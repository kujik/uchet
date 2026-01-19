unit uFrmXDedtMemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls,
  DBCtrlsEh, Vcl.ExtCtrls,
  uFrmBasicMdi, uData, Vcl.Mask
  ;

type
  TFrmXDedtMemo = class(TFrmBasicMdi)
    pnlCaption: TPanel;
    lblCaption: TLabel;
    memMain: TDBMemoEh;
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
  PrepareCreatedForm(AOwner, Self.Name + '_' + AFormDoc, '~' + AFormCaption, fEdit, null, [], [myfoModal, myfoDialog, myfoDialogButtonsB, myfoSizeable]);
  memMain.Text := Text;
  lblCaption.Caption := ATitle;
  Result := ShowModal = mrOk;
  if not Result then
    Exit;
  Text := memMain.Text;
end;

end.
