using Dapper;
using System.Data;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço para executar queries SQL_CAMP e popular combos T/IT.
/// Suporta SQL Server e Oracle via IDbProvider.
/// </summary>
public class LookupService : ILookupService
{
    private readonly IDbProvider _dbProvider;
    private readonly ILogger<LookupService> _logger;

    public LookupService(IDbProvider dbProvider, ILogger<LookupService> logger)
    {
        _dbProvider = dbProvider;
        _logger = logger;
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
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var results = await connection.QueryAsync(sql);
            var items = new List<LookupItem>();

            foreach (var row in results)
            {
                var dict = (IDictionary<string, object>)row;
                var values = dict.Values.ToList();

                if (values.Count >= 2)
                {
                    items.Add(new LookupItem
                    {
                        Key = values[0]?.ToString() ?? string.Empty,
                        Value = values[1]?.ToString() ?? string.Empty
                    });
                }
                else if (values.Count == 1)
                {
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
    /// Executa uma query SQL_CAMP e retorna todos os dados completos de cada registro.
    /// Usado para lookups que precisam preencher campos IE associados.
    /// Similar ao comportamento do TDBLookNume no Delphi que mantém todos os campos do registro.
    /// </summary>
    public async Task<LookupQueryResult> ExecuteLookupQueryFullAsync(string sql)
    {
        var result = new LookupQueryResult();

        if (string.IsNullOrWhiteSpace(sql))
        {
            return result;
        }

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var queryResults = await connection.QueryAsync(sql);

            foreach (var row in queryResults)
            {
                var dict = (IDictionary<string, object>)row;
                var record = new LookupRecord();

                // Guarda os nomes das colunas na primeira iteração
                if (result.Columns.Count == 0)
                {
                    result.Columns.AddRange(dict.Keys.Select(k => k.ToUpper()));
                }

                // Preenche Key e Value (colunas 0 e 1)
                var values = dict.Values.ToList();
                if (values.Count >= 1)
                {
                    record.Key = values[0]?.ToString() ?? string.Empty;
                }
                if (values.Count >= 2)
                {
                    record.Value = values[1]?.ToString() ?? string.Empty;
                }
                else
                {
                    record.Value = record.Key;
                }

                // Armazena TODOS os valores do registro por nome de coluna (uppercase)
                foreach (var kvp in dict)
                {
                    record.Data[kvp.Key.ToUpper()] = kvp.Value?.ToString() ?? string.Empty;
                }

                result.Records.Add(record);
            }

            _logger.LogDebug("Lookup Full executado: {Count} registros, {ColCount} colunas",
                result.Records.Count, result.Columns.Count);
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Erro ao executar lookup SQL Full: {Sql}", sql.Substring(0, Math.Min(100, sql.Length)));
            return result;
        }
    }
}

/// <summary>
/// Resultado completo de uma query de lookup.
/// Contém todos os registros com todos os campos.
/// </summary>
public class LookupQueryResult
{
    /// <summary>
    /// Nomes das colunas retornadas (uppercase)
    /// </summary>
    public List<string> Columns { get; set; } = new();

    /// <summary>
    /// Lista de registros completos
    /// </summary>
    public List<LookupRecord> Records { get; set; } = new();
}

/// <summary>
/// Um registro completo do lookup.
/// Contém Key/Value para exibição e Data com todos os campos para campos IE.
/// </summary>
public class LookupRecord
{
    /// <summary>
    /// Chave primária (primeira coluna do SQL_CAMP)
    /// </summary>
    public string Key { get; set; } = string.Empty;

    /// <summary>
    /// Valor de exibição (segunda coluna do SQL_CAMP)
    /// </summary>
    public string Value { get; set; } = string.Empty;

    /// <summary>
    /// Todos os dados do registro indexados por nome de coluna (uppercase)
    /// Ex: Data["NOMEPROD"] = "Produto XYZ"
    /// </summary>
    public Dictionary<string, string> Data { get; set; } = new();
}
