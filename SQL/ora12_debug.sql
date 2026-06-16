select * from v$active_session_history order by nvl(sql_exec_start, date '2000-01-01') desc;

SELECT sid, serial#, username, event, wait_class
FROM v$session
WHERE username = 'DV'; -- »ли по program, machine

SET ARRAYSIZE 5000;

ALTER SESSION SET SQL_TRACE = TRUE;
ALTER SESSION SET SQL_TRACE = FALSE;