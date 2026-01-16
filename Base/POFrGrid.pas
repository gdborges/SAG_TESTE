unit POFrGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, sgDBG2, sgDBG, Data.Win.ADODB, sgFrame, dxUIAClasses, dxDateRanges, dxScrollbarAnnotations,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Vcl.Menus, sgPop, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  sgQuery, Vcl.StdCtrls, sgLbl, Vcl.ExtCtrls, sgPnl, cxContainer, cxLabel;

type
  TFraGrid = class(TsgFrame)
    DtsGrid: TDataSource;
    QryGrid: TsgQuery;
    PnlGrid: TsgPnl;
    DbgGrid: TsgDBG;
    DbgGridView: TcxGridDBTableView;
    DbgGridLeve: TcxGridLevel;
    PopGrid: TsgPop;
    PopExpoExce: TsgMenuItem;
    PopExpoInse: TsgMenuItem;
    PopExpoUpda: TsgMenuItem;
    N8: TsgMenuItem;
    PopFiltQuer: TsgMenuItem;
    N5: TsgMenuItem;
    PopExpoXML: TsgMenuItem;
    PopImpoXML: TsgMenuItem;
    PnlTopo: TsgPnl;
    LblTemp: TsgLbl;
    LblRegi: TsgLbl;
    PopGridAjudSepa: TsgMenuItem;
    PopGridAjud: TsgMenuItem;
    procedure PopExpoXMLClick(Sender: TObject);
    procedure PopFiltQuerClick(Sender: TObject);
    procedure PopImpoXMLClick(Sender: TObject);
    procedure PopExpoExceClick(Sender: TObject);
    procedure PopExpoInseClick(Sender: TObject);
    procedure QryGridAfterScroll(DataSet: TDataSet); virtual;
    procedure QryGridAfterOpen(DataSet: TDataSet); virtual;
    procedure QryGridBeforeOpen(DataSet: TDataSet); virtual;
    procedure PopGridAjudClick(Sender: TObject);
  private
    vQuer: TADOQuery;
    FsgSQL: String;
    procedure SetsgSQL(const Value: String);
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    procedure TradDataSet(DataSet: TDataSet); virtual;
    property sgSQL: String read FsgSQL write SetsgSQL;
  end;

implementation

{$R *.dfm}

uses Func, Funcoes, COMobj, Clipbrd
  {$ifndef SAGLIB}
    , vTabe, PlusUni, TradConsts
  {$endif};

constructor TFraGrid.Create(AOwner: TComponent);
var
  i, vCodiTabe: Integer;
  vForm: TComponent;
begin
  inherited;
  vQuer := TADOQuery.Create(Self);
  {$if not Defined(SAGLIB) and not Defined(LIBUNI)}
    if GetCodiIdio() <> 0 then
    begin
      vForm := GetOwnerWin(AOwner, TForm);
      if Assigned(vForm) then
      begin
        vCodiTabe := TForm(vForm).HelpContext;
        if vCodiTabe <> 0 then
        begin
          ExibMensHint('Traduzindo...(C)');
          for I  := 0 to ComponentCount - 1 do
          begin
            If (Components[i].ClassType <> TcxGridDBTableView) then
              Trad_Componente(Components[i], vCodiTabe, Self.Name);
          end;
          ExibMensHint('');
        end;
      end;
    end;
  {$endif}
end;

destructor TFraGrid.Destroy;
begin
  QryGrid.Close;
  vQuer.Close;
  inherited;
end;

procedure TFraGrid.PopExpoExceClick(Sender: TObject);
var
  Exce :variant;
  i, Linh: Integer;
  Auxi: string;
