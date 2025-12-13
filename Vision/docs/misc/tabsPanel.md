# TabsPanel.vue - Documentação Completa

## Visão Geral

O componente `TabsPanel.vue` é um painel lateral com sistema de abas e sub-abas, ideal para formulários complexos com múltiplas seções. Oferece navegação hierárquica, atalhos de teclado e configuração dinâmica de abas.

## Características Principais

- **Sidebar**: Navegação por abas com possibilidade de minimizar
- **Sub-abas**: Sistema hierárquico de navegação
- **Atalhos de Teclado**: Ctrl+↑/↓ para navegar entre abas, Ctrl+S para salvar
- **Configuração Dinâmica**: Abas configuráveis via props
- **Botões Contextuais**: Diferentes botões para cada aba
- **Checkpoint System**: Salvamento de estado entre navegações

## Props

### `open` (obrigatório)
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Controla se o painel está visível

```vue
<TabsPanel :open="state.openModal" />
```

### `title` (obrigatório)
- **Tipo**: `string`
- **Descrição**: Título do painel

```vue
<TabsPanel title="Gerenciar Usuário" />
```

### `configActions` (obrigatório)
- **Tipo**: `TabsPanelConfigActions[]`
- **Descrição**: Configuração das abas do painel

```vue
<TabsPanel :config-actions="tabsConfig" />
```

### `tabIndex`
- **Tipo**: `number`
- **Padrão**: `0`
- **Descrição**: Índice da aba selecionada (suporta v-model)

```vue
<TabsPanel v-model:tab-index="state.tabIndex" />
```

### `isEnableDeleteButton`
- **Tipo**: `boolean`
- **Padrão**: `true`
- **Descrição**: Controla se o botão de deletar está habilitado

```vue
<TabsPanel :is-enable-delete-button="false" />
```

### `isLoadingButton`
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Controla se o botão está em estado de loading

```vue
<TabsPanel :is-loading-button="state.isLoading" />
```

### `showBackButton`
- **Tipo**: `boolean`
- **Padrão**: `true`
- **Descrição**: Mostra o botão de voltar

```vue
<TabsPanel :show-back-button="false" />
```

### `breadcrumbMain`
- **Tipo**: `string`
- **Descrição**: Texto principal do breadcrumb

```vue
<TabsPanel breadcrumb-main="Usuários" />
```

### `breadcrumbCurrent`
- **Tipo**: `string`
- **Descrição**: Texto atual do breadcrumb

```vue
<TabsPanel breadcrumb-current="Detalhes" />
```

### `hasSubtabNavigationButtons`
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Determina se os botões de navegação entre subtabs serão exibidos

```vue
<TabsPanel :has-subtab-navigation-buttons="true" />
```

### `subtabIndex`
- **Tipo**: `number`
- **Padrão**: `0`
- **Descrição**: Índice da sub-aba selecionada

```vue
<TabsPanel :subtab-index="state.subtabIndex" />
```

## Interface TabsPanelConfigActions

```typescript
interface TabsPanelConfigActions {
  // Título da aba
  tabTitle: string;
  
  // Desabilita a aba
  disabled?: boolean;
  
  // Oculta a aba
  hidden?: boolean;
  
  // Botões principais da aba
  buttonsActions?: {
    label: string | VNode;
    class?: string;
    callback: VoidFunction;
    disabled?: boolean;
    icon?: IconProps;
  }[];
  
  // Botões à esquerda
  leftButtons?: {
    label: string | VNode;
    class?: string;
    callback: VoidFunction;
    disabled?: boolean;
    icon?: IconProps;
  }[];
  
  // Sub-abas
  subTabs?: SubTab[];
  
  // Callbacks de navegação
  onNextSubtab?: (currentIndex: number, nextIndex: number) => boolean | Promise<boolean>;
  onPreviousSubtab?: (currentIndex: number, previousIndex: number) => boolean | Promise<boolean>;
  saveCheckpoint?: (currentIndex: number) => boolean | Promise<boolean>;
  
  // Título do header na aba
  headerTitleOnTab?: string;
}
```

## Interface SubTab

```typescript
interface SubTab {
  id: number;
  title: string;
  icon?: {
    name: LucideIconName;
    color: string;
    size?: number;
  };
  code: number;
}
```

## Eventos

### `close-panel`
Emitido ao fechar o painel

```vue
<TabsPanel @close-panel="handleClose" />
```

### `tab-click`
Emitido ao clicar em uma aba

```vue
<TabsPanel @tab-click="handleTabClick" />
```

### `sub-tab-click`
Emitido ao clicar em uma sub-aba

```vue
<TabsPanel @sub-tab-click="handleSubTabClick" />
```

