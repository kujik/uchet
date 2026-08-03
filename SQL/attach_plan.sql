set serveroutput on size unlimited
set long 1000000
set pagesize 0
set linesize 300
set verify off

define SOURCE_SQL_ID = '&&1'   --айди запроса для хорошего плана
define SOURCE_PHV    = '&&2'   --хеш хорошего плана
define TARGET_SQL_ID = '&&3'   --айди запроса плохого плана
define PROFILE_NAME  = '&&4'   --произвольное  имя профиля  

DECLARE
    l_sql_text   CLOB;
    l_profile    SYS.SQLPROF_ATTR;
    l_hints      CLOB;
BEGIN

    ----------------------------------------------------------------------------
    -- Get target SQL text
    ----------------------------------------------------------------------------
    SELECT sql_fulltext
    INTO   l_sql_text
    FROM   v$sql
    WHERE  sql_id = '&&TARGET_SQL_ID'
    AND    rownum = 1;

----------------------------------------------------------------------------
    -- Collect outline hints from good plan
    ----------------------------------------------------------------------------
    SELECT
        XMLCAST(
            XMLAGG(
                XMLELEMENT(e, q'[']' || hint || q'[' ,]')
                ORDER BY hint
            ) AS CLOB
        )
    INTO l_hints
    FROM (
        SELECT DISTINCT
               REPLACE(extractvalue(value(d), '/hint'), '''', '''''') AS hint
        FROM xmltable(
            '/other_xml/outline_data/hint'
            PASSING (
                SELECT XMLTYPE(other_xml)
                FROM   v$sql_plan
                WHERE  sql_id = '&&SOURCE_SQL_ID'
                AND    plan_hash_value = &&SOURCE_PHV
                AND    other_xml IS NOT NULL
                AND    rownum = 1
            )
        ) d
    );

    -- убираем хвостовую запятую и пробел
    l_hints := RTRIM(l_hints, ', ');

    -- на всякий случай проверим, что список не пустой
    IF l_hints IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Не найдено ни одного хинта для указанного SQL_ID/PHV');
    END IF;
    
    ----------------------------------------------------------------------------
    -- Convert hint list to SQLPROF_ATTR
    ----------------------------------------------------------------------------
    EXECUTE IMMEDIATE
        'BEGIN :x := SYS.SQLPROF_ATTR(' || l_hints || '); END;'
    USING OUT l_profile;

    ----------------------------------------------------------------------------
    -- Create SQL Profile
    ----------------------------------------------------------------------------
    DBMS_SQLTUNE.IMPORT_SQL_PROFILE(
        sql_text    => l_sql_text,
        profile     => l_profile,
        name        => '&&PROFILE_NAME',
        force_match => TRUE,
        replace     => TRUE,
        category    => 'DEFAULT'
    );

    DBMS_OUTPUT.PUT_LINE('SQL Profile created: &&PROFILE_NAME');

END;
/