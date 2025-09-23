Alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;

--------------------------------------------------------------------------------
--найти все пропуски позиции в заказе
SELECT pos - 1 AS missing_number
FROM (
    SELECT pos,
           LAG(pos) OVER (ORDER BY pos) AS prev_pos
    FROM order_items where id_order = -90
)
WHERE pos - prev_pos > 1;







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
--alter table orders drop column attention;

alter table orders add dt_to_prod date;
--alter table orders add has_prod number(1) default 0;
/*alter table orders add qnt_boards_m2 number;
alter table orders add qnt_edges_m number;
alter table orders add qnt_panels_w_drill number;
alter table orders add has_prod number(1) default 0;
*/
--alter table orders add constraint fk_orders_id_complaint_reasons foreign key (id_complaint_reasons) references ref_complaint_reasons(id);
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
  area number(1) default 0,          -- производственная площадка (0 - ПЩ, 1 - Инженерный)
  estimatepath varchar2(400),        -- путь к сметам для стандартных шаблонов 
  cashtype number(1),                -- 2 - наличные, 1 - безнал
  wholesale number(1),               -- 2 - розница, 1 - опт
  project varchar2(400),             -- название проекта
  address varchar2(400),             -- адрес отгруузки 
  account varchar2(400),             -- счет
  id_format number(11),              -- айди формата паспорта (0 - общий, Х - КБ ...)
  id_target number(11),
  target varchar2(40),               -- подпапка в стандартных проектах итм (П - производство, остальные берутся из справочника стандартных форматов) 
  id_type number(1),                 -- 1 - новый, 2 рекламация, 3 эксперимент 
  or_reference varchar(16),          -- номер заказа, по которому рекламация, в виде текста 
  id_manager number(11),             -- айди человека, оформившего заказ
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
  upd varchar2(20),                  -- номер УПД 
  pay number(12,2),                  -- суммарный платеж по заказу (поступление денег в кассу)
  pay_n number(12,2),                -- суммарный промежуточный платеж по заказу (по заказам Н)
  dt_cancel date,                    -- дата останоки/отмены заказа 
  attention number(3)  default 0,    -- признак внимания к ячеке (пока только комментарий - выделена цветом в паспорте)
  --qnt_boards_m2 number,              -- метраж плитных материалов 
  --qnt_edges_m number,                -- метраж кромки
  --qnt_panels_w_drill number,         -- количество панелей со сверловкой 
  has_prod number(1) default 0,      -- в составе заказа есть про изводственные материалы 
  constraint pk_orders primary key (id),
  constraint fk_orders_format foreign key (id_format) references or_formats(id),
  constraint fk_orders_manager foreign key (id_manager) references adm_users(id),
  constraint fk_orders_organization foreign key (id_organization) references ref_sn_organizations(id),
  constraint fk_orders_customer foreign key (id_customer) references ref_customers(id),
  constraint fk_orders_customer_contact foreign key (id_customer_contact) references ref_customer_contact(id),
  constraint fk_orders_customer_org foreign key (id_customer_org) references ref_customer_legal(id),
  constraint fk_orders_estimates foreign key (id_or_format_estimates) references or_format_estimates(id)
  --constraint fk_orders_id_complaint_reasons foreign key (id_complaint_reasons) references ref_complaint_reasons(id) 
);

--create unique index idx_order_num on or_formats(lower(name));
create unique index idx_orders_templatename on orders(lower(templatename));
create index idx_orders_dt_beg on orders(dt_beg);

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



--update orders set ndsd = 1;
--update orders set ndsd = 1.2 where nvl(cost, 0) > nvl(cost_wo_nds, 0); 


