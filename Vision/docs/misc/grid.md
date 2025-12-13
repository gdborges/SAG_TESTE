# Guia de Uso do Componente Vue 3 Grid

Este documento descreve como utilizar o componente Vue 3 Grid baseado no `ag-grid-vue3`.

## Instalação

Certifique-se de ter as dependências necessárias instaladas no seu projeto:

```sh
npm install ag-grid-vue3 ag-grid-enterprise
```



## Props do Componente

| Propriedade                                 | Tipo               | Padrão          | Descrição                              |
|---------------------------------------------|--------------------|-----------------|----------------------------------------|
| `pagination` (Opcional)                     | `boolean`          | `true`          | Habilita paginação.                    |
| `paginationPageSize` (Opcional)             | `number`           | `25`            | Define o tamanho da página.            |
| `paginationPageSizeSelector` (Opcional)     | `number[]`         | `[25, 50, 100]` | Define as opções de tamanho da página. |
| `rowSelected` (Opcional)                    | `any[]`            | `[]`            | Lista de linhas selecionadas.          |
| `isVisibleHeader` (Opcional)                | `boolean`          | `true`          | Controla a visibilidade do cabeçalho.  |
| `hasActionButtons` (Opcional)               | `boolean`          | `true`          | Exibe botões de ação na grade.         |
| `headerProps`                               | `object`           | `{}`            | Define propriedades do cabeçalho.      |
| `headerProps.newItem`                       | `Function`         | `undefined`     | Define um novo item no cabeçalho.      |
| `service`                                   | `Function`         | `undefined`     | Função para buscar dados no servidor.  |
| `paramsService` (Opcional)                  | `any`              | `undefined`     | Parâmetros da chamada do serviço.      |
| `payloadService` (Opcional)                 | `any`              | `undefined`     | Payload da chamada do serviço.         |
| `columnDefs`                                | `array`            | `[]`            | Definição das colunas da grade.        |

## Eventos Emitidos

| Evento        | Parâmetros              | Descrição  |
|---------------|-------------------------|------------|
| `view`        | `event`                 | Acionado ao clicar em uma linha, retorna os dados da linha clicada. |
| `update`      | `params`                | Acionado ao editar um item. |
| `delete`      | `params.id`             | Acionado ao excluir um item. |
| `doubleClick` | `event`                 | Acionado ao dar um clique duplo em uma linha, retorna os dados da linha clicada |

## Métodos Expostos

O componente expõe métodos para manipulação dos dados na grade:

| Método       | Parâmetros        | Descrição |
|-------------|------------------|------------|
| `createRow` | `newItem`         | Adiciona uma nova linha no server side. |
| `updateRow` | `updatedItem`     | Atualiza uma linha existente no server side. |
| `deleteRow` | `deleteItem`      | Remove uma linha no server side. |

## Exemplo de Uso

```vue
<template>
  <Grid
    ref="gridItem"
    :columnDefs="columnDefs" 
    :rowData="rowData"
    :header-props="headerProps"
    :service="getItems"
  ></Grid>
</template>

<script setup lang="ts">
import Grid from '@/components/grid/Grid.vue';
import { useService } '@/server/api/moduleName/serverName';

const { getItems } = useService();

const columnDefs = [
  { headerName: 'ID', field: 'id', flex: 1 },
  { headerName: 'Nome', field: 'name', flex: 1 },
];

const headerProps: GridHeaderProps = reactive({
  newItem: viewItem
})

function viewItem() {
  // funcão que é executada ao clicar no botão de novo item.
}

</script>
```

## Considerações

- Utilize `service`, `paramsService` e `payloadService` para carregar dados do servidor.
- Utilize `createRow`, `updateRow` e `deleteRow` para manipular os dados na grade com o servidor server side.
- O evento `update` deve ser tratado para persistir as edições realizadas.

Com esse guia, você poderá integrar o componente de forma eficiente no seu projeto Vue 3.