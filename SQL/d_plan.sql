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


/*

ПРОИЗВОДСТВЕНЫЕ ОПЕРАЦИИ ПО СТАНДАРТНЫМ ИЗДЕЛИЯМ И ИЗДЕЛИЯМ В ЗАКАЗАХ 

*/

alter table pnl_ops_painting add no_ops number(1) default 1;
alter table pnl_ops_cnc      add no_ops number(1) default 1;
alter table pnl_ops_laser    add no_ops number(1) default 1;
alter table pnl_ops_drilling add no_ops number(1) default 1;

-------------------------------------------------------------------------------
--справочник производственных операций по покраске
create table pnl_ref_ops_painting (
  id number(11),
  name varchar(400),  --полное наименование операции
  pos number(4),      --позиция, для производственных
  norm number,        --норма времени на 1 м.кв., мин. 
  active number(1), 
  constraint pk_pnl_ref_ops_painting primary key (id)
);   

create unique index idx_pnl_ref_ops_painting on pnl_ref_ops_painting lower(name);
  
create sequence sq_pnl_ref_ops_painting nocache start with 100;

create or replace trigger trg_pnl_ref_ops_painting_bi_r 
before insert on pnl_ref_ops_painting for each row
begin
  :new.id := sq_pnl_ref_ops_painting.nextval;
  :new.pos := :new.id;
end;
/

-------------------------------------------------------------------------------
--производственных операций по покраске для стагндартных изделий и изделий в заказе

--родительская таблица
create table pnl_ops_painting (
  id number(11) primary key,            --айди
  id_std_item number(11),               --айди стандартного изделия
  id_order_item number(11),             --фйди изделия в заказе 
  dt_data_entered date,                 --дата, когда все данные были введены   
  dt_changed date,                      --дата изменения
  is_data_entered number(1) default 0,  --введены ли данные; 0 – не введены, 1 – введены
  no_ops number(1) default 1,           --нет операций по данному типу    
  constraint fk_ops_painting_id_std_item foreign key (id_std_item) references or_std_items(id) on delete cascade,
  constraint fk_ops_painting_id_order_item foreign key (id_order_item) references order_items(id) on delete cascade
);

create unique index idx_pnl_ops_painting_id_std_item on pnl_ops_painting (id_std_item);
create unique index idx_pnl_ops_painting_id_order_item on pnl_ops_painting (id_order_item);
create unique index idx_pnl_ops_painting_ids_std_order_item on pnl_ops_painting (id_std_item, id_order_item);


create sequence sq_pnl_ops_painting nocache start with 1;

create or replace trigger trg_pnl_ops_painting_bi_r 
before insert on pnl_ops_painting for each row
begin
  :new.id := sq_pnl_ops_painting.nextval;
end;
/

 
--сами операции для данной таблицы (изделия)
drop table pnl_ops_painting_items cascade constraints;
create table pnl_ops_painting_items (
  id number(11) primary key,            --айди
  id_ops_painting number(11),           --айди в родительской таблице
  id_ref_ops_painting number(11),       --айди операции в журнале
  area_per_item number,                 --площадь покраски на одно изделие                           
  constraint fk_ops_painting_id_ops_painting foreign key (id_ops_painting) references pnl_ops_painting(id) on delete cascade,
  constraint fk_ops_painting_id_ref_ops_painting foreign key (id_ref_ops_painting) references pnl_ref_ops_painting(id)
);   

create index idx_pnl_ops_painting_items_id_ops_painting on pnl_ops_painting_items (id_ops_painting);
  
create sequence sq_pnl_ops_painting_items nocache start with 1;

create or replace trigger trg_pnl_ops_painting_items_bi_r 
before insert on pnl_ops_painting_items for each row
begin
  :new.id := sq_pnl_ops_painting_items.nextval;
end;
/

