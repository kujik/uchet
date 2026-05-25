unit uFrmAGLstLdapUsers;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh,
  Data.DbxSqlite, Data.FMTBcd, Data.SqlExpr
  ;

type
  TFrmAGLstLdapUsers = class(TFrmBasicGrid2)
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    cnSQLite: TSQLConnection;
    qrySQLite: TSQLQuery;
  private
    function  PrepareForm: Boolean; override;
    procedure GetData;
    procedure CreateABook;
    procedure Test;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    //procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    function  RunADHelperByGUID(const ObjectGUID, AttrName, AttrValue, PasswordPart2: string): Boolean;

  end;

var
  FrmAGLstLdapUsers: TFrmAGLstLdapUsers;

implementation

uses
  System.Win.ComObj, Winapi.ActiveX, Winapi.ShellAPI,
  uLdapHelper, uAdUpdater;

{$R *.dfm}

const
  // Значения флагов авторизации для Active Directory (Источник: iads.h)
  ADS_SECURE_AUTHENTICATION = $00000001; // 0x1
  ADS_USE_ENCRYPTION         = $00000002; // 0x2
  ADS_USE_SSL                = $00000002; // 0x2
  ADS_READONLY_SERVER        = $00000004; // 0x4
  ADS_PROMPT_CREDENTIALS     = $00000008; // 0x8
  ADS_NO_AUTHENTICATION      = $00000010; // 0x10
  ADS_FAST_BIND              = $00000020; // 0x20
  ADS_USE_SIGNING            = $00000040; // 0x40
  ADS_USE_SEALING            = $00000080; // 0x80
  ADS_USE_DELEGATION         = $00000100; // 0x100
  ADS_PROPERTY_CLEAR = 1;

function GuidToStringFromBinary(const Bytes: TBytes): string;
begin
  Result := GuidToString(PGUID(@Bytes[0])^);
end;

function TFrmAGLstLdapUsers.PrepareForm: Boolean;
begin
  Caption:='Пользователи AD';
  Frg1.Opt.SetFields([
   // ['login$s','Логин','120'],
    ['objectguid$s','guid','120'],
    ['adspath$s','_путь','120'],
    ['distinguishedname$s','_distinguishedName','120'],
    ['ab$i','X','30', 'pic'],
    ['name$s','Значение','120'],
    ['displayname$s','Отображаемое имя','120','t=1'],
    ['sn$s','Фамилия','120','t=1'],
    ['givenname$s','Имя','120','t=1'],
    ['description$s','Отчество','120','t=1'],
    ['company$s','Организация','120','t=1'],
    ['department$s','Отдел','120','t=1'],
    ['title$s','Должность','200;h','t=1'],
    ['mail$s','Электронная почта','120'],
    ['telephoneNumber$s','Телефон городской','120','t=1'],
    ['ipphone$s','Телефон внутренний','120','t=1'],
    ['mobile$s','Телефон рабочий', '120','t=1'],
    ['office$s','Комната','200;h','t=1'],
    ['www$s','Веб-страница','120','t=1']
  ]);
  Frg1.Opt.SetButtons(1, [[mbtGo, True], [mbtTest, False], [], [mbtCtlPanel]]);
  Frg1.CreateAddControls('1', cntCheck, 'Редактировать', 'chbEdit', '', 4, yrefT, 200);
  Frg1.InfoArray:=[['']];
  Frg1.SetInitData([]);
  GetData;
  Result := Inherited;
end;

procedure TFrmAGLstLdapUsers.GetData;
var
  va2: TVarDynArray2;
  v: Variant;
function GetAttributeArray(const Field: TField): TVarDynArray;
var
  V: OleVariant;
  LBound, UBound, i: Integer;
begin
  Result := [''];
  V := Field.Value;
  if VarIsNull(V) or VarIsEmpty(V) then
    Exit;
  if (VarType(V) and varArray) <> 0 then
  begin
    LBound := VarArrayLowBound(V, 1);
    UBound := VarArrayHighBound(V, 1);
    Result := [];
    for i := LBound to UBound do
      Result := Result + [VarToStr(V[i])];
  end
  else
  begin
    Result := Result + [VarToStr(V)];
  end;
end;

