# Change: Aplicar Design System Vision ao SAG-WEB

## Why

O SAG-WEB atualmente usa um visual baseado em Bootstrap padrão com cores e estilos genéricos. O sistema Vision possui um design system moderno e consistente que queremos replicar no SAG-WEB para oferecer uma experiência visual mais profissional e alinhada com outros sistemas da empresa.

**Importante**: Esta mudança afeta APENAS o aspecto visual (CSS, cores, tipografia, espaçamentos). A stack tecnológica (ASP.NET Core MVC, Razor, Bootstrap) permanece inalterada.

## What Changes

### Paleta de Cores
- **ANTES**: Verde primário (#5cb85c), bordas cinzas (#ddd), texto preto padrão
- **DEPOIS**: Azul primário (#447BDA), paleta neutral estruturada, cores de feedback padronizadas

### Tipografia
- **ANTES**: Fonte do sistema (sans-serif padrão)
- **DEPOIS**: Fonte Inter (Google Fonts)

### Espaçamentos e Bordas
- **ANTES**: Border-radius 4px para inputs, 8px para containers
- **DEPOIS**: Border-radius 6px para inputs/botões, 16px para containers

### Componentes Visuais
- Novos estilos para inputs, selects, botões
- Novos estilos para containers (form-container, bevel-group)
- Novos estilos para tabs e grids
- Estados visuais melhorados (hover, focus, disabled, error)
- Transições suaves em interações

### Arquivos Afetados
- `wwwroot/css/vision-theme.css` (NOVO)
- `wwwroot/css/form-renderer.css` (ATUALIZADO)
- `wwwroot/css/consulta-grid.css` (ATUALIZADO)
- `Views/Shared/_Layout.cshtml` (ATUALIZADO - incluir fonte Inter)

## Impact

- **Affected specs**: visual-design (novo)
- **Affected code**:
  - `SagPoc.Web/wwwroot/css/` - arquivos CSS
  - `SagPoc.Web/Views/Shared/_Layout.cshtml` - layout principal
- **Breaking changes**: Nenhum - mudanças puramente visuais
- **Funcionalidade**: 100% preservada

## Out of Scope

- Mudanças na stack tecnológica (Vue 3, ag-grid, etc.)
- Novos componentes JavaScript
- Alterações na lógica de negócio
- Modificações no backend
