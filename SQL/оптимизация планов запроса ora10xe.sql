--������ ����� ������� ����������� ������ � ������ � ��������� �����
select * from v$sql where elapsed_time/executions > 5000000 and executions > 0 and parsing_schema_name = 'DV';--       and username = 'DV';
select child_number, sql_id, last_Active_time, round(elapsed_time/executions/1000000,1) sec, executions, sql_fulltext from v$sql where elapsed_time/executions > 5*1000000 and executions > 0 and parsing_schema_name = 'DV';-- 

--������� ������ �������� � ��������� ������ (����������� �� � ����!)
--This view displays the status of various operations that run for longer than 6 seconds (in absolute time).
--������� ��� ����������� � ������������� ������
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






--�������� ������� � �������� ������� (����, ������, �������
--� ���, � ������ ������ �����, ��� ����� ������ � �����-�� ����, � � ������� ������ ������ � ��
--select sql_id, state, event from v$session where username = 'DV'; 
select sid, status, user, sql_id, state, event, sql_exec_start, seconds_in_wait 
from v$session 
where 
not (state = 'WAITING' and event = 'SQL*Net message from client')
and username = 'UCHET22' and osuser like '%';
--and username = 'DV' and osuser like '%';


--�� ����������� ������� �� sql_id �������� ��������� - ��� ������ ������� ����� ���� ��������� ��������, �� ����� � ����������,
--����� ��������� ����������, �� � ������ ����� �������
select child_number, last_Active_time, sql_fulltext from v$sql where sql_id = 'cpaggxc8wk3wr';

--������� �������� �������� ������
select * from v$active_session_history;

--� ������ ������ ����� ���� �� �������� ���� ������� ���, ������ �� ��������  ���������� �� ������� ������, �� ����� ���������� � �� ���
select dbms_sqltune.report_sql_monitor('9k2393mxjbkq4') from dual;
--select dbms_sqltune.report_sql_monitor

-- ��� �������� ���� �������, �� sql_id � child_number 
-- ����� ���� ������ ����� ����� ��� ��� ����� ���� ������� �������
select * from table(dbms_xplan.display_cursor('8xrn2f4tj8yma',6));
--| Id  | Operation                                               | Name                     | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
select plan_table_output from table(dbms_xplan.display_cursor('8xrn2f4tj8yma',6)) where plan_table_output like '%TABLE ACCESS FULL%';

-- �� ��, ��������
select * from table (dbms_xplan.display_cursor('8xrn2f4tj8yma',6,'advanced allstats last'));
--| Id  | Operation                                               | Name                     | E-Rows |E-Bytes|E-Temp | Cost (%CPU)| E-Time   |  OMem |  1Mem | Used-Mem |

--������� ���� ������� ���������� ��������
--� ������ ������ � ��� (��� ����� ������������) ������� ������� ������� STOCK S
--� �������� ������� �� ������ �������� ������� ID_NOMENCL
--� ����� ������� �����, ��� ���� ������ ������ ������/, ��� ������������� �������

--����� ���������������� �������, � ����� ��������� ������, �� ���������, ������� ������������ � ������ �������
--��������� ������ ���������� �����
select count(1) from dv18.stock;
--� ��������� � ������ ������ ������� ��� ����������� ����� ID_NOMENCL � �������, � ����������� �� ������� �����
select ID_NOMENCL, count(1) from dv18.stock where DOCTYPE in (1,5,6,7,8,9,10,11,12) group by id_nomencl order by 2 desc;

--���������� ���������:
--����� ��� �������� ���� ������� (����� ��� ����������;������� ����������, � ������ ������ �� ����� ������� ������ ����� ������ ���������� ������
--!!! ������ ��������� ��� �����������
--������ ����� �������� �� ������� ���� �� �������, ���� ��������
--�������� ������� ������� ����� ��������
--� ������ ���������� �������� ������ (��������� ������������� �������), optimizer_index_cost_adj, �� ��������� 100
--!!! �� ����� ��� ����� ��� ������, �� ����� � ��� ��� �������� ��������� ������������� �������
--��� ������������� ����� ���������� ������� ��� ������� ���� � ��� ������, ���� �������� ������� ��������, ������� � ������� ����������� ����� 
--(����� ������� �������), ������ ��� ��� ����� �������, � ���� ���������� �����, �� ����� ����� ����� ������ �������, ���� ��� ��� ����� �������� ������)
--��� optimizer_index_cost_adj ��������� �������� ������������� �������, ������ ��������� ����, �� �������� ��� ������� ������ ������������ ������� ����
alter session set optimizer_index_cost_adj=100;
--����� ����������� ��������� ���� ��������� (��������� � 10 � ���� 1), �� ��� ������������ ��������� ����� ����� ���� � ������� ������� ����������� ���������,
--� ����� ������ ���� ���������, � �� ���� ����� �������� 100.

--��� ���� ������ ����������� � ������������
--� ����������� /*...*/ ����� ������ ����������� �����������, ������ ��� ���� +
--���� �������� ������������ ���� ���������� ������ ������ ������ /*+ index(s  IND_ID_NOMENCL) */
--����������� ��� ���������� � ��� ������� IND_ID_NOMENCL
--����������� ������� ��� ������� ����� ���
select * from dba_ind_columns where table_name = 'STOCK';

--�� � ��������� ������
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
    session_id => 136, -- ID ������
    --serial_num => 456, -- SERIAL#
    waits => TRUE,
    binds => TRUE
  );
  DBMS_MONITOR.SESSION_TRACE_ENABLE(
    session_id => 270, -- ID ������
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
  a.event, session_id, session_state, s.sql_text, s.sql_fulltext, a.sql_id, a.sql_exec_start, s.executions, s.fetches,  s.rows_processed, round(elapsed_time / greatest(executions, 1) / 1024 / 1024,1) as "����� �������"
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