### `delete`
Emitido ao clicar no botão de deletar

```vue
<TabsPanel @delete="handleDelete" />
```

### `update:tabIndex`
Emitido ao atualizar o índice da aba (para v-model)

```vue
<TabsPanel @update:tab-index="state.tabIndex = $event" />
```

### `save-info`
Emitido ao usar o atalho Ctrl+S

```vue
<TabsPanel @save-info="handleSave" />
```

## Atalhos de Teclado

- **Ctrl+S**: Emite evento `save-info`
- **Ctrl+D**: Fecha o painel
- **Ctrl+↓**: Navega para próxima aba
- **Ctrl+↑**: Navega para aba anterior

## Exemplo Completo

```vue
<template>
  <TabsPanel
    v-show="state.openModal"
    title="Gerenciar Não Conformidade"
    :open="state.openModal"
    :config-actions="modalTabsConfig"
    :is-enable-delete-button="state.viewMode !== 'create'"
    :is-loading-button="state.isLoadingButton"
    v-model:tab-index="state.tabIndex"
    :breadcrumb-main="currentBreadcrumbMain"
    :breadcrumb-current="currentBreadcrumbCurrent"
    @save-info="saveInfo"
    @close-panel="handleClosePanel"
    @delete="deleteItem"
  >
    <!-- Conteúdo da primeira aba -->
    <div v-if="state.tabIndex === 0">
      <Details :item="item" :form-errors="formErrors" />
    </div>

    <!-- Conteúdo da segunda aba -->
    <div v-else-if="state.tabIndex === 1">
      <ActionPlan :item="item" />
    </div>

    <!-- Conteúdo da terceira aba -->
    <div v-else-if="state.tabIndex === 2">
      <Attachments :item="item" />
    </div>
  </TabsPanel>
</template>

<script setup lang="ts">
import { TabsPanelConfigActions } from '../../interfaces/components/TabsPanel';
import { LucideIconName } from '../../interfaces/components/Icon';

interface State {
  openModal: boolean;
  tabIndex: number;
  isLoadingButton: boolean;
  viewMode: 'create' | 'update' | 'view';
}

const state = reactive<State>({
  openModal: false,
  tabIndex: 0,
  isLoadingButton: false,
  viewMode: 'view'
});

const item = reactive({
  id: '',
  description: '',
  status: 0
});

const currentBreadcrumbMain = computed(() => {
  if (state.viewMode === 'create') {
    return 'Criando Item';
  } else {
    return `Item ${item.id}`;
  }
});

const currentBreadcrumbCurrent = computed(() => {
  switch (state.tabIndex) {
    case 0: return 'Detalhes';
    case 1: return 'Plano de Ação';
    case 2: return 'Anexos';
    default: return 'Detalhes';
  }
});

const modalTabsConfig = computed((): TabsPanelConfigActions[] => [
  {
    tabTitle: 'Detalhes',
    buttonsActions: [
      ...(state.viewMode !== 'create' ? [{
        label: 'Deletar',
        class: 'is-danger-light',
        icon: { name: 'Trash2' as LucideIconName, size: 18, color: '#EA4335' },
        callback: deleteItem,
      }] : []),
      {
        label: 'Salvar',
        class: `is-primary ${state.isLoadingButton ? 'is-loading' : ''}`,
        icon: { name: 'Save' as LucideIconName, size: 18, color: '#fff' },
        callback: saveItem,
      },
    ],
  },
  {
    tabTitle: 'Plano de Ação',
    disabled: state.viewMode === 'create',
    buttonsActions: [
      {
        label: 'Salvar Plano',
        class: 'is-primary',
        callback: saveActionPlan,
      },
    ],
  },
  {
    tabTitle: 'Anexos',
    disabled: state.viewMode === 'create',
    leftButtons: [
      {
        label: 'Upload',
        class: 'is-info',
        icon: { name: 'Upload' as LucideIconName, size: 18 },
        callback: uploadFile,
      },
    ],
  },
]);

function handleClosePanel() {
  state.openModal = false;
  state.tabIndex = 0;
}

function saveInfo() {
  if (state.viewMode === 'create') {
    createItem();
  } else {
    updateItem();
  }
}

async function createItem() {
  state.isLoadingButton = true;
  try {
    // Lógica de criação
    await itemService.create(item);
    state.tabIndex = 1; // Mover para próxima aba após criar
    state.viewMode = 'update';
  } finally {
    state.isLoadingButton = false;
  }
}

async function updateItem() {
  state.isLoadingButton = true;
  try {
    // Lógica de atualização
    await itemService.update(item);
  } finally {
    state.isLoadingButton = false;
  }
}

function deleteItem() {
  // Lógica de exclusão
}

function saveActionPlan() {
  // Lógica específica da aba
}

function uploadFile() {
  // Lógica específica da aba
}
</script>
```

