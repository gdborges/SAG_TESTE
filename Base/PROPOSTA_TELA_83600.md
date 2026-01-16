# Proposta: Implementar Recursos Avançados da Tela 83600

## 1. Contexto

A tela 83600 (Pedidos Outros) utiliza `TFrmPOHeCam6` e apresenta funcionalidades avançadas que ainda nao estao implementadas na POC Web:

### Estrutura da Tela
```
CodiTabe: 83600
NomeTabe: Pedidos (Outros)
FormTabe: TFrmPOHeCam6
GravTabe: VDGEPEOU
SiglTabe: PEOU
Gui1Tabe: &Dados Gerais
Gui2Tabe: Dados Ad&icionais
TpGrTabe: 260 (altura do painel principal)
```

### Movimento Filho
```
CodiTabe: 83603
NomeTabe: Mov. Pedidos (Outros)
GravTabe: VDCAMVPO
SeriTabe: 51 (> 50 = movimento INLINE na mesma tab)
Gui1Tabe: Produtos
```

### Diferenca Fundamental: SeriTabe

| Tabela | SeriTabe | Layout |
|--------|----------|--------|
| 120 (Clientes) | <= 50 | Movimento em **TAB SEPARADA** no PgcGene |
| 83600 (Pedidos) | 51 (> 50) | Movimento **INLINE** no PnlDado/PgcMovi |

**Codigo Delphi (POHeCam6.pas:672-675):**
```pascal
if vMovi.SeriTabe > 50 then
  vTbs := CriaTbs(PgcMovi, ...)  // Tab interna no PnlDado
else
  vTbs := CriaTbs(PgcGene, ...)  // Tab separada no PageControl principal
```

### Layout Visual da 83600 (baseado na tela Delphi)

```
+== Tab "Dados Gerais" ==========================================+
|                                                                |
| [AREA SUPERIOR - Campos Cabecalho] (altura = TpGrTabe = 260px) |
| +------------------------------------------------------------+ |
| | Pessoa [___________] Cidade [_____] Pedido [6007]          | |
| | Tipo Movimento [___] Cond. Pagto [___] Documento [___]     | |
| | Custo Frete [___] Motivo Bloqueio [___] Desconto [100,00]  | |
| | Pedido Geral [___] Endereco Entrega [___] Tab. Preco [___] | |
| +------------------------------------------------------------+ |
|                                                                |
| [PnlDado - MOVIMENTO INLINE] (Align = alClient)                |
| +------------------------------------------------------------+ |
| | +-- Tab "* Produtos" (PgcMovi) --------------------------+ | |
| | | [Novo] [Altera] [Exclui]                               | | |
| | | +----------------------------------------------------+ | | |
| | | | CODIPROD | Cod | Produto | Qtde | Peso | Valor ... | | | |
| | | | ........ | ... | ....... | .... | .... | ......... | | | |
| | | +----------------------------------------------------+ | | |
| | +--------------------------------------------------------+ | |
| +------------------------------------------------------------+ |
|                                                                |
| [PAINEL RESUMO - Campos GuiaCamp=83603] (GUIARESU_83603=140px) |
| +------------------------------------------------------------+ |
| | Qtde Total [0,00] | Qtde Acer [0,00] | Peso Total [0,00]   | |
| | Mix [0,00] | Valor Total [0,00] | Mix Tabela | Valor Tab  | |
| | Desconto [0,00] [Rateia Dcto] | Frete [0,00] [Rateia Frete]| |
| +------------------------------------------------------------+ |
+================================================================+

+== Tab "Dados Adicionais" (GuiaCamp = 2) =======================+
|                                                                |
| [X Cancela] [✓ Autoriza]  Informacao Padrao [________▼] [🔍]  |
|                                                                |
| Motivo [________________________________________________]      |
|                                                                |
| +-- BVL Cai5PEOU (Caixa Agrupamento) ----------------------+   |
| | Documento [____________________________________________] |   |
| | Motivo do Bloqueio [___________________________________] |   |
| | Observacao Romaneio [__________________________________] |   |
| | Observacao Nota [______________________________________] |   |
| +----------------------------------------------------------+   |
|                                                                |
| Observacao do Pedido (CompCamp = 'M' - Memo multilinha)        |
| +----------------------------------------------------------+   |
| |                                                          |   |
| +----------------------------------------------------------+   |
|                                                                |
| +-- BVL Cai6PEOU (Caixa Agrupamento) ----------------------+   |
| | Transporte [___▼][🔍]  Frete por Conta [___▼]  [☐]      |   |
| | Pessoa-Entrega NF [___▼][🔍]    ART [___▼][🔍]          |   |
| | Setor [___▼][🔍]  Numero ART [___]  Incubatorio [___▼]  |   |
| +----------------------------------------------------------+   |
+================================================================+
```

