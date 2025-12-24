namespace SagPoc.Web.Models;

/// <summary>
/// Dados de eventos do formulário para o sistema PLSAG.
/// Armazena as instruções do ciclo de vida do formulário.
/// </summary>
public class FormEventData
{
    /// <summary>
    /// Código da tabela/formulário (CodiTabe)
    /// </summary>
    public int CodiTabe { get; set; }

    /// <summary>
    /// Nome da tabela (NomeTabe)
    /// </summary>
    public string NomeTabe { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas no FormShow (após campos inicializados).
    /// Fonte: SISTTABE.ShowTabe + EPerTabe mesclados
    /// </summary>
    public string ShowTabeInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas antes de gravar (BtnConfClick).
    /// Fonte: SISTTABE.LancTabe + EPerTabe mesclados
    /// </summary>
    public string LancTabeInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas após gravar.
    /// Fonte: SISTTABE.EGraTabe + EPerTabe mesclados
    /// </summary>
    public string EGraTabeInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas no final (após tudo).
    /// Fonte: SISTTABE.AposTabe + EPerTabe mesclados
    /// </summary>
    public string AposTabeInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas antes de criar campos (AnteCria).
    /// Fonte: SISTCAMP.ExprCamp onde NomeCamp='AnteCria'
    /// </summary>
    public string AntecriaInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas depois de criar campos (DepoCria).
    /// Fonte: SISTCAMP.ExprCamp onde NomeCamp='DepoCria'
    /// </summary>
    public string DepocriaInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Expressões permanentes da tabela (usado internamente para merge).
    /// </summary>
    internal string EPerTabeInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Indica se existem eventos de formulário configurados.
    /// </summary>
    public bool HasEvents =>
        !string.IsNullOrWhiteSpace(ShowTabeInstructions) ||
        !string.IsNullOrWhiteSpace(LancTabeInstructions) ||
        !string.IsNullOrWhiteSpace(EGraTabeInstructions) ||
        !string.IsNullOrWhiteSpace(AposTabeInstructions) ||
        !string.IsNullOrWhiteSpace(AntecriaInstructions) ||
        !string.IsNullOrWhiteSpace(DepocriaInstructions);
}
