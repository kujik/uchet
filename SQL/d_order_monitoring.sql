/*

финансовый мониторинг заказов.

формируется почтовая рассылка с финансовыми показателями запущенных за вчерашний день заказов.
первоначально эти данные сохраняются в таблиицу orders_fin_monitoring в 23ч каждого дня
по заданbю шедулера в бд.

в отчете выводятся изделия запущенных за день заказов, сгруппированные по сумме продажи.

в программе можно посмотреть сохраненные данные (суммы будут такими, какими были за день создания)
за любой день из сохраненных.

также предусмотрен отчет по изделиям заказов, запущенным ранее, но у которых не было хотя
бы одной сметы в цепочке, и для которых в данный день появились все сметы.

также предусмотрен отчет по всем изделиям выбранного заказа. 

*/

--------------------------------------------------------------------------------
-- таблицца с финансовыми данными по заказам
-- все суммы и цены без ндс
alter table orders_fin_monitoring add priceraw_wo_nds_std number;
create table orders_fin_monitoring (
  id number(11),                        --айди
  dt date,                              --дата внесения записи
  data_type number,                     --1 - данные по запущенным заказам, 2 - данныые по заказам, по которым появились сметы, 3 - данные по конкретному заказу, 4 - данные по заказам за период 
  dt_beg date,                          --дата внесения записи 
  order_type    number,                 --тип заказа, -1 П, 0 - О
  id_order_items varchar2(4000),
  ornums        varchar2(4000),         --номера заказов для данной строки сгруппированных изделий, через разделитель 
  customer      varchar2(4000),         --покупатели, через разделитель     
  fullname      varchar2(1000),         --наименование изделия 
  qnt           number,                 --суммарное количество изделий с учетом группировки
  price         number,                 --продажная цена (по ней группировка)
  price_std     number,                 --продажная цена из справочника стандартных изделий
  price_diff    number,                 --разница реальной продажной со справочником
  summ          number,                 --сумма по продаже
  sum0          number,                 --сумма по закупке (себестоимость), на основании смет по изделиям в заказе
  priceraw_wo_nds_std number,           --цена по закупке материалов на основании сметы стандартного изделия 
  priceraw_wo_nds number,               --цена по закупке материалов, средняя для сгруппированных изделий
  labor_intensity_0 number,             --трудоемкость ПЩ, мин (сумма)
  labor_cost_0     number,              --трудоемкость ПЩ, руб (сумма)
  labor_intensity_2 number,
  labor_cost_2     number,
  prime_cost       number,              --себестоимость (сумма сырья + стоимость работы)
  sum0_percent     number,              --проценты в продажной сумме
  labor_cost_0_percent number,
  labor_cost_2_percent number,
  prime_cost_percent   number,          --общая доля всех расходов, %
  item_wo_estimate number,              --признак отсутствия сметы
  qnt_on_sgp number,                    --количество изделий (стандартных) на СГП на вечер дня  
  comm varchar2(4000),                  --комментарий (вводится в отчете)
  attentions varchar2(4000)             --выделение ячеек (вводится в отчете)  
);


create or replace view v_orders_fin_monitoring as
select
  t.*,
  decode (item_wo_estimate, 0, '', '!!!') as item_wo_estimate_st
from  
  orders_fin_monitoring t
;  


--временная таблица уровня сессии, в нее загружаются данные выборки при просмотре
--пользователем отчета за произвольный период или по заказу.
drop table temp_orders_fin_monitoring;
create global temporary table temp_orders_fin_monitoring (
  id number,
  data_type        number,
  dt               date,
  order_type     number,
  dt_beg         date,
  ornums         varchar2(4000),
  customer       varchar2(4000),
  fullname       varchar2(1000),
  qnt            number,
  price          number,
  price_std      number,
  price_diff     number,
  priceraw_wo_nds_std number,
  priceraw_wo_nds number,
  summ           number,
  sum0           number,
  labor_intensity_0 number,
  labor_cost_0     number,
  labor_intensity_2 number,
  labor_cost_2     number,
  prime_cost       number,
  sum0_percent     number,
  labor_cost_0_percent number,
  labor_cost_2_percent number,
  prime_cost_percent   number,
  item_wo_estimate number,
  qnt_on_sgp number,
  id_order_items   varchar2(4000)
) on commit preserve rows;

