create table scheduler_sync_control (
  job_name    varchar2(30)  primary key,
  last_run_at date          not null
);

insert into scheduler_sync_control(job_name, last_run_at) values ('p_update_estimates_depend_dt', date '1900-01-01');

begin
  dbms_scheduler.drop_job('update_estimates_depend_job');
  dbms_scheduler.create_job (
    job_name        => 'update_estimates_depend_job',
    job_type        => 'plsql_block',
    job_action      => 'begin p_update_estimates_depend_dt; end;',
    --start_date      => trunc(systimestamp) + 1/24,  -- первый запуск
    repeat_interval => 'freq=minutely; interval=5',
    enabled         => true,
    comments        => 'обновление dt_changed_depend в estimates'
  );
end;
/
  
begin
  dbms_scheduler.drop_job('vm_orders_fin_monitoring_job');
  dbms_scheduler.create_job (
    job_name        => 'vm_orders_fin_monitoring_job',
    job_type        => 'plsql_block',
    job_action      => 'begin dbms_mview.refresh(''vm_orders_fin_monitoring'', ''c''); end;',
    --start_date      => trunc(systimestamp) + 5/24 + 18/(24*60),  
    repeat_interval => 'freq=daily; byhour=2; byminute=05; bysecond=0;', 
    enabled         => true,
    comments        => 'обновление vm_orders_fin_monitoring'
  );
end;
/

begin
  dbms_scheduler.drop_job('vm_or_std_items_job');
  dbms_scheduler.create_job (
    job_name        => 'vm_or_std_items_job',
    job_type        => 'plsql_block',
    job_action      => 'begin dbms_mview.refresh(''vm_or_std_items'', ''c''); end;',
    --start_date      => trunc(systimestamp) + 5/24 + 50/(24*60),  
    repeat_interval => 'freq=daily; byhour=2; byminute=30; bysecond=0;', 
    enabled         => true,
    comments        => 'обновление vm_or_std_items'
  );
end;
/


select job_name, enabled, state, next_run_date, last_start_date from dba_scheduler_jobs where job_name = 'UPDATE_DEPEND_DATES_JOB';

--прервать задание
exec dbms_scheduler.stop_job('vm_orders_fin_monitoring_job');
--Включить/выключить: 
exec dbms_scheduler.enable('update_estimates_depend_job'); 
exec dbms_scheduler.disable('update_estimates_depend_job');
--апустить вручную: 
exec dbms_scheduler.run_job('vm_or_std_items_job', false);
--Удалить задание: 
exec dbms_scheduler.drop_job('update_estimates_depend_job');


--логи
--во время выполнения задания информация в логе еще не появится!
select sysdate from dual;
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'UPDATE_ESTIMATES_DEPEND_JOB' order by log_date desc;
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'VM_ORDERS_FIN_MONITORING_JOB' order by log_date desc;
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'VM_OR_STD_ITEMS_JOB' order by log_date desc;













exec p_update_estimates_depend_dt;

  select last_run_at
    from sync_control
    where job_name = 'p_update_estimates_depend_dt';


select * from v_estimate where name = 'Примерочная основная с зеркалом 1220х1200х2100 мм'; --OZ.П_Примерочная основная с зеркалом 1220х1200х2100 мм