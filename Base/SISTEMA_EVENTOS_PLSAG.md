# Sistema de Eventos e PL-SAG - Documentacao AS-IS

Este documento descreve como o SAG no Delphi cria, controla e executa eventos dos componentes de formularios dinamicos, e como esses eventos disparam instrucoes PL-SAG.

> **Nota**: Este documento foi gerado com base na analise do codigo-fonte, principalmente `PlusUni.pas` (procedure `MontCampPers` e funcoes `CampPers*`) e `POHeCam6.pas`.

---

## Visao Geral

O sistema SAG utiliza um mecanismo de **criacao dinamica de formularios** onde:

1. Componentes visuais sao criados em runtime baseados em configuracao de banco de dados (tabelas `POCaTabe` e `SistCamp`)
2. Cada componente recebe uma **Lista de Instrucoes PL-SAG** (propriedade `Lista.Text`)
3. Eventos do componente (`OnExit`, `OnClick`, `OnChange`) sao associados a uma procedure central (`iExecExit`)
4. Quando o evento e disparado, o sistema executa as instrucoes PL-SAG armazenadas na Lista do componente

---

## Arquitetura do Sistema de Eventos

### Diagrama de Fluxo

```
+------------------+     +-------------------+     +--------------------+
|   SISTTABE       |     |   SISTCAMP        |     |   Componente       |
| (Configuracao    |---->| (Configuracao     |---->|   Visual           |
|  do Formulario)  |     |  dos Campos)      |     |   (TDBEdtLbl, etc) |
+------------------+     +-------------------+     +--------------------+
        |                        |                         |
        |                        |                         v
        |                        |               +--------------------+
        |                        +-------------->|  Lista.Text        |
        |                        (ExprCamp +     |  (Instrucoes       |
        |                         EPerCamp)      |   PL-SAG)          |
        |                                        +--------------------+
        |                                                  |
        v                                                  v
+------------------+                             +--------------------+
| ShowTabe         |                             | OnExit/OnClick/    |
| LancTabe         |---(Eventos do Form)-------->| OnChange           |
| EGraTabe         |                             | (iExecExit)        |
| AposTabe         |                             +--------------------+
+------------------+                                       |
                                                           v
                                               +--------------------+
                                               | CampPersExecExit   |
                                               | CampPersExecListInst|
                                               +--------------------+
                                                           |
                                                           v
                                               +--------------------+
                                               | INTERPRETA PL-SAG  |
                                               +--------------------+
```

---

## Componentes do Sistema

### 1. Propriedade `Lista` dos Componentes

Cada componente criado pelo sistema possui uma propriedade `Lista` (do tipo `TStrings`) que armazena as instrucoes PL-SAG a serem executadas quando um evento e disparado.

**Origem dos dados:**
- Campo `ExprCamp` da tabela `SistCamp` - Expressoes principais
- Campo `EPerCamp` da tabela `SistCamp` - Expressoes permanentes (mescladas)

**Codigo em PlusUni.pas (linha 805):**
```pascal
Edit.Lista.Text := CampPers_TratExec(nil,
  cds.FieldByName('ExprCamp').AsString,
  cds.FieldByName('EPerCamp').AsString);
```

### 2. Atribuicao de Eventos

Durante a criacao dos componentes em `MontCampPers`, os eventos sao atribuidos a uma procedure generica `iExecExit`:

| Tipo Componente | Eventos Atribuidos | Codigo de Referencia |
|-----------------|-------------------|----------------------|
| TDBEdtLbl (E) | OnExit, OnChange | PlusUni.pas:804-816 |
| TDBCmbLbl (C) | OnExit/OnClick, OnChange | PlusUni.pas:871-873 |
| TDBRxELbl (N) | OnExit, OnChange | PlusUni.pas:926-937 |
| TDBLcbLbl (T) | OnExit/OnClick | PlusUni.pas:988-991 |
| TDBLookNume (L) | OnExit, OnChange | PlusUni.pas:1137-1145 |
| TDBRxDLbl (D) | OnExit, OnChange | PlusUni.pas:1211-1221 |
| TDBChkLbl (S) | OnClick | PlusUni.pas:1264 |
| TDBMemLbl (M) | OnExit, OnChange | PlusUni.pas:1281-1290 |
| TsgBtn (BTN) | OnClick | PlusUni.pas:2200 |
| TLstLbl (LC) | OnClick | PlusUni.pas:2385 |

### 3. Procedure Central: iExecExit

O parametro `iExecExit` recebido por `MontCampPers` e uma procedure do tipo `TNotifyEvent` que:

1. Recebe o `Sender` (componente que disparou o evento)
2. Chama `CampPersExecExit(Self, Sender)`
3. Que por sua vez chama `CampPersExecListInst` para executar as instrucoes

**Fluxo de Execucao:**
```
Evento do Componente (OnExit/OnClick/OnChange)
    |
    v
iExecExit(Sender: TObject)
    |
    v
CampPersExecExit(iForm, Sender)  [PlusUni.pas:3698]
    |
    +-- CampPersRetoListExec(iForm, Sender)  [Obtem Lista.Text do componente]
    |
    +-- CampPersExecListInst(iForm, List)  [Executa instrucoes PL-SAG]
```

---

