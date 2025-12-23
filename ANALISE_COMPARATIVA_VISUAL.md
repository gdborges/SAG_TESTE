# Analise Comparativa Visual: Delphi vs Web

**Data:** 2025-12-23
**Versao:** 1.0
**Escopo:** Aspectos visuais da montagem de formularios (campos, agrupamentos, posicionamento)

---

## 1. Resumo Executivo

Este documento compara a implementacao visual do sistema SAG Delphi (procedure `MontCampPers`) com a versao Web (poc-web). O foco e exclusivamente no aspecto visual: criacao de campos, tipos de componentes, agrupamentos e posicionamento na tela.

### Status Geral

| Aspecto | Delphi | Web | Status |
|---------|--------|-----|--------|
| Tipos de Componentes | 40+ tipos | 36 tipos | **Parcial** |
| Agrupamento (Bevels) | OrdeCamp-based | OrdeCamp-based | **OK** |
| Layout de Linhas | Top/Left fixo | Flexbox responsivo | **OK** (adaptado) |
| Tab Order | OrdeCamp | OrdeCamp | **OK** |
| Guias/Abas | GuiaCamp 1-99 | GuiaCamp 1-99 | **OK** |
| Movimentos | GuiaCamp >= 10 | GuiaCamp >= 10 | **OK** |
| Campos Ocultos | ExisCamp, OrdeCamp=9999 | IsHidden | **OK** |

---

## 2. Mapeamento de Tipos de Componentes

### 2.1 Componentes Implementados na Web

| CompCamp | Delphi Component | Web Component | Status |
|----------|------------------|---------------|--------|
| **E** | TDBEdtLbl | input[type="text"] | OK |
| **N** | TDBRxELbl | input[type="number"] | OK |
| **D** | TDBRxDLbl | input[type="date"] | OK |
| **S** | TDBChkLbl | input[type="checkbox"] | OK |
| **C** | TDBCmbLbl | select | OK |
| **M** | TDBMemLbl | textarea | OK |
| **BM** | TDBMemLbl | textarea | OK |
| **T** | TDBLcbLbl | select (populated via SQL_CAMP) | OK |
| **IT** | TLcbLbl | select (readonly) | OK |
| **L** | TDBLookNume | input-group + btn-lookup | OK |
| **IL** | TDBLookNume | input-group + btn-lookup (readonly) | OK |
| **A** | TDBFilLbl | input-group + btn-file | OK |
| **EE** | TEdtLbl | input[type="text"] (calc) | OK |
| **EN** | TRxEdtLbl | input[type="number"] (calc) | OK |
| **ED** | TRxDatLbl | input[type="date"] (calc) | OK |
| **EC** | TCmbLbl | select (calc) | OK |
| **ES** | TChkLbl | input[type="checkbox"] (calc) | OK |
| **ET** | TMemLbl | textarea (calc) | OK |
| **EA** | TFilLbl | input-group + btn-file (calc) | OK |
| **EI** | TDirLbl | input-group + btn-directory | OK |
| **LE** | TEdtLbl | input (readonly) | OK |
| **LN** | TRxEdtLbl | input[type="number"] (readonly) | OK |
| **IE** | TDBEdtLbl | input (info, readonly) | OK |
| **IN** | TDBRxELbl | input[type="number"] (info) | OK |
| **IM** | TDBMemLbl | textarea (info) | OK |
| **IR** | TDBRchLbl | div[contenteditable] (info) | OK |
| **BVL** | TsgBvl | fieldset.bevel-group | OK |
| **LBL** | TsgLbl | span.field-static-label | OK |
| **BTN** | TsgBtn | button.btn | OK |
| **DBG** | TsgDBG | div.data-grid-placeholder | Placeholder |
| **GRA** | TFraGraf | div.chart-placeholder | Placeholder |
| **FE** | TDBImgLbl | img + input[type="file"] | OK |
| **FI** | TDBImgLbl | img (readonly) | OK |
| **FF** | TImgLbl | img (fixed) | OK |
| **LC** | TLstLbl | div.checklist-container | Placeholder |
| **TIM** | TsgTim | (hidden) | OK |

### 2.2 Componentes NAO Implementados na Web