create or replace view v_pnl_ops_painting_items_dlg as
select
--вью для диалога ввода оперций по лакокраске для стандартного изделия изи изделия в заказе
--выдаем все строки из справочника операций по лакокраске, и данные из таблицы к изделию, если есть
--если привязано к изделию заказа, то выдадим еще итоговые ввеличины в пересчете на количество изделий
  p.id_order_item,
  p.id_std_item,
  i.id,
  i.id_ops_painting,
  i.area_per_item,
  r.id as id_ref_ops_painting,
  r.name,
  r.norm,
  r.active,
  r.pos,
  oi.qnt * i.area_per_item as area_per_all_items
from
  pnl_ref_ops_painting r,
  pnl_ops_painting_items i,
  pnl_ops_painting p,
  order_items oi
where
  r.id = i.id_ref_ops_painting (+)
  and i.id_ops_painting = p.id (+)
  and p.id_order_item = oi.id (+)
;    

select * from v_pnl_ops_painting_items_dlg;

-------------------------------------------------------------------------------
--производственных операций на ЧПУ для стагндартных изделий и изделий в заказе

--родительская таблица
drop table pnl_ops_cnc cascade constraints;
create table pnl_ops_cnc (
  id number(11) primary key,            --айди
  id_std_item number(11),               --айди стандартного изделия
  id_order_item number(11),             --фйди изделия в заказе 
  dt_data_entered date,                 --дата, когда все данные были введены   
  dt_changed date,                      --дата изменения
  is_data_entered number(1) default 0,  --введены ли данные; 0 – не введены, 1 – введены
  no_ops number(1) default 1,           --нет операций по данному типу    
  constraint fk_ops_cnc_id_std_item foreign key (id_std_item) references or_std_items(id) on delete cascade,
  constraint fk_ops_cnc_id_order_item foreign key (id_order_item) references order_items(id) on delete cascade
);

create unique index idx_pnl_ops_cnc_id_std_item on pnl_ops_cnc (id_std_item);
create unique index idx_pnl_ops_cnc_id_order_item on pnl_ops_cnc (id_order_item);
create unique index idx_pnl_ops_cnc_ids_std_order_item on pnl_ops_cnc (id_std_item, id_order_item);

create sequence sq_pnl_ops_cnc nocache start with 1;

create or replace trigger trg_pnl_ops_cnc_bi_r 
  before insert on pnl_ops_cnc for each row
begin
  :new.id := sq_pnl_ops_cnc.nextval;
end;
/

 
--сами операции для данной таблицы (изделия)
--мы не можем привязать строку к строке в смете, так как сметы пересоздаются!
drop table pnl_ops_cnc_items cascade constraints;
create table pnl_ops_cnc_items (
  id number(11) primary key,            --айди
  id_ops_cnc number(11),                --айди операции в журнале
  id_bcad_nomencl number(11),              --айди наименования материла в смете (не уникальны!)
  batch_count number,                   --количество закладкок
  batch_duration number,                --время на одну закладку, мин  
  constraint fk_ops_cnc_id_ops_cnc foreign key (id_ops_cnc) references pnl_ops_cnc(id) on delete cascade,
  constraint fk_ops_cnc_id_bcad_nomencl foreign key (id_bcad_nomencl) references bcad_nomencl(id)
);   

create index idx_pnl_ops_cnc_items_id_ops_cnc on pnl_ops_cnc_items (id_ops_cnc);
  
create sequence sq_pnl_ops_cnc_items nocache start with 1;

create or replace trigger trg_pnl_ops_cnc_items_bi_r 
before insert on pnl_ops_cnc_items for each row
begin
  :new.id := sq_pnl_ops_cnc_items.nextval;
end;
/

create or replace view v_pnl_ops_cnc_items_dlg as
select
--вью для диалога ввода оперций по xge
  t.id_order_item,
  t.id_std_item,
  i.*,
  bn.name
from
  pnl_ops_cnc_items i,
  pnl_ops_cnc t,
  bcad_nomencl bn
where
  i.id_ops_cnc = t.id
  and i.id_bcad_nomencl = bn.id
