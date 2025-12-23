# Padrões Comuns para CRUD

Este guia apresenta os padrões, estruturas e convenções comuns utilizadas em todos os tipos de CRUD no projeto.

## Estrutura de Arquivos
**IMPORTANTE:** 
Quando vamos implementar um CRUD com TabsPanel, devemos ter em mente que a estrutura de pastas deve ser a seguinte:

```
src/views/private/[module]/[entity]/  
├── [entity].vue                # Tela principal
├── [tab1].vue                  # Aba 1
├── [tab2].vue                  # Aba 2
```

Quando vamos implementar um CRUD com Modal ou Panel, devemos ter em mente que a estrutura de pastas deve ser a seguinte:

```
src/views/private/[module]/
├── [entity].vue              
└── tests/
    └── [entity].spec.ts        # Testes unitários
```

## Imports Padrão

### Imports Essenciais

```typescript
// Componentes base
import Grid from '../../../components/grid/Grid.vue';
import Modal from '../../../components/modals/Modal.vue';
import TabsPanel from '../../../components/modals/TabsPanel.vue';
import Panel from '../../../components/modals/Panel.vue';
import ConfirmationModal from '../../../components/modals/ConfirmationModal.vue';

// Services
import { use[Entity]Service } from '../../../server/api/[module]/[entity]';

// Interfaces
import { [Entity] } from '../../../interfaces/api/[module]/[Entity]';
import { ViewMode } from '../../../interfaces/Generic';
import { GridHeaderProps } from '../../../interfaces/components/Grid';

// Composables
import { useExceptionHandler } from '../../../composables/useExceptionHandler';
import { useCurrencyFormatter } from '../../../composables/useCurrencyFormatter';

// Utilitários
import { z } from 'zod';
import { formatDate } from '../../../utils/helpers/date';
import moment from 'moment';
```

## Estrutura de Estado Padrão

### Interface de Estado Base

```typescript
interface State {
  openModal: boolean;           // Controla abertura do modal/panel
  showDeleteModal: boolean;     // Controla modal de confirmação de exclusão
  isLoadingButton: boolean;     // Estado de loading dos botões
  viewMode: ViewMode;          // 'create' | 'update' | 'view' | 'delete'
  tabIndex?: number;           // Para TabsPanel (índice da aba ativa)
  gridWasOpened?: boolean;     // Para Panel (controle de exibição do grid)
  formHasChanges?: boolean;    // Para Panel (detecta mudanças no formulário)
}

// Estado reativo padrão
const state: State = reactive({
  openModal: false,
  showDeleteModal: false,
  isLoadingButton: false,
  viewMode: 'view',
  tabIndex: 0,              // Se usar TabsPanel
  gridWasOpened: false,     // Se usar Panel
  formHasChanges: false,    // Se usar Panel
});
```

### Referências de Template

```typescript
// Grid sempre presente
const grid[Entity] = useTemplateRef('grid[Entity]');

// Para TabsPanel - componentes das abas
const componentTab1 = useTemplateRef('componentTab1');
const componentTab2 = useTemplateRef('componentTab2');
```

### Services e Composables

```typescript
// Service principal da entidade
const [entity]Service = use[Entity]Service();

// Exception handler (sempre necessário)
const { onException, onSuccess, onValidateErrors } = useExceptionHandler();

// Tradução (sempre necessário)
const translate = inject("$translate") as (key: string) => string;

// Currency formatter (quando necessário)
const { formattedValue, updateValue } = useCurrencyFormatter(
  () => [entity].value,
  (_, value) => {
    [entity].value = value as number;
    if (state.viewMode === 'update') state.formHasChanges = true; // Para Panel
  }
);
```

## Estrutura de Entidade Padrão

### Definição da Entidade

```typescript
// Estrutura inicial da entidade
const initial[Entity]: [Entity] = reactive({
  code: 0,                   // Código numérico
  name: '',                  // Nome/descrição principal
  description: '',           // Descrição detalhada
  isActive: true,              // Status ativo/inativo
  createdAt: null,          // Data de criação
  updatedAt: null,          // Data de atualização
  // ... campos específicos da entidade
});

// Entidade reativa
const [entity]: [Entity] = reactive({ ...initial[Entity] });
```

