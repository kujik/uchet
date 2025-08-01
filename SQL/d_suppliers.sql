/*
������� ��������� � �����

--�������� ������� ������������ ������ ��
--������� ������ �� ���� ������� � ���
--������ �� �� ���������
--��������� ����������, �� ����� � ������� � �������� �������
--����������� � ����� ������ � ��������� ��������� �� ���

��������:
  ��� ������ ���������� �������� ������� �� ��������� ������������ ������ �������� �� ��� ���� �������
  (v_spl_qntonstocks_sum)

*/

alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--������� � ��� ������� ���������� �� ���������
alter table dv.namenom_supplier add is_default number(1) default(0);
--create unique index dv.idx_namenom_supplier_isdef on dv.namenom_supplier (id_supplier, decode(is_default, 0, null, 1));
comment on column dv.namenom_supplier.is_default is '��������� �� ��������� ��� ���� ������������, ���� =1';

alter table dv.namenom_supplier add httplink varchar2(4000);
comment on column dv.namenom_supplier.httplink is '������ �� ���� ��� ������ �������';

alter table dv.namenom_supplier add addcomment varchar2(4000);
comment on column dv.namenom_supplier.httplink is '����������� (�������) � ������ �������';

--���������� �� ���� ������ � ��������� � ����������� ������� ���
alter table dv.sklad add sgp number(1) default(0);
comment on column dv.sklad.sgp is '����� ������� ���������, ���� =1';
alter table dv.sklad add area number(1) default(0);
comment on column dv.sklad.area is '���� ���������������� �������� ��� ������';




--��������� ��� ������ � ��������� 
--��������� ������������� ������ ������������, ������ ����������� ������ �� ���������� ���������
--������������ ������ �� ��������� �������� ������ ����������� � ��� ������������� 
create table spl_categoryes(
  id number(11),
  name varchar2(50) not null,       --������������ ���������         
  useravail varchar2(4000),         --���� ������������� ����� ������� 
  constraint pk_spl_categoryes primary key (id)
);

--���������� ������������ ��� ����� ��������
create unique index idx_spl_categoryes_name on spl_categoryes(lower(name)); 
  
create sequence sq_spl_categoryes start with 1 nocache;

create or replace trigger trg_spl_categoryes_bi_r
  before insert on spl_categoryes for each row
begin
  select sq_spl_categoryes.nextval into :new.id from dual;
end;
/

create or replace view v_spl_categoryes as select
--��� ��� ����������� ��������� ������ �� ���������
  sc.*,
  --������ ���� ������������� �� ������ ���������
  GetUserNames(sc.useravail) as usernames 
from
  spl_categoryes sc
;    

--��������� '���������' ������ ���� � id=1
insert into spl_categoryes (name) values ('���������');
update spl_categoryes set id = 1 where name = '���������';

--��� ��������� ������������ ��� ��� ���������
--alter table spl_itm_nom_props add planned_need_days number(2);
--alter table spl_itm_nom_props add planned_need_qnt number(11,3);
--alter table spl_itm_nom_props add constraint fk_spl_itm_nom_props_category foreign key (id_category) references spl_categoryes(id);
create table spl_itm_nom_props(
  id number(11),                    --���� ������������ � ���  dv.nomenclatura.id_nomencl
  id_category number(11),           --���� ��������� ���������
  tomin number(1) default 0,        --������������ �� � ��� ��������
  dt_correct date,                  --���� ������������� ��� ��������
  qnt_order number(11,3),           --���������� � ������
  qnt_order_opt number(11,3),       --��� ������ � �������� ��������
  to_order number(1) default 0,     --����� � �����
  prc_min_ost number(5),            --������� �������������� �� ���. �������
  prc_qnt number(5),                --������� �������������� �� ���� �������
  prc_need_m number(5),             --������� �������������� �� ����������� � ������ ��� �������
  price_check number(11,2),         --����������� ����, ������������� ������������  
  has_files number(1) default 0,    --�� ������������ ��������� �������������� �����    
  planned_need_days number(2),      --���������� ���� ������������ ��������, �� �������� ��������� �������� �����������
  --planned_need_qnt number(11,3),              --
  constraint pk_spl_itm_nom_props primary key (id),
  constraint fk_spl_itm_nom_props_category foreign key (id_category) references spl_categoryes(id)
);


--alter table spl_minremains_params add planned_dt date;
--alter table spl_minremains_params add onway_old_days number;
--alter table spl_minremains_params drop column defprc;  
create table spl_minremains_params(
  d0 number(4, 0),  --���������� ���� ���������� �������
  d1 number(4, 0),  --���������� ���� �������� ��������� ������� � ������� (�� 6) ��� ���������
  d2 number(4, 0),
  d3 number(4, 0),
  d4 number(4, 0),
  d5 number(4, 0),
  d6 number(4, 0),
  prc_min_ost number(5),--������� �������������� �� ���. �������
  prc_qnt number(5),    --������� �������������� �� ���� �������
  prc_need_m number(5), --������� �������������� �� ����������� � ������ ��� �������
  on_demand_days number(3),  --���������� ���� �� ������� �� ���������, ����� �� ��� ������������ � ������� "� ���������" (���� ���)
  onway_custom number(1) default 0,    --���������� "� ����" �� �� ����� �������, � �� �������� ����� - ��� ���� (���� ���); ����� ������ �� ��������� ��������� - � ���� ����� ������� �� ����� �����, ��������� �� �����
  onway_dt1 date,       --���� ��� ������� � ���� (�������, ��������, ����� �������!)   
  onway_dt2 date,       --���� ��� ������� � ���� (���������)
  planned_dt date,      --���� ���������� ����������� �� �������� �������
  onway_old_days number --���������� ���� ��� ������� � ����, ���� ���� ������ ����� ���� ����, �� ������ ��������������.
);

update spl_minremains_params set on_demand_days = 27;


--��������� �������, ������ ��������� �������� � ����������� ����� ����������� ��������,
--�������� ��� �������� �����������
alter table spl_remains_enter drop column min_part;
alter table spl_remains_enter add e_qnt_order_opt number(1);
alter table spl_remains_enter add constraint spl_remains_enter primary key (id); 
create global temporary table spl_remains_enter (
  id number(11),
  min_ostatok number(14),
  qnt_order_opt number(14),
  e_min_ostatok number(1),          --�������� ��������������
  e_qnt_order number(1),
  e_qnt_order_opt number(1),
  constraint spl_remains_enter primary key (id)
)  
on commit preserve rows;


create or replace view v_spl_namenom as select 
--��� ��� ����������� ������ ������������ �����������
  ns.*,
  k.full_name as supplier,
  u.name_unit as supplierunitname,
  w.name_unit as baseunitname,
  n.name as basenomenclname,
  0 as usedcnt
  --nu.usedcnt as usedcnt
from 
  dv.namenom_supplier ns
  inner join dv.nomenclatura n on n.id_nomencl = ns.id_nomencl  
  left outer join dv.kontragent k on ns.id_supplier = k.id_kontragent  
  left outer join dv.unit u on ns.id_base_unit = u.id_unit
  left outer join dv.unit w on n.id_unit  = w.id_unit
;

select * from dv.namenom_supplier where id_nomencl = 19077;  


create or replace view v_spl_namenom_used as select
--��� ��������, ��� ������ ������������ ���������� �����������
--(��������� � ������ ����������� � � ������� �����������
  count(*) as usedcnt,
  dss.id_nomencl,
  ds.id_supplier
from
  dv.demand_supplier_spec dss,
  dv.demand_supplier ds
where
  dss.id_demand_supplier = ds.id_demand_supplier 
group by id_nomencl, id_supplier  
;


select * from v_spl_nom_lastibprice where id_nomencl = 15203;

create or replace view v_spl_nom_lastibprice as 
select
--��������� ���������� ���� �������������� ������� �� ������ ��������� ���������
  ibs.rn, ibs.id_inbill, ibs.id_nomencl, ibs.ibprice as ibprice, round(s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity), 2) as price_last from  
  (
    select max(ibs.id_ibspec) as id_ibspec, ib.id_inbill, ibs.id_nomencl, max(ibs.ibprice) as ibprice  
    ,row_number() over (partition by ibs.id_nomencl order by ib.id_inbill desc) as rn
    from 
    dv.in_bill ib
    inner join dv.in_bill_spec ibs
    on ib.id_inbill = ibs.id_inbill
    where ib.id_docstate = 3
    group by ib.id_inbill, ibs.id_nomencl
  ) ibs
  inner join
  dv.stock s
  on s.doctype = 1 and s.id_spec = ibs.id_ibspec
;  

/*select
  s.id_nomencl,  
  round(s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity), 2) as price_last
from 
  dv.stock s
where*/  

create or replace view v_spl_nom_lastibprice2 as 
select
--��������� ���������� ���� �������������� ������� �� ������ ��������� ��������� �������� ��� ������� ����������, ���������� �� ����� �/� �� ����
--���� ������������ ��� � ������ ��� � ��������� �� ����/��� ����������, 
--������ �� ���������� ���� ������� �� stock �� ��������� ��������� ��������� (�� �-� DV.CenaNomOld)
  ibs.rn,
  n.id_nomencl,
  ibs.id_inbill,
  ibs.id_kontragent,
  ibs.price_main
