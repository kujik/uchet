--------------------------------------------------------------------------------
-- финансовый отчет по запущенным за прошлый день заказам
--------------------------------------------------------------------------------

select * from v_orders_fin_monitoring;
create or replace view v_orders_fin_monitoring as --!!!
select
--финансовый отчет по запущенным за вчерашний день заказам
--вызывается отдельно для производства и продажи t.order_type
--сгруппирован по изделиям и продажной цене (идет накопительно по изделиям, но при разной цене выделяются строки)
--все цены без ндс  
  t.order_type,  -- -1 П, 0 - О
  t.dt_beg,
  t.ornums,
  t.customer,
  t.fullname,
  t.qnt,
  t.price,
  t.price_std,   --цена в справочнике
  case when t.price_std > t.price then t.price - t.price_std else null end as price_diff,  --разница между продажной и справочной
  round(t.price * t.qnt, 2) as summ,
  t.sum0,
  t.labor_intensity_0,
  t.labor_cost_0,
  t.labor_intensity_2,
  t.labor_cost_2,
  t.sum0 + t.labor_cost_0 + labor_cost_2 as prime_cost,
  case when t.price = 0 then null else round((t.sum0) / (t.price * t.qnt) * 100, 1) end as sum0_percent,
  case when t.price = 0 then null else round((t.labor_cost_0) / (t.price * t.qnt) * 100, 1) end as labor_cost_0_percent,
  case when t.price = 0 then null else round((t.labor_cost_2) / (t.price * t.qnt) * 100, 1) end as labor_cost_2_percent,
  case when t.price = 0 then null else round((t.sum0 + t.labor_cost_0 + labor_cost_2) / (t.price * t.qnt) * 100, 1) end as prime_cost_percent
from (  
select
  decode(oi.id_organization, -1, -1, 0) as order_type,
  max(dt_beg) as dt_beg,
  listagg(oi.ornum, ', ') within group (order by oi.ornum) as ornums,
  listagg(oi.customer, ', ') within group (order by oi.ornum) as customer,
  si.fullname,
  --цена по справочнику изделий без ндс (она там с ндс для отгрузочных и без - для производственных)
  max(round(case when oi.id_organization <> -1 then si.price / 1.22 else si.price end)) as price_std,
  sum(oi.qnt) as qnt,
  round(oi.cost_wo_nds / oi.qnt, 0) as price,
  sum(round(oi.sum0 / 1.22, 0)) as sum0,
  sum(si.labor_intensity_0 * oi.qnt) as labor_intensity_0,
  sum(si.labor_cost_0 * oi.qnt) as labor_cost_0,
  sum(si.labor_intensity_2 * oi.qnt) as labor_intensity_2,
  sum(si.labor_cost_2 * oi.qnt) as labor_cost_2
from
  v_order_items oi,
  v_or_std_items si
where
  oi.id_std_item = si.id
  and qnt <> 0
  --and oi.id_organization <> -1  --!!
  and oi.dt_beg = trunc(sysdate) - 1
group by
  si.fullname, round(oi.cost_wo_nds / oi.qnt, 0), decode(oi.id_organization, -1, -1, 0)  
order by
  si.fullname
) t    
;


--------------------------------------------------------------------------------
-- финансовый отчет по изменениям в стандартных изделиях
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--материализованное представление стандартных изделий
create materialized view vm_or_std_items as
  select * from v_or_std_items;

select * from vm_or_std_items;


--------------------------------------------------------------------------------
--промежуточное представление, возвращающее айди затрагиваемых стандартных 
--изделий при изменении себестоимости по участку
create or replace view v_std_items_changed_cost_labor as
select distinct
--промежуточное представление, возвращающее айди затрагиваемых стандартных изделий 
--id изделий с изменением себестоимости в течении суток и наличием трудозатрат по тому же участку
  si.id
from
  or_std_items si
