{
отображает сессии Oracle (все или только для модулей Учета)
также позволяет послать сигнал завершения сесии выбранным модулям.
}
unit uFrmAWOracleSessions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, DBCtrlsEh, Vcl.Buttons,
  uFrDBGridEh, uData, uDBOra, uMessages, uForms, uString, uFrmBasicGrid2,
  Vcl.Mask
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
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure GetInfo;
  public
  end;

var
  FrmAWOracleSessions: TFrmAWOracleSessions;

implementation

{$R *.dfm}

procedure TFrmAWOracleSessions.tmr1Timer(Sender: TObject);
begin
  inherited;
  Frg1.RefreshGrid;
  GetInfo;
end;

procedure TFrmAWOracleSessions.btnCloseModulesClick(Sender: TObject);
var
  i, j: Integer;
  Cb: TCheckBox;
begin
  if nedtIdle.Value = null then
    exit;
  if MyQuestionMessage('Завершить работу выбранных модулей?') <> mrYes then
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

function TFrmAWOracleSessions.PrepareForm: Boolean;
var
  i, t : integer;
  c: TControl;
begin
  Caption := 'Сессии Oracle';
  Frg1.Options := Frg1.Options - [myogGrayedWhenRefresh];
  Frg1.Opt.SetFields([
    ['id$s as id','_id','40'],
    ['id_uchet$s','_id_uchet','40'],
    ['sid$i', 'sid', '60'],
    ['serial#$i', 'serial', '60'],
    ['type$s', 'Тип', '60'],
    ['logon_time','Время подключения к Oracle','130'],
    ['user_logon_time','Время логина в Учет','130'],
    ['name','Пользователь Учета','100;w'],
    ['login','Логин в Учете','100;w'],
    ['username$s','username','100;w'],
    ['module$s','module','100;w'],
    ['module_version$s','Версия модуля','175'],
    ['module_actual$i','Актуален','90','pic=0;1:6;1;0'],
    ['machine$s','machine','100;w'],
    ['osuser$s','osuser','100;w']
  ]);
  Frg1.Opt.SetTable('v_active_user_sessions');
  //Frg1.SetInitData('*', []);
  Frg1.Opt.SetButtons(1, [[mbtRefresh], [mbtRefresh], [-1000, True, 'Завершить сессию', 'cancel'], [mbtCtlPanel]]);
  Frg1.CreateAddControls('1', cntCheck, 'Все схемы', 'chbAll', '', 4, yrefC, 80);
  Frg1.CreateAddControls('1', cntCheck, 'Системные сесии', 'chbOracle', '', -1, yrefC, 130);
  Frg1.CreateAddControls('1', cntCheck, 'Фоновые процессы', 'chbBackground', '', -1, yrefC, 130);
  Result := Inherited;
  t := 8;
  for i := 0 to cMainModulesCount - 1 do begin
    c:=Cth.CreateControls(pnlFrmClient, cntCheck, ModuleRecArr[i].Caption, 'chb' + IntToStr(i), '', 0);
    c.Left := 4;
    c.Width := pnlLeft.Width - 10;
    c.Top := t + 4 + i * MY_FORMPRM_CONTROL_H;
  end;
  Cth.SetBtn(btnCloseModules, mybtClose, False, 'Послать сигнал завершения');
end;

procedure TFrmAWOracleSessions.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = 1000 then
    if (Fr.GetValueS('sid') <> '') and (Fr.GetValueS('serial#') <> '') and (MyQuestionMessage('Завершить сессию?') = mrYes) then
      try
        Q.QCallStoredProc('sys.kill_user_session', 'sid$i;serial#$s', [Fr.GetValue('sid'), Fr.GetValue('serial#')]);
      except
        MyInfoMessage('Не удалось завершить сессию!');
      end;
end;

procedure TFrmAWOracleSessions.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if Fr.IsPrepared then
    Fr.RefreshGrid;
end;

procedure TFrmAWOracleSessions.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  SqlWhere := S.IIFStr(Fr.GetControlValue('chbOracle') = '0', 'osuser <> ''oracle'' and ') + S.IIFStr(Fr.GetControlValue('chbBackground') = '0', 'type <> ''BACKGROUND'' and ') + 'nvl(username, ''~'') like :username$s';
  if Fr.GetControlValue('chbAll') = 0 then begin
    Fr.Opt.SetTable('v_active_user_sessions_w_grp');
    Fr.SetSqlParameters('username$s', [UpperCase(Q.CurrentShema)]);
  end
  else begin
    Fr.Opt.SetTable('v_active_user_sessions');
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

end.
