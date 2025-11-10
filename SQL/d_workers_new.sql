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

--------------------------------------------------------------------------------

--статусы работников (когда и куда принят/переведен/уволен)
--drop table w_worker_status cascade constraints;
alter table w_employee_properties add is_trainee number(1) default 0;
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
  comm varchar(4000), 
  id_manager number(1),
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

select * from v_w_employees;
   

create or replace view v_w_employee_properties as  
select
  ep.*,
  row_number() over (partition by ep.id_employee order by ep.id) as rn,
  case when is_hired = 1 then 'принят' when is_terminated = 1 then 'уволен' else 'переведен' end as status,
  f_fio(e.f, e.i, e.o) as name,
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
  adm_users u
where
  ep.id_employee = e.id and
  ep.id_departament = d.id (+) and
  ep.id_job = j.id (+) and
  ep.id_organization = o.id (+) and
  ep.id_schedule = s.id (+) and
  ep.id_manager = u.id (+)
;     

delete from w_employee_properties;
insert into w_employee_properties(id, dt, id_employee, id_job, id_departament, is_hired, is_terminated, dt_beg) 
  select id, dt, id_worker, id_job, id_division, decode(status, 1, 1, 0), decode(status ,3 , 1, 0), dt from j_worker_status;



select * from v_turv_workers;

select * from (
select dt1, id_worker, id_schedule_active, row_number() over (partition by id_worker order by id desc) as rn from v_turv_workers) where rn = 1;



--================================================================================
alter table ref_production_areas add constraint pk_ref_production_areas primary key (id);







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




 