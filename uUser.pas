unit uUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Jpeg, MemTableDataEh, Db,
  ADODB, DataDriverEh, GridsEh, DBGridEh, PropStorageEh, DBAxisGridsEh,
  PngImage, uString, IniFiles, DBCtrlsEh, Types,
  frxClass, frxDesgn, Vcl.Styles,
  Xml.xmldom,

  IdIOHandler, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  Data.DBXOracle, Menus
  ;

type
  TUser = class
  private
    Logged: Boolean;
    UserID: Integer;
    UserLogin: string;
    UserName: string;
    UserRights: string;
    UserJob: Integer;
    UserJobComm: string;
    ComputerUserLogin: string;
    UserIdleTime: Integer;
    function GetComputerUserLogin: string;
    function EnableLogin(Login: string): Boolean;
    function AfterUserLogin: Boolean;
  public
    constructor Create();
    function  IsLogged: Boolean;
    function  GetId: Integer;
    function  GetLogin: string;
    function  GetName: string;
    function  GetJobID: Integer;
    function  GetJob: string;
    function  GetJobComm: string;
    function  GetComputerLogin: string;
    function  GetIdleTime: Integer;
    function  LoginAuto: Boolean;
    function  LoginManual(UName, Pwd: string): Boolean;
    function  LoginAsServer: Boolean;
    function  Logout: Boolean;
    procedure SetUsersComboBox(Cb: TDBComboboxEh; ShowNoActiveUsers: Boolean = False);
    procedure SaveCfgToDB(st: string; ToDef: Boolean = False);
    function  LoadCfgFromDB(ToDef: Boolean = False): string;
//    function  LoadDefCfgFromDB(): string;
    function  Role(r: string): Boolean;
    function  Roles(RAnd: TVarDynArray = []; ROr: TVarDynArray = []; RNot: TVarDynArray = []): Boolean;
    function  IsDeveloper: Boolean;
    function  IsDataEditor: Boolean;
end;


implementation


uses
  uData,
  uDBOra,
  uSettings,
  uForms,
  uErrors,
  uMessages,
  uFrmMain
  ;


constructor TUser.Create();
begin
  Logged:=False;
end;

//право пользователя
function TUser.Role(r: string): Boolean;
begin
  Result := (Pos(r, UserRights) > 0) and ((r[1] = '0') or (r[1] = InttoStr(cMainModule)));  //сбросим права, если они относятся к другим модулям (кроме тех что для Админки)
  if UserID = 0 then
    Result := True;
end;

//вернет по сочетанию прав - (если есть все в первом массиве) и (есть хотя бы один во втором массиве) и (нет ни одного в третьем массиве)
function TUser.Roles(RAnd: TVarDynArray = []; ROr: TVarDynArray = []; RNot: TVarDynArray = []): Boolean;
var
  i: Integer;
  b1, b2, b3: Boolean;
begin
  b1 := False;
  b2 := False;
  b3 := False;
  if Length(RAnd) = 0 then
    b1 := True
  else
    for i := 0 to High(RAnd) do
      b1 := b1 and Role(RAnd[i]);
  if Length(ROr) = 0 then
    b2 := True
  else
    for i := 0 to High(ROr) do
      b2 := b2 or Role(ROr[i]);
  b3 := True;
  if Length(RNot) = 0 then
    b3 := True
  else
    for i := 0 to High(RNot) do
      b3 := b3 and not Role(RNot[i]);
  Result := b1 and b2 and b3;
  if UserID = 0 then
    Result := True;
end;

function  TUser.IsDeveloper: Boolean;
begin
  Result:=Role(rAdm_Other_IsDeveloper);
//  Result:=GetLogin='sprokopenko';
end;

function  TUser.IsDataEditor: Boolean;
begin
  Result:=Role(rAdm_Other_IsDataEditor);
//  Result:=GetLogin='sprokopenko';
end;

//получить логин текущего пользователя компьютера
function TUser.GetComputerUserLogin: string;
const
  cnMaxUserNameLen = 254;
var
  sUserName: string;
  dwUserNameLen: DWORD;
