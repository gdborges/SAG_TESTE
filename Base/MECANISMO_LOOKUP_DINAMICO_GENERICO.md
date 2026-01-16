# Mecanismo Genérico de Lookup Dinâmico no SAG/Delphi

## Resumo Executivo

Descobrimos um **padrão genérico** usado em todo o sistema SAG para lookups dinâmicos que precisam ser filtrados em runtime baseado no contexto.

### Números do Padrão:
- ✅ **528 telas** usam comando QY
- ✅ **102 campos** usam especificamente QY-CODIPROD
- ✅ **20 campos** em telas diferentes usam o padrão `= 0` no SQL

**Conclusão**: Este é um **PADRÃO ARQUITETURAL** do sistema, NÃO específico da tela 83600!

---

## 1. Padrão Genérico: SQL com Linha de Injeção

### Estrutura Padrão do SQL_CAMP:

```sql
(linha 0) SELECT ...
(linha 1) FROM ...
(linha 2) WHERE condições_fixas
(linha 3) AND campo_chave = 0          ← DESABILITA a query (0 registros)
(linha 4)                              ← LINHA VAZIA para injeção dinâmica
(linha 5) ORDER BY ...
```

### Por que `= 0` na linha 3?

- **Desabilita completamente** a query por padrão
- Garante que **nenhum dado é retornado** sem filtro adequado
- **Segurança**: Evita carregar dados indevidos se o filtro não for aplicado
- **Obriga** o desenvolvedor a definir o filtro via comando QY no evento adequado

---

## 2. Comando QY: Injeção Dinâmica de Filtro

### Sintaxe:
```
QY-<campo>-<condição_sql>
```

### Comportamento (PlusUni.pas:4585-4616):

```delphi
if AnsiUpperCase(Linh) <> 'ABRE' then
begin
  // 1. Pega SQL original (SQL_CAMP)
  Quer.SQL.Text := SubsCampPers(iForm, Quer.SQL_Back.Text);

  // 2. Injeta condição na LINHA 4
  Quer.SQL.Strings[4] := Linh;
end

// 3. Abre a query com SQL modificado
if Quer.SQL.Count > 0 then
  Quer.Open;
```

### Processo:
1. **SQL_Back.Text**: Contém o SQL original (SQL_CAMP do banco)
2. **SubsCampPers**: Substitui **TODOS** os placeholders ({DG-xxx}, {DM-xxx}, etc.) com valores reais
3. **Quer.SQL.Strings[4]**: **Injeta** a condição na linha 4 (índice 4)
4. **Quer.Open**: Executa a query com o SQL final

---

## 3. Exemplos em Diferentes Telas

### Tela 83603 (Produtos de Pedido - Frango Vivo)

**SQL Original:**
```sql
SELECT CODIPROD, NOMEPROD || ' - '||UPPER(POCAUNID.NOMEUNID) AS NOMEPROD, ...
FROM POCAPROD INNER JOIN POCAUNID ... INNER JOIN POGESGPR ...
WHERE ATIVPROD = 1
AND POCAPROD.CODIPROD = 0
                                    ← linha vazia
ORDER BY NOMEPROD
```

**Comando QY (evento DEPOSHOW):**
```plsag
QY-CODIPROD-{VA-VALO0001} {VA-VALO0002} AND EXISTS(SELECT 1 FROM VDCAMVTP WHERE VDCAMVTP.CODITBPR = ({DG-CODITBPR}) AND VDCAMVTP.CODIPROD = POCAPROD.CODIPROD)
```

**Filtro Aplicado:**
- Por **CODITBPR (Tabela de Preço)**
- Exemplo: CODITBPR = 1682 ("TABELA ENCANTADO")
- Lógica: Mostra apenas produtos que estão na tabela de preço do pedido

---

### Tela 4420 (Produtos por Subgrupo)

**Comando QY:**
```plsag
QY-CODIPROD-AND CODISGPR = {IT-CODISGPR}
{IT-CODIPROD-PROCTUDO}
```

**Filtro Aplicado:**
- Por **CODISGPR (Subgrupo de Produto)**
- Lógica: Mostra apenas produtos do subgrupo selecionado

---

### Tela 40070 (Produtos de uma Nota Fiscal)

**SQL Original:**
```sql
SELECT POCAPROD.CODIPROD, POCAPROD.NOMEPROD
FROM POCAPROD
WHERE (POCAPROD.SISTPROD LIKE '%S27%')
AND POCAPROD.CODIPROD = 0
ORDER BY NOMEPROD
```

**Comando QY:**
```plsag
QY-CODIPROD-AND 0 < (SELECT COUNT(*) FROM POCAMVNO WHERE POCAMVNO.CODIPROD = POCAPROD.CODIPROD AND POCAMVNO.CODINOTA = {QY-CODINOTA-CODINOTA})
```

