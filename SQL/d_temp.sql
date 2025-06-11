alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';

create or replace  directory ora_exp_dir as '/home/oracle/dir';
create or replace  directory ora_exp_dir as '/home/oracle/dir';
GRANT READ, WRITE ON DIRECTORY ora_exp_dir TO SYSTEM;

select comp_id, version, status FROM dba_registry;


SELECT * FROM V$NLS_PARAMETERS;  
PARAMETER,VALUE
NLS_LANGUAGE,RUSSIAN
NLS_TERRITORY,RUSSIA
NLS_CURRENCY,?
NLS_ISO_CURRENCY,RUSSIA
NLS_NUMERIC_CHARACTERS,, 
NLS_CALENDAR,GREGORIAN
NLS_DATE_FORMAT,DD.MM.RR
NLS_DATE_LANGUAGE,RUSSIAN
NLS_CHARACTERSET,CL8MSWIN1251
NLS_SORT,RUSSIAN
NLS_TIME_FORMAT,HH24:MI:SSXFF
NLS_TIMESTAMP_FORMAT,DD.MM.RR HH24:MI:SSXFF
NLS_TIME_TZ_FORMAT,HH24:MI:SSXFF TZR
NLS_TIMESTAMP_TZ_FORMAT,DD.MM.RR HH24:MI:SSXFF TZR
NLS_DUAL_CURRENCY,?
NLS_NCHAR_CHARACTERSET,AL16UTF16
NLS_COMP,BINARY
NLS_LENGTH_SEMANTICS,BYTE
NLS_NCHAR_CONV_EXCP,FALSE


PARAMETER,VALUE,CON_ID
NLS_LANGUAGE,RUSSIAN,0
NLS_TERRITORY,RUSSIA,0
NLS_CURRENCY,?,0
NLS_ISO_CURRENCY,RUSSIA,0
NLS_NUMERIC_CHARACTERS,, ,0
NLS_CALENDAR,GREGORIAN,0
NLS_DATE_FORMAT,DD.MM.RR,0
NLS_DATE_LANGUAGE,RUSSIAN,0
NLS_CHARACTERSET,CL8MSWIN1251,0
NLS_SORT,RUSSIAN,0
NLS_TIME_FORMAT,HH24:MI:SSXFF,0
NLS_TIMESTAMP_FORMAT,DD.MM.RR HH24:MI:SSXFF,0
NLS_TIME_TZ_FORMAT,HH24:MI:SSXFF TZR,0
NLS_TIMESTAMP_TZ_FORMAT,DD.MM.RR HH24:MI:SSXFF TZR,0
NLS_DUAL_CURRENCY,?,0
NLS_NCHAR_CHARACTERSET,AL16UTF16,0
NLS_COMP,BINARY,0
NLS_LENGTH_SEMANTICS,BYTE,0
NLS_NCHAR_CONV_EXCP,FALSE,0


select * from nls_database_parameters;


delete from adm_error_log where dt < '28.06.2024' or ide = 1;



select dbms_metadata.get_ddl('VIEW','V_PAYROLL','UCHET22') from dual;    
select * from dba_views where view_name = 'V_SN_CALENDAR_ACCOUNTS';




select id, path, dt_beg, dt_end from v_orders where nvl(in_archive, 0) <> 1 and dt_end is not null and dt_end >=; 


create table test_groups as select * from dv.groups;


select DV.CenaNomInPeriod(13054, '01.05.2024', '01.05.2024') from dual;
select DV.CenaNomBeforeDate(13054, '01.04.2024') from dual;


select count(*), sum(price*qnt) from order_items i, orders o where i.id_order = o.id and resale = 1 and dt_beg >'01.05.2024';

create or replace view v_test as
  select * from test1;
  
delete from test1 where id = 104;  

select sum(sum) from or_payments;-- where dt < '14.05.2024';--93561578,1
select sum(sum) from sn_order_payments;-- where dt < '14.05.2024';

select sum(sum) from or_payments where dt = '14.05.2024';--93561578,1
select sum(sum) from sn_order_payments where dt = '14.05.2024';

select o.id, o.prefix, o.ornum, o.dt_beg, o.dt_end, o.dt_to_sgp, o.dt_from_sgp, o.dt_upd, o.dt_end_manager, o.dt_end_copy, o.cost, o.pay, o.dt_montage_end, m.dt_end as dt_montage_end_fact from orders o, or_montage m where m.id(+) = o.id;


--o240117
--id 1642
--itm 9497
select numzakaz from dv.zakaz where id_zakaz = 9693;
select * from adm_db_log where comm like '%1643%' or comm like '%9497%';


update orders set dt_end = null where pay is null and id_organization <> -1;

update ref_estimate_replace set id_new= :id_new where id_old = :id_old;


select * from adm_db_log where itemname = 'FinalizeOrder' order by dt desc;


SELECT * FROM v_demandsuppliers;

  SELECT v_demandsupplierspec1.*, v_demandsupplierspec1."ROWID"
    FROM v_demandsupplierspec1
   WHERE id_demand_supplier = 2514508
