{
Диалог ввода/редактирования календаря приемки изделия по этапу (даты и количество принятого по каждой дате) -
таблица order_item_stages, ключ - (id_order_item, id_stage). Модальный диалог, вызывается только из
uFrmOGjrnOrderStages.pas (клик по ячейке общего принятого количества в детальной панели журнала этапов заказа).

AID при вызове - id_order_item (aналог старого aID_Order_Item), AAddParam - VarArrayOf([id_stage, DtEditMin])
(aналоги старых aID_Stage/aDtEditMin) - см. общий комментарий выше про 2 слота ID/AddParam у Show/ShowModal2.

Редактирование строк - через фрейм грида (Frg1: TFrDBGridEh) с кнопками "+"/"-" в панели кнопок формы (как в
гридах заказов), вместо старого MemTableEh1+DBGridEh1 (см. исходный TDlg_Order_Stages1/D_Order_Stages1). Кнопки
и панель диалога - через базовый класс TFrmBasicEditabelGrid (по аналогии с uFrmOGedtDistributeQnt.pas - более
простым примером этого базового класса, без бокового канала как у uFrmOGedtEstimate.pas).

ПРОВЕРКИ (см. также общий комментарий в начале старого модуля/Bt_OkClick) - логика сохранена:
- дата обязательна, не может быть раньше DtEditMin (права доступа по датам) и позже текущей (см. столбец 'dt',
  верификация выставляется динамически в PrepareForm через Frg1.Opt.SetColumsProperties, т.к. DtEditMin - параметр
  вызова, а не константа);
- количество обязательно, не может быть отрицательным (столбец 'qnt', статическая верификация в SetFields);
- сумма количества по всем строкам не может превышать общее количество изделий по позиции заказа (Qnt) - проверяется
  в VerifyBeforeSave;
- нельзя вводить одинаковые даты в разных строках - проверяется в VerifyBeforeSave;
- строки с датой раньше DtEditMin нельзя редактировать/удалять (Frg1GetCellReadOnly/Frg1ButtonClick) - права доступа
  по датам, как и в исходном диалоге (см. RowDisable);
- удаление уже сохраненной (не только что добавленной) строки требует подтверждения (Frg1ButtonClick), как и в
  исходном диалоге (см. DelRow) - для новых (еще не сохраненных) строк подтверждение не запрашивается.

Старое поведение "количество = 0 в строке означает удаление записи при сохранении" не перенесено - теперь для
удаления служит настоящая кнопка "-" (Frg1.EditData.IdsDeleted, см. Save); поле "количество" по-прежнему может
быть равно 0 (как и в старом диалоге - SetFields, 'e=0:999999:2:N'), но это больше не служебное значение, просто
обычное (хоть и малополезное) число - для удаления строки теперь всегда используется кнопка "-".

Также не перенесены клавиатурные ускорители старого диалога (по "+", "=", пробел - см. DBGridEh1KeyPress) - это
не проверка данных, а лишь удобство ввода; при необходимости можно добавить позже.
}
unit uFrmOGedtOrderStages;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrmBasicGrid2, uFrmBasicEditabelGrid, uFrDBGridEh,
  uLabelColors
  ;

type
  TFrmOGedtOrderStages = class(TFrmBasicEditabelGrid)
    lbl_Caption: TLabel;
  private
    { Private declarations }
    ID_Order, ID_Order_Item, ID_Stage: Integer;
    Qnt: Extended;
    DtEditMin: TDateTime; //редактирование записей и ввод дат запрещен ранее этой даты (права доступа)
    procedure SetCaptionLabel;
  protected
    function  PrepareForm: Boolean; override;
    function  Save: Boolean; override;
    procedure VerifyBeforeSave; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
  public
  end;

var
  FrmOGedtOrderStages: TFrmOGedtOrderStages;

implementation

uses
  uDBOra;

{$R *.dfm}

function TFrmOGedtOrderStages.PrepareForm: Boolean;
var
  va: TVarDynArray;
begin
  Result := False;
  ID_Order_Item := ID;
  ID_Stage := AddParam[0];
  DtEditMin := VarToDateTime(AddParam[1]);
  Caption := S.Decode([ID_Stage, 1, 'Распил', 2, 'Приёмка на СГП', 3, 'Отгрузка с СГП', 2, 'Приёмка ОТК', '']);

  va := Q.QLoadRow('select nvl(qnt,0), id_order, dt_end from v_order_items where id = :id_order_item$i', [ID_Order_Item]);
  if va[0] = null then begin
    MyWarningMessage('Позиция заказа не найдена!');
    Exit;
  end;
  Qnt := va[0];
  ID_Order := va[1];
  //нельзя редактировать завершенный заказ
  if va[2] <> null then
    Mode := fView;

  Frg1.Opt.SetFields([
    ['id$i', '_id', '40'],
    ['dt$d', 'Дата', '85'],
    ['qnt$f', 'Кол-во', '85', 'e=0:999999:2:N']
  ]);
  Frg1.Opt.SetTable('order_item_stages');
  Frg1.Opt.SetGridOperations(S.IIFStr(Mode = fEdit, 'uad', ''));
  //диапазон допустимых дат зависит от параметра вызова (DtEditMin), поэтому верификацию столбца 'dt' выставляем
  //здесь, а не статически в SetFields выше (см. также общий комментарий в начале модуля)
  Frg1.Opt.SetColumsProperties('dt', myogfpFVerify, S.DateTimeToIntStr(DtEditMin) + ':' + S.DateTimeToIntStr(Date));
  Frg1.Opt.SetWhere('where id_order_item = :id_order_item$i and id_stage = :id_stage$i order by dt');
  Frg1.SetInitData('*', [ID_Order_Item, ID_Stage]);
  Frg1.Opt.Caption := 'Даты и количество';
  FOpt.InfoArray := [[
   'Изменяйте данные по принятым изделиям в этой таблице.'#13#10+
   'Ввод части данных может быть недоступным в зависимости от прав доступа (за ранние даты).'#13#10+
   'Для добавления строки нажмите кнопку "+" в панели кнопок.'#13#10+
   'Для удаления записи нажмите кнопку "-" в панели кнопок.'#13#10+
   'Ввести одинаковые даты в разных строках нельзя.'#13#10+
   'Если данные не верны, то они не сохранятся!'#13#10+
   'Недопустимо общее количество, большее количества для данного изделия, даты, большие текущей, и повторы дат!'#13#10,
   Mode <> fView]
  ];
  Result := inherited;
  if not Result then
    Exit;
  SetCaptionLabel;
