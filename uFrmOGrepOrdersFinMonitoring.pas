unit uFrmOGrepOrdersFinMonitoring;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrDBGridEh
  ;

type
  TFrmOGrepOrdersFinMonitoring = class(TFrmBasicMdi)
    pgcMain: TPageControl;
    tsStartedOrders: TTabSheet;
    FrgStartedOrders: TFrDBGridEh;
    tsAllEstimatesLoaded: TTabSheet;
    FrgAllEstimatesLoaded: TFrDBGridEh;
    tsOrdersInPeriod: TTabSheet;
    FrgOrdersInPeriod: TFrDBGridEh;
    tsSelectedOrder: TTabSheet;
    FrgSelectedOrder: TFrDBGridEh;
  private
    function Prepare: Boolean; override;
    function PrepareFrg(Frg: TFrDBGridEh): Boolean;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); virtual;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); virtual;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); virtual;
  public
  end;

var
  FrmOGrepOrdersFinMonitoring: TFrmOGrepOrdersFinMonitoring;

implementation

uses
  uDBOra, uWindows;

{$R *.dfm}

function TFrmOGrepOrdersFinMonitoring.Prepare: Boolean;
begin
  Result := False;
  Caption := '~Финансовый отчет по изделиям в заказах';
  if not PrepareFrg(FrgStartedOrders) or not PrepareFrg(FrgAllEstimatesLoaded) or not PrepareFrg(FrgOrdersInPeriod) or not PrepareFrg(FrgSelectedOrder) then
    Exit;
  pgcMain.TabIndex := 0;
  Result := True;
end;

function TFrmOGrepOrdersFinMonitoring.PrepareFrg(Frg: TFrDBGridEh): Boolean;
var
  Fields: TVarDynArray2;
begin
  Result := False;
  Fields := [
    ['rownum$i', '№', '20'],
    ['item_wo_estimate$s', 'Нет сметы', '60', 'pic=1:6'],
    ['ornums$s', 'Заказы', '200;h'],
    ['dt_beg$s', 'Дата запуска', '80', 'i', not A.InArray(Frg.Name, ['FrgStartedOrders', 'FrgAllEstimatesLoaded', 'FrgSelectedOrder'])],
    ['customer$s', 'Покупатели', '200;h'],
    ['fullname$s', 'Изделие', '500;h'],
    ['qnt$i', 'Количество', '80'],
    ['price_std$i', 'Цена по справочнику без НДС', '80', 'r'],
    ['price$i', 'Цена продажи без НДС', '80', 'r'],
    ['price_diff$i', 'Занижение цены без НДС', '80', 'r'],
    ['summ$i', 'Сумма продажи без НДС', '80', 'f=#:', 's', 'r'],
    ['priceraw_wo_nds$i', 'Себестоимость по смете, за шт., без НДС', '80', 's', 'r'],
    ['sum0$i', 'Себестоимость по смете, сумма без НДС', '80', 'f=#:', 's', 'r'],
    ['sum0_percent$i', '%', '80', 'r'],
    ['labor_cost_0$i', 'Трудозатраты по ПЩ', 'f=#:', '80', 's', 'r'],
    ['labor_cost_0_percent$i', '80', '%', 'r'],
    ['labor_cost_2$i', 'Трудозатраты по ЛОК', '80', 'f=#:', 's', 'r'],
    ['labor_cost_2_percent$i', '%', '80', 'f=#:', 'r'],
    ['prime_cost$i', 'Затраты всего, сумма', '80', 'f=#:', 's', 'r', 'b'],
    ['prime_cost_percent$i', 'Затраты всего, %', '80', 'r']
  ];
  Frg.Options:= FrDBGridOptionDef + FrDBGridOptionRefDef + [myogLoadAfterVisible];
  Frg.Opt.SetFields(Fields);
  if A.InArray(Frg.Name, ['FrgStartedOrders', 'FrgAllEstimatesLoaded']) then begin
    Frg.Opt.SetWhere('where data_type = :data_type$i and order_type = :order_type$i and dt_beg >= :dt_beg$d and dt_beg <= :dt_end$d');
    Frg.Opt.SetTable('orders_fin_monitoring');
  end
  else begin
    Frg.Opt.SetTable('temp_orders_fin_monitoring');
    Frg.Opt.SetWhere('where data_type = :data_type$i');
  end;
  Frg.Opt.SetButtons(1, [[mbtGo], [mbtGridSettings], [mbtExcel], [], [mbtCtlPanel], [], [mbtCtlPanel]]);
  Frg.Opt.SetButtonsIfEmpty([mbtGo]);
  if not A.InArray(Frg.Name, ['FrgSelectedOrder']) then begin
    Frg.CreateAddControls('1', cntCheck, 'Производственные', 'ChbP', '', 4, yrefT, 120, -2);
    Frg.CreateAddControls('1', cntCheck, 'Отгрузочные', 'ChbO', '', 4, yrefB, 120, -3);
  end;
  if A.InArray(Frg.Name, ['FrgStartedOrders', 'FrgAllEstimatesLoaded', 'FrgOrdersInPeriod']) then begin
    Frg.CreateAddControls('2', cntDTEdit, 'С', 'dteBeg', '', 15, yrefC, 80);
    Frg.CreateAddControls('2', cntDTEdit, 'По', 'dteEnd', '', 15 + 80 + 25, yrefC, 80);
  end;
  if A.InArray(Frg.Name, ['FrgStartedOrders', 'FrgAllEstimatesLoaded']) then begin
    Frg.CreateAddControls('2', cntCheck, 'Один день', 'chbOneDay', '', 15 + 80 + 25 + 80 + 10, yrefC, 90);
  end;
  if A.InArray(Frg.Name, ['FrgOrdersInPeriod']) then begin
    Frg.CreateAddControls('2', cntCheck, 'Только незакрытые', 'chbIncompleted', '', 15 + 80 + 25 + 80 + 10, yrefC, 150);
  end;
  Frg.OnButtonClick := Frg1ButtonClick;
  Frg.OnCellButtonClick := Frg1CellButtonClick;
  Frg.OnSetSqlParams := Frg1OnSetSqlParams;
  Frg.OnAddControlChange := Frg1AddControlChange;
  Frg.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;
  Frg.Prepare;
  if A.InArray(Frg.Name, ['FrgStartedOrders', 'FrgAllEstimatesLoaded']) then
    Frg.RefreshGrid;
  Result := True;
