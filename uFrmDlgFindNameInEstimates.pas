unit uFrmDlgFindNameInEstimates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, System.Types,
  Vcl.Buttons, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, EhLibVCL,
  GridsEh, DBAxisGridsEh, DBGridEh, Data.Win.ADODB, DataDriverEh,
  ADODataDriverEh, Vcl.DBCtrls, DateUtils, uFrmBasicMdi;

type
  TFrmDlgFindNameInEstimates = class(TFrmBasicMdi)
    PTop: TPanel;
    PClient: TPanel;
    ChbInClosedOrders: TCheckBox;
    ChbLike: TCheckBox;
    PgcGrid: TPageControl;
    TsStdItems: TTabSheet;
    DBGridEh1: TDBGridEh;
    E_PPComment: TDBEditEh;
    TsOrders: TTabSheet;
    DBGridEh2: TDBGridEh;
    DBEditEh1: TDBEditEh;
    EName: TDBEditEh;
    PButtons: TPanel;
    BtGo: TSpeedButton;
    ImgInfoMAIN: TImage;
  private
    { Private declarations }
    function  Prepare(): Boolean; override;
  public
    { Public declarations }
  end;

var
  FrmDlgFindNameInEstimates: TFrmDlgFindNameInEstimates;

implementation

uses
  uSettings,
  uForms,
  uDBOra,
  uString,
  uData,
  uMessages,
  uWindows,
  uOrders
  ;


{$R *.dfm}

function TFrmDlgFindNameInEstimates.Prepare(): Boolean;
begin
  FMode:= fEdit;
  FOpt.DlgPanelStyle:= dpsNone;
  FOpt.StatusBarMode:= stbmNone;
  Caption:='Поиск сметной позиции';
  Cth.MakePanelsFlat(PMDIClient, []);
  FWHCorrected:=Cth.AlignControls(PTop, [PButtons], True);
  FWHCorrected.Y:= FWHCorrected.Y + 300;
  Cth.SetSpeedButton(BtGo, mybtGo, True);
  FOpt.InfoArray:=[['Тестовая форма']];
  FWHBounds.Y := 400;

  FWHBounds.X := 400;
  FWHBounds.Y2 := -1;
  Result:= True;
end;


end.
