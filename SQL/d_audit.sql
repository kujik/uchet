/*

журнал выполнения сроков конструкторами/технологами
формирется на основе дат в журнале заказов (по слешам, в order_items), для слешей в которых присутствуют кнс/тхн.
плановые даты формируются на основании регламента заказа





*/

--таблиц лога изменения объектов заказа пользователями
--alter table orders_audit add is_correction number(1) default 1;
create table orders_audit (
  id number(11),
  id_user number(11),
  type number,        --тип объекта (1-заказ,2-смета,3-док.кнс,4-док.тхн)  
  name varchar(100),  --наименование объекта
  dt date,            --дата и время события
  is_correction number(1) default 1, --прзнак что это измениене документа, а не первоначальное создание
  changes varchar(4000),  --что было изменено 
  constraint pk_orders_audit primary key (id),
  constraint fk_orders_audit_id_user foreign key (id_user) references adm_users(id)
);   
  
create sequence sq_orders_audit nocache start with 1;

create or replace trigger trg_orders_audit_bi_r before insert on orders_audit for each row
begin
  :new.id := sq_orders_audit.nextval;
end;
/

create or replace view v_rep_orders_audit as 
--отчет по соблюдению сроков обработки заказов конструкторами и технологами
select
  a.*,
  trunc(a.dt) as dt_date,
  to_char(dt, 'HH24:MI:SS') as dt_time,
  u.name as username,
  decode(is_correction, 0, 'добавление', 'изменение') as correction,
  decode(type, 1, 'заказ', 2, 'смета', 3, 'документы КНС', 4, 'документы ТХН') as typename
from
  orders_audit a,
  adm_users u
where
  u.id = a.id_user
;      


--------------------------------------------------------------------------------
--create or replace view v_rep_orders_overdue_kns_thn as 
--отчет по соблюдению сроков обработки заказов конструкторами и технологами
select
  t.*,
  oi.slash,
  o.dt_beg,
  o.dt_otgr,
  o.dt_beg + ri.day_end - 1 as dt_to_sgp_by_reglament,
  o.dt_to_sgp,
  -(nvl(o.dt_to_sgp, trunc(sysdate)) - (o.dt_beg + ri.day_end - 1)) as to_sgp_overdue_days, 
  o.project,
  o.customer,
  oi.itemname,
  u.name
from
(select
  'Конструктор загрузка' as type,
  oi.id_order, 
  oi.id as id_order_item,
  oi.id_kns as id_user,
  o.dt_beg + ri.day_end - 1 as dt_by_reglament,
  oi.dt_kns as dt_fact,
  -(nvl(oi.dt_kns, trunc(sysdate)) - (o.dt_beg + ri.day_end - 1)) as overdue_days 
from
  v_orders o,
  order_items oi,
  order_reglaments r,
  order_reglament_items ri
where
  o.dt_beg > date '2026-03-01' and
  nvl(oi.id_kns, -1) > 0
  and o.id_reglament is not null 
  and oi.id_order = o.id
  and o.id_reglament = r.id
  and ri.id_reglament = r.id and ri.id_work_cell_type = 1
union all  
select
  'Конструктор смета' as type,
  oi.id_order,
  oi.id as id_order_item,
  oi.id_kns as id_user,
  o.dt_beg + ri.day_end - 1 as dt_by_reglament,
  es.dt as dt_fact,
  -(nvl(es.dt_, trunc(sysdate)) - (o.dt_beg + ri.day_end - 1)) as overdue_days 
from
  v_orders o,
  order_items oi,
  estimates es,
  order_reglaments r,
  order_reglament_items ri
where
  o.dt_beg > date '2026-03-01' and
  nvl(oi.id_kns, -1) > 0
  and oi.wo_estimate <> 1
  and es.dt is null or dt_est is not null  --уитываем строки, по которым сметы еще не подгружены или в любом случае если подгружены в ручном режиме
  and o.id_reglament is not null 
  and oi.id_order = o.id
  and o.id_reglament = r.id
  and oi.id = es.id_order_item (+) 
  and ri.id_reglament = r.id and ri.id_work_cell_type = 1
union all  
select
  'Технолог загрузка' as type,
  oi.id_order, 
  oi.id as id_order_item,
  oi.id_thn as id_user,
  o.dt_beg + ri.day_end - 1 as dt_by_reglament,
  oi.dt_thn as dt_fact,
  -(nvl(oi.dt_thn, trunc(sysdate)) - (o.dt_beg + ri.day_end - 1)) as overdue_days 
from
  v_orders o,
  order_items oi,
  order_reglaments r,
  order_reglament_items ri
where
  o.dt_beg > date '2026-03-01' and
  nvl(oi.id_thn, -1) > 0
  and o.id_reglament is not null 
  and oi.id_order = o.id
  and o.id_reglament = r.id
  and ri.id_reglament = r.id and ri.id_work_cell_type = 2 
union all  
select
  'Технолог документы' as type,
  oi.id_order, 
  oi.id as id_order_item,
  oi.id_thn as id_user,
  o.dt_beg + ri.day_end - 1 as dt_by_reglament,
  oi.dt_doc as dt_fact,
  -(nvl(oi.dt_doc, trunc(sysdate)) - (o.dt_beg + ri.day_end - 1)) as overdue_days 
from
  v_orders o,
  v_order_items oi,
  order_reglaments r,
  order_reglament_items ri
where
  o.dt_beg > date '2026-03-01' and
  nvl(oi.id_thn, -1) > 0
  and o.id_reglament is not null 
  and oi.id_order = o.id
  and o.id_reglament = r.id
  and ri.id_reglament = r.id and ri.id_work_cell_type = 7 --планирование
) t,
  v_orders o,
  v_order_items oi,
  order_reglaments r,
  order_reglament_items ri,
adm_users u
where
  o.dt_beg > date '2026-03-01' and
  oi.qnt <> 0
  and t.id_order = o.id
  and t.id_order_item = oi.id
  and o.id_reglament = r.id
  and ri.id_reglament = r.id and ri.id_work_cell_type = 5  --приемка на СГГ
  and u.id = oi.id_thn and u.id > 0 
;