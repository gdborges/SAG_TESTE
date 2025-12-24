# PL/SAG - Especificação Formal para Inteligência Artificial

## 📋 Sumário Executivo

Este documento especifica formalmente a linguagem PL/SAG (Process Language - Sistema de Automação Gerencial), uma DSL interpretada para automação de formulários empresariais. O objetivo é permitir que sistemas de IA compreendam, simulem e reimplementem o PL/SAG em novas plataformas (especialmente web).

### Propósito da Linguagem
- **Domínio:** Automação de processos empresariais via formulários dinâmicos
- **Paradigma:** Declarativo/Imperativo com SQL embutido
- **Execução:** Interpretada, event-driven (eventos de formulário)
- **Integração:** Banco de dados Oracle/SQL Server/Firebird + componentes UI Delphi

---

## 🔤 GRAMÁTICA FORMAL (BNF)

### Estrutura Fundamental

```bnf
<programa>       ::= <instrução>+
<instrução>      ::= <prefixo> "-" <identificador> "-" <parâmetro> <nl>
                   | <bloco-xml>
                   | <comentário>

<prefixo>        ::= <tipo-comando> <modificador>?
<tipo-comando>   ::= "IF" | "WH" | "DG" | "DM" | "D2" | "D3"
                   | "CE" | "CN" | "CS" | "CM" | "CT" | "CA"
                   | "EX" | "QY" | "QD" | "QM" | "QN"
                   | "MA" | "MC" | "ME" | "MI" | "MP" | "MB"
                   | "FO" | "FM" | "IR" | "VA" | "VP" | "PU"
                   | "NF" | "N2" | "LC" | "TI" | "TQ" | "EM"
                   | ... (80+ prefixos)

<modificador>    ::= "D" | "F" | "V" | "C" | "R" | "G" | "A" | "P" | "W" | ...

<identificador>  ::= <char>{8}  # EXATAMENTE 8 caracteres (padding com espaços)
<char>           ::= [A-Za-z0-9_]

<parâmetro>      ::= <sql> | <expressão> | <valor> | <ação> | <bloco-mensagem>

<sql>            ::= "SELECT" ... "FROM" ... ("WHERE" ...)? ("ORDER BY" ...)?
<expressão>      ::= <template> | <operação-aritmética> | <literal>
<template>       ::= "{" <prefixo> "-" <identificador> ("." <campo>)? "}"
                   | "{QY-" <query> "-" <campo> "}"

<bloco-xml>      ::= "<COMPS>" ... "</COMPS>"
<bloco-mensagem> ::= <nl> <texto> <nl>
```

### Regras Sintáticas Críticas

#### 1. **REGRA DOS 8 CARACTERES (ABSOLUTA)**

```
FORMATO: XX-IIIIIIII-PARÂMETRO
         ││ │      │
         ││ │      └─ 8 chars EXATOS (com espaços à direita se < 8)
         ││ └─────── Separador (hífen)
         │└─────────── Modificador opcional
         └──────────── Prefixo (2 chars)
```

**Exemplos Válidos:**
```
DG-CodiPess-SELECT 123 FROM DUAL          ✓ (CodiPess = 8 chars)
VA-INTE0001-100                            ✓ (INTE0001 = 8 chars)
IF-INIC0001-SELECT 1 FROM DUAL             ✓ (INIC0001 = 8 chars)
TQ-DPI     -SELECT 203 FROM DUAL           ✓ (DPI+5 espaços = 8 chars)
EX-MUDADTB_-'DTBCADA'                      ✓ (MUDADTB_ = 8 chars)
```

**Exemplos Inválidos:**
```
DG-Codi-SELECT 123 FROM DUAL               ✗ (Codi = 4 chars)
VA-INTE001-100                             ✗ (INTE001 = 7 chars)
IF-INICIAL001-SELECT 1 FROM DUAL           ✗ (INICIAL001 = 10 chars)
```

#### 2. **Parsing de Linha**

```pascal
// Algoritmo de parsing (baseado no PlusUni.pas linha 3901):
function ParseInstruction(line: string): TInstruction;
begin
  Result.Prefix := Copy(line, 1, 2);        // Posição 1-2: Prefixo
  Result.Modifier := Copy(line, 3, 1);       // Posição 3: Modificador (opcional)
  Result.Identifier := Trim(Copy(line, 4, 8)); // Posição 4-11: Identificador (8 chars)
  Result.Parameter := Copy(line, 13, MaxInt); // Posição 13+: Parâmetro
end;
```

#### 3. **Substituição de Templates**

**Sintaxe:**
```
{PREFIXO-IDENTIFICADOR}         → Retorna valor do campo/variável
{QY-QUERY-CAMPO}                → Retorna campo da query ligada
{QY-QUERY-NumeRegi}             → Retorna número de registros
{LC-LISTA-NUMETOTA}             → Retorna total de itens da lista
{LC-LISTA-NUMESELE}             → Retorna itens selecionados
{VA-INSERIND}                   → Retorna 1 se inserindo, 0 se alterando
```

**Algoritmo de Substituição:**
```
1. ANTES da execução do comando, varrer o parâmetro
2. Para cada {PATTERN} encontrado:
   a. Extrair PREFIXO-IDENTIFICADOR
   b. Buscar valor correspondente no contexto (formulário/variáveis/queries)
   c. Substituir {PATTERN} pelo valor
3. Executar comando com parâmetro substituído
```

---

## 📊 SEMÂNTICA OPERACIONAL

### Modelo de Execução

