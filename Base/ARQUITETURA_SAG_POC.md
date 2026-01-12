# Arquitetura SAG POC Web

**Versão:** 1.0
**Data:** 2026-01-05
**Autores:** Time SAG
**Audiência:** Time Vision Web (Vue 3)

---

## 1. Visão Geral

O SAG POC Web é uma prova de conceito que replica a funcionalidade do sistema ERP SAG (desenvolvido originalmente em Delphi) em uma aplicação web moderna. O objetivo é permitir que formulários SAG sejam renderizados dinamicamente a partir de metadados armazenados no banco de dados, mantendo compatibilidade com a lógica de negócio existente (PLSAG).

### 1.1 Objetivos do Projeto

- **Renderização Dinâmica**: Forms gerados a partir de metadados (SISTTABE/SISTCAMP)
- **Compatibilidade PLSAG**: Execução de scripts de negócio armazenados no banco
- **Multi-Database**: Suporte a Oracle e SQL Server
- **Embeddable**: Pode ser incorporado em outras aplicações (ex: Vision Web) via iframe
- **Standalone**: Funciona independentemente como aplicação web completa

### 1.2 Diagrama de Alto Nível

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           SAG POC Web                                    │
│                     ASP.NET Core 9 MVC + Razor                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Form      │  │  Movement   │  │   Plsag     │  │   SagApi    │    │
│  │ Controller  │  │ Controller  │  │ Controller  │  │ Controller  │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │                │            │
│  ┌──────┴────────────────┴────────────────┴────────────────┴──────┐    │
│  │                        Services Layer                           │    │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐   │    │
│  │  │ Metadata   │ │ Consulta   │ │ Movement   │ │  Event     │   │    │
│  │  │ Service    │ │ Service    │ │ Service    │ │  Service   │   │    │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────┘   │    │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐   │    │
│  │  │ Lookup     │ │ Sequence   │ │ Validation │ │ Database   │   │    │
│  │  │ Service    │ │ Service    │ │ Service    │ │ Provider   │   │    │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                    │                                     │
│  ┌─────────────────────────────────┴─────────────────────────────────┐  │
│  │                        Database Layer                              │  │
│  │  ┌─────────────────────┐       ┌─────────────────────┐            │  │
│  │  │  SqlServerProvider  │       │   OracleProvider    │            │  │
│  │  └─────────────────────┘       └─────────────────────┘            │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└──────────────────────────────────┬───────────────────────────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    ▼                              ▼
            ┌──────────────┐              ┌──────────────┐
            │  SQL Server  │              │    Oracle    │
            │  192.168.0.  │              │     SAG      │
            │  245\SQL19   │              │              │
            └──────────────┘              └──────────────┘
