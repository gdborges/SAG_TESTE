# Memória do Projeto SAG-WEB POC

## Visão Geral

Este projeto é uma **Prova de Conceito (POC)** para migração do sistema SAG (ERP Delphi) para Web usando ASP.NET Core MVC. O objetivo é renderizar formulários dinâmicos baseados em metadados do banco de dados, replicando o comportamento do sistema Delphi original.

---

## Arquitetura do Sistema Delphi (Referência)

### Formulários Dinâmicos
O SAG Delphi constrói formulários em runtime a partir de configurações em banco:
- **POCaTabe/SistTabe**: Definições de tabelas/formulários
- **POCaCamp/SistCamp**: Definições de campos (tipo, posição, validação, expressões)

### Hierarquia de Forms
```
TsgForm → TFrmPOHeGera → TFrmPOHeCam6 (form dinâmico)
```

### Procedure Principal
`MontCampPers` em `PlusUni.pas` cria componentes visuais baseado em `CompCamp`:
- `E` = TDBEdtLbl (Editor texto)
- `N` = TDBRxELbl (Editor numérico)
- `D` = TDBRxDLbl (Editor data)
- `S` = TDBChkLbl (Checkbox)
- `C` = TDBCmbLbl (ComboBox)
- `T/IT/IL` = TDBLcbLbl (Lookup combo)
- `M/BM` = TDBMemLbl (Memo/TextArea)
- `BVL` = TsgBvl (Bevel - agrupador visual)

### Separação Header vs Movimento
No Delphi (`PlusUni.pas`, linha 691-692):
```pascal
else if Guia >= 10 then
  Pane := Pnl3  // PnlMovi - painel de movimentos
```
- **GuiaCamp < 10**: Campos de cabeçalho (abas normais)
- **GuiaCamp >= 10**: Campos de movimento (registros filhos com grid)

---

## Estrutura do Projeto Web

```
poc-web/
├── SagPoc.Web/
│   ├── Controllers/
│   │   └── FormController.cs       # Controller principal
│   ├── Models/
│   │   ├── FieldMetadata.cs        # Metadados de campo
│   │   ├── FormMetadata.cs         # Metadados de formulário + agrupamentos
│   │   ├── FormRenderViewModel.cs  # ViewModel para renderização
│   │   └── TableMetadata.cs        # Metadados da tabela (SistTabe)
│   ├── Services/
│   │   ├── MetadataService.cs      # Carrega metadados do banco
│   │   └── ConsultaService.cs      # Executa consultas do grid
│   ├── Views/
│   │   └── Form/
│   │       ├── Render.cshtml       # View principal do formulário
│   │       ├── _FormContent.cshtml # Conteúdo do form (todos campos)
│   │       ├── _FormTabContent.cshtml # Conteúdo de uma aba
│   │       ├── _FieldRenderer.cshtml  # Renderiza campo individual
│   │       ├── _MovementTab.cshtml    # Aba de movimento (grid + botões)
│   │       └── _ConsultaTab.cshtml    # Aba de consulta (grid)
│   └── wwwroot/
│       ├── css/
│       │   ├── form-renderer.css   # Estilos do formulário
│       │   ├── consulta-grid.css   # Estilos do grid
│       │   └── vision-tokens.css   # Design tokens Vision
│       └── js/
│           └── consulta-grid.js    # JS do grid de consulta
```

---

## Banco de Dados

### Conexão
- **Azure SQL Server**: sagpocsqlserver.database.windows.net
- **Database**: SAGPOC
- String de conexão em `appsettings.json`

### Tabelas Principais
| Tabela | Descrição |
|--------|-----------|
| SistTabe | Definições de formulários |
| SistCamp | Definições de campos |
| SistCons | Definições de consultas |
| POCaTpDo | Tipos de Documento (tela 715) |
| POGeCont | Contratos (tela 120) |

---

## Implementações Concluídas

### 1. Renderização de Formulários Dinâmicos
- Carrega metadados do banco via `MetadataService`
- Renderiza campos baseado em `CompCamp`
- Suporta tipos: TextInput, NumberInput, DateInput, Checkbox, ComboBox, LookupCombo, TextArea, Bevel

### 2. Sistema de Abas
- Abas baseadas em `GuiaCamp`
- Nomes das abas vêm de `GUI1TABE`, `GUI2TABE` na SistTabe

### 3. Agrupamento por Bevel (Fieldsets)
- Campos agrupados por `OrdeCamp` entre bevels
- Classe `BevelGroup` gerencia agrupamento
- Classe `FieldRow` agrupa campos na mesma linha (por `TopoCamp`)

### 4. Grid de Consulta
- Aba "Consulta" com grid paginado
- Filtros dinâmicos
- Seleção de registro para edição
- Ordenação por coluna

### 5. Vision Design System
- Tokens CSS em `vision-tokens.css`
- Estilos aplicados em `form-renderer.css`
- Cores, tipografia, espaçamentos padronizados

### 6. Separação Header/Movimento (RECENTE - Dez/2024)
**Problema:** Tela 120 no Delphi tem "Dados Gerais" + "Produtos" (movimento), mas na web tudo aparecia misturado.

