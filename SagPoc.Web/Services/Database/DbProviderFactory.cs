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
        ILoggerFactory loggerFactory)
    {
        var providerName = configuration["DatabaseProvider"] ?? "SqlServer";

        return providerName.ToLower() switch
        {
            "sqlserver" => CreateSqlServerProvider(configuration, loggerFactory),
            "oracle" => CreateOracleProvider(configuration, loggerFactory),
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
        ILoggerFactory loggerFactory)
    {
        var connectionString = configuration.GetConnectionString("Oracle")
            ?? throw new InvalidOperationException(
                "Connection string 'Oracle' não encontrada em appsettings.json");

        var logger = loggerFactory.CreateLogger<OracleProvider>();
        return new OracleProvider(connectionString, logger);
    }
}

/// <summary>
/// Extension methods para registrar o DbProvider no DI
/// </summary>
public static class DbProviderExtensions
{
    /// <summary>
    /// Adiciona o IDbProvider ao container de DI baseado na configuração
    /// </summary>
    public static IServiceCollection AddDbProvider(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddSingleton<IDbProvider>(sp =>
        {
            var loggerFactory = sp.GetRequiredService<ILoggerFactory>();
            return DbProviderFactory.CreateProvider(configuration, loggerFactory);
        });

        return services;
    }
}
