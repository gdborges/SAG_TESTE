using Dapper;
using System.Text.Json;
using SagPoc.Web.Models;
using SagPoc.Web.Services.Database;

namespace SagPoc.Web.Services;

/// <summary>
/// Serviço de módulos e janelas do SAG.
/// Consulta POViAcPr (view de acesso) + CLCaProd para módulos filtrados por permissão.
/// A view POViAcPr usa sys_context('SAG_USUARIO') para filtrar por usuário/empresa.
/// </summary>
public class ModuleService : IModuleService
{
    private readonly IDbProvider _dbProvider;
    private readonly ILogger<ModuleService> _logger;
    private readonly IWebHostEnvironment _environment;
    private MenuOrderConfig? _menuOrderConfig;

    // Mapeamento de siglas de módulos para ícones Lucide (https://lucide.dev/icons/)
    private static readonly Dictionary<string, string> ModuleIconMapping = new(StringComparer.OrdinalIgnoreCase)
    {
        // Módulos principais
        { "GE", "Settings" },           // Gerencial
        { "CO", "ShoppingCart" },       // Compras
        { "FI", "DollarSign" },         // Financeiro
        { "ES", "Package" },            // Estoques
        { "CR", "Users" },              // CRM
        { "CE", "Wheat" },              // Cerealista
        { "LA", "FlaskConical" },       // Laboratório
        { "FP", "UserCheck" },          // Folha de Pagamento
        { "IS", "Leaf" },               // ISS

        // Avicultura
        { "MP", "Egg" },                // Matrizes Pesadas
        { "IN", "Thermometer" },        // Incubatório
        { "FC", "Bird" },               // Frango de Corte
        { "AB", "Factory" },            // Abatedouro Aves
        { "AV", "Bird" },               // Avicultura
        { "PO", "Egg" },                // Postura Comercial
        { "GP", "Dna" },                // Genética Pesada e Incubatório

        // Abatedouros
        { "BO", "Beef" },               // Abatedouro Bovinos
        { "AS", "Ham" },                // Abatedouro Suínos

        // Produção e Indústria
        { "RA", "Factory" },            // Fábrica de Ração
        { "IT", "Factory" },            // Indústria
        { "MN", "Wrench" },             // Manutenção Industrial
        { "PE", "Tractor" },            // Pecuária
        { "EX", "PackageCheck" },       // Expedição

        // Transporte
        { "FR", "Truck" },              // Frotas

        // Fiscal e Contábil
        { "NF", "FileText" },           // NFe/MDFe
        { "EN", "Receipt" },            // ECF/NFCe
        { "CT", "Calculator" },         // Contábil
        { "FS", "FileSpreadsheet" },    // Fiscal
        { "PA", "Building2" },          // Patrimonial

        // Financeiro e Cobrança
        { "CB", "CreditCard" },         // Cobrança

        // RH
        { "CA", "Clock" },              // Cartão Ponto

        // Vendas
        { "VD", "Store" },              // Vendas - Distribuição
        { "RE", "ClipboardList" },      // Requisição/Pedido

        // Planejamento (Plan)
        { "1V", "TrendingUp" },         // Plan - Vendas
        { "1M", "BarChart3" },          // Plan - Matrizes Pesadas
        { "1I", "BarChart3" },          // Plan - Incubatório
        { "1F", "BarChart3" },          // Plan - Frango de Corte
        { "1A", "BarChart3" },          // Plan - Abatedouro

        // SAGMob (Mobile)
        { "PV", "Smartphone" },         // SAGMob - Vendas
        { "PM", "Smartphone" },         // SAGMob - Matrizes Pesadas
        { "PI", "Smartphone" },         // SAGMob - Incubatório
        { "PB", "Smartphone" },         // SAGMob - Abatedouro
        { "PG", "Smartphone" },         // SAGMob - Pecuária
        { "PC", "Smartphone" },         // SAGMob - Frango de Corte
        { "PP", "Smartphone" },         // SAGMob - Postura Comercial

        // Web e Integração
        { "SW", "Globe" },              // SAG Web
        { "WV", "Globe" },              // Web Vision
        { "WP", "Headphones" },         // Web Portal
        { "SC", "ScanLine" },           // SAGColetor

        // Outros
        { "CW", "Briefcase" },          // Prática - CW
        { "BE", "Lightbulb" },          // Projeto B.E.N.
        { "SS", "Cloud" },              // Postura SaSS
    };

