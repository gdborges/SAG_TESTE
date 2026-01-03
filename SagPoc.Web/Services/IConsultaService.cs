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

    /// <summary>
    /// Cria um registro vazio (com valores default) para iniciar modo de inclusão.
    /// Usado pelo Saga Pattern: INSERT imediato, DELETE se cancelar.
    /// </summary>
    /// <param name="tableId">ID da tabela</param>
    /// <returns>ID do registro criado</returns>
    Task<int> CreateEmptyRecordAsync(int tableId);

    /// <summary>
    /// Exclui um registro e todos os seus movimentos em cascata.
    /// Usado pelo Saga Pattern ao cancelar uma inclusão.
    /// </summary>
    /// <param name="tableId">ID da tabela pai</param>
    /// <param name="recordId">ID do registro a excluir</param>
    /// <returns>Resultado da operação</returns>
    Task<SaveRecordResponse> DeleteRecordWithMovementsAsync(int tableId, int recordId);

    /// <summary>
    /// Obtém os valores default para campos com InicCamp=1.
    /// Usado para popular o formulário quando o usuário clica em "Novo".
    /// Replica o comportamento do Delphi InicValoCampPers.
    /// </summary>
    /// <param name="tableId">ID da tabela</param>
    /// <returns>Dicionário com nome do campo -> valor default</returns>
    Task<Dictionary<string, object?>> GetFieldDefaultsAsync(int tableId);
}
