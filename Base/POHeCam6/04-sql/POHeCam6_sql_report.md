# SQL e Stored Procedures - POHeCam6.pas

**Arquivo analisado:** `C:\Trabalho\Edata\GIT\MIMS_V7\SAG\POHeCam6.pas`

**Data:** 1764420635.9476693

## 🗂️ Stored Procedures Identificadas

*Nenhuma stored procedure identificada*

## 📝 Queries SQL Identificadas

**Total:** 1

### Query 1 (SELECT)

**Fonte:** SQL.Add calls

```sql
SELECT CompCamp, NameCamp, LabeCamp FROM POCaCamp WHERE (POCaCamp.CodiTabe = '+IntToStr(ConfTabe.CodiTabe)+ AND (CompCamp NOT IN (''BVL'',''LBL'',''BTN'',''DBG'',''GRA'',''T' AND (InteCamp = 0) ORDER BY GuiaCamp, OrdeCamp
```

**Análise:**
- **Tabelas envolvidas:** POCaCamp

## 🗄️ Tabelas Identificadas

**Total:** 1

- `POCaCamp`

## 📊 Resumo

- **Stored Procedures:** 0
- **Queries SQL:** 1
- **Tabelas:** 1

## ✅ Próximos Passos

1. Documentar parâmetros de cada stored procedure
2. Verificar se SPs existem em `Scripts\Procedures & Functions\`
3. Analisar queries dinâmicas (WHERE conditions adicionados em runtime)
4. Mapear relacionamentos entre tabelas
5. Identificar regras de negócio nas SPs
