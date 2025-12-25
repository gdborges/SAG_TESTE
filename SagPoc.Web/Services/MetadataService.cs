using Dapper;
using System.Data;
using Microsoft.Data.SqlClient;
using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço de leitura de metadados do banco SAG usando Dapper.
/// Conecta ao SQL Server Azure.
/// </summary>
public class MetadataService : IMetadataService
{
    private readonly string _connectionString;
    private readonly ILogger<MetadataService> _logger;

    public MetadataService(IConfiguration configuration, ILogger<MetadataService> logger)
    {
        _connectionString = configuration.GetConnectionString("SagDb")
            ?? throw new InvalidOperationException("Connection string 'SagDb' not found.");
        _logger = logger;

        _logger.LogInformation("MetadataService inicializado - SQL Server Azure");
    }

    private IDbConnection CreateConnection()
    {
        return new SqlConnection(_connectionString);
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
        var sql = GetFieldsQuery();

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

    private string GetFieldsQuery() => @"
        SELECT
            CODICAMP as CodiCamp,
            CODITABE as CodiTabe,
            NOMECAMP as NomeCamp,
            ISNULL(NAMECAMP, NOMECAMP) as NameCamp,
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
            CAST(VAGRCAMP as NVARCHAR(MAX)) as VaGrCamp,
            CFONCAMP as CfonCamp,
            CTAMCAMP as CtamCamp,
            CCORCAMP as CcorCamp,
            LFONCAMP as LfonCamp,
            LTAMCAMP as LtamCamp,
            LCORCAMP as LcorCamp,
            CAST(EXPRCAMP as NVARCHAR(MAX)) as ExprCamp,
            CAST(EPERCAMP as NVARCHAR(MAX)) as EperCamp
        FROM SISTCAMP
        WHERE CODITABE = @CodiTabe
        ORDER BY OrdeCamp, TopoCamp, EsquCamp";

    /// <inheritdoc/>
    public async Task<Dictionary<int, string>> GetAvailableTablesAsync()
    {
        var sql = "SELECT DISTINCT CODITABE FROM SISTCAMP WHERE CODITABE IS NOT NULL ORDER BY CODITABE";

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
