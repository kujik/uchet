--------------------------------------------------------------------------------
--профессии
alter table w_jobs drop column has_hazard_comp;
alter table w_jobs add has_milk_compensation number(1) default 0;
create table w_jobs(
  id number(11),
  name varchar2(400),
  comm varchar2(400),
  has_milk_compensation number(1) default 0,
  active number(1),
  constraint pk_w_jobs primary key (id)
);

create unique index idx_w_jobs on w_jobs(lower(name)); 

create sequence sq_w_jobs start with 1000 nocache;

create or replace trigger trg_w_jobs_bi_r before insert on w_jobs for each row
begin
  select nvl(:new.id, sq_w_jobs.nextval) into :new.id from dual;
end;
/

--!
--insert into w_jobs (id, name, active) select id,name,active from ref_jobs;

--------------------------------------------------------------------------------
--обозначения в турв
create table w_turvcodes(
  id number(11),
  code varchar2(25),
  name varchar2(400),
  active number(1) default 1,
  constraint pk_w_turvcodes primary key (id)
);

create unique index idx_w_turvcodes_code on w_turvcodes(lower(code)); 
create unique index idx_w_turvcodes_name on w_turvcodes(lower(name)); 

create sequence sq_w_turvcodes start with 1000 nocache;

create or replace trigger trg_w_turvcodes_bi_r before insert on w_turvcodes for each row
begin
  select nvl(:new.id, sq_w_turvcodes.nextval) into :new.id from dual;
end;
/

--!
--insert into w_turvcodes (id, code, name, active) select id,code, name, 1 from ref_turvcodes;

--------------------------------------------------------------------------------
--допустимые разряды
create table w_grades(
  grade number not null unique,    --разряд, в конечных единицах (1, 1.1, 1.3...)
  active number(1) default 1
);


begin
--!
insert into w_grades (grade) values (1);
insert into w_grades (grade) values (1.15);
insert into w_grades (grade) values (1.3);
end;


--------------------------------------------------------------------------------
--сотрудники
--alter table w_employees drop column i;
alter table w_employees add is_concurrent number(1) default 0; 
create table w_employees(
  id number(11),
  f varchar2(25) not null,
  i varchar2(25) not null,
  o varchar2(25),
  birthday date,
  is_concurrent number(1) default 0,        --совместитель (занимает несколько должностей в разных организациях)
  comm varchar2(400),
  active number(1),
  constraint pk_w_employees primary key (id)
);

drop index idx_w_employees;
create unique index idx_w_employees on w_employees(lower(f),lower(i),lower(o), nvl(birthday, date '2099-01-01')); 

create sequence sq_w_employees start with 10000 nocache;

create or replace trigger trg_w_mployees_bi_r before insert on w_employees for each row
begin
  if :new.id is null then
    select sq_w_employees.nextval into :new.id from dual;
   end if;
end;
/


--!!!
--delete from w_employees;
--insert into w_employees(id,f,i,o) select id, f,i,o from ref_workers;

--------------------------------------------------------------------------------
--подразделения
alter table w_departaments drop constraint fk_w_departaments_head;
alter table w_departaments add constraint fk_w_departaments_head foreign key (id_head) references adm_users(id);
create table w_departaments(
  id number(11),
  code varchar(5),
  name varchar2(400),
  id_head number(11),
  id_prod_area number(11),
  is_office number(1) default 0,
  has_foreman number(1) default 0,
  ids_editusers varchar2(4000),
  comm varchar2(400),
  active number(1),
  constraint pk_w_departaments primary key (id),
  constraint fk_w_departaments_head foreign key (id_head) references adm_users(id), 
  constraint fk_w_departaments_area foreign key (id_prod_area) references ref_production_areas(id) 
);

update w_departaments set id_head = null;

create unique index idx_w_departaments_name on w_departaments(lower(name)); 
create unique index idx_w_departaments_code on w_departaments(lower(code)); 

create sequence sq_w_departaments start with 10000 nocache;

create or replace trigger trg_w_departaments_bi_r before insert on w_departaments for each row
begin
  select nvl(:new.id, sq_w_departaments.nextval) into :new.id from dual;
end;
/

--!
--delete from w_departaments;
--insert into w_departaments (id,code,name,id_head,id_prod_area,is_office,ids_editusers,active) select id,code,name,id_head,id_prod_area,office,editusers,active from ref_divisions; 

create or replace view v_w_departaments as  
select
  d.*,
  u.name as head,
  case when d.is_office = 1 then 'офис' else 'цех' end as office,
  case when d.has_foreman = 1 then 'есть бригадир' else '' end as st_foreman,
  getusernames(d.ids_editusers) as editusernames,
  a.name as area_name,  
  a.shortname as area_shortname  
from
  w_departaments d,
  adm_users u,
  ref_production_areas a
where
  d.id_head = u.id (+)
  and a.id = d.id_prod_area
;     


--------------------------------------------------------------------------------
--справочник персональных надбавок
create table w_personal_allowances(
  id number(11),
  name varchar2(400),
  comm varchar2(4000),
  active number(1),
  constraint pk_w_personal_allowances primary key (id)
);  

create unique index idx_w_personal_allowances_name on w_personal_allowances(lower(name)); 

create sequence sq_w_personal_allowances start with 1 nocache;

create or replace trigger trg_w_personal_allowances_bi_r before insert on w_personal_allowances for each row
begin
  select nvl(:new.id, sq_w_personal_allowances.nextval) into :new.id from dual;
end;
/



--------------------------------------------------------------------------------
--таблица графиков работы
alter table w_schedules add duration number;
create table w_schedules(
  id number(11),
  code varchar2(50),
  name varchar2(400),
  comm varchar2(400),
  duration number,
  active number(1),
  constraint pk_w_schedules primary key (id)
);  

create unique index idx_w_schedules_code on w_schedules(lower(code));
create unique index idx_w_schedules_name on w_schedules(lower(name));

create sequence sq_w_schedules start with 1000 nocache;

create or replace trigger trg_w_schedules_bi_r before insert on w_schedules for each row
begin
  select nvl(:new.id, sq_w_schedules.nextval) into :new.id from dual;
end;
/

--!!!
insert into w_schedules(id,code,name,active) select id, code, name, active from ref_work_schedules;

--таблица шаблона графикав
create table w_schedule_templates(
  id_schedule number(11),      --айди графика работы 
  pos number,                  --номер дня циклва
  hours number,                --рабочее время в часах
  constraint pk_w_schedule_templates primary key (id_schedule, pos),
  constraint fk_w_schedule_templates_sсh foreign key (id_schedule) references w_schedules(id) on delete cascade
);

create table w_schedule_periods(
  id_schedule number(11),      --айди графика работы 
  dt date,                     --дата начала периода
  pos_beg number,              --позиция в шаблоне, на которую выпадает первое число месяца  
  approved number,             --график согласован
  hours number,                --рабочее время в часах за месяц
  hours1 number,               --рабочее время в часах, 1й пмериод
  hours2 number,               --рабочее время в часах, 2йф период
  constraint pk_w_schedule_periods primary key (id_schedule, dt),
  constraint fk_w_schedule_periods_sсh foreign key (id_schedule) references w_schedules(id) on delete cascade 
); 

--таблица норма рабочего времени, по графикам и по периодам
  create table w_schedule_hours(
    id number(11),
    id_schedule number(11),      --айди графика работы 
    dt date,                     --дата начала периода
    hours number,                --норма, в часах
    constraint pk_w_schedule_hours primary key (id_schedule, dt),
    constraint fk_w_schedule_hours_sсhedule foreign key (id_schedule) references w_schedules(id) on delete cascade 
  );  
  
  
