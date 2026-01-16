using Dapper;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;

namespace SagPoc.Web.Services;

/// <summary>
/// Servico de dashboards - agrega dados e formata para Vision
/// </summary>
public class DashboardService : IDashboardService
{
    private readonly IDbProvider _dbProvider;
    private readonly ILogger<DashboardService> _logger;

    // Cores padrao do Vision
    private const string COLOR_SUCCESS = "#34A853";
    private const string COLOR_ERROR = "#EA4335";
    private const string COLOR_WARNING = "#FF9F1D";
    private const string COLOR_PRIMARY = "#447BDA";
    private const string COLOR_ACTION = "#0098A3";

    public DashboardService(IDbProvider dbProvider, ILogger<DashboardService> logger)
    {
        _dbProvider = dbProvider;
        _logger = logger;
        _logger.LogInformation("DashboardService inicializado com provider {Provider}", _dbProvider.ProviderName);
    }

    public async Task<List<DashboardConfigDto>> GetAvailableDashboardsAsync()
    {
        var sql = @"
            SELECT
                ID AS Id,
                MODULO_ID AS ModuleId,
                MODULO_NOME AS ModuleName,
                DASHBOARD_KEY AS DashboardKey,
                ATIVO AS Active
            FROM POCWEB_DASH_CONFIG
            WHERE ATIVO = 1
            ORDER BY MODULO_NOME";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();
            var result = await connection.QueryAsync<DashboardConfigDto>(sql);
            return result.ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar dashboards disponiveis");
            throw;
        }
    }

    public async Task<DashboardData?> GetDashboardByModuleAsync(int moduleId)
    {
        // Buscar configuracao do dashboard
        var configSql = $@"
            SELECT
                ID AS Id,
                MODULO_ID AS ModuleId,
                MODULO_NOME AS ModuleName,
                DASHBOARD_KEY AS DashboardKey,
                ATIVO AS Active
            FROM POCWEB_DASH_CONFIG
            WHERE MODULO_ID = {_dbProvider.FormatParameter("ModuleId")}
              AND ATIVO = 1";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var config = await connection.QueryFirstOrDefaultAsync<DashboardConfigDto>(
                configSql, new { ModuleId = moduleId });

            if (config == null)
            {
                _logger.LogWarning("Dashboard nao encontrado para modulo {ModuleId}", moduleId);
                return null;
            }

            // Roteamento por tipo de dashboard
            return config.DashboardKey switch
            {
                "matrizes_pesadas" => await GetMatrizesPesadasDashboardAsync(connection, config),
                "incubatorio" => await GetIncubatorioDashboardAsync(connection, config),
                "frango_corte" => await GetFrangoCorteDashboardAsync(connection, config),
                "racao_insumo" => await GetRacaoInsumoDashboardAsync(connection, config),
                "poedeiras" => await GetPoedeirasDashboardAsync(connection, config),
                _ => throw new NotImplementedException($"Dashboard '{config.DashboardKey}' nao implementado")
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar dashboard para modulo {ModuleId}", moduleId);
            throw;
        }
    }

    /// <summary>
    /// Dashboard especifico para Matrizes Pesadas
    /// </summary>
    private async Task<DashboardData> GetMatrizesPesadasDashboardAsync(
        System.Data.IDbConnection connection,
        DashboardConfigDto config)
    {
        var dashboard = new DashboardData
        {
            ModuleId = config.ModuleId,
            ModuleName = config.ModuleName
        };

        // ===== METRICAS =====
        var metricsSql = @"
            SELECT
                COUNT(*) AS TotalLotes,
                SUM(SALDO_FEMEA) AS SaldoFemeas,
                ROUND(AVG(VIABILIDADE_REAL), 2) AS ViabilidadeMedia,
                ROUND(AVG(CASE WHEN ECLOSAO_REAL > 0 THEN ECLOSAO_REAL END), 2) AS EclosaoMedia,
                ROUND(AVG(POSTURA_OBTIDA), 2) AS PosturaMedia
            FROM POCWEB_DASH_MATRIZES";

        var metrics = await connection.QueryFirstAsync<dynamic>(metricsSql);

        dashboard.Metrics = new List<DashboardMetric>
        {
            new()
            {
                Id = "total_lotes",
                Label = "Total de Lotes",
                Value = (decimal)(metrics.TOTALLOTES ?? 0),
                Icon = "Layers",
                Color = "primary"
            },
            new()
            {
                Id = "saldo_femeas",
                Label = "Saldo Femeas",
                Value = (decimal)(metrics.SALDOFEMEAS ?? 0),
                Icon = "Bird",
                Color = "success"
            },
            new()
            {
                Id = "viab_media",
                Label = "Viabilidade Media",
                Value = (decimal)(metrics.VIABILIDADEMEDIA ?? 0),
                Icon = "Activity",
                Color = "warning"
            },
            new()
            {
                Id = "eclosao_media",
                Label = "Eclosao Media",
                Value = (decimal)(metrics.ECLOSAOMEDIA ?? 0),
                Icon = "Egg",
                Color = "action"
            }
        };

        // ===== DISTRIBUICOES =====
        // Distribuicao por Linhagem
        var linhagemSql = @"
            SELECT
                TRIM(LINHAGEM_FEMEA) AS Category,
                COUNT(*) AS Value
            FROM POCWEB_DASH_MATRIZES
            GROUP BY LINHAGEM_FEMEA
            ORDER BY COUNT(*) DESC";

        var linhagens = (await connection.QueryAsync<dynamic>(linhagemSql)).ToList();

        var linhagemDistribution = new DashboardDistribution
        {
            Id = "linhagens",
            Title = "Distribuicao por Linhagem",
            Subtitle = "Lotes",
            Items = linhagens.Select((l, i) => new DashboardDistributionItem
            {
                Category = (string)(l.CATEGORY ?? ""),
                Value = (decimal)(l.VALUE ?? 0),
                Color = i switch
                {
                    0 => COLOR_PRIMARY,
                    1 => COLOR_SUCCESS,
                    2 => COLOR_WARNING,
                    _ => COLOR_ACTION
                }
            }).ToList()
        };

        // Distribuicao por Faixa de Idade
        var idadeSql = @"
            SELECT
                CASE
                    WHEN IDADE BETWEEN 25 AND 35 THEN '25-35 sem'
                    WHEN IDADE BETWEEN 36 AND 50 THEN '36-50 sem'
                    WHEN IDADE BETWEEN 51 AND 65 THEN '51-65 sem'
                    ELSE 'Outros'
                END AS Category,
                COUNT(*) AS Value
            FROM POCWEB_DASH_MATRIZES
            GROUP BY
                CASE
                    WHEN IDADE BETWEEN 25 AND 35 THEN '25-35 sem'
                    WHEN IDADE BETWEEN 36 AND 50 THEN '36-50 sem'
                    WHEN IDADE BETWEEN 51 AND 65 THEN '51-65 sem'
                    ELSE 'Outros'
                END
            ORDER BY MIN(IDADE)";

        var idades = (await connection.QueryAsync<dynamic>(idadeSql)).ToList();

        var idadeDistribution = new DashboardDistribution
        {
            Id = "faixa_idade",
            Title = "Faixa de Idade",
            Subtitle = "Lotes",
            Items = idades.Select(i => new DashboardDistributionItem
            {
                Category = (string)(i.CATEGORY ?? ""),
                Value = (decimal)(i.VALUE ?? 0)
            }).ToList()
        };

        dashboard.Distributions = new List<DashboardDistribution>
        {
            linhagemDistribution,
            idadeDistribution
        };

        // ===== TRENDS =====
        dashboard.Trends = new List<DashboardTrend>();

        // ===== RANKINGS =====
        // Top 5 Lotes por Viabilidade
        var topViabSql = @"
            SELECT
                'Lote ' || NRO_LOTE AS Category,
                VIABILIDADE_REAL AS Value
            FROM POCWEB_DASH_MATRIZES
            ORDER BY VIABILIDADE_REAL DESC
            FETCH FIRST 5 ROWS ONLY";

        var topViab = (await connection.QueryAsync<dynamic>(topViabSql)).ToList();

        var topViabilidadeRanking = new DashboardRanking
        {
            Id = "top_viabilidade",
            Title = "Aproveitamento de Ovos",
            MaxItems = 5,
            Items = topViab.Select(v => new DashboardRankingItem
            {
                Category = (string)(v.CATEGORY ?? ""),
                Value = (decimal)(v.VALUE ?? 0),
                Color = (decimal)(v.VALUE ?? 0) >= 95 ? COLOR_SUCCESS :
                        (decimal)(v.VALUE ?? 0) >= 90 ? COLOR_WARNING : COLOR_ERROR
            }).ToList()
        };

        // Lotes com Viabilidade Critica (abaixo do padrao)
        var criticosSql = @"
            SELECT
                'Lote ' || NRO_LOTE AS Category,
                VIABILIDADE_REAL AS Value
            FROM POCWEB_DASH_MATRIZES
            WHERE VIABILIDADE_REAL < VIABILIDADE_STANDARD
            ORDER BY VIABILIDADE_REAL ASC
            FETCH FIRST 5 ROWS ONLY";

        var criticos = (await connection.QueryAsync<dynamic>(criticosSql)).ToList();

        var criticosRanking = new DashboardRanking
        {
            Id = "lotes_criticos",
            Title = "Ovo/Ave Crítico",
            MaxItems = 5,
            Items = criticos.Select(c => new DashboardRankingItem
            {
                Category = (string)(c.CATEGORY ?? ""),
                Value = (decimal)(c.VALUE ?? 0),
                Color = (decimal)(c.VALUE ?? 0) < 85 ? COLOR_ERROR : COLOR_WARNING
            }).ToList()
        };

        dashboard.Rankings = new List<DashboardRanking>
        {
            topViabilidadeRanking,
            criticosRanking
        };

        return dashboard;
    }

    /// <summary>
    /// Dashboard especifico para Incubatorio
    /// </summary>
    private async Task<DashboardData> GetIncubatorioDashboardAsync(
        System.Data.IDbConnection connection,
        DashboardConfigDto config)
    {
        var dashboard = new DashboardData
        {
            ModuleId = config.ModuleId,
            ModuleName = config.ModuleName
        };

        // ===== METRICAS =====
        var metricsSql = @"
            SELECT
                COUNT(DISTINCT NRO_LOTE) AS TotalLotes,
                SUM(TOTAL_NASC) AS TotalNascidos,
                SUM(QTD_OVO_INCUB) AS TotalOvosIncubados,
                ROUND(AVG(ESTOCAGEM_REAL), 2) AS EstocagemMediaGeral,
                ROUND(AVG(ECLOSAO_REAL), 2) AS EclosaoMediaGeral
            FROM POCWEB_DASH_INCUBATORIO";

        var metrics = await connection.QueryFirstAsync<dynamic>(metricsSql);

        dashboard.Metrics = new List<DashboardMetric>
        {
            new()
            {
                Id = "total_lotes",
                Label = "Total de Lotes",
                Value = (decimal)(metrics.TOTALLOTES ?? 0),
                Icon = "Layers",
                Color = "primary"
            },
            new()
            {
                Id = "total_nascidos",
                Label = "Total Nascidos",
                Value = (decimal)(metrics.TOTALNASCIDOS ?? 0),
                Icon = "Bird",
                Color = "success"
            },
            new()
            {
                Id = "estocagem_media",
                Label = "Estocagem Media Geral",
                Value = (decimal)(metrics.ESTOCAGEMMEDIAGERAL ?? 0),
                Icon = "Archive",
                Color = "warning"
            },
            new()
            {
                Id = "eclosao_media",
                Label = "Eclosao Media Geral",
                Value = (decimal)(metrics.ECLOSAOMEDIAGERAL ?? 0),
                Icon = "Activity",
                Color = "action"
            }
        };

        // ===== DISTRIBUICOES =====
        // Eclosao Media por Linhagem
        var eclosaoLinhagemSql = @"
            SELECT
                TRIM(LINHAGEM) AS Category,
                ROUND(AVG(ECLOSAO_REAL), 2) AS Value
            FROM POCWEB_DASH_INCUBATORIO
            GROUP BY LINHAGEM
            ORDER BY AVG(ECLOSAO_REAL) DESC";

        var eclosaoLinhagem = (await connection.QueryAsync<dynamic>(eclosaoLinhagemSql)).ToList();

        var eclosaoLinhagemDistribution = new DashboardDistribution
        {
            Id = "eclosao_linhagem",
            Title = "Eclosao Media por Linhagem",
            Subtitle = "%",
            Items = eclosaoLinhagem.Select((l, i) => new DashboardDistributionItem
            {
                Category = (string)(l.CATEGORY ?? ""),
                Value = (decimal)(l.VALUE ?? 0),
                Color = i switch
                {
                    0 => COLOR_PRIMARY,
                    1 => COLOR_SUCCESS,
                    2 => COLOR_WARNING,
                    _ => COLOR_ACTION
                }
            }).ToList()
        };

        // Eclosao Media por Lote
        var eclosaoLoteSql = @"
            SELECT
                'Lote ' || NRO_LOTE AS Category,
                ROUND(AVG(ECLOSAO_REAL), 2) AS Value
            FROM POCWEB_DASH_INCUBATORIO
            GROUP BY NRO_LOTE
            ORDER BY AVG(ECLOSAO_REAL) DESC";

        var eclosaoLote = (await connection.QueryAsync<dynamic>(eclosaoLoteSql)).ToList();

        var eclosaoLoteDistribution = new DashboardDistribution
        {
            Id = "eclosao_lote",
            Title = "Eclosao Media por Lote",
            Subtitle = "%",
            Items = eclosaoLote.Select((l, i) => new DashboardDistributionItem
            {
                Category = (string)(l.CATEGORY ?? ""),
                Value = (decimal)(l.VALUE ?? 0),
                Color = i switch
                {
                    0 => COLOR_SUCCESS,
                    1 => COLOR_PRIMARY,
                    2 => COLOR_WARNING,
                    3 => COLOR_ACTION,
                    _ => COLOR_ERROR
                }
            }).ToList()
        };

        dashboard.Distributions = new List<DashboardDistribution>
        {
            eclosaoLinhagemDistribution,
            eclosaoLoteDistribution
        };

        // ===== TRENDS (dados estaticos para POC) =====
        dashboard.Trends = new List<DashboardTrend>
        {
            new()
            {
                Id = "eclosao_semanal",
                Title = "Eclosao Semanal",
                Type = "line",
                XKey = "dia",
                Series = new List<DashboardTrendSeries>
                {
                    new() { YKey = "real", Label = "Real", Color = COLOR_PRIMARY },
                    new() { YKey = "padrao", Label = "Padrao", Color = COLOR_SUCCESS }
                },
                Data = new List<Dictionary<string, object>>
                {
                    new() { { "dia", "Seg" }, { "real", 74.5 }, { "padrao", 80.0 } },
                    new() { { "dia", "Ter" }, { "real", 76.2 }, { "padrao", 80.0 } },
                    new() { { "dia", "Qua" }, { "real", 72.8 }, { "padrao", 80.0 } },
                    new() { { "dia", "Qui" }, { "real", 75.1 }, { "padrao", 80.0 } },
                    new() { { "dia", "Sex" }, { "real", 73.7 }, { "padrao", 80.0 } },
                    new() { { "dia", "Sab" }, { "real", 74.3 }, { "padrao", 80.0 } },
                    new() { { "dia", "Dom" }, { "real", 71.9 }, { "padrao", 80.0 } }
                }
            }
        };

        // ===== RANKINGS =====
        // Top Eclosao por Lote
        var topEclosaoSql = @"
            SELECT
                'Lote ' || NRO_LOTE || ' - ' || TRIM(LINHAGEM) AS Category,
                ROUND(AVG(ECLOSAO_REAL), 2) AS Value
            FROM POCWEB_DASH_INCUBATORIO
            GROUP BY NRO_LOTE, LINHAGEM
            ORDER BY AVG(ECLOSAO_REAL) DESC
            FETCH FIRST 5 ROWS ONLY";

        var topEclosao = (await connection.QueryAsync<dynamic>(topEclosaoSql)).ToList();

        var topEclosaoRanking = new DashboardRanking
        {
            Id = "top_eclosao",
            Title = "Top Eclosao",
            MaxItems = 5,
            Items = topEclosao.Select(v => new DashboardRankingItem
            {
                Category = (string)(v.CATEGORY ?? ""),
                Value = (decimal)(v.VALUE ?? 0),
                Color = (decimal)(v.VALUE ?? 0) >= 85 ? COLOR_SUCCESS :
                        (decimal)(v.VALUE ?? 0) >= 75 ? COLOR_WARNING : COLOR_ERROR
            }).ToList()
        };

        // Estocagem por Lote
        var estocagemSql = @"
            SELECT
                'Lote ' || NRO_LOTE AS Category,
                ROUND(AVG(ESTOCAGEM_REAL), 2) AS Value
            FROM POCWEB_DASH_INCUBATORIO
            GROUP BY NRO_LOTE
            ORDER BY AVG(ESTOCAGEM_REAL) DESC
            FETCH FIRST 5 ROWS ONLY";

        var estocagem = (await connection.QueryAsync<dynamic>(estocagemSql)).ToList();

        var estocagemRanking = new DashboardRanking
        {
            Id = "estocagem_lote",
            Title = "Estocagem por Lote",
            MaxItems = 5,
            Items = estocagem.Select(e => new DashboardRankingItem
            {
                Category = (string)(e.CATEGORY ?? ""),
                Value = (decimal)(e.VALUE ?? 0),
                Color = (decimal)(e.VALUE ?? 0) <= 3 ? COLOR_SUCCESS :
                        (decimal)(e.VALUE ?? 0) <= 5 ? COLOR_WARNING : COLOR_ERROR
            }).ToList()
        };

        dashboard.Rankings = new List<DashboardRanking>
        {
            topEclosaoRanking,
            estocagemRanking
        };

        return dashboard;
    }

    /// <summary>
    /// Dashboard especifico para Frango de Corte
    /// </summary>
    private async Task<DashboardData> GetFrangoCorteDashboardAsync(
        System.Data.IDbConnection connection,
        DashboardConfigDto config)
    {
        var dashboard = new DashboardData
        {
            ModuleId = config.ModuleId,
            ModuleName = config.ModuleName
        };

        // ===== METRICAS =====
        var metricsSql = @"
            SELECT
                COUNT(*) AS TotalLotes,
                SUM(ALOJADAS) AS TotalAlojadas,
                ROUND(AVG(MORTE_PERC), 2) AS MortalidadeMedia,
                ROUND(AVG(PESO_MEDIO), 3) AS PesoMedio,
                ROUND(AVG(CA), 3) AS CAMedio,
                ROUND(AVG(IEP), 2) AS IEPMedio
            FROM POCWEB_DASH_FRANGO_CORTE";

        var metrics = await connection.QueryFirstAsync<dynamic>(metricsSql);

        dashboard.Metrics = new List<DashboardMetric>
        {
            new()
            {
                Id = "total_lotes",
                Label = "Total de Lotes",
                Value = (decimal)(metrics.TOTALLOTES ?? 0),
                Icon = "Layers",
                Color = "primary"
            },
            new()
            {
                Id = "total_alojadas",
                Label = "Aves Alojadas",
                Value = (decimal)(metrics.TOTALALOJADAS ?? 0),
                Icon = "Bird",
                Color = "success"
            },
            new()
            {
                Id = "mortalidade_media",
                Label = "Mortalidade Media",
                Value = (decimal)(metrics.MORTALIDADEMEDIA ?? 0),
                Icon = "TrendingDown",
                Color = "warning"
            },
            new()
            {
                Id = "iep_medio",
                Label = "IEP Medio",
                Value = (decimal)(metrics.IEPMEDIO ?? 0),
                Icon = "Activity",
                Color = "action"
            }
        };

        // ===== DISTRIBUICOES =====
        // Distribuicao por Tipo de Galpao
        var galpaoSql = @"
            SELECT
                CASE WHEN TIPO_GALPAO IS NULL OR TRIM(TIPO_GALPAO) = '' THEN 'Nao Informado' ELSE TRIM(TIPO_GALPAO) END AS Category,
                COUNT(*) AS Value
            FROM POCWEB_DASH_FRANGO_CORTE
            GROUP BY CASE WHEN TIPO_GALPAO IS NULL OR TRIM(TIPO_GALPAO) = '' THEN 'Nao Informado' ELSE TRIM(TIPO_GALPAO) END
            ORDER BY COUNT(*) DESC";

        var galpoes = (await connection.QueryAsync<dynamic>(galpaoSql)).ToList();

        var galpaoDistribution = new DashboardDistribution
        {
            Id = "tipo_galpao",
            Title = "Distribuicao por Tipo Galpao",
            Subtitle = "Lotes",
            Items = galpoes.Select((g, i) => new DashboardDistributionItem
            {
                Category = (string)(g.CATEGORY ?? ""),
                Value = (decimal)(g.VALUE ?? 0),
                Color = i switch
                {
                    0 => COLOR_PRIMARY,
                    1 => COLOR_SUCCESS,
                    2 => COLOR_WARNING,
                    _ => COLOR_ACTION
                }
            }).ToList()
        };

        // Faixa de Viabilidade
        var viabSql = @"
            SELECT
                CASE
                    WHEN VIABILIDADE >= 95 THEN 'Excelente (95%+)'
                    WHEN VIABILIDADE >= 90 THEN 'Bom (90-95%)'
                    WHEN VIABILIDADE >= 85 THEN 'Regular (85-90%)'
                    ELSE 'Critico (<85%)'
                END AS Category,
                COUNT(*) AS Value
            FROM POCWEB_DASH_FRANGO_CORTE
            GROUP BY
                CASE
                    WHEN VIABILIDADE >= 95 THEN 'Excelente (95%+)'
                    WHEN VIABILIDADE >= 90 THEN 'Bom (90-95%)'
                    WHEN VIABILIDADE >= 85 THEN 'Regular (85-90%)'
                    ELSE 'Critico (<85%)'
                END
            ORDER BY MIN(VIABILIDADE) DESC";

        var viabilidade = (await connection.QueryAsync<dynamic>(viabSql)).ToList();

        var viabDistribution = new DashboardDistribution
        {
            Id = "faixa_viabilidade",
            Title = "Faixa de Viabilidade",
            Subtitle = "Lotes",
            Items = viabilidade.Select((v, i) => new DashboardDistributionItem
            {
                Category = (string)(v.CATEGORY ?? ""),
                Value = (decimal)(v.VALUE ?? 0),
                Color = ((string)(v.CATEGORY ?? "")).Contains("Excelente") ? COLOR_SUCCESS :
                        ((string)(v.CATEGORY ?? "")).Contains("Bom") ? COLOR_PRIMARY :
                        ((string)(v.CATEGORY ?? "")).Contains("Regular") ? COLOR_WARNING : COLOR_ERROR
            }).ToList()
        };

        dashboard.Distributions = new List<DashboardDistribution>
        {
            galpaoDistribution,
            viabDistribution
        };

        // ===== TRENDS (dados estaticos para POC) =====
        dashboard.Trends = new List<DashboardTrend>
        {
            new()
            {
                Id = "peso_semanal",
                Title = "Peso Medio Semanal",
                Type = "line",
                XKey = "semana",
                Series = new List<DashboardTrendSeries>
                {
                    new() { YKey = "real", Label = "Real", Color = COLOR_PRIMARY },
                    new() { YKey = "padrao", Label = "Padrao", Color = COLOR_SUCCESS }
                },
                Data = new List<Dictionary<string, object>>
                {
                    new() { { "semana", "S1" }, { "real", 2.85 }, { "padrao", 2.90 } },
                    new() { { "semana", "S2" }, { "real", 2.92 }, { "padrao", 2.90 } },
                    new() { { "semana", "S3" }, { "real", 3.05 }, { "padrao", 2.90 } },
                    new() { { "semana", "S4" }, { "real", 2.78 }, { "padrao", 2.90 } }
                }
            }
        };

        // ===== RANKINGS =====
        // Top IEP
        var topIepSql = @"
            SELECT
                'Lote ' || LOTE AS Category,
                IEP AS Value
            FROM POCWEB_DASH_FRANGO_CORTE
            WHERE IEP IS NOT NULL
            ORDER BY IEP DESC
            FETCH FIRST 5 ROWS ONLY";

        var topIep = (await connection.QueryAsync<dynamic>(topIepSql)).ToList();

        var topIepRanking = new DashboardRanking
        {
            Id = "top_iep",
            Title = "Top IEP",
            MaxItems = 5,
            Items = topIep.Select(v => new DashboardRankingItem
            {
                Category = (string)(v.CATEGORY ?? ""),
                Value = (decimal)(v.VALUE ?? 0),
                Color = (decimal)(v.VALUE ?? 0) >= 270 ? COLOR_SUCCESS :
                        (decimal)(v.VALUE ?? 0) >= 250 ? COLOR_WARNING : COLOR_ERROR
            }).ToList()
        };

        // Lotes Criticos (alta mortalidade)
        var criticosSql = @"
            SELECT
                'Lote ' || LOTE AS Category,
                MORTE_PERC AS Value
            FROM POCWEB_DASH_FRANGO_CORTE
            WHERE MORTE_PERC IS NOT NULL
            ORDER BY MORTE_PERC DESC
            FETCH FIRST 5 ROWS ONLY";

        var criticos = (await connection.QueryAsync<dynamic>(criticosSql)).ToList();

        var criticosRanking = new DashboardRanking
        {
            Id = "lotes_criticos",
            Title = "Maior Mortalidade",
            MaxItems = 5,
            Items = criticos.Select(c => new DashboardRankingItem
            {
                Category = (string)(c.CATEGORY ?? ""),
                Value = (decimal)(c.VALUE ?? 0),
                Color = (decimal)(c.VALUE ?? 0) >= 8 ? COLOR_ERROR :
                        (decimal)(c.VALUE ?? 0) >= 5 ? COLOR_WARNING : COLOR_SUCCESS
            }).ToList()
        };

        dashboard.Rankings = new List<DashboardRanking>
        {
            topIepRanking,
            criticosRanking
        };

        return dashboard;
    }

    /// <summary>
    /// Dashboard especifico para Fabrica de Racao
    /// </summary>
    private async Task<DashboardData> GetRacaoInsumoDashboardAsync(
        System.Data.IDbConnection connection,
        DashboardConfigDto config)
    {
        var dashboard = new DashboardData
        {
            ModuleId = config.ModuleId,
            ModuleName = config.ModuleName
        };

        // ===== METRICAS =====
        var metricsSql = @"
            SELECT
                COUNT(DISTINCT PRODUTO_FINAL) AS TotalProdutos,
                COUNT(DISTINCT INGREDIENTE) AS TotalIngredientes,
                ROUND(SUM(QTD_DOSADA), 2) AS VolumeTotal,
                ROUND(SUM(CUSTO), 2) AS CustoTotal
            FROM POCWEB_DASH_RACAO_INSUMO";

        var metrics = await connection.QueryFirstAsync<dynamic>(metricsSql);

        dashboard.Metrics = new List<DashboardMetric>
        {
            new()
            {
                Id = "total_produtos",
                Label = "Produtos Finais",
                Value = (decimal)(metrics.TOTALPRODUTOS ?? 0),
                Icon = "Package",
                Color = "primary"
            },
            new()
            {
                Id = "total_ingredientes",
                Label = "Ingredientes",
                Value = (decimal)(metrics.TOTALINGREDIENTES ?? 0),
                Icon = "Layers",
                Color = "success"
            },
            new()
            {
                Id = "volume_total",
                Label = "Volume Total (kg)",
                Value = (decimal)(metrics.VOLUMETOTAL ?? 0),
                Icon = "Scale",
                Color = "warning"
            },
            new()
            {
                Id = "custo_total",
                Label = "Custo Total (R$)",
                Value = (decimal)(metrics.CUSTOTOTAL ?? 0),
                Icon = "DollarSign",
                Color = "action"
            }
        };

        // ===== DISTRIBUICOES =====
        // Custo por Produto Final
        var custoProdutoSql = @"
            SELECT
                TRIM(PRODUTO_FINAL) AS Category,
                ROUND(SUM(CUSTO), 2) AS Value
            FROM POCWEB_DASH_RACAO_INSUMO
            GROUP BY PRODUTO_FINAL
            ORDER BY SUM(CUSTO) DESC
            FETCH FIRST 5 ROWS ONLY";

        var custoProduto = (await connection.QueryAsync<dynamic>(custoProdutoSql)).ToList();

        var custoProdutoDistribution = new DashboardDistribution
        {
            Id = "custo_produto",
            Title = "Custo por Produto",
            Subtitle = "R$",
            Items = custoProduto.Select((p, i) => new DashboardDistributionItem
            {
                Category = (string)(p.CATEGORY ?? ""),
                Value = (decimal)(p.VALUE ?? 0),
                Color = i switch
                {
                    0 => COLOR_PRIMARY,
                    1 => COLOR_SUCCESS,
                    2 => COLOR_WARNING,
                    3 => COLOR_ACTION,
                    _ => COLOR_ERROR
                }
            }).ToList()
        };

        // Volume por Produto
        var volumeProdutoSql = @"
            SELECT
                TRIM(PRODUTO_FINAL) AS Category,
                ROUND(SUM(QTD_DOSADA), 2) AS Value
            FROM POCWEB_DASH_RACAO_INSUMO
            GROUP BY PRODUTO_FINAL
            ORDER BY SUM(QTD_DOSADA) DESC
            FETCH FIRST 5 ROWS ONLY";

        var volumeProduto = (await connection.QueryAsync<dynamic>(volumeProdutoSql)).ToList();

        var volumeProdutoDistribution = new DashboardDistribution
        {
            Id = "volume_produto",
            Title = "Volume por Produto",
            Subtitle = "kg",
            Items = volumeProduto.Select((p, i) => new DashboardDistributionItem
            {
                Category = (string)(p.CATEGORY ?? ""),
                Value = (decimal)(p.VALUE ?? 0),
                Color = i switch
                {
                    0 => COLOR_PRIMARY,
                    1 => COLOR_SUCCESS,
                    2 => COLOR_WARNING,
                    3 => COLOR_ACTION,
                    _ => COLOR_ERROR
                }
            }).ToList()
        };

        dashboard.Distributions = new List<DashboardDistribution>
        {
            custoProdutoDistribution,
            volumeProdutoDistribution
        };

        // ===== TRENDS (dados estaticos para POC) =====
        dashboard.Trends = new List<DashboardTrend>
        {
            new()
            {
                Id = "producao_semanal",
                Title = "Producao Semanal",
                Type = "area",
                XKey = "semana",
                Series = new List<DashboardTrendSeries>
                {
                    new() { YKey = "volume", Label = "Volume (ton)", Color = COLOR_PRIMARY }
                },
                Data = new List<Dictionary<string, object>>
                {
                    new() { { "semana", "S1" }, { "volume", 45.2 } },
                    new() { { "semana", "S2" }, { "volume", 52.8 } },
                    new() { { "semana", "S3" }, { "volume", 48.5 } },
                    new() { { "semana", "S4" }, { "volume", 55.1 } }
                }
            }
        };

        // ===== RANKINGS =====
        // Top Ingredientes por Custo
        var topCustoSql = @"
            SELECT
                TRIM(INGREDIENTE) AS Category,
                ROUND(SUM(CUSTO), 2) AS Value
            FROM POCWEB_DASH_RACAO_INSUMO
            GROUP BY INGREDIENTE
            ORDER BY SUM(CUSTO) DESC
            FETCH FIRST 5 ROWS ONLY";

        var topCusto = (await connection.QueryAsync<dynamic>(topCustoSql)).ToList();

        var topCustoRanking = new DashboardRanking
        {
            Id = "top_custo_ingrediente",
            Title = "Top Custo Ingrediente",
            MaxItems = 5,
            Items = topCusto.Select((c, i) => new DashboardRankingItem
            {
                Category = (string)(c.CATEGORY ?? ""),
                Value = (decimal)(c.VALUE ?? 0),
                Color = i == 0 ? COLOR_ERROR : i <= 2 ? COLOR_WARNING : COLOR_SUCCESS
            }).ToList()
        };

        // Top Ingredientes por Volume
        var topVolumeSql = @"
            SELECT
                TRIM(INGREDIENTE) AS Category,
                ROUND(SUM(QTD_DOSADA), 2) AS Value
            FROM POCWEB_DASH_RACAO_INSUMO
            GROUP BY INGREDIENTE
            ORDER BY SUM(QTD_DOSADA) DESC
            FETCH FIRST 5 ROWS ONLY";

        var topVolume = (await connection.QueryAsync<dynamic>(topVolumeSql)).ToList();

        var topVolumeRanking = new DashboardRanking
        {
            Id = "top_volume_ingrediente",
            Title = "Top Volume Ingrediente",
            MaxItems = 5,
            Items = topVolume.Select((v, i) => new DashboardRankingItem
            {
                Category = (string)(v.CATEGORY ?? ""),
                Value = (decimal)(v.VALUE ?? 0),
                Color = i switch
                {
                    0 => COLOR_PRIMARY,
                    1 => COLOR_SUCCESS,
                    2 => COLOR_WARNING,
                    _ => COLOR_ACTION
                }
            }).ToList()
        };

        dashboard.Rankings = new List<DashboardRanking>
        {
            topCustoRanking,
            topVolumeRanking
        };

        return dashboard;
    }

    /// <summary>
    /// Dashboard especifico para Poedeiras Comerciais
    /// </summary>
    private async Task<DashboardData> GetPoedeirasDashboardAsync(
        System.Data.IDbConnection connection,
        DashboardConfigDto config)
    {
        var dashboard = new DashboardData
        {
            ModuleId = config.ModuleId,
            ModuleName = config.ModuleName
        };

        // ===== METRICAS =====
        var metricsSql = @"
            SELECT
                ROUND(SUM(NATUR_OVOS_SEM) / 360, 0) AS CaixasProduzidas,
                SUM(SALDO_FEMEA) AS SaldoAves,
                SUM(QTD_MORTE) AS Mortalidade,
                SUM(DIF_OVOS) AS DiferencaOvos
            FROM POCWEB_DASH_POEDEIRAS";

        var metrics = await connection.QueryFirstAsync<dynamic>(metricsSql);

        dashboard.Metrics = new List<DashboardMetric>
        {
            new()
            {
                Id = "caixas_produzidas",
                Label = "Caixas Produzidas",
                Value = (decimal)(metrics.CAIXASPRODUZIDAS ?? 0),
                Icon = "Package",
                Color = "primary"
            },
            new()
            {
                Id = "saldo_aves",
                Label = "Saldo de Aves",
                Value = (decimal)(metrics.SALDOAVES ?? 0),
                Icon = "Bird",
                Color = "success"
            },
            new()
            {
                Id = "mortalidade",
                Label = "Mortalidade",
                Value = (decimal)(metrics.MORTALIDADE ?? 0),
                Icon = "TrendingDown",
                Color = "error"
            },
            new()
            {
                Id = "diferenca_ovos",
                Label = "Diferenca de Ovos",
                Value = (decimal)(metrics.DIFERENCAOVOS ?? 0),
                Icon = "Activity",
                Color = "action"
            }
        };

        // ===== DISTRIBUICOES =====
        // Producao por Granja
        var producaoGranjaSql = @"
            SELECT
                'Granja ' || GRANJA AS Category,
                SUM(NATUR_OVOS_SEM) AS Value
            FROM POCWEB_DASH_POEDEIRAS
            GROUP BY GRANJA
            ORDER BY SUM(NATUR_OVOS_SEM) DESC";

        var producaoGranja = (await connection.QueryAsync<dynamic>(producaoGranjaSql)).ToList();

        var producaoGranjaDistribution = new DashboardDistribution
        {
            Id = "producao_granja",
            Title = "Producao por Granja",
            Subtitle = "ovos",
            Items = producaoGranja.Select((g, i) => new DashboardDistributionItem
            {
                Category = (string)(g.CATEGORY ?? ""),
                Value = (decimal)(g.VALUE ?? 0),
                Color = i switch
                {
                    0 => COLOR_PRIMARY,
                    1 => COLOR_SUCCESS,
                    2 => COLOR_WARNING,
                    _ => COLOR_ACTION
                }
            }).ToList()
        };

        // Postura Media por Linhagem
        var posturaLinhagemSql = @"
            SELECT
                TRIM(LINHAGEM) AS Category,
                ROUND(AVG(POSTURA_OBTIDA_SEM), 2) AS Value
            FROM POCWEB_DASH_POEDEIRAS
            GROUP BY LINHAGEM
            ORDER BY AVG(POSTURA_OBTIDA_SEM) DESC";

        var posturaLinhagem = (await connection.QueryAsync<dynamic>(posturaLinhagemSql)).ToList();

        var posturaLinhagemDistribution = new DashboardDistribution
        {
            Id = "postura_linhagem",
            Title = "Postura Media por Linhagem",
            Subtitle = "%",
            Items = posturaLinhagem.Select((l, i) => new DashboardDistributionItem
            {
                Category = (string)(l.CATEGORY ?? ""),
                Value = (decimal)(l.VALUE ?? 0),
                Color = i switch
                {
                    0 => COLOR_SUCCESS,
                    1 => COLOR_PRIMARY,
                    2 => COLOR_WARNING,
                    _ => COLOR_ACTION
                }
            }).ToList()
        };

        dashboard.Distributions = new List<DashboardDistribution>
        {
            producaoGranjaDistribution,
            posturaLinhagemDistribution
        };

        // ===== TRENDS (dados estaticos para POC) =====
        dashboard.Trends = new List<DashboardTrend>
        {
            new()
            {
                Id = "producao_semanal",
                Title = "Producao Semanal",
                Type = "line",
                XKey = "dia",
                Series = new List<DashboardTrendSeries>
                {
                    new() { YKey = "real", Label = "Producao Real", Color = COLOR_PRIMARY },
                    new() { YKey = "padrao", Label = "Producao Padrao", Color = COLOR_SUCCESS }
                },
                Data = new List<Dictionary<string, object>>
                {
                    new() { { "dia", "Seg" }, { "real", 91.5 }, { "padrao", 90.0 } },
                    new() { { "dia", "Ter" }, { "real", 92.3 }, { "padrao", 90.0 } },
                    new() { { "dia", "Qua" }, { "real", 89.8 }, { "padrao", 90.0 } },
                    new() { { "dia", "Qui" }, { "real", 93.1 }, { "padrao", 90.0 } },
                    new() { { "dia", "Sex" }, { "real", 90.7 }, { "padrao", 90.0 } },
                    new() { { "dia", "Sab" }, { "real", 88.5 }, { "padrao", 90.0 } },
                    new() { { "dia", "Dom" }, { "real", 87.2 }, { "padrao", 90.0 } }
                }
            }
        };

        // ===== RANKINGS =====
        // Top Postura por Galinheiro
        var topPosturaSql = @"
            SELECT
                'Lote ' || NRO_LOTE || ' / Gal ' || COD_GALINHEIRO AS Category,
                POSTURA_OBTIDA_SEM AS Value
            FROM POCWEB_DASH_POEDEIRAS
            ORDER BY POSTURA_OBTIDA_SEM DESC
            FETCH FIRST 5 ROWS ONLY";

        var topPostura = (await connection.QueryAsync<dynamic>(topPosturaSql)).ToList();

        var topPosturaRanking = new DashboardRanking
        {
            Id = "top_postura",
            Title = "Top Postura",
            MaxItems = 5,
            Items = topPostura.Select(p => new DashboardRankingItem
            {
                Category = (string)(p.CATEGORY ?? ""),
                Value = (decimal)(p.VALUE ?? 0),
                Color = (decimal)(p.VALUE ?? 0) >= 95 ? COLOR_SUCCESS :
                        (decimal)(p.VALUE ?? 0) >= 90 ? COLOR_WARNING : COLOR_ERROR
            }).ToList()
        };

        // Galinheiros com maior deficit de producao
        var deficitSql = @"
            SELECT
                'Lote ' || NRO_LOTE || ' / Gal ' || COD_GALINHEIRO AS Category,
                DIF_OVOS AS Value
            FROM POCWEB_DASH_POEDEIRAS
            WHERE DIF_OVOS < 0
            ORDER BY DIF_OVOS ASC
            FETCH FIRST 5 ROWS ONLY";

        var deficit = (await connection.QueryAsync<dynamic>(deficitSql)).ToList();

        var deficitRanking = new DashboardRanking
        {
            Id = "deficit_producao",
            Title = "Deficit de Producao",
            MaxItems = 5,
            Items = deficit.Select(d => new DashboardRankingItem
            {
                Category = (string)(d.CATEGORY ?? ""),
                Value = (decimal)(d.VALUE ?? 0),
                Color = (decimal)(d.VALUE ?? 0) < -300 ? COLOR_ERROR :
                        (decimal)(d.VALUE ?? 0) < -100 ? COLOR_WARNING : COLOR_SUCCESS
            }).ToList()
        };

        dashboard.Rankings = new List<DashboardRanking>
        {
            topPosturaRanking,
            deficitRanking
        };

        return dashboard;
    }
}
