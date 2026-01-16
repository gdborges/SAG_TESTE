# POHeCam6 - Technical AS-IS Documentation

## Fragmento 04_TECHNICAL (Configuracao, Seguranca e Erros)

**Versao:** 1.0
**Data:** 2025-12-23
**Analista:** Claude Code (Automatizado)

---

## Navegacao entre Fragmentos

| Fragmento | Arquivo | Conteudo |
|-----------|---------|----------|
| [00_MASTER](POHeCam6_Technical_AS-IS_00_MASTER.md) | 00_MASTER | Identificacao + Resumo + Anexos |
| [01_STRUCTURE](POHeCam6_Technical_AS-IS_01_STRUCTURE.md) | 01_STRUCTURE | Componentes + DataSources |
| [02_LOGIC](POHeCam6_Technical_AS-IS_02_LOGIC.md) | 02_LOGIC | Events + SPs + Dependencias |
| [03_BUSINESS](POHeCam6_Technical_AS-IS_03_BUSINESS.md) | 03_BUSINESS | Regras + Fluxo + Integracoes |
| **04_TECHNICAL** | Este documento | Config + Seguranca + Erros |

---

## SECAO 10: CONFIGURACOES

### 10.1 Constantes do Formulario

| Constante | Valor | Descricao |
|-----------|-------|-----------|
| cEspaTabe | 10 | Espacamento entre abas |
| cTamaTabe | 72 | Tamanho base da aba |
| cAltuTabe | 10 | Altura base |
| cAltuMovi | 240 | Altura do painel de movimento |

### 10.2 Variaveis de Instancia

| Variavel | Tipo | Escopo | Descricao |
|----------|------|--------|-----------|
| Criado | Boolean | Private | Flag de criacao concluida |
| PrimGui1 | TControl | Private | Primeiro controle guia 1 |
| PrimGui2 | TControl | Private | Primeiro controle guia 2 |
| PrimMov1 | TControl | Private | Primeiro controle movimento 1 |
| DtbCada | TsgConn | Private | Conexao de banco (Desktop) |
| FPgcMovi | TsgPgc | Private | PageControl de movimentos |
| fListMovi | TObjectList<TMovi> | Private | Lista de movimentos |
| fListLeitSeri | TObjectList<TsgLeitSeri> | Private | Lista de leitores seriais |

### 10.3 Propriedades

| Propriedade | Tipo | Leitura | Escrita | Descricao |
|-------------|------|---------|---------|-----------|
| PgcMovi | TsgPgc | GetPgcMovi | FPgcMovi | PageControl lazy-load |
| ListMovi | TObjectList<TMovi> | fListMovi | fListMovi | Lista de movimentos |
| ListLeitSeri | TObjectList<TsgLeitSeri> | fListLeitSeri | fListLeitSeri | Lista seriais |

### 10.4 Configuracao de Dimensoes

**Dimensionamento Automatico:**
```pascal
if (AltuTabe = 9999) and (TamaTabe = 9999) then
  // Tela maximizada
  Height := GetConfWeb.PAltReso;
  Width := GetConfWeb.PTamReso;
else
  // Dimensoes configuradas
  Height := AltuTabe + SeInte(PnlDado.Visible, cAltuMovi, 0) + vMaioTamaResu + 10;
  Width := TamaTabe + 5 - 50;
```

**Altura do Painel de Dados:**
- TpGrTabe > 0: Usa TpGrTabe
- Senao: AltuTabe - 55

---

## SECAO 11: DIRETIVAS DE COMPILACAO

### 11.1 Diretivas Principais

```pascal
{$DEFINE ERPUNI_FRAME}  // Define modo frame

{$ifdef ERPUNI}
  // Componentes uniGUI para Web
{$ELSE}
  // Componentes VCL para Desktop
{$ENDIF}

{$IFDEF ERPUNI_MODAL}
  // Formulario modal para Web
{$ELSE}
  // Formulario normal
{$ENDIF}
```

### 11.2 Impacto por Bloco Condicional

| Bloco | Impacto |
|-------|---------|
| {$ifdef ERPUNI} | Alterna entre uniGUI e VCL |
| {$IFDEF ERPUNI_MODAL} | Alterna heranca entre Modal e Normal |
| Uses condicionais | Carrega units especificas por plataforma |