## Ciclo de Vida dos Eventos

### Fase 1: Criacao do Formulario (FormCreate / AfterCreate)

```
FormCreate [POHeCam6.pas:627]
    |
    +-- Cria conexao de banco (DtbCada)
    +-- Inicializa listas (ListMovi, ListLeitSeri)
    +-- Carrega movimentos de POCaTabe
    +-- Para cada movimento: cria TFraCaMv
    +-- Chama inherited FormCreate

AfterCreate [POHeCam6.pas:1065]
    |
    +-- [1] CampPersExecDireStri('AnteCria')  [linha 1084]
    |       Executa instrucoes do campo 'AnteCria' antes de criar componentes
    |
    +-- [2] QryTabeConf.Open
    |       Carrega configuracao da tabela POCaTabe
    |
    +-- [3] MontCampPers()  [linha 1094]
    |       Cria todos os componentes dinamicos
    |       Para cada componente:
    |         - Cria componente (TDBEdtLbl, etc)
    |         - Atribui Lista.Text = ExprCamp + EPerCamp
    |         - Atribui OnExit/OnClick = iExecExit
    |         - Atribui OnChange = Habi (se obrigatorio)
    |
    +-- [4] PopAtuaClick()
    |       Abre cadastros/queries auxiliares
    |
    +-- [5] CampPersExecDireStri('DepoCria')  [linha 1200]
            Executa instrucoes do campo 'DepoCria' apos criar componentes
```

### Fase 2: Exibicao do Formulario (FormShow)

```
FormShow [POHeCam6.pas:883]
    |
    +-- AnteShow()
    |
    +-- PreparaManu() / InicValoCampPers()
    |       Prepara dados e inicializa valores (ver seção detalhada abaixo)
    |
    +-- [1] CampPersExecListInst(ExecShowTela)  [linha 1020]
    |       Executa instrucoes passadas por outra tela
    |
    +-- [2] CampPersExecExitShow()  [linha 1023]
    |       Executa OnExit de todos os campos com ExprCamp
    |       (simula saida de cada campo)
    |
    +-- [3] CampPersExecNoOnShow(ShowTabe)  [linha 1027]
    |       Executa instrucoes do campo ShowTabe
    |
    +-- Atualiza grids dos movimentos
    |
    +-- CampPers_CriaBtn_LancCont()
    |
    +-- DepoShow()
    |
    +-- HabiConf() - Habilita/desabilita Confirma
    |
    +-- ConfPortSeri() - Configura portas serial/IP
```

---

## Funcoes de Inicializacao e Validacao

### InicValoCampPers - Inicializacao de Valores Default

**Localizacao:** PlusUni.pas (chamada em FormShow)
**Momento:** Executada no FormShow, ANTES dos eventos PLSAG (ShowTabe)

Esta funcao inicializa valores default para campos marcados com `InicCamp = 1` na tabela `SISTCAMP` (POCaCamp).

#### Campos Fonte (SISTCAMP)

| Campo | Tipo | Descricao |
|-------|------|-----------|
| **InicCamp** | Integer | Flag: 1 = inicializar este campo |
| **CompCamp** | String | Tipo do componente (determina logica) |
| **VaGrCamp** | Text | Valores do combo (separados por \n), primeiro = default |
| **VaReCamp** | Text | Labels de exibicao do combo |
| **PadrCamp** | Variant | Valor default para checkbox/numerico |

#### Logica por Tipo de Componente

| CompCamp | Tipo | Default Aplicado | Exemplo |
|----------|------|------------------|---------|
| **D** | Data | DateTime.Today | 02/01/2026 |
| **DH** | DateTime | DateTime.Now | 02/01/2026 14:30:00 |
| **C** | Combo | Primeiro valor de VaGrCamp | "E" de "E\nS" |
| **S** | Checkbox | PadrCamp (0 ou 1) | 1 = marcado |
| **E** | Texto | PadrCamp (se definido) | "ATIVO" |
| **N, EN** | Numerico | PadrCamp (se definido) | 0 ou valor especifico |
| **EE, LE, ED, EC, ES, LN** | Calculado | Calculado via expressao | - |

#### Fluxo de Execucao

```
InicValoCampPers (FormShow)
    |
    +-- Para cada campo com InicCamp = 1:
    |       |
    |       +-- Identifica CompCamp
    |       |
    |       +-- Switch (CompCamp):
    |           |
    |           +-- 'D', 'DH': campo.Value = DateTime.Today/Now
    |           |
    |           +-- 'C': campo.Value = VaGrCamp.Split('\n')[0]
    |           |
    |           +-- 'S': campo.Value = PadrCamp (0 ou 1)
    |           |
    |           +-- 'E', 'N', 'EN': campo.Value = PadrCamp (se nao vazio)
    |           |
    |           +-- Calculados: Executa expressao de calculo
    |
    +-- Propaga valores para Decorator (Prin_D)
```

#### Exemplo de Configuracao (SISTCAMP)

