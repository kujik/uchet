
alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;

--таблица групп материалов, которые используются для смет (не все группы)
--данные сеййчас вставляются вручную для первых трех групп, чтобы использовать их в коде по айди, остальные автоматом.
--alter table material_groups add dim varchar2(30); 
--alter table material_groups drop column dim; 
create table material_groups(
  id number(11),
  name varchar2(1000) not null,     --наименование для учета
  name_bcad varchar2(1000) not null,--наименование в бкад
  constraint pk_material_groups primary key (id)
);

--наименовани группы и наименование группы по бкад должны быть уникальными
create unique index idx_material_groups_name on material_groups(lower(name)); 
create unique index idx_material_groups_name_bcad on material_groups(lower(name_bcad));

create sequence sq_material_groups start with 3 nocache;
 

--пока две группы
insert into material_groups (id, name, name_bcad) values (-1, 'Материалы без групп', 'Материалы без групп');
insert into material_groups (id, name, name_bcad) values (1, 'Панели: Материалы основы', 'Панели: Материалы основы');
insert into material_groups (id, name, name_bcad) values (2, 'Панели: Материалы кромок', 'Панели: Материалы кромок');

create or replace trigger trg_material_groups_bi_r
  before insert
  on material_groups
  for each row
begin
  if :new.id is null then
    select sq_material_groups.nextval into :new.id from dual;
  end if;
  if :new.name is null then
    :new.name := :new.name_bcad;
  end if;
end;
/




--+++++++++++
--уточняющие группы, вводятся вручную, нужны так как реальная обработка может быть разной по одной группе бкад
--сейчас это для плитных, там есть рельно плитные мателиалы, а есть мебель и прочее
create table material_addgroups(
  id number(11),
  id_group number(11),     --айди группы
  name varchar2(400),      --наименование
  constraint pk_material_addgroups primary key (id)
);

create unique index idx_material_addgroups on material_addgroups(lower(name), id_group); 

insert into material_addgroups (id, id_group, name) values (1, 1, 'Плитные');
insert into material_addgroups (id, id_group, name) values (2, 1, 'Прочее');



--+++++++++++
--таблица материалов, собранных из смет, соответствует материалам бкад
--alter table materials add dim varchar2(30); 
create table materials(
  id number(11),
  id_group number(11) not null,     --айди группы, но пока не делаем форин кей, группа только 1, что соотвествует плитным материалам
  id_addgroup number(11),           --признак, что материал соответствуе группе, в смысле что в Плитных (материалы основы) есть, например, Мебель, для нее должно быть проставлено несоотвествие (0 - ?, 1- соотв, 2 - не соотв)
  name varchar2(1000) not null,     --наименование материала, предполагается уникальным по всей базе без учета регистра
  dim varchar2(30),                 --единица измерения, строка как есть в базе бкад
  dt date,                          --дата и время добаления в базу
  active number(1) default 1,       --признак, что материал используется (1)
  constraint pk_materials primary key (id)
);

create unique index idx_materials_name on materials(lower(name)); 

create sequence sq_materials start with 1 nocache;

--автоматически присвоим при вставке айди и установим дату добавления материала
create or replace trigger trg_materials_bi_r
  before
  insert
  on materials
  for each row
begin
  select sq_materials.nextval into :new.id from dual;
  select SysDate into :new.dt from dual;
end;
/

create or replace view v_r_materials as 
select
  m.*,
  g.name as groupname
from
  materials m,
  material_groups g
where
  m.id_group = g.id
;      


/*
create table orders(
  id number(11),              --айди заказа, присваивается триггером
  id_or_uchet number(11),     --айди заказа в схеме Uchet
  year number(4),             --год заказа 
  or_char varchar2(10),       --литера заказа
  or_num number(10),          --числовой номер заказа
  dt_beg date,                --дата создания заказа
  constraint pk_orders primary key (id)
);  
*/

--таблица файлов, привязанных к заказу 
create table order_files(
  id number(11),
  id_order number(11),        --айди заказа, не ставим форин кей, тк таблица в другой схеме
  filetype number(2),         --код типа файла, 1-смета, 2-заявка сн, 3-заявка сн общая 
  filename varchar(400),      --имя файла общей сн/общей сметы, включая путь относительно каталога заказа
  filedt date,                --его дата модификации
  constraint pk_order_files primary key (id)
);  

create sequence sq_order_files start with 100 nocache;

--автоматически присвоем при вставке айди
create or replace trigger trg_order_files_bi_r
  before insert on order_files for each row
begin
  select sq_order_files.nextval into :new.id from dual;
end;
/



