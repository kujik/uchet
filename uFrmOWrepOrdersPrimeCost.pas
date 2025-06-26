unit uFrmOWrepOrdersPrimeCost;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, DBCtrlsEh, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Mask, Vcl.ComCtrls, Vcl.ExtCtrls, uLabelColors, Math
  ;

type
  TFrmOWrepOrdersPrimeCost = class(TFrmBasicMdi)
    P_Main: TPanel;
    Lb_1: TLabel;
    Lb_2: TLabel;
    Lb_3: TLabel;
    Ne_1_R: TDBNumberEditEh;
    Ne_1_O: TDBNumberEditEh;
    Ne_1_I: TDBNumberEditEh;
    Ne_2_R: TDBNumberEditEh;
    Ne_2_O: TDBNumberEditEh;
    Ne_2_I: TDBNumberEditEh;
    Ne_3_R: TDBNumberEditEh;
    Ne_3_O: TDBNumberEditEh;
    Ne_3_I: TDBNumberEditEh;
    Cb_DtB: TDBComboBoxEh;
    Cb_DtE: TDBComboBoxEh;
    Lb_1_Caption: TLabel;
  private
    DtB, DtE: TDateTime;
    InCalculateReport: Boolean;
    ReportCalculated: Boolean;
    function  Prepare: Boolean; override;
    procedure BtClick(Sender: TObject); override;
    procedure BtOkClick(Sender: TObject); override;
    procedure SetReportCaption;
    function  GetDateFromComboBox(st: string; LastDay: Boolean = False): TDateTime;
    procedure CalculateReport;
  public
  end;

var
  FrmOWrepOrdersPrimeCost: TFrmOWrepOrdersPrimeCost;

implementation

uses
  DateUtils,
  uSettings,
  uForms,
  uDBOra,
  uString,
  uData,
  uMessages,
  uLabelColors2
  ;


{$R *.dfm}

function  TFrmOWrepOrdersPrimeCost.Prepare: Boolean;
var
  i, j: Integer;
begin
  Caption := 'Отчет по себестоимости заказов';
  Mode := fNone;
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(PMDIClient, []);
  FOpt.DlgButtonsR:=[[btnGo, True, True, 160, 'Сформировать отчет', '', 120]];
  FOpt.StatusBarMode:=stbmCustom;
  Cth.AlignControls(PDlgBtnL, [], True, 2);
  DtB := EncodeDate(2000, 1, 1);
  Cb_DtB.Items.Clear;
  Cb_DtE.Items.Clear;
  for i := 2024 to YearOf(Date) do
    for j := 1 to S.IIf(i = YearOf(Date), MonthOf(Date), 12) do begin
      Cb_DtB.Items.Insert(0, IntToStr(i) + ', ' + MonthsRu[j]);
      Cb_DtE.Items.Insert(0, IntToStr(i) + ', ' + MonthsRu[j]);
    end;
  if Cb_DtB.ItemIndex = -1 then
    Cb_DtB.ItemIndex := 0;
  if Cb_DtE.ItemIndex = -1 then
    Cb_DtE.ItemIndex := 0;
  DtB := EncodeDate(2000, 1, 1);
  SetReportCaption;
  RefreshStatusBar('Отчет не сформирован', '', True);
  Result := True;
end;

procedure TFrmOWrepOrdersPrimeCost.BtOkClick(Sender: TObject);
begin
end;


procedure TFrmOWrepOrdersPrimeCost.BtClick(Sender: TObject);
begin
  if (Cb_DtB.ItemIndex = -1) or (Cb_DtE.ItemIndex = -1) or (Cb_DtE.ItemIndex > Cb_DtB.ItemIndex) then begin
    MyWarningMessage('Неверно задан период!');
    Exit;
  end;
  DtB := GetDateFromComboBox(Cb_DtB.Value);
  DtE := GetDateFromComboBox(Cb_DtE.Value, True);
  CalculateReport;
end;

procedure TFrmOWrepOrdersPrimeCost.SetReportCaption;
begin
  if InCalculateReport then
    Lb_1_Caption.SetCaptionAr2(['$FF00FF', '   Отчет формируется.'])
  else if not ReportCalculated then
    Lb_1_Caption.SetCaptionAr2(['$0000FF', '   Отчет не сформирован!'])
  else
    Lb_1_Caption.SetCaptionAr2(['$000000', '   Отчет за период с ', '$FF0000', DateToStr(DtB), '$000000', ' по ', '$FF0000', DateToStr(DtE)])
