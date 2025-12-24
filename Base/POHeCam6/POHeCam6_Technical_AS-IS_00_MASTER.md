# POHeCam6 - Technical AS-IS Documentation

## Documento Master (00_MASTER)

**Versao:** 1.0
**Data:** 2025-12-23
**Analista:** Claude Code (Automatizado)
**Status:** Completo

---

## Navegacao entre Fragmentos

| Fragmento | Arquivo | Conteudo |
|-----------|---------|----------|
| **00_MASTER** | Este documento | Identificacao + Resumo + Anexos |
| [01_STRUCTURE](POHeCam6_Technical_AS-IS_01_STRUCTURE.md) | 01_STRUCTURE | Componentes + DataSources |
| [02_LOGIC](POHeCam6_Technical_AS-IS_02_LOGIC.md) | 02_LOGIC | Events + SPs + Dependencias |
| [03_BUSINESS](POHeCam6_Technical_AS-IS_03_BUSINESS.md) | 03_BUSINESS | Regras + Fluxo + Integracoes |
| [04_TECHNICAL](POHeCam6_Technical_AS-IS_04_TECHNICAL.md) | 04_TECHNICAL | Config + Seguranca + Erros |

---

## SECAO 1: IDENTIFICACAO DO FORMULARIO

### 1.1 Informacoes Basicas

| Atributo | Valor |
|----------|-------|
| **Nome do Form** | TFrmPOHeCam6 |
| **Unit** | POHeCam6.pas |
| **Arquivo DFM** | POHeCam6.dfm |
| **Modulo** | SAG (Sistema de Apoio a Gestao) |
| **Localizacao** | `SAG\POHeCam6.pas` |
| **Tipo** | Formulario Base Generico |
| **Linhas de Codigo** | 1245 |
| **Complexidade** | MEDIA |

### 1.2 Hierarquia de Classes

```
TForm (VCL)
  └── TFormGabarito (Framework sg*)
      └── TFrmPOHeForm (Formulario base PO)
          └── TFrmPOHeGera (Formulario generico)
              └── TFrmPOHeCam6 (Este formulario)
```

**Nota:** O formulario suporta compilacao condicional:
- `{$IFDEF ERPUNI_MODAL}`: Herda de `TFrmPOHeGeraModal`
- Caso contrario: Herda de `TFrmPOHeGera`

### 1.3 Diretivas de Compilacao

```pascal
{$DEFINE ERPUNI_FRAME}  // Define modo frame

// Compilacao condicional para Web/Desktop:
{$ifdef ERPUNI}
  // Componentes uniGUI para Web
{$ELSE}
  // Componentes VCL para Desktop
{$ENDIF}

{$IFDEF ERPUNI_MODAL}
  // Formulario modal para Web
{$ELSE}
  // Formulario normal
{$ENDIF}
```

### 1.4 Proposito Funcional

Este formulario e uma **classe base generica** para criacao de formularios com campos personalizados. Implementa:

1. **Gerenciamento Dinamico de Campos**: Cria componentes visuais em runtime baseado em configuracao de banco de dados (tabelas POCaCamp e POCaTabe)

2. **Suporte a Comunicacao Serial/IP**: Integra com dispositivos externos como balancas, leitores de codigo de barras via porta serial ou IP

3. **Movimentos Relacionados**: Suporta multiplos grids filhos (movimentos) relacionados ao cabecalho do registro

4. **Configuracao Flexivel**: Todo comportamento e definido por configuracao nas tabelas POCaTabe e POCaCamp

5. **Dual Mode (Web/Desktop)**: Suporta compilacao para uniGUI (Web) e VCL (Desktop) atraves de diretivas condicionais

### 1.5 Contexto de Uso

- **Usuarios**: Desenvolvedores (classe base)
- **Frequencia**: Indireta (formularios derivados usados diariamente)
- **Criticidade**: Alta (base para muitos formularios)
- **Processo**: Manutencao de dados com campos personalizados

---

## SECAO 17: RESUMO EXECUTIVO

### 17.1 Visao Geral

POHeCam6 e um formulario base generico do modulo SAG que implementa um framework para criacao dinamica de formularios com campos personalizados. O comportamento e totalmente configuravel atraves de tabelas de banco de dados (POCaTabe para configuracao do formulario e POCaCamp para configuracao dos campos).

### 17.2 Principais Caracteristicas

| Caracteristica | Descricao |
|---------------|-----------|
| **Criacao Dinamica** | Campos criados em runtime via MontCampPers() |
| **Movimentos** | Suporta multiplos grids filhos (TFraCaMv) |
| **Serial/IP** | Integracao com dispositivos externos |
| **Web/Desktop** | Compilacao condicional uniGUI/VCL |
| **Configuracao DB** | POCaTabe + POCaCamp definem comportamento |

