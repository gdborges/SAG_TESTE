# Capability: PLSAG Client Commands

Comandos PLSAG que são executados diretamente no navegador, sem necessidade de chamada ao backend.

## ADDED Requirements

### Requirement: Field Enable/Disable Commands

O sistema MUST habilitar e desabilitar campos de formulário via comandos CE e CN.

| Comando | Descrição |
|---------|-----------|
| CE-Campo | Habilita campo para edição |
| CN-Campo | Desabilita campo (somente leitura) |
| CED-Campo-Cond | Habilita se condição != 0, desabilita se = 0 |

#### Scenario: Enable field with CE
- **GIVEN** campo "CodiProd" desabilitado no formulário
- **WHEN** executa "CE-CodiProd"
- **THEN** campo fica habilitado (disabled = false)
- **AND** remove classe CSS "disabled"

#### Scenario: Disable field with CN
- **GIVEN** campo "CodiProd" habilitado no formulário
- **WHEN** executa "CN-CodiProd"
- **THEN** campo fica desabilitado (disabled = true)
- **AND** adiciona classe CSS "disabled"

#### Scenario: Conditional enable/disable with CED
- **GIVEN** campo "Email" e condição = 1
- **WHEN** executa "CED-Email---1"
- **THEN** campo fica habilitado

#### Scenario: Conditional disable with CED zero
- **GIVEN** campo "Email" habilitado e condição = 0
- **WHEN** executa "CED-Email---0"
- **THEN** campo fica desabilitado

---

### Requirement: Field Visibility Commands

O sistema MUST mostrar e esconder campos via comandos CM e CT.

| Comando | Descrição |
|---------|-----------|
| CM-Campo | Mostra campo (torna visível) |
| CT-Campo | Tira/esconde campo |
| CEV-Campo-Cond | Habilita E mostra se condição != 0 |

#### Scenario: Show field with CM
- **GIVEN** campo "Descri" escondido (display: none)
- **WHEN** executa "CM-Descri"
- **THEN** campo fica visível (display: '')
- **AND** remove classe CSS "hidden"

#### Scenario: Hide field with CT
- **GIVEN** campo "Descri" visível
- **WHEN** executa "CT-Descri"
- **THEN** campo fica escondido (display: none)
- **AND** adiciona classe CSS "hidden"

#### Scenario: Hide entire field row
- **GIVEN** campo "Descri" com label em container .field-row-single
- **WHEN** executa "CT-Descri"
- **THEN** o container inteiro fica escondido (inclui label)

---

### Requirement: Field Value Commands

O sistema MUST definir valores de campos via comandos CS e CV.

| Comando | Descrição |
|---------|-----------|
| CS-Campo-Valor | Define valor do campo |
| CV-Campo-Valor | Define valor específico |

#### Scenario: Set field value with CS
- **GIVEN** campo "NomeProd" vazio
- **WHEN** executa "CS-NomeProd-Produto Teste"
- **THEN** campo recebe valor "Produto Teste"
- **AND** dispara evento "change" para atualizar bindings

#### Scenario: Set field value with template
- **GIVEN** campo "Total" e variável CALC = 250
- **WHEN** executa "CS-Total---{VA-CALC}"
- **THEN** campo recebe valor "250"

#### Scenario: Set checkbox field
- **GIVEN** campo checkbox "Ativo"
- **WHEN** executa "CS-Ativo----1"
- **THEN** checkbox fica marcado (checked = true)

#### Scenario: Set select field
- **GIVEN** campo select "TipoProd" com opções A, B, C
- **WHEN** executa "CS-TipoProd-B"
- **THEN** opção B fica selecionada

---

### Requirement: Field Focus Command

O sistema MUST mover o foco para campos via comando CF.

| Comando | Descrição |
|---------|-----------|
| CF-Campo | Move foco para o campo |
| CEF-Campo | Habilita E foca o campo |

#### Scenario: Focus field with CF
- **GIVEN** campo "CodiProd" no formulário
- **WHEN** executa "CF-CodiProd"
- **THEN** campo recebe foco (element.focus())

#### Scenario: Enable and focus with CEF
- **GIVEN** campo "CodiProd" desabilitado
- **WHEN** executa "CEF-CodiProd"
- **THEN** campo fica habilitado
- **AND** campo recebe foco

---

### Requirement: Variable Assignment Commands

