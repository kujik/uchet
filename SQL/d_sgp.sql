/*
������� ������� �� ������ ������� ��������� ������� �� ���������� ���� ����������� �������.

�� ������� ����������� ������� ���������� �� �� ���, �� ������� � ����������� ����������� ����� ���� �� ��� (����������� ���������, ��� ��� �� ������� ����� ����)
������ ����� ������ ������������� ������ ��� ������� ����������� ��������, ���� ����� ������ ��� ��������������� �� ���� �� ����� ������� ����� ��������!
� ����������� ����� ���������� ���������� � ������������ �������������� ������� ���� � (id_organization = -1),
���������� ���������� ��������� �� ������� orders �� ���� ��������� ������������,
���������� �������� �� ��� ��������� ������������� ���� �������� ���������������� �������� �� ������� ������� ��� (order_stages � id_stage = 2), ��� ����� �������,
(�� ��� �� ����������� ������� � ������ � �������� "� ���", �� �� ��������� ������ ����������������, ��� ������� ����� ���� �� ������)
���������� ����������� ��������� �� ������� �������� � ��� order_stages/id_stage = 3, ��� ����� �������,
������� �������, ���� �������� ��������� ������/�������� ���� ������� ��������, � ������ �������
(�������� � �������� sgp_act_in_items, sgp_act_out_items (���������� �� ����� ��������� - � ��������� ������� ��� ������������� ������)
����������� ������� (��� ��������), �������� � ����� ������� ��� ��� ������� ����.
����� �������� ������� �� ��� (���� �� ������� ���������� �������, � ������ ����� ����� �����)
�����������. ��������� � ������� ���, � �� �������� � ���������. ��������� �������� ������� �������� ������������ �����������.

� ��������� ������� �������� ������ � ������� ����������� ������� ����� (���������� �� ������)

�� ���� ������ ������������ �������, � ����� �������� ������ ������ ������� (������������) � ����, ����������� � ������� sgp_params

��������������, �� ����� �� �����������, ��� ��� ����������� �������� �� ��������, ���������� � �����, ������� ����������� � ������������ � ������� �,
� ��� ��� ������� ������� �� ���, � � ��� ����������� �� ����������� ���������.
����� ��������������, ��� � ������ ����������� ������� ���� ���� ������ ��� ������������ � ���� ��� ������� (����� ����� ��������!)

��� ������� ������� �������, ���������� � ����������� ������ ���� �� ��� � ����������� ���������.
������ �� ������� � ������� ������������� �� ��������� ���� �� ������� �������, ��� ���� ������ � �������� �������������� �� ������������,
������ ��������� �� ��������� � ������������ -1 (������������) � ������� �������������� � ������� �������������.

�������� ����� �� ������� ������ ����� �� �� ����� �������� ������� �� ����� ������� ���� � v_order_items_all !!!

����� � ��� � �������� �� ����������� (����� ������� �� ����������� � ������� ������� ���, � �� ������ ���� � �������� �
----- ����� ���� ��������� � ������ �� ��� ������������������ �������� �� ������ ������ � ���???

������������� ������� ������� �� ������������ (�� or_std_items),  �� ������� ��������� ������ � order_items, � ������ ���� ������ ��� ������� (WB, ������...),
� ������ ���� �������� (������������/��������), ��� ����� �������� �������, ��� ����� �������� ���/����.

�� ���������, ��� ����� ���� ������� ��� � ������������� �������� � ����������� ��� �������������� 
(�� ���� ������ � ������ ��� ��������? ����������� ������� � �������������, ������������ � �������������, ������� ��� ������)

*/


alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;



/*
wb otgr 10
wb prod 9
*/

--���� ������������� �� ��� (�� ��������������)
create table sgp_act_in(
  id number(11),                       --���� ���������, �� �� �����
  id_format number(11),                --���� ������� ����
  id_user number(11),
  dt date,                             --����
  comm varchar2(400),                  --�����������
  constraint pk_sgp_act_in primary key (id),
  constraint fk_sgp_act_in_id_format foreign key (id_format) references or_format_estimates(id),
  constraint fk_sgp_act_in_id_user foreign key (id_user) references adm_users(id)
);

create sequence sq_sgp_act_in increment by 1 nocache;

create or replace trigger trg_sgp_act_in_bi_r
  before insert on sgp_act_in for each row
