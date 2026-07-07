
--------------------------------------------------------------------------------
-- Создание/обновление заданий шедулера с использованием обёрток
--------------------------------------------------------------------------------
begin
  dbms_scheduler.drop_job('update_estimates_depend_job');
  dbms_scheduler.create_job (
    job_name        => 'update_estimates_depend_job',
    job_type        => 'plsql_block',
    job_action      => 'begin p_run_update_estimate_depends; end;',
    repeat_interval => 'freq=minutely; interval=5',
    enabled         => true,
    comments        => 'обновление dt_changed_depend в estimates'
  );
end;
/

begin
  dbms_scheduler.drop_job('orders_fin_monitoring_job');
  dbms_scheduler.create_job (
    job_name        => 'orders_fin_monitoring_job',
    job_type        => 'plsql_block',
    job_action      => 'begin p_run_insert_orders_fin_monitoring; end;',
    repeat_interval => 'freq=daily; byhour=10; byminute=37; bysecond=0;',
    enabled         => true,
    comments        => 'заполнение финансовых параметров запущенных вчера заказов'
  );
end;
/

begin
  dbms_scheduler.drop_job('vm_or_std_items_job');
  dbms_scheduler.create_job (
    job_name        => 'vm_or_std_items_job',
    job_type        => 'plsql_block',
    job_action      => 'begin p_run_refresh_vm_or_std_items; end;',
    repeat_interval => 'freq=daily; byhour=2; byminute=30; bysecond=0;',
    enabled         => true,
    comments        => 'обновление vm_or_std_items'
  );
end;
/

begin
  dbms_scheduler.drop_job('purge_scheduler_log_job');
  dbms_scheduler.create_job (
    job_name        => 'purge_scheduler_log_job',
    job_type        => 'plsql_block',
    job_action      => 'begin p_run_purge_scheduler_log; end;',
    start_date      => trunc(systimestamp) + interval '3' hour,
    repeat_interval => 'freq=daily; byhour=10; byminute=41; bysecond=0;',
    enabled         => true,
    comments        => 'очистка лога заданий шедулера старше 7 дней'
  );
end;
/

--прервать задание
exec dbms_scheduler.stop_job('orders_fin_monitoring_job');
--Включить/выключить: 
exec dbms_scheduler.enable('update_estimates_depend_job'); 
exec dbms_scheduler.disable('update_estimates_depend_job');
--апустить вручную: 
exec dbms_scheduler.run_job('orders_fin_monitoring_job', false);
--Удалить задание: 
exec dbms_scheduler.drop_job('update_estimates_depend_job');


--логи
--во время выполнения задания информация в логе еще не появится!
select sysdate from dual;
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'UPDATE_ESTIMATES_DEPEND_JOB' order by log_date desc;
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'ORDERS_FIN_MONITORING_JOB' order by log_date desc;
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'VM_OR_STD_ITEMS_JOB' order by log_date desc;
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'PURGE_SCHEDULER_LOG_JOB' order by log_date desc;


--------------------------------------------------------------------------------
-- Процедуры-обёртки для заданий
--------------------------------------------------------------------------------
create or replace procedure p_run_insert_orders_fin_monitoring is
  v_log_id number;
begin
  p_log_job_start('orders_fin_monitoring_job', v_log_id);
  p_insert_orders_fin_monitoring;
  p_log_job_end(v_log_id, 'SUCCESS');
exception
  when others then
    p_log_job_end(v_log_id, 'FAILED', sqlerrm);
    raise;
end p_run_insert_orders_fin_monitoring;
/

create or replace procedure p_run_update_estimate_depends is
  v_log_id number;
begin
  p_log_job_start('update_estimates_depend_job', v_log_id);
  --обновим ссылки на стандартные изделия
  p_update_estimate_items_ref;
  --обновим в смета дату изменения влияющих смет 
  p_update_estimates_depend_dt;
  --обновим признаки готовности все влияющих смет для данной 
  p_upd_estimates_infl_batch;
  p_log_job_end(v_log_id, 'SUCCESS');
