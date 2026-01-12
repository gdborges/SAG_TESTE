# Resumo - Gap Lookup de Produtos na Tela 83600 (Pedidos)

## 🎯 Objetivo
Corrigir o lookup de produtos (CODIPROD) no modal de movimento da tela de pedidos (83600 → 83603). No Delphi mostra **3 produtos** (PINTOS DE 1 DIA), na Web mostra **1668 produtos**.

---

## 📊 Situação Atual

### Delphi (Comportamento Esperado)
- Abre tela 83600 (Pedidos)
- Seleciona pessoa "Granaleiro 2"
- Preenche defaults automaticamente (Tipo Venda, Condição Pagamento, etc.)
- Clica "Incluir Produto" → abre modal 83603
- Clica no botão lookup de CODIPROD
- **Mostra apenas 3 produtos**: PINTOS DE 1 DIA (MACHO, FEMEA, MISTO)

### Web (Comportamento Atual - Incorreto)
- Abre tela 83600
- Seleciona pessoa
- Defaults preenchem corretamente ✅
- Clica "Incluir Produto" → modal abre
- Clica lookup de CODIPROD
- **Mostra 1668 produtos** (após nossa correção de remover `= 0`)

---

## 🔍 Achados Técnicos

### 1. SQL_CAMP do Campo CODIPROD
```sql
SELECT CODIPROD, NOMEPROD || ' - '||UPPER(POCAUNID.NOMEUNID) AS NOMEPROD, ...
FROM POCAPROD
INNER JOIN POCAUNID ON POCAPROD.CODIUNID = POCAUNID.CODIUNID
INNER JOIN POGESGPR ON POCAPROD.CODISGPR = POGESGPR.CODISGPR
WHERE ATIVPROD = 1
AND POCAPROD.CODIPROD = 0    -- ⚠️ PROBLEMA
ORDER BY NOMEPROD
```

### 2. Descoberta dos 3 Produtos
```sql
-- Produtos que aparecem no Delphi:
CODIPROD  NOMEPROD                 CODIPLAN  CODISGPR
3814      PINTOS DE 1 DIA (MACHO)  4833      547
3985      PINTOS DE 1 DIA (FEMEA)  4833      547
3986      PINTOS DE 1 DIA (MISTO)  4833      547

-- Descoberta crucial:
SELECT COUNT(*) FROM POCAPROD WHERE ATIVPROD = 1 AND CODIPLAN = 4833
-- Resultado: 3 produtos (exatamente os 3 que aparecem no Delphi!)
```

**✅ Comprovado**: O filtro real do Delphi é `CODIPLAN = 4833`, NÃO `CODIPROD = 0`.

### 3. Mecanismo do Delphi (Descoberto via Code Analysis)

**Arquivo**: `Base/PlusUni.pas` - Função `SubsCampPers()` (linhas 2670-3130)

**Como funciona:**
1. SQL é armazenado em **2 lugares**:
   - `SQL_Back`: Template original com placeholders `{DG-CAMPO}`, `{CT-CAMPO}`, etc.
   - `SQL.Text`: SQL executável com placeholders substituídos

2. Placeholders são substituídos dinamicamente:
   - `{DG-CAMPO}`: Pega valor do campo do cabeçalho (Data Gravação)
   - `{DM-CAMPO}`: Pega valor do movimento
   - `{CT-CAMPO}`: Lookup text field
   - `{QY-CAMPO-COLUNA}`: Resultado de query prévia

3. Quando campo pai muda (ex: CODITPVE):
   - Evento OnExit dispara
   - Executa comando PLSAG (ex: `CA,CODIPROD,ABRE`)
   - Chama `SubsCampPers()` novamente
   - Reconstrói SQL com novos valores

### 4. Nossa Correção Implementada

✅ **MovementController.cs** - Adicionado `PopulateLookupOptionsAsync()`:
```csharp
// Linha 317-338
private async Task PopulateLookupOptionsAsync(List<FieldMetadata> fields)
{
    var lookupTypes = new[] { "L", "T", "IT", "IL" };
    var lookupFields = fields.Where(f =>
        lookupTypes.Contains(f.CompCamp?.ToUpper()) &&
        !string.IsNullOrEmpty(f.SqlCamp));

    foreach (var field in lookupFields)
    {
        field.LookupOptions = await _lookupService.ExecuteLookupQueryAsync(field.SqlCamp!);
    }
}
```

✅ **LookupService.cs** - Adicionado `RemoveSqlPlaceholders()`:
```csharp
// Linha 33-34: Remove "= 0" antes de executar SQL
sql = RemoveSqlPlaceholders(sql);

// Linha 257-295: Regex para remover padrões "AND campo = 0"
```

**Resultado**: Produtos aumentaram de 18 para 1668 (mas ainda não está correto - deveria ser 3).

---

## ❓ Dúvidas Críticas

### 1. **De onde vem o filtro `CODIPLAN = 4833`?**

Hipóteses:
- ❓ Vem do Tipo de Venda (CODITPVE)?
- ❓ Vem da Pessoa selecionada (CODIPESS)?
- ❓ Vem da Tabela de Preço (CODITBPR)?
- ❓ É aplicado via evento PLSAG no OnShow da tela 83603?

### 2. **Onde está o placeholder real no SQL_CAMP?**

O SQL_CAMP tem `CODIPROD = 0` literal, mas deveria ter algo como:
- `POCAPROD.CODIPLAN = {DG-CODIPLAN}`?
- `POCAPROD.CODIPLAN = {QY-CODITPVE-CODIPLAN}`?
- `POCAPROD.SISTPROD LIKE '%' || {DG-CODITPVE} || '%'`?

