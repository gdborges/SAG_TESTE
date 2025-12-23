using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Interface para serviço de consultas e CRUD.
/// </summary>
public interface IConsultaService
{
    /// <summary>
    /// Obtém os metadados da tabela.
    /// </summary>
    Task<TableMetadata?> GetTableMetadataAsync(int tableId);

    /// <summary>
    /// Obtém as consultas disponíveis para uma tabela.
    /// </summary>
    Task<List<ConsultaMetadata>> GetConsultasByTableAsync(int tableId);

    /// <summary>
    /// Obtém uma consulta específica.
    /// </summary>
    Task<ConsultaMetadata?> GetConsultaAsync(int consultaId);

    /// <summary>
    /// Executa uma consulta com filtros e paginação.
    /// </summary>
    Task<GridDataResponse> ExecuteConsultaAsync(GridFilterRequest request);

    /// <summary>
    /// Obtém um registro pelo ID.
    /// </summary>
    Task<Dictionary<string, object?>?> GetRecordByIdAsync(int tableId, int recordId);

    /// <summary>
    /// Salva (insere ou atualiza) um registro.
    /// </summary>
    Task<SaveRecordResponse> SaveRecordAsync(SaveRecordRequest request);

    /// <summary>
    /// Exclui um registro.
    /// </summary>
    Task<SaveRecordResponse> DeleteRecordAsync(int tableId, int recordId);
}
