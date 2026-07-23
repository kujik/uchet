Alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;

--------------------------------------------------------------------------------







--------------------------------------------------------------------------------
-- Справочник покупателей
--alter table ref_customers add priority varchar2(1) default 'C';
--alter table ref_customers drop column priority;
create table ref_customers (
  id number(11),
  name varchar2(400) not null,
  wholesale number(1),              --1=оптовый клиент
  priority varchar2(1) default 'C', --приоритет (A,B,C, А - наивысший) 
  active number(1) default 1, 
  constraint pk_ref_customers primary key (id)
);

create unique index idx_ref_customers_name on ref_customers(lower(name));

create sequence sq_ref_customers nocache;

create or replace trigger trg_ref_customers_bi_r
  before insert on ref_customers for each row
begin
  select sq_ref_customers.nextval into :new.id from dual;
end;
/

--контакты покупателей
create table ref_customer_contact (
  id number(11),
  id_customer number(11) not null,
  name varchar2(400) not null,                 --произвольное имя контекта, не можжет быть пустым
  contact varchar2(400),                       --телефон, емайл и т.п. - произвольная строка
  active number(1) default 1, 
  constraint pk_ref_customer_contact primary key (id),
  constraint fk_ref_customer_contact foreign key (id_customer) references ref_customers(id) on delete cascade
);

create unique index idx_ref_customer_contact on ref_customer_contact(id_customer, lower(name));

create sequence sq_ref_customer_contact nocache;

create or replace trigger trg_ref_customer_contact_bi_r
  before insert on ref_customer_contact for each row
begin
  select sq_ref_customer_contact.nextval into :new.id from dual;
end;
/

--юридические организации покупателя
create table ref_customer_legal (
  id number(11),
  id_customer number(11) not null,
  legalname varchar2(400) not null,   --юридическое название 
  inn varchar2(12),                   --ИНН 
  active number(1) default 1, 
  constraint pk_ref_customer_legal primary key (id),
  constraint fk_ref_customer_legal foreign key (id_customer) references ref_customers(id) on delete cascade
);

create unique index idx_ref_customer_legal on ref_customer_legal(id_customer, lower(legalname));

create sequence sq_ref_customer_legal nocache;

create or replace trigger trg_ref_customer_legal_bi_r
  before insert on ref_customer_legal for each row
begin
  select sq_ref_customer_legal.nextval into :new.id from dual;
end;
/


create or replace procedure p_add_customer
--возвращает айди покупателя, его контакта, и юридической информации по переданным текстовым полям
--если нет вообще записи покупателя или каких-то ее подчиненных данных, то создает их
--если запись была неактивна то делает ее активной
--имя контакта и юридическое наименование уникальны, если изменится напр ИНН, то он будет заменен в строке юр. лица, а не добавлена запись
(
  customernamenew varchar2,
  contactnamenew varchar2,
  contactnew varchar2,
  legalnamenew varchar2,
  innnew varchar2,
  id_customer out number,
  id_contact out number,
  id_legal out number
)
is
  idc number;
  idm number;
  idl number;
  idca number;
  idma number;
  idla number;
  st varchar(400);
--  id_customer  number;
--  id_contact  number;
--  id_legal  number;
begin
   select max(id), max(active) into idc, idca from ref_customers where lower(name) = lower(customernamenew);
   if idc is null then
     insert into ref_customers (name) values (customernamenew) returning id into idc;
   else 
     if idca <> 1 then update ref_customers set active = 1 where id = idc; end if;
   end if;
   id_customer := idc;
--return;   
   if contactnamenew is not null then
     select max(id), max(active), max(contact) into idm, idma, st from ref_customer_contact where id_customer = idc and lower(name) = lower(contactnamenew);
     if idm is null then
       insert into ref_customer_contact (id_customer, name, contact, active) values (idc, contactnamenew, contactnew, 1) returning id into idm;
     else 
       if idma <> 1 or st is null or st <> contactnew then update ref_customer_contact set active = 1, contact = contactnew where id = idm; end if;
     end if;
     id_contact := idm;
   else
     id_contact := null;
   end if;
   if legalnamenew is not null then
     select max(id), max(active), max(inn) into idl, idla, st from ref_customer_legal where id_customer = idc and lower(legalname) = lower(legalnamenew);
     if idl is null then
       insert into ref_customer_legal (id_customer, legalname, inn, active) values (idc, legalnamenew, innnew, 1) returning id into idl;
     else 
       if idla <> 1 or st is null or st <> innnew then update ref_customer_legal set active = 1, inn = innnew where id = idl; end if;
     end if;
     id_legal := idl;
   else
     id_legal := null;
   end if;
end;
/  

--select f_add_customer('test1', '','','','',:a,:b,:c) from dual;
declare
  a number;
  b number;
  c number;
begin  
--  p_add_customer('test1', 'test1-man1','test1-contact11','legalnamenew','innnew2', a, b, c);
--  p_add_customer('АО "Лотереи Москвы"', 'Андрей','test1-contact11','АО "Лотерии Москвы"','innnew4', a, b, c);
--select id, active, inn from ref_customer_legal where id_customer = 21 and lower(legalname) = lower('АО "Лотерии Москвы"');
end;
/

--select id, active from ref_customers where lower(name) = lower('АО "Лотереи Москвы"');
select id, active, inn from ref_customer_legal where id_customer = 21 and lower(legalname) = lower('АО "Лотерии Москвы"');


--------------------------------------------------------------------------------
-- справочник Причины рекламаций
create table ref_complaint_reasons(
  id number(11),
  name varchar2(400),        --причина
  active number(1),          --признак активности
  constraint pk_ref_complaint_reasons primary key (id)
);

--уникальность без учета регистра
create unique index idx_ref_complaint_reasons_name on ref_complaint_reasons(lower(name));

create sequence sq_ref_complaint_reasons nocache start with 100;

create or replace trigger trg_ref_complaint_reasons_bi_r
  before insert on ref_complaint_reasons for each row
begin
  if :new.id is null then
    select sq_ref_complaint_reasons.nextval into :new.id from dual;
  end if;
end;
/


--------------------------------------------------------------------------------
-- справочник Причины задержки заказов в производстве
create table ref_delayed_prod_reasons(
  id number(11),
  name varchar2(400),        --причина
  active number(1),          --признак активности
  constraint pk_ref_delayed_prod_reasons primary key (id)
);

--уникальность без учета регистра
create unique index idx_ref_delayed_prod_reasons_n on ref_delayed_prod_reasons(lower(name));

create sequence sq_ref_delayed_prod_reasons nocache start with 100;

create or replace trigger trg_ref_delayed_prod_rsn_bi_r
  before insert on ref_delayed_prod_reasons for each row
begin
  if :new.id is null then
    select sq_ref_delayed_prod_reasons.nextval into :new.id from dual;
  end if;
end;
/

--------------------------------------------------------------------------------
-- справочник Причины неприемки изделия ОТК
--drop  table ref_otc_reject_reasons cascade constraints;
--drop index idx_ref_otc_reject_reasons;
--d-rop sequence sq_ref_otc_reject_reasons;
--drop trigger trg_ref_otc_reject_rsn_bi_r;
create table ref_otk_reject_reasons(
  id number(11),
  name varchar2(400),        --причина
  active number(1),          --признак активности
  constraint pk_ref_otk_reject_reasons primary key (id)
);

--уникальность без учета регистра
create unique index idx_ref_otk_reject_reasons_n on ref_otk_reject_reasons(lower(name));

create sequence sq_ref_otk_reject_reasons nocache start with 100;

create or replace trigger trg_ref_otk_reject_rsn_bi_r
  before insert on ref_otk_reject_reasons for each row
begin
  if :new.id is null then
    select sq_ref_otk_reject_reasons.nextval into :new.id from dual;
  end if;
end;
/

select id, dt, qnt, id_reason, comm 
    , (select max(name) from ref_otk_reject_reasons where id = id_reason) reason
    from or_otk_rejected where id_order_item = 1205 order by dt;



--------------------------------------------------------------------------------
-- Справочник стандартных проектов
-- Содержит только наименование и признак активности
create table or_projects (
  id number(11),
  name varchar2(400),
  active number(1) default 1, --признак активности
  constraint pk_or_projects primary key (id)
);

create unique index idx_or_projects_name on or_projects(lower(name));

create sequence sq_or_projects nocache;

create or replace trigger trg_or_projects_bi_r
  before insert on or_projects for each row
begin
  select sq_or_projects.nextval into :new.id from dual;
end;
/


--------------------------------------------------------------------------------
-- Справочник стандартных форматов
-- ТШ,КБб ...
alter  table or_formats add targets varchar2(400);
create table or_formats (
  id number(11),
  name varchar2(400),        --наименование проекта
  targets varchar2(400),     --назначения (буква, соответствующая папке в ИТМ), через запятую 
  active number(1), --признак активности
  constraint pk_or_formats primary key (id)
);

create unique index idx_or_formats_name on or_formats(lower(name));

create sequence sq_or_formats nocache;

create or replace trigger trg_or_formats_bi_r
  before insert on or_formats for each row
begin
  if :new.id is null then
    select sq_or_formats.nextval into :new.id from dual;
  end if;
end;
/

insert into or_formats (name, active) values ('ТШ', 1);
insert into or_formats (id, name, active) values (0, 'Общий', 1);
update or_formats set active = 0 where id not in (select distinct id_format from orders where dt_beg >= date '2026-01-01');
update or_formats set active = 1;

--------------------------------------------------------------------------------
-- Справочник типов смет для стандартных форматов
--Пооизводство, Отгрузка, РЦ к формату or_formats КБ например...
--alter table or_format_estimates drop column prefix;
--alter table or_format_estimates add prefix varchar2(20);
create table or_format_estimates (
  id number(11),
  id_format number(11),
  name varchar2(400) not null,        --наименование проекта
  prefix varchar2(20),                --префикс для итм, для отгрузочного паспорта 
  --prefix_prod varchar2(20),           --префикс для итм, для производственного паспорта
  --is_semiproduct number(1) default 0, --это группа полуфабрикатов
  type number(1),                     --0 - производственный, 1 - отгрузочный, 2 - п/ф
  active number(1),                   --признак активности
  constraint pk_or_format_estimates primary key (id),
  constraint fk_or_format_estimates_f foreign key (id_format) references or_formats(id)
);

create unique index idx_or_format_estimates_name on or_format_estimates(id_format, lower(name));
create unique index idx_or_format_estimates_prefix on or_format_estimates(lower(prefix));

create sequence sq_or_format_estimates nocache;

create or replace trigger trg_or_format_estimates_bi_r
  before insert on or_format_estimates for each row
begin
  if :new.id is null then
    select sq_or_format_estimates.nextval into :new.id from dual;
  end if;
end;
/

create or replace view v_or_format_estimates as
select
  fe.*,
  decode(type, 0, 'производственное изделие', 1, 'отгрузочное изделие', 2, 'полуфабрикат') as type_name
from  
  or_format_estimates fe
;     



--------------------------------------------------------------------------------
alter table orders drop column status;

--alter table orders add id_or_reference number(11);
--alter table orders add id_or_reference number(11);

update orders set id_type2 = 117 where id_type = 1 and id_type2 is null;
update orders set id_type2 = 106 where id_type = 2 and id_type2 is null;

alter table orders add id_launched_by number(11);
alter table orders add constraint fk_id_launched_by foreign key (id_launched_by) references adm_users(id);
alter table orders add id_or_reference number(11);
alter table orders add constraint fk_id_or_reference foreign key (id_or_reference) references orders(id);
alter table orders add id_status number(2) default 1;
--update orders set id_status = 3;
alter table orders add order_number_customer varchar2(400);
alter table orders add basis_text varchar2(4000);

alter table orders add dt_start date;
update orders set dt_start = dt_beg;
--alter table orders add is_wholesale number(1) default 0;
alter table orders add nds_rate number default 0;
update orders set nds_rate = ndsd;



