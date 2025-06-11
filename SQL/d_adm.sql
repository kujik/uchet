-- �����������������


--����

create table adm_roles ( 
  id number(12),
  name varchar2(50) not null,
  rights varchar2(4000),
  constraint pk_adm_roles primary key (id)
);

create sequence sq_adm_roles nocache start with 1;

create unique index idx_adm_roles_name on adm_roles(lower(name));

insert into adm_roles (id, name) values (0, '�������������');


---

-- ������������
alter table adm_users add  job_comm varchar2(150);
alter table adm_users add idletime number default 0;
create table adm_users (
  id number(12),
  login varchar2(50),               -- ����� �� ����������, �� ����������
  name varchar2(50) not null,       -- ������������ ���
  pwd varchar2(50),                 -- ������, �� ����������
  active number(1) default 0,       -- �������, ��� ����� ����� ����� ����� ������ ����������, ����� ����������� �������� ����� �� ������ ����� ��� ����� 
  autologin number(1) default 1,    -- �������� ��������� ������������ ��� ���������� ��� ������ � ������ �� ����������
  job number(2) default 0,          -- ��������� ������������, ��� ������������� � ���� ���������, �������� ������ � ���
  job_comm varchar2(150),           -- ����������� (���������, ����� ������)
  email varchar2(100),              -- ����� ����������� �����, ���� �� ������������
  emailauto number(1) default 1,    -- ������� ��� ����� ����������� �������������, �� ������� � ������ 
  idletime number default 0,      -- ����� ������� ���������, ����� ������� ��� ������������� ���������� (���� ��� 0)
  constraint pk_adm_users primary key (id)
);

create sequence sq_adm_users nocache start with 1;

-- ��� ������������ � ����� ��������� � ��������� �� ��������
create unique index idx_adm_users_name on adm_users(lower(name));
create unique index idx_adm_users_name_2 on adm_users(name);
create unique index idx_adm_users_login on adm_users(lower(login));

/*
insert into adm_users (id, name, login) values (0, '�������������', '�������������');
*/
insert into adm_users (id, name, login, active, emailauto) values (-100, '[���]', '', 0, 0);
insert into adm_users (id, name, login, active, emailauto) values (-101, '[�����������]', '', 0, 0);
insert into adm_users (id, name, login, active, emailauto) values (-102, '[��������]', '', 0, 0);

--update adm_users set pwd = get_hash_val('9987') where id = 0;

create or replace trigger trg_adm_users_auid 
after update or insert or delete
on adm_users
begin
  update adm_mailing set userids = userids;
end;
/


create or replace view v_users as select
  u.*,
  j.name as jobname, --no use
  decode(job_comm, null, decode(u.job, 0, u.login, F_GetUserJob(u.job)), job_comm) as comm,
  decode(u.emailauto, 1, u.login || '@' || s.emaildomain, u.email) as emailaddr
from
  adm_users u,
  ref_jobs j,
  adm_main_settings s
where
  j.id (+) = u.job
;

select * from v_users;

create or replace function F_GetUserJob( 
  AIdJob number
)  
return varchar2
is
  st varchar2(200);
begin
  select decode(AIdJob,
    1,'�������� ������ ������',
    2,'�����������',
    3,'��������',
    4,'��������� ���',
    5,'���������',
    6,'�������� ������ ���������',
    7,'���������',
    8,'�������� ������ ������',
    9,'������',
    10,'��������',
    11,'���',
    12,'������� �� ������������',
    ''
  ) into st from dual;
  return st;
end;
/    



select * from v_users;  
      

-- ������, ������� ��� ���������� ����������� ������, ����������� ���� �������
alter table adm_modules add (autoclosedt date, autoclosemin number(4) default 0);
create table adm_modules (
  id number(12),             -- ����, �� �������� �������� ������ � ��������, ������� � ������� � ������
  nameen varchar2(50),       -- ���������� ������������, ��������� � ������
  nameru varchar2(50),       -- �������, ���������� 
  autoclosedt date,          -- ����/����� �������������� ������, ����������� ��� � ������, ���� ����� �������� ����� +3��� �� ��������� �����������
  autoclosemin number(4) default 0,    -- ���������� ����� ����� autoclosedt, � ������� ������� ��������� �� ����� ���� ��������, ����������� ��� �������
  constraint pk_adm_modules primary key (id)
);

insert into adm_modules (id, nameen, nameru) values (0, 'Admin', '�����������������');
insert into adm_modules (id, nameen, nameru) values (1, 'PaymentCalendar', '��������� ���������');
insert into adm_modules (id, nameen, nameru) values (2, 'Workers', '���������');
insert into adm_modules (id, nameen, nameru) values (3, 'Picking', '������������');
insert into adm_modules (id, nameen, nameru) values (4, 'Server', '������');
insert into adm_modules (id, nameen, nameru) values (5, 'Production', '������������');
insert into adm_modules (id, nameen, nameru) values (6, 'Orders', '������');
insert into adm_modules (id, nameen, nameru) values (0, '', '');


