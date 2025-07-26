_--------------------------------------------------------------------------------
-- ���� ------------------------------------------------------------------------
--------------------------------------------------------------------------------

alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';

--������������ ������
--alter  table workers_cfg add time_beg_diff_2 number(4,2);
alter  table workers_cfg add path_to_payrolls varchar(4000); 
create table workers_cfg (
  time_autoagreed number(4,2),  --����� � �����, ���� ����������� ������ � ������������ �� ��� �������� ��� ������, �� ������������ ����� ������ ��� �������������
  time_dinner_1 number(4,2),     --����� � ����� �� ����, ��� �����
  time_dinner_2 number(4,2),     --����� � ����� �� ����, ��� ����
  time_beg_2 number(4,2),       --����� ������ ������ ��� ����, ��.��, � ���� �� ���� ��� �������� �� ������ �� ����������� ������ ������ ����� ������� ��� �������� ��������� 
  time_beg_diff_2 number(4,2),     --����� � ����, ���� �� ���� ���������� ��� ����� ������ ������ ��� time_beg_2, �� ��������� �� ������� �������
  path_to_payrolls varchar(4000)  -- ���� � ������ ������� ��������

);  

--���������������� ���������
--drop table ref_holidays;
create table ref_holidays(
  dt date,             
  type number(1),          --1-��������, 2-�����������, 3-�������
  descr varchar(200),      --�������� ���������
  constraint pk_ref_holideys primary key (dt)
);

create or replace view v_ref_holidays as select
  h.*,
  decode(h.type, 1, '�', 2, '�', 3, '�') as typetxt
from
  ref_holidays h
;    

select dt as id, dt, typetxt, descr from v_ref_holidays where Year(dt) = 2023;


--���������
--alter table ref_workers add id_organization number(11);
--alter table ref_workers add constraint fk_ref_workers_org foreign key (id_organization) references ref_sn_organizations(id);
create table ref_workers(
  id number(11),
  f varchar2(25),
  i varchar2(25),
  o varchar2(25),
  id_schedule number(11),
  personnel_number varchar2(10),
  id_organization number(11),
  active number(1),
  constraint pk_ref_workers primary key (id),
  constraint fk_ref_workers_schedule foreign key (id_schedule) references ref_work_schedules(id), 
  constraint fk_ref_workers_org foreign key (id_organization) references ref_sn_organizations(id) 
);

create unique index idx_ref_workers on ref_workers(lower(f),lower(i),lower(o)); 

--������������ �� ������������ � ���������� ������, ���� ��� �������� ������
create unique index idx_ref_workers_number on ref_workers (
    case 
        when personnel_number is not null and id_organization is not null 
        then id_organization || '|' || personnel_number 
        else null 
    end
);

create sequence sq_ref_workers start with 1 nocache;


create or replace view v_ref_workers as
select
  w.*,
  w.f || ' ' || w.i  || ' ' || w.o as workername,
  d.name as divisionname,
  j.name as job,
  o.name as orgname,
  (case 
    when s.status = 1 then '������'
    when s.status = 2 then '���������'
    when s.status = 3 then '������'
    else ''
   end) as statusname,
   s.dt as dt 
from
  ref_workers w,
  (select max(id) as id, id_worker from j_worker_status group by id_worker) sm,
  j_worker_status s,
  ref_divisions d,
  ref_jobs j,
  ref_sn_organizations o
where
  sm.id_worker (+) = w.id and
  s.id (+) = sm.id and
  s.id_division = d.id (+) and
  s.id_job = j.id (+) and
  o.id (+) = w.id_organization
;     

select * from v_ref_workers order by workername;



--���������
create table ref_jobs(
  id number(11),
  name varchar2(400),
  constraint pk_ref_jobs primary key (id)
);

create unique index idx_ref_jobs on ref_jobs(lower(name)); 

create sequence sq_ref_jobs start with 1 nocache;

--����������� � ����
create table ref_turvcodes(
  id number(11),
  code varchar2(25),
  name varchar2(400),
  constraint pk_ref_turvcodes primary key (id)
);

create unique index idx_ref_turvcodes on ref_turvcodes(lower(code)); 

create sequence sq_ref_turvcodes start with 1 nocache;

/*
--������ ������� �/� - �� ����������
create table ref_payroll_methods(
  id number(11),
  name varchar2(400),
  comm varchar2(400),
  method clob,
  constraint pk_ref_payroll_methods primary key (id)
);

create unique index idx_ref_payroll_methods on ref_turvcodes(lower(name)); 

create sequence sq_ref_payroll_methods start with 1 nocache;
*/


--�������������
--alter table ref_divisions add id_prod_area number(11);
--alter table ref_divisions add constraint fk_ref_divisions_area foreign key (id_prod_area) references ref_production_areas(id);
--update ref_divisions set id_prod_area = 0;
create table ref_divisions(
  id number(11),
  code varchar(5),
  id_head number(11),
  id_schedule number(11),
  id_prod_area number(11),
  office number(1),
  name varchar2(400),
  editusers varchar2(4000),
  active number(1),
  constraint pk_ref_divisions primary key (id),
  constraint fk_ref_divisions_head foreign key (id_head) references ref_workers(id), 
  constraint fk_ref_divisions_schedule foreign key (id_schedule) references ref_work_schedules(id),
  constraint fk_ref_divisions_area foreign key (id_prod_area) references ref_production_areas(id) 
);


create unique index idx_ref_divisions on ref_divisions(lower(name)); 
create unique index idx_ref_divisions_code on ref_divisions(lower(code)); 

create sequence sq_ref_divisions start with 1 nocache;

create or replace view v_ref_divisions as  
select
  d.*,
  w.f || ' ' || w.i  || ' ' || w.o as head,
  case when d.office = 1 then '����' else '���' end as isoffice,
  getusernames(d.editusers) as editusernames,
  s.code as schedule_code,
  a.name as area_name,  
  a.shortname as area_shortname  
from
  ref_divisions d,
  ref_workers w,
  ref_work_schedules s,
  ref_production_areas a
where
  d.id_head = w.id
  and s.id = d.id_schedule
  and a.id = d.id_prod_area
;     





--������� ���������� (����� � ���� ������/���������/������)
create table j_worker_status(
  id number(11),
  id_division number(11),
  id_job number(11),
  id_worker number(11),
  dt date,
  status number(1),             --1=������, 2=���������, 3=������
  comm varchar(100), 
  constraint pk_j_worker_status primary key (id),
  constraint fk_j_worker_status_div foreign key (id_division) references ref_divisions(id), 
  constraint fk_j_worker_status_job foreign key (id_job) references ref_jobs(id), 
  constraint fk_j_worker_status_worker foreign key (id_worker) references ref_workers
);

