using Microsoft.AspNetCore.Mvc;
using SagPoc.Web.Models;
using SagPoc.Web.Services;

namespace SagPoc.Web.Controllers;

/// <summary>
/// Controller para renderização dinâmica de formulários.
/// </summary>
public class FormController : Controller
{
    private readonly IMetadataService _metadataService;
    private readonly ILookupService _lookupService;
    private readonly IConsultaService _consultaService;
    private readonly ILogger<FormController> _logger;

    public FormController(
        IMetadataService metadataService,
        ILookupService lookupService,
        IConsultaService consultaService,
        ILogger<FormController> logger)
    {
        _metadataService = metadataService;
        _lookupService = lookupService;
        _consultaService = consultaService;
        _logger = logger;
    }

    /// <summary>
    /// Lista os formulários disponíveis.
    /// </summary>
    public async Task<IActionResult> Index()
    {
        try
        {
            var tables = await _metadataService.GetAvailableTablesAsync();
            return View(tables);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao listar formulários");
            return View("Error", new ErrorViewModel { RequestId = HttpContext.TraceIdentifier });
        }
    }

    /// <summary>
    /// Renderiza um formulário dinamicamente baseado nos metadados.
    /// </summary>
    /// <param name="id">ID da tabela (CodiTabe)</param>
    public async Task<IActionResult> Render(int id)
    {
        try
        {
            _logger.LogInformation("Renderizando formulário {TableId}", id);

            var formMetadata = await _metadataService.GetFormMetadataAsync(id);

            if (formMetadata.Fields.Count == 0)
            {
                _logger.LogWarning("Nenhum campo encontrado para tabela {TableId}", id);
                return NotFound($"Nenhum campo encontrado para a tabela {id}");
            }

            // Popular LookupOptions para campos T/IT com SQL_CAMP
            await PopulateLookupOptionsAsync(formMetadata.Fields);

            // Carrega metadados da tabela e consultas
            var tableMetadata = await _consultaService.GetTableMetadataAsync(id);
            var consultas = await _consultaService.GetConsultasByTableAsync(id);

            // Monta o ViewModel
            var viewModel = new FormRenderViewModel
            {
                Form = formMetadata,
                Table = tableMetadata,
                Consultas = consultas
            };

            return View(viewModel);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao renderizar formulário {TableId}", id);
            return View("Error", new ErrorViewModel { RequestId = HttpContext.TraceIdentifier });
        }
    }

    /// <summary>
    /// Popula as opções de lookup para campos L/T/IT/IL que têm SQL_CAMP definido.
    /// </summary>
    private async Task PopulateLookupOptionsAsync(List<FieldMetadata> fields)
    {
        var lookupTypes = new[] { "L", "T", "IT", "IL" };
        var lookupFields = fields.Where(f =>
            lookupTypes.Contains(f.CompCamp?.ToUpper()) &&
            !string.IsNullOrEmpty(f.SqlCamp));

        foreach (var field in lookupFields)
        {
            try
            {
                field.LookupOptions = await _lookupService.ExecuteLookupQueryAsync(field.SqlCamp!);
                _logger.LogDebug("Campo {FieldName}: {Count} opções carregadas",
                    field.NomeCamp, field.LookupOptions?.Count ?? 0);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Erro ao carregar lookup para campo {FieldName}", field.NomeCamp);
                field.LookupOptions = new List<LookupItem>();
            }
        }
    }

    /// <summary>
    /// Retorna os campos de um formulário em JSON (para debug/API).
    /// </summary>
    /// <param name="id">ID da tabela</param>
    [HttpGet]
    public async Task<IActionResult> Fields(int id)
    {
        try
        {
            var fields = await _metadataService.GetFieldsByTableAsync(id);
            return Json(fields);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter campos da tabela {TableId}", id);
            return StatusCode(500, ex.Message);
        }
    }

    #region API Endpoints para Consulta/CRUD

    /// <summary>
    /// Retorna as consultas disponíveis para uma tabela.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetConsultas(int tableId)
    {
        try
        {
            var consultas = await _consultaService.GetConsultasByTableAsync(tableId);
            return Json(consultas.Select(c => new
            {
                c.CodiCons,
                c.NomeCons,
                c.BuscCons,
                Columns = c.GetColumns()
            }));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter consultas da tabela {TableId}", tableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Executa uma consulta com filtros e paginação.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> ExecuteConsulta([FromBody] GridFilterRequest request)
    {
        try
        {
            var result = await _consultaService.ExecuteConsultaAsync(request);
            return Json(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar consulta {ConsultaId}", request.ConsultaId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Obtém um registro pelo ID.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetRecord(int tableId, int recordId)
    {
        try
        {
            var record = await _consultaService.GetRecordByIdAsync(tableId, recordId);
            if (record == null)
                return NotFound(new { error = "Registro não encontrado" });

            return Json(record);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter registro {RecordId} da tabela {TableId}", recordId, tableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Salva (insere ou atualiza) um registro.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> SaveRecord([FromBody] SaveRecordRequest request)
    {
        try
        {
            var result = await _consultaService.SaveRecordAsync(request);
            if (result.Success)
                return Json(result);
            else
                return BadRequest(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao salvar registro na tabela {TableId}", request.TableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Exclui um registro.
    /// </summary>
    [HttpDelete]
    public async Task<IActionResult> DeleteRecord(int tableId, int recordId)
    {
        try
        {
            var result = await _consultaService.DeleteRecordAsync(tableId, recordId);
            if (result.Success)
                return Json(result);
            else
                return BadRequest(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao excluir registro {RecordId} da tabela {TableId}", recordId, tableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    #endregion
}
