# Guia CRUD com Panel

Este guia detalha como implementar um CRUD completo utilizando o componente `Panel` para interfaces customizadas com layout específico e controle total sobre header, body e footer.

Caso queira uma referencia de como deve ser a estrutura, veja o arquivo `src/views/private/mypac/occurence-note.vue`.

## Estrutura Base do Template

```vue
<template>
  <div class="[entity-name]">
    <!-- Grid Container -->
    <div class="grid-container" v-show="!state.openModal">
      <Grid
        ref="grid[Entity]"
        :column-defs="grid"
        :template-service="service[Entity].get[Entity]ByCriteria"
        :criteria-service="service[Entity].get[Entity]Criteria"
        :header-props="headerProps"
        :is-loading="service[Entity].loading.value"
        :force-show-grid="state.gridWasOpened"
        :hide-no-content="state.gridWasOpened"
        @double-click="[state.viewMode = 'update', get[Entity]($event)]"
        @update="[state.viewMode = 'update', state.openModal = true, get[Entity]({ data: $event } as any)]"
        @delete="[state.viewMode = 'delete', state.showDeleteModal = true, Object.assign([entity], $event)]"
      ></Grid>
    </div>

    <!-- Panel Container -->
    <div class="panel-container" v-if="state.openModal">
      <Panel
        :open="true"
        :action-button-disabled="state.isLoadingButton"
        :is-enable-delete-button="false"
        :current-mode="state.viewMode"
        :services="{
          create: create[Entity],
          update: update[Entity],
          delete: delete[Entity],
        }"
        @close-panel="handleClosePanel"
        :breadcrumb-main="currentBreadCrumbMain"
        :breadcrumb-current="currentBreadcrumbTitle"
      >
        <!-- REGRA CRÍTICA: [code] deve SEMPRE ser minúsculo (ex: sct003, cad031, pro107) -->
        <!-- ❌ INCORRETO: CAD001, PRO107, SCT003 -->
        <!-- ✅ CORRETO: cad001, pro107, sct003 -->
        <template #header>
          <h2>{{ translate('[module].[code].[entity].details') }}</h2>
        </template>

        <template #body>
          <!-- Conteúdo customizado do formulário -->
        </template>

        <template #footer>
          <!-- Botões customizados no footer -->
        </template>
      </Panel>

      <!-- Modais de Confirmação -->
      <ConfirmationModal
        :open="state.showDeleteModal"
        :title="translate('[module].[code].actions.deleteModalTitle')"
        :message="translate('[module].[code].actions.deleteModalConfirm')"
        :confirm-text="translate('[module].[code].actions.deleteModalConfirmText')"
        :loading="state.isLoadingButton"
        @confirm="delete[Entity]"
        @close="state.showDeleteModal = false; state.openModal = true"
      />

      <!-- Outros modais conforme necessário -->
    </div>
  </div>
</template>
```

## Estrutura do Script Setup

### 1. Imports Necessários

```typescript
import Grid from "../../../components/grid/Grid.vue";
import Panel from "../../../components/modals/Panel.vue";
import ConfirmationModal from "../../../components/modals/ConfirmationModal.vue";

// Componentes específicos
import InfoBox from "../../../components/InfoBox.vue";
import AttachmentField from "../../../components/form/AttachmentField.vue";

// Services
import { use[Entity]Service } from "../../../server/api/[module]/[entity].ts";

// Interfaces e tipos
import { [Entity] } from "../../../interfaces/api/[module]/[Entity].ts";
import { ViewMode } from "../../../interfaces/Generic.ts";
import { GridHeaderProps } from "../../../interfaces/components/Grid.ts";
import { I18nContext } from '../../../plugins/i18n';

// Composables e utilitários
import { useExceptionHandler } from '../../../composables/useExceptionHandler.ts';
import { useCurrencyFormatter } from "../../../composables/useCurrencyFormatter.ts";
import { formatDate } from "../../../utils/helpers/date.ts";
import { z } from 'zod';
```

