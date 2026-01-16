# Design: Movement System for Web

## Context

O sistema SAG Delphi implementa movimentos atraves das classes TFrmPOHeCam6, TMovi, TFraCaMv e TFraGrMv. Este design documenta como transpor essa arquitetura para ASP.NET MVC web, adaptando para o modelo stateless HTTP enquanto mantemos fidelidade funcional.

### Stakeholders
- Desenvolvedores SAG
- Usuarios finais do sistema ERP

### Constraints
- HTTP e stateless - sem conexao persistente
- Modal nao pode bloquear como ShowModal do Delphi
- Views Razor sao pre-compiladas (sem FindClass dinamico)
- Transacoes de banco nao podem atravessar requests

## Goals / Non-Goals

### Goals
- Carregar tabelas de movimento via CABETABE do SISTTABE
- Renderizar grids de movimento com CRUD funcional
- Suportar layout SERITABE (>50 mesma guia, <=50 guia separada)
- Executar eventos PLSAG de movimento (AnteIAE_Movi, DepoIncl, etc.)
- Suportar 2 niveis de hierarquia (Cabecalho -> Movimento -> Sub-movimento)
- Integrar templates {DM-Campo} e {D2-Campo} no PLSAG interpreter

### Non-Goals
- Transacao compartilhada entre cabecalho e movimentos
- Suporte a D3 (3o nivel de movimento)
- Orphan record cleanup (nao criamos registro ate confirmacao)
- Hierarquia de decorators (Prin_D.Pai_Prin_D)
- SuspendLayouts/ResumeLayouts (nao aplicavel em DOM)

## Decisions

### D1: Transacao por Operacao

**Decisao**: Cada INSERT/UPDATE/DELETE e uma transacao independente.

**Alternativas consideradas**:
1. Transacao em sessao (como Delphi)
   - Pro: Mais fiel ao original
   - Con: Complexidade de timeout, limpeza, estado de sessao
2. Transacao por operacao (escolhido)
   - Pro: Simples, stateless, sem gerenciamento de estado
   - Con: Consistencia eventual (aceitavel para POC)

**Racional**: A arquitetura web e fundamentalmente diferente. Manter transacoes abertas em sessao introduziria complexidade desproporcional para o beneficio.

### D2: Modal Nao-Bloqueante

**Decisao**: Bootstrap modal com backdrop removido, permitindo interacao com o sistema.

**Implementacao**:
```javascript
const modal = new bootstrap.Modal(element, {
    backdrop: false,  // Nao bloqueia cliques fora
    keyboard: true
});
```

**Alternativas consideradas**:
1. Modal bloqueante (backdrop: 'static')
   - Con: Nao permite outras operacoes simultaneas
2. Panel flutuante (draggable)
   - Pro: Mais flexivel
   - Con: Mais complexo de implementar
3. Modal nao-bloqueante (escolhido)
   - Pro: Balanco entre simplicidade e flexibilidade

### D3: Layout SERITABE

**Decisao**: Respeitar a logica SERITABE do Delphi.

| SERITABE | Comportamento |
|----------|---------------|
| > 50 | Movimento na mesma guia do cabecalho (abaixo dos campos) |
| <= 50 | Movimento em guia separada |

**Implementacao em Render.cshtml**:
```razor
@foreach (var movement in Model.Form.MovementTables)
{
    if (movement.SeriTabe > 50)
    {
        <!-- Renderiza inline na guia atual -->
    }
    else
    {
        <!-- Cria nova tab -->
    }
}
```

### D4: Hierarquia 2 Niveis

**Decisao**: Suportar Cabecalho -> Movimento -> Sub-movimento via CABETABE recursivo.

**Estrutura de dados**:
```csharp
public class MovementMetadata
{
    public int CodiTabe { get; set; }          // ID desta tabela
    public int? CabeTabe { get; set; }         // ID do pai (null = cabecalho)
    public int SeriTabe { get; set; }          // Posicao visual
    public string GravTabe { get; set; }       // Nome fisico da tabela
    public List<MovementMetadata> Children { get; set; } // Sub-movimentos
}
```

**Query para carregar hierarquia**:
```sql
-- Nivel 1: Movimentos do cabecalho
SELECT * FROM SISTTABE WHERE CABETABE = @CodiTabe

-- Nivel 2: Sub-movimentos de cada movimento
SELECT * FROM SISTTABE WHERE CABETABE = @MovimentoCodiTabe
```

### D5: Nao Criar Registro Antecipado

**Decisao**: Diferente do Delphi, so criar registro ao confirmar.