---

## 2. Componentes da Tab "Dados Adicionais"

| Campo | Label | CompCamp | Status POC |
|-------|-------|----------|------------|
| CA30PEOU | - | BVL | Parcial (caixa agrupamento) |
| CANCPEOU | Cance&la | BTN | OK (botao PLSAG) |
| AUTOPEOU | A&utoriza | BTN | OK |
| CODIINFO | Informacao Padrao | T | OK (lookup) |
| MOTIPEOU | Motivo | EE | OK (edit extendido) |
| Cai5PEOU | - | BVL | Parcial |
| NRDOPEOU | Documento | E | OK |
| OBS_PEOU | Motivo do Bloqueio | E | OK |
| OBSRPEOU | Observacao Romaneio | E | OK |
| OBSNPEOU | Observacao Nota | E | OK |
| OBSEPEOU | Observacao do Pedido | **M** | **NOVO** (memo multilinha) |
| Cai6PEOU | - | BVL | Parcial |
| CODITRAN | Transporte | T | OK |
| FRCOPEOU | Frete por Conta | C | OK (combo) |
| GEENPESS | - | **ES** | **VERIFICAR** (checkbox?) |
| ENNFPESS | Pessoa-Entrega NF | T | OK |
| CODIART_ | ART | T | OK |
| CODISETO | Setor | T | OK |
| ART_PEOU | Numero ART | N | OK |
| CODIINCU | Incubatorio | T | OK |

### Componentes a verificar/implementar:

1. **BVL (Bevel/GroupBox)** - Caixas de agrupamento visuais
   - Atualmente renderizamos como `<fieldset>` mas sem posicionamento absoluto
   - Precisa agrupar campos filhos visualmente

2. **M (Memo)** - Campo textarea multilinha
   - Diferente de EE que e single-line grande
   - Precisa altura configuravel (AltuCamp)

3. **ES (Editor Sim/Nao)** - Checkbox sem databind (`TChkLbl`)
   - Diferente de 'S' que e `TDBChkLbl` (com databind)
   - Na tela aparece como checkbox sem label visivel

---

## 3. Gaps Identificados

### 3.1 Sistema de Consultas (SISTCONS)

**Situacao Atual:**
- A POC usa GRIDTABE/GRCOTABE de SISTTABE
- Funciona para tabelas simples

**Novo Requisito:**
- A tabela 83600 NAO tem GRIDTABE definido
- Usa a tabela SISTCONS com multiplas consultas:

```sql
SELECT CodiCons, NomeCons, AtivCons FROM SISTCONS WHERE CodiTabe = 83600;

-- Resultado:
-- 83600000 | Padrao                    | 1
-- 83600010 | Clientes-Ultimas Compras  | 1
-- 83600020 | Recibo de Venda           | 1
-- 83600030 | Duplicata da Venda        | 1
-- 83600040 | Pedido de Venda           | 1
```

**Campos importantes de SISTCONS:**
- `SQL_Cons` (CLOB): Query SQL completa
- `FiltCons` (CLOB): Configuracao de colunas e filtros
- `WherCons` (CLOB): WHERE adicional
- `OrByCons` (CLOB): ORDER BY
- `AtivCons`: Se a consulta esta ativa

**Formato de FiltCons:**
```
[COLUNAS]
Entrega=/Tama=90
Emissao=/Tama=90
Pedido=/Tama=90
Situacao=/Tama=110
Cod. Cliente=/Tama=90
...
```

### 3.2 Campos de Movimento no Cabecalho (GuiaCamp = CodiTabe)

**Situacao Atual:**
- Campos com GuiaCamp = 1 ou 2 sao renderizados nas guias
- Campos com GuiaCamp = 999 sao eventos especiais

**Novo Requisito:**
- Campos com GuiaCamp = CodiTabe do movimento (83603) sao totalizadores
- Aparecem em um painel de resumo (PnlResu) abaixo do grid de movimento:

```sql
SELECT NomeCamp, LabeCamp, CompCamp, GuiaCamp FROM SISTCAMP
WHERE CodiTabe = 83600 AND GuiaCamp = 83603;

-- Resultado:
-- CAI1MVPO | -              | BVL   (caixa de agrupamento)
-- TOQTMVPO | Qtde Total     | LN    (label numerico)
-- QTACMVPO | Qtde Acer.     | LN
-- PeToMVPO | Peso Total     | LN
-- Mix_MVPO | Mix            | LN
-- TOVLMVPO | Valor Total    | LN
-- MixTMVPO | Mix Tabela     | LN
-- ValTMVPO | Valor Tabela   | LN
-- DctoMvPo | Desconto       | EN    (editavel)
-- DctoRate | &Rateia Dcto.  | BTN   (botao)
-- FretMvPo | Frete          | EN
-- FretRate | Rateia &Frete  | BTN
```

