select * from v$active_session_history;
select sample_time, session_id, session_serial#, sql_id, sql_child_number, sql_exec_id, sql_plan_line_id, sql_plan_operation, sql_plan_options, session_state from v$active_session_history where session_id = 512 and session_serial# = 42782;

select sql_id, child_number, executions, elapsed_time 
from v$sql 
where sql_text like '%name, qnt_psp_sell, qnt% where%id_format_est = :%';

select * from table(dbms_xplan.display_cursor('c3j98uumn7xhd', 4, 'ALLSTATS LAST'));


select sql_id, child_number, executions, elapsed_time 
from v$sql 
where sql_text like '%select id, format_name,slash,name,qnt_psp_sell,qnt_psp_prod,qnt_sgp_registered,qnt_shipped,qnt,qnt_in_prod,qnt_to_shipped,qnt_min,qnt_need,price,summ,priceraw,sumraw from v_sgp_items where id_format_est  =%';

select * from table(dbms_xplan.display_cursor('aw19ubm7b905g', 1, 'ALLSTATS LAST'));

--полцмим outline из хорошего плана
SELECT DBMS_XPLAN.DISPLAY_CURSOR(
  'aw19ubm7b905g', 1, 'ALLSTATS LAST +OUTLINE'
) FROM DUAL;

--посмотреть плагн запроса по sql_id (можно передать еще и sql_exec_id)
select dbms_sqltune.report_sql_monitor('c3j98uumn7xhd',16777251) from dual;

select * from v$sql;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*

привязка планов выполнения для запроса.

1. смотрим какой запрос надо модифицировать и из кагого использовать хороший план
можно смореть в реальном времени в active_session_history
скрипт ниже фильтруем запросы по тексту который в них есть, исключает сами эти отладочные запросы
выводит текст запроса и доп информацию (считаем что запросы формируются из программы Учет,
в этом случае мы здесь видим от имени кого запрос; если для отладки запрос вручную, то исключить соединение)
отсортировав вывод, мы можем найти хорошие и плохие запросы.
если текст их один, скорее всего будет различие в sql_child_number

2. определив хороший запрос, получаем план для него по sql_id и child_number
нам нужен хеш плана, он в шапке

3.
выполняем скриптом файл 
attach_plan.sql
в нем вводим (тоад выдаст окно диалога ввода бинд-переменных)
--айди запроса для хорошего плана
--хеш хорошего плана
--айди запроса плохого плана
--произвольное  имя профиля 

3. выполняем запрос, получаем также план для него, убеждаемся что план привязался:
внизу в ноте должно быть не
   - this is an adaptive plan
а
   - SQL profile plan_for_sgp_report used for this statement

*/

--1.
--получаем даннгые по проблемным запросам, которые сейчас выполняются
--миксуем данные по запросу, акти сессион хистори и кто залогинен в учете
select 
  u.login, u.name, u.machine,
  h.sample_time, h.session_id, h.session_serial#, h.sql_id, h.sql_child_number, h.sql_exec_id, h.sql_plan_line_id, h.sql_plan_operation, h.sql_plan_options, h.session_state,
  s.sql_text , s.sql_fulltext
from 
  v$active_session_history h, v$sql s, v_active_user_sessions u  
where
  sql_text like '%select to_char(id) as id, format_name, slash, name, qnt_psp_sell, qnt_psp_prod, qnt_sgp_registered, qnt_shipped, qnt, qnt_in_prod, qnt_to_shipped, qnt_min, qnt_need, price, summ, priceraw, sumraw from v_sgp_items where id_format_est = :1%' 
  and not sql_text like '%v$active_session_history%' 
  and h.sql_id = s.sql_id and h.sql_child_number = s.child_number
  and h.session_id = u.sid and h.session_serial# = u.serial#
  --and session_id in (512) and session_serial# in (42782)
;  

--2.
--смотрим план запроса по sql_id и child_number
select * from table(dbms_xplan.display_cursor('c3j98uumn7xhd', 6, 'ALLSTATS LAST'));
--plzn hash value   760683200



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*
закрепление хорошего плана через baseline
у  меня не сработало, возможно проблема в получении SQL_HANDLE,
недопонял как э то сделать корректно
*/

--Закрепление хорошего плана через SQL Plan Management (SPM)
--Загрузить хороший план из кеша курсоров:
DECLARE
  l_plans_loaded PLS_INTEGER; 
BEGIN
  l_plans_loaded := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(
    sql_id => 'aw19ubm7b905g',   -- хороший SQL_ID
    plan_hash_value => 2082400565 -- hash хорошего плана
  );
  DBMS_OUTPUT.PUT_LINE('Загружено планов: ' || l_plans_loaded);
END;
/

--SQL_HANDLE — это хеш, вычисленный на основе нормализованного текста SQL (удалены пробелы, регистр приведён к верхнему, заменены литералы на bind-переменные и т.д.). Если вы загрузили план для конкретного SQL_ID, то именно его SQL_HANDLE и будет в представлении.
SELECT SQL_HANDLE, SQL_TEXT FROM DBA_SQL_PLAN_BASELINES WHERE SQL_TEXT like '%v_sgp_items%';

--Привяжите хороший план к плохому запросу
SELECT PLAN_NAME, ENABLED, ACCEPTED, FIXED
FROM DBA_SQL_PLAN_BASELINES
WHERE SQL_HANDLE = 'SQL_558ee4c15c02a6d8';

--Затем зафиксируйте хороший план (сделайте его ENABLED и ACCEPTED)
DECLARE
  l_plans_altered PLS_INTEGER;
BEGIN
  l_plans_altered := DBMS_SPM.ALTER_SQL_PLAN_BASELINE(
    sql_handle      => 'SQL_558ee4c15c02a6d8',
    plan_name       => 'SQL_PLAN_5b3r4s5f059qs3a7ee6e8',   -- из предыдущего запроса
    attribute_name  => 'ENABLED',
    attribute_value => 'YES'
  );
  DBMS_OUTPUT.PUT_LINE('План изменён: ' || l_plans_altered);
END;
/

--Проверка, что план применился
--выполняем проблемный запрос
select to_char(id) as id, format_name, slash, name, qnt_psp_sell, qnt_psp_prod, qnt_sgp_registered, qnt_shipped, qnt, qnt_in_prod, qnt_to_shipped, qnt_min, qnt_need, price, summ, priceraw, sumraw from v_sgp_items where id_format_est = :1;
--В колонке Note должно появиться сообщение, что использован SQL Plan Baseline.
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +OUTLINE'));


