unit uFrmWGEdtTurv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd,
  ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGEdtTurv = class(TFrmBasicGrid2)
    procedure Frg1DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh;  var CanShow: Boolean);
    procedure Frg1DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
      AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
    procedure Frg2DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
      AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
    procedure Frg1DbGridEh1DataHintShow(Sender: TCustomDBGridEh;
      CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint;
      Column: TColumnEh; var Params: TDBGridEhDataHintParams;
      var Processed: Boolean);
    procedure Frg2DbGridEh1DataHintShow(Sender: TCustomDBGridEh;
      CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint;
      Column: TColumnEh; var Params: TDBGridEhDataHintParams;
      var Processed: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FPeriodStartDate: TDateTime;
    FPeriodEndDate: TDateTime;
    FDayColumnsCount: Integer;
    FIdDivision: Integer;
    FDivisionName: string;
    FDivisionScehdule: string;
    FIsOffice: Boolean;
    FIsCommited: Boolean;
    FRgsCommit, FRgsEdit1, FRgsEdit2, FRgsEdit3: Boolean;  //�����
    FEditUsers: string;
    FStatus, FStatusOld : Integer;

    FArrTitle: TNamedArr;
    FTurvCodes: TNamedArr;
    FTurvCodeWeekend: Integer;
    FArrTurv: array of array of array of Variant;
    FInEditMainGridMode: Boolean;
    FInEditMode: Boolean;
    FIsDetailGridUpdated: Boolean;


    FDayColWidth: Integer;
    FLeftPartWidth: Integer;


    function  PrepareForm: Boolean; override;
    function  SetLock: Boolean;
    function  LoadTurv: Boolean;
    function  LoadTurvCodes: Boolean;
    function  GetTurvCode(AValue: Variant): Variant;
    function  GetTurvCell(ARow, ADay, ANum: Integer): Variant;
    procedure PushTurvToGrid;
    procedure PushTurvCellToGrid(ARow, ADay: Integer);
    procedure PushTurvCellToDetailGrid(ARow, ADay: Integer);
    procedure SetLblDivisionText;
    procedure SetLblWorkerText;
    procedure SetLblsDetailText;
    function  FormatTurvCell(v: Variant): string;
    procedure FrgsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure InputDialog(Mode : Integer);
    function  GetDay: Integer;
    procedure SaveDayToDB(r, d: Integer; Mode: Integer);
    procedure SaveWorkerToDB(r: Integer);
    procedure ExportToXlsxA7(Doc: Integer; Date1, Date2: Variant; AutoOpen: Boolean);
    procedure SundaysToTurv;
    procedure SendEMailToHead;
    procedure SetGridEditableMode;

    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;

    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;

  public
  end;

var
  FrmWGEdtTurv: TFrmWGEdtTurv;

implementation

uses
  uTurv,
  uLabelColors2,
  uFrmBasicInput,
  uFrmWWsrvTurvComment,
  uExcel,
  uPrintReport
  ;

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
  cTlComm = 6;            //������������, ����� ��� ���������
  cTlSchedule = 7;
  cTlScheduleCh = 8;

  cTmM = 1;               //����� ��� ��� �� ��������
  cTmP = 2;               //����� ��� ��� ������
  cTmV = 3;               //����������� ����� ��� ���


function TFrmWGEdtTurv.PrepareForm: Boolean;
var
  i, j: Integer;
  va2, va21, flds1, flds2, values2: TVarDynArray2;
  Captions2: TVarDynArray;
begin
  Result := False;

  Caption:='����';
  FOpt.RefreshParent := True;

  Q.QLoadFromQuery('select id, id_division, code, name, dt1, dt2, committxt, commit, editusers, status, name, id_schedule from v_turv_period where id = :id$i', [ID], va2);
  if Length(va2) = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;
  Q.QLoadFromQuery('select name, IsStInCommaSt(:id_user$i, editusers), editusers from ref_divisions where id = :id$i', [User.GetId, va2[0][1]], va21);
  FDivisionScehdule := Q.QSelectOneRow('select code from ref_work_schedules where id = :id', [va2[0][11]])[0];
  FIsOffice := Q.QSelectOneRow('select office from ref_divisions where id = :id$i', [va2[0][1]])[0] = 1;


  if Length(va2) = 0 then
    Exit;

  FIdDivision := va2[0][1];
  FDivisionName := va2[0][10];
  FPeriodStartDate := va2[0][4];
  FPeriodEndDate := va2[0][5];
  FDayColumnsCount := DaysBetween(FPeriodEndDate, FPeriodStartDate) + 1;
  FRgsCommit:=User.Role(rW_J_Turv_Commit);;
  FRgsEdit1:=va21[0][1]=1;
  FRgsEdit2:=User.Role(rW_J_Turv_TP);
  FRgsEdit3:=User.Role(rW_J_Turv_TS);;
  FEditUsers:=va21[0][2];
  FIsCommited:=va2[0][7];

  FDayColWidth := 40;
  //������� ����������, �������� �� ��������� ������� ���� �������
  SetLock;
  if Mode = fNone then
    Exit;
  //���� ���� ��� ������ �� ��������������, �� ��������������� ��������� = �� ������, � ���������� �� ������, �� ��� ��� ����� ��� �������� ����
  //���� �� ��� � ������ ���������, �� � ����� �������������� �� ���������
  FInEditMode := (Mode = fEdit) and (not FIsCommited);
  //����� ����� ������� ������������ - ���� ����� �� ���� ����� �������, �� �� ���� ������ ��� ��������������
  FInEditMainGridMode := FInEditMode and FRgsEdit1 and not (FRgsEdit2 or FRgsEdit3);

  //��������� 16 ������� ��� ������� ������
  //��������� ������������ ��� �� ����
  //���� ������������� ������� � �������
  //������ �������, ������� ���� ����� �������
  for i := 1 to 16 do begin
    flds1 := flds1 + [[
      'd' + IntToStr(i) + '$s',
      S.IIfStr(IncDay(FPeriodStartDate, i - 1) > FPeriodEndDate, '_') +
        //'������|' +
        IntToStr(DayOf(IncDay(FPeriodStartDate, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FPeriodStartDate, i - 1))],
      IntToStr(FDayColWidth) + ';R',
      'e'
    ]];
    flds2 := flds2 + [[
      'd' + IntToStr(i) + '$s',
      S.IIfStr(IncDay(FPeriodStartDate, i - 1) > FPeriodEndDate, '_') +
        IntToStr(DayOf(IncDay(FPeriodStartDate, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FPeriodStartDate, i - 1))],
      IntToStr(FDayColWidth) + ';R',
      'e'
    ]];
  end;

  Frg1.Options := FrDBGridOptionDef + [myogPanelFind];
  Frg1.Opt.SetFields([
    ['x$s', '*','20'],
    ['worker$s','��������|���','200'],
    ['job$s','��������|���������','150'],
    ['schedule$s','��������|������','50']
    ] + flds1 + [
    ['time$f', '�����|�����', '50'] ,
    ['premium_p$f', '�����|������ �� ������', '50'],
    ['premium$f', '�����|������', '50'],
    ['penalty$f', '�����|������', '50'],
    ['comm$s', '�����|�����������', '100']
  ]);
  //������ �������� �������� ���������
  FLeftPartWidth := 200 + 150 + 50;
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtView, FRgsEdit1, True, '�������� �����'],
    [mbtEdit, FRgsEdit1, False, '���� ������� ������������'],
    [],
    [-mbtDivisionScedule, FInEditMode, True],
    [-mbtWorkerScedule, FInEditMode, True],
    [],
    [-mbtPremiumForDay, FInEditMode and FRgsEdit1, True],
    [-mbtFine, FInEditMode and FRgsEdit1, True],
    [-mbtComment, FInEditMode, True],
    [],
    [mbtSendEMail, FRgsEdit2 and FInEditMode],
    [mbtCustom_SundaysToTurv, FInEditMode and FRgsEdit2, FInEditMode],
    [mbtLock, FRgsCommit and (FIsCommited or (Mode = fEdit)), True, S.IIFStr(FIsCommited, '�������� �������� �������', '������� ������')],
    [],
    [mbtPrint],
    [],
    [mbtCtlPanel]
  ]);

  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblWorker', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Frg2.Options := FrDBGridOptionDef;
  flds2 := [['type$s', '��������', IntToStr(FLeftPartWidth - 22)]] + flds2;
  Frg2.Opt.SetFields(flds2);
  Frg2.Opt.SetGridOperations('u');
  Frg2.Opt.SetButtons(1, [
    [mbtCtlPanel, True, FLeftPartWidth - 4],
    [],
    [mbtPremiumForPeriod, FInEditMode and FRgsEdit1, False, '������ �� ������', 'edit'],
    [mbtCtlPanel, True, 150],
    [],
    [mbtCommentForWorker, FInEditMode, False, '����������� �� ���������', 'edit'],
    [mbtCtlPanel, True, 500],
    [],
    [-mbtPremiumForDay, FInEditMode and FRgsEdit1, True, '������� �� ����'],
    [-mbtFine, FInEditMode and FRgsEdit1, True, '����� �� ����'],
    [-ghtNightWork, FInEditMode, True, '������ �����'],
    [-mbtComment, FInEditMode, True, '�����������'],
    []
  ], cbttSSmall);

  Frg2.CreateAddControls('1', cntLabelClr, '��������:', 'lblDWorker', '', 4, yrefC, FLeftPartWidth - 4);
  Frg2.CreateAddControls('2', cntLabelClr, '������:', 'lblDPremium', '', 4, yrefC, 200);
  Frg2.CreateAddControls('3', cntLabelClr, '�����������:', 'lblDComm', '', 4, yrefC, 500);

  Captions2 := ['����� (������������)', '����� (������)', '����� (�������������)', '������', '�����'];
  for i := 0 to High(Captions2) do
    values2 := values2 + [[Captions2[i], null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]];
  Frg2.SetInitData(values2, '');

  Frg1.InfoArray := [
  ['������ ����� �������� �������.'#13#10#13#10+
  '����� ������������ ������ ���������� �������������, �� ���������, ������� ������, �������� ����� ������ �� ������ ���� ������� � ��������� �� �������� '#13#10+
  '(� ����� � ������� ����� ����), � � ������ ����� - ��������� ������������ ����� �� ������, ����� ������� ������ � ������� ���������, '#13#10+
  '�������� ������ �� ���� ������, � ����� �����������.'#13#10+
  '��� �������� ������������ ����� ���������� � �������������, � ����� � ��������� ��������� (������� ����� ������� � ����� ��������� �� ������� ������������ ��������).'#13#10+
  ''#13#10
  ],
  [
  '��� �������� � ����� ������������ ����� �� ������������, � �� ������ ������� ������ ��������������� � �������� �������.'#13#10+
  '��� ����������� ��������� ������� ������� ��������������� ������ (� ���� ������ ������� ������ � �������� ������� ����� ������!)'#13#10
  , FInEditMode and FRgsEdit1],
  [
  '��� ������� ������� ������ ����� ������������� ��� �� ����������� ��������� �� ������ ������ �������� ��������������� ����� ������������ ����.'#13#10+
  '���� ��� ��������� ����� ���� ������ ������, �� �������������� �����, ����� ������ ��������� ����� ����� ��, ��� ����� �������������.'#13#10+
  '����� ������ ��������� �� ������� �������� ������ �������� ������������� (��� ����������� �� ��� �������� �������, � ������������),'#13#10+
  '�� �� ������ ������ ��� ��������������� ��� ������� � ��������� ��������, � ���� ������ ����� ������������ ��������� ���� ������.'#13#10+
  '����� ������ ����� ��������� ��� ��������, �������� �������������, ������ ���� �� ����������, ��� ������������� �����.'#13#10+
  ''#13#10+
  ''#13#10
  , FInEditMode and FRgsEdit2],
  [
  '�� ������ ��������� ������������� ����� � ��������� �������. ������ ����� ����� ���������, �, ���� ��� ������, �� ������ ��� ����� ������������ � �������� ���������.'#13#10+
  '����� ��� ������ � ������� ���������, ������� ������ "������� ������". ���� ��� ������ ������� � ���������, ������ ����� ������ � �������� ��������� � ���� ������ �����������.'#13#10+
  '������ ��� ������������� �� ������ �������� �������� ������� (���� �� �������).'#13#10+
  ''#13#10
  ,FRgsEdit2],
  [
  '�� ������ ������ "+" ����� �� ����� ���������, � ������� ������� �� ����� ������� '#13#10+
  '(������� �� ������������, �������, �������������, ������), � ������������� ������ ��� � ���, � ������������ �� ����� ��������.'#13#10+
  '������� (� ����� �������) ������ ������ ���� ��� ����� ������, ������ ��� �����������.'#13#10+
  '(����������� �������� � ��� ������ �������, ������� ������ �������, �� ���� � ������� ��� ����� �����������, �������������, ��� ������).'#13#10+
  '��������� ����� � ������ ����������, ��� ���� ����� ������� �����������.'#13#10+
  '���� �� ������������ �������������, �� ������ ������ ����� ����������� � ������ ������� � ������ ��������� �� ������, ����� ������ ������.'#13#10+
  '����� ��� �������� ��� �������� ������������ ���������� �� ��������� �� ��� �����, ������� ������ �������.'+
  ''#13#10
  , FInEditMode],
  [
  '���� ������ � ������ ���������� ������������� ��� ����� �������, � ��� �������������� ���� ������ �������� ������ �� ������ ��� ������ F2.'#13#10+
  '������� Enter ��������� ���� � ���������� ����� �� ������ ������, ������� ����� � ���� ����� ��������� ���� � ���������� � ���������� ��� ���������� ������ �������.'#13#10+
  '������� Esc �������� ����.'#13#10#13#10
  , FInEditMode],
  [
  '������ � ������� ������������ ���������� �������, ���������� �� ������� �������� �������, � ��� �����������'#13#10+
  '��� �� �������� ������������ ����� ��� �� ���, ������ ���������� �������. ����� ������������ ���, � ������� �������� �� �������� � �������������.'#13#10+
  ''#13#10
  ],
  [
  '������ ��� ����� ����������� �����, ��������� �������� ������������� �� �����.'#13#10
  , FInEditMode]
  ];


  Result := inherited;
  if not (Result and LoadTurvCodes and LoadTurv) then
    Exit;
  SetLblDivisionText;
  PushTurvToGrid;
  Frg1.MemTableEh1.First;
  SetGridEditableMode;
