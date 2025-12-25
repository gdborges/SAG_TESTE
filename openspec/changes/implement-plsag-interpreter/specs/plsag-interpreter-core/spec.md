# Capability: PLSAG Interpreter Core

Core do interpretador PLSAG responsável por parsing, substituição de templates, execução sequencial e gerenciamento de contexto.

## ADDED Requirements

### Requirement: Instruction Parser

O sistema MUST parsear instruções PLSAG seguindo a regra dos 8 caracteres. O parser MUST extrair prefixo (2 chars), identificador (8 chars, padded) e parâmetro de cada instrução.

O formato de instrução é: `PREFIXO-IDENTIFICADOR-PARAMETRO` onde:
- PREFIXO: 2 caracteres que identificam o tipo de comando
- IDENTIFICADOR: EXATAMENTE 8 caracteres (completados com espaços se necessário)
- PARAMETRO: valor ou expressão (opcional)

#### Scenario: Parse instruction with 8-char identifier
- **GIVEN** uma instrução "CE-CodiProd-valor"
- **WHEN** o parser processa a instrução
- **THEN** extrai prefix="CE", identifier="CodiProd", parameter="valor"

#### Scenario: Parse instruction with short identifier (padding)
- **GIVEN** uma instrução "CE-Prod   -valor" (Prod + 4 espaços = 8 chars)
- **WHEN** o parser processa a instrução
- **THEN** extrai prefix="CE", identifier="Prod" (trimmed), parameter="valor"

#### Scenario: Parse instruction without separator after prefix
- **GIVEN** uma instrução "CECodiProd-valor"
- **WHEN** o parser processa a instrução
- **THEN** extrai prefix="CE", identifier="CodiProd", parameter="valor"

#### Scenario: Parse multiple instructions separated by semicolon
- **GIVEN** uma string "CE-Campo1;CN-Campo2;CS-Campo3-valor"
- **WHEN** o parser tokeniza a string
- **THEN** retorna array com 3 tokens parseados corretamente

---

### Requirement: Template Substitution

O sistema MUST substituir templates `{TIPO-CAMPO}` por valores do contexto antes de executar instruções. O sistema MUST suportar templates DG, DM, VA, QY e outros tipos definidos.

Tipos de template suportados:
- `{DG-Campo}` - Valor do campo no formulário (cabeçalho)
- `{DM-Campo}` - Valor do campo no movimento 1
- `{D2-Campo}` - Valor do campo no movimento 2
- `{D3-Campo}` - Valor do campo no movimento 3
- `{VA-Variavel}` - Valor de variável PLSAG
- `{QY-Query-Campo}` - Valor de campo de query executada
- `{FC-Campo}` - Valor formatado do campo
- `{LI-Indice}` - Valor de lista/array

#### Scenario: Substitute DG template
- **GIVEN** contexto com formData.CodiProd = "1001"
- **WHEN** substitui template em "{DG-CodiProd}"
- **THEN** retorna "1001"

#### Scenario: Substitute VA template
- **GIVEN** contexto com variables.custom.TOTAL = "250.00"
- **WHEN** substitui template em "{VA-TOTAL}"
- **THEN** retorna "250.00"

#### Scenario: Substitute QY template
- **GIVEN** contexto com queryResults.PROD = { DESCRI: "Produto Teste" }
- **WHEN** substitui template em "{QY-PROD-DESCRI}"
- **THEN** retorna "Produto Teste"

#### Scenario: Substitute multiple templates in same string
- **GIVEN** contexto com formData.Quanti = "10" e formData.ValoUnit = "25.00"
- **WHEN** substitui template em "{DG-Quanti} x {DG-ValoUnit}"
- **THEN** retorna "10 x 25.00"

#### Scenario: Handle missing template value
- **GIVEN** contexto sem o campo CodiXXXX
- **WHEN** substitui template em "{DG-CodiXXXX}"
- **THEN** retorna string vazia "" e loga warning

---

### Requirement: Execution Context

O sistema MUST manter um contexto de execução que persiste entre instruções. O contexto MUST conter formData, variables, queryResults e control state.

O contexto contém:
- formData: campos do formulário atual
- variables: variáveis PLSAG (VA, VP, PU)
- system: variáveis de sistema (INSERIND, ALTERIND, CODIPESS, etc.)
- queryResults: resultados de queries executadas
- control: estado de controle de fluxo (IF/ELSE, loops)
- meta: metadados da execução (eventType, triggerField, executionId)

#### Scenario: Initialize context with form data
- **GIVEN** dados do formulário { CodiProd: "1001", Descri: "Teste" }
- **WHEN** inicializa contexto de execução
- **THEN** formData contém os campos do formulário
- **AND** system contém variáveis de sistema inicializadas

#### Scenario: Persist variable across instructions
- **GIVEN** contexto inicializado
- **WHEN** executa "VA-TOTAL---100" seguido de "CS-Campo1-{VA-TOTAL}"
- **THEN** Campo1 recebe valor "100"

