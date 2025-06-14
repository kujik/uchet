alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';

/*
ИЗМЕНЕНИЯ В КОДЕ БД ИТМ
--!GM
2025-03-28
в расходных накладных разрешил выбор заказов П в качестве основания:
модификация DV.V_ZAKAZ_ALL_SCLAD_OB, убрал сравенение AND NOT z.numzakaz LIKE 'П%'


*/


create or replace procedure P_Itm_DelNomencl (
  IdNom in number,       --айди удаляемой номенклатуры
  ToDelete in number,    --если 1, то удаляем, иначе только выдаем информацию об использовании
  NomUsed out varchar2   --возвращаемая инфа по использованию номенклатуры
)  
is
  RecCount number;
begin
/*    if ToDelete = 1 then 
        delete from dv.nomencl_price_dynamics where id_nomencl=IdNom;
        delete from dv.bcad_nom where id_nomencl=IdNom;
        delete from dv.material_es where id_nomencl=IdNom;
        delete from dv.namenom_supplier where id_nomencl=IdNom;
        delete from dv.nomencl_units where id_nomencl=IdNom;
        delete from dv.nom_pictures where id_nomencl=IdNom;
        delete from dv.birki_spec where id_nomencl=IdNom;
        delete from dv.mnf_nom_in_job where id_nomencl=IdNom;
        delete from dv.mnf_spec_properties where id_nomencl=IdNom;
        --delete from nome_sets where id_nomencl=IdNom;  //комментировано в итм
    end if;*/
    NomUsed:=null;

    select count(1) into RecCount from dv.demand_supplier_spec  t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в заявках на снабжение' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.sp_schet_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в счетах поставщиков' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.price_list_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в прайс-листах' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.actcomp_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в акте комлектации на складе' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.act_spec_nomencl t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в акте выполненных работ' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.bcad_nom t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в сопоставлении с bCad' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.birki_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в бирках на складе' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.broke_bill_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в браке производства' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.in_bill_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в приходной накладной' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.inventory_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в инвентаризации' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.material_es t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в нормах материалов ТК' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.mnf_plan_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в плане производства' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.mnf_spec_properties t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в свойствах позиций спецификации' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.mnf_tech_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в спецификации' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.mnf_struct_element t where t.id_itemnomencl = IdNom; --!!!
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в составе спецификации' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.move_bill_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в накладной перемещения' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.namenom_supplier t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в справочнике наименования поставщиков' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.nomenclatura_in_izdel t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в составе заказа' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.nomencl_units t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в таблице взаимозаменяемости' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.nom_pictures t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в списке чертежей' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.off_minus_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в списании недостачи' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.out_bill_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в расходной накладной' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.post_plus_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в оприходовании излишков' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.prime_cost_temp t where t.id_nomencl = IdNom;
    if RecCount > 0 then
    null;
      --delete from prime_cost_temp;
    end if;

    select count(1) into RecCount from dv.return_mnf_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в возврате производства' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.rs_bill_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в возврате поставщику' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.rs_clbill_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в возврате клиента' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.stock t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в регистре складского учета' || chr('13') || chr('10');
    end if;

    select count(1) into RecCount from dv.zakaznomencl_spec t where t.id_nomencl = IdNom;
    if RecCount > 0 then
      NomUsed:= NomUsed || 'в складских заказах' || chr('13') || chr('10');
    end if;

end; 
/

--повторяющиеся наименования в номенклатуре
select name, cnt from (
 select n.name, count(1) as cnt
   from dv.nomenclatura n 
   where n.id_nomencltype=0
   group by n.name
)
where 
  cnt > 1
order by name   
; 

select name, cnt from (
 select n.name, count(1) as cnt
   from dv.nomenclatura n 
   where n.id_nomencltype>=0
   group by n.name
)
where 
  cnt > 1
order by name   
;

select artikul, cnt from (
 select n.artikul, count(1) as cnt
   from dv.nomenclatura n 
   where n.id_nomencltype>=0
   group by n.artikul
)
where 
  cnt > 1
order by artikul   
; 

select count(*) from dv.nomenclatura;




