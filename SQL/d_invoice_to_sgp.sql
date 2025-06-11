/*
��������� ����������� �� ���
*/

  

--��������� ����������� �� ���
alter table invoice_to_sgp add items varchar(4000);
create table invoice_to_sgp (
  id number(11),
  num number,                 --����� ���������
  id_order number(11),        --���� ������, �� �������� ������� ���������
  dt_m date,                  --���� � ����� �������� � ����� ������ �� ��������� ��������
  dt_s date,                  --���� � ����� ������� �� ��� �� ������ ���������
  state number(1),            --������. 0-�������, 1-���������� �����������, ������ �� ���, 2-���������� �����������, ������ ��� 
  id_user_m number(11),       --���� ������� 
  id_user_s number(11),       --���� ���������� 
  items varchar(4000),        --����� � ������� �� ����� �����������  
  constraint pk_invoice_to_sgp primary key (id),
  constraint fk_invoice_to_sgp_id_order foreign key (id_order) references orders(id) on delete cascade,  
  constraint fk_invoice_to_sgp_id_user_m foreign key (id_user_m) references adm_users(id),  
  constraint fk_invoice_to_sgp_id_user_s foreign key (id_user_s) references adm_users(id)  
);  

--�������� ������������ ������ ��������� � �������� ����
create unique index idx_invoice_to_sgp_num on invoice_to_sgp(num, to_char(dt_m, 'yyyy'));

create sequence sq_invoice_to_sgp start with 1 nocache;

create or replace trigger trg_invoice_to_sgp_bi_r
  before insert on invoice_to_sgp for each row
begin
  select sq_invoice_to_sgp.nextval into :new.id from dual;
end;
/

create or replace view v_invoice_to_sgp as
select
--��� ��������� ����������� �� ��� (�����)
  i.*,
  trunc(i.dt_m) as dt1_m,
  trunc(i.dt_s) as dt1_s,
  o.ornum,
  o.dt_beg,
  o.dt_otgr,
  o.project,
  o.area,
  o.area_short,
  um.name as user_m,
  us.name as user_s
from
  invoice_to_sgp i,
  v_orders o,
  adm_users um,
  adm_users us
where
  o.id = i.id_order
  and um.id (+) = i.id_user_m   
  and us.id (+) = i.id_user_s   
;    

--------------------------------------------------------------------------------
--������� ������� ��������� ����������� �� ���
create table invoice_to_sgp_items(
  id number(11),                       --����
  id_invoice number(11),               --���� ������������ ��������� 
  id_order_item number(11),            --���� ������� � ������
  qnt_m number(11,3),                  --���������� ����������
  qnt_s number(11,3),                  --���������� �������� 
  constraint pk_invoice_to_sgp_items primary key (id),
  constraint fk_invoice_to_sgp_items_inv foreign key (id_invoice) references invoice_to_sgp(id) on delete cascade,  
  constraint fk_invoice_to_sgp_items_order foreign key (id_order_item) references order_items(id) on delete cascade  
);  

create sequence sq_invoice_to_sgp_items start with 1 nocache;

create or replace trigger trg_invoice_to_sgp_items_bi_r
  before insert on invoice_to_sgp_items for each row
begin
  select sq_invoice_to_sgp_items.nextval into :new.id from dual;
end;
/

create or replace view v_invoice_to_sgp_items as
select
--��� ������� ��������� ����������� �� ���
  i.*,
  o.id_order,
  o.slash,
  o.itemname,
  o.fullitemname,
  o.sgp,
  o.qnt
from
  invoice_to_sgp_items i,
  v_order_items o
where
  i.id_order_item = o.id  
;  


create or replace view v_invoice_to_sgp_getitems as
select
--��� ��� ��������������� ��������� ������ ������ ��� ��������� ����������� �� ������
  o.id_order,
  o.ornum,
  o.area,
  o.id,                                 --���� ������� � ������
  o.slash, 
  o.fullitemname, 
  o.qnt,
  nvl(s.qnt, 0) as qnt_sgp,             --���������� �������, ��� ��������  �� ���
  o.qnt - nvl(s.qnt, 0) as qnt_max      --����������, ��������� � ���������� 
from
  v_order_items o,
  (select id_order_item, nvl(sum(qnt), 0) as qnt from order_item_stages where id_stage = 2 group by id_order_item) s
where
  o.id = s.id_order_item(+)
  and o.qnt > 0
  and nvl(sgp, 0) = 0
; 

--������ ��������� ������� �������, �� ������� ��� ���� ���������� �� ��� �������
select distinct(ornum) from (select ornum from v_invoice_to_sgp_getitems where qnt > qnt_sgp and area = 1) order by ornum;












select * from v_invoice_to_sgp_items;
select ornum, id from orders where area = 1 and dt_end is null and dt_to_sgp is null order by ornum;

select ornum, project, dt_beg, dt_otgr from orders where id = 3791;

select id_order_item, max(slash), max(fullitemname), max(qnt), sum(qnt2), null from v_order_item_stages1 where id_order = 3791 and id_stage = 2 and nvl(sgp, 0) = 0 group by id_order_item order by slash;
select num, id_order, ornum, project, dt_beg, dt_otgr, dt_m, user_m from v_invoice_to_sgp;

delete from invoice_to_sgp;
----------------
