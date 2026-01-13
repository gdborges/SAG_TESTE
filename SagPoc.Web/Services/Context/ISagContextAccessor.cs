namespace SagPoc.Web.Services.Context;

/// <summary>
/// Interface para acessar o contexto de sessão do SAG.
/// Permite que serviços obtenham informações do usuário, empresa e módulo atual.
/// </summary>
public interface ISagContextAccessor
{
    /// <summary>
    /// Obtém o contexto atual da requisição.
    /// </summary>
    SagContext Context { get; }

    /// <summary>
    /// Define o contexto para a requisição atual.
    /// </summary>
    void SetContext(SagContext context);

    /// <summary>
    /// ID do usuário atual (atalho para Context.UsuarioId).
    /// </summary>
    int UsuarioId { get; }

    /// <summary>
    /// ID da empresa atual (atalho para Context.EmpresaId).
    /// </summary>
    int EmpresaId { get; }

    /// <summary>
    /// ID do módulo atual (atalho para Context.ModuloId).
    /// </summary>
    int ModuloId { get; }

    /// <summary>
    /// Indica se o contexto foi inicializado com valores válidos.
    /// </summary>
    bool IsInitialized { get; }
}