;    


-------------------------------------------------------------------------------
--производственных операций на Лазера для стагндартных изделий и изделий в заказе
--структура полностью аналогична таковой для ЧПУ

--родительская таблица
drop table pnl_ops_laser cascade constraints;
create table pnl_ops_laser (
  id number(11) primary key,            --айди
  id_std_item number(11),               --айди стандартного изделия
  id_order_item number(11),             --фйди изделия в заказе 
  dt_data_entered date,                 --дата, когда все данные были введены   
  dt_changed date,                      --дата изменения
  is_data_entered number(1) default 0,  --введены ли данные; 0 – не введены, 1 – введены
  no_ops number(1) default 1,           --нет операций по данному типу    
  constraint fk_ops_laser_id_std_item foreign key (id_std_item) references or_std_items(id) on delete cascade,
  constraint fk_ops_laser_id_order_item foreign key (id_order_item) references order_items(id) on delete cascade
);

create unique index idx_pnl_ops_laser_id_std_item on pnl_ops_laser (id_std_item);
create unique index idx_pnl_ops_laser_id_order_item on pnl_ops_laser (id_order_item);
create unique index idx_pnl_ops_laser_ids_std_order_item on pnl_ops_laser (id_std_item, id_order_item);

create sequence sq_pnl_ops_laser nocache start with 1;

create or replace trigger trg_pnl_ops_laser_bi_r 
  before insert on pnl_ops_laser for each row
begin
  :new.id := sq_pnl_ops_laser.nextval;
end;
/

 
--сами операции для данной таблицы (изделия)
--мы не можем привязать строку к строке в смете, так как сметы пересоздаются!
drop table pnl_ops_laser_items cascade constraints;
create table pnl_ops_laser_items (
  id number(11) primary key,            --айди
  id_ops_laser number(11),                --айди операции в журнале
  id_bcad_nomencl number(11),              --айди наименования материла в смете (не уникальны!)
  batch_count number,                   --количество закладкок
  batch_duration number,                --время на одну закладку, мин  
  constraint fk_ops_laser_id_ops_laser foreign key (id_ops_laser) references pnl_ops_laser(id) on delete cascade,
  constraint fk_ops_laser_id_bcad_nomencl foreign key (id_bcad_nomencl) references bcad_nomencl(id)
);   

create index idx_pnl_ops_laser_items_id_ops_laser on pnl_ops_laser_items (id_ops_laser);
  
create sequence sq_pnl_ops_laser_items nocache start with 1;

create or replace trigger trg_pnl_ops_laser_items_bi_r 
before insert on pnl_ops_laser_items for each row
begin
  :new.id := sq_pnl_ops_laser_items.nextval;
end;
/

create or replace view v_pnl_ops_laser_items_dlg as
select
--вью для диалога ввода оперций по xge
  t.id_order_item,
  t.id_std_item,
  i.*,
  bn.name
from
  pnl_ops_laser_items i,
  pnl_ops_laser t,
  bcad_nomencl bn
where
  i.id_ops_laser = t.id
  and i.id_bcad_nomencl = bn.id
;    


-------------------------------------------------------------------------------
--производственных операций по сверловке для стагндартных изделий и изделий в заказе
--содержит только основную таблицу. единственный параметр - количество панелей со сверловкой

--основная таблица
create table pnl_ops_drilling (
  id number(11) primary key,            --айди
  id_std_item number(11),               --айди стандартного изделия
  id_order_item number(11),             --фйди изделия в заказе 
  dt_data_entered date,                 --дата, когда все данные были введены   
  dt_changed date,                      --дата изменения
  is_data_entered number(1) default 0,  --введены ли данные; 0 – не введены, 1 – введены
  no_ops number(1) default 1,           --нет операций по данному типу    
  qnt_panels_with_drill number,         --количество панелей со сверловкой   
  constraint fk_ops_drilling_id_std_item foreign key (id_std_item) references or_std_items(id) on delete cascade,
  constraint fk_ops_drilling_id_order_item foreign key (id_order_item) references order_items(id) on delete cascade
);

