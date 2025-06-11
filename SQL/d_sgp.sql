/*
Таблица наличия на складе готовой продукции изделий по выбранному типу стандартных изделий.

Из таблицы стандартных изделий выбираются те из них, по которым в справочнике проставлена галка Учет по СГП (проставляют менеджеры, для тех по которым нужен учет)
Данная галка должна проставляться только для изделий ОТГРУЗОЧНЫХ форматов, если будет указан для производственнх то учет по этому формату будет неверный!
В дальннейшем общее количество запущенных в производство определяетсяпо заказам типа П (id_organization = -1),
количество заказанных клиентами из таблицы orders по всем остальным организациям,
количество принятых на сгп считается суммированием всех принятых производственных заказвов по таблице приемки сгп (order_stages с id_stage = 2), без учета ревизии,
(на сгп не принимаются изделия с галкой в паспорте "С сгп", но мы учитываем только производственные, для которых этого быть не должно)
количество отгруженных считается по таблице отгрузки с сгп order_stages/id_stage = 3, без учета ревизии,
текущий остаток, план отгрузки считаются суммой/разницей этих четырех значений, с учетом ревизии
(отдельно в таблицах sgp_act_in_items, sgp_act_out_items (количество из обеих плюсуется - в последней таблице оно отрицательное всегда)
минимальный остаток (для контроля), вводится в самой таблице сгп при наличии прав.
сумма текущего остатка на СГП (цена из таблицы сандартных изделий, у которх стоят галки учета)
потребность. выводится с помощью вью, а не расчетом в программе. признаком нехватки изделия является отрицательня потребность.

в программе таблица выдается всегда в разрезе конкретного форматы сметы (выбирается из списка)

по всем данным производится отсечка, в отчет попадают данные только начиная (включитально) с даты, находящейся в таблице sgp_params

Предполагается, но никак не проверяется, что все отгрузочные поспарта по изделиям, отмеченным к учету, сначала запускаются в производство с литерой П,
и уже эти изделия ложатся на СГП, а с СГП отгружаются по отгрузочным паспортам.
Также предполагается, что в группе стандартных изделий есть одна запись для Производства и одна для Продажи (иначе схема ломается!)

для расчета берутся изделия, отмеченные в стандартных галкой Учет по СГП в отгрузочныз паспортах.
Данные по приходу и расходу вытаскиваются из паспортов того же формата изделия, при этом изедия в паспорте сопоставляются по наименованию,
приход считается по паспортам с организацией -1 (Производство) а расхода сооотвественно с другими организациями.

исключен явнои из расчета формат сметы КБ РЦ путем невыбора записей по этому формату смет в v_order_items_all !!!

Галка С СГП в паспорте не учитывается (такие позиции не приходуются в журнале прихода СГП, и не должны быть в паспорте П
----- может надо учитывать в приход на СГП непроизводственные паспорта со снятой галкой с СГП???

Сопоставление позиций ведется по Наименованию (из or_std_items),  на которое ссылается строка в order_items, с учетом айди группы стд изделий (WB, Магнит...),
с учетом типа паспотра (производство/отгрузка), без учета префикса изделия, без учета признака Стд/Нстд.

Не проверено, что будет если паспорт был с нестандартным изделием и попробовать его стандртизовать 
(не знаю вообще а вообще это возможно? стандартное изделие с наименованием, существующем у нестанартного, создять няп нельзя)

*/


alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;



/*
wb otgr 10
wb prod 9
*/

--акты оприходования по СГП (по инвентаризации)
create table sgp_act_in(
  id number(11),                       --айди документа, он же номер
  id_format number(11),                --айди формата смет
  id_user number(11),
  dt date,                             --дата
  comm varchar2(400),                  --комментарий
  constraint pk_sgp_act_in primary key (id),
  constraint fk_sgp_act_in_id_format foreign key (id_format) references or_format_estimates(id),
  constraint fk_sgp_act_in_id_user foreign key (id_user) references adm_users(id)
);

create sequence sq_sgp_act_in increment by 1 nocache;

create or replace trigger trg_sgp_act_in_bi_r
  before insert on sgp_act_in for each row
begin
  select sq_sgp_act_in.nextval into :new.id from dual;
end;
/