create sequence sq_j_worker_status start with 1 nocache;

create index idx_j_worker_status_div on j_worker_status(id_division); 
create index idx_j_worker_status_job on j_worker_status(id_job); 
create index idx_j_worker_status_worker on j_worker_status(id_worker); 

create or replace view v_j_worker_status as  
select
  s.*,
  w.f || ' ' || w.i  || ' ' || w.o as workername,
  w.id_schedule,            --������ ������ ������ ���������, � �� ��� ������� �������!!!
  w.personnel_number,
  o.name as orgname,
  d.name as divisionname,
  d.editusers as editusers,
  j.name as job,
  (case 
    when s.status = 1 then '������'
    when s.status = 2 then '���������'
    when s.status = 3 then '������'
    else ''
   end) as statusname
from
  j_worker_status s,
  ref_workers w,
  ref_divisions d,
  ref_jobs j,
  ref_sn_organizations o
where
  s.id_worker = w.id (+) and
  s.id_division = d.id (+) and
  s.id_job = j.id (+) and
  o.id = w.id_organization
;     


--------------------------------------------------------------------------------

--alter  table turv_day add nighttime number(4,2);
--alter  table turv_day add constraint  fk_turv_day_turvcode2 foreign key (id_turvcode2) references ref_turvcodes(id);
--alter  table turv_day add constraint fk_turv_day_turv_worker foreign key (id_turv_worker) references turv_worker(id) on delete cascade;
--������� ���� ��� ����������� ��������� �� ���������� ����
create table turv_day(
  id_turv_worker number(11),        --���� ������ ���� �� ���������
  id_worker number(11),             --
  id_division number(11),           --
  dt1 date,                         --���� ������ ������� ���� 
  dt date,                          --���� ���� (����)
  id_turvcode1 number(11),          --��� ���� �� ��������
  worktime1 number(4,2),            --����� ������ �� �������� 
  comm1 varchar2(400),              --���������� ������������ 
  id_turvcode2 number(11),          --��� ���� �� �������
  worktime2 number(4,2),            --����� ������ �� �������
  comm2 varchar2(400),              --���������� �� 
  id_turvcode3 number(11),          --��� ������������� 
  worktime3 number(4,2),            --����� ������ ������������� 
  comm3 varchar2(400),              --���������� �� ��������������  
  premium number(5),                --����� ������ �� ����
  premium_comm varchar2(400),       --���������� � ������ 
  penalty number(5),                --����� ������
  penalty_comm varchar2(400),       --���������� � ������ 
  production number(1),             --��������� (�����, ���)
  begtime number(4,2),              --����� ������� �� �������  
  endtime number(4,2),              --����� ����� �� �������
  nighttime number(4,2),            --����� ������ � ������ �����
  settime3 number(1),               --1, ����� ����� �� ������� worktime2 ����������� 
  constraint pk_turv_day primary key (id_worker, dt),
  constraint fk_turv_day_turv_worker foreign key (id_turv_worker) references turv_worker(id) on delete cascade,
  constraint fk_turv_day_worker foreign key (id_worker) references ref_workers(id), 
  constraint fk_turv_day_div foreign key (id_division) references ref_divisions(id),
  constraint fk_turv_day_turvcode1 foreign key (id_turvcode1) references ref_turvcodes(id),
  constraint fk_turv_day_turvcode2 foreign key (id_turvcode2) references ref_turvcodes(id),
  constraint fk_turv_day_turvcode3 foreign key (id_turvcode3) references ref_turvcodes(id)
);



create table turv_day_copy as select * from turv_day;
create table turv_day_copy2 as select * from turv_day;

--������� ���� ��� ����������� ��������� � ���������� ���� ������ �� ������
--(��������� �� ���������, ������, ��������� � ���� ������ ����)
--drop table turv_worker cascade constraints;
alter table turv_worker add dt2 date;
create table turv_worker(
  id number(11),                   
  id_turv number(11),                   
  id_worker number(11),             --���� ���������
  id_division number(11),           --���� �������������
  id_job number(11),                --���� ���������
  id_schedule number(11),            
  dt1 date,                         --���� ������ ������� ���� 
  dt2 date,                         --���� ����� ������� ���� 
  dt1p date,                        --���� ������ ������ �� ����� ��������� � ���� 
  dt2p date,                        --���� ����� ������ �� ����� ��������� � ���� 
  premium number(9),                --����� ������ �� �������� �������
  comm varchar2(400),               --���������� � ��������� 
  constraint pk_turv_worker primary key (id),
  constraint fk_turv_worker_turv foreign key (id_turv) references turv_period (id) on delete cascade,
  constraint fk_turv_worker_worker foreign key (id_worker) references ref_workers(id), 
  constraint fk_turv_worker_div foreign key (id_division) references ref_divisions(id),
  constraint fk_turv_worker_job foreign key (id_job) references ref_jobs(id),
  constraint fk_turv_worker_schedule foreign key (id_schedule) references ref_work_schedules(id)
);  

create unique index idx_turv_worker_1 on turv_worker (id_worker, id_division, id_job, dt1, dt1p);
create unique index idx_turv_worker_2 on turv_worker (id_worker, dt1p);
create index idx_turv_worker_dt1 on turv_worker (dt1);
create index idx_turv_worker_dt1p on turv_worker (dt1p);

create sequence sq_turv_worker start with 10000 nocache;

--������ ������ � ������������ ����������� �� ���������� ��� ����
create or replace view v_turv_workers as 
select 
  tw.*,
  rd.name as divisionname,
  rd.office,
  F_FIO(rw.f, rw.i, rw.o) as workername,
  rj.name as job,
  decode(tw.id_schedule, null, 0, 1) as worker_has_schedule,
  decode(tw.id_schedule, null, s2.code, s1.code) as schedule,
  decode(tw.id_schedule, null, s2.id, s1.id) as id_schedule_active
from
  turv_worker tw,
  ref_workers rw,
  ref_divisions rd,
  ref_jobs rj,
  turv_period tp,
  ref_work_schedules s1,  
  ref_work_schedules s2  
where
  rw.id = tw.id_worker and
  rj.id = tw.id_job and
  rd.id = tw.id_division and
  tw.id_turv = tp.id and
  s1.id (+) = nvl(tw.id_schedule,0) and    
  s2.id (+) = tp.id_schedule     
; 

select * from v_turv_workers where id_division = 1;


