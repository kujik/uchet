/*
ѕЋјЌќ¬џ≈ » ѕ–≈ƒ¬ј–»“≈Ћ№Ќџ≈ «ј ј«џ

на данный момент заказ может быть создан только по шаблону производственного паспорта 
и состо€ть из стандартных изделий.

*/


--таблица плановых заказов
--drop table planned_orders cascade constraints;
alter table planned_orders add dt_end date;
create table planned_orders (
  id number(11),                     
  id_template number(11),                 -- айди шаблона, на основании которого создан плановый заказ
  num number(6),                          -- номер заказа 250002 
  is_plannedorder number(1) default(1),   -- €вл€етс€ плановым заказом
  is_preorder number(1) default(0),       -- €вл€етс€ предзаказом
  project varchar2(400),                  -- название проекта
  id_or_format_estimates number(11),      -- айди типа стандартной сметы 
  id_user number(11),                     -- айди человека, оформившего заказ
  dt_start date,                          -- дата, с какого момента действует палнирование по заказу (год и мес€ц)
  dt_end date,                            -- дата, до которой действует палнирование по заказу (год и мес€ц)
  dt date,                                -- дата создани€ паспорта
  dt_change date,                         -- дата изменени€ паспорта 
  sum number,                             -- итогова€ сумма заказа
  active number(1) default 1,             -- заказ учавствует в расчетах          
  comm varchar(4000),                     -- произвольный комментарий к заказу                           
  constraint pk_planned_orders primary key (id),
  constraint fk_planned_orders_manager foreign key (id_user) references adm_users(id),
  constraint fk_planned_orders_estimates foreign key (id_or_format_estimates) references or_format_estimates(id)
);

create unique index idx_planned_order_num on planned_orders(num);

create sequence sq_planned_orders nocache;

create or replace trigger trg_planned_orders_bi_r
  before insert on planned_orders for each row
begin
  --зададим айди, и номер (с учетом года), если тольько он не передан €вно
  select sq_planned_orders.nextval into :new.id from dual;
  if (:new.num is null) and (:new.dt is not null) then
    P_GetDocumNum('planned_order', to_number(to_char(:new.dt, 'YYYY')), :new.num, 0, 1, 4);
--    :new.num := to_char(:new.dt, 'YY') || substr('0000' || :new.num, -4); 
  end if;
end;
/


--insert into planned_orders (dt, project) values (sysdate, 'qqqцц');


create or replace view v_planned_orders as
select
--вью журнала плановых заказов
  po.*,
  nvl2(po.id_template, 1, 0) as std,
  o.templatename,
  nvl(o.project, po.project) as projectname,
  orf.id as id_format,
  orf.name as formatname,
  u.name as username
from
  planned_orders po,
  orders o,
  or_format_estimates orfe,
  or_formats orf,
  adm_users u
where
  po.id_template = o.id (+)
  and po.id_or_format_estimates = orfe.id (+)
  and orfe.id_format = orf.id (+)
  and po.id_user = u.id
;

create or replace view v_planned_orders_w_sum as
select
--вью журнала плановых заказов с выводом суммы заказа
--(сумма расчитываетс€ на основании цен из справочника стандартных изделий)
  po.*,
  nvl2(po.id_template, 1, 0) as std,
  o.templatename,
  nvl(o.project, po.project) as projectname,
  orf.id as id_format,
  orf.name as formatname,
  u.name as username,
  poi.sum_all,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum1 else 0 end as sum1,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum2 else 0 end as sum2,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum3 else 0 end as sum3,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum4 else 0 end as sum4,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum5 else 0 end as sum5,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum6 else 0 end as sum6,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum7 else 0 end as sum7,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum8 else 0 end as sum8,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum9 else 0 end as sum9,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum10 else 0 end as sum10,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum11 else 0 end as sum11,
  case when extract(year from dt_start) =  extract(year from sysdate) then poi.sum12 else 0 end as sum12
from
  planned_orders po,
  orders o,
  or_format_estimates orfe,
  or_formats orf,
  adm_users u,
  (select id_planned_order, 
   sum(osi.price * (nvl(poi.qnt1,0)+nvl(poi.qnt2,0)+nvl(poi.qnt3,0)+nvl(poi.qnt4,0)+nvl(poi.qnt5,0)+nvl(poi.qnt6,0)+
     nvl(poi.qnt7,0)+nvl(poi.qnt8,0)+nvl(poi.qnt9,0)+nvl(poi.qnt10,0)+nvl(poi.qnt11,0)+nvl(poi.qnt12,0))) 
   as sum_all,
   sum(osi.price * nvl(poi.qnt1,0)) as sum1, 
   sum(osi.price * nvl(poi.qnt2,0)) as sum2, 
   sum(osi.price * nvl(poi.qnt3,0)) as sum3, 
   sum(osi.price * nvl(poi.qnt4,0)) as sum4, 
   sum(osi.price * nvl(poi.qnt5,0)) as sum5, 
   sum(osi.price * nvl(poi.qnt6,0)) as sum6, 
   sum(osi.price * nvl(poi.qnt7,0)) as sum7, 
   sum(osi.price * nvl(poi.qnt8,0)) as sum8, 
   sum(osi.price * nvl(poi.qnt9,0)) as sum9, 
   sum(osi.price * nvl(poi.qnt10,0)) as sum10, 
   sum(osi.price * nvl(poi.qnt11,0)) as sum11, 
   sum(osi.price * nvl(poi.qnt12,0)) as sum12 
   from planned_order_items poi, or_std_items osi
   where poi.id_std_item = osi.id (+)  
   group by id_planned_order) poi   