```
┌──────────────────────────────────────────┐
│  CONTEXTO DE EXECUÇÃO                    │
├──────────────────────────────────────────┤
│ • Formulário Ativo (sgForm)              │
│ • Dataset Cabeçalho (DtsGrav)            │
│ • Dataset Movimento (DtsMov1/2/3)        │
│ • Variáveis (VA/VP/PU)                   │
│ • Queries (QY/QD/QM/QN)                  │
│ • Pilha de Controle (IF/WH)              │
│ • Estado (inserindo/alterando)           │
└──────────────────────────────────────────┘
         ▼
┌──────────────────────────────────────────┐
│  INTERPRETADOR (CampPersExecListInst)    │
├──────────────────────────────────────────┤
│ PARA cada linha em ListaInstruções:      │
│   1. Substituir templates {XXXX}         │
│   2. Parsear PREFIXO-ID-PARAM            │
│   3. Executar ação conforme PREFIXO      │
│   4. Atualizar contexto                  │
│   5. Se ME#, parar execução              │
│   6. Se PA e retorno=0, parar            │
└──────────────────────────────────────────┘
```

### Eventos que Disparam Execução

```
┌─────────────────────────┬──────────────────────────────────┐
│ Evento                  │ Campo PL/SAG Executado           │
├─────────────────────────┼──────────────────────────────────┤
│ OnShow do Form          │ POCATabe.ExecOnShow              │
│ OnExit de Campo         │ POCATabe.ExecSaida (linha do ID) │
│ OnEnter de Campo        │ POCATabe.ExecEntrada (linha)     │
│ OnChange de Campo       │ POCATabe.ExecChange (linha)      │
│ Confirmar (botão OK)    │ POCATabe.ExecConfirma            │
│ Cancelar (botão Cancel) │ POCATabe.ExecCancela             │
│ Timer                   │ POCATabe.TimerInst               │
│ Após voltar de FO       │ Comandos FV-...                  │
└─────────────────────────┴──────────────────────────────────┘
```

---

## 🎯 SEMÂNTICA POR CATEGORIA DE COMANDO

### 1. ESTRUTURAS DE CONTROLE

#### IF - Condicional

**Semântica:**
```
IF-INIC<label>-<condição>   → Se condição ≠ 0, executa bloco
IF-ELSE<label>-<condição>   → Se IF anterior falhou e condição ≠ 0, executa
IF-ELSE<label>-             → Se IF anterior falhou, executa (else incondicional)
IF-FINA<label>              → Fim do bloco
```

**Máquina de Estados:**
```
Estado: {EXECUTANDO, PULANDO, SATISFEITO}

Ao encontrar IF-INIC:
  Se Condição ≠ 0: Estado = EXECUTANDO
  Senão: Estado = PULANDO

Ao encontrar IF-ELSE:
  Se Estado = PULANDO e (sem condição OU condição ≠ 0):
    Estado = EXECUTANDO
  Senão: Estado = SATISFEITO

Ao encontrar IF-FINA:
  Estado = EXECUTANDO (restaura execução normal)
```

**Exemplo Canônico:**
```plsag
IF-INIC0001-SELECT {CS-AtivCarg} FROM DUAL
  CE-NomeCarg-'Ativo'
IF-ELSE0001-SELECT {DG-CodiPess} > 100 FROM DUAL
  CE-NomeCarg-'Pessoa > 100'
IF-ELSE0001-
  CE-NomeCarg-'Padrão'
IF-FINA0001
```

**Equivalente JavaScript:**
```javascript
if (getFieldValue('CS-AtivCarg') != 0) {
  setFieldValue('CE-NomeCarg', 'Ativo');
} else if (getFieldValue('DG-CodiPess') > 100) {
  setFieldValue('CE-NomeCarg', 'Pessoa > 100');
} else {
  setFieldValue('CE-NomeCarg', 'Padrão');
}
```

#### WH - Loop/While

**Semântica:**
```
WH-<id>-SELECT ... FROM ... WHERE ...  → Executa query e itera sobre resultados
  ... instruções ...                   → Executadas para cada registro
WH-<id>-                               → Marca fim do loop
```

**Algoritmo:**
```
1. Executar query do WH
2. Para cada registro do resultado:
   a. Posicionar query no registro atual
   b. Executar todas as instruções entre WH-<id>- e WH-<id>-
   c. Templates {QY-<id>-CAMPO} retornam valores do registro atual
3. Fechar query ao sair do loop
```

**Exemplo Canônico:**
```plsag
WH-NOVOMOV01-SELECT CodiProd, QtdeProd FROM POCAMVES WHERE CodiEsto = {DG-CodiEsto}
  MP-DG-12345678-SELECT 'Produto: '||{QY-NOVOMOV01-CodiProd}||' Qtde: '||{QY-NOVOMOV01-QtdeProd} FROM DUAL
  Processando produto...
WH-NOVOMOV01-
```

**Equivalente JavaScript:**
```javascript
const results = await db.query('SELECT CodiProd, QtdeProd FROM POCAMVES WHERE CodiEsto = ?',
                               [getFieldValue('DG-CodiEsto')]);
for (const row of results) {
  showMessage(`Produto: ${row.CodiProd} Qtde: ${row.QtdeProd}`, 'Processando produto...');
}
```

#### PA - Pare

**Semântica:**
```
PA-<id>-<condição>  → Se condição = 0, PARA execução de toda a lista
```

**Uso:**
```plsag
PA-12345678-SELECT COUNT(*) FROM POCAPESS WHERE CodiPess = {DG-CodiPess}
# Se COUNT(*) = 0, para aqui e não executa o resto
```

---

### 2. MANIPULAÇÃO DE DADOS

#### DG/DM/D2/D3 - Dados Gravados

**Semântica:**
```
DG-<campo>-<expressão>  → Grava no campo do Cabeçalho (DtsGrav)
DM-<campo>-<expressão>  → Grava no campo do Movimento 1 (DtsMov1)
D2-<campo>-<expressão>  → Grava no campo do Movimento 2 (DtsMov2)
D3-<campo>-<expressão>  → Grava no campo do Movimento 3 (DtsMov3)
```

