
--данные зарплатной ведомости для конкретного работника из ведомости
--данные сопоставляются с турв по подразделению, айди работника, должности, расписания, организации, и табельному номеру
--alter table w_payroll_calc_item drop column personnel_number;
alter table w_payroll_calc_item add ors_pay1 number;
alter table w_payroll_calc_item add ors1 number;
alter table w_payroll_calc_item add period_hours_norm1 number;
alter table w_payroll_calc_item add hours_worked1 number;
alter table w_payroll_calc_item add overtime1 number;
alter table w_payroll_calc_item add total_pay1 number;
alter table w_payroll_calc_item add from_first_period number;
alter table w_payroll_calc_item add base_pay1 number;
alter table w_payroll_calc_item add base_pay2 number;
alter table w_payroll_calc_item add ext_pay1 number;
alter table w_payroll_calc_item add adjustments_total1 number;

create table w_payroll_calc_item(
  id number(11),
  id_payroll_calc number(11),     --айди зарплатной ведомости, в которую входит эта строка
  id_employee number(11),         --айди раболтника 
  id_job number(11),              --айди должности 
  id_schedule number(11),         --айди графика
  id_organization number(11),     --айди организации, в которой числится работник
  personnel_number varchar2(10),  --табельный номер 
  monthly_hours_norm number,      --норма за месяц, по данной строке табеля для работника
  period_hours_norm number,       --норма за период ведомости, по данной строке табеля для работника     
  hours_worked number,            --отработано по турв
  overtime number,                --количество часов переработки (приведенное)
  planned_pay number,             --плановое начисление
  fixed_pay number,               --постоянная часть
  variable_pay number,            --стимулирующая часть
  ors number,                     --оценка работы сотрудника, %
  ors_pay number,                 --оценка работы сотрудника, сумма, начисленная исходя из оценки
  base_pay number,                --итого рассчитано
  ext_pay number,                 --загружено из внешнего источника (рассчет сделки)
  overtime_pay number,            --выплаты за переработки 
  personal_pay number,            --персональная выплата
  daily_bonus number,             --ежедневные премии (не депремирование!) из турв
  extra_bonus number,             --дополнительная премия, вводится в ведомости
  night_pay number,               --выплата за ночные часы, вводится в ведомости
  milk_compensation number,       --выплата за молоко  
  non_work_pay number,            --оплата неотработанного вермени (ОТ/БЛ)
  penalty number,                 --депремирование
  correction number,              --ручная корректировка начисления, вводится в ведомости
  total_pay number,               --итого начислено 
  constraint pk_w_payroll_calc_item primary key (id),
  constraint fk_w_payroll_calc_i_own foreign key (id_payroll_calc) references w_payroll_calc(id) on delete cascade,
  constraint fk_w_payroll_calc_i_emp foreign key (id_employee) references w_employees(id),
  constraint fk_w_payroll_calc_i_job foreign key (id_job) references w_jobs(id),
  constraint fk_w_payroll_calc_i_sch foreign key (id_schedule) references w_schedules(id),
  constraint fk_w_payroll_calc_i_org foreign key (id_organization) references ref_sn_organizations(id)
);  

create table temp_w_payroll_calc as select * from w_payroll_calc;
create table temp_w_payroll_calc_item as select * from w_payroll_calc_item;
  
--drop sequence sq_w_payroll_calculations_item;
create sequence sq_w_payroll_calc_item start with 100000 nocache;

--create unique index idx_payroll_item_unique on payroll_item(id_division, id_worker, dt);
--create index idx_payroll_item_dt_job on payroll_item(dt, id_job);

create or replace trigger trg_w_payroll_calc_item_bi_r before insert on w_payroll_calc_item for each row
begin
  select nvl(:new.id, sq_w_payroll_calc_item.nextval) into :new.id from dual;
end;
   

--вью для элемента (записи по работнику в данном подразделении) зарплатных ведомостей
create or replace view v_w_payroll_calc_item as 
select
  i.*,
  s.code as schedulecode,
  s.code as schedule,
  --s.code || ' (' || to_char(i.period_work_hours_norm) || ')' as schedule,
  p.id_departament as id_target_departament,
  p.id_employee as id_target_employee,
  p.id_organization as id_target_organization,
  p.personnel_number as target_personnel_number,
  p.is_finalized,
  p.dt1,
  p.dt2,
  p.calc_method,
  p.overtime_method,
  --f_fio(e.f, e.i, e.o) as employee,
  --e.personnel_number,
  e.name as employee,
  --e.concurrent_employee,
  o.name as organization,
  d.name as departament,
  d.id_prod_area,
  a.shortname as prod_area_shortname,
  a.name as prod_area_name,
  j.name as job,
  0 as changed,
  null as temp
