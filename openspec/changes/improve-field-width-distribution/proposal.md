# Proposal: improve-field-width-distribution

## Summary

Melhorar a distribuicao de largura dos campos nos formularios web para aproveitar 100% do espaco horizontal disponivel, mantendo as proporcoes relativas originais definidas em `TamaCamp`.

## Problem Statement

Os campos nos formularios web sao dimensionados com base em `TamaCamp` (pixels Delphi), que foram projetados para telas desktop fixas (~700-800px). Na web, com telas maiores (1200-1400px+), os campos ficam "espremidos" a esquerda com espaco vazio a direita.

### Evidencia Visual

| Tela | Container Delphi | Uso Original | Resultado Web |
|------|------------------|--------------|---------------|
| 507 (E-mail) | 820px | 94% | Bom |
| 120 (Contratos) | 660px | 92% | ~50% da tela |
| 210 (Tipo Doc) | 340px | 91% | ~30% da tela |
| 715 (Config) | 660px | 91% | ~60% da tela |

### Causa Raiz

Codigo atual em `_FieldRendererV2.cshtml`:
```csharp
wrapperStyle = $"flex: 0 1 {field.TamaCamp}px; ...";
//              ^-- flex-grow: 0 = campos NAO crescem
```

## Proposed Solution

### Abordagem: Flex-Grow Proporcional

Usar `TamaCamp` como peso para `flex-grow`, permitindo que campos cresçam proporcionalmente:

```csharp
wrapperStyle = $"flex: {field.TamaCamp} 1 {field.TamaCamp}px; ...";
//              ^-- flex-grow = TamaCamp (peso proporcional)
```

### Comportamento Esperado

**Linha com campos 150px + 310px + 150px em container 1000px:**
- Espaço extra: 390px
- Distribuicao proporcional mantendo ratio 1:2:1
- Resultado: 246px + 508px + 246px = 1000px (100%)

### Beneficios

1. **Aproveitamento total** do espaco horizontal
2. **Proporcoes mantidas** - campos maiores continuam maiores
3. **Agnostico** - funciona para qualquer tela sem configuracao adicional
4. **Responsivo** - adapta automaticamente a diferentes larguras de viewport

### Consideracoes

1. **Campo unico na linha**: remover ou aumentar significativamente o `max-width`
2. **Checkboxes/botoes**: manter largura fixa (nao precisam crescer)
3. **Min-width**: manter para evitar campos muito pequenos

## Scope

### In Scope
- Modificar calculo de `wrapperStyle` em `_FieldRendererV2.cshtml`
- Ajustar tratamento de campos unicos na linha
- Adicionar tratamento especial para checkboxes/botoes

### Out of Scope
- Mudancas no banco de dados
- Alteracao de valores `TamaCamp` existentes
- Mudancas na logica de agrupamento de linhas

## Success Criteria

1. Campos em linhas multi-campo ocupam 100% da largura disponivel
2. Proporcoes relativas entre campos sao mantidas
3. Checkboxes e botoes mantem largura adequada
4. Layout responsivo continua funcionando
5. Telas existentes (507, 120, 210, 715) apresentam melhor distribuicao