**Algoritmo:**
```
1. Avaliar <expressão> (substituindo templates, executando SQL se necessário)
2. Se formulário em modo INSERT ou EDIT:
   Dataset.FieldByName(<campo>).Value := ResultadoExpressão
3. Senão, ignorar
```

**Diferença DD vs D*:**
```
DG-CodiPess-100  → Só grava se inserindo (padrão)
DDG-CodiPess-100 → SEMPRE grava, mesmo se alterando
```

#### CE/CN/CS/CM/CT/CA - Campos de Formulário

**Semântica:**
```
CE-<campo>-<valor>  → Define valor de campo Editor/Text
CN-<campo>-<valor>  → Define valor de campo Numérico
CS-<campo>-<valor>  → Define valor de campo Sim/Não (0/1)
CM-<campo>-<valor>  → Define valor de campo Memo
CT-<campo>-<valor>  → Define valor de campo Tabela (lookup)
CA-<campo>-<valor>  → Define valor de campo Arquivo (path)
```

**Modificadores:**
```
CED-<campo>-<cond>  → Habilita/Desabilita (0=desabilita, ≠0=habilita)
CEF-<campo>-<cond>  → Foca campo se condição ≠ 0
CEV-<campo>-<cond>  → Torna visível/invisível (0=esconde, ≠0=mostra)
CEC-<campo>-<cor>   → Altera cor do campo
CER-<campo>-<cond>  → Torna ReadOnly se condição ≠ 0
```

**Algoritmo:**
```javascript
function executeCE(field, param, modifier) {
  const component = form.findComponent(field);
  if (!component) return;

  const value = evaluateExpression(param);

  switch(modifier) {
    case '': // Sem modificador: atribui valor
      component.value = value;
      break;
    case 'D': // Disable/Enable
      component.enabled = (value != 0);
      break;
    case 'F': // Focus
      if (value != 0) component.setFocus();
      break;
    case 'V': // Visible
      component.visible = (value != 0);
      break;
    case 'C': // Color
      component.color = value;
      break;
    case 'R': // ReadOnly
      component.readOnly = (value != 0);
      break;
  }
}
```

---

### 3. QUERIES E DATASETS

#### QY - Query Principal

**Ações:**
```
QY-<id>-SELECT ... WHERE ...  → Aplica filtro à query
QY-<id>-ABRE                  → Reabre query com SQL original
QY-<id>-FECH                  → Fecha query
QY-<id>-PRIM                  → Vai ao primeiro registro
QY-<id>-PROX                  → Próximo registro
QY-<id>-ANTE                  → Registro anterior
QY-<id>-ULTI                  → Último registro
QY-<id>-EDIT                  → Entra em modo edição
QY-<id>-INSE                  → Insere novo registro
QY-<id>-POST                  → Grava alterações
QY-<id>-FILTRA(expressão)     → Aplica filtro local
```

**Leitura de Campos:**
```
{QY-<id>-<campo>}      → Retorna valor do campo no registro atual
{QY-<id>-NumeRegi}     → Retorna número total de registros
```

#### QN - Query Nova (Dinâmica)

**Semântica:**
```
QN-<id>-SELECT ...  → Cria query temporária, executa SQL, torna acessível como QY-<id>
QN-<id>-DESTROI     → Destrói a query criada
```

**Uso:**
```plsag
QN-BUSCVALO-SELECT 1 AS VALO, 2 AS DOIS FROM DUAL
VA-INTE0001-{QY-BUSCVALO-VALO}
VA-INTE0002-{QY-BUSCVALO-DOIS}
QN-BUSCVALO-DESTROI
```

---

### 4. MENSAGENS E INTERAÇÃO

#### M* - Mensagens

**Tipos:**
```
MA-<id>-<condição>  → Alerta (msgAviso)
  <texto mensagem>

MC-<id>-<condição>  → Confirmação (Sim/Não) - retorna true/false
  <texto pergunta>

ME#-<id>-<condição> → Erro (PARA execução) - # = beeps (0-9)
  <texto erro>

MI-<id>-<condição>  → Informação (msgOk)
  <texto info>

MP-<id>-<expressão> → Mensagem personalizada (exibe se resultado ≠ '')
  <texto mensagem>
```

**Algoritmo:**
```javascript
function executeMessage(type, id, param, messageLines) {
  const condition = evaluateExpression(param);

  // MA/MC/ME/MI: só exibe se condição = 0 (falso)
  if (['MA', 'MC', 'ME', 'MI'].includes(type) && condition != 0) {
    return;
  }

  // MP: exibe se resultado ≠ ''
  if (type === 'MP' && param === '') {
    return;
  }

  const message = messageLines.join('\n');

  switch(type) {
    case 'MA': showAlert(message); break;
    case 'MC': return confirm(message); // true/false
    case 'ME':
      showError(message);
      throw new ExecutionHalt(); // PARA execução
    case 'MI': showInfo(message); break;
    case 'MP': showCustom(message); break;
  }
}
```

**Mensagens Multi-linha:**
```plsag
MC-NomePess-SELECT {CS-AtivCarg} = 0 FROM DUAL
O cargo está inativo.
Deseja continuar mesmo assim?
```

---

### 5. EXECUÇÃO E PROCESSAMENTO

#### EX - Executa (80+ Comandos Especiais)

**Categorias:**