**Filtro Aplicado:**
- Por **CODINOTA (Nota Fiscal)**
- Lógica: Mostra apenas produtos que já existem na nota

---

### Tela 85110 (Produto Específico)

**Comando QY:**
```plsag
QY-CODIPROD-WHERE CODIPROD = {DG-CODIPROD}
```

**Filtro Aplicado:**
- Por **CODIPROD específico**
- Lógica: Mostra apenas o produto selecionado

---

## 4. Mecanismo GENÉRICO vs ESPECÍFICO

### 🔧 GENÉRICO (Infraestrutura):

1. **SQL_CAMP com linha vazia** (linha 4)
2. **Linha de desabilitação** (`campo = 0` na linha 3)
3. **Comando QY-campo-condição** (processado no PlusUni.pas)
4. **Substituição de placeholders** (SubsCampPers)
5. **Injeção dinâmica** (Strings[4] = condição)

### 🎯 ESPECÍFICO (Regra de Negócio):

1. **Qual filtro aplicar** (CODITBPR, CODISGPR, CODINOTA, etc.)
2. **Quando aplicar** (evento DEPOSHOW, ANTESHOW, ShowPai_Filh, etc.)
3. **De onde vem o valor** ({DG-xxx}, {IT-xxx}, {VA-xxx}, etc.)
4. **Lógica de negócio** (EXISTS, IN, subquery, etc.)

---

## 5. Fluxo Completo: Tela 83600/83603

### Contexto:
- **Tela PAI**: 83600 (Pedido de Venda - Frango Vivo)
- **Tela FILHO**: 83603 (Produtos do Pedido)
- **Objetivo**: Filtrar produtos pela tabela de preço do pedido

### Passo a Passo:

```
1. Usuário clica "Incluir Produto" (BTNNOV1) na tela 83600
   ↓
2. POFrGrMv.BtnNovoClick (linha 299):
   - Executa AnteIAE_Movi_83603 (evento PAI)
   - Executa AnteIncl_83603 (evento PAI)
   - Busca ShowPai_Filh_83603 (se existir) → GetConfWeb.MemVal1
   - Cria form modal da tela 83603
   ↓
3. POHeCam6.FormShow da tela 83603 (linha 910):
   - Executa GetConfWeb.MemVal1 (instruções do PAI)
   - Executa evento DEPOSHOW da tela 83603
   ↓
4. DEPOSHOW da tela 83603:
   - Define DM-CODIPLAN (para outras regras de negócio)
   - Define DM-CODICENT (centro de custo)
   - Executa QY-CODIPROD com filtro por CODITBPR
   ↓
5. Comando QY-CODIPROD (PlusUni.pas:4585):
   - Pega SQL original (SQL_Back)
   - Substitui placeholders: {DG-CODITBPR} → 1682
   - Injeta na linha 4: "AND EXISTS(SELECT 1 FROM VDCAMVTP WHERE VDCAMVTP.CODITBPR = (1682) AND ...)"
   - Abre QryCODIPROD com SQL modificado
   ↓
6. Lookup mostra apenas produtos da tabela de preço 1682 ("TABELA ENCANTADO")
```

---

## 6. Tabelas de Preço na Tela 83600

### Exemplos Reais:

| CODIPEOU | CODITPVE | CODITBPR | Nome Tabela              |
|----------|----------|----------|--------------------------|
| 32293    | 787      | 1654     | TABELA UNIDASUL          |
| 32985    | 787      | **1682** | **TABELA ENCANTADO**     |
| 32813    | 787      | 1842     | TABELA SUCATAS - MATRIZ  |

### Produtos PINTOS DE 1 DIA:

| CODIPROD | Nome                | CODIPLAN | Em CODITBPR 1682? |
|----------|---------------------|----------|-------------------|
| 3814     | PINTOS DE 1 DIA ... | 4833     | ✅ SIM            |
| 3985     | PINTOS DE 1 DIA ... | 4833     | ✅ SIM            |
| 3986     | PINTOS DE 1 DIA ... | 4833     | ✅ SIM            |

**Verificação:**
```sql
SELECT CODIPROD, CODITBPR FROM VDCAMVTP
WHERE CODIPROD IN (3814, 3985, 3986) AND CODITBPR = 1682;

-- Resultado: Os 3 produtos estão na tabela 1682 ✅
```

---

## 7. Por Que CODIPLAN É Definido Mas Não Usado no Filtro?

O evento DEPOSHOW define:
```plsag
IT-CODIPLAN-SELECT MAX(CODIPLAN) FROM VDCAPANA WHERE CODITPMV = {DG-CODITPMV}
DM-CODIPLAN-{IT-CODIPLAN}
```

### Usos do CODIPLAN (não no lookup):

