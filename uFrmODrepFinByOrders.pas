unit uFrmODrepFinByOrders;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, DBCtrlsEh, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Mask, Vcl.ComCtrls, Vcl.ExtCtrls, uLabelColors, Math
  ;

type
  TFrmODrepFinByOrders = class(TFrmBasicMdi)
    Pgc_1: TPageControl;
    Ts_1: TTabSheet;
    P_1_Top: TPanel;
    Gb_1_1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Ne_1_RA: TDBNumberEditEh;
    Ne_1_RD: TDBNumberEditEh;
    Ne_1_RM: TDBNumberEditEh;
    Ne_1_R: TDBNumberEditEh;
    Ne_1_RI2: TDBNumberEditEh;
    Ne_1_RI3: TDBNumberEditEh;
    Ne_1_RA2: TDBNumberEditEh;
    Ne_1_RA3: TDBNumberEditEh;
    Ne_1_RD2: TDBNumberEditEh;
    Ne_1_RM2: TDBNumberEditEh;
    Ne_1_R2: TDBNumberEditEh;
    Ne_1_RD3: TDBNumberEditEh;
    Ne_1_RM3: TDBNumberEditEh;
    Ne_1_R3: TDBNumberEditEh;
    Ne_1_RI: TDBNumberEditEh;
    Gb_1_2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Ne_1_OA: TDBNumberEditEh;
    Ne_1_OD: TDBNumberEditEh;
    Ne_1_OM: TDBNumberEditEh;
    Ne_1_O: TDBNumberEditEh;
    Ne_1_OI2: TDBNumberEditEh;
    Ne_1_OI3: TDBNumberEditEh;
    Ne_1_OA2: TDBNumberEditEh;
    Ne_1_OA3: TDBNumberEditEh;
    Ne_1_OD2: TDBNumberEditEh;
    Ne_1_OM2: TDBNumberEditEh;
    Ne_1_O2: TDBNumberEditEh;
    Ne_1_OD3: TDBNumberEditEh;
    Ne_1_OM3: TDBNumberEditEh;
    Ne_1_O3: TDBNumberEditEh;
    Ne_1_OI: TDBNumberEditEh;
    Gb_1_3: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Ne_1_I: TDBNumberEditEh;
    Ne_1_I2: TDBNumberEditEh;
    Ne_1_I3: TDBNumberEditEh;
    Ts_2: TTabSheet;
    P_2_Top: TPanel;
    Gb_2_2: TGroupBox;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Ne_2_OA: TDBNumberEditEh;
    Ne_2_OD: TDBNumberEditEh;
    Ne_2_OM: TDBNumberEditEh;
    Ne_2_O: TDBNumberEditEh;
    Ne_2_OI2: TDBNumberEditEh;
    Ne_2_OI3: TDBNumberEditEh;
    Ne_2_OA2: TDBNumberEditEh;
    Ne_2_OA3: TDBNumberEditEh;
    Ne_2_OD2: TDBNumberEditEh;
    Ne_2_OM2: TDBNumberEditEh;
    Ne_2_O2: TDBNumberEditEh;
    Ne_2_OD3: TDBNumberEditEh;
    Ne_2_OM3: TDBNumberEditEh;
    Ne_2_O3: TDBNumberEditEh;
    Ne_2_OI: TDBNumberEditEh;
    Gb_2_3: TGroupBox;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Ne_2_I: TDBNumberEditEh;
    Ne_2_I2: TDBNumberEditEh;
    Ne_2_I3: TDBNumberEditEh;
    GroupBox1: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Ne_2_RA: TDBNumberEditEh;
    Ne_2_RD: TDBNumberEditEh;
    Ne_2_RM: TDBNumberEditEh;
    Ne_2_R: TDBNumberEditEh;
    Ne_2_RI2: TDBNumberEditEh;
    Ne_2_RI3: TDBNumberEditEh;
    Ne_2_RA2: TDBNumberEditEh;
    Ne_2_RA3: TDBNumberEditEh;
    Ne_2_RD2: TDBNumberEditEh;
    Ne_2_RM2: TDBNumberEditEh;
    Ne_2_R2: TDBNumberEditEh;
    Ne_2_RD3: TDBNumberEditEh;
    Ne_2_RM3: TDBNumberEditEh;
    Ne_2_R3: TDBNumberEditEh;
    Ne_2_RI: TDBNumberEditEh;
    Ts_4: TTabSheet;
    Panel1: TPanel;
    GroupBox5: TGroupBox;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Ne_4_RA: TDBNumberEditEh;
    Ne_4_RD: TDBNumberEditEh;
    Ne_4_RM: TDBNumberEditEh;
    Ne_4_R: TDBNumberEditEh;
    Ne_4_RI2: TDBNumberEditEh;
    Ne_4_RI3: TDBNumberEditEh;
    Ne_4_RA2: TDBNumberEditEh;
    Ne_4_RA3: TDBNumberEditEh;
    Ne_4_RD2: TDBNumberEditEh;
    Ne_4_RM2: TDBNumberEditEh;
    Ne_4_R2: TDBNumberEditEh;
    Ne_4_RD3: TDBNumberEditEh;
    Ne_4_RM3: TDBNumberEditEh;
    Ne_4_R3: TDBNumberEditEh;
    Ne_4_RI: TDBNumberEditEh;
    GroupBox6: TGroupBox;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Ne_4_OA: TDBNumberEditEh;
    Ne_4_OD: TDBNumberEditEh;
    Ne_4_OM: TDBNumberEditEh;
    Ne_4_O: TDBNumberEditEh;
    Ne_4_OI2: TDBNumberEditEh;
    Ne_4_OI3: TDBNumberEditEh;
    Ne_4_OA2: TDBNumberEditEh;
    Ne_4_OA3: TDBNumberEditEh;
    Ne_4_OD2: TDBNumberEditEh;
    Ne_4_OM2: TDBNumberEditEh;
    Ne_4_O2: TDBNumberEditEh;
    Ne_4_OD3: TDBNumberEditEh;
    Ne_4_OM3: TDBNumberEditEh;
    Ne_4_O3: TDBNumberEditEh;
    Ne_4_OI: TDBNumberEditEh;
    GroupBox7: TGroupBox;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Ne_4_I: TDBNumberEditEh;
    Ne_4_I2: TDBNumberEditEh;
    Ne_4_I3: TDBNumberEditEh;
    Ts_3: TTabSheet;
    P_3_Top: TPanel;
    GroupBox2: TGroupBox;
    Ne_3_I: TDBNumberEditEh;
    Ne_3_IOk: TDBNumberEditEh;
    Ne_3_IPrc: TDBNumberEditEh;
    Ne_3_IPrcOk: TDBNumberEditEh;
    Ne_3_IPlan: TDBNumberEditEh;
    GroupBox3: TGroupBox;
    Ne_3_A: TDBNumberEditEh;
    Ne_3_AOk: TDBNumberEditEh;
    Ne_3_APrc: TDBNumberEditEh;
    Ne_3_APrcOk: TDBNumberEditEh;
    Ne_3_APlan: TDBNumberEditEh;
    GroupBox4: TGroupBox;
    Ne_3: TDBNumberEditEh;
    Ne_3_Prc: TDBNumberEditEh;
    Ne_3_Plan: TDBNumberEditEh;
    DBNumberEditEh7: TDBNumberEditEh;
    DBNumberEditEh9: TDBNumberEditEh;
    Cb_DtB: TDBComboBoxEh;
    Cb_DtE: TDBComboBoxEh;
    Ts_5: TTabSheet;
    Ne5Selling: TDBNumberEditEh;
    Panel2: TPanel;
    LbCaption: TLabel;
    GroupBox8: TGroupBox;
    Ne_5_1: TDBNumberEditEh;
    Ne_5_2: TDBNumberEditEh;
    Ne_5_3: TDBNumberEditEh;
    Ne_5_6: TDBNumberEditEh;
    Ne_5_4: TDBNumberEditEh;
    Ne_5_5: TDBNumberEditEh;
    Ne_5_7: TDBNumberEditEh;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    DtB, DtE: TDateTime;
    function  Prepare: Boolean; override;
    procedure BtClick(Sender: TObject); override;
    procedure ClearReport;
    procedure CalculateReport;
    procedure SetReportCaption;
    function  GetDateFromComboBox(st: string; LastDay: Boolean = False): TDateTime;
  end;

