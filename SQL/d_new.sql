
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

--alter table or_format_estimates add prefix_prod varchar2(20);           --префикс для итм, для производственного паспорта
--alter table or_format_estimates add is_semiproduct number(1) default 0; --это группа полуфабрикатов
--alter table or_format_estimates drop column prefix_prod;           --префикс для итм, для производственного паспорта
--alter table or_format_estimates drop column is_semiproduct; --это группа полуфабрикатов
alter table or_format_estimates add type number(1) default 0; --ok
update or_formats set name = 'Полуфабрикаты' where id = 1;
update or_format_estimates set name = 'Общие полуфабрикаты' where id = 1;
--v_or_format_estimates


--create table or_std_items 
alter table or_std_items drop column type_of_semiproduct cascade constraints;
alter table or_std_items add type_of_semiproduct number(11); --тип полуфабриката, соотвествует одному из участков
alter table or_std_items add barcode_c varchar2(100);
alter table or_std_items add constraint fk_or_std_items_sem foreign key (type_of_semiproduct) references work_cell_types(id);


alter table estimate_items add id_or_std_item number(11);
alter table estimate_items add  constraint fk_estimate_items_std foreign key (id_or_std_item) references or_std_items(id);
alter table estimate_items add contract number(1) default 0;
--удалить id_bcad_nomencl у изделий, проставить им группы пф или ги, тк в бд есть неверные группы



alter table bcad_groups add is_semiproduct number(1) default 0;




--------------------------------------------------------------------------------

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

--послке правки таблиц стд.изд. и вью v_estimate и простановки типов стд.изд. в справочнике!!!
--проставимя в сметах айди стандартных изделий и группу Готовые изделия
update estimate_items t1
set t1.id_or_std_item = (
    select t2.id
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname
)
,t1.id_group = 104
--,t1.id_name = null
where exists (
    select 1
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname and type <> 2
);

update estimate_items t1
set t1.id_or_std_item = (
    select t2.id
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname
)
,t1.id_group = 2
--,t1.id_name = null
where exists (
    select 1
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname and type = 2
);





select * from estimate_items where id_or_std_item is not null;

/*
--проставим в сметах группы для изделий-полуфабрикатов
--update estimate_items t1
--set t1.id_group = 2 
;
select * from estimate_items t1
where exists (
select t2.fullname  
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname and nvl(t2.is_semiproduct, 0) = 1
);

select id, is_semiproduct from v_or_std_items where fullname = :fullname$s;

select *    
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname and nvl(t2.is_semiproduct, 0) = 1;\
*/    

--END обновление смет

select * from v_or_std_items where nvl(is_semiproduct, 0) = 1;
select * from estimate_items where id_group = 2;
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
--F_TestEstimateItem_New

*/


select 
  max(oi.slash),
  max(oi.fullitemname),
  count(ei.id)
from
  v_order_items oi,
  estimates e,
  estimate_items ei
  --bcad_nomencl n1
  --bcad_nomencl n2
where
  oi.id_organization <> -1
  and nvl(oi.std, 0) = 1
  and e.id_order_item = oi.id
  and ei.id_estimate = e.id
group by
  ei.id_estimate
having      
  count(ei.id) > 1  
  ;
  --and count(
  
select * from or_format_estimates where id_format = 1; 
select * from or_std_items where id_or_format_estimates =1; --=Д/К





--------------------------------------------------------------------------------
/*
order_item +поля
v_ordert_items
v_orders_list
trg_order_item_stages_biud_r
v_order_items

*/    
--заполнить количество принятых на сгп в журнале заказов на основании журнала приемки на сгп
merge into order_items t1
using (select id_order_item, sum(qnt2) as qnt from v_order_item_stages1 group by id_order_item) t2
on (t1.id = t2.id_order_item)
when matched then
    update set t1.qnt_to_sgp = t2.qnt;
    
update order_items set qnt_to_sgp = 0 where qnt_to_sgp is null;    


--------------------------------------------------------------------------------

create or replace view v_orders_send_to_prod as
--заказы, по кторым есть НП на производство с выдачей плитных материалов
--Материалы основы = 14, кромочные = 13
select
--  distinct id_zakaz,  
  id_zakaz,
  min(movebilldate) as dt
from
  dv.move_bill mb,
  dv.move_bill_spec mbs,
  dv.nomenclatura n,
  dv.sklad s
where
  mb.id_movebill = mbs.id_movebill
  and mb.id_docstate = 3
  and mb.id_skladdest = s.id_sklad
  and nvl(s.brigada, 0) = 1
  and mbs.id_nomencl = n.id_nomencl
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (14)  
    connect by prior id_group = id_parentgroup   
)
  group by id_zakaz
  order by id_zakaz desc
;  

--первоначально заполним по старым заказам, даты проставим равной дате накладной  
/*merge into orders t1
using (select id_zakaz, dt from v_orders_send_to_prod) t2
on (t1.id_itm = t2.id_zakaz)
when matched then
    update set t1.dt_to_prod = t2.dt;
*/    

create or replace view v_orders_has_prod as
select
--список заказов ИТМ, в которых есть плитные материалы 
  id_zakaz
  --, count(n.name)
from 
  dv.nomenclatura_in_izdel niz,dv.nomenclatura n
