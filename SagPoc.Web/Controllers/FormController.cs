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
    private readonly ILogger<FormController> _logger;

    public FormController(IMetadataService metadataService, ILogger<FormController> logger)
    {
        _metadataService = metadataService;
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

            return View(formMetadata);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao renderizar formulário {TableId}", id);
            return View("Error", new ErrorViewModel { RequestId = HttpContext.TraceIdentifier });
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