--��� �� ����� ������ ����
--���������� ����� ����� ������� �������� �������� � �������, ��� ��� ��� ���� ��� ����� ����� � ������,
--� ����� ���������� �������� � ���� ����������, ���� ���� ������������� �� ���, ����� ������, ����� �� ��������  
create or replace view v_turv_day as
select
  td.*,
  c1.name as cname1,
  c1.code as ccode1, 
  c2.name as cname2,
  c2.code as ccode2, 
  c3.name as cname3,
  c3.code as ccode3,
  (case 
    when c1.code is not null then c1.code  
    when td.worktime1 is not null then to_char(td.worktime1)
  end) as t1,
  (case 
    when c2.code is not null then c2.code  
    when td.worktime2 is not null then to_char(td.worktime2)
  end) as t2,
  (case 
    when c3.code is not null then c3.code  
    when td.worktime3 is not null then to_char(td.worktime3)
  end) as t3,  
  (case 
    when c3.code is not null then c3.code  
    when td.worktime3 is not null then to_char(td.worktime3)
    when c2.code is not null then c2.code  
    when td.worktime2 is not null then to_char(td.worktime2)
    when c1.code is not null then c1.code  
    when td.worktime1 is not null then to_char(td.worktime1)
  end) as t  
from
  turv_day td,
  ref_turvcodes c1,
  ref_turvcodes c2,
  ref_turvcodes c3
where
  td.id_turvcode1 = c1.id (+) and  
  td.id_turvcode2 = c2.id (+) and  
  td.id_turvcode3 = c3.id (+) 
; 

select sum(nvl(worktime1, 0)) from turv_day;  --81768
select count(*) from turv_day;  --17862  19431

--update turv_worker set id_worker = id_worker; 




select count(*) from v_turv_day where id_division >= 1 and t is null;
select * from turv_day where id_division >= 1 and worktime1 is null;

--��� ���������� ������ ������ ����
create or replace view v_turv_worker_1 as 
select 
  vd.*,
  rd.name as divisionname,
  F_FIO(rw.f, rw.i, rw.o) as workername,
  rj.name as job,
  td.dt - td.dt1 + 1 as dayno,
  tw.commit as commit
from
  turv_worker tw,
  turv_day td,
  v_turv_day vd,
  ref_workers rw,
  ref_divisions rd,
  ref_jobs rj
where
  td.id_turv_worker = tw.id and
  vd.id_worker = td.id_worker and vd.dt = td.dt and
  rw.id = tw.id_worker and
  rj.id = tw.id_job and
  rd.id = tw.id_division   
; 

select * from v_turv_worker_1 where id_division = 1;


create or replace view v_turv_worker_16 as 
select 
  tw.*,
  rd.name as divisionname,
  F_FIO(rw.f, rw.i, rw.o) as workername,
  rj.name as job,
  d1.t as t1, d1.t1 as t1_1, d1.t2 as t1_2, d1.t3 as t1_3,
  d2.t as t2, d2.t1 as t2_1, d2.t2 as t2_2, d2.t3 as t2_3,
  d3.t as t3, d3.t1 as t3_1, d3.t2 as t3_2, d3.t3 as t3_3
from
  turv_worker tw,
  ref_workers rw,
  ref_divisions rd,
  ref_jobs rj,
  v_turv_day d1,
  v_turv_day d2,
  v_turv_day d3
where  
  rw.id = tw.id_worker and
  rj.id = tw.id_job and
  rd.id = tw.id_division and   
  d1.id_worker = tw.id_worker and d1.dt1 = tw.dt1 and d1.dt - tw.dt1 = 0 and
  d2.id_worker = tw.id_worker and d2.dt1 = tw.dt1 and d2.dt - tw.dt1 = 1 and
  d3.id_worker = tw.id_worker and d3.dt1 = tw.dt1 and d3.dt - tw.dt1 = 2
;  
  
select * from v_turv_worker_16 where id_division = 1 and dt1 = '16.02.2023';
select * from v_turv_worker_16 where t1 is null;;
select * from v_turv_day where id_division = 1 and dt1 = '16.02.2023';



--update turv_worker set id = rownum;

create or replace trigger trg_turv_worker_bi_r
  before
  insert
  on turv_worker
  for each row
begin
  select sq_turv_worker.nextval into :new.id from dual;
end;
/

create or replace trigger trg_turv_worker_ai_r
  after
  insert
  on turv_worker
  for each row
declare
  ag varchar(100);
  an varchar(100);
  sql1 varchar(1000);
  d integer;
  d1 integer;
  d2 integer;
  dt date;
begin 
  --������� � ���� ������ �� ����, ��� ������ ���� ������� ��� ����� ���������
  d1 := extract(day from :new.dt1p); 
  d2 := extract(day from :new.dt2p);
  for d in d1 .. d2 
    loop
     dt := to_date(d || '.' || extract(month from :new.dt1p) || '.' || extract(year from :new.dt1p), 'DD.MM.YYYY'); 
     sql1:='insert into turv_day (id_turv_worker, id_worker, id_division, dt1, dt) values (:id_turv_worker, :id_worker, :id_division, :dt1, :dt)';
     execute immediate sql1 using :new.id, :new.id_worker, :new.id_division, :new.dt1, dt;
   end loop;   
end;
/

create or replace trigger trg_turv_worker_au_r
  after
  update
  on turv_worker
  for each row
declare
  ag varchar(100);
  an varchar(100);
  sql1 varchar(1000);
  d integer;
  d1 integer;
  d2 integer;
  dtv date;
  i integer;
begin 
  --������� � ���� ������ �� ���� �� ������, ������� ��� ���, � ������ �� ��� ��������� ����� ��������� �� ��������� ���������
  d1 := extract(day from :new.dt1p); 
  d2 := extract(day from :new.dt2p); 
  for d in d1 .. d2 
    loop
      dtv := to_date(d || '.' || extract(month from :new.dt1p) || '.' || extract(year from :new.dt1p), 'DD.MM.YYYY');
      select count(1) into i from turv_day where id_turv_worker = :new.id and dt = dtv;
      if i = 0 then
        sql1:='insert into turv_day (id_turv_worker, id_worker, id_division, dt1, dt) values (:id_turv_worker, :id_worker, :id_division, :dt1, :dt)';
        execute immediate sql1 using :new.id, :new.id_worker, :new.id_division, :new.dt1, dtv;
      end if;
    end loop;    
  for cur in (select dt from turv_day where id_turv_worker = :new.id)  
    loop
      if (cur.dt < :new.dt1p) or (cur.dt > :new.dt2p) then 
       sql1:='delete from turv_day where id_turv_worker = :id and dt = :dt';
        execute immediate sql1 using :new.id, cur.dt;
      end if;
   end loop;   
end;
/

insert into turv_worker (id_turv, id_worker, id_division, id_job, dt1, dt2, dt1p, dt2p) values (1, 1, 1, 1, '01.08.2023', '15.08.2023', '02.08.2023', '10.08.2023');
update turv_worker set dt1p = '02.08.2023', dt2p = '07.08.2023';
delete from turv_worker;  

