Alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;

--------------------------------------------------------------------------------
--проверочные вью для поиска проблем в наименованиях изделий/полуфабрикатов/нестандартных изделий и в сметах.
--набор скриптов черновой, состав проверок и выводимых полей будем уточнять по ходу работы.
--
--предполагается, что каждая вью станет источником данных для отдельной вкладки будущей формы (заголовок вкладки -
--"проблема n", под ним текст описания проблемы, под ним грид по этой вью; из грида должен быть вызов редактора
--стандартного изделия (uFrmODedtOrStdItem) и редактора сметы (uFrmOGedtEstimate) по строке).
--
--проблема 1 - совпадающие (без учета регистра) наименования полуфабрикатов из разных подгрупп полуфабрикатов.
--проблема 2 - совпадение наименования полуфабриката с наименованием нестандартного изделия (у обоих нет префикса).
--проблема 3 - совпадение полного (с префиксом) наименования любого изделия с "голым" наименованием полуфабриката
--  или нестандартного изделия.
--проблема 4 - отгрузочное изделие (по полному наименованию) встречается как компонент в какой-либо смете.
--проблема 5 - в собственной смете отгрузочного изделия ссылка на производственное изделие не из того же формата,
--  либо не совпадающая по наименованию с фактическим производственным изделием.
--проблема 6 - нестандартное изделие встречается как компонент в какой-либо смете.
--проблема 7 - совпадающие без учета регистра наименования в bcad_nomencl (справочник сметных позиций).
--проблема 8 - совпадающие без учета регистра наименования в итм (dv.nomenclatura).
--проблема 9 - лишние пробелы (в начале/в конце/двойные) в наименованиях bcad_nomencl.
--проблема 10 - лишние пробелы (в начале/в конце/двойные) в наименованиях итм (dv.nomenclatura).
--проблема 11 - номенклатура bcad_nomencl, отсутствующая в итм (dv.nomenclatura), при том что для этого уже есть
--  основания (смета стандартного изделия либо смета проведенного заказа) - то есть должна была попасть в итм, но
--  не попала. номенклатура, которая используется только в смете еще НЕ проведенного заказа, за проблему не
--  считается - для нее расхождение с итм ожидаемо (см. подробный комментарий у вью).
--------------------------------------------------------------------------------


create or replace view v_orders_check1_semiprod_name_dups as --!+
  select
  --проблема 1: одинаковые (без учета регистра) наименования у полуфабрикатов (or_format_estimates.type = 2),
  --относящихся к РАЗНЫМ подгруппам полуфабрикатов (id_or_format_estimates). в пределах одной подгруппы дубли
  --исключены уникальным индексом idx_or_std_items_name, поэтому пересечение возможно только между подгруппами -
  --само по себе это не ошибка (в разных форматах могут быть похожие детали), но требует ручной проверки.
    i.id,
    i.name,
    i.active,
    fe.id as id_or_format_estimate,
    fe.name as format_estimate_name,
    fe.prefix,
    fe.prefix || '_' || i.name as fullname,
    f.id as id_format,
    f.name as format_name,
    --oracle не разрешает count(distinct ...) в аналитической (over) форме (ORA-30482), поэтому считаем count(*) -
    --дубль (subgroup, lower(name)) внутри одной подгруппы и так исключен уникальным индексом idx_or_std_items_name,
    --так что count(*) по факту равносилен количеству разных подгрупп с этим именем (кроме редкого случая различий
    --только в пробелах по краям, которые индекс не учитывает, а trim() здесь - да)
    count(*) over (partition by lower(trim(i.name))) as dup_subgroup_cnt
  from
    or_std_items i
    join or_format_estimates fe on fe.id = i.id_or_format_estimates
    join or_formats f on f.id = fe.id_format
  where
    fe.type = 2 --только полуфабрикаты (STDITEM_TYPE_SEMIPRODUCT)
    and i.active = 1
;

create or replace view v_orders_check1 as --!+
  select * from v_orders_check1_semiprod_name_dups where dup_subgroup_cnt > 1
;


