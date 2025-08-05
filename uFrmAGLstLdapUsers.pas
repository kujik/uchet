unit uFrmAGLstLdapUsers;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uLabelColors,
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
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
  end;

var
  FrmAGLstLdapUsers: TFrmAGLstLdapUsers;

implementation

{$R *.dfm}

function TFrmAGLstLdapUsers.PrepareForm: Boolean;
begin
  Caption:='Пользователи AD';
  Frg1.Opt.SetFields([
   // ['login$s','Логин','120'],
    ['name$s','Отображаемое имя','120'],
    ['sn$s','Фамилия','120'],
    ['givenname$s','Имя','120'],
    ['description$s','Отчество','120'],
    ['company$s','Организация','120'],
    ['department$s','Отдел','120'],
    ['title$s','Должность','200;h'],
    ['mail$s','Электронная почта','120'],
    ['telephoneNumber$s','Телефон городской','120'],
    ['ipphone$s','Телефон внутренний','120'],
    ['mobile$s','Телефон рабочий', '120'],
    ['office$s','Комната','200;h'],
    ['www$s','Веб-страница','120']
  ]);
  Frg1.Opt.SetButtons(1, [[mbtGo, True]]);
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
//exit;
  va2 := [];
  ADOConnection1.ConnectionString := 'Provider=ADsDSOObject;Encrypt Password=False;Mode=Read;Bind Flags=0;ADSI Flag=-2147483648;';
  ADOConnection1.LoginPrompt := False;
  ADOConnection1.Mode := cmRead;
  ADOConnection1.Provider := 'ADsDSOObject';
  ADOConnection1.Open;
  ADOQuery1.Close;
  ADOQuery1.ParamCheck:=false;
  ADOQuery1.SQL.Text:=
    'SELECT sn,givenName,initials,description,comment,name,wWWHomePage,physicalDeliveryOfficeName,telephoneNumber,mail,title,department,company,ipPhone,mobile '+
    'FROM ''LDAP://DC=fresh,DC=local'' WHERE objectCategory=''user''';// AND mail IS NOT NULL';
  ADOQuery1.Open;
  ADOQuery1.First;
  while not ADOQuery1.Eof do begin
    va2 := va2 + [[
      ADOQuery1.FieldByName('name').AsString,
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
  cnSqLite.Connected := True;
  qrySqLite.SQL.Text := 'delete from properties';
  qrySqLite.ExecSQL;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValueS('mail', i, False) = '' then
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
end;


procedure TFrmAGLstLdapUsers.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtGo then
    CreateABook
  else
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


end.