insert into turv_day1 (id_turv_worker, dt) values (10007, '02.08.2023');
delete from turv_day1;


--create table turv_worker1 as select * from turv_worker;

--drop  table turv_day1 cascade constraints;
create table turv_day1(
  id_turv_worker number(11),        --
  id_worker number(11),             --
  id_division number(11),           --
  dt date,                          --���� ���� (����)
  dt1 date,                          --���� ���� (����)
  constraint pk_turv_day1 primary key (id_turv_worker, dt),
  constraint fk_turv_day1_turv_worker foreign key (id_turv_worker) references turv_worker(id) on delete cascade, 
  constraint fk_turv_day1_worker foreign key (id_worker) references ref_workers(id), 
  constraint fk_turv_day1_div foreign key (id_division) references ref_divisions(id)
);  


select extract(day from sysdate) from dual;








--������� ���� �� ������������� �� ������
--������ �� ���������� ����� �� ��������� � ��, ���������� ������ ��� � ��������� �� ������ ������� ������� �������� ����������
alter table turv_period add id number(11);
alter table turv_period  drop constraint pk_turv_period; 
alter table turv_period  add constraint pk_turv_period  primary key (id); 
create table turv_period(  
  id number(11),                   
  id_division number(11),           --�������������
  id_schedule number(11),
  dt1 date,                         --���� ������ ������� ����
  dt2 date,                         --���� ����� ������� ����
  commit number(1),                 --������ ������
  status number(1),                 --������ ������������ ������
  constraint pk_turv_period  primary key (id),
  constraint fk_turv_period_div foreign key (id_division) references ref_divisions(id),
  constraint fk_turv_period_schedule foreign key (id_schedule) references ref_work_schedules(id)
);

create unique index idx_turv_period_1 on turv_period(id_division, dt1);

create sequence sq_turv_period start with 1000 nocache;

create or replace trigger trg_turv_period_bi_r
before insert
on turv_period
for each row
begin
  select sq_turv_period.nextval into :new.id from dual;
end;
 
   
--update turv_period p1 set id = rownum;


 --order by id_division, dt1 

create or replace view v_turv_period as  
select
 -- to_char(p.id_division) || ' ' || to_char(p.dt1, 'YYYYMMDD') || ' ' || to_char(p.dt2, 'YYYYMMDD') as id,
  p.*,
  d.name,
  case when d.office = 1 then '����' else '���' end as isoffice,
  case when p.commit = 1 then '������' else '' end as committxt,
  getusernames(d.editusers) as editusernames,
  d.editusers,
  d.code 
from
  turv_period p,
  ref_divisions d
where
  d.id = p.id_division
;     
   
select id, name, dt1, dt2, committxt from v_turv_period;


--------------------------------------------------------------------------------
---  �������� ------------------------------------------------------------------
--------------------------------------------------------------------------------

--������ ������� �/�
--���� ������������ ������ ��������� ����
create table payroll_method(
  id number(11),
  name varchar2(400),
  comm varchar2(4000),
  constraint pk_payroll_method primary key (id)
);  

--����� ������� (����� ����� �� ������) �� ������ �������� ������ � �����, �������� ��� ���� � �����
--drop table payroll_norm cascade constraints;  //!!! �������
create table payroll_norm(
  dt date,
  norm0 number(7,2),          --����� ������� ��� 
  norm1 number(7,2),          --����� ������� ����
  constraint pk_payroll_norm primary key (dt)
);  

--���������� ���������
--����� ���� �� ������ �������������, ����� id_worker = null, ��� �� ������ ���������
--alter table payroll add commit number(1);
--alter table payroll add constraint fk_payroll_method foreign key (id_method) references payroll_method(id);
--alter table payroll drop column id_calcmode;
create table payroll(
  id number(11),
  id_division number(11),    --���� �������������
  id_worker number(11),      --���� ���������� 
  dt1 date,                  --���� ������ ���������, �� ���������, ��� � ����
  dt2 date,                  --���� ����� ���������
  id_method number(11),      --����� �������   
  commit number(1),                 --������ ������
  constraint pk_payroll primary key (id),
  constraint fk_payroll_div foreign key (id_division) references ref_divisions(id),
  constraint fk_payroll_worker foreign key (id_worker) references ref_workers(id),
  constraint fk_payroll_method foreign key (id_method) references payroll_method(id)
);

--���������� ������ �� �������������/���������/���� ������
create unique index idx_payroll_unique on payroll(id_division, id_worker, dt1);

create sequence sq_payroll start with 100 nocache;

--insert into payroll (id, id_division) values (1, 1);
 

--��� ��� ������� ���������� ����������
create or replace view v_payroll as 
select
  p.*,
  case when p.commit = 1 then '�������' else '' end as committxt,
  trim(w.f || ' ' || w.i  || ' ' || w.o) as workername,
  d.name as divisionname,
  d.office,
  d.code
from
  payroll p,
  ref_workers w,
  ref_divisions d
where
  p.id_division = d.id and
  p.id_worker = w.id (+) 
;

    
--������ ���������� ��������� ��� ����������� ��������� �� ���������
create table payroll_item(
  id number(11),
  id_payroll number(11),          --���� ���������� ���������, � ������� ������ ��� ������
  dt date,
  id_division number(11),         --���� �������������
  id_worker number(11),           --���� ���������
  id_schedule number(11),         --������ ������
  id_job number(11),              --����              
  blank number(7),                --����� ������ ��� ������
  ball_m number(7),               --����� �� ����� (������, ��������� ������, ���������)
  turv number(7),                 --�������� ����� �� ����
  ball number(7),                 --����� ���������
  norm number(7),                 --����� � ����� ��� �������� �������     
  norm_m number(7),               --����� � ����� �� ������ ����������� ����� 
  premium_m_src number(7),        --������ �� �������� ������, ������ �� ����
  premium_m number(7),            --������ �� �������� ������, ����������� �� ������� ��� �������� ������� � ���������� ���������
  premium number(7),              --������, ����� ������� ������ �� ����
  premium_p number(7),            --������, �� �����������, �� �������
  otpusk number(7),               --������
  bl number(7),                   --����������
  penalty number(7),              --������, �� ����
  itog1 number(7),                --����� ���������
  ud number(7),                   --��������
  ndfl number(7),                 --���� 
  fss number(7),                  --���
  pvkarta number(7),              --������������� �������/�����
  karta number(7),                --�����
  banknotes varchar2(40),         --������� �� �������
  itog number(7),                 --����� � ������
  constraint pk_payroll_item primary key (id),
  constraint fk_payroll_item_payroll foreign key (id_payroll) references payroll(id) on delete cascade,
  constraint fk_payroll_item_worker foreign key (id_worker) references ref_workers(id),
  constraint fk_payroll_item_job foreign key (id_job) references ref_jobs(id),
  constraint fk_payroll_item_schedule foreign key (id_schedule) references ref_work_schedules(id)
);  
  