begin
  try
    Exce := CreateOleObject('\Excel.application\');
    if not Exce.Application.Visible then
      Exce.Application.Visible := True;

    Exce.WorkBooks.Add;

    //Cabeçalho
    for i := 1 to QryGrid.Fields.Count - 1 do
      Exce.Cells[1, i] := QryGrid.Fields[i].FieldName;

    QryGrid.First;
    Linh := 2;
    while not(QryGrid.Eof) do
    begin
      for i := 1 to QryGrid.Fields.Count - 1 do
      begin
        if TipoDadoCara(QryGrid.Fields[i]) IN ['N','I'] then
          Exce.Cells[Linh, i] := FormNumeSQL(QryGrid.Fields[i].AsFloat)
        else if TipoDadoCara(QryGrid.Fields[i]) IN ['D'] then
          Exce.Cells[Linh, i] := FormatDateTime('MM/DD/YYYY',QryGrid.Fields[i].AsDateTime)
        else
        begin
          Auxi := QryGrid.Fields[i].Text;
          if QryGrid.Fields[i].Tag = 20 then
            Exce.Cells[Linh, i] := FormPont(Auxi)
          else
            Exce.Cells[Linh, i] := Auxi;
        end;
      end;
      Inc(Linh);
      QryGrid.Next;
    end;
  except
    on E: Exception do
      sgMessageDlg('Erro ao exportar!'+#13+E.Message,mtError,[mbOK],0);
  end;
end;

procedure TFraGrid.PopExpoInseClick(Sender: TObject);
var
  i, vTag : Integer;
  Mark : TBookMark;
  Linh: Integer;
  vTabe, vCodi: String;
begin
  if not QryGrid.Active then
    sgMessageDlg('SQL não executado. Query deve estar aberta!', mtInformation, [mbOK], 0)
  else
  begin
    for I := 0 to QryGrid.SQL.Count-1 do
    begin
      if AnsiUpperCase(Copy(Trim(QryGrid.SQL.Strings[i]),01,04)) = 'FROM' then
      begin
        vTabe := Trim(Copy(Trim(QryGrid.SQL.Strings[i]),05,100));
        if Pos(' ',vTabe) > 0 then
          vTabe := Trim(Copy(vTabe,01,Pos(' ',vTabe)));
        Break;
      end;
    end;
    if InputQuery('Tabela','Tabela',vTabe) then
    begin
      vCodi := 'Codi'+Copy(vTabe,05,100);
      if InputQuery('Campo Código','Campo Código',vCodi) then
      begin
        vTag := TsgMenuItem(Sender).Tag;
        Mark := QryGrid.GetBookmark;
        try
          Linh := DbgGridView.Controller.SelectedRowCount;
          if Linh <= 1 then
          begin
            Screen.Cursor := crHourGlass;
            try
              if vTag = 0 then
                InseGeraScri(vTabe, vCodi +' = '+IntToStr(QryGrid.FieldByName(vCodi).AsInteger))
              else
                UpdaGeraScri(vTabe, vCodi +' = '+IntToStr(QryGrid.FieldByName(vCodi).AsInteger));
            finally
              Screen.Cursor := crDefault;
            end;
          end
          else
          begin
            try
              for i := 0 to (Linh - 1) do
              begin
                DbgGridView.DataController.ChangeFocusedRowIndex(DbgGridView.Controller.SelectedRows[i].Index);
                if vTag = 0 then
                  InseGeraScri(vTabe, vCodi +' = '+IntToStr(QryGrid.FieldByName(vCodi).AsInteger))
                else
                  UpdaGeraScri(vTabe, vCodi +' = '+IntToStr(QryGrid.FieldByName(vCodi).AsInteger));
              end;
            finally
            end;
          end;
          CopyToClipBoard(GetConfWeb.MemVal1.Text);
          GetConfWeb.MemVal1.Clear;
        finally
          try
            if QryGrid.BookmarkValid(Mark) then
              QryGrid.GotoBookmark(Mark);
            QryGrid.FreeBookmark(Mark);
          except
            QryGrid.FreeBookmark(Mark);
          end;
        end;
        sgMessageDlg('Dados gerados para a Área de Transferência!',mtInformation,[mbOK],0);
      end;
    end;
  end;
end;

procedure TFraGrid.PopExpoXMLClick(Sender: TObject);
begin
  with TSaveDialog.Create(Application) do
  try
    Title     := 'Salvar XML/ADT';
    Filter    := 'Arquivos ADT (*.ADT)|*.ADT|Arquivos XML (*.XML)|*.xml|Todos os Arquivos (*.*)|*.*';
    DefaultExt:= 'ADT';
    if Execute then
      QryGrid.SaveToFile(FileName);
  finally
    Free;
  end;
end;

procedure TFraGrid.PopFiltQuerClick(Sender: TObject);
var
  Wher: String;
begin
  Wher := QryGrid.Filter;
  if InputQuery('Filtro','Filtro',Wher) then
  begin
    QryGrid.Filtered := False;
    QryGrid.Filter   := Wher;
    if Wher <> '' then
      QryGrid.Filtered := True;
  end;
end;

procedure TFraGrid.PopGridAjudClick(Sender: TObject);
begin
  msgOk(TsgPop(Sender).Tag.ToString);
end;

procedure TFraGrid.PopImpoXMLClick(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  try
    Title     := 'Abrir XML/ADT';
    Filter    := 'Arquivos ADT (*.ADT)|*.ADT|Arquivos XML (*.XML)|*.xml|Todos os Arquivos (*.*)|*.*';
    DefaultExt:= 'ADT';
    if Execute then
    begin
      DbgGrid.GeraCamp := False;
      vQuer.LoadFromFile(FileName);
      DtsGrid.DataSet := vQuer;
      DbgGrid.GeraCamp := True;
    end;
  finally
    Free;
  end;
end;

procedure TFraGrid.QryGridAfterOpen(DataSet: TDataSet);
begin
  inherited;
  begin
  end;
end;

procedure TFraGrid.QryGridAfterScroll(DataSet: TDataSet);
begin
  if QryGrid.RecNo < 0 then
    LblRegi.Caption := ''
  else
    LblRegi.Caption := FormInteBras(QryGrid.RecNo) + ' de ' + FormInteBras(QryGrid.RecordCount);
  LblTemp.Caption := FormatDateTime('nn:ss:zzz', QryGrid.HoraTota);
end;

procedure TFraGrid.TradDataSet(DataSet: TDataSet);
var
  vCodiTabe: Integer;
  vForm: TComponent;
begin
  {$if not Defined(SAGLIB) and not Defined(LIBUNI)}
    if (GetCodiIdio() <> 0) and (DbgGridView.Tag <> 0) then
    begin
      vForm := GetPareWin(Self, TForm);
      if Assigned(vForm) then
      begin
        vCodiTabe := TForm(vForm).HelpContext;
        if vCodiTabe <> 0 then
        begin
          ExibMensHint('Traduzindo...(D)');
          Trad_Componente(DbgGridView, vCodiTabe, Self.Name);
          DbgGridView.Tag := 0;  //Marca como já traduzido
          ExibMensHint('');
        end;
      end;
    end;
  {$endif}
end;

procedure TFraGrid.QryGridBeforeOpen(DataSet: TDataSet);
begin
  DtsGrid.DataSet := QryGrid;
  inherited;
  TradDataSet(DataSet);
end;

procedure TFraGrid.SetsgSQL(const Value: String);
begin
  if FsgSQL <> Value then
  begin
    FsgSQL := Value;
    QryGrid.TamaCamp := 20;
    QryGrid.SQL.Text := FsgSQL;
    DbgGrid.Edita := True; //(isAdmiSAG() or isAdmiClie());
  end;
end;

end.