### 2. Declaração de Variáveis de Estado

```typescript
// Referências de template
const grid[Entity] = ref<InstanceType<typeof Grid> | null>(null);

// Services e composables
const service[Entity] = use[Entity]Service();
const { onException, onSuccess, onValidateErrors } = useExceptionHandler();
const { translate } = inject("i18n") as I18nContext;

// Interface do estado expandida para Panel
interface State {
  openModal: boolean;
  showDeleteModal: boolean;
  showCustomModal: boolean; // Modais adicionais conforme necessário
  isLoadingButton: boolean;
  viewMode: ViewMode;
  gridWasOpened: boolean; // Controle de exibição do grid
  formHasChanges: boolean; // Controle de mudanças no formulário
}

// Estado reativo
const state: State = reactive({
  openModal: false,
  showDeleteModal: false,
  showCustomModal: false,
  isLoadingButton: false,
  viewMode: 'view',
  gridWasOpened: false,
  formHasChanges: false,
});
```

### 3. Entidade e Dados

```typescript
// Estrutura inicial da entidade
const initial[Entity]: [Entity] = {
  code: 0,
  description: '',
  // ... campos específicos da entidade
  status: 0,
  date: null,
  createdAt: null,
  updatedAt: null,
  // ... outros campos
};

// Entidade reativa
const [entity]: [Entity] = reactive({...initial[Entity]});

// Dados auxiliares e opções
const statusOptions = ref<any[]>([]);
const lookupOptions = ref<any[]>([]);
```

### 4. Computed Properties

```typescript
// Controle de visibilidade de botões baseado no estado
const showSaveButton = computed(() => {
  if (state.viewMode === 'create') return true;
  return state.viewMode === 'update' && !isDisabledMode.value && hasFormChanges.value;
});

const showActionButton = computed(() => 
  [entity].status === SpecificStatus.Analysis && state.viewMode === 'update'
);

const isDisabledMode = computed(() => 
  [entity].status === SpecificStatus.Approved || [entity].status === SpecificStatus.Reproved
);

const hasFormChanges = computed(() => state.formHasChanges);

// Breadcrumbs dinâmicos
const currentBreadcrumbTitle = computed(() => 
  translate('[module].[code].[entity].details')
);

const currentBreadCrumbMain = computed(() => {
  if (state.viewMode === 'create') {
    return 'Criando [Entity]';
  } else {
    return `${[entity].entry?.code}`;
  }
});

// Formatação de dados para exibição
const [entity]Date = computed({
  get() {
    return [entity].date ? new Date([entity].date) : null
  },
  set(newDate) {
    [entity].date = newDate
  }
});
```

### 5. Validação com Zod

```typescript
const [entity]Schema = z.object({
  description: z.string()
    .nonempty(translate('errors.[code].validation.description.required')),
  
  responsibleId: z.number({
    required_error: translate('errors.[code].validation.responsible.required'),
    invalid_type_error: translate('errors.[code].validation.responsible.required')
  }).min(1, translate('errors.[code].validation.responsible.min')),
  
  date: z.date({
    required_error: translate('errors.[code].validation.date.required'),
    invalid_type_error: translate('errors.[code].validation.date.required')
  }),
  
  // Validações condicionais
  status: z.number().refine(
    (val) => val >= 0 && val <= 10,
    translate('errors.[code].validation.status.invalid')
  ),
});

const formErrors = reactive<{ [key: string]: string }>({});
```

### 6. Configuração do Grid

