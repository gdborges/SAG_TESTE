# Design: Aplicar Design System Vision ao SAG-WEB

## Context

O SAG-WEB é uma aplicação ASP.NET Core MVC com Razor Views que usa Bootstrap 5 e CSS customizado. O sistema Vision possui um design system moderno implementado em Vue 3 com SCSS. Esta mudança visa replicar o visual do Vision no SAG-WEB usando apenas CSS, sem alterar a stack tecnológica.

**Stakeholders**: Equipe de desenvolvimento SAG, usuários finais
**Constraints**: Manter stack ASP.NET Core MVC, não adicionar dependências JavaScript

## Goals / Non-Goals

### Goals
- Replicar a aparência visual do Vision (cores, tipografia, espaçamentos)
- Usar variáveis CSS para facilitar manutenção futura
- Manter compatibilidade com Bootstrap 5 existente
- Melhorar experiência visual do usuário

### Non-Goals
- Migrar para Vue 3 ou outra stack JavaScript
- Implementar componentes JavaScript do Vision (ag-grid, etc.)
- Adicionar funcionalidades novas
- Modificar lógica de backend

## Decisions

### 1. Arquitetura CSS em Camadas

**Decisão**: Criar arquivo `vision-theme.css` separado que sobrescreve estilos padrão.

**Justificativa**:
- Mantém separação de responsabilidades
- Facilita rollback se necessário
- Permite evolução independente do tema

**Estrutura**:
```
wwwroot/css/
├── site.css           # Bootstrap + estilos gerais (não modificar)
├── vision-theme.css   # NOVO - Variáveis e tema Vision
├── form-renderer.css  # Atualizar para usar variáveis
└── consulta-grid.css  # Atualizar para usar variáveis
```

### 2. Variáveis CSS Nativas

**Decisão**: Usar CSS Custom Properties (variáveis nativas) ao invés de SCSS.

**Justificativa**:
- Não requer build step adicional
- Suportado por todos os browsers modernos
- Permite tematização dinâmica futura
- Alinha com abordagem do Vision

**Alternativas consideradas**:
- SCSS: Descartado por adicionar complexidade de build
- CSS-in-JS: Descartado por exigir mudança de stack

### 3. Paleta de Cores Vision

**Decisão**: Adotar paleta completa do Vision.

```css
:root {
  /* Cores Neutras */
  --neutral-white: #FFFFFF;
  --neutral-100: #F5F5F5;
  --neutral-200: #E5E5E5;
  --neutral-300: #D4D4D4;
  --neutral-400: #A3A3A3;
  --neutral-500: #737373;
  --neutral-600: #525252;
  --neutral-700: #404040;
  --neutral-800: #262626;

  /* Cor Primária */
  --primary-100: #E8F0FC;
  --primary-200: #A3C2F0;
  --primary-300: #447BDA;
  --primary-400: #2D5CB8;

  /* Feedback */
  --feedback-error-100: #EA4335;
  --feedback-success-100: #34A853;
  --feedback-warning-100: #FBBC05;
}
```

### 4. Tipografia com Inter

**Decisão**: Usar fonte Inter via Google Fonts.

**Justificativa**:
- É a fonte padrão do Vision
- Excelente legibilidade em interfaces
- CDN gratuito e confiável

**Implementação**:
```html
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### 5. Border Radius Padronizado

**Decisão**: Adotar convenção de border-radius do Vision.

```css
:root {
  --radius-sm: 6px;    /* Inputs, botões, tabs */
  --radius-md: 12px;   /* Cards menores */
  --radius-lg: 16px;   /* Containers, modais */
}
```

### 6. Espaçamentos Consistentes

**Decisão**: Usar sistema de espaçamento baseado em 4px.

```css
:root {
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
}
```

## Risks / Trade-offs

### Riscos

1. **Conflito com Bootstrap** → Usar especificidade CSS para sobrescrever
2. **Performance de carregamento da fonte** → Usar `display=swap` para evitar FOIT
3. **Inconsistência em browsers antigos** → Aceitar degradação graceful (variáveis CSS fallback)

### Trade-offs

- **Manutenção duplicada**: Alterações futuras no Vision precisam ser manualmente replicadas no SAG-WEB
- **Não 100% idêntico**: Sem ag-grid e componentes Vue, algumas nuances visuais serão aproximadas

## Migration Plan

1. Criar `vision-theme.css` com variáveis
2. Adicionar fonte Inter ao layout
3. Atualizar `form-renderer.css` gradualmente
4. Atualizar `consulta-grid.css`
5. Testar em todas as telas existentes

**Rollback**: Remover import do `vision-theme.css` retorna ao visual anterior.

## Open Questions

- Nenhuma questão em aberto no momento.