##### 5.1 Arquivos
```
EX-COPYARQU-SELECT 'C:\orig.txt' AS Origem, 'C:\dest.txt' AS Destino FROM DUAL
EX-DELEARQU-SELECT 'C:\arquivo.txt' AS Arqu FROM DUAL
EX-RENOARQU-SELECT 'C:\old.txt' AS Orig, 'C:\new.txt' AS Dest FROM DUAL
EX-EXISARQU-'C:\arquivo.txt'  → Retorna '1' em {VA-RETOFUNC} se existe
EX-ARQUZIPA-'C:\arquivo.txt'  → Retorna path do .zip em {VA-RETOFUNC}
EX-ZIPAARQU-SELECT 'C:\arq.txt' AS Origem, 'C:\arq.zip' AS Destino FROM DUAL
EX-DES_ZIPA-SELECT 'C:\arq.zip' AS Origem, 'C:\pasta' AS Destino FROM DUAL
```

##### 5.2 Banco de Dados
```
EX-TRANSACT-'BEGIN'     → Inicia transação
EX-TRANSACT-'COMMIT'    → Confirma transação
EX-TRANSACT-'ROLLBACK'  → Desfaz transação

EX-MUDADTB_-'DTBCADA'   → Muda para conexão DtbCada
EX-MUDADTB_-'DTBGENE'   → Volta para conexão DtbGene

EX-DTBCADA-UPDATE TABLE SET x=1  → Executa SQL no DtbCada
EX-DTBGENE-UPDATE TABLE SET x=1  → Executa SQL no DtbGene
```

##### 5.3 Validações
```
EX-VALICPF_-SELECT '12345678901' AS CPF FROM DUAL   → Retorna '1' se válido
EX-VALICNPJ-SELECT '12345678000199' AS CNPJ FROM DUAL
EX-VALIIE__-SELECT '123456789' AS IE, 'SP' AS UF FROM DUAL
EX-VALIHORA-'14:30:00'  → Retorna '1' se hora válida em {VA-RETOFUNC}
EX-VALIDATA-'31/12/2023'
```

##### 5.4 Strings
```
EX-SUBSPATU-<string>  → Substitui TODAS ocorrências de {VA-STRI0001} por {VA-STRI0002}
EX-SUBSPALA-<string>  → Substitui primeira ocorrência (case sensitive)
EX-SUBSPAUM-<string>  → Substitui UMA ocorrência
```

##### 5.5 Sistema
```
EX-TECLENTE-          → Simula tecla Enter
EX-PROXCAMP-          → Vai para próximo campo
EX-RETOVERS-          → Retorna versão em {VA-RETOFUNC}
EX-VERIACES-'<cod>'   → Retorna acessos da tabela (1=Inc,2=Alt,...)
EX-EXECPLSG-'<inst>'  → Executa PL-SAG dentro de PL-SAG (recursivo)
```

**Padrão de Retorno:**
```
Comandos EX que retornam valores:
  → Retorno em {VA-RETOFUNC} (string)
  → {VA-RESU0001} a {VA-RESU0008} para múltiplos retornos
```

---

### 6. FORMULÁRIOS E NAVEGAÇÃO

```
FO-<codiTabe>                      → Abre formulário pelo código
FO-<codiTabe>-/Filtro=<valor>      → Abre com parâmetros
FM-<codiTabe>-WHERE <condição>     → Manutenção genérica
FV-<instrução>                     → Executa APÓS voltar do formulário
```

**Passagem de Parâmetros:**
```plsag
# Formulário chamador:
PU-INTE0001-{DG-CodiPess}
PU-STRI0001-'Modo Edição'
FO-1050

# Formulário chamado (1050):
VA-INTE0001-{PU-INTE0001}  # Recebe CodiPess
VA-STRI0001-{PU-STRI0001}  # Recebe 'Modo Edição'
```

---

### 7. VARIÁVEIS

#### VA - Variáveis do Formulário

**Tipos e Ranges:**
```
VA-INTE0001 a VA-INTE0020  → Inteiros
VA-REAL0001 a VA-REAL0020  → Decimais
VA-STRI0001 a VA-STRI0020  → Strings
VA-DATA0001 a VA-DATA0010  → Datas
VA-VALO0001 a VA-VALO0010  → Valores sem aspas
VA-RESU0001 a VA-RESU0008  → Resultado (retorno de funções)
```

**Escopo:**
```
0001-0010: Privadas/Locais (uso livre)
0011-0020: Públicas (documentar uso na POCATabe)
```

**Variáveis Especiais (Sistema):**
```
{VA-INSERIND}  → 1=inserindo, 0=alterando (read-only)
{VA-CONFIRMA}  → Se preenchida, exibe erro ao confirmar
{VA-RETOFUNC}  → Retorno de funções (read/write)
{VA-FECHCONF}  → Controla visibilidade do botão fechar
{VA-CODIPESS}  → Código do usuário logado
{VA-PCODPESS}  → PCODPESS do usuário
{VA-EMPRESA}   → Sigla da empresa (SAG, AGD, etc.)
{VA-NUMEBASE}  → Número do banco (2=SQL, 3=Firebird, 4=Oracle)
{VA-CODITABE}  → Código da tabela atual
{VA-DATETIME}  → 'DD/MM/YYYY HH:MM:SS'
{VA-DATE}      → 'DD/MM/YYYY'
{VA-TIME}      → 'HH:MM:SS'
```

#### VP - Variáveis Personalizadas

```
VP-INTE0001 a VP-INTE####  → Inteiros (sem limite superior definido)
VP-REAL0001 a VP-REAL####  → Decimais
VP-STRI0001 a VP-STRI####  → Strings
VP-DATA0001 a VP-DATA####  → Datas
VP-VALO0001 a VP-VALO####  → Valores sem aspas
```

#### PU - Variáveis Públicas Globais

