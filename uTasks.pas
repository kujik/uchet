unit uTasks;

{
������, ������� ������ ����������� ������������, ��� ����������� �� ����������� ������� ��������� ��������������

�� ������ ������:
��� ������ ������ ������� �������� ��������� ������, ������� � ���������� ��� ������, ��� ������ "������.exe /������"
� ��� �� ������ ���������� ������ ������, ����� ���� ���������� ����� �� ���������
��������� ����� ������������ � ����� ���������� ��������� - �� ����� ���� ���������

���������� ������ �� ��������, ���� ��� �� ������� �������� (� ������ ���� ��������)
� ������ ������� �� ������, ����� ��� ������ ��� ������������� ���������� ������ (����� �� ����������� ��������)

� ������ ������ �� ����� ���������� ������, �������� ���� ������, � ����� 3 ������ ��������� ���������

�� ������ ������ ��� �������� ���������� ����� ����� ������������ ����������� �������, ��� ����������� ���������� ������ � ����������
��� �������, ������������� ����� ������ ������ � ���������� ���������
���� ���� ��������� � ������� ��� (��� �������� ������), �� ������ � ������ ����� ������ � ������� ���� 12�, � ���������� � ���.

/fromparsec
��������� � 8:10, ������ ��������, � ������� 12�
/turvreport
��� ������, ��������� � 8� � � 15� (������ ���� ���������� ����� ���� ������� ��������, � ������ �������� ����)


}

interface

uses
 Graphics, Classes, StrUtils, DateUtils, Variants, SysUtils, Types, uString,LibXL, Windows
 ;


type
  TMyTskOpTypes = (
    mytskopMail, mytskopMoveToArchive, mytskopDeleteFromArchive, mytskopMoveToCurrent, mytskopSmetaReport, mytskopDeleteAllFromAccounts,
    mytskopGetFileListByMask, mytskopDeleteDirectoriesFromList, mytskopDeleteFilesFromList, mytskopToPassportChange,
    mytskopToSnDocuments, mytskopToEstimates, mytskopToThnDocuments, mytskopLinkMontage, mytskopToKnsDocuments
  );

type
  TTasks = class
  private
  public
    function CreateTaskDir: string;
    function FinalizeTaskDir(TaskDir: string): Boolean;
    function CreateTaskRoot(Operation: TMyTskOpTypes; Fields: TVarDynArray2; ForTesting: Boolean = False; AutoRun: Boolean = True): string;
    function TestTaskRootComplete(TaskDir:string):Boolean;
    function GetProductionCalendar(Year: Variant): Integer;
    function TestTurvComplete: Integer;
    function TestTurvDifferences: Integer;
    procedure SmetaReport;
    procedure DeleteOldData;
    procedure CalcPlannedOrders;
    procedure CloSEItmPeriod;
    procedure Run_TestTurvDifferences;
    procedure Run;
  end;

var
  Tasks: TTasks;


implementation


uses
  ZLib,
  uDBOra,
  uData,
  uSys,
  uTurv,
  uMessages,
  uFrmMain,
  Dialogs,
  XmlDoc,
  Xml.XMLIntf,
  iDMessage,
  ShellApi,
  uOrders,

  D_Order

  ;




function TTasks.CreateTaskDir: string;
var
  st: string;
begin
  Result:='';
  try
    st:=Module.GetPath_Tasks + '\' + FormatDateTime('yyyy.mm.dd_hh-mm-ss,zzzzzz', Now);
    if not ForceDirectories(st + '\Files') then Exit;
  except
    Exit;
  end;
  Result:=st;
end;

function TTasks.FinalizeTaskDir(TaskDir: string): Boolean;
begin
  Result:=RenameFile(TaskDir, ExtractFilePath(TaskDir) + '\GO_' + ExtractFileName(TaskDir));
end;

function TTasks.CreateTaskRoot(Operation: TMyTskOpTypes; Fields: TVarDynArray2; ForTesting: Boolean = False; AutoRun: Boolean = True): string;
//������� ������� � ����� ������ ��� ���������� ��������� (php-������ �� �������� �������)
//����� ������� �������������, �������������� ����� �������� �������� � �������, � ������� ���������� ��������� ��� �������
//���������� ��������� �����, � ������� ������ ������� ������
var
  st, TaskDir: string;
  op: string;
  i: Integer;
  b: Boolean;
