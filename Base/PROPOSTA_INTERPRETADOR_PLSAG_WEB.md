# Proposta de Implementacao do Interpretador PLSAG - SAG Web

**Versao:** 1.1
**Data:** 2025-12-24
**Status:** Proposta para Aprovacao
**Fase:** Fase 2 - Interpretador PLSAG (continuacao da Fase 1 - Infraestrutura de Eventos)
**Documento Base:** [AI_SPECIFICATION.md](./AI_SPECIFICATION.md) - Especificacao Formal PL/SAG

---

## Sumario Executivo

Este documento apresenta a proposta de implementacao do **Interpretador PLSAG** para a plataforma web do SAG. Esta e a **Fase 2** do sistema de eventos, dando continuidade a Fase 1 (infraestrutura de captura de eventos com popups de debug) que ja foi implementada.

O PLSAG (Personalizacao por Lista de Instrucoes do SAG) e a linguagem de personalizacao do SAG que permite configurar comportamentos dinamicos nos formularios. O interpretador web devera ser compativel com a sintaxe existente no Delphi, permitindo que as mesmas instrucoes configuradas no banco funcionem tanto no sistema desktop quanto no web.

> **Referencia Tecnica:** A especificacao formal completa da linguagem PL/SAG, incluindo gramatica BNF, semantica operacional e casos de teste canonicos, esta documentada em `AI_SPECIFICATION.md`. Este documento foca na estrategia de implementacao web.

---

## PARTE 1: Entendimento do PLSAG no Delphi

### 1.1 O que e o PLSAG

PLSAG e uma linguagem de script proprietaria do SAG que permite:
- Manipular campos de formulario (habilitar, desabilitar, setar valores)
- Executar queries no banco de dados
- Exibir mensagens ao usuario
- Controlar fluxo com condicionais e loops
- Executar comandos especiais do sistema

### 1.2 Sintaxe Basica

A sintaxe segue o padrao:

```
PREFIXO-IDENTIFICADOR-PARAMETRO
```

Onde:
- **PREFIXO**: 2 caracteres que identificam o tipo de comando
- **IDENTIFICADOR**: 8 caracteres (completados com espacos se necessario)
- **PARAMETRO**: Valor ou expressao (opcional, dependendo do comando)

**Exemplos:**
```
CE-CodiProd         -> Habilita o campo CodiProd
CN-CodiProd         -> Desabilita o campo CodiProd
VA-TOTAL   -100     -> Atribui 100 a variavel TOTAL
CS-Quant   -{DG-Quant}  -> Seta campo Quant com valor do campo Quant no form
```

### 1.3 Regra dos 8 Caracteres

O identificador SEMPRE tem 8 caracteres. Se o nome for menor, e completado com espacos:

| Nome Original | Identificador (8 chars) |
|---------------|------------------------|
| `CodiProd` | `CodiProd` (8 chars, ok) |
| `Quant` | `Quant   ` (5 + 3 espacos) |
| `A` | `A       ` (1 + 7 espacos) |

#### Algoritmo Formal de Parsing

Conforme definido em `AI_SPECIFICATION.md`, o algoritmo de parsing segue esta sequencia:

```
PARSE_INSTRUCTION(raw_string):
  1. prefix = raw_string[0:2]          // Primeiros 2 caracteres
  2. Se raw_string[2] == '-':
       identifier = raw_string[3:11]   // Proximos 8 caracteres (posicoes 3-10)
       parameter = raw_string[12:]     // Apos segundo hifen (se houver)
     Senao:
       identifier = raw_string[2:10]   // Proximos 8 caracteres (posicoes 2-9)
       parameter = raw_string[11:]     // Restante apos hifen

  3. identifier = RIGHT_PAD(identifier, 8, ' ')  // Garantir 8 chars
  4. Retornar { prefix, identifier, parameter }
```

**Exemplo passo a passo:**
```
Input: "CS-Quant   -{DG-Total}"
  1. prefix = "CS"
  2. raw_string[2] = '-', entao:
     identifier = "Quant   " (posicoes 3-10)
     parameter = "{DG-Total}" (posicao 12+)
  3. identifier ja tem 8 chars
  4. Resultado: { prefix: "CS", identifier: "Quant   ", parameter: "{DG-Total}" }
```

### 1.4 Categorias de Comandos

#### 1.4.1 Comandos de Campo (Prefixos C*)

Os prefixos C* definem o **TIPO de componente UI** do campo, nao acoes de habilitar/desabilitar:

| Prefixo | Tipo de Campo | Componente Delphi | Descricao |
|---------|---------------|-------------------|-----------|
| `CE` | Campo Editor | TDBEdtLbl | Campo de texto simples com vinculo ao banco |
| `CN` | Campo Numerico | TDBRxELbl | Campo para valores numericos (inteiros/decimais) |
| `CS` | Campo Sim/Nao | TDBChkLbl | Checkbox (valores 0/1 ou S/N) |
| `CM` | Campo Memo | TDBMemLbl | Campo de texto longo (multilinha) |
| `CT` | Campo Tabela | TLcbLbl/TDBLookNume | Lookup/Combo ligado a tabela auxiliar |
| `CA` | Campo Arquivo | TFileLbl | Seletor de arquivo/path |

**Variantes sem vinculo ao banco (prefixo I):**

| Prefixo | Tipo de Campo | Descricao |
|---------|---------------|-----------|
| `IE` | Input Editor | Campo texto sem vinculo ao banco |
| `IN` | Input Numerico | Campo numerico sem vinculo ao banco |
| `IT` | Input Tabela | Lookup/Combo sem vinculo ao banco |
| `IM` | Input Memo | Memo sem vinculo ao banco |

**Sintaxe de Atribuicao:**
```
CE-<campo>-<valor>  -> Define valor de campo Editor
CN-<campo>-<valor>  -> Define valor de campo Numerico
CS-<campo>-<valor>  -> Define valor de campo Sim/Nao (0 ou 1)
CM-<campo>-<valor>  -> Define valor de campo Memo
CT-<campo>-<valor>  -> Define valor de campo Tabela (ID do registro)
```

**Modificadores de Acao (aplicaveis a todos os tipos C*):**

Os modificadores controlam **acoes de UI** e podem ser combinados com qualquer tipo:

| Modificador | Sintaxe | Descricao | Parametro |
|-------------|---------|-----------|-----------|
| `D` (Disable) | `CED-Campo-<cond>` | Habilita/Desabilita | 0=desabilita, !=0 habilita |
| `F` (Focus) | `CEF-Campo-<cond>` | Foca campo | Se cond != 0, foca |
| `V` (Visible) | `CEV-Campo-<cond>` | Mostra/Esconde | 0=esconde, !=0 mostra |
| `C` (Color) | `CEC-Campo-<cor>` | Altera cor de fundo | Cor em formato hex |
| `R` (Readonly) | `CER-Campo-<cond>` | Somente leitura | Se cond != 0, readonly |

> **IMPORTANTE:** Modificadores aplicam-se a TODOS os tipos (CND, CNF, CNV, CSD, CSF, etc.)

**Exemplos de uso:**
```
CE-NomeProd-'Produto Teste'   -> Define texto do campo NomeProd
CN-Quanti  -10                -> Define campo numerico Quanti = 10
CS-AtivCarg-1                 -> Marca checkbox AtivCarg como true
CT-CodiCida-{QY-CIDA-CODICIDA} -> Define lookup Cidade com resultado de query

CED-NomeProd-1                -> Habilita campo NomeProd (1 = true)
CED-NomeProd-0                -> Desabilita campo NomeProd (0 = false)
CEV-Observa-{CS-MostraObs}    -> Mostra/esconde conforme valor do checkbox
CNF-Quanti  -1                -> Move foco para campo numerico Quanti
CEC-Total   -#FFFF00          -> Muda cor de fundo do campo Total para amarelo
```

#### 1.4.2 Comandos de Variavel (Prefixos V*, P*)

| Prefixo | Comando | Escopo | Descricao |
|---------|---------|--------|-----------|
| `VA` | Variable Assign | Formulario | Variaveis locais do formulario atual |
| `VP` | Variable Persistent | Sessao | Variaveis persistentes durante a sessao |
| `PU` | Public | Global | Variaveis publicas globais (compartilhadas entre formularios) |

> **IMPORTANTE:** Variaveis DEVEM seguir o padrao `TIPO####` onde:
> - `TIPO` = INTE, REAL, STRI, DATA ou VALO (4 caracteres)
> - `####` = Indice numerico de 4 digitos (0001, 0002, etc.)
> - Nomes livres como "VA-TOTAL" NAO sao validos!

**Faixas de Variaveis VA (Formulario):**

| Faixa | Tipo | Range | Descricao |
|-------|------|-------|-----------|
| `VA-INTE####` | Integer | 0001-0020 | Valores inteiros |
| `VA-REAL####` | Float | 0001-0020 | Valores decimais |
| `VA-STRI####` | String | 0001-0020 | Textos |
| `VA-DATA####` | Date | 0001-0010 | Datas |
| `VA-VALO####` | Raw | 0001-0010 | Valores sem aspas (para SQL) |
| `VA-RESU####` | Any | 0001-0008 | Resultado de funcoes EX |

**Faixas de Variaveis VP (Persistentes):**

