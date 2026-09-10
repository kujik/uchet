Alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;

--------------------------------------------------------------------------------
--проверочные вью для контроля результатов TOrders.ConvertOrders2026 (uOrders.pas) -
--конвертации цен/скидок/наценок/сумм заказов из старого формата (D_Order, поля
--orders.cost_i/cost_m/cost_d/cost_av/cost и order_items.price) в новый формат
--(uFrmOWOrder, поля orders.sum_items_final/sum_montage_final/... и
--order_items.price_base/price_adjusted/price_final). Данные старого формата в БД
--остаются навсегда, конвертация только заполняет новые поля - эти вью ничего не
--чиняют, только показывают расхождения.
--
--проверка 1 - итоговые суммы по заказу (sum_final/sum_advance) должны точно
--  совпадать с исторической суммой старого заказа (cost_i+cost_m+cost_d/cost_av) -
--  оба поля копируются "как есть" из шапки старого заказа, без пересчета, поэтому
--  расхождение больше пары копеек = ошибка конвертации, а не следствие смены ставки ндс.
--проверка 2 - внутренняя согласованность новых полей: sum_items_final/
--  sum_montage_final/sum_delivery_final должны получаться из соответствующих base
--  с учетом markup/discount_..._percent (по старой аддитивной формуле, см.
--  комментарий в TOrders.ConvertOrders2026) и nds_rate.
--проверка 3 - цены по строкам (order_items.price_final) в сравнении с price_base/
--  price_adjusted/nds_rate той же строки (тоже внутренняя согласованность).
--проверка 4 - сумма price_final*qnt по строкам заказа в сравнении с sum_items_final
--  в шапке - расхождение здесь ожидаемо (см. комментарий в процедуре: в старом
--  формате скидка/наценка на уровне отдельной позиции не хранилась, а после смены
--  ставки ндс с исторической на новую по организации могут набегать заметные
--  отличия) - вью только для информации, не для поиска "ошибок".
--проверка 5 - заказы из диапазона конвертации (dt_beg >= 01.05.2026), которые
--  почему-то остались неконвертированными (nds_rate is null).
--проверка 6 - заказы с ненулевой cost_a (категория "покупные"/перепродажа) - по
--  словам пользователя эта категория раньше не использовалась и в конвертации
--  сознательно не участвует; если такие заказы всё же находятся - для них
--  sum_final гарантированно разойдётся с cost, это нужно перепроверить отдельно.
--------------------------------------------------------------------------------


create or replace view v_orders_pconv_check1_totals as --$+
  select
  --проверка 1: сравнение итоговых сумм заказа со старым форматом.
    o.id,
    o.num,
    o.ornum,
    o.dt_beg,
    o.id_organization,
    --историческая ставка ндс (та же логика, что в TOrders.ConvertOrders2026,
    --используется только чтобы понять, каким nds_rate заказ был бы сконвертирован)
    case
      when o.dt_beg >= date '2026-06-01' then 22
      when o.id_organization = -1 then 0
      else 20
    end as nds_rate_hist_expected,
    o.nds_rate as nds_rate_saved,
    --новая ставка ндс по организации (та же логика, что в TOrders.ConvertOrders2026;
    --именно она пишется в nds_rate и участвует в price_final/sum_*_final)
    case o.id_organization
      when -1 then 0
      when 7 then 0
      when 2 then 6
      else 22
    end as nds_rate_new_expected,
    o.cost_a as cost_a_old,
    o.cost_i as cost_i_old,
    o.cost_m as cost_m_old,
    o.cost_d as cost_d_old,
    o.cost_av as cost_av_old,
    o.cost as cost_old,
    o.sum_final,
    round(nvl(o.cost_i, 0) + nvl(o.cost_m, 0) + nvl(o.cost_d, 0), 2) as sum_final_expected,
    round(nvl(o.sum_final, 0) - (nvl(o.cost_i, 0) + nvl(o.cost_m, 0) + nvl(o.cost_d, 0)), 2) as sum_final_diff,
    o.sum_advance,
    round(nvl(o.sum_advance, 0) - nvl(o.cost_av, 0), 2) as sum_advance_diff
  from
    orders o
  where
    o.dt_beg >= date '2026-05-01'
    and o.id > 0
;

create or replace view v_orders_pconv_check1_totals_mismatch as --$+
  select * from v_orders_pconv_check1_totals
  where abs(nvl(sum_final_diff, 0)) > 0.02
     or abs(nvl(sum_advance_diff, 0)) > 0.02
     or sum_final is null
;