--+++++++++++
--таблица смет по заказам
--alter table order_smeta add deleted number(1);
create table order_smeta(
  id number(11),
  id_order number(11),        --айди заказа, не ставим форин кей, тк таблица в другой схеме
  year number(4),             --год заказа 
  or_char varchar2(10),       --литера заказа
  or_num number(10),          --числовой номер заказа
  or_slash number(10),        --числовой номер слэша
  dt date,                    --дата, когда была загружена/обновлена смета
  deleted number(1),          --
  constraint pk_order_smeta primary key (id)
);  

--номер заказа+слэш должен быыть уникальным по году  
create unique index idx_order_smeta_order on order_smeta(year, or_char, or_num, or_slash); 
  
create sequence sq_order_smeta start with 1 nocache;

--автоматически присвоем при вставке айди
create or replace trigger trg_order_smeta_bi_r
  before insert on order_smeta for each row
begin
  select sq_order_smeta.nextval into :new.id from dual;
end;
/


--+++++++++++
--таблица материалов в сметах
--alter table order_smeta_materials add deleted number(1);
create table order_smeta_materials(
  id number(11),
  id_smeta number(11),        --айди сметы в таблице смет
  id_material number(11),     --айди материала 
  qnt number(15,4),           --количество (на все изделия, если их несколько, с учетом т.е. кратности, на одно изделие нельзя вытащить из объединенных СН) 
  deleted number(1),          --признак, что материал удален из сметы (1), сделано, тк ссылка на материал может уже быть в таблицах, а надо обозначить, что он ислкючен
  constraint pk_order_smeta_materials primary key (id),
  constraint pk_order_smeta_materials_s foreign key (id_smeta) references order_smeta(id) on delete cascade,  
  constraint pk_order_smeta_materials_m foreign key (id_material) references materials(id)  
);  


create unique index idx_order_smeta_materials_1 on order_smeta_materials(id_smeta, id_material); 
  
create sequence sq_order_smeta_materials start with 1 nocache;

--автоматически присвоем при вставке айди
create or replace trigger trg_order_smeta_materials_bi_r
  before insert on order_smeta_materials for each row
begin
  select sq_order_smeta_materials.nextval into :new.id from dual;
end;
/



--++++++++++++++++++++++++++++++++++
--тбалица по заказам (изделиям) принятым ОТК
create table order_otk(
  id number(11),
  id_order number(11),      --айди заказа
  pos number(11),           --номер слеша 
  qnt number(11),           --количество принятых 
  dt date,                  --дата приема
  constraint pk_order_otk primary key (id)
);  

create unique index idx_order_otk on order_otk(id_order, pos, dt); 
  
create sequence sq_order_otk start with 1 nocache;

create or replace trigger trg_order_otk_bi_r
  before insert on order_otk for each row
begin
  select sq_order_otk.nextval into :new.id from dual;
end;
/

--список изделий по слешам, с информацией по заказу, и количеству принятых изделий
create or replace view v_order_otk_items as (
  select
    i.id_order || '-' || i.pos as id, 
    i.*,
    i.org || ' ' || i.num as ordernumfull,
    i.org || ' ' || i.num || ' (' || i.year || ')    ' || c.customer || ' ' || p.name as ordernamefull,
    i.org || ' ' || i.num || '_' || i.pos as itemnumfull,
    c.customer as customername,
    p.name as projectname,
    o1.qnt as qnt_otk_curr,
    o2.qnt as qnt_otk,
    (case 
      when o2.qnt >= i.qnt then 'принят'
      when o2.qnt < i.qnt and o2.qnt > 0 then 'частично'
      else 'не принят'
    end) as otk_status,
    o2.dt_otk_max  
  from
    uchet.v_to_passport_items_current i,
    uchet.to_projects p,
    uchet.to_customers c,
    order_otk o1,
    (select sum(qnt) as qnt, id_order, pos, max(dt) as dt_otk_max from order_otk group by id_order, pos) o2
  where
    i.id_customer = c.id_customer and
    i.id_project = p.id_project and
    i.qnt > 0 and
    o1.id_order(+) = i.id_order and o1.pos(+) = i.pos and o1.dt(+) = trunc(sysdate) and
    o2.id_order(+) = i.id_order and o2.pos(+) = i.pos
);

select * from v_order_otk_items where dt_otgr is null;
select distinct projectname from v_order_otk_itemst;
select count(1) from uchet.v_to_passport_items;













