| Faixa | Tipo | Range | Descricao |
|-------|------|-------|-----------|
| `VP-INTE####` | Integer | 0001-sem limite | Inteiros persistentes |
| `VP-REAL####` | Float | 0001-sem limite | Decimais persistentes |
| `VP-STRI####` | String | 0001-sem limite | Textos persistentes |
| `VP-DATA####` | Date | 0001-sem limite | Datas persistentes |
| `VP-VALO####` | Raw | 0001-sem limite | Valores persistentes |

**Faixas de Variaveis PU (Publicas Globais):**

| Faixa | Tipo | Range | Descricao |
|-------|------|-------|-----------|
| `PU-INTE####` | Integer | 0001-0005 | Inteiros globais |
| `PU-REAL####` | Float | 0001-0005 | Decimais globais |
| `PU-STRI####` | String | 0001-0005 | Textos globais |
| `PU-DATA####` | Date | 0001-0005 | Datas globais |
| `PU-VALO####` | Raw | 0001-0005 | Valores globais |

> **ATENCAO:** Variaveis PU sao limitadas a 5 por tipo (0001-0005)

**Exemplos de uso correto:**
```
VA-INTE0001-100              -> Atribui 100 a variavel inteira 1
VA-REAL0001-3.14             -> Atribui 3.14 a variavel decimal 1
VA-STRI0001-'Texto exemplo'  -> Atribui texto a variavel string 1
VA-DATA0001-{VA-DATAATUA}    -> Atribui data atual a variavel data 1
VP-STRI0001-{DG-NomeProd}    -> Persiste nome do produto na sessao
PU-INTE0001-{DG-CodiEmpr}    -> Define empresa em variavel global
```

**Variaveis de Sistema (somente leitura):**

| Variavel | Tipo | Descricao |
|----------|------|-----------|
| `VA-INSERIND` | Boolean | 1 se em modo insercao, 0 se alteracao |
| `VA-ALTERIND` | Boolean | 1 se em modo alteracao |
| `VA-VISUALIZ` | Boolean | 1 se em modo visualizacao |
| `VA-CODIPESS` | Integer | Codigo da pessoa logada |
| `VA-CODIEMPR` | Integer | Codigo da empresa atual |
| `VA-CODIFILI` | Integer | Codigo da filial atual |
| `VA-CODIUSUA` | Integer | Codigo do usuario logado |
| `VA-DATAATUA` | Date | Data atual do sistema |
| `VA-HORAATUA` | Time | Hora atual do sistema |
| `VA-NOMEUSU` | String | Nome do usuario logado |
| `VA-CODITABE` | Integer | Codigo da tabela atual |
| `VA-REGISTRO` | Integer | Numero do registro atual |

**Variaveis Reservadas de Retorno:**
```
VA-RETOFUNC  -> Retorno de funcoes EX (string)
VA-RESU0001 a VA-RESU0008 -> Multiplos valores de retorno
```

#### 1.4.3 Comandos de Query (Prefixos Q*, D*)

| Prefixo | Comando | Descricao |
|---------|---------|-----------|
| `QY` | Query Yes | Executa query, armazena resultado |
| `QN` | Query N-lines | Executa query multi-linha |
| `QD` | Query Delete | Deleta registro |
| `QM` | Query Modify | Modifica registro |
| `QT` | Query Table | Executa em tabela especifica |
| `DG` | Data Grava | Grava dados campo a campo |
| `DM` | Data Mestre | Grava em tabela destino |
| `D2` | Data 2 | Grava registro secundario |
| `D3` | Data 3 | Grava multiplos registros |

#### 1.4.4 Comandos de Mensagem (Prefixos M*)

| Prefixo | Comando | Descricao |
|---------|---------|-----------|
| `MA` | Message Alert | Exibe alerta |
| `MC` | Message Confirm | Exibe confirmacao (Sim/Nao) |
| `ME` | Message Error | Exibe erro |
| `MI` | Message Info | Exibe informacao |
| `MP` | Message Prompt | Solicita entrada do usuario |

#### 1.4.5 Comandos de Controle de Fluxo

A estrutura de controle usa o prefixo `IF-` seguido de sufixos que indicam a operacao:

| Comando | Sintaxe | Descricao |
|---------|---------|-----------|
| `IF-INIC<label>` | `IF-INIC0001-<cond>` | Inicia bloco IF com label numerado |
| `IF-ELSE<label>` | `IF-ELSE0001-<cond>` | Else com condicao opcional |
| `IF-ELSE<label>` | `IF-ELSE0001-` | Else incondicional (sem condicao) |
| `IF-FINA<label>` | `IF-FINA0001` | Finaliza bloco IF (obrigatorio mesmo label) |
| `WH-INIC<label>` | `WH-INIC0001-<cond>` | Inicia loop while |
| `WH-FINA<label>` | `WH-FINA0001` | Finaliza loop while |
| `PA` | `PA------` | Pare (break) - sai do loop atual |

> **IMPORTANTE:** O `<label>` (4 digitos) DEVE ser o mesmo para INIC/ELSE/FINA do mesmo bloco.
> Isso permite o parser identificar blocos aninhados corretamente.

**Sintaxe de Condicao:**

A condicao e uma expressao que retorna 0 (falso) ou != 0 (verdadeiro):
```
IF-INIC0001-{CS-AtivCarg}=1       -> Compara checkbox com 1
IF-INIC0002-{DG-Quanti}>10        -> Compara campo numerico
IF-INIC0003-'{DG-NomeProd}'<>''   -> Verifica string nao vazia
IF-INIC0004-SELECT 1 FROM DUAL WHERE {DG-CodiProd} > 0  -> Subquery SQL
```

##### Maquina de Estados IF/ELSE/FINA

O controle de fluxo usa uma maquina de estados de 3 niveis:

```
Estados:
  EXECUTANDO -> Executando instrucoes normalmente
  PULANDO    -> Pulando instrucoes (condicao falsa)
  SATISFEITO -> Bloco IF ja foi satisfeito, pular ELSE restantes

Transicoes:
  Ao encontrar IF-INIC<label>-<cond>:
    Se cond != 0: Estado = EXECUTANDO
    Senao: Estado = PULANDO

  Ao encontrar IF-ELSE<label>-<cond>:
    Se Estado = PULANDO e (sem cond OU cond != 0):
      Estado = EXECUTANDO
    Senao:
      Estado = SATISFEITO (pula este ELSE)

  Ao encontrar IF-FINA<label>:
    Estado = EXECUTANDO (restaura execucao normal)
    Remove label da pilha de blocos
```

**Gerenciamento de Blocos Aninhados:**

```javascript
// Pilha de estados para suportar IFs aninhados
const blockStack = [];  // {label, state}

function handleIfInic(label, condition) {
    blockStack.push({
        label: label,
        state: condition ? 'EXECUTANDO' : 'PULANDO'
    });
}

function handleIfElse(label, condition) {
    const block = blockStack.find(b => b.label === label);
    if (!block) return; // Erro: ELSE sem IF

    if (block.state === 'PULANDO') {
        // IF anterior falhou, verificar condicao do ELSE
        if (condition === undefined || condition) {
            block.state = 'EXECUTANDO';
        }
    } else if (block.state === 'EXECUTANDO') {
        // IF anterior executou, pular ELSE
        block.state = 'SATISFEITO';
    }
}

function handleIfFina(label) {
    const idx = blockStack.findIndex(b => b.label === label);
    if (idx >= 0) {
        blockStack.splice(idx, 1);
    }
}

function shouldExecute() {
    // Executa se todos os blocos na pilha estao em EXECUTANDO
    return blockStack.every(b => b.state === 'EXECUTANDO');
}
```

**Exemplo de Bloco Aninhado (Sintaxe Correta):**
```
IF-INIC0001-{DG-Campo1}='A'
  CE-Campo2-'Valor A'
  IF-INIC0002-{DG-Campo2}>10
    MA-MSG1   -Valor alto
  IF-ELSE0002-
    MA-MSG2   -Valor baixo
  IF-FINA0002
IF-ELSE0001-
  CN-Campo2-'Valor diferente de A'
IF-FINA0001
```

**Exemplo Canonico (conforme AI_SPECIFICATION.md):**
```
IF-INIC0001-{CS-AtivCarg}=1
  CE-NomeCarg-'Ativo'
IF-ELSE0001-{DG-CodiPess}>100
  CE-NomeCarg-'Pessoa > 100'
IF-ELSE0001-
  CE-NomeCarg-'Padrao'
IF-FINA0001
```

#### 1.4.6 Comandos Especiais EX

O prefixo `EX` agrupa mais de 80 comandos especiais, organizados por categoria:

##### Categoria: Formulario

| Comando | Descricao | Web |
|---------|-----------|-----|
| `EX-FECHFORM` | Fecha formulario | ✅ |
| `EX-GRAVAFOR` | Grava formulario | ✅ |
| `EX-LIMPAFOR` | Limpa formulario | ✅ |
| `EX-ATUAFORM` | Atualiza formulario | ✅ |
| `EX-EXPOFORM` | Exporta formulario | ✅ |
| `EX-ABRETELA` | Abre outra tela/modal | ✅ |
| `EX-MOSTRABT` | Mostra botao | ✅ |
| `EX-ESCONDBT` | Esconde botao | ✅ |
| `EX-HABILIBT` | Habilita botao | ✅ |
| `EX-DESABIBT` | Desabilita botao | ✅ |

