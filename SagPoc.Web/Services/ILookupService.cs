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

    /// <summary>
    /// Executa uma query SQL_CAMP e retorna TODOS os dados de cada registro.
    /// Usado para lookups que precisam preencher campos IE associados.
    /// Similar ao comportamento do TDBLookNume no Delphi.
    /// </summary>
    /// <param name="sql">Query SQL do campo (SQL_CAMP)</param>
    /// <returns>LookupQueryResult com todos os registros e colunas</returns>
    Task<LookupQueryResult> ExecuteLookupQueryFullAsync(string sql);
}
