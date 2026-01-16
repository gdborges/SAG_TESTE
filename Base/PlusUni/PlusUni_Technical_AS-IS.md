# PlusUni - Technical AS-IS Documentation

**Versao:** 1.1
**Data:** 2025-12-23
**Analista:** Claude Code (Automatizado)
**Tipo de Artefato:** Biblioteca (Unit)
**Ultima Atualizacao:** Detalhamento completo da procedure MontCampPers

---

## SECAO 1: IDENTIFICACAO

### 1.1 Informacoes Gerais

| Item | Valor |
|------|-------|
| Nome | PlusUni |
| Tipo | Biblioteca de Funcoes (Unit) |
| Modulo | SAG (Sistema de Apoio a Gestao) |
| Localizacao | `SAG\PlusUni.pas` |
| Linhas de Codigo | 16,195 |
| Tamanho | 685 KB |

### 1.2 Proposito

PlusUni e a **biblioteca central** do modulo SAG, fornecendo:

1. **Framework CampPers** - Sistema de criacao dinamica de campos
2. **Classes de Negocio** - TsgSenh, TMovi
3. **80+ Funcoes Utilitarias** - Suporte operacional ao sistema
4. **Integracao Multi-Base** - Oracle/SQL Server

### 1.3 Dependencias

| Tipo | Quantidade |
|------|------------|
| Interface uses | 31 units |
| Implementation uses | 142 units |
| **Total** | **173 units** |

---

## SECAO 2: TIPOS E CONSTANTES

### 2.1 Constantes

```pascal
const
  cFiltPessSenh = '(POGePess.AtivPess <> 0) AND (POGePess.UsuaPess <> 0) AND (COPY(POGePess.PCodPess,02,02) <> ''99'')';
```

**Uso:** Filtro padrao para consulta de pessoas ativas com permissao de usuario.

### 2.2 Tipos Enumerados

| Tipo | Valores | Descricao |
|------|---------|-----------|
| TModeloXML | mxNormal, mxSimulador | Modo de geracao XML |
| TBuscDia_Util | duAnte, duProx | Direcao de busca de dias uteis |
| TsgSenhModoCons | mcTota, mcProd, mcUnion | Modo de consulta de licencas |

### 2.3 Tipos Array e Classe

| Tipo | Definicao | Descricao |
|------|-----------|-----------|
| TStringArray | array of string | Array dinamico de strings |
| TColorWinControl | class(TUniControl/TWinControl) | Wrapper para controle de cor |

---

## SECAO 3: CLASSE TsgSenh

### 3.1 Definicao

```pascal
TsgSenh = class(TCustomSgSenh)
```

**Proposito:** Gerenciamento de senhas, licencas e controle de acesso ao sistema.

### 3.2 Propriedades

| Propriedade | Tipo | Leitura | Escrita | Descricao |
|-------------|------|---------|---------|-----------|
| WherPers | String | R/W | R/W | Filtro personalizado WHERE |
| SQL_Nume | String | Getter | - | SQL para numero de licenca |
| SQL_Num1 | String | Getter | - | SQL alternativo |
| NumeContReal | Integer | Getter | - | Numero real de contrato |
| Num1ContReal | Integer | Getter | - | Numero alternativo |
| DataAcesGrav | TDateTime | R/W | R/W | Data de acesso gravada |
| NumeSeriGrav | String | R/W | R/W | Numero de serie |
| DataValiGrav | TDateTime | R/W | R/W | Data de validade |
| TipoContGrav | String | R/W | R/W | Tipo de contrato |
| NumeContGrav | Integer | R/W | R/W | Numero do contrato |
| Num1ContGrav | Integer | R/W | R/W | Numero alternativo |
| NumeAcesGrav | Integer | R/W | R/W | Numero de acessos |
| DataVeriNumeGrav | TDateTime | R/W | R/W | Data de verificacao |
| DataVencNumeGrav | TDateTime | R/W | R/W | Data de vencimento |
| ModoConsulta | TsgSenhModoCons | R/W | R/W | Modo de consulta |

### 3.3 Metodos Publicos

| Metodo | Retorno | Descricao |
|--------|---------|-----------|
| Create() | - | Construtor |
| ValiCont(iMens, iGeral) | Boolean | Valida contrato/licenca |
| GeraContra(iMens) | String | Gera contra-senha |
| GravaControles() | - | Persiste controles no banco |
| ValidaModulo() | Boolean | Valida acesso ao modulo |
| ValidaModuloReal() | Boolean | Validacao real (nao cache) |
| DataSenh_FormToDate(iData) | TDateTime | Converte formato de data |
| SenhModu_Todo() | String | Retorna todos os modulos |

### 3.4 Variavel Global

```pascal
var
  FsgSenh : TsgSenh;

function GetsgSenh(): TsgSenh;
```

**Uso:** Instancia singleton para acesso global ao gerenciador de licencas.

---

## SECAO 4: CLASSE TMovi

### 4.1 Definicao

```pascal
TMovi = class
```

