using Microsoft.AspNetCore.Mvc;
using SagPoc.Web.Services;

namespace SagPoc.Web.Controllers;

/// <summary>
/// Controller de API para módulos e janelas do SAG.
/// Endpoints para consumo pelo Vision.
/// </summary>
[Route("api/modules")]
[ApiController]
public class ModulesController : ControllerBase
{
    private readonly IModuleService _moduleService;
    private readonly ILogger<ModulesController> _logger;

    public ModulesController(IModuleService moduleService, ILogger<ModulesController> logger)
    {
        _moduleService = moduleService;
        _logger = logger;
    }

    /// <summary>
    /// Retorna a lista de módulos disponíveis
    /// GET /api/modules
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetModules()
    {
        try
        {
            var modules = await _moduleService.GetModulesAsync();
            return Ok(new { success = true, data = modules });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar módulos");
            return StatusCode(500, new { success = false, message = "Erro ao buscar módulos" });
        }
    }

    /// <summary>
    /// Retorna as janelas de um módulo específico, agrupadas por menu
    /// GET /api/modules/{moduleId}/windows
    /// </summary>
    [HttpGet("{moduleId:int}/windows")]
    public async Task<IActionResult> GetWindows(int moduleId)
    {
        try
        {
            var windows = await _moduleService.GetWindowsByModuleAsync(moduleId);
            return Ok(new { success = true, data = windows });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar janelas do módulo {ModuleId}", moduleId);
            return StatusCode(500, new { success = false, message = "Erro ao buscar janelas" });
        }
    }

    /// <summary>
    /// Retorna as janelas de um módulo como lista plana (sem agrupamento)
    /// GET /api/modules/{moduleId}/windows/flat
    /// </summary>
    [HttpGet("{moduleId:int}/windows/flat")]
    public async Task<IActionResult> GetWindowsFlat(int moduleId)
    {
        try
        {
            var windows = await _moduleService.GetWindowsFlatAsync(moduleId);
            return Ok(new { success = true, data = windows });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar janelas do módulo {ModuleId}", moduleId);
            return StatusCode(500, new { success = false, message = "Erro ao buscar janelas" });
        }
    }
}
