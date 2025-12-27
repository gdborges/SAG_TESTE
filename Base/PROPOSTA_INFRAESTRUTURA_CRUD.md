# Proposta: Infraestrutura CRUD - SAG POC Web

> **Versão:** 1.0
> **Data:** 2025-12-27
> **Status:** APROVADA
> **Autor:** Claude Code + Equipe SAG

---

## 1. Objetivo

Este documento especifica as regras e estratégias para operações CRUD (Create, Read, Update, Delete) no SAG POC Web, cobrindo aspectos que não foram contemplados nas propostas de Eventos e PLSAG.

### 1.1 Escopo

- Cálculo dinâmico de Primary Key (PK)
- Estratégias de geração de ID
- Compatibilidade com triggers SQL Server
- Conversão de tipos entre Frontend, Backend e Banco
- Validação e sanitização de metadados
- Tratamento de concorrência

### 1.2 Documentos Relacionados

| Documento | Relação |
|-----------|---------|
| PROPOSTA_SISTEMA_EVENTOS_WEB.md | Eventos que disparam CRUD |
| PROPOSTA_INTERPRETADOR_PLSAG_WEB.md | Comandos PLSAG que executam CRUD |
| AI_SPECIFICATION.md | Sintaxe de templates para SQL |

---

## 2. Arquitetura de Dados SAG

### 2.1 Tabelas de Metadados

```
SISTTABE (Tabelas)
├── CODITABE    int        - ID único da tabela (ex: 715, 400, 120)
├── NOMETABE    varchar    - Nome exibido ao usuário
├── GRAVTABE    varchar    - Nome físico da tabela (ex: "POCALESI", "FPCAEVEN")
├── SIGLTABE    varchar    - Sufixo para PK (ex: "LESI", "EVEN")
└── ...

SISTCAMP (Campos)
├── CODITABE    int        - FK para SISTTABE
├── NOMECAMP    varchar    - Nome físico do campo
├── LABECAMP    varchar    - Label exibido
├── TIPOCAMP    varchar    - Tipo do campo
└── ...
```

### 2.2 Convenção de Primary Key SAG

```
PK = "CODI" + SIGLTABE

Exemplos:
┌──────────┬──────────┬────────────┐
│ CODITABE │ SIGLTABE │ PK Column  │
├──────────┼──────────┼────────────┤
│ 715      │ LESI     │ CODILESI   │
│ 400      │ EVEN     │ CODIEVEN   │
│ 120      │ UNIT     │ CODIUNIT   │
│ 150      │ FUNC     │ CODIFUNC   │
└──────────┴──────────┴────────────┘
```

**IMPORTANTE:** SIGLTABE pode conter espaços em branco. Sempre usar:
```csharp
if (!string.IsNullOrWhiteSpace(siglTabe))
    pkColumn = $"CODI{siglTabe.Trim()}";
```

---

## 3. Estratégias de Primary Key

### 3.1 Tipos de PK no SAG

| Tipo | Detecção | Estratégia |
|------|----------|------------|
| **IDENTITY** | `is_identity = 1` | Deixar banco gerar, usar `SCOPE_IDENTITY()` |
| **Manual SAG** | `is_identity = 0` + padrão CODI* | Gerar com `MAX()+1` |
| **Composta** | Múltiplas colunas na PK | Não gerar, exigir do usuário |

### 3.2 Detecção de Tipo

```sql
-- Verificar se coluna é IDENTITY
SELECT
    c.name AS ColumnName,
    c.is_identity
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
WHERE t.name = @TableName
  AND c.name = @ColumnName
```

### 3.3 Geração de ID para Tabelas Não-IDENTITY

```sql
-- Estratégia MAX()+1 com proteção contra concorrência
BEGIN TRANSACTION;

DECLARE @newId INT;
SELECT @newId = ISNULL(MAX(CODILESI), 0) + 1 FROM POCALESI WITH (TABLOCKX);

INSERT INTO POCALESI (CODILESI, ...) VALUES (@newId, ...);

COMMIT TRANSACTION;

SELECT @newId AS NewId;
```

**Nota:** `TABLOCKX` previne race conditions mas reduz concorrência. Para alta carga, considerar:
- Tabela de sequência separada
- SEQUENCE do SQL Server (se versão suportar)

### 3.4 Algoritmo de Decisão