create unique index idx_pnl_ops_drilling_id_std_item on pnl_ops_drilling (id_std_item);
create unique index idx_pnl_ops_drilling_id_order_item on pnl_ops_drilling (id_order_item);
create unique index idx_pnl_ops_drilling_ids_std_order_item on pnl_ops_drilling (id_std_item, id_order_item);

create sequence sq_pnl_ops_drilling nocache start with 1;

create or replace trigger trg_pnl_ops_drilling_bi_r 
  before insert on pnl_ops_drilling for each row
begin
  :new.id := sq_pnl_ops_drilling.nextval;
end;
/

create or replace view v_pnl_ops_drilling as
select
--вью для диалога ввода оперций по сверловке для стандартного изделия изи изделия в заказе
  t.*,
  oi.qnt * i.qnt_panels_with_drill as qnt_panels_with_drill_for_all
from
  pnl_ops_drilling t,
  order_items oi
where
  t.id_order_item = oi.id (+)
;    

-- =============================================================================

-- =============================================================================
-- процедура: p_pnl_delete_for_order_item
-- назначение: удаляет все записи из таблиц операций (pnl_ops_*) 
--             для указанного изделия заказа.
-- параметры:
--   p_order_item_id – id записи order_items
--   p_tables_list   – список сокращений операций через запятую,
--                     если null – все известные операции
-- =============================================================================
create or replace procedure p_pnl_delete_for_order_item(
  p_order_item_id in number,
  p_tables_list in varchar2 default null
) is
  c_all_ops constant varchar2(100) := 'painting,cnc,laser,drilling';
  v_ops_list varchar2(100);
  v_op_name varchar2(30);
  v_pos integer;
  v_rest varchar2(100);
  v_main_table varchar2(30);
begin
  if p_tables_list is null then
    v_ops_list := c_all_ops;
  else
    v_ops_list := p_tables_list;
  end if;

  v_rest := v_ops_list;
  loop
    v_pos := instr(v_rest, ',');
    if v_pos = 0 then
      v_op_name := trim(v_rest);
      v_rest := '';
    else
      v_op_name := trim(substr(v_rest, 1, v_pos-1));
      v_rest := substr(v_rest, v_pos+1);
    end if;
    exit when v_op_name is null;
    v_main_table := 'pnl_ops_' || v_op_name;
    execute immediate 'delete from ' || v_main_table || ' where id_order_item = :id' using p_order_item_id;
  end loop;
end p_pnl_delete_for_order_item;
/

-- =============================================================================
-- процедура: p_pnl_update_ops
-- назначение: создаёт, обновляет или удаляет записи в таблицах операций
--             для одного или всех изделий заказов в зависимости от параметров.
--             Использует p_pnl_update_single_order_item для каждого order_item.
-- параметры:
--   p_order_item_id – id записи order_items (если null, обрабатываются все)
--   p_force         – 0: создавать только если нет записи и есть шаблон;
--                     1: пересоздавать если есть запись и есть шаблон,
--                        если шаблона нет – удалять запись
--   p_tables_list   – список сокращений операций с режимами через запятую,
--                     если null – все известные операции с режимом по умолчанию
--   p_debug         – если 1, выводить отладочную информацию через DBMS_OUTPUT
-- =============================================================================
create or replace procedure p_pnl_update_ops(
  p_order_item_id in number default null,
  p_force in number default 0,
  p_tables_list in varchar2 default null,
  p_debug in number default 0
) is
  cursor c_order_items is
    select id, std, qnt, id_std_item
    from order_items
    where id = p_order_item_id;
begin
  for rec in c_order_items loop
    p_pnl_update_single_order_item(
      p_order_item_id => rec.id,
      p_std           => rec.std,
      p_qnt           => rec.qnt,
      p_id_std_item   => rec.id_std_item,
      p_force         => p_force,
      p_tables_list   => p_tables_list,
      p_debug         => p_debug
    );
  end loop;
