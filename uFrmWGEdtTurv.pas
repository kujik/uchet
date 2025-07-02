unit uFrmWGEdtTurv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd,
  ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGEdtTurv = class(TFrmBasicGrid2)
  private
    FPeriodStartDate: TDateTime;
    FPeriodEndDate: TDateTime;
    FDayColumnsCount: Integer;
    FIdDivision: Integer;
    FArrTitle: TVarDynArray2;
    FTurvCodes: TNamedArr;
    FArrTurv: array of array of array of Variant;
    FEditInGrid1: Boolean;
    FInEditMode: Boolean;
    FDayColWidth: Integer;


    function  PrepareForm: Boolean; override;
    function  LoadTurv: Boolean;
    function  LoadTurvCodes: Boolean;
    function  GetTurvCode(AValue: Variant): Variant;
    function  GetTurvCell(ARow, ADay, ANum: Integer): Variant;
    procedure PushTurvToGrid;
    procedure PushTurvCellToGrid(ARow, ADay: Integer);

    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;

  public
  end;

var
  FrmWGEdtTurv: TFrmWGEdtTurv;

implementation

uses
  uTurv;

{$R *.dfm}

const
  cExists = 0;
  cTRuk = 1;               //����� �� ��������
  cTPar =2;                //����� ������
  cTSogl = 3;              //����� �������������
  cCRuk = 4;               //��� ������������
  cCPar = 5;               //��� ������
  cCSog = 6;               //��� �������������
  cSumPr = 7;              //����� ������
  cComPr = 8;              //����������� � ������
  cSumSct = 9;             //����� ������
  cComSct = 10;            //����������� � ������
  cVyr = 11;               //����� �� ���������
  cColor = 12;             //���� ����
  cColorF = 13;            //���� ������
  cComRuk = 14;            //����������� ������������
  cComPar = 15;            //����������� �������
  cComSogl = 16;           //�� �������� �� ��������������
  cBegTime = 17;           //����� ������� �� �������
  cEndTime = 18;           //����� ����� �� �������
  cSetTime = 19;           //���� 1, �� ������ ��������������. ��������������� � 1 ���� ��� ������ �� ������ ��� �������� �� ���� ����� ������. ������������ ��� ����� �������� � ������ �������          ���!!! - 1, ����� ����� �� ������� worktime2 �����������
  cNight = 20 ;            //����� � ����� � ������ �����
  cItog = 21;              //�������� ������, ������� ������������

  cTlIdW = 0;             //id worker
  cTlIdJ = 1;             //id job
  cTlW = 2;               //workername
  cTlJ = 3;               //job
  cTlPremium = 5;         //������ �� �������� ������
  cTlcomm = 6;            //������������, ����� ��� ���������

  cTmM = 1;               //����� ��� ��� �� ��������
  cTmP = 2;               //����� ��� ��� ������
  cTmV = 3;               //����������� ����� ��� ���

function TFrmWGEdtTurv.PrepareForm: Boolean;
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  Result := False;

  Caption:='~����';

