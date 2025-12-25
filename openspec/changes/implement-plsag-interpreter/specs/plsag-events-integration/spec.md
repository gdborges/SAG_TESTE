# Capability: PLSAG Events Integration

Integração do interpretador PLSAG com o sistema de eventos já implementado em sag-events.js (Fase 1).

## ADDED Requirements

### Requirement: Field Event Integration

O sistema MUST executar instruções PLSAG quando eventos de campo são disparados.

Modificação em sag-events.js:fireFieldEvent() (linhas 185-186):

```javascript
// ANTES (Fase 1 - apenas log)
// TODO: Fase 2 - Executar instruções PLSAG

// DEPOIS (Fase 2 - execução real)
if (instructions && instructions.trim()) {
    const result = await PlsagInterpreter.execute(instructions, {
        type: 'field',
        fieldName: fieldName,
        codiCamp: codiCamp,
        fieldValue: eventInfo.value,
        eventType: eventType
    });
}
```

#### Scenario: Execute OnExit instructions
- **GIVEN** campo CodiProd com evento OnExit configurado
- **WHEN** usuário sai do campo (blur)
- **THEN** chama SagEvents.fireFieldEvent()
- **AND** PlsagInterpreter.execute() recebe instruções OnExit
- **AND** contexto inclui valor atual do campo

#### Scenario: Execute OnClick instructions
- **GIVEN** botão com evento OnClick configurado
- **WHEN** usuário clica no botão
- **THEN** executa instruções OnClick

#### Scenario: Execute OnChange instructions
- **GIVEN** campo select com evento OnChange
- **WHEN** valor muda
- **THEN** executa instruções OnChange

#### Scenario: Execute OnDblClick instructions
- **GIVEN** campo com evento OnDblClick
- **WHEN** usuário dá duplo clique
- **THEN** executa instruções OnDblClick

#### Scenario: Handle execution error in field event
- **GIVEN** instruções com erro
- **WHEN** PlsagInterpreter.execute() falha
- **THEN** loga erro no console
- **AND** emite evento "sag:plsag-error"
- **AND** não propaga erro para UI

---

### Requirement: Form Event Integration

O sistema MUST executar instruções PLSAG quando eventos de formulário são disparados.

Modificação em sag-events.js:fireFormEvent() (linhas 206-207):

```javascript
// ANTES (Fase 1 - apenas log)
// TODO: Fase 2 - Executar instruções PLSAG

// DEPOIS (Fase 2 - execução real)
if (instructions && instructions.trim()) {
    const result = await PlsagInterpreter.execute(instructions, {
        type: 'form',
        eventType: eventType,
        formData: collectFormData()
    });
}
```

#### Scenario: Execute AnteCria instructions
- **GIVEN** formulário com evento AnteCria configurado
- **WHEN** formulário inicia renderização
- **THEN** executa instruções AnteCria
- **AND** pode modificar variáveis antes dos campos existirem

#### Scenario: Execute DepoCria instructions
- **GIVEN** formulário com evento DepoCria configurado
- **WHEN** campos foram criados
- **THEN** executa instruções DepoCria
- **AND** pode manipular campos já existentes

#### Scenario: Execute ShowTabe instructions
- **GIVEN** formulário com evento ShowTabe configurado
- **WHEN** formulário está visível
- **THEN** executa instruções ShowTabe
- **AND** tipicamente inicializa valores e estados

#### Scenario: Execute DepoShow instructions
- **GIVEN** formulário com evento DepoShow configurado
- **WHEN** após ShowTabe
- **THEN** executa instruções DepoShow

#### Scenario: Execute LancTabe instructions
- **GIVEN** formulário com evento LancTabe configurado
- **WHEN** usuário clica em Salvar (antes de gravar)
- **THEN** executa instruções LancTabe
- **AND** pode cancelar salvamento se retornar erro

#### Scenario: Execute EGraTabe instructions
- **GIVEN** formulário com evento EGraTabe configurado
- **WHEN** salvamento concluído com sucesso
- **THEN** executa instruções EGraTabe

#### Scenario: Execute AposTabe instructions
- **GIVEN** formulário com evento AposTabe configurado
- **WHEN** formulário é fechado
- **THEN** executa instruções AposTabe

#### Scenario: Execute AtuaGrid instructions
- **GIVEN** formulário com evento AtuaGrid configurado
- **WHEN** grid precisa ser atualizado
- **THEN** executa instruções AtuaGrid
- **AND** recarrega dados da grid de consulta

---

### Requirement: Context Initialization

O sistema MUST inicializar o contexto de execução com dados do formulário.

#### Scenario: Collect form data for context
- **GIVEN** formulário com campos preenchidos
- **WHEN** evento é disparado
- **THEN** collectFormData() retorna objeto com todos os valores
- **AND** campos indexados por nome (data-sag-nomecamp)