create or replace view v_orders as (
  select
  --базовая информацияпо заказу
    o.*,
    ro.name as organization,
    rc.name as customer,
    rcc.name as customerman,
    rcc.contact as customercontact,
    rcl.legalname as customerlegal,
    rcl.inn as customerinn,
    au.name as managername,
    (case 
      when o.id_type = 1 then 'новый'
      when o.id_type = 2 then 'рекламация'
      when o.id_type = 3 then 'эксперимент'
      else ''
    end) as typename,
    pa.shortname as area_short,
    decode(o.wholesale, 1, 'опт', 2, 'розница', '') as wholesalename,
    f.name as format,
    (case 
      when o.cashtype = 2 then 'наличные'
      when o.cashtype = 1 and o.account is null then 'безнал (нет счета)'
      when o.cashtype = 1 and o.account is not null then 'безнал'
      else ''
    end) as cashtypename,
    (case 
      when o.cashtype = 1 and o.account is null then 0
      else o.cashtype
    end) as cashtype_add,
    round(nvl(cost_i, 0) / ndsd, 2) cost_i_wo_nds,
    round(nvl(cost_i_nosgp, 0) / ndsd, 2) cost_i_nosgp_wo_nds,
    round(nvl(cost_a, 0) / ndsd, 2) cost_a_wo_nds,
    round(nvl(cost_d, 0) / ndsd, 2) cost_d_wo_nds,
    round(nvl(cost_m, 0) / ndsd, 2) cost_m_wo_nds,
    (case when dt_cancel is null then 0 else 1 end) as cancel, 
    dt_beg + trunc(((dt_otgr - dt_beg) / 2)) as dt_pnr,  -- плановая дата начала распила
   (select 
       listagg(oc.name,  '; ') within group (order by oc.name) 
       from ((select o.id, o.id_order, r.name from order_complaints o, ref_complaint_reasons r where o.id_complaint_reason = r.id) oc ) 
       where id_order = o.id
    ) complaints,
    (select 
       regexp_replace(listagg(case when no <= 250 then t.name || ';' else '' end) within group (order by t.name), '([^;]+)(;\1)+', '\1' )
       from ((select i.id_order, u.name, row_number() over (order by u.name) no from order_items i, adm_users u where i.qnt <> 0 and u.id = i.id_thn and i.id_thn <> -100) t ) 
       where id_order = o.id
    ) as thn,
    decode(nvl(othn.cnt, 0), 0,  '', '[технолог]') as to_thn,
    (select 
       regexp_replace(listagg(case when no <= 250 then t.name || ';' else '' end) within group (order by t.name), '([^;]+)(;\1)+', '\1' )
       from ((select i.id_order, u.name, row_number() over (order by u.name) no from order_items i, adm_users u where i.qnt <> 0 and u.id = i.id_kns and i.id_kns <> -100) t ) 
       where id_order = o.id
    ) as kns,
    decode(nvl(okns.cnt, 0), 0,  '', '[конструктор]') as to_kns,
    he.estimates,
    he.dt_estimate_max,
    osn.qnt_sn_no,
    decode(nvl(osn.qnt_sn_no, 0), 0, '+', '-') as sn_status,
    decode(othndt.dt_thn_cnt, othndt.cnt, othndt.dt_thn_max, null) as dt_thn_max,
    trunc(dt_aggr_estimate - dt_beg) as days_aggr_estimate,
    --opc.sum0
    --0 as sum0
    --(select sum0 from v_order_primecost_itm where id_zakaz(+) = o.id_itm) as sum0
    F_GetCostOrderItemsFromItm(o.id, null) as sum0,
    --статус заказа в итм (выполнен = 30)
    sz.id_status as id_status_itm,
    sz.statusname as status_itm,
    trunc(rsv.dt_reserve) as dt_reserve,
    timemsqnt.qnt_slashes as qnt_slashes,
    timemsqnt.qnt_items as qnt_items,
    timemsqnt.qnt_in_prod as qnt_in_prod,
    timemsqnt.qnt_to_sgp as qnt_to_sgp
  from
    orders o,
    ref_sn_organizations ro,
    ref_customers rc,
    ref_customer_contact rcc,
    ref_customer_legal rcl,
    or_formats f,
    ref_production_areas pa, 
    adm_users au,
    v_order_hasestimate he,
    --v_order_primecost_itm opc,
    (select max(id_order) as id_order, count(id_kns) as cnt from order_items where qnt > 0 and id_kns is not null and id_kns <> -100 group by id_order) okns, 
    (select max(id_order) as id_order, count(id_thn) as cnt from order_items where qnt > 0 and id_thn is not null and id_thn <> -100 group by id_order) othn,
    (select max(id_order) as id_order, max(dt_thn) as dt_thn_max, sum(decode(dt_thn, null, 0, 1)) as dt_thn_cnt, 
       count(id_thn) as cnt from order_items where qnt > 0 and id_thn is not null and id_thn <> -100 group by id_order) othndt,
    (select max(id_order) as id_order, count(*) as qnt_sn_no from order_items where dt_sn is null and qnt <> 0 group by id_order) osn,
    (select id_order, sum(case when qnt > 0 then 1 else 0 end) qnt_slashes, sum(qnt) as qnt_items, sum(case when nvl(sgp, 0) = 1 then 0 else qnt end) - sum(qnt_to_sgp) as qnt_in_prod, sum(qnt_to_sgp) as qnt_to_sgp from order_items group by id_order) timemsqnt,
    dv.zakaz z,
    dv.status_zakaza sz,
    (select id_doc, max(log_date) as dt_reserve from dv.stock where agentcode = 'ZAKAZ' and doctype = 27 group by id_doc) rsv
  where
    ro.id(+) = o.id_organization and
    rc.id(+) = o.id_customer and  
    rcc.id(+) = o.id_customer_contact and  
    rcl.id(+) = o.id_customer_org and
    f.id(+) = o.id_format and 
    au.id(+) = o.id_manager and
    pa.id(+) = o.area and
    --opc.id_zakaz(+) = o.id_itm and
    he.id_order (+) = o.id
    and okns.id_order (+) = o.id
    and othn.id_order (+) = o.id
    and othndt.id_order (+) = o.id
    and osn.id_order (+) = o.id
    and z.id_zakaz (+) = o.id_itm
    and sz.id_status (+) = z.id_status
    and rsv.id_doc (+) = o.id_itm
    and timemsqnt.id_order (+) = o.id
);

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
--alter table order_items add disassembled number default 0;
--alter table order_items add control_assembly number default 0;  
--alter table order_items add qnt_to_sgp number default 0; 
--alter table order_items add constraint fk_order_items_std_item foreign key (id_std_item) references or_std_items(id);
--alter table order_items drop column id_itm_group;
alter table order_items add qnt_boards_m2 number;
alter table order_items add qnt_edges_m number;
alter table order_items add qnt_panels_w_drill number;