    // Mapeamento de MenuId para ícones Lucide (fallback para janelas)
    private static readonly Dictionary<string, string> MenuIconMapping = new(StringComparer.OrdinalIgnoreCase)
    {
        { "MNUCADA", "FolderOpen" },       // Cadastro
        { "MNULOTE", "Layers" },           // Lote
        { "MNUCOMPCOMP", "ShoppingCart" }, // Compras
        { "MNUFINA", "DollarSign" },       // Financeiro
        { "MNUNOTA", "FileText" },         // Nota Fiscal
        { "MNUPREV", "ClipboardList" },    // Pré-Venda
        { "MNUVEND", "Store" },            // Venda Direta
        { "MNUABAT", "Factory" },          // Abatedouro
        { "MNUABATESTO", "Package" },      // Abatedouro Estoque
        { "MNUABATEXPE", "Truck" },        // Abatedouro Expedição
        { "MNUESTO", "Package" },          // Estoque
        { "MNUEXPE", "PackageCheck" },     // Expedição
        { "MNUSAG_COLE", "ScanLine" },     // SAG Coletor
        { "MNUSTAN", "LayoutGrid" },       // Standard
        { "MNUCONT", "Calculator" },       // Contabiliza
        { "MNUQUAL", "CheckCircle" },      // Qualidade
        { "MNUINCU", "Thermometer" },      // Incubatório
        { "MNUPEDI", "ClipboardList" },    // Pedidos
        { "MNUPERS", "Sparkles" },         // Personalizado
        { "MNUGERE", "BarChart3" },        // Gerência
        { "MNUSIST", "Settings" },         // Sistema
        { "MNUUTIL", "Wrench" },           // Utilitários
        { "MNUARQU", "FileArchive" },      // Arquivos
        { "MNURELA", "FileSpreadsheet" },  // Relatórios
        { "MNUCONS", "Search" },           // Consultas
        { "MNUPROC", "Play" },             // Processos
        { "MNUPROD", "Factory" },          // Produção
        { "MNUMATR", "Egg" },              // Matrizes
        { "MNUFRAN", "Bird" },             // Frango
    };

