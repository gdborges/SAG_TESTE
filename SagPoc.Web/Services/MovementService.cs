using Dapper;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço de operações CRUD em tabelas de movimento.
/// </summary>
public class MovementService : IMovementService
{
    private readonly IDbProvider _dbProvider;
    private readonly IMetadataService _metadataService;
    private readonly ILogger<MovementService> _logger;

    public MovementService(
        IDbProvider dbProvider,
        IMetadataService metadataService,
        ILogger<MovementService> logger)
    {
        _dbProvider = dbProvider;
        _metadataService = metadataService;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<MovementGridData> GetMovementDataAsync(int parentId, int movementTableId, int page = 1, int pageSize = 50)
    {
        var metadata = await GetMovementMetadataAsync(movementTableId);
        if (metadata == null)
        {
            _logger.LogWarning("Movimento {MovementTableId} não encontrado", movementTableId);
            return new MovementGridData();
        }

        var result = new MovementGridData
        {
            CurrentPage = page,
            PageSize = pageSize,
            PkColumnName = metadata.PkColumnName,
            Columns = metadata.GetGridColumns()
        };

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            // Obtém nome da FK (coluna que referencia o pai)
            var fkColumnName = await GetForeignKeyColumnAsync(metadata);

            // Qualifica FK com nome da tabela para evitar ambiguidade em JOINs
            var qualifiedFk = $"{metadata.GravTabe}.{fkColumnName}";

            // Monta SQL do grid (já sem ORDER BY)
            var gridSql = GetGridSql(metadata, fkColumnName);
            var param = _dbProvider.FormatParameter("ParentId");

            // Verifica se já existe WHERE no SQL (pode ter newlines antes)
            var hasWhere = Regex.IsMatch(gridSql, @"\bWHERE\b", RegexOptions.IgnoreCase);
            var whereClause = hasWhere ? $" AND {qualifiedFk} = {param}" : $" WHERE {qualifiedFk} = {param}";

            // Count total - usa subquery para evitar problemas
            var countSql = $"SELECT COUNT(*) FROM ({gridSql}{whereClause}) CountQuery";
            _logger.LogWarning("Grid SQL: {GridSql}", gridSql);
            _logger.LogWarning("Where Clause: {WhereClause}", whereClause);
            _logger.LogWarning("Count SQL: {CountSql}", countSql);
            result.TotalRecords = await connection.ExecuteScalarAsync<int>(countSql, new { ParentId = parentId });
            result.TotalPages = (int)Math.Ceiling((double)result.TotalRecords / pageSize);

            // Query paginada
            var offset = (page - 1) * pageSize;
            var pagedSql = $@"
                {gridSql}
                {whereClause}
                ORDER BY {metadata.PkColumnName}
                {_dbProvider.GetPaginationClause(offset, pageSize)}";

            var data = await connection.QueryAsync(pagedSql, new { ParentId = parentId });

            result.Data = data.Select(row =>
            {
                var dict = new Dictionary<string, object?>();
                foreach (var prop in (IDictionary<string, object>)row)
                {
                    dict[prop.Key] = prop.Value;
                }
                return dict;
            }).ToList();

            // Se não há colunas definidas, extrai do resultado
            if (result.Columns.Count == 0 && result.Data.Count > 0)
            {
                result.Columns = result.Data[0].Keys.Select(k => new GridColumnConfig
                {
                    FieldName = k,
                    DisplayName = k,
                    Width = 100
                }).ToList();
            }

            _logger.LogInformation("Carregados {Count} registros do movimento {MovementId} para pai {ParentId}",
                result.Data.Count, movementTableId, parentId);

            // Calcula totais para campos do cabeçalho (TOQTMVCT, TOVLMVCT, etc.)
            result.Totals = await CalculateMovementTotalsAsync(connection, metadata, fkColumnName, parentId);

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar dados do movimento {MovementId}", movementTableId);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<Dictionary<string, object?>?> GetMovementRecordAsync(int movementTableId, int recordId)
    {
        var metadata = await GetMovementMetadataAsync(movementTableId);
        if (metadata == null) return null;

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var quotedTable = _dbProvider.QuoteIdentifier(metadata.GravTabe);
            var quotedPk = _dbProvider.QuoteIdentifier(metadata.PkColumnName);
            var param = _dbProvider.FormatParameter("RecordId");

            var sql = $"SELECT * FROM {quotedTable} WHERE {quotedPk} = {param}";
            var result = await connection.QueryFirstOrDefaultAsync(sql, new { RecordId = recordId });

            if (result == null) return null;

            var dict = new Dictionary<string, object?>();
            foreach (var prop in (IDictionary<string, object>)result)
            {
                dict[prop.Key] = prop.Value;
            }
            return dict;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter registro {RecordId} do movimento {MovementId}",
                recordId, movementTableId);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<MovementSaveResult> InsertMovementAsync(int movementTableId, int parentId, Dictionary<string, object?> fields)
    {
        var metadata = await GetMovementMetadataAsync(movementTableId);
        if (metadata == null)
        {
            return new MovementSaveResult
            {
                Success = false,
                Message = "Tabela de movimento não encontrada"
            };
        }

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            // Obtém colunas válidas
            var validColumnsSql = _dbProvider.GetColumnsMetadataQuery(metadata.GravTabe);
            var columnsResult = await connection.QueryAsync<dynamic>(validColumnsSql,
                new { TableName = metadata.GravTabe.ToUpper() });
            var validColumns = columnsResult
                .Select(c => ((string)c.COLUMN_NAME).ToUpperInvariant())
                .ToHashSet();

            // Filtra campos válidos
            var filteredFields = fields
                .Where(f => validColumns.Contains(f.Key.ToUpperInvariant()))
                .ToDictionary(f => f.Key, f => ConvertValue(f.Value));

            // Adiciona FK do pai
            var fkColumn = await GetForeignKeyColumnAsync(metadata);
            filteredFields[fkColumn] = parentId;

            // Remove PK se for 0/null (será gerado)
            var pkKey = filteredFields.Keys.FirstOrDefault(k =>
                k.Equals(metadata.PkColumnName, StringComparison.OrdinalIgnoreCase));
            var pkValue = pkKey != null ? filteredFields[pkKey] : null;
            var needsNewId = pkValue == null || pkValue.ToString() == "0" || pkValue.ToString() == "";

            using var transaction = connection.BeginTransaction();
            try
            {
                int newId;

                // Verifica se é IDENTITY
                var isIdentity = await IsIdentityColumnAsync(connection, metadata.GravTabe, metadata.PkColumnName);

                if (isIdentity)
                {
                    // Remove PK, banco gera
                    if (pkKey != null) filteredFields.Remove(pkKey);

                    var columns = filteredFields.Keys.ToList();
                    var columnList = string.Join(", ", columns.Select(c => _dbProvider.QuoteIdentifier(c)));
                    var valueList = string.Join(", ", columns.Select(c => _dbProvider.FormatParameter(c)));

                    var sql = $"INSERT INTO {_dbProvider.QuoteIdentifier(metadata.GravTabe)} ({columnList}) VALUES ({valueList})";

                    var parameters = new DynamicParameters();
                    foreach (var field in filteredFields)
                    {
                        parameters.Add(field.Key, field.Value);
                    }

                    await connection.ExecuteAsync(sql, parameters, transaction: transaction);
                    newId = await _dbProvider.GetLastInsertedIdAsync(connection, transaction);
                }
                else if (needsNewId)
                {
                    // Gera próximo ID
                    if (pkKey != null) filteredFields.Remove(pkKey);

                    newId = await _dbProvider.GetNextIdAsync(connection, metadata.GravTabe,
                        metadata.PkColumnName, false, transaction) ?? 1;

                    filteredFields[metadata.PkColumnName] = newId;

                    var columns = filteredFields.Keys.ToList();
                    var columnList = string.Join(", ", columns.Select(c => _dbProvider.QuoteIdentifier(c)));
                    var valueList = string.Join(", ", columns.Select(c => _dbProvider.FormatParameter(c)));

                    var sql = $"INSERT INTO {_dbProvider.QuoteIdentifier(metadata.GravTabe)} ({columnList}) VALUES ({valueList})";

                    var parameters = new DynamicParameters();
                    foreach (var field in filteredFields)
                    {
                        parameters.Add(field.Key, field.Value);
                    }

                    await connection.ExecuteAsync(sql, parameters, transaction: transaction);
                }
                else
                {
                    // PK fornecido pelo usuário
                    newId = Convert.ToInt32(pkValue);

                    var columns = filteredFields.Keys.ToList();
                    var columnList = string.Join(", ", columns.Select(c => _dbProvider.QuoteIdentifier(c)));
                    var valueList = string.Join(", ", columns.Select(c => _dbProvider.FormatParameter(c)));

                    var sql = $"INSERT INTO {_dbProvider.QuoteIdentifier(metadata.GravTabe)} ({columnList}) VALUES ({valueList})";

                    var parameters = new DynamicParameters();
                    foreach (var field in filteredFields)
                    {
                        parameters.Add(field.Key, field.Value);
                    }

                    await connection.ExecuteAsync(sql, parameters, transaction: transaction);
                }

                transaction.Commit();

                _logger.LogInformation("Inserido registro {RecordId} no movimento {MovementId}",
                    newId, movementTableId);

                return new MovementSaveResult
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
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao inserir no movimento {MovementId}", movementTableId);
            return new MovementSaveResult
            {
                Success = false,
                Message = $"Erro ao inserir: {ex.Message}"
            };
        }
    }

    /// <inheritdoc/>
    public async Task<MovementSaveResult> UpdateMovementAsync(int movementTableId, int recordId, Dictionary<string, object?> fields)
    {
        var metadata = await GetMovementMetadataAsync(movementTableId);
        if (metadata == null)
        {
            return new MovementSaveResult
            {
                Success = false,
                Message = "Tabela de movimento não encontrada"
            };
        }

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            // Obtém colunas válidas
            var validColumnsSql = _dbProvider.GetColumnsMetadataQuery(metadata.GravTabe);
            var columnsResult = await connection.QueryAsync<dynamic>(validColumnsSql,
                new { TableName = metadata.GravTabe.ToUpper() });
            var validColumns = columnsResult
                .Select(c => ((string)c.COLUMN_NAME).ToUpperInvariant())
                .ToHashSet();

            // Filtra campos válidos (exceto PK)
            var filteredFields = fields
                .Where(f => validColumns.Contains(f.Key.ToUpperInvariant()) &&
                           !f.Key.Equals(metadata.PkColumnName, StringComparison.OrdinalIgnoreCase))
                .ToDictionary(f => f.Key, f => ConvertValue(f.Value));

            if (filteredFields.Count == 0)
            {
                return new MovementSaveResult
                {
                    Success = false,
                    Message = "Nenhum campo válido para atualizar"
                };
            }

            var setClauses = filteredFields.Keys
                .Select(k => $"{_dbProvider.QuoteIdentifier(k)} = {_dbProvider.FormatParameter(k)}");

            var sql = $@"
                UPDATE {_dbProvider.QuoteIdentifier(metadata.GravTabe)}
                SET {string.Join(", ", setClauses)}
                WHERE {_dbProvider.QuoteIdentifier(metadata.PkColumnName)} = {_dbProvider.FormatParameter("RecordId")}";

            var parameters = new DynamicParameters();
            parameters.Add("RecordId", recordId);
            foreach (var field in filteredFields)
            {
                parameters.Add(field.Key, field.Value);
            }

            var affected = await connection.ExecuteAsync(sql, parameters);

            if (affected == 0)
            {
                return new MovementSaveResult
                {
                    Success = false,
                    Message = "Registro não encontrado"
                };
            }

            _logger.LogInformation("Atualizado registro {RecordId} no movimento {MovementId}",
                recordId, movementTableId);

            return new MovementSaveResult
            {
                Success = true,
                Message = "Registro atualizado com sucesso",
                RecordId = recordId
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao atualizar registro {RecordId} no movimento {MovementId}",
                recordId, movementTableId);
            return new MovementSaveResult
            {
                Success = false,
                Message = $"Erro ao atualizar: {ex.Message}"
            };
        }
    }

    /// <inheritdoc/>
    public async Task<MovementSaveResult> DeleteMovementAsync(int movementTableId, int recordId)
    {
        var metadata = await GetMovementMetadataAsync(movementTableId);
        if (metadata == null)
        {
            return new MovementSaveResult
            {
                Success = false,
                Message = "Tabela de movimento não encontrada"
            };
        }

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var sql = $@"
                DELETE FROM {_dbProvider.QuoteIdentifier(metadata.GravTabe)}
                WHERE {_dbProvider.QuoteIdentifier(metadata.PkColumnName)} = {_dbProvider.FormatParameter("RecordId")}";

            var affected = await connection.ExecuteAsync(sql, new { RecordId = recordId });

            if (affected == 0)
            {
                return new MovementSaveResult
                {
                    Success = false,
                    Message = "Registro não encontrado"
                };
            }

            _logger.LogInformation("Excluído registro {RecordId} do movimento {MovementId}",
                recordId, movementTableId);

            return new MovementSaveResult
            {
                Success = true,
                Message = "Registro excluído com sucesso",
                RecordId = recordId
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao excluir registro {RecordId} do movimento {MovementId}",
                recordId, movementTableId);
            return new MovementSaveResult
            {
                Success = false,
                Message = $"Erro ao excluir: {ex.Message}"
            };
        }
    }

