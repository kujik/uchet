{
������� ����� ������ � ��
�� ���� ����������� ������ ��� ������ � ����������� ������ ��� ������

AdoConnection - ���������� � ��
AdoConnectionProviderEh - ��� �������� �� ����������� EhLib
(���� ��� ���� ��������� Connection = AdoConnection, �� ���������� ��� ����������� � ����� ���� ������ �� ���������,
���� �� ���������� ���������� InlineConnection � ������� ����� ���. � ��������� ������ ���������. ����� ��� ������/�����������
�������� �� ����������� EhLib, ����� ������� �� ��� ����� �������� �������� ����� AdoConnection, �� ��������� �� ���������
�� �����������. ����� ������ - ���������� �� �������������� - ������������ �� �������������/������� � ����������� AdoConnectionProviderEh.onnection
)

��� TAdoDataDriverEh �� ������ ���������� �������� AdoConnectionProvider:= myDBOra.AdoConnectionProviderEh, AdoConnection ��������� ������

��������� ������� (��� ������ ����� ����� ��������, ��� ������) ����� �������,
��������� ������� (�� ����� ������ � ����������-�������� ��������) - ������ ��������� (����)
��� ��� ����� ������������ AdoQueryService
}

unit uDB;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  MemTableDataEh, DataDriverEh, Math, Types, Dialogs, StdCtrls, DBCtrlsEh, DB,
  AdoDB, uString, Variants, MemTableEh, IniFiles, ADODataDriverEh, DBGridEh,
  uFrmXDmsgNoConnection, uErrors, uData;

type
  TmydbType = (mydbtOra, mydbtMsSql, mydbtSqLite);

const
  cmydbLogId = 0;
  cmydbLogTime = 1;
  cmydbLogSource = 2;
  cmydbLogQuery = 3;
  cmydbLogParams = 4;
  cmydbLogError = 5;