### 17.3 Metricas do Formulario

| Metrica | Valor |
|---------|-------|
| Linhas de codigo | 1245 |
| Metodos analisados | 20 |
| Chamadas de metodos | 292 |
| Queries SQL | 1 (inline) |
| Stored Procedures | 0 |
| Tabelas referenciadas | 1 (POCaCamp) |
| Componentes proprios | 7 |
| Dependencias interface | 63 |
| Dependencias implementation | 14 |

### 17.4 Fluxo Principal

```
FormCreate
    ├── Cria conexao DB (DtbCada)
    ├── Inicializa listas (ListMovi, ListLeitSeri)
    ├── Carrega movimentos de POCaTabe (QryTabe)
    ├── Para cada movimento:
    │   ├── Cria TsgTbs (tab)
    │   ├── Cria TFraCaMv (frame de movimento)
    │   └── Configura grid e queries
    └── Chama inherited FormCreate

AfterCreate
    ├── Executa instrucoes "AnteCria" (POCaCamp)
    ├── Abre QryTabeConf (configuracao)
    ├── MontCampPers() - Cria campos dinamicos
    ├── Configura tabs e paineis
    ├── PopAtuaClick() - Abre cadastros
    └── Executa instrucoes "DepoCria"

FormShow
    ├── AnteShow()
    ├── Prepara dados (PreparaManu)
    ├── InicValoCampPers() - Inicializa valores
    ├── Configura movimentos
    ├── CampPersExecNoOnShow() - Instrucoes OnShow
    ├── Atualiza grids dos movimentos
    ├── CampPers_CriaBtn_LancCont()
    ├── DepoShow()
    ├── HabiConf() - Habilita/desabilita Confirma
    └── ConfPortSeri() - Configura portas serial/IP
```

### 17.5 Regras de Negocio Criticas

1. **Campos Personalizados**: Sistema CampPers* controla criacao e comportamento de campos
2. **Validacao de Modificacao**: BtnConf_CampModi() impede alteracao de dados gerados por outros processos
3. **Sequenciamento**: InicCampSequ() gera numeros sequenciais unicos
4. **Comunicacao Serial**: Configuracao via campo SeriTabe (formato "//protocolo:params")

### 17.6 Dependencias Criticas

| Dependencia | Tipo | Uso |
|-------------|------|-----|
| TFrmPOHeGera | Classe pai | Heranca completa |
| DmPoul | DataModule | Queries auxiliares |
| DmPlus | DataModule | Funcoes utilitarias |
| TFraCaMv | Frame | Movimentos/grids filhos |
| TsgLeitSeri | Classe | Comunicacao serial/IP |
| CampPers* | Functions | Framework campos personalizados |

---

## SECAO 18: ANEXOS

### 18.1 Arquivos Relacionados

| Arquivo | Localizacao | Descricao |
|---------|-------------|-----------|
| POHeCam6.pas | SAG\ | Codigo fonte principal |
| POHeCam6.dfm | SAG\ | Definicao visual |
| PlusUni.pas | SAG\ | Funcoes auxiliares |
| POHeGera.pas | (Bases) | Classe pai |
| POFrCaMv.pas | (Bases) | Frame de movimento |

### 18.2 Tabelas de Banco de Dados

| Tabela | Uso |
|--------|-----|
| POCaTabe | Configuracao do formulario |
| POCaCamp | Configuracao dos campos |

### 18.3 Referencias para Outros Fragmentos

- **Componentes visuais**: Ver [01_STRUCTURE](POHeCam6_Technical_AS-IS_01_STRUCTURE.md)
- **Event handlers**: Ver [02_LOGIC](POHeCam6_Technical_AS-IS_02_LOGIC.md)
- **Regras de negocio**: Ver [03_BUSINESS](POHeCam6_Technical_AS-IS_03_BUSINESS.md)
- **Configuracoes tecnicas**: Ver [04_TECHNICAL](POHeCam6_Technical_AS-IS_04_TECHNICAL.md)

### 18.4 Glossario

| Termo | Definicao |
|-------|-----------|
| CampPers | Sistema de campos personalizados |
| Movimento | Grid filho relacionado ao cabecalho |
| SeriTabe | Configuracao de porta serial/IP |
| POCaTabe | Tabela de configuracao de telas |
| POCaCamp | Tabela de configuracao de campos |
| TsgLeitSeri | Classe de leitura serial |
| TFraCaMv | Frame de cadastro de movimento |

### 18.5 Historico de Alteracoes

| Data | Versao | Alteracao | Autor |
|------|--------|-----------|-------|
| 2025-12-23 | 1.0 | Documentacao inicial | Claude Code |

---

**Proximo Fragmento:** [01_STRUCTURE - Componentes e DataSources](POHeCam6_Technical_AS-IS_01_STRUCTURE.md)