##### Categoria: Banco de Dados

| Comando | Descricao | Web |
|---------|-----------|-----|
| `EX-SQL-----` | Executa SQL direto | ✅ (API) |
| `EX-EXECPROC` | Executa stored procedure | ✅ (API) |
| `EX-TRANSINI` | Inicia transacao | ✅ (API) |
| `EX-TRANSCOM` | Commit transacao | ✅ (API) |
| `EX-TRANSROL` | Rollback transacao | ✅ (API) |
| `EX-REFRESHD` | Refresh dataset | ✅ (API) |

##### Categoria: Impressao e Relatorios

| Comando | Descricao | Web |
|---------|-----------|-----|
| `EX-IMPRIMIR` | Imprime relatorio | ✅ (PDF) |
| `EX-PREVISAO` | Preview de impressao | ✅ (PDF) |
| `EX-EXPOPDF-` | Exporta para PDF | ✅ |
| `EX-EXPOEXCE` | Exporta para Excel | ✅ |
| `EX-IMPRDIRE` | Impressao direta | ⚠️ Limitado |

##### Categoria: Navegacao e UI

| Comando | Descricao | Web |
|---------|-----------|-----|
| `EX-PROXREGI` | Proximo registro | ✅ |
| `EX-ANTEREGI` | Registro anterior | ✅ |
| `EX-PRIMREGI` | Primeiro registro | ✅ |
| `EX-ULTIREGI` | Ultimo registro | ✅ |
| `EX-PESQUISA` | Abre pesquisa | ✅ |
| `EX-FILTRO--` | Aplica filtro | ✅ |

##### Categoria: Sistema (Limitados na Web)

| Comando | Descricao | Web |
|---------|-----------|-----|
| `EX-LEITSER-` | Leitura porta serial | ❌ |
| `EX-EXECEXT-` | Executa programa externo | ❌ |
| `EX-ARQUIVOS` | Manipula arquivos locais | ⚠️ File API |
| `EX-CLIPBOARD` | Acesso clipboard | ✅ Clipboard API |
| `EX-EMAIL---` | Envia email | ✅ (API) |
| `EX-ENVIASMS` | Envia SMS | ✅ (API) |

##### Categoria: Validacao e Calculo

| Comando | Descricao | Web |
|---------|-----------|-----|
| `EX-CALCCAMP` | Calcula campo | ✅ |
| `EX-VALIDCPF` | Valida CPF | ✅ |
| `EX-VALIDCNP` | Valida CNPJ | ✅ |
| `EX-VALIDEMA` | Valida email | ✅ |
| `EX-FORMATAR` | Formata valor | ✅ |

**Legenda:** ✅ Suportado | ⚠️ Parcial/Limitado | ❌ Nao suportado

### 1.5 Templates de Substituicao

O PLSAG usa templates `{TIPO-CAMPO}` que sao substituidos em tempo de execucao:

| Template | Descricao | Exemplo |
|----------|-----------|---------|
| `{DG-Campo}` | Valor do campo no formulario | `{DG-CodiProd}` -> "1001" |
| `{DM-Campo}` | Valor do campo na tabela destino | `{DM-Total}` -> "150.00" |
| `{QY-Query-Campo}` | Resultado de query | `{QY-Preco-ValoUnit}` -> "25.00" |
| `{VA-Variavel}` | Valor de variavel | `{VA-TOTAL}` -> "100" |
| `{FC-Campo}` | Valor formatado do campo | `{FC-Data}` -> "24/12/2025" |
| `{LI-Indice}` | Valor de lista/array | `{LI-1}` -> "Item1" |

### 1.6 Implementacao no Delphi (PlusUni.pas)

O interpretador Delphi esta implementado em `PlusUni.pas` com as seguintes funcoes principais:

```
CampPersExecListInst  -> Funcao principal de execucao (linha 3731)
SubsCampPers          -> Substituicao de templates (linha 2670)
CampPersAcao          -> Handler de acoes especiais (linha 6163)
```

**Fluxo de Execucao:**
```
┌─────────────────────────────────────────────────────────────────────┐
│                        CampPersExecListInst                          │
│  1. Tokeniza instrucoes por ";"                                      │
│  2. Para cada instrucao:                                             │
│     a. Extrai prefixo (2 chars)                                      │
│     b. Extrai identificador (8 chars)                                │
│     c. Extrai parametro (restante)                                   │
│     d. Executa SubsCampPers para substituir templates                │
│     e. Chama handler especifico do comando                           │
│  3. Trata blocos IF/ELSE/FINA e loops WH                            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## PARTE 2: Mapeamento Delphi -> Web

### 2.1 Comandos Client-Side vs Server-Side

Os comandos PLSAG podem ser divididos em duas categorias para implementacao web:

#### 2.1.1 Comandos Client-Side (JavaScript)

Podem ser executados diretamente no navegador:

| Comando | Implementacao Web |
|---------|-------------------|
| `CE/CN` | `element.disabled = false/true` |
| `CM/CT` | `element.style.display = 'block'/'none'` |
| `CS/CV` | `element.value = valor` |
| `CF` | `element.focus()` |
| `VA/VP/PU` | Manipulacao de objeto JavaScript |
| `MA/MC/ME/MI` | `alert()`, `confirm()`, modals |
| `IF/ELSE/FINA` | Condicionais JavaScript |
| `WH/FINH/PA` | Loops JavaScript |

#### 2.1.2 Comandos Server-Side (API)

Requerem chamada ao backend:

| Comando | Implementacao Web |
|---------|-------------------|
| `QY/QN/QD/QM` | `fetch('/api/plsag/query')` |
| `DG/DM/D2/D3` | `fetch('/api/plsag/save')` |
| `EX-SQL-----` | `fetch('/api/plsag/execute')` |
| `EX-EXECPROC` | `fetch('/api/plsag/procedure')` |
| `EX-ABRETELA` | `window.location` ou modal |
| `EX-IMPRIMIR` | Gerar PDF no backend |

### 2.2 Comandos Incompativeis/Limitados

| Comando | Limitacao Web | Alternativa |
|---------|---------------|-------------|
| `EX-LEITSER` | Porta serial inacessivel | WebSerial API (experimental) ou app auxiliar |
| `EX-EXECEXT` | Execucao de programas bloqueada | Nao suportado |
| `EX-IMPRDIRE` | Impressao direta bloqueada | Dialogo de impressao ou PDF |
| `EX-ARQUIVOS` | Acesso a arquivos locais | File API com upload |

### 2.3 Mapeamento de Tipos de Dados

| Tipo Delphi | Tipo JavaScript | Observacao |
|-------------|-----------------|------------|
| Integer | Number | Usar `parseInt()` |
| Float/Double | Number | Usar `parseFloat()` |
| String | String | Direto |
| TDateTime | Date/String | ISO 8601 ou dd/mm/yyyy |
| Boolean | Boolean | '1'/'0' ou true/false |
| Currency | Number | Precisao de 2 casas |

---

## PARTE 3: Arquitetura da Implementacao Web

### 3.1 Visao Geral

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           NAVEGADOR (Frontend)                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────┐                                                   │
│  │  sag-events.js   │  <- Ja implementado (Fase 1)                      │
│  │  - Captura DOM   │                                                   │
│  │  - Dispara PLSAG │                                                   │
│  └────────┬─────────┘                                                   │
│           │                                                              │
│           v                                                              │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    plsag-interpreter.js (NOVO)                    │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐   │   │
│  │  │   Parser    │  │  Template   │  │      Executor           │   │   │
│  │  │ Tokenizacao │->│ Substituicao│->│ - Client-side handlers  │   │   │
│  │  │ Regra 8char │  │ {DG-Campo}  │  │ - Server-side calls     │   │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│           │                                                              │
│           v                                                              │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    plsag-commands.js (NOVO)                       │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐          │   │
│  │  │CE/CN/CS│ │VA/VP/PU│ │MA/MC/ME│ │IF/ELSE │ │   EX   │          │   │
│  │  │ Campo  │ │Variavel│ │Mensagem│ │Controle│ │Especial│          │   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘          │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│           │                                                              │
└───────────│──────────────────────────────────────────────────────────────┘
            │ (AJAX/Fetch - para comandos server-side)
            v
┌─────────────────────────────────────────────────────────────────────────┐
│                           SERVIDOR (Backend)                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    PlsagController.cs (NOVO)                      │   │
│  │  POST /api/plsag/query    - Executa queries (QY, QN)             │   │
│  │  POST /api/plsag/save     - Grava dados (DG, DM)                 │   │
│  │  POST /api/plsag/execute  - Comandos EX                          │   │
│  │  POST /api/plsag/procedure - Stored procedures                   │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│           │                                                              │
│           v                                                              │
│  ┌──────────────────┐                                                   │
│  │   SQL Server     │                                                   │
│  │   Dados SAG      │                                                   │
│  └──────────────────┘                                                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Componentes a Implementar

#### 3.2.1 plsag-interpreter.js

Modulo principal do interpretador:

```javascript
/**
 * PLSAG Interpreter - Interpretador de instrucoes PLSAG para Web
 *
 * Responsabilidades:
 * - Parser de instrucoes (tokenizacao, regra 8 caracteres)
 * - Substituicao de templates {TIPO-CAMPO}
 * - Execucao de instrucoes (client e server-side)
 * - Controle de fluxo (IF/ELSE/FINA, WH/FINH)
 */