### Dados Auxiliares

```typescript
// Arrays para selects, lookups, etc.
const categories = ref<Category[]>([]);
const users = ref<Usuario[]>([]);
const status = ref<Status[]>([]);

// Opções estáticas para selects
const typeOptions = [
  { name: translate('[module].[code].type.option1'), value: 0 },
  { name: translate('[module].[code].type.option2'), value: 1 },
  { name: translate('[module].[code].type.option3'), value: 2 },
];
```

## Validação com Zod - Padrões

### Schema Base

```typescript
const [entity]Schema = z.object({
  // Campos de texto obrigatórios
  name: z.string()
    .nonempty(translate('errors.[code].validation.name.required'))
    .max(100, translate('errors.[code].validation.name.maxLength')),
  
  description: z.string()
    .nonempty(translate('errors.[code].validation.description.required'))
    .max(255, translate('errors.[code].validation.description.maxLength')),
  
  // Campos numéricos
  code: z.number({
    required_error: translate('errors.[code].validation.code.required'),
    invalid_type_error: translate('errors.[code].validation.code.required')
  }).min(1, translate('errors.[code].validation.codigo.min')),
  
  // Campos de data
  dueDate: z.string({
    required_error: translate('errors.[code].validation.dueDate.required'),
    invalid_type_error: translate('errors.[code].validation.dueDate.required')
  }),
  
  // Campos de seleção
  categoryId: z.string()
    .nonempty(translate('errors.[code].validation.categoryId.required')),
  
  // Campos booleanos
  isActive: z.boolean({
    required_error: translate('errors.[code].validation.isActive.required'),
    invalid_type_error: translate('errors.[code].validation.isActive.required'),
  }),
  
  // Campos opcionais
  observation: z.string().optional(),
  
  // Validações condicionais
  value: z.number().refine(
    (val) => val > 0,
    translate('errors.[code].validation.value.positive')
  ),
});

// Objeto para erros de validação
const formErrors = reactive<{ [key: string]: string }>({});
```

### Validações Customizadas

```typescript
// Validação de email
const emailSchema = z.string().email(translate('errors.validation.email.invalid'));

// Validação de CPF/CNPJ
const documentSchema = z.string().refine(
  (val) => isValidDocument(val),
  translate('errors.validation.document.invalid')
);

// Validação de data futura
const futureDateSchema = z.string().refine(
  (val) => moment(val).isAfter(moment()),
  translate('errors.validation.date.future')
);
```

## Configuração do Grid

### Definição de Colunas Padrão

```typescript
const colsDefs = computed(() => [
  // Coluna de código (sempre primeira)
  { 
    headerName: translate('entities.[code].code'), 
    field: "code", 
    flex: 1, 
    sortable: true, 
    cellDataType: "number"
  },
  
  // Colunas de texto
  { 
    headerName: translate('entities.[code].name'), 
    field: "name", 
    flex: 1, 
    sortable: true, 
    cellDataType: "text" 
  },
  
  // Colunas com formatação
  { 
    headerName: translate('entities.[code].createdAt'), 
    field: "createdAt", 
    flex: 1, 
    sortable: true, 
    valueFormatter: (date: ValueFormatterParams) => formatDate(date.value),
    cellDataType: "date" 
  },
  
  // Colunas booleanas
  { 
    headerName: translate('entities.[code].active'), 
    field: "active", 
    flex: 1, 
    sortable: true, 
    cellDataType: "boolean" 
  },
  
  // Colunas com lookup/relacionamento
  { 
    headerName: translate('entities.[code].category'), 
    field: "categoryId", 
    flex: 1, 
    sortable: true, 
    cellDataType: "text",
    valueFormatter: (category: ValueFormatterParams) => 
      categories.value.find((c) => c.id === category.value)?.name || '',
  },
]);

// Header props padrão
const headerProps: GridHeaderProps = reactive({
  newItem: view[Entity]
});
```

## Funções CRUD Padrão

### Estrutura Base das Funções

