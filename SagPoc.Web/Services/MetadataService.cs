using Dapper;
using System.Data;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço de leitura de metadados do banco SAG usando Dapper.
/// Suporta SQL Server e Oracle via IDbProvider.
/// </summary>
public class MetadataService : IMetadataService
{
    private readonly IDbProvider _dbProvider;
    private readonly ILogger<MetadataService> _logger;

    public MetadataService(IDbProvider dbProvider, ILogger<MetadataService> logger)
    {
        _dbProvider = dbProvider;
        _logger = logger;
        _logger.LogInformation("MetadataService inicializado com provider {Provider}", _dbProvider.ProviderName);
    }

    /// <inheritdoc/>
    public async Task<FormMetadata> GetFormMetadataAsync(int codiTabe)
    {
        var fields = await GetFieldsByTableAsync(codiTabe);
        var tableInfo = await GetTableInfoAsync(codiTabe);
        var movementTables = await GetMovementTablesAsync(codiTabe);

        var fieldsList = fields.ToList();

        // Associa campos do cabeçalho a cada movimento onde GuiaCamp = CodiTabe do movimento
        // No Delphi, campos com GuiaCamp=125 aparecem na aba do movimento 125 junto com o grid
        foreach (var movement in movementTables)
        {
            movement.HeaderFields = fieldsList
                .Where(f => f.GuiaCamp == movement.CodiTabe && !f.IsHidden)
                .OrderBy(f => f.OrdeCamp)
                .ThenBy(f => f.TopoCamp)
                .ThenBy(f => f.EsquCamp)
                .ToList();

            if (movement.HeaderFields.Count > 0)
            {
                _logger.LogInformation("Movimento {MovementId} tem {Count} campos de cabeçalho associados (GuiaCamp={GuiaCamp})",
                    movement.CodiTabe, movement.HeaderFields.Count, movement.CodiTabe);
            }
        }

        return new FormMetadata
        {
            TableId = codiTabe,
            TableName = tableInfo.GravTabe ?? $"Tabela{codiTabe}",
            SiglTabe = tableInfo.SiglTabe,
            Title = tableInfo.NomeTabe ?? $"Formulário {codiTabe}",
            Fields = fieldsList,
            MovementTables = movementTables
        };
    }

    /// <summary>
    /// Busca informações da tabela do SISTTABE.
    /// GravTabe = nome físico da tabela (ex: "POCALESI")
    /// SIGLTABE = sufixo de 4 caracteres (ex: "LESI") usado para PK: CODI{SIGLTABE}
    /// </summary>
    private async Task<(string? NomeTabe, string? GravTabe, string? SiglTabe)> GetTableInfoAsync(int codiTabe)
    {
        var sql = $"SELECT NOMETABE, GravTabe, SIGLTABE FROM SISTTABE WHERE CODITABE = {_dbProvider.FormatParameter("CodiTabe")}";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            var result = await connection.QueryFirstOrDefaultAsync<dynamic>(sql, new { CodiTabe = codiTabe });

            if (result != null)
            {
                return (
                    result.NOMETABE?.ToString(),
                    result.GRAVTABE?.ToString()?.Trim(),
                    result.SIGLTABE?.ToString()?.Trim()
                );
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Erro ao buscar info da tabela {CodiTabe}", codiTabe);
        }

        return (null, null, null);
    }

