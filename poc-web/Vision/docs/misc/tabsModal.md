# Guia de Uso do Componente `TabsModal`

## Introdução
O `TabsModal` é um componente modal personalizável para Vue 3, que permite a exibição de conteúdo organizado em abas. Ele possui suporte a transições, personalização de largura baseada em breakpoints e botões de ação dinâmicos.

## Instalação e Importação
Para utilizar este componente, importe-o em seu projeto Vue:

```html
<script setup>
import TabsModal from '@/components/modals/TabsModal.vue';
</script>
```

## Props
O componente aceita as seguintes props:

| Prop            | Tipo    | Padrão | Descrição |
|----------------|--------|--------|------------|
| `open`         | boolean | `false` | Controla a exibição do modal. |
| `title`        | string  | `''` | Define o título do modal. |
| `configActions` | TabsModalConfigActions[]  | `[]` | Configuração das abas e botões de ação. |
| `breakpoints`  | Record<string, string>  | Definido no componente | Define a largura do modal com base no tamanho da tela. |
| `tabIndex`     | number  | `0` | Índice da aba ativa. |

## Eventos Emitidos

| Evento         | Descrição |
|---------------|------------|
| `close-modal` | Emitido quando o modal é fechado. |

## Estrutura do `configActions`
A prop `configActions` define as abas e seus botões. Ela deve ser um array de TabsModalConfigActions (interface disponivel para importação) com a seguinte estrutura:

```ts
[
  {
    tabTitle: 'Nome da Aba',
    disabled: false,
    buttonsActions: [
      {
        label: 'Salvar',
        class: 'btn-primary',
        callback: () => console.log('Salvo!')
      }
    ]
  }
]
```

## Exemplo de Uso

```vue
<template>
  <TabsModal 
    :open="isModalOpen" 
    title="Configuração" 
    :configActions="tabsConfig"
    v-model:tabIndex="activeTab"
    @close-modal="isModalOpen = false"
  >
    <template #default>
      <div v-if="activeTab === 0">Conteúdo da Aba 1</div>
      <div v-else-if="activeTab === 1">Conteúdo da Aba 2</div>
    </template>
  </TabsModal>
</template>

<script setup>
import { ref, computed } from 'vue';
import TabsModal from '@/components/TabsModal.vue';


interface State {
  isModalOpen: boolean;
  activeTab: number;
}

const state: State = reactive({
  isModalOpen: false,
  activeTab: 0,
})

const tabsConfig = computed((): TabsModalConfigActions[] => {
  return [
    {
      tabTitle: 'Aba 1',
      disabled: false,
      buttonsActions: [
        { label: 'Avançar', class: 'btn-primary', callback: () => alert('Avançando!') }
      ]
    },
    {
      tabTitle: 'Aba 2',
      disabled: false,
      buttonsActions: [
        { label: 'Finalizar', class: 'btn-success', callback: () => alert('Finalizado!') }
      ]
    }
  ]
});
</script>
```

## Considerações Finais
- O modal fecha ao clicar no fundo escuro.
- O tamanho do modal se adapta automaticamente com base nos `breakpoints`.
- A navegação entre as abas é feita dinamicamente ao clicar nos nomes das abas.

Esse guia cobre os principais aspectos do `TabsModal` para facilitar sua implementação e personalização em projetos Vue 3.