create sequence sq_payroll_item start with 100 nocache;

create unique index idx_payroll_item_unique on payroll_item(id_division, id_worker, dt);
create index idx_payroll_item_dt_job on payroll_item(dt, id_job);   

--��� ��� �������� (������ �� ��������� � ������ �������������) ���������� ����������
create or replace view v_payroll_item as 
select
  i.*,
  s.code,
  s.code || ' (' || to_char(i.norm) || ')' as schedule,
  p.dt2 as dt2,
  w.f || ' ' || w.i  || ' ' || w.o as workername,
  w.personnel_number,
  o.name as org_name,
  d.name as divisionname,
  d.id_prod_area,
  a.shortname as prod_area_shortname,
  a.name as prod_area_name,
  j.name as job,
  p.id_method as id_method
from
  payroll_item i,
  payroll p,
  ref_workers w,
  ref_divisions d,
  ref_jobs j,
  payroll_method m,
  ref_work_schedules s,
  ref_sn_organizations o,
  ref_production_areas a
where
  i.id_payroll = p.id and
  i.id_division = d.id and
  i.id_worker = w.id and 
  i.id_job = j.id and
  p.id_method = m.id (+) and
  i.id_schedule = s.id (+) and
  o.id (+) = w.id_organization and
  a.id (+) = d.id_prod_area
;     

select * from v_payroll_item;

--����� �� ���������� ����������
--����� ������ �������� ����� �� ���������� ������, �� ���������� �������� �� �����
--����� ��������� ������ ������ �� ���������� �� �������������, ��������� �� ��������� ���������� �� �����������
create or replace view v_payroll_sum as 
select 
  id_d, max(divisioncode) as code, max(s.divisionname) as dn , dt1, sum(sitog1) as itog1, sum(sud) as ud, sum(sndfl) as ndfl, sum(sfss) as fss, sum(spvkarta) as pvkarta, sum(skarta) as karta, sum(sitog) as itog
from
(
select
  i.*,
  p.dt1 as dt1,
  p.dt2 as dt2,
  d.name as divisionname,
  d.code as divisioncode
from
  (select id_payroll, max(id_division) as id_d, sum(itog1) as sitog1, sum(ud) as sud, sum(ndfl) as sndfl, sum(fss) as sfss, sum(pvkarta) as spvkarta, sum(karta) as skarta, sum(itog) as sitog from payroll_item group by id_payroll) i,
  (select id, dt1, dt2 from payroll where id_worker is null) p,
  ref_divisions d
where
  i.id_payroll = p.id and
  i.id_d = d.id
) s 
group by
  dt1,
  id_d  
;     

select * from v_payroll_sum; 
select to_char(dt1, 'dd-mm-yyyy') from v_payroll_sum; 








/*create or replace view v_ref_division_members as  
select
  dm.*,
  w.f || ' ' || w.i  || ' ' || w.o as workername,
  d.name as divisionname,
  j.name as job,
  t.code as turvcode
from
  ref_division_members dm,
  ref_workers w,
  ref_divisions d,
  ref_turvcodes t,
  ref_jobs j
where
  dm.id_division = d.id and
  dm.id_division = d.id and
  dm.id_worker = w.id and
  dm.id_turvcode = t.id(+) and
  dm.id_job = j.id
;     
*/

/*
create or replace view v_turv as  
select
  turv.*,
  w.f || ' ' || w.i  || ' ' || w.o as workername,
  d.name as divisionname,
  j.name as job
--  t.code as turvcode
from
  turv,
  ref_workers w,
  ref_divisions d,
--  ref_turvcodes t,
  ref_jobs j
where
  turv.id_division = d.id and
  turv.id_division = d.id and
  turv.id_worker = w.id and
--  turv.id_turvcode = t.id(+) and
  turv.id_job = j.id
;     

*/



------------------------------------------------------------------------------------------------------------------------
/*
���������� � ��������
*/

--������� �������� ��� �����������
--drop table ref_candidates_status cascade constraints; 
create table ref_candidates_status(
  id number(11),
  name varchar(100) not null,
  constraint pk_ref_candidates_status primary key (id)
);  

insert into ref_candidates_status (id, name) values (1, '������');
insert into ref_candidates_status (id, name) values (3, '������');
insert into ref_candidates_status (id, name) values (10, '������');
insert into ref_candidates_status (id, name) values (11, '����� ���-��');
insert into ref_candidates_status (id, name) values (12, '����� ���.');
insert into ref_candidates_status (id, name) values (13, '����� ��');


create table ref_candidates_ad(
  id number(11),
  name varchar(100) not null,
  constraint pk_ref_candidates_ad primary key (id)
);  

create sequence sq_ref_candidates_ad start with 100 nocache;


create table j_vacancy(
  id number(11),
  id_job number(11),           --���� ��������� ���������
  id_division number(11),      --���� �������������
  id_head number(11),          --���� ������������ (� ������� ����������)
  dt_beg date,                 --���� �������� ��������  
  dt_end date,                 --���� �������� ��������
  status number(1) default 0,  --��� �������� (0 - ��������, 1 - �������, 2 - ������)
  qnt number(3,0),             --��������� ���������� ����������                 
  reason number(1),            --������� �������� �������� (null, 1-�������� �������, 2-������� ������������) 
  comm varchar(4000),          --����� ����������� � ��������
  constraint pk_j_vacancy primary key (id),
  constraint fk_j_vacancy_job foreign key (id_job) references ref_jobs(id),
  constraint fk_j_vacancy_division foreign key (id_division) references ref_divisions(id),
  constraint fk_j_vacancy_head foreign key (id_head) references ref_workers(id)
);  

create index idx_j_vacancy_dt_beg on j_vacancy(dt_beg); 

create sequence sq_j_vacancy start with 100 nocache;


--drop table j_candidates cascade constraints; 
----delete from j_candidates;
--alter table j_candidates drop column ad;
--alter table j_candidates add id_ad number(11);
--alter table j_candidates add constraint fk_j_candidates_ad foreign key (id_ad) references ref_candidates_ad(id);

