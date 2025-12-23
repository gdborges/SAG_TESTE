# Project Context

## Purpose
SAG é um sistema ERP (Enterprise Resource Planning) desenvolvido em Delphi/Object Pascal, focado em gestão empresarial com módulos especializados para diferentes setores (avicultura, incubatório, etc.). O projeto está em processo de migração para web através do framework UniGUI, mantendo compatibilidade com a versão desktop VCL.

**Objetivos principais:**
- Manter uma base de código única que compila para desktop (VCL) e web (UniGUI)
- Preservar toda a lógica de negócio existente durante a migração
- Oferecer interface web moderna sem reescrever o sistema do zero

## Tech Stack
- **Linguagem**: Delphi/Object Pascal
- **Framework Desktop**: VCL (Visual Component Library)
- **Framework Web**: UniGUI
- **Banco de Dados**: SQL Server
- **Acesso a Dados**: FireDAC
- **IDE**: Embarcadero RAD Studio

### Componentes Customizados
- `TsgQuery`: Query FireDAC estendida
- `TsgPnl`, `TsgBtn`, `TsgTbs`, `TsgPgc`: Componentes visuais customizados
- `TsgLeitSeri`: Comunicação serial/IP para integração com hardware

## Project Conventions

### Code Style
- **Prefixos de tabelas**: Módulos identificados por prefixo (PO = base, MP = avicultura, IN = incubatório)
- **Nomenclatura de componentes**: Prefixo indica tipo (Btn = Button, Pnl = Panel, Edt = Edit)
- **Nomenclatura de campos**: Sufixo `Camp` para campos de configuração
- **Forms**: Prefixo `TFrm` para classes de formulário

### Architecture Patterns
**Hierarquia de Forms:**
```
TsgForm (base)
  └── TFrmPOHeGera / TFrmPOHeGeraModal (forms genéricos)
        └── TFrmPOHeCam6 (construtor dinâmico de UI)
```

**Sistema de Forms Dinâmicos:**
- Forms construídos em runtime a partir de configuração no banco de dados
- `POCaTabe`: Definições de tabelas (tamanho, posição, SQL, eventos)
- `POCaCamp`/`SistCamp`: Definições de campos (tipo, posição, validação, expressões)
- Procedure `MontCampPers` em `PlusUni.pas` cria componentes visuais

**Compilação Condicional:**
```pascal
{$IFDEF ERPUNI}        // Versão UniGUI web
{$ELSE}                // Versão VCL desktop
{$ENDIF}

{$IFDEF ERPUNI_MODAL}  // Modo modal
{$ELSE}                // Modo frame/embedded
{$ENDIF}
```

### Testing Strategy
- Testes manuais em ambas as plataformas (VCL e UniGUI)
- Validação de mudanças em código compartilhado deve cobrir ambos os targets

### Git Workflow
- Commits devem indicar se afetam VCL, UniGUI ou ambos
- Mudanças em arquivos `.pas` compartilhados requerem atenção especial aos blocos condicionais

## Domain Context
**Sistema de Expressões/Scripts:**
O sistema usa uma linguagem de script customizada para eventos de campos:
- `VA-varname-value`: Atribuição de variável
- `CS-fieldname-value`: Define valor de componente
- `IF-INIC/ELSE/FINA`: Blocos condicionais
- `EX-SQL`: Executa SQL

**Tipos de Componentes (CompCamp):**
- `E` = Edit (texto)
- `N` = Number (numérico)
- `S` = Checkbox
- `C` = Combo (dropdown)

**Fluxo de Configuração de Form:**
1. `FormCreate` → Cria frames de movimento, inicializa conexões
2. `AfterCreate` → Constrói campos da configuração POCaCamp
3. `FormShow` → Inicializa valores, executa scripts OnShow
4. `BtnConfClick` → Valida e salva dados

## Important Constraints
- **Compatibilidade dual**: Código deve funcionar em VCL e UniGUI
- **UniGUI usa `TUniControl`** como base; **VCL usa `TWinControl`**
- **Configuração em banco**: Muitas funcionalidades dependem de registros nas tabelas de configuração
- **Sistema legado**: Mudanças devem preservar comportamento existente

## External Dependencies
- **SQL Server**: Banco de dados principal
- **Hardware serial/IP**: Integração via `TsgLeitSeri` para dispositivos externos
- **UniGUI Server**: Servidor de aplicação para versão web

## Design System de Referência: Vision

A pasta `Vision/` contém a documentação completa do design system que serve como referência visual para o SAG. O objetivo é que a interface web do SAG tenha a mesma aparência e experiência do sistema Vision.

### Stack Técnica Vision
| Tecnologia | Descrição |
|------------|-----------|
| Vue 3 | Framework JavaScript com Composition API |
| ag-grid-vue3 | Grid de dados enterprise |
| Zod | Validação de schemas |
| SCSS | Estilização com variáveis CSS |
| i18n | Internacionalização (pt-br, en-us, es-es) |
| Inter | Fonte padrão |

### Componentes Principais

#### Containers de Formulário
| Componente | Quando Usar | Características |
|------------|-------------|-----------------|
| **Modal** | ≤11 campos, sem abas | Centralizado, responsivo, overlay |
| **Panel** | >11 campos, sem abas | Painel lateral, breadcrumb, mantém contexto |
| **TabsPanel** | Qualquer quantidade, com abas | Navegação hierárquica, sub-abas, atalhos |