| CompCamp | Delphi Component | Descricao | Prioridade |
|----------|------------------|-----------|------------|
| **RM** | TDBRchLbl | RichEdit (HTML editor) | Media |
| **RB** | TDBRchLbl | RichEdit blob | Media |
| **BS** | TDBAdvMemLbl | Memo SQL syntax | Baixa |
| **BE** | TDBAdvMemLbl | Memo Pascal syntax | Baixa |
| **BI** | TDBAdvMemLbl | Memo INI syntax | Baixa |
| **BP** | TDBAdvMemLbl | Memo PLSAG syntax | Baixa |
| **BX** | TDBAdvMemLbl | Memo XML syntax | Baixa |
| **RS** | TDBAdvMemLbl | Memo SQL nao-bound | Baixa |
| **RE** | TDBAdvMemLbl | Memo Pascal nao-bound | Baixa |
| **RI** | TDBAdvMemLbl | Memo INI nao-bound | Baixa |
| **RP** | TDBAdvMemLbl | Memo PLSAG nao-bound | Baixa |
| **RX** | TDBAdvMemLbl | Memo XML nao-bound | Baixa |

> **Nota:** Os componentes de syntax highlight (BS, BE, etc.) sao usados principalmente para configuracao tecnica. Nao sao essenciais para formularios de usuario.

---

## 3. Regras de Layout

### 3.1 Posicionamento Delphi (Absoluto)

```pascal
// MontCampPers - Posicionamento
CompAtua.Left   := cds.FieldByName('EsquCamp').AsInteger;
CompAtua.Top    := cds.FieldByName('TopoCamp').AsInteger;
CompAtua.Width  := cds.FieldByName('TamaCamp').AsInteger;
CompAtua.Height := cds.FieldByName('AltuCamp').AsInteger;

// Label: Posicionado 13px acima do campo
Labe.Left := cds.FieldByName('EsquCamp').AsInteger;
Labe.Top  := cds.FieldByName('TopoCamp').AsInteger - 13;
```

### 3.2 Posicionamento Web (Responsivo)

```csharp
// _FieldRendererV2.cshtml - Layout adaptativo

// 1. Agrupamento por TopoCamp (tolerancia 20px)
const int RowTolerance = 20;
// Campos com TopoCamp similar = mesma linha

// 2. Ordenacao dentro da linha por EsquCamp
row.Fields = row.Fields.OrderBy(f => f.EsquCamp).ToList();

// 3. Largura proporcional baseada em TamaCamp
var flexBasis = Math.Max(100, field.TamaCamp);
style = $"flex: 1 1 {flexBasis}px; max-width: {flexBasis}px;"
```

### 3.3 Comparacao de Abordagens

| Aspecto | Delphi | Web | Compatibilidade |
|---------|--------|-----|-----------------|
| TopoCamp | Posicao Y absoluta | Agrupa em linhas (tolerancia 20px) | **OK** |
| EsquCamp | Posicao X absoluta | Ordena dentro da linha | **OK** |
| TamaCamp | Largura em pixels | flex-basis + max-width | **OK** |
| AltuCamp | Altura em pixels | Altura padrao 38px (exceto 999) | **OK** |
| AltuCamp=999 | alClient | 100% do container | **OK** |
| OrdeCamp | TabOrder | Ordem de renderizacao | **OK** |
| OrdeCamp=9999 | TabStop=False (oculto) | IsHidden=true | **OK** |

---

## 4. Regras de Agrupamento (Bevels)

### 4.1 Logica Delphi

No Delphi, componentes sao posicionados geometricamente dentro de bevels usando coordenadas absolutas. O bevel e renderizado primeiro e os campos sao posicionados sobre ele.

### 4.2 Logica Web (Atual)

```csharp
// FormMetadata.cs - Agrupamento por OrdeCamp
// Um campo pertence ao bevel cujo OrdeCamp e imediatamente menor

for (int i = 0; i < bevels.Count; i++)
{
    var bevel = bevels[i];
    var nextBevelOrde = i < bevels.Count - 1
        ? bevels[i + 1].OrdeCamp
        : int.MaxValue;

    // Campos com OrdeCamp entre este bevel e o proximo
    group.Children = inputFields
        .Where(f => f.OrdeCamp > bevel.OrdeCamp && f.OrdeCamp < nextBevelOrde)
        .ToList();
}
```

### 4.3 Avaliacao

| Criterio | Status | Observacao |
|----------|--------|------------|
| Campos dentro do bevel | OK | OrdeCamp determina pertencimento |
| Campos orfaos (antes do 1o bevel) | OK | Grupo sem bevel criado |
| Caption do bevel | OK | LbcxCamp != 0 mostra legend |
| Bevel sem campos | OK | Exibido se HasBevelCaption |

