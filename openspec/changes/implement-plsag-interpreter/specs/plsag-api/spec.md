# Capability: PLSAG API Backend

API REST em ASP.NET Core para execução de comandos PLSAG server-side.

## ADDED Requirements

### Requirement: Query Endpoint

O sistema MUST fornecer endpoint POST /api/plsag/query para execução de queries SQL.

Request:
```json
{
  "queryName": "PROD",
  "sql": "SELECT DESCRI, PRECO FROM PRODUTO WHERE CODI = 1001",
  "type": "single" | "multi"
}
```

Response:
```json
{
  "success": true,
  "data": { "DESCRI": "Produto A", "PRECO": 25.00 }
}
```

#### Scenario: Execute single-row query
- **GIVEN** request com type = "single"
- **WHEN** API processa query
- **THEN** executa SQL via Dapper QueryFirstOrDefault
- **AND** retorna objeto único ou null

#### Scenario: Execute multi-row query
- **GIVEN** request com type = "multi"
- **WHEN** API processa query
- **THEN** executa SQL via Dapper Query
- **AND** retorna array de objetos

#### Scenario: Return empty result for no rows
- **GIVEN** query que não retorna registros
- **WHEN** API processa
- **THEN** retorna { success: true, data: null } para single
- **OR** retorna { success: true, data: [] } para multi

#### Scenario: Validate SQL before execution
- **GIVEN** SQL com comando bloqueado (DROP, TRUNCATE)
- **WHEN** API recebe request
- **THEN** retorna status 400
- **AND** mensagem "SQL inválido: comando bloqueado"

#### Scenario: Log query execution
- **GIVEN** qualquer query executada
- **WHEN** API processa
- **THEN** loga "PLSAG Query: {queryName} por {user} em {timestamp}"

---

### Requirement: Save Endpoint

O sistema MUST fornecer endpoint POST /api/plsag/save para gravação de dados.

Request:
```json
{
  "tableName": "PRODUTO",
  "operation": "INSERT" | "UPDATE" | "DELETE",
  "data": { "CODI": 1001, "DESCRI": "Produto A" },
  "where": "CODI = 1001"
}
```

Response:
```json
{
  "success": true,
  "rowsAffected": 1,
  "lastInsertId": 1001
}
```

#### Scenario: Execute INSERT operation
- **GIVEN** operation = "INSERT"
- **WHEN** API processa
- **THEN** monta SQL INSERT com colunas e valores
- **AND** executa via Dapper Execute
- **AND** retorna lastInsertId se aplicável

#### Scenario: Execute UPDATE operation
- **GIVEN** operation = "UPDATE" com where clause
- **WHEN** API processa
- **THEN** monta SQL UPDATE com SET e WHERE
- **AND** executa e retorna rowsAffected

#### Scenario: Execute DELETE operation
- **GIVEN** operation = "DELETE" com where clause
- **WHEN** API processa
- **THEN** monta SQL DELETE com WHERE
- **AND** executa e retorna rowsAffected

#### Scenario: Reject DELETE without WHERE
- **GIVEN** operation = "DELETE" sem where clause
- **WHEN** API recebe request
- **THEN** retorna status 400
- **AND** mensagem "DELETE requer cláusula WHERE"

#### Scenario: Use parameterized queries
- **GIVEN** data com valores a inserir
- **WHEN** API monta SQL
- **THEN** usa parâmetros (@param) em vez de concatenação
- **AND** previne SQL injection

---

### Requirement: Execute Endpoint

O sistema MUST fornecer endpoint POST /api/plsag/execute para comandos EX.

Request:
```json
{
  "command": "SQL" | "PROC" | "VALIDATE" | "EXPORT",
  "sql": "UPDATE ...",
  "procedure": "SP_NOME",
  "parameters": { "param1": "value1" }
}
```

#### Scenario: Execute raw SQL command
- **GIVEN** command = "SQL" com sql válido
- **WHEN** API processa
- **THEN** valida SQL
- **AND** executa via Dapper
- **AND** retorna rowsAffected

#### Scenario: Execute stored procedure
- **GIVEN** command = "PROC" com procedure name
- **WHEN** API processa
- **THEN** executa procedure com parâmetros
- **AND** retorna resultado

#### Scenario: Validate CPF
- **GIVEN** command = "VALIDATE", parameters.type = "CPF", parameters.value = "12345678901"
- **WHEN** API processa
- **THEN** valida CPF usando algoritmo
- **AND** retorna { valid: true/false }

#### Scenario: Validate CNPJ
- **GIVEN** command = "VALIDATE", parameters.type = "CNPJ"
- **WHEN** API processa
- **THEN** valida CNPJ usando algoritmo
- **AND** retorna { valid: true/false }

#### Scenario: Export to PDF
- **GIVEN** command = "EXPORT", parameters.format = "PDF"
- **WHEN** API processa
- **THEN** gera PDF do formulário/relatório
- **AND** retorna URL do arquivo ou base64

---

### Requirement: SQL Validation

