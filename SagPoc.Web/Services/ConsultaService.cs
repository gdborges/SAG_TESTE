using Dapper;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;
using System.Data;
using System.Globalization;
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
    private readonly ISequenceService _sequenceService;
    private readonly ILogger<ConsultaService> _logger;

    public ConsultaService(IDbProvider dbProvider, ISequenceService sequenceService, ILogger<ConsultaService> logger)
    {
        _dbProvider = dbProvider;
        _sequenceService = sequenceService;
        _logger = logger;
        _logger.LogInformation("ConsultaService inicializado com provider {Provider}", _dbProvider.ProviderName);
    }

    /// <summary>
    /// Busca campos com InicCamp=1 (campos que devem ter defaults aplicados).
    /// Replica o comportamento do Delphi InicValoCampPers.
    /// Retorna NomeCamp, CompCamp, PadrCamp (object para suportar texto e número) e VaGrCamp.
    /// </summary>
    private async Task<List<(string NomeCamp, string CompCamp, object? PadrCamp, string? VaGrCamp)>> GetFieldsWithDefaultsAsync(
        IDbConnection connection, int codiTabe)
    {
        var sql = $@"
            SELECT
                NOMECAMP as NomeCamp,
                {_dbProvider.NullFunction("COMPCAMP", "'E'")} as CompCamp,
                PADRCAMP as PadrCamp,
                VAGRCAMP as VaGrCamp
            FROM SISTCAMP
            WHERE CODITABE = {_dbProvider.FormatParameter("CodiTabe")}
              AND {_dbProvider.NullFunction("INICCAMP", "0")} = 1";

        var fields = await connection.QueryAsync<dynamic>(sql, new { CodiTabe = codiTabe });

        // Oracle retorna nomes de coluna em UPPERCASE
        return fields.Select(f =>
        {
            var dict = (IDictionary<string, object>)f;
            var nomeCamp = dict.ContainsKey("NOMECAMP") ? dict["NOMECAMP"]?.ToString() : dict["NomeCamp"]?.ToString();
            var compCamp = dict.ContainsKey("COMPCAMP") ? dict["COMPCAMP"]?.ToString() : dict["CompCamp"]?.ToString();
            var padrCampObj = dict.ContainsKey("PADRCAMP") ? dict["PADRCAMP"] : dict["PadrCamp"];
            var vaGrCampObj = dict.ContainsKey("VAGRCAMP") ? dict["VAGRCAMP"] : dict["VaGrCamp"];

            // Preserva PadrCamp como object - pode ser número ou texto dependendo do CompCamp
            object? padrCamp = null;
            if (padrCampObj != null && padrCampObj != DBNull.Value)
            {
                padrCamp = padrCampObj;
            }

            string? vaGrCamp = null;
            if (vaGrCampObj != null && vaGrCampObj != DBNull.Value)
            {
                vaGrCamp = vaGrCampObj.ToString();
            }

            return (
                NomeCamp: nomeCamp ?? "",
                CompCamp: compCamp?.Trim() ?? "E",
                PadrCamp: padrCamp,
                VaGrCamp: vaGrCamp
            );
        }).ToList();
    }

    /// <summary>
    /// Aplica valores default para campos com InicCamp=1 que não foram fornecidos.
    /// Replica o comportamento do Delphi InicValoCampPers que aplica defaults
    /// no DataSet ANTES do formulário aparecer para o usuário.
    ///
    /// Lógica por tipo de campo (CompCamp):
    /// - 'S', 'ES' (checkbox): PadrCamp != 0 ? 1 : 0
    /// - 'D' (data): Data atual
    /// - 'DH' (data/hora): Data atual
    /// - 'C' (combo): Primeiro valor de VaGrCamp
    /// - 'E' (texto): PadrCamp como string se definido
    /// - 'N', 'EN' (numérico): PadrCamp como número (mesmo se 0)
    /// </summary>
    private async Task ApplyFieldDefaultsAsync(
        IDbConnection connection,
        int tableId,
        Dictionary<string, object?> fields,
        HashSet<string> validColumns)
    {
        var fieldsWithDefaults = await GetFieldsWithDefaultsAsync(connection, tableId);

        foreach (var (nomeCamp, compCamp, padrCamp, vaGrCamp) in fieldsWithDefaults)
        {
            // Verifica se campo é válido na tabela
            if (!validColumns.Contains(nomeCamp.ToUpperInvariant()))
                continue;

            // Verifica se valor já foi fornecido pelo frontend
            var existingKey = fields.Keys.FirstOrDefault(k =>
                k.Equals(nomeCamp, StringComparison.OrdinalIgnoreCase));

            if (existingKey != null)
            {
                var existingValue = ConvertJsonElementToValue(fields[existingKey]);
                // Se já tem valor não-nulo/não-vazio, não sobrescreve
                if (existingValue != null && existingValue.ToString() != "")
                    continue;
            }

            // Aplica default baseado no tipo de campo
            object? defaultValue = null;

            if (compCamp == "S" || compCamp == "ES") // Checkbox
            {
                // Lógica Delphi: SeInte(PadrCamp = 0, 0, 1)
                // Se PadrCamp = 0, valor = 0; senão valor = 1
                var padrNum = ConvertToDecimal(padrCamp);
                defaultValue = (padrNum == null || padrNum == 0) ? 0 : 1;
                _logger.LogInformation(
                    "Aplicando default checkbox: {Field} = {Value} (PadrCamp={PadrCamp})",
                    nomeCamp, defaultValue, padrCamp);
            }
            else if (compCamp == "D" || compCamp == "DH") // Data ou Data/Hora
            {
                // Delphi aplica data atual para campos de data com InicCamp=1
                defaultValue = DateTime.Today;
                _logger.LogInformation(
                    "Aplicando default data: {Field} = {Value}",
                    nomeCamp, defaultValue);
            }
            else if (compCamp == "H") // Só hora
            {
                // Para campos de hora, não aplica default automático
                continue;
            }
            else if (compCamp == "C") // Combo
            {
                // Delphi: primeiro valor de VaGrCamp é o default
                // VaGrCamp contém valores separados por \n (newline)
                if (!string.IsNullOrEmpty(vaGrCamp))
                {
                    var firstValue = vaGrCamp
                        .Split(new[] { '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries)
                        .FirstOrDefault()?.Trim();

                    if (!string.IsNullOrEmpty(firstValue))
                    {
                        defaultValue = firstValue;
                        _logger.LogInformation(
                            "Aplicando default combo: {Field} = {Value} (primeiro de VaGrCamp)",
                            nomeCamp, defaultValue);
                    }
                }
            }
            else if (compCamp == "E") // Texto (Edit)
            {
                // Para campos de texto, usa PadrCamp como string se definido
                if (padrCamp != null)
                {
                    defaultValue = padrCamp.ToString();
                    _logger.LogInformation(
                        "Aplicando default texto: {Field} = {Value}",
                        nomeCamp, defaultValue);
                }
            }
            else if (compCamp == "N" || compCamp == "EN") // Numérico
            {
                // Para campos numéricos, aplica PadrCamp mesmo se for 0
                // (0 pode ser um valor default válido)
                if (padrCamp != null)
                {
                    var padrNum = ConvertToDecimal(padrCamp);
                    if (padrNum != null)
                    {
                        defaultValue = padrNum.Value;
                        _logger.LogInformation(
                            "Aplicando default numérico: {Field} = {Value}",
                            nomeCamp, defaultValue);
                    }
                }
            }
            else if (compCamp == "M" || compCamp == "MEMO")
            {
                // Campos memo: não aplica default numérico
                continue;
            }
            else
            {
                // Outros tipos: aplica PadrCamp se definido e != 0
                var padrNum = ConvertToDecimal(padrCamp);
                if (padrNum.HasValue && padrNum.Value != 0)
                {
                    defaultValue = padrNum.Value;
                    _logger.LogInformation(
                        "Aplicando default genérico: {Field} = {Value}",
                        nomeCamp, defaultValue);
                }
            }

            if (defaultValue != null)
            {
                // Adiciona ou atualiza o campo
                if (existingKey != null)
                    fields[existingKey] = defaultValue;
                else
                    fields[nomeCamp] = defaultValue;
            }
        }
    }

    /// <summary>
    /// Converte um valor object para decimal? de forma segura.
    /// </summary>
    private static decimal? ConvertToDecimal(object? value)
    {
        if (value == null) return null;
        if (value is decimal d) return d;
        if (value is int i) return i;
        if (value is long l) return l;
        if (value is double dbl) return (decimal)dbl;
        if (value is float f) return (decimal)f;
        if (decimal.TryParse(value.ToString(), out var result)) return result;
        return null;
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
    /// Converte valores string especiais (checkbox "on", datas, etc.) para valores do banco.
    /// </summary>
    private static object? ConvertStringValue(string? value)
    {
        if (value == null) return null;

        if (value.Equals("on", StringComparison.OrdinalIgnoreCase)) return 1;
        if (value.Equals("true", StringComparison.OrdinalIgnoreCase)) return 1;
        if (value.Equals("false", StringComparison.OrdinalIgnoreCase)) return 0;
        if (string.IsNullOrWhiteSpace(value)) return null;

        // Tenta detectar e converter datas (formato dd/MM/yyyy ou yyyy-MM-dd)
        if (TryParseDate(value, out var dateValue))
        {
            return dateValue;
        }

        // Tenta converter para decimal (suporta pt-BR vírgula e en-US ponto)
        var normalizedValue = value.Replace(",", ".");
        if (decimal.TryParse(normalizedValue, NumberStyles.Any, CultureInfo.InvariantCulture, out var decValue))
            return decValue;

        return value;
    }

    /// <summary>
    /// Tenta parsear uma string como data em formatos comuns.
    /// </summary>
    private static bool TryParseDate(string value, out DateTime result)
    {
        result = default;

        // Ignora valores muito curtos ou muito longos para serem datas
        if (value.Length < 8 || value.Length > 20) return false;

        // Formatos de data comuns
        var formats = new[]
        {
            "dd/MM/yyyy",      // Formato brasileiro
            "yyyy-MM-dd",      // Formato ISO
            "dd-MM-yyyy",      // Formato alternativo
            "MM/dd/yyyy",      // Formato americano
            "dd/MM/yyyy HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-ddTHH:mm:ss",
            "yyyy-MM-ddTHH:mm:ss.fff",
            "yyyy-MM-ddTHH:mm:ssZ"
        };

        return DateTime.TryParseExact(value, formats,
            System.Globalization.CultureInfo.InvariantCulture,
            System.Globalization.DateTimeStyles.None,
            out result);
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
                {_dbProvider.NullFunction("SIGLTABE", "''")} as SiglTabe,
                CABETABE as CabeTabe,
                {_dbProvider.NullFunction("SERITABE", "0")} as SeriTabe,
                GETATABE as GeTaTabe
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
    public async Task<ConsultasResponse> GetConsultasWithFallbackAsync(int tableId)
    {
        var response = new ConsultasResponse();

        // Primeiro tenta carregar do SISTCONS
        var consultas = await GetConsultasByTableAsync(tableId);

        if (consultas.Count > 0)
        {
            response.Consultas = consultas;
            response.Source = "SISTCONS";
            _logger.LogInformation("Tabela {TableId}: {Count} consultas carregadas do SISTCONS",
                tableId, consultas.Count);
            return response;
        }

        // Fallback: cria consulta padrão usando GRIDTABE/GRCOTABE de SISTTABE
        _logger.LogInformation("Tabela {TableId}: SISTCONS vazio, usando fallback GRIDTABE", tableId);

        var tableMetadata = await GetTableMetadataAsync(tableId);
        if (tableMetadata == null)
        {
            _logger.LogWarning("Tabela {TableId}: metadados não encontrados", tableId);
            response.Source = "SISTTABE";
            return response;
        }

        // Cria consulta padrão baseada em GRIDTABE
        var fallbackConsulta = new ConsultaMetadata
        {
            CodiCons = tableId * 1000, // ID sintético
            CodiTabe = tableId,
            NomeCons = "Padrão",
            BuscCons = $"{tableMetadata.SiglTabe?.Trim()}000-Padrão",
            SqlCons = tableMetadata.GridTabe,
            FiltCons = null, // GRCOTABE seria usado aqui se existisse
            AtivCons = 1,
            AcceCons = 1
        };

        // Se GridTabe estiver vazio, cria SQL básico com SELECT *
        if (string.IsNullOrEmpty(fallbackConsulta.SqlCons))
        {
            if (!string.IsNullOrEmpty(tableMetadata.GravTabe))
            {
                fallbackConsulta.SqlCons = $"SELECT * FROM {tableMetadata.GravTabe}";
                _logger.LogInformation("Tabela {TableId}: criado SQL fallback: SELECT * FROM {GravTabe}",
                    tableId, tableMetadata.GravTabe);
            }
        }

        if (!string.IsNullOrEmpty(fallbackConsulta.SqlCons))
        {
            response.Consultas.Add(fallbackConsulta);
        }

        response.Source = "SISTTABE";
        return response;
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
                // Aplica defaults de campos com InicCamp=1 (replica InicValoCampPers do Delphi)
                // Isso garante que checkboxes e outros campos tenham valores corretos no INSERT
                await ApplyFieldDefaultsAsync(connection, request.TableId, filteredFields, validColumns);

                // Modo VERI: Gera sequências para campos vazios/nulos/zero (InicCampSequ do Delphi)
                var sequenceFields = await _sequenceService.GetFieldsRequiringSequenceAsync(request.TableId);
                foreach (var seqField in sequenceFields)
                {
                    if (!validColumns.Contains(seqField.NomeCamp.ToUpperInvariant()))
                        continue;

                    // Verifica se campo já tem valor
                    var existingKey = filteredFields.Keys.FirstOrDefault(k =>
                        k.Equals(seqField.NomeCamp, StringComparison.OrdinalIgnoreCase));

                    if (existingKey != null)
                    {
                        var existingValue = ConvertJsonElementToValue(filteredFields[existingKey]);
                        // Se já tem valor não-nulo e não-zero, mantém
                        if (existingValue != null)
                        {
                            var numVal = ConvertToDecimal(existingValue);
                            if (numVal.HasValue && numVal.Value != 0)
                                continue;
                        }
                    }

                    // Gera sequência para o campo
                    var seqConfig = await _sequenceService.GetSequenceConfigAsync(request.TableId, seqField.NomeCamp);
                    Models.SequenceResult seqResult;

                    if (seqConfig != null)
                    {
                        seqResult = await _sequenceService.GetNextSequenceAsync(seqConfig.CodiNume);
                    }
                    else
                    {
                        seqResult = await _sequenceService.GetNextMaxPlusOneAsync(tableName, seqField.NomeCamp);
                    }

                    if (seqResult.Success)
                    {
                        if (existingKey != null)
                            filteredFields[existingKey] = seqResult.Value;
                        else
                            filteredFields[seqField.NomeCamp] = seqResult.Value;

                        _logger.LogInformation("SaveRecord VERI: gerada sequência {Field} = {Value}",
                            seqField.NomeCamp, seqResult.Value);
                    }
                }

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

    /// <inheritdoc/>
    public async Task<int> CreateEmptyRecordAsync(int tableId)
    {
        var table = await GetTableMetadataAsync(tableId);
        if (table == null || string.IsNullOrEmpty(table.GravTabe))
        {
            throw new InvalidOperationException($"Tabela {tableId} não encontrada");
        }

        var tableName = table.GravTabe;
        _logger.LogInformation("Criando registro vazio para tabela {TableId} ({TableName})", tableId, tableName);

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

            // Verifica estratégia de PK
            var (strategy, needsNewId) = await GetPkStrategyAsync(connection, tableName, pkColumn, null);
            _logger.LogInformation("Tabela {TableName}: estratégia PK = {Strategy}", tableName, strategy);

            using var transaction = connection.BeginTransaction();
            try
            {
                int newId;
                var columns = new List<string>();
                var parameters = new DynamicParameters();

                // Adiciona campos de controle padrão SAG (se existirem)
                var now = DateTime.Now;
                if (validColumns.Contains("CRDATABE"))
                {
                    columns.Add("CRDATABE");
                    parameters.Add("CRDATABE", now.Date);
                }
                if (validColumns.Contains("CRHORTABE"))
                {
                    columns.Add("CRHORTABE");
                    parameters.Add("CRHORTABE", now.ToString("HH:mm:ss"));
                }
                if (validColumns.Contains("ULDATABE"))
                {
                    columns.Add("ULDATABE");
                    parameters.Add("ULDATABE", now.Date);
                }
                if (validColumns.Contains("ULHORTABE"))
                {
                    columns.Add("ULHORTABE");
                    parameters.Add("ULHORTABE", now.ToString("HH:mm:ss"));
                }
                if (validColumns.Contains("CRUSUTABE"))
                {
                    columns.Add("CRUSUTABE");
                    parameters.Add("CRUSUTABE", 1); // Usuário padrão
                }
                if (validColumns.Contains("ULUSUTABE"))
                {
                    columns.Add("ULUSUTABE");
                    parameters.Add("ULUSUTABE", 1); // Usuário padrão
                }

                // Aplica defaults de campos com InicCamp=1 (replica InicValoCampPers do Delphi)
                var defaultFields = new Dictionary<string, object?>();
                await ApplyFieldDefaultsAsync(connection, tableId, defaultFields, validColumns);
                foreach (var field in defaultFields)
                {
                    if (!columns.Any(c => c.Equals(field.Key, StringComparison.OrdinalIgnoreCase)))
                    {
                        columns.Add(field.Key);
                        parameters.Add(field.Key, field.Value);
                    }
                }

                // Gera sequências para campos com TagQCamp=1 (InicCampSequ do Delphi)
                // Campos numéricos com InicCamp=1 e TagQCamp=1 recebem valores automáticos
                var sequenceValues = await _sequenceService.GenerateSequencesForTableAsync(tableId, tableName);

                // Consolida todos os valores em um Dictionary para evitar duplicatas
                var fieldValues = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
                foreach (var col in columns)
                {
                    if (parameters.ParameterNames.Contains(col))
                    {
                        fieldValues[col] = parameters.Get<object?>(col);
                    }
                }

                // Adiciona sequências (sobrescreve defaults se existir)
                foreach (var seq in sequenceValues)
                {
                    if (validColumns.Contains(seq.Key.ToUpperInvariant()))
                    {
                        fieldValues[seq.Key] = seq.Value;
                        _logger.LogInformation("Sequência final: {Field} = {Value}", seq.Key, seq.Value);
                    }
                }

                switch (strategy)
                {
                    case PkStrategy.Identity:
                        // SQL Server: banco gera PK automaticamente
                        break;

                    case PkStrategy.MaxPlusOneOrSequence:
                        // Gera próximo ID via MAX+1 ou SEQUENCE
                        var nextId1 = await _dbProvider.GetNextIdAsync(connection, tableName, pkColumn, false, transaction);
                        newId = nextId1 ?? throw new InvalidOperationException($"Não foi possível gerar ID para tabela {tableName}");
                        fieldValues[pkColumn] = newId;
                        break;

                    case PkStrategy.UserProvided:
                        // Se requer valor do usuário, gera via MAX+1 como fallback
                        var nextId2 = await _dbProvider.GetNextIdAsync(connection, tableName, pkColumn, false, transaction);
                        newId = nextId2 ?? throw new InvalidOperationException($"Não foi possível gerar ID para tabela {tableName}");
                        fieldValues[pkColumn] = newId;
                        break;
                }

                // Monta INSERT com fieldValues consolidados
                var quotedTable = _dbProvider.QuoteIdentifier(tableName);
                var finalColumns = fieldValues.Keys.ToList();
                var columnList = string.Join(", ", finalColumns.Select(c => _dbProvider.QuoteIdentifier(c)));
                var valueList = string.Join(", ", finalColumns.Select(c => _dbProvider.FormatParameter(c)));

                var finalParams = new DynamicParameters();
                foreach (var kv in fieldValues)
                {
                    finalParams.Add(kv.Key, kv.Value);
                }

                var sql = finalColumns.Count > 0
                    ? $"INSERT INTO {quotedTable} ({columnList}) VALUES ({valueList})"
                    : $"INSERT INTO {quotedTable} DEFAULT VALUES"; // Fallback para tabelas sem campos obrigatórios

                await connection.ExecuteAsync(sql, finalParams, transaction: transaction);

                if (strategy == PkStrategy.Identity)
                {
                    newId = await _dbProvider.GetLastInsertedIdAsync(connection, transaction);
                }
                else
                {
                    // Já temos o ID gerado em fieldValues
                    newId = Convert.ToInt32(fieldValues[pkColumn]);
                }

                transaction.Commit();

                _logger.LogInformation("Registro vazio criado: ID {NewId} na tabela {TableName}", newId, tableName);
                return newId;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao criar registro vazio na tabela {TableId}", tableId);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<SaveRecordResponse> DeleteRecordWithMovementsAsync(int tableId, int recordId)
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
        _logger.LogInformation("Excluindo registro {RecordId} e movimentos da tabela {TableId} ({TableName})",
            recordId, tableId, tableName);

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var pkColumn = await GetPrimaryKeyColumnAsync(connection, tableName);

            // Busca tabelas de movimento (filhos) via CABETABE
            var movementsSql = $@"
                SELECT CODITABE, GRAVTABE, {_dbProvider.NullFunction("SIGLTABE", "''")} as SiglTabe
                FROM SISTTABE
                WHERE CABETABE = {_dbProvider.FormatParameter("ParentId")}";

            var movements = await connection.QueryAsync<dynamic>(movementsSql, new { ParentId = tableId });

            using var transaction = connection.BeginTransaction();
            try
            {
                var totalDeleted = 0;

                // Deleta movimentos primeiro (FKs apontam para o header)
                foreach (var movement in movements)
                {
                    var movTableName = (string)movement.GRAVTABE;
                    var movSiglTabe = ((string?)movement.SiglTabe)?.Trim() ?? "";

                    if (string.IsNullOrEmpty(movTableName))
                        continue;

                    // Descobre a FK do movimento que referencia o header
                    // Convenção SAG: FK é CODI + sufixo do GRAVTABE (ex: POCACONT -> CODICONT)
                    // NÃO usa SIGLTABE pois pode diferir (ex: SIGLTABE=COTR mas FK=CODICONT)
                    var parentSuffix = tableName
                        .Replace("POCA", "")
                        .Replace("POGE", "")
                        .Replace("FPCA", "")
                        .Replace("ADMN", "");
                    var fkColumn = $"CODI{parentSuffix}";

                    // Verifica se a coluna FK existe na tabela de movimento
                    var fkCheckSql = _dbProvider.GetColumnsMetadataQuery(movTableName);
                    var movColumns = await connection.QueryAsync<dynamic>(fkCheckSql,
                        new { TableName = movTableName.ToUpper() }, transaction: transaction);
                    var hasFK = movColumns.Any(c =>
                        ((string)c.COLUMN_NAME).Equals(fkColumn, StringComparison.OrdinalIgnoreCase));

                    if (hasFK)
                    {
                        var quotedMovTable = _dbProvider.QuoteIdentifier(movTableName);
                        var quotedFK = _dbProvider.QuoteIdentifier(fkColumn);
                        var deleteSql = $"DELETE FROM {quotedMovTable} WHERE {quotedFK} = {_dbProvider.FormatParameter("ParentRecordId")}";

                        var deleted = await connection.ExecuteAsync(deleteSql,
                            new { ParentRecordId = recordId }, transaction: transaction);
                        totalDeleted += deleted;

                        _logger.LogInformation("Excluídos {Count} registros de movimento {MovTable} (FK: {FK})",
                            deleted, movTableName, fkColumn);
                    }
                    else
                    {
                        _logger.LogWarning("Coluna FK {FKColumn} não encontrada na tabela {MovTable}",
                            fkColumn, movTableName);
                    }
                }

                // Deleta o header
                var quotedTable = _dbProvider.QuoteIdentifier(tableName);
                var quotedPk = _dbProvider.QuoteIdentifier(pkColumn);
                var headerDeleteSql = $"DELETE FROM {quotedTable} WHERE {quotedPk} = {_dbProvider.FormatParameter("RecordId")}";

                var headerDeleted = await connection.ExecuteAsync(headerDeleteSql,
                    new { RecordId = recordId }, transaction: transaction);

                transaction.Commit();

                _logger.LogInformation("Exclusão em cascata concluída: header={Header}, movimentos={Movements}",
                    headerDeleted, totalDeleted);

                return new SaveRecordResponse
                {
                    Success = headerDeleted > 0,
                    Message = headerDeleted > 0
                        ? $"Registro e {totalDeleted} movimento(s) excluído(s) com sucesso"
                        : "Registro não encontrado"
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
            _logger.LogError(ex, "Erro ao excluir registro {RecordId} com movimentos da tabela {TableId}",
                recordId, tableId);
            return new SaveRecordResponse
            {
                Success = false,
                Message = $"Erro ao excluir: {ex.Message}"
            };
        }
    }

    /// <inheritdoc/>
    public async Task<Dictionary<string, object?>> GetFieldDefaultsAsync(int tableId)
    {
        var defaults = new Dictionary<string, object?>();

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var fieldsWithDefaults = await GetFieldsWithDefaultsAsync(connection, tableId);

            foreach (var (nomeCamp, compCamp, padrCamp, vaGrCamp) in fieldsWithDefaults)
            {
                object? defaultValue = null;

                if (compCamp == "S" || compCamp == "ES") // Checkbox
                {
                    var padrNum = ConvertToDecimal(padrCamp);
                    defaultValue = (padrNum == null || padrNum == 0) ? 0 : 1;
                }
                else if (compCamp == "D" || compCamp == "DH") // Data ou Data/Hora
                {
                    // Retorna data como string no formato ISO para JavaScript
                    defaultValue = DateTime.Today.ToString("yyyy-MM-dd");
                }
                else if (compCamp == "C") // Combo
                {
                    if (!string.IsNullOrEmpty(vaGrCamp))
                    {
                        var firstValue = vaGrCamp
                            .Split(new[] { '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries)
                            .FirstOrDefault()?.Trim();

                        if (!string.IsNullOrEmpty(firstValue))
                        {
                            defaultValue = firstValue;
                        }
                    }
                }
                else if (compCamp == "E") // Texto (Edit)
                {
                    // Para campos de texto, usa PadrCamp como string se definido
                    if (padrCamp != null)
                    {
                        defaultValue = padrCamp.ToString();
                    }
                }
                else if (compCamp == "N" || compCamp == "EN") // Numérico
                {
                    // Para campos numéricos, aplica PadrCamp mesmo se for 0
                    if (padrCamp != null)
                    {
                        var padrNum = ConvertToDecimal(padrCamp);
                        if (padrNum != null)
                        {
                            defaultValue = padrNum.Value;
                        }
                    }
                }
                else
                {
                    // Outros tipos: aplica PadrCamp se definido e != 0
                    var padrNum = ConvertToDecimal(padrCamp);
                    if (padrNum.HasValue && padrNum.Value != 0)
                    {
                        defaultValue = padrNum.Value;
                    }
                }

                if (defaultValue != null)
                {
                    defaults[nomeCamp] = defaultValue;
                    _logger.LogDebug("Default para {Field}: {Value} (tipo={CompCamp})",
                        nomeCamp, defaultValue, compCamp);
                }
            }

            _logger.LogInformation("Carregados {Count} defaults para tabela {TableId}",
                defaults.Count, tableId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter defaults da tabela {TableId}", tableId);
        }

        return defaults;
    }
}
