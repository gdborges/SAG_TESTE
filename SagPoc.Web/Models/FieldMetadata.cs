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
            // Tipos básicos
            "E" => "text",
            "N" => "number",
            "D" => "date",
            "S" => "checkbox",
            "C" => "select",
            "T" or "IT" => "select",
            "M" or "BM" => "textarea",

            // Tipos estendidos
            "ES" => "checkbox",        // Editor Sim/Não
            "EC" => "select",          // Editor Combo
            "EN" or "LN" => "number",  // Editor Numérico
            "ED" => "date",            // Editor Data
            "EA" or "EE" or "LE" or "EI" or "ET" => "text",

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
            // Tipos básicos
            "E" => ComponentType.TextInput,           // TDBEdtLbl - Editor texto
            "N" => ComponentType.NumberInput,         // TDBRxELbl - Editor numérico
            "D" => ComponentType.DateInput,           // TDBRxDLbl - Editor data
            "S" => ComponentType.Checkbox,            // TDBChkLbl - Checkbox
            "C" => ComponentType.ComboBox,            // TDBCmbLbl - ComboBox
            "T" or "IT" => ComponentType.LookupCombo, // TDBLcbLbl - Lookup combo
            "M" or "BM" => ComponentType.TextArea,    // TDBMemLbl - Memo/TextArea

            // Tipos estendidos (E = Editor + sufixo)
            "ES" => ComponentType.Checkbox,           // TChkLbl - Editor Sim/Não (Checkbox)
            "EC" => ComponentType.ComboBox,           // TCmbLbl - Editor Combo (ComboBox fixo)
            "EN" or "LN" => ComponentType.NumberInput, // Editor Numérico estendido
            "ED" => ComponentType.DateInput,          // Editor Data estendido
            "EA" => ComponentType.TextInput,          // TFilLbl - Editor Arquivo (texto por ora)
            "EE" or "LE" => ComponentType.TextInput,  // Editor Especial (texto por ora)
            "EI" => ComponentType.TextInput,          // Editor Inteiro (texto por ora)
            "ET" => ComponentType.TextInput,          // Editor Texto estendido

            // Componentes visuais
            "BVL" => ComponentType.Bevel,             // TsgBvl - Agrupador visual
            "BTN" => ComponentType.Button,            // TsgBtn - Botão
            "LBL" => ComponentType.Label,             // TsgLbl - Label
            "DBG" => ComponentType.DataGrid,          // TsgDBG - Grid

            _ => ComponentType.TextInput              // Fallback para input texto
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
