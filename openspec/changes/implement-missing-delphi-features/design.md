# Design: Implement Missing Delphi Features

## Visao Arquitetural

Este documento descreve as decisoes de design para implementacao das funcionalidades perdidas do Delphi, mantendo consistencia com a arquitetura existente.

---

## 1. InicValoCampPers - Valores Default

### Decisao: Estender ApplyFieldDefaultsAsync existente

**Justificativa:** Ja existe infraestrutura para defaults de D/DH e C. Adicionar S/E/N segue o mesmo padrao.

```
ApplyFieldDefaultsAsync(fields, values)
    |
    +-- Para cada field com InicCamp = 1:
        |
        +-- Switch (CompCamp):
            +-- 'D', 'DH': DateTime.Today/Now    [EXISTENTE]
            +-- 'C': Primeiro valor de VaGrCamp  [EXISTENTE]
            +-- 'S': PadrCamp (0 ou 1)           [NOVO]
            +-- 'E': PadrCamp se nao vazio       [NOVO]
            +-- 'N', 'EN': PadrCamp se definido  [NOVO]
```

### Nao Fazer
- Nao criar servico separado (complexidade desnecessaria)
- Nao modificar frontend (backend ja retorna valores)

---

## 2. InicCampSequ - Numeracao Automatica

### Decisao: Criar SequenceService dedicado

**Justificativa:**
- Logica complexa (3 tipos de sequencia)
- Requer acesso a tabela POCaNume
- Potencial reutilizacao em outros contextos

### Arquitetura

```
ISequenceService
    |
    +-- GetNextSequenceAsync(codiNume)     -> Tipo _UN_
    |       Busca POCaNume, incrementa, retorna formatado
    |
    +-- GetNextMaxPlusOneAsync(table, col) -> Tipo SEQU
    |       SELECT MAX(col) + 1 FROM table
    |
    +-- GetFieldsRequiringSequenceAsync(tableId)
            SELECT FROM SISTCAMP WHERE TagQCamp=1 AND InicCamp=1
```

### Integracao com CRUD

```
CreateEmptyRecordAsync(tableId)
    |
    +-- GetFieldsRequiringSequenceAsync(tableId)
    |
    +-- Para cada campo:
    |       |
    |       +-- Se ExisCamp = 0 (campo nao existe ainda):
    |               |
    |               +-- Gera sequencia
    |               +-- Adiciona ao dicionario de valores
    |
    +-- Cria registro com valores
```

### Alternativa Descartada
- Gerar no frontend: Rejeitado pois sequencia deve ser atomica no servidor

---

## 3. BtnConf_CampModi - Validacao de Modificacao

### Decisao: Criar ValidationService separado

**Justificativa:**
- Responsabilidade distinta de CRUD
- Pode ser reutilizado em outros controllers
- Facilita testes unitarios

### Arquitetura

```
IValidationService
    |
    +-- GetProtectedFieldsAsync(tableId)
    |       Retorna campos: MarcCamp=1 OU ApAt{SiglTabe}* OU Calculados
    |
    +-- ValidateModificationsAsync(tableId, original, modified)
            |
            +-- Para cada campo protegido:
            |       Se original[campo] != modified[campo]:
            |           violations.Add(campo, mensagem)
            |
            +-- Return ValidationResult { IsValid, Violations }
```

### Fluxo no Controller

```
SaveRecord(request)
    |
    +-- Se request.IsUpdate:
    |       |
    |       +-- original = GetRecordByIdAsync(...)
    |       +-- result = ValidateModificationsAsync(original, request.Data)
    |       |
    |       +-- Se !result.IsValid:
    |               Return BadRequest(result.Violations)
    |
    +-- Continua com save normal
```

### Frontend
- Mostrar toast com campos violados
- Opcionalmente: destacar campos com borda vermelha

---

## 4. Tipos de Componente

### Decisao: Estender _FieldRendererV2.cshtml com novos cases

**Justificativa:** Padrao ja estabelecido para outros tipos.

### Mapeamento HTML

| CompCamp | Componente Delphi | HTML Web | Classes CSS |
|----------|-------------------|----------|-------------|
| BTN | TsgBtn | `<button>` | btn btn-secondary btn-sm |
| IE/IM/IR/IN | TEdtLbl info | `<span>` | form-control-plaintext text-muted |
| LBL | TLabel | `<label>` | form-label static-label |
| EE/LE | TEdtLbl calc | `<input readonly>` | form-control calculated-field |
| EN/LN | TRxEdtLbl calc | `<input readonly>` | form-control calculated-field |