--create or replace view v_itm_ext_nomencl as
select 
   A.id_nomencl,
   A.skladname, 
   A.artikul,
   A.qnt, 
   A.name,
   A.name_unit,
   A.Rezerv,
   A.Broke, 
   A.r, 
   A.cat, 
   A.id_nomencltype, 
   decode(A.id_nomencltype, 0, 'материалы', 1, 'продукция') as nomencltype,
  (select groupname from dv.groups where id_group=A.r) as ras,
  (select groupname from dv.groups where id_group=A.cat) as catalog
  from 
    (select ss.skladname,n.id_nomencl,n.artikul, 
       B.qnt,n.name,n.id_group,u.name_unit,dv.getcountreserv(n.id_nomencl, n.id_unit) as rezerv, 
       n.Comments as broke,
       dv.GetRasdelCatalog(n.id_group,0) as r, dv.GetRasdelCatalog(n.id_group,1) as cat,
       --null as r, null as cat,
       n.id_nomencltype as id_nomencltype 
         from 
           dv.nomenclatura n, 
           dv.unit u, 
           dv.sklad ss,
           --((select id_sklad, skladname from dv.sklad)union(select null as id_sklad, '-' as skladname from dual)) ss,
           (select g1.id_group, g1.groupname from dv.groups g1
             connect by prior g1.id_group = g1.id_parentgroup
             start with g1.id_group = 1 or g1.id_group = 1
           ) g, 
           (select nvl(sum(quantity),0) as qnt, id_nomencl, id_sklad 
--           from stock s where s.doctype<>27 and s.id_sklad in (23,1163,823,1143) group by id_nomencl,s.id_sklad) B 
             from 
               dv.stock s 
             group by id_nomencl,s.id_sklad
           ) B 
         where 
           B.id_nomencl = n.id_nomencl 
           and ss.id_sklad = B.id_sklad
           and n.id_unit = u.id_unit 
           and n.id_group = g.id_group 
           and nvl(B.qnt, 0) >= 0
    ) a
  order by A.r, A.cat
;

select count(*) from v_itm_ext_nomencl;
select * from v_itm_ext_nomencl;
select count(*) from dv.nomenclatura; 
 



create or replace view v_itm_ext_nomencl as select  
--данные по номенклатуре ИТМ
--включают данные по всей номенклатуре, по каждой отдельные записи для
--каждого склада и для резерва
   a.skladname, 
   a.artikul,
   a.qnt, 
   a.name,
   a.name_unit,
   a.Rezerv,
   a.Broke, 
   a.r, 
   a.cat, 
   --a.rcnt,
   a.id_nomencl,
   a.id_nomencltype, 
   a.id_sklad,
   decode(A.id_nomencltype, 0, 'материалы', 1, 'продукция') as nomencltype,
  (select groupname from dv.groups where id_group=A.r) as ras,
  (select groupname from dv.groups where id_group=A.cat) as catalog
from (
  select 
    ss.skladname,
    n.id_nomencl,
    n.artikul, 
    b.qnt,
    n.name,
    n.id_group,
    u.name_unit,
    dv.getcountreserv(n.id_nomencl, n.id_unit) as rezerv, 
    n.Comments as broke,
    dv.GetRasdelCatalog(n.id_group,0) as r, dv.GetRasdelCatalog(n.id_group,1) as cat,
    n.id_nomencltype as id_nomencltype,
    b.rcnt,
    b.id_sklad 
  from  
    dv.nomenclatura n
    inner join dv.unit u on (n.id_unit = u.id_unit)
    inner join (select g1.id_group, g1.groupname from dv.groups g1
      connect by prior g1.id_group = g1.id_parentgroup
      start with g1.id_group = 1 or g1.id_group = 1
    ) g on (n.id_group = g.id_group)
    left outer join (
      select nvl(sum(quantity),0) as qnt, id_nomencl, id_sklad, count(*) as rcnt 
      from 
         dv.stock s 
         group by id_nomencl,s.id_sklad
      ) B on (B.id_nomencl = n.id_nomencl)
    left outer join dv.sklad ss on (ss.id_sklad = B.id_sklad)
    --where nvl(B.qnt, 0) >= 0  --это или резерв при id_sklad=null, или отмена проведения 
  ) a
;         

select count(*) from (select count(*) from v_itm_ext_nomencl_2 group by id_nomencl);
select * from dv.nomenclatura where name = 'ЛДСП/_16/Egger/Камень Металл антрацит F121 ST87';
select * from dv.nomenclatura where name = 'ЛДСП/_16/Egger/Камень Металл антрацит F121 ST87';


create or replace view v_itm_nomencl_1 as 
select
--справочник номенклатуры ИТМ в модуле Заказы
  n.id_nomencl,
  g.groupname,                --группа
  n.artikul,                  --артикул
  n.name,                     --наименование
  u.name_unit,                --ед.изм.
  k.name_org as supplier,     --наименование основного поставщика 
  prc.price_main,             --последняя цена из ПН по основному поставщику
  np.price_check,             --контрольная цена, из таблицы Учета
  np.has_files,               --к номенклатуре прикреплены файлы   
  ns.name_pos                 --номенклатура дефолтного (или единственного) поставщика  
