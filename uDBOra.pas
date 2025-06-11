unit uDBOra;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Types,
  Dialogs, StdCtrls, DBCtrlsEh, uData, DB, AdoDB, uString, Variants, MemTableEh, uErrors, IniFiles, ADODataDriverEh,
  uFrmXDmsgNoConnection, MemTableDataEh, DataDriverEh, uDB
  ;

const
  oraeNonUnique = '00001';
  oraeNumberTooLarge = '01438';
  oraePkNotFound = '02291';
  oraeStringTooLarge = '12899';
  oraeChildFound = '02292';
  oraeCannotInsertNull = '01400';
  oraeCannotUpdateNull = '01407';
  oraeDeadLock = '00060';

type
  TmyDBOra = class(TmyDB)
    //��� ���������� ����� ������ �� �������� � ����� ��������, ���� � dfm nil �� ����
    function AdoConnectionProviderEhExecuteCommand(
      SQLDataDriver: TCustomSQLDataDriverEh; Command: TCustomSQLCommandEh;
      var Cursor: TDataSet; var FreeOnEof, Processed: Boolean): Integer;
  private
    { Private declarations }
  public
    { Public declarations }
    //������� ������ ���� ������
    //���������� ���� �������� ���������� (������ ��� �����, ��� ����������), ���� AConnectAfterCreate �� ��� �� �������� ������������
    constructor CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = true); reintroduce;
    //��������� � ��������� ������� ����������� ��������� ������� ����������� ��������
    //��������� ������ ��� (��� �������� � ��� dbgrideh, ��������������� � � ��� � � ��� ���������
    function QSetContextValue(Par: string; Val: Variant): Integer;
    //������ � ������ ��������� ��
    //���������� ��� ������� (���������, �������...) � ������������ ������� �� 4000 ��������
    procedure QLog(ItemName, Comm: string);
    //��������� � ������������� ��������� ��������� (�� ������������ ������� Docum, documAdd)
    //��������� ��������!
    //���� �������� ��������� Msg, �� ��� ��������� � ������ ������ ��������� ���������� ($u ���������� �� ��� �����)
    //Msg �������� ��������� ���� ������ ������������ ������|���� ��� ������
    //���������� � ������� ���� ��������� � ��� ����� � ��� ����, �� � ������ ������ �� �������� ���� ��� ����� ������� � ������ ������
    //���� ������� ���������� ��� ������ ������������, �� ����� ����������� �������� ���� ���� ��� ����� ������������� � ������ ������
    //���������� ��� �������� ������ ������������ �������� �������� ����������, �������� ����� �������� ��������� ��� ���������� ������������ �������� �������������
    // Mode: Integer = 0 fNone - ������������� �� ����������� �������
    function DBLock(SetLock: Boolean; Docum: string; DocumAdd: string = ''; Msg: string = '*|*'; Mode: TDialogType = fNone) : TVarDynArray;
    //�������� ��� ��������� ��� �������� ������������
    procedure DBLock_ClearAll;
    procedure OraError(msg: string);
  end;

var
  Q: TmyDBOra;

implementation

uses
  uWindows,
  uMessages,
  uForms
  ;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}


function TmyDBOra.AdoConnectionProviderEhExecuteCommand(
  SQLDataDriver: TCustomSQLDataDriverEh; Command: TCustomSQLCommandEh;
  var Cursor: TDataSet; var FreeOnEof, Processed: Boolean): Integer;
begin
  inherited;
//
end;

constructor TmyDBOra.CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = true);
//������� ������ ���� ������
//���������� ���� �������� ���������� (������ ��� �����, ��� ����������), ���� AConnectAfterCreate �� ��� �� �������� ������������
var
  va: TVarDynArray;
begin
  Inherited CreateObject(AOwner, mydbtOra, AConnectionFile, AConnectAfterCreate);
end;

function TmyDBOra.QSetContextValue(Par: string; Val: Variant): Integer;
//��������� � ��������� ������� ����������� ��������� ������� ����������� ��������
//��������� ������ ��� (��� �������� � ��� dbgrideh, ��������������� � � ��� � � ��� ���������
//� �� �������� ��������� ����� ��� varchar2, �� ��������� ������������� � ���� �������� ���������� �����
var
  ValType: string;
