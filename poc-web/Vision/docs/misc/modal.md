# Modal.vue - Documentação Completa

## Visão Geral

O componente `Modal.vue` é um modal tradicional centralizado com sistema de breakpoints responsivos e redimensionamento automático. É ideal para formulários que precisam se adaptar ao conteúdo e funcionar bem em diferentes tamanhos de tela.

## Características Principais

- **Overlay**: Fundo escuro com modal centralizado
- **Breakpoints**: Sistema responsivo baseado na largura da tela
- **Redimensionamento Automático**: Sistema baseado na quantidade de campos detectados
- **Atalhos de Teclado**: Ctrl+S para salvar, Ctrl+D para fechar
- **Transições**: Animações suaves de entrada/saída

## Props

### `open` (obrigatório)
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Controla se o modal está visível

```vue
<Modal :open="state.openModal" />
```

### `breakpoints`
- **Tipo**: `Record<string, string>`
- **Padrão**: 
```typescript
{
  '3000px': '90vw',
  '2000px': '90vw',
  '1600px': '90vw',
  '1300px': '90vw',
  '960px': '85vw',
  '640px': '80vw',
  '480px': '90vw'
}
```
- **Descrição**: Define a largura do modal baseado no tamanho da tela

```vue
<Modal 
  :breakpoints="{
    '960px': '50vw',
    '640px': '75vw',
    '480px': '90vw'
  }"
/>
```

### `height`
- **Tipo**: `number | string`
- **Padrão**: `90`
- **Descrição**: Define a altura do modal em porcentagem

```vue
<Modal :height="75" />
```

### `expand`
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Habilita o botão de expandir/minimizar

```vue
<Modal :expand="true" />
```

### `isEnableFooter`
- **Tipo**: `boolean`
- **Padrão**: `true`
- **Descrição**: Controla se o footer deve ser exibido

```vue
<Modal :is-enable-footer="false" />
```

### `isEnableDeleteButton`
- **Tipo**: `boolean`
- **Padrão**: `false`
- **Descrição**: Exibe o botão de deletar no header

```vue
<Modal :is-enable-delete-button="true" />
```

### `viewMode`
- **Tipo**: `'create' | 'update' | 'view'`
- **Descrição**: Define o modo de visualização para botões automáticos

```vue
<Modal :view-mode="state.viewMode" />
```

### `isDisabledButton`
- **Tipo**: `boolean`
- **Descrição**: Desabilita os botões de ação

```vue
<Modal :is-disabled-button="state.isLoading" />
```

### `service`
- **Tipo**: `{ create?: () => Promise<void>; update?: () => Promise<void>; }`
- **Descrição**: Serviços para operações CRUD automáticas

```vue
<Modal 
  :service="{
    create: createItem,
    update: updateItem
  }"
/>
```

## Eventos

### `close-modal`
Emitido quando o modal deve ser fechado

```vue
<Modal @close-modal="handleClose" />
```

### `delete`
Emitido quando o botão de deletar é clicado

```vue
<Modal @delete="handleDelete" />
```

### `save-info`
Emitido quando Ctrl+S é pressionado

```vue
<Modal @save-info="handleSave" />
```

## Slots

### `header`
Personaliza o cabeçalho do modal

```vue
<Modal>
  <template #header>
    <h2>Título Personalizado</h2>
  </template>
</Modal>
```

### `body`
Conteúdo principal do modal

```vue
<Modal>
  <template #body>
    <form>
      <!-- Formulário aqui -->
    </form>
  </template>
</Modal>
```

### `footer`
Personaliza o rodapé (substitui botões automáticos)

```vue
<Modal>
  <template #footer>
    <Button @click="customSave">Salvar</Button>
    <Button @click="close">Cancelar</Button>
  </template>
</Modal>
```

## Sistema de Redimensionamento Automático

O modal possui um sistema inteligente que detecta automaticamente a quantidade de campos no formulário e ajusta o tamanho:

- **Pequeno** (≤3 campos): 400px width, height auto
- **Médio** (≤7 campos): 600px width, height auto  
- **Grande** (≤11 campos): 800px width, height auto
- **Tela Cheia** (>11 campos): 95vw width, 90vh height

### Desabilitar Redimensionamento Automático

```vue
<Modal :auto-size="false" />
```

## Atalhos de Teclado

- **Ctrl+S**: Emite evento `save-info`
- **Ctrl+D**: Fecha o modal

## Exemplo Completo

```vue
<template>
  <Modal
    :open="state.openModal"
    :view-mode="state.viewMode"
    :is-disabled-button="state.isLoading"
    :is-enable-delete-button="state.viewMode !== 'create'"
    :service="{
      create: createUser,
      update: updateUser
    }"
    @close-modal="state.openModal = false"
    @delete="handleDelete"
    @save-info="handleSave"
  >
    <template #header>
      <h2>{{ state.viewMode === 'create' ? 'Novo Usuário' : 'Editar Usuário' }}</h2>
    </template>

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
    </template>
  </Modal>
</template>

<script setup lang="ts">
interface State {
  openModal: boolean;
  viewMode: 'create' | 'update' | 'view';
  isLoading: boolean;
}

const state = reactive<State>({
  openModal: false,
  viewMode: 'view',
  isLoading: false
});

const user = reactive({
  name: '',
  email: ''
});

async function createUser() {
  state.isLoading = true;
  try {
    // Lógica de criação
    await userService.create(user);
    state.openModal = false;
  } finally {
    state.isLoading = false;
  }
}

async function updateUser() {
  state.isLoading = true;
  try {
    // Lógica de atualização
    await userService.update(user);
    state.openModal = false;
  } finally {
    state.isLoading = false;
  }
}

function handleDelete() {
  // Lógica de exclusão
}

function handleSave() {
  if (state.viewMode === 'create') {
    createUser();
  } else {
    updateUser();
  }
}
</script>
```

## Casos de Uso Ideais

- Formulários que precisam se adaptar ao conteúdo
- Interfaces que requerem foco total do usuário
- Operações CRUD simples a médias
- Quando o redimensionamento automático é importante
- Formulários que precisam funcionar bem em diferentes tamanhos de tela

## Integração com Permissões

O modal integra automaticamente com o sistema de permissões:

```vue
<!-- Botão de salvar só aparece se usuário tem permissão GRAVAR -->
<Modal view-mode="create" />

<!-- Botão de atualizar só aparece se usuário tem permissão ALTERAR -->
<Modal view-mode="update" />
```

## Estilização

O modal utiliza variáveis CSS do tema:

```scss
.custom-modal {
  .modal-card {
    background-color: var(--neutral-white);
    border-radius: 16px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  }
  
  .modal-background {
    background-color: rgba(0, 0, 0, 0.425);
  }
}
```

## Troubleshooting

### Modal não aparece
- Verifique se `open` está definido como `true`
- Certifique-se de que o modal está dentro de um Teleport para `#container`

### Redimensionamento não funciona
- Verifique se `autoSize` não está definido como `false`
- Certifique-se de que os campos têm as classes CSS corretas

### Atalhos não funcionam
- Verifique se o modal tem foco
- Certifique-se de que não há outros elementos capturando os eventos de teclado