const PlsagInterpreter = (function() {
    'use strict';

    /**
     * Contexto de execucao (alinhado com AI_SPECIFICATION.md)
     *
     * Baseado na interface TypeScript ExecutionContext definida
     * na especificacao formal do PL/SAG.
     */
    const context = {
        // === DADOS DO FORMULARIO ===
        formData: {},              // Campos do formulario atual
        tableName: '',             // Nome da tabela (CodiTabe)
        recordId: null,            // ID do registro atual

        // === VARIAVEIS PLSAG ===
        variables: {
            // Variaveis tipadas por faixa
            integers: {},          // VA-INTE0001 a VA-INTE0020
            floats: {},            // VA-FLOA0001 a VA-FLOA0020
            strings: {},           // VA-TEXT0001 a VA-TEXT0020
            dates: {},             // VA-DATA0001 a VA-DATA0020
            // Variaveis customizadas (definidas pelo usuario)
            custom: {}
        },

        // === VARIAVEIS DE SISTEMA ===
        system: {
            // Estado do formulario
            'INSERIND': false,     // Modo insercao
            'ALTERIND': false,     // Modo alteracao
            'VISUALIZ': false,     // Modo visualizacao
            // Contexto de sessao
            'CODIPESS': null,      // Codigo da pessoa
            'CODIEMPR': null,      // Codigo da empresa
            'CODIFILI': null,      // Codigo da filial
            'CODIUSUA': null,      // Codigo do usuario
            'NOMEUSU': '',         // Nome do usuario
            // Temporais
            'DATAATUA': null,      // Data atual
            'HORAATUA': null,      // Hora atual
            'DATAHORA': null,      // DateTime combinado
            'MESAATUA': null,      // Mes atual
            'ANOAATUA': null,      // Ano atual
            // Contexto de tabela
            'CODITABE': null,      // Codigo da tabela
            'NOMETABE': '',        // Nome da tabela
            'REGISTRO': null,      // Numero do registro
            'ULTIMOID': null       // Ultimo ID inserido
        },

        // === RESULTADOS DE QUERIES ===
        queryResults: {},          // {queryName: {campo: valor, ...}}
        queryMultiResults: {},     // {queryName: [{...}, {...}]}

        // === ESTADO DE CONTROLE DE FLUXO ===
        control: {
            shouldStop: false,     // PA (pare/break) foi chamado
            returnValue: null,     // Valor de retorno
            ifStateStack: [],      // Pilha de estados IF
            currentIfState: 'NORMAL', // NORMAL, IN_IF_TRUE, IN_IF_FALSE, IN_ELSE
            loopStack: [],         // Pilha de loops WH
            errorState: null       // Ultimo erro
        },

        // === METADADOS ===
        meta: {
            eventType: '',         // Tipo do evento (OnExit, OnClick, etc.)
            triggerField: '',      // Campo que disparou
            triggerValue: '',      // Valor no momento do disparo
            executionId: '',       // ID unico da execucao (para debug)
            startTime: null        // Timestamp de inicio
        }
    };

    /**
     * Executa uma lista de instrucoes PLSAG
     * @param {string} instructions - Instrucoes separadas por ";"
     * @param {Object} eventContext - Contexto do evento (campo, valor, etc.)
     * @returns {Promise<Object>} Resultado da execucao
     */
    async function execute(instructions, eventContext) {
        // Implementacao...
    }

    /**
     * Tokeniza instrucoes em array
     * @param {string} instructions - String de instrucoes
     * @returns {Array<Object>} Array de tokens
     */
    function tokenize(instructions) {
        // Implementacao...
    }

    /**
     * Substitui templates {TIPO-CAMPO} pelos valores
     * @param {string} text - Texto com templates
     * @returns {string} Texto com valores substituidos
     */
    function substituteTemplates(text) {
        // Implementacao...
    }

    /**
     * Executa uma instrucao individual
     * @param {Object} token - Token da instrucao
     * @returns {Promise<any>} Resultado
     */
    async function executeInstruction(token) {
        // Implementacao...
    }

    // API Publica
    return {
        execute,
        getContext: () => ({ ...context }),
        setSystemVar: (name, value) => { context.system[name] = value; },
        getVariable: (name) => context.variables.custom[name],
        setVariable: (name, value) => { context.variables.custom[name] = value; }
    };
})();
```

#### 3.2.2 plsag-commands.js

Handlers para cada tipo de comando:

```javascript
/**
 * PLSAG Commands - Handlers de comandos PLSAG
 */