    /// <inheritdoc/>
    public async Task<IEnumerable<FieldMetadata>> GetFieldsByTableAsync(int codiTabe)
    {
        var sql = GetFieldsQuery();

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            var fields = await connection.QueryAsync<FieldMetadata>(sql, new { CodiTabe = codiTabe });

            _logger.LogInformation("Carregados {Count} campos para tabela {TableId}",
                fields.Count(), codiTabe);

            return fields;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar campos da tabela {TableId}", codiTabe);
            throw;
        }
    }

    private string GetFieldsQuery()
    {
        var param = _dbProvider.FormatParameter("CodiTabe");

        return $@"
        SELECT
            CODICAMP as CodiCamp,
            CODITABE as CodiTabe,
            NOMECAMP as NomeCamp,
            {_dbProvider.NullFunction("NAMECAMP", "NOMECAMP")} as NameCamp,
            {_dbProvider.NullFunction("LABECAMP", "''")} as LabeCamp,
            {_dbProvider.NullFunction("HINTCAMP", "''")} as HintCamp,
            {_dbProvider.NullFunction("COMPCAMP", "'E'")} as CompCamp,
            {_dbProvider.NullFunction("TOPOCAMP", "0")} as TopoCamp,
            {_dbProvider.NullFunction("ESQUCAMP", "0")} as EsquCamp,
            {_dbProvider.NullFunction("TAMACAMP", "100")} as TamaCamp,
            {_dbProvider.NullFunction("ALTUCAMP", "21")} as AltuCamp,
            {_dbProvider.NullFunction("GUIACAMP", "0")} as GuiaCamp,
            {_dbProvider.NullFunction("ORDECAMP", "0")} as OrdeCamp,
            {_dbProvider.NullFunction("OBRICAMP", "0")} as ObriCamp,
            {_dbProvider.NullFunction("DESACAMP", "0")} as DesaCamp,
            {_dbProvider.NullFunction("INICCAMP", "0")} as InicCamp,
            {_dbProvider.NullFunction("LBCXCAMP", "0")} as LbcxCamp,
            {_dbProvider.NullFunction("TAGQCAMP", "0")} as TagQCamp,
            {_dbProvider.NullFunction("EXISCAMP", "0")} as ExisCamp,
            {_dbProvider.NullFunction("INTECAMP", "0")} as InteCamp,
            {_dbProvider.NullFunction("MASCCAMP", "''")} as MascCamp,
            MINICAMP as MiniCamp,
            MAXICAMP as MaxiCamp,
            {_dbProvider.NullFunction("DECICAMP", "0")} as DeciCamp,
            PADRCAMP as PadrCamp,
            SQL_CAMP as SqlCamp,
            VARECAMP as VareCamp,
            VAGRCAMP as VaGrCamp,
            CFONCAMP as CfonCamp,
            CTAMCAMP as CtamCamp,
            CCORCAMP as CcorCamp,
            LFONCAMP as LfonCamp,
            LTAMCAMP as LtamCamp,
            LCORCAMP as LcorCamp,
            EXPRCAMP as ExprCamp,
            EPERCAMP as EperCamp
        FROM SISTCAMP
        WHERE CODITABE = {param}
        ORDER BY OrdeCamp, TopoCamp, EsquCamp";
    }

    /// <inheritdoc/>
    public async Task<Dictionary<int, string>> GetAvailableTablesAsync()
    {
        var sql = "SELECT DISTINCT CODITABE FROM SISTCAMP WHERE CODITABE IS NOT NULL ORDER BY CODITABE";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            var tableIds = await connection.QueryAsync<int>(sql);

            return tableIds.ToDictionary(
                id => id,
                id => $"Tabela {id}"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao listar tabelas disponíveis");
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<List<MovementMetadata>> GetMovementTablesAsync(int parentCodiTabe, bool loadChildren = true)
    {
        var param = _dbProvider.FormatParameter("CabeTabe");

        // GRIDTABE, GRCOTABE e PARATABE são campos TEXT (tipo legado) - precisam de CAST para Dapper mapear
        var sql = $@"
            SELECT
                CODITABE as CodiTabe,
                {_dbProvider.NullFunction("NOMETABE", "''")} as NomeTabe,
                {_dbProvider.NullFunction("GRAVTABE", "''")} as GravTabe,
                {_dbProvider.NullFunction("SIGLTABE", "''")} as SiglTabe,
                {_dbProvider.NullFunction("CABETABE", "0")} as CabeTabe,
                {_dbProvider.NullFunction("SERITABE", "0")} as SeriTabe,
                GETATABE as GeTaTabe,
                {_dbProvider.NullFunction("GUI1TABE", "''")} as Gui1Tabe,
                {_dbProvider.CastTextToString("GRIDTABE")} as GridTabe,
                {_dbProvider.CastTextToString("GRCOTABE")} as GrCoTabe,
                {_dbProvider.NullFunction("ALTUTABE", "400")} as AltuTabe,
                {_dbProvider.NullFunction("TAMATABE", "600")} as TamaTabe,
                {_dbProvider.CastTextToString("PARATABE")} as ParaTabe
            FROM SISTTABE
            WHERE CABETABE = {param}
            ORDER BY SERITABE, CODITABE";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var movements = (await connection.QueryAsync<MovementMetadata>(sql, new { CabeTabe = parentCodiTabe })).ToList();

            _logger.LogInformation("Carregados {Count} movimentos para tabela {ParentId}",
                movements.Count, parentCodiTabe);

            // Carrega sub-movimentos (nível 2) se solicitado
            if (loadChildren)
            {
                foreach (var movement in movements)
                {
                    // Trim strings
                    movement.GravTabe = movement.GravTabe?.Trim() ?? string.Empty;
                    movement.SiglTabe = movement.SiglTabe?.Trim() ?? string.Empty;
                    movement.Gui1Tabe = movement.Gui1Tabe?.Trim();

                    // Carrega sub-movimentos (não carrega filhos dos filhos para evitar loop infinito)
                    movement.Children = await GetMovementTablesAsync(movement.CodiTabe, loadChildren: false);

                    if (movement.Children.Count > 0)
                    {
                        _logger.LogInformation("Movimento {MovementId} tem {ChildCount} sub-movimentos",
                            movement.CodiTabe, movement.Children.Count);
                    }
                }
            }

            return movements;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar movimentos da tabela {ParentId}", parentCodiTabe);
            return new List<MovementMetadata>();
        }
    }

    /// <inheritdoc/>
    public async Task<List<FieldMetadata>> GetMovementFieldsAsync(int movementCodiTabe)
    {
        try
        {
            var fields = await GetFieldsByTableAsync(movementCodiTabe);
            return fields.ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar campos do movimento {MovementId}", movementCodiTabe);
            return new List<FieldMetadata>();
        }
    }

    /// <inheritdoc/>
    public async Task<string?> GetFieldLookupSqlAsync(int codiCamp)
    {
        var sql = $"SELECT SQL_CAMP FROM SISTCAMP WHERE CODICAMP = {_dbProvider.FormatParameter("CodiCamp")}";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            var result = await connection.QueryFirstOrDefaultAsync<string?>(sql, new { CodiCamp = codiCamp });
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter SQL de lookup do campo {CodiCamp}", codiCamp);
            return null;
        }
    }
}