```sql
-- Campo de data que deve ser inicializado com data atual
INSERT INTO SISTCAMP (CodiTabe, NomeCamp, CompCamp, InicCamp)
VALUES (120, 'DATACONT', 'D', 1);

-- Combo com valor default "E" (Entrada)
INSERT INTO SISTCAMP (CodiTabe, NomeCamp, CompCamp, VaGrCamp, VaReCamp, InicCamp)
VALUES (120, 'TIPOCONT', 'C', 'E'||CHR(10)||'S', 'Entrada'||CHR(10)||'Saida', 1);

-- Checkbox marcado por default
INSERT INTO SISTCAMP (CodiTabe, NomeCamp, CompCamp, PadrCamp, InicCamp)
VALUES (120, 'ATIVCONT', 'S', 1, 1);
```

---

### InicCampSequ - Geracao de Numeros Sequenciais

**Localizacao:** POHeCam6.pas linha 819
**Momento:** FormShow (se novo registro) e BtnConfClick (modo 'VERI')

Esta funcao gera numeros unicos/sequenciais para campos configurados como sequenciais.

#### Condicoes para Geracao

Um campo recebe numero sequencial se TODAS as condicoes forem atendidas:

| Condicao | Campo | Valor |
|----------|-------|-------|
| Campo nao existe ainda | ExisCamp | = 0 |
| Tipo numerico | CompCamp | IN ('N', 'EN') |
| Marcado para inicializacao | InicCamp | = 1 |
| Flag de sequencial | TagQCamp | = 1 |

#### Tipos de Sequencia

| Tipo | Descricao | Fonte |
|------|-----------|-------|
| **_UN_** | Chave unica | POCaNume_ProxSequ() |
| **SEQU** | Sequencial simples | MAX(campo) + 1 |
| **VERI** | Verifica e gera se vazio | Usado no BtnConfClick |

#### Tabela POCaNume (Controle de Sequencias)

```sql
CREATE TABLE POCANUME (
    CodiNume INT PRIMARY KEY,      -- Codigo da sequencia
    NomeNume VARCHAR(50),          -- Nome descritivo
    AtualNume INT,                 -- Valor atual
    PrefNume VARCHAR(10),          -- Prefixo (ex: "CT-")
    SufixNume VARCHAR(10),         -- Sufixo
    TamaNumeNume INT               -- Tamanho do numero (zeros a esquerda)
);
```

#### Fluxo de Execucao

```
InicCampSequ(Modo: string)
    |
    +-- Para cada campo em QryCampSequ:
    |       |
    |       +-- Verifica condicoes (ExisCamp, CompCamp, InicCamp, TagQCamp)
    |       |
    |       +-- Se atendidas:
    |           |
    |           +-- Se Modo = '_UN_':
    |           |       POCaNume_ProxSequ(CodiNume)
    |           |       Incrementa AtualNume
    |           |       Retorna PrefNume + AtualNume + SufixNume
    |           |
    |           +-- Se Modo = 'SEQU':
    |           |       SELECT MAX(campo) + 1 FROM tabela
    |           |
    |           +-- Se Modo = 'VERI':
    |                   Se campo vazio, gera como '_UN_' ou 'SEQU'
    |
    +-- Atribui valor ao campo
    |
    +-- Exibe mensagem confirmando geracao
```

#### Exemplo de Configuracao

```sql
-- Campo de codigo do contrato com sequencial automatico
INSERT INTO SISTCAMP (CodiTabe, NomeCamp, CompCamp, InicCamp, TagQCamp, ExisCamp)
VALUES (120, 'CODICONT', 'N', 1, 1, 0);

-- Sequencia configurada em POCaNume
INSERT INTO POCANUME (CodiNume, NomeNume, AtualNume, PrefNume, TamaNumeNume)
VALUES (120, 'Contratos', 1000, 'CT-', 6);
-- Proximo valor: CT-001001
```

---

### Fase 3: Interacao do Usuario

```
Usuario interage com componente
    |
    v
Evento dispara (OnExit, OnClick, OnChange)
    |
    v
iExecExit(Sender)  [TFrmPOHeForm.ExecExit]
    |
    v
CampPersExecExit(Self, Sender)  [PlusUni.pas:3698]
    |
    +-- List := CampPersRetoListExec(iForm, Sender)
    |       Obtem Lista.Text do componente Sender
    |
    +-- CampPersExecListInst(iForm, List)
            Loop por cada linha da Lista:
              - Substitui variaveis (SubsCampPers)
              - Interpreta e executa instrucao PL-SAG
```

---

### BtnConf_CampModi - Validacao de Modificacao

**Localizacao:** POHeCam6.pas linha 442
**Momento:** Chamada no inicio de BtnConfClick, ANTES de qualquer gravacao

Esta funcao impede que o usuario modifique campos que foram gerados/calculados por outros processos.

#### Campos Protegidos

| Tipo | Identificacao | Descricao |
|------|---------------|-----------|
| **ApAt{FinaTabe}** | Campos com prefixo ApAt | Campos de finalizacao (totais, saldos) |
| **InteCamp=0** | SISTCAMP.InteCamp | Campos gerados por processo (nao editaveis) |
| **Campos calculados** | CompCamp IN ('EE','LE','EN','LN') | Valores calculados por expressao |

**Nota:** A coluna MARCCAMP nao existe no schema. A protecao de campos usa InteCamp=0.

#### Logica de Validacao

