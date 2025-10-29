unit uFrmOGedtSnMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, uLabelColors,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;


type
  TFrmOGedtSnMain = class(TFrmBasicGrid2)
    pnlName: TPanel;
    lblName: TLabel;
    Frg3: TFrDBGridEh;
    procedure tmrAfterCreateTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FDays: TVarDynArray;
    FPeriodNames: TVarDynArray;
    FEditFieldName: string;
    FPrcMinOst, FPrcQnt, FPrcNeedM: Extended;
    FFields3: string;
    FNames3: string;
    //��������� ����, �� ������� ������������ �������� �����������
    FPlannedDt: TDateTime;
    //������ ��� ����������� ����� "� ����" - ����������� ���������, ���� ��������, ���� ���������
    FCustomOnWay: TVarDynArray;
    //��� �������� ����� ����� � ��������, � � ����� �������� � ������
    FRowColors, FRowFontColors: TVarDynArray;
    //��� ��������� (����, ����, ������������)
    FCategoryes: TVarDynArray2;
    //���� ���������
    FCategoryesSelf: TVarDynArray2;
    //���� ���������, �� ������� ���� ���������� ���������� �� �������������� ������� �������������
    FIdCategoryLock: Variant;
    //���� �������� ��������� "���������" (� ��� ��� �����)
    FIsSnab: Boolean;
    //������� ����� �������������� ����� ������, ��� �������������� ������, ���������� �� Ctrl-E � �����
    FAdminEditMode: Boolean;
    InAddControlChangeEvent: Boolean;
    FLockEdit: Boolean;
    function  PrepareForm: Boolean; override;
    procedure SetDetailGrid;
    procedure SetCategoryes;
    procedure SetFieldsEditable;
    procedure EditSettings;
    procedure SetCategory;
    function  ExportGridToXLSX(Open: Boolean = False; OnlyNot0: Boolean = False): Boolean;
    procedure RecalcPlannedEst;
    procedure InfoOnTheQntInProccessing;
    procedure SetLock;
    procedure ViewXLSFiles;
    function  CreateDemand: Boolean;
    procedure FillFromPlanned;
    procedure SetDetailInfo;
    procedure ClearInvalidReserve;
  protected
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
//    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Msg: string); virtual;
//    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); virtual;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
  public
  end;

var
  FrmOGedtSnMain: TFrmOGedtSnMain;

implementation

uses
  RegularExpressions,
  uWindows,
  uOrders,
  uPrintReport,
  D_Spl_InfoGrid,
  uFrmODedtNomenclFiles,
  uExcel,
  uSys,
  uFrmBasicInput
  ;

{$R *.dfm}

function TFrmOGedtSnMain.PrepareForm: Boolean;
var
  IsNstd: Boolean;
  va, va1: TVarDynArray;
  va2: TVarDynArray2;
  i, j: Integer;
begin
  Caption := '������������ ������ �� ���������';
  FDays:=Q.QLoadToVarDynArrayOneRow('select d0,d1,d2,d3,d4,d5,d6,prc_min_ost, prc_qnt, prc_need_m, planned_dt from spl_minremains_params', []);

  Q.QExecSql('delete from spl_remains_enter', []);
  FPrcMinOst:=FDays[7];
  FPrcQnt:=FDays[8];
  FPrcNeedM:=FDays[9];
  if FDays[10] = null
    then FPlannedDt := Date
    else FPlannedDt:=FDays[10];
  FDays:=Copy(FDays, 0, 7);
  FPeriodNames := [];
  for i := 0 to High(FDays) - 1 do
    FPeriodNames := FPeriodNames + [S.iif(FDays[i] < 0, '���', S.GetDaysCountToName(FDays[i]))];    //!!! ������ ��� ������ ������� � ����������
  //������ ��� ���������� ����������� "� ����" (���� onway_custom = 1) - ����� ������� dt2, dt1, ��� � ���� ���������� ���������(
  FCustomOnWay:=Q.QLoadToVarDynArrayOneRow('select onway_custom, onway_dt2, onway_dt1, onway_old_days from spl_minremains_params', []);
  //����
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible, myogIndicatorCheckboxes, myogMultiSelect];
  va2 := [
    ['id$i','_id','40'],
    ['aprc_min_ost$f','_aprc_min_ost','40'],
    ['aprc_qnt$f','_aprc_qnt','40'],
    ['aprc_need_m$f','_aprc_need_m','40'],
    ['e_min_ostatok$i','_emo','40'],
    ['e_qnt_order_opt$i','_eoo','40'],
    ['e_qnt_order$i','_eqo','40'],

    ['id_category$i','���������','80;L'],
    ['artikul$s','������������|�������','80'],
    ['name$s','������������|������������','180'],
    ['name_unit$s','������������|��.���.','50'],
    ['has_files$s','������������|�����.','40','pic'],
    ['supplierinfo$s','���������|������������','120','bt=����������','t=2'],
    ['suppliers_cnt$s','���������|���.','40','t=2'],
    ['no_namenom_supplier$s','���������|��� ����.','40','t=2','pic=-:6'],
    ['qnt0$f','������|'+S.GetDaysCountToName(FDays[0]),'60']
  ];
  //Q.QExecSql('selet 1 from', [], False);
  va := Copy(FPeriodNames, 1);
  //���� �� �������� ��� �������
  for i:=1 to High(va) + 1 do
    va2 := va2 + [['qnti' + InttoStr(i) + '$f', '������|' + va[i - 1], '60', 't=1']];
  //���� �� �������� ��� �������
  for i:=1 to High(va) + 1 do
    va2 := va2 + [['qnt' + InttoStr(i) + '$f', '������|' + va[i - 1], '60', 't=1']];
  va2 := va2 +
  [
    ['qnta0$f','������� �������|��','60'],
    ['qnta1$f','������� �������|�','60'],
    ['qnta2$f','������� �������|��','60'],
    ['qnt$f','������� �������|�����','60'],
    ['prc_qnt$f','% �� �������','40'],
    ['rezerva0$f','������� ������|��','40'],
    ['rezerva1$f','������� ������|�','40'],
    ['rezerva2$f','������� ������|��','40'],
    ['rezerv$f','������� ������|�����','40'],
    ['qnt_onway$f','� ����|���-��','40'],
    ['onway_old$f','� ����|�����','40', 'pic=1:3'],
    ['qnt_in_processing$f','� ���������','40'],
    ['qnt_suspended$f','�������� �������','40'],
    ['min_ostatok$i','����������� �������|����','40','t=3'],
    ['prc_min_ost$f','����������� �������|%','40'],
    ['qnt_order_opt$i','������ ����','40','t=3'],
    ['planned_need_days$i','������ �������  ����','40','t=3'],
    ['qnt_order$f','�����|����','60','t=3'],
    ['to_order$i','�����|� ������','40', 'chb','f=f:','t=3'],
    ['need$f','�����������|���.','60'],
    ['need_p$f','�����������|��������','60'],
    ['need_m$f','�����������|� ��������','60'],
    ['prc_need_m$f','�����������|%','40'],
    ['price_check$f','���������|����������� ����','60'],
    ['price_main$f','���������|����','60'],
    ['order_cost$f','���������|�����','60','f=r:'],
    ['qnt_cost$f','���������|�������','60','f=r:'],
    ['onway_cost$f','���������|� ����','60','f=r:'],
    ['ornumwoqnt$s','����� � ���������','60'],
    ['qnt_pl1$f','�������� ������|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 0))],'60'],
    ['qnt_pl2$f','�������� ������|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 1))],'60'],
    ['qnt_pl3$f','�������� ������|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 2))],'60'],
    ['qnt_pl$f', '�������� ������|�����','60']
  ];
  Frg1.Opt.SetFields(va2);
  Frg1.Opt.SetTable('v_spl_minremains');

  //������ (������������ ������ ������ ��� ��� � ���� ����� �� ���������)
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtParams, User.Role(rOr_Other_R_MinRemains_Ch)],[mbtGridSettings,User.Role(rOr_Other_R_MinRemains_ViewReports)],[],
    [-mbtCustom_SetCategory],
    [],[-1003,True,'������� �����'],[],
    [-mbtCustom_SnRecalcPlannedEst, User.Role(rOr_Other_R_MinRemains_Ch), '����������� �������� �����������'],
    [-mbtCustom_SnFillFromPlanned, 1, '��������� �� �������� �����������'], [-mbtCustom_SetOnWayPeriod],
    [],[-1002,User.Role(rOr_Other_R_MinRemains_Ch),'�������� ��������� �������'],[],
    [],[mbtExcelView],[-1001, True,'����������� �������'],[],[mbtGo, User.Role(rOr_Other_R_MinRemains_Ch), '������������ ������'],[mbtCtlPanel]
  ]);
  Frg1.Opt.SetButtonsIfEmpty([1003]);

  Frg1.CreateAddControls('1', cntCheck, '������ �� ��������', 'ChbPeriods', '', 4, yrefC, 129);
  Frg1.CreateAddControls('1', cntCheck, '���������', 'ChbSupplier', '', -1, yrefC, 120);
