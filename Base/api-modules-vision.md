# API de Módulos e Janelas SAG

Documentação da API REST para integração do Vision com o sistema de menus do SAG.

---

## Análise do Sistema Delphi

### Contexto de Usuário/Empresa/Módulo

O SAG Delphi usa uma string de contexto `UUUEEESSS` armazenada em `POCACONF.CONFCONF`:

```
U99E01S83
│  │  └── S83 = Sistema/Módulo 83 (Vendas - Distribuição)
│  └───── E01 = Empresa 01
└──────── U99 = Usuário 99
```

### Procedure MenuPers (Plus.pas:232-472)

Esta é a procedure central que constrói os menus dinamicamente:

```pascal
Procedure MenuPers(Form: TForm);
begin
  // 1. Query principal de menus
  SQL := 'SELECT POCaTabe.CodiTabe, NomeTabe, CaptTabe, HintTabe, MenuTabe, ' +
         'Sub_Tabe, NomeMenu, MenuMenu, Cnf_Menu, OrdeTabe, FormTabe, ' +
         'AtivMenu, ClicTabe, FixoTabe, AtalTabe, ParaTabe ' +
         'FROM POCaTabe, POCaMenu ' +
         'WHERE (POCaTabe.CodiTabe BETWEEN POCaMenu.InicMenu AND POCaMenu.FinaMenu) ' +
         'AND (MenuMenu IS NOT NULL) ' +
         'AND (AtivMenu <> 0) ' +
         'AND (POCaTabe.MePeTabe <> 0) ' +
         'AND (SistTabe LIKE ''%'' + GetPCodSist() + ''%'') ' +
         'AND (SistMenu LIKE ''%'' + GetPCodSist() + ''%'') ' +
         'AND (UPPER(MenuMenu) NOT IN (''MNUSIST'', ''MNUUTIL'')) ' +
         'ORDER BY MenuMenu, OrdeTabe, Sub_Tabe';

  // 2. Para cada registro, cria TsgMenuItem dinamicamente
  // 3. Define Tag = GetPSis() para filtro de visibilidade
  // 4. Associa OnClick conforme ClicTabe (ClicShow, ClicManu, etc)
end;
```

### Funções de Contexto

| Função | Retorno | Exemplo | Uso |
|--------|---------|---------|-----|
| `GetPSis()` | INTEGER | 1, 2, 83 | Comparações numéricas, Tags |
| `GetPCodSist()` | STRING | 'S01', 'S83' | Queries LIKE |
| `GetPUsu()` | STRING | 'Supervisor' | Identificação usuário |
| `GetPEmp()` | INTEGER | 1, 2 | Empresa selecionada |

### Fluxo de Seleção de Módulo (POGePrin.pas:1599-1850)

```
1. Usuário seleciona módulo em LcbCodiProd
2. SetPSis(LcbCodiProd.ValorInteiro) - define módulo ativo
3. GravPOCaConf() - persiste em POCACONF
4. Destroi menus antigos (Tag = 999)
5. MenuPers(Self) - reconstrói menus do módulo
6. DefiAces() - aplica permissões via FUN_ACES_TABE()
```

### Estrutura de Menus no DFM (POGePrin.dfm)

Os menus têm ordem fixa definida no DFM, não no banco:

```delphi
object MnuPrin: TPopupMenu
  object MnuCada: TsgMenuItem     // Ordem 1 - Cadastro
  object MnuLote: TsgMenuItem     // Ordem 2 - Lote
  object MnuCompComp: TsgMenuItem // Ordem 3 - Compras
  object MnuFina: TsgMenuItem     // Ordem 4 - Financeiro
  object MnuNota: TsgMenuItem     // Ordem 5 - Nota Fiscal
  object MnuPreV: TsgMenuItem     // Ordem 6 - Pré-Venda
  object MnuVend: TsgMenuItem     // Ordem 7 - Venda Direta
  object MnuAbat: TsgMenuItem     // Ordem 8 - Abatedouro
  object MnuEsto: TsgMenuItem     // Ordem 11 - Estoque
  object MnuExpe: TsgMenuItem     // Ordem 12 - Expedição
  // ... Mnu001 a Mnu020 (placeholders dinâmicos)
  object MnuPers: TsgMenuItem     // Ordem 50 - Personalizado
  object MnuGere: TsgMenuItem     // Ordem 60 - Gerência
  object MnuSist: TsgMenuItem     // Ordem 90 - Sistema (Tag=95, global)
  object MnuUtil: TsgMenuItem     // Ordem 95 - Utilitários (Tag=95, global)
end;
```

---

## Estrutura das Tabelas Oracle

