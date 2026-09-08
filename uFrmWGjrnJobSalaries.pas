{
Журнал "Плановые начисления по должностям" (07.09.2026).

Frg1 - список активных должностей, по каждой - плановое начисление (суммарное/фиксированное/
стимулирующее) за прошлый, текущий и следующий календарный месяц (view v_w_job_salaries_grid,
d_workers_new.sql). Суммарное начисление - вычисляемое, в базе не хранится.

Редактирование (галочка "Редактировать" вверху формы, доступна только при наличии права
rW_J_JobSalaries_Ch) разрешено всегда для следующего месяца, а для текущего и прошлого -
если по должности за этот месяц нет реальных данных из зарплатных ведомостей (флаги
can_edit_cur/can_edit_prev из вью v_w_job_salaries_grid), либо если включен расширенный режим
редактирования (Ctrl+Shift+E, только для User.IsDataEditor, см. GlobalEvent) - тогда
блокировка снимается для текущего и прошлого месяца (08.09.2026). Сохранение каждого значения
идёт через хранимую процедуру p_w_job_salaries_set_value, которая при первом вводе по месяцу
заполняет несохранённую графу нулём и дополнительно перепроверяет то же бизнес-правило
редактируемости на сервере (с учётом переданного признака расширенного режима).

Frg2 - детальная таблица, история плановых начислений по выбранной должности за все месяцы
(view v_w_job_salaries_history), только для просмотра.

Перенос значений на новый месяц (если по должности заполнен текущий месяц, но еще не заполнен
следующий) выполняется отдельным заданием шедулера - см. d_sheduled_tesks.sql,
w_job_salaries_fill_next_month_job / p_w_job_salaries_fill_next_month (d_workers_new.sql).
}
unit uFrmWGjrnJobSalaries;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGjrnJobSalaries = class(TFrmBasicGrid2)
  private
    FExtendedEdit: Boolean;
    function  PrepareForm: Boolean; override;
    procedure GlobalEvent(AEvent: Integer); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    function  MonthCaption(ADt: TDateTime): string;
  public
  end;

var
  FrmWGjrnJobSalaries: TFrmWGjrnJobSalaries;

implementation

uses
  uWindows
  ;

{$R *.dfm}

function TFrmWGjrnJobSalaries.MonthCaption(ADt: TDateTime): string;
begin
  Result := MonthsRu[MonthOf(ADt)] + ' ' + IntToStr(YearOf(ADt));
end;

function TFrmWGjrnJobSalaries.PrepareForm: Boolean;
var
  DtPrev, DtCur, DtNext: TDateTime;
  CanEdit: Boolean;
