# Spec: movement-rendering

## ADDED Requirements

### Requirement: Movement Section Container
The system SHALL render a visual container for each movement table. Each container MUST have identification attributes.

#### Scenario: Container basico
- **WHEN** formulario possui MovementTables
- **THEN** renderiza _MovementSection.cshtml para cada movimento

#### Scenario: Atributos do container
- **WHEN** container e renderizado
- **THEN** possui data-movement="CodiTabe" e data-parent="CabeTabe"

### Requirement: SERITABE Layout Logic
The system SHALL respect SERITABE logic for movement positioning. Values greater than 50 MUST render inline, values 50 or less MUST create separate tabs.

#### Scenario: SERITABE maior que 50
- **WHEN** movimento possui SeriTabe > 50
- **THEN** renderiza inline na mesma guia do cabecalho (abaixo dos campos)

#### Scenario: SERITABE menor ou igual a 50
- **WHEN** movimento possui SeriTabe <= 50
- **THEN** cria nova tab no formulario para o movimento

#### Scenario: Multiplas tabs de movimento
- **WHEN** formulario possui movimentos 125 (SeriTabe=30) e 126 (SeriTabe=40)
- **THEN** cria tabs separadas para cada movimento

### Requirement: Movement Grid
The system SHALL render an HTML table with movement data. The table MUST include CRUD buttons and support row selection.

#### Scenario: Grid basico
- **WHEN** _MovementGrid.cshtml e renderizado
- **THEN** exibe tabela com colunas configuradas em GRCOTABE

#### Scenario: Botoes CRUD
- **WHEN** grid e renderizado
- **THEN** possui botoes Novo, Alterar, Excluir (visibilidade configuravel)

#### Scenario: Selecao de linha
- **WHEN** usuario clica em uma linha do grid
- **THEN** linha e destacada e dados sao carregados no contexto

#### Scenario: Duplo clique
- **WHEN** usuario faz duplo clique em uma linha
- **THEN** abre modal de edicao para o registro

### Requirement: Movement Modal
The system SHALL render a non-blocking modal for record editing. The modal MUST NOT block interaction with other parts of the system.

#### Scenario: Modal nao-bloqueante
- **WHEN** modal e aberto
- **THEN** usa backdrop: false permitindo interacao com o sistema

#### Scenario: Modal insert
- **WHEN** usuario clica em Novo
- **THEN** abre modal vazio com data-mode="insert"

#### Scenario: Modal edit
- **WHEN** usuario clica em Alterar (ou duplo-clique)
- **THEN** abre modal com dados do registro e data-mode="edit"

#### Scenario: Campos do modal
- **WHEN** modal e renderizado
- **THEN** exibe campos do SISTCAMP para CodiTabe do movimento

### Requirement: Sub-Movement Rendering
The system SHALL support rendering of sub-movements (level 2) inside the level 1 movement modal.

#### Scenario: Modal com sub-movimento
- **WHEN** movimento possui Children (sub-movimentos)
- **THEN** modal exibe grid do sub-movimento na area inferior

#### Scenario: CRUD do sub-movimento
- **WHEN** usuario opera no sub-movimento dentro do modal
- **THEN** botoes CRUD funcionam para o nivel 2

### Requirement: Responsive Grid
The system SHALL render a responsive grid that adapts to available space. The grid MUST maintain usability across different screen sizes.

#### Scenario: Grid com scroll
- **WHEN** movimento possui muitos registros
- **THEN** grid exibe scroll vertical mantendo cabecalho fixo

#### Scenario: Colunas responsivas
- **WHEN** tela e pequena
- **THEN** colunas menos importantes sao ocultadas