### CLCaProd (Módulos)

```sql
DESC CLCaProd;
-- Campos principais:
-- CODIPROD   NUMBER(38)      - Código do módulo (PK)
-- NOMEPROD   VARCHAR2(2500)  - Nome do módulo
-- SIGLPROD   CHAR(2)         - Sigla (MP, FI, ES, etc)
-- DESCPROD   VARCHAR2(100)   - Descrição
-- ORDEPROD   NUMBER(38)      - Ordem de exibição
-- ATIVPROD   NUMBER(38)      - Ativo (0/1)
-- PCODPROD   CHAR(3)         - Código formatado (S01, S83)
```

**Exemplo de dados:**
| CodiProd | NomeProd | SiglProd | OrdeProd |
|----------|----------|----------|----------|
| 1 | Matrizes Pesadas | MP | 20 |
| 9 | Financeiro | FI | 320 |
| 83 | Vendas - Distribuição | VD | 240 |

### POCaTabe (Janelas/Tabelas)

```sql
-- Campos principais:
-- CODITABE   NUMBER       - Código da tabela (PK)
-- NOMETABE   VARCHAR2     - Nome interno
-- CAPTTABE   VARCHAR2     - Caption para exibição
-- GRAVTABE   VARCHAR2     - Nome físico da tabela no banco
-- MENUTABE   VARCHAR2     - Nome do componente menu (MnuCaCl)
-- SISTTABE   VARCHAR2     - Filtro de módulos (%S01%S02%S83%)
-- MEPETABE   NUMBER       - Aparece no menu (0=não, <>0=sim)
-- ORDETABE   NUMBER       - Ordem dentro do menu
-- CLICTABE   VARCHAR2     - Handler de clique (ClicShow, ClicManu)
-- SUB_TABE   NUMBER       - É submenu (>0 = sim)
```

### POCaMenu (Menus Pai)

```sql
-- Campos principais:
-- CODIMENU   NUMBER       - Código do menu (PK)
-- MENUMENU   VARCHAR2     - Nome do componente (MnuCada, MnuFina)
-- NOMEMENU   VARCHAR2     - Caption exibido (&Cadastro)
-- INICMENU   NUMBER       - CodiTabe inicial do range
-- FINAMENU   NUMBER       - CodiTabe final do range
-- SISTMENU   VARCHAR2     - Filtro de módulos
-- ATIVMENU   NUMBER       - Ativo (0/1)
-- ORDEMENU   NUMBER       - Ordem de exibição
```

### POCaConf (Configuração do Usuário)

```sql
-- CONFCONF armazena a string de contexto:
-- Exemplo: 'U99E01S83' (Usuário 99, Empresa 01, Sistema 83)
SELECT CONFCONF FROM POCACONF WHERE USERCONF = 'SAGADM';
```

### POViAcPr (View de Acesso a Módulos)

```sql
-- View que usa Oracle Context para filtrar módulos permitidos
SELECT TEXT FROM USER_VIEWS WHERE VIEW_NAME = 'POVIACPR';
-- Resultado: SELECT "CODIPROD" FROM TABLE (FUN_ACES_PROD)
```

---

## Proposta de Implementação

### Objetivo

Criar endpoints REST que forneçam módulos e janelas do SAG de forma dinâmica, permitindo ao Vision construir menus personalizados por usuário/empresa/módulo.

### Arquitetura Implementada

```
┌─────────────────────────────────────────────────────────────┐
│                        Vision (Frontend)                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Seletor de  │  │   Menu      │  │      iframe         │  │
│  │   Módulo    │→ │  Lateral    │→ │  /Form/RenderEmbed  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
           │                │                    │
           ▼                ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                    SAG POC Web (Backend)                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              ModulesController                       │    │
│  │  GET /api/modules                                    │    │
│  │  GET /api/modules/{id}/windows                       │    │
│  └─────────────────────────────────────────────────────┘    │
│                           │                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                ModuleService                         │    │
│  │  - GetModulesAsync()                                 │    │
│  │  - GetWindowsByModuleAsync(moduleId)                 │    │
│  │  - Carrega MenuOrder.json para ordenação             │    │
│  └─────────────────────────────────────────────────────┘    │
│                           │                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │               Oracle Database                        │    │
│  │  CLCaProd → POCaTabe → POCaMenu                      │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Arquivos Criados

| Arquivo | Descrição |
|---------|-----------|
| `Models/ModuleDto.cs` | DTOs: ModuleDto, WindowDto, MenuGroupDto |
| `Services/IModuleService.cs` | Interface do serviço |
| `Services/ModuleService.cs` | Implementação com queries Oracle |
| `Controllers/ModulesController.cs` | Endpoints REST |
| `Config/MenuOrder.json` | Ordenação visual dos menus |

### Queries Implementadas

**GetModulesAsync:**
```sql
SELECT CodiProd, NomeProd, SiglProd, DescProd, OrdeProd, AtivProd
FROM CLCaProd
WHERE AtivProd = 1 AND CodiProd > 0
ORDER BY OrdeProd, CodiProd
```

**GetWindowsByModuleAsync:**
```sql
SELECT DISTINCT
    t.CodiTabe, t.CaptTabe, t.NomeTabe, t.SiglTabe,
    t.OrdeTabe, t.MenuTabe, m.MenuMenu, m.NomeMenu, m.OrdeMenu