--alter table orders add constraint fk_orders_id_type2 foreign key (id_type2) references order_types(id);
--alter table orders add constraint fk_orders_id_reglament foreign key (id_reglament) references order_reglaments(id);
--alter table orders drop column id_complaint_reasons cascade constraints;
create table orders (
  id number(11),
  id_itm number(11) unique,
  sync_with_itm number(1) default 1, --если 1, то синхронизируем заказа с ИТМ
  id_or_format_estimates number(11), --айди типа стандартной сметы 
  --id_complaint_reasons number(11),   --айди причины рекламации
  year number(4),                    -- год  (2023)
  prefix varchar(10),                -- префикс заказа (М, СГ...)
  num number(4),                     -- номер заказа 
  ornum varchar(16) unique,          -- полный номер заказа СГ230013 
  templatename varchar2(400),        -- название шаблона, только для шаблонов
  id_status number(2) default 1,     -- стутус заказа (1 - на оформлении, 2 - проведен, 3 - запущен в работу)
  basis_text varchar2(4000),         -- основание (текстовое мемо-0поле) 
  area number(1) default 0,          -- производственная площадка (0 - ПЩ, 1 - Инженерный)
  estimatepath varchar2(400),        -- путь к сметам для стандартных шаблонов 
  cashtype number(1),                -- 2 - наличные, 1 - безнал
  wholesale number(1),               -- 2 - розница, 1 - опт
  project varchar2(400),             -- название проекта
  address varchar2(400),             -- адрес отгруузки 
  account varchar2(400),             -- счет
  order_number_customer varchar2(400),-- номер заказа клиента 
  id_format number(11),              -- айди формата паспорта (0 - общий, Х - КБ ...)
  id_target number(11),
  target varchar2(40),               -- подпапка в стандартных проектах итм (П - производство, остальные берутся из справочника стандартных форматов) 
  id_type number(1),                 -- 1 - новый, 2 рекламация, 3 эксперимент 
  id_type2 number,                   -- тип заказа из справочника "типы заказов"
  id_reglament number(11), 
  or_reference varchar(16),          -- номер заказа, по которому рекламация, в виде текста 
  id_manager number(11),             -- айди человека, оформившего заказ
  id_launched_by number(11),         -- айди человека, запустившего заказ в работу
  dt_beg date,                       -- дата создания паспорта
  dt_otgr date,                      -- планируемая дата отгрузки
  dt_montage_beg date,               -- плановая дата начала монтажа
  dt_montage_end date,               -- плановая дата окончания монтажа
  dt_change date,                    -- дата изменения паспорта 
  id_organization number(11),        -- айди своей организации 
  id_customer number(11),            -- айди покупателя
  id_customer_contact number(11),    -- айди контактного лица покупателя
  id_customer_org number(11),        -- айди юридического лица покупателя
  ndsd number(5,3),                  -- ндс для вычета (если ндс 20% то будет здесь 1.2) 
  cost number(12,2),                 -- сумма заказа
  cost_nds number(12,2),             -- сумма ндс в заказе НЕ ИСПОЛЬЗУЕМ
  cost_wo_nds number(12,2),          -- сумма заказа без ндс
  cost_av number(12,2),              -- сумма аванса
  cost_i_0 number(12,2),               -- стоимость изделий начальная (без скидки и наценки)
  cost_d_0 number(12,2),               -- стоимость доставки
  cost_m_0 number(12,2),               -- стоимость монтажа
  cost_a_0 number(12,2),               -- стоимость покупных изделий
  cost_i number(12,2),               -- стоимость изделий (с учетом скидки и наценки)
  cost_i_nosgp number(12,2),         -- стоимость изделий не с сгп (кроме д/к, с учетом скидки/наценки)
  cost_d number(12,2),               -- стоимость доставки
  cost_m number(12,2),               -- стоимость монтажа
  cost_a number(12,2),               -- стоимость покупных изделий
  m_i number(12,2),               -- наценка для изделий в процентах
  m_d number(12,2),               -- наценка для доставки
  m_m number(12,2),               -- наценка для монтажа
  m_a number(12,2),               -- наценка для покупных изделий
  d_i number(12,2),               -- скидка для изделий в процентах
  d_d number(12,2),               -- скидка для доставки
  d_m number(12,2),               -- скидка для монтажа
  d_a number(12,2),               -- скидка для покупных изделий
  discount number(12,2),             -- сумма скидки НЕ используем
  comm varchar(4000),                -- произвольный комментарий к заказу                           
  ch varchar(4000),                  -- изменения, сделанные в заголовке заказа, имена контролов через запятую   
  ch_comm varchar(4000),             -- изменения, сделанные в заказе, в текстовом виде   
  path varchar2(400),                -- наименование каталога заказа на Z
  in_archive number(1),              -- 1 - заказа перемещен в архив 
  dt_end date,                       -- дата закрытия заказа
  dt_end_copy date,                  -- копия даты закрытия, для ее восстановления при временной отмене завершения
  dt_end_manager date,               -- дата завершения заказа менеджером
  dt_aggr_estimate date,             -- дата создания общей сметы по заказу, для  снабжения 
  dt_complete_estimate date,         -- дата создания общей сметы по заказу, для кладовщиков
  dt_to_prod date,                   -- дата поступлдения заказа в работу (выдача плитных материалов на склад пр-ва)
  dt_to_sgp date,                    -- дата поступления на сгп всего заказа (полные количества всех изделия) 
  dt_from_sgp date,                  -- дата отгрузки с сгп всего заказа  
  dt_upd_reg date,                   -- дата регистрации упд (внесение данныых по нему) 
  dt_upd date,                       -- дата УПД (из документа)
  dt_account date,                   -- дата счета
  dt_account_reg date,               -- дата регистрации счета 
  upd varchar2(20),                  -- номер УПД 
  pay number(12,2),                  -- суммарный платеж по заказу (поступление денег в кассу)
  pay_n number(12,2),                -- суммарный промежуточный платеж по заказу (по заказам Н)
  dt_cancel date,                    -- дата останоки/отмены заказа 
  attention number(3)  default 0,    -- признак внимания к ячеке (пока только комментарий - выделена цветом в паспорте)
  --qnt_boards_m2 number,              -- метраж плитных материалов 
  --qnt_edges_m number,                -- метраж кромки
  --qnt_panels_w_drill number,         -- количество панелей со сверловкой 
  has_prod number(1) default 0,      -- в составе заказа есть производственные материалы
  ids_order_properties varchar2(4000),  --айди свойств заказа через "," 
  active number(1) default 1,        -- используемтся (применяется только в шаблонах)    

  constraint pk_orders primary key (id),
  constraint fk_orders_format foreign key (id_format) references or_formats(id),
  constraint fk_orders_manager foreign key (id_manager) references adm_users(id),
  constraint fk_id_launched_by foreign key (id_launched_by) references adm_users(id),
  constraint fk_orders_organization foreign key (id_organization) references ref_sn_organizations(id),
  constraint fk_orders_customer foreign key (id_customer) references ref_customers(id),
  constraint fk_orders_customer_contact foreign key (id_customer_contact) references ref_customer_contact(id),
  constraint fk_orders_customer_org foreign key (id_customer_org) references ref_customer_legal(id),
  constraint fk_orders_estimates foreign key (id_or_format_estimates) references or_format_estimates(id),
  constraint fk_orders_id_type2 foreign key (id_type2) references order_types(id),
  constraint fk_orders_id_reglament foreign key (id_reglament) references order_reglaments(id)
  --constraint fk_orders_id_complaint_reasons foreign key (id_complaint_reasons) references ref_complaint_reasons(id) 
);

--create unique index idx_order_num on or_formats(lower(name));
create unique index idx_orders_templatename on orders(lower(templatename));
create index idx_orders_dt_beg on orders(dt_beg);
create index idx_orders_dt_end on orders(dt_end);
create index idx_orders_id_customer on orders(id_customer);
create index idx_orders_or_reference on orders(or_reference);
create index idx_orders_id_organization on orders(id_organization);
create index idx_orders_id_customer_contact on orders(id_customer_contact);
create index idx_orders_id_customer_org on orders(id_customer_org);
create index idx_orders_id_format on orders(id_format);
create index idx_orders_id_manager on orders(id_manager);
create index idx_orders_area on orders(area);
create index idx_orders_id_type2 on orders(id_type2);
create index idx_orders_ornum on orders(ornum);   -- для ob


create sequence sq_orders nocache;
create sequence sq_orders_template nocache;

create or replace trigger trg_orders_bi_r
  before insert on orders for each row
begin
  if (:new.id is null) and (:new.templatename is null) then
    select sq_orders.nextval into :new.id from dual;
  end if;
  if (:new.id is null) and (:new.templatename is not null) then
    select -sq_orders_template.nextval into :new.id from dual;
  end if;
end;
/

create or replace function f_order_getnewnum
--получим номер заказа из переданных даты (есть нулл то из текущей) и айди своей организации
--номер вида М230013
--последний 4 цифры получаем как максимальное существующее значение поля num в заказах для данного префикса
(
  dt date,
  id_org number
)
return varchar2
is
  p varchar2(10);
  y varchar2(10);
  n number(6);
begin
  select prefix into p from ref_sn_organizations where id = id_org;
  if dt is null then 
    select extract(year from SysDate) into y from dual;
  else 
    select extract(year from dt) into y from dual;
  end if;
  select nvl(max(num), 0) + 1 into n from orders where extract(year from dt_beg) = y and prefix = p;
  return p || substr(y, 3, 2) || substr('000000' || n, -4);
end;
/  

select nvl(max(num), 0) + 1 from orders where extract(year from dt_beg) = '20' || 23 and prefix = 'Ф';

select f_order_getnewnum(null, 1) from dual;



create or replace view v_orders as
with
  -- единая агрегация по позициям заказа (все показатели за один проход)
  order_items_agg as (
    select
      i.id_order,
      -- okns: количество уникальных kns
      count(distinct case when i.qnt > 0 and i.id_kns is not null and i.id_kns != -100 then i.id_kns end) as cnt_kns,
      -- othn: количество уникальных thn
      count(distinct case when i.qnt > 0 and i.id_thn is not null and i.id_thn != -100 then i.id_thn end) as cnt_thn,
      -- oknsdt: максимальная дата kns, количество заполненных dt_kns, общее количество kns
      max(case when i.qnt > 0 and i.id_kns is not null and i.id_kns != -100 then i.dt_kns end) as dt_kns_max,
      count(case when i.qnt > 0 and i.id_kns is not null and i.id_kns != -100 and i.dt_kns is not null then 1 end) as dt_kns_cnt,
      count(case when i.qnt > 0 and i.id_kns is not null and i.id_kns != -100 then 1 end) as cnt_kns_total,
      -- othndt: аналогично для thn
      max(case when i.qnt > 0 and i.id_thn is not null and i.id_thn != -100 then i.dt_thn end) as dt_thn_max,
      count(case when i.qnt > 0 and i.id_thn is not null and i.id_thn != -100 and i.dt_thn is not null then 1 end) as dt_thn_cnt,
      count(case when i.qnt > 0 and i.id_thn is not null and i.id_thn != -100 then 1 end) as cnt_thn_total,
      -- osn: количество позиций без dt_sn
      --count(case when i.qnt != 0 and i.dt_sn is null then 1 end) as qnt_sn_no,
      -- oxml: количество позиций без xml
      count(case when i.qnt != 0 and nvl(i.is_xml_loaded, 0) = 0 then 1 end) as qnt_xml_no,
      -- timemsqnt: агрегаты количества и материалов
      sum(case when i.qnt > 0 then 1 else 0 end) as qnt_slashes,
      sum(i.qnt) as qnt_items,
      sum(case when nvl(i.sgp, 0) = 1 then 0 else i.qnt end) - sum(i.qnt_to_sgp) as qnt_in_prod,
      sum(i.qnt_to_sgp) as qnt_to_sgp,
      sum(nvl(i.qnt_boards_m2, 0)) as qnt_boards_m2,
      sum(nvl(i.qnt_edges_m, 0)) as qnt_edges_m,
      sum(nvl(i.qnt_glass_m2, 0)) as qnt_glass_m2,
      sum(nvl(i.qnt_paint_kg, 0)) as qnt_paint_kg,
      sum(nvl(i.qnt_panels_w_drill, 0) * i.qnt) as qnt_panels_w_drill_all
    from order_items i
    group by i.id_order
  ),
  -- уникальные технологи для заказа (без row_number, просто distinct + listagg)
/*  thn_list as (
    select
      i.id_order,
      listagg(u.name, '; ') within group (order by u.name) as thn_names
    from (select distinct id_order, id_thn from order_items where qnt > 0 and id_thn is not null and id_thn != -100) i
    join adm_users u on u.id = i.id_thn
    group by i.id_order
  ),
  -- уникальные конструкторы
  kns_list as (
    select
      i.id_order,
      listagg(u.name, '; ') within group (order by u.name) as kns_names
    from (select distinct id_order, id_kns from order_items where qnt > 0 and id_kns is not null and id_kns != -100) i
    join adm_users u on u.id = i.id_kns
    group by i.id_order
  ),
 */
  -- рекламации
  complaints_list as (
    select
      o.id_order,
      listagg(r.name, '; ') within group (order by r.name) as complaints_names
    from order_complaints o
    join ref_complaint_reasons r on r.id = o.id_complaint_reason
    group by o.id_order
  )
-- основной запрос
select
  o.*,
  ro.name as organization,
  decode(o.id_status, 1, 'на оформлениии', 2, 'проведен', 3, 'запущен в работу', '') as status,
  rc.name as customer,
  rcc.name as customerman,
  rcc.contact as customercontact,
  rcl.legalname as customerlegal,
  rcl.inn as customerinn,
  au.name as managername,
  au2.name as launched_by_name,
  case
    when o.id_type2 is not null then ot.name
    else case
      when o.id_type = 1 then 'Новый'
      when o.id_type = 2 then 'Рекламация'
      when o.id_type = 3 then 'Эксперимент'
      else ''
    end
  end as typename,
  orr.name as reglament,
  case when (o.id_type = 2) or (ot.name like 'Рекламация%') then 1 else 0 end as is_complaint,
  pa.shortname as area_short,
  decode(o.wholesale, 1, 'опт', 2, 'розница', '') as wholesalename,
  f.name as format,
  ob.dt_beg as ref_dt_beg,
  ob.dt_otgr as ref_dt_otgr,
  case when o.cashtype = 1 and o.account is null then 0 else o.cashtype end as cashtypeex,
  case
    when o.cashtype = 2 then 'наличные'
    when o.cashtype = 1 and o.account is null then 'безнал (нет счета)'
    when o.cashtype = 1 and o.account is not null then 'безнал'
    else ''
  end as cashtypename,
  case
    when o.cashtype = 2 then 'наличные'
    when o.cashtype = 1 and o.account is null then 'безнал (нет счета)'
    when o.cashtype = 1 and o.account is not null then o.account
    else ''
  end as cashtype_account,
  case when o.cashtype = 1 and o.account is null then 0 else o.cashtype end as cashtype_add,
  round(nvl(o.cost_i, 0) / o.ndsd, 2) as cost_i_wo_nds,
  round(nvl(o.cost_i_nosgp, 0) / o.ndsd, 2) as cost_i_nosgp_wo_nds,
  round(nvl(o.cost_a, 0) / o.ndsd, 2) as cost_a_wo_nds,
  round(nvl(o.cost_d, 0) / o.ndsd, 2) as cost_d_wo_nds,
  round(nvl(o.cost_m, 0) / o.ndsd, 2) as cost_m_wo_nds,
  case when o.dt_cancel is null then 0 else 1 end as cancel,
  o.dt_beg + trunc(((o.dt_otgr - o.dt_beg) / 2)) as dt_pnr,
  cl.complaints_names as complaints,
  --tl.thn_names as thn,
  case when nvl(agg.cnt_thn, 0) = 0 then '' else '[технолог]' end as to_thn,
  --kl.kns_names as kns,
  case when nvl(agg.cnt_kns, 0) = 0 then '' else '[конструктор]' end as to_kns,
  he.estimates,
  he.dt_estimate_max,
  --agg.qnt_sn_no,
  --decode(nvl(agg.qnt_sn_no, 0), 0, '+', '-') as sn_status,
  decode(nvl(agg.qnt_xml_no, 0), 0, '+', '-') as xml_status,
  case when agg.dt_thn_cnt = agg.cnt_thn_total then agg.dt_thn_max else null end as dt_thn_max,
  case when agg.dt_kns_cnt = agg.cnt_kns_total then agg.dt_kns_max else null end as dt_kns_max,
  trunc(o.dt_aggr_estimate - o.dt_beg) as days_aggr_estimate,
  --F_GetCostOrderItemsFromItm(o.id, null) as sum0,
  0 as sum0,
  sz.id_status as id_status_itm,
  sz.statusname as status_itm,
  trunc(rsv.dt_reserve) as dt_reserve,
  agg.qnt_slashes,
  agg.qnt_items,
  agg.qnt_in_prod,
  agg.qnt_to_sgp,
  agg.qnt_boards_m2,
  agg.qnt_edges_m,
  agg.qnt_glass_m2,
  agg.qnt_paint_kg,
  agg.qnt_panels_w_drill_all,
  case
    when nvl(agg.cnt_thn, 0) = 0 then null
    else decode(o.dt_to_sgp, null, trunc(sysdate) - o.dt_otgr, o.dt_to_sgp - o.dt_otgr)
  end as early_or_late
from
  orders o,
  orders ob,
  ref_sn_organizations ro,
  ref_customers rc,
  ref_customer_contact rcc,
  ref_customer_legal rcl,
  or_formats f,
  ref_production_areas pa,
  adm_users au,
  adm_users au2,
  v_order_hasestimate he,
  order_items_agg agg,
  --thn_list tl,
  --kns_list kl,
  complaints_list cl,
  dv.zakaz z,
  dv.status_zakaza sz,
  (select id_doc, max(log_date) as dt_reserve from dv.stock where agentcode = 'ZAKAZ' and doctype = 27 group by id_doc) rsv,
  order_types ot,
  order_reglaments orr
