CREATE OR REPLACE FORCE VIEW DV.V_SPINVOICES
(R, ID_SCHET, SCHET_NUM, ID_DOCSTATE, COMMENTS, 
 SCHET_DATE_REGISTR, ID_CASHFLOW, STATES, POSTNAME, POKUPNAME, 
 SCHET_SUM, ORDERDEMANDSP, TRANSPORT_PLACE, EXPORT, OPLATIT_DO, 
 OPLACHENO, RAZNICA, ID_KONTRAGENT2, ID_KONTRAGENT1, DOC_OWNER, 
 DOC_DATE, NUMINBILL)
BEQUEATH DEFINER
AS 
select
  rownum r,
  s.ID_SCHET as ID_SCHET,
  s.NUM as SCHET_NUM,
  s.ID_DOCSTATE,
  s.Comments,
  s.DATE_REGISTR as SCHET_DATE_REGISTR,
  s.ID_CASHFLOW as ID_CASHFLOW,
  s.states as states,
  kontragent_full_name(id_kontragent1) As PostName,
  kontragent_full_name(id_kontragent2) As PokupName,
  s.SUM as SCHET_SUM,
  (select ds.list_order from demand_supplier ds where ds.id_demand_supplier=s.docid) as OrderDemandSP,
  s.TRANSPORT_PLACE as TRANSPORT_PLACE,
  s.EXPORT as EXPORT,
  s.date_payment as OPLATIT_DO,
  (select sum(v.SumItogo) as Oplacheno
   from v_in_bills v
   where v.docid=s.id_schet) oplacheno,
  ((s.sum)-(select nvl(sum(v.SumItogo),0) as Oplacheno
              from v_in_bills v
              where v.docid=s.id_schet)) as Raznica,
  s.id_kontragent2,
  s.id_kontragent1,
  get_lu_docs_user('SP_SCHET', s.id_schet) as doc_owner,
  get_lu_docs_date('SP_SCHET', s.id_schet) as doc_date,
     (select ib.inbillnum from in_bill ib where ib.docid=s.id_schet and ib.docstr is not null and rownum=1) as NumInBill
from
  SP_SCHET s
where  
  --s.DATE_REGISTR > trunc(sysdate) - 120
  s.DATE_REGISTR >= date '2026-01-01'
  ;  