from  
  dv.nomenclatura n
  left outer join dv.unit u on n.id_unit = u.id_unit
  left outer join dv.groups g on n.id_group = g.id_group
  left outer join
  --количество поставщиков; айди, если единственный, или айди дефолтного если несколько, если такового нет то нулл
  (select id_nomencl, count(*) as suppliers_cnt, max(minpart) minpart_max, 
    decode(count(*), 1, max(id_supplier), max(decode(is_default, 1, id_supplier, null))) as id_supplier, 
    decode(count(*), 1, max(name_pos), max(decode(is_default, 1, name_pos, null))) as name_pos,
    min(nvl(name_pos, chr(1)))as min_name_pos 
    from dv.namenom_supplier ns group by id_nomencl
  ) ns
  on n.id_nomencl = ns.id_nomencl  
  left outer join dv.kontragent k on ns.id_supplier = k.id_kontragent
  left outer join
    --данные по ценам последнего прихода товара, для дефолтного или единственного поставщика
    v_spl_nom_lastibprice2 prc
    on n.id_nomencl = prc.id_nomencl and prc.id_kontragent = k.id_kontragent and prc.rn = 1  
  left outer join spl_itm_nom_props np on n.id_nomencl = np.id
; 





select DV.CenaNomInPeriod(13054, '01.05.2024', '01.05.2024') from dual;
select DV.CenaNomBeforeDate(13054, '16.03.2024') from dual;
select DV.GET_COST_ZAKAZ(9440) from dual;

--так получаем сметные позиции по заказу
    select n.name
    from dv.nomenclatura_in_izdel niz,dv.nomenclatura n
    where
    niz.id_nomencl = n.id_nomencl and 
    niz.id_zakaz=8897
    and niz.id_nomizdel_parent_t is not null;

    select n.name, niz.count_nomencl, DV.CenaNomBeforeDate(n.id_nomencl, SysDate)
    from dv.nomenclatura_in_izdel niz,dv.nomenclatura n
    where
    niz.id_nomencl = n.id_nomencl and 
    niz.id_zakaz=8774
    and niz.id_nomizdel_parent_t is not null;
    
    --м24079 ид 8774

--так получим смету по одному изделию в заказе
    select 
      n.name,niz.count_nomencl
      ,DV.CenaNomBeforeDate(n.id_nomencl, SysDate) as price,
      round(DV.CenaNomBeforeDate(n.id_nomencl, SysDate) * niz.count_nomencl, 2) as sum0
    from dv.nomenclatura_in_izdel niz,dv.nomenclatura n
    where
    niz.id_nomencl = n.id_nomencl and 
    niz.id_nomizdel_parent_t = 48384;

--так получим список изделий в заказе    
    select n.name, niz.count_nomencl
    from dv.nomenclatura_in_izdel niz,dv.nomenclatura n
    where
    niz.id_nomencl = n.id_nomencl and 
    niz.id_zakaz=8774
    and niz.id_nomizdel_parent_t is null
    and niz.count_nomencl > 0
    ;
    

create or replace view v_order_primecost as 
select 
  round(sum(DV.CenaNomBeforeDate(n.id_nomencl, SysDate) * niz.count_nomencl), 2) as sum0,
  o.id,
  max(o.dt_end) as dt_end,
  max(o.cost) as cost
from
  orders o, 
  dv.nomenclatura_in_izdel niz,
  dv.nomenclatura n
where
  o.id_itm = niz.id_zakaz (+) 
  and niz.id_nomencl = n.id_nomencl 
  and niz.id_nomizdel_parent_t is not null
group by o.id  
;

create or replace view v_order_primecost_itm as 
select 
  round(sum(DV.CenaNomBeforeDate(niz.id_nomencl, SysDate) * niz.count_nomencl), 2) as sum0,
  id_zakaz
from
  dv.nomenclatura_in_izdel niz
where
  niz.id_nomizdel_parent_t is not null
group by id_zakaz  
;



select * from v_order_primecost where id = 1631;


create or replace view v_order_items_primecost as
select 
v.*,
  /*round((
    case when nvl(v.resale,0) = 0 then v.price * v.qnt else 0 end
  ) / ndsd, 2) as sum1_i,
  round((
    case when nvl(v.resale,0) = 1 then v.price * v.qnt else 0 end
  ) / ndsd, 2) as sum1_a*/
  round((
    case when nvl(v.resale,0) = 0 then v.price * v.qnt else 0 end
  ) / ndsd, 2) as sum1_i,
  round((
    case when nvl(v.resale,0) = 1 then v.price * v.qnt else 0 end
  ) / ndsd, 2) as sum1_a
