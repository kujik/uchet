--------------------------------------------------------------------------------
--
-- Расчет мотивации сотрудников
--
--------------------------------------------------------------------------------

--w_motivation_coefficients - справочник коэффициентов мотивации (критериев эффективности),
--общий список, используются в привязке к должностям (см. *_for_job ниже). pos - позиция в списке
--(только для визуальной сортировки этого справочника, см. p_ExchangePositions/кнопки "Выше"/"Ниже"),
--по умолчанию = id (новые коэффициенты - в конец списка).
--fact_value - текущее значение производственного показателя, ВСЕГДА вводится пользователем вручную (тем,
--кто есть в ids_value_setters) через хранимую процедуру p_w_motivation_coefficients_set_value (см. ниже).
--Оценка (1-4) в БД НЕ хранится: она вычисляется динамически, каждый раз заново, по текущему fact_value и
--текущим диапазонам w_motivation_coefficients_rates (и диапазоны, и значение могут меняться в процессе и
--разными людьми) - см. вью v_w_motivation_coefficients_rates (is_selected) и v_w_motivation_coefficients
--(selected_rating и др.). Оценка определяется только если диапазоны ВСЕХ 4 оценок заданы корректно и не
--пересекаются (range_state = 0) и значение попало ровно в один из них; иначе оценка не определена.
--unit_name - единица измерения значения показателя (процент, раз, ...), произвольный короткий текст, пусто -
--без обозначения.
--decode_name1..3/decode_value1..3 - таблица-расшифровка значения (3 строки, 2 колонки: название и значение,
--любые тексты до 150 символов, в т.ч. пустые). Задаётся тем, кто вводит значение, вместе с ним (та же
--процедура), выводится в расчётной сетке. Пример:
--  Норма времени текущий месяц | 168.00
--  Фактическая выработка       | 168.00
--  Итог                        | 100.00%
--Для персональных коэффициентов (is_personal = 1) fact_value/расшифровка здесь не задаются -
--значение считается индивидуально по каждому сотруднику, в другом месте (расчёт по сотруднику).
--
create table w_motivation_coefficients (
  id number(11) primary key,
  pos number,                             --позиция в списке (только для сортировки, см. комментарий выше) --$+
  name varchar2(150) not null,           --наименование коэффициента
  is_personal number(1) default 0,       --коэффициент задается индивидуально для каждого сотрудника
  description varchar2(4000),            --описание
  comm_for_eval varchar2(4000),          --комментарий к выставлению оценки
  fact_value number,                     --текущее значение производственного показателя (вводится вручную)
  ids_value_setters varchar2(400),       --айди пользователей, которым разрешено задавать пороги/значение
  unit_name varchar2(30 char),           --единица измерения значения (%, раз, ...), пусто - без обозначения      --$+
  decode_name1 varchar2(150 char),       --расшифровка значения, строка 1, название                               --$+
  decode_value1 varchar2(150 char),      --расшифровка значения, строка 1, значение                               --$+
  decode_name2 varchar2(150 char),       --расшифровка значения, строка 2, название                               --$+
  decode_value2 varchar2(150 char),      --расшифровка значения, строка 2, значение                               --$+
  decode_name3 varchar2(150 char),       --расшифровка значения, строка 3, название                               --$+
  decode_value3 varchar2(150 char)       --расшифровка значения, строка 3, значение                               --$+
);

create unique index idx_w_motivation_coefficients on w_motivation_coefficients(lower(name));

create sequence sq_w_motivation_coefficients nocache start with 1;

create or replace trigger trg_w_motivation_coefficients_bi_r --$+
  before insert on w_motivation_coefficients for each row
begin
  :new.id := sq_w_motivation_coefficients.nextval;
  :new.pos := :new.id;
end;
/

--$go begin
update w_motivation_coefficients set pos = id where pos is null;
--$go end

--------------------------------------------------------------------------------
--w_motivation_coefficients_rates - пороговые значения коэффициента по 4 фиксированным оценкам.
--rating: 1-отлично, 2-хорошо, 3-удовлетворительно, 4-зона роста. Строки создаются автоматически,
--все 4 сразу, при добавлении коэффициента (см. триггер ниже) - добавлять/удалять их по отдельности
--нельзя, только редактировать value/comm/range_from/range_to/is_outside_range. value - коэффициент
--премии, применяемый при расчете, если для данного коэффициента определилась именно эта оценка (она
--вычисляется динамически по fact_value и диапазонам - см. v_w_motivation_coefficients_rates.is_selected). range_from/range_to - диапазон значений производственного
--показателя для этой оценки (оба включительно, null - граница не задана, т.е. диапазон открыт в эту
--сторону). is_outside_range: 0 - оценке соответствует показатель ВНУТРИ диапазона [range_from;
--range_to], 1 - оценке соответствует показатель ВНЕ диапазона (< range_from или > range_to) - для
--случаев, когда одной оценке соответствуют сразу два разрозненных интервала по краям шкалы
--(например, "зона роста" = менее 25 или более 40 - это одна строка с range_from=25, range_to=40,
--is_outside_range=1). Диапазон обязателен для каждой из 4 оценок, диапазоны не должны пересекаться -
--границы всегда принадлежат "внутренней" оценке. Так как диапазоны задаются поодиночке (по строке на
--оценку), корректность проверяется во вью (range_state, см. v_w_motivation_rates_state): 0 - в порядке,
--1 - не задан (обе границы пусты), 2 - некорректен (range_from > range_to), 3 - пересекается с диапазоном
--другой оценки этого же коэффициента.
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
--вью-помощник: диапазоны значений (интервалы на числовой оси) каждой оценки коэффициента - для проверки
--пересечений. "Внутренний" диапазон [from; to] - один интервал, "внешний" (is_outside_range = 1) - до двух:
--(-бесконечность; from) и (to; +бесконечность). Бесконечность - +-1e38, lo_incl/hi_incl - включена ли
--граница. В выборку не попадают диапазоны с обеими пустыми границами и с range_from > range_to (они и
--так отмечаются как "не задан"/"некорректен" в v_w_motivation_rates_state).
--
create or replace view v_w_motivation_rate_intervals as --$+
select
  r.id_coefficient, r.rating,
  nvl(r.range_from, -1e38) lo, case when r.range_from is null then 0 else 1 end lo_incl,
  nvl(r.range_to, 1e38) hi, case when r.range_to is null then 0 else 1 end hi_incl
from
  w_motivation_coefficients_rates r
where
  nvl(r.is_outside_range, 0) = 0
  and (r.range_from is not null or r.range_to is not null)
  and (r.range_from is null or r.range_to is null or r.range_from <= r.range_to)
union all
select
  r.id_coefficient, r.rating, -1e38, 0, r.range_from, 0
from
  w_motivation_coefficients_rates r
where
  r.is_outside_range = 1
  and r.range_from is not null
  and (r.range_to is null or r.range_from <= r.range_to)
union all
select
  r.id_coefficient, r.rating, r.range_to, 0, 1e38, 0
from
  w_motivation_coefficients_rates r
where
  r.is_outside_range = 1
  and r.range_to is not null
  and (r.range_from is null or r.range_from <= r.range_to)
;

--------------------------------------------------------------------------------
--вью-помощник: состояние диапазона (range_state) каждой оценки и признак того, что текущее значение
--коэффициента (fact_value) попало в диапазон этой оценки (is_match). range_state: 0 - в порядке,
--1 - диапазон не задан (обе границы пусты), 2 - некорректен (range_from > range_to), 3 - пересекается
--с диапазоном другой оценки этого же коэффициента.
--
create or replace view v_w_motivation_rates_state as --$+
select
  r.id,
  r.id_coefficient,
  r.rating,
  r.comm,
  r.value,
  r.range_from,
  r.range_to,
  r.is_outside_range,
  c.fact_value,
  case
    when r.range_from is null and r.range_to is null then 1
    when r.range_from > r.range_to then 2
    when exists (
      select 1
      from v_w_motivation_rate_intervals a, v_w_motivation_rate_intervals b
      where a.id_coefficient = r.id_coefficient and a.rating = r.rating
        and b.id_coefficient = r.id_coefficient and b.rating <> r.rating
        and (a.lo < b.hi or (a.lo = b.hi and a.lo_incl = 1 and b.hi_incl = 1))
        and (b.lo < a.hi or (b.lo = a.hi and b.lo_incl = 1 and a.hi_incl = 1))
    ) then 3
    else 0
  end range_state,
  case
    when c.fact_value is null then 0
    when nvl(r.is_outside_range, 0) = 0
      and (r.range_from is not null or r.range_to is not null)
      and (r.range_from is null or c.fact_value >= r.range_from)
      and (r.range_to is null or c.fact_value <= r.range_to) then 1
    when r.is_outside_range = 1
      and ((r.range_from is not null and c.fact_value < r.range_from)
        or (r.range_to is not null and c.fact_value > r.range_to)) then 1
    else 0
  end is_match