CREATE OR REPLACE PROCEDURE P_SaveScheduleHours(
  AIdSchedule NUMBER,
  AYear       NUMBER,
  AHours      VARCHAR2
)
AS
  l_date      DATE;
  l_pair      VARCHAR2(100);
  l_idx       PLS_INTEGER := 1;
  l_comma_pos PLS_INTEGER;
  l_dash_pos  PLS_INTEGER;
  l_day_num   NUMBER;
  l_hours_val NUMBER;
BEGIN
  -- 1. Удаляем все записи для указанного графика и заданного года
  DELETE FROM w_schedule_hours
   WHERE id_schedule = AIdSchedule
     AND dt >= TO_DATE(AYear || '-01-01', 'YYYY-MM-DD')
     AND dt <=  TO_DATE(AYear || '-12-31', 'YYYY-MM-DD');
  -- 2. Если строка пустая — завершаем
  IF AHours IS NULL OR TRIM(AHours) = '' THEN
    RETURN;
  END IF;
  -- 3. Разбираем строку вида '1-0,9-8,200-6.5'
  WHILE l_idx <= LENGTH(AHours) LOOP
    -- Найдём позицию следующей запятой
    l_comma_pos := INSTR(AHours, ',', l_idx);
    IF l_comma_pos = 0 THEN
      l_pair := TRIM(SUBSTR(AHours, l_idx));
      l_idx := LENGTH(AHours) + 1;
    ELSE
      l_pair := TRIM(SUBSTR(AHours, l_idx, l_comma_pos - l_idx));
      l_idx := l_comma_pos + 1;
    END IF;
    -- Пропускаем пустые фрагменты
    CONTINUE WHEN l_pair IS NULL OR l_pair = '';
    -- Найдём дефис
    l_dash_pos := INSTR(l_pair, '-');
    IF l_dash_pos = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Неверный формат пары: ' || l_pair);
    END IF;
    -- Извлекаем день и часы
    l_day_num := TO_NUMBER(SUBSTR(l_pair, 1, l_dash_pos - 1));
    l_hours_val := TO_NUMBER(SUBSTR(l_pair, l_dash_pos + 1));
    -- Проверяем корректность дня года (1–366)
    IF l_day_num < 1 OR l_day_num > 366 THEN
      RAISE_APPLICATION_ERROR(-20002, 'Недопустимый день года: ' || l_day_num);
    END IF;
    -- Формируем дату: 1 января AYear + (l_day_num - 1) дней
    BEGIN
      --l_date := TO_DATE(TO_CHAR(AYear, 'FM0000'), 'YYYY') + (l_day_num - 1);
      l_date := TO_DATE(AYear || '-01-01', 'YYYY-MM-DD') + (l_day_num - 1);
      -- Убедимся, что дата действительно в том же году (защита от 366 в невисокосный год)
      IF EXTRACT(YEAR FROM l_date) != AYear THEN
        RAISE_APPLICATION_ERROR(-20003, 'День ' || l_day_num || ' не существует в году ' || AYear);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Ошибка при создании даты для года ' || AYear || ' и дня ' || l_day_num);
    END;
    -- 4. Вставляем запись (поле ID может быть NULL, так как не используется в PK)
    INSERT INTO w_schedule_hours (id_schedule, dt, hours)
    VALUES (AIdSchedule, l_date, l_hours_val);
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END P_SaveScheduleHours;
/  


--------------------------------------------------------------------------------
--таблица - справочник персональных надбавок
alter table w_pers_bonus add active number(1);
create table w_pers_bonus(
  id number(11),
  name varchar2(400),
  comm varchar2(4000),
  active number(1),
  constraint pk_w_pers_bonus primary key (id)
);  

create unique index idx_w_pers_bonus_uq on w_pers_bonus(lower(name));

create sequence sq_w_pers_bonus start with 1 nocache;

create or replace trigger trg_w_pers_bonus_bi_r before insert on w_pers_bonus for each row
begin
  select nvl(:new.id, sq_w_pers_bonus.nextval) into :new.id from dual;
end;
/

create table w_pers_bonus_sum(
  id_pers_bonus number(11),
  dt date,                     --дата начала месяца
  sum number,                  --сумма надбавки за месяц                    
  constraint pk_w_pers_bonus_sum primary key (id_pers_bonus, dt),
  constraint fk_w_pers_bonus_sum foreign key (id_pers_bonus) references w_pers_bonus(id) on delete cascade
);  


CREATE OR REPLACE PROCEDURE P_extend_pers_bonuses as 
-- проставим суммы персональных надбавок в справочнике за текущий месяц равными теми, что были в прошшлом месяце
--(только если значение в текущем еще не введено, и если надбавка активна)
BEGIN
MERGE INTO w_pers_bonus_sum target
USING (
  SELECT 
    b.id AS id_pers_bonus,
    TRUNC(SYSDATE, 'MM') AS dt_current,
    (
      SELECT prev.sum
      FROM w_pers_bonus_sum prev
      WHERE prev.id_pers_bonus = b.id
        AND prev.dt = ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1)
    ) AS sum_from_prev
  FROM w_pers_bonus b
  WHERE b.active = 1
) src
ON (target.id_pers_bonus = src.id_pers_bonus AND target.dt = src.dt_current)
WHEN MATCHED THEN
  UPDATE SET sum = src.sum_from_prev
  WHERE target.sum IS NULL
WHEN NOT MATCHED THEN
  INSERT (id_pers_bonus, dt, sum)
  VALUES (src.id_pers_bonus, src.dt_current, src.sum_from_prev);
END;
/  

create or replace view v_w_pers_bonus as
select
  b.*,
  to_date(to_char(add_months(sysdate, -1), 'yyyy-mm') || '-01', 'yyyy-mm-dd') as dt1,
  s1.sum as sum1,
  to_date(to_char(sysdate, 'yyyy-mm') || '-01', 'yyyy-mm-dd') as dt2,
  s2.sum as sum2,
  to_date(to_char(add_months(sysdate, 1), 'yyyy-mm') || '-01', 'yyyy-mm-dd') as dt3,
  s3.sum as sum3
from  
  w_pers_bonus b,
  w_pers_bonus_sum s1,
  w_pers_bonus_sum s2,
  w_pers_bonus_sum s3
where  
  s1.id_pers_bonus(+) = b.id and s1.dt(+) = to_date(to_char(add_months(sysdate, -1), 'yyyy-mm') || '-01', 'yyyy-mm-dd')
  and s2.id_pers_bonus(+) = b.id and s2.dt(+) = to_date(to_char(add_months(sysdate, 0), 'yyyy-mm') || '-01', 'yyyy-mm-dd')
  and s3.id_pers_bonus(+) = b.id and s3.dt(+) = to_date(to_char(add_months(sysdate, 1), 'yyyy-mm') || '-01', 'yyyy-mm-dd')
;  

select * from v_w_pers_bonus;

create table w_employee_pers_bonus(
  id number(11),
  id_employee number(11),
  id_pers_bonus number(11),
  dt_beg date,                     
  dt_end date,                     
  constraint pk_w_employee_pers_bonus primary key (id),
  constraint fk_w_employee_pers_bonus_b foreign key (id_pers_bonus) references w_pers_bonus(id),
  constraint fk_w_employee_pers_bonus_e foreign key (id_employee) references w_employees(id)
);

create sequence sq_w_employee_pers_bonus start with 1 nocache;

create or replace trigger trg_w_employee_pers_bonus_bi_r before insert on w_employee_pers_bonus for each row
begin
  select nvl(:new.id, sq_w_employee_pers_bonus.nextval) into :new.id from dual;