create or replace view v_orders_pconv_check2_group_consistency as --$+
  select
  --проверка 2: sum_..._final должны получаться из base + markup/discount_percent (по
  --старой аддитивной формуле) + nds_rate - если нет, где-то разошлись расчеты внутри
  --самой процедуры конвертации (например, после ручной правки заказа без пересчета).
    o.id,
    o.num,
    o.nds_rate,
    o.sum_items_base,
    o.markup_items_percent,
    o.discount_items_percent,
    o.sum_items_final_wo_nds,
    o.sum_items_final,
    round(round(o.sum_items_base * (1 + nvl(o.markup_items_percent, 0) / 100 - nvl(o.discount_items_percent, 0) / 100), 2), 2) as sum_items_adjusted_expected,
    round(round(o.sum_items_base * (1 + nvl(o.markup_items_percent, 0) / 100 - nvl(o.discount_items_percent, 0) / 100), 2) * (1 + o.nds_rate / 100), 2) as sum_items_final_expected,
    o.sum_montage_base,
    o.markup_montage_percent,
    o.discount_montage_percent,
    o.sum_montage_final,
    round(round(o.sum_montage_base * (1 + nvl(o.markup_montage_percent, 0) / 100 - nvl(o.discount_montage_percent, 0) / 100), 2) * (1 + o.nds_rate / 100), 2) as sum_montage_final_expected,
    o.sum_delivery_base,
    o.markup_delivery_percent,
    o.discount_delivery_percent,
    o.sum_delivery_final,
    round(round(o.sum_delivery_base * (1 + nvl(o.markup_delivery_percent, 0) / 100 - nvl(o.discount_delivery_percent, 0) / 100), 2) * (1 + o.nds_rate / 100), 2) as sum_delivery_final_expected
  from
    orders o
  where
    o.dt_beg >= date '2026-05-01'
    and o.id > 0
    and o.nds_rate is not null
;

create or replace view v_orders_pconv_check2_group_consistency_mismatch as --$+
  select * from v_orders_pconv_check2_group_consistency
  where abs(nvl(sum_items_final, 0) - nvl(sum_items_final_expected, 0)) > 0.02
     or abs(nvl(sum_items_final_wo_nds, 0) - nvl(sum_items_adjusted_expected, 0)) > 0.02
     or abs(nvl(sum_montage_final, 0) - nvl(sum_montage_final_expected, 0)) > 0.02
     or abs(nvl(sum_delivery_final, 0) - nvl(sum_delivery_final_expected, 0)) > 0.02
;


create or replace view v_orders_pconv_check3_items as --$+
  select
  --проверка 3: price_final строки должен получаться из price_adjusted и nds_rate той же строки.
    i.id as id_order_item,
    i.id_order,
    i.price as price_old,
    i.qnt,
    i.price_base,
    i.price_adjusted,
    i.price_final,
    i.nds_rate,
    round(i.price_adjusted * (1 + i.nds_rate / 100), 2) as price_final_expected,
    round(nvl(i.price_final, 0) - round(i.price_adjusted * (1 + i.nds_rate / 100), 2), 2) as price_final_diff
  from
    order_items i, orders o
  where
    i.id_order = o.id
    and o.dt_beg >= date '2026-05-01'
    and o.id > 0
    and i.price_base is not null
;

create or replace view v_orders_pconv_check3_items_mismatch as --$+
  select * from v_orders_pconv_check3_items
  where abs(nvl(price_final_diff, 0)) > 0.02
;


create or replace view v_orders_pconv_check4_items_vs_header as --$+
  select
  --проверка 4: сумма price_final*qnt по строкам в сравнении с sum_items_final в шапке -
  --расхождение ожидаемо (см. заголовок файла), вью для информации, не для поиска "ошибок".
    o.id,
    o.num,
    o.sum_items_final,
    round(sum(i.price_final * i.qnt), 2) as sum_items_final_by_rows,
    round(nvl(o.sum_items_final, 0) - sum(i.price_final * i.qnt), 2) as diff,
    count(*) as items_cnt
  from
    order_items i, orders o
  where
    i.id_order = o.id
    and o.dt_beg >= date '2026-05-01'
    and o.id > 0
    and i.price_final is not null
  group by
    o.id, o.num, o.sum_items_final
;


create or replace view v_orders_pconv_check5_missing as --$+
  select
  --проверка 5: заказы из диапазона конвертации, оставшиеся неконвертированными.
    o.id,
    o.num,
    o.ornum,
    o.dt_beg,
    o.id_organization
  from
    orders o
  where
    o.dt_beg >= date '2026-05-01'
    and o.id > 0
    and o.nds_rate is null
;


create or replace view v_orders_pconv_check6_cost_a_nonzero as --$+
  select
  --проверка 6: заказы с ненулевой cost_a ("покупные"/перепродажа) - конвертация эту
  --категорию не переносит (см. заголовок файла), для таких заказов sum_final не
  --будет совпадать с полной cost старого заказа.
    o.id,
    o.num,
    o.ornum,
    o.dt_beg,
    o.cost_a,
    o.cost_a_0,
    o.m_a,
    o.d_a
  from
    orders o
  where
    o.dt_beg >= date '2026-05-01'
    and o.id > 0
    and nvl(o.cost_a, 0) <> 0
;