begin
  Caption := 'Плановые начисления по должностям';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];

  DtCur  := StartOfTheMonth(Date);
  DtPrev := IncMonth(DtCur, -1);
  DtNext := IncMonth(DtCur, 1);

  CanEdit := User.Role(rW_J_JobSalaries_Ch);

  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['can_edit_prev$i','_can_edit_prev','40'],
    ['can_edit_cur$i','_can_edit_cur','40'],
    ['job$s','Должность','250;h'],
    [ 'total_pay_prev$i', MonthCaption(DtPrev) + '|Итого', '90', 'f=r'],
    ['fixed_pay_prev$i','!Постоянная','90','f=r','e',CanEdit],
    ['variable_pay_prev$i','!Стиму-'#13#10'лирующая','90','f=r','e',CanEdit],
    [ 'total_pay_cur$i', MonthCaption(DtCur) + '|Итого', '90', 'f=r'],
    ['fixed_pay_cur$i','!Постоянная','90','f=r','e',CanEdit],
    ['variable_pay_cur$i','!Стиму-'#13#10'лирующая','90','f=r','e',CanEdit],
    [ 'total_pay_next$i', MonthCaption(DtNext) + '|Итого', '90', 'f=r'],
    ['fixed_pay_next$i','!Постоянная','90','f=r','e',CanEdit],
    ['variable_pay_next$i','!Стиму-'#13#10'лирующая','90','f=r','e',CanEdit]
  ]);
  Frg1.Opt.SetTable('v_w_job_salaries_grid', '', 'id', False, False);
  Frg1.Opt.SetWhere('order by job');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtExcel],[mbtPrintGrid],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  if CanEdit then
    Frg1.CreateAddControls('1', cntCheck, 'Редактировать', 'chbEdit', '', -1, yrefC, 100);

  Frg2.Opt.Caption := 'История плановых начислений';
  Frg2.Options := Frg2.Options + [myogGridLabels];
  Frg2.Opt.SetFields([
    ['id_job$i','_id_job','40'],
    ['dt$d','Месяц','90'],
    ['fixed_pay$i','Постоянная часть','120','f=f:'],
    ['variable_pay$i','Стимулирующая часть','120','f=f:'],
    ['total_pay$i','Итого','120','f=f:']
  ]);
  Frg2.Opt.SetTable('v_w_job_salaries_history');
  Frg2.Opt.SetWhere('where id_job = :id_job$i order by dt desc');
  Frg2.Opt.SetButtons(1, [[mbtRefresh],[],[mbtExcel],[mbtPrintGrid],[],[mbtGridSettings]]);

  Frg1.InfoArray:=[
    ['Плановые начисления по должностям.'#13#10#13#10+
    'Отображаются суммарное плановое начисление, а также его фиксированная и стимулирующая части '+
    'за прошлый, текущий и следующий месяц по каждой должности.'#13#10],
    ['Редактирование доступно всегда за следующий месяц, а за текущий и прошлый - '+
    'если по должности нет реальных данных из зарплатных ведомостей за этот месяц '+
    #13#10, CanEdit],
    ['Данные для расчетных ведомостей и штатного расписания берутся из этого журнала.'#13#10],
    ['В детальной таблице - полная история плановых начислений по выбранной должности.']
  ];

  Result := Inherited;

  Frg1.GridReadOnly := Frg1.GetControlValue('chbEdit', False, True) <> 1;
end;

procedure TFrmWGjrnJobSalaries.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  ReadOnly := True;
  if not User.Role(rW_J_JobSalaries_Ch) then
    Exit;
  if Frg1.GetControlValue('chbEdit') <> 1 then
    Exit;
  if A.InArray(Fr.CurrField, ['fixed_pay_next', 'variable_pay_next']) then
    ReadOnly := False
  else if A.InArray(Fr.CurrField, ['fixed_pay_cur', 'variable_pay_cur']) and (FExtendedEdit or (Fr.GetValue('can_edit_cur') = 1)) then
    ReadOnly := False
  else if A.InArray(Fr.CurrField, ['fixed_pay_prev', 'variable_pay_prev']) and (FExtendedEdit or (Fr.GetValue('can_edit_prev') = 1)) then
    ReadOnly := False;
end;

procedure TFrmWGjrnJobSalaries.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
var
  Dt: TDateTime;
  Fld: string;
begin
  if FieldName = 'fixed_pay_prev' then begin
    Dt := IncMonth(StartOfTheMonth(Date), -1);
    Fld := 'FIXED_PAY';
  end
  else if FieldName = 'variable_pay_prev' then begin
    Dt := IncMonth(StartOfTheMonth(Date), -1);
    Fld := 'VARIABLE_PAY';
  end
  else if FieldName = 'fixed_pay_cur' then begin
    Dt := StartOfTheMonth(Date);
    Fld := 'FIXED_PAY';
  end
  else if FieldName = 'variable_pay_cur' then begin
    Dt := StartOfTheMonth(Date);
    Fld := 'VARIABLE_PAY';
  end
  else if FieldName = 'fixed_pay_next' then begin
    Dt := IncMonth(StartOfTheMonth(Date), 1);
    Fld := 'FIXED_PAY';
  end
  else if FieldName = 'variable_pay_next' then begin
    Dt := IncMonth(StartOfTheMonth(Date), 1);
    Fld := 'VARIABLE_PAY';
  end
  else
    Exit;
  Q.QCallStoredProc('p_w_job_salaries_set_value', 'p_id_job$i;p_dt$d;p_field$s;p_value$f;p_override$i', [Fr.GetValue('id'), Dt, Fld, S.NNum(Value), Ord(FExtendedEdit)]);
  Fr.RefreshRecord;
end;

procedure TFrmWGjrnJobSalaries.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  Frg1.GridReadOnly := Frg1.GetControlValue('chbEdit') <> 1;
  Frg1.InvalidateGrid;
end;

procedure TFrmWGjrnJobSalaries.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_job$i', [Frg1.ID]);
  Fr.Opt.Caption := 'История: ' + Frg1.GetValueS('job');
end;

procedure TFrmWGjrnJobSalaries.GlobalEvent(AEvent: Integer);
begin
  if AEvent <> 1 then
    Exit;
  if not User.IsDataEditor then
    Exit;
  if not FExtendedEdit then begin
    if MyQuestionMessage('Включить расширенный режим редактирования (прошлый и текущий месяц - без ограничений)?') <> mrYes then
      Exit;
    FExtendedEdit := True;
  end
  else begin
    if MyQuestionMessage('Выключить расширенный режим редактирования?') <> mrYes then
      Exit;
    FExtendedEdit := False;
  end;
  Frg1.InvalidateGrid;
end;

end.
