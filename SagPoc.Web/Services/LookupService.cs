using Dapper;
using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Data.Sqlite;
using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço para executar queries SQL_CAMP e popular combos T/IT.
/// Suporta SQL Server e SQLite.
/// </summary>
public class LookupService : ILookupService
{
    private readonly string _connectionString;
    private readonly string _provider;
    private readonly ILogger<LookupService> _logger;

    public LookupService(IConfiguration configuration, ILogger<LookupService> logger)
    {
        _connectionString = configuration.GetConnectionString("SagDb")
            ?? throw new InvalidOperationException("Connection string 'SagDb' not found.");
        _provider = configuration.GetValue<string>("DatabaseProvider") ?? "SqlServer";
        _logger = logger;
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
    public async Task<List<LookupItem>> ExecuteLookupQueryAsync(string sql)
    {
        if (string.IsNullOrWhiteSpace(sql))
        {
            return new List<LookupItem>();
        }

        try
        {
            // Ajustar SQL para SQLite se necessário
            var adjustedSql = _provider.ToLower() == "sqlite"
                ? AdjustSqlForSqlite(sql)
                : sql;

            using var connection = CreateConnection();
            connection.Open();

            // Executar query dinamicamente - pode ter 1 ou mais colunas
            var results = await connection.QueryAsync(adjustedSql);
            var items = new List<LookupItem>();

            foreach (var row in results)
            {
                // row é um dynamic (DapperRow)
                var dict = (IDictionary<string, object>)row;
                var values = dict.Values.ToList();

                if (values.Count >= 2)
                {
                    // Padrão SQL_CAMP: Coluna 0 = Key, Coluna 1 = Value
                    items.Add(new LookupItem
                    {
                        Key = values[0]?.ToString() ?? string.Empty,
                        Value = values[1]?.ToString() ?? string.Empty
                    });
                }
                else if (values.Count == 1)
                {
                    // Se só tem uma coluna, usa como Key e Value
                    var val = values[0]?.ToString() ?? string.Empty;
                    items.Add(new LookupItem { Key = val, Value = val });
                }
            }

            _logger.LogDebug("Lookup executado: {Count} itens carregados", items.Count);
            return items;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Erro ao executar lookup SQL: {Sql}", sql.Substring(0, Math.Min(100, sql.Length)));
            return new List<LookupItem>();
        }
    }

    /// <summary>
    /// Ajusta SQL do padrão SQL Server para SQLite.
    /// Converte nomes de tabelas e funções básicas.
    /// </summary>
    private string AdjustSqlForSqlite(string sql)
    {
        // Por enquanto, retorna o SQL como está
        // Se necessário, pode adicionar conversões específicas aqui
        // Ex: ISNULL -> COALESCE, TOP -> LIMIT, etc.
        return sql;
    }
}