--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--alter table order_item_stages add qnt11 number(11);
--alter table order_item_stages add qnt number(12,3);
--alter table order_item_stages drop column  qnt11;
--Операции:
--1-в производство
--2-приемка на СГП
--3-отгрузка с СГП
--4-приёмка на ОТК
create table order_item_stages(
  id number(11),
  id_order_item number(11), --айди заказа
  id_stage  number(11),     --айди этапа 
  qnt number(11),           --количество принятых 
  dt date,                  --дата приема
  constraint pk_order_item_stages primary key (id),
  constraint fk_order_item_stages_oritem foreign key (id_order_item) references order_items(id) on delete cascade
);  


create table order_item_stages_3 as select * from order_item_stages;

create unique index idx_order_item_stages on order_item_stages(id_order_item, id_stage, dt);
create index idx_order_item_stages_idoi on order_item_stages(id_order_item); 
 
  
create sequence sq_order_item_stages start with 1 nocache;

create or replace trigger trg_order_item_stages_bi_r
  before insert on order_item_stages for each row
begin
  select sq_order_item_stages.nextval into :new.id from dual;
end;
/

create or replace trigger trg_order_item_stages_biud_r
--в триггере пишем события изменения таблицы этапов заказа в лог действий 
  before insert or update or delete on order_item_stages for each row
declare
  orslash varchar2(30); 
  std varchar2(30); 
begin
  begin
  if deleting then
    --select decode(:old.id_stage, 2, 'СГП-приемка', 3, 'СГП-отгрузка', 4, 'ОТК', :old.id_stage) into std from dual;
    --select slash into orslash from v_order_items where id = :old.id_order_item;
    --insert into adm_db_log (itemname, comm, dt) values (std || ' -уд', orslash || ' = ' || :old.qnt || '  (i=' || :old.id_order_item || ')', sysdate);
    if :old.id_stage = 2 then
      update order_items set qnt_to_sgp = qnt_to_sgp - :old.qnt where id = :old.id_order_item;
    end if;   
    P_ToUchetLog(:old.id_stage, null, :old.id_order_item, null, -:old.qnt, null, :old.dt, null, null, null);
  end if;
  if updating then
    --select decode(:new.id_stage, 2, 'СГП-приемка', 3, 'СГП-отгрузка', 4, 'ОТК', :new.id_stage) into std from dual;
    --select slash into orslash from v_order_items where id = :new.id_order_item; 
    --insert into adm_db_log (itemname, comm, dt) values (std || ' -изм', orslash || ' = ' || :new.qnt || '  (i=' || :new.id_order_item || ')', sysdate);
    if :new.id_stage = 2 then
      update order_items set qnt_to_sgp = qnt_to_sgp - :old.qnt + :new.qnt where id = :new.id_order_item;
    end if;   
    P_ToUchetLog(:new.id_stage, null, :new.id_order_item, null, nvl(:new.qnt,0) - nvl(:old.qnt,0), null, :new.dt, null, null, null);
  end if;
  if inserting then
    --select decode(:new.id_stage, 2, 'СГП-приемка', 3, 'СГП-отгрузка', 4, 'ОТК', :new.id_stage) into std from dual;
    --select slash into orslash from v_order_items where id = :new.id_order_item; 
    --insert into adm_db_log (itemname, comm, dt) values (std || ' -доб', orslash || ' = ' || :new.qnt || '  (i=' || :new.id_order_item || ')', sysdate);
    if :new.id_stage = 2 then
      update order_items set qnt_to_sgp = qnt_to_sgp + :new.qnt where id = :new.id_order_item;
    end if;   
    P_ToUchetLog(:new.id_stage, null, :new.id_order_item, null, :new.qnt, null, :new.dt, null, null, null);
  end if;
  exception
  when others then
  null;
  end;
end;
/


create or replace view v_order_items_for_stages as
--промежуточное представление для получения данных из журнала заказов 
  select
    i.*,
    o.ornum,
    o.id_organization,
    --o.area,
    --o.customer,
    --o.project,
    o.ornum || '_' || substr('000000' || i.pos, -3) as slash,
    o.id_itm as id_order_itm,
    o.sync_with_itm,
    o.dt_beg,
    o.dt_end,
    o.dt_otgr,
    o.path,
    o.in_archive,
    s.name as itemname,
    (case 
      when ee.id > 0 then ee.prefix
      else ''
    end) prefix, 
    (case 
      when ee.id > 0 then ee.prefix || '_'
      else ''
    end) || s.name  as fullitemname,  --наименование с префиксом формата, только для стандартных изделий и стандартной д/к
    F_OrItemRoute(i.r1,i.r2,i.r3,i.r4,i.r5,i.r6,i.r7,i.r8,i.r9) as route2
  from
    order_items i,
    --v_orders o,
    orders o,
    or_std_items s,
    or_format_estimates ee 
 where
   i.id_order = o.id 
   and i.id_std_item = s.id (+) 
   and s.id_or_format_estimates = ee.id (+)
