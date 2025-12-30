--------------------------------------------------------------------------------
--профессии
alter table w_jobs add has_hazard_comp number(1) default 0;
create table w_jobs(
  id number(11),
  name varchar2(400),
  comm varchar2(400),
  has_hazard_comp number(1) default 0,
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
--alter table w_employees add i varchar2(25) not null; 
create table w_employees(
  id number(11),
  f varchar2(25) not null,
  i varchar2(25) not null,
  o varchar2(25),
  birthday date,
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
drop table w_departments cascade constraints;
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
  constraint fk_w_departaments_head foreign key (id_head) references w_employees(id), 
  constraint fk_w_departaments_area foreign key (id_prod_area) references ref_production_areas(id) 
);

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
  f_fio(e.f, e.i, e.o) as head,
  case when d.is_office = 1 then 'офис' else 'цех' end as office,
  case when d.has_foreman = 1 then 'есть бригадир' else '' end as st_foreman,
  getusernames(d.ids_editusers) as editusernames,
  a.name as area_name,  
  a.shortname as area_shortname  
from
  w_departaments d,
  w_employees e,
  ref_production_areas a
where
  d.id_head = e.id
  and a.id = d.id_prod_area
;     


--------------------------------------------------------------------------------
--справочник персональных надбавок
drop table w_personal_allowances cascade constraints;
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
drop table w_schedules cascade constraints;
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
--drop table w_schedule_templates cascade constraints;
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
--drop table w_schedule_hours cascade constraints;
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


/*

--------------------------------------------------------------------------------
--таблица норма рабочего времени, по графикам и по периодам
drop table w_schedule_hours cascade constraints;
create table w_schedule_hours(
  id number(11),
  id_schedule number(11),      --айди графика работы 
  dt date,                     --дата начала периода
  hours number,                --норма, в часах
  constraint pk_w_schedule_hours primary key (id),
  constraint fk_w_schedule_hours_sсhedule foreign key (id_schedule) references w_schedules(id) 
);  

create unique index idx_w_schedule_hours_uq on w_schedule_hours(id_schedule, dt);

create sequence sq_w_schedule_hours start with 1000 nocache;

create or replace trigger trg_w_schedule_hours_bi_r before insert on w_schedule_hours for each row
begin
  select nvl(:new.id, sq_w_schedule_hours.nextval) into :new.id from dual;
end;
/

create or replace view v_w_schedules as
select
  s.*,
  to_date(to_char(add_months(sysdate, -1), 'yyyy-mm') || '-16', 'yyyy-mm-dd') as dt1,
  h1.hours as hours1,
  to_date(to_char(sysdate, 'yyyy-mm') || '-01', 'yyyy-mm-dd') as dt2,
  h2.hours as hours2,
  to_date(to_char(sysdate, 'yyyy-mm') || '-16', 'yyyy-mm-dd') as dt3,
  h3.hours as hours3,
  to_date(to_char(add_months(sysdate, 1), 'yyyy-mm') || '-01', 'yyyy-mm-dd') as dt4,
  h4.hours as hours4
from  
  w_schedules s,
  w_schedule_hours h1,
  w_schedule_hours h2,
  w_schedule_hours h3,
  w_schedule_hours h4
where  
  h1.id_schedule(+) = s.id and h1.dt(+) = to_date(to_char(add_months(sysdate, -1), 'yyyy-mm') || '-16', 'yyyy-mm-dd')
  and h2.id_schedule(+) = s.id and h2.dt(+) = to_date(to_char(sysdate, 'yyyy-mm') || '-01', 'yyyy-mm-dd')
  and h3.id_schedule(+) = s.id and h3.dt(+) = to_date(to_char(sysdate, 'yyyy-mm') || '-16', 'yyyy-mm-dd')
  and h4.id_schedule(+) = s.id and h4.dt(+) = to_date(to_char(add_months(sysdate, 1), 'yyyy-mm') || '-01', 'yyyy-mm-dd')
;  

--!!!
--insert into w_schedule_hours(id,id_schedule,dt,hours) select id,id_work_schedule,dt,hours from ref_working_hours;
*/
--------------------------------------------------------------------------------

--статусы работников (когда и куда принят/переведен/уволен)
--drop table w_worker_status cascade constraints;
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
  is_concurrent number(1) default 0,        --совместитель (занимает несколько должностей в разных организациях)
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
  e.comm
from w_employees e
left join last_hired h on e.id = h.id_employee and h.rn = 1
left join last_terminated t on e.id = t.id_employee and t.rn = 1
left join first_any_event f on e.id = f.id_employee and f.rn = 1
left join last_any_event a on e.id = a.id_employee and a.rn = 1
left outer join last_transfer lt on e.id = lt.id_employee
left outer join w_departaments d on a.id_departament = d.id and a.rn = 1
left outer join w_jobs j on a.id_job = j.id and a.rn = 1
;


create or replace view v_w_employee_properties as  
select
  ep.*,
  row_number() over (partition by ep.id_employee order by ep.id) as rn,
  case when is_hired = 1 then 'принят' when is_terminated = 1 then 'уволен' else 'переведен' end as status,
  f_fio(e.f, e.i, e.o) as name,
  f_fio(e.f, e.i, e.o) as employee,
  o.name as organization,
  d.name as departament,
  j.name as job,
  s.code as schedulecode,
  decode(ep.is_foreman, 1, 'бригадир', null) as foreman, 
  decode(ep.is_concurrent, 1, 'совместитель', null) as concurrent,
  decode(ep.is_trainee, 1, 'ученик', null) as trainee,
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
/*  
and h.id = s.id
    AND h.dt = (
        CASE
            WHEN EXTRACT(DAY FROM ep.dt) >= 16 THEN
                TRUNC(ep.dt, 'MM') + 15  -- 16-е число текущего месяца
            ELSE
                TRUNC(ep.dt, 'MM')       -- 1-е число текущего месяца
        END
    )
;
*/         
--!
--delete from w_employee_properties;
--insert into w_employee_properties(id, dt, id_employee, id_job, id_departament, is_hired, is_terminated, dt_beg) 
--  select id, dt, id_worker, id_job, id_division, decode(status, 1, 1, 0), decode(status ,3 , 1, 0), dt from j_worker_status;
  
  
--------------------------------------------------------------------------------

--таблица турв по подразделению за период
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
  constraint fk_w_turv_period_dep foreign key (id_departament) references ref_divisions(id)
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

--alter  table _wturv_day add nighttime number(4,2);
--alter  table w_turv_day add constraint  fk_turv_day_turvcode2 foreign key (id_turvcode2) references ref_turvcodes(id);
--таблица турв для конкретного работника за конкретный день
create table w_turv_period(
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
create table w_payroll_calculation_methods(
  id number(11),
  name varchar2(400),
  comm varchar2(4000),
  constraint pk_w_payroll_calculation_mtds primary key (id)
);  

insert into w_payroll_calculation_methods select * from payroll_method;

--------------------------------------------------------------------------------
drop table w_payroll_calculations cascade constraints;
create table w_payroll_calculations ( 
  id number(11),
  id_departament number(11), --айди подразделения
  id_employee number(11),    --айди раболтника 
  id_method number(11),      --метод расчета   
  dt1 date,                  --дата начала ведомости, по полмесяца, как в турв
  dt2 date,                  --дата конца ведомости
  is_finalized number(1),    --период закрыт
  constraint pk_w_payroll_calculations primary key (id),
  constraint fk_w_payroll_calculations_div foreign key (id_departament) references w_departaments(id),
  constraint fk_w_payroll_calculations_emp foreign key (id_employee) references w_employees(id),
  constraint fk_w_payroll_calculations_mtd foreign key (id_method) references w_payroll_calculation_methods(id)
);

--уникальный индекс по подразделению/работнику/дате начала
--create unique index idx_payroll_unique on payroll(id_division, id_worker, dt1);

create sequence sq_w_payroll_calculations start with 1000 nocache;

create or replace trigger trg_w_payroll_calc_bi_r before insert on w_payroll_calculations for each row
begin
  select nvl(:new.id, sq_w_payroll_calculations.nextval) into :new.id from dual;
end;

/*
  id_job number(11),         --айди должности 
  id_shedule number(11),     --айди графика
  is_foreman number(1),      --является бригадиром 
  constraint fk_w_payroll_calculations_job foreign key (id_job) references w_jobs(id),
  constraint fk_w_payroll_calculations_sch foreign key (id_shedule) references w_schedules(id),
  form_number                --номер бланка для печати
*/



--вью для журнала зарплатных ведомостей
create or replace view v_w_payroll_calculations as 
select
  p.*,
  case when p.is_finalized = 1 then 'закрыта' else '' end as finalized,
  f_fio(e.f, e.i, e.o) as employee,
  d.name as departament,
  d.is_office,
  d.code
from
  w_payroll_calculations p,
  w_employees e,
  w_departaments d
where
  p.id_departament = d.id and
  p.id_employee = e.id (+) 
;

/*
назвать поля оклад, плановое начисление зп, постоянная часть зп, стимулирующая часть заработной платы, итого начислено за период, надбавка за работу бригадиром, суммарная ежедневная премия, дополнительная премия, надбавка за вредность на покупку молока, ручная корректировка зарплаты, депремирование, начисление за отпуск, начисление за больничный, итого начислено
*/


--данные зарплатной ведомости для конкретного работника из ведомости
drop table w_payroll_calculations_item cascade constraints;
create table w_payroll_calculations_item(
  id number(11),
  id_payroll_calculation number(11), --айди зарплатной ведомости, в которую входит эта строка
  dt date,
  id_departament number(11), --айди подразделения
  id_employee number(11),    --айди раболтника 
  id_job number(11),         --айди должности 
  id_schedule number(11),    --айди графика
  is_foreman number(1),
  days_worked number,
  hours_worked number,
  monthly_work_hours_norm number,
  period_work_hours_norm number,
  base_salary number,
  planned_monthly_payroll number,
  fixed_compensation number,
  variable_compensation number,
  performance_coefficient number,
  performance_bonus number,
  core_earnings number,  --Начислено за период  (либо по окладной части, либо на основе выработки
/*  
  blank number(7),                --номер бланка для печати
  ball_m number(7),               --баллы за месяц (точнее, отчтетный период, полмесяца)
  turv number,                    --итоговое время из турв
  ball number(7),                 --баллы расчетные
  norm number(7),                 --норма в часах для текущего периода     
  norm_m number(7),               --норма в часах за данный календарный месяц 
  premium_m_src number(7),        --премия за отчетный период, взятая из ТУРВ
  premium_m number(7),            --премия за отчетный период, вычисляется по формуле или вводится вручную в зарплатной ведомости
  premium number(7),              --премия, сумма дневных премий из турв
  premium_p number(7),            --премия, за переработку, по формуле
  otpusk number(7),               --отпуск
  bl number(7),                   --больничные
  penalty number(7),              --штрафы, из турв
  itog1 number(7),                --итого начислено
  ud number(7),                   --удержано
  ndfl number(7),                 --ндфл 
  fss number(7),                  --фсс
  pvkarta number(7),              --промежуточные выплаты/карта
  karta number(7),                --карта
  banknotes varchar2(40),         --расклад по купюрам
  itog number(7),                 --итого к выдаче
  ---
  salary_plan_m number,           --плановое начисление, месяц
  salary_const_m number,          --постоянная часть, месяц
  salary_incentive_m number,      --стимулирующая часть з/п
  ors number,                     --оценка оработы сотрудника, в % (120.5)
  ors_sum number,
  
*/ 
  foreman_allowance number,       --брмигадирские
  hazard_pay number,              --доплата за вредность 
  daily_premium_total number,     --сумма дневных премий за период  
  holiday_work_premium number,    --доплата за работу в выходные и праздничные дни
  additional_premium number,      --премия, вручную выставляемая в расчетных ведомостях
  vacation_pay number,            --оплата отпуска
  sick_leave_pay number,          --оплата болльничных 
  gross_pay number,               --итого начислено до удержаний
  total_accrued number,
  blank number,

  
  constraint pk_w_payroll_calc_item primary key (id),
  constraint fk_w_payroll_calc_i_own foreign key (id_payroll_calculation) references w_payroll_calculations(id) on delete cascade,
  constraint fk_w_payroll_calc_i_emp foreign key (id_employee) references w_employees(id),
  constraint fk_w_payroll_calc_i_job foreign key (id_job) references w_jobs(id),
  constraint fk_w_payroll_calc_i_sch foreign key (id_schedule) references w_schedules(id)
);  
  
create sequence sq_w_payroll_calculations_item start with 100000 nocache;

create unique index idx_payroll_item_unique on payroll_item(id_division, id_worker, dt);
create index idx_payroll_item_dt_job on payroll_item(dt, id_job);

create or replace trigger trg_w_payroll_calc_item_bi_r before insert on w_payroll_calculations_item for each row
begin
  select nvl(:new.id, sq_w_payroll_calculations_item.nextval) into :new.id from dual;
end;
   

--вью для элемента (записи по работнику в данном подразделении) зарплатных ведомостей
create or replace view v_w_payroll_calculations_item as 
select
  i.*,
  s.code,
  s.code || ' (' || to_char(i.period_work_hours_norm) || ')' as schedule,
  p.id_employee as id_target_employee,
  p.dt1,
  p.dt2 as dt2,
  f_fio(w.f, w.i, w.o) as employee,
  --w.personnel_number,
  --w.concurrent_employee,
  --o.name as org_name,
  d.name as departament,
  d.id_prod_area,
  a.shortname as prod_area_shortname,
  a.name as prod_area_name,
  j.name as job,
  p.id_method as id_method
from
  w_payroll_calculations_item i,
  w_payroll_calculations p,
  w_employees w,
  w_departaments d,
  w_jobs j,
  w_payroll_calculation_methods m,
  w_schedules s,
  --ref_sn_organizations o,
  ref_production_areas a
where
  i.id_payroll_calculation = p.id and
  i.id_departament = d.id and
  i.id_employee = w.id and 
  i.id_job = j.id and
  p.id_method = m.id (+) and
  i.id_schedule = s.id (+) and
  --o.id (+) = w.id_organization and
  a.id (+) = d.id_prod_area
;     




































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
  id, id_employee_properties, id_employee, dt, worktime1, worktime2, worktime3, id_turvcode1, id_turvcode2, id_turvcode3, premium, premium_comm, penalty, penalty_comm, production, comm1, comm2, comm3, begtime, endtime, settime3, nighttime
from 
  w_employee_properties ep,
  w_turv_day d
  w_schedule_hours h
where
  ep.id = d.id_employee_properties
  and  
;   
  
  
  
  
  --where dt >= :dtbeg$d and dt <= :dtend$d and id_employee_properties in (' + A.Implode(A.VarDynArray2ColToVD1(FList.V, 0), ',') + ') ' +






 