type
  TmyDB = class(TDataModule)
    AdoStoredProc: TADOStoredProc;
    ADODataDriverEh: TADODataDriverEh;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    AdoQuery: TADOQuery;
    AdoConnectionProviderEh: TADOConnectionProviderEh;
    AdoConnection: TADOConnection;
    ADOQueryService: TADOQuery;
    procedure AdoConnectionWillExecute(Connection: TADOConnection; var CommandText: WideString; var CursorType: TCursorType; var LockType: TADOLockType; var CommandType: TCommandType; var ExecuteOptions: TExecuteOptions; var EventStatus: TEventStatus; const Command: _Command; const Recordset: _Recordset);
    function AdoConnectionProviderEhExecuteCommand(SQLDataDriver: TCustomSQLDataDriverEh; Command: TCustomSQLCommandEh; var Cursor: TDataSet; var FreeOnEof, Processed: Boolean): Integer;
    procedure AdoQueryBeforeOpen(DataSet: TDataSet);
  private
    { Private declarations }
    //������ ������ ����������
    //������� ��������� � ������ Adoconnection � ������ AdoconnectionEh
    function GetConnectState: Boolean;
  protected
    FDbType: TMyDbType;
    FConnectionFile: string;
    FConnectionFileFull: string;
    FConnectionString: string;
    FCurrentShema: string;
    FTestDB: Boolean;
    FConnected: Boolean;
    FErrorState: string;
    FIsLogEnabled: Boolean;
    FSQLLog: TVarDynArray2;
    FLastSequenceId: Variant;
    FSuccess: Boolean;
    FSuccessAll: Boolean;
    FRowsAffected: Integer;
    FPackageMode: Integer;
    FCommitSuccess: Boolean;
    FLastReceivedFiedNames: TVarDynArray;
    //��������� ������������� ������ �������, ���������� ��� ������� �� ���������, � ������
    //��� �� ���������, ��� ����, ������������ � QSetParams
    FLastSql: string;
    FLastParamsStr: string;
    FLastParamsErr: string;
    _FLastSql: string;
    _FLastParamsStr: string;
    _FLastParamsErr: string;
    //������ ����
    FLogArray: TVarDynArray2;
  public
    { Public declarations }

    //��� ���� ������
    property DbType: TmyDbType read FDbType;
    //������ ��� ����� ����������� *.UDL, ������� ��� ��������
    property ConnectionFileFull: string read FConnectionFileFull;
    //������ �����������
    property ConnectionString: string read FConnectionString;
    //������� �����/����
    property CurrentShema: string read FCurrentShema;
    //�����������, ���� �������� ����
    property TestDB: Boolean read FTestDB;
    //�����������, ���� ���� ����������
    property Connected: Boolean read GetConnectState;
    property ErrorState: string read FErrorState;
    //����, ������������ ����������
    property LastSequenceId: Variant read FLastSequenceId;
    property Success: Boolean read FSuccess;
    //property SuccessAll: Boolean;//ad FSuccessAll write SucessAllClear;
    property RowsAffected: Integer read FRowsAffected;
    //����� ��������� ����������.
    //������������ ������� ���������� � ������� True (��������������� � 1)
    //���� ���� �� ���� �������� ����� ����� ������������ ���������, PackageMode ������������ � -1
    //� ��������� ������� QExecSql �� �����������, ���������� ������������� ������������, � ������� ����� ��������� ����������
    property PackageMode: Integer read FPackageMode;
    //������ �������� ��������� ����������
    property CommitSuccess: Boolean read FCommitSuccess;
    //��������� ������ �������� � ���
    property IsLogEnabled: Boolean read FIsLogEnabled;
    //��� ���� �������� � ����� � ������� ������ ������ ���������
    property LastSql: string read FLastSql;
    property LastParamsStr: string read FLastParamsStr;
    property LastParamsErr: string read FLastParamsErr;
    //������ ���� �����, ������� ������� ����������������� ���� select
    property LastReceivedFiedNames: TVarDynArray read FLastReceivedFiedNames;
    //������ ���� sql-�������� ��� ���������� �������
    property LogArray: TVarDynArray2 read FLogArray;

    //�����������
    //������� ������ ���� ������
    //���������� ���� �������� ���������� (������ ��� �����, ��� ����������, ��� ������ ".udl"),
    //���� AConnectAfterCreate �� ��� �� �������� ������������
    //����������� �������� ��������� ���� "AConnectionFile"_test, ���� ������� �� ������� ��� ��� �������� �����
    constructor CreateObject(AOwner: TComponent; ADbType: TMyDbType; AConnectionFile: string; AConnectAfterCreate: Boolean = True); virtual;
    //������� ConnectionString ��� oracle � mssql (� ������� �������� ������)
    //������ ������ ������� ���� True (���� ������ ���� �������� ������, �� ������ ��������� �� ���� � ������ False)
    function ReadConnectionFile: Boolean;
    //������������ � ��
    function Connect(MessageIfError: Boolean = True): Boolean;

    {������� ���������� �������� � �������� ������}
    //��� ���������� �������� ������������ ������ ������ QOpen ��� QExecSql, ��������� - �������-�������

    //��������� ������, ��������� ��������� (���� ����)
    //���������� ����� �������, ������  ����������
    //���������� ���������� ����� � �������, ��� -1
    function QOpen(Sql: string; ParamValues: TVarDynArray): Integer;
    //��������� ������
    procedure QClose;
    //��������� ������ �� ����������� ������
    //���������� ����� �������, ���������� ������ ����������
    //���������� ���������� ���������� ����� ��� -1 ��� ������
    function QExecSql(Sql: string; ParamValues: TVarDynArray; ShowErrors: Boolean = True): Integer;
    //��������� ������������ ������ ��� �������� ����������
    function QExecSqlSimple(Sql: string; ShowErrors: Boolean = True): Integer;
    //���������� ���� �� ���������� ���������
    function QSelectId(sequence: string): LongInt;

    function QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; var Res: TNamedArr): Boolean; overload;
    function QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; var Res: TVarDynArray2): Boolean; overload;
    function QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; var Res: TVarDynArray): Boolean; overload;
    function QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; Res: TMemTableEh; ByFieldNames: Boolean = True; ClearTable: Boolean = True): Boolean; overload;
    function QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; Res: TDBGridEh; ByFieldNames: Boolean = True; ClearTable: Boolean = True): Boolean; overload;

    //���������� ������ ������ �������
    //���������� ����� �������, ������ ����������
    //������������ ������ ������ �� ���������� �����, ���� ������ �� ������� �� ����� ������ �� ��� �������� ������� ����� ����!!!
    function QSelectOneRow(Sql: string; ParamValues: TVarDynArray): Variant;
    //��������� ��������� ������� � ���������� ���������� ������
    function QLoadToVarDynArray2(Sql: string; ParamValues: TVarDynArray): TVarDynArray2;
    //��������� ��������� ������� � ���������� ���������� ������, ���������� ������������ ����� ���������� � �� ��������
    function QLoadToRec(Sql: string; ParamValues: TVarDynArray): TNamedArr;
    //��������� ���� ������ � ���������� ���������� ������
    //���� ������ �� �������, ������ ����� ������� �����
    function QLoadToVarDynArrayOneRow(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
    //��������� ���� ���� (�������) �� ���������� ����� � ���������� ���������� ������
    function QLoadToVarDynArrayOneCol(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
    //������ ����������� ������� ������ � ����������
    //���������� ������, ��������� �������,
    //������ ������������ �������� �������� ����� ;, ������� ���������� ������ � ������� - ����������� � ������� (2), � ����� (1) ��� ��������� (0).
    //��������������� ������ ���� �� ������ FieldNames (����� ;), ���� �� �������, ���� ������ �� ��������������
    //���� �������� �� ������ ����� �������, ���� FieldNames='-' �� ��������������� ���� �� ������� ���������� �� ��������
    //������ ���������� ����������� �����
    function QLoadToMemTableEh(Sql: string; ParamValues: TVarDynArray; MemTableEh: TMemTableEh; FieldNames: string = ''; Append: Byte = 0): Integer;
    //��������� ������ � ��������� �� ����������� ���
    //�������� ��������: �-������, �-������ � ������ � ������,�-������ � ������ ������,�-������ � ������ ������ � ������ �������
    //���� ��������� �������� ������ �� ������ ������ ���������� � ����� - ��������,����
    //���� Append=0 �� ������ ����� ��������� ���������
    function QLoadToDBComboBoxEh(Sql: string; ParamValues: TVarDynArray; DBComboboxEh: TDBComboboxEh; ComboBoxMode: TMyControlType; Append: Byte = 0): Integer;
    //��������� ������ �� ������� � TStringList
    //���� ������ ���������� ���� ���� �� ��������� ������ ���, ����� ��������� ���� �������� Key=Value, ������ Value ������� �� ������ (��������) ����
    function QLoadToTStringList(Sql: string; ParamValues: TVarDynArray; StringList: TStringList; Append: Byte = 0): Integer;
    //��������� SQL-������ �� �������/���������/�������� ������
    //���������� ����� ������, ��� �������, ��� ���������,
    //������ ����� ����� ; (����� ������ ������ ���� ���� ����, ���� ����� ���� � ���� ���_����$���),
    //�������� ���������� � ������� (����� ������ ����), ���������� �� ��������� �� ������
    //��������� ����� ��� ���� �������� ���������� ����������, � ��� �������������� ������������ ����
    //� ������ ������� ����� ������������ ��� ��������, � ���� ������ �������� ������� �� ����, � ����������� �������� ��� ������� ���������
    //��� ��, ���� ������������������ �� ��������, �� �������� ��������� � returning ��� ������� ���������, ��������� � ���� id ��� id$i �� id$ir
    //���� �������� ������� = '-' �� 'id', �� ���� �� ������������, � ������� �� ������� ����
    //��� ������� ������ ��������������� ������ �������� (����) ��������, � ������������ �������� ����� ���������
    //� ������ ������ ������������ -1, ����� ��� ������ - �������� ����, ��� ��������� - ���������� ������������ �����
    function QIUD(Mode: string; Table: string; Sequence: string; FieldsSt: string; Values: TVarDynArray; ShowError: Boolean = True): Integer;
    //���������� �������� ��������� Oracle
    //���������� ��� ���������, ��������� (��� � ������ ����� ;, ��� � VarArrayOf), �������� ���� ���������� (��� ����, ��� � VarArrayOf)
    //������ ��������� ������ ����� ; ��������� ������ ������ ��� ���������, ������ - ���������� ������ (I - ��������, B - InOut, O - ��������)
    //������ ������ �� ���������� ���� ���������� (� ������� � ��������), ��� ������ ������ � ������ ������
    function QCallStoredProc(ProcName: string; ParamNames: Variant; ParamValues: TVarDynArray): TVarDynArray;

    {������� ��������� ���������� (bind-����������) �������}

    //�������� ����� ���������� �� ������� sql-�������
    function QGetParamNamesFromSql(Sql: string): string;
    //��������� ��������� �������
    //���������� ����� ����������, ���� ������, ����� ��������� ���� ��������, ��� ��������� ����� ";", ��� �� VarArrayOf
    //����� ���������� ����������� ��� ���������
    //����� ���������� ������ ������� �������� ����������
    function QSetParams(ParamNames: Variant; ParamValues: TVarDynArray): Boolean;
    //������������� ��������� � ADODataDriverEh1
    //���� ������������ �� ������������� $s, $f, $i, $d
    //������������� ��� ������� �������� � ����� � CommandType (�� ��������� s - selectsql)
    //���� IgnoreRemainings=True (�� �� ���������), �� ���������� �� �� ��������� � ������� ��������� �������������, ����� ������ ������
    //������������� ��������� � ADODataDriverEh1
    //���� ������������ �� ������������� $s, $f, $i, $d
    //������������� ��� ������� �������� � ����� � CommandType (�� ��������� s - selectsql)
    //���� IgnoreRemainings=True (�� �� ���������), �� ���������� �� �� ��������� � ������� ��������� �������������, ����� ������ ������
    function QSetParamsEh(ADODataDriverEh1: TADODataDriverEh; ParamNames: Variant; ParamValues: TVarDynArray; CommandType: string = 's'; IgnoreRemainings: Boolean = False): Boolean;

    {������ � ������������}

    //��������� ����������
    //���� ����������� APackageMode, ���������� �������� �����
    //(� ������� ������� ��������� ����������� ����� ������� ����, � ���� �� ��� ���������� ��������� ���������� �� ���������)
    //���� ���� �������� ����������, �� ������� ��!
    function QBeginTrans(APackageMode: Boolean = False; ShowErrors: Boolean = True): Boolean;
    //��������� ��� ���������� ����������
    //���� �������� �����, �� ����� ��������/������ ������������ ��� ����������� and Commit
    //����� ��������� ������� ������� ��������� ����������
    //���� ��� �������� ����������, ������ � False
    function QCommitOrRollback(Commit: Boolean = True; ShowErrors: Boolean = True): Boolean;
    //�������� ����������
    function QCommitTrans: Boolean;
    //���������� ����������
    function QRollbackTrans: Boolean;

    {��������������� �������}

    //������ ������ ��� ���� ���� nameindb as fieldname$s400
    function ParseFieldNameFull(FieldNameFull: string; var FieldWithMod: string; var Alias: string; var DbFieldName: string; var FieldType: string; var DataType: TDataType; var DataLength: Integer): Boolean;
    //���������� ��������� ����������� �� ���� ������
    function QGetDataTypeAsChar(DataType: TDataType): Char;
    //���������� ��������� ����������� ��������� �� ��� ���������� ��������
    //���� �� ����� ���������� ''
    function QGetParamTypeCharFromName(ParamName: string): string;
    //������� ����� ���, �������������� � QIUD, � ����������� �� ������ ����������� ����
    function QFModeToIUD(fMode: TDialogType): char;
    //������� ���������� ���������� �������� �����
    function QRowsAffected: Integer;
    //���������� �������� ���������� ���������� ������� � �������
    //��������� ����� ���� ����������� � ������ ����� ; ��� ��������
    //����� ����������� ��������� � �������������� $ ��� ��� ���
    function QGetReturnValues(ParamNames: Variant): Variant;
    //��������� �� ������ ����� ����� ; � ����� ������� ������ ���-������� ��� ������/������/������/�����
    //���� ���������� ������ ������� ����� ��������� � ������ �����
    //���� ����� ���� �������� � �������������, � ���� ������ � �������� ���� � ������� ������������ ����� ����� ����� �� $, ������ ���������� ���
    function QSIUDSql(Mode: string; Table, FieldsSt: string): string;

    {������� �����������}

    //��������� ��� ��������� ������ �������� � ���
    function SetEnableLog(Enable: Boolean = True): Boolean;
    //������ ������� � ���������� � ������ ����
    //����� ������������� ��������� �������, � ��� �������� ������� ���� �������� ��� ���������� (���������� ������)
    procedure ToLog(Source, Query, Params, ErrMsg: string);
    //��������� � ��� ������ �� AdoDataDriverEh ��� ���������� �������
    procedure ToLogEh(Command: TCustomSQLCommandEh; ErrMsg: string = '');
  end;

var
  myDB: TmyDB;

implementation

uses
  uMessages, uForms, uFrmXGsrvSqlMonitor;


{%CLASSGROUP 'Vcl.Controls.TControl'}


{$R *.dfm}


constructor TmyDB.CreateObject(AOwner: TComponent; ADbType: TMyDbType; AConnectionFile: string; AConnectAfterCreate: Boolean = True);
//�����������
//������� ������ ���� ������
//���������� ���� �������� ���������� (������ ��� �����, ��� ����������, ��� ������ ".udl"),
//���� AConnectAfterCreate �� ��� �� �������� ������������
//����������� �������� ��������� ���� "AConnectionFile"_test, ���� ������� �� ������� ��� ��� �������� �����
begin
  inherited Create(AOwner);
  FDbType := ADbType;
  FConnectionFile := AConnectionFile;
  ReadConnectionFile;
  FConnected := False;
  if FErrorState <> '' then
    Exit;
  if AConnectAfterCreate then
    Connect;
  FIsLogEnabled := True;
end;

function TmyDB.ReadConnectionFile: Boolean;
//������� ConnectionString ��� oracle � mssql (� ������� �������� ������)
//������ ������ ������� ���� True (���� ������ ���� �������� ������, �� ������ ��������� �� ���� � ������ False)
var
  f: TIniFile;
  st: string;
const
  FileExt = '.udl';
begin
  Result := False;
  FConnectionString := '';
  FCurrentShema := '';
  FConnectionFileFull := '';
  try
    f := nil;
    st := Module.ExePath + '\' + FConnectionFile + '_test' + FileExt;
    if FileExists(st) then begin
      f := TIniFile.Create(st);
      FTestDB := True;
    end
    else begin
      st := Module.ExePath + '\' + FConnectionFile + '' + FileExt;
      if FileExists(st) then begin
        f := TIniFile.Create(st);
        FTestDB := False;
      end
    end;
    FConnectionString := 'Provider=' + f.ReadString('oledb', 'Provider', '');
    FCurrentShema := copy(ConnectionString, pos(';User ID=', ConnectionString) + 9, 1000);
    FCurrentShema := copy(CurrentShema, 1, pos(';', CurrentShema) - 1);
    FConnectionFileFull := st;
    Result := True;
    f.Free;
  except //on E: Exception do Application.ShowException(E);
    if not Result then
      FErrorState := '�� ������� ��������� ���� �������� ���������� � ����� ������.';
    f.Free;
  end;
{  if FileExists(ExtractFilePath(ParamStr(0)) + '\parsec.udl') then begin
    f:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + '\parsec.udl');
    ParsecConnectionString:='Provider=' + f.ReadString('oledb', 'Provider', '');
    MyData.CnParsec.ConnectionString:= ParsecConnectionString;
    MyData.CnParsec.LoginPrompt:= False;
    MyData.CnParsecEh.InlineConnection.ConnectionString:= ParsecConnectionString;
    MyData.CnParsecEh.InlineConnection.LoginPrompt:= False;
    f.Free;
  end;}
end;

function TmyDB.Connect(MessageIfError: Boolean = True): Boolean;
//������������ � ���� ������
//���� ��� ����������� � Oracle, �� � ������ ������ �����������, ������� ���� � ��������� ���������
//� ������ ������� �� ������� �������� ���������, ������� � Result := False
var
  i: Integer;
  ok: Boolean;
begin
  if FDbType = mydbtOra then begin
  i := 0;
  repeat
    try
    try
      ok := False;
      if not AdoConnection.Connected then begin
        AdoConnection.ConnectionString := ConnectionString;
        AdoConnection.LoginPrompt := False;
        try
          AdoConnection.Connected := True;
        except
        end;
      end;
      if AdoConnectionProviderEh.Connection = nil then begin
        if AdoConnection.Connected and not AdoConnectionProviderEh.InlineConnection.Connected then begin
          AdoConnectionProviderEh.InlineConnection.ConnectionString := ConnectionString;
          AdoConnectionProviderEh.InlineConnection.LoginPrompt := False;
          try
            AdoConnectionProviderEh.InlineConnection.Connected := True;
          except
          end;
        end;
      end;
      ok := True;
    except
    end;
    finally
    if (not ok) and (not AfterProgramStart) then
      if MessageIfError
        then FrmXDmsgNoConnection.ShowModal;
    end;
    inc(i);
  until (GetConnectState) or (i > 0);
  Result := ok;
  end
  else begin
    try
      Result := False;
      if not AdoConnection.Connected then begin
        AdoConnection.ConnectionString := ConnectionString;
        AdoConnection.LoginPrompt := False;
          AdoConnection.Connected := True;
      end;
      if AdoConnectionProviderEh.Connection = nil then begin
        if AdoConnection.Connected and not AdoConnectionProviderEh.InlineConnection.Connected then begin
          AdoConnectionProviderEh.InlineConnection.ConnectionString := ConnectionString;
          AdoConnectionProviderEh.InlineConnection.LoginPrompt := False;
            AdoConnectionProviderEh.InlineConnection.Connected := True;
        end;
      end;
      Result := True;
    except
    end;
  end;
end;

function TmyDB.GetConnectState: Boolean;
//���������� ������ ����������
//������ ���� ���������� AdoDriver (� AdoDriverEh � ������ AdoDriverEh.Connection = null)
begin
  Result := AdoConnection.Connected and ((AdoConnectionProviderEh.Connection <> nil) or (AdoConnectionProviderEh.InlineConnection.Connected));
end;

{================== ������� ����������� =======================================}

function TmyDB.AdoConnectionProviderEhExecuteCommand(SQLDataDriver: TCustomSQLDataDriverEh; Command: TCustomSQLCommandEh; var Cursor: TDataSet; var FreeOnEof, Processed: Boolean): Integer;
var
  st, st0, ErrMsg, st1, st2: string;
  p: TParams;
  v: Variant;
  i, j: Integer;
begin
//MyInfoMessage('!!!');
  st := Command.CommandText.text;
  try
    FLastSql := st;
    FLastParamsStr := '';
    p := Command.GetParams;
    for i := 0 to p.count - 1 do begin
      S.ConcatStP(FLastParamsStr, '[' + p[i].Name + ']=' + S.iif(p[i].Value = null, '<Null>', VarToStr(p[i].Value)), sLineBreak);
    end;

    st0 := st;
  //���������� ������ � ������ EhLib, ��� ������ Nextval ���� Curval
    if DbType = mydbtOra then
      if Pos('.curval ', st) > 0 then
        Command.CommandText.text := StringReplace(st, '.curval ', '.nextval ', []);
  //���������� ��������, ����� ��� ������������ �������� ����� � �������� �� ������ �������
  //���� ���� �������� �� � ������������ ��������� ������
  //��� ��������� ������ ��� ���������� �������� ������� � ���� 12.0000
  //� ������ ������ �������� �������� :ID � ������ �������� �� ��� ��������, ��������
  //��� ��� �� �������� �� ����������� ���� ��������� ��������������� � ���������� �����������,
  //�� ������� �������� ��� ��� ��   MemTableEh1.FieldDefs[MemTableEh1.FieldDefs.IndexOf('id')].DataType:=ftInteger;
  //(MemTableEh1.FieldByName('id').DataType ��� ���� �������)
  //MemTableEh1.FieldDefs.Add('id', ftInteger, 0, False);  MemTableEh1.Mth.CreateTableGrid; ������� � ������ ����� ��
  //� ������� ����������� � ����������� ����� (������� �������� ���, ��������� ��������, ������� � �������� ����� ��������)

    if (pos(':ID', st) > 1) and (pos('where', st) > 1) and (pos(':ID', st) > pos('where', st)) then begin
      st := Command.FinalCommandText.text;
      p := Command.GetParams;
//    v:=p.ParamByName('ID').value;
      v := p.ParamByName('ID').value;
      Command.CommandText.text := StringReplace(st, ':ID', IntToStr(Round(v)), []);
      p.Delete(p.ParamByName('ID').Index);
//    p.Delete(p.ParamByName('ID').Index);
//Command.CommandText.text:= StringReplace(st, ':ID', ':id$i', []);
//    p:=command.GetParams;
//    command.GetParams.ParamByName('ID').DataType:=ftFloat;
//    command.GetParams.ParamByName('ID').value:=trunc(v);
{    v:=p.ParamByName('ID').value;
    Command.CommandText.text:= StringReplace(st, ':ID', IntToStr(Round(v)), []);
    p.Delete(p.ParamByName('ID').Index);}
  //  p.ParamByName('ID').value:=IntToStr(Round(v));
  //  p.ParamByName('ID').AsString:='''' + IntToStr(Round(v)) + '''';
    end;
{  p:=command.GetParams;
  for i:=0 to p.Count - 1 do begin
    if p[i].Name  =  'dt_beg' then p[i].DataType:=ftDate;
  end;}
  //AppendSQLInfoEh(Command);
  //IsOraTreat:=True;
    ErrMsg := '';
    Result := AdoConnectionProviderEh.DefaultExecuteCommand(SQLDataDriver, Command, Cursor, FreeOnEof, Processed);
  except
    on E: Exception do begin
      ToLogEh(Command, E.Message);
      //Errors.SetParam('' ,'', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
  ToLogEh(Command, ErrMsg);
  //IsOraTreat:=False;
  if Command.CommandText.text <> st0 then
    Command.CommandText.text := st0;
end;

procedure TmyDB.AdoConnectionWillExecute(Connection: TADOConnection; var CommandText: WideString; var CursorType: TCursorType; var LockType: TADOLockType; var CommandType: TCommandType; var ExecuteOptions: TExecuteOptions; var EventStatus: TEventStatus; const Command: _Command; const Recordset: _Recordset);
begin
  //
end;

procedure TmyDB.AdoQueryBeforeOpen(DataSet: TDataSet);
begin
//  FLastSQL:=AdoQuery.SQL.Text;
end;


{=========================== ��������������� ������� ==========================}

function TmyDB.QGetDataTypeAsChar(DataType: TDataType): Char;    //++������
//���������� ��������� ����������� �� ���� ������
begin
  case DataType of
    ftString:
      Result := 's';
    ftInteger:
      Result := 'i';
    ftFloat:
      Result := 'f';
    ftBcd, ftFMTbcd:    //��� ���� � Delphi ��� �������� ����� � ������������� ���������
      Result := 'f';
    ftDate:
      Result := 'd';
    ftDateTime:
      Result := 'd';
  else
    Result := 's';
  end;
end;

function TmyDB.ParseFieldNameFull(FieldNameFull: string; var FieldWithMod: string; var Alias: string; var DbFieldName: string; var FieldType: string; var DataType: TDataType; var DataLength: Integer): Boolean;
//������ ������ ��� ���� ���� "data as fieldname$s400"
//FieldNameFull = fieldname$s400, alias = ieldname, DbFieldName = data
var
  i: Integer;
  va1, va: TVarDynArray;
  st: string;
begin
  try
  Result:= False;
  va1:= A.Explode(FieldNameFull, ' as ');
  FieldWithMod := va1[High(va1)];
  if High(va1) > 1 then Exit;
  if High(va1) > 0 then DbFieldName:= va1[0];
  va:= A.Explode(FieldWithMod, '$');
  if High(va1) = 0 then DbFieldName:= va[0];
  Alias:= va[0];
  FieldType:= '';
  DataType:= ftUnknown;
  DataLength:= 0;
  if (Length(va) <> 2)
    then begin Result:= True; Exit; end;
  FieldType:=LowerCase(va[1])[1];
  if (FieldType = '') or not (FieldType[1] in ['s', 't', 'd', 'h', 'i', 'f', 'c']) then Exit;
  DataLength:= StrToIntDef(Copy(va[1], 2), -1);
  if DataLength = -1 then begin
    if FieldType[1] in ['s', 't'] then DataLength:=4000 else DataLength:=0;
  end;
  case FieldType[1] of
    's', 't':  DataType:= ftString;
    'i':  DataType:= ftInteger;
    'f':  DataType:= ftFloat;
    'd':  DataType:= ftDateTime;
  end;
  finally
  end;
  Result:= True;
end;

function TmyDB.QFModeToIUD(fMode: TDialogType): char;
//������� ����� ���, �������������� � QIUD, � ����������� �� ������ ����������� ����
begin
  Result := '-';
  case fMode of
    fAdd, fCopy:
      Result := 'i';
    fDelete:
      Result := 'd';
    fEdit:
      Result := 'u';
  end;
end;

function TmyDB.QGetParamTypeCharFromName(ParamName: string): string;
//���������� ��������� ����������� ��������� �� ��� ���������� �������� (�������� � ������� ��������)
//������ ��� ������ ������������� (1� - ��� 's','t','d','h','i','f','c',  2� - R = ������������
//���� �� ����� ���������� 's  '
var
  sa: TStringDynArray;
begin
  try
    Result := 's  ';
    sa := A.ExplodeS(ParamName, '$');
    if (Length(sa) < 2) or (Length(sa[1]) < 1) then
      Exit;
    Result := LowerCase(sa[1]);
    if (Result <> '') and not (Result[1] in ['s', 't', 'd', 'h', 'i', 'f', 'c']) then begin
      Errors.SetParam('', '�������� ��� ��������� ($) � �������', myerrTypeDB);
      raise Exception.Create('�������� ��� ��������� ($) � �������');
    end;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
end;

(*
function TmyDB.QGetParamNamesFromSql(Sql: string): string;
//������� ��������� � ������ ������� (���������� � :, ������� �� ���������� ���� � ������� $),
//� ���������� ������ �� ���� ���������� ����� ����� � �������
var
  i, j: Integer;
  sa: TStringDynArray;
  st: string;
begin
  try
    sa := A.ExplodeS(Sql, ':');
    Result := '';
    for i := 1 to High(sa) do begin
      st := '';
      for j := 1 to Length(sa[i]) do
        if (sa[i][j] in EngChars_) or (sa[i][j] in ['0'..'9']) or (sa[i][j] = '$') then
          st := st + sa[i][j]
        else
          Break;
      S.ConcatStP(Result, st, ';');
    end;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
end;
*)

function TmyDB.QGetParamNamesFromSql(Sql: string): string;
//������� ��������� � ������ ������� (���������� � :, ������� �� ���������� ���� � ������� $),
//� ���������� ������ �� ���� ���������� ����� ����� � �������
var
  i, j: Integer;
  sa: TStringDynArray;
  ParamList: TParams;
  st: string;
begin
  try
    ParamList := TParams.Create(nil);
    ParamList.ParseSQL(SQL, True); //Force to create the params from the SQL
    for i := 0 to ParamList.Count - 1 do
      S.ConcatStP(Result, ParamList[i].Name, ';');
  finally
    ParamList.Free;
  end;
end;

function TmyDB.QSIUDSql(Mode: string; Table, FieldsSt: string): string;
//��������� �� ������ ����� ����� ; � ����� ������� ������ ���-������� ��� ������/������/������/�����
//���� ���������� ������ ������� ����� ��������� � ������ �����
//���� ����� ���� �������� � �������������, � ���� ������ � �������� ���� � ������� ������������ ����� ����� ����� �� $, ������ ���������� ���
var
  Fields, FieldsWType: TVarDynArray;
  i, j: Integer;
  St, St1: string;
begin
  A.ExplodeP(FieldsSt, ';', Fields);
  FieldsWType := copy(Fields);
  for i := 0 to High(Fields) do begin
    if Pos('$', Fields[i]) > 0 then
      Fields[i] := Copy(Fields[i], 1, Pos('$', Fields[i]) - 1);
  end;
  Mode := UpCase(Mode[1]);
  case Mode[1] of
    'D':
      begin
        St := 'delete from ' + Table + ' where ' + Fields[0] + ' = :' + FieldsWType[0] + '';
      end;
    'S':
      begin
        St := '';
        for i := 0 to High(Fields) do begin
          S.ConcatStP(St, Fields[i], ', ');
        end;
        St := 'select ' + St + ' from ' + Table + ' where ' + Fields[0] + ' = :' + FieldsWType[0];
      end;
    'I':
      begin
        St := '';
        St1 := '';
        for i := 0 to High(Fields) do begin
          S.ConcatStP(St, Fields[i], ', ');
          S.ConcatStP(St1, ':' + FieldsWType[i], ', ');
        end;
        St := 'insert into ' + Table + '(' + St + ') values (' + St1 + ')';
      end;
    'U':
      begin
        St := '';
        for i := 1 to High(Fields) do begin
          S.ConcatStP(St, Fields[i] + '= :' + FieldsWType[i], ', ');
        end;
        St := 'update ' + Table + ' set ' + St + ' where ' + Fields[0] + ' = :' + FieldsWType[0];
      end;
    'Q':
      begin
        St := '';
        for i := 0 to High(Fields) do begin
          S.ConcatStP(St, Fields[i] + '= :' + FieldsWType[i], ', ');
        end;
        St := 'update ' + Table + ' set ' + St;
      end;
    'A':
      begin
        St := '';
        for i := 0 to High(Fields) do
          S.ConcatStP(St, Fields[i], ', ');
        St := 'select ' + St + ' from ' + Table;
      end;
    'N':
      begin
        St := '';
        for i := 0 to High(Fields) do
          S.ConcatStP(St, Fields[i], ', ');
        St := 'select ' + St + ' from ' + Table + ' where 0=1';
      end;
  end;
  Result := St;
end;

function TmyDB.QSetParams(ParamNames: Variant; ParamValues: TVarDynArray): Boolean;
//��������� ��������� �������
//���������� ����� ����������, ���� ������, ����� ��������� ���� ��������, ��� ��������� ����� ";", ��� �� VarArrayOf
//����� ���������� ����������� ��� ���������
//����� ���������� ������ ������� �������� ����������
var
  i, j: Integer;
  st, st1, st2: string;
  v: Variant;
  ParamNamesA: TVarDynArray;
  CurrParamName, CurrParamValue, CurrParamType: string;
begin
//st :=  AdoQuery.SQL.Text;
  Result := True;
  FLastParamsStr := '';
  FLastParamsErr := '';
  ParamNamesA := A.ExplodeV(ParamNames, ';');
  if (Length(ParamNamesA) = 0) or (ParamNamesA[0] = '') then
    Exit;
  for i := 0 to Max(High(ParamNamesA), High(ParamValues)) do begin
    if i <= High(ParamNamesA) then
      st1 := VarToStr(ParamNamesA[i])
    else
      st1 := '<Unknown>';
    if i <= High(ParamValues) then
      st2 := S.IIf(VarIsNull(ParamValues[i]), '<Null>', VarToStr(ParamValues[i]))
    else
      st2 := '<Unknown>';
    S.ConcatStP(FLastParamsStr, '[' + st1 + ']=' + st2, sLineBreak);
  end;
  try
    Result := False;
    if (High(ParamNamesA)) = (High(ParamValues)) then begin
      for i := Low(ParamNamesA) to High(ParamNamesA) do
      try
        if ParamNamesA[i] <> '' then begin
          CurrParamName := ParamNamesA[i];
          CurrParamValue := VarToStr(ParamValues[i]);
          CurrParamType := QGetParamTypeCharFromName(ParamNamesA[i]);
          case CurrParamType[1] of
            's', 't':
              AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftString;
            'd':
              AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftDate;
            'h':
              AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftDateTime;
            'i':
              AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftInteger;
            'f':
              AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftFloat;
            'c':
              AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftCurrency;
          end;
          if CurrParamType[2] = 'r' then
            AdoQuery.Parameters.ParamByName(ParamNamesA[i]).Direction := pdReturnValue
          else
            AdoQuery.Parameters.ParamByName(ParamNamesA[i]).Direction := pdInput;
          AdoQuery.Parameters.ParamByName(ParamNamesA[i]).Attributes := [paNullable];
          //������ ������ ������ ����������� � null!!!  2025-07-28
          AdoQuery.Parameters.ParamValues[ParamNamesA[i]] := S.NullIfEmpty(ParamValues[i]);
        end;
      except
        on E: Exception do begin
          if FIsLogEnabled then
            FLastParamsErr := '������ ��������� ��������� ������� (' + CurrParamName + ' = "' + CurrParamValue + '")'#13#10'*';
          Errors.SetParam('', FLastParamsErr, myerrTypeDB);
          Application.ShowException(E);
          FLastParamsErr := '';
        end;
      end;
    end
    else begin
      FLastParamsErr := '������ ��������� ���������� ������� (�� ��������� ���������� ���������� � ����������� ����������)';
      Errors.SetParam('', FLastParamsErr, myerrTypeDB);
      raise Exception.Create(FLastParamsErr);
      FLastParamsErr := '';
    end;
    Result := True;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
      FLastParamsErr := E.Message;
    end;
  end;
end;

function TmyDB.QGetReturnValues(ParamNames: Variant): Variant;
//���������� �������� ���������� ���������� ������� � �������
//��������� ����� ���� ����������� � ������ ����� ; ��� ��������
//����� ����������� ��������� � �������������� $ ��� ��� ���
var
  i, j: Integer;
  v: Variant;
  ParamNamesA, ParamValuesA: TVarDynArray;
  b: Boolean;
begin
  Result := null;
  try
    ParamNamesA := A.ExplodeV(ParamNames, ';');
    if (Length(ParamNamesA) = 0) or (ParamNamesA[0] = '') then
      Exit;
    for i := 0 to High(ParamNamesA) do begin
      for j := 0 to AdoQuery.Parameters.Count - 1 do begin
        b := False;
        if (ParamNamesA[i] = AdoQuery.Parameters[j].Name) or (Pos(ParamNamesA[i] + '$', AdoQuery.Parameters[j].Name) = 1) then begin
          ParamValuesA := ParamValuesA + [AdoQuery.Parameters[j].Value];
          b := True;
          Break;
        end;
      end;
      if not b then
        Break;
    end;
    if not b then begin
      Errors.SetParam('', '�� ����� ����� ����������, ������������ �� ������� /�� ��� �������/ (' + A.Implode(ParamNamesA, ';') + ')', myerrTypeDB);
      raise Exception.Create('�� ����� ����� ����������, ������������ �� ������� /�� ��� �������/ (' + A.Implode(ParamNamesA, ';') + ')');
    end;
    Result := ParamValuesA;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
end;

function TmyDB.QRowsAffected: Integer;
//������� ���������� ���������� �������� �����
begin
  Result := AdoQuery.RowsAffected;
  FRowsAffected := Result;
end;


{================= ������� ���������� �������� � �������� ������ ==============}

function TmyDB.QExecSql(Sql: string; ParamValues: TVarDynArray; ShowErrors: Boolean = True): Integer;
//��������� ������ �� ����������� ������
//���������� ����� �������, ���������� ������ ����������
//���������� ���������� ���������� ����� ��� -1 ��� ������
var
  err: Boolean;
  ErrMsg: string;
begin
  if PackageMode = -1 then
    Exit;
  Result := -1;
  ErrMsg := '';
  FLastSql := Sql;
  try
    AdoQuery.Close;
    AdoQuery.SQL.Text := Sql;
    if not QSetParams(QGetParamNamesFromSql(Sql), ParamValues) then begin
      ToLog('Ado', Sql, FLastParamsStr, FLastParamsErr);
      Exit;
    end;
    Result := AdoQuery.ExecSQL;
  except
    on E: Exception do begin
      Errors.SetParam('', '*', myerrTypeDB, ShowErrors);
      ErrMsg := E.Message;
      Application.ShowException(E);
    end;
  end;
  ToLog('Ado', Sql, FLastParamsStr, ErrMsg);
  if (PackageMode = 1) and (Result < 0) then
    FPackageMode := -1;
end;

function TmyDB.QOpen(Sql: string; ParamValues: TVarDynArray): Integer;
//��������� ������, ��������� ��������� (���� ����)
//���������� ����� �������, ������  ����������
//���������� ���������� ����� � �������, ��� -1
var
  i: Integer;
  b: Boolean;
begin
  Result := -1;
  try
    AdoQuery.Close;
    AdoQuery.SQL.Text := Sql;
    FLastSql := Sql;
    if not QSetParams(QGetParamNamesFromSql(Sql), ParamValues) then begin
      ToLog('Ado', Sql, FLastParamsStr, FLastParamsErr);
      Exit;
    end;
    AdoQuery.Open;
    Result := AdoQuery.RecordCount;
  except
    on E: Exception do begin
      Errors.SetParam('', '*', myerrTypeDB);
      AdoQuery.Close;
      Application.ShowException(E);
    end;
  end;
  ToLog('Ado', Sql, FLastParamsStr, FLastParamsErr);
end;

procedure TmyDB.QClose;
//��������� ������
begin
  try
    AdoQuery.Close;
  except
  end;
end;

function TmyDB.QExecSqlSimple(Sql: string; ShowErrors: Boolean = True): Integer;
//��������� sql-������� ��� ����������; ���������� ���������� ���������� ����� ��� -1 ��� ������
begin
  Result := QExecSql(Sql, [], ShowErrors);
end;

function TmyDB.QIUD(Mode: string; Table: string; Sequence: string; FieldsSt: string; Values: TVarDynArray; ShowError: Boolean = True): Integer;
//��������� SQL-������ �� �������/���������/�������� ������
//���������� ����� ������, ��� �������, ��� ���������,
//������ ����� ����� ; (����� ������ ������ ���� ���� ����, ���� ����� ���� � ���� ���_����$���),
//�������� ���������� � ������� (����� ������ ����), ���������� �� ��������� �� ������
//��������� ����� ��� ���� �������� ���������� ����������, � ��� �������������� ������������ ����
//� ������ ������� ����� ������������ ��� ��������, � ���� ������ �������� ������� �� ����, � ����������� �������� ��� ������� ���������
//��� ��, ���� ������������������ �� ��������, �� �������� ��������� � returning ��� ������� ���������, ��������� � ���� id ��� id$i �� id$ir
//���� �������� ������� = '-' �� 'id', �� ���� �� ������������, � ������� �� ������� ����
//��� ������� ������ ��������������� ������ �������� (����) ��������, � ������������ �������� ����� ���������
//� ������ ������ ������������ -1, ����� ��� ������ - �������� ����, ��� ��������� - ���������� ������������ �����
var
  Fields: TVarDynArray;
  Params: Variant;
  i, j: Integer;
  St, St1, sql: string;
  id: longint;
  AutoId: Boolean;
begin
  if PackageMode = -1 then
    Exit;
  A.ExplodeP(FieldsSt, ';', Fields);
  Mode := UpperCase(Mode);
  sql := QSIUDSql(Mode, Table, FieldsSt);
  if Mode = 'U' then begin
    Params := VarArrayCreate([0, High(Fields)], varVariant);
    for i := 1 to high(Fields) do
      Params[i - 1] := Values[i];
    Params[High(Fields)] := Values[0];
    Result := QExecSql(sql, Params, ShowError);
    Exit;
  end;
  if Mode = 'I' then begin
    AutoId := not ((UpperCase(Sequence) = 'ID') or (Sequence = '-'));
    Params := VarArrayCreate([0, High(Fields) + S.IIf((Sequence = ''), 1, 0)], varVariant);
    for i := 1 to high(Fields) do
      Params[i] := Values[i];
    if AutoId and (Sequence <> '') then begin
      id := QSelectId(Sequence);
      Params[0] := id;
    end;
    if not AutoId then begin
      id := Values[0];
      Params[0] := id;
    end;
// Sys.SaveTextToFile('r:\1', sql);
// Sys.SaveTextToFile('r:\2', A.Implode(Params, '; '));
    Result := QExecSql(sql + S.IIf(Sequence = '', ' returning ' + A.ExplodeV(Fields[0], '$')[0] + ' into :' + A.ExplodeV(Fields[0], '$')[0] + '$ir', ''), Params, ShowError);
    if Result >= 0 then
      if Sequence <> '' then
        Result := id
      else
        Result := QGetReturnValues(A.ExplodeV(Fields[0], '$')[0] + '$ir')[0];
    Exit;
  end;
  if Mode = 'D' then begin
    Params := VarArrayCreate([0, 0], varVariant);
    Params[0] := Values[0];
    Result := QExecSql(sql, Params, ShowError);
    Exit;
  end;
end;

function TmyDB.QSelectOneRow(Sql: string; ParamValues: TVarDynArray): Variant;
//���������� ������ ������ �������
//���������� ����� �������, ������ ����������
//������������ ������ ������ �� ���������� �����, ���� ������ �� ������� �� ����� ������ �� ��� �������� ������� ����� ����!!!
var
  i: Integer;
begin
  Result := VarArrayOf([]);
  FLastReceivedFiedNames := [];
  try
    AdoQuery.Close;
    AdoQuery.SQL.Text := Sql;
    if FIsLogEnabled then
      FLastSql := Sql;
    if not QSetParams(QGetParamNamesFromSql(Sql), ParamValues) then begin
      ToLog('Ado', Sql, FLastParamsStr, FLastParamsErr);
      Exit;
    end;
    AdoQuery.Open;
    Result := VarArrayCreate([0, AdoQuery.FieldCount - 1], varVariant);
    if not AdoQuery.EOF then begin
      if Length(FLastReceivedFiedNames) = 0 then
        for i := 0 to AdoQuery.FieldCount - 1 do
          FLastReceivedFiedNames := FLastReceivedFiedNames + [AdoQuery.Fields[i].FieldName];
      for i := 0 to AdoQuery.FieldCount - 1 do
        Result[i] := AdoQuery.Fields[i].AsVariant
    end
    else
      for i := 0 to AdoQuery.FieldCount - 1 do
        Result[i] := Null;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
  ToLog('Ado', Sql, FLastParamsStr, FLastParamsErr);
  QClose;
end;

function TmyDB.QLoadToVarDynArray2(Sql: string; ParamValues: TVarDynArray): TVarDynArray2;
//��������� ��������� ������� � ���������� ���������� ������
var
  res, i, j: Integer;
begin
  Result := [];
  FLastReceivedFiedNames := [];
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  while not AdoQuery.EOF do begin
    SetLength(Result, Length(Result) + 1);
    SetLength(Result[High(Result)], AdoQuery.FieldCount);
    if Length(FLastReceivedFiedNames) = 0 then
      for i := 0 to AdoQuery.FieldCount - 1 do
        FLastReceivedFiedNames := FLastReceivedFiedNames + [AdoQuery.Fields[i].FieldName];
    for i := 0 to AdoQuery.FieldCount - 1 do
      Result[High(Result)][i] := AdoQuery.Fields[i].AsVariant;
    AdoQuery.Next;
  end;
  QClose;
end;


function TmyDB.QLoadToRec(Sql: string; ParamValues: TVarDynArray): TNamedArr;
//��������� ��������� ������� � ���������� ���������� ������, ���������� ������������ ����� ���������� � �� ��������
var
  res, i, j: Integer;
begin
  Result.Clear;
  FLastReceivedFiedNames := [];
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  while not AdoQuery.EOF do begin
    SetLength(Result.V, Length(Result.V) + 1);
    SetLength(Result.V[High(Result.V)], AdoQuery.FieldCount);
    if Length(FLastReceivedFiedNames) = 0 then
      for i := 0 to AdoQuery.FieldCount - 1 do
        FLastReceivedFiedNames := FLastReceivedFiedNames + [AdoQuery.Fields[i].FieldName];
    for i := 0 to AdoQuery.FieldCount - 1 do
      Result.V[High(Result.V)][i] := AdoQuery.Fields[i].AsVariant;
    AdoQuery.Next;
  end;
  Result.FFull := FLastReceivedFiedNames;
  Result.F := FLastReceivedFiedNames;
  for j := 0 to High(Result.F) do begin
  i := Pos('$', Result.F[j]);
  if i > 0 then
    Result.F[j] := Copy(Result.F[j], 1, i - 1);
  end;
  QClose;
end;

function TmyDB.QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; var Res: TNamedArr): Boolean;
var
  va, va1: TVarDynArray;
  SqlM: string;
