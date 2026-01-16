# Design: PLSAG Interpreter Architecture

## Context

O SAG (Sistema de Administração Geral) utiliza a linguagem PLSAG para personalização de formulários. As instruções PLSAG são armazenadas no banco de dados (tabela POCATabe) e executadas em resposta a eventos de formulário.

A implementação Delphi original está em `PlusUni.pas` (função `CampPersExecListInst`, linha 3731). A versão web deve ser compatível com a sintaxe existente, permitindo que as mesmas instruções funcionem em ambas plataformas.

**Stakeholders:**
- Usuários SAG: esperam comportamento idêntico ao Delphi
- Desenvolvedores: precisam de código manutenível e testável
- DBA: preocupação com segurança SQL

**Constraints:**
- Navegadores não permitem acesso a sistema de arquivos ou hardware
- Operações de banco devem passar por API (não SQL direto do browser)
- Modais são assíncronos na web (vs síncronos no Delphi)

## Goals / Non-Goals

### Goals
- Executar instruções PLSAG no browser com fidelidade ao Delphi
- Manter compatibilidade 100% com sintaxe existente
- Permitir comandos assíncronos (queries, mensagens)
- Integrar com sistema de eventos já implementado (Fase 1)
- Validar SQL no backend para prevenir injection

### Non-Goals
- Implementar comandos impossíveis na web (porta serial, execução de programas)
- Otimizar performance de instruções complexas (POC)
- Suportar instruções mal-formadas (tolerância a erros)
- Criar interface de debug visual (apenas logs no console)

## Decisions

### Decision 1: Arquitetura em Camadas

O interpretador será dividido em módulos com responsabilidades claras:

```
┌─────────────────────────────────────────────────────────────┐
│                    sag-events.js                            │
│  (Fase 1 - já implementado)                                │
│  fireFieldEvent() / fireFormEvent()                        │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                 plsag-interpreter.js                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Parser    │→ │  Template   │→ │      Executor       │  │
│  │ tokenize()  │  │ substitute()│  │ executeInstruction()│  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│                                              │              │
│  ┌───────────────────────────────────────────┼────────────┐ │
│  │              ExecutionContext             │            │ │
│  │  formData, variables, queryResults, control           │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  plsag-commands.js                          │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐     │
│  │ field  │ │variable│ │message │ │control │ │  ex    │     │
│  │CE/CN/CS│ │VA/VP/PU│ │MA/MC/ME│ │IF/ELSE │ │EX-*    │     │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘     │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ (fetch API - comandos server-side)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  PlsagController.cs                         │
│  POST /api/plsag/query   - QY, QN                          │
│  POST /api/plsag/save    - DG, DM, D2, D3                  │
│  POST /api/plsag/execute - EX server-side                  │
└─────────────────────────────────────────────────────────────┘
```

**Rationale:** Separação clara permite testes unitários, manutenção independente, e reuso de módulos.

### Decision 2: Regra dos 8 Caracteres no Parser

Implementar parsing estrito conforme especificação BNF:

```javascript
function parseInstruction(raw) {
    const prefix = raw.substring(0, 2);
    const hasSeparator = raw[2] === '-';

    let identifier, parameter;
    if (hasSeparator) {
        identifier = raw.substring(3, 11).padEnd(8, ' ');
        parameter = raw.substring(12);
    } else {
        identifier = raw.substring(2, 10).padEnd(8, ' ');
        parameter = raw.substring(11);
    }

    return { prefix, identifier: identifier.trim(), parameter };
}
```

**Rationale:** Garante compatibilidade com instruções existentes no banco.

### Decision 3: Contexto de Execução Persistente

Manter estado entre instruções via objeto `ExecutionContext`:

```javascript
const context = {
    formData: {},              // Campos do formulário
    variables: {
        integers: {},          // VA-INTE0001 a VA-INTE0020
        floats: {},            // VA-FLOA0001 a VA-FLOA0020
        strings: {},           // VA-TEXT0001 a VA-TEXT0020
        dates: {},             // VA-DATA0001 a VA-DATA0020
        custom: {}             // Variáveis personalizadas
    },
    system: {
        'INSERIND': false,     // Modo inserção
        'ALTERIND': false,     // Modo alteração
        'CODIPESS': null,      // etc.
    },
    queryResults: {},          // Resultados de QY/QN
    control: {
        shouldStop: false,
        ifStateStack: [],
        currentIfState: 'NORMAL'
    }
};
```

