# Guia de Referência Visual: Inclusão Rápida

> **Documento de Especificação Visual**
> Propósito: Servir como referência para recriação da interface "Inclusão Rápida" em diferentes tecnologias
> Foco: Aspectos visuais, layout, design e experiência do usuário
> Escopo: **SEM** referências a backend, lógica de negócio ou acesso a dados

---

## 📋 Sumário

1. [Visão Geral](#visão-geral)
2. [Wireframes e Layouts](#wireframes-e-layouts)
3. [Sistema de Grid e Colunas](#sistema-de-grid-e-colunas)
4. [Componentes de Interface](#componentes-de-interface)
5. [Paleta de Cores](#paleta-de-cores)
6. [Espaçamentos e Dimensões](#espaçamentos-e-dimensões)
7. [Tipografia e Formatação](#tipografia-e-formatação)
8. [Estados Visuais](#estados-visuais)
9. [Responsividade](#responsividade)
10. [Checklist de Implementação](#checklist-de-implementação)

---

## 🎯 Visão Geral

### O que é "Inclusão Rápida"?

Interface modal (popup) para adicionar produtos rapidamente a um pedido de vendas. Otimizada para entrada ágil via teclado com validações visuais em tempo real.

### Versões Disponíveis

| Versão | Complexidade | Recomendação |
|--------|-------------|--------------|
| **Simplificada** | 5 campos + histórico | Uso básico |
| **Completa** ⭐ | 12 campos + catálogo | **Recomendada** |

**Este guia documenta a versão COMPLETA** por ser mais moderna e rica em recursos visuais.

---

## 🖼️ Wireframes e Layouts

### Layout Geral do Popup

```
┌────────────────────────────────────────────────────────────────┐
│  [×]  INCLUSÃO RÁPIDA                                          │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────────── FORMULÁRIO ─────────────────────┐      │
│  │                                                      │      │
│  │  [Código] [Qtde] [$ Min] [$ Max] [KG]               │      │
│  │                                                      │      │
│  │  [$ Proposto] [$ Suframa] [$ Valor Total]           │      │
│  │                                                      │      │
│  │  [Dt. Min] [Dt. Max]            ◄── Condicional     │      │
│  │                                                      │      │
│  │  [Cota] [────── Produto (Descrição) ──────]         │      │
│  │                                                      │      │
│  └──────────────────────────────────────────────────────┘      │
│                                                                │
│  ┌──────────────── GRID DE PRODUTOS ───────────────────┐      │
│  │                                                      │      │
│  │  Cód. Produto  │  Descrição                         │      │
│  │ ───────────────┼─────────────────────────────────── │      │
│  │  12345         │  Produto Exemplo A                 │      │
│  │  67890         │  Produto Exemplo B                 │      │
│  │  ...           │  ...                               │      │
│  │                                                      │      │
│  │                                                      │      │
│  └──────────────────────────────────────────────────────┘      │
│                                                                │
│  ⚠️ Preço abaixo do mínimo!      ◄── Mensagem validação       │
│                                                                │
│                                  [Salvar] [Fechar]             │
└────────────────────────────────────────────────────────────────┘
```

### Estrutura de Áreas

```
┌─────────────────────────────────┐
│        HEADER                   │  40-50px altura
├─────────────────────────────────┤
│                                 │
│    FORMULÁRIO (flex-container)  │  Auto (baseado em campos)
│        gap: 2rem                │
│                                 │
├─────────────────────────────────┤
│                                 │
│    GRID DE PRODUTOS             │  34vh (34% da viewport)
│                                 │
│                                 │
├─────────────────────────────────┤
│    MENSAGEM DE VALIDAÇÃO        │  Auto (condicional)
├─────────────────────────────────┤
│    BOTÕES DE AÇÃO               │  ~50px altura
└─────────────────────────────────┘
```

### Divisão Horizontal (Desktop)

```
┌────────────────────────────────────────┐
│  20% │ 20% │ 20% │ 20% │ 20%          │  Sistema de 20 colunas
│  (4) │ (4) │ (4) │ (4) │ (4)          │  Cada campo = 4 colunas
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│  20% │ 20% │ 20% │ 20% │ 20%          │  Linha 1: 5 campos
│ Códg │ Qtde│ $Min│ $Max│  KG          │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│  20% │ 20% │ 40% (ou 60% vazio)       │  Linha 2: 3 campos
│ $Prop│$Sufr│ $Total │                 │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│  20% │ 80%                             │  Linha 4: 2 campos
│ Cota │ Produto (Descrição)             │
└────────────────────────────────────────┘
```

---

## 📐 Sistema de Grid e Colunas

### Configuração do Grid

- **Total de Colunas**: 20
- **Unidade Básica**: 5% da largura (1 coluna)
- **Distribuição Comum**: 4 colunas por campo (20%)

### Mapeamento de Campos

| Campo | ColSpan | Largura % | Posição Visual |
|-------|---------|-----------|----------------|
| Código do Produto | 4 | 20% | Linha 1, Col 1-4 |
| Quantidade | 4 | 20% | Linha 1, Col 5-8 |
| $ Valor Mínimo | 4 | 20% | Linha 1, Col 9-12 |
| $ Valor Máximo | 4 | 20% | Linha 1, Col 13-16 |
| KG (Peso) | 4 | 20% | Linha 1, Col 17-20 |
| $ Proposto | 4 | 20% | Linha 2, Col 1-4 |
| $ Valor Suframa | 4 | 20% | Linha 2, Col 5-8 |
| $ Valor Total | 4 | 20% | Linha 2, Col 9-12 |
| Dt. Mínima | 4 | 20% | Linha 3, Col 1-4 |
| Dt. Máxima | 4 | 20% | Linha 3, Col 5-8 |
| Cota Disponível | 4 | 20% | Linha 4, Col 1-4 |
| Produto (Descrição) | 16 | 80% | Linha 4, Col 5-20 |

### Sistema Flexbox Principal

```css
.flex-container {
    height: 100%;
    display: flex;
    flex-direction: column;  /* Empilhamento vertical */
    gap: 2rem;               /* 32px entre elementos */
}
```

---

## 🎨 Componentes de Interface

### 1. Campos de Entrada

#### 1.1. TextBox - Código do Produto

**Especificações Visuais:**
- Label: "Código do produto"
- Posição da label: Acima do campo
- Largura: 20% (4 colunas)
- Altura: ~40px (padrão)
- Borda: 1px sólida
- Destaque de obrigatório: Sim (asterisco ou cor)

**Estados:**
- Normal: Borda cinza clara
- Focus: Borda azul, sombra suave
- Filled: Borda padrão, fundo branco
- Error: Borda vermelha

**Ícones/Adornos:** Nenhum

---

#### 1.2. NumberBox - Quantidade

**Especificações Visuais:**
- Label: "Quantidade"
- Largura: 20% (4 colunas)
- Altura: ~40px
- **Spin Buttons**: Sim (botões +/-)

**Elementos do Spin:**
```
┌─────────────────────────┬───┐
│         123             │ ▲ │  Botão incremento
│                         ├───┤
│                         │ ▼ │  Botão decremento
└─────────────────────────┴───┘
```

**Propriedades:**
- Incremento: Definido por parâmetro (ex: 1, 5, 10)
- Valor mínimo: Definido por parâmetro
- Valor inicial: Valor mínimo
- Alinhamento: Centro ou direita

**Estados:**
- Disabled quando min = max
- Error quando < mínimo

---

#### 1.3. NumberBox - Valores Monetários ($ Min, $ Max, $ Proposto, $ Suframa, $ Total)

**Especificações Visuais:**
- Altura: ~40px
- Largura: 20% (4 colunas)
- Alinhamento: Direita
- Prefixo: Símbolo da moeda (R$, $, etc)

**Formatação Visual:**
```
┌─────────────────────────┐
│      R$ 1.234,56        │  Formato Moeda Padrão
└─────────────────────────┘

┌─────────────────────────┐
│    R$ 1.234,5678        │  Formato Moeda c/ Decimais ($ Proposto)
└─────────────────────────┘
```

**Variações:**
- **$ Valor Mínimo**: Readonly, fundo cinza claro (#f5f5f5)
- **$ Valor Máximo**: Readonly, fundo cinza claro (#f5f5f5)
- **$ Proposto**: Editável (se tiver permissão), fundo branco
- **$ Valor Suframa**: Readonly, fundo cinza claro
- **$ Valor Total**: Readonly, fundo cinza claro, fonte em negrito

**Cores de Validação:**
- Dentro da faixa: Borda verde (#5cb85c)
- Abaixo do mínimo: Borda vermelha (#d96f6f)
- Acima do máximo: Borda laranja (#f0ad4e)

---

#### 1.4. NumberBox - KG (Peso)

**Especificações Visuais:**
- Label: "KG."
- Largura: 20%
- Readonly: Sim
- Fundo: Cinza claro (#f5f5f5)
- Decimais: 2 ou 3 casas

**Formato:**
```
┌─────────────────────────┐
│       123.45 kg         │
└─────────────────────────┘
```

---

#### 1.5. DateBox - Datas de Produção

**Especificações Visuais:**
- Label: "Dt. Min Prod" / "Dt. Max Prod"
- Largura: 20% cada
- Altura: ~40px
- Formato: dd/MM/yyyy

**Elementos Visuais:**
```
┌─────────────────────────┬───┐
│   25/12/2024            │ 📅│  Ícone calendário
└─────────────────────────┴───┘
```

**Dt. Mínima:**
- Valor mínimo: Hoje
- Ícone: Calendário à direita

**Dt. Máxima:**
- Datas desabilitadas: Antes da data mínima
- Datas desabilitadas em cinza claro

**Popup de Calendário:**
- Largura: ~300px
- Hoje destacado em azul
- Seleção em azul escuro
- Datas desabilitadas em cinza

---

#### 1.6. NumberBox - Cota Disponível

**Especificações Visuais:**
- Label: "Cota Disponível"
- Largura: 20%
- Readonly: Sim
- Fundo: Cinza claro
- Alinhamento: Centro

**Feedback Visual:**
- Cota > 0: Texto verde (#5cb85c)
- Cota = 0: Texto vermelho (#d96f6f)
- Sem cota definida: Texto cinza

---

#### 1.7. TextBox - Produto (Descrição)

**Especificações Visuais:**
- Label: "Produto"
- Largura: 80% (16 colunas)
- Readonly: Sim
- Fundo: Cinza muito claro (#fafafa)
- Alinhamento: Esquerda

**Formato:**
```
┌─────────────────────────────────────────────────────────────┐
│  PRODUTO EXEMPLO - DESCRIÇÃO COMPLETA DO ITEM               │
└─────────────────────────────────────────────────────────────┘
```

**Estados:**
- Vazio: Texto placeholder em cinza claro
- Preenchido: Texto preto
- Produto bloqueado: Fundo vermelho claro, texto vermelho escuro

---

### 2. Grid de Produtos

#### Especificações do Grid

**Dimensões:**
- Altura: 34vh (34% da altura da viewport)
- Largura: 100% do container
- Altura mínima: 200px
- Altura máxima: Nenhuma

**Cabeçalho:**
```
┌──────────────────┬────────────────────────────────────────────┐
│  Cód. Produto ▼  │  Descrição ▼                               │
└──────────────────┴────────────────────────────────────────────┘
```

**Colunas:**

| Coluna | Largura | Alinhamento | Ordenável | Filtrável |
|--------|---------|-------------|-----------|-----------|
| Cód. Produto | ~20% | Esquerda | Sim | Sim |
| Descrição | ~80% | Esquerda | Sim | Sim |

**Linhas:**
- Altura: ~40px
- Linhas alternadas: Sim
  - Par: Branco (#ffffff)
  - Ímpar: Cinza muito claro (#f9f9f9)
- Hover: Azul muito claro (#e8f4fd)
- Seleção: Azul claro (#d4e9f7)

**Cores Condicionais (Background da Linha):**

| Condição | Cor de Fundo | Cor do Texto |
|----------|-------------|--------------|
| Produto desbloqueado | Verde claro (#5cb85c) | Branco (#ffffff) |
| Tipo Valor = 1 | Vermelho claro (#d96f6f) | Preto (#000000) |
| Tipo Valor = 2 | Azul claro (#78acff) | Preto (#000000) |
| Padrão | Branco/Cinza alternado | Preto (#000000) |

**Filtros:**
```
┌──────────────────┬────────────────────────────────────────────┐
│  [__________] 🔍 │  [________________________] 🔍             │  Linha de filtro
├──────────────────┼────────────────────────────────────────────┤
│  Cód. Produto ▼  │  Descrição ▼                               │  Cabeçalho
└──────────────────┴────────────────────────────────────────────┘
```

**Paginação:**
- Tipo: Scroll infinito
- Itens por página: 10
- Loading: Spinner no final da lista

**Bordas:**
- Borda externa: 1px sólida #ddd
- Linhas de separação: 1px sólida #e0e0e0
- Colunas de separação: 1px sólida #e0e0e0

---

### 3. Botões de Ação

#### Container dos Botões

```
┌────────────────────────────────────────────────────────────────┐
│                                          [Salvar] [Fechar]     │
└────────────────────────────────────────────────────────────────┘
```

**Layout:**
- Display: Flex
- Alinhamento: À direita (justify-content: end)
- Margem superior: 5px
- Espaçamento entre botões: 10px

---

#### 3.1. Botão "Salvar"

**Especificações Visuais:**
- Texto: "Salvar"
- Tipo: Success (Verde)
- Estilo: Contained (fundo sólido)
- Largura: Auto (~100px)
- Altura: ~40px

**Cores:**
```css
/* Estado Normal */
background: #5cb85c;
color: #ffffff;
border: none;
border-radius: 4px;

/* Hover */
background: #4cae4c;
box-shadow: 0 2px 4px rgba(0,0,0,0.2);

/* Active (clique) */
background: #449d44;

/* Disabled */
background: #cccccc;
color: #666666;
cursor: not-allowed;
```

**Ícone:** Nenhum (apenas texto)

---

#### 3.2. Botão "Fechar"

**Especificações Visuais:**
- Texto: "Fechar"
- Tipo: Default (Cinza)
- Estilo: Contained
- Largura: Auto (~100px)
- Altura: ~40px

**Cores:**
```css
/* Estado Normal */
background: #e0e0e0;
color: #333333;
border: none;
border-radius: 4px;

/* Hover */
background: #d0d0d0;
box-shadow: 0 2px 4px rgba(0,0,0,0.2);

/* Active */
background: #c0c0c0;
```

---

### 4. Elementos de Feedback

#### 4.1. Mensagem de Validação

**Posicionamento:**
- Entre grid e botões
- Margem: 10px acima dos botões

**Especificações:**
```html
<div style="color: #FF0000; font-size: 14px; text-align: left;">
    ⚠️ Preço abaixo do mínimo!
</div>
```

**Mensagens Possíveis:**
- "⚠️ Preço abaixo do mínimo!"
- "⚠️ Preço acima do máximo!"
- "ℹ️ Preço abaixo do padrão!"

**Cores por Tipo:**
- Erro: #FF0000 (vermelho)
- Aviso: #f0ad4e (laranja)
- Info: #5bc0de (azul claro)

---

#### 4.2. Indicadores de Campo Obrigatório

**Método 1: Asterisco**
```
Código do produto *
┌─────────────────────────┐
│                         │
└─────────────────────────┘
```

**Método 2: Borda Colorida**
- Borda esquerda: 3px sólida azul (#007bff)

**Método 3: Label em Negrito**
- Campos obrigatórios: font-weight: 600
- Campos opcionais: font-weight: 400

---

## 🎨 Paleta de Cores

### Cores Primárias

| Nome | Hexadecimal | RGB | Uso |
|------|-------------|-----|-----|
| Success | `#5cb85c` | rgb(92, 184, 92) | Botão Salvar, validações OK |
| Danger | `#FF0000` | rgb(255, 0, 0) | Mensagens de erro |
| Danger Light | `#d96f6f` | rgb(217, 111, 111) | Fundos de erro |
| Info | `#78acff` | rgb(120, 172, 255) | Fundos informativos |
| Default | `#e0e0e0` | rgb(224, 224, 224) | Botão Fechar |

### Cores de Background

| Nome | Hexadecimal | Uso |
|------|-------------|-----|
| White | `#ffffff` | Fundo padrão, campos editáveis |
| Gray Light | `#f5f5f5` | Campos readonly |
| Gray Very Light | `#f9f9f9` | Linhas alternadas |
| Gray Ultra Light | `#fafafa` | Descrição de produto |

### Cores de Borda

| Nome | Hexadecimal | Uso |
|------|-------------|-----|
| Border Default | `#ddd` | Bordas externas |
| Border Light | `#e0e0e0` | Separadores de grid |
| Border Focus | `#007bff` | Campos em foco |

### Cores de Texto

| Nome | Hexadecimal | Uso |
|------|-------------|-----|
| Text Primary | `#000000` | Texto principal |
| Text Secondary | `#333333` | Texto secundário |
| Text Muted | `#797979` | Texto em fundos coloridos |
| Text Disabled | `#cccccc` | Texto desabilitado |
| Text Placeholder | `#999999` | Placeholders |

---

## 📏 Espaçamentos e Dimensões

### Espaçamentos Padrão

```css
/* Gap entre seções do formulário */
gap: 2rem;              /* 32px */

/* Margem superior dos botões */
margin-top: 5px;

/* Margem entre botões */
margin-left: 10px;

/* Margem interna de campos */
padding: 8px 12px;

/* Margem interna de botões */
padding: 10px 20px;
```

### Dimensões de Componentes

| Componente | Largura | Altura |
|------------|---------|--------|
| Campo de texto | 20% (4col) | 40px |
| Campo de data | 20% (4col) | 40px |
| Campo numérico | 20% (4col) | 40px |
| Campo descrição | 80% (16col) | 40px |
| Botão | Auto (~100px) | 40px |
| Linha do grid | 100% | 40px |
| Grid de produtos | 100% | 34vh |

### Dimensões do Popup

**Desktop:**
- Largura: 750px
- Altura: 370px
- Margem do viewport: 20px

**Tablet:**
- Largura: 90vw
- Altura: 80vh

**Mobile:**
- Largura: 100vw
- Altura: 100vh (fullscreen)

### Border Radius

```css
/* Campos de entrada */
border-radius: 4px;

/* Botões */
border-radius: 4px;

/* Popup */
border-radius: 8px;      /* Desktop */
border-radius: 0;        /* Mobile (fullscreen) */
```

---

## 🔤 Tipografia e Formatação

### Hierarquia de Texto

| Elemento | Font Size | Font Weight | Line Height | Color |
|----------|-----------|-------------|-------------|-------|
| Título do Popup | 18px | 600 | 1.4 | #000000 |
| Label de Campo | 14px | 500 | 1.4 | #333333 |
| Valor de Campo | 14px | 400 | 1.4 | #000000 |
| Texto do Grid | 14px | 400 | 1.4 | #000000 |
| Botão | 14px | 500 | 1.4 | Variável |
| Mensagem Erro | 14px | 500 | 1.4 | #FF0000 |
| Placeholder | 14px | 400 | 1.4 | #999999 |

### Família de Fontes

```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
             "Helvetica Neue", Arial, sans-serif;
```

### Formatações Numéricas

#### Moeda Padrão
```
Formato: R$ #.###,##
Exemplo: R$ 1.234,56
Decimais: 2
Separador milhar: .
Separador decimal: ,
```

#### Moeda com Decimais Extras
```
Formato: R$ #.###,####
Exemplo: R$ 1.234,5678
Decimais: 4
```

#### Quantidade
```
Formato: #.###
Exemplo: 1.500
Decimais: 0
```

#### Peso (KG)
```
Formato: #.###,##
Exemplo: 123,45
Decimais: 2
Sufixo: " kg"
```

### Formatações de Data

```
Formato: dd/MM/yyyy
Exemplo: 25/12/2024
```

---

## 🎭 Estados Visuais

### Estados de Campos de Entrada

#### Normal (Padrão)
```css
background: #ffffff;
border: 1px solid #ddd;
color: #000000;
cursor: text;
```

#### Focus (Em Foco)
```css
background: #ffffff;
border: 1px solid #007bff;
box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
color: #000000;
outline: none;
```

#### Readonly (Somente Leitura)
```css
background: #f5f5f5;
border: 1px solid #e0e0e0;
color: #797979;
cursor: not-allowed;
```

#### Disabled (Desabilitado)
```css
background: #f0f0f0;
border: 1px solid #d0d0d0;
color: #cccccc;
cursor: not-allowed;
opacity: 0.6;
```

#### Error (Com Erro)
```css
background: #fff5f5;
border: 1px solid #FF0000;
color: #000000;
```

#### Valid (Validado)
```css
background: #f0fff4;
border: 1px solid #5cb85c;
color: #000000;
```

### Estados de Botões

#### Salvar - Normal
```css
background: #5cb85c;
color: #ffffff;
border: none;
box-shadow: none;
cursor: pointer;
```

#### Salvar - Hover
```css
background: #4cae4c;
color: #ffffff;
box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
transform: translateY(-1px);
transition: all 0.2s;
```

#### Salvar - Active
```css
background: #449d44;
transform: translateY(0);
box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
```

#### Fechar - Normal
```css
background: #e0e0e0;
color: #333333;
```

#### Fechar - Hover
```css
background: #d0d0d0;
box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
```

### Estados de Linhas do Grid

#### Normal
```css
background: #ffffff;      /* Par */
background: #f9f9f9;      /* Ímpar */
```

#### Hover
```css
background: #e8f4fd;
cursor: pointer;
transition: background 0.2s;
```

#### Selecionado
```css
background: #d4e9f7;
font-weight: 500;
```

#### Produto Desbloqueado (StatusProdutoBloqueio = 2)
```css
background: #5cb85c !important;
color: #ffffff;
```

#### Tipo Valor 1
```css
background: #d96f6f !important;
color: #000000;
```

#### Tipo Valor 2
```css
background: #78acff !important;
color: #000000;
```

---

## 📱 Responsividade

### Breakpoints

```css
/* Mobile - até 767px */
@media (max-width: 767px) {
    /* Popup fullscreen */
    width: 100vw;
    height: 100vh;
    border-radius: 0;

    /* Campos em coluna única */
    .field { width: 100% !important; }

    /* Grid menor */
    .grid { height: 40vh; }
}

/* Tablet - 768px a 1023px */
@media (min-width: 768px) and (max-width: 1023px) {
    /* Popup 90% viewport */
    width: 90vw;
    height: 80vh;

    /* Campos em 2 colunas */
    .field { width: 50%; }
}

/* Desktop - 1024px+ */
@media (min-width: 1024px) {
    /* Popup tamanho fixo */
    width: 750px;
    height: 370px;

    /* Sistema de 20 colunas */
    /* Campos conforme especificado */
}
```

### Adaptações Mobile

#### Layout do Formulário
```
Desktop:
[Códg] [Qtde] [$Min] [$Max] [KG]

Mobile:
[Código do produto        ]
[Quantidade               ]
[$ Valor Mínimo           ]
[$ Valor Máximo           ]
[KG                       ]
```

#### Grid de Produtos
- Altura aumenta para 40vh
- Scroll vertical facilitado
- Colunas ajustadas:
  - Cód: 30%
  - Descrição: 70%

#### Botões
```
Desktop:
                 [Salvar] [Fechar]

Mobile:
[Salvar ──────────────────────]
[Fechar ──────────────────────]
```

### Unidades Responsivas Utilizadas

| Propriedade | Desktop | Tablet | Mobile |
|-------------|---------|--------|--------|
| Popup Width | 750px | 90vw | 100vw |
| Popup Height | 370px | 80vh | 100vh |
| Grid Height | 34vh | 40vh | 40vh |
| Gap | 2rem | 1.5rem | 1rem |
| Font Size | 14px | 14px | 16px |
| Button Height | 40px | 44px | 48px |

---

## ✅ Checklist de Implementação

### 1. Estrutura Base

- [ ] Container modal/popup
- [ ] Header com título e botão fechar
- [ ] Área de conteúdo flex vertical
- [ ] Footer com botões de ação

### 2. Formulário de Entrada

- [ ] Sistema de grid 20 colunas
- [ ] Gap de 2rem entre linhas
- [ ] Labels acima dos campos

**Campos Linha 1:**
- [ ] TextBox - Código do Produto (4col)
- [ ] NumberBox - Quantidade com spin buttons (4col)
- [ ] NumberBox - $ Valor Mínimo readonly (4col)
- [ ] NumberBox - $ Valor Máximo readonly (4col)
- [ ] NumberBox - KG readonly (4col)

**Campos Linha 2:**
- [ ] NumberBox - $ Proposto editável (4col)
- [ ] NumberBox - $ Valor Suframa readonly (4col)
- [ ] NumberBox - $ Valor Total readonly (4col)

**Campos Linha 3 (Condicional):**
- [ ] DateBox - Dt. Mínima (4col)
- [ ] DateBox - Dt. Máxima (4col)

**Campos Linha 4:**
- [ ] NumberBox - Cota Disponível readonly (4col)
- [ ] TextBox - Produto (Descrição) readonly (16col)

### 3. Grid de Produtos

- [ ] DataGrid com 2 colunas
- [ ] Altura 34vh
- [ ] Scroll infinito
- [ ] Linhas alternadas
- [ ] Filtros por coluna
- [ ] Clique para selecionar
- [ ] Cores condicionais
- [ ] Hover effect
- [ ] Bordas visíveis

### 4. Elementos de Validação

- [ ] Mensagem de erro (vermelho)
- [ ] Validação de preço min/max
- [ ] Validação de campos obrigatórios
- [ ] Feedback visual em tempo real

### 5. Botões de Ação

- [ ] Botão Salvar (verde, à direita)
- [ ] Botão Fechar (cinza, à direita)
- [ ] Espaçamento 10px entre botões
- [ ] Estados hover/active
- [ ] Alinhamento à direita

### 6. Responsividade

- [ ] Breakpoint mobile (< 768px)
- [ ] Breakpoint tablet (768-1023px)
- [ ] Breakpoint desktop (1024px+)
- [ ] Fullscreen em mobile
- [ ] Grid height responsivo (vh)
- [ ] Campos empilhados em mobile

### 7. Interações de Teclado

- [ ] Tab navega entre campos
- [ ] Enter salva produto
- [ ] Esc fecha popup
- [ ] Setas navegam no grid
- [ ] Insert abre popup (externo)
- [ ] Delete fecha popup (externo)

### 8. Estados Visuais

- [ ] Focus em campos
- [ ] Hover em botões
- [ ] Hover em linhas do grid
- [ ] Estados readonly
- [ ] Estados disabled
- [ ] Estados de erro
- [ ] Estados de sucesso

### 9. Formatações

- [ ] Moeda com 2 decimais
- [ ] Moeda com 4 decimais ($ Proposto)
- [ ] Data dd/MM/yyyy
- [ ] Números com separador de milhar
- [ ] Peso com sufixo "kg"

### 10. Paleta de Cores

- [ ] Verde success (#5cb85c)
- [ ] Vermelho danger (#FF0000)
- [ ] Vermelho claro (#d96f6f)
- [ ] Azul claro (#78acff)
- [ ] Cinza default (#e0e0e0)
- [ ] Fundos readonly (#f5f5f5)
- [ ] Bordas (#ddd, #e0e0e0)

---

## 🔄 Fluxo de Interação Visual

### 1. Abertura do Popup

```
Estado Inicial: Popup fechado
        ↓
Trigger: Clique botão "Produtos" ou tecla Insert
        ↓
Animação: Fade in + scale (0.95 → 1.0)
Duração: 200ms
        ↓
Estado Final: Popup aberto com foco no campo "Código"
```

### 2. Preenchimento do Formulário

```
Usuário digita código
        ↓
Validação em tempo real
        ↓
Se código válido:
    - Preenche descrição
    - Carrega valores min/max
    - Carrega peso
    - Carrega cota
    - Atualiza grid de histórico
        ↓
Cursor move para "Quantidade" (Tab ou Enter)
        ↓
Usuário ajusta quantidade
        ↓
Recalcula valor total automaticamente
        ↓
Cursor move para "$ Proposto"
        ↓
Usuário informa valor
        ↓
Validação de faixa (min/max)
    - Se OK: borda verde
    - Se baixo: borda vermelha + mensagem
    - Se alto: borda laranja + mensagem
        ↓
Preenche valor Suframa automaticamente
        ↓
Recalcula valor total
```

### 3. Seleção via Grid

```
Usuário clica em produto no grid
        ↓
Linha fica selecionada (background azul)
        ↓
Formulário é preenchido automaticamente:
    - Código
    - Descrição
    - Valores min/max
    - Peso
    - Cota
        ↓
Foco move para campo "Quantidade"
```

### 4. Salvamento

```
Usuário clica "Salvar" ou pressiona Enter
        ↓
Validações:
    ✓ Código preenchido
    ✓ Quantidade > 0
    ✓ Valor dentro da faixa
        ↓
Se válido:
    - Animação de sucesso (✓ verde)
    - Fecha popup (fade out)
    - Atualiza lista de produtos do pedido
        ↓
Se inválido:
    - Destaca campo com erro (borda vermelha)
    - Exibe mensagem específica
    - Foco no campo com erro
```

### 5. Cancelamento

```
Usuário clica "Fechar", Esc ou Delete
        ↓
Confirmação (se houver dados digitados):
    "Descartar alterações?"
        ↓
Se confirmar:
    - Limpa formulário
    - Fecha popup (fade out)
        ↓
Se cancelar:
    - Mantém popup aberto
```

---

## 📊 Comparativo Visual das Versões

### Versão Simplificada vs Versão Completa

| Aspecto | Simplificada | Completa ⭐ |
|---------|--------------|------------|
| **Layout** | Horizontal (50/50) | Vertical (empilhado) |
| **Campos** | 5 | 12 |
| **Grid** | Histórico cliente | Catálogo produtos |
| **Altura Grid** | 206px fixo | 34vh responsivo |
| **Colunas Form** | 2 | 20 (mais flexível) |
| **Info Preço** | Apenas proposto | Min/Max/Proposto/Suframa/Total |
| **Info Produto** | Básica | Peso, Cota, Datas |
| **Validação Visual** | Básica | Avançada (mensagens, cores) |
| **Responsivo** | Não | Sim (fullscreen mobile) |
| **Atalhos** | Não | Sim (Insert/Delete) |
| **Gap** | Fixo (px) | Responsivo (rem) |

### Recomendação

**Use a Versão COMPLETA** porque:

1. ✅ **Mais informações** para decisão do usuário
2. ✅ **Validações visuais** reduzem erros
3. ✅ **Responsiva** funciona em qualquer dispositivo
4. ✅ **Grid interativo** acelera o processo
5. ✅ **Layout vertical** é mais moderno e escalável
6. ✅ **Cálculos automáticos** reduzem trabalho manual

---

## 🎨 Mockup Visual ASCII Detalhado

### Desktop (750px x 370px)

```
┌────────────────────────────────────────────────────────────────────────┐
│  [×]  INCLUSÃO RÁPIDA                                                  │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  Código do produto *     Quantidade *        $ Valor Mínimo           │
│  ┌──────────────────┐    ┌────────┬──┐      ┌──────────────────┐     │
│  │ 12345            │    │  150   │▲▼│      │   R$ 1.200,00    │     │
│  └──────────────────┘    └────────┴──┘      └──────────────────┘     │
│                                                                        │
│  $ Valor Máximo          KG.                                          │
│  ┌──────────────────┐    ┌──────────────────┐                        │
│  │   R$ 1.800,00    │    │     123,45 kg    │                        │
│  └──────────────────┘    └──────────────────┘                        │
│                                                                        │
│  $ Proposto *            $ Valor Suframa     $ Valor Total            │
│  ┌──────────────────┐    ┌──────────────────┐ ┌──────────────────┐   │
│  │   R$ 1.500,0000  │    │   R$ 1.350,00    │ │  R$ 225.000,00   │   │
│  └──────────────────┘    └──────────────────┘ └──────────────────┘   │
│                                                                        │
│  Cota Disponível         Produto                                      │
│  ┌──────────────────┐    ┌──────────────────────────────────────────┐│
│  │       500        │    │ PRODUTO EXEMPLO - DESCRIÇÃO COMPLETA     ││
│  └──────────────────┘    └──────────────────────────────────────────┘│
│                                                                        │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │  Cód. Produto │  Descrição                                     │   │
│  ├───────────────┼────────────────────────────────────────────────┤   │
│  │  🔍 _________ │  🔍 ____________________________________       │   │
│  ├───────────────┼────────────────────────────────────────────────┤   │
│  │  12345        │  Produto Exemplo A - Detalhes completos       │   │
│  │  67890        │  Produto Exemplo B - Mais informações         │   │
│  │  11111        │  Produto Exemplo C - Linha completa           │   │
│  │  22222        │  Produto Exemplo D - Variação especial        │   │
│  │               │                                                │   │
│  └───────────────┴────────────────────────────────────────────────┘   │
│                                                                        │
│  ⚠️ Preço abaixo do mínimo!                                           │
│                                                                        │
│                                      ┌─────────┐  ┌─────────┐         │
│                                      │ Salvar  │  │ Fechar  │         │
│                                      └─────────┘  └─────────┘         │
└────────────────────────────────────────────────────────────────────────┘
```

### Mobile (100vw x 100vh - Fullscreen)

```
┌─────────────────────────────────┐
│  [×]  INCLUSÃO RÁPIDA           │
├─────────────────────────────────┤
│                                 │
│  Código do produto *            │
│  ┌──────────────────────────┐   │
│  │ 12345                    │   │
│  └──────────────────────────┘   │
│                                 │
│  Quantidade *                   │
│  ┌──────────────────────┬──┐    │
│  │  150                 │▲▼│    │
│  └──────────────────────┴──┘    │
│                                 │
│  $ Valor Mínimo                 │
│  ┌──────────────────────────┐   │
│  │   R$ 1.200,00            │   │
│  └──────────────────────────┘   │
│                                 │
│  $ Valor Máximo                 │
│  ┌──────────────────────────┐   │
│  │   R$ 1.800,00            │   │
│  └──────────────────────────┘   │
│                                 │
│  KG.                            │
│  ┌──────────────────────────┐   │
│  │     123,45 kg            │   │
│  └──────────────────────────┘   │
│                                 │
│  $ Proposto *                   │
│  ┌──────────────────────────┐   │
│  │   R$ 1.500,0000          │   │
│  └──────────────────────────┘   │
│                                 │
│  Cota Disponível                │
│  ┌──────────────────────────┐   │
│  │       500                │   │
│  └──────────────────────────┘   │
│                                 │
│  Produto                        │
│  ┌──────────────────────────┐   │
│  │ PRODUTO EXEMPLO DESC...  │   │
│  └──────────────────────────┘   │
│                                 │
│  ┌──────────────────────────┐   │
│  │  Cód   │  Descrição      │   │
│  ├────────┼─────────────────┤   │
│  │ 12345  │ Produto A       │   │
│  │ 67890  │ Produto B       │   │
│  │ 11111  │ Produto C       │   │
│  │ 22222  │ Produto D       │   │
│  │ 33333  │ Produto E       │   │
│  │        │                 │   │
│  └────────┴─────────────────┘   │
│                                 │
│  ⚠️ Preço abaixo do mínimo!    │
│                                 │
│  ┌─────────────────────────┐    │
│  │       Salvar            │    │
│  └─────────────────────────┘    │
│  ┌─────────────────────────┐    │
│  │       Fechar            │    │
│  └─────────────────────────┘    │
│                                 │
└─────────────────────────────────┘
```

---

## 📚 Referências de Tecnologia

### Possíveis Implementações

#### 1. HTML + CSS + JavaScript Puro
- Modal: `<dialog>` ou div com position fixed
- Grid: Tabela HTML ou CSS Grid
- Formatações: Intl.NumberFormat, Intl.DateTimeFormat

#### 2. React
- Modal: react-modal, @mui/modal
- Grid: ag-grid-react, react-table
- Formulário: react-hook-form
- Validações: yup, zod

#### 3. Vue.js
- Modal: vuetify dialog, bootstrap-vue modal
- Grid: vue-good-table, ag-grid-vue
- Formulário: vee-validate

#### 4. Angular
- Modal: Angular Material Dialog
- Grid: ag-grid-angular, ngx-datatable
- Formulário: Reactive Forms

#### 5. DevExtreme (Original)
- Modal: dxPopup
- Grid: dxDataGrid
- Formulário: dxForm
- Campos: dxTextBox, dxNumberBox, dxDateBox

---

## 🎯 Prioridades de Implementação

### Fase 1: MVP (Mínimo Viável)
1. ✅ Popup modal básico
2. ✅ Formulário com 3 campos principais (Código, Qtde, Valor)
3. ✅ Grid simples (2 colunas)
4. ✅ Botões Salvar/Fechar
5. ✅ Layout desktop fixo

### Fase 2: Completo
1. ✅ Todos os 12 campos
2. ✅ Grid com filtros
3. ✅ Formatações numéricas
4. ✅ Validações visuais
5. ✅ Mensagens de erro

### Fase 3: Polimento
1. ✅ Responsividade completa
2. ✅ Animações suaves
3. ✅ Atalhos de teclado
4. ✅ Estados hover/focus
5. ✅ Cores condicionais no grid

### Fase 4: Otimização
1. ✅ Carregamento lazy do grid
2. ✅ Virtualização de linhas
3. ✅ Cache de dados
4. ✅ Debounce em filtros
5. ✅ Acessibilidade (ARIA)

---

## 📝 Notas Finais

### Princípios de Design

1. **Simplicidade Visual**: Interface limpa, sem elementos desnecessários
2. **Hierarquia Clara**: Formulário → Grid → Ações
3. **Feedback Imediato**: Validações em tempo real
4. **Eficiência**: Otimizado para entrada via teclado
5. **Consistência**: Padrões visuais uniformes

### Considerações de UX

1. **Foco Automático**: Primeiro campo recebe foco ao abrir
2. **Navegação Fluida**: Tab/Enter movem entre campos logicamente
3. **Atalhos Úteis**: Insert/Delete/Esc para ações rápidas
4. **Erro Preventivo**: Validações impedem erros antes do salvamento
5. **Clique no Grid**: Atalho visual para preencher formulário

### Acessibilidade

- [ ] Labels associados a inputs (for/id)
- [ ] ARIA labels em ícones
- [ ] Contraste mínimo 4.5:1
- [ ] Navegação completa por teclado
- [ ] Estados de foco visíveis
- [ ] Mensagens de erro anunciadas por leitores de tela

---

**Fim do Guia de Referência Visual**

_Documento criado para POC de migração Delphi → Web_
_Versão: 1.0_
_Data: 2025_