```
┌─────────────────────────────────────────────────────────────┐
│                    INSERINDO REGISTRO                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │  PK é IDENTITY?         │
              └─────────────────────────┘
                     │           │
                   Sim          Não
                     │           │
                     ▼           ▼
        ┌────────────────┐  ┌────────────────┐
        │ Não incluir PK │  │ Gerar MAX()+1  │
        │ no INSERT      │  │ em transação   │
        └────────────────┘  └────────────────┘
                     │           │
                     ▼           ▼
              ┌─────────────────────────┐
              │  Tabela tem TRIGGER?    │
              └─────────────────────────┘
                     │           │
                   Sim          Não
                     │           │
                     ▼           ▼
        ┌────────────────┐  ┌────────────────────┐
        │ SCOPE_IDENTITY │  │ OUTPUT INSERTED.PK │
        │ após INSERT    │  │ (mais eficiente)   │
        └────────────────┘  └────────────────────┘
                     │           │
                     └─────┬─────┘
                           ▼
                  ┌─────────────────┐
                  │ Retornar novo ID│
                  └─────────────────┘
```

---

## 4. Compatibilidade com Triggers

### 4.1 Problema

SQL Server não permite `OUTPUT INSERTED.*` quando a tabela tem triggers `INSTEAD OF INSERT`. Exemplo:

```sql
-- Trigger existente em FPCAEVEN (tabela 400)
CREATE TRIGGER TRI_FPCAEVEN_I ON FPCAEVEN
INSTEAD OF INSERT AS
BEGIN
    INSERT INTO FPCAEVEN (...)
    SELECT ... FROM INSERTED
END
```

### 4.2 Solução

Usar `SCOPE_IDENTITY()` após o INSERT:

```sql
-- Método compatível com triggers
INSERT INTO FPCAEVEN (DESCEVEN, ...) VALUES (@desc, ...);
SELECT SCOPE_IDENTITY() AS NewId;

-- OU para tabelas não-IDENTITY
INSERT INTO FPCAEVEN (CODIEVEN, DESCEVEN, ...) VALUES (@id, @desc, ...);
SELECT @id AS NewId;
```

### 4.3 Tabelas com Triggers Conhecidas

| Tabela | CodiTabe | Trigger | Observação |
|--------|----------|---------|------------|
| FPCAEVEN | 400 | TRI_FPCAEVEN_I | **PROBLEMA:** Descarta CODIEVEN passado |

**AÇÃO NECESSÁRIA:** Modificar trigger TRI_FPCAEVEN_I para preservar CODIEVEN quando fornecido.

---

## 5. Conversão de Tipos

### 5.1 Fluxo de Dados

```
Frontend (JSON)  →  Backend (C#)  →  Banco (SQL Server)
─────────────────────────────────────────────────────────
JsonElement.Number    int/decimal      INT/DECIMAL
JsonElement.String    string           VARCHAR/NVARCHAR
JsonElement.Boolean   bool             BIT
JsonElement.Null      null             NULL
```

### 5.2 Casos Especiais

| Input Frontend | Interpretação | Valor SQL |
|----------------|---------------|-----------|
| `"true"` | Boolean string | `1` (BIT) |
| `"false"` | Boolean string | `0` (BIT) |
| `"on"` | Checkbox HTML | `1` (BIT) |
| `""` | String vazia | `NULL` |
| `"123"` | String numérica | `123` (INT) ou `'123'` (VARCHAR) |

### 5.3 Implementação C#

```csharp
public static object? ConvertJsonElementToValue(JsonElement element, string sqlType)
{
    // 1. Null handling
    if (element.ValueKind == JsonValueKind.Null ||
        element.ValueKind == JsonValueKind.Undefined)
        return null;

    // 2. String vazia = NULL
    if (element.ValueKind == JsonValueKind.String)
    {
        var str = element.GetString();
        if (string.IsNullOrWhiteSpace(str))
            return null;

        // Boolean strings
        if (str.Equals("true", StringComparison.OrdinalIgnoreCase) ||
            str.Equals("on", StringComparison.OrdinalIgnoreCase))
            return 1;
        if (str.Equals("false", StringComparison.OrdinalIgnoreCase))
            return 0;

        return str;
    }

    // 3. Números - preservar tipo
    if (element.ValueKind == JsonValueKind.Number)
    {
        if (sqlType.Contains("INT", StringComparison.OrdinalIgnoreCase))
            return element.GetInt32();
        if (sqlType.Contains("DECIMAL", StringComparison.OrdinalIgnoreCase) ||
            sqlType.Contains("NUMERIC", StringComparison.OrdinalIgnoreCase))
            return element.GetDecimal();
        return element.GetDouble();
    }

    // 4. Boolean
    if (element.ValueKind == JsonValueKind.True) return 1;
    if (element.ValueKind == JsonValueKind.False) return 0;

    return element.ToString();
}
```