begin
//  var LUser := 'FRESH\sprokopenko';
//  var LPassword := '';
  var LUser := 'FRESH\testuser';
  var LPassword := 'usertest';
  ADOConnection1.ConnectionString :=
    'Provider=ADsDSOObject;' +
    'Encrypt Password=False;' +
    'Mode=Read;' +
    'Bind Flags=0;' +
    'ADSI Flag=-2147483648;' +
    'User ID=' + LUser + ';' +
    'Password=' +LPassword + ';';
  ADOConnection1.LoginPrompt := False;
  ADOConnection1.Mode := cmRead;
  ADOConnection1.Provider := 'ADsDSOObject';
  ADOConnection1.Open;
  ADOQuery1.Close;
  ADOQuery1.ParamCheck:=false;
  ADOQuery1.SQL.Text:=
    'SELECT objectGUID,ADsPath,distinguishedName,sn,givenName,initials,description,comment,name,displayName,wWWHomePage,physicalDeliveryOfficeName,telephoneNumber,mail,title,department,company,ipPhone,mobile '+
    'FROM ''LDAP://10.1.1.11/DC=fresh,DC=local'' WHERE objectCategory=''user''';
  ADOQuery1.Open;
  ADOQuery1.First;
  va2 := [];
  while not ADOQuery1.Eof do begin
    va2 := va2 + [[
      GuidToStringFromBinary(ADOQuery1.FieldByName('objectGUID').AsBytes),
      ADOQuery1.FieldByName('ADsPath').AsString,
      ADOQuery1.FieldByName('distinguishedName').AsString,
      S.IIf((ADOQuery1.FieldByName('mail').AsString <> '') and (ADOQuery1.FieldByName('physicalDeliveryOfficeName').AsString <> '-'), 1, 0),
      ADOQuery1.FieldByName('name').AsString,
      ADOQuery1.FieldByName('displayName').AsString,
      ADOQuery1.FieldByName('sn').AsString,
      ADOQuery1.FieldByName('givenName').AsString,
      GetAttributeArray(ADOQuery1.FieldByName('description'))[0],
      ADOQuery1.FieldByName('company').AsString,
      ADOQuery1.FieldByName('department').AsString,
      ADOQuery1.FieldByName('title').AsString,
      ADOQuery1.FieldByName('mail').AsString,
      ADOQuery1.FieldByName('telephoneNumber').AsString,
      ADOQuery1.FieldByName('ipPhone').AsString,
      ADOQuery1.FieldByName('mobile').AsString,
      ADOQuery1.FieldByName('physicalDeliveryOfficeName').AsString,
      ADOQuery1.FieldByName('wWWHomePage').AsString

    ]];
    ADOQuery1.Next;
  end;
  ADOQuery1.Close;
  ADOConnection1.Close();
  Frg1.SetInitData(va2);
end;

procedure TFrmAGLstLdapUsers.CreateABook;
var
  i, j: Integer;
begin
  {$IFDEF  ADMIN}
  try
  cnSqLite.Params.Values['Database'] := '\\10.1.1.14\Admin\scriptsr\Domain\abook\abook-tmp.sqlite';
  cnSqLite.Connected := True;
  qrySqLite.SQL.Text := 'delete from properties';
  qrySqLite.ExecSQL;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if (Frg1.GetValueS('mail', i, False) = '') or (Frg1.GetValueS('office', i, False) = '-') then
      Continue;
    qrySqLite.SQL.Text := 'insert into properties (card, name, value) values (' + IntToStr(i) + ','  + '''DisplayName''' + ',' + '''' + Frg1.GetValueS('name', i, False) + '''' + ')';
    qrySqLite.ExecSQL;
    qrySqLite.SQL.Text := 'insert into properties (card, name, value) values (' + IntToStr(i) + ','  + '''PrimaryEmail''' + ',' + '''' + Frg1.GetValueS('mail', i, False) + '''' + ')';
    qrySqLite.ExecSQL;
    qrySqLite.SQL.Text := 'insert into properties (card, name, value) values (' + IntToStr(i) + ','  + '''JobTitle''' + ',' + '''' + Frg1.GetValueS('title', i, False) + '''' + ')';
    qrySqLite.ExecSQL;
  //  qrySqLite.SQL.Text := 'insert into properties (card, name, value) values (' + IntToStr(i) + ','  + '''Department''' + ',' + '''' + Frg1.GetValueS('department', i, False) + '''' + ')';
  //  qrySqLite.ExecSQL;
    qrySqLite.SQL.Text := 'insert into properties (card, name, value) values (' + IntToStr(i) + ','  + '''WorkPhone''' + ',' + '''' + Frg1.GetValueS('mobile', i, False) + '''' + ')';
    qrySqLite.ExecSQL;
  end;
  cnSqLite.Connected := False;
  DeleteFile('\\10.1.1.14\Admin\scriptsr\Domain\abook\abook.sqlite');
  CopyFile('\\10.1.1.14\Admin\scriptsr\Domain\abook\abook-tmp.sqlite', '\\10.1.1.14\Admin\scriptsr\Domain\abook\abook.sqlite', False);
  MyInfoMessage('Адресная книга создана.');
  except
    MyWarningMessage('Ошибка создания адресно книги!');
  end;
  {$ENDIF}
end;

