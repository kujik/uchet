select event, wait_class, seconds_in_wait, blocking_session 
from v$session 
where status='ACTIVE' and username is not null;


select to_char(id) as id, format_name, slash, name, qnt_psp_sell, 
qnt_psp_prod, qnt_sgp_registered, qnt_shipped, qnt, qnt_in_prod, 
qnt_to_shipped, qnt_min, qnt_need, price, summ, priceraw, sumraw from 
v_sgp_items
where id_format_est = :id_format_est
;