where
  ob.ornum (+) = o.or_reference
  and ro.id (+) = o.id_organization
  and rc.id (+) = o.id_customer
  and rcc.id (+) = o.id_customer_contact
  and rcl.id (+) = o.id_customer_org
  and f.id (+) = o.id_format
  and au.id (+) = o.id_manager
  and au2.id (+) = o.id_launched_by
  and pa.id (+) = o.area
  and he.id_order (+) = o.id
  and agg.id_order (+) = o.id
  --and tl.id_order (+) = o.id
  --and kl.id_order (+) = o.id
  and cl.id_order (+) = o.id
  and z.id_zakaz (+) = o.id_itm
  and sz.id_status (+) = z.id_status
  and rsv.id_doc (+) = o.id_itm
  and ot.id (+) = o.id_type2
  and orr.id (+) = o.id_reglament
;

SELECT /*+ PARALLEL(4) */ * FROM v_orders;

--update orders set active = 1 where id < 0;

create or replace view v_orders_list as 
select
--расширенная информация по заказу, для журнала заказов и детализаций
  o.*,
  itmest.cnt as has_itm_est
from
  v_orders o,
  v_order_itm_has_est itmest
where
  itmest.id_order (+) = o.id
;

select qnt_to_sgp from v_orders_list;  


create or replace view v_order_itm_has_est as
select
--проверка, есть ли в заказе изделия, по которым не подгружены сметы 
  id_order, 
  min(nvl(cnt,0)) as cnt 
from
  (select id_nomizdel_parent_t, count(*) as cnt from dv.nomenclatura_in_izdel niz group by niz.id_nomizdel_parent_t) niz,
  (select id_itm, id_order from order_items) oi
where 
  oi.id_itm = niz.id_nomizdel_parent_t (+) and oi.id_itm is not null and oi.qnt <> 0
group by
  id_order
;

create or replace view v_order_hasestimate as 
select
--таким образом получаем информацию, созданы ли сметы по всем ненулевым позициям заказа
  o.id as id_order, 
  case when count(i.id) > count(e.dt)
    then '-' else '+'
  end estimates,
  max(case when e.isempty = 1 then null else e.dt end) as dt_estimate_max
from
  estimates e,
  orders o,
  order_items i
where
  e.id_order_item (+) = i.id and
  i.id_order = o.id and
  nvl(i.qnt, 0) <> 0
  group by o.id
;

--create or replace view v_order_kns as 
--  select rtrim(xmlagg(xmlelement(e,username,', ').extract('//text()') order by username).getclobval(),', ')  x
--  select listagg(username,  '; ') within group (order by k.username) x
select 
    regexp_replace(listagg(k.username,  ';') within group (order by k.id_order), '([^;]+)(;\1)+', '\1' ) as constructor,
    k.id_order  
from
 (select id_kns, u.name as username,  id_order from order_items i, adm_users u where u.id = i.id_kns and i.id_kns <> -100/* and i.id_order = 42 */order by username) k
;
select i.id_order, u.name, sum(length(u.name)+1) over (order by u.name rows unbounded preceding) len_cummulative, row_number() over (order by u.name) no  from order_items i, adm_users u where u.id = i.id_thn and i.id_order = 41 ;--and i.id_thn <> -100;  


--таблица позиций в заказе
alter table order_items add price_wo_nds number;  --!!! 
alter table order_items add nds_rate number;
alter table order_items add price_wo_nds_with_margin number;
alter table order_items add price_tmp number;
update order_items set nds_rate = 22;
update order_items set price_tmp = price;
update order_items set price_pp = 0;
update order_items set price_wo_nds = round(price_tmp / 1.22 , 2)where id_order >= 16743;
update order_items set price_wo_nds = round(price_tmp / 1.22 , 2)where id_order < 0;
update order_items set price_wo_nds_with_margin = round(price_tmp / 1.22 , 2) where id_order >= 16743;
update order_items set price_wo_nds_with_margin = round(price_tmp / 1.22 , 2) where id_order < 0;
 
create table order_items (
  id number(11),
  id_order number(11),               --айди заказа
  pos number(11),                    --позиция в паспорте
  id_itm number(11), 
  id_std_item number(11),            --айди наименования изделия в or_std_item (и для стандартных и нестандартных)  
  dt_create date,                    --дата создания записи  
  dt_changed date,                   --дата изменения количества либо цены изделия (без учета скидки!!!), для финансового мониторинга   
  std number(1),                     --1 для стандартных изделий
  nstd number(1),                    --иначе, 1 для нестандартных изделий 
  sgp number(1),                     --отгрузка позиции с сгп
  qnt number(12,3),                  --количество
  comm varchar2(400),                --комментарий
  wo_estimate number(1) default 0,   --изделие не требует смету  
  id_kns number(11),                 --айди конструктора, или -100 = нет, или -101 = [конструктор] (любой)
  id_thn number(11),                 --технолог
  nds_rate number,                   --ставка ндс  
  price_wo_nds number,               --базовая цена без ндс и скидок
  price_wo_nds_with_margin number,   --цена без ндс, но с учетом скидки и наценки
  price number(12,2),                --цена позиции общая с учетом ндс, наченки и скидки 
  price_pp number(12,2),             --цена перепродажи, входит в общую цену позиции, не больше ее (всегда равна в случае д/к)
  r0 number(1) default 0,            --не задается производственный маршрут
  r1 number(1),                      --производственный участок №1 (КС)
  r2 number(1),
  r3 number(1),
  r4 number(1),
  r5 number(1),
  r6 number(1),
  r7 number(1),
  r8 number(1),
  r9 Number(1),
  ch varchar(4000),                  -- изменения, сделанные к данному слешу, имена полей memtable через запятую
  attention number(3) default 0,     -- признак внимания к ячеке строки (выделена цветом в паспорте)
  dt_sn date,                        -- отметка по слешу, что заказ обработан снабжением   
  dt_thn date,                       -- дата, когда по слэшу загружены документы технологов (при перезагрузке остается старая)
  dt_thn_last date,
  dt_kns date,                       -- дата, когда по слэшу загружены документы конструкторов (при перезагрузке остается старая)
  dt_kns_last date,
  wo_kns number(1) default 0,                  -- признак (если 1), что к слешу не нужны документы кнс (имеет смысл при наличии конструктора, когда по логике документы требуются)
  disassembled number default 0,     -- в разборе
  control_assembly number default 0, -- контрольная сборка  
  qnt_to_sgp number default 0,       -- количество принятых на сгп изделий по слэшу 
  qnt_boards_m2 number,              -- метраж плитных материалов 
  qnt_edges_m number,                -- метраж кромки
  qnt_glass_m2 number,               -- метраж стекла/зеркала
  qnt_paint_kg number,               -- вес краски/эмали/лака
  qnt_panels_w_drill number,         -- количество панелей со сверловкой 
  is_xml_loaded number default 0,      --загружен xml
  labor_intensity number,              --трудоемкость, мин.
  dt_last date,                        --дата первой подгрузки/обновления по одному слешу сметы в ручном режиме
  dt_est_last date,                    --дата последней подгрузки/обновления по одному слешу сметы в ручном режиме
  dt_doc date,                         --дата выдачи бумажных документов по заказу технологами
  constraint pk_order_items primary key (id),
  constraint fk_order_items_id_order foreign key (id_order) references orders(id) on delete cascade,
  constraint fk_order_items_kns foreign key (id_kns) references adm_users(id),
  constraint fk_order_items_thn foreign key (id_thn) references adm_users(id),
  constraint fk_order_items_std_item foreign key (id_std_item) references or_std_items(id)
);  

create unique index idx_order_items_pos on order_items(id_order, pos);
create index idx_order_items_id_order on order_items(id_order);
create index idx_order_items_id_std_item on order_items(id_std_item);
create index idx_order_items_id_order on order_items(id_order);
create index idx_order_items_id_thn on order_items(id_thn);
create index idx_order_items_id_kns on order_items(id_kns);
create index idx_order_items_id_order_qnt on order_items(id_order, qnt);

create index idx_order_items_covering on order_items(
  id_order,
  qnt,
  id_kns,
  id_thn,
  dt_kns,
  dt_thn,
  is_xml_loaded,
  qnt_to_sgp,
  sgp,
  qnt_boards_m2,
  qnt_edges_m,
  qnt_glass_m2,
  qnt_paint_kg,
  qnt_panels_w_drill
);

create sequence sq_order_items nocache;

create or replace trigger trg_order_items_bi_r 
  before insert on order_items for each row
begin
  :new.id := sq_order_items.nextval;
  :new.dt_create := sysdate;
end;
/

create or replace trigger trg_order_items_dt_ch_bu_r 
  before update on order_items for each row
begin
  if (nvl(:new.price, 0) <> nvl(:old.price, 0)) or (nvl(:new.qnt, 0) <> nvl(:old.qnt, 0)) then
    :new.dt_changed := sysdate;
  end if;
end;
/

create or replace view v_order_items as --!!!
with
  -- агрегация по входящим изделиям
  niz_agg as (
    select id_nomizdel_parent_t, count(*) as cnt
    from dv.nomenclatura_in_izdel
    group by id_nomizdel_parent_t
  ),
  -- маршруты для каждого id
  routes as (
    select
      i.id,
      f_oritemroute(i.r1,i.r2,i.r3,i.r4,i.r5,i.r6,i.r7,i.r8,i.r9) as route_val
    from order_items i
  ),
  nomencl_uniq as (
    select name, min(artikul) as artikul
    from dv.nomenclatura
    group by name
  )
  select
  i.*,
  o.ornum,
  o.id_organization,
  o.area,
  rc.name as customer,
  o.project,
  o.or_reference,
  ob.dt_beg as ref_dt_beg,
  ob.dt_otgr as ref_dt_otgr,
  o.ornum || '_' || substr('000000' || i.pos, -3) as slash,
  o.id_itm as id_order_itm,
  o.sync_with_itm,
  o.dt_beg,
  o.dt_end,
  o.dt_otgr,
  o.path,
  o.in_archive,
  uk.name as kns,
  ut.name as thn,
  s.name as itemname,
  case when ee.id > 0 then ee.prefix else '' end as prefix,
  case when ee.id > 0 then ee.prefix || '_' else '' end || s.name as fullitemname,
  r.route_val as route,
  r.route_val as route2,
  es.dt as dt_estimate,
  f_get_order_item_raw_price(i.id) as sum0,
  (round(nvl((i.price - i.price_pp)*i.qnt*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01) / o.ndsd, 0)) +
   round(nvl((i.price_pp)*i.qnt*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01) / o.ndsd, 0))) as cost_wo_nds,
  niz.cnt as has_itm_est,
  case when nvl(i.sgp, 0) = 1 then 0 else i.qnt - i.qnt_to_sgp end as qnt_in_prod,
  nvl(i.qnt_panels_w_drill, 0) * i.qnt as qnt_panels_w_drill_all,
  cast(decode(nvl(i.labor_intensity, -1), -1, null, i.labor_intensity * i.qnt) as number) as labor_intensity_total,
  n2.artikul as article,
    case 
      when id_thn = -100 then null
      when pp.is_data_entered + pc.is_data_entered + pl.is_data_entered + pd.is_data_entered = 4
        then trunc(greatest(pp.dt_data_entered, pc.dt_data_entered, pl.dt_data_entered, pd.dt_data_entered))
        else date '2000-01-01'
    end as dt_pln_ops 
from
  order_items i,
  orders o,
  orders ob,
  ref_customers rc,
  or_std_items s,
  or_format_estimates ee,
  adm_users uk,
  adm_users ut,
  estimates es,
  dv.nomenclatura n,
  niz_agg niz,
  routes r,
  nomencl_uniq n2,
  pnl_ops_painting pp,
  pnl_ops_cnc pc,
  pnl_ops_laser pl,
  pnl_ops_drilling pd
where
  i.id_order = o.id
  and ob.ornum (+) = o.or_reference
  and rc.id (+) = o.id_customer
  and i.id_std_item = s.id (+)
  and s.id_or_format_estimates = ee.id (+)
  and i.id_kns = uk.id (+)
  and i.id_thn = ut.id (+)
  and i.id = es.id_order_item (+)
  and i.id_itm = n.id_nomencl (+)
  and i.id_itm = niz.id_nomizdel_parent_t (+)
  and r.id (+) = i.id
  and n2.name (+) = s.name
  and i.id = pp.id_order_item (+)
  and i.id = pc.id_order_item (+)
  and i.id = pl.id_order_item (+)
  and i.id = pd.id_order_item (+)
;

select ornum, article from v_order_items where article is not null order by dt_beg desc; 
select * from v_order_items where id_itm is not null and qnt > 0 and has_itm_est is null and dt_estimate is not null and dt_beg > to_date('01.04.2025', 'DD.MM.YYYY'); 

--update order_items i set qnt_panels_w_drill = nvl((select qnt_panels_w_drill from or_std_items s where i.id_std_item = s.id and nvl(i.std, 0) = 1), i.qnt_panels_w_drill) where i.id_order = 10;  

create or replace function F_TestOrderEstimatesInItm(
--вернем количество изделий в заказе в ИТМ, к которым нет смет
  AIDOrder number
) 
return number
is
  FCnt number;
begin
  select count(*) into FCnt from v_order_items where 
    id_itm is not null and qnt > 0 and has_itm_est is null and dt_estimate is not null 
    and dt_beg > to_date('01.03.2025', 'DD.MM.YYYY') and id_order = AIDOrder;
  return FCnt;
end;
     
select F_TestOrderEstimatesInItm(7865) from dual;
    

create or replace view v_order_item_names as
select
--вью возвращает наименования и слеши изделий из заказов
  i.id,
  s.id as id_std_item,
  s.name,
  o.ornum || '_' || substr('000000' || i.pos, -3) as slash
from
  order_items i,
  orders o,
  or_std_items s
where
  o.id = i.id_order
  and s.id = i.id_std_item
;    
  

--update order_items set price_pp = price where resale = 1;

--------------------------------------------------------------------------------
--платежи (поступления в кассу) по заказам
create table or_payments(
  id number(11),       -- айди 
  id_order number(11), -- ид заказа в таблице uchet.to_orders
  dt date not null,    -- дата поступления платежа
  sum number(12,2),    -- сумма платежа     
  comm varchar(400),   -- комментарий  
  constraint pk_or_payments primary key (id),
  constraint fk_or_payments_order foreign key (id_order) references orders(id) on delete cascade
);

create unique index idx_or_payments on or_payments(id_order, dt);
create index idx_or_payments_order on or_payments(id_order);

create sequence sq_or_payments nocache;

create or replace trigger trg_or_payments_bi_r
  before insert on or_payments for each row
begin
  select sq_or_payments.nextval into :new.id from dual;
end;
/