from  
  dv.nomenclatura n
  left outer join ( 
    select ibs.rn, ibs.id_inbill, ibs.id_kontragent, ibs.id_nomencl, ibs.ibprice as ibprice, round(s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity), 2) as price_main from  
      (
        select max(ibs.id_ibspec) as id_ibspec, ib.id_inbill, ib.id_kontragent, ibs.id_nomencl, max(ibs.ibprice) as ibprice 
        ,row_number() over (partition by ibs.id_nomencl, ib.id_kontragent order by ib.id_inbill desc) as rn
        from 
        dv.in_bill ib
        inner join dv.in_bill_spec ibs
        on ib.id_inbill = ibs.id_inbill
        where ib.id_docstate = 3
        group by ib.id_inbill, ib.id_kontragent, ibs.id_nomencl
        --order by ibs.id_nomencl, ib.id_kontragent, ib.id_inbill desc 
      ) ibs
      inner join
      dv.stock s
      on s.doctype = 1 and s.id_spec = ibs.id_ibspec
      ) ibs
    on n.id_nomencl = ibs.id_nomencl
--where n.id_nomencl = 13667    --id_k = 2787;  
;  

select * from v_spl_nom_lastibprice2 where id_nomencl = 13667;
select * from v_spl_nom_lastibprice2 where id_nomencl = 15203 order by id_inbill desc;
select * from v_spl_nom_lastibprice2 lp where lp.id_kontragent = 2787 and rownum = 1;
--13667 ����������/���������� 1��

select n.name, lp.* from
dv.nomenclatura n, 
v_spl_nom_lastibprice2 lp
where
  n.id_nomencl = lp.id_nomencl
  and lp.id_kontragent = 2805 and lp.id_nomencl = 13667 
  and rownum = 1
;  



create or replace view v_spl_nom_lastsupplierprice as 
select
--��������� ���������� ����� �������������� ������� �� ������������ ����� �� ����������
--��������� ���� ���������� �� ������������� ����
  smax.id,
  n.id_nomencl,
  n.name,
  sn.base_unit_k,
  sn.price,  --���� �� ������� ����������
  sn.price / nvl(sn.base_unit_k, 1) as price_main  --���� �� ���� ������� ���������
from 
  dv.nomenclatura n
  left outer join 
  --��������� ���� �� ������ ������������
  (select 
     max(s.id_schet) as id,
     ss.id_nomencl
   from
     dv.sp_schet s
     inner join dv.sp_schet_spec ss on ss.id_sp_schet = s.id_schet and s.id_docstate = 3
   group by
     ss.id_nomencl
  ) smax on n.id_nomencl = smax.id_nomencl
  left outer join
  --��������� ���� ������������ �� ���������� �����
  (select 
     ss.id_sp_schet as id,
     ss.id_nomencl,
     ss.price,
     ns.base_unit_k
   from
     dv.sp_schet s 
     inner join dv.sp_schet_spec ss on ss.id_sp_schet = s.id_schet
     --������� �����������, �� � ��� ���� (����?) � ���� - ����� ���� ��� ����� ������������ � ���������� ��������� �������
     --������� ���������� � ����������� ��������� �����������
     left outer join 
       (select id_nomencl, id_supplier, max(base_unit_k) as base_unit_k from dv.namenom_supplier group by id_nomencl, id_supplier) ns 
         on ns.id_nomencl = ss.id_nomencl and ns.id_supplier = s.id_kontragent2
  ) sn on smax.id = sn.id and smax.id_nomencl = sn.id_nomencl
;    

select count(*) from v_spl_nom_lastsupplierprice order by price desc;   
select distinct(name) from v_spl_nom_lastsupplierprice order by name;


create or replace view v_spl_nom_on_inbill as 
--��� ������ ���������� ������������, ����������� �� ������, ���������� ����� ���� �������
--����������� ������ ����������� ���������, �� ������ ����� �� �����������
select
  ii.id_nomencl, 
  sum(ii.fact_quantity) as qnt
from 
  dv.in_bill i,
  dv.in_bill_spec ii,
  dv.sp_schet s
where 
  i.id_docstate = 3
  and ii.id_inbill = i.id_inbill
  and s.id_schet = i.docid 
  and s.date_registr >= to_date('01.08.2024', 'DD.MM.YYYY')
group by ii.id_nomencl
;

create or replace view v_spl_nom_on_demand as 
--��� ������ ���������� ������������ �� ������� �� ��������� � ����� ������� ����� ���� �������
select
  ds.id_nomencl, 
  sum(ds.quantity) as qnt
from 
  dv.demand d,
  dv.demand_spec ds
where 
  d.id_demand = ds.id_demand
  and d.demand_date >= to_date('01.08.2024', 'DD.MM.YYYY')
group by ds.id_nomencl
;

create or replace view v_spl_nomencl_on_demand as 
--��� ������ ������ �� ������������ �� ������ �� ���������
select
  d.id_demand,
  d.demand_date,
  id_docstate,
  --4-����������, 3-�� ���������, 1-� ��������, 2-?
  decode(id_docstate, 1, '� ��������', 3, '�� ���������', 4, '����������', ',') as docstate,
  ds.id_nomencl, 
  ds.quantity
from 
  dv.demand d,
  dv.demand_spec ds,
  spl_minremains_params mp 
where 
  d.id_demand = ds.id_demand
  and d.demand_date >= sysdate - mp.on_demand_days
;

--select * from DV.V_DEMANDS;

create or replace view v_spl_nom_onway_agg as
--��� ������ ������� � ����
--��������� ����, �� ��� �� � ������� '3-������� �����' - ���� � ���� �� �� ���� �������� ��� ��� �� ��,
--�� ����� ������ ��������� ���������
--� ���� �������� ������� ����� ����������� � ����� (��� � �������� ����������, ��������������� �� �����������)
--� ����������� � ��������� (��� � �������� ��������), ���� ������� ����,
--��� ������������� �� ������������
select 
  max(n.name) as name,
  n.id_nomencl,
  sum(d.qnt) as qnt,
  max(flag) as flag
from
(
select
  s.id_n,
  s.quantity,
  i.fact_quantity,
  s.base_unit_k,
  s.quantity_main,
  s.quantity_main - nvl(i.fact_quantity, 0) as qnt,
  s.num,
  s.date_registr,
  --����, ��� ���� ������, ����� ��������� ����, �������� � ���������� ������� (��� ���������)
  case when s.date_registr < trunc(sysdate) - nvl(mp.onway_old_days, 365*10) then 1 else 0 end as flag
from   
(select 
  ss.id_nomencl as id_n, 
  ss.quantity,
  ss.id_sp_schet as id,
  ns.base_unit_k,
  ss.quantity * nvl(ns.base_unit_k, 1) as quantity_main,
  --ss.quantity as quantity_main,
  s.num,
  s.date_registr
from 
  dv.sp_schet s
  inner join dv.sp_schet_spec ss on ss.id_sp_schet = s.id_schet
  --�����������, ���� ��������� ��������� � ������������
  left outer join dv.namenom_supplier ns on ns.id_nomencl = ss.id_nomencl and ns.id_supplier = s.id_kontragent2  
where 
--  (s.states <> '4-������� �����' or s.date_registr >= to_date('01.04.2025', 'DD.MM.YYYY')) and
  s.states <> '4-������� �����' and
  s.id_docstate in (3, 4)  --2 - ��������, 3 - ������
  --and date_registr >= to_date('01.08.2024', 'DD.MM.YYYY')
) s, 
(select 
  ii.id_nomencl, 
  i.docid as id,
--  sum(ii.ibquantity) as fact_quantity   --� ��� ����������� ��� ����������
  sum(ii.fact_quantity) as fact_quantity
--  ii.ibquantity,
--  i.docid as id,
--  i.inbillnum
from 
  dv.in_bill i,
  dv.in_bill_spec ii
where 
  i.id_docstate = 3 and
  ii.id_inbill = i.id_inbill
  group by i.docid, ii.id_nomencl
) i,
spl_minremains_params mp
where
  s.id = i.id(+)
  and s.id_n = i.id_nomencl(+) 
  and (
  --������� ����������
  (nvl(onway_custom,0) = 0 and s.date_registr <= sysdate and s.date_registr >= to_date('01.08.2024', 'DD.MM.YYYY')) or
  --�������, ������������� � ���� ������� ���������   
  (nvl(onway_custom,0) = 1 and s.date_registr <= mp.onway_dt1 and s.date_registr >= mp.onway_dt2)
  )
  --�� �������� ������, � ������� ���������� �� ��������� � �� ����� ��������� (!!!��� 2025-02-14)
  and nvl(s.quantity_main, 0) <> nvl(i.fact_quantity, 0)
) d,
dv.nomenclatura n 
where
  d.id_n = n.id_nomencl
group by n.id_nomencl
;

create or replace view v_spl_nom_onway_agg_old as
--��� ������ ������� � ����
--��������� ����, �� ��� �� � ������� '3-������� �����' - ���� � ���� �� �� ���� �������� ��� ��� �� ��,
--�� ����� ������ ��������� ���������
--� ���� �������� ������� ����� ����������� � ����� (��� � �������� ����������, ��������������� �� �����������)
--� ����������� � ��������� (��� � �������� ��������), ���� ������� ����,
--��� ������������� �� ������������
select 
  max(n.name) as name,
  n.id_nomencl,
  sum(d.qnt) as qnt,
  max(flag) as flag
