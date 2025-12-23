
# useFetch - Composable para Requisições HTTP com Autenticação

## 📄 Descrição

O `useFetch` é um composable Vue 3 que centraliza as chamadas HTTP utilizando o `axios`, com suporte para autenticação via JWT, tratamento de erros (incluindo redirecionamento em caso de token expirado) e estado de carregamento.

---

## 📆 Estrutura

```ts
import { ref } from 'vue';
import axios, { AxiosError, Method } from 'axios';
import { getAccessToken, JWT_KEY } from '../utils/helpers/jwt';
import router from '../router/routes';
import { removeFromLocalStorage } from '../utils/helpers/localStorage';
```

---

## 🔁 Enum `Service`

Enum que define os módulos (serviços) da API com seus respectivos caminhos base. Isso facilita a reutilização e evita erros de digitação em rotas.

### Exemplo padrão (produção):

```ts
export enum Service {
  Authorize = '/auth/v1/authorize',
  Core = '/core/v1',
  Checklist = '/checklist/v1',
  Custom = '/custom/v1',
  Reading = '/reading/v1',
  Reports = '/reports/v1',
  Analyzer = '/analyzer/v1',
  Notification = '/notifications/v1'
}
```

### Exemplo para rodar backend localmente:

```ts
export enum Service {
  Authorize = ':5134/v1/authorize',
  Core = ':5001/v1',
  Checklist = ':5008/v1',
  Custom = ':5003/v1',
  Reading = ':5005/v1',
  Reports = ':5006/v1',
  Analyzer = ':5141/v1',
  Notification = ':5010/v1'
}
```

### Exemplo settings.js com backend local:

```js
window._clientSettings = {
  apiUrl: "http://localhost",
  websocketUrl: "ws://localhost:8001",
  webServiceUrl: "http://192.168.1.5:{Coloque a porta corretamente}/datasnap/rest/RESTWebServiceMethods",
  homeToRedirect: "myPAC"
}
```
---

## 🚀 Utilização

A função `useFetch` é chamada com um serviço da enumeração `Service` e retorna:

- `result`: Resultado da requisição (reativo)
- `loading`: Indica se a requisição está em andamento
- `error`: Erro retornado pelo `axios`, caso ocorra
- `fetchData`: Função para realizar a chamada

### Exemplo:

```ts
const { result, loading, error, fetchData } = useFetch(Service.Core);

await fetchData('GET', '/usuarios');
```

### Argumentos de `fetchData`

| Argumento     | Tipo               | Obrigatório | Descrição                             |
|---------------|--------------------|--------------|------------------------------------------|
| `method`      | `Method`           | Sim          | Método HTTP (GET, POST, etc)            |
| `url`         | `string`           | Sim          | Endpoint relativo ao `baseURL`           |
| `data`        | `object/string`  | Não         | Corpo da requisição (POST, PUT, etc)     |
| `contentType` | `string`           | Não         | Tipo de conteúdo, padrão é `application/json` |

---

## ❌ Tratamento de Erros

Caso a API retorne erro 401 (Unauthorized):
- O token é removido do `localStorage`
- Dados de sessão são limpos
- O usuário é redirecionado para a tela de login

---

## 🔗 Integração com JWT

- O token é recuperado via `getAccessToken()`
- Inserido automaticamente no cabeçalho Authorization como `Bearer <token>`

---

## 📊 Considerações Finais

Esse composable é uma base robusta para lidar com chamadas HTTP autenticadas em aplicações Vue 3, com foco em reatividade, segurança e usabilidade.