begin
  Result:='';
  TaskDir:=CreateTaskDir;
  if TaskDir = '' then Exit;
  case Operation of
    myTskOpMail: op:= 'message';
    mytskopMoveToArchive: op:='to_move_in_archive';
    mytskopDeleteFromArchive: op:='to_delete_from_archive';
    mytskopMoveToCurrent: op:='to_move_in_current';
    mytskopDeleteAllFromAccounts: op:='to_deleteall_from_accounts';
    mytskopGetFileListByMask: op:='get_file_list_by_mask';
    mytskopDeleteDirectoriesFromList: op:='delete_directories_from_list';
    mytskopDeleteFilesFromList: op:='delete_files_from_list';
    mytskopToPassportChange: op:='to_passport_change';
    mytskopToSnDocuments: op:='to_sn_documents';
    mytskopToEstimates: op:='to_estimates';
    mytskopToThnDocuments: op:='to_thn_documents';
    mytskopToKnsDocuments: op:='to_kns_documents';
    mytskopLinkMontage: op:='to_link_montage';
//    mytskSmetaReport: op:='';
  end;
  b:= False;
  for i:=0 to High(Fields) do begin
    if Fields[i][0] = 'user-name' then b:=True;
    if Module.InTestmode and (Fields[i][0] = 'to') then Fields[i][1]:= 'sprokopenko@fr-mix.ru';
    if not Sys.SaveTextToFile(TaskDir + '\__' + Fields[i][0], Fields[i][1])
       then Exit;
  end;
  //���� �������� 'user-name' �� �������, �� ������� �� ���� ��� �������� ������������ (��� ����� � ������� ������)
  if not b then
    if not Sys.SaveTextToFile(TaskDir + '\__user-name', User.GetName)
       then Exit;
  if ForTesting then
    if not Sys.SaveTextToFile(TaskDir + '\__for-testing', '') then Exit;
  if not Sys.SaveTextToFile(TaskDir + '\__operation', op) then Exit;
  if AutoRun then
    if not FinalizeTaskDir(TaskDir) then Exit;
  Result:=ExtractFileName(TaskDir);
end;

function TTasks.TestTaskRootComplete(TaskDir:string):Boolean;
begin
  Result:=False;
  try
    Result:=DirectoryExists(Module.GetPath_Tasks + '\OLD_' + TaskDir);
  except
  end;
end;

function TTasks.GetProductionCalendar(Year: Variant): Integer;
var
  i,j,k:Integer;
  st: string;

  FileStream: TFileStream;
  DecompressionStream: TDecompressionStream;
  Strings: TStringList;
  MS:TMemoryStream;
//  XMLDocument:TXMLDocument;
  RootNode: IXMLNode;
  a1: TVarDynArray;
  a2, a3: TVarDynArray2;
  b: Boolean;
begin
(*
<!--
year    - ��� �� ������� ����������� ���������
lang    - ������������� ��� ����� �� ������� ������������ �������� ����������
date    - ���� ������������ xml-��������� � ������� ����.��.��
country - ������������� ��� ������
-->
<calendar year="2014" lang="ru" date="2014.01.01" country="ru">
	<!--
		holidays - ������ ����������
		id - ������������� ���������
		title - �������� ���������
	-->
	<holidays>
		<holiday id="1" title="���������� ��������" />
		<holiday id="2" title="��������� ��������" />
		<holiday id="3" title="���� ��������� ���������" />
		<holiday id="4" title="������������� ������� ����" />
		<holiday id="5" title="�������� ����� � �����" />
		<holiday id="6" title="���� ������" />
		<holiday id="7" title="���� ������" />
		<holiday id="8" title="���� ��������� ��������" />
	</holidays>
	<!--
		days - ���������/�������� ���/������� ��� (������� ���� �����������)
		d (day) - ���� (������ ��.��)
		t (type) - ��� ���: 1 - �������� ����, 2 - ������� � ����������� (����� ���� ����������� ��� ������ ��� ������), 3 - ������� ���� (�������/�����������)
		h (holiday) - ����� ��������� (������ �� ������� id ���� holiday)
		f (from) - ���� � ������� ��� ��������� �������� ����
		������� � ����������� ��������� ���������, ���� ��� ����� day � ��������� t=2 � t=3 �� ���� ����
	-->
	<days>
		<day d="01.01" t="1" h="1" />
		<day d="01.02" t="1" h="1" />
		<day d="01.03" t="1" h="1" />
		<day d="02.22" t="1" f="01.03" />
		...
	</days>
</calendar>
*)
  Result:=-1;
  repeat
  try
  if not Sys.LoadFileFromWWW('http://xmlcalendar.ru/data/ru/' + VarToStr(Year) + '/calendar.xml.gz', Sys.GetWinTemp+'\calendar.xml.gz') then break;
  FileStream := TFileStream.Create(Sys.GetWinTemp+'\calendar.xml.gz', fmOpenRead);
{   windowBits can also be greater than 15 for optional gzip decoding.  Add
   32 to windowBits to enable zlib and gzip decoding with automatic header
   detection, or add 16 to S.Decode only the gzip format (the zlib format will
   return a Z_DATA_ERROR).}
  DecompressionStream := TDecompressionStream.Create(FileStream, 15 + 16);  // 31 bit wide window = gzip only mode
  Strings := TStringList.Create;
  Strings.LoadFromStream(DecompressionStream);
  Strings.Text:=UTF8Decode(Strings.Text);