end p_pnl_update_ops;
/


--обновим для всех переданных айди изделий операции в режиме форсе
--айди передаются в строке через запятую 
create or replace procedure p_pnl_update_ops_for_order(
  p_order_items_str in varchar2,
  p_delimiter       in varchar2 default ','
) is
  v_str varchar2(4000) := p_order_items_str || p_delimiter;
  v_pos number;
  v_id number;
begin
  loop
    v_pos := nvl(instr(v_str, p_delimiter), 0);
    exit when v_pos <= 1;
    v_id := to_number(trim(substr(v_str, 1, v_pos - 1)));
    v_str := substr(v_str, v_pos + 1);
    p_pnl_update_ops(p_order_item_id => v_id, p_force => 1);
  end loop;
end p_pnl_update_ops_for_order;
/

create or replace procedure p_pnl_update_ops_for_order(
  p_order_items_str in varchar2,
  p_delimiter       in varchar2 default ','
) is
  v_str varchar2(4000) := trim(p_order_items_str);
  v_pos number;
  v_id number;
begin
  if v_str is null then
    return;
  end if;

  v_str := v_str || p_delimiter;

  loop
    v_pos := instr(v_str, p_delimiter);
    exit when v_pos = 0;

    v_id := to_number(trim(substr(v_str, 1, v_pos - 1)));
    v_str := substr(v_str, v_pos + 1);

    p_pnl_update_ops(p_order_item_id => v_id, p_force => 1);
  end loop;
end p_pnl_update_ops_for_order;
/

-- =============================================================================
-- процедура: p_pnl_update_single_order_item
-- назначение: создаёт или обновляет записи в таблицах операций для одного
--             изделия заказа, используя переданные параметры.
--             Не читает таблицу order_items, поэтому безопасна для вызова
--             из триггера.
-- параметры:
--   p_order_item_id – id записи order_items
--   p_std           – значение поля std
--   p_qnt           – значение поля qnt
--   p_id_std_item   – значение поля id_std_item
--   p_force         – 0: создавать если нет записи и есть шаблон;
--                     1: пересоздавать если есть запись и есть шаблон,
--                        если шаблона нет – удалить
--   p_tables_list   – список операций с режимами (как в основной процедуре)
--   p_debug         – отладка
-- =============================================================================
create or replace procedure p_pnl_update_single_order_item(
  p_order_item_id in number,
  p_std           in number,
  p_qnt           in number,
  p_id_std_item   in number,
  p_force         in number default 0,
  p_tables_list   in varchar2 default null,
  p_debug         in number default 0
) is
--  pragma autonomous_transaction;
  c_all_ops constant varchar2(100) := 'painting:copy,cnc:reset,laser:reset,drilling:copy';
  v_ops_list varchar2(200);
  v_op_name varchar2(30);
  v_op_mode varchar2(10);
  v_pos integer;
  v_pos2 integer;
  v_rest varchar2(200);
  v_item varchar2(100);

  v_main_table varchar2(30);
  v_child_table varchar2(30);
  v_fk_column varchar2(30);
  v_seq_main varchar2(30);
  v_seq_child varchar2(30);
  v_main_id number;
  v_template_main_id number;
  v_has_templates number;
  v_has_existing number;
  v_sql varchar2(4000);
  v_cols_parent varchar2(4000);
  v_cols_child varchar2(4000);
  v_is_data_entered number;
  v_dt_data_entered date;
  v_dt_changed date;
  v_cnt_inserted number;

  procedure log(p_msg in varchar2) is
  begin
    if p_debug = 1 then
      dbms_output.put_line(p_msg);
    end if;
    p_log(p_msg);
  end log;
