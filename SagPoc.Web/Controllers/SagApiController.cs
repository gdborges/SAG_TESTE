using Microsoft.AspNetCore.Mvc;
using Dapper;
using SagPoc.Web.Services.Database;

namespace SagPoc.Web.Controllers;

/// <summary>
/// API controller para integração com Vision Web (frontend Vue).
/// Expõe informações sobre forms SAG disponíveis para o menu lateral.
/// </summary>
[ApiController]
[Route("api/sag")]
public class SagApiController : ControllerBase
{
    private readonly IDbProvider _dbProvider;
    private readonly ILogger<SagApiController> _logger;

    public SagApiController(IDbProvider dbProvider, ILogger<SagApiController> logger)
    {
        _dbProvider = dbProvider;
        _logger = logger;
    }

    /// <summary>
    /// Retorna lista de formulários SAG disponíveis para exibição no menu Vue.
    /// Consulta SISTTABE para obter tabelas que têm formulários configurados.
    /// </summary>
    [HttpGet("available-forms")]
    public async Task<IActionResult> GetAvailableForms()
    {
        try
        {
            _logger.LogInformation("Buscando forms SAG disponíveis");

            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            // Query para buscar tabelas disponíveis
            // Filtra por tabelas que têm campos definidos (SISTCAMP) e não são auxiliares
            // Usamos aspas para preservar case dos aliases no Oracle
            var sql = @"
                SELECT DISTINCT
                    t.CODITABE as ""TableId"",
                    t.NOMETABE as ""Name"",
                    t.SIGLTABE as ""Sigla"",
                    t.MENUTABE as ""MenuName"",
                    CASE
                        WHEN t.GETATABE = 1 THEN 'parent'
                        WHEN t.CABETABE > 0 THEN 'child'
                        ELSE 'standalone'
                    END as ""TableType"",
                    t.GETATABE as ""HasChildren"",
                    t.CABETABE as ""ParentTableId""
                FROM SISTTABE t
                WHERE EXISTS (
                    SELECT 1 FROM SISTCAMP c
                    WHERE c.CODITABE = t.CODITABE
                )
                AND t.CODITABE > 0
                AND t.NOMETABE IS NOT NULL
                ORDER BY t.NOMETABE";

            var tables = await connection.QueryAsync<dynamic>(sql);

            var forms = new List<SagFormInfo>();
            int tagCounter = 1;

            foreach (var row in tables)
            {
                // Cast para dicionário para acesso seguro (Oracle retorna case exato do alias)
                var dict = (IDictionary<string, object>)row;

                var tableId = Convert.ToInt32(dict["TableId"] ?? 0);
                var name = dict["Name"]?.ToString()?.Trim() ?? $"Tabela {tableId}";
                var sigla = dict["Sigla"]?.ToString()?.Trim() ?? "";
                var menuName = dict["MenuName"]?.ToString()?.Trim();
                var tableType = dict["TableType"]?.ToString() ?? "standalone";
                var parentTableId = dict["ParentTableId"] != null ? Convert.ToInt32(dict["ParentTableId"]) : 0;

                // Só inclui tabelas standalone ou parent no menu principal
                // Tabelas child (movimentos) não aparecem como item de menu
                if (parentTableId > 0)
                    continue;

                forms.Add(new SagFormInfo
                {
                    TableId = tableId,
                    Name = !string.IsNullOrEmpty(menuName) ? menuName : name,
                    Description = name,
                    Tag = $"SAG{tagCounter:D3}",
                    Sigla = sigla,
                    ModuleId = "SAG",
                    TableType = tableType
                });

                tagCounter++;
            }

            _logger.LogInformation("Encontrados {Count} forms SAG disponíveis", forms.Count);

            return Ok(new
            {
                success = true,
                data = forms,
                total = forms.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar forms SAG disponíveis");
            return StatusCode(500, new
            {
                success = false,
                message = "Erro ao buscar formulários: " + ex.Message
            });
        }
    }

    /// <summary>
    /// Retorna informações sobre um form específico.
    /// </summary>
    [HttpGet("form/{tableId}")]
    public async Task<IActionResult> GetFormInfo(int tableId)
    {
        try
        {
            _logger.LogInformation("Buscando informações do form {TableId}", tableId);

            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var sql = @"
                SELECT
                    t.CODITABE as ""TableId"",
                    t.NOMETABE as ""Name"",
                    t.SIGLTABE as ""Sigla"",
                    t.MENUTABE as ""MenuName"",
                    t.GETATABE as ""HasChildren"",
                    t.CABETABE as ""ParentTableId"",
                    t.GRAVTABE as ""GravTabe""
                FROM SISTTABE t
                WHERE t.CODITABE = :TableId";

            var result = await connection.QueryFirstOrDefaultAsync<dynamic>(sql, new { TableId = tableId });

            if (result == null)
            {
                return NotFound(new { success = false, message = $"Tabela {tableId} não encontrada" });
            }

            // Cast para dicionário
            var dict = (IDictionary<string, object>)result;

            // Conta campos
            var fieldCountSql = "SELECT COUNT(*) FROM SISTCAMP WHERE CODITABE = :TableId";
            var fieldCount = await connection.QueryFirstOrDefaultAsync<int>(fieldCountSql, new { TableId = tableId });

            // Conta movimentos
            var movementCountSql = "SELECT COUNT(*) FROM SISTTABE WHERE CABETABE = :TableId";
            var movementCount = await connection.QueryFirstOrDefaultAsync<int>(movementCountSql, new { TableId = tableId });

            var info = new
            {
                tableId = Convert.ToInt32(dict["TableId"]),
                name = dict["Name"]?.ToString()?.Trim(),
                sigla = dict["Sigla"]?.ToString()?.Trim(),
                menuName = dict["MenuName"]?.ToString()?.Trim(),
                moduleId = "SAG",
                hasChildren = Convert.ToInt32(dict["HasChildren"] ?? 0) == 1,
                parentTableId = dict["ParentTableId"] != null && Convert.ToInt32(dict["ParentTableId"]) > 0
                    ? Convert.ToInt32(dict["ParentTableId"])
                    : (int?)null,
                gravTabe = dict["GravTabe"]?.ToString()?.Trim(),
                fieldCount = fieldCount,
                movementCount = movementCount,
                embedUrl = $"/Form/RenderEmbedded/{tableId}",
                fullUrl = $"/Form/Render/{tableId}"
            };

            return Ok(new { success = true, data = info });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar informações do form {TableId}", tableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Health check para verificar se o SAG está rodando.
    /// </summary>
    [HttpGet("health")]
    public IActionResult Health()
    {
        return Ok(new
        {
            status = "healthy",
            provider = _dbProvider.ProviderName,
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Retorna os módulos disponíveis no SAG.
    /// Como não há coluna MODUTABE no Oracle, retorna apenas SAG como módulo único.
    /// </summary>
    [HttpGet("modules")]
    public async Task<IActionResult> GetModules()
    {
        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            // Conta total de tabelas com campos definidos
            var sql = @"
                SELECT COUNT(DISTINCT t.CODITABE) as TableCount
                FROM SISTTABE t
                WHERE EXISTS (
                    SELECT 1 FROM SISTCAMP c
                    WHERE c.CODITABE = t.CODITABE
                )
                AND t.CODITABE > 0
                AND t.CABETABE = 0";  // Só tabelas principais (não movimentos)

            var tableCount = await connection.QueryFirstOrDefaultAsync<int>(sql);

            var result = new[]
            {
                new { moduleId = "SAG", tableCount = tableCount }
            };

            return Ok(new { success = true, data = result });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar módulos");
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }
}

/// <summary>
/// DTO para informações de form SAG.
/// </summary>
public class SagFormInfo
{
    public int TableId { get; set; }
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public string Tag { get; set; } = "";
    public string Sigla { get; set; } = "";
    public string ModuleId { get; set; } = "";
    public string TableType { get; set; } = "standalone";
}
