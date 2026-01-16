namespace SagPoc.Web.Services.Context;

/// <summary>
/// Contexto de sessão do SAG.
/// Contém informações do usuário, empresa e módulo atual.
/// Equivalente às variáveis globais do Delphi (CodiUsua, CodiEmpr, CodiModu).
/// </summary>
public class SagContext
{
    /// <summary>
    /// ID do usuário logado (CODIUSUA).
    /// </summary>
    public int UsuarioId { get; set; }

    /// <summary>
    /// Nome do usuário (para exibição/audit).
    /// </summary>
    public string? UsuarioNome { get; set; }

    /// <summary>
    /// ID da empresa ativa (CODIEMPR).
    /// </summary>
    public int EmpresaId { get; set; }

    /// <summary>
    /// Nome/razão social da empresa (para exibição).
    /// </summary>
    public string? EmpresaNome { get; set; }

    /// <summary>
    /// ID do módulo ativo (CODIMODU).
    /// </summary>
    public int ModuloId { get; set; }

    /// <summary>
    /// Nome do módulo (para exibição).
    /// </summary>
    public string? ModuloNome { get; set; }

    /// <summary>
    /// Indica se o contexto foi inicializado com valores válidos.
    /// </summary>
    public bool IsInitialized => UsuarioId > 0 && EmpresaId > 0;

    /// <summary>
    /// Timestamp de quando o contexto foi criado.
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Dados adicionais do contexto (extensível).
    /// </summary>
    public Dictionary<string, object?> Extra { get; set; } = new();

    public override string ToString()
    {
        return $"SagContext[Usuario={UsuarioId}, Empresa={EmpresaId}, Modulo={ModuloId}]";
    }
}
