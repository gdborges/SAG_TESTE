using Dapper;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;
using System.Data;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço de consultas e CRUD usando Dapper.
/// Suporta SQL Server e Oracle via IDbProvider.
/// </summary>
public class ConsultaService : IConsultaService
{
    private readonly IDbProvider _dbProvider;
    private readonly ILogger<ConsultaService> _logger;

    public ConsultaService(IDbProvider dbProvider, ILogger<ConsultaService> logger)
    {
        _dbProvider = dbProvider;
        _logger = logger;
        _logger.LogInformation("ConsultaService inicializado com provider {Provider}", _dbProvider.ProviderName);
    }

    /// <summary>
    /// Obtém o nome real da coluna de chave primária (primeira coluna da tabela).
    /// No SAG, a convenção é que a primeira coluna é sempre a PK (CODI + sufixo da tabela).
    /// </summary>
    private async Task<string> GetPrimaryKeyColumnAsync(IDbConnection connection, string tableName)
    {
        var sql = _dbProvider.GetFirstColumnQuery(tableName);
        var pkColumn = await connection.QueryFirstOrDefaultAsync<string>(
            sql,
            new { TableName = tableName.ToUpper() });  // Oracle é case-sensitive em metadados
        return pkColumn ?? $"CODI{tableName.Replace("POCA", "").Replace("POGE", "")}"; // Fallback
    }

    /// <summary>
    /// Verifica se uma coluna é IDENTITY (auto-increment).
    /// Retorna false no Oracle (não suporta IDENTITY em 11g).
    /// </summary>
    private async Task<bool> IsIdentityColumnAsync(IDbConnection connection, string tableName, string columnName)
    {
        if (!_dbProvider.SupportsIdentity)
            return false;

        var sql = _dbProvider.GetIdentityCheckQuery(tableName, columnName);
        var result = await connection.QueryFirstOrDefaultAsync<int?>(
            sql,
            new { TableName = tableName, ColumnName = columnName });
        return result == 1;
    }

    /// <summary>
    /// Estratégia de geração de Primary Key.
    /// </summary>
    public enum PkStrategy
    {
        /// <summary>Banco gera via IDENTITY, usar SCOPE_IDENTITY()</summary>
        Identity,
        /// <summary>Aplicação gera via MAX()+1 (SQL Server) ou SEQUENCE (Oracle)</summary>
        MaxPlusOneOrSequence,
        /// <summary>Valor já fornecido pelo usuário/frontend</summary>
        UserProvided
    }

    /// <summary>
    /// Determina a estratégia de geração de PK para INSERT.
    /// Encapsula a lógica de decisão baseada em metadados da tabela e valor fornecido.
    /// </summary>
    private async Task<(PkStrategy Strategy, bool NeedsNewId)> GetPkStrategyAsync(
        IDbConnection connection,
        string tableName,
        string pkColumn,
        object? providedPkValue)
    {
        // Verifica se a coluna é IDENTITY (só SQL Server)
        var isIdentity = await IsIdentityColumnAsync(connection, tableName, pkColumn);

        if (isIdentity)
        {
            return (PkStrategy.Identity, false);
        }

        // Tabela não-IDENTITY: verifica se valor foi fornecido
        var needsNewId = providedPkValue == null
            || providedPkValue.ToString() == "0"
            || providedPkValue.ToString() == ""
            || (providedPkValue is int intVal && intVal == 0)
            || (providedPkValue is long longVal && longVal == 0);

        if (needsNewId)
        {
            return (PkStrategy.MaxPlusOneOrSequence, true);
        }

        return (PkStrategy.UserProvided, false);
    }

    /// <summary>
    /// Converte um valor object (que pode ser JsonElement) para tipo primitivo.
    /// </summary>
    private static object? ConvertJsonElementToValue(object? value)
    {
        if (value == null) return null;

        if (value is int or long or short or decimal or double or float or bool)
        {
            return value;
        }

        if (value is JsonElement jsonElement)
        {
            return jsonElement.ValueKind switch
            {
                JsonValueKind.String => ConvertStringValue(jsonElement.GetString()),
                JsonValueKind.Number => jsonElement.TryGetInt32(out var intVal) ? intVal : jsonElement.GetDecimal(),
                JsonValueKind.True => 1,
                JsonValueKind.False => 0,
                JsonValueKind.Null => null,
                _ => jsonElement.ToString()
            };
        }

        return ConvertStringValue(value?.ToString());
    }

