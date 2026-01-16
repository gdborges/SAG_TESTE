using System.Data;

namespace SagPoc.Web.Services.Database;

/// <summary>
/// Interface para abstração de provider de banco de dados.
/// Permite chavear entre SQL Server e Oracle.
/// </summary>
public interface IDbProvider
{
    /// <summary>
    /// Nome do provider (SqlServer, Oracle)
    /// </summary>
    string ProviderName { get; }

    /// <summary>
    /// Prefixo de parâmetro (@ para SQL Server, : para Oracle)
    /// </summary>
    string ParameterPrefix { get; }

    /// <summary>
    /// Indica se o provider suporta IDENTITY columns
    /// </summary>
    bool SupportsIdentity { get; }

    /// <summary>
    /// Cria uma nova conexão com o banco de dados
    /// </summary>
    IDbConnection CreateConnection();

    /// <summary>
    /// Retorna a função para tratar NULL (ISNULL vs NVL)
    /// </summary>
    string NullFunction(string column, string defaultValue);

    /// <summary>
    /// Concatena strings usando operador correto (+ vs ||)
    /// </summary>
    string ConcatStrings(params string[] values);

    /// <summary>
    /// Retorna cláusula TOP/FETCH FIRST para limitar resultados
    /// </summary>
    /// <param name="count">Número de linhas</param>
    /// <param name="useTopClause">True para usar no início do SELECT (SQL Server TOP N)</param>
    string GetLimitClause(int count, bool useTopClause = true);

    /// <summary>
    /// Retorna cláusula de paginação (OFFSET/FETCH)
    /// </summary>
    string GetPaginationClause(int offset, int pageSize);

    /// <summary>
    /// Retorna hints de lock para tabela
    /// </summary>
    string GetLockHints(string tableName);

    /// <summary>
    /// Obtém o próximo ID para INSERT.
    /// - SQL Server com IDENTITY: retorna null (deixa banco gerar)
    /// - SQL Server sem IDENTITY: usa MAX()+1
    /// - Oracle: usa SEQUENCE.NEXTVAL
    /// </summary>
    Task<int?> GetNextIdAsync(IDbConnection connection, string tableName,
        string pkColumn, bool isIdentity, IDbTransaction? transaction = null);

    /// <summary>
    /// Obtém o ID gerado após INSERT (para tabelas IDENTITY)
    /// </summary>
    Task<int> GetLastInsertedIdAsync(IDbConnection connection, IDbTransaction? transaction = null);

    /// <summary>
    /// Query para verificar se coluna é IDENTITY
    /// </summary>
    string GetIdentityCheckQuery(string tableName, string columnName);

    /// <summary>
    /// Query para obter a primeira coluna de uma tabela (geralmente PK)
    /// </summary>
    string GetFirstColumnQuery(string tableName);

    /// <summary>
    /// Query para obter metadados das colunas de uma tabela
    /// </summary>
    string GetColumnsMetadataQuery(string tableName);

    /// <summary>
    /// Formata nome de tabela/coluna para o banco (brackets vs aspas)
    /// </summary>
    string QuoteIdentifier(string identifier);

    /// <summary>
    /// Formata nome de parâmetro com prefixo correto
    /// </summary>
    string FormatParameter(string parameterName);

    /// <summary>
    /// Converte campo TEXT/CLOB para VARCHAR/NVARCHAR para Dapper mapear corretamente.
    /// SQL Server: CAST(coluna AS NVARCHAR(MAX))
    /// Oracle: TO_CHAR(coluna) ou DBMS_LOB.SUBSTR(coluna, 4000)
    /// </summary>
    string CastTextToString(string columnName);

    /// <summary>
    /// Trata coluna que pode não existir em todos os bancos.
    /// Retorna NullFunction se a coluna existe, ou apenas o valor default se não existe.
    /// Usado para colunas adicionadas em versões mais recentes do schema.
    /// </summary>
    string OptionalColumn(string column, string defaultValue);
}
