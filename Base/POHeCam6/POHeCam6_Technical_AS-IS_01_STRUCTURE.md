# POHeCam6 - Technical AS-IS Documentation

## Fragmento 01_STRUCTURE (Componentes e DataSources)

**Versao:** 1.0
**Data:** 2025-12-23
**Analista:** Claude Code (Automatizado)

---

## Navegacao entre Fragmentos

| Fragmento | Arquivo | Conteudo |
|-----------|---------|----------|
| [00_MASTER](POHeCam6_Technical_AS-IS_00_MASTER.md) | 00_MASTER | Identificacao + Resumo + Anexos |
| **01_STRUCTURE** | Este documento | Componentes + DataSources |
| [02_LOGIC](POHeCam6_Technical_AS-IS_02_LOGIC.md) | 02_LOGIC | Events + SPs + Dependencias |
| [03_BUSINESS](POHeCam6_Technical_AS-IS_03_BUSINESS.md) | 03_BUSINESS | Regras + Fluxo + Integracoes |
| [04_TECHNICAL](POHeCam6_Technical_AS-IS_04_TECHNICAL.md) | 04_TECHNICAL | Config + Seguranca + Erros |

---

## SECAO 2: COMPONENTES VISUAIS

### 2.1 Componentes Declarados no Form

| Componente | Tipo | Descricao | Uso Principal |
|------------|------|-----------|---------------|
| QryTabeConf | TsgQuery | Query de configuracao da tela | Carrega configuracoes de POCaTabe |
| DtsTabeConf | TDataSource | DataSource para QryTabeConf | Vincula dados de configuracao |
| PnlDado | TsgPnl | Painel de dados/movimentos | Container para grids de movimento |
| Pnl1 | TsgPnl | Painel principal | Container para campos dinamicos |
| EdtSeriRece | TEdtLbl | Campo de recepcao serial | Recebe dados da porta serial |
| EdtSeriEnvi | TEdtLbl | Campo de envio serial | Envia dados para porta serial |
| MaiEnvi | TEnviMail | Componente de envio de email | Envio automatizado de emails |

### 2.2 Componentes Criados Dinamicamente

| Componente | Tipo | Criado Em | Descricao |
|------------|------|-----------|-----------|
| FPgcMovi | TsgPgc | GetPgcMovi | PageControl para movimentos |
| DtbCada | TsgConn | FormCreate | Conexao de banco de dados |
| vTbs | TsgTbs | FormCreate | Tabs para cada movimento |
| vFraCaMv | TFraCaMv | FormCreate | Frame de movimento |
| vsgLeitSeri | TsgLeitSeri | ConfPortSeri | Leitor serial/IP |
| vEdtLbl | TEdtLbl | ConfPortSeri | Campos dinamicos para serial |

### 2.3 Listas de Objetos

| Lista | Tipo | Descricao |
|-------|------|-----------|
| fListMovi | TObjectList<TMovi> | Lista de movimentos relacionados |
| fListLeitSeri | TObjectList<TsgLeitSeri> | Lista de leitores seriais |

### 2.4 Hierarquia Visual

```
TFrmPOHeCam6
  |-- PnlDado (TsgPnl) [Container de Movimentos]
  |     |-- PgcMovi (TsgPgc) [Criado dinamicamente]
  |           |-- TbsMov{N} (TsgTbs) [Para cada movimento]
  |                 |-- FraCaMv{N} (TFraCaMv) [Frame de movimento]
  |
  |-- PgcGene (TsgPgc) [Herdado - Abas Gerais]
  |     |-- Tbs1 (TsgTbs) [Guia principal]
  |     |     |-- Pnl1 (TsgPnl) [Campos personalizados]
  |     |
  |     |-- Tbs02 (TsgTbs) [Guia secundaria, se existir]
  |     |-- TbsMov{N} (TsgTbs) [Movimentos com SeriTabe <= 50]
  |
  |-- EdtSeriRece (TEdtLbl) [Campo serial recepcao]
  |-- EdtSeriEnvi (TEdtLbl) [Campo serial envio]
  |-- MaiEnvi (TEnviMail) [Envio de email]
```