end;
/
  
create or replace function F_Check_w_employee_pers_bonus(
  p_id            in number,
  p_id_employee   in number,
  p_id_pers_bonus in number,
  p_dt_beg        in date,
  p_dt_end        in date
) return boolean
is
  pragma autonomous_transaction;  --так как в триггере for each row
  l_count pls_integer;
  c_max_date constant date := date '9999-12-31';
begin
  if (p_dt_beg is null) or (nvl(p_dt_end, c_max_date) < p_dt_beg) then
    return false;
  end if;
  select count(*)
  into l_count
  from w_employee_pers_bonus
  where id_employee = p_id_employee
    and id_pers_bonus = p_id_pers_bonus
    and id != nvl(p_id, -1)  -- исключаем саму себя при update
    and ( 
            (p_dt_end is null and p_dt_beg <= dt_end) or           -- новая запись бессрочная: старая не должна начинаться до или в p_dt_beg
            (p_dt_end is not null and dt_end is null and p_dt_end >= dt_beg) or  --новая с датой окончания, старая бессрочная
            (p_dt_end is null and p_dt_end is null) or                           --обе бессрочные 
            (p_dt_end is not null and dt_end is not null and 
             p_dt_beg <= dt_end and dt_beg <= p_dt_end)            -- обе записи срочные: стандартное пересечение
    );      
  return (l_count = 0);
end;
/

create or replace trigger trg_w_employee_pers_b_biu_r before insert or update on w_employee_pers_bonus for each row
begin
  if not F_Check_w_employee_pers_bonus(:new.id, :new.id_employee, :new.id_pers_bonus, :new.dt_beg, :new.dt_end) then
    raise_application_error(-20002, 'Диапазон дат перекрывается с существующей записью для данного работника и типа бонуса.');
  end if;
end;
/

create or replace view v_w_employee_pers_bonus as
select 
  e.id || '-' || b.id as id, 
  t.name as bonus_name,
  t.comm,
  b.id as id_empl_bonus,
  b.dt_beg,
  b.dt_end,
  e.name as employee,
  e.personnel_number,
  e.birthday,
  e.id as id_employee
from  
  w_pers_bonus t,
  w_employee_pers_bonus b,
  v_w_employees e
where
  b.id_pers_bonus = t.id (+)
  and b.id_employee (+) = e.id
  --and e.is_working_now = 'работает'
;

select * from v_w_employees where id = 458;
select * from v_w_employees where is_working_now is null; 
 

create or replace view v_w_employee_pers_bonus_get as
select 
  b.id, 
  b.id_pers_bonus, 
  t.name,
  t.comm,
  b.dt_beg,
  b.dt_end,
  s.dt,
  s.sum
from  
  w_pers_bonus t,
  w_employee_pers_bonus b,
  w_pers_bonus_sum s
where
  b.id_pers_bonus = t.id 
  and s.id_pers_bonus (+) = t.id
;    
    
--create or replace view v_w_employee_pers_bonus_get2 as
--select b.id, b.id_employee, b.id_pers_bonus, b.dt_beg, b.dt_end from w_employee_pers_bonus b, w_pers_bonus_sum s where b.id_pers_bonus = s.id_pers_bonus (+) and s.dt (+) = :dt$d and id_employee in (1,39,77) and dt_beg <= :dt_end$d and (dt_end is null or dt_end >= :dt_beg$d);

--------------------------------------------------------------------------------