var
  FrmODrepFinByOrders: TFrmODrepFinByOrders;

implementation

{$R *.dfm}

uses
  DateUtils,
  uSettings,
  uForms,
  uDBOra,
  uString,
  uData,
  uMessages,
  D_R_Order_Plans
  ;

function TFrmODrepFinByOrders.GetDateFromComboBox(st: string; LastDay: Boolean = False): TDateTime;
//������� ���� �� �� ��������� ������ ���� 2024, ����
//���� LastDay �� ��������� ������ ������, ����� ������ ������
//���� ������ ������� ����, �� ������ ������� ����
var
  i:Integer;
begin
  Result:=EncodeDate(2000,1,1);
  try
    i:=1;
    while Copy(st,7) <> MonthsRu[i] do inc(i);
    Result:=EncodeDate(StrToInt(Copy(st,1,4)), i, 1);
    if LastDay then
      Result:=IncDay(IncMonth(Result, 1), -1);
    if Result > Date then
      Result:= Date;
  except
    Exit;
  end;
end;


procedure TFrmODrepFinByOrders.ClearReport;
var
  i:Integer;
  c: TComponent;
begin
  for i:=0 to ComponentCount - 1 do
    if TControl(Components[i]) is TDBNumberEditEh
      then TCustomDBEditEh(Components[i]).Value:=null;
