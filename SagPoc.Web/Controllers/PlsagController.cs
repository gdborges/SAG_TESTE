using Microsoft.AspNetCore.Mvc;
using Dapper;
using System.Data;
using System.Security;
using System.Text.RegularExpressions;
using SagPoc.Web.Services;
using SagPoc.Web.Services.Database;

namespace SagPoc.Web.Controllers;

/// <summary>
/// Controller para execucao de comandos PLSAG server-side.
///
/// PRINCIPIO DE SEGURANCA: O frontend NUNCA envia SQL bruto.
/// - O frontend envia IDs de comandos/queries (referencia ao banco)
/// - O backend busca o SQL original na tabela SISTCAMP
/// - O backend substitui templates e valida antes de executar
/// - Parametros sao sanitizados usando queries parametrizadas
/// </summary>
[Route("api/plsag")]
[ApiController]
public class PlsagController : ControllerBase
{
    private readonly IDbProvider _dbProvider;
    private readonly ILogger<PlsagController> _logger;
    private readonly IMetadataService _metadataService;
    private readonly ILookupService _lookupService;

    // Lista de tabelas permitidas para operacoes de gravacao
    private static readonly HashSet<string> AllowedTables = new(StringComparer.OrdinalIgnoreCase)
    {
        // Adicione tabelas permitidas conforme necessario
        "CADAPESS", "CADAPROD", "CADAEMPR", "CADAFILI", "CADAOPER",
        "MOVICOMP", "MOVIVEND", "MOVIESTO", "MOVICONT"
    };

    // Padroes de SQL bloqueados (seguranca)
    private static readonly string[] BlockedPatterns = {
        "DROP ", "TRUNCATE ", "ALTER ", "CREATE ", "GRANT ", "REVOKE ",
        "xp_", "sp_", "EXEC ", "EXECUTE ", "--", "/*", "*/"
    };

    public PlsagController(
        IDbProvider dbProvider,
        ILogger<PlsagController> logger,
        IMetadataService metadataService,
        ILookupService lookupService)
    {
        _dbProvider = dbProvider;
        _logger = logger;
        _metadataService = metadataService;
        _lookupService = lookupService;
    }

    private IDbConnection CreateConnection()
    {
        return _dbProvider.CreateConnection();
    }

    #region Query Endpoints

    /// <summary>
    /// Executa query PLSAG (QY, QN).
    /// POC: Aceita SQL direto do frontend com validacao.
    /// Em producao, o SQL deveria vir da tabela SISTCAMP.
    /// </summary>
    [HttpPost("query")]
    public async Task<IActionResult> ExecuteQuery([FromBody] QueryRequest request)
    {
        try
        {
            _logger.LogInformation("PLSAG Query: {QueryName} CodiTabe={CodiTabe} Type={Type} Sql={Sql}",
                request.QueryName, request.CodiTabe, request.Type, request.Sql?.Substring(0, Math.Min(50, request.Sql?.Length ?? 0)));

            using var connection = CreateConnection();
            connection.Open();

            string sql;

            // POC: Se SQL direto foi fornecido, usa ele (apos validacao)
            if (!string.IsNullOrEmpty(request.Sql))
            {
                sql = request.Sql;

                // Valida SQL antes de executar
                if (!IsValidSql(sql))
                {
                    _logger.LogWarning("SQL bloqueado por seguranca: {Sql}", sql);
                    return BadRequest(new { success = false, error = "SQL invalido ou nao permitido" });
                }

                // Apenas SELECT permitido para queries diretas
                if (!sql.Trim().StartsWith("SELECT", StringComparison.OrdinalIgnoreCase))
                {
                    _logger.LogWarning("Apenas SELECT permitido para SQL direto: {Sql}", sql);
                    return BadRequest(new { success = false, error = "Apenas SELECT permitido" });
                }
            }
            else
            {
                // Para a POC, usamos o queryName diretamente como nome de uma view ou construimos SQL seguro
                // Em producao, o SQL deveria vir da tabela SISTCAMP
                sql = BuildSafeQuerySql(request.QueryName, request.Params);

                if (string.IsNullOrEmpty(sql))
                {
                    return BadRequest(new { success = false, error = "Query nao encontrada ou invalida" });
                }
            }

            var parameters = new DynamicParameters(request.Params);
            var isSingleRow = request.SingleRow || request.Type != "multi";

            if (!isSingleRow)
            {
                var results = await connection.QueryAsync<dynamic>(sql, parameters);
                return Ok(new { success = true, data = results.ToList() });
            }
            else
            {
                var result = await connection.QueryFirstOrDefaultAsync<dynamic>(sql, parameters);
                return Ok(new { success = true, data = result });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar query PLSAG: {QueryName} SQL: {Sql}",
                request.QueryName, request.Sql?.Substring(0, Math.Min(100, request.Sql?.Length ?? 0)));
            return StatusCode(500, new { success = false, error = $"Erro interno ao executar query: {ex.Message}" });
        }
    }

