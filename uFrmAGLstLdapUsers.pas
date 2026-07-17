unit uFrmAGLstLdapUsers;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uNamedArr, uData, uMessages, uForms, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh,
  Data.DbxSqlite, Data.FMTBcd, Data.SqlExpr
  ;

type
  TFrmAGLstLdapUsers = class(TFrmBasicGrid2)
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    cnSQLite: TSQLConnection;
    qrySQLite: TSQLQuery;
  private const
    CLdapURL = '''LDAP://10.1.1.11/DC=fresh,DC=local''';
    CLdapUserW = 'FRESH\ad_w';
    CLdapUserWPwd = '___';
    CLddapUserR = 'FRESH\testuser';
    CLddapUserRPwd = 'usertest';
  private
    FPwd: string;
    FRoleCh, FRoleChAll, FRoleABook: Boolean;
    function  PrepareForm: Boolean; override;
    function  ConnectToLDAP(AUser, APassword: string): Boolean;
    procedure GetData(const AGUID: string = '');
    procedure CreateABook;
    procedure Test;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    function  RunADHelperByGUID(const ObjectGUID, AttrName, AttrValue, PasswordPart2: string): Boolean;
  end;

var
  FrmAGLstLdapUsers: TFrmAGLstLdapUsers;

implementation

uses
  System.Win.ComObj, Winapi.ActiveX, Winapi.ShellAPI, uAdUpdater, uDBOra, uFrmXDinputPwd, uUpdater, uWaitForm;

{$R *.dfm}

function GuidToStringFromBinary(const Bytes: TBytes): string;
begin
  Result := GuidToString(PGUID(@Bytes[0])^);
end;

function TFrmAGLstLdapUsers.PrepareForm: Boolean;
begin
  Caption:='Пользователи AD';
  Frg1.Opt.SetFields([
   // ['login$s','Логин','120'],
    ['objectguid$s','_guid','120','t=0'],
    ['adspath$s','_путь','120','t=0'],
    ['distinguishedname$s','_distinguishedName','120','t=0'],
    ['ab$i','X','30', 'pic'],
    ['name$s','Значение','120','t=0'],
    ['displayname$s','Отображаемое имя','120','t=0,2'],
    ['sn$s','Фамилия','120','t=0,1'],
    ['givenname$s','Имя','120','t=0,2'],
    ['description$s','Отчество','120','t=0,1'],
    ['company$s','Организация','120','t=0,1'],
    ['department$s','Отдел','120','t=0,1'],
    ['title$s','Должность','200;h','t=0,1'],
    ['mail$s','Электронная почта','120','t=0'],
    ['telephoneNumber$s','Телефон городской','120','t=0,1'],
    ['ipphone$s','Телефон внутренний','120','t=0,1'],
    ['mobile$s','Телефон рабочий', '120','t=0,1'],
    ['physicaldeliveryofficename$s','Подразделение','200','t=0,1'], //Комната
    ['wwwhomepage$s','Площадка','120','t=0,1'],   //Веб-страница
    ['comm$s','Примечание','300;h','t=3']
  ]);
  {$IFDEF ADMIN}
  FRoleCh := User.Role(rAdm_ActiveDirectoryUsers_Ch);
  FRoleChAll := User.Role(rAdm_ActiveDirectoryUsers_ChAll);
  FRoleABook := User.Role(rAdm_ActiveDirectoryUsers_ABook);
  {$ENDIF}
  {$IFDEF TURV}
  FRoleCh := User.Role(rW_ActiveDirectoryUsers_Ch);
  FRoleChAll := User.Role(rW_ActiveDirectoryUsers_ChAll);
  FRoleABook := User.Role(rW_ActiveDirectoryUsers_ABook);
  {$ENDIF}
  Frg1.Opt.SetButtons(1, [[mbtRefresh], [], [mbtGo, FRoleABook, 'Обновить адресную книгу'], [mbtTest, False], [], [mbtCtlPanel]]);
  Frg1.CreateAddControls('1', cntCheck, 'Редактировать', 'chbEdit', '', 4, yrefC, 200);
  Frg1.InfoArray:=[['']];
  Frg1.SetInitData([]);
  GetData;
  Result := Inherited;
  TDBCheckBoxEh(Frg1.FindComponent('chbEdit')).Enabled := FRoleCh or FRoleChAll;
  Frg1.SetControlValue('chbEdit', 0);
