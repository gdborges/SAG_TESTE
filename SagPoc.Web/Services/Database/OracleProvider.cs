using System.Data;
using Dapper;
using Oracle.ManagedDataAccess.Client;
using SagPoc.Web.Services.Context;

namespace SagPoc.Web.Services.Database;

/// <summary>
/// Provider para Oracle Database.
/// Automaticamente inicializa o contexto SAG_USUARIO via MERGE em POCACONF.
/// </summary>
public class OracleProvider : IDbProvider
{
    private readonly string _connectionString;
    private readonly ILogger<OracleProvider> _logger;
    private readonly ISagContextAccessor _contextAccessor;

    // Cache do PCODEMPR por EmpresaId (evita query repetida na mesma requisição)
    private readonly Dictionary<int, string> _pcodEmprCache = new();

    public OracleProvider(
        string connectionString,
        ILogger<OracleProvider> logger,
        ISagContextAccessor contextAccessor)
    {
        _connectionString = connectionString;
        _logger = logger;
        _contextAccessor = contextAccessor;
    }

    public string ProviderName => "Oracle";
    public string ParameterPrefix => ":";
    public bool SupportsIdentity => false; // Oracle 11g compatibilidade

    public IDbConnection CreateConnection()
    {
        var connection = new OracleConnection(_connectionString);

        // Inicializa contexto SAG automaticamente ao abrir a conexão
        connection.StateChange += (sender, e) =>
        {
            if (e.CurrentState == ConnectionState.Open && sender is OracleConnection conn)
            {
                InitializeSagContext(conn);
            }
        };

        return connection;
    }

    /// <summary>
    /// Inicializa o contexto SAG_USUARIO no Oracle.
    /// Faz MERGE em POCACONF que dispara o trigger TRG_POCACONF_AU_VAR_USUA,
    /// o qual chama SYSTEM.SAG_PRO_USUARIO para configurar sys_context('SAG_USUARIO', ...).
    /// </summary>
    private void InitializeSagContext(OracleConnection connection)
    {
        try
        {
            var ctx = _contextAccessor.Context;

            // 1. Buscar PCODEMPR de POCAEMPR (com cache)
            var pcodEmpr = GetPcodEmpr(connection, ctx.EmpresaId);

            // 2. Montar CONFCONF no formato SAG (ex: U99E01S83)
            var confConf = ctx.ToConfConf(pcodEmpr);
            var userConf = ctx.UsuarioNome ?? "WEB";

            // 3. MERGE em POCACONF - dispara o trigger que configura o contexto Oracle
            using var cmd = connection.CreateCommand();
            cmd.CommandText = @"
                MERGE INTO POCACONF p
                USING (SELECT :userConf AS USERCONF FROM DUAL) s
                ON (p.USERCONF = s.USERCONF)
                WHEN MATCHED THEN
                    UPDATE SET CONFCONF = :confConf
                WHEN NOT MATCHED THEN
                    INSERT (USERCONF, CONFCONF) VALUES (:userConf, :confConf)";

            cmd.Parameters.Add(new OracleParameter("userConf", userConf));
            cmd.Parameters.Add(new OracleParameter("confConf", confConf));
            cmd.ExecuteNonQuery();

            _logger.LogInformation(
                "Contexto SAG inicializado: USERCONF={UserConf}, CONFCONF={ConfConf} (Usuario={UsuarioId}, Empresa={EmpresaId}, Modulo={ModuloId})",
                userConf, confConf, ctx.UsuarioId, ctx.EmpresaId, ctx.ModuloId);
        }
        catch (OracleException ex)
        {
            // Log mas não falha - algumas operações podem funcionar sem contexto
            _logger.LogWarning(ex, "Não foi possível inicializar contexto SAG: {Message}", ex.Message);
        }
    }

    /// <summary>
    /// Obtém o código da empresa no formato E?? (PCODEMPR) a partir do CodiEmpr.
    /// Usa cache para evitar queries repetidas na mesma requisição.
    /// </summary>
    private string GetPcodEmpr(OracleConnection connection, int codiEmpr)
    {
        // Verifica cache primeiro
        if (_pcodEmprCache.TryGetValue(codiEmpr, out var cached))
        {
            return cached;
        }

        try
        {
            using var cmd = connection.CreateCommand();
            cmd.CommandText = "SELECT PCODEMPR FROM POCAEMPR WHERE CODIEMPR = :codiEmpr";
            cmd.Parameters.Add(new OracleParameter("codiEmpr", codiEmpr));

            var result = cmd.ExecuteScalar() as string;

            if (!string.IsNullOrEmpty(result))
            {
                _pcodEmprCache[codiEmpr] = result;
                return result;
            }
        }
        catch (OracleException ex)
        {
            _logger.LogWarning(ex, "Erro ao buscar PCODEMPR para CodiEmpr={CodiEmpr}", codiEmpr);
        }

        // Fallback: usar E01 como padrão
        _logger.LogWarning("PCODEMPR não encontrado para CodiEmpr={CodiEmpr}, usando fallback 'E01'", codiEmpr);
        var fallback = "E01";
        _pcodEmprCache[codiEmpr] = fallback;
        return fallback;
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

    public string CastTextToString(string columnName)
    {
        // Oracle CLOB precisa de conversão explícita para Dapper mapear corretamente
        // DBMS_LOB.SUBSTR extrai até 4000 caracteres (limite do VARCHAR2)
        return $"DBMS_LOB.SUBSTR({columnName}, 4000, 1)";
    }

    public string OptionalColumn(string column, string defaultValue)
    {
        // Oracle: usa NullFunction normalmente (mesma estrutura que SQL Server)
        return NullFunction(column, defaultValue);
    }
}