```typescript
const grid = computed(() => [
  {
    headerName: translate('[module].[code].grid.code'),
    field: 'code',
    flex: 1,
    sortable: true,
    cellDataType: "number"
  },
  {
    headerName: translate('[module].[code].grid.description'),
    field: 'description', 
    flex: 1,
    sortable: true,
    cellDataType: "text"
  },
  {
    headerName: translate('[module].[code].grid.status'),
    field: 'status',
    flex: 1,
    sortable: true,
    valueFormatter: (status: ValueFormatterParams) => statusMapping[status.value]?.text,
    cellDataType: "text"
  },
  {
    headerName: translate('[module].[code].grid.createdAt'),
    field: 'createdAt',
    flex: 1,
    sortable: true,
    valueFormatter: (date: ValueFormatterParams) => formatDate(date.value) ?? '',
    cellDataType: "date"
  },
]);

const headerProps: GridHeaderProps = reactive({
  newItem: () => view[Entity]()
});
```

### 7. Composables Específicos

```typescript
// Formatação de moeda (se necessário)
const { formattedValue, updateValue } = useCurrencyFormatter(
  () => [entity].financialImpact,
  (_, value) => {
    [entity].financialImpact = value as number;
    if (state.viewMode === 'update') state.formHasChanges = true;
  }
);

// Mapeamento de status
const statusMapping: Record<number, { text: string; color: string }> = {
  0: {
    text: translate('[module].[code].status.new'),
    color: "#FF9F1D",
  },
  1: {
    text: translate('[module].[code].status.inProgress'),
    color: "#447BDA",
  },
  // ... outros status
};
```

## Funções CRUD

### 1. Função de Visualização/Criação

```typescript
function view[Entity]() {
  resetFields();
  [entity].status = DefaultStatus.New;
  state.viewMode = 'create';
  state.openModal = true;
  state.formHasChanges = false;
}
```

### 2. Função de Criação

```typescript
async function create[Entity]() {
  try {
    state.isLoadingButton = true;
    
    // Preparação de dados específicos
    const payload = {
      description: [entity].description || '',
      status: TargetStatus.Analysis,
      date: formatDate(([entity].date ?? new Date()).toString(), true, true),
      // ... outros campos
    };

    // Validação
    const validationResult = [entity]Schema.safeParse(payload);
    if (!onValidateErrors(validationResult, formErrors)) {
      return onException(validationResult.error, translate("errors.[code].validation"));
    }

    // Chamada da API
    const {result, error} = await service[Entity].create[Entity](payload);
    if (error.value) {
      return onException(error.value, translate("errors.[code].create"));
    }
    
    // Atualização do estado
    Object.assign([entity], result.value);
    state.viewMode = "update";
    grid[Entity].value?.createRow(result.value);

    return onSuccess(
      translate("common.messages.successMessages.success"),
      translate("[module].[code].onSuccess.create")
    );
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
    
    // Limpeza de campos não necessários
    const {
      //@ts-ignore
      extraField1,
      //@ts-ignore
      extraField2,
      ...cleanPayload
    } = [entity];

    const payload = {
      ...cleanPayload,
      date: formatDate((cleanPayload.date ?? new Date()).toString(), true, true)
    };

    // Chamada da API
    const {error, result} = await service[Entity].update[Entity](payload.code, payload);

    if (error.value) {
      return onException(error.value, translate("errors.[code].update"));
    }

    // Formatação de resposta se necessário
    //@ts-ignore
    let [entity]UpdateResponse: [Entity] = {...result.value};

    if ([entity]UpdateResponse.updatedAt) {
      [entity]UpdateResponse.updatedAt = formatDate([entity]UpdateResponse.updatedAt.toString(), false, true);
    }

    Object.assign([entity], [entity]UpdateResponse);
    grid[Entity].value?.updateRow([entity]UpdateResponse);
    
    return onSuccess(
      translate("common.messages.successMessages.success"),
      translate("[module].[code].onSuccess.update")
    );
  } finally {
    state.isLoadingButton = false;
  }
}
```

### 4. Função de Exclusão

