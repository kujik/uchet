{
Справочник планов по заказам (помесячно): суммы продажи/отгрузки по типам (розница/опт), с разбивкой на
изделия/доп.комплектацию/доставку/монтаж и итого, плюс блок производства (изделия/доп.комплектация с процентами).
Данные записываются в таблицу order_plans, по одной строке на месяц (dt = первое число месяца).
Вызывается из uFrmODrepFinByOrders.pas (кнопка "Планы", видимость по праву rOr_R_Plans).
}
unit uFrmODedtOrdersFinancePlans;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  DBCtrlsEh, Vcl.ExtCtrls, Vcl.Mask,
  uFrmBasicMdi, uData, uString
  ;

type
  TFrmODedtOrdersFinancePlans = class(TFrmBasicMdi)
    nedt_Sum1RI: TDBNumberEditEh;
    nedt_Sum1RA: TDBNumberEditEh;
    nedt_Sum1RD: TDBNumberEditEh;
    nedt_Sum1RM: TDBNumberEditEh;
    nedt_Sum1R_: TDBNumberEditEh;
    lbl11: TLabel;
    nedt_Sum1OI: TDBNumberEditEh;
    nedt_Sum1OA: TDBNumberEditEh;
    nedt_Sum1OD: TDBNumberEditEh;
    nedt_Sum1OM: TDBNumberEditEh;
    nedt_Sum1O_: TDBNumberEditEh;
    lbl1: TLabel;
    nedt_Sum2RI: TDBNumberEditEh;
    nedt_Sum2RA: TDBNumberEditEh;
    nedt_Sum2RD: TDBNumberEditEh;
    nedt_Sum2RM: TDBNumberEditEh;
    nedt_Sum2R_: TDBNumberEditEh;
    lbl2: TLabel;
    nedt_Sum2OI: TDBNumberEditEh;
    nedt_Sum2OA: TDBNumberEditEh;
    nedt_Sum2OD: TDBNumberEditEh;
    nedt_Sum2OM: TDBNumberEditEh;
    nedt_Sum2O_: TDBNumberEditEh;
    lbl3: TLabel;
    lbl4: TLabel;
    nedt_Prc3i: TDBNumberEditEh;
    lbl5: TLabel;
    nedt_Sum3A: TDBNumberEditEh;
    nedt_Prc3A: TDBNumberEditEh;
    nedt_Sum3i: TDBNumberEditEh;
    lbl_Caption: TLabel;
  private
    { Private declarations }
    FDtB: TDateTime;
    FIsEmptyRow: Boolean;
    FFields: TVarDynArray;
    procedure ControlOnChange(Sender: TObject); override;
    procedure VerifyBeforeSave; override;
    function Save: Boolean; override;
  public
    { Public declarations }
    function ShowDialog(AOwner: TObject; ADt: TDateTime): Boolean;
  end;

var
  FrmODedtOrdersFinancePlans: TFrmODedtOrdersFinancePlans;

implementation

{$R *.dfm}

uses
  DateUtils,
  uDBOra,
  uForms
  ;

function TFrmODedtOrdersFinancePlans.ShowDialog(AOwner: TObject; ADt: TDateTime): Boolean;
//см. также аналогичный исходный TDlg_R_Order_Plans.ShowDialog
var
  va1: TVarDynArray2;
  i: Integer;
  c: TComponent;
begin
  Result := False;
  FDtB := EncodeDate(YearOf(ADt), MonthOf(ADt), 1);
  FFields := [
    'dt$d',
    'sum1ri$i','sum1ra$i','sum1rd$i','sum1rm$i','sum1oi$i','sum1oa$i','sum1od$i','sum1om$i',
    'sum2ri$i','sum2ra$i','sum2rd$i','sum2rm$i','sum2oi$i','sum2oa$i','sum2od$i','sum2om$i',
    'sum3i$i','prc3i$f','sum3a$i','prc3a$f'
  ];
  PrepareCreatedForm(AOwner, Self.Name, '~Справочник планов по заказам', fEdit, Null, [], [myfoModal, myfoDialog, myfoDialogButtonsB]);
  lbl_Caption.Caption := IntToStr(YearOf(FDtB)) + ', ' + MonthsRu[MonthOf(FDtB)];
  va1 := Q.QLoad(Q.QGetSql('s', 'order_plans', A.Implode(FFields, ';')), [FDtB]);
  FIsEmptyRow := Length(va1) = 0;
  if FIsEmptyRow then begin
    SetLength(va1, 1);
    SetLength(va1[0], Length(FFields));
  end;
  for i := 0 to High(va1[0]) do begin
    c := Self.FindComponent('nedt_' + Copy(FFields[i], 1, Length(FFields[i]) - 2));
    if c <> nil then
      Cth.SetControlValue(TControl(c), va1[0][i]);
  end;
  Result := ShowModal = mrOk;
end;

procedure TFrmODedtOrdersFinancePlans.ControlOnChange(Sender: TObject);
//пересчет итоговых сумм при изменении любого из слагаемых (см. также исходный TDlg_R_Order_Plans.ControlChange).
//вызывается автоматически базовым классом при изменении любого контрола формы (см. TFrmBasicMdi.ControlOnChangeEvent)
begin
  nedt_Sum1R_.Value := nedt_Sum1RI.Value + nedt_Sum1RA.Value + nedt_Sum1RD.Value + nedt_Sum1RM.Value;
  nedt_Sum1O_.Value := nedt_Sum1OI.Value + nedt_Sum1OA.Value + nedt_Sum1OD.Value + nedt_Sum1OM.Value;
  nedt_Sum2R_.Value := nedt_Sum2RI.Value + nedt_Sum2RA.Value + nedt_Sum2RD.Value + nedt_Sum2RM.Value;
  nedt_Sum2O_.Value := nedt_Sum2OI.Value + nedt_Sum2OA.Value + nedt_Sum2OD.Value + nedt_Sum2OM.Value;
end;

procedure TFrmODedtOrdersFinancePlans.VerifyBeforeSave;
//проверка перед сохранением (см. TFrmBasicMdi.btnOkClick): все поля должны быть заполнены (не пусты и не 0),
//см. также исходный TDlg_R_Order_Plans.SaveData
var
  i: Integer;
  c: TComponent;
begin
  for i := 0 to High(FFields) do begin
    c := Self.FindComponent('nedt_' + Copy(FFields[i], 1, Length(FFields[i]) - 2));
    if (c <> nil) and ((S.NSt(TDBNumberEditEh(c).Value) = '') or (TDBNumberEditEh(c).Value = 0)) then begin
      FErrorMessage := 'Не все данные заполнены!';
      Exit;
    end;
  end;
end;

function TFrmODedtOrdersFinancePlans.Save: Boolean;
var
  i: Integer;
  c: TComponent;
  va: TVarDynArray;
begin
  SetLength(va, Length(FFields));
  for i := 0 to High(FFields) do begin
    c := Self.FindComponent('nedt_' + Copy(FFields[i], 1, Length(FFields[i]) - 2));
    if c <> nil then
      va[i] := TDBNumberEditEh(c).Value;
  end;
  va[0] := FDtB;
  Result := Q.QSave(S.IIfStr(FIsEmptyRow, 'i', 'u')[1], 'order_plans', '-', A.Implode(FFields, ';'), va) <> -1;
end;

end.
