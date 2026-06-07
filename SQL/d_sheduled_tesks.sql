create table sync_control (
  job_name    varchar2(30)  primary key,
  last_run_at date          not null
);

insert into sync_control (job_name, last_run_at) values ('p_update_estimates_depend_dt', date '1900-01-01');

begin
  dbms_scheduler.drop_job('update_estimates_depend_job');
  dbms_scheduler.create_job (
    job_name        => 'update_estimates_depend_job',
    job_type        => 'plsql_block',
    job_action      => 'begin p_update_estimates_depend_dt; end;',
    start_date      => trunc(systimestamp) + 1/24,  -- первый запуск завтра в 01:00
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
    --start_date      => trunc(systimestamp) + 5/24 + 15/(24*60),  
    repeat_interval => 'freq=daily; byhour=5; byminute=15; bysecond=0;', 
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
    --start_date      => trunc(systimestamp) + 5/24 + 15/(24*60),  
    repeat_interval => 'freq=daily; byhour=2; byminute=15; bysecond=0;', 
    enabled         => true,
    comments        => 'обновление vm_or_std_items'
  );
end;
/


select job_name, enabled, state, next_run_date, last_start_date from dba_scheduler_jobs where job_name = 'UPDATE_DEPEND_DATES_JOB';

--прервать задание
exec dbms_scheduler.stop_job('vm_orders_fin_monitoring_job');
--¬ключить/выключить: 
exec dbms_scheduler.enable('update_estimates_depend_job'); 
exec dbms_scheduler.disable('update_estimates_depend_job');
--апустить вручную: 
exec dbms_scheduler.run_job('update_estimates_depend_job', false);
--”далить задание: 
exec dbms_scheduler.drop_job('update_estimates_depend_job');


--логи1
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'UPDATE_ESTIMATES_DEPEND_JOB' order by log_date desc;
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'VM_ORDERS_FIN_MONITORING_JOB' order by log_date desc;
select log_date, run_duration, status, additional_info from dba_scheduler_job_run_details where job_name = 'VM_OR_STD_ITEMS_JOB' order by log_date desc;









--------------------------------------------------------------------------------
create or replace procedure p_update_estimates_depend_dt is
-- процедура обновлени€ пол€ dt_changed_depend в таблице estimates
-- находит все сметы, которые завис€т от изменЄнных смет (через цепочку стандартных изделий)
-- и проставл€ет им текущую дату в dt_changed_depend
-- запускаетс€ по расписанию (раз в 5 мин)
  v_last_run date;
  v_now      date := sysdate;
  v_root_id  estimates.id%type;
  cursor c_changed is
    select id from estimates where dt_changed > v_last_run;
  cursor c_deps(p_child_id number) is
    select distinct connect_by_root child_id as root_id
    from (
      select ei.id_estimate as parent_id, ei.id_dependent_estimate as child_id
      from estimate_items ei
      where ei.id_dependent_estimate is not null
    )
    start with child_id = p_child_id
    connect by nocycle prior parent_id = child_id;
begin
  -- получить врем€ последнего запуска (как выше)
  begin
    select last_run_at into v_last_run
      from sync_control
      where job_name = 'p_update_estimates_depend_dt';
  exception
    when no_data_found then
      insert into sync_control (job_name, last_run_at)
        values ('p_update_estimates_depend_dt', date '1900-01-01');
      commit;
      v_last_run := date '1900-01-01';
  end;

  for ch in c_changed loop
    for dep in c_deps(ch.id) loop
      update estimates
        set dt_changed_depend = v_now
        where id = dep.root_id
          and (dt_changed_depend is null or dt_changed_depend < v_now);
    end loop;
  end loop;

  update sync_control
    set last_run_at = v_now
    where job_name = 'p_update_estimates_depend_dt';

  commit;

exception
  when others then
    rollback;
    raise;
end p_update_estimates_depend_dt;
/




exec p_update_estimates_depend_dt;

  select last_run_at
    from sync_control
    where job_name = 'p_update_estimates_depend_dt';


select * from v_estimate where name = 'ѕримерочна€ основна€ с зеркалом 1220х1200х2100 мм'; --OZ.ѕ_ѕримерочна€ основна€ с зеркалом 1220х1200х2100 мм