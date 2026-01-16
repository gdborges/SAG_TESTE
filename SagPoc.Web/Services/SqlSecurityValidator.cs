using System.Text.RegularExpressions;

namespace SagPoc.Web.Services;

/// <summary>
/// Valida condições SQL dinâmicas para prevenção de SQL injection.
/// Usado pelo LookupService para validar condições injetadas via comando QY.
///
/// Estratégia: Whitelist de padrões permitidos + Blacklist de comandos perigosos.
/// </summary>
public static class SqlSecurityValidator
{
    // Padrões permitidos (regex) - condição DEVE começar com um destes
    private static readonly Regex[] AllowedPatterns = new[]
    {
        new Regex(@"^\s*AND\s+", RegexOptions.IgnoreCase | RegexOptions.Compiled),
        new Regex(@"^\s*OR\s+", RegexOptions.IgnoreCase | RegexOptions.Compiled),
        new Regex(@"^\s*EXISTS\s*\(\s*SELECT", RegexOptions.IgnoreCase | RegexOptions.Compiled),
        new Regex(@"^\s*IN\s*\(\s*SELECT", RegexOptions.IgnoreCase | RegexOptions.Compiled),
        new Regex(@"^\s*ABRE\s*$", RegexOptions.IgnoreCase | RegexOptions.Compiled)  // Caso especial: apenas abre
    };

    // Comandos/padrões bloqueados (blacklist)
    private static readonly string[] BlockedCommands = new[]
    {
        "DROP", "DELETE", "INSERT", "UPDATE", "ALTER", "CREATE", "TRUNCATE",
        "EXEC", "EXECUTE", "GRANT", "REVOKE", "MERGE", "CALL"
    };

    // Caracteres/sequências perigosas
    private static readonly string[] BlockedSequences = new[]
    {
        ";",    // Statement separator
        "--",   // Line comment
        "/*",   // Block comment start
        "*/",   // Block comment end
        "@@",   // System variable (SQL Server)
        "xp_",  // Extended stored procedures (SQL Server)
        "sp_"   // System stored procedures (SQL Server)
    };

    /// <summary>
    /// Valida uma condição SQL dinâmica para injeção em lookup.
    /// </summary>
    /// <param name="condition">Condição SQL a ser validada (ex: "AND EXISTS(SELECT 1 FROM T)")</param>
    /// <returns>True se a condição é segura para uso</returns>
    public static bool ValidateDynamicSqlCondition(string? condition)
    {
        if (string.IsNullOrWhiteSpace(condition))
            return false;

        // Caso especial: ABRE (apenas abre o lookup sem filtro adicional)
        if (condition.Trim().Equals("ABRE", StringComparison.OrdinalIgnoreCase))
            return true;

        // 1. Verifica whitelist de padrões permitidos
        var matchesAllowedPattern = AllowedPatterns.Any(pattern => pattern.IsMatch(condition));
        if (!matchesAllowedPattern)
            return false;

        var conditionUpper = condition.ToUpperInvariant();

        // 2. Verifica blacklist de comandos
        foreach (var cmd in BlockedCommands)
        {
            // Verifica se comando aparece como palavra inteira (não parte de outro nome)
            var pattern = $@"\b{cmd}\b";
            if (Regex.IsMatch(conditionUpper, pattern, RegexOptions.IgnoreCase))
                return false;
        }

        // 3. Verifica sequências perigosas
        foreach (var seq in BlockedSequences)
        {
            if (condition.Contains(seq, StringComparison.OrdinalIgnoreCase))
                return false;
        }

        return true;
    }

    /// <summary>
    /// Sanitiza uma string para uso seguro em SQL.
    /// Escapa aspas simples e remove caracteres perigosos.
    /// </summary>
    /// <param name="value">Valor a sanitizar</param>
    /// <returns>Valor sanitizado</returns>
    public static string SanitizeValue(string? value)
    {
        if (string.IsNullOrEmpty(value))
            return string.Empty;

        // Escapa aspas simples (padrão SQL)
        var sanitized = value.Replace("'", "''");

        // Remove sequências perigosas
        foreach (var seq in BlockedSequences)
        {
            sanitized = sanitized.Replace(seq, "", StringComparison.OrdinalIgnoreCase);
        }

        return sanitized;
    }

    /// <summary>
    /// Obtém descrição do motivo de rejeição para logging.
    /// </summary>
    public static string GetRejectionReason(string? condition)
    {
        if (string.IsNullOrWhiteSpace(condition))
            return "Condição vazia ou nula";

        if (condition.Trim().Equals("ABRE", StringComparison.OrdinalIgnoreCase))
            return string.Empty; // Válido

        // Verifica whitelist
        var matchesAllowedPattern = AllowedPatterns.Any(pattern => pattern.IsMatch(condition));
        if (!matchesAllowedPattern)
            return "Condição não começa com padrão permitido (AND, OR, EXISTS, IN)";

        var conditionUpper = condition.ToUpperInvariant();

        // Verifica blacklist
        foreach (var cmd in BlockedCommands)
        {
            var pattern = $@"\b{cmd}\b";
            if (Regex.IsMatch(conditionUpper, pattern, RegexOptions.IgnoreCase))
                return $"Comando bloqueado detectado: {cmd}";
        }

        // Verifica sequências
        foreach (var seq in BlockedSequences)
        {
            if (condition.Contains(seq, StringComparison.OrdinalIgnoreCase))
                return $"Sequência bloqueada detectada: {seq}";
        }

        return string.Empty; // Válido
    }
}