from
  w_payroll_calc_item i
  inner join w_payroll_calc p on i.id_payroll_calc = p.id
  left outer join w_departaments d on p.id_departament = d.id
  left outer join v_w_employees e on i.id_employee = e.id
  left outer join w_jobs j on i.id_job = j.id  
  left outer join w_schedules s on i.id_schedule = s.id 
  left outer join ref_production_areas a on d.id_prod_area = a.id
  left outer join ref_sn_organizations o on i.id_organization = o.id
;  

select id_employee, id_organization, personnel_number, employee, organization, personnel_number, total_pay, null as temp from v_w_payroll_calc_item where id_employee = 721 and id_organization = 1 and personnel_number = '488' and id_target_employee <> null;

--проверимм, нет ли задвоения мотивации (загруженных баллов)в одном подразделениии
--такая ситуация сейчас будет если были перехода работника внутри подразделения, во все строки загрузится одно число из хлс
WITH dups AS (
    SELECT t.dt1, t.departament, t.employee, t.ext_pay,
           COUNT(*) OVER (PARTITION BY id_target_departament, employee) AS cnt,
           MIN(nvl(ext_pay,-1)) OVER (PARTITION BY id_target_departament, employee) AS min_pay,
           MAX(nvl(ext_pay,-1)) OVER (PARTITION BY id_target_departament, employee) AS max_pay
    FROM v_w_payroll_calc_item t
    where dt1 = date '2026-02-16'
)
SELECT *
FROM dups
WHERE cnt > 1
  AND min_pay = max_pay
  and max_pay <> -1 
  AND min_pay IS NOT NULL;\
  
  
  
  create table w_payroll_transfer ( 
  id number(11),
  id_employee number(11),    --айди раболтника 
  id_organization number(11), --айди организации
  personnel_number varchar2(10),  --табельный номер 
  dt1 date,                  --дата начала ведомости, по полмесяца, как в турв
  dt2 date,                  --дата конца ведомости
  is_finalized number(1),    --период закрыт
  constraint pk_w_payroll_transfer primary key (id),
  constraint fk_w_payroll_transfer_empl foreign key (id_employee) references w_employees(id)
);

--уникальный индекс по подразделению/работнику/дате начала
--create unique index idx_w_payroll_transfer_uq on w_payroll_transfer(id_departament, id_employee, dt1);

create sequence sq_w_payroll_transfer start with 1000 nocache;

create or replace trigger trg_w_payroll_transfer_bi_r before insert on w_payroll_transfer for each row
begin
  select nvl(:new.id, sq_w_payroll_transfer.nextval) into :new.id from dual;
end;

--вью для журнала зарплатных ведомостей
create or replace view v_w_payroll_transfer as 
select
  p.*,
  case when p.is_finalized = 1 then 'Закрыта' else '' end as finalized,
  f_fio(e.f, e.i, e.o) as employee,
  o.name as organization
from
  w_payroll_transfer p,
  w_employees e,
  ref_sn_organizations o 
where
  p.id_employee = e.id (+)
  and p.id_organization = o.id (+)
;

alter table w_payroll_transfer_item add correction number; 
create table w_payroll_transfer_item(
  id number(11),
  id_payroll_transfer number(11),     --айди зарплатной ведомости, в которую входит эта строка
  id_employee number(11),         --айди раболтника 
  id_organization number(11),     --айди организации, в которой числится работник
  personnel_number varchar2(10),  --табельный номер
  is_concurrent number(1), 
  hours_worked number,            --отработано по турв
  overtime number,                --количество часов переработки (приведенное)
  total_pay number,               --итого начислено 
  ors_pay number,
  deduct_enf number,      -- удержание по исполнительному листу
  deduct_ndfl number,     -- НДФЛ
  pay_fss number,         -- выплата в ФСС (например, больничный)
  pay_adv number,         -- промежуточная (авансовая) выплата
  pay_card number,        -- перечислено на карту
  correction number,              --ручная корректировка начисления, вводится в ведомости
  pay_cash number,        -- итого к выдаче наличными  
  constraint pk_w_payroll_transfer_item primary key (id),
  constraint fk_w_payroll_transfer_i_own foreign key (id_payroll_transfer) references w_payroll_transfer(id) on delete cascade,
  constraint fk_w_payroll_transfer_i_emp foreign key (id_employee) references w_employees(id),
  constraint fk_w_payroll_transfer_i_org foreign key (id_organization) references ref_sn_organizations(id)
);  
  
--drop sequence sq_w_payroll_transferulations_item;
create sequence sq_w_payroll_transfer_item start with 100000 nocache;

--create unique index idx_payroll_item_unique on payroll_item(id_division, id_worker, dt);
--create index idx_payroll_item_dt_job on payroll_item(dt, id_job);