;

create or replace view v_order_item_stages1 as
select
  i.id,
  i.slash,
  i.itemname,
  i.fullitemname,
  i.id as id_order_item,
  i.id_std_item,
  i.qnt,
  i.sgp,
  null as resale,
  i.route2,
  i.id_order,
  --1 - отправка в производство, не требуется для изделий, отгружаемых с сгп, и для доп комплектации
  qnt1, dt1b, dt1e, is1.qnt as qnt1c, is1.dt as dt1c,
   (case when not(nvl(i.sgp,0) = 1/* or nvl(i.resale,0) = 1*/ or i.qnt = 0) then (case when qnt1 >=  i.qnt then 2 when qnt1 is not null then 1 else 0 end) else null end) as st1,
  --2 - приемка на сгп, для изделий всех заказов, кроме изделий с сгп (склад плитных и панелей тут не разделяем)
  qnt2, dt2b, dt2e, is2.qnt as qnt2c, is2.dt as dt2c,
   --(case when qnt2 >=  i.qnt then 2 when qnt2 is not null then 1 else 0 end) as st2,
   (case when not(nvl(i.sgp,0) = 1 or i.qnt = 0) then (case when qnt2 >=  i.qnt then 2 when qnt2 is not null then 1 else 0 end) else null end) as st2,
  --3 - отгрузка с сгп, все изделия заказов, кроме производственных (П, id_org = -1)
  qnt3, dt3b, dt3e, is3.qnt as qnt3c, is3.dt as dt3c,
   (case when i.id_organization <> -1 and i.qnt <> 0 then (case when qnt3 >=  i.qnt then 2 when qnt3 is not null then 1 else 0 end) else null end) as st3,
  --4 - приемка ОТК, для изделий всех заказов, кроме изделий с сгп /как и для оп=2/
  qnt4, dt4b, dt4e, is4.qnt as qnt4c, is4.dt as dt4c,
   (case when not(nvl(i.sgp,0) = 1 or i.qnt = 0) then (case when qnt4 >=  i.qnt then 2 when qnt4 is not null then 1 else 0 end) else null end) as st4
from
--  v_order_items i,
  v_order_items_for_stages i,
 (select 
   id_order_item, 
   max(qnt1) as qnt1, min(dt1b) as dt1b, max(dt1e) as dt1e, 
   max(qnt2) as qnt2, min(dt2b) as dt2b, max(dt2e) as dt2e, 
   max(qnt3) as qnt3, min(dt3b) as dt3b, max(dt3e) as dt3e, 
   max(qnt4) as qnt4, min(dt4b) as dt4b, max(dt4e) as dt4e 
   from
 (select id_order_item,
   sum(decode(s1.id_stage, 1, s1.qnt, null)) as qnt1, min(decode(s1.id_stage, 1, s1.dt, null)) as dt1b, max(decode(s1.id_stage, 1, s1.dt, null)) as dt1e,
   sum(decode(s1.id_stage, 2, s1.qnt, null)) as qnt2, min(decode(s1.id_stage, 2, s1.dt, null)) as dt2b, max(decode(s1.id_stage, 2, s1.dt, null)) as dt2e, 
   sum(decode(s1.id_stage, 3, s1.qnt, null)) as qnt3, min(decode(s1.id_stage, 3, s1.dt, null)) as dt3b, max(decode(s1.id_stage, 3, s1.dt, null)) as dt3e, 
   sum(decode(s1.id_stage, 4, s1.qnt, null)) as qnt4, min(decode(s1.id_stage, 4, s1.dt, null)) as dt4b, max(decode(s1.id_stage, 4, s1.dt, null)) as dt4e 
 from order_item_stages s1 group by id_order_item, id_stage) s
 group by id_order_item) ss
 ,order_item_stages is1
 ,order_item_stages is2
 ,order_item_stages is3
 ,order_item_stages is4
where
  i.id = ss.id_order_item (+) 
  and i.id = is1.id_order_item (+) and is1.id_stage (+) = 1 and is1.dt (+) = sys_context('context_uchet22','order_stages_dt1c')  
  and i.id = is2.id_order_item (+) and is2.id_stage (+) = 2 and is2.dt (+) = sys_context('context_uchet22','order_stages_dt2c')  
  and i.id = is3.id_order_item (+) and is3.id_stage (+) = 3 and is3.dt (+) = sys_context('context_uchet22','order_stages_dt3c')  
  and i.id = is4.id_order_item (+) and is4.id_stage (+) = 4 and is4.dt (+) = sys_context('context_uchet22','order_stages_dt4c')  
;         

select * from v_order_item_stages1 where id_order = 49;
select * from v_order_stages1 where id = 8091;