//  ShowMessage(Strings.Text);

  MyData.XMLDocument.LoadFromXML(Strings.Text);
  MyData.XMLDocument.Active := True;

  st:=MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes[1].xml;//ChildNodes['holideys'].XML;

  a1:=[''];
  for i:=0 to MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes.Count - 1 do begin
    j:=StrToInt(MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes[i].Attributes['id']);
    if j > High(a1) then SetLength(a1, j+1);
    a1[j]:=S.NSt(MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes[i].Attributes['title']);
  end;

  SetLength(a2, MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes.Count);
  for i:=0 to MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes.Count - 1 do begin
    st:=MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes[i].Attributes['d'];
    a2[i]:=[
      EncodeDate(S.VarToInt(Year), StrToInt(Copy(st,1,2)), StrToInt(Copy(st,4,2))),
      StrToInt(MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes[i].Attributes['t']),
      a1[StrToIntDef(S.NSt(MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes[i].Attributes['h']), 0)]
    ]
  end;

//  text;//ChildNodes['holideys1'].text;//ChildNodes[1].Text;
//  ShowMessage(st);
  if Length(a2) > 0 then begin
    a3:=Q.QLoadToVarDynArray2('select dt, type, descr from ref_holidays where extract(year from dt) = :year order by dt', [S.VarToInt(Year)]);
    b:=Length(a2) <> Length(a3);
    if not b then
      for i:=0 to High(a2) do
        if (a2[i][0] <> a3[i][0])or(a2[i][1] <> a3[i][1])or(a2[i][2] <> S.NSt(a3[i][2]))
          then begin b:=True; Break end;
    if b then begin
      Q.QExecSql('delete from ref_holidays where extract(year from dt) = :year', [S.VarToInt(Year)]);
      for i:=0 to High(a2) do
        Q.QExecSql('insert into ref_holidays (dt, type, descr) values (:dt$d, :type$i, :descr$t)', [a2[i][0], a2[i][1], Copy(a2[i][2], 1, 200)]);
      Result:=1;
    end
    else Result:=0;
    Break;
  end;
  except
    Break;
  end;
  until False;
//  XMLDocument.Free;
  DecompressionStream.Free;
  FileStream.Free;
  Strings.Free;
end;

function TTasks.TestTurvComplete: Integer;
var
  i,j,k,t: Integer;
  st, st1, st2: string;
  ar1: TVarDynArray2;
  ar2: TVarDynArray2;
  ar3: TVarDynArray2;
  sta: TStringDynArray;
  v: Variant;
  b, b1: Boolean;
  dt: TDateTime;
  autoagreedtime: Variant;
begin
  //���� ������ ��������������� ���� (��������� ����������� ������)
  dt:=Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1));
  //��� �������!
