# SQL e Stored Procedures - PlusUni.pas

**Arquivo analisado:** `C:\Trabalho\Edata\GIT\MIMS_V7\SAG\PlusUni.pas`

**Data:** 1764420631.3722756

## 🗂️ Stored Procedures Identificadas

**Total:** 2

| # | Nome | Método de Chamada | Contexto |
|---|------|-------------------|----------|
| 1 | `Chav` | EXEC in SQL | `EXEC
    Chav` |
| 2 | `Linh` | EXEC in SQL | `EXEC
                      Linh` |

### Detalhes das Stored Procedures

#### 1. Chav

- **Método de chamada:** EXEC in SQL
- **Contexto:** `EXEC
    Chav`
- **Ação necessária:** Documentar parâmetros e lógica
- **Arquivo SP:** `Scripts\Procedures & Functions\Chav.sql`

#### 2. Linh

- **Método de chamada:** EXEC in SQL
- **Contexto:** `EXEC
                      Linh`
- **Ação necessária:** Documentar parâmetros e lógica
- **Arquivo SP:** `Scripts\Procedures & Functions\Linh.sql`

## 📝 Queries SQL Identificadas

**Total:** 1

### Query 1 (SELECT)

**Fonte:** SQL.Add calls

```sql
SELECT CompCamp, NameCamp, InclAcCa, AlteAcCa, ConsAcCa FROM POViAcCa INNER JOIN POCaCamp ON (POViAcCa.NameAcCa = POCaCamp.NameCamp) and (POViAcCa.CodiTabe = POCaCamp.CodiTabe) WHERE ((POCaCamp.CodiTabe = '+IntToStr(iForm.HelpContext)+ ) AND (('+TipoOper+' = 0) OR (ConsAcCa = 0)) AND (CompCamp <> ''BVL' SELECT POCaMvEs.CodiEsto, QtNoMvEs AS Qtde'+
                         ', Round(Nulo(ValoMvEs)-Nulo(DctoMvEs)+Nulo(VIPIMvEs)+Nulo(VaITMvEs)+Nulo(FretMvEs)+Nulo(SeguMvEs)+Nulo(OutrMvEs)'+SeStri(iDctoVaDe,' - NULO(VaDeMvEs)',' FROM POCAMvEs WHERE (POCaMvEs.CodiMvEs = '+IntToStr(CodiMvEs)+ SELECT POCaMvNo.CodiNota'+
                         ', POCaMvNo.QtdeMvNo AS Qtde'+
                         ', Round(Nulo(ValoMvNo)-Nulo(DctoMvNo)+Nulo(VaIpMvNo)+Nulo(VaITMvNo)+Nulo(FretMvNo)+Nulo(SeguMvNo)+Nulo(OutrMvNo)'+
                                SeStri(GetEmpresa='MAR','', '+Nulo(VaDeMvNo) FROM POCAMvNo WHERE POCaMvNo.CodiMvNo = '+IntToStr(CodiMvNo));
    QryMvNo.Open;

    TipoTpMv := CalcInte('SELECT TipoTpMv FROM POCaTpMv WHERE (CodiTpMv = '+IntToStr(SeInte(QryMvNo.FieldByName('CodiTpMv WITH TABE AS ( SELECT    POVIMVCX.CODIFINA , '+FormNumeSQL(Valo)+' AS VALOFINA , POVIMVCX.CODIPLAN , POVIMVCX.CODICENT , POVIMVCX.CODIRAMO , POVIMVCX.CODIPRCC , POVIMVCX.DATAMVCX , POVIMVCX.VLDEMVCX AS VLDE , POVIMVCX.VLCRMVCX AS VLCR , SUM(POVIMVCX.VLDEMVCX) OVER (PARTITION BY NULL) AS TTDEMVCX , SUM(POVIMVCX.VLCRMVCX) OVER (PARTITION BY NULL) AS TTCRMVCX FROM POVIMVCX WHERE POVIMVCX.CODIFINA IN ('+RetoZero(vList)+ ) SELECT NomePlan AS "Conta" , NomeCent AS "Centro de Custo" , DataMvCx AS "Data" , NomeRamo AS "Ramo de Atividade" , NomePrCC AS "Projeto" , ROUND(DBO.DIVEZERO(VLDE, TTDEMVCX) * VALOFINA,02) AS "Débito" , ROUND(DBO.DIVEZERO(VLCR, TTCRMVCX) * VALOFINA,02) AS "Crédito" FROM TABE INNER JOIN MPGEPLAN MPCAPLAN ON TABE.CODIPLAN = MPCAPLAN.CODIPLAN           INNER JOIN POGECENT POCACENT ON TABE.CODICENT = POCACENT.CODICENT           LEFT  JOIN POCARAMO ON TABE.CODIRAMO = POCARAMO.CODIRAMO           LEFT  JOIN POCAPRCC ON TABE.CODIPRCC = POCAPRCC.CODIPRCC ORDER BY CODIFINA, NumeCent WITH TABE AS ( SELECT    POVIMVCX.CODIFINA , '+FormNumeSQL(iQuer.FieldByName('Valo , POVIMVCX.CODIPLAN , POVIMVCX.CODICENT , POVIMVCX.CODIRAMO , POVIMVCX.CODIPRCC , POVIMVCX.DATAMVCX , POVIMVCX.VLDEMVCX AS VLDE , POVIMVCX.VLCRMVCX AS VLCR , SUM(POVIMVCX.VLDEMVCX) OVER (PARTITION BY NULL) AS TTDEMVCX , SUM(POVIMVCX.VLCRMVCX) OVER (PARTITION BY NULL) AS TTCRMVCX FROM POVIMVCX WHERE POVIMVCX.CODIFINA IN ('+RetoZero(vList)+ ) SELECT NomePlan AS "Conta" , NomeCent AS "Centro de Custo" , DataMvCx AS "Data" , NomeRamo AS "Ramo de Atividade" , NomePrCC AS "Projeto" , ROUND(DBO.DIVEZERO(VLDE, TTDEMVCX) * VALOFINA,02) AS "Débito" , ROUND(DBO.DIVEZERO(VLCR, TTCRMVCX) * VALOFINA,02) AS "Crédito" FROM TABE INNER JOIN MPGEPLAN MPCAPLAN ON TABE.CODIPLAN = MPCAPLAN.CODIPLAN           INNER JOIN POGECENT POCACENT ON TABE.CODICENT = POCACENT.CODICENT           LEFT  JOIN POCARAMO ON TABE.CODIRAMO = POCARAMO.CODIRAMO           LEFT  JOIN POCAPRCC ON TABE.CODIPRCC = POCAPRCC.CODIPRCC ORDER BY CODIFINA, NumeCent WITH TABE AS ( SELECT POCAMVFI.CODIFINA, CALCUNFI FROM POVIUNFI_BAIX CAIX INNER JOIN POCAMVFI ON CAIX.CODIMVFI = POCAMVFI.CODIMVFI WHERE CAIX.CODIFINA = '+IntToStr(iQuer.FieldByName('CodiFina SELECT    POVIMVCX.CODIFINA , '+FormNumeSQL(QryUnFi.FieldByName('CALCUNFI , POVIMVCX.CODIPLAN , POVIMVCX.CODICENT , POVIMVCX.CODIRAMO , POVIMVCX.CODIPRCC , POVIMVCX.DATAMVCX , POVIMVCX.VLDEMVCX AS VLDE , POVIMVCX.VLCRMVCX AS VLCR , SUM(POVIMVCX.VLDEMVCX) OVER (PARTITION BY NULL) AS TTDEMVCX , SUM(POVIMVCX.VLCRMVCX) OVER (PARTITION BY NULL) AS TTCRMVCX , ''Baixado'' AS Tipo , ''VERDE_FRACO'' AS Linh_ , ''LARANJA_FRACO'' AS Linh_ FROM POVIMVCX WHERE POVIMVCX.CODIFINA = '+RetoZero(vListBaix));
              if QryUnFi.RecordCount <> QryUnFi.RecNo then
                QrySQL.SQL.Add('UNION ALL UNION ALL SELECT    POVIMVCX.CODIFINA , '+FormNumeSQL(Debi+Cred)+' AS VALOFINA , POVIMVCX.CODIPLAN , POVIMVCX.CODICENT , POVIMVCX.CODIRAMO , POVIMVCX.CODIPRCC , POVIMVCX.DATAMVCX , POVIMVCX.VLDEMVCX AS VLDE , POVIMVCX.VLCRMVCX AS VLCR , SUM(POVIMVCX.VLDEMVCX) OVER (PARTITION BY NULL) AS TTDEMVCX , SUM(POVIMVCX.VLCRMVCX) OVER (PARTITION BY NULL) AS TTCRMVCX , ''Parcelado'' AS Tipo , ''0'' AS Linh_ FROM POVIMVCX WHERE POVIMVCX.CODIFINA IN ('+RetoZero(vList)+ ) SELECT NomePlan AS "Conta" , NomeCent AS "Centro de Custo" , DataMvCx AS "Data" , NomeRamo AS "Ramo de Atividade" , NomePrCC AS "Projeto" , ROUND(DBO.DIVEZERO(VLDE, TTDEMVCX) * VALOFINA,02) AS "Débito" , ROUND(DBO.DIVEZERO(VLCR, TTCRMVCX) * VALOFINA,02) AS "Crédito" , Tipo AS "Tipo" , Linh_ FROM TABE INNER JOIN MPGEPLAN MPCAPLAN ON TABE.CODIPLAN = MPCAPLAN.CODIPLAN           INNER JOIN POGECENT POCACENT ON TABE.CODICENT = POCACENT.CODICENT           LEFT  JOIN POCARAMO ON TABE.CODIRAMO = POCARAMO.CODIRAMO           LEFT  JOIN POCAPRCC ON TABE.CODIPRCC = POCAPRCC.CODIPRCC ORDER BY TIPO, Linh_, CODIFINA, NumeCent SELECT * FROM ' + Tabe);
  QryCabe.SQL.Add(' ');
  if Codi = 0 then
    QryCabe.SQL.Add('WHERE ('+Camp+' = '+IntToStr(CalcCodi(Camp,Tabe))+ WHERE ('+Camp+' = '+IntToStr(Codi)+ ');
  QryCabe.SQL.Add(' SELECT * FROM ' + Tabe);
  QryCabe.SQL.Add(' ');
  if Codi = 0 then
    QryCabe.SQL.Add('WHERE ('+Camp+' = '+IntToStr(CalcCodi(Camp,Tabe))+ WHERE ('+Camp+' = '+IntToStr(Codi)+ ');
  QryCabe.SQL.Add(' SELECT InclAces, AlteAces, ConsAces, ExclAces, SeleAces, RelaAces FROM TABLE(FUN_ACES_TABE(0,'+IntToStr(Tabe)+ WHERE (CodiTabe = '+IntToStr(Tabe)+ SELECT NomePess FROM '+Tabe+' INNER JOIN POCaPess ON '+Tabe+'.CodiUsua = POCaPess.CodiPess WHERE (CodiUsua <> 0) AND (CodiUsua <> '+IntToStr(GetPUsu())+ SELECT '+Camp);
    SQL.Add('FROM MPCaAloj INNER JOIN MPGeBox MPCaBox ON MPCaAloj.CodiBox = MPCaBox.CodiBox '+
                          'INNER JOIN MPGeAvia MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia '+
                          'INNER JOIN MPGeNucl MPCaNucl ON MPCaNucl.CodiNucl = MPCaAvia.CodiNucl '+
                          'INNER JOIN MPGeGran MPCaGran ON MPCaGran.CodiGran = MPCaNucl.CodiGran '+
                          'INNER JOIN MPGeLote MPCaLote ON MPCaAloj.CodiLote = MPCaLote.CodiLote '+
                          'LEFT JOIN POGePess Inte ON Inte.CodiPess = MPCaLote.CodiPess '+
                          'LEFT JOIN POGePess Resp ON Resp.CodiPess = MPCaAvia.CodRPess '+
                          'LEFT JOIN MPViLote Orig ON Orig.CodiLote = MPCaAloj.CodMLote WHERE '+vCodiLote+' AND (MPCaBox.AtivBox <> 0) AND (MPCAAloj.DataAloj = (SELECT MAX(DataAloj) FROM MPCaAloj Aloj WHERE (Aloj.CodiLote = MPCaAloj.CodiLote))) GROUP BY '+Camp);
    SQL.Add('ORDER BY '+Camp);
    Open;
    While not(Eof) do
    begin
      if Result = '' then
        Result := Fields[0].AsString
      else
        Result := Result+' | '+Fields[0].AsString;
      Next;
    end;
    Close;
  end;
end;

//----> Pegar os Aviários de Recria onde o Lote está Alojado
function PegaAvRe(Lote:String):String;
begin
  Result := '';
  with DtmPoul.QryCalcPlus do
  begin
    SQL.Clear;
    SQL.Add('SELECT MPCaAvia.CodiAvia, MPCaAvia.NomeAvia FROM MPCaAloj INNER JOIN MPCaBox ON MPCaAloj.CodiBox = MPCaBox.CodiBox INNER JOIN MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia WHERE (MPCaAloj.CodiLote IN ('+Lote+ GROUP BY MPCaAvia.CodiAvia, MPCaAvia.NomeAvia ORDER BY MPCaAvia.NomeAvia SELECT POCaPess.CodiPess, NomePess FROM MPCaAloj INNER JOIN MPCaBox ON MPCaAloj.CodiBox = MPCaBox.CodiBox INNER JOIN MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia INNER JOIN POCaPess ON MPCaAvia.CodiPess = POCaPess.CodiPess'+' INNER JOIN MPCaLote ON ((MPCaAloj.CodiLote = MPCaLote.CodiLote) AND (MPCaAloj.DataAloj = MPCaLote.UltiLote)) WHERE (MPCaAloj.CodiLote IN ('+Lote+ GROUP BY POCaPess.CodiPess, NomePess ORDER BY NomePess SELECT MPCaGran.CodiGran, NomeGran FROM MPCaTrFu INNER JOIN MPCaBox ON MPCaTrFu.CodiBox = MPCaBox.CodiBox INNER JOIN MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia INNER JOIN MPCaNucl ON MPCaAvia.CodiNucl = MPCaNucl.CodiNucl '+'INNER JOIN MPCaGran ON MPCaNucl.CodiGran = MPCaGran.CodiGran WHERE (MPCaTrFu.CodiPess = '+RetoZero(Func)+ GROUP BY MPCaGran.CodiGran, NomeGran ORDER BY MPCaGran.CodiGran, NomeGran SELECT MPCaGran.CodiGran, NomeGran FROM MPCaTrFu INNER JOIN MPCaBox ON MPCaTrFu.CodiBox = MPCaBox.CodiBox INNER JOIN MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia INNER JOIN MPCaNucl ON MPCaAvia.CodiNucl = MPCaNucl.CodiNucl '+'INNER JOIN MPCaGran ON MPCaNucl.CodiGran = MPCaGran.CodiGran WHERE (MPCaTrFu.CodiPess = '+Func+ GROUP BY MPCaGran.CodiGran, NomeGran ORDER BY MPCaGran.CodiGran, NomeGran SELECT INCaIncu.CodiIncu, NomeIncu FROM INCaTrIn INNER JOIN INCaIncu ON INCaTrIn.CodiIncu = INCaIncu.CodiIncu  WHERE (INCaTrIn.CodiPess = '+Func+ GROUP BY INCaIncu.CodiIncu, NomeIncu ORDER BY INCaIncu.CodiIncu, NomeIncu SELECT INCaIncu.CodiIncu, NomeIncu FROM INCaTrIn INNER JOIN INCaIncu ON INCaTrIn.CodiIncu = INCaIncu.CodiIncu  WHERE (INCaTrIn.CodiPess = '+Func+ GROUP BY INCaIncu.CodiIncu, NomeIncu ORDER BY INCaIncu.CodiIncu, NomeIncu SELECT IdadCole AS Idad, DataCole, ChavCole, ProdLote FROM MPCaCole INNER JOIN MPCaLote ON MPCaCole.CodiLote = MPCaLote.CodiLote WHERE (MPCaCole.CodiLote = '+Lote+
                     AND (MPCaCole.CodiAloj = '+IntToStr(iCodiAloj)+ GROUP BY IdadCole, DataCole, ChavCole, ProdLote ORDER BY IdadCole, ChavCole SELECT IdadIdad AS Idad FROM POCaIdad WHERE (IdadIdad BETWEEN '+FormPont(IdadInic)+' AND '+FormPont(IdadFina)+ ORDER BY IdadIdad SELECT SQL_SiSt, MPCaMvIs.CodiMvIs, RecrSist, ProdSiSt, NomeItSt, NomeSiSt, IncuSiSt, DiarSiSt, EnceSiSt, ZeroSiSt, MiniSiSt, MaxiSiSt, TipoSiSt FROM MPCaSiSt INNER JOIN MPCaMvIS ON MPCaSiSt.CodiSiSt = MPCaMvIS.CodiSiSt INNER JOIN MPCaItSt ON MPCaMvIs.CodiItSt = MPCaItSt.CodiItSt WHERE (EstiSiSt = ''C'  AND (MPCaMvIs.CodiMvIs = '+IntToStr(SubI)+ ');
    QrySiSt.SQL.Add('ORDER BY OrdeItSt, OrdeMvIs SELECT CodiCole FROM MPCaCole WHERE (CodiLote = '+Lote+ ');
    if iCodiAloj <> 0 then
      QryCole.SQL.Add('AND (MPCaCole.CodiAloj = '+IntToStr(iCodiAloj)+ SELECT CodiGraf FROM MPCaGraf WHERE ('+FormUppeSQL+'('+FormLeftSQL+'(NomeGraf,'+IntToStr(Length(NomeDest))+ SELECT * FROM MPCAGRAF WHERE ('+FormUppeSQL+'('+FormLeftSQL+'(NOMEGRAF,'+IntToStr(Length(NomeOrig))+ SELECT * FROM MPCAGRAF WHERE (CODIGRAF = 0) SELECT * FROM MPCAMVGR WHERE (CODIMVGR = 0) SELECT * FROM MPCAMVGR WHERE CodiGraf = '+RetoZero(QryCalcPlus.FieldByName('CodiGraf SELECT MPCaLote.CodiLote, MPCaLote.EnceLote, MPCaPlan.CuCoPlan, SUM(CalcMvCu) AS Valo FROM MPCaMvCu INNER JOIN MPCaPlan ON MPCaMvCu.CodiPlan = MPCaPlan.CodiPlan INNER JOIN MPCaMvIs ON MPCaPlan.CuCoPlan = MPCaMvIs.CodiMvIs INNER JOIN MPCaSiSt ON MPCaMvIs.CodiSiSt = MPCaSiSt.CodiSiSt '+'INNER JOIN MPCaLote ON MPCaLote.CodiLote = MPCaMvCu.CodiLote WHERE (AtivPlan <> 0) AND (CuCoPlan > 0) AND (EnceSiSt <> 0) AND (AtivLote = 0) AND (MPCaLote.CodiLote = '+CodiLote+ GROUP BY MPCaLote.CodiLote, MPCaLote.EnceLote, MPCaPlan.CuCoPlan SELECT * FROM MPCACOLE ');
    while not(QryCust.Eof) do
    begin
      QryCole.SQL.Strings[1] := 'WHERE (CODILOTE = '+RetoZero(QryCust.FieldByName('CodiLote SELECT CodSMvIs, PeAcSiSt, PeAbSiSt, CoAcSiSt, CoAbSiSt FROM MPGESIST MPCaSiSt INNER JOIN MPCaMvIs ON MPCaSiSt.CodiSiSt = MPCaMvIs.CodiSiSt WHERE (MPCaMvIs.CodiMvIs = '+IntToStr(Item)+ SELECT * FROM '+Tabe);
    QryOrig.SQL.Add(Wher);
    QryOrig.Open;
    //Abro para a Duplicação
    QryDest.SQL.Clear;
    QryDest.SQL.Add('SELECT * FROM '+Tabe);
    QryDest.SQL.Add('WHERE (1 = 2) SELECT Codi'+Copy(Tabe,05,04)+', '+Camp);
      QryOrde.SQL.Add('FROM '+Tabe);
      QryOrde.SQL.Add('WHERE '+Wher);
      QryOrde.SQL.Add('ORDER BY '+Orde);
      QryOrde.Open;
      i := 10;
      while not(QryOrde.Eof) do
      begin
        AlteDadoTabe(Tabe,
                    [Camp, IntToStr(i)
                    ],'WHERE (Codi'+Copy(Tabe,05,04)+' = '+IntToStr(QryOrde.Fields[0].AsInteger)+ SELECT '+Camp+' FROM '+Tabe+' ORDER BY '+Camp);
      QryCria.Open;
      i := 1;
      while not(QryCria.Eof) do
      begin
        QryCria.Edit;
        QryCria.Fields[0].AsString := SubsPala(SubsPala(Nome,'%NUME%',ZeroEsqu(IntToStr(i),03)),'%NOME%',QryCria.Fields[0].AsString);
        TratErroBanc(QryCria);
        Inc(i);
        QryCria.Next;
      end;
    finally
      QryCria.Free;
    end;
  end;
end;

//Passado o Número da  Conta, retorna o seu respectivo grau
Function RetoGrauPlan(NumePlan: String):Integer;
begin
  if (Copy(NumePlan,10,02) <> '00 SELECT NumePlan FROM MPCaPlan WHERE (COPY(NumePlan,01,'+IntToStr(Grau*3)+ ORDER BY NumePlan DESC SELECT '+Camp);
        QryIdad.SQL.Add('FROM '+Tabe);
    //    QryIdad.SQL.Add('GROUP BY '+Camp);
        QryIdad.Open;
        FrmPOGeAgCa.GauAgua.MaxValue := QryIdad.RecordCount;
        while not(QryIdad.Eof) do
        begin
    //      AtuaTabe('UPDATE '+Tabe+' SET '+Camp+' = '+FormPont(FloatToStr(AredReal(QryIdad.Fields[0].AsFloat,NumeCasa)))+' WHERE ('+Camp+' = '+FormPont(QryIdad.Fields[0].AsString)+ SELECT * FROM MPCAGRAF WHERE (CODIGRAF = 0) SELECT NomeProd, NomeUnid, MiniDePr as MiniProd, MaxidePr as MaxiProd FROM POGeProd INNER JOIN POCaUnid ON POGeProd.CodiUnid = POCaUnid.CodiUnid               LEFT  JOIN POCADEPR ON POGeProd.CodiProd = POCADEPR.CodiProd WHERE (POGeProd.CodiProd = '+IntToStr(Prod)+ SELECT * FROM '+ TabeCole);
    if PesqChav then
      QryCole.SQL.Add('WHERE (CODILOTE = '+ IntToStr(CodiLote)+ WHERE (CODICOLE = '+IntToStr(CodiCole)+ SELECT CLCaProd.CodiProd, NomeProd FROM CLCaProd WHERE (AtivProd <> 0) GROUP BY CLCaProd.CodiProd, NomeProd ORDER BY CLCaProd.CodiProd SELECT CLCaProd.CodiProd, NomeProd AS "Módulo", FinaMvPr AS "Final", TipoMvPr AS "Tipo", '+
                    'LibeMvPr AS "Liberado", POCaPess.Nu01Pess FROM CLCaProd INNER JOIN CLCaMvPr          ON CLCaProd.CodiProd = CLCaMvPr.CodiProd SELECT CLCaProd.CodiProd, NomeProd FROM CLCaProd WHERE (AtivProd <> 0) GROUP BY CLCaProd.CodiProd, NomeProd ORDER BY CLCaProd.CodiProd SELECT * FROM FSXXImNF  WHERE (ProtImNF = '+QuotedStr(Prot)+ SELECT * FROM FSXXMvIN  WHERE (ProtMvIN = '+QuotedStr(Prot)+ SELECT POCAPROD.CODIPROD, POCATPMV.CODITPMV, POCASETO.CODISETO, FSXXIMPR.CODITPMV AS VALITPMV, FSXXIMPR.CODISETO AS VALISETO  FROM FSXXIMPR  INNER JOIN POCAPROD ON FSXXIMPR.CODIPROD = POCAPROD.CODIPROD  LEFT  JOIN POCATPMV ON FSXXIMPR.CODITPMV = POCATPMV.CODITPMV  LEFT  JOIN POCASETO ON FSXXIMPR.CODISETO = POCASETO.CODISETO  WHERE FSXXIMPR.PRODIMPR = 0  ORDER BY PDATIMPR DESC SELECT CODIUNID, FATOUNME FROM POGEUNME  WHERE CODINUNME = 0
```

