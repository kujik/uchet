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
    else round(nvl((i.price - i.price_pp)*s.sqnt*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01), 0) / 1.2)
  end as sum_i,
  case when nvl(o.cost, 0) = nvl(o.cost_wo_nds, 0) 
    then round(nvl((i.price - i.price_pp)*s.sqnt1*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01),0))
    else round(nvl((i.price - i.price_pp)*s.sqnt1*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01), 0) / 1.2)
  end as sum_i_ok,
  case when nvl(o.cost, 0) = nvl(o.cost_wo_nds, 0) 
    then round(nvl((i.price_pp)*s.sqnt*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01),0))
    else round(nvl((i.price_pp)*s.sqnt*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01), 0) / 1.2)
  end as sum_a,
  case when nvl(o.cost, 0) = nvl(o.cost_wo_nds, 0) 
    then round(nvl((i.price_pp)*s.sqnt1*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01),0))
    else round(nvl((i.price_pp)*s.sqnt1*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01), 0) / 1.2)
  end as sum_a_ok,
  i.price, i.price_pp, o.m_i,o.d_i,
  s.sqnt, s.sqnt1, s.sqnt_delayed
from
  (select id_order_item, sum(s1.qnt) sqnt, sum(case when o1.dt_otgr > s1.dt then s1.qnt else 0 end) sqnt1, sum(case when o1.dt_otgr > s1.dt then 0 else s1.qnt end) sqnt_delayed 
    from 
      order_item_stages s1, 
      order_items i1,
      orders o1
    where 
      id_stage = 2 and nvl(i1.sgp, 0) <> 1 and i1.id = s1.id_order_item and o1.id = i1.id_order 
      and s1.dt >= sys_context('context_uchet22','order_finreport_dtbeg') and s1.dt <= sys_context('context_uchet22','order_finreport_dtend')
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
  
select id, ornum || '_' pos, qnt, qnt_ok from v_order_finreport_1  where (sum_i > sum_i_ok) or (sum_a > sum_a_ok) ;


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
  
  

