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
    public string NameCamp { get; set; } = string.Empty;  // Nome do componente visual (usado pelo PLSAG para FindComponent)
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
    public int LbcxCamp { get; set; }      // Label Box - Mostra caption em Bevel (1=sim)

    // Formatação
    public string MascCamp { get; set; } = string.Empty;  // Máscara de entrada
    public double? MiniCamp { get; set; }  // Valor mínimo
    public double? MaxiCamp { get; set; }  // Valor máximo
    public int DeciCamp { get; set; }      // Casas decimais
    public double? PadrCamp { get; set; }  // Valor padrão (usado em checkboxes)

    // Lookup/Combo
    public string? SqlCamp { get; set; }   // Query para lookup
    public string? VareCamp { get; set; }  // Valores do combo (texto exibido, separado por |)
    public string? VaGrCamp { get; set; }  // Valores de gravação do combo (separado por |, usado como value)

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

    // Lookup dinâmico (populado pelo controller)
    /// <summary>
    /// Opções carregadas do SQL_CAMP (populado pelo controller para campos T/IT)
    /// </summary>
    public List<LookupItem>? LookupOptions { get; set; }

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
    /// Indica se é campo "Informada" (IT, IL, etc.) - somente leitura/informativo.
    /// No Delphi: IT usa TLcbLbl (não persiste), T usa TDBLcbLbl (persiste).
    /// Na POC: IT renderiza como disabled para indicar que é informativo.
    /// </summary>
    public bool IsInformada => CompCamp?.ToUpper().StartsWith("I") == true;

    /// <summary>
    /// Indica se o Bevel deve exibir caption (LbcxCamp = 1).
    /// No Delphi, quando LbcxCamp != 0, o Bevel mostra o LabeCamp como título.
    /// </summary>
    public bool HasBevelCaption => LbcxCamp != 0;

    /// <summary>
    /// Indica se o campo pertence a um movimento (registro filho/detalhe).
    /// No Delphi (PlusUni.pas linha 691): GuiaCamp >= 10 significa movimento.
    /// Movimentos são renderizados em abas separadas com grid próprio.
    /// </summary>
    public bool IsMovementField => GuiaCamp >= 10;

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
    /// Retorna o tipo de componente para renderização.
    /// Mapeamento completo baseado na procedure MontCampPers (PlusUni.pas).
    /// </summary>
    public ComponentType GetComponentType()
    {
        var comp = CompCamp?.ToUpper()?.Trim() ?? "";

        // Primeiro verifica campos especiais pelo nome
        var nome = NomeCamp?.ToUpper()?.Trim() ?? "";
        if (nome == "DEPOSHOW" || nome == "ATUAGRID")
            return ComponentType.Hidden;

        return comp switch
        {
            // === Tipos Básicos (DB-Aware) ===
            "E" => ComponentType.TextInput,           // TDBEdtLbl - Editor texto
            "N" => ComponentType.NumberInput,         // TDBRxELbl - Editor numérico
            "D" => ComponentType.DateInput,           // TDBRxDLbl - Editor data
            "S" => ComponentType.Checkbox,            // TDBChkLbl - Checkbox
            "C" => ComponentType.ComboBox,            // TDBCmbLbl - ComboBox fixo
            "T" => ComponentType.LookupCombo,         // TDBLcbLbl - Lookup com SQL (persiste)
            "IT" => ComponentType.LookupComboInfo,    // TLcbLbl - Lookup informativo (não persiste)
            "L" => ComponentType.LookupModal,         // TDBLookNume - Lookup modal (persiste)
            "IL" => ComponentType.LookupModalInfo,    // TDBLookNume - Lookup modal informativo
            "M" => ComponentType.TextArea,            // TDBMemLbl - Memo simples
            "BM" => ComponentType.TextAreaBlob,       // TDBMemLbl - Memo BLOB
            "A" => ComponentType.FileInput,           // TDBFilLbl - Upload de arquivo

            // === Tipos Calculados (não-DB) ===
            "EE" => ComponentType.CalcTextInput,      // TEdtLbl - Editor texto calculado editável
            "LE" => ComponentType.CalcTextReadonly,   // TEdtLbl - Editor texto calculado readonly
            "EN" => ComponentType.CalcNumberInput,    // TRxEdtLbl - Número calculado editável
            "LN" => ComponentType.CalcNumberReadonly, // TRxEdtLbl - Número calculado readonly
            "ED" => ComponentType.CalcDateInput,      // TRxDatLbl - Data calculada
            "EC" => ComponentType.CalcComboBox,       // TCmbLbl - Combo calculado
            "ES" => ComponentType.CalcCheckbox,       // TChkLbl - Checkbox calculado
            "ET" => ComponentType.CalcMemo,           // TMemLbl - Memo calculado
            "EA" => ComponentType.CalcFileInput,      // TFilLbl - Arquivo calculado
            "EI" => ComponentType.DirectoryInput,     // TDirLbl - Seletor de diretório

            // === Tipos Info (readonly, dados de outra tabela via VaGrCamp) ===
            "IE" => ComponentType.InfoTextInput,      // TDBEdtLbl - Info texto readonly
            "IN" => ComponentType.InfoNumberInput,    // TDBRxELbl - Info número readonly
            "IM" => ComponentType.InfoTextArea,       // TDBMemLbl - Info memo readonly
            "IR" => ComponentType.InfoRichEdit,       // TDBRchLbl - Info RichEdit readonly

            // === Tipos RichEdit ===
            "RM" => ComponentType.RichEdit,           // TDBRchLbl - RichEdit DB-Aware
            "RB" => ComponentType.RichEditBlob,       // TDBRchLbl - RichEdit BLOB

            // === Tipos Advanced Memo (com syntax highlighting) ===
            "BS" => ComponentType.AdvMemoSQL,         // TDBAdvMemLbl - Memo SQL
            "BE" => ComponentType.AdvMemoGeneral,     // TDBAdvMemLbl - Memo geral (PLSAG)
            "BI" => ComponentType.AdvMemoINI,         // TDBAdvMemLbl - Memo INI
            "BP" => ComponentType.AdvMemoPascal,      // TDBAdvMemLbl - Memo Pascal
            "BX" => ComponentType.AdvMemoXML,         // TDBAdvMemLbl - Memo XML
            "RS" => ComponentType.AdvRichSQL,         // TDBAdvMemLbl - RichEdit SQL
            "RE" => ComponentType.AdvRichGeneral,     // TDBAdvMemLbl - RichEdit geral
            "RI" => ComponentType.AdvRichINI,         // TDBAdvMemLbl - RichEdit INI
            "RP" => ComponentType.AdvRichPascal,      // TDBAdvMemLbl - RichEdit Pascal
            "RX" => ComponentType.AdvRichXML,         // TDBAdvMemLbl - RichEdit XML

            // === Tipos Visuais ===
            "BVL" => ComponentType.Bevel,             // TsgBvl - Agrupador visual
            "BTN" => ComponentType.Button,            // TsgBtn - Botão
            "LBL" => ComponentType.Label,             // TsgLbl - Label estático
            "DBG" => ComponentType.DataGrid,          // TsgDBG - Grid de dados
            "GRA" => ComponentType.Chart,             // TFraGraf - Gráfico
            "TIM" => ComponentType.Timer,             // TsgTim - Timer
            "LC" => ComponentType.CheckList,          // TLstLbl - Lista de checkboxes

            // === Tipos de Imagem ===
            "FE" => ComponentType.ImageEditable,      // TDBImgLbl - Imagem editável
            "FI" => ComponentType.ImageReadonly,      // TDBImgLbl - Imagem somente leitura
            "FF" => ComponentType.ImageFixed,         // TImgLbl - Imagem fixa

            // === Campos especiais que devem ser ocultos ===
            "DEPOSHOW" or "ATUAGRID" => ComponentType.Hidden,

            _ => ComponentType.TextInput              // Fallback para input texto
        };
    }

    /// <summary>
    /// Indica se o campo deve ser oculto (não renderizado visualmente).
    /// Campos ocultos: DEPOSHOW, ATUAGRID, OrdeCamp=9999
    /// </summary>
    public bool IsHidden
    {
        get
        {
            // Campos especiais pelo nome
            var nome = NomeCamp?.ToUpper()?.Trim() ?? "";
            if (nome == "DEPOSHOW" || nome == "ATUAGRID")
                return true;

            // Campos com OrdeCamp = 9999 não recebem foco no Delphi
            if (OrdeCamp == 9999)
                return true;

            // Verifica pelo tipo
            return GetComponentType() == ComponentType.Hidden;
        }
    }

    /// <summary>
    /// Indica se o campo é somente leitura (tipos Info, Calc Readonly, etc.)
    /// </summary>
    public bool IsReadonly
    {
        get
        {
            var type = GetComponentType();
            return type switch
            {
                // Tipos calculados readonly
                ComponentType.CalcTextReadonly => true,
                ComponentType.CalcNumberReadonly => true,
                // Tipos info (dados de outra tabela)
                ComponentType.InfoTextInput => true,
                ComponentType.InfoNumberInput => true,
                ComponentType.InfoTextArea => true,
                ComponentType.InfoRichEdit => true,
                // Tipos de imagem somente leitura
                ComponentType.ImageReadonly => true,
                ComponentType.ImageFixed => true,
                _ => false
            };
        }
    }

    /// <summary>
    /// Indica se o campo é um componente visual (não de entrada de dados).
    /// Componentes visuais: Bevel, Button, Label, DataGrid, Chart, Timer, CheckList
    /// </summary>
    public bool IsVisualComponent
    {
        get
        {
            var type = GetComponentType();
            return type switch
            {
                ComponentType.Bevel => true,
                ComponentType.Button => true,
                ComponentType.Label => true,
                ComponentType.DataGrid => true,
                ComponentType.Chart => true,
                ComponentType.Timer => true,
                ComponentType.CheckList => true,
                ComponentType.ImageFixed => true,
                _ => false
            };
        }
    }
}

