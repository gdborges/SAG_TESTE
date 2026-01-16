# POHeCam6 - Technical AS-IS Documentation

## Fragmento 02_LOGIC (Events, SPs e Dependencias)

**Versao:** 1.0
**Data:** 2025-12-23
**Analista:** Claude Code (Automatizado)

---

## Navegacao entre Fragmentos

| Fragmento | Arquivo | Conteudo |
|-----------|---------|----------|
| [00_MASTER](POHeCam6_Technical_AS-IS_00_MASTER.md) | 00_MASTER | Identificacao + Resumo + Anexos |
| [01_STRUCTURE](POHeCam6_Technical_AS-IS_01_STRUCTURE.md) | 01_STRUCTURE | Componentes + DataSources |
| **02_LOGIC** | Este documento | Events + SPs + Dependencias |
| [03_BUSINESS](POHeCam6_Technical_AS-IS_03_BUSINESS.md) | 03_BUSINESS | Regras + Fluxo + Integracoes |
| [04_TECHNICAL](POHeCam6_Technical_AS-IS_04_TECHNICAL.md) | 04_TECHNICAL | Config + Seguranca + Erros |

---

## SECAO 4: EVENT HANDLERS

### 4.1 Event Handlers do Formulario

| Evento | Metodo | Tipo | Descricao |
|--------|--------|------|-----------|
| OnCreate | FormCreate | Override | Inicializa conexao, listas e movimentos |
| OnShow | FormShow | Override | Configura campos e executa instrucoes |
| OnClose | FormClose | Override | Limpa recursos e fecha conexoes |
| OnDestroy | FormDestroy | Override | Libera memoria e objetos |

### 4.2 Detalhamento dos Event Handlers

#### 4.2.1 FormCreate (linha 627)

**Responsabilidades:**
1. Cria conexao de banco de dados (DtbCada) se nao existir
2. Inicializa lista de leitores seriais (fListLeitSeri)
3. Inicializa lista de movimentos (fListMovi)
4. Carrega movimentos da tabela POCaTabe via QryTabe
5. Para cada movimento:
   - Cria TsgTbs (aba)
   - Cria TFraCaMv (frame de movimento)
   - Configura grid e queries do movimento

**Chamadas Externas:**
- `TsgConn.Create` - Cria conexao de banco
- `TFraCaMv.Create` - Cria frame de movimento
- `DtmPoul.QryTabe` - Carrega configuracao de movimentos
- `DtmPoul.QryTabeGrid` - Carrega colunas do grid

```
FormCreate
    |-- Verifica sgTransaction
    |-- Se nao atribuido:
    |     |-- Cria DtbCada (TsgConn)
    |     |-- Configura ConnectionString
    |     |-- Atribui a sgTransaction
    |
    |-- Cria fListLeitSeri (TObjectList<TsgLeitSeri>)
    |-- Cria fListMovi (TObjectList<TMovi>)
    |
    |-- Para cada registro em QryTabe (movimentos):
    |     |-- Cria TMovi
    |     |-- Cria TsgTbs (aba)
    |     |-- Cria TFraCaMv (frame)
    |     |-- Configura QryGrid.SQL via QryTabeGrid
    |     |-- Adiciona a ListMovi
    |
    |-- Chama inherited FormCreate
```

#### 4.2.2 FormShow (linha 883)

**Responsabilidades:**
1. Configura caption do formulario
2. Executa instrucoes AnteShow
3. Prepara dados para manutencao
4. Inicializa valores dos campos personalizados
5. Configura movimentos filhos
6. Executa instrucoes CampPersExecNoOnShow
7. Atualiza grids dos movimentos
8. Configura portas seriais/IP

**Chamadas Externas:**
- `AnteShow` - Preparacao antes de exibir
- `PreparaManu` - Prepara dados para edicao
- `InicValoCampPers` - Inicializa campos personalizados
- `CampPersExecNoOnShow` - Executa instrucoes OnShow
- `ConfPortSeri` - Configura portas seriais

