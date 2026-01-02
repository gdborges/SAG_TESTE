# Spec: movement-events

## ADDED Requirements

### Requirement: Movement Event Loading
The system SHALL load movement-specific events from SISTCAMP. All events related to CRUD operations MUST be loaded.

#### Scenario: Eventos carregados
- **WHEN** EventService.GetMovementEventsAsync(movementTableId) e chamado
- **THEN** retorna eventos AnteIAE_Movi, AnteIncl, AnteAlte, AnteExcl, DepoIAE_Movi, DepoIncl, DepoAlte, DepoExcl

#### Scenario: Evento AtuaGrid
- **WHEN** movimento e carregado
- **THEN** carrega evento AtuaGrid_{CodiTabe}

#### Scenario: Evento ShowPai_Filh
- **WHEN** movimento possui sub-movimentos
- **THEN** carrega evento ShowPai_Filh_{CodiTabe}

### Requirement: Before Events (Ante)
The system SHALL execute "Ante" events before CRUD operations. Events MUST be executed in the correct order.

#### Scenario: AnteIAE_Movi
- **WHEN** qualquer operacao CRUD e iniciada
- **THEN** executa AnteIAE_Movi_{CodiTabe} primeiro

#### Scenario: AnteIncl
- **WHEN** insert e iniciado
- **THEN** executa AnteIncl_{CodiTabe} apos AnteIAE_Movi

#### Scenario: AnteAlte
- **WHEN** update e iniciado
- **THEN** executa AnteAlte_{CodiTabe} apos AnteIAE_Movi

#### Scenario: AnteExcl
- **WHEN** delete e iniciado
- **THEN** executa AnteExcl_{CodiTabe} apos AnteIAE_Movi

### Requirement: Event Blocking
The system SHALL block CRUD operation if "Ante" event returns false. The system MUST display message when operation is blocked.

#### Scenario: Evento bloqueia operacao
- **WHEN** evento Ante retorna false ou executa ABORT
- **THEN** operacao CRUD nao e executada

#### Scenario: Mensagem de bloqueio
- **WHEN** operacao e bloqueada
- **THEN** exibe mensagem definida no evento (comando PG)

### Requirement: After Events (Depo)
The system SHALL execute "Depo" events after successful CRUD operations. Events MUST be executed in the correct order.

#### Scenario: DepoIAE_Movi
- **WHEN** qualquer operacao CRUD e concluida com sucesso
- **THEN** executa DepoIAE_Movi_{CodiTabe} primeiro

#### Scenario: DepoIncl
- **WHEN** insert e concluido
- **THEN** executa DepoIncl_{CodiTabe} apos DepoIAE_Movi

#### Scenario: DepoAlte
- **WHEN** update e concluido
- **THEN** executa DepoAlte_{CodiTabe} apos DepoIAE_Movi

#### Scenario: DepoExcl
- **WHEN** delete e concluido
- **THEN** executa DepoExcl_{CodiTabe} apos DepoIAE_Movi

### Requirement: Grid Refresh Event
The system SHALL execute AtuaGrid event after updating movement grid. Event MUST be executed both after CRUD and on initial load.

#### Scenario: Apos CRUD
- **WHEN** grid e recarregado apos operacao CRUD
- **THEN** executa AtuaGrid_{CodiTabe}

#### Scenario: Apos load inicial
- **WHEN** grid e carregado pela primeira vez
- **THEN** executa AtuaGrid_{CodiTabe}

### Requirement: Form Open Event
The system SHALL execute ShowPai_Filh event when opening movement modal with sub-movements.

#### Scenario: Modal aberto
- **WHEN** modal de edicao e aberto
- **THEN** executa ShowPai_Filh_{CodiTabe}

### Requirement: JavaScript Event Integration
The system SHALL expose JavaScript functions to trigger movement events. Functions MUST integrate with the PLSAG interpreter.

#### Scenario: fireMovementEvent
- **WHEN** sag-events.js e carregado
- **THEN** expoe fireMovementEvent(eventType, tableId, data)

#### Scenario: Integracao com PLSAG
- **WHEN** evento e disparado
- **THEN** instrucoes sao executadas via plsag-interpreter.js

### Requirement: Event Flow Order
The system SHALL guarantee correct event execution order. The flow MUST follow pattern Ante -> Operation -> Depo -> AtuaGrid.

#### Scenario: Fluxo insert
- **WHEN** usuario confirma insert
- **THEN** executa: AnteIAE_Movi -> AnteIncl -> [INSERT] -> DepoIAE_Movi -> DepoIncl -> AtuaGrid

#### Scenario: Fluxo update
- **WHEN** usuario confirma update
- **THEN** executa: AnteIAE_Movi -> AnteAlte -> [UPDATE] -> DepoIAE_Movi -> DepoAlte -> AtuaGrid

#### Scenario: Fluxo delete
- **WHEN** usuario confirma delete
- **THEN** executa: AnteIAE_Movi -> AnteExcl -> [DELETE] -> DepoIAE_Movi -> DepoExcl -> AtuaGrid
