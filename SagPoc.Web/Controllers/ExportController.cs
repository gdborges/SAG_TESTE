using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Data.Sqlite;

namespace SagPoc.Web.Controllers;

/// <summary>
/// Controller temporário para exportar dados para SQLite.
/// Remover após o deploy.
/// </summary>
public class ExportController : Controller
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<ExportController> _logger;

    public ExportController(IConfiguration configuration, ILogger<ExportController> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    /// <summary>
    /// Exporta dados do SQL Server para SQLite e retorna o arquivo.
    /// Acesse: /Export/ToSqlite
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> ToSqlite()
    {
        var sqlServerConn = _configuration.GetConnectionString("SagDb");
        var tempFile = Path.Combine(Path.GetTempPath(), "sag_poc.db");

        try
        {
            // Remove arquivo existente
            if (System.IO.File.Exists(tempFile))
            {
                System.IO.File.Delete(tempFile);
            }

            // Cria banco SQLite
            using var sqlite = new SqliteConnection($"Data Source={tempFile}");
            sqlite.Open();

            // Cria tabela
            var createTable = @"
                CREATE TABLE SistCamp (
                    CodiCamp INTEGER PRIMARY KEY,
                    CodiTabe INTEGER,
                    NomeCamp TEXT,
                    LabeCamp TEXT,
                    HintCamp TEXT,
                    CompCamp TEXT,
                    TopoCamp INTEGER,
                    EsquCamp INTEGER,
                    TamaCamp INTEGER,
                    AltuCamp INTEGER,
                    GuiaCamp INTEGER,
                    OrdeCamp INTEGER,
                    ObriCamp INTEGER,
                    DesaCamp INTEGER,
                    InicCamp INTEGER,
                    MascCamp TEXT,
                    MiniCamp REAL,
                    MaxiCamp REAL,
                    DeciCamp INTEGER,
                    SqlCamp TEXT,
                    VareCamp TEXT,
                    CfonCamp TEXT,
                    CtamCamp INTEGER,
                    CcorCamp INTEGER,
                    LfonCamp TEXT,
                    LtamCamp INTEGER,
                    LcorCamp INTEGER,
                    ExprCamp TEXT,
                    EperCamp TEXT
                )";

            await sqlite.ExecuteAsync(createTable);
            _logger.LogInformation("Tabela SistCamp criada no SQLite");

            // Lê dados do SQL Server
            using var sqlServer = new SqlConnection(sqlServerConn);
            var data = await sqlServer.QueryAsync<dynamic>(@"
                SELECT
                    CODICAMP, CODITABE, NOMECAMP, LABECAMP, HINTCAMP, COMPCAMP,
                    TOPOCAMP, ESQUCAMP, TAMACAMP, ALTUCAMP, GUIACAMP, ORDECAMP,
                    OBRICAMP, DESACAMP, INICCAMP, MASCCAMP, MINICAMP, MAXICAMP,
                    DECICAMP, CAST(SQL_CAMP as NVARCHAR(MAX)) as SQL_CAMP,
                    CAST(VARECAMP as NVARCHAR(MAX)) as VARECAMP,
                    CFONCAMP, CTAMCAMP, CCORCAMP, LFONCAMP, LTAMCAMP, LCORCAMP,
                    CAST(EXPRCAMP as NVARCHAR(MAX)) as EXPRCAMP,
                    CAST(EPERCAMP as NVARCHAR(MAX)) as EPERCAMP
                FROM SISTCAMP");

            _logger.LogInformation("Lidos {Count} registros do SQL Server", data.Count());

            // Insere no SQLite
            var insertSql = @"
                INSERT INTO SistCamp (
                    CodiCamp, CodiTabe, NomeCamp, LabeCamp, HintCamp, CompCamp,
                    TopoCamp, EsquCamp, TamaCamp, AltuCamp, GuiaCamp, OrdeCamp,
                    ObriCamp, DesaCamp, InicCamp, MascCamp, MiniCamp, MaxiCamp,
                    DeciCamp, SqlCamp, VareCamp, CfonCamp, CtamCamp, CcorCamp,
                    LfonCamp, LtamCamp, LcorCamp, ExprCamp, EperCamp
                ) VALUES (
                    @CODICAMP, @CODITABE, @NOMECAMP, @LABECAMP, @HINTCAMP, @COMPCAMP,
                    @TOPOCAMP, @ESQUCAMP, @TAMACAMP, @ALTUCAMP, @GUIACAMP, @ORDECAMP,
                    @OBRICAMP, @DESACAMP, @INICCAMP, @MASCCAMP, @MINICAMP, @MAXICAMP,
                    @DECICAMP, @SQL_CAMP, @VARECAMP, @CFONCAMP, @CTAMCAMP, @CCORCAMP,
                    @LFONCAMP, @LTAMCAMP, @LCORCAMP, @EXPRCAMP, @EPERCAMP
                )";

            var count = 0;
            foreach (var row in data)
            {
                await sqlite.ExecuteAsync(insertSql, (object)row);
                count++;
            }

            _logger.LogInformation("Inseridos {Count} registros no SQLite", count);

            // Fecha conexão explicitamente antes de ler o arquivo
            sqlite.Close();
            sqlite.Dispose();

            // Limpa pool de conexões SQLite (importante!)
            SqliteConnection.ClearAllPools();

            // Pequena pausa para garantir que arquivo foi liberado
            await Task.Delay(200);

            // Retorna o arquivo para download
            var fileBytes = await System.IO.File.ReadAllBytesAsync(tempFile);
            return File(fileBytes, "application/octet-stream", "sag_poc.db");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao exportar para SQLite");
            return Content($"Erro: {ex.Message}");
        }
    }
}
