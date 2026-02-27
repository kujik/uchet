unit uFrmOGjrnProdCalculations;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uData, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGjrnProdCalculations = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
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
    ['name','Изделие','200'],
    ['price','Цена','100'],
    ['comm$s','Комментарий','200']
//    ['','',''],
  ]);
  Frg2.Opt.SetTable('v_prod_calc_items');
  Frg2.Opt.SetWhere('where id_order = :id_order$i and qnt > 0 order by slash');
  Frg2.Opt.SetButtons(1, [
    [mbtRefresh], [], [mbtView], [mbtEdit, User.Role(rOr_J_ProdCalculations_Ch)], [mbtAdd, 1], [mbtCopy, 1], [mbtToClipboard, 1], [mbtFromClipboard, 1], [mbtDelete, 1], [], [mbtGridSettings]
  ]);

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
      ['id_manager$i', cntNEdit, ' -', ''],
      ['dt$d', cntDEdit, ' -', ''],
      ['customer$s', cntComboE, 'Клиент','1:400'],
      ['project$s', cntComboE, 'Проект','1:400'],
      ['comm$s', cntEdit, 'Комментарий','0:400']],
//      [S.IIf(fMode = fAdd, User.GetId, #1), S.IIf(fMode = fAdd, Date, #1), #1, #1, #1],
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


end.


