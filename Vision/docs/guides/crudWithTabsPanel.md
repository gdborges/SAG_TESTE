# Guia CRUD com TabsPanel

Este guia detalha como implementar um CRUD completo utilizando o componente `TabsPanel` para interfaces complexas com múltiplas abas.

**IMPORTANTE:** 
Quando vamos implementar um CRUD com TabsPanel, devemos ter em mente que a estrutura de pastas deve ser a seguinte:

**Todos arquivos dentro da pasta view devem estar no padrão kebab-case**

**Estrutura correta:**
```
src/views/private/[module]/[entity-name]/  
├── [entity-name].vue                # Tela principal
├── [tab1].vue                  # Aba 1
├── [tab2].vue                  # Aba 2

src/views/private/[module]/tests/[entity-name].spec.ts
```

**Estrutura errada:**
```
src/views/private/[module]/  
├── [entity-name].vue                # Tela principal
├── [entity-name]/tests/[entity-name].spec.ts
├── components/[tab1].vue                  # Aba 1
├── components/[tab2].vue                  # Aba 2
```

Caso queira uma referencia de como deve ser a estrutura, veja o arquivo `src/views/private/mypac/non-compliance/`.


## Estrutura Base do Template

```vue
<template>
  <div class="page-[entity-name]">
    <!-- Grid Principal -->
    <Grid 
      v-show="!state.openModal"
      ref="grid[EntityName]"
      :column-defs="colsDefs"
      :service="[entity]Service.get[Entities]"
      :template-service="[entity]Service.get[Entities]ByCriteria"
      :criteria-service="[entity]Service.get[Entity]Criteria"
      :header-props="headerProps"
      :loading="[entity]Service.loading.value"
      @double-click="[state.viewMode = 'update', get[Entity]($event.data)]"
      @create="[state.viewMode = 'create', state.openModal = true]"
      @update="[state.viewMode = 'update', get[Entity]($event)]"
      @delete="[state.viewMode = 'delete', state.showDeleteModal = true, Object.assign([entity], $event)]"
    ></Grid>

    <!-- TabsPanel Modal -->
    <!-- REGRA CRÍTICA: [code] deve SEMPRE ser minúsculo (ex: sct003, cad031, pro107) -->
    <!-- ❌ INCORRETO: CAD001, PRO107, SCT003 -->
    <!-- ✅ CORRETO: cad001, pro107, sct003 -->
    <TabsPanel
      v-show="state.openModal"
      :title="$translate('[module].[code].title')"
      :open="state.openModal"
      :config-actions="modalTabsConfig"
      :is-enable-delete-button="state.tabIndex === 0 && state.viewMode !== 'create'"
      :is-loading-button="state.isLoadingButton"
      v-model:tab-index="state.tabIndex"
      v-model:show-delete-modal="state.showDeleteModal"
      :breadcrumb-main="$translate('routes.[module].[code].translatedName')"
      :breadcrumb-current="$translate('[module].[code].title')"
      @save-info="saveInfo"
      @close-panel="[state.openModal = false, state.tabIndex = 0]"
      @delete="delete[Entity]"
    >
      <!-- Aba 0: Detalhes -->
      <div v-if="state.tabIndex == 0">
        <!-- Conteúdo da aba principal -->
      </div>

      <!-- Aba 1: Segunda aba -->
      <div v-else-if="state.tabIndex == 1">
        <!-- Componente da segunda aba -->
      </div>

      <!-- Abas adicionais conforme necessário -->
    </TabsPanel>

    <!-- Modal de Confirmação de Exclusão -->
    <Teleport to="#container">
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
import Grid from '../../../../components/grid/Grid.vue';
import TabsPanel from '../../../../components/modals/TabsPanel.vue';
import ConfirmationModal from '../../../../components/modals/ConfirmationModal.vue';

// Componentes das abas
import ComponenteAba1 from './componente-aba1.vue';
import ComponenteAba2 from './componente-aba2.vue';

// Services
import { use[Entity]Service } from '../../../../server/api/[module]/[entity]';

// Interfaces e tipos
import { [Entity] } from '../../../../interfaces/api/[module]/[Entity]';
import { ViewMode } from '../../../../interfaces/Generic';
import { GridHeaderProps } from '../../../../interfaces/components/Grid';
import { TabsPanelConfigActions } from '../../../../interfaces/components/TabsPanel';
import { I18nContext } from '../../../../plugins/i18n';

// Composables e utilitários
import { useExceptionHandler } from '../../../../composables/useExceptionHandler';
import { z } from 'zod';
```