begin
  Result := False;
  try
    if pos(';', Sql) > 0 then begin
      va := A.Explode(Sql, ';');
      va1 := Copy(va, 2);
      Sql := QSIUDSql(S.IIf(va[1] = '', 's', 'a'),va1[0],  A.Implode(va1, ';')) + S.IIfStr(va[1] <> '', ' ' + va[1]);
    end;
  Res := QLoadToRec(Sql, ParamValues);
  except
    on E: Exception do begin
      Errors.SetErrorCapt(Self.Name, 'O����� ��� �������� ������ �� ��');
      Application.ShowException(E);
      Errors.SetErrorCapt;
    end;
  end;
  Result := Res.Count > 0;
end;

function TmyDB.QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; var Res: TVarDynArray2): Boolean;
var
  na: TNamedArr;
begin
  Result := QLoadFromQuery(Sql, ParamValues, na);
  Res := na.V;
end;

function TmyDB.QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; var Res: TVarDynArray): Boolean;
var
  na: TNamedArr;
begin
  Result := QLoadFromQuery(Sql, ParamValues, na);
  if na.Count > 0 then
    Res := A.VarDynArray2RowToVD1(na.V, 0)
  else
    Res := [null];
end;

function TmyDB.QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; Res: TMemTableEh; ByFieldNames: Boolean = True; ClearTable: Boolean = True): Boolean;
var
  na: TNamedArr;