```typescript
async function delete[Entity]() {
  // Validações de regra de negócio
  if ([entity].status === RestrictedStatus.Completed) {
    onException(
      translate('errors.[code].cannotDeleteCompleted'),
      translate('common.messages.errors.error')
    );
    state.showDeleteModal = false;
    return;
  }

  try {
    state.isLoadingButton = true;
    const {error} = await service[Entity].delete[Entity]([entity].code);

    if (error.value) {
      return onException(error.value, translate("errors.[code].delete"));
    }

    grid[Entity].value?.deleteRow([entity]);
    return onSuccess(
      translate("common.messages.successMessages.success"),
      translate("[module].[code].onSuccess.delete")
    );

  } finally {
    state.showDeleteModal = false;
    state.openModal = false;
    state.isLoadingButton = false;
  }
}
```

### 5. Função de Busca

```typescript
async function get[Entity](event: RowEditingStartedEvent) {
  state.openModal = true;
  state.formHasChanges = false;

  const [entity]EventByClickTable = event.data as [Entity];

  if (!([entity]EventByClickTable.entry || [entity]EventByClickTable.code))
    return onException(translate("errors.[code].get"));

  const {result, error} = await service[Entity].get[Entity]([entity]EventByClickTable.code);

  if (error.value) {
    return onException(error.value, translate("errors.[code].get"));
  }
  
  const data = result.value.data;
  
  // Processamento específico de dados relacionados
  if (data.relatedEntity) {
    [entity].relatedEntityId = data.relatedEntity.code;
    [entity].relatedEntityName = data.relatedEntity.name;
  }

  Object.assign([entity], data);
}
```

### 6. Funções Auxiliares

```typescript
function resetFields() {
  Object.assign([entity], initial[Entity]);
  state.formHasChanges = false;
}

function handleClosePanel() {
  state.openModal = false;
  state.gridWasOpened = true;
  state.formHasChanges = false;
}

// Watcher para detectar mudanças no formulário
watch(
  () => ({
    description: [entity].description,
    status: [entity].status,
    date: [entity].date,
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

## Estrutura do Panel

### Header Customizado

```vue
<template #header>
  <h2>{{ translate('[module].[code].[entity].details') }}</h2>
</template>
```

### Body com InfoBox e Formulário

```vue
<template #body>
  <!-- InfoBox para informações contextuais -->
  <InfoBox
    :items="infoBoxItems"
    :right-items="rightInfoBoxItems"
    @click="toggleCollapse"
  />

  <!-- Formulário principal -->
  <div class="columns">
    <div class="w-4/12">
      <Label>{{ translate('[module].[code].[entity].date') }}</Label>
      <Datepicker
        v-model:selected-date="[entity]Date"
        type="datetime"
        :disabled="isDisabledMode"
      />
    </div>

    <div class="w-4/12">
      <Lookup
        :columnDefs="lookupColumnDefs"
        :service-type="Service.Core"
        v-model:modelValue="[entity].relatedEntityName"
        entity-name="relatedEntity"
        value-field="name"
        :label="translate('[module].[code].[entity].relatedEntity')"
        :placeholder="translate('[module].[code].[entity].relatedEntityPlaceholder')"
        :model-title="translate('[module].[code].[entity].relatedEntity')"
        @onSelect="[entity].relatedEntityId = $event.code"
        :disabled="isDisabledMode"
      />
    </div>

    <div class="w-4/12">
      <Select
        :label="translate('[module].[code].[entity].status.label')"
        v-model="[entity].status"
        :options="statusOptions"
        key-field="label"
        value-field="value"
        :disabled="isDisabledMode"
        :placeholder="translate('[module].[code].[entity].status.placeholder')"
      />
    </div>
  </div>

  <!-- Campos de texto -->
  <div class="columns">
    <div class="w-6/12">
      <Textarea
        :label="translate('[module].[code].[entity].description')"
        :placeholder="translate('[module].[code].[entity].descriptionPlaceholder')"
        v-model="[entity].description"
        :disabled="isDisabledMode"
        class="mb-[0]"
      />
    </div>

    <div class="w-6/12">
      <AttachmentField
        :items="[entity].attachments"
        :label="translate('[module].[code].[entity].attachments')"
        @update:files="[entity].attachments = $event"
        :disabled="isDisabledMode"
      ></AttachmentField>
    </div>
  </div>
