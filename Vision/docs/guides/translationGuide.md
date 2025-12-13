# Guia de Sistema de Traduções

## Visão Geral

O sistema de traduções da aplicação está implementado utilizando o padrão i18n (internacionalização) e permite o suporte para múltiplos idiomas. Este documento explica como o sistema está organizado, como adicionar novas traduções e como utilizá-las nos componentes Vue.

## Estrutura de Arquivos

### Diretórios e Arquivos Principais

```
src/translations/
├── index.ts                  # Ponto de entrada para as traduções
└── locales/
    ├── pt-br/                # Traduções em Português do Brasil
    │   ├── common.json       # Textos comuns da aplicação
    │   ├── components.json   # Traduções específicas de componentes
    │   ├── grid.json         # Traduções relacionadas ao grid
    │   ├── routes.json       # Nomes traduzidos de rotas
    │   ├── index.ts          # Arquivo que combina as traduções
    │   ├── [modulo]/         # Traduções específicas do módulo Security
    │   │   ├── entities.json # Entidades do módulo Security separados pela tag da janela correpondente
    │   │   ├── errors.json   # Mensagens de erro do módulo separados pela tag da janela correpondente
    │   │   └── labels.json   # Rótulos e textos da interface separados pela tag da janela correpondente
    │   │  
    ├── en-us/                # Traduções em Inglês (EUA)
    │   └── [estrutura similar]
    └── es-es/                # Traduções em Espanhol (Espanha)
        └── [estrutura similar]
```

### Arquivos de Tradução

Cada arquivo JSON contém uma estrutura hierárquica de chaves e valores que representam as traduções.

#### Arquivos Globais

1. **common.json**: Contém textos gerais utilizados em toda a aplicação
   - Botões comuns (Salvar, Cancelar, etc)
   - Mensagens de erro/sucesso
   - Títulos de seções comuns
   
2. **components.json**: Contém traduções específicas para componentes
   - Rótulos de campos em formulários
   - Mensagens específicas de componentes
   
3. **grid.json**: Traduções relacionadas aos componentes de grid
   - Cabeçalhos de colunas genéricas
   - Mensagens de paginação
   
4. **routes.json**: Traduções para nomes de rotas e navegação
   - Títulos de páginas
   - Itens do menu

#### Arquivos Específicos por Módulo

Cada módulo (security, production, register, commercial, mypac) possui sua própria pasta com arquivos específicos:

1. **entities.json**: Traduções para campos de entidades do módulo
   - Nomes de campos em tabelas do banco de dados
   - Atributos de objetos específicos do módulo
   - Exemplo: `entities.cad074.username`: "Usuário" (tradução para o campo username da tabela cad074)

2. **errors.json**: Mensagens de erro específicas do módulo
   - Validações de formulários
   - Erros de regras de negócio
   - Exceções específicas do módulo
   - Exemplo: `errors.cad074.createError`: "Falha ao criar um novo usuário." (tradução de erro ao criar um novo usuário da tela cad074)

3. **labels.json**: Textos e rótulos da interface do módulo
   - Títulos de telas
   - Rótulos de abas
   - Mensagens específicas
   - Textos de ajuda
   - Exemplo: `security.cad074.title`: "Cadastro de Usuários"

## Configuração e Inicialização

O sistema de traduções é configurado no arquivo `src/plugins/i18n.ts` e registrado como um plugin Vue. As principais responsabilidades deste plugin são:

1. Carregar as traduções globais dos arquivos JSON comuns
2. Carregar as traduções específicas do módulo selecionado
3. Fornecer funções para tradução e troca de idioma
4. Integrar com o Vue para disponibilizar as funções de tradução em todos os componentes

### Carregamento de Traduções por Módulo

O sistema carrega dinamicamente as traduções com base no módulo selecionado pelo usuário:

1. O módulo atualmente selecionado é armazenado em `localStorage` como parte do `sessionInfo`
2. Quando o usuário muda de módulo, as traduções são recarregadas automaticamente
3. A função `loadModuleTranslations` importa dinamicamente os arquivos corretos:
   - `labels.json` do módulo selecionado
   - `errors.json` do módulo selecionado
   - `entities.json` do módulo selecionado

Se um módulo não possuir um dos arquivos ou se o módulo não existir, o sistema registra um erro no console, mas continua funcionando com as traduções disponíveis.

## Como Adicionar Novas Traduções

### 1. Adicionando Novas Chaves de Tradução

Para adicionar uma nova tradução, localize o arquivo apropriado no diretório `src/translations/locales/{idioma}/` e adicione a nova chave com seu valor traduzido:

