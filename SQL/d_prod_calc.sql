/*
просчеты изделий для менеджеров
*/

--------------------------------------------------------------------------------

--таблица просчетов
create table prod_calc(
  id number(11),
  id_manager number(11),   --айди менеджера, создавшего просчет
  customer varchar2(400),  --клиент   
  project varchar2(400),   --проект 
  dt date,                 --дата создания просчета  
  comm varchar2(400),      --комментарий
  constraint pk_prod_calc primary key (id),
  constraint fk_prod_calc_manager foreign key (id_manager) references adm_users(id)
);

create index idx_prod_calc_customer on prod_calc(customer); 
create index idx_prod_calc_project on prod_calc(project); 
create index idx_prod_calc_uq on prod_calc(lower(project), lower(customer)); 
create index idx_prod_calc_dt on prod_calc(dt); 

create sequence sq_prod_calc start with 1 nocache;

create or replace trigger trg_prod_calc_bi_r before insert on prod_calc for each row
begin
  select nvl(:new.id, sq_prod_calc.nextval) into :new.id from dual;
end;
/

create or replace view v_prod_calc as
select
  c.*,
  u.name as manager
from
  prod_calc c,
  adm_users u
where
  c.id_manager = u.id (+) 
;     
  

--------------------------------------------------------------------------------

--таблица изделий по проекту (просчету)

create table prod_calc_items(
  id number(11),
  id_prod_calc number(11),   
  name varchar2(400),  
  price number,   
  comm varchar2(400),      --комментарий
  constraint pk_prod_calc_items primary key (id),
  constraint fk_prod_calc_items_parent foreign key (id_prod_calc) references prod_calc(id) on delete cascade
);

create index idx_prod_calc_items_parent on prod_calc_items(id_prod_calc); 

create sequence sq_prod_calc_items start with 1 nocache;

create or replace trigger trg_prod_calc_items_bi_r before insert on prod_calc_items for each row
begin
  select nvl(:new.id, sq_prod_calc_items.nextval) into :new.id from dual;
end;
/

create or replace view v_prod_calc_items as
select
  i.*
from
  prod_calc_items i
;  

