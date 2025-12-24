# Change: Implementar Sistema de Eventos PLSAG na Web

## Why

O SAG-WEB precisa capturar eventos dos componentes dinamicos (OnExit, OnClick, OnChange) para futuramente executar instrucoes PLSAG, replicando o comportamento do sistema Delphi original. Na Fase 1, implementaremos toda a infraestrutura de captura de eventos com popups de debug para validacao.

## What Changes

### Backend (C#)
- **Models/FieldEventData.cs** (NOVO): Modelo para dados de eventos de campo
- **Models/FormEventData.cs** (NOVO): Modelo para eventos de formulario
- **Services/IEventService.cs** (NOVO): Interface do servico de eventos
- **Services/EventService.cs** (NOVO): Servico que carrega eventos do banco (SISTCAMP/SISTTABE)
- **Controllers/FormController.cs** (MODIFICADO): Injeta EventService e passa eventos para View
- **Program.cs** (MODIFICADO): Registra EventService no container DI

### Frontend (JavaScript/Razor)
- **wwwroot/js/sag-events.js** (NOVO): Gerenciador de eventos com popup debug
- **Views/Form/_FieldRendererV2.cshtml** (MODIFICADO): Adiciona data-sag-* attributes
- **Views/Form/Render.cshtml** (MODIFICADO): Inicializa SagEvents com dados do servidor
- **Views/Shared/_Layout.cshtml** (MODIFICADO): Inclui sag-events.js

### Eventos Capturados
- **Campos**: OnExit (blur), OnClick, OnChange, OnDblClick
- **Formulario**: ShowTabe, LancTabe, EGraTabe, AposTabe

## Impact

- **Affected specs**: plsag-events (nova capability)
- **Affected code**:
  - `poc-web/SagPoc.Web/Models/` (2 novos arquivos)
  - `poc-web/SagPoc.Web/Services/` (2 novos arquivos)
  - `poc-web/SagPoc.Web/Controllers/FormController.cs`
  - `poc-web/SagPoc.Web/Views/Form/` (2 arquivos)
  - `poc-web/SagPoc.Web/wwwroot/js/` (1 novo arquivo)
- **Breaking changes**: Nenhum - nova funcionalidade
- **Fase 1**: Popup debug mostrando eventos (sem interpretar PLSAG)
- **Fase 2**: Interpretador PLSAG (escopo futuro)

## References

- `Base/SISTEMA_EVENTOS_PLSAG.md` - Documentacao AS-IS do sistema Delphi
- `Base/PROPOSTA_SISTEMA_EVENTOS_WEB.md` - Proposta tecnica detalhada
