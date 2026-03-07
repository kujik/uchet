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
drop table prod_calc_items cascade constraints;
create table prod_calc_items(
  id number(11),
  id_prod_calc number(11),   
  name varchar2(400),  
  purchase_sum number,             --общая сумма закупки
  markup_percent number,           --запас цены, %
  overall_coeff number,            --общий коэффициент, число
  sales_sum number,                --продажа  
  sales_sum_from_items number,     --продажа по расчету (суммарная из таблиц)  
  coeff_from_items number,         --коэффициент по расчету  
  comm varchar2(400),              --комментарий
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
  i.*,
  c.project,
  c.customer
  --round(i.purchase_sum * (i.markup_percent / 100) * overall_coeff) as product_sales_sum,
  --i.sales_sum_from_items / nullif(purchase_sum,0)  as coeff_from_items
from
  prod_calc_items i,
  prod_calc c
where
  i.id_prod_calc = c.id  
;


--------------------------------------------------------------------------------
--справочники для просчетов (узлы изделия, пипы панелей)
create table prod_calc_refs(
  id number(11),
  type varchar2(40),
  name varchar2(200),    
  active number(1) default 1,
  constraint pk_prod_calc_refs primary key (id)
);

create index idx_prod_calc_refs_uq on prod_calc_refs(lower(type), lower(name)); 

create sequence sq_prod_calc_refs start with 1 nocache;

create or replace trigger trg_prod_calc_refs_bi_r before insert on prod_calc_refs for each row
begin
  select nvl(:new.id, sq_prod_calc_refs.nextval) into :new.id from dual;
end;
/

begin
  insert into prod_calc_refs (type, name) values ('', ''); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Фриз'); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Основание'); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Средняя часть'); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Колпак'); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Цоколь'); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Фасад'); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Крыша'); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Подиум'); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Столешница'); 
  insert into prod_calc_refs (type, name) values ('assembly', 'Экран'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Вертикаль'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Горизонталь'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Фасад'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Столешница'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Полка'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Тяга'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Стойка'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Цоколь'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Задняя стенка'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Подиум'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Крыша'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Дно'); 
  insert into prod_calc_refs (type, name) values ('panel_type', 'Экран'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Левая'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Правая'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Задняя'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Передняя'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Верхняя'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Нижняя'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Средняя'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Внутренняя'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Боковая'); 
  insert into prod_calc_refs (type, name) values ('panel_position', 'Лицевая'); 
end;
/

--------------------------------------------------------------------------------
drop table prod_calc_boards cascade constraints;
create table prod_calc_boards(
  id number(11),
  id_prod_calc_item number(11),
  pos number,
  id_name number,
  info varchar2(400),
  assembly varchar2(100),
  panel_type varchar2(100),
  panel_position varchar2(100),
  length number,
  width number,
  waste number,
  price0 number,
  qnt number,
  markup number,     
  id_facing_name number,
  facing_length number,
  facing_width number,
  facing_waste number,
  facing_id_banding_type number,
  facing_price0 number,
  facing_qnt number,
  facing_markup number,     
  constraint pk_prod_calc_boards primary key (id),
  constraint fk_prod_calc_boards_pci foreign key (id_prod_calc_item) references prod_calc_items(id) 
);

create sequence sq_prod_calc_boards start with 1 nocache;

create or replace trigger trg_prod_calc_boards_bi_r before insert on prod_calc_boards for each row
begin
  select nvl(:new.id, sq_prod_calc_boards.nextval) into :new.id from dual;
end;
/

create or replace view v_prod_calc_boards as select
  t.*,
  n.name
from   
 prod_calc_boards t,
 dv.nomenclatura n
where
  t.id_name = n.id_nomencl
;   
 
--------------------------------------------------------------------------------
create table prod_calc_edges(
  id number(11),
  id_prod_calc_item number(11),
  pos number,
  id_name number,
  assembly varchar2(100),
  info varchar2(400),
  price0 number,
  consumption number,
  markup number,     
  constraint pk_prod_calc_edges primary key (id),
  constraint fk_prod_calc_edges_pci foreign key (id_prod_calc_item) references prod_calc_items(id) 
);

create sequence sq_prod_calc_edges start with 1 nocache;

create or replace trigger trg_prod_calc_edges_bi_r before insert on prod_calc_edges for each row
begin
  select nvl(:new.id, sq_prod_calc_edges.nextval) into :new.id from dual;
end;
/

create or replace view v_prod_calc_edges as select
  t.*,
  n.name
from   
 prod_calc_edges t,
 dv.nomenclatura n
where
  t.id_name = n.id_nomencl
;   


--------------------------------------------------------------------------------
create table prod_calc_profiles(
  id number(11),
  id_prod_calc_item number(11),
  pos number,
  id_name number,
  assembly varchar2(100),
  info varchar2(400),
  price0 number,
  length number,
  waste number,
  qnt number,
  markup number,     
  constraint pk_prod_calc_profiles primary key (id),
  constraint fk_prod_calc_profiles_pci foreign key (id_prod_calc_item) references prod_calc_items(id) 
);

create sequence sq_prod_calc_profiles start with 1 nocache;

create or replace trigger trg_prod_calc_profiles_bi_r before insert on prod_calc_profiles for each row
begin
  select nvl(:new.id, sq_prod_calc_profiles.nextval) into :new.id from dual;
end;
/

create or replace view v_prod_calc_profiles as select
  t.*,
  n.name
from   
 prod_calc_profiles t,
 dv.nomenclatura n
where
  t.id_name = n.id_nomencl
;   


--------------------------------------------------------------------------------
create table prod_calc_furniture(
  id number(11),
  id_prod_calc_item number(11),
  pos number,
  id_name number,
  assembly varchar2(100),
  info varchar2(400),
  price0 number,
  consumption number,
  markup number,     
  constraint pk_prod_calc_furniture primary key (id),
  constraint fk_prod_calc_furniture_pci foreign key (id_prod_calc_item) references prod_calc_items(id) 
);

create sequence sq_prod_calc_furniture start with 1 nocache;

create or replace trigger trg_prod_calc_furniture_bi_r before insert on prod_calc_furniture for each row
begin
  select nvl(:new.id, sq_prod_calc_furniture.nextval) into :new.id from dual;
end;
/

create or replace view v_prod_calc_furniture as select
  t.*,
  n.name
from   
 prod_calc_furniture t,
 dv.nomenclatura n
where
  t.id_name = n.id_nomencl
;   


--------------------------------------------------------------------------------
create table prod_calc_electric(
  id number(11),
  id_prod_calc_item number(11),
  pos number,
  id_name number,
  assembly varchar2(100),
  info varchar2(400),
  price0 number,
  consumption number,
  markup number,     
  constraint pk_prod_calc_electric primary key (id),
  constraint fk_prod_calc_electric_pci foreign key (id_prod_calc_item) references prod_calc_items(id) 
);

create sequence sq_prod_calc_electric start with 1 nocache;

create or replace trigger trg_prod_calc_electric_bi_r before insert on prod_calc_electric for each row
begin
  select nvl(:new.id, sq_prod_calc_electric.nextval) into :new.id from dual;
end;
/

create or replace view v_prod_calc_electric as select
  t.*,
  n.name
from   
 prod_calc_electric t,
 dv.nomenclatura n
where
  t.id_name = n.id_nomencl
;   