create table j_candidates(
  id number(11),
  id_vacancy number(11),       --���� ��������, �� ������� �������� ����������
  id_job number(11),           --���� ��������� ���������, ���� ��� ��������
  id_division number(11),      --���� �������������, ���� ��� ��������
  id_head number(11),          --���� ������������ (� ������� ����������), ���� ��� ��������
  id_ad number(11),             --��� ����� ������ ��������
  f varchar2(25),              --�������
  i varchar2(25),              --���
  o varchar2(25),              --��������  
  dt_birth date,               --���� ��������
  phone varchar2(400),         --������� 
  dt date,                     --���� ������������� 
  dt1 date,                    --���� ������
  dt2 date,                    --���� ����������
  id_status number(3),         --������ (������, ����� ��...) 
  comm varchar(4000),          --�����������   
  constraint pk_j_candidates primary key (id),
  constraint fk_j_candidates_vacancy foreign key (id_vacancy) references j_vacancy(id),
  constraint fk_j_candidates_job foreign key (id_job) references ref_jobs(id),
  constraint fk_j_candidates_division foreign key (id_division) references ref_divisions(id),
  constraint fk_j_candidates_head foreign key (id_head) references ref_workers(id),
  constraint fk_j_candidates_status foreign key (id_status) references ref_candidates_status(id),
  constraint fk_j_candidates_ad foreign key (id_ad) references ref_candidates_ad(id)  
);

create index idx_j_candidates_dt on j_candidates(dt); 
create index idx_j_candidates_name on j_candidates(f,i,o); 
create index idx_j_candidates_vacancy on j_candidates(id_vacancy); 
create index idx_j_candidates_job on j_candidates(id_job); 
create index idx_j_candidates_division on j_candidates(id_division); 
create index idx_j_candidates_head on j_candidates(id_head); 
create index idx_j_candidates_ on j_candidates(id_); 
create index idx_j_candidates_ on j_candidates(id_); 


create sequence sq_j_candidates start with 100000 nocache;


--��� ������� �����������
--���������, ������������ � ������������� ����� �� ����������� ��������, ���� ��� ����
--����� ����� �� ������ ������� �����������
create or replace view v_j_candidates as 
select
  c.*,
  f_fio(c.f, c.i, c.o) as name,
  (case
    when c.id_vacancy is null then f_fio_short(w.f, w.i, w.o)
    else f_fio_short(wv.f, wv.i, wv.o)
  end) as headname,
  (case
    when c.id_vacancy is null then null
    else to_char(v.dt_beg, 'YYYY-MM-DD') || ' (' || v.id || ')' 
  end) as vacancy,
  (case
    when c.id_vacancy is null then d.name
    else dv.name
  end) as divisionname,
  (case
    when c.id_vacancy is null then j.name
    else jv.name
  end) as job,
  (case 
    when c.dt2 is not null then '������'
    when c.dt1 is not null then '��������'
    else s.name
  end) as statusname,
  (case 
    when c.dt2 is not null and c.dt1 is not null 
      then '������� � ' || to_char(c.dt1, 'DD.MM.YYYY') || ' �� ' || to_char(c.dt2, 'DD.MM.YYYY')
    when c.dt2 is not null and c.dt1 is null 
      then '������ ' || to_char(c.dt2, 'DD.MM.YYYY')
    when c.dt1 is not null then '�������� c ' || to_char(c.dt1, 'DD.MM.YYYY')
    else s.name
  end) as statusfull,
  ad.name as ad,
  v.dt_end as vacancyclosed
from
  j_candidates c,
  j_vacancy v,
  ref_workers w,
  ref_workers wv,
  ref_divisions d,
  ref_divisions dv,
  ref_jobs j,
  ref_jobs jv,
  ref_candidates_status s,
  ref_candidates_ad ad
where
  c.id_vacancy = v.id (+) and
  c.id_division = d.id (+) and
  c.id_head = w.id (+) and 
  c.id_job = j.id (+) and
  c.id_status = s.id (+) and
  c.id_ad = ad.id (+) and
  v.id_job = jv.id (+) and
  v.id_division = dv.id (+) and
  v.id_head = wv.id (+) 
;     

select * from v_j_candidates order by id asc;


--��� ������ ��������
--��� ������� �� ������� ��������, ����� ���������� � �������� �� ������ ��������
--��������� ��� ������������ (���� ������ � ������������ ��������� �� ���������� �����), � ��� �������� �� ����
--�������� ��������, ���������� ��� ����� ��������������� ����� � ���������� � ���� 
create or replace view v_j_vacancy as 
select
  v.*,
  to_char(v.dt_beg, 'YYYY-MM-DD') || ' (' || v.id || ')' as caption1, 
  f_fio(w.f, w.i, w.o) as headname,
  d.name as divisionname,
  j.name as job,
  (case
    when v.status = 0 then '��������'
    when v.status = 1 then '�������'
    when v.status = 2 then '������'
    else ''
  end) as statusname,
  (case
    when v.reason = 1 then '�������'
    when v.status = 2 then '������� ������������'
    else ''
  end) as reasonname,
  vw.name as workers, 
  vc.name as candidates,
  nvl(vw.qntworkers, 0) as qntworkers,
  nvl(v.qnt, 0) - nvl(vw.qntworkers, 0) as qntopen 
from
  j_vacancy v,
  ref_workers w,
  ref_divisions d,
  ref_jobs j,
  v_j_vacancy_workers vw,
  v_j_vacancy_candidates vc
where
  v.id_division = d.id (+) and
  v.id_head = w.id (+) and
  v.id_job = j.id (+) and
  v.id = vw.id (+) and 
  v.id = vc.id (+) 
;     

--��� ��������� ������, ������������� �������� �� ������ �������� � ����� ������ � ������� �� ���������� �����
--��������� ��������� ���� ���� ���� �������� � ��� ���� ����������, ��� ���� ���������� ������ ���� �������� ��������
create or replace view v_j_vacancy_workers as 
select
  max(v.id) as id,
  count(v.id) as qntworkers,
--  listagg(cp.fio ||  ';  ') within group (order by cp.f) as name
  rtrim(listagg(cp.fio ||  '; ') within group (order by cp.fio), '; ') as name
from
  j_vacancy v,
  (select id, f_fio_short(f, i, o) as fio, id_vacancy, dt1, dt2, f from j_candidates) cp
where
  v.id = cp.id_vacancy  and
  cp.dt1 is not null and
  (cp.dt2 is null or v.dt_end is null or cp.dt2 > v.dt_end)  
--  (cp.dt2 is null and (v.dt_end is null or cp.dt2 > v.dt_end))
  group by v.id
;

--�� �� �� ���������� - ��� �� �������� ��� ��� ���������
create or replace view v_j_vacancy_candidates as 
select
  max(v.id) as id,
  count(v.id) as qntcandidates,
  --v.id, cp.fio
  rtrim(listagg(cp.fio ||  '; ') within group (order by cp.fio), '; ') as name
from
  j_vacancy v,
  (select id, f_fio_short(f, i, o) as fio, id_vacancy, dt1, dt2, f from j_candidates) cp
