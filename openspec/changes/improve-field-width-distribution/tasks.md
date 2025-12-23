# Tasks: improve-field-width-distribution

## 1. Implementation

- [x] 1.1 Modificar calculo de `wrapperStyle` em `_FieldRendererV2.cshtml`
  - Usar `flex: {TamaCamp} 1 {TamaCamp}px` para campos multi-linha
  - Usar `flex: 1 1 {TamaCamp}px` para campos unicos na linha
  - Usar `flex: 0 0 auto` para checkboxes e botoes

## 2. Validation

- [x] 2.1 Testar tela 120 (Contratos) - campos devem ocupar largura total
- [x] 2.2 Testar tela 210 (Tipo Documento) - campo Nome deve expandir
- [x] 2.3 Testar tela 507 (E-mail) - deve manter aparencia atual
- [x] 2.4 Testar tela 715 (Configuracao) - melhor distribuicao
- [x] 2.5 Verificar comportamento de checkboxes (nao devem esticar)
- [x] 2.6 Testar responsividade em viewport estreito