create or replace view v_order_stages1 as
select
  o.id,
  o.ornum,
  o.dt_beg,
  o.dt_otgr,
  o.project,
  o.dt_end,
  ss.dt1b, ss.dt1e, st1, 
  ss.dt2b, ss.dt2e, st2, 
  ss.dt3b, ss.dt3e, st3,
  ss.dt4b, ss.dt4e, st4 
from
  --v_orders o,
  orders o,
  (select 
    id_order,
    min(dt1b) as dt1b,  max(dt1e) as dt1e, F_GetOrderStage_State(min(st1), max(st1)) as st1, 
    min(dt2b) as dt2b,  max(dt2e) as dt2e, F_GetOrderStage_State(min(st2), max(st2)) as st2, 
    min(dt3b) as dt3b,  max(dt3e) as dt3e, F_GetOrderStage_State(min(st3), max(st3)) as st3, 
    min(dt4b) as dt4b,  max(dt4e) as dt4e, F_GetOrderStage_State(min(st4), max(st4)) as st4 
    from v_order_item_stages1 s
    group by id_order
  ) ss
where  
  o.id = ss.id_order
--and id = 49  
--and in_stage_stanki = 0-- is not null  
;  

select count(*) from v_order_stages1 where dt_beg = '28.10.2024';
select to_char(id) as id, dt_end, ornum, dt_beg, dt_otgr, project, st2, dt2b, dt2e, dt_otk, period from v_order_stages1_tosgp where dt_beg = '28.10.2024' and id > 0 and st2 is not null;



create or replace function F_GetOrderStage_State(
--возвращает статус выполнения шага заказа, для каждой его позиции
--могут быть значений null, 0 - ничего не выполнено, 1 - частично, 2 - полностью
--по минимальному и максимальному значениям для изделий получим итоговое для заказа
  StMin number, 
  StMax number
) 
return 
  number
is  
begin
  if StMin is null then
    return null;
  elsif StMin = 2 then
    return 2;
  elsif StMax = 0 then
    return 0;
  else return 1;
  end if;      
end;
/
  
    
    
create or replace procedure p_OrderStage_SetMainTable(
--обновим поля в таблице заказов на основании таблицы этапов заказа
--данные по ним берем из вьюхи
  IdOrder number,      --айди заказа                      
  IdStage number       --номер операции
) is                    
  st1 number;
  sqltxt varchar2(4000);
  dt1 date;
begin
  if not(IdStage in (2, 3)) then
    return;
  end if;
  --если для операций На СГП, с СГП во всему заказу завершено, то проставляем даты в таблице заказов, иначе ставим пустые даты
  sqltxt := 'select dt' || IdStage || 'e, st' || IdStage || ' from v_order_stages1 where id = :idorder';
  execute immediate sqltxt into dt1, st1 using IdOrder;
  if nvl(st1, 0) <> 2 then dt1 := null; end if;
  sqltxt := 'update orders set ' || case when IdStage = 2 then 'dt_to_sgp' else 'dt_from_sgp' end || ' = :dt1 where id = :idorder';  
  execute immediate sqltxt using dt1, IdOrder;
end;
/  

create or replace procedure p_OrderStage_SetItem(
--зададим количество принятых изделий по позиции заказа для указанной операции за указанную дату
--если указан 0, то запись на эту дату будет удалена
--за заданную дату количество будет установлено не большее, чем остаток (непринятые), если 0, то запись на дату будет удалена
  IdOrderItem number,  --айди изделия в заказе                      
  IdStage number,      --номер операции                  
  NewDt date,          --дата, за которую устанавливаем
  NewQnt number,       --количество, которое устанавливаем  
  UpdateOrders number, --если =1, то обновляем таблицу orders (для операций 2=на сгп, 3=отгрузка с сгп)  
  ResQnt out number,   --вернем количество, которое установили
  Adding number default 0  --если не 0, то NewQnt добавляется к количеству, которое уже есть на данную дату
) is 
  id1 number;
  sqltxt varchar2(4000);
  qnt1 number(11,5);
  qnt2 number(11,5);
  FNewQnt number(11,5);
  qnt_or number(11,5);
  dt1 date;
  IdOrder number;      --айди заказа                      
