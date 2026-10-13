{
Штатное расписание.

Обычный режим - по официальным должностям (w_jobs, вью v_w_staff_schedule). Галочка "По внутренним
должностям" (chbInternal) переключает на вью v_w_staff_schedule_internal - группировка по
внутренним должностям (w_jobs_internal); нескольким официальным должностям может соответствовать
одна внутренняя - численность суммируется, а плановая з/п и рынок усредняются по входящим в нее
официальным должностям (простое или средневзвешенное по занятой численности среднее - см. константу
cUseWeightedInternalAvg). Если у официальной должности внутренняя не задана - используется сама
официальная как единственная в своей группе. В этом режиме ввод данных (плановая численность, рынок)
недоступен - это агрегат по нескольким официальным должностям, редактировать нечего одно конкретное;
"Начисленная з/п (средняя)" (из фактических ведомостей, привязана к официальной должности) в этом
режиме не считается - остается пустой.

Плановая з/п (salary_plan) в обоих режимах берется из w_job_salaries (см. uFrmWGjrnJobSalaries.pas) -
раньше бралась из ручного ввода в таблицу w_ref_staff_schedule (type = 2), сейчас этот столбец там
больше не используется, значение только для просмотра (не редактируется через этот отчет).

Вид отчета : группируемые чекбоксы "Вид 1" (прежний: строки по специальностям
с итогом по каждой и разбивкой по подразделениям) и "Вид 2" (по подразделениям: сверху сплошной строкой подразделение и
общее количество работающих в нем, под ней список специальностей этого подразделения). В виде 2 нет столбцов "офис /цех"
и "Подразделение", ввод данных не доступен. Данные в обоих видах читаются из одних и тех же вью (v_w_staff_schedule /
v_w_staff_schedule_internal), вид 2 строится в BuildView2.

}

unit uFrmWGrepStaffSchedule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uNamedArr, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uWindows
  ;

type
  TFrmWGrepStaffSchedule = class(TFrmBasicGrid2)
  private
    //включен вид 2 (по подразделениям), устанавливается в SetMode
    FView2: Boolean;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
    procedure SetMode;
    procedure GetData;
    procedure BuildView2(var na: TNamedArr; const ArSalary: TVarDynArray2; bInternal: Boolean);
    procedure FromExcel;
  public
  end;

var
  FrmWGrepStaffSchedule: TFrmWGrepStaffSchedule;

implementation

uses
  uTurv,
  uExcel,
  XlsMemFilesEh
  ;

{$R *.dfm}

const
  //режим "По внутренним должностям" (см. GetData) - плановая з/п и рынок по внутренней должности
  //считаются как среднее по официальным должностям, которые в нее входят (несколько официальных
  //могут соответствовать одной внутренней) - выбор способа усреднения пока не очевиден для
  //бухгалтерии, поэтому сделан константой, а не настройкой в интерфейсе:
  //False - простое среднее по официальным должностям, True - средневзвешенное по фактически занятой
  //численности (см. v_w_staff_schedule_internal, salary_plan_avg/salary_plan_wavg, salary_sity_avg/
  //salary_sity_wavg - SQL/d_workers_new.sql)
  cUseWeightedInternalAvg = False;
  //вид 2: строка-заголовок подразделения рисуется сплошной на всю ширину таблицы (см. Frg1DbGridEh1AdvDrawDataCell).
  //если при отрисовке будут артефакты (например при горизонтальной прокрутке) - поставить False, тогда это обычная
  //строка с серым фоном и жирным текстом в первом столбце
  cSpanTitleRows = True;

function TFrmWGrepStaffSchedule.PrepareForm: Boolean;
var
  NoSum: boolean;
