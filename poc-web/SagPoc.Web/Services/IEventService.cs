using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Interface para o serviço de eventos PLSAG.
/// Carrega eventos do banco de dados (SISTTABE/SISTCAMP).
/// </summary>
public interface IEventService
{
    /// <summary>
    /// Carrega os eventos do formulário (ciclo de vida).
    /// Fonte: SISTTABE (ShowTabe, LancTabe, EGraTabe, AposTabe)
    /// </summary>
    /// <param name="codiTabe">Código da tabela/formulário</param>
    /// <returns>Dados de eventos do formulário</returns>
    Task<FormEventData> GetFormEventsAsync(int codiTabe);

    /// <summary>
    /// Carrega os eventos dos campos.
    /// Fonte: SISTCAMP (ExprCamp, EPerCamp, Exp1Camp)
    /// </summary>
    /// <param name="codiTabe">Código da tabela/formulário</param>
    /// <returns>Dicionário de CodiCamp -> FieldEventData</returns>
    Task<Dictionary<int, FieldEventData>> GetFieldEventsAsync(int codiTabe);
}