from
(
select
  s.id_n,
  s.quantity,
  i.fact_quantity,
  s.base_unit_k,
  s.quantity_main,
  s.quantity_main - nvl(i.fact_quantity, 0) as qnt,
  s.num,
  s.date_registr,
  --����, ��� ���� ������, ����� ��������� ����, �������� � ���������� ������� (��� ���������)
  case when s.date_registr < trunc(sysdate) - nvl(mp.onway_old_days, 365*10) then 1 else 0 end as flag
from   
(select 
  ss.id_nomencl as id_n, 
  ss.quantity,
  ss.id_sp_schet as id,
  ns.base_unit_k,
  ss.quantity * nvl(ns.base_unit_k, 1) as quantity_main,
  --ss.quantity as quantity_main,
  s.num,
  s.date_registr
from 
  dv.sp_schet s
  inner join dv.sp_schet_spec ss on ss.id_sp_schet = s.id_schet
  --�����������, ���� ��������� ��������� � ������������
  left outer join dv.namenom_supplier ns on ns.id_nomencl = ss.id_nomencl and ns.id_supplier = s.id_kontragent2  
where 
  s.states <> '4-������� �����' and
  s.id_docstate in (3, 4)  --2 - ��������, 3 - ������
  --and date_registr >= to_date('01.08.2024', 'DD.MM.YYYY')
) s, 
(select 
  ii.id_nomencl, 
  i.docid as id,
--  sum(ii.fact_quantity) as fact_quantity
    sum(ii.ibquantity) as fact_quantity

--  ii.ibquantity,
--  i.docid as id,
--  i.inbillnum
from 
  dv.in_bill i,
  dv.in_bill_spec ii
where 
  i.id_docstate = 3 and
  ii.id_inbill = i.id_inbill
  group by i.docid, ii.id_nomencl
) i,
spl_minremains_params mp
where
  s.id = i.id(+)
  and s.id_n = i.id_nomencl(+) 
  and (
  --������� ����������
  (nvl(onway_custom,0) = 0 and s.date_registr <= sysdate and s.date_registr >= to_date('01.08.2024', 'DD.MM.YYYY')) or
  --�������, ������������� � ���� ������� ���������   
  (nvl(onway_custom,0) = 1 and s.date_registr <= mp.onway_dt1 and s.date_registr >= mp.onway_dt2)
  )
  --�� �������� ������, � ������� ���������� �� ��������� � �� ����� ��������� (!!!��� 2025-02-14)
  and nvl(s.quantity_main, 0) <> nvl(i.fact_quantity, 0)
) d,
dv.nomenclatura n 
where
  d.id_n = n.id_nomencl
group by n.id_nomencl  
;  
  
select 
  v1.name, v1.qnt, v2.qnt
from 
  v_spl_nom_onway_agg v1,  v_spl_nom_onway_agg_old v2
where
  v1.id_nomencl = v2.id_nomencl(+)
  and nvl(v1.qnt,0) <> nvl(v2.qnt,0)
;    


select * from v_spl_nom_onway_agg;

--select id_schet from dv.sp_schet where num = '110169' order by 1;
select inbillnum from dv.in_bill where docid = (select id_schet from dv.sp_schet where num = '110169') order by 1;
select * from dv.in_bill_spec where id_inbill in (select id_inbill from dv.in_bill where docid = (select id_schet from dv.sp_schet where num = '110169'));



create or replace view v_spl_onway_detail as select
--������ ������ ����������, ������� � ���� � ����������� ������������ � ����
--�� ���������� �� ������ � ������ ����� '3-������� �����' � �����������
--id_docstate = 1 - � ��������, 2 - ��������, 3 - ������ 
--(���������� � ����� � �������� ���������� � ��������������� �� ������������ �� namenom_supplier) 
--���������� ���������� �� ��������� ��������� ��� ������� ����� (������� � ����� ��������)
  s.id, 
  s.control_date,
  s.date_registr, 
  s.num, 
  s.name_org, 
  s.quantity_main, 
  s.quantity_suppl,
  s.unit_suppl,
  i.fact_quantity, 
  s.quantity_main - i.fact_quantity as rest, 
  s.id_n
from 
(select 
  ss.id_nomencl as id_n, ss.quantity, ss.id_sp_schet as id, round(ss.quantity * nvl(ns.base_unit_k, 1),2) as quantity_main, k.name_org, ss.quantity as quantity_suppl, u.name_unit as unit_suppl, s.* --, s.num, s.control_date  
  from 
    dv.sp_schet s
    inner join dv.sp_schet_spec ss on ss.id_sp_schet = s.id_schet
    inner join dv.kontragent k on s.id_kontragent2 = k.id_kontragent
    --����� ��������� ������ �����, ���� ��������� ������� ��� ��������� � namenom_supplier ����� ������ ����������, ��� ��������� ����� �����������
    left outer join dv.namenom_supplier ns on ns.id_nomencl = ss.id_nomencl and ns.id_supplier = s.id_kontragent2
    left outer join dv.unit u on ss.id_unit = u.id_unit 
  where  
    s.states <> '4-������� �����' and
    s.id_docstate in (3,4)  --2 - ��������, 3 - ������
    --and date_registr >= to_date('01.08.2024', 'DD.MM.YYYY')
) s
left outer join
(select 
ii.id_nomencl as id_n, i.docid as id, round(sum(ii.fact_quantity),2) as fact_quantity, ii.id_nomencl
  from dv.in_bill i, dv.in_bill_spec ii 
  where 
    i.id_docstate = 3 and ii.id_inbill = i.id_inbill 
  group by i.docid, ii.id_nomencl
) i 
on s.id = i.id and s.id_n = i.id_n
inner join spl_minremains_params mp on 
  (nvl(onway_custom,0) = 0 and s.date_registr <= sysdate and s.date_registr >= to_date('01.08.2024', 'DD.MM.YYYY')) or   
  (nvl(onway_custom,0) = 1 and s.date_registr <= mp.onway_dt1 and s.date_registr >= mp.onway_dt2)
;


--------------------------------------------------------------------------------
create or replace procedure P_CreateSplDemand(
--������� ������������ ������ �� ��������� � �� ���, �� ���������� ��������� ���������
  IdCategory in number
) is
  NameCategory varchar2(400);
  IdDemand number;
  cursor c1 is
    select
      n.id_nomencl, n.id_unit, p.qnt_order
    from
      spl_itm_nom_props p, 
      dv.nomenclatura n
    where
      p.id = n.id_nomencl and nvl(p.qnt_order, 0) > 0 and p.to_order = 1 and nvl(p.id_category,0) = IdCategory 
  ;
begin
  --������� ������������ ����������
  select name into NameCategory from spl_categoryes where id = IdCategory;
  --�������� ������ �� � �� ���, ������� ����
  insert into dv.demand (id_category, id_docstate, comments, control_date) 
    values (3, 1, '���� (' || NameCategory || ')', (select trunc(sysdate) + 7 from dual)) 
    returning id_demand into IdDemand;
  --������ � ������ ��� �������, ���������� � ������ � ������ ��������� � � ��������� ����������� � ������
  for n in c1 loop
    insert into dv.demand_spec 
      (id_demand, quantity, id_nomencl, id_unit)
      values
      (IdDemand, n.qnt_order, n.id_nomencl, n.id_unit);
  end loop;
  --������� ����� "� �����" ��� ���� ���� �������
  update spl_itm_nom_props set to_order = 0 where id_category = IdCategory;
end;
/  

create or replace procedure P_SetSplDemandValue(
--������������� �������� � �������� ��� ����� ������ � ����� ��� ������������ ������ �� ���������
--�����:
--1 - ������� � �����
--2 - ����������� �������
--3 - ����������� �����
--4 - ���������� � ������
--5 - ������� � �����
--6 - ���������
--7 - ����������� ����
--8 - ������� ������� ����������� ������ � ������������
--9 - ���������� ���� ��� ������� �� �������� �����������
  IdNomencl in number,
  PMode in number,
  PValue in number 
) is
  c number;
begin
  select count(1) into c from spl_itm_nom_props where id = IdNomencl;
  if c = 0 then
    insert into spl_itm_nom_props (id) values (IdNomencl);
  end if;
  select count(1) into c from spl_remains_enter where id = IdNomencl;
  if c = 0 then
    insert into spl_remains_enter (id) values (IdNomencl);
  end if;
  if PMode = 1 then 
    update spl_itm_nom_props set tomin = PValue where id = IdNomencl;
  end if;  
  if PMode = 2 then 
    update dv.nomenclatura set min_ostatok = PValue where id_nomencl = IdNomencl;
    update spl_remains_enter set e_min_ostatok = 1 where id = IdNomencl;
  end if;  
  if PMode = 3 then 
    update spl_itm_nom_props set qnt_order_opt = PValue where id = IdNomencl;
    update spl_remains_enter set e_qnt_order_opt = 1 where id = IdNomencl;
  end if;  
  if PMode = 4 then 
    update spl_itm_nom_props set qnt_order = PValue where id = IdNomencl;
    update spl_remains_enter set e_qnt_order = 1 where id = IdNomencl;
  end if;  
  if PMode = 5 then 
    update spl_itm_nom_props set to_order = PValue where id = IdNomencl;
  end if;  
  if PMode = 6 then 
    update spl_itm_nom_props set id_category = PValue where id = IdNomencl;
  end if;  
  if PMode = 7 then 
    update spl_itm_nom_props set price_check = PValue where id = IdNomencl;
  end if;  
  if PMode = 8 then 
    update spl_itm_nom_props set has_files = PValue where id = IdNomencl;
  end if;  
  if PMode = 9 then 
    update spl_itm_nom_props set planned_need_days = PValue where id = IdNomencl;
  end if;  
end;
/  

































SELECT * FROM dv.v_demands;
/*
demand
id_category = 3
demand_date auto
demand_num auto
control_date +week
comments �� �����
id_docstate =1
doctable=null
docid = 0
*/

create or replace view v_spl_consumption as
--������ �� �������������� ������� - ������� ����������, �� ������� ��� ������
--(������ �� �����������)
--��������� ����������� �� ����� ������������
select
  rownum as id,
  a.*
