unit uUser;

{
  Модуль работы с пользователем.
  Содержит информацию о текущем авторизованном пользователе,
  проверку прав, авторизацию, загрузку/сохранение конфигурации.
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Jpeg, MemTableDataEh, Db,
  ADODB, DataDriverEh, GridsEh, DBGridEh, PropStorageEh, DBAxisGridsEh,
  PngImage, uString, IniFiles, DBCtrlsEh, Types,
  frxClass, frxDesgn, Vcl.Styles,
  Xml.xmldom,
  IdIOHandler, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  Data.DBXOracle, Menus;

type
  TUser = class
  private
    Logged: Boolean;
    UserID: Integer;
    UserLogin: string;
    UserName: string;
    UserRights: string;           // строка прав в формате ",модуль-роль,"
    UserJob: Integer;
    UserJobComm: string;
    ComputerUserLogin: string;
    UserIdleTime: Integer;
    function GetComputerUserLogin: string;
    function EnableLogin(const ALogin: string): Boolean;
    function AfterUserLogin: Boolean;
  public
    constructor Create();

    // проверка, выполнен ли вход
    function IsLogged: Boolean;
    // получить ID пользователя
    function GetId: Integer;
    // получить логин пользователя
    function GetLogin: string;
    // получить полное имя пользователя
    function GetName: string;
    // получить код должности
    function GetJobID: Integer;
    // получить название должности
    function GetJob: string;
    // получить комментарий к должности
    function GetJobComm: string;
    // получить логин пользователя Windows
    function GetComputerLogin: string;
    // получить время бездействия (в минутах) для автовыхода
    function GetIdleTime: Integer;

    // свойства для удобного доступа (не заменяют методы, а дополняют их)
    property Id: Integer read GetId;
    property Login: string read GetLogin;
    property Name: string read GetName;
    property JobID: Integer read GetJobID;
    property Job: string read GetJob;
    property JobComm: string read GetJobComm;
    property ComputerLogin: string read GetComputerLogin;
    property IdleTime: Integer read GetIdleTime;

    // автоматический вход по логину Windows
    function LoginAuto: Boolean;
    // ручной вход по имени и паролю
    function LoginManual(const AUserName, APassword: string): Boolean;
    // вход под служебным пользователем "server"
    function LoginAsServer: Boolean;
    // выход из системы
    function Logout: Boolean;

    // заполнить комбобокс именами пользователей, имеющих доступ к модулю
    procedure SetUsersComboBox(ACb: TDBComboboxEh; const AShowNoActiveUsers: Boolean = False);
    // сохранить конфигурацию пользователя в БД
    procedure SaveCfgToDB(const AConfig: string; const AToDef: Boolean = False);
    // загрузить конфигурацию пользователя из БД
    function LoadCfgFromDB(const AToDef: Boolean = False): string;

    // проверка одного права. AModuleId = -1 (по умолчанию) – текущий модуль.
    // Если передано значение модуля, ищем право для этого модуля или сквозное.
    function Role(const ARight: string; const AModuleId: Integer = -1): Boolean;
    // проверка сочетания прав: AND, OR, NOT. AModuleId = -1 – текущий модуль.
    function Roles(const AAnd: TVarDynArray = []; const AOr: TVarDynArray = []; const ANot: TVarDynArray = []; const AModuleId: Integer = -1): Boolean; overload;
    // перегрузка для проверки права по OR (достаточно одного из списка)
    function Roles(const AOr: TVarDynArray; const AModuleId: Integer = -1): Boolean; overload;

    // является ли пользователь разработчиком (глобальное право)
    function IsDeveloper: Boolean;
    // является ли пользователь редактором данных (глобальное право)
    function IsDataEditor: Boolean;
  end;

implementation

uses
  uData,
  uDBOra,
  uSettings,
  uForms,
  uErrors,
  uMessages,
  uFrmMain;

constructor TUser.Create();
// инициализация: вход не выполнен
begin
  Logged := False;
end;

function TUser.Role(const ARight: string; const AModuleId: Integer = -1): Boolean;
// проверка наличия одного права с учётом модуля.
// Если AModuleId = -1, используется текущий модуль (cMainModule).
// Ищем либо "<модуль>-<право>", либо "<право>" (сквозное право)
var
  ModuleId: Integer;
  SearchStr: string;
begin
  if AModuleId = -1 then
    ModuleId := cMainModule
  else
    ModuleId := AModuleId;

  // Поиск права для указанного модуля: ",модуль-право,"
  SearchStr := ',' + IntToStr(ModuleId) + '-' + ARight + ',';
  Result := Pos(SearchStr, UserRights) > 0;

  // Если не найдено, ищем сквозное право (без дефиса): ",право,"
  if not Result then
  begin
    SearchStr := ',' + ARight + ',';
    Result := Pos(SearchStr, UserRights) > 0;
  end;

  // Для пользователя с ID=0 (неавторизованный) всегда разрешено
  if UserID = 0 then
    Result := True;
end;

function TUser.Roles(const AAnd: TVarDynArray = []; const AOr: TVarDynArray = []; const ANot: TVarDynArray = []; const AModuleId: Integer = -1): Boolean;
// проверка сложного условия: (все AAnd) и (хотя бы один AOr) и (ни один из ANot)
var
  i: Integer;
  HasAllAnd, HasAnyOr, HasNoNot: Boolean;
begin
  HasAllAnd := True;
  if Length(AAnd) > 0 then
    for i := 0 to High(AAnd) do
      HasAllAnd := HasAllAnd and Role(AAnd[i], AModuleId);

  HasAnyOr := True;
  if Length(AOr) > 0 then
    for i := 0 to High(AOr) do
      HasAnyOr := HasAnyOr or Role(AOr[i], AModuleId);

  HasNoNot := True;
  if Length(ANot) > 0 then
    for i := 0 to High(ANot) do
      HasNoNot := HasNoNot and not Role(ANot[i], AModuleId);

  Result := HasAllAnd and HasAnyOr and HasNoNot;
  if UserID = 0 then
    Result := True;
end;

function TUser.Roles(const AOr: TVarDynArray; const AModuleId: Integer = -1): Boolean;
// перегрузка: проверка права по OR (достаточно одного из массива)
begin
  Result := Roles([], AOr, [], AModuleId);
end;

function TUser.IsDeveloper: Boolean;
// проверка права разработчика (глобальное право "rAdm_Other_IsDeveloper")
begin
  Result := Role(rAdm_Other_IsDeveloper);
end;

function TUser.IsDataEditor: Boolean;
// проверка права редактора данных (глобальное право "rAdm_Other_IsDataEditor")
begin
  Result := Role(rAdm_Other_IsDataEditor);
end;

//==============================================================================
// Реализация остальных методов
//==============================================================================

function TUser.GetComputerUserLogin: string;
// получение логина текущего пользователя Windows
const
  MaxUserNameLen = 254;
var
  UserNameBuf: string;
  BufSize: DWORD;
begin
  BufSize := MaxUserNameLen - 1;
  SetLength(UserNameBuf, MaxUserNameLen);
  GetUserName(PChar(UserNameBuf), BufSize);
  SetLength(UserNameBuf, BufSize - 1);
  Result := UserNameBuf;
end;

function TUser.AfterUserLogin: Boolean;
// действия после успешного входа: загрузка прав, настроек и т.д.
var
  RowResult: TVarDynArray;
  RightsRows: TVarDynArray2;
  i: Integer;
begin
  Q.QCallStoredProc('p_UserLogon', 'IdModule$i;IdUser$i;AVersion',
    [cMainModule, User.GetId, Module.VersionString]);

  RightsRows := Q.QLoad(
    'select r.rights from adm_roles r, adm_user_roles ur ' +
    'where r.id = ur.id_role and ur.id_user = :id', [UserID]);

  UserRights := ',';
  for i := 0 to High(RightsRows) do
    UserRights := UserRights + RightsRows[i][0] + ',';

  Settings.Load;
  Settings.ReadInterfaceSettings;
  Settings.SetStyle;

  RowResult := Q.QLoadRow('select job, job_comm, idletime from adm_users where id = :id$i', [GetID]);
  UserJob := RowResult[0].AsInteger;
  UserJobComm := RowResult[1].AsString;
  UserIdleTime := RowResult[2].AsInteger;

  Errors.SetMadExcept;
  if FrmMain <> nil then
    FrmMain.AfterUserLogged;

  {$IFDEF TURV}
  // временная заглушка для ограничения доступа
  {$ENDIF}

  Result := True;
end;

function TUser.LoginAuto: Boolean;
// автоматический вход, если логин Windows совпадает с логином в БД и включён автовход
var
  RowResult, CheckModuleRow: TVarDynArray;
  Index: Integer;
begin
  if not Q.Connected then Exit;

  ComputerUserLogin := GetComputerUserLogin;
  if ComputerUserLogin = 'Администратор' then Exit;

  RowResult := Q.QLoadRow('select id, login, name from adm_users ' +
    'where login = :login and active = 1 and autologin = 1',
    [ComputerUserLogin]);

  if RowResult[0] = Null then
    Exit(False);

  Result := EnableLogin(RowResult[1]);
  if not Result then
    Exit;

  Index := RowResult[0];
  CheckModuleRow := Q.QLoadRow('select IsModuleAvailableToUser(:id_u, :id_m) from dual',
    [Index, cMainModule]);
  Result := CheckModuleRow[0] = 1;

  if Result then
  begin
    UserID := RowResult[0];
    UserLogin := RowResult[1];
    UserName := RowResult[2];
    Logged := True;
    AfterUserLogin;
  end;
end;

function TUser.LoginManual(const AUserName, APassword: string): Boolean;
// ручной вход по имени пользователя и паролю
var
  RowResult: TVarDynArray;
begin
  // для разработчика с файлом dev – вход без пароля под любым активным пользователем
  if User.IsDeveloper and Module.DevFileExists then
    RowResult := Q.QLoadRow(
      'select id, login, name from adm_users where name = :name1$s',
      [AUserName])
  else
    RowResult := Q.QLoadRow(
      'select id, login, name from adm_users where (name = :name1$s) and (' +
      '( (select password from adm_password) = get_hash_val(:pwd1$s) ' +
      ' and (:name2$s <> ''Администратор'') ) or (pwd = get_hash_val(:pwd2$s)) )',
      [AUserName, APassword, AUserName, APassword]);

  if RowResult[0] = Null then
    Exit(False);

  Result := EnableLogin(RowResult[1]);
  if not Result then
    Exit;

  if Logged then
    Q.DBLock_ClearAll;

  UserID := RowResult[0];
  UserLogin := RowResult[1];
  UserName := RowResult[2];
  Logged := True;
  AfterUserLogin;
end;

function TUser.LoginAsServer: Boolean;
// служебный вход для серверных операций
begin
  UserID := -10;
  UserLogin := 'server';
  UserName := 'Server';
  Logged := True;
  Result := True;
end;

function TUser.EnableLogin(const ALogin: string): Boolean;
// дополнительная проверка разрешения входа (для отладки)
begin
  Result := True;
  {$IFDEF PC}
  // например, проверка вхождения в список
  {$ENDIF}
end;

function TUser.Logout: Boolean;
// выход из системы
begin
  Logged := False;
  Result := True;
end;

function TUser.IsLogged: Boolean;
// проверка, выполнен ли вход
begin
  Result := Logged;
end;

function TUser.GetId: Integer;
// получить ID пользователя
begin
  Result := UserID;
end;

function TUser.GetLogin: string;
// получить логин пользователя
begin
  Result := UserLogin;
end;

function TUser.GetName: string;
// получить полное имя пользователя
begin
  Result := UserName;
end;

function TUser.GetJobID: Integer;
// получить код должности
begin
  Result := UserJob;
end;

function TUser.GetJob: string;
// получить название должности по коду
begin
  Result := '';
  try
    Result := MyJobNames[UserJob];
  except
    // если код вне диапазона, возвращаем пустую строку
  end;
end;

function TUser.GetJobComm: string;
// получить комментарий к должности
begin
  Result := UserJobComm;
end;

function TUser.GetComputerLogin: string;
// получить логин Windows текущего пользователя
begin
  ComputerUserLogin := GetComputerUserLogin;
  Result := ComputerUserLogin;
end;

function TUser.GetIdleTime: Integer;
// получить время бездействия (в минутах) для автовыхода
begin
  Result := UserIdleTime;
end;

procedure TUser.SetUsersComboBox(ACb: TDBComboboxEh; const AShowNoActiveUsers: Boolean = False);
// заполнить комбобокс именами пользователей, имеющих доступ к текущему модулю
begin
  ACb.Items.Clear;
  ACb.Items.Add('Администратор');
  Q.QLoadToDBComboBoxEh(
    'select name from adm_users where id > 0 ' +
    S.IIf(not AShowNoActiveUsers, 'and active = 1 ', '') +
    ' and IsModuleAvailableToUser(id, :id_module) = 1 order by name',
    [cMainModule], ACb, cntComboL, 1);
end;

procedure TUser.SaveCfgToDB(const AConfig: string; const AToDef: Boolean = False);
// сохранить пользовательскую конфигурацию в БД (если AToDef=True – сохранить в общую)
var
  UserIDParam: Integer;
begin
  {$IFDEF SRV}
  Exit;
  {$ENDIF}
  try
    if AToDef then
      UserIDParam := -1
    else
      UserIDParam := GetId;

    // вставляем запись, если её ещё нет
    Q.QExecSql(
      'insert into adm_user_cfg (id_user, id_module) ' +
      'select ' + IntToStr(UserIDParam) + ', ' + IntToStr(cMainModule) + ' from dual ' +
      'where not exists (select id_user from adm_user_cfg where id_user = :id_user$i and id_module = :id_module$i)',
      [UserIDParam, cMainModule], False);

    // обновляем конфигурацию
    Q.QExecSql(
      'update adm_user_cfg set cfg = :cfg where id_user = :id_user and id_module = :id_module',
      [AConfig, UserIDParam, cMainModule], False);
  except
    // игнорируем ошибки сохранения (например, если нет прав)
  end;
end;

function TUser.LoadCfgFromDB(const AToDef: Boolean = False): string;
// загрузить пользовательскую конфигурацию из БД
var
  RowResult: Variant;
  UserIDParam: Integer;
begin
  if AToDef then
    UserIDParam := -1
  else
    UserIDParam := GetId;

  RowResult := Q.QLoadRow(
    'select cfg from adm_user_cfg where id_user = :id_user and id_module = :id_module',
    [UserIDParam, cMainModule]);

  if RowResult[0] = Null then
    Result := ''
  else
    Result := VarToStr(RowResult[0]);
end;

end.
