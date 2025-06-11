

--свои организации дл€ использовани€ в и таблицах снабжени€
--alter table ref_sn_organizations drop column is_customer;
alter table ref_sn_organizations add nds number(1);
create table ref_sn_organizations (
  id number(12),
  name varchar(30),        --наименование
  requisites varchar(100), --реквизиты
  active number(1),        --активность
  is_buyer number(1),   --€вл€етс€ покупателем (1) 
  is_seller number(1),   --€вл€етс€ продавцом (1)
  prefix varchar(10),      --префикс дл€ заказов
  or_cashless number(1),   --в заказах допускаетс€ только безналичный расчет (1)
  nds number(1),           --в заказах, выделать Ќƒ—
  constraint pk_ref_sn_organizations primary key (id)
);  

create unique index idx_ref_sn_organizations_name on ref_sn_organizations(lower(name));

create sequence sq_ref_sn_organizations start with 4 nocache;


--адреса дл€ транспортных счетов
--не делаем регистронезависимый индекс
--drop table ref_sn_locations; 
create table ref_sn_locations (
  id number(12),
  name varchar(400), --наименование
  type number(1) default 0,   --0 - наше расположение, 1 - в счетах по транпорту “ќ, 2- - счетах по транспорту —Ќ
  active number(1), --активность
  constraint pk_ref_sn_locations primary key (id)
);  

create unique index idx_ref_sn_locations_name on ref_sn_locations(name, type);

create sequence sq_ref_sn_locations start with 1 nocache;


--типы транспортных средств дл€ транспортных счетов
create table ref_sn_cartypes (
  id number(12),
  name varchar(100), --наименование
  active number(1), --активность
  constraint pk_ref_sn_cartypes primary key (id)
);

create unique index idx_ref_sn_cartypes_name on ref_sn_cartypes(lower(name));

create sequence sq_ref_sn_cartypes start with 1 nocache;




--журнал задач
drop  table j_tasks cascade constraints;
create table j_tasks (
  id number(11),
  id_user1 number(11),
  id_user2 number(11),
  dt date,
  dt_beg date,
  dt_planned date,
  dt_end date,
  id_state number(2),
  id_order number(11), 
  id_order_item number(11), 
  type varchar2(100),
  name varchar2(400),
  comm1 varchar2(4000),
  comm2 varchar2(4000),
  active number(1), --активность
  confirmed number(1),
  constraint pk_j_tasks primary key (id),
  constraint fk_j_tasks_user1 foreign key (id_user1) references adm_users(id),
  constraint fk_j_tasks_user2 foreign key (id_user2) references adm_users(id),
  constraint fk_j_tasks_order foreign key (id_order) references orders(id),
  constraint fk_j_tasks_order_item foreign key (id_order_item) references order_items(id)
);

drop index idx_user1_name;
create index idx_user1_name on j_tasks(id_user1, lower(type));

create sequence sq_j_tasks start with 1 nocache;

create or replace trigger trg_j_tasks_bi_r
  before insert on j_tasks for each row
begin
  select sq_j_tasks.nextval into :new.id from dual;
end;
/

create or replace view v_j_tasks as 
select
  t.*,
  decode(t.id_state, 1, 'нова€', 2, 'в работе', 3, 'остановлена', 4, 'на согласовании', 5, 'зависла', 99, 'готово', '') as state, 
  u1.name as user1,
  u2.name as user2,
  oi.ornum,
  oi.slash,
  oi.fullitemname,
  oi.project,
  oi.fullitemname as itemcaption,
  oi.ornum || ' ' || oi.project as orcaption
from
  j_tasks t,
  adm_users u1,  
  adm_users u2,
  v_order_items oi
where
  u1.id = t.id_user1 and u2.id = t.id_user2
  and oi.id_order (+) = t.id_order
  and oi.id (+) = t.id_order_item
;       

--------------------------------------------------------------------------------
drop table ref_test2;
create table ref_test2 as select * from or_projects;