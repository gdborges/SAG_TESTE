namespace SagPoc.Web.Models;

/// <summary>
/// Modelo que representa um formulário dinâmico completo.
/// Contém informações da tabela e seus campos.
/// </summary>
public class FormMetadata
{
    /// <summary>
    /// ID da tabela/formulário (CodiTabe)
    /// </summary>
    public int TableId { get; set; }

    /// <summary>
    /// Nome da tabela (ex: "TipDoc")
    /// </summary>
    public string TableName { get; set; } = string.Empty;

    /// <summary>
    /// Título do formulário
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// Lista de campos do formulário
    /// </summary>
    public List<FieldMetadata> Fields { get; set; } = new();

    /// <summary>
    /// Campos agrupados por GuiaCamp (aba)
    /// </summary>
    public IEnumerable<IGrouping<int, FieldMetadata>> FieldsByTab =>
        Fields.GroupBy(f => f.GuiaCamp).OrderBy(g => g.Key);

    /// <summary>
    /// Indica se o formulário tem múltiplas guias.
    /// </summary>
    public bool HasMultipleTabs =>
        Fields.Select(f => f.GuiaCamp).Distinct().Count() > 1;

    /// <summary>
    /// Retorna as abas do formulário com bevels e campos organizados.
    /// </summary>
    public List<TabGroup> GetTabGroups()
    {
        var guias = Fields
            .Select(f => f.GuiaCamp)
            .Distinct()
            .OrderBy(g => g)
            .ToList();

        var tabGroups = new List<TabGroup>();

        foreach (var guia in guias)
        {
            var tabFields = Fields.Where(f => f.GuiaCamp == guia).ToList();
            var bevelGroups = GetBevelGroupsForFields(tabFields);

            tabGroups.Add(new TabGroup
            {
                TabIndex = guia,
                TabName = $"Guia {guia}",
                BevelGroups = bevelGroups
            });
        }

        return tabGroups;
    }

    /// <summary>
    /// Agrupa campos por bevel para um subset de campos.
    /// </summary>
    private List<BevelGroup> GetBevelGroupsForFields(List<FieldMetadata> fields)
    {
        var bevels = fields
            .Where(f => f.GetComponentType() == ComponentType.Bevel)
            .OrderBy(f => f.TopoCamp)
            .ThenBy(f => f.EsquCamp)
            .ToList();

        var inputFields = fields
            .Where(f => f.GetComponentType() != ComponentType.Bevel)
            .ToList();

        var groups = new List<BevelGroup>();
        var assignedFields = new HashSet<int>();

        foreach (var bevel in bevels)
        {
            var group = new BevelGroup { Bevel = bevel };

            foreach (var field in inputFields)
            {
                if (assignedFields.Contains(field.CodiCamp))
                    continue;

                if (IsFieldInsideBevel(field, bevel))
                {
                    group.Children.Add(field);
                    assignedFields.Add(field.CodiCamp);
                }
            }

            group.Children = group.Children
                .OrderBy(f => f.OrdeCamp)
                .ThenBy(f => f.TopoCamp)
                .ThenBy(f => f.EsquCamp)
                .ToList();

            // Só adiciona o grupo se tiver campos dentro
            if (group.Children.Any())
            {
                groups.Add(group);
            }
        }

        var orphanFields = inputFields
            .Where(f => !assignedFields.Contains(f.CodiCamp))
            .OrderBy(f => f.OrdeCamp)
            .ThenBy(f => f.TopoCamp)
            .ThenBy(f => f.EsquCamp)
            .ToList();

        if (orphanFields.Any())
        {
            groups.Add(new BevelGroup
            {
                Bevel = null,
                Children = orphanFields
            });
        }

        return groups;
    }

    /// <summary>
    /// Bevels (agrupadores visuais) do formulário
    /// </summary>
    public IEnumerable<FieldMetadata> Bevels =>
        Fields.Where(f => f.GetComponentType() == ComponentType.Bevel)
              .OrderBy(f => f.OrdeCamp)
              .ThenBy(f => f.TopoCamp)
              .ThenBy(f => f.EsquCamp);

    /// <summary>
    /// Campos de entrada (não-bevels) do formulário
    /// </summary>
    public IEnumerable<FieldMetadata> InputFields =>
        Fields.Where(f => f.GetComponentType() != ComponentType.Bevel)
              .OrderBy(f => f.OrdeCamp)
              .ThenBy(f => f.TopoCamp)
              .ThenBy(f => f.EsquCamp);

