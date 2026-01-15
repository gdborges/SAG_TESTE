# API de Dashboards - POCWeb

## Visao Geral

API REST para fornecer dados de dashboards para o frontend Vision, seguindo o formato padronizado.

**Base URL**: `http://localhost:5255/api/dashboard`

---

## Endpoints

### 1. Listar Dashboards Disponiveis

**GET** `/api/dashboard/available`

Retorna todos os dashboards configurados e ativos.

**Resposta:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "moduleId": 1,
      "moduleName": "Matrizes Pesadas",
      "dashboardKey": "matrizes_pesadas",
      "active": true
    }
  ],
  "total": 1
}
```

---

### 2. Obter Dashboard por Modulo

**GET** `/api/dashboard/{moduleId}`

Retorna dados do dashboard para um modulo especifico.

**Parametros:**
| Parametro | Tipo | Descricao |
|-----------|------|-----------|
| `moduleId` | int | ID do modulo SAG |
| `startDate` | date (query) | Data inicial (opcional, para filtros futuros) |
| `endDate` | date (query) | Data final (opcional, para filtros futuros) |

**Exemplo:**
```
GET /api/dashboard/1
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "moduleId": 1,
    "moduleName": "Matrizes Pesadas",
    "metrics": [...],
    "distributions": [...],
    "trends": [],
    "rankings": [...],
    "quickActions": null
  },
  "error": null
}
```

---

## Estrutura de Dados

### Metrics (Cards de KPI)
```json
{
  "id": "total_lotes",
  "label": "Total de Lotes",
  "value": 10,
  "icon": "Layers",
  "color": "primary",
  "trend": null
}
```

| Campo | Tipo | Descricao |
|-------|------|-----------|
| `id` | string | Identificador unico |
| `label` | string | Texto do card |
| `value` | decimal | Valor numerico |
| `icon` | string | Nome do icone Lucide |
| `color` | string | `primary`, `success`, `warning`, `error`, `action` ou hex |
| `trend` | object | Tendencia comparativa (opcional) |

### Distributions (Graficos Doughnut)
```json
{
  "id": "linhagens",
  "title": "Distribuicao por Linhagem",
  "subtitle": "Lotes",
  "items": [
    { "category": "COBB", "value": 5, "color": "#447BDA" },
    { "category": "ROSS", "value": 3, "color": "#34A853" },
    { "category": "HUBBARD", "value": 2, "color": "#FF9F1D" }
  ]
}
```

### Rankings (Graficos de Barra)
```json
{
  "id": "top_viabilidade",
  "title": "Top 5 Lotes - Viabilidade",
  "maxItems": 5,
  "items": [
    { "category": "Lote 104", "value": 99.49, "color": "#34A853" },
    { "category": "Lote 102", "value": 98.53, "color": "#34A853" }
  ]
}
```

---

## Tabelas Oracle

### POCWEB_DASH_CONFIG
Configuracao dos dashboards por modulo.

```sql
SELECT * FROM POCWEB_DASH_CONFIG;
```

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| ID | NUMBER | PK auto-incremento |
| MODULO_ID | NUMBER | ID do modulo SAG |
| MODULO_NOME | VARCHAR2(100) | Nome do modulo |
| DASHBOARD_KEY | VARCHAR2(50) | Chave para roteamento |
| ATIVO | NUMBER(1) | 1 = ativo, 0 = inativo |

### POCWEB_DASH_MATRIZES
Dados de matrizes pesadas.

```sql
SELECT * FROM POCWEB_DASH_MATRIZES;
```

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| ID | NUMBER | PK auto-incremento |
| EMPRESA_ID | NUMBER | ID da empresa |
| DATA_CARGA | DATE | Data de carga dos dados |
| NRO_LOTE | NUMBER | Numero do lote |
| LINHAGEM_FEMEA | VARCHAR2(50) | COBB, ROSS, HUBBARD |
| IDADE | NUMBER | Idade em semanas |
| SALDO_FEMEA | NUMBER | Quantidade de femeas |
| VIABILIDADE_STANDARD | NUMBER(6,2) | Viabilidade padrao % |
| VIABILIDADE_REAL | NUMBER(6,2) | Viabilidade real % |
| ... | ... | (demais campos de producao) |

---

## Cores Padrao (Vision)

| Nome | Hex | Uso |
|------|-----|-----|
| `primary` | #447BDA | Informacoes neutras |
| `success` | #34A853 | Valores positivos |
| `warning` | #FF9F1D | Alertas |
| `error` | #EA4335 | Valores negativos |
| `action` | #0098A3 | Destaques |

---

## Icones (Lucide)

Icones disponiveis: https://lucide.dev/icons

Exemplos usados:
- `Layers` - Total de lotes
- `Bird` - Aves/femeas
- `Activity` - Viabilidade
- `Egg` - Eclosao

---

## Extensibilidade

Para adicionar um novo dashboard:

1. Criar tabela `POCWEB_DASH_<AREA>` com dados
2. Inserir registro em `POCWEB_DASH_CONFIG`
3. Implementar metodo `Get<Area>DashboardAsync()` em `DashboardService.cs`
4. Adicionar case no switch de `GetDashboardByModuleAsync()`

---

## Arquivos Criados

| Arquivo | Descricao |
|---------|-----------|
| `Controllers/DashboardController.cs` | REST API |
| `Services/IDashboardService.cs` | Interface |
| `Services/DashboardService.cs` | Implementacao |
| `Models/DashboardModels.cs` | DTOs |
| `Base/Dashboard/create_dashboard_tables.sql` | Script DDL |
| `Base/Dashboard/API_DASHBOARD.md` | Esta documentacao |
