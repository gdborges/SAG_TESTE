namespace SagPoc.Web.Models;

/// <summary>
/// Dados de eventos de um campo para o sistema PLSAG.
/// Armazena as instruções que serão executadas em cada evento.
/// </summary>
public class FieldEventData
{
    /// <summary>
    /// Código do campo (CodiCamp)
    /// </summary>
    public int CodiCamp { get; set; }

    /// <summary>
    /// Nome do campo (NomeCamp)
    /// </summary>
    public string NomeCamp { get; set; } = string.Empty;

    /// <summary>
    /// Instruções PLSAG para OnExit/OnBlur.
    /// Fonte: ExprCamp + EPerCamp mesclados
    /// </summary>
    public string OnExitInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções PLSAG para OnClick (botões, checkboxes).
    /// Fonte: ExprCamp + EPerCamp mesclados
    /// </summary>
    public string OnClickInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções PLSAG para duplo clique (grids).
    /// Fonte: Exp1Camp + EPerCamp mesclados
    /// </summary>
    public string OnDblClickInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Indica se o campo é obrigatório (para validação OnChange).
    /// </summary>
    public bool IsRequired { get; set; }

    /// <summary>
    /// Indica se este campo possui algum evento configurado.
    /// </summary>
    public bool HasEvents =>
        !string.IsNullOrWhiteSpace(OnExitInstructions) ||
        !string.IsNullOrWhiteSpace(OnClickInstructions) ||
        !string.IsNullOrWhiteSpace(OnDblClickInstructions);
}