end;

function TFrmWGEdtTurv.SetLock: Boolean;
var
  st, st1, st2, st3, st4: string;
begin
  //����������
  //����� ������ � ������ �������������� � ���� ������ ��� �� ������
  if not ((Mode = fEdit) and not FIsCommited) then
    Exit;
  st := '';
  st1 := '';
  st2 := '';
  st3 := '';
    //������� ������������� ���� ��� ������� ���� ������� ��������
  if FRgsEdit1 then
    st1 := Q.DBLock(True, FormDoc, VarToStr(id) + '-1', '', fNone)[1];
  if FRgsEdit2 then
    st2 := Q.DBLock(True, FormDoc, VarToStr(id) + '-2', '', fNone)[1];
  if FRgsEdit3 then
    st3 := Q.DBLock(True, FormDoc, VarToStr(id) + '-3', '', fNone)[1];
  if (st1 = User.GetName) or (st2 = User.GetName) or (st3 = User.GetName) then begin
      //���� ���� �� ���� ���������� ����, �� ������ ��� �� ��� �����������
    st := '�� ��� ������� ���� ���� ��� ��������������!';
    MyWarningMessage(st);
    FLockInDB := fNone;
    Mode := fNone;
    Exit;
  end
  else if byte(FRgsEdit1) + byte(FRgsEdit2) + byte(FRgsEdit3) = 1 then begin
      //���� ������ ���� �����, �������� ����� ������������, �� �� ����� ��������, ������ ��� ��� ������������� �����
    if st1 + st2 + st3 <> '' then begin
      st := '���� ���� ��� ������������� ������������� ' + A.ImplodeNotEmpty([st1, st2, st3], ',') + ' � ����� ������ ������ ��� ���������!';
      MyWarningMessage(st);
      Mode := fView;
    end;
  end
  else begin
      //���� �������� ����, �� �������� �������� ��� �������������
    if st1 <> '' then begin
      st1 := '���� ������� ������������ ����������, ��� ��� ���� ���� ����������� ' + st1;
      FRgsEdit1 := False;
    end;
    if st2 <> '' then begin
      st2 := '���� ������� �� Parsec ����������, ��� ��� ���� ���� ����������� ' + st2;
      FRgsEdit2 := False;
    end;
    if st3 <> '' then begin
      st3 := '���� �������������� ������� ����������, ��� ��� ���� ���� ����������� ' + st3;
      FRgsEdit3 := False;
    end;
    if not (FRgsEdit1 or FRgsEdit2 or FRgsEdit3) then
      Mode := fView;
    st := A.ImplodeNotEmpty([st1, st2, st3], #13#10);
    if st <> '' then
      MyWarningMessage(st);
  end;
end;

function TFrmWGEdtTurv.LoadTurv: Boolean;
var
  i, j, k: Integer;
  vs: TVarDynArray2;
  v2: TVarDynArray;
  v1: Variant;
  dt, dt1, dtbeg, dtend: TDateTime;
  y, m: Integer;
  res: Integer;
  st: string;
  TurwW: TNamedArr;
begin
  //������� ������ ���������� ��� ������� ����
  FArrTurv := [];
  vs := [];
  v2 := [];
  //dt1p, dt2p, id_worker, workername, id_job, job, worker_has_schedule, id_shedule, schedule
  FArrTitle := Turv.GetTurvArrayFromDb(FIdDivision, FPeriodStartDate);
  Result := FArrTitle.Count > 0;
  if not Result then
    Exit;
  //�������� �� ������
  for i := 0 to FArrTitle.Count - 1 do begin
    SetLength(FArrTurv, i + 1, 31, cItog + 1);
    //������ ����_��� � ��� ������� ��������� � ����������, � ������� �� � ���� ����, ��������� �� ����
    vs := Q.QLoadToVarDynArray2(
      'select dt, worktime1, worktime2, worktime3, id_turvcode1, id_turvcode2, id_turvcode3, premium, premium_comm, penalty, penalty_comm, production, ' +
      'null, null, comm1, comm2, comm3, begtime, endtime, settime3, nighttime ' +
      'from turv_day where id_worker = :id_worker$i and dt >= :dtbeg$d and dt <= :dtend$d order by dt',
       [FArrTitle.G(i, 'id_worker'), FArrTitle.G(i, 'dt1p'), FArrTitle.G(i, 'dt2p')]
    );
    //������ �� ������� ����
    for j := 1 to 16 do begin
      //�������� ����
      for k := 0 to cItog do
        FArrTurv[i][j][k] := null;
      //���� ������ �������� ��� ������ �������� ����, �� ������� ��� ������ ������ � ���� ���
      if (IncDay(FPeriodStartDate, j - 1) < FArrTitle.G(i, 'dt1p')) or (IncDay(FPeriodStartDate, j - 1) > FArrTitle.G(i, 'dt2p')) then
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
  for i := 0 to FArrTitle.Count - 1 do begin
    Frg1.MemTableEh1.Last;
    Frg1.MemTableEh1.Insert;
    Frg1.MemTableEh1.FieldByName('worker').Value := FArrTitle.G(i, 'workername');
    Frg1.MemTableEh1.FieldByName('job').Value := FArrTitle.G(i, 'job');
    Frg1.MemTableEh1.FieldByName('schedule').Value := FArrTitle.G(i, 'schedule');
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
  if (FInEditMainGridMode) and (FInEditMode) then
    v0 := v1;
    //����������� ������, ���� �����
  if S.IsNumber(S.NSt(v0), 0, 24) then
    st := FormatFloat('0.00', S.VarToFloat(v0))
  else
    st := S.NSt(v0);
    //������� �������� �� ���������� ������� ������
    //��� ���� �� ������ ����������� ������ ����� ��������� ������ ������, ������������ ������ ��������� �� ����������
  Frg1.SetValue('d' + IntToStr(ADay), ARow, False, st);
  Frg1.DbGridEh1.Invalidate;

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
  Frg1.SetValue('premium_p', ARow, False, FormatFloat('0.00', S.NNum(FArrTitle.G(ARow, 'premium'))));
  Frg1.SetValue('premium', ARow, False, FormatFloat('0.00', S.NNum(sum[1])));
  Frg1.SetValue('penalty', ARow, False, FormatFloat('0.00', S.NNum(sum[2])));
  Frg1.SetValue('comm', ARow, False, FArrTitle.G(ARow, 'comm'));
  //������ ������� ������
  FStatus := 1;
  for j := 0 to High(FArrTurv) do begin
    for i := 1 to FDayColumnsCount do begin
      if (FArrTurv[j][i][cColor] = -1) and (FStatus = 1) then
        FStatus := 2;
      if FArrTurv[j][i][cColor] = 1 then
        FStatus := 3;
      if FStatus = 3 then
        break
    end;
    if FStatus = 3 then
      break
  end;
end;

procedure TFrmWGEdtTurv.PushTurvCellToDetailGrid(ARow, ADay: Integer);
//��������� ������ � ����� ����� �� ��������� ������� ������
var
  i: Integer;
  st: string;
  v1, v2, v3: Variant;
begin
  try
  if (not Frg2.MemTableEh1.Active) or (Frg2.GetCount(False) = 0) then
    Exit;
  //������� ������������� ����� �������� ������ �����
  if ARow = -1 then
    ARow := Frg1.RecNo - 1;
  //������ �� ������ � ������ ����
//  if VarType(ArrTurv[ARow][ADay][0]) <> varInteger then exit;
  if FArrTurv[ARow][ADay][0] = -1 then begin
    //������� ��� ������ � ������
    for i := 0 to 4 do
      Frg2.SetValue('d' + IntToStr(ADay), i, False, null);
    exit;
  end;
  //������� �������� �� ���������� ������� ������
  //��� ���� �� ������ ����������� ������ ����� ��������� ������ ������, ������������ ������ ��������� �� ����������
  v1 := GetTurvCell(ARow, ADay, cTmM);
  v2 := GetTurvCell(ARow, ADay, cTmP);
  v3 := GetTurvCell(ARow, ADay, cTmV);
  //����������� ������, ���� �����
  if S.IsNumber(S.NSt(v1), 0, 24) then
    st := FormatFloat('0.00', S.VarToFloat(v1))
  else
    st := S.NSt(v1);
  Frg2.SetValue('d' + IntToStr(ADay), 0, False, st);
  if S.IsNumber(S.NSt(v2), 0, 24) then
    st := FormatFloat('0.00', S.VarToFloat(v2))
  else
    st := S.NSt(v2);
  Frg2.SetValue('d' + IntToStr(ADay), 1, False, st);
  if S.IsNumber(S.NSt(v3), 0, 24) then
    st := FormatFloat('0.00', S.VarToFloat(v3))
  else
    st := S.NSt(v3);
  Frg2.SetValue('d' + IntToStr(ADay), 2, False, st);
  //������ � ������
  if (FArrTurv[ARow][ADay][cSumPr] <> null) then begin
    st := FormatFloat('0', S.NNum(FArrTurv[ARow][ADay][cSumPr]));
    Frg2.SetValue('d' + IntToStr(ADay), 3, False, st);
  end
  else
    Frg2.SetValue('d' + IntToStr(ADay), 3, False, null);
  if (FArrTurv[ARow][ADay][cSumSct] <> null) then begin
    st := FormatFloat('0', S.NNum(FArrTurv[ARow][ADay][cSumSct]));
    Frg2.SetValue('d' + IntToStr(ADay), 4, False, st);
  end
  else
    Frg2.SetValue('d' + IntToStr(ADay), 4, False, null);
  Frg2.DbGridEh1.Invalidate;
  except on E: Exception do
    Application.ShowException(E);
  end;
end;

 procedure TFrmWGEdtTurv.SetLblDivisionText;
var
  st, stc : string;
begin
  if (FInEditMode) and (FInEditMainGridMode) then begin
    st := '���� ������� ������������';
    stc := '$FF0060';
  end
  else if (FInEditMode) and (not FInEditMainGridMode) then begin
    st := '���� ������';
    stc := '$FF00FF';
  end
  else if FIsCommited then begin
    st := '������ ��������, ������ ������';
    stc := '$0000FF';
  end
  else begin
    st := '������ ��������';
    stc := '$009000';
  end;
  TLabelClr(Frg1.FindComponent('lblDivision')).SetCaptionAr2([
    '$000000', '�������������: ', '$FF0000', FDivisionName,
    '$000000', '   ������ � ', '$FF0000',  DateToStr(FPeriodStartDate), '$000000 �� $FF0000', DateToStr(FPeriodEndDate),
    '$000000      [', stc, st, '$000000]'
    ]);
end;

procedure TFrmWGEdtTurv.SetLblWorkerText;
//������� ������ �� ��������� � ������, �� �������� ����������� ������� � �������� �����.
//�������� �� ������� ��������� ������� ���������� ����� � ��������� ������� ���������, � ����� ����������� ��������1
//!���� ������ ��������� ����, � � �� ������ ��������� �������� � ��������� � ��� ����� ��������� ��������������, � �������,
//�� ���� �� �������� - �� ���������� ������� �� colEnter, �� Cellclick, �� CellMouseClick, ���� ������ ��� � ������ ��������������!
var
  i, j: Integer;
begin
  //������ �� ����� �������� ������
  //� �������������� ����� � ����� ����������� ������ � form.onshow
//  if Frg1.InLoadData or Frg2.InLoadData then
//    Exit;
  //���� ����� ��������� ������, �� ������� �� ���, ����� �� ��������
  if Frg2.DBGridEh1.Focused then begin
    if not Frg2.MemTableEh1.Active or (Frg2.RecNo < 1) or Frg2.InLoadData then
      Exit;
    j := StrToIntDef(Copy(Frg2.CurrField, 2, 2), -1)
  end
  else begin
    if not Frg1.MemTableEh1.Active or (Frg1.RecNo < 1) or Frg1.InLoadData then
      Exit;
    j := StrToIntDef(Copy(Frg1.CurrField, 2, 2), -1);
  end;
  //������� � ������� ������
  i := Frg1.RecNo - 1;
  if (i < 0) then
    Exit;
  if (j < 0) or (FArrTurv[i][j][cExists] = -1) then
    //�� ������� ���� - ������ ���
    TLabelClr(Frg1.FindComponent('lblWorker')).SetCaptionAr2(['$000000��������: $FF00FF', FArrTitle.G(i, 'workername')])
  else
    //������� ���� - ������ �� ������� ������
    //��� ����� �� ����� � ������ ������ ���� ������ ��� �����������!
    TLabelClr(Frg1.FindComponent('lblWorker')).SetCaptionAr2([
      '$000000��������: $FF00FF', FArrTitle.G(i, 'workername'),
      '$000000', '   ����: ', '$FF0000', DateToStr(IncDay(FPeriodStartDate, j-1)) +
      '$000000', '   �����: ', '$FF0000',
      FormatTurvCell(GetTurvCell(i, j, 1)), ' $000000/$FF0000', FormatTurvCell(GetTurvCell(i, j, 2)), ' $000000/$FF0000', FormatTurvCell(GetTurvCell(i, j, 3)),
      S.IIf(FArrTurv[i][j][cSumPr] > 0, ' $000000   ������: $FF0000 ' + VarToStr(FArrTurv[i][j][cSumPr]), ''),
      S.IIf(FArrTurv[i][j][cSumSct] > 0, ' $000000   �����: $FF0000 ' + VarToStr(FArrTurv[i][j][cSumSct]), ''),
      S.IIf(S.NSt(FArrTurv[i][j][cBegTime]) = '', '', ' $000000   ������: $FF0000 ' + S.IIf(FArrTurv[i][j][cBegTime] = '-1', '-',
        StringReplace(FormatFloat('00.00', S.VarToFloat(FArrTurv[i][j][cBegTime])), FormatSettings.DecimalSeparator, ':', []))),
      S.IIf(S.NSt(FArrTurv[i][j][cEndTime]) = '', '', ' $000000   ����: $FF0000 ' + S.IIf(FArrTurv[i][j][cEndTime] = '-1', '-',
        StringReplace(FormatFloat('00.00', S.VarToFloat(FArrTurv[i][j][cEndTime])), FormatSettings.DecimalSeparator, ':', []))),
      S.IIf(S.NSt(FArrTurv[i][j][cNight]) = '', '', ' $000000   �����: $FF0000 ' + VarToStr(FArrTurv[i][j][cNight]))
    ]);
end;

procedure TFrmWGEdtTurv.SetLblsDetailText;
//�������� � ��������� ������ ������ � ����������� ������������, ������ ��������������
begin
  if not Frg1.MemTableEh1.Active or (Frg1.RecNo < 1) or not Frg2.MemTableEh1.Active or (Frg2.RecNo < 1) or Frg2.InLoadData then
    Exit;
  TLabelClr(Frg2.FindComponent('lblDWorker')).SetCaptionAr2(['$FF0000', FArrTitle.G(Frg1.RecNo - 1, 'workername')]);
  TLabelClr(Frg2.FindComponent('lblDComm')).SetCaptionAr2(['�����������:$FF0000 ', S.IIf(S.NSt(FArrTitle.G(Frg1.RecNo - 1, 'comm')) <> '', FArrTitle.G(Frg1.RecNo - 1, 'comm'), '���')]);
  TLabelClr(Frg2.FindComponent('lblDComm')).ShowHint := Length(VarToStr(FArrTitle.G(Frg1.RecNo - 1, 'comm'))) > 150;
  TLabelClr(Frg2.FindComponent('lblDComm')).Hint := VarToStr(FArrTitle.G(Frg1.RecNo - 1, 'comm'));
  TLabelClr(Frg2.FindComponent('lblDPremium')).SetCaptionAr2(['������ �� ������:$FF0000 ', FormatFloat('0.00', S.NNum(FArrTitle.G(Frg1.RecNo - 1, 'premium')))]);
  Frg2.SetBtnNameEnabled(1001, null, FInEditMode and FRgsEdit1);
  Frg2.SetBtnNameEnabled(1002, null, FInEditMode);
end;

function TFrmWGEdtTurv.FormatTurvCell(v: Variant): string;
begin
  if S.IsNumber(S.NSt(v), 0, 24) then
    Result := FormatFloat('0.00', S.VarToFloat(v))
  else
    Result := S.NSt(v);
end;

procedure TFrmWGEdtTurv.FrgsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
var
  st, st1, stc: string;
  v: Variant;
  rsd: TVarDynArray;
  e, e1: extended;
  i, j, r, d, rd: Integer;
  dt: TDateTime;
  sa1: TStringDynArray;
begin
  FIsDetailGridUpdated := TDBGridColumnEh(Sender).Grid = Frg2.DBGridEh1;
  if UseText then
    st := Text
  else
    st := VarToStr(Value);
  r := Frg1.RecNo - 1;
  d := StrToIntDef(Copy(TColumnEh(Sender).FieldName, 2, 2), -1);
  if d = -1 then
    Exit;
  //���������� � ������� ������ �� ���� �������
  if FIsDetailGridUpdated then
    rd := Frg2.RecNo - 1
  else
    rd := 0;
  dt := IncDay(FPeriodStartDate, d - 1);
  if d < 1 then
    Exit;
  if rd < 3 then begin
    UseText := True;
    //������� ����������� - ����� ��������� ������ ����� ������� �����
    //!!! �������� ����������� ���� ���� ����� � ���� ���� ��� ��� ��������, ���� � ���� �� �� ������ �� ����� ������!!!
    stc := '~'; //������� ��� ����������� �� ���������
    sa1 := A.ExplodeS(st, '/');
    st := sa1[0];
    if High(sa1) > 0 then begin
      stc := sa1[1];
      for i := 2 to High(sa1) do
        stc := stc + '/' + sa1[i];
      stc := trim(stc);
    end;
    if not S.IsNumber(st, 0.01, 24, 2) then begin
      //�� �����, �������� �������� ���
      FArrTurv[r][d][cTRuk + rd] := null;
      FArrTurv[r][d][cCRuk + rd] := null;
      i := pos(' - ', st);
      if i > 0 then
        st1 := copy(st, 1, i - 1)
      else
        st1 := st;
//      st := '';
      for i := 0 to FTurvCodes.Count - 1 do
        if UpperCase(st1) = UpperCase(FTurvCodes.G(i, 'code')) then begin
//              st:= TurvCodes[i];
          FArrTurv[r][d][cTRuk + rd] := null;
          FArrTurv[r][d][cCRuk + rd] := FTurvCodes.G(i, 'id');
          Break;
        end;
    end
    else if dt > Date then begin
      //������, �� ���� ������ �������
      FArrTurv[r][d][cTRuk - 1 + Frg1.RecNo] := null;
      FArrTurv[r][d][cCRuk - 1 + Frg1.RecNo] := null;
    end
    else begin
      //���� ����� �� 0 �� 24
      //��������� �� �������� ����, �� ����� 0.25
      e := StrToFloat(st);
{        if e<0.13 then e1:=0.25
          else if frac(e)<0.13
          then e1:=round(e)
          else if frac(e)<0.26
          then e1:=trunc(e)+0.25
          else if frac(e)<0.51
          then e1:=trunc(e)+0.5
          else if frac(e)<0.76
          then e1:=trunc(e)+0.75
          else e1:=round(e);}
      //��������� ������ �������� �, �.0 ��� �.5
{      if frac(e) >= 0.5 then
        e := trunc(e) + 0.5
      else
        e := trunc(e);}
      e := RoundTo(e, -1);
      if e > 24 then
        e := 24;
      e1 := e;
      //����������� �� ���� ������ ����� �������
      st := FormatFloat('0.00', e1);
      FArrTurv[r][d][cTRuk + rd] := e1;
      FArrTurv[r][d][cCRuk + rd] := null;
    end;
    //�����������
    if stc <> '~' then
      FArrTurv[r][d][cComRuk + rd] := stc;
    //������� ��������� ����� ��� ���������� ������ �� ������ ������
    if rd = 1 then
      FArrTurv[r][d][cSetTime] := null;
  end;
  //������� ����������
  Handled := True;
  //��������� ������ � �������� �������
  PushTurvCellToGrid(r, StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2, 2)));
  //��������� ������ � ��������� �������
  PushTurvCellToDetailGrid(r, StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2, 2)));
  //�������� � ��
  rsd := [cTRuk, cTPar, cTSogl, cTRuk, cTRuk];
  SaveDayToDB(r, StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2, 2)), rsd[rd]);