    // Mapeamento de palavras-chave no nome da janela para ícones (prioridade sobre menu)
    private static readonly (string Keyword, string Icon)[] WindowKeywordIcons = new[]
    {
        // Cadastros específicos
        ("Cliente", "User"),
        ("Fornecedor", "Building"),
        ("Produto", "Package"),
        ("Funcionário", "UserCog"),
        ("Funcionario", "UserCog"),
        ("Usuário", "User"),
        ("Usuario", "User"),
        ("Empresa", "Building2"),
        ("Filial", "Building2"),
        ("Vendedor", "BadgeDollarSign"),
        ("Transportador", "Truck"),
        ("Motorista", "Car"),
        ("Veículo", "Car"),
        ("Veiculo", "Car"),

        // Financeiro
        ("Conta", "Wallet"),
        ("Banco", "Landmark"),
        ("Pagamento", "CreditCard"),
        ("Recebimento", "HandCoins"),
        ("Cobrança", "Receipt"),
        ("Cobranca", "Receipt"),
        ("Boleto", "FileText"),
        ("Título", "FileText"),
        ("Titulo", "FileText"),
        ("Caixa", "DollarSign"),
        ("Cheque", "CreditCard"),

        // Documentos
        ("Nota", "FileText"),
        ("NF-e", "FileText"),
        ("NFe", "FileText"),
        ("NFC-e", "Receipt"),
        ("NFCe", "Receipt"),
        ("CT-e", "Truck"),
        ("CTe", "Truck"),
        ("MDF-e", "Truck"),
        ("MDFe", "Truck"),
        ("Fatura", "FileText"),
        ("Romaneio", "ClipboardList"),
        ("Pedido", "ClipboardList"),
        ("Requisição", "ClipboardList"),
        ("Requisicao", "ClipboardList"),
        ("Ordem", "ClipboardList"),
        ("Cotação", "FileSearch"),
        ("Cotacao", "FileSearch"),

        // Estoque
        ("Estoque", "Package"),
        ("Entrada", "PackagePlus"),
        ("Saída", "PackageMinus"),
        ("Saida", "PackageMinus"),
        ("Transferência", "ArrowLeftRight"),
        ("Transferencia", "ArrowLeftRight"),
        ("Inventário", "ClipboardCheck"),
        ("Inventario", "ClipboardCheck"),
        ("Saldo", "Scale"),
        ("Lote", "Layers"),

        // Relatórios e Consultas
        ("Relatório", "FileSpreadsheet"),
        ("Relatorio", "FileSpreadsheet"),
        ("Consulta", "Search"),
        ("Dashboard", "LayoutDashboard"),
        ("Gráfico", "BarChart3"),
        ("Grafico", "BarChart3"),
        ("Análise", "PieChart"),
        ("Analise", "PieChart"),

        // Produção
        ("Produção", "Factory"),
        ("Producao", "Factory"),
        ("Fabricação", "Factory"),
        ("Fabricacao", "Factory"),
        ("Receita", "Book"),
        ("Fórmula", "FlaskConical"),
        ("Formula", "FlaskConical"),

        // Avicultura
        ("Ave", "Bird"),
        ("Ovo", "Egg"),
        ("Incubação", "Thermometer"),
        ("Incubacao", "Thermometer"),
        ("Matriz", "Egg"),
        ("Pintinho", "Bird"),
        ("Frango", "Bird"),
        ("Abate", "Factory"),

        // Agro
        ("Fazenda", "Tractor"),
        ("Granja", "Warehouse"),
        ("Silo", "Warehouse"),
        ("Balança", "Scale"),
        ("Balanca", "Scale"),
        ("Pesagem", "Scale"),
        ("Romaneio", "ClipboardList"),

        // Configurações
        ("Configuração", "Settings"),
        ("Configuracao", "Settings"),
        ("Parâmetro", "SlidersHorizontal"),
        ("Parametro", "SlidersHorizontal"),
        ("Tabela", "Table"),
        ("Grupo", "FolderTree"),
        ("Tipo", "Tag"),
        ("Classe", "Tag"),
        ("Categoria", "Tag"),

        // Processos
        ("Processo", "Play"),
        ("Importação", "Upload"),
        ("Importacao", "Upload"),
        ("Exportação", "Download"),
        ("Exportacao", "Download"),
        ("Geração", "Sparkles"),
        ("Geracao", "Sparkles"),
        ("Cálculo", "Calculator"),
        ("Calculo", "Calculator"),
        ("Fechamento", "Lock"),
        ("Abertura", "Unlock"),

        // Qualidade
        ("Qualidade", "CheckCircle"),
        ("Inspeção", "Search"),
        ("Inspecao", "Search"),
        ("Laudo", "FileCheck"),
        ("Amostra", "FlaskConical"),

        // Genéricos (última prioridade)
        ("Cadastro", "FilePlus"),
        ("Lista", "List"),
        ("Manutenção", "Wrench"),
        ("Manutencao", "Wrench"),
        ("Log", "ScrollText"),
        ("Histórico", "History"),
        ("Historico", "History"),
    };

    public ModuleService(IDbProvider dbProvider, ILogger<ModuleService> logger, IWebHostEnvironment environment)
    {
        _dbProvider = dbProvider;
        _logger = logger;
        _environment = environment;
        _logger.LogInformation("ModuleService inicializado com provider {Provider}", _dbProvider.ProviderName);
    }