FROM POCaTabe t
INNER JOIN POCaMenu m ON t.CodiTabe BETWEEN m.InicMenu AND m.FinaMenu
WHERE t.MePeTabe <> 0
  AND t.SistTabe LIKE '%S' || LPAD(:moduleId, 2, '0') || '%'
  AND m.SistMenu LIKE '%S' || LPAD(:moduleId, 2, '0') || '%'
  AND m.AtivMenu <> 0
  AND t.CaptTabe <> '-'      -- Exclui separadores
  AND t.NomeTabe <> 'SUB'    -- Exclui submenus vazios
  AND UPPER(m.MenuMenu) NOT IN ('MNUSIST', 'MNUUTIL')
ORDER BY m.OrdeMenu, t.OrdeTabe
```

### Decisões de Design

1. **Hardcoded U99E01**: Na POC, não usa Oracle Context. Todos os módulos ativos são retornados.

2. **Ordenação por arquivo**: `MenuOrder.json` reproduz a ordem visual do DFM, garantindo consistência entre Delphi e Web.

3. **Agrupamento por menu**: Janelas são agrupadas por MenuMenu para facilitar construção de menus hierárquicos.

4. **Exclusão de menus globais**: MNUSIST e MNUUTIL são excluídos (são sempre visíveis no Delphi).

5. **Mapeamento de ícones**: Siglas são mapeadas para ícones Lucide quando disponível.

---

## Base URL

```
http://localhost:5255
```

## Endpoints

### 1. Listar Módulos

Retorna todos os módulos disponíveis no SAG.

```http
GET /api/modules
```

**Resposta:**

```json
{
  "success": true,
  "data": [
    {
      "moduleId": 1,
      "name": "Matrizes Pesadas",
      "sigla": "MP",
      "description": "Matrizes Pesadas",
      "order": 20,
      "icon": null,
      "windows": null
    },
    {
      "moduleId": 9,
      "name": "Financeiro",
      "sigla": "FI",
      "description": "Financeiro",
      "order": 320,
      "icon": "DollarSign",
      "windows": null
    }
  ]
}
```

**Campos:**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `moduleId` | int | Código do módulo (CodiProd) |
| `name` | string | Nome do módulo |
| `sigla` | string | Sigla de 2 caracteres |
| `description` | string | Descrição do módulo |
| `order` | int | Ordem de exibição |
| `icon` | string? | Nome do ícone Lucide (opcional) |
| `windows` | null | Não carregado neste endpoint |

---

### 2. Listar Janelas por Módulo (Agrupadas)

Retorna as janelas de um módulo, agrupadas por menu.

```http
GET /api/modules/{moduleId}/windows
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `moduleId` | int | Código do módulo |

**Resposta:**

```json
{
  "success": true,
  "data": [
    {
      "menuId": "MNUCADA",
      "caption": "Cadastro",
      "order": 1,
      "windows": [
        {
          "windowId": "SAG10",
          "tag": "SAG10",
          "name": "Empresas",
          "tableId": 10,
          "menuId": "MNUCADA",
          "menuGroup": "&Cadastro",
          "order": 3,
          "icon": null
        },
        {
          "windowId": "SAG90",
          "tag": "SAG90",
          "name": "Pessoas",
          "tableId": 90,
          "menuId": "MNUCADA",
          "menuGroup": "&Cadastro",
          "order": 5,
          "icon": null
        }
      ]
    },
    {
      "menuId": "MNUFINA",
      "caption": "Financeiro",
      "order": 4,
      "windows": [...]
    }
  ]
}
```

**Campos do MenuGroup:**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `menuId` | string | ID do menu (ex: "MNUCADA") |
| `caption` | string | Título do menu para exibição |
| `order` | int | Ordem de exibição do menu |
| `windows` | array | Lista de janelas do menu |

