# Tasks: Implement PLSAG Interpreter

## 1. Core do Interpretador (plsag-interpreter.js)

### 1.1 Parser
- [x] 1.1.1 Implementar funcao `parseInstruction(raw)` com regra dos 8 caracteres
- [x] 1.1.2 Implementar funcao `tokenize(instructions)` para separar por ";"
- [x] 1.1.3 Tratar instrucoes multi-linha (mensagens MA, MC, ME, MI)
- [ ] 1.1.4 Adicionar testes unitarios do parser

### 1.2 Template Substitution
- [x] 1.2.1 Implementar funcao `substituteTemplates(text, context)`
- [x] 1.2.2 Suportar templates DG, DM, D2, D3 (dados do formulario)
- [x] 1.2.3 Suportar templates VA, VP, PU (variaveis)
- [x] 1.2.4 Suportar templates QY (resultados de query)
- [ ] 1.2.5 Adicionar testes unitarios de substituicao

### 1.3 Execution Context
- [x] 1.3.1 Definir estrutura do objeto `ExecutionContext`
- [x] 1.3.2 Implementar inicializacao com dados do formulario
- [x] 1.3.3 Implementar variaveis de sistema (INSERIND, ALTERIND, CODIPESS, etc.)
- [x] 1.3.4 Implementar faixas de variaveis (INTE, FLOA, TEXT, DATA)

### 1.4 Executor
- [x] 1.4.1 Implementar funcao `execute(instructions, eventContext)`
- [x] 1.4.2 Implementar loop de execucao sequencial
- [x] 1.4.3 Suportar operacoes assincronas (async/await)
- [x] 1.4.4 Implementar tratamento de PA (pare)
- [x] 1.4.5 Implementar tratamento de ME (erro que para execucao)

### 1.5 Expression Evaluation
- [x] 1.5.1 Implementar avaliador de expressoes aritmeticas
- [x] 1.5.2 Implementar avaliador de expressoes de comparacao
- [x] 1.5.3 Tratar divisao por zero e erros

## 2. Comandos de Campo (plsag-commands.js - fieldCommands)

- [x] 2.1 Implementar `CE` - Campo Enable (habilita campo)
- [x] 2.2 Implementar `CN` - Campo Disable (desabilita campo)
- [x] 2.3 Implementar `CED` - Conditional Enable/Disable
- [x] 2.4 Implementar `CM` - Campo Mostra (torna visivel)
- [x] 2.5 Implementar `CT` - Campo Tira (esconde)
- [x] 2.6 Implementar `CEV` - Enable and Visible
- [x] 2.7 Implementar `CS` - Campo Set (define valor)
- [x] 2.8 Implementar `CV` - Campo Valor
- [x] 2.9 Implementar `CF` - Campo Foco
- [x] 2.10 Implementar `CEF` - Enable and Focus
- [x] 2.11 Implementar funcao auxiliar `findField(fieldName)`
- [x] 2.12 Implementar funcao auxiliar `findFieldContainer(fieldName)`

## 3. Comandos de Variavel (plsag-commands.js - variableCommands)

- [x] 3.1 Implementar `VA` - Variable Assign
- [x] 3.2 Implementar `VP` - Variable Persistent (com sessionStorage)
- [x] 3.3 Implementar `PU` - Purge (limpa variavel)
- [x] 3.4 Implementar deteccao de faixa (INTE, FLOA, TEXT, DATA)

## 4. Comandos de Mensagem (plsag-commands.js - messageCommands)

- [x] 4.1 Implementar `MA` - Message Alert (exibe alerta)
- [x] 4.2 Implementar `MC` - Message Confirm (Sim/Nao, retorna S ou N)
- [x] 4.3 Implementar `ME` - Message Error (para execucao)
- [x] 4.4 Implementar `MI` - Message Info
- [x] 4.5 Implementar `MP` - Message Prompt (mensagem customizada)
- [x] 4.6 Implementar funcao `showModal(type, message, callback)`

## 5. Controle de Fluxo

### 5.1 IF/ELSE/FINA
- [x] 5.1.1 Implementar maquina de estados (NORMAL, IN_IF_TRUE, IN_IF_FALSE, IN_ELSE)
- [x] 5.1.2 Implementar pilha de estados para IFs aninhados
- [x] 5.1.3 Implementar handler para `IF-INIC`
- [x] 5.1.4 Implementar handler para `ELSE`
- [x] 5.1.5 Implementar handler para `FINA`
- [ ] 5.1.6 Adicionar testes para blocos aninhados

