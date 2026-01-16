{$DEFINE ERPUNI_FRAME}
unit POHeCam6;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, sgTypes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet, sgQuery, Vcl.Menus,
  sgPop, sgBtn, sgTbs, sgPgc, sgPnl, MemLbl, System.Generics.Collections,
  {$ifdef ERPUNI}
    uniMainMenu, uniButton, uniPageControl, uniGUIClasses, uniGUIBaseClasses, uniMemo, uniGUIFrame, uniGroupBox, uniPanel, uniEdit,
  {$ELSE}
    cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, cxButtons, MaskEdEx, dxUIAClasses,
  {$ENDIF}
  {$IFDEF ERPUNI_MODAL}
    POsgFormModal, POHeFormModal, POHeGeraModal,
  {$ELSE}
    POsgForm, POHeForm, POHeGera,
  {$ENDIF}
  sgForm, sgFormModal, PlusUni, Func,
  sgClientDataSet, ComCtrls, POFrGrMv, POFrGrid, sgDBG, sgBvl, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Phys, FireDAC.VCLUI.Wait, sgFrame, Data.Win.ADODB, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Mask, EdtLbl, sgDBG2, POFrCaMv, sgLeitSeri, EnviMail, sgScrollBox, sgClass, cxControls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  EdtExtControls;

const
  cEspaTabe = 10;
  cTamaTabe = 72; //110-28-10;
  cAltuTabe = 10;
  cAltuMovi = 240;