begin
  Caption:='Штатное расписание';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible] - [myogSorting];
  //NoSum := not A.InArray(User.GetLogin, ['sprokopenko','ostulihina','eteplyakova']);
  Frg1.Opt.SetFields([
    ['rownum$i','_id','40'],
    ['is_title$i','_title','40'],
    ['id_job$i','_Должность','40'],
    ['id_departament$i','_Подразделение','40'],
    ['office$s','офис /цех','50'],
    ['job$s','Должность','250;h'],
    ['departament$s','Подразделение','250;h'],
    ['qnt$i','Фактическая численность работников','100'],
    ['qnt_wo_org$i','из них без оформления','100'],
    ['qnt_plan$i','Плановая численность работников','100','f=f:','e=0:100:0',User.Roles([], [rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C])],
    ['qnt_need$i','Потребность в работниках','100','f=f:'],
    ['schedule$s','График работы','100'],
    ['salary_avg$i','Начисленная з/п (средняя)','100','f=f','t=1'],
    ['salary_plan$i','Начисленная з/п (плановая)','100','f=f','t=1'],
    ['salary_wo_ndfl$i','з/п после вычета НДФЛ','100','f=f','t=1'],
    ['salary_sity$i','Рынок, начисл.','100','f=f','e','t=1'],
    ['budget$i','Бюджет исходя из кол-во факт. занятых ставок','100','f=f','t=1'],
    ['salary_diff$i','Отклонения от рынка по должности','100','f=f','t=1'],
    ['budget_sity$i','Бюджет по рынку','100','f=f','t=1'],
    ['budget_diff$i','Отклонения бюджета от рынка','100','f=f','t=1']
  ]);
  Frg1.Opt.SetButtons(1,[[mbtGo],[],[mbtExcel],[mbtPrintGrid],[],[-1001, User.Role(rW_Rep_StaffSchedule_Ch_O), 'Вакантные должности'],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtGo]);
  Frg1.CreateAddControls('1', cntDTEdit, 'Дата', 'edtd1', ':',30, yrefC, 85);
  Frg1.CreateAddControls('1', cntComboL, 'Площадка', 'cmbArea', ':', 30 + 65 + 80, yrefC, 100);
  //вид отчета - группа чекбоксов с тегом -1 (радио: нельзя снять оба, см. TFrDBGridEh.AddControlChange)
  Frg1.CreateAddControls('1', cntCheck, 'Вид 1', 'chbView1', '', -1, yrefC, 55, -1);
  Frg1.CreateAddControls('1', cntCheck, 'Вид 2', 'chbView2', '', -1, yrefC, 55, -1);
  if User.Roles([], [rW_Rep_StaffSchedule_V_S]) then
    Frg1.CreateAddControls('1', cntCheck, 'Данные по з/п', 'chbSalary', '', -1, yrefC, 100);
  if User.Roles([], [rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C, rW_Rep_StaffSchedule_Ch_SP, rW_Rep_StaffSchedule_Ch_SS]) then
    Frg1.CreateAddControls('1', cntCheck, 'Ввод данных', 'chbEdit', '', -1, yrefC, 100);
  Frg1.CreateAddControls('1', cntCheck, 'По внутренним должностям', 'chbInternal', '', -1, yrefC, 160);
  Q.QLoadToDBComboBoxEh('select ''Все'' from dual union select distinct area_shortname || '' - '' || office from v_w_departaments where active = 1 order by 1', [], TDBComboBoxEh(Frg1.FindComponent('cmbArea')), cntComboL);
  Frg1.InfoArray:=[[
    'Штатное расписание.'#13#10#13#10+
    'Данные по составу работников фолрмируются строго по состоянию на (произвольный) указанный день.'#13#10+
    'можно сформировать отчет как по всему предприятию, так и отдельно по площадкам (с учетом признака Цех/Офис").'#13#10+
    'Вид 1 - по специальностям (с итогом по каждой и разбивкой по подразделениям), вид 2 - по подразделениям: '#13#10+
    'сверху подразделение и общее количество работающих в нем, под ним список специальностей.'#13#10+
    'В виде 2 ввод данных недоступен.'#13#10+
    'Возвоможен вывод штатного расписания как по официальным, так и внутренним должностям.'#13#10+
    'Данные по заработной плате берутся из журнала "Плановые начисления по должностям" на период, содержащий дапту формирования ведомости." '#13#10+
    ''#13#10
  ]];
  //данные из массива
  Frg1.SetInitData([]);
  Result := Inherited;
  //отрисовка строки-заголовка подразделения в виде 2 (событие грида, как в uFrmWGedtTurvN)
  Frg1.DbGridEh1.OnAdvDrawDataCell := Frg1DbGridEh1AdvDrawDataCell;
  SetMode;
