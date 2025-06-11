/*
ИНФОРМАЦИЯ ПО ТАБЛИЦАМ СХЕМЫ
*/

-- Проверка максимального количества процессов
SELECT 
    (SELECT COUNT(*) FROM v$process) AS current_processes,
    (SELECT value FROM v$parameter WHERE name = 'processes') AS max_processes,
    (SELECT COUNT(*) FROM v$session) AS current_sessions,
    (SELECT value FROM v$parameter WHERE name = 'sessions') AS max_sessions
FROM dual;

SELECT name, round(value / 1024 /1024)
FROM v$parameter
WHERE name IN ('memory_target', 'memory_max_target', 'sga_target', 'pga_aggregate_target');

SELECT 
  a.*,
  case when unit = 'bytes' then round(value / 1024/1024) end as value_mb
FROM v$pgastat a;

--ALTER SYSTEM SET MEMORY_MAX_TARGET = 8G SCOPE=SPFILE;
--ALTER SYSTEM SET MEMORY_TARGET = 4G SCOPE=BOTH;

--так  поправать параметры если оракл не запускается и используется spfile
--sqlplus / as sysdba
CREATE PFILE='/tmp/initorcl.ora' FROM SPFILE;
STARTUP PFILE='/tmp/initorcl.ora'
CREATE SPFILE FROM PFILE='/tmp/initorcl.ora';




--select sum("Size KB") from (
SELECT t.owner,
t.table_name AS "Table Name",
t.num_rows AS "Rows",
t.avg_row_len AS "Avg Row Len",
Trunc((t.blocks * p.value)/1024) AS "Size KB",
to_char(t.last_analyzed,'DD/MM/YYYY HH24:MM:SS') AS "Last Analyzed"
FROM dba_tables t,
v$parameter p
--WHERE t.owner = Decode(Upper('&&Table_Owner'), 'ALL', t.owner, Upper('&&Table_Owner'))
WHERE t.owner = 'UCHET22'
AND p.name = 'db_block_size'
--ORDER by t.owner,t.last_analyzed desc,t.table_name
--order by "Size KB" desc;
order by "Rows" desc
;

select Trunc(sum(bytes)/1024) from dba_segments where owner = 'UCHET22';
select segment_name, Trunc(sum(bytes)/1024) from dba_segments where owner = 'UCHET22' group by segment_name;
select * from dba_segments where owner = 'UCHET22';
--SYS_LOB0000456863C00015$$
select * from dba_lobs;
select table_name, column_name from dba_lobs where segment_name = 'SYS_LOB0000456863C00015$$';

select dbms_lob.getlength(lob_column_name) from your_Table;

update adm_error_log set pictc = null;

/*
СОБРАТЬ СТАТИСТИКУ ПО СХЕМЕ
*/
exec dbms_stats.gather_schema_stats('UCHET22');


/*
ПРОВЕРКА СИНХРОНИЗАЦИИ УЧЕТА С ИТМ
*/
--------------------------------------------------------------------------------
create or replace view v_debug_orderitemsdiff as
--изделия, наименования которых в Учети и в ИТМ не совпадают
select 
  oi.id_order,
  oi.ornum,
  oi.slash,
  ni.id_nominizdel,
  n.name,
  n.id_nomencl,
  oi.fullitemname 
from 
  dv.nomenclatura_in_izdel ni,
  dv.nomenclatura n,
  v_order_items oi
where 
  ni.id_nomizdel_parent_t is null 
  and n.id_nomencl = ni.id_nomencl
  and oi.id_itm = ni.id_nominizdel
  and n.name <> oi.fullitemname
;

select * from v_debug_orderitemsdiff
--where not (instr(name, '_') = 0 and instr(fullitemname, '_') > 0)
--where ornum = 'Н240680'
;

select distinct ornum from v_debug_orderitemsdiff
where instr(name, '_') = 0 and instr(fullitemname, '_') > 0
--where ornum = 'Н240680'
;



select
--заказы, в которых есть несовпадения наименований изделий в Учете и в ИТМ
  o.ornum,
  o.dt_beg,
  o.dt_end,
  trunc(o.dt_change)
from
  orders o,  
  (select distinct id_order from v_debug_orderitemsdiff) od
where
  od.id_order = o.id
order by
  dt_change desc
;







select * from v_debug_orderitemsdiff where ornum = 'Н241166';



--------------------------------------------------------------------------------

create table temp_syncwithitm (
  slash varchar2(50),
  id_nominizdel number,
  id_nomencl_old number,
  id_nomencl_new number,
  name_old varchar2(400),
  name_new varchar2(400)
);  
  
  

declare
  IdNomenclatura number;
  cursor c1 is 
    select slash, id_nominizdel, id_nomencl, name, fullitemname
    from v_debug_orderitemsdiff
    where instr(name, '_') = 0 and instr(fullitemname, '_') > 0;
begin
  
  return;
  
  delete from temp_syncwithitm;
  
  for rec in c1 loop

    dbms_output.put_line(rec.slash);

    begin
      select n.id_nomencl into IdNomenclatura
      from dv.nomenclatura n 
      where n.name=rec.fullitemname;
    exception
      when no_data_found then
        insert into dv.nomenclatura(name, fullname, id_unit, id_group, id_nomencltype)
        values(rec.fullitemname, rec.fullitemname, 6, 3, 1) returning id_nomencl into IdNomenclatura;
    end;

    update dv.nomenclatura_in_izdel niz 
    set niz.id_nomencl=IdNomenclatura
    where niz.id_nominizdel=rec.id_nominizdel;

    insert into temp_syncwithitm 
    (slash, id_nominizdel, id_nomencl_old, id_nomencl_new, name_old, name_new)
    values 
    (rec.slash, rec.id_nominizdel, rec.id_nomencl, IdNomenclatura, rec.name, rec.fullitemname);
  end loop;
end;
/

--М242042

