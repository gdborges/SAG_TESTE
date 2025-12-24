## 1. Backend - Modelo de Dados

- [x] 1.1 Modificar `Models/FormEventData.cs`:
  - Adicionar `DepoShowInstructions` (string)
  - Adicionar `AtuaGridInstructions` (string)

## 2. Backend - Serviço de Eventos

- [x] 2.1 Modificar `Services/EventService.cs`:
  - Atualizar query em `LoadSpecialFieldEventsAsync` para incluir DEPOSHOW e ATUAGRID
  - Tratar DEPOSHOW -> result.DepoShowInstructions
  - Tratar ATUAGRID -> result.AtuaGridInstructions

## 3. Frontend - JavaScript

- [x] 3.1 Modificar `wwwroot/js/sag-events.js`:
  - Na função `init()`: Disparar DepoShow após ShowTabe
  - Criar função `refreshGrid()` para disparar AtuaGrid
  - Expor `refreshGrid` na API pública

## 4. Frontend - View

- [x] 4.1 Modificar `Views/Form/Render.cshtml`:
  - Chamar `SagEvents.onClose()` após save com sucesso (depois de afterSave)
  - Adicionar `onclick` no botão Voltar para chamar `SagEvents.onClose()`

## 5. Testes

Os testes podem ser realizados abrindo Form 120 (Contratos) no browser e observando o console:

- [x] 5.1 Build do projeto passa sem erros
- [x] 5.2 Testar DepoShow - console log após ShowTabe na inicialização
- [x] 5.3 Testar AposTabe - console log após salvar ou ao clicar Voltar
- [x] 5.4 Testar AtuaGrid - console log ao chamar `SagEvents.refreshGrid()`

### URLs de Teste
- Form 120 (Contratos): http://localhost:5255/Form/Render/120
  - Possui DEPOSHOW e ATUAGRID configurados

### Comandos de Debug no Console
```javascript
SagEvents.getFormEvents()   // Ver depoShowInstructions e atuaGridInstructions
SagEvents.refreshGrid()     // Disparar AtuaGrid manualmente
SagEvents.onClose()         // Disparar AposTabe manualmente
```
