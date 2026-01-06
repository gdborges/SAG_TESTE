namespace SagPoc.Web.Models;

/// <summary>
/// Metadados de consulta obtidos de SISTCONS.
/// </summary>
public class ConsultaMetadata
{
    /// <summary>
    /// Código da consulta (CODICONS)
    /// </summary>
    public int CodiCons { get; set; }

    /// <summary>
    /// Código da tabela (CODITABE)
    /// </summary>
    public int CodiTabe { get; set; }

    /// <summary>
    /// Nome da consulta (NOMECONS)
    /// </summary>
    public string NomeCons { get; set; } = string.Empty;

    /// <summary>
    /// Identificador único da consulta (BUSCCONS) - ex: "TPDO000-Padrão"
    /// </summary>
    public string BuscCons { get; set; } = string.Empty;

    /// <summary>
    /// SQL completo da consulta (SQL_CONS)
    /// </summary>
    public string? SqlCons { get; set; }

    /// <summary>
    /// Configuração de colunas (FILTCONS)
    /// Formato: "[COLUNAS]\nTipo=/Tama=200\nAtivo=/Tama=50\n..."
    /// </summary>
    public string? FiltCons { get; set; }

    /// <summary>
    /// WHERE adicional (WHERCONS)
    /// </summary>
    public string? WherCons { get; set; }

    /// <summary>
    /// ORDER BY (ORBYCONS)
    /// </summary>
    public string? OrByCons { get; set; }

    /// <summary>
    /// Acesso (ACCECONS)
    /// </summary>
    public int AcceCons { get; set; } = 1;

    /// <summary>
    /// Ativo (ATIVCONS)
    /// </summary>
    public int AtivCons { get; set; } = 1;

    /// <summary>
    /// Colunas parseadas
    /// </summary>
    private List<GridColumn>? _columns;

    /// <summary>
    /// Obtém as colunas da consulta parseadas do FILTCONS.
    /// </summary>
    public List<GridColumn> GetColumns()
    {
        if (_columns != null)
            return _columns;

        _columns = new List<GridColumn>();

        if (string.IsNullOrEmpty(FiltCons))
            return _columns;

        var lines = FiltCons.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        foreach (var line in lines)
        {
            var trimmedLine = line.Trim();

            // Ignora linhas de seção
            if (trimmedLine.StartsWith("["))
                continue;

            // Formato: "Nome=/Tama=200" ou "Bloqueio Comercial=/Tama=90"
            var parts = trimmedLine.Split("=/", 2);
            if (parts.Length >= 1)
            {
                var displayName = parts[0].Trim();
                if (string.IsNullOrEmpty(displayName))
                    continue;

                int width = 100; // Default
                if (parts.Length > 1)
                {
                    // Extrai Tama=XXX
                    var config = parts[1];
                    var tamaMatch = System.Text.RegularExpressions.Regex.Match(config, @"Tama=(\d+)");
                    if (tamaMatch.Success)
                    {
                        width = int.Parse(tamaMatch.Groups[1].Value);
                    }
                }

                _columns.Add(new GridColumn
                {
                    FieldName = displayName, // Usa o nome de exibição como nome do campo
                    DisplayName = displayName,
                    Width = width
                });
            }
        }

        return _columns;
    }
}

/// <summary>
/// Representa uma coluna do grid.
/// </summary>
public class GridColumn
{
    /// <summary>
    /// Nome do campo (alias no SQL)
    /// </summary>
    public string FieldName { get; set; } = string.Empty;

    /// <summary>
    /// Nome para exibição
    /// </summary>
    public string DisplayName { get; set; } = string.Empty;

    /// <summary>
    /// Largura em pixels
    /// </summary>
    public int Width { get; set; } = 100;
}

/// <summary>
/// Resposta da API GetConsultas com fonte dos dados.
/// </summary>
public class ConsultasResponse
{
    /// <summary>
    /// Lista de consultas disponíveis
    /// </summary>
    public List<ConsultaMetadata> Consultas { get; set; } = new();

    /// <summary>
    /// Fonte dos dados: "SISTCONS" ou "SISTTABE"
    /// </summary>
    public string Source { get; set; } = "SISTCONS";
}