**⚠️ LIMITAÇÃO: Apenas 0001 a 0005**
```
PU-INTE0001 a PU-INTE0005  → Inteiros globais
PU-REAL0001 a PU-REAL0005  → Decimais globais
PU-STRI0001 a PU-STRI0005  → Strings globais
PU-DATA0001 a PU-DATA0005  → Datas globais
PU-VALO0001 a PU-VALO0005  → Valores sem aspas globais
```

**Uso:** Passar valores entre formulários via FO.

---

## 🔄 CASOS DE USO CANÔNICOS

### Caso 1: Validação Condicional com Mensagem

**Requisito:** Ao confirmar, se cargo ativo mas sem nome, pedir confirmação.

```plsag
# ExecConfirma (executado ao clicar OK):
IF-INIC0001-SELECT (CASE WHEN {CS-AtivCarg} = 1 AND TRIM({CE-NomeCarg}) = '' THEN 1 ELSE 0 END) FROM DUAL
  MC-NomeCarg-SELECT 1 FROM DUAL
  O cargo está ativo mas não tem nome.
  Deseja continuar mesmo assim?

  IF-INIC0002-SELECT 0 FROM DUAL  # MC retorna false = 0 se clicou "Não"
    ME-NomeCarg-SELECT 1 FROM DUAL
    Operação cancelada pelo usuário.
  IF-FINA0002
IF-FINA0001
```

### Caso 2: Cálculo Automático em Movimento

**Requisito:** Ao alterar Qtde ou Preço, recalcular Total.

```plsag
# ExecSaida do campo QtdeProd:
DM-ValoTota-SELECT {DM-QtdeProd} * {DM-ValoUnit} FROM DUAL

# ExecSaida do campo ValoUnit:
DM-ValoTota-SELECT {DM-QtdeProd} * {DM-ValoUnit} FROM DUAL
```

### Caso 3: Lookup Dinâmico

**Requisito:** Ao selecionar Laboratório, preencher cidade automaticamente.

```plsag
# ExecSaida do campo XCodLabo:
QY-XCodLabo-ABRE
CE-XCidLabo-{QY-XCodLabo-NomCida}
```

### Caso 4: Habilitação Condicional

**Requisito:** Habilitar campo Email só se tipo = 'E-mail'.

```plsag
# ExecSaida do campo TipoMens:
CED-EmailDes-SELECT (CASE {CE-TipoMens} WHEN 'E' THEN 1 ELSE 0 END) FROM DUAL
```

### Caso 5: Loop com Processamento

**Requisito:** Para cada produto do pedido, gerar estoque.

```plsag
WH-ITEMPEDI-SELECT CodiProd, QtdeProd FROM POCAMVPE WHERE CodiPedi = {DG-CodiPedi}
  # Para cada item:
  EX-DTBGENE-INSERT INTO POCAMVES (CodiEsto, CodiProd, QtdeMvEs)
              VALUES ({DG-CodiEsto}, {QY-ITEMPEDI-CodiProd}, {QY-ITEMPEDI-QtdeProd})
WH-ITEMPEDI-
```

### Caso 6: Relatório com Filtro Dinâmico

**Requisito:** Imprimir relatório de pessoas com filtro personalizado.

```plsag
VA-STRI0001-SELECT 'AND CodiPess BETWEEN '||{EN-PessInic}||' AND '||{EN-PessFina} FROM DUAL
IR-21041   -{VA-VALO0001}
```

### Caso 7: Importação de Arquivo

**Requisito:** Importar arquivo texto linha por linha para tabela.

```plsag
EX-IMPOARQU-SELECT 'C:\dados.txt' AS Arqu, 'POCAIMPO' AS Tabe, 'LinhaImpo' AS Camp FROM DUAL
```

---

## 🧪 MODELO DE DADOS E ESTADO

### Contexto de Execução (Runtime State)

```typescript
interface ExecutionContext {
  // Formulário ativo
  form: {
    mode: 'INSERT' | 'EDIT' | 'VIEW',
    codiTabe: number,
    components: Map<string, Component>
  },

  // Datasets
  datasets: {
    DtsGrav: Dataset,  // Cabeçalho
    DtsMov1: Dataset,  // Movimento 1
    DtsMov2: Dataset,  // Movimento 2
    DtsMov3: Dataset   // Movimento 3
  },

  // Queries
  queries: Map<string, Query>,

  // Variáveis
  variables: {
    VA: Map<string, any>,  // Variáveis do formulário
    VP: Map<string, any>,  // Variáveis personalizadas
    PU: Map<string, any>   // Variáveis públicas globais
  },

  // Pilha de controle
  controlStack: {
    ifStack: Array<IFState>,
    whileStack: Array<WhileState>
  },

  // Estado de execução
  execution: {
    halted: boolean,
    lastResult: any
  }
}

interface IFState {
  label: string,
  state: 'EXECUTING' | 'SKIPPING' | 'SATISFIED'
}

interface WhileState {
  id: string,
  query: Query,
  startLine: number
}
```

### Mapeamento Componente → Tipo

```typescript
const COMPONENT_PREFIXES = {
  // Campos Database-Aware
  'CE': 'TsgDBE',      // Edit
  'CN': 'TsgDBN',      // Number
  'CS': 'TsgDBS',      // SimNao (Checkbox)
  'CM': 'TsgDBM',      // Memo
  'CT': 'TsgDBT',      // Tabela (Lookup Combo)
  'CA': 'TsgDBA',      // Arquivo
  'CC': 'TsgDBC',      // Combo
  'CD': 'TsgDBD',      // Data
  'CR': 'TsgDBR',      // RichText

  // Editores standalone
  'EE': 'TsgEdt',      // Edit
  'EN': 'TsgEdN',      // Number
  'ES': 'TsgEdS',      // SimNao
  'ET': 'TsgEdT',      // Text/Memo
  'EC': 'TsgEdC',      // Combo
  'ED': 'TsgEdD',      // Data
  'EA': 'TsgEdA',      // Arquivo
  'EI': 'TsgEdI',      // Diretório

  // Labels
  'LB': 'TsgLbl',
  'LE': 'TsgLblE',
  'LN': 'TsgLblN',

  // Outros
  'BT': 'TsgBtn',      // Botão
  'QY': 'TsgQuery',    // Query
  'LC': 'TsgLCB',      // Lista CheckBox
  'GR': 'TsgGraf',     // Gráfico
};
```