from
  w_motivation_coefficients_rates r,
  w_motivation_coefficients c
where
  c.id = r.id_coefficient
;

--------------------------------------------------------------------------------
--вью для детальной панели коэффициента - 4 строки (по одной на каждую оценку), с текстовой расшифровкой
--rating, состоянием диапазона (маркер "не задан"/"некорректен"/"пересекается", range_state_name) и
--признаком того, что оценка сейчас соответствует значению коэффициента (is_selected). Оценка НЕ хранится,
--а вычисляется здесь при каждом чтении: выбрана та, в чей диапазон попало fact_value - но только если
--диапазоны ВСЕХ 4 оценок коэффициента в порядке (иначе подбор был бы недостоверным) и значение попало
--ровно в один диапазон.
--
create or replace view v_w_motivation_coefficients_rates as --$+
select
  s.id,
  s.id_coefficient,
  s.rating,
  case s.rating
    when 1 then 'Отлично'
    when 2 then 'Хорошо'
    when 3 then 'Удовлетворительно'
    when 4 then 'Зона роста'
  end rating_name,
  s.comm,
  s.value,
  s.range_from,
  s.range_to,
  s.is_outside_range,
  s.range_state,
  case s.range_state
    when 1 then 'Не задан'
    when 2 then 'Некорректен'
    when 3 then 'Пересекается'
  end range_state_name,
  case
    when s.is_match = 1
      and sum(s.is_match) over (partition by s.id_coefficient) = 1
      and max(s.range_state) over (partition by s.id_coefficient) = 0 then 1
    else 0
  end is_selected
from
  v_w_motivation_rates_state s
;

--------------------------------------------------------------------------------
--вью для основной таблицы - коэффициент вместе с вычисленной (динамически, не хранится) оценкой, если она
--определилась, и текстовым списком имён пользователей, которым разрешено задавать значение (getusernames -
--см. использование в v_w_departaments, d_workers_new.sql). range_state: 0 - диапазоны всех оценок в порядке,
--1 - хотя бы один диапазон не задан, 2 - хотя бы один некорректен или пересекается с другим.
--
create or replace view v_w_motivation_coefficients as --$+
select 
--коэффициент вместе с вычисленной оценкой (если определилась) и именами тех, кто может задать значение
  c.id,
  c.pos,
  c.name,
  c.is_personal,
  c.description,
  c.comm_for_eval,
  c.unit_name,
  c.fact_value,
  c.decode_name1,
  c.decode_value1,
  c.decode_name2,
  c.decode_value2,
  c.decode_name3,
  c.decode_value3,
  v.rating selected_rating,
  v.id id_selected_rate,
  v.rating_name selected_rating_name,
  v.value selected_rate_value,
  nvl(g.range_state, 1) range_state,
  case nvl(g.range_state, 1)
    when 1 then 'Не задан'
    when 2 then 'Некорректен'
  end range_state_name,
  c.ids_value_setters,
  getusernames(c.ids_value_setters) value_setters_names
from 
  w_motivation_coefficients c, 
  v_w_motivation_coefficients_rates v,
  (select id_coefficient,
          case
            when sum(case when range_state = 1 then 1 else 0 end) > 0 then 1
            when sum(case when range_state > 1 then 1 else 0 end) > 0 then 2
            else 0
          end range_state
     from v_w_motivation_rates_state
    group by id_coefficient) g
where 
  v.id_coefficient (+) = c.id
  and v.is_selected (+) = 1
  and g.id_coefficient (+) = c.id
;

