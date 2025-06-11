unit F_Rep_Orders_PrimeCost;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Mask, DBCtrlsEh, Vcl.Buttons,
  DateUtils, uLabelColors, Math, V_MDI;

type
  TForm_Rep_Orders_PrimeCost = class(TForm_MDI)
    P_Bottom: TPanel;
    Bt_Cancel: TBitBtn;
    Bt_Ok: TBitBtn;
    Cb_DtB: TDBComboBoxEh;
    Cb_DtE: TDBComboBoxEh;
    P_Main: TPanel;
    Lb_1_Caption: TLabel;
    Ne_1_R: TDBNumberEditEh;
    Ne_1_O: TDBNumberEditEh;
    Ne_1_I: TDBNumberEditEh;
    Lb_1: TLabel;
    Lb_2: TLabel;
    Ne_2_R: TDBNumberEditEh;
    Ne_2_O: TDBNumberEditEh;
    Ne_2_I: TDBNumberEditEh;
    Lb_3: TLabel;
    Ne_3_R: TDBNumberEditEh;
    Ne_3_O: TDBNumberEditEh;
    Ne_3_I: TDBNumberEditEh;
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_OkClick(Sender: TObject);
    procedure SetReportCaption;
    function GetDateFromComboBox(st: string; LastDay: Boolean = False): TDateTime;
    procedure CalculateReport;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    DtB, DtE: TDateTime;
    InCalculateReport: Boolean;
    function Prepare: Boolean; override;
  public
    { Public declarations }
  end;

var
  Form_Rep_Orders_PrimeCost: TForm_Rep_Orders_PrimeCost;

implementation

uses
  uSettings, uForms, uDBOra, uString, uData, uMessages;


{$R *.dfm}

procedure TForm_Rep_Orders_PrimeCost.CalculateReport;
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

  Bt_Cancel.Enabled := False;
  Bt_Ok.Enabled := False;

  SetReportCaption;

  //продажа, выборка по начальной дате
  //розница, по префиксам О и Н
  SetStatusBar(' $000000формирование отчета: $FF0000данные по продажам (розница)', '$0000FFЖдите!  ', True);
  Ne_1_R.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_order_items where (id_order > 0) and (ornum like ''О%'' or ornum like ''Н%'') and (dt_beg >= :dtb$d) and (dt_beg <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_1_R.Value := S.NNum(va1[0]);
  //опт, по префиксам М и Ф
  SetStatusBar(' $000000формирование отчета: $FF0000данные по продажам (опт)', '$0000FFЖдите!  ', True);
  Ne_1_O.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (ornum like ''М%'' or ornum like ''Ф%'') and (dt_beg >= :dtb$d) and (dt_beg <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_1_O.Value := S.NNum(va1[0]);
  Ne_1_I.Value := Ne_1_R.Value + Ne_1_O.Value;

  //отгрузка, выборка по дате отгрузки с СГП
  SetStatusBar(' $000000формирование отчета: $FF0000данные по отгрузке (розница)', '$0000FFЖдите!  ', True);
  Ne_2_R.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''Н'',''О'')) and (dt_from_sgp >= :dtb$d) and (dt_from_sgp <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_2_R.Value := S.NNum(va1[0]);
  SetStatusBar(' $000000формирование отчета: $FF0000данные по отгрузке (опт)', '$0000FFЖдите!  ', True);
  Ne_2_O.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''М'',''Ф'')) and (dt_from_sgp >= :dtb$d) and (dt_from_sgp <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_2_O.Value := S.NNum(va1[0]);
  Ne_2_I.Value := Ne_2_R.Value + Ne_2_O.Value;

  //реализация, выборка по дате закрытия заказа
  SetStatusBar(' $000000формирование отчета: $FF0000данные по реализации (розница)', '$0000FFЖдите!  ', True);
  Ne_3_R.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''Н'',''О'')) and (dt_end >= :dtb$d) and (dt_end <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_3_R.Value := S.NNum(va1[0]);
  SetStatusBar(' $000000формирование отчета: $FF0000данные по реализации (опт)', '$0000FFЖдите!  ', True);
  Ne_3_O.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''М'',''Ф'')) and (dt_end >= :dtb$d) and (dt_end <= :dte$d)', [DtB, DtE]);
  if Length(va1) > 0 then
    Ne_3_O.Value := S.NNum(va1[0]);
  Ne_3_I.Value := Ne_3_R.Value + Ne_3_O.Value;

  Bt_Cancel.Enabled := True;
  Bt_Ok.Enabled := True;
  SetReportCaption;

  SetStatusBar('', '', False);
  InCalculateReport := False;
end;

procedure TForm_Rep_Orders_PrimeCost.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited;
  CanClose := Bt_Cancel.Enabled;
end;

procedure TForm_Rep_Orders_PrimeCost.SetReportCaption;
begin
  if not Bt_Ok.Enabled then
    Lb_1_Caption.SetCaptionAr2(['$FF00FF', '   Отчет формируется.'])
  else if YearOf(DtB) = 2000 then
    Lb_1_Caption.SetCaptionAr2(['$0000FF', '   Отчет не сформирован!'])
  else
    Lb_1_Caption.SetCaptionAr2(['$000000', '   Отчет за период с ', '$FF0000', DateToStr(DtB), '$000000', ' по ', '$FF0000', DateToStr(DtE)])
end;

function TForm_Rep_Orders_PrimeCost.GetDateFromComboBox(st: string; LastDay: Boolean = False): TDateTime;
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

procedure TForm_Rep_Orders_PrimeCost.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TForm_Rep_Orders_PrimeCost.Bt_OkClick(Sender: TObject);
begin
  if (Cb_DtB.ItemIndex = -1) or (Cb_DtE.ItemIndex = -1) or (Cb_DtE.ItemIndex > Cb_DtB.ItemIndex) then begin
    MyWarningMessage('Неверно задан период!');
    Exit;
  end;
  DtB := GetDateFromComboBox(Cb_DtB.Value);
  DtE := GetDateFromComboBox(Cb_DtE.Value, True);
  CalculateReport;
end;

function TForm_Rep_Orders_PrimeCost.Prepare: Boolean;
var
  Info: string;
  st: string;
  i, j: Integer;
begin
  Result := False;
  SetStatusBar('', '', False);
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
  Cth.SetBtn(Bt_Ok, mybtGo, False, 'Сформировать отчет');
  Cth.SetBtn(Bt_Cancel, mybtCancel, False);
  Result := True;
end;

end.

