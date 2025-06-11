
drop function test1;


--по полю, содержащему айди юзеров чкерез запятую,
--выводит строку имен юзеров через ;
create or replace function GetUserNames (
userids varchar2
)
return varchar2   
is
   cv sys_refcursor; 
   val varchar2(4000);
   usernames varchar2(4000);  
begin
   usernames := '';
   if userids is null then return null; end if;
   open cv for 
      'select name from adm_users where id in (' || userids || ') order by name asc'; 
   loop
      fetch cv into val;
      exit when cv%notfound;
      if usernames is not null
        then usernames := usernames || '; ';
      end if; 
      usernames := usernames || val;
--      dbms_output.put_line (val);
   end loop;
   close cv;
   return usernames;
end;
/ 

select GetUserNames(null) from dual;

--находит подстроку в строке, разделенной запятыми
CREATE OR REPLACE function IsStInCommaSt (
  st in number,
  commast in varchar2
)
return number
is
  i number;
begin
  i := instr(',' || commast || ',', ',' || st || ',');
  if i > 0 
    then return 1;
    else return 0;
  end if; 
end;
/





CREATE OR REPLACE PROCEDURE showcol (
   tab IN VARCHAR2,
   col IN VARCHAR2,
   whr IN VARCHAR2 := NULL)
IS
   cv SYS_REFCURSOR; 
   val VARCHAR2(32767);  
BEGIN
   OPEN cv FOR 
      'SELECT ' || col || 
      '  FROM ' || tab ||
      ' WHERE ' || NVL (whr, '1 = 1');
      
   LOOP
      /* Fetch and exit if done; same as with explicit cursors. */
      FETCH cv INTO val;
      EXIT WHEN cv%NOTFOUND;
      
      /* If on first row, display header info. */
      IF cv%ROWCOUNT = 1
      THEN
         DBMS_OUTPUT.PUT_LINE (RPAD ('-', 60, '-'));
         DBMS_OUTPUT.PUT_LINE (
            'Contents of ' || UPPER (tab) || '.' || UPPER (col));
         DBMS_OUTPUT.PUT_LINE (RPAD ('-', 60, '-'));
      END IF;
      
      DBMS_OUTPUT.PUT_LINE (val);
   END LOOP;
   
   /* Don't forget to clean up! Very important... */
   CLOSE cv;
END;
/ 



CREATE OR REPLACE function F_FIO_Short (
--содиняет Фамилия, Имя, Отчество в строку короткого имени (Иванов А.Б.)
--корректно работает если только есть Фамилия и Имя, отчество же не важно 
  f in varchar2,
  i in varchar2,
  o in varchar2
)
return varchar2
is
  sti varchar2(4000);
begin
  sti := f;
  if length(sti) > 0 and length(i) > 0 then
    sti := sti || ' ' || substr(i, 1, 1) || '.';
  end if; 
  if length(sti) > 0 and length(o) > 0 then
    sti := sti || ' ' || substr(o, 1, 1) || '.';
  end if; 
  return sti;
end;
/

CREATE OR REPLACE function F_FIO (
--содиняет Фамилия, Имя, Отчество в полную строку
  f in varchar2,
  i in varchar2,
  o in varchar2
)
return varchar2
is
  sti varchar2(4000);
begin
  sti := f;
  if length(sti) > 0 and length(i) > 0 then
    sti := sti || ' ' || i;
  end if; 
  if length(sti) > 0 and length(o) > 0 then
    sti := sti || ' ' || o;
  end if; 
  return sti;
end;
/


select F_FIO_Short('Иванов', 'Александр', 'Ильич') from dual;


--по полю, содержащему айди юзеров чкерез запятую,
--выводит строку имен юзеров через ;
create or replace function GetUsersEmail(
userids varchar2
)
return varchar2   
is
   cv sys_refcursor; 
   val varchar2(4000);
   usersemail varchar2(4000);  
begin
   usersemail := '';
   if userids is null then return null; end if;
   open cv for 
      'select emailaddr from v_users where id in (' || userids || ')'; 
   loop
      fetch cv into val;
      exit when cv%notfound;
      if usersemail is not null
        then usersemail := usersemail || ',';
      end if; 
      usersemail := usersemail || val;
--      dbms_output.put_line (val);
   end loop;
   close cv;
   return usersemail;