from ( 
select 
  i.id,
  --max(i.itemname) as itemname,
  max(i.id_order) as id_order,
  max(o.dt_beg) as dt_beg,
  max(o.dt_end) as dt_end,
  max(o.dt_from_sgp) as dt_from_sgp,
  max(o.prefix) as prefix,
  round(sum(
    case when nvl(i.resale,0) = 0 then DV.CenaNomBeforeDate(n.id_nomencl, SysDate) * niz.count_nomencl else 0 end
  ), 2) as sum0_i,
  round(sum(
    case when nvl(i.resale,0) = 1 then DV.CenaNomBeforeDate(n.id_nomencl, SysDate) * niz.count_nomencl else 0 end
  ), 2) as sum0_a,
  max(ndsd) as ndsd,
  max(i.resale) as resale,
  max(i.price) as price,
  max(i.qnt) as qnt
from
  order_items i,
  orders o, 
  dv.nomenclatura_in_izdel niz,
  dv.nomenclatura n
where
  i.qnt > 0
  and o.id = i.id_order
  and niz.id_nomizdel_parent_t (+) = i.id_itm
  and niz.id_nomencl = n.id_nomencl 
--  and i.id_order = 1598
--  and i.id = 48373;
group by i.id
) v  
;

create or replace view v_order_items_primecost_itm as
select
  round(SUM(DV.CenaNomBeforeDate(niz.id_nomencl, SysDate) * niz.count_nomencl),2) as sum0,
  id_nomizdel_parent_t as id_itm
from
  dv.nomenclatura_in_izdel niz
where
  niz.count_nomencl > 0
--  and niz.id_nomizdel_parent_t (+) = i.id_itm
group by niz.id_nomizdel_parent_t
;




select * from v_order_items_primecost where id_order = 1433;
select sum(sum0_i) from v_order_items_primecost where id_order = 1433;
select * from v_order_primecost where id = 1631;
select * from v_order_primecost where dt_end is null;
select ornum from orders where id = 1433;

select * from v_order_items_primecost
  where id > 0 and prefix in ('О', 'Н') and dt_beg >= '01.04.2024' and dt_beg <= '30.04.2024'
order by dt_beg  
;

select sum(sum1_i), sum(sum1_a), sum(sum0_i), sum(sum0_a) from v_order_items_primecost
  where id > 0 and prefix in ('О', 'Н') and dt_beg >= '01.04.2024' and dt_beg <= '30.04.2024'
;


 


--insert into or_payments (dt, id_order, sum) select dt, id_order, sum from sn_order_payments;-- where dt ='14.05.2024'; 











--Н240411
--49251 изделие
--49252 обрешетка
--1613 - заказ 9474 itm
  select F_GetCotFromItm(0, 49252) from dual;


--------------------------------------------------------------------------------

--так получим смету по одному изделию в заказе
    select 
      n.name,niz.count_nomencl
      ,DV.CenaNomBeforeDate(n.id_nomencl, SysDate) as price,
      round(DV.CenaNomBeforeDate(n.id_nomencl, SysDate) * niz.count_nomencl, 2) as sum0
    from dv.nomenclatura_in_izdel niz,dv.nomenclatura n
    where
    niz.id_nomencl = n.id_nomencl and 
    niz.id_nomizdel_parent_t = 103582;    --48384;
    
select * from dv.nomenclatura_in_izdel niz where id_nomencl = 17087 and niz.id_nomizdel_parent_t is null order by id_nominizdel desc;
select * from dv.nomenclatura_in_izdel niz where id_nominizdel = 103582;
    

--так получим список изделий в заказе    
    select n.name, niz.count_nomencl
    from dv.nomenclatura_in_izdel niz,dv.nomenclatura n
    where
    niz.id_nomencl = n.id_nomencl and 
    niz.id_zakaz=8774
    and niz.id_nomizdel_parent_t is null
    and niz.count_nomencl > 0
    ;
    
    
--Н240411
--49251 изделие
--49252 обрешетка
--1613 - заказ 9474 itm


--or 1647 М240885 итм 9513 два изделия в смете
  select F_GetCostOrderItemsFromItm(1647, null) from dual;
  select F_GetCostOrderItemsFromItm(1647, 49611) from dual;
  
--  1634  два изделия, в сметах тоько материалы
  select F_GetCostOrderItemsFromItm(1634, null) from dual;
select F_GetCostOrderItemsFromItm(null, null) from dual;


      
drop  function F_GetCotFromItm;

