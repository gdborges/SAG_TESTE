# Tasks: fix-form-field-validation

## 1. Model Changes
- [x] 1.1 Adicionar propriedade `VaGrCamp` em `FieldMetadata.cs`

## 2. Data Layer
- [x] 2.1 Modificar `GetFieldsQuery()` em `MetadataService.cs` para incluir `VAGRCAMP`

## 3. Rendering
- [x] 3.1 Atualizar ComboBox (tipo C) em `_FieldRendererV2.cshtml`
  - Usar `VaGrCamp[i]` como `value` e `VareCamp[i]` como texto
  - Fallback: se `VaGrCamp` vazio, usar `VareCamp` para ambos
- [x] 3.2 Atualizar ComboBox calculado (tipo EC) com mesma logica
- [x] 3.3 Atualizar Lookup combo (tipo T/IT) fallback com mesma logica

## 4. Validation
- [ ] 4.1 Testar ComboBox com VaGrCamp populado
- [ ] 4.2 Testar ComboBox sem VaGrCamp (fallback)
- [ ] 4.3 Verificar que valores gravados usam VaGrCamp