begin
  Result := QLoadFromQuery(Sql, ParamValues, na);
  Mth.LoadMemTableFromNamedArray(Res, na, ByFieldNames, ClearTable);
end;

function TmyDB.QLoadFromQuery(Sql: string; ParamValues: TVarDynArray; Res: TDBGridEh; ByFieldNames: Boolean = True; ClearTable: Boolean = True): Boolean;
var
  na: TNamedArr;
begin
  Result := QLoadFromQuery(Sql, ParamValues, na);
  Mth.LoadGridFromNamedArray(Res, na, ByFieldNames, ClearTable);
end;




function TmyDB.QLoadToVarDynArrayOneRow(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
//��������� ���� ������ � ���������� ���������� ������
var
  res, i, j: Integer;
  FName: string;
begin
  Result := [];
  FLastReceivedFiedNames := [];
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  if not AdoQuery.EOF then begin
    SetLength(Result, AdoQuery.FieldCount);
    for i := 0 to AdoQuery.FieldCount - 1 do begin
      Result[i] := AdoQuery.Fields[i].AsVariant;
      FLastReceivedFiedNames := FLastReceivedFiedNames + [AdoQuery.Fields[i].FieldName];
    end;
  end;
  QClose;
end;

function TmyDB.QLoadToVarDynArrayOneCol(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
//��������� ���� ���� (�������) �� ���������� ����� � ���������� ���������� ������
var
  res, i, j: Integer;
  FName: string;
begin
  Result := [];
  FLastReceivedFiedNames := [];
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  while not AdoQuery.EOF do begin
    if Length(FLastReceivedFiedNames) = 0 then
      FLastReceivedFiedNames := [AdoQuery.Fields[0].FieldName];
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := AdoQuery.Fields[0].AsVariant;
    AdoQuery.Next;
  end;
  QClose;
end;

function TmyDB.QLoadToMemTableEh(Sql: string; ParamValues: TVarDynArray; MemTableEh: TMemTableEh; FieldNames: string = ''; Append: Byte = 0): Integer;
//������ ����������� ������� ������ � ����������
//���������� ������, ��������� �������,
//������ ������������ �������� �������� ����� ;, ������� ���������� ������ � ������� - ����������� � ������� (2), � ����� (1) ��� ��������� (0).
//��������������� ������ ���� �� ������ FieldNames (����� ;), ���� �� �������, ���� ������ �� ��������������
//���� �������� �� ������ ����� �������, ���� FieldNames='-' �� ��������������� ���� �� ������� ���������� �� ��������
//������ ���������� ����������� �����
var
  res, i, j: Integer;
  FName: string;
begin
  Result := 0;
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  MemTableEh.DisableControls;
  if (Append <> 1) and (Append <> 2) then begin
    j := MemTableEh.RecordCount - 1;
    MemTableEh.First;
    for i := 0 to j do begin
      MemTableEh.Delete;
    end;
  end;
  while not AdoQuery.EOF do begin
    if Append = 2 then
      MemTableEh.Last;
    MemTableEh.Append;
    for i := 0 to AdoQuery.FieldCount - 1 do begin
      FName := AdoQuery.Fields[i].FieldName;
      if (FieldNames = '') or (S.InCommaStrI(FName, FieldNames, ';')) then
        MemTableEh.FieldByName(AdoQuery.Fields[i].FieldName).Value := AdoQuery.Fields[i].AsVariant
      else if (FieldNames = '-') then
        MemTableEh.Fields[i].Value := AdoQuery.Fields[i].AsVariant;
    end;
    AdoQuery.Next;
  end;
  QClose;
  MemTableEh.First;
  Mth.Post(MemTableEh);
  Result := MemTableEh.RecordCount;
  MemTableEh.EnableControls;
end;

function TmyDB.QLoadToDBComboBoxEh(Sql: string; ParamValues: TVarDynArray; DBComboboxEh: TDBComboboxEh; ComboBoxMode: TMyControlType; Append: Byte = 0): Integer;
//��������� ������ � ��������� �� ����������� ���
//�������� ��������: �-������, �-������ � ������ � ������,�-������ � ������ ������,�-������ � ������ ������ � ������ �������
//���� ��������� �������� ������ �� ������ ������ ���������� � ����� - ��������,����
//���� Append=0 �� ������ ����� ��������� ���������
var
  i: Integer;
begin
  Result := 0;
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  if Append = 0 then begin
    DBComboboxEh.Items.Clear;
    DBComboboxEh.KeyItems.Clear;
  end;
  if (ComboBoxMode = cntComboL0) or (ComboBoxMode = cntComboLK0) then
    DBComboboxEh.Items.Add('');
  if (ComboBoxMode = cntComboLK0) then
    DBComboboxEh.KeyItems.Add('0');
  while not AdoQuery.EOF do begin
    DBComboboxEh.Items.Add(AdoQuery.Fields[0].AsString);
    if (ComboBoxMode = cntComboLK) or (ComboBoxMode = cntComboLK0) or (ComboBoxMode = cntComboEK) then
      DBComboboxEh.KeyItems.Add(AdoQuery.Fields[1].AsString);
    AdoQuery.Next;
    inc(Result);
  end;
  QClose;
end;

function TmyDB.QLoadToTStringList(Sql: string; ParamValues: TVarDynArray; StringList: TStringList; Append: Byte = 0): Integer;
//��������� ������ �� ������� � TStringList
//���� ������ ���������� ���� ���� �� ��������� ������ ���, ����� ��������� ���� �������� Key=Value, ������ Value ������� �� ������ (��������) ����
var
  i: Integer;
begin
  Result := 0;
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  if Append = 0 then begin
    StringList.Clear;
  end;
  while not AdoQuery.EOF do begin
    if AdoQuery.Fields.Count = 1 then
      StringList.Add(AdoQuery.Fields[0].AsString)
    else
      StringList.Add(AdoQuery.Fields[1].AsString + '=' + AdoQuery.Fields[0].AsString);
    AdoQuery.Next;
    inc(Result);
  end;
  QClose;
end;

//���������� �������� ��������� Oracle
//���������� ��� ���������, ��������� (��� � ������ ����� ;, ��� � VarArrayOf), �������� ���� ���������� (��� ����, ��� � VarArrayOf)
//������ ��������� ������ ����� ; ��������� ������ ������ ��� ���������, ������ - ���������� ������ (I - ��������, B - InOut, O - ��������)
//������ ������ �� ���������� ���� ���������� (� ������� � ��������), ��� ������ ������ � ������ ������
function TmyDB.QCallStoredProc(ProcName: string; ParamNames: Variant; ParamValues: TVarDynArray): TVarDynArray;
var
  i, j: Integer;
  st, st1, st2: string;
  v: Variant;
  ParamNamesA, ParamValuesA: TVarDynArray;
  pt: TFieldType;
  pd: TParameterDirection;
  ps: Integer;
begin
  if PackageMode = -1 then
    Exit;
  Result := [];
  FLastSql := 'Call "' + ProcName + '"';
  FLastParamsStr := ParamNames + ' = ' + A.Implode(ParamValues, ' | ');
  try
    ParamNamesA := A.ExplodeV(ParamNames, ';');
    if (Length(ParamNamesA) = 0) or (ParamNamesA[0] = '') then
      ParamNamesA := [];
    ParamValuesA := ParamValues;
    AdoStoredProc.Parameters.Clear;
    AdoStoredProc.ProcedureName := ProcName;
    if (High(ParamNamesA)) = (High(ParamValuesA))       //!!!!!!!!!!
      then begin
      for i := Low(ParamNamesA) to High(ParamNamesA) do
      try
        if ParamNamesA[i] <> '' then begin
          st1 := QGetParamTypeCharFromName(ParamNamesA[i]);
          if st1[2] = ' ' then
            st1[2] := 'i';
          pt := ftString;
          pd := pdInput;
          ps := 4000;
  {          st1:='S'; st2:='I'; ps:=0;
            j:=pos('$', ParamNamesA[i]);
            if j > 0 then begin
              st:=copy(ParamNamesA[i],1,j-1);
              st1:=copy(ParamNamesA[i],j+1,1);
              st2:=copy(ParamNamesA[i],j+2,1);
              if st2 = '' then st2:='I';
            end;}
          case st1[1] of
            'f':
              pt := ftFloat;
            'i':
              pt := ftInteger;
            'd':
              pt := ftDateTime;
            'h':
              pt := ftDateTime;
            'c':
              pt := ftCurrency;
          else
            begin
              pt := ftString;
              ps := 4000;
            end;
          end;
          case st1[2] of
            'r':
              pd := pdReturnValue;
            'i':
              pd := pdInput;
            'b':
              pd := pdInputOutput;
            'o':
              pd := pdOutput;
          else
            begin
              pd := pdInput
            end;
          end;
          AdoStoredProc.Parameters.CreateParameter(ParamNamesA[i], pt, pd, ps, ParamValuesA[i]);
          AdoStoredProc.Parameters[i].Attributes := [paNullable];
        end;
      except
        on E: Exception do begin
          Errors.SetParam('', '������ ��������� ��������� ������� (' + ParamNamesA[i] + ' = "' + ParamValuesA[i] + '")'#13#10'*', myerrTypeDB);
          Application.ShowException(E);
          if (PackageMode = 1) then
            FPackageMode := -1;
        end;
      end;
    end
    else begin
      Errors.SetParam('', '������ ��������� ���������� ������� (�� ��������� ���������� ���������� � ����������� ����������)', myerrTypeDB);
      raise Exception.Create('������ ��������� ���������� ������� (�� ��������� ���������� ���������� � ����������� ����������)');
      if (PackageMode = 1) then
        FPackageMode := -1;
      Exit;
    end;
    AdoStoredProc.ExecProc;
    for i := 0 to AdoStoredProc.Parameters.Count - 1 do
      Result := Result + [AdoStoredProc.Parameters[i].Value];
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
      if (PackageMode = 1) then
        FPackageMode := -1;
    end;
  end;
//  if (PackageMode = 1) and (Length(Result) = 0) then
//    FPackageMode := -1;
end;


{=========================== ������� ������ � ������������ ====================}

function TmyDB.QBeginTrans(APackageMode: Boolean = False; ShowErrors: Boolean = True): Boolean;
//��������� ����������
//���� ����������� APackageMode, ���������� �������� �����
//(� ������� ������� ��������� ����������� ����� ������� ����, � ���� �� ��� ���������� ��������� ���������� �� ���������)
//���� ���� �������� ����������, �� ������� ��!
begin
  try
    Result := False;
    if AdoConnection.InTransaction then
      AdoConnection.RollbackTrans;
    AdoConnection.BeginTrans;
    Result := True;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB, ShowErrors);
      Application.ShowException(E);
    end;
  end;
  FPackageMode := S.IIf(APackageMode, S.IIf(Result, 1, -1), 0);
end;

function TmyDB.QCommitOrRollback(Commit: Boolean = True; ShowErrors: Boolean = True): Boolean;
//��������� ��� ���������� ����������
//���� �������� �����, �� ����� ��������/������ ������������ ��� ����������� and Commit
//����� ��������� ������� ������� ��������� ����������
//���� ��� �������� ����������, ������ � False
begin
  if not AdoConnection.InTransaction then begin
    Result := False;
    Exit;
  end;
  if PackageMode <> 0 then
    Commit := (PackageMode = 1) and (Commit);
  try
    Result := False;
    if Commit then
      AdoConnection.CommitTrans
    else
      AdoConnection.RollbackTrans;
    Result := True;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB, ShowErrors);
      Application.ShowException(E);
    end;
  end;
  FCommitSuccess := Result and Commit;
end;

function TmyDB.QCommitTrans: Boolean;
//�������� ����������
begin
  Result := QCommitOrrollback(True);
end;

function TmyDB.QRollbackTrans: Boolean;
//���������� ����������
begin
  Result := QCommitOrRollback(False);
end;

function TmyDB.QSelectId(sequence: string): LongInt;
//���������� ���� �� ���������� ���������
begin
  Result := StrToInt(VarToStr(QSelectOneRow('select ' + sequence + '.nextval from dual', [])[0]));
  FLastSequenceId := Result;
end;


{=========================== ��������� BIND-���������� ��� �������� ===========}

function TmyDB.QSetParamsEh(ADODataDriverEh1: TADODataDriverEh; ParamNames: Variant; ParamValues: TVarDynArray; CommandType: string = 's'; IgnoreRemainings: Boolean = False): Boolean;
//������������� ��������� � ADODataDriverEh1
//���� ������������ �� ������������� $s, $f, $i, $d
//������������� ��� ������� �������� � ����� � CommandType (�� ��������� s - selectsql)
//���� IgnoreRemainings=True (�� �� ���������), �� ���������� �� �� ��������� � ������� ��������� �������������, ����� ������ ������
//������������� ��������� � ADODataDriverEh1
//���� ������������ �� ������������� $s, $f, $i, $d
//������������� ��� ������� �������� � ����� � CommandType (�� ��������� s - selectsql)
//���� IgnoreRemainings=True (�� �� ���������), �� ���������� �� �� ��������� � ������� ��������� �������������, ����� ������ ������
var  //++ ��������� ����������!!!  ��������� � []
  i, j, k: Integer;
  st, st1, st2: string;
  v: Variant;
  ParamNamesA: TVarDynArray;
  Parameters: TParameters;
  Command: TAdoCommandEh;
  b: Boolean;
begin
  //��������� ���
  //if VarType(V) and VarArray = VarArray then  ��� VarIsArray(ParamValues)
  Result := False;
  try
    if ParamNames = '' then
      Exit;
    FLastParamsStr := '';
    FLastParamsErr := '';
    case UpCase(CommandType[1]) of
      'U':
        Command := ADODataDriverEh1.UpdateCommand;
      'D':
        Command := ADODataDriverEh1.DeleteCommand;
      'G':
        Command := ADODataDriverEh1.GetrecCommand;
      'R':
        Command := ADODataDriverEh1.GetrecCommand;
    else
      Command := ADODataDriverEh1.SelectCommand;
    end;
    if FIsLogEnabled then
      FLastSql := Command.CommandText.Text;
    ;
    ParamNamesA := A.ExplodeV(ParamNames, ';');
    if (Length(ParamNamesA) = 0) or (ParamNamesA[0] = '') then
      Exit;
    Result := False;
    for i := 0 to Max(High(ParamNamesA), High(ParamValues)) do begin
      if i <= High(ParamNamesA) then
        st1 := VarToStr(ParamNamesA[i])
      else
        st1 := '<Unknown>';
      if i <= High(ParamValues) then
        st2 := S.IIf(VarIsNull(ParamValues[i]), '<Null>', VarToStr(ParamValues[i]))
      else
        st2 := '<Unknown>';
      S.ConcatStP(FLastParamsStr, '[' + st1 + ']=' + st2, sLineBreak);
    end;
    Parameters := Command.Parameters;
    if (High(ParamNamesA)) = (High(ParamValues)) then begin
      for i := Low(ParamNamesA) to High(ParamNamesA) do
      try
        if ParamNamesA[i] <> '' then begin
          b := False;
          for k := 0 to Parameters.Count - 1 do
            if Parameters[k].Name = ParamNamesA[i] then begin
              b := True;
              Break;
            end;
          if b or (IgnoreRemainings = False) then
            if pos('$', ParamNamesA[i]) = 0 then
              Parameters.ParamValues[ParamNamesA[i]] := ParamValues[i]
            else begin
              j := pos('$', ParamNamesA[i]);
              st := copy(ParamNamesA[i], 1, j - 1);
              st1 := copy(ParamNamesA[i], j + 1, 1);
              if UpperCase(st1) = 'F' then
                Parameters.ParamByName(ParamNamesA[i]).DataType := ftFloat
              else if UpperCase(st1) = 'I' then
                Parameters.ParamByName(ParamNamesA[i]).DataType := ftInteger
              else if UpperCase(st1) = 'S' then
                Parameters.ParamByName(ParamNamesA[i]).DataType := ftString
              else if UpperCase(st1) = 'D' then
                Parameters.ParamByName(ParamNamesA[i]).DataType := ftDateTime;
  //Parameters.ParamByName(ParamNamesA[i]).Attributes:=[paNullable];
              Parameters.ParamValues[ParamNamesA[i]] := ParamValues[i];
            end;
        end;
        FLastParamsErr := '������ ��������� ��������� ������� (' + ParamNamesA[i] + ' = "' + VarToStr(ParamValues[i]) + '")'#13#10'*';
      except
        on E: Exception do begin
          Errors.SetParam('', FLastParamsErr, myerrTypeDB);
          Application.ShowException(E);
          FLastParamsErr := ''
        end;
      end;
    end
    else begin
      Errors.SetParam('', '������ ��������� ���������� ������� (�� ��������� ���������� ���������� � ����������� ����������)', myerrTypeDB);
      raise Exception.Create('������ ��������� ���������� ������� (�� ��������� ���������� ���������� � ����������� ����������)');
    end;
    Result := True;
  except
    on E: Exception do begin
      Errors.SetParam('', FLastParamsErr, myerrTypeDB);
      Application.ShowException(E);
      FLastParamsErr := E.Message;
    end;
  end;
  //MyData.IsOraTreat:=False;
end;

{===================== ������ � ������ ========================================}

function TmyDB.SetEnableLog(Enable: Boolean = True): Boolean;
//��������� ��� ��������� ������ �������� � ���
begin
  if FIsLogEnabled = Enable then
    Exit;
  Result := Enable;
  FIsLogEnabled := Enable;
  //FLastSql := '';
  //FLastParamsStr := '';
  //FLastParamsErr := ''
  {
  S.SwapPlaces(FLastSql, _FLastSql);
  S.SwapPlaces(FLastParamsStr, _FLastParamsStr);
  S.SwapPlaces(FLastParamsErr, _FLastParamsErr);}
end;

procedure TmyDB.ToLogEh(Command: TCustomSQLCommandEh; ErrMsg: string = '');
//��������� � ��� ������ �� AdoDataDriverEh ��� ���������� �������
var
  ap: TParameters;
  i: Integer;
  s, ps: string;
begin
  if not FIsLogEnabled then
    Exit;
  if Command is TADOCommandEh then begin
    ap := TADOCommandEh(Command).Parameters;
    for i := 0 to ap.Count - 1 do begin
      if VarIsNull(ap[i].Value) then
        ps := '<Null>'
      else
        ps := VarToStr(ap[i].Value);
      s := s + '[' + ap[i].Name + ']=' + ps + sLineBreak;
    end;
  end;
  ToLog('Eh', Command.FinalCommandText.Text, s, ErrMsg);
end;

procedure TmyDB.ToLog(Source, Query, Params, ErrMsg: string);
//������ ������� � ���������� � ������ ����
//����� ������������� ��������� �������, � ��� �������� ������� ���� �������� ��� ���������� (���������� ������)
begin
  if not FIsLogEnabled then
    Exit;
  FLogArray := FLogArray + [[-1, Now, Source, Query, Params, ErrMsg]];
  try
    if FrmXGSrvSqlMonitor <> nil then
      FrmXGSrvSqlMonitor.LoadLogRowToGrid;
  except
  end;
end;

end.