--------------------------------------------------------------------------------
--ввод текущего значения коэффициента (fact_value) и таблицы-расшифровки значения (decode_name1..3/
--decode_value1..3) - только через эту процедуру (не прямым update), она же перепроверяет на сервере то,
--что уже проверено в форме: коэффициент не персональный и пользователь есть в списке ids_value_setters.
--Оценка здесь не передаётся и не сохраняется - она вычисляется динамически (см. v_w_motivation_coefficients_rates).
--Значение и расшифровка перезаписываются целиком (пустые поля расшифровки - это тоже валидное значение).
--
create or replace procedure p_w_motivation_coefficients_set_value( --$+
  p_id_coefficient number, p_user_id number, p_fact_value number,
  p_decode_name1 varchar2, p_decode_value1 varchar2,
  p_decode_name2 varchar2, p_decode_value2 varchar2,
  p_decode_name3 varchar2, p_decode_value3 varchar2
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
  update w_motivation_coefficients set
    fact_value = p_fact_value,
    decode_name1 = trim(p_decode_name1), decode_value1 = trim(p_decode_value1),
    decode_name2 = trim(p_decode_name2), decode_value2 = trim(p_decode_value2),
    decode_name3 = trim(p_decode_name3), decode_value3 = trim(p_decode_value3)
  where id = p_id_coefficient;
end;
/

--------------------------------------------------------------------------------
--миграция (оценка больше не хранится, считается динамически): удалить столбец selected_rating и его
--ограничение, если они остались в уже созданной таблице. Выполнять ПОСЛЕ создания вью выше (новые вью от
--этого столбца не зависят). Безопасно выполнять повторно.
--
--$go begin
declare
  v_cnt number;
begin
  select count(*) into v_cnt from user_tab_columns
    where table_name = 'W_MOTIVATION_COEFFICIENTS' and column_name = 'SELECTED_RATING';
  if v_cnt > 0 then
    execute immediate 'alter table w_motivation_coefficients drop column selected_rating';
  end if;
end;
/
--$go end


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
create or replace view v_w_motivation_coefficient_for_job as --$+
select
  f.id,
  f.id_job_internal,
  f.id_coefficient,
  f.pos,
  f.weight,
  round(f.weight * 100, 2) weight_pct,   --доля вознаграждения в процентах (для отображения/редактирования)
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
--вью для списка должностей в форме "Коэффициенты по должностям" (uFrmWGjrnMotivationCoeffsByJob.pas) -
--количество привязанных критериев и СУММА ДОЛЕЙ вознаграждения по ним: доли всех критериев одной
--должности вместе должны давать ровно 100% (1.0). weights_state: 0 - ровно 100%, 1 - меньше 100%
--(не хватает), 2 - больше 100%, 3 - у должности нет ни одного критерия. Сравнение с округлением до
--4 знаков (столько хранит w_motivation_coefficient_for_job.weight).
--
create or replace view v_w_motivation_jobs_coeffs as --$+
select
  j.id,
  j.name,
  j.comm,
  j.active,
  nvl(s.coeffs_count, 0) coeffs_count,
  nvl(s.weights_sum, 0) weights_sum,
  round(nvl(s.weights_sum, 0) * 100, 2) weights_pct,
  case
    when nvl(s.coeffs_count, 0) = 0 then 3
    when round(s.weights_sum, 4) = 1 then 0
    when round(s.weights_sum, 4) < 1 then 1
    else 2
  end weights_state,
  case
    when nvl(s.coeffs_count, 0) = 0 then 'Нет критериев'
    when round(s.weights_sum, 4) = 1 then 'Ок'
    when round(s.weights_sum, 4) < 1 then 'Не хватает до 100%'
    else 'Больше 100%'
  end weights_state_name
from
  w_jobs_internal j,
  (select id_job_internal, count(*) coeffs_count, sum(weight) weights_sum
     from w_motivation_coefficient_for_job
    group by id_job_internal) s
where
  s.id_job_internal (+) = j.id
;

--------------------------------------------------------------------------------
--привести доли критериев должности к 100% (при ручном вводе по одному критерию сумма может не
--сходиться). p_mode = 1 - пропорционально текущим долям (если все доли пусты/нулевые - как p_mode = 2),
--p_mode = 2 - поровну между всеми критериями. Доли округляются до 4 знаков; остаток от округления
--добавляется критерию с наибольшей долей (при равных - первому по pos), чтобы сумма была ровно 1.
--Саму проверку "не больше 100%" при ручном вводе делает форма (uFrmWGjrnMotivationCoeffsByJob.pas).
--
create or replace procedure p_w_motivation_job_weights_fix( --$+
  p_id_job_internal number, p_mode number
) as
  v_cnt number;
  v_sum number;
  v_mode number := p_mode;
  v_w number;
  v_diff number;
  v_id_max number;
begin
  select count(*), nvl(sum(weight), 0) into v_cnt, v_sum
    from w_motivation_coefficient_for_job where id_job_internal = p_id_job_internal;
  if v_cnt = 0 then
    return;
  end if;
  if v_mode = 1 and v_sum <= 0 then
    v_mode := 2;
  end if;
  for r in (select id, weight from w_motivation_coefficient_for_job
             where id_job_internal = p_id_job_internal order by pos, id) loop
    if v_mode = 2 then
      v_w := round(1 / v_cnt, 4);
    else
      v_w := round(nvl(r.weight, 0) / v_sum, 4);
    end if;
    update w_motivation_coefficient_for_job set weight = v_w where id = r.id;
  end loop;
  select 1 - sum(weight) into v_diff
    from w_motivation_coefficient_for_job where id_job_internal = p_id_job_internal;
  if v_diff <> 0 then
    select id into v_id_max from (
      select id from w_motivation_coefficient_for_job
       where id_job_internal = p_id_job_internal order by weight desc, pos, id
    ) where rownum = 1;
    update w_motivation_coefficient_for_job set weight = weight + v_diff where id = v_id_max;
  end if;
end;
/

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


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--СПЕЦИАЛЬНЫЕ КОЭФФИЦИЕНТЫ мотивации (05.10.2026): kind = 1 - "Культура производства", kind = 2 - "Качество
--работы по специальности". В отличие от обычных коэффициентов (w_motivation_coefficients):
--  - у них нет доли в вознаграждении - итоговая оценка это МНОЖИТЕЛЬ (коэффициент) к премии;
--  - и список позиций (показателей), и диапазоны оценок СВОИ для каждой внутренней должности;
--  - у каждой позиции задан вес (weight); оценка показателя по позиции (value) вводится вручную;
--    баллы позиции = оценка * вес; итог = сумма баллов по всем позициям; по итогу и диапазонам должности
--    ДИНАМИЧЕСКИ (не хранится) определяется оценка 1-4 и множитель (см. v_w_motivation_spec_grades);
--  - позиция либо ЛИЧНАЯ (is_personal = 1: оценка по каждому сотруднику отдельно, привязана к сотруднику),
--    либо ПО ОТДЕЛУ (is_personal = 0: одна оценка на всех сотрудников специальности, привязана к должности);
--  - даты (месяца) нигде нет: вся мотивация считается за прошедший месяц, ретроспектива не нужна, значение
--    просто перезаписывается.
--

--w_motivation_special_items - позиции (показатели) специального коэффициента по должностям.
--ids_value_setters - кто может вводить оценку по позиции (пусто - только имеющие право на изменение
--справочника коэффициентов, rW_Mtvn_Coeffs_Ch); pos - порядок позиций в рамках должности и вида.
create table w_motivation_special_items ( --$+
  id number(11) primary key,
  kind number(1) not null,               --1 - культура производства, 2 - качество работы по специальности
  id_job_internal number(11) not null,   --айди должности (внутренней)
  name varchar2(300 char) not null,      --наименование позиции
  weight number(8,2) default 1 not null, --вес позиции
  is_personal number(1) default 1 not null, --1 - личная (оценка по сотруднику), 0 - по отделу (оценка по специальности)
  pos number,                            --порядок позиций в рамках должности и вида
  ids_value_setters varchar2(400),       --айди пользователей, которым разрешено вводить оценку по позиции
  comm varchar2(1000 char),              --комментарий
  constraint fk_w_mtvn_spec_items_job foreign key (id_job_internal) references w_jobs_internal(id),
  constraint ck_w_mtvn_spec_items_kind check (kind in (1, 2))
);

create unique index idx_w_mtvn_spec_items on w_motivation_special_items(kind, id_job_internal, lower(name)); --$+

create sequence sq_w_motivation_special_items nocache start with 1; --$+

--------------------------------------------------------------------------------
--w_motivation_special_rates - диапазоны итоговых баллов по 4 оценкам для (вид, должность): структура и смысл
--полей как у w_motivation_coefficients_rates (rating 1-отлично .. 4-зона роста; value - множитель к премии
--для этой оценки; range_from/range_to - диапазон ИТОГОВЫХ БАЛЛОВ, оба включительно, пусто - граница не
--задана; is_outside_range - оценке соответствует итог вне диапазона). Строки создаются автоматически (все 4)
--при добавлении первой позиции вида для должности (триггер на w_motivation_special_items).
create table w_motivation_special_rates ( --$+
  id number(11) primary key,
  kind number(1) not null,
  id_job_internal number(11) not null,
  rating number(1) not null,
  comm varchar2(100 char),               --комментарий к градации
  value number,                          --множитель к премии для этой оценки
  range_from number(12,2),               --нижняя граница итоговых баллов (включительно), пусто - без границы
  range_to number(12,2),                 --верхняя граница итоговых баллов (включительно), пусто - без границы
  is_outside_range number(1) default 0,  --0 - итог внутри диапазона, 1 - вне диапазона
  constraint fk_w_mtvn_spec_rates_job foreign key (id_job_internal) references w_jobs_internal(id),
  constraint ck_w_mtvn_spec_rates_kind check (kind in (1, 2)),
  constraint ck_w_mtvn_spec_rates_rating check (rating between 1 and 4)
);

create unique index idx_w_mtvn_spec_rates on w_motivation_special_rates(kind, id_job_internal, rating); --$+

create sequence sq_w_motivation_special_rates nocache start with 1; --$+

create or replace trigger trg_w_mtvn_spec_rates_bi_r --$+
  before insert on w_motivation_special_rates for each row
begin
  :new.id := sq_w_motivation_special_rates.nextval;
end;
/

create or replace trigger trg_w_mtvn_spec_items_bi_r --$+
  before insert on w_motivation_special_items for each row
begin
  :new.id := sq_w_motivation_special_items.nextval;
  :new.pos := nvl(:new.pos, :new.id);
end;
/

create or replace trigger trg_w_mtvn_spec_items_ai_r --$+
  after insert on w_motivation_special_items for each row
begin
  for i in 1..4 loop
    insert into w_motivation_special_rates (kind, id_job_internal, rating)
    select :new.kind, :new.id_job_internal, i from dual
    where not exists (
      select 1 from w_motivation_special_rates r
      where r.kind = :new.kind and r.id_job_internal = :new.id_job_internal and r.rating = i);
  end loop;
end;
/

--------------------------------------------------------------------------------
--w_motivation_special_values - оценка показателя (вводится вручную) по позиции. Для ЛИЧНОЙ позиции id_employee
--- айди сотрудника, для позиции ПО ОТДЕЛУ id_employee = 0 (оценка относится к специальности, она же у позиции).
--FK на сотрудников нет (0 - не сотрудник). Дат нет: значение просто перезаписывается. Запись - только через
--p_w_motivation_special_set_value.
create table w_motivation_special_values ( --$+
  id number(11) primary key,
  id_item number(11) not null,
  id_employee number(11) default 0 not null, --айди сотрудника (личная позиция) или 0 (позиция по отделу)
  value number,                          --оценка показателя по позиции
  comm varchar2(400 char),               --комментарий
  id_user number(11),                    --кто ввёл
  constraint fk_w_mtvn_spec_values_item foreign key (id_item) references w_motivation_special_items(id) on delete cascade
);

create unique index idx_w_mtvn_spec_values on w_motivation_special_values(id_item, id_employee); --$+

create sequence sq_w_motivation_special_values nocache start with 1; --$+

create or replace trigger trg_w_mtvn_spec_values_bi_r --$+
  before insert on w_motivation_special_values for each row
begin
  :new.id := sq_w_motivation_special_values.nextval;
end;
/

--------------------------------------------------------------------------------
--вью-помощник: интервалы диапазонов (как v_w_motivation_rate_intervals, но по (вид, должность))
create or replace view v_w_motivation_spec_intervals as --$+
select
  r.kind, r.id_job_internal, r.rating,
  nvl(r.range_from, -1e38) lo, case when r.range_from is null then 0 else 1 end lo_incl,
  nvl(r.range_to, 1e38) hi, case when r.range_to is null then 0 else 1 end hi_incl
from
  w_motivation_special_rates r
where
  nvl(r.is_outside_range, 0) = 0
  and (r.range_from is not null or r.range_to is not null)
  and (r.range_from is null or r.range_to is null or r.range_from <= r.range_to)
union all
select
  r.kind, r.id_job_internal, r.rating, -1e38, 0, r.range_from, 0
from
  w_motivation_special_rates r
where
  r.is_outside_range = 1
  and r.range_from is not null
  and (r.range_to is null or r.range_from <= r.range_to)
union all
select
  r.kind, r.id_job_internal, r.rating, r.range_to, 0, 1e38, 0
from
  w_motivation_special_rates r
where
  r.is_outside_range = 1
  and r.range_to is not null
  and (r.range_from is null or r.range_from <= r.range_to)
;

--------------------------------------------------------------------------------
--вью для таблицы диапазонов по должности: оценка с состоянием диапазона (range_state: 0 - в порядке, 1 - не
--задан, 2 - некорректен (от > до), 3 - пересекается с диапазоном другой оценки этого же вида и должности)
create or replace view v_w_motivation_spec_rates as --$+
select
  r.id,
  r.kind,
  decode(r.kind, 1, 'Культура производства', 2, 'Качество работы') kind_name,
  r.id_job_internal,
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
  case
    when r.range_from is null and r.range_to is null then 1
    when r.range_from > r.range_to then 2
    when exists (
      select 1
      from v_w_motivation_spec_intervals a, v_w_motivation_spec_intervals b
      where a.kind = r.kind and a.id_job_internal = r.id_job_internal and a.rating = r.rating
        and b.kind = r.kind and b.id_job_internal = r.id_job_internal and b.rating <> r.rating
        and (a.lo < b.hi or (a.lo = b.hi and a.lo_incl = 1 and b.hi_incl = 1))
        and (b.lo < a.hi or (b.lo = a.hi and b.lo_incl = 1 and a.hi_incl = 1))
    ) then 3
    else 0
  end range_state,
  case
    when r.range_from is null and r.range_to is null then 'Не задан'
    when r.range_from > r.range_to then 'Некорректен'
    when exists (
      select 1
      from v_w_motivation_spec_intervals a, v_w_motivation_spec_intervals b
      where a.kind = r.kind and a.id_job_internal = r.id_job_internal and a.rating = r.rating
        and b.kind = r.kind and b.id_job_internal = r.id_job_internal and b.rating <> r.rating
        and (a.lo < b.hi or (a.lo = b.hi and a.lo_incl = 1 and b.hi_incl = 1))
        and (b.lo < a.hi or (b.lo = a.hi and b.lo_incl = 1 and a.hi_incl = 1))
    ) then 'Пересекается'
  end range_state_name
from
  w_motivation_special_rates r
;

--------------------------------------------------------------------------------
--сводное состояние диапазонов (вид, должность): 0 - все 4 в порядке, 1 - хотя бы один не задан,
--2 - хотя бы один некорректен или пересекается
create or replace view v_w_motivation_spec_sets_state as --$+
select
  kind, id_job_internal,
  case
    when sum(case when range_state = 1 then 1 else 0 end) > 0 then 1
    when sum(case when range_state > 1 then 1 else 0 end) > 0 then 2
    else 0
  end range_state
from
  v_w_motivation_spec_rates
group by
  kind, id_job_internal
;

--------------------------------------------------------------------------------
--список внутренних должностей для журналов позиций/диапазонов: по каждому виду - количество позиций,
--сумма весов и состояние диапазонов (пусто - позиций нет)
create or replace view v_w_motivation_special_jobs as --$+
select
  j.id,
  j.name,
  j.comm,
  j.active,
  nvl(c.cnt, 0) c_cnt,
  c.wsum c_weights,
  case when nvl(c.cnt, 0) = 0 then null
    else decode(sc.range_state, 0, 'Ок', 1, 'Не задан', 2, 'Некорректен', 'Не задан') end c_ranges_name,
  nvl(q.cnt, 0) q_cnt,
  q.wsum q_weights,
  case when nvl(q.cnt, 0) = 0 then null
    else decode(sq.range_state, 0, 'Ок', 1, 'Не задан', 2, 'Некорректен', 'Не задан') end q_ranges_name
from
  w_jobs_internal j,
  (select id_job_internal, count(*) cnt, sum(weight) wsum from w_motivation_special_items where kind = 1 group by id_job_internal) c,
  (select id_job_internal, count(*) cnt, sum(weight) wsum from w_motivation_special_items where kind = 2 group by id_job_internal) q,
  v_w_motivation_spec_sets_state sc,
  v_w_motivation_spec_sets_state sq
where
  c.id_job_internal (+) = j.id
  and q.id_job_internal (+) = j.id
  and sc.id_job_internal (+) = j.id and sc.kind (+) = 1
  and sq.id_job_internal (+) = j.id and sq.kind (+) = 2
;

--------------------------------------------------------------------------------
--позиции специальных коэффициентов (для журнала позиций по должностям)
create or replace view v_w_motivation_special_items as --$+
select
  i.id,
  i.kind,
  decode(i.kind, 1, 'Культура производства', 2, 'Качество работы') kind_name,
  i.id_job_internal,
  i.name,
  i.weight,
  i.is_personal,
  decode(i.is_personal, 1, 'Личный', 'По отделу') scope_name,
  i.pos,
  i.ids_value_setters,
  getusernames(i.ids_value_setters) value_setters_names,
  i.comm
from
  w_motivation_special_items i
;

--------------------------------------------------------------------------------
--позиции + оценки по каждому сотруднику его должности: для личной позиции оценка берётся по сотруднику, для
--позиции по отделу - общая (id_employee = 0). points = оценка * вес. id = id позиции (в рамках сотрудника
--уникален).
create or replace view v_w_motivation_spec_emp_items as --$+
select
  i.id,
  i.kind,
  decode(i.kind, 1, 'Культура производства', 2, 'Качество работы') kind_name,
  e.id id_employee,
  e.name employee_name,
  i.id_job_internal,
  i.name,
  i.weight,
  i.is_personal,
  decode(i.is_personal, 1, 'Личный', 'По отделу') scope_name,
  i.pos,
  i.ids_value_setters,
  getusernames(i.ids_value_setters) value_setters_names,
  v.id id_value,
  v.value,
  v.comm value_comm,
  v.value * i.weight points
from
  w_motivation_special_items i,
  v_w_motivation_employees_by_job e,
  w_motivation_special_values v
where
  e.id_job_internal = i.id_job_internal
  and v.id_item (+) = i.id
  and v.id_employee (+) = decode(i.is_personal, 1, e.id, 0)
;

--------------------------------------------------------------------------------
--итоги по (вид, сотрудник): количество позиций, сколько из них с введённой оценкой, сумма весов и итоговые
--баллы (сумма points)
create or replace view v_w_motivation_spec_totals as --$+
select
  kind, id_job_internal, id_employee,
  count(*) items_count,
  count(value) values_count,
  sum(weight) weights_sum,
  sum(points) total_points
from
  v_w_motivation_spec_emp_items
group by
  kind, id_job_internal, id_employee
;

--------------------------------------------------------------------------------
--оценка специального коэффициента по сотруднику - ВЫЧИСЛЯЕТСЯ при каждом чтении (в БД не хранится). Определена,
--только если: введены оценки по ВСЕМ позициям, диапазоны всех 4 оценок вида и должности в порядке
--(range_state = 0) и итог попал ровно в один диапазон. state_name - итог/причина, почему не определена.
create or replace view v_w_motivation_spec_grades as --$+
select
  t.kind,
  t.id_job_internal,
  t.id_employee,
  t.items_count,
  t.values_count,
  t.weights_sum,
  t.total_points,
  nvl(st.range_state, 1) range_state,
  case when nvl(st.range_state, 1) = 0 then m.rating end selected_rating,
  case when nvl(st.range_state, 1) = 0 then m.value end selected_rate_value,
  case when nvl(st.range_state, 1) = 0 then
    decode(m.rating, 1, 'Отлично', 2, 'Хорошо', 3, 'Удовлетворительно', 4, 'Зона роста') end selected_rating_name,
  case
    when t.items_count = 0 then 'Нет позиций'
    when t.values_count < t.items_count then 'Введено ' || t.values_count || ' из ' || t.items_count
    when nvl(st.range_state, 1) = 1 then 'Диапазоны не заданы'
    when nvl(st.range_state, 1) = 2 then 'Диапазоны некорректны'
    when m.rating is null then 'Итог вне диапазонов'
    else decode(m.rating, 1, 'Отлично', 2, 'Хорошо', 3, 'Удовлетворительно', 4, 'Зона роста')
  end state_name
from
  v_w_motivation_spec_totals t,
  v_w_motivation_spec_sets_state st,
  (select * from (
     select
       t2.kind, t2.id_job_internal, t2.id_employee, r.rating, r.value,
       count(*) over (partition by t2.kind, t2.id_job_internal, t2.id_employee) cnt
     from
       v_w_motivation_spec_totals t2,
       w_motivation_special_rates r
     where
       r.kind = t2.kind and r.id_job_internal = t2.id_job_internal
       and t2.items_count > 0 and t2.values_count = t2.items_count
       and (
         (nvl(r.is_outside_range, 0) = 0
           and (r.range_from is not null or r.range_to is not null)
           and (r.range_from is null or t2.total_points >= r.range_from)
           and (r.range_to is null or t2.total_points <= r.range_to))
         or
         (r.is_outside_range = 1
           and ((r.range_from is not null and t2.total_points < r.range_from)
             or (r.range_to is not null and t2.total_points > r.range_to)))
       )
   ) where cnt = 1) m
where
  st.kind (+) = t.kind and st.id_job_internal (+) = t.id_job_internal
  and m.kind (+) = t.kind and m.id_job_internal (+) = t.id_job_internal and m.id_employee (+) = t.id_employee
;

--------------------------------------------------------------------------------
--сотрудники (работающие, с внутренней должностью) со сводкой по обоим специальным коэффициентам:
--c_* - культура производства, q_* - качество работы; items_total - всего позиций у должности
create or replace view v_w_motivation_special_emp as --$+
select
  e.id,
  e.name,
  e.id_job,
  e.id_job_internal,
  ji.name job_internal_name,
  nvl(g1.items_count, 0) + nvl(g2.items_count, 0) items_total,
  g1.items_count c_items,
  g1.values_count c_values,
  g1.total_points c_total,
  g1.selected_rate_value c_rate_value,
  g1.state_name c_state_name,
  g2.items_count q_items,
  g2.values_count q_values,
  g2.total_points q_total,
  g2.selected_rate_value q_rate_value,
  g2.state_name q_state_name
from
  v_w_motivation_employees_by_job e,
  w_jobs_internal ji,
  (select * from v_w_motivation_spec_grades where kind = 1) g1,
  (select * from v_w_motivation_spec_grades where kind = 2) g2
where
  ji.id (+) = e.id_job_internal
  and g1.id_employee (+) = e.id
  and g2.id_employee (+) = e.id
;

--------------------------------------------------------------------------------
--ввод оценки показателя по позиции (только через эту процедуру). Для личной позиции нужен сотрудник
--(p_id_employee) и он должен работать на специальности позиции; для позиции по отделу сотрудник не нужен
--(оценка хранится с id_employee = 0). Проверка прав: если у позиции задан список ids_value_setters - пользователь
--должен быть в нём (если список пуст - проверка прав делается в форме, по праву rW_Mtvn_Coeffs_Ch).
--Пустая оценка (p_value is null) удаляет запись. Даты нет: значение перезаписывается.
create or replace procedure p_w_motivation_special_set_value( --$+
  p_id_item number, p_id_employee number, p_user_id number, p_value number, p_comm varchar2
) as
  v_personal number;
  v_setters varchar2(400);
  v_job number;
  v_emp number;
  v_cnt number;
begin
  select is_personal, ids_value_setters, id_job_internal into v_personal, v_setters, v_job
    from w_motivation_special_items where id = p_id_item;
  if v_setters is not null and IsStInCommaSt(p_user_id, v_setters) <> 1 then
    raise_application_error(-20003, 'Нет прав на ввод оценки по этой позиции');
  end if;
  if v_personal = 1 then
    if nvl(p_id_employee, 0) <= 0 then
      raise_application_error(-20004, 'Для личной позиции нужно указать сотрудника');
    end if;
    select count(*) into v_cnt from v_w_motivation_employees_by_job
      where id = p_id_employee and id_job_internal = v_job;
    if v_cnt = 0 then
      raise_application_error(-20005, 'Сотрудник не работает на специальности этой позиции');
    end if;
    v_emp := p_id_employee;
  else
    v_emp := 0;
  end if;
  if p_value is null then
    delete from w_motivation_special_values where id_item = p_id_item and id_employee = v_emp;
    return;
  end if;
  update w_motivation_special_values set value = p_value, comm = trim(p_comm), id_user = p_user_id
    where id_item = p_id_item and id_employee = v_emp;
  if sql%rowcount = 0 then
    insert into w_motivation_special_values (id, id_item, id_employee, value, comm, id_user)
      values (null, p_id_item, v_emp, p_value, trim(p_comm), p_user_id);
  end if;
end;
/


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--ЗНАЧЕНИЯ ЛИЧНЫХ КОЭФФИЦИЕНТОВ ПО СОТРУДНИКУ и ФАКТ ЗАМЕЧАНИЙ/ЧС (07.10.2026) - ввод из экрана "Мотивация - Тест"
--(двойной щелчок по ячейке). Даты (месяца) нет - значение просто перезаписывается (вся мотивация считается за
--прошедший месяц). Права на ввод пока не ограничены (будут заданы позже: пользователь, имеющий право вводить
--значения личных коэффициентов и показателей по отделу для данной должности).
--

--w_motivation_employee_values - значение ЛИЧНОГО коэффициента (w_motivation_coefficients.is_personal = 1) по
--сотруднику: значение показателя и таблица-расшифровка (как у обычных коэффициентов, см. fact_value/
--decode_* в w_motivation_coefficients). Оценка не хранится: вычисляется по диапазонам коэффициента
--(v_w_motivation_emp_rates). Запись - только через p_w_motivation_emp_coeff_set_value.
create table w_motivation_employee_values ( --$+
  id number(11) primary key,
  id_coefficient number(11) not null,    --айди коэффициента (личного)
  id_employee number(11) not null,       --айди сотрудника
  fact_value number,                     --значение показателя
  decode_name1 varchar2(150 char),       --расшифровка значения, строка 1, название
  decode_value1 varchar2(150 char),      --расшифровка значения, строка 1, значение
  decode_name2 varchar2(150 char),       --расшифровка значения, строка 2, название
  decode_value2 varchar2(150 char),      --расшифровка значения, строка 2, значение
  decode_name3 varchar2(150 char),       --расшифровка значения, строка 3, название
  decode_value3 varchar2(150 char),      --расшифровка значения, строка 3, значение
  id_user number(11),                    --кто ввёл
  constraint fk_w_mtvn_emp_values_coeff foreign key (id_coefficient) references w_motivation_coefficients(id) on delete cascade
);

create unique index idx_w_mtvn_emp_values on w_motivation_employee_values(id_coefficient, id_employee); --$+

create sequence sq_w_motivation_employee_values nocache start with 1; --$+

create or replace trigger trg_w_mtvn_emp_values_bi_r --$+
  before insert on w_motivation_employee_values for each row
begin
  :new.id := sq_w_motivation_employee_values.nextval;
end;
/

--------------------------------------------------------------------------------
--w_motivation_remark_facts - фактический множитель блока "грубые замечания и чрезвычайные ситуации" по
--сотруднику (выставляется ВРУЧНУЮ; коэффициентов за случай и учёта случаев нет): kind = 1 - грубые замечания,
--kind = 2 - чрезвычайные ситуации. Нет записи - множитель 1. Запись - через p_w_motivation_remark_fact_set.
create table w_motivation_remark_facts ( --$+
  id number(11) primary key,
  id_employee number(11) not null,       --айди сотрудника
  kind number(1) not null,               --1 - грубые замечания, 2 - чрезвычайные ситуации
  value number,                          --множитель (по умолчанию 1)
  comm varchar2(400 char),               --комментарий
  id_user number(11),                    --кто ввёл
  constraint ck_w_mtvn_remark_facts_kind check (kind in (1, 2))
);

create unique index idx_w_mtvn_remark_facts on w_motivation_remark_facts(id_employee, kind); --$+

create sequence sq_w_motivation_remark_facts nocache start with 1; --$+

create or replace trigger trg_w_mtvn_remark_facts_bi_r --$+
  before insert on w_motivation_remark_facts for each row
begin
  :new.id := sq_w_motivation_remark_facts.nextval;
end;
/

--------------------------------------------------------------------------------
--оценка ЛИЧНОГО коэффициента по сотруднику - ВЫЧИСЛЯЕТСЯ (не хранится) по его значению
--(w_motivation_employee_values.fact_value) и текущим диапазонам коэффициента (v_w_motivation_rates_state): строка
--на каждую оценку каждого сотрудника, у которого значение введено. is_selected = 1 - выбранная оценка: значение
--попало ровно в один диапазон и диапазоны всех 4 оценок коэффициента в порядке (range_state = 0), как у
--v_w_motivation_coefficients_rates для обычных коэффициентов.
create or replace view v_w_motivation_emp_rates as --$+
select
  x.id_coefficient,
  x.id_employee,
  x.rating,
  x.value,
  x.range_state,
  x.is_match,
  case
    when x.is_match = 1
      and sum(x.is_match) over (partition by x.id_coefficient, x.id_employee) = 1
      and max(x.range_state) over (partition by x.id_coefficient, x.id_employee) = 0 then 1
    else 0
  end is_selected
from (
  select
    s.id_coefficient,
    v.id_employee,
    s.rating,
    s.value,
    s.range_state,
    case
      when v.fact_value is null then 0
      when nvl(s.is_outside_range, 0) = 0
        and (s.range_from is not null or s.range_to is not null)
        and (s.range_from is null or v.fact_value >= s.range_from)
        and (s.range_to is null or v.fact_value <= s.range_to) then 1
      when s.is_outside_range = 1
        and ((s.range_from is not null and v.fact_value < s.range_from)
          or (s.range_to is not null and v.fact_value > s.range_to)) then 1
      else 0
    end is_match
  from
    v_w_motivation_rates_state s,
    w_motivation_employee_values v
  where
    v.id_coefficient = s.id_coefficient
) x
;

--------------------------------------------------------------------------------
--ввод значения личного коэффициента по сотруднику (и таблицы-расшифровки). Пустое значение и пустая расшифровка
--(все 6 полей) - запись удаляется. Проверяет: коэффициент личный и привязан к должности сотрудника
--(w_motivation_coefficient_for_job). Права пока не проверяются (будут заданы позже).
create or replace procedure p_w_motivation_emp_coeff_set_value( --$+
  p_id_coefficient number, p_id_employee number, p_user_id number, p_fact_value number,
  p_decode_name1 varchar2, p_decode_value1 varchar2,
  p_decode_name2 varchar2, p_decode_value2 varchar2,
  p_decode_name3 varchar2, p_decode_value3 varchar2
) as
  v_personal number;
  v_cnt number;
begin
  select is_personal into v_personal from w_motivation_coefficients where id = p_id_coefficient;
  if nvl(v_personal, 0) <> 1 then
    raise_application_error(-20011, 'Коэффициент не личный - значение задаётся в справочнике коэффициентов');
  end if;
  select count(*) into v_cnt
    from v_w_motivation_employees_by_job e, w_motivation_coefficient_for_job f
    where e.id = p_id_employee and f.id_job_internal = e.id_job_internal and f.id_coefficient = p_id_coefficient;
  if v_cnt = 0 then
    raise_application_error(-20012, 'Коэффициент не привязан к должности сотрудника');
  end if;
  if p_fact_value is null
     and trim(p_decode_name1) is null and trim(p_decode_value1) is null
     and trim(p_decode_name2) is null and trim(p_decode_value2) is null
     and trim(p_decode_name3) is null and trim(p_decode_value3) is null then
    delete from w_motivation_employee_values where id_coefficient = p_id_coefficient and id_employee = p_id_employee;
    return;
  end if;
  update w_motivation_employee_values set
    fact_value = p_fact_value,
    decode_name1 = trim(p_decode_name1), decode_value1 = trim(p_decode_value1),
    decode_name2 = trim(p_decode_name2), decode_value2 = trim(p_decode_value2),
    decode_name3 = trim(p_decode_name3), decode_value3 = trim(p_decode_value3),
    id_user = p_user_id
  where id_coefficient = p_id_coefficient and id_employee = p_id_employee;
  if sql%rowcount = 0 then
    insert into w_motivation_employee_values (id, id_coefficient, id_employee, fact_value,
      decode_name1, decode_value1, decode_name2, decode_value2, decode_name3, decode_value3, id_user)
    values (null, p_id_coefficient, p_id_employee, p_fact_value,
      trim(p_decode_name1), trim(p_decode_value1), trim(p_decode_name2), trim(p_decode_value2),
      trim(p_decode_name3), trim(p_decode_value3), p_user_id);
  end if;
end;
/

--------------------------------------------------------------------------------
--ввод фактического множителя замечаний (p_kind = 1) или ЧС (p_kind = 2) по сотруднику; пустое значение - запись
--удаляется (множитель снова 1). Права пока не проверяются.
create or replace procedure p_w_motivation_remark_fact_set( --$+
  p_id_employee number, p_kind number, p_user_id number, p_value number, p_comm varchar2
) as
begin
  if p_kind not in (1, 2) then
    raise_application_error(-20013, 'Неверный вид: 1 - замечания, 2 - ЧС');
  end if;
  if p_value is null then
    delete from w_motivation_remark_facts where id_employee = p_id_employee and kind = p_kind;
    return;
  end if;
  update w_motivation_remark_facts set value = p_value, comm = trim(p_comm), id_user = p_user_id
    where id_employee = p_id_employee and kind = p_kind;
  if sql%rowcount = 0 then
    insert into w_motivation_remark_facts (id, id_employee, kind, value, comm, id_user)
      values (null, p_id_employee, p_kind, p_value, trim(p_comm), p_user_id);
  end if;
end;
/

--------------------------------------------------------------------------------
--w_motivation_job_formulas - формула вознаграждения (ВЗ) внутренней должности (экран "Мотивация - Тест"):
--текст из чисел, коэффициентов К1, К2, ... (нумерация позиционная - в порядке блоков в таблице: критерии, затем
--специальные коэффициенты и замечания/ЧС), знаков + - * / и скобок. Нет записи - действует стандартная формула
--(К1+К2+...)*К(культура)*К(качество)*К(замечания). k_count - сколько коэффициентов было у должности на момент
--сохранения (для предупреждения, если состав изменился и номера К могли сдвинуться). Запись - через
--p_w_motivation_job_formula_set.
create table w_motivation_job_formulas ( --$+
  id_job_internal number(11) primary key,   --айди внутренней должности (w_jobs_internal)
  formula varchar2(1000 char) not null,     --текст формулы
  k_count number(3),                        --число коэффициентов К на момент сохранения
  id_user number(11),                       --кто сохранил
  dt date default sysdate                   --когда сохранено
);

--------------------------------------------------------------------------------
--сохранение формулы ВЗ должности; пустая формула - запись удаляется (формула снова стандартная)
create or replace procedure p_w_motivation_job_formula_set( --$+
  p_id_job_internal number, p_user_id number, p_k_count number, p_formula varchar2
) as
begin
  if trim(p_formula) is null then
    delete from w_motivation_job_formulas where id_job_internal = p_id_job_internal;
    return;
  end if;
  update w_motivation_job_formulas
    set formula = trim(p_formula), k_count = p_k_count, id_user = p_user_id, dt = sysdate
    where id_job_internal = p_id_job_internal;
  if sql%rowcount = 0 then
    insert into w_motivation_job_formulas (id_job_internal, formula, k_count, id_user, dt)
      values (p_id_job_internal, trim(p_formula), p_k_count, p_user_id, sysdate);
  end if;
end;
/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--БЛОКИРОВКА ДАННЫХ МОТИВАЦИИ и РЕЗУЛЬТАТ РАСЧЁТА ПРЕМИИ (12.10.2026)
--
--1. Блокировка корректировки. Одна общая на всю мотивацию (строка id = 1 в w_motivation_state). Пока is_locked = 1,
--любая вставка/изменение/удаление в таблицах исходных данных мотивации (список ниже, go-блок с триггерами)
--отклоняется ошибкой ORA-20010: справочники коэффициентов и их диапазоны, привязки к должностям, формулы, позиции и
--оценки специальных коэффициентов, личные значения, замечания/ЧС. Установка и снятие - только через
--p_w_motivation_lock_set (каждое действие пишется в w_motivation_lock_log). Права на установку/снятие проверяет
--форма (rW_Mtvn_Lock_Set / rW_Mtvn_Lock_Clear, uData.pas), как и у остальных процедур мотивации. Таблицы результата
--(w_motivation_results, w_motivation_job_state) блокировкой не закрыты - их пишет пересчёт.
--
--2. Признак изменения данных. Каждое разрешённое изменение исходных данных ставит w_motivation_state.dirty_dt =
--sysdate (в том же триггере). Результат по сотруднику (w_motivation_results.dt_calc) считается актуальным, если он
--посчитан не раньше dirty_dt (см. v_w_motivation_results.is_actual). НЕ отслеживаются (триггеров нет): плановые
--начисления (w_job_salaries), смена должности сотрудника, ТУРВ - для них результат нужно пересчитать вручную.
--
--3. Результат расчёта. Сама премия считается в Delphi (формула ВЗ - разборщик в uMotivationCalc.pas), SQL формулу не
--вычисляет. Расчёт выполняется по требованию (метод MotRecalc* в uMotivationCalc.pas, кнопка на экране "Мотивация -
--Тест") и сохраняет по каждому сотруднику: признак "все данные введены и корректны" (is_valid), причины, премию по
--формуле и с учётом ТУРВ - в w_motivation_results; по каждой должности - в w_motivation_job_state. Расчёт зарплаты
--читает готовое значение: v_w_motivation_results / f_w_motivation_premium.
--
create table w_motivation_state ( --$+
  id number(1) primary key,                 --всегда 1 (единственная строка)
  is_locked number(1) default 0 not null,   --1 - данные заблокированы от корректировки
  lock_dt date,                             --когда установлена блокировка
  lock_id_user number(11),                  --кто установил
  lock_comm varchar2(400 char),             --комментарий к блокировке
  dirty_dt date,                            --когда исходные данные менялись в последний раз
  full_calc_dt date,                        --когда выполнялся последний полный пересчёт
  constraint ck_w_mtvn_state_one check (id = 1)
);

--единственная строка состояния (выполняется один раз)
--$go begin
begin
  insert into w_motivation_state (id, is_locked) select 1, 0 from dual where not exists (select 1 from w_motivation_state);
  commit;
end;
/
--$go end

--w_motivation_lock_log - журнал установки/снятия блокировки
create table w_motivation_lock_log ( --$+
  id number(11) primary key,
  dt date default sysdate not null,         --когда
  id_user number(11),                       --кто
  action number(1) not null,                --1 - блокировка установлена, 0 - снята
  comm varchar2(400 char)                   --комментарий
);

create sequence sq_w_motivation_lock_log nocache start with 1; --$+

create or replace trigger trg_w_mtvn_lock_log_bi_r --$+
  before insert on w_motivation_lock_log for each row
begin
  :new.id := sq_w_motivation_lock_log.nextval;
end;
/

--------------------------------------------------------------------------------
--триггеры-запреты на таблицах исходных данных мотивации (по одному на таблицу, уровень оператора). Имена -
--trg_w_mtvn_lock_NN. Тело: если is_locked = 1 - ошибка ORA-20010, иначе отметка w_motivation_state.dirty_dt.
--Создаются одним go-блоком (триггеры не должны вызывать процедуры: триггеры файла создаются раньше процедур).
--Новая таблица исходных данных - добавить в список ниже НОВЫМ go-блоком (этот уже выполнен).
--$go begin
declare
  type t_tabs is table of varchar2(60);
  v_tabs t_tabs := t_tabs(
    'w_motivation_coefficients',
    'w_motivation_coefficients_rates',
    'w_motivation_coefficient_for_job',
    'w_motivation_negative_remarks',
    'w_motivation_negative_remarks_for_job',
    'w_motivation_w_work_emergencies',
    'w_motivation_w_work_emergencies_for_job',
    'w_motivation_special_items',
    'w_motivation_special_rates',
    'w_motivation_special_values',
    'w_motivation_employee_values',
    'w_motivation_remark_facts',
    'w_motivation_job_formulas');
  v_sql varchar2(4000);
begin
  for i in 1 .. v_tabs.count loop
    v_sql := q'[create or replace trigger trg_w_mtvn_lock_]' || lpad(i, 2, '0') || chr(10) ||
      q'[  before insert or update or delete on ]' || v_tabs(i) || chr(10) ||
      q'[declare
  v_locked number;
begin
  select nvl(max(is_locked), 0) into v_locked from w_motivation_state where id = 1;
  if v_locked = 1 then
    raise_application_error(-20010, 'Данные мотивации заблокированы от изменений. Для корректировки снимите блокировку.');
  end if;
  update w_motivation_state set dirty_dt = sysdate where id = 1;
end;]';
    execute immediate v_sql;
  end loop;
end;
/
--$go end

--------------------------------------------------------------------------------
--w_motivation_results - результат расчёта по сотруднику (один на сотрудника; пишется только пересчётом через
--p_w_motivation_result_save). is_valid = 1 - все данные введены и корректны (job_ok - общие данные должности и
--формула, emp_ok - личные данные сотрудника) и премия рассчитана. state_text - причины, если нет.
--premium - премия по формуле ВЗ при отработке нормы часов; premium_turv - с учётом факта/плана ТУРВ.
create table w_motivation_results ( --$+
  id_employee number(11) primary key,
  id_job_internal number(11) not null,      --внутренняя должность на момент расчёта
  job_ok number(1) default 0 not null,
  emp_ok number(1) default 0 not null,
  is_valid number(1) default 0 not null,
  state_text varchar2(2000 char),           --причины некорректности (пусто - всё в порядке)
  formula varchar2(1000 char),              --формула ВЗ, по которой считалось
  fixed_pay number,                         --оклад (плановые начисления за прошлый месяц)
  variable_pay number,                      --премия - расчётная часть (плановые начисления за прошлый месяц)
  premium number,                           --премия по формуле ВЗ (при отработке нормы)
  turv_plan number,                         --план ТУРВ, часов
  turv_fact number,                         --факт ТУРВ, часов
  premium_turv number,                      --премия с учётом ТУРВ
  dt_calc date default sysdate not null,    --когда посчитано
  id_user number(11)                        --кто запустил расчёт
);

create index idx_w_mtvn_results_job on w_motivation_results(id_job_internal); --$+

--w_motivation_job_state - результат проверки данных по должности (общие данные: коэффициенты, диапазоны, значения по
--отделу, формула). emp_total/emp_valid - сколько сотрудников должности в результатах и сколько из них is_valid = 1.
create table w_motivation_job_state ( --$+
  id_job_internal number(11) primary key,
  job_ok number(1) default 0 not null,
  state_text varchar2(2000 char),
  emp_total number(6) default 0 not null,
  emp_valid number(6) default 0 not null,
  dt_calc date default sysdate not null,
  id_user number(11)
);

--------------------------------------------------------------------------------
--установка (p_lock = 1) и снятие (p_lock = 0) блокировки; запись в журнал. Права проверяет форма.
create or replace procedure p_w_motivation_lock_set( --$+
  p_user_id number, p_lock number, p_comm varchar2
) as
  v_cur number;
begin
  select is_locked into v_cur from w_motivation_state where id = 1 for update;
  if nvl(p_lock, 0) = 1 then
    if v_cur = 1 then
      raise_application_error(-20011, 'Данные мотивации уже заблокированы');
    end if;
    update w_motivation_state set is_locked = 1, lock_dt = sysdate, lock_id_user = p_user_id,
      lock_comm = trim(p_comm) where id = 1;
  else
    if v_cur = 0 then
      raise_application_error(-20012, 'Блокировка уже снята');
    end if;
    update w_motivation_state set is_locked = 0, lock_dt = null, lock_id_user = null,
      lock_comm = null where id = 1;
  end if;
  insert into w_motivation_lock_log (id, dt, id_user, action, comm)
    values (null, sysdate, p_user_id, nvl(p_lock, 0), trim(p_comm));
end;
/

--------------------------------------------------------------------------------
--сохранение результата расчёта по сотруднику (вставка или обновление). Блокировкой не закрыто.
create or replace procedure p_w_motivation_result_save( --$+
  p_id_employee number, p_id_job_internal number, p_user_id number,
  p_job_ok number, p_emp_ok number, p_state_text varchar2, p_formula varchar2,
  p_fixed_pay number, p_variable_pay number, p_premium number,
  p_turv_plan number, p_turv_fact number, p_premium_turv number
) as
  v_valid number;
begin
  if nvl(p_job_ok, 0) = 1 and nvl(p_emp_ok, 0) = 1 and p_premium is not null then
    v_valid := 1;
  else
    v_valid := 0;
  end if;
  update w_motivation_results set
    id_job_internal = p_id_job_internal, job_ok = nvl(p_job_ok, 0), emp_ok = nvl(p_emp_ok, 0), is_valid = v_valid,
    state_text = substr(p_state_text, 1, 2000), formula = substr(p_formula, 1, 1000),
    fixed_pay = p_fixed_pay, variable_pay = p_variable_pay, premium = p_premium,
    turv_plan = p_turv_plan, turv_fact = p_turv_fact, premium_turv = p_premium_turv,
    dt_calc = sysdate, id_user = p_user_id
  where id_employee = p_id_employee;
  if sql%rowcount = 0 then
    insert into w_motivation_results (id_employee, id_job_internal, job_ok, emp_ok, is_valid, state_text, formula,
      fixed_pay, variable_pay, premium, turv_plan, turv_fact, premium_turv, dt_calc, id_user)
    values (p_id_employee, p_id_job_internal, nvl(p_job_ok, 0), nvl(p_emp_ok, 0), v_valid,
      substr(p_state_text, 1, 2000), substr(p_formula, 1, 1000),
      p_fixed_pay, p_variable_pay, p_premium, p_turv_plan, p_turv_fact, p_premium_turv, sysdate, p_user_id);
  end if;
end;
/

--------------------------------------------------------------------------------
--сохранение результата проверки данных должности; число сотрудников и валидных берётся из w_motivation_results
--(вызывать ПОСЛЕ сохранения результатов сотрудников должности)
create or replace procedure p_w_motivation_job_state_save( --$+
  p_id_job_internal number, p_user_id number, p_job_ok number, p_state_text varchar2
) as
  v_total number;
  v_valid number;
begin
  select count(*), nvl(sum(is_valid), 0) into v_total, v_valid
    from w_motivation_results where id_job_internal = p_id_job_internal;
  update w_motivation_job_state set
    job_ok = nvl(p_job_ok, 0), state_text = substr(p_state_text, 1, 2000), emp_total = v_total, emp_valid = v_valid,
    dt_calc = sysdate, id_user = p_user_id
  where id_job_internal = p_id_job_internal;
  if sql%rowcount = 0 then
    insert into w_motivation_job_state (id_job_internal, job_ok, state_text, emp_total, emp_valid, dt_calc, id_user)
    values (p_id_job_internal, nvl(p_job_ok, 0), substr(p_state_text, 1, 2000), v_total, v_valid, sysdate, p_user_id);
  end if;
end;
/

--------------------------------------------------------------------------------
--удаление результатов сотрудников, которых больше нет среди работающих на этой должности (уволены, перешли на
--другую); p_id_job_internal пусто - по всем должностям. p_full = 1 - после полного пересчёта: запомнить время
--(w_motivation_state.full_calc_dt) и убрать состояние должностей, которых больше нет
create or replace procedure p_w_motivation_calc_done( --$+
  p_id_job_internal number, p_full number
) as
begin
  delete from w_motivation_results r
   where (p_id_job_internal is null or r.id_job_internal = p_id_job_internal)
     and not exists (select 1 from v_w_motivation_employees_by_job e
                      where e.id = r.id_employee and e.id_job_internal = r.id_job_internal);
  if nvl(p_full, 0) = 1 then
    delete from w_motivation_job_state s where not exists (select 1 from w_jobs_internal j where j.id = s.id_job_internal);
    update w_motivation_state set full_calc_dt = sysdate where id = 1;
  end if;
end;
/

--------------------------------------------------------------------------------
--состояние мотивации для экрана: блокировка (кто и когда), признак "данные менялись после последнего полного
--пересчёта" и сводка по результатам
create or replace view v_w_motivation_state as --$+
select
  s.id,
  s.is_locked,
  s.lock_dt,
  s.lock_id_user,
  getusernames(to_char(s.lock_id_user)) lock_user_name,
  s.lock_comm,
  s.dirty_dt,
  s.full_calc_dt,
  case when s.dirty_dt is not null and (s.full_calc_dt is null or s.dirty_dt > s.full_calc_dt) then 1 else 0 end is_dirty,
  nvl(r.emp_total, 0) emp_total,
  nvl(r.emp_valid, 0) emp_valid
from
  w_motivation_state s,
  (select count(*) emp_total, nvl(sum(is_valid), 0) emp_valid from w_motivation_results) r
where
  s.id = 1
;

--------------------------------------------------------------------------------
--результаты по сотрудникам с названиями и признаком актуальности: is_actual = 1, если результат посчитан не раньше
--последнего изменения исходных данных (dirty_dt); is_valid = 1 - все данные введены и корректны (тогда premium_turv -
--итоговая премия к начислению)
create or replace view v_w_motivation_results as --$+
select
  r.id_employee,
  e.name employee_name,
  r.id_job_internal,
  ji.name job_name,
  r.job_ok,
  r.emp_ok,
  r.is_valid,
  r.state_text,
  r.formula,
  r.fixed_pay,
  r.variable_pay,
  r.premium,
  r.turv_plan,
  r.turv_fact,
  r.premium_turv,
  r.dt_calc,
  r.id_user,
  case when s.dirty_dt is null or r.dt_calc >= s.dirty_dt then 1 else 0 end is_actual,
  s.is_locked
from
  w_motivation_results r,
  w_motivation_state s,
  w_jobs_internal ji,
  v_w_motivation_employees_by_job e
where
  s.id = 1
  and ji.id (+) = r.id_job_internal
  and e.id (+) = r.id_employee
;

--------------------------------------------------------------------------------
--премия сотрудника к начислению (с учётом ТУРВ) для расчёта зарплаты: только если результат есть и все данные введены
--и корректны (is_valid = 1); иначе null. Актуальность (is_actual) не проверяется - см. v_w_motivation_results
create or replace function f_w_motivation_premium( --$+
  p_id_employee number
) return number as
  v_res number;
begin
  select max(premium_turv) into v_res from w_motivation_results where id_employee = p_id_employee and is_valid = 1;
  return v_res;
end;
/
