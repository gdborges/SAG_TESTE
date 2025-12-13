# Panel.vue - Documentação Completa

## Visão Geral

O componente `Panel.vue` é um painel lateral simples com funcionalidades básicas de CRUD e navegação. É ideal para formulários simples, visualização de detalhes e operações que não requerem múltiplas seções.

## Características Principais

- **Layout**: Painel ocupando 100% da altura e largura
- **Header**: Botão voltar, breadcrumb e ações (expandir/deletar)
- **Body**: Slot para conteúdo personalizado
- **Footer**: Botões de ação baseados no `viewMode`
- **Transições**: Animação suave de entrada/saída

## Props

### `open` (obrigatório)
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Controla se o painel está visível

```vue
<Panel :open="state.openPanel" />
```

### `height`
- **Tipo**: `number | string`
- **Padrão**: `100`
- **Descrição**: Define a altura do painel em vh (viewport height)

```vue
<Panel :height="80" />
```

### `expand`
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Habilita o botão de expandir/minimizar

```vue
<Panel :expand="true" />
```

### `isEnableFooter`
- **Tipo**: `boolean`
- **Padrão**: `true`
- **Descrição**: Controla se o footer deve ser exibido

```vue
<Panel :is-enable-footer="false" />
```

### `isEnableDeleteButton`
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Exibe o botão de deletar no header

```vue
<Panel :is-enable-delete-button="true" />
```

### `viewMode`
- **Tipo**: `'create' | 'update' | 'view'`
- **Descrição**: Define o modo de visualização para botões automáticos

```vue
<Panel :view-mode="state.viewMode" />
```

### `isDisabledButton`
- **Tipo**: `boolean`
- **Descrição**: Desabilita os botões de ação

```vue
<Panel :is-disabled-button="state.isLoading" />
```

### `service`
- **Tipo**: `{ create?: () => Promise<void>; update?: () => Promise<void>; }`
- **Descrição**: Serviços para operações CRUD automáticas

```vue
<Panel 
  :service="{
    create: createItem,
    update: updateItem
  }"
/>
```

### `showBackButton`
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Controla se o botão de voltar deve ser exibido

```vue
<Panel :show-back-button="true" />
```

### `breadcrumbMain`
- **Tipo**: `string`
- **Padrão**: `''`
- **Descrição**: Texto principal do breadcrumb

```vue
<Panel breadcrumb-main="Usuários" />
```

### `breadcrumbCurrent`
- **Tipo**: `string`
- **Padrão**: `''`
- **Descrição**: Texto atual do breadcrumb

```vue
<Panel breadcrumb-current="Novo Usuário" />
```

## Eventos

### `close-panel`
Emitido quando o painel deve ser fechado

```vue
<Panel @close-panel="handleClose" />
```

### `delete`
Emitido quando o botão de deletar é clicado

```vue
<Panel @delete="handleDelete" />
```

### `back`
Emitido quando o botão de voltar é clicado (apenas se `showBackButton` for true)

```vue
<Panel @back="handleBack" />
```

## Slots

### `body`
Conteúdo principal do painel

```vue
<Panel>
  <template #body>
    <form>
      <!-- Formulário aqui -->
    </form>
  </template>
</Panel>
```

### `footer`
Personaliza o rodapé (substitui botões automáticos)

```vue
<Panel>
  <template #footer>
    <Button @click="customSave">Salvar</Button>
    <Button @click="close">Cancelar</Button>
  </template>
</Panel>
```

## Sistema de Navegação

### Breadcrumb
O painel suporta breadcrumb para navegação contextual:

```vue
<Panel
  breadcrumb-main="Cadastros"
  breadcrumb-current="Usuários"
/>
```

### Botão Voltar
Comportamento do botão voltar:

- Se `showBackButton` for `true`: emite evento `back`
- Se `showBackButton` for `false`: emite evento `close-panel` e limpa query params da URL

## Integração com Permissões

O painel integra automaticamente com o sistema de permissões:

```vue
<!-- Botão de salvar só aparece se usuário tem permissão GRAVAR -->
<Panel view-mode="create" />

<!-- Botão de atualizar só aparece se usuário tem permissão ALTERAR -->
<Panel view-mode="update" />
```

## Exemplo Completo