```
BtnConf_CampModi() -- POHeCam6.pas linha 442
    |
    +-- Obtem Decorator (valores originais vs atuais)
    |       New_D = valores novos
    |       Old_D = valores originais (quando carregou)
    |
    +-- Verifica se ApAt+FinaTabe foi modificado (linha 450)
    |       Se diferente: Return False (bloqueia)
    |
    +-- Se registro finalizado (Tabe{FinaTabe} != '' AND CodiGene != 0):
    |       |
    |       +-- Para cada campo em POCaCamp (linha 465-483):
    |       |       WHERE CompCamp NOT IN ('BVL','LBL','BTN','DBG','GRA','T')
    |       |       AND InteCamp = 0  -- <-- campos gerados por processo
    |       |       |
    |       |       +-- Se campo foi modificado:
    |       |               BLOQUEIA e exibe mensagem
    |       |               "Dados Gerados por outro Processo. Informacao nao pode ser modificada: [Label]"
    |       |               Return False
    |
    +-- Return True (pode continuar)
```

#### Mensagens de Erro

| Codigo | Mensagem | Causa |
|--------|----------|-------|
| **E001** | "Campo {NomeCamp} não pode ser alterado manualmente" | Campo ApAt modificado |
| **E002** | "Este registro foi finalizado e não pode ser editado" | FinaTabe = 1 |
| **E003** | "Campo calculado não aceita edição direta" | CompCamp calculado |

#### Exemplo de Fluxo

```
Usuario edita formulario de Nota Fiscal
    |
    +-- Modifica campo "VALOTOTA" (total da nota)
    |       Este campo e ApAtNOTA (calculado automaticamente)
    |
    +-- Clica em Confirmar
    |
    +-- BtnConf_CampModi() detecta alteracao:
    |       Old_D["VALOTOTA"] = 1500.00
    |       New_D["VALOTOTA"] = 2000.00
    |
    +-- BLOQUEIA gravacao
    |       Mensagem: "Campo VALOTOTA não pode ser alterado manualmente"
    |
    +-- Usuario deve corrigir itens para alterar total
```

---

### Fase 4: Confirmacao (BtnConfClick)

```
BtnConfClick [POHeCam6.pas:436]
    |
    +-- BtnConf_CampModi()
    |       Valida se campos foram modificados indevidamente (ver seção acima)
    |
    +-- [1] VeriEnviConf(LancTabe)  [linha 537]
    |       Executa instrucoes de lancamento (antes de gravar)
    |
    +-- [2] GravSemC()
    |       Grava dados no banco
    |
    +-- [3] VeriEnviConf(EGraTabe)  [linha 528/581]
    |       Executa instrucoes pos-gravacao
    |
    +-- [4] VeriEnviConf(AposTabe)  [linha 592]
            Executa instrucoes finais (apos confirma)
```

### Fase 5: Fechamento (FormClose)

```
FormClose [POHeCam6.pas:740]
    |
    +-- QryGrav.Cancel
    |       Cancela alteracoes pendentes
    |
    +-- DELETE do registro (se inclusao nao confirmada)
    |
    +-- Limpa DtbCada
    |
    +-- Fecha ListLeitSeri
```

---

## Mapeamento de Eventos por Tipo de Componente

### Tabela Completa de Atribuicao de Eventos

| CompCamp | Componente Delphi | OnExit | OnClick | OnChange | OnKeyPress | Lista.Text |
|----------|-------------------|--------|---------|----------|------------|------------|
| **E** | TDBEdtLbl | iExecExit | - | Habi (se obri) | UltiCamp | ExprCamp+EPerCamp |
| **C** | TDBCmbLbl | iExecExit (Web) | iExecExit (VCL) | Habi (se obri) | UltiCamp | ExprCamp+EPerCamp |
| **A** | TDBFilLbl | iExecExit | - | Habi (se obri) | UltiCamp | ExprCamp+EPerCamp |
| **N** | TDBRxELbl | iExecExit | - | Habi (se obri) | UltiCamp | ExprCamp+EPerCamp |
| **T** | TDBLcbLbl | iExecExit (Web) | iExecExit (VCL) | - | UltiCamp | ExprCamp+EPerCamp |
| **IT** | TLcbLbl | iExecExit (Web) | iExecExit (VCL) | - | UltiCamp | ExprCamp+EPerCamp |
| **L** | TDBLookNume | iExecExit | - | Habi (se obri) | - | ExprCamp+EPerCamp |
| **IL** | TDBLookNume | iExecExit | - | Habi (se obri) | - | ExprCamp+EPerCamp |
| **D** | TDBRxDLbl | iExecExit | - | Habi (se obri) | UltiCamp | ExprCamp+EPerCamp |
| **S** | TDBChkLbl | - | iExecExit | - | - | ExprCamp+EPerCamp |
| **M** | TDBMemLbl | iExecExit | - | Habi (se obri) | - | ExprCamp+EPerCamp |
| **BM** | TDBMemLbl | iExecExit | - | Habi (se obri) | - | ExprCamp+EPerCamp |
| **RM/RB** | TDBRchLbl | iExecExit | - | Habi (se obri) | - | ExprCamp+EPerCamp |
| **EE** | TEdtLbl | iExecExit | - | Habi (se obri) | UltiCamp | ExprCamp+EPerCamp |
| **LE** | TEdtLbl | iExecExit | - | - | - | ExprCamp+EPerCamp |
| **EN/LN** | TRxEdtLbl | iExecExit | - | Habi (se obri) | - | ExprCamp+EPerCamp |
| **ED** | TRxDatLbl | iExecExit | - | Habi (se obri) | UltiCamp | ExprCamp+EPerCamp |
| **EC** | TCmbLbl | iExecExit | iExecExit | Habi (se obri) | - | ExprCamp+EPerCamp |
| **ES** | TChkLbl | - | iExecExit | - | - | ExprCamp+EPerCamp |
| **ET** | TMemLbl | iExecExit | - | Habi (se obri) | - | ExprCamp+EPerCamp |
| **EA** | TFilLbl | iExecExit | - | Habi (se obri) | - | ExprCamp+EPerCamp |
| **EI** | TDirLbl | iExecExit | - | Habi (se obri) | - | ExprCamp+EPerCamp |
| **BTN** | TsgBtn | - | iExecExit | - | - | ExprCamp+EPerCamp |
| **DBG** | TsgDBG | - | - | - | - | Exp1Camp+EPerCamp (DuplCliq) |
| **LC** | TLstLbl | - | iExecExit | - | - | ExprCamp+EPerCamp |
| **TIM** | TsgTim | - | - | - | - | ExprCamp+EPerCamp (OnTimer) |
| **GRA** | TFraGraf | - | - | - | - | ExprCamp+EPerCamp |

