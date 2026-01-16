# Capability: PLSAG Server Commands

Comandos PLSAG que requerem chamada ao backend para execução de queries, gravação de dados ou operações especiais.

## ADDED Requirements

### Requirement: Query Commands QY/QN

O sistema MUST executar queries SQL via comandos QY e QN, armazenando resultados no contexto.

| Comando | Descrição |
|---------|-----------|
| QY-ID-SQL | Executa query, armazena resultado único em queryResults[ID] |
| QN-ID-SQL | Executa query multi-linha, armazena array em queryResults[ID] |
| QY-ID-ABRE | Reabre query com SQL original |
| QY-ID-FECH | Fecha/limpa query do contexto |
| QY-ID-PRIM | Posiciona no primeiro registro (QN) |
| QY-ID-PROX | Posiciona no próximo registro (QN) |
| QY-ID-ANTE | Posiciona no registro anterior (QN) |
| QY-ID-ULTI | Posiciona no último registro (QN) |

#### Scenario: Execute single-row query with QY
- **GIVEN** instrução "QY-PROD----SELECT DESCRI, PRECO FROM PRODUTO WHERE CODI = 1001"
- **WHEN** executor processa QY
- **THEN** chama API POST /api/plsag/query com { queryName: "PROD", sql: "...", type: "single" }
- **AND** armazena resultado em context.queryResults.PROD

#### Scenario: Access query result via template
- **GIVEN** query PROD executada com resultado { DESCRI: "Produto A", PRECO: 25.00 }
- **WHEN** substitui template "{QY-PROD-DESCRI}"
- **THEN** retorna "Produto A"

#### Scenario: Execute multi-row query with QN
- **GIVEN** instrução "QN-ITENS---SELECT * FROM ITEMPEDIDO WHERE CODIPEDI = 100"
- **WHEN** executor processa QN
- **THEN** chama API com type: "multi"
- **AND** armazena array de registros em context.queryMultiResults.ITENS

#### Scenario: Navigate multi-row query
- **GIVEN** query ITENS com 5 registros, posição atual = 0
- **WHEN** executa "QY-ITENS---PROX"
- **THEN** posição atual = 1
- **AND** {QY-ITENS-*} retorna valores do registro 1

#### Scenario: Handle empty query result
- **GIVEN** query que retorna 0 registros
- **WHEN** executor processa QY
- **THEN** context.queryResults.ID = null
- **AND** templates {QY-ID-*} retornam string vazia

#### Scenario: Handle query error
- **GIVEN** query com SQL inválido
- **WHEN** API retorna erro
- **THEN** loga erro no console
- **AND** context.queryResults.ID = null
- **AND** continua execução (não para)

---

### Requirement: Query Modify Commands QD/QM

O sistema MUST executar comandos de modificação de dados via QD e QM.

| Comando | Descrição |
|---------|-----------|
| QD-ID-SQL | Executa DELETE |
| QM-ID-SQL | Executa UPDATE |

#### Scenario: Execute delete with QD
- **GIVEN** instrução "QD-DEL-----DELETE FROM TEMP WHERE ID = 1"
- **WHEN** executor processa QD
- **THEN** chama API POST /api/plsag/save com operação DELETE
- **AND** retorna número de linhas afetadas

#### Scenario: Execute update with QM
- **GIVEN** instrução "QM-UPD-----UPDATE PRODUTO SET PRECO = 30 WHERE CODI = 1001"
- **WHEN** executor processa QM
- **THEN** chama API POST /api/plsag/save com operação UPDATE
- **AND** retorna número de linhas afetadas

#### Scenario: Substitute templates in SQL
- **GIVEN** instrução "QD-DEL-----DELETE FROM TEMP WHERE CODI = {DG-CodiProd}"
- **WHEN** executor processa QD
- **THEN** substitui templates ANTES de enviar à API
- **AND** SQL enviado contém valor real do campo

---

