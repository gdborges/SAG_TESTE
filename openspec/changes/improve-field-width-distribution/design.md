# Design: improve-field-width-distribution

## Technical Analysis

### Current Implementation

**File**: `SagPoc.Web/Views/Form/_FieldRendererV2.cshtml` (lines 39-54)

```csharp
var wrapperStyle = "";
if (field.TamaCamp > 0)
{
    if (isSingleInRow)
    {
        wrapperStyle = $"max-width: {field.TamaCamp}px;";
    }
    else
    {
        wrapperStyle = $"flex: 0 1 {field.TamaCamp}px; min-width: {Math.Min(field.TamaCamp, 120)}px;";
    }
}
```

**Problem**: `flex: 0 1 ...` = `flex-grow: 0` impede crescimento.

### Proposed Implementation

```csharp
var wrapperStyle = "";
if (field.TamaCamp > 0)
{
    var componentType = field.GetComponentType();
    var isFixedWidth = componentType == ComponentType.Checkbox
                    || componentType == ComponentType.CalcCheckbox
                    || componentType == ComponentType.Button;

    if (isSingleInRow)
    {
        // Campo unico: permitir crescer mas com max razoavel
        // Usa 100% da largura disponivel, sem max-width restritivo
        wrapperStyle = $"flex: 1 1 {field.TamaCamp}px;";
    }
    else if (isFixedWidth)
    {
        // Checkboxes/botoes: nao crescer, manter compactos
        wrapperStyle = $"flex: 0 0 auto;";
    }
    else
    {
        // Multi-campo: crescer proporcionalmente ao TamaCamp original
        wrapperStyle = $"flex: {field.TamaCamp} 1 {field.TamaCamp}px; min-width: {Math.Min(field.TamaCamp, 120)}px;";
    }
}
```

## Flex-Grow Proportional Algorithm

### How It Works

CSS Flexbox distribui espaco extra proporcional ao `flex-grow`:

```
espaco_extra = largura_container - soma_flex_basis
crescimento_campo[i] = espaco_extra * (flex_grow[i] / soma_flex_grow)
largura_final[i] = flex_basis[i] + crescimento_campo[i]
```

### Example Calculation

**Input**: Container 1000px, campos [150px, 310px, 150px], gap 16px

```
soma_basis = 150 + 310 + 150 = 610px
gaps = 2 * 16 = 32px
espaco_extra = 1000 - 610 - 32 = 358px

soma_flex_grow = 150 + 310 + 150 = 610

campo_1: 150 + 358 * (150/610) = 150 + 88 = 238px
campo_2: 310 + 358 * (310/610) = 310 + 182 = 492px
campo_3: 150 + 358 * (150/610) = 150 + 88 = 238px

Total: 238 + 492 + 238 + 32(gap) = 1000px
Ratio: 1:2.07:1 (original era 1:2.07:1)
```

As proporcoes sao perfeitamente mantidas.

## Special Cases

### 1. Single Field in Row

**Antes**: `max-width: {TamaCamp}px` - campo limitado

**Depois**: `flex: 1 1 {TamaCamp}px` - campo cresce para usar espaco disponivel

Campos de texto/numero/data isolados em uma linha devem expandir para facilitar entrada de dados.

### 2. Checkboxes and Buttons

**Tratamento**: `flex: 0 0 auto` - nao crescer, manter tamanho natural

Checkboxes nao devem esticar - ficaria estranho visualmente.

### 3. TextArea/Memo Fields

Ja usam `field-wrapper-full` que ocupa 100% via CSS. Nao afetados.

### 4. LookupModal (Input + Button)

O `input-group` interno ja gerencia a distribuicao. O wrapper externo pode crescer normalmente.

## CSS Considerations

### Current CSS (`form-renderer.css`)

```css
.field-row-multi > .field-wrapper {
    flex: 1 1 auto;  /* fallback */
    min-width: 100px;
}
```

O fallback `flex: 1 1 auto` ja esta correto. O style inline sobrescreve conforme necessario.

### No CSS Changes Required

A mudanca e apenas no calculo do style inline no Razor.

## Testing Strategy

### Visual Verification

1. **Tela 120** (Contratos): Verificar que campos ocupam largura total
2. **Tela 210** (Tipo Documento): Campo "Nome" deve expandir
3. **Tela 507** (E-mail): Deve manter aparencia atual (ja estava boa)
4. **Tela 715** (Configuracao): Campos devem distribuir melhor

### Edge Cases

1. Linha com apenas checkboxes - devem ficar compactos
2. Linha mista (input + checkbox) - input cresce, checkbox fixo
3. Viewport muito estreito - min-width evita colapso
4. Viewport muito largo - campos crescem proporcionalmente

## Rollback Plan

Caso a mudanca cause problemas, reverter para:
```csharp
wrapperStyle = $"flex: 0 1 {field.TamaCamp}px; min-width: {Math.Min(field.TamaCamp, 120)}px;";
```

## Performance Impact

Nenhum impacto de performance. A mudanca e puramente no CSS inline gerado.