create or replace view v_orders_check2 as --!+
  select
  --проблема 2: совпадение (без учета регистра) наименования полуфабриката (у него нет префикса - это единственное
  --его имя) с наименованием нестандартного изделия (id_or_format_estimates = 0 - у таких изделий тоже нет
  --префикса, см. GetPrefixedName в uFrmODedtOrStdItem.pas). такое совпадение создает риск путаницы там, где позиции
  --ищутся по имени (bcad_nomencl/сметы) - см. также проблема 3/4/6.
    sp.id as id_semiproduct,
    sp.name as semiproduct_name,
    sp.active as semiproduct_active,
    fe.id as id_or_format_estimate,
    fe.name as format_estimate_name,
    fe.prefix,
    f.id as id_format,
    f.name as format_name,
    ns.id as id_nonstandard,
    ns.name as nonstandard_name,
    ns.active as nonstandard_active
  from
    or_std_items sp
    join or_format_estimates fe on fe.id = sp.id_or_format_estimates and fe.type = 2
    join or_formats f on f.id = fe.id_format
    join or_std_items ns on ns.id_or_format_estimates = 0
      and lower(trim(ns.name)) = lower(trim(sp.name))
  where
    sp.active = 1
    and ns.active = 1
;


create or replace view v_orders_check3 as --!+
  with unprefixed as (
    select
      i.id,
      i.name,
      i.active,
      case when fe.type = 2 then 'полуфабрикат' else 'нестандартное изделие' end as kind
    from
      or_std_items i
      join or_format_estimates fe on fe.id = i.id_or_format_estimates
    where
      fe.type = 2
      or fe.id = 0
  )
  select
  --проблема 3: полное (с учетом префикса подгруппы, см. GetPrefixedName) наименование ЛЮБОГО изделия совпадает
  --(без учета регистра) с "голым" (без префикса) наименованием полуфабриката или нестандартного изделия. опасно
  --тем, что и bcad_nomencl (справочник сметных позиций), и итм (dv.nomenclatura) идентифицируют записи по полному
  --наименованию - совпадение создает риск подмены при использовании полуфабриката/нестандартного изделия как
  --компонента сметы.
    src.id as id_item,
    src.name as item_name,
    src.active as item_active,
    src_fe.prefix,
    src_fe.prefix || '_' || src.name as item_fullname,
    src_fe.id as id_or_format_estimate,
    src_f.id as id_format,
    src_f.name as format_name,
    u.id as id_target,
    u.name as target_name,
    u.kind as target_kind,
    u.active as target_active
  from
    or_std_items src
    join or_format_estimates src_fe on src_fe.id = src.id_or_format_estimates and src_fe.id <> 0
    join or_formats src_f on src_f.id = src_fe.id_format
    join unprefixed u on lower(trim(src_fe.prefix || '_' || src.name)) = lower(trim(u.name))
      and u.id <> src.id
  where
    src.active = 1
    and u.active = 1
;


create or replace view v_orders_check4 as --!+
  select
  --проблема 4: отгрузочное изделие (по полному наименованию, с префиксом) встречается как компонент в какой-либо
  --смете (estimate_items, через bcad_nomencl.name) - отгрузочные изделия сами не производятся и не должны
  --использоваться как составная часть чужой сметы (сравнение с точностью до регистра - bcad_nomencl намеренно не
  --имеет регистронезависимой уникальности, см. комментарий в d_estimates.sql).
    ei.id as id_estimate_item,
    ei.id_estimate,
    es.id_std_item as estimate_owner_std_item_id,
    owner.name as estimate_owner_name,
    --owner (сама смета) может относиться не к стандартному изделию, а к позиции заказа (id_order_item) - тогда
    --owner/owner_fe пустые (left join); case вместо простой конкатенации - иначе '_' || null дало бы '_', а не null
    case when owner.id is not null then owner_fe.prefix || '_' || owner.name end as estimate_owner_fullname,
    es.id_order_item as estimate_owner_order_item_id,
    ei.qnt1,
    bn.id as id_name_bcad,
    bn.name as referenced_name_bcad,
    ship.id as id_shipment_item,
    ship.name as shipment_item_name,
    ship_fe.prefix || '_' || ship.name as shipment_item_fullname,
    ship.active as shipment_item_active
  from
    estimate_items ei
    join estimates es on es.id = ei.id_estimate
    left join or_std_items owner on owner.id = es.id_std_item
    left join or_format_estimates owner_fe on owner_fe.id = owner.id_or_format_estimates
    join bcad_nomencl bn on bn.id = ei.id_name
    join or_format_estimates ship_fe on ship_fe.type = 1 --STDITEM_TYPE_SHIPMENT
    join or_std_items ship on ship.id_or_format_estimates = ship_fe.id
      and trim(ship_fe.prefix || '_' || ship.name) = trim(bn.name)
  where
    ei.deleted = 0
    and (es.id_std_item is null or es.id_std_item <> ship.id)