type
  {$IFDEF ERPUNI_MODAL}
    TFrmPOHeCam6 = class(TFrmPOHeGeraModal)
  {$ELSE}
    TFrmPOHeCam6 = class(TFrmPOHeGera)
  {$ENDIF}
    QryTabeConf: TsgQuery;
    DtsTabeConf: TDataSource;
    PnlDado: TsgPnl;
    Pnl1: TsgPnl;
    EdtSeriRece: TEdtLbl;
    EdtSeriEnvi: TEdtLbl;
    MaiEnvi: TEnviMail;
    procedure FormShow(Sender: TObject); override;
    procedure BtnConfClick(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    {$ifdef ERPUNI}
    {$ELSE}
      procedure Grav(iConfig: TsgLeitSeri; Valo: string);
      procedure LePeso(iConfig: TsgLeitSeri; iPeso: Real);
    {$ENDIF}
    procedure QryTabeConfBeforeOpen(DataSet: TDataSet);
  private
    Criado: Boolean;
    PrimGui1, PrimGui2, PrimMov1: {$ifdef ERPUNI}TUniControl{$else}TWinControl{$endif};
    {$ifdef ERPUNI}
    {$ELSE}
      DtbCada: TsgConn;
    {$ENDIF}
    FPgcMovi: TsgPgc;
    fListMovi: TObjectList<TMovi>;
    fListLeitSeri: TObjectList<TsgLeitSeri>;

    procedure MudaTab2(Sender: TObject; var Key: Char);
    procedure DuplClic(Sender: TObject);
    procedure ListChecColumnClick(Sender: TObject; Column: TListColumn);
    procedure InicCampSequ(Tipo: String; var Mens, iListCamp, iListValo: String);
    procedure ConfPortSeri;
    function CriaTbs(iPgc: TsgPgc; iNome: String): TsgTbs;
    function GetPgcMovi: TsgPgc;

    property PgcMovi: TsgPgc read GetPgcMovi write FPgcMovi;
    property ListMovi: TObjectList<TMovi> read fListMovi write fListMovi;

    property ListLeitSeri: TObjectList<TsgLeitSeri> read fListLeitSeri write fListLeitSeri;
  public
    {$ifdef ERPUNI}
      {$IFDEF ERPUNI_MODAL}
      {$ELSE}
        procedure LoadCompleted; override;
      {$ENDIF}
    {$ELSE}
    {$ENDIF}
    procedure AtuaGrid(iPara: Boolean=False; iCodiTabe: Integer = 0); override;
    procedure AfterCreate(Sender: TObject); override;
    function BuscaComponente(iNome: String): TObject; override;
    function IsWeb: Boolean;
  end;

var
  FrmPOHeCam6: TFrmPOHeCam6;

implementation

{$R *.dfm}

uses
  Funcoes, DmPoul, DmPlus, RxEdtLbl, DBLcbLbl, LcbLbl, DBEdtLbl, Datasnap.DBClient, sgPrinDecorator, sgConsts, Log, TradConsts
  {$ifdef ERPUNI}
    , uniGUIApplication, DmCall, PlusUnig, LstLbl
  {$ELSE}
    , Plus
  {$ENDIF}
  {$IFDEF ERPUNI_MODAL}
  {$ELSE}
  {$ENDIF}
  ;

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

function TFrmPOHeCam6.CriaTbs(iPgc: TsgPgc; iNome: String): TsgTbs;
begin
  Result := TsgTbs.Create(Self);
  {$IFDEF ERPUNI}
    Result.Parent := iPgc;
    Result.AutoScroll := True;
  {$ELSE}
    Result.Parent := Self;
  {$ENDIF}
  Result.PageControl := iPgc;
  Result.Name := 'Tbs'+iNome;
end;

function TFrmPOHeCam6.BuscaComponente(iNome: String): TObject;
var
  i: integer;
begin
  Result := nil;
  iNome := AnsiUpperCase(iNome);
  if iNome = 'DTSGRAV' then
    Result := DtsGrav
  else if iNome = 'QRYGRAV' then
  begin
    if Assigned(DtsGrav.DataSet) and (DtsGrav.DataSet.ClassType = tsgQuery) then
      Result := DtsGrav.DataSet
    else
      Result := QryGrav
  end
  else if iNome = 'QRYTELA' then
    Result := QryTela
  else if iNome = 'QRYSQL' then
    Result := QrySQL
  {$ifndef ERPUNI}
    else if iNome = 'DTBCADA' then
    begin
      if Assigned(sgTransaction) and (sgTransaction.CodiTabe <> HelpContext)  then //Pega o DTB do pai
        Result := sgTransaction
      else
        Result := DtbCada;
    end
  {$endif}
  else
  begin
    if StrIn(Copy(iNome,01,03), ['PNL','QRY', 'DTS', 'DBG', 'GRA', 'BTN']) then
    begin
      for I := 0 to ListMovi.Count-1 do
      begin
        if StrIn(iNome, ['QRYDAD'+IntToStr(i), 'QRYDADO'+IntToStr(i), 'QRY'+IntToStr(ListMovi[i].CodiTabe), 'QRYD'+IntToStr(ListMovi[i].CodiTabe), 'QRYDAD'+IntToStr(ListMovi[i].CodiTabe)]) then
        begin
          Result := ListMovi[i].FraMovi.QryGrid;
          Break;
        end
        else if StrIn(iNome, ['QRYMOV'+IntToStr(i), 'QRYMOVI'+IntToStr(i), 'QRY'+IntToStr(ListMovi[i].CodiTabe), 'QRYM'+IntToStr(ListMovi[i].CodiTabe), 'QRYMOV'+IntToStr(ListMovi[i].CodiTabe)]) then
        begin
          Raise Exception.Create('Componente QryMov'+IntToStr(i)+' não é mais usados neste modelo de Formulário!');
          //Result := ListMovi[i].FraMovi.QryMovi;
        end
        else if StrIn(iNome, ['DTSMOV'+IntToStr(i), 'DTSMOVI'+IntToStr(i), 'DTS'+IntToStr(ListMovi[i].CodiTabe), 'DTSM'+IntToStr(ListMovi[i].CodiTabe), 'DTSMOV'+IntToStr(ListMovi[i].CodiTabe)]) then
        begin
          Raise Exception.Create('Componente DtsMov'+IntToStr(i)+' não é mais usados neste modelo de Formulário!');
        end
        else if StrIn(iNome, ['DBGDAD'+IntToStr(i), 'DBGDADO'+IntToStr(i), 'DBG'+IntToStr(ListMovi[i].CodiTabe), 'DBGD'+IntToStr(ListMovi[i].CodiTabe), 'DBGDAD'+IntToStr(ListMovi[i].CodiTabe)]) then
        begin
          Result := ListMovi[i].FraMovi.DbgGrid;
          Break;
        end
        else if StrIn(iNome, ['BTNNOV'+IntToStr(i), 'BTNNOV'+IntToStr(ListMovi[i].CodiTabe), 'BTNNOVO'+IntToStr(i)
                            , 'BTNN'+IntToStr(ListMovi[i].CodiTabe)
                            , 'BTNINCL'+IntToStr(i), 'BTNINC'+IntToStr(i), 'BTNINC'+IntToStr(ListMovi[i].CodiTabe)
                            , 'BTNI'+IntToStr(ListMovi[i].CodiTabe)]) then
        begin
          Result := ListMovi[i].FraMovi.BtnNovo;
          Break;
        end
        else if StrIn(iNome, ['BTNALT'+IntToStr(i), 'BTNALT'+IntToStr(ListMovi[i].CodiTabe), 'BTNALTE'+IntToStr(i), 'BTNA'+IntToStr(ListMovi[i].CodiTabe)]) then
        begin
          Result := ListMovi[i].FraMovi.BtnAlte;
          Break;
        end
        else if StrIn(iNome, ['BTNEXC'+IntToStr(i), 'BTNEXC'+IntToStr(ListMovi[i].CodiTabe), 'BTNEXCL'+IntToStr(i), 'BTNE'+IntToStr(ListMovi[i].CodiTabe)]) then
        begin
          Result := ListMovi[i].FraMovi.BtnExcl;
          Break;
        end
        else if StrIn(iNome, ['PNL'+IntToStr(ListMovi[i].CodiTabe), 'PNL0'+IntToStr(ListMovi[i].CodiTabe)]) then
        begin
          Result := ListMovi[i].PnlResu;
          Break;
//        end
//        else if StrIn(iNome, ['PNL0'+IntToStr(ListMovi[i].GeTaTabe)]) then
//        begin
//          Result := ListMovi[i].PnlResu;
//          Break;
        end;
      end;
    end;

    if not Assigned(Result) then
      Result := inherited BuscaComponente(iNome);
  end;
end;

procedure TFrmPOHeCam6.MudaTab2(Sender: TObject;var Key: Char);
{$ifdef ERPUNI}
{$ELSE}
  var
    I: Integer;
    PageInde, NovoInde: Integer;

    Function MudaTabe2_BuscTbs_Index(Comp: TObject): Integer;
    begin
      if Comp = Nil then
        Result := -1
      else if AnsiUpperCase(Comp.ClassName) = AnsiUpperCase('TsgTbs') then
        Result := TsgTbs(Comp).PageIndex
      else
        Result := MudaTabe2_BuscTbs_Index(TWinControl(Comp).Parent);
    end;
{$ENDIF}
begin
  {$ifdef ERPUNI}
  {$ELSE}
    {  if (Key = #27) and (PrimGui2 <> nil) and PrimGui2.Enabled and PrimGui2.Visible then
    begin
      PgcGene.ActivePage := Tbs2;
      PrimGui2.SetFocus;
    end;}
    if (Key = #27) then
    begin
      PageInde := MudaTabe2_BuscTbs_Index(Sender);
      if (PageInde >= 0) and (not((PageInde = 0) and PnlDado.Visible)) then //Primeira guia, tem o movimento nela, se tiver o movimento, não faz nada
      begin
        if PageInde = (PgcGene.PageCount - 1) then  //Última guia
          UltiConf(Sender, Key)
        else
        begin
          NovoInde := PageInde;
          for I := (PageInde+1) to PgcGene.PageCount - 1 do
          begin
            if PgcGene.Pages[i].TabVisible then
            begin
              NovoInde := PgcGene.Pages[i].PageIndex;
              Break;
            end;
          end;
          if NovoInde = PageInde then  //Último Visivel
            UltiConf(Sender, Key)
          else
          begin
            PgcGene.TabStop := PnlDado.Visible;
            if PgcGene.Focused then
              Perform(Wm_NextDlgCtl,0,0);
            PgcGene.ActivePage := PgcGene.Pages[NovoInde];
          end;
        end;
      end;
    end;
  {$ENDIF}
end;

procedure TFrmPOHeCam6.QryTabeConfBeforeOpen(DataSet: TDataSet);
begin
  if GetConfWeb.Modo = cwModoMobile then
    QryTabeConf.SQL.Text := isMobi_POCaCamp_Sele(QryTabeConf.SQL.Text);
  inherited;
end;

Procedure TFrmPOHeCam6.ConfPortSeri();
{$ifdef ERPUNI}
{$ELSE}
  var
    Maqu, Conf: String;
    cds: TClientDataSet;
    vsgLeitSeri: TsgLeitSeri;
    vEdtLbl: TEdtLbl;
{$ENDIF}
begin
  {$ifdef ERPUNI}
  {$ELSE}
    ListLeitSeri.Clear;
    if QryTabeConf.Active then
    begin
      if Pos('//',QryTabeConf.FieldByName('SeriTabe').AsString) > 0 then
      begin
        vsgLeitSeri := TsgLeitSeri.Create_Owner(Self);
        vsgLeitSeri.Configur    := QryTabeConf.FieldByName('SeriTabe').AsString;
        vsgLeitSeri.proResuSeri := Grav;
        vsgLeitSeri.proPegaPeso := LePeso;
        vsgLeitSeri.EdtLbl      := EdtSeriRece;
        EdtSeriRece.Lista.Text := QryTabeConf.FieldByName('InSeTabe').AsString;
        vsgLeitSeri.Open;
        ListLeitSeri.Add(vsgLeitSeri);
      end
      else
      begin

        //Não funcionou o Like
        //DtmPoul.Campos_Busc(ConfTabe.CodiTabe, '', '([NameCamp] = '+QuotedStr('LEITSERI')+') AND ([NameCamp] LIKE '+QuotedStr('%'+Maqu+';%')+')', 'Exp1Camp');
        cds := DtmPoul.Campos_Cds(ConfTabe.CodiTabe, 'LeitSeri', '');
        if not cds.isEmpty then
        begin
          Maqu := Func.PegaMaqu();
          ExibMensHint('Cria Porta Serial/IP. Máquina: '+Maqu);
          while not cds.Eof do
          begin
            if (cds.FieldByName('LabeCamp').AsString.Trim = '') or (sgPos(';'+Maqu+';', ';'+cds.FieldByName('LabeCamp').AsString+';') > 0) then
            begin
              Conf := cds.FieldByName('Exp1Camp').AsString;
              if Pos('//',Conf) > 0 then
              begin
                vsgLeitSeri := TsgLeitSeri.Create_Owner(Self);
                vsgLeitSeri.Configur    := Conf;
                vsgLeitSeri.proPegaPeso := LePeso;

                //Somente se tiver o componente para enviar os dados
                if cds.FieldByName('HintCamp').AsString.Trim <> '' then
                  vsgLeitSeri.proResuSeri := Grav;

                vEdtLbl := TEdtLbl(BuscaComponente('Edt'+cds.FieldByName('HintCamp').AsString));
                if not Assigned(vEdtLbl) then
                begin
                  vEdtLbl := TEdtLbl.Create(Self);
                  vEdtLbl.Name := 'Edt'+cds.FieldByName('HintCamp').AsString;
                  vEdtLbl.Visible := False;
                end;
                vsgLeitSeri.EdtLbl      := vEdtLbl;
                vsgLeitSeri.NumeVariReal:= cds.FieldByName('InicCamp').AsInteger;
                vEdtLbl.Lista.Text      := cds.FieldByName('ExprCamp').AsString;

                vsgLeitSeri.Open;
                ListLeitSeri.Add(vsgLeitSeri)
              end;
            end;
            cds.Next;
          end;
          cds.Close;
          FreeAndNil(cds);
        end;
      end;

    end;
  {$ENDIF}
end;

procedure TFrmPOHeCam6.AtuaGrid(iPara: Boolean=False; iCodiTabe: Integer = 0);
var
  i: integer;
begin
  if iCodiTabe > 0 then
  begin
    for i := 0 to ListMovi.Count-1 do
    begin
      if ListMovi[i].CodiTabe = iCodiTabe then
      begin
        ListMovi[i].FraMovi.AtuaGridMovi(iPara);
        Break;
      end;
    end;
  end;
  inherited;
end;

//Executar o Duplo Clique, tratado conforme o componente
procedure TFrmPOHeCam6.DuplClic(Sender: TObject);
begin
  CampPersDuplCliq(Self, Sender);
end;

//LisTChkLbl, clique na coluna para ordenar
procedure TFrmPOHeCam6.ListChecColumnClick(Sender: TObject; Column: TListColumn);
begin
  CampPersListChecColumnClick(Sender, Column);
end;

{$ifdef ERPUNI}
  {$IFDEF ERPUNI_MODAL}
  {$ELSE}
    procedure TFrmPOHeCam6.LoadCompleted;
    var
      i, j: integer;
      Coluna: String;
    begin
      inherited;
          for i := 0 to (ComponentCount - 1) do
          begin
            If (Components[i] is TLstLbl) then
            begin
              if Assigned(TLstLbl(Components[i]).Query) and (TLstLbl(Components[i]).Query.Active) then
              begin
                Coluna := TLstLbl(Components[i]).Coluna.Text;
                for j := 0 to TLstLbl(Components[i]).Columns.Count - 1 do
                begin
                  if TLstLbl(Components[i]).Columns[j].Visible then
                  begin
                    if TLstLbl(Components[i]).Columns[j].Width > 180 then
                      TLstLbl(Components[i]).Columns[j].Width := 180;
                  end;
                end;
                TLstLbl(Components[i]).CarregaDados();
                TLstLbl(Components[i]).Coluna.Text := Coluna;
              end;
            end;
          end;
    end;
  {$ENDIF}
{$else}
{$endif}

//******************************************************************************
//******************************************************************************

procedure TFrmPOHeCam6.BtnConfClick(Sender: TObject);
var
  i, j : Integer;
  Focu: TComponent;
  Mens: String;

  function BtnConf_CampModi(): Boolean;
  var
    z: integer;
  begin
    Result := False;
    if Assigned(Prin_D) then
    begin
      Prin_D.Dts_To_New;
      if (Prin_D.TabNewOld.New.getPropTableValue('ApAt'+ConfTabe.FinaTabe) <> Prin_D.TabNewOld.Old.getPropTableValue('ApAt'+ConfTabe.FinaTabe)) then
        Exit;
    end;

    if (ConfTabe.GravTabe <> '') and (not PSitGrav) then
    begin
      if Assigned(DtsGrav.DataSet)
        and (DtsGrav.DataSet.FindField('Tabe'+ConfTabe.FinaTabe) <> nil)
        and (DtsGrav.DataSet.FindField('CodiGene') <> nil) then
      begin
        if (Trim(DtsGrav.DataSet.FieldByName('Tabe'+ConfTabe.FinaTabe).AsString) <> '') and
                (DtsGrav.DataSet.FieldByName('CodiGene').AsInteger <> 0) then
        begin
          if DtsGrav.DataSet.Modified then
          begin
            DtmPoul.QryCalc.SQL.Clear;
            DtmPoul.QryCalc.SQL.Add('SELECT CompCamp, NameCamp, LabeCamp');
            DtmPoul.QryCalc.SQL.Add('FROM POCaCamp');
            DtmPoul.QryCalc.SQL.Add('WHERE (POCaCamp.CodiTabe = '+IntToStr(ConfTabe.CodiTabe)+')');
            DtmPoul.QryCalc.SQL.Add('AND (CompCamp NOT IN (''BVL'',''LBL'',''BTN'',''DBG'',''GRA'',''T''))');
            DtmPoul.QryCalc.SQL.Add('AND (InteCamp = 0)');
            DtmPoul.QryCalc.SQL.Add('ORDER BY GuiaCamp, OrdeCamp');
            DtmPoul.QryCalc.Open;
            while (not DtmPoul.QryCalc.Eof) and (not Result) do
            begin
              Result := CampPersCompAtuaGetProp(Self, CampPersCompAtua(Self, DtmPoul.QryCalc.FieldByName('CompCamp').AsString, DtmPoul.QryCalc.FieldByName('NameCamp').AsString),'Modified');
              if Result then
              begin
                CampPersAcao(Self, EspaDire(DtmPoul.QryCalc.FieldByName('CompCamp').AsString,02)+'-'+DtmPoul.QryCalc.FieldByName('NameCamp').AsString+'-1','F');
                sgMessageDlg('Dados Gerados por outro Processo. Informação não pode ser modificada: '+SubsPala(DtmPoul.QryCalc.FieldByName('LabeCamp').AsString,'&',''), mtInformation, [mbOK], 0);
              end;
              DtmPoul.QryCalc.Next;
            end;
            DtmPoul.QryCalc.Close;

            if (not Result) then
            begin
              for z := 0 to ListMovi.Count-1 do
              begin
                if (not ListMovi[z].FraMovi.ClicEnviRemo) then
                begin
                  DtsGrav.DataSet.FieldByName('ApAt'+ConfTabe.FinaTabe).AsInteger := DtsGrav.DataSet.FieldByName('ApAt'+ConfTabe.FinaTabe).AsInteger + 1;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;

var
  vLinh, vListValo, vListCamp: String;
  Lcb: TDbLcbLbl;

begin
  if (BtnConf.Visible) and (BtnConf.Enabled) then
  begin
    try
      BtnConf_Ante(Sender);

      if ConfTabe.CodiTabe = 16120 then
        msgAviso('Esta opção de Autorização será desativada. Favor utilizar a opção "Autorização de Compras (Padrão)".');
      if ConfTabe.CodiTabe = 16130 then
        msgAviso('Esta opção de Autorização será desativada. Favor utilizar a opção "Autorização de Compras - Diretoria (Padrão)".');

      if ListLeitSeri.Count > 0 then
        ExibMensHint('Fecha Porta Serial/IP');
      for i := 0 to ListLeitSeri.Count-1 do
        ListLeitSeri[i].Close;

      Perform(Wm_NextDlgCtl,0,0);
      if (not BtnConf_CampModi) and ConfGrav(Self, ConfTabe.CodiTabe) then
      begin
        if StrIn(ConfTabe.GravTabe, ['MPCAPARA', 'MPVIPARA']) then
        begin
          CampPersInicGravPara(Self, ConfTabe.CodiTabe, (ConfTabe.GravTabe = 'MPVIPARA'), False);
          RecaDadoGera();
          VeriEnviConf(Self, CampPers_TratExec(Self, QryTabeConf.FieldByName('EGraTabe').AsString, QryTabeConf.FieldByName('EPerTabe').AsString));
          Close;
        end
        else
        begin
          //**** Pegar o campo que foi setado o Focus, antes de passar pelo FormShow
          Focu := nil;
          GetConfWeb.MemVal1.Clear;
          try
            GetConfWeb.MemVal1.Text := CampPers_TratExec(Self, QryTabeConf.FieldByName('LancTabe').AsString, QryTabeConf.FieldByName('EPerTabe').AsString);
            j := 0;
            while j < GetConfWeb.MemVal1.Count do
            begin
              vLinh := GetConfWeb.MemVal1.Strings[j];
              if CampPersValiExecLinh(GetConfWeb.MemVal1.Strings[j]) then
              begin
                if (Copy(GetConfWeb.MemVal1.Strings[j],03,01) = 'F') then //Executa o Focus em algum campo
                begin
                  for i := 0 to ComponentCount - 1 do
                  begin
                    if BuscPareWin(Components[i].ClassType) then
                      if {$ifdef ERPUNI}TUniControl{$else}TWinControl{$endif}(Components[i]).Focused then
                        Focu := Components[i];
                  end;
                end
                else if (Copy(GetConfWeb.MemVal1.Strings[j],01,01) = 'M') then //Mensagem, passa mais uma linha
                  Inc(j)
              end;
              Inc(j);
            end;
            //*****

            if DtsGrav.DataSet <> nil then
            begin
              if PSitGrav then
                InicCampSequ('VERI', Mens, vListCamp, vListValo);

              Criado := True;
              if sgIsMovi then
              begin
                DtsGrav.DataSet.FieldByName('CodiUsua').AsInteger := 0;
                DtsGrav.DataSet.FieldByName('Marc'+ConfTabe.FinaTabe).AsInteger := 0;
              end;
              inherited GravSemC(Sender);  //Tirado para poder fazer o Commit antes de entrar no FormShow

              //??  Tratar o PWheRela (buscar pela chave)
              GetConfWeb.PWheRela := '';

              if Mens <> '' then
                msgOk(Mens);
            end
            else
            begin
              VeriEnviConf(Self, CampPers_TratExec(Self, QryTabeConf.FieldByName('EGraTabe').AsString, QryTabeConf.FieldByName('EPerTabe').AsString));
              if (not ConfTabe.FechaConfirma) then
                FormShow(Self);
            end;

            if PSitGrav and (not ConfTabe.FechaConfirma) then //Só executa se for incluindo e não Fecha no Confirma, que daí prepara para nova Inclusão
            begin
              if (Focu <> nil) then
                {$ifdef ERPUNI}TUniControl{$else}TWinControl{$endif}(Focu).SetFocus;

              //Executa após o clique no Confirma
              VeriEnviConf(Self, CampPers_TratExec(Self, QryTabeConf.FieldByName('AposTabe').AsString, QryTabeConf.FieldByName('EPerTabe').AsString));

              for i := 0 to (ComponentCount - 1) do
              begin
                If (Components[i].ClassType = TsgQuery) and (Components[i].Tag = 5) then
                begin
                  Lcb := TDbLcbLbl(FindComponent('Lcb'+Copy(Components[i].Name,04,08)));
                  if Assigned(Lcb) then
                  begin
                    if not sgIsMovi then  //Componente do Cabeçalho
                      TsgQuery(Components[i]).Next
                    else //Componente do Movimento
                      TsgQuery(Components[i]).First;
                  end;
                end;
              end;
            end;
          finally
            GetConfWeb.MemVal1.Clear;
          end;
        end;
      end;
    finally
      if (not ConfTabe.FechaConfirma) then
      begin
        if ListLeitSeri.Count > 0 then
          ExibMensHint('Abre Porta Serial/IP');
        for i := 0 to ListLeitSeri.Count-1 do
          ListLeitSeri[i].Open;
      end;
      BtnConf_Depo(Sender);
    end;
  end;
end;

procedure TFrmPOHeCam6.FormCreate(Sender: TObject);
var
  vMovi: TMovi;
  vTbs: TsgTbs;
  vFraCaMv: TFraCaMv;
begin
  try
    {$ifdef ERPUNI}
    {$ELSE}
      if not Assigned(sgTransaction) then
      begin
        DtbCada := TsgConn.Create(Self);
        DtbCada.Name := 'DtbCada';
        DtbCada.LoginPrompt := False;
        DtbCada.CodiTabe := GetPTab;
        ConfConnectionString(DtbCada);
        sgTransaction := TsgTransaction(DtbCada);
      end
      else
        DtbCada := sgTransaction;
    {$ENDIF}

    fListLeitSeri := TObjectList<TsgLeitSeri>.Create;

    //Criar antes do Inherited para passar pela formatação de campos do sgForm.Create
    fListMovi  := TObjectList<TMovi>.Create();
    sgTem_Movi := False;
    if not (sgTipoclic in [tcClicShow, tcClicShowAces]) then
    begin
      with DtmPoul do
      begin
        try
          QryTabe.Filtered := False;
          QryTabe.Filter   := '(CabeTabe = '+IntToStr(GetPTab)+')';
          QryTabe.Filtered := True;
          QryTabe.Sort     := 'SeriTabe';
          QryTabe.First;
          while not QryTabe.Eof do
          begin
             vMovi := TMovi.Create;
             vMovi.CodiTabe := QryTabe.FieldByName('CodiTabe').AsInteger;
             vMovi.GeTaTabe := QryTabe.FieldByName('GeTaTabe').AsInteger;
             vMovi.SeriTabe := sgStrToInt(QryTabe.FieldByName('SeriTabe').AsString);

             //Fica na primeira guia
             if vMovi.SeriTabe > 50 then
               vTbs := CriaTbs(PgcMovi, 'Mov'+IntToStr(vMovi.CodiTabe))
             else
               vTbs := CriaTbs(PgcGene, 'Mov'+IntToStr(vMovi.CodiTabe));

             vFraCaMv := TFraCaMv.Create(Self);
             vFraCaMv.Parent := vTbs;
             vFraCaMv.Name   := 'FraCaMv'+IntToStr(vMovi.CodiTabe);
             vFraCaMv.HelpContext := vMovi.CodiTabe;
             vFraCaMv.FraMovi.PopGridAjud.Caption := resMnuAjud_Hint+' ('+FormInteBras(vMovi.CodiTabe)+')';
             vFraCaMv.FraMovi.PopGridAjud.Visible := True;
             vFraCaMv.FraMovi.PopGridAjudSepa.Visible := True;

             vMovi.FraCaMv := vFraCaMv;
             vTbs.AutoScroll := False;

             if vMovi.SeriTabe > 50 then  //Na primeira guia
               vFraCaMv.FraMovi.PnlTopo.Margins.Left := 6
             else
               vFraCaMv.FraMovi.PnlTopo.Margins.Left := 10;
             vFraCaMv.FraMovi.DbgGrid.Margins.Left := vFraCaMv.FraMovi.PnlTopo.Margins.Left;

             sgTem_Movi := True;
             {$IFDEF ERPUNI_MODAL}
               vMovi.FraMovi.FormParentModal := Self;
             {$ELSE}
               vMovi.FraMovi.FormParent := Self;
             {$ENDIF}

             vMovi.FraMovi.ConfTabe.CodiTabe := QryTabe.FieldByName('CodiTabe').AsInteger;
             vMovi.FraMovi.ConfTabe.NomeTabe := QryTabe.FieldByName('NomeTabe').AsString;
             vMovi.FraMovi.ConfTabe.FormTabe := QryTabe.FieldByName('FormTabe').AsString;
             vMovi.FraMovi.ConfTabe.GravTabe := QryTabe.FieldByName('GravTabe').AsString;
             vMovi.FraMovi.ConfTabe.CaptTabe := QryTabe.FieldByName('CaptTabe').AsString;
             //vMovi.FraMovi.ConfTabe.ChavTabe := QryTabe.FieldByName('ChavTabe').AsInteger;
             //vMovi.FraMovi.ConfTabe.HintTabe := QryTabe.FieldByName('HintTabe').AsString;

             vTbs.Caption := '* '+CampPers_TratNome(QryTabe.FieldByName('Gui1Tabe').AsString);

             QryTabeGrid.Close;
             QryTabeGrid.Params.ParamByName('Tabe').Value := vMovi.CodiTabe;
             QryTabeGrid.Open;
             vMovi.FraMovi.DbgGrid.Coluna.Text  := TradSQL_Cons(0, QryTabeGrid.FieldByName('GrCoTabe').AsString, True,  'GRIDTABE', vMovi.CodiTabe);
             vMovi.FraMovi.QryGrid.SQL.Text     := TradSQL_Cons(0, QryTabeGrid.FieldByName('GridTabe').AsString, False, 'GRIDTABE', vMovi.CodiTabe);
             vMovi.FraMovi.QryGrid.SQL_Back.Text:= vMovi.FraMovi.QryGrid.SQL.Text;
             QryTabeGrid.Close;

             ListMovi.Add(vMovi);

             QryTabe.Next;
          end;
        finally
        end;
      end;
    end;

    Criado := False;

    inherited;

    //AfterCreate(Nil);
  except
    Width := 500;
    Height := 400;
    raise;
  end;
end;

procedure TFrmPOHeCam6.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  inherited;

  {$ifdef ERPUNI}
  {$else}
    if Action = caNone then Exit;

    QryGrav.Cancel;

    if PSitGrav and sgTem_Movi and ((ConfTabe.Operacao = opIncl) and not (ConfTabe.ClicConf)) then
      ExecSQL_('DELETE FROM '+ConfTabe.GravTabe+' WHERE '+ConfTabe.NomeCodi+' = '+IntToStr(ConfTabe.CodiGrav), sgTransaction);

    if Assigned(DtbCada) then
    begin
      if DtbCada.CodiTabe = ConfTabe.CodiTabe then
      begin
        if DtbCada = GetPsgTrans then
          SetPsgTrans(nil);
        sgTransaction := nil;
      end;
    end;

    ModalResult := mrOK;

    if sgTipoClic in [tcClicShow, tcClicShowIncl, tcClicShowAces] then
      Action := cafree;

    Criado := True;
  {$endif}

  if Assigned(fListLeitSeri) then
  begin
    for i := 0 to ListLeitSeri.Count-1 do
      ListLeitSeri[i].Close;
  end;
end;

procedure TFrmPOHeCam6.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  {$ifdef ERPUNI}
  {$else}
    if Assigned(DtbCada) then
    begin
      if DtbCada.CodiTabe = ConfTabe.CodiTabe then
      begin
        if DtbCada = GetPsgTrans then
          SetPsgTrans(nil);
        sgTransaction := nil;
        FreeAndNil(DtbCada);
      end;
    end;

    if Assigned(ExecShowTela) then
      ExecShowTela.Clear;

    if Assigned(fListMovi) then
      fListMovi.Clear;
    FreeAndNil(fListMovi);
  {$endif}

  if Assigned(fListLeitSeri) then
  begin
    for i := 0 to ListLeitSeri.Count-1 do
    begin
      ListLeitSeri[i].Close;
      ListLeitSeri[i].Free;
    end;
    fListLeitSeri.Clear;
    FreeAndNil(fListLeitSeri);
  end;

  inherited;
end;

//Tipo: _UN_: Chave única
//      Veri: Verifica
procedure TFrmPOHeCam6.InicCampSequ(Tipo: String; var Mens, iListCamp, iListValo: String);
var
  Nome, Name, Auxi: String;
  cds: TClientDataSet;
  vNume: Real;
begin
  Tipo := AnsiUpperCase(Tipo);

  cds := DtmPoul.Campos_Cds(ConfTabe.CodiTabe, '', '(ExisCamp = 0) '+
                                                   'AND (CompCamp IN (''N'',''EN'')) '+
                                                   'AND (InicCamp = 1) AND (TagQCamp = 1)');
  try
    cds.First;
    while not(cds.Eof) do
    begin
      Name := cds.FieldByName('NameCamp').AsString;
      Nome := cds.FieldByName('NomeCamp').AsString;
      if Tipo = '_UN_' then
      begin
        if (cds.FieldByName('CompCamp').AsString = 'N') then
        begin
          vNume := POCaNume_ProxSequ(ConfTabe.GravTabe,Nome+'_UN_',True);
          if TestDataSet(DtsGrav.DataSet) then
            DtsGrav.DataSet.FieldByName(Nome).AsFloat := vNume;
          iListCamp := iListCamp + SeStri(iListCamp='','',', ')+Nome;
          iListValo := iListValo + SeStri(iListValo='','',', ')+FormNumeSQL(vNume);
        end
        else if (cds.FieldByName('CompCamp').AsString = 'EN') then
          TRxEdtLbl(FindComponent('Edt'+Name)).Value:= POCaNume_ProxSequ(ConfTabe.GravTabe,Nome+'_UN_',True);
      end
      else if Tipo = 'SEQU' then
      begin
        if (cds.FieldByName('CompCamp').AsString = 'N') and TestDataSet(DtsGrav.DataSet) then
          DtsGrav.DataSet.FieldByName(Nome).AsFloat := POCaNume_ProxSequ(ConfTabe.GravTabe,Nome,False)
        else if (cds.FieldByName('CompCamp').AsString = 'EN') then
          TRxEdtLbl(FindComponent('Edt'+Name)).Value:= POCaNume_ProxSequ(ConfTabe.GravTabe,Nome,False);
      end
      else
      begin
        if (cds.FieldByName('CompCamp').AsString = 'N') and TestDataSet(DtsGrav.DataSet) then
        begin
          DtsGrav.DataSet.FieldByName(Nome).AsInteger := POCaNume_ProxSequ_VeriGrav(ConfTabe.GravTabe, Nome,
                                                                                    DtsGrav.DataSet.FieldByName(Nome).AsInteger,
                                                                                    Auxi)
        end
        else if (cds.FieldByName('CompCamp').AsString = 'EN') then
        begin
          TRxEdtLbl(FindComponent('Edt'+Name)).Value := POCaNume_ProxSequ_VeriGrav(ConfTabe.GravTabe, Nome,
                                                                                   DtsGrav.DataSet.FieldByName(Nome).AsInteger,
                                                                                   Auxi);
        end;
        if Trim(Auxi) <> '' then
          Mens := Mens + #10#13 + SubsPalaTudo(cds.FieldByName('LabeCamp').AsString,'&','')+': '+Auxi;
      end;
      cds.Next;
    end;
  finally
    cds.Close;
    cds.Free;
  end;
end;

procedure TFrmPOHeCam6.FormShow(Sender: TObject);
var
  i: Integer;
  vMens, vListValo, vListCamp: String;
  {$ifdef ERPUNI}
    {$ifdef ERPUNI_MODAL}
    {$else}
      vAuxi: Integer;
    {$endif}
  {$else}
  {$endif}
begin
  ConfTabe.ClicCanc := False;

  ExibMensHint('.:.');
  if Criado then
  begin
    if (not sgTem_Movi) and (sgTipoClic in [tcClicManuDeta, tcClicShowIncl]) then
      sgTem_Movi := True;

    AnteShow();

    ConfTabe.ValoSgCh := '';

    //Quando a Tela é Chamada por outra telas, as instruções estão no MemVal1
    if ExecShowTela.Count = 0 then
    begin
      ExecShowTela.Text := GetConfWeb.MemVal1.Text;
      ExecShowTela.Add('');  //Para não entrar mais aqui
      GetConfWeb.MemVal1.Clear;
    end;

    {$ifdef ERPUNI}
      {$ifdef ERPUNI_MODAL}
      {$else}
        try
          SuspendLayouts;
          if PnlDado.Visible then
          begin
            if QryTabeConf.FieldByName('TpGrTabe').AsInteger > 0 then
              vAuxi := QryTabeConf.FieldByName('TpGrTabe').AsInteger
            else
              vAuxi := QryTabeConf.FieldByName('AltuTabe').AsInteger - cTamaTabe + 15;

            if GetConfWeb.Modo = cwModoMobile then
            begin
              if vAuxi > (GetConfWeb.PAltReso-(cAltuMovi*2)) then
                vAuxi := GetConfWeb.PAltReso-(cAltuMovi*2);
            end;
            Pnl1.Height := vAuxi;
          end
          else
            Pnl1.Align := alClient;
        finally
          ResumeLayouts;
        end;
      {$endif}
    {$ELSE}
    {$ENDIF}

    PSitGrav := ConfTabe.SituGrav;
    if (sgTipoclic in [tcClicShow, tcClicShowAces]) then
      Caption := ConfTabe.NomeTabe
    else
      Caption := SeStri(PSitGrav,sInclusao,sAlteracao)+' de '+ConfTabe.NomeTabe;

    if StrIn(ConfTabe.GravTabe, ['MPCAPARA', 'MPVIPARA']) then
    begin
      CampPersInicGravPara(Self, ConfTabe.CodiTabe, (ConfTabe.GravTabe = 'MPVIPARA'), True);
    end
    else
    begin
      if PSitGrav then
        InicCampSequ('_UN_', vMens, vListCamp, vListValo);
      PreparaManu(vListCamp, vListValo);
      {$IFDEF ERPUNI}
      {$ELSE}
//        if (DtsGrav.DataSet <> nil) and (DtsGrav.DataSet <> QrySQL) and Assigned(DtsGrav.DataSet.AfterPost) then
//        begin
//          AftePost := DtsGrav.DataSet.AfterPost;
//          DtsGrav.DataSet.AfterPost := nil;
//        end;
      {$ENDIF}

      ExibMensHint('Iniciando Valores');
      InicValoCampPers(Self, ConfTabe.CodiTabe, DtsGrav, PSitGrav);
      if Assigned(Prin_D) and Assigned(DtsGrav.DataSet) then
      begin
        Prin_D.DataSet := TClientDataSet(DtsGrav.DataSet);
        if sgisMovi and (PSitGrav or (DtsGrav.DataSet.FieldByName(ConfTabe.NomeSgCh).AsString = '')) then
          DtsGrav.DataSet.FieldByName(ConfTabe.NomeSgCh).AsString := ConfTabe.ValoSgCh;
        TsgDecorator(Prin_D).Dts_To_Old;
      end;
    end;

    PopCopiGene.Visible := TestDataSet(DtsGrav);
    PopCopiGene.Enabled := TestDataSet(DtsGrav);
    N400.Visible        := TestDataSet(DtsGrav);

    for I := 0 to PgcGene.PageCount-1 do
    begin
      if PgcGene.Pages[i].TabVisible then
      begin
        PgcGene.ActivePage := PgcGene.Pages[i];
        Break;
      end;
    end;

    if PnlDado.Visible then
    begin
      for I := 0 to PgcMovi.PageCount-1 do
      begin
        begin
          PgcMovi.ActivePage := PgcMovi.Pages[i];
          Break;
        end;
      end;
    end;

    if Assigned(ListMovi) then
    begin
      for I := 0 to ListMovi.Count-1 do
      begin
        if Assigned(ListMovi[i].FraMovi.Prin_D) and Assigned(Prin_D) then
        begin
          ListMovi[i].FraMovi.Prin_D.Pai_Prin_D := Self.Prin_D;
          ListMovi[i].FraMovi.Prin_D.Conn := Self.Prin_D.Conn;
        end;
        ListMovi[i].FraMovi.PSitGrav := PSitGrav;
        ListMovi[i].FraMovi.Pai_Tabe.CodiGrav := DtsGrav.DataSet.Fields[0].AsInteger;
        ListMovi[i].FraMovi.sgTransaction          := Self.sgTransaction;
        ListMovi[i].FraMovi.QryGrid.sgTransaction  := Self.sgTransaction;
        //ListMovi[i].FraMovi.AtuaGridMovi();
      end;
    end;

    //Quando a Tela é Chamada por outra telas, as instruções estão no MemVal1 que foi passado pro ExecShowTela
    CampPersExecListInst(Self, ExecShowTela);

    ExibMensHint('Executa na Saída dos Campos');
    CampPersExecExitShow(Self, ConfTabe.CodiTabe);

    ExibMensHint('Executando instruções do On-Show');
    if PSitGrav or (sgTipoClic in [tcClicShow, tcClicShowAces, tcClicShowIncl]) then
      CampPersExecNoOnShow(Self, CampPers_TratExec(Self, QryTabeConf.FieldByName('ShowTabe').AsString, QryTabeConf.FieldByName('EPerTabe').AsString), True, '')
    else
      CampPersExecNoOnShow(Self, '', True); //Para fazer só a validação de Acesso a Campos

    if Assigned(ListMovi) then
    begin
      for I := 0 to ListMovi.Count-1 do
        ListMovi[i].FraMovi.AtuaGridMovi();
    end;

    PgcGene.ActivePage := Tbs1;
    if (PrimGui1 <> nil) and PrimGui1.Enabled and PrimGui1.Visible then
      PrimGui1.SetFocus;

    CampPers_CriaBtn_LancCont(Self);

    DepoShow();

    ExibMensHint('Habilita/Desabilita o Confirma');
    inherited HabiConf(Self);

    ExibMensHint('...');

    Criado := False;

    ConfPortSeri();
  end;
end;

function TFrmPOHeCam6.IsWeb: Boolean;
begin
  {$ifdef ERPUNI}
    Result := True;
  {$ELSE}
    Result := False;
  {$ENDIF}
end;

procedure TFrmPOHeCam6.AfterCreate(Sender: TObject);
var
  i: integer;
  vCont: Integer;
  vMaioTamaResu: Integer;
  vMensagem: String;
begin
  vMensagem := '';
  if Cria and (ConfTabe.CodiTabe > 0) then
  begin
    {$ifdef ERPUNI}
      SuspendLayouts;
    {$endif}
    try
      //Sidiney (07/04/2023): Adicionado antes do AnteCria para caso necessário manipular variaveis antes de criar os componentes (propriedade SQL_FK)
      if Assigned(Prin_D) then
        Prin_D.CriaObjs;

      ExibMensHint('AnteCria');
      CampPersExecDireStri(Self, DtmPoul.Campos_Busc(ConfTabe.CodiTabe, 'AnteCria', '', 'ExprCamp'), '');

      QryTabeConf.Close;
      QryTabeConf.Params[0].Value := ConfTabe.CodiTabe;
      QryTabeConf.Open;

      Cria := False;
      ExibMensHint('Criando Campos');

      try
        MontCampPers(ConfTabe.CodiTabe, 50, Self, DtsGrav, MudaTab2, nil, UltiConf, HabiConf, ClicBota, ExecExit, Pnl1, nil, nil, ArruTama,
                     DeleCons, ClicObs, PrimGui1, PrimGui2, PrimMov1, 01, TeclCons, DuplClic, ListChecColumnClick, ClicBusc);
      except
        on E: Exception do
           vMensagem := E.Message;
      end;
      msgRaiseTratada(vMensagem, vMensagem);

      Tbs1.TabVisible := Pnl1.Visible;
      Tbs1.Caption    := CampPers_TratNome(QryTabeConf.FieldByName('Gui1Tabe').AsString);
      if Assigned(TsgTbs(FindComponent('Tbs02'))) then
        TsgTbs(FindComponent('Tbs02')).Caption := CampPers_TratNome(QryTabeConf.FieldByName('Gui2Tabe').AsString);

      vMaioTamaResu := 0;
      if Assigned(Prin_D) then
        Prin_D.ListPrin.Clear;

      for I := 0 to ListMovi.Count-1 do
      begin
        if Trim(ListMovi[i].FraMovi.QryGrid.SQL.Text) = '' then
          ListMovi[i].CodiTabe := 0
        else
        begin
          if Assigned(Prin_D) and Assigned(ListMovi[i].FraMovi.Prin_D) then
            Prin_D.ListPrin.Add(ListMovi[i].FraMovi.Prin_D);

          ListMovi[i].FraMovi.QryGrid.SQL_Back.Text := ListMovi[i].FraMovi.QryGrid.SQL.Text;

          ListMovi[i].FraMovi.ConfTabe.CodiTabe := ListMovi[i].CodiTabe;
          //ListMovi[i].FraMovi.ConfTabe.ValoSgCh := ConfTabe.ValoSgCh;
          ListMovi[i].FraMovi.Pai_Tabe.Assign(Self.ConfTabe);

          if ListMovi[i].PnlResu.Visible then
          begin
            ListMovi[i].PnlResu.Height := StrToInt(RetoZero(DtmPoul.Campos_Busc(ConfTabe.CodiTabe, 'GUIARESU_'+IntToStr(ListMovi[i].CodiTabe), '', 'AltuCamp')));
            if ListMovi[i].PnlResu.Height = 0 then
              ListMovi[i].PnlResu.Height := 88;

            if ListMovi[i].SeriTabe > 50 then  //Mesma guia do Cabeçalho
            begin
              if vMaioTamaResu < ListMovi[i].PnlResu.Height then
                vMaioTamaResu := ListMovi[i].PnlResu.Height;
            end;
          end;
        end;
      end;

      vCont := 0;
      for I := 0 to PgcGene.PageCount-1 do
      begin
        if PgcGene.Pages[i].TabVisible then
        begin
          Inc(vCont);
          if vCont = 1 then
            PgcGene.ActivePage := PgcGene.Pages[i];
        end;
      end;
      PgcGene.TabBarVisible := vCont > 1;

      for I := 0 to PgcMovi.PageCount-1 do
      begin
        if PgcMovi.Pages[i].TabVisible then
        begin
          PgcMovi.Visible := True;
          PnlDado.Visible := True;
          Break;
        end;
      end;

      {$if not Defined(ERPUNI_MODAL) and Defined(ERPUNI)}
        //Quando Frame e Unigui ajusta no onShow
      {$else}
        if (QryTabeConf.FieldByName('AltuTabe').AsInteger = 9999) and (QryTabeConf.FieldByName('TamaTabe').AsInteger = 9999) then
        begin
          BorderIcons := [biSystemMenu, biMinimize, biMaximize];
          {$ifdef ERPUNI}
          {$else}
            BorderStyle := bsSizeable;
          {$endif}
          Height           := GetConfWeb.PAltReso;
          Width            := GetConfWeb.PTamReso;
        end
        else
        begin
          Height           := QryTabeConf.FieldByName('AltuTabe').AsInteger + SeInte(PnlDado.Visible, cAltuMovi, 0) + vMaioTamaResu + 10;
          Width            := QryTabeConf.FieldByName('TamaTabe').AsInteger + 5 - 50;
          Tbs1.Constraints.MinHeight := Height;
          Tbs1.Constraints.MinWidth := Width;
        end;

        if PnlDado.Visible then
        begin
          if QryTabeConf.FieldByName('TpGrTabe').AsInteger > 0 then
            Pnl1.Height := QryTabeConf.FieldByName('TpGrTabe').AsInteger
          else
            Pnl1.Height := QryTabeConf.FieldByName('AltuTabe').AsInteger - 55;
        end
        else
          Pnl1.Align := alClient;
      {$endif}


      ExibMensHint('Abrindo Cadastros');
      PopAtuaClick(Self);

      ExibMensHint('DepoCria');
      CampPersExecDireStri(Self, DtmPoul.Campos_Busc(ConfTabe.CodiTabe, 'DepoCria', '', 'ExprCamp'), '');
      ExibMensHint('.');
    finally
      {$ifdef ERPUNI}
        ResumeLayouts;
      {$endif}
    end;
    ExibMensHint('..');
  end;

//a  //PgcGene.ActivePage := Tbs1;
//  SetaPageAtiv();

  Criado := True;
end;

{$ifdef ERPUNI}
{$ELSE}
  procedure TFrmPOHeCam6.Grav(iConfig: TsgLeitSeri; Valo: string);
  begin
    if Assigned(iConfig) and Assigned(iConfig.EdtLbl) and (iConfig.EdtLbl.Text <> Valo) then
    begin
      Func.GravLog_Mens('Serial Valor: '+Valo);
      iConfig.EdtLbl.Text := Valo;
      CampPersExecListInst(Self, iConfig.EdtLbl.Lista);
    end;
  end;

  procedure TFrmPOHeCam6.LePeso(iConfig: TsgLeitSeri; iPeso: Real);
  begin
    if NumeroInRange(iConfig.NumeVariReal, 01, 20) then
    begin
      if Assigned(iConfig.EdtLbl) and (VariReal[iConfig.NumeVariReal] <> iPeso) then
      begin
        Func.GravLog_Mens('Serial Peso: '+FormRealBras(iPeso));
        VariReal[iConfig.NumeVariReal] := iPeso;
        CampPersExecListInst(Self, iConfig.EdtLbl.Lista);
      end;
    end;
  end;
{$ENDIF}

initialization
  RegisterClass(TFrmPOHeCam6);
end.
