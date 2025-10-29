unit uFrmODedtAccount;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog, uData
  ;

type
  TFrmODedtAccount = class(TFrmBasicDbDialog)
  private
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    function  Save: Boolean; override;
  public
  end;

var
  FrmODedtAccount: TFrmODedtAccount;

implementation

uses
  uForms,
  uDBOra,
  uString,
  uMessages,
  uFields,
  uTasks
;


{$R *.dfm}

function TFrmODedtAccount.Prepare: Boolean;
begin
  Result := False;
  //проверим блокировку, выйдем если нельзя взять (при попытке редактирования уйдет в просмотр, при удалении - выход)
//  if FormDbLock = fNone then
  //  Exit;

  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;
 // FOpt.AutoAlignControls := True;

  Cth.MakePanelsFlat(pnlFrmClient, []);
  F.PrepareDefineFieldsAdd;
  if Table = '' then
    Table := View;
  if Mode <> fAdd then
    if not Load then
      Exit;
  //загрузим комбобоксы и сделаем другие кастомные действия
//  if not LoadComboBoxes then
//    Exit;
  F.SetPropsControls;
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  Result := True;
end;

function TFrmODedtAccount.LoadComboBoxes: Boolean;
begin

end;

procedure TFrmODedtAccount.ControlOnExit(Sender: TObject);
begin

end;

procedure TFrmODedtAccount.ControlOnChange(Sender: TObject);
begin

end;

function TFrmODedtAccount.Save: Boolean;
begin

end;



end.
