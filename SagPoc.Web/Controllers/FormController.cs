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
    private readonly ILogger<FormController> _logger;

    public FormController(
        IMetadataService metadataService,
        ILookupService lookupService,
        ILogger<FormController> logger)
    {
        _metadataService = metadataService;
        _lookupService = lookupService;
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

            return View(formMetadata);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao renderizar formulário {TableId}", id);
            return View("Error", new ErrorViewModel { RequestId = HttpContext.TraceIdentifier });
        }
    }

    /// <summary>
    /// Popula as opções de lookup para campos T/IT que têm SQL_CAMP definido.
    /// </summary>
    private async Task PopulateLookupOptionsAsync(List<FieldMetadata> fields)
    {
        var lookupFields = fields.Where(f =>
            (f.CompCamp?.ToUpper() == "T" || f.CompCamp?.ToUpper() == "IT") &&
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
}