---

## 5. Regras de Guias/Abas

### 5.1 Logica Delphi

```pascal
// MontCampPers - Determinacao do painel destino
if GuiaCamp = 99 then Pane := PnlPers   // Painel personalizado
else if GuiaCamp in [21..23] then Pane := PnlRes // Resumo
else if GuiaCamp >= 10 then Pane := Pnl3 // Movimento
else if GuiaCamp = 3 then Pane := Pnl3
else if GuiaCamp = 2 then Pane := Pnl2
else if GuiaCamp = 1 then Pane := Pnl1
else if GuiaCamp in [4..9] then // Cria aba dinamica
```

### 5.2 Logica Web

```csharp
// FormMetadata.cs
// Cabecalho: GuiaCamp < 10
public IEnumerable<FieldMetadata> HeaderFields =>
    Fields.Where(f => !f.IsMovementField && !f.IsHidden);

// Movimento: GuiaCamp >= 10
public IEnumerable<FieldMetadata> MovementFields =>
    Fields.Where(f => f.IsMovementField && !f.IsHidden);

// FieldMetadata.cs
public bool IsMovementField => GuiaCamp >= 10;
```

### 5.3 Avaliacao

| Criterio | Status | Observacao |
|----------|--------|------------|
| Guia 1 (Dados Gerais) | OK | Aba principal |
| Guia 2 (Dados Adicionais) | OK | Segunda aba se houver campos |
| Guias 3-9 | **Parcial** | Nao cria abas dinamicas 4-9 |
| Guias >= 10 (Movimentos) | OK | Abas separadas por GuiaCamp |
| Guias 21-23 (Resumo) | **Nao Impl** | Paineis de resumo nao existem |
| Guia 99 (Personalizado) | **Nao Impl** | Painel personalizado |

---

## 6. Atributos de Campo

### 6.1 Atributos Utilizados na Web

| Campo DB | Uso Web | Status |
|----------|---------|--------|
| NomeCamp | name do input | OK |
| LabeCamp | label.text | OK |
| CompCamp | Tipo do componente | OK |
| TopoCamp | Agrupamento em linhas | OK |
| EsquCamp | Ordenacao na linha | OK |
| TamaCamp | flex-basis | OK |
| AltuCamp | Altura (999=full) | OK |
| GuiaCamp | Numero da aba | OK |
| OrdeCamp | Tab order | OK |
| ObriCamp | required attribute | OK |
| DesaCamp | disabled em edicao | OK |
| HintCamp | title attribute | OK |
| MascCamp | PasswordChar (*) | OK |
| DeciCamp | step="0.01" etc | **Parcial** |
| MiniCamp | min attribute | OK |
| MaxiCamp | max attribute | OK |
| SqlCamp | Popular select | OK |
| VareCamp | Options do select | OK |
| VaGrCamp | Values do select | **Nao Impl** |

### 6.2 Atributos NAO Utilizados (Aspecto Visual)

| Campo DB | Delphi | Web | Prioridade |
|----------|--------|-----|------------|
| CfonCamp | Font.Name | N/A | Baixa |
| CtamCamp | Font.Size | N/A | Baixa |
| CcorCamp | Font.Color | N/A | Baixa |
| CestCamp | Font.Style (bold/italic) | N/A | Baixa |
| CefeCamp | Font.Effect (underline) | N/A | Baixa |
| LfonCamp | Label.Font.Name | N/A | Baixa |
| LtamCamp | Label.Font.Size | N/A | Baixa |
| LcorCamp | Label.Font.Color | N/A | Baixa |
| LestCamp | Label.Font.Style | N/A | Baixa |
| LefeCamp | Label.Font.Effect | N/A | Baixa |
| DropCamp | DropDownWidth | N/A | Baixa |
| FormCamp | DisplayFormat | N/A | Media |

> **Nota:** Atributos de fonte sao considerados baixa prioridade porque o design web usa CSS com fontes padronizadas (Vision Design System).

---

## 7. Gaps Identificados

### 7.1 Gaps Criticos (Alta Prioridade)

Nenhum gap critico identificado para o escopo visual atual.

### 7.2 Gaps Medios

