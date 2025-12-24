## Context

O SAG Delphi usa um sistema de eventos onde cada componente possui uma propriedade `Lista.Text` contendo instrucoes PLSAG. Quando eventos como OnExit/OnClick disparam, a procedure `CampPersExecExit` executa essas instrucoes.

**Documentacao de referencia**: `Base/SISTEMA_EVENTOS_PLSAG.md`

## Goals / Non-Goals

### Goals
- Capturar todos os eventos de componentes dinamicos
- Carregar instrucoes PLSAG do banco (ExprCamp, EPerCamp)
- Exibir popup debug mostrando evento + instrucoes
- Preparar infraestrutura para interpretador PLSAG futuro

### Non-Goals (Fase 1)
- Interpretar/executar instrucoes PLSAG
- Implementar comunicacao serial (TsgLeitSeri)
- Implementar eventos de timer (TsgTim)

## Decisions

### 1. Mapeamento de Eventos

| Delphi | JavaScript | Componentes |
|--------|------------|-------------|
| OnExit | blur/focusout | E, N, D, M, L, T |
| OnClick | click | S, BTN, LC |
| OnChange | change | C, T/IT (combos) |
| OnDblClick | dblclick | DBG (grids) |

### 2. Data Attributes nos Componentes

Cada componente recebera:
- `data-sag-field="CodiCamp"` - ID do campo
- `data-sag-type="CompCamp"` - Tipo (E, N, S, etc.)
- `data-sag-required="true/false"` - Obrigatoriedade

### 3. Carregamento de Eventos

O EventService carrega:
- **SISTCAMP**: ExprCamp + EPerCamp para cada campo
- **SISTTABE**: ShowTabe, LancTabe, EGraTabe, AposTabe

### 4. Popup Debug (Fase 1)

Notificacao visual exibindo:
- Tipo do evento (OnExit, OnClick, etc.)
- Campo/Formulario envolvido
- Instrucoes PLSAG que seriam executadas
- Auto-remove apos 5 segundos

## Risks / Trade-offs

| Risco | Mitigacao |
|-------|-----------|
| Eventos assincronos (vs Delphi sincrono) | Fila de eventos com processamento sequencial |
| Combos: diferenca VCL (OnClick) vs UniGUI (OnExit) | Usar OnChange unificado |
| Performance com muitos campos | Lazy binding + throttle de eventos |

## Open Questions

- Nenhuma questao pendente para Fase 1
