{
таблица подробной информации по различным параметрам для отчета Состояние СГП по стандартным изделиям
}
unit uFrmOGinfSgp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uLabelColors
  ;

type
  TFrmOGinfSgp = class(TFrmBasicGrid2)
    lblCaption: TLabel;
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
  public
  end;

var
  FrmOGinfSgp: TFrmOGinfSgp;

implementation

uses
  uWindows
  ;

{$R *.dfm}

function TFrmOGinfSgp.PrepareForm: Boolean;
var
  i, j: integer;
  va: TVarDynArray;
  FldDef: TVarDynArray2;
begin
  Mode := fView;
  FOpt.DlgPanelStyle := dpsBottomRight;
  //заголовок формы
  Caption := S.Decode([
     FormDoc,
     myfrm_Dlg_Sgp_InfoGrid_PspSell, 'Отгрузочные паспорта по изделию.',
     myfrm_Dlg_Sgp_InfoGrid_PspProd, 'Производственные паспорта по изделию.',
     myfrm_Dlg_Sgp_InfoGrid_Shipped, 'Отгрузка изделия с СГП.',
     myfrm_Dlg_Sgp_InfoGrid_Registered, 'Приемка изделия на СГП.',
     myfrm_Dlg_Sgp_InfoGrid_Shipped_Plan, 'Отгрузка планируемая.',
     myfrm_Dlg_Sgp_InfoGrid_In_Prod, 'В производстве.',
     myfrm_Dlg_Sgp_InfoGrid_Move, 'Движение по изделию.',
     'Информация'
  ]);
  //заголовочный лейбл - наименование выбранного для детализации изделия
  va:= Q.QSelectOneRow('select slash, name from v_sgp_sell_items where id = :id$i', [ID]);
  lblCaption.SetCaption2('$FF0000 ' + S.NSt(va[0]) + ' $000000 ' + S.NSt(va[1]));

  FldDef := [
    ['id_order','_id','40'],
    ['dt_end','_dt_end','40'],
    ['slash','Заказ','120;w','bt=Паспорт'],
    ['dt_beg','Оформлен','75'],
    ['dt_otgr','Отгрузка план','75']
  ];
  Frg1.Opt.SetWhere('where id = :id$i order by dt_beg desc');

  if FormDoc = myfrm_Dlg_Sgp_InfoGrid_PspSell then begin
    //информация по отгрузочным паспортам, когда-либо оформелнным по данной позиции
    Frg1.Opt.SetFields(FldDef + [
      ['qnt','Кол-во','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_by_psp_sell_list');
    Frg1.InfoArray:=[];
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_PspProd then begin
    //информация по производственным паспортам, когда-либо оформелнным по данной позиции
    Frg1.Opt.SetFields(FldDef + [
      ['qnt','Кол-во','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_by_psp_prod_list');
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_Shipped then begin
    //информация по отгрузке с сгп
    Frg1.Opt.SetFields(FldDef + [
      ['dt','Отгрузка факт','75'],
      ['qnt','Кол-во','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_shipped_list');
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_Shipped_Plan then begin
    //информация по запланированным отгрузкам
    //разница по слешам между количеством в заказке и отгруженным количеством
    //(если в заказе не ноль и эти количества не одинаковые)
    Frg1.Opt.SetFields(FldDef + [
      ['qnt','Кол-во','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_shipped_plan_list');
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_Registered then begin
    //информация по приемке на сгп
    Frg1.Opt.SetFields(FldDef + [
      ['dt','Дата приемки','75'],
      ['qnt','Кол-во','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_registered_list');
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_In_Prod then begin
    //информация по изделиям В производстве
    Frg1.Opt.SetFields(FldDef + [
      ['qnt_in_order','Кол-во всего','75'],
      ['qnt','Кол-во в производстве','75','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_in_prod_list');
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_Move then begin
    //информация общая по движению изделия
    Frg1.Opt.SetFields([
      ['id_order','_id','40'],
      ['dt_end','_dt_end','40'],
      ['doctype','Вид документа','130;w'],
      ['slash','Документ','120;w','bt=Паспорт'],
      ['dt_beg','Оформлен','75'],
      ['dt_otgr','Отгрузка план','75'],
      ['dt','Дата приемки','75'],
      ['qnt','Кол-во','75','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_move_list');
    Frg1.Opt.SetWhere('where id = :id$i order by dt_beg desc, id_order desc');
  end;
  Result := Inherited;
end;

procedure TFrmOGinfSgp.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//клик по кнопке в ячейке
var
  IdOrder: Variant;
begin
  //выйдем при пустой таблице
  if Fr.IsEmpty then
    Exit;
  //получим айди заказа в учете
  IdOrder := null;
  if Fr.DBGridEh1.FindFieldColumn('id_order') <> nil then
    IdOrder := Fr.GetValue('id_order');
  if (Fr.DBGridEh1.FindFieldColumn('doctype') <> nil) and (Pos('паспорт', Fr.GetValueS('doctype')) = 0) then
    IdOrder := null;
  //откроем паспотр заказа или смету
  if IdOrder <> null then
    if TCellButtonEh(Sender).Hint = 'Паспорт' then
      Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, IdOrder, null);
end;

procedure TFrmOGinfSgp.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id$i', [ID]);
end;


end.