**Análise:**
- **Tabelas envolvidas:** CLCaMvPr, CLCaProd, FSXXIMNF, FSXXIMPR, FSXXImNF, FSXXMVIN, FSXXMvIN, INCaIncu, INCaTrIn, MPCACOLE, MPCAGRAF, MPCAMVGR, MPCaAloj, MPCaAvia, MPCaBox, MPCaCole, MPCaGraf, MPCaGran, MPCaItSt, MPCaLote, MPCaMvCu, MPCaMvGr, MPCaMvIS, MPCaMvIs, MPCaNucl, MPCaPlan, MPCaSiSt, MPCaTrFu, MPGEPLAN, MPGESIST, MPGeAvia, MPGeBox, MPGeGran, MPGeLote, MPGeNucl, MPViLote, POCADEPR, POCAMVES, POCAMVFI, POCAMVNO, POCAMvEs, POCAMvNo, POCAPRCC, POCAPROD, POCARAMO, POCASETO, POCATPMV, POCATpMv, POCAUNID, POCaCamp, POCaCent, POCaIdad, POCaMvEs, POCaMvFi, POCaMvNo, POCaPess, POCaTpMv, POCaUnid, POGECENT, POGEPESS, POGEPROD, POGEUNME, POGePess, POGeProd, POVIMVCX, POVIUNFI_BAIX, POViAcCa, TABE, TABLE, ou, pocamves, pogeprod
- **Parâmetros:** Integer, String
- **Joins:** 53

