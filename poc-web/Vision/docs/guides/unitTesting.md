# Guia de Testes Unitários no Frontend

Este documento explica a abordagem de testes unitários utilizada no projeto frontend-v2, abordando tanto a justificativa para os testes quanto os padrões e técnicas implementados. A documentação baseia-se nas implementações existentes em `src/components/tests` e `src/views/private/security/tests`.

## Sumário

1. [Por que escrever testes unitários?](#por-que-escrever-testes-unitários)
2. [Ferramentas de teste](#ferramentas-de-teste)
3. [Estrutura de testes](#estrutura-de-testes)
4. [Padrões de teste](#padrões-de-teste)
   - [Testes de componentes](#testes-de-componentes)
   - [Testes de páginas (views)](#testes-de-páginas-views)
   - [Testes de serviços](#testes-de-serviços)
5. [Mocks](#mocks)
6. [Boas práticas](#boas-práticas)
7. [Exemplos detalhados](#exemplos-detalhados)
8. [Executando os testes](#executando-os-testes)

## Por que escrever testes unitários?

Os testes unitários oferecem vários benefícios importantes para o projeto:

1. **Detecção precoce de bugs**: Identificam problemas antes que cheguem à produção
2. **Documentação viva**: Fornecem exemplos funcionais de como os componentes devem ser usados
3. **Refatoração segura**: Permitem refatorar código com confiança, verificando se a funcionalidade continua inalterada
4. **Design modular**: Incentivam um design de código mais modular e desacoplado
5. **Confiabilidade**: Aumentam a confiança na qualidade e estabilidade do código
6. **Integração contínua**: Facilitam a implementação de pipelines de CI/CD

No contexto deste projeto Vue 3, os testes unitários ajudam a garantir que:

- Os componentes funcionem como esperado em diferentes cenários
- As interações de usuário sejam processadas corretamente
- As integrações com serviços externos ocorram conforme esperado
- Os fluxos de dados através da aplicação sejam consistentes

## Ferramentas de teste

O projeto utiliza as seguintes ferramentas para testes:

- **Vitest**: Framework de teste rápido e compatível com o ecossistema Vite
- **Vue Test Utils**: Biblioteca oficial para testar componentes Vue
- **jsdom**: Ambiente de teste que simula um navegador
- **vi (mock)**: API de mocking fornecida pelo Vitest

A configuração básica está definida em `vitest.config.ts`:

```typescript
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import AutoImport from 'unplugin-auto-import/vite';

export default defineConfig({
  plugins: [
    vue(),
    AutoImport({
      imports: ['vue'],
      dts: 'src/modules/auto-imports.d.ts',
    }),
  ],
  test: {
    environment: 'jsdom',
    include: ['**/tests/**/*.spec.ts'],
  },
  resolve: {
    extensions: ['.vue', '.js', '.json', '.jsx', '.ts', '.tsx', '.node'],
  }
})
```

## Estrutura de testes

Os arquivos de teste seguem uma estrutura organizada:

```
src/
├── components/
│   ├── Component.vue            # Componente a ser testado
│   └── tests/
│       └── Component.spec.ts    # Teste do componente
├── composables/
│   ├── useFetch.ts              # Composable de comunicação com a API
│   └── tests/
│       └── useFetch.spec.ts     # Teste do composable
├── views/private/[módulo]/
│   ├── page.vue                 # Página a ser testada
│   └── tests/
│       └── page.spec.ts         # Teste da página
└── server/api/[service]/
    ├── service.ts               # Serviço a ser testado
    └── tests/
        └── service.spec.ts      # Teste do serviço
├── utils/
    ├── helpers/
    │   ├── parsers.ts           # Parser a ser testado
    │   └── tests/
    │       └── parsers.spec.ts  # Teste do parser
    │   ├── validators.ts        # Validator a ser testado
    │   └── tests/
    │       └── validators.spec.ts  # Teste do validator
```

Esta estrutura permite um mapeamento claro entre o código de produção e seus testes correspondentes.

## Padrões de teste

### Testes de componentes

Os testes de componentes focam em verificar:

1. **Renderização correta** (se o componente é montado adequadamente)
2. **Comportamento das props** (como o componente reage a diferentes props)
3. **Emissão de eventos** (se eventos são emitidos corretamente)
4. **Interação com o usuário** (cliques, inputs, etc.)
5. **Estados visuais** (classes CSS, textos visíveis, etc.)

Exemplo básico (Button.spec.ts):

```typescript
import { mount } from '@vue/test-utils';
import { describe, it, expect } from 'vitest';
import Button from '../Button.vue';

describe('Button.vue', () => {
  it('renders the button', () => {
    const wrapper = mount(Button, {
      props: {
        type: 'primary',
      },
    });

    const button = wrapper.find('button');
    expect(button.exists()).toBe(true);
    expect(button.classes()).toContain('is-primary');
  });

  it('emits click event when clicked', async () => {
    const wrapper = mount(Button);

    const button = wrapper.find('button');
    await button.trigger('click');

    expect(wrapper.emitted()).toHaveProperty('click');
  });

  it('does not emit click event when disabled', async () => {
    const wrapper = mount(Button, {
      props: {
        disabled: true,
      },
    });

    const button = wrapper.find('button');
    await button.trigger('click');

    expect(wrapper.emitted().click).toBeFalsy();
  });
});
```

### Testes de páginas (views)

Os testes de páginas são mais complexos e verificam:

1. **Integração de múltiplos componentes**
2. **Interações com serviços** (chamadas API)
3. **Fluxos de trabalho completos** (ex: criar, editar, excluir)
4. **Estados da página** (ex: loading, erro, sucesso)
5. **Manipulação de dados** (ex: preencher formulários, validação)

Exemplo (companies.spec.ts):

```typescript
import { mount } from '@vue/test-utils';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import pageCompanys from '../companies.vue';
import { createPinia, setActivePinia } from 'pinia';

// Mock de serviços
vi.mock('../../../../server/api/core/company', () => {
  return {
    useCompanyService: vi.fn(() => ({
      getCompanys: vi.fn().mockResolvedValue({
        result: { value: { data: [], total: 0 } },
        error: { value: null }
      }),
      createCompany: vi.fn().mockResolvedValue({
        result: { value: { id: '1' } },
        error: { value: null }
      }),
      // ...outros métodos mockados
      loading: { value: false }
    }))
  };
});

// Mock de traduções
vi.mock('../../../../plugins/i18n', () => ({
  useTranslate: () => ({
    $translate: (key: string) => key,
  }),
}));

describe('companies.vue', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
  });

  it('abre o modal de criação ao clicar no botão criar', async () => {
    const wrapper = mount(pageCompanys, {
      global: {
        stubs: {
          Grid: { template: '<div class="grid-stub"></div>' },
          Modal: true,
        },
        provide: {
          $translate: (key: string) => key,
        },
      }
    });

    await wrapper.vm.state.viewMode = 'create';
    await wrapper.vm.state.openModal = true;

    expect(wrapper.vm.state.viewMode).toBe('create');
    expect(wrapper.vm.state.openModal).toBe(true);
  });

  // ...outros testes
});
```

### Testes de serviços

Os testes de serviços verificam:

1. **Chamadas API corretas** (URLs, métodos HTTP, parâmetros)
2. **Tratamento de respostas** (dados, erros)
3. **Transformações de dados** 
4. **Estados reativos** (error, loading, result)

Exemplo de teste de serviço:

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useProductService } from '../product';

// Mock do composable useFetch
vi.mock('../../../composables/useFetch', () => {
  const fetchDataMock = vi.fn();
  const errorMock = { value: null };
  const resultMock = { value: { data: [] } };
  const loadingMock = { value: false };

  return {
    Service: {
      Reading: 'reading',
    },
    useFetch: () => ({
      fetchData: fetchDataMock,
      error: errorMock,
      result: resultMock,
      loading: loadingMock
    })
  };
});

describe('useProductService', () => {
  const fetchMock = vi.mocked(useFetch().fetchData);
  
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('getProductsByCriteria chama fetchData com os parâmetros corretos', async () => {
    const productService = useProductService();
    const params = 'param=value';
    const payload = { filter: 'test' };
    
    await productService.getProductsByCriteria(params, payload);
    
    expect(fetchMock).toHaveBeenCalledWith(
      'post', 
      `/produto/criteria?${params}`, 
      payload
    );
  });
});
```

## Mocks

Mocks são essenciais nos testes unitários para isolar o código sendo testado das dependências externas. No projeto, existem várias estratégias de mocking:

### 1. Mocks de serviços API

```typescript
vi.mock('../../../../server/api/core/window', () => {
  return {
    useWindowService: vi.fn(() => ({
      getWindows: vi.fn().mockResolvedValue({
        result: { value: { data: [{ id: '1' }], total: 1 } },
        error: { value: null }
      }),
      // outros métodos...
    }))
  };
});
```

### 2. Mocks de composables Vue

```typescript
vi.mock('vue', async (importOriginal) => {
  const actual = (await importOriginal()) as Record<string, any>
  return {
    ...actual,
    useTemplateRef: () => ({
      value: gridMethods
    })
  };
});
```

### 3. Mocks de bibliotecas

```typescript
vi.mock('vue-router', async (importOriginal) => {
  const actual = (await importOriginal()) as Record<string, any>
  return {
    ...actual,
    useRoute: vi.fn(() => ({
      params: { id: '1' }
    })),
    useRouter: vi.fn(() => ({
      push: vi.fn()
    }))
  };
});
```

### 4. Mocks de configurações

```typescript
vi.mock('../../../../utils/configs/configSettings', () => ({
  config: {
    apiUrl: 'http://localhost:3000',
    websocketUrl: 'ws://localhost:3001',
    homeToRedirect: '/home',
  },
}));
```

## Boas práticas

### 1. Isole os testes

Cada teste deve ser independente e não afetar outros testes. Use `beforeEach` para reinicializar estados:

```typescript
beforeEach(() => {
  setActivePinia(createPinia());
  vi.clearAllMocks();
});
```

### 2. Use nomes descritivos

Os nomes dos testes devem descrever claramente o comportamento esperado:

```typescript
it('desabilita o botão quando a propriedade loading é true', () => {
  // ...
});
```

### 3. Um assert por teste

Sempre que possível, mantenha um único assert por teste para facilitar a identificação de falhas:

```typescript
// Bom
it('aplica a classe is-loading quando loading é true', () => {
  expect(button.classes()).toContain('is-loading');
});

it('desativa o botão quando loading é true', () => {
  expect(button.attributes('disabled')).toBeDefined();
});

// Evitar
it('aplica a classe is-loading e desativa quando loading é true', () => {
  expect(button.classes()).toContain('is-loading');
  expect(button.attributes('disabled')).toBeDefined();
});
```

### 4. Use stubs para componentes complexos

Quando testar componentes complexos, use stubs para simplificar:

```typescript
const wrapper = mount(Component, {
  global: {
    stubs: {
      ComplexComponent: true,
      AnotherComponent: { template: '<div class="stub"></div>' }
    }
  }
});
```

### 5. Teste comportamentos, não implementações

Foque em testar o comportamento esperado, não os detalhes de implementação:

```typescript
// Bom
it('exibe mensagem de erro quando a validação falha', async () => {
  await wrapper.find('button').trigger('click');
  expect(wrapper.find('.error-message').exists()).toBe(true);
});

// Evitar
it('chama a função validateForm quando o botão é clicado', async () => {
  const spy = vi.spyOn(wrapper.vm, 'validateForm');
  await wrapper.find('button').trigger('click');
  expect(spy).toHaveBeenCalled();
});
```

## Exemplos detalhados

### Exemplo 1: Teste de componente básico (Button.spec.ts)

Este exemplo mostra como testar um componente UI simples:

```typescript
import { mount } from '@vue/test-utils';
import { describe, it, expect } from 'vitest';
import Button from '../Button.vue';

describe('Button.vue', () => {
  it('renderiza o botão', () => {
    const wrapper = mount(Button, {
      props: {
        type: 'primary',
      },
    });

    const button = wrapper.find('button');
    expect(button.exists()).toBe(true);
    expect(button.classes()).toContain('is-primary');
  });

  it('emite evento de clique quando clicado', async () => {
    const wrapper = mount(Button);

    const button = wrapper.find('button');
    await button.trigger('click');

    expect(wrapper.emitted()).toHaveProperty('click');
  });

  it('não emite evento de clique quando desabilitado', async () => {
    const wrapper = mount(Button, {
      props: {
        disabled: true,
      },
    });

    const button = wrapper.find('button');
    await button.trigger('click');

    expect(wrapper.emitted().click).toBeFalsy();
  });

  it('aplica classe loading quando prop loading é true', () => {
    const wrapper = mount(Button, {
      props: {
        loading: true,
      },
    });

    const button = wrapper.find('button');
    expect(button.classes()).toContain('is-loading');
  });
});
```

### Exemplo 2: Teste de página CRUD (windows.spec.ts)

Este exemplo demonstra como testar uma página com operações CRUD:

```typescript
import { mount } from '@vue/test-utils';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createPinia, setActivePinia } from 'pinia';
import Windows from '../windows.vue';

// Mock dos serviços
const createWindowMock = vi.fn().mockResolvedValue({
  result: { value: { id: '1' } },
  error: { value: null }
});

// ... outros mocks ...

vi.mock('../../../../server/api/core/window', () => {
  return {
    useWindowService: vi.fn(() => ({
      getWindows: vi.fn().mockResolvedValue({
        result: { value: { data: [{ id: '1' }], total: 1 } },
        error: { value: null }
      }),
      createWindow: createWindowMock,
      // ... outros métodos mockados ...
    }))
  };
});

describe('windows.vue', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
    vi.clearAllMocks();
  });

  it('abre o modal ao clicar no botão de criação', async () => {
    const wrapper = mount(Windows, {
      global: {
        stubs: {
          Grid: { template: '<div><slot /></div>' },
          Modal: true,
          // ... outros stubs ...
        },
        provide: {
          $translate: (key: string) => key
        },
      }
    });

    // Simular clique no botão de criação
    await wrapper.vm.state.viewMode = 'create';
    await wrapper.vm.state.openModal = true;

    expect(wrapper.vm.state.openModal).toBe(true);
    expect(wrapper.vm.state.viewMode).toBe('create');
  });

  it('cria uma janela com sucesso', async () => {
    const wrapper = mount(Windows, {
      global: {
        stubs: {
          Grid: true,
          Modal: true,
        },
        provide: {
          $translate: (key: string) => key
        },
      }
    });

    // Configurar dados do formulário
    wrapper.vm.window.description = 'Test Window';
    wrapper.vm.window.moduleId = 'mod1';

    // Chamar método de criação
    await wrapper.vm.createWindow();

    expect(createWindowMock).toHaveBeenCalledWith({
      description: 'Test Window',
      moduleId: 'mod1'
    });
    expect(wrapper.vm.state.openModal).toBe(false);
  });

  // ... outros testes para atualização, exclusão, etc.
});
```

### Exemplo 3: Teste de serviço de API

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useCompanyService } from '../company';

// Mock da função useFetch
const fetchDataMock = vi.fn();
vi.mock('../../../../composables/useFetch', () => {
  return {
    Service: {
      Core: 'core'
    },
    useFetch: () => ({
      fetchData: fetchDataMock,
      error: { value: null },
      result: { value: { data: [] } },
      loading: { value: false }
    })
  };
});

describe('useCompanyService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('getCompanys chama a API correta', async () => {
    const companyService = useCompanyService();
    await companyService.getCompanys('filter=test');
    
    expect(fetchDataMock).toHaveBeenCalledWith('get', '/company?filter=test');
  });

  it('createCompany chama a API com o payload correto', async () => {
    const companyService = useCompanyService();
    const payload = { name: 'Test Company' };
    
    await companyService.createCompany(payload);
    
    expect(fetchDataMock).toHaveBeenCalledWith('post', '/company/', payload);
  });

  // ... outros testes ...
});
```

## Executando os testes

### Executar todos os testes

```bash
npm run test
```

### Executar testes específicos

```bash
# Executar testes de um arquivo específico
npm run test -- src/components/tests/Button.spec.ts

# Executar testes com nome específico
npm run test -- -t "renderiza o botão"

# Executar testes em modo watch
npm run test -- --watch

# Ver cobertura de código
npm run test -- --coverage
```

### Depurar testes

Para depurar testes:

1. Adicione a instrução `debugger;` no código do teste
2. Execute o teste com o flag `--inspect-brk`
3. Abra o Chrome DevTools para depuração

```bash
node --inspect-brk ./node_modules/.bin/vitest src/components/tests/Button.spec.ts
```