end;

procedure TFrmWGrepStaffSchedule.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  //if Tag = mbtExcel then FromExcel else
  if Tag = mbtGo then begin
    GetData;
    Fr.RefreshGrid;
  end
  else if Tag = 1001 then
    Wh.ExecReference(myfrm_Ref_JobsNeeded)
  else
    inherited;
end;

procedure TFrmWGrepStaffSchedule.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if Fr.GetValue('office') = 'Итого:' then
    Params.Background := clmyYelow
  else if (Fr.GetValue('id_departament') = null) or (Fr.GetValue('is_title') = 1) then
    Params.Background := clmyGray;
  //вид 2: строки-заголовки подразделений выделим жирным
  if FView2 and (Fr.GetValue('is_title') = 1) then
    Params.Font.Style := Params.Font.Style + [fsBold];
  if (FieldName = 'qnt_need') and (Fr.GetValue('qnt_need') <> null) then begin
    if Fr.GetValue('qnt_need') < 0 then
      Params.Background := clmyPink
    else if Fr.GetValue('qnt_need') > 0 then
      Params.Background := clmyGreen;
  end;
end;

procedure TFrmWGrepStaffSchedule.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //в виде 2 ввод данных недоступен
  ReadOnly := FView2 or (Fr.GetValue('id_departament') = null) or (
    (Fr.CurrField = 'qnt_plan') and (
    ((Fr.GetValue('office') = 'цех') and not User.Role(rW_Rep_StaffSchedule_Ch_C)) or
    ((Fr.GetValue('office') = 'цех') and not User.Role(rW_Rep_StaffSchedule_Ch_C))));
end;

procedure TFrmWGrepStaffSchedule.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
var
  t: Integer;
begin
  t := A.PosInArray(FieldName, ['','qnt_plan','salary_plan','salary_sity']);
  if t > 0 then begin
    Q.QExecSql('delete from w_ref_staff_schedule where id_departament = :id_departament$i and id_job = :id_job$i and dt = :dt$d and type = :t$i', [Fr.GetValue('id_departament'), Fr.GetValue('id_job'), Date, t]);
    Q.QExecSql('insert into w_ref_staff_schedule (id_departament, id_job, dt, type, value) values (:id_departament$i, :id_job$i, :dt$d, :t$i, :value$i)', [Fr.GetValue('id_departament'), Fr.GetValue('id_job'), Date, t, S.NullIf0(Value)]);
  end;
end;

procedure TFrmWGrepStaffSchedule.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  SetMode;
  //при смене вида перечитаем данные, если они уже были загружены (структура строк у видов разная)
  if (TControl(Sender).Name = 'chbView1') or (TControl(Sender).Name = 'chbView2') then
    if Fr.IsPrepared and (Fr.GetCount(False) > 0) then begin
      GetData;
      Fr.RefreshGrid;
    end;
end;

procedure TFrmWGrepStaffSchedule.SetMode;
var
  b, bInternal, bView2 : Boolean;
  c: TComponent;
begin
  b := Cth.DteValueIsDate(Frg1.FindComponent('edtd1')) and (Frg1.GetControlValue('edtd1') = Date);
  bInternal := Frg1.GetControlValue('chbInternal') = 1;
  //вид отчета: если ни один не выбран (первый запуск) - вид 1
  if (not (Frg1.GetControlValue('chbView1') = 1)) and (not (Frg1.GetControlValue('chbView2') = 1)) then
    Frg1.SetControlValue('chbView1', 1);
  bView2 := Frg1.GetControlValue('chbView2') = 1;
  FView2 := bView2;
  Frg1.Opt.SetColFeature('1', 'i', not ((Frg1.GetControlValue('chbSalary') = 1) and User.Role(rW_Rep_StaffSchedule_V_S)), True);
  //в режиме "по внутренним должностям" qnt_plan/salary_sity - агрегаты по нескольким официальным
  //должностям, править их через этот отчет нельзя (см. заголовочный комментарий модуля)
  Frg1.Opt.SetColFeature('qnt_plan', 'e', (not bInternal) and (not bView2) and (Frg1.GetControlValue('chbEdit') = 1)  and b and User.Roles([], [rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C]), False);
  //salary_plan теперь в обоих режимах берется из w_job_salaries и правится через uFrmWGjrnJobSalaries.pas,
  //через этот отчет больше не редактируется (см. заголовочный комментарий модуля)
  Frg1.Opt.SetColFeature('salary_sity', 'e', (not bInternal) and (not bView2) and (Frg1.GetControlValue('chbEdit') = 1) and b and User.Role(rW_Rep_StaffSchedule_Ch_SS), False);
  //вид 2: нет столбцов "офис /цех" и "Подразделение" (подразделение - в строке-заголовке); этот вызов должен идти после
  //вызова SetColFeature с очисткой признака 'i' выше
  Frg1.Opt.SetColFeature('office;departament', 'i', bView2, False);
  //в виде 2 нет ввода данных - блокируем соответствующий чекбокс
  c := Frg1.FindComponent('chbEdit');
  if c is TControl then
    TControl(c).Enabled := not bView2;
  Frg1.SetColumnsVisible;
  Frg1.DbGridEh1.Invalidate;
