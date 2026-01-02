using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Interface para operações CRUD em tabelas de movimento.
/// </summary>
public interface IMovementService
{
    /// <summary>
    /// Obtém os dados do grid de movimento.
    /// </summary>
    /// <param name="parentId">ID do registro pai (cabeçalho)</param>
    /// <param name="movementTableId">Código da tabela de movimento</param>
    /// <param name="page">Página atual (1-based)</param>
    /// <param name="pageSize">Registros por página</param>
    /// <returns>Dados paginados do grid</returns>
    Task<MovementGridData> GetMovementDataAsync(int parentId, int movementTableId, int page = 1, int pageSize = 50);

    /// <summary>
    /// Obtém um registro de movimento para edição.
    /// </summary>
    /// <param name="movementTableId">Código da tabela de movimento</param>
    /// <param name="recordId">ID do registro</param>
    /// <returns>Dados do registro ou null se não encontrado</returns>
    Task<Dictionary<string, object?>?> GetMovementRecordAsync(int movementTableId, int recordId);

    /// <summary>
    /// Insere um novo registro de movimento.
    /// </summary>
    /// <param name="movementTableId">Código da tabela de movimento</param>
    /// <param name="parentId">ID do registro pai</param>
    /// <param name="fields">Campos e valores do registro</param>
    /// <returns>Resultado da operação</returns>
    Task<MovementSaveResult> InsertMovementAsync(int movementTableId, int parentId, Dictionary<string, object?> fields);

    /// <summary>
    /// Atualiza um registro de movimento existente.
    /// </summary>
    /// <param name="movementTableId">Código da tabela de movimento</param>
    /// <param name="recordId">ID do registro</param>
    /// <param name="fields">Campos e valores atualizados</param>
    /// <returns>Resultado da operação</returns>
    Task<MovementSaveResult> UpdateMovementAsync(int movementTableId, int recordId, Dictionary<string, object?> fields);

    /// <summary>
    /// Exclui um registro de movimento.
    /// </summary>
    /// <param name="movementTableId">Código da tabela de movimento</param>
    /// <param name="recordId">ID do registro</param>
    /// <returns>Resultado da operação</returns>
    Task<MovementSaveResult> DeleteMovementAsync(int movementTableId, int recordId);

    /// <summary>
    /// Obtém os metadados de uma tabela de movimento.
    /// </summary>
    /// <param name="movementTableId">Código da tabela de movimento</param>
    /// <returns>Metadados ou null se não encontrado</returns>
    Task<MovementMetadata?> GetMovementMetadataAsync(int movementTableId);

    /// <summary>
    /// Valida se a tabela de movimento pertence ao cabeçalho especificado.
    /// </summary>
    /// <param name="parentTableId">Código da tabela cabeçalho</param>
    /// <param name="movementTableId">Código da tabela de movimento</param>
    /// <returns>True se válido</returns>
    Task<bool> ValidateMovementTableAsync(int parentTableId, int movementTableId);
}

/// <summary>
/// Dados paginados do grid de movimento.
/// </summary>
public class MovementGridData
{
    /// <summary>
    /// Registros da página atual
    /// </summary>
    public List<Dictionary<string, object?>> Data { get; set; } = new();

    /// <summary>
    /// Total de registros (todas as páginas)
    /// </summary>
    public int TotalRecords { get; set; }

    /// <summary>
    /// Total de páginas
    /// </summary>
    public int TotalPages { get; set; }

    /// <summary>
    /// Página atual
    /// </summary>
    public int CurrentPage { get; set; }

    /// <summary>
    /// Registros por página
    /// </summary>
    public int PageSize { get; set; }

    /// <summary>
    /// Colunas do grid (parseadas do GRCOTABE)
    /// </summary>
    public List<GridColumnConfig> Columns { get; set; } = new();

    /// <summary>
    /// Nome da coluna PK
    /// </summary>
    public string PkColumnName { get; set; } = string.Empty;

    /// <summary>
    /// Totais calculados para campos do cabeçalho (ex: soma de quantidades/valores).
    /// Chave: nome do campo do cabeçalho (ex: TOQTMVCT)
    /// Valor: valor calculado
    /// </summary>
    public Dictionary<string, object?> Totals { get; set; } = new();
}

/// <summary>
/// Resultado de operação de salvamento de movimento.
/// </summary>
public class MovementSaveResult
{
    /// <summary>
    /// Indica se a operação foi bem sucedida
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Mensagem de resultado ou erro
    /// </summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// ID do registro (para INSERT, o novo ID gerado)
    /// </summary>
    public int? RecordId { get; set; }

    /// <summary>
    /// Dados adicionais retornados pela operação
    /// </summary>
    public Dictionary<string, object?>? Data { get; set; }
}