/// <summary>
/// Tipos de componentes suportados - Mapeamento completo do MontCampPers (Delphi)
/// </summary>
public enum ComponentType
{
    // === Tipos Básicos (DB-Aware) ===
    TextInput,          // E - TDBEdtLbl - Editor texto simples
    NumberInput,        // N - TDBRxELbl - Editor numérico com decimais
    DateInput,          // D - TDBRxDLbl - Editor de data
    Checkbox,           // S - TDBChkLbl - Checkbox sim/não
    ComboBox,           // C - TDBCmbLbl - ComboBox com valores fixos (VareCamp)
    LookupCombo,        // T - TDBLcbLbl - Lookup com SQL (DB-Aware, persiste)
    LookupComboInfo,    // IT - TLcbLbl - Lookup com SQL (não-DB, informativo)
    LookupModal,        // L - TDBLookNume - Lookup modal numérico (DB-Aware)
    LookupModalInfo,    // IL - TDBLookNume - Lookup modal informativo (não-DB)
    TextArea,           // M - TDBMemLbl - Memo/textarea
    TextAreaBlob,       // BM - TDBMemLbl - Memo armazenado em BLOB

    // === Tipos Calculados (não-DB) ===
    CalcTextInput,      // EE - TEdtLbl - Editor texto calculado editável
    CalcTextReadonly,   // LE - TEdtLbl - Editor texto calculado readonly
    CalcNumberInput,    // EN - TRxEdtLbl - Número calculado editável
    CalcNumberReadonly, // LN - TRxEdtLbl - Número calculado readonly
    CalcDateInput,      // ED - TRxDatLbl - Data calculada
    CalcComboBox,       // EC - TCmbLbl - Combo calculado
    CalcCheckbox,       // ES - TChkLbl - Checkbox calculado
    CalcMemo,           // ET - TMemLbl - Memo calculado (não-DB)

