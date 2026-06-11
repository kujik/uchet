/*
для стандартных изделий, изделитй заказа и сметныых позиций при просмотре сметы используем функции получения цены
для всех видов документов цены получаются одинаково

исходная цена номенклатуры получается из итм из sstock
(select
   row_number() over (partition by doctype, id_nomencl order by stockdate desc) as rn,
   id_nomencl, quantity, summa
 from dv.stock
 where doctype = 1) s
where s.rn = 1
это последняя по времени цена поступления по ПН

функции типа
f_get_order_item_raw_price
разворачивают изделия, при этом изделием будет считать строка с именем, найденная
в наименованиях стандартныых изделий как с префиксом так и без префикса
(практикуест по МТ, строка находится в группе крепеж кк материал и не и меет префикса в этом названии, 
но есть такая же в стандартных изделиях и по ней есть смета)

изделия разворачиваются рекурсивно, то есть например в отгрузочных - производственное, в проиизводстенном - полуфабррикаты.
глубина рекурсии ограничена 10, если превысит то будет ошибка.





*/


create table order_plans (
  dt date not null,         --дата, первое число месяца
  sum1ri number,            --для продажи, по рознице, сумма изделий  
  sum1ra number,            --доп комплектации
  sum1rd number,            --доставки 
  sum1rm number,            --монтажа
  sum1oi number,            --для продажи, по опту, сумма изделий  
  sum1oa number,            --доп комплектации
  sum1od number,            --доставки 
  sum1om number,            --монтажа
  sum2ri number,            --для реализации, по рознице, сумма изделий  
  sum2ra number,            --доп комплектации
  sum2rd number,            --доставки 
  sum2rm number,            --монтажа
  sum2oi number,            --для реализации, по опту, сумма изделий  
  sum2oa number,            --доп комплектации
  sum2od number,            --доставки 
  sum2om number,            --монтажа
  sum3i number,             --для выпуска продукции, сумма изделий  
  sum3a number,             --для выпуска продукции, доп комплектации
  prc3i number(5,2),        --плановый процент изделий, выпускаемых без просрочки
  prc3a number(5,2),        --плановый процент доп комплектации, выпускаемых без просрочки
  prc3 number(5,2),         --плановый процент изделий, выпускаемых без просрочки /не используем/
  constraint pk_order_plans primary key (dt)
);  


create or replace view v_order_finreport_1 as
select
--список изделий заказов, принятых на сгп за заданный период, 
--суммы изделий (без д/к), с учетом скидок по заказу, за вычетом ндс,
--также суммы только для тех, которые уложились в план выпуска (дата приемки на сгп меньше плановой даты отгрузки)
  o.id,
  o.ornum,
  i.pos,
  case when nvl(o.cost, 0) = nvl(o.cost_wo_nds, 0) 
    then round(nvl((i.price - i.price_pp)*s.sqnt*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01),0))
    else round(nvl((i.price - i.price_pp)*s.sqnt*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01), 0) / 1.22)
  end as sum_i,
  case when nvl(o.cost, 0) = nvl(o.cost_wo_nds, 0) 
    then round(nvl((i.price - i.price_pp)*s.sqnt1*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01),0))
    else round(nvl((i.price - i.price_pp)*s.sqnt1*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01), 0) / 1.22)
  end as sum_i_ok,
  case when nvl(o.cost, 0) = nvl(o.cost_wo_nds, 0) 
    then round(nvl((i.price_pp)*s.sqnt*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01),0))
    else round(nvl((i.price_pp)*s.sqnt*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01), 0) / 1.22)
  end as sum_a,
  case when nvl(o.cost, 0) = nvl(o.cost_wo_nds, 0) 
    then round(nvl((i.price_pp)*s.sqnt1*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01),0))
    else round(nvl((i.price_pp)*s.sqnt1*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01), 0) / 1.22)
  end as sum_a_ok,
  --0 as sum_i_raw,
  round(f_get_order_item_raw_price(i.id) / i.qnt * s.sqnt / 1.22) as sum_i_raw,
  --round(s.sum_raw / 1.22, 0)  as sum_i_raw,
  i.price, i.price_pp, o.m_i,o.d_i,
  s.sqnt, s.sqnt1, s.sqnt_delayed
