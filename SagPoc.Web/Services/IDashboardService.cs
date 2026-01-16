using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Interface para servico de dashboards
/// </summary>
public interface IDashboardService
{
    /// <summary>
    /// Obtem dados do dashboard para um modulo especifico
    /// </summary>
    /// <param name="moduleId">ID do modulo</param>
    /// <returns>Dados do dashboard ou null se nao existir</returns>
    Task<DashboardData?> GetDashboardByModuleAsync(int moduleId);

    /// <summary>
    /// Lista todos os dashboards disponiveis
    /// </summary>
    /// <returns>Lista de configuracoes de dashboard</returns>
    Task<List<DashboardConfigDto>> GetAvailableDashboardsAsync();
}
