# Plano de Integração: SAG POC no Vision Web (Vue 3)

**Data de criação:** 2026-01-03
**Status:** SAG pronto, Vue pendente
**Branch SAG:** `feature/apply-vision-design-system`
**Commit base:** `22a0675`

---

## Objetivo

Embedar os forms do SAG POC (ASP.NET Core MVC) dentro do Vision Web (Vue 3), utilizando a infraestrutura existente de menus personalizáveis do Vue.

**Visão do usuário:**
> "Fazer login no Edata, clicar no menu, dentro de personalizados ter um submenu SAG e as telas lá. Clicando abrir no 'miolo' do Vue as janelas."

---

## Estratégia Escolhida

**Vue embeda SAG via iframe** - escolhida por ser mais rápida e manter visual Vue.

### Por que esta abordagem?

1. O Vision já tem sistema de menus customizáveis (CDU/RDU/DDU) pronto
2. Só precisamos adicionar novo prefixo "SAG" e um viewer
3. Mantém login, sidebar, navbar, tema do Vue intactos
4. SAG continua funcionando standalone (sem refatoração)
5. Ambos projetos acessam bancos separados (Vue seus bancos, SAG Oracle)

---

## Arquitetura da Integração

```
┌─────────────────────────────────────────────────────────────┐
│  Vision Web (frontend-v2) - Vue 3 + Vite                    │
│  http://localhost:5173                                       │
│                                                              │
│  ┌──────────┐  ┌─────────────────────────────────────────┐  │
│  │ Sidebar  │  │                                         │  │
│  │          │  │   ┌─────────────────────────────────┐   │  │
│  │ CDU...   │  │   │                                 │   │  │
│  │ RDU...   │  │   │   <iframe>                      │   │  │
│  │ DDU...   │  │   │                                 │   │  │
│  │ ──────── │  │   │   SAG POC Form (CodiTabe)      │   │  │
│  │ SAG001 ←─┼──┼───│   http://localhost:5255        │   │  │
│  │ SAG002   │  │   │                                 │   │  │
│  │ SAG003   │  │   └─────────────────────────────────┘   │  │
│  │          │  │                                         │  │
│  └──────────┘  └─────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  SAG POC (ASP.NET Core)                                     │
│  http://localhost:5255                                       │
│                                                              │
│  /Form/Render/{tableId}         → HTML completo do form     │
│  /Form/RenderEmbedded/{tableId} → HTML sem layout (iframe)  │
│  /api/sag/available-forms       → Lista forms para menu     │
│  /api/sag/form/{tableId}        → Info detalhada do form    │
│  /api/sag/modules               → Módulos disponíveis       │
│  /api/sag/health                → Health check              │
│  /api/plsag/*                   → APIs PLSAG                │
│  /api/movement/*                → APIs de movimentos        │
└─────────────────────────────────────────────────────────────┘
```

---

## Fase 1: SAG - Preparar para Embedding [CONCLUÍDA ✓]

### 1.1 CORS Configurado
**Arquivo:** `SagPoc.Web/Program.cs`

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("VisionWeb", policy =>
    {
        policy.WithOrigins(
                "http://localhost:5173",    // Vite dev server
                "http://localhost:8080",    // Alternate dev port
                "http://127.0.0.1:5173",
                "http://vision.local"       // Production
            )
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
});

// No pipeline:
app.UseCors("VisionWeb");
```

### 1.2 RenderEmbedded Action
**Arquivo:** `SagPoc.Web/Controllers/FormController.cs`

```csharp
[HttpGet("Form/RenderEmbedded/{id}")]
public async Task<IActionResult> RenderEmbedded(int id)
{
    // Mesma lógica de Render, mas usa view sem layout
    return View("RenderEmbedded", viewModel);
}
```

### 1.3 View Self-Contained
**Arquivo:** `SagPoc.Web/Views/Form/RenderEmbedded.cshtml`

- `@{ Layout = null; }` - sem master layout
- CSS Bootstrap via CDN inline
- Todos os JS inline (plsag-interpreter, sag-events, etc.)
- PostMessage API para comunicação com Vue parent:

```javascript
window.SAG_EMBEDDED = true;

function notifyParent(type, data) {
    if (window.parent !== window) {
        window.parent.postMessage({ type: type, data: data }, '*');
    }
}

// Eventos disponíveis:
// - SAG_FORM_LOADED
// - SAG_RECORD_SAVED
// - SAG_RECORD_DELETED
// - SAG_ERROR
```

### 1.4 API REST para Vue
**Arquivo:** `SagPoc.Web/Controllers/SagApiController.cs`

#### GET /api/sag/available-forms
Retorna lista de forms para exibir no menu Vue.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "tableId": 120,
      "name": "MNUPOCAMVCT",
      "description": "Contratos",
      "tag": "SAG001",
      "sigla": "COTR",
      "moduleId": "SAG",
      "tableType": "standalone"
    },
    ...
  ],
  "total": 1207
}
```

#### GET /api/sag/form/{tableId}
Retorna info detalhada de um form específico.