begin
  select sq_sgp_act_in.nextval into :new.id from dual;
end;
/

--������������ ���� �������������
alter table sgp_act_in_items add id_or_item number(11);
alter table sgp_act_in_items add constraint fk_sgp_act_in_items_or foreign key (id_or_item) references order_items(id) on delete cascade; 
create table sgp_act_in_items(
  id_act_in number(11),                --���� ����
  id_std_item number(11),              --���� ������������ ������� (��� ����������� �������)
  id_or_item number(11),               --���� ������� � ������ (��� ������������� �������)
  qnt number(15,3),                    --����������, ����������� �� ����� �� ����, ������ ������������
  constraint fk_sgp_act_in_items_act foreign key (id_act_in) references sgp_act_in(id) on delete cascade,
  constraint fk_sgp_act_in_items_std foreign key (id_std_item) references or_std_items(id),
  constraint fk_sgp_act_in_items_or foreign key (id_or_item) references order_items(id) on delete cascade
);

drop index idx_sgp_act_in_items;
--create unique index idx_sgp_act_in_items on sgp_act_in_items(id_std_item, id_act_in);



--------------------------------------------------------------------------------
--���� �������� � ��� (�� ��������������)
create table sgp_act_out(
  id number(11),                       --���� ���������, �� �� �����
  id_format number(11),                --���� ������� ����
  id_user number(11),
  dt date,                             --����
  comm varchar2(400),                  --�����������
  constraint pk_sgp_act_out primary key (id),
  constraint fk_sgp_act_out_id_format foreign key (id_format) references or_format_estimates(id),
  constraint fk_sgp_act_out_id_user foreign key (id_user) references adm_users(id)
);

create sequence sq_sgp_act_out increment by 1 nocache;

create or replace trigger trg_sgp_act_out_bi_r
  before insert on sgp_act_out for each row
begin
  select sq_sgp_act_out.nextval into :new.id from dual;
end;
/ 

--������������ ���� ��������
alter table sgp_act_out_items add id_or_item number(11);
alter table sgp_act_out_items add constraint fk_sgp_act_out_items_or foreign key (id_or_item) references order_items(id) on delete cascade; 
create table sgp_act_out_items(
  id_act_out number(11),                --���� ����
  id_std_item number(11),              --���� ������������ �������
  id_or_item number(11),               --���� ������� � ������ (��� ������������� �������)
  qnt number(15,3),                    --����������, ����������� �� ����� �� ����, ������ ������������
  constraint fk_sgp_act_out_items_act foreign key (id_act_out) references sgp_act_out(id) on delete cascade,
  constraint fk_sgp_act_out_items_std foreign key (id_std_item) references or_std_items(id),
  constraint fk_sgp_act_out_items_or foreign key (id_or_item) references order_items(id) on delete cascade
);

drop index idx_sgp_act_out_items;
--create unique index idx_sgp_act_out_items on sgp_act_out_items(id_std_item, id_act_out);

create or replace view v_sgp_revisions as
--������ ����� ������������� � �������� �� ���
select
  a.id,
  doctype, 
  id_format,
  dt, 
  f.name as formatname, 
  u.name as username
from
  (
  (select '��� �������������' as doctype, id_format, id, id_user, dt from sgp_act_in)
  union
  (select '��� ��������' as doctype, id_format, id, id_user, dt from sgp_act_out)
  ) a,
  v_sgp_sell_formats f, 
  adm_users u
where
  a.id_format = f.id (+)
  and a.id_user = u.id
;


--------------------------------------------------------------------------------
--�������������� ��������� ��� ���� ������� ��������� ���
--(������������ ������)
create table sgp_params(
  dt_beg date                      --���� ������� ��� ���� ������������ �������
);

--��������� ���� �������
update sgp_params set dt_beg = to_date('01.08.2024', 'DD.MM.YYYY');

--�������������� ��������� ��� ������� � ������� ��������� ���
create table sgp_items_add(
  id number(11),                       --���� ������������ �������
  qnt_min number,                      --����������� ���������� �� ������, ��� ��������
  constraint pk_sgp_items_add primary key (id),
  constraint fk_sgp_items_add foreign key (id) references or_std_items(id)
);

create or replace procedure P_SetSgpItemAdd(
--������������� �������� � �������� ��� ����� ������ � �����
--�����:
--1 - ����������� �������
  IdNomencl in number,
  PMode in number,
  PValue in number 
) is
  c number;
