--смотри какие запросы выполнялись дольше Х секунд в указанной схеме
select * from v$sql where elapsed_time/executions > 5000000 and executions > 0 and parsing_schema_name = 'DV';--       and username = 'DV';
select child_number, sql_id, last_Active_time, round(elapsed_time/executions/1000000,1) sec, executions, sql_fulltext from v$sql where elapsed_time/executions > 5*1000000 and executions > 0 and parsing_schema_name = 'DV';-- 

--смотрим долгие операции в указанной сессии (обязательно не в этой!)
--This view displays the status of various operations that run for longer than 6 seconds (in absolute time).
--покажет уже выполенныые и выполняющиеся сейчас
select l.sid, l.start_time,l.time_remaining,l.message,l.last_update_time,(l.last_update_time-l.start_time)*86400 as sec from v$session_longops l;

select s.osuser, l.sid, l.start_time,l.time_remaining,l.message,l.last_update_time,(l.last_update_time-l.start_time)*86400 as sec 
from v$session_longops l
, v$session s         
where 
--l.sid=83
s.sid (+) = l.sid
--and message like '%DV%'
--and s.username = 'DV18' 
--and s.osuser like 'oorlova' 
and l.last_update_time <> l.start_time
order by L.last_update_time desc;      

select * from v$session;

ALTER SYSTEM KILL SESSION '389,9786';

select * from v$active_Session_history order by sample_time desc;






