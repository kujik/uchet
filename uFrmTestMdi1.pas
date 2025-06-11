unit uFrmTestMdi1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, V_MDI, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, uSettings, uString, PrnDbgEh, DBCtrlsEh, Types, uData, uMessages, uForms, uDBOra, uFrmBasicMdi,
  uFrDBGridEh, Vcl.Mask
  ;

type
  TFrmTestMdi1 = class(TFrmBasicMdi)
    e_1: TDBEditEh;
    l1: TLabel;
    bt_44: TBitBtn;
    l2: TLabel;
    bv3: TBevel;
    e4: TDBEditEh;
    chb4: TCheckBox;
    DBEditEh1: TDBEditEh;
    DBEditEh2: TDBEditEh;
    DBMemoEh1: TDBMemoEh;
    Bevel1: TBevel;
    DBEditEh3: TDBEditEh;
  private
    { Private declarations }
    function  Prepare(): Boolean; override;
  public
    { Public declarations }
  end;

var
  FrmTestMdi1: TFrmTestMdi1;

implementation

{$R *.dfm}

function TFrmTestMdi1.Prepare(): Boolean;
begin
result := True;

  //Mode:= fEdit;
  FOpt.DlgPanelStyle:= dpsBottomRight;
  FOpt.UseChbNoClose:=True;
  //Opt.DlgButtonsR:= [[btnApply, True, 'Сохранить'],[btnCopy],[btnEdit],[btnView]];
  FOpt.StatusBarMode:= stbmNone;
  FOpt.InfoArray:=[['Тестовая форма', True]];
  //WHCorrected:=Cth.AlignControls(PMDIClient, [], True);
  FOpt.AutoAlignControls:= True;
  //FWHBounds.Y:=Height;
  //FWHBounds.Y2:=-1;
  Caption:= 'Тестовая форма'; //~
//ChbDlgNoClose.Visible:=False;
  Result:= True;
end;


end.