//  Frg1.CreateAddControls('1', cntCheck, '�������, ��.���.', 'chb_Article', '', 260, yrefT, 120);
//  Frg1.CreateAddControls('1', cntCheck, '������ ���������', 'chb_Checked', '', 1, yrefB, 120);
//  Frg1.CreateAddControls('1', cntCheck, '�� ���. ��������', 'chb_AQnt', '', 130, yrefB, 120);
//  Frg1.CreateAddControls('1', cntCheck, '�� ���. ��������', 'chb_AMinOst', '', 260, yrefB, 120);
//  Frg1.CreateAddControls('1', cntCheck, '�� �����������', 'chb_ANeedM', '', 390, yrefB, 120);

  Frg1.CreateAddControls('1', cntComboLK, '���������', 'CbCategory', '', 420, yrefC, 180);
  Frg1.CreateAddControls('1', cntCheck, '������', 'ChbCatEmpty', '', 620 , yrefC, 80);
  Frg1.CreateAddControls('1', cntCheck, '���', 'ChbCatAll', '', 620 + 80, yrefC, 40);
//  Frg1.ReadControlValues;

  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['dt$d','����','120'],
    ['state$s','������','120'],
    ['supplierinfo$s','�������� ���������','150'],
    ['qnta0$f','������� �������|��','60'],
    ['qnta1$f','������� �������|�','60'],
    ['qnta2$f','������� �������|��','60'],
    ['qnt$f','������� �������|�����','60'],
    ['rezerva0$f','������� ������|��','40'],
    ['rezerva1$f','������� ������|�','40'],
    ['rezerva2$f','������� ������|��','40'],
    ['rezerv$f','������� ������|�����','40'],
    ['qnt_onway$f','� ����','40'],
    ['qnt_in_processing$f','� ���������','40'],
    ['planned_need_days$i','������ �������','40','t=3'],
    ['qnt_order$f','�����|���-��','60','t=3'],
    ['to_order$i','�����|� ������','40', 'chb','t=3'],
    ['need$f','�����������|���.','60'],
    ['need_p$f','�����������|��������','60'],
    ['price_check$f','���������|����������� ����','60'],
    ['price_main$f','���������|����','60'],
    ['qnt_pl1$f','�������� ������|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 0))],'60'],
    ['qnt_pl2$f','�������� ������|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 1))],'60'],
    ['qnt_pl3$f','�������� ������|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 2))],'60'],
    ['qnt_pl$f', '�������� ������|�����','60']
  ]);
  Frg2.Opt.SetTable('spl_history');
  Frg2.Opt.SetWhere('where id = :id$i');
  Frg2.Opt.Caption := '������� �� ������������';

  SetCategoryes;

  //���������� ���� ���� ���� ����� �� ���������
  SetFieldsEditable;

  SetDetailGrid;

  Frg1.InfoArray:=[
    [Caption + '.'#13#10#13#10],[
    '� ������� �� ������ �������������� ������� ������������ ������ �� ������� � ������� �� ��������� �������,'#13#10+
    '���������� �� �������� ������� �� ������� � �������, �������� ������������ �������, '#13#10+
    '������ � ���� � � ��������� �� �������.'#13#10+
    '�� ��������� ���� ����� ��������������� � ������� �������� �������� ������������ ��� ���������:'#13#10+
    '����������� �������������� �� ������ �������, ����������� ������ ������ � ������'#13#10+
    '� ����������� ������, ����� � ������� ������������ ���������� ��������.'#13#10+
    '��� ���������� ������ ��������� �������� ��������� ������������ ������� �� ��������� ������,'#13#10+
    '��� ���������� ��������� �������� ������ ��������������.'#13#10+
    '��� ������� ��������� ����� �� ������� � ������� ������������� �� ��������� (�� 6) ��������, ��������� ���� � �����.'#13#10+
    '��� ����� ������ �������� �����������, ���� � ��� ����������� �� �������� ����� � ������.'#13#10+
    '����� ���������� ��������� � �������� ������������ �����������, ����� ��� ����� ����������� ��� ������� ������ � ������� "���������".'#13#10+
    '��� ����� �������� ������ ������ ������ � ������������� ����� "� ������".'#13#10+
    '��� �������� ������ � ��� ���������� ������ ������ "�����", ����� ������������ ������ �� ��������,'#13#10+
    '�� ������� ���������� ����� ������ � ������� "� �����"'#13#10+
    '��� �������� ������ � ������� ����������� ��������������� � ������ �����.'#13#10+
    '��� ������������ ������ ��������� ������ ������� "� ������", ��� ��������� ������ ����������.'#13#10+
    ''#13#10+
    '��������� (�������� ��� ��������������, �������) �������� �� ������ "���������" � ��������� ��� ���� �������������.'#13#10+
    ''#13#10+
    '� ������� �������� �����, ����������, ���������� ��������, �� ������ ���������� �������, ���������� �� � �������� (����������� ������ ���� �������)'#13#10+
    ''#13#10
  ]];
  Frg1.Opt.ColumnsInfo:=[
    ['tomin', '���� ������� �����������, �� ����� �������� ������� "������ ���������" � ���������, � � ������� ����� ������������ ������ ��� ������'],
    ['id_category' ,
      '������������ ������������ �� ���������� ���������. �� ������ ����� ������ ���� ��������� (� ������, ���� ���������� �����'+
      '"���������� ������"'#13#10'���� ��������� �� ����� �����������, �� �� ������� ������ ������ � ������� �� ���� ������'#1#10+
      '������� �� ����� �� ����������� ������ ��� ��������� �������, ��� �� �������� ������ ������� ������� � ������� ����� "������ ���������" � ���������� ����.'#1#10+
      '��� ������������ ������, ����������� ��������� ������ �� ��������� ��� ������ ���������, ��������� ����������� � ����������� � ������'+
      ''#1#10
    ],
    ['supplierinfo', '������������ ������������ ��������� ���������� �� ������ ������������. ���� ����� ������, ���� ������� � ������� ������������ ����������'+
      '���������, �� ������� �� ��������� �� �������'#1#10+
      '������� ������ ������ � ������ ����� ����������� (��� �������������, ���� � ��� ���� �����) ������ �� ������������ ����������'#1#10
    ],
    ['suppliers_cnt', '���������� ������� � ������� ������������ ���������� ��� ������ �������������� �������'],
    ['no_namenom_supplier', '���� ������� ������������ ����������� ��� ������ ������ ��������, �� � ���� ������� ���� ������ � ������� ��������������, ����� ����� ������������ ������� �����'],
    ['qnt0','������ �� ������������ �� ��������� ������. � ������ ����� �������, � ��� ����� ������ � ����������, �������������� ��� �������� � ��������� ������ � �������.'+
     '������ ������������� �� ����������� ��������� ��� ������ � ������������, � ����� �� ����� �������.'#1#10+
     '�� �������� ����� ����� ����� ���������� ����������� �� �������'#1#10
    ],
    ['qnt1;qnt2;qnt3;qnt4;qnt5;qnt5','������ �� ������������ �� �������� ������. ������ ������������� �� ����������� ��������� ��� ������ � ������������, � ����� �� ����� �������.'+
     '�� �������� ����� ����� ����� ���������� ����������� �� �������'#1#10
    ],
    ['qnti1;qnti2;qnti3;qnti4;qnti5;qnti5','������ �� ������������ �� �������� ������. ������������� �� ����������� ��������� ���������, ���� ������������� �� �����������.'+
     '�� �������� ����� ����� ����� ���������� ����������� �� �������'#1#10
    ],
    ['qnt', '������� (�����������) ������� �� ���� ������� (�� �� �� ������������. �������������� �������, ���� �������� ������� �� '+
    '������� �� ��������� ������ ������ 50% (���� ������� �������������). �� �������� ����� ����� �������� ������� �� �������.'
    ],
    ['prc_qnt', '����������, ������� ��������� ���������� ���������� ������� �� ������� �� ��������� ������. ��������� �������� � ����������, �� ����� ���� ������� ��� ���������� ������, � ���� ������ �� ����� ��������� ����� (��� ��������� �������� ������� ���� � ������)'],
    ['rezerv', '������ �� �������. �������� ������� ���� �� ������, ����� ���������� �����������'],
    ['qnt_onway', '�������������� ��� ���������� ������ � ����� ����������, �� �������� ��� �� ������� ��������� ���������. �� ��������� �� ������ ���������� ���������������.'#13#10+
    '��� �������� ����� ������ ������������ ������ ������� ��� ���� ������ (�� ������ ������ �����).'#13#10+
    '���� ���� ������ �����, �� ��������� � �� ������ ������ ��� ���� �������, � ������ � ���� ������� ����� ���������� �����.'
    ],
//    ['qnt_in_processing','���������� �� �������, �� ������ ������� ������ �� ���������, �� ������� ��� ��������������� ���������� � �� ������� ���������� � ����. �� ��������� - �������������� ����������.'],
    ['qnt_in_processing','���������� �� ������� �� ��������� �� ��������� 7 ����. �� ��������� - ������ ������ ��.'],
    ['min_ostatok','�������, ������� ������ �������������� �� �������. �������� � �����, ���� ���� ����� �� ��������������. '+
     '�������������� �������, ���� ���� ������� �� 10% ������ ������� �� ��������� ������, � ������, ���� �� 10% ������ �������. '+
     '(������� ������ ����� �������� � ����������, � ����� � �������� ��� ����� �������.)'
    ],
    ['prc_min_ost', '����������, ��������� ����������� ������� ��������� ������ �� ��������� ������, � ���������. '+
     '���� ����� ������ ���. �������, �� ������� ����� ������ ����, ���� �� ������ ������, �� ������� ����� ������������. ' +
     '�� ���� ������ ���� "���. �������" ��������������. ������� ��� ��������� ���������� ������������ ����� ���������, ��� '+
     '����� ������ �������� �� ���� ������ � ������� ��������. ��������� ������� ����� �������������� ����� �������.'
    ],
    ['qnt_order_opt','����������� ������ ��� ������� ������. �������� � �����.'],
    ['qnt_order','���������� �� ������������ � �������� �������� ���������, ������� ������� � ������ �� ��������� � ���. �������� � ������.'+
     '���� ������ ����� Shift, �� ����� ������� �������� ����������� ������. ��������� �������� �� ������������ ��� ������������ ������.'
    ],
    ['to_order','�� �������, �� ������� ����� ����������� ������� (��� �������, ��� � ��� ����� ����������� ���������� � ������), ��� ������� ������ "������������ �����", ������� � ����������� � ��� ������ ����������.'],
    ['need','��� ���������� ����� ��������, ����� ������� ����������� (������� ������ �� �������, � ������ ����������, ������� ���� �� ������, � � ������ ����, ��� ��� �������� � � ����).'+
     '���������� ����������, ���� ����������� �������������. � ���� ������ ������ ����� ���������� �����.'
    ],
    ['need_m','��� ���������� ����� ��������, ����� ������� ����������� (������� ������ �� �������, � ������ ����������, ������� ���� �� ������, � � ������ ����, ��� ��� �������� � � ����.), '+
     '� ��� ���� ������� ���������� �� ������� �� ������������ �������. ���������� ����������, ���� ����������� �������������. � ���� ������ ������ ����� ���������� �����.'
    ],
    ['price_main','���� ���������� ������� �� ������������, �� ��������� �� �� ��������� ���������� (� ����� ������� ���������). '+
     '���� ��������������, ���� �� ����� ����� ���� �� �� 1 ����� ���������� �� ����������� ����.'+
     '�� �������� ����� ����� ������� ������ ���� ��������� ��������� �� ��������, � ��� ���� �������� �������� ����� ���������.'
    ],
    ['order_cost','��������� (�� ��������� ����) ������ � ����������, ��������� � ����� "� ������". �� �������� ������ ����� �������� ������ �� ������ �� ���� ������������ �� ���� ������, ��� �� �������� �������� ����� ������.'],
    ['qnt_cost','��������� ������������ �������'],
    ['onway_cost','��������� ������ "� ����"'],
    ['ornumwoqnt','����� ������ �� ���� �������� ����� (����� � ���� ��������), �� ������� �� ������� ���������� ������ ���� ������ � ����.'],
    ['price_check','���� ��� �������� ������� �� �������, �������� �������.'],
    ['has_files','������� � ���� ���� ����������, ��� � ������ ������������ ���� ������������� �����. �� �������� ������ ����� ������ ������ � ������������ ��������� � ����������� ���� ������.'],
    ['qnt_pl1;qnt_pl2;qnt_pl3','����������� �� �������� ������� �� ��������� �����. �� �������� ������ ����� ���������� �������� ������, �� ������� ��������� ��� �����������, � ������������ �� ���������.'],
    ['qnt_pl','����������� �� �������� ������� �� ��� ������, ������� � ��������. ��� ��������� �������� ������� � ���� � �������� � ��������� ����� ������������� �� ���������������! ����� ��������� �� ������, �������� "����������� �������� �����������" � ����.'],
    ['qnt_suspended','�������� ������� - ������� �������, �������� �� ������ �� �������� ������� (������������ ������� �������� � ���������� �������)'],
    ['','']
  ];


  Result := inherited;
//  Frg1.Prepare;
//  Result := True;

  FIdCategoryLock := -1;
//  SetLock;

  SetLength(FRowColors, Frg1.DBGridEh1.Columns.Count + 1);
  SetLength(FRowFontColors, Frg1.DBGridEh1.Columns.Count + 1);

  FrmOGedtSnMain := Self;
end;

procedure TFrmOGedtSnMain.SetDetailGrid;
begin
  Frg3.Opt.SetFields([
    ['id$i', '_id', 20],
    ['qnt$f', '�������', 50],
    ['prc_qnt$f', '%', 20],
    ['rezerv$f', '������', 50],
    ['qnt_onway$f', '� ����', 50],
    ['qnt_in_processing$f', '� ���.', 50],
    ['min_ostatok$f', '���.���.', 55],
    ['prc_min_ost$f', '%', 20],
    ['qnt_order_opt$f', '������', 50],
    ['need$f', '�����������', 80],
    ['need_m$f', '�����������+', 80],
    ['price_main$f', '? ����', 70],
    ['order_cost$f', '? �����', 70],
    ['qnt_cost$f', '? �������', 70],
    ['onway_cost$f', '? � ����', 70],
    ['qnt0$f', '������ 1', 70],
    ['qnt2$f', '������ 2', 70],
    ['qnt3$f', '������ 3', 70],
    ['qnt4$f', '������ 4', 70],
    ['qnt5$f', '������ 5', 70],
    ['qnt6$f', '������ 6', 70],
    ['qnti1$f', '������ 1', 70],
    ['qnti2$f', '������ 2', 70],
    ['qnti3$f', '������ 3', 70],
    ['qnti4$f', '������ 4', 70],
    ['qnti5$f', '������ 5', 70],
    ['qnti6$f', '������ 6', 70]
  ]);
  Frg3.Opt.SetDataMode(myogdmFromArray);
  Frg3.Prepare;
  Frg3.LoadSourceDataFromArray([[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]);
  Frg3.DbGridEh1.HorzScrollBar.VisibleMode := sbNeverShowEh;
end;


{������� �����}

procedure TFrmOGedtSnMain.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  Frg1.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Fr, 'ChbPeriods') = 0, False);
  Frg1.Opt.SetColFeature('2', 'i', Cth.GetControlValue(Fr, 'ChbSupplier') = 0, False);
  Frg1.SetColumnsVisible;
  if not A.InArray(TControl(Sender).Name, ['ChbPeriods', 'ChbSupplier']) and Fr.IsPrepared then
    Frg1.RefreshGrid;
