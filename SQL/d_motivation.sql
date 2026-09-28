--------------------------------------------------------------------------------
--
-- Расчет мотивации сотрудников
--
--------------------------------------------------------------------------------

--w_motivation_coefficients - справочник коэффициентов мотивации (критериев эффективности),
--общий список, используются в привязке к должностям (см. *_for_job ниже). pos - позиция в списке
--(только для визуальной сортировки этого справочника, см. p_ExchangePositions/кнопки "Выше"/"Ниже"),
--по умолчанию = id (новые коэффициенты - в конец списка).
--fact_value - текущее значение производственного показателя, по которому вручную выбирается
--selected_rating (номер оценки, см. w_motivation_coefficients_rates.rating) - в отличие от value
--в самой w_motivation_coefficients_rates (это уже коэффициент премии для выбранной оценки), эти
--два значения между собой никак не соотносятся. В перспективе возможен автовыбор оценки по
--диапазону fact_value, но там есть словесные исключения из общего правила - пока выбор вручную,
--через хранимую процедуру p_w_motivation_coefficients_set_value (см. ниже).
--Для персональных коэффициентов (is_personal = 1) fact_value/selected_rating здесь не задаются -
--значение считается индивидуально по каждому сотруднику, в другом месте (расчёт по сотруднику).
--
create table w_motivation_coefficients (
  id number(11) primary key,
  pos number,                             --позиция в списке (только для сортировки, см. комментарий выше) --!+
  name varchar2(150) not null,           --наименование коэффициента
  is_personal number(1) default 0,       --коэффициент задается индивидуально для каждого сотрудника
  description varchar2(4000),            --описание
  comm_for_eval varchar2(4000),          --комментарий к выставлению оценки
  fact_value number,                     --текущее значение производственного показателя
  selected_rating number(1),             --выбранная оценка (см. w_motivation_coefficients_rates.rating)
  ids_value_setters varchar2(400),       --айди пользователей, которым разрешено задавать пороги/значение
  constraint ck_w_motivation_coefficients_sel_rating check (selected_rating between 1 and 4)
);

create unique index idx_w_motivation_coefficients on w_motivation_coefficients(lower(name));

create sequence sq_w_motivation_coefficients nocache start with 1;

create or replace trigger trg_w_motivation_coefficients_bi_r --!+
  before insert on w_motivation_coefficients for each row
begin
  :new.id := sq_w_motivation_coefficients.nextval;
  :new.pos := :new.id;
end;
/

--!go begin
update w_motivation_coefficients set pos = id where pos is null;
--!go end

--------------------------------------------------------------------------------
--w_motivation_coefficients_rates - пороговые значения коэффициента по 4 фиксированным оценкам.
--rating: 1-отлично, 2-хорошо, 3-удовлетворительно, 4-зона роста. Строки создаются автоматически,
--все 4 сразу, при добавлении коэффициента (см. триггер ниже) - добавлять/удалять их по отдельности
--нельзя, только редактировать value/comm/range_from/range_to/is_outside_range. value - коэффициент
--премии, применяемый при расчете, если для данного коэффициента выбрана именно эта оценка (см.
--w_motivation_coefficients.selected_rating). range_from/range_to - диапазон значений производственного
--показателя для этой оценки (оба включительно, null - граница не задана, т.е. диапазон открыт в эту
--сторону). is_outside_range: 0 - оценке соответствует показатель ВНУТРИ диапазона [range_from;
--range_to], 1 - оценке соответствует показатель ВНЕ диапазона (< range_from или > range_to) - для
--случаев, когда одной оценке соответствуют сразу два разрозненных интервала по краям шкалы
--(например, "зона роста" = менее 25 или более 40 - это одна строка с range_from=25, range_to=40,
--is_outside_range=1). Соседние диапазоны не должны пересекаться - границы всегда принадлежат
--"внутренней" оценке (в перспективе - для автоматического подбора оценки по значению показателя,
--с учетом словесных исключений).
--
create table w_motivation_coefficients_rates (
  id number(11) primary key,
  id_coefficient number(11) not null,    --айди коэффициента в справочнике
  rating number(1) not null,             --оценка: 1-отлично, 2-хорошо, 3-удовлетворительно, 4-зона роста
  comm varchar2(100),                    --комментарий к данной градации оценки
  value number,                          --коэффициент премии для этой оценки
  range_from number(12,2),               --нижняя граница диапазона показателя для этой оценки (включительно), null - без нижней границы     --$+
  range_to number(12,2),                 --верхняя граница диапазона показателя для этой оценки (включительно), null - без верхней границы   --$+
  is_outside_range number(1) default 0,  --0 - показатель внутри диапазона, 1 - показатель вне диапазона (< range_from или > range_to)       --$+  
  constraint fk_w_motivation_coefficients_rates_id_coefficient foreign key (id_coefficient) references w_motivation_coefficients(id) on delete cascade,
  constraint ck_w_motivation_coefficients_rates_rating check (rating between 1 and 4)
);

