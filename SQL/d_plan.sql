alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;

--таблица по типам производственных участков
--alter  table work_cell_types add color number;
--drop table work_cell_types cascade constraints; 
create table work_cell_types (
  id number(11),
  name varchar(100),  --полное наименование типа участков
  code varchar(4),    --код 
  pos number(4),      --позиция, для производственных 
  posstd number(4),   --позиция, для стандартных участков, заданных вручную (не нулл является их признаком; отрицательная - после производственных, -1 сразу, -2 дальше)
  refers_to_prod_area number(1) default 0,
  active number(1), 
  color number,
  constraint pk_work_cell_types primary key (id)
);   

create unique index idx_work_cell_types_name on work_cell_types lower(name);
create unique index idx_work_cell_types_code on work_cell_types lower(code);
  
create sequence sq_work_cell_types nocache start with 100;

create or replace trigger trg_work_cell_types_bi_r
  before insert on work_cell_types for each row
begin
  if :new.id is null then 
    :new.id := sq_work_cell_types.nextval;
    :new.refers_to_prod_area := 1;
    :new.pos := :new.id;
  end if;
end;
/

--времменный запрос, возьмем цвета из регламента
--update work_cell_types t set color = (select max(color) from order_reglament_items r where r.id_work_cell_type = t.id);
update order_reglament_items t set color = (select color from work_cell_types r where t.id_work_cell_type = r.id) where color = 0;



/*
begin
insert into work_cell_types (id, name, code, posstd, refers_to_prod_area, active) values (1, 'Конструктора', 'КНС', 1, 0, 1);
insert into work_cell_types (id, name, code, posstd, refers_to_prod_area, active) values (2, 'Технологи', 'ТХН', 2, 0, 1);
insert into work_cell_types (id, name, code, posstd, refers_to_prod_area, active) values (3, 'Снабжение', 'СН', 3, 0, 1);
insert into work_cell_types (id, name, code, posstd, refers_to_prod_area, active) values (4, 'ОТК', 'ОТК', -1, 0, 1);
insert into work_cell_types (id, name, code, posstd, refers_to_prod_area, active) values (5, 'СГП', 'СГП', -2, 0, 1);
end;
/
*/


create or replace view v_work_cell_types as
  select 
    t.*,
    case 
      when posstd is null then pos
      when nvl(posstd, 0) > 0 then posstd
      when nvl(posstd, 0) < 0 then 10000 - posstd
    end as posall
  from 
    work_cell_types t
;  

select * from v_work_cell_types;


--таблица производственных участков
create table work_cells (
  id number(11),
  id_type number(11),
  id_area number(11),
  name varchar(400),
  constraint pk_work_cells primary key (id),
  constraint fk_work_cells_type foreign key (id_type) references work_cells_types(id),
  constraint fk_work_cells_area foreign key (id_area) references ref_production_areas(id)
);   

create unique index idx_work_cells_name on work_cell_types lower(name);
  
create sequence sq_work_cells nocache start with 100;

create or replace trigger trg_work_cells_bi_r
  before insert on work_cell_s for each row
begin
  select sq_work_cells.nextval into :new.id from dual;
end;
/ 


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

drop table pdo_order_stage_dates cascade constraints;
create table pdo_order_stage_dates (
  id number(11),
  constraint pk_pdo_order_stage_dates primary key (id),
  constraint fk_pdo_order_stage_dates_id foreign key (id) references order_items(id) on delete cascade
);  
  
drop table pdo_order_stage_dates_items cascade constraints;
create table pdo_order_stage_dates_items (
  --id number(11),
  id_dates number(11),
  id_stage number(11),
  dt_plan date,
  dt_fact date,
--  constraint pk_pdo_order_stage_dates_items primary key (id),
  constraint pk_pdo_order_stage_dates_items primary key (id_dates, id_stage),
  constraint fk_pdo_order_stage_dates_i_1 foreign key (id_dates) references pdo_order_stage_dates(id) on delete cascade
);  



create or replace view v_rep_orders_overdue_kns_thn as 
select
--отчет по соблюдению сроков обработки заказов конструкторами и технологами
  oi.slash,
  o.dt_beg,
  o.dt_otgr,
  o.project,
  o.customer,
  oi.itemname,
  'Конструктор' as type,
  u.name,
  u.id as id_user,
  o.dt_beg + ri.day_end as dt_by_reglament,
  oi.dt_kns as dt_fact,
  -(nvl(oi.dt_kns, trunc(sysdate)) - (o.dt_beg + ri.day_end)) as overdue_days 
from
  v_orders o,
  v_order_items oi,
  adm_users u,
  order_reglaments r,
  order_reglament_items ri
where
  nvl(oi.id_kns, -1) > 0
  and o.id_reglament is not null 
  and oi.id_order = o.id
  and o.id_reglament = r.id
  and ri.id_reglament = r.id and ri.id_work_cell_type = 1
  and u.id = oi.id_kns and u.id > 0
union all  
select
  oi.slash,
  o.dt_beg,
  o.dt_otgr,
  o.project,
  o.customer,
  oi.itemname,
  'Технолог' as type,
  u.name,
  u.id as id_user,
  o.dt_beg + ri.day_end as dt_by_reglament,
  oi.dt_thn as dt_fact,
  -(nvl(oi.dt_thn, trunc(sysdate)) - (o.dt_beg + ri.day_end)) as overdue_days 
from
  v_orders o,
  v_order_items oi,
  adm_users u,
  order_reglaments r,
  order_reglament_items ri
where
  nvl(oi.id_thn, -1) > 0
  and o.id_reglament is not null 
  and oi.id_order = o.id
  and o.id_reglament = r.id
  and ri.id_reglament = r.id and ri.id_work_cell_type = 2
  and u.id = oi.id_thn and u.id > 0 
;       