**Proposito:** Estrutura para representar movimentos (grids filhos) em formularios.

### 4.2 Propriedades

| Propriedade | Tipo | Descricao |
|-------------|------|-----------|
| CodiTabe | Integer | Codigo da tabela de movimento |
| GeTaTabe | Integer | Codigo generico da tabela |
| SeriTabe | Integer | Numero de serie (indice da aba) |
| TbsMovi | TsgTbs | Componente Tab do movimento |
| FraCaMv | TFraCaMv | Frame de cadastro de movimento |
| FraMovi | TFraGrMv | Frame de grid (somente leitura) |
| PnlResu | TsgPnl | Painel de resumo (somente leitura) |
| PnlMovi | TsgPnl | Painel de movimento (somente leitura) |

### 4.3 Uso Tipico

```pascal
// Formularios derivados de POHeCam6 usam lista de TMovi
ListMovi: TObjectList<TMovi>;

// Cada movimento representa uma aba com grid filho
for Movi in ListMovi do
begin
  Movi.FraCaMv.AtuaGrid;
end;
```

---

## SECAO 5: FRAMEWORK CAMPPPERS

### 5.1 Visao Geral

O framework CampPers (Campos Personalizados) permite:

1. **Criacao dinamica** de componentes em tempo de execucao
2. **Configuracao via banco** (POCaTabe, POCaCamp)
3. **Execucao de instrucoes** em diferentes momentos
4. **Validacao e regras** por campo

### 5.2 Funcao Principal: MontCampPers

**Localizacao:** `SAG\PlusUni.pas:517-2554` (2.037 linhas)

```pascal
procedure MontCampPers(
  CodiTabe: Integer;           // Codigo da tabela (POCaTabe)
  Tag_Obri: Integer;           // Tag para campos obrigatorios
  iForm: TsgForm;              // Formulario destino
  DataSour: TDataSource;       // DataSource para binding
  MudaTab2, MudaTab3, ClicGrav: TKeyPressEvent;  // Eventos de teclado
  Habi, ClicBota, iExecExit: TNotifyEvent;       // Eventos de notificacao
  Pnl1, Pnl2, Pnl3: TsgPnl;    // Paineis destino por guia
  ArruTama: TDataSetNotifyEvent;
  DeleCons, ClicObs: TKeyEvent;
  var PrimGui1, PrimGui2, PrimGui3: TWinControl; // Primeiro controle por guia
  Guia: Integer;               // Numero da guia
  TeclCons: TKeyEvent;
  DuplClic: TNotifyEvent;
  ListChecColumnClick: TLVColumnClickEvent;
  ClicBusc: TNotifyEvent = nil
);
```

**Descricao:** Monta dinamicamente os campos do formulario baseado na configuracao da tabela POCaCamp.

#### 5.2.1 Fluxo de Execucao Detalhado

```
MontCampPers
    |
    +-- [1] Validacao inicial: Se CodiTabe = 0, sai imediatamente
    |
    +-- [2] Inicializacao de fontes (vFontCamp, vFontLabe)
    |       - Web (ERPUNI): TUniFont
    |       - Desktop: TFont
    |
    +-- [3] Carrega nomes das guias personalizadas (GUI4 a GUI9)
    |       Query: DtmPoul.Campos_Cds(CodiTabe, '', '(NameCamp > ''GUI'') AND (NameCamp < ''GUI99'')')
    |
    +-- [4] Carrega campos a criar
    |       Query: DtmPoul.Campos_Cds(CodiTabe, '', '(ExisCamp = 0)')
    |       Ordenacao:
    |       - Tag_Obri = 50: 'GuiaCamp;OrdeCamp' (movimento)
    |       - Outros: 'OrdeCamp' (formulario normal)
    |
    +-- [5] Loop principal: Para cada campo do CDS
    |       |
    |       +-- [5.1] Conta total de campos validos (exclui BVL, BTN, DBG, etc.)
    |       |
    |       +-- [5.2] Determina painel destino (Pane) baseado na Guia:
    |       |         - Guia 99: PnlPers
    |       |         - Guia 21-23: PnlRes1-3
    |       |         - Guia >= 10: Pnl3 (PnlMovi)
    |       |         - Guia 3: Pnl3
    |       |         - Guia 2: Pnl2
    |       |         - Guia 1: Pnl1
    |       |         - Guia 4-9: Cria TsgTbs dinamicamente + TsgPnl
    |       |
    |       +-- [5.3] Configura fontes (vFontCamp, vFontLabe) a partir dos campos:
    |       |         - CFonCamp, CTamCamp, CCorCamp, CEstCamp, CEfeCamp
    |       |         - LFonCamp, LTamCamp, LCorCamp, LEstCamp, LEfeCamp
    |       |
    |       +-- [5.4] Cria Label associado (exceto DBG, GRA, S, BVL, BTN, etc.)
    |       |
    |       +-- [5.5] Cria componente baseado em CompCamp (ver tabela 5.2.2)
    |       |
    |       +-- [5.6] Configuracao geral do componente:
    |       |         - Parent, Width, Left, Top, Hint
    |       |         - TabOrder (sequencial)
    |       |         - Tag = Tag_Obri se ObriCamp <> 0
    |       |         - Enabled baseado em DesaCamp e estado do DataSet
    |       |         - FocusControl do Label
    |       |         - Primeiro campo por guia (PrimGui1/2/3)
    |       |
    |       +-- [5.7] Uppercase automatico se GetPUppeCase()
    |
    +-- [6] Finalizacao
            - POHeForm_AtuaCria(iForm, False)
            - Componentes_Formata(iForm)
            - Libera recursos (cds, vFontCamp, vFontLabe)
```