;


create or replace view v_orders_check5 as --!+
  select
  --проблема 5: в собственной смете отгрузочного изделия (estimates.id_std_item = id отгрузочного изделия) есть
  --позиция, ссылающаяся на производственное изделие (estimate_items.id_or_std_item -> or_std_items с type = 0),
  --которое либо (а) относится к ДРУГОМУ формату (id_format), чем само отгрузочное изделие, либо (б) наименование
  --в bcad_nomencl этой позиции не совпадает с фактическим текущим полным наименованием производственного изделия.
  --см. также CheckSelfSmetaAction в uFrmODedtOrStdItem.pas - там аналогичная проверка выполняется "на лету" для
  --одной пары при редактировании, здесь - по всей базе целиком, как есть на текущий момент.
    ship.id as id_shipment_item,
    ship.name as shipment_item_name,
    ship_fe.prefix || '_' || ship.name as shipment_item_fullname,
    ship_fe.id_format as shipment_id_format,
    ship_f.name as shipment_format_name,
    ship.active as shipment_active,
    es.id as id_estimate,
    ei.id as id_estimate_item,
    prod.id as id_production_item,
    prod.name as production_item_name,
    prod_fe.prefix || '_' || prod.name as production_item_fullname,
    prod_fe.id_format as production_id_format,
    prod_f.name as production_format_name,
    prod.active as production_active,
    bn.name as referenced_name_bcad,
    case when prod_fe.id_format <> ship_fe.id_format then 1 else 0 end as format_mismatch,
    case when trim(bn.name) <> trim(prod_fe.prefix || '_' || prod.name) then 1 else 0 end as name_mismatch
  from
    or_std_items ship
    join or_format_estimates ship_fe on ship_fe.id = ship.id_or_format_estimates and ship_fe.type = 1
    join or_formats ship_f on ship_f.id = ship_fe.id_format
    join estimates es on es.id_std_item = ship.id
    join estimate_items ei on ei.id_estimate = es.id and ei.deleted = 0 and ei.id_or_std_item is not null
    join or_std_items prod on prod.id = ei.id_or_std_item
    join or_format_estimates prod_fe on prod_fe.id = prod.id_or_format_estimates and prod_fe.type = 0
    join or_formats prod_f on prod_f.id = prod_fe.id_format
    join bcad_nomencl bn on bn.id = ei.id_name
  where
    prod_fe.id_format <> ship_fe.id_format
    or trim(bn.name) <> trim(prod_fe.prefix || '_' || prod.name)
;


create or replace view v_orders_check6 as --!+
  select
  --проблема 6: нестандартное изделие (or_std_items.id_or_format_estimates = 0, наименование без префикса)
  --встречается как компонент в какой-либо смете (estimate_items, через bcad_nomencl.name). нестандартные изделия
  --обычно создаются под конкретный разовый заказ и не предполагаются переиспользуемыми компонентами чужих смет
  --(сравнение с точностью до регистра, см. комментарий в проблеме 4 про bcad_nomencl).
    ei.id as id_estimate_item,
    ei.id_estimate,
    es.id_std_item as estimate_owner_std_item_id,
    owner.name as estimate_owner_name,
    case when owner.id is not null then owner_fe.prefix || '_' || owner.name end as estimate_owner_fullname,
    es.id_order_item as estimate_owner_order_item_id,
    ei.qnt1,
    bn.id as id_name_bcad,
    bn.name as referenced_name_bcad,
    ns.id as id_nonstandard_item,
    ns.name as nonstandard_item_name,
    ns.active as nonstandard_item_active
  from
    estimate_items ei
    join estimates es on es.id = ei.id_estimate
    left join or_std_items owner on owner.id = es.id_std_item
    left join or_format_estimates owner_fe on owner_fe.id = owner.id_or_format_estimates
    join bcad_nomencl bn on bn.id = ei.id_name
    join or_std_items ns on ns.id_or_format_estimates = 0
      and trim(ns.name) = trim(bn.name)
  where
    ei.deleted = 0
    and (es.id_std_item is null or es.id_std_item <> ns.id)