```vue
<template>
  <div class="page-users">
    <!-- Grid para listagem -->
    <Grid
      v-show="!state.openPanel"
      ref="gridUsers"
      :column-defs="colsDefs"
      :template-service="userService.getUsersByCriteria"
      @update="[state.viewMode = 'update', state.openPanel = true, getUser($event)]"
    />

    <!-- Panel para edição -->
    <Panel
      v-if="state.openPanel"
      :open="true"
      :view-mode="state.viewMode"
      :is-disabled-button="state.isLoading"
      :is-enable-delete-button="state.viewMode !== 'create'"
      :service="{
        create: createUser,
        update: updateUser
      }"
      :breadcrumb-main="currentBreadcrumbMain"
      :breadcrumb-current="currentBreadcrumbCurrent"
      @close-panel="handleClosePanel"
      @delete="handleDelete"
    >
      <template #body>
        <div class="columns">
          <div class="column">
            <FormControl
              label="Nome"
              v-model="user.name"
              :disabled="state.viewMode === 'view'"
              required
            />
          </div>
          <div class="column">
            <FormControl
              label="Email"
              v-model="user.email"
              :disabled="state.viewMode === 'view'"
              required
            />
          </div>
        </div>
        
        <div class="columns">
          <div class="column">
            <Select
              label="Perfil"
              v-model="user.profileId"
              :options="profiles"
              value-field="id"
              key-field="name"
              :disabled="state.viewMode === 'view'"
            />
          </div>
        </div>
      </template>
    </Panel>
  </div>
</template>

<script setup lang="ts">
interface State {
  openPanel: boolean;
  viewMode: 'create' | 'update' | 'view';
  isLoading: boolean;
}

const state = reactive<State>({
  openPanel: false,
  viewMode: 'view',
  isLoading: false
});

const user = reactive({
  id: '',
  name: '',
  email: '',
  profileId: ''
});

const currentBreadcrumbMain = computed(() => {
  if (state.viewMode === 'create') {
    return 'Criando Usuário';
  } else {
    return `Usuário ${user.id}`;
  }
});

const currentBreadcrumbCurrent = computed(() => {
  return 'Detalhes';
});

async function createUser() {
  state.isLoading = true;
  try {
    await userService.create(user);
    state.openPanel = false;
  } finally {
    state.isLoading = false;
  }
}

async function updateUser() {
  state.isLoading = true;
  try {
    await userService.update(user);
    state.openPanel = false;
  } finally {
    state.isLoading = false;
  }
}

function handleClosePanel() {
  state.openPanel = false;
}

function handleDelete() {
  // Lógica de exclusão
}

async function getUser(userData: any) {
  const { result } = await userService.getUser(userData.id);
  Object.assign(user, result.value.data);
}
</script>
```

## Casos de Uso Ideais

- **Formulários simples**: Quando não há necessidade de múltiplas seções
- **Visualização de detalhes**: Para exibir informações de um item específico
- **Operações CRUD básicas**: Create, Read, Update, Delete simples
- **Interfaces laterais**: Quando você quer manter o contexto da listagem visível
- **Workflows lineares**: Processos que não requerem navegação entre abas

## Exemplo com InfoBox

```vue
<Panel>
  <template #body>
    <!-- InfoBox para exibir informações resumidas -->
    <InfoBox
      :items="infoBoxItems"
      :right-items="rightInfoBoxItems"
      @click="toggleCollapse"
    />

    <!-- Formulário principal -->
    <div class="columns">
      <div class="column">
        <FormControl
          label="Descrição"
          v-model="item.description"
        />
      </div>
    </div>
  </template>
</Panel>

<script setup lang="ts">
const infoBoxItems = computed(() => [
  {
    icon: 'FileDigitIcon',
    text: `Código: ${item.code}`,
    color: '#447BDA'
  },
  {
    icon: 'CalendarPlus2Icon',
    label: 'Criado em',
    text: formatDate(item.createdAt),
    color: '#606B80'
  }
]);
</script>
```

## Estilização

O painel utiliza variáveis CSS do tema:

```scss
.custom-tabs-panel {
  font-family: 'Inter';
  
  .tabs-panel-head {
    background-color: var(--neutral-white);
    border-top-left-radius: 16px;
    border-top-right-radius: 16px;
    color: var(--neutral-800);
  }
  
  .panel-back {
    border: 2px solid var(--neutral-200);
    background: var(--neutral-white);
    
    &:hover {
      background-color: var(--neutral-100);
    }
  }
}
```

## Diferenças do Modal

| Aspecto | Panel | Modal |
|---------|-------|-------|
| **Layout** | Lateral, 100% altura | Centralizado, overlay |
| **Contexto** | Mantém grid visível | Foco total no conteúdo |
| **Navegação** | Breadcrumb, botão voltar | Botão fechar |
| **Uso** | Formulários simples | Formulários complexos |
| **Responsividade** | Fixo | Breakpoints adaptativos |

## Troubleshooting

### Panel não aparece
- Verifique se `open` está definido como `true`
- Certifique-se de que o container pai tem altura definida

### Botão voltar não funciona
- Verifique se `showBackButton` está definido como `true`
- Implemente o handler para o evento `@back`

### Breadcrumb não aparece
- Certifique-se de que tanto `breadcrumbMain` quanto `breadcrumbCurrent` estão definidos
- Ambos precisam ter valores não vazios

### Footer não aparece
- Verifique se `isEnableFooter` não está definido como `false`
- Se usando slot footer personalizado, certifique-se de que o conteúdo não está vazio