    /// <summary>
    /// Retorna os bevels com seus campos filhos agrupados geometricamente.
    /// Um campo pertence a um bevel se está dentro de suas coordenadas.
    /// </summary>
    public List<BevelGroup> GetBevelGroups()
    {
        var bevels = Fields
            .Where(f => f.GetComponentType() == ComponentType.Bevel)
            .OrderBy(f => f.OrdeCamp)
            .ThenBy(f => f.TopoCamp)
            .ThenBy(f => f.EsquCamp)
            .ToList();

        var inputFields = Fields
            .Where(f => f.GetComponentType() != ComponentType.Bevel)
            .ToList();

        var groups = new List<BevelGroup>();
        var assignedFields = new HashSet<int>();

        foreach (var bevel in bevels)
        {
            var group = new BevelGroup { Bevel = bevel };

            // Encontra campos que estão geometricamente dentro deste bevel
            foreach (var field in inputFields)
            {
                if (assignedFields.Contains(field.CodiCamp))
                    continue;

                if (IsFieldInsideBevel(field, bevel))
                {
                    group.Children.Add(field);
                    assignedFields.Add(field.CodiCamp);
                }
            }

            // Ordena campos dentro do bevel por ORDECAMP (sequência de tabulação)
            group.Children = group.Children
                .OrderBy(f => f.OrdeCamp)
                .ThenBy(f => f.TopoCamp)
                .ThenBy(f => f.EsquCamp)
                .ToList();

            // Só adiciona o grupo se tiver campos dentro
            if (group.Children.Any())
            {
                groups.Add(group);
            }
        }

        // Campos órfãos (fora de qualquer bevel)
        var orphanFields = inputFields
            .Where(f => !assignedFields.Contains(f.CodiCamp))
            .OrderBy(f => f.OrdeCamp)
            .ThenBy(f => f.TopoCamp)
            .ThenBy(f => f.EsquCamp)
            .ToList();

        if (orphanFields.Any())
        {
            groups.Add(new BevelGroup
            {
                Bevel = null,
                Children = orphanFields
            });
        }

        return groups;
    }

    /// <summary>
    /// Verifica se um campo está geometricamente dentro de um bevel.
    /// </summary>
    private bool IsFieldInsideBevel(FieldMetadata field, FieldMetadata bevel)
    {
        // Coordenadas do bevel
        int bevelTop = bevel.TopoCamp;
        int bevelLeft = bevel.EsquCamp;
        int bevelBottom = bevel.TopoCamp + bevel.AltuCamp;
        int bevelRight = bevel.EsquCamp + bevel.TamaCamp;

        // Centro do campo (para verificação mais precisa)
        int fieldCenterY = field.TopoCamp + 10; // Aproximadamente o centro vertical
        int fieldCenterX = field.EsquCamp + 10; // Um pouco dentro da borda esquerda

        // Verifica se o campo está dentro do bevel
        return fieldCenterY >= bevelTop &&
               fieldCenterY <= bevelBottom &&
               fieldCenterX >= bevelLeft &&
               fieldCenterX <= bevelRight;
    }
}

/// <summary>
/// Representa um bevel com seus campos filhos.
/// </summary>
public class BevelGroup
{
    /// <summary>
    /// O bevel (agrupador visual). Null se for grupo de campos órfãos.
    /// </summary>
    public FieldMetadata? Bevel { get; set; }

    /// <summary>
    /// Campos que estão dentro deste bevel.
    /// </summary>
    public List<FieldMetadata> Children { get; set; } = new();

    /// <summary>
    /// Indica se este grupo tem um bevel container.
    /// </summary>
    public bool HasBevel => Bevel != null;
}

/// <summary>
/// Representa uma aba/guia do formulário com seus bevels e campos.
/// </summary>
public class TabGroup
{
    /// <summary>
    /// Índice da guia (valor do GuiaCamp)
    /// </summary>
    public int TabIndex { get; set; }

    /// <summary>
    /// Nome da guia para exibição
    /// </summary>
    public string TabName { get; set; } = string.Empty;

    /// <summary>
    /// Grupos de bevel desta guia
    /// </summary>
    public List<BevelGroup> BevelGroups { get; set; } = new();
}