---

## 🎓 PADRÕES E CONVENÇÕES

### Nomenclatura de Identificadores

```
┌──────────────────┬────────────────┬──────────────────────────────┐
│ Categoria        │ Padrão         │ Exemplos                     │
├──────────────────┼────────────────┼──────────────────────────────┤
│ Campos de Form   │ CamelCase      │ CodiPess, NomePess, XCodCida │
│ Variáveis VA/VP  │ TIPO####       │ INTE0001, STRI0005, REAL0010 │
│ Labels IF/WH     │ XXXX#### ou    │ INIC0001, ELSE0002, NOVOMOV1 │
│                  │ Livre (8 char) │ BASEAUXI, LOOPGRID           │
│ Queries QY/QN    │ Livre (8 char) │ BUSCVALO, GRIDGRID, CodiPess │
│ Genéricos        │ 12345678       │ 12345678 (8 dígitos)         │
└──────────────────┴────────────────┴──────────────────────────────┘
```

### Anti-Padrões Comuns

**❌ ERRADO:**
```plsag
# Identificador muito curto
DG-CODI-SELECT 123 FROM DUAL

# Template sem prefixo
CE-NomePess-{NomePess}

# IF sem label único
IF-INIC0001-...
  IF-INIC0001-...  # ❌ Label duplicado!
  IF-FINA0001
IF-FINA0001
```

**✅ CORRETO:**
```plsag
# Padding com espaços
DG-CODI    -SELECT 123 FROM DUAL

# Template completo
CE-NomePess-{DG-NomePess}

# Labels únicos aninhados
IF-INIC0001-...
  IF-INIC0002-...
  IF-FINA0002
IF-FINA0001
```

---

## 🔌 INTEGRAÇÃO COM BANCO DE DADOS

### Funções SQL Customizadas

```sql
-- Retorna código do usuário
RETOPUSU(USER) → VARCHAR2
  Retorno: Código numérico do usuário logado

-- Retorna NULL se valor = 0
NULO(valor) → NUMBER
  Retorno: NULL se valor = 0, senão valor

-- Retorna 0 se NULL
RetoZero(valor) → NUMBER
  Retorno: 0 se valor IS NULL, senão valor
```

### Padrão de Queries

```sql
-- Query simples (usado em 90% dos casos)
SELECT <expressão> FROM DUAL

-- Query com filtro
SELECT * FROM TABELA WHERE <condição>

-- Query com join
SELECT T1.Campo1, T2.Campo2
FROM TABELA1 T1
INNER JOIN TABELA2 T2 ON T1.Chave = T2.Chave
WHERE <condição>
```

---

## 📦 EXEMPLOS DE IMPLEMENTAÇÃO

### Implementação JavaScript/TypeScript

```typescript
class PLSAGInterpreter {
  private context: ExecutionContext;

  constructor(context: ExecutionContext) {
    this.context = context;
  }

  async execute(instructions: string[]): Promise<void> {
    for (let i = 0; i < instructions.length; i++) {
      if (this.context.execution.halted) break;

      const line = instructions[i];
      const parsed = this.parseLine(line);

      if (!parsed) continue;

      // Substituir templates
      parsed.parameter = await this.substituteTemplates(parsed.parameter);

      // Executar comando
      await this.executeCommand(parsed);

      // Comandos especiais
      if (parsed.prefix === 'ME') {
        this.context.execution.halted = true;
        throw new Error(parsed.messageText);
      }

      if (parsed.prefix === 'PA') {
        const result = await this.evaluateExpression(parsed.parameter);
        if (result == 0) {
          this.context.execution.halted = true;
          break;
        }
      }
    }
  }

  private parseLine(line: string): ParsedInstruction | null {
    // Implementação do algoritmo de parsing
    const prefix = line.substring(0, 2);
    const modifier = line.substring(2, 3);
    const identifier = line.substring(3, 11).trim();
    const parameter = line.substring(12);

    return { prefix, modifier, identifier, parameter };
  }

  private async substituteTemplates(text: string): Promise<string> {
    const regex = /\{([A-Z]{2})-([A-Z0-9_ ]{1,8})(?:-([A-Z0-9_]+))?\}/g;

    let result = text;
    let match;

    while ((match = regex.exec(text)) !== null) {
      const [fullMatch, prefix, id, field] = match;
      const value = await this.getTemplateValue(prefix, id.trim(), field);
      result = result.replace(fullMatch, value);
    }

    return result;
  }

  private async executeCommand(parsed: ParsedInstruction): Promise<void> {
    switch (parsed.prefix) {
      case 'DG':
        this.executeDG(parsed);
        break;
      case 'CE':
        this.executeCE(parsed);
        break;
      case 'IF':
        this.executeIF(parsed);
        break;
      case 'WH':
        await this.executeWH(parsed);
        break;
      case 'EX':
        await this.executeEX(parsed);
        break;
      // ... outros comandos
    }
  }

  private executeDG(parsed: ParsedInstruction): void {
    if (this.context.form.mode !== 'INSERT' && !parsed.parameter.startsWith('DD')) {
      return; // Só grava em INSERT
    }

    const value = this.evaluateExpression(parsed.parameter);
    this.context.datasets.DtsGrav.setFieldValue(parsed.identifier, value);
  }

  private executeCE(parsed: ParsedInstruction): void {
    const component = this.context.form.components.get(parsed.identifier);
    if (!component) return;

    const value = this.evaluateExpression(parsed.parameter);

    switch (parsed.modifier) {
      case '':  // Sem modificador
        component.setValue(value);
        break;
      case 'D': // Disable/Enable
        component.setEnabled(value != 0);
        break;
      case 'F': // Focus
        if (value != 0) component.setFocus();
        break;
      case 'V': // Visible
        component.setVisible(value != 0);
        break;
    }
  }

  private executeIF(parsed: ParsedInstruction): void {
    const label = parsed.identifier;

    if (parsed.identifier.startsWith('INIC')) {
      const condition = this.evaluateExpression(parsed.parameter);
      this.context.controlStack.ifStack.push({
        label,
        state: condition != 0 ? 'EXECUTING' : 'SKIPPING'
      });
    }
    else if (parsed.identifier.startsWith('ELSE')) {
      const current = this.context.controlStack.ifStack.pop();
      if (current.state === 'SKIPPING') {
        if (parsed.parameter) {
          const condition = this.evaluateExpression(parsed.parameter);
          current.state = condition != 0 ? 'EXECUTING' : 'SKIPPING';
        } else {
          current.state = 'EXECUTING';
        }
      } else {
        current.state = 'SATISFIED';
      }
      this.context.controlStack.ifStack.push(current);
    }
    else if (parsed.identifier.startsWith('FINA')) {
      this.context.controlStack.ifStack.pop();
    }
  }
}
```