O sistema MUST gerenciar variáveis PLSAG via comandos VA, VP e PU.

| Comando | Descrição |
|---------|-----------|
| VA-Var-Valor | Atribui valor à variável (sessão) |
| VP-Var-Valor | Atribui valor persistente (sessionStorage) |
| PU-Var-Valor | Limpa variável |

Faixas de variáveis:
- VA-INTE0001 a VA-INTE0020: Inteiros
- VA-FLOA0001 a VA-FLOA0020: Decimais
- VA-TEXT0001 a VA-TEXT0020: Textos
- VA-DATA0001 a VA-DATA0020: Datas

#### Scenario: Assign variable with VA
- **GIVEN** contexto sem variável TOTAL
- **WHEN** executa "VA-TOTAL---100"
- **THEN** context.variables.custom.TOTAL = "100"

#### Scenario: Assign integer variable
- **GIVEN** contexto sem variável INTE0001
- **WHEN** executa "VA-INTE0001-50"
- **THEN** context.variables.integers.INTE0001 = 50

#### Scenario: Assign persistent variable with VP
- **GIVEN** contexto sem variável CACHE
- **WHEN** executa "VP-CACHE---dados"
- **THEN** context.variables.custom.CACHE = "dados"
- **AND** sessionStorage contém "plsag_CACHE"

#### Scenario: Clear variable with PU
- **GIVEN** variável TOTAL = 100 no contexto
- **WHEN** executa "PU-TOTAL"
- **THEN** context.variables.custom.TOTAL é undefined
- **AND** sessionStorage não contém "plsag_TOTAL"

#### Scenario: Variable expression evaluation
- **GIVEN** formData.Quanti = 10, formData.Preco = 25
- **WHEN** executa "VA-TOTAL---{DG-Quanti} * {DG-Preco}"
- **THEN** context.variables.custom.TOTAL = 250

---

### Requirement: Message Commands

O sistema MUST exibir mensagens ao usuário via comandos MA, MC, ME, MI e MP.

| Comando | Descrição |
|---------|-----------|
| MA-ID-Cond | Alerta (se condição = 0) |
| MC-ID-Cond | Confirmação Sim/Não (retorna S ou N) |
| ME-ID-Cond | Erro (para execução) |
| MI-ID-Cond | Informação |
| MP-ID-Texto | Mensagem personalizada (se texto não vazio) |

#### Scenario: Show alert with MA
- **GIVEN** condição = 0 (falso)
- **WHEN** executa "MA-ALERTA--0" com texto "Campo obrigatório!"
- **THEN** exibe modal de alerta com texto
- **AND** aguarda usuário fechar

#### Scenario: Skip alert when condition is true
- **GIVEN** condição = 1 (verdadeiro)
- **WHEN** executa "MA-ALERTA--1"
- **THEN** não exibe alerta (mensagem pulada)

#### Scenario: Show confirm with MC
- **GIVEN** condição = 0
- **WHEN** executa "MC-CONFIRM-0" com texto "Deseja continuar?"
- **THEN** exibe modal de confirmação com botões Sim/Não
- **AND** retorna "S" se clicou Sim, "N" se clicou Não

#### Scenario: Show error with ME and halt execution
- **GIVEN** condição = 0
- **WHEN** executa "ME-ERRO----0" com texto "Erro crítico!"
- **THEN** exibe modal de erro
- **AND** para execução das instruções seguintes

#### Scenario: Show info with MI
- **GIVEN** condição = 0
- **WHEN** executa "MI-INFO----0" com texto "Operação concluída"
- **THEN** exibe modal informativo

#### Scenario: Show custom message with MP
- **GIVEN** resultado de expressão = "Valor: 100"
- **WHEN** executa "MP-MSG-----{VA-RESULTADO}"
- **THEN** exibe mensagem "Valor: 100"

---

### Requirement: Control Flow IF/ELSE/FINA

O sistema MUST executar blocos condicionais via IF/ELSE/FINA.

Estados da máquina:
- NORMAL: executando normalmente
- IN_IF_TRUE: dentro de IF, condição verdadeira
- IN_IF_FALSE: dentro de IF, condição falsa (skip)
- IN_ELSE: dentro de ELSE

