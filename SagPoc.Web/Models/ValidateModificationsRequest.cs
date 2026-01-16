namespace SagPoc.Web.Models;

/// <summary>
/// Request para validação de modificações em campos protegidos.
/// </summary>
public class ValidateModificationsRequest
{
    /// <summary>
    /// ID da tabela (CodiTabe)
    /// </summary>
    public int TableId { get; set; }

    /// <summary>
    /// Dados originais do registro (antes da edição)
    /// </summary>
    public Dictionary<string, object?> OriginalData { get; set; } = new();

    /// <summary>
    /// Dados novos do registro (após a edição)
    /// </summary>
    public Dictionary<string, object?> NewData { get; set; } = new();
}
