unit uFrmXDedtMemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls, Vcl.Mask,
  DBCtrlsEh, Vcl.ExtCtrls,
  uFrmBasicMdi, uData
  ;

type
  TFrmXDedtMemo = class(TFrmBasicMdi)
    PCaption: TPanel;
    LbCaption: TLabel;
    MMain: TDBMemoEh;
  private
  public
    function ShowDialog(AOwner: TObject; AFormDoc, AFormCaption, ATitle: string; var Text: string): Boolean;
  end;

var
  FrmXDedtMemo: TFrmXDedtMemo;

implementation

{$R *.dfm}

function TFrmXDedtMemo.ShowDialog(AOwner: TObject; AFormDoc, AFormCaption, ATitle: string; var Text: string): Boolean;
begin
  PrepareCreatedForm(AOwner, Self.Name + '_' + AFormDoc, '~' + AFormCaption, fEdit, null, [myfoModal, myfoDialog, myfoDialogButtonsB, myfoSizeable]);
  MMain.Text := Text;
  LbCaption.Caption := ATitle;
  Result := ShowModal = mrOk;
  if not Result then
    Exit;
  Text := MMain.Text;
end;

end.
