Alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;

--------------------------------------------------------------------------------
--вью для сервера сканирования штрихкодов продукции (uScanApi.pas, scan.html).
--
--штрихкод - это ПРЕФИКС ТИПА (2 буквы, жёстко задан для типа сущности) + её id,
--отдельного поля-штрихкода в базе не заводим, где это возможно - код разбирается
--на сервере (uScanApi.pas), значение id используется для поиска напрямую:
--  SI<id> - стандартное изделие (or_std_items.id)
--  OI<id> - изделие заказа (order_items.id)
--  EM<id> - работник (w_employees.id), это же бейджик для входа в систему
--
--вход в сканер обязателен - сканирование EM-бейджика включает/выключает
--"смену" на этом телефоне (см. TScanApi.HandleScan/сессии в uScanApi.pas);
--права на действия (приёмка/отгрузка) - ПОКА заглушка (константа 1 = разрешено
--всем), настоящая система прав по работникам будет сделана позже отдельной
--задачей - см. v_scan_api_employee ниже.
--------------------------------------------------------------------------------


create or replace view v_scan_api_order_item as --$+
  --данные об одной позиции заказа (order_items.id) для карточки на телефоне;
  --qnt_shipped считаем отдельной агрегацией по order_item_stages (id_stage = 3),
  --т.к. готового поля с отгруженным количеством на order_items нет (только qnt_to_sgp)
  select
    i.id,
    i.id_order,
    i.ornum,
    i.customer,
    i.project,
    i.fullitemname,
    i.qnt,
    i.qnt_to_sgp,
    nvl(sh.qnt_shipped, 0) as qnt_shipped
  from
    v_order_items i,
    (select id_order_item, sum(qnt) as qnt_shipped from order_item_stages where id_stage = 3 group by id_order_item) sh
  where
    sh.id_order_item(+) = i.id
;


create or replace view v_scan_api_std_item as --$+
  --данные об одном стандартном изделии (or_std_items.id) для карточки на телефоне
  select
    i.id,
    i.name,
    i.fullname,
    i.type_name,
    i.or_format_name,
    i.price_with_nds,
    i.active
  from
    v_or_std_items i
;


create or replace view v_scan_api_employee as --$+
  --данные о работнике (w_employees.id) для входа в мобильный сканер по бейджику -
  --ФИО/должность из уже существующей v_w_employees; права на действия пока не
  --разделены по работникам - константа 1 (разрешено), настоящие права будут
  --сделаны позже отдельной задачей - тогда здесь появится реальное условие
  select
    e.id,
    e.name,
    e.job,
    e.is_working_now,
    1 as scan_can_accept,
    1 as scan_can_ship
  from
    v_w_employees e
;