create or replace function F_GetCostOrderItemsFromItm(
--найдем себестоимость всего заказа или изделия в заказе
--передаются айди в Учете
  IdOrder number,
  IdItem number
) 
return number
is
  IdNomenclatura number;
  IdZakaz number;
  IdIzdel number;
  IdParentIzdel number; 
  NameSpec varchar2(4000); 
  CountSpec number;
  IdSpec number;
  PSum number;
  Qid number;
  Qname varchar2(4000);
  Qtype number;
  Qqnt number;
  Q2id number;
  Q2name varchar2(4000);
  Q2type number;
  Q2qnt number;
  Q2price number;
  st1 varchar2(4000);
  st2 varchar2(4000);
  res number;
  cursor c_oritems is
    select
      o.id_itm, i.id_itm, i.pos, o.ornum
    from
      orders o,
      order_items i
    where
      i.id_order = o.id and
      (IdItem is null or i.id = IdItem)and
      o.id = IdOrder and
      i.qnt > 0
  --    (o.id = IdOrder or IdOrder is null)and
  --    ((i.id_order = IdOrder and IdItem is null)or(i.id = IdItem))
    ;
  cursor c_spec is
    select
      niz.id_nomencl, niz.count_nomencl, n.id_nomencltype, n.name
    from 
      dv.nomenclatura_in_izdel niz,
      dv.nomenclatura n
    where
      niz.id_nomencl = n.id_nomencl and
      niz.id_nominizdel = IdIzdel
    ;
  cursor c_spec_izd is
    select 
      n.id_nomencl, niz.count_nomencl, n.id_nomencltype ,n.name, Decode(n.id_nomencltype, 0, DV.CenaNomOld(n.id_nomencl, SysDate), 0)
    from 
      dv.nomenclatura_in_izdel niz,
      dv.nomenclatura n
    where
      niz.id_nomencl = n.id_nomencl and
      niz.id_nomizdel_parent_t = IdIzdel 
    ;
begin
  res := -1;
  PSum:= 0;
  if IdOrder is null and IdItem is null then 
    Return -1;
  end if;
  begin
    open c_oritems;
    loop
      fetch c_oritems into IdZakaz, IdIzdel, st1, st2;
      exit when c_oritems%notfound;
      dbms_output.put_line('Заказ ' || idzakaz || '-' || idizdel || '-' || st1 || '-' || st2);
      open c_spec;
      loop
        fetch c_spec into Qid, Qqnt, Qtype, Qname;
        exit when c_spec%notfound;
        dbms_output.put_line('Изделие ' || Qid || '-' || Qname || '-' || Qtype || '-' || Qqnt || '-' );
          open c_spec_izd;
          loop
            fetch c_spec_izd into Q2id, Q2qnt, Q2type, Q2name, Q2Price;
            exit when c_spec_izd%notfound;
            dbms_output.put_line('Сметная позиция ' || Q2id || '-' || Q2name || '-' || Q2type || '-' || Q2qnt || '-'  ||  Q2price || '-' );
            if Q2type = 1 then
              PSum:=PSum + Q2qnt * nvl(F_GetLastCostNomInIzdelFromItm(Q2id),0);
            else
              PSum:=PSum + Q2qnt * Q2price;
            end if;
          end loop;
          close c_spec_izd;
      end loop;
      close c_spec;
    end loop;
    close c_oritems;
  end;
  return Round(PSum, 2);
end;
/

-- id_nomencl = 17086;
--Шкаф табачный, 560х400х1480 мм, 56 SKU, без запасника, RAL 7035
select name from dv.nomenclatura where id_nomencl = 17086;

select * from dv.nomenclatura_in_izdel niz where id_nominizdel = 103582;


--находим все изделия (позиции заказов) являющиеся данной номенклатурой:  niz.id_nomencl
--вначале будут созданные последними
select n.id_nomencl, niz.id_nominizdel, n.name, niz.count_nomencl 
from dv.nomenclatura_in_izdel niz, dv.nomenclatura n 
where niz.id_nomencl = 16231 and niz.id_nomizdel_parent_t is null and niz.id_nomencl = n.id_nomencl and niz.count_nomencl > 0 
order by id_nominizdel desc
;

    select
      *
    from (
    select
      niz.id_nominizdel, niz.count_nomencl, n.name
    from 
      dv.nomenclatura_in_izdel niz,
      dv.nomenclatura n
    where
      niz.id_nomencl = 16231 and
      niz.id_nomizdel_parent_t is null and
      niz.id_nomencl = n.id_nomencl and
      niz.count_nomencl > 0
    order by id_nominizdel desc) 
    where rownum = 1
    ;


select n.name from dv.nomenclatura n where id_nomencl = 92622;

--выводим смету по этому изделию
--сопостовляем niz.id_nomizdel_parent_t вывод запроса ранее (id_nominizdel) 
select 
  n.name, n.id_nomencltype, niz.count_nomencl, DV.CenaNomOld(n.id_nomencl, SysDate) as price
from 
  dv.nomenclatura_in_izdel niz, dv.nomenclatura n
where
  niz.id_nomencl = n.id_nomencl and 
  niz.id_nomizdel_parent_t = 93741; --19712; --103581;    --48384;
    
--select n.id_nomencl, n.name from dv.nomencl n,

--!!!
--проверяем
--в номиниздел пустые, в учете смета есть
--КБ.П_К-т панелей Боковина ДСП-16 мм. на паллет 300х1000 мм            --id_nomencl = 16231
    
    
--17086
select F_GetLastCostNomInIzdelFromItm(93741) from dual;