from
  (select id_order_item, sum(s1.qnt) sqnt, sum(case when o1.dt_otgr > s1.dt then s1.qnt else 0 end) sqnt1, sum(case when o1.dt_otgr > s1.dt then 0 else s1.qnt end) sqnt_delayed
    from 
      order_item_stages s1, 
      order_items i1,
      orders o1
    where 
      i1.qnt <> 0 and
      id_stage = 2 and nvl(i1.sgp, 0) <> 1 and i1.id = s1.id_order_item and o1.id = i1.id_order 
--      and s1.dt >= sys_context('context_uchet22','order_finreport_dtbeg') and s1.dt <= sys_context('context_uchet22','order_finreport_dtend')
      and s1.dt >= date '2026-06-01' and s1.dt < date '2026-07-01'
    group by id_order_item
  ) s,
  order_items i,
  orders o
where
  i.id_order = o.id and o.id > 0 and
  s.id_order_item = i.id
--and o.id = 49  
order by
  sqnt1 desc, ornum, pos   
;     
  
select id, ornum || '_' pos, qnt, qnt_ok, sum_i, sum_i_raw from v_order_finreport_1  where (sum_i > sum_i_ok) or (sum_a > sum_a_ok) ;
select id, ornum || '_' pos, sqnt, sum_i, sum_i_raw from v_order_finreport_1;
select * from v_order_finreport_1;


create or replace view v_order_finreport_inprod as
select
--список изделий заказов, запущенных в работу, но еще не принятых на сгп полностью 
--суммы изделий (без д/к) и д/к, с учетом скидок по заказу, за вычетом ндс,
  o.id,
  o.ornum,
  i.pos,
  case when nvl(o.cost, 0) = nvl(o.cost_wo_nds, 0) 
    then round(nvl((i.price - i.price_pp)*s.qnt_inprod*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01),0))
    else round(nvl((i.price - i.price_pp)*s.qnt_inprod*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01), 0) / 1.2)
  end as sum_i,
  case when nvl(o.cost, 0) = nvl(o.cost_wo_nds, 0) 
    then round(nvl((i.price_pp)*s.qnt_inprod*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01),0))
    else round(nvl((i.price_pp)*s.qnt_inprod*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01), 0) / 1.2)
  end as sum_a,
  i.price, i.price_pp, o.m_i,o.d_i,
  --f_get_order_item_raw_price(i.id) as sum0,
  s.qnt, s.qnt2, s.qnt_inprod
from
  v_oritms_pn_in_prod s,
  order_items i,
  orders o
where
  i.id_order = o.id and o.id > 0 and
  s.id_order_item = i.id
;     


create or replace view v_oritms_pn_in_prod as 
select 
--изделия по производственным заказам и нестандартные в работе
--(по незакрытым заказам П и нестандартным изделиям, которые еще не приняты в полном составе на СГП)
  i.id as id_order_item, sum(i.qnt) as qnt, sum(nvl(os.qnt,0)) as qnt2, sum(i.qnt) - sum(nvl(os.qnt,0)) qnt_inprod 
from 
  (select id_order_item, sum(qnt) as qnt from order_item_stages where id_stage = 2 group by id_order_item) os, 
  order_items i,
  orders o
where 
  os.id_order_item (+) = i.id 
  and i.qnt > 0 and nvl(i.sgp, 0) <> 1 
  and o.id = i.id_order and o.dt_end is null and o.id > 0 
  and (o.id_organization = -1 or nvl(i.std,0) = 0)  and nvl(i.sgp, 0) <> 1 
group by i.id
having sum(i.qnt) - sum(nvl(os.qnt,0)) > 0
;


create or replace view v_oritms_all_in_prod as 
select 
--изделия, производимые сейчас по всем незакрытым заказам (кроме изделий с сгп)
--(которые еще не приняты в полном составе на СГП)
  i.id as id_order_item, sum(i.qnt) as qnt, sum(nvl(os.qnt,0)) as qnt2, sum(i.qnt) - sum(nvl(os.qnt,0)) qnt_inprod 
from 
  (select id_order_item, sum(qnt) as qnt from order_item_stages where id_stage = 2 group by id_order_item) os, 
  order_items i
where 
  os.id_order_item (+) = i.id
  and i.qnt > 0 and nvl(i.sgp, 0) <> 1 
