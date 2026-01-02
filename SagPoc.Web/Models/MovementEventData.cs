namespace SagPoc.Web.Models;

/// <summary>
/// Dados de eventos de movimento para o sistema PLSAG.
/// Armazena as instruções do ciclo de vida CRUD de movimentos.
/// Eventos são definidos como campos virtuais no SISTCAMP do formulário pai.
/// </summary>
public class MovementEventData
{
    /// <summary>
    /// Código da tabela de movimento
    /// </summary>
    public int MovementCodiTabe { get; set; }

    /// <summary>
    /// Código da tabela pai (cabeçalho)
    /// </summary>
    public int ParentCodiTabe { get; set; }

    /// <summary>
    /// Instruções executadas antes de qualquer operação CRUD.
    /// Campo virtual: AnteIAE_Movi_{CodiTabe}
    /// </summary>
    public string AnteIAEMoviInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas antes de INSERT.
    /// Campo virtual: AnteIncl_{CodiTabe}
    /// </summary>
    public string AnteInclInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas antes de UPDATE.
    /// Campo virtual: AnteAlte_{CodiTabe}
    /// </summary>
    public string AnteAlteInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas antes de DELETE.
    /// Campo virtual: AnteExcl_{CodiTabe}
    /// </summary>
    public string AnteExclInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas depois de qualquer operação CRUD.
    /// Campo virtual: DepoIAE_Movi_{CodiTabe}
    /// </summary>
    public string DepoIAEMoviInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas depois de INSERT.
    /// Campo virtual: DepoIncl_{CodiTabe}
    /// </summary>
    public string DepoInclInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas depois de UPDATE.
    /// Campo virtual: DepoAlte_{CodiTabe}
    /// </summary>
    public string DepoAlteInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas depois de DELETE.
    /// Campo virtual: DepoExcl_{CodiTabe}
    /// </summary>
    public string DepoExclInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas ao carregar/atualizar grid.
    /// Campo virtual: AtuaGrid_{CodiTabe}
    /// </summary>
    public string AtuaGridInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Instruções executadas ao abrir modal de inserção/edição.
    /// Campo virtual: ShowPai_Filh_{CodiTabe}
    /// </summary>
    public string ShowPaiFilhInstructions { get; set; } = string.Empty;

    /// <summary>
    /// Indica se existem eventos de movimento configurados.
    /// </summary>
    public bool HasEvents =>
        !string.IsNullOrWhiteSpace(AnteIAEMoviInstructions) ||
        !string.IsNullOrWhiteSpace(AnteInclInstructions) ||
        !string.IsNullOrWhiteSpace(AnteAlteInstructions) ||
        !string.IsNullOrWhiteSpace(AnteExclInstructions) ||
        !string.IsNullOrWhiteSpace(DepoIAEMoviInstructions) ||
        !string.IsNullOrWhiteSpace(DepoInclInstructions) ||
        !string.IsNullOrWhiteSpace(DepoAlteInstructions) ||
        !string.IsNullOrWhiteSpace(DepoExclInstructions) ||
        !string.IsNullOrWhiteSpace(AtuaGridInstructions) ||
        !string.IsNullOrWhiteSpace(ShowPaiFilhInstructions);
}