where
  niz.id_nomencl = n.id_nomencl 
  and niz.id_nomizdel_parent_t is not null
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (14)  
    connect by prior id_group = id_parentgroup   
  )
  group by id_zakaz
;

/*
select
  max(o.id) as id_order,
  max(o.ornum) as ornum,
  id_zakaz, 
  count(n.name) as qnt_n,
  sum(niz.count_nomencl) as qnt
from 
  dv.nomenclatura_in_izdel niz,dv.nomenclatura n,orders o
where
  niz.id_nomencl = n.id_nomencl 
  and o.id_itm = niz.id_zakaz
  and niz.id_nomizdel_parent_t is not null
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (14)  
    connect by prior id_group = id_parentgroup   
  )
  group by id_zakaz
;
*/

/*
create or replace view v_orders_boards_m2 as
select
--количество плитных материалов (на пильные центры) по заказам
  id_zakaz, 
  count(n.name) as qnt_n,
  sum(niz.count_nomencl) as qnt
from 
  dv.nomenclatura_in_izdel niz,dv.nomenclatura n
where
  niz.id_nomencl = n.id_nomencl 
  and niz.id_nomizdel_parent_t is not null
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (14)  
    connect by prior id_group = id_parentgroup   
  )
  group by id_zakaz
;

create or replace view v_orders_edges_m as
select
--количество кромочных материалов,м.пог.
  id_zakaz, 
  count(n.name) as qnt_n,
  sum(niz.count_nomencl) as qnt
from 
  dv.nomenclatura_in_izdel niz,dv.nomenclatura n
where
  niz.id_nomencl = n.id_nomencl 
  and niz.id_nomizdel_parent_t is not null
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (13)  
    connect by prior id_group = id_parentgroup   
  )
  group by id_zakaz
;

*/


create or replace procedure P_SetOrdersProdData is
begin
  --устанавливает в таблице заказов проиизводственные статусы и данные, взятые из ИТМ
  --(является ли заказ производственныым, дата выдачи в производство, количество плитных и кромочных материалов по смете) 

  update orders set dt_to_prod = null;
  merge into orders t1
  using (select id_zakaz, dt from v_orders_send_to_prod) t2
  on (t1.id_itm = t2.id_zakaz)
  when matched then
      update set t1.dt_to_prod = t2.dt;

/*
  update orders set has_prod = 0;
  merge into orders t1
  using (select id_zakaz from v_orders_has_prod) t2
  on (t1.id_itm = t2.id_zakaz)
  when matched then
      update set t1.has_prod = 1;

  update orders set qnt_boards_m2 = null;
  merge into orders t1
  using (select id_zakaz, qnt from v_orders_boards_m2) t2
  on (t1.id_itm = t2.id_zakaz)
  when matched then
      update set t1.qnt_boards_m2 = t2.qnt;

  update orders set qnt_edges_m = null;
  merge into orders t1
  using (select id_zakaz, qnt from v_orders_edges_m) t2
  on (t1.id_itm = t2.id_zakaz)
  when matched then
      update set t1.qnt_edges_m = t2.qnt;
  */
  update order_items set qnt_boards_m2 = null;
  merge into order_items t1
  using (select id, qnt from v_orders_boards_m2) t2
  on (t1.id = t2.id)
  when matched then
      update set t1.qnt_boards_m2 = t2.qnt;
end;
/


  merge into order_items t1
  using (select id, qnt from v_orders_boards_m2) t2
  on (t1.id = t2.id)
  when matched then
      update set t1.qnt_boards_m2 = t2.qnt;



begin
  P_SetOrdersProdData;
end;
/













/*
alter table payroll_item add salary_plan_m number;    
alter table payroll_item add salary_const_m number;    
alter table payroll_item add salary_incentive_m number;    
alter table payroll_item add ors_sum number;    
alter table payroll_item add ors number;    
*/


create or replace view v_orders_edges_m as
select
--количество кромочных материалов,м.пог.
  oi.id,
--  max(oi.slash) as slash,
  sum(ei.qnt_itm) as qnt
from 
  v_order_items oi,
  estimates e,
  estimate_items ei,
  bcad_nomencl bn,
  dv.nomenclatura n
where
  oi.id = e.id_order_item
  and ei.id_estimate (+) = e.id
  and ei.id_name = bn.id
  and n.name = bn.name 
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (/*13*/ 2308 /*меламин*/, 2297 /*пвх*/, 2309 /*шпон*/) --кромка 
    connect by prior id_group = id_parentgroup   
  )
  group by oi.id
;

create or replace view v_orders_boards_m2 as
select
--количество плитных материалов (на пильные центры) по заказам
  oi.id,
--  max(oi.slash) as slash,
  sum(ei.qnt_itm) as qnt
from 
  v_order_items oi,
  estimates e,
  estimate_items ei,
  bcad_nomencl bn,
  dv.nomenclatura n
where
  oi.id = e.id_order_item
  and ei.id_estimate (+) = e.id
  and ei.id_name = bn.id
  and n.name = bn.name 
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (/*14*/ 2284 /*массив щит*/, 2276 /*мдф*/, 18 /*лдсп*/, 2288 /* Пластик HPL*/, 2287 /*Пластик рекламный*/, 2275 /*ХДФ\ДВП*/, 2295 /*Фанера*/, 2283 /*Шпон*/) --плитные 
    connect by prior id_group = id_parentgroup   
  )
  group by oi.id
;