create or replace procedure p_Or_Payment(
--сохраним в БД платеж по данному заказу за указанную дату
--!НЕТ - может быть больше заказа!!!
--/*за заданную дату сумма будет установлено не большее, чем остаток*/
--сохраним итоговую сумму платежа в журнале заказов
  IdOrder number,      --айди заказа                      
  PSum number,         --сумма платежа                  
  PDt date,            --дата платежа
  PAdd number          --если 1, то сумма добавляется к сумме за эту дату, иначе заменяет ее
) is 
  id1 number;
  sum1 number;
  sum2 number;
begin
  if nvl(PSum, 0) = 0 then
    delete from or_payments where id_order = IdOrder and dt = PDt;
  else
    --select nvl(sum(sum),0) into sum1 from or_payments where id_order = IdOrder;
    --select nvl(cost, 0) into sum2 from orders where id = IdOrder;
    select max(id), nvl(max(sum),0) into id1, sum1 from or_payments where id_order = IdOrder and dt = PDt;
    if id1 is null then  
      insert into or_payments (id_order, dt, sum, comm) values (IdOrder, PDt, PSum, null);
    else
      if PAdd = 1 then 
        sum1 := PSum + sum1;
      else
        sum1 := PSum;
      end if; 
      update or_payments set sum = sum1 where id_order = IdOrder and dt = PDt;
    end if;
  end if; 
  select nvl(sum(sum),0) into sum2 from or_payments where id_order = IdOrder;
  update orders set pay = sum2 where id = IdOrder;
end;
/


create or replace view v_or_payments as (
  select
    o.*, 
    nvl(p.paidsum, 0) as paidsum,
    nvl(o.cost, 0) - nvl(p.paidsum, 0) as restsum,
    (case when o.prefix <> 'Н' 
      then 
        (case when o.dt_upd <= trunc(sysdate) then nvl(o.cost, 0) - nvl(p.paidsum, 0) else 0 end)
      else 
        nvl(o.cost, 0) - nvl(p.paidsum, 0)
    end) as receivables,       --дебиторская задолженность
  (case 
    when p.paidsum is null then 'не оплачен'
    when p.paidsum = o.cost then 'полностью'
    when p.paidsum = 0 then 'не оплачен'
    when p.paidsum > o.cost then 'переплата'
    else 'частично'
  end) as paimentstatus,
  (case 
    when  o.dt_end is null then 0
    else 1
  end) as endstatus,
  p.maxdtpaid
  from 
    v_orders o,
    (select sum(sum) as paidsum, id_order, max(dt) as maxdtpaid from or_payments pp group by id_order) p 
  where
    o.id > 0 and
    o.id_organization <> -1 and
    o.id = p.id_order(+) 
);



--промежуточные платежи по заказам Н (поступление денег менеджеру, логисту, на карту от клиента, но еще не в кассу)
create table or_payments_n(
  id number(11),       -- айди 
  id_order number(11), -- ид заказа в таблице uchet.to_orders
  dt date not null,    -- дата поступления платежа
  sum number(12,2),    -- сумма платежа     
  comm varchar(400),   -- комментарий  
  constraint pk_or_payments_n primary key (id),
  constraint fk_or_payments_n_order foreign key (id_order) references orders(id) on delete cascade
);

create unique index idx_or_payments_n on or_payments_n(id_order, dt);
create index idx_or_payments_n_order on or_payments_n(id_order);

create sequence sq_or_payments_n nocache;

create or replace trigger trg_or_payments_n_bi_r
  before insert on or_payments_n for each row
begin
  select sq_or_payments_n.nextval into :new.id from dual;
end;
/

create or replace procedure p_Or_Payment_n(
--сохраним в БД промежуточный платеж по данному заказу за указанную дату
--сохраним итоговую сумму платежа в журнале заказов
  IdOrder number,      --айди заказа                      
  PSum number,         --сумма платежа                  
  PDt date,            --дата платежа
  PAdd number          --если 1, то сумма добавляется к сумме за эту дату, иначе заменяет ее
) is 
  id1 number;
  sum1 number;
  sum2 number;
begin
  if nvl(PSum, 0) = 0 then
    delete from or_payments_n where id_order = IdOrder and dt = PDt;
  else
    select max(id), nvl(max(sum),0) into id1, sum1 from or_payments_n where id_order = IdOrder and dt = PDt;
    if id1 is null then  
      insert into or_payments_n (id_order, dt, sum, comm) values (IdOrder, PDt, PSum, null);
    else
      if PAdd = 1 then 
        sum1 := PSum + sum1;
      else
        sum1 := PSum;
      end if; 
      update or_payments_n set sum = sum1 where id_order = IdOrder and dt = PDt;
    end if;
  end if; 
  select nvl(sum(sum),0) into sum2 from or_payments_n where id_order = IdOrder;
  update orders set pay_n = sum2 where id = IdOrder;
end;
/
  
create or replace view v_or_payments_n as (
  select
    o.*, 
    nvl(p.paidsum, 0) as paidsum,
    nvl(o.cost, 0) - nvl(p.paidsum, 0) as restsum,
  (case 
    when nvl(p.paidsum,0) = 0 then 'не оплачен'
    when p.paidsum = o.cost then 'полностью'
    when p.paidsum > o.cost then 'переплата'
    else 'частично'
  end) as paimentstatus,
  (case 
    when  o.dt_end is null then 0
    else 1
  end) as endstatus,
  p.maxdtpaid
  from 
    v_orders o,
    (select sum(sum) as paidsum, id_order, max(dt) as maxdtpaid from or_payments_n pp group by id_order) p 
  where
    o.id > 0 and
    o.prefix = 'Н' and
    o.id = p.id_order(+) 
);


--дополнительные данные заказа, привязянные у айди заказов
--можно сделать здесь разные поля, зависят от типа данных
create table orders_add(
  id number(11),       -- айди 
  id_order number(11), -- ид заказа в таблице uchet.to_orders
  --тип данных
  -- 1-коммент по закрытию заказа, 2- коммент предв. платежа, 3- коммент платежа
  id_data number(2),   -- тип данных   
  comm varchar2(4000), -- комментарий  
  constraint pk_orders_add primary key (id),
  constraint fk_orders_add_order foreign key (id_order) references orders(id) on delete cascade
);

create unique index idx_orders_add on orders_add(id_order, id_data);

create sequence sq_orders_add nocache;

create or replace trigger trg_orders_add_bi_r
  before insert on orders_add for each row
begin
  select sq_orders_add.nextval into :new.id from dual;
end;
/

        

--------------------------------------------------------------------------------
-- справочник стандартных изделий
-- id_or_format_estimates=0 - нестандартное изделий
-- id_or_format_estimates=1 - доп. комплектация (с 20224-06 убрана)
--alter table or_std_items add dt_changed_price date;
create table or_std_items (
  id number(11),
  id_or_format_estimates number(11),   --айди типа сметы (КБ/Производство)
  name varchar2(400),                  --наименование изделия
  price number(12,2),                  --цена
  price_pp number(12,2),               --цена перепродажи, входит в итоговую цену, не больше ее (всегда равна в случае д/к)
  price_check number(12,2),            --контрольная цена (имеется ввиду себестоимость) 
  wo_estimate number(1) default 0,     --если 1, то смета не требуется (по факту требуется запись в estimates с полем isempty = 1)
  type_of_semiproduct number(11),      --тип полуфабриката, соотвествует одному из участков
  barcode_c varchar2(100),             --штрих-код
  r0 number(1) default 0,              --если 1, то производдственный маршрут не задается
  by_sgp number(1) default 0,          --для данного изделия ведется учет СГП по стандартным изделиям 
  qnt_panels_w_drill number,
  is_xml_loaded number default 0,      --загружен xml
  labor_intensity number,              --трудоемкость, мин.
  dt_changed_price date,               --дата.время изменения продажной цены изделия
  
  r1 number(1),                        --производственный маршрут
  r2 number(1),
  r3 number(1),
  r4 number(1),
  r5 number(1),
  r6 number(1),
  r7 number(1),
  r8 number(1),
  r9 number(1),
  
  constraint pk_or_std_items primary key (id), 
  constraint fk_or_std_items_est foreign key (id_or_format_estimates) references or_format_estimates(id),
  constraint fk_or_std_items_sem foreign key (type_of_semiproduct) references work_cell_types(id)
);
  
-- наименование уникально без учета регистра для данного формата смет
create unique index idx_or_std_items_name on or_std_items(id_or_format_estimates, lower(name));
create index idx_or_std_items_name1 on or_std_items(name);


create sequence sq_or_std_items nocache;

create or replace trigger trg_or_std_items_bi_r
  before insert on or_std_items for each row
begin
  select sq_or_std_items.nextval into :new.id from dual;
end;
/

create or replace trigger trg_or_std_items_ai_r 
  after insert on or_std_items for each row
begin
  --создаем строки в таблице трудоемкости по стандартному изделию для обеих плозадок
  insert into or_std_labor_intensity (id, id_area) values (:new.id, 0);
  insert into or_std_labor_intensity (id, id_area) values (:new.id, 2);
end;
/

create or replace trigger trg_or_std_items_bu_price_r 
  before update on or_std_items for each row
--триггер для обновления даты при изменении price
begin
  --обновляем поле только если значение price действительно изменилось
  if nvl(:new.price, 0) <> nvl(:old.price, 0) then
    :new.dt_changed_price := sysdate;
  end if;
end;
/


create or replace view v_or_std_items as --!!!
  select
  --вью для справочника стандартныых изделий
    i.*,
    fi.prefix,
    fi.id_format,
    fi.type,
    fi.name as or_format_estimate_name,  
    orf.name as or_format_name,
    round(i.price / 1.22, 2) as price_wo_nds,
    decode(fi.id, 0, '', fi.prefix || '_') || i.name as fullname,
    f_oritemroute(i.r1,i.r2,i.r3,i.r4,i.r5,i.r6,i.r7,i.r8,i.r9) as route2,
    e.dt as dt_estimate,
    case when e.has_influencing = 0 then null when e.dt_influencing_ready is null then date '2000-01-01' else e.dt_influencing_ready end as dt_influencing, 
    prc.priceraw,
    round(prc.priceraw / 1.22, 2) as priceraw_wo_nds,
    case 
        when nvl(i.price, 0) = 0 then null 
        else round(nvl(decode(i.price_check, null, prc.priceraw / 1.22, i.price_check), 0) / (nvl(i.price, 0) / 1.22) * 100, 2) 
    end as material_percent,
    fi.is_semiproduct,
    i0.labor_intensity as labor_intensity_0,
    i0.labor_cost as labor_cost_0,
    case when nvl(i.price, 0) = 0 then null else round(i0.labor_cost / (nvl(i.price, 0) / 1.22) * 100, 2) end as labor_percent_0,
    i2.labor_intensity as labor_intensity_2,
    i2.labor_cost as labor_cost_2,
    case when nvl(i.price, 0) = 0 then null else round(i2.labor_cost / (nvl(i.price, 0) / 1.22) * 100, 2) end as labor_percent_2,
    i0.labor_intensity + i2.labor_intensity as labor_intensity_total,
    i0.labor_cost + i2.labor_cost as labor_cost,
    case when nvl(i.price, 0) = 0 then null else round((i0.labor_cost + i2.labor_cost) / (nvl(i.price, 0) / 1.22) * 100, 2) end as labor_percent,
    case 
      when not ((type = 0) or (type = 2)) then null
      when pp.is_data_entered + pc.is_data_entered + pl.is_data_entered + pd.is_data_entered = 4
        then trunc(greatest(pp.dt_data_entered, pc.dt_data_entered, pl.dt_data_entered, pd.dt_data_entered))
        else date '2000-01-01'
    end as dt_pln_ops 
  from
    or_std_items i
    left join estimates e on i.id = e.id_std_item
    join or_format_estimates fi on i.id_or_format_estimates = fi.id
    join or_formats orf on fi.id_format = orf.id
    join v_or_std_labor_intensity i0 on i.id = i0.id and i0.id_area = 0
    join v_or_std_labor_intensity i2 on i.id = i2.id and i2.id_area = 2
    join (select id, f_get_stditem_raw_price(id) as priceraw from or_std_items) prc on prc.id = i.id
    left outer join pnl_ops_painting pp on i.id = pp.id_std_item
    left outer join pnl_ops_cnc pc on i.id = pc.id_std_item
    left outer join pnl_ops_laser pl on i.id = pl.id_std_item
    left outer join pnl_ops_drilling pd on i.id = pd.id_std_item
  ;
    

drop procedure P_SetStdItemPrice;     
create or replace procedure P_SetStdItemPrice(
--установка цены всего изделия и перепродажи для него (включаемая) в позиции справочника стандартных изделий
  IdStdItem number,  --айди стандартного изделия                      
  PriceNew number,   --новая цена (или общая изделия, или перепродажи в нем)                  
  WoNds number
) is 
  Idformat number;
  PriceOld number(11,2);
  PricePpOld number(11,2);
  v_type number(1);  --0 - производственный, 1 - отгрузочный, 2 - п/ф
  v_pricenew number;
begin
  select 
    ii.type, d_or_format_estimates, nvl(price,0) into v_type, IdFormat, PriceOld 
    from or_std_items i, or_format_estimates f 
    where id = IdStdItem and i.id_or_format_estimates = f.id;
    --это не д/к
    v_pricenew := PriceNew;
    if WoNds = 1 then 
      v_pricenew := Round(v_pricenew * 1.22, 2); 
    end if; 
   update or_std_items set price = v_pricenew where id = IdStdItem;
    if v_type = 1 then
      update order_items set price = v_pricenew where id_order < 0 and id_organization = -1 and id_std_item = IdStdItem;
    else
      update order_items set price = Round(v_pricenew / 1.22, 2) where id_order < 0 and id_organization <> -1 and id_std_item = IdStdItem;
    end if;
end;  
/  

create or replace procedure p_set_std_item_price(
--установим цену стандартного изделия (с ндс),
--обновим цены в шаблонах папортов
  p_id_std_item in number,  -- айлди изделия
  p_price_new   in number,  -- цена
  p_wo_nds      in number   -- 1 если цена передена без ндс
) is
  v_type        number(1);  -- 0 – производственный, 1 – отгрузочный, 2 – п/ф
  v_id_format   number;
  v_price_old   number(11,2);
  v_price_new   number;
begin
  -- получение типа изделия и старой цены (соединение через старый синтаксис Oracle)
  select
    f.type,
    i.id_or_format_estimates,
    nvl(i.price, 0)
  into
    v_type,
    v_id_format,
    v_price_old
  from
    or_std_items i,
    or_format_estimates f
  where
    i.id = p_id_std_item
    and i.id_or_format_estimates = f.id;
  -- пересчёт цены с учётом флага "без НДС" - итоговая будет с ндс
  v_price_new := p_price_new;
  if p_wo_nds = 1 then
    v_price_new := round(v_price_new * 1.22, 2);
  end if;
  -- обновление цены в справочнике стандартных изделий
  update or_std_items
    set price = v_price_new
    where id = p_id_std_item;
 -- обновление цены в позициях заказов (order_items)
  if v_type = 1 then
    --для отгрузочных заказов цена с НДС
    update order_items oi
       set oi.price = v_price_new
     where oi.id_std_item = p_id_std_item
       and oi.id_order < 0
       and exists (select 1 from orders o where o.id = oi.id_order and o.id_organization <> -1);  
  else
    --для производственных заказов цена без НДС
    update order_items oi
       set oi.price = round(v_price_new / 1.22, 2)
     where oi.id_std_item = p_id_std_item
       and oi.id_order < 0
       and exists (select 1 from orders o where o.id = oi.id_order and o.id_organization = -1);  
  end if; 
