namespace SagPoc.Web.Models;

/// <summary>
/// Metadados da tabela obtidos de SISTTABE.
/// </summary>
public class TableMetadata
{
    /// <summary>
    /// Código da tabela (CODITABE)
    /// </summary>
    public int CodiTabe { get; set; }

    /// <summary>
    /// Nome da tabela (NOMETABE)
    /// </summary>
    public string NomeTabe { get; set; } = string.Empty;

    /// <summary>
    /// Nome do form (FORMTABE)
    /// </summary>
    public string FormTabe { get; set; } = string.Empty;

    /// <summary>
    /// Caption da janela (CAPTTABE)
    /// </summary>
    public string CaptTabe { get; set; } = string.Empty;

    /// <summary>
    /// Hint (HINTTABE)
    /// </summary>
    public string HintTabe { get; set; } = string.Empty;

    /// <summary>
    /// Tabela de gravação (GRAVTABE) - ex: "POCATPDO"
    /// </summary>
    public string GravTabe { get; set; } = string.Empty;

    /// <summary>
    /// Campo chave (CHAVTABE) - 1 = primeiro campo
    /// </summary>
    public int ChavTabe { get; set; }

    /// <summary>
    /// Nome da Guia 1 (GUI1TABE)
    /// </summary>
    public string Gui1Tabe { get; set; } = string.Empty;

    /// <summary>
    /// Nome da Guia 2 (GUI2TABE)
    /// </summary>
    public string Gui2Tabe { get; set; } = string.Empty;

    /// <summary>
    /// Parâmetros JSON (PARATABE)
    /// </summary>
    public string? ParaTabe { get; set; }

    /// <summary>
    /// SQL do grid padrão (GRIDTABE)
    /// </summary>
    public string? GridTabe { get; set; }

    /// <summary>
    /// Altura da janela (ALTUTABE)
    /// </summary>
    public int AltuTabe { get; set; }

    /// <summary>
    /// Largura da janela (TAMATABE)
    /// </summary>
    public int TamaTabe { get; set; }

    /// <summary>
    /// Sigla (SIGLTABE)
    /// </summary>
    public string SiglTabe { get; set; } = string.Empty;

    /// <summary>
    /// Parâmetros parseados do JSON
    /// </summary>
    public TableParameters? Parameters => ParseParameters();

    private TableParameters? ParseParameters()
    {
        if (string.IsNullOrEmpty(ParaTabe))
            return null;

        try
        {
            return System.Text.Json.JsonSerializer.Deserialize<TableParameters>(ParaTabe);
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Remove o '&' do nome da guia (usado para atalho de teclado no Delphi)
    /// </summary>
    public string GetCleanGui1Name() => Gui1Tabe?.Replace("&", "") ?? "Dados";

    /// <summary>
    /// Remove o '&' do nome da guia 2
    /// </summary>
    public string GetCleanGui2Name() => Gui2Tabe?.Replace("&", "") ?? "";
}

/// <summary>
/// Parâmetros da tabela (parseados do JSON em PARATABE)
/// </summary>
public class TableParameters
{
    public int campColu { get; set; }
    public int campTama { get; set; }
    public bool btnIncl { get; set; } = true;
    public bool btnAlte { get; set; } = true;
    public bool btnExcl { get; set; } = true;
    public bool btnGraf { get; set; }
    public bool btnEspe { get; set; }
    public bool btnBI { get; set; }
    public bool btnLanc { get; set; }
    public int imagem { get; set; }
    public string? linkBI { get; set; }
    public int campColuMobi { get; set; }
    public int campTamaMobi { get; set; }
}