begin
  log('=== p_pnl_update_single_order_item start ===');
  log('p_order_item_id: ' || p_order_item_id);
  log('p_std: ' || p_std);
  log('p_qnt: ' || p_qnt);
  log('p_id_std_item: ' || p_id_std_item);
  log('p_force: ' || p_force);
  log('p_tables_list: ' || nvl(p_tables_list, 'NULL'));

  -- определяем, подходит ли состояние
  if (p_std != 1 or nvl(p_qnt, 0) <= 0) then
    log('состояние неподходящее – удаляем все записи');
    if p_tables_list is null then
      v_ops_list := c_all_ops;
    else
      v_ops_list := p_tables_list;
    end if;
    -- убираем режимы (оставляем только имена операций)
    v_rest := v_ops_list;
    loop
      v_pos := instr(v_rest, ',');
      if v_pos = 0 then
        v_item := trim(v_rest);
        v_rest := '';
      else
        v_item := trim(substr(v_rest, 1, v_pos-1));
        v_rest := substr(v_rest, v_pos+1);
      end if;
      exit when v_item is null;
      v_pos2 := instr(v_item, ':');
      if v_pos2 = 0 then
        v_op_name := v_item;
      else
        v_op_name := substr(v_item, 1, v_pos2-1);
      end if;
      v_main_table := 'pnl_ops_' || v_op_name;
      log('  удаление из ' || v_main_table || ' для order_item id=' || p_order_item_id);
      execute immediate 'delete from ' || v_main_table || ' where id_order_item = :id' using p_order_item_id;
    end loop;
    log('=== p_pnl_update_single_order_item end (удаление) ===');
    return;
  end if;

  log('состояние подходит, продолжаем');
  if p_tables_list is null then
    v_ops_list := c_all_ops;
  else
    v_ops_list := p_tables_list;
  end if;

  v_rest := v_ops_list;
  loop
    v_pos := instr(v_rest, ',');
    if v_pos = 0 then
      v_item := trim(v_rest);
      v_rest := '';
    else
      v_item := trim(substr(v_rest, 1, v_pos-1));
      v_rest := substr(v_rest, v_pos+1);
    end if;
    exit when v_item is null;

    -- извлекаем имя операции и режим
    v_pos2 := instr(v_item, ':');
    if v_pos2 = 0 then
      v_op_name := v_item;
      v_op_mode := 'reset';
    else
      v_op_name := substr(v_item, 1, v_pos2-1);
      v_op_mode := lower(trim(substr(v_item, v_pos2+1)));
    end if;

    log('  Операция: ' || v_op_name || ', режим: ' || v_op_mode);

    -- формируем имена объектов
    v_main_table := 'pnl_ops_' || v_op_name;
    v_child_table := 'pnl_ops_' || v_op_name || '_items';
    v_fk_column := 'id_ops_' || v_op_name;
    v_seq_main := 'sq_pnl_ops_' || v_op_name;
    v_seq_child := 'sq_pnl_ops_' || v_op_name || '_items';

    log('    main_table: ' || v_main_table);
    log('    child_table: ' || v_child_table);

    -- проверяем существование записи для этого order_item
    begin
      execute immediate 'select id from ' || v_main_table || ' where id_order_item = :id'
        into v_main_id
        using p_order_item_id;
      v_has_existing := 1;
      log('    существующая запись id=' || v_main_id);
    exception when no_data_found then
      v_has_existing := 0;
      v_main_id := null;
      log('    существующая запись не найдена');
    end;

    -- ищем шаблон
    begin
      execute immediate 'select id from ' || v_main_table || ' where id_std_item = :std_id and id_order_item is null'
        into v_template_main_id
        using p_id_std_item;
      log('    найдена шаблонная родительская запись id=' || v_template_main_id);
      v_has_templates := 1;
    exception when no_data_found then
      v_template_main_id := null;
      v_has_templates := 0;
      log('    шаблонная родительская запись не найдена');
    end;

    -- логика p_force
    if p_force = 0 then
      if v_has_existing = 1 then
        log('    запись уже существует, пропускаем (p_force=0)');
        continue;
      end if;
      if v_has_templates = 0 then
        log('    шаблон не найден, пропускаем (p_force=0)');
        continue;
      end if;
      log('    создаём новую запись из шаблона (p_force=0)');
    else -- p_force = 1
      if v_has_existing = 1 and v_has_templates = 0 then
        log('    запись есть, шаблона нет – удаляем и пропускаем');
        execute immediate 'delete from ' || v_main_table || ' where id = :id' using v_main_id;
        continue;
      end if;
      if v_has_existing = 1 and v_has_templates = 1 then
        log('    запись есть и шаблон есть – удаляем существующую запись');
        execute immediate 'delete from ' || v_main_table || ' where id = :id' using v_main_id;
        v_has_existing := 0;
      end if;
      if v_has_existing = 0 and v_has_templates = 0 then
        log('    записи нет и шаблона нет – пропускаем');
        continue;
      end if;
      if v_has_existing = 0 and v_has_templates = 1 then
        log('    записи нет, шаблон есть – создаём');
      end if;
    end if;

    -- создание записи
    if v_has_templates = 1 and v_has_existing = 0 then
      -- определяем значения флага и дат в зависимости от режима
      if v_op_mode = 'copy' then
        v_is_data_entered := 1;
        v_dt_data_entered := sysdate;
        v_dt_changed := null;
        log('    режим copy: is_data_entered=1, dt_data_entered=sysdate');
      else -- reset
        v_is_data_entered := 0;
        v_dt_data_entered := null;
        v_dt_changed := null;
        log('    режим reset: is_data_entered=0, даты сброшены');
      end if;

      -- формируем список дополнительных колонок родительской таблицы
      v_cols_parent := '';
      for c in (
        select column_name
        from all_tab_columns
        where owner = user
          and table_name = upper(v_main_table)
          and column_name not in ('ID', 'ID_ORDER_ITEM', 'ID_STD_ITEM', 'DT_DATA_ENTERED', 'DT_CHANGED', 'IS_DATA_ENTERED')
        order by column_id
      ) loop
        if v_cols_parent is not null then
          v_cols_parent := v_cols_parent || ', ';
        end if;
        v_cols_parent := v_cols_parent || c.column_name;
      end loop;
      log('    дополнительные колонки родителя: ' || nvl(v_cols_parent, 'нет'));

      -- вставляем запись
      if v_cols_parent is not null then
        v_sql := 'insert into ' || v_main_table || ' (
                    id,
                    id_order_item,
                    dt_data_entered,
                    dt_changed,
                    is_data_entered,
                    ' || v_cols_parent || '
                  )
                  select
                    ' || v_seq_main || '.nextval,
                    :order_id,
                    :dt_data_entered,
                    :dt_changed,
                    :is_data_entered,
                    ' || v_cols_parent || '
                  from ' || v_main_table || '
                  where id = :template_id';
      else
        v_sql := 'insert into ' || v_main_table || ' (
                    id,
                    id_order_item,
                    dt_data_entered,
                    dt_changed,
                    is_data_entered
                  )
                  select
                    ' || v_seq_main || '.nextval,
                    :order_id,
                    :dt_data_entered,
                    :dt_changed,
                    :is_data_entered
                  from ' || v_main_table || '
                  where id = :template_id';
      end if;
      log('    SQL: ' || v_sql);
      execute immediate v_sql using p_order_item_id, v_dt_data_entered, v_dt_changed, v_is_data_entered, v_template_main_id;
      -- получаем id
      execute immediate 'select id from ' || v_main_table || ' where id_order_item = :id' into v_main_id using p_order_item_id;
      log('    создан id родителя: ' || v_main_id);

      -- копируем дочерние шаблоны
      begin
        execute immediate 'select count(*) from ' || v_child_table || ' where ' || v_fk_column || ' = :id'
          into v_has_templates
          using v_template_main_id;
      exception when others then
        v_has_templates := 0;
      end;

      if v_has_templates > 0 then
        v_cols_child := '';
        for c in (
          select column_name
          from all_tab_columns
          where owner = user
            and table_name = upper(v_child_table)
            and column_name not in ('ID', upper(v_fk_column))
          order by column_id
        ) loop
          if v_cols_child is not null then
            v_cols_child := v_cols_child || ', ';
          end if;
          v_cols_child := v_cols_child || c.column_name;
        end loop;

        if v_cols_child is not null then
          v_sql := 'insert into ' || v_child_table || ' (
                      id,
                      ' || v_fk_column || ',
                      ' || v_cols_child || '
                    )
                    select
                      ' || v_seq_child || '.nextval,
                      :main_id,
                      ' || v_cols_child || '
                    from ' || v_child_table || '
                    where ' || v_fk_column || ' = :template_id';
          log('    копируем дочерние шаблоны');
          log('    SQL: ' || v_sql);
          execute immediate v_sql using v_main_id, v_template_main_id;
          v_cnt_inserted := sql%rowcount;
          log('    вставлено строк в дочернюю таблицу: ' || v_cnt_inserted);
        end if;
      end if;
    end if;
  end loop;
  --commit;
  log('=== p_pnl_update_single_order_item end ===');
