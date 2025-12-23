namespace SagPoc.Web.Models;

/// <summary>
/// Request para executar uma consulta com filtros.
/// </summary>
public class GridFilterRequest
{
    /// <summary>
    /// ID da tabela
    /// </summary>
    public int TableId { get; set; }

    /// <summary>
    /// ID da consulta (CODICONS)
    /// </summary>
    public int ConsultaId { get; set; }

    /// <summary>
    /// Filtros a serem aplicados
    /// </summary>
    public List<GridFilter> Filters { get; set; } = new();

    /// <summary>
    /// Campo para ordenação
    /// </summary>
    public string? SortField { get; set; }

    /// <summary>
    /// Direção da ordenação (ASC ou DESC)
    /// </summary>
    public string SortDirection { get; set; } = "ASC";

    /// <summary>
    /// Página atual (1-based)
    /// </summary>
    public int Page { get; set; } = 1;

    /// <summary>
    /// Quantidade de registros por página
    /// </summary>
    public int PageSize { get; set; } = 20;
}

/// <summary>
/// Representa um filtro individual.
/// </summary>
public class GridFilter
{
    /// <summary>
    /// Nome do campo
    /// </summary>
    public string Field { get; set; } = string.Empty;

    /// <summary>
    /// Condição: startswith, contains, equals, notequals
    /// </summary>
    public string Condition { get; set; } = "contains";

    /// <summary>
    /// Valor a filtrar
    /// </summary>
    public string Value { get; set; } = string.Empty;

    /// <summary>
    /// Gera a cláusula SQL para este filtro.
    /// </summary>
    public string ToSqlCondition()
    {
        // Sanitiza o valor para evitar SQL injection
        var safeValue = Value.Replace("'", "''");

        return Condition.ToLower() switch
        {
            "startswith" => $"LIKE '{safeValue}%'",
            "contains" => $"LIKE '%{safeValue}%'",
            "equals" => $"= '{safeValue}'",
            "notequals" => $"<> '{safeValue}'",
            "greaterthan" => $"> '{safeValue}'",
            "lessthan" => $"< '{safeValue}'",
            _ => $"LIKE '%{safeValue}%'"
        };
    }
}