begin
  Result:=-1;
  try
    ValType := 's';
    if S.VarType(Val) = varDate then
      ValType := 'd';
    if S.VarType(Val) = varInteger then
      ValType := 'i';
    if S.VarType(Val) = varDouble then
      ValType := 'f';
    //��� ��������� ������ ehlib
    if AdoConnectionProviderEh.Connection <> nil then begin
      ADODataDriverEh.SelectSQL.Text:='select f_set_context_value(:par$s, :val$' + ValType + ') from dual';
      ADODataDriverEh.SelectCommand.Parameters.ParamByName('par$s').Value:= Par;
      ADODataDriverEh.SelectCommand.Parameters.ParamByName('val$' + ValType + '').Value:=Val;
      MemTableEh1.Active:=true;
      MemTableEh1.Active:=false;
    end;
    //��� ��������� �������� ������
    QCallStoredProc('set_context_value', 'par$s;val$' + ValType + '', [Par, Val]);
    Result:=0;
  except on E: Exception do Application.ShowException(E);
  end;
end;

procedure TmyDBOra.QLog(ItemName, Comm: string);
//������ � ������ ��������� ��
//���������� ��� ������� (���������, �������...) � ������������ ������� �� 4000 ��������
begin
  QExecSql('insert into adm_db_log (itemname, comm) values (:itemname$s, :comm$s)', [ItemName, Comm], false);
end;

procedure TmyDBOra.OraError(msg: string);
var
  Msg1, EMsg: string;
begin
  Msg1:='';
  EMsg:= msg; //E.Message;
  if Pos('unique constraint ', EMsg)> 0 then msg:='������ ������ ���� ����������! ������ �� ��������!';
  if Msg = '' then Msg:=EMsg;
//  If E is Exception then
//    ShowMessage ('ErrE - ' + E.Message)
//  else
//    ShowMessage ('ErrNE - ' + E.Message);
  ShowMessage (Msg);
end;


//��������� � ������������� ��������� ��������� (�� ������������ ������� Docum, documAdd)
//��������� ��������!
//���� �������� ��������� Msg, �� ��� ��������� � ������ ������ ��������� ���������� ($u ���������� �� ��� �����)
//Msg �������� ��������� ���� ������ ������������ ������|���� ��� ������
//���������� � ������� ���� ��������� � ��� ����� � ��� ����, �� � ������ ������ �� �������� ���� ��� ����� ������� � ������ ������
//���� ������� ���������� ��� ������ ������������, �� ����� ����������� �������� ���� ���� ��� ����� ������������� � ������ ������
//���������� ��� �������� ������ ������������ �������� �������� ����������, �������� ����� �������� ��������� ��� ���������� ������������ �������� �������������
function TmyDBOra.DBLock(SetLock: Boolean; Docum: string; DocumAdd: string = ''; Msg: string = '*|*'; Mode: TDialogType = fNone) : TVarDynArray;
var
  res: Variant;
  resi: Integer;
  v: TVarDataArray;
  Msgs: TStringDynArray;
  m1, m2: string;
begin
  Result:= [S.IIf(Mode in [fNone, fEdit, fDelete], true, null), '', '', Mode];
  if not (Mode in [fNone, fEdit, fDelete]) then Exit;
  if SetLock
    then begin
      //����� ���������� � ������� �������
      QExecSql('delete from adm_locks l where (select count(1) from v$session vs where l.sid = vs.sid and l.serial# = vs.serial#) = 0', [], false);
      //���������� ���������� ����������
      resi:= QExecSql(
        'insert into adm_locks (logon_time, sid, serial#, login, username, lock_time, lock_docum, lock_docum_add) values ('+
        '(select logon_time from v$session where sid in (select sid from v$mystat where rownum = 1)), ' +
        '(select sid from v$session where sid in (select sid from v$mystat where rownum = 1)), ' +
        '(select serial# from v$session where sid in (select sid from v$mystat where rownum = 1)), ' +
        ':login$s, :username$s, current_date, :docum$s, :documadd$s)',
        [User.GetLogin, User.GetName, Docum, DocumAdd], false
        );
      if resi = -1 then
        begin
          //������ ��������� ����������
          res:= QSelectOneRow(
//            'select login, username, lock_time from locks where login <> :login and lock_docum = :docum and lock_docum_add = :documadd',
//            VarArrayOf([User.GetLogin, Docum, DocumAdd])
            'select login, username, lock_time from adm_locks where lock_docum = :docum and lock_docum_add = :documadd',
            [Docum, DocumAdd]
            );
          Result[0]:= False;
          Result[1]:= S.NSt(res[1]);
          Result[2]:= res[2];
          Result[3]:= fNone;
          if Msg='' then Msg:='|';
          Msgs:=A.ExplodeS(Msg, '|');
          if (Mode in [fNone, fDelete])
            then if (Msgs[0] <> '*')
              then m1:= Msgs[0]
              else m1:= '���� �������� ������ �������, ��� ��� �� ������ ������������� ������������� $u.';
          if (Mode in [fEdit])
            then if (Msgs[0] <> '*')
              then m1:= Msgs[0]
              else m1:= '���� �������� ������ ������������� ������������� $u � ����� ������ ������ ��� ������.';
          if Length(Msgs) = 0 then m2:= m1 else m2:= Msgs[1];
