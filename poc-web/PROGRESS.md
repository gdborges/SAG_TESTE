# Progresso: Refatoração do Interpretador de Telas SAG

## Status Atual
- **Data**: 2025-12-20
- **Fase**: Implementação
- **Plano**: `.claude/plans/fluffy-skipping-noodle.md`

## Objetivo
Alcançar 100% de fidelidade visual na renderização de telas do SAG (Delphi → Web).

## Telas de Referência
- **715**: Config. Leitura Serial/Impressão
- **120**: Contratos

## Arquivos Modificados

### 1. FieldMetadata.cs
**Status**: CONCLUÍDO
**Modificações**:
- [x] Expandir enum `ComponentType` de 12 para 45+ tipos
- [x] Atualizar método `GetComponentType()` para todos os tipos
- [x] Adicionar propriedade `IsHidden` para campos ocultos (DEPOSHOW, ATUAGRID, OrdeCamp=9999)
- [x] Adicionar propriedade `IsReadonly` para tipos somente leitura
- [x] Adicionar propriedade `IsVisualComponent` para componentes visuais

### 2. FormMetadata.cs
**Status**: CONCLUÍDO
**Modificações**:
- [x] Filtrar abas vazias em `FieldsByTab`
- [x] Excluir campos ocultos de HeaderFields e MovementFields
- [x] Atualizar `GetBevelGroupsForFields` para filtrar campos ocultos
- [x] Adicionar `VisibleTabIndexes` para listar abas visíveis

### 3. _FieldRendererV2.cshtml
**Status**: CONCLUÍDO
**Modificações**:
- [x] Não renderizar campos Hidden (verificação no início com return)
- [x] Corrigir atributos min/max (usando @if com text blocks)
- [x] Adicionar suporte a todos os 45+ tipos de componentes
- [x] Adicionar classes CSS para campos readonly, calc, info
- [x] Implementar LookupModal com botão de pesquisa
- [x] Implementar RichEdit, AdvancedMemo, Imagens, CheckList
- [x] Implementar placeholders visuais para Grid e Chart

### 4. _FormContent.cshtml
**Status**: CONCLUÍDO (já estava correto)
**Modificações**:
- [x] Adicionar `<legend>` para bevels com LbcxCamp=1 (HasBevelCaption)

### 5. Render.cshtml e _MovementTab.cshtml
**Status**: CONCLUÍDO
**Modificações**:
- [x] Movimentos já usam Model.Form.MovementsByType (filtra Hidden)
- [x] _MovementTab atualizado para usar _FieldRendererV2
- [x] Campos ocultos filtrados (.Where(f => !f.IsHidden))
- [x] Agrupamento por linhas (RowTolerance 20px)

### 6. form-renderer.css
**Status**: CONCLUÍDO
**Modificações**:
- [x] Estilos para campos calculados (field-calc, form-control-calc)
- [x] Estilos para campos info (field-info, form-control-info)
- [x] Estilos para campos readonly (field-readonly)
- [x] Estilos para lookup modal (btn-lookup, input-group)
- [x] Estilos para RichEdit (form-control-rich)
- [x] Estilos para Advanced Memo (form-control-code, tema escuro)
- [x] Estilos para imagens (field-image, image-container)
- [x] Estilos para placeholders (data-grid-placeholder, chart-placeholder)
- [x] Estilos para CheckList (field-checklist)
- [x] Estilos para Label e Button

---

## Mapeamento Completo de Tipos (32+ CompCamp)

| Código | Tipo | Status |
|--------|------|--------|
| E | TextInput | OK |
| N | NumberInput | Bug min/max |
| D | DateInput | OK |
| S | Checkbox | OK |
| C | ComboBox | OK |
| T | LookupCombo | Parcial |
| IT | LookupComboInfo | Parcial |
| L | LookupModal | Não impl. |
| IL | LookupModalInfo | Não impl. |
| M | TextArea | OK |
| BM | TextAreaBlob | OK |
| A | FileInput | Não impl. |
| BVL | Bevel | Sem caption |
| LBL | Label | Não impl. |
| BTN | Button | Não impl. |
| DBG | DataGrid | Placeholder |
| GRA | Chart | Não impl. |
| TIM | Timer | Não impl. |
| LC | CheckList | Não impl. |
| FE | ImageEditable | Não impl. |
| FI | ImageReadonly | Não impl. |
| FF | ImageFixed | Não impl. |
| EE | CalcTextInput | Não impl. |
| LE | CalcTextReadonly | Não impl. |
| EN | CalcNumberInput | Não impl. |
| LN | CalcNumberReadonly | Não impl. |
| ED | CalcDateInput | Não impl. |
| EC | CalcComboBox | Não impl. |
| ES | CalcCheckbox | Não impl. |
| ET | CalcMemo | Não impl. |
| EA | CalcFileInput | Não impl. |
| EI | DirectoryInput | Não impl. |
| IE | InfoTextInput | Não impl. |
| IN | InfoNumberInput | Não impl. |
| IM | InfoTextArea | Não impl. |
| IR | InfoRichEdit | Não impl. |
| RM | RichEdit | Não impl. |
| RB | RichEditBlob | Não impl. |
| BS | AdvMemoSQL | Não impl. |
| BE | AdvMemoGeneral | Não impl. |
| BI | AdvMemoINI | Não impl. |
| BP | AdvMemoPascal | Não impl. |
| BX | AdvMemoXML | Não impl. |

---

## Problemas Identificados

### Tela 715
1. [CRÍTICO] Aba "Dados Adicionais" vazia renderizada
2. [CRÍTICO] 13 campos N com min/max HTML-encoded
3. [MÉDIO] 3 bevels sem títulos

### Tela 120
1. [CRÍTICO] Grids de movimento vazios (GuiaCamp=125, 999)
2. [CRÍTICO] DEPOSHOW/ATUAGRID visíveis
3. [MÉDIO] Campos repetidos entre guias
4. [BAIXO] Consultas duplicadas

---

## Testes Realizados

### Tela 715 - Config. Leitura Serial/Impressão
- [x] DEPOSHOW/ATUAGRID **NÃO** renderizados (ocultos corretamente)
- [x] Atributos min/max corretos (sem HTML-encoding)
- [x] Bevels renderizados (sem legend pois LbcxCamp=0)
- [x] Layout por linhas (field-row-multi) funcionando

### Tela 120 - Contratos
- [x] DEPOSHOW/ATUAGRID **NÃO** renderizados
- [x] Aba de movimento 125 criada corretamente
- [x] movement-container renderizado

## Próximos Passos (Visual)
1. ~~Completar FieldMetadata.cs~~ CONCLUÍDO
2. ~~Atualizar FormMetadata.cs~~ CONCLUÍDO
3. ~~Atualizar views Razor~~ CONCLUÍDO
4. ~~Testar com telas 715 e 120~~ CONCLUÍDO

## Próximos Passos (Funcionalidade - Futuro)
- Implementar CRUD de movimentos
- Implementar sistema de expressões (ExprCamp)
- Implementar lookups funcionais (T/IT com SQL)

---

## Notas Importantes
- Foco atual: **VISUAL** apenas (sem ExprCamp, sem CRUD de movimentos)
- Banco: **MSSQL Azure** (único)
- Referência: `PlusUni.pas` procedure `MontCampPers`
