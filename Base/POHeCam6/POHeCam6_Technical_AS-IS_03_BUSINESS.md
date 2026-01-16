# POHeCam6 - Technical AS-IS Documentation

## Fragmento 03_BUSINESS (Regras de Negocio, Fluxo e Integracoes)

**Versao:** 1.0
**Data:** 2025-12-23
**Analista:** Claude Code (Automatizado)

---

## Navegacao entre Fragmentos

| Fragmento | Arquivo | Conteudo |
|-----------|---------|----------|
| [00_MASTER](POHeCam6_Technical_AS-IS_00_MASTER.md) | 00_MASTER | Identificacao + Resumo + Anexos |
| [01_STRUCTURE](POHeCam6_Technical_AS-IS_01_STRUCTURE.md) | 01_STRUCTURE | Componentes + DataSources |
| [02_LOGIC](POHeCam6_Technical_AS-IS_02_LOGIC.md) | 02_LOGIC | Events + SPs + Dependencias |
| **03_BUSINESS** | Este documento | Regras + Fluxo + Integracoes |
| [04_TECHNICAL](POHeCam6_Technical_AS-IS_04_TECHNICAL.md) | 04_TECHNICAL | Config + Seguranca + Erros |

---

## SECAO 7: REGRAS DE NEGOCIO

### 7.1 Regras de Criacao Dinamica

#### RN-001: Criacao de Campos Personalizados
**Descricao:** Campos visuais sao criados em runtime baseados na configuracao da tabela POCaCamp.

**Implementacao:**
- Metodo `MontCampPers()` cria componentes dinamicamente
- Configuracao vem de POCaCamp (CodiTabe, CompCamp, NameCamp, etc.)
- Suporta diversos tipos de componentes (EDT, DBE, LCB, etc.)

**Localizacao:** AfterCreate:1094

#### RN-002: Criacao de Movimentos
**Descricao:** Cada movimento filho e criado como um frame TFraCaMv em uma aba separada.

**Logica:**
- Movimentos sao carregados de QryTabe filtrado por CabeTabe
- SeriTabe > 50: Movimento na mesma guia do cabecalho (PgcMovi)
- SeriTabe <= 50: Movimento em guia separada (PgcGene)

**Localizacao:** FormCreate:664-725

### 7.2 Regras de Validacao

#### RN-003: Validacao de Modificacao
**Descricao:** Impede alteracao de dados gerados por outro processo.

**Logica:**
1. Verifica se ApAt{FinaTabe} foi alterado
2. Verifica se registro foi gerado externamente (Tabe{FinaTabe} + CodiGene)
3. Consulta POCaCamp para campos modificaveis
4. Bloqueia alteracao se campo foi gerado por outro processo

**Localizacao:** BtnConfClick:442-499

**SQL de Validacao:**
```sql
SELECT CompCamp, NameCamp, LabeCamp
FROM POCaCamp
WHERE CodiTabe = {codigo}
  AND CompCamp NOT IN ('BVL','LBL','BTN','DBG','GRA','T')
  AND InteCamp = 0
ORDER BY GuiaCamp, OrdeCamp
```

#### RN-004: Validacao de Gravacao
**Descricao:** Funcao ConfGrav valida se dados podem ser gravados.

**Localizacao:** BtnConfClick:522

### 7.3 Regras de Sequenciamento

#### RN-005: Geracao de Numeros Sequenciais
**Descricao:** Gera numeros sequenciais unicos para campos configurados.

**Tipos:**
- `_UN_`: Chave unica (via POCaNume_ProxSequ)
- `SEQU`: Sequencial simples
- `VERI`: Verifica e gera se necessario

**Condicoes:**
- Campo com ExisCamp = 0
- CompCamp IN ('N', 'EN')
- InicCamp = 1
- TagQCamp = 1

**Localizacao:** InicCampSequ:819-881

### 7.4 Regras de Tratamento Especial

#### RN-006: Tratamento MPCAPARA/MPVIPARA
**Descricao:** Tratamento especial para parametros de captura.

**Logica:**
- GravTabe = 'MPCAPARA': Captura de parametros
- GravTabe = 'MPVIPARA': Visualizacao de parametros
- Executa CampPersInicGravPara ao inves de fluxo normal

**Localizacao:** FormShow:949-951, BtnConfClick:524-529

#### RN-007: Avisos de Deprecacao
**Descricao:** Exibe avisos para telas que serao desativadas.

**Telas Afetadas:**
- CodiTabe 16120: "Autorizacao de Compras" (usar Padrao)
- CodiTabe 16130: "Autorizacao Diretoria" (usar Padrao)

**Localizacao:** BtnConfClick:511-514

### 7.5 Regras de Navegacao

#### RN-008: Navegacao por ESC
**Descricao:** Tecla ESC navega para proxima guia ou aciona UltiConf.

**Logica:**
1. Identifica guia atual via MudaTabe2_BuscTbs_Index
2. Se nao for ultima guia: Avanca para proxima visivel
3. Se for ultima guia: Chama UltiConf

**Localizacao:** MudaTab2:227-283

---

## SECAO 8: FLUXO DE NEGOCIO

### 8.1 Fluxo de Inicializacao

