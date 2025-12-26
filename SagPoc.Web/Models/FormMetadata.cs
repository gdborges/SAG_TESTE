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
    /// Nome físico da tabela (GravTabe, ex: "POCALESI")
    /// </summary>
    public string TableName { get; set; } = string.Empty;

    /// <summary>
    /// Sufixo da tabela (SIGLTABE, ex: "LESI")
    /// Usado para calcular o nome da PK: CODI{SiglTabe}
    /// </summary>
    public string? SiglTabe { get; set; }

    /// <summary>
    /// Título do formulário (NOMETABE)
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// Lista de campos do formulário
    /// </summary>
    public List<FieldMetadata> Fields { get; set; } = new();

    /// <summary>
    /// Campos do cabeçalho (GuiaCamp menor que 10).
    /// Esses campos são renderizados nas abas normais do formulário.
    /// Exclui campos ocultos (DEPOSHOW, ATUAGRID, OrdeCamp=9999).
    /// </summary>
    public IEnumerable<FieldMetadata> HeaderFields =>
        Fields.Where(f => !f.IsMovementField && !f.IsHidden);

    /// <summary>
    /// Campos de movimento (GuiaCamp >= 10).
    /// Esses campos são renderizados em abas de movimento com grid próprio.
    /// No Delphi, movimentos têm Envia/Remove e grid de registros filhos.
    /// Exclui campos ocultos.
    /// </summary>
    public IEnumerable<FieldMetadata> MovementFields =>
        Fields.Where(f => f.IsMovementField && !f.IsHidden);

    /// <summary>
    /// Indica se o formulário tem movimentos (registros filhos).
    /// </summary>
    public bool HasMovements => MovementFields.Any();

    /// <summary>
    /// Nome da coluna PK (chave primária).
    /// Segue o padrão SAG: CODI + SIGLTABE (ex: SIGLTABE="LESI" -> PK="CODILESI")
    /// </summary>
    public string PkColumnName
    {
        get
        {
            // Usa SIGLTABE se disponível
            if (!string.IsNullOrEmpty(SiglTabe))
            {
                return $"CODI{SiglTabe}";
            }

            // Fallback: extrai do nome físico da tabela
            if (string.IsNullOrEmpty(TableName)) return "ID";
            var suffix = TableName
                .Replace("POCA", "", StringComparison.OrdinalIgnoreCase)
                .Replace("POGE", "", StringComparison.OrdinalIgnoreCase);
            return $"CODI{suffix}";
        }
    }

    /// <summary>
    /// Movimentos agrupados por tipo (cada GuiaCamp >= 10 é um tipo diferente).
    /// Ex: GuiaCamp 10 = Produtos, GuiaCamp 11 = Serviços, etc.
    /// </summary>
    public IEnumerable<IGrouping<int, FieldMetadata>> MovementsByType =>
        MovementFields.GroupBy(f => f.GuiaCamp).OrderBy(g => g.Key);

    /// <summary>
    /// Campos de cabeçalho agrupados por GuiaCamp (aba).
    /// Exclui campos de movimento e campos ocultos.
    /// Filtra abas vazias (que não têm campos visíveis de entrada).
    /// </summary>
    public IEnumerable<IGrouping<int, FieldMetadata>> FieldsByTab =>
        HeaderFields
            .GroupBy(f => f.GuiaCamp)
            .Where(g => g.Any(f => !f.IsVisualComponent || f.GetComponentType() == ComponentType.Bevel))
            .OrderBy(g => g.Key);

    /// <summary>
    /// Retorna os GuiaCamp que têm campos visíveis (excluindo ocultos e abas vazias).
    /// </summary>
    public IEnumerable<int> VisibleTabIndexes =>
        FieldsByTab.Select(g => g.Key);

    /// <summary>
    /// Indica se o formulário tem múltiplas guias de cabeçalho.
    /// </summary>
    public bool HasMultipleTabs =>
        HeaderFields.Select(f => f.GuiaCamp).Distinct().Count() > 1;

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
    /// Usa OrdeCamp para determinar agrupamento - campos entre dois bevels pertencem ao bevel anterior.
    /// Exclui campos ocultos (IsHidden) do agrupamento.
    /// </summary>
    private List<BevelGroup> GetBevelGroupsForFields(List<FieldMetadata> fields)
    {
        // Filtra campos ocultos primeiro
        var visibleFields = fields.Where(f => !f.IsHidden).ToList();

        // Ordena bevels por OrdeCamp
        var bevels = visibleFields
            .Where(f => f.GetComponentType() == ComponentType.Bevel)
            .OrderBy(f => f.OrdeCamp)
            .ToList();

        // Campos de entrada (não-bevel, não-ocultos, não apenas visuais sem valor)
        var inputFields = visibleFields
            .Where(f => f.GetComponentType() != ComponentType.Bevel &&
                        f.GetComponentType() != ComponentType.Timer) // Timer é invisível
            .OrderBy(f => f.OrdeCamp)
            .ToList();

        var groups = new List<BevelGroup>();

        // Se não há bevels, retorna todos os campos em um grupo sem bevel
        if (!bevels.Any())
        {
            if (inputFields.Any())
            {
                groups.Add(new BevelGroup
                {
                    Bevel = null,
                    Children = inputFields
                });
            }
            return groups;
        }

        // Campos antes do primeiro bevel (órfãos iniciais)
        var firstBevelOrde = bevels.First().OrdeCamp;
        var orphansBefore = inputFields
            .Where(f => f.OrdeCamp < firstBevelOrde)
            .ToList();

        if (orphansBefore.Any())
        {
            groups.Add(new BevelGroup
            {
                Bevel = null,
                Children = orphansBefore
            });
        }

        // Para cada bevel, agrupa os campos com OrdeCamp entre este bevel e o próximo
        for (int i = 0; i < bevels.Count; i++)
        {
            var bevel = bevels[i];
            var nextBevelOrde = i < bevels.Count - 1
                ? bevels[i + 1].OrdeCamp
                : int.MaxValue;

            var group = new BevelGroup { Bevel = bevel };

            // Campos com OrdeCamp entre este bevel e o próximo
            group.Children = inputFields
                .Where(f => f.OrdeCamp > bevel.OrdeCamp && f.OrdeCamp < nextBevelOrde)
                .OrderBy(f => f.OrdeCamp)
                .ThenBy(f => f.TopoCamp)
                .ThenBy(f => f.EsquCamp)
                .ToList();

            // Só adiciona o grupo se tiver campos dentro OU se o bevel tem caption
            // (bevels com caption podem ser usados como separadores visuais)
            if (group.Children.Any() || bevel.HasBevelCaption)
            {
                groups.Add(group);
            }
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
    /// Retorna os bevels com seus campos filhos agrupados por OrdeCamp.
    /// Um campo pertence a um bevel se seu OrdeCamp está entre o OrdeCamp desse bevel e o próximo.
    /// Usa apenas campos do cabeçalho (GuiaCamp menor que 10), excluindo movimentos.
    /// </summary>
    public List<BevelGroup> GetBevelGroups()
    {
        // Usa apenas HeaderFields (GuiaCamp < 10, excluindo ocultos)
        return GetBevelGroupsForFields(HeaderFields.ToList());
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
    /// Tolerancia em pixels para agrupar campos na mesma linha.
    /// Campos com diferenca de TopoCamp menor ou igual a este valor sao considerados na mesma linha.
    /// </summary>
    public const int RowTolerance = 20;

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

    /// <summary>
    /// Agrupa os campos filhos em linhas baseado na proximidade de TopoCamp.
    /// Campos com TopoCamp dentro da tolerancia (20px) sao agrupados na mesma linha.
    /// Dentro de cada linha, campos sao ordenados por EsquCamp (esquerda para direita).
    /// </summary>
    public List<FieldRow> GetFieldRows()
    {
        if (!Children.Any())
            return new List<FieldRow>();

        var rows = new List<FieldRow>();

        // Ordena por TopoCamp primeiro, depois EsquCamp
        var sortedFields = Children
            .OrderBy(f => f.TopoCamp)
            .ThenBy(f => f.EsquCamp)
            .ToList();

        FieldRow? currentRow = null;

        foreach (var field in sortedFields)
        {
            // Se nao ha linha atual OU a diferenca de TopoCamp excede a tolerancia, cria nova linha
            if (currentRow == null ||
                Math.Abs(field.TopoCamp - currentRow.BaseTopoCamp) > RowTolerance)
            {
                currentRow = new FieldRow { BaseTopoCamp = field.TopoCamp };
                rows.Add(currentRow);
            }

            currentRow.Fields.Add(field);
        }

        // Ordena campos dentro de cada linha por EsquCamp (esquerda para direita)
        foreach (var row in rows)
        {
            row.Fields = row.Fields.OrderBy(f => f.EsquCamp).ToList();
        }

        return rows;
    }
}

/// <summary>
/// Representa uma linha de campos que compartilham valores similares de TopoCamp.
/// Usado para layout CSS Grid baseado em linhas.
/// </summary>
public class FieldRow
{
    /// <summary>
    /// O valor base de TopoCamp para esta linha (o menor TopoCamp dos campos agrupados).
    /// </summary>
    public int BaseTopoCamp { get; set; }

    /// <summary>
    /// Campos nesta linha, ordenados por EsquCamp (esquerda para direita).
    /// </summary>
    public List<FieldMetadata> Fields { get; set; } = new();

    /// <summary>
    /// Indica se esta linha contem apenas um campo (deve usar max-width).
    /// </summary>
    public bool IsSingleField => Fields.Count == 1;

    /// <summary>
    /// Indica se esta linha contem multiplos campos (layout grid).
    /// </summary>
    public bool IsMultiField => Fields.Count > 1;
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
