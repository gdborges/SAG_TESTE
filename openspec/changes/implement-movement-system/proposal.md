# Change: Implement Movement System for Web

## Why

O sistema SAG utiliza "Movimentos" para modelar relacionamentos 1:N entre registros no banco de dados. Exemplos incluem:
- Nota Fiscal (cabecalho) -> Itens da Nota (movimentos)
- Pedido (cabecalho) -> Itens do Pedido (movimentos)
- Contrato (cabecalho) -> Produtos do Contrato (movimentos)
- Colaborador (cabecalho) -> Historico de Locacoes (movimentos)

Atualmente, a POC web so renderiza o formulario de cabecalho. Para paridade funcional com o sistema Delphi original (TFrmPOHeCam6), precisamos implementar o sistema completo de movimentos, incluindo:
- Identificacao de tabelas filhas via campo CABETABE
- Grids de movimento com operacoes CRUD
- Modal nao-bloqueante para edicao de registros
- Eventos especificos de movimento (AnteIAE_Movi, DepoIncl, etc.)
- Suporte a 2 niveis de hierarquia (Cabecalho -> Movimento -> Sub-movimento)

## What Changes

### Backend (C#)

- **NOVO** `MovementMetadata.cs` - Model para metadados de tabela de movimento
- **NOVO** `IMovementService.cs` - Interface do servico
- **NOVO** `MovementService.cs` - Logica de carregamento e CRUD de movimentos
- **NOVO** `MovementController.cs` - API REST para operacoes de movimento
- **MODIFICADO** `TableMetadata.cs` - Adiciona CabeTabe, SeriTabe, GeTaTabe
- **MODIFICADO** `FormMetadata.cs` - Adiciona MovementTables list
- **MODIFICADO** `MetadataService.cs` - Adiciona GetMovementTablesAsync()
- **MODIFICADO** `EventService.cs` - Adiciona GetMovementEventsAsync()

### Frontend (Views)

- **NOVO** `_MovementSection.cshtml` - Container visual do movimento
- **NOVO** `_MovementGrid.cshtml` - Grid com botoes CRUD
- **NOVO** `_MovementModal.cshtml` - Modal de edicao nao-bloqueante
- **MODIFICADO** `Render.cshtml` - Integracao com secoes de movimento

### Frontend (JavaScript)

- **NOVO** `movement-manager.js` - Gerenciador de movimentos no browser
- **MODIFICADO** `sag-events.js` - Adiciona eventos de movimento
- **MODIFICADO** `plsag-interpreter.js` - Adiciona contexto DM/D2 para templates

## Impact

- **Affected specs**: Nenhum existente (novas capabilities)
- **Affected code**:
  - `SagPoc.Web/Models/` (2 novos, 2 modificados)
  - `SagPoc.Web/Services/` (2 novos, 2 modificados)
  - `SagPoc.Web/Controllers/` (1 novo)
  - `SagPoc.Web/Views/Form/` (3 novos, 1 modificado)
  - `SagPoc.Web/wwwroot/js/` (1 novo, 2 modificados)
- **Breaking changes**: Nenhum
- **Dependencies**:
  - PLSAG interpreter (implement-plsag-interpreter) - CONCLUIDO
  - Event system (sag-events.js) - CONCLUIDO
  - Form rendering infrastructure - CONCLUIDO

## Scope

Esta proposta cobre a implementacao completa do sistema de movimentos, dividida em 5 capabilities:

1. **movement-metadata** - Carregamento de metadados de movimento via CABETABE
2. **movement-rendering** - Renderizacao visual (grid, tabs, modals)
3. **movement-crud** - Operacoes CRUD com transacao por operacao
4. **movement-events** - Sistema de eventos especificos de movimento
5. **movement-integration** - Integracao com PLSAG e sistema de forms

## Decisoes de Design

| Aspecto | Decisao | Justificativa |
|---------|---------|---------------|
| Transacao | Por operacao | Simplifica arquitetura (HTTP stateless) |
| Modal | Nao-bloqueante | Permite multiplas operacoes simultaneas |
| Layout SERITABE | Respeitado | Fidelidade ao Delphi (>50 mesma guia, <=50 guia separada) |
| Hierarquia | 2 niveis | Cabecalho -> Movimento -> Sub-movimento |
| Orphan records | Nao criar | Registro so e criado ao confirmar (padrao moderno) |

## Documentacao de Referencia

- `Base/Movimentos/MOVIMENTOS_AS-IS.md` - Documentacao tecnica do Delphi
- `Base/Movimentos/MOVIMENTOS_DIAGRAMAS.md` - Diagramas de fluxo
- `Base/DICIONARIO_DADOS_SISTTABE_SISTCAMP.md` - Dicionario de dados
