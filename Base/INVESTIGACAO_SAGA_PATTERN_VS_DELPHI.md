# Investigacao: Saga Pattern vs Fluxo Delphi

**Data:** 2026-01-05
**Status:** Aguardando feedback do time
**Erro:** ORA-20000: Pedidos: Inclusao Invalida! Periodo Fechado.

---

## Resumo do Problema

Ao clicar em "Incluir" no formulario 83600 (Pedidos), o SAG Web retorna erro de trigger Oracle, enquanto no Delphi o mesmo formulario funciona normalmente.

---

## Analise Tecnica

### Fluxo SAG Web (Atual - Saga Pattern)

```
1. Usuario clica "Incluir"
2. Frontend chama POST /Form/CreateRecord?tableId=83600
3. Backend executa INSERT INTO VDGEPEOU (...) VALUES (...)
4. Trigger TRG_VDGEPEOU_BIUD_VD_VALIDATA dispara
5. Trigger valida EMISPEOU via FUN_VALIDATA
6. ERRO: Periodo fechado (ou outro erro de validacao)
```

**Motivo do Saga Pattern:** Precisamos do `recordId` imediatamente para:
- Permitir adicionar movimentos filhos (FK para registro pai)
- Manter consistencia entre cabecalho e itens
- Evitar registros orfaos

### Fluxo Delphi (Tradicional)

```
1. Usuario clica "Incluir"
2. DataSet entra em modo dsInsert (MEMORIA APENAS)
3. Usuario preenche campos no formulario
4. Usuario adiciona movimentos (tambem em memoria?)
5. Usuario clica "Gravar"
6. SO ENTAO faz INSERT no banco
7. Trigger dispara com todos os campos preenchidos
8. Sucesso
```

**Questao em aberto:** Como o Delphi lida com movimentos filhos antes de ter o `recordId` do pai?

---

## Trigger Envolvida

### Oracle: TRG_VDGEPEOU_BIUD_VD_VALIDATA

```sql
TRIGGER "TRG_VDGEPEOU_BIUD_VD_VALIDATA"
BEFORE INSERT OR UPDATE OR DELETE
ON VDGEPEOU
FOR EACH ROW
BEGIN
  IF :NEW.SITUPEOU <> 'C' THEN  -- IGNORA SE SITUPEOU = 'C'
    IF (INSERTING) THEN
      IF (FUN_VALIDATA(:NEW.EMISPEOU, :NEW.EMISPEOU, 'VD-PEOUdos') = 0) THEN
        RAISE_APPLICATION_ERROR(-20000,'Pedidos: Inclusao Invalida! Periodo Fechado.');
      END IF;
    ELSIF (UPDATING) THEN
      IF (FUN_VALIDATA(:NEW.EMISPEOU, :OLD.EMISPEOU, 'VD-PEOUdos') = 0) THEN
        RAISE_APPLICATION_ERROR(-20000,'Pedidos: Alteracao Invalida! Periodo Fechado.');
      END IF;
    ELSIF (DELETING) THEN
      IF (FUN_VALIDATA(:OLD.EMISPEOU, :OLD.EMISPEOU, 'VD-PEOUdos') = 0) THEN
        RAISE_APPLICATION_ERROR(-20000,'Pedidos: Exclusao Invalida! Periodo Fechado.');
      END IF;
    END IF;
  END IF;
END;
```

### SQL Server: NAO TEM ESSA TRIGGER

```
Triggers existentes para VDGEPEOU no SQL Server:
- TRS_VDGEPEOU_AAD_LOG (log de auditoria)
- TRG_VDGEPEOU_INSE_ALTE (sem validacao de periodo)
```

**Conclusao:** A validacao de periodo so existe no Oracle.

---

## Funcao de Validacao

### FUN_VALIDATA

```sql
FUNCTION "FUN_VALIDATA" (
  iATUA DATE,   -- Data atual/nova
  iANTE DATE,   -- Data anterior
  iTIPO CHAR)   -- Modulo (ex: 'VD-PEOUdos')
RETURN INTEGER
AS
  vINIC DATE := NULL;
  vFINA DATE := NULL;
BEGIN
  SELECT MAX(INICFECH), MAX(FINAFECH)
    INTO vINIC, vFINA
    FROM POCAFECH
    WHERE (UPPER(LOCAFECH) = UPPER(iTIPO));

  RETURN (CASE
    WHEN (vINIC IS NULL) OR
         (vFINA IS NULL) OR
         (iATUA < vINIC) OR
         (iATUA > vFINA) OR
         (iANTE < vINIC) OR
         (iANTE > vFINA)
    THEN 0  -- Fora do periodo
    ELSE 1  -- Dentro do periodo
  END);
END;
```