from (  
select
  s.id_movebill as id_doc,
  1 as doctype,
  '��������� �����������' as doctypename,
  s.id_nomencl as id_nomencl,
  m.movebillnum as docnum,
  m.movebilldate as dt,
  sk.skladname as scladname,
  m.comments as comm,
  z.numzakaz as basedoc, 
  --s.movebillquantity as qnt
  s.itogoquantity as qnt 
from 
  dv.move_bill m,
  dv.move_bill_spec s,
  dv.sklad sk,
  dv.zakaz z
where
  m.id_docstate = 3  --���������
  and m.id_skladdest = 842  --�� ����� ������������
  and s.id_movebill(+) = m.id_movebill 
  and sk.id_sklad (+) = m.id_skladsource
  and m.id_zakaz = z.id_zakaz (+)
union 
--���� �������� 
select 
  m.id_offminus as id_doc,
  2 as doctype,
  '��� ��������' as doctypename,
  s.id_nomencl as id_nomencl,
  m.offminusnum as docnum,
  m.offminusdate as dt,
  m.skladname as skladname,
  m.basedoc as basedoc,
  m.comments as comm, 
  s.omquantity as qnt
from 
  dv.v_offminuses m,
  dv.off_minus_spec s
where
  m.id_offminus = s.id_offminus
  and m.id_docstate = 3
) a  
;  

create or replace view v_spl_rezerv_detail as select
--���������� �� �������
--������ �� ��������� ���, ������ �� ������ �� �����
  mn.stockdate, 
  mn.numdoc,
  mn.id_nomencl,
  o.ornum,
  o.dt_beg,
  o.dt_end,
  o.project,
  o.dt_otgr, 
  pa.shortname as area_short,
  mn.rashod 
from 
  dv.v_movenomencl mn,
  orders o,
  ref_production_areas pa
where 
  mn.doctype = 27
  and o.ornum (+) = mn.numdoc
  and pa.id (+) = o.area
;


create or replace view v_spl_schetbynomencl as
--������ ���� ������ �� ������ ������������
--���������� ��� �������� ��������� (�����), ��� � �������������� ������� � �����. 
select
   s.id_schet, s.num, date_registr, s.control_date, s.states, s.docstr,
   k.name_org,
   ss.id_nomencl, ss.name, round(ss.price, 2) as price, ss.quantity, ss.unit
from 
  dv.sp_schet s, 
  dv.kontragent k,
  dv.v_spschetspec ss
where 
  k.id_kontragent = s.id_kontragent2
  and ss.id_schet = s.id_schet
;


create or replace view v_spl_rezerv_list as
select 
--��� ������� ������ �� ���������, �� ������ ������ ��������������
  mn.id_nomencl,
  mn.rashod as rezerv,
  decode(o.area, 0, mn.rashod, null) as rezerv0, 
  decode(o.area, 1, mn.rashod, null) as rezerv1, 
  decode(o.area, 2, mn.rashod, null) as rezerv2, 
  o.area
from
  dv.v_movenomencl mn,
  orders o
where
  mn.doctype = 27
  and o.id_itm = mn.id_doc  
;    


select * from dv.sklad;

create or replace view v_spl_qntonstocks_sum as
select 
--��� ������� ���������� �� ������������ �� ������� �������
--(�����, ����� ������������, � �� ���������)
--id_sklad ������ ����� ���� null!
  id_nomencl,
  sum(qnt) as qnt,
  sum(qnt0) as qnt0,
  sum(qnt1) as qnt1,
  sum(qnt2) as qnt2
from (
  select
    id_nomencl, 
    id_sklad,
    --�����, ����� ������� ������������ (��, �, ��)
    sum(decode(id_sklad, null, 0, 842, 0, 922, 0, 982, 0, quantity)) as qnt,
    --��, ����� ������� ������������ � "��� �", "����� ����� �" ,��� ��", "����� ����� ��"    
    sum(decode(id_sklad, null, 0, 842, 0, 922, 0, 982, 0, 862, 0, 902, 0, 983, 0, 962, 0, quantity)) as qnt0,
    --� - "��� �", "����� ����� �" 
    sum(decode(id_sklad, null, 0, 862, quantity, 902, quantity, 0)) as qnt1,   
    --�� - "��� ��", "����� ����� ��" 
    sum(decode(id_sklad, null, 0, 983, quantity, 962, quantity, 0)) as qnt2   
  from 
    dv.stock s 
  where 
    s.doctype<>27 
  group by 
    s.id_nomencl, s.id_sklad
) 
  group by 
    id_nomencl
;

create or replace function F_GetOrdersWhereNoQnt (
--������ ����� � ���� ������ ������� �� �������� ������, �� ������� �� ������� ������ ����� �������
IdNom number,
Qnt number, 
OnWay number 
)
return varchar2   
is
   cv sys_refcursor; 
   qntor number;
   qntcum number;
   orname varchar2(40);
   dtotgr date;
   res varchar2(50);   
begin
   res := '';
   qntcum := 0;
   open cv for
     'select mn.rashod, o.ornum, o.dt_otgr from dv.v_movenomencl mn, orders o ' ||
     'where mn.doctype = 27 and o.ornum (+) = mn.numdoc and id_nomencl = :id_nomencl order by dt_otgr asc, ornum asc' 
     using IdNom;
--      'select rashod, ornum, dt_otgr from v_spl_rezerv_detail_ where id_nomencl = :id_nomencl order by dt_otgr asc, ornum asc' using IdNom; 
   loop
      fetch cv into qntor, orname, dtotgr;
      exit when cv%notfound;
      qntcum := qntcum + abs(qntor); --rashod ������ �������������!
      exit when qntcum > nvl(Qnt, 0) + nvl(OnWay, 0);
   end loop;
   close cv;
   if qntcum > nvl(Qnt, 0) + nvl(OnWay, 0) then
     --������ ����� ������ � ���� ��������, �� ������� ��� �������� �������� ������� + � ����
     res := orname || ' ' || to_char(dtotgr, 'DD.MM.YYYY');
   end if;
   return res;
end;
/ 

/*select rashod, ornum, dt_otgr from v_spl_rezerv_detail where id_nomencl = '31691' order by dt_otgr asc, ornum asc;
select F_GetOrdersWhereNoQnt(31691, qnt, null) from dual; 
select id, qnt, ornumwoqnt from v_spl_minremains where id = 31691;*/

  


create or replace view v_itm_movenomencl as 
--�������� ������������
--���� ����������� �� ������, �� �� ��� ������ ������������ ����� �� �����������
--  "����� �� ������ ������������" (��� � ��������), � ��� ������ "����� �� ����� ������������" (��� � ��������) 
select
  a.*,
  o.dt_beg,
  o.project,
  o.dt_otgr,
  o.dt_end
from (  
select
  n.name,
  n.id_nomencltype,
  mn.*,
  s.skladname,
  --��������� ���������
  (case when mn.doctype = 1 
    then (select docstr from dv.in_bill where id_inbill = id_doc) 
  --��������� ���������
  when mn.doctype = 2
    then mn.sourcedoc
  --��������� �����������
  when mn.doctype = 3
--    then (select comments from dv.move_bill where id_movebill = id_doc)
    then substr(mn.comments, -7, 7)
  --��� 
  when mn.doctype = 4
    then (select numzakaz from dv.v_acts where id_act = id_doc) 
  --��� �������������
  when mn.doctype = 5
    then null
  --��� ��������
  when mn.doctype = 6
    then null
  --������
  when mn.doctype = 27
    then numdoc
  end
  ) as basis,
  (case when mn.doctype = 1 
    then s.skladname 
  --��������� ���������
  when mn.doctype = 2
    then null
  when mn.doctype = 3
    then (select destskladname from dv.v_move_bills where id_movebill = id_doc) 
  --��� 
  when mn.doctype = 4
    then (select s.skladname from dv.acts a, dv.sklad s where a.id_act = id_doc and s.id_sklad = a.sklad_in) 
  --��� �������������
  when mn.doctype = 5
    then s.skladname
  --��� ��������
  when mn.doctype = 6
    then null
  --�������
  when mn.doctype = 27
    then ''
  end
  ) as skladdest,
  (case when mn.doctype = 1 
    then null 
  --��������� ���������
  when mn.doctype = 2
    then s.skladname
  when mn.doctype = 3
    then (select sourceskladname from dv.v_move_bills where id_movebill = id_doc) 
  --��� 
  when mn.doctype = 4
    then (select s.skladname from dv.acts a, dv.sklad s where a.id_act = id_doc and s.id_sklad = a.sklad_out) 
  --��� �������������  off_minus
  when mn.doctype = 5
    then null
  --��� ��������
  when mn.doctype = 6
    then s.skladname
  --�������
  when mn.doctype = 27
    then null
  end
  ) as skladsrc
from 
  dv.v_movenomencl mn,
  dv.sklad s,
  dv.nomenclatura n
where
  mn.id_nomencl = n.id_nomencl
  and nvl(mn.id_sklad, 0) = s.id_sklad (+)
) a,
  orders o
where
  a.basis = o.ornum (+)
--and (skladsrc = '����� ������� ����������' or skladdest = '����� ������� ����������')  
;

create or replace view v_itm_movenomencl_store as
select * from v_itm_movenomencl where skladsrc = '����� ������� ����������' and rashod <> 0
union
select * from v_itm_movenomencl where skladdest = '����� ������� ����������' and prihod <> 0
; 
--��� 04 ��/19/������/��� ���������� ��������

select * from v_itm_movenomencl_store where numdoc = 4879;
 


--5 ��� ������������� 6-��� ��������  27-������  4-���

select * from dv.v_movenomencl where doctype =27;
select * from v_itm_movenomencl where doctype =27;

select id_stock, id_doc, doctype, td, numdoc, stockdate, skladsrc, skladdest, basis, dt_beg, dt_otgr, project, prihod, rashod, comments 
from v_itm_movenomencl where id_nomencl = 16384;-- and stockdate >= :dt$d order by stockdate
select numdoc, stockdate, prihod, rashod from dv.v_movenomencl  where id_nomencl = 16384 order by stockdate desc; -- where id_nomencl = 16384;




