# Guia de Implementação de Componentes - Templates Práticos

## 📋 Visão Geral

Este guia fornece templates exatos para implementação dos principais componentes utilizados nos formulários CRUD. Use estes exemplos como base para garantir implementação consistente.

### Importações que não são necessárias

No arquivo `src/utils/configs/globalComponents.ts` estão importados os componentes que mais são utilizados no projeto. Caso o componente esteja nesse arquivo, ele não tem a necessidade de ser importado na view. Caso ele não esteja nesse arquivo, ele tem a necessidade de ser importado na view.

---

## 🔧 FormControl - Campos de Texto e Número

### Uso Básico
```vue
<FormControl
  v-model="entity.fieldName"
  :label="$translate('module.entity.fields.fieldName.label')"
  :placeholder="$translate('module.entity.fields.fieldName.placeholder')"
></FormControl>
```

### Com Máscara
```vue
<FormControl
  v-model="entity.tag"
  :label="$translate('module.entity.fields.tag.label')"
  :placeholder="$translate('module.entity.fields.tag.placeholder')"
  v-mask="'AAA###'"
></FormControl>
```

### Campo Desabilitado
```vue
<FormControl
  v-model="entity.code"
  :label="$translate('module.entity.fields.code.label')"
  disabled
></FormControl>
```

### Com Limite de Caracteres
```vue
<FormControl
  v-model="entity.description"
  :label="$translate('module.entity.fields.description.label')"
  :placeholder="$translate('module.entity.fields.description.placeholder')"
  maxlength="45"
></FormControl>
```

### Com validação e obrigatóriedade
```vue
<FormControl
  v-model="entity.description"
  :label="$translate('module.entity.fields.description.label')"
  :placeholder="$translate('module.entity.fields.description.placeholder')"
  :class="{ error: formErrors.description }"
  :help-text="formErrors.description"
  required
></FormControl>
```

---

## 📅 Datepicker - Campos de Data

### Data Simples
```vue
<Datepicker
  v-model:selected-date="entity.date"
  :label="$translate('module.entity.fields.date.label')"
></Datepicker>
```

### Data e Hora
```vue
<Datepicker
  v-model:selected-date="entity.deadline"
  :label="$translate('module.entity.fields.deadline.label')"
  type="datetime"
></Datepicker>
```

### Campo desabilitado
```vue
<Datepicker
  v-model:selected-date="entity.deadline"
  :label="$translate('module.entity.fields.deadline.label')"
  disabled
></Datepicker>
```

### Com validação e obrigatóriedade
```vue
<Datepicker
  v-model:selected-date="entity.completionDate"
  :label="$translate('module.entity.fields.completionDate.label')"
  :class="{ error: formErrors.completionDate }"
  :help-text="formErrors.completionDate"
  required
></Datepicker>
```

---

## 📋 Select - Campos de Seleção

### Select Simples (Boolean)
```vue
<template>
  <Select
    v-model="entity.active"
    :label="$translate('module.entity.fields.active.label')"
    :options="boolOptions"
    key-field="value"
    value-field="id"
  ></Select>
</template>

<script script setup="ts">
const boolOptions = computed(() => [
  { id: true, value: translate('common.bool.true') },
  { id: false, value: translate('common.bool.false') },
]);
</script>
```

### Select com Opções Fixas
```vue
<template>
  <Select
    v-model="entity.severity"
    :label="$translate('module.entity.fields.severity.label')"
    :options="options"
    key-field="value"
    value-field="id"
  ></Select>
</template>

<script script setup="ts">
const options = computed(() => [
  { id: 'low', value: $translate('module.entity.severity.low') },
  { id: 'medium', value: $translate('module.entity.severity.medium') },
  { id: 'high', value: $translate('module.entity.severity.high') }
]);
</script>
```

### Select com pesquisa
```vue
<Select
  v-model="entity.moduleId"
  :options="modules"
  :label="$translate('module.entity.fields.module.label')"
  :placeholder="$translate('module.entity.fields.module.placeholder')"
  value-field="id"
  key-field="description"
  :searchable="true"
></Select>
```

### Select com obrigatóriedade e validação
```vue
<Select
  v-model="entity.moduleId"
  :options="modules"
  :label="$translate('module.entity.fields.module.label')"
  :placeholder="$translate('module.entity.fields.module.placeholder')"
  value-field="description"
  key-field="id"
  :class="{ error: formErrors.moduleId }"
  :help-text="formErrors.moduleId"
  required
></Select>
```

---

## 🔍 Lookup - Campos de Busca

### Lookup Básico
```vue
<Lookup
  v-model="entity.responsibleUserName"
  :columnDefs="lookupUserColumnDefs"
  :service-type="Service.Core"
  entity-name="User"
  value-field="name"
  :visible-fields="['id', 'name', 'email']"
  :label="translate('module.entity.fields.user.label')"
  :model-title="translate('module.entity.fields.user.label')"
  :placeholder="$translate('module.entity.fields.user.placeholder')"
  :class="{ error: formErrors.responsibleUserId }"
  :help-text="formErrors.responsibleUserId"
  @onSelect="handleUserSelect"
></Lookup>
```

