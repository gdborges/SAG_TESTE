namespace SagPoc.Web.Models;

/// <summary>
/// Metadados de uma tabela de movimento (filho de um cabeçalho).
/// Representa a configuração de um grid de movimento vinculado a um registro pai.
/// </summary>
public class MovementMetadata
{
    /// <summary>
    /// Código da tabela de movimento (CODITABE)
    /// </summary>
    public int CodiTabe { get; set; }

    /// <summary>
    /// Nome descritivo da tabela de movimento (NOMETABE)
    /// </summary>
    public string NomeTabe { get; set; } = string.Empty;

    /// <summary>
    /// Nome físico da tabela SQL (GRAVTABE)
    /// </summary>
    public string GravTabe { get; set; } = string.Empty;

    /// <summary>
    /// Sigla da tabela (SIGLTABE) - usado para calcular nome da PK
    /// </summary>
    public string SiglTabe { get; set; } = string.Empty;

    /// <summary>
    /// Código da tabela cabeçalho/pai (CABETABE)
    /// </summary>
    public int CabeTabe { get; set; }

    /// <summary>
    /// Posição/série do movimento (SERITABE).
    /// > 50: movimento exibido na mesma guia do cabeçalho (inline)
    /// <= 50: movimento exibido em guia/tab separada
    /// </summary>
    public int SeriTabe { get; set; }

    /// <summary>
    /// Código alternativo de referência (GETATABE)
    /// </summary>
    public int? GeTaTabe { get; set; }

    /// <summary>
    /// Título da guia (GUI1TABE) - usado quando SeriTabe <= 50
    /// </summary>
    public string? Gui1Tabe { get; set; }

    /// <summary>
    /// SQL do grid de movimento (GRIDTABE)
    /// </summary>
    public string? GridTabe { get; set; }

    /// <summary>
    /// Configuração de colunas do grid (GRCOTABE)
    /// Formato: "col1;width1;col2;width2;..."
    /// </summary>
    public string? GrCoTabe { get; set; }

    /// <summary>
    /// Altura da tabela (ALTUTABE)
    /// </summary>
    public int AltuTabe { get; set; }

    /// <summary>
    /// Largura da tabela (TAMATABE)
    /// </summary>
    public int TamaTabe { get; set; }

    /// <summary>
    /// Parâmetros JSON (PARATABE)
    /// </summary>
    public string? ParaTabe { get; set; }

    /// <summary>
    /// Sub-movimentos (filhos deste movimento).
    /// Permite hierarquia de 2 níveis: Cabeçalho -> Movimento -> Sub-movimento
    /// </summary>
    public List<MovementMetadata> Children { get; set; } = new();

    /// <summary>
    /// Campos do formulário de edição do movimento.
    /// Carregado sob demanda ao abrir o modal.
    /// </summary>
    public List<FieldMetadata>? Fields { get; set; }

    /// <summary>
    /// Campos do cabeçalho que pertencem a esta aba de movimento.
    /// São campos da tabela pai onde GuiaCamp = CodiTabe deste movimento.
    /// Ex: Na tabela 120, campos TOQTMVCT e TOVLMVCT têm GuiaCamp=125,
    /// então aparecem na aba do movimento 125 junto com o grid.
    /// </summary>
    public List<FieldMetadata> HeaderFields { get; set; } = new();

    /// <summary>
    /// Indica se este movimento tem campos de cabeçalho associados.
    /// </summary>
    public bool HasHeaderFields => HeaderFields.Count > 0;

