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
    |       Prepara dados e inicializa valores
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

### Fase 4: Confirmacao (BtnConfClick)

```
BtnConfClick [POHeCam6.pas:436]
    |
    +-- BtnConf_CampModi()
    |       Valida se campos foram modificados indevidamente
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
*Baseado na analise de: PlusUni.pas, POHeCam6.pas*
*Versao: 1.0*