---

## SECAO 3: DATASOURCES E QUERIES

### 3.1 DataSources do Formulario

| DataSource | Query/DataSet Associado | Uso |
|------------|------------------------|-----|
| DtsTabeConf | QryTabeConf | Configuracao da tela (POCaTabe) |
| DtsGrav | Herdado (QryGrav) | Gravacao de dados |

### 3.2 Queries do Formulario

#### 3.2.1 QryTabeConf

**Tipo:** TsgQuery
**Evento BeforeOpen:** QryTabeConfBeforeOpen
**Parametros:**

| Parametro | Tipo | Uso |
|-----------|------|-----|
| CodiTabe | Integer | Codigo da tabela de configuracao |

**SQL Base:** Carrega configuracoes de POCaTabe

#### 3.2.2 Queries Herdadas

| Query | Fonte | Descricao |
|-------|-------|-----------|
| QryGrav | TFrmPOHeGera | Query de gravacao principal |
| QryTela | TFrmPOHeGera | Query da tela |
| QrySQL | TFrmPOHeGera | Query auxiliar SQL |

### 3.3 Queries Utilizadas de DataModules

| Query | DataModule | Uso no Formulario |
|-------|------------|-------------------|
| QryTabe | DtmPoul | Carrega movimentos filhos |
| QryTabeGrid | DtmPoul | Configuracao de grid do movimento |
| QryCalc | DtmPoul | Validacao de modificacao |
| Campos_Cds | DtmPoul | Configuracao de campos |
| Campos_Busc | DtmPoul | Busca de campos especificos |

### 3.4 Mapeamento de Campos - QryTabeConf

| Campo | Tipo | Descricao | Uso |
|-------|------|-----------|-----|
| CodiTabe | Integer | Codigo da tabela | Identificador unico |
| NomeTabe | String | Nome da tabela | Caption do formulario |
| Gui1Tabe | String | Nome da guia 1 | Caption de Tbs1 |
| Gui2Tabe | String | Nome da guia 2 | Caption de Tbs02 |
| AltuTabe | Integer | Altura da tela | Dimensionamento |
| TamaTabe | Integer | Largura da tela | Dimensionamento |
| TpGrTabe | Integer | Tipo grid | Altura do painel |
| ShowTabe | String | Instrucoes OnShow | Execucao automatica |
| LancTabe | String | Instrucoes de lancamento | Execucao no Confirma |
| EGraTabe | String | Instrucoes pos-gravacao | Execucao apos gravar |
| AposTabe | String | Instrucoes apos confirma | Execucao final |
| EPerTabe | String | Instrucoes permanentes | Variaveis/constantes |
| SeriTabe | String | Config porta serial | Formato: "//protocolo:params" |
| InSeTabe | String | Instrucoes serial | Lista de comandos |
| FormTabe | String | Nome do formulario | Identificador |
| GravTabe | String | Tabela de gravacao | Nome da tabela destino |
| FinaTabe | String | Sufixo de campos | ApAt, Marc, etc |
| CaptTabe | String | Caption | Titulo da tela |

### 3.5 Fluxo de Dados

```
POCaTabe (Configuracao)
    |
    v
QryTabeConf --> DtsTabeConf --> Configuracao do Formulario
    |
    |-- Gui1Tabe, Gui2Tabe --> Captions das guias
    |-- AltuTabe, TamaTabe --> Dimensoes da tela
    |-- ShowTabe, LancTabe --> Instrucoes de execucao
    |-- SeriTabe --> Configuracao serial/IP
    |
    v
POCaCamp (Campos)
    |
    v
MontCampPers() --> Criacao dinamica de componentes
    |
    |-- Componentes visuais em Pnl1
    |-- Event handlers configurados
    |-- Bindings com DtsGrav
```

---

**Proximo Fragmento:** [02_LOGIC - Events + SPs + Dependencias](POHeCam6_Technical_AS-IS_02_LOGIC.md)

