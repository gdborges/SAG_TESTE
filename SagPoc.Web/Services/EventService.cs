using Dapper;
using System.Data;
using Microsoft.Data.SqlClient;
using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço para carregar dados de eventos PLSAG do banco.
/// Consulta SISTTABE para eventos de formulário e SISTCAMP para eventos de campo.
/// </summary>
public class EventService : IEventService
{
    private readonly string _connectionString;
    private readonly ILogger<EventService> _logger;

    public EventService(IConfiguration configuration, ILogger<EventService> logger)
    {
        _connectionString = configuration.GetConnectionString("SagDb")
            ?? throw new InvalidOperationException("Connection string 'SagDb' not found.");
        _logger = logger;
    }

    private IDbConnection CreateConnection() => new SqlConnection(_connectionString);

    /// <inheritdoc/>
    public async Task<FormEventData> GetFormEventsAsync(int codiTabe)
    {
        var sql = @"
            SELECT
                CODITABE as CodiTabe,
                ISNULL(NOMETABE, '') as NomeTabe,
                CAST(SHOWTABE as NVARCHAR(MAX)) as ShowTabeInstructions,
                CAST(LANCTABE as NVARCHAR(MAX)) as LancTabeInstructions,
                CAST(EGRATABE as NVARCHAR(MAX)) as EGraTabeInstructions,
                CAST(APOSTABE as NVARCHAR(MAX)) as AposTabeInstructions,
                CAST(EPERTABE as NVARCHAR(MAX)) as EPerTabeInstructions
            FROM SISTTABE
            WHERE CODITABE = @CodiTabe";

        try
        {
            using var connection = CreateConnection();
            connection.Open();
            var result = await connection.QueryFirstOrDefaultAsync<FormEventData>(sql, new { CodiTabe = codiTabe });

            if (result != null)
            {
                // Mescla EPerTabe com cada instrução (similar ao Delphi)
                result.ShowTabeInstructions = MergeInstructions(result.ShowTabeInstructions, result.EPerTabeInstructions);
                result.LancTabeInstructions = MergeInstructions(result.LancTabeInstructions, result.EPerTabeInstructions);
                result.EGraTabeInstructions = MergeInstructions(result.EGraTabeInstructions, result.EPerTabeInstructions);
                result.AposTabeInstructions = MergeInstructions(result.AposTabeInstructions, result.EPerTabeInstructions);

                // Carrega AnteCria e DepoCria do SISTCAMP
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
        var sql = @"
            SELECT
                CODICAMP as CodiCamp,
                ISNULL(NOMECAMP, '') as NomeCamp,
                ISNULL(COMPCAMP, 'E') as CompCamp,
                ISNULL(OBRICAMP, 0) as ObriCamp,
                CAST(EXPRCAMP as NVARCHAR(MAX)) as ExprCamp,
                CAST(EPERCAMP as NVARCHAR(MAX)) as EPerCamp,
                CAST(EXP1CAMP as NVARCHAR(MAX)) as Exp1Camp,
                ISNULL(INICCAMP, 0) as InicCamp,
                CAST(VAGRCAMP as NVARCHAR(MAX)) as VaGrCamp,
                PADRCAMP as PadrCamp,
                ISNULL(TAGQCAMP, 0) as TagQCamp
            FROM SISTCAMP
            WHERE CODITABE = @CodiTabe
              AND NOMECAMP NOT IN ('AnteCria', 'DepoCria', 'DEPOSHOW', 'ATUAGRID')
            ORDER BY ORDECAMP";

        try
        {
            using var connection = CreateConnection();
            connection.Open();
            var fields = await connection.QueryAsync<dynamic>(sql, new { CodiTabe = codiTabe });

            var result = new Dictionary<int, FieldEventData>();

            foreach (var field in fields)
            {
                var compType = ((string)(field.CompCamp ?? "E"))?.ToUpper()?.Trim() ?? "E";

                var eventData = new FieldEventData
                {
                    CodiCamp = (int)field.CodiCamp,
                    NomeCamp = (string)(field.NomeCamp ?? ""),
                    IsRequired = (int)field.ObriCamp != 0,
                    // Campos para InicValoCampPers
                    CompCamp = compType,
                    InicCamp = (int)(field.InicCamp ?? 0),
                    DefaultText = (string?)(field.VaGrCamp),
                    DefaultNumber = field.PadrCamp != null ? (double?)Convert.ToDouble(field.PadrCamp) : null,
                    IsSequential = (int)(field.TagQCamp ?? 0) == 1
                };

                // Mescla ExprCamp + EPerCamp
                var instructions = MergeInstructions(
                    (string)(field.ExprCamp ?? ""),
                    (string)(field.EPerCamp ?? ""));

                if (IsClickComponent(compType))
                {
                    eventData.OnClickInstructions = instructions;
                }
                else
                {
                    eventData.OnExitInstructions = instructions;
                }

                // Grid usa Exp1Camp para DblClick
                if (compType == "DBG")
                {
                    eventData.OnDblClickInstructions = MergeInstructions(
                        (string)(field.Exp1Camp ?? ""),
                        (string)(field.EPerCamp ?? ""));
                }

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
        var sql = @"
            SELECT
                NOMECAMP as NomeCamp,
                CAST(EXPRCAMP as NVARCHAR(MAX)) as ExprCamp
            FROM SISTCAMP
            WHERE CODITABE = @CodiTabe
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
    /// Similar ao CampPers_TratExec do Delphi.
    /// </summary>
    private string MergeInstructions(string primary, string permanent)
    {
        if (string.IsNullOrWhiteSpace(primary) && string.IsNullOrWhiteSpace(permanent))
            return string.Empty;

        if (string.IsNullOrWhiteSpace(primary))
            return permanent?.Trim() ?? string.Empty;

        if (string.IsNullOrWhiteSpace(permanent))
            return primary?.Trim() ?? string.Empty;

        // Mescla: primary primeiro, depois permanent
        return $"{primary.Trim()}\n{permanent.Trim()}";
    }

    /// <summary>
    /// Determina se o componente usa OnClick ao invés de OnExit.
    /// Baseado na tabela de mapeamento do Delphi.
    /// </summary>
    private bool IsClickComponent(string compType)
    {
        return compType switch
        {
            "S" or "ES" => true,   // Checkbox
            "BTN" => true,          // Botão
            "LC" => true,           // Lista de checkboxes
            _ => false
        };
    }
}
