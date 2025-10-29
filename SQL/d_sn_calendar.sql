
--------------------------------------------------------------------------------
-- ПЛАТЕЖНЫЙ КАЛЕНДАРЬ ---------------------------------------------------------
--------------------------------------------------------------------------------

alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';

-- ТАБЛИЦА СЧЕТОВ
--alter table sn_calendar_accounts add nds number(4,2) default 0;
--alter table sn_calendar_accounts add accounttype number(1) default 0;
--update sn_calendar_accounts set agreed2dt=dt, receiptdt = dt;
--alter table sn_calendar_accounts add nds number(4,2);
--alter table sn_calendar_accounts add constraint fk_sn_calendar_accounts_who1 foreign key (id_whoagreed1) references adm_users(id);
create table sn_calendar_accounts(
  id number(12),
  type number(1),               -- 2 - наличные, 1 - безнал
  account varchar2(400),        -- счет
  dt date,                      -- дата создания счета
  accountdt date,               -- дата из документа-счета
  id_expenseitem number(11),    -- статья расходов
  id_supplier number(11),       -- айди поставщика 
  id_org number(11),            -- айди плательщика
  id_user number(11),           -- айди пользователя, создавшего дукумент
  sum number(11,2),             -- сумма счета
  filename varchar2(400),       -- имя файл счета  
  comm varchar2(400),           -- примечание
  boss_comm varchar2(400),      -- примечание директора
  receiptdt date,               -- дата получения тмц по счету (склад)
  agreed2dt date,               -- дата согласования директором
  agreed1 number(1),            -- согласовано, руководитель (или кому разрешено согласование)
  id_whoagreed1 number(11),     -- кто согласовал счет от имени руководителя
  agreed2 number(1),            -- согласовано (директор)
  agreed2auto number(1),        -- если 1, то согласование директора не трубуется  
  accounttype number(1) default 0,   -- тип счета по этой статье (0-обычный, 1-транспорт отгрузки, 2-транспорт снабжения, 3-подрядчик по монтажу)
  nds number(4,2),              -- ставка ндс 
  constraint pk_sn_calendar_accounts primary key (id),
--  constraint fk_sn_calendar_accounts_user foreign key (id_user) references users(id_user),
  constraint fk_sn_calendar_accounts_exp foreign key (id_expenseitem) references ref_expenseitems(id),
  constraint fk_sn_calendar_accounts_org foreign key (id_org) references ref_sn_organizations(id),
  constraint fk_sn_calendar_accounts_who1 foreign key (id_whoagreed1) references adm_users(id),
  constraint fk_sn_calendar_accounts_spl foreign key (id_supplier) references ref_suppliers(id)
);


--pdate sn_calendar_accounts set nds = 0 where type = 2 or accounttype <> 0; 
--pdate sn_calendar_accounts set nds = 20 where type = 1 and accounttype = 0; 


--drop sequence sq_calendar_accounts;
create sequence sq_sn_calendar_accounts start with 250 nocache;

create index idx_sn_calendar_accounts_1 on sn_calendar_accounts(id_expenseitem);
create index idx_sn_calendar_accounts_2 on sn_calendar_accounts(id_supplier);
create index idx_sn_calendar_accounts_3 on sn_calendar_accounts(dt);
create index idx_sn_calendar_accounts_4 on sn_calendar_accounts(accountdt);

--select (select legalname from ref_suppliers where id = id_supplier), id from uchet.sn_calendar_accounts; 

--insert into sn_calendar_accounts (
--  id, type, account, dt, accountdt, id_expenseitem, id_supplier, id_org, id_user, sum, filename, comm, agreed1, agreed2, agreed2auto )
--  select id, type, account, dt, accountdt, id_expenseitem, id_supplier, id_org, id_user, sum, filename, comm, agreed1, agreed2, agreed2auto from uchet.sn_calendar_accounts;  

update sn_calendar_accounts a set id_whoagreed1 = (select e.agreed from ref_expenseitems e where a.id_expenseitem = e.id) where a.agreed1 = 1;