#### 5.2.2 Tipos de Componentes Suportados (CompCamp)

| Codigo | Componente Criado | Descricao | Linha |
|--------|-------------------|-----------|-------|
| **E** | TDBEdtLbl | Editor texto simples | 796-825 |
| **C** | TDBCmbLbl | ComboBox com valores | 828-875 |
| **A** | TDBFilLbl | Editor de arquivo | 878-915 |
| **N** | TDBRxELbl | Editor numerico | 918-965 |
| **T** / **IT** | TDBLcbLbl / TLcbLbl + TsgQuery + TDataSource + TsgBtn | Lookup tabela | 968-1129 |
| **L** / **IL** | TDBLookNume + TsgQuery | Lookup numerico | 1133-1198 |
| **D** | TDBRxDLbl | Editor data | 1202-1230 |
| **S** | TDBChkLbl | CheckBox (Sim/Nao) | 1233-1268 |
| **M** / **BM** | TDBMemLbl | Memo multi-linha | 1271-1330 |
| **BS/BE/BI/BP/BX/RS/RE/RI/RP/RX** | TDBAdvMemLbl | Memo avancado (SQL, INI, XML, Pascal, PLSAG) | 1333-1408 |
| **ET** | TMemLbl | Editor memo nao-bound | 1411-1467 |
| **RM** / **RB** | TDBRchLbl | RichEdit | 1470-1528 |
| **EE** / **LE** | TEdtLbl | Editor calculado | 1531-1577 |
| **ED** | TRxDatLbl | Data calculada | 1580-1608 |
| **EC** | TCmbLbl | Combo calculada | 1612-1655 |
| **ES** | TChkLbl | CheckBox calculado | 1658-1689 |
| **EA** | TFilLbl | Arquivo calculado | 1692-1724 |
| **EI** | TDirLbl | Diretorio calculado | 1727-1758 |
| **LN** / **EN** | TRxEdtLbl | Numero calculado | 1761-1812 |
| **BVL** | TsgBvl (+TsgLbl opcional) | Bevel separador | 1815-1859 |
| **LBL** | (apenas Label) | Label simples | 1862-1864 |
| **IE** | TDBEdtLbl (ReadOnly) | Info Editor | 1867-1894 |
| **IM** | TDBMemLbl (ReadOnly) | Info Memo | 1897-1950 |
| **IR** | TDBRchLbl (ReadOnly) | Info RichEdit | 1953-2006 |
| **IN** | TDBRxELbl (ReadOnly) | Info Numero | 2009-2047 |
| **DBG** | TsgDBG + TsgQuery + TDataSource | Grid de dados | 2050-2150 |
| **GRA** | TFraGraf | Grafico | 2153-2187 |
| **BTN** | TsgBtn | Botao de acao | 2190-2255 |
| **FE** / **FI** | TDBImgLbl | Imagem do banco | 2258-2328 |
| **FF** | TImgLbl | Imagem fixa | 2331-2360 |
| **LC** | TLstLbl + TsgQuery | Lista com CheckBox | 2363-2436 |
| **TIM** | TsgTim | Timer | 2439-2447 |

#### 5.2.3 Campos da Tabela POCaCamp Utilizados

