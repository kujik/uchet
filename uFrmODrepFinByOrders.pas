unit uFrmODrepFinByOrders;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, DBCtrlsEh, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls, uLabelColors, Math, Vcl.Mask
  ;

type
  TFrmODrepFinByOrders = class(TFrmBasicMdi)
    pgc_1: TPageControl;
    ts_1: TTabSheet;
    pnl_1_Top: TPanel;
    gb_1_1: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    nedt_1_RA: TDBNumberEditEh;
    nedt_1_RD: TDBNumberEditEh;
    nedt_1_RM: TDBNumberEditEh;
    nedt_1_R: TDBNumberEditEh;
    nedt_1_RI2: TDBNumberEditEh;
    nedt_1_RI3: TDBNumberEditEh;
    nedt_1_RA2: TDBNumberEditEh;
    nedt_1_RA3: TDBNumberEditEh;
    nedt_1_RD2: TDBNumberEditEh;
    nedt_1_RM2: TDBNumberEditEh;
    nedt_1_R2: TDBNumberEditEh;
    nedt_1_RD3: TDBNumberEditEh;
    nedt_1_RM3: TDBNumberEditEh;
    nedt_1_R3: TDBNumberEditEh;
    nedt_1_RI: TDBNumberEditEh;
    gb_1_2: TGroupBox;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    nedt_1_OA: TDBNumberEditEh;
    nedt_1_OD: TDBNumberEditEh;
    nedt_1_OM: TDBNumberEditEh;
    nedt_1_O: TDBNumberEditEh;
    nedt_1_OI2: TDBNumberEditEh;
    nedt_1_OI3: TDBNumberEditEh;
    nedt_1_OA2: TDBNumberEditEh;
    nedt_1_OA3: TDBNumberEditEh;
    nedt_1_OD2: TDBNumberEditEh;
    nedt_1_OM2: TDBNumberEditEh;
    nedt_1_O2: TDBNumberEditEh;
    nedt_1_OD3: TDBNumberEditEh;
    nedt_1_OM3: TDBNumberEditEh;
    nedt_1_O3: TDBNumberEditEh;
    nedt_1_OI: TDBNumberEditEh;
    gb_1_3: TGroupBox;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    nedt_1_I: TDBNumberEditEh;
    nedt_1_I2: TDBNumberEditEh;
    nedt_1_I3: TDBNumberEditEh;
    ts_2: TTabSheet;
    pnl_2_Top: TPanel;
    gb_2_2: TGroupBox;
    lbl14: TLabel;
    lbl15: TLabel;
    lbl16: TLabel;
    nedt_2_OA: TDBNumberEditEh;
    nedt_2_OD: TDBNumberEditEh;
    nedt_2_OM: TDBNumberEditEh;
    nedt_2_O: TDBNumberEditEh;
    nedt_2_OI2: TDBNumberEditEh;
    nedt_2_OI3: TDBNumberEditEh;
    nedt_2_OA2: TDBNumberEditEh;
    nedt_2_OA3: TDBNumberEditEh;
    nedt_2_OD2: TDBNumberEditEh;
    nedt_2_OM2: TDBNumberEditEh;
    nedt_2_O2: TDBNumberEditEh;
    nedt_2_OD3: TDBNumberEditEh;
    nedt_2_OM3: TDBNumberEditEh;
    nedt_2_O3: TDBNumberEditEh;
    nedt_2_OI: TDBNumberEditEh;
    gb_2_3: TGroupBox;
    lbl17: TLabel;
    lbl18: TLabel;
    lbl19: TLabel;
    nedt_2_I: TDBNumberEditEh;
    nedt_2_I2: TDBNumberEditEh;
    nedt_2_I3: TDBNumberEditEh;
    gb1: TGroupBox;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    nedt_2_RA: TDBNumberEditEh;
    nedt_2_RD: TDBNumberEditEh;
    nedt_2_RM: TDBNumberEditEh;
    nedt_2_R: TDBNumberEditEh;
    nedt_2_RI2: TDBNumberEditEh;
    nedt_2_RI3: TDBNumberEditEh;
    nedt_2_RA2: TDBNumberEditEh;
    nedt_2_RA3: TDBNumberEditEh;
    nedt_2_RD2: TDBNumberEditEh;
    nedt_2_RM2: TDBNumberEditEh;
    nedt_2_R2: TDBNumberEditEh;
    nedt_2_RD3: TDBNumberEditEh;
    nedt_2_RM3: TDBNumberEditEh;
    nedt_2_R3: TDBNumberEditEh;
    nedt_2_RI: TDBNumberEditEh;
    ts_4: TTabSheet;
    pnl1: TPanel;
    gb5: TGroupBox;
    lbl20: TLabel;
    lbl21: TLabel;
    lbl22: TLabel;
    nedt_4_RA: TDBNumberEditEh;
    nedt_4_RD: TDBNumberEditEh;
    nedt_4_RM: TDBNumberEditEh;
    nedt_4_R: TDBNumberEditEh;
    nedt_4_RI2: TDBNumberEditEh;
    nedt_4_RI3: TDBNumberEditEh;
    nedt_4_RA2: TDBNumberEditEh;
    nedt_4_RA3: TDBNumberEditEh;
    nedt_4_RD2: TDBNumberEditEh;
    nedt_4_RM2: TDBNumberEditEh;
    nedt_4_R2: TDBNumberEditEh;
    nedt_4_RD3: TDBNumberEditEh;
    nedt_4_RM3: TDBNumberEditEh;
    nedt_4_R3: TDBNumberEditEh;
    nedt_4_RI: TDBNumberEditEh;
    gb6: TGroupBox;
    lbl23: TLabel;
    lbl24: TLabel;
    lbl25: TLabel;
    nedt_4_OA: TDBNumberEditEh;
    nedt_4_OD: TDBNumberEditEh;
    nedt_4_OM: TDBNumberEditEh;
    nedt_4_O: TDBNumberEditEh;
    nedt_4_OI2: TDBNumberEditEh;
    nedt_4_OI3: TDBNumberEditEh;
    nedt_4_OA2: TDBNumberEditEh;
    nedt_4_OA3: TDBNumberEditEh;
    nedt_4_OD2: TDBNumberEditEh;
    nedt_4_OM2: TDBNumberEditEh;
    nedt_4_O2: TDBNumberEditEh;
    nedt_4_OD3: TDBNumberEditEh;
    nedt_4_OM3: TDBNumberEditEh;
    nedt_4_O3: TDBNumberEditEh;
    nedt_4_OI: TDBNumberEditEh;
    gb7: TGroupBox;
    lbl26: TLabel;
    lbl27: TLabel;
    lbl28: TLabel;
    nedt_4_I: TDBNumberEditEh;
    nedt_4_I2: TDBNumberEditEh;
    nedt_4_I3: TDBNumberEditEh;
    ts_3: TTabSheet;
    pnl_3_Top: TPanel;
    gb2: TGroupBox;
    nedt_3_I: TDBNumberEditEh;
    nedt_3_IOk: TDBNumberEditEh;
    nedt_3_IPrc: TDBNumberEditEh;
    nedt_3_IPrcOk: TDBNumberEditEh;
    nedt_3_IPlan: TDBNumberEditEh;
    gb3: TGroupBox;
    nedt_3_A: TDBNumberEditEh;
    nedt_3_AOk: TDBNumberEditEh;
    nedt_3_APrc: TDBNumberEditEh;
    nedt_3_APrcOk: TDBNumberEditEh;
    nedt_3_APlan: TDBNumberEditEh;
    gb4: TGroupBox;
    nedt_3: TDBNumberEditEh;
    nedt_3_Prc: TDBNumberEditEh;
    nedt_3_Plan: TDBNumberEditEh;
    DBNumberEditEh7: TDBNumberEditEh;
    DBNumberEditEh9: TDBNumberEditEh;
    cmb_DtB: TDBComboBoxEh;
    cmb_DtE: TDBComboBoxEh;
    ts_5: TTabSheet;
    Ne5Selling: TDBNumberEditEh;
    Panel2: TPanel;
    lblCaption: TLabel;
    gb8: TGroupBox;
    nedt_5_1: TDBNumberEditEh;
    nedt_5_2: TDBNumberEditEh;
    nedt_5_3: TDBNumberEditEh;
    nedt_5_6: TDBNumberEditEh;
    nedt_5_4: TDBNumberEditEh;
    nedt_5_5: TDBNumberEditEh;
    nedt_5_7: TDBNumberEditEh;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    DtB, DtE: TDateTime;
    function  Prepare: Boolean; override;
    procedure btnClick(Sender: TObject); override;
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

  uForms,
  uDBOra,
  uString,
  uData,
  uMessages,
  D_R_Order_Plans
  ;

