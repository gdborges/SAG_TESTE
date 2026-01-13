namespace SagPoc.Web.Models
{
    /// <summary>
    /// DTO para representar um módulo do SAG
    /// Mapeado da tabela CLCaProd
    /// </summary>
    public class ModuleDto
    {
        /// <summary>Código do módulo (CodiProd)</summary>
        public int ModuleId { get; set; }

        /// <summary>Nome do módulo (NomeProd)</summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>Sigla do módulo (SiglProd)</summary>
        public string Sigla { get; set; } = string.Empty;

        /// <summary>Descrição do módulo (DescProd)</summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>Ordem de exibição (OrdeProd)</summary>
        public int Order { get; set; }

        /// <summary>Nome do ícone Lucide</summary>
        public string? Icon { get; set; }

        /// <summary>Lista de janelas do módulo (opcional, carregado separadamente)</summary>
        public List<WindowDto>? Windows { get; set; }
    }

    /// <summary>
    /// DTO para representar uma janela/tabela do SAG
    /// Mapeado das tabelas POCaTabe e POCaMenu
    /// </summary>
    public class WindowDto
    {
        /// <summary>ID da janela no formato "SAG{CodiTabe}"</summary>
        public string WindowId { get; set; } = string.Empty;

        /// <summary>Tag para roteamento (igual ao WindowId)</summary>
        public string Tag { get; set; } = string.Empty;

        /// <summary>Nome de exibição da janela (CaptTabe)</summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>Código da tabela para renderização (CodiTabe)</summary>
        public int TableId { get; set; }

        /// <summary>ID do menu pai para agrupamento (MenuMenu)</summary>
        public string? MenuId { get; set; }

        /// <summary>Nome do menu pai para agrupamento (NomeMenu)</summary>
        public string? MenuGroup { get; set; }

        /// <summary>Ordem dentro do menu (OrdeTabe)</summary>
        public int Order { get; set; }

        /// <summary>Nome do ícone Lucide (opcional)</summary>
        public string? Icon { get; set; }
    }

    /// <summary>
    /// DTO para representar um grupo de menus com suas janelas
    /// </summary>
    public class MenuGroupDto
    {
        /// <summary>ID do menu (MenuMenu em maiúsculo)</summary>
        public string MenuId { get; set; } = string.Empty;

        /// <summary>Caption do menu (NomeMenu)</summary>
        public string Caption { get; set; } = string.Empty;

        /// <summary>Ordem de exibição (do arquivo auxiliar ou OrdeMenu)</summary>
        public int Order { get; set; }

        /// <summary>Lista de janelas dentro deste menu</summary>
        public List<WindowDto> Windows { get; set; } = new();
    }

    /// <summary>
    /// DTO para configuração de ordenação de menu (carregado de MenuOrder.json)
    /// </summary>
    public class MenuOrderConfig
    {
        public List<MenuOrderItem> MenuOrder { get; set; } = new();
    }

    /// <summary>
    /// Item de configuração de ordenação de menu
    /// </summary>
    public class MenuOrderItem
    {
        public string MenuId { get; set; } = string.Empty;
        public string Caption { get; set; } = string.Empty;
        public int Order { get; set; }
        public bool Global { get; set; }
    }
}
