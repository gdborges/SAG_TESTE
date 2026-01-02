using Dapper;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço de validação de modificações em campos protegidos.
/// Implementa a lógica do BtnConf_CampModi do Delphi (POHeCam6.pas linha 442).
/// </summary>
public class ValidationService : IValidationService
{
    private readonly IDbProvider _dbProvider;
    private readonly IMetadataService _metadataService;
    private readonly ILogger<ValidationService> _logger;

    // Tipos de componentes que são excluídos da validação (não são campos de dados)
    private static readonly HashSet<string> ExcludedComponentTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        "BVL", "LBL", "BTN", "DBG", "GRA", "T"
    };

    // Tipos de componentes calculados (não podem ser editados diretamente)
    private static readonly HashSet<string> CalculatedComponentTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        "EE", "LE", "EN", "LN"
    };

    public ValidationService(
        IDbProvider dbProvider,
        IMetadataService metadataService,
        ILogger<ValidationService> logger)
    {
        _dbProvider = dbProvider;
        _metadataService = metadataService;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<List<ProtectedFieldInfo>> GetProtectedFieldsAsync(int tableId)
    {
        var result = new List<ProtectedFieldInfo>();

        try
        {
            // Obtém metadados da tabela (incluindo FinaTabe)
            var formMetadata = await _metadataService.GetFormMetadataAsync(tableId);
            var finaTabe = formMetadata.FinaTabe ?? "";

            foreach (var field in formMetadata.Fields)
            {
                // Ignora tipos de componentes excluídos
                if (ExcludedComponentTypes.Contains(field.CompCamp))
                    continue;

                // Verifica se o campo é protegido
                var isApAt = !string.IsNullOrEmpty(finaTabe) &&
                             field.NomeCamp.StartsWith($"ApAt{finaTabe}", StringComparison.OrdinalIgnoreCase);
                var isMarcCamp = field.MarcCamp == 1;
                var isCalculated = CalculatedComponentTypes.Contains(field.CompCamp);

                if (isApAt || isMarcCamp || isCalculated)
                {
                    var reason = isApAt ? ProtectionReason.AutoFinalization
                               : isMarcCamp ? ProtectionReason.MarkedAsProtected
                               : ProtectionReason.Calculated;

                    result.Add(new ProtectedFieldInfo
                    {
                        FieldName = field.NomeCamp,
                        Label = field.LabeCamp.Replace("&", ""),
                        ComponentType = field.CompCamp,
                        Reason = reason,
                        IsApAtField = isApAt,
                        IsMarcCamp = isMarcCamp
                    });
                }
            }

            _logger.LogDebug("Encontrados {Count} campos protegidos para tabela {TableId}",
                result.Count, tableId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter campos protegidos da tabela {TableId}", tableId);
        }

        return result;
    }

    /// <inheritdoc/>
    public async Task<ValidationResult> ValidateModificationsAsync(
        int tableId,
        Dictionary<string, object?> originalData,
        Dictionary<string, object?> newData,
        bool isFinalized)
    {
        var result = new ValidationResult();

        // Se o registro não está finalizado, não precisa validar campos ApAt
        // (só valida campos marcados como protegidos - MarcCamp)
        var protectedFields = await GetProtectedFieldsAsync(tableId);

        foreach (var field in protectedFields)
        {
            // Se não está finalizado, ignora campos ApAt (só valida se finalizado)
            if (!isFinalized && field.IsApAtField)
                continue;

            // Obtém valores original e novo (case-insensitive)
            var originalValue = GetFieldValue(originalData, field.FieldName);
            var newValue = GetFieldValue(newData, field.FieldName);

            // Compara valores
            if (!AreValuesEqual(originalValue, newValue))
            {
                result.Violations.Add(new ValidationViolation
                {
                    FieldName = field.FieldName,
                    Label = field.Label,
                    OriginalValue = originalValue,
                    NewValue = newValue,
                    Reason = field.Reason
                });

                _logger.LogWarning(
                    "Violação de campo protegido: {FieldName} ({Label}) alterado de '{Original}' para '{New}'",
                    field.FieldName, field.Label, originalValue, newValue);
            }
        }

        if (result.Violations.Any())
        {
            _logger.LogWarning("Validação falhou para tabela {TableId}: {Count} violações",
                tableId, result.Violations.Count);
        }

        return result;
    }

    /// <inheritdoc/>
    public async Task<bool> IsRecordFinalizedAsync(int tableId, Dictionary<string, object?> recordData)
    {
        try
        {
            // Obtém metadados da tabela
            var formMetadata = await _metadataService.GetFormMetadataAsync(tableId);
            var finaTabe = formMetadata.FinaTabe;

            if (string.IsNullOrEmpty(finaTabe))
            {
                // Tabela não tem controle de finalização
                return false;
            }

            // Verifica campo Tabe{FinaTabe}
            var tabeFieldName = $"Tabe{finaTabe}";
            var tabeValue = GetFieldValue(recordData, tabeFieldName);
            var tabeIsEmpty = tabeValue == null ||
                              string.IsNullOrWhiteSpace(tabeValue.ToString());

            // Verifica campo CodiGene
            var codiGeneValue = GetFieldValue(recordData, "CodiGene");
            var codiGeneIsZero = codiGeneValue == null ||
                                 (int.TryParse(codiGeneValue.ToString(), out var codiGene) && codiGene == 0);

            // Registro está finalizado se Tabe{FinaTabe} não está vazio E CodiGene != 0
            var isFinalized = !tabeIsEmpty && !codiGeneIsZero;

            _logger.LogDebug(
                "Verificação de finalização tabela {TableId}: Tabe{FinaTabe}='{TaBeValue}', CodiGene='{CodiGene}', Finalizado={IsFinalized}",
                tableId, finaTabe, tabeValue, codiGeneValue, isFinalized);

            return isFinalized;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao verificar finalização do registro na tabela {TableId}", tableId);
            return false;
        }
    }

    /// <summary>
    /// Obtém valor de um campo no dicionário (case-insensitive).
    /// </summary>
    private static object? GetFieldValue(Dictionary<string, object?> data, string fieldName)
    {
        // Busca case-insensitive
        var key = data.Keys.FirstOrDefault(k =>
            k.Equals(fieldName, StringComparison.OrdinalIgnoreCase));

        return key != null ? data[key] : null;
    }

    /// <summary>
    /// Compara dois valores para igualdade, tratando nulls e tipos diferentes.
    /// </summary>
    private static bool AreValuesEqual(object? value1, object? value2)
    {
        // Ambos nulos
        if (value1 == null && value2 == null)
            return true;

        // Um nulo e outro não
        if (value1 == null || value2 == null)
            return false;

        // Converte para string para comparação
        var str1 = value1.ToString()?.Trim() ?? "";
        var str2 = value2.ToString()?.Trim() ?? "";

        // Tenta comparação numérica se ambos parecem números
        if (decimal.TryParse(str1, out var num1) && decimal.TryParse(str2, out var num2))
        {
            return num1 == num2;
        }

        // Comparação de string (case-insensitive)
        return str1.Equals(str2, StringComparison.OrdinalIgnoreCase);
    }
}