begin
  select count(1) into c from sgp_items_add where id = IdNomencl;
  if c = 0 then
    insert into sgp_items_add (id) values (IdNomencl);
  end if;
  if PMode = 1 then 
    update sgp_items_add set qnt_min = PValue where id = IdNomencl;
  end if;  
end;
/  

--------------------------------------------------------------------------------

create or replace view v_order_items_all as
--��������������� �������������, ���������� �� �������� ������, ������� �������
select
  i.id,                --���� �������
  i.id_std_item,       --���� ������������ ������� 
  o.id_format,         --���� �������
  o.id_organization,   --���� �����������, -1 == ������������
  o.dt_beg,            --���� ���������� ������
  o.dt_end,            --����������� ���� �������� ������ � �����
  o.dt_otgr,           --�������� ���� ��������
  s.name as itemname,  --������������ ����� (��� ��������)
  i.id_order,          --���� ������
  i.qnt,               --���������� �� ������ � ������  
  o.ornum || '_' || substr('000000' || i.pos, -3) as slash,   --� �����
  p.dt_beg as dt_base_beg                                     --���� ������� �� �������� ������ �� ���
from
  order_items i,
  orders o,
  or_std_items s,
  sgp_params p
where
  o.id = i.id_order
  and nvl(i.nstd, 0) <> 1
  and s.id = i.id_std_item
  and nvl(o.id_or_format_estimates, -1) <> 11  --��������� ������ �� �� ��
;  


create or replace view v_order_items__ as
--��������������� �������������, ���������� �� �������� ������, ����� ��������
select
  *
from
  v_order_items_all
  where id_order > 0
;      
/*

select
  i.id,                --���� �������
  i.id_std_item,       --���� ������������ ������� 
  o.id_format,         --���� �������
  o.id_organization,   --���� �����������, -1 == ������������
  o.dt_beg,            --���� ���������� ������
  o.dt_end,            --����������� ���� �������� ������ � �����
  o.dt_otgr,           --�������� ���� ��������
  s.name as itemname,  --������������ ����� (��� ��������)
  i.id_order,          --���� ������
  i.qnt,               --���������� �� ������ � ������  
  o.ornum || '_' || substr('000000' || i.pos, -3) as slash,   --� �����
  p.dt_beg as dt_base_beg                                     --���� ������� �� �������� ������ �� ���
from
  order_items i,
  orders o,
  or_std_items s,
  sgp_params p
where
  o.id = i.id_order
  and s.id = i.id_std_item
 -- and o.id > 0
;  
    
*/


/*
create or replace view v_sgp_sell_formats as
--������ �������� ����������� �������, ��� �� �������� ��������� ��������� ���
select
  fe.id,
  orf.name || ' (' ||  fe.name || ')' as name 
from
  --or_std_items si,
  or_format_estimates fe,
  or_formats orf
where
  not lower(fe.name) like '%������������%'
  and orf.id > 1
  and orf.id = fe.id_format
;
*/

create or replace view v_sgp_sell_formats as
--������ �������� ����������� �������, ��� �� �������� ��������� ��������� ���
--�������� �������, �� ������� ���� ���� �� ���� ����� "���� �� ���" � ��������
--���������������� �� ������� ��������, �� ��� ���� ����������, �� ��� �� ���������� �� ��� ��������
select
  fe.id,
  orf.name || ' (' ||  fe.name || ')' as name 
from
  or_format_estimates fe,
  or_formats orf,
  (select id_or_format_estimates, max(by_sgp) as by_sgp from or_std_items group by id_or_format_estimates) si
where
--  not lower(fe.name) like '%������������%'
  si.by_sgp = 1 and si.id_or_format_estimates = fe.id
  and orf.id > 1
  and orf.id = fe.id_format
;


select * from v_sgp_sell_formats;

create or replace view v_sgp_sell_items as
--������ ������� �� �������� �������� �� ������� �������, ��� �� �������� ��������� ��������� ���
select
  si.id,  --���� ������ ������������ �������, ������� � ����� �� ��������� � ������ ���� � or_std_items ����� ��� (��� �)
  max(si.name) as name,
  max(fe.id_format) as id_format,  --����������� ������ �������� (WB, ������...)
  si.id_or_format_estimates as id_format_est,  --����������� ������ ����� ��� �������� �� ��������
  max(orf.name) as orf_name, 
  max(fe.name) as orfe_name, 
  substr(max(oi.slash), 2, 3) as slash,   --�������� ����� (3 �������) �����
  max(si.price) as price                  --���� �� ������ ���������� ������� (�����������) 