ORDER BY name;

  SELECT *
    FROM v_demandsupplierspec2
   WHERE id_demand_supplier = 2514508
ORDER BY name;

create table test_3 (
v1 varchar2(10) not null,
v2 varchar2(10) unique,
i1 number(3,1)
);

insert into test_3 (v1) values (null);

delete from adm_users where id = 33;

--update orders set dt_end = dt_to_sgp where prefix = 'П' and dt_to_sgp is not null and dt_end is null and dt_beg < '15.05.2024';
--update orders set dt_end = dt_from_sgp where prefix <> 'П' and dt_from_sgp is not null and dt_end is null and dt_beg < '15.05.2024';




/*
======================================================================================================================
--для доп компл также создавалась запись estimate_items с id_name_resale ref to or_std_items
--при этом для этих наименований в справочнике бкад_номенкл не создавалось (есть 2 позиции таких что и там и там наименование)
нужно

для нстд изд
создать в бкад_ном номенклатуру равную итемнаме
в ест_итемс найти по ид_наме_ресале и вставить созданный айди в ид_наме, группу 109, еди изм 1
в ор_итемся снять д/к

для стд
--для ор_стд_итемся с ид_естимате поменять ид_естимате но 0  --это сдлает изделие нестандартным
для ор_стд_итемся с ид_естимате поменять ид_естимате но 100  --создадим группу стд изделий На удаление
и меняем ресале в ор_стд_итемс на 0
--создать в бкад_ном номенклатуру равную итемнаме в в_ор_стд_итемс для них 
--в ест_итемс найти по ид_наме_ресале и вставить созданный айди в ид_наме, группу 109, еди изм 1
в ор_итемся снять д/к

*/

select id, ornum, dt_beg, itemname, std from v_order_items where qnt > 0 and resale = 1 order by dt_beg desc;
--18543,М240383,29/02/2024,Ремонтный набор для направляющей витрины,0
select id from or_std_items where name = 'Ремонтный набор для направляющей витрины';  --1121
select * from estimate_items where id_name_resale=1121;  --id30238 est 7438
select * from bcad_nomencl where name = 'Ремонтный набор для направляющей витрины'; --null

--совпадают в базе бкад и изделий
select
  b.name,
  b.id
from
  bcad_nomencl b,
  v_order_items i
where
  i.fullitemname = b.name  --i.itemname = b.name
  and i.resale = 1;
  --2 names
--    Металлический ящик (сейф AIKO SL-65T)   - нигде не используется, поменяем нейм
--    Ключ для крючка с стоп локом    - в трех заказах втч в итм, менять нельзя    идбнаме=1976 
select * from v_or_std_items where name = 'Ключ для крючка с стоп локом';  --900 нестандартный
select id from v_order_items where nstd = 1 and itemname = 'Ключ для крючка с стоп локом';  --7 строк
  
--  bcad_groups    на удаление =109  

--нст Н240359_015     Корзина для мусора металл 350х295 мм._ДК
select id from or_std_items where name = 'Корзина для мусора металл 350х295 мм._ДК';  --76

select count(id) from estimate_items where id_name_resale is not null order by id desc;

--в or_std_items есть и признак resale и айди формата покупных. как выяснилось, они совпадают.
select count(*) from or_std_items where (nvl(resale,0) = 1)and(id_or_format_estimates <> 1) or (nvl(resale,0) = 0)and(id_or_format_estimates = 1); --0

-----------------------------------------------------------
--убрать д/к, добавить пустые сметы
--select * from estimate_items wher id_name_resale is not null;
select * from order_items where resale = 1;

alter table order_items drop column id_itm_group;

