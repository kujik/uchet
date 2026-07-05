--==============================================================================
--таблица дл€ отладочного логировани€ действий в коде pl/sql
--==============================================================================

create table tmp_log_ (
  id  number primary key,
  dt  date,
  msg varchar2(4000)
);

create sequence sq_tmp_log start with 1 increment by 1;

create or replace trigger trg_tmp_log_bi
  before insert on tmp_log_
  for each row
begin
  if :new.id is null then
    :new.id := sq_tmp_log.nextval;
  end if;
  if :new.dt is null then
    :new.dt := sysdate;
  end if;
end;
/

--=============================================================================
--ѕроцедура дл€ записи в лог
create or replace procedure p_log(p_msg in varchar2) is
  pragma autonomous_transaction;
begin
  insert into tmp_log_ (msg) values (p_msg);
  commit;
end;
/

delete from tmp_log_;