create sequence sq_orders_fin_monitoring start with 1 nocache;

create or replace trigger trg_orders_fin_monitoring_bi_r
  before insert on orders_fin_monitoring for each row
begin
  :new.id := sq_orders_fin_monitoring.nextval;
end;
/

--таблица, содержащая (накапливающая) айди изделий в заказах, по котоорым
--не загружены все сметы. в день, когда смета загружена, проставляется поле dt 
--drop  table order_items_wo_estimate;
create table order_items_wo_estimate (
  id_order_item number(11) unique,
  dt date,
  constraint fk_order_items_wo_estimate foreign key (id_order_item) references order_items(id)
);  

------------------------------------------------------------------------------------
-- Процедуры заполениния таблиц финансового мониторинга (работает по расписанию в бд 
------------------------------------------------------------------------------------

--update orders_fin_monitoring set price_diff = round(price_diff, 2) where price_diff is not null;
--------------------------------------------------------------------------------
--вспомогательная процедура вставки агрегированных данных
create or replace procedure p_insert_fin_monitoring_data(
  p_dt             in date,
  p_data_type      in number,
  p_use_wo_list    in number,
  p_id_order       in number default null,
  p_dt_beg_from    in date   default null,
  p_dt_beg_to      in date   default null,
  p_filter_dt_end_zero in number default 0
) is
  v_dt date := trunc(p_dt);
  v_target_table varchar2(30);
  v_data_type number;
  v_where_clause varchar2(4000);
  v_sql varchar2(4000);
  v_delete_sql varchar2(4000);
  v_use_temp boolean := false;
begin
  -- определяем режим
  if (p_id_order is not null) or
     (p_dt_beg_from is not null) or
     (p_dt_beg_to is not null) or
     (p_filter_dt_end_zero = 1) then
    v_use_temp := true;
  end if;

  if v_use_temp then
    v_target_table := 'temp_orders_fin_monitoring';
    if p_id_order is not null then
      v_data_type := 3;
    else
      v_data_type := 4;
    end if;
    -- удаляем старые записи по data_type
    v_delete_sql := 'delete from ' || v_target_table || ' where data_type = :v_data_type';
    execute immediate v_delete_sql using v_data_type;
  else
    v_data_type := p_data_type;
    v_target_table := 'orders_fin_monitoring';
    -- удаляем старые записи по dt и data_type
    v_delete_sql := 'delete from ' || v_target_table || ' where dt = :dt and data_type = :dt_type';
    execute immediate v_delete_sql using v_dt, p_data_type;
  end if;

  -- формируем условие WHERE
  if v_use_temp then
    -- режим фильтрации
    v_where_clause := '1=1';
    if p_id_order is not null then
      v_where_clause := v_where_clause || ' and oi.id_order = :id_order';
    end if;
    if p_dt_beg_from is not null then
      v_where_clause := v_where_clause || ' and oi.dt_beg >= :dt_beg_from';
    end if;
    if p_dt_beg_to is not null then
      v_where_clause := v_where_clause || ' and oi.dt_beg <= :dt_beg_to';
    end if;
    if p_filter_dt_end_zero = 1 then
      v_where_clause := v_where_clause || ' and oi.dt_end is null';
    end if;
  else
    -- стандартный режим
    if p_use_wo_list = 0 then
      v_where_clause := 'oi.dt_beg = :dt';
      --return;
    else
      v_where_clause := 'oi.id in (select id_order_item from order_items_wo_estimate where dt is null)';
    end if;
  end if;

  -- собираем основной INSERT
  v_sql := '
    insert into ' || v_target_table || ' (
      order_type,
      dt_beg,
      ornums,
      customer,
      fullname,
      qnt,
      price,
      price_std,
      price_diff,
      priceraw_wo_nds_std,
      priceraw_wo_nds,
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
      prime_cost_percent,
      item_wo_estimate,
      qnt_on_sgp,
      id_order_items,
      data_type,
      dt
    )
    select
      t.order_type,
      t.dt_beg,
      t.ornums,
      t.customer,
      t.fullname,
      t.qnt,
      t.price,
      t.price_std,
      case when t.price_std > t.price then t.price - t.price_std else null end,
      t.priceraw_wo_nds_std,
      t.priceraw_wo_nds,
      round(t.price * t.qnt, 2),
      t.sum0,
      t.labor_intensity_0,
      t.labor_cost_0,
      t.labor_intensity_2,
      t.labor_cost_2,
      t.sum0 + t.labor_cost_0 + t.labor_cost_2,
      case when t.price = 0 then null else round((t.sum0) / (t.price * t.qnt) * 100, 1) end,
      case when t.price = 0 then null else round((t.labor_cost_0) / (t.price * t.qnt) * 100, 1) end,
      case when t.price = 0 then null else round((t.labor_cost_2) / (t.price * t.qnt) * 100, 1) end,
      case when t.price = 0 then null else round((t.sum0 + t.labor_cost_0 + t.labor_cost_2) / (t.price * t.qnt) * 100, 1) end,
      t.item_wo_estimate,
      t.qnt_on_sgp,
      t.id_order_items_str,
      :dt_type,
      :dt
    from (
      select
        decode(oi.id_organization, -1, -1, 0) as order_type,
        max(oi.dt_beg) as dt_beg,
        listagg(oi.ornum, '', '') within group (order by oi.ornum) as ornums,
        listagg(oi.customer, '', '') within group (order by oi.ornum) as customer,
        si.fullname,
        max(round(si.price / 1.22, 0)) as price_std,
        sum(oi.qnt) as qnt,
        round(oi.cost_wo_nds / oi.qnt, 0) as price,
        round(max(si.priceraw_wo_nds)) as priceraw_wo_nds_std,
        round(sum(oi.sum0 / 1.22) / sum(oi.qnt)) as priceraw_wo_nds,
        sum(round(oi.sum0 / 1.22, 0)) as sum0,
        sum(si.labor_intensity_0 * oi.qnt) as labor_intensity_0,
        sum(si.labor_cost_0 * oi.qnt) as labor_cost_0,
        sum(si.labor_intensity_2 * oi.qnt) as labor_intensity_2,
        sum(si.labor_cost_2 * oi.qnt) as labor_cost_2,
        max(sgp.qnt) as qnt_on_sgp,
        max(case when (nvl(oi.wo_estimate, 0) <> 0) and (nvl(si.dt_influencing, date ''1900-01-01'') = date ''2000-01-01'' or e.id is null) then 1 else 0 end) as item_wo_estimate,
        listagg(oi.id, '', '') within group (order by oi.id) as id_order_items_str
      from
        v_order_items oi,
        v_or_std_items si,
        ' || case when not v_use_temp then 'v_sgp_items sgp,' else '(select null as id, null as qnt from dual) sgp,' end || '
        --v_sgp_items sgp,
        estimates e
      where
        oi.id_std_item = si.id
        and oi.id = e.id_order_item (+)
        and oi.qnt <> 0
        and si.id = sgp.id (+)
        and ' || v_where_clause || '
      group by
        si.fullname,
        round(oi.cost_wo_nds / oi.qnt, 0),
        decode(oi.id_organization, -1, -1, 0)
    ) t
  ';

  -- выполнение
  if v_use_temp then
    -- в режиме фильтрации передаём параметры
    if p_id_order is not null then
      execute immediate v_sql using v_data_type, v_dt, p_id_order;
    elsif p_dt_beg_from is not null and p_dt_beg_to is not null then
      execute immediate v_sql using v_data_type, v_dt, p_dt_beg_from, p_dt_beg_to;
    end if;
  else
    -- стандартный режим
    execute immediate v_sql using v_data_type, v_dt, v_dt; -- для p_use_wo_list=0 передаём v_dt, иначе не нужно
  end if;
end;
/

--        ' || case when v_use_temp and false then 'v_sgp_items sgp,' else '(select null as id, null as qnt from dual) sgp,' end || '

--------------------------------------------------------------------------------
--процедура обработки одного дня
create or replace procedure p_order_fin_mon_process_day(p_dt in date) is
  v_dt date := trunc(p_dt);
  type t_id_list is table of order_items_wo_estimate.id_order_item%type;
  v_ids t_id_list;
begin
  --data_type = 1 для всех заказов за день
  p_insert_fin_monitoring_data(v_dt, 1, 0);

  --Найти в order_items_wo_estimate те записи, у которых dt is null (ещё без сметы)
  --и для которых сейчас смета появилась (item_wo_estimate = 0)
  select distinct oi.id
    bulk collect into v_ids
    from
      v_order_items oi,
      v_or_std_items si,
      estimates e
    where
      oi.id_std_item = si.id
      and oi.id = e.id_order_item (+)
      and oi.qnt <> 0
      and oi.id in (select id_order_item from order_items_wo_estimate where dt is null)
      and not (nvl(oi.wo_estimate, 0) <> 0 and (nvl(si.dt_influencing, date '1900-01-01') = date '2000-01-01' or e.id is null));

  if v_ids.count > 0 then
    --вставляем data_type = 2 для этих id
    p_insert_fin_monitoring_data(v_dt, 2, 1);

    --обновляем дату появления сметы для этих позиций
    for i in 1..v_ids.count loop
      update order_items_wo_estimate
         set dt = v_dt
       where id_order_item = v_ids(i);
    end loop;
  end if;

  --Добавляем в order_items_wo_estimate новые позиции,
  --которые на текущий момент остаются без сметы (item_wo_estimate = 1)
  --и которых ещё нет в таблице
  for rec in (
    select distinct oi.id as id_order_item
      from v_order_items oi,
           v_or_std_items si,
           estimates e
     where oi.id_std_item = si.id
       and oi.id = e.id_order_item (+)
       and oi.dt_beg = v_dt
       and oi.qnt <> 0
       and (nvl(oi.wo_estimate, 0) <> 0)
       and (nvl(si.dt_influencing, date '1900-01-01') = date '2000-01-01' or e.id is null)
       and not exists (select 1 from order_items_wo_estimate w where w.id_order_item = oi.id)
  )
  loop
    insert into order_items_wo_estimate (id_order_item, dt)
      values (rec.id_order_item, null);
  end loop;

  commit;
end p_order_fin_mon_process_day;
/

--------------------------------------------------------------------------------
--процедура заполняет таблицу данными финансового отчета за вчерашний день.
--если были пропуски в вызовах процедуры, то найдет максимальную дату внесепния 
--записи и обработает начиная с нее.
--также добавляются в таблицу order_items_wo_estimate айди заказов, по которым
--не были загружены все сметы.
--при появлении сметы в указанной выше таблице устанавливает дату события, и 
--добавляет записи по этим изделиям в основную таблицу.
create or replace procedure p_insert_orders_fin_monitoring is
  v_start_date date;
  v_end_date   date := trunc(sysdate) - 1; -- вчера
  v_cur_date   date;
  v_last_date  date;
begin
  -- находим последнюю обработанную дату (data_type = 1)
  select nvl(max(dt), date '2026-06-01')
    into v_last_date
    from orders_fin_monitoring
    where data_type = 1;

  -- начинаем со следующего дня после последней обработанной даты
  v_start_date := v_last_date + 1;

  if v_start_date > v_end_date then
    return; -- нечего обрабатывать
  end if;

  -- обрабатываем каждый день от start до end
  v_cur_date := v_start_date;
  while v_cur_date <= v_end_date loop
    p_order_fin_mon_process_day(v_cur_date);
    v_cur_date := v_cur_date + 1;
  end loop;

  commit;
exception
  when others then
    rollback;
    raise;
end p_insert_orders_fin_monitoring;
/


delete from orders_fin_monitoring where trunc(dt) >= trunc(sysdate) - 4;

exec p_insert_orders_fin_monitoring;

--select rownum, item_wo_estimate, ornums, customer, fullname, qnt, qnt_on_sgp, price_std, price, price_diff, summ, priceraw_wo_nds, sum0, sum0_percent, labor_cost_0, labor_cost_0_percent, labor_cost_2, labor_cost_2_percent, prime_cost, prime_cost_percent from orders_fin_monitoring where data_type = 1 and order_type = :p$i and dt_beg = trunc(sysdate) - 1 order by prime_cost_percent desc;













--------------------------------------------------------------------------------
-- финансовый отчет по запущенным за прошлый день заказам
--------------------------------------------------------------------------------

select * from v_orders_fin_monitoring where order_type = -1 and sum0 <> sum000;
create or replace view v_orders_fin_monitoring as 
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
  t.priceraw_wo_nds,
  round(t.price * t.qnt, 2) as summ,
  t.sum0,
  t.sum000,
  t.labor_intensity_0,
  t.labor_cost_0,
  t.labor_intensity_2,
  t.labor_cost_2,
  t.sum0 + t.labor_cost_0 + labor_cost_2 as prime_cost,
  case when t.price = 0 then null else round((t.sum0) / (t.price * t.qnt) * 100, 1) end as sum0_percent,
  case when t.price = 0 then null else round((t.labor_cost_0) / (t.price * t.qnt) * 100, 1) end as labor_cost_0_percent,
  case when t.price = 0 then null else round((t.labor_cost_2) / (t.price * t.qnt) * 100, 1) end as labor_cost_2_percent,
  case when t.price = 0 then null else round((t.sum0 + t.labor_cost_0 + labor_cost_2) / (t.price * t.qnt) * 100, 1) end as prime_cost_percent,
  t.item_wo_estimate
from (  
select
  decode(oi.id_organization, -1, -1, 0) as order_type,
  max(dt_beg) as dt_beg,
  listagg(oi.ornum, ', ') within group (order by oi.ornum) as ornums,
  listagg(oi.customer, ', ') within group (order by oi.ornum) as customer,
  si.fullname,
  --цена по справочнику изделий без ндс (она там с ндс для отгрузочных и без - для производственных)
  --max(round(case when oi.id_organization <> -1 then si.price / 1.22 else si.price end)) as price_std,
  max(si.price / 1.22) as price_std,
  sum(oi.qnt) as qnt,
  round(oi.cost_wo_nds / oi.qnt, 0) as price,
  max(si.priceraw_wo_nds) as priceraw_wo_nds,
  sum(round(oi.sum0 / 1.22, 0)) as sum000,
  sum(round(si.priceraw_wo_nds * oi.qnt, 0)) as sum0,
  sum(si.labor_intensity_0 * oi.qnt) as labor_intensity_0,
  sum(si.labor_cost_0 * oi.qnt) as labor_cost_0,
  sum(si.labor_intensity_2 * oi.qnt) as labor_intensity_2,
  sum(si.labor_cost_2 * oi.qnt) as labor_cost_2,
  max(case when nvl(si.dt_influencing, date '1900-01-01') = date '2000-01-01' then '!!!' else ' ' end) as item_wo_estimate
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


create or replace view v_orders_fin_monitoring_all as 
select
--финансовый отчет по всем незакрытымзаказм
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
  t.priceraw_wo_nds,
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
  max(si.priceraw_wo_nds) as priceraw_wo_nds,
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
  and oi.dt_end is null
group by
  si.fullname, round(oi.cost_wo_nds / oi.qnt, 0), decode(oi.id_organization, -1, -1, 0)  
order by
  si.fullname
) t    
;

select * from v_orders_fin_monitoring_all;

select * from v_orders_fin_monitoring where fullname ='ЛЕНМ.П_Органайзер для кофе модуля';

--create or replace view v_orders_fin_monitoring as 
select
--финансовый отчет по запущенным за вчерашний день заказам
--вызывается отдельно для производства и продажи t.order_type
--сгруппирован по изделиям и продажной цене (идет накопительно по изделиям, но при разной цене выделяются строки)
--все цены без ндс  
  --t.order_type,  -- -1 П, 0 - О
  --t.dt_beg,
  t.ornums as "Заказы",
  t.customer as "Покупатели",
  t.fullname as "Изделие",
  t.qnt as "Количество",
  t.price as "Цена продажи",
  t.price_std as "Цена по справочнику",   --цена в справочнике
  case when t.price_std > t.price then t.price - t.price_std else null end as "Занижение цены",
  round(t.price * t.qnt, 2) as "Сумма продажи",
  t.priceraw_wo_nds as "Себестоимость по смете, цена",
  t.sum0 as "Себестоимость по смете, сумма",
  case when t.price = 0 then null else round((t.sum0) / (t.price * t.qnt) * 100, 1) end as "Себестоимость по смете, %",
  t.labor_cost_0 as "Трудозатраты по ПЩ",
  case when t.price = 0 then null else round((t.labor_cost_0) / (t.price * t.qnt) * 100, 1) end as "Трудозатрты ПЩ, %",
  t.labor_cost_2 as "Трудозатраты по ЛОК",
  case when t.price = 0 then null else round((t.labor_cost_2) / (t.price * t.qnt) * 100, 1) end as "Трудозатраты по ЛОК, %",
  t.sum0 + t.labor_cost_0 + labor_cost_2 as "Затраты всего, сумма",
  case when t.price = 0 then null else round((t.sum0 + t.labor_cost_0 + labor_cost_2) / (t.price * t.qnt) * 100, 1) end as "Затраты всего, %",
  t.sum0_min,
  t.sum0_max
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
  max(si.priceraw_wo_nds) as priceraw_wo_nds,
  round(oi.cost_wo_nds / oi.qnt, 0) as price,
  sum(round(oi.sum0 / 1.22, 0)) as sum0,
  max(round(oi.sum0 / 1.22, 0)) as sum0_max,
  min(round(oi.sum0 / 1.22, 0)) as sum0_min,
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
--  and oi.id_organization <> -1  --!!
--  and oi.id_organization = -1  --!!
  and oi.dt_end is null
  and si.fullname ='ЛЕНМ.П_Органайзер для кофе модуля'
  --and oi.dt_beg >= trunc(sysdate) - 7 
group by
  si.fullname, round(oi.cost_wo_nds / oi.qnt, 0), decode(oi.id_organization, -1, -1, 0)  
order by
  si.fullname
) t    
;