group by i.id
having sum(i.qnt) - sum(nvl(os.qnt,0)) > 0
;

create or replace view v_nom_for_orders_in_prod_fin as
select
--финансовый отчет по сырью на в производстве, складе, в резерве...
  sum((nvl(n.qnt_inprod, 0) + nvl(m.rezerv, 0)) * nvl(m.price_last, 0) / 1.2) as sum_in_prod,
  sum(m.qnt * nvl(m.price_last, 0) / 1.2) as sum_in_stock,
  -sum(m.rezerv * nvl(m.price_last, 0) / 1.2) as sum_rezerv,
  -sum(m.need * nvl(m.price_last, 0) / 1.2) as sum_need,
  -sum(m.need_p * nvl(m.price_last, 0) / 1.2) as sum_need_p,
  sum(m.qnt_onway * nvl(m.price_last, 0) / 1.2) as sum_onway,
  sum(greatest(-nvl(m.rezerv,0) - nvl(m.qnt,0) - nvl(m.qnt_onway,0), 0) * nvl(m.price_last, 0) / 1.2) as sum_needcurr
from  
  v_nom_for_orders_in_prod n,
  v_spl_minremains m
where
  n.id_nomencl (+) = m.id
;

/*
select
--финансовый отчет по сырью на в производстве, складе, в резерве...
  sum((nvl(n.qnt_inprod, 0) + nvl(m.rezerv, 0)) * nvl(m.price_last, 0) / 1.2) as sum_in_prod,
  sum(m.qnt * nvl(m.price_last, 0) / 1.2) as sum_in_stock,
  sum(m.qnt_onway * nvl(m.price_last, 0) / 1.2) as sum_onway,
  sum(greatest(-nvl(m.rezerv,0) - nvl(m.qnt,0) - nvl(m.qnt_onway,0), 0) * nvl(m.price_last, 0) / 1.2) as sum_needcurr
from  
  v_nom_for_orders_in_prod n,
  v_spl_minremains m
where
  n.id_nomencl (+) = m.id
and m.supplierinfo = 'ДМ'  
;
*/



--Сырье в резерве (кол-во) минус остаток этого сырья на складах минус кол-во этого же сырья в пути = Потребность текущая в кол-ве. Умножить на цену. 
--Если Потребность текущая в кол-ве меньше 0, то исключаем ее из итоговой суммы

create or replace view v_fin_stditem_raw_prices as 
select
--считает закупочные суммы стандартных изделий
--позиции, являющиеся изделиями, не разворачивает,
--цены находит в stock в последней по дате проводке по ПН для данной номенклатуры
  i.id,
  --i.name,
  --b.name,
  round(sum(ei.qnt1_itm * s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity))) as sum
from
  or_std_items i,
  estimates e,
  estimate_items ei,
  bcad_nomencl b,
  dv.nomenclatura n,
  (select row_number() over (partition by doctype, id_nomencl order by stockdate desc) as rn, id_nomencl, quantity, summa, stockdate from dv.stock where doctype = 1) s 
where
  e.id_std_item = i.id
  and ei.id_estimate = e.id
  and b.id = ei.id_name
  and n.name = b.name
  and s.id_nomencl = n.id_nomencl and s.rn = 1
group by 
  i.id  
;





select* from v_fin_stditem_raw_prices where id = 308;
select* from v_sgp_item_prices where id = 457;

create or replace view v_fin_estitem_raw_prices as 
select
--получает закупочные цену по сметной номенклатуре
  ei.id,
  round(s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity),2) as price,
  round(ei.qnt1_itm * s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity),2) as sum
from
  estimate_items ei,
  bcad_nomencl b,
  dv.nomenclatura n,
  (select row_number() over (partition by doctype, id_nomencl order by stockdate desc) as rn, id_nomencl, quantity, summa, stockdate from dv.stock where doctype = 1) s 
where
  b.id = ei.id_name
  and n.name = b.name
  and s.id_nomencl = n.id_nomencl and s.rn = 1
;


--себестоимость заказов по площадке МТ, полностью принятых на СГП в заданный период
select 
  sum(sum0) 
from
  v_order_items i,
  orders o
where
  o.id = i.id_order
  and i.area = 3 and
  o.dt_to_sgp >= '01/08/2025' and o.dt_to_sgp < '01/09/2025'