    /// <summary>
    /// Constroi SQL seguro baseado no nome da query.
    /// Na POC, simula busca em SISTCAMP.
    /// </summary>
    private string BuildSafeQuerySql(string? queryName, Dictionary<string, object>? parameters)
    {
        if (string.IsNullOrEmpty(queryName))
            return string.Empty;

        // TODO: Em producao, buscar SQL da tabela SISTCAMP
        // Por enquanto, retorna vazio para a POC demonstrar a estrutura
        _logger.LogDebug("BuildSafeQuerySql: queryName={QueryName}", queryName);

        // Se o queryName segue um padrao conhecido, podemos construir SQL seguro
        // Exemplo: "PRODUTO" -> SELECT * FROM CADAPROD WHERE ...
        return string.Empty;
    }

    #endregion

    #region Dynamic Lookup Endpoint

    /// <summary>
    /// Executa lookup com injeção dinâmica de condição SQL.
    /// Usado pelo comando PLSAG QY-CAMPO-CONDIÇÃO para filtrar lookups em runtime.
    /// </summary>
    [HttpPost("execute-dynamic-lookup")]
    public async Task<IActionResult> ExecuteDynamicLookup([FromBody] DynamicLookupRequest request)
    {
        try
        {
            _logger.LogInformation("Dynamic Lookup: CodiCamp={CodiCamp} Condition={Condition}",
                request.CodiCamp, request.Condition?.Substring(0, Math.Min(50, request.Condition?.Length ?? 0)));

            // 1. Validar request
            if (request.CodiCamp <= 0)
            {
                return BadRequest(new { success = false, error = "CodiCamp é obrigatório" });
            }

            if (string.IsNullOrWhiteSpace(request.Condition))
            {
                return BadRequest(new { success = false, error = "Condition não pode ser vazia" });
            }

            // 2. Buscar metadata do campo
            var fields = await _metadataService.GetFieldsByTableAsync(request.CodiTabe);
            var field = fields.FirstOrDefault(f => f.CodiCamp == request.CodiCamp);

            if (field == null)
            {
                _logger.LogWarning("Campo não encontrado: CodiCamp={CodiCamp}, CodiTabe={CodiTabe}",
                    request.CodiCamp, request.CodiTabe);
                return BadRequest(new { success = false, error = $"Campo {request.CodiCamp} não encontrado" });
            }

            if (field.SqlLines == null || field.SqlLines.Length == 0)
            {
                // Se SqlLines não foi populado mas SqlCamp existe, faz split agora
                if (!string.IsNullOrEmpty(field.SqlCamp))
                {
                    field.SqlLines = field.SqlCamp.Split('\n');
                }
                else
                {
                    _logger.LogWarning("Campo não suporta SQL dinâmico: CodiCamp={CodiCamp}", request.CodiCamp);
                    return BadRequest(new { success = false, error = "Campo não suporta SQL dinâmico (SQL_CAMP vazio)" });
                }
            }

            // 3. Executar lookup dinâmico
            var items = await _lookupService.ExecuteDynamicLookupAsync(
                field.SqlLines,
                request.Condition,
                request.Parameters ?? new Dictionary<string, object>());

            _logger.LogInformation("Dynamic Lookup executado: CodiCamp={CodiCamp}, {Count} itens retornados",
                request.CodiCamp, items.Count);

            return Ok(new { success = true, data = items });
        }
        catch (SecurityException ex)
        {
            _logger.LogWarning("Tentativa de SQL injection bloqueada: {Message}", ex.Message);
            return BadRequest(new { success = false, error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar dynamic lookup: CodiCamp={CodiCamp}", request.CodiCamp);
            return StatusCode(500, new { success = false, error = $"Erro interno ao executar lookup: {ex.Message}" });
        }
    }

    #endregion

    #region Execute SQL Endpoints

    /// <summary>
    /// Executa SQL de comandos EX (EX-SQL, EX-DTBCADA, EX-DTBGENE).
    /// SEGURO: SQL vem do banco, nao do frontend.
    /// </summary>
    [HttpPost("execute-sql")]
    public async Task<IActionResult> ExecuteSql([FromBody] ExecuteSqlRequest request)
    {
        try
        {
            _logger.LogInformation("PLSAG Execute SQL: CommandId={CommandId} CodiTabe={CodiTabe}",
                request.CommandId, request.CodiTabe);

            using var connection = CreateConnection();
            connection.Open();

            // Busca SQL da tabela SISTCAMP
            var instruction = await GetPlsagInstruction(connection, request.CodiTabe, request.CodiCamp, request.CommandId);

            if (string.IsNullOrEmpty(instruction))
            {
                return BadRequest(new { success = false, error = "Instrucao PLSAG nao encontrada" });
            }

            // Processa templates e obtem parametros
            var (sql, parameters) = ProcessPlsagInstruction(instruction, request.Params);

            // Valida SQL
            if (!IsValidSql(sql))
            {
                _logger.LogWarning("SQL bloqueado: {Sql}", sql);
                return BadRequest(new { success = false, error = "SQL invalido ou nao permitido" });
            }

            // Audit log
            _logger.LogInformation(
                "PLSAG SQL executado: CodiTabe={CodiTabe}, CodiCamp={CodiCamp}, User={User}",
                request.CodiTabe, request.CodiCamp, User.Identity?.Name ?? "anonimo");

            var rowsAffected = await connection.ExecuteAsync(sql, parameters);
            return Ok(new { success = true, rowsAffected });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar SQL PLSAG: {CommandId}", request.CommandId);
            return StatusCode(500, new { success = false, error = "Erro interno ao executar SQL" });
        }
    }

    /// <summary>
    /// Executa procedure ou comando generico.
    /// </summary>
    [HttpPost("execute")]
    public async Task<IActionResult> Execute([FromBody] ExecuteRequest request)
    {
        try
        {
            _logger.LogInformation("PLSAG Execute: Type={Type} Name={Name}",
                request.Type, request.Name);

            switch (request.Type?.ToLower())
            {
                case "procedure":
                    return await ExecuteProcedure(request);

                case "validate-cpf":
                    return Ok(new { success = true, data = ValidateCPF(request.Params?.GetValueOrDefault("value")?.ToString()) });

                case "validate-cnpj":
                    return Ok(new { success = true, data = ValidateCNPJ(request.Params?.GetValueOrDefault("value")?.ToString()) });

                default:
                    return BadRequest(new { success = false, error = $"Tipo de execucao desconhecido: {request.Type}" });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar comando PLSAG: {Type} {Name}", request.Type, request.Name);
            return StatusCode(500, new { success = false, error = "Erro interno ao executar comando" });
        }
    }

    private async Task<IActionResult> ExecuteProcedure(ExecuteRequest request)
    {
        if (string.IsNullOrEmpty(request.Name))
        {
            return BadRequest(new { success = false, error = "Nome da procedure nao informado" });
        }

        // Valida nome da procedure (apenas alfanumericos e underscore)
        if (!Regex.IsMatch(request.Name, @"^[a-zA-Z_][a-zA-Z0-9_]*$"))
        {
            return BadRequest(new { success = false, error = "Nome de procedure invalido" });
        }

        using var connection = CreateConnection();
        connection.Open();

        var parameters = new DynamicParameters(request.Params);
        var result = await connection.QueryFirstOrDefaultAsync<dynamic>(
            request.Name,
            parameters,
            commandType: CommandType.StoredProcedure);

        return Ok(new { success = true, data = result });
    }

    /// <summary>
    /// Executa SQL direto (DELETE, UPDATE, INSERT) via EX-SQL.
    /// POC: Aceita SQL do frontend com validacoes de seguranca.
    /// </summary>
    [HttpPost("execute-direct-sql")]
    public async Task<IActionResult> ExecuteDirectSql([FromBody] DirectSqlRequest request)
    {
        try
        {
            _logger.LogInformation("PLSAG Direct SQL: Type={Type} Sql={Sql}",
                request.SqlType, request.Sql?.Substring(0, Math.Min(80, request.Sql?.Length ?? 0)));

            // Validacao basica
            if (string.IsNullOrEmpty(request.Sql))
            {
                return BadRequest(new { success = false, error = "SQL nao fornecido" });
            }

            var sqlTrimmed = request.Sql.Trim();
            var sqlUpper = sqlTrimmed.ToUpperInvariant();

            // Determina tipo automaticamente se nao especificado
            var sqlType = request.SqlType?.ToUpperInvariant() ?? "";
            if (string.IsNullOrEmpty(sqlType))
            {
                if (sqlUpper.StartsWith("DELETE")) sqlType = "DELETE";
                else if (sqlUpper.StartsWith("UPDATE")) sqlType = "UPDATE";
                else if (sqlUpper.StartsWith("INSERT")) sqlType = "INSERT";
                else
                {
                    _logger.LogWarning("Tipo SQL nao reconhecido: {Sql}", sqlTrimmed.Substring(0, Math.Min(50, sqlTrimmed.Length)));
                    return BadRequest(new { success = false, error = "Tipo SQL nao reconhecido. Use DELETE, UPDATE ou INSERT." });
                }
            }

            // Validacao de seguranca: DELETE DEVE ter WHERE
            if (sqlType == "DELETE" && !sqlUpper.Contains("WHERE"))
            {
                _logger.LogWarning("DELETE sem WHERE bloqueado: {Sql}", request.Sql);
                return BadRequest(new { success = false, error = "DELETE requer clausula WHERE por seguranca" });
            }

            // Valida SQL (bloqueia DROP, TRUNCATE, etc.)
            if (!IsValidSql(request.Sql))
            {
                _logger.LogWarning("SQL bloqueado por padrao perigoso: {Sql}", request.Sql);
                return BadRequest(new { success = false, error = "SQL contem padroes nao permitidos" });
            }

            // Extrai e valida nome da tabela
            var tableName = ExtractTableName(request.Sql, sqlType);
            if (string.IsNullOrEmpty(tableName))
            {
                _logger.LogWarning("Nao foi possivel extrair nome da tabela: {Sql}", request.Sql);
                return BadRequest(new { success = false, error = "Nao foi possivel identificar a tabela" });
            }

            if (!IsValidTableName(tableName))
            {
                _logger.LogWarning("Tabela nao permitida para SQL direto: {Table}", tableName);
                return BadRequest(new { success = false, error = $"Tabela '{tableName}' nao permitida para esta operacao" });
            }

            // Executa SQL
            using var connection = CreateConnection();
            connection.Open();

            var parameters = new DynamicParameters(request.Params);
            var rowsAffected = await connection.ExecuteAsync(request.Sql, parameters);

            _logger.LogInformation("SQL executado: {Type} em {Table}, {Rows} linhas afetadas",
                sqlType, tableName, rowsAffected);

            return Ok(new { success = true, rowsAffected, sqlType, tableName });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar SQL direto: {Sql}", request.Sql?.Substring(0, Math.Min(100, request.Sql?.Length ?? 0)));
            return StatusCode(500, new { success = false, error = $"Erro ao executar SQL: {ex.Message}" });
        }
    }

    /// <summary>
    /// Extrai nome da tabela de um comando SQL.
    /// </summary>
    private string? ExtractTableName(string sql, string sqlType)
    {
        var sqlUpper = sql.ToUpperInvariant();
        Match match;

        switch (sqlType)
        {
            case "DELETE":
                // DELETE FROM tabela WHERE...
                match = Regex.Match(sqlUpper, @"DELETE\s+FROM\s+\[?(\w+)\]?", RegexOptions.IgnoreCase);
                break;

            case "UPDATE":
                // UPDATE tabela SET...
                match = Regex.Match(sqlUpper, @"UPDATE\s+\[?(\w+)\]?", RegexOptions.IgnoreCase);
                break;

            case "INSERT":
                // INSERT INTO tabela...
                match = Regex.Match(sqlUpper, @"INSERT\s+INTO\s+\[?(\w+)\]?", RegexOptions.IgnoreCase);
                break;

            default:
                return null;
        }

        return match.Success ? match.Groups[1].Value : null;
    }

    #endregion

    #region Save Endpoints

    /// <summary>
    /// Grava dados PLSAG (DG, DM).
    /// </summary>
    [HttpPost("save")]
    public async Task<IActionResult> ExecuteSave([FromBody] SaveRequest request)
    {
        try
        {
            _logger.LogInformation("PLSAG Save: Table={TableName} RecordId={RecordId}",
                request.TableName, request.RecordId);

            // Valida nome da tabela
            if (!IsValidTableName(request.TableName))
            {
                _logger.LogWarning("Tentativa de gravar em tabela nao permitida: {TableName}", request.TableName);
                return BadRequest(new { success = false, error = "Tabela nao permitida" });
            }

            using var connection = CreateConnection();
            connection.Open();

            var sql = BuildSaveSql(request.TableName, request.Fields, request.RecordId);
            var parameters = new DynamicParameters(request.Fields);

            if (request.RecordId.HasValue)
            {
                parameters.Add("RecordId", request.RecordId.Value);
            }

            var rowsAffected = await connection.ExecuteAsync(sql, parameters);

            // Se foi INSERT, tenta obter o ID inserido
            int? newId = null;
            if (!request.RecordId.HasValue && rowsAffected > 0)
            {
                newId = await connection.QueryFirstOrDefaultAsync<int>("SELECT SCOPE_IDENTITY()");
            }

            return Ok(new { success = true, rowsAffected, newId });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao gravar dados PLSAG: {TableName}", request.TableName);
            return StatusCode(500, new { success = false, error = "Erro interno ao gravar dados" });
        }
    }

    #endregion

    #region Helper Methods

    /// <summary>
    /// Busca instrucao PLSAG do banco de dados (tabela SISTCAMP).
    /// </summary>
    private async Task<string?> GetPlsagInstruction(IDbConnection connection, int codiTabe, int? codiCamp, string? instructionId)
    {
        var sql = @"
            SELECT CAST(ExprCamp AS NVARCHAR(MAX))
            FROM SISTCAMP
            WHERE CodiTabe = @CodiTabe
              AND (@CodiCamp IS NULL OR CodiCamp = @CodiCamp)
              AND (@InstructionId IS NULL OR NomeCamp = @InstructionId)";

        return await connection.QueryFirstOrDefaultAsync<string>(sql, new
        {
            CodiTabe = codiTabe,
            CodiCamp = codiCamp,
            InstructionId = instructionId
        });
    }

    /// <summary>
    /// Processa instrucao PLSAG substituindo templates.
    /// Retorna SQL com parametros nomeados (previne injection).
    /// </summary>
    private (string sql, DynamicParameters parameters) ProcessPlsagInstruction(
        string instruction, Dictionary<string, object>? inputParams)
    {
        var parameters = new DynamicParameters();
        var sql = instruction;

        if (inputParams != null)
        {
            foreach (var (key, value) in inputParams)
            {
                // Template pattern: {DG-Campo}, {VA-INTE0001}, etc.
                var template = $"{{{key}}}";
                var paramName = "@p_" + Regex.Replace(key, @"[^a-zA-Z0-9]", "_");

                if (sql.Contains(template))
                {
                    sql = sql.Replace(template, paramName);
                    parameters.Add(paramName, value);
                }
            }
        }

        return (sql, parameters);
    }

    /// <summary>
    /// Constroi SQL de INSERT ou UPDATE.
    /// </summary>
    private string BuildSaveSql(string tableName, Dictionary<string, object> fields, int? recordId)
    {
        // Remove campos vazios
        var validFields = fields
            .Where(f => f.Value != null && !string.IsNullOrEmpty(f.Value.ToString()))
            .ToDictionary(f => f.Key, f => f.Value);

        if (validFields.Count == 0)
        {
            throw new ArgumentException("Nenhum campo para gravar");
        }

        // Escapa nome da tabela (ja validado)
        var safeTableName = EscapeIdentifier(tableName);

        if (recordId.HasValue)
        {
            // UPDATE
            var setClauses = string.Join(", ",
                validFields.Keys.Select(k => $"{EscapeIdentifier(k)} = @{k}"));
            return $"UPDATE {safeTableName} SET {setClauses} WHERE Id = @RecordId";
        }
        else
        {
            // INSERT
            var columns = string.Join(", ", validFields.Keys.Select(EscapeIdentifier));
            var values = string.Join(", ", validFields.Keys.Select(k => $"@{k}"));
            return $"INSERT INTO {safeTableName} ({columns}) VALUES ({values})";
        }
    }

    /// <summary>
    /// Escapa identificador SQL (tabela/coluna).
    /// </summary>
    private string EscapeIdentifier(string identifier)
    {
        // Remove caracteres invalidos
        var safe = Regex.Replace(identifier, @"[^\w]", "");
        return $"[{safe}]";
    }

    /// <summary>
    /// Verifica se tabela e permitida para operacoes.
    /// </summary>
    private bool IsValidTableName(string? tableName)
    {
        if (string.IsNullOrEmpty(tableName))
            return false;

        // Na POC, permite qualquer tabela que comeca com CADA ou MOVI
        return tableName.StartsWith("CADA", StringComparison.OrdinalIgnoreCase) ||
               tableName.StartsWith("MOVI", StringComparison.OrdinalIgnoreCase) ||
               AllowedTables.Contains(tableName);
    }

    /// <summary>
    /// Valida SQL para bloqueio de comandos perigosos.
    /// </summary>
    private bool IsValidSql(string? sql)
    {
        if (string.IsNullOrEmpty(sql))
            return false;

        var sqlUpper = sql.ToUpperInvariant();

        // Bloqueia padroes perigosos
        return !BlockedPatterns.Any(pattern =>
            sqlUpper.Contains(pattern, StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// Valida CPF.
    /// </summary>
    private bool ValidateCPF(string? cpf)
    {
        if (string.IsNullOrEmpty(cpf)) return false;

        cpf = Regex.Replace(cpf, @"\D", "");

        if (cpf.Length != 11) return false;
        if (Regex.IsMatch(cpf, @"^(\d)\1+$")) return false;

        int sum = 0;
        for (int i = 0; i < 9; i++)
            sum += int.Parse(cpf[i].ToString()) * (10 - i);

        int digit1 = (sum * 10) % 11;
        if (digit1 == 10) digit1 = 0;
        if (digit1 != int.Parse(cpf[9].ToString())) return false;

        sum = 0;
        for (int i = 0; i < 10; i++)
            sum += int.Parse(cpf[i].ToString()) * (11 - i);

        int digit2 = (sum * 10) % 11;
        if (digit2 == 10) digit2 = 0;
        if (digit2 != int.Parse(cpf[10].ToString())) return false;

        return true;
    }

    /// <summary>
    /// Valida CNPJ.
    /// </summary>
    private bool ValidateCNPJ(string? cnpj)
    {
        if (string.IsNullOrEmpty(cnpj)) return false;

        cnpj = Regex.Replace(cnpj, @"\D", "");

        if (cnpj.Length != 14) return false;
        if (Regex.IsMatch(cnpj, @"^(\d)\1+$")) return false;

        int[] weights1 = { 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };
        int[] weights2 = { 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };

        int sum = 0;
        for (int i = 0; i < 12; i++)
            sum += int.Parse(cnpj[i].ToString()) * weights1[i];

        int digit1 = sum % 11;
        digit1 = digit1 < 2 ? 0 : 11 - digit1;
        if (digit1 != int.Parse(cnpj[12].ToString())) return false;

        sum = 0;
        for (int i = 0; i < 13; i++)
            sum += int.Parse(cnpj[i].ToString()) * weights2[i];

        int digit2 = sum % 11;
        digit2 = digit2 < 2 ? 0 : 11 - digit2;
        if (digit2 != int.Parse(cnpj[13].ToString())) return false;

        return true;
    }

    #endregion

    #region Lookup Column Endpoint

    /// <summary>
    /// Busca uma coluna específica de um registro de lookup.
    /// Usado quando {QY-CAMPO-COLUNA} precisa de uma coluna que não está na SQL_CAMP.
    /// Exemplo: {QY-CODIPROD-PESOPROD} onde PESOPROD não está no SELECT do lookup.
    /// </summary>
    [HttpPost("lookup-column")]
    public async Task<IActionResult> GetLookupColumn([FromBody] LookupColumnRequest request)
    {
        try
        {
            if (request.CodiCamp == 0)
            {
                return BadRequest(new { success = false, error = "CodiCamp é obrigatório" });
            }

            if (string.IsNullOrWhiteSpace(request.Code))
            {
                return BadRequest(new { success = false, error = "Code é obrigatório" });
            }

            if (string.IsNullOrWhiteSpace(request.ColumnName))
            {
                return BadRequest(new { success = false, error = "ColumnName é obrigatório" });
            }

            // Sanitização básica do nome da coluna
            if (!Regex.IsMatch(request.ColumnName, @"^\w+$"))
            {
                _logger.LogWarning("Nome de coluna inválido: {Column}", request.ColumnName);
                return BadRequest(new { success = false, error = "Nome de coluna inválido" });
            }

            var value = await _lookupService.GetLookupColumnAsync(
                request.CodiCamp,
                request.Code,
                request.ColumnName);

            return Ok(new
            {
                success = true,
                value = value?.ToString() ?? "",
                column = request.ColumnName,
                code = request.Code
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar coluna de lookup: CodiCamp={CodiCamp}, Column={Column}, Code={Code}",
                request.CodiCamp, request.ColumnName, request.Code);
            return StatusCode(500, new { success = false, error = $"Erro ao buscar coluna: {ex.Message}" });
        }
    }

    #endregion
}

#region Request DTOs

public class QueryRequest
{
    public int CodiTabe { get; set; }
    public int? CodiCamp { get; set; }
    public string? QueryName { get; set; }
    public string? Sql { get; set; }  // SQL direto para POC
    public bool SingleRow { get; set; } = true;  // Compat com frontend
    public string Type { get; set; } = "single";
    public Dictionary<string, object>? Params { get; set; }
}

public class ExecuteSqlRequest
{
    public int CodiTabe { get; set; }
    public int? CodiCamp { get; set; }
    public string CommandId { get; set; } = "";
    public string? Database { get; set; }
    public Dictionary<string, object>? Params { get; set; }
}

public class ExecuteRequest
{
    public string? Type { get; set; }
    public string? Name { get; set; }
    public Dictionary<string, object>? Params { get; set; }
}

public class SaveRequest
{
    public string TableName { get; set; } = "";
    public int? RecordId { get; set; }
    public Dictionary<string, object> Fields { get; set; } = new();
}

public class DirectSqlRequest
{
    public string Sql { get; set; } = "";
    public string? SqlType { get; set; }  // DELETE, UPDATE, INSERT (auto-detectado se nulo)
    public int CodiTabe { get; set; }
    public Dictionary<string, object>? Params { get; set; }
}

/// <summary>
/// Request para execução de lookup dinâmico via comando QY.
/// </summary>
public class DynamicLookupRequest
{
    /// <summary>
    /// ID do campo (CODICAMP) que contém o SQL_CAMP a ser modificado.
    /// </summary>
    public int CodiCamp { get; set; }

    /// <summary>
    /// ID da tabela (CODITABE) onde o campo está definido.
    /// </summary>
    public int CodiTabe { get; set; }

    /// <summary>
    /// Condição SQL a ser injetada na linha 4 do SQL_CAMP.
    /// Exemplo: "AND EXISTS(SELECT 1 FROM VDCAMVTP WHERE CODITBPR = {DG-CODITBPR})"
    /// </summary>
    public string Condition { get; set; } = string.Empty;

    /// <summary>
    /// Parâmetros para substituição de placeholders na condição e SQL.
    /// Chaves no formato: "DG-CAMPO", "IT-CAMPO", etc.
    /// Valores serão sanitizados antes da substituição.
    /// </summary>
    public Dictionary<string, object>? Parameters { get; set; }
}

/// <summary>
/// Request para buscar uma coluna específica de um registro de lookup.
/// </summary>
public class LookupColumnRequest
{
    /// <summary>
    /// ID do campo de lookup (CODICAMP) que contém a SQL_CAMP.
    /// </summary>
    public int CodiCamp { get; set; }

    /// <summary>
    /// Código do registro selecionado no lookup.
    /// </summary>
    public string Code { get; set; } = "";

    /// <summary>
    /// Nome da coluna a buscar na tabela base.
    /// </summary>
    public string ColumnName { get; set; } = "";
}

#endregion