```typescript
// 1. Função de visualização/criação
function view[Entity]() {
  resetFields();
  state.viewMode = 'create';
  state.openModal = true;
  state.formHasChanges = false; // Para Panel
}

// 2. Função de criação
async function create[Entity]() {
  try {
    state.isLoadingButton = true;

    // Preparação do payload (remover campos desnecessários)
    const { code, createdAt, updatedAt, ...payload } = [entity];

    // Validação
    const validationResult = [entity]Schema.safeParse(payload);
    if (!onValidateErrors(validationResult, formErrors)) {
      return onException(validationResult.error, translate('errors.validationError'));
    }

    // Chamada da API
    const { result, error } = await [entity]Service.create[Entity](payload);
    if (error.value) {
      return onException(error.value, translate('errors.[code].createError'));
    }

    // Atualização do grid e estado
    grid[Entity].value?.createRow(result.value);
    state.viewMode = 'update'; // Para TabsPanel
    Object.assign([entity], result.value);
    
    // Fechamento do modal (para Modal simples)
    if (useModal) state.openModal = false;
    
    return onSuccess(translate('errors.success'), translate('errors.[code].createSuccess'));
  
  } finally {
    state.isLoadingButton = false;
  }
}

// 3. Função de atualização
async function update[Entity]() {
  try {
    state.isLoadingButton = true;

    // Validação
    const validationResult = [entity]Schema.safeParse([entity]);
    if (!onValidateErrors(validationResult, formErrors)) {
      return onException(validationResult.error, translate('errors.validationError'));
    }

    // Chamada da API
    const { error, result } = await [entity]Service.update[Entity]([entity].code, [entity]);
    if (error.value) {
      return onException(error.value, translate('errors.[code].updateError'));
    }
    
    // Atualização do grid
    grid[Entity].value?.updateRow(result.value);
    Object.assign([entity], result.value);
    
    // Fechamento do modal (para Modal simples)
    if (useModal) state.openModal = false;
    
    return onSuccess(translate('errors.success'), translate('errors.[code].updateSuccess'));

  } finally {
    state.isLoadingButton = false;
  }
}

// 4. Função de exclusão
async function delete[Entity]() {
  try {
    state.isLoadingButton = true;
    
    const { error } = await [entity]Service.delete[Entity]([entity].code);
    if (error.value) {
      return onException(error.value, translate('errors.[code].deleteError'));
    }
    
    grid[Entity].value?.deleteRow([entity]);
    return onSuccess(translate('errors.success'), translate('errors.[code].deleteSuccess'));

  } finally {
    state.showDeleteModal = false;
    state.openModal = false;
    state.isLoadingButton = false;
  }
}

// 5. Função de busca
async function get[Entity](event: any) {
  try {
    const [entity]EventByClickTable = event.data as [Entity];
    const { result, error } = await [entity]Service.get[Entity]([entity]EventByClickTable.code);

    if (error.value) {
      return onException(error.value, translate('errors.[code].get[Entity]Error'));
    }

    Object.assign([entity], result.value.data);

  } finally {
    state.openModal = true;
  }
}

// 6. Função de reset
function resetFields() {
  Object.assign([entity], initial[Entity]);
  Object.keys(formErrors).forEach(key => formErrors[key] = '');
  state.formHasChanges = false; // Para Panel
}

// 7. Save info (para Modal e TabsPanel)
const saveInfo = () => state.viewMode === 'create' ? create[Entity]() : update[Entity]();
```

## Ciclo de Vida

### onMounted/onBeforeMount Padrão

```typescript
onMounted(async () => {
  await Promise.allSettled([
    getCategories(),
    getUsers(),
    getStatus(),
  ]);
});

// Ou para dados que precisam estar disponíveis antes da renderização
onBeforeMount(async () => {
  await Promise.allSettled([
    getEssentialData()
  ]);
});
```

### Funções de Carregamento de Dados

```typescript
async function getCategories() {
  try {
    const { result, error } = await categoryService.getCategories();
    if (error.value) {
      return onException(error.value, translate('errors.[code].getCategoriesError'));
    }
    categories.value = result.value.data;
  } finally { }
}
```

