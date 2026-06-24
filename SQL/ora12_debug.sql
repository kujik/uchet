select round(s.elapsed_time / 1000000 / s.executions) as tm, s.executions, t.* 
from v$active_session_history t, v$sql s, v$session se
where t.sql_id = s.sql_id and t.session_id = se.sid and se.username = 'DV'
order by nvl(t.sql_exec_start, date '2000-01-01') desc;

 

select sid, serial#, username, event, wait_class
from v$session
where username = 'DV'; -- или по program, machine

SET ARRAYSIZE 5000;

ALTER SESSION SET SQL_TRACE = TRUE;
ALTER SESSION SET SQL_TRACE = FALSE;