begin
   dwUserNameLen := cnMaxUserNameLen - 1;
   SetLength(sUserName, cnMaxUserNameLen);
   GetUserName(PChar(sUserName), dwUserNameLen);
   SetLength(sUserName, dwUserNameLen-1);
   Result:=sUserName;
end;

function TUser.AfterUserLogin: Boolean;
var
  v, v1: TVarDynArray;
  i: Integer;
  va2: TVarDynArray2;
begin
  Q.QCallStoredProc('p_UserLogon', 'IdModule$i;IdUser$i', [cMainModule, User.GetId]);
  va2 := Q.QLoadToVarDynArray2('select r.rights from adm_roles r, adm_user_roles ur where r.id = ur.id_role and ur.id_user = :id', [UserID]);
  UserRights := ',';
  for i := 0 to High(va2) do
    UserRights := UserRights + va2[i][0] + ',';
  Settings.Load;
  Settings.ReadInterfaceSettings;
  Settings.SetStyle;
{  if Settings.InterfaceStyle = ''
    then Module.SetStyle('')
    else Module.SetStyle(Module.GetPath_Styles+'\'+Settings.InterfaceStyle);}
  v := Q.QSelectOneRow('select job, job_comm, idletime from adm_users where id = :id$i', [GetID]);
  UserJob := v[0].AsInteger;
  UserIdleTime := v[2].AsInteger;
  Errors.SetMadExcept;
  if FrmMain <> nil then
    FrmMain.AfterUserLogged;
    {$IFDEF  TURV}
//  if not A.InArray(User.GetLogin, ['sprokopenko', 'eteplyakova', 'kadry1', 'kadry2', 'kadry3', 'eveselova', 'ostulihina']) then Halt;  //!T!!! //!!!
    {$ENDIF}

end;

//пытаемся войти в систему под пользователем системы (вход если логин на компьютере совпадает с логином в БД учета)
function TUser.LoginAuto: Boolean;
var
  v, v1: TVarDynArray;
  i: Integer;
begin
  if not Q.Connected then Exit;
  ComputerUserLogin:=GetComputerUserLogin;
  //автовход под администратором невозможен
  if ComputerUserLogin = 'Администратор' then Exit;
  v:= Q.QSelectOneRow('select id, login, name from adm_users where login=:login and active = 1 and autologin = 1', [ComputerUserLogin]);
  Result:= (v[0] <> null) and EnableLogin(v[1]);
  if Result then begin
    i:= v[0];
    v1:=Q.QSelectOneRow('select IsModuleAvailableToUser(:id_u, :id_m) from dual', [i, cMainModule]);
    Result:= (v1[0] = 1);
  end;
  if Result then begin
    UserId:=v[0];
    UserLogin:=v[1];
    UserName:=v[2];
    Logged:=True;
    AfterUserLogin;
//    DBLock_ClearAll;
  end;
end;

//вход вручную по введенному логину и паролю
function TUser.LoginManual(UName, Pwd: string): Boolean;
var
  v: TVarDynArray;
begin
//  v:= QSelectOneRow('select id, login, name from adm_users where (name=:name) and ((''1''=:pwd1) or (pwd=get_hash_val(:pwd2)))',  VarArrayOf([UName, Pwd, Pwd]));
  //для разработчика в присутствии файла dev вход под любым незаблокированным пользователем без пароля
  if User.IsDeveloper and Module.DevFileExists
    then
      v:= Q.QSelectOneRow('select id, login, name from adm_users where (name = :name1$s)', [UName])
    else
      v:= Q.QSelectOneRow(
        'select id, login, name from adm_users where (name = :name1$s) and ('+
        '( (select password from adm_password) = get_hash_val(:pwd1$s) '+
        ' and (:name2$s <> ''Администратор'') '+
        ') or (pwd=get_hash_val(:pwd2$s)) )',
        [UName, Pwd, UName, Pwd]
      );
  Result:= (v[0] <> null) and EnableLogin(v[1]);
  if Result then begin
    if Logged then Q.DBLock_ClearAll;
    UserId:=v[0];
    UserLogin:=v[1];
    UserName:=v[2];
    Logged:=True;
    AfterUserLogin;
//    DBLock_ClearAll;
  end;
end;

//пытаемся войти в систему под пользователем системы (вход если логин на компьютере совпадает с логином в БД учета)
function TUser.LoginAsServer: Boolean;
begin
  UserId:=-10;
  UserLogin:='server';
  UserName:='Server';
  Logged:=True;
end;

function TUser.EnableLogin(Login: string): Boolean;
begin
  Result:=True;
  {$IFDEF PC}
  //Result:= (PosInStArray(Login, PmCal.PC_Users) >=0);
  {$ENDIF}
end;

function TUser.Logout: Boolean;
begin
  Logged:=False;
end;

function TUser.IsLogged: Boolean;
begin
  Result:=Logged;
end;

function TUser.GetId: Integer;
begin
  Result:=UserId;
end;

function TUser.GetLogin: string;
begin
  Result:=UserLogin;
end;

function TUser.GetName: string;
begin
  Result:=UserName;
end;

function TUser.GetJobID: Integer;
begin
  Result:=UserJob;
end;

function TUser.GetJob: string;
begin
  Result:='';
  try
    Result:=MyJobNames[UserJob];
  finally
  end;
end;

function TUser.GetJobComm: string;
begin
  Result:=UserJobComm;
end;



function TUser.GetComputerLogin: string;
begin
  ComputerUserLogin:=GetComputerUserLogin;
  Result:=ComputerUserLogin;
end;

function TUser.GetIdleTime: Integer;
begin
  Result:=UserIdleTime;
end;


//сформируем комбе-бокс с именами пользователей, которым доступен данный молдуль
//первым свегда будет админ
//если параметр истина то будут показаны и неактивные пользователи
procedure TUser.SetUsersComboBox(Cb: TDBComboboxEh; ShowNoActiveUsers: Boolean = False);
begin
  Cb.Items.Clear;
  Cb.Items.Add('Администратор');
  Q.QLoadToDBComboBoxEh('select name from adm_users where id > 0 ' + S.IIf(not ShowNoActiveUsers, 'and active = 1 ', '') + ' and IsModuleAvailableToUser(id, :id_module) = 1 order by name', [cMainModule], Cb,  cntComboL, 1);
end;

procedure TUser.SaveCfgToDB(st: string; ToDef: Boolean = False);
//процедура вызывается в событии разрушения главной формы, так как конфиги фреймов сохраняются при их разрушении, то есть непосредственно перед этим событием
//в результате на данном этапе не работают запросы типа select - всегда разу получает признак EOF !!!
var
  v: TVardynArray;
  id: Integer;
begin
  {$IFDEF SRV}
  Exit;
  {$ENDIF}
  try
  if ToDef then id:= -1 else id:= GetId;
//  v:=Q.QSelectOneRow('select id_user from adm_user_cfg where id_user = :id_user$i and id_module = :id_module$i', [ID, cMainModule]);
//  v:=Q.QSelectOneRow('select count(*) from adm_user_cfg', []);
//  v:=Q.QSelectOneRow('select count(*) from orders', []);
//  if v[0] = 0 then
//    Q.QExecSql('insert into adm_user_cfg (id_user, id_module, cfg) values (:id_user, :id_module, :cfg)', [ID, cMainModule, ''], True);
  Q.QExecSql('insert into adm_user_cfg (id_user, id_module) select '+ IntToStr(ID) + ', ' + InttoStr(cMainModule) + ' from dual '+
    'where not exists (select id_user from adm_user_cfg where id_user = :id_user$i and id_module = :id_module$i)',
    [ID, cMainModule], False
  );
  Q.QExecSql('update adm_user_cfg set cfg = :cfg where id_user = :id_user and id_module = :id_module', [st, ID, cMainModule], False);
  except
  end;
end;

function TUser.LoadCfgFromDB(ToDef: Boolean = False): string;
var
  v: Variant;
  id: Integer;
begin
  if ToDef then id:= -1 else id:= GetId;
  v:=Q.QSelectOneRow('select cfg from adm_user_cfg where id_user = :id_user and id_module = :id_module', [ID, cMainModule]);
  if v[0]<> null
    then Result:= VarToStr(v[0])
    else Result:='';
end;


end.
