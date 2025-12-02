using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Data.Sqlite;

/// <summary>
/// Script para exportar dados do SQL Server para SQLite.
/// Execute com: dotnet run --project Tools/ExportToSqlite.csproj
/// </summary>
public class ExportToSqlite
{
    public static async Task Main(string[] args)
    {
        var sqlServerConn = "Server=MOOVEFY-0150\\SQLEXPRESS;Database=SAG_TESTE;Trusted_Connection=True;TrustServerCertificate=True;";
        var sqliteFile = args.Length > 0 ? args[0] : "sag_poc.db";

        Console.WriteLine($"Exportando dados para: {sqliteFile}");

        // Remove arquivo existente
        if (File.Exists(sqliteFile))
        {
            File.Delete(sqliteFile);
            Console.WriteLine("Arquivo SQLite existente removido.");
        }

        // Cria banco SQLite
        using var sqlite = new SqliteConnection($"Data Source={sqliteFile}");
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
        Console.WriteLine("Tabela SistCamp criada.");

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

        Console.WriteLine($"Lidos {data.Count()} registros do SQL Server.");

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

        Console.WriteLine($"Inseridos {count} registros no SQLite.");
        Console.WriteLine($"\nArquivo criado: {Path.GetFullPath(sqliteFile)}");
        Console.WriteLine("\nPronto! Copie o arquivo .db para o servidor junto com a aplicação.");
    }
}
