# Manual Completo do PL/SAG para Programadores

**Versão:** 2.0
**Data:** 2025-12-14
**Baseado em:** PlusUni.pas (16.167 linhas) + PL-SAG Wiki.txt

---

## Índice

1. [Introdução](#1-introdução)
2. [Conceitos Fundamentais](#2-conceitos-fundamentais)
3. [Sintaxe e Estrutura](#3-sintaxe-e-estrutura)
4. [Referência Completa de Comandos](#4-referência-completa-de-comandos)
5. [Exemplos Práticos](#5-exemplos-práticos)
6. [Boas Práticas](#6-boas-práticas)
7. [Troubleshooting](#7-troubleshooting)
8. [Apêndices](#8-apêndices)

---

## 1. Introdução

### 1.1 O que é PL/SAG?

PL/SAG (Programming Language - Sistema de Automação Genérica) é uma **linguagem de script interpretada** desenvolvida em Delphi/Pascal, projetada especificamente para **configurar o comportamento dinâmico de formulários empresariais** sem necessidade de recompilação.

### 1.2 Características Principais

- **Interpretada:** Executada em tempo de execução pelo procedimento `CampPersExecListInst`
- **Declarativa:** Foca no "o que fazer" ao invés do "como fazer"
- **Integrada ao SQL:** Permite execução de queries Oracle/SQL Server inline
- **Orientada a Eventos:** Responde a eventos de formulário (OnShow, OnExit, etc.)
- **Fortemente Tipada por Prefixo:** Cada comando tem um prefixo de 2 caracteres que define seu tipo

### 1.3 Quando Usar PL/SAG?

✅ **Use PL/SAG para:**
- Validações dinâmicas de campos
- Cálculos automáticos baseados em regras de negócio
- Controle de visibilidade/habilitação de componentes
- Navegação condicional entre formulários
- Geração de relatórios parametrizados
- Integração com sistemas externos (NFe, boletos, etc.)

❌ **NÃO use PL/SAG para:**
- Lógica complexa que requer estruturas de dados avançadas
- Processamento massivo de dados (use procedures SQL)
- Operações que requerem performance crítica

### 1.4 Arquitetura do Interpretador

```
┌─────────────────────────────────────────────────────────┐
│  Formulário (sgForm)                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │  POCATabe.CampPers (Campo Personalizado)        │   │
│  │  ┌───────────────────────────────────────────┐  │   │
│  │  │ Lista de Instruções PL/SAG:               │  │   │
│  │  │ CE-NomePess-'João'                        │  │   │
│  │  │ IF-INIC0001-SELECT {DG-CodiPess}>0 DUAL   │  │   │
│  │  │ ...                                        │  │   │
│  │  └───────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
         ┌─────────────────────────────┐
         │  CampPersExecListInst       │
         │  (Interpretador Principal)  │
         └──────────┬──────────────────┘
                    │
        ┌───────────┴────────────┬───────────────┐
        ▼                        ▼               ▼
┌───────────────┐    ┌────────────────┐   ┌──────────────┐
│ CampPersExec  │    │ CampPersAcao   │   │ CampPers_EX  │
│ (Executa SQL) │    │ (D/F/V/C/R)    │   │ (Comandos)   │
└───────────────┘    └────────────────┘   └──────────────┘
```

**Fluxo de Execução:**
1. Formulário carrega instruções PL/SAG da tabela `POCATabe`
2. Evento dispara execução (OnShow, OnExit, OnClick, etc.)
3. `CampPersExecListInst` processa linha por linha
4. Cada linha é parseada: `PREFIXO-IDENTIFICADOR-PARÂMETRO`
5. Funções auxiliares executam a ação específica
6. Resultado é aplicado ao formulário/banco de dados

---

## 2. Conceitos Fundamentais

### 2.1 Estrutura de uma Instrução

Toda instrução PL/SAG segue o formato:

```
PREFIXO-IDENTIFICADOR-PARÂMETRO
```

**Componentes:**

| Componente     | Tamanho         | Descrição                              |
|----------------|-----------------|----------------------------------------|
| PREFIXO        | 2 caracteres    | Tipo de comando (CE, DG, IF, EX, etc.) |
| Separador      | 1 caractere     | Hífen `-`                              |
| IDENTIFICADOR  | 8 caracteres    | Nome do campo/variável/label           |
| Separador      | 1 caractere     | Hífen `-`                              |
| PARÂMETRO      | Variável        | SQL, valor, ação, etc.                 |

**Exemplo Anotado:**
```
CE-NomePess-SELECT NomePess FROM POCaPess WHERE CodiPess = 123
│  │        │
│  │        └─ Parâmetro: SQL que retorna o valor
│  └────────── Identificador: 8 caracteres exatos
└──────────── Prefixo: CE = Campo Editor
```

### 2.2 A Regra Crítica dos 8 Caracteres

⚠️ **FUNDAMENTAL:** Todos os identificadores devem ter **EXATAMENTE 8 caracteres**.

**Como o interpretador funciona (código-fonte):**
```pascal
// PlusUni.pas, linha 3901 e 4266:
Camp := AnsiUpperCase(Trim(Copy(Linh,04,08)));
```

**Extração do Identificador:**
1. `Copy(Linh, 04, 08)` → Pega 8 caracteres da posição 4
2. `Trim(...)` → Remove espaços à direita e esquerda
3. `AnsiUpperCase(...)` → Converte para maiúsculas

**Implicações Práticas:**

✅ **Identificadores de 8 caracteres exatos:**
```
DG-CodiPess-SELECT 123 FROM DUAL    ✓ (CodiPess = 8 chars)
IF-INIC0001-SELECT 1 FROM DUAL      ✓ (INIC0001 = 8 chars)
EX-ARQUZIPA-'C:\arq.txt'            ✓ (ARQUZIPA = 8 chars)
```

✅ **Identificadores menores com espaços:**
```
TQ-DPI     -SELECT 203 FROM DUAL    ✓ (DPI + 5 espaços = 8)
TH-SLEEP   -1000                    ✓ (SLEEP + 3 espaços = 8)
EX-DLL_    -Params                  ✓ (DLL_ + 4 espaços = 8)
```

❌ **Identificadores incorretos:**
```
DG-Codi-SELECT 123 FROM DUAL        ✗ (Codi = 4 chars)
IF-INICIAL001-SELECT 1 FROM DUAL    ✗ (INICIAL001 = 10 chars)
TQ-DPI-SELECT...                    ✗ (será lido como "DPI-SELE")
```

### 2.3 Substituição de Variáveis (Templates)

O PL/SAG suporta **substituição de templates** usando chaves `{}`.

**Sintaxe:**
```
{PREFIXO-IDENTIFICADOR}
{QY-QueryName-FieldName}
{LC-ListName-NUMETOTA}
```

**Substituição ocorre ANTES da execução:**
```pascal
// Antes da substituição:
CE-ValoTota-SELECT {DG-QtdeProd} * {DG-ValoUnit} FROM DUAL

// Depois da substituição (se QtdeProd=10, ValoUnit=5.50):
CE-ValoTota-SELECT 10 * 5.50 FROM DUAL

// Resultado: Campo ValoTota recebe 55.00
```

**Variáveis Substituíveis:**

| Sintaxe                  | Retorna                                        |
|--------------------------|------------------------------------------------|
| `{DG-Campo}`             | Valor do campo no cabeçalho (DtsGrav)          |
| `{DM-Campo}`             | Valor do campo no movimento 1 (DtsMov1)        |
| `{D2-Campo}`             | Valor do campo no movimento 2 (DtsMov2)        |
| `{D3-Campo}`             | Valor do campo no movimento 3 (DtsMov3)        |
| `{CE-Campo}`             | Valor do campo Editor                          |
| `{VA-INTE0001}`          | Valor da variável inteira 0001                 |
| `{QY-Query-Field}`       | Campo específico da query                      |
| `{QY-Query-NumeRegi}`    | Número de registros da query                   |
| `{LC-Lista-NUMETOTA}`    | Total de itens marcados na lista               |
| `{GC-Grid}`              | Coluna atual do grid                           |

**Exemplos Práticos:**

```plsag
# Exemplo 1: Cálculo com substituição
CE-ValoTota-SELECT {DG-QtdeProd} * {DG-ValoUnit} * (1 - {DG-Desconto}/100) FROM DUAL

# Exemplo 2: Filtro dinâmico
QY-Produtos-SELECT * FROM POGeProd WHERE CodiPess = {DG-CodiPess}

# Exemplo 3: Mensagem personalizada
MI-12345678-SELECT 1 FROM DUAL
Cliente: {DG-NomePess}
Total: {CE-ValoTota}

# Exemplo 4: Condicional com query
IF-INIC0001-SELECT {QY-Produtos-NumeRegi} > 0 FROM DUAL
  CE-Mensagem-'Possui produtos cadastrados'
IF-FINA0001
```

### 2.4 Tipos de Dados

PL/SAG trabalha principalmente com **tipos SQL**, mas tem categorias de variáveis:

| Tipo       | Prefixo     | Faixa            | Exemplo                    |
|------------|-------------|------------------|----------------------------|
| Inteiro    | VA-INTE#### | 0001-0020        | `VA-INTE0001-100`          |
| Real       | VA-REAL#### | 0001-0020        | `VA-REAL0001-10.50`        |
| String     | VA-STRI#### | 0001-0020        | `VA-STRI0001-'Texto'`      |
| Data       | VA-DATA#### | 0001-0010        | `VA-DATA0001-SYSDATE`      |
| Valor      | VA-VALO#### | 0001-0010        | `VA-VALO0001-Expressão`    |
| Resultado  | VA-RESU#### | 0001-0008        | `VA-RESU0001-1`            |

**Variáveis Públicas (compartilhadas entre formulários):**
```
PU-INTE0001 até PU-INTE0005   (apenas 5 variáveis!)
PU-REAL0001 até PU-REAL0005
PU-STRI0001 até PU-STRI0005
PU-DATA0001 até PU-DATA0005
```

**Variáveis Personalizadas (armazenadas no banco):**
```
VP-INTE0001, VP-REAL0001, VP-STRI0001, VP-DATA0001, VP-VALO0001
```

### 2.5 Escopo e Contexto

**Escopo de Variáveis:**

```
┌─────────────────────────────────────────┐
│ Escopo Global (Aplicação)               │
│ ├─ VA-CODIPESS (usuário logado)         │
│ ├─ VA-EMPRESA (sigla da empresa)        │
│ ├─ VA-VERSMONI (versão)                 │
│ └─ PU-XXXX#### (5 variáveis públicas)   │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ Escopo do Formulário                    │
│ ├─ VA-INTE0011-0020 (públicas)          │
│ ├─ VA-INTE0001-0010 (privadas)          │
│ ├─ DG-XXXXXXXX (campos cabeçalho)       │
│ └─ QY-XXXXXXXX (queries do form)        │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ Escopo do Evento                        │
│ ├─ Variáveis temporárias                │
│ └─ Resultado de IF/WH                   │
└─────────────────────────────────────────┘
```

**Contexto de Execução:**

| Evento     | Quando Executa                          | Acesso                      |
|------------|-----------------------------------------|-----------------------------|
| OnShow     | Ao abrir formulário                     | DG, QY, VA, executa EY      |
| OnExit     | Ao sair de um campo                     | DG, DM, campo atual         |
| OnConfirm  | Ao confirmar (botão OK)                 | DG, DM, validações          |
| OnCancel   | Ao cancelar                             | Apenas leitura              |
| Custom     | Chamada via procedimento                | Contexto específico         |

---

## 3. Sintaxe e Estrutura

### 3.1 Comentários

PL/SAG **não possui sintaxe nativa para comentários** nas instruções armazenadas no banco. Use:

**Opção 1: Comentários na documentação POCATabe**
```sql
-- Armazenar comentários no campo DescTabe da POCATabe
```

**Opção 2: Instruções "dummy" que não executam**
```plsag
-- Usar MA com condição falsa (não exibe mensagem)
MA-12345678-SELECT 1=0 FROM DUAL
Este é um comentário que nunca será exibido
```

**Opção 3: Labels vazios (não recomendado)**
```plsag
LB-COMMENT1-'-- Este é um comentário'
```

### 3.2 Estruturas de Controle

#### 3.2.1 Condicional IF

**Sintaxe:**
```plsag
IF-INIC####-<condição SQL que retorna 0 ou ≠0>
  <instruções executadas se condição ≠ 0>
IF-ELSE####-<condição opcional>
  <instruções executadas se condição anterior = 0>
IF-FINA####
```

**Label deve ser o mesmo** em INIC, ELSE e FINA (8 caracteres exatos).

**Exemplo 1: IF simples**
```plsag
IF-INIC0001-SELECT {DG-CodiPess} > 0 FROM DUAL
  CE-NomePess-SELECT NomePess FROM POCaPess WHERE CodiPess = {DG-CodiPess}
IF-FINA0001
```

**Exemplo 2: IF-ELSE**
```plsag
IF-INIC0002-SELECT {VA-INSERIND} = 1 FROM DUAL
  CE-DataCada-SELECT SYSDATE FROM DUAL
IF-ELSE0002
  CE-DataAlte-SELECT SYSDATE FROM DUAL
IF-FINA0002
```

**Exemplo 3: IF-ELSE com condição**
```plsag
IF-INIC0003-SELECT {DG-TipoPess} = 'F' FROM DUAL
  CE-MaskCPF -'999.999.999-99'
IF-ELSE0003-SELECT {DG-TipoPess} = 'J' FROM DUAL
  CE-MaskCNPJ-'99.999.999/9999-99'
IF-ELSE0003
  CE-MaskGene-''
IF-FINA0003
```

**Regras:**
- ✅ Condição SQL deve retornar valor numérico
- ✅ Retorno **≠ 0** = Verdadeiro (executa bloco)
- ✅ Retorno **= 0** = Falso (pula bloco)
- ✅ `IF-ELSE####` sem condição = senão incondicional
- ✅ IFs podem ser aninhados (usar labels diferentes)
- ❌ Não há ELSEIF nativo (usar IF-ELSE com condição)

#### 3.2.2 Loop WH (While)

**Sintaxe:**
```plsag
WH-XXXXXXXX-<SQL que retorna registros>
  <instruções executadas para cada registro>
  # Pode usar {QY-XXXXXXXX-Campo} para acessar valores
WH-XXXXXXXX
```

**Tipos de WH:**

**1. WH-NOVO#### (Cria query temporária)**
```plsag
WH-NOVO0001-SELECT CodiProd, NomeProd, Preco FROM POGeProd WHERE Ativo = 1
  VA-INTE0001-SELECT {VA-INTE0001} + 1 FROM DUAL
  MP-12345678-SELECT 1 FROM DUAL
Produto: {QY-NOVO0001-NomeProd} - R$ {QY-NOVO0001-Preco}
WH-NOVO0001
```

**2. WH-BASEAUXI (Usa cdsBaseAuxi)**
```plsag
WH-BASEAUXI-SELECT * FROM POCaPess WHERE CodiCida = 1 ORDER BY NomePess
  CE-ListaNom-SELECT {CE-ListaNom} || {QY-BASEAUXI-NomePess} || CHR(13) FROM DUAL
WH-BASEAUXI
```

**3. WH-QueryNom (Itera sobre query existente do form)**
```plsag
# Assumindo que existe Qry CodiProd no formulário
WH-CodiProd-
  DM-QtdeEsto-SELECT Estoque FROM POGeEsto WHERE CodiProd = {QY-CodiProd-CodiProd}
  DM-QtdeProd-PROX
WH-CodiProd
```

**Regras:**
- ✅ Query é aberta automaticamente
- ✅ Loop executa enquanto houver registros
- ✅ Acesso aos campos via `{QY-Label-Campo}`
- ✅ `{QY-Label-NumeRegi}` retorna total de registros
- ✅ Query é fechada ao final (se NOVO)
- ❌ Não há BREAK nativo (usar flag com IF)

#### 3.2.3 Pare (PA)

Interrompe a execução se condição = 0:

```plsag
PA-12345678-SELECT {DG-CodiPess} > 0 FROM DUAL
# Se CodiPess = 0, execução PARA aqui
CE-NomePess-SELECT NomePess FROM POCaPess WHERE CodiPess = {DG-CodiPess}
```

### 3.3 Trabalhando com Dados

#### 3.3.1 Gravação no Banco

**DG - Dados Gravação (Cabeçalho)**
```plsag
DG-CodiPess-SELECT 123 FROM DUAL
DG-NomePess-'João da Silva'
DG-DataCada-SELECT SYSDATE FROM DUAL
```

**DM/D2/D3 - Dados Movimento**
```plsag
DM-CodiProd-SELECT 100 FROM DUAL     # Movimento 1 (DtsMov1)
DM-QtdeProd-SELECT 10 FROM DUAL
D2-ValoUnit-SELECT 5.50 FROM DUAL    # Movimento 2 (DtsMov2)
D3-Desconto-SELECT 10 FROM DUAL      # Movimento 3 (DtsMov3)
```

**DD - Dados Diretos (especifica origem)**
```plsag
DDG-CodiPess-SELECT 456 FROM DUAL    # G = DtsGrav
DDM-QtdeProd-SELECT 20 FROM DUAL     # M = DtsMov1
DD2-ValoUnit-SELECT 3.75 FROM DUAL   # 2 = DtsMov2
DD3-Desconto-SELECT 5 FROM DUAL      # 3 = DtsMov3
```

**Diferença DG vs DDG:**
- `DG` = Grava no DataSource padrão (context-aware)
- `DDG` = Força gravação em DtsGrav (cabeçalho)

#### 3.3.2 Campos de Formulário

**CE - Campo Editor (Text)**
```plsag
CE-NomePess-'João da Silva'
CE-Email   -SELECT 'joao@email.com' FROM DUAL
CE-Enderec -{DG-EndePess} || ', ' || {DG-NumeEnde}
```

**CN - Campo Numérico**
```plsag
CN-QtdeProd-SELECT 100 FROM DUAL
CN-ValoUnit-SELECT 10.50 FROM DUAL
CN-ValoTota-SELECT {CN-QtdeProd} * {CN-ValoUnit} FROM DUAL
```

**CS - Campo Sim/Não (Checkbox)**
```plsag
CS-AtivPess-SELECT 1 FROM DUAL    # 1 = Marcado, 0 = Desmarcado
CS-InatiPes-SELECT 0 FROM DUAL
```

**CM - Campo Memo**
```plsag
CM-ObsePess-'Observações do cliente' || CHR(13) || 'Linha 2'
```

**CT - Campo Tabela (Lookup)**
```plsag
CT-CodiCida-SELECT 1 FROM DUAL    # Define código da cidade (lookup)
```

**CD - Campo Data**
```plsag
CD-DataNasc-SELECT SYSDATE FROM DUAL
CD-DataCada-SELECT TO_DATE('01/01/2025', 'DD/MM/YYYY') FROM DUAL
```

**CC - Campo Combo**
```plsag
CC-TipoPess-'F'    # F = Física, J = Jurídica
```

**CA - Campo Arquivo**
```plsag
CA-PathArqu-'C:\Documentos\arquivo.pdf'
```

**CR - Campo RichText**
```plsag
CR-TextRico-'<b>Negrito</b> <i>Itálico</i>'
```

#### 3.3.3 Modificadores de Ação

**Sintaxe:** `[PREFIXO][MODIFICADOR]-CAMPO-CONDIÇÃO`

| Modificador | Ação                  | Comportamento                       |
|-------------|-----------------------|-------------------------------------|
| D           | Disable/Enable        | 0 = desabilita, ≠0 = habilita       |
| F           | Focus                 | ≠0 = foca no campo                  |
| V           | Visible               | 0 = esconde, ≠0 = mostra            |
| C           | Color                 | Define cor do campo                 |
| R           | ReadOnly              | ≠0 = somente leitura                |

**Exemplos:**
```plsag
# Desabilita campo se não for inserção
CED-CodiPess-SELECT {VA-INSERIND} FROM DUAL

# Foca no nome se código foi preenchido
CEF-NomePess-SELECT {CE-CodiPess} <> '' FROM DUAL

# Esconde desconto se cliente não for VIP
CEV-Desconto-SELECT ClienteVIP FROM POCaPess WHERE CodiPess = {DG-CodiPess}

# Torna campo somente leitura se já confirmado
CER-ValoTota-SELECT Confirmado FROM POCaOrca WHERE CodiOrca = {DG-CodiOrca}

# Cor vermelha se valor negativo
CEC-ValoTota-SELECT CASE WHEN {CN-ValoTota} < 0 THEN 255 ELSE 0 END FROM DUAL
```

### 3.4 Queries e Dados

#### 3.4.1 QY - Query Principal

**Comandos:**
```plsag
QY-CodiPess-SELECT * FROM POCaPess WHERE Ativo = 1           # Abre com filtro
QY-CodiPess-ABRE                                             # Reabre (SQL original)
QY-CodiPess-FECH                                             # Fecha query
QY-CodiPess-PRIM                                             # Primeiro registro
QY-CodiPess-PROX                                             # Próximo
QY-CodiPess-ANTE                                             # Anterior
QY-CodiPess-ULTI                                             # Último
QY-CodiPess-EDIT                                             # Modo edição
QY-CodiPess-INSE                                             # Insere novo
QY-CodiPess-POST                                             # Grava alterações
QY-CodiPess-FILTRA(CodiCida = 1)                             # Aplica filtro
```

**Acessar dados:**
```plsag
CE-NomeClien-{QY-CodiPess-NomePess}                          # Campo específico
CE-TotalReg -{QY-CodiPess-NumeRegi}                          # Nº de registros
```

#### 3.4.2 QD - Query do Grid

```plsag
QD-GridPess-SELECT * FROM POCaPess WHERE CodiCida = {CE-CodiCida}
QD-GridPess-ABRE
QD-GridPess-FECH
QD-GridPess-FILTRA(Ativo = 1)
```

#### 3.4.3 QN - Query Nova (Temporária)

```plsag
# Cria query temporária
QN-TempQuer-SELECT * FROM POGeP rod WHERE Preco > 100

# Usa a query
CE-Resultado-{QN-TempQuer-NomeProd}

# Destroi quando não precisar mais
QN-TempQuer-DESTROI
```

### 3.5 Mensagens e Interação

#### 3.5.1 Tipos de Mensagens

**MA - Mensagem Alerta**
```plsag
MA-12345678-SELECT {DG-CodiPess} = 0 FROM DUAL
Atenção: Cliente não selecionado!
```

**MC - Mensagem Confirmação**
```plsag
MC-12345678-SELECT 1 FROM DUAL
Confirma exclusão do registro?

# Resultado em VA-RETOFUNC: '1' = Sim, '0' = Não
IF-INIC0001-SELECT {VA-RETOFUNC} = '1' FROM DUAL
  EX-12345678-DELETE FROM POCaPess WHERE CodiPess = {DG-CodiPess}
IF-FINA0001
```

**ME - Mensagem Erro (PARA execução)**
```plsag
ME1-12345678-SELECT {DG-NomePess} = '' FROM DUAL
ERRO: Nome é obrigatório!

# ME1, ME2, ..., ME9 = número de beeps antes da mensagem
```

**MI - Mensagem Informação**
```plsag
MI-12345678-SELECT 1 FROM DUAL
Registro salvo com sucesso!
Código: {DG-CodiPess}
```

**MP - Mensagem Personalizada**
```plsag
MP-12345678-Mensagem customizada sem SQL
```

#### 3.5.2 Controle de Botões

```plsag
BO-12345678-SELECT 0 FROM DUAL    # Executa botão Confirmar se = 0
BC-12345678-SELECT 0 FROM DUAL    # Executa botão Cancelar se = 0
BF-12345678-SELECT 1 FROM DUAL    # 0 = só fechar, 1 = confirmar/cancelar
```

### 3.6 Formulários e Navegação

#### 3.6.1 Abrir Formulários

**FO - Formulário**
```plsag
FO-00000123                                      # Abre form código 123
FO-00000456-/Filtro=CodiCida=1                   # Com parâmetros
FO-00000789-/CodiPess={DG-CodiPess}              # Com substituição
```

**FM - Formulário Manutenção Genérica**
```plsag
FM-00000050-WHERE CodiPess > 100                 # Código da tabela + filtro
```

**FV - Executa após voltar do formulário**
```plsag
FO-00000123
FV-CE-NomePess-{PU-STRI0001}                     # Executa ao retornar
```

---

## 4. Referência Completa de Comandos

### 4.1 Estruturas de Controle

| Comando | Sintaxe | Descrição |
|---------|---------|-----------|
| IF-INIC | `IF-INIC####-<SQL>` | Início bloco condicional |
| IF-ELSE | `IF-ELSE####-<SQL opcional>` | Senão (com ou sem condição) |
| IF-FINA | `IF-FINA####` | Fim do bloco |
| WH | `WH-XXXXXXXX-<SQL>` | Início loop |
| WH (fim) | `WH-XXXXXXXX` | Fim do loop |
| PA | `PA-12345678-<SQL>` | Para se SQL = 0 |

### 4.2 Dados - Gravação no Banco

| Comando | Origem | Descrição |
|---------|--------|-----------|
| DG | DtsGrav (auto) | Grava no cabeçalho |
| DDG | DtsGrav (forçado) | Força gravação no cabeçalho |
| DM | DtsMov1 (auto) | Grava no movimento 1 |
| DDM | DtsMov1 (forçado) | Força gravação no movimento 1 |
| D2 | DtsMov2 (auto) | Grava no movimento 2 |
| DD2 | DtsMov2 (forçado) | Força gravação no movimento 2 |
| D3 | DtsMov3 (auto) | Grava no movimento 3 |
| DD3 | DtsMov3 (forçado) | Força gravação no movimento 3 |

### 4.3 Campos de Formulário (Database-Aware)

| Comando | Tipo | Modificadores |
|---------|------|---------------|
| CE | Editor/Text | D, F, V, C, R |
| CN | Numérico | D, F, V, C, R |
| CS | Sim/Não | D, F, V, C, R |
| CM | Memo | D, F, V, C, R |
| CR | RichText | D, F, V, C, R |
| CT | Tabela (Lookup) | D, F, V, C, R |
| IT | Informação Tabela | D, F, V, C, R |
| IL | Lookup Numérico | D, F, V, C, R |
| CA | Arquivo | D, F, V, C, R |
| CC | Combo | D, F, V, C, R |
| CD | Data | D, F, V, C, R |

### 4.4 Editores (Não ligados ao banco)

| Comando | Tipo |
|---------|------|
| EE | Editor Text |
| EN | Editor Numérico |
| ES | Editor Sim/Não |
| ET | Editor Texto/Memo |
| EC | Editor Combo |
| ED | Editor Data |
| EA | Editor Arquivo |
| EI | Editor Diretório |
| EL | Editor Lookup |

### 4.5 Labels e Componentes Especiais

| Comando | Descrição |
|---------|-----------|
| LB | Label (Caption) |
| LE | Label Editor |
| LN | Label Numérico |
| BT | Botão (Caption) |

### 4.6 Queries

| Comando | Descrição |
|---------|-----------|
| QY | Query principal (10 ações) |
| QD | Query Grid (mantém posição) |
| QM | Query com Marcador (bookmark) |
| QN | Query Nova (temporária) |
| QT | Query Tela (filtro) |

### 4.7 Execução

| Comando | Descrição |
|---------|-----------|
| EX | Executa comando especial (80+) |
| EP | Executa Procedure Delphi |
| TR | Trigger Delphi |
| OB | Objeto Trigger |
| OP | Objeto Procedure |
| OD | Objeto Decorator |
| EY | Executa SQL direto (OnShow) |
| EQ | Executa em query específica |
| CW | Configuração Web |
| JS | JavaScript (apenas web) |

### 4.8 Mensagens

| Comando | Tipo | Para Execução? |
|---------|------|----------------|
| MA | Alerta | Não |
| MC | Confirmação | Não |
| ME | Erro | **Sim** |
| MI | Informação | Não |
| MP | Personalizada | Não |
| MB | Botão (mtInformation) | Não |

### 4.9 Botões

| Comando | Ação |
|---------|------|
| BO | Clica Botão Confirmar |
| BC | Clica Botão Cancelar |
| BF | Controla Botão Fechar |

### 4.10 Formulários

| Comando | Descrição |
|---------|-----------|
| FO | Abre formulário pelo código |
| FM | Manutenção genérica |
| FV | Executa ao voltar do form |
| FDM | Formulário especial M |
| FDC | Formulário especial C |

### 4.11 Relatórios e Impressão

| Comando | Descrição |
|---------|-----------|
| IR | Imprime relatório |
| IP | Imprime relatório personalizado |
| IM | Imprime arquivo texto |
| GR | Gráfico (carrega) |
| GG | Gráfico (cria - desktop) |

### 4.12 Componentes Especiais

| Comando | Descrição |
|---------|-----------|
| LC | Lista CheckBox (5 ações) |
| TI | Timer (ATIV/DESA) |
| TH | Thread (SLEEP) |
| TQ | Etiqueta ACBr (12 ações) |
| VV | Validador ACBr (CPF/CNPJ/IE) |
| EM | E-Mail (10 parâmetros) |
| SO | Som (beeps) |
| NF | NFe v1.0 (6 ações: G/A/P/V/W/I) |
| N2 | NFe v2.0 (7 ações: G/A/P/V/W/I/X) |

### 4.13 Variáveis de Sistema

#### VA - Variáveis do Formulário

| Variável | Tipo | Faixa | Descrição |
|----------|------|-------|-----------|
| VA-INTE#### | Integer | 0001-0020 | Inteiro (0001-0010 privado, 0011-0020 público) |
| VA-REAL#### | Real | 0001-0020 | Decimal |
| VA-STRI#### | String | 0001-0020 | Texto |
| VA-DATA#### | Date | 0001-0010 | Data |
| VA-VALO#### | Variant | 0001-0010 | Valor sem aspas |
| VA-RESU#### | Variant | 0001-0008 | Resultado |

#### Variáveis Especiais (Somente Leitura)

| Variável | Retorna |
|----------|---------|
| VA-INSERIND | 1 = inserindo, 0 = alterando |
| VA-CODIPESS | Código do usuário logado |
| VA-PCODPESS | PCODPESS do usuário |
| VA-EMPRESA | Sigla da empresa (SAG/AGD/etc) |
| VA-NUMEBASE | 2=SQL Server, 3=Firebird, 4=Oracle |
| VA-CODITABE | Código da tabela atual |
| VA-CODISIST | Número do módulo |
| VA-NOMESIST | Nome do sistema/módulo |
| VA-USUAMONI | Usuário do banco de dados |
| VA-VERSMONI | Versão do aplicativo |
| VA-IP__MONI | IP da máquina |
| VA-MAQUMONI | Nome da máquina Windows |
| VA-WINDMONI | Usuário do Windows |
| VA-ENDEMONI | Endereço do executável |
| VA-DATETIME | Data/hora 'DD/MM/YYYY HH:MM:SS' |
| VA-DATE | Data 'DD/MM/YYYY' |
| VA-TIME | Hora 'HH:MM:SS' |
| VA-RETOFUNC | Retorno de funções EX |
| VA-CONFIRMA | Se preenchida, erro ao confirmar |
| VA-FECHCONF | Controla visibilidade botão fechar |
| VA-PDA1MANU | Data inicial filtro manutenção |
| VA-PDA2MANU | Data final filtro manutenção |

#### PU - Variáveis Públicas Globais (LIMITADO!)

⚠️ **Apenas 5 variáveis de cada tipo!**

```
PU-INTE0001 até PU-INTE0005
PU-REAL0001 até PU-REAL0005
PU-STRI0001 até PU-STRI0005
PU-DATA0001 até PU-DATA0005
PU-VALO0001 até PU-VALO0005
```

Usadas para passar valores entre formulários via FO.

#### VP - Variáveis Personalizadas

```
VP-INTE####, VP-REAL####, VP-STRI####, VP-DATA####, VP-VALO####
```

Armazenadas no banco de dados, específicas por usuário/tabela.

---

## 5. Exemplos Práticos

### 5.1 Exemplo Completo: Cadastro de Cliente

**Objetivo:** Validar e preencher campos automaticamente no cadastro de pessoa.

```plsag
# ========================================
# EVENTO: OnShow (Ao abrir formulário)
# ========================================

# Define data de cadastro se for inserção
IF-INIC0001-SELECT {VA-INSERIND} = 1 FROM DUAL
  DG-DataCada-SELECT SYSDATE FROM DUAL
  DG-CodiUsua-SELECT {VA-CODIPESS} FROM DUAL
IF-FINA0001

# Carrega dados da cidade se já selecionada
IF-INIC0002-SELECT {DG-CodiCida} > 0 FROM DUAL
  CE-NomeCida-SELECT NomeCida FROM POGeCida WHERE CodiCida = {DG-CodiCida}
  CE-UF_Cida -SELECT UF_Cida FROM POGeCida WHERE CodiCida = {DG-CodiCida}
IF-FINA0002

# Desabilita código se não for inserção
CED-CodiPess-SELECT {VA-INSERIND} FROM DUAL

# ========================================
# EVENTO: OnExit do campo TipoPess
# ========================================

# Tipo Pessoa alterado: ajusta máscaras
IF-INIC0003-SELECT {DG-TipoPess} = 'F' FROM DUAL
  # Pessoa Física
  LB-LblCPF  -'CPF:'
  CE-MaskDoc -'999.999.999-99'
  CEV-RG     -SELECT 1 FROM DUAL
IF-ELSE0003-SELECT {DG-TipoPess} = 'J' FROM DUAL
  # Pessoa Jurídica
  LB-LblCPF  -'CNPJ:'
  CE-MaskDoc -'99.999.999/9999-99'
  CEV-RG     -SELECT 0 FROM DUAL
IF-FINA0003

# ========================================
# EVENTO: OnExit do campo DocuPess (CPF/CNPJ)
# ========================================

# Valida CPF se Pessoa Física
IF-INIC0004-SELECT {DG-TipoPess} = 'F' FROM DUAL
  EX-VALICPF_-SELECT '{DG-DocuPess}' AS CPF FROM DUAL

  IF-INIC0005-SELECT {VA-RETOFUNC} = '0' FROM DUAL
    ME1-12345678-SELECT 1 FROM DUAL
CPF inválido!
  IF-FINA0005
IF-FINA0004

# Valida CNPJ se Pessoa Jurídica
IF-INIC0006-SELECT {DG-TipoPess} = 'J' FROM DUAL
  EX-VALICNPJ-SELECT '{DG-DocuPess}' AS CNPJ FROM DUAL

  IF-INIC0007-SELECT {VA-RETOFUNC} = '0' FROM DUAL
    ME1-12345678-SELECT 1 FROM DUAL
CNPJ inválido!
  IF-FINA0007
IF-FINA0006

# Busca se CPF/CNPJ já existe
QY-VerifDoc-SELECT CodiPess, NomePess FROM POCaPess WHERE DocuPess = '{DG-DocuPess}' AND CodiPess <> {DG-CodiPess}

IF-INIC0008-SELECT {QY-VerifDoc-NumeRegi} > 0 FROM DUAL
  MC-12345678-SELECT 1 FROM DUAL
Documento já cadastrado para: {QY-VerifDoc-NomePess}
Deseja visualizar o cadastro?

  IF-INIC0009-SELECT {VA-RETOFUNC} = '1' FROM DUAL
    FO-00000050-/CodiPess={QY-VerifDoc-CodiPess}
  IF-FINA0009
IF-FINA0008

QY-VerifDoc-FECH

# ========================================
# EVENTO: OnExit do campo CEP
# ========================================

# Busca endereço pelo CEP (integração externa)
IF-INIC0010-SELECT LENGTH({DG-CEP_Pess}) = 8 FROM DUAL
  # Aqui integraria com webservice de CEP
  # Por simplicidade, busca em tabela local
  QY-BuscaCEP-SELECT * FROM POGeCEP WHERE CEP = '{DG-CEP_Pess}'

  IF-INIC0011-SELECT {QY-BuscaCEP-NumeRegi} > 0 FROM DUAL
    DG-EndePess-{QY-BuscaCEP-Logradouro}
    DG-BairrPes-{QY-BuscaCEP-Bairro}
    DG-CodiCida-{QY-BuscaCEP-CodiCida}
    CE-NomeCida-{QY-BuscaCEP-NomeCida}
    CE-UF_Cida -{QY-BuscaCEP-UF}

    # Foca no número
    CEF-NumeEnde-SELECT 1 FROM DUAL
  IF-FINA0011

  QY-BuscaCEP-FECH
IF-FINA0010

# ========================================
# EVENTO: OnConfirm (Antes de salvar)
# ========================================

# Validação: Nome obrigatório
IF-INIC0012-SELECT TRIM({DG-NomePess}) = '' FROM DUAL
  VA-CONFIRMA-'Nome é obrigatório'
  CEF-NomePess-SELECT 1 FROM DUAL
IF-FINA0012

# Validação: Documento obrigatório
IF-INIC0013-SELECT TRIM({DG-DocuPess}) = '' FROM DUAL
  VA-CONFIRMA-'CPF/CNPJ é obrigatório'
  CEF-DocuPess-SELECT 1 FROM DUAL
IF-FINA0013

# Validação: Cidade obrigatória
IF-INIC0014-SELECT {DG-CodiCida} = 0 FROM DUAL
  VA-CONFIRMA-'Cidade é obrigatória'
  CEF-CodiCida-SELECT 1 FROM DUAL
IF-FINA0014

# Se chegou aqui sem erros, confirma
IF-INIC0015-SELECT TRIM({VA-CONFIRMA}) = '' FROM DUAL
  MI-12345678-SELECT 1 FROM DUAL
Cadastro salvo com sucesso!
Cliente: {DG-NomePess}
Código: {DG-CodiPess}
IF-FINA0015
```

### 5.2 Exemplo: Pedido de Venda com Itens

```plsag
# ========================================
# EVENTO: OnShow do Pedido
# ========================================

# Inicializa pedido
IF-INIC0001-SELECT {VA-INSERIND} = 1 FROM DUAL
  DG-DataPedi-SELECT SYSDATE FROM DUAL
  DG-CodiUsua-SELECT {VA-CODIPESS} FROM DUAL
  DG-SituPedi-'A'  # A = Aberto
  DG-ValoTota-0
IF-FINA0001

# Calcula valor total do pedido
VA-REAL0001-0

WH-NOVO0001-SELECT CodiItem, QtdeItem, ValoUnit, (QtdeItem * ValoUnit) AS ValoItem FROM POCaItPe WHERE CodiPedi = {DG-CodiPedi}
  VA-REAL0001-SELECT {VA-REAL0001} + {QY-NOVO0001-ValoItem} FROM DUAL
WH-NOVO0001

DG-ValoTota-SELECT {VA-REAL0001} FROM DUAL

# ========================================
# EVENTO: OnExit do campo CodiPess (Cliente)
# ========================================

# Carrega dados do cliente
IF-INIC0002-SELECT {DG-CodiPess} > 0 FROM DUAL
  QY-Cliente -SELECT * FROM POCaPess WHERE CodiPess = {DG-CodiPess}

  CE-NomePess-{QY-Cliente-NomePess}
  CE-Endereco-{QY-Cliente-EndePess} || ', ' || {QY-Cliente-NumeEnde}
  CE-Telefone-{QY-Cliente-FonePess}

  # Verifica limite de crédito
  VA-REAL0002-SELECT LimiCred FROM POCaPess WHERE CodiPess = {DG-CodiPess}
  VA-REAL0003-SELECT SaldDevi FROM POCaPess WHERE CodiPess = {DG-CodiPess}
  VA-REAL0004-SELECT {VA-REAL0002} - {VA-REAL0003} FROM DUAL

  IF-INIC0003-SELECT {VA-REAL0004} < {DG-ValoTota} FROM DUAL
    MA-12345678-SELECT 1 FROM DUAL
ATENÇÃO: Cliente sem limite de crédito suficiente!
Limite disponível: R$ {VA-REAL0004}
Valor do pedido: R$ {DG-ValoTota}
  IF-FINA0003

  QY-Cliente-FECH
IF-FINA0002

# ========================================
# GRID DE ITENS - OnExit do CodiProd
# ========================================

# Carrega dados do produto
IF-INIC0004-SELECT {DM-CodiProd} > 0 FROM DUAL
  QY-Produto-SELECT * FROM POGeProd WHERE CodiProd = {DM-CodiProd}

  DM-DescProd-{QY-Produto-NomeProd}
  DM-ValoUnit-{QY-Produto-PrecVend}
  DM-CodiUnid-{QY-Produto-CodiUnid}

  # Verifica estoque
  VA-REAL0005-SELECT Estoque FROM POGeEsto WHERE CodiProd = {DM-CodiProd} AND CodiLoca = {DG-CodiLoca}

  IF-INIC0005-SELECT NVL({VA-REAL0005}, 0) <= 0 FROM DUAL
    MA-12345678-SELECT 1 FROM DUAL
ATENÇÃO: Produto sem estoque!
  IF-FINA0005

  # Foca na quantidade
  CEF-QtdeItem-SELECT 1 FROM DUAL

  QY-Produto-FECH
IF-FINA0004

# ========================================
# GRID DE ITENS - OnExit do QtdeItem
# ========================================

# Calcula valor do item
DM-ValoItem-SELECT {DM-QtdeItem} * {DM-ValoUnit} FROM DUAL

# Recalcula total do pedido
VA-REAL0006-0

WH-NOVO0002-SELECT ValoItem FROM POCaItPe WHERE CodiPedi = {DG-CodiPedi}
  VA-REAL0006-SELECT {VA-REAL0006} + {QY-NOVO0002-ValoItem} FROM DUAL
WH-NOVO0002

DG-ValoTota-SELECT {VA-REAL0006} FROM DUAL

# ========================================
# BOTÃO: Confirmar Pedido
# ========================================

# Valida antes de confirmar
IF-INIC0006-SELECT {DG-CodiPess} = 0 FROM DUAL
  ME1-12345678-SELECT 1 FROM DUAL
Cliente não selecionado!
IF-FINA0006

# Verifica se tem itens
VA-INTE0001-SELECT COUNT(*) FROM POCaItPe WHERE CodiPedi = {DG-CodiPedi}

IF-INIC0007-SELECT {VA-INTE0001} = 0 FROM DUAL
  ME1-12345678-SELECT 1 FROM DUAL
Pedido sem itens!
IF-FINA0007

# Confirma
MC-12345678-SELECT 1 FROM DUAL
Confirma finalização do pedido?

IF-INIC0008-SELECT {VA-RETOFUNC} = '1' FROM DUAL
  # Atualiza situação
  DG-SituPedi-'F'  # F = Finalizado
  DG-DataFina-SELECT SYSDATE FROM DUAL

  # Baixa estoque
  WH-NOVO0003-SELECT CodiProd, QtdeItem FROM POCaItPe WHERE CodiPedi = {DG-CodiPedi}
    EX-12345678-UPDATE POGeEsto SET Estoque = Estoque - {QY-NOVO0003-QtdeItem} WHERE CodiProd = {QY-NOVO0003-CodiProd} AND CodiLoca = {DG-CodiLoca}
  WH-NOVO0003

  # Atualiza saldo devedor do cliente
  EX-12345678-UPDATE POCaPess SET SaldDevi = SaldDevi + {DG-ValoTota} WHERE CodiPess = {DG-CodiPess}

  MI-12345678-SELECT 1 FROM DUAL
Pedido confirmado com sucesso!
Número: {DG-NumePedi}
Valor Total: R$ {DG-ValoTota}
IF-FINA0008
```

### 5.3 Exemplo: Relatório Dinâmico

```plsag
# ========================================
# TELA: Parâmetros do Relatório
# ========================================

# OnShow
DG-DataInic-SELECT TRUNC(SYSDATE, 'MM') FROM DUAL      # Primeiro dia do mês
DG-DataFina-SELECT LAST_DAY(SYSDATE) FROM DUAL         # Último dia do mês

# Botão Imprimir
# Valida datas
IF-INIC0001-SELECT {DG-DataInic} > {DG-DataFina} FROM DUAL
  ME1-12345678-SELECT 1 FROM DUAL
Data inicial maior que data final!
IF-FINA0001

# Monta filtro dinâmico
VA-STRI0001-'WHERE 1=1'

# Adiciona filtro de data
VA-STRI0001-SELECT {VA-STRI0001} || ' AND DataPedi BETWEEN ' || TO_DATE('{DG-DataInic}','DD/MM/YYYY') || ' AND ' || TO_DATE('{DG-DataFina}','DD/MM/YYYY') FROM DUAL

# Adiciona filtro de cliente se informado
IF-INIC0002-SELECT {DG-CodiPess} > 0 FROM DUAL
  VA-STRI0001-SELECT {VA-STRI0001} || ' AND CodiPess = {DG-CodiPess}' FROM DUAL
IF-FINA0002

# Adiciona filtro de situação se informado
IF-INIC0003-SELECT TRIM({DG-SituPedi}) <> '' FROM DUAL
  VA-STRI0001-SELECT {VA-STRI0001} || ' AND SituPedi = ''{DG-SituPedi}''' FROM DUAL
IF-FINA0003

# Imprime relatório
IR2-00000123-{VA-STRI0001}
```

### 5.4 Exemplo: Integração com NFe

```plsag
# ========================================
# BOTÃO: Gerar NFe
# ========================================

# Valida se pode gerar NFe
IF-INIC0001-SELECT {DG-SituNFe} <> 'A' FROM DUAL
  ME1-12345678-SELECT 1 FROM DUAL
NFe já foi gerada para este documento!
Situação atual: {DG-SituNFe}
IF-FINA0001

# Gera XML da NFe
N2G-12345678-SELECT {DG-CodiNota} AS CodiNota FROM DUAL

# Verifica se gerou com sucesso
IF-INIC0002-SELECT {VA-RETOFUNC} = '1' FROM DUAL

  # Assina NFe
  N2A-12345678-/CertDigi=C:\Certificado.pfx/TipoAssi=0

  IF-INIC0003-SELECT {VA-RETOFUNC} = '1' FROM DUAL

    # Valida schema
    N2V-12345678-/EndeArqu=C:\NFe\{DG-ChavNFe}.xml/TipoVali=1

    IF-INIC0004-SELECT {VA-RETOFUNC} = '1' FROM DUAL

      # Envia para SEFAZ
      N2W-12345678-/Acao=ENVIAR/Sincrono=1

      IF-INIC0005-SELECT {VA-RETOFUNC} LIKE '%AUTORIZADO%' FROM DUAL
        # Sucesso!
        DG-SituNFe-'A'  # Autorizada
        DG-DataAuto-SELECT SYSDATE FROM DUAL

        MI-12345678-SELECT 1 FROM DUAL
NFe autorizada com sucesso!
Chave: {DG-ChavNFe}
Protocolo: {VA-RETOFUNC}

      IF-ELSE0005
        # Erro na autorização
        DG-SituNFe-'E'  # Erro

        ME1-12345678-SELECT 1 FROM DUAL
Erro ao autorizar NFe!
{VA-RETOFUNC}
      IF-FINA0005

    IF-ELSE0004
      ME1-12345678-SELECT 1 FROM DUAL
Erro na validação do XML!
{VA-RETOFUNC}
    IF-FINA0004

  IF-ELSE0003
    ME1-12345678-SELECT 1 FROM DUAL
Erro ao assinar NFe!
{VA-RETOFUNC}
  IF-FINA0003

IF-ELSE0002
  ME1-12345678-SELECT 1 FROM DUAL
Erro ao gerar XML da NFe!
{VA-RETOFUNC}
IF-FINA0002
```

### 5.5 Exemplo: Loop com Processamento em Lote

```plsag
# ========================================
# Processar todos os pedidos pendentes
# ========================================

VA-INTE0001-0  # Contador de sucesso
VA-INTE0002-0  # Contador de erro

# Lista pedidos pendentes
WH-NOVO0001-SELECT CodiPedi, NumePedi, CodiPess, ValoTota FROM POCaPedi WHERE SituPedi = 'P' ORDER BY NumePedi

  # Tenta processar pedido
  VA-INTE0003-SELECT {QY-NOVO0001-CodiPedi} FROM DUAL

  # Verifica estoque de todos os itens
  VA-INTE0004-1  # Flag sucesso

  WH-NOVO0002-SELECT CodiProd, QtdeItem FROM POCaItPe WHERE CodiPedi = {VA-INTE0003}

    VA-REAL0001-SELECT NVL(Estoque, 0) FROM POGeEsto WHERE CodiProd = {QY-NOVO0002-CodiProd}

    IF-INIC0001-SELECT {VA-REAL0001} < {QY-NOVO0002-QtdeItem} FROM DUAL
      VA-INTE0004-0  # Flag erro

      # Log do erro
      EX-12345678-INSERT INTO POCaLog (Tipo, Mensagem, Data) VALUES ('ERRO', 'Pedido {QY-NOVO0001-NumePedi} - Produto {QY-NOVO0002-CodiProd} sem estoque', SYSDATE)
    IF-FINA0001

  WH-NOVO0002

  # Se todos os itens têm estoque
  IF-INIC0002-SELECT {VA-INTE0004} = 1 FROM DUAL

    # Confirma pedido
    EX-12345678-UPDATE POCaPedi SET SituPedi = 'C', DataConf = SYSDATE WHERE CodiPedi = {VA-INTE0003}

    # Baixa estoque
    WH-NOVO0003-SELECT CodiProd, QtdeItem FROM POCaItPe WHERE CodiPedi = {VA-INTE0003}
      EX-12345678-UPDATE POGeEsto SET Estoque = Estoque - {QY-NOVO0003-QtdeItem} WHERE CodiProd = {QY-NOVO0003-CodiProd}
    WH-NOVO0003

    # Incrementa contador
    VA-INTE0001-SELECT {VA-INTE0001} + 1 FROM DUAL

  IF-ELSE0002
    # Incrementa contador de erro
    VA-INTE0002-SELECT {VA-INTE0002} + 1 FROM DUAL
  IF-FINA0002

WH-NOVO0001

# Exibe resultado
MI-12345678-SELECT 1 FROM DUAL
Processamento concluído!

Pedidos confirmados: {VA-INTE0001}
Pedidos com erro: {VA-INTE0002}
Total processado: {VA-INTE0003}
```

---

## 6. Boas Práticas

### 6.1 Nomenclatura

#### 6.1.1 Identificadores de Campos

✅ **BOM:**
```plsag
DG-CodiPess-...    # Código da Pessoa
DG-NomePess-...    # Nome da Pessoa
DG-DataCada-...    # Data de Cadastro
CE-ValoTota-...    # Valor Total
```

❌ **RUIM:**
```plsag
DG-CP-...          # Muito curto, não descritivo
DG-CODIGO_PESSOA_CLIENTE-...  # Muito longo
DG-x1-...          # Sem significado
```

**Convenção recomendada:**
- 4 primeiras letras: Tipo/Categoria (`Codi`, `Nome`, `Data`, `Valo`)
- 4 últimas letras: Entidade abreviada (`Pess`, `Prod`, `Esta`, `Ordi`)
- CamelCase para legibilidade

#### 6.1.2 Labels de Controle

✅ **BOM:**
```plsag
IF-INIC0001-...    # Numeração sequencial
IF-ELSE0001-...
IF-FINA0001-...

IF-INIC0002-...    # Próximo IF
IF-FINA0002-...

WH-LOOP0001-...    # Descritivo + número
WH-NOVO0001-...    # Tipo + número
```

❌ **RUIM:**
```plsag
IF-INICAAAA-...    # Sem padrão numérico
IF-INIC9999-...    # Número muito alto sem necessidade
WH-X-...           # Não descritivo
```

**Convenção recomendada:**
- IFs: `INIC####`, `ELSE####`, `FINA####` com mesmo número
- WHs: `NOVO####`, `LOOP####`, `BASE####` descritivo + número
- Sequência: 0001, 0002, 0003... (facilita manutenção)

#### 6.1.3 Variáveis

✅ **BOM:**
```plsag
VA-INTE0001-...    # Contador de registros
VA-INTE0002-...    # Código auxiliar
VA-REAL0001-...    # Valor calculado
VA-STRI0001-...    # Filtro SQL dinâmico
VA-DATA0001-...    # Data de referência
```

**Documentar uso de variáveis públicas (0011-0020):**
```plsag
# VA-INTE0011: Total de pedidos do mês
# VA-INTE0012: Código do último registro inserido
# VA-STRI0011: Mensagem de erro global
```

### 6.2 Organização do Código

#### 6.2.1 Separação por Evento

```plsag
# ========================================
# EVENTO: OnShow
# ========================================
[código do OnShow]

# ========================================
# EVENTO: OnExit - Campo CodiPess
# ========================================
[código do OnExit CodiPess]

# ========================================
# EVENTO: OnConfirm
# ========================================
[código do OnConfirm]
```

#### 6.2.2 Agrupamento Lógico

```plsag
# ----------------------------------------
# Inicialização de variáveis
# ----------------------------------------
VA-INTE0001-0
VA-REAL0001-0
VA-STRI0001-''

# ----------------------------------------
# Validações de campos obrigatórios
# ----------------------------------------
IF-INIC0001-...
IF-INIC0002-...
IF-INIC0003-...

# ----------------------------------------
# Cálculos
# ----------------------------------------
CN-ValoTota-...
CN-ValoDesc-...
```

#### 6.2.3 Indentação Visual

Embora PL/SAG não exija indentação, use espaços consistentes para legibilidade:

```plsag
IF-INIC0001-SELECT {DG-CodiPess} > 0 FROM DUAL
  IF-INIC0002-SELECT {DG-AtivPess} = 1 FROM DUAL
    CE-Status-'Cliente Ativo'
  IF-ELSE0002
    CE-Status-'Cliente Inativo'
  IF-FINA0002
IF-FINA0001
```

### 6.3 Performance

#### 6.3.1 Evite Queries Repetidas

❌ **RUIM:**
```plsag
CE-NomePess-SELECT NomePess FROM POCaPess WHERE CodiPess = {DG-CodiPess}
CE-Endereco-SELECT EndePess FROM POCaPess WHERE CodiPess = {DG-CodiPess}
CE-Telefone-SELECT FonePess FROM POCaPess WHERE CodiPess = {DG-CodiPess}
```

✅ **BOM:**
```plsag
QY-Cliente-SELECT NomePess, EndePess, FonePess FROM POCaPess WHERE CodiPess = {DG-CodiPess}

CE-NomePess-{QY-Cliente-NomePess}
CE-Endereco-{QY-Cliente-EndePess}
CE-Telefone-{QY-Cliente-FonePess}

QY-Cliente-FECH
```

#### 6.3.2 Use Variáveis para Cálculos Repetidos

❌ **RUIM:**
```plsag
CN-ValoTota-SELECT {CN-QtdeProd} * {CN-ValoUnit} FROM DUAL
CN-ValoDesc-SELECT ({CN-QtdeProd} * {CN-ValoUnit}) * 0.10 FROM DUAL
CN-ValoFina-SELECT ({CN-QtdeProd} * {CN-ValoUnit}) - (({CN-QtdeProd} * {CN-ValoUnit}) * 0.10) FROM DUAL
```

✅ **BOM:**
```plsag
VA-REAL0001-SELECT {CN-QtdeProd} * {CN-ValoUnit} FROM DUAL

CN-ValoTota-SELECT {VA-REAL0001} FROM DUAL
CN-ValoDesc-SELECT {VA-REAL0001} * 0.10 FROM DUAL
CN-ValoFina-SELECT {VA-REAL0001} - ({VA-REAL0001} * 0.10) FROM DUAL
```

#### 6.3.3 Limite o Escopo de Loops

❌ **RUIM:**
```plsag
WH-NOVO0001-SELECT * FROM POCaPedi  # Todas as colunas, todos os registros!
  ...
WH-NOVO0001
```

✅ **BOM:**
```plsag
WH-NOVO0001-SELECT CodiPedi, NumePedi, ValoTota FROM POCaPedi WHERE DataPedi >= SYSDATE - 30 AND SituPedi = 'A'
  ...
WH-NOVO0001
```

### 6.4 Manutenibilidade

#### 6.4.1 Validações Centralizadas

Agrupe validações no mesmo local (OnConfirm):

```plsag
# OnConfirm
VA-STRI0010-''  # String de erros

IF-INIC0001-SELECT TRIM({DG-NomePess}) = '' FROM DUAL
  VA-STRI0010-SELECT {VA-STRI0010} || '- Nome é obrigatório' || CHR(13) FROM DUAL
IF-FINA0001

IF-INIC0002-SELECT {DG-CodiCida} = 0 FROM DUAL
  VA-STRI0010-SELECT {VA-STRI0010} || '- Cidade é obrigatória' || CHR(13) FROM DUAL
IF-FINA0002

IF-INIC0003-SELECT TRIM({DG-DocuPess}) = '' FROM DUAL
  VA-STRI0010-SELECT {VA-STRI0010} || '- CPF/CNPJ é obrigatório' || CHR(13) FROM DUAL
IF-FINA0003

IF-INIC0004-SELECT TRIM({VA-STRI0010}) <> '' FROM DUAL
  VA-CONFIRMA-SELECT 'Erros encontrados:' || CHR(13) || {VA-STRI0010} FROM DUAL
IF-FINA0004
```

#### 6.4.2 Reutilização via Procedures

Para lógica complexa repetida, crie procedures Delphi e chame via EP/TR:

```plsag
# Ao invés de repetir 50 linhas de cálculo complexo:
EP-CalcComis-{DG-CodiPedi}|{DG-CodiVend}

# A procedure CalcComis retorna valor em VA-RETOFUNC
DG-ValoComis-SELECT {VA-RETOFUNC} FROM DUAL
```

#### 6.4.3 Documentação Inline (quando possível)

Use MA com condição falsa como "comentário documentado":

```plsag
MA-12345678-SELECT 1=0 FROM DUAL
CÁLCULO DE COMISSÃO:
- Base: Valor Total - Descontos
- Percentual: 5% para vendas < R$ 1000
             10% para vendas >= R$ 1000

# [código do cálculo aqui]
```

### 6.5 Segurança

#### 6.5.1 Validação de Input

Sempre valide dados do usuário:

```plsag
# Validação de range numérico
IF-INIC0001-SELECT {CN-Desconto} < 0 OR {CN-Desconto} > 100 FROM DUAL
  ME1-12345678-SELECT 1 FROM DUAL
Desconto deve estar entre 0% e 100%!
IF-FINA0001

# Validação de data
IF-INIC0002-SELECT {CD-DataEntr} < SYSDATE FROM DUAL
  ME1-12345678-SELECT 1 FROM DUAL
Data de entrega não pode ser no passado!
IF-FINA0002
```

#### 6.5.2 SQL Injection (Cuidado!)

⚠️ **CUIDADO:** PL/SAG permite SQL dinâmico, o que pode ser vulnerável.

❌ **PERIGOSO:**
```plsag
# Se CE-Filtro vier do usuário sem validação:
QY-Produtos-SELECT * FROM POGeProd WHERE {CE-Filtro}
# Usuário pode digitar: "1=1 OR 1=1; DELETE FROM POGeProd"
```

✅ **SEGURO:**
```plsag
# Use variáveis validadas:
IF-INIC0001-SELECT {CE-CodiCate} > 0 FROM DUAL
  QY-Produtos-SELECT * FROM POGeProd WHERE CodiCate = {CE-CodiCate}
IF-FINA0001
```

#### 6.5.3 Controle de Acesso

Verifique permissões antes de operações críticas:

```plsag
# Verifica se usuário pode excluir
EX-VERIACES-'{DG-CodiTabe}'
# Retorna string com permissões: "1=Inc,2=Alt,3=Cons,4=Exc,..."

IF-INIC0001-SELECT INSTR({VA-RETOFUNC}, '4=Exc') = 0 FROM DUAL
  ME1-12345678-SELECT 1 FROM DUAL
Você não tem permissão para excluir registros desta tabela!
IF-FINA0001
```

### 6.6 Testes

#### 6.6.1 Testes Unitários

Crie formulários de teste para validar lógica complexa:

```plsag
# Formulário POCaTeste - Teste de Cálculo de Comissão

# Cenário 1: Venda < R$ 1000
DG-ValoVend-900
EP-CalcComis-...
IF-INIC0001-SELECT {VA-RETOFUNC} <> 45 FROM DUAL  # Esperado: 900 * 5% = 45
  ME1-12345678-SELECT 1 FROM DUAL
TESTE FALHOU: Cenário 1
Esperado: 45
Obtido: {VA-RETOFUNC}
IF-FINA0001

# Cenário 2: Venda >= R$ 1000
DG-ValoVend-1500
EP-CalcComis-...
IF-INIC0002-SELECT {VA-RETOFUNC} <> 150 FROM DUAL  # Esperado: 1500 * 10% = 150
  ME1-12345678-SELECT 1 FROM DUAL
TESTE FALHOU: Cenário 2
Esperado: 150
Obtido: {VA-RETOFUNC}
IF-FINA0002

MI-12345678-SELECT 1 FROM DUAL
Todos os testes passaram!
```

#### 6.6.2 Debug com Mensagens

Use MI para debug temporário:

```plsag
# Debug: verificar valores intermediários
MI-12345678-SELECT 1 FROM DUAL
DEBUG - Valores:
QtdeProd: {CN-QtdeProd}
ValoUnit: {CN-ValoUnit}
ValoTota: {CN-ValoTota}
VA-REAL0001: {VA-REAL0001}

[remover após debug]
```

---

## 7. Troubleshooting

### 7.1 Erros Comuns

#### 7.1.1 Identificador com tamanho incorreto

**Sintoma:**
```
Erro: Campo não encontrado "DPI-SELE"
```

**Causa:**
```plsag
TQ-DPI-SELECT 203 FROM DUAL
```

O identificador `DPI` tem 3 caracteres. O sistema lê 8 caracteres: `"DPI-SELE"`.

**Solução:**
```plsag
TQ-DPI     -SELECT 203 FROM DUAL  # DPI + 5 espaços = 8 chars
```

#### 7.1.2 Substituição de variável não funciona

**Sintoma:**
Campo recebe valor literal `{DG-CodiPess}` ao invés do valor da variável.

**Causa:**
Chaves dentro de strings SQL precisam estar fora das aspas:

❌ **ERRADO:**
```plsag
CE-Mensagem-SELECT 'Código: {DG-CodiPess}' FROM DUAL
# Resultado: "Código: {DG-CodiPess}"
```

✅ **CORRETO:**
```plsag
CE-Mensagem-SELECT 'Código: ' || {DG-CodiPess} FROM DUAL
# Resultado: "Código: 123"
```

#### 7.1.3 Loop infinito em WH

**Sintoma:**
Sistema trava ao executar WH.

**Causa:**
Query não avança para próximo registro dentro do loop.

❌ **ERRADO:**
```plsag
WH-NOVO0001-SELECT * FROM POCaPess
  CE-Nome-{QY-NOVO0001-NomePess}
  # Falta comando para avançar!
WH-NOVO0001
```

✅ **CORRETO:**
```plsag
WH-NOVO0001-SELECT * FROM POCaPess
  CE-Nome-{QY-NOVO0001-NomePess}
  QY-NOVO0001-PROX  # Avança para próximo
WH-NOVO0001
```

Ou deixe o sistema avançar automaticamente (padrão para WH-NOVO):
```plsag
WH-NOVO0001-SELECT * FROM POCaPess
  CE-Nome-{QY-NOVO0001-NomePess}
  # Sistema avança automaticamente ao final do bloco
WH-NOVO0001
```

#### 7.1.4 IF não executa bloco esperado

**Sintoma:**
Bloco IF não executa mesmo quando condição deveria ser verdadeira.

**Causa 1:** Condição SQL retorna NULL ao invés de 0:

❌ **PROBLEMA:**
```plsag
IF-INIC0001-SELECT CodiPess FROM POCaPess WHERE CodiPess = 99999
# Se não encontrar, retorna NULL (não 0)
# NULL é tratado como FALSE
```

✅ **SOLUÇÃO:**
```plsag
IF-INIC0001-SELECT NVL(MAX(CodiPess), 0) FROM POCaPess WHERE CodiPess = 99999
# Retorna 0 se não encontrar
```

**Causa 2:** Label de fechamento diferente:

❌ **PROBLEMA:**
```plsag
IF-INIC0001-...
IF-FINA0002  # Label diferente!
```

✅ **SOLUÇÃO:**
```plsag
IF-INIC0001-...
IF-FINA0001  # Mesmo label
```

#### 7.1.5 Campo não atualiza na tela

**Sintoma:**
Comando CE/CN/CS executa mas campo não atualiza visualmente.

**Causa:**
Campo está desabilitado ou invisível.

**Solução:**
```plsag
# Antes de atribuir valor, habilite e torne visível:
CEV-CodiPess-SELECT 1 FROM DUAL  # Torna visível
CED-CodiPess-SELECT 1 FROM DUAL  # Habilita
CE-CodiPess-SELECT 123 FROM DUAL # Atribui valor
```

#### 7.1.6 Erro "Componente não localizado"

**Sintoma:**
```
Erro: Componente não localizado (CodiPess)
```

**Causa:**
Nome do componente no formulário difere do usado no PL/SAG.

**Verificação:**
1. Abra formulário no designer Delphi
2. Verifique propriedade `Name` do componente
3. Deve ser exatamente: `DbECodiPess` para campo `CodiPess`

**Padrão de nomes:**
- Campos DB: `DbE` + Nome (ex: `DbECodiPess`)
- Editores: `Edt` + Nome (ex: `EdtFiltro`)
- Queries: `Qry` + Nome (ex: `QryCodiPess`)

### 7.2 Debugging

#### 7.2.1 Rastreamento de Execução

Use variáveis para rastrear fluxo:

```plsag
VA-STRI0020-''  # Log de execução

VA-STRI0020-SELECT {VA-STRI0020} || 'Passo 1: Iniciando' || CHR(13) FROM DUAL

IF-INIC0001-...
  VA-STRI0020-SELECT {VA-STRI0020} || 'Passo 2: IF verdadeiro' || CHR(13) FROM DUAL
IF-FINA0001

VA-STRI0020-SELECT {VA-STRI0020} || 'Passo 3: Finalizando' || CHR(13) FROM DUAL

# Ao final, exibe log completo:
MI-12345678-SELECT 1 FROM DUAL
Log de Execução:
{VA-STRI0020}
```

#### 7.2.2 Verificação de Valores

Exiba valores intermediários:

```plsag
MI-12345678-SELECT 1 FROM DUAL
DEBUG:
DG-CodiPess: {DG-CodiPess}
CE-NomePess: {CE-NomePess}
VA-INTE0001: {VA-INTE0001}
VA-REAL0001: {VA-REAL0001}
VA-STRI0001: {VA-STRI0001}
```

#### 7.2.3 Teste de Queries

Teste queries isoladamente antes de usar em loops:

```plsag
# Teste a query primeiro:
QY-Teste001-SELECT * FROM POCaPess WHERE CodiCida = 1

MI-12345678-SELECT 1 FROM DUAL
Registros encontrados: {QY-Teste001-NumeRegi}
Primeiro registro: {QY-Teste001-NomePess}

QY-Teste001-FECH

# Se funcionar, use em WH:
WH-Teste001-SELECT * FROM POCaPess WHERE CodiCida = 1
  ...
WH-Teste001
```

### 7.3 Performance Issues

#### 7.3.1 Query lenta em loop

**Sintoma:**
WH demora muito para executar.

**Diagnóstico:**
```plsag
VA-DATA0001-SELECT SYSDATE FROM DUAL  # Início

WH-NOVO0001-...
WH-NOVO0001

VA-DATA0002-SELECT SYSDATE FROM DUAL  # Fim

MI-12345678-SELECT 1 FROM DUAL
Tempo decorrido: {VA-DATA0002} - {VA-DATA0001}
Registros processados: {QY-NOVO0001-NumeRegi}
```

**Soluções:**
1. Adicione índices nas tabelas
2. Reduza colunas retornadas (SELECT * → SELECT Col1, Col2)
3. Adicione filtro WHERE mais restritivo
4. Limite registros (ROWNUM <= 1000)

#### 7.3.2 Muitas chamadas ao banco

**Problema:**
Cada linha PL/SAG executa uma query separada.

**Solução:**
Agrupe em queries batch quando possível:

❌ **RUIM:**
```plsag
CE-Nome1-SELECT NomePess FROM POCaPess WHERE CodiPess = 1
CE-Nome2-SELECT NomePess FROM POCaPess WHERE CodiPess = 2
CE-Nome3-SELECT NomePess FROM POCaPess WHERE CodiPess = 3
# 3 queries!
```

✅ **BOM:**
```plsag
WH-NOVO0001-SELECT CodiPess, NomePess FROM POCaPess WHERE CodiPess IN (1,2,3) ORDER BY CodiPess
  IF-INIC0001-SELECT {QY-NOVO0001-CodiPess} = 1 FROM DUAL
    CE-Nome1-{QY-NOVO0001-NomePess}
  IF-ELSE0001-SELECT {QY-NOVO0001-CodiPess} = 2 FROM DUAL
    CE-Nome2-{QY-NOVO0001-NomePess}
  IF-ELSE0001-SELECT {QY-NOVO0001-CodiPess} = 3 FROM DUAL
    CE-Nome3-{QY-NOVO0001-NomePess}
  IF-FINA0001
WH-NOVO0001
# 1 query!
```

### 7.4 Limitações e Workarounds

#### 7.4.1 Sem estrutura CASE nativa

**Workaround:** Use IFs encadeados ou CASE SQL:

```plsag
# Opção 1: IFs
IF-INIC0001-SELECT {DG-TipoPess} = 'F' FROM DUAL
  CE-MaskDoc-'999.999.999-99'
IF-ELSE0001-SELECT {DG-TipoPess} = 'J' FROM DUAL
  CE-MaskDoc-'99.999.999/9999-99'
IF-ELSE0001
  CE-MaskDoc-''
IF-FINA0001

# Opção 2: CASE SQL
CE-MaskDoc-SELECT CASE {DG-TipoPess} WHEN 'F' THEN '999.999.999-99' WHEN 'J' THEN '99.999.999/9999-99' ELSE '' END FROM DUAL
```

#### 7.4.2 Sem Arrays/Listas

**Workaround:** Use strings delimitadas + funções SQL:

```plsag
# "Array" como string delimitada
VA-STRI0001-'1,2,3,4,5'

# Verifica se valor está no "array"
IF-INIC0001-SELECT INSTR(',{VA-STRI0001},', ',{DG-CodiPess},') > 0 FROM DUAL
  CE-Status-'Código encontrado na lista'
IF-FINA0001
```

#### 7.4.3 Sem funções definidas pelo usuário

**Workaround:** Crie procedures Delphi ou functions SQL no banco:

```plsag
# Crie function no Oracle:
# CREATE OR REPLACE FUNCTION CalcComissao(pValoVend NUMBER) RETURN NUMBER IS ...

# Use no PL/SAG:
DG-ValoComis-SELECT CalcComissao({DG-ValoVend}) FROM DUAL
```

#### 7.4.4 Sem TRY-CATCH nativo

**Workaround:** Valide antes de executar:

```plsag
# Valida antes de dividir (evita divisão por zero)
IF-INIC0001-SELECT {CN-Divisor} <> 0 FROM DUAL
  CN-Resultado-SELECT {CN-Dividendo} / {CN-Divisor} FROM DUAL
IF-ELSE0001
  CN-Resultado-0
  MA-12345678-SELECT 1 FROM DUAL
Erro: Divisão por zero!
IF-FINA0001
```

---

## 8. Apêndices

### 8.1 Tabela de Funções SQL Úteis (Oracle)

| Função | Descrição | Exemplo PL/SAG |
|--------|-----------|----------------|
| SYSDATE | Data/hora atual | `DG-DataCada-SELECT SYSDATE FROM DUAL` |
| TRUNC | Trunca data | `DG-DataInic-SELECT TRUNC(SYSDATE, 'MM') FROM DUAL` |
| TO_DATE | Converte para data | `DG-DataNasc-SELECT TO_DATE('01/01/2000','DD/MM/YYYY') FROM DUAL` |
| TO_CHAR | Formata data/número | `CE-DataForm-SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') FROM DUAL` |
| NVL | Substitui NULL | `CN-QtdeProd-SELECT NVL({DG-QtdeProd}, 0) FROM DUAL` |
| DECODE | IF inline | `CE-TipoDesc-SELECT DECODE({DG-TipoPess},'F','Física','J','Jurídica') FROM DUAL` |
| CASE | CASE inline | `CE-Status-SELECT CASE WHEN {CN-Saldo}>0 THEN 'Crédito' ELSE 'Débito' END FROM DUAL` |
| SUBSTR | Substring | `CE-Prefixo-SELECT SUBSTR({CE-Telefone}, 1, 2) FROM DUAL` |
| LENGTH | Tamanho string | `VA-INTE0001-SELECT LENGTH({CE-Nome}) FROM DUAL` |
| UPPER | Maiúsculas | `CE-NomeUppe-SELECT UPPER({CE-Nome}) FROM DUAL` |
| LOWER | Minúsculas | `CE-NomeLowe-SELECT LOWER({CE-Nome}) FROM DUAL` |
| TRIM | Remove espaços | `CE-NomeLimp-SELECT TRIM({CE-Nome}) FROM DUAL` |
| REPLACE | Substitui texto | `CE-Limpo-SELECT REPLACE({CE-Texto}, 'X', '') FROM DUAL` |
| INSTR | Posição substring | `VA-INTE0001-SELECT INSTR({CE-Email}, '@') FROM DUAL` |
| CONCAT / \|\| | Concatena | `CE-NomeComp-SELECT {CE-Nome} \|\| ' ' \|\| {CE-Sobrenome} FROM DUAL` |
| CHR | Caractere por código | `CE-QuebraLin-SELECT 'Linha1' \|\| CHR(13) \|\| 'Linha2' FROM DUAL` |
| ROUND | Arredonda | `CN-ValoArre-SELECT ROUND({CN-Valor}, 2) FROM DUAL` |
| TRUNC (num) | Trunca número | `CN-ValoTrun-SELECT TRUNC({CN-Valor}, 2) FROM DUAL` |
| MOD | Módulo/resto | `VA-INTE0001-SELECT MOD({CN-Numero}, 2) FROM DUAL` |
| ABS | Valor absoluto | `CN-ValoAbso-SELECT ABS({CN-Saldo}) FROM DUAL` |
| GREATEST | Maior valor | `CN-Maior-SELECT GREATEST({CN-Val1}, {CN-Val2}) FROM DUAL` |
| LEAST | Menor valor | `CN-Menor-SELECT LEAST({CN-Val1}, {CN-Val2}) FROM DUAL` |

### 8.2 Funções Customizadas SAG (Oracle)

| Função | Descrição | Exemplo |
|--------|-----------|---------|
| RETOPUSU() | Código do usuário logado | `DG-CodiUsua-SELECT RETOPUSU() FROM DUAL` |
| NULO(val) | Converte NULL para 0 | `CN-QtdeProd-SELECT NULO({DG-QtdeProd}) FROM DUAL` |
| RetoZero(val) | Se NULL ou vazio, retorna '0' | `VA-INTE0001-SELECT RetoZero({CE-Codigo}) FROM DUAL` |

### 8.3 Prefixos - Referência Rápida

```
Controle:    IF, WH, PA
Dados:       DG, DDG, DM, DDM, D2, DD2, D3, DD3
Campos DB:   CE, CN, CS, CM, CR, CT, IT, IL, CA, CC, CD
Editores:    EE, EN, ES, ET, EC, ED, EA, EI, EL
Labels:      LB, LE, LN, BT
Queries:     QY, QD, QM, QN, QT
Execução:    EX, EP, TR, OB, OP, OD, EY, EQ, CW, JS
Mensagens:   MA, MC, ME, MI, MP, MB
Botões:      BO, BC, BF
Forms:       FO, FM, FV, FDM, FDC
Relatórios:  IR, IP, IM, GR, GG
Especiais:   LC, TI, TH, TQ, VV, EM, SO, NF, N2
Variáveis:   VA, VP, PU
```

### 8.4 Atalhos de Desenvolvimento

**Template de Validação:**
```plsag
IF-INIC####-SELECT <condição de erro> FROM DUAL
  ME1-12345678-SELECT 1 FROM DUAL
<mensagem de erro>
IF-FINA####
```

**Template de Cálculo:**
```plsag
VA-REAL####-SELECT <cálculo complexo> FROM DUAL
DG-Campo-SELECT {VA-REAL####} FROM DUAL
```

**Template de Loop:**
```plsag
WH-NOVO####-SELECT <colunas> FROM <tabela> WHERE <filtro>
  <processamento por registro>
WH-NOVO####
```

**Template de Busca:**
```plsag
QY-Query-SELECT <colunas> FROM <tabela> WHERE <filtro>
CE-Campo1-{QY-Query-Coluna1}
CE-Campo2-{QY-Query-Coluna2}
QY-Query-FECH
```

### 8.5 Glossário

| Termo | Definição |
|-------|-----------|
| CampPers | Campo Personalizado - campo na POCATabe onde instruções PL/SAG são armazenadas |
| DtsGrav | DataSource do cabeçalho/registro principal |
| DtsMov1/2/3 | DataSources de movimentos/detalhes |
| Interpretador | Procedimento `CampPersExecListInst` que executa instruções PL/SAG |
| Label | Identificador de 8 caracteres usado em IF/WH |
| POCATabe | Tabela que armazena configurações de telas e campos personalizados |
| Prefixo | 2 primeiros caracteres de uma instrução (CE, DG, IF, etc.) |
| sgForm | Classe base de formulários do sistema SAG |
| Substituição | Processo de trocar `{VAR}` pelo valor real antes da execução |
| Template | Variável entre chaves `{}` que será substituída por valor |

### 8.6 Recursos Adicionais

**Arquivos de Referência:**
- `PlusUni.pas` (linha 3731): Código-fonte do interpretador
- `PL-SAG - Wiki.txt`: Wiki original com exemplos
- `POCATabe`: Tabela do banco com instruções PL/SAG configuradas

**Procedimentos Delphi Relacionados:**
- `CampPersExecListInst`: Interpretador principal
- `CampPersExec`: Executa expressão SQL
- `CampPersAcao`: Executa modificadores (D/F/V/C/R)
- `CampPers_EX`: Executa comandos EX especiais
- `SubsCampPers`: Substitui templates `{}`

**Variáveis do Sistema (TsgForm):**
```pascal
iForm.VariInte[1..20]  // VA-INTE0001..0020
iForm.VariReal[1..20]  // VA-REAL0001..0020
iForm.VariStri[1..20]  // VA-STRI0001..0020
iForm.VariData[1..10]  // VA-DATA0001..0010
iForm.VariValo[1..10]  // VA-VALO0001..0010
iForm.VariResu[1..8]   // VA-RESU0001..0008
iForm.RetoFunc         // VA-RETOFUNC
```

---

## 📚 Conclusão

Este manual cobriu todos os aspectos principais do PL/SAG, desde conceitos fundamentais até técnicas avançadas de desenvolvimento e troubleshooting.

**Próximos Passos Recomendados:**
1. Pratique com exemplos simples (validações, cálculos)
2. Estude códigos PL/SAG existentes no sistema
3. Documente padrões específicos da sua organização
4. Crie biblioteca de snippets reutilizáveis
5. Compartilhe conhecimento com a equipe

**Lembre-se:**
- ✅ Sempre valide entrada do usuário
- ✅ Use nomenclatura consistente e descritiva
- ✅ Documente lógica complexa
- ✅ Teste isoladamente antes de integrar
- ✅ Priorize legibilidade sobre brevidade

---

**Versão do Manual:** 1.0
**Última Atualização:** 2025-12-14
**Autor:** Análise do código-fonte PlusUni.pas + PL-SAG Wiki.txt
**Feedback:** Documente melhorias e envie sugestões

---

**FIM DO MANUAL**