function TFrmODrepFinByOrders.GetDateFromComboBox(st: string; LastDay: Boolean = False): TDateTime;
//получим дату из по текстовой строке типа 2024, март
//если LastDay то последним числом месяца, иначе первым числом
//если старше текущей даты, то вернем текущую дату
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
//порядок вкладок не совпадает с номерами в их названиях, в именах контролов цира совпадает с цифрой в имени вкладки
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
      cmb_DtB.Items.Insert(0, IntToStr(i) + ', ' + MonthsRu[j]);
      cmb_DtE.Items.Insert(0, IntToStr(i) + ', ' + MonthsRu[j]);
    end;
  if cmb_DtB.ItemIndex = -1 then
    cmb_DtB.ItemIndex := 0;
  if cmb_DtE.ItemIndex = -1 then
    cmb_DtE.ItemIndex := 0;
  ts_1.TabVisible := User.Role(rOr_Rep_Order_Fin1);         //продажа
  ts_2.TabVisible := User.Role(rOr_Rep_Order_Fin5);         //отгрузка
  ts_3.TabVisible := User.Role(rOr_Rep_Order_Fin3);         //производство
  ts_4.TabVisible := User.Role(rOr_Rep_Order_Fin2);         //реализация
  ts_5.TabVisible := User.Role(rOr_Rep_Order_Fin3);         //производство