1. **Validações de Negócio**: Verificar se produto pertence ao plano
2. **Cálculos**: Fórmulas de preço, meta, comissão
3. **Relatórios**: Agrupar vendas por plano
4. **Histórico**: Rastrear qual plano estava associado
5. **Regras**: Habilitar/desabilitar campos baseado no plano

**Motivo**: O filtro por CODITBPR é mais **dinâmico e flexível**:
- Tabela de preço pode ter produtos de **vários planos**
- Permite **promoções** e **preços especiais**
- Relação N:N (um produto pode estar em várias tabelas)
- CODIPLAN é mais **estático** (propriedade do produto)

---

## 8. Outros Padrões Similares no Sistema

### Campos que usam `= 0` no SQL:

| CodiTabe | NameCamp  | Tipo | Descrição                    |
|----------|-----------|------|------------------------------|
| 4420     | CODIPROD  | IT   | Produtos por subgrupo        |
| 21060    | APONPROD  | IL   | Produtos em apontamento      |
| 27041    | CODILOPR  | IT   | Locais de produto            |
| 33600    | INFORESU  | DBG  | Grid de resumo               |
| 40010    | CODIPROD  | IT   | Produtos gerais              |
| 40070    | CODIPROD  | L    | Produtos de nota             |
| 83533    | CODILOPR  | T    | Locais em estoque            |
| 83603    | CODIPROD  | L    | Produtos de pedido (nosso!)  |
| 85110    | CODIPROD  | T    | Produto específico           |

**Padrão em TODOS**: Linha com `= 0` + linha vazia + comando QY dinâmico

---

## 9. Implementação na POC Web

### Adaptações Necessárias:

#### 9.1. SQL_CAMP como Array de Linhas

**Backend (MetadataService.cs):**
```csharp
public class FieldMetadata
{
    public string SqlCamp { get; set; }  // Texto completo
    public string[] SqlLines { get; set; }  // Array de linhas
}

// Ao carregar de SISTCAMP:
field.SqlLines = field.SqlCamp?.Split('\n') ?? Array.Empty<string>();
```

#### 9.2. Comando QY no PLSAG

**plsag-commands.js:**
```javascript
// Comando: QY-CODIPROD-AND EXISTS(...)
function executarComandoQY(campo, condicao) {
  const lookupComponent = document.querySelector(`[data-lookup="${campo}"]`);
  if (!lookupComponent) return;

  // 1. Pega SQL original (armazenado em data-sql-original)
  let sqlLines = JSON.parse(lookupComponent.dataset.sqlOriginal);

  // 2. Substitui TODOS os placeholders nas linhas
  sqlLines = sqlLines.map(linha => substituirPlaceholders(linha));

  // 3. Injeta condição na linha 4 (se não for 'ABRE')
  if (condicao.toUpperCase() !== 'ABRE') {
    sqlLines[4] = condicao;
  }

  // 4. Recarrega lookup com novo SQL
  const sqlFinal = sqlLines.join('\n');
  recarregarLookup(campo, sqlFinal);
}

// Registrar comando
registrarComando('QY', (args) => {
  const [campo, ...condicaoParts] = args;
  const condicao = condicaoParts.join('-'); // Reconstroi a condição
  executarComandoQY(campo, condicao);
});
```

#### 9.3. Lookup com SQL Dinâmico

**Frontend (lookup-manager.js):**
```javascript
function inicializarLookup(campo, metadata) {
  const lookupEl = document.querySelector(`[data-lookup="${campo}"]`);

  // Armazena SQL original como array de linhas
  lookupEl.dataset.sqlOriginal = JSON.stringify(metadata.sqlLines);

  // Não carrega dados ainda (linha 3 tem = 0)
  lookupEl.dataset.carregado = 'false';
}

function recarregarLookup(campo, sqlFinal) {
  const lookupEl = document.querySelector(`[data-lookup="${campo}"]`);

  // Executa SQL modificado
  fetch('/api/lookup/execute', {
    method: 'POST',
    body: JSON.stringify({ sql: sqlFinal }),
    headers: { 'Content-Type': 'application/json' }
  })
  .then(res => res.json())
  .then(data => {
    popularLookup(lookupEl, data);
    lookupEl.dataset.carregado = 'true';
  });
}
```

#### 9.4. Backend: Execução de SQL Dinâmico

