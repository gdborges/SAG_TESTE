using System.Data;
using Dapper;
using Oracle.ManagedDataAccess.Client;

namespace SagPoc.Web.Services.Database;

/// <summary>
/// Provider para Oracle Database
/// </summary>
public class OracleProvider : IDbProvider
{
    private readonly string _connectionString;
    private readonly ILogger<OracleProvider> _logger;

    public OracleProvider(string connectionString, ILogger<OracleProvider> logger)
    {
        _connectionString = connectionString;
        _logger = logger;
    }

    public string ProviderName => "Oracle";
    public string ParameterPrefix => ":";
    public bool SupportsIdentity => false; // Oracle 11g compatibilidade

    public IDbConnection CreateConnection()
    {
        return new OracleConnection(_connectionString);
    }

    public string NullFunction(string column, string defaultValue)
    {
        return $"NVL({column}, {defaultValue})";
    }

    public string ConcatStrings(params string[] values)
    {
        return string.Join(" || ", values);
    }

    public string GetLimitClause(int count, bool useTopClause = true)
    {
        // Oracle 12c+ syntax (compatível com 11g via ROWNUM em subquery se necessário)
        return $"FETCH FIRST {count} ROWS ONLY";
    }

    public string GetPaginationClause(int offset, int pageSize)
    {
        // Oracle 12c+ syntax
        return $"OFFSET {offset} ROWS FETCH NEXT {pageSize} ROWS ONLY";
    }

    public string GetLockHints(string tableName)
    {
        return "FOR UPDATE";
    }

    public async Task<int?> GetNextIdAsync(IDbConnection connection, string tableName,
        string pkColumn, bool isIdentity, IDbTransaction? transaction = null)
    {
        // Tenta usar SEQUENCE primeiro (convenção: SEQ_ + nome da tabela)
        var sequenceName = $"SEQ_{tableName.ToUpper()}";
        var sequenceSql = $"SELECT {sequenceName}.NEXTVAL FROM DUAL";

        try
        {
            var nextId = await connection.ExecuteScalarAsync<int>(sequenceSql, transaction: transaction);
            _logger.LogDebug("Gerado próximo ID {NextId} para tabela {TableName} via sequence {SequenceName}",
                nextId, tableName, sequenceName);
            return nextId;
        }
        catch (OracleException ex) when (ex.Number == 2289) // ORA-02289: sequence does not exist
        {
            // Fallback: usa MAX(pkColumn)+1 (padrão SAG/Delphi)
            _logger.LogDebug("Sequence {SequenceName} não existe, usando MAX()+1 para tabela {TableName}",
                sequenceName, tableName);

            var maxSql = $"SELECT NVL(MAX({pkColumn.ToUpper()}), 0) + 1 FROM {tableName.ToUpper()}";

            try
            {
                var maxId = await connection.ExecuteScalarAsync<int>(maxSql, transaction: transaction);
                _logger.LogDebug("Gerado próximo ID {NextId} para tabela {TableName} via MAX()+1", maxId, tableName);
                return maxId;
            }
            catch (Exception maxEx)
            {
                _logger.LogError(maxEx, "Erro ao obter MAX()+1 para tabela {TableName}", tableName);
                throw;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter próximo ID para tabela {TableName}", tableName);
            throw;
        }
    }

    public Task<int> GetLastInsertedIdAsync(IDbConnection connection, IDbTransaction? transaction = null)
    {
        // Oracle não tem equivalente direto ao SCOPE_IDENTITY
        // O ID deve ser obtido antes do INSERT via SEQUENCE.NEXTVAL
        return Task.FromException<int>(new NotSupportedException(
            "Oracle não suporta SCOPE_IDENTITY. Use GetNextIdAsync antes do INSERT."));
    }

    public string GetIdentityCheckQuery(string tableName, string columnName)
    {
        // Oracle 11g não tem IDENTITY columns, sempre retorna false
        return "SELECT 0 FROM DUAL";
    }

    public string GetFirstColumnQuery(string tableName)
    {
        return @"SELECT COLUMN_NAME
                 FROM USER_TAB_COLUMNS
                 WHERE TABLE_NAME = :TableName
                 ORDER BY COLUMN_ID
                 FETCH FIRST 1 ROWS ONLY";
    }

    public string GetColumnsMetadataQuery(string tableName)
    {
        return @"SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH,
                        NULLABLE, DATA_DEFAULT, COLUMN_ID
                 FROM USER_TAB_COLUMNS
                 WHERE TABLE_NAME = :TableName
                 ORDER BY COLUMN_ID";
    }

    public string QuoteIdentifier(string identifier)
    {
        // Oracle usa aspas duplas, mas geralmente não precisa para nomes em maiúsculo
        return identifier.ToUpper();
    }

    public string FormatParameter(string parameterName)
    {
        if (parameterName.StartsWith(":"))
            return parameterName;
        if (parameterName.StartsWith("@"))
            return ":" + parameterName.Substring(1);
        return $":{parameterName}";
    }
}
