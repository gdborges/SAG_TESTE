namespace SagPoc.Web.Models;

/// <summary>
/// ViewModel para o formulário de movimento (modal).
/// </summary>
public class MovementFormViewModel
{
    /// <summary>
    /// ID da tabela de movimento
    /// </summary>
    public int TableId { get; set; }

    /// <summary>
    /// ID do registro (null para novo)
    /// </summary>
    public int? RecordId { get; set; }

    /// <summary>
    /// Campos do formulário
    /// </summary>
    public List<FieldMetadata> Fields { get; set; } = new();

    /// <summary>
    /// Dados do registro (para edição)
    /// </summary>
    public Dictionary<string, object?>? RecordData { get; set; }

    /// <summary>
    /// Verifica se é modo de edição
    /// </summary>
    public bool IsEditMode => RecordId.HasValue;

    /// <summary>
    /// Obtém o valor de um campo do registro
    /// </summary>
    public object? GetFieldValue(string fieldName)
    {
        if (RecordData == null) return null;

        // Tenta nome exato
        if (RecordData.TryGetValue(fieldName, out var value))
            return value;

        // Tenta case-insensitive
        var key = RecordData.Keys.FirstOrDefault(k =>
            k.Equals(fieldName, StringComparison.OrdinalIgnoreCase));
        if (key != null && RecordData.TryGetValue(key, out value))
            return value;

        return null;
    }

    /// <summary>
    /// Tolerância em pixels para agrupar campos na mesma linha.
    /// Campos com diferença de TopoCamp menor ou igual a este valor são considerados na mesma linha.
    /// Igual ao BevelGroup.RowTolerance.
    /// </summary>
    private const int RowTolerance = 20;

    /// <summary>
    /// Agrupa campos por linha usando TopoCamp (coordenada Y).
    /// Usa a mesma lógica do BevelGroup.GetFieldRows() do formulário principal:
    /// - Campos com TopoCamp dentro da tolerância (20px) ficam na mesma linha
    /// - Dentro de cada linha, campos são ordenados por EsquCamp (esquerda para direita)
    /// </summary>
    public IEnumerable<List<FieldMetadata>> GetFieldRows()
    {
        if (!Fields.Any())
            return new List<List<FieldMetadata>>();

        var rows = new List<List<FieldMetadata>>();

        // Ordena por TopoCamp primeiro, depois EsquCamp
        var sortedFields = Fields
            .OrderBy(f => f.TopoCamp)
            .ThenBy(f => f.EsquCamp)
            .ToList();

        List<FieldMetadata>? currentRow = null;
        int currentBaseTop = 0;

        foreach (var field in sortedFields)
        {
            // Se não há linha atual OU a diferença de TopoCamp excede a tolerância, cria nova linha
            if (currentRow == null ||
                Math.Abs(field.TopoCamp - currentBaseTop) > RowTolerance)
            {
                currentRow = new List<FieldMetadata>();
                currentBaseTop = field.TopoCamp;
                rows.Add(currentRow);
            }

            currentRow.Add(field);
        }

        // Ordena campos dentro de cada linha por EsquCamp (esquerda para direita)
        foreach (var row in rows)
        {
            row.Sort((a, b) => a.EsquCamp.CompareTo(b.EsquCamp));
        }

        return rows;
    }
}