```

---

## 2. Stack Tecnológica

| Componente | Tecnologia | Versão |
|------------|------------|--------|
| **Backend** | ASP.NET Core MVC | 9.0 |
| **ORM** | Dapper | 2.1+ |
| **Views** | Razor Pages | - |
| **Frontend** | Bootstrap 5 + jQuery | 5.3.2 / 3.7.1 |
| **DB Oracle** | Oracle.ManagedDataAccess.Core | 23.x |
| **DB SQL Server** | Microsoft.Data.SqlClient | 5.x |
| **Icons** | Bootstrap Icons | 1.11.3 |

### 2.1 Decisões Arquiteturais

| Decisão | Escolha | Justificativa |
|---------|---------|---------------|
| ORM | Dapper | Performance, flexibilidade para SQL dinâmico |
| Frontend | Server-side Razor + JS vanilla | Simplicidade, compatibilidade com Delphi |
| Banco | Multi-provider | Clientes usam Oracle ou SQL Server |
| State | Sem sessão server-side | Stateless para escalabilidade |
| Auth | Nenhuma (POC) | Delegado ao Vue em produção |

---

## 3. Estrutura do Projeto

```
SagPoc.Web/
├── Controllers/
│   ├── FormController.cs       # Renderização de forms e CRUD
│   ├── MovementController.cs   # API REST para movimentos (1:N)
│   ├── PlsagController.cs      # Execução de scripts PLSAG
│   ├── SagApiController.cs     # API para integração Vue
│   └── HomeController.cs       # Página inicial
│
├── Services/
│   ├── Database/
│   │   ├── IDbProvider.cs          # Interface de abstração
│   │   ├── SqlServerProvider.cs    # Implementação SQL Server
│   │   └── OracleProvider.cs       # Implementação Oracle
│   │
│   ├── IMetadataService.cs         # Interface
│   ├── MetadataService.cs          # Metadados de tabelas/campos
│   ├── IConsultaService.cs         # Interface
│   ├── ConsultaService.cs          # CRUD e consultas
│   ├── IMovementService.cs         # Interface
│   ├── MovementService.cs          # CRUD de movimentos
│   ├── ILookupService.cs           # Interface
│   ├── LookupService.cs            # Lookups e combos
│   ├── IEventService.cs            # Interface
│   ├── EventService.cs             # Eventos PLSAG
│   ├── ISequenceService.cs         # Interface
│   ├── SequenceService.cs          # Numeração sequencial
│   ├── IValidationService.cs       # Interface
│   └── ValidationService.cs        # Validação de campos protegidos
│
├── Models/
│   ├── FormMetadata.cs             # Estrutura do formulário
│   ├── FieldMetadata.cs            # Configuração de campo
│   ├── MovementMetadata.cs         # Hierarquia de movimentos
│   ├── TableMetadata.cs            # Metadados da tabela
│   ├── ConsultaMetadata.cs         # Configuração de consultas
│   ├── FormEventData.cs            # Eventos de formulário
│   ├── FieldEventData.cs           # Eventos de campo
│   ├── MovementEventData.cs        # Eventos de movimento
│   ├── GridFilterRequest.cs        # Request de consulta
│   ├── GridDataResponse.cs         # Response de consulta
│   ├── SaveRecordRequest.cs        # Request de gravação
│   └── SequenceMetadata.cs         # Configuração de sequência
│
├── Views/
│   └── Form/
│       ├── Index.cshtml            # Lista de formulários
│       ├── Render.cshtml           # Form completo (standalone)
│       ├── RenderEmbedded.cshtml   # Form para iframe (Vue)
│       ├── _FormContent.cshtml     # Campos do formulário
│       ├── _FieldRendererV2.cshtml # Renderização de campo
│       ├── _ConsultaTab.cshtml     # Aba de consulta/grid
│       ├── _MovementSection.cshtml # Container de movimento
│       ├── _MovementGrid.cshtml    # Grid de movimento
│       └── _MovementModal.cshtml   # Modal de edição
│
└── wwwroot/
    ├── css/
    │   ├── site.css                # Estilos gerais
    │   ├── form-renderer.css       # Estilos de formulário
    │   ├── vision-theme.css        # Tema Vision
    │   └── consulta-grid.css       # Estilos do grid
    │
    └── js/
        ├── plsag-interpreter.js    # Parser e executor PLSAG
        ├── plsag-commands.js       # Implementação dos comandos
        ├── sag-events.js           # Sistema de eventos
        ├── consulta-grid.js        # Gerenciador do grid
        └── movement-manager.js     # Gerenciador de movimentos
```

---

## 4. Sistema de Formulários Dinâmicos

### 4.1 Fluxo de Renderização

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Request   │────▶│ FormController  │────▶│ MetadataService │
│ /Form/120   │     │   Render(120)   │     │ GetFormMetadata │
└─────────────┘     └────────┬────────┘     └────────┬────────┘
                             │                       │
                    ┌────────┴────────┐     ┌────────┴────────┐
                    │                 │     │   SISTTABE      │
                    │   Razor View    │◀────│   SISTCAMP      │
                    │  Render.cshtml  │     │   SISTCONS      │
                    │                 │     │   SISTEVEN      │
                    └────────┬────────┘     └─────────────────┘
                             │
                    ┌────────┴────────┐
                    │     HTML +      │
                    │   JavaScript    │
                    └─────────────────┘
```

### 4.2 Tabelas de Metadados

| Tabela | Descrição |
|--------|-----------|
| **SISTTABE** | Definição de tabelas (nome, sigla, gravação, PK) |
| **SISTCAMP** | Campos de cada tabela (tipo, tamanho, posição, SQL) |
| **SISTCONS** | Consultas/grids disponíveis |
| **SISTEVEN** | Eventos PLSAG por tabela |

### 4.3 Tipos de Campo Suportados

