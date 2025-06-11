alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';



--���������� ������
create table ref_colors(
  id number(12),                      --����
  article varchar2(20) not null,      --�������, �������� � ��������� �� ���������
  name varchar2(400) not null,        --������������, �������� � ��������� �� ���������
  constraint pk_ref_colors primary key (id)
);
create unique index idx_ref_colors_name on ref_colors(lower(name));
create unique index idx_ref_colors_article on ref_colors(lower(article));

create sequence sq_ref_colors start with 1 nocache;


create table pick_general_fittings(
  id number(12),                      --����
  article varchar2(20) not null,      --�������, �������� � ��������� �� ���������
  name varchar2(400) not null,        --������������, �������� � ��������� �� ���������
  constraint pk_pick_general_fittings primary key (id)
);
create unique index idx_pick_general_fittings_name on pick_general_fittings(lower(name));
create unique index idx_pick_general_fittings_art on pick_general_fittings(lower(article));

create sequence sq_pick_general_fittings start with 1 nocache;

  

--������ ����������� �������
--������������ �� �������� �� �����
create table pick_item_groups(
  id number(12),                      --����
  name varchar2(400) not null,        --������������ ������
  constraint pk_pick_item_groups primary key (id)
);

create sequence sq_pick_item_groups start with 1 nocache;


--����������� �������   
--(������� �� ������� ������������)
--drop table pick_items cascade constraints;
--alter table pick_items drop column weight; 
--alter table pick_items add weight number(7,1); 
create table pick_items(
  id number(12),                      --����
  id_group number(12),                --���� ������
  article varchar2(400) not null,     --�������, ��������� � ��������� �� �������� 
  name varchar2(400) not null,        --������������, �� ���������! 
  id_color number(12),                --���� �����
  description varchar2(400) not null, --��������
  weight number(7,1),                 --��� � ��, � ��������
  wi number(10),                      --������, �������, ������ ������� � ��                 
  di number(10), 
  hi number(10), 
  wp number(10),                      --������, �������, ������ �������� � ��
  dp number(10), 
  hp number(10), 
  file1 varchar2(400) not null,       --basename ����� ������ �� �������
  dt1 date,                           --���� �������� ����� ������ �� ������� 
  file2 varchar2(400),                --���� ��� ������������
  dt2 date,                           --���� �������� ��� ������������
  file3 varchar2(400),                --���� ����� ���������
  dt3 date,                           --���� �������� 
  code varchar2(20),                  --�����-��� �������, �� �������
  filepath varchar2(25),              --������� � ������� (��������� �����)
  active number(1),                   --����������
  constraint pk_pick_items primary key (id),
  constraint fk_pick_items_id_group foreign key (id_group) references pick_item_groups(id),
  constraint fk_pick_items_id_color foreign key (id_color) references ref_colors(id)
);

--drop index idx_pick_items_name;
--alter table pick_items modify file2 null;
alter table pick_items add file3 varchar2(400);
alter table pick_items add dt3 date;
alter table pick_items add filepath varchar2(25);

--create unique index idx_pick_items_name on pick_items(lower(name));
create unique index idx_pick_items_article on pick_items(lower(article));
create sequence sq_pick_items start with 1 nocache;


--������� ������� ��� ������� ������� ������������
--������� �� ����� ������ ������
--�� �������� ������� ���������� ������� ��� ��������, ������ ��������� � ������ �������������� ������� ������
--drop table pick_panels cascade constraints; 
create table pick_panels(
  id_item number(12),         --���� � ����������� ������
  id number(12),              --�����
  name varchar2(400),         --������������ 
  code varchar2(20),          --��
  qnt number(4),
  constraint pk_pick_panels primary key (id),
  constraint fk_pick_panels_id_item foreign key (id_item) references pick_items(id) on delete cascade
);

create sequence sq_pick_panels start with 1 nocache;


