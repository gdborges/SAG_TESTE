using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Interface para serviço de leitura de metadados do banco SAG.
/// </summary>
public interface IMetadataService
{
    /// <summary>
    /// Obtém os metadados de todos os campos de uma tabela/formulário.
    /// </summary>
    /// <param name="codiTabe">ID da tabela (ex: 210 para TipDoc)</param>
    /// <returns>FormMetadata com todos os campos</returns>
    Task<FormMetadata> GetFormMetadataAsync(int codiTabe);

    /// <summary>
    /// Obtém a lista de campos de uma tabela.
    /// </summary>
    /// <param name="codiTabe">ID da tabela</param>
    /// <returns>Lista de FieldMetadata</returns>
    Task<IEnumerable<FieldMetadata>> GetFieldsByTableAsync(int codiTabe);

    /// <summary>
    /// Lista todas as tabelas disponíveis no sistema.
    /// </summary>
    /// <returns>Dicionário com ID e nome das tabelas</returns>
    Task<Dictionary<int, string>> GetAvailableTablesAsync();

    /// <summary>
    /// Obtém as tabelas de movimento (filhos) de um cabeçalho.
    /// Busca tabelas onde CABETABE = parentCodiTabe.
    /// </summary>
    /// <param name="parentCodiTabe">Código da tabela pai (cabeçalho)</param>
    /// <param name="loadChildren">Se true, carrega sub-movimentos recursivamente (até 2 níveis)</param>
    /// <returns>Lista de MovementMetadata</returns>
    Task<List<MovementMetadata>> GetMovementTablesAsync(int parentCodiTabe, bool loadChildren = true);

    /// <summary>
    /// Obtém os campos de um movimento para o modal de edição.
    /// </summary>
    /// <param name="movementCodiTabe">Código da tabela de movimento</param>
    /// <returns>Lista de campos do movimento</returns>
    Task<List<FieldMetadata>> GetMovementFieldsAsync(int movementCodiTabe);

    /// <summary>
    /// Obtém o SQL de lookup de um campo pelo CodiCamp.
    /// </summary>
    /// <param name="codiCamp">ID do campo</param>
    /// <returns>SQL do lookup ou null se não encontrado</returns>
    Task<string?> GetFieldLookupSqlAsync(int codiCamp);
}