| CompCamp | Tipo | Descrição | Componente HTML |
|----------|------|-----------|-----------------|
| S | String | Texto simples | `<input type="text">` |
| E | Extended String | Texto grande | `<textarea>` |
| N | Numeric | Número | `<input type="number">` |
| EN | Extended Numeric | Número grande | `<input type="number">` |
| D | Date | Data | `<input type="date">` |
| T | Table Lookup | Combo com SQL | `<select>` |
| IT | Indexed Table | Combo com SQL | `<select>` |
| L | List | Lista fixa | `<select>` |
| IL | Indexed List | Lista indexada | `<select>` |
| C | Checkbox | Booleano | `<input type="checkbox">` |
| IE | Image Edit | Campo associado a lookup | `<input readonly>` |
| B | Bevel | Separador visual | `<div class="bevel">` |
| BTN | Button | Botão com ação PLSAG | `<button>` |

### 4.4 Posicionamento de Campos

O sistema utiliza `GuiaCamp` (guia/aba) e `OrdeCamp` (ordem) para posicionar os campos:

```
GuiaCamp = 1 → Aba "Dados" (principal)
GuiaCamp = 2 → Aba secundária
GuiaCamp = 50+ → Movimento inline
GuiaCamp = 0 → Campo oculto
```

---

## 5. Sistema de Movimentos (1:N)

Movimentos são tabelas filhas vinculadas a uma tabela pai (ex: Itens de Pedido → Pedido).

### 5.1 Identificação de Movimentos

```
SISTTABE.CABETABE > 0  → Tabela é um movimento
SISTTABE.CABETABE      → CodiTabe da tabela pai
SISTTABE.SERITABE      → Modo de exibição:
                          - > 50: Inline (direto no form)
                          - ≤ 50: Tab separada
SISTTABE.GETATABE = 1  → Tabela pai aceita movimentos
```

### 5.2 API de Movimentos

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/movement/{parentId}/tables` | Lista movimentos do pai |
| GET | `/api/movement/{parentId}/{tableId}/data` | Dados do grid |
| GET | `/api/movement/{tableId}/form/{recordId}` | Dados para edição |
| POST | `/api/movement/{tableId}` | Inserir movimento |
| PUT | `/api/movement/{tableId}/{recordId}` | Atualizar movimento |
| DELETE | `/api/movement/{tableId}/{recordId}` | Excluir movimento |

### 5.3 Fluxo de Movimento

```
┌─────────────────────────────────────────────────────────────┐
│                    Formulário Pai                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Tab: Dados                                              │ │
│  │ [Campo1] [Campo2] [Campo3]                             │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Tab: Itens (Movimento 815)                             │ │
│  │ ┌────────────────────────────────────────────────────┐ │ │
│  │ │ Grid de Movimentos                                 │ │ │
│  │ │ [Produto] [Qtde] [Valor]                          │ │ │
│  │ │ --------------------------------                   │ │ │
│  │ │ Item 1    10     100.00                           │ │ │
│  │ │ Item 2    5      50.00                            │ │ │
│  │ └────────────────────────────────────────────────────┘ │ │
│  │ [+ Novo] [Editar] [Excluir]                            │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ Click "Novo"
┌─────────────────────────────────────────────────────────────┐
│                    Modal de Movimento                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Produto: [________] [🔍]                               │ │
│  │ Quantidade: [____]                                      │ │
│  │ Valor Unitário: [______]                               │ │
│  │ Valor Total: [______] (calculado)                      │ │
│  └────────────────────────────────────────────────────────┘ │
│                    [Salvar] [Cancelar]                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. PLSAG - Linguagem de Scripts

O PLSAG é uma linguagem de script proprietária armazenada no banco que executa lógica de negócio.

### 6.1 Arquitetura do Interpretador