**Exemplo para o arquivo `pt-br/common.json`**:

```json
{
  "common": {
    "buttons": {
      "submit": "Enviar"
    }
  }
}
```

### 2. Estrutura de Chaves

As chaves de tradução seguem uma estrutura hierárquica com pontos (`.`) como separadores:

- **Entidades**: `entities.{entidade}.{campo}`
- **Componentes**: `components.{componente}.{elemento}`
- **Rotas**: `routes.{módulo}.{rota}.{propriedade}`
- **Comum**: `common.{categoria}.{elemento}`

### 3. Tradução para Múltiplos Idiomas

Após adicionar uma tradução em um idioma, certifique-se de adicionar a mesma chave nos outros idiomas suportados para manter a consistência.

## Como Usar Traduções nos Componentes Vue

### 1. Acessando o Serviço de Tradução

Em componentes Vue, a função de tradução está disponível através de injeção de dependência:

```typescript
// Em componentes Vue Setup
const { translate } = inject("i18n") as I18nContext;
```

### 2. Traduzindo Textos

Use a função `translate()` com a chave de tradução para obter o texto traduzido:

```typescript
// Exemplo de uso no componente
const buttonLabel = translate('common.buttons.save');
```

### 3. Utilizando em Templates

Você pode usar a função diretamente nos templates:

```vue
<template>
  <button>{{ $translate('common.buttons.save') }}</button>
</template>
```

Obs: Caso você utilize apenas dentro da tag "template", a importação ou injeção não é necessária, pois ele se torna um plugin global.

## Exemplo Prático: View reject-package.vue

A view `src/views/private/production/reject-package.vue` demonstra o uso de traduções em uma tabela de grid:

```vue
<template>
  <div class="page-reject-package">
    <Grid
      ref="gridProductionNote"
      :column-defs="colsDefs"
      :template-service="getRejectPackagesByCriteria"
      :criteria-service="getRejectPackagesCriteria"
      :hide-edit-button="true"
      :hide-delete-button="true"
      :is-loading="loading"
      :enable-pivot-mode="true"
      :visible-button-add="false"
      :enable-body-scroll="true"
    ></Grid>
  </div>
</template>

<script setup lang="ts">
import Grid from '../../../components/grid/Grid.vue';
import { ValueFormatterParams } from 'ag-grid-enterprise';
import { I18nContext } from '../../../plugins/i18n';
import { useRejectPackageService } from '../../../server/api/reading/rejectPackage';
import { formatDate } from '../../../utils/helpers/date';

const { getRejectPackagesByCriteria, getRejectPackagesCriteria, loading } = useRejectPackageService();
const { translate } = inject("i18n") as I18nContext;

const colsDefs = computed(() => [
  { 
    headerName: translate('entities.pro290.empresa'), 
    field: "empresa", 
    flex: 1, 
    sortable: true, 
    cellDataType: "text" 
  },
  { 
    headerName: translate('entities.pro290.filial'), 
    field: "filial", 
    flex: 1, 
    sortable: true, c
    ellDataType: "number" 
    },
  // Mais colunas...
]);
</script>
```

### Análise do Exemplo:

1. **Importação e Injeção**:
  ```typescript
  import { I18nContext } from '../../../plugins/i18n';
  const { translate } = inject("i18n") as I18nContext;
  ```

2. **Uso da Tradução**:
  ```typescript
  { 
    headerName: translate('entities.pro290.empresa'), 
    field: "empresa", 
    ... 
  }
  ```
  
  Aqui, o componente está buscando a tradução para `entities.pro290.empresa`, que estaria definida no arquivo `production/entities.json` pois:
  - Este componente pertence ao módulo de produção (`production`)
  - Está usando traduções de entidades (`entities`)
  - Referenciando a tabela `pro290`
  - Campo específico `empresa`

3. **Carregamento específico por módulo**:
  Quando o usuário está no módulo de produção, o sistema carrega automaticamente as traduções do diretório `production/`, tornando as chaves `entities.pro290.*` disponíveis para este componente.

## Regras Críticas de Tradução

### 1. Parâmetro [code] - SEMPRE MINÚSCULO

**PROBLEMA IDENTIFICADO**: O parâmetro `[code]` usado nas views às vezes é criado em maiúsculo, mas nos arquivos JSON de tradução deve SEMPRE ser minúsculo.

