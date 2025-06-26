
--производственные маршруты стандартных изделий
--drop table or_std_item_route cascade constraints;
create table or_std_item_route (
  id_or_std_item number(11),
  id_work_cell_type number(11),
  constraint pk_or_std_item_route primary key (id_or_std_item, id_work_cell_type),
  constraint fk_or_std_item_route_oi foreign key (id_or_std_item) references or_std_items(id) on delete cascade,
  constraint fk_or_std_item_route_wct foreign key (id_work_cell_type) references work_cell_types(id)
);   

delete from or_std_item_route;

--alter table or_std_items add route varchar2(400);
--alter table or_std_items drop column route;

alter table or_format_estimates add prefix_prod varchar2(20);           --префикс для итм, для производственного паспорта
alter table or_format_estimates add is_semiproduct number(1) default 0; --это группа полуфабрикатов

--create table or_std_items 
alter table or_std_items drop column type_of_semiproduct cascade constraints;
alter table or_std_items add type_of_semiproduct number(11); --тип полуфабриката, соотвествует одному из участков
alter table or_std_items add constraint fk_or_std_items_sem foreign key (type_of_semiproduct) references work_cell_types(id);


alter table estimate_items add id_or_std_item number(11);
alter table estimate_items add  constraint fk_estimate_items_std foreign key (id_or_std_item) references or_std_items(id);


--установить айди стандартного изделия в сметах по признаку совпадения наименований
--запрос работает долго 4 мин
select
  e.id_or_std_item,
  e.name,
  o.fullname
from
  v_estimate e,
  v_or_std_items o
where
  e.name = o.FULLNAME    
;

update estimate_items t1
set t1.id_or_std_item = (
--    select max(t2.id)
    select t2.id
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname
)
where exists (
    select 1
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname
);

select * from estimate_items where id_or_std_item is not null;
--END обновление смет

--------------------------------------------------------------------------------
/*
не получается сделать без пробела в t.code || ', ', если его убрать, то при одинаковых конце одного участка и начале следующего будет неверно:
КС,СТ -> КСТ
    ,rtrim(
    (select 
       regexp_replace(listagg(t.code || ', ') within group (order by t.pos), '([^\,]+)(\,\1)+', '\1' )
       from ((select i.id_or_std_item, t.code, t.pos from work_cell_types t, or_std_item_route i where t.id = i.id_work_cell_type)) t
       where id_or_std_item = i.id
    ), ', ') as route


--v_or_std_items
--D ConvertNewOrStdItemRoutes

*/