### Requirement: Data Save Commands DG/DM/D2/D3

O sistema MUST gravar dados em campos via comandos DG, DM, D2 e D3.

| Comando | Descrição |
|---------|-----------|
| DG-Campo-Valor | Grava no campo do cabeçalho (INSERT mode) |
| DM-Campo-Valor | Grava no campo do movimento 1 |
| D2-Campo-Valor | Grava no campo do movimento 2 |
| D3-Campo-Valor | Grava no campo do movimento 3 |
| DDG-Campo-Valor | SEMPRE grava (mesmo em EDIT mode) |

#### Scenario: Save field value with DG in INSERT mode
- **GIVEN** formulário em modo INSERT
- **WHEN** executa "DG-CodiProd-1001"
- **THEN** chama API POST /api/plsag/save
- **AND** campo CodiProd do registro recebe valor 1001

#### Scenario: Skip DG in EDIT mode
- **GIVEN** formulário em modo EDIT (VA-ALTERIND = 1)
- **WHEN** executa "DG-CodiProd-1001"
- **THEN** NÃO grava (ignora instrução)
- **AND** loga info "DG ignorado em modo EDIT"

#### Scenario: Force save with DDG
- **GIVEN** formulário em modo EDIT
- **WHEN** executa "DDG-CodiProd-1001"
- **THEN** GRAVA mesmo em modo EDIT

#### Scenario: Save movement field with DM
- **GIVEN** registro de movimento ativo
- **WHEN** executa "DM-Quanti---10"
- **THEN** campo Quanti do movimento 1 recebe valor 10

#### Scenario: Save with expression value
- **GIVEN** campos Quanti = 10, Preco = 25
- **WHEN** executa "DG-Total---{DG-Quanti} * {DG-Preco}"
- **THEN** campo Total recebe valor 250

---

### Requirement: EX Commands Server-Side

O sistema MUST executar comandos EX que requerem processamento no servidor.

#### Scenario: EX-SQL execute raw SQL
- **GIVEN** instrução "EX-SQL-----UPDATE PRODUTO SET ATIVO = 1 WHERE CODI = 100"
- **WHEN** executor processa EX-SQL
- **THEN** chama API POST /api/plsag/execute com { command: "SQL", sql: "..." }

#### Scenario: EX-EXECPROC execute stored procedure
- **GIVEN** instrução "EX-EXECPROC-SP_CALCULA_ESTOQUE @CODI = 100"
- **WHEN** executor processa EX-EXECPROC
- **THEN** chama API POST /api/plsag/execute com { command: "PROC", procedure: "..." }

#### Scenario: EX-TRANSINI start transaction
- **GIVEN** instrução "EX-TRANSINI"
- **WHEN** executor processa
- **THEN** chama API para iniciar transação
- **AND** armazena transaction ID no contexto

#### Scenario: EX-TRANSCOM commit transaction
- **GIVEN** transação ativa
- **WHEN** executa "EX-TRANSCOM"
- **THEN** chama API para commit

#### Scenario: EX-TRANSROL rollback transaction
- **GIVEN** transação ativa
- **WHEN** executa "EX-TRANSROL"
- **THEN** chama API para rollback

#### Scenario: EX-GRAVAFOR trigger form save
- **GIVEN** formulário com dados alterados
- **WHEN** executa "EX-GRAVAFOR"
- **THEN** dispara submit do formulário
- **AND** aguarda resposta antes de continuar

#### Scenario: EX-IMPRIMIR generate print
- **GIVEN** instrução "EX-IMPRIMIR-REL001"
- **WHEN** executor processa
- **THEN** chama API para gerar PDF do relatório
- **AND** abre PDF em nova aba ou download

#### Scenario: EX-EXPOPDF export to PDF
- **GIVEN** instrução "EX-EXPOPDF--FORM"
- **WHEN** executor processa
- **THEN** chama API para gerar PDF do formulário
- **AND** retorna URL do arquivo em VA-RETOFUNC