```
FormShow
    |-- AnteShow()
    |-- Configura Caption
    |-- Se GravTabe in [MPCAPARA, MPVIPARA]:
    |     |-- CampPersInicGravPara()
    |-- Senao:
    |     |-- InicCampSequ() se PSitGrav
    |     |-- PreparaManu()
    |     |-- InicValoCampPers()
    |
    |-- Configura Prin_D.DataSet
    |-- Ativa primeira guia visivel
    |
    |-- Para cada movimento:
    |     |-- Configura Pai_Prin_D
    |     |-- Configura sgTransaction
    |     |-- AtuaGridMovi()
    |
    |-- CampPersExecListInst()
    |-- CampPersExecExitShow()
    |-- CampPersExecNoOnShow()
    |-- CampPers_CriaBtn_LancCont()
    |-- DepoShow()
    |-- HabiConf()
    |-- ConfPortSeri()
```

#### 4.2.3 FormClose (linha 740)

**Responsabilidades:**
1. Cancela alteracoes pendentes
2. Deleta registro se inclusao nao confirmada
3. Limpa transacao
4. Fecha leitores seriais

```
FormClose
    |-- inherited
    |-- QryGrav.Cancel
    |-- Se PSitGrav e sgTem_Movi e nao ClicConf:
    |     |-- ExecSQL_ DELETE do registro
    |
    |-- Limpa DtbCada se CodiTabe igual
    |-- SetPsgTrans(nil)
    |
    |-- Fecha ListLeitSeri
```

#### 4.2.4 FormDestroy (linha 780)

**Responsabilidades:**
1. Libera conexao DtbCada
2. Libera ExecShowTela
3. Libera ListMovi
4. Fecha e libera ListLeitSeri

### 4.3 Event Handlers de Botoes

#### 4.3.1 BtnConfClick (linha 436) - Override

**Responsabilidades:**
1. Valida modificacao via BtnConf_CampModi
2. Fecha portas seriais
3. Valida gravacao via ConfGrav
4. Executa instrucoes de lancamento (LancTabe)
5. Gera sequenciais via InicCampSequ
6. Grava dados via GravSemC
7. Reabre portas seriais

**Funcao Interna - BtnConf_CampModi:**
- Verifica se dados foram gerados por outro processo
- Impede modificacao de campos bloqueados
- Consulta POCaCamp para validar campos

### 4.4 Event Handlers de Queries

| Evento | Query | Metodo | Descricao |
|--------|-------|--------|-----------|
| BeforeOpen | QryTabeConf | QryTabeConfBeforeOpen | Ajusta SQL para mobile |

### 4.5 Procedures Auxiliares

| Procedure | Linha | Visibilidade | Descricao |
|-----------|-------|--------------|-----------|
| MudaTab2 | 227 | Private | Navegacao entre abas via ESC |
| DuplClic | 388 | Private | Trata duplo clique em componentes |
| ListChecColumnClick | 394 | Private | Ordenacao de colunas em TLstLbl |
| InicCampSequ | 819 | Private | Gera numeros sequenciais |
| ConfPortSeri | 292 | Private | Configura portas serial/IP |
| CriaTbs | 125 | Private | Cria abas dinamicamente |
| GetPgcMovi | 112 | Private | Lazy-load do PgcMovi |

---

## SECAO 5: STORED PROCEDURES

### 5.1 Stored Procedures Identificadas

**Nenhuma stored procedure e chamada diretamente neste formulario.**

O formulario delega operacoes de banco para:
- Framework CampPers* (campos personalizados)
- DataModule DtmPoul (queries e operacoes)
- Classe pai TFrmPOHeGera (gravacao/alteracao)

### 5.2 Queries SQL Inline

#### Query 1 - Validacao de Modificacao (BtnConfClick:466-471)

**Localizacao:** Metodo BtnConf_CampModi (interno a BtnConfClick)

**Proposito:** Busca campos que podem ter sido modificados para validar se foram gerados por outro processo

**Tabelas Envolvidas:**
- POCaCamp

**Campos Retornados:**
- CompCamp (tipo do componente)
- NameCamp (nome do campo)
- LabeCamp (label do campo)

**Filtros:**
- CodiTabe = {codigo da tela}
- CompCamp NOT IN ('BVL','LBL','BTN','DBG','GRA','T')
- InteCamp = 0

**Ordenacao:**
- GuiaCamp, OrdeCamp

---

## SECAO 6: DEPENDENCIAS

### 6.1 Dependencias Interface (uses)

