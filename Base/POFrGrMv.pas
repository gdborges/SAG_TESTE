unit POFrGrMv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, POFrGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option, sgTypes,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Vcl.Menus,
  sgPop, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, sgQuery, sgLbl, Vcl.Controls, Vcl.Forms, sgPnl, sgBtn,
  {$ifdef ERPUNI}
    uniLabel, uniGUIClasses, uniBasicGrid, uniDBGrid, uniMainMenu, uniGUIBaseClasses, uniPanel, uniButton, UniGUIForm, uniGUIFrame, uniDBNavigator,
  {$else}
    cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
    cxNavigator, cxDBData, Vcl.StdCtrls, cxButtons, Data.Win.ADODB, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
    cxGridDBTableView, cxGrid, dxDateRanges, dxScrollbarAnnotations, dxUIAClasses,
  {$endif}
  Vcl.ExtCtrls, sgClientDataSet, Func, sgClass, sgPrinDecorator, sgDBG2, sgDBG, cxContainer, cxLabel;

type
  TFraGrMv = class;

  TConfTabe = class(TCustomConfTabe)
  private
    FFraGrid: TFraGrMv;
  public
    constructor sgCreate(owner: TFraGrMv);
    property Parent: TFraGrMv read FFraGrid write FFraGrid;
  end;

  TFraGrMv = class(TFraGrid)
    BtnNovo: TsgBtn;
    BtnAlte: TsgBtn;
    BtnExcl: TsgBtn;
    procedure QryGridAfterScroll(DataSet: TDataSet); override;
    procedure QryGridAfterOpen(DataSet: TDataSet); override;
    procedure QryGridAfterClose(DataSet: TDataSet);
    procedure BtnExclClick(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure DbgGridDblClick(Sender: TObject); {$ifdef ERPUNI} override; {$else} {$ENDIF}
    procedure UniFrameReady(Sender: TObject);
  private
    FPSitGrav, FClicEnviRemo: Boolean;
    FFormRelaModal, FFormParentModal: {$ifdef ERPUNI} TUniForm {$else} TForm {$ENDIF};
    FFormParent: {$ifdef ERPUNI} TUniFrame {$else} TForm {$ENDIF};
    FsgTransaction: TsgTransaction;
    FConfTabe, FPai_Tabe: TConfTabe;
    FPrin_D: TsgDecorator;

    procedure SetPSitGrav(const Value: Boolean);
    function GetPSitGrav: Boolean;

    function CriaFormManu: Boolean;
    function GetPrin_D: TsgDecorator;
    procedure SetConfTabe(const Value: TConfTabe);
    procedure SetFormRelaModal(const Value: {$ifdef ERPUNI} TUniForm {$else} TForm {$endif});
    {$ifdef ERPUNI}
      procedure UniFrameDestroy(Sender: TObject);
    {$else}
    {$endif}
    procedure SetPrin_D(const Value: TsgDecorator);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AtuaGridMovi(iPara: Boolean = False);

    property PSitGrav: Boolean read GetPSitGrav write SetPSitGrav;

    property ClicEnviRemo: Boolean read FClicEnviRemo write FClicEnviRemo;

    property FormRelaModal : {$ifdef ERPUNI} TUniForm {$else} TForm {$ENDIF} read FFormRelaModal write SetFormRelaModal;
    property ConfTabe: TConfTabe read fConfTabe write SetConfTabe;
    property Pai_Tabe: TConfTabe read FPai_Tabe write FPai_Tabe;

    property Prin_D: TsgDecorator read GetPrin_D write SetPrin_D;
  published
    property FormParent : {$ifdef ERPUNI} TUniFrame {$else} TForm {$ENDIF} read FFormParent write FFormParent;
    property FormParentModal : {$ifdef ERPUNI} TUniForm {$else} TForm {$ENDIF} read FFormParentModal write FFormParentModal;
    property sgTransaction : TsgTransaction read FsgTransaction write FsgTransaction;
  end;

implementation

{$R *.dfm}


uses Funcoes, DmPoul, PlusUni, DmPlus, sgForm, sgFormModal, sgConsts, dmImag,
  {$ifdef ERPUNI}
    uniGUIApplication,
    {$ifndef LIBUNI}
      DmCall, PlusUniModal,
    {$endif}
  {$else}
  {$endif}
  Dialogs, DBClient;

procedure TFraGrMv.AtuaGridMovi(iPara: Boolean = False);
var
  vAuxi: String;
  //vOpen: Boolean;
begin
  //vOpen := QryGrid.Active;
  if (QryGrid.SQL.Count > 3) then
  begin
    if (QryGrid.ParamCount = 0) and (QryGrid.SQL.Count > 3) then  //Estava no Create, mas nesse momento o PSitGrav não está definido
    begin
      if Trim(QryGrid.SQL.Strings[2]) = '' then
        vAuxi := 'WHERE '
      else
        vAuxi := 'AND ';

      QryGrid.CriaParameter('Codi', ftLargeint);
      QryGrid.SQL.Strings[3] := vAuxi+' ('+ConfTabe.GravTabe+'.'+Pai_Tabe.NomeCodi+' = :Codi)';
    end;

    //Begin e EndUpdate geram erro no ApplyBestFit
    //DbgGrid.BeginUpdate;
    if QryGrid.Params.ParamByName('Codi').Value = Pai_Tabe.CodiGrav then
      QryGrid.sgRefresh(True)
    else
    begin
      QryGrid.Close;
      QryGrid.Params.ParamByName('Codi').Value := Pai_Tabe.CodiGrav;
      QryGrid.Open;
    end;
    {$ifdef ERPUNI}
      // DbgGrid.ReGeraCamp();  //Ficou no AfterOpen, devido do comando QD, não respeitava o tamanho das colunas
    {$else}
      DbgGrid.AtuaCamp(nil);
      if Assigned(DbgGrid.sgView) and (DbgGrid.sgView.ClassType = TcxGridDBTableView) then
      begin
        try
          if TcxGridDBTableView(DbgGrid.sgView).ColumnCount > 1 then
          begin
            TcxGridDBTableView(DbgGrid.sgView).Columns[0].Visible := TcxGridDBTableView(DbgGrid.sgView).Columns[0].DataBinding.Field.Visible;
            TcxGridDBTableView(DbgGrid.sgView).Columns[1].Visible := TcxGridDBTableView(DbgGrid.sgView).Columns[1].DataBinding.Field.Visible;
          end;
        except
        end;
      end;
    {$endif}
    //Desabilitar os dois primeiros campos ficou na sgQuery.FormatFields
    //DbgGrid.EndUpdate;
  end;

//  if (not vOpen) and QryGrid.Active and (not QryGrid.IsEmpty) and Assigned(Prin_D) then
  if QryGrid.Active and (not QryGrid.IsEmpty) and Assigned(Prin_D) then
    Prin_D.DadoMovi.CarregaListaDB(ConfTabe.GravTabe, '*', ConfTabe.GravTabe+'.'+Pai_Tabe.NomeCodi+' = '+IntToStr(Pai_Tabe.CodiGrav))
  else if Assigned(Prin_D) then
    Prin_D.DadoMovi.Limpa;
end;

function TFraGrMv.CriaFormManu(): Boolean;
var
  FrC : {$ifdef ERPUNI} TUniFormClass {$else} TsgFormClass {$endif};
  FClassName: string;
begin
  {$ifdef ERPUNI}
  {$else}
    if Assigned(FormRelaModal) then
      Result := True
    else
  {$endif}
  begin
    Result := False;
    if Pos('TFRMPOHECAM', AnsiUpperCase(Pai_Tabe.FormTabe)) > 0 then
      FClassName := Pai_Tabe.FormTabe + SeStri(GetConfWeb.Modo = cwModoMobile, 'Mobi','') {$ifdef ERPUNI} +'Modal' {$else} {$endif}
    else
      FClassName := ConfTabe.FormTabe + SeStri(GetConfWeb.Modo = cwModoMobile, 'Mobi','') {$ifdef ERPUNI} +'Modal' {$else} {$endif};

    {$ifdef ERPUNI}
      FrC := TUniFormClass(FindClass(FClassName));
      if Assigned(FrC) then
      begin
        SetPTab(Self.ConfTabe.CodiTabe);
        FormRelaModal := FrC.Create(uniGUIApplication.UniApplication);
        FormRelaModal.Name := 'Frm'+IntToStr(Self.ConfTabe.CodiTabe);

        TsgFormModal(FormRelaModal).sgTransaction := Self.sgTransaction;  //antes do HelpContext para não criar na outra tela
        if Assigned(Self.FormParent) then
          TsgFormModal(FormRelaModal).FormRela := Self.FormParent
        else
          TsgFormModal(FormRelaModal).FormRela := Self.FormParentModal;
        TsgFormModal(FormRelaModal).sgIsMovi := True;

        FormRelaModal.HelpContext := Self.ConfTabe.CodiTabe;

        if Assigned(FormParent) then
          FormRelaModal.Parent := FormParent
        else
          FormRelaModal.Parent := FormParentModal;

        FormRelaModal.Top := 0;
        FormRelaModal.Left := 0;
        Result := True;
      end;
    {$ELSE}
      FrC := TsgFormClass(FindClass(FClassName));
      if Assigned(FrC) then
      begin
        SetPTab(Self.ConfTabe.CodiTabe);
        FormRelaModal := FrC.sgCreate(Self.FormParent, Self.ConfTabe, Self.sgTransaction, nil);

        //FormRelaModal.Parent := Self.Parent;  //Setava o Width e Height do Parent

        if sgCopy(FClassName,01,11) = 'TFRMPOHECAM' then
          FormRelaModal.Name := Copy(FClassName,02,11)+'_'+IntToStr(Self.ConfTabe.CodiTabe);
        //FormRelaModal.Name := 'Frm'+IntToStr(Self.ConfTabe.CodiTabe);
        //TsgForm(FormRelaModal).sgTransaction := Self.sgTransaction;  //antes do HelpContext para não criar na outra tela
        //TsgForm(FormRelaModal).FormRela := Self.FormParent;
        TsgForm(FormRelaModal).sgIsMovi := True;
        //TsgForm(FormRelaModal).Prin_D.Pai_Prin_D  := Self.Prin_D.Pai_Prin_D;

        FormRelaModal.FormStyle := fsNormal;
        FormRelaModal.Visible := False;
        FormRelaModal.HelpContext := Self.ConfTabe.CodiTabe;
        Result := True;
      end;
    {$ENDIF}
    if Assigned(Prin_D) then
      Prin_D.sgForm := FormRelaModal;
  end;
end;


//*******************************************************************************
//*******************************************************************************

procedure TFraGrMv.BtnExclClick(Sender: TObject);
var
  vTabe: TsgNewOldTable;
begin
  try
    if Assigned(Sender) and (Sender is TsgBtn) then TsgBtn(Sender).Enabled := False;
    Self.ConfTabe.Operacao := opExcl;
    if Assigned(FormParent) then
    begin
      TsgForm(FormParent).ConfTabe.ConfMovi.Assign(Self.ConfTabe);

      ExibMensHint(IntToStr(ConfTabe.CodiTabe)+': AnteIAE_Movi e AnteExcl');
      if PlusUni.VeriEnviConf(TsgForm(FormParent), PlusUni.CampPers_TratExec(TsgForm(FormParent), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'AnteIAE_Movi_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp')+sLineBreak+
                                                                                                  DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'AnteExcl_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), '')) then
      begin
        if Assigned(Prin_D) then
        begin
          vTabe := Prin_D.DadoMovi.BuscaPorCodi(sgStrToInt(QryGrid.FieldByName(ConfTabe.NomeCodi).AsString), QryGrid.FieldByName(ConfTabe.NomeSgCh).AsString);
          if Assigned(vTabe) then
          begin
            Prin_D.TabNewOld.Assign(vTabe);
            Prin_D.Remo_Tab();
          end
          else
            Prin_D.Exclui_Cod(sgStrToInt(QryGrid.FieldByName(ConfTabe.NomeCodi).AsString));
  //          sgMessageDlg('Objeto Tabela não encontrado na Lista de Exclusão (ListaMovi[NewOldTable])!', mtInformation, [mbOK], 0);
        end
        else
          DmPlus.ExecSQL_('DELETE FROM '+ConfTabe.GravTabe+' WHERE ('+QryGrid.Fields[0].FieldName+' = '+RetoZero(QryGrid.Fields[0].AsString)+')', Self.sgTransaction);
        AtuaGridMovi;

        ExibMensHint(IntToStr(ConfTabe.CodiTabe)+': DepoIAE_Movi e DepoExcl');
        PlusUni.VeriEnviConf(TsgForm(FormParent), PlusUni.CampPers_TratExec(TsgForm(FormParent), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'DepoIAE_Movi_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp')+sLineBreak+
                                                                                                 DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'DepoExcl_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), ''));
        ClicEnviRemo := True;
      end;
    {$if defined(ERPUNI) and not defined(LIBUNI)}
    end
    else
    begin
      ExibMensHint(IntToStr(ConfTabe.CodiTabe)+': AnteIAE_Movi e AnteExcl');
      if PlusUniModal.VeriEnviConf(TsgFormModal(FormParent), PlusUniModal.CampPers_TratExec(TsgFormModal(FormParent), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'AnteIAE_Movi_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp')+sLineBreak+
                                                                                                                      DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'AnteExcl_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), '')) then
      begin
        if Assigned(Prin_D) then
        begin
          vTabe := Prin_D.DadoMovi.BuscaPorCodi(sgStrToInt(QryGrid.FieldByName(ConfTabe.NomeCodi).AsString), QryGrid.FieldByName(ConfTabe.NomeSgCh).AsString);
          if Assigned(vTabe) then
          begin
            Prin_D.TabNewOld.Assign(vTabe);
            Prin_D.Remo_Tab();
          end
          else
            Prin_D.Exclui_Cod(sgStrToInt(QryGrid.FieldByName(ConfTabe.NomeCodi).AsString));
        end
        else
          DmPlus.ExecSQL_('DELETE FROM '+ConfTabe.GravTabe+' WHERE ('+QryGrid.Fields[0].FieldName+' = '+RetoZero(QryGrid.Fields[0].AsString)+')', Self.sgTransaction);
        AtuaGridMovi;

        ExibMensHint(IntToStr(ConfTabe.CodiTabe)+': DepoIAE_Movi e DepoExcl');
        PlusUniModal.VeriEnviConf(TsgFormModal(FormParentModal), PlusUniModal.CampPers_TratExec(TsgFormModal(FormParent), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'DepoIAE_Movi_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp')+sLineBreak+
                                                                                                                          DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'DepoExcl_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), ''));
        ClicEnviRemo := True;
      end;
    {$ELSE}
    {$ENDIF}
    end;
  finally
    if Assigned(Sender) and (Sender is TsgBtn) then TsgBtn(Sender).Enabled := True;
  end;
end;

procedure TFraGrMv.BtnNovoClick(Sender: TObject);
var
  vInst: String;
  PTabAnte: Integer;
begin
  vInst := SeStri(TsgBtn(Sender).Tag = 0,'Incl','Alte');
  PTabAnte := GetPTab;
  try
    if Assigned(Sender) and (Sender is TsgBtn) then TsgBtn(Sender).Enabled := False;

    ExibMensHint(IntToStr(ConfTabe.CodiTabe)+': AnteIAE_Movi e Ante'+vInst);
    if PlusUni.CampPersExecDireStri(TsgForm(FormParent), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'AnteIAE_Movi_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp')+sLineBreak+
                                                         DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'Ante'+vInst+'_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), '') then
    begin
      if CriaFormManu() then
      begin
        if Assigned(FormParent) then
          TsgForm(FormParent).AcaoPnls := False
        else
          TsgFormModal(FormParentModal).AcaoPnls := False;

        with TSgFormModal(FormRelaModal) do
        begin
          ConfTabe.Assign(Self.ConfTabe);
          Pai_Tabe.Assign(Self.Pai_Tabe);
          ConfTabe.SituGrav := TsgBtn(Sender).Tag = 0;
          if ConfTabe.SituGrav then
          begin
            ConfTabe.CodiGrav := 0;
            vInst := 'Incl';
          end
          else
          begin
            ConfTabe.CodiGrav := QryGrid.Fields[0].AsInteger;
            vInst := 'Alte';
          end;
          //ConfTabe.FechaConfirma := True;
          {$ifdef ERPUNI}
          {$ELSE}
            if ConfTabe.NomeTabe = '' then
              Caption := SeStri(ConfTabe.SituGrav, sInclusao+' de ', sAlteracao+' de ')+SubsPalaTudo(DtmPoul.Tabelas_Busc('Gui1Tabe', '(CodiTabe = '+IntToStr(ConfTabe.CodiTabe)+')'),'&','')
            else
              Caption := SeStri(ConfTabe.SituGrav, sInclusao+' de ', sAlteracao+' de ')+SubsPalaTudo(ConfTabe.NomeTabe,'&','');
          {$ENDIF}
          {$if Defined(SAGLIB) or Defined(LIBUNI)}
          {$else}
            //Estava deixando o Prin_D nil => ????
            //FraGrMvRela := Self;
          {$ENDIF}
          if Assigned(Self.Prin_D) then
          begin
            TSgFormModal(FormRelaModal).Prin_D := Self.Prin_D;
            if Assigned(Self.Prin_D.Pai_Prin_D) then  //Pode ter a classe do filho e não ter a do Pai
            begin
              TSgFormModal(FormRelaModal).Prin_D.Pai_Prin_D := Self.Prin_D.Pai_Prin_D;
              if Self.Prin_D.Pai_Prin_D.MetoSave = msDts then
                Self.Prin_D.Pai_Prin_D.Dts_To_New;
            end;
          end;
        end;

        if Assigned(FormParent) then
        begin
          TsgForm(FormParent).ConfTabe.ConfMovi.Assign(TSgFormModal(FormRelaModal).ConfTabe);
          GetConfWeb.MemVal1.Text := PlusUni.SubsCampPers(TsgForm(FormParent), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'ShowPai_Filh_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'));
        end
        else
        begin
          {$ifdef ERPUNI}
            TsgFormModal(FormParentModal).ConfTabe.ConfMovi.Assign(TSgFormModal(FormRelaModal).ConfTabe);
            GetConfWeb.MemVal1.Text := PlusUniModal.SubsCampPers(TsgFormModal(FormParentModal), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'ShowPai_Filh_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'));
          {$ELSE}
          {$ENDIF}
        end;

        if Assigned(FormRelaModal) then
        begin
          {$ifdef ERPUNI}
          if GetConfWeb.Modo = cwModoMobile then
            FormRelaModal.WindowState := wsMaximized;

          if ((FormRelaModal.ShowModal = mrOk) or TSgFormModal(FormRelaModal).ConfTabe.ClicConf) then
            begin
              ExibMensHint(IntToStr(ConfTabe.CodiTabe)+': DepoIAE_Movi e Depo'+vInst);
              if Assigned(FormParent) then
                PlusUni.CampPersExecDireStri(TsgForm(FormParent), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'DepoIAE_Movi_'+ IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp')+sLineBreak+
                                                                  DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'Depo'+vInst+'_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), '')
              else
              begin
                {$ifdef ERPUNI}
                  PlusUniModal.CampPersExecDireStri(TsgFormModal(FormParentModal), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'DepoIAE_Movi_'+ IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp')+sLineBreak+
                                                                                   DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'Depo'+vInst+'_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), '');
                {$ELSE}
                {$ENDIF}
              end;
            end;
            if Assigned(FPrin_D) then
              FPrin_D.DataSet := TClientDataSet(QryGrid);
          {$else}
            //FormRelaModal.Show;
            //FormRelaModal.onShow(nil);
            FormRelaModal.ShowModal;

            ExibMensHint(IntToStr(ConfTabe.CodiTabe)+': DepoIAE_Movi e Depo'+vInst);
            if Assigned(FormParent) then
              PlusUni.CampPersExecDireStri(TsgForm(FormParent), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'DepoIAE_Movi_'+ IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp')+sLineBreak+
                                                                DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'Depo'+vInst+'_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), '')
          {$endif}
        end;
      end;
    end;
  finally
    SetPTab(PTabAnte);
    if Assigned(Sender) and (Sender is TsgBtn) then TsgBtn(Sender).Enabled := True;
  end;
end;

constructor TFraGrMv.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fConfTabe := TConfTabe.sgCreate(Self);
  fPai_Tabe := TConfTabe.sgCreate(Self);
  {$ifdef ERPUNI}
    OnDestroy := UniFrameDestroy;
    OnReady   := UniFrameReady;
    DbgGrid.WebOptions.Paged := False;
  {$else}
    DbgGridView.OptionsView.GroupByBox := False;
  {$endif}
  Componentes_Formata(Self);
end;

{$ifdef ERPUNI}
  procedure TFraGrMv.UniFrameDestroy(Sender: TObject);
  begin
    inherited;
  end;
{$else}
{$endif}

procedure TFraGrMv.UniFrameReady(Sender: TObject);
var
  i: integer;
begin
  inherited;
  if GetConfWeb.Modo = cwModoMobile then
  begin
    if PnlTopo.Tag <> 10 then
    begin
      BtnNovo.Caption := '';
      BtnAlte.Caption := '';
      BtnExcl.Caption := '';

      PnlTopo.Height := 31;
      BtnNovo.Left   := 05;
      BtnNovo.Width  := 60;
      BtnNovo.Top    := 03;
      BtnNovo.Height := 26;
      for I := 0 to ComponentCount-1 do
      begin
        if (Components[i].ClassType = TsgBtn) and (Components[I].GetParentComponent = PnlTopo) then
        begin
          TsgBtn(Components[i]).Width  := BtnNovo.Width;
          TsgBtn(Components[i]).Height := BtnNovo.Height;
          TsgBtn(Components[i]).Top    := BtnNovo.Top;
        end;
      end;
      BtnAlte.Left   := BtnNovo.Left + BtnNovo.Width + 05;
      BtnExcl.Left   := BtnAlte.Left + BtnAlte.Width + 05;
    end;
  end;
end;

procedure TFraGrMv.DbgGridDblClick(Sender: TObject);
begin
  BtnNovoClick(BtnAlte);
end;

destructor TFraGrMv.Destroy;
begin
  FreeAndNil(fConfTabe);
  FreeAndNil(fPai_Tabe);
  inherited;
end;

function TFraGrMv.GetPrin_D: TsgDecorator;
var
  sgClas: TPersistentClass;
begin
  if (not Assigned(FPrin_D)) and (ConfTabe.GravTabe <> '') then
  begin
    try
      sgClas := sgClass.GetsgClass(ConfTabe.GravTabe+'_D');
      if Assigned(sgClas) then
        FPrin_D := TsgDecoratorClass(sgClas).Create;

      if Assigned(FPrin_D) then
      begin
        FPrin_D.conn    := Self.sgTransaction;
        //FPrin_D.sgForm  := Self;
        FPrin_D.ConfTabe:= Self.ConfTabe;
        //FPrin_D.MetoSave := Recebe do Pai;
        //FPrin_D.UsaTrans := Recebe do Pai;
        FPrin_D.DataSet := TClientDataSet(QryGrid);

        DbgGrid.Prin_D := FPrin_D;
      end;
    except
      raise;
    end;
  end;
  Result := FPrin_D;
end;

function TFraGrMv.GetPSitGrav: Boolean;
begin
  Result := ConfTabe.SituGrav;
end;

procedure TFraGrMv.QryGridAfterClose(DataSet: TDataSet);
begin
  inherited;
  BtnAlte.Enabled := False;
  BtnExcl.Enabled := False;
end;

procedure TFraGrMv.QryGridAfterOpen(DataSet: TDataSet);
begin
  inherited;

  {$ifdef ERPUNI}
    DbgGrid.ReGeraCamp();  //Tirado do AtuaGrid q quando faz o comando QD não respeitava o tamanho das colunas
  {$else}
    if QryGrid.Fields.Count >= 2 then
    begin
      QryGrid.ExibChav := False;
      QryGrid.Fields[0].Visible := False;
      QryGrid.Fields[1].Visible := False;

      if QryGrid.Fields.Count = 3 then
        DbgGridView.Columns[0].Width := DbgGrid.Width - 35;

    end;
    //DbgGrid.ReGeraCamp();  //Deixado no atuagrid por causa do ApplyBestFit;
  {$endif}

  ExibMensHint('Exec AtuaGrid Mov '+IntToStr(ConfTabe.CodiTabe));
  if Assigned(FormParent) then
    PlusUni.CampPersExecDireStri(TsgForm(FormParent), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'AtuaGrid_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), '')
  else
  begin
    {$ifdef ERPUNI}
      PlusUniModal.CampPersExecDireStri(TsgFormModal(FormParentModal), DtmPoul.Campos_Busc(Pai_Tabe.CodiTabe, 'AtuaGrid_'+IntToStr(ConfTabe.CodiTabe), '', 'ExprCamp'), '');
    {$ELSE}
    {$ENDIF}
  end;
end;

procedure TFraGrMv.QryGridAfterScroll(DataSet: TDataSet);
begin
  inherited;
  BtnAlte.Enabled := QryGrid.RecordCount > 0;
  BtnExcl.Enabled := QryGrid.RecordCount > 0;
end;

procedure TFraGrMv.SetConfTabe(const Value: TConfTabe);
begin
  if FConfTabe <> Value then
  begin
    FConfTabe := Value;
    DbgGrid.ConfTabe := ConfTabe;
  end;
end;

procedure TFraGrMv.SetFormRelaModal(const Value: {$ifdef ERPUNI} TUniForm {$else} TForm {$endif});
begin
  if FFormRelaModal <> Value then
  begin
    FFormRelaModal := Value;
    DbgGrid.sgForm := FFormRelaModal;
  end;
end;

procedure TFraGrMv.SetPrin_D(const Value: TsgDecorator);
begin
  FPrin_D := Value;
  DbgGrid.Prin_D := Value;
end;

procedure TFraGrMv.SetPSitGrav(const Value: Boolean);
begin
  {$ifdef FD}
    //Sempre que reinicia o formulário, passa por aqui
    if FPSitGrav <> Value then
      QryGrid.Params.Clear;
  {$endif}

  FPSitGrav := Value;

  ConfTabe.SituGrav := Value;

  ClicEnviRemo := False;
end;

{ TConfTabe }

constructor TConfTabe.sgCreate(owner: TFraGrMv);
begin
  inherited Create;
  Parent := owner;
end;

end.