### 11.3 Classes Base por Modo

| Modo | Classe Pai |
|------|------------|
| Desktop Normal | TFrmPOHeGera |
| Desktop Modal | TFrmPOHeGeraModal |
| Web Normal | TFrmPOHeGera (uniGUI) |
| Web Modal | TFrmPOHeGeraModal (uniGUI) |

---

## SECAO 12: SEGURANCA

### 12.1 Controle de Acesso

**Validacao de Acesso a Campos:**
- CampPersExecNoOnShow verifica acesso a campos
- Campos podem ser habilitados/desabilitados por perfil

**Validacao de Modificacao:**
- BtnConf_CampModi verifica se dados foram gerados externamente
- Impede alteracao de campos bloqueados

### 12.2 Tratamento de Transacoes

**Conexao de Banco (Desktop):**
```pascal
if not Assigned(sgTransaction) then
begin
  DtbCada := TsgConn.Create(Self);
  DtbCada.LoginPrompt := False;
  DtbCada.CodiTabe := GetPTab;
  ConfConnectionString(DtbCada);
  sgTransaction := TsgTransaction(DtbCada);
end
```

**Limpeza de Transacao:**
```pascal
// FormClose
if DtbCada.CodiTabe = ConfTabe.CodiTabe then
begin
  if DtbCada = GetPsgTrans then
    SetPsgTrans(nil);
  sgTransaction := nil;
end;
```

### 12.3 Validacao de Inclusao Nao Confirmada

**Delecao de Registro Orfao:**
```pascal
if PSitGrav and sgTem_Movi and
   ((ConfTabe.Operacao = opIncl) and not (ConfTabe.ClicConf)) then
  ExecSQL_('DELETE FROM '+ConfTabe.GravTabe+
           ' WHERE '+ConfTabe.NomeCodi+' = '+IntToStr(ConfTabe.CodiGrav),
           sgTransaction);
```

---

## SECAO 13: TRATAMENTO DE ERROS

### 13.1 Erros de Componente Obsoleto

**Componentes QryMov/DtsMov:**
```pascal
if StrIn(iNome, ['QRYMOV'+IntToStr(i), ...]) then
  Raise Exception.Create('Componente QryMov'+IntToStr(i)+
    ' nao e mais usados neste modelo de Formulario!');

if StrIn(iNome, ['DTSMOV'+IntToStr(i), ...]) then
  Raise Exception.Create('Componente DtsMov'+IntToStr(i)+
    ' nao e mais usados neste modelo de Formulario!');
```

### 13.2 Erros de Criacao

**Tratamento em AfterCreate:**
```pascal
try
  MontCampPers(...);
except
  on E: Exception do
    vMensagem := E.Message;
end;
msgRaiseTratada(vMensagem, vMensagem);
```

**Tratamento em FormCreate:**
```pascal
try
  // ... criacao de movimentos
  inherited;
except
  Width := 500;
  Height := 400;
  raise;
end;
```

### 13.3 Mensagens ao Usuario

| Tipo | Funcao | Uso |
|------|--------|-----|
| Erro | sgMessageDlg | Dados nao podem ser modificados |
| Aviso | msgAviso | Telas em deprecacao |
| OK | msgOk | Confirmacao de sequencial |
| Hint | ExibMensHint | Status de processamento |

---

## SECAO 14: PERFORMANCE

### 14.1 Lazy Loading

**PgcMovi (GetPgcMovi):**
```pascal
function TFrmPOHeCam6.GetPgcMovi: TsgPgc;
begin
  if not Assigned(FPgcMovi) then
  begin
    FPgcMovi := TsgPgc.Create(Self);
    FPgcMovi.Parent := PnlDado;
    FPgcMovi.Name := 'PgcDado';
    FPgcMovi.Align := alClient;
    FPgcMovi.Style := PgcGene.Style;
  end;
  Result := FPgcMovi;
end;
```

### 14.2 Otimizacoes Web

**SuspendLayouts/ResumeLayouts:**
```pascal
{$ifdef ERPUNI}
  SuspendLayouts;
  try
    // ... operacoes de layout
  finally
    ResumeLayouts;
  end;
{$endif}
```