end;

procedure TFrmWGEdtTurv.InputDialog(Mode : Integer);
var
  va1, va2, va3, va4: TVarDynArray;
  i, j, r, d, n, n1: Integer;
  st: string;
  rsd: TVarDynArray;
  DataMode: Integer;
begin
  for i := 0 to High(myDefaultBtns) do
    if myDefaultBtns[i].Bt = Mode then begin
      st := myDefaultBtns[i].Caption;
      Break;
    end;
  r := Frg1.RecNo - 1;
  //���� ����
  d := GetDay;
  if Mode = mbtComment then begin
    if d = -1 then
      Exit;
    //����� ��� ������ ��������
    va3 := [cComRuk, cComPar, cComSogl, cComPr, cComSct];
    if Frg2.DbGridEh1.Focused then
      n1 := Frg2.RecNo - 1
    else
      n1 := 0;
    //��� ������ - ������������, ������, ������������ (1, 2, 3)
    DataMode := n1 + 1;
    if DataMode > 3 then
      DataMode := 1;
    if not (((va3[n1] = cComPar) and FRgsEdit2) or ((va3[n1] = cComSogl) and FRgsEdit3) or FRgsEdit1) or not FInEditMode then
      Exit;
    va1 := [S.NSt(FArrTurv[r][d][S.NInt(va3[n1])])];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80,
      [[cntEdit, '�����������:','0:400::T']],
      va1, va2, [['']], nil
    ) < 0 then
      Exit;
    FArrTurv[r][d][S.NInt(va3[n1])] := va2[0];
  end
  else if Mode = mbtPremiumForDay then begin
    if d = -1 then
      Exit;
    va1 := [S.NSt(FArrTurv[r][d][cSumPr]), S.NSt(FArrTurv[r][d][cComPr])];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80,
      [[cntNEdit, '�����:','0:100000'],
      [cntEdit, '�����������:','0:400::T']],
      va1, va2, [['']], nil
    ) < 0 then
      Exit;
    FArrTurv[r][d][cSumPr] := va2[0];
    FArrTurv[r][d][cComPr] := va2[1];
  end
  else if Mode = mbtFine then begin
    if d = -1 then
      Exit;
    va1 := [S.NSt(FArrTurv[r][d][cSumSct]), S.NSt(FArrTurv[r][d][cComSct])];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80,
      [[cntNEdit, '�����:','0:100000'],
      [cntEdit, '�����������:','0:400::T']],
      va1, va2, [['']], nil
    ) < 0 then
      Exit;
    FArrTurv[r][d][cSumSct] := va2[0];
    FArrTurv[r][d][cComSct] := va2[1];
  end
  else if Mode = mbtPremiumForPeriod then begin
    if d = -1 then
      d := 1;
    va1 := [S.NSt(FArrTitle.G(r, 'premium'))];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 180, 60,
      [[cntNEdit, '�����:','0:100000']],
      va1, va2, [['']], nil
    ) < 0 then
      Exit;
    FArrTitle.SetValue(r, 'premium', va2[0]);
    SetLblsDetailText;
    SaveWorkerToDB(r);
  end
  else if Mode = mbtCommentForWorker then begin
    if d = -1 then
      d := 1;
    va1 := [S.NSt(FArrTitle.G(r, 'comm'))];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80,
      [[cntEdit, '�����������:','0:400::T']],
      va1, va2, [['']], nil
    ) < 0 then
      Exit;
    FArrTitle.SetValue(r, 'comm', va2[0]);
    SetLblsDetailText;
    SaveWorkerToDB(r);
  end
  else if Mode = mbtDivisionScedule then begin
    if d = -1 then
      d := 1;
    va3 := Q.QLoadToVarDynArrayOneCol('select code from ref_work_schedules where active = 1 order by code', []);
    va4 := Q.QLoadToVarDynArrayOneCol('select id from ref_work_schedules where active = 1 order by code', []);
    va1 := [VarArrayOf([null, VarArrayOf(va3), VarArrayOf(va4)])];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80,
      [[cntComboLk, '������:','1:50']],
      va1, va2, [['������ ������������� (������ ��� ������� �������!). �� ���� ��� ������� ������, �� ������ ������ ���������� � � ����������� �������������.']], nil
    ) < 0 then
      Exit;
    FDivisionScehdule := Q.QSelectOneRow('select code from ref_work_schedules where id = :id', [va2[0]])[0];
    for i := 0 to Frg1.GetCount(False) - 1 do
      if S.NNum(FArrTitle.G(i, 'worker_has_schedule')) <> 1 then begin
        FArrTitle.SetValue(i, 'schedule', FDivisionScehdule);
        Frg1.SetValue('schedule', i, False, FDivisionScehdule);
      end;
    Q.QExecSql('update turv_period set id_schedule = :id_schedule$i where id_division = :id_division$i and dt1 = :dt1$d', [va2[0], FIdDivision, FPeriodStartDate]);
    if FPeriodEndDate >= Date then
      Q.QExecSql('update ref_divisions set id_schedule = :id_schedule$i where id = :id$i', [va2[0], FIdDivision]);
  end
  else if Mode = mbtWorkerScedule then begin
    if d = -1 then
      d := 1;
    va3 := Q.QLoadToVarDynArrayOneCol('select code from ref_work_schedules where active = 1 order by code', []);
    va4 := Q.QLoadToVarDynArrayOneCol('select id from ref_work_schedules where active = 1 order by code', []);
    va1 := [VarArrayOf([null, VarArrayOf(va3), VarArrayOf(va4)])];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80,
      [[cntComboLk, '������:','0:50']],
      va1, va2,
        [['������ ������ ��� ���������� ���������. ���� �� ����� (���� ����� ��, ��� ��� �������������!), �� � ���������� ����� �������� � ������� ���������, '+
         '���� ��� ��������� ������� ������������� ��� ��������� ���������. '+
         '����� ��������� ������ � ����� � �������������, ������� ����� ������ ��������'
        ]], nil
    ) < 0 then
      Exit;
    FArrTitle.SetValue(r, 'id_schedule', va2[0]);
    if S.NSt(va2[0]) = '' then begin
      FArrTitle.SetValue(r, 'worker_has_schedule', 0);
      st := FDivisionScehdule;
    end
    else begin
      FArrTitle.SetValue(r, 'worker_has_schedule', 1);
      st := Q.QSelectOneRow('select code from ref_work_schedules where id = :id', [va2[0]])[0];
    end;
    FArrTitle.SetValue(r, 'schedule', st);
    Frg1.SetValue('schedule', r, False, st);
    SaveWorkerToDB(r);
    if FPeriodEndDate >= Date then
      Q.QExecSql('update ref_workers set id_schedule = :id_schedule$i where id = :id_worker$i', [S.NullIfEmpty(va2[0]), FArrTitle.G(r, 'id_worker')]);
  end;
  //��������� ������ � �������� �������
  PushTurvCellToGrid(r, d);
  //��������� ������ � ��������� �������
  PushTurvCellToDetailGrid(r, d);
  //������� � ��
  SaveDayToDB(r, d, DataMode);