| Campo | Tipo | Descricao | Uso |
|-------|------|-----------|-----|
| **NameCamp** | String | Nome interno do campo | Nome do componente (prefixo + NameCamp) |
| **NomeCamp** | String | Nome do campo no DataSet | DataField binding |
| **LabeCamp** | String | Label do campo | Caption do Label associado |
| **CompCamp** | String | Tipo do componente | Determina qual componente criar |
| **GuiaCamp** | Integer | Numero da guia (1-99) | Qual aba/painel recebe o campo |
| **OrdeCamp** | Integer | Ordem de tabulacao | TabOrder e sequencia de criacao |
| **EsquCamp** | Integer | Posicao Left | CompAtua.Left |
| **TopoCamp** | Integer | Posicao Top | CompAtua.Top (Label: Top-13) |
| **TamaCamp** | Integer | Largura | CompAtua.Width |
| **AltuCamp** | Integer | Altura (999=alClient) | CompAtua.Height ou Align |
| **ObriCamp** | Integer | Campo obrigatorio (0/1) | Tag = Tag_Obri, sgConf.Obrigatorio |
| **ExisCamp** | Integer | Nao usar (0=ativo) | Filtro de campos ativos |
| **MascCamp** | String | Mascara/Password | EditMask ou PasswordChar='*' |
| **DeciCamp** | Integer | Casas decimais | DecimalPlaces / DecimalPrecision |
| **MiniCamp** | Float | Valor minimo | MinValue |
| **MaxiCamp** | Float | Valor maximo | MaxValue |
| **HintCamp** | String | Dica do campo | Hint do componente |
| **DesaCamp** | Integer | Desabilitar em edicao | Enabled = False se State=dsEdit |
| **InteCamp** | Integer | Inteiro/WordWrap | ScrollBars vertical, WordWrap=True |
| **SQL_Camp** | String | SQL do lookup | Query.SQL_Back.Text |
| **TagQCamp** | Integer | Tag da Query | Query.Tag (10=abre manual) |
| **CodTTabe** | Integer | Codigo tabela cadastro | Botao de cadastro associado |
| **PesqCamp** | Integer | Indice campo pesquisa | ListFieldIndex |
| **DropCamp** | Integer | Largura dropdown | DropDownWidth |
| **GrCoCamp** | String | Configuracao colunas grid | Grid.Coluna.Text |
| **FormCamp** | String | Formato/Tabela gravacao | DisplayFormat, ConfTabe.GravTabe |
| **EstiCamp** | String | Estilo/DataLook | LookNume.DataLook |
| **PadrCamp** | Integer | Valor padrao | Timer.Interval (x1000) |
| **VaGrCamp** | String | Valores gravacao | Combo.Values.Text |
| **VaReCamp** | String | Valores exibicao | Combo.Items.Text |
| **ExprCamp** | String | Expressoes PLSAG | Lista.Text (eventos) |
| **EPerCamp** | String | Expressoes personalizadas | Mesclado com ExprCamp |
| **Exp1Camp** | String | Expressoes adicionais | Grid.Lista.Text, Lst.Lista2.Text |
| **LbCxCamp** | Integer | Exibe botao lookup | LookNume.ExibeBotao |
| **InicCamp** | Integer | Inicializacao especial | ReadOnly, TabStop=False |
| **FiguCamp** | Blob | Imagem do botao | Btn.Glyph, ImgF.Picture |
| **CFonCamp** | String | Fonte do campo | vFontCamp.Name |
| **CTamCamp** | Integer | Tamanho fonte campo | vFontCamp.Size |
| **CCorCamp** | Integer | Cor fonte campo | vFontCamp.Color |
| **CEstCamp** | Integer | Estilo fonte campo | 0=Normal, 1=Bold, 2=Italic, 3=Bold+Italic |
| **CEfeCamp** | Integer | Efeito fonte campo | 1=Sublinhado+Riscado, 2=Sublinhado, 3=Riscado |
| **LFonCamp** | String | Fonte do label | vFontLabe.Name |
| **LTamCamp** | Integer | Tamanho fonte label | vFontLabe.Size |
| **LCorCamp** | Integer | Cor fonte label | vFontLabe.Color |
| **LEstCamp** | Integer | Estilo fonte label | Mesmo que CEstCamp |
| **LEfeCamp** | Integer | Efeito fonte label | Mesmo que CEfeCamp |

#### 5.2.4 Regras de Negocio Implementadas

1. **Navegacao por Tab (Linhas 628-679):**
   - Quando `Tag_Obri <> 50` (nao e movimento): Ultimo campo dispara `ClicGrav`
   - Quando `Tag_Obri = 50` (movimento): Ultimo campo de cada guia dispara `MudaTab2`

2. **Criacao Dinamica de Guias (Linhas 700-728):**
   - Guias 4-9 sao criadas automaticamente se nao existirem
   - Cria TsgTbs no PgcGene com nome `Tbs{XX}` e TsgPnl com nome `Pnl{XX}`
   - Caption vem de campos `GUI4` a `GUI9` da POCaCamp ou padrao `&X. Dados`

3. **Campos Obrigatorios (Linha 2486):**
   - Se `ObriCamp <> 0`, define `CompAtua.Tag := Tag_Obri`
   - Dispara evento `Habi` no `OnChange` do componente

4. **Desabilitacao em Edicao (Linhas 1047-1061, 2490-2491):**
   - Se `DesaCamp <> 0` e `DataSour.DataSet.State = dsEdit`
   - Campo fica `Enabled := False`
   - Query de lookup reduz para mostrar apenas o valor atual

5. **Uppercase Automatico (Linhas 2516-2539):**
   - Se `GetPUppeCase()` retorna True
   - Aplica `CharCase := ecUpperCase` em EditLbl, MemLbl, etc.
   - Exceto campos com `PasswordChar`

6. **AlClient com Margem (Valor 999):**
   - Se `AltuCamp = 999`, componente usa `Align := alClient`
   - Aplica margens de 10px em todos os lados

7. **Compilacao Condicional (ERPUNI):**
   - Web: Usa TUniFont, componentes uniGUI
   - Desktop: Usa TFont, componentes VCL padrao