end;
/

--update or_std_items set price_pp = 0 where id_or_format_estimates > 1;



create or replace function F_OrItemRoute
--формируем производственный маршрут по 9 полям в текстовом виде 
(
  r1 number,r2 number,r3 number,r4 number,r5 number,r6 number,r7 number,r8 number,r9 number
)
return varchar2
is
  st varchar2(4000);
begin
  st := '';
  if r1 = 1 then st := st || 'КС, '; end if;
  if r2 = 1 then st := st || 'МТ, '; end if;
  if r3 = 1 then st := st || 'СТ, '; end if;
  if r4 = 1 then st := st || 'РК, '; end if;
  if r5 = 1 then st := st || 'ПГ, '; end if;
  if r6 = 1 then st := st || 'ЛК, '; end if;
  if r7 = 1 then st := st || 'КМ, '; end if;
  if length(st) > 0 then st := substr(st, 1, length(st) - 2); end if; 
  return st;
end;
/

create or replace function F_OrItemRoute2
--формируем производственный маршрут по 9 полям в текстовом виде, или Доп. компл 
(
  r1 number,r2 number,r3 number,r4 number,r5 number,r6 number,r7 number,r8 number,r9 number,resale number 
)
return varchar2
is
  st varchar2(4000);
begin
  st := F_OrItemRoute(r1,r2,r3,r4,r5,r6,r7,r8,r9);
  return st;
/*  --if resale = 1 then
    st := 'Доп. компл.';
  else
    st := F_OrItemRoute(r1,r2,r3,r4,r5,r6,r7,r8,r9);
  end if;*/
end;
/

create or replace procedure P_CreateOrStdItem_Nstd(
--создадим, если его нет, позицию в справочнике стандартных изделий, в группе общие
  NameItem in varchar2,
  IdItem out number
) is
  IdStdItem number;
begin
  begin
    select id into IdItem from or_std_items 
    where lower(name)=lower(NameItem) and id_or_format_estimates = 0;
  exception
    when no_data_found then
      insert into or_std_items (name, id_or_format_estimates)
      values(NameItem, 0) returning id into IdItem;
  end;
end;
/



--------------------------------------------------------------------------------
--таблица по причинам рекламаций для заказа
create table order_complaints (
  id number(11),
  id_order number(11),                             --айди заказа, при удаелнии последнего удаляются записи в этой таблице
  id_complaint_reason number(11),                  --айди причины рекламации 
  constraint pk_order_complaints primary key (id),
  constraint fk_order_complaints_id_order foreign key (id_order) references orders(id) on delete cascade,
  constraint fk_order_complaints_id_reason foreign key (id_complaint_reason) references ref_complaint_reasons(id)
);   
  
create sequence sq_order_complaints nocache;

create or replace trigger trg_order_complaints_bi_r
  before insert on order_complaints for each row
begin
  select sq_order_complaints.nextval into :new.id from dual;
end;
/

alter table order_plans add prc3a number(5,2);
create table order_plans (
  dt date not null,         --дата, первое число месяца
  sum1ri number,            --для продажи, по рознице, сумма изделий  
  sum1ra number,            --доп комплектации
  sum1rd number,            --доставки 
  sum1rm number,            --монтажа
  sum1oi number,            --для продажи, по опту, сумма изделий  
  sum1oa number,            --доп комплектации
  sum1od number,            --доставки 
  sum1om number,            --монтажа
  sum2ri number,            --для реализации, по рознице, сумма изделий  
  sum2ra number,            --доп комплектации
  sum2rd number,            --доставки 
  sum2rm number,            --монтажа
  sum2oi number,            --для реализации, по опту, сумма изделий  
  sum2oa number,            --доп комплектации
  sum2od number,            --доставки 
  sum2om number,            --монтажа
  sum3i number,             --для выпуска продукции, сумма изделий  
  sum3a number,             --для выпуска продукции, доп комплектации
  prc3i number(5,2),        --плановый процент изделий, выпускаемых без просрочки
  prc3a number(5,2),        --плановый процент доп комплектации, выпускаемых без просрочки
  prc3 number(5,2),         --плановый процент изделий, выпускаемых без просрочки /не используем/
  constraint pk_order_plans primary key (dt)
);  



--------------------------------------------------------------------------------
--таблица видов работы для журнала рахработки проектов (кнс)
create table ref_develtypes (
  id number(11),
  name varchar2(400) unique,          --наименование вида разработки
  constraint pk_ref_develtypes primary key (id)
);  

create sequence sq_ref_develtypes nocache start with 1;

create or replace trigger trg_ref_develtypes_bi_r
  before insert on ref_develtypes for each row
begin
  select sq_ref_develtypes.nextval into :new.id from dual;
end;
/

insert into ref_develtypes (name) values ('Просчет');
insert into ref_develtypes (name) values ('Тендер');
insert into ref_develtypes (name) values ('Разработка');
insert into ref_develtypes (name) values ('Переработка');
insert into ref_develtypes (name) values ('Запуск');
insert into ref_develtypes (name) values ('Чертежи');
insert into ref_develtypes (name) values ('');


--таблица журнала рахработки проектов (кнс)
--alter table j_development add slash varchar2(25);
create table j_development (
  id number(11),
  id_develtype number(11),      --вид разработки, из справочника
  slash varchar2(25),           --номер изделия /слеш/ - не обязательно
  project varchar2(400),        --проект, текстом  
  name varchar2(400),           --наименование разработки, тесктом
  dt_beg date,                  --дата начала разработки, автоматически
  dt_plan date,                 --планируемая дата окончания разработки
  dt_end date,                  --дата окончиния разработки, автоматически ставится при выборе статуса Готово
  id_status number(3),          --номер статуса, без таблицы (1=новый, 2=в работе, 3=остановлен, 4=на согласовании, 5=завис, 100=готово)         
  cnt number(11,1),             --сделка (мож быть например число панелей, или другие подобные величины, число)
  time number(11,1),            --время работы по проекту, в часах
  id_kns number(11),            --айди конструктора
  comm varchar2(4000),          --комментарий
  constraint pk_j_development primary key (id),
  constraint fk_j_development_id_develtype foreign key (id_develtype) references ref_develtypes(id)
);   
  
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
  u.name as constr,
  decode(d.id_status, 1, 'новый', 2, 'в работе', 3, 'остановлен', 4, 'на согласовании', 5, 'завис', 100, 'готово', '') as status 
from
  j_development d,
  ref_develtypes t,
  adm_users u
where
  d.id_develtype = t.id and
  u.id (+) = d.id_kns
;






select rc.name, rc.id, oc.id, null from ref_complaint_reasons rc, order_complaints oc, orders o where rc.id = oc.id_complaint_reason(+) and o.id = oc.id_order(+) and o.id = 29 order by rc.name;
select rc.name, rc.id, oc.id, null from ref_complaint_reasons rc, order_complaints oc, orders o where rc.id = oc.id_complaint_reason(+) and o.id = oc.id_order(+) and o.id = 29 order by rc.name;

select rc.name, rc.id, oc.id, null from ref_complaint_reasons rc, order_complaints oc where rc.id = oc.id_complaint_reason(+) and oc.id_order = 29 order by rc.name;

----------------------------------
select n.name as name, u.name_unit as name_unit from dv.nomenclatura n, dv.unit u where id_group = 762 and n.id_unit = u.id_unit order by n.name;




select f_order_getnewnum(:dt$d, :id_org$i) from dual;



select id_group from dv.groups where groupname = 'Продукция';   --3
select id_group, groupname from dv.groups where id_parentgroup = 3;
SELECT SYS_CONNECT_BY_PATH(groupname, '/') FROM dv.groups START WITH id_group = 4 CONNECT BY PRIOR id_group=id_parentgroup order by 1;

select count(*) from orders where id < 0 and id <> nvl(-7, 0) and templatename = 'template2';

select customercontact from v_orders;





update orders set id_organization= :id_organization$i, or_reference= :or_reference$s, id_format= :id_format$i, account= :account$s, id_type= :id_type$i, address= :address$s, 
dt_beg= :dt_beg$d, dt_otgr= null, dt_montage_beg= :dt_montage_beg$d, dt_change= null, project= :project$s, wholesale= :wholesale$i, m_i= :m_i$f, d_i= :d_i$f, m_a= :m_a$f, d_a= :d_a$f, 
cost_m= :cost_m$f, m_d= :m_d$f, d_d= :d_d$f, cost_d= :cost_d$f, m_d= :m_d$f, d_d= :d_d$f, cashtype= :cashtype$i, comm= :comm$s, id_manager= :id_manager$i, id_customer= :id_customer$i, 
id_customer_contact= :id_customer_contact$i, id_customer_org= :id_customer_org$i where id = :id$i;


---------------------------
---------------------------
---------------------------
--смета из итм
select 
  z.NUMZAKAZ,
 -- nu.name as slash,
  n.name,
  ni.ID_NOMIZDEL_PARENT_T,
  ni.ID_NOMINIZDEL_T
from
  dv.nomenclatura n,
  --dv.nomenclatura nu,
  --dv.nomenclatura nz,
  dv.nomenclatura_in_izdel ni,
  dv.zakaz z
where
  ni.id_nomencl = n.id_nomencl
  --and ni.ID_NOMIZDEL_PARENT_T (+) = nu.id_nomencl
  and z.id_zakaz = ni.ID_ZAKAZ 
  and ni.ID_ZAKAZ = 7249 --6929
  --and ni.ID_NOMINIZDEL_T is not null
order by ni.id_zakaz, ni.position 
;

select 
  z.NUMZAKAZ,
  nu.name as slash,   --родительская номенклатура для сметы
  n.name,             --наименование позиции заказа  
  ni.ID_NOMIZDEL_PARENT_T,
  ni.ID_NOMINIZDEL_T
from
  dv.nomenclatura n,
  dv.nomenclatura nu,
  dv.nomenclatura_in_izdel ni,
  dv.zakaz z
where
  ni.id_nomencl = n.id_nomencl
  and ni.ID_NOMINIZDEL_T = nu.id_nomencl
  and z.id_zakaz = ni.ID_ZAKAZ 
  and ni.ID_ZAKAZ = 7249 --6929
order by ni.id_zakaz, ni.position 
;


select 
  ni.ID_NOMINIZDEL,   --13260
  z.NUMZAKAZ,
  n.name,             --наименование позиции заказа 
  ni.count_nomencl, 
  ni.ID_NOMINIZDEL_T
from
  dv.nomenclatura n,
  dv.nomenclatura_in_izdel ni,
  dv.zakaz z
where
  ni.id_nomencl (+) = n.id_nomencl
  and ni.ID_NOMINIZDEL_T <> 0
  and z.id_zakaz = ni.ID_ZAKAZ 
  and ni.ID_ZAKAZ = 7249
order by n.name, ni.id_zakaz, ni.position 
;                        

select * from dv.nomenclatura_in_izdel ni where id_zakaz = 7249;


select 
  ni.ID_NOMINIZDEL,   --13260
  z.NUMZAKAZ,
  n.name,             --наименование позиции заказа
  g.groupname  
from
  dv.nomenclatura n,
  dv.nomenclatura_in_izdel ni,
  dv.zakaz z,
  dv.groups g
where
  ni.id_nomencl = n.id_nomencl
  and ni.ID_NOMIZDEL_PARENT_T = 13260
  and z.id_zakaz = ni.ID_ZAKAZ
  and n.id_group = g.id_group 
order by g.groupname, n.name 
;

begin
  dbms_output.enable();
end;
/                        

declare
  IdZakaz number;
begin
  select dv.SyncOrder(1, 1, 'test1', '01.12.2023', '10.12.2023', 'Билайн', 'ООО "Омега"') into idzakaz from dual; 
  dbms_output.put_line(idzakaz);
end;
/


declare
  IdZakaz number;
begin
  dv.p_SyncOrder(1, 1, 'test2', '01.12.2023', '10.12.2023', 'Билайн', 'ООО "Омега"', IdZakaz); 
  dbms_output.put_line(idzakaz);
end;
/

delete from dv.zakaz where id_zakaz = 7075;


--update order_items i set dt_sn = trunc(sysdate) where id_order = 126 and id in (select id from v_order_items where dt_estimate is not null);

--delete from ref_complaint_reasons;

select ornum, customer, project from v_orders where id = 190;

/*
--пересчитать сумму изделий по заказу по изделиям не с сгп
update orders o set cost_i_nosgp = round(nvl((select sum(round(price * qnt, 2)) as s from order_items i where i.id_order = o.id and nvl(i.sgp,0) <> 1 and nvl(i.resale,0) <> 1),0) * (1 + nvl(m_i,0)/100 - nvl(d_i,0)/100), 2);-- where id = 448;  --60 
select round(nvl((select sum(round(price * qnt, 2)) as s from order_items i where i.id_order = o.id and nvl(i.sgp,0) <> 1 and nvl(i.resale,0) <> 1),0) * (1 + nvl(m_i,0)/100 - nvl(d_i,0)/100), 2) from orders o where o.id = 448;  --60 
select cost_i_nosgp from orders where id=448;
select price, qnt, resale, sgp from order_items where id_order = 334;
select nvl(sum(round(price * qnt, 2)),0) from order_items i where i.id_order = 448 and nvl(i.sgp,0) <> 1;-- and i.resale <> 1),0) * (1 + nvl(m_i,0)/100 - nvl(d_i,0)/100), 2) where id = 334;
select nvl(round(price * qnt, 2),0) from order_items i where i.id_order = 448 and nvl(i.sgp,0) <> 1;
*/

select dt_beg, dt_end, dt_beg + Round(((dt_end - dt_beg) / 2), 0) from v_orders where id = 51;
--select ornum, dt_beg, dt_otgr, dt_pnr from v_orders;
--update orders set id_itm = null where dt_beg < '01.02.2024';

--update orders set dt_montage_end = dt_montage_beg;












--------------------------------------------------------------------------------
create or replace procedure P_SyncOrderWithITM(
--синхронизируем полностью заказ в итм с заказом в учете по полученному айди из учета
--состав изделий заказа итм будет приведен к составу в учете независимо от того что в нем было и
--был ли вообще в итм заказ создан. позиции с количееством 0, изделия с пометкой Без сметы,
--и те, в которых после автозамены не осталось изделий, загружены в итм не будут.
--
--если передан список айди изделий заказа в учете через запятую, то сметы будут загружены только
--для них, но все остальное будет учтено.
--
--вообще не синхронизируем (кроме удаления заказа) в случае, если статус заказа >= Выполнен, если ASyncIfCompleted = 0 (по умолчения)
--(поле ID_STATUS, статусы в см таблице status_zakaza) 
  AIdOrder in number,
  AOrImems in varchar2,
  ASyncIfCompleted in number := 0
) is
  i number;
  FCreateZ number;
  FOrNum varchar2(50);
  FDtBeg date;
  FDtOtgr date;
  FCustomer varchar2(400);
  FOrg varchar2(400);
  FWholeSale number;
  FIdZakaz number;
  FIdIzdel number;
  FIdStatus number;
  FOrOpMode number;
  FSendEstimate number;
  FEstQntInItm number;
  FIDOrEstimate number;
  FNeedeSyncBoardsEdges number;