end;

procedure TFrmODrepFinByOrders.FormCreate(Sender: TObject);
begin
  inherited;
  pgc_1.TabIndex:=0;
end;

procedure TFrmODrepFinByOrders.SetReportCaption;
var
  Labels:array[0..3] of TLabel;
  i:Integer;
begin
  if YearOf(DtB) = 2000
    then lblCaption.SetCaptionAr2(['$0000FF', 'Отчет не сформирован!'])
    else lblCaption.SetCaptionAr2(['$000000', 'Отчет за период с ', '$FF0000', DateToStr(DtB) , '$000000' , ' по ', '$FF0000', DateToStr(DtE)]);
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
  if ts_1.TabVisible then begin
    //продажа, выборка по начальной дате
    //розница, по префиксам О и Н
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''О'', ''Н'') and dt_beg >= :dtb$d and dt_beg <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum1ri)), round(sum(sum1ra)), round(sum(sum1rd)), round(sum(sum1rm)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
//    if Length(va2) = 0 then va2:=[[1,1,1,1]];
    CorrectNullData;
    nedt_1_RI.Value:=va1[0][0]; nedt_1_RA.Value:=va1[0][1];nedt_1_RD.Value:=va1[0][2];nedt_1_RM.Value:=va1[0][3];
    nedt_1_RI3.Value:=va2[0][0]; nedt_1_RA3.Value:=va2[0][1];nedt_1_RD3.Value:=va2[0][2];nedt_1_RM3.Value:=va2[0][3];
    nedt_1_R.Value:=0;
    for i:=0 to 3 do nedt_1_R.Value:= nedt_1_R.Value + va1[0][i];
    nedt_1_R3.Value:=0;
    for i:=0 to 3 do nedt_1_R3.Value:= nedt_1_R3.Value + va2[0][i];
    nedt_1_RI2.Value:=RoundTo(nedt_1_RI.Value / nedt_1_RI3.Value * 100, -2);
    nedt_1_RA2.Value:=RoundTo(nedt_1_RA.Value / nedt_1_RA3.Value * 100, -2);
    nedt_1_RD2.Value:=RoundTo(nedt_1_RD.Value / nedt_1_RD3.Value * 100, -2);
    nedt_1_RM2.Value:=RoundTo(nedt_1_RM.Value / nedt_1_RM3.Value * 100, -2);
    nedt_1_R2.Value:=RoundTo(nedt_1_R.Value / nedt_1_R3.Value * 100, -2);

    //опт, по префиксам М и Ф
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''М'', ''Ф'') and dt_beg >= :dtb$d and dt_beg <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum1oi)), round(sum(sum1oa)), round(sum(sum1od)), round(sum(sum1om)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
//    if Length(va2) = 0 then va2:=[[1,1,1,1]];
    nedt_1_OI.Value:=va1[0][0]; nedt_1_OA.Value:=va1[0][1];nedt_1_OD.Value:=va1[0][2];nedt_1_OM.Value:=va1[0][3];
    nedt_1_OI3.Value:=va2[0][0]; nedt_1_OA3.Value:=va2[0][1];nedt_1_OD3.Value:=va2[0][2];nedt_1_OM3.Value:=va2[0][3];
    nedt_1_O.Value:=0;
    for i:=0 to 3 do nedt_1_O.Value:= nedt_1_O.Value + va1[0][i];
    nedt_1_O3.Value:=0;
    for i:=0 to 3 do nedt_1_O3.Value:= nedt_1_O3.Value + va2[0][i];
    nedt_1_OI2.Value:=RoundTo(nedt_1_OI.Value / nedt_1_OI3.Value * 100, -2);
    nedt_1_OA2.Value:=RoundTo(nedt_1_OA.Value / nedt_1_OA3.Value * 100, -2);
    nedt_1_OD2.Value:=RoundTo(nedt_1_OD.Value / nedt_1_OD3.Value * 100, -2);
    nedt_1_OM2.Value:=RoundTo(nedt_1_OM.Value / nedt_1_OM3.Value * 100, -2);
    nedt_1_O2.Value:=RoundTo(nedt_1_O.Value / nedt_1_O3.Value * 100, -2);

    //итого
    nedt_1_I.Value:= nedt_1_R.Value + nedt_1_O.Value;
    nedt_1_I3.Value:= nedt_1_R3.Value + nedt_1_O3.Value;
    nedt_1_I2.Value:=RoundTo(nedt_1_I.Value / nedt_1_I3.Value * 100, -2);
  end;

  if ts_2.TabVisible then begin
    //отгрузка, выборка по дате отгрузки с СГП
    //розница, по префиксам О и Н
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''О'', ''Н'') and dt_from_sgp >= :dtb$d and dt_from_sgp <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum2ri)), round(sum(sum2ra)), round(sum(sum2rd)), round(sum(sum2rm)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
//    if Length(va2) = 0 then va2:=[[1,1,1,1]];
    CorrectNullData;
    nedt_2_RI.Value:=va1[0][0]; nedt_2_RA.Value:=va1[0][1];nedt_2_RD.Value:=va1[0][2];nedt_2_RM.Value:=va1[0][3];
    nedt_2_RI3.Value:=va2[0][0]; nedt_2_RA3.Value:=va2[0][1];nedt_2_RD3.Value:=va2[0][2];nedt_2_RM3.Value:=va2[0][3];
    nedt_2_R.Value:=0;
    for i:=0 to 3 do nedt_2_R.Value:= nedt_2_R.Value + va1[0][i];
    nedt_2_R3.Value:=0;
    for i:=0 to 3 do nedt_2_R3.Value:= nedt_2_R3.Value + va2[0][i];
    nedt_2_RI2.Value:=RoundTo(nedt_2_RI.Value / nedt_2_RI3.Value * 100, -2);
    nedt_2_RA2.Value:=RoundTo(nedt_2_RA.Value / nedt_2_RA3.Value * 100, -2);
    nedt_2_RD2.Value:=RoundTo(nedt_2_RD.Value / nedt_2_RD3.Value * 100, -2);
    nedt_2_RM2.Value:=RoundTo(nedt_2_RM.Value / nedt_2_RM3.Value * 100, -2);
    nedt_2_R2.Value:=RoundTo(nedt_2_R.Value / nedt_2_R3.Value * 100, -2);

    //опт, по префиксам М и Ф
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''М'', ''Ф'') and dt_from_sgp >= :dtb$d and dt_from_sgp <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum2oi)), round(sum(sum2oa)), round(sum(sum2od)), round(sum(sum2om)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
//   if Length(va2) = 0 then va2:=[[1,1,1,1]];
    nedt_2_OI.Value:=va1[0][0]; nedt_2_OA.Value:=va1[0][1];nedt_2_OD.Value:=va1[0][2];nedt_2_OM.Value:=va1[0][3];
    nedt_2_OI3.Value:=va2[0][0]; nedt_2_OA3.Value:=va2[0][1];nedt_2_OD3.Value:=va2[0][2];nedt_2_OM3.Value:=va2[0][3];
    nedt_2_O.Value:=0;
    for i:=0 to 3 do nedt_2_O.Value:= nedt_2_O.Value + va1[0][i];
    nedt_2_O3.Value:=0;
    for i:=0 to 3 do nedt_2_O3.Value:= nedt_2_O3.Value + va2[0][i];
    nedt_2_OI2.Value:=RoundTo(nedt_2_OI.Value / nedt_2_OI3.Value * 100, -2);
    nedt_2_OA2.Value:=RoundTo(nedt_2_OA.Value / nedt_2_OA3.Value * 100, -2);
    nedt_2_OD2.Value:=RoundTo(nedt_2_OD.Value / nedt_2_OD3.Value * 100, -2);
    nedt_2_OM2.Value:=RoundTo(nedt_2_OM.Value / nedt_2_OM3.Value * 100, -2);
    nedt_2_O2.Value:=RoundTo(nedt_2_O.Value / nedt_2_O3.Value * 100, -2);

    //итого
    nedt_2_I.Value:= nedt_2_R.Value + nedt_2_O.Value;
    nedt_2_I3.Value:= nedt_2_R3.Value + nedt_2_O3.Value;
    nedt_2_I2.Value:=RoundTo(nedt_2_I.Value / nedt_2_I3.Value * 100, -2);
  end;

  if ts_4.TabVisible then begin
    //реализация, выборка по дате завершения заказа, планы такие же как по отгрузке
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''О'', ''Н'') and dt_end >= :dtb$d and dt_end <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum2ri)), round(sum(sum2ra)), round(sum(sum2rd)), round(sum(sum2rm)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
    nedt_4_RI.Value:=va1[0][0]; nedt_4_RA.Value:=va1[0][1];nedt_4_RD.Value:=va1[0][2];nedt_4_RM.Value:=va1[0][3];
    nedt_4_RI3.Value:=va2[0][0]; nedt_4_RA3.Value:=va2[0][1];nedt_4_RD3.Value:=va2[0][2];nedt_4_RM3.Value:=va2[0][3];
    nedt_4_R.Value:=0;
    for i:=0 to 3 do nedt_4_R.Value:= nedt_4_R.Value + va1[0][i];
    nedt_4_R3.Value:=0;
    for i:=0 to 3 do nedt_4_R3.Value:= nedt_4_R3.Value + va2[0][i];
    nedt_4_RI2.Value:=RoundTo(nedt_4_RI.Value / nedt_4_RI3.Value * 100, -2);
    nedt_4_RA2.Value:=RoundTo(nedt_4_RA.Value / nedt_4_RA3.Value * 100, -2);
    nedt_4_RD2.Value:=RoundTo(nedt_4_RD.Value / nedt_4_RD3.Value * 100, -2);
    nedt_4_RM2.Value:=RoundTo(nedt_4_RM.Value / nedt_4_RM3.Value * 100, -2);
    nedt_4_R2.Value:=RoundTo(nedt_4_R.Value / nedt_4_R3.Value * 100, -2);

    //опт, по префиксам М и Ф
    va1:=Q.QLoadToVarDynArray2(
      'select round(sum(cost_i_wo_nds)), round(sum(cost_a_wo_nds)), round(sum(cost_d_wo_nds)), round(sum(cost_m_wo_nds)) from v_orders '+
      'where id > 0 and prefix in (''М'', ''Ф'') and dt_end >= :dtb$d and dt_end <= :dte$d',
      [DtB, DtE]
    );
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum2oi)), round(sum(sum2oa)), round(sum(sum2od)), round(sum(sum2om)) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
//   if Length(va2) = 0 then va2:=[[1,1,1,1]];
    nedt_4_OI.Value:=va1[0][0]; nedt_4_OA.Value:=va1[0][1];nedt_4_OD.Value:=va1[0][2];nedt_4_OM.Value:=va1[0][3];
    nedt_4_OI3.Value:=va2[0][0]; nedt_4_OA3.Value:=va2[0][1];nedt_4_OD3.Value:=va2[0][2];nedt_4_OM3.Value:=va2[0][3];
    nedt_4_O.Value:=0;
    for i:=0 to 3 do nedt_4_O.Value:= nedt_4_O.Value + va1[0][i];
    nedt_4_O3.Value:=0;
    for i:=0 to 3 do nedt_4_O3.Value:= nedt_4_O3.Value + va2[0][i];
    nedt_4_OI2.Value:=RoundTo(nedt_4_OI.Value / nedt_4_OI3.Value * 100, -2);
    nedt_4_OA2.Value:=RoundTo(nedt_4_OA.Value / nedt_4_OA3.Value * 100, -2);
    nedt_4_OD2.Value:=RoundTo(nedt_4_OD.Value / nedt_4_OD3.Value * 100, -2);
    nedt_4_OM2.Value:=RoundTo(nedt_4_OM.Value / nedt_4_OM3.Value * 100, -2);
    nedt_4_O2.Value:=RoundTo(nedt_4_O.Value / nedt_4_O3.Value * 100, -2);

    //итого
    nedt_4_I.Value:= nedt_4_R.Value + nedt_4_O.Value;
    nedt_4_I3.Value:= nedt_4_R3.Value + nedt_4_O3.Value;
    nedt_4_I2.Value:=RoundTo(nedt_4_I.Value / nedt_4_I3.Value * 100, -2);
  end;


  if ts_3.TabVisible then begin
    //отчет по производству
    //берется дата поступления на сгп по каждому слешу, обсчет идет по заказам частично, по мере изготовления изделий
    //вьюха без параметров, т.к. начальная и конечная дата выборки передаются через контекст сесии
    //получаем сумму изготовленных изделий за период, и сумму за переод же, но только тех, которые изготовлены в срок (ранее плановой даты отгрузки)
    va1:=Q.QLoadToVarDynArray2('select sum(sum_i), sum(sum_i_ok), sum(sum_a), sum(sum_a_ok) from v_order_finreport_1', []);
    va2:=Q.QLoadToVarDynArray2(
      'select round(sum(sum3i)), round(sum(sum3a)), max(prc3i), max(prc3a) from order_plans where dt >= :dtb$d and  dt <= :dte$d',
      [EncodeDate(YearOf(DtB), MonthOf(DtB), 1), EncodeDate(YearOf(DtE), MonthOf(DtE), 1)]
    );
    CorrectNullData;
    if Length(va2) = 0 then va2:=[[1,1,1,1]];
    nedt_3_I.Value:=va1[0][0];
    nedt_3_IOk.Value:=va1[0][1];
    nedt_3_IPlan.Value:=va2[0][0];
    if S.NNum(nedt_3_IPlan.Value) <> 0 then nedt_3_IPrc.Value:=RoundTo(nedt_3_I.Value / nedt_3_IPlan.Value * 100, -2);
    if S.NNum(nedt_3_I.Value) <> 0 then nedt_3_IPrcOk.Value:=RoundTo(nedt_3_IOk.Value / nedt_3_I.Value * 100, -2);
    nedt_3_A.Value:=va1[0][2];
    nedt_3_AOk.Value:=va1[0][3];
    nedt_3_APlan.Value:=va2[0][1];
    if S.NNum(nedt_3_APlan.Value) <> 0 then nedt_3_APrc.Value:=RoundTo(nedt_3_A.Value / nedt_3_APlan.Value * 100, -2);
    if S.NNum(nedt_3_A.Value) <> 0 then nedt_3_APrcOk.Value:=RoundTo(nedt_3_AOk.Value / nedt_3_A.Value * 100, -2);
    nedt_3.Value:=nedt_3_I.Value+nedt_3_A.Value;
    nedt_3_Plan.Value:=nedt_3_IPlan.Value+nedt_3_APlan.Value;
    if S.NNum(nedt_3_Plan.Value) <> 0 then nedt_3_Prc.Value:=RoundTo(nedt_3.Value / nedt_3_Plan.Value * 100, -2);
  end;
  if ts_5.TabVisible then begin
    //отчет по изделиям в производстве
    //сумма изделии и дк без ндс с учетом скидок по производстенным паспортам, и нестандартных изделий по всем остальным,
    //только по незавершенным паспортам, по непринятому на сгп остатку
    Cth.SetControlValue(Ne5Selling, Q.QSelectOneRow('select sum(sum_i) + sum(sum_a) from v_order_finreport_inprod',[])[0]);
    va2:=Q.QLoadToVarDynArray2('select sum_in_prod, sum_in_stock, sum_rezerv, sum_onway, sum_need, sum_need_p, sum_needcurr from v_nom_for_orders_in_prod_fin', []);
    for i:=0 to High(va2[0]) do
      TDBNumberEditEh(FindComponent('nedt_5_' + InttoStr(i + 1))).Value := va2[0][i];
  end;
  SetReportCaption;