;


create or replace view v_orders_check7 as --!+
  with dups as (
    select
    --проблема 7: bcad_nomencl.name уникально только с точностью до регистра (обычный unique-констрейнт, БЕЗ
    --lower() - см. комментарий "не делаем уникальность без учета регистра" в d_estimates.sql). здесь ищем случаи,
    --когда несколько разных id имеют одинаковое (без учета регистра) наименование - формально это разные строки
    --для сравнения "в лоб" (см. проблема 4/5/6), но по смыслу дубли, которые сбивают с толку.
      bn.id,
      bn.name,
      bn.is_purchased,
      count(*) over (partition by lower(trim(bn.name))) as dup_cnt
    from
      bcad_nomencl bn
  )
  select id, name, is_purchased, dup_cnt from dups where dup_cnt > 1
;


create or replace view v_orders_check8 as --!+
  with dups as (
    select
    --проблема 8: то же самое (см. проблема 7), но для номенклатуры итм (dv.nomenclatura.name) - там тоже нет
    --регистронезависимой уникальности. id_nomencltype >= 0 - фильтр только реальных позиций номенклатуры, без
    --служебных/папок (см. аналогичный фильтр в существующей проверке дублей в D_ItmInfo.pas).
      n.id_nomencl,
      n.name,
      n.id_group,
      n.id_unit,
      n.artikul,
      count(*) over (partition by lower(trim(n.name))) as dup_cnt
    from
      dv.nomenclatura n
    where
      n.id_nomencltype >= 0
  )
  select id_nomencl, name, id_group, id_unit, artikul, dup_cnt from dups where dup_cnt > 1
;


create or replace view v_orders_check9 as --!+
  select
  --проблема 9: лишние пробелы в наименовании bcad_nomencl - пробел в начале, в конце, либо два и более подряд
  --внутри имени. такие имена визуально неотличимы от "нормальных", но являются РАЗНЫМИ строками для точного (с
  --учетом регистра и пробелов) сравнения, которое используется при работе со сметами (см. проблема 4/5/6) -
  --источник трудноуловимых "потерянных" совпадений.
    bn.id,
    bn.name,
    case when substr(bn.name, 1, 1) = ' ' then 1 else 0 end as has_leading_space,
    case when substr(bn.name, -1, 1) = ' ' then 1 else 0 end as has_trailing_space,
    case when instr(bn.name, '  ') > 0 then 1 else 0 end as has_double_space
  from
    bcad_nomencl bn
  where
    substr(bn.name, 1, 1) = ' '
    or substr(bn.name, -1, 1) = ' '
    or instr(bn.name, '  ') > 0
;


create or replace view v_orders_check10 as --!+
  select
  --проблема 10: то же самое (см. проблема 9), но для номенклатуры итм (dv.nomenclatura.name). id_nomencltype >= 0 -
  --фильтр только реальных позиций номенклатуры, без служебных/папок.
    n.id_nomencl,
    n.name,
    n.id_group,
    case when substr(n.name, 1, 1) = ' ' then 1 else 0 end as has_leading_space,
    case when substr(n.name, -1, 1) = ' ' then 1 else 0 end as has_trailing_space,
    case when instr(n.name, '  ') > 0 then 1 else 0 end as has_double_space
  from
    dv.nomenclatura n
  where
    n.id_nomencltype >= 0
    and (
      substr(n.name, 1, 1) = ' '
      or substr(n.name, -1, 1) = ' '
      or instr(n.name, '  ') > 0
    )
;