### Botao (BTN) - Eventos

```html
<button type="button"
        class="btn btn-secondary btn-sm"
        data-field-name="@field.NomeCamp"
        data-plsag-onclick="@field.ExprCamp">
    @field.LabeCamp
</button>
```

```javascript
// sag-events.js
document.querySelectorAll('[data-plsag-onclick]').forEach(btn => {
    btn.addEventListener('click', async () => {
        const instructions = btn.dataset.plsagOnclick;
        await sagEvents.executeInstructions(instructions);
    });
});
```

---

## 5. DuplCliq - Duplo Clique

### Decisao: Reutilizar modal de consulta existente

**Justificativa:**
- Consulta-grid ja tem toda infraestrutura de busca
- Evita duplicacao de codigo

### Fluxo

```
Usuario duplo-clica em campo T/IT/L/IL
    |
    +-- Obtem SQL_CAMP do campo (data-sql-camp)
    |
    +-- Abre modal de lookup expandido
    |       - Executa query
    |       - Mostra grid paginado
    |       - Permite busca
    |
    +-- Usuario seleciona linha
    |
    +-- Preenche campo principal (key)
    |
    +-- Preenche campos IE associados (via data)
    |
    +-- Fecha modal
    |
    +-- Dispara evento OnExit do campo
```

### Diferenca de F2 (Consulta) vs DblClick
- F2: Abre consulta padrao da tabela
- DblClick: Abre lookup especifico do campo (SQL_CAMP)

---

## 6. Eventos de Movimento

### Decisao: Completar implementacao existente

**Situacao Atual:**
- EventService ja carrega alguns eventos
- movement-manager.js tem estrutura basica

**A Completar:**
- Garantir carregamento de TODOS os eventos
- Implementar execucao no momento correto
- Implementar bloqueio se Ante* retornar false

### Timeline de Eventos

```
Insert Movement:
    AnteIAE_Movi_{CodiTabe}  [pode bloquear]
    AnteIncl_{CodiTabe}      [pode bloquear]
    --- INSERT no banco ---
    DepoIncl_{CodiTabe}      [pos-processamento]
    AtuaGrid_{CodiTabe}      [atualiza grid]

Update Movement:
    AnteIAE_Movi_{CodiTabe}  [pode bloquear]
    AnteAlte_{CodiTabe}      [pode bloquear]
    --- UPDATE no banco ---
    DepoAlte_{CodiTabe}      [pos-processamento]
    AtuaGrid_{CodiTabe}      [atualiza grid]

Delete Movement:
    AnteIAE_Movi_{CodiTabe}  [pode bloquear]
    AnteExcl_{CodiTabe}      [pode bloquear]
    --- DELETE no banco ---
    DepoExcl_{CodiTabe}      [pos-processamento]
    AtuaGrid_{CodiTabe}      [atualiza grid]
```

---

## 7. MudaTab2 - Navegacao ESC

### Decisao: Handler global de teclado

**Justificativa:** Simples e eficaz.

### Implementacao

```javascript
// sag-events.js
document.addEventListener('keydown', (e) => {
    if (e.key !== 'Escape') return;

    // Ignora se modal aberto
    if (document.querySelector('.modal.show')) return;

    // Encontra aba ativa
    const activeTab = document.querySelector('.nav-link.active[data-bs-toggle="tab"]');
    if (!activeTab) return;

    // Encontra proxima aba visivel
    const tabs = Array.from(document.querySelectorAll('.nav-link[data-bs-toggle="tab"]'))
        .filter(t => !t.classList.contains('d-none'));

    const currentIndex = tabs.indexOf(activeTab);

    if (currentIndex < tabs.length - 1) {
        // Ativa proxima aba
        new bootstrap.Tab(tabs[currentIndex + 1]).show();
    } else {
        // Ultima aba: foca no Confirmar
        document.getElementById('btnConfirmar')?.focus();
    }
});
```

### Alternativa Descartada
- Usar Tab ao inves de ESC: Conflita com navegacao padrao de campos

---

## Decisoes Transversais

### Tratamento de Erros
- Todos os services devem logar erros via ILogger
- Controllers retornam mensagens amigaveis em portugues
- Frontend exibe toasts para erros de usuario

### Performance
- Queries de metadados devem usar cache (implementar se necessario)
- Evitar N+1 queries em loops

### Compatibilidade
- Manter compatibilidade com Oracle e SQL Server
- Usar IDbProvider para queries especificas

### Testes
- Priorizar testes manuais na POC
- Documentar cenarios de teste em cada fase
