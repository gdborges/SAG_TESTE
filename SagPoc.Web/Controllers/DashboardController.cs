using Microsoft.AspNetCore.Mvc;
using SagPoc.Web.Models;
using SagPoc.Web.Services;

namespace SagPoc.Web.Controllers;

/// <summary>
/// Controller REST para API de Dashboards
/// Endpoint: /api/dashboard
/// </summary>
[Route("api/dashboard")]
[ApiController]
public class DashboardController : ControllerBase
{
    private readonly IDashboardService _dashboardService;
    private readonly ILogger<DashboardController> _logger;

    public DashboardController(IDashboardService dashboardService, ILogger<DashboardController> logger)
    {
        _dashboardService = dashboardService;
        _logger = logger;
    }

    /// <summary>
    /// Obtem dados do dashboard para um modulo especifico
    /// GET /api/dashboard/{moduleId}
    /// </summary>
    /// <param name="moduleId">ID do modulo SAG</param>
    /// <param name="startDate">Data inicial (opcional, para filtros futuros)</param>
    /// <param name="endDate">Data final (opcional, para filtros futuros)</param>
    /// <returns>Dados do dashboard formatados para Vision</returns>
    [HttpGet("{moduleId}")]
    public async Task<IActionResult> GetDashboard(
        int moduleId,
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null)
    {
        _logger.LogInformation("Buscando dashboard para modulo {ModuleId}", moduleId);

        try
        {
            var data = await _dashboardService.GetDashboardByModuleAsync(moduleId);

            if (data == null)
            {
                return NotFound(new DashboardResponse
                {
                    Success = false,
                    Error = $"Dashboard nao encontrado para modulo {moduleId}"
                });
            }

            return Ok(new DashboardResponse
            {
                Success = true,
                Data = data
            });
        }
        catch (NotImplementedException ex)
        {
            _logger.LogWarning(ex, "Dashboard nao implementado para modulo {ModuleId}", moduleId);
            return StatusCode(501, new DashboardResponse
            {
                Success = false,
                Error = ex.Message
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar dashboard para modulo {ModuleId}", moduleId);
            return StatusCode(500, new DashboardResponse
            {
                Success = false,
                Error = ex.Message
            });
        }
    }

    /// <summary>
    /// Lista todos os dashboards disponiveis
    /// GET /api/dashboard/available
    /// </summary>
    /// <returns>Lista de dashboards configurados</returns>
    [HttpGet("available")]
    public async Task<IActionResult> GetAvailableDashboards()
    {
        _logger.LogInformation("Listando dashboards disponiveis");

        try
        {
            var dashboards = await _dashboardService.GetAvailableDashboardsAsync();

            return Ok(new
            {
                success = true,
                data = dashboards,
                total = dashboards.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao listar dashboards disponiveis");
            return StatusCode(500, new
            {
                success = false,
                error = ex.Message
            });
        }
    }
}