### 5.3 Funcoes de Execucao CampPers

| Funcao | Descricao |
|--------|-----------|
| CampPers_BuscSQL | Busca SQL associado ao campo |
| CampPers_TratExec | Trata execucao de expressao |
| SubsCampPers | Substitui variaveis em instrucoes |
| CampPersInicGravPara | Inicializa parametros de gravacao |
| InicValoCampPers | Inicializa valores dos campos |
| CampPersExecExit | Executa ao sair do campo |
| CampPersExecExitShow | Executa ao exibir/sair |
| CampPersDuplCliq | Trata duplo-clique em campos |
| CampPersExecListInst | Executa lista de instrucoes |
| CampPersValiExecLinh | Valida linha de execucao |
| CampPersExec | Executa instrucao |
| CampPers_ExecData | Executa expressao de data |
| CampPers_ExecLinhStri | Executa linha como string |
| CampPers_EX | Execucao principal |
| CampPers_OB | Executa com objeto |
| CampPers_OD | Executa com destino |
| CampPers_EP | Executa com parametro |
| CampPers_TR | Executa traducao |
| CampPers_ConfWeb | Configura para Web |
| CampPers_CompCamp_Tipo | Retorna tipo do componente |
| CampPersCompAtua | Retorna componente atual |
| CampPersExecNoOnShow | Executa no OnShow |
| CampPers_BuscModi | Busca modificacao |
| CampPers_CriaBtn_LancCont | Cria botao de lancamento |

### 5.4 Tabelas de Configuracao

| Tabela | Descricao |
|--------|-----------|
| POCaTabe | Configuracao do formulario/tela |
| POCaCamp | Configuracao dos campos |
| POViAcCa | Permissoes de acesso aos campos |

---

## SECAO 6: FUNCOES DE ACESSO E SEGURANCA

### 6.1 Verificacao de Acesso

| Funcao | Retorno | Descricao |
|--------|---------|-----------|
| VeriAcesEmpr(CodiEmpr) | Boolean | Verifica acesso a empresa |
| VeriAcesModu(CodiProd) | Boolean | Verifica acesso ao modulo |
| CarrAcesModu(...) | Integer | Carrega modulos com acesso |
| VeriAcesTabeTota(Tabe) | String | Retorna todos os acessos |
| VeriAcesTabe(Tabe, Opca) | Boolean | Verifica acesso especifico |

### 6.2 Gerenciamento de Senhas

| Funcao | Descricao |
|--------|-----------|
| SenhModu_Todo() | Retorna todos os modulos de senha |
| SenhModu_GeraSenhClie(Opca, Hora) | Gera senha para cliente |
| SenhModu_ContSenh(...) | Controle de senha |
| GetSenh_CalcDigiVeri(Vers) | Calcula digito verificador |
| GetSenh_A_ZparaNume(Valo) | Converte A-Z para numero |
| GetSenh_NumeparaA_Z(Nume) | Converte numero para A-Z |

### 6.3 Validacao de Usuario

| Funcao | Descricao |
|--------|-----------|
| ValiSenhDia() | Valida senha do dia |
| ValiSenhDia_Teste() | Teste de validacao |
| CriaAlteUsua(Usua, Senh) | Cria/altera usuario |
| VeriAlteSenhVenc(Data) | Verifica senha vencida |

---

## SECAO 7: FUNCOES DE BANCO DE DADOS

### 7.1 Edicao Multi-Base

| Funcao | Descricao |
|--------|-----------|
| EditTabeCabeCamp(Data, QryCabe, Tabe, Camp, Inse) | Edita tabela pai por campo |
| EditTabeCabe(Data, QryCabe, Tabe, Inse) | Edita tabela pai |
| EditTabeCabeCodi(Data, QryCabe, Tabe, Codi) | Edita tabela por codigo |

### 7.2 Manipulacao de Registros

| Funcao | Descricao |
|--------|-----------|
| DuplRegiTabe(Tabe, Wher, MarcNovo, Camp, Valo) | Duplica registros |
| OrdeMovi(Camp, Tabe, Wher, Orde, Qry) | Ordena movimentos |
| AbreQuerBookMark(Qry, Contr) | Abre query com bookmark |

### 7.3 Monitor de Queries

| Funcao | Descricao |
|--------|-----------|
| LimpMoniDataModu() | Limpa monitor do DtmPoul |
| LimpMoniGera(iForm) | Limpa monitor geral |
| FechQuerTela(iForm) | Fecha queries da tela |

---

## SECAO 8: FUNCOES DE RELATORIOS

### 8.1 Chamada de Relatorios

| Funcao | Descricao |
|--------|-----------|
| ListCampPOCaRela(iTipo) | Lista campos de relatorio |
| ChamRela(iQryRela, iQrySQL, iTipoExib, iConf, iCodiRela, iForm) | Chama relatorio |
| ChamRelaEspe(iForm, iQryRela, iTipoExib, iConf, iCodiRela) | Relatorio especifico |
| ChamRelaUnig(iForm, iQryRela, iQrySQL, iTipoExib, iConf, iCodiRela, isRelaEspe) | Relatorio uniGUI |