--create or replace procedure p_CreateEstimateItem(
--create or replace procedure P_CopyEstimate (

alter table estimates add isempty number(1) default 0;

alter table or_std_items drop column resale;
alter table or_std_items drop column setofpan; 
alter table or_std_items drop column sgp;  

alter table or_std_items add r0 number(1) default 0; 
alter table or_std_items add wo_estimate number(1) default 0; 

--create or replace view v_order_items as (
--create or replace view v_or_std_items as (

alter table order_items drop column resale;
alter table order_items add wo_estimate number(1) default 0;
alter table order_items add r0 number(1) default 0; 

alter table bcad_groups add is_production number(1) default 0; 



--create or replace view v_or_std_items 
--все функции создания/модификации смет
--все вью смет, заказов, ордерстажес

----
--выполнить после преобразования базы из дельфи
--остались сметы на бывшие дк - удалиить
select i.name, e.* 
from estimates e, or_std_items i
where 
i.id_or_format_estimates = 0 and i.id = e.id_std_item;


select id, name, null from or_std_items where id_or_format_estimates = 1;

select id from estimates where isempty = 1;


select * from v_or_std_items where id_or_format_estimates = 0;  --900 нестандартный


--------------------
--2024-07-18
--------------------
select *  from or_std_items  where id_or_format_estimates = 1; --нет
select * from estimate_items where id_name_resale is not null;
select * from order_items where resale = 1; --нет

/*
не создал группу бкад На удаление, и стд изделия д/к туда не переместились
select * from estimate_items where id_name_resale is not null;
это еще можно сделать

почему-то не создались номенклатура бкад по нестандартным изделиям на основе паспорта заказа
(должна кончаться на _ а в остальном совпадать с именем изделия)
также можем вытащить из заказов по типу нст и смете из одной позиции по имени равной наименованию заказа
до апреля все
*/

update bcad_groups set is_production = 1 where id in (104,108);








--------------------------------------------------------------------------------
/* пересоздать:
v_bcad_nomencl
v_bcad_nomencl_add
v_itm_ext_nomencl
v_spl_minremains
*/


--------------------------------------------------------------------------------
    


--trg_adm_mailing_bu



select s.id, s.control_date, s.num, s.name_org, s.quantity_main, i.fact_quantity, s.quantity_main - i.fact_quantity as rest
from 
(select 
ss.id_nomencl as id_n, ss.quantity, ss.id_sp_schet as id, round(ss.quantity * ns.base_unit_k,2) as quantity_main, s.num, s.control_date, k.name_org  
  from dv.sp_schet s, dv.sp_schet_spec ss, dv.namenom_supplier ns, dv.kontragent k 
  where  
    s.states <> '3-Получен товар' and ss.id_sp_schet = s.id_schet and ns.id_nomencl = ss.id_nomencl 
    and ns.id_supplier = s.id_kontragent2 and s.id_kontragent2 = k.id_kontragent 
      and ss.id_nomencl = 13117 
) s, 
(select 
ii.id_nomencl as id_n, i.docid as id, round(sum(ii.fact_quantity),2) as fact_quantity, ii.id_nomencl
  from dv.in_bill i, dv.in_bill_spec ii 
  where 
    i.id_docstate = 3 and ii.id_inbill = i.id_inbill and ii.id_nomencl = 13117 
  group by i.docid, ii.id_nomencl 
) i 
where s.id = i.id (+)
and s.id_n = i.id_n(+)
and s.id_n = 13117
order by s.control_date desc
;

select * from dv.sp_schet where num = '371';
select * from dv.sp_schet_spec where id_sp_schet = 11085;
select * from dv.sp_schet_spec where id_sp_schet = 7872;

create or replace view v_spl_rezerv_detail as select
  s.id, 
  s.control_date,
  s.date_registr, 
  s.num, 
  s.name_org, 
  s.quantity_main, 
  i.fact_quantity, 
  s.quantity_main - i.fact_quantity as rest, 
  s.id_n
from 
(select 
ss.id_nomencl as id_n, ss.quantity, ss.id_sp_schet as id, round(ss.quantity * nvl(ns.base_unit_k, 1),2) as quantity_main, k.name_org, s.* --, s.num, s.control_date  
  from dv.sp_schet s, dv.sp_schet_spec ss, dv.kontragent k, dv.namenom_supplier ns 
  where  
    s.states <> '3-Получен товар' 
    and ss.id_sp_schet = s.id_schet 
    and ns.id_supplier (+) = s.id_kontragent2 
    and ns.id_nomencl (+) = ss.id_nomencl-- and ns.id_base_unit(+) = ss.id_unit
    and s.id_kontragent2 = k.id_kontragent 
    and s.id_docstate = 3  --счета многие не проведены, но при этом они используются в расчетах в итм все равно 
    and control_date >= to_date('01.07.2024', 'DD.MM.YYYY')
) s, 
(select 
ii.id_nomencl as id_n, i.docid as id, round(sum(ii.fact_quantity),2) as fact_quantity, ii.id_nomencl
  from dv.in_bill i, dv.in_bill_spec ii 
  where 
    i.id_docstate = 3 and ii.id_inbill = i.id_inbill 
  group by i.docid, ii.id_nomencl 
) i 
where s.id = i.id (+)
and s.id_n = i.id_n(+)
order by s.control_date desc
;

/*==============================================================================
  проверка рассогласования позиций в специикации заказа с общим количеством
  (максимальная позиция не соотвествует количеству позиций)
*/
select 
  id_order,
  max(pos),
  count(*) 
from 
  order_items i 
where
  id_order < 0
  or 1 = 1 
group by
  id_order
having   
  count(*) <> max(pos)
; 



--================================================================================

delete from bcad_nomencl where name = 'ТШ.П_Обрешетка большая';

/*
================================================================================
2024-08-31
d_adm:  P_SetGridLabel
v_orders
v_order_items

v_spl_nom_on_inbill
v_spl_nom_on_demand
исправить даты отсечки во вьюхах
пересоздать вьюхи по снабжению
*/
alter table orders add sync_with_itm number(1) default 1; --если 1, то синхронизируем заказа с ИТМ
--update orders set sync_with_itm = 0 where id = 2866;
select * from orders where id_itm is not null and sync_with_itm = 0;

update orders set area = null where id < 0;

select * from order_items where id_order = -82 order by pos;


select pos from order_items i, orders o where o.id = i.id_order and o.templatename = 'OZON Производство' order by pos asc;



--update order_items set pos = pos - 2 where id_order = -82 and pos >= 15;

/*

2025-06-03



order_stages
v_order_finreport_inprod
*/