#### Scenario: Include form metadata in context
- **GIVEN** formulário com CodiTabe = 120
- **WHEN** contexto é inicializado
- **THEN** context.system.CODITABE = 120
- **AND** context.tableName = nome da tabela

#### Scenario: Detect form mode
- **GIVEN** formulário em modo inserção
- **WHEN** contexto é inicializado
- **THEN** context.system.INSERIND = true
- **AND** context.system.ALTERIND = false

#### Scenario: Include user session data
- **GIVEN** usuário logado com código 123
- **WHEN** contexto é inicializado
- **THEN** context.system.CODIUSUA = 123
- **AND** context.system.CODIPESS = pessoa do usuário

---

### Requirement: Async Event Handling

O sistema MUST suportar execução assíncrona sem bloquear UI.

#### Scenario: Show loading indicator during execution
- **GIVEN** instruções com queries (QY)
- **WHEN** execução inicia
- **THEN** pode mostrar indicador de loading
- **AND** UI permanece responsiva

#### Scenario: Cancel execution on form close
- **GIVEN** execução em andamento
- **WHEN** usuário fecha formulário
- **THEN** aborta execução pendente
- **AND** limpa contexto

#### Scenario: Sequential execution prevents race conditions
- **GIVEN** múltiplos eventos disparados rapidamente
- **WHEN** eventos entram na fila
- **THEN** executa um por vez em ordem
- **AND** próximo evento usa contexto atualizado

---

### Requirement: Debug Integration

O sistema MUST integrar com o sistema de debug existente.

O debug popup já implementado na Fase 1 deve mostrar:
- Instruções sendo executadas
- Resultados de cada instrução
- Valores de variáveis
- Erros encontrados

#### Scenario: Log execution start to debug
- **GIVEN** debug popup visível
- **WHEN** PlsagInterpreter.execute() inicia
- **THEN** loga "Executando PLSAG para {eventType}"
- **AND** mostra instruções a executar

#### Scenario: Log each instruction execution
- **GIVEN** debug mode ativo
- **WHEN** cada instrução é processada
- **THEN** loga "Instrução: {prefix}-{identifier}"
- **AND** mostra resultado/erro

#### Scenario: Log variable changes
- **GIVEN** debug mode ativo
- **WHEN** variável é criada/modificada
- **THEN** loga "VA-{nome} = {valor}"

#### Scenario: Log query results
- **GIVEN** debug mode ativo
- **WHEN** query QY/QN é executada
- **THEN** loga SQL executado
- **AND** mostra resultado ou erro

---

### Requirement: Script Loading Order

O sistema MUST carregar scripts na ordem correta.

Em _Layout.cshtml ou Render.cshtml:

```html
<!-- 1. Comandos (não depende de nada) -->
<script src="~/js/plsag-commands.js"></script>

<!-- 2. Interpretador (depende de commands) -->
<script src="~/js/plsag-interpreter.js"></script>

<!-- 3. Eventos (depende de interpreter) -->
<script src="~/js/sag-events.js"></script>
```

#### Scenario: Verify PlsagCommands available
- **GIVEN** plsag-commands.js carregado
- **WHEN** window.PlsagCommands é acessado
- **THEN** objeto existe com métodos field, variable, message

#### Scenario: Verify PlsagInterpreter available
- **GIVEN** plsag-interpreter.js carregado após commands
- **WHEN** window.PlsagInterpreter é acessado
- **THEN** objeto existe com método execute

#### Scenario: Verify SagEvents uses interpreter
- **GIVEN** todos os scripts carregados
- **WHEN** SagEvents.init() é chamado
- **THEN** PlsagInterpreter está disponível
- **AND** eventos disparam execução

---

### Requirement: Error Recovery

O sistema MUST recuperar de erros sem quebrar o formulário.

#### Scenario: Continue after instruction error
- **GIVEN** instrução com erro de sintaxe
- **WHEN** executor encontra erro
- **THEN** loga erro
- **AND** continua com próxima instrução (exceto ME)

#### Scenario: Recover from API timeout
- **GIVEN** API demora mais que timeout
- **WHEN** timeout ocorre
- **THEN** loga warning
- **AND** continua execução

#### Scenario: Handle missing field gracefully
- **GIVEN** instrução referencia campo inexistente
- **WHEN** executor processa CE-CampoXXX
- **THEN** loga warning "Campo não encontrado: CampoXXX"
- **AND** continua execução

#### Scenario: Preserve form state on error
- **GIVEN** erro durante execução
- **WHEN** execução falha
- **THEN** formulário permanece em estado válido
- **AND** dados não são corrompidos