end;
/


create or replace function RemoveRepetitionsComma(
--удалим из строки через запятую повторяющиеся элементы
--!!!! так не работает!!!
p_str_in varchar2
)
return varchar2
is
v_comma_count number;   -- число запятых
v_str_temp_left varchar2(100);
v_str_temp_right varchar2(100);
v_str_final varchar2(100);
v_str_input varchar2(100);
p_str_out varchar2(4000);
begin
    v_comma_count := regexp_count(p_str_in, ',');
    v_str_input := p_str_in;
    for i in 1..v_comma_count loop
      while regexp_like(v_str_input, '^,') or regexp_like(v_str_input, '^[[:space:]]')
         loop
           v_str_input := trim(v_str_input);
           v_str_input := ltrim(v_str_input, ',');        
         end loop;
      -- получаем первое слово
      v_str_temp_left := regexp_replace(regexp_substr(v_str_input, '^[.].{1,},', 1), ','); -- убираем запятую
      -- формируем выходную строку
      v_str_final := v_str_final||v_str_temp_left||',';
      -- изымаем первое слово  из строки
      v_str_temp_right := regexp_replace(v_str_input, '^[.]{1,},');
      -- ищем первое слово в строке и в случае нахождения, заменяем на пробел
      v_str_temp_right := regexp_replace(v_str_temp_right, v_str_temp_left||',', ' ,');
      -- перезаписываем полученную строку (без первого слова) с результатом сравнения
      v_str_input := v_str_temp_right;      
    end loop;
    v_str_final := rtrim(v_str_final, ',');
    --p_str_out := v_str_final;
    return v_str_final;
end;
/  
  

create or replace function GetUsersAddEmail
--по полю, содержащему айди юзеров чкерез запятую, и произвольные адреса через запятую
--выводит строку email-адресов, убирая несуществующих юзеров и повторения адресов
(
userids varchar2,
customemails varchar2
)
return varchar2   
is
   cv sys_refcursor; 
   val varchar2(4000);
   q varchar2(4000);
   z varchar2(4000);
   usersemail varchar2(4000);  
begin
   usersemail := '';
   if (userids is null)and(customemails is null) 
     then return null; end if;
   open cv for 
      'select emailaddr from v_users where id in (' || userids || ')'; 
   loop
      fetch cv into val;
      exit when cv%notfound;
      if usersemail is not null
        then usersemail := usersemail || ',';
      end if; 
      usersemail := usersemail || val;
  end loop;
  close cv;
  if (usersemail is not null) and (customemails is not null) then usersemail := usersemail || ','; end if;
  if customemails is not null then usersemail := usersemail || customemails; end if;
  select * 
  into usersemail
  from (
  with q as (select usersemail as z from dual)
  select listagg(z,',') within group (order by z)
  from (
  select distinct regexp_substr(z, '[^,]+', 1, level) as z
  from q
  connect by instr(z, ',', 1, level - 1) > 0 ));
  return usersemail;
end;
/ 

create or replace function Is_Transaction_Active
return boolean is
  l_count integer;
begin
  select count(*) into l_count
  from v$transaction t
  join v$session s on t.ses_addr = s.saddr
  where s.sid = (select sid from v$mystat where rownum = 1)
    and t.status = 'active';

  return l_count > 0;
end;
/
 
create or replace procedure P_ExchangePositions(
--сдвигает позицию (поле AField) вверх или вниз в переданной таблице ATable
--(путем обменя значений в этом поле)
  ATable varchar2,
  AField varchar2,
  APos number,
  ADirection number
)
as
  p number;
  t boolean;
begin
  if ADirection = -1 then
    execute immediate 'select max(pos) from ' || ATable || ' where ' || AField || ' < :pos' into p using APos;
  else
    execute immediate 'select min(pos) from ' || ATable || ' where ' || AField || ' > :pos' into p using APos;
  end if; 
  if p is null then
    return;
  end if;
  execute immediate 'update ' || ATable || ' set ' || AField || ' = -' || AField || ' where ' || AField || ' = :pos$i' using p;
  execute immediate 'update ' || ATable || ' set ' || AField || ' = :posnew where ' || AField || ' = :pos$i' using p, APos; 
  execute immediate 'update ' || ATable || ' set ' || AField || ' = :posnew where ' || AField || ' = :pos$i' using APos, -p;