    /// <inheritdoc/>
    public async Task<List<ModuleDto>> GetModulesAsync()
    {
        // Query para buscar módulos com acesso do usuário
        // POViAcPr é uma view que filtra por sys_context('SAG_USUARIO')
        // usando RETOPUSU() e RETOPEMP() internamente
        var sql = @"
            SELECT
                CLCaProd.CodiProd,
                CLCaProd.NomeProd,
                CLCaProd.SiglProd,
                CLCaProd.DescProd,
                CLCaProd.OrdeProd,
                CLCaProd.AtivProd
            FROM POViAcPr
            INNER JOIN CLCaProd ON POViAcPr.CodiProd = CLCaProd.CodiProd
            WHERE CLCaProd.AtivProd = 1
              AND CLCaProd.CodiProd > 0
            ORDER BY CLCaProd.CodiProd";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var results = await connection.QueryAsync<dynamic>(sql);
            var modules = new List<ModuleDto>();

            foreach (var row in results)
            {
                var sigla = row.SIGLPROD?.ToString()?.Trim() ?? "";
                var module = new ModuleDto
                {
                    ModuleId = Convert.ToInt32(row.CODIPROD),
                    Name = row.NOMEPROD?.ToString()?.Trim() ?? "",
                    Sigla = sigla,
                    Description = row.DESCPROD?.ToString()?.Trim() ?? "",
                    Order = Convert.ToInt32(row.ORDEPROD ?? 0),
                    Icon = GetIconForSigla(sigla)
                };
                modules.Add(module);
            }

            _logger.LogInformation("Retornando {Count} módulos", modules.Count);
            return modules;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar módulos");
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<List<MenuGroupDto>> GetWindowsByModuleAsync(int moduleId)
    {
        var windows = await GetWindowsFlatAsync(moduleId);
        var menuOrder = await LoadMenuOrderAsync();

        // Agrupa janelas por menu
        var groups = windows
            .GroupBy(w => w.MenuId ?? "OUTROS")
            .Select(g =>
            {
                var menuId = g.Key.ToUpperInvariant();
                var orderItem = menuOrder?.MenuOrder?.FirstOrDefault(m =>
                    m.MenuId.Equals(menuId, StringComparison.OrdinalIgnoreCase));

                return new MenuGroupDto
                {
                    MenuId = menuId,
                    Caption = orderItem?.Caption ?? g.First().MenuGroup ?? "Outros",
                    Order = orderItem?.Order ?? 999,
                    Icon = GetIconForMenu(menuId),
                    Windows = g.OrderByDescending(w => w.Order).ToList()
                };
            })
            .OrderByDescending(g => g.Order)
            .ThenBy(g => g.Caption)
            .ToList();

        _logger.LogInformation("Retornando {Count} grupos de menu para módulo {ModuleId}", groups.Count, moduleId);
        return groups;
    }

    /// <inheritdoc/>
    public async Task<List<WindowDto>> GetWindowsFlatAsync(int moduleId)
    {
        // Formato do código do sistema: S01, S02, S83, etc.
        var sistCode = $"S{moduleId:D2}";
        var likePattern = $"%{sistCode}%";

        var sql = $@"
            SELECT DISTINCT
                t.CodiTabe,
                t.CaptTabe,
                t.NomeTabe,
                t.SiglTabe,
                t.OrdeTabe,
                t.MenuTabe,
                m.MenuMenu,
                m.NomeMenu,
                m.OrdeMenu
            FROM POCaTabe t
            INNER JOIN POCaMenu m ON t.CodiTabe BETWEEN m.InicMenu AND m.FinaMenu
            WHERE t.MePeTabe <> 0
              AND t.SistTabe LIKE {_dbProvider.FormatParameter("LikePattern")}
              AND m.SistMenu LIKE {_dbProvider.FormatParameter("LikePattern")}
              AND m.AtivMenu <> 0
              AND t.CaptTabe <> '-'
              AND t.NomeTabe <> 'SUB'
              AND UPPER(m.MenuMenu) NOT IN ('MNUSIST', 'MNUUTIL')
            ORDER BY m.OrdeMenu DESC, t.OrdeTabe DESC";

        try
        {
            using var connection = _dbProvider.CreateConnection();
            connection.Open();

            var results = await connection.QueryAsync<dynamic>(sql, new { LikePattern = likePattern });
            var windows = new List<WindowDto>();

            foreach (var row in results)
            {
                var codiTabe = Convert.ToInt32(row.CODITABE);
                var menuMenu = row.MENUMENU?.ToString()?.Trim() ?? "";
                var captTabe = row.CAPTTABE?.ToString()?.Trim() ?? "";

                var window = new WindowDto
                {
                    WindowId = $"SAG{codiTabe}",
                    Tag = $"SAG{codiTabe}",
                    Name = captTabe,
                    TableId = codiTabe,
                    MenuId = menuMenu.ToUpperInvariant(),
                    MenuGroup = row.NOMEMENU?.ToString()?.Trim() ?? "",
                    Order = Convert.ToInt32(row.ORDETABE ?? 0),
                    Icon = GetIconForWindow(captTabe, menuMenu)
                };
                windows.Add(window);
            }

            _logger.LogInformation("Retornando {Count} janelas para módulo {ModuleId} ({SistCode})",
                windows.Count, moduleId, sistCode);
            return windows;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar janelas do módulo {ModuleId}", moduleId);
            throw;
        }
    }

    /// <summary>
    /// Carrega a configuração de ordenação de menus do arquivo JSON
    /// </summary>
    private async Task<MenuOrderConfig?> LoadMenuOrderAsync()
    {
        if (_menuOrderConfig != null)
            return _menuOrderConfig;

        var configPath = Path.Combine(_environment.ContentRootPath, "Config", "MenuOrder.json");

        if (!File.Exists(configPath))
        {
            _logger.LogWarning("Arquivo de ordenação de menus não encontrado: {Path}", configPath);
            return null;
        }

        try
        {
            var json = await File.ReadAllTextAsync(configPath);
            _menuOrderConfig = JsonSerializer.Deserialize<MenuOrderConfig>(json, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
            _logger.LogInformation("Configuração de ordenação de menus carregada com {Count} itens",
                _menuOrderConfig?.MenuOrder?.Count ?? 0);
            return _menuOrderConfig;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar configuração de ordenação de menus");
            return null;
        }
    }

    /// <summary>
    /// Retorna o ícone Lucide para uma sigla de módulo
    /// </summary>
    private static string? GetIconForSigla(string? sigla)
    {
        if (string.IsNullOrEmpty(sigla))
            return null;

        return ModuleIconMapping.TryGetValue(sigla, out var icon) ? icon : null;
    }

    /// <summary>
    /// Retorna o ícone Lucide para um grupo de menu
    /// </summary>
    private static string GetIconForMenu(string? menuId)
    {
        if (!string.IsNullOrEmpty(menuId) && MenuIconMapping.TryGetValue(menuId, out var icon))
        {
            return icon;
        }
        return "Folder"; // Ícone padrão para grupos
    }

    /// <summary>
    /// Retorna o ícone Lucide para uma janela baseado em:
    /// 1. Palavras-chave no nome da janela (prioridade)
    /// 2. MenuId da janela (fallback)
    /// 3. Ícone genérico (último recurso)
    /// </summary>
    private static string GetIconForWindow(string? windowName, string? menuId)
    {
        // 1. Tenta encontrar por palavra-chave no nome
        if (!string.IsNullOrEmpty(windowName))
        {
            foreach (var (keyword, icon) in WindowKeywordIcons)
            {
                if (windowName.Contains(keyword, StringComparison.OrdinalIgnoreCase))
                {
                    return icon;
                }
            }
        }

        // 2. Tenta encontrar pelo MenuId
        if (!string.IsNullOrEmpty(menuId) && MenuIconMapping.TryGetValue(menuId, out var menuIcon))
        {
            return menuIcon;
        }

        // 3. Ícone genérico
        return "FileText";
    }
}