end;

function TFrmOWrepOrdersPrimeCost.GetDateFromComboBox(st: string; LastDay: Boolean = False): TDateTime;
//получим дату из по текстовой строке типа 2024, март
//если LastDay то последним числом месяца, иначе первым числом
//если старше текущей даты, то вернем текущую дату
var
  i: Integer;
begin
  Result := EncodeDate(2000, 1, 1);
  try
    i := 1;
    while Copy(st, 7) <> MonthsRu[i] do
      inc(i);
    Result := EncodeDate(StrToInt(Copy(st, 1, 4)), i, 1);
    if LastDay then
      Result := IncDay(IncMonth(Result, 1), -1);
    if Result > Date then
      Result := Date;
  except
    Exit;
  end;
end;

procedure TFrmOWrepOrdersPrimeCost.CalculateReport;
var
  i, j: Integer;
  va1, va2: TVarDynArray;
  e1: Extended;
begin
  InCalculateReport := True;
  //dtb := encodedate(2024, 06, 01);
  //dte := encodedate(2024, 06, 05);
  Ne_1_R.Value := null;
  Ne_1_O.Value := null;
  Ne_1_I.Value := null;
  Ne_2_R.Value := null;
  Ne_2_O.Value := null;
  Ne_2_I.Value := null;
  Ne_3_R.Value := null;
  Ne_3_O.Value := null;
  Ne_3_I.Value := null;
  Q.QSetContextValue('order_finreport_dtbeg', DtB);
  Q.QSetContextValue('order_finreport_dtend', DtE);

  //Bt_Cancel.Enabled := False;
  //Bt_Ok.Enabled := False;

  SetReportCaption;

  //продажа, выборка по начальной дате
  //розница, по префиксам О и Н
  RefreshStatusBar(' $000000формирование отчета: $FF0000данные по продажам (розница)', '$0000FFЖдите!  ', True);
  Ne_1_R.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_order_items where (id_order > 0) and (ornum like ''О%'' or ornum like ''Н%'') and (dt_beg >= :dtb$d) and (dt_beg <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_1_R.Value := S.NNum(va1[0]);
  //опт, по префиксам М и Ф
  RefreshStatusBar(' $000000формирование отчета: $FF0000данные по продажам (опт)', '$0000FFЖдите!  ', True);
  Ne_1_O.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (ornum like ''М%'' or ornum like ''Ф%'') and (dt_beg >= :dtb$d) and (dt_beg <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_1_O.Value := S.NNum(va1[0]);
  Ne_1_I.Value := Ne_1_R.Value + Ne_1_O.Value;

  //отгрузка, выборка по дате отгрузки с СГП
  RefreshStatusBar(' $000000формирование отчета: $FF0000данные по отгрузке (розница)', '$0000FFЖдите!  ', True);
  Ne_2_R.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''Н'',''О'')) and (dt_from_sgp >= :dtb$d) and (dt_from_sgp <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_2_R.Value := S.NNum(va1[0]);
  RefreshStatusBar(' $000000формирование отчета: $FF0000данные по отгрузке (опт)', '$0000FFЖдите!  ', True);
  Ne_2_O.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''М'',''Ф'')) and (dt_from_sgp >= :dtb$d) and (dt_from_sgp <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_2_O.Value := S.NNum(va1[0]);
  Ne_2_I.Value := Ne_2_R.Value + Ne_2_O.Value;

  //реализация, выборка по дате закрытия заказа
  RefreshStatusBar(' $000000формирование отчета: $FF0000данные по реализации (розница)', '$0000FFЖдите!  ', True);
  Ne_3_R.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''Н'',''О'')) and (dt_end >= :dtb$d) and (dt_end <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_3_R.Value := S.NNum(va1[0]);
  RefreshStatusBar(' $000000формирование отчета: $FF0000данные по реализации (опт)', '$0000FFЖдите!  ', True);
  Ne_3_O.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''М'',''Ф'')) and (dt_end >= :dtb$d) and (dt_end <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_3_O.Value := S.NNum(va1[0]);
  Ne_3_I.Value := Ne_3_R.Value + Ne_3_O.Value;

  //Bt_Cancel.Enabled := True;
  //Bt_Ok.Enabled := True;
  InCalculateReport := False;
  ReportCalculated := True;

  SetReportCaption;
  RefreshStatusBar('Отчет сформирован', '', True);
end;





end.