;




create or replace function f_get_estitem_raw_price(
  p_id in number,    -- обязательный: идентификатор строки сметы (estimate_items.id)
  depth in number default 1   -- необязательный: текущая глубина рекурсии (по умолчанию 1)
) return number is
  /*
    Функция возвращает закупочную цену за единицу для позиции сметы.
    Если номенклатура является вложенным изделием, рекурсивно вызывает
    f_get_stditem_raw_price. В противном случае берёт цену из последнего
    поступления (stock). Глубина рекурсии ограничена 10 для защиты от циклов.
  */
  v_price number;
  v_child_id number;
  v_name varchar2(1000);
  c_max_depth constant number := 10;
begin
  -- проверка глубины рекурсии
  if depth > c_max_depth then
    raise_application_error(-20001, 'превышена глубина рекурсии (' || c_max_depth || ') для estimate_items id ' || p_id);
  end if;

  -- получаем имя номенклатуры из bcad_nomencl
  select b.name
  into v_name
  from estimate_items ei, bcad_nomencl b
  where ei.id = p_id and b.id = ei.id_name;

  -- проверяем, не является ли данная номенклатура вложенным изделием
  begin
    select i2.id
    into v_child_id
    from or_std_items i2, or_format_estimates fi2
    where i2.id_or_format_estimates = fi2.id (+)
      and ((case when fi2.id = 0 then '' else fi2.prefix || '_' end) || i2.name = v_name
           or i2.name = v_name)
      and rownum = 1;

    -- рекурсивный вызов для вложенного изделия (глубина увеличивается)
    v_price := f_get_stditem_raw_price(v_child_id, depth + 1);
  exception
    when no_data_found then
      -- не изделие – берём цену из последнего поступления (stock)
      begin
        select round(s.summa / decode(nvl(s.quantity, 1), 0, 1, s.quantity), 2)
        into v_price
        from
          estimate_items ei,
          bcad_nomencl b,
          dv.nomenclatura n,
          (select
             row_number() over (partition by doctype, id_nomencl order by stockdate desc) as rn,
             id_nomencl, quantity, summa
           from dv.stock
           where doctype = 1) s
        where
          ei.id = p_id
          and b.id = ei.id_name
          and n.name = b.name
          and s.id_nomencl = n.id_nomencl
          and s.rn = 1;
      exception
        when no_data_found then
          v_price := null;
      end;
  end;
  return v_price;
end f_get_estitem_raw_price;
/

create or replace function f_get_stditem_raw_price(
  aid in number,           -- обязательный: идентификатор изделия (or_std_items.id)
  depth in number default 1 -- необязательный: текущая глубина рекурсии (по умолчанию 1)
) return number is
  /*
    Функция возвращает полную стоимость изделия (суммарную стоимость всех материалов и подузлов)
    на основе его сметы. Если в смете встречается материал, который является другим изделием,
    функция рекурсивно вызывает себя для этого изделия. Глубина рекурсии ограничена 10 уровнями.
    Для обычных материалов цена берётся из последнего поступления (stock).
  */
  lsum number := 0;
  v_child_id number;
  c_max_depth constant number := 10;