----drop table order_items cascade constraints;
create table order_items (
  id number(11),
  id_order number(11),               --айди заказа
  pos number(11),                    --позиция в паспорте
  id_itm number(11), 
  id_std_item number(11),            --айди наименования изделия в or_std_item (и для стандартных и нестандартных)  
  std number(1),                     --1 для стандартных изделий
  nstd number(1),                    --иначе, 1 для нестандартных изделий 
  sgp number(1),                     --отгрузка позиции с сгп
  qnt number(12,3),                  --количество
  comm varchar2(400),                --комментарий
  wo_estimate number(1) default 0,   --изделие не требует смету  
  id_kns number(11),                 --айди конструктора, или -100 = нет, или -101 = [конструктор] (любой)
  id_thn number(11),                 --технолог 
  price number(12,2),                --цена позиции общая без учета скидок 
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
  r9 number(1),
  ch varchar(4000),                  -- изменения, сделанные к данному слешу, имена полей memtable через запятую
  attention number(3) default 0,     -- признак внимания к ячеке строки (выделена цветом в паспорте)
  dt_sn date,                        -- отметка по слешу, что заказ обработан снабжением   
  dt_thn date,                       -- дата, когда по слэшу загружены документы технологов
  disassembled number default 0,     -- в разборе
  control_assembly number default 0, -- контрольная сборка  
  qnt_to_sgp number default 0,       -- количество принятых на сгп изделий по слэшу 
  qnt_boards_m2 number,              -- метраж плитных материалов 
  qnt_edges_m number,                -- метраж кромки
  qnt_panels_w_drill number,         -- количество панелей со сверловкой 
  constraint pk_order_items primary key (id),
  constraint fk_order_items_id_order foreign key (id_order) references orders(id) on delete cascade,
  constraint fk_order_items_kns foreign key (id_kns) references adm_users(id),
  constraint fk_order_items_thn foreign key (id_thn) references adm_users(id),
  constraint fk_order_items_std_item foreign key (id_std_item) references or_std_items(id)
);  

create unique index idx_order_items_pos on order_items(id_order, pos);
create index idx_order_items_id_order on order_items(id_order);
create index idx_order_items_id_std_item on order_items(id_std_item);

create sequence sq_order_items nocache;

create or replace trigger trg_order_items_bi_r
  before insert on order_items for each row
begin
  select sq_order_items.nextval into :new.id from dual;
end;
/