end;


function TFrmWGEdtTurv.GetDay: Integer;
begin
  if Frg2.DbGridEh1.Focused then
    Result := StrToIntDef(Copy(Frg2.CurrField, 2, 2), -1)
  else
    Result := StrToIntDef(Copy(Frg1.CurrField, 2, 2), -1);
end;

procedure TFrmWGEdtTurv.SaveDayToDB(r, d: Integer; Mode: Integer);
//��������� � �� ���������� ������
//��� ������ 0 ��������� ���, ����� atTRuk - ������ ������������, � ��� �� ������, �������������
//���������� ����� �������!! � �� ���� ������!
var
  v: TVarDynArray;
  res, i: Integer;
  dt: TDateTime;
  Fields, st: string;
begin
  //������ ��� � ���� ���� - �����
  if FArrTurv[r][d][0] = -1 then
    Exit;
  //������� ������
  Fields := '';
  v := [];
  if (Mode in [cTRuk, 0]) then begin
    v:=[
      FArrTurv[r][d][cTRuk],
      FArrTurv[r][d][cCRuk],
      FArrTurv[r][d][cComRuk],
      FArrTurv[r][d][cVyr],
      FArrTurv[r][d][cSumPr],
      FArrTurv[r][d][cComPr],
      FArrTurv[r][d][cSumSct],
      FArrTurv[r][d][cComSct]
    ];
    S.ConcatStP(Fields, 'worktime1$f;id_turvcode1$i;comm1$s;production$i;premium$f;premium_comm$s;penalty$f;penalty_comm$s', ';');
  end;
  if (Mode in [cTPar, 0]) then begin
    v:=v + [
      FArrTurv[r][d][cTPar],
      FArrTurv[r][d][cCPar],
      FArrTurv[r][d][cComPar],
      FArrTurv[r][d][cBegTime],
      FArrTurv[r][d][cEndTime],
      FArrTurv[r][d][cSetTime],
      FArrTurv[r][d][cNight]
    ];
    S.ConcatStP(Fields, 'worktime2$f;id_turvcode2$i;comm2$s;begtime$f;endtime$f;settime3$i;nighttime$f', ';');
  end;
  if (Mode in [cTSogl, 0]) then begin
    v:=v + [
      FArrTurv[r][d][cTSogl],
      FArrTurv[r][d][cCSog],
      FArrTurv[r][d][cComSogl]
    ];
    S.ConcatStP(Fields, 'worktime3$f;id_turvcode3$i;comm3$s', ';');
  end;
  v:=v + [
    FArrTitle.G(r, 'id_worker'),
    IncDay(FPeriodStartDate, d - 1)
  ];
  //������� ������ � �������� �������
  st := Q.QSIUDSql('Q', 'turv_day', Fields) + ' where id_worker = :id_worker$i and dt = :dt$d';
  res := Q.QExecSQL(st, v);
  //������� ������ � ������� �������� - ������ ����������� �� � ���� ����� �������� ������ ��������� �������
  if FStatusOld <> FStatus then begin
    res := Q.QExecSQL(
      'update turv_period set status = :status$i where id_division = :id$i and dt1 = :dt1$d',
      [FStatus, FIDDivision, FPeriodStartDate]
    );
    FStatusOld := FStatus;
  end;