end;


procedure TFrmWGrepStaffSchedule.GetData;
var
  i, j, qc, qo, qdp, qn, qnp, qnm, qdn, qon, qcn: Integer;
  na : TNamedArr;
  st: string;
  ArSalary, ArSalaryPlan, ArSalarySity, ArQntPlan: TVarDynArray2;
  v1: Variant;
  dt1, dt2, dtsal: TDateTime;
  bInternal, bView2: Boolean;
  sPlan, sCity: string;
begin
  if (not Cth.DteValueIsDate(Frg1.FindComponent('edtd1'))) or (S.NSt(Frg1.GetControlValue('cmbArea')) = '') then
    Exit;
  bInternal := Frg1.GetControlValue('chbInternal') = 1;
  bView2 := Frg1.GetControlValue('chbView2') = 1;
  if Frg1.GetControlValue('cmbArea')  <> 'Все' then begin
    i := Pos(' - ', Frg1.GetControlValue('cmbArea'));
    Q.QSetContextValue('staff_schedule_office', S.IIf(Copy(Frg1.GetControlValue('cmbArea'), i + 3) = 'офис' , 1, 0));
    Q.QSetContextValue('staff_schedule_area', Copy(Frg1.GetControlValue('cmbArea'), 1, i -1));
  end
  else begin
    Q.QSetContextValue('staff_schedule_office', '');
    Q.QSetContextValue('staff_schedule_area', '');
  end;
  Q.QSetContextValue('staff_schedule_dt', Frg1.GetControlValue('edtd1'));
  //в режиме "по внутренним должностям" - v_w_staff_schedule_internal, salary_plan/salary_sity берутся
  //как среднее (простое или средневзвешенное - см. cUseWeightedInternalAvg) по официальным должностям,
  //т.к. привязаны именно к ним (см. заголовочный комментарий модуля и комментарий к view в d_workers_new.sql)
  if bView2 then begin
    //вид 2: только строки "специальность в подразделении" (без итогов по специальности и общего), упорядоченные по
    //подразделению и специальности; поля те же и в том же порядке, что и в виде 1 (см. BuildView2)
    if bInternal then begin
      sPlan := S.IIf(cUseWeightedInternalAvg, 'salary_plan_wavg', 'salary_plan_avg') + ' as salary_plan';
      sCity := S.IIf(cUseWeightedInternalAvg, 'salary_sity_wavg', 'salary_sity_avg') + ' as salary_sity';
    end
    else begin
      sPlan := 'salary_plan';
      sCity := 'salary_sity';
    end;
    Q.QLoad(
      'select rownum, 0 as is_title, id_job, id_departament, office, job, departament, qnt, qnt_wo_org, qnt_plan, qnt_need, schedule, '+
      'null as salary_avg, salary_plan, null as salary_wo_ndfl, null as salary_diff, salary_sity, null as budget, null as budget_sity, null as budget_diff '+
      'from (select id_job, id_departament, office, job, departament, qnt, qnt_wo_org, qnt_plan, qnt_need, schedule, ' + sPlan + ', ' + sCity + ' ' +
      'from ' + S.IIf(bInternal, 'v_w_staff_schedule_internal', 'v_w_staff_schedule') + ' where id_departament is not null order by departament, job)',
    [], na);
  end
  else if bInternal then
    Q.QLoad(
      'select rownum, 0 as is_title, id_job, id_departament, office, job, departament, qnt, qnt_wo_org, qnt_plan, qnt_need, schedule, '+
      'null as salary_avg, '+S.IIf(cUseWeightedInternalAvg, 'salary_plan_wavg', 'salary_plan_avg')+' as salary_plan, '+
      'null as salary_wo_ndfl, null as salary_diff, '+
      S.IIf(cUseWeightedInternalAvg, 'salary_sity_wavg', 'salary_sity_avg')+' as salary_sity, '+
      'null as budget, null as budget_sity, null as budget_diff '+
      'from v_w_staff_schedule_internal',
    [], na)
  else
    Q.QLoad(
      'select rownum, 0 as is_title, id_job, id_departament, office, job, departament, qnt, qnt_wo_org, qnt_plan, qnt_need, schedule, '+
      'null as salary_avg, salary_plan, null as salary_wo_ndfl, null as salary_diff, salary_sity, null as budget, null as budget_sity, null as budget_diff '+
      'from v_w_staff_schedule',
    [], na);
  dt2 := Turv.GetTurvBegDate(Turv.GetTurvBegDate(Turv.GetTurvBegDate(Date)));
  //дата для выборки з/п - самая поздняя по закрытой полной ведомости
  ArSalary := [];
  v1 := Q.QLoadValue('select max(nvl(dt, date ''2001-01-01'')) from w_payroll_calc where id_employee is null and is_finalized = 1', []);
  if v1 <> null then begin
    dtsal := v1;
    ArSalary := Q.QLoad(
      'select pi.id_job, round(avg((total_pay - nvl(non_work_pay,0) - nvl(penalty,0)) / hours_worked * period_hours_norm)) sumall ' +
      'from v_w_payroll_calc_item pi, v_w_staff_schedule ss ' +
      'where ' +
      'nvl(total_pay, 0) <> 0 and nvl(hours_worked,0) <> 0 ' +
      'and ss.id_job = pi.id_job ' +
      'and dt >= :dtbeg$d ' +
      'and dt <= :dtend$d ' +
      'group by pi.id_job',
      [IncMonth(dtsal, -2), dtsal]
    );
  end;


