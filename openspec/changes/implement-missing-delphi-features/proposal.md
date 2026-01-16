# Change: Implement Missing Delphi Features

## Status: IN_PROGRESS
**Created:** 2026-01-02
**Last Updated:** 2026-01-02

## Why

Durante analise detalhada dos arquivos de engenharia reversa do sistema Delphi (POHeCam6.pas e PlusUni.pas), identificamos funcionalidades criticas que existem no sistema original mas nao foram implementadas na POC web. A ausencia dessas funcionalidades impacta:

- **Numeracao automatica** - Contratos, notas, pedidos nao recebem numero automatico
- **Validacao de modificacao** - Usuario pode alterar campos protegidos (totais calculados)
- **Valores default completos** - Checkboxes e campos numericos nao inicializam
- **Navegacao** - Falta atalho ESC para navegar entre abas
- **Eventos avancados** - DuplCliq e eventos de movimento incompletos
- **Tipos de componente** - BTN, IE, LBL e outros nao renderizam

## What Changes

### Fase 1: Completar InicValoCampPers (Baixa complexidade)
Adicionar inicializacao de valores default para tipos faltantes:
- **S** (checkbox): Usar PadrCamp (0 ou 1)
- **E/N** (texto/numerico): Usar PadrCamp se definido

### Fase 2: InicCampSequ - Numeracao Automatica (Alta complexidade)
Implementar geracao automatica de numeros sequenciais:
- Novo `ISequenceService.cs` e `SequenceService.cs`
- Suporte a tipos: `_UN_` (unico), `SEQU` (simples), `VERI` (verificar)
- Integracao com tabela POCaNume

### Fase 3: BtnConf_CampModi - Validacao de Modificacao (Media complexidade)
Proteger campos que nao podem ser alterados manualmente:
- Novo `IValidationService.cs` e `ValidationService.cs`
- Detectar campos ApAt{FinaTabe}, MarcCamp, calculados
- Bloquear salvamento com mensagem especifica

### Fase 4: Tipos de Componente (Media complexidade)
Renderizar componentes faltantes:
- **BTN** - Botao de acao com PLSAG onClick
- **IE/IM/IR/IN** - Campos somente leitura (info)
- **LBL** - Labels estaticos
- **EE/LE/EN/LN** - Campos calculados

### Fase 5: DuplCliq - Duplo Clique (Baixa complexidade)
Implementar duplo clique em campos lookup:
- Abrir modal expandido (similar F2 do Delphi)
- Integrar com sistema de eventos

### Fase 6: Eventos de Movimento Completos (Media complexidade)
Completar eventos de movimento:
- AnteIAE_Movi_{CodiTabe}
- AnteIncl_{CodiTabe}, DepoIncl_{CodiTabe}
- AtuaGrid_{CodiTabe}

### Fase 7: MudaTab2 - Navegacao ESC (Baixa complexidade)
Navegacao por tecla ESC:
- ESC avanca para proxima aba visivel
- Na ultima aba, foca no botao Confirmar

## Impact

- **Affected specs**:
  - plsag-interpreter-core (adicionar comandos)
  - movement-events (completar eventos)
- **Affected code**:
  - `SagPoc.Web/Services/` (3 novos, 3 modificados)
  - `SagPoc.Web/Models/` (2 modificados)
  - `SagPoc.Web/Controllers/` (1 modificado)
  - `SagPoc.Web/Views/Form/` (2 modificados)
  - `SagPoc.Web/wwwroot/js/` (3 modificados)
- **Breaking changes**: Nenhum
- **Dependencies**:
  - PLSAG interpreter - CONCLUIDO
  - Event system - CONCLUIDO
  - Movement system - CONCLUIDO

## Scope

Esta proposta cobre 7 fases de implementacao, organizadas por complexidade e dependencias:

| Fase | Funcionalidade | Complexidade | Dependencias |
|------|----------------|--------------|--------------|
| 1 | InicValoCampPers | Baixa | Nenhuma |
| 2 | InicCampSequ | Alta | Fase 1 |
| 3 | BtnConf_CampModi | Media | Nenhuma |
| 4 | Tipos Componente | Media | Nenhuma |
| 5 | DuplCliq | Baixa | Nenhuma |
| 6 | Eventos Movimento | Media | Movement system |
| 7 | MudaTab2 | Baixa | Nenhuma |

## Documentacao de Referencia

- `Base/SISTEMA_EVENTOS_PLSAG.md` - Documentacao completa das funcionalidades
- `Base/POHeCam6/` - Engenharia reversa do form principal
- `Base/PlusUni/` - Engenharia reversa das utilities
- `openspec/changes/implement-missing-delphi-features/tasks.md` - Lista de tarefas

## Como Retomar em Nova Sessao

1. Ler este arquivo para contexto geral
2. Consultar `tasks.md` para ver progresso atual (itens marcados [x])
3. Consultar `Base/SISTEMA_EVENTOS_PLSAG.md` para detalhes tecnicos
4. Continuar na proxima tarefa nao marcada

## Historico de Sessoes

| Data | Sessao | Progresso |
|------|--------|-----------|
| 2026-01-02 | Sessao 1 | Analise completa, documentacao atualizada, proposta criada |