## 🗄️ Tabelas Identificadas

**Total:** 139

- `ABCAAPON`
- `ABGEAPON`
- `ABGEFEPR`
- `CALLCENTER`
- `CLCaMvPr`
- `CLCaProd`
- `CTCAMASC`
- `DUAL`
- `ERPSAG_DESENV`
- `ESCAESTO`
- `ESCaEsto`
- `EsCaEsto`
- `FCViLote`
- `FPGeCola`
- `FSCANFEE`
- `FSXXIMNF`
- `FSXXIMPR`
- `FSXXImDo`
- `FSXXImNF`
- `FSXXMVIN`
- `FSXXMvIN`
- `INCaIncu`
- `INCaTrAm`
- `INCaTrIn`
- `INGeAmbi`
- `MASTER`
- `MPCACOLE`
- `MPCAGRAF`
- `MPCAMVGR`
- `MPCaAloj`
- `MPCaAvia`
- `MPCaBox`
- `MPCaCole`
- `MPCaGraf`
- `MPCaGran`
- `MPCaItSt`
- `MPCaLote`
- `MPCaMvCu`
- `MPCaMvGr`
- `MPCaMvIS`
- `MPCaMvIs`
- `MPCaMvPB`
- `MPCaMvSt`
- `MPCaNucl`
- `MPCaPesa`
- `MPCaPlan`
- `MPCaSiSt`
- `MPCaTrFu`
- `MPGEPLAN`
- `MPGESIST`
- `MPGeAvia`
- `MPGeBox`
- `MPGeGran`
- `MPGeLote`
- `MPGeNucl`
- `MPViLote`
- `PECAGADO`
- `PECaGado`
- `POCAACPR`
- `POCAAUXI`
- `POCACOND`
- `POCACONF`
- `POCACONS`
- `POCADEPR`
- `POCAEMPR`
- `POCALOPR`
- `POCAMVES`
- `POCAMVFI`
- `POCAMVNO`
- `POCAMvEs`
- `POCAMvNo`
- `POCANATU`
- `POCAPRCC`
- `POCAPROD`
- `POCARAMO`
- `POCASETO`
- `POCATPMV`
- `POCATpMv`
- `POCAUNFI`
- `POCAUNID`
- `POCaAuxi`
- `POCaCamp`
- `POCaCard`
- `POCaCent`
- `POCaClie`
- `POCaCole`
- `POCaCond`
- `POCaCons`
- `POCaEmpr`
- `POCaIdad`
- `POCaMvEs`
- `POCaMvFi`
- `POCaMvNo`
- `POCaNatu`
- `POCaNota`
- `POCaPess`
- `POCaReEs`
- `POCaRela`
- `POCaTabe`
- `POCaTpMv`
- `POCaUnid`
- `POGECENT`
- `POGEESTO`
- `POGEFINA`
- `POGEMVCX`
- `POGEPESS`
- `POGEPROD`
- `POGEUNME`
- `POGeCaix`
- `POGeFina`
- `POGeMvCx`
- `POGeNota`
- `POGePesa`
- `POGePess`
- `POGeProd`
- `POREUNFI`
- `POVIMVCX`
- `POVIUNFI_BAIX`
- `POViAcCa`
- `POViAcEm`
- `POViAcPr`
- `POViMvND`
- `POXXMVFI`
- `SIBKTABE_ST`
- `SISTOBRE`
- `SISTRELA`
- `SISTTABE`
- `TABE`
- `TABLE`
- `VDCAMVPE`
- `VDCAMVPO`
- `VDCAPEDI`
- `VDCAPEOU`
- `VSESSION`
- `ou`
- `pocafina`
- `pocamves`
- `pogeesto`
- `pogeprod`

## 📊 Resumo

- **Stored Procedures:** 2
- **Queries SQL:** 1
- **Tabelas:** 139

## ✅ Próximos Passos

1. Documentar parâmetros de cada stored procedure
2. Verificar se SPs existem em `Scripts\Procedures & Functions\`
3. Analisar queries dinâmicas (WHERE conditions adicionados em runtime)
4. Mapear relacionamentos entre tabelas
5. Identificar regras de negócio nas SPs
