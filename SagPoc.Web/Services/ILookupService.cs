using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Interface para serviço de lookup de campos T/IT.
/// Executa SQL_CAMP para popular combos dinâmicos.
/// </summary>
public interface ILookupService
{
    /// <summary>
    /// Executa uma query SQL_CAMP e retorna os itens de lookup.
    /// </summary>
    /// <param name="sql">Query SQL do campo (SQL_CAMP)</param>
    /// <returns>Lista de LookupItem com Key (coluna 0) e Value (coluna 1)</returns>
    Task<List<LookupItem>> ExecuteLookupQueryAsync(string sql);
}