--спецификация акта оприходования
alter table sgp_act_in_items add id_or_item number(11);
alter table sgp_act_in_items add constraint fk_sgp_act_in_items_or foreign key (id_or_item) references order_items(id) on delete cascade; 
create table sgp_act_in_items(
  id_act_in number(11),                --айди акта
  id_std_item number(11),              --айди стандартного изделия (для стандартных изделий)
  id_or_item number(11),               --айди изделия в заказе (для нестандартных изделий)
  qnt number(15,3),                    --количество, добавленное на склад по акту, всегда положительно
  constraint fk_sgp_act_in_items_act foreign key (id_act_in) references sgp_act_in(id) on delete cascade,
  constraint fk_sgp_act_in_items_std foreign key (id_std_item) references or_std_items(id),
  constraint fk_sgp_act_in_items_or foreign key (id_or_item) references order_items(id) on delete cascade
);

drop index idx_sgp_act_in_items;
--create unique index idx_sgp_act_in_items on sgp_act_in_items(id_std_item, id_act_in);



--------------------------------------------------------------------------------
--акты списания с СГП (по инвентаризации)
create table sgp_act_out(
  id number(11),                       --айди документа, он же номер
  id_format number(11),                --айди формата смет
  id_user number(11),
  dt date,                             --дата
  comm varchar2(400),                  --комментарий
  constraint pk_sgp_act_out primary key (id),
  constraint fk_sgp_act_out_id_format foreign key (id_format) references or_format_estimates(id),
  constraint fk_sgp_act_out_id_user foreign key (id_user) references adm_users(id)
);

create sequence sq_sgp_act_out increment by 1 nocache;

create or replace trigger trg_sgp_act_out_bi_r
  before insert on sgp_act_out for each row
begin
  select sq_sgp_act_out.nextval into :new.id from dual;
end;
/ 

--спецификация акта списания
alter table sgp_act_out_items add id_or_item number(11);
alter table sgp_act_out_items add constraint fk_sgp_act_out_items_or foreign key (id_or_item) references order_items(id) on delete cascade; 
create table sgp_act_out_items(
  id_act_out number(11),                --айди акта
  id_std_item number(11),              --айди стандартного изделия
  id_or_item number(11),               --айди изделия в заказе (для нестандартных изделий)
  qnt number(15,3),                    --количество, добавленное на склад по акту, всегда положительно
  constraint fk_sgp_act_out_items_act foreign key (id_act_out) references sgp_act_out(id) on delete cascade,
  constraint fk_sgp_act_out_items_std foreign key (id_std_item) references or_std_items(id),
  constraint fk_sgp_act_out_items_or foreign key (id_or_item) references order_items(id) on delete cascade
);

drop index idx_sgp_act_out_items;
--create unique index idx_sgp_act_out_items on sgp_act_out_items(id_std_item, id_act_out);

create or replace view v_sgp_revisions as
--список актов оприходования и списания по СГП
select
  a.id,
  doctype, 
  id_format,
  dt, 
  f.name as formatname, 
  u.name as username
from
  (
  (select 'акт оприходования' as doctype, id_format, id, id_user, dt from sgp_act_in)
  union
  (select 'акт списания' as doctype, id_format, id, id_user, dt from sgp_act_out)
  ) a,
  v_sgp_sell_formats f, 
  adm_users u
where
  a.id_format = f.id (+)
  and a.id_user = u.id
;


--------------------------------------------------------------------------------
--дополнительные параметры для всей таблицы состояния СГП
--(единственная строка)
create table sgp_params(
  dt_beg date                      --дата отсечки для всех составляющих таблицы
);

--установим дату отсечки
update sgp_params set dt_beg = to_date('01.08.2024', 'DD.MM.YYYY');

--дополнительные параметры для позиций в таблице состояния СГП
create table sgp_items_add(
  id number(11),                       --айди стандартного изделия
  qnt_min number,                      --минимальное количество на складе, для контроля
  constraint pk_sgp_items_add primary key (id),
  constraint fk_sgp_items_add foreign key (id) references or_std_items(id)
);

create or replace procedure P_SetSgpItemAdd(
--устанавливаем значения в таблицах при вводе данных в учете
--режим:
--1 - минимальный остаток
  IdNomencl in number,
  PMode in number,
  PValue in number 
) is
  c number;
begin
  select count(1) into c from sgp_items_add where id = IdNomencl;
  if c = 0 then
    insert into sgp_items_add (id) values (IdNomencl);
  end if;
  if PMode = 1 then 
    update sgp_items_add set qnt_min = PValue where id = IdNomencl;
  end if;  