### 5.2 WH Loop
- [x] 5.2.1 Implementar handler para `WH-INIC` (inicia loop com query)
- [x] 5.2.2 Implementar handler para `WH-FINA` (fim do loop)
- [x] 5.2.3 Implementar navegacao pelos registros do loop
- [x] 5.2.4 Suportar PA dentro de loop (break)

## 6. API Backend (PlsagController.cs)

### 6.1 Controller Base
- [x] 6.1.1 Criar PlsagController.cs com injecao de dependencia
- [x] 6.1.2 Configurar rota base `/api/plsag`
- [x] 6.1.3 Implementar logging de requisicoes

### 6.2 Query Endpoint
- [x] 6.2.1 Criar endpoint `POST /api/plsag/query`
- [x] 6.2.2 Implementar execucao de query single-row
- [x] 6.2.3 Implementar execucao de query multi-row
- [x] 6.2.4 Implementar validacao de SQL

### 6.3 Save Endpoint
- [x] 6.3.1 Criar endpoint `POST /api/plsag/save`
- [x] 6.3.2 Implementar INSERT operation
- [x] 6.3.3 Implementar UPDATE operation
- [x] 6.3.4 Implementar DELETE operation
- [x] 6.3.5 Usar queries parametrizadas

### 6.4 Execute Endpoint
- [x] 6.4.1 Criar endpoint `POST /api/plsag/execute`
- [x] 6.4.2 Implementar execucao de SQL direto
- [x] 6.4.3 Implementar execucao de stored procedures
- [x] 6.4.4 Implementar validacoes (CPF, CNPJ, Data, Hora)

### 6.5 Seguranca
- [x] 6.5.1 Implementar `IsValidPlsagQuery()` para bloqueio de comandos perigosos
- [x] 6.5.2 Bloquear DROP, TRUNCATE, ALTER, CREATE
- [x] 6.5.3 Bloquear xp_, sp_ (procedures de sistema)
- [x] 6.5.4 Bloquear comentarios SQL (--, /* */)

## 7. Comandos de Query (Client -> Server)

- [x] 7.1 Implementar `QY` - Query Yes (fetch para API, armazena resultado)
- [x] 7.2 Implementar `QN` - Query N-lines (multi-row)
- [x] 7.3 Implementar `QD` - Query Delete
- [x] 7.4 Implementar `QM` - Query Modify (UPDATE)
- [x] 7.5 Implementar navegacao (ABRE, FECH, PRIM, PROX, ANTE, ULTI)

## 8. Comandos de Gravacao (Client -> Server)

- [x] 8.1 Implementar `DG` - Data Grava (cabecalho, somente INSERT)
- [x] 8.2 Implementar `DDG/DDM/DD2/DD3` - Data Direto (forca gravacao em dataset especifico)
- [x] 8.3 Implementar `DM` - Data Movimento 1
- [x] 8.4 Implementar `D2` - Data Movimento 2
- [x] 8.5 Implementar `D3` - Data Movimento 3

## 9. Comandos EX

### 9.1 Client-side
- [x] 9.1.1 Implementar `EX-FECHFORM` - Fecha formulario
- [x] 9.1.2 Implementar `EX-LIMPAFOR` - Limpa formulario
- [x] 9.1.3 Implementar `EX-ATUAFORM` - Atualiza formulario
- [x] 9.1.4 Implementar `EX-MOSTRABT` - Mostra botao
- [x] 9.1.5 Implementar `EX-ESCONDBT` - Esconde botao
- [x] 9.1.6 Implementar `EX-HABILIBT` - Habilita botao
- [x] 9.1.7 Implementar `EX-DESABIBT` - Desabilita botao

### 9.2 Server-side
- [x] 9.2.1 Implementar `EX-GRAVAFOR` - Grava formulario
- [x] 9.2.2 Implementar `EX-SQL-----` - Executa SQL
- [x] 9.2.3 Implementar `EX-EXECPROC` - Executa stored procedure
- [x] 9.2.4 Implementar `EX-TRANSINI/TRANSCOM/TRANSROL` - Transacoes (stub)
- [x] 9.2.5 Implementar `EX-VALICPF_` - Valida CPF
- [x] 9.2.6 Implementar `EX-VALICNPJ` - Valida CNPJ
- [x] 9.2.7 Implementar `EX-IMPRIMIR/EXPOPDF/EXPOEXCE` - Exportacoes (stub)