## Computed Properties Comuns

### Para Panel

```typescript
const isDisabledMode = computed(() => 
  [entity].status === Status.Approved || [entity].status === Status.Reproved
);

const showSaveButton = computed(() => {
  if (state.viewMode === 'create') return true;
  return state.viewMode === 'update' && !isDisabledMode.value && state.formHasChanges;
});

const showActionButton = computed(() => 
  [entity].status === Status.Analysis && state.viewMode === 'update'
);
```

### Para TabsPanel

```typescript
const currentBreadcrumbTitle = computed(() => {
  switch (state.tabIndex) {
    case 0: return translate('[module].[code].tabs.details.title');
    case 1: return translate('[module].[code].tabs.segunda.title');
    default: return translate('[module].[code].title');
  }
});
```

### Para formatação de dados

```typescript
const [entity]Date = computed({
  get() {
    return [entity].date ? new Date([entity].date) : null
  },
  set(newDate) {
    [entity].date = newDate
  }
});
```

## Watchers Comuns

### Para detectar mudanças no formulário (Panel)

```typescript
watch(
  () => ({
    name: [entity].name,
    description: [entity].description,
    categoryId: [entity].categoryId,
    // ... outros campos monitorados
  }),
  () => {
    if (state.viewMode === 'update') {
      state.formHasChanges = true;
    }
  },
  { deep: true }
);
```

### Para validação em tempo real

```typescript
watch(
  () => [entity].email,
  (newEmail) => {
    if (newEmail && !isValidEmail(newEmail)) {
      formErrors.email = translate('errors.validation.email.invalid');
    } else {
      formErrors.email = '';
    }
  }
);
```

## Tratamento de Erros Padrão

### Estrutura de Try/Catch

```typescript
async function operation() {
  try {
    state.isLoadingButton = true;
    
    // Lógica da operação
    const { result, error } = await service.operation();
    
    if (error.value) {
      return onException(error.value, translate('errors.operationError'));
    }
    
    // Sucesso
    return onSuccess(translate('errors.success'), translate('errors.operationSuccess'));
    
  } catch (err) {
    return onException(err, translate('errors.unexpectedError'));
  } finally {
    state.isLoadingButton = false;
  }
}
```

### Validações de Regra de Negócio

```typescript
// Antes de executar operação
if ([entity].status === Status.Completed) {
  onException(
    translate('errors.[code].cannotModifyCompleted'),
    translate('common.messages.errors.error')
  );
  return;
}
```

## Estilos Padrão

```scss
<style scoped lang="scss">
.page-[entity-name] {
  height: 100%;
}

// Para Modal
.[entity]-modal {
  ::v-deep(.modal-card) {
    height: auto !important;
    min-width: 50%;
    width: auto !important;
    max-height: 90%;
  }
}

.separator {
  height: 1px;
  background-color: var(--neutral-200);
  margin: 20px 0;
}

// Para Panel
.footer-buttons {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: 16px 0;
}
</style>
```

## Convenções de Nomenclatura

### Variáveis e Funções

```typescript
// Entidades: PascalCase
const user: User = reactive({...});
const company: Company = reactive({...});

// Services: camelCase com sufixo Service
const userService = useUserService();
const companyService = useCompanyService();

// Funções CRUD: verbo + Entity
function createUser() {}
function updateUser() {}
function deleteUser() {}
function getUser() {}
function viewUser() {}

// Grid refs: grid + Entity
const gridUser = useTemplateRef('gridUser');
const gridCompany = useTemplateRef('gridCompany');

// Estado: sempre 'state'
const state: State = reactive({...});

// Dados auxiliares: plural
const users = ref<User[]>([]);
const companies = ref<Company[]>([]);
```

### Templates e IDs

```vue
<!-- Grid sempre com ref -->
<Grid ref="grid[Entity]" />

<!-- Modais sempre com classe específica -->
<Modal class="[entity]-modal" />

<!-- Teleport sempre para #container -->
<Teleport to="#container">
```

## Checklist de Implementação