end;

procedure TFrmODrepFinByOrders.FormActivate(Sender: TObject);
//������� ������� �� ��������� � �������� � �� ���������, � ������ ��������� ���� ��������� � ������ � ����� �������
var
  i,j :Integer;
  st: string;
begin
  inherited;
  DtB := EncodeDate(2000, 1, 1);
  ClearReport;
  SetReportCaption;
  for i := 2024 to YearOf(Date) do
    for j := 1 to S.IIf(i = YearOf(Date), MonthOf(Date), 12) do begin
      Cb_DtB.Items.Insert(0, IntToStr(i) + ', ' + MonthsRu[j]);
      Cb_DtE.Items.Insert(0, IntToStr(i) + ', ' + MonthsRu[j]);
    end;
  if Cb_DtB.ItemIndex = -1 then
    Cb_DtB.ItemIndex := 0;
  if Cb_DtE.ItemIndex = -1 then
    Cb_DtE.ItemIndex := 0;
  Ts_1.TabVisible := User.Role(rOr_Rep_Order_Fin1);         //�������
  Ts_2.TabVisible := User.Role(rOr_Rep_Order_Fin5);         //��������
  Ts_3.TabVisible := User.Role(rOr_Rep_Order_Fin3);         //������������
  Ts_4.TabVisible := User.Role(rOr_Rep_Order_Fin2);         //����������
  Ts_5.TabVisible := User.Role(rOr_Rep_Order_Fin3);         //������������
end;

procedure TFrmODrepFinByOrders.FormCreate(Sender: TObject);
begin
  inherited;
  Pgc_1.TabIndex:=0;
end;

procedure TFrmODrepFinByOrders.SetReportCaption;
var
  Labels:array[0..3] of TLabel;
  i:Integer;
begin
  if YearOf(DtB) = 2000
    then LbCaption.SetCaptionAr2(['$0000FF', '����� �� �����������!'])
    else LbCaption.SetCaptionAr2(['$000000', '����� �� ������ � ', '$FF0000', DateToStr(DtB) , '$000000' , ' �� ', '$FF0000', DateToStr(DtE)]);
end;

procedure TFrmODrepFinByOrders.CalculateReport;
var
  i,j: Integer;
  va1,va2: TVarDynArray2;
  e1: Extended;
procedure CorrectNullData;
var
  i: Integer;
begin
  if Length(va1) = 0 then va1:=[[0,0,0,0,0,0,0]];
  if Length(va2) = 0 then va2:=[[1,1,1,1,1,1,1]];
  for i:=0 to High(va1[0]) do
    if va1[0][i] = null
      then va1[0][i] := 0;
  for i:=0 to High(va2[0]) do
    if (va2[0][i] = null)or(va2[0][i] = 0)
      then va2[0][i] := 1;