</template>
```

### Footer Customizado

```vue
<template #footer>
  <div class="footer-buttons">
    <!-- Botões de ação específicos -->
    <div class="flex gap-2">
      <Button
        v-if="showSpecificActionButton"
        @click="[state.showCustomModal = true]"
      >
        <Icon name="Check" :size="18" color="#11161D" style="margin-right: 6px;"/>
        {{ translate('[module].[code].[entity].actions.approve') }}
      </Button>
    </div>
    
    <!-- Botões padrão -->
    <div class="flex gap-2">
      <Button
        v-if="state.viewMode !== 'create' && !isDisabledMode"
        @click="[state.showDeleteModal = true, Object.assign([entity], [entity])]"
        class="is-danger-light"
      >
        <Icon name="Trash2" :size="18" color="#EA4335" style="margin-right: 6px;"/>
        {{ translate('common.labels.delete') }}
      </Button>
      
      <Button
        v-if="showSaveButton"
        :loading="state.isLoadingButton"
        class="is-primary"
        @click="state.viewMode === 'create' ? create[Entity]() : update[Entity]()"
      >
        <Icon name="Save" :size="18" color="#fff" style="margin-right: 6px;" />
        {{ translate('[module].[code].[entity].actions.save') }}
      </Button>
    </div>
  </div>
</template>
```

### InfoBox Configuration

```typescript
const infoBoxItems = computed(() => [
  {
    isCode: true,
    icon: 'FileDigitIcon' as LucideIconName,
    text: translate('[module].[code].[entity].code') + ': ' + ([entity].code ? [entity].code.toString() : '-'),
    color: '#447BDA',
    textColor: '#447BDA',
  },
  {
    icon: 'CalendarPlus2Icon' as LucideIconName,
    label: translate('[module].[code].[entity].createdAt'),
    text: entryCreatedAt,
    color: '#606B80',
    textColor: '#606B80',
  },
  {
    icon: 'UserPlusIcon' as LucideIconName,
    label: translate('[module].[code].[entity].userCreated'),
    text: [entity].entry?.userCreated || '-',
    color: '#606B80',
    textColor: '#606B80',
  },
]);

const rightInfoBoxItems = computed(() => [
  {
    icon: 'CalendarCheckIcon' as LucideIconName,
    label: translate('[module].[code].[entity].updatedAt'),
    text: entryUpdatedAt,
    color: '#606B80',
    textColor: '#606B80',
  },
  {
    icon: 'UserCheckIcon' as LucideIconName,
    label: translate('[module].[code].[entity].userModified'),
    text: [entity].entry?.userModified || '-',
    color: '#606B80',
    textColor: '#606B80',
  },
]);
```

## Estilos

```scss
<style scoped lang="scss">
.[entity-name] {
  height: 100%;
}

.grid-container {
  height: 100%;
}

.panel-container {
  height: 100%;
}

.footer-buttons {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: 16px 0;
}
</style>
```

## Pontos Importantes

1. **Controle Total**: Panel oferece controle completo sobre header, body e footer
2. **Estado de Grid**: Use `state.gridWasOpened` para controlar exibição do grid
3. **Mudanças no Formulário**: Monitore `state.formHasChanges` para controlar botões
4. **InfoBox**: Use InfoBox para exibir informações contextuais
5. **Validações de Negócio**: Implemente validações específicas antes de operações
6. **Footer Customizado**: Configure botões específicos no footer
7. **Watchers**: Use watchers para detectar mudanças nos campos
8. **Status Mapping**: Crie mapeamentos para status e formatação
9. **Composables**: Use composables específicos como `useCurrencyFormatter`
10. **Breadcrumbs Dinâmicos**: Configure breadcrumbs baseados no estado atual

O Panel é ideal para interfaces que precisam de controle total sobre o layout e comportamento, especialmente quando há necessidade de botões customizados, informações contextuais e validações complexas de regra de negócio.

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