### Lookup com Configuração Completa
```vue
<Lookup
  v-model="entity.productionSectorDescription"
  :columnDefs="lookupSectorColumnDefs"
  :service-type="Service.Core"
  entity-name="ProductionSector"
  value-field="description"
  :visible-fields="['code', 'description']"
  :placeholder="$translate('module.entity.fields.sector.placeholder')"
  :label="translate('module.entity.fields.sector.label')"
  :model-title="translate('module.entity.fields.sector.label')"
  :disabled="state.viewMode === 'view'"
  @onSelect="(item) => entity.productionSectorId = item.id"
></Lookup>
```

### Lookup com obrigatóriedade e validação
```vue
<Lookup
  v-model="entity.productionSectorDescription"
  :columnDefs="lookupSectorColumnDefs"
  :service-type="Service.Core"
  entity-name="ProductionSector"
  value-field="description"
  :visible-fields="['code', 'description']"
  :placeholder="$translate('module.entity.fields.sector.placeholder')"
  :label="translate('module.entity.fields.sector.label')"
  :model-title="translate('module.entity.fields.sector.label')"
  :class="{ error: formErrors.productionSectorId }"
  :help-text="formErrors.productionSectorId"
  required
  @onSelect="(item) => entity.productionSectorId = item.id"
></Lookup>
```

### Definição de Colunas para Lookup
```typescript
const lookupUserColumnDefs = [
  { headerName: translate('common.fields.code'), field: "id", flex: 1, sortable: true },
  { headerName: translate('common.fields.name'), field: "name", flex: 2, sortable: true },
  { headerName: translate('common.fields.email'), field: "email", flex: 2, sortable: true }
];

const lookupSectorColumnDefs = [
  { headerName: translate('common.fields.code'), field: "code", flex: 1, sortable: true },
  { headerName: translate('common.fields.description'), field: "description", flex: 2, sortable: true }
];
```

---

## 📎 AttachmentField - Campos de Anexo

### Anexo Simples
```vue
<AttachmentField
  :items="entity.evidences"
  :label="$translate('module.entity.fields.evidences.label')"
  :disabled="entity.status === 3"
  @update:files="entity.evidences = $event"
></AttachmentField>
```

### Anexo Múltiplo
```vue
<AttachmentField
  :items="entity.attachments"
  :label="$translate('module.entity.fields.attachments.label')"
  :disabled="state.viewMode === 'view'"
  :multiple="true"
  :accept="'.pdf,.doc,.docx,.jpg,.png'"
  @update:files="entity.attachments = $event"
></AttachmentField>
```

### Com Validação
```vue
<AttachmentField
  :items="entity.documents"
  :label="$translate('module.entity.fields.documents.label')"
  :disabled="state.viewMode === 'view'"
  :class="{ error: formErrors.documents }"
  :help-text="formErrors.documents"
  :multiple="true"
  required
  @update:files="entity.documents = $event"
></AttachmentField>
```

---

## 🔢 CustomMultiselect - Seleção Múltipla

### Multiselect Básico
```vue
<CustomMultiselect
  v-model="entity.categories"
  :options="categoriesList"
  :label="$translate('module.entity.fields.categories.label')"
  :placeholder="$translate('module.entity.fields.categories.placeholder')"
  :searchable="true"
></CustomMultiselect>
```

### Multiselect com Configuração Avançada
```vue
<CustomMultiselect
  v-model="entity.permissions"
  :options="permissionsList"
  :label="$translate('module.entity.fields.permissions.label')"
  :placeholder="$translate('module.entity.fields.permissions.placeholder')"
  :searchable="true"
  :disabled="state.viewMode === 'view'"
  :class="{ error: formErrors.permissions }"
  :help-text="formErrors.permissions"
  key-field="id"
  value-field="description"
  required
></CustomMultiselect>
```

---

## 📐 Layout e Estrutura

### Estrutura de Colunas
```vue
<div class="columns">
  <div class="column">
    <!-- Componente 1 -->
  </div>

  <div class="column">
    <!-- Componente 2 -->
  </div>
</div>
```

### Colunas com Tamanhos Específicos
```vue
<div class="columns">
  <div class="w-4/12">
    <!-- 33% da largura -->
  </div>

  <div class="w-4/12">
    <!-- 33% da largura -->
  </div>

  <div class="w-4/12">
    <!-- 33% da largura -->
  </div>
</div>
```

### Container Principal
```vue
<div class="flex flex-col gap-[16px]">
  <!-- Conteúdo com espaçamento vertical de 16px -->
</div>

<div class="flex flex-col gap-[20px]">
  <!-- Conteúdo com espaçamento vertical de 20px -->
</div>
```

---

## 🎯 Padrões de Validação

### Estrutura de Erro nos Componentes
```vue
:class="{ error: formErrors.fieldName }"
:help-text="formErrors.fieldName"
```

### Campos Obrigatórios
```vue
required
```

### Estados de Desabilitado
```vue
:disabled="state.viewMode === 'view'"
:disabled="entity.status === 3"
:disabled="entity.status === 'Finished'"
```

---

## 📝 Importações Necessárias

### Imports para Services
```typescript
import { Service } from '@/composables/useFetch';
```

---

## ⚠️ Regras Importantes

1. **Sempre use v-model** para reatividade
2. **Inclua traduções** para labels e placeholders
3. **Adicione validações** com formErrors quando necessário
4. **Configure estados** de disabled baseado no viewMode
5. **Use classes de erro** para feedback visual
6. **Mantenha consistência** na estrutura de colunas
7. **Configure lookups** com columnDefs apropriadas
8. **Trate eventos** como @onSelect para lookups
9. **Use Service enum** para service-type em lookups
10. **Mantenha padrões** de nomenclatura em campos
