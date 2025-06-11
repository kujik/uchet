unit D_Rep_Smeta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, Vcl.StdCtrls, Vcl.Buttons, Math, uString,
  System.IOUtils, Types, ComObj
  ;

type
  TDlg_Rep_Smeta = class(TForm_Normal)
    Bt_Go: TBitBtn;
    Lb_AddOrders: TLabel;
    Bt_AddOrders: TBitBtn;
    Memo1: TMemo;
    Bt_Stop: TBitBtn;
    Lb_Progress: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure Bt_AddOrdersClick(Sender: TObject);
    procedure Bt_GoClick(Sender: TObject);
    procedure Bt_StopClick(Sender: TObject);
  private
    { Private declarations }
    OrIds, OrNum: string;
    OrCnt: Integer;
    Orders: TVarDynArray2;
    Stop: Boolean;
    Excel, Sh: Variant;
    ExcelExecute: Boolean;
    a1: TVarDynArray2;
    procedure SetLb_AddOrders;
    procedure Go;
    function LoadSmeta(FileName: string): Integer;
    procedure ExportToXlsxA7;
  public
    { Public declarations }
  end;

var
  Dlg_Rep_Smeta: TDlg_Rep_Smeta;

implementation

uses
  uSettings,
  uForms,
  uDBOra,
  uData,
  uWindows,
  uMessages,
  uExcel
  ;

  {$R *.dfm}

procedure TDlg_Rep_Smeta.Bt_AddOrdersClick(Sender: TObject);
var
  v: TVarDynArray;
  i, j:Integer;
  st1, st2: string;
  vv: Variant;
const
  MaxCnt = 10000;