const PlsagCommands = (function() {
    'use strict';

    // ============ COMANDOS DE CAMPO ============

    const fieldCommands = {
        /**
         * CE - Campo Enable (habilita campo)
         */
        CE: function(fieldName) {
            const element = findField(fieldName);
            if (element) {
                element.disabled = false;
                element.classList.remove('disabled');
            }
        },

        /**
         * CN - Campo Disable (desabilita campo)
         */
        CN: function(fieldName) {
            const element = findField(fieldName);
            if (element) {
                element.disabled = true;
                element.classList.add('disabled');
            }
        },

        /**
         * CS - Campo Set (define valor)
         */
        CS: function(fieldName, value) {
            const element = findField(fieldName);
            if (element) {
                element.value = value;
                // Dispara evento change para atualizar bindings
                element.dispatchEvent(new Event('change', { bubbles: true }));
            }
        },

        /**
         * CM - Campo Mostra (torna visivel)
         */
        CM: function(fieldName) {
            const container = findFieldContainer(fieldName);
            if (container) {
                container.style.display = '';
                container.classList.remove('hidden');
            }
        },

        /**
         * CT - Campo Tira (esconde)
         */
        CT: function(fieldName) {
            const container = findFieldContainer(fieldName);
            if (container) {
                container.style.display = 'none';
                container.classList.add('hidden');
            }
        },

        /**
         * CF - Campo Foco
         */
        CF: function(fieldName) {
            const element = findField(fieldName);
            if (element) {
                element.focus();
            }
        }
    };

    // ============ COMANDOS DE VARIAVEL ============

    const variableCommands = {
        /**
         * VA - Variable Assign
         */
        VA: function(varName, value, context) {
            context.variables.custom[varName.trim()] = value;
        },

        /**
         * VP - Variable Persistent
         */
        VP: function(varName, value, context) {
            const name = varName.trim();
            context.variables.custom[name] = value;
            // Persiste em sessionStorage
            sessionStorage.setItem(`plsag_${name}`, JSON.stringify(value));
        },

        /**
         * PU - Purge (limpa variavel)
         */
        PU: function(varName, context) {
            const name = varName.trim();
            delete context.variables.custom[name];
            sessionStorage.removeItem(`plsag_${name}`);
        }
    };

    // ============ COMANDOS DE MENSAGEM ============

    const messageCommands = {
        /**
         * MA - Message Alert
         */
        MA: async function(identifier, text) {
            return new Promise(resolve => {
                showModal('alert', text, resolve);
            });
        },

        /**
         * MC - Message Confirm
         */
        MC: async function(identifier, text) {
            return new Promise(resolve => {
                showModal('confirm', text, (result) => {
                    resolve(result ? 'S' : 'N');
                });
            });
        },

        /**
         * ME - Message Error
         */
        ME: async function(identifier, text) {
            return new Promise(resolve => {
                showModal('error', text, resolve);
            });
        },

        /**
         * MI - Message Info
         */
        MI: async function(identifier, text) {
            return new Promise(resolve => {
                showModal('info', text, resolve);
            });
        }
    };

    // ============ COMANDOS DE QUERY (Server-side) ============

    const queryCommands = {
        /**
         * QY - Query Yes (executa query simples)
         */
        QY: async function(queryName, sql, context) {
            const response = await fetch('/api/plsag/query', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ queryName, sql, type: 'single' })
            });
            const result = await response.json();
            context.queryResults[queryName.trim()] = result.data;
            return result;
        },

        /**
         * QN - Query N-lines (multi-registro)
         */
        QN: async function(queryName, sql, context) {
            const response = await fetch('/api/plsag/query', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ queryName, sql, type: 'multi' })
            });
            const result = await response.json();
            context.queryResults[queryName.trim()] = result.data;
            return result;
        }
    };

    // ============ COMANDOS ESPECIAIS EX ============
    //
    // ATENCAO SEGURANCA: Comandos que executam SQL (EX-SQL, EX-DTBCADA, EX-DTBGENE)
    // NAO devem enviar SQL bruto do frontend. O SQL deve ser:
    // 1. Armazenado no banco (tabela SISTCAMP) e referenciado por ID
    // 2. Reconstruido/validado no backend antes da execucao
    // 3. Ou executado 100% no backend via interpretador server-side
    //

    const exCommands = {
        'FECHFORM': function() {
            window.close();
            // Fallback para navegacao
            if (!window.closed) {
                window.history.back();
            }
        },

        'GRAVAFOR': async function(context) {
            // Dispara submit do formulario
            const form = document.getElementById('dynamicForm');
            if (form) {
                form.dispatchEvent(new Event('submit', { bubbles: true }));
            }
        },

        'LIMPAFOR': function() {
            const form = document.getElementById('dynamicForm');
            if (form) {
                form.reset();
            }
        },

        'ATUAFORM': function() {
            window.location.reload();
        },

        // ⚠️ COMANDOS SQL - DEVEM SER EXECUTADOS NO BACKEND
        // O frontend NAO deve enviar SQL bruto. Em vez disso:
        // - Envia o ID do comando/instrucao
        // - Backend busca o SQL original no banco
        // - Backend valida e executa com parametros sanitizados

        'SQL-----': async function(commandId, params, context) {
            // SEGURO: Envia apenas ID do comando e parametros
            const response = await fetch('/api/plsag/execute-sql', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    commandId: commandId,        // ID da instrucao no banco
                    codiTabe: context.tableName, // Contexto da tabela
                    codiCamp: context.fieldId,   // Campo que disparou
                    params: params               // Valores substituidos (ja sanitizados)
                })
            });
            return await response.json();
        },

        'DTBCADA': async function(commandId, params, context) {
            // Executa SQL no banco DtbCada (cadastros)
            return await exCommands['SQL-----'](commandId, params, {
                ...context,
                database: 'DTBCADA'
            });
        },

        'DTBGENE': async function(commandId, params, context) {
            // Executa SQL no banco DtbGene (geral)
            return await exCommands['SQL-----'](commandId, params, {
                ...context,
                database: 'DTBGENE'
            });
        }
    };

    // ============ FUNCOES AUXILIARES ============

    function findField(fieldName) {
        const name = fieldName.trim();
        return document.querySelector(`[name="${name}"]`) ||
               document.querySelector(`[data-sag-nomecamp="${name}"]`) ||
               document.getElementById(`field_${name}`);
    }

    function findFieldContainer(fieldName) {
        const field = findField(fieldName);
        return field?.closest('.field-row-single, .field-row-multi, .form-group');
    }

    function showModal(type, message, callback) {
        // Implementacao de modal customizado
        // Por enquanto usa alert/confirm nativos
        if (type === 'confirm') {
            callback(confirm(message));
        } else {
            alert(message);
            callback(true);
        }
    }

    // API Publica
    return {
        field: fieldCommands,
        variable: variableCommands,
        message: messageCommands,
        query: queryCommands,
        ex: exCommands,
        findField,
        findFieldContainer
    };
})();
```

#### 3.2.3 PlsagController.cs (Backend)

> **PRINCIPIO DE SEGURANCA:** O frontend NUNCA envia SQL bruto. Em vez disso:
> 1. O frontend envia IDs de comandos/queries (referencia ao banco)
> 2. O backend busca o SQL original na tabela SISTCAMP
> 3. O backend substitui templates e valida antes de executar
> 4. Parametros sao sanitizados usando queries parametrizadas

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Dapper;

namespace SagPoc.Web.Controllers;

/// <summary>
/// Controller para execucao de comandos PLSAG server-side
/// SEGURO: Nao aceita SQL bruto do frontend
/// </summary>
[Route("api/plsag")]
[ApiController]
public class PlsagController : ControllerBase
{
    private readonly string _connectionString;
    private readonly ILogger<PlsagController> _logger;

    public PlsagController(IConfiguration configuration, ILogger<PlsagController> logger)
    {
        _connectionString = configuration.GetConnectionString("SagDb")
            ?? throw new InvalidOperationException("Connection string not found");
        _logger = logger;
    }

    /// <summary>
    /// Executa query PLSAG (QY, QN)
    /// SEGURO: Busca SQL do banco, nao aceita SQL do frontend
    /// </summary>
    [HttpPost("query")]
    public async Task<IActionResult> ExecuteQuery([FromBody] QueryRequest request)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            // SEGURO: Busca instrucao PLSAG do banco de dados
            var instruction = await GetPlsagInstruction(
                connection, request.CodiTabe, request.CodiCamp, request.QueryName);

            if (instruction == null)
            {
                return BadRequest(new { error = "Instrucao PLSAG nao encontrada" });
            }

            // Substitui templates {TIPO-CAMPO} com valores parametrizados
            var (sql, parameters) = ProcessPlsagInstruction(instruction, request.Params);

            // Valida SQL processado
            if (!IsValidPlsagQuery(sql))
            {
                _logger.LogWarning("SQL bloqueado: {Sql}", sql);
                return BadRequest(new { error = "SQL invalido ou nao permitido" });
            }

            // Executa com parametros (previne SQL injection)
            if (request.Type == "single")
            {
                var result = await connection.QueryFirstOrDefaultAsync<dynamic>(sql, parameters);
                return Ok(new { success = true, data = result });
            }
            else
            {
                var results = await connection.QueryAsync<dynamic>(sql, parameters);
                return Ok(new { success = true, data = results.ToList() });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar query PLSAG");
            return StatusCode(500, new { error = "Erro interno ao executar query" });
        }
    }

    /// <summary>
    /// Executa SQL de comandos EX (EX-SQL, EX-DTBCADA, EX-DTBGENE)
    /// SEGURO: SQL vem do banco, nao do frontend
    /// </summary>
    [HttpPost("execute-sql")]
    public async Task<IActionResult> ExecuteSql([FromBody] ExecuteSqlRequest request)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            // SEGURO: Busca SQL original do banco usando o commandId
            var instruction = await GetPlsagInstruction(
                connection, request.CodiTabe, request.CodiCamp, request.CommandId);

            if (instruction == null)
            {
                return BadRequest(new { error = "Comando SQL nao encontrado" });
            }

            // Processa e valida
            var (sql, parameters) = ProcessPlsagInstruction(instruction, request.Params);

            // Audit log
            _logger.LogInformation(
                "PLSAG SQL executado: CodiTabe={CodiTabe}, CodiCamp={CodiCamp}, User={User}",
                request.CodiTabe, request.CodiCamp, User.Identity?.Name ?? "anonimo");

            var rowsAffected = await connection.ExecuteAsync(sql, parameters);
            return Ok(new { success = true, rowsAffected });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar SQL PLSAG");
            return StatusCode(500, new { error = "Erro interno ao executar SQL" });
        }
    }

    /// <summary>
    /// Grava dados PLSAG (DG, DM) - operacoes de INSERT/UPDATE
    /// </summary>
    [HttpPost("save")]
    public async Task<IActionResult> ExecuteSave([FromBody] SaveRequest request)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            // Constroi SQL de INSERT/UPDATE baseado nos campos enviados
            var sql = BuildSaveSql(request.TableName, request.Fields, request.RecordId);
            var parameters = new DynamicParameters(request.Fields);

            var rowsAffected = await connection.ExecuteAsync(sql, parameters);
            return Ok(new { success = true, rowsAffected });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao gravar dados PLSAG");
            return StatusCode(500, new { error = "Erro interno ao gravar dados" });
        }
    }

    /// <summary>
    /// Busca instrucao PLSAG do banco de dados
    /// </summary>
    private async Task<string?> GetPlsagInstruction(
        SqlConnection connection, int codiTabe, int? codiCamp, string? instructionId)
    {
        // Busca na tabela SISTCAMP a instrucao original
        var sql = @"
            SELECT ExprCamp
            FROM SISTCAMP
            WHERE CodiTabe = @CodiTabe
              AND (@CodiCamp IS NULL OR CodiCamp = @CodiCamp)
              AND (@InstructionId IS NULL OR NomeCamp = @InstructionId)";

        return await connection.QueryFirstOrDefaultAsync<string>(sql, new {
            CodiTabe = codiTabe,
            CodiCamp = codiCamp,
            InstructionId = instructionId
        });
    }

    /// <summary>
    /// Processa instrucao PLSAG substituindo templates
    /// Retorna SQL com parametros nomeados (previne injection)
    /// </summary>
    private (string sql, DynamicParameters parameters) ProcessPlsagInstruction(
        string instruction, Dictionary<string, object>? inputParams)
    {
        var parameters = new DynamicParameters();
        var sql = instruction;

        if (inputParams != null)
        {
            foreach (var (key, value) in inputParams)
            {
                // Substitui {DG-Campo}, {VA-INTE0001}, etc. por parametros
                var template = $"{{{key}}}";
                var paramName = $"@p_{key.Replace("-", "_")}";

                if (sql.Contains(template))
                {
                    sql = sql.Replace(template, paramName);
                    parameters.Add(paramName, value);
                }
            }
        }

        return (sql, parameters);
    }

    /// <summary>
    /// Constroi SQL de INSERT ou UPDATE
    /// </summary>
    private string BuildSaveSql(string tableName, Dictionary<string, object> fields, int? recordId)
    {
        // Valida nome da tabela (whitelist)
        if (!IsValidTableName(tableName))
        {
            throw new ArgumentException("Nome de tabela invalido");
        }

        if (recordId.HasValue)
        {
            // UPDATE
            var setClauses = string.Join(", ", fields.Keys.Select(k => $"{k} = @{k}"));
            return $"UPDATE {tableName} SET {setClauses} WHERE Id = @RecordId";
        }
        else
        {
            // INSERT
            var columns = string.Join(", ", fields.Keys);
            var values = string.Join(", ", fields.Keys.Select(k => $"@{k}"));
            return $"INSERT INTO {tableName} ({columns}) VALUES ({values})";
        }
    }

    private bool IsValidTableName(string tableName)
    {
        // Whitelist de tabelas permitidas (carregar do banco ou config)
        var allowedTables = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "CADAPESS", "CADAPROD", "CADAEMPR", "CADAFILI", // etc.
        };
        return allowedTables.Contains(tableName);
    }

    private bool IsValidPlsagQuery(string sql)
    {
        var sqlUpper = sql.ToUpper();

        // Bloqueia comandos perigosos SEMPRE
        var alwaysBlocked = new[] { "DROP ", "TRUNCATE ", "ALTER ", "CREATE ", "--", "/*", "xp_", "sp_" };
        if (alwaysBlocked.Any(cmd => sqlUpper.Contains(cmd)))
        {
            return false;
        }

        return true;
    }
}

// DTOs - Nenhum aceita SQL bruto do frontend

public class QueryRequest
{
    public int CodiTabe { get; set; }
    public int? CodiCamp { get; set; }
    public string? QueryName { get; set; }
    public string Type { get; set; } = "single";
    public Dictionary<string, object>? Params { get; set; }  // Valores para substituir templates
}

public class ExecuteSqlRequest
{
    public int CodiTabe { get; set; }
    public int? CodiCamp { get; set; }
    public string CommandId { get; set; } = "";
    public string? Database { get; set; }  // DTBCADA, DTBGENE
    public Dictionary<string, object>? Params { get; set; }
}

public class SaveRequest
{
    public string TableName { get; set; } = "";
    public int? RecordId { get; set; }  // null = INSERT, valor = UPDATE
    public Dictionary<string, object> Fields { get; set; } = new();
}
```