create or replace view v_orders_check11 as --!+
  with usage as (
    --для каждой позиции bcad_nomencl (по id_name в estimate_items): есть ли использование в смете, ПРИВЯЗАННОЙ
    --к стандартному изделию напрямую (estimates.id_std_item - не зависит от конкретного заказа), и/или в смете,
    --привязанной к позиции ПРОВЕДЕННОГО заказа (orders.id_status >= 1 - см. комментарий "0 - на оформлении, 1 -
    --проведен, 2 - запущен в работу" у or_orders.id_status в d_orders.sql). в обоих случаях синхронизация в итм,
    --по словам пользователя, уже должна была произойти.
    select
      ei.id_name,
      max(case when e.id_std_item is not null then 1 else 0 end) as used_in_std_item_estimate,
      max(case when o.id_status >= 1 then 1 else 0 end) as used_in_posted_order
    from
      estimate_items ei
      join estimates e on e.id = ei.id_estimate
      left join order_items oi on oi.id = e.id_order_item
      left join orders o on o.id = oi.id_order
    where
      ei.deleted = 0
    group by
      ei.id_name
  )
  select
  --проблема 11: сопоставление номенклатуры bcad_nomencl и итм (dv.nomenclatura) - в норме вся номенклатура из
  --bcad_nomencl должна быть заведена и в итм под тем же (с точностью до регистра) именем - см. RenameNomenclatura
  --в uFrmODedtOrStdItem.pas, где переименование ведется синхронно в обе стороны. расхождение считается ОЖИДАЕМЫМ
  --только тогда, когда номенклатура НИГДЕ не использовалась ни в собственной смете стандартного изделия, ни в
  --смете уже ПРОВЕДЕННОГО заказа - то есть еще просто не дошла очередь до передачи в итм (например, только в
  --смете заказа, который пока "на оформлении"). is_ok = 0 в остальных случаях - это уже реальное расхождение.
  --is_ok/in_itm пока в виде простых 0/1 - иконку ("красный минус" для in_itm = 0) добавим отдельно, когда будет
  --код картинки.
    bn.id as id_bcad_nomencl,
    bn.name,
    bn.is_purchased,
    (select min(x.id_nomencl) from dv.nomenclatura x where x.name = bn.name) as id_nomencl_itm,
    case when exists (select 1 from dv.nomenclatura x where x.name = bn.name) then 1 else 0 end as in_itm,
    nvl(u.used_in_std_item_estimate, 0) as used_in_std_item_estimate,
    nvl(u.used_in_posted_order, 0) as used_in_posted_order,
    case
      when exists (select 1 from dv.nomenclatura x where x.name = bn.name) then 1 --есть в итм - проблемы нет
      when nvl(u.used_in_std_item_estimate, 0) = 1 then 0 --должна быть в итм (смета стандартного изделия) - проблема
      when nvl(u.used_in_posted_order, 0) = 1 then 0 --должна быть в итм (смета проведенного заказа) - проблема
      else 1 --нигде не использовалась либо только в смете непроведенного заказа - расхождение пока ожидаемо
    end as is_ok
  from
    bcad_nomencl bn
    left join usage u on u.id_name = bn.id
;


--------------------------------------------------------------------------------
--проверочные выборки из каждой вью - для быстрого ручного прогона всего файла целиком
--------------------------------------------------------------------------------
select * from v_orders_check1; --проблема 1: дубли имен полуфабрикатов между подгруппами
select * from v_orders_check2; --проблема 2: полуфабрикат = нестандартное изделие по имени
select * from v_orders_check3; --проблема 3: полное имя любого изделия = голому имени п/ф или нестандартного
select * from v_orders_check4; --проблема 4: отгрузочное изделие как компонент чужой сметы
select * from v_orders_check5; --проблема 5: несоответствие производственного изделия в самосмете отгрузочного
select * from v_orders_check6; --проблема 6: нестандартное изделие как компонент чужой сметы
select * from v_orders_check7; --проблема 7: дубли имен в bcad_nomencl без учета регистра
select * from v_orders_check8; --проблема 8: дубли имен в итм (dv.nomenclatura) без учета регистра
select * from v_orders_check9; --проблема 9: лишние пробелы в именах bcad_nomencl
select * from v_orders_check10; --проблема 10: лишние пробелы в именах итм (dv.nomenclatura)
select * from v_orders_check11; --проблема 11: номенклатура bcad_nomencl, отсутствующая в итм без уважительной причины