**Solução implementada:**

#### Models Modificados:

**FieldMetadata.cs** - Adicionado:
```csharp
/// <summary>
/// Indica se o campo pertence a um movimento (registro filho/detalhe).
/// No Delphi (PlusUni.pas linha 691): GuiaCamp >= 10 significa movimento.
/// </summary>
public bool IsMovementField => GuiaCamp >= 10;
```

**FormMetadata.cs** - Adicionado:
```csharp
/// <summary>
/// Campos do cabeçalho (GuiaCamp menor que 10).
/// </summary>
public IEnumerable<FieldMetadata> HeaderFields =>
    Fields.Where(f => !f.IsMovementField);

/// <summary>
/// Campos de movimento (GuiaCamp >= 10).
/// </summary>
public IEnumerable<FieldMetadata> MovementFields =>
    Fields.Where(f => f.IsMovementField);

/// <summary>
/// Indica se o formulário tem movimentos (registros filhos).
/// </summary>
public bool HasMovements => MovementFields.Any();

/// <summary>
/// Movimentos agrupados por tipo (cada GuiaCamp >= 10 é um tipo diferente).
/// </summary>
public IEnumerable<IGrouping<int, FieldMetadata>> MovementsByType =>
    MovementFields.GroupBy(f => f.GuiaCamp).OrderBy(g => g.Key);
```

#### Views Modificadas:

**Render.cshtml** - Adicionado após abas de header:
```razor
@* Abas de Movimento (GuiaCamp >= 10) *@
@if (Model.Form.HasMovements)
{
    @foreach (var movementGroup in Model.Form.MovementsByType)
    {
        var movementTabId = $"tab-mov-{movementGroup.Key}";
        var firstBevel = movementGroup.FirstOrDefault(f => f.GetComponentType() == ComponentType.Bevel && f.HasBevelCaption);
        var movementName = firstBevel?.LabeCamp ?? $"Movimento {movementGroup.Key}";
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="@(movementTabId)-tab" ...>
                @movementName
            </button>
        </li>
    }
}
```

**_MovementTab.cshtml** - NOVO:
- Container para campos de movimento
- Grid placeholder vazio (visual only)
- Botões Envia/Remove desabilitados
- Colunas do grid baseadas nos campos do movimento

#### CSS Adicionado em form-renderer.css:
```css
/* Abas de Movimento (GuiaCamp >= 10) */
.movement-container { ... }
.movement-fields { ... }
.movement-grid-container { ... }
.movement-grid { ... }
```

---

## Telas Testadas

| Tela | ID | Status | Observações |
|------|-----|--------|-------------|
| Tipos de Documento | 715 | OK | Form simples, sem movimentos |
| Contratos | 120 | OK | Com movimentos (Produtos) |
| Tipos de Pagamento | 507 | OK | Form simples |

---

## Pendências / Limitações Conhecidas

### Funcionalidades Não Implementadas (Fora do Escopo POC)
1. **CRUD de Movimentos**: Grid de movimento é apenas visual (sem adicionar/remover itens)
2. **Expressões (ExprCamp)**: Scripts de validação/cálculo não executados
3. **Lookup Dinâmico**: Alguns combos T/IT não carregam opções
4. **InicCamp**: Campo "inicialmente desabilitado" não tratado (controlado por expressões no Delphi)

### Melhorias Futuras
1. Nome das abas de movimento deveria vir do banco (não do bevel caption)
2. Implementar CRUD completo de movimentos
3. Parser de expressões ExprCamp
4. Testes automatizados

---

## Como Executar

```bash
cd poc-web/SagPoc.Web
dotnet run
```

Acesse: http://localhost:5255

### URLs Úteis
- Lista de formulários: http://localhost:5255/Form
- Tela 715 (TipDoc): http://localhost:5255/Form/Render/715
- Tela 120 (Contratos): http://localhost:5255/Form/Render/120
- Tela 507 (TipPag): http://localhost:5255/Form/Render/507

---

## OpenSpec

O projeto usa OpenSpec para gerenciar propostas de mudança:
- Diretório: `openspec/changes/`
- Proposta atual: `fix-form-layout-movements/`

### Fluxo OpenSpec
1. `/openspec:proposal` - Criar proposta
2. Revisar `spec.md` e `tasks.md`
3. `/openspec:apply` - Implementar
4. `/openspec:archive` - Arquivar após deploy

---

## Referências Delphi

### Arquivos Importantes
- `PlusUni.pas`: Lógica de criação de componentes dinâmicos
- `HeGerUni.pas`: Form base genérico
- `HeCam6Uni.pas`: Form dinâmico principal

### Constantes Relevantes
```pascal
// GuiaCamp thresholds
GuiaCamp < 10  = Header fields (abas normais)
GuiaCamp >= 10 = Movement fields (registros filhos)

// CompCamp types
E, N, D, S, C, T, IT, IL, M, BM, BVL, BTN, LBL, DBG
```

---

*Última atualização: Dezembro 2024*
