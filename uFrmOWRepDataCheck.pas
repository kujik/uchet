{
отчет по проблемам в БД (несоответствия наименований изделий/полуфабрикатов/нестандартных изделий, смет,
bcad_nomencl и итм) - см. SQL/d_orders_check.sql, вьюхи v_orders_check1..v_orders_check10

каждая вкладка - "Проблема N", под заголовком мемо с описанием проблемы, под ним грид по соответствующей вьюхе.
для проблем 1-6 (связаны со стандартными изделиями/сметами) в гриде есть кнопки вызова редактора стандартного
изделия и просмотра сметы изделия - по одной или по две пары кнопок, в зависимости от того, сколько изделий
участвует в строке проблемы.
для проблем 7-10 (bcad_nomencl / итм) кнопки открытия редактора пока не заведены - решение, что именно открывать
(справочник bcad_nomencl целиком / редактор конкретной позиции итм), еще не согласовано.

набор проверок черновой, вьюхи и состав полей еще будут дорабатываться.
}

unit uFrmOWRepDataCheck;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls, uFrDBGridEh, uString, uData;

type
  TFrmOWRepDataCheck = class(TFrmBasicMdi)
    pgcMain: TPageControl;
    tsCheck1: TTabSheet;
    tsCheck2: TTabSheet;
    tsCheck3: TTabSheet;
    tsCheck4: TTabSheet;
    tsCheck5: TTabSheet;
    tsCheck6: TTabSheet;
    tsCheck7: TTabSheet;
    tsCheck8: TTabSheet;
    tsCheck9: TTabSheet;
    tsCheck10: TTabSheet;
    mmoDesc1: TMemo;
    mmoDesc2: TMemo;
    mmoDesc3: TMemo;
    mmoDesc4: TMemo;
    mmoDesc5: TMemo;
    mmoDesc6: TMemo;
    mmoDesc7: TMemo;
    mmoDesc8: TMemo;
    mmoDesc9: TMemo;
    mmoDesc10: TMemo;
    FrgCheck1: TFrDBGridEh;
    FrgCheck2: TFrDBGridEh;
    FrgCheck3: TFrDBGridEh;
    FrgCheck4: TFrDBGridEh;
    FrgCheck5: TFrDBGridEh;
    FrgCheck6: TFrDBGridEh;
    FrgCheck7: TFrDBGridEh;
    FrgCheck8: TFrDBGridEh;
    FrgCheck9: TFrDBGridEh;
    FrgCheck10: TFrDBGridEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    function Prepare: Boolean; override;
    //для проблем 1-6: имя поля с id стандартного изделия (первое/единственное и, если есть, второе изделие в строке)
    function GetItemField1(Fr: TFrDBGridEh): string;
    function GetItemField2(Fr: TFrDBGridEh): string;
    //общий обработчик кнопок для всех 10 гридов - используется вместе с GetItemField1/2, чтобы не дублировать
    //код кнопок "Открыть изделие"/"Смета изделия" в каждом гриде отдельно
    procedure FrgCheckButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
  public
    { Public declarations }
  end;

var
  FrmOWRepDataCheck: TFrmOWRepDataCheck;

implementation

{$R *.dfm}

uses

  uSettings,
  uForms,
  uMessages,
  uWindows,
  uOrders
  ;


function TFrmOWRepDataCheck.GetItemField1(Fr: TFrDBGridEh): string;
begin
  if Fr = FrgCheck1 then Result := 'id'
  else if Fr = FrgCheck2 then Result := 'id_semiproduct'
  else if Fr = FrgCheck3 then Result := 'id_item'
  else if Fr = FrgCheck4 then Result := 'id_shipment_item'
  else if Fr = FrgCheck5 then Result := 'id_shipment_item'
  else if Fr = FrgCheck6 then Result := 'id_nonstandard_item'
  else Result := '';
end;

function TFrmOWRepDataCheck.GetItemField2(Fr: TFrDBGridEh): string;
begin
  if Fr = FrgCheck2 then Result := 'id_nonstandard'
  else if Fr = FrgCheck3 then Result := 'id_target'
  else if Fr = FrgCheck5 then Result := 'id_production_item'
  else Result := '';
end;

procedure TFrmOWRepDataCheck.FrgCheckButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  LField: string;
  LId: Variant;
