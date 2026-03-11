-- Создается под пользователем SYS на сервере
CREATE OR REPLACE PROCEDURE sys.kill_user_session(p_sid NUMBER, p_serial NUMBER)
AUTHID DEFINER -- Ключевой момент: процедура выполняется с правами владельца (SYS)
AS
BEGIN
  EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || p_sid || ',' || p_serial || ''' IMMEDIATE';
END kill_user_session;
/

GRANT EXECUTE ON SYS.KILL_USER_SESSION TO UCHET22;

select * from v$session;