create or replace view v_order_items as (
  select
    i.*,
    o.ornum,
    o.id_organization,
    o.area,
    o.customer,
    o.project,
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
    (case 
      when ee.id > 0 then ee.prefix
      --when i.resale = 1 then 'ДК'
      else ''
    end) prefix, 
    (case 
--      when ee.id > 0 then ee.prefix || '_' else ''
      when ee.id > 0 then ee.prefix || '_'
      --when i.resale = 1 then 'ДК_'
      else ''
    end) || s.name  as fullitemname,  --наименование с префиксом формата, только для стандартных изделий и стандартной д/к
/*   (case 
      when i.id_std_item is not null then s.name else i.name
    end) as itemname,
   (case 
      when o.id_or_format_estimates > 0 then e.prefix || '_' else ''
    end) 
   ||
   (case 
      when i.id_std_item is not null then s.name else i.name
    end) as fullitemname,*/
    F_OrItemRoute(i.r1,i.r2,i.r3,i.r4,i.r5,i.r6,i.r7,i.r8,i.r9) as route,
    F_OrItemRoute(i.r1,i.r2,i.r3,i.r4,i.r5,i.r6,i.r7,i.r8,i.r9) as route2,
--    F_OrItemRoute2(i.r1,i.r2,i.r3,i.r4,i.r5,i.r6,i.r7,i.r8,i.r9,i.resale) as route2,
    es.dt as dt_estimate,
--    (select sum0 from v_order_items_primecost_itm where id_itm(+) = i.id_itm) as sum0
    F_GetCostOrderItemsFromItm(o.id, i.id) as sum0,
    (round(nvl((i.price - i.price_pp)*i.qnt*(1 + nvl(o.m_i,0) * 0.01 - nvl(o.d_i,0) * 0.01) / o.ndsd, 0)) +
     round(nvl((i.price_pp)*i.qnt*(1 + nvl(o.m_a,0) * 0.01 - nvl(o.d_a,0) * 0.01) / o.ndsd, 0))) as cost_wo_nds,
    niz.cnt as has_itm_est,
    case when nvl(i.sgp, 0) = 1 then 0 else i.qnt - i.qnt_to_sgp end as qnt_in_prod 
--    1 as has_itm_est 
  from
    order_items i,
    v_orders o,
    or_std_items s,
    or_format_estimates fe, 
    or_format_estimates ee, 
    adm_users uk,
    adm_users ut,
    estimates es,
    dv.nomenclatura n,
    (select id_nomizdel_parent_t, count(*) as cnt from dv.nomenclatura_in_izdel group by id_nomizdel_parent_t) niz
 where
   i.id_order = o.id and
   i.id_std_item = s.id (+) and
   s.id_or_format_estimates = ee.id (+) and
   o.id_or_format_estimates = fe.id (+) and
   i.id_kns = uk.id (+) and
   i.id_thn = ut.id (+) and
   i.id = es.id_order_item (+) and
   i.id_itm = n.id_nomencl (+) and
   i.id_itm = niz.id_nomizdel_parent_t (+)
);

