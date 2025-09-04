unit uFrmOGrepSnHistory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmOGrepSnHistory = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
  public
  end;

var
  FrmOGrepSnHistory: TFrmOGrepSnHistory;

implementation

uses
  uWindows,
  uOrders,
  uPrintReport,
  D_Spl_InfoGrid,
  uFrmODedtNomenclFiles
;


{$R *.dfm}

function  TFrmOGrepSnHistory.PrepareForm: Boolean;
begin
  Caption := 'Состояние СН на дату';
  var va2: TVarDynArray2 := [
    ['id$i','_id','40'],
    ['dt$d','Дата','120'],
    ['state$s','Статус','120'],
    ['supplierinfo$s','Основной поставщик','150'],
    ['qnta0$f','Текущий остаток|ПЩ','60'],
    ['qnta1$f','Текущий остаток|И','60'],
    ['qnta2$f','Текущий остаток|ДМ','60'],
    ['qnt$f','Текущий остаток|Всего','60'],
    ['rezerva0$f','Текущий резерв|ПЩ','40'],
    ['rezerva1$f','Текущий резерв|И','40'],
    ['rezerva2$f','Текущий резерв|ДМ','40'],
    ['rezerv$f','Текущий резерв|Всего','40'],
    ['qnt_onway$f','В пути','40'],
    ['qnt_in_processing$f','В обработке','40'],
    ['planned_need_days$i','Период закупки','40','t=3'],
    ['qnt_order$f','Заказ|Кол-ко','60','t=3'],
    ['to_order$i','Заказ|В заявку','40', 'chb','t=3'],
    ['need$f','Потребность|Мин.','60'],
    ['need_p$f','Потребность|Плановая','60'],
    ['price_check$f','Стоимость|Контрольная цена','60'],
    ['price_main$f','Стоимость|Цена','60'],
    ['qnt_pl1$f','Плановый резерв|1''60'],
    ['qnt_pl2$f','Плановый резерв|2''60'],
    ['qnt_pl3$f','Плановый резерв|3''60'],
    ['qnt_pl$f', 'Плановый резерв|Всего','60']
  ];
  Frg1.Opt.SetFields([['name','Наименование','300;h'], ['name_unit$s','Ед.изм.','100']] + va2);
  Frg1.Opt.SetTable('v_spl_history', '', 'id');
  Frg2.Opt.SetFields(va2);
  Frg2.Opt.SetTable('spl_history');
  Frg2.Opt.SetWhere('where id = :id$i');
  Frg2.Opt.Caption := 'История по номенклатуре';
  //01-02-2025 00:10:25 Заказ
  Q.QSetContextValue('spl_history_date', IncSecond(EncodeDateTime(
    StrToInt(Copy(AddParam, 7, 4)), StrToInt(Copy(AddParam, 4, 2)), StrToInt(Copy(AddParam, 1, 2)),
    StrToInt(Copy(AddParam, 12, 2)), StrToInt(Copy(AddParam, 15, 2)), StrToInt(Copy(AddParam, 18, 2)), 0
  )));
  Result := Inherited;
end;

procedure TFrmOGrepSnHistory.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
  i: Integer;
  st: string;
  AddParamD: Variant;
  AddParamAr: tVarDynArray;
  rx1: TRegEx;
begin
  inherited;
  AddParamAr:= [Fr.GetValue('name'), Fr.GetValue('name_unit')];
  AddParamD:= VararrayOf(AddParamAr);
  if Fr.CurrField = 'supplierinfo' then begin
    Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView), Fr.ID, AddParamD);
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
(*  if TRegEx.IsMatch(Fr.CurrField, '^qnt[0-9]{1}$') then begin
    AddParamD:= VararrayOf(AddParamAr + [FDays[StrtoInt(Fr.CurrField[4])]]);
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_Consumption, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if TRegEx.IsMatch(Fr.CurrField, '^qnti[0-9]{1}$') then begin
    AddParamD:= VararrayOf(AddParamAr + [FDays[StrtoInt(Fr.CurrField[5])]]);
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_Incoming, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;*)
  if TRegEx.IsMatch(Fr.CurrField, '^qnt_pl[1-3]{1}$') then begin
    AddParamD[1] := -S.NNum(Copy(Fr.CurrField, 7, 1));
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_PlannedOrders, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
{  if Fr.CurrField = 'has_files' then begin
    TFrmODedtNomenclFiles.ShowDialog(Self, Fr.ID);
  end;}
end;

procedure TFrmOGrepSnHistory.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id$i', [Frg1.ID]);
end;

end.