begin
  --if IdStage in (1, 2, 3) then
  select nvl(sum(qnt),0) into qnt1 from order_item_stages where id_order_item = IdOrderItem and id_stage = IdStage and dt <> NewDt;
  begin 
    sqltxt := 'select nvl(qnt,0), id from order_item_stages where id_order_item = :IdOrderItem and id_stage = :IdStage and dt = :NewDt';
    execute immediate sqltxt into qnt2, id1 using IdOrderItem, IdStage, NewDt;
  exception
    when no_data_found then
      id1 := -1;
      qnt2 := 0;
  end;
  select nvl(qnt,0) into qnt_or from order_items where id = IdOrderItem; 
  FNewQnt := NewQnt;
  if Adding <> 0 then
    FNewQnt := NewQnt + qnt2;
  end if;
  ResQnt := FNewQnt;
  if qnt2 = ResQnt then
    Return;
  end if;
  ResQnt := greatest(least(qnt_or - qnt1, FNewQnt), 0);
  --dbms_output.put_line(newqnt || ' ' || qnt1 || ' ' ||  resqnt);
  if id1 > 0 and qnt2 = ResQnt then
    Return;
  end if;
  if ResQnt <= 0 then
    if id1 <> -1 then
      delete from order_item_stages where id = id1;
    end if;
  else
    if id1 <> -1 then
      update order_item_stages set qnt = ResQnt where id = id1;
    else
      insert into order_item_stages (id_order_item, id_stage, dt, qnt) values (IdOrderItem, IdStage, NewDt, ResQnt);
    end if;
  end if;
  if (UpdateOrders = 1) and (IdStage in (2, 3)) then
    select id_order into IdOrder from order_items where id = IdOrderItem; 
    p_OrderStage_SetMainTable(IdOrder, IdStage);
/*  
  sqltxt := 'select dt' || IdStage || 'b, st' || IdStage || ', qnt, id_order from v_order_item_stages1 where id = :IdOrderItem';
  execute immediate sqltxt into dt1, qnt2, qnt1, IdOrder using IdOrderItem;
  sqltxt := dt1 || qnt1 || qnt2;
  update test2 set d = sqltxt where t = 0;
  select dt1b, st1 into dt1, qnt2 from v_order_stages1 where id = IdOrder;
  sqltxt := dt1 || ' ' || qnt2;
  update test2 set d = sqltxt where t = 1;*/
  end if;
end;
/  

select * from order_item_stages where id_order_item = 9210 and id_stage = 1;
select * from order_item_stages where id_order_item = 11700 and id_stage = 1;
select sum(qnt) from order_item_stages where id_order_item = 11700 and id_stage = 15 and dt <> '27.02.2024';

declare
  q number;
begin
p_OrderStage_SetItem(11700,1,'27.02.2024',3,q);
--dbms_output.put_line(q);
end;
/


select * from v_order_item_stages1;



create or replace view v_nom_for_orders_in_prod as
select
--номенклатура по изделиям, находящимся сейчас в производстве
--(если номенклатура является изделием, она не разворачивается)
  max(n.id_nomencl) as id_nomencl,
  max(bn.name) as name,
  sum(ei.qnt1_itm * i.qnt_inprod) as qnt_inprod 
from
--  v_oritms_all_in_prod i,
  v_oritms_pn_in_prod i,
  estimates e,
  estimate_items ei,
  bcad_nomencl bn,
  dv.nomenclatura n
where    
  e.id_order_item (+) = i.id_order_item
  and ei.id_estimate = e.id
  and nvl(ei.qnt1_itm, 0) <> 0
  and bn.id = ei.id_name
  and n.name = bn.name
group by 
  ei.id_name  
;  


create or replace view v_nom_for_orders_in_prod_2 as
select
--номенклатура по изделиям, находящимся сейчас в производстве
--(только номенклатурая, являющаяся материалами, изделиян е разворачиваются)
--реально (то есть за вычетом резерва по этой номенклатуре),
--с подробностями (резерв, потребность, остаток на складах, цена)
  m.id,
  n.name,
  n.qnt_inprod as qnt_toprod,
  n.qnt_inprod + m.rezerv as qnt_inprod,  
  m.rezerv,
  m.qnt,
  m.need,
  m.need_p,
  m.qnt_onway,
  nvl(m.price_last, 0) / 1.2 as price
from  
  v_nom_for_orders_in_prod n,
  v_spl_minremains m
where
  n.id_nomencl = m.id
;

-------------------------------------------------------------------------------

create or replace view v_oritms_all_in_prod_detail as
--изделия, производимые сейчас по всем незакрытым заказам (кроме изделий с сгп)
--(которые еще не приняты в полном составе на СГП)
select
  i.id_order_item as id,
  o.dt_beg,            --дата оформления заказа
  o.dt_end,            --фактическая дата закрытия заказа в Учете
  o.dt_otgr,           --плановая дата отгрузки
  o.project,
  s.name as itemname,  --наименование слэша (без префикса)
  i.id_order,          --айди азказа
  i.qnt,               --количестов по слеешу в заказе
  i.qnt2,              --принято на сгп
  i.qnt_inprod,
  i.qnt - i.qnt_inprod as qnt_rest, 
  o.ornum || '_' || substr('000000' || i.pos, -3) as slash,   --№ слэша
  pa.shortname as area_short
