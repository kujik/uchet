--------------------------------------------------------------------------------
--
-- –асчет мотивации сотрудников
--
--------------------------------------------------------------------------------

--таблица w_motivation_coefficients
--коэффициенты мотивации (критерии эффективности работы предпри€ти€).
--общий список, могут использоватьс€ в прив€зке к различным должност€м.
--
create table w_motivation_coefficients (
  id number(11) primary key,
  name varchar2(150) unique not null,    --наименование коэффициента   
  comm varchar2(4000),                   --комментарий 
  ids_value_setters varchar2(400)        --айди пользователей, которые могут задавать диапазоны и значени€ коэффициента  
);

create unique index idx_w_motivation_coefficients_name on w_motivation_coefficients(lower(name));

create sequence sq_w_motivation_coefficients nocache start with 1;

create or replace trigger trg_w_motivation_coefficients_bi_r 
  before insert on w_motivation_coefficients for each row
begin
  :new.id := sq_w_motivation_coefficients.nextval;  
end;
/

  
--------------------------------------------------------------------------------
--таблица w_motivation_coefficients
--значений коэффициентов и их интервалы применительно к оценке работы сотрудника на каждый календарный мес€ц 
--
create table w_motivation_coefficient_values (
  id number(11) primary key,
  id_coefficient number(11),       --айди коэффициента в родительской таблице
  dt date,                         --дата (всегда 1е число мес€ца)
  k1 number,                       --начальное значение коэффициента дл€ оценки "отлично"
  k2 number,                       --начальное значение коэффициента дл€ оценки "хорошо" 
  k3 number,                       --начальное значение коэффициента дл€ оценки "удовлетворительно"
  k4 number,                       --начальное значение коэффициента дл€ оценки "зона роста"
  value number,                    --рассчитанное значение коэффициента на данную дату
  constraint fk_w_motivation_coefficient_values foreign key (id_coefficient) references w_motivation_coefficients(id) 
);

create unique index uk_w_motivation_coefficient_values on w_motivation_coefficient_values(id_coefficient, dt);

create sequence sq_w_motivation_coefficient_values nocache start with 1;

create or replace trigger trg_w_motivation_coefficient_values_bi_r 
  before insert on w_motivation_coefficient_values for each row
begin
  :new.id := sq_w_motivation_coefficient_values.nextval;  
end;
/

--------------------------------------------------------------------------------
--таблица w_motivation_coefficients
--значений коэффициентов и их интервалы применительно к оценке работы сотрудника на каждый календарный мес€ц 
--
create table pk_w_motivation_coefficient_for_job (
  id_coefficient number(11),       --айди коэффициента в родительской таблице
  dt date,                         --дата (всегда 1е число мес€ца)
  pos number,
  constraint pk_pk_w_motivation_coefficient_for_job primary key (id_coefficient, id_job, dt) 
);
