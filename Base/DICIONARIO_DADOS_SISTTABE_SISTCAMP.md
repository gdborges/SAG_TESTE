# Dicionario de Dados - SISTTABE e SISTCAMP

Este documento descreve a estrutura e funcao dos campos das tabelas **SISTTABE** e **SISTCAMP**, utilizadas pelo sistema SAG para configuracao dinamica de formularios.

> **Nota**: Este dicionario foi gerado com base na analise do codigo-fonte, principalmente `PlusUni.pas` (procedure `MontCampPers`) e `POHeCam6.pas`. Campos nao identificados com certeza estao listados na secao [Campos Nao Identificados](#campos-nao-identificados).

---

## Tabela SISTTABE

Armazena a configuracao de tabelas/formularios do sistema. Cada registro representa um formulario dinamico.

### Campos de Identificacao

| Campo | Tipo | Descricao |
|-------|------|-----------|
| **CODITABE** | int (PK) | Codigo unico da tabela/formulario |
| NOMETABE | varchar(250) | Nome descritivo da tabela (exibido no titulo do formulario) |
| FORMTABE | varchar(40) | Nome da classe do formulario Delphi (ex: TFrmPOHeCam6) |
| CAPTTABE | varchar(250) | Caption/titulo do formulario |
| HINTTABE | varchar(250) | Hint/dica exibida ao usuario |
| SIGLTABE | varchar(4) | Sigla da tabela (abreviacao) |

### Campos de Dimensao e Layout

| Campo | Tipo | Descricao |
|-------|------|-----------|
| ALTUTABE | int | Altura do formulario em pixels. Valor 9999 = maximizado |
| TAMATABE | int | Largura do formulario em pixels. Valor 9999 = maximizado |
| TPGRTABE | int | Altura do painel de cabecalho (Pnl1). Se > 0, usa este valor; senao usa ALTUTABE - 55 |
| CABETABE | int | Codigo da tabela pai (cabeçalho). Relaciona tabelas de movimento com seu cabecalho |

### Campos de Gravacao

| Campo | Tipo | Descricao |
|-------|------|-----------|
| GRAVTABE | varchar(40) | Nome da tabela fisica no banco onde os dados serao gravados (ex: POGEPESS, MPCAPARA) |
| CHAVTABE | int | Tipo de chave da tabela |

### Campos de Navegacao/Menu

| Campo | Tipo | Descricao |
|-------|------|-----------|
| MENUTABE | varchar(25) | Identificador do menu onde o formulario aparece |
| ORDETABE | int | Ordem de exibicao no menu |
| SUB_TABE | int | Codigo da tabela pai para submenu |

### Campos de Guias/Abas

| Campo | Tipo | Descricao |
|-------|------|-----------|
| GUI1TABE | varchar(100) | Titulo da primeira guia/aba do formulario |
| GUI2TABE | varchar(250) | Titulo da segunda guia/aba do formulario |

### Campos de Eventos PL-SAG

Scripts PL-SAG sao executados em diferentes momentos do ciclo de vida do formulario:

| Campo | Tipo | Descricao |
|-------|------|-----------|
| SHOWTABE | varchar(max) | Script executado no evento OnShow do formulario |
| LANCTABE | varchar(max) | Script executado ao clicar no botao Confirma (antes da gravacao) |
| EPERTABE | varchar(max) | Expressoes permanentes - variaveis e funcoes globais disponiveis em todos os scripts |
| EGRATABE | varchar(max) | Script executado apos a gravacao do registro |
| APOSTABE | varchar(max) | Script executado apos o clique no Confirma (apos FormShow na inclusao continua) |

### Campos de Consulta/Grid

| Campo | Tipo | Descricao |
|-------|------|-----------|
| GRIDTABE | varchar(max) | SQL da consulta para o grid de movimentos |
| GRCOTABE | varchar(max) | Configuracao de colunas do grid (larguras, formatacao, lookup) |
| CONSTABE | int | Codigo da tela de consulta relacionada |

### Campos de Comunicacao Serial/IP

| Campo | Tipo | Descricao |
|-------|------|-----------|
| SERITABE | varchar(100) | Configuracao de porta serial/IP (formato: //IP:PORTA ou COM:BAUD) |
| INSETABE | varchar(max) | Script para tratamento de dados recebidos via serial |

### Campos de Botoes Configurados

| Campo | Tipo | Descricao |
|-------|------|-----------|
| BOT1TABE | int | Codigo de configuracao do botao 1 |
| BOT2TABE | int | Codigo de configuracao do botao 2 |
| BOT3TABE | int | Codigo de configuracao do botao 3 |

### Campos de SQL Auxiliar

| Campo | Tipo | Descricao |
|-------|------|-----------|
| SQL1TABE | varchar(40) | Nome do primeiro SQL auxiliar |
| NOM1TABE | varchar(40) | Descricao do primeiro SQL auxiliar |
| SQL2TABE | varchar(50) | Nome do segundo SQL auxiliar |
| NOM2TABE | varchar(40) | Descricao do segundo SQL auxiliar |
| SQL3TABE | varchar(50) | Nome do terceiro SQL auxiliar |
| NOM3TABE | varchar(40) | Descricao do terceiro SQL auxiliar |
| SQL4TABE | varchar(50) | Nome do quarto SQL auxiliar |
| NOM4TABE | varchar(40) | Descricao do quarto SQL auxiliar |

### Campos de Relatorios

| Campo | Tipo | Descricao |
|-------|------|-----------|
| REL1TABE | varchar(40) | Nome do primeiro relatorio associado |
| REL2TABE | varchar(40) | Nome do segundo relatorio associado |
| REL3TABE | varchar(40) | Nome do terceiro relatorio associado |

### Campos de Controle e Auditoria

| Campo | Tipo | Descricao |
|-------|------|-----------|
| ULTITABE | int | Ultimo codigo sequencial usado |
| ULNUTABE | int | Ultimo numero sequencial de uso |
| ULDATABE | smalldatetime | Data do ultimo uso |
| VERSTABE | varchar(40) | Versao da configuracao |
| PDATTABE | smalldatetime | Data de publicacao |

### Campos de Imagem

| Campo | Tipo | Descricao |
|-------|------|-----------|
| FIGUTABE | image | Icone/figura do formulario |
| FIATTABE | image | Figura adicional (attachment) |

### Campos de Permissao

| Campo | Tipo | Descricao |
|-------|------|-----------|
| PSISTABE | varchar(3) | Permissao por sistema |
| PUSUTABE | varchar(3) | Permissao por usuario |
| PEMPTABE | varchar(3) | Permissao por empresa |

---

## Tabela SISTCAMP

Armazena a configuracao de campos/componentes de cada formulario. Cada registro representa um componente visual.

### Campos de Identificacao

| Campo | Tipo | Descricao |
|-------|------|-----------|
| **CODICAMP** | int (PK) | Codigo unico do campo |
| CODITABE | int (FK) | Codigo da tabela/formulario (referencia SISTTABE) |
| NOMECAMP | varchar(250) | Nome do campo no banco de dados (DataField) |
| NAMECAMP | varchar(250) | Nome interno do componente (usado para criar: Edt+NAMECAMP, Lcb+NAMECAMP, etc.) |
| LABECAMP | varchar(500) | Label/rotulo exibido para o usuario |
| HINTCAMP | varchar(250) | Hint/dica exibida ao passar o mouse |

### Campos de Posicionamento

| Campo | Tipo | Descricao |
|-------|------|-----------|
| TOPOCAMP | int | Posicao Top (Y) do componente em pixels |
| ESQUCAMP | int | Posicao Left (X) do componente em pixels |
| TAMACAMP | int | Largura do componente em pixels |
| ALTUCAMP | int | Altura do componente em pixels. Valor 999 = alClient (preenche container) |

### Campos de Ordenacao e Navegacao

| Campo | Tipo | Descricao |
|-------|------|-----------|
| GUIACAMP | int | Numero da guia/aba onde o campo aparece (1=primeira, 2=segunda, etc.) |
| ORDECAMP | int | Ordem de tabulacao. Valor 9999 = nao recebe foco (TabStop=False) |
| OBRICAMP | int | Campo obrigatorio (0=Nao, 1=Sim). Marca com Tag especial para validacao |
| DESACAMP | int | Desabilitar na alteracao (0=Nao, 1=Sim) |
| FIXOCAMP | int | Campo fixo/bloqueado |

### Campo de Tipo de Componente (COMPCAMP)

| Valor | Componente Delphi | Descricao |
|-------|-------------------|-----------|
| **E** | TDBEdtLbl | Editor de texto ligado ao banco |
| **N** | TDBRxELbl | Campo numerico ligado ao banco |
| **D** | TDBRxDLbl | Campo de data ligado ao banco |
| **S** | TDBChkLbl | Checkbox ligado ao banco |
| **C** | TDBCmbLbl | Combobox ligado ao banco |
| **M** | TDBMemLbl | Memo (texto longo) ligado ao banco |
| **BM** | TDBMemLbl | Memo blob ligado ao banco |
| **RM** / **RB** | TDBRchLbl | RichEdit ligado ao banco |
| **T** | TDBLcbLbl | LookupComboBox ligado ao banco (tabela relacionada) |
| **IT** | TLcbLbl | LookupComboBox nao ligado (calculado) |
| **L** | TDBLookNume | Campo de busca (lookup) numerico ligado ao banco |
| **IL** | TDBLookNume | Campo de busca (lookup) nao ligado |
| **A** | TDBFilLbl | Campo de arquivo ligado ao banco |
| **EE** | TEdtLbl | Editor de texto nao ligado (calculado) |
| **EN** | TRxEdtLbl | Campo numerico nao ligado (calculado) |
| **ED** | TRxDatLbl | Campo de data nao ligado (calculado) |
| **EC** | TCmbLbl | Combobox nao ligado (calculado) |
| **ES** | TChkLbl | Checkbox nao ligado (calculado) |
| **ET** | TMemLbl | Memo nao ligado (calculado) |
| **EA** | TFilLbl | Campo de arquivo nao ligado |
| **EI** | TDirLbl | Campo de diretorio/pasta |
| **LE** | TEdtLbl | Label de texto (somente leitura, calculado ao mudar) |
| **LN** | TRxEdtLbl | Label numerico (somente leitura, calculado ao mudar) |
| **IE** | TDBEdtLbl | Informacao - Editor (exibe dado de outra query) |
| **IN** | TDBRxELbl | Informacao - Numerico (exibe dado de outra query) |
| **IM** | TDBMemLbl | Informacao - Memo (exibe dado de outra query) |
| **IR** | TDBRchLbl | Informacao - RichEdit (exibe dado de outra query) |
| **BS/BE/BI/BP/BX** | TDBAdvMemLbl | Memo avancado com syntax highlight (SQL/Pascal/INI/XML) |
| **RS/RE/RI/RP/RX** | TDBAdvMemLbl | Memo avancado nao ligado com syntax highlight |
| **BVL** | TsgBvl | Bevel (linha/retangulo decorativo) |
| **LBL** | TsgLbl | Label estatico |
| **BTN** | TsgBtn | Botao de acao |
| **DBG** | TsgDBG | Grid de dados (DevExpress cxGrid) |
| **GRA** | TFraGraf | Grafico |
| **FE** | TDBImgLbl | Imagem editavel do banco |
| **FI** | TDBImgLbl | Imagem informativa (de outra query) |
| **FF** | TImgLbl | Imagem fixa (do campo FiguCamp) |
| **LC** | TLstLbl | Lista com checkboxes |
| **TIM** | TsgTim | Timer (dispara evento periodicamente) |

### Campos de Formatacao Numerica

| Campo | Tipo | Descricao |
|-------|------|-----------|
| DECICAMP | int | Numero de casas decimais |
| MINICAMP | float | Valor minimo permitido |
| MAXICAMP | float | Valor maximo permitido |
| MASCCAMP | varchar(250) | Mascara de entrada/exibicao. Valor '*' = campo senha |
| PADRCAMP | float | Valor padrao. Para TIM, e o intervalo em segundos |

### Campos de Combobox/Lookup

| Campo | Tipo | Descricao |
|-------|------|-----------|
| DROPCAMP | int | Largura do dropdown (se > TAMACAMP, usa este valor) |
| PESQCAMP | int | Indice do campo de pesquisa no ListField |
| VARECAMP | text | Valores exibiveis (VaReCamp - itens da combo) |
| VAGRCAMP | text | Valores gravaveis (VaGrCamp - valores salvos no banco) |
| TABECAMP | varchar(20) | Nome da tabela relacionada |
| CODTTABE | int | Codigo da tabela de destino para cadastro/pesquisa (botao ao lado do lookup) |

### Campos de SQL e Eventos

| Campo | Tipo | Descricao |
|-------|------|-----------|
| SQL_CAMP | text | SQL para popular lookups, grids ou listas |
| EXPRCAMP | text | Script PL-SAG executado no OnExit do campo |
| EPERCAMP | text | Expressoes permanentes do campo |
| EXP1CAMP | text | Script adicional (usado em grids para duplo clique, em listas para Lista2) |
| GRCOCAMP | text | Configuracao de colunas do grid/lista |

### Campos de Fonte do Campo

| Campo | Tipo | Descricao |
|-------|------|-----------|
| CFONCAMP | varchar(20) | Nome da fonte do campo |
| CTAMCAMP | int | Tamanho da fonte do campo |
| CCORCAMP | int | Cor da fonte do campo (TColor) |
| CESTCAMP | int | Estilo da fonte (0=Normal, 1=Negrito, 2=Italico, 3=Negrito+Italico) |
| CEFECAMP | int | Efeito da fonte (0=Nenhum, 1=Sublinhado+Riscado, 2=Sublinhado, 3=Riscado) |

### Campos de Fonte do Label

| Campo | Tipo | Descricao |
|-------|------|-----------|
| LFONCAMP | varchar(20) | Nome da fonte do label |
| LTAMCAMP | int | Tamanho da fonte do label |
| LCORCAMP | int | Cor da fonte do label (TColor) |
| LESTCAMP | int | Estilo da fonte do label |
| LEFECAMP | int | Efeito da fonte do label |

### Campos de Controle

| Campo | Tipo | Descricao |
|-------|------|-----------|
| TAGQCAMP | int | Tag da Query. 0=abre no PopAtuaClick, 5=abre e navega apos confirma, 10=nao abre automaticamente |
| INICCAMP | int | Campo sequencial automatico (1=Sim, junto com TagQCamp=1) |
| INTECAMP | int | Inteiro/interno. Para memos: 1=WordWrap+ScrollVertical. Para grids: 1=editavel |
| EXISCAMP | int | Campo nao existe/invisivel (0=visivel, 1=oculto) |
| LBCXCAMP | int | Label dentro do Bevel (1=Sim) ou exibir botao no LookNume |
| CAPTCAMP | int | Capturar valor |

### Campos de Forma e Estilo (Bevel)

| Campo | Tipo | Descricao |
|-------|------|-----------|
| FORMCAMP | varchar(40) | Forma do Bevel (TBevelShape). Para LookNume: lista de campos |
| ESTICAMP | varchar(40) | Estilo do Bevel (TBevelStyle). Para LookNume: campo chave |

### Campos de Permissao

| Campo | Tipo | Descricao |
|-------|------|-----------|
| PSISCAMP | varchar(3) | Permissao por sistema |
| PUSUCAMP | varchar(3) | Permissao por usuario |
| PEMPCAMP | varchar(3) | Permissao por empresa |
| PDATCAMP | smalldatetime | Data de publicacao |

### Campos de Imagem

| Campo | Tipo | Descricao |
|-------|------|-----------|
| FIGUCAMP | image | Imagem do campo (usada em botoes e imagens fixas) |

---

## Campos Nao Identificados

Os campos abaixo existem nas tabelas mas nao foram identificados com certeza no codigo-fonte:

### SISTTABE

| Campo | Tipo | Hipotese |
|-------|------|----------|
| ATALTABE | varchar(40) | Possivelmente configuracao de atualizacao |
| SISTTABE | varchar(250) | Possivelmente descricao do sistema |
| PAOKTABE | int | Flag de aprovacao/OK |
| MEPETABE | int | Configuracao de permissao de menu |
| CLICTABE | varchar(25) | Tipo de clique (tcClicShow, tcClicManu, etc.) |
| GETATABE | int | Configuracao de obtencao de dados |
| EDITTABE | int | Flag de editavel |
| OK__TABE | int | Flag de status OK |
| CLONTABE | int | Flag de clonagem permitida |
| FIXOTABE | int | Flag de tabela fixa |
| APATTABE | int | Configuracao de aparencia |
| PARATABE | varchar(max) | Parametros adicionais |
| ATCATABE | varchar(250) | Acao/categoria |
| SAG_TABE | int | Flag de tabela SAG interna |
| USUATABE | int | Codigo de usuario |
| CODIPRAT | int | Codigo pratico |
| SGCHTABE | varchar(50) | Campo chave SAG |
| SGBUTABE | varchar(50) | Botao SAG |
| SGTBTABE | int | Tabela SAG |
| RESPTABE | varchar(100) | Responsavel |
| SGCITABE | varchar(100) | Configuracao SAG |
| STAMTABE | int | Status/marca |
| SALTTABE | int | Altura SAG |
| SFIXTABE | int | Fixo SAG |
| AJPETABE | varchar(max) | Ajuda permanente |
| AJUDTABE | varchar(max) | Texto de ajuda |
| OBS_TABE | varchar(max) | Observacoes |

### SISTCAMP

| Campo | Tipo | Hipotese |
|-------|------|----------|
| MTOPCAMP | int | Margem top |
| MESQCAMP | int | Margem esquerda |
| TIPOCAMP | varchar(40) | Tipo de dado do campo |
| LISTCAMP | varchar(20) | Lista associada |
| COLUCAMP | int | Coluna no layout |
| COESCAMP | int | Codigo de estilo |
| LINHCAMP | int | Linha no layout |
| LIESCAMP | int | Linha de estilo |
| PERSCAMP | int | Flag de personalizacao |
| POCOCONS | int | Codigo de consulta |
| NOANCAMP | varchar(250) | Nome anterior |
| ID__CAMP | int | ID interno |
| POEMCAMP | int | Posicao em |
| SAG_CAMP | int | Flag SAG |
| CODIPRAT | float | Codigo pratico |
| RESPCAMP | varchar(250) | Responsavel |
| SGBUCAMP | varchar(50) | Botao SAG |
| SGCHCAMP | varchar(50) | Campo chave SAG |
| SGCICAMP | varchar(100) | Configuracao SAG |
| SGTBCAMP | float | Tabela SAG |
| SALTCAMP | float | Altura SAG |
| SCOECAMP | float | Codigo estilo SAG |
| SCOLCAMP | float | Coluna SAG |
| SESQCAMP | float | Esquerda SAG |
| SFIXCAMP | float | Fixo SAG |
| SGUICAMP | float | Guia SAG |
| SLIECAMP | float | Linha estilo SAG |
| SLINCAMP | float | Linha SAG |
| SMESCAMP | float | Margem esquerda SAG |
| SMTOCAMP | float | Margem topo SAG |
| SORDCAMP | float | Ordem SAG |
| STAMCAMP | float | Status SAG |
| STOPCAMP | float | Topo SAG |
| VERSCAMP | varchar(40) | Versao |
| OBS_CAMP | image | Observacoes (blob) |

---

## Exemplos de Uso

### Criar um Campo de Texto Obrigatorio

```sql
INSERT INTO SistCamp (CodiTabe, NomeCamp, NameCamp, LabeCamp, CompCamp,
                      TopoCAMP, EsquCamp, TamaCamp, GuiaCamp, OrdeCamp, ObriCamp)
VALUES (100, 'NomePess', 'NOMEPESS', 'Nome:', 'E',
        30, 10, 300, 1, 1, 1);
```

### Criar um Lookup de Tabela

```sql
INSERT INTO SistCamp (CodiTabe, NomeCamp, NameCamp, LabeCamp, CompCamp,
                      TopoCAMP, EsquCamp, TamaCamp, GuiaCamp, OrdeCamp,
                      SQL_Camp, CodTTabe)
VALUES (100, 'CodiPess', 'CODIPESS', 'Pessoa:', 'T',
        60, 10, 300, 1, 2,
        'SELECT CodiPess, NomePess FROM POGePess ORDER BY NomePess', 200);
```

### Criar um Grid de Movimento

```sql
INSERT INTO SistCamp (CodiTabe, NomeCamp, NameCamp, CompCamp,
                      TopoCAMP, EsquCamp, TamaCamp, AltuCamp, GuiaCamp,
                      SQL_Camp, GrCoCamp, TagQCamp)
VALUES (100, '', 'GRIDMOV', 'DBG',
        100, 10, 600, 200, 1,
        'SELECT * FROM POGeMovi WHERE CodiCabe = [#CodiCabe#]',
        'CodiMovi=0;Descricao=200;Valor=100/Formata=N2', 0);
```

---

## Convencoes de Nomenclatura

- Prefixo **Edt**: Edit, EditNumerico, EditData
- Prefixo **Lcb**: LookupComboBox
- Prefixo **Cmb**: ComboBox
- Prefixo **Chk**: CheckBox
- Prefixo **Mem**: Memo
- Prefixo **Rch**: RichEdit
- Prefixo **Dbg**: DBGrid
- Prefixo **Gra**: Grafico
- Prefixo **Btn**: Botao
- Prefixo **Bvl**: Bevel
- Prefixo **Lbl**: Label
- Prefixo **Img**: Imagem
- Prefixo **Fil**: Arquivo
- Prefixo **Dir**: Diretorio
- Prefixo **Lst**: Lista
- Prefixo **Tim**: Timer
- Prefixo **Dts**: DataSource
- Prefixo **Qry**: Query

---

*Documento gerado em: 2025-12-23*
*Baseado na analise de: PlusUni.pas, POHeCam6.pas*
