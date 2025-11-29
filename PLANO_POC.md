# POC: Migração do Interpretador de Metadados Delphi → ASP.NET Core MVC

> **Documento de Planejamento para Sessões Iterativas**
> Última atualização: 2025-11-29
> Status: Em implementação

## Objetivo
Recriar o mecanismo de renderização dinâmica de formulários do SAG (Delphi) em ASP.NET Core MVC, preservando a capacidade de ler metadados do banco de dados e desenhar interfaces web.

---

## Decisões Tomadas ✅

| Aspecto | Decisão | Justificativa |
|---------|---------|---------------|
| **Fonte de dados** | SQL Server direto | Banco já disponível localmente |
| **Servidor** | `MOOVEFY-0150\SQLEXPRESS` | Instância local do cliente |
| **Expressões (VA-, CS-)** | Documentar para futuro | Foco da POC é renderização visual |
| **Framework CSS** | Bootstrap 5 | Familiar, bom para forms, grid 12 colunas |
| **Localização projeto** | Subpasta `/sag/poc-web/` | Tudo junto para referência |
| **Versão .NET** | .NET 9.0 | Versão instalada na máquina |
| **Tabela teste inicial** | 210 (TipDoc) | Simples, dados já existem |

---

## Análise do Sistema Atual (Delphi) - "AS IS"

### Arquitetura de Metadados

#### Tabelas Principais
| Tabela | Função |
|--------|--------|
| **POCaTabe** | Configuração de formulários (dimensões, abas, SQL, eventos) |
| **POCaCamp/SistCamp** | Definição de campos (100+ colunas controlando cada aspecto) |

#### Colunas Críticas para Renderização
```
┌─────────────────────────────────────────────────────────────────┐
│ POSICIONAMENTO          │ DADOS                │ COMPORTAMENTO  │
├─────────────────────────┼──────────────────────┼────────────────┤
│ TopoCamp (Y)            │ NomeCamp (DB field)  │ ExprCamp       │
│ EsquCamp (X)            │ LabeCamp (Label)     │ ObriCamp       │
│ TamaCamp (Width)        │ CompCamp (Tipo)      │ DesaCamp       │
│ AltuCamp (Height)       │ MascCamp (Máscara)   │ InicCamp       │
│ GuiaCamp (Aba)          │ SQL_Camp (Lookup)    │ TagQCamp       │
│ OrdeCamp (Ordem Tab)    │ VaReCamp (Combo)     │ EPerCamp       │
└─────────────────────────┴──────────────────────┴────────────────┘
```

### Mapeamento de Componentes (CompCamp → Tipo)
| Código | Tipo Delphi | Equivalente Web |
|--------|-------------|-----------------|
| **E** | TDBEdtLbl | `<input type="text">` |
| **N** | TDBRxELbl | `<input type="number">` |
| **C** | TDBCmbLbl | `<select>` |
| **D** | TDBRxDLbl | `<input type="date">` |
| **S** | TDBChkLbl | `<input type="checkbox">` |
| **T/IT** | TDBLcbLbl | `<select>` + AJAX lookup |
| **M/BM** | TDBMemLbl | `<textarea>` |
| **BVL** | TsgBvl | `<fieldset>` / `<div class="separator">` |
| **BTN** | TsgBtn | `<button>` |
| **LBL** | TsgLbl | `<label>` / `<span>` |
| **DBG** | TsgDBG | Grid (DataTables/AG-Grid) |

### Sistema de Expressões (Mini-Linguagem)
O Delphi usa ~50 prefixos de instrução para lógica de negócio:
- **VA-** Variable Assignment
- **CS-** Component Set
- **IF-INIC/ELSE/FINA** Condicionais
- **EX-** Execute Function
- **DG-** Database Field Set
- E muitos outros...

---

## Abordagem "Camadas de Cebola"

### 🧅 Camada 1: Documentação do AS-IS
**Objetivo:** Documentar completamente o mecanismo Delphi
**Entregáveis:**
- Mapeamento completo de colunas POCaCamp → propriedades visuais
- Catálogo de tipos de componentes (CompCamp)
- Documentação do sistema de expressões
- Fluxo de execução (FormCreate → AfterCreate → FormShow)

### 🧅 Camada 2: Estrutura ASP.NET Core (sem conexão com Delphi)
**Objetivo:** Criar projeto base com arquitetura limpa
**Stack:**
- ASP.NET Core 9 MVC
- Dapper para queries
- Razor Views + Bootstrap 5
- JavaScript vanilla

**Entregáveis:**
- Solution structure
- Models para metadados (FormMetadata, FieldMetadata)
- Service para interpretação de metadados
- Razor View Engine para renderização dinâmica

### 🧅 Camada 3: Renderizador Web Básico
**Objetivo:** Ler metadados e gerar HTML funcional
**Entregáveis:**
- Parser de POCaCamp → FieldMetadata
- ComponentRenderer (switch por CompCamp)
- Posicionamento via CSS Grid/Flexbox
- Formulário renderizado no browser

### 🧅 Camada 4: Tela "Inclusão Rápida" Bonita
**Objetivo:** Aplicar design moderno baseado no GUIA_VISUAL_INCLUSAO_RAPIDA.md
**Entregáveis:**
- CSS customizado seguindo especificações
- Grid responsivo (20 colunas → CSS Grid)
- Estados visuais (focus, error, readonly)
- Validações visuais em tempo real

