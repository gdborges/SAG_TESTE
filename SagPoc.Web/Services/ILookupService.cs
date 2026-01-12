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

    /// <summary>
    /// Busca um registro específico pelo código digitado.
    /// Usado quando o usuário digita diretamente no campo lookup (comportamento TDBLookNume).
    /// </summary>
    /// <param name="sql">Query SQL do campo (SQL_CAMP)</param>
    /// <param name="code">Código digitado pelo usuário</param>
    /// <returns>LookupRecord com dados completos ou null se não encontrado</returns>
    Task<LookupRecord?> LookupByCodeAsync(string sql, string code);

    /// <summary>
    /// Executa lookup com injeção dinâmica de condição SQL na linha 4.
    /// Usado pelo comando PLSAG QY-CAMPO-CONDIÇÃO.
    /// </summary>
    /// <param name="sqlLines">Array de linhas do SQL_CAMP</param>
    /// <param name="condition">Condição a injetar na linha 4 (ex: "AND EXISTS(SELECT 1 FROM T)")</param>
    /// <param name="parameters">Parâmetros para substituir placeholders (ex: {DG-CODITBPR} → 1682)</param>
    /// <returns>Lista de LookupItem com Key (coluna 0) e Value (coluna 1)</returns>
    Task<List<LookupItem>> ExecuteDynamicLookupAsync(
        string[] sqlLines,
        string condition,
        Dictionary<string, object> parameters);
}
