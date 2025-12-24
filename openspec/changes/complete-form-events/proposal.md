# Change: Completar Eventos de Formulário PLSAG

## Why

A implementação anterior (`implement-plsag-events`) cobriu eventos de campos e alguns eventos de formulário, mas deixou de fora eventos especiais que são críticos para o comportamento correto do sistema:

1. **DEPOSHOW** - Campo especial que executa instruções APÓS o ShowTabe. Usado no Form 120 (Contratos) para lógica complexa de inicialização.

2. **ATUAGRID** - Campo especial que atualiza/recalcula grids de movimentos. Usado para totalizadores em grids.

3. **AposTabe** - Evento de ciclo de vida que executa ao finalizar operação. Está implementado no backend mas nunca é disparado no frontend.

## What Changes

### Backend (C#)
- **Models/FormEventData.cs** (MODIFICADO): Adicionar propriedades DepoShowInstructions e AtuaGridInstructions
- **Services/EventService.cs** (MODIFICADO): Carregar DEPOSHOW e ATUAGRID do SISTCAMP como campos especiais do formulário

### Frontend (JavaScript/Razor)
- **wwwroot/js/sag-events.js** (MODIFICADO):
  - Disparar DepoShow após ShowTabe na init()
  - Criar função refreshGrid() para ATUAGRID
  - Garantir que onClose() seja chamado
- **Views/Form/Render.cshtml** (MODIFICADO): Chamar SagEvents.onClose() após salvar e ao voltar

### Eventos Adicionados
- **DepoShow**: Dispara após ShowTabe (campos especiais de inicialização tardia)
- **AtuaGrid**: Dispara para atualizar grids (recálculos, totalizadores)
- **AposTabe**: Dispara ao finalizar (já carregado, agora chamado)

## Impact

- **Affected code**:
  - `poc-web/SagPoc.Web/Models/FormEventData.cs`
  - `poc-web/SagPoc.Web/Services/EventService.cs`
  - `poc-web/SagPoc.Web/wwwroot/js/sag-events.js`
  - `poc-web/SagPoc.Web/Views/Form/Render.cshtml`
- **Breaking changes**: Nenhum - extensão de funcionalidade existente
- **Relacionado a**: `implement-plsag-events` (complementa implementação anterior)

## References

- `Base/SISTEMA_EVENTOS_PLSAG.md` - Documentação AS-IS do sistema Delphi
- `Base/PROPOSTA_SISTEMA_EVENTOS_WEB.md` - Proposta técnica original
- Form 120 (Contratos) - Possui DEPOSHOW e ATUAGRID configurados para teste