{function SetADAttribute(const ADsPath, AdminUser, AdminPassword, AttrName, AttrValue: string): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  sCommandLine: string;
  ExitCode: DWORD;
begin
  Result := False;
  // Формируем командную строку так же, как вы делали для ShellExecuteEx
  sCommandLine := Format('"%s" "%s" "%s" "%s" "%s"',
    [ADsPath, AdminUser, AdminPassword, AttrName, AttrValue]);
  sCommandLine :=
    '"LDAP://10.1.1.111/CN=test_1c,CN=Users,DC=fresh,DC=local" "FRESH\sprokopenko" "19-kujikirikus" "title" "job"';

  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;
  StartupInfo.wShowWindow := SW_SHOWNORMAL;  // Показываем окно

  FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);

  // Создаём процесс
  if CreateProcess(
//    PChar(ExtractFilePath(ParamStr(0)) + '\ADHelper.exe'), // Полный путь к вашей программе
    PChar('R:\Projects\Uchet\ADHelper.exe'), // Полный путь к вашей программе
    PChar(sCommandLine),                                  // Аргументы командной строки
    nil,                                                  // Безопасность процесса
    nil,                                                  // Безопасность потока
    False,                                                // Не наследовать дескрипторы
    //CREATE_NO_WINDOW,                                     // Не показывать окно (важно для консольных приложений!)
    0,
    nil,                                                  // Использовать переменные окружения родителя
    PChar(ExtractFilePath(ParamStr(0))),                  // Явно задаём рабочую папку (папка вашей программы)
    StartupInfo,
    ProcessInfo) then
  begin
    // Ждём завершения процесса
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    // Получаем код возврата
    GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
    Result := (ExitCode = 0);
    // Закрываем дескрипторы
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end;  }


function SetADAttribute(const ADsPath, AdminUser, AdminPassword, AttrName, AttrValue: string): Boolean;
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
begin
//MyInfoMessage(Format('"%s" "%s" "%s" "%s" "%s"', [ADsPath, AdminUser, AdminPassword, AttrName, AttrValue]));// Exit;
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(SEInfo);
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  SEInfo.Wnd := 0;
  SEInfo.lpFile := PChar(ExtractFilePath(ParamStr(0)) + 'ADHelper.exe');
  SEInfo.lpParameters := PChar(Format('"%s" "%s" "%s" "%s" "%s"', [ADsPath, AdminUser, AdminPassword, AttrName, AttrValue]));
  SEInfo.nShow := SW_HIDE;
  if ShellExecuteEx(@SEInfo) then
  begin
    WaitForSingleObject(SEInfo.hProcess, INFINITE);
    GetExitCodeProcess(SEInfo.hProcess, ExitCode);
    Result := (ExitCode = 0);
    CloseHandle(SEInfo.hProcess);
  end
  else
    Result := False;
end;

procedure TFrmAGLstLdapUsers.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  Frg1.Opt.SetColFeature('1', 'e=0:400::T', Fr.GetControlValue('chbEdit') = 1, False);
  Frg1.Opt.SetColFeature('2', 'e=1:400::T', Fr.GetControlValue('chbEdit') = 1, False);
  Frg1.InvalidateGrid;
end;

{procedure UpdateUserTitle(const ADistinguishedName: string; const Server, AdminUser, AdminPassword: WideString; const NewTitle: string);
var
  LdapHandle: TLDAPHandle;
  sUserDN: string;
begin
  // 1. Получаем Distinguished Name (DN) пользователя из текущей записи ADOQuery1
  //    Предполагается, что в SQL-запросе уже есть поле distinguishedName
  sUserDN := ADistinguishedName; //ADOQuery1.FieldByName('distinguishedName').AsString;
  if sUserDN = '' then
    raise Exception.Create('Не удалось получить Distinguished Name пользователя. Убедитесь, что поле distinguishedName присутствует в запросе.');

  // 2. Подключаемся к контроллеру домена через LDAP
  LdapHandle := LdapConnect(Server, AdminUser, AdminPassword);
  if LdapHandle = nil then
    raise Exception.Create('Не удалось подключиться к LDAP: ' + LdapGetLastError);
  try
    // 3. Изменяем атрибут title
    if not LdapSetAttribute(LdapHandle, sUserDN, 'title', NewTitle) then
      raise Exception.Create('Ошибка при изменении атрибута title: ' + LdapGetLastError);
  finally
    LdapDisconnect(LdapHandle);
  end;
end;   }

procedure TFrmAGLstLdapUsers.Test;
begin
  if not SetADAttribute(
      Frg1.GetValueS('adspath'),
      'FRESH\sprokopenko',           // Учётная запись администратора (домен\пользователь)
      '19-',                 // Пароль
      'title',
      'job'                 // Новое значение должности
    )
    then MyInfoMessage('Error');
end;

