# Guia CRUD com Modal

Este guia detalha como implementar um CRUD completo utilizando o componente `Modal` para interfaces simples de formulário.

Caso queira uma referencia de como deve ser a estrutura, veja o arquivo `src/views/private/security/windows.vue`.

## Estrutura Base do Template

```vue
<template>
  <div class="page-[entity-name]">
    <!-- Grid Principal -->
    <Grid
      ref="grid[Entity]"
      :column-defs="colsDefs"
      :service="[entity]Service.get[Entities]"
      :template-service="[entity]Service.get[Entities]ByCriteria"
      :criteria-service="[entity]Service.get[Entity]Criteria"
      :header-props="headerProps"
      :loading="[entity]Service.loading.value"
      @double-click="[state.viewMode = 'update', get[Entity]($event.data)]"
      @update="[state.viewMode = 'update', state.openModal = true, get[Entity]($event)]"
      @delete="[state.viewMode = 'delete', state.showDeleteModal = true, Object.assign([entity], $event)]"
    ></Grid>

    <!-- Modal Principal -->
    <Teleport to="#container">
      <Modal
        class="[entity]-modal"
        :open="state.openModal"
        :viewMode="state.viewMode"
        :service="{
          create: create[Entity],
          update: update[Entity]
        }"
        :is-disabled-button="state.isLoadingButton"
        @save-info="saveInfo"
        @close-modal="state.openModal = false"
      >
        <template #header>
          {{ $translate('[module].[code].modalTitle') }}
        </template>

        <!-- REGRA CRÍTICA: [code] deve SEMPRE ser minúsculo (ex: sct003, cad031, pro107) -->
        <!-- ❌ INCORRETO: CAD001, PRO107, SCT003 -->
        <!-- ✅ CORRETO: cad001, pro107, sct003 -->

        <template #body>
          <div class="flex flex-col gap-[20px]">
            <!-- Campos do formulário -->
          </div>
        </template>
      </Modal>

      <!-- Modal de Confirmação de Exclusão -->
      <ConfirmationModal
        :open="state.showDeleteModal"
        :loading="state.isLoadingButton"
        @confirm="delete[Entity]"
        @close="state.showDeleteModal = false;"
      />
    </Teleport>
  </div>
</template>
```

## Estrutura do Script Setup

### 1. Imports Necessários

```typescript
import Grid from '../../../components/grid/Grid.vue';
import Modal from '../../../components/modals/Modal.vue';
import ConfirmationModal from '../../../components/modals/ConfirmationModal.vue';

// Services
import { use[Entity]Service } from '../../../server/api/[module]/[entity]';

// Interfaces e tipos
import { [Entity] } from '../../../interfaces/api/[module]/[Entity]';
import { ViewMode } from '../../../interfaces/Generic';
import { GridHeaderProps } from '../../../interfaces/components/Grid';
import { I18nContext } from '../../../plugins/i18n';

// Composables e utilitários
import { useExceptionHandler } from '../../../composables/useExceptionHandler';
import { z } from 'zod';
```

### 2. Declaração de Variáveis de Estado

```typescript
// Referências de template
const grid[Entity] = useTemplateRef('grid[Entity]');

// Services e composables
const [entity]Service = use[Entity]Service();
const { onException, onSuccess, onValidateErrors } = useExceptionHandler();
const { translate } = inject("i18n") as I18nContext;

// Interface do estado
interface State {
  openModal: boolean;
  showDeleteModal: boolean;
  isLoadingButton: boolean;
  viewMode: ViewMode;
}

// Estado reativo
const state: State = reactive({
  openModal: false,
  showDeleteModal: false,
  isLoadingButton: false,
  viewMode: 'view',
});
```

### 3. Entidade e Dados

```typescript
// Estrutura inicial da entidade
const initial[Entity]: [Entity] = reactive({
  code: 0,
  name: '',
  description: '',
  // ... outros campos da entidade
});

// Entidade reativa
const [entity]: [Entity] = reactive({ ...initial[Entity] });

// Dados auxiliares para selects/lookups
const dadosAuxiliares = ref<TipoAuxiliar[]>([]);
```

### 4. Validação com Zod

```typescript
const [entity]Schema = z.object({
  // Campos de texto obrigatórios
  name: z.string()
    .max(40, translate('errors.[code].validation.name.maxLength'))
    .nonempty(translate('errors.[code].validation.name.required')),

  // REGRA CRÍTICA: [code] SEMPRE minúsculo nas traduções
  // ❌ INCORRETO: CAD001, PRO107, SCT003
  // ✅ CORRETO: cad001, pro107, sct003

  description: z.string()
    .max(100, translate('errors.[code].validation.description.maxLength'))
    .nonempty(translate('errors.[code].validation.description.required')),

  // Campos de seleção obrigatórios
  categoryId: z.string()
    .nonempty(translate('errors.[code].validation.categoryId.required')),

  // Campos booleanos
  active: z.boolean({
    required_error: translate('errors.[code].validation.isActive.required'),
    invalid_type_error: translate('errors.[code].validation.isActive.required'),
  }),

  // Campos opcionais
  observations: z.string().optional(),
});

// Objeto para armazenar erros de validação
const formErrors = reactive<{ [key: string]: string }>({});
```