-- ������ ����/������, ����� ��� ����������� �������������� � ������, �� �������� �� ������ ������������ - ������������ �� ������ �����
-- ��� ���������/�������� ���� ��������� ������ �������� ������ � ��� ������� �������!!!
create table adm_role_modules(
  id_role number(12),
  id_module number(12),
  constraint fk_adm_role_modules_id_role foreign key (id_role) references adm_roles(id) on delete cascade,
  constraint fk_adm_role_modules_id_module foreign key (id_module) references adm_modules(id) on delete cascade
);

-- ������ ������������/����
create table adm_user_roles(
  id_user number(12),
  id_role number(12),
  constraint fk_adm_user_roles_id_user foreign key (id_user) references adm_users(id) on delete cascade,
  constraint fk_adm_user_roles_id_role foreign key (id_role) references adm_roles(id) on delete cascade
);

-- ������� ��� ���������� ��������� ����, ������, �������� � ��, ����������� �������� ��� ������� ������������ � ������
--drop table adm_user_cfg cascade constraints;
create table adm_user_cfg(
  id_user number(12),
  id_module number(12),
  cfg clob,
  constraint pk_adm_user_cfg primary key (id_user, id_module),
  constraint fk_adm_user_cfg_id_user foreign key (id_user) references adm_users(id) on delete cascade,
  constraint fk_adm_user_cfg_id_module foreign key (id_module) references adm_modules(id) on delete cascade
);

--insert into adm_user_cfg (id_user, id_module, cfg) select -1, id_module, cfg from adm_user_cfg where id_user = 33;

--������� ������ ��� ������, �� �������� �������� ���� ��� ����� �������������
create table adm_password (
  password varchar2(4000)
);

--insert into adm_password (password) values ('');
--��������� ������ ��� ����� ��� ����� ������, ����� ������
update adm_password set password = get_hash_val('gurkenau');
--��������� ������ ������
update adm_users set pwd = get_hash_val('dorkinau') where id = 0;
--��������� ������ my
update adm_users set pwd = get_hash_val('Ruglosu4no') where id = 33;
--������ �� ����
select id, login, name from adm_users where (name = '���������� �.�.') and (
   ( (select password from adm_password) = get_hash_val('gurkenau')
     and ('username' <> '�������������')
     )  or 
  (pwd=get_hash_val('11111'))
  );