exception
  when others then
    log('Ошибка: ' || sqlerrm);
    log('Stack: ' || dbms_utility.format_error_backtrace);
    raise;
end p_pnl_update_single_order_item;
/


-- =============================================================================
-- триггер: trg_order_items_pnl_ops
-- назначение: вызывает процедуру p_pnl_update_ops при изменении полей std, qnt, id_std_item
-- =============================================================================
drop trigger trg_order_items_pnl_ops;
create or replace trigger trg_order_items_pnl_ops
  after insert or update of std, qnt, id_std_item on order_items
  for each row
declare
  v_old_ok boolean;
  v_new_ok boolean;
  v_cnt number;
begin
  -- Определяем старое состояние
  if inserting then
    v_old_ok := false;
  else
    v_old_ok := (nvl(:old.std, 0) = 1 and nvl(:old.qnt, 0) > 0);
  end if;

  v_new_ok := (nvl(:new.std, 0) = 1 and nvl(:new.qnt, 0) > 0);

  -- Если изменилось состояние или id_std_item, удаляем старые записи
  if (v_old_ok != v_new_ok) or 
     (not inserting and nvl(:old.id_std_item, -1) != nvl(:new.id_std_item, -1)) then
    p_pnl_delete_for_order_item(p_order_item_id => :new.id);
  end if;

  -- Если новое состояние подходит, создаём запись из шаблона
  if v_new_ok then
    p_pnl_update_single_order_item(
      p_order_item_id => :new.id,
      p_std           => :new.std,
      p_qnt           => :new.qnt,
      p_id_std_item   => :new.id_std_item,
      p_force         => 0,
      p_tables_list   => null,
      p_debug         => 0
    );
  end if;

  -- === ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ===
  -- Сразу после выполнения процедуры проверяем, есть ли записи в таблицах операций
  select count(*) into v_cnt from pnl_ops_painting where id_order_item = :new.id;
  p_log('После выполнения триггера: записей в painting для order_item ' || :new.id || ' = ' || v_cnt);
  select count(*) into v_cnt from pnl_ops_cnc where id_order_item = :new.id;
  p_log('После выполнения триггера: записей в cnc = ' || v_cnt);
  select count(*) into v_cnt from pnl_ops_laser where id_order_item = :new.id;
  p_log('После выполнения триггера: записей в laser = ' || v_cnt);
  select count(*) into v_cnt from pnl_ops_drilling where id_order_item = :new.id;
  p_log('После выполнения триггера: записей в drilling = ' || v_cnt);
end;
/



exec p_pnl_delete_for_order_item(562099);
exec p_pnl_update_ops(562099, 0, null, 1);
exec p_pnl_update_ops_for_order(562099);