//  dt:=Turv.GetTurvBegDate(Date);
//  dt:=EncodeDate(2023, 6, 16);
  //������� ������ ����
  ar1:=Q.QLoadToVarDynArray2(
    'select dt1, dt2, id_division, name, editusers, 0 from v_turv_period where dt1 = :dt$d',
    [dt]
  );
  autoagreedtime:=Q.QSelectOneRow('select time_autoagreed from workers_cfg', [])[0];
  b:=False;
  //��� ������� ����
  for t:=0 to High(ar1) do begin
    //������� ������ ���������� ��� ������� ����
    //v:  0-����1, 1-����2, 2-���� ���������, 3-��� ���������, 4-���� ���������, 5-��������� ���������, 6-����� �������: 1=��������� 2=������
    ar2:=Turv.GetTurvArray(ar1[t][2], ar1[t][0]);
    if Length(ar2) = 0 then Continue;
    for i:= 0 to High(ar2) do begin
      //��� ������� ��������� �������� ��������� �� �����/��� �� ������������, ������� ���������� �����������
      //�� ���!
      //�� ������ ����:
      //�� ������������ ����� � �� ������� ���, ��� ��������
      //����� �� ������������ � ������� ���������� �� ���
      //�� ��� ���������, ���� ��������� ����� �������������
      //� ���� �� ��������� �� �������, �� ������� ����� ������ ��� ��� ��� ����� ������������
      v:=Q.QSelectOneRow(
{        'select count(1) from turv_day  where '+
        '(worktime1 is not null or id_turvcode1 is not null) and id_worker = :id_worker$i and dt >= :dtbeg$d and dt <= :dtend$d',}
        'select count(1) from turv_day  where ('+
        '(worktime3 is not null or id_turvcode3 is not null) or '+
        '(worktime2 is null and id_turvcode2 is null and (worktime1 is not null or id_turvcode1 is not null)) or '+
        '(worktime2 is not null and worktime1 is not null and (abs(worktime2 - worktime1) <= :autoagreedtime$f)) or '+
        '(id_turvcode2 is not null and id_turvcode1 is not null)'+
        ') and '+
        'id_worker = :id_worker$i and dt >= :dtbeg$d and dt <= :dtend$d',
        [autoagreedtime, ar2[i][2], ar2[i][0], ar2[i][1]]
      );
      //���������� ���������� ������ ��������� � ����������� ���� ��� ������ ������ ���� (�������� ��� �������� � 5�� �� 10�)
      j:=DaysBetween(ar2[i][1], ar2[i][0]) + 1;
      if j <> v[0] then begin
        //���� �� ��������� ������ �������
        ar1[t][5]:=1;
        b:=True;
        Break;
      end;
    end;
  end;
  if not b then Exit;
  //���� ���� �������������� ���� �� �� ������ ����
  SetLength(ar3, 0);
  //���������� ������ ar3, � ������� � ������ ������ ������� ������� ��� ���� ������������ (���� ���������� ����� ������),
  //� ��������� - ������������ ����
  for i:=0 to High(ar1) do begin
    if ar1[i][5] <> 1 then Continue;
    sta:=A.ExplodeS(ar1[i][4], ',');
    for j:=0 to High(sta) do begin
      k:=A.PosInArray(sta[j], ar3, 0);
      if k >= 0 then begin
        SetLength(ar3[k], Length(ar3[k])+1);
        ar3[k][High(ar3[k])]:= ar1[i][3];
      end
      else begin
        SetLength(ar3, Length(ar3)+1);
        k:=High(ar3);
        SetLength(ar3[k], 2);
        ar3[k][0]:= sta[j];
        ar3[k][1]:= ar1[i][3];
      end;
    end;
  end;
  //�������� ������
  for i:=0 to High(ar3) do begin
    st:=S.NSt(Q.QSelectOneRow('select emailaddr from v_users where id = :id$i', [ar3[i][0]])[0]);
    if st = '' then Continue;
    st2:=S.NSt(Q.QSelectOneRow('select name from v_users where id = :id$i', [ar3[i][0]])[0]);
    Delete(ar3[i], 0, 1);
    st1:=A.Implode(ar3[i], #13#10);
    CreateTaskRoot(mytskopmail, [
//      ['to', 'sprokopenko@fr-mix.ru'],
      ['to', st],
      ['subject', '�� ��������� �������� ����!'],
      ['body', st2 + ', ' + '�� ������ �� ����� ��������� (���, ����� �� ���� ������� � ������ �����) ��������� ����:'#13#10 + st1],
      ['user-name', '����']]
    );
  end;
end;


function TTasks.TestTurvDifferences: Integer;
//������ ����� �� ����, �� ������ ���� ����� �������� �������
//����� ���� � �������������, ��������� ���� ��� ���� ������������ ����� ��������� ������������ � �������
var
  i,j,k,t: Integer;
  st, st0, st1, st2, st3: string;
  ar1: TVarDynArray2;
  ar2: TVarDynArray2;
  ar3: TVarDynArray2;
  sta: TStringDynArray;
  v: Variant;
  va1: TVarDynArray2;
  b, b1: Boolean;
  dt: TDateTime;
  autoagreedtime: Variant;
  ok_user: string;
begin
  //���� ������ ��������������� ���� (��������� ����������� ������)
  dt:=Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1));
  //��� �������!
