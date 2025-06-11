unit uFrmADedtItmCopyRigths;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask,
  DBCtrlsEh, Vcl.ExtCtrls,
  uData, uForms, uMessages, uFrmBasicMdi, uDBOra
  ;

type
  TFrmADedtItmCopyRigths = class(TFrmBasicMdi)
    CbSrc: TDBComboBoxEh;
    CbDst: TDBComboBoxEh;
  private
    function  Save: Boolean; override;
  public
    procedure ShowDialog;
  end;

var
  FrmADedtItmCopyRigths: TFrmADedtItmCopyRigths;

implementation

{$R *.dfm}

function TFrmADedtItmCopyRigths.Save: Boolean;
begin
  if (CbSrc.Text = '') or (CbDst.Text = '') or (CbSrc.Text = CbDst.Text) then
    Exit;
  if MyQuestionMessage('Установить права доступа пользователя'#13#10 + CbDst.Text + #13#10'такими же, как у'#13#10 + CbSrc.Text + #13#10'?') <> mrYes then
    Exit;
  Result := True;
  exit;
  Q.QBeginTrans(True);
  Q.QExecSql('delete from dv.au_module_user where user_id = :user_id$i', [Cth.GetControlValue(CbDst)]);
  Q.QExecSql(
    'insert into dv.au_module_user (user_id, module_id) (select :user_id_dst$i, module_id from dv.au_module_user where user_id = :user_id_src$i)',
    [Cth.GetControlValue(CbDst), Cth.GetControlValue(CbSrc)]
  );
  Q.QExecSql('delete from dv.au_user_privilege where user_id = :user_id$i', [Cth.GetControlValue(CbDst)]);
  Q.QExecSql(
    'insert into dv.au_user_privilege (user_id, privilege_id) (select :user_id_dst$i, privilege_id from dv.au_user_privilege where user_id = :user_id_src$i)',
    [Cth.GetControlValue(CbDst), Cth.GetControlValue(CbSrc)]
  );
  Q.QCommitOrRollback;
  if not Q.CommitSuccess then begin
    MyWarningMessage('Ошибка! Изменения не внесены!');
    Result := False;
    Exit;
  end;
end;

procedure TFrmADedtItmCopyRigths.ShowDialog;
begin
  PrepareCreatedForm(Application, '', '~Права пользователя ИТМ', fEdit, null, [{myfoModal, }myfoDialog, myfoDialogButtonsB]);
  F.DefineFields:=[['cbsrc','V=1:255'], ['cbdst','V=1:255']];
  Q.QLoadToDBComboBoxEh('select name, id from dv.au_user where id not in (-1, 904) order by name', [], CbSrc, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from dv.au_user where id not in (-1, 904) order by name', [], CbDst, cntComboLK);
//  ShowFormAsMdi;
  ShowModal;
end;

end.