begin
  if Tag = mbtRefresh then begin
    Handled := True;
    Fr.RefreshGrid;
  end
  else if (Tag = mbtCustom_DataCheck_OpenItem) or (Tag = mbtCustom_DataCheck_ViewEstimate) then begin
    Handled := True;
    if Fr.GetCount(False) = 0 then Exit;
    LField := GetItemField1(Fr);
    if LField = '' then Exit;
    LId := Fr.GetValue(LField);
    if VarIsNull(LId) then Exit;
    try
    if Tag = mbtCustom_DataCheck_OpenItem
      then Wh.ExecDialog(myfrm_Dlg_R_OrderStdItems, Self, [myfoDialog, myfoSizeable], S.IIf(User.Role(rOr_R_StdItems_Ch), fEdit, fView), LId, Fr.GetValueI('id_estimate_item'))
      else Orders.LoadEstimate(null, null, LId);
//      else Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([null, LId]));
    except
    end;
  end
  else if (Tag = mbtCustom_DataCheck_OpenItem2) or (Tag = mbtCustom_DataCheck_ViewEstimate2) then begin
    Handled := True;
    if Fr.GetCount(False) = 0 then Exit;
    LField := GetItemField2(Fr);
    if LField = '' then Exit;
    LId := Fr.GetValue(LField);
    if VarIsNull(LId) then Exit;
    try
    if Tag = mbtCustom_DataCheck_OpenItem2
      then Wh.ExecDialog(myfrm_Dlg_R_OrderStdItems, Self, [myfoDialog, myfoSizeable], S.IIf(User.Role(rOr_R_StdItems_Ch), fEdit, fView), LId, Fr.GetValueI('id_estimate_item'))
      else Orders.LoadEstimate(null, null, LId);
//      else Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([null, LId]));
    except
    end;
  end;
end;

procedure TFrmOWRepDataCheck.FormClose(Sender: TObject; var Action: TCloseAction);
//сохраним позицию окна
begin
  inherited;
  Settings.SaveWindowPos(Self, FormDoc);
end;