//  dt:=EncodeDate(2023, 6, 16);
  //������� �������������, � ������� ���� ������ �� �������� ������� �������
  ar1:=Q.QLoadToVarDynArray2(
    'select ur.id_user from adm_roles r, adm_user_roles ur where r.id = ur.id_role and '','' || r.rights || '','' like :v$t',
    ['%,' + rW_J_Turv_TP + ',%']
  );
  for i:=0 to High(ar1) do
    S.ConcatStP(ok_user, ar1[i][0],',');
  ok_user:=S.NSt(Q.QSelectOneRow('select GetUsersemail(:ids$t) from dual', [ok_user])[0]);
  //������� ����� ����������������
  autoagreedtime:=Q.QSelectOneRow('select time_autoagreed from workers_cfg', [])[0];
  //������� ������ ����
  ar1:=Q.QLoadToVarDynArray2(
    'select dt1, dt2, id_division, name, editusers, 0 from v_turv_period where dt1 = :dt$d',
    [dt]
  );
  //��� ������� ����
  for t:=0 to High(ar1) do begin
    //������� ������ ���������� ��� ������� ����
    //v:  0-����1, 1-����2, 2-���� ���������, 3-��� ���������, 4-���� ���������, 5-��������� ���������, 6-����� �������: 1=��������� 2=������
    ar2:=Turv.GetTurvArray(ar1[t][2], ar1[t][0]);
    if Length(ar2) = 0 then Continue;
    st0:='';  //���� ��� �� �������� ������
    st1:='';  //���� �� ������������� ��� �� �������� ��� �������
    st2:='';  //���� �� ������������� ��� �� ��������� �����������
    //���� �� ���� ���������� (�������) ����)
    for i:= 0 to High(ar2) do begin
      //������� ������ ������ �� ����
      va1:=Q.QLoadToVarDynArray2(
        'select dt, worktime1, id_turvcode1, worktime2, id_turvcode2, worktime3, id_turvcode3 from turv_day  where '+
        'id_worker = :id_worker$i and dt >= :dtbeg$d and dt <= :dtend$d order by dt',
        [ar2[i][2], ar2[i][0], ar2[i][1]]
      );
      b1:=False;
      //���� �� ��������� ������ �� ��������� ������ �� ��������� �� �����-�� ��� ������
      if DaysBetween(ar2[i][1], ar2[i][0]) + 1 <> Length(va1)
        then begin
          st0:='-'; //�� �������� ������
          b1:=True; //�� ��������� ����� ������������
        end;
      st3:='';
      //������� �� ���� ���� �� ������
      for j:=0 to High(va1) do begin
        //�� �������� ������
        if VarIsNull(va1[j][3]) and VarIsNull(va1[j][4]) then st0:='-';
        //�� �������� �� ������������ ��� ����������� �����������
        if
          (VarIsNull(va1[j][1]) and VarIsNull(va1[j][2])) or
          (VarIsNull(va1[j][1]) and not VarIsNull(va1[j][3])) or
          (not VarIsNull(va1[j][1]) and VarIsNull(va1[j][3])) or
          (not VarIsNull(va1[j][1]) and not VarIsNull(va1[j][3]) and (abs(S.VarToFloat(va1[j][1]) - S.VarToFloat(va1[j][3])) >  autoagreedtime))
          then b1:=True;
        //������������� �����������
        if not VarIsNull(va1[j][1]) and not VarIsNull(va1[j][3]) and (va1[j][1] <> va1[j][3])
          then S.ConcatStP(st3, IntToStr(DayOf(va1[j][0])) + ':' + VarToStr(va1[j][1]) + '/' + VarToStr(va1[j][3]), ', ');
      end;
      if b1 then st1:=st1 + VarToStr(ar2[i][3]) + #13#10;
      if st3 <> '' then st2:=st2 + VarToStr(ar2[i][3]) + ':... ' + st3 + #13#10;
    end;
    //�� ���� ��������������, ��������� ����
    if st0 + st1 + st2 = '' then Continue;
    //���������� ������ ���������
    st:=
    '��������!'#13#10+
    '� ���� ���� (' + ar1[t][3] + ') ���� ������������ ��� ��������������� ������!'#13#10#13#10;
    if st1 <> '' then
      st:=st +
        '�� ������ �� ����� ������, ��� �� �� ��� ������� ������������ ����������� (��� ������ �������� ������� �����) �� ��������� ����������:'#13#10 +
        st1 + #13#10#13#10;
    if st2 <> '' then
      st:=st +
        '������� �� ��������� ����������, ��������� �������������, � �� Parsec, �����������:'#13#10 +
        st2 + #13#10#13#10;
    if st0 <> '' then
      st:=st + #13#10 + '�����: ��� ����� ���� ��� ��������� �� ��� ������� �� Parsec!!!';
    //������ ������������, ������������ ������ �� ������
//    ok_user:='sprokopenko@fr-mix.ru';
    if ok_user <> '' then
      CreateTaskRoot(mytskopmail, [
        ['to', ok_user],
        ['subject', '���������� �� ���� "' + ar1[t][3] + '"'],
        ['body', st],
        ['user-name', '����']]
      );
    //������� ������ �������������
    st1:=S.NSt(Q.QSelectOneRow('select GetUsersemail(:ids$t) from dual', [ar1[t][4]])[0]);
//st1 :='';
    //������ �������������
    if st1 <> '' then
      CreateTaskRoot(mytskopmail, [
        ['to', st1],
        ['subject', '���������� ��������� ���� "' + ar1[t][3] + '"'],
        ['body', st],
        ['user-name', '����']]
      );
  end;