where
  exists (
    select 1
    from or_std_labor_intensity_cost c
    where exists (
      select 1
      from or_std_labor_intensity l
      where l.id = si.id
        and l.id_area = c.id_area
        and (
          (c.dt_changed1 > trunc(sysdate)-1 and nvl(l.i1, 0) <> 0) or
          (c.dt_changed2 > trunc(sysdate)-1 and nvl(l.i2, 0) <> 0) or
          (c.dt_changed3 > trunc(sysdate)-1 and nvl(l.i3, 0) <> 0) or
          (c.dt_changed4 > trunc(sysdate)-1 and nvl(l.i4, 0) <> 0) or
          (c.dt_changed5 > trunc(sysdate)-1 and nvl(l.i5, 0) <> 0) or
          (c.dt_changed6 > trunc(sysdate)-1 and nvl(l.i6, 0) <> 0) or
          (c.dt_changed7 > trunc(sysdate)-1 and nvl(l.i7, 0) <> 0) or
          (c.dt_changed8 > trunc(sysdate)-1 and nvl(l.i8, 0) <> 0) or
          (c.dt_changed9 > trunc(sysdate)-1 and nvl(l.i9, 0) <> 0) or
          (c.dt_changed10 > trunc(sysdate)-1 and nvl(l.i10, 0) <> 0) or
          (c.dt_changed11 > trunc(sysdate)-1 and nvl(l.i11, 0) <> 0) or
          (c.dt_changed12 > trunc(sysdate)-1 and nvl(l.i12, 0) <> 0) or
          (c.dt_changed13 > trunc(sysdate)-1 and nvl(l.i13, 0) <> 0) or
          (c.dt_changed14 > trunc(sysdate)-1 and nvl(l.i14, 0) <> 0) or
          (c.dt_changed15 > trunc(sysdate)-1 and nvl(l.i15, 0) <> 0) or
          (c.dt_changed16 > trunc(sysdate)-1 and nvl(l.i16, 0) <> 0)
        )
    )
  );

--------------------------------------------------------------------------------
create or replace view v_stditems_fin_monitoring as --!!!
with
  --отображает текущее состояние финансовых параметров по стандартным изделиям,
  --и их состояние на вчерашний день (точнее, из материализованного представления)
  
  --но какие изделия показывать, поределяется событиями:
  --редактирования сметы на изделий, либо сметы, являющейся сметной позицией данного изделия.
  --(при добавлении/удалении строок, изменение количества на ед. или номеклатуры)
  --редактированием трудоемкости по любой площадке для изделия
  --реадктированием цены работы по тем учаткам, трудоемкость по кторым введена в смете 

  --список изменённых id /*+ materialize */
  changed_items as (
    select distinct  id from (
      --изменение смет непосредственно по изделиям или на изделия в их составе
      select e.id_std_item as id
      from
        estimates e
      where
        e.id_std_item is not null and 
        ((nvl(e.dt_changed, date '2000-01-01') > trunc(sysdate) - 1) or (nvl(e.dt_changed_depend, date '2000-01-01') > trunc(sysdate) - 1))
      union
      --изменение трудоемкости работы по изделию
      select id from or_std_labor_intensity where dt_changed > trunc(sysdate) - 1 
      union
      --стандартные изделия, затрагиваемые изменением стоимости работы
      select id from v_std_items_changed_cost_labor
    )
  ),
  all_data as (
  select 
      c.id,
      c.prefix,
      c.or_format_name,
      c.or_format_estimate_name,
      c.fullname,
      c.priceraw_wo_nds,
      c.material_percent,
      c.labor_cost_0,
      c.labor_percent_0,
      c.labor_cost_2,
      c.labor_percent_2,
      c.labor_cost,
      c.labor_percent,
      o.priceraw_wo_nds as priceraw_wo_nds_old,
      o.material_percent as material_percent_old,
      o.labor_cost_0 as labor_cost_0_old,
      o.labor_percent_0 as labor_percent_0_old,
      o.labor_cost_2 as labor_cost_2_old,
      o.labor_percent_2 as labor_percent_2_old,
      o.labor_cost as labor_cost_old,
      o.labor_percent as labor_percent_old
  from 
    v_or_std_items c,
    vm_or_std_items o,
    changed_items ch
    where
      c.id = ch.id
      and c.id = o.id (+)
      and c.id = ch.id
  )
  select * from all_data     
; 

-------------------------------------------------------------------------------
--материализованное представление по финансовым показателям заказов за вчерашний день