| Unidade | Tipo | Descricao |
|---------|------|-----------|
| Winapi.Windows | Sistema | API Windows |
| Winapi.Messages | Sistema | Mensagens Windows |
| System.SysUtils | Sistema | Utilitarios |
| System.Variants | Sistema | Tipos variantes |
| System.Classes | Sistema | Classes base |
| Vcl.Graphics | VCL | Graficos |
| Vcl.Controls | VCL | Controles visuais |
| Vcl.Forms | VCL | Formularios |
| Vcl.Dialogs | VCL | Dialogos |
| Data.DB | VCL | Acesso a dados |
| FireDAC.* | FireDAC | Componentes de banco |
| sgTypes | Framework | Tipos customizados |
| sgQuery | Framework | Query customizada |
| sgPop | Framework | Popup menu |
| sgBtn | Framework | Botoes |
| sgTbs | Framework | Tabs |
| sgPgc | Framework | PageControl |
| sgPnl | Framework | Paineis |
| MemLbl | Framework | Memos com label |
| System.Generics.Collections | Sistema | Colecoes genericas |
| PlusUni | SAG | Funcoes auxiliares SAG |
| Func | Framework | Funcoes utilitarias |
| sgClientDataSet | Framework | ClientDataSet customizado |
| POFrGrMv | Framework | Frame de grid movimento |
| POFrGrid | Framework | Frame de grid |
| sgDBG | Framework | Grid customizado |
| sgBvl | Framework | Bevel customizado |
| sgFrame | Framework | Frame base |
| EdtLbl | Framework | Edit com label |
| sgDBG2 | Framework | Grid customizado v2 |
| POFrCaMv | Framework | Frame de cadastro movimento |
| sgLeitSeri | Framework | Leitura serial |
| EnviMail | Framework | Envio de email |
| sgScrollBox | Framework | ScrollBox customizado |
| sgClass | Framework | Classes base |

### 6.2 Dependencias Implementation (uses)

| Unidade | Tipo | Descricao |
|---------|------|-----------|
| Funcoes | Framework | Funcoes globais |
| DmPoul | DataModule | Queries auxiliares POul |
| DmPlus | DataModule | Funcoes Plus |
| RxEdtLbl | Framework | Edit RX com label |
| DBLcbLbl | Framework | LookupCombo DB |
| LcbLbl | Framework | LookupCombo |
| DBEdtLbl | Framework | Edit DB com label |
| Datasnap.DBClient | Sistema | ClientDataSet |
| sgPrinDecorator | Framework | Decorator principal |
| sgConsts | Framework | Constantes |
| Log | Framework | Logging |
| TradConsts | Framework | Constantes de traducao |
| uniGUIApplication | uniGUI | Aplicacao Web (condicional) |
| DmCall | DataModule | Chamadas (condicional) |
| PlusUnig | SAG | Funcoes uniGUI (condicional) |
| LstLbl | Framework | Lista com label (condicional) |
| Plus | SAG | Funcoes Plus (VCL) |

### 6.3 Dependencias Condicionais

```pascal
{$ifdef ERPUNI}
  // Web (uniGUI)
  uniMainMenu, uniButton, uniPageControl, uniGUIClasses,
  uniGUIBaseClasses, uniMemo, uniGUIFrame, uniGroupBox,
  uniPanel, uniEdit
{$ELSE}
  // Desktop (VCL)
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters,
  cxButtons, MaskEdEx, dxUIAClasses
{$ENDIF}

{$IFDEF ERPUNI_MODAL}
  POsgFormModal, POHeFormModal, POHeGeraModal
{$ELSE}
  POsgForm, POHeForm, POHeGera
{$ENDIF}
```

### 6.4 Grafo de Dependencias Criticas

```
TFrmPOHeCam6
    |
    +-- TFrmPOHeGera (heranca)
    |     |-- TFrmPOHeForm
    |     |     |-- TFormGabarito
    |     |           |-- TForm (VCL)
    |
    +-- DmPoul (DataModule)
    |     |-- QryTabe (movimentos)
    |     |-- QryTabeGrid (configuracao grid)
    |     |-- QryCalc (calculos)
    |     |-- Campos_Cds / Campos_Busc
    |
    +-- TFraCaMv (Frame de movimento)
    |     |-- FraMovi (frame interno)
    |     |-- QryGrid, DbgGrid
    |
    +-- TsgLeitSeri (Comunicacao serial)
    |
    +-- CampPers* (Framework campos personalizados)
          |-- MontCampPers
          |-- InicValoCampPers
          |-- CampPersExec*
```

---

**Proximo Fragmento:** [03_BUSINESS - Regras + Fluxo + Integracoes](POHeCam6_Technical_AS-IS_03_BUSINESS.md)