select id_nomencl from dv.nomenclatura where name = '��.�_�������� ��� ������� 800'; --16364

select * from v_itm_movenomencl where /*doctype in (3,4) and*/ id_nomencl = 16364;

select * from
(
select 
  id_nomencl,
  max(id_nomencltype) as id_nomencltype,
  max(name),
  max(skladdest) as skladdest,
  max(skladsrc) as skladsrc,
  max(td) as td,
  max (numdoc) as numdoc,
  basis,
  sum(prihod) + sum(rashod) as qntb
from 
  v_itm_movenomencl
  where doctype in (3,4)
--  where basis = '�240550'  
group by id_nomencl, basis
)
--where id_nomencl = 16573
--and qntb <> 0
--and basis = '�240550'
where 
  id_nomencltype <> 0 and qntb <> 0
  and (skladdest = '����� ������� ���������' or skladsrc = '����� ������� ���������')
;  


create or replace view v_spl_nom_inbills as 
--���������� �� ��������� ��������� �� ������ ������������
select
  ib.id_inbill,
  ibs.id_ibspec,
  ibs.id_nomencl, 
  ib.inbilldate,   --����� ��������� ��� � ���
  ib.inbillnum,    --���� �������� ��������� ����  
  ib.name_org,     --������������ ����������
  
  ibs.name,        --������������ ������������
  ibs.artikul, 
  ibs.name_unit,        
  ibs.ibquantity,  --���������� �� ��������� (���������� ����������)
  ibs.fact_quantity,  --���������� (�� ���������)
  --ibs.ibprice,        --���� ������� (��� ����� ����������� ��� �������� ibquantity � fact_quantity) 
  ibs.ibsum,            --����� �������� ��� ��� (�� fact_quantity) 
  ibs.itogo,             --����� �������� � ��� (�� fact_quantity)
  round(ibs.ibsum / ibs.fact_quantity, 2) as price, --���� �������� ��� ���  
  round(ibs.itogo / ibs.fact_quantity, 2) as price_itogo --���� �������� c ���  
from
  dv.v_in_bills ib,
  dv.v_inbillspec_inner ibs
where
  ibs.id_inbill = ib.id_inbill
;    


create or replace view v_spl_nom_movebills as 
--���������� �� ��������� ����������� �� ������ ������������
select
  s.id_mbspec as id,
  h.id_movebill as id_doc,
  h.movebillnum as numdoc,
  h.movebilldate as dt,
  h.sourceskladname,
  h.destskladname,
  h.n as basis,
  h.id_docstate,
  h.is_delete,
  s.name,        
  s.artikul, 
  s.name_unit,        
  s.movebillquantity as quantity
from
  dv.v_move_bills h,
  dv.v_movebillspec s
where
  s.id_movebill = h.id_movebill
;

create or replace view v_spl_nom_offminuses as 
--���������� �� ����� �������� �� ������ ������������
select
  s.id_omspec as id,
  h.id_offminus as id_doc,
  h.offminusnum as numdoc,
  h.offminusdate as dt,
  h.skladname,
  h.basedoc as basis,
  h.id_docstate,
  h.comments,
  s.name,        
  --s.artikul, 
  s.name_unit,        
  s.omquantity as quantity
from
  dv.v_offminuses h,
  dv.v_offminusspec s
where
  s.id_offminus = h.id_offminus
;


create or replace view v_spl_nom_postpluses as 
--���������� �� ����� ������������� �� ������ ������������
select
  s.id_ppspec as id,
  h.id_postplus as id_doc,
  h.postplusnum as numdoc,
  h.postplusdate as dt,
  h.skladname,
  h.basedoc as basis,
  h.id_docstate,
  h.comments,
  s.name,        
  s.artikul, 
  s.name_unit,        
  s.ppquantity as quantity
from
  dv.v_postpluses h,
  dv.v_postplusspec s
where
  s.id_postplus = h.id_postplus
;

create or replace view v_spl_nom_acts as 
--���������� �� ��� �� ������ ������������
select
  s.id_act_spec_nomencl as id,
  h.id_act as id_doc,
  h.actnum as numdoc,
  h.actdate as dt,
  h.numzakaz || ' ' || h.zakazname as basis,
  h.id_docstate,
  h.comments,
  s.name,        
  s.artikul, 
  --s.name_unit,        
  s.countnomencl as quantity,
  s.skladname
from
  dv.v_acts h,
  dv.v_actspec_materials s
where
  s.id_act = h.id_act
;    
    
    
    





--------------------------------------------------------------------------------
-- ���� ������ ������ ������������ (������� ����������� � ������� �� ���������) �������� �� ���������
-- (�� ������ ������ ��� ��������)
--------------------------------------------------------------------------------
--������� ������������, ���������� ������� ���� �������������� �� ����� ��������� ��������
--������ ������� ��� ���� ��� �������� ���������
--�������� ������ ������, ������ ���, � ����������� �������� �������� ���, ��� ������� �������� ������ 
--�������� 0 = ��, 1 = �, ���������� �� ������ ������� �� ������ ��������, ��������� �������� � ref_production_areas
--������������ ��� ��� �� ����������!!! �� ��� �� ��������� ��� ���!
alter table spl_minremains_byareas add to_order_2 number(11,3);
create table spl_minremains_byareas (
  id number(11),                      --����, ���� ������������� �� ��� ��������� �������, ����� ��������� � id_nomencl  � ���
  name varchar2(400),                --������������ �������, ���� ��� �� ��������� ��� 
  qnt_0 number(11,3),                 --���� ����������
  qnt_min_0 number(11,3),             --����������� �������
  qnt_order_0 number(11,3),           --���������� � ������
  to_order_0 number(1) default 0,     --����� � �����
  qnt_1 number(11,3),                 --���� ����������
  qnt_min_1 number(11,3),             --����������� �������
  qnt_order_1 number(11,3),           --���������� � ������
  to_order_1 number(1) default 0,     --����� � �����
  qnt_2 number(11,3),                 --���� ����������
  qnt_min_2 number(11,3),             --����������� �������
  qnt_order_2 number(11,3),           --���������� � ������
  to_order_2 number(1) default 0,     --����� � �����
  constraint pk_spl_minremains_byareas primary key (id)
);

--������ ��� ������������ ��������� ����
create unique index idx_spl_minremains_byareas_n on spl_minremains_byareas(lower(name));

create sequence sq_spl_minremains_byareas increment by -1 nocache;

create or replace trigger trg_spl_minremains_byar_bi_r
  before insert on spl_minremains_byareas for each row
begin
  if :new.id is null then
    select sq_spl_minremains_byareas.nextval into :new.id from dual;
  end if;
end;
/
 
create or replace view v_spl_minremains_byareas as
select
  1 as is_itm,
  s.id,
  n.name,
  n.artikul,
  st0.qnt as qnt_0,
  s.qnt_min_0,
  s.qnt_order_0,
  s.to_order_0, 
  st1.qnt as qnt_1,
  s.qnt_min_1,
  s.qnt_order_1,
  s.to_order_1, 
  st2.qnt as qnt_2,
  s.qnt_min_2,
  s.qnt_order_2,
  s.to_order_2 
from
  dv.nomenclatura n,
  spl_minremains_byareas s,
  (select id_nomencl, sum(quantity) as qnt from dv.stock where doctype <> 27 and F_Itm_GetStockMode(id_sklad) in ('00', '02') group by id_nomencl) st0,
  (select id_nomencl, sum(quantity) as qnt from dv.stock where doctype <> 27 and F_Itm_GetStockMode(id_sklad) in ('10', '12') group by id_nomencl) st1,
  (select id_nomencl, sum(quantity) as qnt from dv.stock where doctype <> 27 and F_Itm_GetStockMode(id_sklad) in ('20', '22') group by id_nomencl) st2
where 
  n.id_nomencl = s.id
  and n.id_nomencl = st0.id_nomencl (+)
  and n.id_nomencl = st1.id_nomencl (+)
  and n.id_nomencl = st2.id_nomencl (+)
;

create or replace function F_Itm_GetStockMode (
--�� ���� ������� ���������� ��� � �������������� ������
--������ ������ - ����� �������� �� ����������� ref_production_areas (0-��, 1-�)
--������ ������ - ��� ������ (0-��, 1-������������, 2-��������) 
   IdSklad number
)
return number
is
  res varchar2(2);
  area number;
  skladmode number;
  skladnm varchar2(200);
begin
  area := 9;
  skladmode := 9;
  select skladname, nvl(brigada, 2) into skladnm, skladmode from dv.sklad where nvl(id_sklad, -1) = IdSklad;
  --������������ ������ ������ ������������ �� ������� �� ����������� ��������, ��� ������� ������
  select max(id) into area from ref_production_areas where nvl(substr(skladnm, -length(itm_suffix)), '---') = nvl(itm_suffix, '---');  
  return area || skladmode;   
end;
/

select skladname, F_Itm_GetStockMode(id_sklad) from dv.sklad;