drop materialized view vm_orders_fin_monitoring;
create materialized view vm_orders_fin_monitoring as
select
--финансовый отчет по запущенным за вчерашний день заказам
--вызывается отдельно для производства и продажи t.order_type
--сгруппирован по изделиям и продажной цене (идет накопительно по изделиям, но при разной цене выделяются строки)
--все цены без ндс  
  t.order_type,  -- -1 П, 0 - О
  t.ornums,
  t.customer,
  t.fullname,
  t.qnt,
  t.price,
  t.price_std,   --цена в справочнике
  case when t.price_std > t.price then t.price - t.price_std else null end as price_diff,  --разница между продажной и справочной
  round(t.price * t.qnt, 2) as summ,
  t.sum0,
  t.labor_intensity_0,
  t.labor_cost_0,
  t.labor_intensity_2,
  t.labor_cost_2,
  t.sum0 + t.labor_cost_0 + labor_cost_2 as prime_cost,
  case when t.price = 0 then null else round((t.sum0) / (t.price * t.qnt) * 100, 1) end as sum0_percent,
  case when t.price = 0 then null else round((t.labor_cost_0) / (t.price * t.qnt) * 100, 1) end as labor_cost_0_percent,
  case when t.price = 0 then null else round((t.labor_cost_2) / (t.price * t.qnt) * 100, 1) end as labor_cost_2_percent,
  case when t.price = 0 then null else round((t.sum0 + t.labor_cost_0 + labor_cost_2) / (t.price * t.qnt) * 100, 1) end as prime_cost_percent
from (  
select
  decode(oi.id_organization, -1, -1, 0) as order_type,
  listagg(oi.ornum, ', ') within group (order by oi.ornum) as ornums,
  listagg(oi.customer, ', ') within group (order by oi.ornum) as customer,
  si.fullname,
  --цена по справочнику изделий без ндс (она там с ндс для отгрузочных и без - для производственных)
  max(round(case when oi.id_organization <> -1 then si.price / 1.22 else si.price end)) as price_std,
  sum(oi.qnt) as qnt,
  round(oi.cost_wo_nds / oi.qnt, 0) as price,
  sum(round(oi.sum0 / 1.22, 0)) as sum0,
  sum(si.labor_intensity_0 * oi.qnt) as labor_intensity_0,
  sum(si.labor_cost_0 * oi.qnt) as labor_cost_0,
  sum(si.labor_intensity_2 * oi.qnt) as labor_intensity_2,
  sum(si.labor_cost_2 * oi.qnt) as labor_cost_2
from
  v_order_items oi,
  v_or_std_items si
where
  oi.id_std_item = si.id
  and qnt <> 0
  --and oi.id_organization <> -1  --!!
  and oi.dt_end is null or dt_end = trunc(sysdate) - 7
group by
  si.fullname, round(oi.cost_wo_nds / oi.qnt, 0), decode(oi.id_organization, -1, -1, 0)  
order by
  si.fullname
) t    
;      
      
exec dbms_mview.refresh('vm_orders_fin_monitoring', 'c');  


create table orders_fin_monitoring_snapshot (
  snapshot_date date,                    -- дата снимка
  order_type    number,
  ornums        varchar2(4000),
  customer      varchar2(4000),
  fullname      varchar2(1000),
  qnt           number,
  price         number,
  price_std     number,
  price_diff    number,
  summ          number,
  sum0          number,
  labor_intensity_0 number,
  labor_cost_0     number,
  labor_intensity_2 number,
  labor_cost_2     number,
  prime_cost       number,
  sum0_percent     number,
  labor_cost_0_percent number,
  labor_cost_2_percent number,
  prime_cost_percent   number
);


create or replace procedure p_snapshot_fin_monitoring is
begin
  -- удаляем старый снимок за сегодня (если вдруг запустили повторно)
  delete from orders_fin_monitoring_snapshot where snapshot_date = trunc(sysdate);
  -- вставляем текущие данные из материализованного представления
  insert into orders_fin_monitoring_snapshot (
    snapshot_date, 
    order_type,    
    ornums,
    customer,      
    fullname,      
    qnt,           
    price,         
    price_std,
    price_diff,    
    summ,          
    sum0,          
    labor_intensity_0,
    labor_cost_0,     
    labor_intensity_2,
    labor_cost_2,     
    prime_cost,       
    sum0_percent,     
    labor_cost_0_percent, 
    labor_cost_2_percent, 
    prime_cost_percent 
  )  
  select trunc(sysdate), t.* from vm_orders_fin_monitoring t;
  commit;
end;
/

exec p_snapshot_fin_monitoring;


-- =============================================================================
   
    
    --create or replace view v_fin_monitoring_changes as
