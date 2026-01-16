using SagPoc.Web.Services.Context;

namespace SagPoc.Web.Models;

/// <summary>
/// ViewModel para renderização do formulário com guia de consulta.
/// </summary>
public class FormRenderViewModel
{
    /// <summary>
    /// Contexto de sessão SAG (usuário, empresa, módulo)
    /// </summary>
    public SagContext? SagContext { get; set; }

    /// <summary>
    /// Metadados do formulário (campos)
    /// </summary>
    public FormMetadata Form { get; set; } = new();

    /// <summary>
    /// Metadados da tabela (SISTTABE)
    /// </summary>
    public TableMetadata? Table { get; set; }

    /// <summary>
    /// Lista de consultas disponíveis (SISTCONS)
    /// </summary>
    public List<ConsultaMetadata> Consultas { get; set; } = new();

    /// <summary>
    /// Eventos do formulário (ciclo de vida PLSAG)
    /// </summary>
    public FormEventData? FormEvents { get; set; }

    /// <summary>
    /// Eventos dos campos (PLSAG)
    /// </summary>
    public Dictionary<int, FieldEventData> FieldEvents { get; set; } = new();

    /// <summary>
    /// Indica se existem consultas configuradas para esta tabela
    /// </summary>
    public bool HasConsultas => Consultas.Any();

    /// <summary>
    /// ID do registro em edição (null = novo)
    /// </summary>
    public int? EditingRecordId { get; set; }

    /// <summary>
    /// Modo de edição: "new", "edit", ou null
    /// </summary>
    public string? EditMode { get; set; }

    /// <summary>
    /// Nome da guia Consulta
    /// </summary>
    public string ConsultaTabName => "Consulta";

    /// <summary>
    /// Nome da primeira guia de dados (vem de GUI1TABE ou default)
    /// </summary>
    public string DadosTabName => Table?.GetCleanGui1Name() ?? "Dados Gerais";

    /// <summary>
    /// Nome da segunda guia de dados (vem de GUI2TABE, se existir)
    /// </summary>
    public string? DadosTab2Name => string.IsNullOrEmpty(Table?.GetCleanGui2Name())
        ? null
        : Table?.GetCleanGui2Name();

    /// <summary>
    /// Indica se deve mostrar botão Incluir
    /// </summary>
    public bool ShowBtnIncluir => Table?.Parameters?.btnIncl ?? true;

    /// <summary>
    /// Indica se deve mostrar botão Alterar
    /// </summary>
    public bool ShowBtnAlterar => Table?.Parameters?.btnAlte ?? true;

    /// <summary>
    /// Indica se deve mostrar botão Excluir
    /// </summary>
    public bool ShowBtnExcluir => Table?.Parameters?.btnExcl ?? true;
}