{
  ArSalaryPlan := Q.QLoad(
    'select id_departament, id_job, value from w_ref_staff_schedule where dt = ( '+
    'select max(dt) from w_ref_staff_schedule '+
    'where dt < :dt$d and type = 2 '+
    'group by id_departament, id_job)',
    [Frg1.GetControlValue('edtd1')]
  );}
  //вид 2 строится отдельно
  if bView2 then begin
    BuildView2(na, ArSalary, bInternal);
    Frg1.SetInitData(na);
    Exit;
  end;
  //посчитаем итоги по цеху и офису
  qc := 0;
  qo := 0;
  qcn := 0;
  qon := 0;
  for i := 0 to na.Count - 2 do
    if na.G(i, 'id_departament') <> null then
      if na.G(i, 'office') = 'цех' then begin
        qc := qc + na.G(i, 'qnt');
        qcn := qcn + na.G(i, 'qnt_wo_org')
      end
      else begin
        qo := qo + na.G(i, 'qnt');
        qon := qon + na.G(i, 'qnt_wo_org')
      end;
  //удалим последнюю строку (вью там возвращает строку с общим итогом)
  Delete(na.V, na.Count - 1, 1);
  //добавим итоги
  na.V := na.V + [[100000, null, null, null, 'Итого:', '', 'офис', qo, qon, null,null,null,null,null,null,null,null,null,null,null]];
  na.V := na.V + [[100001, null, null, null, 'Итого:', '', 'цех', qc, qcn, null,null,null,null,null,null,null,null,null,null,null]];
  na.V := na.V + [[100002, null, null, null, 'Итого:', '', 'всего', qc + qo, qon + qcn, null,null,null,null,null,null,null,null,null,null,null]];
  //удалим итоги по тем профессиям по которым только одна запись (цифра в предыдущей строке совпадает с текущей)
  i := 1;
  while i <= na.Count - 4 do begin
    if (na.G(i, 'qnt') = na.G(i - 1, 'qnt')) and (na.G(i, 'id_departament') = null) then begin
      Delete(na.V, i, 1);
      na.SetValue(i - 1, 'is_title', 1);
    end;
    Inc(i);
  end;
  i := 0;
  qn := 0;
  qnp := 0;
  qnm := 0;
  qdn := 0;
  while i <= na.Count - 4 do begin
    if na.G(i, 'id_departament') = null then begin
      na.SetValue(i, 'departament', 'По всем подразделениям:');
      na.SetValue(i, 'qnt_plan', qdp);
      na.SetValue(i, 'qnt_need', qdn);
      if na.G(i, 'qnt_plan').AsInteger <> 0 then
        na.SetValue(i, 'qnt_need', qdp - na.G(i, 'qnt'));
    end
    else if na.G(i, 'qnt_plan') <> null then begin
      qdp := qdp + na.G(i, 'qnt_plan').AsInteger;
      qdn := qdn + na.G(i, 'qnt_need').AsInteger;
      qnp := qnp + Max(na.G(i, 'qnt_need').AsInteger, 0);
      qnm := qnm + Min(na.G(i, 'qnt_need').AsInteger, 0);
    end;
    if na.G(i, 'is_title') = 1 then begin
      qdp := 0;
      qdn := 0;
    end;
    Inc(i);
  end;
  na.SetValue(na.Count - 1, 'qnt_need', qnp + qnm);
  i := 0;
  while i <= na.Count - 4 do begin
    if na.G(i, 'id_departament') = null then begin
      //na.SetValue(i, 'qnt_plan', null);
      //na.SetValue(i, 'qnt_need', null);
      na.SetValue(i, 'schedule', null);
    end;
    if (na.G(i, 'is_title') = 1) or (na.G(i, 'id_departament') = null) then begin
      //в режиме "по внутренним должностям" id_job - не официальный id (см. GetData/v_w_staff_schedule_internal),
      //ArSalary же ключуется официальным id_job из v_w_payroll_calc_item - поиск по нему здесь неверен и
      //пропускается, salary_avg остается пустым (см. заголовочный комментарий модуля)
      if not bInternal then begin
        j := A.PosInArray(na.G(i, 'id_job'), ArSalary, 0);
        if j >= 0 then
          na.SetValue(i, 'salary_avg', ArSalary[j][1]);
      end;