### Legenda de Eventos

| Evento | Quando Dispara | Procedure Chamada |
|--------|----------------|-------------------|
| **OnExit** | Usuario sai do campo (perde foco) | iExecExit -> CampPersExecExit |
| **OnClick** | Usuario clica no componente | iExecExit -> CampPersExecExit |
| **OnChange** | Valor do campo muda | Habi (HabiConf) - habilita Confirma |
| **OnKeyPress** | Tecla pressionada | UltiCamp (ultimo campo -> Confirma) |
| **OnTimer** | Intervalo de tempo expira | CampPersExecListInst |

---

## Funcoes de Execucao de Eventos

### Hierarquia de Chamadas

```
CampPersExecExit(iForm, Sender)
    |
    +-- CampPersRetoListExec(iForm, Sender)
    |       |
    |       +-- CampPersCompAtuaGetProp(iForm, Sender, 'Lista')
    |       |       Obtem Lista.Text via RTTI
    |       |
    |       +-- CampPers_TratExec(iForm, Result, '')
    |               Trata substituicoes e referencias
    |
    +-- CampPersExecListInst(iForm, List)
            |
            +-- Loop por cada linha
            |
            +-- CampPersValiExecLinh(Linh)
            |       Valida se linha deve ser executada
            |
            +-- SubsCampPers(iForm, Linh)
            |       Substitui variaveis ([#Campo#], etc.)
            |
            +-- Interpreta e executa instrucao PL-SAG
```

### Funcoes Principais

| Funcao | Localizacao | Descricao |
|--------|-------------|-----------|
| `CampPersExecExit` | PlusUni.pas:3698 | Ponto de entrada - obtem Lista e executa |
| `CampPersRetoListExec` | PlusUni.pas:3724 | Retorna Lista.Text do componente |
| `CampPersExecListInst` | PlusUni.pas:3731 | Executa lista de instrucoes PL-SAG |
| `CampPersExecExitShow` | PlusUni.pas:5382 | Executa OnExit de todos os campos |
| `CampPersExecNoOnShow` | PlusUni.pas:8021 | Executa ShowTabe no FormShow |
| `CampPersExecDireStri` | PlusUni.pas:5400 | Executa instrucoes diretamente (string) |
| `CampPersValiExecLinh` | PlusUni.pas:3556 | Valida se linha deve ser executada |
| `SubsCampPers` | PlusUni.pas:2700 | Substitui variaveis em instrucoes |
| `CampPers_TratExec` | PlusUni.pas:5650 | Mescla ExprCamp + EPerCamp |

---

## Campos de Eventos na Tabela POCaTabe (SISTTABE)

| Campo | Momento de Execucao | Descricao |
|-------|---------------------|-----------|
| **ShowTabe** | FormShow | Executado apos exibir formulario |
| **LancTabe** | BtnConfClick (antes gravar) | Instrucoes de lancamento |
| **EGraTabe** | BtnConfClick (apos gravar) | Instrucoes pos-gravacao |
| **AposTabe** | BtnConfClick (final) | Instrucoes finais |
| **EPerTabe** | Todos os momentos | Expressoes permanentes (variaveis globais) |

### Fluxo de Execucao no BtnConfClick

```pascal
// POHeCam6.pas - BtnConfClick simplificado
procedure TFrmPOHeCam6.BtnConfClick(Sender: TObject);
begin
  // 1. Validacao
  if not BtnConf_CampModi() then Exit;

  // 2. Executa LancTabe (antes de gravar)
  VeriEnviConf(CampPers_TratExec(QryTabeConf.FieldByName('LancTabe').AsString,
                                 QryTabeConf.FieldByName('EPerTabe').AsString));

  // 3. Grava dados
  GravSemC();

  // 4. Executa EGraTabe (apos gravar)
  VeriEnviConf(CampPers_TratExec(QryTabeConf.FieldByName('EGraTabe').AsString,
                                 QryTabeConf.FieldByName('EPerTabe').AsString));

  // 5. Executa AposTabe (final)
  VeriEnviConf(CampPers_TratExec(QryTabeConf.FieldByName('AposTabe').AsString,
                                 QryTabeConf.FieldByName('EPerTabe').AsString));
end;
```