from
  or_std_items si
  inner join or_format_estimates fe
  on fe.id = si.id_or_format_estimates
  inner join or_formats orf
  on orf.id = fe.id_format
  left outer join
  (select min(id) as id_order, id_or_format_estimates as id_format_est from orders where id < 0 group by id_or_format_estimates) o
  on o.id_format_est = fe.id
  left outer join
  v_order_items_all oi --!!!
  on oi.id_order = o.id_order and oi.itemname = si.name
where
  si.by_sgp = 1
group by 
  si.id_or_format_estimates, si.id    
;


--------------------------------------------------------------------------------
create or replace view v_sgp_by_psp_sell as
--����� ���������� ������� �� ����������� ���������, �����-���� ����������
select
  ssi.id,    
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(qnt) as qnt
    from 
      v_order_items__ oi
    where
      id_organization <> -1  --�� ������������
      and oi.dt_beg >= oi.dt_base_beg
    group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;


create or replace view v_sgp_by_psp_sell_list as
--����������� �� ������� �� ����������� ���������, �����-���� ����������
select
  ssi.id,    
  ssi.name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  inner join
  (select id_format, itemname, qnt, slash, id_order, dt_beg, dt_otgr, dt_end
    from 
      v_order_items__ oi
    where
      id_organization <> -1  --�� ������������
      and qnt > 0
      and dt_beg >= dt_base_beg
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;



create or replace view v_sgp_by_psp_prod as
--����� ���������� ������� �� ���������������� ���������, �����-���� ����������
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(qnt) as qnt
    from 
      v_order_items__
    where
      id_organization = -1  --������������
      and dt_beg >= dt_base_beg
    group by id_format, itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_by_psp_prod_list as
--����������� �� ������� �� ���������������� ���������, �����-���� ����������
select
  ssi.id,    
  ssi.name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  inner join
  (select id_format, itemname, qnt, slash, id_order, dt_beg, dt_otgr, dt_end
    from 
      v_order_items__
    where
      id_organization = -1  --������������
      and qnt > 0          --�������� ���-�� �� �����
      and dt_beg >= dt_base_beg
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

select * from v_sgp_by_psp_prod_list where id = 275;;
 
 
create or replace view v_sgp_shipped as
--����� ���������� ������� �� ����������� ���������, ����������� �� ������ ������� �������� � ���
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(ois.qnt) as qnt
    from 
      v_order_items__ oi,
      --����� ���������� ����������� �� ������� �����
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s, sgp_params p
        where s.id_stage = 3 and s.dt > p.dt_beg 
        group by id_order_item
      ) ois   
    where
      oi.id_organization <> -1  --�� ������������
      and ois.id_order_item (+) = oi.id
    group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_shipped_list as
--����������� �� �������� � ���
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  oi.dt, --���� �������� �� ����� �����
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  inner join
  (select id_format, itemname, ois.dt, ois.qnt, oi.slash, oi.id_order, oi.dt_beg, oi.dt_otgr, oi.dt_end
    from 
      v_order_items__ oi,
      --����� ���������� ����������� �� ������� �����
      (select id_order_item, qnt ,dt 
        from order_item_stages s, sgp_params p
        where s.id_stage = 3 and s.dt > p.dt_beg 
      ) ois   
    where
      oi.id_organization <> -1  --�� ������������
      and ois.id_order_item = oi.id
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;



create or replace view v_sgp_registered as
--����� ���������� ������� �� ���������������� ���������, �������������� �� ��� �� ������ ������� ������� � ���
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(ois.qnt) as qnt
    from 
      v_order_items__ oi,
      --����� ���������� �������� �� ��� �� ������� �����  
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s, sgp_params p
        where s.id_stage = 2 and s.dt > p.dt_beg 
        group by id_order_item
      ) ois   
    where
      oi.id_organization = -1  --������������
      and ois.id_order_item (+) = oi.id
    group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_registered_list as
--����������� �� ������� �� ���
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  oi.dt, --���� ������� �� ����� �����
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, ois.dt, ois.qnt, oi.slash, oi.id_order, oi.dt_beg, oi.dt_otgr, oi.dt_end
    from 
      v_order_items__ oi,
      --����� ���������� �������� �� ������� �����
      (select id_order_item, qnt ,dt 
        from order_item_stages s, sgp_params p
        where s.id_stage = 2 and s.dt > p.dt_beg 
      ) ois   
    where
      oi.id_organization = -1  --������������
      and oi.qnt <> 0
      and ois.id_order_item = oi.id
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

select * from v_sgp_registered_list where id = 275;
select * from v_sgp_registered_list where id = 275;

select * from v_order_item_stages1 where slash = '�240491_004';



create or replace view v_sgp_shipped_plan as
--�������� ��������
--(����� ���������������� �� ������� ���������� �� �������� ������� �� ������� ���������� ��� ����������� �� ������� �������)
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(nvl(oi.qnt, 0) - nvl(ois.qnt, 0)) as qnt
    from 
      v_order_items__ oi,
      --����� ���������� ����������� �� ������� �����
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s--, sgp_params p
        where s.id_stage = 3 --and s.dt > p.dt_beg
        group by id_order_item 
      ) ois   
    where
      oi.id_organization <> -1  --�� ������������
      and oi.dt_end is null                    --������� ����������� �������
      --and oi.dt_beg > oi.dt_base_beg               --������� �� ����
      and ois.id_order_item (+) = oi.id
      and oi.qnt <> 0
      and oi.qnt <> nvl(ois.qnt, 0)
      group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;


