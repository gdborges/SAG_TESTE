using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace SagPoc.Web.Services.Database;

/// <summary>
/// Provider para SQL Server
/// </summary>
public class SqlServerProvider : IDbProvider
{
    private readonly string _connectionString;
    private readonly ILogger<SqlServerProvider> _logger;

    public SqlServerProvider(string connectionString, ILogger<SqlServerProvider> logger)
    {
        _connectionString = connectionString;
        _logger = logger;
    }

    public string ProviderName => "SqlServer";
    public string ParameterPrefix => "@";
    public bool SupportsIdentity => true;

    public IDbConnection CreateConnection()
    {
        return new SqlConnection(_connectionString);
    }

    public string NullFunction(string column, string defaultValue)
    {
        return $"ISNULL({column}, {defaultValue})";
    }

    public string ConcatStrings(params string[] values)
    {
        return string.Join(" + ", values);
    }

    public string GetLimitClause(int count, bool useTopClause = true)
    {
        if (useTopClause)
            return $"TOP {count}";
        else
            return $"FETCH FIRST {count} ROWS ONLY";
    }

    public string GetPaginationClause(int offset, int pageSize)
    {
        return $"OFFSET {offset} ROWS FETCH NEXT {pageSize} ROWS ONLY";
    }

    public string GetLockHints(string tableName)
    {
        return "WITH (TABLOCKX, HOLDLOCK)";
    }

    public async Task<int?> GetNextIdAsync(IDbConnection connection, string tableName,
        string pkColumn, bool isIdentity, IDbTransaction? transaction = null)
    {
        // Para IDENTITY, retorna null - deixa o banco gerar
        if (isIdentity)
        {
            _logger.LogDebug("Tabela {TableName} usa IDENTITY, banco gerará o ID", tableName);
            return null;
        }

        // Para não-IDENTITY, usa MAX()+1 com lock
        var sql = $"SELECT ISNULL(MAX([{pkColumn}]), 0) + 1 FROM [{tableName}] WITH (TABLOCKX, HOLDLOCK)";
        var nextId = await connection.ExecuteScalarAsync<int>(sql, transaction: transaction);

        _logger.LogDebug("Gerado próximo ID {NextId} para tabela {TableName} via MAX+1", nextId, tableName);
        return nextId;
    }

    public async Task<int> GetLastInsertedIdAsync(IDbConnection connection, IDbTransaction? transaction = null)
    {
        return await connection.ExecuteScalarAsync<int>("SELECT SCOPE_IDENTITY()", transaction: transaction);
    }

    public string GetIdentityCheckQuery(string tableName, string columnName)
    {
        return @"SELECT COLUMNPROPERTY(OBJECT_ID(@TableName), @ColumnName, 'IsIdentity')";
    }

    public string GetFirstColumnQuery(string tableName)
    {
        return @"SELECT TOP 1 COLUMN_NAME
                 FROM INFORMATION_SCHEMA.COLUMNS
                 WHERE TABLE_NAME = @TableName
                 ORDER BY ORDINAL_POSITION";
    }

    public string GetColumnsMetadataQuery(string tableName)
    {
        return @"SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
                        IS_NULLABLE, COLUMN_DEFAULT, ORDINAL_POSITION
                 FROM INFORMATION_SCHEMA.COLUMNS
                 WHERE TABLE_NAME = @TableName
                 ORDER BY ORDINAL_POSITION";
    }

    public string QuoteIdentifier(string identifier)
    {
        return $"[{identifier}]";
    }

    public string FormatParameter(string parameterName)
    {
        if (parameterName.StartsWith("@"))
            return parameterName;
        return $"@{parameterName}";
    }

    public string CastTextToString(string columnName)
    {
        // Campos TEXT precisam de CAST para NVARCHAR(MAX) para Dapper mapear corretamente
        return $"CAST({columnName} AS NVARCHAR(MAX))";
    }
}