---

## PARTE 4: Integracao com Sistema de Eventos

### 4.1 Modificacoes em sag-events.js

O sistema de eventos (Fase 1) sera modificado para chamar o interpretador:

```javascript
// Em fireFieldEvent() - linha 185-186
async function fireFieldEvent(eventType, fieldName, codiCamp, instructions, domEvent) {
    const eventInfo = {
        type: eventType,
        field: fieldName,
        codiCamp: codiCamp,
        value: getElementValue(domEvent.target),
        instructions: instructions,
        timestamp: new Date().toISOString()
    };

    console.log(`[SagEvents] Campo ${fieldName} disparou ${eventType}:`, eventInfo);

    // Emite evento customizado
    document.dispatchEvent(new CustomEvent('sag:field-event', {
        detail: eventInfo
    }));

    // FASE 2: Executa instrucoes PLSAG
    if (instructions && instructions.trim()) {
        try {
            const result = await PlsagInterpreter.execute(instructions, {
                type: 'field',
                fieldName: fieldName,
                codiCamp: codiCamp,
                fieldValue: eventInfo.value,
                eventType: eventType
            });

            console.log(`[SagEvents] PLSAG executado:`, result);
        } catch (error) {
            console.error(`[SagEvents] Erro PLSAG:`, error);
        }
    }
}

// Em fireFormEvent() - linha 206-207
async function fireFormEvent(eventType, instructions) {
    const eventInfo = {
        type: eventType,
        instructions: instructions,
        timestamp: new Date().toISOString()
    };

    console.log(`[SagEvents] Form disparou ${eventType}:`, eventInfo);

    // Emite evento customizado
    document.dispatchEvent(new CustomEvent('sag:form-event', {
        detail: eventInfo
    }));

    // FASE 2: Executa instrucoes PLSAG
    if (instructions && instructions.trim()) {
        try {
            const result = await PlsagInterpreter.execute(instructions, {
                type: 'form',
                eventType: eventType,
                formData: collectFormData()
            });

            console.log(`[SagEvents] PLSAG executado:`, result);
        } catch (error) {
            console.error(`[SagEvents] Erro PLSAG:`, error);
        }
    }
}
```

### 4.2 Ordem de Carregamento dos Scripts

```html
<!-- Em _Layout.cshtml ou Render.cshtml -->
<script src="~/js/plsag-commands.js"></script>
<script src="~/js/plsag-interpreter.js"></script>
<script src="~/js/sag-events.js"></script>
```

---

## PARTE 5: Passo a Passo de Implementacao

### 5.1 Etapas de Desenvolvimento

```
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 1: Core do Interpretador                                  │
│  - Parser de instrucoes (tokenizacao)                           │
│  - Regra dos 8 caracteres                                        │
│  - Substituicao de templates basica                              │
│  Estimativa: Modulo base funcional                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 2: Comandos de Campo (Client-side)                        │
│  - CE, CN (habilita/desabilita)                                  │
│  - CM, CT (mostra/esconde)                                       │
│  - CS, CV (seta valor)                                           │
│  - CF (foco)                                                     │
│  Estimativa: Manipulacao de campos funcional                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 3: Sistema de Variaveis                                   │
│  - VA, VP, PU                                                    │
│  - Variaveis de sistema                                          │
│  - Faixas de variaveis (INTE, FLOA, TEXT, DATA)                 │
│  Estimativa: Variaveis funcionais                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 4: Comandos de Mensagem                                   │
│  - MA, MC, ME, MI, MP                                            │
│  - Modais customizados                                           │
│  Estimativa: Mensagens funcionais                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 5: Integracao sag-events.js                               │
│  - Modificar fireFieldEvent                                      │
│  - Modificar fireFormEvent                                       │
│  - Testes de integracao                                          │
│  Estimativa: Eventos disparando PLSAG                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 6: API Backend                                            │
│  - PlsagController.cs                                            │
│  - Endpoints query, save, execute                                │
│  - Validacao de seguranca                                        │
│  Estimativa: Backend pronto                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 7: Comandos de Query                                      │
│  - QY, QN (leitura)                                              │
│  - QD, QM (delete/update)                                        │
│  - Armazenamento de resultados                                   │
│  Estimativa: Queries funcionais                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 8: Comandos de Gravacao                                   │
│  - DG, DM (gravacao simples)                                     │
│  - D2, D3 (gravacao multipla)                                    │
│  Estimativa: Gravacao funcional                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 9: Controle de Fluxo                                      │
│  - IF/ELSE/FINA                                                  │
│  - WH/FINH/PA                                                    │
│  - Blocos aninhados                                              │
│  Estimativa: Condicionais e loops funcionais                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 10: Comandos EX                                           │
│  - Implementar comandos EX mais usados                           │
│  - FECHFORM, GRAVAFOR, LIMPAFOR, ATUAFORM                       │
│  - SQL, ABRETELA                                                 │
│  Estimativa: Comandos especiais principais                       │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Checklist de Implementacao

```
[ ] ETAPA 1: Core do Interpretador
    [ ] Funcao tokenize() implementada
    [ ] Regra 8 caracteres funcionando
    [ ] Separacao por ";" funcionando
    [ ] Funcao substituteTemplates() basica
    [ ] Testes unitarios do parser

[ ] ETAPA 2: Comandos de Campo
    [ ] CE - Campo Enable
    [ ] CN - Campo Disable
    [ ] CM - Campo Mostra
    [ ] CT - Campo Tira
    [ ] CS - Campo Set
    [ ] CV - Campo Valor
    [ ] CF - Campo Foco
    [ ] Testes de manipulacao de campos

[ ] ETAPA 3: Sistema de Variaveis
    [ ] VA - Variable Assign
    [ ] VP - Variable Persistent
    [ ] PU - Purge
    [ ] Variaveis de sistema (INSERIND, etc.)
    [ ] Faixas INTE, FLOA, TEXT, DATA
    [ ] Testes de variaveis

[ ] ETAPA 4: Comandos de Mensagem
    [ ] MA - Message Alert
    [ ] MC - Message Confirm
    [ ] ME - Message Error
    [ ] MI - Message Info
    [ ] MP - Message Prompt
    [ ] Modal customizado (opcional)

[ ] ETAPA 5: Integracao sag-events.js
    [ ] fireFieldEvent modificado
    [ ] fireFormEvent modificado
    [ ] Debug popup atualizado
    [ ] Testes de integracao

[ ] ETAPA 6: API Backend
    [ ] PlsagController.cs criado
    [ ] POST /api/plsag/query
    [ ] POST /api/plsag/save
    [ ] POST /api/plsag/execute
    [ ] Validacao de seguranca SQL
    [ ] Testes de API

[ ] ETAPA 7: Comandos de Query
    [ ] QY - Query Yes (single)
    [ ] QN - Query N-lines (multi)
    [ ] QD - Query Delete
    [ ] QM - Query Modify
    [ ] Armazenamento queryResults
    [ ] Templates {QY-*} funcionando

[ ] ETAPA 8: Comandos de Gravacao
    [ ] DG - Data Grava
    [ ] DM - Data Mestre
    [ ] D2 - Data 2
    [ ] D3 - Data 3
    [ ] Templates {DG-*}, {DM-*}

[ ] ETAPA 9: Controle de Fluxo
    [ ] IF-INIC condicional
    [ ] ELSE alternativo
    [ ] FINA finalizacao
    [ ] WH loop while
    [ ] FINH fim while
    [ ] PA pare (break)
    [ ] Blocos aninhados

