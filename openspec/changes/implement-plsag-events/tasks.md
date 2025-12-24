## 1. Backend - Modelos

- [x] 1.1 Criar `Models/FieldEventData.cs` com propriedades:
  - CodiCamp, NomeCamp
  - OnExitInstructions, OnClickInstructions, OnDblClickInstructions
  - IsRequired, HasEvents

- [x] 1.2 Criar `Models/FormEventData.cs` com propriedades:
  - CodiTabe, NomeTabe
  - ShowTabeInstructions, LancTabeInstructions
  - EGraTabeInstructions, AposTabeInstructions
  - AntecriaInstructions, DepocriaInstructions

## 2. Backend - Servico de Eventos

- [x] 2.1 Criar `Services/IEventService.cs` com interface:
  - GetFormEventsAsync(int codiTabe)
  - GetFieldEventsAsync(int codiTabe)

- [x] 2.2 Criar `Services/EventService.cs`:
  - Query SISTTABE para eventos de form
  - Query SISTCAMP para eventos de campo
  - Merge ExprCamp + EPerCamp
  - Carrega AnteCria/DepoCria do SISTCAMP

- [x] 2.3 Registrar EventService no `Program.cs`

## 3. Backend - Controller

- [x] 3.1 Injetar IEventService no FormController
- [x] 3.2 Carregar eventos na action Render
- [x] 3.3 Adicionar FormEvents e FieldEvents ao FormRenderViewModel

## 4. Frontend - JavaScript

- [x] 4.1 Criar `wwwroot/js/sag-events.js`:
  - Modulo SagEvents com init(), beforeSave(), afterSave(), onClose()
  - Binding de eventos (blur, click, change, dblclick)
  - Observador de DOM para campos dinâmicos
  - Log de eventos para debug (Fase 1)

## 5. Frontend - Views

- [x] 5.1 Modificar `_FieldRendererV2.cshtml`:
  - Adicionar data-sag-codicamp, data-sag-nomecamp, data-sag-comptype

- [x] 5.2 Modificar `Render.cshtml`:
  - Serializar eventos como JSON com System.Text.Json
  - Incluir sag-events.js
  - Chamar SagEvents.init(formEvents, fieldEvents)
  - Integrar beforeSave() e afterSave() no fluxo de salvamento

- [x] 5.3 Script incluído em Render.cshtml (não precisa alterar _Layout.cshtml)

## 6. Testes

Os testes abaixo podem ser realizados abrindo um formulário no browser (F12 → Console):

- [x] 6.1 Build do projeto passa sem erros
- [ ] 6.2 Testar componente E (TextInput) - OnExit → Form 120 ou 715 (campos texto)
- [ ] 6.3 Testar componente N (NumberInput) - OnExit → Form 120 (QTTOCONT)
- [ ] 6.4 Testar componente S/ES (Checkbox) - OnClick/OnChange → Form 514 (VLCH_NFE, OBCH_NFE, ESPEESTO)
- [ ] 6.5 Testar componente C (ComboBox) - OnExit/OnChange → Form 715 (TIPOLESI, TPIPLESI) ou Form 120 (TIPOCONT)
- [ ] 6.6 Testar componente L (Lookup) - OnExit → Form 120 (CODIPESS)
- [ ] 6.7 Testar componente BTN (Button) - OnClick → Form 514 (ESPEGRPE)
- [ ] 6.8 Testar evento ShowTabe (console log na inicialização) → Form 120
- [ ] 6.9 Testar evento LancTabe (console log no submit) → Form 120, 507 ou 715

### URLs de Teste
- Form 120 (Contratos): http://localhost:5255/Form/Render/120
- Form 210 (Tipo Documento): http://localhost:5255/Form/Render/210
- Form 507 (Modelo E-mail): http://localhost:5255/Form/Render/507
- Form 514 (Parâm. Estoque): http://localhost:5255/Form/Render/514
- Form 715 (Config. Leitura): http://localhost:5255/Form/Render/715

### Comandos de Debug no Console
```javascript
SagEvents.isInitialized()   // Deve retornar true
SagEvents.getFormEvents()   // Ver eventos do form
SagEvents.getFieldEvents()  // Ver eventos dos campos (por CodiCamp)
```