**Response:**
```json
{
  "success": true,
  "data": {
    "tableId": 120,
    "name": "Contratos",
    "sigla": "COTR",
    "menuName": "MNUPOCAMVCT",
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

#### GET /api/sag/modules
```json
{
  "success": true,
  "data": [
    { "moduleId": "SAG", "tableCount": 1207 }
  ]
}
```

#### GET /api/sag/health
```json
{
  "status": "healthy",
  "provider": "Oracle",
  "timestamp": "2026-01-03T16:00:10.718Z"
}
```

---

## Fase 2: Vue - Criar Infraestrutura [CONCLUIDA]

### 2.1 Adicionar Prefixo SAG ao Mapeamento
**Arquivo:** `frontend-v2/src/stores/sidebarStore.ts`

```typescript
const routes: Record<string, string> = {
  CDU: 'consulta-customizada',
  RDU: 'relatorio-customizado',
  DDU: 'dashboard-customizado',
  SAG: 'sag-form',  // ADICIONAR
};
```

### 2.2 Adicionar no CustomMenuGroup
**Arquivo:** `frontend-v2/src/components/menu/CustomMenuGroup.vue`

Mesmo mapeamento na função `navigateTo()`.

### 2.3 Criar Rota Dinâmica
**Arquivo:** `frontend-v2/src/router/register.routes.ts`

```typescript
{
  path: "/sag-form/:tag/:tableId",
  name: "SagFormViewer",
  component: () => import("../views/private/sag/sag-form-viewer.vue"),
  meta: {
    requiresAuth: true,
    translatedName: '',
    module: ModuleOptions.CAD,
    layout: () => import("../layouts/side-nav.vue")
  }
}
```

### 2.4 Criar Viewer Component
**Arquivo:** `frontend-v2/src/views/private/sag/sag-form-viewer.vue`

```vue
<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useNotificationStore } from '@/stores/notificationStore'

const route = useRoute()
const notificationStore = useNotificationStore()

const tableId = computed(() => route.params.tableId as string)
const loading = ref(true)
const iframeRef = ref<HTMLIFrameElement | null>(null)

const sagBaseUrl = import.meta.env.VITE_SAG_URL || 'http://localhost:5255'
const iframeSrc = computed(() =>
  `${sagBaseUrl}/Form/RenderEmbedded/${tableId.value}`
)

// Listener para mensagens do SAG iframe
function handleSagMessage(event: MessageEvent) {
  if (event.origin !== sagBaseUrl) return

  const { type, data } = event.data || {}

  switch (type) {
    case 'SAG_FORM_LOADED':
      loading.value = false
      break
    case 'SAG_RECORD_SAVED':
      notificationStore.success('Registro salvo com sucesso!')
      break
    case 'SAG_RECORD_DELETED':
      notificationStore.success('Registro excluído!')
      break
    case 'SAG_ERROR':
      notificationStore.error(data?.message || 'Erro no SAG')
      break
  }
}

onMounted(() => {
  window.addEventListener('message', handleSagMessage)
})

onUnmounted(() => {
  window.removeEventListener('message', handleSagMessage)
})
</script>

<template>
  <div class="sag-form-container h-full">
    <div v-if="loading" class="flex items-center justify-center h-64">
      <span class="loading loading-spinner loading-lg" />
    </div>
    <iframe
      ref="iframeRef"
      :src="iframeSrc"
      class="w-full h-full border-0"
      style="min-height: 80vh;"
      @load="loading = false"
    />
  </div>
</template>

<style scoped>
.sag-form-container {
  padding: 0;
  margin: 0;
}
</style>
```

### 2.5 Variável de Ambiente
**Arquivo:** `frontend-v2/.env` ou `.env.local`

```
VITE_SAG_URL=http://localhost:5255
```

### 2.6 Service para Buscar Forms SAG
**Arquivo:** `frontend-v2/src/services/sagService.ts`

```typescript
import axios from 'axios'

const SAG_BASE_URL = import.meta.env.VITE_SAG_URL || 'http://localhost:5255'

export interface SagFormInfo {
  tableId: number
  name: string
  description: string
  tag: string
  sigla: string
  moduleId: string
  tableType: string
}

export async function getAvailableForms(): Promise<SagFormInfo[]> {
  const response = await axios.get(`${SAG_BASE_URL}/api/sag/available-forms`)
  if (response.data.success) {
    return response.data.data
  }
  throw new Error(response.data.message || 'Erro ao buscar forms SAG')
}

export async function getFormInfo(tableId: number) {
  const response = await axios.get(`${SAG_BASE_URL}/api/sag/form/${tableId}`)
  if (response.data.success) {
    return response.data.data
  }
  throw new Error(response.data.message || 'Form não encontrado')
}