create or replace view v_sgp_shipped_plan_list as
--����������� �� �������� ��������
--(���������� �� �������� ����������� ������� �� ������� ���������� ��� ����������� �� ������� �������)
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  oi.qnt  
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, oi.qnt - nvl(ois.qnt, 0) as qnt, oi.slash, oi.id_order, oi.dt_beg, oi.dt_otgr, oi.dt_end
    from 
      v_order_items__ oi,
      --����� ���������� ����������� �� ������� �����
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s --, sgp_params p
        where s.id_stage = 3 --and s.dt > p.dt_beg
        group by id_order_item 
      ) ois   
    where
      oi.id_organization <> -1  --�� ������������
      and oi.dt_end is null                    --������� ����������� �������
      --and o.dt_beg > p.dt_beg               --������� �� ����
      and ois.id_order_item (+) = oi.id
      and oi.qnt <> 0
      and oi.qnt <> nvl(ois.qnt, 0)
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;


create or replace view v_sgp_in_prod as
--����������, ����������� � ������������
--(���������� �� �������� ���������������� ������� �� ������� ���������� ��� �������� �� ��� �� ������� �������)
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(oi.qnt - nvl(ois.qnt, 0)) as qnt
    from 
      v_order_items__ oi,
      --����� ���������� ������������� (�������� �� ���) �� ������� �����
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s--, sgp_params p
        where s.id_stage = 2 --and s.dt > p.dt_beg
        group by id_order_item 
      ) ois   
    where
      oi.id_organization = -1  --������������
      --and o.dt_beg > p.dt_beg               --������� �� ����
      and oi.dt_end is null                    --������� ����������� �������
      and ois.id_order_item (+) = oi.id
      and oi.qnt <> 0
      and oi.qnt <> nvl(ois.qnt, 0)
      group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_in_prod_list as