end;

begin
  ClearReport;
  Q.QSetContextValue('order_finreport_dtbeg', DtB);
  Q.QSetContextValue('order_finreport_dtend', DtE);
  //QSetContextValue('order_finreport_dtbeg', IncDay(Date, -1));
  //QSetContextValue('order_finreport_dtend', IncDay(Date, -1));
  if Ts_1.TabVisible then begin
    //�������, ������� �� ��������� ����
    //�������, �� ��������� � � �
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''�'', ''�'') and dt_beg >= :dtb$d and dt_beg <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum1ri)), round(sum(sum1ra)), round(sum(sum1rd)), round(sum(sum1rm)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
//    if Length(va2) = 0 then va2:=[[1,1,1,1]];
    CorrectNullData;
    Ne_1_RI.Value:=va1[0][0]; Ne_1_RA.Value:=va1[0][1];Ne_1_RD.Value:=va1[0][2];Ne_1_RM.Value:=va1[0][3];
    Ne_1_RI3.Value:=va2[0][0]; Ne_1_RA3.Value:=va2[0][1];Ne_1_RD3.Value:=va2[0][2];Ne_1_RM3.Value:=va2[0][3];
    Ne_1_R.Value:=0;
    for i:=0 to 3 do Ne_1_R.Value:= Ne_1_R.Value + va1[0][i];
    Ne_1_R3.Value:=0;
    for i:=0 to 3 do Ne_1_R3.Value:= Ne_1_R3.Value + va2[0][i];
    Ne_1_RI2.Value:=RoundTo(Ne_1_RI.Value / Ne_1_RI3.Value * 100, -2);
    Ne_1_RA2.Value:=RoundTo(Ne_1_RA.Value / Ne_1_RA3.Value * 100, -2);
    Ne_1_RD2.Value:=RoundTo(Ne_1_RD.Value / Ne_1_RD3.Value * 100, -2);
    Ne_1_RM2.Value:=RoundTo(Ne_1_RM.Value / Ne_1_RM3.Value * 100, -2);
    Ne_1_R2.Value:=RoundTo(Ne_1_R.Value / Ne_1_R3.Value * 100, -2);

    //���, �� ��������� � � �
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''�'', ''�'') and dt_beg >= :dtb$d and dt_beg <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum1oi)), round(sum(sum1oa)), round(sum(sum1od)), round(sum(sum1om)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
//    if Length(va2) = 0 then va2:=[[1,1,1,1]];
    Ne_1_OI.Value:=va1[0][0]; Ne_1_OA.Value:=va1[0][1];Ne_1_OD.Value:=va1[0][2];Ne_1_OM.Value:=va1[0][3];
    Ne_1_OI3.Value:=va2[0][0]; Ne_1_OA3.Value:=va2[0][1];Ne_1_OD3.Value:=va2[0][2];Ne_1_OM3.Value:=va2[0][3];
    Ne_1_O.Value:=0;
    for i:=0 to 3 do Ne_1_O.Value:= Ne_1_O.Value + va1[0][i];
    Ne_1_O3.Value:=0;
    for i:=0 to 3 do Ne_1_O3.Value:= Ne_1_O3.Value + va2[0][i];
    Ne_1_OI2.Value:=RoundTo(Ne_1_OI.Value / Ne_1_OI3.Value * 100, -2);
    Ne_1_OA2.Value:=RoundTo(Ne_1_OA.Value / Ne_1_OA3.Value * 100, -2);
    Ne_1_OD2.Value:=RoundTo(Ne_1_OD.Value / Ne_1_OD3.Value * 100, -2);
    Ne_1_OM2.Value:=RoundTo(Ne_1_OM.Value / Ne_1_OM3.Value * 100, -2);
    Ne_1_O2.Value:=RoundTo(Ne_1_O.Value / Ne_1_O3.Value * 100, -2);

    //�����
    Ne_1_I.Value:= Ne_1_R.Value + Ne_1_O.Value;
    Ne_1_I3.Value:= Ne_1_R3.Value + Ne_1_O3.Value;
    Ne_1_I2.Value:=RoundTo(Ne_1_I.Value / Ne_1_I3.Value * 100, -2);
  end;

  if Ts_2.TabVisible then begin
    //��������, ������� �� ���� �������� � ���
    //�������, �� ��������� � � �
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''�'', ''�'') and dt_from_sgp >= :dtb$d and dt_from_sgp <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum2ri)), round(sum(sum2ra)), round(sum(sum2rd)), round(sum(sum2rm)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
//    if Length(va2) = 0 then va2:=[[1,1,1,1]];
    CorrectNullData;
    Ne_2_RI.Value:=va1[0][0]; Ne_2_RA.Value:=va1[0][1];Ne_2_RD.Value:=va1[0][2];Ne_2_RM.Value:=va1[0][3];
    Ne_2_RI3.Value:=va2[0][0]; Ne_2_RA3.Value:=va2[0][1];Ne_2_RD3.Value:=va2[0][2];Ne_2_RM3.Value:=va2[0][3];
    Ne_2_R.Value:=0;
    for i:=0 to 3 do Ne_2_R.Value:= Ne_2_R.Value + va1[0][i];
    Ne_2_R3.Value:=0;
    for i:=0 to 3 do Ne_2_R3.Value:= Ne_2_R3.Value + va2[0][i];
    Ne_2_RI2.Value:=RoundTo(Ne_2_RI.Value / Ne_2_RI3.Value * 100, -2);
    Ne_2_RA2.Value:=RoundTo(Ne_2_RA.Value / Ne_2_RA3.Value * 100, -2);
    Ne_2_RD2.Value:=RoundTo(Ne_2_RD.Value / Ne_2_RD3.Value * 100, -2);
    Ne_2_RM2.Value:=RoundTo(Ne_2_RM.Value / Ne_2_RM3.Value * 100, -2);
    Ne_2_R2.Value:=RoundTo(Ne_2_R.Value / Ne_2_R3.Value * 100, -2);

    //���, �� ��������� � � �
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''�'', ''�'') and dt_from_sgp >= :dtb$d and dt_from_sgp <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum2oi)), round(sum(sum2oa)), round(sum(sum2od)), round(sum(sum2om)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
//   if Length(va2) = 0 then va2:=[[1,1,1,1]];
    Ne_2_OI.Value:=va1[0][0]; Ne_2_OA.Value:=va1[0][1];Ne_2_OD.Value:=va1[0][2];Ne_2_OM.Value:=va1[0][3];
    Ne_2_OI3.Value:=va2[0][0]; Ne_2_OA3.Value:=va2[0][1];Ne_2_OD3.Value:=va2[0][2];Ne_2_OM3.Value:=va2[0][3];
    Ne_2_O.Value:=0;
    for i:=0 to 3 do Ne_2_O.Value:= Ne_2_O.Value + va1[0][i];
    Ne_2_O3.Value:=0;
    for i:=0 to 3 do Ne_2_O3.Value:= Ne_2_O3.Value + va2[0][i];
    Ne_2_OI2.Value:=RoundTo(Ne_2_OI.Value / Ne_2_OI3.Value * 100, -2);
    Ne_2_OA2.Value:=RoundTo(Ne_2_OA.Value / Ne_2_OA3.Value * 100, -2);
    Ne_2_OD2.Value:=RoundTo(Ne_2_OD.Value / Ne_2_OD3.Value * 100, -2);
    Ne_2_OM2.Value:=RoundTo(Ne_2_OM.Value / Ne_2_OM3.Value * 100, -2);
    Ne_2_O2.Value:=RoundTo(Ne_2_O.Value / Ne_2_O3.Value * 100, -2);

    //�����
    Ne_2_I.Value:= Ne_2_R.Value + Ne_2_O.Value;
    Ne_2_I3.Value:= Ne_2_R3.Value + Ne_2_O3.Value;
    Ne_2_I2.Value:=RoundTo(Ne_2_I.Value / Ne_2_I3.Value * 100, -2);
  end;

  if Ts_4.TabVisible then begin
    //����������, ������� �� ���� ���������� ������, ����� ����� �� ��� �� ��������
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''�'', ''�'') and dt_end >= :dtb$d and dt_end <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum2ri)), round(sum(sum2ra)), round(sum(sum2rd)), round(sum(sum2rm)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
    Ne_4_RI.Value:=va1[0][0]; Ne_4_RA.Value:=va1[0][1];Ne_4_RD.Value:=va1[0][2];Ne_4_RM.Value:=va1[0][3];
    Ne_4_RI3.Value:=va2[0][0]; Ne_4_RA3.Value:=va2[0][1];Ne_4_RD3.Value:=va2[0][2];Ne_4_RM3.Value:=va2[0][3];
    Ne_4_R.Value:=0;
    for i:=0 to 3 do Ne_4_R.Value:= Ne_4_R.Value + va1[0][i];
    Ne_4_R3.Value:=0;
    for i:=0 to 3 do Ne_4_R3.Value:= Ne_4_R3.Value + va2[0][i];
    Ne_4_RI2.Value:=RoundTo(Ne_4_RI.Value / Ne_4_RI3.Value * 100, -2);
    Ne_4_RA2.Value:=RoundTo(Ne_4_RA.Value / Ne_4_RA3.Value * 100, -2);
    Ne_4_RD2.Value:=RoundTo(Ne_4_RD.Value / Ne_4_RD3.Value * 100, -2);
    Ne_4_RM2.Value:=RoundTo(Ne_4_RM.Value / Ne_4_RM3.Value * 100, -2);
    Ne_4_R2.Value:=RoundTo(Ne_4_R.Value / Ne_4_R3.Value * 100, -2);

    //���, �� ��������� � � �
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''�'', ''�'') and dt_end >= :dtb$d and dt_end <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum2oi)), round(sum(sum2oa)), round(sum(sum2od)), round(sum(sum2om)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
//   if Length(va2) = 0 then va2:=[[1,1,1,1]];
    Ne_4_OI.Value:=va1[0][0]; Ne_4_OA.Value:=va1[0][1];Ne_4_OD.Value:=va1[0][2];Ne_4_OM.Value:=va1[0][3];
    Ne_4_OI3.Value:=va2[0][0]; Ne_4_OA3.Value:=va2[0][1];Ne_4_OD3.Value:=va2[0][2];Ne_4_OM3.Value:=va2[0][3];
    Ne_4_O.Value:=0;
    for i:=0 to 3 do Ne_4_O.Value:= Ne_4_O.Value + va1[0][i];
    Ne_4_O3.Value:=0;
    for i:=0 to 3 do Ne_4_O3.Value:= Ne_4_O3.Value + va2[0][i];
    Ne_4_OI2.Value:=RoundTo(Ne_4_OI.Value / Ne_4_OI3.Value * 100, -2);
    Ne_4_OA2.Value:=RoundTo(Ne_4_OA.Value / Ne_4_OA3.Value * 100, -2);
    Ne_4_OD2.Value:=RoundTo(Ne_4_OD.Value / Ne_4_OD3.Value * 100, -2);
    Ne_4_OM2.Value:=RoundTo(Ne_4_OM.Value / Ne_4_OM3.Value * 100, -2);
    Ne_4_O2.Value:=RoundTo(Ne_4_O.Value / Ne_4_O3.Value * 100, -2);

    //�����
    Ne_4_I.Value:= Ne_4_R.Value + Ne_4_O.Value;
    Ne_4_I3.Value:= Ne_4_R3.Value + Ne_4_O3.Value;
    Ne_4_I2.Value:=RoundTo(Ne_4_I.Value / Ne_4_I3.Value * 100, -2);
  end;


  if Ts_3.TabVisible then begin
    //����� �� ������������
    //������� ���� ����������� �� ��� �� ������� �����, ������ ���� �� ������� ��������, �� ���� ������������ �������
    //����� ��� ����������, �.�. ��������� � �������� ���� ������� ���������� ����� �������� �����
    //�������� ����� ������������� ������� �� ������, � ����� �� ������ ��, �� ������ ���, ������� ����������� � ���� (����� �������� ���� ��������)
    va1:=Q.QLoadToVarDynArray2('select sum(sum_i), sum(sum_i_ok), sum(sum_a), sum(sum_a_ok) from v_order_finreport_1', []);
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum3i)), round(sum(sum3a)), max(prc3i), max(prc3a) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
    if Length(va2) = 0 then va2:=[[1,1,1,1]];
    Ne_3_I.Value:=va1[0][0];
    Ne_3_IOk.Value:=va1[0][1];
    Ne_3_IPlan.Value:=va2[0][0];
    if S.NNum(Ne_3_IPlan.Value) <> 0 then Ne_3_IPrc.Value:=RoundTo(Ne_3_I.Value / Ne_3_IPlan.Value * 100, -2);
    if S.NNum(Ne_3_I.Value) <> 0 then Ne_3_IPrcOk.Value:=RoundTo(Ne_3_IOk.Value / Ne_3_I.Value * 100, -2);
    Ne_3_A.Value:=va1[0][2];
    Ne_3_AOk.Value:=va1[0][3];
    Ne_3_APlan.Value:=va2[0][1];
    if S.NNum(Ne_3_APlan.Value) <> 0 then Ne_3_APrc.Value:=RoundTo(Ne_3_A.Value / Ne_3_APlan.Value * 100, -2);
    if S.NNum(Ne_3_A.Value) <> 0 then Ne_3_APrcOk.Value:=RoundTo(Ne_3_AOk.Value / Ne_3_A.Value * 100, -2);
    Ne_3.Value:=Ne_3_I.Value+Ne_3_A.Value;
    Ne_3_Plan.Value:=Ne_3_IPlan.Value+Ne_3_APlan.Value;
    if S.NNum(Ne_3_Plan.Value) <> 0 then Ne_3_Prc.Value:=RoundTo(Ne_3.Value / Ne_3_Plan.Value * 100, -2);
  end;
  if Ts_5.TabVisible then begin
    //����� �� �������� � ������������
    //����� ������� � �� ��� ��� � ������ ������ �� ��������������� ���������, � ������������� ������� �� ���� ���������,
    //������ �� ������������� ���������, �� ����������� �� ��� �������
    Cth.SetControlValue(Ne5Selling, Q.QSelectOneRow('select sum(sum_i) + sum(sum_a) from v_order_finreport_inprod',[])[0]);
    va2:=Q.QLoadToVarDynArray2('select sum_in_prod, sum_in_stock, sum_rezerv, sum_onway, sum_need, sum_need_p, sum_needcurr from v_nom_for_orders_in_prod_fin', []);
    for i:=0 to High(va2[0]) do
      TDBNumberEditEh(FindComponent('Ne_5_' + InttoStr(i + 1))).Value := va2[0][i];
  end;
  SetReportCaption;