--������� ��� ������������ ������� 
--drop table pick_addcompl cascade constraints; 
create table pick_addcompl(
  id number(12),
  id_item number(12),
  name varchar2(400),
  code varchar2(20),
  qnt number(4),
  constraint pk_pick_addcompl primary key (id),
  constraint fk_pick_addcompl_id_item foreign key (id_item) references pick_items(id) on delete cascade
);

create sequence sq_pick_addcompl start with 1 nocache;


create table pick_fittings(
  id_item number(12),         --���� � ����������� ������
  id_fitting number(12),      --����� � ����������� �������������
  qnt number(4),
  constraint pk_pick_fittings primary key (id_item, id_fitting),
  constraint fk_pick_fittings_id_item foreign key (id_item) references pick_items(id) on delete cascade,
  constraint fk_pick_fittings_id_fitting foreign key (id_fitting) references pick_general_fittings(id)
);


--������� ��� ������������ ������� 
--drop table pick_log cascade constraints; 
create table pick_log(
  id number(12),
  id_item number(12),
  id_user number(12),
  dtbeg date,
  dtend date,
  constraint pk_pick_log primary key (id),
  constraint fk_pick_log_id_item foreign key (id_item) references pick_items(id),
  constraint fk_pick_log_id_user foreign key (id_user) references adm_users(id)
);

create sequence sq_pick_log start with 1 nocache;

--��������� ������
--drop table pick_cfg; 
create table pick_cfg (
  id number(12),
  pick_font_size number,
  path_to_files varchar2(4000)
);  

insert into pick_cfg (id) values (1);
update pick_cfg set pick_font_size = 14, path_to_files = '\\10.1.1.14\Uchet\����\Files\������������';  



create or replace view v_pick_fittings as (
  select
    f.*,
    pf.*
  from 
    pick_general_fittings pf,
    pick_fittings f
  where
    pf.id = f.id_fitting
);   
  


--��� ����������� �������
--������������ ����� ������������ ������ � ������������ �����
create or replace view v_pick_items as (
  select 
    pi.*,
    g.name as groupname,
    c.name as colorname
  from
    pick_items pi,
    ref_colors c,
    pick_item_groups g
  where
    pi.id_group = g.id and
    pi.id_color = c.id    
);    

--��� ��� ����������� ����� ������������
create or replace view v_pick_log as (
  select 
    pl.*,
    (pl.dtend - pl.dtbeg)*24 as worktimeh,              --����� � �����
    (pl.dtend - pl.dtbeg)*24*60 as worktimem,            --����� ������������ � �������
    to_char(pl.dtbeg, 'HH24:MI:SS') as timebeg,          --����� ������ ���������������� ������ ��� ����
    to_char(pl.dtend, 'HH24:MI:SS') as timeend,          --����� ���������
    trunc(pl.dtbeg) as dt,
    u.name as username,
    i.name as itemname,
    i.article as itemarticle,
    (select sum(p.qnt) from pick_panels p where pl.id_item = p.id_item)  
     + 
    (select sum(p.qnt) from pick_panels p where pl.id_item = p.id_item) as pancnt  
  from
    pick_log pl,
    adm_users u,
    pick_items i
  where
    pl.id_user = u.id and
    pl.id_item = i.id
);


        

select * from v_pick_log;

select max(id) as id, max(username) as username, max(itemarticle) as itemarticle, max(itemname) as itemname, count(1) as cnt from v_pick_log where id_user = 33 group by id_item;

select extract (MONTH FROM to_date('22.08.2019 16:04:21')) FROM DUAL;

select trunc(to_date('22.08.2019 16:04:21')) FROM DUAL;


select id, filename, username, organization, expenseitem, supplier, account, accountdt, acctype, dt, regdays, accsum, paidsum, debt, comm, paimentstatus, agreed1, agreed2 from v_sn_calendar_accounts where accountdt> '11.05.2022';
select id, 0, null, qnt, 0 as scanqnt from v_pick_fittings;