select F_GetLastCostNomInIzdelFromItm(16231) from dual;    


create or replace function F_GetLastCostNomInIzdelFromItm(
--находит цену номенклатурной позиции, заведомо являющейся позицией изделия в 
--nomenclatura_in_izdel по пиереданному nomenclatura.id_nomencl
  IdNomencl number
)  
return number
is
  IdIzdel number;
  Qnt number;
  PSum number;
  Q2id number;
  Q2name varchar2(4000);
  Q2type number;
  Q2qnt number;
  Q2price number;
  st1 varchar2(4000);
  st2 varchar2(4000);
  res number;
  i number;
  cursor c_izd is
    select
      *
    from (
    select
      niz.id_nominizdel, niz.count_nomencl, n.name
    from 
      dv.nomenclatura_in_izdel niz,
      dv.nomenclatura n
    where
      niz.id_nomencl = IdNomencl and
      niz.id_nomizdel_parent_t is null and
      niz.id_nomencl = n.id_nomencl
      and nvl(niz.count_nomencl, 0) > 0
    order by id_nominizdel asc) 
    where rownum = 1
    ;
/*не понимаю. надо бы так. но в итоге пропуски (нулл) по полным заказам!!!
      and niz.count_nomencl > 0
    order by id_nominizdel desc) 
*/
  cursor c_spec_izd is
    select 
      n.id_nomencl, niz.count_nomencl, n.id_nomencltype ,n.name, Decode(n.id_nomencltype, 0, DV.CenaNomOld(n.id_nomencl, SysDate), 0)
    from 
      dv.nomenclatura_in_izdel niz,
      dv.nomenclatura n
    where
      niz.id_nomencl = n.id_nomencl and
      niz.id_nomizdel_parent_t = IdIzdel 
    ;
begin
  PSum:= -1;
  begin
    open c_izd;
    loop
      fetch c_izd into IdIzdel, Qnt, st1;
      exit when c_izd%notfound;
        dbms_output.put_line('Готовое изделие в сметной позиции ' || idizdel || ' - ' || st1 || ' qnt=' || Qnt);
        open c_spec_izd;
        loop
          fetch c_spec_izd into Q2id, Q2qnt, Q2type, Q2name, Q2Price;
          exit when c_spec_izd%notfound;
          dbms_output.put_line('Сметная позиция ' || Q2id || '-' || Q2name || '-' || Q2type || '-' || Q2qnt || '-'  ||  Q2price || '-' );
          PSum:=PSum + Q2qnt * Q2price;
        end loop;
        close c_spec_izd;
    end loop;
    close c_izd;
  end;
 dbms_output.put_line(PSum || st1);
  if Qnt = 0 then
    return round(PSum, 2);
  else 
    return round(PSum/Qnt, 2);
  end if;
end;
/

select F_GetLastCostNomNameFromItm('КБ.П_К-т панелей Боковина ДСП-16 мм. на паллет 300х1000 мм') from dual; 
select F_GetLastCostNomInIzdelFromItm(16231) from dual;    

create or replace function F_GetLastCostNomNameFromItm(
--вернем цену номенклатурной позиции, сразу встроенной функцией ИТМ, если это тип материал,
--или посчитаем своей функцией, если это изделие
  NomenclName varchar2
)  
return number
is
  IdNomencl number;
  IdNomenclType number;
  NomenclName2 varchar2(4000);
  PSum number;
begin
  PSum:= 0;
  begin
    select n.id_nomencl, n.id_nomencltype, n.name into IdNomencl, IdNomenclType, NomenclName2 from dv.nomenclatura n where name = NomenclName and rownum = 1;
    dbms_output.put_line(idnomencl || NomenclName2);
  exception
    when no_data_found then Return -1;
  end;
  if IdNomenclType = 0 then
    select round(DV.CenaNomOld(IdNomencl, SysDate),2) into PSum from dual;
  else
    select F_GetLastCostNomInIzdelFromItm(IdNomencl) into PSum from dual; 
  end if;
  return PSum;
end;
/



--так получим смету по одному изделию в заказе
    select 
      n.name,niz.count_nomencl
      ,DV.CenaNomBeforeDate(n.id_nomencl, SysDate) as price,
      round(DV.CenaNomBeforeDate(n.id_nomencl, SysDate) * niz.count_nomencl, 2) as sum0
    from dv.nomenclatura_in_izdel niz,dv.nomenclatura n
    where
    niz.id_nomencl = n.id_nomencl and 
    niz.id_nomizdel_parent_t = 238433;
    
select count(*) from dv.nomenclatura_in_izdel niz where niz.id_nomizdel_parent_t = 238480;
    
    
select * from dv.nomenclatura_in_izdel niz where id_nomencl = 17087 and niz.id_nomizdel_parent_t is null order by id_nominizdel desc;