--������� ������ ��������� ���� ������ (����������� ��� ���� ������� � ���� �������������
--alter table adm_main_settings add orderestimatepath varchar2(500);
create table adm_main_settings (
  filespath varchar2(500),        --���� � ������ ������ � ��������, ���� ������ ���� �������� �� ������ � ������ ���� ������������� ��������� �� ���� �������
  orderarchivepath varchar2(500),        --���� � ������ �������   
  ordercurrentpath varchar2(500),        --���� � ������� � ������
  orderestimatepath varchar2(500),       --���� � ����������� ������ ��� �������
  emaildomain varchar2(200),             --�������� �����, fr-mix.ru
  emailserver varchar2(200),             --����� �������  
  emaillogin varchar2(200),              --����� ������� ������ �������
  emailpassword varchar2(200),           --������ ������� ������ 
  emailuser varchar2(200),               --����, �� �������� ���� ������ - uchet
  emailname varchar2(200)                --������������ ��� ������������, ����  
);

create or replace trigger trg_adm_main_settings_au 
after update
of emaildomain
on adm_main_settings
begin
  update adm_mailing set userids = userids;
end;
/

--���������� 1, ���� � ������ ���� ������������ ���������� ������� ������
create or replace function IsModuleAvailable (
  id_role in number,
  id_module in number
)
return number
is
  rgs varchar2(4000);
  i number;
begin
  select rights into rgs from adm_roles where id = id_role;
  i := instr(',' || rgs, ',' || id_module || '-');
  if i > 0 
    then return 1;
    else return 0;
  end if; 
end;
/


--���������� 1 ���� � ����� ����������� ������������ ����������� ���������� ������� ������ 
create or replace function IsModuleAvailableToUser (
  id_user1 in number,
  id_module in number
)
return number
is
  rgs varchar2(4000);
  i number;
begin
select
  listagg(IsModuleAvailable(r.id, id_module),  '') within group (order by r.id) into rgs
from adm_users u, adm_roles r, adm_user_roles ur
where 
  ur.id_user = u.id and r.id = ur.id_role and u.id = id_user1
group by u.id;  
  i := instr(rgs, 1);
  if i > 0 
    then return 1;
    else return 0;
  end if; 
end;
/


select IsModuleAvailableToUser(33,0) from dual;

select
  u.id, max(u.name),
  listagg(r.rights,  ',') within group (order by r.id)
from adm_users u, adm_roles r, adm_user_roles ur
where 
  ur.id_user = u.id and r.id = ur.id_role
  and u.id = 33
group by u.id  
;       

-- �������� ����������� ������ ������ �� ��� ����������� � �����, ����������� ������������
--���� ������ ��������, �� � ������������ ������ ����� �������������� ����� 1
select
  u.id, max(u.name),
  listagg(IsModuleAvailable(r.id, 1),  '') within group (order by r.id)
from adm_users u, adm_roles r, adm_user_roles ur
where 
  ur.id_user = u.id and r.id = ur.id_role
  and u.id = 33
group by u.id  
;

select
  u.id, max(u.name),
  listagg(IsModuleAvailable(r.id, 0),  '') within group (order by r.id)
from adm_users u, adm_roles r, adm_user_roles ur
where 
  ur.id_user = u.id and r.id = ur.id_role
  and u.id = 33
group by u.id  
;       
       



CREATE OR REPLACE FUNCTION get_hash_val (
     p_in_val      IN   VARCHAR2,
     p_algorithm   IN   VARCHAR2 := 'SH1'
  )
     RETURN VARCHAR2
  IS
     l_hash_val    RAW (4000);
     l_hash_algo   PLS_INTEGER;
     l_in          RAW (4000);
     l_ret         VARCHAR2 (4000);
  BEGIN
     l_hash_algo :=
        CASE p_algorithm
           WHEN 'SH1'
              THEN DBMS_CRYPTO.hash_sh1
           WHEN 'MD4'
              THEN DBMS_CRYPTO.hash_md4
           WHEN 'MD5'
              THEN DBMS_CRYPTO.hash_md5
        END;
     l_in := utl_i18n.string_to_raw (p_in_val, 'AL32UTF8');
     l_hash_val := DBMS_CRYPTO.HASH (src => l_in, typ => l_hash_algo);
     l_ret := rawtohex(l_hash_val);
     RETURN l_ret;
  END;

-- ����������
select logon_time, sid, serial# from v$session;
select * from v$session;  
-- ��� ����������, ����������� �� ����������� � ������, 
-- ���� �� ����� �����, ��������� ���� �����
-- logon_time, sid, serial# ���������� � ������� ����������, ��� ���������� ��������� ��� ������
-- �������� �� � v$session, � ���� ��� ��� �� ��� ������ ��� ������� ��� ���������� ����������� �������

select USERENV ('sessionid') from dual;
select logon_time, sid, serial# from v$session where sid in (select sid from v$mystat); -- where rownum = 1) ;
select logon_time, sid, serial# from v$session where sid in (select sid from v$mystat where rownum = 1);

delete from adm_locks l where (select count(*) from v$session vs where l.sid = vs.sid and l.serial# = vs.serial#) = 0;
delete from adm_locks l where (select count(sid) from v$session vs where l.sid = vs.sid and l.serial# = vs.serial#) = 0;

select serial# from v$session where sid in (select sid from v$mystat where rownum = 1);

insert into adm_locks (logon_time, sid, serial#, login, username, lock_time, lock_docum, lock_docum_add) values 
((select logon_time from v$session where sid in (select sid from v$mystat where rownum = 1)), 
(select sid from v$session where sid in (select sid from v$mystat where rownum = 1)), 
(select serial# from v$session where sid in (select sid from v$mystat where rownum = 1)), 
'sprokopenko','aaa',current_date,'a', '0');

select current_date from dual;

drop table adm_locks cascade constraints;

delete from locks;

create table adm_locks (
  logon_time date,
  sid number(20),
  serial# number(20),
  login varchar2(50),
  username varchar2(50),
  lock_time date,
  lock_docum varchar2(50),
  lock_docum_add varchar2(50),
  constraint pk_adm_locks primary key (lock_docum, lock_docum_add)
);


-- END ����������

--------------------------------------------------------------------------------
--�������, � ������� ��������� ������ ��� ������ ������������ � �����
--����������� ������� P_UserLogon
create table adm_user_sessions (
  id number(11),
  logon_time date,               --����� �������� ������ � ������
  sid number(20),             
  serial# number(20),
  --login varchar2(50),
  id_module number(11),          --���� ������ (��, ������..)
  id_user number(11),            --���� ������������, ������� �����������
  --username varchar2(50),
  user_logon_time date,          --����� ����������� ������������ � ����� (����� ���������� �� logon_time) 
  constraint pk_adm_user_sessions primary key (id)
);

create sequence sq_adm_user_sessions nocache;

create or replace trigger trg_adm_user_sessions_bi_r
  before insert on adm_user_sessions for each row
begin
  select sq_adm_user_sessions.nextval into :new.id from dual;
end;
/

create or replace procedure P_UserLogon (
--���������� �� ��������� ���� ��� ������� ������ ������������
--������ ������ ��������� �������������, ��������� ���� ������ ����� � ���� ������������� �����
  AIdModule in number,
  AIdUser in number
)
is
begin
  --������ ������ �� ������� ������� (������ ������ 14 ����)
  delete from adm_user_sessions us where 
    ((select count(1) from v$session vs where us.sid = vs.sid and us.serial# = vs.serial#) = 0)
    and (trunc(SysDate) - trunc(us.logon_time) > 14);
  --������ ������ 
  insert into adm_user_sessions (logon_time, sid, serial#, id_module, id_user, user_logon_time) values (
  (select logon_time from v$session where sid in (select sid from v$mystat where rownum = 1)),
  (select sid from v$session where sid in (select sid from v$mystat where rownum = 1)),
  (select serial# from v$session where sid in (select sid from v$mystat where rownum = 1)),
  AIdModule, AIdUser, SysDate
  );
end;
/

exec P_UserLogon(1,33);




--���������� 1, ���� 
create or replace function IsUserInAvailable (
  id_user in number,
  tablename in varchar2,
  id in number
)
return number
is
  rgs varchar2(4000);
  i number;
begin
  execute immediate 'select useravail from ' || tablename || ' where id = ' || id  into rgs;
  i := instr(',' || rgs || ',', ',' || id_user || ',');
  if i > 0 
    then return 1;
    else return 0;
  end if; 
end;
/ 

select IsUserInAvailable(33, 'ref_expenseitems', 110) from dual;

begin
 execute immediate 'select useravail from ' || 'ref_expenseitems' || ' where id = ' || 110 Into rrr;
end;
/


create or replace function IsRoleInAvailable (
  ids in varchar2,
  tablename in varchar2,
  id in number
)
return number
is
  rgs varchar2(4000);
  st varchar2(4000);
  sti varchar2(4000);
  i number;
begin
  execute immediate 'select useravail from ' || tablename || ' where id = ' || id  into rgs;
  sti := ids || ',';
  while sti is not null
  loop
    st := substr(sti, 1, instr(sti, ',', 1) - 1);
    sti := substr(sti, instr(sti, ',', 1) + 1);
    i := instr(',' || rgs || ',', ',' || st || ',');
    if i > 0 
      then return 1;
    end if;
  end loop;
  return 0;
end;
/ 

create or replace function AnyInStr (
  ids in varchar2,
  str in varchar2
)
return number
is
  rgs varchar2(4000);
  st varchar2(4000);
  sti varchar2(4000);
  i number;
begin
  sti := ids || ',';
  while sti is not null
  loop
    st := substr(sti, 1, instr(sti, ',', 1) - 1);
    sti := substr(sti, instr(sti, ',', 1) + 1);
    i := instr(',' || str || ',', ',' || st || ',');
    if i > 0 
      then return 1;
    end if;
  end loop;
  return 0;
end;

select IsRoleInAvailable('33', 'ref_expenseitems', 110) from dual;
select name from ref_expenseitems where anyinstr('33', useravail) = 1;


select name from adm_roles where id in (1,5,8,90);


--���������� ������ ���� ������������� ����� ;, �������� �� �� ����������� ���������, 
--������� �������� ������� ����� ������� ����� �������.
create or replace function GetUserNames (
userids varchar2
)
return varchar2   
is
   cv sys_refcursor; 
   val varchar2(4000);
   usernames varchar2(4000);  
begin
   usernames := '';
   open cv for 
      'select name from adm_users where id in (' || userids || ')'; 
   loop
      fetch cv into val;
      exit when cv%notfound;
      if usernames is not null
        then usernames := usernames || '; ';
      end if; 
      usernames := usernames || val;
--      dbms_output.put_line (val);
   end loop;
   close cv;
   return usernames;
end;
/ 

select GetUserNames('33,12') from dual;


--�������� ������
select module, machine, osuser from v$session where username = 'UCHET22';


--������� ��� �������� ������������� �������� ��������
alter table adm_mailing add customemail varchar2(4000);
create table adm_mailing (
  id number(11) not null,        --���� ��������
  userids varchar2(4000),        --������ ���� ������������� (������������ ��������� ����, �� �����!!!) ����� �������
  customemail varchar2(4000),    --������ �������, �������� �������, ����������� ������������� � ������� �������������
  comm varchar2(500),            --������ ����������� 
  addresses varchar2(4000),      --�������� ������ �������, ���������� ���������
  dt date, 
  constraint pk_adm_mailing primary key (id)
);

insert into adm_mailing (id, comm) values (1, '�������� ��� �������� � ��������� ��������, ��� �����-excel'); 
insert into adm_mailing (id, comm, userids) values (2, '�������� ��� �������� � ��������� ��������, ��� ���', '33'); 
insert into adm_mailing(id, comm) values (3, '�������� ��� ������������ ����� � ���������� ��� ���������, ��� �����-excel');
insert into adm_mailing(id, comm) values (4, '�������� �� ������, ��� ������� �� ������� �����');
insert into adm_mailing(id, comm) values (5, '�������� ��� ������������ ���������� ����������');


create or replace trigger trg_adm_mailing_bu
before update
of userids, customemail, id
on adm_mailing
for each row
begin
  --�������� ������ ������� ��� ���������� ������/��������
  select GetUsersAddemail(:new.userids, :new.customemail) into :new.addresses from dual;
/*  if :new.id = 1 and :new.addresses <> :old.addresses  then
    --��� �������� ��� �����-��� �� �������� ��������, ������� 
    update uchet.mailing set addresses = :new.addresses where id = 1;
  end if;*/
/*  if :new.id = 2 and :new.addresses <> :old.addresses then
    --��� ��� ��� �� �������� �������� 
    merge into dv.property_values d 
       using 
       (select m from (
         with tbl as (select :new.addresses || '' as str from dual)
         select regexp_substr(str, '[^,]+', 1, level) m
         from tbl
         connect by nvl(regexp_instr(str, '[^,]+', 1, level), 0) <> 0   
       )) s
       on (s.m = d.avalue and d.id_prop = 219)
       when not matched then insert (d.avalue, d.id_prop) values (s.m, 219)
       ;
    delete from dv.property_values where id_prop=219 and avalue not in 
     (select m from (
       with tbl as (select :new.addresses || '' as str from dual)
       select regexp_substr(str, '[^,]+', 1, level) m
       from tbl
       connect by nvl(regexp_instr(str, '[^,]+', 1, level), 0) <> 0   
     ));
  end if;*/
/*  if :new.id = 3 and :new.addresses <> :old.addresses  then
    --��� �������� ��� �����-��� ��� ��������� ����� 
    update uchet.mailing set addresses = :new.addresses where id = 2;
  end if;*/
end;
/






select GetUsersemail('33,1234,31') from dual;


--��������� ��������������� �������� ���������� ������
create table adm_delete_old (
  or_to_archive number(5),    --���������� ���� ����� �������� ������, �� ��������� �������� ������ ������������ � ����� (10)
  orders_n number(5),         --���������� ���� ����� �������� ������, �� ��������� �������� ������ � ��������� �� ������ � ���� (40)
  accounts_n number(5),       --���������� ���� ����� �������� ����� �� ���, ����� �������� ���� ��������� 
  turv number(5),             --���������� �������� ����, ������ ������� ������� (������ 2 ������)
  payrolls number(5)          --���������� �������� ���������� ����������, ������ ������� ������� (������ 2 ������)
);


create table grid_labels (
  doc varchar(100),
  id_user number(11),
  tablerow number(11),
  tablenum number,
  labelnum number,
  constraint pk_grid_labels primary key (doc, id_user, tablerow, tablenum),
  constraint fk_grid_labels_user foreign key (id_user) references adm_users(id)
);  


create or replace procedure P_SetGridLabel(
--������������� ������ ��� ��������� ������ �����, �� ������� formdoc ��� ����������� ������ ������� ����� � ������
--plabelnum ��������� ��� (����) ����� � �������
--���� �������� ������ < 0, �� ��������� ��� ����� ��� ������ �������
  pdoc varchar,
  pid_user number,
  ptablerow number,
  ptablenum number,
  plabelnum number
) is 
  c number;
begin
  if ptablerow < 0 then
    delete from grid_labels where doc = pdoc and id_user = pid_user and tablenum = ptablenum;
  elsif nvl(plabelnum, 0) = 0 then
    delete from grid_labels where doc = pdoc and id_user = pid_user and tablerow = ptablerow and tablenum = ptablenum;
  else
    select count(*) into c from grid_labels where doc = pdoc and id_user = pid_user and tablerow = ptablerow and tablenum = ptablenum;
    if c = 0 then
      insert into grid_labels (doc, id_user, tablerow, tablenum, labelnum) values (pdoc, pid_user, ptablerow, ptablenum, plabelnum);
    else  
      update grid_labels set labelnum = plabelnum where doc = pdoc and id_user = pid_user and tablerow = ptablerow and tablenum = ptablenum;
    end if;
  end if; 
end;
/

--------------------------------------------------------------------------------
--����������� ���������������� ������� ��� ���������� (�����, ������ � ��������, ��� ������� ������������ �������������)
create table grid_filters (
  doc varchar(100),                            --formdoc
  id_user number(11),                          --���� �����
  name varchar(100),                           --������������ �������
  comm varchar(400),                           --������������ �����������
  filter clob,                                 --��������� ������������� �������
  tablenum number,                             --����� ������� � ���������
  constraint pk_grid_filters primary key (doc, id_user, tablenum, name),
  constraint fk_grid_filters_user foreign key (id_user) references adm_users(id) on delete cascade
);  
  


--------------------------------------------------------------------------------
alter table adm_db_log add osuser varchar2(100);
create table adm_db_log (  
  id number(11),
  osuser varchar2(100),
  itemname varchar2(100),
  comm varchar2(4000),
  dt date,
  constraint pk_adm_db_log primary key (id)
);   

create sequence sq_adm_db_log nocache;

create or replace trigger trg_adm_db_log_bi_r
  before insert on adm_db_log for each row
begin
  select sq_adm_db_log.nextval into :new.id from dual;
  select sysdate into :new.dt from dual;
  select v.osuser into :new.osuser from v$session v where v.sid = (select sid from v$mystat where rownum=1);
end;
/

--select v.osuser  from v$session v where v.sid = (select sid from v$mystat where rownum=1);
--select sid from v$mystat where rownum=1;

--------------------------------------------------------------------------------
--++
-- ��� ������ (�������������� ��������) � ���������� � ��������������
alter table adm_error_log add fullreportc clob;
alter table adm_error_log add pictc clob;
alter table adm_error_log add ide number(1) default 0;
--drop table adm_error_log cascade constraints;
create table adm_error_log (  
  id number(11),
  id_module number(2),          --���� �������, � ������� ���� ������
  compile_dt varchar(40),       --���� ���������� ������
  ver varchar(40),              --������ ������
  dt date,                      --����/����� �������
  userlogin varchar2(100),      --����� ������������ � �����
  mashineinfo varchar2(400),    --��� ������/������������
  message varchar2(4000),       --��������� �� ������
  sql varchar2(4000),           --����� ���-�������, ���� ������ ������� ����������� �������
  sqlparams varchar2(4000),     --��� ��������� 
  stack varchar2(4000),         --���� ������� ����� �������
  general varchar2(4000),       --����� ����������
  handled varchar2(100),        --��� �������
  comm varchar2(4000),          --�����������, �������� � ������������ �����
  pictc clob,                   --��������
  fullreportc clob,             --������ ����� (��, ��� �� ��������� ����������� � ����)
  ide number(1) default 0,      --���� 1, �� ������ ��������� ��� ������ ��� ��� 
  constraint pk_adm_error_log primary key (id)
);  

truncate table adm_error_log; 

create index idx_adm_error_log_dt on adm_error_log(dt);
create index idx_adm_error_log_dt_login on adm_error_log(dt, userlogin);

create sequence sq_adm_error_log nocache;

create or replace trigger trg_adm_error_log_bi_r
  before insert on adm_error_log for each row
begin
  select sq_adm_error_log.nextval into :new.id from dual;
--  select sysdate into :new.dt from dual;
end;
/

create or replace view v_adm_error_log as select
  l.*,
  u.name as username,
  u.name || '(' || userlogin || ')' as userloginandname,
  m.nameru as modulename
from
  adm_error_log l,
  adm_users u,
  adm_modules m
where
  l.userlogin = u.login (+) and
  l.id_module = m.id (+)
;

create or replace procedure P_To_Adm_Error_Log(
  pdt date,
  puserlogin varchar2,
  pid_module number,
  pver varchar2,
  pcompile_dt varchar2,
  pmashineinfo varchar2,
  pmessage varchar2,
  psql varchar2,
  psqlparams varchar2,
  pgeneral varchar2,
  pstack varchar2,
  phandled varchar2,
  ppictc clob,
  pfullreportc clob,
  pide number
)
is
 pragma autonomous_transaction;
begin
 insert into adm_error_log 
   (dt, userlogin, id_module, ver, compile_dt, mashineinfo, message, sql, sqlparams, general, stack, handled, pictc, fullreportc, ide) 
     values 
   (pdt, puserlogin, pid_module, pver, pcompile_dt, pmashineinfo, pmessage, psql, psqlparams, pgeneral, pstack, phandled, ppictc, pfullreportc, pide);
  commit;
end;
/

create or replace function F_To_Adm_Error_Log(
  pdt date,
  puserlogin varchar2,
  pid_module number,
  pver varchar2,
  pcompile_dt varchar2,
  pmashineinfo varchar2,
  pmessage varchar2,
  psql varchar2,
  psqlparams varchar2,
  pgeneral varchar2,
  pstack varchar2,
  phandled varchar2,
  ppictc clob,
  pfullreportc clob,
  pide number
)
return number
is
  pragma autonomous_transaction;
begin
  insert into adm_error_log 
   (dt, userlogin, id_module, ver, compile_dt, mashineinfo, message, sql, sqlparams, general, stack, handled, pictc, fullreportc, ide) 
     values 
   (pdt, puserlogin, pid_module, pver, pcompile_dt, pmashineinfo, pmessage, psql, psqlparams, pgeneral, pstack, phandled, ppictc, pfullreportc, pide);
  commit;
  return 1;
end;
/     


     

  
--------------------------------------------------------------------------------
-- ��� ��������� �������
--(��������� ������ �������������� ����� ������ �����������������)
create table adm_install_log (  
  id number(11),
  id_module number(2),          --���� �������, � ������� ���� ������
  dt date,                      --����/����� �������
  compile_dt varchar(40),       --���� ���������� ������
  ver varchar(40),              --������ ������
  comm varchar2(4000),          --�����������, �������� � ������������ �����
  constraint pk_adm_install_log primary key (id)
);   

create sequence sq_adm_install_log nocache;

create or replace trigger trg_adm_install_log_bi_r
  before insert on adm_install_log for each row
begin
  select sq_adm_install_log.nextval into :new.id from dual;
  select sysdate into :new.dt from dual;
end;
/

--------------------------------------------------------------------------------
-- ��������� ������� ����������, � ����������� ��� � ���, �� ��������������� �������
-- ���� ��������������� ����� �� ����� ������� � ���������, �� ����� ����� � �������
-- �����, ���� �������� �������� ������, ����� �������������

create table docum_numbers (
  docum varchar2(400),          --��� ���������
  year number(4),               --���, 4 �����
  num number,                   --��������� ����������� �����
  constraint pk_docum_numbers primary key (docum, year)
);

create unique index idx_docum_numbers on docum_numbers(docum, year, num);

create or replace procedure P_GetDocumNum(
--�������� ����� ��������� �� ��� ���������� ���� � ����
  ADocum varchar,
  AYear number,
  ANum out varchar2,           --���������
  ANoStore number default 0,   --������ ���������, �� �� ��������� ������� � ������� (��������� ���������)
  AYPrefix number default 0,   --��������� ������� ���������� ������� YY 
  ADigits  number default 0    --������� ��������� �� ADigits �������� (��� ����� ����)  
)  
as
begin
  ANum := '0';
  begin
    select num into ANum from docum_numbers where docum = ADocum and year = AYear;
  exception
    when no_data_found then
    insert into docum_numbers (docum, year, num) values (ADocum, AYear, 0);
  end;
  select to_char(num + 1) into ANum from docum_numbers where docum = ADocum and year = AYear;
  if ANoStore = 0 then
    update docum_numbers set num = nvl(num, 0) + 1 where docum = ADocum and year = AYear;
  end if;
  if ADigits <> 0 then
    ANum := substr('00000000' || ANum, -ADigits);  
  end if;
  if AYPrefix <> 0 then
    ANum := substr(to_char(AYear), 3) || ANum;  
  end if;
end;
/


--------------------------------------------------------------------------------
--������� ��� ������������ ������ (��������)
create table properties (  
prop varchar2(100),               --������������ ��������, �����������
subprop varchar2(100),            --���������� ������������ (�����������), ����������� 
st varchar2(200),                 --���� ������ �������� (������, ����, ����� �����, ����� � ������)
dt date,
i number,
f number (38,10),
constraint pk_properties primary key (prop, subprop)
);

create or replace procedure P_SetProp(
--���������� ������������ �������� (����������� ������������ �������� � �����������)
  AProp varchar2,
  ASubProp varchar2,
  ASt varchar2 default null,
  ADt date default null,
  AI number default null,
  AF number default null
)  
as
  n number; 
begin
  select count(*) into n from properties where prop = AProp and subprop = ASubProp;
  if n = 0 then
    insert into properties (prop, subprop) values (AProp, ASubProp);
  end if;
  update properties set st = ASt, dt = ADt, i = AI, f = AF where prop = AProp and subprop = ASubProp;
end;
/




--------------------------------------------------------------------------------
--������� ���� �������� ������������� ��� �����, �������� �������������, � ������� ���� ����� �� ��������
--����� ����� ������ ��� ���� ��������/���������� ����������, � ��-������� ����������������
--������������� ���� ���� � ������������� ��� ������ ���� id_operation 
--������ � ��� ��������� ������� ��������� P_ToUchetLog �� �� ��� ����������, ������������ � ����� ������� ������������ �������������
alter table adm_uchet_log add dt2 date; 
create table adm_uchet_log (  
  id number(11),
  dt date,                         --���� (������� �����)
  id_user number(11),              --���� ������������ �����
  id_operation number(11),         --���� �������� (��� �� ��� ����) 
  id_operation_add number(11),
  id_document number(11),
  id_document_item number(11),
  qnt1 number(20,6),
  qnt2 number(20,6),
  dt1 date,
  dt2 date,
  comm1 varchar2(4000),
  comm2 varchar2(4000),
  constraint pk_adm_uchet_log primary key (id)
);   

create sequence sq_adm_uchet_log nocache;

create or replace trigger trg_adm_uchet_log_bi_r
  before insert on adm_uchet_log for each row
begin
  select sq_adm_uchet_log.nextval into :new.id from dual;
end;
/



create or replace view v_adm_uchet_log as
--��� ���� �������� ������������� ��� �����
select
  ul.*,
  --���� ��� ������� 
  trunc(ul.dt) as dt_day,
  --��� ������������
  u.name as username,
  --������������ �������� ��������/���� ����
  decode(id_operation, 2, '������ �� ���', 3, '�������� � ���', 4, '������ ���', '[������]') as operation,
  --��������� �������� ���������, � �������� ��������� ��������, ������ �� id_operation 
  case when ul.id_operation in (2,3, 4) then
    --��� ������ ����������� ������ (������� order_item_stages) - ���� � ������������ �������
    (select slash || ' ' || name from v_order_item_names where id = id_document)
    --null
  else
    null    
  end as document
from
  adm_uchet_log ul,
  adm_users u
where
  ul.id_user = u.id (+)
;   

select * from v_adm_uchet_log;   

create or replace function F_GetCurrentUser
--���������� ���� ������������ ��������� ����, ������� ������������� � �������  ������
return number
is
  FSid number(20);             
  FSerial number(20);
  FIdUser number(11);
begin
  begin 
    --������� sid � serial ��� ������� ������ 
    select sid, serial# into FSid, FSerial from v$session where sid in (select sid from v$mystat where rownum = 1);
    --���� � ������� ����� ������ ����� ��������� ������ ��� ������ ������
    select id_user into FIdUser from (select id_user from adm_user_sessions where sid = FSid and serial# = FSerial order by id desc) where rownum = 1;
  exception 
    when no_data_found then
      Return null;
  end;
  Return FIdUser;
end;
/   

select F_GetCurrentUser from dual;
select rownum, id_user from (select id_user from adm_user_sessions where sid = 72 and serial# = 401 order by id desc) where rownum = 1;

/*
  1..9 - ��������� � order_item_stages
  AIdOperation=id_stage, AIdDocument=id_order_item, qnt1
*/
create or replace procedure P_ToUchetLog (
--���������� ������, ���������� � ����������, � ���
--���� � ���� ������������ ����� ��� ����������
  AIdOperation in number,
  AIdOperationAdd in number,
  AIdDocument in number,
  AIdDocumentItem in number,
  AQnt1 in number,
  AQnt2 in number,
  ADt1 in date,
  ADt2 in date,
  AComm1 in varchar2,
  AComm2 in varchar2
)
is
begin
  execute immediate 
    'insert into adm_uchet_log (id_user, dt, id_operation, id_operation_add, id_document, id_document_item, qnt1, qnt2, dt1, dt2, comm1, comm2) ' ||
    'values (F_GetCurrentUser, SysDate, :id_operation, :id_operation_add, :id_document, :id_document_item, :qnt1, :qnt2, :dt1, :dt2, :comm1, :comm2)'
  using 
    AIdOperation, AIdOperationAdd, AIdDocument, AIdDocumentItem, AQnt1, AQnt2, ADt1, ADt2, AComm1, AComm2;
end;
/

exec P_ToUchetLog(0, null, null, null, -20, null, sysdate, null, 'test2', null);

--------------------------------------------------------------------------------
-- ���������� ���������������� ��������
alter table ref_production_areas add itm_suffix varchar(10);
create table ref_production_areas (
  id number(1),                      --���� ��������
  name varchar(20),                  --������ �����������
  shortname varchar(5),              --����������� ������������
  order_prefix varchar(5),           --������� ��� ��������� ������ �� �����
  itm_suffix varchar(10),            --������� ��� ������� �������� � ��� � ������� sklad, ���� skladname  
  active number(1)                   --������������
); 

insert into ref_production_areas (id, name, shortname, order_prefix, active) values (0, '����� �������', '��', '', 1);  
insert into ref_production_areas (id, name, shortname, order_prefix, active) values (1, '����������', '�', '�', 1);  
insert into ref_production_areas (id, name, shortname, order_prefix, active) values (2, '���������', '��', '��', 1);  
insert into ref_production_areas (id, name, shortname, order_prefix, itm_suffix, active) values (3, '������ ���������', '��', '��', '��', 1);  