```
┌─────────────────────────────────────────────────────────────┐
│                   plsag-interpreter.js                       │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  Parser                                                  ││
│  │  - Tokenização de instruções                            ││
│  │  - Expansão de templates {D-Campo}, {DM-Campo}          ││
│  │  - Resolução de variáveis                               ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │  Executor                                                ││
│  │  - Dispatch para plsag-commands.js                      ││
│  │  - Controle de fluxo (IF, WH)                           ││
│  │  - Comunicação com servidor (/api/plsag/execute)        ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    plsag-commands.js                         │
│  - ED (Enable/Disable)                                       │
│  - MSG (Mensagens)                                          │
│  - ESI (Execute SQL Insert)                                 │
│  - DBI (Database Insert)                                    │
│  - UPD (Update)                                             │
│  - DEL (Delete)                                             │
│  - VAL (Validation)                                         │
│  - CAL (Calculate)                                          │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 Comandos PLSAG Principais

| Comando | Sintaxe | Descrição |
|---------|---------|-----------|
| **ED** | `ED,<comp>,ENABLED,<0\|1>` | Habilita/desabilita componente |
| **ED** | `ED,<comp>,VISIBLE,<0\|1>` | Mostra/esconde componente |
| **MSG** | `MSG,<tipo>,<mensagem>` | Exibe mensagem (I=Info, W=Warning, E=Error) |
| **ESI** | `ESI,<tabela>,<pk>,<sql>` | Executa SQL e preenche form |
| **IF** | `IF,<cond>,<then>,<else>` | Condicional |
| **WH** | `WH-<id>-SELECT <sql>` | Início de loop |
| **WH** | `WH-<id>` | Fim de loop |

### 6.3 Templates de Variáveis

| Template | Descrição | Exemplo |
|----------|-----------|---------|
| `{D-Campo}` | Valor do campo no header | `{D-CODICONT}` → `123` |
| `{DM-Campo}` | Valor do campo no movimento | `{DM-QTDEMVCT}` → `10` |
| `{D2-Campo}` | Valor do sub-movimento | `{D2-VALOMVIT}` |
| `{P-Campo}` | Parâmetro do sistema | `{P-USUARIO}` |
| `{QY-<id>-Campo}` | Resultado de query WH | `{QY-NOVO01-NOME}` |

### 6.4 Eventos PLSAG

| Evento | Quando Executa | Uso Típico |
|--------|----------------|------------|
| `OnShow` | Ao abrir formulário | Inicialização, defaults |
| `OnNewRecord` | Ao criar registro | Valores iniciais |
| `OnExit` | Ao sair do campo | Validação, cálculo |
| `OnEnter` | Ao entrar no campo | Preparação |
| `BeforeSave` | Antes de gravar | Validação final |
| `AfterSave` | Após gravar | Atualização de relacionados |
| `BeforeDelete` | Antes de excluir | Verificação de dependências |

---

## 7. APIs REST

### 7.1 Form Controller (`/Form/*`)

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/Form/Index` | GET | Lista todos os forms disponíveis |
| `/Form/Render/{id}` | GET | Renderiza form completo |
| `/Form/RenderEmbedded/{id}` | GET | Renderiza para iframe |
| `/Form/Fields/{id}` | GET | Retorna campos em JSON |
| `/Form/GetConsultas?tableId={id}` | GET | Consultas disponíveis |
| `/Form/ExecuteConsulta` | POST | Executa consulta com filtros |
| `/Form/GetRecord?tableId={id}&recordId={id}` | GET | Obtém registro |
| `/Form/SaveRecord` | POST | Salva registro |
| `/Form/DeleteRecord?tableId={id}&recordId={id}` | DELETE | Exclui registro |
| `/Form/CreateRecord?tableId={id}` | POST | Cria registro vazio (Saga) |
| `/Form/CancelRecord/{tableId}/{recordId}` | DELETE | Cancela inclusão |
| `/Form/GetFieldDefaults?tableId={id}` | GET | Valores default |
| `/Form/ExecuteLookup` | POST | Executa lookup SQL |
| `/Form/LookupByCode` | POST | Busca por código |
| `/Form/GetProtectedFields?tableId={id}` | GET | Campos protegidos |
| `/Form/ValidateModifications` | POST | Valida alterações |
| `/Form/MovementFormHtml/{tableId}` | GET | HTML do form de movimento |

### 7.2 Movement Controller (`/api/movement/*`)

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/api/movement/{parentId}/tables` | GET | Lista movimentos do pai |
| `/api/movement/{parentId}/{tableId}/data` | GET | Dados do grid |
| `/api/movement/{parentId}/{tableId}/events` | GET | Eventos do movimento |
| `/api/movement/{tableId}/form/{recordId}` | GET | Dados para edição |
| `/api/movement/{tableId}` | POST | Inserir |
| `/api/movement/{tableId}/{recordId}` | PUT | Atualizar |
| `/api/movement/{tableId}/{recordId}` | DELETE | Excluir |

### 7.3 PLSAG Controller (`/api/plsag/*`)

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/api/plsag/execute` | POST | Executa instruções PLSAG |
| `/api/plsag/eval` | POST | Avalia expressão |

### 7.4 SAG API Controller (`/api/sag/*`)

**Esta é a API principal para integração com o Vision Web.**

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/api/sag/available-forms` | GET | Lista forms para menu |
| `/api/sag/form/{tableId}` | GET | Info detalhada do form |
| `/api/sag/modules` | GET | Módulos disponíveis |
| `/api/sag/health` | GET | Health check |

#### GET `/api/sag/available-forms`

Retorna lista de formulários para popular o menu do Vue.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "tableId": 120,
      "name": "Contratos",
      "description": "POCACONT",
      "tag": "SAG001",
      "sigla": "CONT",
      "moduleId": "SAG",
      "tableType": "standalone"
    },
    {
      "tableId": 715,
      "name": "Pedidos de Venda",
      "description": "POCAPEDV",
      "tag": "SAG002",
      "sigla": "PEDV",
      "moduleId": "SAG",
      "tableType": "parent"
    }
  ],
  "total": 1207
}
```

#### GET `/api/sag/form/{tableId}`

**Response:**
```json
{
  "success": true,
  "data": {
    "tableId": 120,
    "name": "Contratos",
    "sigla": "CONT",
    "menuName": "MNUPOCACONT",
    "moduleId": "SAG",
    "hasChildren": false,
    "parentTableId": null,
    "gravTabe": "POCACONT",
    "fieldCount": 22,
    "movementCount": 1,
    "embedUrl": "/Form/RenderEmbedded/120",
    "fullUrl": "/Form/Render/120"
  }
}
```

#### GET `/api/sag/health`

**Response:**
```json
{
  "status": "healthy",
  "provider": "Oracle",
  "timestamp": "2026-01-05T14:30:00Z"
}
```

---

## 8. Integração com Vision Web (Vue 3)

### 8.1 Arquitetura de Embedding

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Vision Web (Vue 3)                                                      │
│  http://localhost:5173                                                   │
│                                                                          │
│  ┌──────────────┐  ┌─────────────────────────────────────────────────┐  │
│  │   Sidebar    │  │                                                 │  │
│  │              │  │   ┌─────────────────────────────────────────┐   │  │
│  │ Personalizados   │   │                                         │   │  │
│  │  └─ SAG      │  │   │  <iframe                                │   │  │
│  │     └─ SAG001│  │   │    src="http://localhost:5255           │   │  │
│  │     └─ SAG002│──┼───│        /Form/RenderEmbedded/120">       │   │  │
│  │     └─ SAG003│  │   │                                         │   │  │
│  │              │  │   │                                         │   │  │
│  │              │  │   └─────────────────────────────────────────┘   │  │
│  └──────────────┘  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

### 8.2 CORS Configurado

O SAG já está configurado para aceitar requests do Vue:

```csharp
// Program.cs
builder.Services.AddCors(options =>
{
    options.AddPolicy("VisionWeb", policy =>
    {
        policy.WithOrigins(
                "http://localhost:5173",    // Vite dev server
                "http://localhost:8080",    // Alternate dev port
                "http://127.0.0.1:5173"
            )
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
});
```

### 8.3 Comunicação via PostMessage

O SAG embedded envia eventos para o Vue parent:

```javascript
// No SAG (RenderEmbedded.cshtml)
window.SAG_EMBEDDED = true;

function notifyParent(type, data) {
    if (window.parent !== window) {
        window.parent.postMessage({ type, data }, '*');
    }
}

// Eventos disponíveis:
notifyParent('SAG_FORM_LOADED', { tableId: 120 });
notifyParent('SAG_RECORD_SAVED', { tableId: 120, recordId: 456 });
notifyParent('SAG_RECORD_CREATED', { tableId: 120, recordId: 457 });
notifyParent('SAG_RECORD_CANCELLED', { tableId: 120 });
notifyParent('SAG_ERROR', { message: 'Erro ao salvar' });
```

```javascript
// No Vue (sag-form-viewer.vue)
function handleSagMessage(event) {
    if (event.origin !== 'http://localhost:5255') return;

    const { type, data } = event.data || {};

    switch (type) {
        case 'SAG_FORM_LOADED':
            loading.value = false;
            break;
        case 'SAG_RECORD_SAVED':
            notificationStore.success('Registro salvo!');
            break;
        case 'SAG_ERROR':
            notificationStore.error(data?.message);
            break;
    }
}

onMounted(() => {
    window.addEventListener('message', handleSagMessage);
});
```

### 8.4 URLs para Embedding

| Tipo | URL | Uso |
|------|-----|-----|
| **Embedded** | `/Form/RenderEmbedded/{tableId}` | Dentro de iframe (sem layout) |
| **Standalone** | `/Form/Render/{tableId}` | Acesso direto (com layout) |

---

## 9. Banco de Dados

### 9.1 Configuração

```json
// appsettings.json
{
  "DatabaseProvider": "Oracle",  // ou "SqlServer"
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=SAG;User Id=Comercial;Password=ComeW88_01_;"
  }
}
```

### 9.2 Providers Disponíveis

| Provider | Connection String |
|----------|-------------------|
| **Oracle** | `Data Source=SAG;User Id=Comercial;Password=ComeW88_01_;` |
| **SQL Server** | `Server=192.168.0.245\SQL19;Database=SAG;User Id=SAG;Password=sag;TrustServerCertificate=True;` |

### 9.3 Abstração de Banco

```csharp
public interface IDbProvider
{
    string ProviderName { get; }
    IDbConnection CreateConnection();
    string GetParameterPrefix();      // ":" para Oracle, "@" para SQL Server
    string GetLimitClause(int limit); // "FETCH FIRST N ROWS ONLY" ou "TOP N"
    string CastTextToString(string column); // DBMS_LOB.SUBSTR ou CAST
}
```

### 9.4 Tabelas Principais

| Tabela | Descrição | Campos Principais |
|--------|-----------|-------------------|
| **SISTTABE** | Definição de tabelas | CODITABE, NOMETABE, SIGLTABE, GRAVTABE, CABETABE, GETATABE |
| **SISTCAMP** | Campos das tabelas | CODICAMP, CODITABE, NOMECAMP, LABECAMP, COMPCAMP, GUIACAMP, ORDECAMP |
| **SISTCONS** | Consultas | CODICONS, CODITABE, NOMECONS, BUSCCONS, GRIDCONS |
| **SISTEVEN** | Eventos | CODITABE, ONSHOWINS, ONNEWRECINS, BEFOSAVEINS |
| **POCANUME** | Sequências | SEQUTABLE, SEQUCAMPO, SEQUVALO |

---

## 10. Como Executar

### 10.1 Pré-requisitos

- .NET 9 SDK
- Acesso ao banco Oracle ou SQL Server

### 10.2 Desenvolvimento

```bash
# Navegar para o projeto
cd C:\Users\geraldo.borges\CascadeProjects\SAG\SagPoc.Web

# Restaurar dependências
dotnet restore

# Executar em desenvolvimento
dotnet run --urls=http://localhost:5255
```

### 10.3 URLs de Teste

| URL | Descrição |
|-----|-----------|
| `http://localhost:5255` | Página inicial (lista de forms) |
| `http://localhost:5255/Form/Render/120` | Form 120 standalone |
| `http://localhost:5255/Form/RenderEmbedded/120` | Form 120 para iframe |
| `http://localhost:5255/api/sag/health` | Health check |
| `http://localhost:5255/api/sag/available-forms` | Lista de forms (JSON) |

### 10.4 Variáveis de Ambiente

| Variável | Descrição | Default |
|----------|-----------|---------|
| `ASPNETCORE_ENVIRONMENT` | Ambiente | Development |
| `DatabaseProvider` | Oracle ou SqlServer | appsettings.json |

---

## 11. Referências

### 11.1 Documentação Relacionada

| Documento | Caminho |
|-----------|---------|
| Plano de Integração Vue | `Base/PLANO_INTEGRACAO_SAG_VUE.md` |
| Manual PLSAG | `Base/MANUAL_PLSAG.md` |
| Dicionário SISTTABE/SISTCAMP | `Base/DICIONARIO_DADOS_SISTTABE_SISTCAMP.md` |
| Sistema de Eventos | `Base/SISTEMA_EVENTOS_PLSAG.md` |
| Gaps de Implementação | `Base/GAPS_PLSAG_EVENTS.md` |

### 11.2 Contatos

| Role | Nome |
|------|------|
| Dev SAG | Geraldo Borges |
| Time Vision | [A definir] |

---

*Documento gerado em 2026-01-05 para o time Vision Web.*
