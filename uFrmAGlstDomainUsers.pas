unit uFrmAGlstDomainUsers;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uLabelColors,
  Data.DbxSqlite, Data.FMTBcd, Data.SqlExpr
  ;

type
  TFrmAGlstDomainUsers = class(TFrmBasicGrid2)
    cnSQLite: TSQLConnection;
    qrySQLite: TSQLQuery;
  private
    function  PrepareForm: Boolean; override;
    procedure GetData;
  end;

var
  FrmAGlstDomainUsers: TFrmAGlstDomainUsers;

implementation

{$R *.dfm}

function TFrmAGlstDomainUsers.PrepareForm: Boolean;
begin
  Caption:='������������ ������';
  Frg1.Opt.SetFields([
    ['login$s','�����','120'],
    ['name$s','������������ ���','120'],
    ['machine$s','��� ����������','120'],
    ['os_version$s','������ ��','200;h'],
    ['ip_addresses$s','������ ������� ���������','200;h'],
    ['last_login$s','����� ���������� ������','120'],
    ['last_time$s','��������� ����� ����������', '120']
  ]);
  Frg1.InfoArray:=[['']];
  Frg1.SetInitData([]);
  GetData;
  Result := Inherited;
end;

procedure TFrmAGlstDomainUsers.GetData;
var
  va2: TVarDynArray2;
begin
  va2:=[];
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
  Frg1.SetInitData(va2);
end;

end.