## Exemplo com Sub-abas

```vue
<script setup lang="ts">
const modalTabsConfig = computed((): TabsPanelConfigActions[] => [
  {
    tabTitle: 'Configurações',
    subTabs: [
      {
        id: 1,
        title: 'Geral',
        code: 1,
        icon: { name: 'Settings', color: '#447BDA' }
      },
      {
        id: 2,
        title: 'Segurança',
        code: 2,
        icon: { name: 'Shield', color: '#EA4335' }
      },
      {
        id: 3,
        title: 'Notificações',
        code: 3,
        icon: { name: 'Bell', color: '#34A853' }
      }
    ],
    onNextSubtab: async (current, next) => {
      // Validar antes de avançar
      const isValid = await validateCurrentSubtab(current);
      return isValid;
    },
    saveCheckpoint: async (current) => {
      // Salvar estado atual
      await saveSubtabState(current);
      return true;
    }
  }
]);

// Handlers para sub-abas
function handleSubTabClick(newSubTab: SubTab, oldSubTab: SubTab | undefined) {
  console.log('Mudou de sub-aba:', oldSubTab?.title, '→', newSubTab.title);
}
</script>
```

## Sidebar Colapsável

O TabsPanel possui uma sidebar que pode ser minimizada:

```vue
<template>
  <TabsPanel>
    <!-- Botão para minimizar/expandir sidebar -->
    <Button class="panel-minimize" @click="tabsMinimized = !tabsMinimized">
      <Icon name="Table2" color="#447BDA" :size="20" />
      <span>Sidebar</span>
    </Button>
  </TabsPanel>
</template>
```

## Casos de Uso Ideais

- **Formulários complexos**: Com múltiplas seções que precisam ser organizadas
- **Workflows sequenciais**: Processos com etapas que dependem umas das outras
- **Interfaces de configuração**: Quando há muitas opções para organizar
- **Sistemas com sub-categorias**: Quando há hierarquia na navegação
- **Operações que requerem contexto**: Manter navegação visível durante edição

## Exemplo Real - Não Conformidade

```vue
<template>
  <TabsPanel
    title="Gerenciar Não Conformidade"
    :open="state.openModal"
    :config-actions="modalTabsConfig"
    v-model:tab-index="state.tabIndex"
    @close-panel="[state.openModal = false, state.tabIndex = 0]"
  >
    <div v-if="state.tabIndex == 0">
      <Details :non-compliance="nonCompliance" :form-errors="formErrors" />
    </div>

    <div v-else-if="state.tabIndex == 1">
      <ActionPlan :non-compliance="nonCompliance" />
    </div>
  </TabsPanel>
</template>

<script setup lang="ts">
const modalTabsConfig = computed((): TabsPanelConfigActions[] => [
  {
    tabTitle: 'Detalhes',
    buttonsActions: [
      {
        label: 'Salvar',
        class: 'is-primary',
        icon: { name: 'Save' as LucideIconName, size: 18, color: '#fff' },
        callback: () => {
          if (state.viewMode === "create") {
            createNonCompliance();
          } else {
            updateNonCompliance();
          }
        },
      },
    ],
  },
  {
    tabTitle: 'Plano de Ação',
    disabled: state.viewMode === 'create', // Desabilitada até criar o item
  },
]);
</script>
```

## Estilização

```scss
.custom-tabs-panel {
  .tabs-name {
    width: 243px;
    
    .tab {
      height: 48px;
      padding: 12px;
      border-radius: 6px;
      cursor: pointer;
      
      &.active {
        background: var(--neutral-200);
      }
      
      &.disabled {
        pointer-events: none;
        opacity: 0.5;
      }
    }
  }
  
  .subtabs-dropdown {
    max-height: 320px;
    overflow-y: auto;
    
    .subtab-item {
      &.active {
        .vertical-line {
          background-color: var(--primary-300);
        }
      }
    }
  }
}
```

## Troubleshooting

### Abas não aparecem
- Verifique se `configActions` está definido e não está vazio
- Certifique-se de que as abas não estão marcadas como `hidden: true`

### Sub-abas não funcionam
- Verifique se a propriedade `subTabs` está definida na configuração da aba
- Implemente o handler `@sub-tab-click`

### Navegação por teclado não funciona
- Certifique-se de que o painel tem foco
- Verifique se não há outros elementos capturando os eventos de teclado

### Botões não aparecem
- Verifique se `buttonsActions` ou `leftButtons` estão definidos na aba atual
- Certifique-se de que os botões não estão marcados como `disabled: true`