{
procedure TFrmAGLstLdapUsers.Test;
begin
//''LDAP://10.1.1.11/DC=fresh,DC=local''
  try
    UpdateUserTitle(
      Frg1.GetValueS('distinguishedname'),                       // TADOQuery с данными пользователей
      '10.1.1.11',                     // IP или имя контроллера домена
//      '''LDAP://10.1.1.11/DC=fresh,DC=local''',
      'FRESH\sprokopenko',           // Учётная запись администратора (домен\пользователь)
      '19-',                 // Пароль
      'job'                 // Новое значение должности
    );
    ShowMessage('Должность успешно обновлена!');
    ADOQuery1.Requery();               // Обновляем данные в DBGrid
  except
    on E: Exception do
      ShowMessage('Ошибка: ' + E.Message);
  end;
end;}

{
procedure TFrmAGLstLdapUsers.Test;
var
  sADsPath: string;
  aAttr: array of string;
  aVals: array of Variant;
begin
  // Получаем ADsPath выбранной записи
//  sADsPath := ADOQuery1.FieldByName('ADsPath').AsString;

  sADsPath := Frg1.GetValue('adspath');

  // Формируем массивы атрибутов и новых значений
  SetLength(aAttr, 2);
  SetLength(aVals, 2);
  aAttr[0] := 'title';
  aVals[0] := 'job';        // новая должность
//  aAttr[1] := 'telephoneNumber';
//  aVals[1] := edtNewPhone.Text;        // новый телефон

  try
    UpdateADAttributes(
      sADsPath,
      'FRESH\sprokopenko',        // глобальная переменная или поле класса, хранящее 'fresh\admin'
      '19-',    // пароль администратора
      aAttr,
      aVals
    );
    ShowMessage('Атрибуты успешно обновлены');
  except
    on E: Exception do
      ShowMessage('Ошибка: ' + E.Message);
  end;
end;  }

procedure TFrmAGLstLdapUsers.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtGo then
    CreateABook
  else if Tag = mbtTest then
    Test
  else
    inherited;
end;

procedure TFrmAGLstLdapUsers.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if FieldName = 'displayname' then begin
    if Fr.GetValueS('displayname') <> Fr.GetValueS('name') then
      Params.Background := clmyYelow;
    if not ((Fr.GetValueS('displayname') = Fr.GetValueS('givenname')) or (Fr.GetValueS('displayname') = Fr.GetValueS('sn') + ' ' + Fr.GetValueS('givenname'))) then
      Params.Font.Color := clRed;
  end;
end;

procedure TFrmAGLstLdapUsers.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Value := Trim(Value.AsString);
  if RunADHelperByGUID(Fr.GetValue('objectguid') ,Fr.CurrField, Value.AsString, 'Fre-shKos-troma-44' )
    then begin
      Fr.SetValue(Fr.CurrField, Value);
    end
    else
      MyInfoMessage('Error');
    Handled := True;
end;

procedure TFrmAGLstLdapUsers.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  inherited;
end;








{  va2:=[];
  cnSqLite.Connected := True;
  qrySqLite.SQL.Text :=
    'select login, name, machine, os_version, ip_addresses, last_login, last_time from usersinfo';
  qrySqLite.Open;
  while not qrySqLite.Eof do begin
    va2 := va2 + [[
       qrySqLite.FieldByName('login').AsString,
       qrySqLite.FieldByName('name').AsString,
       qrySqLite.FieldByName('machine').AsString,
       qrySqLite.FieldByName('os_version').AsString,
       qrySqLite.FieldByName('ip_addresses').AsString,
       qrySqLite.FieldByName('last_login').AsString,
       qrySqLite.FieldByName('last_time').AsString
    ]];
    qrySqLite.Next;
  end;
  qrySqLite.Close;
  cnSqLite.Connected := False;
  Frg1.SetInitData(va2);}


function TFrmAGLstLdapUsers.RunADHelperByGUID(const ObjectGUID, AttrName, AttrValue, PasswordPart2: string): Boolean;
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
  sParams: string;
  sExePath: string;
begin
  Result := False;

  // Формируем параметры с правильными кавычками
  sParams := Format('"%s" "%s" "%s" "%s"',
    [ObjectGUID, AttrName, AttrValue, PasswordPart2]);

  sExePath := ExtractFilePath(ParamStr(0)) + 'ADHelper.exe';

  if not FileExists(sExePath) then
  begin
    ShowMessage('Ошибка: не найден ADHelper.exe в папке программы');
    Exit;
  end;

  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(SEInfo);
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  SEInfo.lpFile := PChar(sExePath);
  SEInfo.lpParameters := PChar(sParams);
  SEInfo.nShow := SW_HIDE;

  if ShellExecuteEx(@SEInfo) then
  begin
    WaitForSingleObject(SEInfo.hProcess, INFINITE);
    GetExitCodeProcess(SEInfo.hProcess, ExitCode);
    Result := (ExitCode = 0);
    CloseHandle(SEInfo.hProcess);
  end;
end;

end.
