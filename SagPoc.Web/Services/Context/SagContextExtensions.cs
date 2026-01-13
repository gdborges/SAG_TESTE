namespace SagPoc.Web.Services.Context;

/// <summary>
/// Extensões e helpers para formatação do contexto SAG no padrão Oracle.
/// O formato CONFCONF é: UUUEEESSS (ex: U99E01S83)
/// </summary>
public static class SagContextExtensions
{
    /// <summary>
    /// Formata ID do usuário no padrão SAG (U + 2 dígitos)
    /// Ex: 99 -> "U99", 1 -> "U01"
    /// </summary>
    public static string FormatPUSU(int usuarioId)
        => $"U{usuarioId:D2}";

    /// <summary>
    /// Formata ID do módulo/sistema no padrão SAG (S + 2 dígitos)
    /// Ex: 83 -> "S83", 8 -> "S08"
    /// </summary>
    public static string FormatPSIS(int moduloId)
        => $"S{moduloId:D2}";

    /// <summary>
    /// Gera string CONFCONF a partir do contexto.
    /// Ex: "U99E01S83"
    /// </summary>
    /// <param name="context">Contexto SAG da requisição</param>
    /// <param name="pcodEmpr">Código da empresa no formato E?? (obtido de POCAEMPR.PCODEMPR)</param>
    public static string ToConfConf(this SagContext context, string pcodEmpr)
        => $"{FormatPUSU(context.UsuarioId)}{pcodEmpr}{FormatPSIS(context.ModuloId)}";
}
