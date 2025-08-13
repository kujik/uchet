/*
������ � ��������������� �� �������.
*/

alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';


--��������� ��������� ��������������, ���� � ���.
select id_kontragent from dv.kontragent where name_org in ('��', '�'); 
--6212

create or replace view v_semiproducts_nomencl as
select 
--������ ������������, ��� ������� ������������ ��� ��������� ����������� �������� ��������� ��������������
  ns.id_nomencl,
  n.name,
  n.id_unit
from
  (select id_nomencl, count(*) as suppliers_cnt, max(minpart) minpart_max, 
    decode(count(*), 1, max(id_supplier), max(decode(is_default, 1, id_supplier, null))) as id_supplier, 
    decode(count(*), 1, max(name_pos), max(decode(is_default, 1, name_pos, null))) as name_pos,
    min(nvl(name_pos, chr(1)))as min_name_pos 
    from dv.namenom_supplier ns group by id_nomencl
  ) ns,
  dv.nomenclatura n
where
  ns.id_nomencl = n.id_nomencl
  --and ns.id_supplier = 6212
  and ns.id_supplier = sys_context('context_uchet22','semiproduct_supplier')
;      

create or replace view v_semiproducts_or_in_reserve as
select
--������ ���� ������� � ���, � ������� �� ������� ������� ������������ ��
  distinct 
  --mn.numdoc
  mn.id_doc
from
  dv.v_movenomencl mn,
  v_semiproducts_nomencl n,
  orders o
where
  mn.id_nomencl = n.id_nomencl
  and mn.doctype = 27
  and o.id_itm = mn.id_doc  
;


create or replace view v_semiproducts_minremains as
select
--������ �������� �� ����� ������� �� �� ������������ �� �� �������
  --s.*
  s.id, 
  s.qnt,           --������� �� ���� ������� 
  s.rezerv,        --������ �� ���� ������� � ���������
  s.qnt_onway,     --���������� "� ����"  
  s.need,          --����������� �����������
  s.need_m,        --����������� � ������ ���. �������
  s.min_ostatok    --����������� �������
from
  v_spl_minremains s,
  v_semiproducts_nomencl n
where
  n.id_nomencl = s.id
;     


create or replace view v_semiproducts_srcorders as
select
--�������� ������ ��� ������������ ������� ����������� ������� � �� �� ������,
--�� ���� ����� �������, ����������� � ������� ���
  rownum as id,            --��������� ����
  oi.id_order,
  oi.id as id_order_item,
  v.id_nomencl,
  v.name,                  --������������ ������������ � ��� (��������� ��� �������� �� � ����� ����� ��) 
  v.id_unit,               --�������� ������� ���������  
  id_nomizdel_parent_t,    --���� �������, � ������� �������� ������������, � ���
  oi.itemname,             --������������ ������� ������ � ����� (��� ��������)
  oi.ornum,                --����� ������
  oi.project,              --������
  oi.slash,                --����
--  oi.qnt as qnt_in_order,  --���������� � ������
  niz.count_nomencl as qnt_in_order,  --���������� � ������ (����� �� ����� � ���)  
  oi.ornum || ' ' || oi.project || ' ['  || to_char(oi.dt_otgr, 'DD.MM.YYYY') || ']' as ordercaption,  --��������� ������
  oi.slash || ' ' || oi.itemname as itemcaption,  --��������� ������� 
  oi.dt_beg,
  oi.dt_otgr,
  s.qnt as qnt_stock,                             --���������� �� ������ 
  case when mog.id_order is not null 
    then nullif(oi.qnt - nvl(mo.qnt_in_order, 0), 0)
    else null
  end as qnt_in_order_diff,  --��������� � ������ � ������� ��������� ������   
  --s.rezerv, s.qnt_onway, s.need_m, 
  s.need,                                         --����������� �����������
  s.min_ostatok as qnt_nin,                       --����������� �������������� �������
  s.qnt as qnt_on_stock,                          --������� ���������� �� ������
  s.qnt_onway,
  s.has_files,                                    --������� ������� ������ ��� ������������
  mo.qnt_in_order as qnt_in_order_old,            --������� ���� � ������ ������� ��� ��������� ������������ ������
  mog.id_order as ors,  
  mo.qnt_in_demand as qnt_in_demand_old           --������� ���� � ������� ������� ��������  
from
  v_semiproducts_nomencl v
  inner join dv.nomenclatura_in_izdel niz
    on niz.id_nomencl = v.id_nomencl
  inner join v_order_items oi
    on oi.id_itm = niz.id_nomizdel_parent_t
  inner join v_spl_minremains s
    on v.id_nomencl = s.id
  inner join (select sys_context('context_uchet22','semiproduct_supplier') as id_supplier from dual) sp
    on 1 = 1
  left outer join j_semiproducts_src mo
    on mo.id_order = oi.id_order and mo.id_order_item = oi.id and mo.id_nomencl = v.id_nomencl and mo.id_supplier = sp.id_supplier
  left outer join (select id_supplier, id_order from j_semiproducts_src group by id_supplier, id_order) mog
    on mog.id_order = oi.id_order and mog.id_supplier = sp.id_supplier
where
  niz.id_zakaz in (select id_doc from v_semiproducts_or_in_reserve)
; 

      
    
--------------------------------------------------------------------------------
--� ������� ����������� ������ �� ����� ������� ������� ��-������� � ����������� ������ �� 
--�������� ����� �� ������ � ����������������� ������ �� ������� ������������ ������ ������
--drop  table j_semiproducts_src cascade constraints;
--alter table j_semiproducts_src drop constraint pk_j_sem_orders_oritem;
--alter table j_semiproducts_src add constraint fk_j_sem_orders_oritem foreign key (id_order_item) references order_items(id);
create table j_semiproducts_src(
  id_supplier number(11),           --���� ���������� ��������������
  id_order number(11),              --���� ������������ ������
  id_order_item number(11),         --���� ������� 
  id_nomencl number,                --���� ������������ - ������������� � ���
  qnt_in_order number(11,3),        --���������� ����������� � ����������� ������ �����, ������� ���� �� ������ �������� ������  
  qnt_in_demand number(11,3),       --���������� � ������ 
  constraint pk_j_sem_orders primary key (id_supplier, id_order, id_order_item, id_nomencl),
  constraint pk_j_sem_orders_or foreign key (id_order) references orders(id),
  constraint fk_j_sem_orders_oritem foreign key (id_order_item) references order_items(id)
);

--insert into j_semiproducts_src (id_supplier, id_order, id_order_item, id_nomencl, qnt_in_order, qnt_in_demand) values (6212, 9785, 302382, 42089, 170, 1);


create or replace view v_semiproducts_get_std_item as
select
--��� ������� ������ ��������������� ������������� �� ����� ���������� ������:
--����������� ������� ��� ����, ���������� �� �����, � ���� ���������� �� ������� ������� �� � ���� ��������
  si.name,
  si.id as id_std_item, si.fullname, si.id_or_format_estimates, si.dt_estimate,
  o.id as id_template
from
  v_or_std_items si,
  (select id_std_item, min(id_order) as id_order from order_items group by id_std_item) oi,
  orders o
where
  oi.id_std_item (+) = si.id
  and o.id (+) = oi.id_order
  and oi.id_order (+) < 0
  --and si.id > 0
;
  
select * from dv.demand order by id_demand desc;




select * from v_semiproducts_get_std_item
where name = '������ ���� 1650 ��������� - ��������� ����.04.01.00_�01 RAL 7022'
;