#### Scenario: EX-EXPOEXCE export to Excel
- **GIVEN** instrução "EX-EXPOEXCE-GRID"
- **WHEN** executor processa
- **THEN** chama API para gerar Excel dos dados
- **AND** inicia download do arquivo

---

### Requirement: Validation Commands

O sistema MUST validar dados via comandos EX de validação.

#### Scenario: EX-VALICPF validate CPF
- **GIVEN** instrução "EX-VALICPF_-12345678901"
- **WHEN** executor processa
- **THEN** chama API para validar CPF
- **AND** retorna "1" em VA-RETOFUNC se válido, "0" se inválido

#### Scenario: EX-VALICNPJ validate CNPJ
- **GIVEN** instrução "EX-VALICNPJ-12345678000199"
- **WHEN** executor processa
- **THEN** chama API para validar CNPJ
- **AND** retorna "1" em VA-RETOFUNC se válido, "0" se inválido

#### Scenario: EX-VALIDATA validate date
- **GIVEN** instrução "EX-VALIDATA-31/02/2025"
- **WHEN** executor processa
- **THEN** valida se data é válida
- **AND** retorna "0" em VA-RETOFUNC (31/02 inválido)

#### Scenario: EX-VALIHORA validate time
- **GIVEN** instrução "EX-VALIHORA-25:00:00"
- **WHEN** executor processa
- **THEN** valida se hora é válida
- **AND** retorna "0" em VA-RETOFUNC (25:00 inválido)

---

### Requirement: Navigation Commands

O sistema MUST suportar navegação entre registros e formulários.

#### Scenario: EX-PROXREGI next record
- **GIVEN** dataset com múltiplos registros, posição atual = 2
- **WHEN** executa "EX-PROXREGI"
- **THEN** navega para registro 3
- **AND** atualiza formData com novos valores

#### Scenario: EX-ANTEREGI previous record
- **GIVEN** dataset com múltiplos registros, posição atual = 2
- **WHEN** executa "EX-ANTEREGI"
- **THEN** navega para registro 1

#### Scenario: EX-PRIMREGI first record
- **GIVEN** dataset com múltiplos registros
- **WHEN** executa "EX-PRIMREGI"
- **THEN** navega para primeiro registro

#### Scenario: EX-ULTIREGI last record
- **GIVEN** dataset com múltiplos registros
- **WHEN** executa "EX-ULTIREGI"
- **THEN** navega para último registro

#### Scenario: EX-ABRETELA open another form
- **GIVEN** instrução "EX-ABRETELA-CONSULTA_CLIENTE"
- **WHEN** executor processa
- **THEN** abre modal ou nova aba com formulário CONSULTA_CLIENTE
- **AND** pode passar parâmetros via variáveis PU

---

### Requirement: API Error Handling

O sistema MUST tratar erros de API de forma consistente.

#### Scenario: Handle network error
- **GIVEN** API indisponível (fetch falha)
- **WHEN** executor tenta chamar API
- **THEN** loga erro "[PLSAG] Erro de rede: ..."
- **AND** seta context.control.errorState com mensagem
- **AND** continua execução (não para, exceto se ME)

#### Scenario: Handle API validation error
- **GIVEN** API retorna status 400 com mensagem de erro
- **WHEN** executor processa resposta
- **THEN** loga warning com mensagem de erro
- **AND** comando retorna null/false

#### Scenario: Handle API timeout
- **GIVEN** API não responde em 30 segundos
- **WHEN** timeout ocorre
- **THEN** loga erro "[PLSAG] Timeout: ..."
- **AND** aborta operação atual
- **AND** continua com próxima instrução

#### Scenario: Retry transient errors
- **GIVEN** API retorna status 503 (temporário)
- **WHEN** executor processa erro
- **THEN** aguarda 1 segundo
- **AND** tenta novamente (máximo 3 tentativas)