end;

procedure TFrmOGedtOrderStages.SetCaptionLabel;
//информация вверху окна по количеству изделий (аналог старого SetCaptionLabel, сумма считается по строкам
//грида, а не через Footer.SumValue старого DBGridEh1)
var
  i: Integer;
  q, LSum: Extended;
begin
  TLabel(lbl_Caption).ResetColors;
  LSum := 0;
  for i := 0 to Frg1.GetRawCount - 1 do
    LSum := LSum + Frg1.GetRawValueF('qnt', i);
  q := Qnt - LSum;
  if q < 0 then q := -1;
  if q > 0 then q := 1;
  TLabel(lbl_Caption).SetCaptionAr([
    '$000000', 'Общее количество: ', S.Decode([q, 0, '$00FF00', 1, '$FF0000', -1, '$0000FF']), FloatToStr(Qnt) + ' шт.'
  ]);
end;

procedure TFrmOGedtOrderStages.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //блокируем изменение строк по датам, для которых (раньше DtEditMin) редактирование недопустимо правами доступа
  if (Fr.GetValue('dt') <> null) and (Fr.GetValueD('dt') < DtEditMin) then
    ReadOnly := True;
end;

procedure TFrmOGedtOrderStages.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtDeleteRow then begin
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
    SetCaptionLabel;
  end
  else
    inherited;
end;

procedure TFrmOGedtOrderStages.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
  SetCaptionLabel;
end;

procedure TFrmOGedtOrderStages.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  SetCaptionLabel;
end;

procedure TFrmOGedtOrderStages.VerifyBeforeSave;
//стандартная проверка при нажатии кнопки Ок - логика (сумма количества, повторы дат) сохранена от исходного
//Bt_OkClick, отдельная проверка корректности значений столбцов (обязательность/диапазон дат и количества) - через
//Frg1.IsTableCorrect (см. inherited, TFrmBasicEditabelGrid.VerifyBeforeSave)
var
  i, j: Integer;
  LSum: Extended;
  LHasDup: Boolean;
begin
  inherited;
  if Frg1.HasError then begin
    FErrorMessage := 'Данные некорректны!';
    Exit;
  end;
  LSum := 0;
  for i := 0 to Frg1.GetRawCount - 1 do
    LSum := LSum + Frg1.GetRawValueF('qnt', i);
  LHasDup := False;
  for i := 0 to Frg1.GetRawCount - 1 do
    for j := i + 1 to Frg1.GetRawCount - 1 do
      if Frg1.GetRawValueD('dt', i) = Frg1.GetRawValueD('dt', j) then
        LHasDup := True;
  if (LSum > Qnt) or LHasDup then
    FErrorMessage := 'Данные некорректны!';
end;

function TFrmOGedtOrderStages.Save: Boolean;
var
  i, res: Integer;
begin
  Result := False;
  res := 0;
  Q.QBeginTrans;
  for i := 0 to Frg1.EditData.IdsDeleted.Count - 1 do begin
    res := Q.QExecSql('delete from order_item_stages where id = :id$i', [Frg1.EditData.IdsDeleted[i]]);
    if res < 0 then Break;
  end;
  if res >= 0 then
    for i := 0 to Frg1.GetRawCount - 1 do begin
      if Frg1.GetRawValue('id', i) <> null
        then res := Q.QExecSql('update order_item_stages set dt = :dt$d, qnt = :qnt$f where id = :id$i',
          [Frg1.GetRawValueD('dt', i), Frg1.GetRawValueF('qnt', i), Frg1.GetRawValue('id', i)])
        else res := Q.QExecSql('insert into order_item_stages (id_order_item, id_stage, dt, qnt) values (:id_order_item$i, :id_stage$i, :dt$d, :qnt$f)',
          [ID_Order_Item, ID_Stage, Frg1.GetRawValueD('dt', i), Frg1.GetRawValueF('qnt', i)], False);
      if res < 0 then Break;
    end;
  if res >= 0 then
    res := Length(Q.QCallStoredProc('p_OrderStage_SetMainTable', 'IdOrder$i;IdStage$i', [ID_Order, ID_Stage])) - 1;
  Q.QCommitOrRollback(res >= 0);
  if res < 0 then begin
    MyWarningMessage('Не удалось сохранить данные!');
    Exit;
  end;
  Result := True;
end;

end.
