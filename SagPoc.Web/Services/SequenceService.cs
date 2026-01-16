using Dapper;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;

namespace SagPoc.Web.Services;

/// <summary>
/// Implementação do serviço de sequências numéricas.
/// Suporta SQL Server e Oracle via IDbProvider.
/// </summary>
public class SequenceService : ISequenceService
{
    private readonly IDbProvider _dbProvider;
    private readonly ILogger<SequenceService> _logger;

    public SequenceService(IDbProvider dbProvider, ILogger<SequenceService> logger)
    {
        _dbProvider = dbProvider;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<SequenceResult> GetNextSequenceAsync(int codiNume)
    {
        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            // Busca configuração atual da sequência
            // Colunas existentes em POCANUME: CODINUME, TABENUME, CAMPNUME, NUMENUME,
            // PEMPNUME, PSISNUME, PUSUNUME, PDATNUME, CODIPRAT
            // Colunas NÃO existentes (usamos defaults): NOMENUME, INCRNUME, MININUME, MAXINUME, PREFNUME, SUFINUME
            var selectSql = $@"
                SELECT
                    CODINUME as CodiNume,
                    '' as NomeNume,
                    {_dbProvider.NullFunction("TABENUME", "0")} as TabeNume,
                    {_dbProvider.NullFunction("CAMPNUME", "''")} as CampNume,
                    {_dbProvider.NullFunction("NUMENUME", "0")} as NumeNume,
                    1 as IncrNume,
                    0 as MiniNume,
                    999999999 as MaxiNume,
                    '' as PrefNume,
                    '' as SufiNume
                FROM POCANUME
                WHERE CODINUME = {_dbProvider.FormatParameter("CodiNume")}";

            var sequence = await connection.QueryFirstOrDefaultAsync<SequenceMetadata>(
                selectSql, new { CodiNume = codiNume });

            if (sequence == null)
            {
                _logger.LogWarning("Sequência {CodiNume} não encontrada em POCANUME", codiNume);
                return new SequenceResult
                {
                    Success = false,
                    ErrorMessage = $"Sequência {codiNume} não configurada"
                };
            }

            // Calcula próximo valor
            var nextValue = sequence.NumeNume + sequence.IncrNume;

            // Verifica limite máximo
            if (nextValue > sequence.MaxiNume)
            {
                _logger.LogError("Sequência {CodiNume} atingiu limite máximo {Max}",
                    codiNume, sequence.MaxiNume);
                return new SequenceResult
                {
                    Success = false,
                    ErrorMessage = $"Sequência atingiu limite máximo ({sequence.MaxiNume})"
                };
            }

            // Atualiza contador na tabela
            var updateSql = $@"
                UPDATE POCANUME
                SET NUMENUME = {_dbProvider.FormatParameter("NextValue")}
                WHERE CODINUME = {_dbProvider.FormatParameter("CodiNume")}";

            await connection.ExecuteAsync(updateSql, new { NextValue = nextValue, CodiNume = codiNume });

            // Formata valor com prefixo/sufixo se houver
            var formattedValue = $"{sequence.PrefNume}{nextValue}{sequence.SufiNume}";

            _logger.LogInformation("Gerada sequência {CodiNume}: {Value} (campo: {Campo})",
                codiNume, nextValue, sequence.CampNume);

            return new SequenceResult
            {
                Value = nextValue,
                FormattedValue = formattedValue,
                FieldName = sequence.CampNume ?? string.Empty,
                Success = true
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao gerar sequência {CodiNume}", codiNume);
            return new SequenceResult
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
    }

    /// <inheritdoc/>
    public async Task<SequenceResult> GetNextMaxPlusOneAsync(string tableName, string columnName)
    {
        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            // Busca MAX atual + 1
            var sql = $"SELECT {_dbProvider.NullFunction($"MAX({columnName})", "0")} + 1 FROM {tableName}";
            var nextValue = await connection.QueryFirstOrDefaultAsync<int>(sql);

            // Garante valor mínimo de 1
            if (nextValue < 1) nextValue = 1;

            _logger.LogInformation("Gerada sequência MAX+1 para {Table}.{Column}: {Value}",
                tableName, columnName, nextValue);

            return new SequenceResult
            {
                Value = nextValue,
                FormattedValue = nextValue.ToString(),
                FieldName = columnName,
                Success = true
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao gerar MAX+1 para {Table}.{Column}", tableName, columnName);
            return new SequenceResult
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
    }

    /// <inheritdoc/>
    public async Task<List<FieldMetadata>> GetFieldsRequiringSequenceAsync(int tableId)
    {
        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var sql = $@"
                SELECT
                    CODICAMP as CodiCamp,
                    CODITABE as CodiTabe,
                    NOMECAMP as NomeCamp,
                    {_dbProvider.NullFunction("COMPCAMP", "'E'")} as CompCamp,
                    {_dbProvider.NullFunction("INICCAMP", "0")} as InicCamp,
                    {_dbProvider.NullFunction("TAGQCAMP", "0")} as TagQCamp,
                    {_dbProvider.NullFunction("EXISCAMP", "0")} as ExisCamp
                FROM SISTCAMP
                WHERE CODITABE = {_dbProvider.FormatParameter("CodiTabe")}
                  AND {_dbProvider.NullFunction("INICCAMP", "0")} = 1
                  AND {_dbProvider.NullFunction("TAGQCAMP", "0")} = 1
                  AND {_dbProvider.NullFunction("EXISCAMP", "0")} = 0
                  AND {_dbProvider.NullFunction("COMPCAMP", "'E'")} IN ('N', 'EN')";

            var fields = await connection.QueryAsync<FieldMetadata>(sql, new { CodiTabe = tableId });
            var result = fields.ToList();

            _logger.LogInformation("Encontrados {Count} campos com sequência para tabela {TableId}",
                result.Count, tableId);

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar campos com sequência para tabela {TableId}", tableId);
            return new List<FieldMetadata>();
        }
    }

    /// <inheritdoc/>
    public async Task<SequenceMetadata?> GetSequenceConfigAsync(int tableId, string fieldName)
    {
        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            // Colunas existentes em POCANUME: CODINUME, TABENUME, CAMPNUME, NUMENUME,
            // PEMPNUME, PSISNUME, PUSUNUME, PDATNUME, CODIPRAT
            // Colunas NÃO existentes (usamos defaults): NOMENUME, INCRNUME, MININUME, MAXINUME, PREFNUME, SUFINUME
            var sql = $@"
                SELECT
                    CODINUME as CodiNume,
                    '' as NomeNume,
                    {_dbProvider.NullFunction("TABENUME", "0")} as TabeNume,
                    {_dbProvider.NullFunction("CAMPNUME", "''")} as CampNume,
                    {_dbProvider.NullFunction("NUMENUME", "0")} as NumeNume,
                    1 as IncrNume,
                    0 as MiniNume,
                    999999999 as MaxiNume,
                    '' as PrefNume,
                    '' as SufiNume
                FROM POCANUME
                WHERE TABENUME = {_dbProvider.FormatParameter("TabeNume")}
                  AND UPPER(CAMPNUME) = UPPER({_dbProvider.FormatParameter("CampNume")})";

            return await connection.QueryFirstOrDefaultAsync<SequenceMetadata>(
                sql, new { TabeNume = tableId, CampNume = fieldName });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar config de sequência para {TableId}.{Field}",
                tableId, fieldName);
            return null;
        }
    }