### 9.3 Navegacao
- [x] 9.3.1 Implementar `EX-PROXREGI` - Proximo registro
- [x] 9.3.2 Implementar `EX-ANTEREGI` - Registro anterior
- [x] 9.3.3 Implementar `EX-PRIMREGI` - Primeiro registro
- [x] 9.3.4 Implementar `EX-ULTIREGI` - Ultimo registro
- [x] 9.3.5 Implementar `EX-ABRETELA` - Abre outra tela

## 10. Integracao com sag-events.js

- [x] 10.1 Modificar `fireFieldEvent()` para chamar `PlsagInterpreter.execute()`
- [x] 10.2 Modificar `fireFormEvent()` para chamar `PlsagInterpreter.execute()`
- [x] 10.3 Implementar `collectFormData()` para criar contexto
- [x] 10.4 Atualizar ordem de carregamento de scripts em _Layout.cshtml
- [x] 10.5 Implementar tratamento de erros sem quebrar formulario
- [x] 10.6 Implementar `execFieldEventsOnShow()` - executa Exit de todos campos no show (CampPersExecExitShow)
- [x] 10.7 Implementar `filterInstructionsForShow()` - filtra M*, EX*, BO*, BC*, TI* no show
- [x] 10.8 Implementar `VeriEnviConf` - beforeSave() bloqueia quando PA/ME param execucao
- [x] 10.9 Implementar `InicValoCampPers` - inicializa valores padrao de campos (VaGrCamp, PadrCamp)
- [x] 10.10 Implementar `InicCampSequ` - marca campos sequenciais (TagQCamp=1) como readonly
- [ ] 10.11 Implementar POViAcCa - controle de acesso por campo (FORA DO ESCOPO POC - requer auth)

## 11. Tratamento de Comandos Nao Suportados

- [x] 11.1 Criar lista de comandos nao suportados (EX-LEITSER, EX-EXECEXT, etc.)
- [x] 11.2 Implementar `handleUnsupportedCommand()` com log e evento
- [x] 11.3 Garantir que execucao continua apos comando nao suportado

## 12. Testes e Validacao

- [ ] 12.1 Criar testes unitarios do parser (Jest ou similar)
- [ ] 12.2 Criar testes unitarios de substituicao de templates
- [ ] 12.3 Criar testes unitarios de controle de fluxo (IF/ELSE)
- [ ] 12.4 Criar testes unitarios de comandos de campo
- [ ] 12.5 Criar testes de integracao com API backend
- [ ] 12.6 Testar com formularios reais do SAG (minimo 3)
- [ ] 12.7 Comparar comportamento Web vs Delphi

## 13. Documentacao

- [ ] 13.1 Documentar API do PlsagInterpreter
- [ ] 13.2 Documentar comandos suportados vs nao suportados
- [ ] 13.3 Atualizar debug popup para mostrar execucao PLSAG

## 14. Comandos Faltantes - Alta/Media Prioridade

Comandos que existem na documentacao base mas nao foram incluidos na proposta original.

### 14.1 Labels e Campos Calculados
- [x] 14.1.1 Implementar `LN` - Label Numerico (campo calculado numerico, read-only)
- [x] 14.1.2 Implementar `LB` - Label (define caption/texto de label)
- [x] 14.1.3 Implementar `LE` - Label Editor (campo calculado texto, read-only)

### 14.2 Botoes
- [x] 14.2.1 Implementar `BT` - Botao (caption, enable, visible)

### 14.3 Campos Adicionais
- [x] 14.3.1 Implementar `CC` - Campo Combo (se diferente de CT)
- [x] 14.3.2 Implementar `CD` - Campo Data (se diferente de CE com mascara)

## 15. Comandos Faltantes - Baixa Prioridade

Comandos menos usados ou com alternativas existentes.

### 15.1 Campos Especiais
- [x] 15.1.1 Implementar `CA` - Campo Arquivo
- [x] 15.1.2 Implementar `CR` - Campo Formatado
- [x] 15.1.3 Implementar `IL` - Lookup Numerico

### 15.2 Editores (sem banco)
- [x] 15.2.1 Implementar `EE` - Editor Text
- [x] 15.2.2 Implementar `ES` - Editor Sim/Nao
- [x] 15.2.3 Implementar `ET` - Editor Memo
- [x] 15.2.4 Implementar `EC` - Editor Combo
- [x] 15.2.5 Implementar `ED` - Editor Data
- [x] 15.2.6 Implementar `EA` - Editor Arquivo
- [x] 15.2.7 Implementar `EI` - Editor Diretorio
- [x] 15.2.8 Implementar `EL` - Editor Lookup