from
  orders o,  
  or_std_items s,
  ref_production_areas pa, 
(select 
  i.id as id_order_item, sum(i.qnt) as qnt, sum(nvl(os.qnt,0)) as qnt2, sum(i.qnt) - sum(nvl(os.qnt,0)) qnt_inprod, 
  max(id_order) as id_order,
  max(pos) as pos,
  max(i.id_std_item) as id_std_item
from 
  (select id_order_item, sum(qnt) as qnt from order_item_stages where id_stage = 2 group by id_order_item) os, 
  order_items i,
  orders o
where 
  os.id_order_item (+) = i.id
  and i.qnt > 0 and nvl(i.sgp, 0) <> 1 
  and o.id = i.id_order and o.dt_end is null and o.id > 0 
group by i.id
having sum(i.qnt) - sum(nvl(os.qnt,0)) > 0
) i
where
  o.id = i.id_order
  and i.id_std_item = s.id
  and pa.id(+) = o.area 
   
;

--------------------------------------------------------------------------------

--таблица комментариев по просрочкам заказа в производстве
create table delayed_prod_reasons (
  id number(11),             --айди таблицы, оно же айди заказа - так как причины привязаны к заказу
  id_reason number(11),      --айди причины просрочки из справочника 
  comm varchar(4000),        --произвольный комментарий
  constraint pk_delayed_prod_reasons primary key (id),
  constraint fk_delayed_prod_reasons_or foreign key (id) references orders(id) on delete cascade,
  constraint fk_delayed_prod_reasons_res foreign key (id_reason) references ref_delayed_prod_reasons(id)
);

--журнал просрочки заказов в производстве (по заказам)
--ориентируемся на дату приема отк, выбираем записи, по которым требуется пприемка 
--и позднейшая дата приема не раньше плановой даты отгрузки,
--либо статус не принят или не полностью принят (а при выборе отсеим по дате отгрузки в пределах периода)
create or replace view v_order_delinprod as
select 
  v.*,
  s.dt2e,
  s.st2,
  rdr.id as id_delreason,
  rdr.name as delreasonname,
  dr.comm as delreasoncomm
from
  v_orders v,
  v_order_stages1 s,
  delayed_prod_reasons dr,
  ref_delayed_prod_reasons rdr
where
  v.id = s.id and
  v.id = dr.id(+) and
  dr.id_reason = rdr.id (+) 
  and s.st2 is not null
  and 
  ((s.dt2e >= v.dt_otgr) or (st2 < 2))
;      

select ornum, dt_beg, dt_otgr, dt2e, st2 from v_order_delinprod;

--журнал просрочки заказов в производстве (по слешам)
--аналогично тому что по заказам
create or replace view v_order_delinprod_items as
select 
  v.*,
  s.dt2e,
  s.st2
from
  v_order_items v,
  v_order_item_stages1 s
where
  v.id = s.id 
  and s.st2 is not null
  and 
  ((s.dt2e >= v.dt_otgr) or (st2 < 2))
;


--------------------------------------------------------------------------------

--таблица комментариев по просрочкам заказа в производстве
create table delayed_prod_reasons (
  id number(11),             --айди таблицы, оно же айди заказа - так как причины привязаны к заказу
  id_reason number(11),      --айди причины просрочки из справочника 
  comm varchar(4000),        --произвольный комментарий
  constraint pk_delayed_prod_reasons primary key (id),
  constraint fk_delayed_prod_reasons_or foreign key (id) references orders(id) on delete cascade,
  constraint fk_delayed_prod_reasons_res foreign key (id_reason) references ref_delayed_prod_reasons(id)
);


--------------------------------------------------------------------------------

--таблица просроченных для ОТК
--содержит ссылку на изделие, количество непринятых, дату, причину непринятия, и комментарий
--причина для конкретного слэша единственная по логике, по факту могут быть разные на данную дату, это логически подразумевает что 
--допустим 2 изделия не приняты по Причине1, а еще одно - по Причине2
alter table or_otk_rejected add dt date;
drop sequence sq_or_otc_rejected ;
drop trigger trg_or_otc_rejected_bi_r;
create table or_otk_rejected (
  id number(11),             --айди таблицы
  id_order_item number(11),  --айди изделия в заказе
  qnt number(11,3),          --количество непринятых по данной позиции
  dt date,
  id_reason number(11),      --айди причины непринятия из справочника 
  comm varchar(4000),        --произвольный комментарий
  constraint pk_or_otk_rejected primary key (id),
  constraint fk_or_otk_rejected_or foreign key (id_order_item) references order_items(id) on delete cascade,
  constraint fk_or_otk_rejected_res foreign key (id_reason) references ref_otk_reject_reasons(id)
);