end;
/  

--------------------------------------------------------------------------------

create or replace view v_order_items_all as
--вспомогательное представление, информация по изделиию заказа, включая шаблоны
select
  i.id,                --айди изделия
  i.id_std_item,       --айди стандартного изделия 
  o.id_format,         --айди формата
  o.id_organization,   --айди организации, -1 == производство
  o.dt_beg,            --дата оформления заказа
  o.dt_end,            --фактическая дата закрытия заказа в Учете
  o.dt_otgr,           --плановая дата отгрузки
  s.name as itemname,  --наименование слэша (без префикса)
  i.id_order,          --айди азказа
  i.qnt,               --количестов по слеешу в заказе  
  o.ornum || '_' || substr('000000' || i.pos, -3) as slash,   --№ слэша
  p.dt_beg as dt_base_beg                                     --дата отсечки из настроек отчета по сгп
from
  order_items i,
  orders o,
  or_std_items s,
  sgp_params p
where
  o.id = i.id_order
  and nvl(i.nstd, 0) <> 1
  and s.id = i.id_std_item
  and nvl(o.id_or_format_estimates, -1) <> 11  --исключаем заказы по КБ РЦ
;  


create or replace view v_order_items__ as
--вспомогательное представление, информация по изделиию заказа, кроме шаблонов
select
  *
from
  v_order_items_all
  where id_order > 0
;      
/*

select
  i.id,                --айди изделия
  i.id_std_item,       --айди стандартного изделия 
  o.id_format,         --айди формата
  o.id_organization,   --айди организации, -1 == производство
  o.dt_beg,            --дата оформления заказа
  o.dt_end,            --фактическая дата закрытия заказа в Учете
  o.dt_otgr,           --плановая дата отгрузки
  s.name as itemname,  --наименование слэша (без префикса)
  i.id_order,          --айди азказа
  i.qnt,               --количестов по слеешу в заказе  
  o.ornum || '_' || substr('000000' || i.pos, -3) as slash,   --№ слэша
  p.dt_beg as dt_base_beg                                     --дата отсечки из настроек отчета по сгп
from
  order_items i,
  orders o,
  or_std_items s,
  sgp_params p
where
  o.id = i.id_order
  and s.id = i.id_std_item
 -- and o.id > 0
;  
    
*/


/*
create or replace view v_sgp_sell_formats as
--список форматов стандартных изделий, для по которому формируем состояние СГП
select
  fe.id,
  orf.name || ' (' ||  fe.name || ')' as name 
from
  --or_std_items si,
  or_format_estimates fe,
  or_formats orf
where
  not lower(fe.name) like '%производство%'
  and orf.id > 1
  and orf.id = fe.id_format
;
*/

create or replace view v_sgp_sell_formats as
--список форматов стандартных изделий, для по которому формируем состояние СГП
--попадают форматы, по которым есть хотя бы одна галка "Учет по СГП" в изделиях
--производственные не долждны попадать, по ним учет поломается, но это не провряется тк нет признака
select
  fe.id,
  orf.name || ' (' ||  fe.name || ')' as name 
from
  or_format_estimates fe,
  or_formats orf,
  (select id_or_format_estimates, max(by_sgp) as by_sgp from or_std_items group by id_or_format_estimates) si
where
--  not lower(fe.name) like '%производство%'
  si.by_sgp = 1 and si.id_or_format_estimates = fe.id
  and orf.id > 1
  and orf.id = fe.id_format
;


select * from v_sgp_sell_formats;

create or replace view v_sgp_sell_items as
--список изделий по паспорту отгрузки по данному формату, для по которому формируем состояние СГП
select
  si.id,  --айди именно отгрузочного изделия, изделие с таким же названием и другим айди в or_std_items будет еще (для П)
  max(si.name) as name,
  max(fe.id_format) as id_format,  --стандартный формат паспорта (WB, МАГНИТ...)
  si.id_or_format_estimates as id_format_est,  --стандартный формат сметы для паспорта по отгрузке
  max(orf.name) as orf_name, 
  max(fe.name) as orfe_name, 
  substr(max(oi.slash), 2, 3) as slash,   --цифровая часть (3 символа) слеша
  max(si.price) as price                  --цена по данным спрвочника изделий (отгрузочных) 