select ornum, qnt, sum0 from v_order_items where dt_end is null and fullitemname = 'ЛЕНМ.П_Органайзер для кофе модуля';

--------------------------------------------------------------------------------
--материализованное представление финансового отчета по заказам
create materialized view vь_orders_fin_monitoring as
  select * from v_orders_fin_monitoring; 
  
select * from vь_orders_fin_monitoring;  

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
create or replace view v_stditems_fin_monitoring as 
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
      union
      --стандартные изделия, по которым была изменена цена
      select id from or_std_items where dt_changed_price > trunc(sysdate) - 1
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

select * from v_stditems_fin_monitoring;




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
    where 
      (e.dt_create > trunc(sysdate) - 1) or (e.dt_changed > trunc(sysdate) - 1) or (e.dt_changed_depend > trunc(sysdate) - 1) 
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
      vm_orders_fin_monitoring s,
      --orders_fin_monitoring_snapshot s,
      (select distinct order_type, fullname, price from current_data) c
    where
      --s.snapshot_date = trunc(sysdate) - 0
      s.order_type = c.order_type
      and s.fullname = c.fullname
      and s.price = c.price  
  )
 select *     
from
  current_data o,
  old_data old
where
  old.order_type (+) = o.order_type 
  and old.fullname (+) = o.fullname
  and old.price (+) = o.price
  and o.sum0 <> old.sum0
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


    select oi.ornum
    from v_order_items oi
    join estimates e on e.id_order_item = oi.id
    where e.dt_changed > trunc(sysdate) - 1;

select * from m


