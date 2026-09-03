{
Диалог ввода/редактирования изделий, не принятых ОТК, по позиции заказа (даты, количество, причина отказа,
комментарий) - таблица or_otk_rejected, ключ - id_order_item. Модальный диалог, вызывается только из
uFrmOGjrnOrderStages.pas (клик по ячейке "Непринятые" в детальной панели журнала этапов заказа) - по аналогии с
uFrmOGedtOrderStages.pas (см. также общий комментарий и заметки о переносе там же - структура и решения те же:
TFrmBasicEditabelGrid, фрейм грида Frg1 с кнопками "+"/"-" в панели кнопок формы вместо MemTableEh1+DBGridEh1,
логика проверок сохранена по данным исходного TDlg_Order_Stages_Otk2/D_Order_Stages_Otk2).

AID при вызове - id_order_item, AAddParam - VarArrayOf([DtEditMin, DtEditCurr]) (см. общий комментарий в
uFrmOGedtOrderStages.pas про 2 слота ID/AddParam у Show/ShowModal2). Параметр aID_Stage старого ShowDialog в
исходном диалоге фактически нигде не использовался (принимался, но не сохранялся ни в одно поле) - в новом
диалоге не переносился.

ОТЛИЧИЯ ОТ uFrmOGedtOrderStages.pas (это НЕ идентичная копия, проверки этого диалога проверены по его
собственному Bt_OkClick/DBGridEh1ColumnsUpdateData, а не скопированы оттуда):
- количество проверяется поштучно (для каждой строки - не больше общего количества изделий Qnt), а не суммой по
  всем строкам, как там (в исходном диалоге суммовой проверки при сохранении здесь нет вообще - переменные
  qnt/d в Bt_OkClick собирались, но нигде не использовались после сбора, похоже на недоделку/копипасту оттуда);
- проверки на повтор дат нет (в отличие от uFrmOGedtOrderStages.pas) - для отказов ОТК за одну дату вполне может
  быть несколько записей с разными причинами, так что это не перенесено как настоящее отличие, а не недосмотр;
  строки с датой раньше DtEditMin нельзя редактировать/удалять - RowDisable, как и там, но проверка на удаление
  (DelRow) в исходном диалоге сравнивала VarToDateTime от поля 'id' (а не 'dt') - похоже на опечатку/баг
  копипасты, здесь для проверки берется поле 'dt', как и везде остальные (RowDisable/Frg1GetCellReadOnly);
- добавлены поля "Причина неприемки" (id_reason, справочник ref_otk_reject_reasons, выпадающий список через
  Frg1.Opt.SetPick) и "Комментарий" (comm, необязательное поле) - обязательность причины сохранена;
- при добавлении новой строки (кнопка "+") дата по умолчанию проставляется в DtEditCurr, как и в исходном
  диалоге (см. AddRow) - через переопределение Frg1ButtonClick для Tag = mbtAddRow;
- окно оставлено изменяемого размера (myfoSizeable) - как и в исходном диалоге (BorderStyle = bsSizeable), в
  отличие от узкого фиксированного uFrmOGedtOrderStages.pas; автосохранение позиции/размера окна
  (AutoSaveWindowPos в исходном диалоге) в новом движке не перенесено - соответствующего механизма не нашлось.

Как и в uFrmOGedtOrderStages.pas: старое поведение "количество = 0 в строке означает удаление записи при
сохранении" не перенесено - для удаления служит кнопка "-" (Frg1.EditData.IdsDeleted, см. Save); клавиатурные
ускорители старого диалога (по "+", "=", пробел) тоже не перенесены - не проверка данных, а удобство ввода.
}
unit uFrmOGedtOrderStagesOtkRejected;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrmBasicGrid2, uFrmBasicEditabelGrid, uFrDBGridEh,
  uLabelColors
  ;