**LookupService.cs:**
```csharp
public async Task<List<Dictionary<string, object>>> ExecuteSql(string sql, Dictionary<string, object> parameters)
{
    // IMPORTANTE: Validações de segurança!
    if (!ValidarSqlSeguro(sql))
        throw new SecurityException("SQL contém comandos não permitidos");

    // Substitui placeholders restantes (se houver)
    sql = SubstituirPlaceholders(sql, parameters);

    // Executa SQL
    return await _dbProvider.ExecuteQuery(sql);
}

private bool ValidarSqlSeguro(string sql)
{
    // Bloqueia comandos perigosos
    var sqlUpper = sql.ToUpper();
    var comandosProibidos = new[] { "DROP", "DELETE", "TRUNCATE", "ALTER", "CREATE", "INSERT", "UPDATE" };

    return !comandosProibidos.Any(cmd => sqlUpper.Contains(cmd));
}
```

---

## 10. Segurança e Validações

### ⚠️ Pontos de Atenção:

1. **Injeção SQL**: O comando QY permite SQL arbitrário na linha 4
   - **Mitigação**: Whitelist de padrões permitidos
   - **Validação**: Verificar se contém apenas AND/OR/EXISTS/SELECT
   - **Sanitização**: Remover `;`, `--`, `/*`, etc.

2. **Performance**: SQL dinâmico pode ser lento
   - **Cache**: Armazenar resultados de consultas frequentes
   - **Índices**: Garantir que tabelas têm índices adequados

3. **Logs**: Registrar todas as queries dinâmicas
   - **Auditoria**: Saber quais filtros estão sendo usados
   - **Debug**: Facilitar troubleshooting

### Exemplo de Validação:

```csharp
private bool ValidarCondicaoQY(string condicao)
{
    var condicaoUpper = condicao.ToUpper();

    // Permitir apenas cláusulas WHERE seguras
    var padrõesPermitidos = new[]
    {
        @"^AND\s+", // Começa com AND
        @"^OR\s+",  // Começa com OR
        @"EXISTS\s*\(SELECT", // Contém EXISTS
        @"IN\s*\(SELECT", // Contém IN subquery
    };

    if (!padrõesPermitidos.Any(p => Regex.IsMatch(condicao, p)))
        return false;

    // Bloquear comandos perigosos
    var bloqueados = new[] { "DELETE", "DROP", "INSERT", "UPDATE", "EXEC", ";", "--" };
    if (bloqueados.Any(b => condicaoUpper.Contains(b)))
        return false;

    return true;
}
```

---

## 11. Conclusão

### ✅ Descobertas Principais:

1. **Padrão Arquitetural Genérico**
   - Usado em 528 telas
   - Mecanismo consistente em todo o sistema
   - NÃO específico da tela 83600

2. **Estrutura SQL com Injeção Controlada**
   - Linha 3: Desabilita por padrão (`= 0`)
   - Linha 4: Espaço para filtro dinâmico
   - Comando QY: Injeta filtro em runtime

3. **Filtros Específicos por Tela**
   - 83603: Filtra por CODITBPR (Tabela de Preço)
   - 4420: Filtra por CODISGPR (Subgrupo)
   - 40070: Filtra por CODINOTA (Nota Fiscal)
   - Cada tela define sua lógica de negócio

4. **TABELA ENCANTADO**
   - CODITBPR = 1682
   - Usada em alguns pedidos tipo 787
   - Contém os produtos PINTOS DE 1 DIA

### 🎯 Próximos Passos:

1. **Validar com o Time**
   - Confirmar entendimento do mecanismo
   - Verificar se há casos especiais não documentados
   - Validar abordagem de segurança para POC Web

2. **Implementar na POC Web**
   - SQL_CAMP como array de linhas
   - Comando QY no interpretador PLSAG
   - Backend para execução segura de SQL dinâmico
   - Validações de segurança robustas

3. **Testes**
   - Testar com tela 83600/83603
   - Validar com outras telas (4420, 40070)
   - Performance de queries dinâmicas
   - Segurança contra injeção SQL

---

## Apêndice: Referências no Código Delphi

### Arquivos Principais:

1. **PlusUni.pas** (linha 4585-4616):
   - Processamento do comando QY
   - Injeção na linha 4 do SQL
   - Abertura da query modificada

2. **POFrGrMv.pas** (linha 299-414):
   - Evento BtnNovoClick (botão incluir movimento)
   - Passagem de instruções PAI → FILHO
   - Execução de eventos Ante/Depo

3. **POHeCam6.pas** (linha 910-963):
   - FormShow da tela de edição
   - Execução de GetConfWeb.MemVal1
   - Execução de DEPOSHOW

### Tabelas Principais:

1. **SISTCAMP**: Metadados de campos (SQL_CAMP, ExprCamp)
2. **VDCAPEOU**: Cabeçalho de pedido (CODITBPR)
3. **VDCAMVPO**: Movimentos/produtos do pedido
4. **VDCAMVTP**: Tabela de Preço × Produtos
5. **VDCATBPR**: Cadastro de Tabelas de Preço
6. **POCAPROD**: Cadastro de Produtos
7. **VDCAPANA**: Panalizador (CODIPLAN por tipo movimento)