end;

procedure TFrmOGedtSnMain.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  i, j: Integer;
  va1, va2: TVarDynArray;
  b: Boolean;
begin
  if Tag = mbtGo then begin
    CreateDemand;
  end
  else if Tag = mbtTest then begin
  end
  else if Tag = mbtExcelView then begin
    ViewXLSFiles;
  end
  else if Tag = mbtExcel then begin
    ExportGridToXLSX(True, False);
  end
  else if Tag = mbtCustom_SetCategory then begin
    SetCategory;
  end
  else if Tag = mbtCustom_SnRecalcPlannedEst then begin
    RecalcPlannedEst;
  end
  else if Tag = mbtCustom_SnFillFromPlanned then begin
    FillFromPlanned;
  end
  else if Tag = 1001 then begin
    va1 := Q.QLoadToVarDynArrayOneCol('select caption from v_spl_history_contents', []);
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~������� ��������� ��', 50 + 200, 50,
      [[cntComboL, '����:','1:500']],
      [VarArrayOf(['', VarArrayOf(va1)])],
      va2, [['']], nil
    ) < 0 then
      Exit;
    Wh.ExecReference(myfrm_J_SnHistory, Self, [], va2[0]);
  end
  else if Tag = 1002 then begin
    ClearInvalidReserve;
  end
  else if Tag = 1003 then begin
    va1 := Q.QLoadToVarDynArrayOneCol('select ornum from v_orders where id > 0 and id_itm is not null order by id', []);
    va2 := Q.QLoadToVarDynArrayOneCol('select id from v_orders where id > 0 and id_itm is not null order by id', []);
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~����� ��� �������', 50 + 100, 50,
      [[cntComboLK, '�����:','0:500']],
      [VarArrayOf([null, VarArrayOf(va1), VarArrayOf(va2)])],
      va2, [['']], nil
    ) < 0 then
      Exit;
    if va2[0].AsString = '' then begin
      Frg1.Opt.SetWhere('');
      Frg1.Opt.Caption := Caption;
    end
    else begin
      va1 := Q.QLoadToVarDynArrayOneRow('select id_itm, ornum from v_orders where id = :id$i', [va2[0]]);
      Frg1.Opt.SetWhere(' where id in (select id_nomencl from dv.nomenclatura_in_izdel where id_nomizdel_parent_t is not null and id_zakaz = ' + va1[0].AsString + ')');
      Frg1.Opt.Caption := Caption + ' (' + va1[1].AsString + ')';
    end;
    Frg1.RefreshGrid;
 end
  else if Tag = mbtParams then begin
    repeat
      va2:=[];
      va1 := copy(FDays);
      for i := 0 to High(va1) do
        if va1[i] < 0 then
          va1[i] := 0;
      if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '~���������', 200, 100,
          [
            [cntNEdit, '% ���������'#13#10'���. �������', '1:100', 80],
            [cntNEdit, '% ���������'#13#10'����. �������', '1:100', 80],
            [cntNEdit, '% ���������'#13#10'�����������', '1:100', 80],
            [cntNEdit, '������ ������', '1:10000', 80],
            [cntNEdit, '������ 1', '0:10000', 80], [cntNEdit, '������ 2', '0:10000', 80],
            [cntNEdit, '������ 3', '0:10000'], [cntNEdit, '������ 4', '0:10000', 80], [cntNEdit, '������ 5', '0:10000', 80], [cntNEdit, '������ 6', '0:10000', 80]
          ],
          [FPrcMinOst, FPrcQnt, FPrcNeedM] + va1,
          va2,
          [['������� ������ ������, �������� ��� ��������� �������� � ������� ��������� �������/������� (� ����).'#13#10+
            '���� ��������� 0, �� ������ ������ ������������ �� �����.'#13#10+
            '������ ������ ���������� ����� �������� � �������� 1'#13#10+
            '��������, ������������� �����, ��������� ��������� ��� ���� �������������!'
           ]],
           nil
        ) <= 0 then Exit;  //����� �� ������ ��� ���� ��� ���������
      b := True;
      for i := 3 to High(va2) do
        if va2[i] > 0 then
          b := False;
      if not b then
        Break;
      va1 := Copy(va2);
      MyWarningMessage('������ ���� ����� ���� �� ���� ������!');
    until False;
    FPrcMinOst := va2[0];
    FPrcQnt := va2[1];
    FPrcNeedM := va2[2];
    va1 := Copy(va2, 4);
    for i := 0 to High(va1) do
      if va1[i] = 0 then
        va1[i] := 100000;
    a.VarDynArraySort(va1, True);
    for i := 0 to High(va1) do
      if va1[i] = 100000 then
        va1[i] := -100;
    FDays := [va2[3]] + va1;
    Q.QExecSql(
      'update spl_minremains_params set '+
      'd0=:d0$i,d1=:d1$i,d2=:d2$i,d3=:d3$i,d4=:d4$i,d5=:d5$i,d6=:d6$i,prc_min_ost=:prc_min_ost$i,prc_qnt=:prc_qnt$i,prc_need_m=:prc_need_m$i',
      [va2[3]] + va1 + [FPrcMinOst, FPrcQnt, FPrcNeedM]
    );
//    SetCaptions;
//!!!    Gh.SetGridColumnsProperty(DBGridEh1, cptCaption, Pr[1].Fields, Pr[1].Captions);
    Fr.RefreshGrid;
  end
  else if Tag = mbtCustom_SetOnWayPeriod then begin
    if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '~������ "� ����', 200, 100,
        [
          [cntCheck, '��������', '', 80],
          [cntDtEdit, '������ �', '*:*', 80],
          [cntDtEdit, '��', '*:*', 80],
          [cntNEdit, '���������, ����', '0:10000:0', 80]
        ],
        FCustomOnWay,
        va2,
        [['������� ������ ������� ������ ��� ����� "� ����"'#13#10+
          '(��� ������������� ���� �������� ���������� ������� "��������")'#13#10+
          '�����: � ������� ��������� ������ ����� ����� ������ ��� �������� "� ����"!'#13#10+#13#10+
          '����� ���������� �������� "���������, ����".'#13#10+
          '��� ���� ������, ��� ���� ����� ������ ������ �� ������ � ����, ����� ���������� ������� �����..'#13#10
         ]],
         nil
      ) <= 0 then Exit;  //����� �� ������ ��� ���� ��� ���������
    FCustomOnWay:= va2;
    Q.QExecSql('update spl_minremains_params set onway_custom = :p1$i, onway_dt2 = :p2$d, onway_dt1 = :p3$d, onway_old_days = :p4$i', FCustomOnWay);
    Fr.RefreshGrid;
  end
  else
    inherited;
end;

procedure TFrmOGedtSnMain.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if Fr.CurrField = 'supplierinfo' then begin
    Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView), Fr.ID,
      VararrayOf([Fr.GetValue('name'), Fr.GetValue('name_unit')])
    );
    Fr.RefreshRecord;
  end;
  Fr.ChangeSelectedData;