    // === Tipos de Arquivo ===
    FileInput,          // A - TDBFilLbl - Upload de arquivo (DB-Aware)
    CalcFileInput,      // EA - TFilLbl - Arquivo calculado
    DirectoryInput,     // EI - TDirLbl - Seletor de diretório

    // === Tipos Info (readonly, dados de outra tabela) ===
    InfoTextInput,      // IE - TDBEdtLbl - Info texto (readonly, outra tabela)
    InfoNumberInput,    // IN - TDBRxELbl - Info número (readonly, outra tabela)
    InfoTextArea,       // IM - TDBMemLbl - Info memo (readonly, outra tabela)
    InfoRichEdit,       // IR - TDBRchLbl - Info RichEdit (readonly, outra tabela)

    // === Tipos RichEdit ===
    RichEdit,           // RM - TDBRchLbl - RichEdit DB-Aware
    RichEditBlob,       // RB - TDBRchLbl - RichEdit armazenado em BLOB

    // === Tipos Advanced Memo (com syntax highlighting) ===
    AdvMemoSQL,         // BS - TDBAdvMemLbl - Memo avançado SQL
    AdvMemoGeneral,     // BE - TDBAdvMemLbl - Memo avançado geral
    AdvMemoINI,         // BI - TDBAdvMemLbl - Memo avançado INI
    AdvMemoPascal,      // BP - TDBAdvMemLbl - Memo avançado Pascal
    AdvMemoXML,         // BX - TDBAdvMemLbl - Memo avançado XML
    AdvRichSQL,         // RS - TDBAdvMemLbl - RichEdit avançado SQL
    AdvRichGeneral,     // RE - TDBAdvMemLbl - RichEdit avançado geral
    AdvRichINI,         // RI - TDBAdvMemLbl - RichEdit avançado INI
    AdvRichPascal,      // RP - TDBAdvMemLbl - RichEdit avançado Pascal
    AdvRichXML,         // RX - TDBAdvMemLbl - RichEdit avançado XML

    // === Tipos Visuais ===
    Bevel,              // BVL - TsgBvl - Agrupador visual (fieldset)
    Button,             // BTN - TsgBtn - Botão
    Label,              // LBL - TsgLbl - Label estático
    DataGrid,           // DBG - TsgDBG - Grid de dados
    Chart,              // GRA - TFraGraf - Gráfico
    Timer,              // TIM - TsgTim - Timer (não visual)
    CheckList,          // LC - TLstLbl - Lista de checkboxes

    // === Tipos de Imagem ===
    ImageEditable,      // FE - TDBImgLbl - Imagem editável (upload)
    ImageReadonly,      // FI - TDBImgLbl - Imagem somente leitura
    ImageFixed,         // FF - TImgLbl - Imagem fixa (do banco)

    // === Tipos Ocultos ===
    Hidden              // DEPOSHOW, ATUAGRID, campos especiais - não renderizados
}

/// <summary>
/// Item de lookup para combos T/IT (carregado via SQL_CAMP)
/// </summary>
public class LookupItem
{
    /// <summary>
    /// Chave/ID do item (primeira coluna do SQL_CAMP)
    /// </summary>
    public string Key { get; set; } = string.Empty;

    /// <summary>
    /// Valor/descrição do item (segunda coluna do SQL_CAMP)
    /// </summary>
    public string Value { get; set; } = string.Empty;
}
