## Context

O sistema de eventos PLSAG possui campos especiais no SISTCAMP que não são campos visuais, mas sim containers de instruções que executam em momentos específicos do ciclo de vida do formulário.

Atualmente, o `EventService.cs` filtra esses campos na linha 83:
```csharp
AND NOMECAMP NOT IN ('AnteCria', 'DepoCria', 'DEPOSHOW', 'ATUAGRID')
```

AnteCria e DepoCria já são tratados separadamente e funcionam. DEPOSHOW e ATUAGRID são filtrados mas nunca carregados.

## Goals / Non-Goals

### Goals
- Carregar instruções de DEPOSHOW e ATUAGRID do banco
- Disparar DepoShow após ShowTabe na inicialização
- Criar mecanismo para refreshGrid (ATUAGRID)
- Disparar AposTabe ao finalizar operação (após save ou ao voltar)

### Non-Goals (Fase 1)
- Interpretar/executar instruções PLSAG (apenas log)
- Implementar lógica de atualização real do grid (apenas dispara evento)

## Decisions

### 1. Carregamento de DEPOSHOW e ATUAGRID

Modificar `LoadSpecialFieldEventsAsync` para também carregar DEPOSHOW e ATUAGRID:

```csharp
// Query modificada:
AND UPPER(NOMECAMP) IN ('ANTECRIA', 'DEPOCRIA', 'DEPOSHOW', 'ATUAGRID')

// Tratamento:
if (nome == "DEPOSHOW")
    result.DepoShowInstructions = expr;
else if (nome == "ATUAGRID")
    result.AtuaGridInstructions = expr;
```

### 2. Ordem de Disparo dos Eventos

A sequência correta de eventos na inicialização é:
1. AnteCria (antes de criar campos)
2. DepoCria (depois de criar campos)
3. ShowTabe (formulário exibido)
4. **DepoShow** (após ShowTabe) - NOVO

### 3. AtuaGrid - Quando Disparar

ATUAGRID deve ser chamado:
- Após salvar um registro com sucesso
- Ao trocar de aba (se houver grid na aba)
- Manualmente via `SagEvents.refreshGrid()`

### 4. AposTabe - Quando Disparar

AposTabe deve ser chamado:
- Após salvar com sucesso (depois de EGraTabe)
- Ao clicar em "Voltar"
- Ao fechar modal/painel

## Risks / Trade-offs

| Risco | Mitigação |
|-------|-----------|
| AposTabe chamado múltiplas vezes | Flag para evitar execução duplicada |
| ATUAGRID pesado em grids grandes | Fase 1 apenas loga, sem execução real |
| Ordem de eventos incorreta | Seguir sequência documentada do Delphi |

## Open Questions

- Nenhuma questão pendente para esta implementação
