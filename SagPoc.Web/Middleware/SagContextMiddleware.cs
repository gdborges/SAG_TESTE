using SagPoc.Web.Services.Context;

namespace SagPoc.Web.Middleware;

/// <summary>
/// Middleware que captura o contexto de sessão SAG da requisição.
///
/// O contexto pode ser passado via:
/// 1. Query parameters: ?usuarioId=1&empresaId=2&moduloId=3
/// 2. Headers HTTP: X-Sag-Usuario-Id, X-Sag-Empresa-Id, X-Sag-Modulo-Id
/// 3. Session (se configurada)
///
/// Prioridade: Headers > Query > Session > Defaults
/// </summary>
public class SagContextMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<SagContextMiddleware> _logger;

    // Nomes dos parâmetros aceitos
    private static class ParamNames
    {
        // Query parameters
        public const string UsuarioId = "usuarioId";
        public const string EmpresaId = "empresaId";
        public const string ModuloId = "moduloId";
        public const string UsuarioNome = "usuarioNome";
        public const string EmpresaNome = "empresaNome";
        public const string ModuloNome = "moduloNome";

        // Headers HTTP
        public const string HeaderUsuarioId = "X-Sag-Usuario-Id";
        public const string HeaderEmpresaId = "X-Sag-Empresa-Id";
        public const string HeaderModuloId = "X-Sag-Modulo-Id";
        public const string HeaderUsuarioNome = "X-Sag-Usuario-Nome";
        public const string HeaderEmpresaNome = "X-Sag-Empresa-Nome";
        public const string HeaderModuloNome = "X-Sag-Modulo-Nome";
    }

    public SagContextMiddleware(RequestDelegate next, ILogger<SagContextMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext httpContext, ISagContextAccessor sagContextAccessor)
    {
        var context = BuildContext(httpContext);
        sagContextAccessor.SetContext(context);

        if (context.IsInitialized)
        {
            _logger.LogDebug("SagContext inicializado: {Context}", context);
        }

        await _next(httpContext);
    }

    private SagContext BuildContext(HttpContext httpContext)
    {
        var context = new SagContext();

        // 1. Tenta headers primeiro (maior prioridade)
        var usuarioIdHeader = httpContext.Request.Headers[ParamNames.HeaderUsuarioId].FirstOrDefault();
        var empresaIdHeader = httpContext.Request.Headers[ParamNames.HeaderEmpresaId].FirstOrDefault();
        var moduloIdHeader = httpContext.Request.Headers[ParamNames.HeaderModuloId].FirstOrDefault();

        if (!string.IsNullOrEmpty(usuarioIdHeader) && int.TryParse(usuarioIdHeader, out var usuarioIdH))
            context.UsuarioId = usuarioIdH;

        if (!string.IsNullOrEmpty(empresaIdHeader) && int.TryParse(empresaIdHeader, out var empresaIdH))
            context.EmpresaId = empresaIdH;

        if (!string.IsNullOrEmpty(moduloIdHeader) && int.TryParse(moduloIdHeader, out var moduloIdH))
            context.ModuloId = moduloIdH;

        context.UsuarioNome = httpContext.Request.Headers[ParamNames.HeaderUsuarioNome].FirstOrDefault();
        context.EmpresaNome = httpContext.Request.Headers[ParamNames.HeaderEmpresaNome].FirstOrDefault();
        context.ModuloNome = httpContext.Request.Headers[ParamNames.HeaderModuloNome].FirstOrDefault();

        // 2. Query parameters (sobrescreve se não veio por header)
        var query = httpContext.Request.Query;

        if (context.UsuarioId == 0 && query.TryGetValue(ParamNames.UsuarioId, out var usuarioIdQ) && int.TryParse(usuarioIdQ, out var usuarioId))
            context.UsuarioId = usuarioId;

        if (context.EmpresaId == 0 && query.TryGetValue(ParamNames.EmpresaId, out var empresaIdQ) && int.TryParse(empresaIdQ, out var empresaId))
            context.EmpresaId = empresaId;

        if (context.ModuloId == 0 && query.TryGetValue(ParamNames.ModuloId, out var moduloIdQ) && int.TryParse(moduloIdQ, out var moduloId))
            context.ModuloId = moduloId;

        if (string.IsNullOrEmpty(context.UsuarioNome) && query.TryGetValue(ParamNames.UsuarioNome, out var usuarioNome))
            context.UsuarioNome = usuarioNome;

        if (string.IsNullOrEmpty(context.EmpresaNome) && query.TryGetValue(ParamNames.EmpresaNome, out var empresaNome))
            context.EmpresaNome = empresaNome;

        if (string.IsNullOrEmpty(context.ModuloNome) && query.TryGetValue(ParamNames.ModuloNome, out var moduloNome))
            context.ModuloNome = moduloNome;

        // 3. Aplica defaults se não foi informado
        if (context.UsuarioId == 0)
        {
            context.UsuarioId = SagContextAccessor.Defaults.UsuarioId;
            context.UsuarioNome ??= SagContextAccessor.Defaults.UsuarioNome;
        }

        if (context.EmpresaId == 0)
        {
            context.EmpresaId = SagContextAccessor.Defaults.EmpresaId;
            context.EmpresaNome ??= SagContextAccessor.Defaults.EmpresaNome;
        }

        if (context.ModuloId == 0)
        {
            context.ModuloId = SagContextAccessor.Defaults.ModuloId;
            context.ModuloNome ??= SagContextAccessor.Defaults.ModuloNome;
        }

        return context;
    }
}

/// <summary>
/// Extension methods para registrar o middleware.
/// </summary>
public static class SagContextMiddlewareExtensions
{
    /// <summary>
    /// Adiciona o middleware de contexto SAG ao pipeline.
    /// </summary>
    public static IApplicationBuilder UseSagContext(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<SagContextMiddleware>();
    }

    /// <summary>
    /// Registra os serviços necessários para o contexto SAG.
    /// </summary>
    public static IServiceCollection AddSagContext(this IServiceCollection services)
    {
        services.AddScoped<ISagContextAccessor, SagContextAccessor>();
        return services;
    }
}
