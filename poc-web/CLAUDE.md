<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SAG is a Delphi/Object Pascal ERP system with web migration support through UniGUI framework. The codebase supports dual compilation:
- **Desktop (VCL)**: Traditional Windows desktop application
- **Web (UniGUI)**: Web-based version using UniGUI framework

The project uses conditional compilation directives (`{$IFDEF ERPUNI}`, `{$IFDEF ERPUNI_MODAL}`, `{$IFDEF ERPUNI_FRAME}`) to generate both versions from the same codebase.

## Architecture

### Form Hierarchy
- `TsgForm` → Base form class
- `TFrmPOHeGera` / `TFrmPOHeGeraModal` → Generic header forms (depends on modal/frame mode)
- `TFrmPOHeCam6` → Dynamic form builder that creates UI from database configuration

### Dynamic Form System
Forms are built dynamically at runtime from database configuration stored in tables:
- **POCaTabe**: Table definitions (size, position, SQL queries, events)
- **POCaCamp/SistCamp**: Field definitions (type, position, validation, expressions)

Key procedure `MontCampPers` in `PlusUni.pas` creates visual components based on database configuration.

### Key Components
- **TsgQuery**: Enhanced FireDAC query component
- **TsgPnl, TsgBtn, TsgTbs, TsgPgc**: Custom panel, button, tab, and page control components
- **TMovi**: Represents movement (child) records within a form
- **TsgLeitSeri**: Serial port/IP communication for hardware integration

### Conditional Compilation
```pascal
{$IFDEF ERPUNI}        // UniGUI web version
{$ELSE}                 // VCL desktop version
{$ENDIF}

{$IFDEF ERPUNI_MODAL}  // Modal form mode
{$ELSE}                 // Frame/embedded mode
{$ENDIF}
```

### Form Configuration Flow
1. `FormCreate` → Creates movement frames, initializes database connections
2. `AfterCreate` → Builds fields from POCaCamp configuration
3. `FormShow` → Initializes values, executes OnShow scripts
4. `BtnConfClick` → Validates and saves data

## Database

- **SQL Server** database with tables prefixed by module (PO = base, MP = poultry, IN = hatchery, etc.)
- Table configuration stored in `POCaTabe` and field configuration in `POCaCamp`/`SistCamp`
- Uses FireDAC for database access

### Key Tables
- `SistCamp`: Field/component definitions for dynamic forms
- `POCaTabe`: Form/table configuration
- `POGePess`: Person/user records

## Development Guidelines

### Working with Dual Platform Code
- Always maintain both VCL and UniGUI paths in conditional blocks
- Test changes on both platforms when modifying shared code
- UniGUI uses `TUniControl` base class; VCL uses `TWinControl`

### Form Field Configuration
Fields are configured through database records with these key attributes:
- `CompCamp`: Component type (E=Edit, N=Number, S=Checkbox, C=Combo, etc.)
- `ExprCamp`: Exit event expressions/scripts
- `SQL_Camp`: SQL for dropdown queries
- `ObriCamp`: Required field flag

### Expression/Script System
The system uses a custom scripting language for field events:
- `VA-varname-value`: Variable assignment
- `CS-fieldname-value`: Set component value
- `IF-INIC/ELSE/FINA`: Conditional blocks
- `EX-SQL`: Execute SQL statement

## File Structure

- `*.pas`: Delphi source units
- `*.dfm`: Delphi form files (visual component definitions)
- `*.sql`: SQL scripts for table creation and data
- `GUIA_VISUAL_INCLUSAO_RAPIDA.md`: UI specification document for "Quick Inclusion" feature migration

## Visual Reference: Vision Design System

A pasta `Vision/` contém a documentação do design system de referência para a migração visual do SAG. O objetivo é que a interface web do SAG tenha a mesma aparência e experiência do sistema Vision.

### Documentação Disponível em Vision/docs/

