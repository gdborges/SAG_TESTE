# Spec: movement-integration

## ADDED Requirements

### Requirement: DM Template Context
The system SHALL add movementData (DM) context in plsag-interpreter.js for level 1 movement templates. The context MUST be updated when selecting rows in the grid.

#### Scenario: Template DM basico
- **WHEN** instrucao PLSAG contem {DM-CODIPROD}
- **THEN** substitui pelo valor do campo CODIPROD do movimento atual

#### Scenario: Contexto atualizado
- **WHEN** usuario seleciona linha diferente no grid
- **THEN** contexto movementData e atualizado com novos valores

#### Scenario: Contexto no modal
- **WHEN** modal de edicao e aberto
- **THEN** contexto movementData reflete campos do modal

### Requirement: D2 Template Context
The system SHALL add subMovementData (D2) context in plsag-interpreter.js for level 2 sub-movement templates. The context MUST work analogously to DM.

#### Scenario: Template D2 basico
- **WHEN** instrucao PLSAG contem {D2-QTDEPROD}
- **THEN** substitui pelo valor do campo QTDEPROD do sub-movimento atual

#### Scenario: Contexto D2 no modal
- **WHEN** sub-movimento e selecionado dentro do modal
- **THEN** contexto subMovementData e atualizado

### Requirement: Component Mapping
The system SHALL map Delphi component names to CSS web selectors. The mapping MUST cover grids, buttons and fields.

#### Scenario: DBG para grid
- **WHEN** instrucao refere DBG125
- **THEN** mapeia para [data-movement="125"] table

#### Scenario: BTNNOV para botao
- **WHEN** instrucao refere BTNNOV125
- **THEN** mapeia para [data-movement="125"] .btn-novo

#### Scenario: ED para campo
- **WHEN** instrucao refere ED125_CODIPROD
- **THEN** mapeia para [data-movement="125"] [name="CODIPROD"]

### Requirement: BuscaComponente Implementation
The system SHALL implement BuscaComponente via document.querySelector to locate components by Delphi name.

#### Scenario: Busca por nome Delphi
- **WHEN** BuscaComponente("DBG125") e chamado
- **THEN** retorna elemento DOM correspondente

#### Scenario: Componente nao encontrado
- **WHEN** componente nao existe
- **THEN** retorna null (sem erro)

### Requirement: Component State Control
The system SHALL support ED commands to control movement component state. Commands MUST affect enabled, visible and readonly properties.

#### Scenario: Desabilitar grid
- **WHEN** ED,DBG125,ENABLED,0 e executado
- **THEN** grid do movimento 125 e desabilitado

#### Scenario: Ocultar botao
- **WHEN** ED,BTNNOV125,VISIBLE,0 e executado
- **THEN** botao Novo do movimento 125 e ocultado

#### Scenario: Readonly campo
- **WHEN** ED,ED125_CODIPROD,READONLY,1 e executado
- **THEN** campo CODIPROD do movimento 125 fica readonly

### Requirement: Header-Movement Sync
The system SHALL synchronize header state with movements. Movement buttons MUST respect header mode.

#### Scenario: Modo visualizacao
- **WHEN** cabecalho esta em data-mode="view"
- **THEN** botoes de CRUD do movimento sao desabilitados

#### Scenario: Modo edicao
- **WHEN** cabecalho esta em data-mode="edit" ou "insert"
- **THEN** botoes de CRUD do movimento sao habilitados

### Requirement: Insert Mode API
The system SHALL expose API to check and set operation mode. The API MUST allow events to query current state.

#### Scenario: setInsertMode
- **WHEN** insert e iniciado
- **THEN** plsagInterpreter.setInsertMode(true) e chamado

#### Scenario: isInsertMode
- **WHEN** evento verifica modo
- **THEN** plsagInterpreter.isInsertMode() retorna estado correto

### Requirement: Movement Manager JavaScript
The system SHALL expose MovementManager for browser movement management. The manager MUST centralize all movement operations.

#### Scenario: initMovements
- **WHEN** pagina e carregada
- **THEN** MovementManager.initMovements() inicializa todos os movimentos

#### Scenario: getMovementContext
- **WHEN** operacao precisa do contexto
- **THEN** MovementManager.getMovementContext(tableId) retorna dados atuais

#### Scenario: refreshMovementGrid
- **WHEN** dados mudam
- **THEN** MovementManager.refreshMovementGrid(tableId) recarrega grid

### Requirement: Form Data Collection
The system SHALL collect modal data for CRUD operations. The system MUST validate and format values according to field type.

#### Scenario: Coletar campos
- **WHEN** usuario confirma modal
- **THEN** coleta todos os campos com name do movimento

#### Scenario: Validar obrigatorios
- **WHEN** campos obrigatorios estao vazios
- **THEN** bloqueia submit e destaca campos

#### Scenario: Formatar valores
- **WHEN** dados sao coletados
- **THEN** formata conforme TipoCamp (data, numero, etc)