#### Scenario: Store query result in context
- **GIVEN** contexto inicializado
- **WHEN** executa query QY-PROD com resultado { DESCRI: "Produto" }
- **THEN** queryResults.PROD contém { DESCRI: "Produto" }
- **AND** template {QY-PROD-DESCRI} retorna "Produto"

---

### Requirement: Sequential Executor

O sistema MUST executar instruções sequencialmente, respeitando a ordem. O executor MUST aguardar operações assíncronas antes de continuar com a próxima instrução.

#### Scenario: Execute instructions in order
- **GIVEN** instruções "VA-A---1;VA-B---{VA-A};VA-C---{VA-B}"
- **WHEN** executor processa a lista
- **THEN** A=1, B=1, C=1 (cada instrução usa resultado da anterior)

#### Scenario: Stop execution on ME command
- **GIVEN** instruções "VA-A---1;ME-ERR---Erro;VA-B---2"
- **WHEN** executor processa a lista
- **THEN** A=1, B permanece undefined
- **AND** execução para após ME

#### Scenario: Stop execution on PA command with false condition
- **GIVEN** instruções "VA-A---1;PA-12345678-0;VA-B---2"
- **WHEN** executor processa a lista
- **THEN** A=1, B permanece undefined (PA com 0 para execução)

#### Scenario: Continue execution on PA command with true condition
- **GIVEN** instruções "VA-A---1;PA-12345678-1;VA-B---2"
- **WHEN** executor processa a lista
- **THEN** A=1, B=2 (PA com valor != 0 continua)

#### Scenario: Handle async commands
- **GIVEN** instruções com comando de query (QY) que retorna async
- **WHEN** executor processa a lista
- **THEN** aguarda resultado da query antes de continuar
- **AND** próxima instrução pode usar resultado da query

---

### Requirement: System Variables

O sistema MUST disponibilizar variáveis de sistema somente-leitura. O sistema MUST impedir alteração dessas variáveis via VA.

| Variável | Tipo | Descrição |
|----------|------|-----------|
| INSERIND | Boolean | Modo inserção (1) ou alteração (0) |
| ALTERIND | Boolean | Modo alteração (1) ou inserção (0) |
| VISUALIZ | Boolean | Modo visualização (1) ou edição (0) |
| CODIPESS | Integer | Código da pessoa logada |
| CODIEMPR | Integer | Código da empresa atual |
| CODIFILI | Integer | Código da filial atual |
| CODIUSUA | Integer | Código do usuário logado |
| NOMEUSU | String | Nome do usuário logado |
| DATAATUA | Date | Data atual do sistema |
| HORAATUA | Time | Hora atual do sistema |
| DATAHORA | DateTime | Data e hora combinadas |
| CODITABE | Integer | Código da tabela atual |
| NOMETABE | String | Nome da tabela atual |
| REGISTRO | Integer | Número do registro atual |
| ULTIMOID | Integer | Último ID inserido |

#### Scenario: Read INSERIND system variable
- **GIVEN** formulário em modo inserção
- **WHEN** substitui template "{VA-INSERIND}"
- **THEN** retorna "1"

#### Scenario: Read DATAATUA system variable
- **GIVEN** data atual é 2025-12-24
- **WHEN** substitui template "{VA-DATAATUA}"
- **THEN** retorna "24/12/2025" (formato BR)

#### Scenario: System variables are read-only
- **GIVEN** tentativa de atribuir "VA-INSERIND-0"
- **WHEN** executor processa a instrução
- **THEN** ignora a atribuição
- **AND** loga warning sobre tentativa de alterar variável de sistema

---

### Requirement: Expression Evaluation

O sistema MUST avaliar expressões aritméticas e lógicas em parâmetros. O avaliador MUST suportar operadores +, -, *, / e comparações.

Operadores suportados:
- Aritméticos: +, -, *, /
- Comparação: =, <>, <, >, <=, >=
- Lógicos: AND, OR, NOT

#### Scenario: Evaluate arithmetic expression
- **GIVEN** expressão "10 * 25.5"
- **WHEN** avaliador processa a expressão
- **THEN** retorna 255

#### Scenario: Evaluate expression with templates
- **GIVEN** contexto com formData.Quanti = "10", formData.Preco = "25.00"
- **WHEN** avalia expressão "{DG-Quanti} * {DG-Preco}"
- **THEN** retorna 250

#### Scenario: Evaluate comparison expression
- **GIVEN** contexto com formData.Tipo = "A"
- **WHEN** avalia expressão "{DG-Tipo} = 'A'"
- **THEN** retorna true (ou 1)

#### Scenario: Handle division by zero
- **GIVEN** expressão "100 / 0"
- **WHEN** avaliador processa a expressão
- **THEN** retorna 0
- **AND** loga warning sobre divisão por zero