### 14.3 Recursao Controlada

**BuscaComponente (recursao propria):**
- Busca recursiva em hierarquia de componentes
- Limite natural pela hierarquia de componentes

**MudaTabe2_BuscTbs_Index (recursao propria):**
- Busca recursiva de tab por hierarquia de parent
- Limite natural pela profundidade de controles

---

## SECAO 15: COMPATIBILIDADE

### 15.1 Suporte Dual Mode (Web/Desktop)

| Funcionalidade | Desktop (VCL) | Web (uniGUI) |
|----------------|---------------|--------------|
| Conexao | DtbCada (TsgConn) | Via framework |
| Porta Serial | TsgLeitSeri | Nao suportado |
| Layout | Imediato | SuspendLayouts |
| Focus | TWinControl.SetFocus | TUniControl.SetFocus |
| Teclado | WM_NextDlgCtl | Via framework |

### 15.2 Funcao IsWeb

```pascal
function TFrmPOHeCam6.IsWeb: Boolean;
begin
  {$ifdef ERPUNI}
    Result := True;
  {$ELSE}
    Result := False;
  {$ENDIF}
end;
```

### 15.3 Tratamento Mobile

**QryTabeConfBeforeOpen:**
```pascal
if GetConfWeb.Modo = cwModoMobile then
  QryTabeConf.SQL.Text := isMobi_POCaCamp_Sele(QryTabeConf.SQL.Text);
```

---

## SECAO 16: MANUTENCAO E EXTENSIBILIDADE

### 16.1 Pontos de Extensao

| Metodo Virtual | Descricao |
|----------------|-----------|
| FormCreate | Override para inicializacao customizada |
| FormShow | Override para comportamento de exibicao |
| FormClose | Override para limpeza customizada |
| FormDestroy | Override para liberacao de recursos |
| BtnConfClick | Override para logica de confirmacao |
| AfterCreate | Override para configuracao pos-criacao |
| AtuaGrid | Override para atualizacao de grids |
| BuscaComponente | Override para busca customizada |

### 16.2 Metodos Herdados Utilizados

| Metodo | Classe Pai | Uso |
|--------|------------|-----|
| AnteShow | TFrmPOHeGera | Preparacao antes de exibir |
| DepoShow | TFrmPOHeGera | Finalizacao apos exibir |
| PreparaManu | TFrmPOHeGera | Prepara dados para manutencao |
| UltiConf | TFrmPOHeGera | Ultimo controle antes de confirma |
| HabiConf | TFrmPOHeGera | Habilita/desabilita confirma |
| GravSemC | TFrmPOHeGera | Grava sem commit |
| BtnConf_Ante | TFrmPOHeGera | Antes do confirma |
| BtnConf_Depo | TFrmPOHeGera | Depois do confirma |

### 16.3 Registro de Classe

```pascal
initialization
  RegisterClass(TFrmPOHeCam6);
end.
```

**Proposito:** Permite criacao dinamica do formulario por nome de classe.

---

## SECAO 16B: CHECKLIST DE QUALIDADE

### Cobertura da Documentacao

| Item | Status | Observacao |
|------|--------|------------|
| Identificacao completa | OK | Secao 1 |
| Componentes documentados | OK | Secao 2 |
| DataSources mapeados | OK | Secao 3 |
| Event handlers detalhados | OK | Secao 4 |
| SPs documentadas | OK | Nenhuma SP direta |
| Dependencias listadas | OK | Secao 6 |
| Regras de negocio | OK | Secao 7 |
| Fluxos documentados | OK | Secao 8 |
| Integracoes mapeadas | OK | Secao 9 |
| Configuracoes | OK | Secao 10 |
| Diretivas condicionais | OK | Secao 11 |
| Seguranca | OK | Secao 12 |
| Tratamento de erros | OK | Secao 13 |
| Performance | OK | Secao 14 |
| Compatibilidade | OK | Secao 15 |

---

**Fragmento Anterior:** [03_BUSINESS - Regras + Fluxo + Integracoes](POHeCam6_Technical_AS-IS_03_BUSINESS.md)

**Documento Master:** [00_MASTER - Identificacao + Resumo + Anexos](POHeCam6_Technical_AS-IS_00_MASTER.md)

