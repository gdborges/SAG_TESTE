namespace SagPoc.Web.Models;

/// <summary>
/// Response com dados paginados do grid.
/// </summary>
public class GridDataResponse
{
    /// <summary>
    /// Dados da página atual
    /// </summary>
    public List<Dictionary<string, object?>> Data { get; set; } = new();

    /// <summary>
    /// Total de registros (sem paginação)
    /// </summary>
    public int TotalRecords { get; set; }

    /// <summary>
    /// Total de páginas
    /// </summary>
    public int TotalPages { get; set; }

    /// <summary>
    /// Página atual (1-based)
    /// </summary>
    public int CurrentPage { get; set; }

    /// <summary>
    /// Tamanho da página
    /// </summary>
    public int PageSize { get; set; }

    /// <summary>
    /// Colunas da consulta
    /// </summary>
    public List<GridColumn> Columns { get; set; } = new();

    /// <summary>
    /// Indica se há página anterior
    /// </summary>
    public bool HasPreviousPage => CurrentPage > 1;

    /// <summary>
    /// Indica se há próxima página
    /// </summary>
    public bool HasNextPage => CurrentPage < TotalPages;
}