from
  or_std_items si
  inner join or_format_estimates fe
  on fe.id = si.id_or_format_estimates
  inner join or_formats orf
  on orf.id = fe.id_format
  left outer join
  (select min(id) as id_order, id_or_format_estimates as id_format_est from orders where id < 0 group by id_or_format_estimates) o
  on o.id_format_est = fe.id
  left outer join
  v_order_items_all oi --!!!
  on oi.id_order = o.id_order and oi.itemname = si.name
where
  si.by_sgp = 1
group by 
  si.id_or_format_estimates, si.id    
;


--------------------------------------------------------------------------------
create or replace view v_sgp_by_psp_sell as
--общее количество изделия по отгрузочным паспортам, когда-либо запущенным
select
  ssi.id,    
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(qnt) as qnt
    from 
      v_order_items__ oi
    where
      id_organization <> -1  --не производство
      and oi.dt_beg >= oi.dt_base_beg
    group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;


create or replace view v_sgp_by_psp_sell_list as
--детализация по изделию по отгрузочным паспортам, когда-либо запущенным
select
  ssi.id,    
  ssi.name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  inner join
  (select id_format, itemname, qnt, slash, id_order, dt_beg, dt_otgr, dt_end
    from 
      v_order_items__ oi
    where
      id_organization <> -1  --не производство
      and qnt > 0
      and dt_beg >= dt_base_beg
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;



create or replace view v_sgp_by_psp_prod as
--общее количество изделия по производственным паспортам, когда-либо запущенным
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(qnt) as qnt
    from 
      v_order_items__
    where
      id_organization = -1  --производство
      and dt_beg >= dt_base_beg
    group by id_format, itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_by_psp_prod_list as
--детализация по изделию по производственным паспортам, когда-либо запущенным
select
  ssi.id,    
  ssi.name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  inner join
  (select id_format, itemname, qnt, slash, id_order, dt_beg, dt_otgr, dt_end
    from 
      v_order_items__
    where
      id_organization = -1  --производство
      and qnt > 0          --непустое кол-во по слешу
      and dt_beg >= dt_base_beg
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

select * from v_sgp_by_psp_prod_list where id = 275;;
 
 
create or replace view v_sgp_shipped as
--общее количество изделия по отгрузочным паспортам, отгруженное по данным журнала отгрузки с СГП
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(ois.qnt) as qnt
    from 
      v_order_items__ oi,
      --общее количество отгруженных по данному слешу
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s, sgp_params p
        where s.id_stage = 3 and s.dt > p.dt_beg 
        group by id_order_item
      ) ois   
    where
      oi.id_organization <> -1  --не производство
      and ois.id_order_item (+) = oi.id
    group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_shipped_list as
--детализация по отгрузке с СГП
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  oi.dt, --дата отгрузки по этому слешу
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  inner join
  (select id_format, itemname, ois.dt, ois.qnt, oi.slash, oi.id_order, oi.dt_beg, oi.dt_otgr, oi.dt_end
    from 
      v_order_items__ oi,
      --общее количество отгруженных по данному слешу
      (select id_order_item, qnt ,dt 
        from order_item_stages s, sgp_params p
        where s.id_stage = 3 and s.dt > p.dt_beg 
      ) ois   
    where
      oi.id_organization <> -1  --не производство
      and ois.id_order_item = oi.id
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;



create or replace view v_sgp_registered as
--общее количество изделия по производственным паспортам, оприходованных на СГП по данным журнала приемки с СГП
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(ois.qnt) as qnt
    from 
      v_order_items__ oi,
      --общее количество принятых на сгп по данному слешу  
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s, sgp_params p
        where s.id_stage = 2 and s.dt > p.dt_beg 
        group by id_order_item
      ) ois   
    where
      oi.id_organization = -1  --производство
      and ois.id_order_item (+) = oi.id
    group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_registered_list as
--детализация по приемке на СГП
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  oi.dt, --дата приемки по этому слешу
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, ois.dt, ois.qnt, oi.slash, oi.id_order, oi.dt_beg, oi.dt_otgr, oi.dt_end
    from 
      v_order_items__ oi,
      --общее количество принятых по данному слешу
      (select id_order_item, qnt ,dt 
        from order_item_stages s, sgp_params p
        where s.id_stage = 2 and s.dt > p.dt_beg 
      ) ois   
    where
      oi.id_organization = -1  --производство
      and oi.qnt <> 0
      and ois.id_order_item = oi.id
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

select * from v_sgp_registered_list where id = 275;
select * from v_sgp_registered_list where id = 275;

select * from v_order_item_stages1 where slash = 'П240491_004';



create or replace view v_sgp_shipped_plan as
--плановая отгрузка
--(сумма сгруппированнаая по изделию количества по изделиям заказов за минусом количества уже отгруженных по данному изделию)
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt 
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(nvl(oi.qnt, 0) - nvl(ois.qnt, 0)) as qnt
    from 
      v_order_items__ oi,
      --общее количество отгруженных по данному слешу
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s--, sgp_params p
        where s.id_stage = 3 --and s.dt > p.dt_beg
        group by id_order_item 
      ) ois   
    where
      oi.id_organization <> -1  --не производство
      and oi.dt_end is null                    --отсечка завершенных заказов
      --and oi.dt_beg > oi.dt_base_beg               --отсечка по дате
      and ois.id_order_item (+) = oi.id
      and oi.qnt <> 0
      and oi.qnt <> nvl(ois.qnt, 0)
      group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;


