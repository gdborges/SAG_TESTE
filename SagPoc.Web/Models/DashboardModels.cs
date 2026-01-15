namespace SagPoc.Web.Models;

/// <summary>
/// Resposta principal da API de Dashboard
/// </summary>
public class DashboardResponse
{
    public bool Success { get; set; }
    public DashboardData? Data { get; set; }
    public string? Error { get; set; }
}

/// <summary>
/// Dados completos do dashboard
/// </summary>
public class DashboardData
{
    public int ModuleId { get; set; }
    public string ModuleName { get; set; } = "";
    public List<DashboardMetric> Metrics { get; set; } = new();
    public List<DashboardDistribution> Distributions { get; set; } = new();
    public List<DashboardTrend> Trends { get; set; } = new();
    public List<DashboardRanking> Rankings { get; set; } = new();
}

/// <summary>
/// Card de metrica (KPI)
/// </summary>
public class DashboardMetric
{
    public string Id { get; set; } = "";
    public string Label { get; set; } = "";
    public decimal Value { get; set; }
    public string Icon { get; set; } = "";
    public string Color { get; set; } = "";
    public DashboardTrendInfo? Trend { get; set; }
}

/// <summary>
/// Info de tendencia para metricas
/// </summary>
public class DashboardTrendInfo
{
    public string Direction { get; set; } = "stable"; // "up", "down", "stable"
    public decimal Percentage { get; set; }
}

/// <summary>
/// Grafico de distribuicao (Doughnut)
/// </summary>
public class DashboardDistribution
{
    public string Id { get; set; } = "";
    public string Title { get; set; } = "";
    public string? Subtitle { get; set; }
    public List<DashboardDistributionItem> Items { get; set; } = new();
}

public class DashboardDistributionItem
{
    public string Category { get; set; } = "";
    public decimal Value { get; set; }
    public string? Color { get; set; }
}

/// <summary>
/// Grafico de tendencia (Line/Area)
/// </summary>
public class DashboardTrend
{
    public string Id { get; set; } = "";
    public string Title { get; set; } = "";
    public string Type { get; set; } = "line"; // "line" ou "area"
    public string XKey { get; set; } = "";
    public List<DashboardTrendSeries> Series { get; set; } = new();
    public List<Dictionary<string, object>> Data { get; set; } = new();
}

public class DashboardTrendSeries
{
    public string YKey { get; set; } = "";
    public string Label { get; set; } = "";
    public string? Color { get; set; }
}

/// <summary>
/// Grafico de ranking (Bar)
/// </summary>
public class DashboardRanking
{
    public string Id { get; set; } = "";
    public string Title { get; set; } = "";
    public List<DashboardRankingItem> Items { get; set; } = new();
    public int? MaxItems { get; set; }
}

public class DashboardRankingItem
{
    public string Category { get; set; } = "";
    public decimal Value { get; set; }
    public string? Color { get; set; }
}

/// <summary>
/// Configuracao de dashboard disponivel
/// </summary>
public class DashboardConfigDto
{
    public int Id { get; set; }
    public int ModuleId { get; set; }
    public string ModuleName { get; set; } = "";
    public string DashboardKey { get; set; } = "";
    public bool Active { get; set; }
}

/// <summary>
/// Dados brutos de matrizes pesadas (mapeamento da tabela)
/// </summary>
public class MatrizesPesadasData
{
    public int Id { get; set; }
    public int EmpresaId { get; set; }
    public DateTime DataCarga { get; set; }
    public int NroLote { get; set; }
    public string LinhagemFemea { get; set; } = "";
    public int Idade { get; set; }
    public int SaldoFemea { get; set; }
    public decimal ViabilidadeStandard { get; set; }
    public decimal ViabilidadeReal { get; set; }
    public decimal RacaoFemeaStandard { get; set; }
    public decimal RacaoFemea { get; set; }
    public decimal PosturaPadrao { get; set; }
    public decimal PosturaObtida { get; set; }
    public decimal OvoAveAcumStandard { get; set; }
    public decimal OvoAveAcum { get; set; }
    public decimal AprovOvoPadraoGranja { get; set; }
    public decimal AproveitamentoGranja { get; set; }
    public decimal AproveitamentoIncubatorio { get; set; }
    public decimal EclosaoPadrao { get; set; }
    public decimal EclosaoReal { get; set; }
    public decimal PintoAveAcumPadrao { get; set; }
    public decimal PintoAveAcum { get; set; }
}