create index idx_or_otk_rejected_oritem on or_otk_rejected(id_order_item);
create index idx_or_otk_rejected_2 on or_otk_rejected(id_order_item, id_reason);
      
--create unique index idx_ref_customers_n on re_customers(lower(name));

create sequence sq_or_otk_rejected nocache;

create or replace trigger trg_or_otk_rejected_bi_r
  before insert on or_otk_rejected for each row
begin
  select sq_or_otk_rejected.nextval into :new.id from dual;
end;
/


--вью для журнала приемки ОТК, по изделиям
--добавим признак, что по изделию были замечания (есть ненулевые причины неприемки)
create or replace view v_order_item_stages1_otk as
select
  s.*,
  o.r,
  (case when o.r is null then 0 else 1 end) is_rej,
  (case when o.r is null then 'без замечаний' else 'с замечаниями' end) rej
from
  v_order_item_stages1 s,  
  (select id_order_item, max(id_reason) as r from or_otk_rejected group by id_order_item) o
where
  s.st4 is not null and
  o.id_order_item (+) = s.id
;

create or replace view v_order_item_stages1_otk as
select
  s.*,
  o.r,
  (case when o.r is null then 0 else 1 end) is_rej,
  (case when o.r is null then 'без замечаний' else 'с замечаниями' end) rej
from
  v_order_item_stages1 s,  
  (select -9 as id_order_item, null as r from dual) o
  --(select id_order_item, max(id_reason) as r from or_otk_rejected group by id_order_item) o
where
  s.st4 is not null and
  o.id_order_item (+) = s.id
;    
    
 
select * from v_order_item_stages1_otk where r is not null;     

--вью для журнала приемки ОТК, по полным заказам
--добавим признак, что по изделию были замечания (есть ненулевые причины неприемки)
create or replace view v_order_stages1_otk as
select
  s.*,
  o.r,
  (case when o.r is null then 0 else 1 end) is_rej,
  (case when o.r is null then 'без замечаний' else 'с замечаниями' end) rej
from
  v_order_stages1 s,  
  (select id_order, max(r) as r from v_order_item_stages1_otk where r is not null group by id_order) o
where
  s.st4 is not null and
  o.id_order (+) = s.id
;


select * from v_order_stages1_otk; -- where r is not null;     

--------------------------------------------------------------------------------
-- журнал по монтажу
--записи пмрименяются только к самим заказам, по слешам учета нет
create table or_montage (
  id number(11),             --айди таблицы, он же айди заказа
  dt_beg date,
  dt_end date,
  rep_customer number(1),    --1, если было замечание покупателя    reprimand
  rep_installer number(1),   --1, если было замечание монтажников 
  comm varchar2(4000),       --произвольный комментарий
  path varchar2(100),        --путь в каталоге учета для фотоотчетов и актов    
  constraint pk_or_montage primary key (id),
  constraint fk_or_montage_or foreign key (id) references orders(id) on delete cascade
);


create or replace view v_or_montage as select
  o.*,
  m.dt_beg as dt_montage_beg_real,
  m.dt_end as dt_montage_end_real,
  m.rep_customer,
  (case when m.rep_customer = 1 then 'с замечаниями' else 'без замечаний' end) rep_customer_txt,
  m.rep_installer,
  (case when m.rep_installer = 1 then 'с замечаниями' else 'без замечаний' end) rep_installer_txt,
  m.comm as montage_comm,
  m.path as montage_path
from
  v_orders o,
  or_montage m
where
  o.id = m.id(+)    
;  

--------------------------------------------------------------------------------
--вью приемки на сгп
--добавлена дата полной приемки заказа ОТК и разница между приемкой на склад и ней
create or replace view v_order_stages1_tosgp as
select
  s.*,
  case when s.st4 = 2 then s.dt4e end as dt_otk,
  case when s.st4 = 2 and s.st2 = 2 then s.dt2e - s.dt4e end as period
from
  v_order_stages1 s  
;

create or replace view v_order_item_stages1_tosgp as
select
  s.*,
  case when s.st4 = 2 then s.dt4e end as dt_otk,
  case when s.st4 = 2 and s.st2 = 2 then s.dt2e - s.dt4e end as period
from
  v_order_item_stages1 s  
;


select * from v_order_stages1_tosgp where dt_end is null;
select * from v_order_item_stages1_tosgp where dt_otk is not null;