end;

procedure TFrmOGedtSnMain.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
var
  st1, st2: string;
  i: Integer;
  b: Boolean;
begin
  //����, ������� ����� �������� �� null ���������� �� �� ��������� [����, ������(True), {������� ���������� - ������ ���� ���� ������ �� ����}, {�������� ��� null - null, 0}]
(*  Pr[1].NullFields := [];
  b := Cth.GetControlValue(TControl(Self.FindComponent('chb_Periods'))) = 1;
  for i := 1 to High(FDays) do
    if (FDays[i] < 0) { or (not b)} then begin
      Pr[1].NullFields := Pr[1].NullFields + [['qnt' + IntToStr(i), True, False, 0]];
      Pr[1].NullFields := Pr[1].NullFields + [['qnti' + IntToStr(i), True, False, 0]];
    end;*)
  SqlWhere := A.ImplodeNotEmpty([
    //S.IIf(TDbCheckBoxEh(Self.FindComponent('chb_Checked')).Checked, 'nvl(tomin, 0) = 1', ''),
    //S.IIf(TDbCheckBoxEh(Self.FindComponent('chb_AMinOst')).Checked, '(prc_min_ost <= -aprc_min_ost or prc_min_ost >= aprc_min_ost)', ''),
    //S.IIf(TDbCheckBoxEh(Self.FindComponent('chb_AQnt')).Checked, '(prc_qnt <= aprc_qnt)', ''),
    //S.IIf(TDbCheckBoxEh(Self.FindComponent('chb_ANeedM')).Checked, '((need_m < 0)or(prc_need_m <= -aprc_need_m or prc_need_m >= aprc_need_m))', ''),
    S.IIfStr((Fr.GetControlValue('ChbCatAll') = 0) and (Length(FCategoryesSelf) > 0),
      '(id_category = ' + VarToStr(Fr.GetControlValue('CbCategory')) + S.IIfStr(Fr.GetControlValue('ChbCatEmpty') = 1, ' or id_category is null') + ')')
    ], ' and '
  );
end;


procedure TFrmOGedtSnMain.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//��� ����� ������ � ����� ������� (������� Enter ��� ���� ������ ����� ����, ��� ���� ������� ������ � ��������� ������, ��� ���� �� ��������)
var
  i: Integer;
  e: extended;
  va2: TVarDynArray2;
begin
  Handled := True;
  if not Fr.RefreshRecord then begin
    //���� �������, ���� ������ ���� ������� (��������� ����� ������ � RefreshRecord)
    Fr.MemTableEh1.Cancel;
    Exit;
  end;
  //SetFieldEditable ������ �����������, ��� ����� �� ���������, ��� ����� ����� ������ � �������, ���� ���� ��������� MemTableEh1.ReadOnly � �����,
  //� ���� ����, ��������������� ��� ������. �� ���� ������ ��� ����������, � ����� �� �������������. ����� � �������� ������ ������� � ��������� CancelEdit,
  //�� ��� �� �������� ����� �������������, ���� ������ ��������������� �� ��������������, �� �� ���� ����� ������.
//!!!  SetFieldEditable(1);
//  if MemTableEh1.ReadOnly then begin
//    MemTableEh1.Cancel;
//    Exit;
//  end;
  //���������� ��������� ������, ��� ����� ����� �������� ������� �� ��������� ��������� (Value)
  //��� ��������� �������� ����� ��� MemTableEh1.FieldByName(Fr.CurrField).AsInteger,
  //� ��� ���� ��� ���� ������������� (���� ������� 0, �� � ���� ����� 1, � ��������)!
  //��� ����������� � ����� ����� �� Enter �������� GoToNextEdit(1), �� �������������� �� ������,
  //��������� ������������ � ������ �� ������ ���� �� ����� ��� ����� ����� ������, ���� ���� ���� ������ � ������ ������.
  //� ������, ���� ���� ������ � ����, ���������� ������ (������ �������� ��������� ����� ������� � ���� ������ �� ���).
  repeat
    if (Fr.CurrField = 'tomin') then begin
      i := S.Iif(Fr.MemTableEh1.FieldByName(Fr.CurrField).AsInteger = 0, 1, 0);
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 1, S.NullIfEmpty(Value)]));
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'min_ostatok') then begin
      if not (S.IsNumber(Value, 0, 1000000) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 2, S.NullIfEmpty(Value)]));
//      GoToNextEdit(1);    //��� ����������� � ����� ����� �� Enter
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'qnt_order_opt') then begin
      if not (S.IsNumber(Value, 0, 1000000) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 3, S.NullIfEmpty(Value)]));