O SQL no banco **não tem placeholder**, mas o Delphi aplica filtro. Como?

### 3. **O filtro é estático ou dinâmico?**

- **Estático**: Sempre 3 produtos (CODIPLAN = 4833) independente do contexto
- **Dinâmico**: Muda conforme Tipo de Venda, Pessoa, ou Tabela de Preço

Usuário não conseguiu testar mudando Tipo de Venda (só tem 1 opção no dropdown).

---

## 🧩 Próximos Passos (Rastreamento de Eventos)

Conforme sugestão do usuário, precisamos rastrear a **cadeia de eventos**:

### A. Botão "Incluir Produto" (Tela 83600)
1. ✅ Arquivo: `Base/POHeCam6.pas`
2. Procurar evento do botão (ex: `BtnNovProduto.OnClick`)
3. Ver que tela/modal é chamado
4. Quais parâmetros são passados

### B. Abertura do Modal de Produto (Tela 83603)
1. Como campos são inicializados
2. Eventos OnShow da tela
3. Comandos PLSAG executados (ex: `CA,CODIPROD,ABRE`)

### C. Botão Lookup do CODIPROD
1. Como SQL é montado/modificado
2. Se há evento OnBeforeOpen
3. Como `SubsCampPers()` é chamado
4. Que variáveis de contexto são usadas

### D. Código a Investigar
```
Base/POHeCam6.pas - Eventos da tela de pedidos
Base/PlusUni.pas - SubsCampPers (linha 2670-3130)
                 - CampPersExecExit (linha 3698)
                 - CampPersExecListInst (linha 3731)
```

---

## 📁 Arquivos Modificados

### Backend (C#)
1. **SagPoc.Web/Controllers/MovementController.cs**
   - Adicionado `ILookupService` (linha 17, 30)
   - Adicionado `PopulateLookupOptionsAsync()` (linha 317-338)
   - Modificado `GetMovementForm` para chamar PopulateLookupOptionsAsync

2. **SagPoc.Web/Services/LookupService.cs**
   - Adicionado `RemoveSqlPlaceholders()` (linha 257-295)
   - Chamado antes de executar query (linha 34)

### Estado do Banco
- ✅ **Não modificamos nada** no Oracle
- ✅ SQL_CAMP permanece com `CODIPROD = 0` (como está no Delphi)
- ✅ Confirmado: Se funciona no Delphi, problema é na Web

---

## 🔧 Estratégias Possíveis

### Opção 1: Encontrar o Placeholder Real
Se SQL_CAMP deveria ter `{DG-ALGO}`, atualizar no banco.
**Risco**: Não sabemos se isso está correto.

### Opção 2: Implementar Filtro Contextual no Backend
No `MovementController.GetMovementForm()`, antes de popular lookup:
```csharp
// Detecta contexto do cabeçalho
var headerData = await GetHeaderContext(parentId);
var codiTPVE = headerData["CODITPVE"];

// Modifica SQL dinamicamente
if (field.NomeCamp == "CODIPROD" && codiTPVE != null)
{
    sql = sql.Replace("CODIPROD = 0", $"CODIPLAN = (SELECT CODIPLAN FROM ... WHERE CODITPVE = {codiTPVE})");
}
```

### Opção 3: Rastrear Eventos PLSAG
Implementar comandos `CA` (Campo Abre) que executam antes do lookup abrir:
```javascript
// sag-events.js - Antes de abrir lookup
if (command === 'CA' && fieldName === 'CODIPROD') {
    // Reconstrói SQL com contexto atual
    sql = SubsCampPers(sqlBack, formContext);
}
```

---

## 📊 Estatísticas

- **Total produtos ativos**: 9639
- **Após JOINs + ATIVPROD = 1**: ~1668
- **Com CODIPLAN = 4833**: 3 ✅ (match Delphi)
- **Tipo de Venda selecionado**: 787 (Frango Vivo, TIPOTPVE = 'FRAN')
- **Pessoa selecionada**: 123 (Granaleiro 2)

---

## ✅ Conclusão Temporária

O problema **NÃO é** remover `= 0`. O problema é descobrir **qual filtro contextual** o Delphi aplica para reduzir de 9639 produtos para 3.

**Próximo passo crítico**: Rastrear no código Delphi (`POHeCam6.pas` e `PlusUni.pas`) a cadeia de eventos desde clicar "Incluir Produto" até abrir o lookup de CODIPROD, identificando exatamente onde e como o filtro `CODIPLAN = 4833` é aplicado.

---

## 📝 Notas de Investigação

### Comandos PLSAG Relevantes (de PlusUni.pas)
- **CA** (Campo Abre): Abre/recarrega query de lookup
- **QY** (Query): Executa SQL e armazena resultado
- **QD** (Query Define): Define SQL para um campo
- **SubsCampPers**: Substitui placeholders `{XX-CAMPO}` por valores reais

### Padrão Delphi para Lookups Dinâmicos
```delphi
// 1. Armazena SQL template
Qry.SQL_Back.Text := 'SELECT ... WHERE CAMPO = {DG-PARENT_CAMPO}';

// 2. Executa substituição
Qry.SQL.Text := SubsCampPers(Form, Qry.SQL_Back.Text);

// 3. Abre query
Qry.Open;
```

### Locais para Investigar
1. **POHeCam6.pas**: Evento do botão "Novo" do movimento
2. **Criação do campo CODIPROD**: Como é inicializado no movimento
3. **SISTCAMP.EXPRCAMP**: Scripts PLSAG do campo CODIPROD (já temos, mas não mostra CA)
4. **Eventos de tabela**: OnShow da tabela 83603

---

**Data**: 2026-01-11
**Status**: Em investigação - Pausado para análise de eventos Delphi