end;

procedure TTasks.Run_TestTurvDifferences;
var
  dt: TDateTime;
  i, j: Integer;
  b:Boolean;
begin
  b:=False;
{
  //� �����������
  if
    ((DayOf(Date) in [1, 16]) and (DayOfTheWeek(IncDay(Date, 1)) >=6) and (DayOfTheWeek(IncDay(Date, 2)) >=6))
       then TestTurvDifferences
       else if ((DayOf(Date) in [2, 17]) and (DayOfTheWeek(IncDay(Date, 1)) >=6))
         then TestTurvDifferences
         else if (DayOf(Date) in [3, 18])
           then TestTurvDifferences;}
  //������ 3�� ���� ��� �������, ��� 4��, ���� �� ������� � 3�� ��������, ��� 5�� ���� ��� ������� � 4�� � 3�� ��������
  if
    ((DayOf(Date) in [3, 18]) and (DayOfTheWeek(Date) <6))
       then TestTurvDifferences
       else if ((DayOf(Date) in [4, 19]) and (DayOfTheWeek(Date) <6) and (DayOfTheWeek(IncDay(Date, -1)) >=6))
         then TestTurvDifferences
           else if ((DayOf(Date) in [5, 20]) and (DayOfTheWeek(Date) <6) and (DayOfTheWeek(IncDay(Date, -1)) >=6) and (DayOfTheWeek(IncDay(Date, -2)) >=6))
           then TestTurvDifferences;
end;


procedure TTasks.Run;
var
  IscorrectTask: Boolean;
  HasError: Boolean;

begin
  repeat
    IscorrectTask:=False;
    HasError:=True;
    try
    if ParamStr(1) = '/turvreport1' then begin
      IscorrectTask:=True;
      if DayOf(Date) in [1, 16] then TestTurvComplete;
    end;
    if ParamStr(1) = '/turvreport2' then begin
      IscorrectTask:=True;
      Run_TestTurvDifferences;
    end;
    if ParamStr(1) = '/fromparsec' then begin
      IscorrectTask:=True;
      TURV.LoadParsecData;
    end;
    if ParamStr(1) = '/smetareport' then begin
      IscorrectTask:=True;
      SmetaReport;
    end;
    if ParamStr(1) = '/deleteolddata' then begin
      IscorrectTask:=True;
      DeleteOldData;
    end;
    if ParamStr(1) = '/getcalendar' then begin
      IscorrectTask:=True;
      GetProductionCalendar(YearOf(Date));
      GetProductionCalendar(YearOf(Date) + 1);
    end;
    if ParamStr(1) = '/calcplanned' then begin
      IscorrectTask:=True;
      CalcPlannedOrders;
    end;
    if ParamStr(1) = '/closeitmperiod' then begin
      CloSEItmPeriod
    end;
    if ParamStr(1) = '/test' then begin
      IscorrectTask:=True;
    end;
    HasError:=False;
    finally
    end;
    if IscorrectTask
      then Module.ToLogFile(ParamStr(1) + S.IIf(HasError, ' [������!]', ''));
  until True;
  FrmMain.Close;
end;

procedure TTasks.SmetaReport;
var
  i, j: Integer;
  va: TVarDynArray2;
  va1: TVarDynArray;
  body: string;
  addr: string;
