--------------------------------------------------------------------------------
--профессии
drop table w_jobs cascade constraints;
create table w_jobs(
  id number(11),
  name varchar2(400),
  comm varchar2(400),
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
insert into w_jobs (id, name, active) select id,name,active from ref_jobs;

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
insert into w_turvcodes (id, code, name, active) select id,code, name, 1 from ref_turvcodes;


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
insert into w_employees(id,f,i,o) select id, f,i,o from ref_workers;

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
delete from w_departaments;
insert into w_departaments (id,code,name,id_head,id_prod_area,is_office,ids_editusers,active) select id,code,name,id_head,id_prod_area,office,editusers,active from ref_divisions; 

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
--таблица графиков работы
drop table w_schedules cascade constraints;
create table w_schedules(
  id number(11),
  code varchar2(50),
  name varchar2(400),
  comm varchar2(400),
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

--------------------------------------------------------------------------------
--таблица норма рабочего времени, по графикам и по периодам
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
insert into w_schedule_hours(id,id_schedule,dt,hours) select id,id_work_schedule,dt,hours from ref_working_hours;










--статусы работников (когда и куда принят/переведен/уволен)
create table w_worker_status(
  id number(11),
  dt date,
  dt_beg date,
  dt_end date,  
  hired number(1) default 0,
  fired number(1) default 0,
  id_worker number(11),
  id_organization,
  id_division number(11),
  id_job number(11),
  id_schedule number(11),
  is_foreman number(1) default 0,
  is_concurrent number(1) default 0,
  --status number(1),             
  comm varchar(4000), 
  id_manager number(1),
  deleted number(1) default 0,
  constraint pk_w_worker_status primary key (id),
  constraint fk_w_worker_status_worker foreign key (id_worker) references ref_workers,
  constraint fk_w_wworker_status_div foreign key (id_division) references ref_divisions(id), 
  constraint fk_w_worker_status_job foreign key (id_job) references ref_jobs(id), 
  constraint fk_w_worker_status_manager foreign key (id_manager) references adm_users(id),
  constraint fk_w_worker_status_schedule foreign key (id_schedule) references ref_work_schedules(id)
);

create sequence sq_w_worker_status start with 100000 nocache;

create index idx_w_worker_status_div on w_worker_status(id_division); 
create index idx_w_worker_status_job on w_worker_status(id_job); 
create index idx_w_worker_status_worker on w_worker_status(id_worker); 

create or replace trigger trg_w_worker_status_bi_r before insert on w_worker_status for each row
begin
  if :new.id is null then
    select sq_w_worker_status.nextval into :new.id from dual;
   end if;
end;
/

--create or replace view V_EMPLOYEE_STATUS as
select
    id_worker,
    case
        when last_hired_id > nvl(last_fired_id, 0) then 'y'
        else 'n'
    end as is_working_now,
    last_hired,
    last_fired
from (
    select
        id_worker,
        max(case when hired = 1 then hired end)
            keep (dense_rank last order by case when hired = 1 then id end) as last_hired,
        max(case when fired = 1 then fired end)
            keep (dense_rank last order by case when fired = 1 then id end) as last_fired,
        max(case when hired = 1 then id end) as last_hired_id,
        max(case when fired = 1 then id end) as last_fired_id
    from w_worker_status
    group by id_worker
);

--create or replace view v_w_worker_status as  
select
  w.id as id_w,
  s.*,
  row_number() over (partition by s.id_worker order by s.id) as worker_row,
  w.f || ' ' || w.i  || ' ' || w.o as workername,
  w.personnel_number,
  o.name as orgname,
  d.name as divisionname,
  d.editusers as editusers,
  j.name as job,
  case
      when lag(s.id_job) over (partition by id_worker order by s.id) is null then 'y'
      when lag(s.id_job) over (partition by id_worker order by s.id) <> s.id_job then 'y'
      else 'n'
  end as job_ch,  
  sh.code as shedulecode
from
  ref_workers w,
  w_worker_status s,
  ref_divisions d,
  ref_jobs j,
  ref_sn_organizations o,
  ref_work_schedules sh
where
  s.id_worker (+) = w.id and
  s.id_division = d.id (+) and
  s.id_job = j.id (+) and
  o.id (+) = w.id_organization and
  sh.id (+) = s.id_schedule
;     

insert into w_worker_status(id, id_worker, id_job, id_division, hired, fired, dt_beg) 
  select id, id_worker, id_job, id_division, decode(status, 1, 1, 0), decode(status ,1 , 1, 0), dt from j_worker_status;





--================================================================================
alter table ref_production_areas add constraint pk_ref_production_areas primary key (id);







/*
оракл. есть таблица employee_state(id, state_type, comm, id_user, hired, fired, dt). создать вью, в котором выводится список уникальных пользователей, а также работает ли работник на текущую дату, когда принят последний раз, и если последним статусом было увольнение то когда уволен последний раз.  статусы работников могут содержать не только события приема и увольнения, но и другие. признаком что это событие приема, является hired=1, иначе hired будет 0, для увольнения аналогично. также нужно вывести комментарий для последнего по id события для данного работника

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


 