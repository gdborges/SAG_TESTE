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
}