### 5. Configuração do Grid

```typescript
const colsDefs = computed(() => [
  {
    headerName: translate('entities.[code].code'),
    field: "code",
    flex: 1,
    sortable: true,
    cellDataType: "number"
  },
  {
    headerName: translate('entities.[code].name'),
    field: "name",
    flex: 1,
    sortable: true,
    cellDataType: "text"
  },
  {
    headerName: translate('entities.[code].description'),
    field: "description",
    flex: 1,
    sortable: true,
    cellDataType: "text"
  },
  {
    headerName: translate('entities.[code].active'),
    field: "active",
    flex: 1,
    sortable: true,
    cellDataType: "boolean"
  },
]);

// REGRA CRÍTICA: [code] deve SEMPRE ser minúsculo (ex: sct003, cad031, pro107)
// ❌ INCORRETO: CAD001, PRO107, SCT003
// ✅ CORRETO: cad001, pro107, sct003

const headerProps: GridHeaderProps = reactive({
  newItem: view[Entity]
});
```

### 6. Ciclo de Vida

```typescript
onMounted(async () => {
  await getDadosAuxiliares();
});
```

## Funções CRUD

### 1. Função de Visualização/Criação

```typescript
function view[Entity]() {
  resetFields();
  state.viewMode = 'create';
  state.openModal = true;
}
```

### 2. Função de Criação

```typescript
async function create[Entity]() {
  try {
    state.isLoadingButton = true;

    // Remove campos não necessários para criação
    const { code, ...payload } = [entity];

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

    // Atualização do grid e fechamento do modal
    grid[Entity].value?.createRow(result.value);
    state.openModal = false;

    return onSuccess(translate('errors.success'), translate('errors.[code].createSuccess'));

  } finally {
    state.isLoadingButton = false;
  }
}
```

### 3. Função de Atualização

```typescript
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

    // Atualização do grid e fechamento do modal
    grid[Entity].value?.updateRow(result.value);
    state.openModal = false;

    return onSuccess(translate('errors.success'), translate('errors.[code].updateSuccess'));

  } finally {
    state.isLoadingButton = false;
  }
}
```

### 4. Função de Exclusão

```typescript
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
    state.isLoadingButton = false;
  }
}
```

### 5. Função de Busca

```typescript
async function get[Entity]([entity]EventByClickTable: [Entity]) {
  try {
    state.openModal = true;
    state.isLoadingButton = true;

    const { result, error } = await [entity]Service.get[Entity]([entity]EventByClickTable.code);

    if (error.value) {
      return onException(error.value, translate('errors.[code].get[Entity]Error'));
    }

    Object.assign([entity], result.value.data);

  } finally {
    state.isLoadingButton = false;
  }
}
```

### 6. Funções Auxiliares

```typescript
// Carregamento de dados auxiliares
async function getDadosAuxiliares() {
  try {
    const { result, error } = await auxiliarService.getDados();

    if (error.value) {
      return onException(error.value, translate('errors.[code].getDadosError'));
    }

    dadosAuxiliares.value = result.value.data;
  } finally { }
}

// Reset de campos
function resetFields() {
  Object.assign([entity], initial[Entity]);
  Object.keys(formErrors).forEach(key => formErrors[key] = '');
}

// Função de save info
const saveInfo = () => state.viewMode === 'create' ? create[Entity]() : update[Entity]();
```

## Estrutura do Formulário no Modal

### Formulário Básico

```vue
<template #body>
  <div class="flex flex-col gap-[20px]">
    <div class="columns">
      <div class="column">
        <FormControl
          :label="$translate('[module].[code].fields.code.label')"
          <!-- REGRA CRÍTICA: [code] SEMPRE minúsculo -->
          v-model="[entity].code"
          disabled
        ></FormControl>
      </div>
    </div>

    <!-- Campos principais -->
    <div class="columns">
      <div class="column">
        <FormControl
          :label="$translate('[module].[code].fields.name.label')"
          :placeholder="$translate('[module].[code].fields.name.placeholder')"
          v-model="[entity].name"
          :disabled="state.viewMode === 'view'"
          :class="{ error: formErrors.name }"
          :help-text="formErrors.name"
          maxlength="40"
          required
        ></FormControl>
      </div>

      <div class="column">
        <FormControl
          :label="$translate('[module].[code].fields.description.label')"
          :placeholder="$translate('[module].[code].fields.description.placeholder')"
          v-model="[entity].description"
          :disabled="state.viewMode === 'view'"
          :class="{ error: formErrors.description }"
          :help-text="formErrors.description"
          maxlength="100"
          required
        ></FormControl>
      </div>
    </div>

    <!-- Select/Dropdown -->
    <div class="columns">
      <div class="column">
        <Select
          v-model="[entity].categoryId"
          :options="categorias"
          :label="$translate('[module].[code].fields.categoryId.label')"
          :placeholder="$translate('[module].[code].fields.categoryId.placeholder')"
          value-field="code"
          key-field="name"
          :searchable="true"
          :disabled="state.viewMode === 'view'"
          :class="{ error: formErrors.categoryId }"
          :help-text="formErrors.categoryId"
          required
        ></Select>
      </div>
    </div>

    <!-- Checkbox -->
    <div class="columns">
      <div class="column">
        <Checkbox
          v-model="[entity].active"
          :description="$translate('[module].[code].fields.active.label')"
          :disabled="state.viewMode === 'view'"
        ></Checkbox>
      </div>
    </div>

    <!-- Campo de data -->
    <div class="columns">
      <div class="column">
        <Datepicker
          v-model:selected-date="[entity].validUntil"
          :label="$translate('[module].[code].fields.validUntil.label')"
          type="date"
          :disabled="state.viewMode === 'view'"
          :class="{ error: formErrors.validUntil }"
          :help-text="formErrors.validUntil"
          required
        ></Datepicker>
      </div>
    </div>
  </div>
</template>
```