--����������� �� �������� ��������
--(���������� �� �������� ���������������� ������� �� ������� ���������� ��� �������� �� ��� �� ������� �������)
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  oi.qnt,
  oi.qnt_in_order  
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, oi.qnt - nvl(ois.qnt, 0) as qnt, oi.qnt as qnt_in_order, oi.slash, oi.id_order, oi.dt_beg, oi.dt_otgr, oi.dt_end
    from 
      v_order_items__ oi,
      --����� ���������� ������������� (�������� �� ���) �� ������� �����
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s --, sgp_params p
        where s.id_stage = 2 --and s.dt > p.dt_beg
        group by id_order_item 
      ) ois   
    where
      oi.id_organization = -1  --������������
      --and o.dt_beg > p.dt_beg               --������� �� ����
      and oi.dt_end is null                    --������� ����������� �������
      and ois.id_order_item (+) = oi.id
      and oi.qnt <> 0
      and oi.qnt <> nvl(ois.qnt, 0)
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_move_list as
--����������� �������� �� ������������
(select
  '���������������� �������' as doctype, id, name, id_order, slash, dt_beg, dt_otgr, dt_end, dt, qnt as qnt
from
  v_sgp_registered_list
)
union
(
select
  '����������� �������' as doctype, id, name, id_order, slash, dt_beg, dt_otgr, dt_end, dt, -qnt as qnt
from
  v_sgp_shipped_list
)  
union
(
select
  '��� �������������' as doctype, aoi.id_std_item as id, name, ao.id as id_order, to_char(ao.id) as slash, trunc(ao.dt) as dt_beg, null as dt_otgr, trunc(ao.dt) as dt_end, trunc(ao.dt) as dt, aoi.qnt as qnt
from
  sgp_act_in ao, sgp_act_in_items aoi, v_sgp_sell_items si
where
  aoi.id_act_in = ao.id and aoi.id_std_item = si.id 
)  
union
(
select
  '��� ��������' as doctype, aoi.id_std_item as id, name, ao.id as id_order, to_char(ao.id) as slash, trunc(ao.dt) as dt_beg, null as dt_otgr, trunc(ao.dt) as dt_end, trunc(ao.dt) as dt, aoi.qnt as qnt
from
  sgp_act_out ao, sgp_act_out_items aoi, v_sgp_sell_items si
where
  aoi.id_act_out = ao.id and aoi.id_std_item = si.id   
)  
--����������
union
(
select
  '��� �������������' as doctype, aoi.id_or_item as id, name, ao.id as id_order, to_char(ao.id) as slash, trunc(ao.dt) as dt_beg, null as dt_otgr, trunc(ao.dt) as dt_end, trunc(ao.dt) as dt, aoi.qnt as qnt
from
  sgp_act_in ao, sgp_act_in_items aoi, v_sgp2_order_items si
where
  aoi.id_act_in = ao.id and aoi.id_or_item = si.id 
)
union
(
select
  '��� ��������' as doctype, aoi.id_or_item as id, name, ao.id as id_order, to_char(ao.id) as slash, trunc(ao.dt) as dt_beg, null as dt_otgr, trunc(ao.dt) as dt_end, trunc(ao.dt) as dt, aoi.qnt as qnt
from
  sgp_act_out ao, sgp_act_out_items aoi, v_sgp2_order_items si
where
  aoi.id_act_out = ao.id and aoi.id_or_item = si.id   
)  
union
(
select
  '������' as doctype, si.id as id, name, si.id_order, slash, trunc(si.dt_beg) as dt_beg, null as dt_otgr, trunc(si.dt_end) as dt_end, trunc(ois.dt) as dt, ois.qnt as qnt
from
  v_sgp2_order_items si, order_item_stages ois  
where
  si.id = ois.id_order_item
  and ois.id_stage = 2
)  
union
(
select
  '��������' as doctype, si.id as id, name, si.id_order, slash, trunc(si.dt_beg) as dt_beg, null as dt_otgr, trunc(si.dt_end) as dt_end, trunc(ois.dt) as dt, -ois.qnt as qnt
from
  v_sgp2_order_items si, order_item_stages ois  
where
  si.id = ois.id_order_item
  and ois.id_stage = 3
)  
;

select
  '��������' as doctype, si.id as id, name, si.id_order, slash, trunc(si.dt_beg) as dt_beg, null as dt_otgr, trunc(si.dt_end) as dt_end, trunc(ois.dt) as dt, -ois.qnt as qnt
from
  v_sgp2_order_items si, order_item_stages ois  
where
  si.id = ois.id_order_item
  and ois.id_stage = 3
  and si.id = 92163
;  

select * from v_sgp_move_list where doctype = '��� �������������' and id_order = 34;