--------------------------------------------------------------------------------
create or replace view v_itm_nom_qntbystosktypes_1 as
--���������� ������������ �� ������� �� ����� ������� � ���������
--���������� � ��������� �������� �� ������ �������� ������ ���, ������������ � ��������
 select
   id_nomencl, 
   sum(qnt) as qnt, 
   sum(qnt_sgp_0) as qnt_sgp_0, 
   sum(qnt_stock_0) as qnt_stock_0, 
   sum(qnt_mnf_0) as qnt_mnf_0, 
   sum(qnt_sgp_1) as qnt_sgp_1, 
   sum(qnt_stock_1) as qnt_stock_1, 
   sum(qnt_mnf_1) as qnt_mnf_1
   from ( 
   select 
     id_nomencl, 
     sk.id_sklad,
     max(sk.skladname),
     max(sk.brigada), 
     sum(quantity) as qnt,
     case when (max(sk.skladname) not like '% �')and(nvl(max(sk.brigada), -1) = 0) then sum(quantity) else 0 end as qnt_sgp_0,   
     case when (max(sk.skladname) not like '% �')and(nvl(max(sk.brigada), -1) = 1) then sum(quantity) else 0 end as qnt_stock_0,   
     case when (max(sk.skladname) not like '% �')and(nvl(max(sk.brigada), -1) = -1) then sum(quantity) else 0 end as qnt_mnf_0,   
     case when (max(sk.skladname) like '% �')and(nvl(max(sk.brigada), -1) = 0) then sum(quantity) else 0 end as qnt_sgp_1,   
     case when (max(sk.skladname) like '% �')and(nvl(max(sk.brigada), -1) = 1) then sum(quantity) else 0 end as qnt_stock_1,   
     case when (max(sk.skladname) like '% �')and(nvl(max(sk.brigada), -1) = -1) then sum(quantity) else 0 end as qnt_mnf_1   
   from 
     dv.stock st,
     dv.sklad sk
   where
     st.id_sklad = sk.id_sklad 
   group by id_nomencl, sk.id_sklad
   )
 group by id_nomencl  
;



--------------------------------------------------------------------------------
-- ���� ���������� ������ ������������ �������� �� �������� ����������
--------------------------------------------------------------------------------
--������� ������������ ��� �����
create table spl_minremains_i (
  id number(11),                    --���� ������������ �� ���
  qnt number(11,3),                 --���� ����������
  qnt_min number(11,3),             --����������� �������
  qnt_order number(11,3),           --���������� � ������
  to_order number(1) default 0,     --����� � �����
  constraint pk_spl_minremains_i primary key (id)
);

create or replace view v_spl_minremains_i as
select
  s.id,
  n.name,
  n.artikul,
  u.name_unit,
  st1.qnt as qnt,
  s.qnt_min,
  s.qnt_order,
  s.to_order 
from
  dv.nomenclatura n,
  dv.unit u,
  spl_minremains_i s,
  (select id_nomencl, sum(quantity) as qnt from dv.stock where doctype <> 27 and F_Itm_GetStockMode(id_sklad) in ('10', '12') group by id_nomencl) st1
where 
  n.id_nomencl = s.id
  and n.id_unit = u.id_unit (+)
  and n.id_nomencl = st1.id_nomencl (+)
;



--------------------------------------------------------------------------------
-- ���� ���������� ������ ������������ �������� �� �������� ���������
--------------------------------------------------------------------------------
--������� ������������ ��� �����
create table spl_minremains_dm (
  id number(11),                    --���� ������������ �� ���
  qnt number(11,3),                 --���� ����������
  qnt_min number(11,3),             --����������� �������
  qnt_order number(11,3),           --���������� � ������
  to_order number(1) default 0,     --����� � �����
  constraint pk_spl_minremains_dm primary key (id)
);

create or replace view v_spl_minremains_dm as
select
  s.id,
  n.name,
  n.artikul,
  u.name_unit,
  st1.qnt as qnt,
  s.qnt_min,
  s.qnt_order,
  s.to_order 
from
  dv.nomenclatura n,
  dv.unit u,
  spl_minremains_dm s,
  (select id_nomencl, sum(quantity) as qnt from dv.stock where doctype <> 27 and F_Itm_GetStockMode(id_sklad) in ('20', '22') group by id_nomencl) st1
where 
  n.id_nomencl = s.id
  and n.id_unit = u.id_unit (+)
  and n.id_nomencl = st1.id_nomencl (+)
;

create or replace view v_spl_need_curr as
select
--������� ����������� � ���������� (������ �� ������� ������� �� ������� � ������ � ����)
  m.name, 
  m.rezerv, 
  m.qnt, 
  m.qnt_onway,
  greatest(-nvl(m.rezerv,0) - nvl(m.qnt,0) - nvl(m.qnt_onway, 0), 0) as need_curr, 
  m.price_last, 
  round((greatest(-nvl(m.rezerv,0) - nvl(m.qnt,0) - nvl(m.qnt_onway,0), 0) * nvl(m.price_last, 0) / 1.2)) as sum_needcurr
from  
  v_nom_for_orders_in_prod n,
  v_spl_minremains m
where
  n.id_nomencl (+) = m.id
  and greatest(-nvl(m.rezerv,0) - nvl(m.qnt,0) - nvl(m.qnt_onway,0), 0) > 0
;

select * from v_spl_need_curr;


--������� ������� ��������� ���������� �� ���������
--drop table spl_history cascade constraints;
--������� ������� ��������� ���������� ������������, ������������ ��� ������������ ������ �� ���������
--����������� ������� �� ������ � �� ���������, ������, ���������� � ��������� � � ����, �������� ������,
--�����������, � ����� ���������� � ������ � ��������� ����� "� ������"
create table spl_history (
  dt date,
  state varchar2(30),              --����������� (��� ��� �����, ��� "�����")
  id number(11),
  supplierinfo varchar2(4000),
  qnt number,
  qnta0 number,
  qnta1 number,
  qnta2 number,
  qnt_in_processing number,
  qnt_pl number,
  qnt_pl1 number,
  qnt_pl2 number, 
  qnt_pl3 number,
  rezerv number,
  rezerva0 number, rezerva1 number, rezerva2 number,
  qnt_onway number,
  planned_need_days number(3),
  price_main number(11,2),
  price_check number(11,2),
  qnt_order number,
  to_order number(1),
  need number,
  need_p number,
  constraint pk_spl_history primary key (id, dt)
);  

select 
  v.id, h.planned_need_days, rn, v.supplierinfo, v.qnt, v.qnt_pl1, v.qnt_pl2, v.qnt_pl3, v.rezerv, v.rezerva0, v.rezerva1, v.rezerva2, v.qnt_onway, v.planned_need_days, v.price_main, v.price_check, v.qnt_order, v.to_order 
from 
  v_spl_minremains v,
  (select id, dt, row_number() over (partition by id order by dt desc) as rn from spl_history) l,
  spl_history h
where
  v.id = l.id (+)
  and h.id (+) = l.id and h.dt (+) = l.dt 
  and v.id = 13053  
  and l.rn = 1
; 


create or replace procedure P_Spl_Create_History( 
--��������� � ������� ��������� ������ �� ������������, �� ��� ��������, ������� � ������� ��� ������ ���, ���� ����� �������� �� ���� ������
--��� ���� ������������ ���� �� ����� ����� ���������� �� ������ ��� ��� � ������� ���������
--(���� ���� ����� AState, �� ��������� ��� ������� - ��� ������ ���������� ��� ������, ����� ����������� ������) 
  AState varchar2
) is
  FDate date;
  cursor c1 is
    select 
      v.id, v.supplierinfo, v.qnt, v.qnta0, v.qnta1, v.qnta2, v.qnt_in_processing, v.qnt_pl, v.qnt_pl1, v.qnt_pl2, v.qnt_pl3, 
      v.rezerv, v.rezerva0, v.rezerva1, v.rezerva2, v.qnt_onway, v.planned_need_days, v.price_main, v.price_check, v.qnt_order, v.to_order, v.need, v.need_p 
    from 
      v_spl_minremains v,
      (select id, dt, row_number() over (partition by id order by dt desc) as rn from spl_history) l,
      spl_history h
    where
      v.id = l.id (+)
      and l.rn (+) = 1
      and h.id (+) = l.id and h.dt (+) = l.dt
      and (
      state is not null or
      nvl(v.supplierinfo,0) <> nvl(h.supplierinfo,0) or nvl(v.qnt,0) <> nvl(h.qnt,0) or nvl(v.qnta0,0) <> nvl(h.qnta0,0) or nvl(v.qnta1,0) <> nvl(h.qnta1,0) or nvl(v.qnta2,0) <> nvl(h.qnta2,0) or
      nvl(v.qnt_in_processing,0) <> nvl(h.qnt_in_processing,0) or nvl(v.qnt_pl,0) <> nvl(h.qnt_pl,0) or 
      nvl(v.qnt_pl1,0) <> nvl(h.qnt_pl1,0) or nvl(v.qnt_pl2,0) <> nvl(h.qnt_pl2,0) or nvl(v.qnt_pl3,0) <> nvl(h.qnt_pl3,0) or 
      nvl(v.rezerv,0) <> nvl(h.rezerv,0) or nvl(v.rezerva0,0) <> nvl(h.rezerva0,0) or nvl(v.rezerva1,0) <> nvl(h.rezerva1,0) or nvl(v.rezerva2,0) <> nvl(h.rezerva2,0) or
      nvl(v.qnt_onway,0) <> nvl(h.qnt_onway,0) or nvl(v.planned_need_days,0) <> nvl(h.planned_need_days,0) or nvl(v.price_main,0) <> nvl(h.price_main,0) or
      nvl(v.price_check,0) <> nvl(h.price_check,0) or nvl(v.qnt_order,0) <> nvl(h.qnt_order,0) or nvl(v.to_order,0) <> nvl(h.to_order,0) or nvl(v.need,0) <> nvl(h.need,0) or nvl(v.need_p,0) <> nvl(h.need_p,0)
      )   
    ; 
begin
  select sysdate into FDate from dual;
  for v in c1 loop
    insert into spl_history
      (id, dt, state, supplierinfo, qnt, qnt_pl1, qnt_pl2, qnt_pl3, rezerv, rezerva0, rezerva1, rezerva2, qnt_onway, planned_need_days, price_main, price_check, qnt_order, to_order)
      values
      (v.id, FDate, AState, v.supplierinfo, v.qnt, v.qnt_pl1, v.qnt_pl2, v.qnt_pl3, v.rezerv, v.rezerva0, v.rezerva1, v.rezerva2, v.qnt_onway, v.planned_need_days, v.price_main, v.price_check, v.qnt_order, v.to_order)
      ;   
  end loop;