    /// <inheritdoc/>
    public async Task<Dictionary<string, object>> GenerateSequencesForTableAsync(int tableId, string tableName)
    {
        var result = new Dictionary<string, object>();

        try
        {
            // Busca campos que precisam de sequência
            var fields = await GetFieldsRequiringSequenceAsync(tableId);

            foreach (var field in fields)
            {
                // Primeiro tenta buscar configuração em POCANUME
                var seqConfig = await GetSequenceConfigAsync(tableId, field.NomeCamp);

                SequenceResult seqResult;

                if (seqConfig != null)
                {
                    // Usa sequência centralizada (_UN_)
                    seqResult = await GetNextSequenceAsync(seqConfig.CodiNume);
                }
                else
                {
                    // Fallback para MAX+1 (SEQU)
                    seqResult = await GetNextMaxPlusOneAsync(tableName, field.NomeCamp);
                }

                if (seqResult.Success)
                {
                    result[field.NomeCamp] = seqResult.Value;
                    _logger.LogInformation("Campo {Field} recebeu sequência {Value}",
                        field.NomeCamp, seqResult.Value);
                }
                else
                {
                    _logger.LogWarning("Falha ao gerar sequência para {Field}: {Error}",
                        field.NomeCamp, seqResult.ErrorMessage);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao gerar sequências para tabela {TableId}", tableId);
        }

        return result;
    }
}