---

## 🎯 TESTES E VALIDAÇÃO

### Casos de Teste Canônicos

```typescript
describe('PL/SAG Interpreter', () => {
  test('Parsing: Identificador de 8 chars com espaços', () => {
    const line = 'TQ-DPI     -SELECT 203 FROM DUAL';
    const parsed = interpreter.parseLine(line);
    expect(parsed.identifier).toBe('DPI');
    expect(parsed.identifier.length).toBe(3); // Após trim
  });

  test('Substituição de template simples', async () => {
    context.datasets.DtsGrav.setFieldValue('CodiPess', 123);
    const result = await interpreter.substituteTemplates('{DG-CodiPess}');
    expect(result).toBe('123');
  });

  test('Substituição de template de query', async () => {
    context.queries.set('XCodLabo', {
      currentRecord: { NomCida: 'São Paulo' }
    });
    const result = await interpreter.substituteTemplates('{QY-XCodLabo-NomCida}');
    expect(result).toBe('São Paulo');
  });

  test('IF: Executa bloco se condição verdadeira', async () => {
    const instructions = [
      'IF-INIC0001-SELECT 1 FROM DUAL',
      'VA-INTE0001-100',
      'IF-FINA0001'
    ];
    await interpreter.execute(instructions);
    expect(context.variables.VA.get('INTE0001')).toBe(100);
  });

  test('IF: Pula bloco se condição falsa', async () => {
    const instructions = [
      'IF-INIC0001-SELECT 0 FROM DUAL',
      'VA-INTE0001-100',
      'IF-FINA0001'
    ];
    await interpreter.execute(instructions);
    expect(context.variables.VA.get('INTE0001')).toBeUndefined();
  });

  test('WH: Itera sobre registros', async () => {
    mockQuery.returns([
      { CodiProd: 1, QtdeProd: 10 },
      { CodiProd: 2, QtdeProd: 20 }
    ]);

    const instructions = [
      'WH-PRODUTOS-SELECT * FROM PRODUTOS',
      'VA-INTE0001-{QY-PRODUTOS-CodiProd}',
      'WH-PRODUTOS-'
    ];

    // Deve executar 2 vezes
    await interpreter.execute(instructions);
    expect(context.variables.VA.get('INTE0001')).toBe(2); // Último valor
  });

  test('ME: Para execução', async () => {
    const instructions = [
      'VA-INTE0001-1',
      'ME-12345678-SELECT 1 FROM DUAL',
      'Erro!',
      'VA-INTE0002-2' // Não deve executar
    ];

    await expect(interpreter.execute(instructions)).rejects.toThrow();
    expect(context.variables.VA.get('INTE0001')).toBe(1);
    expect(context.variables.VA.get('INTE0002')).toBeUndefined();
  });
});
```

---

## 📚 GLOSSÁRIO

```
Dataset      → Conjunto de dados (tabela em memória) ligado ao banco
Query        → Consulta SQL executável
Template     → Padrão {XXX} a ser substituído por valor
Cabeçalho    → Registro principal do formulário (DtsGrav)
Movimento    → Registros filhos (detalhes) do formulário (DtsMov1/2/3)
Label        → Identificador usado em IF/WH para marcação de blocos
Lookup       → Campo que busca valor em outra tabela
PostBack     → Atualizar campo após busca/cálculo
Trigger      → Código Delphi executado em resposta a evento
POCATabe     → Tabela de configuração de telas/formulários
sgForm       → Classe base de formulário no sistema
```

---

## 🚀 GUIA DE MIGRAÇÃO PARA WEB

### Conceitos Equivalentes