end;

begin
  P_Spl_Create_History();
--  P_Spl_Create_History('�����');
end;
/  

create or replace view v_spl_history as
select
--��� ������� ��
--���������� ��� �������� �� ������ ������������, �������� ������� �� ����, �� ����� ���� � ���������
--(��� ��� �������� ������ ������, � ������� ���� ��������� �� ���������� � ��������� �� ���� ����������� ����������� �� ������������)
  n.name,
  h.*
from 
  (select h.*, row_number() over (partition by id order by dt desc) as rn from spl_history h where h.dt < sys_context('context_uchet22','spl_history_date') ) h,
  dv.nomenclatura n 
where
  n.id_nomencl = h.id
  and rn = 1
;


create or replace view v_spl_history_contents as
select 
--��������� ������ ����� ���������� ������� ��
  to_char(s.dt, 'DD.MM.YYYY HH24:MI:SS')  || ' ' || s.state as caption
from
  (select distinct dt from spl_history) l, 
  (select dt, max(state) as state from spl_history group by dt) s
where 
  l.dt = s.dt
order by
  s.dt desc
;   

select * from v_spl_history_contents; 


select to_char(to_date('01.08.2025 02:33:04', 'DD.MM.YYYY HH24:MI:SS')) from dual;
select to_char(sysdate) from dual;


begin
  set_context_value('spl_history_date', to_date('01.08.2025', 'DD.MM.YYYY'));
end;
/
select * from v_spl_history where id = 13053; 


--================================================================================
select count(*) from v_spl_minremains;
create or replace view v_spl_minremains as
--��� ��� ������� ������������ ������ �� ��������� (����� �������) 
select
  n.id_nomencl as id,
  s1.*,
  s2.*,
  n.name as name,
  np.has_files,
  n.artikul as artikul,
  n.min_ostatok as min_ostatok,
  n.max_ostatok as max_ostatok,
  vn.qnt,
  vn.qnt0 as qnta0,
  vn.qnt1 as qnta1,
  vn.qnt2 as qnta2,
  --������ �� �������
  rz.rezerv,
  --�������� ������ �� 3 ������ ������, ������� �������,� �����
  poe.qnt1 as qnt_pl1, 
  poe.qnt2 as qnt_pl2, 
  poe.qnt3 as qnt_pl3,
  nullif(nvl(poe.qnt1,0)+nvl(poe.qnt2,0)+nvl(poe.qnt3,0),0)  as qnt_pl,
  rz.rezerva0,
  rz.rezerva1,
  rz.rezerva2,
  u.name_unit,
  re.min_ostatok as min_ostatok_new,
  re.qnt_order_opt as qnt_order_opt_new,
  re.e_min_ostatok,
  re.e_qnt_order_opt,
  re.e_qnt_order,
  nvl(np.prc_min_ost, p.prc_min_ost) as aprc_min_ost, --������� �������������� ��� ��� �������
  nvl(np.prc_qnt, p.prc_qnt) as aprc_qnt, --������� �������������� ��� ������������ ������� 
  nvl(np.prc_need_m, p.prc_need_m) as aprc_need_m, --������� �������������� ��� ��� ������ (� ������ �������)
  --(case when nvl(n.min_ostatok,0) > 0 then 100 - round(s1.qnt0 / n.min_ostatok * 100) else null end) as chprc,  --������
  (case when nvl(n.min_ostatok,0) > 0 then 100 - round(s1.qnt0 / n.min_ostatok * 100) else null end) as prc_min_ost,
  (case when vn.qnt is not null and nvl(s1.qnt0,0) > 0 then round(vn.qnt / s1.qnt0 * 100) else null end) as prc_qnt,
  (case when nvl(vn.qnt, 0) + nvl(rz.rezerv, 0) + nvl(niv.qnt, 0) - nvl(n.min_ostatok,0) < 0 then 
    abs(100 - round(n.min_ostatok / (nvl(vn.qnt, 0) + nvl(rz.rezerv, 0) + nvl(niv.qnt, 0) - nvl(n.min_ostatok,0))* 100)) else null end) as prc_need_m,
  nvl(ns.suppliers_cnt, 0) as suppliers_cnt,
  (case when ns.suppliers_cnt > 0 and ns.min_name_pos = chr(1) then '-' else null end) as no_namenom_supplier,  
  k.full_name as supplier,
