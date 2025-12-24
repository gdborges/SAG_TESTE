## ADDED Requirements

### Requirement: Field Event Capture
O sistema MUST capturar eventos de componentes dinamicos baseado no tipo de componente (CompCamp).

#### Scenario: Text input OnExit
- **WHEN** usuario sai de um campo tipo E (texto)
- **THEN** o sistema dispara evento OnExit com CodiCamp e valor atual

#### Scenario: Checkbox OnClick
- **WHEN** usuario clica em checkbox (tipo S)
- **THEN** o sistema dispara evento OnClick com CodiCamp e estado (0/1)

#### Scenario: ComboBox OnChange
- **WHEN** usuario seleciona opcao em combo (tipo C, T, IT)
- **THEN** o sistema dispara evento OnChange com CodiCamp e valor selecionado

#### Scenario: Button OnClick
- **WHEN** usuario clica em botao (tipo BTN)
- **THEN** o sistema dispara evento OnClick com CodiCamp

---

### Requirement: Form Lifecycle Events
O sistema MUST disparar eventos nos momentos do ciclo de vida do formulario.

#### Scenario: ShowTabe on form display
- **WHEN** formulario e exibido (apos DOMContentLoaded)
- **THEN** o sistema dispara evento ShowTabe com CodiTabe

#### Scenario: LancTabe before save
- **WHEN** usuario clica em Salvar (antes de enviar)
- **THEN** o sistema dispara evento LancTabe

#### Scenario: EGraTabe after save
- **WHEN** gravacao e concluida com sucesso
- **THEN** o sistema dispara evento EGraTabe

#### Scenario: AposTabe final
- **WHEN** processamento pos-gravacao e concluido
- **THEN** o sistema dispara evento AposTabe

---

### Requirement: Event Data Loading
O sistema MUST carregar instrucoes PLSAG das tabelas de configuracao.

#### Scenario: Load field events from SISTCAMP
- **WHEN** formulario e renderizado
- **THEN** sistema carrega ExprCamp + EPerCamp para cada campo

#### Scenario: Load form events from SISTTABE
- **WHEN** formulario e renderizado
- **THEN** sistema carrega ShowTabe, LancTabe, EGraTabe, AposTabe

#### Scenario: Merge permanent expressions
- **WHEN** campo possui EPerCamp
- **THEN** sistema mescla com ExprCamp (ExprCamp primeiro, depois EPerCamp)

---

### Requirement: Event Debug Display (Phase 1)
O sistema MUST exibir popup de debug quando eventos disparam.

#### Scenario: Show popup with event details
- **WHEN** evento e disparado e campo possui instrucoes
- **THEN** popup exibe: tipo evento, nome campo, valor, instrucoes PLSAG

#### Scenario: Auto-dismiss popup
- **WHEN** popup e exibido
- **THEN** popup desaparece automaticamente apos 5 segundos

#### Scenario: Manual close popup
- **WHEN** usuario clica no X do popup
- **THEN** popup e fechado imediatamente
