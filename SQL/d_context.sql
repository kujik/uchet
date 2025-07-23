CREATE OR REPLACE CONTEXT context_uchet22 USING set_context_value;

CREATE OR REPLACE PROCEDURE set_context_value (
  par IN VARCHAR2,
  val IN VARCHAR2 
) 
AS
BEGIN 
  DBMS_SESSION.SET_CONTEXT ('context_uchet22', par, val);
END;
/

/*
CREATE OR REPLACE FUNCTION get_context_value (
  par IN VARCHAR2
) 
RETURN

AS
BEGIN DBMS_SESSION.SET_CONTEXT ('context_uchet22', par, val);
END;
/
*/

drop function get_context_value;
CREATE OR REPLACE FUNCTION f_set_context_value (
  par IN VARCHAR2,
  val IN VARCHAR2 
) 
RETURN number
AS
BEGIN 
  set_context_value(par, val);
  return 1;
END;
/

create or replace function get_context (
  par in varchar2
)
return varchar2  
as
begin
  return sys_context('context_uchet22', par);
end;
/  


begin
set_context_value('par1', 1);
end;
/

select sys_context('context_uchet22','qqq') from dual;

select get_context_value('qqq') from dual;