create or replace trigger trg_w_payroll_transfer_it_bi_r before insert on w_payroll_transfer_item for each row
begin
  select nvl(:new.id, sq_w_payroll_transfer_item.nextval) into :new.id from dual;
end;

--delete from w_payroll_transfer;
   

--вью для элемента (записи по работнику в данном подразделении) зарплатных ведомостей
create or replace view v_w_payroll_transfer_item as 
select
  i.*,
  p.dt1,
  p.dt2,
  p.id_employee as id_target_employee,
  e.name as employee,
  --e.is_concurrent,
  o.name as organization,
  --d.name as departament,
  0 as changed,
  null as temp
from
  w_payroll_transfer_item i,
  w_payroll_transfer p,
  v_w_employees e,
  ref_sn_organizations o
  --w_departaments d
where
  i.id_payroll_transfer = p.id and
  i.id_employee (+) = e.id and 
  i.id_organization = o.id (+) 
  --and p.id_departament (+) = d.id 
;     


--------------------------------------------------------------------------------
create table w_payroll_cash ( 
  id number(11),
  id_departament number(11), --айди подразделения
  id_employee number(11),    --айди раболтника 
  id_organization number(11), --айди организации
  personnel_number varchar2(10),  --табельный номер 
  dt1 date,                  --дата начала ведомости, по полмесяца, как в турв
  dt2 date,                  --дата конца ведомости
  is_finalized number(1),    --период закрыт
  constraint pk_w_payroll_cash primary key (id),
  constraint fk_w_payroll_cash_div foreign key (id_departament) references w_departaments(id),
  constraint fk_w_payroll_cash_empl foreign key (id_employee) references w_employees(id)
);



--уникальный индекс по подразделению/работнику/дате начала
--create unique index idx_w_payroll_cash_uq on w_payroll_cash(id_departament, id_employee, dt1);

create sequence sq_w_payroll_cash start with 1000 nocache;

create or replace trigger trg_w_payroll_cash_bi_r before insert on w_payroll_cash for each row
begin
  select nvl(:new.id, sq_w_payroll_cash.nextval) into :new.id from dual;
end;

--вью для журнала зарплатных ведомостей
create or replace view v_w_payroll_cash as 
select
  p.*,
  case when p.is_finalized = 1 then 'Закрыта' else '' end as finalized,
  d.name as departament,  
  f_fio(e.f, e.i, e.o) as employee,
  o.name as organization,
  a.shortname as prod_area_shortname,
  a.name as prod_area_name,
  d.code,
  a.shortname || ' - ' || decode(d.is_office, 1, 'офис', 'цех') || '' as area
from
  w_payroll_cash p,
  w_departaments d,
  w_employees e,
  ref_sn_organizations o,
  ref_production_areas a 
where
  p.id_employee = e.id (+)
  and p.id_departament = d.id
  and p.id_organization = o.id (+)
  and d.id_prod_area = a.id
;

select * from v_w_payroll_cash;


create table w_payroll_cash_item(
  id number(11),
  id_payroll_cash number(11),     --айди зарплатной ведомости, в которую входит эта строка
  id_employee number(11),         --айди раболтника 
  id_job number(11),              --айди должности 
  id_organization number(11),     --айди организации, в которой числится работник
  personnel_number varchar2(10),  --табельный номер
  pay_cash number,                --итого к выдаче наличными
  banknotes varchar2(400),        --купюры       
  constraint pk_w_payroll_cash_item primary key (id),
  constraint fk_w_payroll_cash_i_own foreign key (id_payroll_cash) references w_payroll_cash(id) on delete cascade,
  constraint fk_w_payroll_cash_i_emp foreign key (id_employee) references w_employees(id),
  constraint fk_w_payroll_cash_i_job foreign key (id_job) references w_jobs(id),
  constraint fk_w_payroll_cash_i_org foreign key (id_organization) references ref_sn_organizations(id)
);  
  
create sequence sq_w_payroll_cash_item start with 100000 nocache;

--create unique index idx_payroll_item_unique on payroll_item(id_division, id_worker, dt);
--create index idx_payroll_item_dt_job on payroll_item(dt, id_job);

create or replace trigger trg_w_payroll_cash_it_bi_r before insert on w_payroll_cash_item for each row
begin
  select nvl(:new.id, sq_w_payroll_cash_item.nextval) into :new.id from dual;
end;

create or replace view v_w_payroll_cash_item as 
select
  i.*,
  p.dt1,
  p.dt2,
  e.name as employee,
  j.name as job,
  o.name as organization,
  0 as changed,
  null as temp
from
  w_payroll_cash_item i,
  w_payroll_cash p,
  v_w_employees e,
  w_jobs j,
  ref_sn_organizations o
where
  i.id_payroll_cash = p.id and
  i.id_employee (+) = e.id and 
  i.id_job = j.id and  
  i.id_organization = o.id (+)
;