--статусы заказа
select distinct id_status, dv.Get_Status_Name(ID_STATUS) from dv.zakaz;
/*
28	На выполнении
26	Готов к производству
32	Отгружен
30	Выполнен
22	Потенциальный/принятый
*/

create or replace view v_reservpos_completed_orders as 
--позиции резерва по отгруженным и выполненным заказам
select 
  s.*,
  z.numzakaz,
  z.id_status
  --,dv.Get_Status_Name(id_status) as status 
from 
  dv.stock s,
  dv.zakaz z
where 
  s.doctype = 27
  and s.id_doc = z.id_zakaz
  and z.id_status in (30, 32)
;

create or replace view v_reservpos_completed_orders2 as 
--позиции резерва по завершенным в Учете заказам
select 
  s.*,
  o.ornum,
  o.dt_end,
  z.id_status,
  n.name,
  '[' || o.ornum || ' ' || to_char(o.dt_end) || '] [' || n.name || '] [' || to_char(s.quantity) || ']' as info
from 
  orders o,
  dv.stock s,
  dv.zakaz z,
  dv.nomenclatura n
where 
  z.id_zakaz = o.id_itm 
  and o.id_itm is not null
  and o.dt_end is not null
  and s.doctype = 27
  and s.id_doc = z.id_zakaz
  and n.id_nomencl = s.id_nomencl
  --and z.id_status in (30, 32)  //!!!!
order by
  o.dt_end desc  
;


select * from v_reservpos_completed_orders2;
select * from stock where doctype = 27;

--заказы, которые завершены или отгружены, но по ним числятся позиции в резерве
select distinct numzakaz from v_reservpos_completed_orders order by numzakaz;

--удаление из резерва данных по заказам,  которые завершены или отгружены
--delete from dv.stock where id_stock in (select id_stock from v_reservpos_completed_orders);


create or replace procedure P_Itm_DelRezervForOrder(
--удаление резерва по заказу с переданным АйДи (в Учете!)
  AIdOrder in number
)  
is
  FIdZakaz number;
begin
  select id_itm into FIdZakaz from orders where id = AIdOrder;
  if FIdZakaz is not null then 
    delete from dv.stock s where s.doctype=27 and s.id_doc=FIdZakaz;
    update dv.nomenclatura_in_izdel niz set niz.rezerv_id=0 where niz.rezerv_id=1 and niz.id_zakaz=FIdZakaz;
  end if;
end;
/

create or replace procedure P_Itm_DelRezervForCompleted
is
--удаление резерва ИТМ по всем заказам, завершенным в Учете
begin
  for c1 in (select id from orders where dt_end is not null) loop
    P_Itm_DelRezervForOrder(c1.id);
  end loop;
end;
/

begin
--  P_Itm_DelRezervForCompleted;
end;
/  



--------------------------------------------------------------------------------
create or replace view v_itm_units as
--вью для справочника единици измерения ИТМ в Учете
select
  u.*,
  gm.name as groupname,
  --это наименование ед.изм. из bCad (справочника Учета)
  (case when bu.id is null then 0 else 1 end) as is_bcad_unit
from
  dv.unit u,
  dv.groups_measure gm,
  bcad_units bu
where
  u.id_measuregroup = gm.id_measuregroup (+)
  and u.name_unit = bu.name (+)  
;     

select * from v_itm_units;

create or replace view v_itm_suppliers as
--вью справочника поставщиков из ИТМ для Учета
select
  k.id_kontragent,
  k.name_org,
  k.full_name,
  k.inn,
  k.e_mail
from
  dv.kontragent k, 
  dv.kontragent_pri_kon_post kp
where
  k.id_kontragent = kp.id_kontragent (+) 
  and kp.id_type = 1   --поставщик 
;     

create or replace view v_itm_qntonstore as
--возвращает количество номенклатуры на складах,
--в том числе и на производстве (айди 842) и резерв (айди null)
select 
  id_nomencl,
  id_sklad,
  max(skladname) as skladname,
  sum(qnt) as qnt
from 
  v_itm_ext_nomencl n
group by 
  id_nomencl, id_sklad
;  


select 
--выведем список групп (только тех, у которых нет дочерних), у которых не задано или 
--пустое доп. свойтво "Префикс группы"
  g.groupname,
  pv.avalue
from 
  dv.groups g 
  left outer join dv.group_properties gp on g.id_group = gp.id_group 
  left outer join dv.properties p on p.prop_name='Префикс группы'
  left outer join dv.property_values pv on pv.id_prop_value =gp.id_prop_value
where
  pv.avalue is null
  and (select count(*) from dv.groups where id_parentgroup = g.id_group) = 0 