//  Mode := fEdit;
//  ID := 2234;

  Q.QLoadFromQuery('select id, id_division, code, name, dt1, dt2, committxt, commit, editusers, status from v_turv_period where id = :id$i', [ID], va2);

  if Length(va2) = 0 then
    Exit;

  FIdDivision := va2[0][1];
  FPeriodStartDate := va2[0][4];
  FPeriodEndDate := va2[0][5];
  FDayColumnsCount := DaysBetween(FPeriodEndDate, FPeriodStartDate) + 1;


  FDayColWidth := 55;

  //��������� 16 ������� ��� ������� ������
  //��������� ������������ ��� �� ����
  //���� ������������� ������� � �������
  //������ �������, ������� ���� ����� �������
  va2 := [];
  for i := 1 to 16 do begin
    va2 := va2 + [[
      'd' + IntToStr(i) + '$s',
      S.IIfStr(IncDay(FPeriodStartDate, i - 1) > FPeriodEndDate, '_') +
        '������|' + IntToStr(DayOf(IncDay(FPeriodStartDate, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FPeriodStartDate, i - 1))],
      IntToStr(FDayColWidth) + ';R',
      'e'
    ]];
  end;

  Frg1.Opt.SetFields([
//  ['id$i','_id','40'],
    ['x$s', '*','20'],
    ['worker$s','��������|���','200'],
    ['job$s','��������|���������','100'],
    ['r$i','_��������|������','0']
    ] + va2 + [
    ['premium_p$f', '�����|�����', '50'] ,
    ['time$f', '�����|������ �� ������', '50'],
    ['premium$f', '�����|������', '50'],
    ['penalty$f', '�����|������', '50'],
    ['comm$s', '�����|�����������', '100']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.SetInitData([], '');
//  Frg1.Opt.SetTable('v_ref_work_schedules');

  Result := inherited;
  if not (Result and LoadTurvCodes and LoadTurv) then
    Exit;

  PushTurvToGrid;

end;

function TFrmWGEdtTurv.LoadTurv: Boolean;
var
  i, j, k: Integer;
  v, vs: TVarDynArray2;
  v2: TVarDynArray;
  v1: Variant;
  dt, dt1, dtbeg, dtend: TDateTime;
  y, m: Integer;
  res: Integer;
  st: string;
begin
  //������� ������ ���������� ��� ������� ����
  FArrTitle := [];
  FArrTurv := [];
  v := [];
  vs := [];
  v2 := [];
  v := Turv.GetTurvArrayFromDb(FIdDivision, FPeriodStartDate);
  Result := Length(v) > 0;
  if not Result then
    Exit;
  //�������� �� ������
  for i := 0 to High(v) do begin
   //v:  0-����1, 1-����2, 2-���� ���������, 3-��� ���������, 4-���� ���������, 5-��������� ���������, 6-����� �������: 1=��������� 2=������
    SetLength(FArrTitle, i + 1, 7);
    SetLength(FArrTurv, i + 1, 31, cItog + 1);
    //������ ���������� (��������, ���������...)
    FArrTitle[i][cTlIdW] := v[i][2];  //id worker
    FArrTitle[i][cTlIdJ] := v[i][4];  //id job
    FArrTitle[i][cTlW] := v[i][3];  //workername
    FArrTitle[i][cTlJ] := v[i][5];  //job
    FArrTitle[i][4] := '';       //ccegory
    FArrTitle[i][cTlPremium] := 0;        //������ �� �������� ������
    FArrTitle[i][cTlComm] := '';       //������������, ����� ��� ���������
    //������ ����_��� � ��� ������� ��������� � ����������, � ������� �� � ���� ����, ��������� �� ����
    vs := Q.QLoadToVarDynArray2(
      'select dt, worktime1, worktime2, worktime3, id_turvcode1, id_turvcode2, id_turvcode3, premium, premium_comm, penalty, penalty_comm, production, ' +
      'null, null, comm1, comm2, comm3, begtime, endtime, settime3, nighttime ' +
      'from turv_day where id_worker = :id_worker$i and dt >= :dtbeg$d and dt <= :dtend$d order by dt',
       [FArrTitle[i][cTlIdW], v[i][0], v[i][1]]
    );
    //������ �� ������� ����
    for j := 1 to 16 do begin
      //�������� ����
      for k := 0 to cItog do
        FArrTurv[i][j][k] := null;
      //���� ������ �������� ��� ������ �������� ����, �� ������� ��� ������ ������ � ���� ���
      if (IncDay(FPeriodStartDate, j - 1) < v[i][0]) or (IncDay(FPeriodStartDate, j - 1) > v[i][1]) then
        FArrTurv[i][j][0] := -1
      else begin
        FArrTurv[i][j][cExists] := 0;
        for k := 0 to High(vs) do
          if DayOf(vs[k][0]) = DayOf(FPeriodStartDate) + j - 1 then begin
            //������ ���� � ���� � ��
            FArrTurv[i][j][cExists] := 1;    //id
            FArrTurv[i][j][cTRuk] := vs[k][1];    //����� �� ��������
            FArrTurv[i][j][cTPar] := vs[k][2];    //����� ������
            FArrTurv[i][j][cTSogl] := vs[k][3];    //����� �������������
            FArrTurv[i][j][cCRuk] := vs[k][4];    //��� �� ��������
            FArrTurv[i][j][cCPar] := vs[k][5];    //��� �� ������
            FArrTurv[i][j][cCSog] := vs[k][6];    //��� �������������
            FArrTurv[i][j][cSumPr] := vs[k][7];    //����� ������
            FArrTurv[i][j][cComPr] := vs[k][8];     //����������� � ������
            FArrTurv[i][j][cSumSct] := vs[k][9];    //����� ������
            FArrTurv[i][j][cComSct] := vs[k][10];     //����������� � ������
            FArrTurv[i][j][cVyr] := vs[k][11];    //����� �� ���������
            FArrTurv[i][j][cComRuk] := vs[k][14];    //����������� ������������
            FArrTurv[i][j][cComPar] := vs[k][15];    //���������� �� �������
            FArrTurv[i][j][cComSogl] := vs[k][16];    //���������� �� ��������������
            FArrTurv[i][j][cBegTime] := vs[k][17];    // ����� ������� �� �������
            FArrTurv[i][j][cEndTime] := vs[k][18];    //����� ����� �� �������
            FArrTurv[i][j][cSetTime] := vs[k][19];    //1, ����� ����� �� ������� worktime2 �����������
            FArrTurv[i][j][cNight] := vs[k][20];    //����� � ������ �����
          end;
      end;
    end;
    //��������� �� �� ������ � ������
    vs := Q.QLoadToVarDynArray2(
      'select premium, comm from turv_worker where id_worker = :id_worker$i and id_division = :id_division$i and id_job = :id_job$i and dt1 = :dt1$d',
      [FArrTitle[i][0], FIDDivision, FArrTitle[i][1], FPeriodStartDate]
    );
    if Length(vs) > 0 then begin
      FArrTitle[i][cTlPremium] := vs[0][0];
      FArrTitle[i][cTlComm] := vs[0][1];
    end;
  end;
end;

function TFrmWGEdtTurv.LoadTurvCodes: Boolean;
//�������� ���������� ����� ����
begin
  Result := False;
  Q.QLoadFromQuery('select id, code, name from ref_turvcodes order by code', [], FTurvCodes);
  Result := True;
end;


function TFrmWGEdtTurv.GetTurvCode(AValue: Variant): Variant;
//������� ��� ���� �� ���� ����� ����
var
  i: Integer;
begin
  Result := null;
  i := A.PosInArray(AValue, FTurvCodes.V, 0);
  if i >= 0 then
    Result := FTurvCodes.V[i][1];
end;

function TFrmWGEdtTurv.GetTurvCell(ARow, ADay, ANum: Integer): Variant;
begin
  if FArrTurv[ARow][ADay][ANum] <> null then
    Result := FArrTurv[ARow][ADay][ANum]
  else
    Result := GetTurvCode(FArrTurv[ARow][ADay][ANum + 3]);
end;

procedure TFrmWGEdtTurv.PushTurvToGrid;
var
  i, j: Integer;
begin
  for i := 0 to High(FArrTitle) do begin
    Frg1.MemTableEh1.Last;
    Frg1.MemTableEh1.Insert;
    Frg1.MemTableEh1.FieldByName('worker').Value := FArrTitle[i][2];
    Frg1.MemTableEh1.FieldByName('job').Value := FArrTitle[i][3];
//    Frg1.MemTableEh1.FieldByName('category').Value := null;
    Frg1.MemTableEh1.Post;
    for j := 1 to 16 do begin
      PushTurvCellToGrid(i, j);
    end;
  end;
end;

procedure TFrmWGEdtTurv.PushTurvCellToGrid(ARow, ADay: Integer);
//��������� ������ � ����� ����� �� ��������� ������� ������
var
  st: string;
  v, v0, v1, v2: Variant;
  color: Integer;
  i, j: Integer;
  sum: TVarDynArray;
  e: extended;
  b: Boolean;
{
   ���� ���������� ����� �������� � �����������, �� ��������� ���, ���������� �� �������� � ������� ������ �� ������� � ������
   � ��������� ������, �������� �� ������� ����������� ������ ���� �����������
   ��� ����, ���� �� ����������� �������� ������, ��������� �������� �� ������� � ����� ���
   ���� ����������� ����� ������, � ������� �� ������� ������ � ������� ����� ����, �� ��������� ����� ������
   ���� ���������� ��� ������, �� ��������� ��� ������, ���������� �������� �������
   �� ���� ���������� ������ � ������� � ������, ��� ���� ���� �� ��� ����� � ������ ���, ��� ��� �������, �� ���������� ����� ����,
   �� ���� ��������� ������, �� ���� �������, ������� ������������
}
begin
  v := FArrTurv[ARow][ADay][0];
  //������� ������������� ����� �������� ������ �����
  if ARow = -1 then
    ARow := Frg1.MemTableEh1.RecNo - 1;
  v0 := GetTurvCell(ARow, ADay, cTmV);  //����������� ����� ��� ���
  v1 := GetTurvCell(ARow, ADay, cTmM);  //����� ��� ��� �� ��������
  v2 := GetTurvCell(ARow, ADay, cTmP);  //����� ��� ��� ������
  color := 0;
    //���� ������ ����������� �����/���, �� ������� ���, ����� ������� �� ��������
  if v0 = null then begin
    if (v1 = null) and (v2 = null) then begin
      color := 0;
    end
    else if (v1 <> null) and (v2 = null) then begin
      color := 2;   //�������
      v0 := v1;
    end
    else if (v1 = null) and (v2 <> null) then begin
      color := 1;   //�������
      v0 := v2;
    end
    else if (not S.IsNumber(S.NSt(v1), 0, 24)) and (not S.IsNumber(S.NSt(v2), 0, 24)) then begin
      v0 := v2;
    end
    else if S.IsNumber(S.NSt(v1), 0, 24) and S.IsNumber(S.NSt(v2), 0, 24) and (abs(StrToFloat(S.NSt(v1)) - StrToFloat(S.NSt(v2))) <= Module.GetCfgVar(mycfgWtime_autoagreed)) then begin
      v0 := v2;
      if v1 <> v2 then
        color := -1; //������� ���� ������
    end
    else begin
      v0 := v2;
      color := 1;
    end;
  end;
  FArrTurv[ARow][ADay][cColor] := color;
    //��� �������������� � �������� ����� ����� ���������� � ��� ����� �� ��������/������������
  if (FEditInGrid1) and (FInEditMode) then
    v0 := v1;
    //����������� ������, ���� �����
  if S.IsNumber(S.NSt(v0), 0, 24) then
    st := FormatFloat('0.00', S.VarToFloat(v0))
  else
    st := S.NSt(v0);
    //������� �������� �� ���������� ������� ������
    //��� ���� �� ������ ����������� ������ ����� ��������� ������ ������, ������������ ������ ��������� �� ����������
  Frg1.SetValue('d' + IntToStr(ADay), ARow, False, st);

  //����� � ������ ����� �������
  Setlength(sum, 3);
  b := True;
  //���� �� ����
  for i := 1 to FDayColumnsCount do begin
      //����� - �� ��������, ���� ����������� ������ �� ������, ���� ����������� ������������� �� ���
    e := S.NNum(FArrTurv[ARow][i][1]);
    if (FArrTurv[ARow][i][2] <> null) or (FArrTurv[ARow][i][5] <> null) then
      e := S.NNum(FArrTurv[ARow][i][2]);
    if (FArrTurv[ARow][i][3] <> null) or (FArrTurv[ARow][i][6] <> null) then
      e := S.NNum(FArrTurv[ARow][i][3]);
    sum[0] := sum[0] + e;
    sum[1] := sum[1] + S.NNum(FArrTurv[ARow][i][7]);
    sum[2] := sum[2] + S.NNum(FArrTurv[ARow][i][9]);
      //������ ������� � ������, ��� ������ �������� � ��� ���� �� ����� - �� ���� ����������� ������� ����
    if (S.NNum(FArrTurv[ARow][i][12]) = 1) or (S.NNum(FArrTurv[ARow][i][12]) = 2) or ((FArrTurv[ARow][i][0] <> -1) and (FArrTurv[ARow][i][1]) = null) then
      b := False;
  end;
  //�������� �������� ������ ��������
  Frg1.SetValue('time', ARow, False, FormatFloat('0.00', S.NNum(sum[0])));
  Frg1.SetValue('premium_p', ARow, False, FormatFloat('0.00', S.NNum(FArrTitle[ARow][cTlPremium])));
  Frg1.SetValue('premium', ARow, False, FormatFloat('0.00', S.NNum(sum[1])));
  Frg1.SetValue('penalty', ARow, False, FormatFloat('0.00', S.NNum(sum[2])));
    //������ ������� ������  //!!!
{  Status := 1;
  for j := 0 to High(ArrTurv) do begin
    for i := 1 to DayColumnsCount do begin
      if (ArrTurv[j][i][atColor] = -1) and (Status = 1) then
        Status := 2;
      if ArrTurv[j][i][atColor] = 1 then
        Status := 3;
      if Status = 3 then
        break
    end;
    if Status = 3 then
      break
  end}
end;



(*
//�������� ������
procedure TDlg_TURV.DBGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
  AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
  var Params: TColCellParamsEh; var Processed: Boolean);
var
  v1, v2, v3, v4: Variant;
  ARow, c: Integer;
begin
  inherited;
  //������ ������ ������� � �����
  if (Params.Col<5)or(Params.Col>5+16-1) then Exit;
//  v:=MemTableEh1.RecordsView.MemTableData.RecordsList[Params.row-1].DataValues['ADay'+ IntToStr(Params.Col-4),dvvValueEh];
  //������� �����������
  v1:=ArrTurv[Params.row-1][Params.Col-4][atComRuk];
  v2:=ArrTurv[Params.row-1][Params.Col-4][atComPar];
  v3:=ArrTurv[Params.row-1][Params.Col-4][atComSogl];
  v4:=ArrTurv[Params.row-1][Params.Col-4][atNight];
  //���� ������, �� ����� ����������� ���������
//  if (v<>'8.00')and(v<>'8,00')  then exit;
  //������, ���� ��� �������� �����������
  if (((VarIsEmpty(v1))or(S.NSt(v1) = '')) and ((VarIsEmpty(v2))or(S.NSt(v2) = '')) and ((VarIsEmpty(v3))or(S.NSt(v3) = '')) and ((VarIsEmpty(v4))or(S.NNum(v4) = 0))) then Exit;
  //����������� ���������
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
  if S.NSt(v1) + S.NSt(v2) + S.NSt(v3) <> '' then begin
    //� ������� ��������� �����������
    TDBGridEh(Sender).Canvas.Pen.Width:=1;
    //���� ���� ����������� �����������/�������������, �� ��������� ���������, ���� ������ ������, �� �����
    if (VarToStr(v2) <> '')or(VarToStr(v3) <> '')
      then TDBGridEh(Sender).Canvas.Brush.Color:=RGB(255,0,255)
      else TDBGridEh(Sender).Canvas.Brush.Color:=clBlue;
    //�������� ������������� � ������� ����� ���� ������
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top , ARect.Left+7, ARect.Top+7);
  end;
  if S.NNum(v4) <> 0 then begin
    TDBGridEh(Sender).Canvas.Pen.Width:=1;
    TDBGridEh(Sender).Canvas.Brush.Color:=clBlack;
    //�������� ������������� � ����� ������ ���� ������
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Bottom - 7 , ARect.Left+7, ARect.Bottom);
  end;
  //���� ��� ����������, ���� �� ��������� �� ����� ����������� ���������
  Processed:=True;
end;
*)

procedure TFrmWGEdtTurv.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  Row, Day: Integer;
  Color: Integer;
begin
  Row := Params.Row - 1;
  Day := StrToIntDef(Copy(FieldName, 2, 2), -1);
  if Day <> -1 then begin
    case FArrTurv[Row][Day][cColor] of
      1 : Params.Background := clRed;
      2 : Params.Background := clYellow;
      -1: Params.Font.Color := clRed;
    end;
  end
  else Params.Background := clmyGray;
end;


end.
