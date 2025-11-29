namespace SagPoc.Web.Models;

/// <summary>
/// Modelo que representa um campo do formulário dinâmico.
/// Mapeado da tabela SistCamp do banco SAG.
/// </summary>
public class FieldMetadata
{
    // Identificação
    public int CodiCamp { get; set; }      // ID único do campo
    public int CodiTabe { get; set; }      // ID da tabela/formulário

    // Dados do campo
    public string NomeCamp { get; set; } = string.Empty;  // Nome do campo no banco (ex: NOMETPDO)
    public string LabeCamp { get; set; } = string.Empty;  // Label exibido (ex: "Nome")
    public string HintCamp { get; set; } = string.Empty;  // Tooltip/hint
    public string CompCamp { get; set; } = string.Empty;  // Tipo de componente (E, N, C, S, BVL, etc.)

    // Posicionamento (pixels no Delphi)
    public int TopoCamp { get; set; }      // Posição Y (topo)
    public int EsquCamp { get; set; }      // Posição X (esquerda)
    public int TamaCamp { get; set; }      // Largura
    public int AltuCamp { get; set; }      // Altura

    // Organização
    public int GuiaCamp { get; set; }      // Aba/Tab do campo
    public int OrdeCamp { get; set; }      // Ordem de tabulação

    // Comportamento
    public int ObriCamp { get; set; }      // Campo obrigatório (1=sim)
    public int DesaCamp { get; set; }      // Campo desabilitado (1=sim)
    public int InicCamp { get; set; }      // Inicialmente desabilitado

    // Formatação
    public string MascCamp { get; set; } = string.Empty;  // Máscara de entrada
    public double? MiniCamp { get; set; }  // Valor mínimo
    public double? MaxiCamp { get; set; }  // Valor máximo
    public int DeciCamp { get; set; }      // Casas decimais

    // Lookup/Combo
    public string? SqlCamp { get; set; }   // Query para lookup
    public string? VareCamp { get; set; }  // Valores do combo (texto separado)

    // Visual
    public string? CfonCamp { get; set; }  // Fonte do campo
    public int? CtamCamp { get; set; }     // Tamanho da fonte
    public int? CcorCamp { get; set; }     // Cor do campo
    public string? LfonCamp { get; set; }  // Fonte do label
    public int? LtamCamp { get; set; }     // Tamanho fonte label
    public int? LcorCamp { get; set; }     // Cor do label

    // Expressões (para documentação futura)
    public string? ExprCamp { get; set; }  // Expressões do campo
    public string? EperCamp { get; set; }  // Expressões de permissão

    /// <summary>
    /// Indica se o campo é obrigatório
    /// </summary>
    public bool IsRequired => ObriCamp == 1;

    /// <summary>
    /// Indica se o campo está desabilitado permanentemente.
    /// Nota: InicCamp é ignorado na POC (no Delphi, é controlado por expressões em runtime).
    /// </summary>
    public bool IsDisabled => DesaCamp == 1;

    /// <summary>
    /// Retorna o tipo HTML equivalente baseado no CompCamp
    /// </summary>
    public string GetHtmlInputType()
    {
        return CompCamp?.ToUpper() switch
        {
            "E" => "text",           // TDBEdtLbl → input text
            "N" => "number",         // TDBRxELbl → input number
            "D" => "date",           // TDBRxDLbl → input date
            "S" => "checkbox",       // TDBChkLbl → checkbox
            "C" => "select",         // TDBCmbLbl → select/combo
            "T" or "IT" => "select", // TDBLcbLbl → select com lookup
            "M" or "BM" => "textarea", // TDBMemLbl → textarea
            _ => "text"
        };
    }

    /// <summary>
    /// Retorna o tipo de componente para renderização
    /// </summary>
    public ComponentType GetComponentType()
    {
        return CompCamp?.ToUpper() switch
        {
            "E" => ComponentType.TextInput,
            "N" => ComponentType.NumberInput,
            "D" => ComponentType.DateInput,
            "S" => ComponentType.Checkbox,
            "C" => ComponentType.ComboBox,
            "T" or "IT" => ComponentType.LookupCombo,
            "M" or "BM" => ComponentType.TextArea,
            "BVL" => ComponentType.Bevel,
            "BTN" => ComponentType.Button,
            "LBL" => ComponentType.Label,
            "DBG" => ComponentType.DataGrid,
            _ => ComponentType.TextInput
        };
    }
}

/// <summary>
/// Tipos de componentes suportados
/// </summary>
public enum ComponentType
{
    TextInput,      // E - TDBEdtLbl
    NumberInput,    // N - TDBRxELbl
    DateInput,      // D - TDBRxDLbl
    Checkbox,       // S - TDBChkLbl
    ComboBox,       // C - TDBCmbLbl
    LookupCombo,    // T/IT - TDBLcbLbl
    TextArea,       // M/BM - TDBMemLbl
    Bevel,          // BVL - TsgBvl (agrupador visual)
    Button,         // BTN - TsgBtn
    Label,          // LBL - TsgLbl
    DataGrid        // DBG - TsgDBG
}
