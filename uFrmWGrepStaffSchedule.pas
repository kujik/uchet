{
Штатное расписание (27.09.2026, см. !алгоритмы.txt).

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

Также попутно исправлены две устаревшие ссылки на переименованные объекты бд (остались после
переименования в w_ref_staff_schedule/v_w_staff_schedule): запись плановой численности/рынка и
импорт из Excel писали в несуществующую уже "ref_staff_schedule" (без w_), а выборка начисленной
средней з/п (ArSalary, см. GetData) джойнилась со старой "v_staff_schedule" (без w_).
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
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure SetMode;
    procedure GetData;
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
  if User.Roles([], [rW_Rep_StaffSchedule_V_S]) then
    Frg1.CreateAddControls('1', cntCheck, 'Данные по з/п', 'chbSalary', '', -1, yrefC, 100);
  if User.Roles([], [rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C, rW_Rep_StaffSchedule_Ch_SP, rW_Rep_StaffSchedule_Ch_SS]) then
    Frg1.CreateAddControls('1', cntCheck, 'Ввод данных', 'chbEdit', '', -1, yrefC, 100);
  Frg1.CreateAddControls('1', cntCheck, 'По внутренним должностям', 'chbInternal', '', -1, yrefC, 160);
  Q.QLoadToDBComboBoxEh('select ''Все'' from dual union select distinct area_shortname || '' - '' || office from v_w_departaments where active = 1 order by 1', [], TDBComboBoxEh(Frg1.FindComponent('cmbArea')), cntComboL);
  Frg1.InfoArray:=[[
    'Штатное расписание.'#13#10
  ]];
  //данные из массива
  Frg1.SetInitData([]);
  Result := Inherited;
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
  if (FieldName = 'qnt_need') and (Fr.GetValue('qnt_need') <> null) then begin
    if Fr.GetValue('qnt_need') < 0 then
      Params.Background := clmyPink
    else if Fr.GetValue('qnt_need') > 0 then
      Params.Background := clmyGreen;
  end;
end;

procedure TFrmWGrepStaffSchedule.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  ReadOnly := (Fr.GetValue('id_departament') = null) or (
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
end;

procedure TFrmWGrepStaffSchedule.SetMode;
var
  b, bInternal : Boolean;
begin
  b := Cth.DteValueIsDate(Frg1.FindComponent('edtd1')) and (Frg1.GetControlValue('edtd1') = Date);
  bInternal := Frg1.GetControlValue('chbInternal') = 1;
  Frg1.Opt.SetColFeature('1', 'i', not ((Frg1.GetControlValue('chbSalary') = 1) and User.Role(rW_Rep_StaffSchedule_V_S)), True);
  //в режиме "по внутренним должностям" qnt_plan/salary_sity - агрегаты по нескольким официальным
  //должностям, править их через этот отчет нельзя (см. заголовочный комментарий модуля)
  Frg1.Opt.SetColFeature('qnt_plan', 'e', (not bInternal) and (Frg1.GetControlValue('chbEdit') = 1)  and b and User.Roles([], [rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C]), False);
  //salary_plan теперь в обоих режимах берется из w_job_salaries и правится через uFrmWGjrnJobSalaries.pas,
  //через этот отчет больше не редактируется (см. заголовочный комментарий модуля)
  Frg1.Opt.SetColFeature('salary_sity', 'e', (not bInternal) and (Frg1.GetControlValue('chbEdit') = 1) and b and User.Role(rW_Rep_StaffSchedule_Ch_SS), False);
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
  bInternal: Boolean;
begin
  if (not Cth.DteValueIsDate(Frg1.FindComponent('edtd1'))) or (S.NSt(Frg1.GetControlValue('cmbArea')) = '') then
    Exit;
  bInternal := Frg1.GetControlValue('chbInternal') = 1;
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
  if bInternal then
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