**REGRA OBRIGATÓRIA**:
- ✅ **CORRETO**: `cad001`, `cad002`, `pro107`, `sct003`
- ❌ **INCORRETO**: `CAD001`, `CAD002`, `PRO107`, `SCT003`

**Exemplos de uso correto**:
```typescript
// Na view - SEMPRE minúsculo
translate('entities.cad001.code')
translate('errors.cad001.createError')
translate('security.cad001.title')

// Nos arquivos JSON - SEMPRE minúsculo
{
  "entities": {
    "cad001": {
      "code": "Código",
      "name": "Nome"
    }
  },
  "errors": {
    "cad001": {
      "createError": "Erro ao criar usuário"
    }
  }
}
```

### 2. Traduções para Componentes Lookup

**PROBLEMA IDENTIFICADO**: CRUDs que possuem a propriedade `code` precisam de traduções adicionais para os cabeçalhos dos grids nos componentes Lookup.

**REGRA OBRIGATÓRIA**: Para entidades que possuem a propriedade `code`, adicione traduções no arquivo `components.json`:

**Localização**: `src/translations/locales/{idioma}/components.json`

**Estrutura obrigatória**:
```json
{
  "components": {
    "lookup": {
      "entities": {
        "{nomeEntidadeMinusculo}": {
          "code": "Código",
          "name": "Nome",
          "description": "Descrição",
          // ... outros campos da entidade
        }
      }
    }
  }
}
```

**Exemplo prático**:
```json
{
  "components": {
    "lookup": {
      "entities": {
        "user": {
          "code": "Código",
          "name": "Nome do Usuário",
          "email": "Email",
          "isActive": "Usuário Ativo"
        },
        "company": {
          "code": "Código",
          "name": "Nome da Empresa",
          "cnpj": "CNPJ",
          "isActive": "Empresa Ativa"
        }
      }
    }
  }
}
```

**Implementação nos 3 idiomas obrigatórios**:
- `pt-br/components.json`
- `en-us/components.json` 
- `es-es/components.json`

## Boas Práticas

1. **Organização de Chaves**:
   - Use prefixos consistentes (`entities`, `components`, etc.)
   - Agrupe traduções relacionadas
   - Use nomes descritivos para as chaves

2. **Evitar Hardcoding**:
   - Nunca escreva textos diretamente nos componentes
   - Use sempre a função `translate()`

3. **Manutenção**:
   - Mantenha todos os idiomas sincronizados
   - Adicione comentários explicativos para chaves complexas

4. **Testes**:
   - Verifique se todas as traduções existem em todos os idiomas
   - Teste a interface em diferentes idiomas

5. **Consistência do [code]**:
   - SEMPRE use minúsculo para o parâmetro [code]
   - Verifique tanto na view quanto nos arquivos JSON
   - Use ferramentas de busca para validar consistência

6. **Traduções de Lookup**:
   - Para entidades com propriedade `code`, adicione traduções em `components.lookup.entities`
   - Mantenha a mesma estrutura nos 3 idiomas
   - Use o nome da entidade em minúsculo como chave

## Alterando o Idioma da Aplicação

O sistema suporta a troca dinâmica de idioma. O idioma padrão é definido como "pt-br", mas pode ser alterado usando a função `setLanguage`:

```typescript
const { setLanguage } = inject("i18n") as I18nContext;

// Mudar para inglês
await setLanguage("en-us");
```

## Adicionando um Novo Idioma

Para adicionar suporte a um novo idioma:

1. Crie um novo diretório em `src/translations/locales/` com o código do idioma (ex: `fr-fr`)
2. Copie os arquivos JSON de um idioma existente e traduza os valores
3. Adicione o novo idioma ao arquivo `src/translations/index.ts`:

```typescript
import pt from "./locales/pt-br/index";
import en from "./locales/en-us/index";
import fr from "./locales/fr-fr/index";

export const translations = {
  pt,
  en,
  fr
};
```

## Considerações Técnicas

1. **Carregamento Dinâmico**:
   - As traduções são carregadas dinamicamente por meio do `import.meta.glob`
   - O sistema pode carregar traduções remotas do servidor

2. **Chaves Aninhadas**:
   - O sistema suporta chaves aninhadas com notação de ponto
   - Ex: `common.buttons.save` acessa `{ common: { buttons: { save: "Salvar" } } }`

3. **Fallback**:
   - Se uma chave não for encontrada, o sistema retornará a própria chave
   - Isso ajuda a identificar traduções faltantes

4. **Integração com Vue**:
   - O sistema é registrado como um plugin Vue
   - As funções de tradução estão disponíveis em todos os componentes