create unique index idx_w_motivation_coefficients_rates on w_motivation_coefficients_rates(id_coefficient, rating);

create sequence sq_w_motivation_coefficients_rates nocache start with 1;

create or replace trigger trg_w_motivation_coefficients_rates_bi_r
  before insert on w_motivation_coefficients_rates for each row
begin
  :new.id := sq_w_motivation_coefficients_rates.nextval;
end;
/

create or replace trigger trg_w_motivation_coefficients_ai_r
  after insert on w_motivation_coefficients for each row
begin
  insert into w_motivation_coefficients_rates (id_coefficient, rating) values (:new.id, 1);
  insert into w_motivation_coefficients_rates (id_coefficient, rating) values (:new.id, 2);
  insert into w_motivation_coefficients_rates (id_coefficient, rating) values (:new.id, 3);
  insert into w_motivation_coefficients_rates (id_coefficient, rating) values (:new.id, 4);
end;
/

--------------------------------------------------------------------------------
--вью для детальной панели коэффициента - 4 строки (по одной на каждую оценку), с текстовой расшифровкой rating
--
create or replace view v_w_motivation_coefficients_rates as  --$+
select 
--пороги коэффициента с текстовой расшифровкой оценки и признаком того, что оценка сейчас выбрана
  r.id,
  r.id_coefficient,
  r.rating,
  case r.rating
    when 1 then 'Отлично'
    when 2 then 'Хорошо'
    when 3 then 'Удовлетворительно'
    when 4 then 'Зона роста'
  end rating_name,
  r.comm,
  r.value,
  r.range_from,
  r.range_to,
  r.is_outside_range,
  case when r.rating = c.selected_rating then 1 else 0 end is_selected
from 
  w_motivation_coefficients_rates r, 
  w_motivation_coefficients c
where 
  c.id = r.id_coefficient
;

--------------------------------------------------------------------------------
--вью для основной таблицы - коэффициент вместе с айди/названием выбранной оценки (если выбрана)
--и текстовым списком имён пользователей, которым разрешено задавать значение (getusernames - см.
--использование в v_w_departaments, d_workers_new.sql)
--
create or replace view v_w_motivation_coefficients as --!+
select 
--коэффициент вместе с выбранной оценкой (если выбрана) и именами тех, кто может задать значение
  c.id,
  c.pos,
  c.name,
  c.is_personal,
  c.description,
  c.comm_for_eval,
  c.fact_value,
  c.selected_rating,
  v.id id_selected_rate,
  v.rating_name selected_rating_name,
  v.value selected_rate_value,
  c.ids_value_setters,
  getusernames(c.ids_value_setters) value_setters_names
from 
  w_motivation_coefficients c, 
  v_w_motivation_coefficients_rates v
where 
  v.id_coefficient (+) = c.id
  and v.rating (+) = c.selected_rating
;

--------------------------------------------------------------------------------
--ввод текущего значения коэффициента (fact_value) и выбор оценки (selected_rating) - только через
--эту процедуру (не прямым update), она же перепроверяет на сервере то, что уже проверено в форме:
--коэффициент не персональный и пользователь есть в списке ids_value_setters.
--
create or replace procedure p_w_motivation_coefficients_set_value(
  p_id_coefficient number, p_user_id number, p_fact_value number, p_rating number
) as
  v_is_personal number;
  v_ids_value_setters varchar2(400);
begin
  select is_personal, ids_value_setters into v_is_personal, v_ids_value_setters
    from w_motivation_coefficients where id = p_id_coefficient;
  if nvl(v_is_personal, 0) = 1 then
    raise_application_error(-20001, 'Коэффициент персональный - значение задаётся в расчёте по сотруднику');
  end if;
  if IsStInCommaSt(p_user_id, v_ids_value_setters) <> 1 then
    raise_application_error(-20002, 'Нет прав на ввод значения этого коэффициента');
  end if;
  update w_motivation_coefficients set fact_value = p_fact_value, selected_rating = p_rating where id = p_id_coefficient;
end;
/