### ✅ Estrutura Base
- [ ] Imports necessários
- [ ] Interface State definida
- [ ] Entidade inicial e reativa
- [ ] Services e composables
- [ ] Validação Zod

### ✅ Grid
- [ ] Definição de colunas
- [ ] Header props
- [ ] Eventos configurados
- [ ] Ref definida

### ✅ Modal/Panel/TabsPanel
- [ ] Componente escolhido adequadamente
- [ ] Props configuradas
- [ ] Templates definidos
- [ ] Eventos configurados

### ✅ Funções CRUD
- [ ] view[Entity]
- [ ] create[Entity]
- [ ] update[Entity]
- [ ] delete[Entity]
- [ ] get[Entity]
- [ ] resetFields

### ✅ Validação
- [ ] Schema Zod definido
- [ ] formErrors reativo
- [ ] onValidateErrors implementado

### ✅ Tratamento de Erros
- [ ] Try/catch em todas as funções
- [ ] onException para erros
- [ ] onSuccess para sucessos
- [ ] Loading states

### ✅ Ciclo de Vida
- [ ] onMounted/onBeforeMount
- [ ] Carregamento de dados auxiliares
- [ ] Watchers se necessário

### ✅ Estilos
- [ ] Classe principal definida
- [ ] Responsividade
- [ ] Customizações específicas

### ✅ Traduções
- [ ] Parâmetro [code] sempre em minúsculo na view
- [ ] Parâmetro [code] sempre em minúsculo nos arquivos JSON
- [ ] Traduções criadas nos 3 idiomas (pt-br, en-us, es-es)
- [ ] Se entidade tem propriedade 'code', adicionar traduções em components.lookup.entities
- [ ] Verificar consistência entre view e arquivos JSON

## Regras Críticas de Tradução

### 1. Parâmetro [code] - SEMPRE MINÚSCULO

**PROBLEMA IDENTIFICADO**: O parâmetro `[code]` usado nas views às vezes é criado em maiúsculo, mas nos arquivos JSON de tradução deve SEMPRE ser minúsculo.

**REGRA OBRIGATÓRIA**:
- ✅ **CORRETO**: `cad001`, `cad002`, `pro107`, `sct003`
- ❌ **INCORRETO**: `CAD001`, `CAD002`, `PRO107`, `SCT003`

**Exemplos de uso correto**:
```typescript
// Na view - SEMPRE minúsculo
translate('entities.cad001.code')
translate('errors.cad001.createError')
translate('security.cad001.title')

// Nos arquivos JSON - SEMPRE minúsculo
{
  "entities": {
    "cad001": {
      "code": "Código",
      "name": "Nome"
    }
  },
  "errors": {
    "cad001": {
      "createError": "Erro ao criar usuário"
    }
  }
}
```

### 2. Traduções para Componentes Lookup

**PROBLEMA IDENTIFICADO**: CRUDs que possuem a propriedade `code` precisam de traduções adicionais para os cabeçalhos dos grids nos componentes Lookup.

**REGRA OBRIGATÓRIA**: Para entidades que possuem a propriedade `code`, adicione traduções no arquivo `components.json`:

**Localização**: `src/translations/locales/{idioma}/components.json`

**Estrutura obrigatória**:
```json
{
  "components": {
    "lookup": {
      "entities": {
        "{nomeEntidadeMinusculo}": {
          "code": "Código",
          "name": "Nome",
          "description": "Descrição",
          // ... outros campos da entidade
        }
      }
    }
  }
}
```

**Exemplo prático**:
```json
{
  "components": {
    "lookup": {
      "entities": {
        "user": {
          "code": "Código",
          "name": "Nome do Usuário",
          "email": "Email",
          "isActive": "Usuário Ativo"
        },
        "company": {
          "code": "Código",
          "name": "Nome da Empresa",
          "cnpj": "CNPJ",
          "isActive": "Empresa Ativa"
        }
      }
    }
  }
}
```

**Implementação nos 3 idiomas obrigatórios**:
- `pt-br/components.json`
- `en-us/components.json` 
- `es-es/components.json`

Este guia serve como referência para manter consistência em todos os CRUDs do projeto.