    /// <summary>
    /// Agrupa os campos de cabeçalho em linhas baseado na proximidade de TopoCamp.
    /// Similar ao BevelGroup.GetFieldRows() mas para os HeaderFields deste movimento.
    /// </summary>
    public List<FieldRow> GetHeaderFieldRows()
    {
        const int RowTolerance = 20;

        if (!HeaderFields.Any())
            return new List<FieldRow>();

        var rows = new List<FieldRow>();

        // Ordena por TopoCamp primeiro, depois EsquCamp
        var sortedFields = HeaderFields
            .OrderBy(f => f.TopoCamp)
            .ThenBy(f => f.EsquCamp)
            .ToList();

        FieldRow? currentRow = null;

        foreach (var field in sortedFields)
        {
            // Se não há linha atual OU a diferença de TopoCamp excede a tolerância, cria nova linha
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

    /// <summary>
    /// Indica se o movimento deve ser exibido inline (mesma guia do cabeçalho).
    /// True se SeriTabe > 50, False se deve ter guia separada.
    /// </summary>
    public bool IsInline => SeriTabe > 50;

    /// <summary>
    /// Indica se tem sub-movimentos (filhos).
    /// </summary>
    public bool HasChildren => Children.Count > 0;

    /// <summary>
    /// Nome limpo da guia (remove '&' usado para atalhos no Delphi).
    /// </summary>
    public string GetCleanTabName() => Gui1Tabe?.Replace("&", "") ?? NomeTabe ?? $"Movimento {CodiTabe}";

    /// <summary>
    /// Nome da coluna PK seguindo convenção SAG: CODI + sufixo da tabela
    /// Prioriza extração do GravTabe (nome físico) sobre SIGLTABE.
    /// </summary>
    public string PkColumnName
    {
        get
        {
            // Prioriza extração do nome físico da tabela (mais confiável)
            if (!string.IsNullOrWhiteSpace(GravTabe))
            {
                var suffix = GravTabe
                    .Replace("POCA", "", StringComparison.OrdinalIgnoreCase)
                    .Replace("POGE", "", StringComparison.OrdinalIgnoreCase)
                    .Replace("FPCA", "", StringComparison.OrdinalIgnoreCase)
                    .Replace("ADMN", "", StringComparison.OrdinalIgnoreCase);

                if (!string.IsNullOrWhiteSpace(suffix))
                {
                    return $"CODI{suffix}";
                }
            }

            // Fallback: usa SIGLTABE se disponível
            if (!string.IsNullOrWhiteSpace(SiglTabe))
            {
                return $"CODI{SiglTabe.Trim()}";
            }

            return "ID";
        }
    }

    /// <summary>
    /// Retorna as colunas do grid parseadas do GRCOTABE ou extraídas do SQL.
    /// Formato GRCOTABE: "nome1;largura1;nome2;largura2;..." ou formato INI "[Colunas]..."
    /// Se GRCOTABE estiver vazio ou em formato INI, extrai colunas do GridTabe (SQL aliases).
    /// </summary>
    public List<GridColumnConfig> GetGridColumns()
    {
        var columns = new List<GridColumnConfig>();

        // Tenta primeiro o formato tradicional nome;largura
        if (!string.IsNullOrEmpty(GrCoTabe) && !GrCoTabe.TrimStart().StartsWith("["))
        {
            var parts = GrCoTabe.Split(';', StringSplitOptions.RemoveEmptyEntries);
            for (int i = 0; i < parts.Length - 1; i += 2)
            {
                var name = parts[i].Trim();
                var widthStr = parts[i + 1].Trim();

                if (int.TryParse(widthStr, out var width))
                {
                    columns.Add(new GridColumnConfig
                    {
                        FieldName = name,
                        DisplayName = name,
                        Width = width
                    });
                }
            }

            if (columns.Count > 0)
                return columns;
        }

        // Extrai colunas do SQL (aliases entre aspas ou campos simples)
        if (!string.IsNullOrEmpty(GridTabe))
        {
            columns = ExtractColumnsFromSql(GridTabe);

            // Aplica configurações de visibilidade do GrCoTabe (formato INI)
            if (!string.IsNullOrEmpty(GrCoTabe))
            {
                ApplyColumnVisibility(columns, GrCoTabe);
            }
        }

        return columns;
    }

    /// <summary>
    /// Extrai colunas do SQL SELECT, considerando aliases.
    /// Formato: SELECT campo AS "Alias", campo2 AS "Alias 2" FROM ...
    /// </summary>
    private List<GridColumnConfig> ExtractColumnsFromSql(string sql)
    {
        var columns = new List<GridColumnConfig>();
        if (string.IsNullOrEmpty(sql))
            return columns;

        // Encontra a parte SELECT ... FROM
        var upperSql = sql.ToUpper();
        var selectIndex = upperSql.IndexOf("SELECT");
        var fromIndex = upperSql.IndexOf("FROM");

        if (selectIndex < 0 || fromIndex < 0 || fromIndex <= selectIndex)
            return columns;

        var selectPart = sql.Substring(selectIndex + 6, fromIndex - selectIndex - 6).Trim();

        // Divide por vírgulas, mas respeitando parênteses (funções)
        var columnDefs = SplitSqlColumns(selectPart);

        // Rastreia colunas fonte que já foram aliasadas para evitar duplicatas
        // Ex: se QTDEMVCT AS "Quantidade" apareceu, ignoramos QTDEMVCT quando aparecer depois
        var aliasedSourceColumns = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var colDef in columnDefs)
        {
            var trimmed = colDef.Trim();
            if (string.IsNullOrEmpty(trimmed))
                continue;

            string fieldName;
            string displayName;
            string? sourceColumn = null;

            // Verifica se tem alias com AS "Nome"
            var asMatch = System.Text.RegularExpressions.Regex.Match(
                trimmed,
                @"AS\s+""([^""]+)""",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);

            if (asMatch.Success)
            {
                // Quando há alias com aspas, o Oracle retorna o alias como nome da coluna
                // Então fieldName DEVE ser o alias para acessar corretamente os dados
                displayName = asMatch.Groups[1].Value;
                fieldName = displayName;  // Usa o alias como fieldName

                // Extrai a coluna fonte antes do AS para rastrear
                var beforeAs = trimmed.Substring(0, asMatch.Index).Trim();
                sourceColumn = ExtractFieldName(beforeAs).ToUpperInvariant();
                aliasedSourceColumns.Add(sourceColumn);
            }
            else
            {
                // Sem alias - usa o nome do campo (Oracle converte para maiúsculo)
                fieldName = ExtractFieldName(trimmed).ToUpperInvariant();
                displayName = fieldName;

                // Se esta coluna já foi aliasada antes, ignora a versão raw
                if (aliasedSourceColumns.Contains(fieldName))
                    continue;
            }

            // Ignora a primeira coluna se for PK (CODI*)
            if (columns.Count == 0 && fieldName.StartsWith("CODI", StringComparison.OrdinalIgnoreCase))
                continue;

            // Ignora campos técnicos/internos que não devem aparecer no grid
            // SGCH* = chaves secundárias/hash
            // MARC* = marcadores de status interno
            if (fieldName.StartsWith("SGCH", StringComparison.OrdinalIgnoreCase) ||
                fieldName.StartsWith("MARC", StringComparison.OrdinalIgnoreCase))
                continue;

            // Ignora se já existe (duplicatas)
            if (columns.Any(c => c.FieldName.Equals(fieldName, StringComparison.OrdinalIgnoreCase)))
                continue;

            columns.Add(new GridColumnConfig
            {
                FieldName = fieldName,
                DisplayName = displayName,
                Width = CalculateColumnWidth(displayName),
                Visible = true
            });
        }

        return columns;
    }

    /// <summary>
    /// Divide a parte SELECT em colunas, respeitando parênteses e funções.
    /// </summary>
    private List<string> SplitSqlColumns(string selectPart)
    {
        var columns = new List<string>();
        var current = new System.Text.StringBuilder();
        int parenLevel = 0;

        foreach (char c in selectPart)
        {
            if (c == '(')
            {
                parenLevel++;
                current.Append(c);
            }
            else if (c == ')')
            {
                parenLevel--;
                current.Append(c);
            }
            else if (c == ',' && parenLevel == 0)
            {
                columns.Add(current.ToString());
                current.Clear();
            }
            else
            {
                current.Append(c);
            }
        }

        if (current.Length > 0)
            columns.Add(current.ToString());

        return columns;
    }

    /// <summary>
    /// Extrai o nome do campo de uma expressão SQL.
    /// Ex: "TABELA.CAMPO" -> "CAMPO", "CAMPO" -> "CAMPO"
    /// </summary>
    private string ExtractFieldName(string expression)
    {
        var trimmed = expression.Trim();

        // Se é uma função (CASE, NULO, etc), retorna a expressão toda simplificada
        if (trimmed.Contains("(") || trimmed.ToUpper().StartsWith("CASE"))
        {
            // Para CASE WHEN... usa o alias ou gera nome genérico
            return "EXPR_" + Math.Abs(trimmed.GetHashCode() % 10000);
        }

        // Se tem ponto (TABELA.CAMPO), pega só o campo
        var dotIndex = trimmed.LastIndexOf('.');
        if (dotIndex >= 0)
        {
            return trimmed.Substring(dotIndex + 1).Trim();
        }

        return trimmed;
    }

    /// <summary>
    /// Calcula largura da coluna baseado no nome de exibição.
    /// </summary>
    private int CalculateColumnWidth(string displayName)
    {
        // Largura mínima baseada no tamanho do texto + padding
        var baseWidth = displayName.Length * 8 + 20;
        return Math.Max(80, Math.Min(200, baseWidth));
    }

    /// <summary>
    /// Aplica configurações de visibilidade do formato INI.
    /// Formato: [Colunas]\nCAMPO=/Visi=N
    /// </summary>
    private void ApplyColumnVisibility(List<GridColumnConfig> columns, string iniConfig)
    {
        var lines = iniConfig.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);

        foreach (var line in lines)
        {
            // Ignora seções [...]
            if (line.TrimStart().StartsWith("["))
                continue;

            // Formato: CAMPO=/Visi=N
            var eqIndex = line.IndexOf('=');
            if (eqIndex <= 0)
                continue;

            var fieldName = line.Substring(0, eqIndex).Trim();
            var config = line.Substring(eqIndex + 1).Trim();

            var column = columns.FirstOrDefault(c =>
                c.FieldName.Equals(fieldName, StringComparison.OrdinalIgnoreCase));

            if (column != null && config.Contains("Visi=N", StringComparison.OrdinalIgnoreCase))
            {
                column.Visible = false;
            }
        }

        // Remove colunas invisíveis da lista
        columns.RemoveAll(c => !c.Visible);
    }
}

/// <summary>
/// Configuração de uma coluna do grid de movimento.
/// </summary>
public class GridColumnConfig
{
    /// <summary>
    /// Nome do campo no banco de dados
    /// </summary>
    public string FieldName { get; set; } = string.Empty;

    /// <summary>
    /// Nome de exibição no grid
    /// </summary>
    public string DisplayName { get; set; } = string.Empty;

    /// <summary>
    /// Largura em pixels
    /// </summary>
    public int Width { get; set; } = 100;

    /// <summary>
    /// Indica se a coluna é visível
    /// </summary>
    public bool Visible { get; set; } = true;
}