//      j := A.PosInArray(na.G(i, 'id_job'), ArSalaryPlan, 0);
      na.SetValue(i, 'salary_wo_ndfl', Round(na.G(i, 'salary_avg').AsInteger * 0.87));
      na.SetValue(i, 'budget', na.G(i, 'salary_plan').AsInteger * na.G(i, 'qnt').AsInteger);
      na.SetValue(i, 'salary_diff', na.G(i, 'salary_avg').AsInteger - na.G(i, 'salary_sity').AsInteger);
      na.SetValue(i, 'budget_sity', na.G(i, 'salary_sity').AsInteger * na.G(i, 'qnt').AsInteger);
      na.SetValue(i, 'budget_diff', na.G(i, 'budget').AsInteger - na.G(i, 'budget_sity').AsInteger);
    end;
    inc(i);
  end;
  Frg1.SetInitData(na);
end;


procedure TFrmWGrepStaffSchedule.BuildView2(var na: TNamedArr; const ArSalary: TVarDynArray2; bInternal: Boolean);
//вид 2: na - строки "специальность в подразделении", упорядоченные по подразделению и специальности (см. GetData).
//перед строками каждого подразделения вставляем строку-заголовок (is_title = 1): подразделение и общее количество
//работающих в нем (сумма численности по специальностям; для з/п - суммы бюджета), в конце - итоги по офису, цеху и всего.
//порядок полей: rownum, is_title, id_job, id_departament, office, job, departament, qnt, qnt_wo_org, qnt_plan, qnt_need,
//schedule, salary_avg, salary_plan, salary_wo_ndfl, salary_diff, salary_sity, budget, budget_sity, budget_diff
var
  i, j, k, t, n, qt, qwo, qo, qc, qon, qcn, bud, bsc: Integer;
  rows: TVarDynArray2;
  dep: Variant;
