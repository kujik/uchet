CREATE OR REPLACE PROCEDURE DV.EXECUTEINBILL (ID IN NUMBER, id_error OUT NUMBER, ERROR_TEXT OUT VARCHAR2)
IS
CURSOR reestr (id_ IN NUMBER) IS
SELECT i.id_sklad, i.id_nomencl, i.fact_quantity, i.ibprice, ii.inbilldate, i.id_ibspec,
i.id_cell, ii.inbillnum, ii.id_inbill, ii.id_kontragent, i.ibsumitogo, k.name_org,
i.swidth, i.sheight, i.num_party
FROM in_bill_spec i, in_bill ii, kontragent k
WHERE i.id_inbill = ii.id_inbill
AND ii.id_inbill = id_
AND ii.id_kontragent = k.id_kontragent;

ll_id_stock NUMBER;
ID_DOC number;
cFill number;
DateDoc date;

BEGIN
   id_error := -1;                                   -- изначально ошибки нет

   begin
     select nvl(t.docid, 0), t.inbilldate into ID_DOC, DateDoc from in_bill t where t.id_inbill=ID and t.doctable='SP_SCHET';
   exception
     when NO_DATA_FOUND then ID_DOC := 0;
   end;

   UPDATE in_bill SET id_docstate = 3 WHERE id_inbill = ID;

   FOR i IN reestr (ID)
   LOOP
--------------------------------------------------------------------------------
-- Добавляем движение по складу
-------------------------------------------------------------------------------
     INSERT INTO stock(id_sklad, id_nomencl, quantity, id_spec,stockdate, doctype, id_doc, agentcode, summa, width, height)
     VALUES (i.id_sklad, i.id_nomencl, i.fact_quantity, i.id_ibspec,i.inbilldate, 1, i.id_inbill, i.id_kontragent, i.ibsumitogo, i.swidth, i.sheight);

--------------------------------------------------------------------------------
-- Добавляем примечание к движению по складу
-------------------------------------------------------------------------------
     SELECT sq_stock_id.CURRVAL INTO ll_id_stock FROM DUAL;

     insert into Stock_spec (id_stock, Id_Prop, Id_Prop_Value)
       select ll_id_stock, p.id_prop, p.id_prop_value
       from alternate_nomencl_properties p where p.id_nom_in_izdel=i.id_ibspec and p.doctype=1;

     INSERT INTO stock_remm(id_stock, doc_num, comments,type_dv)
     VALUES (ll_id_stock, i.inbillnum, (case when i.num_party is not null then 'Партия: '||i.num_party||', ' end)||'Поставщик: ' || i.name_org,'Прих.накл.');

     if GetKonstant('TYPE_PRICE_RUR') = 0 then
       UPDATE nomenclatura SET price_rur=cenanomold(i.id_nomencl, DateDoc), price_last=i.ibprice WHERE id_nomencl=i.id_nomencl;
     end if;

     if GetKonstant('TYPE_PRICE_RUR') = 1 then
       UPDATE nomenclatura SET price_rur=cenanomold(i.id_nomencl, DateDoc), price_last=cenanomold(i.id_nomencl) WHERE id_nomencl=i.id_nomencl;
     end if;

------------------------------------------------------------------------------
      -- кладем номенклатуру в выбранную ячейку
     IF (i.id_cell IS NOT NULL)
     THEN
       ERROR_TEXT :=  logistics.addnomencltocell (NVL (i.id_cell, 0),i.id_nomencl,i.fact_quantity);

         -- если не удалось положить номенклатуру в ячейку, выкидываем ошибку
       IF (LENGTH (ERROR_TEXT) > 0) THEN
         id_error := i.id_ibspec;
         RETURN;
       END IF;
     END IF;
   END LOOP;

  if (ID_DOC > 0) then
    --psv добавил учет коэфф. перерасчета:  * nvl(max(kp_unit_sp),1) и добавил округление до 3 (в НП введено было 4 знака а пришло 3)
    select count(*) into cFill from
    (Select sps.id_nomencl, sps.price, sps.id_unit, round(sum(sps.quantity) * nvl(max(kp_unit_sp),1),3) as c
    from Sp_Schet sp, sp_schet_spec sps
    where sp.id_schet=sps.id_sp_schet and sp.id_schet=ID_DOC
    group by sps.id_nomencl, sps.price, sps.id_unit)A,
    (select ibs.id_nomencl, ibs.ib_sp_unit, round(sum(ibs.ibquantity),3) as c
    from IN_BILL_SPEC ibs, in_bill ib
    where ibs.id_inbill=ib.id_inbill and ib.doctable='SP_SCHET' and ib.docid=ID_DOC
    group by ibs.id_nomencl, ibs.ib_sp_unit)B, nomenclatura n , unit u
    where u.id_unit=n.Id_Unit
    and n.Id_Nomencl=a.id_nomencl
    and a.id_nomencl=b.id_nomencl(+)
    --and a.id_unit=b.ib_sp_unit(+)
    and(b.id_nomencl is null or a.c-nvl(b.c, 0) > 0);

    if cFill = 0 then
      update sp_schet sp set sp.states='4-Получен товар', sp.id_docstate=4 where sp.id_schet=ID_DOC;
    end if;
  end if;
  
  CheckStock();
END;
/


update sp_schet sp set sp.states='4-Получен товар' where sp.states='3-Получен товар';
update sp_schet set id_docstate = 3 where id_schet = 23890; 

select * from dv.sp_schet where id_schet = 23890;
select * from dv.sp_schet_spec where id_sp_schet = 23890;
select * from in_bill where inbillnum = 7585;  --73832

declare
  i number;
  st varchar2(4000);
begin
  EXECUTEINBILL(73832, i, st);
end;
/
  


    --select count(*) as cFill from
    select a.c, b.c as cb, k from
    (Select sps.id_nomencl, sps.price, sps.id_unit, round(sum(sps.quantity) * nvl(max(kp_unit_sp),1), 3) as c, nvl(max(kp_unit_sp),1) as k
    from Sp_Schet sp, sp_schet_spec sps
    where sp.id_schet=sps.id_sp_schet and sp.id_schet=23890
    group by sps.id_nomencl, sps.price, sps.id_unit)A,
    (select ibs.id_nomencl, ibs.ib_sp_unit, sum(ibs.ibquantity) as c
    from IN_BILL_SPEC ibs, in_bill ib
    where ibs.id_inbill=ib.id_inbill and ib.doctable='SP_SCHET' and ib.docid=23890  --21767
    group by ibs.id_nomencl, ibs.ib_sp_unit)B, nomenclatura n , unit u
    where u.id_unit=n.Id_Unit
    and n.Id_Nomencl=a.id_nomencl
    and a.id_nomencl=b.id_nomencl(+)
    --and a.id_unit=b.ib_sp_unit(+)
    --and(b.id_nomencl is null or a.c-nvl(b.c, 0) > 0);
