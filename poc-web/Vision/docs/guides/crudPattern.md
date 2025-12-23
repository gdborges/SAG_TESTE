# Guias de CRUD - Frontend v2

Esta pasta contém guias completos para implementação de CRUDs no projeto Frontend v2, baseados na análise de componentes existentes e padrões estabelecidos.

## 📁 Guias Disponíveis

### 1. [CRUD com TabsPanel](./crudWithTabsPanel.md)
**Quando usar**: Interfaces complexas com múltiplas abas e funcionalidades avançadas.

**Características**:
- Múltiplas abas com conteúdo específico
- Configuração de botões por aba
- Controle de estado entre abas
- Ideal para entidades com muitos campos ou relacionamentos

**Exemplos no projeto**: `users.vue`, `non-compliance.vue`

### 2. [CRUD com Modal](./crudWithModal.md)
**Quando usar**: Formulários simples com poucos campos.

**Características**:
- Interface limpa e direta
- Formulário único
- Ideal para CRUDs básicos
- Rápido de implementar

**Exemplos no projeto**: `windows.vue`, `cities.vue`

### 3. [CRUD com Panel](./crudWithPanel.md)
**Quando usar**: Interfaces que precisam de controle total sobre layout e comportamento.

**Características**:
- Header, body e footer customizáveis
- InfoBox para informações contextuais
- Botões específicos no footer
- Controle de mudanças no formulário
- Ideal para processos complexos

**Exemplos no projeto**: `occurrence-note.vue`

### 4. [Padrões Comuns](./crudCommonPatterns.md)
**Referência geral**: Estruturas, convenções e padrões utilizados em todos os tipos de CRUD.

**Conteúdo**:
- Estrutura de arquivos
- Imports padrão
- Validação com Zod
- Funções CRUD base
- Tratamento de erros
- Convenções de nomenclatura

## 🎯 Como Escolher o Componente Certo

### Use **TabsPanel** quando:
- ✅ Entidade tem múltiplas seções de dados
- ✅ Precisa de abas com funcionalidades específicas
- ✅ Há relacionamentos complexos (usuários → empresas → grupos → recursos)
- ✅ Cada aba tem botões específicos
- ✅ Algumas abas só funcionam em modo de edição

### Use **Modal** quando:
- ✅ Formulário simples com poucos campos
- ✅ CRUD básico sem complexidades
- ✅ Interface limpa e direta
- ✅ Implementação rápida

### Use **Panel** quando:
- ✅ Precisa de controle total sobre o layout
- ✅ Tem informações contextuais (InfoBox)
- ✅ Botões customizados no footer
- ✅ Validações complexas de regra de negócio
- ✅ Estados específicos (aprovado, reprovado, etc.)

## 🛠️ Estrutura Base de Qualquer CRUD

Independente do componente escolhido, todo CRUD deve ter:

```typescript
// 1. Estado base
interface State {
  openModal: boolean;
  showDeleteModal: boolean;
  isLoadingButton: boolean;
  viewMode: ViewMode;
}

// 2. Entidade reativa
const [entity]: [Entity] = reactive({ ...initial[Entity] });

// 3. Validação Zod
const [entity]Schema = z.object({...});

// 4. Funções CRUD
function view[Entity]() {}
async function create[Entity]() {}
async function update[Entity]() {}
async function delete[Entity]() {}
async function get[Entity]() {}
function resetFields() {}

// 5. Grid configuration
const colsDefs = computed(() => [...]);
const headerProps: GridHeaderProps = reactive({...});

// 6. Exception handling
const { onException, onSuccess, onValidateErrors } = useExceptionHandler();
```

## 📋 Checklist de Implementação

### Antes de Começar
- [ ] Definir qual componente usar (TabsPanel/Modal/Panel)
- [ ] Analisar a complexidade da entidade
- [ ] Verificar relacionamentos necessários
- [ ] Definir validações de regra de negócio

### Durante a Implementação
- [ ] Seguir a estrutura do guia específico
- [ ] Implementar todas as funções CRUD
- [ ] Configurar validação Zod
- [ ] Implementar tratamento de erros
- [ ] Testar todos os cenários

### Após a Implementação
- [ ] Verificar responsividade
- [ ] Testar validações
- [ ] Verificar traduções
- [ ] Documentar particularidades
- [ ] Criar testes unitários

## 🔧 Utilitários e Helpers

### Services Padrão
```typescript
const [entity]Service = use[Entity]Service();
const { onException, onSuccess, onValidateErrors } = useExceptionHandler();
const translate = inject("$translate") as (key: string) => string;
```

### Formatação Comum
```typescript
import { formatDate } from '../../../utils/helpers/date';
import { useCurrencyFormatter } from '../../../composables/useCurrencyFormatter';
```

### Validação
```typescript
import { z } from 'zod';
// Sempre usar onValidateErrors para consistência
if (!onValidateErrors(validationResult, formErrors)) {
  return onException(validationResult.error, translate('errors.validationError'));
}
```

## 📝 Convenções de Nomenclatura

- **Arquivos**: `kebab-case` (ex: `user-profile.vue`)
- **Componentes**: `PascalCase` (ex: `UserProfile`)
- **Variáveis**: `camelCase` (ex: `userName`)
- **Funções**: `camelCase` com verbo (ex: `createUser`)
- **Interfaces**: `PascalCase` (ex: `UserInterface`)
- **Enums**: `PascalCase` (ex: `UserStatus`)

## 🚀 Próximos Passos

1. Escolha o guia apropriado para seu CRUD
2. Siga a estrutura passo a passo
3. Adapte conforme necessário
4. Teste todas as funcionalidades
5. Documente particularidades

---

**Nota**: Estes guias foram criados baseados na análise de componentes existentes no projeto e seguem os padrões estabelecidos. Para dúvidas ou sugestões, consulte os exemplos práticos nos arquivos mencionados.