--ТАБЛИЦА ПЛАТЕЖЕЙ ПО СЧЕТАМ
--drop table sn_calendar_payments cascade constraints;
--alter table sn_calendar_payments add dtpaid date;
create table sn_calendar_payments(
  id number(12),
  id_account number(11),       -- айди счета в таблице счетов
  dt date,                     -- дата, на которую запланирована оплата
  sum number(11,2),            -- сумма платежа (сколько запланировано, оплачивается всегда столько же
  status number(1),            -- стутус - 1 = оплачено
  dtpaid date,                 -- фактическая дата оплаты 
  constraint pk_sn_calendar_payments primary key (id),
  constraint fk_sn_calendar_payments_acc foreign key (id_account) references sn_calendar_accounts(id) on delete cascade
);

create sequence sq_sn_calendar_payments start with 250 nocache;

--insert into sn_calendar_payments (id, id_account, dt, sum, status, dtpaid) select id, id_account, dt, sum, status, dtpaid from uchet.sn_calendar_payments; 


--справочник поставщиков
create table ref_suppliers(
  id number(11),
  name varchar2(400),       -- краткое наименование не используем
  legalname varchar2(400),  -- юридическое наименование, пока используем только его
  active number(1),
  constraint ref_suppliers primary key (id)
);

create unique index idx_ref_suppliers_legalname on ref_suppliers(lower(legalname));  --!!!!!!

create sequence sq_ref_suppliers start with 10016 nocache;

--insert into ref_suppliers (id, name, legalname, active) select id, name, legalname, active from uchet.ref_suppliers; 


--справочник статьи расходов
--alter table ref_expenseitems add accounttype number(1) default 0;
--alter table ref_expenseitems add constraint fk_ref_expenseitems_group foreign key (id_group) references ref_grexpenseitems(id);
--alter table ref_expenseitems drop column receipttype;
create table ref_expenseitems(
  id number(11),
  id_group number(11),
  name varchar2(400),
  useravail varchar2(4000),
  agreed varchar2(4000),
  recvreceipt number(1) default 0,   --обязательно требовать заявку на снабжение 
  accounttype number(1) default 0,   --тип счета по этой статье (0-обычный, 1-транспорт отгрузки, 2-транспорт снабжения
  active number(1),
  constraint ref_expenseitems primary key (id),
  constraint fk_ref_expenseitems_group foreign key (id_group) references ref_grexpenseitems(id)
);

create unique index idx_ref_expenseitems_name on ref_expenseitems(lower(name));
  
create sequence sq_ref_expenseitems start with 130 nocache;

--insert into ref_expenseitems (id, name, active) select id, name, active from uchet.ref_expenseitems;

--update ref_expenseitems set id_group = 1; 
--update ref_expenseitems set recvreceipt = 1; 

--update ref_expenseitems set useravail = '47,67,91', agreed = '47';


--справочник групп статеи расходов
create table ref_grexpenseitems(
  id number(11),
  name varchar2(400),
  constraint pk_ref_grexpenseitems primary key (id)
);

create unique index idx_ref_grexpenseitems_name on ref_grexpenseitems(lower(name));
  
create sequence sq_ref_grexpenseitems start with 2 nocache;

insert into ref_grexpenseitems (id, name) values (1, 'Общее'); 


--начальная кредиторская задолженность для диаграммы расходов по годам/месяцам
--должна быть на начало периода, в котором есть счета в таблице счетов/платежей
create table sn_initialdebt(
  sum number(11)
);

--insert into sn_initialdebt (sum) values (0);

/*******************************************************************************
ТРАНСПОРТНЫЕ СЧЕТА
*******************************************************************************/

--дополнительная таблица для транспортных счетов, одна запись в этой таблице есть для каждого транспотрного счета
--drop table sn_calendar_accounts_t;
--alter table sn_calendar_accounts_t drop column idle;
--alter table sn_calendar_accounts_t add idle number(12,2);
create table sn_calendar_accounts_t(
  id number(12),                  --первичный ключ, он же родительский в таблице счетов
  cartype number(12),             --тип транспорта, из справочника
  flighttype number(1),           --тип рейса, 1-прямой 2-фиксированный 
  flightdt date,                  --дата рейса
  kilometrage number(12),         --километраж
  idle number(12,2),              --время простоя, ч
  basissum number(12,2),          --сумма по основанию счета
  othersum number(12,2),          --сумма прочих расходов
  priceidle number(12,2),         --цена часа простоя
  pricekm number(12,2),           --цена километра
  freeidletime number(12,2),      --время простоя, которое не оплачивается, ч
  constraint pk_sn_calendar_accounts_t primary key (id),
  constraint fk_sn_calendar_accounts_t_id foreign key (id) references sn_calendar_accounts(id) on delete cascade,
  constraint fk_sn_calendar_accounts_t_ct foreign key (cartype) references ref_sn_cartypes(id)
);

--таблица маршрутов для транспортных счетов, одна строка на каждую строку грида маршрутов в транспортном счете
create table sn_calendar_t_route(
  id_account number(12),          --айди счета
  pos number(12),                 --позиция в гриде
  point1 number(12),              --айди места отправления
  dt1 date,                       --дата/время отправления 
  point2 number(12),
  dt2 date,
  kilometrage number(12),                  --километраж
  constraint pk_sn_calendar_t_route primary key (id_account, pos),
  constraint fk_sn_calendar_t_route_id_a foreign key (id_account) references sn_calendar_accounts(id) on delete cascade,
  constraint fk_sn_calendar_t_route_p1 foreign key (point1) references ref_sn_locations(id),
  constraint fk_sn_calendar_t_route_p2 foreign key (point2) references ref_sn_locations(id)
);

--таблица оснований для транспортных счетов, основаниями являются любые счета и заказы
--alter table sn_calendar_t_basis add constraint fk_sn_calendar_t_basis_id_ab foreign key (id_order) references sn_calendar_accounts(id) on delete cascade;
--alter table sn_calendar_t_basis add  
create table sn_calendar_t_basis(
  id_account number(12),          --айди основного счета (для которого эти являются основанием)
  id_order number(12),          --айди заказа-основания
  id_acc number(12),          --айди счета-основания
  pos number(12),                 --позиция в гриде
  sum_saved number(12,2),              --сохраненная сумма с учетом процента
  prc number(3),                       --процент обслуживания документа/основания 
  constraint pk_sn_calendar_t_basis primary key (id_account, pos),
  constraint fk_sn_calendar_t_basis_id_a foreign key (id_account) references sn_calendar_accounts(id) on delete cascade,
  constraint fk_sn_calendar_t_basis_id_ab foreign key (id_acc) references sn_calendar_accounts(id) on delete cascade   
);

/*
create or replace view v_sn_calendar_t_basis as (
  select
    b.*,
  (case 
    when b.id_order is not null then b.id_order 
    else b.id_acc
  end) as id_basis,
  (case 
    when b.id_order is not null then 'Заказ' 
    else 'Счет'
  end) as type,
  (case 
    when b.id_order is not null then o.ordernum || ' | ' || to_char(o.dt_beg, 'dd.mm.yyyy') || ' | ' || o.customer 
    else a.supplier || ' | ' || to_char(a.accountdt, 'dd.mm.yyyy') || ' | ' || a.account
  end) as name,
  (case 
    when b.id_order is not null then nvl(o.sum,0) 
    else nvl(a.sum,0)
  end) as sumfull,
  (case 
    when b.id_order is not null then round(nvl(o.sum,0) / 100 * b.prc) 
    else round(nvl(a.sum,0) / 100 * b.prc)
  end) as sum
  from
    sn_calendar_t_basis b,
    v_sn_calendar_accounts a,
    v_sn_orders o
  where
    b.id_acc = a.id(+) and 
    b.id_order = o.id_order(+) 
);
*/

--возвращает данные по основанию транспортного счета
--если есть айди счета-основания или заказа, то данные по нему (одновременно не должны быть, но это не проверяется)
--если и ид_акк и ид_ордер is null, то выставляется статься Прочие, процент 100%, сумма их сохраненных
--(в программе сумма, уже с учетом процента использования, сохраняется в sum_saved)
create or replace view v_sn_calendar_t_basis as (
  select
    b.id_account,
    b.id_acc,
    b.id_order,
    b.pos,
    b.sum_saved,
  (case 
    when b.id_order is not null then b.prc 
    when b.id_acc is not null then b.prc 
    else 100
  end) as prc,
  (case 
    when b.id_order is not null then b.id_order 
    when b.id_acc is not null then b.id_acc 
    else 0
  end) as id_basis,
  (case 
    when b.id_order is not null then 'Заказ' 
    when b.id_acc is not null then 'Счет' 
    else 'Прочие'
  end) as type,
  (case 
    when b.id_order is not null then o.ordernum || ' | ' || to_char(o.dt_beg, 'dd.mm.yyyy') || ' | ' || o.customer 
    when b.id_acc is not null then a.supplier || ' | ' || to_char(a.accountdt, 'dd.mm.yyyy') || ' | ' || a.account
    else ''
  end) as name,
  (case 
    when b.id_order is not null then nvl(o.sum,0)
    when b.id_acc is not null then nvl(a.sum,0)
    else sum_saved
  end) as sumfull,
  (case 
    when b.id_order is not null then round(nvl(o.sum,0) / 100 * b.prc) 
    when b.id_acc is not null then round(nvl(a.sum,0) / 100 * b.prc)
    else sum_saved
  end) as sum,
  (case 
    when b.id_order is not null
      --для заказа цена изделий + д/к без ндс, для счета - полная сумма счета 
      then round(
        nvl(
          case when nvl(o.sum, 0) = nvl(o.cost_wo_nds, 0) then nvl(o.cost_i,0) + nvl(o.cost_a,0) else round((nvl(o.cost_i,0) + nvl(o.cost_a,0)) / 1.2, 2) end
          ,0), 0) / 100 * b.prc 
    when b.id_acc is not null 
      then round(nvl(a.sum,0) / 100 * b.prc)
      else sum_saved
  end) as sum_ia,
  (case 
    when b.id_order is not null 
      then round(nvl((case when nvl(o.sum, 0) = nvl(o.cost_wo_nds, 0) then o.cost_m else round(nvl(o.cost_m, 0) / 1.2, 2) end), 0) / 100 * b.prc) 
      else 0
  end) as sum_m,
  (case 
    when b.id_order is not null 
      then round(nvl((case when nvl(o.sum, 0) = nvl(o.cost_wo_nds, 0) then o.cost_d else round(nvl(o.cost_d, 0) / 1.2, 2) end), 0) / 100 * b.prc) 
      else 0
  end) as sum_d
  /*(case 
    when b.id_order is not null then round(nvl(o.cost_d,0) / 100 * b.prc) 
    else 0
  end) as sum_d*/
  from
    sn_calendar_t_basis b,
    v_sn_calendar_accounts a,
    v_sn_orders o
  where
    b.id_acc = a.id(+) and 
    b.id_order = o.id_order(+) 
);  

select * from v_sn_calendar_t_basis where id_acc is null and id_order is not null and sum_saved = 0;
--тестовый счет
select * from v_sn_calendar_t_basis where id_account = 4319;
  

--отчет по транспортным счетам
create or replace view v_sn_calendar_accounts_t_rep as select
--2024-03-04 b.sum заменили на b.sum_ia
  a.*,
  round(a.sum / ((100 + a.nds) / 100), 2) as sum_wo_nds,
  p.dtp as dt_payment,
  u.name as username,
  u.id as userid,
--  e.useravail as useravail,
--  e.agreed as useragreed,
  o.name as organization,
  s.legalname as supplier,
  e.name as expenseitem,
  ct.name as cartype,
  --at.flighttype,
  (case when flighttype = 1 then 'Прямой' else 'Фиксированный' end) as flighttype,
  at.idle,
  at.kilometrage,
  b.sum as basissum,
  r.strings,
  l1.name as location1,
--  l2.name as location2,
  (case when flighttype = 1 
    then l3.name 
    else l2.name
  end) as location2,  --для прямого рейса вторая локация из первой строки таблицы, для фиксированного вторая локация из последней
  at.pricekm as pricekm,
  at.priceidle as priceidle,
  at.othersum as sumother,
  at.priceidle*greatest(at.idle - at.freeidletime, 0) as sumidle,
  at.pricekm*at.kilometrage as sumkm,
  round(a.sum/greatest(b.sum,0.01)*100,1) as percent,
  b.sum_m,
  b.sum_d
  from 
    sn_calendar_accounts a, ref_expenseitems e, adm_users u, ref_sn_organizations o, 
    (select min(dtpaid) as dtp, id_account from sn_calendar_payments group by id_account) p, 
    ref_suppliers s, sn_calendar_accounts_t at, ref_sn_cartypes ct, 
--    (select id_account, sum(sum) as sum from v_sn_calendar_t_basis b group by id_account) b,
    (select id_account, sum(sum_ia) as sum, sum(sum_m) as sum_m, sum(sum_d) as sum_d from v_sn_calendar_t_basis b group by id_account) b,
    (select min(pos) as pos1, max(pos) as pos2, count(pos) as strings, id_account from sn_calendar_t_route group by id_account) r,
    sn_calendar_t_route r1,
    sn_calendar_t_route r2,
    ref_sn_locations l1,
    ref_sn_locations l2, 
    ref_sn_locations l3 
  where
    ((a.accounttype = 1) or (a.accounttype = 2)) and
    a.id = p.id_account(+) and 
    (e.id = a.id_expenseitem and u.id = a.id_user and o.id = a.id_org and s.id = a.id_supplier and at.id = a.id
    and b.id_account (+) = a.id
    and ct.id = at.cartype
    and a.id = r.id_account
    and a.id = r1.id_account and r1.pos = r.pos1
    and a.id = r2.id_account and r2.pos = r.pos2
    and l1.id = r1.point1
    and l2.id = r2.point2
    and l3.id = r1.point2
    )
  ;   
  
select * from v_sn_calendar_accounts_t_rep;  

select count(*), sum(sum) from v_sn_calendar_t_basis where id_acc is null and id_order is null;
select id_account, sum, id_basis from v_sn_calendar_t_basis where id_order is not null order by sum desc;


--отчет по счетам подрядчиков по монтажу
create or replace view v_sn_calendar_accounts_m_rep as select
  a.*,
  u.name as username,
  u.id as userid,
  o.name as organization,
  s.legalname as supplier,
  e.name as expenseitem,
  b.sum as basissum,
  round(a.sum/greatest(b.sum,0.01)*100,1) as percent,
  b.sum_m,
  b.sum_d
  from 
    sn_calendar_accounts a, ref_expenseitems e, adm_users u, ref_sn_organizations o, ref_suppliers s, 
    (select id_account, sum(sum_ia) as sum, sum(sum_m) as sum_m, sum(sum_d) as sum_d from v_sn_calendar_t_basis b group by id_account) b
  where
    a.accounttype = 3 and
    (e.id = a.id_expenseitem and u.id = a.id_user and o.id = a.id_org and s.id = a.id_supplier 
    and b.id_account (+) = a.id
    )
  ;   

select * from v_sn_calendar_accounts_m_rep;  


/*******************************************************************************
END ТРАНСПОРТНЫЕ СЧЕТА
*******************************************************************************/

/*******************************************************************************
ЖУРНАЛ БРАКА МАТЕРИАЛА
*******************************************************************************/

--таблица журнала брака материалов
create table sn_defectives(
  id number(11), -- ид
  dt date,                            --дата записи, автоматически
  id_user number(11) not null,        --ид юзера, создавшего запись
  basis varchar2(400) not null,       --строка-основание
  addexp number(9),                   --дополнительные расходы
  id_account number(11),              --ид счета-основания
  sum number(9),                      --сумма брака
  result number(1),                   --результат обработки, есть/нет 
  comm varchar2(400),                 --комментарий
  filename varchar2(25),              --временная метка, каталог для хранения файлов  
  constraint pk_sn_defectives primary key (id),
  constraint fk_sn_defectives_user foreign key (id_user) references adm_users(id),
  constraint fk_sn_defectives_account foreign key (id_account) references sn_calendar_accounts(id)
);  

create index idx_sn_defectives_dt on sn_defectives(dt); 
create sequence sq_sn_defectives start with 100 nocache;


--таблица журнала актов брака материалов
--drop table sn_defectives_act cascade constraints;
create table sn_defectives_act(
  id number(11),                      -- ид
  id_defectives number(11),           -- ид записи о браке в журнале
  dt date,                            --дата записи, автоматически
  num number(6),                      --номер акта
  id_user number(11) not null,        --ид юзера, создавшего запись
  type_user number(1),                --должность пользователя, создавшего акт (0-кладовщик, иначе 1 - все остальные, пишет как менеджер)
  supplier varchar2(400),             --поставщик, текстом
  waybill_num varchar2(100),          --номер накладной
  waybill_date date,                  --дата накладной
  comm varchar2(400),
  constraint pk_sn_defectives_act primary key (id),
  constraint fk_sn_defectives_act_user foreign key (id_user) references adm_users(id),
  constraint fk_sn_defectives_act_d foreign key (id_defectives) references sn_defectives(id) on delete cascade
);

create index idx_sn_defectives_act_d on sn_defectives_act(id_defectives); 
create sequence sq_sn_defectives_act start with 100 nocache;
  

--таблица записей о браке в акте (табличная часть актов)
--drop table sn_defectives_act_items cascade constraints;
create table sn_defectives_act_items(
  id_defectives_act number(11),           -- ид записи о браке в журнале актов брака
  pos number(3),                      --позиция в сетке
  name varchar2(400),                 
  dim varchar2(50),          
  qnt varchar2(50),          
  basis varchar2(400),       
  constraint pk_sn_defectives_act_items primary key (id_defectives_act, pos),
  constraint fk_sn_defectives_act_items_d foreign key (id_defectives_act) references sn_defectives_act(id) on delete cascade
);  

create index idx_sn_defectives_act_items_d on sn_defectives_act_items(id_defectives); 


create or replace view v_sn_defectives as (select
  d.*,
  a.account,
  a.accountdt,
  s.legalname as supplier,
  u.name as username,
  da.num as act_num,
  da.id as id_act
  from
    sn_defectives d,
    sn_calendar_accounts a,
    adm_users u,
    ref_suppliers s,
    sn_defectives_act da    
  where
    d.id_account = a.id (+) and
    d.id_user = u.id and
    a.id_supplier = s.id (+) and
    d.id = da.id_defectives (+)
);

select * from  v_sn_defectives;


  
/*******************************************************************************
END - ЖУРНАЛ БРАКА МАТЕРИАЛА
*******************************************************************************/

/*******************************************************************************
ПЛАТЕЖИ ПО ЗАКАЗАМ
*******************************************************************************/

-- таблица заказов для платежного календаря (для учета оплат по заказам)
-- заполняется программой Учет.xls при создании/модификации паспорта заказа
-- ПОКА НЕ ИСПОЛЬЗУЕМ, ИСПОЛЬЗУЕМ ВЫБОРКУ ИЗ СХЕМЫ UCHET
/*
create table sn_orders(
  id number(11), -- ид заказа в таблице uchet.to_orders
  ordernum varchar(20),  -- номер заказа М-45
  --year number(4),        -- год заказа
  dtbeg date,            -- дата оформления заказа 
  dtend date,            -- дата сдачи заказа  
  customer number(400),  -- покупатель
  account number(400),   -- рассчетный счет
  sum number(12,2),      -- сумма заказа 
  cashless number(1),    -- 0 - нал, 1 - безнал 
  comm varchar(400),     -- комментарий
  filename varchar2(400),-- имя файла ПЗ
  constraint pk_sn_orders primary key (id)
);
*/

--дополнительная информация для журнала заказов (список заказов берется из схемы uchet)
--drop table sn_orders_add;
create table sn_orders_add(
  id_order number(11), -- ид заказа в таблице uchet.to_orders
  comm varchar(400),
  constraint pk_sn_orders_add primary key (id_order)
--  constraint fk_sn_orders_add_order foreign key (id_order) references uchet.to_orders(id_order) on delete cascade
); 

create index idx_sn_orders_add_id_order on sn_orders_add(id_order);
--alter table sn_orders_add add constraint pk_sn_orders_add primary key (id_order);
--alter table sn_orders_add drop constraint fk_sn_orders_add_order;
--insert into sn_orders_add (id_order, comm) values (2794, 'проверочный заказ'); 

  
--платежи по заказам
create table sn_order_payments(
  id number(11), -- 
  id_order number(11), -- ид заказа в таблице uchet.to_orders
  dt date not null,
  sum number(12,2),
  comm varchar(400),
  constraint pk_sn_order_payments primary key (id)
--  constraint fk_sn_order_payments_order foreign key (id_order) references uchet.to_orders(id_order) on delete cascade
);

--alter table sn_order_payments drop constraint fk_sn_order_payments_order;
--alter table sn_order_payments add constraint fk_sn_order_payments_order foreign key (id_order) references uchet.to_orders(id_order) on delete cascade;

create index idx_sn_order_payments_id_order on sn_order_payments(id_order); 
create sequence sq_sn_order_payments start with 100 nocache;


--вьюха получает список заказов из схемы UCHET в соедиеннии с таблицей sn_orders_add
create or replace view v_sn_orders as (
  select
    o.id, 
    o.id as id_order,
    o.id_organization as id_organization,
    o.organization,
    o.organization as org,
    o.num,
    o.ornum,
    o.ornum as ordernum,
    o.year,
    o.path,
    o.dt_end as dt_end,
    o.dt_pnr as dt_pnr,
    o.cost as sum,
    o.cost_i, o.cost_a, o.cost_d, o.cost_m, o.cost_wo_nds,
    lower(o.cashtypename) as orcashtype,
    decode(o.cashtype, 2, 'нал', 'безнал') as cashtype,
    o.customer,
    o.account, 
--    h.organization,
    o.dt_beg,
    o.project,
    o.comm as sn_comment,
    nvl(p.paidsum, 0) as paidsum,
    nvl(o.cost, 0) - nvl(p.paidsum, 0) as restsum,
  (case 
    when p.paidsum is null then 'не оплачен'
    when p.paidsum = o.cost then 'полностью'
    when p.paidsum = 0 then 'не оплачен'
    when p.paidsum > o.cost then 'переплата'
    else 'частично'
  end) as paimentstatus,
  (case 
    when  o.dt_end is null then 0 --o.dt_end
    else 1
  end) as endstatus,
  p.maxdtpaid
  from 
    v_orders o,
--    uchet.to_passport_head h,
--    uchet.to_customers c,
--    uchet.to_projects pr,
    sn_orders_add a,
    (select sum(sum) as paidsum, id_order, max(dt) as maxdtpaid from sn_order_payments pp group by id_order) p 
  where
--    o.id_order = h.id_order and 
    o.id > 0 and
    o.id = a.id_order(+) and 
    o.id = p.id_order(+) 
--    and 
--    h.id_beg <= o.version and h.id_end >= o.version and
--    h.id_project = pr.id_project and
--    h.id_customer = c.id_customer
);

select  * from v_sn_orders;
select  * from v_sn_orders where sum is not null;

--o 360 id_order=2794 ;id_end_max = 99999999
select id_beg, id_end, cost from uchet.to_passport_head where id_order = 2794;
--обновим сумму заказы в последней версии заголовков
--update uchet.to_passport_head h set h.cost = 500 where h.id_order = 2794 and h.id_end = (select max(id_end) from uchet.to_passport_head where id_order = 2794);
update uchet.to_passport_head h set h.cost = 500.34 where h.id_order = 2794 and h.id_end = 99999999; 


/*******************************************************************************
END ПЛАТЕЖИ ПО ЗАКАЗАМ
*******************************************************************************/

/*******************************************************************************
ОТЧЕТ ПО ЗАКАЗАМ (КОЛИЧЕСТВЕННЫЙ СОСТАВ)
*******************************************************************************/

--таблица проектов для отчета по заказам (выпадающий список на форме, чтобы каждый раз не набирать)
create table sn_orders_qntreport_proekts(
  name varchar2(100), 
  constraint pk_sn_orders_qntreport_proekts primary key (name)
);

create unique index idx_sn_orders_qntreport_p on sn_orders_qntreport_proekts(lower(name)); 

--скл запрос
--выбирает изделия из заказов за период с данным проектом,
--группирует по имени изделия и суммирует количества и количества заказов, и среднее на заказ
select
  max(pos) as slash,
  max(name),
  sum(qnt),
  sum(orqnt),
  ceil(sum(qnt) / sum(orqnt)) as cntbyor
from (  
select
  i.pos,
  i.name,
  i.qnt,
  o.dt_beg,
  o.project,
  o.org,
  o.id_order,
  1 as orqnt
from
  uchet.v_to_orders_list o,  
  uchet.v_to_passport_items i
where
  o.id_order = i.id_order
  and
  o.dt_beg >= '01.12.2022'  
  and
  o.dt_beg <= '31.12.2022'
  and
  o.org <> 'СГ'
  and
  o.id_beg <= o.version and o.id_end >= o.version
  and
  i.id_beg <= i.version and i.id_beg_i <= i.version and i.id_end >= i.version and i.id_end_i >= i.version
  and
--  upper(o.project) like 'МАГАЗИН КБ%'
  upper(o.project) like 'ТАБАЧНЫЙ ШКАФ%'
order by 
  name, id_order
)
group by name
order by slash  
;  

/*******************************************************************************
END - ОТЧЕТ ПО ЗАКАЗАМ (КОЛИЧЕСТВЕННЫЙ СОСТАВ)
*******************************************************************************/

/*******************************************************************************
КАССА
*******************************************************************************/
/*
-1 - касса 1
-2 - касса 2
-9 - депозит
0  - расходы по счетам
1  - прочие расходы
10 - прихооды по заказам
11 - прочие приходы
*/

create table sn_cash_revision(
  id number(2), 
  sum number(12,2),
  constraint pk_sn_cash_revision primary key (id)
);
  
create table sn_cash_revision_dt(
  dt date
--  sum1 number(12,2),
--  sum2 number(12,2),
--  sum9 number(12,2)
);

create table sn_cash_revision_sum(
  id number(2),
  sum number(12,2),
  constraint pk_sn_cash_revision_sum primary key (id)
);

--drop table sn_cash_payments;
create table sn_cash_payments(
  id number(11), 
  source number(2), 
  receiver number(2), 
  sum number(12,2),
  comm varchar(400),
  dt date,
  constraint pk_sn_cash_payments primary key (id)
);

create sequence sq_sn_cash_payments start with 100 nocache;











/*
--!!!!!!!!!!!!!!!старый
create or replace view v_sn_cash_list as
  select 
    *
  from (
  select
    -1 as source,
    0 as receiver,
    a.account as comm,
    ei.name as grp,
    p.sum as sum,
    p.dtpaid as dt,
    p.id as id_,
    '-1_0_' || p.id as id 
  from
    sn_calendar_payments p,
    sn_calendar_accounts a,
    ref_expenseitems ei
  where
    p.status = 1 and
    p.id_account = a.id and
    a.type = 2 and
    a.id_expenseitem = ei.id
  union
  select
    10 as source,
    -1 as receiver,
    vo.ordernum as comm,
    'заказ' as grp,
    p.sum as sum,
    p.dt as dt,
    vo.id_order as id_,
    '10_-1_' || vo.id_order as id 
  from
    sn_order_payments p,
    v_sn_orders vo
  where
    p.id_order = vo.id_order and
    vo.cashtype = 'нал'
  union
  select
    c.source as source,
    c.receiver as receiver,
    c.comm as comm,
    (case
      when c.receiver = 1 then 'прочие расходы'  
      when c.receiver = -9 then 'на депозит'
      when c.source = 11 then 'прочие приходы'  
      when c.source = -9 then 'с депозита'
      else 'касса'
    end) as grp,  
    c.sum as sum,
    c.dt as dt,
    c.id as id_,
    c.source || '_' || c.receiver || '_' || c.id as id 
  from
    sn_cash_payments c
  )
  where dt >= (select dt from sn_cash_revision_dt);
  ; 
*/

create or replace view v_sn_cash_list as
  select 
    *
  from (
  select
    -1 as source,
    0 as receiver,
    a.account as comm,
    ei.name as grp,
    p.sum as sum,
    p.dtpaid as dt,
    p.id as id_,
    '-1_0_' || p.id as id 
  from
    sn_calendar_payments p,
    sn_calendar_accounts a,
    ref_expenseitems ei
  where
    p.status = 1 and
    p.id_account = a.id and
    a.type = 2 and
    a.id_expenseitem = ei.id
  union
  select
    10 as source,
    -1 as receiver,
    vo.ornum as comm,
    'заказ' as grp,
    p.sum as sum,
    p.dt as dt,
    vo.id as id_,
    '10_-1_' || vo.id as id 
  from
    or_payments p,
    v_or_payments vo
  where
    p.id_order = vo.id and
    vo.cashtype = 2 --нал
  union
  select
    c.source as source,
    c.receiver as receiver,
    c.comm as comm,
    (case
      when c.receiver = 1 then 'прочие расходы'  
      when c.receiver = -9 then 'на депозит'
      when c.source = 11 then 'прочие приходы'  
      when c.source = -9 then 'с депозита'
      else 'касса'
    end) as grp,  
    c.sum as sum,
    c.dt as dt,
    c.id as id_,
    c.source || '_' || c.receiver || '_' || c.id as id 
  from
    sn_cash_payments c
  )
  where dt >= (select dt from sn_cash_revision_dt);
  ; 
     
    
    
select * from v_test1;    
select * from v_test1 where receiver = -2 and source > -100;    
select * from v_test1 where source = -2;    
select * from v_test1 where source = -2;    

    

create or replace view v_sn_cash_sum as
select
  (select sum from sn_cash_revision_sum where id = -1) + arrival1 - spending1 as sum1,
  (select sum from sn_cash_revision_sum where id = -2) + arrival2 - spending2 as sum2,
  (select sum from sn_cash_revision_sum where id = -9) + arrival_d - spending_d as sum9,
  arrival1,
  arrival2,
  arrival_d,
  spending1,
  spending2,
  spending_d,
  arrivalday,
  spendingday
from (
(select 
  sum(arrival1) as arrival1,
  sum(spending1) as spending1,
  sum(arrival2) as arrival2,
  sum(spending2) as spending2,
  sum(arrival_d) as arrival_d,
  sum(spending_d) as spending_d,
  sum(arrivalday) as arrivalday,
  sum(spendingday) as spendingday
from (  
select 
  (case when receiver = -1 then sum else 0 end) as arrival1,  --приход по кассе 1 с учетом перемещений
  (case when source = -1 then sum else 0 end) as spending1,   --расход по кассе 1 с учетом перемещений
  (case when receiver = -2 then sum else 0 end) as arrival2,  --приход по кассе 2 с учетом перемещений
  (case when source = -2 then sum else 0 end) as spending2,   --расход по кассе 2 с учетом перемещений
  (case when receiver = -9 then sum else 0 end) as arrival_d,  --приход по депозиту с учетом перемещений
  (case when source = -9 then sum else 0 end) as spending_d,   --расход по депозиту с учетом перемещений
  (case when (receiver = -1 or receiver = -2) and source >=0 and trunc(dt) = trunc(sysdate) then sum else 0 end) as arrivalday,
  (case when  (source = -1 or source = -2) and receiver >=0 and trunc(dt) = trunc(sysdate)  then sum else 0 end) as spendingday
from
(
  (select source, receiver, sum, dt, rownum from v_sn_cash_list)
  union
  (select 999 as receiver, 999 as source, 0 as sum, sysdate as dt,999999999 from dual)
) s1   
)
)
)
; 

select * from v_sn_cash_sum;

select 
  (case when receiver = -1 then sum else 0 end) as arrival1,  --приход по кассе 1 с учетом перемещений
  (case when source = -1 then sum else 0 end) as spending1,   --расход по кассе 1 с учетом перемещений
  (case when receiver = -2 then sum else 0 end) as arrival2,  --приход по кассе 2 с учетом перемещений
  (case when source = -2 then sum else 0 end) as spending2,   --расход по кассе 2 с учетом перемещений
  (case when receiver = -9 then sum else 0 end) as arrival_d,  --приход по кассе 2 с учетом перемещений
  (case when source = -9 then sum else 0 end) as spending_d,   --расход по кассе 2 с учетом перемещений
  (case when (receiver = -1 or receiver = -2) and source >=0 and trunc(dt) = trunc(sysdate) then sum else 0 end) as arrivalday,
  (case when  (source = -1 or source = -2) and receiver >=0 and trunc(dt) = trunc(sysdate)  then sum else 0 end) as spendingday,
  dt
from 
(
  (select source, receiver, sum, dt, rownum from v_sn_cash_list)
  union
  (select 999 as receiver, 999 as source, 0 as sum, sysdate as dt, 999999 from dual)
);     

select source, receiver, sum, dt from v_sn_cash_list where receiver = -1;


create or replace view v_sn_calendar_cash as select
  a.*,
  p.id as pid,            --ид платежа!!!
  p.dt as pdt,            --дата платежа
  p.dtpaid as pdtpaid,    --дата проведения платежа
  p.sum as psum,          --сумма платежа
  p.status as pstatus     --статус: 1=оплачено  
  from 
    sn_calendar_payments p, v_sn_calendar_accounts a
  where
    p.id_account = a.id;
    
select * from v_sn_calendar_payments;    



/*******************************************************************************
END КАССА
*******************************************************************************/


create or replace view v_ref_expenseitems as select
  e.*,
  getusernames(e.useravail) as usernames,
  getusernames(e.agreed) as agreednames,
  g.name as groupname
from
  ref_expenseitems e, ref_grexpenseitems g
where
  e.id_group = g.id
;  

select * from v_ref_expenseitems;




--счета
create or replace view v_sn_calendar_accounts as select
  a.*,
  u.name as username,
  u.id as userid,
  u1.name as whoagreed1,
  e.useravail as useravail,
  e.agreed as useragreed,
  o.name as organization,
  s.legalname as supplier,
  e.name as expenseitem,
  p.accsum,  --полная сумма счета, берется из суммы таблицы платежей а не поля в таблице счетов
  p.paidsum, --проплаченная сумма
  a.dt - a.accountdt as regdays, --время регистрации счета в днях (разница между датой регистрации и датой счета) 
  (case
    when a.receiptdt is not null and a.agreed2 is not null
      then a.receiptdt - a.agreed2dt
      else null
   end)  as receiptdays,  --время в днях оприходования позиций по счету с момента согласования директором 
  (p.accsum - p.paidsum) as debt,
  (case 
    when a.type = 1 then 'безнал'
    else 'нал'
  end) as acctype, 
  (case 
    when p.accsum = p.paidsum then 'полностью'
    when p.paidsum = 0 then 'не оплачен'
    else 'частично'
  end) as paimentstatus,
  p.maxdtpaid
  from 
    sn_calendar_accounts a, ref_expenseitems e, adm_users u, adm_users u1, ref_sn_organizations o, ref_suppliers s,
    (select sum(sum) as accsum, sum(case when status = 1 then sum else 0 end) as paidsum, max(dtpaid) as maxdtpaid, id_account from sn_calendar_payments pp group by id_account) p 
  where
    e.id = a.id_expenseitem and 
    u.id = a.id_user and 
    u1.id (+) = a.id_whoagreed1 and 
    o.id = a.id_org and 
    s.id = a.id_supplier and 
    p.id_account (+) = a.id
  ;   

select * from v_sn_calendar_accounts;
 
create or replace view v_sn_calendar_payments as select
  a.*,
  p.id as pid,            --ид платежа!!!
  p.dt as pdt,            --дата платежа
  p.dtpaid as pdtpaid,    --дата проведения платежа
  p.sum as psum,          --сумма платежа
  p.status as pstatus     --статус: 1=оплачено  
  from 
    sn_calendar_payments p, v_sn_calendar_accounts a
  where
    p.id_account = a.id;
    
select * from v_sn_calendar_payments;    
    
--статистика по дням, суммы планируемого платежа и оплаченная сумма
create or replace view v_sn_calendar_datereport as select
  ppm.pdt,
  ppm.sum as sum,
  ppaid.sum as paidsum
from 
  (select pdt, sum(psum) as sum  from v_sn_calendar_payments group by pdt) ppm,              --группировка по сумме планируемого платежа
  (select pdtpaid, sum(psum) as sum from v_sn_calendar_payments group by pdtpaid) ppaid      --группировка по сумме проплаты 
where
  pdt = pdtpaid (+);
  
--сумма неоплаченных платежей за все время    
select sum(case when status = 0 then sum else 0 end) as debtsum from sn_calendar_payments;


--настройки модуля
alter table sn_calendar_cfg add transport_maxidle number(4);
create table sn_calendar_cfg (
  id number(12),
  --autoclose date,
  sum_autoagreed number,
  sum_need_req number,
  --path_to_files varchar2(4000),
  --order_archive_path varchar2(4000),
  --order_current_path varchar2(4000),
  transport_maxidle number(4)         --неоплачиваемое время простоя в транспортных счетах
);  

--insert into sn_calendar_cfg (id) values (1);
--update sn_calendar_cfg set sum_autoagreed = 15000, sum_need_req = 10000, path_to_files = '\\10.1.1.14\Uchet\Учет\Files';  
--alter table sn_calendar_cfg add (order_archive_path varchar2(4000), order_current_path varchar2(4000)); 
--update sn_calendar_cfg set order_current_path = '\\10.1.1.14\В работу\YYYY\СГ', order_archive_path = '\\10.1.1.14\Архив\YYYY\ОПТ\СГ'; 
--alter table sn_calendar_cfg add (autoclose date);


--выборка - отчет по статьям расходов по месяцам
--rollup не используем, итоги средствами дельфи
select 
  ie_name, max(s1), max(s2), max(s3), max(s4), max(s5), max(s6), max(s7), max(s8), max(s9), max(s10), max(s11), max(s12), max(sumall) 
from 
(
select
a.ie_name as ie_name,
(case when a.month = 1 then a.sum end) as s1,
(case when a.month = 2 then a.sum end) as s2,
(case when a.month = 3 then a.sum end) as s3,
(case when a.month = 4 then a.sum end) as s4,
(case when a.month = 5 then a.sum end) as s5,
(case when a.month = 6 then a.sum end) as s6,
(case when a.month = 7 then a.sum end) as s7,
(case when a.month = 8 then a.sum end) as s8,
(case when a.month = 9 then a.sum end) as s9,
(case when a.month = 10 then a.sum end) as s10,
(case when a.month = 11 then a.sum end) as s11,
(case when a.month = 12 then a.sum end) as s12,
a.sum as sumall
from  
(select extract(month from a.dt) month, a.id_expenseitem ie, sum(a.sum) sum, max(i.name) as ie_name 
  from 
    sn_calendar_accounts a, ref_expenseitems i
  where 
    i.id = a.id_expenseitem and extract(year from a.dt) = 2022 
  group by rollup (a.id_expenseitem, extract(month from a.dt))) a 
)
group by rollup (ie_name) 
;

select distinct extract(year from dt) from sn_calendar_accounts; 














--------------------------------------------------------------------------------
/*
drop view v_sn_calendar_datereport1;
insert into ref_suppliers (id, name, legalname, active) select id_supplier, name, name, 1 from suppliers;


insert into ref_expenseitems (id, name, active) values (1, 'Статья расходов 1', 1);
insert into ref_expenseitems (id, name, active) values (2, 'Статья расходов 2', 1);


insert into sn_calendar_accounts (id, dt, type, account, id_expenseitem, id_supplier, id_org, id_user, sum, filename, comm, agreed1, agreed2) values (1,'17.03.2022',1,'1234567890',1,1,1,33,100,'file','comm',1,1);
 
insert into sn_calendar_payments (id, id_account, dt, sum, status) values (1, 1, '17.03.2022', 50, 1);
insert into sn_calendar_payments (id, id_account, dt, sum, status) values (2, 1, '17.03.2022', 20, 1);
insert into sn_calendar_payments (id, id_account, dt, sum, status) values (3, 1, '18.03.2022', 30, 1);

select * from v_sn_calendar_accounts;


select count(*) from v_sn_calendar_payments;
select count(*) from sn_calendar_payments;


select paidsum from v_sn_calendar_datereport1;
select sum(paidsum) from v_sn_calendar_payments;

select * from (select count(*) as c, lower(legalname) from ref_suppliers group by lower(legalname)) where c > 1;

*/











--выборка - отчет по статьям расходов по месяцам
select 
  ie_name, max(s1), max(s2), max(s3), max(s4), max(s5), max(s6), max(s7), max(s8), max(s9), max(s10), max(s11), max(s12), max(sumall) 
from 
(
select
a.ie_name as ie_name,
(case when a.month = 1 then a.sum end) as s1,
(case when a.month = 2 then a.sum end) as s2,
(case when a.month = 3 then a.sum end) as s3,
(case when a.month = 4 then a.sum end) as s4,
(case when a.month = 5 then a.sum end) as s5,
(case when a.month = 6 then a.sum end) as s6,
(case when a.month = 7 then a.sum end) as s7,
(case when a.month = 8 then a.sum end) as s8,
(case when a.month = 9 then a.sum end) as s9,
(case when a.month = 10 then a.sum end) as s10,
(case when a.month = 11 then a.sum end) as s11,
(case when a.month = 12 then a.sum end) as s12,
a.sum as sumall
from  
(select extract(month from a.dt) month, a.id_expenseitem ie, sum(a.sum) sum, max(i.name) as ie_name 
  from 
    sn_calendar_accounts a, ref_expenseitems i
  where 
    i.id = a.id_expenseitem and extract(year from a.dt) = 2022 
  group by (a.id_expenseitem, extract(month from a.dt))) a 
)
group by (ie_name) 
;


select 
  ie_name, max(s1), max(s2), max(s3), max(s4), max(s5), max(s6), max(s7), max(s8), max(s9), max(s10), max(s11), max(s12), max(sumall) 
from 
(
select
a.ie_name as ie_name,
(case when a.month = 1 then a.sum end) as s1,
(case when a.month = 2 then a.sum end) as s2,
(case when a.month = 3 then a.sum end) as s3,
(case when a.month = 4 then a.sum end) as s4,
(case when a.month = 5 then a.sum end) as s5,
(case when a.month = 6 then a.sum end) as s6,
(case when a.month = 7 then a.sum end) as s7,
(case when a.month = 8 then a.sum end) as s8,
(case when a.month = 9 then a.sum end) as s9,
(case when a.month = 10 then a.sum end) as s10,
(case when a.month = 11 then a.sum end) as s11,
(case when a.month = 12 then a.sum end) as s12,
a.sum as sumall
from  
(select extract(month from a.dt) month, sum(a.sum) sum, max(g.name) as ie_name 
  from 
    sn_calendar_accounts a, ref_expenseitems i, ref_grexpenseitems g
  where 
    i.id = a.id_expenseitem and g.id = i.id_group and extract(year from a.dt) = 2022 
  group by g.id, extract(month from a.dt)) a 
)
group by ie_name 
;





  select
    ie_name as name, max(s1) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7, 
   max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall 
  from 
  (
  select
  a.ie_name as ie_name,
  (case when a.month = 1 then a.sum end) as s1,
  (case when a.month = 2 then a.sum end) as s2,
  (case when a.month = 3 then a.sum end) as s3,
  (case when a.month = 4 then a.sum end) as s4,
  (case when a.month = 5 then a.sum end) as s5,
  (case when a.month = 6 then a.sum end) as s6,
  (case when a.month = 7 then a.sum end) as s7,
  (case when a.month = 8 then a.sum end) as s8,
  (case when a.month = 9 then a.sum end) as s9,
  (case when a.month = 10 then a.sum end) as s10,
  (case when a.month = 11 then a.sum end) as s11,
  (case when a.month = 12 then a.sum end) as s12,
  a.sum as sumall 
  from 
  (select extract(month from a.dt) month, sum(a.sum) sum, max(g.name) as ie_name
    from
      sn_calendar_accounts a, ref_expenseitems i, ref_grexpenseitems g
    where
      i.id = a.id_expenseitem and extract(year from a.dt) = 2022 and g.id = i.id_group
    group by i.id_group, extract(month from a.dt)) a
  )
  group by ie_name
  ;
  
  select  ie_name as name, max(s6) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7,  max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall from (select a.ie_name as ie_name,(case when a.month = 1 then a.sum end) as s1,(case when a.month = 2 then a.sum end) as s2,(case when a.month = 3 then a.sum end) as s3,(case when a.month = 4 then a.sum end) as s4,(case when a.month = 5 then a.sum end) as s5,(case when a.month = 6 then a.sum end) as s6,(case when a.month = 7 then a.sum end) as s7,(case when a.month = 8 then a.sum end) as s8,(case when a.month = 9 then a.sum end) as s9,(case when a.month = 10 then a.sum end) as s10,(case when a.month = 11 then a.sum end) as s11,(case when a.month = 12 then a.sum end) as s12,a.sum as sumall from (select extract(month from a.dt) month, sum(a.sum) sum, max(g.name) as ie_name  from    sn_calendar_accounts a, ref_expenseitems i, ref_grexpenseitems g  where    i.id = a.id_expenseitem and extract(year from a.dt) = 2022 and g.id = i.id_group  group by i.id_group, extract(month from a.dt)) a)group by ie_name;



select extract(month from a.dt) month, a.id_expenseitem ie, sum(a.sum) sum, max(i.name) as ie_name 
  from 
    sn_calendar_accounts a, ref_expenseitems i
  where 
    i.id = a.id_expenseitem
  group by rollup (a.id_expenseitem, extract(month from a.dt))
  ;







select extract(month from dt) month, id_expenseitem ie, sum(sum) sum from sn_calendar_accounts group by extract(month from dt), id_expenseitem; 





select  ie_name as name, max(s1) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7,  max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall 
from (select 1 as ie_name,(case when a.month = 1 then a.sum end) as s1,(case when a.month = 2 then a.sum end) as s2,(case when a.month = 3 then a.sum end) as s3,(case when a.month = 4 then a.sum end) as s4,(case when a.month = 5 then a.sum end) as s5,
(case when a.month = 6 then a.sum end) as s6,(case when a.month = 7 then a.sum end) as s7,(case when a.month = 8 then a.sum end) as s8,(case when a.month = 9 then a.sum end) as s9,(case when a.month = 10 then a.sum end) as s10,
(case when a.month = 11 then a.sum end) as s11,(case when a.month = 12 then a.sum end) as s12,
a.sum as sumall from (select extract(month from a.dt) month, a.id_expenseitem ie, sum(a.sum) sum, max(i.name) as ie_name  
from    sn_calendar_accounts a, ref_expenseitems i, ref_grexpenseitems g  
where    i.id = a.id_expenseitem and extract(year from a.dt) = 2022 and g.id = i.id_group 
 group by i.id_group, extract(month from a.dt)) a)group by ie_name;
  
 
 
  SELECT ie_name          AS name,
         MAX (s6)         AS s1,
         MAX (s2)         AS s2,
         MAX (s3)         AS s3,
         MAX (s4)         AS s4,
         MAX (s5)         AS s5,
         MAX (s6)         AS s6,
         MAX (s7)         AS s7,
         MAX (s8)         AS s8,
         MAX (s9)         AS s9,
         MAX (s10)        AS s10,
         MAX (s11)        AS s11,
         MAX (s12)        AS s12,
         SUM (sumall)     AS sall
    FROM (SELECT a.ie_name                                   AS ie_name,
                 (CASE WHEN a.month = 1 THEN a.SUM END)      AS s1,
                 (CASE WHEN a.month = 2 THEN a.SUM END)      AS s2,
                 (CASE WHEN a.month = 3 THEN a.SUM END)      AS s3,
                 (CASE WHEN a.month = 4 THEN a.SUM END)      AS s4,
                 (CASE WHEN a.month = 5 THEN a.SUM END)      AS s5,
                 (CASE WHEN a.month = 6 THEN a.SUM END)      AS s6,
                 (CASE WHEN a.month = 7 THEN a.SUM END)      AS s7,
                 (CASE WHEN a.month = 8 THEN a.SUM END)      AS s8,
                 (CASE WHEN a.month = 9 THEN a.SUM END)      AS s9,
                 (CASE WHEN a.month = 10 THEN a.SUM END)     AS s10,
                 (CASE WHEN a.month = 11 THEN a.SUM END)     AS s11,
                 (CASE WHEN a.month = 12 THEN a.SUM END)     AS s12,
                 a.SUM                                       AS sumall
            FROM (  SELECT EXTRACT (MONTH FROM a.dt)     month,
                           SUM (a.SUM)                   SUM,
                           MAX (g.name)                  AS ie_name
                      FROM sn_calendar_accounts a,
                           ref_expenseitems  i,
                           ref_grexpenseitems g
                     WHERE     i.id = a.id_expenseitem
                           AND EXTRACT (YEAR FROM a.dt) = 2022
                           AND g.id = i.id_group
                  GROUP BY i.id_group, EXTRACT (MONTH FROM a.dt)) a)
GROUP BY ie_name
; 
 
select  ie_name as name, max(s1) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7,  max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall from (select a.ie_name as ie_name,(case when a.month = 6 then a.sum end) as s1,(case when a.month = 2 then a.sum end) as s2,(case when a.month = 3 then a.sum end) as s3,(case when a.month = 4 then a.sum end) as s4,(case when a.month = 5 then a.sum end) as s5,(case when a.month = 6 then a.sum end) as s6,(case when a.month = 7 then a.sum end) as s7,(case when a.month = 8 then a.sum end) as s8,(case when a.month = 9 then a.sum end) as s9,(case when a.month = 10 then a.sum end) as s10,(case when a.month = 11 then a.sum end) as s11,(case when a.month = 12 then a.sum end) as s12,a.sum as sumall from (select extract(month from a.dt) month, sum(a.sum) sum, max(g.name) as ie_name  from    sn_calendar_accounts a, ref_expenseitems i, ref_grexpenseitems g  where    i.id = a.id_expenseitem and extract(year from a.dt) = 2022 and g.id = i.id_group  group by i.id_group, extract(month from a.dt)) a)group by ie_name; 


select  ie_name as name, max(s1) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7,  max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall from (select a.ie_name as ie_name,(case when a.month = 6 then a.sum end) as s1,(case when a.month = 2 then a.sum end) as s2,(case when a.month = 3 then a.sum end) as s3,(case when a.month = 4 then a.sum end) as s4,(case when a.month = 5 then a.sum end) as s5,(case when a.month = 6 then a.sum end) as s6,(case when a.month = 7 then a.sum end) as s7,(case when a.month = 8 then a.sum end) as s8,(case when a.month = 9 then a.sum end) as s9,(case when a.month = 10 then a.sum end) as s10,(case when a.month = 11 then a.sum end) as s11,(case when a.month = 12 then a.sum end) as s12,a.sum as sumall from (select extract(month from a.dt) month, sum(a.sum) sum, max(g.name) as ie_name  from    sn_calendar_accounts a, ref_expenseitems i, ref_grexpenseitems g  where    i.id = a.id_expenseitem and extract(year from a.dt) = 2022 and g.id = i.id_group  group by i.id_group, extract(month from a.dt)) a)group by ie_name;
select  ie_name as name, max(s1) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7,  max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall from (select a.ie_name as ie_name,(case when a.month = 6 then a.sum end) as s1,(case when a.month = 2 then a.sum end) as s2,(case when a.month = 3 then a.sum end) as s3,(case when a.month = 4 then a.sum end) as s4,(case when a.month = 5 then a.sum end) as s5,(case when a.month = 6 then a.sum end) as s6,(case when a.month = 7 then a.sum end) as s7,(case when a.month = 8 then a.sum end) as s8,(case when a.month = 9 then a.sum end) as s9,(case when a.month = 10 then a.sum end) as s10,(case when a.month = 11 then a.sum end) as s11,(case when a.month = 12 then a.sum end) as s12,a.sum as sumall from (select extract(month from a.dt) month, sum(a.sum) sum, max(g.name) as ie_name  from    sn_calendar_accounts a, ref_expenseitems i, ref_grexpenseitems g  where    i.id = a.id_expenseitem and extract(year from a.dt) = 2022 and g.id = i.id_group  group by i.id_group, extract(month from a.dt)) a)group by ie_name;

select sql_fulltext, executions, last_active_time from v$sql where sql_text like '%month = 6%' order by last_active_time desc;  
select sql_fulltext, length(sql_fulltext), sql_text, executions, last_active_time, sql_id, plan_hash_value from v$sql where sql_text like '%month = 6%' order by last_active_time desc;  



select sum(accsum), sum(sum) from v_sn_calendar_accounts where dt >= '01.06.2022' and dt <= '30.06-2022';


select a.ie_name as name,sum(case when a.month = 6 then a.sum end) as s1,sum(case when a.month = 2 then a.sum end) as s2,sum(case when a.month = 3 then a.sum end) as s3,sum(case when a.month = 4 then a.sum end) as s4,sum(case when a.month = 5 then a.sum end) as s5,sum(case when a.month = 6 then a.sum end) as s6,sum(case when a.month = 7 then a.sum end) as s7,sum(case when a.month = 8 then a.sum end) as s8,sum(case when a.month = 9 then a.sum end) as s9,sum(case when a.month = 10 then a.sum end) as s10,sum(case when a.month = 11 then a.sum end) as s11,sum(case when a.month = 12 then a.sum end) as s12,sum(a.sum) as sall from (select to_char(a.dt, 'mm') month, sum(a.sum) sum, max(g.name) as ie_name  from    sn_calendar_accounts a, ref_expenseitems i, ref_grexpenseitems g  where    i.id = a.id_expenseitem and to_char(a.dt,'yyyy') = 2022 and g.id = i.id_group  group by g.name, to_char(a.dt, 'mm')) a;


create table test1 as select * from sn_calendar_accounts;

select name from ref_suppliers order by name;

select id_order, path, ordernum, year, dt_beg, dt_end, customer, account, sum, cashtype, paidsum, restsum, paimentstatus, sn_comment from v_sn_orders where sum is not null or sum > 0;





















--extract(month from p.dtpaid) y,


--------------------------------------------------------------------------------
-- ЗАПРОС для отчета платежи (расходы) по месяцам
--------------------------------------------------------------------------------

--запрос в тексте программы, не стал делать вью, вводить еще одну группировку по году
--в тексте программы используется преобразование to_char(c.dt, ''mm''), так как там связанные переменные имеют тип по умолчанию - стринг

--запрос по группам статей расходов, по статьям аналогично без ef_grexpenseitems g
 select
    ie_name as name, max(s1) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7, 
   max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall 
  from 
  (
  select
  a.ie_name as ie_name,
  (case when a.month = 1 then a.sum end) as s1,
  (case when a.month = 2 then a.sum end) as s2,
  (case when a.month = 3 then a.sum end) as s3,
  (case when a.month = 4 then a.sum end) as s4,
  (case when a.month = 5 then a.sum end) as s5,
  (case when a.month = 6 then a.sum end) as s6,
  (case when a.month = 7 then a.sum end) as s7,
  (case when a.month = 8 then a.sum end) as s8,
  (case when a.month = 9 then a.sum end) as s9,
  (case when a.month = 10 then a.sum end) as s10,
  (case when a.month = 11 then a.sum end) as s11,
  (case when a.month = 12 then a.sum end) as s12,
  a.sum as sumall 
 from 
 (
   (select extract(month from p.dtpaid) month, sum(p.sum) sum, max(g.name) as ie_name
    from
      sn_calendar_payments p, sn_calendar_accounts ac, ref_expenseitems i, ref_grexpenseitems g
    where
      p.id_account = ac.id and
      i.id = ac.id_expenseitem and 
      g.id = i.id_group and 
      extract(year from p.dtpaid) = 2022
    group by g.name, extract(month from p.dtpaid))    
    union
    (select extract(month from c.dt) month, sum(c.sum) sum, 'Прочие расходы' as ie_name
    from
      sn_cash_payments c
    where
      c.receiver = 1 and
      extract(year from c.dt) = 2022
    group by extract(month from c.dt)
    )
    )
    a
    )  
  group by ie_name
  ;
  
  select
    ie_name as name, max(s1) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7, 
   max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall 
  from 
  (
  select
  a.ie_name as ie_name,
  (case when a.month = 1 then a.sum end) as s1,
  (case when a.month = 2 then a.sum end) as s2,
  (case when a.month = 3 then a.sum end) as s3,
  (case when a.month = 4 then a.sum end) as s4,
  (case when a.month = 5 then a.sum end) as s5,
  (case when a.month = 6 then a.sum end) as s6,
  (case when a.month = 7 then a.sum end) as s7,
  (case when a.month = 8 then a.sum end) as s8,
  (case when a.month = 9 then a.sum end) as s9,
  (case when a.month = 10 then a.sum end) as s10,
  (case when a.month = 11 then a.sum end) as s11,
  (case when a.month = 12 then a.sum end) as s12,
  a.sum as sumall 
 from 
 (
   (select extract(month from p.dtpaid) month, sum(p.sum) sum, max(g.name) as ie_name
    from
      sn_calendar_payments p, sn_calendar_accounts ac, ref_expenseitems g
    where
      p.id_account = ac.id and
      g.id = ac.id_expenseitem and 
      extract(year from p.dtpaid) = 2022
    group by g.name, extract(month from p.dtpaid))    
    union
    (select extract(month from c.dt) month, sum(c.sum) sum, 'Прочие расходы' as ie_name
    from
      sn_cash_payments c
    where
      c.receiver = 1 and
      extract(year from c.dt) = 2022
    group by extract(month from c.dt)
    )
    )
    a
    )  
  group by ie_name
  ;
  
  --получение списка лет, за которые есть расходы
  select y from (
      select to_char(dtpaid, 'yyyy') y from sn_calendar_payments p
      union
      select to_char(dt, 'yyyy') y from sn_cash_payments c where c.receiver = 1
  )    
  where y is not null
  group by y
  order by y asc; 
  
  
  
  
  
  
  
  


/*
   (select extract(month from p.dtpaid) month, sum(p.sum) sum, max(g.name) as ie_name
    from
      sn_calendar_payments p, sn_calendar_accounts ac, ref_expenseitems g
    where
      p.id_account = ac.id and
      g.id = ac.id_expenseitem and 
      g.id = 109 and 
      extract(year from p.dtpaid) = 2022 and
      extract(month from p.dtpaid) = 10
    group by g.name, extract(month from p.dtpaid));    

   select *
    from
      sn_calendar_payments p, sn_calendar_accounts ac, ref_expenseitems g
    where
      p.id_account = ac.id and
      g.id = ac.id_expenseitem and 
      g.id = 109 and 
      extract(year from p.dtpaid) = 2022 and
      extract(month from p.dtpaid) = 10
   order by p.dtpaid      ;
*/


--select sq_ref_sn_organizations.nextval from dual;

--выборка счетов за наличный расчет для удаления
select id, filename, type, maxdtpaid from v_sn_calendar_accounts where type <> 1 and paimentstatus = 'полностью' and maxdtpaid < (select dt from sn_cash_revision_dt) order by maxdtpaid desc;  

select * from v_sn_orders where restsum = 0 and (maxdtpaid is null or maxdtpaid < (select dt from sn_cash_revision_dt));





---------------------------
select * from sn_calendar_accounts where id_whoagreed1 is null;











--================================================================================
--update sn_calendar_t_basis set id_order = null;
--delete from sn_orders_add;
--delete from sn_order_payments; 
