using Dapper;
using System.Data;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço para carregar dados de eventos PLSAG do banco.
/// Consulta SISTTABE para eventos de formulário e SISTCAMP para eventos de campo.
/// Suporta SQL Server e Oracle via IDbProvider.
/// </summary>
public class EventService : IEventService
{
    private readonly IDbProvider _dbProvider;
    private readonly ILogger<EventService> _logger;

    public EventService(IDbProvider dbProvider, ILogger<EventService> logger)
    {
        _dbProvider = dbProvider;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<FormEventData> GetFormEventsAsync(int codiTabe)
    {
        var sql = $@"
            SELECT
                CODITABE as CodiTabe,
                {_dbProvider.NullFunction("NOMETABE", "''")} as NomeTabe,
                SHOWTABE as ShowTabeInstructions,
                LANCTABE as LancTabeInstructions,
                EGRATABE as EGraTabeInstructions,
                APOSTABE as AposTabeInstructions,
                EPERTABE as EPerTabeInstructions
            FROM SISTTABE
            WHERE CODITABE = {_dbProvider.FormatParameter("CodiTabe")}";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            var result = await connection.QueryFirstOrDefaultAsync<FormEventData>(sql, new { CodiTabe = codiTabe });

            if (result != null)
            {
                result.ShowTabeInstructions = MergeInstructions(result.ShowTabeInstructions, result.EPerTabeInstructions);
                result.LancTabeInstructions = MergeInstructions(result.LancTabeInstructions, result.EPerTabeInstructions);
                result.EGraTabeInstructions = MergeInstructions(result.EGraTabeInstructions, result.EPerTabeInstructions);
                result.AposTabeInstructions = MergeInstructions(result.AposTabeInstructions, result.EPerTabeInstructions);

                await LoadSpecialFieldEventsAsync(connection, codiTabe, result);
            }

            _logger.LogInformation("Eventos do form {CodiTabe} carregados", codiTabe);
            return result ?? new FormEventData { CodiTabe = codiTabe };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar eventos do form {CodiTabe}", codiTabe);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<Dictionary<int, FieldEventData>> GetFieldEventsAsync(int codiTabe)
    {
        var sql = $@"
            SELECT
                CODICAMP as CodiCamp,
                {_dbProvider.NullFunction("NOMECAMP", "''")} as NomeCamp,
                {_dbProvider.NullFunction("COMPCAMP", "'E'")} as CompCamp,
                {_dbProvider.NullFunction("OBRICAMP", "0")} as ObriCamp,
                EXPRCAMP as ExprCamp,
                EPERCAMP as EPerCamp,
                EXP1CAMP as Exp1Camp,
                {_dbProvider.NullFunction("INICCAMP", "0")} as InicCamp,
                VAGRCAMP as VaGrCamp,
                PADRCAMP as PadrCamp,
                {_dbProvider.NullFunction("TAGQCAMP", "0")} as TagQCamp
            FROM SISTCAMP
            WHERE CODITABE = {_dbProvider.FormatParameter("CodiTabe")}
              AND NOMECAMP NOT IN ('AnteCria', 'DepoCria', 'DEPOSHOW', 'ATUAGRID')
            ORDER BY ORDECAMP";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            var fields = await connection.QueryAsync<dynamic>(sql, new { CodiTabe = codiTabe });

            var fieldsList = fields.ToList();
            _logger.LogInformation("Query retornou {Count} registros para tabela {CodiTabe}", fieldsList.Count, codiTabe);

            var result = new Dictionary<int, FieldEventData>();

            foreach (var field in fieldsList)
            {
                // Oracle retorna colunas em MAIÚSCULO, SQL Server mantém o alias
                var fieldDict = (IDictionary<string, object>)field;

                var codiCamp = fieldDict.ContainsKey("CodiCamp") ? fieldDict["CodiCamp"] : fieldDict["CODICAMP"];
                var nomeCamp = fieldDict.ContainsKey("NomeCamp") ? fieldDict["NomeCamp"] : fieldDict["NOMECAMP"];
                var compCamp = fieldDict.ContainsKey("CompCamp") ? fieldDict["CompCamp"] : fieldDict["COMPCAMP"];
                var obriCamp = fieldDict.ContainsKey("ObriCamp") ? fieldDict["ObriCamp"] : fieldDict["OBRICAMP"];
                var exprCamp = fieldDict.ContainsKey("ExprCamp") ? fieldDict["ExprCamp"] : fieldDict["EXPRCAMP"];
                var ePerCamp = fieldDict.ContainsKey("EPerCamp") ? fieldDict["EPerCamp"] : fieldDict["EPERCAMP"];
                var exp1Camp = fieldDict.ContainsKey("Exp1Camp") ? fieldDict["Exp1Camp"] : fieldDict["EXP1CAMP"];
                var inicCamp = fieldDict.ContainsKey("InicCamp") ? fieldDict["InicCamp"] : fieldDict["INICCAMP"];
                var vaGrCamp = fieldDict.ContainsKey("VaGrCamp") ? fieldDict["VaGrCamp"] : fieldDict["VAGRCAMP"];
                var padrCamp = fieldDict.ContainsKey("PadrCamp") ? fieldDict["PadrCamp"] : fieldDict["PADRCAMP"];
                var tagQCamp = fieldDict.ContainsKey("TagQCamp") ? fieldDict["TagQCamp"] : fieldDict["TAGQCAMP"];

                var compType = ((string)(compCamp ?? "E"))?.ToUpper()?.Trim() ?? "E";

                var eventData = new FieldEventData
                {
                    CodiCamp = int.TryParse(codiCamp?.ToString(), out var codiVal) ? codiVal : 0,
                    NomeCamp = (string)(nomeCamp ?? ""),
                    IsRequired = int.TryParse(obriCamp?.ToString(), out var obriVal) && obriVal != 0,
                    CompCamp = compType,
                    InicCamp = int.TryParse(inicCamp?.ToString(), out var inicVal) ? inicVal : 0,
                    DefaultText = (string?)(vaGrCamp),
                    DefaultNumber = double.TryParse(padrCamp?.ToString(), out var padrVal) ? padrVal : null,
                    IsSequential = int.TryParse(tagQCamp?.ToString(), out var tagQVal) && tagQVal == 1
                };

                var instructions = MergeInstructions(
                    (string)(exprCamp ?? ""),
                    (string)(ePerCamp ?? ""));

                if (IsClickComponent(compType))
                {
                    eventData.OnClickInstructions = instructions;
                }
                else
                {
                    eventData.OnExitInstructions = instructions;
                }

                if (compType == "DBG")
                {
                    eventData.OnDblClickInstructions = MergeInstructions(
                        (string)(exp1Camp ?? ""),
                        (string)(ePerCamp ?? ""));
                }

                _logger.LogDebug("Campo {CodiCamp} ({NomeCamp}) adicionado ao resultado",
                    eventData.CodiCamp, eventData.NomeCamp);
                result[eventData.CodiCamp] = eventData;
            }

            _logger.LogInformation("Eventos de {Count} campos carregados para tabela {CodiTabe}",
                result.Count, codiTabe);

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar eventos dos campos da tabela {CodiTabe}", codiTabe);
            throw;
        }
    }

    /// <summary>
    /// Carrega campos especiais AnteCria, DepoCria, DepoShow e AtuaGrid do SISTCAMP.
    /// </summary>
    private async Task LoadSpecialFieldEventsAsync(IDbConnection connection, int codiTabe, FormEventData result)
    {
        var sql = $@"
            SELECT
                NOMECAMP as NomeCamp,
                EXPRCAMP as ExprCamp
            FROM SISTCAMP
            WHERE CODITABE = {_dbProvider.FormatParameter("CodiTabe")}
              AND UPPER(NOMECAMP) IN ('ANTECRIA', 'DEPOCRIA', 'DEPOSHOW', 'ATUAGRID')";

        var specialFields = await connection.QueryAsync<dynamic>(sql, new { CodiTabe = codiTabe });

        foreach (var field in specialFields)
        {
            var nome = ((string)(field.NomeCamp ?? ""))?.ToUpper()?.Trim();
            var expr = (string)(field.ExprCamp ?? "");

            if (nome == "ANTECRIA")
                result.AntecriaInstructions = expr;
            else if (nome == "DEPOCRIA")
                result.DepocriaInstructions = expr;
            else if (nome == "DEPOSHOW")
                result.DepoShowInstructions = expr;
            else if (nome == "ATUAGRID")
                result.AtuaGridInstructions = expr;
        }
    }

    /// <summary>
    /// Mescla instruções primárias com instruções permanentes.
    /// </summary>
    private string MergeInstructions(string primary, string permanent)
    {
        if (string.IsNullOrWhiteSpace(primary) && string.IsNullOrWhiteSpace(permanent))
            return string.Empty;

        if (string.IsNullOrWhiteSpace(primary))
            return permanent?.Trim() ?? string.Empty;

        if (string.IsNullOrWhiteSpace(permanent))
            return primary?.Trim() ?? string.Empty;

        return $"{primary.Trim()}\n{permanent.Trim()}";
    }

    /// <summary>
    /// Determina se o componente usa OnClick ao invés de OnExit.
    /// </summary>
    private bool IsClickComponent(string compType)
    {
        return compType switch
        {
            "S" or "ES" => true,
            "BTN" => true,
            "LC" => true,
            _ => false
        };
    }

    /// <inheritdoc/>
    public async Task<MovementEventData> GetMovementEventsAsync(int parentCodiTabe, int movementCodiTabe)
    {
        // Campos virtuais de evento de movimento seguem o padrão NomeCamp_CodiTabe
        // Ex: AnteIAE_Movi_815, DepoIncl_815, etc.
        var eventPatterns = new[]
        {
            $"AnteIAE_Movi_{movementCodiTabe}",
            $"AnteIncl_{movementCodiTabe}",
            $"AnteAlte_{movementCodiTabe}",
            $"AnteExcl_{movementCodiTabe}",
            $"DepoIAE_Movi_{movementCodiTabe}",
            $"DepoIncl_{movementCodiTabe}",
            $"DepoAlte_{movementCodiTabe}",
            $"DepoExcl_{movementCodiTabe}",
            $"AtuaGrid_{movementCodiTabe}",
            $"ShowPai_Filh_{movementCodiTabe}"
        };

        // Constrói IN clause dinâmico
        var inClause = string.Join(", ", eventPatterns.Select((_, i) => _dbProvider.FormatParameter($"Name{i}")));
        var parameters = new DynamicParameters();
        parameters.Add("CodiTabe", parentCodiTabe);
        for (int i = 0; i < eventPatterns.Length; i++)
        {
            parameters.Add($"Name{i}", eventPatterns[i]);
        }

        var sql = $@"
            SELECT
                UPPER({_dbProvider.NullFunction("NOMECAMP", "''")}) as NomeCamp,
                {_dbProvider.NullFunction("EXPRCAMP", "''")} as ExprCamp,
                {_dbProvider.NullFunction("EPERCAMP", "''")} as EPerCamp
            FROM SISTCAMP
            WHERE CODITABE = {_dbProvider.FormatParameter("CodiTabe")}
              AND UPPER(NOMECAMP) IN ({inClause})";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var fields = await connection.QueryAsync<dynamic>(sql, parameters);

            var result = new MovementEventData
            {
                ParentCodiTabe = parentCodiTabe,
                MovementCodiTabe = movementCodiTabe
            };

            foreach (var field in fields)
            {
                var fieldDict = (IDictionary<string, object>)field;
                var nomeCamp = ((string)(fieldDict.ContainsKey("NomeCamp") ? fieldDict["NomeCamp"] : fieldDict["NOMECAMP"]))?.ToUpper()?.Trim() ?? "";
                var exprCamp = (string)(fieldDict.ContainsKey("ExprCamp") ? fieldDict["ExprCamp"] : fieldDict["EXPRCAMP"]) ?? "";
                var ePerCamp = (string)(fieldDict.ContainsKey("EPerCamp") ? fieldDict["EPerCamp"] : fieldDict["EPERCAMP"]) ?? "";

                var instructions = MergeInstructions(exprCamp, ePerCamp);

                if (nomeCamp == $"ANTEIAE_MOVI_{movementCodiTabe}")
                    result.AnteIAEMoviInstructions = instructions;
                else if (nomeCamp == $"ANTEINCL_{movementCodiTabe}")
                    result.AnteInclInstructions = instructions;
                else if (nomeCamp == $"ANTEALTE_{movementCodiTabe}")
                    result.AnteAlteInstructions = instructions;
                else if (nomeCamp == $"ANTEEXCL_{movementCodiTabe}")
                    result.AnteExclInstructions = instructions;
                else if (nomeCamp == $"DEPOIAE_MOVI_{movementCodiTabe}")
                    result.DepoIAEMoviInstructions = instructions;
                else if (nomeCamp == $"DEPOINCL_{movementCodiTabe}")
                    result.DepoInclInstructions = instructions;
                else if (nomeCamp == $"DEPOALTE_{movementCodiTabe}")
                    result.DepoAlteInstructions = instructions;
                else if (nomeCamp == $"DEPOEXCL_{movementCodiTabe}")
                    result.DepoExclInstructions = instructions;
                else if (nomeCamp == $"ATUAGRID_{movementCodiTabe}")
                    result.AtuaGridInstructions = instructions;
                else if (nomeCamp == $"SHOWPAI_FILH_{movementCodiTabe}")
                    result.ShowPaiFilhInstructions = instructions;
            }

            // Carrega DEPOSHOW da tabela de movimento (não do pai)
            // O DEPOSHOW contém comandos QY para injeção dinâmica de filtros em lookups
            var depoShowSql = $@"
                SELECT
                    {_dbProvider.NullFunction("EXPRCAMP", "''")} as ExprCamp,
                    {_dbProvider.NullFunction("EPERCAMP", "''")} as EPerCamp
                FROM SISTCAMP
                WHERE CODITABE = {_dbProvider.FormatParameter("MovementCodiTabe")}
                  AND UPPER(NOMECAMP) = 'DEPOSHOW'";

            var depoShowParams = new DynamicParameters();
            depoShowParams.Add("MovementCodiTabe", movementCodiTabe);

            var depoShowResult = await connection.QueryFirstOrDefaultAsync<dynamic>(depoShowSql, depoShowParams);
            if (depoShowResult != null)
            {
                var dsDict = (IDictionary<string, object>)depoShowResult;
                var dsExprCamp = (string)(dsDict.ContainsKey("ExprCamp") ? dsDict["ExprCamp"] : dsDict["EXPRCAMP"]) ?? "";
                var dsEPerCamp = (string)(dsDict.ContainsKey("EPerCamp") ? dsDict["EPerCamp"] : dsDict["EPERCAMP"]) ?? "";
                result.DepoShowInstructions = MergeInstructions(dsExprCamp, dsEPerCamp);
            }

            _logger.LogInformation("Eventos do movimento {MovementCodiTabe} (pai {ParentCodiTabe}) carregados. HasEvents: {HasEvents}, HasDepoShow: {HasDepoShow}",
                movementCodiTabe, parentCodiTabe, result.HasEvents, !string.IsNullOrWhiteSpace(result.DepoShowInstructions));

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar eventos do movimento {MovementCodiTabe}", movementCodiTabe);
            throw;
        }
    }
}