---

## Campos de Eventos na Tabela SistCamp (POCaCamp)

| Campo | Uso | Descricao |
|-------|-----|-----------|
| **ExprCamp** | Lista.Text | Instrucoes PL-SAG do campo |
| **EPerCamp** | Lista.Text | Expressoes permanentes do campo |
| **Exp1Camp** | Grid/Lista | Instrucoes para duplo clique (DBG) ou Lista2 (LC) |

### Campos Especiais de Controle

| NameCamp | Quando Executado | Descricao |
|----------|------------------|-----------|
| **AnteCria** | AfterCreate (inicio) | Antes de criar componentes |
| **DepoCria** | AfterCreate (fim) | Apos criar componentes |

---

## Evento OnChange e Validacao de Obrigatorios

Quando um campo e marcado como obrigatorio (`ObriCamp <> 0`):

1. O evento `OnChange` e atribuido a procedure `Habi`
2. A procedure `Habi` chama `HabiConf` para verificar campos obrigatorios
3. O botao Confirma e habilitado/desabilitado conforme validacao

```pascal
// Codigo em MontCampPers (PlusUni.pas)
if cds.FieldByName('ObriCamp').Value <> 0 then
  Edit.OnChange := Habi;

Edit.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
Edit.sgConf.OnHabi := Habi;
```

---

## Eventos Especiais

### 1. Ultimo Campo (UltiCamp)

O ultimo campo do formulario recebe `OnKeyPress := UltiCamp` que:
- Ao pressionar Tab no ultimo campo, simula clique no Confirma

```pascal
if NumeRegi = TotaRegi then
  Edit.OnKeyPress := UltiCamp;
```

### 2. Duplo Clique (DuplClic)

Componentes como DBG e alguns outros recebem tratamento de duplo clique:

```pascal
procedure TFrmPOHeCam6.DuplClic(Sender: TObject);
begin
  CampPersDuplCliq(Self, Sender);
end;
```

### 3. Timer (TIM)

Componentes Timer executam suas instrucoes periodicamente:

```pascal
Tim.Lista.Text := CampPers_TratExec(nil,
  cds.FieldByName('ExprCamp').AsString,
  cds.FieldByName('EPerCamp').AsString);
// Intervalo definido por PadrCamp (em segundos)
Tim.Interval := cds.FieldByName('PadrCamp').AsInteger * 1000;
```

### 4. Leitura Serial (TsgLeitSeri)

Para componentes de leitura serial/IP, quando dados sao recebidos:

```pascal
procedure TFrmPOHeCam6.Grav(iConfig: TsgLeitSeri; Valo: string);
begin
  if Assigned(iConfig) and Assigned(iConfig.EdtLbl) then
  begin
    iConfig.EdtLbl.Text := Valo;
    CampPersExecListInst(Self, iConfig.EdtLbl.Lista);
  end;
end;
```

---

## Diferenca entre VCL e UniGUI

O sistema suporta compilacao condicional para Web (UniGUI) e Desktop (VCL):

```pascal
{$ifdef ERPUNI}
  // Web: OnExit funciona normalmente
  Comb.OnExit := iExecExit;
{$else}
  // VCL: Combo usa OnClick ao inves de OnExit
  Comb.OnClick := iExecExit;
{$endif}
```

| Componente | VCL | UniGUI |
|------------|-----|--------|
| TDBCmbLbl | OnClick | OnExit |
| TDBLcbLbl | OnClick | OnExit |
| TCmbLbl | OnClick + OnChange | OnChange |

---

## Resumo do Fluxo Completo

```
1. CRIACAO DO FORMULARIO
   +-- FormCreate: Cria estruturas base
   +-- AfterCreate:
       +-- Executa 'AnteCria' (PL-SAG)
       +-- MontCampPers: Cria componentes
           +-- Para cada campo em SistCamp:
               +-- Cria componente (TDBEdtLbl, etc.)
               +-- Lista.Text := ExprCamp + EPerCamp
               +-- OnExit/OnClick := iExecExit
               +-- OnChange := Habi (se obrigatorio)
       +-- Executa 'DepoCria' (PL-SAG)

2. EXIBICAO DO FORMULARIO
   +-- FormShow:
       +-- Executa instrucoes de outra tela (ExecShowTela)
       +-- CampPersExecExitShow: Executa OnExit de todos campos
       +-- CampPersExecNoOnShow: Executa ShowTabe
       +-- Atualiza grids de movimentos

3. INTERACAO DO USUARIO
   +-- Usuario modifica campo
   +-- OnChange dispara -> Habi() -> Valida obrigatorios
   +-- Usuario sai do campo
   +-- OnExit dispara -> iExecExit -> CampPersExecExit
       +-- Obtem Lista.Text do componente
       +-- CampPersExecListInst: Executa PL-SAG

4. CONFIRMACAO
   +-- BtnConfClick:
       +-- Valida campos modificados
       +-- Executa LancTabe (antes gravar)
       +-- GravSemC: Grava dados
       +-- Executa EGraTabe (apos gravar)
       +-- Executa AposTabe (final)

5. FECHAMENTO
   +-- FormClose:
       +-- Cancela alteracoes pendentes
       +-- Limpa recursos
```