end;

function TFrmAGLstLdapUsers.ConnectToLDAP(AUser, APassword: string): Boolean;
begin
  try
    Result:=True;
    ADOConnection1.ConnectionString :=
      'Provider=ADsDSOObject;' +
      'Encrypt Password=False;' +
      'Mode=Read;' +
      'Bind Flags=0;' +
      'ADSI Flag=-2147483648;' +
      'User ID=' + AUser + ';' +
      'Password=' +APassword + ';';
    ADOConnection1.LoginPrompt := False;
    ADOConnection1.Mode := cmRead;
    ADOConnection1.Provider := 'ADsDSOObject';
    ADOConnection1.Open;
    Result := ADOConnection1.Connected;
    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT title FROM ' + CLdapURL + ' WHERE objectCategory=''user''';
    ADOQuery1.Open;
  except
    Result := False;
  end;
  ADOQuery1.Close;
end;

procedure TFrmAGLstLdapUsers.GetData(const AGUID: string = '');
var
  va2: TVarDynArray2;
  v: Variant;
  na: TNamedArr;
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
  var LFields := Frg1.GetFieldNamesEx('0', False);
  ConnectToLDAP(CLddapUserR, CLddapUserRPwd);
  ADOQuery1.Close;
  ADOQuery1.ParamCheck := False;
  ADOQuery1.SQL.Text :=
    'SELECT ' + LFields.Implode(',') + ' FROM ' + CLdapURL + ' WHERE objectCategory=''user''' + S.IIFStr(AGUID <> '', ' and objectGUID = ''' + AGUID + '''');
  ADOQuery1.Open;
  ADOQuery1.First;
  na.Create(LFields + ['ab', 'comm'], 0);
  va2 := Q.QLoad('select guid, comm from adm_ldap_users_ext', []);
  while not ADOQuery1.Eof do begin
    na.IncLength;
    for var j := 0 to ADOQuery1.Fields.Count - 1 do begin
      if ADOQuery1.Fields[j].FieldName = 'objectguid' then
        v := GuidToStringFromBinary(ADOQuery1.FieldByName('objectGUID').AsBytes)
      else if ADOQuery1.Fields[j].FieldName = 'description' then
        v := GetAttributeArray(ADOQuery1.FieldByName('description'))[0]
      else
        v := ADOQuery1.Fields[j].AsString;
      na.SetValue(na.High, ADOQuery1.Fields[j].FieldName, v);
    end;
    na.SetValue(na.High, 'ab', S.IIf((ADOQuery1.FieldByName('mail').AsString <> '') and (ADOQuery1.FieldByName('physicalDeliveryOfficeName').AsString <> '-'), 1, 0));
    var k := A.PosInArray(na.G(na.High, 'objectguid'), va2, 0);
    v := null;
    if k >= 0 then
      v := va2[k][1];
    na.SetValue(na.High, 'comm', v);
    ADOQuery1.Next;
  end;
  ADOQuery1.Close;
  ADOConnection1.Close();
  if AGUID = '' then begin
    Frg1.SetInitData(na);
  end
  else begin
    for var j := 0 to na.FieldsCount - 1 do
      Frg1.SetValue(na.F[j], na.G(na.F[j]));
  end;
end;

procedure TFrmAGLstLdapUsers.CreateABook;
var
  i, j: Integer;
begin
  ShowWaitForm('Создание адресной книги...');
  try
  cnSqLite.Params.Values['Database'] := '\\10.1.1.14\scriptsw\Domain\abook\abook-tmp.sqlite';
  cnSqLite.Connected := True;
  qrySqLite.SQL.Text := 'delete from properties';
  qrySqLite.ExecSQL;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if (Frg1.GetValueS('mail', i, False) = '') or (Frg1.GetValueS('physicaldeliveryofficename', i, False) = '-') then
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
  DeleteFile('\\10.1.1.14\scriptsw\Domain\abook\abook.sqlite');
  CopyFile('\\10.1.1.14\scriptsw\Domain\abook\abook-tmp.sqlite', '\\10.1.1.14\scriptsw\Domain\abook\abook.sqlite', False);
  MyInfoMessage('Адресная книга создана.');
  except
    MyWarningMessage('Ошибка создания адресно книги!');
  end;
end;

procedure TFrmAGLstLdapUsers.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
var
  LPwd: string;
begin
  if not Fr.IsPrepared or not Self.Visible then
    Exit;
  if Fr.GetControlValue('chbEdit') = 1 then begin
    LPwd := FrmXDinputPwd.ShowDialogP(Self);
    if LPwd = '' then
      FPwd := ''
    else begin
      if ConnectToLDAP(CLdapUserW, CLdapUserWPwd + LPwd) then
        FPwd := LPwd
      else
        FPwd := '';
      ADOConnection1.Close;
    end;
  end;
  if not SyncFilesFromServer(['ADHelper.exe']) then
    FPwd := '';
  if FPwd = '' then
    Fr.SetControlValue('chbEdit', 0);
  Frg1.Opt.SetColFeature('1', 'e=0:64::T', Fr.GetControlValue('chbEdit') = 1, False);
  Frg1.Opt.SetColFeature('2', 'e=1:64::T', Fr.GetControlValue('chbEdit') = 1, False);
  Frg1.Opt.SetColFeature('3', 'e=0:1000::T', Fr.GetControlValue('chbEdit') = 1, False);
  Frg1.InvalidateGrid;
end;


procedure TFrmAGLstLdapUsers.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  if Tag = mbtRefresh then begin
    GetData;
    Frg1.RefreshGrid;
  end
  else if Tag = mbtGo then
    CreateABook
  else if Tag = mbtTest then
    Test
  else begin
    Handled := False;
    inherited;
  end;
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
  if Fr.CurrField = 'comm' then begin
    Q.QExecSql(
      'merge into adm_ldap_users_ext t '+
      'using (select :guid$s as guid from dual) s '+
      'on (t.guid = s.guid) '+
      'when not matched then insert (guid) values (s.guid)',
      [Fr.GetValue('objectguid')]
    );
    Q.QExecSql('update adm_ldap_users_ext set comm = :comm$s where guid = :guid$s', [Value, Fr.GetValue('objectguid')]);
    Fr.SetValue(Fr.CurrField, Value);
  end
  else begin
    if RunADHelperByGUID(Fr.GetValue('objectguid') ,Fr.CurrField, Value.AsString, 'Fre-shKos-troma-44' )
      then begin
        GetData(Fr.GetValue('objectguid'));
      end
      else
        MyInfoMessage('Error');
  end;
    Handled := True;
end;

procedure TFrmAGLstLdapUsers.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  ReadOnly := FRoleCh and (Fr.GetValue('physicaldeliveryofficename') = '-');
end;

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
  if not FileExists(sExePath) then begin
    ShowMessage('Ошибка: не найден ADHelper.exe в папке программы');
    Exit;
  end;
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(SEInfo);
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  SEInfo.lpFile := PChar(sExePath);
  SEInfo.lpParameters := PChar(sParams);
  SEInfo.nShow := SW_HIDE;
  if ShellExecuteEx(@SEInfo) then begin
    WaitForSingleObject(SEInfo.hProcess, INFINITE);
    GetExitCodeProcess(SEInfo.hProcess, ExitCode);
    Result := (ExitCode = 0);
    CloseHandle(SEInfo.hProcess);
  end;
end;

procedure TFrmAGLstLdapUsers.Test;
begin

end;

end.
