# Padrões de Código

## Padrões para Arquivos `.vue`

1. **Estrutura do Componente**:
  - Utilize a ordem padrão: `<template>`, `<script>`, `<style>`.
  - Certifique-se de manter o código limpo e organizado.
  - Certifique-se de utilizar as ferramentas do composition api, typescript, scss e scoped.

```html
<template>
  <div class="page-example">
    <p>{{ message }}</p>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const message = ref('Olá, mundo!');
</script>

<style scoped styles="scss">
.page-example {
  height: 100%;
}
</style>
```

2. **Nome de Arquivos**:
  - Use PascalCase para nomear component"es `.vue` (ex.: `MyComponent.vue`).
  - Use snake-case para nomear views `.vue` (ex.: `my-view.vue`).

3. **Indentação**:
  - Utilize 2 espaços para indentação.

## Padrões para Arquivos `.ts`

1. **Exportação de Funções**:
  - Cada função deve ser exportada de forma explícita no final do arquivo.
  - Cada função deve ter os tipos no retorno e dos parâmetros de forma explícita.

```typescript
function callback(args: Record<string, any>): string {
  // Implementação aqui
}

export {
  callback
};
```

2. **Nome de Arquivos**:
  - Use camelCase para arquivos contendo utilitários ou funções (ex.: `calculateSum.ts`).
  - Use PascalCase para classes e interfaces (ex.: `UserModel.ts`).


## Padrão para Declaração de Funções

### Funções com até 3 linhas

Para funções curtas (com no máximo 3 linhas), a declaração é opcional entre:

- **Arrow Function:**
  ```javascript
  const handleClick = () => console.log('Clique!');

- **Function Declaration:**
  ```javascript
  function handleClick() { 
    console.log('Clique!'); 
  }

Ambas as formas são aceitas, permitindo flexibilidade na escrita do código.

### Funções com mais de 3 linhas

Para funções que ultrapassam 3 linhas, o padrão é utilizar function declaration:

- **Function Declaration:**
  ```javascript
  function fetchData() {
    try {
      console.log('Iniciando requisição...');
      const { result, error } = useFetch('https://api.example.com');
      return {
        result, 
        error,
      };
    } catch (error) {
      return error;
    }
  }
Isso garante melhor legibilidade e facilita o debug.

## Padrões para Requisições

1. **Validação com Zod**:
  - Utilize a biblioteca `zod` para validar os dados antes de qualquer requisição.

```typescript
import { z } from 'zod';
import { reactive } from 'vue';

const loginSchema = z.object({
  username: z.string().nonempty('Usuário inválido'),
  password: z.string().min(6, 'A senha é obrigatória'),
});

interface Login {
  username: string;
  password: string;
}

const loginState: Login = reactive({
  username: "",
  password: "",
});

async function login() {
  try {
    loginSchema.parse(loginState);
    // Continue com a lógica de login aqui
  } finally {

  }
}
```

2. **Erros**:
  - Trate erros de validação exibindo mensagens claras para o usuário.

## Observações Gerais

- Sempre documente funções e componentes utilizando comentários no estilo JSDoc.
- Utilize nomes descritivos para variáveis, funções e arquivos.
- Garanta consistência nos estilos de código seguindo os padrões acima.