---

## 6. Validação de Metadados

### 6.1 Problemas Encontrados

| Campo | Problema | Impacto |
|-------|----------|---------|
| SIGLTABE | Espaços em branco ("    ") | PK calculada incorretamente |
| GRAVTABE | NULL ou vazio | Tabela não encontrada |
| NOMECAMP | Case diferente do banco | Coluna não encontrada |

### 6.2 Regras de Sanitização

```csharp
// Ao ler SISTTABE
public class TableMetadata
{
    public string GravTabe
    {
        get => _gravTabe?.Trim() ?? string.Empty;
        set => _gravTabe = value;
    }

    public string SiglTabe
    {
        get => string.IsNullOrWhiteSpace(_siglTabe) ? null : _siglTabe.Trim();
        set => _siglTabe = value;
    }
}

// Ao comparar nomes de coluna
string.Equals(columnA, columnB, StringComparison.OrdinalIgnoreCase)
```

### 6.3 Fallbacks

| Situação | Fallback |
|----------|----------|
| SIGLTABE null/vazio | Extrair sufixo de GRAVTABE |
| GRAVTABE null/vazio | Erro - não pode continuar |
| PK não encontrada | Usar primeira coluna INT |

---

## 7. Operações CRUD

### 7.1 CREATE (INSERT)

