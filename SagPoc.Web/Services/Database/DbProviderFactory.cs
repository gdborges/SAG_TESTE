using SagPoc.Web.Services.Context;

namespace SagPoc.Web.Services.Database;

/// <summary>
/// Factory para criar o provider de banco correto baseado em configuração
/// </summary>
public static class DbProviderFactory
{
    /// <summary>
    /// Cria o provider apropriado baseado na configuração
    /// </summary>
    public static IDbProvider CreateProvider(
        IConfiguration configuration,
        ILoggerFactory loggerFactory,
        ISagContextAccessor? contextAccessor = null)
    {
        var providerName = configuration["DatabaseProvider"] ?? "SqlServer";

        return providerName.ToLower() switch
        {
            "sqlserver" => CreateSqlServerProvider(configuration, loggerFactory),
            "oracle" => CreateOracleProvider(configuration, loggerFactory, contextAccessor),
            _ => throw new ArgumentException($"Provider desconhecido: {providerName}. Use 'SqlServer' ou 'Oracle'.")
        };
    }

    private static SqlServerProvider CreateSqlServerProvider(
        IConfiguration configuration,
        ILoggerFactory loggerFactory)
    {
        var connectionString = configuration.GetConnectionString("SqlServer")
            ?? configuration.GetConnectionString("SagDb")
            ?? throw new InvalidOperationException(
                "Connection string 'SqlServer' ou 'SagDb' não encontrada em appsettings.json");

        var logger = loggerFactory.CreateLogger<SqlServerProvider>();
        return new SqlServerProvider(connectionString, logger);
    }

    private static OracleProvider CreateOracleProvider(
        IConfiguration configuration,
        ILoggerFactory loggerFactory,
        ISagContextAccessor? contextAccessor)
    {
        var connectionString = configuration.GetConnectionString("Oracle")
            ?? throw new InvalidOperationException(
                "Connection string 'Oracle' não encontrada em appsettings.json");

        if (contextAccessor == null)
        {
            throw new InvalidOperationException(
                "ISagContextAccessor é obrigatório para OracleProvider (necessário para inicializar contexto SAG)");
        }

        var logger = loggerFactory.CreateLogger<OracleProvider>();
        return new OracleProvider(connectionString, logger, contextAccessor);
    }
}

/// <summary>
/// Extension methods para registrar o DbProvider no DI
/// </summary>
public static class DbProviderExtensions
{
    /// <summary>
    /// Adiciona o IDbProvider ao container de DI baseado na configuração.
    /// IMPORTANTE: Registrado como Scoped para Oracle (cada requisição tem seu próprio contexto).
    /// </summary>
    public static IServiceCollection AddDbProvider(this IServiceCollection services, IConfiguration configuration)
    {
        var providerName = configuration["DatabaseProvider"] ?? "SqlServer";

        if (providerName.Equals("Oracle", StringComparison.OrdinalIgnoreCase))
        {
            // Oracle: Scoped - cada requisição tem seu próprio provider com contexto
            services.AddScoped<IDbProvider>(sp =>
            {
                var loggerFactory = sp.GetRequiredService<ILoggerFactory>();
                var contextAccessor = sp.GetRequiredService<ISagContextAccessor>();
                return DbProviderFactory.CreateProvider(configuration, loggerFactory, contextAccessor);
            });
        }
        else
        {
            // SQL Server: Singleton - não precisa de contexto SAG
            services.AddSingleton<IDbProvider>(sp =>
            {
                var loggerFactory = sp.GetRequiredService<ILoggerFactory>();
                return DbProviderFactory.CreateProvider(configuration, loggerFactory);
            });
        }

        return services;
    }
}