begin
  vv:=VarArrayOf(['%', OrIds, 'dt_pnr', '���� �������']);
  Wh.ExecAdd(myfrm_J_Orders_SEL_1, Self, fNone, 0, [], vv, True);
{
//!!! �� ������� ����� ����������� ��������� ����� ExecDlgFormAdd (ShowMessage �� ������������, ����������� ���������, MyWarningMessage �������� ��������� ��� �����������)!!!
ShowMessage('!!!+++'); exit;
self.Visible:=False;
MyWarningMessage('������� �������� ����� �������!'#13#10'����� ��������� ������ 300 ������ �������.');
self.Visible:=True;
exit;
}
//  if Length(Wh.SelectDialogResult) = 0 then Exit; //++
  OrIds:='';
  OrNum:='';
  if Length(Wh.SelectDialogResult2) > MaxCnt
    then MyWarningMessage('������� �������� ����� �������!'#13#10'����� ��������� ������ 300 ������ �������.');

  OrCnt:=Min(Length(Wh.SelectDialogResult2), MaxCnt);
  for i:=0 to Min(High(Wh.SelectDialogResult2), MaxCnt-1) do begin
    OrIds:=OrIds + S.IIFStr(Length(OrIds) = 0, '', ';') + IntToStr(Integer(Wh.SelectDialogResult2[i][0]));
    OrNum:=OrNum + S.IIFStr(Length(OrNum) = 0, '', ';  ') + Wh.SelectDialogResult2[i][2];
  end;
  SetLb_AddOrders;
  Orders:=Copy(Wh.SelectDialogResult2);
end;

procedure TDlg_Rep_Smeta.SetLb_AddOrders;
begin
  Lb_AddOrders.Caption:=S.IIFStr(OrCnt = 0,
    '������ �� �������!',
    IntToStr(OrCnt) +
//    ' ������������' + S.GetEnding(OrCnt,'��','��','��') +
    ' �����' + S.GetEnding(OrCnt,'','�','��'));
end;

procedure TDlg_Rep_Smeta.Bt_GoClick(Sender: TObject);
begin
  inherited;
  Go;
end;

procedure TDlg_Rep_Smeta.Bt_StopClick(Sender: TObject);
begin
  inherited;
  Stop:=True;
end;

procedure TDlg_Rep_Smeta.Go;
var
  i,j,k,sm:Integer;
  st: string;
  fe: Integer;
  Err: string;
  SnFiles: TStringDynArray;
  b: Boolean;
const
  smtypes: array of string = ['������ �� ���������!','����� ������� �������','����� ������ �������','������ ��','������ �� �����'];
begin
  Stop:=False;
  Memo1.Lines.Clear;
  Lb_Progress.Caption:='';
  a1:=[[]];
  SetLength(a1, 50000);
  for i:= 0 to High(Orders) do begin
    Application.ProcessMessages;
    if Stop then Exit;
    Err:='';
    repeat;
    st:=Module.GetPath_OrderCurrent(Orders[i,3]) + '\' + Orders[i,1];
    if not DirectoryExists(st) then begin
      st:=Module.GetPath_OrderArchive(Orders[i,3]) + '\' + Orders[i,1];
      if not DirectoryExists(st) then
        begin Err:='�� ������ ������� ������!'; Break; end;
    end;
    if not DirectoryExists(st + '\��') then
      begin Err:='�� ������ ������� ��!'; Break; end;
    SnFiles:=[];
    try
      SnFiles:=TDirectory.GetFiles(st + '\��', '*xls');
    finally
    end;
    if Length(SnFiles) = 0 then
      begin Err:='��� �� ����� �����!'; Break; end;
    b:=True;
    for j:=0 to High(SnFiles) do begin
      sm:=LoadSmeta(SnFiles[j]);
      b:=(sm > 0) and b;
    end;
    if not(b)
      then begin Err:='����� � �� �� �������� ������� �����!'; Break; end
      else begin Err:=smtypes[sm]; end;
    until True;
    if Err<>'' then begin
      Memo1.Lines.Add(Orders[i, 2] + ':  ' + Err);
    end;
    Application.ProcessMessages;
    Lb_Progress.Caption:='����������:  ' + IntToStr(i+1) + ' �� ' + IntToStr(Length(Orders));
  end;
  Lb_Progress.Caption:='���������� ������';
  ExportToXlsxA7;
  Lb_Progress.Caption:='���������';
end;

procedure TDlg_Rep_Smeta.ExportToXlsxA7;
var
  i,j,k,rn,x,y,y1,y2 : Integer;
  Rep: TA7Rep;
  FileName, gr: string;
  buf: Variant;
  changed: Boolean;
  a2: TVarDynArray;
  st: string;
begin
  for k := 0 to High(a1) do
    if High(a1[k]) = -1 then Break;
  SetLength(a1, k);
  A.VarDynArray2Sort(a1, +1);
{  repeat
    changed := False;
    for k := 0 to High(a1) - 1 do
      if a1[k][0] > a1[k + 1][0] then
      begin // �������� k-� � k+1-� ��������
        for j:=0 to High(a1[k]) do begin
          buf := a1[k][j];
          a1[k][j] := a1[k + 1][j];
          a1[k + 1][j] := buf;
        end;
        changed := True;
      end;
  until not changed;}
  FileName:='������ �� �����';
  FileName:=Module.GetReportFileXls(FileName);
  if FileName = '' then Exit;
  Rep:= TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName);
  except
    Rep.Free;
    Exit;
  end;
  Rep.OpenWorkSheet('��');
  Rep.PasteBand('HEADER');
  gr:='';
  j:=0;
  for i:=0 to High(a1) do begin
    if High(a1[i]) = -1 then Break;
    try
    if S.NSt(a1[i][0]) <> gr then begin
      Rep.PasteBand('TABLE');
      gr:=S.NSt(a1[i][0]);
      Rep.SetValue('#N#', VarToStr(gr));
      Rep.SetValue('#NAME#', '');
      Rep.SetValue('#CODE#', '');
      Rep.SetValue('#DIM#', '');
      Rep.SetValue('#QNT#', '');
      Rep.SetValue('#COMM#', '');
    end;
    inc(j);
    Rep.PasteBand('TABLE');
    Rep.SetValue('#N#', VarToStr(j));
    Rep.SetValue('#NAME#', VarToStr(a1[i][1]));
    Rep.SetValue('#CODE#', VarToStr(a1[i][2]));
    Rep.SetValue('#DIM#', VarToStr(a1[i][3]));
    if S.IsNumber(a1[i][4], -999999999999, +999999999999, 10)
      then Rep.SetValue('#QNT#', VarToStr(a1[i][4]))
      else Rep.SetValue('#QNT#', '');
    st:='';
    if VarToStr(a1[i][5]) <> '' then begin
      A.ExplodeP(VarToStr(a1[i][5]), '|', False, a2);
      A.VarDynArraySort(a2, True);
      buf:=''; st:='';
      for k:=0 to High(a2) do begin
        if a2[k] <> buf then begin
          buf:=a2[k];
          st:=st + S.IIf(st = '', '', '|') + buf;
        end;
      end;
    end;
    Rep.SetValue('#COMM#', st);
    except
//    st:=VarToStr(a1[i][1]);
    end;
  end;
  Rep.DeleteCol1;
  Rep.Show;
  Rep.Free;
end;

function TDlg_Rep_Smeta.LoadSmeta(FileName: string): Integer;
var
  i,j,k,sti,irow: Integer;
  dtype, doctype: Integer;
  nm, gr, st, st1, st2: string;
const
  cGr = 0;
  cNo = 1;
  cName = 2;
  cCode = 3;
  cEd = 4;
  cQnt1 = 5;
  cQntA = 6;
  cComm = 7;
begin
  if not ExcelExecute then begin
    Excel := CreateOleObject('Excel.Application');
    ExcelExecute:= True;
  end;
  Excel.Workbooks.Open(FileName, True, True);
  Excel.DisplayAlerts := False; // for prevent error in SetValue procedure, where VarName not fount for replace
  Excel.Visible := False;
  dtype:=0;
  for i:=1 to Excel.Workbooks[1].WorkSheets.Count do begin
    if Excel.Workbooks[1].WorkSheets[i].Name = '��'
      then begin dtype:=1; Break; end
      else if Excel.Workbooks[1].WorkSheets[i].Name = '����� ������'
        then begin dtype:=2; Break; end;
  end;
//MyInfoMessage(inttostr(dtype));
  doctype:=0;
  if dtype > 0 then begin
    sh:=Excel.Workbooks[1].WorkSheets[i];
    if S.NSt(sh.Cells[3,1].Value) = '��������' then begin
      //����� ������� �������
      if (S.NSt(sh.Cells[4,1].Value) = '������������ �������')and
        (S.NSt(sh.Cells[5,1].Value) = '� �������� ������ ��')and
        (S.NSt(sh.Cells[16,1].Value) = '����� �� ���������')and
        (S.NSt(sh.Cells[17,1].Value) = '�')
        then begin
          DocType:=1; sti:=18;
        end;
    end
    else if S.NSt(sh.Cells[13,1].Value) = '��������:' then begin
      //����� ������ �������
      if (S.NSt(sh.Cells[14,1].Value) = '������������ �������:')and
        (S.NSt(sh.Cells[19,1].Value) = '����� �� ���������')and
        (S.NSt(sh.Cells[20,1].Value) = '�')
        then begin
          DocType:=2; sti:=21;
        end;
    end
    else if Trim(S.NSt(sh.Cells[1,1].Value)) = '����� ������ �� ���������' then begin
      //������ ��
      if (Trim(S.NSt(sh.Cells[2,1].Value)) = '����� ������:')and
        (Trim(S.NSt(sh.Cells[3,1].Value)) = '��������:')and
        (Trim(S.NSt(sh.Cells[4,1].Value)) = '�������')
        then begin
          DocType:=3; sti:=7;
        end;
    end
    else if Trim(S.NSt(sh.Cells[2,2].Value)) = '��������' then begin
      //������������ ������ ��
      if (Trim(S.NSt(sh.Cells[6,6].Value)) = '�����:')and
        (Trim(S.NSt(sh.Cells[6,7].Value)) = '����������')and
        (Trim(S.NSt(sh.Cells[9,2].Value)) = '������������')
        then begin
          DocType:=4; sti:=10;
        end;
    end;
  end;
  Result:= doctype;
  if Result = 0 then begin
    Excel.Workbooks[1].Close;
    Exit;
  end;

  irow:=sh.UsedRange.Row + sh.UsedRange.Rows.Count + 3; //!
  gr:='��������� ��� �����';
  for i:=sti to sti + 10000 do begin
    Application.ProcessMessages;
    try
    if (doctype in [1, 3]) then begin
      //������ ����� � ������ �� �����
      //'��������� ���������, ������ ����������� (�� ������) - ����� � ������ �������
      //���������� ��������� ����� �� ������� �������� � ��� (��� �������� �� ��� ������), � �� ���������
      If Not (((S.NSt(Sh.Cells[i, 1].Value) = '') And (S.NSt(Sh.Cells[i, 2].Value) = '')) Or ((S.NSt(Sh.Cells[i, 1].Value) = '0') And (S.NSt(Sh.Cells[i, 2].Value) = '0'))) Then begin
        If (S.NSt(Sh.Cells[i, 2].Value) <> '') And (S.NSt(Sh.Cells[i, 2].Value) <> '0') Then begin
          nm:=sh.cells[i,2].Value;
          for j:=0 to High(a1) - 1 do
            if (High(a1[j]) = -1) or (S.NSt(a1[j, 1]) = nm)
              then Break;
          st:=S.IIFStr(doctype = 1, Sh.Cells[i, 16].Value, Sh.Cells[i, 10].Value);
          if High(a1[j]) = -1
            then a1[j] := [gr, nm, Sh.Cells[i, 3].Value, Sh.Cells[i, 4].Value, S.NNum(Sh.Cells[i, 9].Value), st]
            else begin
              a1[j][4]:=a1[j][4] + S.NNum(Sh.Cells[i, 9].Value);
              if st <> '' then a1[j][5]:=a1[j][5] + '|' + st;
            end;
        end
        else begin
          gr:=S.NSt(Sh.Cells[i, 1].Value);
        end;
      end
      else if i > irow then Break;
{          k = k + 1
          sh.Cells(j, 1) = k 'no
          sh.Cells(j, 2) = arr(i, 2) '������������
          sh.Cells(j, 3) = arr(i, 3) '���
          If sh.Cells(j, 3) = "0" Then sh.Cells(j, 3) = ""
          sh.Cells(j, 4) = arr(i, 4) '�� ���
          sh.Cells(j, 5) = arr(i, 5) '���� �����
          sh.Cells(j, 9) = arr(i, 9) '�������� � ���
          If doctype = 1 Then sh.Cells(j, 10) = arr(i, 16) Else sh.Cells(j, 10) = arr(i, 11) '����������
          If sh.Cells(j, 10) = "0" Then sh.Cells(j, 10) = ""
          If sh.Cells(j, 10) = "0" Then sh.Cells(j, 10) = ""
          j = j + 1
        Else
          sh.Cells(j, 1) = ""
          sh.Cells(j, 2) = arr(i, 1) '������
          j = j + 1
        End If
      End If}
    end;
    if (doctype in [2]) then begin
      //����� �����
      //������ ��������� - ������ ������ �������, ������ ��� � �������� � ���������
      If Not (((S.NSt(Sh.Cells[i, 1].Value) = '') And (S.NSt(Sh.Cells[i, 4].Value) = '')) Or ((S.NSt(Sh.Cells[i, 1].Value) = '0') And (S.NSt(Sh.Cells[i, 4].Value) = '0'))) Then begin
        If (S.NSt(Sh.Cells[i, 1].Value) <> '') And (S.NSt(Sh.Cells[i, 1].Value) <> '0') Then begin
          nm:=sh.cells[i,4].Value;
st2:=Sh.Cells[i, 11].Value;
S.NNum(Sh.Cells[i, 11].Value);
          for j:=0 to High(a1) - 1 do
            if (High(a1[j]) = -1) or (S.NSt(a1[j, 1]) = nm)
              then Break;
          //st:=S.IIFStr(doctype = 1, Sh.Cells[i, 16].Value, Sh.Cells[i, 10].Value);
          st:=S.NSt(Sh.Cells[i, 12].Value);
          if High(a1[j]) = -1
            then a1[j] := [gr, nm, Sh.Cells[i, 6].Value, Sh.Cells[i, 8].Value, S.NNum(Sh.Cells[i, 11].Value), st]
            else begin
              a1[j][4]:=a1[j][4] + S.NNum(Sh.Cells[i, 11].Value);
              if st <> '' then a1[j][5]:=a1[j][5] + '|' + st;
            end;
        end
        else begin
          gr:=S.NSt(Sh.Cells[i, 4].Value);
        end;
{      If Not (((CStr(arr(i, 1)) = "") And (CStr(arr(i, 4)) = "")) Or ((CStr(arr(i, 1)) = "0") And (CStr(arr(i, 4)) = "0"))) Then
        If (arr(i, 1) <> "") And (arr(i, 1) <> 0) Then
          k = k + 1
          sh.Cells(j, 1) = k 'no
          sh.Cells(j, 1) = arr(i, 1) 'no
          sh.Cells(j, 2) = arr(i, 4) '������������
          sh.Cells(j, 3) = arr(i, 6) '���
          If sh.Cells(j, 3) = "0" Then sh.Cells(j, 3) = ""
          sh.Cells(j, 4) = arr(i, 8) '�� ���
          sh.Cells(j, 5) = arr(i, 9) '���� �����
          sh.Cells(j, 9) = arr(i, 11) '�������� � ���
          sh.Cells(j, 10) = arr(i, 12)
          If sh.Cells(j, 10) = "0" Then sh.Cells(j, 10) = ""
          j = j + 1
        Else
          sh.Cells(j, 1) = ""
          sh.Cells(j, 2) = arr(i, 4) '������
          j = j + 1
        End If
      end;}
      end
      else if i > irow then Break;
    end;
    if (doctype in [4]) then begin
      //������ �� �����
      //������ ��������� - ������ ������� �������� ������, � ������ �� ������, ������ � ������ �������
      if (S.NSt(Sh.Cells[i, 1].Value) <> '') or (S.NSt(Sh.Cells[i, 2].Value) <> '') then begin
        if S.IsNumber(S.NSt(Sh.Cells[i, 1].Value), 1 , 10000) and (S.NSt(Sh.Cells[i, 1].Value) <> '') then begin
          nm:=sh.cells[i,2].Value;
          for j:=0 to High(a1) - 1 do
            if (High(a1[j]) = -1) or (S.NSt(a1[j, 1]) = nm)
              then Break;
if nm = '���������/������/D25 ������' then begin

end;
          //st:=S.IIFStr(doctype = 1, Sh.Cells[i, 16].Value, Sh.Cells[i, 10].Value);
          st:=S.NSt(Sh.Cells[i, 7].Value);
          if High(a1[j]) = -1
            then a1[j] := [gr, nm, Sh.Cells[i, 5].Value, Sh.Cells[i, 4].Value, S.NNum(Sh.Cells[i, 6].Value), st]
            else begin
              a1[j][4]:=a1[j][4] + S.NNum(Sh.Cells[i, 6].Value);
              if st <> '' then a1[j][5]:=a1[j][5] + '|' + st;
            end;
        end
        else begin
          gr:=S.NSt(Sh.Cells[i, 1].Value);
        end;
      end
      else if i > irow then Break;
    end;
    except
    end;
  end;
  Excel.Workbooks[1].Close;
end;

procedure TDlg_Rep_Smeta.FormActivate(Sender: TObject);
begin
  inherited;
  Cth.SetBtn(Bt_AddOrders, mybtAdd, False, '�������� ������');
  Cth.SetBtn(Bt_Go, mybtGo, False, '�����');
  Cth.SetBtn(Bt_Stop, mybtCancel, False, '����');
  SetLb_AddOrders;
  Lb_Progress.Caption:='';
  Excel:=null;
  ExcelExecute:= False;
end;

end.