### 8.2 Geracao de Graficos

| Funcao | Descricao |
|--------|-----------|
| GrafCabe(NomeGraf) | Grava cabecalho do grafico |
| GrafSeri(CodiGraf, Orde, Seri, Nome, NomX, ValX, ValY, SQL, Cor) | Grava series |
| TranGraf(NomeOrig, NomeDest, CodiOrig, CodiDest, StanOrig, StanDest) | Copia graficos |

---

## SECAO 9: FUNCOES DE MOVIMENTACAO

### 9.1 Distribuicao de Movimento Caixa

| Funcao | Descricao |
|--------|-----------|
| POCaMvCx_Dist(...) | Distribui movimento de caixa generico |
| POCaMvEs_DistMvCx(iForm, iQuer, iQry, iDctoVaDe) | Dist. mov. estoque |
| POCaMvNo_DistMvCx(iForm, iQuer, iQry, iDctoVaDe) | Dist. mov. nota |
| POCaFina_DistMvCx(iForm, iQuer, iQry) | Dist. financeiro |
| POCaCaix_DistMvCx(iForm, iQuer, iQry) | Dist. caixa |
| POCaUnFi_DistMvCx(iForm, iQuer, iQry) | Dist. unificado |

### 9.2 Notas e Documentos

| Funcao | Descricao |
|--------|-----------|
| POCaMvND_ChamTela(...) | Chama tela de nota/documento |
| POCaMvND_Dist(...) | Distribui nota/documento |

---

## SECAO 10: FUNCOES DE ESTOQUE E PRODUTOS

### 10.1 Controle de Estoque

| Funcao | Descricao |
|--------|-----------|
| QtdeProd(CodiProd, Tipo, Wher, Oper, Data) | Quantidade do produto |
| ValoProd(CodiProd, Tipo, Wher, Oper, Data, ...) | Valor do produto |
| EstoProd(CodiProd, Wher, Oper, Data, ...) | Estoque do produto |
| EstoProd_Pedi(CodiProd, Wher, Oper, Data, ...) | Estoque com pedidos |
| LibeMovi(Movi, Prod, Qtde, Esto, Data, VeriEsto, ...) | Libera movimento |
| BloqProdCarr(Nome, Pedi, Carr, Prod) | Bloqueia produto |

### 10.2 Custos

| Funcao | Descricao |
|--------|-----------|
| Fun_CustProd_Calc(CodiProd, Data, iCodiSeto, iAtualiza, ...) | Calcula custo |

### 10.3 Codigo de Barras

| Funcao | Descricao |
|--------|-----------|
| GeraCodiBarr() | Gera codigo de barras |
| ProxCodiBarr() | Proximo codigo |
| DigiVeriBarr(CodiBarr) | Digito verificador |

---

## SECAO 11: FUNCOES DE DATA E HORA

### 11.1 Manipulacao de Datas

| Funcao | Descricao |
|--------|-----------|
| DiasMes(Mes, Ano) | Dias do mes |
| VeriDia_Vali(Data, Domi, ..., Feri) | Verifica dia valido |
| DifeEntrMes(Mes_Inic, Ano_Inic, Mes_Fina, Ano_Fina) | Diferenca entre meses |
| AchaDia_Util(Dia, Mes, Ano) | Acha dia util |
| BuscDia_Util(iData, iBusc) | Busca dia util |
| ProxDia_Util(iData, iBusc) | Proximo dia util |
| isTime(Linh) | Valida se e hora |
| isDateTime(Linh) | Valida se e data/hora |

---

## SECAO 12: FUNCOES DE LOTE E COLETA

### 12.1 Informacoes de Lote

| Funcao | Descricao |
|--------|-----------|
| PegaAvia(Lote, Camp) | Aviarios do lote |
| PegaAvRe(Lote) | Aviarios de recria |
| PegaInte(Lote) | Integradores do lote |
| MaioIdad(Lote, Data) | Maior idade |
| IdadEnce(CodiLote) | Idade de encerramento |
| IdadLote(ColeLote, Data, PeriIdad) | Idade do lote |
| DataCole(ColeLote, Idad, PeriIdad) | Data da coleta |

### 12.2 Coleta de Dados

| Funcao | Descricao |
|--------|-----------|
| CampCalc(Lote, IdadInic, IdadFina, ...) | Calculos de campos |
| LancCole(TabeCole, CodiCole, CodiLote, CodiMvIS, ...) | Lanca coleta |
| PegaCole(TabeCole, TabeLote, TabeMvSt, Stan, Lote, ...) | Pega valor coleta |
| CalcMax_ColeLote(iLote) | Calcula maximo |
| AtuaCustCole(CodiLote) | Atualiza custos de coleta |
| AtuaColeCust(CodiLote, DataInic, DataFina, iComp) | Atualiza coleta para custos |