end;

procedure TFrmWGEdtTurv.SaveWorkerToDB(r: Integer);
//�������� ������ �� ������ ���� (��� ������ ������ ���������) - ���� ������ � �����������
var
  i: Integer;
begin
  Q.QExecSql('update turv_worker set id_schedule = :id_schedule$i, premium = :premium$f, comm = :comm$s '+
    'where id_worker = :id_worker$i and id_division = :id_division$i and id_job = :id_job$i and dt1 = :dt$d',
    [FArrTitle.G(r, 'id_schedule'), FArrTitle.G(r, 'premium'), FArrTitle.G(r, 'comm'),
    FArrTitle.G(r, 'id_worker'), FArrTitle.G(r, 'id_division'), FArrTitle.G(r, 'id_job'), FPeriodStartDate]
  );
end;


procedure TFrmWGEdtTurv.ExportToXlsxA7(Doc: Integer; Date1, Date2: Variant; AutoOpen: Boolean);
var
  i, j, d1, d2, x, y: Integer;
  sm, sum, sumall: Double;
  v: Variant;
  Rep: TA7Rep;
  FileName: string;
  dt1, dt2: TDateTime;
  b: Boolean;
  Range: Variant;
begin
  if Date2 < Date1 then
    Exit;
  if Doc = 0 then
    FileName := '���� �� Parsec';
  FileName := Module.GetReportFileXlsx(FileName);
  if FileName = '' then
    Exit;
  Rep := TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName);
  except
    Rep.Free;
    Exit;
  end;
  dt1 := Date1;
  dt2 := Date2;
  d1 := trunc(dt1 - FPeriodStartDate + 1);
  d2 := trunc(dt2 - FPeriodStartDate + 1);
  Rep.PasteBand('HEADER');
  Rep.SetValue('#MONTH#', DateToStr(FPeriodStartDate) + ' - ' + DateToStr(FPeriodEndDate));
  for j := 1 to 16 do begin
    b := (j >= d1) and (j <= d2);
    Rep.ExcelFind('#d' + IntToStr(j) + '#', x, y, xlValues);
    Rep.TemplateSheet.Columns[x].Hidden := not b;
    if b then
      Rep.SetValue('#d' + IntToStr(j) + '#', IntToStr(DayOf(FPeriodStartDate + j - 1)));
  end;
  for i := 0 to FArrTitle.Count - 1 do begin
    Rep.PasteBand('TABLE');
    Rep.SetValue('#N#', i + 1);
    Rep.SetValue('#FIO#', FArrTitle.G(i, 'workername'));
    Rep.SetValue('#JOB#', FArrTitle.G(i, 'job'));
    sum := 0;
    for j := d1 to d2 do begin
      v := S.NSt(GetTurvCell(i, j, cTPar));
      if S.IsNumber(v, 0, 24) then
        sum := sum + v;
      Rep.SetValue('#d' + IntToStr(j) + '#', v);
    end;
    Rep.SetValue('#ITOG#', sum);
    sumall := 0;
    for j := 1 to 16 do begin
      v := S.NSt(GetTurvCell(i, j, cTPar));
      if S.IsNumber(v, 0, 24) then
        sumall := sumall + v;
    end;
    Rep.SetValue('#ITOGA#', sumall);
  end;
