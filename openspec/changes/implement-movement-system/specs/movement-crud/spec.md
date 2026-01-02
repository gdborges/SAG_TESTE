# Spec: movement-crud

## ADDED Requirements

### Requirement: Movement Service Interface
The system SHALL expose IMovementService for CRUD operations on movement tables. The interface MUST define methods for all basic operations.

#### Scenario: Interface methods
- **WHEN** IMovementService e definido
- **THEN** possui GetMovementDataAsync, InsertMovementAsync, UpdateMovementAsync, DeleteMovementAsync

### Requirement: Movement Data Loading
The system SHALL load movement data filtered by parent record. The data MUST be ordered according to configuration.

#### Scenario: Carregar dados
- **WHEN** GetMovementDataAsync(parentId, movementTableId) e chamado
- **THEN** retorna registros onde FK = parentId

#### Scenario: Ordenacao
- **WHEN** dados sao carregados
- **THEN** respeitam ordem definida em GRIDTABE ou SISTCAMP

### Requirement: Movement Insert
The system SHALL allow inserting new movement records. The system MUST automatically fill FK and use correct PK strategy.

#### Scenario: Insert basico
- **WHEN** InsertMovementAsync e chamado com dados validos
- **THEN** insere registro na tabela de movimento

#### Scenario: FK automatica
- **WHEN** insert e realizado
- **THEN** FK do pai e preenchida automaticamente

#### Scenario: PK Strategy
- **WHEN** insert e realizado
- **THEN** usa estrategia de PK correta (Identity/MaxPlusOne/UserProvided)

### Requirement: Movement Update
The system SHALL allow updating existing movement records. The system MUST validate required fields before persisting.

#### Scenario: Update basico
- **WHEN** UpdateMovementAsync e chamado com dados validos
- **THEN** atualiza registro identificado pela PK

#### Scenario: Validacao de campos
- **WHEN** update e realizado
- **THEN** valida campos obrigatorios antes de persistir

### Requirement: Movement Delete
The system SHALL allow deleting movement records. The system MUST delete sub-movements in cascade when necessary.

#### Scenario: Delete basico
- **WHEN** DeleteMovementAsync e chamado
- **THEN** exclui registro identificado pela PK

#### Scenario: Delete em cascata
- **WHEN** movimento possui sub-movimentos
- **THEN** exclui sub-movimentos antes do movimento pai

### Requirement: Movement API Controller
The system SHALL expose MovementController with REST endpoints for movement operations. Each CRUD operation MUST have its corresponding endpoint.

#### Scenario: GET dados
- **WHEN** GET /api/movement/{parentId}/{tableId}/data
- **THEN** retorna lista de registros do movimento

#### Scenario: GET form
- **WHEN** GET /api/movement/{tableId}/form/{recordId}
- **THEN** retorna dados para edicao do registro

#### Scenario: POST insert
- **WHEN** POST /api/movement/{tableId} com body JSON
- **THEN** insere registro e retorna ID criado

#### Scenario: PUT update
- **WHEN** PUT /api/movement/{tableId}/{recordId} com body JSON
- **THEN** atualiza registro

#### Scenario: DELETE
- **WHEN** DELETE /api/movement/{tableId}/{recordId}
- **THEN** exclui registro

### Requirement: Transaction Per Operation
The system SHALL execute each CRUD operation in an independent transaction. Transactions MUST NOT be shared between header and movements.

#### Scenario: Transacao isolada
- **WHEN** operacao CRUD e executada
- **THEN** usa transacao propria (nao compartilhada com cabecalho)

#### Scenario: Rollback
- **WHEN** operacao falha
- **THEN** transacao e revertida sem afetar outras operacoes

### Requirement: Security Validation
The system SHALL validate that movement table belongs to the current form. Operations on unrelated tables MUST be rejected.

#### Scenario: Tabela valida
- **WHEN** operacao e solicitada para movimento do formulario
- **THEN** operacao e permitida

#### Scenario: Tabela invalida
- **WHEN** operacao e solicitada para tabela nao relacionada
- **THEN** retorna erro 403 Forbidden