---

## SECAO 13: FUNCOES DE RASTREABILIDADE

### 13.1 Calculo de Rastreabilidade

| Funcao | Descricao |
|--------|-----------|
| CalcRastGera(TabeRast, SaidRast, EntrRast, QtdeRast, ...) | Calculo generico |
| CalcRast_BuscOrig(TabeOrig, CampPrin, CampOrig, TabeRast, ...) | Busca origem |

---

## SECAO 14: FUNCOES XML E ARQUIVOS

### 14.1 Geracao XML

| Funcao | Descricao |
|--------|-----------|
| GeraArquXML_SQL(EndeArqu, SQL, iMode) | Gera XML de SQL |
| ImpoArquXML_(EndeArqu, SQL) | Importa XML |

### 14.2 Manipulacao de Arquivos

| Funcao | Descricao |
|--------|-----------|
| ArquValiEnde(iEnde, iCriaDire) | Valida endereco |
| ArquZipa(iEnde, iDest) | Compacta arquivo |
| ArquDes_Zipa(iEnde, iDest, iSubs) | Descompacta arquivo |
| ImpoArqu(Arqu, Tabe, Camp, ...) | Importa arquivo |

---

## SECAO 15: FUNCOES DE TRADUCAO

### 15.1 Traducao de Componentes

| Funcao | Descricao |
|--------|-----------|
| Trad_Componente_Form(iForm, iCodiTabe) | Traduz formulario |
| Trad_Componente(iComp, iCodiTabe, iNomeCompPrin) | Traduz componente |
| Trad_Combo(iCodiTabe, iNameCamp) | Traduz combo |

---

## SECAO 16: FUNCOES UTILITARIAS DIVERSAS

### 16.1 Validacao e Formatacao

| Funcao | Descricao |
|--------|-----------|
| VeriSexo(Nome) | Verifica sexo pelo nome |
| NomeDupl(TextSQL, Codi) | Verifica nome duplicado |
| SobrNome(Nome) | Extrai sobrenome |
| TabeVazi(TextSQL) | Verifica tabela vazia |
| PegaSobr(Nome) | Pega sobrenome |
| ValiCont(Grau) | Valida conta contabil |
| RetoGrauPlan(NumePlan) | Retorna grau do plano |
| ProxNumePlan(NumePlan) | Proximo numero do plano |

### 16.2 Funcoes de Interface

| Funcao | Descricao |
|--------|-----------|
| MensConf(Mens, Nom1, Nom2, Nom3, Nume, Focu) | Mensagem de confirmacao |
| Cancela() | Dialogo de cancelamento |
| ChamModa(Form) | Chama formulario modal |
| Sair() | Mensagem padrao de saida |
| AbreWebBrowser(iURL) | Abre navegador |

### 16.3 Funcionarios e Alocacao

| Funcao | Descricao |
|--------|-----------|
| PessGran(Func) | Granjas do funcionario |
| FuncDaGr(Func, Data) | Funcionario da granja |
| FuncIncu(Func) | Incubatorios do funcionario |
| FuncDaIn(Func, Data) | Funcionario do incubatorio |

---

## SECAO 17: COMPILACAO CONDICIONAL

### 17.1 Diretivas Principais

```pascal
{$DEFINE ERPUNI_FRAME}

{$IFDEF ERPUNI}
  // Modo Web (uniGUI)
{$ELSE}
  // Modo Desktop (VCL)
{$ENDIF}

{$IFDEF ERPUNI_MODAL}
  // Formulario modal
{$ELSE}
  // Formulario normal
{$ENDIF}
```

### 17.2 Impacto nas Uses

**Interface (Web):**
```pascal
uniGUIClasses, sgCompUnig, UniGuiForm
```

**Interface (Desktop):**
```pascal
sgComPort, idTelNet, ACBrBAL, CPort
```

### 17.3 Tipos Condicionais

```pascal
TColorWinControl = class({$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif});
```

---

## SECAO 18: SQL E TABELAS REFERENCIADAS

### 18.1 Stored Procedures

| SP | Contexto |
|----|----------|
| Chav | Usada em contexto de grid (parcial) |
| Linh | Usada em contexto de linha (parcial) |

**Nota:** Os nomes podem estar truncados na extracao.

### 18.2 Tabelas Referenciadas (Top 30)