begin
  --есть ли заказ в базе учета
  select count(*) into i from orders where id = AIdOrder;
  --если передан айди заказа, которого нет в таблице, значит это было удаление заказа, тогда удалим и из итм и выйдем
  if i = 0 then 
    delete from dv.zakaz where id_order_dv = AIdOrder;
    Return;
  end if;
  --получим параметры заказа
  select 
    o.sync_with_itm, o.id_itm, o.ornum, o.dt_beg, o.dt_otgr, decode(c.wholesale, 1, o.customer, 'Розница'), o.organization
    into i, FIdZakaz, FOrNum, FDtBeg, FDtOtgr, FCustomer, FOrg 
    from v_orders o, ref_customers c
    where o.id_customer = c.id (+) and o.id = AIdOrder;
  if i <> 1 then 
    --синхронизация с итм для этого заказа отключена, выйдем
    Return;
  end if;
  --есть ли такой заказ в итм и данные заказа
  begin
    i := 1;
    --получим статус заказа в итм
    select id_status into FIdStatus from dv.zakaz where id_order_dv = AIdOrder;
    --если статус >= выполнен, то ничего не синхронизируем, выйдем
    --статусы в таблице status_zakaza
    if FIdStatus >= 30 and ASyncIfCompleted = 0 then
      Return;
    end if;
  exception
    --нет заказа
    when no_data_found then
      i := 0;
  end;
  FNeedeSyncBoardsEdges := 0;
  --если id_itm is null или айди есть, но не найден в итм, то это вставка, иначе изменение
  if FIdZakaz is null or i = 0 then
    update orders set id_itm = null where id = AIdOrder;
    update order_items set id_itm = null where id_order = AIdOrder;      
    FIdZakaz := null;
    FOrOpMode := 1;
    dbms_output.put_line('cleanitmids');
  else
    FOrOpMode := 2;
    --при изменении сразу изменим заголовок
    dv.P_SyncOrder(AIdOrder, FOrOpMode, FOrNum, FDtBeg, FDtOtgr, FCustomer, FOrg, FIdZakaz);
  end if;
  --признак что нужно создавать заказ (создадим при первом внесенном изделии), или не удалять в случае, если это изменение
  FCreateZ := 0;
  --проход по изделиям заказа  
  for CVOrderItems in (select * from v_order_items where id_order = AIdOrder order by pos) loop
    FIdIzdel := CVOrderItems.id_itm; 
    FSendEstimate := 0; 
    if nvl(CVOrderItems.qnt, 0) = 0 or nvl(CVOrderItems.wo_estimate, 0) = 1 then
      --количество равно 0, или изделие без сметы   
      if (FOrOpMode = 2)and(CVOrderItems.id_itm is not null) then 
        --если это изменение заказа, то удалим изделие из итм
        dv.P_SyncIzdel(FIdZakaz, 3, CVOrderItems.slash, CVOrderItems.fullitemname, CVOrderItems.qnt, CVOrderItems.id_itm, FIdIzdel);
        update order_items set id_itm = null where id = CVOrderItems.id;
        dbms_output.put_line('delitem');
      end if;
    else 
      --иначе надо эту позицию синхронизировать  
      --получим айди сметы по изделию заказа
      select max(id) into FIDOrEstimate from estimates where id_order_item = CVOrderItems.id;
      --получим количество позиций в смете, которые пойдут в итм (учетем автозамену)
      select count(id) into FEstQntInItm from v_estimate where id_estimate = FIDOrEstimate and qnt_itm is not null;
      if (FIDOrEstimate is not null) and FEstQntInItm = 0 then
        --если смета есть, но в ней нет позиций для итм, то удалим это изделие
        dv.P_SyncIzdel(FIdZakaz, 3, CVOrderItems.slash, CVOrderItems.fullitemname, CVOrderItems.qnt, CVOrderItems.id_itm, FIdIzdel);
        update order_items set id_itm = null where id = CVOrderItems.id;
        FNeedeSyncBoardsEdges := 1;
        Continue;
      end if;
      if FOrOpMode = 1 and FCreateZ = 0 then
        --если заказ в итм не был создан, то создадим его
        dv.P_SyncOrder(AIdOrder, FOrOpMode, FOrNum, FDtBeg, FDtOtgr, FCustomer, FOrg, FIdZakaz);
        update orders set id_itm = FIdZakaz where id = AIdOrder;
        dbms_output.put_line('createorder');
      end if;
      FCreateZ := 1; 
      if CVOrderItems.id_itm is null then
        --изделия в итм еще нет - создадим
        dv.P_SyncIzdel(FIdZakaz, 1, CVOrderItems.slash, CVOrderItems.fullitemname, CVOrderItems.qnt, null, FIdIzdel);
        update order_items set id_itm = FIdIzdel where id = CVOrderItems.id;      
        FSendEstimate := 1; 
        dbms_output.put_line('createitem');
      else
        --изделие в итм есть - изменим
        dv.P_SyncIzdel(FIdZakaz, 2, CVOrderItems.slash, CVOrderItems.fullitemname, CVOrderItems.qnt, CVOrderItems.id_itm, FIdIzdel);
        FSendEstimate := 1; 
        dbms_output.put_line('chitem ' || FIdIzdel);
      end if;
    end if;
    --если нужно обновим смету
    if (FSendEstimate = 1)and(FIdIzdel is not null)
    and((AOrImems is null)or(instr(',' || AOrImems || ',', ',' || CVOrderItems.id || ',') > 0)) 
    then
      P_SendEstimateToItm(FIDOrEstimate, FIdZakaz, FIdIzdel, i); 
      FNeedeSyncBoardsEdges := 1; 
      dbms_output.put_line('P_SendEstimateToItm');
    end if; 
  end loop;
  --заказ в итм существует
  if FIdZakaz is not null then
    --получим и удалим изделия в заказе итм, для которых нет издели в ПЗ в Учете
    for CNiz in (
      select n.id_nominizdel 
      from dv.nomenclatura_in_izdel n
      where id_nomizdel_parent_t is null and id_zakaz = FIdZakaz 
        and not (n.id_nominizdel in (select nvl(id_itm, -1) from order_items where id_order = AIdOrder))
    ) 
    loop
      dv.P_SyncIzdel(FIdZakaz, 3, null, null, null, CNiz.id_nominizdel, FIdIzdel);
      dbms_output.put_line('in itm only');
    end loop;  
    --получим количество изделий в итм   
    select count(*) into i from dv.nomenclatura_in_izdel where id_nomizdel_parent_t is null and id_zakaz = FIdZakaz;
    if i = 0 then
      --нет ни одного изделия - удалим заказ и очистим поля в учете
      delete from dv.zakaz where id_order_dv = AIdOrder;
      update orders set id_itm = null where id = AIdOrder;
      update order_items set id_itm = null where id_order = AIdOrder;      
    else
      --иначе финишная процедура итм
      update orders set id_itm = FIdZakaz where id = AIdOrder;
      dv.P_SyncOrder_Finish(AIdOrder);
      if FNeedeSyncBoardsEdges = 1 then
        P_SetOrderEdgesAndBoards(AIdOrder);
      end if;
    end if;
  end if;
 end;
/    
  

begin
  P_SyncOrderWithITM(5427, '179804');
end;
/



exec P_SyncOrderWithITM(3604, '117962');

  select 
    o.sync_with_itm, o.id_itm, o.ornum , o.dt_beg, o.dt_otgr, c.wholesale, o.customer, decode(c.wholesale, 1, o.customer, 'Розница'), organization
    from v_orders o, ref_customers c
    where o.id_customer = c.id and o.id = 5136;


m242136
3604   15875
24? 62

117249
117287

select * from dv.zakaz where numzakaz = 'М242136';
delete from dv.zakaz where numzakaz = 'М242136';
update order_items set id_itm = null where id_order = 3604;
update orders set id_itm = null where id = 3604;       
select * from dv.nomenclatura_in_izdel order by id_nominizdel desc;
select id_itm from order_items where id_order = 3604;

   select n.id_nominizdel 
      from dv.nomenclatura_in_izdel n
      where id_nomizdel_parent_t is null and id_zakaz = 15954 
        and (not (n.id_nominizdel in (select id_itm from order_items where id_order >= 3604)));

select 332119 a from dual where not (3321196 in (select nvl(id_itm, -1) from order_items where id_order >= 3604));

update order_items set qnt = 2 where id = 117249;
update order_items set qnt = 10 where id = 117287;
update order_items set wo_estimate = 0 where id = 117287;


select count(*) from dv.nomenclatura_in_izdel where id_nomizdel_parent_t is null and id_zakaz = 15889;

      select max(id) from estimates where id_order_item = 117249;


va1 := Q.QCallStoredProc('P_SendEstimateToItm', 'idestimate$i;idzakaz$i;idparentizdel$i;count$i', [IdEstimate, OrderIdItm, OrItemIdItm, -1]);




select  sync_with_itm, id_itm, ornum , dt_beg, dt_otgr, decode(FWholeSale, 1, FCustomer, 'Розница') as c, organization
    from v_orders
    order by c desc;
    --where id = AIdOrder;
    

/*==============================================================================
  проверка рассогласования позиций в специикации заказа
  выдает пропущенные значения pos (может быить несколько в одном заказе) для всех заказов

order_max — находит MAX(pos) для каждого id_order.
expected_pos — генерирует все ожидаемые значения pos от 1 до max_pos для каждого заказа.
Трюк PRIOR SYS_GUID() IS NOT NULL нужен в Oracle 11g, чтобы CONNECT BY правильно работал внутри каждой группы id_order.
LEFT JOIN order_items — показывает, каких позиций не хватает (oi.id_order IS NULL).
JOIN orders — добавляет templatename (предполагается, что все id_order из order_items существуют в orders — иначе используйте LEFT JOIN).
*/
With
  -- 1. определяем для каждого заказа максимальную позицию
  order_max as (
    select 
      id_order,
      max(pos) as max_pos
    from order_items
    group by id_order
  ),
  -- 2. генерируем полную последовательность pos от 1 до max_pos для каждого id_order
  expected_pos as (
    select 
      om.id_order,
      level as pos
    from order_max om
    connect by 
      prior om.id_order = om.id_order
      and prior sys_guid() is not null
      and level <= om.max_pos
  )
-- 3. находим отсутствующие pos и подключаем templatename
select 
  ep.id_order,
  ep.pos,
  o.templatename
from expected_pos ep
left join order_items oi 
  on ep.id_order = oi.id_order 
 and ep.pos = oi.pos
join orders o 
  on o.id = ep.id_order
where oi.id_order is null
order by ep.id_order, ep.pos
;



select pos from order_items where id_order = -105;
--поправить так (подстваить айди шаблона и pos из запроса выше)
update order_items set pos = pos - 1 where id_order = -168 and pos > 44;


select id from order_reglaments;
--==============================================================================
-- -99

create or replace procedure P_CreatePspForSemiproducts(
--создаем заказ по шаблону (пока эьто всегда заказ П, но можно поправиль)
--задаем количества для переданных стандартных изделий в заказе
--рассчитывем суммы по азказу
--для изделий с ненулевым количество копируем смету из стандартных
--синхронизируем с итм
  AIdTemplate number,            --айди шаблона
  AStdItems varchar2,            --айди стандартных изделий и их количества, которые надо проставить, в виде id1=qnt1,id5=qnt5,...
  AIdManager number,             --айди менеджера, по которому провети заказ
  AComment varchar2,             --комментарий к заказу
  ADtOtgr date,                  --плановая дата отгрузки  
  AIdReglament number,           --айди регламента 
  AIdType number,                --тип заказа (МТ, Плановый ...)
  AProps varchar2,         --свойства заказов (которые выбираются в окне выбора регламента)
  AIdOrder out number,           --возврат: айди созданного заказа 
  AOrNum out varchar2            --возврат: номер созданного заказа 
)  
as
  FOrnum varchar2(20);
  FOrId number;
  FOrIdOld number;
  FQnt number;
  FIdEst number;
  FSum number(11,2);
  FSumP number(11,2);
  FSumNS number(11,2);
  i number;
  j number;
  st varchar2(1000);
begin
  select max(id) into FOrIdOld from orders;
  --получим номер заказа
  select f_order_getnewnum(trunc(sysdate), -1) into FOrnum from dual;
  --вставим в заказ данные из шаблона
  insert into orders (
    ornum, year, prefix, num, id_type, 
    area, id_organization, id_or_format_estimates, estimatepath, cashtype, wholesale,
    project, id_format, id_manager, 
    dt_beg, dt_otgr, dt_montage_beg, dt_montage_end,
    ndsd, comm, id_reglament, id_type2, ids_order_properties, path
  ) (select
    FOrnum,
    extract(year from sysdate), 'П', substr(FOrnum, 4), 1,
    area, id_organization, id_or_format_estimates, estimatepath, cashtype, wholesale,
    project, id_format, AIdManager, 
    trunc(sysdate), ADtOtgr, dt_montage_beg, dt_montage_end,
    ndsd, 
    AComment, 
    AIdReglament,
    AIdType,
    AProps,
    ''
  from 
    orders
  where
    id = AIdTemplate)
  --returning id into FOrId
  ;
  --получим айди заказа
  select max(id) into FOrId from orders;
  if FOrId <= FOrIdOld then
    raise_application_error(-20000,'Неверный айди шаблона!');
    return;
  end if;
  --вставим изделия из шаблона
  insert into order_items (
    id_order,
    pos, id_std_item, std, nstd, sgp, qnt, comm, wo_estimate, id_kns, id_thn, price, price_pp, 
    r0, r1, r2, r3, r4, r5, r6, r7, r8, r9
  ) select
    FOrId,
    pos, id_std_item, std, nstd, sgp, qnt, comm, wo_estimate, id_kns, id_thn, price, price_pp, 
    r0, r1, r2, r3, r4, r5, r6, r7, r8, r9
  from
    order_items
  where
    id_order = AIdTemplate
   ; 
   

  --для указанных изделий зададим количество и скопируем смету от стандартных изделий
  for COrderItems in (select * from order_items where id_order = FOrId) loop
    i := instr(',' || AStdItems || ',', ',' || COrderItems.id_std_item || '=');
    if i > 0 then
      j := instr(',' || AStdItems || ',', ',', i + 1);
      FQnt := to_number(substr(AStdItems, i + length(to_char(COrderItems.id_std_item)) + 1, j - i - length(to_char(COrderItems.id_std_item)) - 2));
      update order_items set qnt = FQnt where id_order = FOrId and id_std_item = COrderItems.id_std_item; 
      
      insert into estimates (id_std_item, id_order_item, isempty, dt) values 
        (null, COrderItems.id, 0, trunc(sysdate))
        returning id into FIdEst;
      begin  
        select id into i from estimates where id_std_item = COrderItems.id_std_item;
      exception
        when  no_data_found then
        i := null;
      end; 
      if i is not null then
        p_copyestimate(FIdEst, i, FQnt);
      end if;
      
    end if;  
  end loop;
  
  --получим сумму общую и перепродажи
  select sum(round(price * qnt, 2)), sum(round(price_pp * qnt, 2)), sum(decode(sgp, 1, 0, round(price * qnt, 2)) - round(price_pp * qnt, 2))
    into FSum, FSumP, FSumNS 
    from order_items  
    where id_order = FOrId;
  --запишем суммы заказа, ндс для П не выделяется, флага С сгп нет, остальные суммы и наценки остаются null
  --а также зададим путь
  update orders set
    cost = FSum,
    cost_wo_nds = FSum,
    cost_i = FSum - FSumP,
    cost_i_0 = FSum - FSumP,
    cost_a = FSumP,
    cost_a_0 = FSumP,
    cost_d =0,
    cost_m =0,
    cost_i_nosgp = FSumNS,
    path = (select order_prefix from ref_production_areas where id = area) || ornum || ' Производство ' || project
  where id = FOrId;

  --передадим заказа в ИТМ
  P_SyncOrderWithITM(FOrId, '');
  --вернем айди и номер созданного заказа
  AIdOrder := FOrId;
  AOrNum := FOrnum;