--статусы работников (когда и куда принят/переведен/уволен)
alter table w_employee_properties add grade number default 1;
create table w_employee_properties(
  id number(11),
  dt date,
  dt_beg date,
  dt_end date,  
  id_employee number(11),
  is_hired number(1) default 0,
  is_terminated  number(1) default 0,
  id_organization number(11),               --организация, в которой числится работники
  personnel_number varchar2(10),            --табельный номер (уникален для организации, номер уволенного не повторится, номер вновь принятого будет другой чем ранее
  id_departament number(11),
  id_job number(11),
  id_schedule number(11),
  is_concurrent number(1) default 0,        --совместитель (занимает несколько должностей в разных организациях)  ---!!!
  is_foreman number(1) default 0,
  is_trainee number(1) default 0,           --ученик
  grade number default 1,                    --разряд
  comm varchar(4000), 
  id_manager number(11),
  --deleted number(1) default 0,              
  constraint pk_w_employee_properties primary key (id),
  constraint fk_w_employee_properties_emp foreign key (id_employee) references w_employees,
  constraint fk_w_employee_properties_org foreign key (id_organization) references ref_sn_organizations(id), 
  constraint fk_w_employee_properties_div foreign key (id_departament) references w_departaments(id), 
  constraint fk_w_employee_properties_job foreign key (id_job) references w_jobs(id), 
  constraint fk_w_employee_properties_mgr foreign key (id_manager) references adm_users(id),
  constraint fk_w_employee_properties_sch foreign key (id_schedule) references w_schedules(id)
);

create sequence sq_w_employee_properties start with 100000 nocache;

create index idx_w_employee_properties_div on w_employee_properties(id_departament); 
create index idx_w_employee_properties_job on w_employee_properties(id_job); 
create index idx_w_employee_properties_emp on w_employee_properties(id_employee); 

CREATE UNIQUE INDEX idx_employee_properties_pn
ON w_employee_properties (
    CASE 
        WHEN is_hired = 1 AND id_organization IS NOT NULL 
        THEN id_organization 
        ELSE NULL 
    END,
    CASE 
        WHEN is_hired = 1 AND id_organization IS NOT NULL 
        THEN personnel_number 
        ELSE NULL 
    END,
    CASE 
        WHEN is_hired = 1 AND id_organization IS NULL AND personnel_number IS NOT NULL 
        THEN personnel_number   -- Индексируем номер, чтобы он был уникален среди NULL-организаций
        ELSE NULL 
    END
);

WITH duplicates AS (
  -- Находим все пары (организация, номер), которые дублируются
  SELECT id_organization, personnel_number
  FROM w_employee_properties
  WHERE is_hired = 1 
    AND id_organization IS NOT NULL
    AND personnel_number IS NOT NULL
  GROUP BY id_organization, personnel_number
  HAVING COUNT(*) > 1
  
  UNION ALL
  
  -- Находим все номера без организации, которые дублируются
  SELECT NULL AS id_organization, personnel_number
  FROM w_employee_properties
  WHERE is_hired = 1 
    AND id_organization IS NULL
    AND personnel_number IS NOT NULL
  GROUP BY personnel_number
  HAVING COUNT(*) > 1
)
-- Выбираем все строки, попадающие в найденные дубликаты
SELECT 
  w.*,
  CASE 
    WHEN w.id_organization IS NOT NULL THEN 'Организация: ' || w.id_organization
    ELSE 'Без организации'
  END AS duplicate_group
FROM w_employee_properties w
WHERE EXISTS (
  SELECT 1 FROM duplicates d
  WHERE (d.id_organization = w.id_organization OR 
         (d.id_organization IS NULL AND w.id_organization IS NULL))
    AND d.personnel_number = w.personnel_number
    AND w.is_hired = 1
)
ORDER BY 
  w.id_organization NULLS FIRST,
  w.personnel_number,
  w.id;
  

WITH index_calc AS (
  SELECT 
    id,
    id_employee,
    is_hired,
    id_organization,
    personnel_number,
    -- Рассчитываем значения, которые попадут в функциональный индекс
    CASE 
      WHEN is_hired = 1 AND id_organization IS NOT NULL 
      THEN id_organization 
      ELSE NULL 
    END AS idx_org,
    CASE 
      WHEN is_hired = 1 AND id_organization IS NOT NULL 
      THEN personnel_number 
      ELSE NULL 
    END AS idx_number,
    CASE 
      WHEN is_hired = 1 AND id_organization IS NULL AND personnel_number IS NOT NULL 
      THEN personnel_number 
      ELSE NULL 
    END AS idx_null_org_number
  FROM w_employee_properties
)
SELECT 
  id,
  id_employee,
  is_hired,
  id_organization,
  personnel_number,
  idx_org,
  idx_number,
  idx_null_org_number
FROM index_calc
WHERE (idx_org, idx_number) IN (
  -- Находим дубликаты для случая с организацией
  SELECT idx_org, idx_number
  FROM index_calc
  WHERE idx_org IS NOT NULL AND idx_number IS NOT NULL
  GROUP BY idx_org, idx_number
  HAVING COUNT(*) > 1
)
OR idx_null_org_number IN (
  -- Находим дубликаты для случая без организации
  SELECT idx_null_org_number
  FROM index_calc
  WHERE idx_null_org_number IS NOT NULL
  GROUP BY idx_null_org_number
  HAVING COUNT(*) > 1
)
ORDER BY 
  CASE 
    WHEN idx_org IS NOT NULL THEN idx_org 
    ELSE 999999 
  END,
  idx_number,
  idx_null_org_number;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

create or replace trigger trg_w_employee_properties_bi_r before insert on w_employee_properties for each row
begin
  select nvl(:new.id, sq_w_employee_properties.nextval) into :new.id from dual;
end;
/


select * from w_employee_properties order by id_employee, dt_beg;

create or replace view v_w_employees as
with
--последнее событие приёма  
last_hired as (
    select
        id_employee,
        is_hired,
        is_terminated,
        dt_beg,
        row_number() over (partition by id_employee order by id desc) as rn
    from w_employee_properties
    where is_hired = 1
),
--последнее событие увольнения 
last_terminated as (
    select
        id_employee,
        is_hired,
        is_terminated,
        dt_beg,
        row_number() over (partition by id_employee order by id desc) as rn
    from w_employee_properties
    where is_terminated = 1
),
--первая запись вообще
first_any_event as (
    select
        dt_beg,
        id_employee,
        id_departament,
        id_job,
        row_number() over (partition by id_employee order by id asc) as rn
    from w_employee_properties
),
--последняя запись вообще, за исключением увольнения
last_any_event as (
    select
        dt_beg,
        id_employee,
        id_departament,
        id_job,
        personnel_number,
        id_organization,
        row_number() over (partition by id_employee order by id desc) as rn
    from w_employee_properties
    where is_terminated <> 1
),
--Дата последнего изменения отдела/должности (исключая увольнения)
last_transfer as (
    select
        id_employee,
        max(dt_beg) as dt_beg
    from (
        select
            id_employee,
            dt_beg,
            id_departament,
            id_job,
            lag(id_departament) over (partition by id_employee order by id) as prev_dept,
            lag(id_job) over (partition by id_employee order by id) as prev_job
        from w_employee_properties
        where is_terminated = 0 --исключаем увольнения
    )
    where
      (id_departament <> prev_dept or nvl(id_departament, -999) <> nvl(prev_dept, -999))
      or ((id_job <> prev_job) or nvl(id_job, -999) <> nvl(prev_job, -999))
      or prev_dept is null --первая запись (не увольнение) считается как "изменение" (приём)
    group by id_employee
)
--сам запрос получения данных
select
  e.id,
  e.birthday,
  floor(months_between(sysdate, e.birthday) / 12) as age,
  f_fio(e.f, e.i, e.o) as name,
  f.dt_beg as dt_reg,
  h.dt_beg as last_hired,
  case when t.dt_beg > h.dt_beg then t.dt_beg else null end as last_terminated,
  case when t.dt_beg > h.dt_beg then 'уволен' when h.dt_beg is not null then 'работает' else null end as is_working_now,
  lt.dt_beg as dt_last_transfer,
  d.name as departament,
  j.name as job,
  a.personnel_number,
  a.id_organization,
  o.name as organization,
  e.is_concurrent,
  e.comm
from w_employees e
left join last_hired h on e.id = h.id_employee and h.rn = 1
left join last_terminated t on e.id = t.id_employee and t.rn = 1
left join first_any_event f on e.id = f.id_employee and f.rn = 1
left join last_any_event a on e.id = a.id_employee and a.rn = 1
left outer join last_transfer lt on e.id = lt.id_employee
left outer join w_departaments d on a.id_departament = d.id and a.rn = 1
left outer join w_jobs j on a.id_job = j.id and a.rn = 1
left outer join ref_sn_organizations o on a.id_organization = o.id and a.rn = 1
;


create or replace view v_w_employee_properties as  
select
  ep.*,
  row_number() over (partition by ep.id_employee order by ep.id) as rn,
  case when is_hired = 1 then 'принят' when is_terminated = 1 then 'уволен' else 'переведен' end as status,
  f_fio(e.f, e.i, e.o) as name,
  f_fio(e.f, e.i, e.o) as employee,
  f_fio(e.f, e.i, e.o) || ' - ' || o.name || ' - ' || personnel_number || '' as employee_st,
  o.name as organization,
  d.name as departament,
  d.ids_editusers,
  d.id_head,
  j.name as job,
  s.code as schedulecode,
  decode(ep.is_foreman, 1, 'бригадир', null) as foreman, 
  decode(ep.is_concurrent, 1, 'совместитель', null) as concurrent,
  decode(ep.is_trainee, 1, 'ученик', null) as trainee,
  j.has_milk_compensation,
  u.name as managername 
from
  w_employees e,
  w_employee_properties ep,
  w_departaments d,
  w_jobs j,
  ref_sn_organizations o,
  w_schedules s,
  --w_schedule_hours h,
  adm_users u
where  
  ep.id_employee = e.id and
  ep.id_departament = d.id (+) and
  ep.id_job = j.id (+) and
  ep.id_organization = o.id (+) and
  ep.id_schedule = s.id (+) and
  ep.id_manager = u.id (+)
  ;

--!
--delete from w_employee_properties;
--insert into w_employee_properties(id, dt, id_employee, id_job, id_departament, is_hired, is_terminated, dt_beg) 
--  select id, dt, id_worker, id_job, id_division, decode(status, 1, 1, 0), decode(status ,3 , 1, 0), dt from j_worker_status;
  

select distinct employee from v_w_employee_properties where is_terminated = 1 and dt_beg > date '2025-12-01';

--в случае незанесения айди работника в таблицу по днямм, проставим эту информацию (т.к. она избыточна и соответственно имеется)
update w_turv_day d set id_employee = (select id_employee from w_employee_properties p where p.id = d.id_employee_properties) where d.id_employee is null; 
  
--------------------------------------------------------------------------------

--таблица турв по подразделению за период
--alter table w_turv_period drop constraint fk_w_turv_period_dep;
--alter table w_turv_period add constraint fk_w_turv_period_dep  foreign key (id_departament) references w_departaments(id);
alter table w_turv_period add foreman_allowance number;
create table w_turv_period(  
  id number(11),                   
  id_departament number(11),        --подразделение
  dt1 date,                         --дата начала периода ТУРВ
  dt2 date,                         --дата конца периода ТУРВ
  is_finalized number(1),           --период закрыт
  foreman_allowance number,              --доплата бригадиру, сумма в месяц
  foreman_allowance_comm varchar2(400),  --комментарий по данной доплате
  status number(1),                 --статус заполенности данных
  constraint pk_w_turv_period  primary key (id),
  constraint fk_w_turv_period_dep foreign key (id_departament) references w_departaments(id)
);

create unique index idx_w_turv_period_1 on w_turv_period(id_departament, dt1);

create sequence sq_w_turv_period start with 10000 nocache;

create or replace trigger trg_w_turv_period_bi_r before insert on w_turv_period for each row
begin
  select nvl(:new.id, sq_w_turv_period.nextval) into :new.id from dual;
end;

create or replace view v_w_turv_period as  
select
  p.*,
  d.name,
  d.name as departament,
  d.is_office,
  case when d.is_office = 1 then 'офис' else 'цех' end as isoffice,
  case when p.is_finalized = 1 then 'закрыт' else '' end as finalized,
  getusernames(d.ids_editusers) as editusernames,
  d.ids_editusers,
  d.code 
from
  w_turv_period p,
  w_departaments d
where
  d.id = p.id_departament
;   


--!
--delete from w_turv_period;
--insert into w_turv_period (id, id_departament, dt1, dt2, commit, status) select id, id_division, dt1, dt2, commit, status from turv_period;  


--------------------------------------------------------------------------------

alter table w_turv_day add begendtime2 varchar2(100);;
--alter  table w_turv_day add constraint  fk_turv_day_turvcode2 foreign key (id_turvcode2) references ref_turvcodes(id);
--таблица турв для конкретного работника за конкретный день
create table w_turv_day(
  id number(11),        
  id_employee_properties number(11),             --
  id_employee number(11),             --
  dt date,                          --дата ТУРВ (день)
  id_turvcode1 number(11),          --код турв по мастерам
  worktime1 number(4,2),            --время работы по мастерам 
  comm1 varchar2(400),              --примечание руководителя 
  id_turvcode2 number(11),          --код турв по парсеку
  worktime2 number(4,2),            --время работы по парсеку
  comm2 varchar2(400),              --примечание ОК 
  id_turvcode3 number(11),          --код согласованный 
  worktime3 number(4,2),            --время работы согласованное 
  comm3 varchar2(400),              --примечание по согласованному  
  premium number(5),                --сумма премии за день
  premium_comm varchar2(400),       --примечание к премии 
  penalty number(5),                --сумма штрафа
  penalty_comm varchar2(400),       --примечание к штрафу 
  production number(1),             --выработка (сдана, нет)
  begtime number(4,2),              --время прихода по парсеку  
  endtime number(4,2),              --время ухода по парсеку
  begendtime2 varchar2(100),        --текстовое поле, содержащие времна ухода и прихода по парсеку, если их было несколько  
  nighttime number(4,2),            --время работы в ночную смену
  settime3 number(1),               --1, когда время по парсеку worktime2 установлено 
  constraint pk_w_turv_day primary key (id),
  constraint fk_w_turv_day_employee foreign key (id_employee) references w_employees(id),
  constraint fk_w_turv_day_emp_prop foreign key (id_employee_properties) references W_employee_properties(id), 
  constraint fk_W_turv_day_turvcode1 foreign key (id_turvcode1) references w_turvcodes(id),
  constraint fk_w_turv_day_turvcode2 foreign key (id_turvcode2) references w_turvcodes(id),
  constraint fk_w_turv_day_turvcode3 foreign key (id_turvcode3) references w_turvcodes(id)
);

create unique index idx_w_turv_day_e on w_turv_day(id_employee, dt);
drop index idx_w_turv_day_ep;
create unique index idx_w_turv_day_ep on w_turv_day(id_employee_properties, dt);

create sequence sq_w_turv_day start with 1 nocache;

create or replace trigger trg_w_turv_day_bi_r before insert on w_turv_day for each row
begin
  select nvl(:new.id, sq_w_turv_day.nextval) into :new.id from dual;
end;

--update w_turv_day d set id_employee_properties = (select id from w_employee_properties p where p.is_terminated <> 1 and d.id_employee = p.id_employee and d.dt >= p.dt_beg and d.dt <= nvl(p.dt_end, TO_DATE('15.11.2027', 'DD.MM.YYYY')));



--------------------------------------------------------------------------------
--методы расчета З/П
--пока определяются просто значением АйДи
/*
drop table w_payroll_calculation_methods cascade constraints;
create table w_payroll_calculation_methods(
  id number(11),
  name varchar2(400),
  comm varchar2(4000),
  constraint pk_w_payroll_calculation_mtds primary key (id)
);  

insert into w_payroll_calculation_methods select * from payroll_method;
*/

--------------------------------------------------------------------------------
--drop table w_payroll_calc cascade constraints;
alter table w_payroll_calc add id_organization number(11); --айди организации
alter table w_payroll_calc add personnel_number varchar2(10);  --табельный номер 
create table w_payroll_calc ( 
  id number(11),
  id_departament number(11), --айди подразделения
  id_employee number(11),    --айди раболтника 
  id_organization number(11), --айди организации
  personnel_number varchar2(10),  --табельный номер 
  calc_method number(11),    --общий метод расчета   
  overtime_method number(11),--метод учета переработки    
  dt1 date,                  --дата начала ведомости, по полмесяца, как в турв
  dt2 date,                  --дата конца ведомости
  is_finalized number(1),    --период закрыт
  constraint pk_w_payroll_calc primary key (id),
  constraint fk_w_payroll_calc_div foreign key (id_departament) references w_departaments(id),
  constraint fk_w_payroll_calc_emp foreign key (id_employee) references w_employees(id)
);

--уникальный индекс по подразделению/работнику/дате начала
drop index idx_w_payroll_calc_uq;
create unique index idx_w_payroll_calc_uq on w_payroll_calc(id_departament, id_employee, id_organization, personnel_number, dt1);

create sequence sq_w_payroll_calc start with 1000 nocache;

create or replace trigger trg_w_payroll_calc_bi_r before insert on w_payroll_calc for each row
begin
  select nvl(:new.id, sq_w_payroll_calc.nextval) into :new.id from dual;
end;

--вью для журнала зарплатных ведомостей
create or replace view v_w_payroll_calc as 
select
  p.*,
  case when p.is_finalized = 1 then 'Закрыта' else '' end as finalized,
  f_fio(e.f, e.i, e.o) as employee,
  d.name as departament,
  o.name as organization,
  d.is_office,
  d.code
from
  w_payroll_calc p,
  w_employees e,
  w_departaments d,
  ref_sn_organizations o 
where
  p.id_departament = d.id
  and p.id_employee = e.id (+)
  and p.id_organization = o.id (+)
;

/*
назвать поля оклад, плановое начисление зп, постоянная часть зп, стимулирующая часть заработной платы, итого начислено за период, надбавка за работу бригадиром, суммарная ежедневная премия, дополнительная премия, надбавка за вредность на покупку молока, ручная корректировка зарплаты, депремирование, начисление за отпуск, начисление за больничный, итого начислено
*/


--данные зарплатной ведомости для конкретного работника из ведомости
--данные сопоставляются с турв по подразделению, айди работника, должности, расписания, организации, и табельному номеру
--alter table w_payroll_calc_item drop column personnel_number;
alter table w_payroll_calc_item add ors_pay1 number;
alter table w_payroll_calc_item add ors1 number;
alter table w_payroll_calc_item add period_hours_norm1 number;
alter table w_payroll_calc_item add hours_worked1 number;
alter table w_payroll_calc_item add overtime1 number;
alter table w_payroll_calc_item add total_pay1 number;
alter table w_payroll_calc_item add from_first_period number;
alter table w_payroll_calc_item add base_pay1 number;
alter table w_payroll_calc_item add base_pay2 number;
alter table w_payroll_calc_item add ext_pay1 number;
alter table w_payroll_calc_item add adjustments_total1 number;

create table w_payroll_calc_item(
  id number(11),
  id_payroll_calc number(11),     --айди зарплатной ведомости, в которую входит эта строка
  id_employee number(11),         --айди раболтника 
  id_job number(11),              --айди должности 
  id_schedule number(11),         --айди графика
  id_organization number(11),     --айди организации, в которой числится работник
  personnel_number varchar2(10),  --табельный номер 
  monthly_hours_norm number,      --норма за месяц, по данной строке табеля для работника
  period_hours_norm number,       --норма за период ведомости, по данной строке табеля для работника     
  hours_worked number,            --отработано по турв
  overtime number,                --количество часов переработки (приведенное)
  planned_pay number,             --плановое начисление
  fixed_pay number,               --постоянная часть
  variable_pay number,            --стимулирующая часть
  ors number,                     --оценка работы сотрудника, %
  ors_pay number,                 --оценка работы сотрудника, сумма, начисленная исходя из оценки
  base_pay number,                --итого рассчитано
  ext_pay number,                 --загружено из внешнего источника (рассчет сделки)
  overtime_pay number,            --выплаты за переработки 
  personal_pay number,            --персональная выплата
  daily_bonus number,             --ежедневные премии (не депремирование!) из турв
  extra_bonus number,             --дополнительная премия, вводится в ведомости
  night_pay number,               --выплата за ночные часы, вводится в ведомости
  milk_compensation number,       --выплата за молоко  
  non_work_pay number,            --оплата неотработанного вермени (ОТ/БЛ)
  penalty number,                 --депремирование
  correction number,              --ручная корректировка начисления, вводится в ведомости
  total_pay number,               --итого начислено 
  constraint pk_w_payroll_calc_item primary key (id),
  constraint fk_w_payroll_calc_i_own foreign key (id_payroll_calc) references w_payroll_calc(id) on delete cascade,
  constraint fk_w_payroll_calc_i_emp foreign key (id_employee) references w_employees(id),
  constraint fk_w_payroll_calc_i_job foreign key (id_job) references w_jobs(id),
  constraint fk_w_payroll_calc_i_sch foreign key (id_schedule) references w_schedules(id),
  constraint fk_w_payroll_calc_i_org foreign key (id_organization) references ref_sn_organizations(id)
);  
  
--drop sequence sq_w_payroll_calculations_item;
create sequence sq_w_payroll_calc_item start with 100000 nocache;

--create unique index idx_payroll_item_unique on payroll_item(id_division, id_worker, dt);
--create index idx_payroll_item_dt_job on payroll_item(dt, id_job);

create or replace trigger trg_w_payroll_calc_item_bi_r before insert on w_payroll_calc_item for each row
begin
  select nvl(:new.id, sq_w_payroll_calc_item.nextval) into :new.id from dual;
end;
   

--вью для элемента (записи по работнику в данном подразделении) зарплатных ведомостей
create or replace view v_w_payroll_calc_item as 
select
  i.*,
  s.code as schedulecode,
  s.code as schedule,
  --s.code || ' (' || to_char(i.period_work_hours_norm) || ')' as schedule,
  p.id_departament as id_target_departament,
  p.id_employee as id_target_employee,
  p.id_organization as id_target_organization,
  p.personnel_number as target_personnel_number,
  p.is_finalized,
  p.dt1,
  p.dt2,
  p.calc_method,
  p.overtime_method,
  --f_fio(e.f, e.i, e.o) as employee,
  --e.personnel_number,
  e.name as employee,
  --e.concurrent_employee,
  o.name as organization,
  d.name as departament,
  d.id_prod_area,
  a.shortname as prod_area_shortname,
  a.name as prod_area_name,
  j.name as job,
  0 as changed,
  null as temp
from
  w_payroll_calc_item i
  inner join w_payroll_calc p on i.id_payroll_calc = p.id
  left outer join w_departaments d on p.id_departament = d.id
  left outer join v_w_employees e on i.id_employee = e.id
  left outer join w_jobs j on i.id_job = j.id  
  left outer join w_schedules s on i.id_schedule = s.id 
  left outer join ref_production_areas a on d.id_prod_area = a.id
  left outer join ref_sn_organizations o on i.id_organization = o.id
;  

select id_employee, id_organization, personnel_number, employee, organization, personnel_number, total_pay, null as temp from v_w_payroll_calc_item where id_employee = 721 and id_organization = 1 and personnel_number = '488' and id_target_employee <> null;
--------------------------------------------------------------------------------

create table w_payroll_transfer ( 
  id number(11),
  id_employee number(11),    --айди раболтника 
  id_organization number(11), --айди организации
  personnel_number varchar2(10),  --табельный номер 
  dt1 date,                  --дата начала ведомости, по полмесяца, как в турв
  dt2 date,                  --дата конца ведомости
  is_finalized number(1),    --период закрыт
  constraint pk_w_payroll_transfer primary key (id),
  constraint fk_w_payroll_transfer_empl foreign key (id_employee) references w_employees(id)
);

--уникальный индекс по подразделению/работнику/дате начала
--create unique index idx_w_payroll_transfer_uq on w_payroll_transfer(id_departament, id_employee, dt1);

create sequence sq_w_payroll_transfer start with 1000 nocache;

create or replace trigger trg_w_payroll_transfer_bi_r before insert on w_payroll_transfer for each row
begin
  select nvl(:new.id, sq_w_payroll_transfer.nextval) into :new.id from dual;
end;

--вью для журнала зарплатных ведомостей
create or replace view v_w_payroll_transfer as 
select
  p.*,
  case when p.is_finalized = 1 then 'Закрыта' else '' end as finalized,
  f_fio(e.f, e.i, e.o) as employee,
  o.name as organization
from
  w_payroll_transfer p,
  w_employees e,
  ref_sn_organizations o 
where
  p.id_employee = e.id (+)
  and p.id_organization = o.id (+)
;

alter table w_payroll_transfer_item add correction number; 
create table w_payroll_transfer_item(
  id number(11),
  id_payroll_transfer number(11),     --айди зарплатной ведомости, в которую входит эта строка
  id_employee number(11),         --айди раболтника 
  id_organization number(11),     --айди организации, в которой числится работник
  personnel_number varchar2(10),  --табельный номер
  is_concurrent number(1), 
  hours_worked number,            --отработано по турв
  overtime number,                --количество часов переработки (приведенное)
  total_pay number,               --итого начислено 
  ors_pay number,
  deduct_enf number,      -- удержание по исполнительному листу
  deduct_ndfl number,     -- НДФЛ
  pay_fss number,         -- выплата в ФСС (например, больничный)
  pay_adv number,         -- промежуточная (авансовая) выплата
  pay_card number,        -- перечислено на карту
  correction number,              --ручная корректировка начисления, вводится в ведомости
  pay_cash number,        -- итого к выдаче наличными  
  constraint pk_w_payroll_transfer_item primary key (id),
  constraint fk_w_payroll_transfer_i_own foreign key (id_payroll_transfer) references w_payroll_transfer(id) on delete cascade,
  constraint fk_w_payroll_transfer_i_emp foreign key (id_employee) references w_employees(id),
  constraint fk_w_payroll_transfer_i_org foreign key (id_organization) references ref_sn_organizations(id)
);  
  
--drop sequence sq_w_payroll_transferulations_item;
create sequence sq_w_payroll_transfer_item start with 100000 nocache;

--create unique index idx_payroll_item_unique on payroll_item(id_division, id_worker, dt);
--create index idx_payroll_item_dt_job on payroll_item(dt, id_job);

create or replace trigger trg_w_payroll_transfer_it_bi_r before insert on w_payroll_transfer_item for each row
begin
  select nvl(:new.id, sq_w_payroll_transfer_item.nextval) into :new.id from dual;
end;

--delete from w_payroll_transfer;
   

--вью для элемента (записи по работнику в данном подразделении) зарплатных ведомостей
create or replace view v_w_payroll_transfer_item as 
select
  i.*,
  p.dt1,
  p.dt2,
  p.id_employee as id_target_employee,
  e.name as employee,
  --e.is_concurrent,
  o.name as organization,
  --d.name as departament,
  0 as changed,
  null as temp
from
  w_payroll_transfer_item i,
  w_payroll_transfer p,
  v_w_employees e,
  ref_sn_organizations o
  --w_departaments d
where
  i.id_payroll_transfer = p.id and
  i.id_employee (+) = e.id and 
  i.id_organization = o.id (+) 
  --and p.id_departament (+) = d.id 
;     


--------------------------------------------------------------------------------
create table w_payroll_cash ( 
  id number(11),
  id_departament number(11), --айди подразделения
  id_employee number(11),    --айди раболтника 
  id_organization number(11), --айди организации
  personnel_number varchar2(10),  --табельный номер 
  dt1 date,                  --дата начала ведомости, по полмесяца, как в турв
  dt2 date,                  --дата конца ведомости
  is_finalized number(1),    --период закрыт
  constraint pk_w_payroll_cash primary key (id),
  constraint fk_w_payroll_cash_div foreign key (id_departament) references w_departaments(id),
  constraint fk_w_payroll_cash_empl foreign key (id_employee) references w_employees(id)
);



--уникальный индекс по подразделению/работнику/дате начала
--create unique index idx_w_payroll_cash_uq on w_payroll_cash(id_departament, id_employee, dt1);

create sequence sq_w_payroll_cash start with 1000 nocache;

create or replace trigger trg_w_payroll_cash_bi_r before insert on w_payroll_cash for each row
begin
  select nvl(:new.id, sq_w_payroll_cash.nextval) into :new.id from dual;
end;

--вью для журнала зарплатных ведомостей
create or replace view v_w_payroll_cash as 
select
  p.*,
  case when p.is_finalized = 1 then 'Закрыта' else '' end as finalized,
  d.name as departament,  
  f_fio(e.f, e.i, e.o) as employee,
  o.name as organization,
  a.shortname as prod_area_shortname,
  a.name as prod_area_name,
  d.code,
  a.shortname || ' - ' || decode(d.is_office, 1, 'офис', 'цех') || '' as area
from
  w_payroll_cash p,
  w_departaments d,
  w_employees e,
  ref_sn_organizations o,
  ref_production_areas a 
where
  p.id_employee = e.id (+)
  and p.id_departament = d.id
  and p.id_organization = o.id (+)
  and d.id_prod_area = a.id
;

select * from v_w_payroll_cash;


create table w_payroll_cash_item(
  id number(11),
  id_payroll_cash number(11),     --айди зарплатной ведомости, в которую входит эта строка
  id_employee number(11),         --айди раболтника 
  id_job number(11),              --айди должности 
  id_organization number(11),     --айди организации, в которой числится работник
  personnel_number varchar2(10),  --табельный номер
  pay_cash number,                --итого к выдаче наличными
  banknotes varchar2(400),        --купюры       
  constraint pk_w_payroll_cash_item primary key (id),
  constraint fk_w_payroll_cash_i_own foreign key (id_payroll_cash) references w_payroll_cash(id) on delete cascade,
  constraint fk_w_payroll_cash_i_emp foreign key (id_employee) references w_employees(id),
  constraint fk_w_payroll_cash_i_job foreign key (id_job) references w_jobs(id),
  constraint fk_w_payroll_cash_i_org foreign key (id_organization) references ref_sn_organizations(id)
);  
  
create sequence sq_w_payroll_cash_item start with 100000 nocache;

--create unique index idx_payroll_item_unique on payroll_item(id_division, id_worker, dt);
--create index idx_payroll_item_dt_job on payroll_item(dt, id_job);

create or replace trigger trg_w_payroll_cash_it_bi_r before insert on w_payroll_cash_item for each row
begin
  select nvl(:new.id, sq_w_payroll_cash_item.nextval) into :new.id from dual;
end;

create or replace view v_w_payroll_cash_item as 
select
  i.*,
  p.dt1,
  p.dt2,
  e.name as employee,
  j.name as job,
  o.name as organization,
  0 as changed,
  null as temp
from
  w_payroll_cash_item i,
  w_payroll_cash p,
  v_w_employees e,
  w_jobs j,
  ref_sn_organizations o
where
  i.id_payroll_cash = p.id and
  i.id_employee (+) = e.id and 
  i.id_job = j.id and  
  i.id_organization = o.id (+)
;     

--------------------------------------------------------------------------------
create or replace view v_w_payroll_summary as 
select 
--отчет по зарплатным ведомостям
--нужен только итоговый отчет за конкретный период, по нескольким периодам не нужно
--также выводятся данные только по ведомостям на подразделения, ведомости на отдельных работников не учитываются
  dt1,
  max(dt2) as dt2,
  id_departament,
  max(d.name) as departament,
  max(d.code) as departament_code,
  max(a.shortname) || ' - ' || decode(max(d.is_office), 1, 'офис', 'цех') || '' as area,
 sum(total_pay) as total_pay, sum(deduct_enf) as deduct_enf, sum(deduct_ndfl) as deduct_ndfl, sum(pay_fss) as pay_fss, sum(pay_card) as pay_card, sum(pay_adv) as pay_adv, sum(pay_cash) as pay_cash 
from 
  (select
    pt.dt1,
    pt.dt2,
    id_departament,
    pti.id_employee,
    total_pay, deduct_enf, deduct_ndfl, pay_fss, pay_card, pay_adv, pay_cash
  from  
    w_payroll_transfer pt,
    w_payroll_transfer_item pti,
    (select 
      pc.dt1,
      pci.id_employee as id_employee,
      max(pc.id_departament) as id_departament
    from
      w_payroll_cash_item pci,
      w_payroll_cash pc
    where
      pci.id_payroll_cash = pc.id
    group by
      pc.dt1, pci.id_employee
    ) ed    
  where
    (nvl(get_context('rep_payroll_sum_full'), 0) = 1 or pt.id_employee is null) 
    and pti.id_payroll_transfer = pt.id
    and pti.id_employee = ed.id_employee
    and pt.dt1 = ed.dt1
  ) t,
  w_departaments d,
  ref_production_areas a 
where
  t.id_departament = d.id  
  and d.id_prod_area = a.id
group by
  dt1, id_departament
; 


create or replace view v_w_payrolls_for_employee as
select
 id, 'Расчетная' as type, decode(p.id_employee, null, 'Подразделение', 'Увольнение') as type2, is_finalized, dt1, dt2, finalized, i.id_employee, i.employee from v_w_payroll_calc p, (select id_employee, id_payroll_calc, max(employee) as employee from v_w_payroll_calc_item group by id_payroll_calc, id_employee) i where  i.id_payroll_calc = p.id           
union all
select
 id, 'К перечислению' as type, decode(p.id_employee, null, 'Подразделение', 'Увольнение') as type2, is_finalized, dt1, dt2, finalized, i.id_employee, i.employee from v_w_payroll_transfer p, (select id_employee, id_payroll_transfer, max(employee) as employee from v_w_payroll_transfer_item group by id_payroll_transfer, id_employee) i where  i.id_payroll_transfer = p.id
union all
select
 id, 'К выдаче' as type, decode(p.id_employee, null, 'Подразделение', 'Увольнение') as type2, 1 as is_finalized, dt1, dt2, 'Закрыта' as finalized, i.id_employee, i.employee from v_w_payroll_cash p, (select id_employee, id_payroll_cash, max(employee) as employee from v_w_payroll_cash_item group by id_payroll_cash, id_employee) i where  i.id_payroll_cash = p.id
; 
 


--апдейт промежуточного значения
select nullif(nvl(overtime_pay,0) + nvl(personal_pay,0) + nvl(daily_bonus,0) +nvl(extra_bonus,0) + nvl(night_pay,0) + nvl(milk_compensation,0) + nvl(non_work_pay,0) + nvl(penalty,0) + nvl(correction,0), 0) from w_payroll_calc_item i where i.id_payroll_calc in (select id from w_payroll_calc where dt1 = date '2026-01-01');   

update w_payroll_calc_item i set adjustments_total1 = nullif(nvl(overtime_pay,0) + nvl(personal_pay,0) + nvl(daily_bonus,0) +nvl(extra_bonus,0) + nvl(night_pay,0) + nvl(milk_compensation,0) + nvl(non_work_pay,0) + nvl(penalty,0) + nvl(correction,0), 0) where i.id_payroll_calc in (select id from w_payroll_calc where dt1 = date '2025-01-01');
update w_payroll_calc_item i set adjustments_total1 = (select   












--================================================================================
--alter table ref_production_areas add constraint pk_ref_production_areas primary key (id);


















































/*
оракл. есть таблица w_employee_properties(id, state_type, comm, id_employee, is_hired, is_terminated, dt_beg, id_departament, id_job). создать вью, в котором выводится список уникальных пользователей, а также работает ли работник на текущую дату, когда принят последний раз, и если последним статусом было увольнение то когда уволен последний раз.  статусы работников могут содержать не только события приема и увольнения, но и другие. признаком что это событие приема, является hired=1, иначе hired будет 0, для увольнения аналогично. также нужно вывести комментарий для последнего по id события для данного работника. также вывести дату события, когда для работника последний раз изменились отдел или должность, считать изменением событие последнего приема но не считать событие последнего увольнения
CREATE OR REPLACE VIEW v_employee_status AS
WITH
-- 1. Все уникальные пользователи
all_users AS (
    SELECT DISTINCT id_user FROM employee_state
),
-- 2. Последнее ЗНАЧИМОЕ событие (приём или увольнение) для определения статуса
last_significant_event AS (
    SELECT
        id_user,
        hired,
        fired,
        dt,
        ROW_NUMBER() OVER (PARTITION BY id_user ORDER BY id DESC) AS rn
    FROM employee_state
    WHERE hired = 1 OR fired = 1
),
-- 3. Последняя запись ВООБЩЕ (для получения комментария)
last_any_event AS (
    SELECT
        id_user,
        comm,
        ROW_NUMBER() OVER (PARTITION BY id_user ORDER BY id DESC) AS rn
    FROM employee_state
)
SELECT
    u.id_user,
    -- Статус: работает ли сейчас?
    CASE
        WHEN s.hired = 1 THEN 'Y'
        WHEN s.fired = 1 THEN 'N'
        ELSE 'N' -- если нет значимых событий
    END AS is_working_now,
    -- Дата последнего приёма (только если последнее значимое событие — приём)
    CASE WHEN s.hired = 1 THEN s.dt END AS last_hired,
    -- Дата последнего увольнения (только если последнее значимое событие — увольнение)
    CASE WHEN s.fired = 1 THEN s.dt END AS last_fired,
    -- Комментарий из последней записи ВООБЩЕ
    a.comm AS last_comment
FROM all_users u
LEFT JOIN last_significant_event s ON u.id_user = s.id_user AND s.rn = 1
LEFT JOIN last_any_event a ON u.id_user = a.id_user AND a.rn = 1;
*/



select null as pos1, 0 as pos2, id, id_job, grade, id_schedule, id_departament, id_organization, is_trainee, is_foreman, is_concurrent, personnel_number, name, departament, job, schedulecode from v_w_employee_properties where is_terminated <> 1 and dt_beg <= :dt_end$d and (dt_end is null or (dt_end >= :dt_end2$d and dt_end >= :dt_beg$d)) and id_departament = 5 order by name, dt_beg, job;



select id, id_employee_properties, id_employee, dt, worktime1, worktime2, worktime3, id_turvcode1, id_turvcode2, id_turvcode3, premium, premium_comm, penalty, penalty_comm, production, comm1, comm2, comm3, begtime, endtime, settime3, nighttime from w_turv_day where  id_employee_properties in (979,17) order by dt;



drop index idx_w_turv_day_ep;
create unique index idx_w_turv_day_e on w_turv_day(id_employee, dt);




select 
  d.id, d.id_employee_properties, d.id_employee, d.dt, d.worktime1, d.worktime2, d.worktime3, d.id_turvcode1, d.id_turvcode2, d.id_turvcode3, d.premium, d.premium_comm, d.penalty, d.penalty_comm, d.production, d.comm1, d.comm2, d.comm3, d.begtime, d.endtime, d.settime3, d.nighttime,
  h.hours
from 
  w_employee_properties ep,
  w_turv_day d,
  w_schedule_hours h
where
  ep.id = d.id_employee_properties (+)
  and h.id_schedule = ep.id_schedule
  and d.dt (+) = h.dt
  and h.hours <> null   
;   
  
  
  
  --where dt >= :dtbeg$d and dt <= :dtend$d and id_employee_properties in (' + A.Implode(A.VarDynArray2ColToVD1(FList.V, 0), ',') + ') ' +
  
  delete from w_payroll_calc_item;
  
  
  select id_employee, id_organization, personnel_number, employee, organization, personnel_number, total_pay, null as temp from v_w_payroll_calc_item;-- where id_employee = :p1$i and id_organization = :p2$i and personnel_number = :p3$i and dt1 = :dt1$d and id_target_employee <> null
  
  select * from w_employee_properties where id_organization is null or personnel_number is null;
  
  select max(case when is_terminated = 1 then id_departament else -1 end) as id_dep, id_employee, id_organization, personnel_number from w_employee_properties group by id_employee, id_organization, personnel_number;
  
  




  --c.id_employee, id_organization, personnel_number 
  
select
  p.id 
from 
  w_payroll_calc c,
  v_w_employee_properties p
where
  c.id_employee = p.id_employee 
  and c.id_organization = p.id_organization 
  and c.personnel_number = p.personnel_number
;



select id_employee, id_job, id_schedule, id_organization, personnel_number, monthly_hours_norm, period_hours_norm as period_hours_norm1, employee, organization, job, schedulecode, hours_worked as hours_worked1, overtime as overtime1, ors as ors1, ors_pay as ors_pay1, base_pay as base_pay1, ext_pay as ext_pay1, total_pay as total_pay1, 
personnel_number, monthly_hours_norm, period_hours_norm as period_hours_norm1, employee, organization, job, schedulecode, hours_worked as hours_worked1, overtime as overtime1, ors as ors1, ors_pay as ors_pay1, base_pay as base_pay1, ext_pay as ext_pay1, total_pay as total_pay1, 
nvl(base_pay) + nvl(overtime_pay) + nvl(personal_pay) + nvl(daily_bonus) +nvl(extra_bonus) + nvl(night_pay) + nvl(milk_compensation) + nvl(non_work_pay) + nvl(penalty) + nvl(correction) as adjustments_total1, planned_pay, fixed_pay, 1 as from_first_period from v_w_payroll_calc_item;-- where id_target_departament = :id_target_departament$i and dt1 = :dt1$d order by job, employee, schedulecode, organization, personnel_number   
  

 