create or replace view v_sgp_shipped_plan_list as
--детализация по плановой отгрузке
--(количества по изделиям отгрузочных заказов за минусом количества уже отгруженных по данному изделию)
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  oi.qnt  
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, oi.qnt - nvl(ois.qnt, 0) as qnt, oi.slash, oi.id_order, oi.dt_beg, oi.dt_otgr, oi.dt_end
    from 
      v_order_items__ oi,
      --общее количество отгруженных по данному слешу
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s --, sgp_params p
        where s.id_stage = 3 --and s.dt > p.dt_beg
        group by id_order_item 
      ) ois   
    where
      oi.id_organization <> -1  --не производство
      and oi.dt_end is null                    --отсечка завершенных заказов
      --and o.dt_beg > p.dt_beg               --отсечка по дате
      and ois.id_order_item (+) = oi.id
      and oi.qnt <> 0
      and oi.qnt <> nvl(ois.qnt, 0)
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;


create or replace view v_sgp_in_prod as
--количество, находящееся в производстве
--(количества по изделиям производственных заказов за минусом количества уже принятых на СГП по данному изделию)
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  nvl(oi.qnt, 0) as qnt
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, sum(oi.qnt - nvl(ois.qnt, 0)) as qnt
    from 
      v_order_items__ oi,
      --общее количество произведенных (принятых на СГП) по данному слешу
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s--, sgp_params p
        where s.id_stage = 2 --and s.dt > p.dt_beg
        group by id_order_item 
      ) ois   
    where
      oi.id_organization = -1  --производство
      --and o.dt_beg > p.dt_beg               --отсечка по дате
      and oi.dt_end is null                    --отсечка завершенных заказов
      and ois.id_order_item (+) = oi.id
      and oi.qnt <> 0
      and oi.qnt <> nvl(ois.qnt, 0)
      group by oi.id_format, oi.itemname
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_in_prod_list as
--детализация по плановой отгрузке
--(количества по изделиям производственных заказов за минусом количества уже принятых на СГП по данному изделию)
select
  ssi.id,
  ssi.name,
  ssi.orf_name,
  ssi.orfe_name,
  oi.slash,
  oi.id_order,
  oi.dt_beg,
  oi.dt_otgr,
  oi.dt_end,
  oi.qnt,
  oi.qnt_in_order  
from
  v_sgp_sell_items ssi
  left outer join
  (select id_format, itemname, oi.qnt - nvl(ois.qnt, 0) as qnt, oi.qnt as qnt_in_order, oi.slash, oi.id_order, oi.dt_beg, oi.dt_otgr, oi.dt_end
    from 
      v_order_items__ oi,
      --общее количество произведенных (принятых на СГП) по данному слешу
      (select id_order_item, sum(qnt) as qnt 
        from order_item_stages s --, sgp_params p
        where s.id_stage = 2 --and s.dt > p.dt_beg
        group by id_order_item 
      ) ois   
    where
      oi.id_organization = -1  --производство
      --and o.dt_beg > p.dt_beg               --отсечка по дате
      and oi.dt_end is null                    --отсечка завершенных заказов
      and ois.id_order_item (+) = oi.id
      and oi.qnt <> 0
      and oi.qnt <> nvl(ois.qnt, 0)
  ) oi
  on oi.id_format = ssi.id_format and oi.itemname = ssi.name   
;