begin
  n := na.Count;
  rows := [];
  qo := 0;
  qc := 0;
  qon := 0;
  qcn := 0;
  i := 0;
  while i < n do begin
    dep := na.G(i, 'id_departament');
    qt := 0;
    qwo := 0;
    j := i;
    while (j < n) and (na.G(j, 'id_departament') = dep) do begin
      qt := qt + na.G(j, 'qnt').AsInteger;
      qwo := qwo + na.G(j, 'qnt_wo_org').AsInteger;
      Inc(j);
    end;
    if na.G(i, 'office') = 'цех' then begin
      qc := qc + qt;
      qcn := qcn + qwo;
    end
    else begin
      qo := qo + qt;
      qon := qon + qwo;
    end;
    //строка-заголовок подразделения
    rows := rows + [[0, 1, null, dep, na.G(i, 'office'), na.G(i, 'departament').AsString + '   -   работающих: ' + IntToStr(qt), na.G(i, 'departament'),
      qt, qwo, null, null, null, null, null, null, null, null, null, null, null]];
    for k := i to j - 1 do
      rows := rows + [na.V[k]];
    i := j;
  end;
  //итоги
  rows := rows + [[0, null, null, null, 'Итого:', 'Итого: офис', 'офис', qo, qon, null, null, null, null, null, null, null, null, null, null, null]];
  rows := rows + [[0, null, null, null, 'Итого:', 'Итого: цех', 'цех', qc, qcn, null, null, null, null, null, null, null, null, null, null, null]];
  rows := rows + [[0, null, null, null, 'Итого:', 'Итого: всего', 'всего', qc + qo, qon + qcn, null, null, null, null, null, null, null, null, null, null, null]];
  na.V := rows;
  for i := 0 to na.Count - 1 do
    na.SetValue(i, 'rownum', i + 1);
  //данные по з/п для строк "специальность в подразделении" (для режима по внутренним должностям средняя начисленная не считается,
  //см. заголовок модуля)
  for i := 0 to na.Count - 1 do
    if (na.G(i, 'is_title') <> 1) and (na.G(i, 'id_departament') <> null) then begin
      if not bInternal then begin
        j := A.PosInArray(na.G(i, 'id_job'), ArSalary, 0);
        if j >= 0 then
          na.SetValue(i, 'salary_avg', ArSalary[j][1]);
      end;
      na.SetValue(i, 'salary_wo_ndfl', Round(na.G(i, 'salary_avg').AsInteger * 0.87));
      na.SetValue(i, 'budget', na.G(i, 'salary_plan').AsInteger * na.G(i, 'qnt').AsInteger);
      na.SetValue(i, 'salary_diff', na.G(i, 'salary_avg').AsInteger - na.G(i, 'salary_sity').AsInteger);
      na.SetValue(i, 'budget_sity', na.G(i, 'salary_sity').AsInteger * na.G(i, 'qnt').AsInteger);
      na.SetValue(i, 'budget_diff', na.G(i, 'budget').AsInteger - na.G(i, 'budget_sity').AsInteger);
    end;
  //суммы бюджета в строках-заголовках подразделений
  t := -1;
  bud := 0;
  bsc := 0;
  for i := 0 to na.Count do begin
    if (i = na.Count) or (na.G(i, 'is_title') = 1) or (na.G(i, 'id_departament') = null) then begin
      if t >= 0 then begin
        na.SetValue(t, 'budget', S.NullIf0(bud));
        na.SetValue(t, 'budget_sity', S.NullIf0(bsc));
        na.SetValue(t, 'budget_diff', S.NullIf0(bud - bsc));
      end;
      t := -1;
      if (i < na.Count) and (na.G(i, 'is_title') = 1) then begin
        t := i;
        bud := 0;
        bsc := 0;
      end;
    end
    else if t >= 0 then begin
      bud := bud + na.G(i, 'budget').AsInteger;
      bsc := bsc + na.G(i, 'budget_sity').AsInteger;
    end;
  end;
end;

procedure TFrmWGrepStaffSchedule.Frg1DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
//вид 2: строка-заголовок подразделения рисуется сплошной на всю ширину видимых столбцов. все ячейки строки до последней
//рисуются стандартно (серый фон, жирный текст в первом столбце - это же и запасной вариант отображения), а в ячейке последнего
//видимого столбца поверх них рисуется сплошная полоса с текстом от левого края первого столбца
var
  i, LastVis, SumW, x1, y: Integer;
  R: TRect;
  st: string;