type
  TFrmOGedtOrderStagesOtkRejected = class(TFrmBasicEditabelGrid)
    lbl_Caption: TLabel;
  private
    { Private declarations }
    ID_Order_Item: Integer;
    Qnt: Extended;
    DtEditMin: TDateTime;  //редактирование записей и ввод дат запрещен ранее этой даты (права доступа)
    DtEditCurr: TDateTime; //дата по умолчанию для новой строки (см. Frg1ButtonClick, Tag = mbtAddRow)
    procedure SetCaptionLabel;
  protected
    function  PrepareForm: Boolean; override;
    function  Save: Boolean; override;
    procedure VerifyBeforeSave; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
  public
  end;

var
  FrmOGedtOrderStagesOtkRejected: TFrmOGedtOrderStagesOtkRejected;

implementation

uses
  uDBOra;

{$R *.dfm}

function TFrmOGedtOrderStagesOtkRejected.PrepareForm: Boolean;
var
  va: TVarDynArray;
  va2: TVarDynArray2;
begin
  Result := False;
  ID_Order_Item := ID;
  DtEditMin := VarToDateTime(AddParam[0]);
  DtEditCurr := VarToDateTime(AddParam[1]);
  Caption := 'Изделия, не принятые ОТК';

  va := Q.QLoadRow('select nvl(qnt,0), id_order, dt_end from v_order_items where id = :id_order_item$i', [ID_Order_Item]);
  if va[0] = null then begin
    MyWarningMessage('Позиция заказа не найдена!');
    Exit;
  end;
  Qnt := va[0];
  //нельзя редактировать завершенный заказ
  if va[2] <> null then
    Mode := fView;

  Frg1.Opt.SetFields([
    ['id$i', '_id', '40'],
    ['dt$d', 'Дата', '85'],
    ['qnt$f', 'Кол-во', '85'],
    ['id_reason$i', 'Причина неприемки', '250;w', 'e=1:100000:0:N'],
    ['comm$s', 'Комментарий', '250;w', 'e=0:2000::TP']
  ]);
  Frg1.Opt.SetTable('or_otk_rejected');
  Frg1.Opt.SetGridOperations(S.IIFStr(Mode = fEdit, 'uad', ''));
  //диапазон дат (DtEditMin) и верхняя граница количества (Qnt) - параметры вызова, поэтому верификация этих
  //столбцов выставляется здесь, а не статически в SetFields выше
  Frg1.Opt.SetColumsProperties('dt', myogfpFVerify, S.DateTimeToIntStr(DtEditMin) + ':' + S.DateTimeToIntStr(Date));
  Frg1.Opt.SetColumsProperties('qnt', myogfpFVerify, '0:' + FloatToStr(Qnt) + ':2:N');
  Frg1.Opt.SetWhere('where id_order_item = :id_order_item$i order by dt');
  Frg1.SetInitData('*', [ID_Order_Item]);
  Frg1.Opt.Caption := 'Не принятые ОТК изделия';

  //причины отказа - все активные, и те неактивные, по которым для этого изделия заказа уже есть записи
  va2 := Q.QLoad(
    'select name, id from ref_otk_reject_reasons where ' +
    'active = 1 or (id in (select id_reason from or_otk_rejected where id_order_item = :id_order_item$i)) ' +
    'order by name',
    [ID_Order_Item]
  );
  Frg1.Opt.SetPick('id_reason', va2, True);

  FOpt.InfoArray := [[
   'Изменяйте данные по не принятым ОТК изделиям в этой таблице.'#13#10+
   'Ввод части данных может быть недоступным в зависимости от прав доступа (за ранние даты).'#13#10+
   'Для добавления строки нажмите кнопку "+" в панели кнопок.'#13#10+
   'Для удаления записи нажмите кнопку "-" в панели кнопок.'#13#10+
   'Причина неприемки выбирается из списка. Комментарий не обязателен.'#13#10+
   'Если данные не верны, то они не сохранятся!'#13#10,
   Mode <> fView]
  ];
  Result := inherited;
  if not Result then
    Exit;
  SetCaptionLabel;
end;

