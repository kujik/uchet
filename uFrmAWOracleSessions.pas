{
отображает сессии Oracle (все или только дл€ модулей ”чета)
также позвол€ет послать сигнал завершени€ сесии выбранным модул€м.
}
unit uFrmAWOracleSessions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, Vcl.Buttons,
  uFrDBGridEh, uData, uDBOra, uMessages, uForms, uString, uFrmBasicGrid2
  ;

type
  TFrmAWOracleSessions = class(TFrmBasicGrid2)
    tmr1: TTimer;
    btnCloseModules: TBitBtn;
    nedtIdle: TDBNumberEditEh;
    procedure tmr1Timer(Sender: TObject);
    procedure btnCloseModulesClick(Sender: TObject);
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure GetInfo;
  public
  end;

var
  FrmAWOracleSessions: TFrmAWOracleSessions;

implementation

{$R *.dfm}

function TFrmAWOracleSessions.PrepareForm: Boolean;
var
  i, t : integer;
  c: TControl;
begin
  Caption := '—ессии Oracle';
  Frg1.Opt.SetFields([
    ['username || module || machine || osuser as id$i','_id','40'],
    ['username$s','username','100;w'],
    ['module$s','module','100;w'],
    ['machine$s','machine','100;w'],
    ['osuser$s','osuser','100;w']
  ]);
  Frg1.Opt.SetTable('v$session');
  Frg1.Opt.SetButtons(1, 'rp');
  Frg1.CreateAddControls('1', cntCheck, 'показать все сесии', 'chbAll', '', 4, yrefC, 150);
  Result := Inherited;
  t := 8;
  for i := 0 to cMainModulesCount - 1 do begin
    c:=Cth.CreateControls(pnlFrmClient, cntCheck, ModuleRecArr[i].Caption, 'chb' + IntToStr(i), '', 0);
    c.Left := 4;
    c.Width := pnlLeft.Width - 10;
    c.Top := t + 4 + i * MY_FORMPRM_CONTROL_H;
  end;
  Cth.SetBtn(btnCloseModules, mybtClose, False, 'ѕослать сигнал завершени€');
end;

procedure TFrmAWOracleSessions.btnCloseModulesClick(Sender: TObject);
var
  i, j: Integer;
  Cb: TCheckBox;
begin
  if nedtIdle.Value = null then
    exit;
  if MyQuestionMessage('«авершить работу выбранных модулей?') <> mrYes then
    Exit;
  for i:= 0 to 15 do begin
    Cb:=TCheckBox(Self.FindComponent('chb' + IntToStr(i)));
    if Cb = nil then
      Break;
    if not Cb.Checked then
      Continue;
    Q.QExecSql('update adm_modules set autoclosedt = (select sysdate from dual), autoclosemin = :idle$i where id = :id$i', [nedtIdle.Value, i]);
  end;
end;

procedure TFrmAWOracleSessions.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  if Fr.GetControlValue('chbAll') = 0 then begin
    SqlWhere := 'username like :username$s group by username, module, machine, osuser';
    Fr.SetSqlParameters('username$s', [UpperCase(Q.CurrentShema)]);
  end
  else begin
    SqlWhere := 'username like :username$s';
    Fr.SetSqlParameters('username$s', ['%']);
  end;
end;

procedure TFrmAWOracleSessions.GetInfo;
var
  i,j,k:Integer;
  st: string;
  va: TVarDynArray;
  Cb: TCheckBox;
begin
  va := [];
  SetLength(va, cMainModulesCount);
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    st := Frg1.GetValueS('module', i, False);
    if S.NSt(st) = '' then
      Continue;
    k := -1;
    for j := 0 to cMainModulesCount - 1 do
      if Pos(ModuleRecArr[j].Caption, st) = 1 then begin
        k := j;
        Break;
      end;
    if k > -1 then
      va[k] := S.NNum(va[k]) + 1;
  end;
  for i := 0 to cMainModulesCount - 1 do begin
    Cb := TCheckBox(Self.FindComponent('chb' + IntToStr(i)));
    if Cb = nil then
      Continue;
    Cb.Caption := ModuleRecArr[i].Caption + S.IIf(S.NNum(va[i]) > 0, '    (' + VarToStr(va[i]) + ')', '');
  end;
end;

procedure TFrmAWOracleSessions.tmr1Timer(Sender: TObject);
begin
  inherited;
  Frg1.RefreshGrid;
  GetInfo;
end;

end.
