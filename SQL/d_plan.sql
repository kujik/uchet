alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;

--таблица по типам производственных участков
--alter  table work_cell_types add active number(1);
--drop table work_cell_types cascade constraints; 
create table work_cell_types (
  id number(11),
  name varchar(100),  --полное наименование типа участков
  code varchar(4),    --код 
  pos number(4),      --позиция, для производственных 
  posstd number(4),   --позиция, для стандартных участков, заданных вручную (не нулл является их признаком; отрицательная - после производственных, -1 сразу, -2 дальше)
  refers_to_prod_area number(1) default 0,
  active number(1), 
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