end;

procedure TFrmOGrepOrdersFinMonitoring.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  dtb, dte: TDateTime;
begin
  Handled := False;
  if Tag = mbtGo then begin
    if Fr = FrgOrdersInPeriod then begin
      if MyQuestionMessage('Получение данных можжет занять длительное время'#13#10'Продолжить?') <> mrYes then
        Exit;
      dtb := S.IIf(Fr.GetControlValue('dteBeg', True, True) = null, Date, Fr.GetControlValue('dteBeg', True, True));
      dte := S.IIf(Fr.GetControlValue('dteEnd', True, True) = null, dtb, Fr.GetControlValue('dteEnd', True, True));
      Q.QCallStoredProc(
        'p_insert_fin_monitoring_data',
        'p1;p2;p3;p_id_order$i;p_dt_beg_from$d;p_dt_beg_to$d;p_filter_dt_end_zero$i',
        [null, null, null, null, dtb, dte, Fr.GetControlValue('chbIncompleted')]
      );
    end
    else if Fr = FrgSelectedOrder then begin
      Wh.ExecReference(myfrm_J_Orders_SEL, Self, [myfoDialog, myfoModal], 0);
      if Length(Wh.SelectDialogResult) = 0 then
        Exit;
      if MyQuestionMessage('Получение данных можжет занять длительное время'#13#10'Продолжить?') <> mrYes then
        Exit;
      Q.QCallStoredProc(
        'p_insert_fin_monitoring_data',
        'p1;p2;p3;p_id_order$i;p_dt_beg_from$d;p_dt_beg_to$d;p_filter_dt_end_zero$i',
        [null, null, null, Wh.SelectDialogResult[0], null, null, null]
      );
    end;
    Fr.RefreshGrid;
  end;
end;

procedure TFrmOGrepOrdersFinMonitoring.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmOGrepOrdersFinMonitoring.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
var
  dtb, dte: TDateTime;
  st: string;
begin
  dtb := S.IIf(Fr.GetControlValue('dteBeg', True, True) = null, Date, Fr.GetControlValue('dteBeg', True, True));
  dte := S.IIf(Fr.GetControlValue('dteEnd', True, True) = null, dtb, Fr.GetControlValue('dteEnd', True, True));
  Fr.SetSqlParameters(
    'data_type$i;order_type$i;dt_beg$d;dt_end$d', [
      S.DecodeBool([Fr = FrgStartedOrders, 1, Fr = FrgAllEstimatesLoaded , 2, Fr = FrgSelectedOrder, 3, 4]),
      S.IIf(Fr.GetControlValue('chbO') = 1, 0, -1),
      dtb,
      dte
    ]);
  st := TTabSheet(Fr.Parent).Caption;
  if A.InArray(Fr.Name, ['FrgStartedOrders', 'FrgAllEstimatesLoaded']) then begin
    st := st + S.IIf(dtb = dte, ' за ', ' с ') + DateToStr(dtb) + S.IIfStr(dtb <> dte, ' по ' + DateToStr(dte));
  end;
  //Fr.SetStatusBarCaption(st);
  Fr.Opt.Caption := st;
end;

procedure TFrmOGrepOrdersFinMonitoring.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if (Fr.FindComponent('chbOneDay') <> nil) and (Fr.FindComponent('dteBeg') <> nil) then
    try
      if Fr.GetControlValue('chbOneDay') = 1 then
        Fr.SetControlValue('dteEnd', Fr.GetControlValue('dteBeg', True, True));
    except
    end;
  if A.InArray(Fr.Name, ['FrgStartedOrders', 'FrgAllEstimatesLoaded']) then
    Fr.RefreshGrid;
end;

procedure TFrmOGrepOrdersFinMonitoring.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin

end;


end.