/*  
--------------------------------------------------------------------------------
--таблица w_motivation_coefficients
--значений коэффициентов и их интервалы применительно к оценке работы сотрудника на каждый календарный месяц 
--
create table w_motivation_coefficient_values (
  id number(11) primary key,
  id_coefficient number(11),       --айди коэффициента в родительской таблице
  dt date,                         --дата (всегда 1е число месяца)
  k1 number,                       --начальное значение коэффициента для оценки "отлично"
  k2 number,                       --начальное значение коэффициента для оценки "хорошо" 
  k3 number,                       --начальное значение коэффициента для оценки "удовлетворительно"
  k4 number,                       --начальное значение коэффициента для оценки "зона роста"
  value number,                    --рассчитанное значение коэффициента на данную дату
  constraint fk_w_motivation_coefficient_values foreign key (id_coefficient) references w_motivation_coefficients(id) 
);

create unique index uk_w_motivation_coefficient_values on w_motivation_coefficient_values(id_coefficient, dt);

create sequence sq_w_motivation_coefficient_values nocache start with 1;

create or replace trigger trg_w_motivation_coefficient_values_bi_r 
  before insert on w_motivation_coefficient_values for each row
begin
  :new.id := sq_w_motivation_coefficient_values.nextval;  
end;
/
*/
--------------------------------------------------------------------------------
--w_motivation_coefficient_for_job - привязка коэффициента мотивации (общий справочник, см.
--w_motivation_coefficients выше) к конкретной внутренней должности - для отображения набора
--критериев по должности/сотруднику (см. uFrmWMotivationTest.pas, форма "Мотивация - Тест").
--weight - доля вознаграждения, которую этот критерий занимает в общей премии по данной должности
--(0..1, как доля, не проценты - на экране отображается умноженной на 100); у разных должностей
--один и тот же коэффициент может иметь разный вес (или не использоваться вовсе). pos - порядок
--отображения критериев для данной должности (присваивается по порядку добавления через кнопку
--"Добавить критерий..." в форме - отдельного экрана для его смены пока нет).
--
--примечание (28.09.2026): до этой правки в файле лежала незавершенная, никогда не выполнявшаяся
--(без тега --!/--$) заготовка "pk_w_motivation_coefficient_for_job" - без сиквенса/триггера на id
--и без поля веса; переименована в общепринятое для этого файла именование (w_..._for_job, как у
--w_motivation_negative_remarks_for_job/w_motivation_w_work_emergencies_for_job выше) и дополнена.
--
create table w_motivation_coefficient_for_job (
  id number(11) primary key,
  id_job_internal number(11) not null,   --айди должности (внутренней)
  id_coefficient number(11) not null,    --айди коэффициента в общем справочнике (w_motivation_coefficients)
  pos number,                            --порядок отображения критериев для данной должности
  weight number(5,4),                    --доля вознаграждения (0..1), null - вес не задан
  constraint fk_w_motivation_coeff_for_job_id_job_internal foreign key (id_job_internal) references w_jobs_internal(id),
  constraint fk_w_motivation_coeff_for_job_id_coefficient foreign key (id_coefficient) references w_motivation_coefficients(id)
);

create unique index idx_w_motivation_coeff_for_job on w_motivation_coefficient_for_job(id_job_internal, id_coefficient);

create sequence sq_w_motivation_coefficient_for_job nocache start with 1;

create or replace trigger trg_w_motivation_coeff_for_job_bi_r
  before insert on w_motivation_coefficient_for_job for each row
begin
  :new.id := sq_w_motivation_coefficient_for_job.nextval;
end;
/

--------------------------------------------------------------------------------
--вью для формы отображения (uFrmWMotivationTest.pas) - привязка коэффициента к должности вместе с
--его данными из общего справочника (имя/описание/персональный ли)
--
create or replace view v_w_motivation_coefficient_for_job as
select
  f.id,
  f.id_job_internal,
  f.id_coefficient,
  f.pos,
  f.weight,
  c.name,
  c.description,
  c.is_personal,
  c.comm_for_eval
from
  w_motivation_coefficient_for_job f,
  w_motivation_coefficients c
where
  c.id = f.id_coefficient
;

--------------------------------------------------------------------------------
--вью для выбора сотрудника в форме отображения (uFrmWMotivationTest.pas, режим "по сотруднику") -
--текущая (последняя, без учета увольнения) официальная и внутренняя должность работающего
--сотрудника; та же идиома "последняя запись по id_employee", что и в last_any_event внутри
--v_w_employees (см. d_workers_new.sql).
--
create or replace view v_w_motivation_employees_by_job as
select
  e.id,
  f_fio(e.f, e.i, e.o) as name,
  a.id_job,
  j.id_job_internal
from
  w_employees e,
  (select id_employee, id_job, is_terminated,
     row_number() over (partition by id_employee order by id desc) as rn
     from w_employee_properties where is_terminated <> 1) a,
  w_jobs j
where
  a.id_employee = e.id
  and a.rn = 1
  and j.id = a.id_job
;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--w_motivation_negative_remarks - справочник грубых замечаний (общий список формулировок).
--is_global - общее для всех должностей, pos - позиция среди глобальных записей.
--
create table w_motivation_negative_remarks (
  id number(11) primary key,
  name varchar2(1000) not null,    --текст замечания
  comm varchar2(400),              --комментарий
  is_global number(1) default 0,   --глобальное (общее для всех должностей)
  pos number,                      --позиция среди глобальных записей
  active number(1) default 1       --используется
);