exception
  when others then
    p_log_job_end(v_log_id, 'FAILED', sqlerrm);
    raise;
end p_run_update_estimate_depends;
/

create or replace procedure p_run_refresh_vm_or_std_items is
  v_log_id number;
begin
  p_log_job_start('vm_or_std_items_job', v_log_id);
  dbms_mview.refresh('vm_or_std_items', 'c');
  p_log_job_end(v_log_id, 'SUCCESS');
exception
  when others then
    p_log_job_end(v_log_id, 'FAILED', sqlerrm);
    raise;
end p_run_refresh_vm_or_std_items;
/




--==============================================================================
--==============================================================================
--==============================================================================

--------------------------------------------------------------------------------
--таблицы для использования в процедурах, выполняющихся в заданиях
--(отмечает время последнего выполнения задания, все делается вручную)
create table scheduler_sync_control (
  job_name    varchar2(30)  primary key,
  last_run_at date          not null
);

insert into scheduler_sync_control(job_name, last_run_at) values ('p_update_estimates_depend_dt', date '1900-01-01');

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Таблица для логирования заданий шедулера
--------------------------------------------------------------------------------

create table adm_oracle_scheduler_log (
  id                   number primary key,
  job_name             varchar2(100),
  start_time           timestamp(6),
  end_time             timestamp(6),
  status               varchar2(20),          -- RUNNING, SUCCESS, FAILED
  error_message        varchar2(4000),
  duration_min         number(10,1),          -- продолжительность в минутах с десятыми
  start_date_readable  varchar2(30),
  end_date_readable    varchar2(30)
);

comment on table adm_oracle_scheduler_log is 'Лог выполнения заданий DBMS_SCHEDULER';
comment on column adm_oracle_scheduler_log.job_name is 'Имя задания (job_name)';
comment on column adm_oracle_scheduler_log.status is 'Статус выполнения: RUNNING, SUCCESS, FAILED';
comment on column adm_oracle_scheduler_log.duration_min is 'Продолжительность выполнения в минутах (с десятыми)';

create sequence sq_adm_oracle_scheduler_log start with 1 increment by 1;


--------------------------------------------------------------------------------
-- Процедуры логирования (с автономной транзакцией)
--------------------------------------------------------------------------------
create or replace procedure p_log_job_start(
  p_job_name in varchar2,
  p_log_id   out number
) is
  pragma autonomous_transaction;
begin
  insert into adm_oracle_scheduler_log (
    id, job_name, start_time, status,
    start_date_readable
  ) values (
    sq_adm_oracle_scheduler_log.nextval,
    p_job_name,
    systimestamp,
    'RUNNING',
    to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS')
  )
  returning id into p_log_id;
  commit;
end p_log_job_start;
/

create or replace procedure p_log_job_end(
  p_log_id       in number,
  p_status       in varchar2,
  p_error_msg    in varchar2 default null
) is
  pragma autonomous_transaction;
begin
  update adm_oracle_scheduler_log
     set end_time = systimestamp,
         status = p_status,
         error_message = p_error_msg,
         end_date_readable = to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'),
         duration_min = round((extract(second from (systimestamp - start_time)) +
                               extract(minute from (systimestamp - start_time)) * 60 +
                               extract(hour from (systimestamp - start_time)) * 3600) / 60, 1)
   where id = p_log_id;
  commit;
end p_log_job_end;
/

--------------------------------------------------------------------------------
-- Очистка лога старше 7 дней
--------------------------------------------------------------------------------
create or replace procedure p_purge_scheduler_log is
begin
  delete from adm_oracle_scheduler_log
   where start_time < sysdate - 7;
  commit;
end p_purge_scheduler_log;
/

create or replace procedure p_run_purge_scheduler_log is
  v_log_id number;
begin
  p_log_job_start('purge_scheduler_log_job', v_log_id);
  p_purge_scheduler_log;
  p_log_job_end(v_log_id, 'SUCCESS');
exception
  when others then
    p_log_job_end(v_log_id, 'FAILED', sqlerrm);
    raise;
end p_run_purge_scheduler_log;
/