end;
/

declare
  i number;
  v varchar2(4000);
begin
  -- -99, 4063, 4064
  P_CreatePspForSemiproducts(-166, '4063=12,4064=123', 33, 'К заказу 1234', trunc(sysdate), 113, i, v);
  
--d_t$i;items$s;id_u$i;comm$s;dt_otgr$d;id_reg$i;id$io;ornum$so = -166 | 6606=20,6608=40,6609=40,6607=20,6617=20,6618=60,6611=60,6610=180,6612=180,5740=240,6615=120,6614=60,6613=60 | 33 | К заказу П260033 | 25.02.2026 | 113 | -1 | -1  
end;
/   


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- данные по заказам и изделиям заказов о количестве плитных материалов и кромки, времени выдачи в производство
-- (на основании данных итм и смет, разделение происходит по айди групп итм, прописано жестко,
-- скрипт выполняется раз в час в серверном процессе и обновляет данные в таблицах заказов)

create or replace view v_orders_send_to_prod as
--заказы, по кторым есть НП на производство с выдачей плитных материалов
--Материалы основы = 14, кромочные = 13
select
--  distinct id_zakaz,  
  id_zakaz,
  min(movebilldate) as dt
from
  dv.move_bill mb,
  dv.move_bill_spec mbs,
  dv.nomenclatura n,
  dv.sklad s
where
  mb.id_movebill = mbs.id_movebill
  and mb.id_docstate = 3
  and mb.id_skladdest = s.id_sklad
  and nvl(s.brigada, 0) = 1
  and mbs.id_nomencl = n.id_nomencl
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (14)  
    connect by prior id_group = id_parentgroup   
)
  group by id_zakaz
  order by id_zakaz desc
;  

create or replace view v_orders_has_prod as
select
--список заказов ИТМ, в которых есть плитные материалы 
  id_zakaz
  --, count(n.name)
from 
  dv.nomenclatura_in_izdel niz,dv.nomenclatura n
where
  niz.id_nomencl = n.id_nomencl 
  and niz.id_nomizdel_parent_t is not null
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (14)  
    connect by prior id_group = id_parentgroup   
  )
  group by id_zakaz
;

create or replace view v_orders_edges_m as
select
--количество кромочных материалов,м.пог.
  oi.id,
  max(oi.id_order) as id_order,
--  max(oi.slash) as slash,
  sum(ei.qnt_itm) as qnt
from 
  v_order_items oi,
  estimates e,
  estimate_items ei,
  bcad_nomencl bn,
  dv.nomenclatura n
where
  oi.id = e.id_order_item
  and ei.id_estimate (+) = e.id
  and ei.id_name = bn.id
  and n.name = bn.name 
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (/*13*/ 2308 /*меламин*/, 2297 /*пвх*/, 2309 /*шпон*/) --кромка 
    connect by prior id_group = id_parentgroup   
  )
  group by oi.id
;

create or replace view v_orders_boards_m2 as
select
--количество плитных материалов (на пильные центры) по заказам
  oi.id,
  max(oi.id_order) as id_order,
--  max(oi.slash) as slash,
  sum(ei.qnt_itm) as qnt
from 
  v_order_items oi,
  estimates e,
  estimate_items ei,
  bcad_nomencl bn,
  dv.nomenclatura n
where
  oi.id = e.id_order_item
  and ei.id_estimate (+) = e.id
  and ei.id_name = bn.id
  and n.name = bn.name 
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (/*14*/ 2284 /*массив щит*/, 2276 /*мдф*/, 18 /*лдсп*/, 2288 /* Пластик HPL*/, 2287 /*Пластик рекламный*/, 2275 /*ХДФ\ДВП*/, 2295 /*Фанера*/, 2283 /*Шпон*/) --плитные 
    connect by prior id_group = id_parentgroup   
  )
  group by oi.id
;

create or replace view v_orders_glass_m2 as
select
--количество стекла и зеркала  по заказам
  oi.id,
  max(oi.id_order) as id_order,
  sum(ei.qnt_itm) as qnt
from 
  v_order_items oi,
  estimates e,
  estimate_items ei,
  bcad_nomencl bn,
  dv.nomenclatura n
where
  oi.id = e.id_order_item
  and ei.id_estimate (+) = e.id
  and ei.id_name = bn.id
  and n.name = bn.name 
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (2278 /*Зеркало*/, 2277 /*Стекло*/)  
    connect by prior id_group = id_parentgroup   
  )
  group by oi.id
;


create or replace view v_orders_paint_kg as
select
--количество стекла и зеркала  по заказам
  oi.id,
  max(oi.id_order) as id_order,
  sum(ei.qnt_itm) as qnt
from 
  v_order_items oi,
  estimates e,
  estimate_items ei,
  bcad_nomencl bn,
  dv.nomenclatura n
where
  oi.id = e.id_order_item
  and ei.id_estimate (+) = e.id
  and ei.id_name = bn.id
  and n.name = bn.name 
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (2475 /*Лак*/, 2807 /*Эмаль\краска*/)  
    connect by prior id_group = id_parentgroup   
  )
  group by oi.id
;


/*
create or replace view v_orders_boards_m2 as
select
--количество плитных материалов (на пильные центры) по заказам
  id_zakaz, 
  count(n.name) as qnt_n,
  sum(niz.count_nomencl) as qnt
from 
  dv.nomenclatura_in_izdel niz,dv.nomenclatura n
where
  niz.id_nomencl = n.id_nomencl 
  and niz.id_nomizdel_parent_t is not null
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (14)  
    connect by prior id_group = id_parentgroup   
  )
  group by id_zakaz
;

create or replace view v_orders_edges_m as
select
--количество кромочных материалов,м.пог.
  id_zakaz, 
  count(n.name) as qnt_n,
  sum(niz.count_nomencl) as qnt
from 
  dv.nomenclatura_in_izdel niz,dv.nomenclatura n
where
  niz.id_nomencl = n.id_nomencl 
  and niz.id_nomizdel_parent_t is not null
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (13)  
    connect by prior id_group = id_parentgroup   
  )
  group by id_zakaz
;

*/


create or replace procedure P_SetOrdersProdData is
begin
  --устанавливает в таблице заказов проиизводственные статусы и данные, взятые из ИТМ
  --(является ли заказ производственныым, дата выдачи в производство, количество плитных и кромочных материалов по смете в изделиях заказа) 

  update orders set dt_to_prod = null;
  merge into orders t1
  using (select id_zakaz, dt from v_orders_send_to_prod) t2
  on (t1.id_itm = t2.id_zakaz)
  when matched then
      update set t1.dt_to_prod = t2.dt;

  update order_items set qnt_boards_m2 = null;
  merge into order_items t1
  using (select id, qnt from v_orders_boards_m2) t2
  on (t1.id = t2.id)
  when matched then
      update set t1.qnt_boards_m2 = t2.qnt;

  update order_items set qnt_edges_m = null;
  merge into order_items t1
  using (select id, qnt from v_orders_edges_m) t2
  on (t1.id = t2.id)
  when matched then
      update set t1.qnt_edges_m = t2.qnt;
      
  update order_items set qnt_glass_m2 = null;
  merge into order_items t1
  using (select id, qnt from v_orders_glass_m2) t2
  on (t1.id = t2.id)
  when matched then
      update set t1.qnt_glass_m2 = t2.qnt;
      
  update order_items set qnt_paint_kg = null;
  merge into order_items t1
  using (select id, qnt from v_orders_paint_kg) t2
  on (t1.id = t2.id)
  when matched then
      update set t1.qnt_paint_kg = t2.qnt;

end;
/


create or replace procedure P_SetOrderEdgesAndBoards(
--заполняет для изделий заказа количество плитных и кромки
  AIdOrder number
) is
begin
  update order_items set qnt_boards_m2 = null where id_order = AIdOrder;
  merge into order_items t1
  using (select id, qnt from v_orders_boards_m2 where id_order = AIdOrder) t2
  on (t1.id = t2.id and t1.id_order = AIdOrder)
  when matched then
      update set t1.qnt_boards_m2 = t2.qnt;
      
  update order_items set qnt_edges_m = null where id_order = AIdOrder;
  merge into order_items t1
  using (select id, qnt from v_orders_edges_m where id_order = AIdOrder) t2
  on (t1.id = t2.id and t1.id_order = AIdOrder)
  when matched then
      update set t1.qnt_edges_m = t2.qnt;

  update order_items set qnt_glass_m2 = null where id_order = AIdOrder;
  merge into order_items t1
  using (select id, qnt from v_orders_glass_m2 where id_order = AIdOrder) t2
  on (t1.id = t2.id and t1.id_order = AIdOrder)
  when matched then
      update set t1.qnt_glass_m2 = t2.qnt;

  update order_items set qnt_paint_kg = null where id_order = AIdOrder;
  merge into order_items t1
  using (select id, qnt from v_orders_paint_kg where id_order = AIdOrder) t2
  on (t1.id = t2.id and t1.id_order = AIdOrder)
  when matched then
      update set t1.qnt_paint_kg = t2.qnt;

end;
/      

begin
P_SetOrdersProdData;
end;
/

begin
P_SetOrderEdgesAndBoards(13476);
end;
/

create or replace procedure P_SetOrderProdData(
  AIdOrder number
)
is
begin
  update order_items set qnt_boards_m2 = null where id_order = AIdOrder;
  merge into order_items t1
  using (select id, qnt from v_orders_boards_m2 where id_order = AIdOrder) t2
  on (t1.id = t2.id)
  when matched then
      update set t1.qnt_boards_m2 = t2.qnt;

  update order_items set qnt_edges_m = null where id_order = AIdOrder;
  merge into order_items t1
  using (select id, qnt from v_orders_edges_m where id_order = AIdOrder) t2
  on (t1.id = t2.id)
  when matched then
      update set t1.qnt_edges_m = t2.qnt;
end;
/


---------------------------- test ----------------------------------------------
select * from v_orders_send_to_prod where id_zakaz = 36648;


select
  id_zakaz,
  min(movebilldate) as dt
from
  dv.move_bill mb,
  dv.move_bill_spec mbs,
  dv.nomenclatura n,
  dv.sklad s
where
id_zakaz = 36648 and
mb.id_movebill = mbs.id_movebill
  --and mb.id_docstate = 3
  and mb.id_skladdest = s.id_sklad
  --and nvl(s.brigada, 0) = 1
  and mbs.id_nomencl = n.id_nomencl
  and n.id_group in ( 
    select id_group
    from dv.groups
    start with id_group in (14)  
    connect by prior id_group = id_parentgroup   
) 
group by id_zakaz
  order by id_zakaz desc
;  


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--таблицы трудоемкости по стандартным изделиям и заказам

--alter table or_std_labor_intensity add i16 number;
create table or_std_labor_intensity (
  id number(11),                   --айди, оно же изделия
  dt_changed date,                 --дфтф изменения записи
  id_area number,                  --айди произволдственной площадки  (0-ПЩ, 2-Лок)
  i0 number,                       --трудоемкость суммарная
  i1 number,                       --трудоемкости по участкам ( 1 = прочие)
  i2 number,                       --трудоемкости по участкам
  i3 number,
  i4 number,
  i5 number,
  i6 number,
  i7 number,
  i8 number,
  i9 number,
  i10 number,
  i11 number,
  i12 number,
  i13 number,
  i14 number,
  i15 number,
  i16 number,
  constraint pk_or_std_labor_intensity primary key (id, id_area),
  constraint fk_or_std_labor_intensity_id foreign key (id) references or_std_items(id) on delete cascade
);  

create or replace trigger trg_or_std_labor_int_bu_r 
  before update on or_std_labor_intensity
  for each row
--фиксируем обновление трудоемкости по данному стандартному изделиию
begin
  if (   nvl(:new.i0, 0) <> nvl(:old.i0, 0)
      or nvl(:new.i1, 0) <> nvl(:old.i1, 0)
      or nvl(:new.i2, 0) <> nvl(:old.i2, 0)
      or nvl(:new.i3, 0) <> nvl(:old.i3, 0)
      or nvl(:new.i4, 0) <> nvl(:old.i4, 0)
      or nvl(:new.i5, 0) <> nvl(:old.i5, 0)
      or nvl(:new.i6, 0) <> nvl(:old.i6, 0)
      or nvl(:new.i7, 0) <> nvl(:old.i7, 0)
      or nvl(:new.i8, 0) <> nvl(:old.i8, 0)
      or nvl(:new.i9, 0) <> nvl(:old.i9, 0)
      or nvl(:new.i10, 0) <> nvl(:old.i10, 0)
      or nvl(:new.i11, 0) <> nvl(:old.i11, 0)
      or nvl(:new.i12, 0) <> nvl(:old.i12, 0)
      or nvl(:new.i13, 0) <> nvl(:old.i13, 0)
      or nvl(:new.i14, 0) <> nvl(:old.i14, 0)
      or nvl(:new.i15, 0) <> nvl(:old.i15, 0)
      or nvl(:new.i16, 0) <> nvl(:old.i16, 0)
     )
  then
    :new.dt_changed := sysdate;
  end if;
end;
/  


