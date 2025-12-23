# Change: Implementar VaGrCamp para Valores de Gravacao Separados

## Why

Atualmente, os campos ComboBox (tipo C) usam apenas `VareCamp` para exibicao e gravacao. No Delphi, o sistema usa `VareCamp` para valores exibidos e `VaGrCamp` para valores gravados no banco. Isso permite mostrar textos descritivos ao usuario enquanto grava codigos ou valores abreviados.

Referencia: `ANALISE_COMPARATIVA_VISUAL.md` - Gap G2

## What Changes

- Adicionar campo `VaGrCamp` ao modelo `FieldMetadata`
- Modificar query SQL no `MetadataService` para carregar `VaGrCamp`
- Atualizar renderizacao de ComboBox para usar `VaGrCamp` como `value` quando disponivel
- Manter `VareCamp` como texto exibido (`innerText` do option)

## Impact

- Affected specs: form-rendering
- Affected code:
  - `SagPoc.Web/Models/FieldMetadata.cs`
  - `SagPoc.Web/Services/MetadataService.cs`
  - `SagPoc.Web/Views/Form/_FieldRendererV2.cshtml`