create unique index idx_w_motivation_negative_remarks on w_motivation_negative_remarks(lower(name));

create sequence sq_w_motivation_negative_remarks nocache start with 1;

create or replace trigger trg_w_motivation_negative_remarks_bi_r
  before insert on w_motivation_negative_remarks for each row
begin
  :new.id := sq_w_motivation_negative_remarks.nextval;
end;
/

--------------------------------------------------------------------------------
--w_motivation_negative_remarks_for_job - привязка замечаний к конкретной (внутренней) должности,
--свой порядок (pos) для каждой должности.
--
create table w_motivation_negative_remarks_for_job (
  id number(11) primary key,
  id_job_internal number(11) not null,   --айди должности (внутренней)
  id_remark number(11) not null,         --айди замечания в справочнике w_motivation_negative_remarks
  pos number,                            --позиция в списке для данной должности
  constraint fk_w_motivation_negative_remarks_for_job_id_job_internal foreign key (id_job_internal) references w_jobs_internal(id),
  constraint fk_w_motivation_negative_remarks_for_job_id_remark foreign key (id_remark) references w_motivation_negative_remarks(id)
);

create unique index idx_w_motivation_negative_remarks_for_job on w_motivation_negative_remarks_for_job(id_job_internal, id_remark);

create sequence sq_w_motivation_negative_remarks_for_job nocache start with 1;

create or replace trigger trg_w_motivation_negative_remarks_for_job_bi_r
  before insert on w_motivation_negative_remarks_for_job for each row
begin
  :new.id := sq_w_motivation_negative_remarks_for_job.nextval;
end;
/

--------------------------------------------------------------------------------
--w_motivation_w_work_emergencies - справочник чрезвычайных ситуаций, структура как у
--w_motivation_negative_remarks.
--
create table w_motivation_w_work_emergencies (
  id number(11) primary key,
  name varchar2(1000) not null,    --текст записи о чрезвычайной ситуации
  comm varchar2(400),              --комментарий
  is_global number(1) default 0,   --глобальное (общее для всех должностей)
  pos number,                      --позиция среди глобальных записей
  active number(1) default 1       --используется
);

create unique index idx_w_motivation_w_work_emergencies on w_motivation_w_work_emergencies(lower(name));

create sequence sq_w_motivation_w_work_emergencies nocache start with 1;

create or replace trigger trg_w_motivation_w_work_emergencies_bi_r
  before insert on w_motivation_w_work_emergencies for each row
begin
  :new.id := sq_w_motivation_w_work_emergencies.nextval;
end;
/

--------------------------------------------------------------------------------
--w_motivation_w_work_emergencies_for_job - привязка записей к конкретной (внутренней) должности,
--структура как у w_motivation_negative_remarks_for_job.
--
create table w_motivation_w_work_emergencies_for_job (
  id number(11) primary key,
  id_job_internal number(11) not null,   --айди должности (внутренней)
  id_remark number(11) not null,         --айди записи в справочнике w_motivation_w_work_emergencies
  pos number,                            --позиция в списке для данной должности
  constraint fk_w_motivation_w_work_emergencies_for_job_id_job_internal foreign key (id_job_internal) references w_jobs_internal(id),
  constraint fk_w_motivation_w_work_emergencies_for_job_id_remark foreign key (id_remark) references w_motivation_w_work_emergencies(id)
);

create unique index idx_w_motivation_w_work_emergencies_for_job on w_motivation_w_work_emergencies_for_job(id_job_internal, id_remark);

create sequence sq_w_motivation_w_work_emergencies_for_job nocache start with 1;

create or replace trigger trg_w_motivation_w_work_emergencies_for_job_bi_r
  before insert on w_motivation_w_work_emergencies_for_job for each row
begin
  :new.id := sq_w_motivation_w_work_emergencies_for_job.nextval;
end;
/

--------------------------------------------------------------------------------
--вью для детальной панели по должности (текст замечания/ЧС - из справочника)
--
create or replace view v_w_motivation_negative_remarks_for_job as
select 
--привязка замечания к должности с текстом из справочника
  f.id,
  f.id_job_internal,
  f.id_remark,
  f.pos,
  r.name,
  r.comm,
  r.is_global
from 
  w_motivation_negative_remarks_for_job f, 
  w_motivation_negative_remarks r
where 
  r.id = f.id_remark
;

create or replace view v_w_motivation_w_work_emergencies_for_job as
select 
--привязка записи к должности с текстом из справочника
  f.id,
  f.id_job_internal,
  f.id_remark,
  f.pos,
  r.name,
  r.comm,
  r.is_global
from 
  w_motivation_w_work_emergencies_for_job f, 
  w_motivation_w_work_emergencies r
where 
  r.id = f.id_remark
;
