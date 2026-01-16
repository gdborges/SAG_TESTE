# Project Context

## Purpose
POC (Proof of Concept) para renderização de formulários dinâmicos do SAG (Sistema de Administração Geral) em ambiente web. O sistema interpreta metadados de campos armazenados no banco de dados (tabela SistCamp) e renderiza formulários HTML dinâmicos que replicam o comportamento do sistema Delphi original.

**Objetivos:**
- Renderizar formulários dinâmicos baseados em metadados
- Manter fidelidade visual e funcional ao sistema Delphi original
- Suportar CRUD completo via grid de consulta
- Implementar eventos PLSAG (linguagem de script do SAG)
- Aplicar design system Vision para interface moderna

## Tech Stack
- **Backend:** ASP.NET Core 9.0 (MVC)
- **Linguagem:** C# com nullable habilitado
- **ORM:** Dapper (micro-ORM)
- **Banco de dados:** SQL Server Azure (Microsoft.Data.SqlClient)
- **Frontend:** Bootstrap 5, jQuery 3.x
- **Views:** Razor (.cshtml) com partial views
- **CSS:** CSS customizado (form-renderer.css, consulta-grid.css, vision-theme.css)

## Project Conventions

### Code Style
- Nomes de classes e métodos em PascalCase
- Propriedades de modelos seguem convenção do SAG: `NomeCamp`, `LabeCamp`, `CompCamp`, etc.
- Interfaces prefixadas com `I` (ex: `IMetadataService`)
- Comentários XML em português para documentação de classes e métodos
- Nullable reference types habilitados

### Architecture Patterns
- **Service Layer:** Serviços com interfaces para injeção de dependência
  - `MetadataService` - carrega metadados de formulários
  - `LookupService` - resolve combos e campos de referência (T/IT)
  - `ConsultaService` - grid de consulta e operações CRUD
  - `EventService` - processamento de eventos PLSAG
- **Partial Views:** Componentes reutilizáveis para renderização
  - `_FieldRendererV2.cshtml` - renderiza campos individuais
  - `_FieldRowRenderer.cshtml` - renderiza linhas de campos
  - `_FormTabContent.cshtml` - conteúdo de abas
  - `_ConsultaTab.cshtml` - grid de consulta
- **Models:** DTOs para metadados e requests/responses

### Testing Strategy
Atualmente sem testes automatizados (POC). Testes manuais via interface web.

### Git Workflow
- Branch principal: `master`
- Feature branches: `feature/<nome-feature>`
- Commits em português com prefixos: `feat:`, `fix:`, `refactor:`, `docs:`
- Mensagens descritivas do que foi alterado

## Domain Context
### Conceitos do SAG
- **CodiTabe:** ID da tabela/formulário (ex: 120 = TipDoc, 715 = Pedidos)
- **CodiCamp:** ID único do campo
- **CompCamp:** Tipo do componente (E=Edit, N=Numérico, C=Checkbox, S=Select, T=Lookup, BVL=Bevel, etc.)
- **GuiaCamp:** Índice da aba (0-9 = cabeçalho, >=10 = movimento/detalhe)
- **OrdeCamp:** Ordem de tabulação e agrupamento
- **TopoCamp/EsquCamp:** Coordenadas X/Y em pixels (layout Delphi)
- **TamaCamp/AltuCamp:** Largura/altura em pixels
- **Bevel:** Componente visual que agrupa campos (fieldset)
- **Movimento:** Registros filhos/detalhes (ex: itens de pedido)

### Eventos PLSAG
Linguagem de script do SAG com eventos como:
- `DEPOSHOW` - executado ao abrir formulário
- `ATUAGRID` - executado ao atualizar grid
- `APOSTABE` - executado após troca de aba

## Important Constraints
- Fidelidade ao comportamento do sistema Delphi original
- Metadados são somente leitura (definidos no banco SAG)
- Suporte a múltiplos tipos de campos (30+ tipos de componentes)
- Layout baseado em coordenadas pixel do Delphi (adaptado para CSS Grid/Flexbox)

## External Dependencies
- **SQL Server Azure:** Banco de dados principal (GDB_TESTE)
- **Design System Vision:** Referência visual do novo ERP web (documentação em Vision/docs/)