create table or_labor_intensity (
  id number(11),
  id_area number,
  i0 number,
  i1 number,
  i2 number,
  i3 number,
  i4 number,
  i5 number,
  i6 number,
  i7 number,
  i8 number,
  i9 number,
  i10 number,
  i11 number,
  i12 number,
  i13 number,
  i14 number,
  i15 number,
  constraint pk_or_labor_intensity primary key (id, id_area),
  constraint fk_or_labor_intensity_id foreign key (id) references order_items(id) on delete cascade
);  

alter table or_std_labor_intensity_cost add p16 number;
alter table or_std_labor_intensity_cost add dt_changed16 date;  
create table or_std_labor_intensity_cost (
  id_area      number,      -- айди производственной площадки (0-ПЩ, 2-Лок)
  p1           number,      -- стоимость минуты по операции
  p2           number,
  p3           number,
  p4           number,
  p5           number,
  p6           number,
  p7           number,
  p8           number,
  p9           number,
  p10          number,
  p11          number,
  p12          number,
  p13          number,
  p14          number,
  p15          number,
  p16          number,
  dt_changed1  date,        -- дата последнего изменения
  dt_changed2  date,        
  dt_changed3  date,        
  dt_changed4  date,        
  dt_changed5  date,        
  dt_changed6  date,        
  dt_changed7  date,        
  dt_changed8  date,        
  dt_changed9  date,        
  dt_changed10 date,        
  dt_changed11 date,        
  dt_changed12 date,        
  dt_changed13 date,        
  dt_changed14 date,        
  dt_changed15 date,        
  dt_changed16 date,        
  constraint pk_or_std_labor_intensity_cost primary key (id_area)
);


create or replace trigger trg_or_std_labor_int_cost_bu_r 
  before update on or_std_labor_intensity_cost
  for each row
begin
  if nvl(:new.p1, 0) <> nvl(:old.p1, 0) then :new.dt_changed1 := sysdate; end if;
  if nvl(:new.p2, 0) <> nvl(:old.p2, 0) then :new.dt_changed2 := sysdate; end if;
  if nvl(:new.p3, 0) <> nvl(:old.p3, 0) then :new.dt_changed3 := sysdate; end if;
  if nvl(:new.p4, 0) <> nvl(:old.p4, 0) then :new.dt_changed4 := sysdate; end if;
  if nvl(:new.p5, 0) <> nvl(:old.p5, 0) then :new.dt_changed5 := sysdate; end if;
  if nvl(:new.p6, 0) <> nvl(:old.p6, 0) then :new.dt_changed6 := sysdate; end if;
  if nvl(:new.p7, 0) <> nvl(:old.p7, 0) then :new.dt_changed7 := sysdate; end if;
  if nvl(:new.p8, 0) <> nvl(:old.p8, 0) then :new.dt_changed8 := sysdate; end if;
  if nvl(:new.p9, 0) <> nvl(:old.p9, 0) then :new.dt_changed9 := sysdate; end if;
  if nvl(:new.p10, 0) <> nvl(:old.p10, 0) then :new.dt_changed10 := sysdate; end if;
  if nvl(:new.p11, 0) <> nvl(:old.p11, 0) then :new.dt_changed11 := sysdate; end if;
  if nvl(:new.p12, 0) <> nvl(:old.p12, 0) then :new.dt_changed12 := sysdate; end if;
  if nvl(:new.p13, 0) <> nvl(:old.p13, 0) then :new.dt_changed13 := sysdate; end if;
  if nvl(:new.p14, 0) <> nvl(:old.p14, 0) then :new.dt_changed14 := sysdate; end if;
  if nvl(:new.p15, 0) <> nvl(:old.p15, 0) then :new.dt_changed15 := sysdate; end if;
  if nvl(:new.p16, 0) <> nvl(:old.p16, 0) then :new.dt_changed16 := sysdate; end if;
end;
/

create or replace view v_or_std_labor_intensity as
select
  i.*,
  nvl(i.i1, 0) +
  nvl(i.i2, 0) +
  nvl(i.i3, 0) +
  nvl(i.i4, 0) +
  nvl(i.i5, 0) +
  nvl(i.i6, 0) +
  nvl(i.i7, 0) +
  nvl(i.i8, 0) +
  nvl(i.i9, 0) +
  nvl(i.i10, 0) +
  nvl(i.i11, 0) +
  nvl(i.i12, 0) +
  nvl(i.i13, 0) +
  nvl(i.i14, 0) +
  nvl(i.i15, 0) + 
  nvl(i.i16, 0) 
  as labor_intensity,
  
  nvl(i.i1, 0) * nvl(p1, 0) + 
  nvl(i.i2, 0) * nvl(p2, 0) + 
  nvl(i.i3, 0) * nvl(p3, 0) + 
  nvl(i.i4, 0) * nvl(p4, 0) + 
  nvl(i.i5, 0) * nvl(p5, 0) + 
  nvl(i.i6, 0) * nvl(p6, 0) + 
  nvl(i.i7, 0) * nvl(p7, 0) + 
  nvl(i.i8, 0) * nvl(p8, 0) + 
  nvl(i.i9, 0) * nvl(p9, 0) + 
  nvl(i.i10, 0) * nvl(p10, 0) + 
  nvl(i.i11, 0) * nvl(p11, 0) + 
  nvl(i.i12, 0) * nvl(p12, 0) + 
  nvl(i.i13, 0) * nvl(p13, 0) + 
  nvl(i.i14, 0) * nvl(p14, 0) + 
  nvl(i.i15, 0) * nvl(p15, 0) +
  nvl(i.i16, 0) * nvl(p16, 0)
  as labor_cost 
from
  or_std_labor_intensity i,  
  or_std_labor_intensity_cost c
where
  c.id_area = i.id_area
;    


































--------------------------------------------------------------------------------
--таблица по типам заказов (рекламация, дозаказ...)   --!!!
alter table order_types add is_production_order number(1);
alter table order_types add is_semiproduct_order number(1);
alter table order_types add is_shipment_order number(1);
alter table order_types add is_additional_order number(1);
alter table order_types add is_nonstandard number(1);
alter table order_types add is_nonstandard_only number(1);
alter table order_types add is_cash_payment number(1);
alter table order_types add is_reference_allowed number(1);
alter table order_types add is_reference_required  number(1);
alter table order_types add need_ref  number(1);
alter table order_types drop column need_ref;

create table order_types (
  id number(11),
  name varchar(100),
  is_production_order number(1),              --может быть производственным заказом
  is_semiproduct_order number(1),             --может быть заказом на полуфабрикаты    
  is_shipment_order number(1),                --может быть отгрузочным заказом
  is_complaint number(1),                     --может быть рекламацией
  is_additional_order number(1),              --может быть дозаказом
  is_nonstandard number(1),                   --может включать нестандартные изделия
  is_nonstandard_only number(1),              --допустимы только нестандартные изделия
  is_cash_payment number(1),                  --допустима оплата за наличные (Ника)
  is_reference_allowed number(1),             --допустима ссылка на другой заказ 
  is_reference_required  number(1),           --обязательна ссылка на другой заказ
  active number(1), 
  pos number(3),
  posstd number(4),
  constraint pk_order_types primary key (id)
);   

create unique index idx_order_types on order_types lower(name);
  
create sequence sq_order_types nocache start with 100;

create or replace trigger trg_order_types_bi_r
  before insert on order_types for each row
begin
  if :new.id is null then 
    select sq_order_types.nextval into :new.id from dual;
    :new.pos := :new.id;
  end if;
end;
/

/*
begin
insert into order_types (id, name, posstd, need_ref, active) values (1, 'Новый на СГП', 1, 0, 1);
insert into order_types (id, name, posstd, need_ref, active) values (2, 'Дозаказ', 2, 1, 1);
insert into order_types (id, name, posstd, need_ref, active) values (3, 'Рекламация', 3, 1, 1);
insert into order_types (id, name, posstd, need_ref, active) values (4, 'Эксперимент', 4, 0, 1);
--insert into order_types (id, name, posstd, need_ref, active) values (1, '', 1, 0, 1);
end;
/
*/

create or replace view v_order_types as
  select 
    ot.*,
    case 
      when posstd is null then pos
      when nvl(posstd, 0) > 0 then posstd
      when nvl(posstd, 0) < 0 then 10000 - posstd
    end as posall
  from 
    order_types ot
;  



--таблица свойств заказа, влияющих на сроки его прохождения по участкам
--alter table order_properties add 
create table order_properties (
  id number(11),
  name varchar(100),
  active number(1),
  grp number(2), 
  pos number(3),
  constraint pk_order_properties primary key (id)
);   

create unique index idx_order_properties_name on order_properties lower(name);
  
create sequence sq_order_properties nocache start with 100;

create or replace trigger trg_order_properties_bi_r
  before insert on order_properties for each row
begin
  if :new.id is null then 
    select sq_order_properties.nextval into :new.id from dual;
    :new.pos := :new.id;
  end if;
end;
/


--таблица доступных свойств для всех типов заказов
create table order_properties_for_type (
  id_type number(11),
  id_property number(11),
  use_property number(1), 
  constraint pk_order_properties_for_type primary key (id_type, id_property),
  constraint fk_order_properties_for_type_t foreign key (id_type) references order_types(id) on delete cascade, 
  constraint fk_order_properties_for_type_p foreign key (id_type) references order_properties(id) on delete cascade 
);   

create or replace view v_order_properties_for_type as
select
--выведем используемые свойства для всех типов заказов
  t.id as id_type,
--  p.id as id_property,
  p.*,
  case when pt.id_type is not null then 1 else 0 end as used
from 
  order_types t
  cross join order_properties p
  left join order_properties_for_type pt on pt.id_type = t.id and pt.id_property = p.id and p.active = 1
;

select * from v_order_properties_for_type;


--регламенты заказов (список решламентов)
alter table order_reglaments add sn_4 number; 
create table order_reglaments (
  id number(11),
  name varchar2(4000),
  ids_types varchar2(4000),   
  ids_properties varchar2(4000),   
  types varchar2(4000),   
  properties varchar2(4000),   
  sn_1 number,
  sn_2 number,
  sn_3 number,
  sn_4 number,
  deadline number,
  active number(1),
  constraint pk_order_reglaments primary key (id)
);   

create unique index idx_order_reglaments_name on order_reglaments lower(name);
  
create sequence sq_order_reglaments nocache start with 100;

create or replace trigger trg_order_reglaments_bi_r
  before insert on order_reglaments for each row
begin
  select sq_order_reglaments.nextval into :new.id from dual;
end;
/


--регламенты заказов, строки регламента
drop table order_reglament_items cascade constraints;
--alter table order_reglament_items  add color number;
create table order_reglament_items (
  id number(11),
  id_reglament number(11),
  id_work_cell_type number(11),
  day_beg number(3),
  day_end number(3),
  color number,
  constraint pk_order_reglament_items primary key (id),
  constraint fk_order_reglament_items_r foreign key (id_reglament) references order_reglaments(id) on delete cascade 
);   

create sequence sq_order_reglament_items nocache start with 100;

create or replace trigger trg_order_reglament_items_bi_r
  before insert on order_reglament_items for each row
begin
  select sq_order_reglament_items.nextval into :new.id from dual;
end;
/




--------------------------------------------------------------------------------
--задвоившиеся id_order_dv в ИТМ
SELECT *
FROM dv.zakaz
WHERE id_order_dv IN (
    SELECT id_order_dv
    FROM dv.zakaz
    WHERE id_order_dv IS NOT NULL
    GROUP BY id_order_dv
    HAVING COUNT(*) > 1
)
ORDER BY id_order_dv;

--------------------------------------------------------------------------------
--выгрузка станлдартных изделий



/*
ОТМЕНИЛ!!!


--таблица по типам материалов в зказов (например, покупной металл), от
--которых зависит срок изготовления заказа
create table order_material_types (
  id number(11),
  name varchar(100),
  active number(1), 
  constraint pk_order_material_types primary key (id)
);   

create unique index idx_order_material_types on order_material_types lower(name);
  
create sequence sq_order_material_types nocache start with 100;

create or replace trigger trg_order_material_types_bi_r
  before insert on order_material_types for each row
begin
  if :new.id is null then 
    select sq_order_material_types.nextval into :new.id from dual;
  end if;
end;
/

--таблица по срокам выполнения заказа в зависимости от метериалов
create table order_completion_times (
  id_order_type number(11),
  id_order_material_type number(11),
  days number(3),
  constraint pk_order_completion_times_or primary key (id_order_type, id_order_material_type), 
  constraint fk_order_completion_times_or foreign key (id_order_type) references order_types(id),
  constraint fk_order_completion_times_mat foreign key (id_order_material_type) references order_material_types(id)
);   


--маршрут движения изделий заказа по площадкам
create table order_item_route (
  id number(11),
  id_order_item number(11),
  id_work_cell number(11),
  active number(1),
  dt_planned_beg date, 
  dt_planned_end date, 
  dt_beg date, 
  dt_end date, 
  constraint pk_order_item_route primary key (id),
  constraint fk_order_item_route_item foreign key (id_order_item) references order_items(id),
  constraint fk_order_item_route_work_cell foreign key (id_work_cell) references work_cells(id)
);   

create index idx_order_item_route_items on order_item_route(id_order_item);
  
create sequence sq_order_item_route nocache start with 100;

create or replace trigger trg_order_item_route_bi_r
  before insert on order_item_route for each row
begin
  if :new.id is null then 
    select sq_order_item_route.nextval into :new.id from dual;
  end if;
end;
/

*/


select id, need_ref, is_complaint, (select count(*) from order_reglaments where instr(',' || ids_types || ',',  ',' || t.id || ',') > 0 and active = 1) from v_order_types t;

select * from v_order_items where id_order = 11674;
select * from v_orders_list where id_order = 11674;



--------------------------------------------------------------------------------
-- получение информации по заказам и стандартным изделиям
--------------------------------------------------------------------------------

--список всех стаандартных изделий
select or_format_name, or_format_estimate_name, prefix, name from v_or_std_items where id_format <> 0 order by or_format_name, or_format_estimate_name, name;
--список стандартных изделий, запцущенныых по заказам текущего года
select 
  or_format_name, or_format_estimate_name, prefix, name
from 
  v_or_std_items i
where 
  id_format in (select distinct id_or_format_estimates from orders where dt_beg >= date '2026-01-01') 
order by 
  or_format_name, or_format_estimate_name, name
;
--список отгруженных с сгп в этом году, по заказам этого же года
--(последнее по факту лишнее сравнение наверное!)
select 
  or_format_name, or_format_estimate_name, prefix, name, sum(s.qnt) as qnt 
from 
  v_or_std_items i,
  order_items oi,
  (select id_order_item, sum(qnt) as qnt from order_item_stages where dt >= date '2026-01-01' and id_stage = 3 group by id_order_item) s
where 
  oi.id_std_item = i.id
  and s.id_order_item = oi.id
  and id_format <> 0 
  and id_format in (select distinct id_or_format_estimates from orders where dt_beg >= date '2026-01-01') 
  and s.qnt > 0
group by 
  or_format_name, or_format_estimate_name, name, prefix
order by 
  or_format_name, or_format_estimate_name, name
;








