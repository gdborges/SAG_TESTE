using Dapper;
using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Data.Sqlite;
using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço de leitura de metadados do banco SAG usando Dapper.
/// Suporta SQL Server e SQLite.
/// </summary>
public class MetadataService : IMetadataService
{
    private readonly string _connectionString;
    private readonly string _provider;
    private readonly ILogger<MetadataService> _logger;

    public MetadataService(IConfiguration configuration, ILogger<MetadataService> logger)
    {
        _connectionString = configuration.GetConnectionString("SagDb")
            ?? throw new InvalidOperationException("Connection string 'SagDb' not found.");
        _provider = configuration.GetValue<string>("DatabaseProvider") ?? "SqlServer";
        _logger = logger;

        _logger.LogInformation("MetadataService usando provider: {Provider}", _provider);
    }

    private IDbConnection CreateConnection()
    {
        return _provider.ToLower() switch
        {
            "sqlite" => new SqliteConnection(_connectionString),
            _ => new SqlConnection(_connectionString)
        };
    }

    /// <inheritdoc/>
    public async Task<FormMetadata> GetFormMetadataAsync(int codiTabe)
    {
        var fields = await GetFieldsByTableAsync(codiTabe);

        return new FormMetadata
        {
            TableId = codiTabe,
            TableName = $"Tabela {codiTabe}",
            Title = $"Formulário {codiTabe}",
            Fields = fields.ToList()
        };
    }

    /// <inheritdoc/>
    public async Task<IEnumerable<FieldMetadata>> GetFieldsByTableAsync(int codiTabe)
    {
        // SQL compatível com ambos os bancos
        var sql = _provider.ToLower() == "sqlite"
            ? GetSqliteFieldsQuery()
            : GetSqlServerFieldsQuery();

        try
        {
            using var connection = CreateConnection();
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

    private string GetSqlServerFieldsQuery() => @"
        WITH CamposUnicos AS (
            SELECT
                CODICAMP as CodiCamp,
                CODITABE as CodiTabe,
                NOMECAMP as NomeCamp,
                ISNULL(LABECAMP, '') as LabeCamp,
                ISNULL(HINTCAMP, '') as HintCamp,
                ISNULL(COMPCAMP, 'E') as CompCamp,
                ISNULL(TOPOCAMP, 0) as TopoCamp,
                ISNULL(ESQUCAMP, 0) as EsquCamp,
                ISNULL(TAMACAMP, 100) as TamaCamp,
                ISNULL(ALTUCAMP, 21) as AltuCamp,
                ISNULL(GUIACAMP, 0) as GuiaCamp,
                ISNULL(ORDECAMP, 0) as OrdeCamp,
                ISNULL(OBRICAMP, 0) as ObriCamp,
                ISNULL(DESACAMP, 0) as DesaCamp,
                ISNULL(INICCAMP, 0) as InicCamp,
                ISNULL(LBCXCAMP, 0) as LbcxCamp,
                ISNULL(MASCCAMP, '') as MascCamp,
                MINICAMP as MiniCamp,
                MAXICAMP as MaxiCamp,
                ISNULL(DECICAMP, 0) as DeciCamp,
                PADRCAMP as PadrCamp,
                CAST(SQL_CAMP as NVARCHAR(MAX)) as SqlCamp,
                CAST(VARECAMP as NVARCHAR(MAX)) as VareCamp,
                CFONCAMP as CfonCamp,
                CTAMCAMP as CtamCamp,
                CCORCAMP as CcorCamp,
                LFONCAMP as LfonCamp,
                LTAMCAMP as LtamCamp,
                LCORCAMP as LcorCamp,
                CAST(EXPRCAMP as NVARCHAR(MAX)) as ExprCamp,
                CAST(EPERCAMP as NVARCHAR(MAX)) as EperCamp,
                ROW_NUMBER() OVER (PARTITION BY NOMECAMP ORDER BY CODICAMP) as RowNum
            FROM SISTCAMP
            WHERE CODITABE = @CodiTabe
        )
        SELECT CodiCamp, CodiTabe, NomeCamp, LabeCamp, HintCamp, CompCamp,
               TopoCamp, EsquCamp, TamaCamp, AltuCamp, GuiaCamp, OrdeCamp,
               ObriCamp, DesaCamp, InicCamp, LbcxCamp, MascCamp, MiniCamp, MaxiCamp,
               DeciCamp, PadrCamp, SqlCamp, VareCamp, CfonCamp, CtamCamp, CcorCamp,
               LfonCamp, LtamCamp, LcorCamp, ExprCamp, EperCamp
        FROM CamposUnicos
        WHERE RowNum = 1
        ORDER BY OrdeCamp, TopoCamp, EsquCamp";

    private string GetSqliteFieldsQuery() => @"
        SELECT
            CodiCamp,
            CodiTabe,
            NomeCamp,
            COALESCE(LabeCamp, '') as LabeCamp,
            COALESCE(HintCamp, '') as HintCamp,
            COALESCE(CompCamp, 'E') as CompCamp,
            COALESCE(TopoCamp, 0) as TopoCamp,
            COALESCE(EsquCamp, 0) as EsquCamp,
            COALESCE(TamaCamp, 100) as TamaCamp,
            COALESCE(AltuCamp, 21) as AltuCamp,
            COALESCE(GuiaCamp, 0) as GuiaCamp,
            COALESCE(OrdeCamp, 0) as OrdeCamp,
            COALESCE(ObriCamp, 0) as ObriCamp,
            COALESCE(DesaCamp, 0) as DesaCamp,
            COALESCE(InicCamp, 0) as InicCamp,
            COALESCE(LbcxCamp, 0) as LbcxCamp,
            COALESCE(MascCamp, '') as MascCamp,
            MiniCamp,
            MaxiCamp,
            COALESCE(DeciCamp, 0) as DeciCamp,
            PadrCamp,
            SqlCamp,
            VareCamp,
            CfonCamp,
            CtamCamp,
            CcorCamp,
            LfonCamp,
            LtamCamp,
            LcorCamp,
            ExprCamp,
            EperCamp
        FROM SistCamp
        WHERE CodiTabe = @CodiTabe
        ORDER BY OrdeCamp, TopoCamp, EsquCamp";

    /// <inheritdoc/>
    public async Task<Dictionary<int, string>> GetAvailableTablesAsync()
    {
        var sql = _provider.ToLower() == "sqlite"
            ? "SELECT DISTINCT CodiTabe FROM SistCamp WHERE CodiTabe IS NOT NULL ORDER BY CodiTabe"
            : "SELECT DISTINCT CODITABE FROM SISTCAMP WHERE CODITABE IS NOT NULL ORDER BY CODITABE";

        try
        {
            using var connection = CreateConnection();
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
}