//      GoToNextEdit(1);    //��� ����������� � ����� ����� �� Enter
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'to_order'){ and not MemTableEh1.ReadOnly} then begin
      i := S.Iif(Fr.MemTableEh1.FieldByName(Fr.CurrField).AsInteger = 0, 1, 0);
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 5, S.NullIfEmpty(Value)]));
      va2 := Q.QLoadToVarDynArray2('select to_order from spl_itm_nom_props where id = :id$i', [Fr.ID]);
      if (Length(va2) = 0) or (va2[0][0] <> S.NullIfEmpty(Value)) then begin
        MyWarningMessage('�� ������� ���������� ��������!');
        Fr.MemTableEh1.Cancel;
      end
      else begin
        Fr.MemTableEh1.FieldByName(Fr.CurrField).AsInteger := i;
        Mth.PostAndEdit(Fr.MemTableEh1);
//        Exit;
      end;
      //MemTableEh1.RefreshRecord;
      //Mth.PostAndEdit(MemTableEh1);
    end;
    if (Fr.CurrField = 'qnt_order') then begin
      if not (S.IsNumber(Value, 0, 1000000) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 4, S.NullIfEmpty(Value)]));
      va2 := Q.QLoadToVarDynArray2('select qnt_order from spl_itm_nom_props where id = :id$i', [Fr.ID]);
      if (Length(va2) = 0) or (va2[0][0] <> S.NullIfEmpty(Value)) then begin
        MyWarningMessage('�� ������� ���������� ��������!');
        Fr.MemTableEh1.Cancel;
      end
      else begin
        Fr.MemTableEh1.FieldByName(Fr.CurrField).AsVariant := S.NullIfEmpty(Value);
        Fr.MemTableEh1.FieldByName('order_cost').AsVariant := S.NullIf0(Round(S.NNum(Value) * S.NNum(Fr.MemTableEh1.FieldByName('price_main').AsFloat)));
        Fr.MemTableEh1.FieldByName('e_qnt_order').AsInteger := 1;
        Mth.PostAndEdit(Fr.MemTableEh1);
//        GoToNextEdit(1);    //��� ����������� � ����� ����� �� Enter
      end;
    end;
    if (Fr.CurrField = 'id_category') then begin
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 6, S.NullIfEmpty(Value)]));
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'price_check') then begin
      if not (S.IsNumber(Value, 0, 100000000, 2) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 7, S.NullIfEmpty(Value)]));
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'planned_need_days') then begin
      if not (S.IsNumber(Value, 0, 90, 0) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 9, S.NullIfEmpty(Value)]));
      Orders.CalcSplNeedPlanned(Fr.ID);
      Fr.RefreshRecord;
    end;
    //!!!�����������!!!
    Fr.ChangeSelectedData;
    Exit;
  until False;
  Fr.MemTableEh1.Cancel;
end;

procedure TFrmOGedtSnMain.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  v: Variant;
begin
//exit;
  if Fr.IsEmpty then
    Exit;
  if FieldName = 'min_ostatok' then begin
    if S.NNum(Fr.GetValue('prc_min_ost')) <= - S.NNum(Fr.GetValue('aprc_min_ost')) then
      Params.Background := clmyPink;  //�������
    if S.NNum(Fr.GetValue('prc_min_ost')) >= + S.NNum(Fr.GetValue('aprc_min_ost')) then
      Params.Background := clmyYelow;  //������
  end;
  if FieldName = 'qnt_order_opt' then begin
    if Fr.GetValue('e_qnt_order_opt') = 1 then begin
      Params.Font.Color := clBlue;
      Params.Font.Style := [fsUnderline];
    end;
  end;
  if FieldName = 'min_ostatok' then begin
    if Fr.GetValue('e_min_ostatok') = 1 then begin
      Params.Font.Color := clBlue;
      Params.Font.Style := [fsUnderline];
    end;
  end;
  if FieldName = 'qnt_order' then begin
    if Fr.GetValue('e_qnt_order') = 1 then begin
      Params.Font.Color := clBlue;
      Params.Font.Style := [fsUnderline];
    end;
    if (S.NNum(Fr.GetValue('to_order')) = 1) and (
      (S.NNum(Fr.GetValue('need_p')) >= 0) or
      (S.NNum(Fr.GetValue('qnt_order')) / - S.NNum(Fr.GetValue('need_p')) > 1.33))
      then Params.Background := clmyPink;
  end;
  if FieldName = 'prc_qnt' then begin
    if S.NNum(Fr.GetValue('aprc_qnt')) <> FPrcQnt then
      Params.Font.Color := clBlue;
  end;
  if FieldName = 'prc_min_ost' then begin
    if S.NNum(Fr.GetValue('aprc_min_ost')) <> FPrcMinOst then
      Params.Font.Color := clBlue;
  end;
  if FieldName = 'prc_need_m' then begin
    if S.NNum(Fr.GetValue('aprc_need_m')) <> FPrcNeedM then
      Params.Font.Color := clBlue;
  end;
  if FieldName = 'need' then begin
    if S.NNum(Fr.GetValue('need')) < 0 then
      Params.Background := clmyGray;
  end;
  if FieldName = 'need_p' then begin
    if S.NNum(Fr.GetValue('need_p')) < 0 then
      Params.Background := clmyGray;
  end;
  if FieldName = 'need_m' then begin
{    if MemTableEh1.FieldByName('prc_need_m').AsFloat <= -MemTableEh1.FieldByName('aprc_need_m').AsFloat then
      Background := RGB(255, 180, 180)  //�������
    else if MemTableEh1.FieldByName('prc_need_m').AsFloat >= +MemTableEh1.FieldByName('aprc_need_m').AsFloat then
      Background := RGB(255, 255, 100)  //������
    else if MemTableEh1.FieldByName('need_m').AsFloat < 0 then
      Background := RGB(200, 200, 200);}
    if S.NNum(Fr.GetValue('need_m')) < 0 then
      Params.Background := clmyGray;
  end;
  if FieldName = 'qnt' then begin
    if (S.NNum(Fr.GetValue('qnt0')) > 0) and (S.NNum(Fr.GetValue('prc_qnt')) <= S.NNum(Fr.GetValue('aprc_qnt'))) then
      Params.Background :=clMyPink;
  end;
  if FieldName = 'qnt_onway' then begin
    //��������� ������ "� ����", ���� ����� ��������� ������ ��� ���� ������
    if FCustomOnWay[0] = 1 then
      Params.Font.Color := clBlue;
    if (S.NNum(Fr.GetValue('onway_old')) = 1) then
      Params.Background :=clMyPink;  //�������
  end;
  if FieldName = 'price_main' then begin
    //��������� ��������� ���� ��������� ����������, ���� �������� ����� ���������� ���� �� �� �����, ������������� ������� ��� �������
    if not ((Fr.GetValue('price_main') = null) or (Fr.GetValue('price_check') = null)) then begin
      if Trunc(S.NNum(Fr.GetValue('price_main'))) < Trunc(S.NNum(Fr.GetValue('price_check')))
        then Params.Background := clmyGreen;  //�����������
      if Trunc(S.NNum(Fr.GetValue('price_main'))) > Trunc(S.NNum(Fr.GetValue('price_check')))
        then Params.Background := clmyPink;  //�������
    end;
  end;
  if (Length(FRowColors) > 0) and (Frg1.MemTableEh1.Active) and (Frg1.MemTableEh1.RecordCount > 0) and (Frg1.MemTableEh1.RecNo = Frg1.DbGridEh1.Row) then begin
    FRowColors[TColumnEh(Sender).Index] := Params.BackGround;
    FRowFontColors[TColumnEh(Sender).Index] := Params.Font.Color;
//    SetDetailInfo;
    //��� �������� ���������� ������ � �������� ��� ������ MemTable.Refresh � ������������ ������!!!
//    ChangeSelectedData;
  end;
end;

procedure TFrmOGedtSnMain.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
  i: Integer;
  st: string;
  AddParamD: Variant;
  AddParamAr: tVarDynArray;
  rx1: TRegEx;
begin
  inherited;
  if A.PosInArray(Fr.CurrField, ['prc_qnt', 'prc_min_ost', 'prc_need_m']) >= 0 then begin
      if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '', 180, 80,
          [[cntNEdit, '% ���������', '1:100:N', 80]],
          [Fr.GetValue('a'+Fr.CurrField)], va,
          [['������� �������������� �� ������� ������������.'#13#10'����� ������������ ������� �� ���������, ������� ������ ��������.']],
           nil
        ) < 0 then Exit;
    Q.QExecSql('insert into spl_itm_nom_props (id) select :id1$i from dual where not exists (select null from spl_itm_nom_props where id = :id2$i)', [Fr.ID, Fr.ID]);    Q.QExecSql('update spl_itm_nom_props set ' + Fr.CurrField + '=:prc$i where id = :id$i', [va[0], id]);
    Fr.RefreshRecord;
  end;
  AddParamAr:= [Fr.GetValueS('name'), Fr.GetValueS('name_unit')];
  AddParamD:= VararrayOf(AddParamAr);
  if Fr.CurrField = 'supplierinfo' then begin
    Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView), Fr.ID, AddParamD);
    Fr.RefreshRecord;
  end;
  if Fr.CurrField = 'qnt_order_opt' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_MinPart, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'rezerv' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_Rezerv, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'qnt' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_QntOnStore, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'qnt_onway' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_OnWay, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'qnt_in_processing' then begin