---

---

## Sistema de Controle de Acesso

O SAG possui um sistema robusto de controle de acesso em multiplos niveis: empresa, modulo, tabela e campo.

### VeriAces* - Verificacao de Permissoes

**Localizacao:** PlusUni.pas

#### Funcoes de Verificacao

| Funcao | Parametro | Retorno | Descricao |
|--------|-----------|---------|-----------|
| **VeriAcesEmpr** | CodiEmpr | Boolean | Verifica acesso a empresa |
| **VeriAcesModu** | CodiProd | Boolean | Verifica acesso ao modulo |
| **VeriAcesTabe** | NomeTabe, Operacao | Boolean | Verifica permissao na tabela |
| **VeriAcesTabeTota** | NomeTabe | String | Retorna todas as permissoes |
| **CarrAcesModu** | Parametros | Integer | Carrega modulos acessiveis |

#### Operacoes de Tabela

| Operacao | Codigo | Descricao |
|----------|--------|-----------|
| **INSERT** | 'I' | Permissao para inserir registros |
| **UPDATE** | 'U' | Permissao para alterar registros |
| **DELETE** | 'D' | Permissao para excluir registros |
| **VIEW** | 'V' | Permissao para visualizar |

#### Fluxo de Verificacao

```
VeriAcesTabe(NomeTabe, Operacao)
    |
    +-- Busca usuario atual (GetPUsu)
    |
    +-- Consulta POViAcTa (permissoes de tabela)
    |       WHERE CodiUsua = @usuario
    |       AND NomeTabe = @tabela
    |
    +-- Se registro existe:
    |       +-- Verifica flag da operacao
    |       +-- Retorna True/False
    |
    +-- Se nao existe:
            +-- Assume permissao default (configuravel)
```

---

### POViAcCa - Permissoes por Campo

**Tabela:** POViAcCa (Permissoes de Campo por Usuario)

Esta tabela permite controle granular de permissoes em nivel de campo.

#### Estrutura da Tabela

```sql
CREATE TABLE POVIACCA (
    CodiAcCa INT PRIMARY KEY,      -- ID da permissao
    CodiUsua INT,                  -- ID do usuario
    CodiTabe INT,                  -- ID da tabela (SISTTABE)
    NomeCamp VARCHAR(50),          -- Nome do campo
    PodeVisu INT DEFAULT 1,        -- Pode visualizar (0/1)
    PodeEdit INT DEFAULT 1,        -- Pode editar (0/1)
    PodeObri INT DEFAULT 0         -- Campo obrigatorio para este usuario (0/1)
);
```

#### Aplicacao das Permissoes

```
MontCampPers() - Durante criacao do campo
    |
    +-- Consulta POViAcCa para usuario atual
    |
    +-- Se PodeVisu = 0:
    |       Campo.Visible = False
    |
    +-- Se PodeEdit = 0:
    |       Campo.Enabled = False
    |       Campo.ReadOnly = True
    |
    +-- Se PodeObri = 1:
            Campo.sgConf.Obrigatorio = True
```

#### Exemplo de Configuracao

```sql
-- Usuario 5 nao pode ver campo VALOTOTA na tabela 100
INSERT INTO POVIACCA (CodiUsua, CodiTabe, NomeCamp, PodeVisu, PodeEdit)
VALUES (5, 100, 'VALOTOTA', 0, 0);

-- Usuario 5 pode ver mas nao editar campo DATACRIA
INSERT INTO POVIACCA (CodiUsua, CodiTabe, NomeCamp, PodeVisu, PodeEdit)
VALUES (5, 100, 'DATACRIA', 1, 0);
```

---

## Comunicacao com Dispositivos Externos

### ConfPortSeri - Configuracao Serial/IP

**Localizacao:** POHeCam6.pas linha 292
**Momento:** FormShow (apos DepoShow)

Esta funcao configura comunicacao com dispositivos externos como balancas, leitores de codigo de barras e impressoras.

#### Formatos de Configuracao

| Formato | Exemplo | Descricao |
|---------|---------|-----------|
| **Serial** | //COM1:9600,N,8,1 | Porta COM com baud rate e paridade |
| **IP/TCP** | //IP:192.168.1.100:4001 | Conexao TCP/IP com host e porta |
| **USB** | //USB:VID_0XXX:PID_0YYY | Dispositivo USB por vendor/product ID |

#### Fonte de Configuracao

| Fonte | Campo | Descricao |
|-------|-------|-----------|
| **SISTTABE** | SeriTabe | Configuracao geral da tela |
| **SISTCAMP** | CompCamp = 'LeitSeri' | Campo especifico para leitura serial |

#### Callbacks de Dados

| Callback | Parametros | Descricao |
|----------|------------|-----------|
| **proResuSeri** (Grav) | iConfig, Valor | Chamado quando dados sao recebidos |
| **proPegaPeso** (LePeso) | iConfig, Peso | Chamado quando peso e recebido de balanca |

