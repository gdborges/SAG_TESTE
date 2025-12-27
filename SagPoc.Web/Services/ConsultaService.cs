using Dapper;
using Microsoft.Data.SqlClient;
using SagPoc.Web.Models;
using System.Data;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço de consultas e CRUD usando Dapper com MSSQL.
/// </summary>
public class ConsultaService : IConsultaService
{
    private readonly string _connectionString;
    private readonly ILogger<ConsultaService> _logger;

    public ConsultaService(IConfiguration configuration, ILogger<ConsultaService> logger)
    {
        _connectionString = configuration.GetConnectionString("SagDb")
            ?? throw new InvalidOperationException("Connection string 'SagDb' not found.");
        _logger = logger;
    }

    private IDbConnection CreateConnection() => new SqlConnection(_connectionString);

    /// <summary>
    /// Obtém o nome real da coluna de chave primária (primeira coluna da tabela).
    /// No SAG, a convenção é que a primeira coluna é sempre a PK (CODI + sufixo da tabela).
    /// </summary>
    private async Task<string> GetPrimaryKeyColumnAsync(IDbConnection connection, string tableName)
    {
        var sql = @"
            SELECT TOP 1 COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = @TableName
            ORDER BY ORDINAL_POSITION";

        var pkColumn = await connection.QueryFirstOrDefaultAsync<string>(sql, new { TableName = tableName });
        return pkColumn ?? $"CODI{tableName.Replace("POCA", "").Replace("POGE", "")}"; // Fallback
    }

    /// <summary>
    /// Verifica se uma coluna é IDENTITY (auto-increment).
    /// </summary>
    private async Task<bool> IsIdentityColumnAsync(IDbConnection connection, string tableName, string columnName)
    {
        var sql = @"
            SELECT COLUMNPROPERTY(OBJECT_ID(@TableName), @ColumnName, 'IsIdentity')";

        var result = await connection.QueryFirstOrDefaultAsync<int?>(sql, new { TableName = tableName, ColumnName = columnName });
        return result == 1;
    }

    /// <summary>
    /// Estratégia de geração de Primary Key.
    /// </summary>
    public enum PkStrategy
    {
        /// <summary>Banco gera via IDENTITY, usar SCOPE_IDENTITY()</summary>
        Identity,
        /// <summary>Aplicação gera via MAX()+1 (tabelas SAG legado)</summary>
        MaxPlusOne,
        /// <summary>Valor já fornecido pelo usuário/frontend</summary>
        UserProvided
    }

    /// <summary>
    /// Determina a estratégia de geração de PK para INSERT.
    /// Encapsula a lógica de decisão baseada em metadados da tabela e valor fornecido.
    /// </summary>
    /// <param name="connection">Conexão com o banco</param>
    /// <param name="tableName">Nome da tabela</param>
    /// <param name="pkColumn">Nome da coluna PK</param>
    /// <param name="providedPkValue">Valor de PK fornecido pelo frontend (pode ser null, 0, ou valor válido)</param>
    /// <returns>Estratégia a ser usada e se precisa gerar novo ID</returns>
    private async Task<(PkStrategy Strategy, bool NeedsNewId)> GetPkStrategyAsync(
        IDbConnection connection,
        string tableName,
        string pkColumn,
        object? providedPkValue)
    {
        // Verifica se a coluna é IDENTITY
        var isIdentity = await IsIdentityColumnAsync(connection, tableName, pkColumn);

        if (isIdentity)
        {
            // IDENTITY: banco gera automaticamente, não precisa de ID manual
            return (PkStrategy.Identity, false);
        }

        // Tabela não-IDENTITY (legado SAG): verifica se valor foi fornecido
        var needsNewId = providedPkValue == null
            || providedPkValue.ToString() == "0"
            || providedPkValue.ToString() == ""
            || (providedPkValue is int intVal && intVal == 0)
            || (providedPkValue is long longVal && longVal == 0);

        if (needsNewId)
        {
            // Precisa gerar via MAX()+1
            return (PkStrategy.MaxPlusOne, true);
        }

        // Valor válido fornecido pelo usuário
        return (PkStrategy.UserProvided, false);
    }

    /// <summary>
    /// Converte um valor object (que pode ser JsonElement) para tipo primitivo.
    /// </summary>
    private static object? ConvertJsonElementToValue(object? value)
    {
        if (value == null) return null;

        // Se já é um tipo primitivo, retorna diretamente (não converte para string!)
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

        // Checkbox HTML envia "on" quando marcado
        if (value.Equals("on", StringComparison.OrdinalIgnoreCase)) return 1;