where
  v.id = cp.id_vacancy  and
  not (
  cp.dt1 is not null and
  (cp.dt2 is null and (v.dt_end is null or cp.dt2 > v.dt_end))
  )
  group by v.id
;


--����� �� ���������� �����, �������� �� ������ ������ ����
create table rep_salary(
  dt date,                     --���� ������ (������, ��������� ������� ����, ������ ��� ������� ��� �� ������ ������
  id_job number(11),           --���������
  sum0 number(7),              --���� �/�
  sum1 number(7),              --������� �� ������
  sum2 number(7),              --�����������  
  sum3 number(7),              --������������ 
  constraint pk_rep_salary primary key (dt, id_job),
  constraint fk_rep_salary_id_job foreign key (id_job) references ref_jobs(id) 
);  

--��� ��� ������ �� ���������� �����
create or replace view v_rep_salary as
select
  j.name as job,
  s.*
from
  rep_salary s,
  ref_jobs j
where
  s.id_job = j.id
;    

--����� ������� ��������� ��������� � ������, ����� ��������� ������ � ��������� ����� ��� ����������, ������� ��� ��� � ������
--insert into rep_salary (dt, id_job, sum0, sum1, sum2, sum3)
--delete from rep_salary;
insert into rep_salary (id_job, dt)
select id, '08.07.2023' as j from ref_jobs where not exists (select 1 from rep_salary where id_job = id and dt = '08.07.2023')
;

--��� �������� ��� �������� ������� ������� �� ������ �� ��������
update rep_salary s0 set 
sum1 =
(select sum1 from rep_salary s1 where dt = '01.06.2023' and s0.id_job = s1.id_job)
where sum0 is null and dt = '07.07.2023' 
;

--��� ������� ������ �� �� �� ���������� ����������
update rep_salary s0 set sum0 = (
   select round(avg((itog1 - nvl(bl) - nvl(otpusk) - nvl(penalty))) / turv * norm)*2 sumall  
    from 
      v_payroll_item pi
    where 
     itog1 is not null and turv is not null and turv <> 0    
     and s0.id_job = pi.id_job
     and dt >= '01.04.2023'
     and dt <= '16.06.2023'
     )
  where s0.dt = '16.06.2023'
;  


select round(avg(sumall) * 2), id_job  from (   
   select dt, id_job, round(itog1 / turv * norm) sumall  
    from 
      v_payroll_item pi
    where 
     itog1 is not null and turv is not null and turv <> 0  
     and dt > '01.04.2023'
)     
group by id_job;

--------------------------------------------------------------------------------

--������� �������� ������
--alter table ref_work_schedules add active number(1);
create table ref_work_schedules(
  id number(11),
  code varchar2(50),
  name varchar2(400),
  active number(1),
  constraint pk_work_schedules primary key (id)
);  

create unique index idx_ref_work_schedules_code on ref_work_schedules(lower(code));
create unique index idx_ref_work_schedules_name on ref_work_schedules(lower(name));

create sequence sq_ref_work_schedules start with 100 nocache;

create or replace trigger trg_ref_work_schedules_bi_r before insert on ref_work_schedules for each row
begin
  select sq_ref_work_schedules.nextval into :new.id from dual;
end;
/

insert into ref_work_schedules (code, name, active) values ('5/2', '5 ����� 2', 1);

 
--������� ����� �������� �������, �� �������� � �� ��������
create table ref_working_hours(
  id number(11),
  id_work_schedule number(11), --���� ������� ������ 
  dt date,                     --���� ������ �������
  hours number,                --�����, � �����
  constraint pk_ref_working_hours primary key (id),
  constraint fk_ref_working_hours_s�hedule foreign key (id_work_schedule) references ref_work_schedules(id) 
);  

create unique index idx_ref_working_hours_uq on ref_working_hours(id_work_schedule, dt);

create sequence sq_ref_working_hours start with 100 nocache;

create or replace trigger trg_ref_working_hours_bi_r before insert on ref_working_hours for each row
begin
  select sq_ref_working_hours.nextval into :new.id from dual;
end;
/

create or replace view v_ref_work_schedules as
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
  ref_work_schedules s,
  ref_working_hours h1,
  ref_working_hours h2,
  ref_working_hours h3,
  ref_working_hours h4
where  
  h1.id_work_schedule(+) = s.id and h1.dt(+) = to_date(to_char(add_months(sysdate, -1), 'yyyy-mm') || '-16', 'yyyy-mm-dd')
  and h2.id_work_schedule(+) = s.id and h2.dt(+) = to_date(to_char(sysdate, 'yyyy-mm') || '-01', 'yyyy-mm-dd')
  and h3.id_work_schedule(+) = s.id and h3.dt(+) = to_date(to_char(sysdate, 'yyyy-mm') || '-16', 'yyyy-mm-dd')
  and h4.id_work_schedule(+) = s.id and h4.dt(+) = to_date(to_char(add_months(sysdate, 1), 'yyyy-mm') || '-01', 'yyyy-mm-dd')
;  

--����������� � ���������� �� ���������� ��������� � ���������� �������������  
create table ref_workers_needed(
  id_job number,
  id_division number,
  qnt number,
  constraint pk_ref_workers_needed primary key (id_job, id_division),
  constraint fk_ref_workers_needed_job foreign key (id_job) references ref_jobs(id),
  constraint fk_ref_workers_needed_div foreign key (id_division) references ref_divisions(id)
);  


create or replace view v_staff_schedule as
select
  --������� ���������� �� �������� ����:
  --���������, �������� ���������� ���������� ������ ��������� �� ������� � ����� (����� ����� division),
  --������� ����������� �� ���������� ��� ������� ������
  t.id_job, 
  t.id_division,
  j.name as job,
  d.name as division,
  decode(t.office, 1, '����', '���') as office,
  t.qnt,
  wn.qnt as qnt_need
from  
  (select 
    id_job, 
    id_division,
    count(1)  as qnt,
    max(office) as office
  from 
    v_turv_workers
  where
    id_division > 3  --��������� ��������
    and dt1p <= nvl(get_context('staff_schedule_dt'),sysdate) 
    and dt2p >= nvl(get_context('staff_schedule_dt'),sysdate) 
  group by
    rollup(id_job, id_division)
  ) t,
  ref_jobs j,
  ref_divisions d,
  ref_workers_needed wn
where
  t.id_job = j.id(+)
  and t.id_division = d.id(+)
  and t.id_job = wn.id_job(+)
  and t.id_division = wn.id_division(+)  
order by
  j.name, d.name       
;  










select 
  job, 
  divisionname,
  count(1)  as qnt
from 
  v_turv_workers
where
  dt1p <= sysdate
  and dt2p >= sysdate  
group by
  rollup(job, divisionname)
order by  
  job, divisionname
;  




--update rep_salary set sum0 = null;
--delete from rep_salary;

/*
update rep_salary s0 set 
sum1 = (
select sum from (
select sum(ball) sum from 
v_payroll_item pi
where
pi.turv is not null
group by
pi.id_job, pi.dt
)
where
s0.id_job = pi.id_job
)
;

select id_job, dt, sum(ball), count(*) from ( 
(select id_job, dt, round(ball/turv*norm) as ball  from
v_payroll_item pi
where
pi.turv is not null
)
group by
pi.id_job, pi.dt
order by id_job
);

 

(select sum0 from rep_salary s1 where dt = '01.06.2023' and s0.id_job = s1.id_job)
where sum0 is null and dt = '07.07.2023' 
;
*/

/*



--����� �� ���������
create or replace view v_rep_personnel as
select
  j.name as job,
  t.*
from
((select  
  v.id_job as idjob,
  null as qnt1,
  null as qnt2,
  v.qnt as vacqnt,
  v.dt_beg as vacbeg
from  
  j_vacancy v)
union  
(select  
  s.id_job as idjob,
  (case when s.status  = 1
    then 1
    else null
  end) as qnt1,
  (case when s.status  = 3
    then 1
    else null
  end) as qnt2,
  null as vacqnt,
  null as vacbeg
from  
  j_worker_status s
)  
) t,
ref_jobs j
where
  t.idjob = j.id;  
  
select * from v_rep_personnel; 
select max(job), sum(qnt1) qnt1, sum(qnt2) qnt2, sum(vacqnt) vacqnt, min(vacbeg) as vacbeg from v_rep_personnel; -- group by job order by qnt2 desc;

select  
  s.id_job as idjob,
  (case when s.status  = 1
    then 1
    else null
  end) as qnt1,
  (case when s.status  = 3
    then 1
    else null
  end) as qnt2,
  null as vacqnt,
  null as vacbeg
from  
  j_worker_status s;



--����� �� ��������� ����������

select
  max(v.id) as id,
  count(v.id) as qntcandidates,
  --v.id, cp.fio
  rtrim(listagg(cp.fio ||  '; ') within group (order by cp.f), '; ') as name
from
  j_vacancy v,
  (select id, f_fio_short(f, i, o) as fio, id_vacancy, dt1, dt2, f from j_candidates) cp
where
  v.id = cp.id_vacancy  and
  not (
  cp.dt1 is not null and
  (cp.dt2 is null and (v.dt_end is null or cp.dt2 > v.dt_end))
  )
;
  
  
;    



select * from v_j_vacancy_workers;

select * from v_j_vacancy_test order by np;
select * from v_j_vacancy_uv;

select * from v_j_vacancy;

select lengthb('����') from dual;

select * from v_j_candidates order by name; 

select max(workername), max(id) from v_j_worker_status where status <> 3 or id = (select id_head from v_j_vacancy where id = 1) group by workername order by workername;




--������ �
--���� �� ���� ���������� 
-- ���� �������� �� �������,
-- ���� ����� ���������� ����� �������� ��������
select  
---select
  max(v.id) as id,
  count(v.id) as qntworkers,
--  listagg(cp.fio ||  ';  ') within group (order by cp.f) as name
  rtrim(listagg(cp.fio ||  '; ') within group (order by cp.f), '; ') as name
from
  j_vacancy v,
  (select id, f_fio_short(f, i, o) as fio, id_vacancy, dt1, dt2, f from j_candidates) cp
where
  v.id = cp.id_vacancy  and
  cp.dt1 is not null 
--  and v.id = 103
  and
      (cp.dt2 is null or v.dt_end is null or cp.dt2 > v.dt_end)  
--  (cp.dt2 is null and (v.dt_end is null or cp.dt2 is null or cp.dt2 > v.dt_end))
group by v.id
;

select job, ad, name, name as name1, dt, dt_birth, null, null, null from v_j_candidates where dt >= '05.01.2023' order by job, ad, name;

*/




select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0 from turv_day where (begtime is null or endtime is null) and id_division = 4;
select distinct id_worker from turv_day where (begtime is null or endtime is null) and id_division = 4;

select * from turv_day where id_worker = 78 order by dt desc;




---------------------------
---------------------------
---------------------------
/*
--alter table j_worker_status drop column id_schedule;
alter table ref_workers add id_schedule number(11);
alter table ref_workers add  constraint fk_ref_workers_schedule foreign key (id_schedule) references ref_work_schedules(id);
alter table turv_worker add id_schedule number(11);
alter table turv_worker add  constraint fk_turv_worker_schedule foreign key (id_schedule) references ref_work_schedules(id);
alter table turv_period add id_schedule number(11);
alter table turv_period add  constraint fk_turv_period_schedule foreign key (id_schedule) references ref_work_schedules(id);
alter table ref_divisions add id_schedule number(11);
alter table ref_divisions add constraint fk_ref_divisions_schedule foreign key (id_schedule) references ref_work_schedules(id);
alter table payroll_item add norm number(7);
alter table payroll_item add norm_m number(7);
alter table payroll_item add id_schedule number(11);
alter table payroll_item add constraint fk_payroll_item_schedule foreign key (id_schedule) references ref_work_schedules(id);
alter table payroll_item add banknotes varchar2(40);

--update ref_divisions set id_schedule = 100;
--update turv_period set id_schedule = 100;
*/
/*
--select sum1 from rep_salary s1 where dt = :dt1$d and s0.id_job = s1.id_job), sum2 = (select sum2 from rep_salary s1 where dt = :dt2$d and s0.id_job = s1.id_job), sum3 = (select sum3 from rep_salary s1 where dt = :dt3$d and s0.id_job = s1.id_job)

 select sum1 from rep_salary s1 where dt = '16/05/2025';
select sum1 from rep_salary where sum1 is null and sum2 is null and sum3 is null and dt = '01/06/2025'; --:dtcurr$d;

--update rep_salary s0 set sum0 = 

select round(avg((itog1 - nvl(otpusk,0) - nvl(bl,0) - nvl(penalty,0)) / turv * norm) * 2) sumall from v_payroll_item pi where itog1 is not null and turv is not null and turv <> 0 and dt >= '01/04/2025' and dt <= '01/06/2025';
select * from v_payroll_item pi where itog1 is not null and turv is not null and turv <> 0 and dt >= '01/04/2025' and dt <= '01/06/2025';


 )-- where s0.dt = :dt$d 
 */
 
 select divisionname, workername, karta, ndfl from v_payroll_item where dt = '01/07/2025' order by workername;
 
 select i.workername, i.divisionname, i.karta, i.ndfl 
 from v_payroll_item i, payroll p 
 where 
 dt = '01/07/2025' and p.id = i.id_payroll and p.id_worker is null
 order by workername;