begin
  va:=Q.QLoadToVarDynArray2(
    'select org || '' '' || num as ordernum, project, customer, dt_beg, dt_otgr, constructor '+
    'from uchet.v_to_orders_list_current2 where (dt_smeta is null) and (dt_end is null) order by ordernum',
    []
  );
  if High(va) < 0 then Exit;
  SetLength(va1, Length(va[0]));
  for i:=0 to High(va) do begin
    for j:=0 to High(va[i]) do
      if S.NNum(va1[j]) < Length(S.NSt(va[i][j]))
        then va1[j] := Length(S.NSt(va[i][j]));
  end;
  body:='������������� ������, �� ������� ��� �� ���� ���������� �����:'#13#10#13#10;
  for i:=0 to High(va) do begin
    for j:=0 to High(va[i]) do
      S.ConcatStP(body, Copy(VarToStr(va[i][j]) + '       ', 1, S.VarToInt(va1[j]) + 3), ' ');
    S.ConcatStP(body, #13#10);
  end;
  S.ConcatStP(body, #13#10);
  addr:=S.NSt(Q.QSelectOneRow('select addresses from adm_mailing where id = :i$i', [4])[0]);
  if addr = '' then Exit;
  CreateTaskRoot(myTskOpMail, [
    ['to', addr],
    ['subject', '������ � ������, �� ������� �� ������� �����'],
    ['body', body],
    ['user-name', '����']]
  );
end;

procedure TTasks.DeleteOldData;
//�������������� �������� ������ ������
var
  i, j: Integer;
  vtimes: TVarDynArray;
  va1, va2, va3: TVarDynArray2;
  va: TVarDynArray;
  body: string;
  dt1, dt2: TDateTime;
  ok: Boolean;
begin
  //������� ��������, ����� � ����, � ���� � �� � �������� 2 ������
  vtimes:=Q.QSelectOneRow('select or_to_archive, orders_n, accounts_n, turv, payrolls from adm_delete_old', []);
  if S.NNum(vtimes[0])>= 10 then begin
    //��������� � ����� ������, ������� ��������� ����� /2 ������/ �����, � ��� �� � ������
    dt1:=IncDay(Date, -vtimes[0]);
 //   dt1:=IncDay(Date, -88);
    va1:=Q.QLoadToVarDynArray2(
      'select id, path, dt_beg, dt_end from v_orders where nvl(in_archive, 0) <> 1 and dt_end is not null and dt_end < :dt1$d',
      [dt1]
    );
   for i:=0 to High(va1) do begin
      dt1:=EncodeDate(YearOf(va1[i][3]), MonthOf(va1[i][3]), DayOf(va1[i][3]));
      Q.QExecSql('update orders set in_archive = 1 where id = :id$i', [va1[i][0]]);
      CreateTaskRoot(mytskopMoveToArchive, [
        ['directory', va1[i][1] ],
        ['in_archive', 0 ],
        ['year', YearOf(va1[i][2]) ]
      ]);
    end;
  end;
 (*  2024!!!!!
  //������� ������� � �����
  if S.NNum(vtimes[0])>= 10 then begin
    //��������� ������������� ������ �������� ������� �������� ������� � ���� ����������
    dt1:=IncDay(Date, -vtimes[0]);
    va1:=QLoadToVarDynArray2(
      'select id_order, path, dt_beg, dt_end from uchet.v_to_orders_list_current where to_char(dt_end, :mask$s) <> :0$s and dt_end < :dt1$d',
      VarArrayOf(['HH24:MI:SS', '00:00:00', dt1])
    );
    for i:=0 to High(va1) do begin
//      if not(va1[i][3] = null) and (DaysBetween(Date, va1[i][3]) > vtimes[0]) then begin
        dt1:=EncodeDate(YearOf(va1[i][3]), MonthOf(va1[i][3]), DayOf(va1[i][3]));
        QExecSql('update uchet.to_orders set dt_end = :dt_end$d where id_order = :id$i', VarArrayOf([dt1, va1[i][0]]));
        CreateTaskRoot(mytskopMoveToArchive, [
          ['directory', va1[i][1] ],
          ['year', YearOf(va1[i][2]) ]
        ]);
//      end;
    end;
  end;
  //�������� ������� � ������� �
  if S.NNum(vtimes[1])>= 10 then begin
//vtimes[1]:=100;
    //������� ������ � ������ ����, �� � ���� ������ �������, � ��� ���� ������ ��������� ������� �����,
    //� ������ ��� ����������� � ������������ � �����
    //��������� ������ ������� restsum � �� ������, �� �� ����� �� ������� ���� ����� �������� 0,
    //� ��� ���� ���� ���� ������� ������ ���� ������ ��� �� ������ ������� �����
    dt1:=IncDay(Date, -vtimes[1]);
    va1:=QLoadToVarDynArray2(
      'select id_order, path, dt_beg, dt_end from v_sn_orders '+
      'where dt_end is not null and to_char(dt_end, :mask$s) = :0$s and org = ''�'' and '+
      'restsum <= 0 and dt_end < :dt1$d and dt_end < (select dt from sn_cash_revision_dt) and '+
      '(maxdtpaid is null or maxdtpaid < (select dt from sn_cash_revision_dt)) '+
      'order by dt_end',
      VarArrayOf(['HH24:MI:SS', '00:00:00', dt1])
    );
    Sys.SaveArray2ToFile(va1,'r:\1');
    for i:=00000 to High(va1) do begin
      QBeginTrans;
      ok:=False;
      repeat
        if QExecSql('delete from uchet.to_orders where id_order = :id$i', va1[i][0]) < 0 then Break;
        //if QRowsAffected > 0 then Sys.SaveTextToFile('r:\1f', VarToStr(va1[i][0])+#13#10, True);
        if QExecSql('update sn_calendar_t_basis set id_order = null where id_order = :id$i', va1[i][0]) < 0 then Break;
        //if QRowsAffected > 0 then Sys.SaveTextToFile('r:\1b', VarToStr(va1[i][0])+#13#10, True);
        if QExecSql('delete from sn_orders_add where id_order = :id$i', va1[i][0]) < 0 then Break;
        if QExecSql('delete from sn_order_payments where id_order = :id$i', va1[i][0]) < 0 then Break;
        ok:=True;
      until True;
      if ok then begin
        QCommitTrans;
        CreateTaskRoot(mytskopDeleteFromArchive, [
          ['directory', va1[i][1] ],
          ['year', YearOf(va1[i][2]) ]
        ]);
      end
      else QRollbackTrans;
    end;
  end;
*)
  ///������� ������ �� �������� ������
  if S.NNum(vtimes[2])>= 10 then begin
//vtimes[2]:=100;
    //������� ����� �� �������� ������
    //���� ������ ���� ��������� ������� � ��������� ���� ������� ������ ���� ������ ������� ���� � ���� ������� �����
    dt1:=IncDay(Date, -vtimes[2]);
    va1:=Q.QLoadToVarDynArray2(
      'select id, filename, type, maxdtpaid, dt from v_sn_calendar_accounts where '+
      'type <> 1 and paimentstatus = ''���������'' and maxdtpaid < :dt1$d and '+
      'maxdtpaid < (select dt from sn_cash_revision_dt) order by maxdtpaid asc',
      [dt1]
    );
//    Sys.SaveArray2ToFile(va1,'r:\2');
  //  exit;
    for i:=00000 to High(va1) do begin
      Q.QBeginTrans(True);
      ok:=False;
      repeat
        if Q.QExecSql('update sn_calendar_t_basis set id_acc = null where id_acc = :id$i', [va1[i][0]]) < 0 then Break;
        if Q.QExecSql('delete from sn_calendar_accounts where id = :id$i', [va1[i][0]]) < 0 then Break;
        ok:=True;
      until True;
      if ok then begin
        Q.QCommitTrans;
        CreateTaskRoot(mytskopDeleteAllFromAccounts, [
          ['directory', va1[i][1] ]
        ]);
      end
      else Q.QRollbackTrans;
    end;
  end;
  //�������� ���� ������ � ��������
  //��� �=1 ��������� ����, �������������� ��������
  if S.NNum(vtimes[3])>= 3 then begin
//vtimes[3]:=10;
    dt1:=TURV.GetTurvBegDate(Date);
    for i:=1 to vtimes[3] do begin
      dt1:=TURV.GetTurvBegDate(IncDay(dt1, -1));
    end;
    dt2:=dt1;
    Q.QExecSql('delete from turv_period where dt1 <= :dt1$d', [dt1]);
  end;
  //�������� ��������� ���������� ������ � ��������
  if S.NNum(vtimes[4])>= 3 then begin
//vtimes[4]:=10;
    dt1:=TURV.GetTurvBegDate(Date);
    for i:=1 to vtimes[4] do begin
      dt1:=TURV.GetTurvBegDate(IncDay(dt1, -1));
    end;
    Q.QExecSql('delete from payroll where dt1 <= :dt1$d', [dt1]);
  end;
end;

procedure TTasks.CalcPlannedOrders;
//��������� ���������� �� ������� �������� �������� ������� ��� ������ � ��� ���������
begin
  Orders.CrealeEstimateOnPlannesOrders(Date, False);
  Orders.CrealeEstimateOnPlannesOrders(Date, True);
end;

procedure TTasks.CloSEItmPeriod;
//������� ������ � ��� � ����� ����������� �� ���������� ����������� ������������
var
  i, j: Integer;
  va2: TVarDynArray2;
  dt1, dt2: TDateTime;
function GetLastSunday(AValue: TDateTime): TDateTime;
var
  Day: Integer;
begin
  Day := DayOfTheWeek(AValue);
  if Day = 7
    then Result := AValue - 7
    else Result := AValue - (Day);
end;
begin
  //�������� ������� - �������� ����������� ����� ���������, ��������� ����, � �������� ���������
  //������ ����� � �������� ��������
  //�������� ������ � �������, ���� �� ������������������
  //sq_closed_period_id
  va2 := Q.QLoadToVarDynArray2('select max(end_date) from dv.closed_period', []);
  if Length(va2) = 0
    then dt1 := IncMonth(Date, -1)
    else dt1 := IncDay(VarToDateTime(va2[0][0]), 1);
  dt2 := GetLastSunday(Date);
  if dt1 >= dt2 then
    Exit;
  Q.QIUD('i', 'dv.closed_period', 'dv.sq_closed_period_id', 'id_closed_period$i;period_name$s;start_date$d;end_date$d;is_closed$i',
    [-1, '����� ������', dt1, dt2, 1]
  );
end;




begin
  Tasks:=TTasks.Create;
end.
