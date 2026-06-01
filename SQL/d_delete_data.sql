--delete from orders where id_organization = 7 and dt_beg < date '2026-01-01';

create or replace procedure p_clear_outdated_order as
begin

update orders set 
id_customer = null, 
id_customer_contact = null,
id_customer_org = null,
id_manager = -103,
address = null,
cost = null,
cost_nds = null,
cost_wo_nds = null,
cost_av = null,
cost_i_0 = null,
cost_d_0 = null,
cost_m_0 = null,
cost_a_0 = null,
cost_i = null,
cost_i_nosgp = null,
cost_d = null,
cost_m = null,
cost_a = null,
m_i = null,
m_d = null,
m_m = null,
m_a = null,
d_i = null,
d_d = null,
d_m = null,
d_a = null,
pay = null,
comm = null
where id in (select id from v_get_outdated_orders)
;

delete from or_payments
where
id_order in (select id from v_get_outdated_orders)
;

update order_items set
price = 0, price_pp = 0
where
id_order in (select id from v_get_outdated_orders)
;
end;
/



--выберем устаревшие заказы для удаления
--по Н, открытые ранее заданной даты, завершенные, полностью оплаченные, все платежи ранее той же даты
--также проверяем чтобы дата была ранее даты ревизии кассы
create or replace view v_get_outdated_orders as
select
  o.id,
  o.dt_beg,
  p.dt
from
  orders o,
  (select id_order, min(dt) as dt from or_payments group by id_order) p,
  sn_cash_revision_dt r   
where 
  p.id_order (+) = o.id
  --ранее не очищены 
  and o.id_customer is not null  ---
  --ника
  and o.id_organization = 7
  --в периоде очистки 
  and o.dt_beg >= date '2026-01-01'  
  and o.dt_beg <= get_context('delete_orders_dt')  
  and o.dt_end is not null
  and o.in_archive = 1
  --открыт ранее кассы
  and o.dt_beg < r.dt  
  and o.pay = o.cost  ---
  --платеж в периоде очистки (если не было платежей то и не попадет в список)
  and p.dt (+) <= get_context('delete_orders_dt')
  --платеж ранее кассы
  and p.dt  < r.dt
;  

select sys_context('context_uchet22','delete_orders_dt') from dual;
select * from v_get_outdated_orders;
begin
  set_context_value('delete_orders_dt', date '2026-06-01');
end;
/

--------------------------------------------------------------------------------

create or replace procedure p_clear_outdated_accounts as
begin
  delete from sn_calendar_accounts where id in (select id from v_get_outdated_accounts);
end;
/   


create or replace view v_get_outdated_accounts as
select
  a.id,
  a.dt,
  a.filename
from 
  sn_calendar_accounts a,
  (select sum(sum) as accsum, sum(case when status = 1 then sum else 0 end) as paidsum, max(dtpaid) as maxdtpaid, id_account from sn_calendar_payments pp group by id_account) p, 
  sn_cash_revision_dt r   
where
  p.id_account (+) = a.id
  and id_expenseitem in (162, 171,172)
  and a.dt < get_context('delete_accounts_dt')  
  and a.dt < r.dt
  and p.maxdtpaid < r.dt
;   