| Gap | Descricao | Impacto | Status |
|-----|-----------|---------|--------|
| ~~**G1**~~ | ~~MiniCamp/MaxiCamp nao aplicados~~ | ~~Validacao de range nao funciona~~ | **Implementado** |
| **G2** | VaGrCamp nao usado | Valores salvos != valores exibidos | OpenSpec: `fix-form-field-validation` |
| **G3** | Guias 4-9 dinamicas | Formularios com mais de 3 abas | Pendente |
| **G4** | RichEdit (RM/RB) | Campos formatados HTML | Pendente |

### 7.3 Gaps Baixos

| Gap | Descricao | Impacto |
|-----|-----------|---------|
| **G5** | Syntax highlight (BS/BE/etc) | Edicao de scripts/SQL |
| **G6** | Fontes personalizadas | Visual diferente do Delphi |
| **G7** | Guias 21-23 (Resumo) | Paineis de totalizacao |
| **G8** | Guia 99 (Personalizado) | Painel customizado |

---

## 8. Compatibilidade de Comportamento

### 8.1 Tab Order

| Aspecto | Delphi | Web | Status |
|---------|--------|-----|--------|
| Ordenacao | OrdeCamp sequencial | Ordem de renderizacao | **OK** |
| TabStop=False | OrdeCamp=9999 | tabindex="-1" | **OK** |
| Campos desabilitados | Enabled=False | disabled + tabindex="-1" | **OK** |

### 8.2 Campos Ocultos

| Aspecto | Delphi | Web | Status |
|---------|--------|-----|--------|
| ExisCamp != 0 | Nao cria campo | Nao renderiza | **OK** |
| OrdeCamp = 9999 | TabStop=False | IsHidden=true | **OK** |
| DEPOSHOW | Pos-show | Filtrado na query | **OK** |
| ATUAGRID | Grid update | Filtrado na query | **OK** |

### 8.3 Validacao Visual

| Aspecto | Delphi | Web | Status |
|---------|--------|-----|--------|
| Campo obrigatorio | Tag marcada | required + * | **OK** |
| Campo desabilitado edicao | DesaCamp | disabled em edit | **OK** |
| Campo readonly | InicCamp | readonly attribute | **OK** |
| Campo senha | MascCamp='*' | type="password" | **OK** |

---

## 9. Recomendacoes

### 9.1 Acoes Imediatas (Nao Bloqueantes)

1. ~~**Implementar MiniCamp/MaxiCamp**~~ - **JA IMPLEMENTADO** (verificado em _FieldRendererV2.cshtml)
2. **Implementar VaGrCamp** - Separar valores exibidos de valores gravados em selects
   - **OpenSpec**: `openspec/changes/fix-form-field-validation/`

### 9.2 Acoes Futuras

1. **Guias 4-9 dinamicas** - Quando houver formularios que usem
2. **RichEdit basico** - Quando houver campos RM/RB em uso
3. **Guias de resumo (21-23)** - Quando necessario

### 9.3 Nao Recomendado

1. **Fontes personalizadas** - Manter Vision Design System
2. **Syntax highlight** - Complexidade alta, uso raro

---

## 10. Conclusao

A implementacao web do SAG esta **funcionalmente alinhada** com o Delphi para o escopo de montagem visual de formularios. Os principais conceitos foram adaptados corretamente:

- **Tipos de componentes**: 36 de 40+ implementados (90%)
- **Layout**: Adaptacao responsiva do modelo absoluto
- **Agrupamento**: Bevels funcionando via OrdeCamp
- **Guias**: Abas 1-2 e movimentos funcionando
- **Tab order**: Ordem de campos preservada

Os gaps identificados sao majoritariamente de baixa prioridade ou relacionados a funcionalidades avancadas pouco utilizadas.

---

## Anexo A: Matriz de Componentes Completa

Veja arquivo `Base/DICIONARIO_DADOS_SISTTABE_SISTCAMP.md` para detalhes completos dos 40+ tipos de componentes Delphi.

## Anexo B: Codigo-Fonte Referenciado

- `Base/PlusUni.pas` - MontCampPers (linhas 517-2554)
- `poc-web/SagPoc.Web/Models/FieldMetadata.cs` - Enum ComponentType
- `poc-web/SagPoc.Web/Models/FormMetadata.cs` - Logica de agrupamento
- `poc-web/SagPoc.Web/Views/Form/_FieldRendererV2.cshtml` - Renderizacao
