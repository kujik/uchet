select last_Active_time, sql_text, sql_fulltext from v$sql
where  lower(sql_text) like 
'%demand%'
--'%temp_demsvod_spec%'
order by last_active_time desc
; 



select * from v$sql where id_session =1111;


select s.* from demand_supplier_spec s, demand_supplier d where s.id_demand_supplier = d.id_demand_supplier and d.num_demand = 14526;  
select * from demand_supplier where num_demand = 14526;

  SELECT *
    FROM v_demandsupplierspec4
   WHERE id_demand_supplier = (select id_demand_supplier from demand_supplier where num_demand = '14525') 
ORDER BY name
;


   SELECT ds.id_demand_supplier
             AS id_demand_supplier_spec,
           ds.id_demand_supplier,
           (CASE
              WHEN (getfieldssp (ds.id_nomencl, d.id_supplier, 'ARTIKUL_SP')
                      IS NOT NULL)
              THEN
                getfieldssp (ds.id_nomencl, d.id_supplier, 'ARTIKUL_SP')
              ELSE
                getfieldsnomencl (ds.id_nomencl, 'ARTIKUL')
            END)
             AS artikul,
           (CASE
              WHEN (getfieldssp (ds.id_nomencl, d.id_supplier, 'NAME_POS')
                      IS NOT NULL)
              THEN
                getfieldssp (ds.id_nomencl, d.id_supplier, 'NAME_POS')
              ELSE
                getfieldsnomencl (ds.id_nomencl, 'NAME')
            END)
             AS NAME,
           NVL (
             TO_NUMBER (getfieldssp (ds.id_nomencl, d.id_supplier, 'PRICE_SP')),
             0)
             AS PRICE,
           ds.id_nomencl,
           NULL
             AS height,
           NULL
             AS width,
           NULL
             AS avalues,
           (CASE
              WHEN (getfieldssp (ds.id_nomencl, d.id_supplier, 'ID_BASE_UNIT')
                      IS NOT NULL)
              THEN
                TO_NUMBER (
                  getfieldssp (ds.id_nomencl, d.id_supplier, 'ID_BASE_UNIT'))
              ELSE
                TO_NUMBER (getfieldsnomencl (ds.id_nomencl, 'ID_UNIT'))
            END)
             AS id_unit,
           getzayavkizakaz (ds.id_nomencl, ds.id_demand_supplier)
             AS NumZakaz,
           getunitname (
             (CASE
                WHEN (getfieldssp (ds.id_nomencl,
                                   d.id_supplier,
                                   'ID_BASE_UNIT')
                        IS NOT NULL)
                THEN
                  getfieldssp (ds.id_nomencl, d.id_supplier, 'ID_BASE_UNIT')
                ELSE
                  getfieldsnomencl (ds.id_nomencl, 'ID_UNIT')
              END))
             AS name_unit,
           ROUND (
               SUM (ds.quantity)
             / NVL (1,
             
                 (SELECT u.coefficient
                    FROM unit u
                   WHERE u.id_unit =
                         getfieldssp (ds.id_nomencl,
                                      d.id_supplier,
                                      'ID_BASE_UNIT')),
                 1),
             getunitpression (ds.id_nomencl))
             AS QUANTITY,
           getCountNomenclkratnSpunit (ds.id_nomencl,
                                       SUM (ds.quantity),
                                       d.id_supplier)
             AS cZakaz,
           ROUND (
               NVL (
                 TO_NUMBER (
                   getfieldssp (ds.id_nomencl, d.id_supplier, 'PRICE_SP')),
                 0)
             * getCountNomenclkratnSpunit (ds.id_nomencl,
                                           SUM (ds.quantity),
                                           d.id_supplier),
             2)
             AS demSUM
      FROM demand_supplier_spec ds, demand_supplier d
     WHERE d.id_demand_supplier = ds.id_demand_supplier
and d.id_demand_supplier = 2532333     
  GROUP BY ds.price,
           ds.id_nomencl,
           ds.id_unit,
           ds.id_demand_supplier,
           d.id_supplier
  ;


select * from demand_supplier d where d.id_demand_supplier = 2532333;

--id_demand_supplier = 2532333 
--id_unit 1065
--id_nomencl 35785
--name_unit т.
--id_supplier 6172

--select getfieldssp (ds.id_nomencl, d.id_supplier, 'ID_BASE_UNIT') from dual;
select getfieldssp (35785, 6172, 'ID_BASE_UNIT') from dual;

                 SELECT u.coefficient
                    FROM unit u
                   WHERE u.id_unit = 1065;


select ds.id_nomencl, ds.id_unit, nvl(tt3.min_ostatok, 0) as MinOstatok,  nvl(round(SP.C, u.pression), 0) as NomInWay,  
sum(nvl(round(ds.quantity, u.pression), 0)) as OSTATOK, FreeNomenclAll(ds.id_nomencl) as CountSklad  
from DEMAND_SPEC ds, NOMENCLATURA tt3, demand d, unit u, (select sum(sps.quantity) as C,sps.id_nomencl N from  sp_schet_spec sps, sp_schet sp 
where  sps.id_sp_schet = sp.id_schet  and (sp.states='2-Оплачен' or sp.states='1-Поставка в долг') group by sps.id_nomencl) SP 
where ds.quantity > 0 and u.id_unit=ds.id_unit and tt3.ID_NOMENCL=ds.ID_NOMENCL and SP.N(+)=ds.id_nomencl and ds.id_demand=d.id_demand and d.id_docstate=3  
group by ds.id_nomencl, ds.id_unit, nvl(tt3.min_ostatok, 0), nvl(round(SP.C, u.pression), 0)
;

select t.value , t."ROWID"  from sys_table_konstant t where  t.name='DEMAND_KRATN';
update sys_table_konstant set value = 0.00001 where name='DEMAND_KRATN';   

--GetCountNomenclKratnSP


--id_nomencl = 35785;  suppl 6172
select GetCountNomenclKratnSP(35785, 1011+25, 6172) from dual;
--GetCountNomenclKratnSP - возвращает количество в наших единицах такое, чтобы кол-во в единицах поставщика было достаточным и целым
--DEMAND_KRATN <> 1  выключит эту подгонку при формировании заявки, но при печати как минимум она останется, полезет 1 тонна



--------------------------------------------------------------------------------
--ЗАДВОЕНИЕ НОМЕНКЛАТУРЫ В РЕЗЕРВЕ

select id_doc, id_nomencl
from stock s
where s.doctype=27
  --and s.id_doc=idZakaz
  --and s.Id_Nomencl=i.id_nomencl
  and s.num_party='pkg_reserve'
group by id_doc, id_nomencl
having count(id_doc) > 1;

select name from nomenclatura where id_nomencl = 37014;
--СД.П_Стол базовый 1100х600х800 Новый

select * 
from stock s
where s.doctype=27 and id_doc = 26442 and id_nomencl = 37014;

select * from stock s where s.doctype=27 and id_nomencl = 22602;


delete from stock where id_stock = 1722674;
--------------------------------------------------------------------------------