### 2. Declaração de Variáveis de Estado

```typescript
// Referências de template
const grid[Entity] = useTemplateRef('grid[Entity]');
const componenteAba1 = useTemplateRef('componenteAba1');
const componenteAba2 = useTemplateRef('componenteAba2');

// Services e composables
const [entity]Service = use[Entity]Service();
const { onException, onSuccess, onValidateErrors } = useExceptionHandler();
const { translate } = inject("i18n") as I18nContext;

// Interface do estado
interface State {
  openModal: boolean;
  showDeleteModal: boolean;
  isLoadingButton: boolean;
  tabIndex: number;
  viewMode: ViewMode;
}

// Estado reativo
const state: State = reactive({
  openModal: false,
  showDeleteModal: false,
  isLoadingButton: false,
  tabIndex: 0,
  viewMode: 'view',
});
```

### 3. Entidade e Dados

```typescript
// Estrutura inicial da entidade
const initial[Entity]: [Entity] = {
  code: 0,
  // ... outros campos da entidade
};

// Entidade reativa
const [entity]: [Entity] = reactive({ ...initial[Entity] });

// Dados auxiliares (se necessário)
const dadosAuxiliares = ref<TipoAuxiliar[]>([]);
```

### 4. Configuração das Abas

```typescript
const modalTabsConfig = computed((): TabsPanelConfigActions[] => {
  return [
    {
      tabTitle: translate('[module].[code].tabs.details.title'),
      buttonsActions: [
        {
          label: translate('[module].[code].tabs.details.actionButton'),
          class: `is-primary ${state.isLoadingButton ? 'is-loading' : ''}`,
          callback: state.viewMode === 'create' ? create[Entity] : update[Entity]
        },
      ],
    },
    {
      tabTitle: translate('[module].[code].tabs.segunda.title'),
      disabled: state.viewMode === 'create',
      buttonsActions: [
        {
          label: translate('[module].[code].tabs.segunda.actionButton'),
          class: `is-primary`,
          callback: componenteAba1.value ? componenteAba1.value.metodoAba : () => true
        },
      ]
    },
    // ... outras abas
  ];
});
```

### 5. Validação com Zod

```typescript
const [entity]Schema = z.object({
  // Campos obrigatórios
  name: z.string()
    .nonempty(translate('errors.[code].validation.name.required'))
    .max(100, translate('errors.[code].validation.name.maxLength')),
  
  // REGRA CRÍTICA: [code] SEMPRE minúsculo nas traduções
  // ❌ INCORRETO: CAD001, PRO107, SCT003
  // ✅ CORRETO: cad001, pro107, sct003
  
  // Campos numéricos
  code: z.number({
    required_error: translate('errors.[code].validation.code.required'),
    invalid_type_error: translate('errors.[code].validation.code.required')
  }).min(1, translate('errors.[code].validation.code.min')),
  
  // Campos de data
  dueDate: z.string({
    required_error: translate('errors.[code].validation.dueDate.required'),
    invalid_type_error: translate('errors.[code].validation.dueDate.required')
  }),
  
  // Campos opcionais
  observation: z.string().optional(),
  
  // Campos booleanos
  active: z.boolean({
    required_error: translate('errors.[code].validation.isActive.required'),
    invalid_type_error: translate('errors.[code].validation.isActive.required'),
  }),
});

// Objeto para armazenar erros de validação
const formErrors = reactive<{ [key: string]: string }>({});
```

### 6. Configuração do Grid

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
  // ... outras colunas
]);

// REGRA CRÍTICA: [code] deve SEMPRE ser minúsculo (ex: sct003, cad031, pro107)
// ❌ INCORRETO: CAD001, PRO107, SCT003
// ✅ CORRETO: cad001, pro107, sct003