--получаем запросы в реальном времени (айди, статус, событие
--и тут, в данном случае видим, что висит запрос с таким-то айди, и в статусе чтение данных и бд
--select sql_id, state, event from v$session where username = 'DV'; 
select sid, status, user, sql_id, state, event, sql_exec_start, seconds_in_wait 
from v$session 
where 
not (state = 'WAITING' and event = 'SQL*Net message from client')
and username = 'UCHET22' and osuser like '%';
--and username = 'DV' and osuser like '%';


--из предыдущего запроса по sql_id получаем параметры - для одного запроса может быть несколько дочерних, он нужен в дальнейшем,
--время последней активности, ну и полный текст запроса
select child_number, last_Active_time, sql_fulltext from v$sql where sql_id = 'cpaggxc8wk3wr';

--история запросов активной сессии
select * from v$active_session_history;

--в полной версии можно было бы получать план запроса так, притом со временем  выполнения по каждому пункту, но этого функионала в хе нет
select dbms_sqltune.report_sql_monitor('9k2393mxjbkq4') from dual;
--select dbms_sqltune.report_sql_monitor

-- так получаем план запроса, по sql_id и child_number 
-- может быть иногда мгого чайлд так что можно явно указать который
select * from table(dbms_xplan.display_cursor('8xrn2f4tj8yma',6));
--| Id  | Operation                                               | Name                     | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
select plan_table_output from table(dbms_xplan.display_cursor('8xrn2f4tj8yma',6)) where plan_table_output like '%TABLE ACCESS FULL%';

-- то же, подробно
select * from table (dbms_xplan.display_cursor('8xrn2f4tj8yma',6,'advanced allstats last'));
--| Id  | Operation                                               | Name                     | E-Rows |E-Bytes|E-Temp | Cost (%CPU)| E-Time   |  OMem |  1Mem | Used-Mem |

--выяснив текс запроса моделируем ситуацию
--в данном случае у нас (для нашей конфигурации) имеется большая таблицы STOCK S
--и делается выборка на основе значений колонки ID_NOMENCL
--в плане запроса видим, что идет прямое чтение данных/, без использования индекса

--можно проанализировать таблицу, в плане структуры данных, по значениям, которые используются в данном запросе
--посмотрим вообще количество строк
select count(1) from dv18.stock;
--и посмотрим в данном случае сколько раз встречаются какие ID_NOMENCL в таблице, и отсортируем те которых много
select ID_NOMENCL, count(1) from dv18.stock where DOCTYPE in (1,5,6,7,8,9,10,11,12) group by id_nomencl order by 2 desc;

--происходит следующее:
--оракл сам выбирает план запроса (когда кэш неактуален;запросы кэшируются, в накшем случае из этого понятно почему может помочь перезапуск оракла
--!!! узнать подробнее про кэширование
--данные могут читаться из таблицы либо по индексу, либо напрямую
--загрузка индекса требует также ресурсов
--в оракле установлен параметр сессии (стоимость использования индекса), optimizer_index_cost_adj, по умолчанию 100
--!!! не помню что ТОЧНО это значит, но смысл в том что задается стоимость использования индекса
--его использование будет выбираться ораклом для запроса чаще в том случае, если делается выборка значений, которые в таблице повторяются редко 
--(малый процент таблицы), потому что оно тогда выгодно, а если повторений много, то имеет смысл сразу читать таблицу, ведь это все равно придется делать)
--вот optimizer_index_cost_adj указывает стоимоть использования индекса, указав стоимость ниже, мы заставим ВСЕ запросы сессии использовать индексы чаще
alter session set optimizer_index_cost_adj=100;
--можно попробовать применить этот парамкетр (поставить и 10 и даже 1), но его использовать постоянно имеет смысл если в проекте хорошее обеспечение индексами,
--в любом случае надо подбирать, а не зная лучше оставить 100.

--вот этот запрос анализируем и модифицируем
--в комментарии /*...*/ можем писать управляющие конструкции, указав там знак +
--этим заставим использовать этот конкретный запрос ВСЕГДА индекс /*+ index(s  IND_ID_NOMENCL) */
--указывается имя псевдонима и имя индекса IND_ID_NOMENCL
--просмотреть индексы для таблицы можем так
select * from dba_ind_columns where table_name = 'STOCK';

--ну и тестируем запрос
SELECT    /*+ index(s  IND_ID_NOMENCL) */
NVL(SUM(S.SUMMA), 0) FROM dv18.STOCK S WHERE S.STOCKDATE <= sysdate AND 
S.DOCTYPE IN (1,5,6,7,8,9,10,11,12) AND S.ID_NOMENCL = 9482;

--------------------------------------------------------------
alter session set optimizer_index_cost_adj=100;

select * from dba_ind_columns where table_name = 'STOCK';

select ID_NOMENCL, count(1) from dv18.stock where DOCTYPE in (1,5,6,7,8,9,10,11,12) group by id_nomencl order by 2 desc;



--------------------------------------------------------------------------------
-- https://rutube.ru/video/a331dc0a1b0fce269e28b50c260fc542/

begin
dbms_stats.gather_schema_stats(ownname=>'DV');
end;
/

BEGIN
  DBMS_MONITOR.SESSION_TRACE_ENABLE(
    session_id => 136, -- ID сессии
    --serial_num => 456, -- SERIAL#
    waits => TRUE,
    binds => TRUE
  );
  DBMS_MONITOR.SESSION_TRACE_ENABLE(
    session_id => 270, -- ID сессии
    --serial_num => 456, -- SERIAL#
    waits => TRUE,
    binds => TRUE
  );
END;
/


select * from v$active_Session_history order by sample_time desc;


select child_number, last_Active_time, sql_text, sql_fulltext from v$sql where sql_id = '6mgvfc391r803';  --select * from v_acts t`
select dbms_sqltune.report_sql_monitor('6mgvfc391r803') from dual;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('6xam4fuwsjmpa', 0, 'ALL'));

begin
  select /*+momitor */  * from v_acts t;
end;
/

  select * from v_acts tttt;

  select /*+momitor */  * from v_acts;

  select id_act,id_docstate,actnum,actdate,numzakaz,zakazname,itogo,comments,zakazcostend,firm,doc_owner,doc_date from v_acts;
  


select
  a.event, session_id, session_state, s.sql_text, s.sql_fulltext, a.sql_id, a.sql_exec_start, s.executions, s.fetches,  s.rows_processed, round(elapsed_time / greatest(executions, 1) / 1024 / 1024,1) as "время запроса"
  ,a.* 
from 
  v$active_session_history a, v$sql s
where
  --(session_id  = (select SID from V$MYSTAT where ROWNUM = 1) or
  --( session_id in (270,136)) 
  --and
  a.sql_id = s.sql_id (+)
  and s.sql_text is not null
order by sample_time desc;

SELECT event, COUNT(*) AS wait_count
FROM 
--WHERE sql_id = '6mgvfc391r803'
  --AND session_state = 'WAITING'
GROUP BY event
ORDER BY wait_count DESC;

CREATE DIRECTORY export_dir AS 'R:\ora_exports';
GRANT READ, WRITE ON DIRECTORY export_dir TO uchet22;