//  Rep.PasteBand('FOOTER');
//  Rep.SetValue('#����������#',mem_Comm.Text);
  Rep.DeleteCol1;
  Rep.Show;
  Rep.Free;
  Exit;
end;

procedure TFrmWGEdtTurv.SundaysToTurv;
var
  v: Variant;
  st: string;
  dt, dt1: TDateTime;
  res: Boolean;
  i, j, k, m, d, rn: Integer;
  va, va1: TVarDynArray;
  va2: TVarDynArray2;
  b: Boolean;
begin
  //���� � ������ ����� ��� ����� � �� �����
  if FTurvCodeWeekend = -1 then
    Exit;
  //������ ��������� ����� ������
  va1 := [];
  if FRgsEdit1 then
    va1 := va1 + ['����� ������������'];
  if FRgsEdit2 then
    va1 := va1 + ['����� �� Parsec'];
  if FRgsEdit3 then
    va1 := va1 + ['������������� �����'];
  if Length(va1) = 0 then
    Exit;
  b := False;
  if Length(va1) = 1 then begin
    b := MyQuestionMessage('���������� �������� � ����������� ��� �� ����������������� ���������'#13#10'(' + VarToStr(va1[0] + ')'#13#10'?')) = mrYes;
    va := [va1[0]];
  end
  else begin
    b := TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '��������', 420, 210,
      [[cntComboL, '���������� �������� � ��������� ���', '1:500:0', 200]],
      [VarArrayOf([va1[0], va1])], va, [['']], nil
    ) >= 0
  end;
  //�����, ���� �������� ���� ��������
  if not b then
    Exit;
  //������� �������� � �������
  k := -1;
  if va[0] = '����� ������������' then
    k := cTRuk;
  if va[0] = '����� �� Parsec' then
    k := cTPar;
  if va[0] = '������������� �����' then
    k := cTSogl;
  if k = -1 then
    Exit;
  //�������� ��������� ������ - ��� ��� ��� �� ���������
  Frg1.DBGridEh1.RowDetailPanel.Visible := False;
  //������� ��������� �� ���� �����
  va2 := Q.QLoadToVarDynArray2('select dt, type, descr from ref_holidays where extract(year from dt) = :year$i and extract(month from dt) = :month$i order by dt', [YearOf(FPeriodStartDate), MonthOf(FPeriodStartDate)]);
  //������ �� ������� ����
  for i := 0 to High(FArrTurv) do begin
    //������ �� ��������
    for j := 1 to 16 do begin
      dt := IncDay(FPeriodStartDate, j - 1);
      if dt > FPeriodEndDate then
        Break;
      //���� ������ �� ���������
      if (FArrTurv[i][j][cExists] <> -1) and (FArrTurv[i][j][k] = null) and (FArrTurv[i][j][k + 3] = null) then begin
        //������� ��� ��� �� ���������
        d := 0;
        for m := 0 to High(va2) do begin
          if dt = va2[m][0] then begin
            d := Trunc(S.NNum(va2[m][1]));
          end;
        end;
        //������� ��������, ���� ��������, ��� (��,�� � ��� ��� �� ���������� ����������� ��� �������)
        if (d = 1) or ((DayOfTheWeek(dt) >= 6) and (d <> 2) and (d <> 3)) then begin
          FArrTurv[i][j][k + 3] := FTurvCodeWeekend;
          //������� � ������� ��� �����
          PushTurvCellToGrid(i, j);
          //������� � ��
          SaveDayToDB(i, j, k);
        end;
      end;
    end;
  end;
end;

procedure TFrmWGEdtTurv.SendEMailToHead;
//���������� ������ ��� ������������� ������ ���� (���, ��� ���������), � ����������� � ������������� ������� � ������� � �������������
//����� �� ������������ � �� �������, � ��������� ����������, ����� � ������
//� ������� �������������� ������ � Thunderbird
var
  i, j, k: Integer;
  v: Variant;
  st, st1: string;
  b, b1, b2: Boolean;
  va1: TVarDynArray;
  va11: TVarDynArray2;
begin
  b := True;
  va1 := [];
  va11 := [];
  //�������� ��� �� ��� ������� �� ������� �������
  for j := 0 to High(FArrTurv) do
    for i := 1 to FDayColumnsCount do
      if (FArrTurv[j][i][cExists] <> -1) and (FArrTurv[j][i][cTPar] = null) and (FArrTurv[j][i][cCPar] = null) then begin
        b := False;
        Break;
      end;
  if (not b) and (MyQuestionMessage('� ���� ���� ��� �� ������� ��� ������ �� Parsec. ��� ����� ����������?') <> mrYes) then
    Exit;
  //������� ������ ���������� �� ������� ����������� ������ (������� ������) ��� �� �������� ������ �� ������������
  for j := 0 to High(FArrTurv) do
    for i := 1 to FDayColumnsCount do
      if (FArrTurv[j][i][cExists] <> -1) and ((FArrTurv[j][i][cTRuk] = null) and (FArrTurv[j][i][cCRuk] = null) or (S.NNum(FArrTurv[j][i][cColor]) = 1)) then begin
        va1 := va1 + [FArrTitle.G(j, 'workername')];
        Break;
      end;
  //������� ������ ���������� � ��� ��� ���� � �������, �� ������� ���� ����������� � ��������
  for j := 0 to High(FArrTurv) do begin
    st := '';
    for i := 1 to FDayColumnsCount do
      if (FArrTurv[j][i][cExists] <> -1) and (FArrTurv[j][i][cCRuk] = null) and (FArrTurv[j][i][cCPar] = null) and (FArrTurv[j][i][cTRuk] <> null) and (FArrTurv[j][i][cTPar] <> null) and (FArrTurv[j][i][cTRuk] <> FArrTurv[j][i][cTPar]) then
        S.ConcatStP(st, IntToStr(DayOf(FPeriodStartDate) + i - 1) + ':' + VarToStr(FArrTurv[j][i][cTRuk]) + '/' + VarToStr(FArrTurv[j][i][cTPar]), ', ');
    if st <> '' then
      va11 := va11 + [[FArrTitle.G(j, 'workername'), st]];
  end;
  if (Length(va1) = 0) and (Length(va11) = 0) and (MyQuestionMessage('� ���� ����, ������, ������� � ����������� ��� ������. ��� ����� ������������ ������?') <> mrYes) then
    Exit;
  st := '��������!'#13#10 + '� ���� ���� ���� ������������ ��� ��������������� ������!'#13#10#13#10;
  if Length(va1) > 0 then
    st := st + '�� ������ �� ����� ������, ��� �� �� ��� ������� ������������ ����������� (��� ������ �������� ������� �����) �� ��������� ����������:'#13#10 + A.Implode(va1, #13#10) + #13#10#13#10;
  if Length(va11) > 0 then begin
    st := st + '������� �� ��������� ����������, ��������� �������������, � �� Parsec, �����������:'#13#10;
    for i := 0 to High(va11) do
      st := st + va11[i][0] + ':.... ' + va11[i][1] + #13#10;
  end;
  if not b then
    st := st + #13#10 + '�����: ��� ����� ���� ��� ��������� �� ��� ������� �� Parsec!!!';
  Module.MailSendWithThunderBird(S.NSt(Q.QSelectOneRow('select GetUsersEmail(:editusers$s) from dual', [FEditUsers])[0]), '���������� ��������� ���� "' + FDivisionName + '"', st, '');
end;

procedure TFrmWGEdtTurv.SetGridEditableMode;
begin
  Frg1.DbGridEh1.ReadOnly := not FRgsEdit1 or not FInEditMode or not FInEditMainGridMode or FIsCommited;
  Frg2.DbGridEh1.ReadOnly := not FInEditMode or FIsCommited;
  Frg1.Invalidate;
  Frg2.Invalidate;
end;





{========================== ������� ������ � ����� ============================}



procedure TFrmWGEdtTurv.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  Row, Day: Integer;
  Color: Integer;
begin
  if Params.Row = 0 then
    Exit;
  Row := Params.Row - 1;
  Day := StrToIntDef(Copy(FieldName, 2, 2), -1);
  if Day <> -1 then begin
    if FArrTurv[Row][Day][cExists] <> -1 then
      case FArrTurv[Row][Day][cColor] of
        1 : Params.Background := clRed;
        2 : Params.Background := clYellow;
        -1: Params.Font.Color := clRed;
      end
    else begin
      Params.Background := clmyGray;
      Params.ReadOnly := True;
    end;
  end
  else Params.Background := clmyGray;
  if (FieldName = 'schedule') and (S.NNum(FArrTitle.G(Row, 'worker_has_schedule')) = 1) then
    Params.Font.Color := clBlue;