```csharp
public async Task<int> InsertAsync(string tableName, Dictionary<string, object> data)
{
    // 1. Verificar se tabela tem IDENTITY
    var isIdentity = await IsIdentityColumnAsync(tableName, pkColumn);

    // 2. Gerar ID se não for IDENTITY
    int? newId = null;
    if (!isIdentity && data.ContainsKey(pkColumn) == false)
    {
        newId = await GetNextIdAsync(tableName, pkColumn);
        data[pkColumn] = newId;
    }

    // 3. Montar INSERT
    var columns = string.Join(", ", data.Keys);
    var parameters = string.Join(", ", data.Keys.Select(k => $"@{k}"));
    var sql = $"INSERT INTO {tableName} ({columns}) VALUES ({parameters})";

    // 4. Executar
    using var transaction = await connection.BeginTransactionAsync();
    try
    {
        await connection.ExecuteAsync(sql, data, transaction);

        // 5. Obter ID gerado
        if (isIdentity)
        {
            newId = await connection.ExecuteScalarAsync<int>(
                "SELECT SCOPE_IDENTITY()", transaction: transaction);
        }

        await transaction.CommitAsync();
        return newId ?? (int)data[pkColumn];
    }
    catch
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

### 7.2 READ (SELECT)

```csharp
public async Task<Dictionary<string, object>> GetByIdAsync(
    string tableName, string pkColumn, int id)
{
    var sql = $"SELECT * FROM {tableName} WHERE {pkColumn} = @id";
    return await connection.QueryFirstOrDefaultAsync<dynamic>(sql, new { id });
}
```

### 7.3 UPDATE

```csharp
public async Task<bool> UpdateAsync(
    string tableName, string pkColumn, int id, Dictionary<string, object> data)
{
    // 1. Remover PK dos dados (não atualizar PK)
    data.Remove(pkColumn);

    // 2. Montar UPDATE
    var sets = string.Join(", ", data.Keys.Select(k => $"{k} = @{k}"));
    var sql = $"UPDATE {tableName} SET {sets} WHERE {pkColumn} = @pkValue";
    data["pkValue"] = id;

    // 3. Executar e verificar
    var affected = await connection.ExecuteAsync(sql, data);
    if (affected == 0)
    {
        throw new InvalidOperationException(
            $"Registro {id} não encontrado na tabela {tableName}");
    }

    return true;
}
```

### 7.4 DELETE

```csharp
public async Task<bool> DeleteAsync(string tableName, string pkColumn, int id)
{
    var sql = $"DELETE FROM {tableName} WHERE {pkColumn} = @id";
    var affected = await connection.ExecuteAsync(sql, new { id });

    if (affected == 0)
    {
        throw new InvalidOperationException(
            $"Registro {id} não encontrado na tabela {tableName}");
    }

    return true;
}
```

---

## 8. Tratamento de Erros

### 8.1 Códigos de Erro SQL Server

| Erro | Significado | Ação |
|------|-------------|------|
| 2627 | Violação de PK/UNIQUE | Retry com novo ID ou informar usuário |
| 547 | Violação de FK | Informar registro relacionado |
| 515 | NULL em coluna NOT NULL | Validar antes de enviar |
| 8152 | String truncada | Validar tamanho antes de enviar |

### 8.2 Mensagens para Usuário

```csharp
public string GetUserFriendlyMessage(SqlException ex)
{
    return ex.Number switch
    {
        2627 => "Este registro já existe. Verifique os dados e tente novamente.",
        547 => "Não é possível excluir: existem registros relacionados.",
        515 => "Preencha todos os campos obrigatórios.",
        8152 => "Um ou mais campos excederam o tamanho máximo permitido.",
        _ => $"Erro ao salvar: {ex.Message}"
    };
}
```

---

## 9. Integração com PLSAG

### 9.1 Comandos que Executam CRUD

| Comando PLSAG | Operação CRUD | Backend API |
|---------------|---------------|-------------|
| `ES-XXXXX` | INSERT/UPDATE | `/Plsag/ExecuteSql` |
| `IN-XXXXX` | INSERT | `/Plsag/ExecuteSql` |
| `AD-XXXXX` | UPDATE | `/Plsag/ExecuteSql` |
| `EX-XXXXX` | DELETE | `/Plsag/ExecuteSql` |

### 9.2 Templates em SQL

Quando templates PLSAG são usados em contexto SQL, aplicar escape:

```javascript
// plsag-interpreter.js
function substituteForSQL(text, context) {
    let result = substituteTemplates(text, context);

    // Escape de aspas simples para SQL
    result = result.replace(/'/g, "''");

    return result;
}
```

### 9.3 Templates Não Encontrados

Quando um template `{VA-XXXXX}` ou `{DG-XXXXX}` não é encontrado:

```javascript
// Retornar string vazia + warning
if (!value) {
    console.warn(`Template não encontrado: ${template}`);
    return '';  // Não quebrar execução
}
```

---

## 10. Checklist de Implementação

### 10.1 ConsultaService.cs

- [ ] Usar `SCOPE_IDENTITY()` em vez de `OUTPUT INSERTED`
- [ ] Envolver INSERT em transação
- [ ] Validar `affected rows` após UPDATE
- [ ] Tratar `TABLOCKX` para concorrência
- [ ] Remover logs de debug

### 10.2 MetadataService.cs

- [ ] Aplicar `Trim()` em SIGLTABE
- [ ] Usar `IsNullOrWhiteSpace()` em validações
- [ ] Cachear metadados frequentes

### 10.3 FormMetadata.cs

- [ ] PkColumnName deve usar SIGLTABE.Trim()
- [ ] Fallback para GRAVTABE quando SIGLTABE vazio

### 10.4 PLSAG Interpreter

- [ ] `substituteForSQL()` com escape de quotes
- [ ] Template não encontrado retorna vazio
- [ ] Comandos QD/QM implementados

---

## 11. Testes Recomendados

### 11.1 Cenários CRUD

```
□ INSERT em tabela IDENTITY
□ INSERT em tabela não-IDENTITY (MAX()+1)
□ INSERT em tabela com trigger INSTEAD OF
□ UPDATE com registro existente
□ UPDATE com registro inexistente (deve falhar)
□ DELETE com registro existente
□ DELETE com FK violation (deve informar)
```

### 11.2 Cenários de Metadados

```
□ SIGLTABE = "LESI" (normal)
□ SIGLTABE = "    " (espaços)
□ SIGLTABE = NULL
□ GRAVTABE = "" (deve falhar)
□ Coluna com case diferente do banco
```

### 11.3 Cenários de Concorrência

```
□ 2 INSERTs simultâneos (mesmo segundo)
□ UPDATE concorrente no mesmo registro
□ DELETE de registro sendo editado
```

---

## 12. Glossário

| Termo | Definição |
|-------|-----------|
| **SISTTABE** | Tabela de metadados que define as tabelas do sistema |
| **SISTCAMP** | Tabela de metadados que define os campos |
| **SIGLTABE** | Sufixo usado para formar o nome da PK (ex: "LESI" → CODILESI) |
| **GRAVTABE** | Nome físico da tabela no banco de dados |
| **IDENTITY** | Coluna com auto-incremento gerenciado pelo SQL Server |
| **SCOPE_IDENTITY()** | Função que retorna o último IDENTITY gerado na sessão atual |
| **INSTEAD OF TRIGGER** | Trigger que substitui a operação original |

---

## 13. Histórico de Revisões

| Versão | Data | Autor | Alterações |
|--------|------|-------|------------|
| 1.0 | 2025-12-27 | Claude Code | Versão inicial |