create or replace view v_sgp_move_list as
--детализация движения по номенклатуре
(select
  'производственный паспорт' as doctype, id, name, id_order, slash, dt_beg, dt_otgr, dt_end, dt, qnt as qnt
from
  v_sgp_registered_list
)
union
(
select
  'отгрузочный паспорт' as doctype, id, name, id_order, slash, dt_beg, dt_otgr, dt_end, dt, -qnt as qnt
from
  v_sgp_shipped_list
)  
union
(
select
  'акт оприходования' as doctype, aoi.id_std_item as id, name, ao.id as id_order, to_char(ao.id) as slash, trunc(ao.dt) as dt_beg, null as dt_otgr, trunc(ao.dt) as dt_end, trunc(ao.dt) as dt, aoi.qnt as qnt
from
  sgp_act_in ao, sgp_act_in_items aoi, v_sgp_sell_items si
where
  aoi.id_act_in = ao.id and aoi.id_std_item = si.id 
)  
union
(
select
  'акт списания' as doctype, aoi.id_std_item as id, name, ao.id as id_order, to_char(ao.id) as slash, trunc(ao.dt) as dt_beg, null as dt_otgr, trunc(ao.dt) as dt_end, trunc(ao.dt) as dt, aoi.qnt as qnt
from
  sgp_act_out ao, sgp_act_out_items aoi, v_sgp_sell_items si
where
  aoi.id_act_out = ao.id and aoi.id_std_item = si.id   
)  
--нестандарт
union
(
select
  'акт оприходования' as doctype, aoi.id_or_item as id, name, ao.id as id_order, to_char(ao.id) as slash, trunc(ao.dt) as dt_beg, null as dt_otgr, trunc(ao.dt) as dt_end, trunc(ao.dt) as dt, aoi.qnt as qnt
from
  sgp_act_in ao, sgp_act_in_items aoi, v_sgp2_order_items si
where
  aoi.id_act_in = ao.id and aoi.id_or_item = si.id 
)
union
(
select
  'акт списания' as doctype, aoi.id_or_item as id, name, ao.id as id_order, to_char(ao.id) as slash, trunc(ao.dt) as dt_beg, null as dt_otgr, trunc(ao.dt) as dt_end, trunc(ao.dt) as dt, aoi.qnt as qnt
from
  sgp_act_out ao, sgp_act_out_items aoi, v_sgp2_order_items si
where
  aoi.id_act_out = ao.id and aoi.id_or_item = si.id   
)  
union
(
select
  'приёмка' as doctype, si.id as id, name, si.id_order, slash, trunc(si.dt_beg) as dt_beg, null as dt_otgr, trunc(si.dt_end) as dt_end, trunc(ois.dt) as dt, ois.qnt as qnt
from
  v_sgp2_order_items si, order_item_stages ois  
where
  si.id = ois.id_order_item
  and ois.id_stage = 2
)  
union
(
select
  'отгрузка' as doctype, si.id as id, name, si.id_order, slash, trunc(si.dt_beg) as dt_beg, null as dt_otgr, trunc(si.dt_end) as dt_end, trunc(ois.dt) as dt, -ois.qnt as qnt
from
  v_sgp2_order_items si, order_item_stages ois  
where
  si.id = ois.id_order_item
  and ois.id_stage = 3
)  
;

select
  'отгрузка' as doctype, si.id as id, name, si.id_order, slash, trunc(si.dt_beg) as dt_beg, null as dt_otgr, trunc(si.dt_end) as dt_end, trunc(ois.dt) as dt, -ois.qnt as qnt
from
  v_sgp2_order_items si, order_item_stages ois  
where
  si.id = ois.id_order_item
  and ois.id_stage = 3
  and si.id = 92163
;  

select * from v_sgp_move_list where doctype = 'акт оприходования' and id_order = 34;



