# Change: Implement PLSAG Interpreter for Web

## Why

O sistema SAG utiliza a linguagem PLSAG (Process Language - SAG) para automação de formulários. A Fase 1 (infraestrutura de eventos) já foi implementada em `sag-events.js`, capturando eventos DOM e preparando para execução. A Fase 2 implementa o interpretador que executa as instruções PLSAG quando eventos são disparados, permitindo que a mesma lógica configurada no banco funcione tanto no Delphi quanto na web.

Sem o interpretador, os eventos são apenas logados no console, sem efeito prático nos formulários.

## Revisão 2024-12-24: Correções de Compatibilidade

Após revisão contra `AI_SPECIFICATION.md` e código Delphi (`PlusUni.pas`), foram corrigidas as seguintes inconsistências:

1. **Comandos C*** - São TIPOS de campo (CE=Editor, CN=Numérico, CS=Sim/Não, CM=Memo, CT=Tabela), não ações de UI. Modificadores D/F/V/C/R controlam Enable/Focus/Visible/Color/Readonly.

2. **Variáveis** - Devem seguir padrão indexado `VA-TIPO####` (ex: VA-INTE0001), não nomes livres.

3. **IF/ELSE/FINA** - Sintaxe correta é `IF-INIC<label>-<cond>`, `IF-ELSE<label>-`, `IF-FINA<label>`.

4. **Templates** - Sintaxe correta é `{DG-Campo}`, `{VA-INTE0001}` (chaves com prefixo).

5. **Segurança SQL** - Frontend NUNCA envia SQL bruto. Backend busca SQL do banco por ID.

## What Changes

### Frontend (JavaScript)

- **NOVO** `plsag-interpreter.js` - Core do interpretador:
  - Parser de instruções (regra dos 8 caracteres)
  - Substituição de templates `{TIPO-CAMPO}`
  - Executor de instruções (sequencial e assíncrono)
  - Gerenciamento de contexto de execução
  - Controle de fluxo (IF-INIC/IF-ELSE/IF-FINA, WH-INIC/WH-FINA, PA)

- **NOVO** `plsag-commands.js` - Handlers de comandos:
  - Comandos de TIPO de campo: CE (Editor), CN (Numérico), CS (Sim/Não), CM (Memo), CT (Tabela)
  - Modificadores de ação: D (Disable), F (Focus), V (Visible), C (Color), R (Readonly)
  - Comandos de variável indexada: VA-TIPO####, VP-TIPO####, PU-TIPO####
  - Comandos de mensagem: MA, MC, ME, MI, MP
  - Comandos especiais EX (subset client-side, SEM SQL direto)

- **MODIFICADO** `sag-events.js` - Integração:
  - `fireFieldEvent()` passa a chamar `PlsagInterpreter.execute()`
  - `fireFormEvent()` passa a chamar `PlsagInterpreter.execute()`

### Backend (C#)

- **NOVO** `PlsagController.cs` - API REST SEGURA:
  - `POST /api/plsag/query` - Executa QY, QN (SQL vem do banco, não do frontend)
  - `POST /api/plsag/execute-sql` - Executa comandos EX-SQL (busca SQL por ID)
  - `POST /api/plsag/save` - Executa DG, DM, D2, D3 (campos parametrizados)
  - Validação de SQL e whitelist de tabelas

## Impact

- **Affected specs**: Nenhum existente (novo)
- **Affected code**:
  - `SagPoc.Web/wwwroot/js/sag-events.js` (linhas 185-186, 206-207)
  - `SagPoc.Web/Views/Shared/_Layout.cshtml` (inclusão de scripts)
  - `SagPoc.Web/Controllers/` (novo controller)
- **Dependencies**:
  - Fase 1 (sag-events.js) - CONCLUÍDA
  - AI_SPECIFICATION.md - Referência técnica
  - PROPOSTA_INTERPRETADOR_PLSAG_WEB.md - Plano detalhado

## Scope

Esta proposta cobre a implementação completa do interpretador PLSAG, dividida em 5 capabilities:

1. **plsag-interpreter-core** - Parser, templates, executor, contexto
2. **plsag-client-commands** - Comandos executados no browser
3. **plsag-server-commands** - Comandos que requerem API
4. **plsag-api** - Backend REST API
5. **plsag-events-integration** - Integração com sistema de eventos
