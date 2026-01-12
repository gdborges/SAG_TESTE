using Dapper;
using System.Data;
using System.Security;
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
            // Remove placeholders '= 0' que são usados pelo Delphi para filtros dinâmicos
            sql = RemoveSqlPlaceholders(sql);

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

    /// <inheritdoc/>
    public async Task<LookupRecord?> LookupByCodeAsync(string sql, string code)
    {
        if (string.IsNullOrWhiteSpace(sql) || string.IsNullOrWhiteSpace(code))
        {
            return null;
        }

        try
        {
            // Modifica a SQL para filtrar pelo código
            // A primeira coluna é sempre o código (Key)
            var filteredSql = WrapSqlWithCodeFilter(sql, code);

            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var queryResults = await connection.QueryAsync(filteredSql);
            var firstRow = queryResults.FirstOrDefault();

            if (firstRow == null)
            {
                _logger.LogDebug("LookupByCode: código '{Code}' não encontrado", code);
                return null;
            }

            var dict = (IDictionary<string, object>)firstRow;
            var record = new LookupRecord();

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

            _logger.LogDebug("LookupByCode: código '{Code}' encontrado, descrição: '{Value}'", code, record.Value);
            return record;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Erro ao executar LookupByCode: {Code}", code);
            return null;
        }
    }

    /// <summary>
    /// Envolve a SQL original em uma subquery para filtrar pelo código.
    /// Funciona para SQL Server e Oracle.
    /// </summary>
    private string WrapSqlWithCodeFilter(string sql, string code)
    {
        // Remove ponto-e-vírgula final se existir
        sql = sql.TrimEnd().TrimEnd(';');

        // Escapa aspas simples no código para evitar SQL injection
        var safeCode = code.Replace("'", "''");

        // Tenta detectar se o código é numérico
        var isNumeric = decimal.TryParse(code, out _);

        // Nome da primeira coluna precisa ser determinado dinamicamente
        // Usamos a subquery approach que funciona em ambos os bancos
        // IMPORTANTE: Oracle retorna colunas em UPPERCASE a menos que sejam quoted
        var firstCol = GetFirstColumnAlias(sql).ToUpper();

        if (_dbProvider.ProviderName == "Oracle")
        {
            // Oracle: usa ROWNUM para limitar
            // Não usa aspas duplas para que seja case-insensitive
            if (isNumeric)
            {
                return $@"SELECT * FROM ({sql}) lookup_sub
                          WHERE lookup_sub.{firstCol} = {safeCode}
                          AND ROWNUM = 1";
            }
            else
            {
                return $@"SELECT * FROM ({sql}) lookup_sub
                          WHERE UPPER(TO_CHAR(lookup_sub.{firstCol})) = UPPER('{safeCode}')
                          AND ROWNUM = 1";
            }
        }
        else
        {
            // SQL Server: usa TOP 1
            if (isNumeric)
            {
                return $@"SELECT TOP 1 * FROM ({sql}) AS lookup_sub
                          WHERE lookup_sub.[{GetFirstColumnAlias(sql)}] = {safeCode}";
            }
            else
            {
                return $@"SELECT TOP 1 * FROM ({sql}) AS lookup_sub
                          WHERE UPPER(CAST(lookup_sub.[{GetFirstColumnAlias(sql)}] AS VARCHAR(MAX))) = UPPER('{safeCode}')";
            }
        }
    }

    /// <summary>
    /// Remove placeholders '= 0' que o Delphi usa para filtros dinâmicos.
    /// No Delphi, essas condições são substituídas em runtime, mas na Web precisamos removê-las
    /// para carregar todas as opções do lookup.
    /// </summary>
    private string RemoveSqlPlaceholders(string sql)
    {
        if (string.IsNullOrWhiteSpace(sql))
            return sql;

        var original = sql;

        // Remove AND seguido de condição = 0 (com ou sem parênteses, com ou sem prefixo de tabela)
        // Exemplos: AND (CODIPROD = 0), AND POCAPROD.CODIPROD = 0, AND (POCAPROD.CODIPROD = 0)
        sql = System.Text.RegularExpressions.Regex.Replace(
            sql,
            @"\s+AND\s+\(?\s*[\w\.]+\s*=\s*0\s*\)?(?=\s|\r|\n|$)",
            "",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase | System.Text.RegularExpressions.RegexOptions.Multiline);

        // Remove WHERE (campo = 0) sem outras condições antes de ORDER BY ou fim
        // Exemplo: WHERE ATIVPROD = 1 AND CODIPROD = 0 ORDER BY -> WHERE ATIVPROD = 1 ORDER BY
        // Já foi removido pelo padrão anterior

        // Se sobrou apenas WHERE antes de ORDER BY ou quebra de linha, remove WHERE também
        sql = System.Text.RegularExpressions.Regex.Replace(
            sql,
            @"\s+WHERE\s+(?=ORDER\s+BY|\r|\n|$)",
            " ",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase | System.Text.RegularExpressions.RegexOptions.Multiline);

        // Remove múltiplos espaços e quebras de linha em branco
        sql = System.Text.RegularExpressions.Regex.Replace(sql, @"[\r\n]+\s*[\r\n]+", "\r\n");
        sql = System.Text.RegularExpressions.Regex.Replace(sql, @"[ \t]+", " ");

        if (sql.Trim() != original.Trim())
        {
            _logger.LogInformation("SQL Placeholders removidos:\nOriginal: {Original}\nResultado: {Result}",
                original.Substring(0, Math.Min(200, original.Length)),
                sql.Substring(0, Math.Min(200, sql.Length)));
        }

        return sql.Trim();
    }

    /// <inheritdoc/>
    public async Task<List<LookupItem>> ExecuteDynamicLookupAsync(
        string[] sqlLines,
        string condition,
        Dictionary<string, object> parameters)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        try
        {
            // 1. Validar condição via SqlSecurityValidator
            if (!SqlSecurityValidator.ValidateDynamicSqlCondition(condition))
            {
                var reason = SqlSecurityValidator.GetRejectionReason(condition);
                _logger.LogWarning("Condição SQL rejeitada por validação de segurança: {Reason}. Condição: {Condition}",
                    reason, condition);
                throw new SecurityException($"Condição SQL rejeitada: {reason}");
            }

            // 2. Copiar array para não modificar original
            var modifiedLines = (string[])sqlLines.Clone();

            // 3. Substituir placeholders em TODAS as linhas
            for (int i = 0; i < modifiedLines.Length; i++)
            {
                modifiedLines[i] = SubstituirPlaceholders(modifiedLines[i], parameters);
            }

            // 4. Injetar condição na linha 4 (índice 4) se não for ABRE
            if (!condition.Trim().Equals("ABRE", StringComparison.OrdinalIgnoreCase))
            {
                // Substitui placeholders na condição também
                var conditionSubstituida = SubstituirPlaceholders(condition, parameters);

                // Garante que temos pelo menos 5 linhas
                if (modifiedLines.Length > 4)
                {
                    modifiedLines[4] = conditionSubstituida;
                }
                else
                {
                    // Se SQL tem menos de 5 linhas, adiciona a condição ao final
                    var linesList = modifiedLines.ToList();
                    while (linesList.Count < 4) linesList.Add("");
                    linesList.Add(conditionSubstituida);
                    modifiedLines = linesList.ToArray();
                }
            }

            // 5. Montar SQL final
            var sqlFinal = string.Join("\n", modifiedLines);

            // 6. Remover placeholders restantes (= 0) que desabilitam a query
            sqlFinal = RemoveSqlPlaceholders(sqlFinal);

            // 7. Logar para auditoria
            _logger.LogWarning("Lookup dinâmico executado: SQL={Sql}, Parâmetros={Params}",
                sqlFinal.Length > 200 ? sqlFinal.Substring(0, 200) + "..." : sqlFinal,
                System.Text.Json.JsonSerializer.Serialize(parameters));

            // 8. Executar query
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var results = await connection.QueryAsync(sqlFinal);
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

            stopwatch.Stop();
            _logger.LogInformation("Lookup dinâmico: {Count} itens em {Ms}ms", items.Count, stopwatch.ElapsedMilliseconds);

            return items;
        }
        catch (SecurityException)
        {
            throw; // Re-throw security exceptions
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, "Erro ao executar lookup dinâmico em {Ms}ms", stopwatch.ElapsedMilliseconds);
            throw;
        }
    }

    /// <summary>
    /// Substitui placeholders {DG-CAMPO}, {IT-CAMPO}, etc. com valores dos parâmetros.
    /// </summary>
    private string SubstituirPlaceholders(string text, Dictionary<string, object> parameters)
    {
        if (string.IsNullOrEmpty(text) || parameters == null || parameters.Count == 0)
            return text;

        var result = text;

        foreach (var param in parameters)
        {
            var placeholder = $"{{{param.Key}}}";
            var value = param.Value?.ToString() ?? "NULL";

            // Sanitizar valor para prevenir SQL injection
            value = SqlSecurityValidator.SanitizeValue(value);

            result = result.Replace(placeholder, value, StringComparison.OrdinalIgnoreCase);
        }

        return result;
    }

    /// <summary>
    /// Extrai o alias/nome da primeira coluna do SELECT.
    /// </summary>
    private string GetFirstColumnAlias(string sql)
    {
        // Procura o primeiro SELECT e extrai a primeira coluna
        var selectMatch = System.Text.RegularExpressions.Regex.Match(
            sql,
            @"SELECT\s+(?:TOP\s+\d+\s+)?(?:DISTINCT\s+)?(\w+(?:\.\w+)?(?:\s+AS\s+(\w+))?)",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase);

        if (selectMatch.Success)
        {
            // Se tem alias (AS xxx), usa o alias
            if (selectMatch.Groups[2].Success && !string.IsNullOrWhiteSpace(selectMatch.Groups[2].Value))
            {
                return selectMatch.Groups[2].Value;
            }
            // Senão usa o nome da coluna (pode ser tabela.coluna)
            var col = selectMatch.Groups[1].Value;
            if (col.Contains('.'))
            {
                col = col.Split('.').Last();
            }
            return col;
        }

        // Fallback: assume primeira coluna padrão
        return "CODICAMPO";
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