create or replace view v_sgp_items as
select
--итоговое представление для состояния СГП про стандартному формату изделий    
  ssi.id,
  ssi.id_format,
  ssi.id_format_est,
  ssi.orf_name,
  ssi.orfe_name,
  ssi.slash,
  ssi.name,
  ssi.price,
  
  ps.qnt as qnt_psp_sell,              --заказано за все время
  pp.qnt as qnt_psp_prod,              --запущено за все время по производственным паспортам  
  sr.qnt as qnt_sgp_registered,        --оприходовано за все время на склад сгп по производственным паспортам
  ss.qnt as qnt_shipped,               --отгружено с сгп за все время (не по П, но по П отгрузить и невозможно)
  
  sip.qnt as qnt_in_prod,              --количество в производстве
  (sr.qnt + nvl(ai.qnt, 0) - ss.qnt + nvl(ao.qnt, 0)) as qnt,  --текущее количество позиции на СГП
  ssp.qnt as qnt_to_shipped,           --количество к отгрузке
  ia.qnt_min,                          --минимальный остаток (вводится в таблице)     
  --потребность (остаток + в производстве - к отгрузке)
  ((sr.qnt + nvl(ai.qnt, 0) - nvl(ss.qnt, 0) + nvl(ao.qnt, 0))) + (nvl(sip.qnt, 0)) - (nvl(ssp.qnt, 0)) as qnt_need,
  --сумма по данным справочника стд изделий, на текущее количество на СГП  
  round((sr.qnt + nvl(ai.qnt, 0) - ss.qnt + nvl(ao.qnt, 0)) * nvl(ssi.price, 0), 2) as summ,
  --сумма сырья на изделие из бд ИТМ по смете соответствующего изделия из производственного паспорта
  prc.sum as priceraw,
  (sr.qnt + nvl(ai.qnt, 0) - ss.qnt + nvl(ao.qnt, 0)) * prc.sum as sumraw
from
  v_sgp_sell_items ssi,   --список изделий, по которому инфа
  v_sgp_by_psp_sell ps,   --запущено по отгрузочным паспортам
  v_sgp_by_psp_prod pp,   --запущено по производственным паспотам 
  v_sgp_registered sr,    --принято на сгп по производственным паспортам 
  v_sgp_shipped ss,       --отгружено с сгп по отгрузочным паспортам 
  v_sgp_shipped_plan ssp, --запланированные отгрузки 
  v_sgp_in_prod sip,      --изделия в производстве
  (select id_std_item, sum(qnt) as qnt from sgp_act_in_items group by id_std_item) ai,     --акты оприходования    
  (select id_std_item, sum(qnt) as qnt from sgp_act_out_items group by id_std_item) ao,    --акты списания
  sgp_items_add ia,
  v_sgp_item_prices prc    
where
  ssi.name = ps.name and ssi.id = ps.id
  and ssi.name = pp.name and ssi.id = pp.id

  and ssi.name = sr.name and ssi.id = sr.id
  and ssi.name = ss.name and ssi.id = ss.id
  and ssi.name = ssp.name and ssi.id = ssp.id
  and ssi.name = sip.name and ssi.id = sip.id
  and ssi.id = ai.id_std_item (+)
  and ssi.id = ao.id_std_item (+)
  and ssi.id = ia.id (+)
  and prc.id (+) = ssi.id
  
--order by ssi.name  
;


select * from v_sgp_items where id = 482;
select * from sgp_act_in_items where id_std_item = 482;

select * from v_sgp_move_list where id = 482;

/*=============================================================================*/
      
   
/*
Таблица наличия на складе готовой продукции нестандартных изделий.
Розница.
Учитываются только изделия с признаком "Нестандарт" в паспорте, по всем паспортам.
Каждая такая позщиция в паспорте считается уникальным изделием, т.е. уникальность определяется 
по номеру слегша, а не по наименованию.
Приходд и расход поределяетсЯ движением по таблице приемки/отгрузки СГП именно по этому слешу.
*/


create or replace view v_sgp2_order_items as
--вспомогательное представление, информация по изделиию заказа
select
  i.id,                --айди изделия
  i.id_std_item,       --айди стандартного изделия 
  o.id_format,         --айди формата заказа
  s.id_or_format_estimates,  --формат сметы стандартнорго изделия (0 = Нестандартное изделие)
  o.id_organization,   --айди организации, -1 == производство
  o.dt_beg,            --дата оформления заказа
  o.dt_end,            --фактическая дата закрытия заказа в Учете
  o.dt_otgr,           --плановая дата отгрузки
  s.name as itemname,  --наименование слэша (без префикса)
  s.name,
  i.id_order,          --айди азказа
  i.qnt,               --количестов по слеешу в заказе
  i.price,             --цена изделия по заказу  
  o.ornum || '_' || substr('000000' || i.pos, -3) as slash,   --№ слэша
  p.dt_beg as dt_base_beg                                     --дата отсечки из настроек отчета по сгп
from
  order_items i,
  orders o,
  or_std_items s,
  sgp_params p