end;    
/    

select * from work_cell_types;
exec P_ExchangePositions ('work_cell_types', 'pos', 2, 1);






select GetUsersAddEmail('33,31,33','1@3,2222,1@3,sprokopenko@fr-mix.ru') from dual;

--select regexp_substr(z, '[^,]+', 1, level) from (select '1@3,2222,1@3,sprokopenko@fr-mix.ru' as z from dual);

---------------------------------------------------------------------------------------------


   /   --(select '33,31,33','1@3,2222,1@3,sprokopenko@fr-mix.ru' from dual)
      select regexp_substr('1@3,2222,1@3,sprokopenko@fr-mix.ru', '[^,]+', 1, rownum) SPLIT
      from test
      connect by level <= length (regexp_replace('1@3,2222,1@3,sprokopenko@fr-mix.ru', '[^,]+'))  + 1);
      
     select * from table(apex_string.split('100,200,300,400,500',',')); 
      select * from table(STRING_TO_TABLE('One:Two:Three'));
      
/*function test22
return table
is
begin
select *      
WITH 
  TMain AS (SELECT '100,200,300,400,500' || ',' AS str
            FROM DUAL)
SELECT regexp_substr(str, '[^,]+', 1, level)
FROM TMain
CONNECT BY NVL(regexp_instr(str, '[^,]+', 1, level), 0) <> 0;      
*/



create table test2(
t number(1),
с number(1),
d varchar2(400)
);





--так можно получить таблицу из строки через разделитель
select d from (     
WITH 
  TMain AS (SELECT '100,200,300,400,500' || ',' AS str
            FROM DUAL)
SELECT regexp_substr(str, '[^,]+', 1, level) d
FROM TMain
CONNECT BY NVL(regexp_instr(str, '[^,]+', 1, level), 0) <> 0   
);
---------------------------------------------------------



--так можно синхронизировать таблицы (в данном случае свтавить значения из строки через разделитель,
--которых еще нет, и удалить те которых нет в строке
select * from test2;

begin
--в этом случае требуется флаг
update test2 set c = null where t = 1;

MERGE INTO test2 
   USING 
   (SELECT dd FROM (
     WITH TMain AS (SELECT 'z,b,v' || '' AS str FROM DUAL)
     SELECT regexp_substr(str, '[^,]+', 1, level) dd
     FROM TMain
     CONNECT BY NVL(regexp_instr(str, '[^,]+', 1, level), 0) <> 0   
   )) s
   ON (s.dd = test2.d and test2.t = 1)
   WHEN MATCHED THEN UPDATE SET test2.c= 1
   --DELETE WHERE test2.c = 0   
   WHEN NOT MATCHED THEN INSERT (test2.t, test2.c, test2.d) VALUES (1, 1, s.dd)
   ;

delete from test2 where c is null and t = 1;
update test2 set c = null where t = 1;
end;
/   

--или без использования флага удалить те что нет в исходной таблице так
delete from test2 where t=1 and d not in (
   (SELECT dd FROM (
     WITH TMain AS (SELECT 'z,b,v' || ',' AS str FROM DUAL)
     SELECT regexp_substr(str, '[^,]+', 1, level) dd
     FROM TMain
     CONNECT BY NVL(regexp_instr(str, '[^,]+', 1, level), 0) <> 0   
   )) 
);

-----------------------------------------------------




merge into dv.property_values d 
   using 
   (select m from (
     with tbl as (select 'slarencov@fr-mix.ru,sprokopenko@fr-mix.ru,lpanova@fr-mix.ru' || ',' as str from dual)
     select regexp_substr(str, '[^,]+', 1, level) m
     from tbl
     connect by nvl(regexp_instr(str, '[^,]+', 1, level), 0) <> 0   
   )) s
   on (s.m = d.avalue and d.id_prop = 219)
   when not matched then insert (d.avalue, d.id_prop) values (s.m, 219)
   ;
delete from test2 where t=1 and d not in (
   (SELECT dd FROM (
     WITH TMain AS (SELECT 'z,b,v' || ',' AS str FROM DUAL)
     SELECT regexp_substr(str, '[^,]+', 1, level) dd
     FROM TMain
     CONNECT BY NVL(regexp_instr(str, '[^,]+', 1, level), 0) <> 0   
   )) 
);

