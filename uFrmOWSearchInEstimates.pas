{
поиск сметной позиции в сметах стандартныых изделий и заказов,
полного значений, или по маске в нотации оракла.
по даблклику переход в смету.
}
unit uFrmOWSearchInEstimates;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, ClipBrd, Vcl.ComCtrls, MemTableEh,
  uLabelColors, uFrmBasicMdi, uFrDBGridEh, uData, uForms, uString
  ;

type
  TFrmOWSearchInEstimates = class(TFrmBasicMdi)
    edt_name: TDBEditEh;
    chbInclosedOrders: TCheckBox;
    chbLike: TCheckBox;
    pgcResults: TPageControl;
    tsStdItems: TTabSheet;
    tsOrderItems: TTabSheet;
    Frg1: TFrDBGridEh;
    Frg2: TFrDBGridEh;
    procedure FormCreate(Sender: TObject);
  private
    function  Prepare: Boolean; override;
    procedure btnClick(Sender: TObject); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
    procedure Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
  public
  end;

var
  FrmOWSearchInEstimates: TFrmOWSearchInEstimates;

implementation

uses
  uOrders,
  uWindows
  ;


{$R *.dfm}

procedure TFrmOWSearchInEstimates.FormCreate(Sender: TObject);
begin
  inherited;
{  //переключим выравнивание у фреймов (а в дизайнтайме нужно поставить alNone), иначе их размеры съезжают
  exit;
  Frg1.Align := alNone;
  Frg1.Align := alClient;
  Frg2.Align := alNone;
  Frg2.Align := alClient;}
end;

function  TFrmOWSearchInEstimates.Prepare: Boolean;
begin
  Result := False;
  Mode := fView;
  Caption := '~Поиск сметной позиции';
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(pnlFrmClient, []);
  FOpt.DlgButtonsR:=[[mbtFind, True, 'Найти']];
  FOpt.StatusBarMode:=stbmNone;
  //грид стандартных изделий
  Frg1.Options := FrDBGridOptionDef + [myogPrintGrid, myogPanelFind];
  Frg1.Opt.SetFields([
    ['id_std_item$i', '_id_std_item', '40'],
    ['id_estimate$i', '_id_estimate', '40'],
    ['formatname$s', 'Формат', '120;w','bt=Просмотреть смету:29'],
    ['stdname$s', 'Стандартное изделие', '300;w','bt=Загрузить смету:28', User.Role(rOr_R_StdItems_Estimate)]
  ]);
  Frg1.SetInitData([], '');
  Frg1.OnCellButtonClick := Frg1CellButtonClick;
  Frg1.Prepare;
  Frg1.RefreshGrid;
  //грид заказов
  Frg2.Options := FrDBGridOptionDef + [myogPrintGrid, myogPanelFind];
  Frg2.Opt.SetFields([
    ['id_order_item$i', '_id_order_item', '40'],
    ['id_estimate$i', '_id_estimate', '40'],
    ['slash$s', 'Заказ', '120;w','bt=Просмотреть смету:29'],
    ['itemname$s', 'Изделие', '300;w','bt=Загрузить смету:28', User.Role(rOr_D_Order_Estimate)],
    ['std$i', 'Стд.', '60', 'pic'],
    ['end$i', 'Закр.', '60', 'pic']
  ]);
  Frg2.SetInitData([], '');
  Frg2.OnCellButtonClick := Frg2CellButtonClick;
  Frg2.Prepare;
  Frg2.RefreshGrid;
  //не дает результата - гриды съезжают, правим при показе формы
  FOpt.ControlsWoAligment := [Frg1, Frg2];
//  pgcResults.ActivePageIndex := 0;
  //минимальные размеры формы (высота явно, ширина определяется панелью кнопок)
  FWHBounds.Y:= 400;
  FWHBounds.X:=500;
  //подсказка
  FOpt.InfoArray:=[[
    'Поиск наименования в сметах.'#13#10+
    ''#13#10+
    'Введите наименование, которое вы хотите найти,'#13#10+
    'и нажмите кнопку "Старт" для поиска.'#13#10+
    ''#13#10+
    'Поиск будет произведен в сметах стандарнтных изделий, и в сметах по изделиям заказов,'#13#10+
    '(как в сметах стандартных, так и нестандартных изделий)'#13#10+
    'результаты отобразатся в соответствующих вкладках.'#13#10+
    ''#13#10+
    'Для поиска позиции в сметх заказов, которые уже закрыты, необходимо поставить соотвествующую галочку'#13#10+
    '(иначе ищет только в незавершенных заказах)'#13#10+
    ''#13#10+
    'Если не установлена галочка "Искать по маске", то позиции в сметах ищутся по полному совпадению со строкой.'#13#10+
    'Если же эта галочка установлена, то можно использовать символы подстановки для поиска.'#13#10+
    'Симовол "_" означает любой символ в искомой строке, а "%" - любое количество либых символов.'#13#10+
    'Важно: если символов подстановки нет, то ищется целая строка, а не эта подстрока!'#13#10+
    'Также, в этом случае поиск производится без учета регистра букв.'#13#10+
    '(например, строку поиска можно записать так: %лдсп% (будут найдены все строки с вхождением "ЛДСП"), или изделие__ ) '#13#10+
    'или так: изделие__  (будут найдены "Изделие12", "изделие S")'#13#10+
    ''#13#10+
    'В найденных данных по двойному клику в таблице на столбце "Изделие" (или "Стандартное изделий).'#13#10+
    'будет открыт редактор сметы (если у вас есть права доступа, и если заказ, в котором найдена позиция, не завершен).'#13#10+
    'По двойному клику в в других столбцах откроется просмотр сметы.'
  ]];
  Result := True;
end;

procedure TFrmOWSearchInEstimates.btnClick(Sender: TObject);
var
  Wherest: string;
begin
  if TControl(Sender).Tag = mbtFind then begin
    if edt_name.Text = '' then
      Exit;
    Wherest:= S.IIf(chbLike.Checked, 'upper(bcadname) like upper(:name)', 'bcadname = :name');
    Frg1.LoadData(
      'select id_std_item, id_estimate, formatname, stdname from v_findinestimate_std where ' + wherest + ' order by formatname, stdname',
      [edt_name.Text]
    );
    Frg2.LoadData(
      'select id_order_item, id_estimate, slash, itemname, std, nvl2(dt_end, 1, 0) as end from v_findinestimate_inorders where ' +
      Wherest +
      S.IIf(not chbInclosedOrders.Checked, ' and dt_end is null ', ' ') +
      ' order by slash, itemname',
      [edt_name.Text]
    );
  end;
end;

procedure TFrmOWSearchInEstimates.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  //для стандартного изделия
  if TCellButtonEh(Sender).Hint = 'Загрузить смету'  then begin
    Orders.LoadBcadGroups(True);
    Orders.LoadEstimate(null, null, Frg1.GetValueI('id_std_item'))
  end
  else
    Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([null, Frg1.GetValueI('id_std_item')]));
end;

procedure TFrmOWSearchInEstimates.Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  //для изделия в заказе (редактор только для нестандартного изделия)
  if TCellButtonEh(Sender).Hint = 'Загрузить смету'  then begin
    Orders.LoadBcadGroups(True);
    Orders.LoadEstimate(null, Frg2.GetValueI('id_order_item'), null)
  end
  else
    Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([Frg2.GetValueI('id_order_item'), null]));
end;

end.

{
размер формы в дизайнтайм должен быть меньше чем минимально допустимые ее размеры, иначе съезжают грниды!!!
}