### Formulário com Máscaras

```vue
<!-- Campo com máscara -->
<div class="column">
  <FormControl
    v-model="[entity].telefone"
    v-mask="'(##) #####-####'"
    :label="$translate('[module].[code].fields.telefone.label')"
    :placeholder="$translate('[module].[code].fields.telefone.placeholder')"
    :class="{ error: formErrors.telefone }"
    :help-text="formErrors.telefone"
    required
  ></FormControl>
</div>

<!-- Campo numérico -->
<div class="column">
  <FormControl
    v-model="[entity].quantidade"
    type="number"
    :label="$translate('[module].[code].fields.quantidade.label')"
    :placeholder="$translate('[module].[code].fields.quantidade.placeholder')"
    :class="{ error: formErrors.quantidade }"
    :help-text="formErrors.quantidade"
    required
  ></FormControl>
</div>
```

## Estilos

```scss
<style scoped lang="scss">
.page-[entity-name] {
  height: 100%;
}

.[entity]-modal {
  ::v-deep(.modal-card) {
    height: auto !important;
    min-width: 50%;
    width: auto !important;
    max-height: 90%;
  }
}
</style>
```

## Pontos Importantes

1. **Simplicidade**: Modal é ideal para formulários simples com poucos campos
2. **ViewMode**: Use `state.viewMode` para controlar se campos estão desabilitados
3. **Validação**: Sempre valide antes de salvar usando Zod
4. **Loading States**: Use `state.isLoadingButton` para feedback visual
5. **Teleport**: Use `Teleport to="#container"` para renderizar modais no local correto
6. **Reset**: Sempre resete os campos ao abrir para criação
7. **Error Handling**: Use `useExceptionHandler` para tratamento consistente de erros
8. **Grid Integration**: Use `grid[Entity].value?.createRow/updateRow/deleteRow` para atualizar o grid
9. **Modal Closing**: Feche o modal após operações bem-sucedidas
10. **Service Integration**: Configure o objeto `:service` com as funções de create/update

## Exemplo Completo de Uso

```typescript
// Exemplo de como usar com uma entidade "Category"
const initialCategory: Category = reactive({
  code: 0,
  name: '',
  description: '',
  active: true,
});

const categorySchema = z.object({
  name: z.string()
    .max(40, translate('errors.category.validation.name.maxLength'))
    .nonempty(translate('errors.category.validation.name.required')),
  description: z.string()
    .max(100, translate('errors.category.validation.description.maxLength'))
    .nonempty(translate('errors.category.validation.description.required')),
  active: z.boolean({
    required_error: translate('errors.[code].validation.isActive.required'),
    invalid_type_error: translate('errors.[code].validation.isActive.required'),
  }),
});
```

Este padrão é ideal para CRUDs simples onde não há necessidade de múltiplas abas ou interfaces complexas.

## Traduções Obrigatórias para Lookup

**IMPORTANTE**: Se a entidade possui a propriedade `code`, você DEVE adicionar traduções para os cabeçalhos dos grids nos componentes Lookup.

### Localização dos Arquivos
- `src/translations/locales/pt-br/components.json`
- `src/translations/locales/en-us/components.json`
- `src/translations/locales/es-es/components.json`

### Estrutura Obrigatória
```json
{
  "components": {
    "lookup": {
      "entities": {
        "{nomeEntidadeMinusculo}": {
          "code": "Código",
          "name": "Nome",
          "description": "Descrição"
        }
      }
    }
  }
}
```

### Exemplo Prático
Para uma entidade `User` com campos `code`, `name`, `email`:

**pt-br/components.json**:
```json
{
  "components": {
    "lookup": {
      "entities": {
        "user": {
          "code": "Código",
          "name": "Nome do Usuário",
          "email": "Email"
        }
      }
    }
  }
}
```

**en-us/components.json**:
```json
{
  "components": {
    "lookup": {
      "entities": {
        "user": {
          "code": "Code",
          "name": "User Name",
          "email": "Email"
        }
      }
    }
  }
}
```

**es-es/components.json**:
```json
{
  "components": {
    "lookup": {
      "entities": {
        "user": {
          "code": "Código",
          "name": "Nombre de Usuario",
          "email": "Correo"
        }
      }
    }
  }
}
```