| Tabela | Modulo |
|--------|--------|
| POCaTabe | SAG - Configuracao de telas |
| POCaCamp | SAG - Configuracao de campos |
| POViAcCa | SAG - Acesso a campos |
| POGePess | SAG - Pessoas/Usuarios |
| POCaPess | SAG - Cadastro de pessoas |
| POCaEmpr | SAG - Empresas |
| POGeProd | SAG - Produtos |
| POCaProd | SAG - Cadastro de produtos |
| POCaMvEs | SAG - Movimento de estoque |
| POCaMvNo | SAG - Movimento de nota |
| POCaFina | SAG - Financeiro |
| POCaCaix | SAG - Caixa |
| POGeMvCx | SAG - Movimento de caixa |
| POCaCent | SAG - Centros de custo |
| MPCaLote | MP - Lotes |
| MPCaCole | MP - Coleta de dados |
| MPCaAvia | MP - Aviarios |
| MPCaGran | MP - Granjas |
| MPCaNucl | MP - Nucleos |
| MPCaBox | MP - Boxes |
| MPCaAloj | MP - Alojamentos |
| MPCaSiSt | MP - Sistema de status |
| MPCaMvIs | MP - Movimento de itens |
| INCaIncu | IN - Incubatorios |
| INCaTrIn | IN - Transferencia incubatorio |
| CLCaProd | CL - Call Center Produtos |
| CLCaMvPr | CL - Movimentos |
| FSXXImNF | FS - Importacao NFe |
| DUAL | Oracle - Tabela dummy |

**Total de tabelas:** 139

---

## SECAO 19: DEPENDENCIAS

### 19.1 Interface Uses (31 units)

```
Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs, DB,
ComCtrls, ADODB, sgTypes, LstLbl, sgClientDataSet, DBImgLbl, LcbLbl,
POGeAgCa, sgForm, sgPnl, sgQuery, Func, sgTbs, POFrCaMv, POFrGrMv,
POFrSeri_D, sgClass, POChRela_D, FireDAC.Stan.Option, FireDAC.Stan.Param

// Condicionais (Web):
uniGUIClasses, sgCompUnig, UniGuiForm

// Condicionais (Desktop):
sgComPort, idTelNet, ACBrBAL, CPort
```

### 19.2 Implementation Uses (142 units)

**Principais categorias:**

- **UI/Controles:** sgBtn, sgBvl, sgLbl, sgPgc, sgProgBar, sgDBG, etc.
- **DB Components:** DBLcbLbl, DBEdtLbl, DBClient, etc.
- **Modulos SAG:** DmPoul, DmPlus, DmImag, etc.
- **Utilitarios:** Funcoes, FuncPlus, BancFunc, etc.
- **Especificos:** INPlus, MPPlus, CLPlus, COPlus, etc.

---

## SECAO 20: METRICAS DE COMPLEXIDADE

### 20.1 Metricas Gerais

| Metrica | Valor |
|---------|-------|
| Linhas de codigo | 16,195 |
| Metodos analisados | 175 |
| Chamadas de metodos | 2,805 |
| Chamadas externas | 440 |
| Chamadas locais | 2,365 |
| Max profundidade | 5 |
| Cadeias de chamadas | 456 |
| Dependencias circulares | 1 |

### 20.2 Unidades Mais Chamadas

| Unit | Chamadas |
|------|----------|
| Quer | 111 |
| cds | 56 |
| iQuer | 41 |
| vProc | 38 |
| Subs | 38 |
| TsgQuery | 25 |
| DataSet | 15 |

---

## SECAO 21: FORMULARIOS DEPENDENTES

### 21.1 Formularios que Usam PlusUni

Esta biblioteca e referenciada por:

- **POHeCam6** - Classe base de formularios com campos personalizados
- **Todos os formularios SAG** - Via heranca de POHeCam6
- **Formularios de Cadastro** - Via framework CampPers
- **Relatorios** - Via funcoes de relatorio

### 21.2 Integracao com POHeCam6

```
POHeCam6
    |
    +-- Chama MontCampPers para criar campos
    |
    +-- Usa TMovi para gerenciar movimentos
    |
    +-- Usa funcoes CampPers* para execucao
    |
    +-- Usa VeriAces* para seguranca
```

---

## SECAO 22: CHECKLIST DE QUALIDADE

### Cobertura da Documentacao

| Item | Status | Observacao |
|------|--------|------------|
| Identificacao completa | OK | Secao 1 |
| Tipos e constantes | OK | Secao 2 |
| Classes documentadas | OK | Secoes 3-4 |
| Framework CampPers | OK | Secao 5 |
| Funcoes de seguranca | OK | Secao 6 |
| Funcoes de banco | OK | Secao 7 |
| Funcoes de relatorio | OK | Secao 8 |
| Funcoes de movimentacao | OK | Secao 9 |
| Funcoes de estoque | OK | Secao 10 |
| Funcoes de data | OK | Secao 11 |
| Funcoes de lote | OK | Secao 12 |
| Funcoes de rastreabilidade | OK | Secao 13 |
| Funcoes XML/Arquivos | OK | Secao 14 |
| Funcoes de traducao | OK | Secao 15 |
| Funcoes utilitarias | OK | Secao 16 |
| Compilacao condicional | OK | Secao 17 |
| SQL e tabelas | OK | Secao 18 |
| Dependencias | OK | Secao 19 |
| Metricas | OK | Secao 20 |
| Formularios dependentes | OK | Secao 21 |

---

**Documento gerado automaticamente por Claude Code**
**Modulo SAG - Sistema de Apoio a Gestao**
**Versao 1.0 - 2025-12-23**