---

## Descoberta Adicional: Bug de Configuracao

Durante a investigacao, encontramos um bug de configuracao:

| Item | Valor |
|------|-------|
| Trigger usa | `'VD-PEOUdos'` |
| POCAFECH tem | `'VD-Pedidos'` |
| UPPER() | `'VD-PEOUDOS'` != `'VD-PEDIDOS'` |

**Resultado:** Funcao nao encontra registro -> retorna NULL -> retorna 0 -> "Periodo Fechado"

**Correcao aplicada:** Adicionar registro `'VD-PEOUdos'` na POCAFECH (feito pelo usuario).

---

## Possiveis Solucoes para Saga Pattern

### Opcao 1: Voltar ao Modelo Tradicional

- **Como:** Nao inserir no banco ate "Gravar"
- **Pro:** Elimina conflito com triggers
- **Contra:** Como lidar com movimentos sem `parentId`?

### Opcao 2: Inserir com SITUPEOU='C'

- **Como:** Criar registro inicial com `SITUPEOU='C'` (Cancelado)
- **Pro:** Trigger ignora registros com SITUPEOU='C'
- **Contra:**
  - Pode ter efeitos colaterais em outras triggers/processos
  - Registro "cancelado" visivel em consultas?

### Opcao 3: IDs Temporarios em Memoria

- **Como:** Gerar IDs negativos ou UUIDs temporarios no frontend
- **Pro:** Nao toca no banco ate gravar
- **Contra:**
  - Complexidade de mapeamento temp->real
  - Movimentos precisam atualizar FK depois

### Opcao 4: Tabela de Staging

- **Como:** Inserir em tabela temporaria, mover para real no "Gravar"
- **Pro:** Isolamento completo
- **Contra:**
  - Duplicacao de estrutura
  - Complexidade de manutencao

### Opcao 5: Transacao Unica no Gravar

- **Como:** Cabecalho + Movimentos em uma unica transacao no "Gravar"
- **Pro:** Atomicidade, sem registros orfaos
- **Contra:**
  - Frontend precisa acumular tudo em memoria
  - Mudanca significativa na arquitetura

---

## Perguntas para o Time Delphi

1. **Como o Delphi gera o ID do registro pai antes de inserir no banco?**
   - Usa MAX+1 em memoria?
   - Gera sequencia antes do INSERT?
   - Outro mecanismo?

2. **Como os movimentos filhos sao vinculados ao pai antes do POST?**
   - Campo FK preenchido com valor temporario?
   - Movimentos ficam em DataSet separado em memoria?
   - INSERT do filho acontece junto com o pai?

3. **O Delphi faz INSERT em transacao unica (pai + filhos)?**
   - Ou insere pai, pega ID, insere filhos?

4. **Existe logica especial para tabelas com triggers de validacao?**
   - Algum campo "bypass" como SITUPEOU='C'?
   - Desabilita trigger temporariamente?

---

## Logs do Erro

```
info: Criando registro vazio para tabela 83600 (VDGEPEOU)
info: Tabela VDGEPEOU: estrategia PK = MaxPlusOneOrSequence
info: Aplicando default data: EMISPEOU = 01/05/2026 00:00:00
info: Aplicando default combo: SITUPEOU = ABER
info: Sequencia final: NUMEPEOU = 6007

fail: Erro ao criar registro vazio na tabela 83600
Oracle.ManagedDataAccess.Client.OracleException:
  ORA-20000: Pedidos: Inclusao Invalida! Periodo Fechado.
  ORA-06512: em "COMERCIAL.TRG_VDGEPEOU_BIUD_VD_VALIDATA", line 5
```

**Observacao:** O EMISPEOU foi preenchido corretamente com a data de hoje, mas:
1. Inicialmente, o registro 'VD-PEOUdos' nao existia na POCAFECH
2. Apos correcao, ainda pode haver outras validacoes falhando

---

## Proximos Passos

1. [ ] Obter feedback do time sobre fluxo Delphi
2. [ ] Decidir qual solucao implementar
3. [ ] Testar solucao escolhida com formularios que tem triggers
4. [ ] Documentar decisao arquitetural final

---

## Arquivos Relacionados

- `SagPoc.Web/Services/ConsultaService.cs` - CreateEmptyRecordAsync()
- `SagPoc.Web/Views/Form/Render.cshtml` - startNewRecord()
- `SagPoc.Web/wwwroot/js/consulta-grid.js` - incluir()