**Campos da Window:**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `windowId` | string | ID da janela (ex: "SAG120") |
| `tag` | string | Tag para roteamento (= windowId) |
| `name` | string | Nome da janela para exibição |
| `tableId` | int | Código da tabela para renderização |
| `menuId` | string | ID do menu pai |
| `menuGroup` | string | Nome do menu pai (do banco) |
| `order` | int | Ordem dentro do menu |
| `icon` | string? | Ícone Lucide (opcional) |

---

### 3. Listar Janelas por Módulo (Lista Plana)

Retorna as janelas sem agrupamento.

```http
GET /api/modules/{moduleId}/windows/flat
```

**Resposta:**

```json
{
  "success": true,
  "data": [
    {
      "windowId": "SAG10",
      "tag": "SAG10",
      "name": "Empresas",
      "tableId": 10,
      "menuId": "MNUCADA",
      "menuGroup": "&Cadastro",
      "order": 3,
      "icon": null
    }
  ]
}
```

---

## Renderização de Formulários

Para renderizar um formulário SAG no Vision, use iframe apontando para:

```
/Form/RenderEmbedded/{tableId}
```

**Exemplo:**

```html
<iframe src="http://localhost:5255/Form/RenderEmbedded/120" />
```

---

## Session Context (SagContext)

A API suporta contexto de sessão para identificação de usuário, empresa e módulo. Isso é essencial para sistemas que embedam a POC Web (como Vision).

### Como Passar o Contexto

O contexto pode ser passado de duas formas:

**1. Query Parameters (para iframe embedding):**

```
/Form/RenderEmbedded/120?usuarioId=5&empresaId=2&moduloId=83
```

**2. HTTP Headers (para chamadas API):**

```http
GET /api/modules/83/windows
X-Sag-Usuario-Id: 5
X-Sag-Empresa-Id: 2
X-Sag-Modulo-Id: 83
X-Sag-Usuario-Nome: João Silva
X-Sag-Empresa-Nome: Empresa ABC
X-Sag-Modulo-Nome: Vendas
```

### Defaults Internos da POC Web

**IMPORTANTE:** Quando nenhum contexto é fornecido, a POC Web usa os seguintes valores default (alinhados com `appsettings.json`):

| Parâmetro | Valor Default | Código Delphi | Descrição |
|-----------|---------------|---------------|-----------|
| `usuarioId` | **99** | U99 | Usuário SAGADM |
| `usuarioNome` | **SAGADM** | - | Nome do usuário |
| `empresaId` | **226** | E01 | Empresa 01 |
| `empresaNome` | **E01** | - | Código da empresa |
| `moduloId` | **83** | S83 | Vendas - Distribuição |
| `moduloNome` | **Vendas - Distribuição** | - | Nome do módulo |

> ⚠️ **Nota:** Esses defaults correspondem ao contexto "U99E01S83" do Delphi. Em produção, o Vision DEVE passar o contexto correto via query parameters ou headers.

### Acesso ao Contexto no JavaScript (Modo Embedded)

Quando usar `RenderEmbedded`, o contexto fica disponível via:

```javascript
// Contexto de sessão SAG (valores default = U99E01S83)
window.SAG_CONTEXT = {
    usuarioId: 99,
    usuarioNome: "SAGADM",
    empresaId: 226,
    empresaNome: "E01",
    moduloId: 83,
    moduloNome: "Vendas - Distribuição",
    isInitialized: true,
    createdAt: "2024-01-13T..."
};

// Exemplo de uso
console.log(`Usuário: ${SAG_CONTEXT.usuarioId} - ${SAG_CONTEXT.usuarioNome}`);
console.log(`Empresa: ${SAG_CONTEXT.empresaId} - ${SAG_CONTEXT.empresaNome}`);
```

### Endpoint de Contexto

Para obter o contexto atual (útil para debug):

```http
GET /Form/GetContext
```

**Resposta:**

```json
{
    "success": true,
    "context": {
        "usuarioId": 99,
        "usuarioNome": "SAGADM",
        "empresaId": 226,
        "empresaNome": "E01",
        "moduloId": 83,
        "moduloNome": "Vendas - Distribuição",
        "isInitialized": true,
        "createdAt": "2024-01-13T10:30:00Z"
    }
}
```

### Exemplo Completo para Vision