end;

//ошибки деления на ноль если нет данных!!!







procedure TFrmODrepFinByOrders.btnClick(Sender: TObject);
begin
  if TControl(Sender).Tag = 1000 then begin
    if cmb_DtB.text = ''
      then Dlg_R_Order_Plans.ShowDialog(IncMonth(Date, 1))
      else Dlg_R_Order_Plans.ShowDialog(GetDateFromComboBox(cmb_DtB.Value));
  end
  else begin
    if (cmb_DtB.ItemIndex = -1) or (cmb_DtE.ItemIndex = -1) or (cmb_DtE.ItemIndex > cmb_DtB.ItemIndex) then begin
      MyWarningMessage('Неверно задан период!');
      Exit;
    end;
    DtB := GetDateFromComboBox(cmb_DtB.Value);
    DtE := GetDateFromComboBox(cmb_DtE.Value, True);
    CalculateReport;
  end;
end;


function TFrmODrepFinByOrders.Prepare: Boolean;
begin
  Caption := 'Финансовый отчет по заказам';
  Mode := fNone;
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(pnlFrmClient, []);
  FOpt.DlgButtonsR:=[[1000, User.Role(rOr_R_Plans), 'Планы'], [], [mbtGo, True, True, 180, 'Сформировать отчет', '', 150]];
  FOpt.StatusBarMode:=stbmNone;
  Cth.AlignControls(pnlFrmBtnsL, [], True, 2);
  Result := True;
end;


end.
