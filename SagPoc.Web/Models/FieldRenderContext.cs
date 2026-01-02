namespace SagPoc.Web.Models;

/// <summary>
/// Contexto para renderizacao de um campo, incluindo informacoes sobre a linha.
/// </summary>
public class FieldRenderContext
{
    /// <summary>
    /// O campo a ser renderizado.
    /// </summary>
    public FieldMetadata Field { get; set; } = null!;

    /// <summary>
    /// Indica se este campo esta sozinho na linha (deve usar max-width).
    /// </summary>
    public bool IsSingleInRow { get; set; }
}

/// <summary>
/// Contexto para renderizacao de campo em modal de movimento.
/// </summary>
public class MovementFieldContext
{
    /// <summary>
    /// O campo a ser renderizado.
    /// </summary>
    public FieldMetadata Field { get; set; } = null!;

    /// <summary>
    /// Valor atual do campo (para edição).
    /// </summary>
    public object? Value { get; set; }

    /// <summary>
    /// Indica se este campo esta sozinho na linha.
    /// </summary>
    public bool IsSingleInRow { get; set; }

    /// <summary>
    /// Indica se está em modo de edição (vs novo).
    /// </summary>
    public bool IsEditMode { get; set; }

    /// <summary>
    /// Obtém o valor formatado como string.
    /// </summary>
    public string GetValueAsString()
    {
        if (Value == null) return string.Empty;
        if (Value is DateTime dt) return dt.ToString("yyyy-MM-dd");
        return Value.ToString() ?? string.Empty;
    }

    /// <summary>
    /// Verifica se o valor é considerado "checked" para checkbox.
    /// </summary>
    public bool IsChecked()
    {
        if (Value == null) return false;
        if (Value is bool b) return b;
        if (Value is int i) return i == 1;
        if (Value is string s) return s == "1" || s.ToUpper() == "S" || s.ToUpper() == "TRUE";
        return false;
    }
}
