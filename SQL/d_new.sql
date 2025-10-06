
--���������������� �������� ����������� �������
--drop table or_std_item_route cascade constraints;
create table or_std_item_route (
  id_or_std_item number(11),
  id_work_cell_type number(11),
  constraint pk_or_std_item_route primary key (id_or_std_item, id_work_cell_type),
  constraint fk_or_std_item_route_oi foreign key (id_or_std_item) references or_std_items(id) on delete cascade,
  constraint fk_or_std_item_route_wct foreign key (id_work_cell_type) references work_cell_types(id)
);   

delete from or_std_item_route;

--alter table or_std_items add route varchar2(400);
--alter table or_std_items drop column route;

--alter table or_format_estimates add prefix_prod varchar2(20);           --������� ��� ���, ��� ����������������� ��������
--alter table or_format_estimates add is_semiproduct number(1) default 0; --��� ������ ��������������
--alter table or_format_estimates drop column prefix_prod;           --������� ��� ���, ��� ����������������� ��������
--alter table or_format_estimates drop column is_semiproduct; --��� ������ ��������������
alter table or_format_estimates add type number(1) default 0; --ok
update or_formats set name = '�������������' where id = 1;
update or_format_estimates set name = '����� �������������' where id = 1;
--v_or_format_estimates


--create table or_std_items 
alter table or_std_items drop column type_of_semiproduct cascade constraints;
alter table or_std_items add type_of_semiproduct number(11); --��� �������������, ������������ ������ �� ��������
alter table or_std_items add barcode_c varchar2(100);
alter table or_std_items add constraint fk_or_std_items_sem foreign key (type_of_semiproduct) references work_cell_types(id);


alter table estimate_items add id_or_std_item number(11);
alter table estimate_items add  constraint fk_estimate_items_std foreign key (id_or_std_item) references or_std_items(id);
alter table estimate_items add contract number(1) default 0;
--������� id_bcad_nomencl � �������, ���������� �� ������ �� ��� ��, �� � �� ���� �������� ������



alter table bcad_groups add is_semiproduct number(1) default 0;




--------------------------------------------------------------------------------

--���������� ���� ������������ ������� � ������ �� �������� ���������� ������������
--������ �������� ����� 4 ���
select
  e.id_or_std_item,
  e.name,
  o.fullname
from
  v_estimate e,
  v_or_std_items o
where
  e.name = o.FULLNAME    
;

--������ ������ ������ ���.���. � ��� v_estimate � ����������� ����� ���.���. � �����������!!!
--���������� � ������ ���� ����������� ������� � ������ ������� �������
update estimate_items t1
set t1.id_or_std_item = (
    select t2.id
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname
)
,t1.id_group = 104
--,t1.id_name = null
where exists (
    select 1
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname and type <> 2
);

update estimate_items t1
set t1.id_or_std_item = (
    select t2.id
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname
)
,t1.id_group = 2
--,t1.id_name = null
where exists (
    select 1
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname and type = 2
);





select * from estimate_items where id_or_std_item is not null;

/*
--��������� � ������ ������ ��� �������-��������������
--update estimate_items t1
--set t1.id_group = 2 
;
select * from estimate_items t1
where exists (
select t2.fullname  
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname and nvl(t2.is_semiproduct, 0) = 1
);

select id, is_semiproduct from v_or_std_items where fullname = :fullname$s;

select *    
    from v_or_std_items t2, bcad_nomencl b
    where t1.id_name = b.id and b.name = t2.fullname and nvl(t2.is_semiproduct, 0) = 1;\
*/    

--END ���������� ����

select * from v_or_std_items where nvl(is_semiproduct, 0) = 1;
select * from estimate_items where id_group = 2;
--------------------------------------------------------------------------------
/*
�� ���������� ������� ��� ������� � t.code || ', ', ���� ��� ������, �� ��� ���������� ����� ������ ������� � ������ ���������� ����� �������:
��,�� -> ���
    ,rtrim(
    (select 
       regexp_replace(listagg(t.code || ', ') within group (order by t.pos), '([^\,]+)(\,\1)+', '\1' )
       from ((select i.id_or_std_item, t.code, t.pos from work_cell_types t, or_std_item_route i where t.id = i.id_work_cell_type)) t
       where id_or_std_item = i.id
    ), ', ') as route


--v_or_std_items
--D ConvertNewOrStdItemRoutes
--F_TestEstimateItem_New

*/


select 
  max(oi.slash),
  max(oi.fullitemname),
  count(ei.id)
from
  v_order_items oi,
  estimates e,
  estimate_items ei
  --bcad_nomencl n1
  --bcad_nomencl n2
where
  oi.id_organization <> -1
  and nvl(oi.std, 0) = 1
  and e.id_order_item = oi.id
  and ei.id_estimate = e.id
group by
  ei.id_estimate
having      
  count(ei.id) > 1  
  ;
  --and count(
  
select * from or_format_estimates where id_format = 1; 
select * from or_std_items where id_or_format_estimates =1; --=�/�





--------------------------------------------------------------------------------

/*
--��������� ���������� �������� �� ��� � ������� ������� �� ��������� ������� ������� �� ���
merge into order_items t1
using (select id_order_item, sum(qnt2) as qnt from v_order_item_stages1 group by id_order_item) t2
on (t1.id = t2.id_order_item)
when matched then
    update set t1.qnt_to_sgp = t2.qnt;
    
update order_items set qnt_to_sgp = 0 where qnt_to_sgp is null;
*/

drop table or_planned_stages cascade constraints;
create table or_planned_stages (
  id number(11),
  dt_estimate_p date,
  dt_kns_p date,
  dt_thn_p date,
  dt_machines_p date,
  dt_machines date,
  dt_assembly_p date,
  dt_assembly date,
  dt_painting_p date,
  dt_painting date,
  dt_final_assembly_p date,
  dt_final_assembly date,
  dt_otk_p date,
  dt_sgp_p date,
  dt_packaging_p date,
  dt_packaging date,
  constraint pk_or_planned_stages primary key (id),
  constraint fk_or_planned_stages_oi foreign key (id) references order_items(id) on delete cascade
);   
    
create or replace procedure p_or_planned_stages_set (
  AId number,
  AMode number,
  AEst date,
  AKns date,
  AThn date,
  AMachines date,
  AAssembly date,
  APainting date,
  AFinalAssembly date,
  AOtk date,
  ASgp date,
  APackaging date
) is
  i number;
begin
  if AMode = -1 then
    delete from or_planned_stages where id = AId;
    return;
  end if;
  select count(*) into i from or_planned_stages where id = AId;
  if i = 0 then
    insert into or_planned_stages (id) values (AId);
  end if;
  update or_planned_stages set
    dt_estimate_p = AEst,
    dt_kns_p = AKns,
    dt_thn_p = AThn,
    dt_machines_p = AMachines,
    dt_assembly_p = AAssembly,
    dt_painting_p = APainting,
    dt_final_assembly_p = AFinalAssembly,
    dt_otk_p = AOtk,
    dt_sgp_p = ASgp,
    dt_packaging_p = APackaging
   where id = AId; 
null;
end;
/
  