#### Fluxo de Configuracao

```
ConfPortSeri()
    |
    +-- Le SeriTabe de POCaTabe
    |
    +-- Para cada configuracao separada por ';':
    |       |
    |       +-- Cria TsgLeitSeri
    |       |
    |       +-- Define callbacks:
    |       |       proResuSeri := Grav
    |       |       proPegaPeso := LePeso
    |       |
    |       +-- Busca campo de destino (EdtSeriRece ou dinamico)
    |       |
    |       +-- Adiciona a fListLeitSeri
    |       |
    |       +-- Abre conexao
    |
    +-- Registra status no log
```

#### Callback Grav (Recepcao de Dados)

```pascal
procedure TFrmPOHeCam6.Grav(iConfig: TsgLeitSeri; Valo: string);
begin
  // Atribui valor recebido ao campo
  if Assigned(iConfig.EdtLbl) then
  begin
    iConfig.EdtLbl.Text := Valo;
    // Executa instrucoes PLSAG do campo
    CampPersExecListInst(Self, iConfig.EdtLbl.Lista);
  end;
end;
```

#### Callback LePeso (Balanca)

```pascal
procedure TFrmPOHeCam6.LePeso(iConfig: TsgLeitSeri; Peso: Double);
begin
  // Valida range do peso
  if NumeroInRange(Peso, 0, 99999) then
  begin
    // Formata e atribui
    iConfig.EdtLbl.Text := FormRealBras(Peso, 3);
    // Executa instrucoes configuradas
    CampPersExecListInst(Self, iConfig.Lista);
  end;
end;
```

---

## Navegacao de Formularios

### MudaTab2 - Navegacao por ESC

**Localizacao:** POHeCam6.pas linha 227
**Trigger:** Tecla ESC pressionada

Esta funcao permite navegar entre abas do formulario usando a tecla ESC.

#### Comportamento

| Situacao | Acao |
|----------|------|
| **Nao e ultima aba** | Avanca para proxima aba visivel |
| **E ultima aba** | Chama UltiConf() - foca no Confirma |

#### Fluxo de Execucao

```
Usuario pressiona ESC
    |
    +-- MudaTab2()
    |       |
    |       +-- MudaTabe2_BuscTbs_Index(AbaAtual)
    |       |       Busca indice da aba atual (recursivo)
    |       |
    |       +-- Se Index < UltimaAba:
    |       |       ProximaAba := Abas[Index + 1]
    |       |       Enquanto ProximaAba.Visible = False:
    |       |           Index++
    |       |       PageControl.ActivePage := ProximaAba
    |       |
    |       +-- Se Index = UltimaAba:
    |               UltiConf()
    |               BtnConf.SetFocus()
```

#### MudaTabe2_BuscTbs_Index

```
MudaTabe2_BuscTbs_Index(Component)
    |
    +-- Se Component e TTabSheet:
    |       Return TabSheet.PageIndex
    |
    +-- Se Component tem Parent:
    |       Return MudaTabe2_BuscTbs_Index(Parent)  // Recursivo
    |
    +-- Senao:
            Return -1
```

#### Exemplo de Uso

```
Formulario com 3 abas: [Dados] [Itens] [Financeiro]
Usuario esta no campo "Nome" na aba [Dados]

1. Pressiona ESC -> Vai para aba [Itens]
2. Pressiona ESC -> Vai para aba [Financeiro]
3. Pressiona ESC -> Foca no botao [Confirmar]
```

#### Configuracao de Teclas (KeyPress)

```pascal
// UltiCamp - Atribuido ao ultimo campo de cada aba
procedure UltiCamp(Sender: TObject; var Key: Char);
begin
  if Key = #9 then  // Tab
    MudaTab2();
end;

// Tratamento global de ESC
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    MudaTab2();
end;
```

---

## Consideracoes para Migracao Web

Para migrar este sistema para uma aplicacao web moderna (Vue/React):

1. **Propriedade Lista.Text** -> Pode ser armazenada como atributo `data-plsag` ou em store
2. **Eventos OnExit** -> Mapear para `@blur` (Vue) ou `onBlur` (React)
3. **Eventos OnClick** -> Mapear para `@click` ou `onClick`
4. **Eventos OnChange** -> Mapear para `@change` ou `onChange`
5. **CampPersExecListInst** -> Implementar interpretador PL-SAG em JavaScript/TypeScript
6. **Ciclo de Vida** -> Mapear FormShow para `onMounted`, FormCreate para constructor

---

*Documento gerado em: 2025-12-24*
*Atualizado em: 2026-01-02*
*Baseado na analise de: PlusUni.pas, POHeCam6.pas*
*Versao: 2.0*

**Changelog v2.0:**
- Adicionada secao InicValoCampPers - Inicializacao de Valores Default
- Adicionada secao InicCampSequ - Geracao de Numeros Sequenciais
- Adicionada secao BtnConf_CampModi - Validacao de Modificacao
- Adicionada secao Sistema de Controle de Acesso (VeriAces*, POViAcCa)
- Adicionada secao ConfPortSeri - Comunicacao Serial/IP
- Adicionada secao MudaTab2 - Navegacao por ESC
