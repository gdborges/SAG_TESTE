using SagPoc.Web.Models;

namespace SagPoc.Web.Services
{
    /// <summary>
    /// Interface para o serviço de módulos e janelas do SAG
    /// </summary>
    public interface IModuleService
    {
        /// <summary>
        /// Retorna a lista de módulos disponíveis para o usuário/empresa atual
        /// Para a POC, usa hardcoded U99E01
        /// </summary>
        Task<List<ModuleDto>> GetModulesAsync();

        /// <summary>
        /// Retorna as janelas de um módulo específico, agrupadas por menu
        /// </summary>
        /// <param name="moduleId">Código do módulo (CodiProd)</param>
        Task<List<MenuGroupDto>> GetWindowsByModuleAsync(int moduleId);

        /// <summary>
        /// Retorna as janelas de um módulo como lista plana (sem agrupamento)
        /// </summary>
        /// <param name="moduleId">Código do módulo (CodiProd)</param>
        Task<List<WindowDto>> GetWindowsFlatAsync(int moduleId);
    }
}