[ ] ETAPA 10: Comandos EX
    [ ] EX-FECHFORM
    [ ] EX-GRAVAFOR
    [ ] EX-LIMPAFOR
    [ ] EX-ATUAFORM
    [ ] EX-SQL-----
    [ ] EX-ABRETELA
    [ ] Outros conforme necessidade
```

---

## PARTE 6: Exemplos de Uso

### 6.1 Exemplo: OnExit com Validacao

**Instrucoes PLSAG (do banco):**
```
IF-CodiProd-{DG-CodiProd}='';
MA-ERR-----Codigo do produto e obrigatorio!;
CF-CodiProd;
FINA;
QY-PRODUTO-SELECT DESCPROD FROM PRODUTO WHERE CODIPROD = {DG-CodiProd};
CS-DescProd-{QY-PRODUTO-DESCPROD}
```

**Execucao Web:**
```javascript
// 1. Tokenizacao
tokens = [
    { prefix: 'IF', identifier: 'CodiProd', param: "{DG-CodiProd}=''" },
    { prefix: 'MA', identifier: 'ERR-----', param: "Codigo do produto e obrigatorio!" },
    { prefix: 'CF', identifier: 'CodiProd', param: "" },
    { prefix: 'FINA', identifier: '', param: '' },
    { prefix: 'QY', identifier: 'PRODUTO-', param: "SELECT DESCPROD..." },
    { prefix: 'CS', identifier: 'DescProd', param: "{QY-PRODUTO-DESCPROD}" }
]

// 2. Execucao
// IF: Verifica se CodiProd esta vazio
// MA: Exibe alerta
// CF: Move foco para CodiProd
// FINA: Fim do IF
// QY: Busca descricao no banco (chamada API)
// CS: Seta campo DescProd com resultado
```

### 6.2 Exemplo: Calculo Automatico

**Instrucoes PLSAG:**
```
VA-TOTAL---{DG-Quanti} * {DG-ValoUnit};
CS-ValoTota-{VA-TOTAL}
```

**Execucao Web:**
```javascript
// Substitui templates
// {DG-Quanti} -> "10"
// {DG-ValoUnit} -> "25.50"
// Calcula: 10 * 25.50 = 255.00
// Seta campo ValoTota = "255.00"
```

### 6.3 Exemplo: Abertura de Tela

**Instrucoes PLSAG:**
```
EX-ABRETELA-CONSULTA_CLIENTE;
VA-CODCLI--{DG-CodiClie};
CS-NomeClie-{QY-CLIENTE-NOMECLIE}
```

**Execucao Web:**
```javascript
// Abre modal/popup com formulario CONSULTA_CLIENTE
// Atribui variavel CODCLI
// Apos selecao, seta campo NomeClie
```

---

## PARTE 7: Consideracoes de Seguranca

### 7.1 Validacao de SQL

Todo SQL executado via PLSAG deve ser validado:

```csharp
// Comandos bloqueados por padrao
var blockedCommands = new[] {
    "DROP ", "TRUNCATE ", "ALTER ", "CREATE ", "GRANT ", "REVOKE ",
    "xp_", "sp_", "EXEC ", "EXECUTE "
};

