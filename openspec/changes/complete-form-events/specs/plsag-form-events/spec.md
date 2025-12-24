# PLSAG Form Events

Especificação dos eventos de formulário adicionais do sistema PLSAG.

## ADDED Requirements

### Requirement: DepoShow Event
O sistema MUST disparar o evento DepoShow após o ShowTabe durante a inicialização do formulário.

#### Scenario: DepoShow dispara após ShowTabe
- **Given**: Um formulário com instruções DepoShow configuradas no SISTCAMP
- **When**: O formulário é carregado e inicializado
- **Then**: O evento DepoShow é disparado após ShowTabe
- **And**: As instruções são logadas no console (Fase 1)

### Requirement: AtuaGrid Event
O sistema MUST fornecer um mecanismo para disparar o evento AtuaGrid que atualiza grids de movimento.

#### Scenario: AtuaGrid dispara via refreshGrid
- **Given**: Um formulário com instruções AtuaGrid configuradas no SISTCAMP
- **When**: A função SagEvents.refreshGrid() é chamada
- **Then**: O evento AtuaGrid é disparado
- **And**: As instruções são logadas no console (Fase 1)

#### Scenario: AtuaGrid dispara após salvar
- **Given**: Um formulário com instruções AtuaGrid configuradas
- **When**: O usuário salva um registro com sucesso
- **Then**: O evento AtuaGrid é disparado automaticamente

### Requirement: AposTabe Activation
O sistema MUST disparar o evento AposTabe nos momentos apropriados do ciclo de vida.

#### Scenario: AposTabe dispara após salvar com sucesso
- **Given**: Um formulário com instruções AposTabe configuradas no SISTTABE
- **When**: O usuário salva um registro com sucesso
- **Then**: O evento AposTabe é disparado após EGraTabe
- **And**: As instruções são logadas no console (Fase 1)

#### Scenario: AposTabe dispara ao voltar
- **Given**: Um formulário com instruções AposTabe configuradas
- **When**: O usuário clica no botão Voltar
- **Then**: O evento AposTabe é disparado antes de sair

## MODIFIED Requirements

### Requirement: Form Event Loading
O EventService MUST carregar os campos especiais DEPOSHOW e ATUAGRID do SISTCAMP.

#### Scenario: Carregar DEPOSHOW do banco
- **Given**: Uma tabela com campo DEPOSHOW configurado no SISTCAMP
- **When**: O EventService carrega eventos do formulário
- **Then**: As instruções de DEPOSHOW são incluídas em FormEventData.DepoShowInstructions

#### Scenario: Carregar ATUAGRID do banco
- **Given**: Uma tabela com campo ATUAGRID configurado no SISTCAMP
- **When**: O EventService carrega eventos do formulário
- **Then**: As instruções de ATUAGRID são incluídas em FormEventData.AtuaGridInstructions