--  (case when nvl(ns.suppliers_cnt, 0) > 1 then '� ' || suppliers_cnt else k.full_name end) as supplierinfo,
--  k.full_name as supplierinfo,
  k.name_org as supplierinfo,
  --���������� "� ����" (��������� ������� ����� ����� ����������� � ����� � ��������� ���������, ������ �� ������ �� ������� �� ������ 3-������� �����
  round(niv.qnt, 0) as qnt_onway,
  --����, ��� ���� �������� ������ ������ � ����
  niv.flag as onway_old,  
  --���������� "� ���������" 
  --��������� ��� ������� ���������� �� ���� ������ �� ��������� �� ������� ����������� �� ��������� ��������� � �� ������� ������ � ����, ��� �� ���� �������
--  round(nvl(nd.qnt, 0) - nvl(nib.qnt, 0) - nvl(niv.qnt, 0), 0) as qnt_in_processing,  
  --���������� "� ���������" 
  --��������� ��� ���������� �� ���� ������ �� ��������� �� ��������� (7) ����
  round(nvl(ndl.quantity, 0)) as qnt_in_processing,
  --����� � ���� ������� �� ���� �������� ������, �� ������� �� ������� ���������� �� ������� + � ����
  F_GetOrdersWhereNoQnt(n.id_nomencl, vn.qnt, niv.qnt) as ornumwoqnt,
  --���������� ����, �� ��������� ������� �� ������� ����������� ������� �������  
  np.planned_need_days,
  np.to_order,
  np.qnt_order,
  np.qnt_order_opt,
  np.tomin as tomin,
  --����������� (�������������, ���� ����� ����������) - �� ������ (�������������), �� � ���� � ���� ��� ��� �� ���� � ������
  round(nvl(vn.qnt, 0) + nvl(rz.rezerv, 0) + nvl(niv.qnt, 0), 1) as need,
  --����������� � ������ ��������� �������, ������������ � ��������� �� ����������� ���� ��������������� ������� planned_need_days
  --poe.qnt0 as need_p, 
  round(nvl(vn.qnt, 0) + nvl(rz.rezerv, 0) + nvl(niv.qnt, 0), 1) - nvl(poe.qnt0, 0) as need_p,
  --�����������, �� ��������� ��� ��� ������� (������� ��������, ����� ��������� �� ����)
  round(nvl(vn.qnt, 0) + nvl(rz.rezerv, 0) + nvl(niv.qnt, 0) - nvl(n.min_ostatok, 0), 1) as need_m,
  --����������� ����
  np.price_check,
  --���� ���������� ������� �� ������ ���������� �� ���� ������� ���������
  case when prc.price_main is null then null else round(prc.price_main, 2) end as price_main,
  --���� ���������� ������� �� ������������, ���������� �� ����������
  round(prclast.price_last,2) as price_last,
  --��������������� ����� ��� ��������� ����� � ������
  case when prc.price_main is null or np.qnt_order is null then null else round(prc.price_main * np.qnt_order) end as order_cost,
  --��������������� ����� ��� �������� �������
  case when prc.price_main is null or vn.qnt is null then null else round(prc.price_main * vn.qnt) end as qnt_cost,
  --����� �� ������������ "� ����"
  case when prc.price_main is null then null else round(prc.price_main * round(niv.qnt, 0)) end as onway_cost,
  --��������� �������� (���������, ����������, ����������..)
  np.id_category
from 
--������� ������������
dv.nomenclatura n
left outer join
--������ ����� �� �������� (����������� �� �� �� ������ ������������, � ���� �������� (������ ������)
(
select
  max(id_nomencl) as idn,
  sum(qnt0) as qnt0,
  sum(qnt1) as qnt1,
  sum(qnt2) as qnt2,
  sum(qnt3) as qnt3,
  sum(qnt4) as qnt4,
  sum(qnt5) as qnt5,
  sum(qnt6) as qnt6
from (  
--������ �� ��������� ����������� �� ������������
select
  n.id_nomencl as id_nomencl,
  sum(case when m.movebilldate >= trunc(sysdate) - p.d0 + 1 then nvl(s.itogoquantity,0) else 0 end) as qnt0, 
  sum(case when m.movebilldate >= trunc(sysdate) - p.d1 + 1 then nvl(s.itogoquantity,0) else 0 end) as qnt1, 
  sum(case when m.movebilldate >= trunc(sysdate) - p.d2 + 1 then nvl(s.itogoquantity,0) else 0 end) as qnt2, 
  sum(case when m.movebilldate >= trunc(sysdate) - p.d3 + 1 then nvl(s.itogoquantity,0) else 0 end) as qnt3, 
  sum(case when m.movebilldate >= trunc(sysdate) - p.d4 + 1 then nvl(s.itogoquantity,0) else 0 end) as qnt4, 
  sum(case when m.movebilldate >= trunc(sysdate) - p.d5 + 1 then nvl(s.itogoquantity,0) else 0 end) as qnt5, 
  sum(case when m.movebilldate >= trunc(sysdate) - p.d6 + 1 then nvl(s.itogoquantity,0) else 0 end) as qnt6 
from 
  dv.move_bill m,
  dv.move_bill_spec s,
  dv.nomenclatura n,
  spl_minremains_params p
where
  m.id_docstate = 3  --���������
  and m.id_skladdest in (842, 922, 982)  --�� ����� ������������ !!!
  and s.id_movebill(+) = m.id_movebill 
  and s.id_nomencl = n.id_nomencl(+)
  and n.id_nomencltype = 0
group by
  n.id_nomencl
union 
--������ �� ����� ��������
select
  n.id_nomencl as id_nomencl,
  sum(case when m.offminusdate >= trunc(sysdate) - p.d0 + 1 then nvl(s.omquantity,0) else 0 end) as qnt0, 
  sum(case when m.offminusdate >= trunc(sysdate) - p.d1 + 1 then nvl(s.omquantity,0) else 0 end) as qnt1, 
  sum(case when m.offminusdate >= trunc(sysdate) - p.d2 + 1 then nvl(s.omquantity,0) else 0 end) as qnt2, 
  sum(case when m.offminusdate >= trunc(sysdate) - p.d3 + 1 then nvl(s.omquantity,0) else 0 end) as qnt3, 
  sum(case when m.offminusdate >= trunc(sysdate) - p.d4 + 1 then nvl(s.omquantity,0) else 0 end) as qnt4, 
  sum(case when m.offminusdate >= trunc(sysdate) - p.d5 + 1 then nvl(s.omquantity,0) else 0 end) as qnt5, 
  sum(case when m.offminusdate >= trunc(sysdate) - p.d6 + 1 then nvl(s.omquantity,0) else 0 end) as qnt6 
from 
  dv.off_minus m,
  dv.off_minus_spec s,
  dv.nomenclatura n,
  spl_minremains_params p
where
  m.id_docstate = 3  --���������
  and s.id_offminus(+) = m.id_offminus 
  and s.id_nomencl = n.id_nomencl(+)
  and n.id_nomencltype = 0
  and 1 = 0          --2024-09-05  - ������ �� ����� �������� �������
group by
  n.id_nomencl
)  
group by
  id_nomencl
) s1 
on n.id_nomencl = s1.idn
left outer join
--������ �� �������� �� ��������� �������� (������ �� ������ ����� ����������!)
(select
  id_nomencl as idi,
  sum(qnt0) as qnti0,
  sum(qnt1) as qnti1,
  sum(qnt2) as qnti2,
  sum(qnt3) as qnti3,
  sum(qnt4) as qnti4,
  sum(qnt5) as qnti5,
  sum(qnt6) as qnti6
from (  
select
  n.id_nomencl as id_nomencl,
  (case when m.inbilldate >= trunc(sysdate) - p.d0 + 1 then nvl(s.ibquantity,0) else 0 end) as qnt0, 
  (case when m.inbilldate >= trunc(sysdate) - p.d1 + 1 then nvl(s.ibquantity,0) else 0 end) as qnt1, 
  (case when m.inbilldate >= trunc(sysdate) - p.d2 + 1 then nvl(s.ibquantity,0) else 0 end) as qnt2, 
  (case when m.inbilldate >= trunc(sysdate) - p.d3 + 1 then nvl(s.ibquantity,0) else 0 end) as qnt3, 
  (case when m.inbilldate >= trunc(sysdate) - p.d4 + 1 then nvl(s.ibquantity,0) else 0 end) as qnt4, 
  (case when m.inbilldate >= trunc(sysdate) - p.d5 + 1 then nvl(s.ibquantity,0) else 0 end) as qnt5, 
  (case when m.inbilldate >= trunc(sysdate) - p.d6 + 1 then nvl(s.ibquantity,0) else 0 end) as qnt6 
from 
  dv.in_bill m,
  dv.in_bill_spec s,
  dv.nomenclatura n,
  spl_minremains_params p
where
  m.id_docstate = 3  --���������
  and s.id_inbill(+) = m.id_inbill 
  and s.id_nomencl = n.id_nomencl(+)
  and n.id_nomencltype = 0
)  
group by
  id_nomencl
) s2
on n.id_nomencl = s2.idi
left outer join
/*
--����� ������� � ������� �� ���� ������� ����� ������ ������������ (� ����� ����)
--������������� ���������� ���������� ��� ������� (� ���� ������ id_sklad=null), ��� ������ ��� ������ ���������� � �� �������
--old
(select id_nomencl, 
  sum(decode(nvl(id_sklad, 0), 0, 0, 842, 0, 922, 0, qnt)) as qnt 
  from v_itm_ext_nomencl group by id_nomencl) vn
on n.id_nomencl = vn.id_nomencl 
*/
--������� ����� � �� ��������� (��� ������� ������������)
v_spl_qntonstocks_sum vn on n.id_nomencl = vn.id_nomencl 
left outer join
--������
--(select id_nomencl, sum(rashod) as rezerv, 0 as rezerv0, 0  as rezerv1 from dv.v_movenomencl where doctype = 27 group by id_nomencl) rz  --old
(select id_nomencl, sum(rezerv) as rezerv, sum(rezerv0) as rezerva0, sum(rezerv1) as rezerva1, sum(rezerv2) as rezerva2 from v_spl_rezerv_list group by id_nomencl) rz
on n.id_nomencl = rz.id_nomencl 
left outer join
--����������� �� �������� �������
planned_order_estimate3 poe
on n.id_nomencl = poe.id_nomencl 
left outer join
--������ �� ������������ "� ����"
v_spl_nom_onway_agg niv
on n.id_nomencl = niv.id_nomencl  
--left outer join
--v_spl_nom_on_inbill nib
--on n.id_nomencl = nib.id_nomencl  
left outer join
--������ �� ������� �� ���������
v_spl_nom_on_demand nd
on n.id_nomencl = nd.id_nomencl  
left outer join
--������ �� ������ �� ��������� �� ��������� ������������ �� ��� �� ��������� N ����
(select sum(quantity) as quantity, id_nomencl from v_spl_nomencl_on_demand where demand_date > sysdate - (select on_demand_days from spl_minremains_params) group by id_nomencl) ndl
on n.id_nomencl = ndl.id_nomencl  
left outer join
--���������� �����������; ����, ���� ������������, ��� ���� ���������� ���� ���������, ���� �������� ��� �� ����
(select id_nomencl, count(*) as suppliers_cnt, max(minpart) minpart_max, 
  decode(count(*), 1, max(id_supplier), max(decode(is_default, 1, id_supplier, null))) as id_supplier, 
  decode(count(*), 1, max(name_pos), max(decode(is_default, 1, name_pos, null))) as name_pos,
  min(nvl(name_pos, chr(1)))as min_name_pos 
  from dv.namenom_supplier ns group by id_nomencl
) ns
on n.id_nomencl = ns.id_nomencl  
left outer join
--temporary table � ������� �����
spl_remains_enter re
on n.id_nomencl = re.id  
left outer join
--������� �������������� ���������� ������������ � ���� ���������
spl_itm_nom_props np
on n.id_nomencl = np.id  
left outer join
--������������
dv.kontragent k
on ns.id_supplier = k.id_kontragent
left outer join
--������ �� ����� ���������� ������� ������, ��� ���������� ��� ������������� ����������
v_spl_nom_lastibprice2 prc
on n.id_nomencl = prc.id_nomencl and prc.id_kontragent = k.id_kontragent and prc.rn = 1
left outer join
--������ �� ����� ���������� ������� ������
v_spl_nom_lastibprice prclast
on n.id_nomencl = prclast.id_nomencl and prclast.rn = 1   
left outer join
--������� ���������
dv.unit u
on n.id_unit = u.id_unit 
inner join
--��������� ���� ������� (�� � ������ ������)
spl_minremains_params p
on 1 = 1 
where  
  n.id_nomencltype = 0  
--order by name asc  
;

select price_main , price_last from v_spl_minremains;







--------------------------------------------------------------------------------

--(select id_nomencl, max(rezerv) as rezerv, max(name_unit) as name_unit, sum(decode(nvl(id_sklad, 0), 0, 0, 842, 0, 922, 0, qnt)) as qnt from v_itm_ext_nomencl group by id_nomencl) vn

select rezerv from v_itm_ext_nomencl where id_nomencl = 14786;


select rezerv from v_spl_minremains where  id = 14786;
select sum(rashod) from dv.v_movenomencl where doctype = 27 and id_nomencl = 14786;
select /*stockdate, */ numdoc, project, dt_beg, dt_otgr, rashod from v_spl_rezerv_detail where id_nomencl = 14786 order by stockdate desc;
select sum(rashod) from v_spl_rezerv_detail where id_nomencl = 14786 order by stockdate desc;

select dv.getcountreserv(14786, 786) from dual; 


/*
--------------------------------------------------------------------------------
--��������� '3-������� �����' �� '4-������� �����' � DV.EXECUTEINBILL � ������������ � sp_schet,
--����� ��������� � ���� ��� � ���� �����
--------------------------------------------------------------------------------
����� ���� �����������, � �� � ������� ������ ������������ 3-������� ����� � ��� ��������
����� 2-�������, ��� ������� �������� ������� �� �����. �� � �� ������ �������� ����� ����,
��� ��� ��������� ����������.
!����� � ���������� ��� ���� ����������� ����� �������
*/

select * from dv.sp_schet where id_schet = 23890;
select * from dv.sp_schet where id_schet = 21767;
select * from dv.sp_schet where states = '3-�������';
select * from dv.sp_schet where states = '3-������� �����' and id_docstate <> 4;

begin
  for cur in (select id from v_spl_minremains) loop
    --P_SetSplDemandValue(cur.id, 9, 15);
  end loop; 
end;
/ 



select max(id_zakaz) from dv.nomenclatura_in_izdel;  --32375
select * from dv.nomenclatura_in_izdel where id_zakaz = 32375;

select * from v_spl_minremains where id in (select id_nomencl from dv.nomenclatura_in_izdel where id_nomizdel_parent_t is not null and id_zakaz = 32375);

/*
================================================================================
2025-02-14
v_spl_nom_onway_agg
*/