where
  o.id = i.id_order
  and s.id = i.id_std_item
  and nvl(i.nstd, 0) = 1
;  


create or replace view v_sgp2 as
--группировка по изделиям ПЗ
select 
  a.*,
 nvl(qnt_sgp_registered,0) - nvl(qnt_shipped,0) + nvl(qntplus,0) + nvl(qntminus,0) as qnt,
 round((nvl(qnt_sgp_registered,0) - nvl(qnt_shipped,0) + nvl(qntplus,0) + nvl(qntminus,0)) * nvl(price,0), 2) as sum  
from  
(select 
  max(id_std_item) as id_std_item,
  s.id_order_item as id, 
  max(oi.slash) as slash,
  max(oi.dt_beg) as dt_beg,
  max(oi.dt_otgr) as dt_otgr,
  max(oi.itemname) as name,
  max(oi.qnt) as qnt_psp,
  max(oi.qnt) - sum(qnt_sgp_registered) as qnt_in_prod,
  --сумма В производстве, в условных ценах сырья (продажа * 0.4)
  round((max(oi.qnt) - sum(qnt_sgp_registered)) * max(oi.price) * 0.4, 2) as sum_in_prod,  
  sum(qnt_sgp_registered) as qnt_sgp_registered,
  sum(qnt_shipped) as qnt_shipped,
--  sum(qnt_sgp_registered) - sum(qnt_shipped) as qnt0,
  max(oi.price) as price
--  round((sum(qnt_sgp_registered) - sum(qnt_shipped)) * max(oi.price), 2) as sum  
from 
  v_sgp2_order_items oi,
  (select
    s.id_order_item, 
    decode(nvl(s.id_stage, 0), 2, qnt, 0) as qnt_sgp_registered,
    decode(nvl(s.id_stage, 0), 3, qnt, 0) as qnt_shipped
  from 
    order_item_stages s, 
    sgp_params p
  where 
    s.id_stage in (2, 3) 
  ) s
where
  s.id_order_item = oi.id (+)
  and oi.dt_beg > oi.dt_base_beg
  and oi.id_or_format_estimates = 0
group by s.id_order_item
) a,
(select id_or_item, sum(qnt) as qntplus from sgp_act_in_items group by id_or_item) ai,     --акты оприходования    
(select id_or_item, sum(qnt) as qntminus from sgp_act_out_items group by id_or_item) ao    --акты списания
where
  a.id = ai.id_or_item (+)
  and a.id = ao.id_or_item (+)
;

  
  
  
  
  
create or replace view v_sgp_item_prices as 
select
--считает закупочные суммы изделий из отгрузочных паспортов, находя соответствующие им папорта производственные,
--позиции, являющиеся изделиями, не разворачивает,
--цены находит в stock в последней по дате проводке по ПН для данной номенклатуры
  ssi.id,
  --max(ssi.name),
  --i.name,
  --ssi.orf_name,
  --ssi.orfe_name,
  --b.name,
  --n.name,
  --round(s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity), 2) as price,
  round(sum(ei.qnt1_itm * s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity))) as sum
from
  v_sgp_sell_items ssi,
  or_format_estimates a,
  or_std_items i,
  estimates e,
  estimate_items ei,
  bcad_nomencl b,
  dv.nomenclatura n,
  (select row_number() over (partition by doctype, id_nomencl order by stockdate desc) as rn, id_nomencl, quantity, summa, stockdate from dv.stock where doctype = 1) s 
where
  a.id = ssi.id_format 
  and ssi.id_format_est <> a.id 
  and i.name = ssi.name
  and e.id_std_item = i.id
  and ei.id_estimate = e.id
  and b.id = ei.id_name
  and n.name = b.name
  and s.id_nomencl = n.id_nomencl and s.rn = 1
group by 
  ssi.id  
;  

select * from dv.stock;
  
        dv.stock s
      on s.doctype = 1 and s.id_spec = ibs.id_ibspec
round(s.summa / decode(nvl(s.quantity, 1), 0 ,1, s.quantity), 2) as price_main
  
  (select id_format, itemname, sum(qnt) as qnt
    from 
      v_order_items__
    where
      id_organization = -1  --производство
      and dt_beg >= dt_base_beg
    group by id_format, itemname
  ) oi
  on oi.id_format = ssi. and oi.itemname = ssi.name   
;
  
  
  
  
  
  
  
  
  
  