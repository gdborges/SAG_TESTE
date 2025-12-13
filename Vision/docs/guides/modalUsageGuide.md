# Documentação dos Componentes Modal

Esta documentação abrange os três principais componentes de modal do sistema: **Modal**, **Panel** e **TabsPanel**.

## 📚 Documentação Completa

### Componentes Individuais
- **[Modal.vue](../misc/modal.md)** - Modal centralizado com redimensionamento automático
- **[Panel.vue](../misc/panel.md)** - Painel lateral simples para formulários básicos  
- **[TabsPanel.vue](../misc/tabsPanel.md)** - Painel com sistema de abas para formulários complexos

## 🚀 Início Rápido

### Modal - Para formulários até 11 campos sem abas
```vue
<Modal :open="showModal" @close-modal="showModal = false">
  <template #header>Título</template>
  <template #body>Conteúdo</template>
</Modal>
```

### Panel - Para formulários com mais de 11 campos sem abas
```vue
<Panel :open="showPanel" breadcrumb-main="Lista" @close-panel="showPanel = false">
  <template #body>Formulário extenso</template>
</Panel>
```

### TabsPanel - Para qualquer formulário com abas/guias
```vue
<TabsPanel :open="showTabs" :config-actions="tabsConfig" v-model:tab-index="tabIndex">
  <div v-if="tabIndex === 0">Primeira aba</div>
  <div v-if="tabIndex === 1">Segunda aba</div>
</TabsPanel>
```

## 🎯 Regras de Escolha

### Critérios de Decisão:

1. **Tem abas/guias?** → **TabsPanel** (independente da quantidade de campos)
2. **Até 11 campos e sem abas?** → **Modal**
3. **Mais de 11 campos e sem abas?** → **Panel**

| Situação | Campos | Abas/Guias | Componente | Motivo |
|----------|--------|------------|------------|---------|
| Confirmação simples | 2 | Não | Modal | ≤11 campos, sem abas |
| Cadastro de usuário | 8 | Não | Modal | ≤11 campos, sem abas |
| Cadastro de produto | 15 | Não | Panel | >11 campos, sem abas |
| Configurações do sistema | 5 | Sim | TabsPanel | Tem abas (prioridade) |
| Não conformidade | 3 | Sim (Detalhes + Plano) | TabsPanel | Tem abas (prioridade) |
| Visualizar detalhes | 20 | Não | Panel | >11 campos, sem abas |

## 📋 Características Principais

### Modal.vue
- ✅ Redimensionamento automático baseado em campos
- ✅ Sistema de breakpoints responsivos  
- ✅ Overlay com foco total
- ✅ Atalhos: Ctrl+S, Ctrl+D

### Panel.vue  
- ✅ Layout lateral mantendo contexto
- ✅ Breadcrumb para navegação
- ✅ Botão voltar integrado
- ✅ Integração com permissões

### TabsPanel.vue
- ✅ Sistema de abas e sub-abas
- ✅ Sidebar colapsável  
- ✅ Navegação por teclado (Ctrl+↑/↓)
- ✅ Botões contextuais por aba
- ✅ Sistema de checkpoint

## 🔧 Funcionalidades Comuns

Todos os componentes compartilham:
- **Sistema de Permissões**: Botões automáticos baseados em permissões do usuário
- **ViewMode**: Suporte para 'create', 'update', 'view' 
- **Service Integration**: Funções CRUD automáticas
- **Slots Flexíveis**: header, body, footer personalizáveis
- **Eventos Padronizados**: close, delete, save-info
- **Transições**: Animações suaves de entrada/saída

## 📖 Exemplos de Uso Real

### Sistema de Usuários (Panel)
```vue
<Panel 
  :open="state.openPanel"
  :view-mode="state.viewMode"
  breadcrumb-main="Usuários"
  :breadcrumb-current="breadcrumbTitle"
  :service="{ create: createUser, update: updateUser }"
>
  <template #body>
    <FormControl label="Nome" v-model="user.name" required />
    <FormControl label="Email" v-model="user.email" required />
    <Select label="Perfil" v-model="user.profileId" :options="profiles" />
  </template>
</Panel>
```

### Sistema de Não Conformidade (TabsPanel)
```vue
<TabsPanel
  :open="state.openModal"
  :config-actions="modalTabsConfig"
  v-model:tab-index="state.tabIndex"
  breadcrumb-main="RNC 001"
  :breadcrumb-current="currentTabTitle"
>
  <div v-if="state.tabIndex === 0">
    <Details :item="nonCompliance" />
  </div>
  <div v-if="state.tabIndex === 1">
    <ActionPlan :item="nonCompliance" />
  </div>
</TabsPanel>
```

### Confirmação de Exclusão (Modal)
```vue
<Modal :open="showDeleteModal" :height="40">
  <template #header>Confirmar Exclusão</template>
  <template #body>
    <p>Tem certeza que deseja excluir este item?</p>
    <p class="has-text-danger">Esta ação não pode ser desfeita.</p>
  </template>
  <template #footer>
    <Button class="is-danger" @click="confirmDelete">Excluir</Button>
    <Button @click="showDeleteModal = false">Cancelar</Button>
  </template>
</Modal>
```

## 🎨 Temas e Estilização

Todos os componentes utilizam as variáveis CSS do tema principal:

```scss
// Cores principais
--neutral-white
--neutral-100, --neutral-200, --neutral-300
--neutral-600, --neutral-800
--primary-300
--feedback-error-100

// Exemplo de customização
.custom-modal {
  .modal-card {
    border-radius: 20px; // Personalizar bordas
  }
}
```

## 🚨 Troubleshooting Comum

### Modal não aparece
- ✅ Verificar se `open` está como `true`
- ✅ Certificar que está dentro de `<Teleport to="#container">`

### Panel não fecha
- ✅ Implementar handler para `@close-panel`
- ✅ Verificar se estado está sendo atualizado

### TabsPanel - abas não mudam
- ✅ Usar `v-model:tab-index` corretamente
- ✅ Verificar se `configActions` está definido

### Botões não aparecem
- ✅ Verificar permissões do usuário
- ✅ Confirmar se `viewMode` está correto
- ✅ Validar configuração de `buttonsActions`

## 📚 Recursos Adicionais

- **Interfaces TypeScript**: Todas definidas em `src/interfaces/components/`
- **Composables**: `useExceptionHandler`, `usePermissionStore`
- **Exemplos Reais**: Ver `src/views/private/` para implementações completas
- **Testes**: Padrões de teste disponíveis nas memórias do sistema

---

**💡 Dica**: Comece sempre com o componente mais simples que atende sua necessidade. Você pode migrar para componentes mais complexos conforme a aplicação evolui.
