using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço para geração de números sequenciais.
/// Suporta dois modos:
/// - _UN_: Usa tabela POCANUME para sequências centralizadas
/// - SEQU: Usa MAX(campo)+1 na tabela de destino
/// </summary>
public interface ISequenceService
{
    /// <summary>
    /// Obtém próximo número da sequência centralizada (POCANUME).
    /// Incrementa automaticamente o contador.
    /// </summary>
    /// <param name="codiNume">Código da sequência em POCANUME</param>
    /// <returns>Resultado com valor gerado ou erro</returns>
    Task<SequenceResult> GetNextSequenceAsync(int codiNume);

    /// <summary>
    /// Obtém próximo número usando MAX+1 na tabela de destino.
    /// Usado quando TagQCamp=1 mas não há entrada em POCANUME.
    /// </summary>
    /// <param name="tableName">Nome físico da tabela</param>
    /// <param name="columnName">Nome da coluna numérica</param>
    /// <returns>Resultado com valor gerado ou erro</returns>
    Task<SequenceResult> GetNextMaxPlusOneAsync(string tableName, string columnName);

    /// <summary>
    /// Busca campos que requerem geração de sequência para uma tabela.
    /// Campos com InicCamp=1, TagQCamp=1, ExisCamp=0 e CompCamp IN ('N','EN').
    /// </summary>
    /// <param name="tableId">Código da tabela (CodiTabe)</param>
    /// <returns>Lista de metadados de campos que precisam de sequência</returns>
    Task<List<FieldMetadata>> GetFieldsRequiringSequenceAsync(int tableId);

    /// <summary>
    /// Busca configuração de sequência pelo código da tabela e nome do campo.
    /// </summary>
    /// <param name="tableId">Código da tabela</param>
    /// <param name="fieldName">Nome do campo</param>
    /// <returns>Metadados da sequência ou null se não configurada</returns>
    Task<SequenceMetadata?> GetSequenceConfigAsync(int tableId, string fieldName);

    /// <summary>
    /// Gera sequências para todos os campos configurados de uma tabela.
    /// Usado ao criar novo registro (modo INSERT).
    /// </summary>
    /// <param name="tableId">Código da tabela</param>
    /// <param name="tableName">Nome físico da tabela</param>
    /// <returns>Dicionário campo -> valor gerado</returns>
    Task<Dictionary<string, object>> GenerateSequencesForTableAsync(int tableId, string tableName);
}