const headerProps: GridHeaderProps = reactive({
  newItem: view[Entity]
});
```

### 7. Ciclo de Vida

```typescript
onBeforeMount(async () => {
  await Promise.allSettled([
    getDadosAuxiliares()
  ]);
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

    // Validação
    const validationResult = [entity]Schema.safeParse([entity]);
    if (!onValidateErrors(validationResult, formErrors)) {
      return onException(validationResult.error, translate('errors.validationError'));
    }

    // Chamada da API
    const { result, error } = await [entity]Service.create[Entity]([entity]);
    if (error.value) {
      return onException(error.value, translate('errors.[code].createError'));
    }

    // Atualização do grid e estado
    grid[Entity].value?.createRow(result.value);
    state.viewMode = 'update';
    Object.assign([entity], result.value);
    
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
    
    // Atualização do grid
    grid[Entity].value?.updateRow(result.value);
    Object.assign([entity], result.value);
    
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
    state.openModal = false;
    state.isLoadingButton = false;
  }
}
```

### 5. Função de Busca

```typescript
async function get[Entity](event: any) {
  try {
    const [entity]EventByClickTable = event.data as [Entity];
    const { result, error } = await [entity]Service.get[Entity]([entity]EventByClickTable.code);

    if (!error.value) {
      Object.assign([entity], result.value.data);
    }

  } finally {
    state.openModal = true;
  }
}
```

### 6. Função de Reset

```typescript
function resetFields() {
  Object.assign([entity], initial[Entity]);
  Object.keys(formErrors).forEach(key => formErrors[key] = '');
}
```

### 7. Função de Save Info

```typescript
const saveInfo = () => state.viewMode === 'create' ? create[Entity]() : update[Entity]();
```

## Estrutura das Abas

### Aba Principal (Detalhes)

```vue
<div v-if="state.tabIndex == 0">
  <div class="flex flex-col gap-[20px]">
    <h4>{{ translate('[module].[code].infos') }}</h4>

    <div class="columns">
      <div class="column">
        <FormControl 
          v-model="[entity].campo1" 
          :label="translate('[module].[code].tabs.details.fields.campo1.label')" 
          :placeholder="translate('[module].[code].tabs.details.fields.campo1.placeholder')" 
          :class="{ error: formErrors.campo1 }"
          :help-text="formErrors.campo1"
          maxlength="40"
          required
        ></FormControl>
      </div>

      <div class="column">
        <Select
          v-model="[entity].campo2"
          :label="translate('[module].[code].tabs.details.fields.campo2.label')"
          :placeholder="translate('[module].[code].tabs.details.fields.campo2.placeholder')"
          :options="opcoes"
          key-field="name"
          value-field="value"
          :class="{ error: formErrors.campo2 }"
          :help-text="formErrors.campo2"
          required
        ></Select>
      </div>
    </div>

    <!-- Separador -->
    <div class="separator"></div>

    <!-- Seções adicionais -->
  </div>
</div>
```

### Abas Secundárias

```vue
<div v-else-if="state.tabIndex == 1">
  <ComponenteAba1 ref="componenteAba1" :[entity]-code="[entity].code" />
</div>

<div v-else-if="state.tabIndex == 2">
  <ComponenteAba2 ref="componenteAba2" :[entity]-code="[entity].code" />
</div>
```

## Estilos

```scss
<style scoped lang="scss">
.page-[entity-name] {
  height: 100%;
}

.separator {
  height: 1px;
  background-color: var(--neutral-200);
  margin: 20px 0;
}
</style>
```

## Pontos Importantes

1. **Controle de Estado**: Use `state.tabIndex` para controlar qual aba está ativa
2. **Validação**: Sempre valide antes de salvar usando Zod
3. **Loading States**: Use `state.isLoadingButton` para feedback visual
4. **Refs de Template**: Use `useTemplateRef` para acessar componentes filhos
5. **Breadcrumbs**: Configure breadcrumbs dinâmicos baseados no estado
6. **Botões por Aba**: Configure botões específicos para cada aba via `modalTabsConfig`
7. **Desabilitar Abas**: Use `disabled: state.viewMode === 'create'` para abas que só funcionam em modo de edição
8. **Callbacks**: Use callbacks nas configurações das abas para executar ações específicas
9. **Reset**: Sempre resete os campos ao abrir para criação
10. **Error Handling**: Use `useExceptionHandler` para tratamento consistente de erros

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