#### Componentes de Campo
| Componente | Tipo | Props Principais |
|------------|------|------------------|
| `FormControl` | Texto/Número | `v-model`, `label`, `placeholder`, `required`, `maxlength`, `disabled` |
| `Datepicker` | Data/DateTime | `v-model:selected-date`, `label`, `type` |
| `Select` | Dropdown | `v-model`, `options`, `key-field`, `value-field`, `searchable` |
| `Lookup` | Busca com modal | `v-model`, `columnDefs`, `entity-name`, `service-type`, `@onSelect` |
| `AttachmentField` | Upload | `:items`, `@update:files`, `multiple`, `accept` |
| `CustomMultiselect` | Seleção múltipla | `v-model`, `options`, `searchable` |

### Sistema de Layout

```vue
<!-- Grid de colunas automáticas -->
<div class="columns">
  <div class="column"><!-- 50% --></div>
  <div class="column"><!-- 50% --></div>
</div>

<!-- Colunas com largura específica (12 colunas) -->
<div class="columns">
  <div class="w-4/12"><!-- 33.3% --></div>
  <div class="w-8/12"><!-- 66.6% --></div>
</div>

<!-- Container com espaçamento -->
<div class="flex flex-col gap-[16px]">
  <!-- Gap vertical de 16px -->
</div>
```

### Variáveis CSS (Tema)

```scss
// Cores Neutras
--neutral-white: #FFFFFF;
--neutral-100: #F5F5F5;
--neutral-200: #E5E5E5;
--neutral-300: #D4D4D4;
--neutral-600: #525252;
--neutral-800: #262626;

// Cores Primárias
--primary-300: #447BDA;

// Feedback
--feedback-error-100: #EA4335;

// Bordas
border-radius: 16px;  // Modais, painéis
border-radius: 6px;   // Botões, inputs, tabs
```

### Padrões de Validação

```vue
<!-- Campo com validação e obrigatoriedade -->
<FormControl
  v-model="entity.fieldName"
  :label="$translate('module.entity.fields.fieldName.label')"
  :placeholder="$translate('module.entity.fields.fieldName.placeholder')"
  :class="{ error: formErrors.fieldName }"
  :help-text="formErrors.fieldName"
  required
/>
```

**Validação com Zod:**
```typescript
const entitySchema = z.object({
  name: z.string().nonempty(translate('errors.validation.name.required')),
  code: z.number().min(1, translate('errors.validation.code.min')),
  date: z.string({ required_error: translate('errors.validation.date.required') }),
});

const formErrors = reactive<{ [key: string]: string }>({});
```

### Estados de Visualização (ViewMode)

| Estado | Descrição | Botões |
|--------|-----------|--------|
| `create` | Novo registro | Salvar |
| `update` | Edição | Salvar, Deletar |
| `view` | Somente leitura | Nenhum (campos disabled) |

### Atalhos de Teclado

| Atalho | Ação |
|--------|------|
| `Ctrl+S` | Salvar |
| `Ctrl+D` | Fechar/Cancelar |
| `Ctrl+↑` | Aba anterior (TabsPanel) |
| `Ctrl+↓` | Próxima aba (TabsPanel) |

### Configuração de Grid (ag-grid)

```typescript
const columnDefs = computed(() => [
  { headerName: 'Código', field: 'code', flex: 1, sortable: true, cellDataType: 'number' },
  { headerName: 'Nome', field: 'name', flex: 2, sortable: true, cellDataType: 'text' },
  {
    headerName: 'Data',
    field: 'createdAt',
    flex: 1,
    valueFormatter: (p) => formatDate(p.value),
    cellDataType: 'date'
  },
  { headerName: 'Ativo', field: 'active', flex: 1, cellDataType: 'boolean' },
]);

const headerProps: GridHeaderProps = reactive({
  newItem: viewEntity  // Função chamada ao clicar em "Novo"
});
```

### Estrutura de Arquivos CRUD

```
src/views/private/[module]/
├── [entity].vue              # Tela principal (Grid + Modal/Panel)
├── [entity]/                 # Para TabsPanel
│   ├── [entity].vue          # Tela principal
│   ├── details.vue           # Aba de detalhes
│   └── other-tab.vue         # Outras abas
└── tests/
    └── [entity].spec.ts      # Testes unitários
```

### Mapeamento SAG → Vision

| Componente SAG (Delphi/UniGUI) | Equivalente Vision (Vue 3) |
|--------------------------------|----------------------------|
| `TsgEdit`, `TUniEdit` | `FormControl` |
| `TsgDateTimePicker` | `Datepicker` |
| `TsgComboBox` | `Select` |
| `TsgLookup` | `Lookup` |
| `TsgGrid`, `TUniDBGrid` | `Grid` (ag-grid) |
| `TsgPgc` (PageControl) | `TabsPanel` |
| `TsgBtn`, `TUniButton` | `Button` |
| `TsgPnl`, `TUniPanel` | `div.columns` / `Panel` |
| `TFrmPOHeGera` | `Panel` |
| `TFrmPOHeGeraModal` | `Modal` |
| `TsgCheckBox` | `Checkbox` / `Select` (boolean) |
| `TMovi` (movimento) | Componente de aba / seção |

### Documentação Detalhada

Consulte os arquivos em `Vision/docs/` para guias completos:

| Arquivo | Conteúdo |
|---------|----------|
| `guides/componentImplementationGuide.md` | Templates de todos os componentes |
| `guides/crudPattern.md` | Visão geral dos padrões CRUD |
| `guides/crudWithModal.md` | CRUD com Modal (formulários simples) |
| `guides/crudWithPanel.md` | CRUD com Panel (formulários extensos) |
| `guides/crudWithTabsPanel.md` | CRUD com TabsPanel (formulários com abas) |
| `guides/crudCommonPatterns.md` | Padrões comuns (validação, estado, etc.) |
| `misc/grid.md` | Documentação do Grid |
| `misc/modal.md` | Documentação do Modal |
| `misc/panel.md` | Documentação do Panel |
| `misc/tabsPanel.md` | Documentação do TabsPanel |