#### Scenario: Execute IF block when condition is true
- **GIVEN** instrução "IF-COND----1" (condição verdadeira)
- **WHEN** entra no bloco IF
- **THEN** estado = IN_IF_TRUE
- **AND** executa instruções do bloco

#### Scenario: Skip IF block when condition is false
- **GIVEN** instrução "IF-COND----0" (condição falsa)
- **WHEN** entra no bloco IF
- **THEN** estado = IN_IF_FALSE
- **AND** pula instruções até ELSE ou FINA

#### Scenario: Execute ELSE block when IF was false
- **GIVEN** estado = IN_IF_FALSE
- **WHEN** encontra "ELSE"
- **THEN** estado = IN_ELSE
- **AND** executa instruções do ELSE

#### Scenario: Skip ELSE block when IF was true
- **GIVEN** estado = IN_IF_TRUE
- **WHEN** encontra "ELSE"
- **THEN** estado = IN_IF_FALSE (skip ELSE)

#### Scenario: Return to NORMAL on FINA
- **GIVEN** qualquer estado IF
- **WHEN** encontra "FINA"
- **THEN** estado = NORMAL (restaura)

#### Scenario: Nested IF blocks
- **GIVEN** IF aninhado dentro de outro IF
- **WHEN** executa bloco aninhado
- **THEN** usa pilha de estados para gerenciar aninhamento
- **AND** FINA interno não afeta IF externo

---

### Requirement: Control Flow WH Loop

O sistema MUST executar loops via WH/FINH.

#### Scenario: Execute WH loop with query results
- **GIVEN** WH-LOOP com query que retorna 3 registros
- **WHEN** executa o loop
- **THEN** executa bloco 3 vezes
- **AND** cada iteração tem acesso ao registro atual

#### Scenario: Break WH loop with PA
- **GIVEN** WH-LOOP em execução
- **WHEN** encontra "PA-12345678-0" (condição falsa)
- **THEN** sai do loop imediatamente

#### Scenario: Empty query results
- **GIVEN** WH-LOOP com query que retorna 0 registros
- **WHEN** executa o loop
- **THEN** pula bloco inteiro até FINH

---

### Requirement: EX Commands Client-Side

O sistema MUST executar comandos EX que não requerem backend.

#### Scenario: EX-FECHFORM close form
- **GIVEN** formulário aberto
- **WHEN** executa "EX-FECHFORM"
- **THEN** tenta window.close()
- **AND** fallback para history.back() se bloqueado

#### Scenario: EX-LIMPAFOR clear form
- **GIVEN** formulário com dados preenchidos
- **WHEN** executa "EX-LIMPAFOR"
- **THEN** executa form.reset()
- **AND** limpa todos os campos

#### Scenario: EX-ATUAFORM refresh form
- **GIVEN** formulário em exibição
- **WHEN** executa "EX-ATUAFORM"
- **THEN** executa window.location.reload()

#### Scenario: EX-MOSTRABT show button
- **GIVEN** botão "btnSalvar" escondido
- **WHEN** executa "EX-MOSTRABT-btnSalvar"
- **THEN** botão fica visível

#### Scenario: EX-ESCONDBT hide button
- **GIVEN** botão "btnSalvar" visível
- **WHEN** executa "EX-ESCONDBT-btnSalvar"
- **THEN** botão fica escondido

#### Scenario: EX-HABILIBT enable button
- **GIVEN** botão "btnSalvar" desabilitado
- **WHEN** executa "EX-HABILIBT-btnSalvar"
- **THEN** botão fica habilitado

#### Scenario: EX-DESABIBT disable button
- **GIVEN** botão "btnSalvar" habilitado
- **WHEN** executa "EX-DESABIBT-btnSalvar"
- **THEN** botão fica desabilitado

---

### Requirement: Unsupported Command Handling

O sistema MUST tratar graciosamente comandos não suportados.

#### Scenario: Log warning for unsupported command
- **GIVEN** comando "EX-LEITSER-" (porta serial, não suportado)
- **WHEN** executor tenta processar
- **THEN** loga warning "[PLSAG] Comando não suportado: EX-LEITSER"
- **AND** emite evento customizado "sag:unsupported-command"
- **AND** continua execução das próximas instruções

#### Scenario: Report unsupported command in result
- **GIVEN** lista de instruções com comando não suportado
- **WHEN** execução completa
- **THEN** resultado inclui lista de comandos não suportados encontrados