**Delphi (original)**:
1. Usuario clica "Novo"
2. Sistema faz INSERT com dados minimos
3. Abre modal para edicao
4. Se cancelar: DELETE do registro
5. Se confirmar: UPDATE com dados completos

**Web (nova abordagem)**:
1. Usuario clica "Novo"
2. Abre modal vazio (sem INSERT)
3. Se cancelar: Nada acontece
4. Se confirmar: INSERT com dados completos

**Racional**: Padrao moderno, evita orphan records, mais seguro.

### D6: Mapeamento de Componentes Delphi -> Web

| Delphi | Web | Notas |
|--------|-----|-------|
| TFrmPOHeCam6 | Render.cshtml + MovementController | View + API |
| TMovi | MovementContext (JS) | Objeto wrapper |
| TFraCaMv | _MovementSection.cshtml | Partial view |
| TFraGrMv | _MovementGrid.cshtml | Partial view |
| TConfTabe | MovementMetadata | C# model |
| ListMovi | Form.MovementTables[] | Lista no model |
| PSitGrav | data-mode="view/insert/edit" | Atributo HTML |
| Prin_D | MovementService | Service simplificado |

### D7: Eventos de Movimento

**Nomenclatura de eventos** (campos virtuais no SISTCAMP):

| Campo | Quando Executar |
|-------|-----------------|
| AnteIAE_Movi_<CodiTabe> | Antes de qualquer operacao CRUD |
| AnteIncl_<CodiTabe> | Antes de INSERT |
| AnteAlte_<CodiTabe> | Antes de UPDATE |
| AnteExcl_<CodiTabe> | Antes de DELETE |
| DepoIAE_Movi_<CodiTabe> | Depois de qualquer operacao CRUD |
| DepoIncl_<CodiTabe> | Depois de INSERT |
| DepoAlte_<CodiTabe> | Depois de UPDATE |
| DepoExcl_<CodiTabe> | Depois de DELETE |
| AtuaGrid_<CodiTabe> | Ao carregar/atualizar grid |
| ShowPai_Filh_<CodiTabe> | Ao abrir modal do filho |

**Fluxo de execucao**:
```
Usuario clica "Novo"
  -> AnteIAE_Movi_<CodiTabe>
  -> AnteIncl_<CodiTabe>
  -> [Se bloqueado: para aqui]
  -> Abre modal
  -> Usuario confirma
  -> INSERT no banco
  -> DepoIAE_Movi_<CodiTabe>
  -> DepoIncl_<CodiTabe>
  -> AtuaGrid_<CodiTabe>
```

### D8: Templates PLSAG para Movimentos

**Novos templates a implementar**:

| Template | Fonte de Dados |
|----------|----------------|
| {DM-Campo} | Campos do movimento nivel 1 |
| {D2-Campo} | Campos do sub-movimento nivel 2 |

**Implementacao no plsag-interpreter.js**:
```javascript
// Adicionar contexto de movimento
context.movementData = {};      // DM
context.subMovementData = {};   // D2

// Substituicao de templates
function substituteTemplate(template, context) {
    // ... codigo existente para DG, VA, VP, PU ...

    // Novo: DM templates
    if (template.startsWith('{DM-')) {
        const fieldName = template.slice(4, -1);
        return context.movementData[fieldName] || '';
    }

    // Novo: D2 templates
    if (template.startsWith('{D2-')) {
        const fieldName = template.slice(4, -1);
        return context.subMovementData[fieldName] || '';
    }
}
```

## Risks / Trade-offs

### R1: Performance com Muitos Movimentos
- **Risco**: Grid lento com centenas de registros
- **Impacto**: Alto
- **Mitigacao**: Paginacao server-side, lazy loading

### R2: Conflitos de Edicao Concorrente
- **Risco**: Dois usuarios editam o mesmo registro
- **Impacto**: Medio
- **Mitigacao**: Lock otimista com timestamp (futuro)

### R3: Perda de Dados em Navegacao
- **Risco**: Usuario navega sem salvar
- **Impacto**: Alto
- **Mitigacao**: beforeunload warning, dirty flag

### R4: Complexidade da Hierarquia 2 Niveis
- **Risco**: Bugs em sub-movimentos
- **Impacto**: Medio
- **Mitigacao**: Testes extensivos, logging detalhado

## Migration Plan

Nao ha migracao - implementacao nova.

## Open Questions

1. **Limite de registros no grid**: Quantos registros exibir antes de paginar?
   - Sugestao: 50 por pagina

2. **Cache de metadados**: Devemos cachear MovementMetadata em sessao?
   - Sugestao: Nao, carregar por request (simplifica)

3. **Validacao server-side**: Eventos "Ante" devem validar no servidor?
   - Sugestao: Sim, para seguranca (nao confiar no client)