//        if (m2 = '*') and (Mode = 0) then m2:= '�� ��� ������� ���� �������� ��� ��������������.';
          if (m2 = '*') then m2:= '�� ��� ������� ���� �������� ��� ��������������.';
          if res[0] <> User.GetLogin
            //������ ������ ��������������
            then begin
              //���� �������� ��������������, �� ������ �� ��������, ���� ������, �� ������ �� ���������
              Result[3]:= S.IIf(Mode = fEdit, fView, fNone);
              //� ������� ���������
              if m1 <> '' then myMessageDlg(StringReplace(m1, '$u', VarToStr(Res[1]),[rfReplaceAll, rfIgnoreCase]), mtWarning, [mbOk]);
            end
            //������ ����� ��
            else begin
              //���� �� ������� �����, ��� ������� � ������� ���� � ������ �����������, �������� ������� � ����
//              if (Mode = fNone) or not Wh.BringToFrontSelfLockedDialog(Docum, DocumAdd) //++
              if True or (Mode = fNone)// or not Wh.BringToFrontSelfLockedDialog(Docum, DocumAdd)
                //� ���� �� ������� �� ������� ���������
                then if m2 <> '' then myMessageDlg(StringReplace(m2, '$u', VarToStr(Res[1]),[rfReplaceAll, rfIgnoreCase]), mtWarning, [mbOk]);
              Result[3]:= fNone;
            end;
        end;
    end
    else begin
      //������� ���������
      resi:= QExecSql(
        'delete from adm_locks where login = :login$s and lock_docum = :docum$s and lock_docum_add = :documadd$s',
        [User.GetLogin, Docum, DocumAdd], false
      );
    end;
end;

//�������� ��� ��������� ��� �������� ������������
procedure TmyDBOra.DBLock_ClearAll;
begin
  QExecSql('delete from adm_locks where login = :login$s', [User.GetLogin], false);
end;



end.

{
�����:
��� ������� ����� ��������� �� ���������� ���������� ������� ��������, � ��� ����� ���� �� ������� ������� ����� �� ��������� �� ������
���� �� ����� ����� ������, ������� ������� (��� i3 number(3,1) ���� ������ ����� ��� 123.4)) ������ ����� ������ �� ���������
ORA-01438: value larger than specified precision allowed for this column
��� �������� �������!!!

�� ������ ������������ ����
�������� �������� ��������, ������� ��� � �����������
ORA-02291: integrity constraint (UCHET.FK_PAS_TEST) violated - parent key not found

�������� ������ ���� ����������
ORA-00001: unique constraint (UCHET.PK_PAS_TEST) violated

���������� ������ � ����� ������� ������� (� ��� ������� � ��� �������)
ORA-01438: value larger than specified precision allowed for this column

������ ������� �������
ORA-12899: value too large for column "UCHET"."PAS_TEST2"."S" (actual: 12, maximum: 10)

������� �������� ������ ��� ��������
������ ������� ������, ��� ��� ������ ��� ������������
ORA-02292: integrity constraint (UCHET.FK_PAS_TEST) violated - child record found

������ �������� ������ ������, ��� ���� � ������� ���� ����������� not null
���� �� ����� ���� ������
ORA-01400: cannot insert NULL into ("UCHET"."PAS_TEST1"."S")

������ �������� ������ ������, ��� ���� � ������� ���� ����������� not null
���� �� ����� ���� ������
ORA-01407: cannot update ("UCHET"."PAS_TEST1"."S") to NULL

ORA-03114: ��� ����� � ORACLE

ORA-00060: deadlock detected while waiting for resource

}

������ � ������ BLOB � CLOB ������ � ��� �� ������ ���������
��� ����������� ���� oraBlob ��� oraClob ��� ���������� ���������� ������
��� ����������� Blob ������ ��������� �������������, �� �������� �� ���� ���������� ������

c Clob ��� �� ����� ������ ������� ����� ��� � ����� ftString, ���� � �� ��� ���� ����������
��� CLOB, �� ������� ������ � ��� ������� � �������� �� ��� ��� ���� ��������� ftString/