O sistema MUST validar SQL para prevenir comandos perigosos.

Comandos bloqueados:
- DROP, TRUNCATE, ALTER, CREATE
- GRANT, REVOKE
- xp_, sp_ (procedures de sistema)
- Comentários: --, /* */

#### Scenario: Block DROP command
- **GIVEN** SQL contendo "DROP TABLE"
- **WHEN** validador processa
- **THEN** retorna inválido
- **AND** mensagem específica sobre comando bloqueado

#### Scenario: Block SQL injection attempts
- **GIVEN** SQL com "; DROP TABLE" ou "1=1 --"
- **WHEN** validador processa
- **THEN** retorna inválido

#### Scenario: Allow SELECT with JOINs
- **GIVEN** SELECT complexo com JOINs e subqueries
- **WHEN** validador processa
- **THEN** retorna válido

#### Scenario: Allow UPDATE in specific context
- **GIVEN** comando QM (Query Modify)
- **WHEN** SQL contém UPDATE
- **THEN** permite UPDATE (contexto autorizado)

#### Scenario: Block system procedures
- **GIVEN** SQL com "xp_cmdshell" ou "sp_configure"
- **WHEN** validador processa
- **THEN** retorna inválido

---

### Requirement: Transaction Support

O sistema MUST suportar transações explícitas.

#### Scenario: Begin transaction
- **GIVEN** request para iniciar transação
- **WHEN** API processa
- **THEN** cria transação no SQL Server
- **AND** retorna transactionId
- **AND** armazena conexão aberta na sessão

#### Scenario: Commit transaction
- **GIVEN** transactionId válido
- **WHEN** API recebe commit request
- **THEN** commita transação
- **AND** fecha conexão

#### Scenario: Rollback transaction
- **GIVEN** transactionId válido
- **WHEN** API recebe rollback request
- **THEN** rollback transação
- **AND** fecha conexão

#### Scenario: Auto-rollback on error
- **GIVEN** transação ativa
- **WHEN** operação falha
- **THEN** rollback automático
- **AND** retorna erro

#### Scenario: Transaction timeout
- **GIVEN** transação ativa por mais de 5 minutos
- **WHEN** timeout ocorre
- **THEN** rollback automático
- **AND** fecha conexão

---

### Requirement: Error Handling

O sistema MUST retornar erros de forma consistente.

Response de erro:
```json
{
  "success": false,
  "error": "Mensagem de erro",
  "code": "SQL_ERROR" | "VALIDATION_ERROR" | "AUTH_ERROR",
  "details": { ... }
}
```

#### Scenario: SQL error response
- **GIVEN** SQL que causa erro no banco
- **WHEN** API captura exceção
- **THEN** retorna status 500
- **AND** code = "SQL_ERROR"
- **AND** message sem detalhes internos (segurança)

#### Scenario: Validation error response
- **GIVEN** request com dados inválidos
- **WHEN** API valida
- **THEN** retorna status 400
- **AND** code = "VALIDATION_ERROR"
- **AND** details com campos inválidos

#### Scenario: Log all errors
- **GIVEN** qualquer erro
- **WHEN** API processa
- **THEN** loga erro completo com stack trace
- **AND** inclui user, timestamp, request details

---

### Requirement: Security

O sistema MUST implementar medidas de segurança.

#### Scenario: Require authentication
- **GIVEN** request sem autenticação
- **WHEN** API recebe
- **THEN** retorna status 401

#### Scenario: Validate user permissions
- **GIVEN** usuário sem permissão para tabela
- **WHEN** tenta executar query
- **THEN** retorna status 403

#### Scenario: Rate limiting
- **GIVEN** mais de 100 requests/minuto do mesmo IP
- **WHEN** próximo request chega
- **THEN** retorna status 429

#### Scenario: Audit trail
- **GIVEN** operação de escrita (INSERT, UPDATE, DELETE)
- **WHEN** API executa
- **THEN** registra em tabela de auditoria
- **AND** inclui user, timestamp, operação, dados antes/depois

---

### Requirement: API Configuration

O sistema MUST permitir configuração via appsettings.

```json
{
  "Plsag": {
    "QueryTimeout": 30,
    "MaxResultRows": 1000,
    "AllowedTables": ["*"],
    "BlockedCommands": ["DROP", "TRUNCATE"],
    "EnableAudit": true
  }
}
```

#### Scenario: Apply query timeout
- **GIVEN** QueryTimeout = 30 segundos
- **WHEN** query demora mais que 30s
- **THEN** cancela execução
- **AND** retorna erro de timeout

#### Scenario: Limit result rows
- **GIVEN** MaxResultRows = 1000
- **WHEN** query retorna mais de 1000 linhas
- **THEN** retorna apenas primeiras 1000
- **AND** inclui warning "Resultado truncado"

#### Scenario: Restrict tables
- **GIVEN** AllowedTables = ["PRODUTO", "CLIENTE"]
- **WHEN** query acessa tabela "USUARIO"
- **THEN** retorna erro 403 "Tabela não permitida"