### 3.3 Evento ATUAGRID_{CodiTabe}

**Situacao Atual:**
- Eventos OnExit/OnShow implementados parcialmente

**Novo Requisito:**
- Evento ATUAGRID executado apos atualizar o grid do movimento
- Usa template especial `{QY-DAD<CodiTabe>-<campo>}` para ler dados do grid

**Exemplo de ATUAGRID_83603:**
```
VA-REAL0001-{QY-DAD83603-SUM(Valor Tab.)}
VA-REAL0002-{QY-DAD83603-SUM(Peso Total)}
VA-REAL0003-{QY-DAD83603-SUM(Qtde)}
VA-REAL0004-{QY-DAD83603-SUM(Valor)}

--Valor Tabela
CN-ValTMVPO-{VA-REAL0001}

--Quantidade Total
CN-TOQTMVPO-{VA-REAL0003}

--Peso Total
CN-PeToMVPO-{VA-REAL0002}

--Valor Total
CN-TOVLMVPO-{VA-REAL0004}
```

**Template {QY-DAD<CodiTabe>-<expr>}:**
- `QY-DAD83603-NUMEREGI`: Numero de registros no grid
- `QY-DAD83603-SUM(Qtde)`: Soma da coluna Qtde
- `QY-DAD83603-SUM(Valor Tab.)`: Soma por alias da coluna

### 3.4 Painel de Resumo (GUIARESU)

**Campo especial:**
```sql
SELECT NomeCamp, TamaCamp, AltuCamp FROM SISTCAMP
WHERE CodiTabe = 83600 AND CompCamp = 'GUIARESU';

-- GUIARESU_83603 | 150 | 140
```

- Define a altura do painel de resumo para o movimento 83603
- Contem os campos com GuiaCamp = 83603

### 3.5 OnExit com Auto-Preenchimento

**Exemplo de CODIPESS:**
```
DG-CODICOND-{QY-CODIPESS-CODICOND}
DG-CODVPESS-{QY-CODIPESS-CODVPESS}
DG-ENNFPESS-{QY-CODIPESS-CodiPESS}
DG-CODITPDO-{QY-CODIPESS-CODITPDO}
LN-SADIPEOU-SELE
```

- Ao sair do lookup CODIPESS, preenche automaticamente outros campos
- Ja temos isso parcialmente (OnExit), mas precisa garantir que funciona com templates `{QY-campo-campo}`

---

## 3. Plano de Implementacao

### Fase 1: Sistema de Consultas SISTCONS

**Arquivos:**
- `Services/ConsultaConfigService.cs` (novo)
- `Models/ConsultaConfig.cs` (novo)
- `Controllers/FormController.cs` (atualizar GetConsultas)

**Tarefas:**
1. Criar modelo `ConsultaConfig` com campos de SISTCONS
2. Criar `ConsultaConfigService` para carregar consultas de SISTCONS
3. Modificar `GetConsultas` para priorizar SISTCONS sobre SISTTABE.GRIDTABE
4. Parsear FiltCons para configurar colunas do AG Grid
5. Suportar multiplas consultas no dropdown

**SQL de Carga:**
```sql
SELECT CodiCons, NomeCons, SQL_Cons, FiltCons, WherCons, OrByCons, AtivCons
FROM SISTCONS
WHERE CodiTabe = :tableId AND AtivCons = 1
ORDER BY OrdeConsend
```

### Fase 2: Campos de Movimento no Cabecalho

**Arquivos:**
- `Services/MetadataService.cs` (atualizar)
- `Models/MovementMetadata.cs` (atualizar)
- `Views/Form/_MovementSection.cshtml` (atualizar)
- `Views/Form/_MovementSummary.cshtml` (novo)

**Tarefas:**
1. Detectar campos com GuiaCamp = CodiTabe de um movimento filho
2. Criar modelo para campos de resumo (diferentes de campos do form)
3. Renderizar painel de resumo abaixo do grid de movimento
4. Conectar campos de resumo ao grid (para receber atualizacoes)

### Fase 3: Evento ATUAGRID

**Arquivos:**
- `wwwroot/js/plsag-interpreter.js` (atualizar)
- `wwwroot/js/plsag-commands.js` (atualizar)
- `wwwroot/js/movement-manager.js` (atualizar)

**Tarefas:**
1. Implementar template `{QY-DAD<CodiTabe>-<expr>}`
   - `NUMEREGI`: `gridApi.getDisplayedRowCount()`
   - `SUM(campo)`: Iterar linhas e somar
2. Disparar evento ATUAGRID apos operacoes CRUD no movimento
3. Atualizar campos LN (label numerico) com resultados

### Fase 4: Painel de Resumo Visual