// Permite apenas SELECT, INSERT, UPDATE, DELETE controlados
var allowedPatterns = new[] {
    @"^SELECT\s+",
    @"^INSERT\s+INTO\s+",
    @"^UPDATE\s+\w+\s+SET\s+",
    @"^DELETE\s+FROM\s+"
};
```

### 7.2 Sanitizacao de Entradas

Templates devem ser sanitizados antes de substituicao:

```javascript
function sanitizeValue(value) {
    if (typeof value !== 'string') return value;

    // Remove caracteres perigosos
    return value
        .replace(/'/g, "''")  // Escape aspas simples
        .replace(/;/g, '')     // Remove ponto-virgula
        .replace(/--/g, '');   // Remove comentarios SQL
}
```

### 7.3 Auditoria

Todas as execucoes PLSAG devem ser logadas:

```csharp
_logger.LogInformation(
    "PLSAG Executado: {Command} por {User} em {Timestamp}",
    command, User.Identity?.Name, DateTime.UtcNow
);
```

---

## PARTE 8: Testes e Validacao

### 8.1 Testes Unitarios (JavaScript)

```javascript
// Testes do Parser
describe('PlsagInterpreter.tokenize', () => {
    it('should parse simple command', () => {
        const result = tokenize('CE-CodiProd');
        expect(result[0].prefix).toBe('CE');
        expect(result[0].identifier).toBe('CodiProd');
    });

    it('should handle 8-char rule', () => {
        const result = tokenize('CE-Prod');
        expect(result[0].identifier).toBe('Prod    '); // 4 + 4 espacos
    });

    it('should split by semicolon', () => {
        const result = tokenize('CE-Campo1;CN-Campo2');
        expect(result.length).toBe(2);
    });
});

// Testes de Substituicao
describe('PlsagInterpreter.substituteTemplates', () => {
    it('should replace {DG-Campo}', () => {
        context.formData.CodiProd = '1001';
        const result = substituteTemplates('{DG-CodiProd}');
        expect(result).toBe('1001');
    });
});
```

### 8.2 Testes de Integracao

```javascript
// Teste de fluxo completo
describe('PLSAG Integration', () => {
    it('should execute OnExit validation', async () => {
        // Simula campo vazio
        document.getElementById('field_CodiProd').value = '';

        // Executa PLSAG
        const instructions = "IF-CodiProd-{DG-CodiProd}='';MA-ERR-----Obrigatorio!;FINA";
        await PlsagInterpreter.execute(instructions, { type: 'field' });

        // Verifica se alerta foi exibido
        expect(alertShown).toBe(true);
    });
});
```

### 8.3 Casos de Teste Canonicos

Baseado na especificacao formal (AI_SPECIFICATION.md), os seguintes casos de teste sao obrigatorios:

#### 8.3.1 Parser - Regra dos 8 Caracteres

```javascript
describe('Parser - 8 Character Rule', () => {
    it('TEST_PARSE_001: Campo com 8 caracteres', () => {
        const result = parse('CE-CodiProd');
        expect(result.identifier).toBe('CodiProd');
    });

    it('TEST_PARSE_002: Campo com menos de 8 caracteres', () => {
        const result = parse('CE-Prod');
        expect(result.identifier).toBe('Prod    '); // padded
    });

    it('TEST_PARSE_003: Campo com espacos no identificador', () => {
        const result = parse('CE-Prod   -');
        expect(result.identifier).toBe('Prod    ');
    });

    it('TEST_PARSE_004: Multiplas instrucoes', () => {
        const results = parseAll('CE-Campo1;CN-Campo2;CS-Campo3-valor');
        expect(results.length).toBe(3);
    });
});
```

#### 8.3.2 Substituicao de Templates

```javascript
describe('Template Substitution', () => {
    it('TEST_SUBST_001: Template DG simples', () => {
        context.formData.CodiProd = '1001';
        const result = substitute('{DG-CodiProd}');
        expect(result).toBe('1001');
    });

    it('TEST_SUBST_002: Template VA variavel', () => {
        context.variables.custom.TOTAL = '250.00';
        const result = substitute('{VA-TOTAL}');
        expect(result).toBe('250.00');
    });

    it('TEST_SUBST_003: Template QY resultado query', () => {
        context.queryResults.PROD = { DESCRI: 'Produto Teste' };
        const result = substitute('{QY-PROD-DESCRI}');
        expect(result).toBe('Produto Teste');
    });

    it('TEST_SUBST_004: Templates multiplos na mesma string', () => {
        context.formData.Quanti = '10';
        context.formData.ValoUnit = '25.00';
        const result = substitute('{DG-Quanti} x {DG-ValoUnit}');
        expect(result).toBe('10 x 25.00');
    });
});
```

#### 8.3.3 Controle de Fluxo IF/ELSE

```javascript
describe('Control Flow - IF/ELSE/FINA', () => {
    it('TEST_IF_001: IF verdadeiro executa bloco', async () => {
        const spy = jest.spyOn(PlsagCommands.field, 'CE');
        await execute("IF-COND----1=1;CE-Campo1;FINA");
        expect(spy).toHaveBeenCalledWith('Campo1');
    });

    it('TEST_IF_002: IF falso pula bloco', async () => {
        const spy = jest.spyOn(PlsagCommands.field, 'CE');
        await execute("IF-COND----1=2;CE-Campo1;FINA");
        expect(spy).not.toHaveBeenCalled();
    });

    it('TEST_IF_003: IF/ELSE executa alternativo', async () => {
        const spyCE = jest.spyOn(PlsagCommands.field, 'CE');
        const spyCN = jest.spyOn(PlsagCommands.field, 'CN');
        await execute("IF-COND----1=2;CE-Campo1;ELSE;CN-Campo1;FINA");
        expect(spyCE).not.toHaveBeenCalled();
        expect(spyCN).toHaveBeenCalledWith('Campo1');
    });

    it('TEST_IF_004: IF aninhado', async () => {
        context.formData.A = 'X';
        context.formData.B = '10';
        await execute(`
            IF-COND1---{DG-A}='X';
                IF-COND2---{DG-B}>5;
                    VA-RESULT--INNER_TRUE;
                ELSE;
                    VA-RESULT--INNER_FALSE;
                FINA;
            FINA
        `);
        expect(context.variables.custom.RESULT).toBe('INNER_TRUE');
    });
});
```

#### 8.3.4 Comandos de Campo

```javascript
describe('Field Commands', () => {
    it('TEST_FIELD_001: CE habilita campo', () => {
        document.body.innerHTML = '<input id="field_Prod" disabled />';
        PlsagCommands.field.CE('Prod');
        expect(document.getElementById('field_Prod').disabled).toBe(false);
    });

    it('TEST_FIELD_002: CN desabilita campo', () => {
        document.body.innerHTML = '<input id="field_Prod" />';
        PlsagCommands.field.CN('Prod');
        expect(document.getElementById('field_Prod').disabled).toBe(true);
    });

    it('TEST_FIELD_003: CS define valor', () => {
        document.body.innerHTML = '<input id="field_Prod" value="" />';
        PlsagCommands.field.CS('Prod', '123');
        expect(document.getElementById('field_Prod').value).toBe('123');
    });
});
```

### 8.4 Comparacao Delphi vs Web

Para cada formulario, comparar:

| Cenario | Resultado Delphi | Resultado Web | Status |
|---------|-----------------|---------------|--------|
| OnExit CodiProd vazio | Alerta + foco | Alerta + foco | OK |
| OnExit CodiProd valido | Busca descricao | Busca descricao | OK |
| BtnCalc click | Calcula total | Calcula total | OK |
| ShowTabe | Inicializa campos | Inicializa campos | OK |

### 8.5 Criterios de Aceitacao

Para considerar a implementacao completa, os seguintes criterios devem ser atendidos:

- [ ] 100% dos testes canonicos passando
- [ ] Compatibilidade verificada com pelo menos 3 formularios reais do SAG
- [ ] Nenhum erro de console durante execucao normal
- [ ] Performance: tempo de parsing < 10ms para instrucoes ate 1000 caracteres
- [ ] Cobertura de codigo > 80% para modulos criticos (parser, executor)

---

## PARTE 9: Incompatibilidades e Limitacoes

Esta secao documenta as diferencas de comportamento entre a implementacao Delphi e a implementacao Web, alem das limitacoes inerentes ao ambiente de navegador.

### 9.1 Comandos Nao Suportados

Os seguintes comandos PLSAG NAO serao implementados na versao web devido a restricoes de seguranca do navegador:

| Comando | Motivo | Alternativa |
|---------|--------|-------------|
| `EX-LEITSER-` | Navegadores nao tem acesso a portas seriais | WebSerial API (experimental, requer HTTPS e permissao) |
| `EX-EXECEXT-` | Execucao de programas externos bloqueada | Nenhuma (restricao de seguranca) |
| `EX-IMPRDIRE` | Impressao direta sem dialogo nao permitida | `window.print()` com dialogo ou geracao de PDF |
| `EX-ARQUIVOS` | Acesso direto ao sistema de arquivos bloqueado | File System Access API ou upload/download |
| `EX-DLL-----` | Chamada de DLLs nao suportada | API backend ou WebAssembly |
| `EX-REGISTWN` | Acesso ao registro do Windows | Nenhuma |

### 9.2 Comandos com Comportamento Diferente

| Comando | Comportamento Delphi | Comportamento Web | Impacto |
|---------|---------------------|-------------------|---------|
| `EX-FECHFORM` | Fecha janela imediatamente | `window.close()` pode ser bloqueado | Usar `history.back()` como fallback |
| `EX-ABRETELA` | Abre janela modal | Abre modal/popup ou nova aba | Comportamento visual diferente |
| `MC-XXXXXXXX` | Dialog modal sincrono | Promise async com modal | Fluxo de codigo precisa ser async |
| `MP-XXXXXXXX` | InputBox sincrono | Prompt async ou modal input | Fluxo de codigo precisa ser async |
| `QY/QN` | Execucao sincrona | Chamada API assincrona | Requer `await` em JS |
| `CF-XXXXXXXX` | Foco imediato garantido | `focus()` pode falhar em certos casos | Navegador pode bloquear foco programatico |

### 9.3 Limitacoes de Ambiente

#### 9.3.1 Execucao Assincrona

No Delphi, comandos como queries e dialogs sao sincronos. Na web, sao assincronos:

```javascript
// Delphi (sincrono)
// QY-PROD----SELECT * FROM PRODUTO WHERE CODI = 1
// CS-Descri--{QY-PROD-DESCRI}

// Web (assincrono) - tratado internamente pelo interpretador
await executeQuery('QY-PROD----...');
await setField('CS-Descri--{QY-PROD-DESCRI}');
```

O interpretador web encapsula essa assincronia, mas o tempo de resposta pode variar.

#### 9.3.2 Limitacoes de UI

| Aspecto | Delphi | Web | Diferenca |
|---------|--------|-----|-----------|
| Hotkeys globais | Suportadas | Limitadas (conflito com navegador) | Ctrl+S, F5, etc. podem nao funcionar |
| Menus de contexto | Nativos | Customizados | Aparencia diferente |
| Drag & Drop | Nativo Windows | HTML5 Drag API | Comportamento levemente diferente |
| Clipboard | Acesso direto | Requer permissao do usuario | Pode falhar silenciosamente |

#### 9.3.3 Restricoes de Seguranca

```
┌─────────────────────────────────────────────────────────────┐
│                    SANDBOX DO NAVEGADOR                      │
├─────────────────────────────────────────────────────────────┤
│ ✗ Sem acesso ao sistema de arquivos local                  │
│ ✗ Sem execucao de programas externos                        │
│ ✗ Sem acesso a hardware (exceto APIs especificas)          │
│ ✗ CORS bloqueia requests para dominios diferentes          │
│ ✓ Todas operacoes server-side via API controlada           │
│ ✓ SQL validado e sanitizado no backend                      │
│ ✓ Autenticacao obrigatoria para operacoes criticas         │
└─────────────────────────────────────────────────────────────┘
```

### 9.4 Estrategia de Fallback

Para comandos nao suportados, o interpretador:

1. **Loga warning** no console com detalhes do comando
2. **Emite evento customizado** `sag:unsupported-command` para tratamento opcional
3. **Continua execucao** (nao bloqueia instrucoes seguintes)
4. **Registra na auditoria** para analise posterior

```javascript
function handleUnsupportedCommand(prefix, identifier, param) {
    console.warn(`[PLSAG] Comando nao suportado: ${prefix}-${identifier}`);

    document.dispatchEvent(new CustomEvent('sag:unsupported-command', {
        detail: { prefix, identifier, param }
    }));

    // Continua execucao
    return { success: false, reason: 'unsupported' };
}
```

### 9.5 Matriz de Compatibilidade

| Categoria | Compatibilidade | Notas |
|-----------|----------------|-------|
| Comandos de Campo (CE/CN/CS/CM/CT/CF/CV) | **100%** | Totalmente suportados |
| Comandos de Variavel (VA/VP/PU) | **100%** | Totalmente suportados |
| Comandos de Mensagem (MA/MC/ME/MI/MP) | **95%** | Modais customizados, async |
| Comandos de Query (QY/QN/QD/QM) | **100%** | Via API backend |
| Comandos de Gravacao (DG/DM/D2/D3) | **100%** | Via API backend |
| Controle de Fluxo (IF/ELSE/FINA/WH) | **100%** | Totalmente suportados |
| Comandos EX (Formulario) | **90%** | Maioria suportada |
| Comandos EX (Sistema) | **40%** | Muitos bloqueados pelo navegador |
| Comandos EX (Impressao) | **70%** | Via PDF, dialogo do navegador |

---

## PARTE 10: Proximos Passos

### 10.1 Apos Aprovacao desta Proposta

1. **Criacao do OpenSpec** - Formalizar requisitos no sistema OpenSpec
2. **Desenvolvimento por Etapas** - Seguir checklist da Parte 5
3. **Testes Incrementais** - Validar cada etapa antes de avancar
4. **Documentacao de Diferencas** - Registrar comportamentos diferentes

### 10.2 Evolucoes Futuras

| Evolucao | Descricao | Prioridade |
|----------|-----------|------------|
| Cache de Queries | Evitar chamadas repetidas ao banco | Media |
| Comandos EX Adicionais | Implementar mais comandos EX | Conforme demanda |
| Debug Avancado | Ferramenta de debug visual | Baixa |
| Performance | Otimizacao para instrucoes longas | Media |

---

## Conclusao

Esta proposta apresenta um caminho claro para implementar o Interpretador PLSAG na plataforma web do SAG. A estrategia de implementacao em etapas permite:

1. **Validar cada componente** antes de avancar
2. **Manter compatibilidade** com instrucoes existentes no banco
3. **Garantir seguranca** atraves de validacao de SQL
4. **Integrar suavemente** com o sistema de eventos ja implementado (Fase 1)

O interpretador web sera capaz de executar a grande maioria das instrucoes PLSAG existentes, com excecao de funcionalidades que dependem de recursos nao disponiveis em navegadores (porta serial, execucao de programas locais, etc.).

---

*Documento gerado em: 2025-12-24*
*Versao: 1.1*
*Status: Aguardando Aprovacao*
*Dependencia: Fase 1 (Sistema de Eventos) - CONCLUIDA*
*Referencias: AI_SPECIFICATION.md (Especificacao Formal PL/SAG)*