    /// <inheritdoc/>
    public async Task<MovementMetadata?> GetMovementMetadataAsync(int movementTableId)
    {
        var param = _dbProvider.FormatParameter("CodiTabe");

        // GRIDTABE e GRCOTABE são campos TEXT (tipo legado) - precisam de CAST para Dapper mapear
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
            WHERE CODITABE = {param}";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var metadata = await connection.QueryFirstOrDefaultAsync<MovementMetadata>(sql,
                new { CodiTabe = movementTableId });

            if (metadata != null)
            {
                metadata.GravTabe = metadata.GravTabe?.Trim() ?? string.Empty;
                metadata.SiglTabe = metadata.SiglTabe?.Trim() ?? string.Empty;
                metadata.Gui1Tabe = metadata.Gui1Tabe?.Trim();
            }

            return metadata;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter metadados do movimento {MovementId}", movementTableId);
            return null;
        }
    }

    /// <inheritdoc/>
    public async Task<bool> ValidateMovementTableAsync(int parentTableId, int movementTableId)
    {
        var metadata = await GetMovementMetadataAsync(movementTableId);
        return metadata != null && metadata.CabeTabe == parentTableId;
    }

    /// <summary>
    /// Obtém o nome da coluna FK que referencia o pai.
    /// Convenção SAG: CODI + sufixo do GRAVTABE do pai (ex: POCACONT → CODICONT).
    /// </summary>
    private async Task<string> GetForeignKeyColumnAsync(MovementMetadata movement)
    {
        var parentMetadata = await GetMovementMetadataAsync(movement.CabeTabe);
        if (parentMetadata == null)
        {
            return "CODICAB";
        }

        // Prioridade 1: Extrai sufixo do nome físico da tabela (GRAVTABE)
        // Ex: POCACONT → CONT → CODICONT
        if (!string.IsNullOrWhiteSpace(parentMetadata.GravTabe))
        {
            var suffix = parentMetadata.GravTabe.Trim()
                .Replace("POCA", "", StringComparison.OrdinalIgnoreCase)
                .Replace("POGE", "", StringComparison.OrdinalIgnoreCase)
                .Replace("FPCA", "", StringComparison.OrdinalIgnoreCase)
                .Replace("VDCA", "", StringComparison.OrdinalIgnoreCase)
                .Replace("VDGE", "", StringComparison.OrdinalIgnoreCase);

            if (!string.IsNullOrWhiteSpace(suffix))
            {
                return $"CODI{suffix}";
            }
        }

        // Prioridade 2: Usa SIGLTABE
        if (!string.IsNullOrWhiteSpace(parentMetadata.SiglTabe))
        {
            return $"CODI{parentMetadata.SiglTabe.Trim()}";
        }

        return "CODICAB";
    }

    /// <summary>
    /// Monta SQL do grid baseado no GRIDTABE ou SELECT * da tabela.
    /// </summary>
    private string GetGridSql(MovementMetadata movement, string fkColumn)
    {
        if (!string.IsNullOrEmpty(movement.GridTabe))
        {
            // Remove ORDER BY do GRIDTABE para aplicar nossa ordenação
            var sql = movement.GridTabe;
            var orderByIndex = sql.LastIndexOf("ORDER BY", StringComparison.OrdinalIgnoreCase);
            if (orderByIndex > 0)
            {
                sql = sql.Substring(0, orderByIndex).Trim();
            }

            // Substitui funções Delphi por equivalentes SQL
            sql = Regex.Replace(sql, @"(?:DBO\.)?FUN_LOGI\(([^)]+)\)",
                "CASE $1 WHEN 1 THEN 'S' ELSE 'N' END",
                RegexOptions.IgnoreCase);

            // Adiciona prefixo dbo. às funções SAG que não têm schema (apenas SQL Server)
            // Oracle não usa prefixo dbo, funções ficam no schema do usuário
            if (_dbProvider.ProviderName == "SqlServer")
            {
                sql = Regex.Replace(sql, @"(?<![.\w])(FUN_\w+|NULO)\s*\(",
                    "dbo.$1(",
                    RegexOptions.IgnoreCase);
            }

            return sql;
        }

        // Fallback: SELECT * da tabela
        return $"SELECT * FROM {_dbProvider.QuoteIdentifier(movement.GravTabe)}";
    }

    /// <summary>
    /// Verifica se a coluna é IDENTITY.
    /// </summary>
    private async Task<bool> IsIdentityColumnAsync(System.Data.IDbConnection connection, string tableName, string columnName)
    {
        if (!_dbProvider.SupportsIdentity)
            return false;

        var sql = _dbProvider.GetIdentityCheckQuery(tableName, columnName);
        var result = await connection.QueryFirstOrDefaultAsync<int?>(sql,
            new { TableName = tableName, ColumnName = columnName });
        return result == 1;
    }

    /// <summary>
    /// Converte valor de entrada (pode ser JsonElement) para valor do banco.
    /// </summary>
    private static object? ConvertValue(object? value)
    {
        if (value == null) return null;

        if (value is int or long or short or decimal or double or float or bool)
            return value;

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

    private static object? ConvertStringValue(string? value)
    {
        if (value == null) return null;
        if (value.Equals("on", StringComparison.OrdinalIgnoreCase)) return 1;
        if (value.Equals("true", StringComparison.OrdinalIgnoreCase)) return 1;
        if (value.Equals("false", StringComparison.OrdinalIgnoreCase)) return 0;
        if (string.IsNullOrWhiteSpace(value)) return null;
        return value;
    }

    /// <summary>
    /// Calcula totais para campos calculados do cabeçalho.
    /// Convenção SAG: campos TO+NomeCampoMovimento (ex: TOQTMVCT = SUM(QTDEMVCT))
    /// </summary>
    private async Task<Dictionary<string, object?>> CalculateMovementTotalsAsync(
        System.Data.IDbConnection connection,
        MovementMetadata metadata,
        string fkColumnName,
        int parentId)
    {
        var totals = new Dictionary<string, object?>();

        try
        {
            // Mapeamento de campos calculados comuns:
            // TO + sufixo do movimento = SUM(campo original)
            // Ex: movimento 125 (POCAMVCT) → TOQTMVCT = SUM(QTDEMVCT), TOVLMVCT = SUM(VALOMVCT)
            var sumFields = new Dictionary<string, string>
            {
                { "TOQTMVCT", "QTDEMVCT" },  // Total Quantidade
                { "TOVLMVCT", "VALOMVCT" },  // Total Valor
                { "TOPEMVCT", "PESOMVCT" },  // Total Peso (se existir)
                { "TOQTMOVE", "QTDEMOVE" },  // Outros movimentos
                { "TOVLMOVE", "VALOMOVE" }
            };

            var quotedTable = _dbProvider.QuoteIdentifier(metadata.GravTabe);
            var quotedFk = _dbProvider.QuoteIdentifier(fkColumnName);
            var param = _dbProvider.FormatParameter("ParentId");

            // Verifica quais campos existem na tabela do movimento
            var columnsQuery = _dbProvider.GetColumnsMetadataQuery(metadata.GravTabe);
            var columnsResult = await connection.QueryAsync<dynamic>(columnsQuery,
                new { TableName = metadata.GravTabe.ToUpper() });
            var existingColumns = columnsResult
                .Select(c => ((string)c.COLUMN_NAME).ToUpperInvariant())
                .ToHashSet();

            // Monta SELECT com SUMs apenas para campos que existem
            var sumClauses = new List<string>();
            var fieldMapping = new List<(string TotalField, string SumField)>();

            foreach (var mapping in sumFields)
            {
                if (existingColumns.Contains(mapping.Value.ToUpperInvariant()))
                {
                    sumClauses.Add($"{_dbProvider.NullFunction($"SUM({mapping.Value})", "0")} AS {mapping.Key}");
                    fieldMapping.Add((mapping.Key, mapping.Value));
                }
            }

            if (sumClauses.Count == 0)
            {
                _logger.LogDebug("Nenhum campo de total encontrado para movimento {MovementId}", metadata.CodiTabe);
                return totals;
            }

            var sql = $@"
                SELECT {string.Join(", ", sumClauses)}
                FROM {quotedTable}
                WHERE {quotedFk} = {param}";

            _logger.LogDebug("SQL de totais: {Sql}", sql);

            var result = await connection.QueryFirstOrDefaultAsync(sql, new { ParentId = parentId });

            if (result != null)
            {
                foreach (var prop in (IDictionary<string, object>)result)
                {
                    totals[prop.Key] = prop.Value;
                }
            }

            _logger.LogDebug("Totais calculados para movimento {MovementId}: {Totals}",
                metadata.CodiTabe, string.Join(", ", totals.Select(t => $"{t.Key}={t.Value}")));
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Erro ao calcular totais para movimento {MovementId}", metadata.CodiTabe);
            // Não propaga erro - totais são opcionais
        }

        return totals;
    }
}
