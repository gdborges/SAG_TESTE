namespace SagPoc.Web.Services.Context;

/// <summary>
/// Implementação do ISagContextAccessor.
/// Armazena o contexto usando AsyncLocal para garantir isolamento entre requisições.
/// </summary>
public class SagContextAccessor : ISagContextAccessor
{
    private static readonly AsyncLocal<SagContextHolder> _contextHolder = new();

    /// <summary>
    /// Valores default quando o contexto não é fornecido.
    /// Alinhados com SagContext do appsettings.json (U99E01S83).
    /// </summary>
    public static class Defaults
    {
        /// <summary>U99 = Usuário 99 (padrão Delphi)</summary>
        public const int UsuarioId = 99;
        public const string UsuarioNome = "SAGADM";

        /// <summary>E01 = Empresa 01, CodiEmpr = 226</summary>
        public const int EmpresaId = 226;
        public const string EmpresaNome = "E01";

        /// <summary>S83 = Sistema Vendas - Distribuição</summary>
        public const int ModuloId = 83;
        public const string ModuloNome = "Vendas - Distribuição";
    }

    public SagContext Context
    {
        get
        {
            var context = _contextHolder.Value?.Context;
            if (context == null)
            {
                // Retorna contexto com valores default
                context = CreateDefaultContext();
                SetContext(context);
            }
            return context;
        }
    }

    public void SetContext(SagContext context)
    {
        _contextHolder.Value = new SagContextHolder { Context = context };
    }

    public int UsuarioId => Context.UsuarioId;
    public int EmpresaId => Context.EmpresaId;
    public int ModuloId => Context.ModuloId;
    public bool IsInitialized => Context.IsInitialized;

    /// <summary>
    /// Cria um contexto com valores default.
    /// Usado quando nenhum contexto é fornecido pela requisição.
    /// </summary>
    private static SagContext CreateDefaultContext()
    {
        return new SagContext
        {
            UsuarioId = Defaults.UsuarioId,
            UsuarioNome = Defaults.UsuarioNome,
            EmpresaId = Defaults.EmpresaId,
            EmpresaNome = Defaults.EmpresaNome,
            ModuloId = Defaults.ModuloId,
            ModuloNome = Defaults.ModuloNome
        };
    }

    /// <summary>
    /// Holder para o contexto (necessário para AsyncLocal funcionar corretamente).
    /// </summary>
    private class SagContextHolder
    {
        public SagContext? Context { get; set; }
    }
}
