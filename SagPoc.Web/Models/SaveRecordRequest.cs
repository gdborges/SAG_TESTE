namespace SagPoc.Web.Models;

/// <summary>
/// Request para salvar um registro.
/// </summary>
public class SaveRecordRequest
{
    /// <summary>
    /// ID da tabela (CODITABE)
    /// </summary>
    public int TableId { get; set; }

    /// <summary>
    /// ID do registro (null = inserir novo)
    /// </summary>
    public int? RecordId { get; set; }

    /// <summary>
    /// Campos e valores a salvar
    /// </summary>
    public Dictionary<string, object?> Fields { get; set; } = new();

    /// <summary>
    /// Indica se é um novo registro
    /// </summary>
    public bool IsNew => RecordId == null || RecordId == 0;
}

/// <summary>
/// Response de operação de salvamento.
/// </summary>
public class SaveRecordResponse
{
    /// <summary>
    /// Indica se a operação foi bem sucedida
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Mensagem de retorno
    /// </summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// ID do registro (útil após inserção)
    /// </summary>
    public int? RecordId { get; set; }

    /// <summary>
    /// Erros de validação
    /// </summary>
    public Dictionary<string, string> ValidationErrors { get; set; } = new();
}

/// <summary>
/// Request para executar query de lookup.
/// </summary>
public class LookupQueryRequest
{
    /// <summary>
    /// SQL do lookup (SELECT com 2 colunas: Key, Value)
    /// </summary>
    public string Sql { get; set; } = string.Empty;

    /// <summary>
    /// Filtro opcional para busca
    /// </summary>
    public string? Filter { get; set; }
}

/// <summary>
/// Request para buscar registro de lookup por código digitado.
/// Usado quando o usuário digita diretamente no campo lookup (comportamento TDBLookNume).
/// </summary>
public class LookupByCodeRequest
{
    /// <summary>
    /// SQL do lookup (SQL_CAMP do campo)
    /// </summary>
    public string Sql { get; set; } = string.Empty;

    /// <summary>
    /// Código digitado pelo usuário
    /// </summary>
    public string Code { get; set; } = string.Empty;
}
