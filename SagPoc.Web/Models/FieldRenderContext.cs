namespace SagPoc.Web.Models;

/// <summary>
/// Contexto para renderizacao de um campo, incluindo informacoes sobre a linha.
/// </summary>
public class FieldRenderContext
{
    /// <summary>
    /// O campo a ser renderizado.
    /// </summary>
    public FieldMetadata Field { get; set; } = null!;

    /// <summary>
    /// Indica se este campo esta sozinho na linha (deve usar max-width).
    /// </summary>
    public bool IsSingleInRow { get; set; }
}
