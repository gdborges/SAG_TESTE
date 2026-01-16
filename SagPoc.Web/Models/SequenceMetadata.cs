namespace SagPoc.Web.Models;

/// <summary>
/// Metadados de sequência numérica (POCANUME).
/// Usado para geração automática de números sequenciais.
/// </summary>
public class SequenceMetadata
{
    /// <summary>Código da sequência (PK)</summary>
    public int CodiNume { get; set; }

    /// <summary>Nome/descrição da sequência</summary>
    public string? NomeNume { get; set; }

    /// <summary>Código da tabela associada</summary>
    public int TabeNume { get; set; }

    /// <summary>Nome do campo que usa esta sequência</summary>
    public string? CampNume { get; set; }

    /// <summary>Valor atual da sequência</summary>
    public int NumeNume { get; set; }

    /// <summary>Incremento (geralmente 1)</summary>
    public int IncrNume { get; set; } = 1;

    /// <summary>Valor mínimo</summary>
    public int MiniNume { get; set; }

    /// <summary>Valor máximo</summary>
    public int MaxiNume { get; set; }

    /// <summary>Prefixo para o número gerado</summary>
    public string? PrefNume { get; set; }

    /// <summary>Sufixo para o número gerado</summary>
    public string? SufiNume { get; set; }
}

/// <summary>
/// Resultado da geração de sequência
/// </summary>
public class SequenceResult
{
    /// <summary>Valor numérico gerado</summary>
    public int Value { get; set; }

    /// <summary>Valor formatado (com prefixo/sufixo se houver)</summary>
    public string FormattedValue { get; set; } = string.Empty;

    /// <summary>Nome do campo destino</summary>
    public string FieldName { get; set; } = string.Empty;

    /// <summary>Se a geração foi bem-sucedida</summary>
    public bool Success { get; set; }

    /// <summary>Mensagem de erro se falhou</summary>
    public string? ErrorMessage { get; set; }
}