begin
  if (not cSpanTitleRows) or (not FView2) then
    Exit;
  if not (Frg1.GetValue('is_title') = 1) then
    Exit;
  LastVis := -1;
  SumW := 0;
  for i := 0 to Sender.Columns.Count - 1 do
    if Sender.Columns[i].Visible then begin
      LastVis := i;
      SumW := SumW + Sender.Columns[i].Width;
    end;
  if Column.Index <> LastVis then
    Exit;
{  if Column.Index = 1 then begin
    Processed := True;
    Exit;
  end;}
  //левый край первого видимого столбца (при горизонтальной прокрутке будет за краем, тогда рисуем от левого края грида)
  x1 := Max(ARect.Right + 1 - SumW, 0);
  //x1 - 16 !--- иначе в заголовке выглядывает текст первого с толдбца
  R := Rect(x1 - 16, ARect.Top, ARect.Right, ARect.Bottom);
  st := Frg1.GetValue('job').AsString;
  with Sender.Canvas do begin
    Brush.Style := bsSolid;
    Brush.Color := Params.Background;
    FillRect(R);
    Font.Assign(Params.Font);
    Font.Style := [fsBold];
    Brush.Style := bsClear;
    y := R.Top + (R.Bottom - R.Top - TextHeight(st)) div 2;
    TextOut(R.Left + 4, y, st);
  end;
  Processed := True;
end;

procedure TFrmWGrepStaffSchedule.FromExcel;
var
  i, j, k: Integer;
  st, st1: string;
  v, v1, v2: Variant;
  b, b1, b2: Boolean;
  XlsFile: TXlsMemFileEh;
  sh, sh1: TXlsWorksheetEh;
  ArXls, va2: TVarDynArray2;
  EmplCn: TVarDynArray;
  e1, e2: Extended;
begin
  va2:=Q.QLoad('select id, name from ref_jobs', []);
  //выберем файл
  MyData.OpenDialog1.Filter := 'файлы Excel (*.xlsx)|*.xlsx';
  if not MyData.OpenDialog1.Execute then
    Exit;
  if not CreateTXlsMemFileEhFromExists(MyData.OpenDialog1.FileName, True, '$2', XlsFile, st) then
    Exit;
  //получим список совместителей
  EmplCn := Q.QLoadCol('select id from w_employees where is_concurrent = 1', []);
  //загрузим в массив данные из эксель со второй строки до первой пустой
  ArXls := [];
  sh := XlsFile.Workbook.Worksheets[0];
  for i := 3 to 2000 do begin
    if (sh.Cells[0, i].Value.AsString = '') then
      break;
    j:=a.PosInArray(sh.Cells[0, i].Value.AsString, va2, 1);
    if j >= 0 then begin
      Q.QExecSql('insert into w_ref_staff_schedule (id_job, dt, type, value) values (:j$i, :dt$d, 3, :v$i)', [va2[j][0], Date, sh.Cells[16, i].Value.AsInteger]);
    end;
  end;
  sh := XlsFile.Workbook.Worksheets[1];
  for i := 3 to 2000 do begin
    if (sh.Cells[0, i].Value.AsString = '') then
      break;
    j:=a.PosInArray(sh.Cells[0, i].Value.AsString, va2, 1);
    if j >= 0 then begin
      Q.QExecSql('insert into w_ref_staff_schedule (id_job, dt, type, value) values (:j$i, :dt$d, 3, :v$i)', [va2[j][0], Date, sh.Cells[13, i].Value.AsInteger]);
    end;
  end;
  for i := 0 to Frg1.GetCount - 1 do
   if Frg1.GetValue('id_departament', i) <> null then
     Q.QExecSql('insert into w_ref_staff_schedule (id_job, id_departament, dt, type, value) values (:j$i, :d$i, :dt$d, 1, :v$i)',
       [Frg1.GetValue('id_job',i), Frg1.GetValue('id_departament',i), Date,Frg1.GetValue('qnt',i)]);
end;


end.