procedure TFrmOGedtOrderStagesOtkRejected.SetCaptionLabel;
//информация вверху окна - аналог старого SetCaptionLabel (в исходном диалоге цветовая раскраска по остатку
//количества была закомментирована, реально показывается только общее количество красным - оставлено как есть)
begin
  TLabel(lbl_Caption).ResetColors;
  TLabel(lbl_Caption).SetCaptionAr([
    '$000000', 'Общее количество: ', '$FF0000', FloatToStr(Qnt) + ' шт.'
  ]);
end;

procedure TFrmOGedtOrderStagesOtkRejected.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //блокируем изменение строк по датам, для которых (раньше DtEditMin) редактирование недопустимо правами доступа
  if (Fr.GetValue('dt') <> null) and (Fr.GetValueD('dt') < DtEditMin) then
    ReadOnly := True;
end;

procedure TFrmOGedtOrderStagesOtkRejected.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtAddRow then begin
    Handled := True;
    Fr.AddRow;
    if not Fr.IsEmpty then
      Fr.SetValue('dt', DtEditCurr);
  end
  else if Tag = mbtDeleteRow then begin
    Handled := True;
    if Fr.IsEmpty then
      Exit;
    //строка заблокирована по дате - права доступа (см. Frg1GetCellReadOnly/RowDisable в исходном диалоге)
    if (Fr.GetValue('dt') <> null) and (Fr.GetValueD('dt') < DtEditMin) then
      Exit;
    //запрос подтверждения только для строк, бывших ранее открытия окна - вновь добавленные удаляем без запроса
    if (Fr.GetValue('id') <> null) and (MyQuestionMessage('Удалить запись?') <> mrYes) then
      Exit;
    Fr.DeleteRow;
  end
  else
    inherited;
end;

procedure TFrmOGedtOrderStagesOtkRejected.VerifyBeforeSave;
//проверка при нажатии кнопки Ок - вся проверка данных (обязательность и диапазон дат/количества/причины) уже
//выполняется по verify-строкам столбцов через Frg1.IsTableCorrect (inherited); отдельных проверок вида "сумма
//по всем строкам"/"повтор дат" для этого диалога нет - см. общий комментарий в начале модуля
begin
  inherited;
  if Frg1.HasError then
    FErrorMessage := 'Данные некорректны!';
end;

function TFrmOGedtOrderStagesOtkRejected.Save: Boolean;
var
  i, res: Integer;
begin
  Result := False;
  res := 0;
  Q.QBeginTrans;
  for i := 0 to Frg1.EditData.IdsDeleted.Count - 1 do begin
    res := Q.QExecSql('delete from or_otk_rejected where id = :id$i', [Frg1.EditData.IdsDeleted[i]]);
    if res < 0 then Break;
  end;
  if res >= 0 then
    for i := 0 to Frg1.GetRawCount - 1 do begin
      if Frg1.GetRawValue('id', i) <> null
        then res := Q.QExecSql('update or_otk_rejected set dt = :dt$d, qnt = :qnt$f, id_reason = :id_reason$i, comm = :comm$s where id = :id$i',
          [Frg1.GetRawValueD('dt', i), Frg1.GetRawValueF('qnt', i), Frg1.GetRawValueI('id_reason', i), Frg1.GetRawValueS('comm', i), Frg1.GetRawValue('id', i)])
        else res := Q.QExecSql('insert into or_otk_rejected (id_order_item, dt, qnt, id_reason, comm) values (:id_order_item$i, :dt$d, :qnt$f, :id_reason$i, :comm$s)',
          [ID_Order_Item, Frg1.GetRawValueD('dt', i), Frg1.GetRawValueF('qnt', i), Frg1.GetRawValueI('id_reason', i), Frg1.GetRawValueS('comm', i)], False);
      if res < 0 then Break;
    end;
  Q.QCommitOrRollback(res >= 0);
  if res < 0 then begin
    MyWarningMessage('Не удалось сохранить данные!');
    Exit;
  end;
  Result := True;
end;

end.