end;

procedure TFrmWGEdtTurv.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  FrgsColumnsUpdateData(Fr, No, Sender, Text, Value, UseText, Handled);
end;


procedure TFrmWGEdtTurv.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
var
  i, j: Integer;
begin
  SetLblWorkerText;
  FTurvCodeWeekend := -1;
  for i := 4 to 16 + 3 do begin
    if Frg1.DBGridEh1.Columns[i].PickList.Count = 0 then
      for j := 0 to FTurvCodes.Count - 1 do begin
        if FTurvCodes.G(j, 'code')  = '�' then
          FTurvCodeWeekend := FTurvCodes.G(j, 'id');
        Frg1.DBGridEh1.Columns[i].PickList.Add(FTurvCodes.G(j, 'code') + ' - ' + FTurvCodes.G(j, 'name'));
      end;
  end;
  Cth.SetButtonState(Frg1, mbtComment, '����������� ������������', null, FInEditMode and FRgsEdit1);
end;

procedure TFrmWGEdtTurv.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  rn, i, j: Integer;
  dt: TDateTime;
  b: Boolean;
  va: TVarDynArray;
  st, st1, st2, st3: string;
begin
  Handled := True;
  if A.InArray(Tag, [mbtComment, mbtPremiumForDay, mbtFine, mbtDivisionScedule, mbtWorkerScedule]) then
    InputDialog(Tag)
  //������ ����� ������ ������������/����� ������
  else if Tag in [mbtView, mbtEdit] then begin
    if Tag = mbtEdit then
      FInEditMainGridMode := True;
    if Tag = mbtView then
      FInEditMainGridMode := False;
    Frg1.MemTableEh1.DisableControls;
    for i := 0 to Frg1.GetCount(False) - 1 do
      for j := 1 to 16 do
        PushTurvCellToGrid(i, j);
    Frg1.MemTableEh1.EnableControls;
  end
  //������ �������� �������
  else if Tag = mbtLock then begin
    if not FIsCommited then
      //���� ������ �� �������, �� ��������, ����� �� ��� �������
      if Turv.GetStatus(FIdDivision, FPeriodStartDate) = -1 then begin
        MyInfoMessage('� ���� ���� ������� �� ��� ������, ������� ��� ������!');
        Exit;
      end;
    if MyQuestionMessage(S.IIFStr(FIsCommited, '�� �������, ��� ������ ����� ������ "������" � ����� ����?', '�� �������, ��� ������ �������� ���� ���� ��� "������"?'#13#10'� ���� ������ ���� ������ � ���� ����� ����������!')) <> mrYes then
      Exit;
    //������� ������������� ���� ��� ������� ���� ������� ��������
    st1 := Q.DBLock(True, FormDoc, VarToStr(id) + '-1', '', fNone)[1];
    st2 := Q.DBLock(True, FormDoc, VarToStr(id) + '-2', '', fNone)[1];
    st3 := Q.DBLock(True, FormDoc, VarToStr(id) + '-3', '', fNone)[1];
    if (st1 = User.GetName) then
      st1 := '';
    if (st2 = User.GetName) then
      st2 := '';
    if (st3 = User.GetName) then
      st3 := '';
    st := A.ImplodeNotEmpty([st1, st2, st3], #13#10);
    if st <> '' then begin
      MyWarningMessage('���� ���� ������ ������ �� �������������� �'#13#10 + st + #13#10'��������� ������� ����������!');
      Exit;
    end;
    FIsCommited := not FIsCommited;
    Q.QExecSql('update turv_period set commit = :commit$i where id = :id$i', [S.IIf(FIsCommited, 1, 0), ID]);
    RefreshParentForm;
    Exit;
    if not FIsCommited then begin
       //���� ������ �� �������, �� ��������, ����� �� ��� �������
      b := True;
      for j := 0 to High(FArrTurv) do begin
        if not b then
          Break;
        for i := 1 to FDayColumnsCount do begin
            //������ ������� � ������, ��� �� ������� �����/��� ������������, � ��� ���� �� ����� - �� ���� ����������� ������� ����
          if (S.NNum(FArrTurv[j][i][cColor]) = 1) or (S.NNum(FArrTurv[j][i][cColor]) = 2) or ((FArrTurv[j][i][cExists] <> -1) and (FArrTurv[j][i][cTRuk] = null) and (FArrTurv[j][i][cCRuk] = null)) then begin
            b := False;
            Break;
          end;
        end;
      end;
      if not b then begin
        MyInfoMessage('� ���� ���� ������� �� ��� ������, ������� ��� ������!');
        Exit;
      end;
    end;
    if MyQuestionMessage(S.IIFStr(FIsCommited,
      '�� �������, ��� ������ ����� ������ "������" � ����� ����?',
      '�� �������, ��� ������ �������� ���� ���� ��� "������"?'#13#10'� ���� ������ ���� ������ � ���� ����� ����������!')
    ) <> mrYes then
      Exit;
    FIsCommited := not FIsCommited;
    Q.QExecSql('update turv_period set commit = :commit$i where id = :id$i', [S.IIf(FIsCommited, 1, 0), ID]);
    RefreshParentForm;
  end
  else if Tag = mbtSendEmail then begin
    SendEMailToHead;
  end
  else if Tag = mbtCustom_SundaysToTurv then begin
    SundaysToTurv;
  end
  else if Tag = mbtPrint then begin
    if FRgsEdit2 then begin
      if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '������� � Excel', 270, 50, [
        [cntComboLK,'������','1:500:0', 210],
        [cntDTEdit,'���� �','' + S.DateTimeToIntStr(FPeriodStartDate) + ':' + S.DateTimeToIntStr(FPeriodEndDate), 90],
        [cntDTEdit,'�� ','' + S.DateTimeToIntStr(FPeriodStartDate) + ':' + S.DateTimeToIntStr(FPeriodEndDate), 90, 170]],
        [VarArrayOf(['0', VarArrayOf(['���� �� Parsec']), VarArrayOf(['0'])]), FPeriodStartDate, FPeriodEndDate],
        va, [['']],  nil
      ) >=0
      then ExportToXlsxA7(Integer(va[0]), va[1], va[2], True);
    end;
  end
  else begin
    Handled := False;
    inherited;
  end;
  SetLblDivisionText;
  SetLblWorkerText;
  SetGridEditableMode;
end;

procedure TFrmWGEdtTurv.Frg1DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
//�������� ������
var
  v1, v2, v3, v4: Variant;
  ARow, c: Integer;
begin
  inherited;
  //������ ������ ������� � �����
  if (Params.Col < 5) or (Params.Col > 5 + 16 - 1) then  //!!!
    Exit;
  //������� �����������
  v1 := FArrTurv[Params.row - 1][Params.Col - 4][cComRuk];
  v2 := FArrTurv[Params.row - 1][Params.Col - 4][cComPar];
  v3 := FArrTurv[Params.row - 1][Params.Col - 4][cComSogl];
  v4 := FArrTurv[Params.row - 1][Params.Col - 4][cNight];
  //���� ������, �� ����� ����������� ���������
  //������, ���� ��� �������� �����������
  if (((VarIsEmpty(v1)) or (S.NSt(v1) = '')) and ((VarIsEmpty(v2)) or (S.NSt(v2) = '')) and ((VarIsEmpty(v3)) or (S.NSt(v3) = '')) and ((VarIsEmpty(v4)) or (S.NNum(v4) = 0))) and Frg1.DbGridEh1.ReadOnly then
    Exit;
  //����������� ���������
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
  TDBGridEh(Sender).Canvas.Brush.Color := Rgb(150, 255, 150);
  TDBGridEh(Sender).Canvas.Pen.Color := Rgb(150, 255, 150);
  TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Left + 3, ARect.Bottom);
  if S.NSt(v1) + S.NSt(v2) + S.NSt(v3) <> '' then begin
    //� ������� ��������� �����������
    TDBGridEh(Sender).Canvas.Pen.Width := 1;
    //���� ���� ����������� �����������/�������������, �� ��������� ���������, ���� ������ ������, �� �����
    if (VarToStr(v2) <> '') or (VarToStr(v3) <> '') then
      TDBGridEh(Sender).Canvas.Brush.Color := RGB(255, 0, 255)
    else
      TDBGridEh(Sender).Canvas.Brush.Color := clBlue;
    //�������� ������������� � ������� ����� ���� ������
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Left + 7, ARect.Top + 7);
  end;
  if S.NNum(v4) <> 0 then begin
    TDBGridEh(Sender).Canvas.Pen.Width := 1;
    TDBGridEh(Sender).Canvas.Brush.Color := clBlack;
    //�������� ������������� � ����� ������ ���� ������
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Bottom - 7, ARect.Left + 7, ARect.Bottom);
  end;
  //���� ��� ����������, ���� �� ��������� �� ����� ����������� ���������
  Processed := True;
end;

procedure TFrmWGEdtTurv.Frg1DbGridEh1DataHintShow(Sender: TCustomDBGridEh;
  CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint;
  Column: TColumnEh; var Params: TDBGridEhDataHintParams;
  var Processed: Boolean);
var
  v1, v2, v3, v4: Variant;
begin
  inherited;
  //������ ������� � �����
  if (Cell.X < 5) or (Cell.X > 5 + 16 - 1) then
    Exit;
  //������� �����������
  v1 := FArrTurv[Cell.Y - 1][Cell.X - 4][cComRuk];
  v2 := FArrTurv[Cell.Y - 1][Cell.X - 4][cComPar];
  v3 := FArrTurv[Cell.Y - 1][Cell.X - 4][cComSogl];
  v4 := FArrTurv[Cell.Y - 1][Cell.X - 4][cNight];
  //���� ����� � ������� ����� ����, ������� ����� ����� ��������, � �� ��� ������� �����, ���� ����������� ��������,
  //����� ���������� ���������� ����� ����� ���� �������� � ������ �����.
  if ((InCellCursorPos.X <= 7) and (InCellCursorPos.Y <= 7)) then
    FrmWWsrvTurvComment.ShowDialog(Self, CursorPos.X, CursorPos.Y, v1, v2, v3, null);
  if ((InCellCursorPos.X <= 7) and (InCellCursorPos.Y >= Frg1.DBGridEh1.CellRect(Cell.X, Cell.Y).Bottom - Frg1.DBGridEh1.CellRect(Cell.X, Cell.Y).Top - 7)) then
    FrmWWsrvTurvComment.ShowDialog(Self, CursorPos.X, CursorPos.Y, null, null, null, v4);
end;

procedure TFrmWGEdtTurv.Frg1DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
var
  i: Integer;
begin
  Frg1.DbGridEh1RowDetailPanelShow(Sender, CanShow);
  //�������� �����
  for i := 1 to 16 do begin
    PushTurvCellToDetailGrid(-1, i);
  end;
  Frg2.MemTableEh1.First;
  SetLblsDetailText;
//  SetBtns;
end;

procedure TFrmWGEdtTurv.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  Row, Day: Integer;
  Color: Integer;
begin
  Row := Params.Row - 1;
  Day := StrToIntDef(Copy(FieldName, 2, 2), -1);
  if Day = -1 then begin
    Params.Background := clmyGray;
    Exit;
  end;
  if FArrTurv[Frg1.DBGridEh1.Row - 1][Day][cExists] = -1 then begin
    Params.Background := clmyGray;
    Params.ReadOnly := True;
  end;
  //���� ����� ������, �� ������ ������ ��� ����� ��������������� ������ ������ ������ �����
  if (FArrTurv[Frg1.DBGridEh1.Row - 1][Day][cSetTime] = 1) and (FRgsEdit2) and (Params.Row = 2) then
    Params.Font.Color := clBlue
  else
    Params.Font.Color := clWindowText;
end;

procedure TFrmWGEdtTurv.Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  FrgsColumnsUpdateData(Fr, No, Sender, Text, Value, UseText, Handled);
end;

procedure TFrmWGEdtTurv.Frg2DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
var
  v1, v2, v3: Variant;
  r, c: Integer;
begin
  inherited;
  //������ ������ ������� � �����
  if (Params.Col <= 1) or (Params.Col > 1 + 16 - 1) then
    Exit;
  //������� �����������
  case Params.Row of
    1..3:
      v1 := FArrTurv[Frg1.RecNo - 1][Params.Col - 1][cComRuk + Params.row - 1];
    4:
      v1 := FArrTurv[Frg1.RecNo - 1][Params.Col - 1][cComPr];
    5:
      v1 := FArrTurv[Frg1.RecNo - 1][Params.Col - 1][cComSct];
  end;
  v2 := null;
  if Params.Row = 2 then
    v2 := FArrTurv[Frg1.RecNo - 1][Params.Col - 1][cNight];
  //���� ������, �� ����� ����������� ���������
  //������, ���� ��� �������� �����������
//  if (VarToStr(v1) = '') and (VarToStr(v2) = '') then
//    Exit;
  //����������� ���������
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
  //������� ������
  if not(not FInEditMode or FIsCommited or (Params.Row > 3) or ((Params.Row= 1) and not FRgsEdit1) or ((Params.Row = 2) and not FRgsEdit2) or ((Params.Row = 3) and not FRgsEdit3)) then begin
    TDBGridEh(Sender).Canvas.Brush.Color := Rgb(150, 255, 150);
    TDBGridEh(Sender).Canvas.Pen.Color := Rgb(150, 255, 150);
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Left + 3, ARect.Bottom);
  end;
  //� ������� ��������� �����������
  TDBGridEh(Sender).Canvas.Pen.Width := 1;
  if (VarToStr(v1) <> '') then begin
    if (Params.Row in [2, 3]) then
      TDBGridEh(Sender).Canvas.Brush.Color := RGB(255, 0, 255)
    else
      TDBGridEh(Sender).Canvas.Brush.Color := clBlue;
    //�������� ������������� � ������� ����� ���� ������
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Left + 7, ARect.Top + 7);
  end;
  if S.NNum(v2) <> 0 then begin
    TDBGridEh(Sender).Canvas.Pen.Width := 1;
    TDBGridEh(Sender).Canvas.Brush.Color := clBlack;
    //�������� ������������� � ����� ������ ���� ������
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Bottom - 7, ARect.Left + 7, ARect.Bottom);
  end;
  //���� ��� ����������, ���� �� ��������� �� ����� ����������� ���������
  Processed := True;