```typescript
const SAG_URL = import.meta.env.VITE_SAG_URL || 'http://localhost:5255';

// Estado do usuário logado no Vision
const currentUser = {
  id: 5,
  name: 'João Silva',
  empresaId: 2,
  empresaNome: 'Empresa ABC',
  moduloId: 83
};

// Renderizar formulário com contexto
function getSagFormUrl(tableId: number): string {
  const params = new URLSearchParams({
    usuarioId: String(currentUser.id),
    usuarioNome: currentUser.name,
    empresaId: String(currentUser.empresaId),
    empresaNome: currentUser.empresaNome,
    moduloId: String(currentUser.moduloId)
  });
  return `${SAG_URL}/Form/RenderEmbedded/${tableId}?${params}`;
}

// Chamada API com headers
async function fetchSagApi(endpoint: string) {
  return fetch(`${SAG_URL}${endpoint}`, {
    headers: {
      'X-Sag-Usuario-Id': String(currentUser.id),
      'X-Sag-Empresa-Id': String(currentUser.empresaId),
      'X-Sag-Modulo-Id': String(currentUser.moduloId),
      'X-Sag-Usuario-Nome': currentUser.name,
      'X-Sag-Empresa-Nome': currentUser.empresaNome
    }
  });
}
```

---

## Integração com Vision

### Configuração

```env
VITE_SAG_URL=http://localhost:5255
```

### Exemplo de Uso (TypeScript)

```typescript
const SAG_URL = import.meta.env.VITE_SAG_URL || 'http://localhost:5255';

// Buscar módulos
async function loadModules() {
  const response = await fetch(`${SAG_URL}/api/modules`);
  const data = await response.json();
  return data.success ? data.data : [];
}

// Buscar janelas de um módulo
async function loadWindows(moduleId: number) {
  const response = await fetch(`${SAG_URL}/api/modules/${moduleId}/windows`);
  const data = await response.json();
  return data.success ? data.data : [];
}

// Renderizar formulário
function renderForm(tableId: number) {
  return `${SAG_URL}/Form/RenderEmbedded/${tableId}`;
}
```

### Estrutura Sugerida para Menu

```typescript
interface SagModule {
  moduleId: number;
  name: string;
  sigla: string;
  icon?: string;
}

interface SagMenuGroup {
  menuId: string;
  caption: string;
  order: number;
  windows: SagWindow[];
}

interface SagWindow {
  windowId: string;
  tag: string;
  name: string;
  tableId: number;
  order: number;
}
```

---

## Ordenação dos Menus

Os menus seguem ordem fixa definida em `SagPoc.Web/Config/MenuOrder.json`:

| Ordem | Menu | Caption |
|-------|------|---------|
| 1 | MNUCADA | Cadastro |
| 2 | MNULOTE | Lote |
| 3 | MNUCOMPCOMP | Compras |
| 4 | MNUFINA | Financeiro |
| 5 | MNUNOTA | Nota Fiscal |
| 6 | MNUPREV | Pré-Venda |
| 7 | MNUVEND | Venda Direta |
| 8 | MNUABAT | Abatedouro |
| 11 | MNUESTO | Estoque |
| 12 | MNUEXPE | Expedição |
| 18 | MNUPEDI | Pedidos |
| 60 | MNUGERE | Gerência |

---

## Ícones Disponíveis (Lucide)

Mapeamento de siglas para ícones:

| Sigla | Ícone Lucide |
|-------|--------------|
| GE | Settings |
| CO | ShoppingCart |
| FI | DollarSign |
| ES | Package |
| CR | Users |
| CE | Wheat |
| LA | FlaskConical |
| FP | UserCheck |
| 1V | TrendingUp |
| WV | Globe |
| WP | Headphones |
| AV | Bird |
| PV | Smartphone |
| IS | Leaf |

---

## Notas Importantes

1. **CORS**: A API permite requisições de `localhost:3000`, `localhost:5173`, `localhost:8080`

2. **Contexto de Sessão**: A API suporta contexto dinâmico via query params ou headers HTTP:
   - Query: `?usuarioId=5&empresaId=2&moduloId=83`
   - Headers: `X-Sag-Usuario-Id`, `X-Sag-Empresa-Id`, `X-Sag-Modulo-Id`
   - **Defaults internos (U99E01S83)**: usuarioId=99, empresaId=226, moduloId=83

3. **Tabelas Oracle**:
   - `CLCaProd` - Cadastro de módulos
   - `POCaTabe` - Cadastro de janelas/tabelas
   - `POCaMenu` - Cadastro de menus

4. **Filtro de Sistema**: Janelas são filtradas por `SistTabe LIKE '%S{moduleId:02d}%'`

5. **Arquivos de Contexto**:
   - `Services/Context/SagContext.cs` - Modelo do contexto
   - `Services/Context/ISagContextAccessor.cs` - Interface de acesso
   - `Services/Context/SagContextAccessor.cs` - Implementação com defaults
   - `Middleware/SagContextMiddleware.cs` - Captura params/headers
