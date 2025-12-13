# Configuração de Ambiente

Este documento explica como o sistema de configuração de ambiente funciona no projeto frontend-v2, permitindo definir URLs e outros parâmetros de ambiente sem a necessidade de recompilar o código.

## Sumário

1. [Visão Geral](#visão-geral)
2. [Arquivos do Sistema de Configuração](#arquivos-do-sistema-de-configuração)
3. [Como Funciona](#como-funciona)
4. [Configurações Disponíveis](#configurações-disponíveis)
5. [Modificando Configurações](#modificando-configurações)
6. [Ambientes Comuns](#ambientes-comuns)
7. [Utilizando as Configurações no Código](#utilizando-as-configurações-no-código)
8. [Melhores Práticas](#melhores-práticas)

## Visão Geral

O projeto utiliza um sistema de configuração baseado em JavaScript que permite definir parâmetros de ambiente (como URLs de API) fora do código-fonte principal. Este padrão oferece várias vantagens:

- **Implantação simplificada**: O mesmo build pode ser implantado em diferentes ambientes
- **Configuração pós-build**: Configurações podem ser ajustadas sem recompilar o projeto
- **Separação de preocupações**: Código e configuração separados
- **Facilidade de gerenciamento**: URLs e parâmetros centralizados em um único arquivo

## Arquivos do Sistema de Configuração

O sistema de configuração é composto por três arquivos principais:

### 1. `public/settings.js`

Arquivo JavaScript externo que define o objeto global de configurações:

```javascript
window._clientSettings = {
  apiUrl: "http://192.168.1.5:8001/api",
  websocketUrl: "ws://192.168.1.5:8021",
  webServiceUrl: "http://192.168.1.5:15020/datasnap/rest/RESTWebServiceMethods",
  homeToRedirect: "myPAC"
}
```

### 2. `index.html`

Importa o script de configurações antes de carregar a aplicação:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <script src="/settings.js"></script>
    <title>Edata</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
```

### 3. `src/utils/configs/configSettings.ts`

Exporta a interface TypeScript para o objeto de configuração e expõe o objeto global para o resto da aplicação:

```typescript
export interface Settings {
  apiUrl: string;
  websocketUrl: string;
  webServiceUrl: string;
  homeToRedirect?: string;
}

declare global {
  interface Window {
    _clientSettings: Settings;
  }
}

const config = window._clientSettings;

export { config }
```

## Como Funciona

O fluxo de funcionamento do sistema de configuração é o seguinte:

1. Quando a página é carregada, o navegador executa `settings.js`, que define o objeto global `window._clientSettings`
2. O módulo TypeScript `configSettings.ts` acessa esse objeto global e o exporta como `config`
3. Outros módulos da aplicação importam `config` deste arquivo quando precisam acessar as configurações

Esta abordagem garante que as configurações estejam disponíveis antes da inicialização da aplicação e que possam ser alteradas sem necessidade de recompilação.

## Configurações Disponíveis

O objeto de configuração (`Settings`) contém as seguintes propriedades:

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `apiUrl` | `string` | URL base para chamadas à API principal |
| `websocketUrl` | `string` | URL para conexões WebSocket |
| `webServiceUrl` | `string` | URL para serviços web específicos |
| `homeToRedirect` | `string?` | Caminho para redirecionamento após login (opcional) |

## Modificando Configurações

Para modificar as configurações para um ambiente específico:

1. Edite o arquivo `public/settings.js` com os valores apropriados para o ambiente
2. Se necessário, crie diferentes versões do arquivo para diferentes ambientes (ex: `settings.dev.js`, `settings.prod.js`)
3. Durante o deploy, copie o arquivo apropriado para `settings.js`

### Exemplo para ambiente de desenvolvimento:

```javascript
window._clientSettings = {
  apiUrl: "http://localhost:8001/api",
  websocketUrl: "ws://localhost:8021",
  webServiceUrl: "http://localhost:15020/datasnap/rest/RESTWebServiceMethods",
  homeToRedirect: "myPAC"
}
```

### Exemplo para ambiente de produção:

```javascript
window._clientSettings = {
  apiUrl: "https://api.exemplo.com/api",
  websocketUrl: "wss://ws.exemplo.com",
  webServiceUrl: "https://api.exemplo.com/datasnap/rest/RESTWebServiceMethods",
  homeToRedirect: "myPAC"
}
```

## Ambientes Comuns

A aplicação geralmente opera em vários ambientes, cada um com suas próprias configurações:

| Ambiente | Descrição | Exemplo de URL API |
|----------|-----------|-------------------|
| Local | Ambiente de desenvolvimento local | `http://localhost:8001/api` |
| Desenvolvimento | Servidor de desenvolvimento compartilhado | `http://dev-api.exemplo.com/api` |
| Homologação | Ambiente de testes e validação | `http://homolog-api.exemplo.com/api` |
| Produção | Ambiente de produção | `https://api.exemplo.com/api` |

## Utilizando as Configurações no Código

Para utilizar as configurações em qualquer parte do código:

```typescript
import { config } from '../utils/configs/configSettings';

// Exemplo de uso com API
const fetchData = async () => {
  const response = await fetch(`${config.apiUrl}/users`);
  return await response.json();
};

// Exemplo de uso com WebSocket
const initWebSocket = () => {
  const ws = new WebSocket(config.websocketUrl);
  // Configuração do WebSocket...
};
```

### Exemplo no composable useFetch

O composable `useFetch` utiliza essas configurações para determinar a URL base das chamadas de API:

```typescript
import { Service } from '../enums/Service';
import { config } from '../utils/configs/configSettings';

export function useFetch(service: Service) {
  // Determina a URL base baseada no serviço
  let baseURL = '';

  switch (service) {
    case Service.Core:
      baseURL = `${config.apiUrl}/core`;
      break;
    case Service.Reading:
      baseURL = `${config.apiUrl}/reading`;
      break;
    // outros serviços...
  }

  // Implementação do fetch...
}
```

## Melhores Práticas

1. **Nunca hardcode URLs**: Sempre use as configurações do ambiente
   ```typescript
   // Incorreto
   fetch('http://192.168.1.5:8001/api/users');

   // Correto
   fetch(`${config.apiUrl}/users`);
   ```

2. **Evite modificar `settings.js` diretamente em ambientes controlados**: Use scripts de deploy para copiar o arquivo apropriado

3. **Adicione validação de configurações**: Verifique se todas as configurações necessárias estão presentes ao inicializar a aplicação

4. **Crie scripts de inicialização para desenvolvimento**: Automatize a configuração do ambiente de desenvolvimento

5. **Documente novas configurações**: Ao adicionar novas propriedades ao objeto de configuração, atualize também a interface TypeScript e a documentação

6. **Considere o uso de valores padrão**: Para configurações opcionais, defina valores padrão sensatos no código

7. **Mantenha exemplos de configuração no repositório**: Inclua exemplos para todos os ambientes comuns