function TFrmOWRepDataCheck.Prepare: Boolean;
//начальная подготовка формы - настройка всех 10 гридов (текст описания в мемо задан в dfm) и первая загрузка данных
begin
  Result := False;
  Caption := 'Отчет по проблемам в БД';
  BorderStyle := bsSizeable;
  if not inherited then
    Exit;

  //заголовки вкладок и тексты описаний проблем зададим здесь в коде (не в dfm), чтобы не хранить кириллицу в dfm

  tsCheck1.Caption := 'Проблема 1';
  mmoDesc1.ReadOnly := True;
  mmoDesc1.Lines.Text := 'Совпадающие (без учета регистра) наименования полуфабрикатов из разных подгрупп. Само по ' +
    'себе может быть не ошибкой (в разных форматах бывают похожие детали), но требует проверки - риск путаницы ' +
    'при поиске позиции по имени (в bcad_nomencl/сметах).';

  tsCheck2.Caption := 'Проблема 2';
  mmoDesc2.ReadOnly := True;
  mmoDesc2.Lines.Text := 'Наименование полуфабриката (без префикса) совпадает (без учета регистра) с наименованием ' +
    'нестандартного изделия (у него тоже нет префикса). Создает риск подмены при использовании по имени в сметах.';

  tsCheck3.Caption := 'Проблема 3';
  mmoDesc3.ReadOnly := True;
  mmoDesc3.Lines.Text := 'Полное (с префиксом подгруппы) наименование какого-либо изделия совпадает (без учета ' +
    'регистра) с "голым" наименованием полуфабриката или нестандартного изделия. Опасно тем, что и bcad_nomencl, ' +
    'и итм (dv.nomenclatura) идентифицируют записи по полному наименованию.';

  tsCheck4.Caption := 'Проблема 4';
  mmoDesc4.ReadOnly := True;
  mmoDesc4.Lines.Text := 'Отгрузочное изделие (по полному наименованию, с префиксом) встречается как компонент в ' +
    'какой-либо смете. Отгрузочные изделия сами не производятся и не должны использоваться как составная часть ' +
    'чужой сметы.';

  tsCheck5.Caption := 'Проблема 5';
  mmoDesc5.ReadOnly := True;
  mmoDesc5.Lines.Text := 'В собственной смете отгрузочного изделия ссылка на производственное изделие не из того ' +
    'же формата, либо не совпадающая по наименованию с фактическим производственным изделием (несоответствие ' +
    '"самосметы" - см. также CheckSelfSmetaAction в uFrmODedtOrStdItem.pas).';

  tsCheck6.Caption := 'Проблема 6';
  mmoDesc6.ReadOnly := True;
  mmoDesc6.Lines.Text := 'Нестандартное изделие встречается как компонент в какой-либо смете. Нестандартные ' +
    'изделия обычно создаются под конкретный разовый заказ и не предполагаются переиспользуемыми компонентами ' +
    'чужих смет.';

  tsCheck7.Caption := 'Проблема 7';
  mmoDesc7.ReadOnly := True;
  mmoDesc7.Lines.Text := 'Проблемы в bcad_nomencl (справочник сметных позиций): совпадающие без учета регистра ' +
    'наименования разных записей (dup_cnt > 1), и/или отсутствие записи с тем же именем в итм - dv.nomenclatura ' +
    '(in_itm = 0). Вся номенклатура в итм берется именно из bcad_nomencl (и только из нее), поэтому расхождения ' +
    'ищем только в эту сторону.';

  tsCheck8.Caption := 'Проблема 8';
  mmoDesc8.ReadOnly := True;
  mmoDesc8.Lines.Text := 'Совпадающие без учета регистра наименования в итм (dv.nomenclatura).';

  tsCheck9.Caption := 'Проблема 9';
  mmoDesc9.ReadOnly := True;
  mmoDesc9.Lines.Text := 'Лишние пробелы (в начале / в конце / двойные) в наименованиях bcad_nomencl.';

  tsCheck10.Caption := 'Проблема 10';
  mmoDesc10.ReadOnly := True;
  mmoDesc10.Lines.Text := 'Лишние пробелы (в начале / в конце / двойные) в наименованиях итм (dv.nomenclatura).';

  FrgCheck1.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck1.Opt.Caption := 'Проблема 1';
  FrgCheck1.Opt.SetFields([
    ['id$i', '_id', '50'],
    ['name$s', 'Наименование', '250;w'],
    ['fullname$s', 'Полное имя', '250'],
    ['format_estimate_name$s', 'Подгруппа', '150'],
    ['format_name$s', 'Формат', '150'],
    ['dup_subgroup_cnt$i', 'Дублей', '60'],
    ['active$i', 'Активно', '60']
  ]);
  FrgCheck1.Opt.SetGridOperations('');
  FrgCheck1.Opt.SetButtons(1, [[mbtRefresh], [], [mbtCustom_DataCheck_OpenItem], [mbtCustom_DataCheck_ViewEstimate]]);
  FrgCheck1.OnButtonClick := FrgCheckButtonClick;
  FrgCheck1.SetInitData('select ' + FrgCheck1.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check1 order by name', []);
  FrgCheck1.Prepare;
  FrgCheck1.RefreshGrid;
  FrgCheck1.GridReadOnly := True;

  FrgCheck2.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck2.Opt.Caption := 'Проблема 2';
  FrgCheck2.Opt.SetFields([
    //['id_semiproduct$i', '_id_пф', '50'],
    ['semiproduct_name$s', 'Полуфабрикат', '200;w'],
    ['format_estimate_name$s', 'Подгруппа', '150'],
    ['format_name$s', 'Формат', '150'],
    ['id_nonstandard$i', '_id_ни', '50'],
    ['nonstandard_name$s', 'Нестанд. изделие', '200']
  ]);
  FrgCheck2.Opt.SetGridOperations('');
  FrgCheck2.Opt.SetButtons(1, [
    [mbtRefresh], [],
    [mbtCustom_DataCheck_OpenItem], [mbtCustom_DataCheck_ViewEstimate], [],
    [mbtCustom_DataCheck_OpenItem2], [mbtCustom_DataCheck_ViewEstimate2]
  ]);
  FrgCheck2.OnButtonClick := FrgCheckButtonClick;
//  FrgCheck2.SetInitData('select * from v_orders_check2 order by semiproduct_name', []);  FrgCheck2.Prepare;
  FrgCheck2.SetInitData('select ' + FrgCheck2.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check2 order by semiproduct_name', []);
  //FrgCheck2.RefreshGrid;
  FrgCheck2.GridReadOnly := True;

  FrgCheck3.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck3.Opt.Caption := 'Проблема 3';
  FrgCheck3.Opt.SetFields([
    ['id_item$i', '_id', '50'],
    ['item_name$s', 'Наименование', '180;w'],
    ['item_fullname$s', 'Полное имя', '200'],
    ['format_name$s', 'Формат', '120'],
    ['id_target$i', '_id_цель', '50'],
    ['target_name$s', 'Совпадает с', '200'],
    ['target_kind$s', 'Тип цели', '120']
  ]);
  FrgCheck3.Opt.SetGridOperations('');
  FrgCheck3.Opt.SetButtons(1, [
    [mbtRefresh], [],
    [mbtCustom_DataCheck_OpenItem], [mbtCustom_DataCheck_ViewEstimate], [],
    [mbtCustom_DataCheck_OpenItem2], [mbtCustom_DataCheck_ViewEstimate2]
  ]);
  FrgCheck3.OnButtonClick := FrgCheckButtonClick;
//  FrgCheck3.SetInitData('select * from v_orders_check3 order by item_name', []);
  FrgCheck3.SetInitData('select ' + FrgCheck3.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check3 order by item_name', []);
  FrgCheck3.Prepare;
  FrgCheck3.RefreshGrid;
  FrgCheck3.GridReadOnly := True;

  FrgCheck4.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck4.Opt.Caption := 'Проблема 4';
  FrgCheck4.Opt.SetFields([
    ['id_estimate_item$i', '_id_стр', '50'],
    ['id_estimate$i', '_id_смета', '60'],
    ['estimate_owner_fullname$s', 'Смета (владелец)', '200'],
    ['referenced_name_bcad$s', 'Позиция в смете', '200;w'],
    ['id_shipment_item$i', '_id_изд', '50'],
    ['shipment_item_fullname$s', 'Отгрузочное изделие', '200'],
    ['qnt1$f', 'Кол-во', '60']
  ]);
  FrgCheck4.Opt.SetGridOperations('');
  FrgCheck4.Opt.SetButtons(1, [[mbtRefresh], [], [mbtCustom_DataCheck_OpenItem], [mbtCustom_DataCheck_ViewEstimate]]);
  FrgCheck4.OnButtonClick := FrgCheckButtonClick;
//  FrgCheck4.SetInitData('select * from v_orders_check4', []);
  FrgCheck4.SetInitData('select ' + FrgCheck4.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check4', []);
  FrgCheck4.Prepare;
  FrgCheck4.RefreshGrid;
  FrgCheck4.GridReadOnly := True;

  FrgCheck5.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck5.Opt.Caption := 'Проблема 5';
  FrgCheck5.Opt.SetFields([
    ['id_shipment_item$i', '_id_отгр', '50'],
    ['shipment_item_fullname$s', 'Отгрузочное изделие', '200;w'],
    ['shipment_format_name$s', 'Формат отгр.', '120'],
    ['id_production_item$i', '_id_произв', '50'],
    ['production_item_fullname$s', 'Производств. изделие', '200'],
    ['production_format_name$s', 'Формат произв.', '120'],
    ['referenced_name_bcad$s', 'В смете указано', '200'],
    ['format_mismatch$i', 'Форматы разные', '60'],
    ['name_mismatch$i', 'Имя не совп.', '60']
  ]);
  FrgCheck5.Opt.SetGridOperations('');
  FrgCheck5.Opt.SetButtons(1, [
    [mbtRefresh], [],
    [mbtCustom_DataCheck_OpenItem], [mbtCustom_DataCheck_ViewEstimate], [],
    [mbtCustom_DataCheck_OpenItem2], [mbtCustom_DataCheck_ViewEstimate2]
  ]);
  FrgCheck5.OnButtonClick := FrgCheckButtonClick;
//  FrgCheck5.SetInitData('select * from v_orders_check5', []);
  FrgCheck5.SetInitData('select ' + FrgCheck5.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check5', []);
  FrgCheck5.Prepare;
  FrgCheck5.RefreshGrid;
  FrgCheck5.GridReadOnly := True;

  FrgCheck6.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck6.Opt.Caption := 'Проблема 6';
  FrgCheck6.Opt.SetFields([
    ['id_estimate_item$i', '_id_стр', '50'],
    ['id_estimate$i', '_id_смета', '60'],
    ['estimate_owner_fullname$s', 'Смета (владелец)', '200'],
    ['referenced_name_bcad$s', 'Позиция в смете', '200;w'],
    ['id_nonstandard_item$i', '_id_ни', '50'],
    ['nonstandard_item_name$s', 'Нестанд. изделие', '200'],
    ['qnt1$f', 'Кол-во', '60']
  ]);
  FrgCheck6.Opt.SetGridOperations('');
  FrgCheck6.Opt.SetButtons(1, [[mbtRefresh], [], [mbtCustom_DataCheck_OpenItem], [mbtCustom_DataCheck_ViewEstimate]]);
  FrgCheck6.OnButtonClick := FrgCheckButtonClick;
//  FrgCheck6.SetInitData('select * from v_orders_check6', []);
  FrgCheck6.SetInitData('select ' + FrgCheck6.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check6', []);
  FrgCheck6.Prepare;
  FrgCheck6.RefreshGrid;
  FrgCheck6.GridReadOnly := True;

  FrgCheck7.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck7.Opt.Caption := 'Проблема 7';
  FrgCheck7.Opt.SetFields([
    ['id$i', '_id', '50'],
    ['name$s', 'Наименование (bcad_nomencl)', '300;w'],
    ['is_purchased$i', 'Покупное', '70'],
    ['dup_cnt$i', 'Дублей', '60'],
    ['in_itm$i', 'Есть в ИТМ', '70']
  ]);
  FrgCheck7.Opt.SetGridOperations('');
  FrgCheck7.Opt.SetButtons(1, [[mbtRefresh]]);
  FrgCheck7.OnButtonClick := FrgCheckButtonClick;
//  FrgCheck7.SetInitData('select * from v_orders_check7 order by name', []);
  FrgCheck7.SetInitData('select ' + FrgCheck7.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check7 order by name', []);
  FrgCheck7.Prepare;
  FrgCheck7.RefreshGrid;
  FrgCheck7.GridReadOnly := True;

  FrgCheck8.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck8.Opt.Caption := 'Проблема 8';
  FrgCheck8.Opt.SetFields([
    ['id_nomencl$i', '_id_nomencl', '60'],
    ['name$s', 'Наименование (ИТМ)', '300;w'],
    ['id_group$i', 'Группа', '80'],
    ['id_unit$i', 'Ед.изм.', '60'],
    ['artikul$s', 'Артикул', '120'],
    ['dup_cnt$i', 'Дублей', '60']
  ]);
  FrgCheck8.Opt.SetGridOperations('');
  FrgCheck8.Opt.SetButtons(1, [[mbtRefresh]]);
  FrgCheck8.OnButtonClick := FrgCheckButtonClick;
//  FrgCheck8.SetInitData('select * from v_orders_check8 order by name', []);
  FrgCheck8.SetInitData('select ' + FrgCheck8.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check8 order by name', []);
  FrgCheck8.Prepare;
  FrgCheck8.RefreshGrid;
  FrgCheck8.GridReadOnly := True;

  FrgCheck9.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck9.Opt.Caption := 'Проблема 9';
  FrgCheck9.Opt.SetFields([
    ['id$i', '_id', '50'],
    ['name$s', 'Наименование (bcad_nomencl)', '300;w'],
    ['has_leading_space$i', 'Пробел в начале', '80'],
    ['has_trailing_space$i', 'Пробел в конце', '80'],
    ['has_double_space$i', 'Двойной пробел', '80']
  ]);
  FrgCheck9.Opt.SetGridOperations('');
  FrgCheck9.Opt.SetButtons(1, [[mbtRefresh]]);
  FrgCheck9.OnButtonClick := FrgCheckButtonClick;
//  FrgCheck9.SetInitData('select * from v_orders_check9 order by name', []);
  FrgCheck9.SetInitData('select ' + FrgCheck9.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check9 order by name', []);
  FrgCheck9.Prepare;
  FrgCheck9.RefreshGrid;
  FrgCheck9.GridReadOnly := True;

  FrgCheck10.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgCheck10.Opt.Caption := 'Проблема 10';
  FrgCheck10.Opt.SetFields([
    ['id_nomencl$i', '_id_nomencl', '60'],
    ['name$s', 'Наименование (ИТМ)', '300;w'],
    ['id_group$i', 'Группа', '80'],
    ['has_leading_space$i', 'Пробел в начале', '80'],
    ['has_trailing_space$i', 'Пробел в конце', '80'],
    ['has_double_space$i', 'Двойной пробел', '80']
  ]);
  FrgCheck10.Opt.SetGridOperations('');
  FrgCheck10.Opt.SetButtons(1, [[mbtRefresh]]);
  FrgCheck10.OnButtonClick := FrgCheckButtonClick;
//  FrgCheck10.SetInitData('select * from v_orders_check10 order by name', []);
  FrgCheck10.SetInitData('select ' + FrgCheck10.GetFieldNamesEx('', False).Implode(', ') + ' from v_orders_check10 order by name', []);
  FrgCheck10.Prepare;
  FrgCheck10.RefreshGrid;
  FrgCheck10.GridReadOnly := True;

  pgcMain.ActivePageIndex := 0;
  Result := True;
end;


end.