export async function healthCheck() {
  const response = await axios.get(`${SAG_BASE_URL}/api/sag/health`)
  return response.data
}
```

---

## Fase 3: Registrar Forms SAG no Menu [CONCLUIDA]

### Opção A: Via API Dinâmica (Recomendada)

O sidebarStore chama `/api/sag/available-forms` e monta os itens de menu dinamicamente.

### Opção B: Via Arquivo JSON (Alternativa para POC)

Criar arquivo `sag-menu.json` com subset de forms para exibir:

```json
{
  "forms": [
    { "tableId": 120, "name": "Contratos", "tag": "SAG001" },
    { "tableId": 715, "name": "Pedidos de Venda", "tag": "SAG002" },
    { "tableId": 400, "name": "Produtos", "tag": "SAG003" }
  ]
}
```

---

## Fase 4: Comunicação Vue ↔ SAG (Opcional)

### PostMessage API

**SAG → Vue:**
```javascript
// No SAG (após salvar)
window.parent.postMessage({
  type: 'SAG_RECORD_SAVED',
  data: { tableId: 120, recordId: 123 }
}, '*');
```

**Vue → SAG:**
```javascript
// No Vue (para comandos)
iframeRef.value?.contentWindow?.postMessage({
  type: 'VUE_COMMAND',
  data: { action: 'refresh' }
}, sagBaseUrl);
```

---

## Arquivos Criados/Modificados

### SAG POC [CONCLUÍDO ✓]

| Arquivo | Status | Descrição |
|---------|--------|-----------|
| `SagPoc.Web/Program.cs` | ✓ Modificado | CORS para Vue |
| `SagPoc.Web/Controllers/FormController.cs` | ✓ Modificado | RenderEmbedded action |
| `SagPoc.Web/Views/Form/RenderEmbedded.cshtml` | ✓ Criado | View sem layout |
| `SagPoc.Web/Controllers/SagApiController.cs` | ✓ Criado | API REST |

### Vision Web (frontend-v2) [CONCLUIDO]

| Arquivo | Status | Descricao |
|---------|--------|-----------|
| `src/stores/sidebarStore.ts` | Modificado | Adicionado prefixo SAG |
| `src/components/menu/CustomMenuGroup.vue` | Modificado | Adicionado SAG ao navigateTo e sortCustomItems |
| `src/router/register.routes.ts` | Modificado | Rota /sag-form/:tag/:tableId |
| `src/views/private/sag/sag-form-viewer.vue` | Criado | Viewer com iframe e postMessage |
| `src/server/api/sag/sagService.ts` | Criado | Service para API SAG |
| `.env.development.local` | Modificado | VITE_SAG_URL=http://localhost:5255 |
| `src/components/menu/Sidebar.vue` | Modificado | getSagForms() carrega forms SAG no menu |

---

## Como Testar

### 1. Iniciar SAG
```bash
cd C:\Users\geraldo.borges\CascadeProjects\SAG\SagPoc.Web
dotnet run --urls=http://localhost:5255
```

### 2. Testar Endpoints SAG
```bash
# Health check
curl http://localhost:5255/api/sag/health

# Lista de forms
curl http://localhost:5255/api/sag/available-forms

# Info de um form
curl http://localhost:5255/api/sag/form/120

# Renderizar form embedded
# Abrir no browser: http://localhost:5255/Form/RenderEmbedded/120
```

### 3. Iniciar Vue (quando implementado)
```bash
cd C:\Users\geraldo.borges\CascadeProjects\Edata\frontend-v2
npm run dev
```

### 4. Testar Integração
1. Abrir http://localhost:5173
2. Fazer login
3. Ir para menu Personalizados > SAG
4. Clicar em um form SAG
5. Verificar se iframe carrega corretamente

---

## Decisões Técnicas

| Decisão | Escolha | Motivo |
|---------|---------|--------|
| Hospedagem | Local dev, portas separadas | Simplicidade para POC |
| Banco de Dados | Vue e SAG isolados | Vue usa seus bancos, SAG continua Oracle |
| Menu | API dinâmica | Flexibilidade, forms atualizados automaticamente |
| Auth | Login via Vue, SAG sem auth | POC - acesso interno |
| Comunicação | PostMessage API | Cross-origin seguro |

---

## Proximos Passos

1. [x] Implementar Fase 2 - Infraestrutura Vue
2. [x] Implementar Fase 3 - Integrar forms no menu (via API dinamica)
3. [ ] Testar integracao completa
4. [ ] (Opcional) Implementar Fase 4 - PostMessage bidirecional

---

## Referências

### Projetos

- **SAG POC:** `C:\Users\geraldo.borges\CascadeProjects\SAG`
- **Vision Web:** `C:\Users\geraldo.borges\CascadeProjects\Edata\frontend-v2`

### Documentação Relacionada

- `frontend-v2/IA/menus-personalizados-cdu.md` - Sistema de menus customizáveis
- `frontend-v2/IA/VISAO_GERAL_SISTEMA_VISION_WEB.md` - Arquitetura Vue
- `SAG/CLAUDE.md` - Instruções do projeto SAG

### Credenciais

**Oracle (SAG):**
- Data Source: `SAG`
- User: `Comercial`
- Password: `ComeW88_01_`

---

*Documento gerado em 2026-01-03 para continuidade do projeto de integração.*