create or replace view v_sgp_items as
select
--�������� ������������� ��� ��������� ��� ��� ������������ ������� �������    
  ssi.id,
  ssi.id_format,
  ssi.id_format_est,
  ssi.orf_name,
  ssi.orfe_name,
  ssi.slash,
  ssi.name,
  ssi.price,
  
  ps.qnt as qnt_psp_sell,              --�������� �� ��� �����
  pp.qnt as qnt_psp_prod,              --�������� �� ��� ����� �� ���������������� ���������  
  sr.qnt as qnt_sgp_registered,        --������������ �� ��� ����� �� ����� ��� �� ���������������� ���������
  ss.qnt as qnt_shipped,               --��������� � ��� �� ��� ����� (�� �� �, �� �� � ��������� � ����������)
  
  sip.qnt as qnt_in_prod,              --���������� � ������������
  (sr.qnt + nvl(ai.qnt, 0) - ss.qnt + nvl(ao.qnt, 0)) as qnt,  --������� ���������� ������� �� ���
  ssp.qnt as qnt_to_shipped,           --���������� � ��������
  ia.qnt_min,                          --����������� ������� (�������� � �������)     
  --����������� (������� + � ������������ - � ��������)
  ((sr.qnt + nvl(ai.qnt, 0) - nvl(ss.qnt, 0) + nvl(ao.qnt, 0))) + (nvl(sip.qnt, 0)) - (nvl(ssp.qnt, 0)) as qnt_need,
  --����� �� ������ ����������� ��� �������, �� ������� ���������� �� ���  
  round((sr.qnt + nvl(ai.qnt, 0) - ss.qnt + nvl(ao.qnt, 0)) * nvl(ssi.price, 0), 2) as summ,
  --����� ����� �� ������� �� �� ��� �� ����� ���������������� ������� �� ����������������� ��������
  prc.sum as priceraw,
  (sr.qnt + nvl(ai.qnt, 0) - ss.qnt + nvl(ao.qnt, 0)) * prc.sum as sumraw
from
  v_sgp_sell_items ssi,   --������ �������, �� �������� ����
  v_sgp_by_psp_sell ps,   --�������� �� ����������� ���������
  v_sgp_by_psp_prod pp,   --�������� �� ���������������� �������� 
  v_sgp_registered sr,    --������� �� ��� �� ���������������� ��������� 
  v_sgp_shipped ss,       --��������� � ��� �� ����������� ��������� 
  v_sgp_shipped_plan ssp, --��������������� �������� 
  v_sgp_in_prod sip,      --������� � ������������
  (select id_std_item, sum(qnt) as qnt from sgp_act_in_items group by id_std_item) ai,     --���� �������������    
  (select id_std_item, sum(qnt) as qnt from sgp_act_out_items group by id_std_item) ao,    --���� ��������
  sgp_items_add ia,
  v_sgp_item_prices prc    
where
  ssi.name = ps.name and ssi.id = ps.id
  and ssi.name = pp.name and ssi.id = pp.id

  and ssi.name = sr.name and ssi.id = sr.id
  and ssi.name = ss.name and ssi.id = ss.id
  and ssi.name = ssp.name and ssi.id = ssp.id
  and ssi.name = sip.name and ssi.id = sip.id
  and ssi.id = ai.id_std_item (+)
  and ssi.id = ao.id_std_item (+)
  and ssi.id = ia.id (+)
  and prc.id (+) = ssi.id
  
--order by ssi.name  
;


select * from v_sgp_items where id = 482;
select * from sgp_act_in_items where id_std_item = 482;

select * from v_sgp_move_list where id = 482;

/*=============================================================================*/
      
   
/*
������� ������� �� ������ ������� ��������� ������������� �������.
�������.
����������� ������ ������� � ��������� "����������" � ��������, �� ���� ���������.
������ ����� �������� � �������� ��������� ���������� ��������, �.�. ������������ ������������ 
�� ������ ������, � �� �� ������������.
������� � ������ ������������ ��������� �� ������� �������/�������� ��� ������ �� ����� �����.
*/


create or replace view v_sgp2_order_items as
--��������������� �������������, ���������� �� �������� ������
select
  i.id,                --���� �������
  i.id_std_item,       --���� ������������ ������� 
  o.id_format,         --���� ������� ������
  s.id_or_format_estimates,  --������ ����� ������������� ������� (0 = ������������� �������)
  o.id_organization,   --���� �����������, -1 == ������������
  o.dt_beg,            --���� ���������� ������
  o.dt_end,            --����������� ���� �������� ������ � �����
  o.dt_otgr,           --�������� ���� ��������
  s.name as itemname,  --������������ ����� (��� ��������)
  s.name,
  i.id_order,          --���� ������
  i.qnt,               --���������� �� ������ � ������
  i.price,             --���� ������� �� ������  
  o.ornum || '_' || substr('000000' || i.pos, -3) as slash,   --� �����
  p.dt_beg as dt_base_beg                                     --���� ������� �� �������� ������ �� ���
from
  order_items i,
  orders o,
  or_std_items s,
  sgp_params p
where
  o.id = i.id_order
  and s.id = i.id_std_item
  and nvl(i.nstd, 0) = 1
;  


create or replace view v_sgp2 as
--����������� �� �������� ��
select 
  a.*,
 nvl(qnt_sgp_registered,0) - nvl(qnt_shipped,0) + nvl(qntplus,0) + nvl(qntminus,0) as qnt,
 round((nvl(qnt_sgp_registered,0) - nvl(qnt_shipped,0) + nvl(qntplus,0) + nvl(qntminus,0)) * nvl(price,0), 2) as sum  
from  
(select 
  max(id_std_item) as id_std_item,
  s.id_order_item as id, 
  max(oi.slash) as slash,
  max(oi.dt_beg) as dt_beg,
  max(oi.dt_otgr) as dt_otgr,
  max(oi.itemname) as name,
  max(oi.qnt) as qnt_psp,
  max(oi.qnt) - sum(qnt_sgp_registered) as qnt_in_prod,
  --����� � ������������, � �������� ����� ����� (������� * 0.4)
  round((max(oi.qnt) - sum(qnt_sgp_registered)) * max(oi.price) * 0.4, 2) as sum_in_prod,  
  sum(qnt_sgp_registered) as qnt_sgp_registered,
  sum(qnt_shipped) as qnt_shipped,
--  sum(qnt_sgp_registered) - sum(qnt_shipped) as qnt0,
  max(oi.price) as price
--  round((sum(qnt_sgp_registered) - sum(qnt_shipped)) * max(oi.price), 2) as sum  
from 
  v_sgp2_order_items oi,
  (select
    s.id_order_item, 
    decode(nvl(s.id_stage, 0), 2, qnt, 0) as qnt_sgp_registered,
    decode(nvl(s.id_stage, 0), 3, qnt, 0) as qnt_shipped
  from 
    order_item_stages s, 
    sgp_params p
  where 
    s.id_stage in (2, 3) 
  ) s
where
  s.id_order_item = oi.id (+)
  and oi.dt_beg > oi.dt_base_beg
  and oi.id_or_format_estimates = 0
group by s.id_order_item
) a,
(select id_or_item, sum(qnt) as qntplus from sgp_act_in_items group by id_or_item) ai,     --���� �������������    
(select id_or_item, sum(qnt) as qntminus from sgp_act_out_items group by id_or_item) ao    --���� ��������
where
  a.id = ai.id_or_item (+)
  and a.id = ao.id_or_item (+)
;

  
  
  
  
  
create or replace view v_sgp_item_prices as 
select
--������� ���������� ����� ������� �� ����������� ���������, ������ ��������������� �� ������� ����������������,
--�������, ���������� ���������, �� �������������,
--���� ������� � stock � ��������� �� ���� �������� �� �� ��� ������ ������������
  ssi.id,
  --max(ssi.name),
  --i.name,
  --ssi.orf_name,
  --ssi.orfe_name,
  --b.name,
  --n.name,
  --round(s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity), 2) as price,
  round(sum(ei.qnt1_itm * s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity))) as sum
from
  v_sgp_sell_items ssi,
  or_format_estimates a,
  or_std_items i,
  estimates e,
  estimate_items ei,
  bcad_nomencl b,
  dv.nomenclatura n,
  (select row_number() over (partition by doctype, id_nomencl order by stockdate desc) as rn, id_nomencl, quantity, summa, stockdate from dv.stock where doctype = 1) s 
where
  a.id = ssi.id_format 
  and ssi.id_format_est <> a.id 
  and i.name = ssi.name
  and e.id_std_item = i.id
  and ei.id_estimate = e.id
  and b.id = ei.id_name
  and n.name = b.name
  and s.id_nomencl = n.id_nomencl and s.rn = 1
group by 
  ssi.id  
;  

select * from dv.stock;
  
        dv.stock s
      on s.doctype = 1 and s.id_spec = ibs.id_ibspec
round(s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity), 2) as price_main
  
  (select id_format, itemname, sum(qnt) as qnt
    from 
      v_order_items__
    where
      id_organization = -1  --������������
      and dt_beg >= dt_base_beg
    group by id_format, itemname
  ) oi
  on oi.id_format = ssi. and oi.itemname = ssi.name   
;
  
  
  
  
  
  
  
  
  
  