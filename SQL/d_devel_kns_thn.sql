--------------------------------------------------------------------------------
--таблица видов работы для журнала рахработки проектов (кнс)
--alter table ref_develtypes add hours number;
create table ref_develtypes (
  id number(11),
  developer number,                   --1 - кнс, 2 - тхн
  name varchar2(400),                 --наименование вида разработки
  hours number,                       --отведенное на работу время в часах
  constraint pk_ref_develtypes primary key (id)
);  

create unique index uq_ref_develtypes_name on ref_develtypes(developer, lower(name));

create sequence sq_ref_develtypes nocache start with 1;

create or replace trigger trg_ref_develtypes_bi_r
  before insert on ref_develtypes for each row
begin
  select sq_ref_develtypes.nextval into :new.id from dual;
end;
/

--в коде в TOrder.OrderItemsToDevel сделана жесткая проверка на id = 5 !!!

/*
insert into ref_develtypes (name) values ('Просчет');
insert into ref_develtypes (name) values ('Тендер');
insert into ref_develtypes (name) values ('Разработка');
insert into ref_develtypes (name) values ('Переработка');
insert into ref_develtypes (name) values ('Запуск');
insert into ref_develtypes (name) values ('Чертежи');
insert into ref_develtypes (name) values ('');
*/

--таблица журнала рахработки проектов (кнс)
--alter table j_development add developer number;
create table j_development (
  id number(11),
  developer number,                   --1 - кнс, 2 - тхн
  id_develtype number(11),      --вид разработки, из справочника
  slash varchar2(25),           --номер изделия /слеш/ - не обязательно
  project varchar2(400),        --проект, текстом  
  name varchar2(400),           --наименование разработки, тесктом
  dt_beg date,                  --дата начала разработки, автоматически
  dt_plan date,                 --планируемая дата окончания разработки
  dt_end date,                  --дата окончиния разработки, автоматически ставится при выборе статуса Готово
  id_status number(3),          --номер статуса, без таблицы (1=новый, 2=в работе, 3=остановлен, 4=на согласовании, 5=завис, 100=готово)         
  cnt number(11,1),             --сделка (мож быть например число панелей, или другие подобные величины, число)
  time number(11,1),            --время работы по проекту, в часах !!!
  id_kns number(11),            --айди конструктора !!!
  comm varchar2(4000),          --комментарий
  constraint pk_j_development primary key (id),
  constraint fk_j_development_id_develtype foreign key (id_develtype) references ref_develtypes(id)
);   
  
create  index idx_j_development_name on j_development(developer, name);
create  index idx_j_development_project on j_development(developer, project);

create sequence sq_j_development nocache;

create or replace trigger trg_j_development_bi_r
  before insert on j_development for each row
begin
  select sq_j_development.nextval into :new.id from dual;
end;
/

create or replace view v_j_development as 
select
  d.*,
  t.name as develtype,
  t.hours,
  u.name as constr,
  decode(d.id_status, 1, 'новый', 2, 'в работе', 3, 'остановлен', 4, 'на согласовании', 5, 'завис', 100, 'готово', '') as status 
from
  j_development d,
  ref_develtypes t,
  adm_users u
where
  d.id_develtype = t.id (+) and
  u.id (+) = d.id_kns
;
