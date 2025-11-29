using Dapper;
using Microsoft.Data.SqlClient;
using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço de leitura de metadados do banco SAG usando Dapper.
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
        const string sql = @"
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
                ISNULL(MASCCAMP, '') as MascCamp,
                MINICAMP as MiniCamp,
                MAXICAMP as MaxiCamp,
                ISNULL(DECICAMP, 0) as DeciCamp,
                CAST(SQL_CAMP as NVARCHAR(MAX)) as SqlCamp,
                CAST(VARECAMP as NVARCHAR(MAX)) as VareCamp,
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
            ORDER BY TOPOCAMP, ESQUCAMP, ORDECAMP";

        try
        {
            await using var connection = new SqlConnection(_connectionString);
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

    /// <inheritdoc/>
    public async Task<Dictionary<int, string>> GetAvailableTablesAsync()
    {
        const string sql = @"
            SELECT DISTINCT CODITABE
            FROM SISTCAMP
            WHERE CODITABE IS NOT NULL
            ORDER BY CODITABE";

        try
        {
            await using var connection = new SqlConnection(_connectionString);
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