        // Valores booleanos em texto
        if (value.Equals("true", StringComparison.OrdinalIgnoreCase)) return 1;
        if (value.Equals("false", StringComparison.OrdinalIgnoreCase)) return 0;

        // String vazia para campos numéricos deve ser null
        if (string.IsNullOrWhiteSpace(value)) return null;

        return value;
    }

    /// <inheritdoc/>
    public async Task<TableMetadata?> GetTableMetadataAsync(int tableId)
    {
        const string sql = @"
            SELECT
                CODITABE as CodiTabe,
                ISNULL(NOMETABE, '') as NomeTabe,
                ISNULL(FORMTABE, '') as FormTabe,
                ISNULL(CAPTTABE, '') as CaptTabe,
                ISNULL(HINTTABE, '') as HintTabe,
                ISNULL(GRAVTABE, '') as GravTabe,
                ISNULL(CHAVTABE, 1) as ChavTabe,
                ISNULL(GUI1TABE, '') as Gui1Tabe,
                ISNULL(GUI2TABE, '') as Gui2Tabe,
                CAST(PARATABE as NVARCHAR(MAX)) as ParaTabe,
                CAST(GRIDTABE as NVARCHAR(MAX)) as GridTabe,
                ISNULL(ALTUTABE, 400) as AltuTabe,
                ISNULL(TAMATABE, 600) as TamaTabe,
                ISNULL(SIGLTABE, '') as SiglTabe
            FROM SISTTABE
            WHERE CODITABE = @TableId";

        try
        {
            using var connection = CreateConnection();
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
        const string sql = @"
            SELECT
                CODICONS as CodiCons,
                CODITABE as CodiTabe,
                ISNULL(NOMECONS, '') as NomeCons,
                ISNULL(BUSCCONS, '') as BuscCons,
                CAST(SQL_CONS as NVARCHAR(MAX)) as SqlCons,
                CAST(FILTCONS as NVARCHAR(MAX)) as FiltCons,
                CAST(WHERCONS as NVARCHAR(MAX)) as WherCons,
                CAST(ORBYCONS as NVARCHAR(MAX)) as OrByCons,
                ISNULL(ACCECONS, 1) as AcceCons,
                ISNULL(ATIVCONS, 1) as AtivCons
            FROM SISTCONS
            WHERE CODITABE = @TableId
              AND ISNULL(ATIVCONS, 1) = 1
            ORDER BY NOMECONS";

        try
        {
            using var connection = CreateConnection();
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
        const string sql = @"
            SELECT
                CODICONS as CodiCons,
                CODITABE as CodiTabe,
                ISNULL(NOMECONS, '') as NomeCons,
                ISNULL(BUSCCONS, '') as BuscCons,
                CAST(SQL_CONS as NVARCHAR(MAX)) as SqlCons,
                CAST(FILTCONS as NVARCHAR(MAX)) as FiltCons,
                CAST(WHERCONS as NVARCHAR(MAX)) as WherCons,
                CAST(ORBYCONS as NVARCHAR(MAX)) as OrByCons,
                ISNULL(ACCECONS, 1) as AcceCons,
                ISNULL(ATIVCONS, 1) as AtivCons
            FROM SISTCONS
            WHERE CODICONS = @ConsultaId";

        try
        {
            using var connection = CreateConnection();
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

        // Prepara o SQL base e extrai ORDER BY original
        var (baseSql, extractedOrderBy) = PrepareBaseSql(consulta.SqlCons ?? "");

        // Aplica filtros
        var (filterSql, parameters) = BuildFilterClause(request.Filters);

        // Monta SQL com filtros
        var filteredSql = ApplyFiltersToSql(baseSql, filterSql);

        try
        {
            using var connection = CreateConnection();
            connection.Open();

            // Conta total de registros
            var countSql = $"SELECT COUNT(*) FROM ({filteredSql}) AS CountQuery";
            var totalRecords = await connection.ExecuteScalarAsync<int>(countSql, parameters);

            // Calcula paginação
            var totalPages = (int)Math.Ceiling((double)totalRecords / request.PageSize);
            var offset = (request.Page - 1) * request.PageSize;

            // Aplica ordenação e paginação
            // Quando há filtros, a query é envolvida em subquery e o ORDER BY original pode referenciar
            // colunas internas que não são visíveis na query externa (só os aliases são visíveis)
            var hasFilters = request.Filters.Any(f => !string.IsNullOrEmpty(f.Field) && !string.IsNullOrEmpty(f.Value));
            var orderByClause = hasFilters && string.IsNullOrEmpty(request.SortField)
                ? "(SELECT NULL)"  // Não pode usar ORDER BY extraído quando há subquery wrapper
                : GetOrderByClause(request, consulta, hasFilters ? null : extractedOrderBy);

            var pagedSql = $@"
                {filteredSql}
                ORDER BY {orderByClause}
                OFFSET {offset} ROWS
                FETCH NEXT {request.PageSize} ROWS ONLY";

            var data = await connection.QueryAsync(pagedSql, parameters);

            // Converte para lista de dicionários
            var dataList = data.Select(row =>
            {
                var dict = new Dictionary<string, object?>();
                foreach (var prop in (IDictionary<string, object>)row)
                {
                    dict[prop.Key] = prop.Value;
                }
                return dict;
            }).ToList();

            // Obtém colunas do FILTCONS ou gera a partir dos dados
            var columns = consulta.GetColumns();
            if (columns.Count == 0 && dataList.Count > 0)
            {
                // Fallback: gera colunas a partir das chaves do primeiro registro
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

        // Extrai e remove ORDER BY existente (será adicionado depois com paginação)
        var orderByIndex = sql.LastIndexOf("ORDER BY", StringComparison.OrdinalIgnoreCase);
        if (orderByIndex > 0)
        {
            // Extrai a cláusula ORDER BY original (ex: "maqulesi" de "ORDER BY maqulesi")
            orderByClause = sql.Substring(orderByIndex + 8).Trim(); // +8 para pular "ORDER BY"
            sql = sql.Substring(0, orderByIndex).Trim();
        }

        // Substitui FUN_LOGI por CASE (incluindo prefixo DBO. se existir)
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

            var paramName = $"@filter{paramIndex++}";
            var fieldName = SanitizeFieldName(filter.Field);

            // Constrói a condição baseada no tipo de filtro
            var condition = filter.Condition.ToLower() switch
            {
                "startswith" => $"[{fieldName}] LIKE {paramName} + '%'",
                "contains" => $"[{fieldName}] LIKE '%' + {paramName} + '%'",
                "equals" => $"[{fieldName}] = {paramName}",
                "notequals" => $"[{fieldName}] <> {paramName}",
                _ => $"[{fieldName}] LIKE '%' + {paramName} + '%'"
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
        // Remove caracteres inválidos para prevenir SQL injection
        // Preserva letras acentuadas (á, é, í, ó, ú, ã, õ, ç, etc.)
        return Regex.Replace(fieldName, @"[^\p{L}\p{N}\s_]", "");
    }

    private string ApplyFiltersToSql(string baseSql, string filterClause)
    {
        if (string.IsNullOrEmpty(filterClause))
            return baseSql;

        // Envolve a query em uma subquery para filtrar pelos aliases
        // Isso permite filtrar por nomes de colunas como "Tipo" que são aliases no SELECT
        return $"SELECT * FROM ({baseSql}) AS BaseQuery WHERE {filterClause}";
    }

    private string GetOrderByClause(GridFilterRequest request, ConsultaMetadata consulta, string? extractedOrderBy = null)
    {
        if (!string.IsNullOrEmpty(request.SortField))
        {
            var direction = request.SortDirection?.ToUpper() == "DESC" ? "DESC" : "ASC";
            return $"[{SanitizeFieldName(request.SortField)}] {direction}";
        }

        // Usa ORDER BY extraído do SQL original (mais confiável que ORBYCONS)
        if (!string.IsNullOrEmpty(extractedOrderBy))
        {
            return extractedOrderBy;
        }

        // Default: primeira coluna (sem ordenação específica)
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
            using var connection = CreateConnection();
            connection.Open();

            // Obtém o nome real da coluna PK da tabela
            var pkColumn = await GetPrimaryKeyColumnAsync(connection, tableName);

            var sql = $"SELECT * FROM [{tableName}] WHERE [{pkColumn}] = @RecordId";
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
            using var connection = CreateConnection();
            connection.Open();

            // Obtém o nome real da coluna PK da tabela
            var pkColumn = await GetPrimaryKeyColumnAsync(connection, tableName);

            // Obtém as colunas válidas da tabela para filtrar campos inválidos
            var validColumnsSql = @"
                SELECT COLUMN_NAME
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = @TableName";
            var validColumns = (await connection.QueryAsync<string>(validColumnsSql, new { TableName = tableName }))
                .Select(c => c.ToUpperInvariant())
                .ToHashSet();

            // Filtra apenas campos que existem na tabela
            var filteredFields = request.Fields
                .Where(f => validColumns.Contains(f.Key.ToUpperInvariant()))
                .ToDictionary(f => f.Key, f => f.Value);

            if (request.IsNew)
            {
                // Busca PK fornecida pelo frontend (case-insensitive)
                var pkKey = filteredFields.Keys.FirstOrDefault(k => k.Equals(pkColumn, StringComparison.OrdinalIgnoreCase));
                var providedPkValue = pkKey != null ? ConvertJsonElementToValue(filteredFields[pkKey]) : null;

                // Determina estratégia de PK usando método centralizado
                var (strategy, needsNewId) = await GetPkStrategyAsync(connection, tableName, pkColumn, providedPkValue);
                _logger.LogInformation("Tabela {TableName}: estratégia PK = {Strategy}, needsNewId = {NeedsNewId}",
                    tableName, strategy, needsNewId);

                // Usa transação para garantir atomicidade: MAX()+1 → INSERT → SCOPE_IDENTITY()
                using var transaction = connection.BeginTransaction();
                try
                {
                    switch (strategy)
                    {
                        case PkStrategy.Identity:
                            // Remove a coluna IDENTITY do INSERT - o banco gerará automaticamente
                            filteredFields.Remove(pkColumn);
                            break;

                        case PkStrategy.MaxPlusOne:
                            // Remove entrada existente da PK (evita duplicação por diferença de case)
                            if (pkKey != null) filteredFields.Remove(pkKey);

                            // Gera próximo ID baseado no MAX atual (dentro da transação)
                            // TABLOCKX + HOLDLOCK previne race condition: bloqueia tabela até commit
                            var maxIdSql = $"SELECT ISNULL(MAX([{pkColumn}]), 0) + 1 FROM [{tableName}] WITH (TABLOCKX, HOLDLOCK)";
                            var nextId = await connection.ExecuteScalarAsync<int>(maxIdSql, transaction: transaction);
                            filteredFields[pkColumn] = nextId;
                            _logger.LogInformation("Gerado próximo ID {NextId} para tabela {TableName}", nextId, tableName);
                            break;

                        case PkStrategy.UserProvided:
                            // Mantém valor fornecido pelo usuário
                            break;
                    }

                    var columns = filteredFields.Keys.ToList();
                    var values = columns.Select(c => $"@{c}");

                    // Monta o INSERT simples (sem OUTPUT pois tabelas podem ter triggers)
                    var sql = $@"
                        INSERT INTO [{tableName}] ({string.Join(", ", columns.Select(c => $"[{c}]"))})
                        VALUES ({string.Join(", ", values)});
                        SELECT SCOPE_IDENTITY();";

                    var parameters = new DynamicParameters();
                    foreach (var field in filteredFields)
                    {
                        var convertedValue = ConvertJsonElementToValue(field.Value);
                        parameters.Add($"@{field.Key}", convertedValue);
                    }

                    int newId;
                    if (strategy == PkStrategy.Identity)
                    {
                        // Executa INSERT e obtém o ID gerado pelo IDENTITY usando SCOPE_IDENTITY()
                        var result = await connection.QuerySingleOrDefaultAsync<decimal?>(sql, parameters, transaction: transaction);
                        newId = result.HasValue ? Convert.ToInt32(result.Value) : 0;
                        _logger.LogInformation("IDENTITY gerou ID {NewId} para tabela {TableName}", newId, tableName);
                    }
                    else
                    {
                        await connection.ExecuteAsync(sql, parameters, transaction: transaction);
                        // Retorna o ID que foi inserido (gerado ou fornecido)
                        newId = filteredFields.TryGetValue(pkColumn, out var generatedPk)
                            ? Convert.ToInt32(generatedPk)
                            : 0;
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
                    .Select(k => $"[{k}] = @{k}");

                var sql = $@"
                    UPDATE [{tableName}]
                    SET {string.Join(", ", setClauses)}
                    WHERE [{pkColumn}] = @RecordId";

                var parameters = new DynamicParameters();
                parameters.Add("@RecordId", request.RecordId);
                foreach (var field in filteredFields)
                {
                    parameters.Add($"@{field.Key}", ConvertJsonElementToValue(field.Value));
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
            using var connection = CreateConnection();
            connection.Open();

            // Obtém o nome real da coluna PK da tabela
            var pkColumn = await GetPrimaryKeyColumnAsync(connection, tableName);

            var sql = $"DELETE FROM [{tableName}] WHERE [{pkColumn}] = @RecordId";
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