**Arquivos:**
- `Views/Form/_MovementSummary.cshtml`
- `wwwroot/css/form-renderer.css`

**Tarefas:**
1. Criar partial view para painel de resumo
2. Renderizar BVL como agrupamento
3. Renderizar LN como labels com valor calculado
4. Renderizar EN como inputs editaveis
5. Renderizar BTN como botoes de acao (Rateia Dcto, Rateia Frete)

---

## 4. Estrutura do Painel de Resumo

```
+------------------------------------------------------------------+
| [Grid de Movimento 83603 - Produtos]                              |
+------------------------------------------------------------------+
| Painel de Resumo (GUIARESU_83603)                                |
| +--------------------------------------------------------------+ |
| | +---------------------------+ +-----------------------------+ | |
| | | Qtde Total:    [123.45]   | | Valor Tabela:  [9,876.54]  | | |
| | | Qtde Acer.:    [100.00]   | | Mix Tabela:    [12.34]     | | |
| | | Peso Total:    [500.00]   | | Valor Total:   [8,765.43]  | | |
| | | Mix:           [10.50]    |                              | | |
| | +---------------------------+ +-----------------------------+ | |
| | +----------------------------------------------------------+ | |
| | | Desconto: [____] [Rateia Dcto] Frete: [____] [Rateia Fr] | | |
| | +----------------------------------------------------------+ | |
| +--------------------------------------------------------------+ |
+------------------------------------------------------------------+
```

---

## 5. Template QY-DAD - Especificacao

```javascript
// Em plsag-interpreter.js

/**
 * Resolve template {QY-DAD<CodiTabe>-<expression>}
 *
 * Exemplos:
 * - {QY-DAD83603-NUMEREGI}           -> Numero de linhas
 * - {QY-DAD83603-SUM(Qtde)}          -> Soma da coluna "Qtde"
 * - {QY-DAD83603-SUM(Valor Tab.)}    -> Soma da coluna "Valor Tab."
 * - {QY-DAD83603-MIN(Preco)}         -> Minimo
 * - {QY-DAD83603-MAX(Preco)}         -> Maximo
 * - {QY-DAD83603-AVG(Preco)}         -> Media
 * - {QY-DAD83603-COUNT(*)}           -> Contagem
 */
function resolveQyDadTemplate(template) {
    const match = template.match(/\{QY-DAD(\d+)-(.+)\}/);
    if (!match) return template;

    const tableId = match[1];
    const expression = match[2];

    const gridApi = getMovementGridApi(tableId);
    if (!gridApi) return '0';

    if (expression === 'NUMEREGI') {
        return gridApi.getDisplayedRowCount();
    }

    const aggMatch = expression.match(/(SUM|MIN|MAX|AVG|COUNT)\((.+)\)/);
    if (aggMatch) {
        const func = aggMatch[1];
        const column = aggMatch[2];
        return calculateAggregate(gridApi, func, column);
    }

    return '0';
}
```

---

## 6. Estimativa de Esforco

| Fase | Tarefas | Complexidade |
|------|---------|--------------|
| 1. SISTCONS | 5 | Media |
| 2. Campos Movimento | 4 | Alta |
| 3. ATUAGRID | 3 | Alta |
| 4. Painel Resumo | 5 | Media |

---

## 7. Dependencias

1. **AG Grid Enterprise** - Ja implementado
2. **PLSAG Interpreter** - Ja implementado, precisa extensao
3. **Movement Manager** - Ja implementado, precisa extensao

---

## 8. Testes

### Cenario 1: Consultas SISTCONS
1. Abrir tela 83600
2. Verificar dropdown com 5 consultas
3. Trocar entre consultas e verificar dados diferentes

### Cenario 2: Painel de Resumo
1. Incluir/alterar itens no movimento
2. Verificar atualizacao automatica dos totalizadores
3. Testar botoes Rateia Dcto e Rateia Frete

### Cenario 3: ATUAGRID
1. Adicionar item ao movimento
2. Verificar execucao do evento ATUAGRID_83603
3. Confirmar valores calculados corretos

---

## 9. Riscos

1. **Performance de agregacoes** - Calcular SUM em grids grandes pode ser lento
   - Mitigacao: Usar colPivotMode do AG Grid quando disponivel

2. **Sincronizacao de dados** - Garantir que o grid esta atualizado antes de calcular
   - Mitigacao: Usar eventos afterRefresh do AG Grid

3. **Templates complexos** - Expressoes aninhadas
   - Mitigacao: Parser robusto com tratamento de erros

---

## 10. Proximos Passos

1. Validar esta proposta
2. Criar OpenSpec change para cada fase
3. Implementar em ordem de dependencia (Fase 1 -> 2 -> 3 -> 4)
4. Testar com tabela 83600 como caso de uso principal
