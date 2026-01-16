# POHeCam6 - Resumo de Componentes

**Data:** 2025-12-23
**Analista:** Claude Code (Automatizado)

---

## 1. Visao Geral

| Metrica | Valor |
|---------|-------|
| Total de Componentes DFM | 7 |
| Componentes Relevantes | 1 (TDataSource) |
| Componentes Dinamicos | 6+ (criados em runtime) |
| Listas de Objetos | 2 |

---

## 2. Componentes Declarados no DFM

### 2.1 Componentes de Dados

| Nome | Tipo | Dataset | Descricao |
|------|------|---------|-----------|
| DtsTabeConf | TDataSource | QryTabeConf | DataSource para configuracao |

### 2.2 Queries

| Nome | Tipo | Parametros | Uso |
|------|------|------------|-----|
| QryTabeConf | TsgQuery | CodiTabe (Integer) | Configuracao da tela |

### 2.3 Paineis

| Nome | Tipo | Align | Descricao |
|------|------|-------|-----------|
| PnlDado | TsgPnl | - | Container de movimentos |
| Pnl1 | TsgPnl | - | Container de campos |

### 2.4 Campos de Edicao

| Nome | Tipo | Uso |
|------|------|-----|
| EdtSeriRece | TEdtLbl | Recepcao de dados serial |
| EdtSeriEnvi | TEdtLbl | Envio de dados serial |

### 2.5 Outros

| Nome | Tipo | Uso |
|------|------|-----|
| MaiEnvi | TEnviMail | Envio de emails |

---

## 3. Componentes Criados Dinamicamente

### 3.1 Na Inicializacao (FormCreate)

| Componente | Tipo | Condicao | Descricao |
|------------|------|----------|-----------|
| DtbCada | TsgConn | Se nao existe sgTransaction | Conexao de banco |
| fListMovi | TObjectList<TMovi> | Sempre | Lista de movimentos |
| fListLeitSeri | TObjectList<TsgLeitSeri> | Sempre | Lista de leitores serial |

### 3.2 Para Cada Movimento

| Componente | Tipo | Nome Padrao | Descricao |
|------------|------|-------------|-----------|
| TsgTbs | Tab | TbsMov{CodiTabe} | Aba do movimento |
| TFraCaMv | Frame | FraCaMv{CodiTabe} | Frame de movimento |

### 3.3 Por Lazy Loading

| Componente | Tipo | Getter | Descricao |
|------------|------|--------|-----------|
| FPgcMovi | TsgPgc | GetPgcMovi | PageControl de movimentos |

### 3.4 Na Configuracao Serial (ConfPortSeri)

| Componente | Tipo | Condicao | Descricao |
|------------|------|----------|-----------|
| TsgLeitSeri | Leitor Serial | Por configuracao | Leitor de porta serial/IP |
| TEdtLbl | Edit | Se campo nao existe | Campo para dados serial |

---

## 4. Listas de Objetos

### 4.1 ListMovi (TObjectList<TMovi>)

**Descricao:** Lista de movimentos (grids filhos) do formulario

**Estrutura TMovi:**
| Propriedade | Tipo | Descricao |
|-------------|------|-----------|
| CodiTabe | Integer | Codigo da tabela de movimento |
| GeTaTabe | Integer | Codigo generico |
| SeriTabe | Integer | Numero de serie (posicao) |
| FraCaMv | TFraCaMv | Frame de movimento |
| FraMovi | - | Atalho para FraCaMv.FraMovi |
| PnlResu | TsgPnl | Painel de resumo |

### 4.2 ListLeitSeri (TObjectList<TsgLeitSeri>)

**Descricao:** Lista de leitores seriais/IP configurados

**Componente TsgLeitSeri:**
| Propriedade | Tipo | Descricao |
|-------------|------|-----------|
| Configur | String | Configuracao (//protocolo:params) |
| EdtLbl | TEdtLbl | Campo destino dos dados |
| proResuSeri | Procedure | Callback de recepcao |
| proPegaPeso | Procedure | Callback de peso |
| NumeVariReal | Integer | Indice da variavel real |

---

## 5. Componentes Herdados Relevantes

### 5.1 De TFrmPOHeGera

| Componente | Tipo | Uso |
|------------|------|-----|
| DtsGrav | TDataSource | DataSource principal de gravacao |
| QryGrav | TsgQuery | Query de gravacao |
| QryTela | TsgQuery | Query da tela |
| QrySQL | TsgQuery | Query auxiliar |
| PgcGene | TsgPgc | PageControl principal |
| Tbs1 | TsgTbs | Primeira aba |
| BtnConf | TsgBtn | Botao Confirma |
| BtnCanc | TsgBtn | Botao Cancela |
| PopCopiGene | TMenuItem | Menu de copia |
| Prin_D | TsgDecorator | Decorator principal |

---

## 6. Binding de Dados

### 6.1 DataSources para Componentes

```
DtsTabeConf --> QryTabeConf
    |
    +-- Configuracao da tela (POCaTabe)

DtsGrav (herdado) --> QryGrav (ou outro)
    |
    +-- Componentes dinamicos (via MontCampPers)
    +-- Campos de edicao personalizados
```

### 6.2 Fluxo de Configuracao

```
POCaTabe
    |
    v
QryTabeConf --> Configuracao geral
    |
    +-- Dimensoes (AltuTabe, TamaTabe)
    +-- Captions (Gui1Tabe, Gui2Tabe)
    +-- Instrucoes (ShowTabe, LancTabe, etc.)
    +-- Serial (SeriTabe)

POCaCamp
    |
    v
MontCampPers --> Componentes dinamicos
    |
    +-- TEdtLbl, TDbEdtLbl
    +-- TLcbLbl, TDbLcbLbl
    +-- TChkLbl, TDbChkLbl
    +-- TsgDBG, TsgDBG2
    +-- etc.
```

---

## 7. Estatisticas de Uso

### 7.1 Por Categoria

| Categoria | Quantidade |
|-----------|------------|
| Queries | 1 (+ 3 herdados) |
| DataSources | 1 (+ 1 herdado) |
| Paineis | 2 |
| Campos | 2 |
| Email | 1 |

### 7.2 Componentes Dinamicos por Execucao

| Componente | Quantidade Tipica |
|------------|-------------------|
| Movimentos (TFraCaMv) | 1-5 por tela |
| Campos personalizados | 10-50 por tela |
| Leitores seriais | 0-3 por tela |

---

## 8. Referencias

- **Codigo Fonte:** SAG\POHeCam6.pas
- **DFM:** SAG\POHeCam6.dfm
- **JSON Extraido:** 02-components/POHeCam6_components.json
- **CSV Extraido:** 02-components/POHeCam6_components.csv

---

**Documento gerado automaticamente**