**Rationale:** Permite que instruções subsequentes acessem resultados de queries anteriores e variáveis definidas.

### Decision 4: Comandos Assíncronos via async/await

Comandos que dependem de API ou UI serão assíncronos:

```javascript
async function executeInstruction(token, context) {
    switch (token.prefix) {
        case 'QY':
            return await queryCommands.QY(token, context);
        case 'MC':
            return await messageCommands.MC(token, context);
        default:
            return fieldCommands[token.prefix]?.(token, context);
    }
}
```

**Rationale:** Navegadores não permitem operações síncronas que bloqueiem UI. async/await mantém código legível.

### Decision 5: Validação de SQL no Backend

Todo SQL executado via PLSAG será validado:

```csharp
private bool IsValidPlsagQuery(string sql) {
    var blockedPatterns = new[] {
        "DROP ", "TRUNCATE ", "ALTER ", "CREATE ",
        "GRANT ", "REVOKE ", "xp_", "sp_", "--", "/*"
    };

    var sqlUpper = sql.ToUpperInvariant();
    return !blockedPatterns.Any(p => sqlUpper.Contains(p));
}
```

**Rationale:** Previne SQL injection e comandos destrutivos acidentais.

**Alternatives considered:**
- Parameterized queries: Difícil com SQL dinâmico do PLSAG
- Whitelist de tabelas: Muito restritivo para uso real
- Execução em sandbox: Overhead de performance

### Decision 6: IF/ELSE via Máquina de Estados

Controle de fluxo usando pilha de estados:

```javascript
const states = {
    NORMAL: 'NORMAL',
    IN_IF_TRUE: 'IN_IF_TRUE',
    IN_IF_FALSE: 'IN_IF_FALSE',
    IN_ELSE: 'IN_ELSE'
};

function enterIf(condition) {
    stateStack.push(currentState);
    currentState = condition ? states.IN_IF_TRUE : states.IN_IF_FALSE;
}

function handleElse() {
    if (currentState === states.IN_IF_TRUE) {
        currentState = states.IN_IF_FALSE; // Pula ELSE
    } else if (currentState === states.IN_IF_FALSE) {
        currentState = states.IN_ELSE; // Executa ELSE
    }
}

function handleFina() {
    currentState = stateStack.pop() || states.NORMAL;
}
```

**Rationale:** Suporta blocos IF aninhados de forma clara e testável.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Performance com muitas instruções | Limite de 1000 instruções por execução, log de warning |
| SQL injection via PLSAG | Validação no backend, whitelist de operações |
| Comandos não suportados quebram fluxo | Fallback gracioso com log, continua execução |
| Diferença de timing (sync vs async) | Documentar, testar cenários críticos |
| Incompatibilidade com Delphi | Testes de paridade em formulários reais |

## Migration Plan

1. **Fase 1 (já concluída)**: Sistema de eventos em sag-events.js
2. **Fase 2A**: Implementar core do interpretador (parser, templates)
3. **Fase 2B**: Implementar comandos client-side (CE/CN/CS, VA/VP, MA/MC)
4. **Fase 2C**: Implementar API backend (PlsagController.cs)
5. **Fase 2D**: Implementar comandos server-side (QY/QN, DG/DM)
6. **Fase 2E**: Implementar controle de fluxo (IF/ELSE, WH)
7. **Fase 2F**: Integrar com sag-events.js
8. **Fase 2G**: Testes de paridade com Delphi

**Rollback:** Remover chamada ao interpretador em sag-events.js restaura comportamento anterior (apenas logs).

## Open Questions

1. **Limite de instruções**: Qual o máximo razoável por execução? (proposta: 1000)
2. **Timeout de queries**: Quanto tempo esperar por resposta da API? (proposta: 30s)
3. **Cache de queries**: Cachear resultados de QY para mesma sessão? (proposta: não na POC)
4. **Comandos EX**: Implementar todos 80+ ou subset? (proposta: subset mais usados)
