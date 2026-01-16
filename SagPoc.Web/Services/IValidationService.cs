using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Interface para serviço de validação de modificações em campos protegidos.
/// Implementa a lógica do BtnConf_CampModi do Delphi.
/// </summary>
public interface IValidationService
{
    /// <summary>
    /// Obtém a lista de campos protegidos para uma tabela.
    /// Campos protegidos: InteCamp=0 (gerados por processo) OU campos que começam com "ApAt{FinaTabe}".
    /// Baseado em BtnConf_CampModi do Delphi (POHeCam6.pas).
    /// </summary>
    /// <param name="tableId">ID da tabela (CodiTabe)</param>
    /// <returns>Lista de campos protegidos com seus metadados</returns>
    Task<List<ProtectedFieldInfo>> GetProtectedFieldsAsync(int tableId);

    /// <summary>
    /// Valida se os dados modificados violam campos protegidos.
    /// Compara valores originais com novos valores para campos protegidos.
    /// </summary>
    /// <param name="tableId">ID da tabela (CodiTabe)</param>
    /// <param name="originalData">Dados originais do registro</param>
    /// <param name="newData">Dados novos (após edição)</param>
    /// <param name="isFinalized">Indica se o registro está finalizado (tem dados gerados por outro processo)</param>
    /// <returns>Resultado da validação com lista de violações</returns>
    Task<ValidationResult> ValidateModificationsAsync(
        int tableId,
        Dictionary<string, object?> originalData,
        Dictionary<string, object?> newData,
        bool isFinalized);

    /// <summary>
    /// Verifica se um registro está finalizado (foi gerado por outro processo).
    /// Um registro está finalizado se:
    /// - Campo Tabe{FinaTabe} não está vazio E
    /// - Campo CodiGene != 0
    /// </summary>
    /// <param name="tableId">ID da tabela</param>
    /// <param name="recordData">Dados do registro</param>
    /// <returns>True se o registro está finalizado</returns>
    Task<bool> IsRecordFinalizedAsync(int tableId, Dictionary<string, object?> recordData);
}

/// <summary>
/// Informações sobre um campo protegido.
/// </summary>
public class ProtectedFieldInfo
{
    /// <summary>
    /// Nome do campo no banco (NomeCamp)
    /// </summary>
    public string FieldName { get; set; } = string.Empty;

    /// <summary>
    /// Label do campo para exibição (LabeCamp)
    /// </summary>
    public string Label { get; set; } = string.Empty;

    /// <summary>
    /// Tipo de componente (CompCamp)
    /// </summary>
    public string ComponentType { get; set; } = string.Empty;

    /// <summary>
    /// Motivo da proteção
    /// </summary>
    public ProtectionReason Reason { get; set; }

    /// <summary>
    /// Indica se o campo é ApAt (campo de finalização automática)
    /// </summary>
    public bool IsApAtField { get; set; }

    /// <summary>
    /// Indica se o campo é gerado por processo (InteCamp=0).
    /// Nome mantido para compatibilidade, mas representa InteCamp=0 no Delphi.
    /// </summary>
    public bool IsMarcCamp { get; set; }
}

/// <summary>
/// Motivo pelo qual um campo é protegido.
/// </summary>
public enum ProtectionReason
{
    /// <summary>
    /// Campo marcado como protegido/gerado por processo (InteCamp=0)
    /// </summary>
    MarkedAsProtected,

    /// <summary>
    /// Campo de finalização automática (ApAt{FinaTabe})
    /// </summary>
    AutoFinalization,

    /// <summary>
    /// Campo calculado (CompCamp IN ('EE','LE','EN','LN'))
    /// </summary>
    Calculated
}

/// <summary>
/// Resultado da validação de modificações.
/// </summary>
public class ValidationResult
{
    /// <summary>
    /// Indica se a validação passou (não há violações)
    /// </summary>
    public bool IsValid => !Violations.Any();

    /// <summary>
    /// Lista de violações encontradas
    /// </summary>
    public List<ValidationViolation> Violations { get; set; } = new();

    /// <summary>
    /// Mensagem resumo das violações
    /// </summary>
    public string? SummaryMessage => Violations.Any()
        ? $"Não é possível salvar: {Violations.Count} campo(s) protegido(s) foram modificados."
        : null;
}

/// <summary>
/// Representa uma violação de campo protegido.
/// </summary>
public class ValidationViolation
{
    /// <summary>
    /// Nome do campo que foi modificado
    /// </summary>
    public string FieldName { get; set; } = string.Empty;

    /// <summary>
    /// Label do campo para exibição
    /// </summary>
    public string Label { get; set; } = string.Empty;

    /// <summary>
    /// Valor original do campo
    /// </summary>
    public object? OriginalValue { get; set; }

    /// <summary>
    /// Novo valor do campo (após edição)
    /// </summary>
    public object? NewValue { get; set; }

    /// <summary>
    /// Motivo da proteção
    /// </summary>
    public ProtectionReason Reason { get; set; }

    /// <summary>
    /// Mensagem de erro para exibição
    /// </summary>
    public string ErrorMessage => Reason switch
    {
        ProtectionReason.MarkedAsProtected =>
            $"Campo '{Label}' não pode ser alterado manualmente.",
        ProtectionReason.AutoFinalization =>
            $"Dados gerados por outro processo. Campo '{Label}' não pode ser modificado.",
        ProtectionReason.Calculated =>
            $"Campo calculado '{Label}' não aceita edição direta.",
        _ => $"Campo '{Label}' é protegido e não pode ser alterado."
    };
}