end;

procedure TFrmWGEdtTurv.Frg2DbGridEh1DataHintShow(Sender: TCustomDBGridEh;
  CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint;
  Column: TColumnEh; var Params: TDBGridEhDataHintParams;
  var Processed: Boolean);
var
  v1, v2, v3, v4: Variant;
begin
  inherited;
  if (Cell.X <= 1) or (Cell.X >= 1 + 16 - 1) then
    Exit;
  //������� �����������
  v1 := '';
  v2 := '';
  v3 := '';
  v4 := '';
  case Cell.Y of
    1:
      v1 := FArrTurv[Frg1.RecNo - 1][Cell.X - 1][cComRuk];
    2:
      begin
        v2 := FArrTurv[Frg1.RecNo - 1][Cell.X - 1][cComPar];
        v4 := FArrTurv[Frg1.RecNo - 1][Cell.X - 1][cNight];
      end;
    3:
      v3 := FArrTurv[Frg1.RecNo - 1][Cell.X - 1][cComSogl];
    4:
      v1 := FArrTurv[Frg1.RecNo - 1][Cell.X - 1][cComPr];
    5:
      v1 := FArrTurv[Frg1.RecNo - 1][Cell.X - 1][cComSct];
  end;
  //���� ����� � ������� ����� ����, ������� ����� ����� ��������, � �� ��� ������� �����, ���� ����������� ��������,
  //����� ���������� ���������� ����� ����� ���� �������� � ������ �����.
  if (InCellCursorPos.X <= 7) and (InCellCursorPos.Y <= 7) then
    FrmWWsrvTurvComment.ShowDialog(Self, CursorPos.X, CursorPos.Y + Frg1.RecNo * Frg1.DBGridEh1.RowHeight, v1, v2, v3, null);
  if ((InCellCursorPos.X <= 7) and (InCellCursorPos.Y >= Frg2.DBGridEh1.CellRect(Cell.X, Cell.Y).Bottom - Frg2.DBGridEh1.CellRect(Cell.X, Cell.Y).Top - 7)) then
    FrmWWsrvTurvComment.ShowDialog(Self, CursorPos.X, CursorPos.Y, null, null, null, v4);
end;

procedure TFrmWGEdtTurv.Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
var
  i, j: Integer;
begin
  SetLblWorkerText;
  for i := 1 to 16 do begin
    if (Frg2.RecNo in [1, 2, 3]) then begin
      if Frg2.DBGridEh1.Columns[i].PickList.Count = 0 then
        for j := 0 to FTurvCodes.Count - 1 do
          Frg2.DBGridEh1.Columns[i].PickList.Add(FTurvCodes.G(j, 'code') + ' - ' + FTurvCodes.G(j, 'name'));
    end
    else
      Frg2.DBGridEh1.Columns[i].PickList.Clear;
  end;
  if Frg2.MemTableEh1.Active then begin
    Frg2.DbGridEh1.ReadOnly := not FInEditMode or FIsCommited or (Frg2.RecNo > 3) or ((Frg2.RecNo = 1) and not FRgsEdit1) or ((Frg2.RecNo = 2) and not FRgsEdit2) or ((Frg2.RecNo = 3) and not FRgsEdit3);
    case Frg2.RecNo of
      1: Cth.SetButtonState(Frg2, mbtComment, '����������� ������������', null, FInEditMode and FRgsEdit1);
      2: Cth.SetButtonState(Frg2, mbtComment, '����������� ������ ������', null, FInEditMode and FRgsEdit2);
      3: Cth.SetButtonState(Frg2, mbtComment, '����������� ����������������', null, FInEditMode and FRgsEdit3);
      4: Cth.SetButtonState(Frg2, mbtComment, '����������� � ������', null, FInEditMode and FRgsEdit1);
      5: Cth.SetButtonState(Frg2, mbtComment, '����������� � ������', null, FInEditMode and FRgsEdit1);
    end;
  end;
end;

procedure TFrmWGEdtTurv.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  case Tag of
    mbtComment, mbtPremiumForDay, mbtFine, mbtPremiumForPeriod, mbtCommentForWorker: InputDialog(Tag);
  end;
  Handled := True;
end;

{==============================================================================}


procedure TFrmWGEdtTurv.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if FRgsEdit1 then
    Q.DBLock(False, FormDoc, VarToStr(id) + '-1', '', fNone);
  if FRgsEdit2 then
    Q.DBLock(False, FormDoc, VarToStr(id) + '-2', '', fNone);
  if FRgsEdit3 then
    Q.DBLock(False, FormDoc, VarToStr(id) + '-3', '', fNone);
end;



end.