end;

//������ ������� �� ���� ���� ��� ������!!!







procedure TFrmODrepFinByOrders.BtClick(Sender: TObject);
begin
  if TControl(Sender).Tag = 1000 then begin
    if Cb_DtB.text = ''
      then Dlg_R_Order_Plans.ShowDialog(IncMonth(Date, 1))
      else Dlg_R_Order_Plans.ShowDialog(GetDateFromComboBox(Cb_DtB.Value));
  end
  else begin
    if (Cb_DtB.ItemIndex = -1) or (Cb_DtE.ItemIndex = -1) or (Cb_DtE.ItemIndex > Cb_DtB.ItemIndex) then begin
      MyWarningMessage('������� ����� ������!');
      Exit;
    end;
    DtB := GetDateFromComboBox(Cb_DtB.Value);
    DtE := GetDateFromComboBox(Cb_DtE.Value, True);
    CalculateReport;
  end;
end;


function TFrmODrepFinByOrders.Prepare: Boolean;
begin
  Caption := '���������� ����� �� �������';
  Mode := fNone;
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(PMDIClient, []);
  FOpt.DlgButtonsR:=[[1000, User.Role(rOr_R_Plans), '�����'], [], [btnGo, True, True, 180, '������������ �����', '', 150]];
  FOpt.StatusBarMode:=stbmNone;
  Cth.AlignControls(PDlgBtnL, [], True, 2);
  Result := True;
end;


end.