select * from v_order_items where id_itm is not null and qnt > 0 and has_itm_est is null and dt_estimate is not null and dt_beg > to_date('01.04.2025', 'DD.MM.YYYY');   

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
--alter table or_std_items add by_sgp number(1) default 0;
create table or_std_items (
  id number(11),
  id_or_format_estimates number(11),   --айди типа сметы (КБ/Производство)
  name varchar2(400),                  --наименование изделия
  price number(12,2),                  --цена
  price_pp number(12,2),               --цена перепродажи, входит в итоговую цену, не больше ее (всегда равна в случае д/к)
  wo_estimate number(1) default 0,     --если 1, то смета не требуется (по факту требуется запись в estimates с полем isempty = 1)
  type_of_semiproduct number(11),      --тип полуфабриката, соотвествует одному из участков
  barcode_c varchar2(100),             --штрих-код
  r0 number(1) default 0,              --если 1, то производдственный маршрут не задается
  by_sgp number(1) default 0,          --для данного изделия ведется учет СГП по стандартным изделиям 
  
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

create or replace view v_or_std_items as (
  select
    i.*,
    fi.prefix,
    fi.id_format,
    fi.type,
    orf.name as or_format_name,
    decode(fi.id, 0, '', fi.prefix || '_') || i.name as fullname,
    --F_OrItemRoute(i.r1,i.r2,i.r3,i.r4,i.r5,i.r6,i.r7,i.r8,i.r9) as route,
    F_OrItemRoute(i.r1,i.r2,i.r3,i.r4,i.r5,i.r6,i.r7,i.r8,i.r9) as route2,
    e.dt as dt_estimate,
    prc.sum as priceraw
    ,rtrim(
    (select 
       regexp_replace(listagg(t.code || ', ') within group (order by t.pos), '([^\,]+)(\,\1)+', '\1' )
       from ((select i.id_or_std_item, t.code, t.pos from work_cell_types t, or_std_item_route i where t.id = i.id_work_cell_type)) t
       where id_or_std_item = i.id
    ), ', ') as route,
    fi.is_semiproduct
  from
    or_std_items i,
    estimates e,
    or_format_estimates fi,
    or_formats orf,
    v_fin_stditem_raw_prices prc
  where
   i.id = e.id_std_item (+)
   and orf.id = fi.id_format 
   and i.id_or_format_estimates = fi.id
   and prc.id(+) = i.id
);   

((select i.id_or_std_item, t.code, t.pos, row_number() over (order by t.pos) no from work_cell_types t, or_std_item_route i where t.id = i.id_work_cell_type));

select count(*) from v_or_std_items;

select route, route2 from v_or_std_items;


create or replace procedure P_SetStdItemPrice(
--установка цены всего изделия и перепродажи для него (включаемая) в позиции справочника стандартных изделий
  IdStdItem number,  --айди стандартного изделия                      
  PriceNew number,   --новая цена (или общая изделия, или перепродажи в нем)                  
  PriceType number   --1, если это цена изделия, иначе цена перепродажи
) is 
  Idformat number;
  PriceOld number(11,2);
  PricePpOld number(11,2);
begin
  --получим данные по этому изделию
  select id_or_format_estimates, nvl(price,0), nvl(price_pp,0) into IdFormat, PriceOld, PricePpOld from or_std_items where id = IdStdItem;
    --это не д/к
    if PriceType = 1 then 
      --если устанавливаем цену изделия, то попутно скорректируем цену перепродажи в нем, чтобы была не более цены изделия
      update or_std_items set price = PriceNew, price_pp = least(PriceNew, PricePpOld) where id = IdStdItem;
    else
      --если передали цену перепродажи, то установим ее не более чем цена изделия
      update or_std_items set price_pp = least(PriceNew, PriceOld) where id = IdStdItem;
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
  проверка рассогласования позиций в специикации заказа с общим количеством
  (максимальная позиция не соотвествует количеству позиций)
*/
select 
  id_order,
  max(pos),
  count(*) 
from 
  order_items i 
where
  id_order < 0
  or 1 = 1 
group by
  id_order
having   
  count(*) <> max(pos)
; 

--поправить так
update order_items set pos = pos - 1 where id_order = -999989 and pos > 10;


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
  ndsd, comm, path
  ) (select
    FOrnum,
    extract(year from sysdate), 'П', substr(FOrnum, 4), 1,
    area, id_organization, id_or_format_estimates, estimatepath, cashtype, wholesale,
    project, id_format, AIdManager, 
    trunc(sysdate), ADtOtgr, dt_montage_beg, dt_montage_end,
    ndsd, 
    AComment, 
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
      select id into i from estimates where id_std_item = COrderItems.id_std_item; 
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
  P_CreatePspForSemiproducts(-99, '4063=12,4064=123', 33, 'К заказу 1234', trunc(sysdate), i, v);
end;
/   

delete from orders where id = 7843;

select instr(',' || '4063=12,4064=123' || ',', ',' || '4063' || '=') from dual;
      select instr(',' || '4063=12,4064=123' || ',', ',', 1 + 1) from dual;

 select path from orders where id = -99;
 
select id, ornum, area_short as area, typename as id_type, or_reference, project, customer, customerlegal, customerman, customercontact, address,
address, account, organization as id_organization, dt_beg, dt_otgr, dt_montage_beg, managername, comm, ch
from v_orders where id = 7956;

select * from v_orders where id = 7956;
select pos, slash, fullitemname, qnt, std, nstd, sgp, r1, r2, r3, r4, r5, r6, r7, kns, thn, comm from v_order_items where id_order = 7956;








select 
  count(i.qnt) as qnt_slash,
  sum(i.qnt) as qnt_items,
  sum(case when i.sgp <> 1 then i.qnt - s.qnt end) as qnt_wo_otk,
  count(distinct(i.id_order)) as qnt_orders
from
  order_items i,
  orders o,
  (select id_order_item, sum(qnt4) as qnt from v_order_item_stages1 group by id_order_item) s
where
  i.id_order > 0 and i.qnt > 0
  and s.id_order_item (+) = i.id
  and o.id = i.id_order
  and o.dt_beg >= '01/01/2025'  
--group by id_order  
;    


























--------------------------------------------------------------------------------


--таблица по типам заказов (рекламация, дозаказ...)
alter table order_types add posstd number(4);
create table order_types (
  id number(11),
  name varchar(100),
  need_ref number(1),
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

begin
insert into order_types (id, name, posstd, need_ref, active) values (1, 'Новый на СГП', 1, 0, 1);
insert into order_types (id, name, posstd, need_ref, active) values (2, 'Дозаказ', 2, 1, 1);
insert into order_types (id, name, posstd, need_ref, active) values (3, 'Рекламация', 3, 1, 1);
insert into order_types (id, name, posstd, need_ref, active) values (4, 'Эксперимент', 4, 0, 1);
--insert into order_types (id, name, posstd, need_ref, active) values (1, '', 1, 0, 1);
end;
/

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