//    Info_QntInProccessing;
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_OnDemand, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'price_main' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_InBillList, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'order_cost' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_SpSchetList, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'name' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_MoveNomencl, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if TRegEx.IsMatch(Fr.CurrField, '^qnt[0-9]{1}$') then begin
    AddParamD:= VararrayOf(AddParamAr + [FDays[StrtoInt(Fr.CurrField[4])]]);
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_Consumption, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if TRegEx.IsMatch(Fr.CurrField, '^qnti[0-9]{1}$') then begin
    AddParamD:= VararrayOf(AddParamAr + [FDays[StrtoInt(Fr.CurrField[5])]]);
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_Incoming, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if TRegEx.IsMatch(Fr.CurrField, '^qnt_pl[1-3]{1}$') then begin
    AddParamD[1] := -S.NNum(Copy(Fr.CurrField, 7, 1));
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_PlannedOrders, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'has_files' then begin
    TFrmODedtNomenclFiles.ShowDialog(Self, Fr.ID);
  end;
end;

procedure TFrmOGedtSnMain.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //�������� ��� ������� � ��������� ������ ���������
  //����� �����, �������� ��������� ��������� ��� ���� ������� ���������
  //�������� ��������� ��������� �������, ��� ������� ��� ������ ��� ����, ���� ���������
  //(��������, ��� ����� ��������� ������ ���������, ������������ � ������������)
  //�������� ��������� ����� ������ � ���������� ������� �������������� ����� �������������
//exit;
  if Fr.CurrField = 'price_check' then
  else if Fr.CurrField = 'id_category'
    then ReadOnly := not (FIsSnab or (A.PosInArray(Fr.GetValue('id_category'), FCategoryesSelf + [['', null]], 1) >= 0))
    else ReadOnly := (Length(FCategoryesSelf) = 0) or (not FAdminEditMode and
      not (Fr.GetValue('id_category') = Cth.GetControlValue(Fr, 'CbCategory')));
end;

procedure TFrmOGedtSnMain.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
  SetDetailInfo;
end;

procedure TFrmOGedtSnMain.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id$i', [Frg1.ID]);
end;


{END ������� �����}


procedure TFrmOGedtSnMain.SetCategoryes;
var
  i: Integer;
begin
  FCategoryes:=Q.QLoadToVarDynArray2('select name, id, useravail from spl_categoryes order by name', []);
  FCategoryesSelf:=[];
  for i:=0 to High(FCategoryes) do
    if S.InCommaStr(IntToStr(User.GetId), FCategoryes[i, 2]) then begin
      FCategoryesSelf:=FCategoryesSelf +[ [FCategoryes[i][0], FCategoryes[i][1]]];
      if FCategoryes[i][1] = 1 then FIsSnab:= True;
    end;
  Cth.AddToComboBoxEh(TDBComboBoxEh(Frg1.FindComponent('CbCategory')), FCategoryesSelf);
  TDBComboBoxEh(Frg1.FindComponent('CbCategory')).ItemIndex:=0;
  if not FIsSnab then begin
    TDBCheckBoxEh(Frg1.FindComponent('ChbCatAll')).Checked:=False;
    TDBCheckBoxEh(Frg1.FindComponent('ChbCatAll')).Visible:=False;
  end
  else TDBComboBoxEh(Frg1.FindComponent('CbCategory')).Value:='1';
  Frg1.Opt.SetPick('id_category', A.VarDynArray2ColToVD1(FCategoryes, 0), A.VarDynArray2ColToVD1(FCategoryes, 1), True);
end;

procedure TFrmOGedtSnMain.SetFieldsEditable;
//���������� ���� ���� ���� ����� �� ���������
begin
  Frg1.Opt.SetColFeature('3', 'e', User.Roles([], [rOr_Other_R_MinRemains_Ch]) and not FLockEdit, False);
  Frg1.Opt.SetColFeature('price_check', 'e', User.Roles([], [rOr_Other_R_MinRemains_ChPriceCheck]) and not FLockEdit, False);
  Frg1.Opt.SetColFeature('id_category', 'e', User.Roles([], [rOr_Other_R_MinRemains_Ch]), False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtGo, null, not FLockEdit);
  Frg1.DBGridEh1.Repaint;
end;

procedure TFrmOGedtSnMain.EditSettings;
var
  i, j: Integer;
  va1, va2: TVarDynArray;
  b: Boolean;
begin
  va1 := copy(FDays);
  for i := 0 to High(va1) do
    if va1[i] < 0 then
      va1[i] := 0;
  repeat
    if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '', 180, 80,
      [[cntNEdit, '������', '1:10000', 80], [cntNEdit, '������ 1', '0:10000', 80], [cntNEdit, '������ 2', '0:10000', 80], [cntNEdit, '������ 3', '0:10000', 80],
       [cntNEdit, '������ 4', '0:10000', 80], [cntNEdit, '������ 5', '0:10000', 80], [cntNEdit, '������ 6', '0:10000', 80]],
       va1, va2,
       [['������� ������ ������ � ������� ��������� �������/������� (� ����). ���� ��������� 0, �� ������ ������ ������������ �� �����.']], nil
    ) < 0 then Exit;
    b := True;
    for i := 1 to High(va2) do
      if va2[i] > 0 then
        b := False;
    if not b then
      Break;
    va1 := Copy(va2);
    MyWarningMessage('������ ���� ����� ���� �� ���� ������!');
  until False;
  va1 := Copy(va2, 1);
  for i := 0 to High(va1) do
    if va1[i] = 0 then
      va1[i] := 100000;
  a.VarDynArraySort(va1, True);
  for i := 0 to High(va1) do
    if va1[i] = 100000 then
      va1[i] := -100;
  FDays := [va2[0]] + va1;
  Q.QExecSql('update spl_minremains_params set d0=:d0$i,d1=:d1$i,d2=:d2$i,d3=:d3$i,d4=:d4$i,d5=:d5$i,d6=:d6$i', [va2[0]] + va1);
//  SetCaptions;
//  Gh.SetGridColumnsProperty(DBGridEh1, cptCaption, Pr[1].Fields, Pr[1].Captions);
  Frg1.RefreshGrid;
end;

procedure TFrmOGedtSnMain.SetCategory;
//����� � ��������� ��������� ��� ���� ���������� ���������� �������
//��������� ���������� �� ������ ����� (� ����� ����� ���� ������)
//����� �������� ��� ������� ������ �� �������, ��������� ������� �������� �����, ��� ������
var
  va2: TVarDynArray2;
  va, vak, vav: TVarDynArray;
  i, j: Integer;
  fcat: Integer;
  cat, catn: Variant;
  catname: string;
begin
(*
//  if not FIsSnab then Exit; //���� �������� ������������ ����, ����� ���������!!!
  //������� ������ ���������� �������
  va2:= Gh.GetGridArrayOfChecked(DbGridEh1, -1);
  //������� � ������, ���� ��� ����������
  if (Length(va2) = 0) then begin
    MyInfoMessage('�������� ������, ��� ������� �� ������ ���������� ���������.');
    Exit;
  end;
  fcat:=MemTableEh1.FieldByName('id_category').Index;
  //������� ������������ � ������ ����� ��������� ��� �������
  vak:=['']; vav:=[''];
  for i:=0 to High(FCategoryesSelf) do begin
    vak:= vak + [FCategoryesSelf[i][1]];
    vav:= vav + [FCategoryesSelf[i][0]];
  end;
  //������
  if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '���������� ���������', 300, 80,
//  if Dlg_BasicInput.ShowDialog(Self, '���������� ���������', 300, 80, fEdit,
    [[cntComboLK, '���������', '0:200:0:n', 210]],
    [VarArrayOf([vak[0], VarArrayOf(vav), VarArrayOf(vak)])],
    va,
    [['���������� ��� �������� ��������� �� ��������� ��������. ������ ���� ��������� ����� ���� �������� ��� �������.']],
    nil
  ) < 0 then Exit; //������, ���� ������
  //������� �������� � ���� ��������� ���������
  cat:=va[0];
  catname:=''; if cat <> '' then begin
    i:= A.PosInArray(cat, FCategoryes, 1);
    if i >=0 then catname:= FCategoryes[i, 0];
  end;
  if (Length(va2) = 0)or(MyQuestionMessage('���������� ��� ' + S.GetEndingFull(Length(va2), '�����������', '�', '�', '�') + ' ��������� "' + catname + '"?') <> mrYes)
    then Exit;
  //������� ���������
  for i:=0 to High(va2) do begin
    //������ ���� ��������� ������ ��� ����, � �� ����� ��
    va:=Q.QSelectOneRow('select id, id_category from spl_itm_nom_props where id = :id$i', [va2[i][0]]);
    if (va[0] <> null)and(VarToStr(va[1]) <> VarToStr(cat))and((va[1] = null)or(A.PosInArray(va[1], FCategoryesSelf, 1) >= 0))
      then Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([va2[i, 0], 6, S.NullIfEmpty(cat)]));
  end;
  //������ �������
  Gh.SetGridIndicatorSelection(DbGridEh1, -1);
  //�������
  Refresh;
  MyInfoMessage('������!');
  *)