begin
  -- проверка глубины рекурсии (защита от циклов)
  if depth > c_max_depth then
    raise_application_error(-20001, 'превышена максимальная глубина рекурсии (' || c_max_depth || ') для изделия id ' || aid);
  end if;

  -- цикл по всем позициям сметы, входящим в данное изделие
  for rec in (
    select
      ei.qnt1_itm,
      b.name as b_name
    from
      or_std_items i,
      or_format_estimates fi,
      estimates e,
      estimate_items ei,
      bcad_nomencl b
    where
      i.id = aid
      and i.id_or_format_estimates = fi.id
      and e.id_std_item = i.id
      and ei.id_estimate = e.id
      and b.id = ei.id_name
  ) loop
    begin
      -- проверяем, не является ли текущая номенклатура вложенным изделием
      select i2.id
      into v_child_id
      from
        or_std_items i2,
        or_format_estimates fi2
      where
        i2.id_or_format_estimates = fi2.id (+)
        and ((case when fi2.id = 0 then '' else fi2.prefix || '_' end) || i2.name = rec.b_name
             or i2.name = rec.b_name)
        and rownum = 1;

      -- рекурсивный вызов для вложенного изделия (глубина увеличивается)
       if v_child_id <> aid then
         lsum := lsum + round(rec.qnt1_itm * f_get_stditem_raw_price(v_child_id, depth + 1));
       end if;
    exception
      when no_data_found then
        -- не изделие – получаем цену из последнего поступления (stock)
        declare
          v_price number;
          v_qty   number;
          v_nom_id number;
        begin
          select n.id_nomencl
          into v_nom_id
          from dv.nomenclatura n
          where n.name = rec.b_name
            and rownum = 1;

          select summa, quantity
          into v_price, v_qty
          from (
            select summa, quantity
            from dv.stock
            where doctype = 1
              and id_nomencl = v_nom_id
            order by stockdate desc
          )
          where rownum = 1;

          lsum := lsum + nvl(round(rec.qnt1_itm * v_price / (case when nvl(v_qty, 1) = 0 then 1 else v_qty end)), 0);
        exception
          when no_data_found then
            null; -- если нет цены – вклад нулевой
        end;
    end;
  end loop;
  return lsum;
end f_get_stditem_raw_price;
/

create or replace function f_get_order_item_raw_price(
--возвращает стоимость по смете позиции в заказе (на все количество изделий, по количеству в итм
  p_id in number,
  depth in number default 1
) return number is
  lsum number := 0;
  v_order_qnt number;
  c_max_depth constant number := 10;
begin
  -- защита от бесконечной рекурсии
  if depth > c_max_depth then
    raise_application_error(-20001, 'превышена глубина рекурсии (' || c_max_depth || ') для order_item id ' || p_id);
  end if;

  -- получаем количество заказанных изделий
  begin
    select oi.qnt into v_order_qnt
      from order_items oi
     where oi.id = p_id;
  exception
    when no_data_found then
      return 0;
  end;

  if v_order_qnt = 0 then
    return 0;
  end if;

  -- перебираем все позиции сметы, связанной с данным order_item
  for rec in (
    select
      b.name,
      ei.qnt1_itm
    from
      order_items oi,
      estimates e,
      estimate_items ei,
      bcad_nomencl b
    where
      oi.id = p_id
      and e.id_order_item = oi.id
      and ei.id_estimate = e.id
      and b.id = ei.id_name
  )
  loop
    declare
      v_child_id number;
      v_std_price number;
      v_nom_id number;
      v_price number;
      v_qty number;
    begin
      -- проверяем, не является ли данная номенклатура стандартным изделием (вложенным)
      begin
        select i2.id
          into v_child_id
          from or_std_items i2, or_format_estimates fi2
         where i2.id_or_format_estimates = fi2.id (+)
           and ((case when fi2.id = 0 then '' else fi2.prefix || '_' end) || i2.name = rec.name
                or i2.name = rec.name)
           and rownum = 1;
      exception
        when no_data_found then
          v_child_id := null;
      end;

      if v_child_id is not null then
        -- рекурсивный вызов для вложенного стандартного изделия
        v_std_price := f_get_stditem_raw_price(v_child_id, depth + 1);
        lsum := lsum + v_order_qnt * rec.qnt1_itm * nvl(v_std_price, 0);
      else
        -- не изделие – берём цену из последнего поступления (stock)
        begin
          select n.id_nomencl into v_nom_id
            from dv.nomenclatura n
           where n.name = rec.name
             and rownum = 1;

          select summa, quantity into v_price, v_qty
            from (
              select summa, quantity
                from dv.stock
               where doctype = 1
                 and id_nomencl = v_nom_id
               order by stockdate desc
            )
           where rownum = 1;

          lsum := lsum + v_order_qnt * rec.qnt1_itm * nvl(round(v_price / (case when nvl(v_qty, 1) = 0 then 1 else v_qty end), 2), 0);
        exception
          when no_data_found then
            null; -- если нет поступлений, не добавляем стоимость
        end;
      end if;
    end;
  end loop;

  return round(lsum, 2);
end f_get_order_item_raw_price;
/

oi 528853  si 8911










8073 --!!! Кушетка (80400665) зацикливание!!!


select f_temp1(5980) from dual;
--
select f_temp1(8187) from dual;