with
  -- материализуем список изменённых id (через хинт materialize)
  changed_order_items as (
    select /*+ materialize */ distinct oi.id
    from order_items oi
    join estimates e on e.id_order_item = oi.id
    where e.dt_changed > trunc(sysdate) - 1
  ),
  -- текущие данные с хинтами push_pred и no_merge
  current_data as (
    select /*+ materialize */
      t.order_type,
      t.ornums,
      t.customer,
      t.fullname,
      t.qnt,
      t.price,
      t.price_std,
      case when t.price_std > t.price then t.price - t.price_std else null end as price_diff,
      round(t.price * t.qnt, 2) as summ,
      t.sum0,
      t.labor_intensity_0,
      t.labor_cost_0,
      t.labor_intensity_2,
      t.labor_cost_2,
      t.sum0 + t.labor_cost_0 + t.labor_cost_2 as prime_cost,
      case when t.price = 0 then null else round((t.sum0) / (t.price * t.qnt) * 100, 1) end as sum0_percent,
      case when t.price = 0 then null else round((t.labor_cost_0) / (t.price * t.qnt) * 100, 1) end as labor_cost_0_percent,
      case when t.price = 0 then null else round((t.labor_cost_2) / (t.price * t.qnt) * 100, 1) end as labor_cost_2_percent,
      case when t.price = 0 then null else round((t.sum0 + t.labor_cost_0 + t.labor_cost_2) / (t.price * t.qnt) * 100, 1) end as prime_cost_percent
    from (
      select
        decode(oi.id_organization, -1, -1, 0) as order_type,
        listagg(oi.ornum, ', ') within group (order by oi.ornum) as ornums,
        listagg(oi.customer, ', ') within group (order by oi.ornum) as customer,
        si.fullname,
        max(round(case when oi.id_organization <> -1 then si.price / 1.22 else si.price end)) as price_std,
        sum(oi.qnt) as qnt,
        round(oi.cost_wo_nds / oi.qnt, 0) as price,
        sum(round(oi.sum0 / 1.22, 0)) as sum0,
        sum(si.labor_intensity_0 * oi.qnt) as labor_intensity_0,
        sum(si.labor_cost_0 * oi.qnt) as labor_cost_0,
        sum(si.labor_intensity_2 * oi.qnt) as labor_intensity_2,
        sum(si.labor_cost_2 * oi.qnt) as labor_cost_2
      from
        v_order_items oi,
        v_or_std_items si,
        changed_order_items ch
      where
        oi.id_std_item = si.id
        and oi.qnt <> 0
        and oi.id = ch.id
        and (oi.dt_end is null or oi.dt_end = trunc(sysdate) - 7)
      group by
        si.fullname,
        round(oi.cost_wo_nds / oi.qnt, 0),
        decode(oi.id_organization, -1, -1, 0)
    ) t
  ),
  old_data as (
    select
      s.*
    from
      orders_fin_monitoring_snapshot s,
      (select distinct order_type, fullname, price from current_data) c
    where
      s.snapshot_date = trunc(sysdate) - 0
      and s.order_type = c.order_type
      and s.fullname = c.fullname
      and s.price = c.price  )
 select *     
from
  current_data o,
  old_data old
where
  old.order_type (+) = o.order_type 
  and old.fullname (+) = o.fullname
  and old.price (+) = o.price;
;      
      
/*select
  o.order_type,
  o.ornums,
  o.customer,
  o.fullname,
  o.qnt,
  o.price,
  o.price_std,
  o.price_diff,
  o.summ,
  o.sum0,
  o.labor_intensity_0,
  o.labor_cost_0,
  o.labor_intensity_2,
  o.labor_cost_2,
  o.prime_cost,
  o.sum0_percent,
  o.labor_cost_0_percent,
  o.labor_cost_2_percent,
  o.prime_cost_percent,
  old.qnt as qnt_old,
  old.price as price_old,
  old.price_std as price_std_old,
  old.price_diff as price_diff_old,
  old.summ as summ_old,
  old.sum0 as sum0_old,
  old.labor_intensity_0 as labor_intensity_0_old,
  old.labor_cost_0 as labor_cost_0_old,
  old.labor_intensity_2 as labor_intensity_2_old,
  old.labor_cost_2 as labor_cost_2_old,
  old.prime_cost as prime_cost_old,
  old.sum0_percent as sum0_percent_old,
  old.labor_cost_0_percent as labor_cost_0_percent_old,
  old.labor_cost_2_percent as labor_cost_2_percent_old
from
  current_data o
  left join old_data old
    on old.order_type = o.order_type
    and old.fullname = o.fullname
    and old.price = o.price;
    
    
        select
      s.*
    from
      orders_fin_monitoring_snapshot s
    where
      s.snapshot_date = trunc(sysdate) ;
;*/