where
  po.id_template = o.id (+)
  and po.id_or_format_estimates = orfe.id (+)
  and orfe.id_format = orf.id (+)
  and po.id_user = u.id
  and po.id = poi.id_planned_order (+)
;      
 
select * from v_planned_orders_w_sum;     

alter table planned_order_items add price number(11,2);
create table planned_order_items (
  id number(11),                     
  id_planned_order number(11),           -- айди родительского планового заказа 
  id_std_item number(11),                -- айди стандартного издели€ 
  pos number(6),                         -- номер позиции
  name varchar(400),                     -- наименование позиции, если это нестандарт 
  comm varchar(400),                     -- произвольный комментарий к позиции
  price number(11,2),
  qnt1 number(12,3),                         
  qnt2 number(12,3),                         
  qnt3 number(12,3),                         
  qnt4 number(12,3),                         
  qnt5 number(12,3),                         
  qnt6 number(12,3),                         
  qnt7 number(12,3),                         
  qnt8 number(12,3),                         
  qnt9 number(12,3),                         
  qnt10 number(12,3),                         
  qnt11 number(12,3),                         
  qnt12 number(12,3),
  constraint pk_planned_order_itemss primary key (id),
  constraint fk_planned_order_items_id_po foreign key (id_planned_order) references planned_orders(id) on delete cascade,
  constraint fk_planned_order_items_id_si foreign key (id_std_item) references or_std_items(id)
);

--create unique index idx_planned_order_num on planned_orders(num);

create sequence sq_planned_order_items nocache;

create or replace trigger trg_planned_order_items_bi_r
  before insert on planned_order_items for each row
begin
  select sq_planned_order_items.nextval into :new.id from dual;
end;
/

create or replace view v_planned_order_items as
select
--вью спецификации планового заказа
  poi.*,
  osi.name as itemname,
  osi.price as itemprice,
  nvl(poi.qnt1,0)+nvl(poi.qnt2,0)+nvl(poi.qnt3,0)+nvl(poi.qnt4,0)+nvl(poi.qnt5,0)+nvl(poi.qnt6,0)+
  nvl(poi.qnt7,0)+nvl(poi.qnt8,0)+nvl(poi.qnt9,0)+nvl(poi.qnt10,0)+nvl(poi.qnt11,0)+nvl(poi.qnt12,0) as qnt
from
  planned_order_items poi,
  or_std_items osi
where
  poi.id_std_item = osi.id (+)
;




drop table planned_order_estimate12 cascade constraints;
create table planned_order_estimate12 (
  id number(11),                     
--  id_name number(11),                          --наименование бкад
--  id_unit number(11),                          --единица измерени€
  name varchar2(400),
  unit varchar2(100),
  qnt number(15,5),                            --количество на все издели€, по учету 
  qnt1 number(12,3),                         
  qnt2 number(12,3),                         
  qnt3 number(12,3),                         
  qnt4 number(12,3),                         
  qnt5 number(12,3),                         
  qnt6 number(12,3),                         
  qnt7 number(12,3),                         
  qnt8 number(12,3),                         
  qnt9 number(12,3),                         
  qnt10 number(12,3),                         
  qnt11 number(12,3),                         
  qnt12 number(12,3),                         
  or1 varchar2(4000),                         
  or2 varchar2(4000),                         
  or3 varchar2(4000),                         
  or4 varchar2(4000),                         
  or5 varchar2(4000),                         
  or6 varchar2(4000),                         
  or7 varchar2(4000),                         
  or8 varchar2(4000),                         
  or9 varchar2(4000),                         
  or10 varchar2(4000),                         
  or11 varchar2(4000),                         
  or12 varchar2(4000),                         
  constraint planned_order_estimate12 primary key (name)
--  constraint planned_order_estimate12 primary key (id_name),
  --constraint fk_pl_order_estimate12_name foreign key (id_name) references bcad_nomencl(id),
  --constraint fk_pl_order_estimate12_unit foreign key (id_unit) references bcad_units(id)
);

create or replace view v_planned_order_estimate12 as
select
  p.*,
  nvl(qnt1,0)+nvl(qnt2,0)+nvl(qnt3,0)+nvl(qnt4,0)+nvl(qnt5,0)+nvl(qnt6,0)+nvl(qnt7,0)+nvl(qnt8,0)+nvl(qnt9,0)+nvl(qnt10,0)+nvl(qnt11,0)+nvl(qnt12,0) as qnt_all
from
  planned_order_estimate12 p
;


--drop table planned_order_estimate3 cascade constraints;
alter table planned_order_estimate3 add qnt0 number(12,3);
create table planned_order_estimate3 (
  id_nomencl number(11),                     
  name varchar2(400),
  qnt0 number(12,3),                         
  qnt1 number(12,3),                         
  qnt2 number(12,3),                         
  qnt3 number(12,3),                         
  or1 varchar2(4000),                         
  or2 varchar2(4000),                         
  or3 varchar2(4000)                         
);

--------------------------------------------------------------------------------
