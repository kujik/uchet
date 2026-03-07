unit uFrmOGjrnProdCalculations;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uData, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uNamedArr
  ;

type
  TFrmOGjrnProdCalculations = class(TFrmBasicGrid2)
  private
    FIdCopyedItem: Integer;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
  public
  end;

var
  FrmOGjrnProdCalculations: TFrmOGjrnProdCalculations;

implementation

uses
  uSys,
  uForms,
  uDBOra,
  uString,
  uMessages,
  uWindows,
  uFrmBasicInput
  ;


{$R *.dfm}

function TFrmOGjrnProdCalculations.PrepareForm: Boolean;
var
  c : TComponent;
  va2: TVarDynArray2;
begin
  Caption:='Журнал просчетов';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogRowDetailPanel, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','d=40'],
    ['dt','Дата','80'],
    ['manager','Менеджер','120'],
    ['customer','Клиент','200'],
    ['project','Проект','200'],
    ['comm','Комментарий','200']
  ]);
  Frg1.Opt.SetTable('v_prod_calc');
  Frg1.Opt.SetButtons(1, 'raedfs', User.Role(rOr_J_ProdCalculations_Ch));
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_prod_calc$i','_id_parent','40'],
    ['name','Изделие','300;h'],
    ['purchase_sum','Общая сумма закупки','100','f=r'],
    ['markup_percent','Запас цены, %','100','f=r'],
    ['overall_coeff','Общие коэффициент','100','f=r'],
    ['sales_sum','Сумма продажи','100','f=r'],
    ['sales_sum_from_items','Сумма продажи по расчету','100','f=r'],
    ['coeff_from_items','Коэффициент по расчету','100','f=r']
//    ['comm$s','Комментарий','200']
//    ['','',''],
  ]);
  Frg2.Opt.SetTable('v_prod_calc_items');
  Frg2.Opt.SetWhere('where id_prod_calc = :id_prod_calc$i order by name');
  Frg2.Opt.SetButtons(1, [
    [mbtRefresh], [], [mbtView], [mbtEdit, User.Role(rOr_J_ProdCalculations_Ch)], [mbtAdd, 1], [mbtCopy, 1], [mbtToClipboard, 1], [mbtFromClipboard, 1], [mbtDelete, 1], [], [mbtGridSettings]
  ]);
  Frg2.Opt.SetButtonsIfEmpty([mbtFromClipboard]);
  Frg1.InfoArray:=[
    [Caption + '.'#13#10]
  ];

  Result := inherited;
end;

procedure TFrmOGjrnProdCalculations.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  if fMode <> fNone then begin
    TFrmBasicInput.ShowDialogDB3(Self, '', [dbioStatusBar, dbioSizeable], fMode, Fr.ID, 'prod_calc', 'Просчет', 500, 80, [
      ['id_manager$i', cntNEdit, '-', ''],
      ['dt$d', cntDEdit, '-', ''],
      ['customer$s', cntComboE, 'Клиент','1:400'],
      ['project$s', cntComboE, 'Проект','1:400'],
      ['comm$s', cntEdit, 'Комментарий','0:400']],
      [S.IIf(fMode = fAdd, User.GetId, #0), S.IIf(fMode = fAdd, Date, #0), #0, #0, #0],
      ['select distinct customer from prod_calc order by customer',
       'select project customer from prod_calc order by project'],
      [['caption dlgedit']]
    );
{
TFrmBasicInput.ShowDialogDB3(Self, '', [dbioStatusBar, dbioSizeable], fMode, Fr.ID, 'prod_calc', 'Просчет', 500, 80, [
  ['dt$s', cntComboE, ' Дата','1:400', 1],
  ['id_manager$s', cntComboLK, ' Менеджер','1:400', 1],
  ['customer$s', cntComboE, 'Клиент','1:400', 1],
  ['project$s', cntComboE, 'Проект','1:400', 1],
  ['comm$s', cntEdit, 'Комментарий','0:400', 1]],
  ['select trunc(sysdate) from dual',
   S.IIf(fMode = fAdd, 'select name, id from adm_users where id = ' + IntToStr(User.GetId),  'select name, id from adm_users where name = ''' + Fr.GetValueS('manager') + ''''),
   'select distinct customer from prod_calc order by customer',
   'select project customer from prod_calc order by project'],
  [['caption dlgedit']]
);
}
  end
  else begin
    Handled := False;
    inherited;
  end;
end;

procedure TFrmOGjrnProdCalculations.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if fMode <> fNone then
    Wh.ExecDialog(myfrm_Dlg_ProdCalculation, Fr, [], fMode, Fr.ID, Frg1.ID)
  else if Tag = mbtToClipboard then begin
    if MyQuestionMessage('Скопировать изделий в буфер?') <> mrYes then
      Exit;
    FIdCopyedItem := Fr.ID;
  end
  else if Tag = mbtFromClipboard then begin
    if FIdCopyedItem = 0 then
      MyInfoMessage('Буфер пуст!')
    else begin
      var va := Q.QSelectOneRow('select id, id_prod_calc, customer, project, name from v_prod_calc_items where id = :id$i', [FIdCopyedItem]);
      if va[0] = null then
        Exit;
      if MyQuestionMessage(
        'Будет создана копия изделия:'#13#10#13#10 + va[2].AsString + #13#10 + va[3].AsString + #13#10 + va[4].AsString + #13#10#13#10 + 'Продолжить?'
      ) <> mrYes then
        Exit;
      Wh.ExecDialog(myfrm_Dlg_ProdCalculation, Fr, [], fCopy, va[0], va[1]);
    end;
  end;
  inherited;
end;

procedure TFrmOGjrnProdCalculations.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_prod_calc$i', [Frg1.ID]);
  Fr.Opt.Caption := 'Просчет (' + Frg1.GetValueS('customer') + ' - ' +  Frg1.GetValueS('project') + ')';
end;


end.


