unit POFrCaMv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs
  {$ifdef ERPUNI}
    , uniGUIFrame, uniGUIBaseClasses, uniGUIClasses, uniPanel
  {$ELSE}
    , cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter,
    cxData, cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
    cxGridCustomTableView, cxGridTableView,  cxGridDBTableView, cxGrid, RxPlacemnt
  {$endif}
  , sgDBG2, sgDBG, Data.Win.ADODB, sgQuery, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, sgPop, sgLbl,
  sgPnl, sgFrame, POFrGrid, POFrGrMv;

type
  {$IFDEF ERPUNI}
    TFraCaMv = class(TUniFrame)
  {$ELSE}
    TFraCaMv = class(TsgFrame)
  {$ENDIF}
    PnlMovi: TsgPnl;
    FraMovi: TFraGrMv;
    PnlResu: TsgPnl;
    procedure FraMoviBtnExclClick(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure FraMoviPnlGridResize(Sender: TObject);
    procedure FraMoviDbgGridDblClick(Sender: TObject);
  private
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses Func;

constructor TFraCaMv.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TFraCaMv.Destroy;
begin
  inherited;
end;

procedure TFraCaMv.BtnNovoClick(Sender: TObject);
begin
  FraMovi.BtnNovoClick(Sender);
end;

procedure TFraCaMv.FraMoviBtnExclClick(Sender: TObject);
begin
  FraMovi.BtnExclClick(Sender);
end;

procedure TFraCaMv.FraMoviDbgGridDblClick(Sender: TObject);
begin
  inherited;
  FraMovi.DbgGridDblClick(Sender);
end;

procedure TFraCaMv.FraMoviPnlGridResize(Sender: TObject);
begin
  if PnlResu.Visible then
    FraMovi.DbgGrid.Margins.Bottom := 0
  else
    FraMovi.DbgGrid.Margins.Bottom := 10;
end;

end.
