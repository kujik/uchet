select id_departament, departament, is_finalized from v_w_turv_period where dt1 = date '2026-08-01' and departament = 'Служба персонала';
select id_departament, departament from v_w_payroll_calc where dt1 =  date '2026-08-01' and id_departament=10223    ;--    and id_employee is null;


select * from orders where ornum = 'Н260329';
select * from v_orders where ornum = 'Н260329';


select to_char(id) as id, id_itm, has_itm_est, path, in_archive, dt_beg, ornum, area_short, typename, organization, customer, project, address, dt_otgr, managername, or_reference, ref_dt_beg, ref_dt_otgr, to_kns, to_thn, dt_kns_max, dt_thn_max, estimates, 
xml_status, dt_estimate_max, dt_reserve, dt_aggr_estimate, status_itm, qnt_slashes, qnt_items, qnt_in_prod, dt_to_prod, qnt_to_sgp, dt_to_sgp, dt_from_sgp, dt_end_manager, cancel, dt_end, early_or_late, qnt_boards_m2, qnt_edges_m, qnt_glass_m2, qnt_paint_kg, 
qnt_panels_w_drill_all, dt_upd_reg, dt_upd, upd, pay, pay_n, dt_account_reg, dt_account, account, cost_i_wo_nds, cost_i_nosgp_wo_nds, cost_a_wo_nds, cost_d_wo_nds, cost_m_wo_nds, cost_wo_nds, cost, 0.0 as sum0, comm from v_orders_list 
where
-- (id_organization <> 7 or 
nvl(in_archive, 0) = 0 and id > 0
and 
ornum = 'Н260329';



--------------------------------------------------------------------------------
--скидки.наценки на монтаж и доставку - есть только в одном заказе, игнорируем
select * from v_orders where nvl(d_d, 0) <> 0 or  nvl(m_d, 0) <> 0 or  nvl(d_m, 0) <> 0 or  nvl(m_m, 0) <> 0;
--скидов по оптовым организациям нет
select ornum, dt_beg, organization from v_orders where (nvl(d_i, 0) <> 0 or  nvl(m_i, 0) <> 0) and not id_organization in (2,3,7);


select
  (round(nvl((i.price - i.price_pp)*i.qnt*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01) / o.ndsd, 0)) +
  
  
  
  round(nvl((i.price_pp)*i.qnt*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01) / o.ndsd, 0))) as cost_wo_nds,
  round(i.price * i.qnt, 2) as sum
from
  order_items;  
  
--  nedt_Items.Value := RoundTo(S.NNum(nedt_Items_0.Value) + S.NNum(nedt_Items_0.Value) / 100 * S.NNum(nedt_Items_M.Value) - S.NNum(nedt_Items_0.Value) / 100 * S.NNum(nedt_Items_D.Value), -2);
  
    
select
  i.price * (1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01) / o.ndsd,
  
/*  
cost number(12,2),                 -- сумма заказа
  cost_nds number(12,2),             -- сумма ндс в заказе НЕ ИСПОЛЬЗУЕМ
  cost_wo_nds number(12,2),          -- сумма заказа без ндс
  cost_av number(12,2),              -- сумма аванса
  cost_i_0 number(12,2),               -- стоимость изделий начальная (без скидки и наценки)
  cost_d_0 number(12,2),               -- стоимость доставки
  cost_m_0 number(12,2),               -- стоимость монтажа
  cost_a_0 number(12,2),               -- стоимость покупных изделий
  cost_i number(12,2),               -- стоимость изделий (с учетом скидки и наценки)
  cost_i_nosgp number(12,2),         -- стоимость изделий не с сгп (кроме д/к, с учетом скидки/наценки)
  cost_d number(12,2),               -- стоимость доставки
  cost_m number(12,2),               -- стоимость монтажа
  cost_a number(12,2),               -- стоимость покупных изделий  
  */
 ; 
 
 
select 
  o.ornum, o.dt_beg, o.organization,o.ndsd,
  cost_i, cost_i_0,
  round(nvl(o.cost_i, 0) / o.ndsd, 2) as cost_i_wo_nds_,
--  (select round(sum(i.price * (1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01) / o.ndsd * i.qnt),2) from order_items i where id_order = o.id group by id_order) as tsum0 
  (select round(sum(i.price_tmp * i.qnt),2) from order_items i where id_order = o.id group by id_order) as tsum, 
  (select round(sum(i.price_tmp * (1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01) * i.qnt),2) from order_items i where id_order = o.id group by id_order) as tsum0, 
  (select round(sum(i.price_tmp * i.qnt),2) from order_items i where id_order = o.id group by id_order) as tsum00 
  from
  v_orders o
where
  o.dt_beg >= date '2026-06-01' 
  and cost_i <> cost_i_0 
order by
  dt_beg  
;

 

  