```
Abertura do Formulario
    |
    v
[FormCreate]
    |-- Cria conexao de banco (DtbCada)
    |-- Inicializa listas (ListMovi, ListLeitSeri)
    |-- Carrega movimentos de QryTabe
    |-- Para cada movimento:
    |     |-- Cria aba (TsgTbs)
    |     |-- Cria frame (TFraCaMv)
    |     |-- Configura grid e queries
    |
    v
[AfterCreate]
    |-- Executa instrucoes "AnteCria" (POCaCamp)
    |-- Abre QryTabeConf
    |-- MontCampPers() - Cria campos dinamicos
    |-- Configura captions das guias
    |-- Configura dimensoes da tela
    |-- PopAtuaClick() - Abre cadastros auxiliares
    |-- Executa instrucoes "DepoCria"
    |
    v
[FormShow]
    |-- AnteShow()
    |-- Configura caption
    |-- InicCampSequ() se inclusao
    |-- PreparaManu()
    |-- InicValoCampPers()
    |-- Configura movimentos
    |-- CampPersExecNoOnShow()
    |-- Atualiza grids
    |-- CampPers_CriaBtn_LancCont()
    |-- DepoShow()
    |-- HabiConf()
    |-- ConfPortSeri()
```

### 8.2 Fluxo de Confirmacao

```
Usuario clica em Confirma
    |
    v
[BtnConfClick]
    |-- BtnConf_Ante()
    |-- Exibe avisos de deprecacao (16120, 16130)
    |-- Fecha portas seriais
    |
    v
[Validacao]
    |-- BtnConf_CampModi() - Valida modificacao
    |     |-- Se dados gerados externamente: BLOQUEADO
    |
    |-- ConfGrav() - Valida gravacao
    |     |-- Se invalido: ABORTADO
    |
    v
[Gravacao]
    |-- Se MPCAPARA/MPVIPARA:
    |     |-- CampPersInicGravPara()
    |     |-- RecaDadoGera()
    |     |-- Executa EGraTabe
    |     |-- Close
    |
    |-- Senao (fluxo normal):
    |     |-- Executa LancTabe
    |     |-- InicCampSequ('VERI')
    |     |-- GravSemC() - Grava dados
    |     |-- Executa EGraTabe
    |     |-- FormShow() se nao FechaConfirma
    |     |-- Executa AposTabe
    |
    v
[Finalizacao]
    |-- Reabre portas seriais
    |-- BtnConf_Depo()
```

### 8.3 Fluxo de Fechamento

```
Usuario fecha formulario
    |
    v
[FormClose]
    |-- QryGrav.Cancel
    |-- Se inclusao nao confirmada e tem movimento:
    |     |-- DELETE do registro
    |
    |-- Limpa transacao
    |-- Fecha leitores seriais
    |
    v
[FormDestroy]
    |-- Libera DtbCada
    |-- Libera ExecShowTela
    |-- Libera ListMovi
    |-- Fecha e libera ListLeitSeri
```

---

## SECAO 9: INTEGRACOES

### 9.1 Integracao com POCaTabe/POCaCamp

**Tabela POCaTabe:**
- Configuracao geral da tela (dimensoes, captions, instrucoes)
- Carregada via QryTabeConf

**Tabela POCaCamp:**
- Configuracao de cada campo individual
- Usada por MontCampPers para criar componentes
- Campos: CompCamp, NameCamp, LabeCamp, ExprCamp, etc.

### 9.2 Integracao com Framework CampPers*

| Funcao | Uso |
|--------|-----|
| MontCampPers | Cria campos dinamicos |
| InicValoCampPers | Inicializa valores |
| CampPersExecDireStri | Executa instrucoes diretas |
| CampPersExecNoOnShow | Executa no OnShow |
| CampPersExecListInst | Executa lista de instrucoes |
| CampPersExecExitShow | Executa na saida |
| CampPersAcao | Executa acao |
| CampPersCompAtua | Atualiza componente |
| CampPersInicGravPara | Inicializa gravacao de parametros |
| CampPers_CriaBtn_LancCont | Cria botoes de lancamento contabil |
| CampPers_TratExec | Trata execucao de instrucoes |
| CampPers_TratNome | Trata nome de campo |

### 9.3 Integracao com Dispositivos Serial/IP

**Classe TsgLeitSeri:**
- Comunicacao com balancas, leitores de codigo de barras
- Configuracao via SeriTabe no formato: "//protocolo:params"

**Eventos:**
- `proResuSeri`: Callback quando dados sao recebidos (Grav)
- `proPegaPeso`: Callback quando peso e lido (LePeso)

**Fluxo:**
1. ConfPortSeri le configuracao de SeriTabe ou POCaCamp (LeitSeri)
2. Cria TsgLeitSeri para cada configuracao
3. Abre porta serial/IP
4. Recebe dados e executa instrucoes configuradas

### 9.4 Integracao com Movimentos (TFraCaMv)

**Estrutura TMovi:**
- CodiTabe: Codigo da tabela de movimento
- GeTaTabe: Codigo generico
- SeriTabe: Numero de serie (determina posicao da aba)
- FraCaMv: Frame de movimento
- FraMovi: Atalho para FraCaMv.FraMovi
- PnlResu: Painel de resumo

**Configuracao de Movimento:**
- QryGrid.SQL: Carregado de QryTabeGrid
- DbgGrid.Coluna: Configuracao de colunas
- Pai_Tabe: Referencia ao cabecalho
- Prin_D: Decorator principal

### 9.5 Integracao com Decorator (Prin_D)

**TsgDecorator (Prin_D):**
- Gerencia estado do registro (New/Old)
- Vincula DataSet ao formulario
- Propaga para movimentos filhos

**Metodos Usados:**
- CriaObjs: Cria objetos do decorator
- Dts_To_New/Old: Sincroniza estado
- getPropTableValue: Obtem valor de propriedade

---

**Proximo Fragmento:** [04_TECHNICAL - Config + Seguranca + Erros](POHeCam6_Technical_AS-IS_04_TECHNICAL.md)