```
Vision/docs/
├── guides/           # Guias de implementação
│   ├── componentImplementationGuide.md   # Templates de componentes
│   ├── crudPattern.md                    # Padrões de CRUD
│   ├── crudWithModal.md                  # CRUD com modal
│   ├── crudWithPanel.md                  # CRUD com painel
│   ├── crudWithTabsPanel.md              # CRUD com abas
│   ├── crudCommonPatterns.md             # Padrões comuns
│   └── modalUsageGuide.md                # Guia de modais
├── misc/             # Componentes específicos
│   ├── grid.md       # Grid (ag-grid)
│   ├── modal.md      # Modal centralizado
│   ├── panel.md      # Painel lateral
│   └── tabsPanel.md  # Painel com abas
└── prompts/          # Exemplos de CRUDs
```

### Princípios Visuais do Vision

#### Escolha de Componentes de Formulário
| Situação | Componente | Critério |
|----------|------------|----------|
| ≤11 campos, sem abas | **Modal** | Centralizado, responsivo |
| >11 campos, sem abas | **Panel** | Painel lateral |
| Qualquer quantidade, com abas | **TabsPanel** | Painel com navegação |

#### Componentes de Formulário
- `FormControl`: Campos de texto/número com label, placeholder, validação
- `Datepicker`: Campos de data com suporte a datetime
- `Select`: Dropdowns com busca opcional
- `Lookup`: Campos de busca com modal de seleção
- `AttachmentField`: Upload de arquivos
- `CustomMultiselect`: Seleção múltipla

#### Sistema de Layout
```vue
<!-- Colunas automáticas -->
<div class="columns">
  <div class="column">Campo 1</div>
  <div class="column">Campo 2</div>
</div>

<!-- Larguras específicas -->
<div class="columns">
  <div class="w-4/12">33%</div>
  <div class="w-8/12">67%</div>
</div>

<!-- Container com espaçamento -->
<div class="flex flex-col gap-[16px]">
  <!-- Espaçamento vertical de 16px -->
</div>
```

#### Variáveis CSS (Tema)
```scss
// Cores neutras
--neutral-white
--neutral-100, --neutral-200, --neutral-300
--neutral-600, --neutral-800

// Cores primárias
--primary-300

// Feedback
--feedback-error-100

// Bordas
border-radius: 16px;  // Modais e painéis
border-radius: 6px;   // Botões e inputs
```

#### Padrões de Validação
```vue
<!-- Campo com validação -->
<FormControl
  v-model="entity.field"
  :label="$translate('module.field.label')"
  :class="{ error: formErrors.field }"
  :help-text="formErrors.field"
  required
/>
```

#### Estados de Visualização (ViewMode)
- `create`: Novo registro
- `update`: Edição
- `view`: Somente leitura

#### Atalhos de Teclado
- `Ctrl+S`: Salvar
- `Ctrl+D`: Fechar/Cancelar
- `Ctrl+↑/↓`: Navegar entre abas (TabsPanel)

### Mapeamento SAG → Vision

| SAG (Delphi/UniGUI) | Vision (Vue 3) |
|---------------------|----------------|
| TsgEdit, TUniEdit | FormControl |
| TsgDateTimePicker | Datepicker |
| TsgComboBox | Select |
| TsgLookup | Lookup |
| TsgGrid | Grid (ag-grid) |
| TsgPgc (PageControl) | TabsPanel |
| TsgBtn | Button |
| TsgPnl | div.columns / Panel |
| TFrmPOHeGera | Panel / Modal |
| TFrmPOHeGeraModal | Modal |

### Stack Técnica Vision
- **Framework**: Vue 3 + Composition API
- **Grid**: ag-grid-vue3 / ag-grid-enterprise
- **Validação**: Zod
- **Estilização**: SCSS + CSS Variables
- **Traduções**: i18n (pt-br, en-us, es-es)
- **Fonte**: Inter