```
┌─────────────────────┬───────────────────────────────────┐
│ PL/SAG (Delphi)     │ Web (Sugestão)                    │
├─────────────────────┼───────────────────────────────────┤
│ sgForm              │ React/Vue Component               │
│ Dataset             │ State/Store (Redux/Vuex)          │
│ Query               │ API Call → Local State            │
│ ExecSaida (OnExit)  │ onBlur / onChange                 │
│ ExecEntrada (OnEnter│ onFocus                           │
│ ExecConfirma        │ onSubmit                          │
│ Template {DG-xxx}   │ ${state.formData.xxx}             │
│ TsgDBE (Edit)       │ <input type="text">               │
│ TsgDBN (Number)     │ <input type="number">             │
│ TsgDBS (SimNao)     │ <input type="checkbox">           │
│ TsgDBT (Lookup)     │ <select> ou Autocomplete          │
│ TsgDBM (Memo)       │ <textarea>                        │
│ IF-INIC/ELSE/FINA   │ if/else if/else                   │
│ WH loop             │ for...of / forEach                │
│ MA/MC/ME/MI         │ alert() / confirm() / toast       │
│ EX-TRANSACT         │ Database transaction API          │
│ FO (abrir form)     │ Router.push() / Modal.open()      │
└─────────────────────┴───────────────────────────────────┘
```

### Arquitetura Sugerida

```
┌─────────────────────────────────────────────────────────┐
│                    FRONTEND (React/Vue)                 │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────┐  ┌──────────────────────────────┐  │
│ │ PL/SAG Engine   │  │ Form Components              │  │
│ │ (Interpreter)   │  │ - DynamicForm                │  │
│ │                 │  │ - FieldRenderer              │  │
│ │ - Parser        │  │ - QueryableField             │  │
│ │ - Executor      │  └──────────────────────────────┘  │
│ │ - Template      │                                     │
│ │   Resolver      │  ┌──────────────────────────────┐  │
│ └─────────────────┘  │ State Management             │  │
│                      │ - Form Data                  │  │
│                      │ - Variables (VA/VP/PU)       │  │
│                      │ - Query Cache                │  │
│                      └──────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ▲
                           │ REST/GraphQL API
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    BACKEND (Node.js/Python)             │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────┐ │
│ │ PL/SAG Compiler/Optimizer                           │ │
│ │ - Valida instruções                                 │ │
│ │ - Otimiza queries                                   │ │
│ │ - Cache de expressões                               │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                           │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ Business Logic Layer                                │ │
│ │ - EX commands implementation                        │ │
│ │ - File operations (COPYARQU, DELEARQU, etc.)        │ │
│ │ - Validations (VALICPF, VALICNPJ, etc.)             │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                           │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ Database Layer (ORM: Prisma/TypeORM/SQLAlchemy)     │ │
│ │ - Query execution                                   │ │
│ │ - Transaction management                            │ │
│ │ - Connection pooling                                │ │
│ └─────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────── │
                           ▲
                           │ SQL
                           ▼
┌─────────────────────────────────────────────────────────┐
│              DATABASE (PostgreSQL/Oracle)               │
└─────────────────────────────────────────────────────────┘
```

### Exemplo de Tradução

**PL/SAG Original:**
```plsag
# ExecSaida do campo CodiPess
QY-CodiPess-ABRE
CE-NomePess-{QY-CodiPess-NomePess}
CED-EmailPes-SELECT (CASE {QY-CodiPess-TipoPess} WHEN 'J' THEN 0 ELSE 1 END) FROM DUAL
```

**Web Equivalente (React):**
```typescript
// Campo CodiPess - onBlur handler
const handleCodiPessBlur = async (value: number) => {
  // QY-CodiPess-ABRE
  const query = await api.query('CodiPess', { CodiPess: value });

  // CE-NomePess-{QY-CodiPess-NomePess}
  setFieldValue('NomePess', query.data.NomePess);

  // CED-EmailPes-...
  const shouldEnable = query.data.TipoPess !== 'J';
  setFieldEnabled('EmailPes', shouldEnable);
};
```

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

### Fase 1: Parser e Core
- [ ] Implementar parser de linhas (8 chars identifier)
- [ ] Implementar substituição de templates `{XXX}`
- [ ] Implementar executor básico (DG, CE, CN, CS)
- [ ] Implementar IF-INIC/ELSE/FINA
- [ ] Implementar WH loop
- [ ] Implementar variáveis VA/VP/PU

### Fase 2: Queries e Dados
- [ ] Implementar QY (queries principais)
- [ ] Implementar QN (queries dinâmicas)
- [ ] Implementar QD/QM (queries com marcador)
- [ ] Implementar templates de query `{QY-ID-CAMPO}`

### Fase 3: UI e Interação
- [ ] Implementar mensagens (MA/MC/ME/MI/MP)
- [ ] Implementar modificadores de campo (D/F/V/C/R)
- [ ] Implementar navegação de formulários (FO/FM)
- [ ] Implementar variáveis de sistema (VA-INSERIND, VA-CODIPESS, etc.)

### Fase 4: Comandos Avançados
- [ ] Implementar 80+ comandos EX
- [ ] Implementar relatórios (IR)
- [ ] Implementar listas (LC)
- [ ] Implementar timers (TI)

### Fase 5: Otimização
- [ ] Cache de queries repetidas
- [ ] Otimização de substituição de templates
- [ ] Lazy loading de componentes
- [ ] Validação prévia de sintaxe

---

## 📖 REFERÊNCIAS

- **Código-fonte:** `PlusUni.pas` (linha 3731: `CampPersExecListInst`)
- **Documentação:** `MANUAL_PLSAG.md`, `PL-SAG - Wiki.txt`
- **Especificação:** `project.md`

---

## 🔄 VERSIONAMENTO DESTE DOCUMENTO

```
Versão: 1.0.0
Data: 2025-12-14
Autor: Claude Code (AI-generated)
Status: Draft inicial para revisão
```

---

**FIM DA ESPECIFICAÇÃO**

Esta especificação formal foi projetada para ser consumida por sistemas de IA, fornecendo:
1. Gramática formal (BNF)
2. Semântica operacional detalhada
3. Exemplos canônicos executáveis
4. Casos de teste
5. Guia de migração para web
6. Modelo de dados completo

Use este documento como base para gerar implementações do PL/SAG em qualquer plataforma moderna.