end;

function TFrmOGedtSnMain.ExportGridToXLSX(Open: Boolean = False; OnlyNot0: Boolean = False): Boolean;
//������������� �������� ������� � ������
//���������, �.�. ����������� �������� EhLib ��������� �����������
//(���������, �� ��� �������� � ������ ������� �������� ���������� � �����-�� ������ � ���� ������������, ������ ��� �����, � ���������� �� ����������������� � ������ ����������� ������)
//�������� �� �������, ��������� ��������� � �������, ���� ��������� �� ������������ ����� ��������
var
  Rep: TA7Rep;
  Range: Variant;
  i, j, k, x, y: Integer;
  v: Variant;
  FileName: string;
  b: Boolean;
  va: TVarDynArray;
  st, st1: string;
  RecNo: Integer;
begin
  Result := False;
  //������� ������
  FileName := Module.GetReportFileXlsx('������������ ������ ��');
  if FileName = '' then
    Exit;
  Rep := TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName, False, True);
  except
    Rep.Free;
    Exit;
  end;
  //���������
  Rep.PasteBand('HEADER');
  //��������� ����� � ��������� ��������� - ������������ ����� � ����� ��������
  Rep.ExcelFind('#' + 'caption' + '#', x, y, xlValues);
  if x > -1 then
    Rep.SetValue('#' + Self.Caption + '  [' + DateTimeToStr(Now) + ']' + '#', st1);
  //Rep.PasteBand('EMPTY');
  //��������� ���� �������

  //�� ��������� �������� ��� ������� �� ������� - � ��� � ������� ����� ����������� ����� ����� ������� �����, ����� �� ������������
  //MemTableEh1.DisableControls;
  RecNo := Frg1.MemTableEh1.RecNo;
  //� ������� ����� ������������� ����� �������, ����� ������� #pos#
  for i := 1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    Rep.PasteBand('TABLE');
    Rep.SetValue('#pos#', IntToStr(i));
    //������ �� ����� ��������
    for j := 0 to Frg1.MemTableEh1.Fields.count - 1 do begin
      //��� ������� - �������� ����� � ����
      st := Frg1.MemTableEh1.Fields[j].FieldName;
      st1 := S.NSt(Frg1.MemTableEh1.Fields[j].AsString);
      //������ ����� � �������, ��������������� ����� ����, � ���� �� ��� - ��������� ��������
      Rep.ExcelFind('#' + st + '#', x, y, xlValues);
      if x = -1 then  Continue;
      //�������� ����
      Rep.SetValue('#' + st + '#', st1);
      //��������� ���� ���� �� ����������� � ������� �����, ���� �� �� ���� ������ ������ (�� ������-�� ����������� ������)
      if not VarIsEmpty(FRowColors[Frg1.DBGridEh1.FindFieldColumn(st).Index])
        then if FRowColors[Frg1.DBGridEh1.FindFieldColumn(st).Index] <> Frg1.DBGridEh1.EvenRowColor
          then Rep.TemplateSheet.Cells[y, x].Interior.Color := FRowColors[Frg1.DBGridEh1.FindFieldColumn(st).Index];
      //� ��������� ���� ������ - ���� ����������� ���������� �����
      if not VarIsEmpty(FRowFontColors[Frg1.DBGridEh1.FindFieldColumn(st).Index])
        then Rep.TemplateSheet.Cells[y, x].Font.Color := FRowFontColors[Frg1.DBGridEh1.FindFieldColumn(st).Index];
    end;
  end;
  //�������� � �������� ������ �������
  Frg1.MemTableEh1.RecNo := RecNo;
  Frg1.MemTableEh1.EnableControls;
  //����� �������
  Rep.PasteBand('FOOTER');
  //�������� �������. ���� ��� ������� � �������, �� �� �����-�� ������� ������������ ��������� ������ ������,
  //���� � ������� ��� ��������, � ����� ������������ ������ ������ ������� (���� EMPTY), ����� �� ������������ ��� �������.
  // ������� ����������� �������, ���� ��� ���� ������
  Rep.Excel.ActiveWindow.FreezePanes:=False;
  // �������� ������ ������, ����� ������� ������� ����� �����������, ������ ��� ��� � ������ � �������
  Rep.Excel.Range['A3'].Select;
  // ������������� ����������� �������
  Rep.Excel.ActiveWindow.FreezePanes:=True;
  //��������� ����������. ���� �� ��� � �������, �� �� ���������� ��� �������� �����, ������� � ����
  //������ ��������� ������ �, ������ ��� � ���� ������ ������ � ������ ������ ����������, � � ���� ������ ��� �������� A2 ������ ��� ����� �������� � ������ ������
  //���������� ���� �������� �� �������� � ����� �� �����, � ������ � ����� ������� - ��, � ������� ������ ���� ���������� ������ (� �������)
  Rep.Excel.Range['A2', 'Z2'].AutoFilter;
  Rep.DeleteCol1;
  if Open then begin
    Rep.Show;
    Rep.Free;
    Result := True;
  end
  else begin
    try
      //������������ ������ .Save, � �� .SaveAs !
      ForceDirectories(Module.GetPath_Demand_Created);
      Rep.Save(Module.GetPath_Demand_Created +'\' + FormatDateTime('yyyy-mm-dd_hh.nn.ss', Now) + '__(' + User.GetName + ')' + '.xlsx');
      Result := True;
    except
    end;
  end;
end;

procedure TFrmOGedtSnMain.RecalcPlannedEst;
//����������� �������� ���������� (�� ������ �������� ������� �� ��� ������ ������, ������� �������)
begin
  if MyQuestionMessage('�������� ����������� ���������� �� ' + DateTimeToStr(FPlannedDt) + #13#10'��������?') <> mrYes then
    Exit;
  Orders.CrealeEstimateOnPlannesOrders(Now, True);
  FPlannedDt:=Q.QLoadToVarDynArrayOneRow('select planned_dt from spl_minremains_params', [])[0];
  Frg1.RefreshGrid;
end;

procedure TFrmOGedtSnMain.InfoOnTheQntInProccessing;
//���������� �� ������������ � ���������
begin
  MyInfoMessage(
    '������������ �� �������� "� ���������"'#13#10#13#10+
    '����������, �� ������� ������� ������ �� ���������, �� ������� ����������� �� ��������� � �� ������� ������ "� ����"'#13#10+
    ''#13#10+
    '��������� �� �������: ' + VarToStr(Q.QselectOneRow('select qnt from v_spl_nom_on_demand where id_nomencl = :id$i', [Frg1.ID])[0]) + #13#10+
    '�������� �� ���������: ' + VarToStr(Q.QselectOneRow('select qnt from v_spl_nom_on_inbill where id_nomencl = :id$i', [Frg1.ID])[0]) + #13#10+
    '� ����: ' + VarToStr(Q.QselectOneRow('select qnt from v_spl_nom_onway_agg where id_nomencl = :id$i', [Frg1.ID])[0]) + #13#10 +
    ''#13#10+
    '�����: ' + S.NSt(Frg1.GetValue('qnt_in_processing'))
  );
end;

procedure TFrmOGedtSnMain.SetLock;
//������� ���������� �� �������������� ������� �� ��������� ���������
//���� �����, �� �������� �������������� ������ � �������� ������, ����� �������� (����� ������� ���������)
var
  va, va1: TVarDynArray;
  i, j: Integer;
  st, st1: string;
  v: Variant;
begin
  //������, ���� ��� ���� �� ��������������, ����� � ���� �� ��������� ��������� (���� ��������� ������, �.�. ��������� �� �������)
  if not (User.Roles([], [rOr_Other_R_MinRemains_Ch]) and (S.NSt(Frg1.GetControlValue('CbCategory')) <> ''))
    then Exit;
  //������� ���������� �� ������� ��������� ���������
  va1:=Q.DBLock(False, FormDoc, VarToStr(FIdCategoryLock), '', fNone);
  //���������� ����� ����������
  va1:=Q.DBLock(True, FormDoc, VarToStr(Frg1.GetControlValue('CbCategory')), '', fNone);
  //�������� ��������� ������� �������
  FIdCategoryLock:= Frg1.GetControlValue('CbCategory');
  //�������, ��� �������������� �������������
  FLockEdit:= not va1[0];
  if FLockEdit then begin
    //���� �������������, �� ������� ���������
    MyWarningMessage('������������ "' + S.NSt(va1[1]) + '" ������ ����������� ������� �� ������ ���������.'#13#10'�� �� ������ ������������� ������ � ����������� ������!');
  end;
  //������� ������ ������������� ����� (� ������ ���������, ������ � ��� ������� "_", � ����� - ����������� ��� ����
  SetFieldsEditable;
end;

procedure TFrmOGedtSnMain.tmrAfterCreateTimer(Sender: TObject);
begin
  inherited;
  SetLock;
end;

procedure TFrmOGedtSnMain.ViewXLSFiles;
//�������� ����������� xls-������ �� �������� ������ �����, ������� ����������� ��� �������� ������ �������������
//����� ��������� � ������� �� �����/�������, � ������� ������.
//��������� ������� ���� �� ������� ������, � ��������� ��������� ����
var
  sa: TStringDynArray;
  va1, va2: TVarDynArray;
  i: Integer;
begin
  sa := TDirectory.GetFiles(Module.GetPath_Demand_Created, '*.*', TSearchOption.soTopDirectoryOnly);
  for i:=0 to High(sa) do
    sa[i]:=ExtractFileName(sa[i]);
  va1:= A.StringDynArrayToVarDynArray(sa);
  A.VarDynArraySort(va1, False);
      if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '', 600, 50,
        [[cntComboL, '����:', '1:4000', 540]],
        [VarArrayOf(['', VarArrayOf(va1)])],
        va2,
        [['����������� ������ � ������� Excel �� ������ �������� ������.'#13#10]],
         nil
      ) <= 0 then Exit;
  Sys.ExecFileIfExists(Module.GetPath_Demand_Created + '\' + VarToStr(va2[0]), '���� �� ������!');
end;


function TFrmOGedtSnMain.CreateDemand: Boolean;
//�������� ������ �� ���������
//������ ��������� ������ �� ��������, ��� ������� ��������� ������������� �������
//����� ��������� �������� ���������� ���� ������� (�� ������ ��������) � ������ � ����������� ��������
//� ������ ���������� ������ ������� �� ������� ���������, ��� ������� ������ � �� ������� ���������� � ������ � ����� ����� � �����
var
  i, j, ToDemand: Integer;
  idd, res: Integer;
  gf: TVarDynArray2;
  id_category: Integer;
  va2: TVarDynArray2;
  st: string;
begin
  //������� ���� ���������
  id_category:= Frg1.GetControlValue('CbCategory');
  //����������, ������� ������� � ������
  ToDemand := Q.QSelectOneRow('select count(*) from spl_itm_nom_props where nvl(qnt_order, 0) > 0 and to_order = 1 and id_category = :id_category$i', [id_category])[0];
  //���� ������ ���, �� ������
  if ToDemand = 0 then begin
    MyInfoMessage('��� �� ����� ������� � ������!');
    Result := False;
    Exit;
  end;
  va2 := Q.QLoadToVarDynArray2(
    'select v.name, v.need from v_spl_minremains v, spl_itm_nom_props p where v.id = p.id and nvl(v.need, 0) < 0 and p.to_order <> 1 and p.id_category = :id_category$i',
    [id_category]
  );
  if Length(va2) > 0 then begin
    st := '�� �������� � ������ ��������� (' + IntToStr(Length(va2)) + ') ������� � ������������:'#13#10;
    for i := 0 to High(va2) do
      S.ConcatStP(st, va2[i][0] + '  [' + VarToStr(va2[i][1]) + ']', #13#10);
    st := st + #13#10#13#10'���������� ������������ ������?';
    if MyQuestionMessage(st, 1) <> mrYes then
      Exit;
  end;
  //�����������
  if MyQuestionMessage(
    '������� ������ �� ��������� �� ' + S.GetEndingFull(ToDemand, '������', '�', '�', '�') + ' �� ��������� "' +
    A.FindValueInArray2(id_category, 1, 0, FCategoryes) + '"?'
    ) <> mrYes then  Exit;
  //�������, ��������� �� � ������
  if MyQuestionMessage('��������� ������� ��������� ������ � Excel-�����?') = mrYes then begin
    //�������� � ������� ������ � �������� � ������
    gf := Gh.GridFilterSave(Frg1.DbGridEh1);
    Gh.GridFilterClear(Frg1.DbGridEh1);
    //������� � ������ (� ����������� ���� �����, �� �� �������), �������� ��������� � ������� � Data, ��� �������������
    ExportGridToXLSX(False);
    //����������� ������
    Gh.GridFilterRestore(Frg1.DbGridEh1, gf);
  end;
  //������� ��������� ������������ ������ ���������� �� ���������� ���������
  Q.QBeginTrans(True);
  Q.QCallStoredProc('p_Spl_Create_History', 'st$s', ['�����']);
  Q.QCallStoredProc('p_CreateSplDemand', 'IdCategory$i', [id_category]);
  Q.QCommitOrRollback();
  //���� ����������� ��������, ������� � ������
  if Q.PackageMode <> 1 then begin
    MyWarningMessage('������ �������� ������!');
    Exit;
  end;
  //����� - ������� � ������� ����
  Frg1.RefreshGrid;
  MyInfoMessage('������ �������.');
end;

procedure TFrmOGedtSnMain.FillFromPlanned;
//������������� ���� "������ (����)" � "����������� �������" ������� �������� ����������� �� ��������� �����
var
  va, van, vaid: TVarDynArray;
  va2: TVarDynArray2;
  i: Integer;
begin
  //������ ������ ������
  van := [MonthsRu[MonthOf(FPlannedDt)], MonthsRu[MonthOf(IncMonth(FPlannedDt, 1))], MonthsRu[MonthOf(IncMonth(FPlannedDt, 2))]];
  vaid := [1,2,3];
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~����� �������', 160, 45,
    [[cntComboLK, '�����:','1:50', 1]],
    [VarArrayOf(['', VarArrayOf(van), VarArrayOf(vaid)])],
    va,
    [],
    nil
  ) < 0 then
    Exit;
  //�������
  if MyQuestionMessage(
    '������ � ����������� ������� ����� ��������� ������ �� �������� �������� ����������� �� ' + van[S.NInt(va[0]) - 1] + #13#10'����������?'
  ) <> mrYes then
    Exit;
  //������� �������� (�� ������� ���������!) �������� ����������� �� ���� �����
  va2 := Q.QLoadToVarDynArray2('select id_nomencl, qnt' + va[0] + ' from planned_order_estimate3 where id_nomencl is not null and qnt' + va[0] + ' is not null', []);
  //������� ��� ����������� ������� � ��������� ������� �������� (��������� �� �������)
  Q.QBeginTrans(True);
  for i := 0 to High(va2) do begin
    Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([va2[i][0], 2, S.NullIfEmpty(RoundTo(va2[i][1], -1))]));     //min_ostatok
    Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([va2[i][0], 3, S.NullIfEmpty(RoundTo(va2[i][1], -1))]));     //qnt_order_opt
  end;
  Q.QCommitOrRollback(True);
  //������� ����
  Frg1.RefreshGrid;
  MyInfoMessage('������!');
end;

procedure TFrmOGedtSnMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //������� ���������� �� ������� ��������� ���������
  Q.DBLock(False, FormDoc, VarToStr(FIdCategoryLock), '', fNone);
  inherited;
end;

procedure TFrmOGedtSnMain.SetDetailInfo;
var
  i, j: Integer;
  f: string;
begin
  if Frg1.IsEmpty then
    Exit;
  if Frg1.MemTableEh1.ControlsDisabled then
    Exit;
  if not Frg1.MemTableEh1.Active or (Frg1.GetCount < 1) then
    lblName.SetCaption2('')
  else
    lblName.SetCaption2('������������: $FF0000 ' + Frg1.GetValueS('name'));
  Frg3.MemTableEh1.Edit;
  for i := 0 to Frg3.MemTableEh1.Fields.Count - 1 do begin
    f := Frg3.MemTableEh1.Fields[i].FieldName;
    Frg3.MemTableEh1.Fields[i].Value := null;
//    if not MemTableEh1.Active or (MemTableEh1.RecordCount < 1) then Continue;
    if Frg1.DbGridEh1.FindFieldColumn(f) = nil then
      Continue;
    Frg3.MemTableEh1.Fields[i].Value := Frg1.MemTableEh1.FieldByName(f).Value;
    if (Length(FRowColors) > 0) and (not VarIsEmpty(FRowColors[Frg1.DBGridEh1.FindFieldColumn(f).Index])) then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := FRowColors[Frg1.DBGridEh1.FindFieldColumn(f).Index];
    if TRegEx.IsMatch(f, 'price_main') then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := RGB(150, 150, 255);
    if TRegEx.IsMatch(f, '_cost$') then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := RGB(150, 150, 255);
    if TRegEx.IsMatch(f, '^qnt[0-9]{1}$') then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := RGB(255, 255, 150);
    if TRegEx.IsMatch(f, '^qnti[0-9]{1}$') then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := RGB(150, 255, 150);
  end;
end;

procedure TFrmOGedtSnMain.ClearInvalidReserve;
var
  va: TVarDynArray;
  i: Integer;
begin
  i := Q.QSelectOneRow('select count(*) from v_reservpos_completed_orders2', [])[0];
  if i = 0 then begin
    MyInfoMessage('��� ��������� ��������.');
    Exit;
  end;
  va := Q.QLoadToVarDynArrayOneCol('select info from v_reservpos_completed_orders2', []);
  if MyQuestionMessage('� ������� ������� ��������� (' + IntToStr(i) + ') ������� �� �������� � ����� �������:'#13#10+
    '(������� "��" ����� �������� �������)'#13#10 + A.Implode(va, #13#10), 1) <> mrYes then
    Exit;
  Q.QBeginTrans(True);
  Q.QCallStoredProc('p_Itm_DelRezervForCompleted', '', []);
  Q.QCommitOrRollback(True);
  Frg1.RefreshGrid;
end;







end.