    /// <summary>
    /// Converte valores string especiais (checkbox "on", etc.) para valores do banco.
    /// </summary>
    private static object? ConvertStringValue(string? value)
    {
        if (value == null) return null;

        if (value.Equals("on", StringComparison.OrdinalIgnoreCase)) return 1;
        if (value.Equals("true", StringComparison.OrdinalIgnoreCase)) return 1;
        if (value.Equals("false", StringComparison.OrdinalIgnoreCase)) return 0;
        if (string.IsNullOrWhiteSpace(value)) return null;

        return value;
    }

    /// <inheritdoc/>
    public async Task<TableMetadata?> GetTableMetadataAsync(int tableId)
    {
        // SQL com funções abstraídas via provider
        var sql = $@"
            SELECT
                CODITABE as CodiTabe,
                {_dbProvider.NullFunction("NOMETABE", "''")} as NomeTabe,
                {_dbProvider.NullFunction("FORMTABE", "''")} as FormTabe,
                {_dbProvider.NullFunction("CAPTTABE", "''")} as CaptTabe,
                {_dbProvider.NullFunction("HINTTABE", "''")} as HintTabe,
                {_dbProvider.NullFunction("GRAVTABE", "''")} as GravTabe,
                {_dbProvider.NullFunction("CHAVTABE", "1")} as ChavTabe,
                {_dbProvider.NullFunction("GUI1TABE", "''")} as Gui1Tabe,
                {_dbProvider.NullFunction("GUI2TABE", "''")} as Gui2Tabe,
                PARATABE as ParaTabe,
                GRIDTABE as GridTabe,
                {_dbProvider.NullFunction("ALTUTABE", "400")} as AltuTabe,
                {_dbProvider.NullFunction("TAMATABE", "600")} as TamaTabe,
                {_dbProvider.NullFunction("SIGLTABE", "''")} as SiglTabe
            FROM SISTTABE
            WHERE CODITABE = {_dbProvider.FormatParameter("TableId")}";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            return await connection.QueryFirstOrDefaultAsync<TableMetadata>(sql, new { TableId = tableId });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter metadados da tabela {TableId}", tableId);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<List<ConsultaMetadata>> GetConsultasByTableAsync(int tableId)
    {
        var sql = $@"
            SELECT
                CODICONS as CodiCons,
                CODITABE as CodiTabe,
                {_dbProvider.NullFunction("NOMECONS", "''")} as NomeCons,
                {_dbProvider.NullFunction("BUSCCONS", "''")} as BuscCons,
                SQL_CONS as SqlCons,
                FILTCONS as FiltCons,
                WHERCONS as WherCons,
                ORBYCONS as OrByCons,
                {_dbProvider.NullFunction("ACCECONS", "1")} as AcceCons,
                {_dbProvider.NullFunction("ATIVCONS", "1")} as AtivCons
            FROM SISTCONS
            WHERE CODITABE = {_dbProvider.FormatParameter("TableId")}
              AND {_dbProvider.NullFunction("ATIVCONS", "1")} = 1
            ORDER BY NOMECONS";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            var consultas = await connection.QueryAsync<ConsultaMetadata>(sql, new { TableId = tableId });
            return consultas.ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter consultas da tabela {TableId}", tableId);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<ConsultaMetadata?> GetConsultaAsync(int consultaId)
    {
        var sql = $@"
            SELECT
                CODICONS as CodiCons,
                CODITABE as CodiTabe,
                {_dbProvider.NullFunction("NOMECONS", "''")} as NomeCons,
                {_dbProvider.NullFunction("BUSCCONS", "''")} as BuscCons,
                SQL_CONS as SqlCons,
                FILTCONS as FiltCons,
                WHERCONS as WherCons,
                ORBYCONS as OrByCons,
                {_dbProvider.NullFunction("ACCECONS", "1")} as AcceCons,
                {_dbProvider.NullFunction("ATIVCONS", "1")} as AtivCons
            FROM SISTCONS
            WHERE CODICONS = {_dbProvider.FormatParameter("ConsultaId")}";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            return await connection.QueryFirstOrDefaultAsync<ConsultaMetadata>(sql, new { ConsultaId = consultaId });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter consulta {ConsultaId}", consultaId);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<GridDataResponse> ExecuteConsultaAsync(GridFilterRequest request)
    {
        var consulta = await GetConsultaAsync(request.ConsultaId);
        if (consulta == null)
        {
            return new GridDataResponse
            {
                Data = new List<Dictionary<string, object?>>(),
                TotalRecords = 0,
                TotalPages = 0,
                CurrentPage = 1,
                PageSize = request.PageSize
            };
        }

        var (baseSql, extractedOrderBy) = PrepareBaseSql(consulta.SqlCons ?? "");
        var (filterSql, parameters) = BuildFilterClause(request.Filters);
        var filteredSql = ApplyFiltersToSql(baseSql, filterSql);

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            // Count total
            var countSql = $"SELECT COUNT(*) FROM ({filteredSql}) CountQuery";
            var totalRecords = await connection.ExecuteScalarAsync<int>(countSql, parameters);

            var totalPages = (int)Math.Ceiling((double)totalRecords / request.PageSize);
            var offset = (request.Page - 1) * request.PageSize;

            var hasFilters = request.Filters.Any(f => !string.IsNullOrEmpty(f.Field) && !string.IsNullOrEmpty(f.Value));
            var orderByClause = hasFilters && string.IsNullOrEmpty(request.SortField)
                ? "(SELECT NULL)"
                : GetOrderByClause(request, consulta, hasFilters ? null : extractedOrderBy);

            // Paginação com sintaxe do provider
            var pagedSql = $@"
                {filteredSql}
                ORDER BY {orderByClause}
                {_dbProvider.GetPaginationClause(offset, request.PageSize)}";

            var data = await connection.QueryAsync(pagedSql, parameters);

            var dataList = data.Select(row =>
            {
                var dict = new Dictionary<string, object?>();
                foreach (var prop in (IDictionary<string, object>)row)
                {
                    dict[prop.Key] = prop.Value;
                }
                return dict;
            }).ToList();

            var columns = consulta.GetColumns();
            if (columns.Count == 0 && dataList.Count > 0)
            {
                columns = dataList[0].Keys.Select(key => new GridColumn
                {
                    FieldName = key,
                    DisplayName = key,
                    Width = 100
                }).ToList();
            }

            return new GridDataResponse
            {
                Data = dataList,
                TotalRecords = totalRecords,
                TotalPages = totalPages,
                CurrentPage = request.Page,
                PageSize = request.PageSize,
                Columns = columns
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar consulta {ConsultaId}", request.ConsultaId);
            throw;
        }
    }

    private (string baseSql, string? orderByClause) PrepareBaseSql(string sql)
    {
        string? orderByClause = null;

        var orderByIndex = sql.LastIndexOf("ORDER BY", StringComparison.OrdinalIgnoreCase);
        if (orderByIndex > 0)
        {
            orderByClause = sql.Substring(orderByIndex + 8).Trim();
            sql = sql.Substring(0, orderByIndex).Trim();
        }

        // Substitui FUN_LOGI por CASE (funciona em ambos os bancos)
        sql = Regex.Replace(sql, @"(?:DBO\.)?FUN_LOGI\(([^)]+)\)",
            "CASE $1 WHEN 1 THEN 'S' ELSE 'N' END",
            RegexOptions.IgnoreCase);

        return (sql, orderByClause);
    }

    private (string sql, DynamicParameters parameters) BuildFilterClause(List<GridFilter> filters)
    {
        if (!filters.Any())
            return ("", new DynamicParameters());

        var conditions = new StringBuilder();
        var parameters = new DynamicParameters();
        int paramIndex = 0;

        foreach (var filter in filters)
        {
            if (string.IsNullOrEmpty(filter.Field) || string.IsNullOrEmpty(filter.Value))
                continue;

            var paramName = $"filter{paramIndex++}";
            var formattedParam = _dbProvider.FormatParameter(paramName);
            var fieldName = SanitizeFieldName(filter.Field);
            var quotedField = _dbProvider.QuoteIdentifier(fieldName);

            // Oracle usa || para concat, SQL Server usa +
            var concatOp = _dbProvider.ProviderName == "Oracle" ? "||" : "+";

            var condition = filter.Condition.ToLower() switch
            {
                "startswith" => $"{quotedField} LIKE {formattedParam} {concatOp} '%'",
                "contains" => $"{quotedField} LIKE '%' {concatOp} {formattedParam} {concatOp} '%'",
                "equals" => $"{quotedField} = {formattedParam}",
                "notequals" => $"{quotedField} <> {formattedParam}",
                _ => $"{quotedField} LIKE '%' {concatOp} {formattedParam} {concatOp} '%'"
            };

            if (conditions.Length > 0)
                conditions.Append(" AND ");

            conditions.Append(condition);
            parameters.Add(paramName, filter.Value);
        }

        return (conditions.ToString(), parameters);
    }

    private string SanitizeFieldName(string fieldName)
    {
        return Regex.Replace(fieldName, @"[^\p{L}\p{N}\s_]", "");
    }

    private string ApplyFiltersToSql(string baseSql, string filterClause)
    {
        if (string.IsNullOrEmpty(filterClause))
            return baseSql;

        return $"SELECT * FROM ({baseSql}) BaseQuery WHERE {filterClause}";
    }

    private string GetOrderByClause(GridFilterRequest request, ConsultaMetadata consulta, string? extractedOrderBy = null)
    {
        if (!string.IsNullOrEmpty(request.SortField))
        {
            var direction = request.SortDirection?.ToUpper() == "DESC" ? "DESC" : "ASC";
            var quotedField = _dbProvider.QuoteIdentifier(SanitizeFieldName(request.SortField));
            return $"{quotedField} {direction}";
        }

        if (!string.IsNullOrEmpty(extractedOrderBy))
        {
            return extractedOrderBy;
        }

        return "(SELECT NULL)";
    }

    /// <inheritdoc/>
    public async Task<Dictionary<string, object?>?> GetRecordByIdAsync(int tableId, int recordId)
    {
        var table = await GetTableMetadataAsync(tableId);
        if (table == null || string.IsNullOrEmpty(table.GravTabe))
            return null;

        var tableName = table.GravTabe;

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var pkColumn = await GetPrimaryKeyColumnAsync(connection, tableName);
            var quotedTable = _dbProvider.QuoteIdentifier(tableName);
            var quotedPk = _dbProvider.QuoteIdentifier(pkColumn);
            var param = _dbProvider.FormatParameter("RecordId");

            var sql = $"SELECT * FROM {quotedTable} WHERE {quotedPk} = {param}";
            var result = await connection.QueryFirstOrDefaultAsync(sql, new { RecordId = recordId });

            if (result == null)
                return null;

            var dict = new Dictionary<string, object?>();
            foreach (var prop in (IDictionary<string, object>)result)
            {
                dict[prop.Key] = prop.Value;
            }
            return dict;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter registro {RecordId} da tabela {TableId}", recordId, tableId);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<SaveRecordResponse> SaveRecordAsync(SaveRecordRequest request)
    {
        var table = await GetTableMetadataAsync(request.TableId);
        if (table == null || string.IsNullOrEmpty(table.GravTabe))
        {
            return new SaveRecordResponse
            {
                Success = false,
                Message = "Tabela não encontrada"
            };
        }

        var tableName = table.GravTabe;

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var pkColumn = await GetPrimaryKeyColumnAsync(connection, tableName);

            // Obtém colunas válidas da tabela
            var validColumnsSql = _dbProvider.GetColumnsMetadataQuery(tableName);
            var columnsResult = await connection.QueryAsync<dynamic>(validColumnsSql, new { TableName = tableName.ToUpper() });
            var validColumns = columnsResult
                .Select(c => ((string)c.COLUMN_NAME).ToUpperInvariant())
                .ToHashSet();

            var filteredFields = request.Fields
                .Where(f => validColumns.Contains(f.Key.ToUpperInvariant()))
                .ToDictionary(f => f.Key, f => f.Value);

            if (request.IsNew)
            {
                var pkKey = filteredFields.Keys.FirstOrDefault(k => k.Equals(pkColumn, StringComparison.OrdinalIgnoreCase));
                var providedPkValue = pkKey != null ? ConvertJsonElementToValue(filteredFields[pkKey]) : null;

                var (strategy, needsNewId) = await GetPkStrategyAsync(connection, tableName, pkColumn, providedPkValue);
                _logger.LogInformation("Tabela {TableName}: estratégia PK = {Strategy}, needsNewId = {NeedsNewId}",
                    tableName, strategy, needsNewId);

                using var transaction = connection.BeginTransaction();
                try
                {
                    int? generatedPkValue = null;

                    switch (strategy)
                    {
                        case PkStrategy.Identity:
                            filteredFields.Remove(pkColumn);
                            break;

                        case PkStrategy.MaxPlusOneOrSequence:
                            if (pkKey != null) filteredFields.Remove(pkKey);
                            // Usa provider para gerar próximo ID (MAX+1 ou SEQUENCE)
                            generatedPkValue = await _dbProvider.GetNextIdAsync(
                                connection, tableName, pkColumn, false, transaction);
                            _logger.LogInformation("Gerado próximo ID {NextId} para tabela {TableName}",
                                generatedPkValue, tableName);
                            break;

                        case PkStrategy.UserProvided:
                            break;
                    }

                    var columns = filteredFields.Keys.ToList();
                    var parameters = new DynamicParameters();

                    foreach (var field in filteredFields)
                    {
                        var convertedValue = ConvertJsonElementToValue(field.Value);
                        parameters.Add(field.Key, convertedValue);
                    }

                    if (strategy == PkStrategy.MaxPlusOneOrSequence && generatedPkValue.HasValue)
                    {
                        columns.Add(pkColumn);
                        parameters.Add(pkColumn, generatedPkValue.Value);
                    }

                    // Monta INSERT com sintaxe do provider
                    var quotedTable = _dbProvider.QuoteIdentifier(tableName);
                    var columnList = string.Join(", ", columns.Select(c => _dbProvider.QuoteIdentifier(c)));
                    var valueList = string.Join(", ", columns.Select(c => _dbProvider.FormatParameter(c)));

                    var sql = $"INSERT INTO {quotedTable} ({columnList}) VALUES ({valueList})";

                    int newId;
                    if (strategy == PkStrategy.Identity)
                    {
                        // SQL Server: executa e obtém SCOPE_IDENTITY()
                        await connection.ExecuteAsync(sql, parameters, transaction: transaction);
                        newId = await _dbProvider.GetLastInsertedIdAsync(connection, transaction);
                        _logger.LogInformation("IDENTITY gerou ID {NewId} para tabela {TableName}", newId, tableName);
                    }
                    else
                    {
                        await connection.ExecuteAsync(sql, parameters, transaction: transaction);
                        newId = generatedPkValue ?? (int)(providedPkValue ?? 0);
                    }

                    transaction.Commit();

                    return new SaveRecordResponse
                    {
                        Success = true,
                        Message = "Registro inserido com sucesso",
                        RecordId = newId
                    };
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
            else
            {
                // UPDATE
                var setClauses = filteredFields.Keys
                    .Where(k => !k.Equals(pkColumn, StringComparison.OrdinalIgnoreCase))
                    .Select(k => $"{_dbProvider.QuoteIdentifier(k)} = {_dbProvider.FormatParameter(k)}");

                var quotedTable = _dbProvider.QuoteIdentifier(tableName);
                var quotedPk = _dbProvider.QuoteIdentifier(pkColumn);
                var sql = $@"
                    UPDATE {quotedTable}
                    SET {string.Join(", ", setClauses)}
                    WHERE {quotedPk} = {_dbProvider.FormatParameter("RecordId")}";

                var parameters = new DynamicParameters();
                parameters.Add("RecordId", request.RecordId);
                foreach (var field in filteredFields)
                {
                    parameters.Add(field.Key, ConvertJsonElementToValue(field.Value));
                }

                var affected = await connection.ExecuteAsync(sql, parameters);

                if (affected == 0)
                {
                    return new SaveRecordResponse
                    {
                        Success = false,
                        Message = $"Registro {request.RecordId} não encontrado na tabela {tableName}"
                    };
                }

                return new SaveRecordResponse
                {
                    Success = true,
                    Message = "Registro atualizado com sucesso",
                    RecordId = request.RecordId
                };
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao salvar registro na tabela {TableId}", request.TableId);
            return new SaveRecordResponse
            {
                Success = false,
                Message = $"Erro ao salvar: {ex.Message}"
            };
        }
    }

    /// <inheritdoc/>
    public async Task<SaveRecordResponse> DeleteRecordAsync(int tableId, int recordId)
    {
        var table = await GetTableMetadataAsync(tableId);
        if (table == null || string.IsNullOrEmpty(table.GravTabe))
        {
            return new SaveRecordResponse
            {
                Success = false,
                Message = "Tabela não encontrada"
            };
        }

        var tableName = table.GravTabe;

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var pkColumn = await GetPrimaryKeyColumnAsync(connection, tableName);
            var quotedTable = _dbProvider.QuoteIdentifier(tableName);
            var quotedPk = _dbProvider.QuoteIdentifier(pkColumn);
            var param = _dbProvider.FormatParameter("RecordId");

            var sql = $"DELETE FROM {quotedTable} WHERE {quotedPk} = {param}";
            var affected = await connection.ExecuteAsync(sql, new { RecordId = recordId });

            return new SaveRecordResponse
            {
                Success = affected > 0,
                Message = affected > 0 ? "Registro excluído com sucesso" : "Registro não encontrado"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao excluir registro {RecordId} da tabela {TableId}", recordId, tableId);
            return new SaveRecordResponse
            {
                Success = false,
                Message = $"Erro ao excluir: {ex.Message}"
            };
        }
    }
}