---

## Plano de Implementação Detalhado

### 🧅 CAMADA 1: Estrutura do Projeto (Sessão 1)

**Objetivo:** Criar projeto ASP.NET Core com conexão ao banco

```
/sag/poc-web/
├── SagPoc.sln
├── SagPoc.Web/                    # Projeto MVC
│   ├── Controllers/
│   │   └── FormController.cs      # Renderização dinâmica
│   ├── Models/
│   │   ├── FieldMetadata.cs       # Modelo do campo
│   │   └── FormMetadata.cs        # Modelo do formulário
│   ├── Services/
│   │   ├── IMetadataService.cs    # Interface
│   │   └── MetadataService.cs     # Leitura do banco
│   ├── Views/
│   │   └── Form/
│   │       └── Render.cshtml      # View dinâmica
│   └── wwwroot/
│       └── css/
│           └── form-renderer.css  # Estilos customizados
```

**Tarefas:**
1. ✅ `dotnet new mvc -n SagPoc.Web`
2. ⏳ Configurar connection string para `MOOVEFY-0150\SQLEXPRESS`
3. ⏳ Criar modelo `FieldMetadata` mapeando colunas críticas de SistCamp
4. ⏳ Implementar `MetadataService.GetFieldsByTable(int codiTabe)`
5. ⏳ Testar leitura dos campos da tabela 210

---

### 🧅 CAMADA 2: Renderizador Básico (Sessão 2)

**Objetivo:** Renderizar HTML a partir dos metadados

**De-Para de Componentes (Subset POC):**

| CompCamp | Delphi | HTML/Bootstrap |
|----------|--------|----------------|
| **E** | TDBEdtLbl | `<input type="text" class="form-control">` |
| **N** | TDBRxELbl | `<input type="number" class="form-control">` |
| **C** | TDBCmbLbl | `<select class="form-select">` |
| **S** | TDBChkLbl | `<input type="checkbox" class="form-check-input">` |
| **BVL** | TsgBvl | `<fieldset><legend>` ou `<div class="card">` |

**Mapeamento de Posição:**
```
Delphi (pixels absolutos)     →    Web (CSS Grid/Bootstrap)
─────────────────────────────────────────────────────────
TopoCamp, EsquCamp            →    CSS Grid row/column
TamaCamp                      →    Bootstrap col-* classes
AltuCamp                      →    height ou rows (textarea)
GuiaCamp                      →    Tab/Accordion section
```

---

## Dados de Teste - Tabela 210 (TipDoc)

Campos identificados no Doc.pdf:

| Campo | Nome | Tipo | Posição | Tamanho |
|-------|------|------|---------|---------|
| CAIXCA01 | - | BVL | 15,10 | 340x175 |
| NOMETPDO | Nome | E | 40,25 | 310 |
| TIPOTPDO | Tipo | C | 95,25 | 150 |
| ORDETPDO | Ordem | N | 95,185 | 150 |
| ATIVTPDO | Ativo | S | 150,25 | 150 |
| PDA_TPDO | Disponível SAGMob | C | 150,185 | 150 |
| CAIXCA02 | - | BVL | 205,10 | 340x65 |
| BLCOTPDO | Bloqueio Comercial | S | 230,25 | 150 |
| BLFITPDO | Bloqueio Financeiro | S | 230,185 | 150 |
| CAIXCA03 | - | BVL | 285,10 | 340x65 |
| SF16TPDO | Reg. 1601 SPED | S | 310,25 | 150 |

---

## Critérios de Sucesso da POC

### Camada 1-2 (MVP):
- [ ] Conectar no SQL Server e ler SistCamp
- [ ] Renderizar formulário 210 no browser
- [ ] Campos aparecem com labels corretos
- [ ] Tipos básicos funcionam (text, number, checkbox, combo)

### Camada 3:
- [ ] Agrupamentos visuais (BVL → fieldsets)
- [ ] Ordenação correta dos campos
- [ ] Campos obrigatórios marcados

### Camada 4:
- [ ] Visual moderno e limpo
- [ ] Responsivo (mobile-friendly)
- [ ] Cores e estados visuais corretos

---

## Riscos e Mitigações

| Risco | Probabilidade | Mitigação |
|-------|---------------|-----------|
| Posicionamento pixel→responsive | Alta | Usar CSS Grid com cálculo relativo |
| Lookup queries (SQL_Camp) | Média | Ignorar na POC, mockar dados |
| Expressões complexas | Baixa (ignorado) | Documentar para fase futura |
| Performance com muitos campos | Baixa | Lazy loading se necessário |

---

## Próximas Sessões

| Sessão | Objetivo | Entregável |
|--------|----------|------------|
| **1** | Setup + Conexão | Projeto rodando, lendo SistCamp |
| **2** | Renderizador básico | Formulário 210 no browser |
| **3** | Refinamento | Layout organizado, validações |
| **4** | Design bonito | Visual moderno, responsivo |
| **5+** | Inclusão Rápida | Formulário complexo funcionando |

---

*Documento de planejamento - POC Migração SAG*
*Versão: 1.1 - Aprovado para implementação*
*Referências: Doc.pdf, GUIA_VISUAL_INCLUSAO_RAPIDA.md, PlusUni.pas, POHeCam6.pas*