;

create or replace view v_itm_getnomenclpath as
select
--возвращает путь к группе, начиная с корневой 
id_group,
sys_connect_by_path(groupname, '|') as path
from 
  dv.groups
start with 
  id_group = 1
connect by prior
 id_group=id_parentgroup
;


select
--информация по зависшему резерву
  mn.stockdate, 
  mn.numdoc,
  mn.id_nomencl,
  n.id_nomencltype,
  n.name,
  o.ornum,
  o.dt_beg,
  o.dt_end,
  o.project,
  o.dt_otgr, 
  mn.rashod 
from 
  dv.v_movenomencl mn,
  orders o,
  dv.nomenclatura n
where 
  mn.doctype = 27
  and o.ornum (+) = mn.numdoc
  and mn.id_nomencl = n.id_nomencl
  and rashod <> 0
  and n.id_nomencltype = 0
  and o.dt_end is not null
order by dt_end  
;




create or replace view v_itm_acts_over_estimate as
select
--номенклатура, выданная по актам списания сверх смет
--(признак №3 в комменатарии)
  os.id_omspec as id,
  n.id_nomencl,
  n.name,
  os.omquantity as qnt,
  om.offminusdate as dt,
  om.offminusnum,
  om.comments
from
  dv.off_minus om,
  dv.off_minus_spec os,
  dv.nomenclatura n
where
  om.id_offminus = os.id_offminus
  and om.id_docstate = 3
  and om.comments like '№3%'
  and os.id_nomencl = n.id_nomencl
;

--лог действий пользователя в ИТМ
select * from dv.v_au_user_document;
select * from dv.lu_doing;
--select distinct(aud) from dv.lu_doing;
create or replace view v_itm_log as
  SELECT l.id_module,
         l.id_user,
         au.name,
         l.id,
         l.machine_windows,
         l.user_windows,
         d.comments,
         l.comments as commentsfull,
         d.act,
         d.aud,
         (CASE
            WHEN INSTR (l.comments, '/') > 0
            THEN
              SUBSTR (l.comments,
                      INSTR (l.comments, ':') + 2,
                      LENGTH (l.comments) - INSTR (l.comments, ':'))
            ELSE
              NULL
          END)                                AS AddInfo,
         l.data_time,
         (CASE
            WHEN INSTR (l.comments, '/') > 0
            THEN
              SUBSTR (l.comments,
                      INSTR (l.comments, '/') + 1,
                      INSTR (l.comments, ':') - INSTR (l.comments, '/') - 1)
            ELSE
              NULL
          END)                                AS id_doc,
         TRUNC (l.data_time)                  AS Log_dates,
         TO_CHAR (l.data_time, 'HH24.MI.SS')  AS Log_time
    FROM dv.lu_users l, dv.lu_doing d, dv.au_user au
   WHERE l.id_doing = d.id AND au.id = l.id_user AND l.id_user > -1;



--------------------------------------------------------------------------------
-- правим единицы измерения - приводим к тем, которые у нас в бкад
--------------------------------------------------------------------------------
select id_unit, name_unit from dv.unit order by name_unit;
select u.id_unit, max(u.name_unit) from dv.unit u, dv.nomenclatura n where n.id_unit = u.id_unit group by u.id_unit order by id_unit;
select max(u.id_unit), u.name_unit from dv.unit u, dv.nomenclatura n where n.id_unit = u.id_unit group by u.name_unit order by name_unit;
/*
1005,грамм  +++
7,кг.  +++
845,л
786,м                909
909,метр  +++
908,метр кв.  +++
785,м2               908
965,пог.м.           909 
885,упак.
6,шт.  +++

*/

--------------------------------------------------------------------------------
-- выгрузка поставщиков из ИТМ и Учета для их синхронизации
-- 12-03-2025

select 
  k.id_kontragent as "id",
  k.name_org as "краткое",
  k.full_name as "полное",
  s.name as "в учете",
  k.inn as "инн",
  a223.address as "юр. адрес",
  a224.address as "факт. адрес"
from 
  dv.kontragent k,
  (select name, upper(name) nm from ref_suppliers) s,
  dv.adress a223,
  dv.adress a224
where
  k.id_kontragent = a223.id_kontragent (+) and a223.id_addr_type (+) = 223   
  and k.id_kontragent = a224.id_kontragent (+) and a224.id_addr_type (+) = 224
  and upper(k.name_org) = s.nm (+)
;


select 
  k.id_kontragent as "id",
  s.name as "в учете"
from 
  (select id_kontragent, upper(name_org) nm from dv.kontragent) k,
  ref_suppliers s
where
  upper(s.name) = k.nm (+)
;    
    

select count(*) from dv.kontragent;

select count(*) from ref_suppliers;
--------------------------------------------------------------------------------

