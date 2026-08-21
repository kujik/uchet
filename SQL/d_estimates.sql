
alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;



--+++++++++++
--таблица групп материалов bCAD
--данные должны вноситься вручную через справочник, при загрузке сметы несуществующая
--группа вызовет ошибку
--alter table bcad_groups add is_semiproduct number(1) default 0; 
create table bcad_groups(
  id number(11),
  name varchar2(1000) unique not null,     --наименование
  is_production number(1) default 0,       --это группа, содержащая готовые изделия  
  is_semiproduct number(1) default 0,       --это группа, содержащая полуфабрикаты  
  constraint pk_bcad_groups primary key (id)
);

create sequence sq_bcad_groups start with 100 nocache;
 
insert into bcad_groups (id, name) values (1, 'ДК');
insert into bcad_groups (id, name) values (2, 'ПФ');
insert into bcad_groups (id, name) values (3, 'Панели: Материалы основы');
insert into bcad_groups (id, name) values (4, 'Панели: Материалы кромок');

create or replace trigger trg_bcad_groups_bi_r before insert on bcad_groups for each row
begin
  if :new.id is null then
    select sq_bcad_groups.nextval into :new.id from dual;
  end if;
end;
/

--единицы измерения bCad
create table bcad_units(
  id number(11),
  name varchar2(50) unique not null,     --наименование
  constraint pk_bcad_units primary key (id)
);

create sequence sq_bcad_units start with 100 nocache;
 
insert into bcad_units (id, name) values (1, 'шт.');

create or replace trigger trg_bcad_units_bi_r before insert on bcad_units for each row
begin
  if :new.id is null then
    select sq_bcad_units.nextval into :new.id from dual;
  end if;
end;
/

--наименования материалов bCad (и из смет, которых нет в bCad)
--таблица просто наименований, без привязки групп и прочих характеристик!
--не делаем уникальность без учета регистра!
create table bcad_nomencl(
  id number(11),
  name varchar2(1000) unique not null,     --наименование
  is_purchased number(1) default 0,        --номенклатура является покупной  --$+
  constraint pk_bcad_nomencl primary key (id)
);

--create unique index idx_bcad_nomencl on bcad_nomencl(lower(name)); 

create sequence sq_bcad_nomencl start with 100 nocache;

create or replace trigger trg_bcad_nomencl_bi_r before insert on bcad_nomencl for each row
begin
  select sq_bcad_nomencl.nextval into :new.id from dual;
end;
/

--комментарии к позициям из файлов смет
create table bcad_comments(
  id number(11),
  name varchar2(1000) unique not null,     --наименование
  constraint pk_bcad_comments primary key (id)
);

--create unique index idx_bcad_comments on bcad_comments(lower(name)); 

create sequence sq_bcad_comments start with 100 nocache;

create or replace trigger trg_bcad_comments_bi_r before insert on bcad_comments for each row
begin
  select sq_bcad_comments.nextval into :new.id from dual;
end;
/

--вью справочника номенклатуры бкад
--собраны изделия, использующиеся в сметах, по данным таблицы bcad_nomencl
--дополнительные параметры, как группа, ед.изм и коммент, задаются в конкретной смете и к bcad_nomencl не привязаны,
--потому собраны случайные (максимальные для данного наименования) эти параметры по данным существующих смет  
create or replace view v_bcad_nomencl as select
  n.id,
  n.name,
  bg.name as groupname,
  bg.id as id_group,
  bu.name as unitname,
  bu.id as id_unit,
  bc.name as bcadcomment
from 
  bcad_nomencl n,
  (select max(id_group) idg, max(id_unit) idu, max(id_comment) idc, id_name from estimate_items e group by id_name) ei,
  bcad_groups bg,
  bcad_units bu,
  bcad_comments bc
where
  n.id = ei.id_name (+) and
  bg.id (+) = ei.idg and  
  bu.id (+) = ei.idu and  
  bc.id (+) = ei.idc  
; 

create or replace view v_bcad_nomencl_add as select
  bn.*,
  n.artikul,
  n.id_nomencl as id_itm
from
  v_bcad_nomencl bn,
  dv.nomenclatura n
where
  bn.name = n.name (+)
;      


select count(*) from bcad_nomencl; 
select count(*) from v_bcad_nomencl; 
select * from v_bcad_nomencl_add; 
select max(id_group) idg, max(id_unit) idu, max(id_comment) idc, id_name from estimate_items e group by id_name;
select to_char(id) as id, groupname, name, unitname, bcadcomment, artikul, id_itm from v_bcad_nomencl_add where id_itm is not null;




--таблица автозамены позиций в сметах для их загрузки в ИТМ
create table ref_estimate_replace(
  id_old number(11) not null,           --айди заменяемой позиции
  id_new number(11),                    --айди новой позиции, или null, если позицию надо просто удалять
  constraint pk_ref_estimate_replace primary key (id_old),
  constraint fk_ref_estimate_replace_old foreign key (id_old) references bcad_nomencl(id) on delete cascade,
  constraint fk_ref_estimate_replace_new foreign key (id_new) references bcad_nomencl(id) on delete cascade
);

--вью для журнала автозамены смет
create or replace view v_ref_estimate_replace as select
  r.id_old || '-' || nvl(r.id_new, 0) as id,
  r.*,
  nold.name as oldname,
  nnew.name as newname,
  dvold.artikul as oldartikul,
  dvnew.artikul as newartikul
from  
  ref_estimate_replace r,
  bcad_nomencl nold,
  bcad_nomencl nnew,
  dv.nomenclatura dvold,
  dv.nomenclatura dvnew
where 
  r.id_old = nold.id and
  r.id_new = nnew.id (+) and
  dvold.name (+) = nold.name and 
  dvnew.name (+) = nnew.name 
;

--вью справочника выбора номенклатуры
--так как группы, единицы, комментарии к ним не привязаны
--(а привязаны к сметным позициям в каждой смете)
--то сюда их не тянем
create or replace view v_ref_nomencl as select
  n.*,
  dvn.artikul as artikul
from  
  bcad_nomencl n,
  dv.nomenclatura dvn
where 
  dvn.name (+) = n.name 
;    
    
select * from v_ref_nomencl;
--------------------------------------------------------------------------------

--таблица сметы на позицию заказа или стандартное изделие
--на данную позицию может быть только одна запись в этой таблице
create table estimates(
  id number(11),
  id_std_item number(11) unique,              --айди стандартного изделия
  id_order_item number(11) unique,            --айди позиции в заказе (оба поля одновременно не могут быть заданы!)
  id_buffer number(11) unique,                 
  dt date,                                    --дата создания сметы
  dt_create date,                             --дата создания, со временем, фиксируется триггером   
  dt_changed date,                            --дата изменения (вставка/удалени позиций, изменение наименования или количества), со временем, фиксируется триггером
  dt_changed_any date,                        --дата любого изменения сметы    --$+
  dt_changed_depend date,                     --дата изменения смет, от которой зависит эта
  has_influencing number(1) default 0,        --смета имеет влияющие на нее сметы
  dt_influencing_ready date,                  --дата, когда все влияющие подгружены, иначе нулл
  isempty number(1) default 0,                --признак того, что смета является пустой 
  has_influencing number(1),                  --флаг, что смета имеет влияющие сметы 
  dt_influencing_ready date,                  --проставляется, когда все влияющие сметы загружены 
  constraint pk_estimates primary key (id),
  constraint fk_estimates_std_item foreign key (id_std_item) references or_std_items(id) on delete cascade,
  constraint fk_estimates_order_item foreign key (id_order_item) references order_items(id) on delete cascade
);  

create index idx_estimate_items_parent on estimate_items(id_estimate, id_dependent_estimate);

select i.* from estimate_items i, estimates e where e.id = i.id_estimate and e.id_std_item is not null;

create sequence sq_estimates start with 100 nocache;

create or replace trigger trg_estimates_bi_r before insert on estimates for each row
begin
  if nvl(:new.id, 0) > -1 then 
    :new.id := sq_estimates.nextval;
    :new.dt_create := nvl(:new.dt_create, sysdate);
  end if;
end;
/


--позиция в смете
--alter table estimate_items drop column id_name_resale_std;
--alter table estimate_items add contract number(1) default 0;
--alter table estimate_items add  constraint fk_estimate_items_std foreign key (id_or_std_item) references or_std_items(id);
alter table estimate_items add or_std_item_cnt number;
create table estimate_items(
  id number(11),
  id_estimate number(11),                      --родительская смета
  id_or_std_item number(11),                   --айди стандартного изделия, если сметная позиция является стандартным изделием
  or_std_item_cnt number,
  id_group number(11),                         --группа бкад
  id_name number(11),                          --наименование бкад
  id_unit number(11),                          --единица измерения
  id_comment number(11),                       --комментарий из сметы
  --contract number(1) default 0,                --подрядный полуфабрикат  --!-
  qnt1 number(15,5),                           --количество на одно изделие, по учету
  qnt number(15,5),                            --количество на все изделия, по учету, только для заказов 
  qnt1_itm number(15,5),                       --количество на одно изделие, по итм
  qnt_itm number(15,5),                        --количество на все изделия, по итм, только для заказов 
  qnt_itm_last number(15,5) default null,      --последнее переданное в итм количество по данной позиции, только для заказов
  --id_dependent_estimate number(11),            --ссылка на другую смету, которая использует данную позицию как вложенное изделие (заполняется автоматически) не используем!!!
  deleted number(1) default 0,                 --признак, что данная позиция удалена (=1)
  constraint pk_estimate_items primary key (id),
  constraint fk_estimate_items_std foreign key (id_or_std_item) references or_std_items(id),
  constraint fk_estimate_items_estimate foreign key (id_estimate) references estimates(id) on delete cascade,
  constraint fk_estimate_items_group foreign key (id_group) references bcad_groups(id),
  constraint fk_estimate_items_name foreign key (id_name) references bcad_nomencl(id),
  constraint fk_estimate_items_resale foreign key (id_name_resale) references or_std_items(id),
  constraint fk_estimate_items_unit foreign key (id_unit) references bcad_units(id),
  constraint fk_estimate_items_comment foreign key (id_comment) references bcad_comments(id)
);

create index idx_estimate_items_estimate on estimate_items(id_estimate); 
create index idx_estimate_items_name on estimate_items(id_name); 
create index idx_estimate_items_resale on estimate_items(id_name_resale); 
create index idx_estimate_items_comment on estimate_items(id_comment);

--не pапрещено иметь в смете по одному изделию/слешу несколько одинаковых наименований!!!
create unique index idx_estimate_items_estname_uq on estimate_items(id_estimate, id_name);

create sequence sq_estimate_items start with 100 nocache;

create or replace trigger trg_estimate_items_bi_r before insert on estimate_items for each row
begin
  select sq_estimate_items.nextval into :new.id from dual;
end;
/

drop trigger trg_estimate_items_aiud_r;
/*create or replace trigger trg_estimate_items_aiud_r
--  after insert or update or delete on estimate_items
  after insert or update on estimate_items
  for each row
--фиксируем дату обновления сметы при добавлении или удалении
--строк либо при изменении наименования или количества на единицу для 
declare
  v_id_estimate estimates.id%type;
begin
  if inserting or deleting then
    v_id_estimate := nvl(:new.id_estimate, :old.id_estimate);
  else
    v_id_estimate := :new.id_estimate;
  end if;
  if inserting or deleting then
    update estimates
      set dt_changed = sysdate
      where id = v_id_estimate;
  elsif updating then
    if (nvl(:old.qnt1, 0) <> nvl(:new.qnt1, 0)) or
       (nvl(:old.id_name, -1) <> nvl(:new.id_name, -1)) then
      update estimates
        set dt_changed = sysdate
        where id = v_id_estimate;
    end if;
  end if;
end;
/
*/

create or replace trigger trg_estimate_items_aiud_r   --$-
--фиксируем дату обновления сметы при добавлении или удалении
--строк либо при изменении наименования или количества на единицу для 
  after insert or update or delete on estimate_items
  for each row
declare
  v_id_estimate estimates.id%type;
  e_mutation exception;
  pragma exception_init(e_mutation, -4091);
begin
  if inserting or deleting then
    v_id_estimate := nvl(:new.id_estimate, :old.id_estimate);
  else
    v_id_estimate := :new.id_estimate;
  end if;
  if inserting or deleting then
    begin
      update estimates set dt_changed = sysdate where id = v_id_estimate;
    exception
      when e_mutation then null; -- подавляем только мутацию
    end;
  elsif updating then
    if (nvl(:old.qnt1, 0) <> nvl(:new.qnt1, 0)) or
       (nvl(:old.id_name, -1) <> nvl(:new.id_name, -1)) then
      begin
        update estimates set dt_changed = sysdate where id = v_id_estimate;
      exception
        when e_mutation then null;
      end;
    end if;
  end if;
end;
/

drop trigger trg_estimate_items_dep_id;
create or replace trigger trg_estimate_items_dep_id
  before insert or update of id_name on estimate_items
  for each row
--проставим айди сметы, если сметная позиция ей является
begin
  if inserting or updating then
    :new.id_dependent_estimate := f_get_dependent_estimate(:new.id_name, :new.id_estimate);
  end if;
end;
/

 
--вызывает ошибки при удалении в ора11хе!!!
drop trigger trg_estimate_items_master;
create or replace trigger trg_estimate_items_master   --$-
  for insert or update or delete on estimate_items
  compound trigger

  -- коллекция для хранения уникальных id_estimate
  type t_id_arr is table of estimates.id%type index by pls_integer;
  v_ids t_id_arr;

  -- секция для каждой строки: запоминаем id родителя
  before each row is
    v_id estimates.id%type;
  begin
    -- определяем id_estimate из новой или старой записи
    if inserting or updating then
      v_id := :new.id_estimate;
    else
      v_id := :old.id_estimate;
    end if;

    if v_id is not null then
      v_ids(v_id) := v_id; -- уникальные ключи в ассоциативном массиве
    end if;
  end before each row;

  -- секция после выполнения всей операции
  after statement is
  begin
    -- один раз обновляем все уникальные сметы
    forall i in indices of v_ids
      update estimates
        set dt_changed = sysdate
        where id = v_ids(i);
  end after statement;

end;
/

create or replace procedure P_CopyEstimateToUserTemp(
  AIdUser in number,
  AIdStdItem in number,
  AIdOrItem in number
) is
begin
  if AIdUser < 1 then
    return;
  end if;
  delete from estimates where id = -AIdUser;
  insert into estimates (id) values (-AIdUser);
  if AIdStdItem is not null then
    insert into estimate_items (id_estimate, id_group, id_name, id_unit, qnt1, id_comment, id_dependent_estimate)
      select -AIdUser, id_group, id_name, id_unit, qnt1, id_comment, id_dependent_estimate from v_estimate where id_std_item = AIdStdItem;
  elsif AIdOrItem is not null then  
    insert into estimate_items (id_estimate, id_group, id_name, id_unit, qnt1, id_comment, id_dependent_estimate)
      select -AIdUser, id_group, id_name, id_unit, qnt1, id_comment, id_dependent_estimate from v_estimate where id_order_item = AIdOrItem;
  end if;
end; 
/ 

call P_CopyEstimateToUserTemp(33,0,0);

--------------------------------------------------------------------------------
create or replace procedure p_createbcadnamecomm(
--создадим записи в таблицах наименований и комметраиев бкад для смет
--вернем айди созданных либо найденых записей
  nameitem in varchar2,
  commentitem in varchar2,
  idnameitem out number,
  idcommentitem out number
) is
begin
  begin
    select id into idnameitem from bcad_nomencl where name = nameitem;
  exception
    when no_data_found then
      insert into bcad_nomencl(name)
      values(nameitem) returning id into idnameitem;
  end;
  if commentitem is null then
    idcommentitem := null;
  else 
      begin
        select id into idcommentitem from bcad_comments where name = commentitem;
      exception
        when no_data_found then
          insert into bcad_comments(name)
          values(commentitem) returning id into idcommentitem;
      end;
  end if;
end;
/

create or replace procedure p_CreateEstimateItem(  --$+
  pid_estimate number,                      --родительская смета
  pid_group number,                         --группа бкад
  pname varchar2,                          --наименование бкад
  pid_unit number,                          --единица измерения
  pcomment varchar2,                       --комментарий из сметы
  pqnt1 number,                           --количество на одно изделие
  pqnt number,                           --количество на все изделия   no use
  pid_or_std_item number default null    --айди стандартного изделия/полуфабриката, если позиция выбрана из справочника (диалог сметы), иначе null
) is 
  iditem number;
  idnameitem number;
  idcommentitem number;
  idorderitem number;
  idstditem number;
  isstdoritem number;
  qntall number;
  qntinor number;
begin
  --запись в родительской таблице - должна быть
  begin
    select id_order_item, id_std_item into idorderitem, idstditem from estimates where id = pid_estimate;
  exception
    when no_data_found then Return;
  end;
  isstdoritem := null;
  qntall := null;
  qntinor := 1;
  if idstditem is null then 
    --для позиции в заказе 
    select std, qnt into isstdoritem, qntinor from order_items where id = idorderitem;
    --это стандартное изделие в заказе
    if isstdoritem = 1 then 
      Return;
    end if;
    --в этом изделии нулевое количество по данной позиции - не создаем смету
    if qntinor = 0 then 
      Return;
    end if;
    qntall := Ceil(pqnt1 * qntinor * 10) / 10;
  end if;
  begin
    select id into idnameitem from bcad_nomencl where name = pname;
  exception
    when no_data_found then
      insert into bcad_nomencl(name)
      values(pname) returning id into idnameitem;
  end;
  if pcomment is null then
    idcommentitem := null;
  else 
      begin
        select id into idcommentitem from bcad_comments where name = pcomment;
      exception
        when no_data_found then
          insert into bcad_comments(name)
          values(pcomment) returning id into idcommentitem;
      end;
  end if;
  begin
    select id into iditem from estimate_items e 
      where e.id_name = idnameitem and e.id_estimate = pid_estimate;
  exception
    when no_data_found then
      insert into estimate_items (id_estimate, id_name)
        values(pid_estimate, idnameitem) returning id into iditem;
  end;
  update estimate_items set id_group = pid_group, id_unit = pid_unit, id_comment = idcommentitem, qnt1 = pqnt1, qnt = qntall, qnt1_itm = pqnt1, qnt_itm = qntall, id_or_std_item = pid_or_std_item, deleted = 0
    where id = iditem;
end;
/

--++ процедура коррекции сметы с учетом справочника автозамены
create or replace procedure P_CorrectEstimateWithReplace (
--корректируем указанную смету с учетом списка автозамены
--изначально в смете количеества для учета и итм совпадают
--если позиция в смете найдена в списке автозамены, то для такой позиции количества в смете для итм проставляется в null
--если есть айди на которое заменяем, то пытаемся найти, есть ли такая позиция уже в данной смете, в случае нахождения прибаляем к ней полученные ранее количества итм
--в случае отстутствия в смете позиции, на которую заменяем, мы добавляем ее с полученным количеством для итм, и количеством для учета равным null
--!может некорректно работать если есть одинаковые строки сметы (несколькко строк с одним id_name), связанные с заменами - это не запрещено констрайнтами
  IdEstimate in number       --запись в estimates
)  
is
  cursor c1 is
    select
      e.id, e.id_name, e.id_group, e.id_unit, e.id_comment, e.qnt1, e.qnt, r.id_new
    from
      estimate_items e, 
      ref_estimate_replace r
    where
      e.id_estimate = IdEstimate and e.id_name = r.id_old 
  ;
  PId number; 
  IdGroup number;
  IdName number;
  IdNameOld number;
  IdNameNew number;
  IdUnit number;
  IdComment number;
  PQnt1 number;
  PQnt number; 
  QntAll number;
begin
  open c1;
  loop
    fetch c1 into PId, IdName, IdGroup, IdUnit, IdComment, PQnt1, PQnt, IdNameNew;
    exit when c1%notfound;
    update estimate_items set qnt1_itm = null, qnt_itm = null where id = PId;
    if IdNameNew is not null then
      select max(id) into PId from estimate_items where id_estimate = IdEstimate and id_name = IdNameNew; -- and qnt1 is not null;
      if PId is not null then
--        update estimate_items set qnt1_itm = nvl(qnt1_itm, 0) + PQnt1, qnt_itm = nvl(qnt_itm, 0) + PQnt where id = PId;
        --в смете уже может быть такая позиция, на которую заменяем, в эьтом случае количества надо сложить
        --но складываем с первоначальным количеством этой позиции по смеите, так как при сложении с qnt_itm при повторном вызове будет задвоение  
        update estimate_items set qnt1_itm = nvl(qnt1, 0) + PQnt1, qnt_itm = nvl(qnt, 0) + PQnt where id = PId;  --!!!
      else
        insert into estimate_items (id_estimate, id_name, id_group, id_unit, id_comment, qnt1, qnt, qnt1_itm, qnt_itm)
          values(IdEstimate, IdNameNew, IdGroup, IdUnit, IdComment, null, null, PQnt1, PQnt)
        ;
      end if; 
    end if;
  end loop;
  close c1;
end;
/ 

--УСТАРЕЛО, заменяется на p_copy_std_estimate_to_order_item (ниже). Причины замены:
--  - копирует id_dependent_estimate из позиции сметы-источника прямо в позицию сметы-приемника, хотя это поле
--    всегда пересчитывается автоматически триггером trg_estimate_items_dep_id при вставке строки (по id_name
--    и id_estimate ЦЕЛЕВОЙ строки) - явное присваивание в последующем update просто затирает верно посчитанное
--    триггером значение чужим (от сметы-источника), поэтому в новой процедуре это поле не трогается;
--  - не копирует id_or_std_item/or_std_item_cnt/contract - эти поля появились в estimate_items позже;
--  - лога изменений нет - теперь строится оберткой uOrders.LoadEstimate сравнением "было"/"стало".
--вызовы заменены на новую процедуру (uOrders.pas TOrders.LoadEstimate, d_orders.sql P_CreatePspForSemiproducts).
--удалить после подтверждения, что новая процедура отработала на реальных данных.
create or replace procedure P_CopyEstimate ( --$-
--устарела, см. p_copy_std_estimate_to_order_item ниже - не трогать, кандидат на удаление
  IdEstimate in number,       --запись в estimates должна быть создана
  IdStdEstimate in number,    --айди стандартной, из которой копируем
  OrQnt in number             --количество изделий в заказе 
)  
is
  cursor c1 is
    select
      id_group, id_name, id_unit, id_comment, qnt1, qnt1_itm, id_dependent_estimate      
    from estimate_items 
    where id_estimate = IdStdEstimate; 
  IdGroup number;
  IdName number;
  IdUnit number;
  IdComment number;
  PQnt1 number;
  PQnt1_Itm number;
  PQnt number; 
  QntAll number;
  QntAll_Itm number;
  IdItem number;
  QidDep number;
--  v_id_or_std_item number;
  st varchar2(400);
begin
  update estimate_items set deleted = 1 where id_estimate = IdEstimate;
  open c1;
  loop
    fetch c1 into IdGroup, IdName, IdUnit, IdComment, PQnt1, PQnt1_Itm, QidDep;
    exit when c1%notfound;
    begin
      select id into IdItem from estimate_items 
        where nvl(id_name, -100) = nvl(IdName, -100) and id_estimate = IdEstimate;
    exception
      when no_data_found then
        insert into estimate_items (id_estimate, id_name)
          values(IdEstimate, IdName) returning id into IdItem;
    end;
    QntAll := null;
    if (OrQnt is not null)and(PQnt1 is not null) then
      QntAll := Ceil(PQnt1 * OrQnt * 1000) / 1000; 
    end if;
    QntAll_Itm := null;
    if (OrQnt is not null)and(PQnt1_Itm is not null) then
      QntAll_Itm := Ceil(PQnt1_Itm * OrQnt * 1000) / 1000; 
    end if;
    update estimate_items 
      set id_group = IdGroup, id_unit = IdUnit, id_comment = IdComment, qnt1 = PQnt1, qnt = QntAll, qnt1_itm = PQnt1_Itm, qnt_itm = QntAll_ITM, id_dependent_estimate = QidDep, deleted = 0
      where id = IdItem;
  end loop;
  close c1;
  delete from estimate_items where id_estimate = IdEstimate and deleted = 1;
  --dbms_output.put_line (st);
end;
/ 

begin
--  P_CopyEstimate(108, 100, 10);
  null;
end;
/

--------------------------------------------------------------------------------
--копируем состав сметы стандартного изделия в смету изделия заказа, масштабируя количество на кол-во изделий
--в заказе. заменяет P_CopyEstimate (выше, помечена на удаление) - тот же принцип сравнения по id_name (пометить все удаленными,
--затем найти/создать и обновить по имени, в конце снести неиспользованные), но:
--  - копируются также id_or_std_item, or_std_item_cnt, contract;
--  - id_dependent_estimate не копируется - его сам пересчитает триггер trg_estimate_items_dep_id для целевой строки;
--  - процедура не логирует изменения и не делает commit - это ответственность вызывающей стороны (обертка
--    uOrders.LoadEstimate сама снимает смету "до" через LoadEstimateArray, вызывает эту процедуру, снимает "после"
--    и пишет diff в estimate_change_log).
create or replace procedure p_copy_std_estimate_to_order_item( --$+
--копируем состав сметы стандартного изделия в смету изделия заказа, масштабируя количество на кол-во изделий в заказе
  p_id_estimate     in number,  --смета изделия заказа, в которую копируем (запись в estimates уже должна быть создана)
  p_id_std_estimate in number,  --смета стандартного изделия, из которой копируем
  p_or_qnt          in number   --количество изделий в заказе, для масштабирования qnt/qnt_itm от qnt1/qnt1_itm
) is
  v_id_item number;
  v_qnt     number;
  v_qnt_itm number;
begin
  update estimate_items set deleted = 1 where id_estimate = p_id_estimate;
  for r in (
    select id_group, id_name, id_unit, id_comment, qnt1, qnt1_itm, id_or_std_item, or_std_item_cnt
      from estimate_items
     where id_estimate = p_id_std_estimate
  ) loop
    begin
      select id into v_id_item from estimate_items
       where id_estimate = p_id_estimate and nvl(id_name, -100) = nvl(r.id_name, -100);
    exception
      when no_data_found then
        insert into estimate_items (id_estimate, id_name)
          values (p_id_estimate, r.id_name) returning id into v_id_item;
    end;
    v_qnt := null;
    if p_or_qnt is not null and r.qnt1 is not null then
      v_qnt := ceil(r.qnt1 * p_or_qnt * 1000) / 1000;
    end if;
    v_qnt_itm := null;
    if p_or_qnt is not null and r.qnt1_itm is not null then
      v_qnt_itm := ceil(r.qnt1_itm * p_or_qnt * 1000) / 1000;
    end if;
    update estimate_items
       set id_group = r.id_group, id_unit = r.id_unit, id_comment = r.id_comment,
           qnt1 = r.qnt1, qnt = v_qnt, qnt1_itm = r.qnt1_itm, qnt_itm = v_qnt_itm,
           id_or_std_item = r.id_or_std_item, or_std_item_cnt = r.or_std_item_cnt,
           deleted = 0
     where id = v_id_item;
  end loop;
  delete from estimate_items where id_estimate = p_id_estimate and deleted = 1;
end;
/

/*
CREATE OR REPLACE procedure UCHET22.P_SendEstimateToItm (
--копируем смету в ИТМ
  IdEstimate in number,       --запись в estimates в учете
  IdZakaz in number,          --айди заказа в ИТМ
  IdParentIzdel in number,    --айди изделия в ИТМ 
  ResCount out number)        --выходной, сколько скопировано строк 
is
  cursor c1 is
    select
      id, name, unit, comm, qnt_itm, qnt_itm_last   --fullname        
    from 
      v_estimate
    where 
      id_estimate = IdEstimate and qnt_itm is not null; 
  FullName varchar2(1000);
  Unit varchar2(1000);
  Comment varchar2(1000);
  EId number;
  Qnt_Itm number;
  Qnt_Itm_Last number;
  IdSpec number;
  Flag number;
  FlagCnt number;
begin
  ResCount:=0;
  FlagCnt :=0;
  --проставим флаг для позиций сметы по данному изделию в ИТМ, для последующего удаления записей, которых более нет
  update dv.nomenclatura_in_izdel niz
    set niz.checked=1
    where niz.id_zakaz=IdZakaz
      and niz.id_nomizdel_parent_t=IdParentIzdel
      and niz.id_nominizdel <> IdParentIzdel;
  --заполняем сметные позиции в ИТМ
  open c1;
  loop
    fetch c1 into EId, FullName, Unit, Comment, Qnt_Itm, Qnt_Itm_Last;
    exit when c1%notfound;
    begin
      Flag := 0;
      if nvl(Qnt_Itm, -111) <> nvl(Qnt_Itm_Last, -111) then
        Flag := 1;
        FlagCnt := FlagCnt + 1;
        update estimate_items set qnt_itm_last = Qnt_Itm where id = EId;
      end if; 
      DV.P_SyncSpecIzdel(IdZakaz, IdParentIzdel, FullName, Unit, Qnt_Itm, Comment, IdSpec);
      if IdSpec <> -1 then
        ResCount := ResCount + 1;
      end if;
    exception
      when others then
        null;
    end;
  end loop;
  close c1;
  --удалим из ИТМ позиции, которых нет более в смете
  delete from dv.nomenclatura_in_izdel niz
    where niz.checked=1 and niz.id_zakaz=IdZakaz and niz.id_nomizdel_parent_t=IdParentIzdel;
  insert into adm_db_log (itemname, comm) values ('P_SendEstimateToItm ', 'id_zakaz ' || IdZakaz || '; id_parent_izdel ' || IdParentIzdel || '  изм=' || FlagCnt);
end;
/
*/

create or replace procedure P_SendEstimateToItm (  --$+
--копируем смету в ИТМ
--не синхронизируем, если заказ в учете не В работе 
--на всякий случай, в принципе эта процедура вызываться не должна в такой ситуации
  IdEstimate in number,       --запись в estimates в учете
  IdZakaz in number,          --айди заказа в ИТМ
  IdParentIzdel in number,    --айди изделия в ИТМ 
  ResCount out number)        --выходной, сколько скопировано строк 
is
  cursor c1 is
    select
      id, name, unit, comm, qnt_itm, qnt_itm_last   --fullname        
    from 
      v_estimate
    where 
      id_estimate = IdEstimate and qnt_itm is not null; 
  FullName varchar2(1000);
  Unit varchar2(1000);
  Comment varchar2(1000);
  EId number;
  Qnt_Itm number;
  Qnt_Itm_Last number;
  IdSpec number;
  Flag number;
  FlagCnt number;
  v_id_status number;
begin
--return;
/*  --получим статус заказа в учете
  select o.id_status into v_id_status 
  from orders o, order_items i, estimates e
  where i.id = e.id_order_item and o.id = i.id_order and e.id = IdEstimate;
  --не синхронизируем, если заказ не в работе
  if v_id_status <> 2 then
    return;
  end if;*/
  
  ResCount:=0;
  FlagCnt :=0;
  --проставим флаг для позиций сметы по данному изделию в ИТМ, для последующего удаления записей, которых более нет
  update dv.nomenclatura_in_izdel niz
    set niz.checked=1
    where niz.id_zakaz=IdZakaz
      and niz.id_nomizdel_parent_t=IdParentIzdel
      and niz.id_nominizdel <> IdParentIzdel;
  --заполняем сметные позиции в ИТМ
  open c1;
  loop
    fetch c1 into EId, FullName, Unit, Comment, Qnt_Itm, Qnt_Itm_Last;
    exit when c1%notfound;
    begin
      Flag := 0;
      if nvl(Qnt_Itm, -111) <> nvl(Qnt_Itm_Last, -111) then
        Flag := 1;
        FlagCnt := FlagCnt + 1;
        update estimate_items set qnt_itm_last = Qnt_Itm where id = EId;
      end if; 
      DV.P_SyncSpecIzdel(IdZakaz, IdParentIzdel, FullName, Unit, Qnt_Itm, Comment, IdSpec);
      if IdSpec <> -1 then

        ResCount := ResCount + 1;
      end if;
    exception
      when others then
        null;
    end;
  end loop;
  close c1;
  --удалим из ИТМ позиции, которых нет более в смете
  delete from dv.nomenclatura_in_izdel niz
    where niz.checked=1 and niz.id_zakaz=IdZakaz and niz.id_nomizdel_parent_t=IdParentIzdel;
  --insert into adm_db_log (itemname, comm) values ('P_SendEstimateToItm ', 'id_zakaz ' || IdZakaz || '; id_parent_izdel ' || IdParentIzdel || '  изм=' || FlagCnt);
end;
/ 


--!!!!!!!!!!!!!!!!!!!!!!!!!!
    select
      id, name, unit, comm, qnt_itm, qnt_itm_last   --fullname        
    from 
      v_estimate
    where 
      id_estimate = 131451 and qnt_itm is not null; 

--P_SendEstimateToItm - 131451 - 55777 - 1031823

declare
i number;
begin
P_SendEstimateToItm(131451,55777,1031823,i);
end;
/









create or replace procedure P_CorrectEstimateQnt (
--пересчитаем количество в смете для данной позиции в заказе,
--если в заказе количество = 0, то пометим всю смету на удаление
  IdOrderItem in number
)   
is
  QntOr number;
  IdEstimate number;
begin
  begin
    select nvl(qnt,0) into QntOr from order_items where id = IdOrderItem;
  exception
    when no_data_found then Return;
  end;
  begin
    select id into IdEstimate from estimates where id_order_item = IdOrderItem;
  exception
    when no_data_found then Return;
  end;
  if QntOr = 0 then
    update estimate_items set deleted = 1 where id_estimate = IdEstimate;
  else
    update estimate_items set qnt = Ceil(qnt1 * QntOr *10) / 10, deleted = 0 where id_estimate = IdEstimate and qnt1 is not null;
    update estimate_items set qnt_itm = Ceil(qnt1_itm * QntOr *10) / 10, deleted = 0 where id_estimate = IdEstimate and qnt1_itm is not null;
  end if; 
end;  



create or replace procedure p_deletefreeestimate (
--удалим запись по смете, в которой нет позиций, если только она не обозначена как пустая смета
  IdEstimate in number
)   
is
begin
  delete from estimates where 
    id = IdEstimate and isempty <> 1 and (select count(*) from estimate_items where id_estimate = IdEstimate) = 0;
end;  

-------------------------------------------------------------------------------
create or replace function F_TestEstimateItem(
--проверим правильность и новизну сметной позиции, вернем в строке
--1й символ = 0 если нет такой позция в справочнике номенклатуры бкад
--2й символ = 0 - ошибка для номенклатуры из группы Изделий - нет такого изделия в v_or_std_items
--3й символ = 0 - ошибка для номенклатуры из группы сметных позиций бкад - номенклатура найдена в списке изделий, при этом являясь материалом согласно группе 
  GroupId number,                         --группа бкад
  Pname varchar2                          --наименование бкад
) 
return varchar2
is 
  isprod number(1);            --это изделий (по признаку группы)
  isnew number(1);             --0, если это новая поззиция
  isproderr number(1);         --если позиция в группе Изделия, и не найдена в списке изделий с учетом префикса
  isbcaderr number(1);         --если позиция в группе номенклатуры из бкад, и найдена в списке изделий с учетом префикса
  cnt number(1); 
begin
  --select count(*) into isnew from bcad_nomencl where name = Pname; 
  select nvl(is_production,0) into isprod from bcad_groups where id = GroupId;
  isproderr:=1;
  isbcaderr:=1;
  select count(*) into cnt from v_or_std_items where fullname = Pname;
  --изделие обязательно должно быть в справочнике стандартных (а нестандартные там же) изделий
  if isprod = 1 and cnt <> 1 then 
    isproderr :=0;
  end if;
  if isprod = 0 and cnt <> 0 then 
  --материал не может быть изделием 
    isbcaderr :=0;
  end if;
  if isprod = 1 then 
    --проверяем изделия по базе Учета
    select count(*) into isnew from bcad_nomencl where name = Pname; 
  else 
    --проверяем Материалы по базе ИТМ
    select count(*) into isnew from dv.nomenclatura where name = Pname and id_nomencltype = 0; 
  end if;
  return isnew || isproderr || isbcaderr;
end;
/

select F_TestEstimateItem(103, 'Кофейная тумба. Стенка задняя МАГ.94.01.00_М02 Ral 7039 гладкая') from dual;

select * from v_or_std_items where name ='Кофейная тумба. Стенка задняя МАГ.94.01.00_М02 Ral 7039 гладкая';
--delete from or_std_items where name ='Стол кухонный_опора КБ.02.01.00_М01 RAL 9005';




create or replace function F_TestEstimateItem_New(
--проверим правильность и новизну сметной позиции, вернем в строке
--1й символ = 0 если нет такой позция в справочнике номенклатуры бкад
--2й символ = 0 - ошибка для номенклатуры из группы Изделий - нет такого изделия в v_or_std_items
--3й символ = 0 - ошибка для номенклатуры из группы сметных позиций бкад - номенклатура найдена в списке изделий, при этом являясь материалом согласно группе 
  AGroupId number,                         --группа бкад
  Aname varchar2,                         --наименование бкад
  AGroupStd number                         --группа самого изделия, по которому смета
) 
return varchar2
is 
  Fisprod number(1);            --это изделий (по признаку группы)
  Fissem  number(1);            --это полуфабрикат  
  FCnt number;
  FCnt2 number;
  FIdFormat number;
begin
  --select count(*) into isnew from bcad_nomencl where name = Pname; 
  select is_production, is_semiproduct into Fisprod, Fissem from bcad_groups where id = AGroupId;
  select count(*), nvl(max(id_format), -1) into FCnt, FIdFormat from v_or_std_items where fullname = Aname and type = 0 and id_format <> 0;
  if Fcnt <> 0 and Fisprod = 0 then
    return '1-Данная позиция является изделием!';
  end if;
  if Fcnt <> 0 and FIdFormat <> AGroupStd then
    return '1-изделие из этой группы недопустимо в этой смете!';
  end if;
  select count(*), nvl(max(id_format), -1) into FCnt, FIdFormat from v_or_std_items where fullname = Aname and type = 2;
  if Fcnt <> 0 and Fissem = 0 then
    return '1-Данная позиция является полуфабрикатом!';
  end if;
  if Fcnt <> 0 and not (FIdFormat = AGroupStd or FIdFormat = 1) then
    return '1-полуфабрикат из этой группы недопустим в этой смете!';
  end if;
  if (Fisprod = 1 or Fissem = 1) and FCnt = 0 then
    return '2-эту позицию необходимо внести в справочник стандартных изделий!';
  end if;
  if Fisprod = 1 and FCnt <> 0 then
    select count(*) into FCnt2 from estimates where id_std_item = (select id from v_or_std_items where fullname = Aname);
    if FCnt2 = 0 then
      return '3-К этому изделию должна быть подгружена смета!';
    end if;
  end if;
  if Fissem = 1 and FCnt <> 0 then
    select count(*) into FCnt2 from estimates where id_std_item = (select id from v_or_std_items where fullname = Aname);
    if FCnt2 = 0 then
      return '3-К этому полуфабрикату должна быть подгружена смета!';
    end if;
  end if;
  if (Fisprod = 0 and Fissem = 0) then
    select count(*) into FCnt2 from dv.nomenclatura where name = Aname and id_nomencltype = 0; 
    if FCnt2 = 0 then
      return '0-Внимание! Этой позиции еще нет в базе ИТМ!';
    end if;
  end if;
  return '';
end;
/

select
  bn.name
from
  bcad_nomencl bn,
  v_or_std_items i
where
  i.id_format = 0
  and bn.name = i.name
;

select
  i.name
from
  v_or_std_items i,
  v_or_std_items i2
where
  i.id_format = 0 and i2.id_format <> 0
  and i.name = i2.fullname
;  
 
  select max(id), max(type), max(id_format) 
    from v_or_std_items
    where fullname = 'Вывеска Об.св. буквы 400. Рама левая. ВБ.14.01.00_М01 Ral 7021 шагрень';      

create or replace procedure p_test_estimate_item(  --$+
--получение по данным типа объекта сметы и сметной позиции дополнительных данных
--по позиции (айди стандартного изделия (если это изделие), его сметы, типа изделия, есть ли в итм.
--кроме того, здесь же сосредоточена вся логика проверки допустимости такой позиции в смете
  p_estimate_type in varchar2, --тип объекта, к которому смета (П,О,ПФ,Н  и И если к нестандартному изделию заказа)
  p_group_id    in  number,  --айди группы бкад
  p_name        in  varchar2,--наименование  
  p_group_std   in  number,  --айди группы стандартных изделий для родительской сметы 
  p_result      out number,  --тип результата: 0 = ок, -1 = ошибка, 1 - предупреждение  
  p_id_std_item out number,  --айди стандартного изделия для данной позиции 
  p_id_estimate out number,  --айди сметы по данной позиции
  p_type_of_item out varchar2,  --тип стандартного изделия ('',П,О,ПФ,Н)
  p_is_new_position out number,  --позиции нет в ИТМ
  p_message      out varchar2  --текст ошибки, или сообщения
) is
  v_is_prod      number(1);
  v_is_semi      number(1);
  v_cnt2         number;
  v_id_format    number;
  v_id_std       number;
  v_type         number;
begin
  -- инициализация выходных параметров
  p_result := 0;
  p_id_std_item := null;
  p_id_estimate := null;
  p_type_of_item := null;
  p_is_new_position := 0;
  p_message := null;

  --проверка на отсутствие выбранных данных
  if (p_name is null) or (p_group_id is null) then
    p_result := -1;
    p_message := 'Не выбрана позиция или группа!';
    return;
  end if;

  --найдем айди стандартного изделия, соответствующего по полному наименованию позиции
  select max(id), max(type), max(id_format) into v_id_std, v_type, v_id_format
    from v_or_std_items
    where fullname = p_name;
  if v_id_std is null then
    select max(id), max(type), max(id_format) into v_id_std, v_type, v_id_format
      from v_or_std_items
      where name = p_name;
  end if;
  p_id_std_item := v_id_std;
  --если найдено стандартное изделие, найдем для него айди сметы
  if p_id_std_item is not null then
    select count(*) into v_cnt2
      from estimates
      where id_std_item = v_id_std;
    if v_cnt2 > 0 then
      select min(id) into p_id_estimate
        from estimates
       where id_std_item = v_id_std;
    end if;
    --получим тип позиции
    p_type_of_item :=
    case
      when v_id_format is null then null
      when v_id_format= 0 then 'Н'
      when v_type = 0 then 'П'
      when v_type = 1 then 'О'
      when v_type = 2 then 'ПФ'
    end;
  else
    --проверим, есть ли эта номенклатура в итм (только для позиций, не являющихся стандартными изделиями)
    select count(*) into v_cnt2
      from dv.nomenclatura
     where name = p_name
       and id_nomencltype = 0;
    if v_cnt2 = 0 then
      p_is_new_position := 1;
    end if;
  end if;

  --признак "изделие" по группе (полуфабрикаты сейчас к группе бкад не привязаны)
  select nvl(max(is_production), 0), 0  --is_semiproduct
    into v_is_prod, v_is_semi
    from bcad_groups
   where id = p_group_id;

  if p_type_of_item = 'О' then
    p_message := 'Данная позиция является отгрузочным изделием и недопустимо в смете!';
    p_result := 1;  --предупреждения, такие позиции встречаются как минимум при подряде
  elsif nvl(p_type_of_item, '-') in ('П', 'О') and v_is_prod = 0 then
    p_message := 'Данная позиция является изделием, и должна быть в группе "Готовые изделия"!';
    p_result := -1;
  elsif p_type_of_item = 'П' and v_id_format <> p_group_std then
    p_message := 'Производственное изделие из этой группы недопустимо в этой смете!';
    p_result := -1;
  elsif not nvl(p_type_of_item, '-') in ('П', 'О', 'ПФ', 'Н') and v_is_prod = 1 then
    p_message := 'Данная позиция не является изделием, однако находится в группе "Готовые изделия"!';
    p_result := 1;
  end if;
/*
надо лии запрещать не изделия в готовых изделиях
*/
end;
/

create or replace view v_estimate as  --!!!
select
  ei.*,
  bn.name as bname,
  bn.name as name,
/*  case
    when si.name is not null
      then decode(fe.prefix, '', '', fe.prefix || '_') || si.name
    else bn.name
  end as name,*/
  bg.name as groupname,
  bu.name as unit,
  bc.name as comm,
  fe.prefix,
  e.id_order_item,
  e.id_std_item,
  e.has_influencing,
  e.dt_influencing_ready,
  prc.price,
  ei.qnt1_itm * nvl(prc.price, 0) as sum1,
  case when has_influencing = 0 then null when dt_influencing_ready is null then date '2000-01-01' else trunc(dt_influencing_ready) end as dt_influencing,  
  2 as cidsemiproduct,
  103 as cidkrep,
  104 as cidproduct,
  1 as cidstuff
from
  estimate_items ei,
  bcad_nomencl bn,
  bcad_units bu,
  bcad_comments bc,
  bcad_groups bg,
  or_std_items si,
  or_format_estimates fe,
  estimates e,
  (select id, f_get_estitem_raw_price(id) as price from estimate_items) prc
where
  ei.id_name = bn.id (+)
  and ei.id_unit = bu.id (+)
  and ei.id_comment = bc.id (+)
  and ei.id_group = bg.id (+)
  and ei.id_or_std_item = si.id (+)
  and si.id_or_format_estimates = fe.id (+)
  and ei.id_estimate = e.id (+)
  and prc.id (+) = ei.id
;

create or replace view v_estimate_add as 
select
  e.*,
  n.artikul
from
  v_estimate e,
  dv.nomenclatura n
where
  e.name = n.name (+) 
;


create or replace view v_estimate_for_edit_dlg as --$+
select
--вью для диалога редактирования сметы
  e.*,
  case
    when e.id_or_std_item is null then null
    when f.id = 0 then 'Н'
    when f.type = 0 then 'П'
    when f.type = 1 then 'O'
    when f.type = 2 then 'ПФ'
  end as type_of_item,
  e2.id as id_item_estimate,
  n.artikul,
  s.qnt as qnt_on_stock
from
  v_estimate e
  left join dv.nomenclatura n on n.name = e.name
  left join v_spl_qntonstocks_sum_2 s on s.id_nomencl = n.id_nomencl
  left join or_std_items si on si.id = e.id_or_std_item
  left join or_format_estimates f on f.id = si.id_or_format_estimates
  left join (
    select min(id) as id, id_std_item
    from v_estimate
    group by id_std_item
  ) e2 on e2.id_std_item = si.id
;


create or replace view v_estimate_prices as select
  e.*,
  F_GetLastCostNomNameFromItm(e.name) as price,
  Round(F_GetLastCostNomNameFromItm(e.name) * qnt1, 2) as sum1
from
  v_estimate e
;    




create or replace view v_findinestimate_std as
select
--поиск сметы по сметной позиции в сметах стандартных изделий
  si.name,
  si.id as id_std_item,
  e.id as id_estimate,
  si.name as stdname,
  f.name || ' [' || fe.name || ']' as formatname,
  bn.name as bcadname 
from
  v_or_std_items si,   
  estimate_items ei,
  estimates e,
  bcad_nomencl bn,
  or_format_estimates fe,
  or_formats f
where 
  e.id = ei.id_estimate
  and e.id_std_item = si.id
  and ei.id_name = bn.id
  and fe.id = si.id_or_format_estimates
  and f.id = fe.id_format
;

create or replace view v_findinestimate_inorders as
select
--поиск сметы по сметной позиции в сметах по изделиям в заказах
  oi.id as id_order_item,
  e.id as id_estimate,
  oi.slash,
  oi.itemname,
  oi.dt_end,
  bn.name as bcadname,
  nvl(oi.std, 0) as std 
from
  v_order_items oi,   
  estimate_items ei,
  estimates e,
  bcad_nomencl bn
where 
  e.id = ei.id_estimate
  and e.id_order_item = oi.id
  and ei.id_name = bn.id
  --and nvl(oi.std, 0) = 0
;


--общая смета по выбранным заказам
--фактически если надо по нескольким, то делать отсюда выборку и группировку
create or replace view v_aggregate_estimate as (
select
  max(o.id) as id_order,
  e.name, 
  max(e.artikul) as artikul,
  max(e.groupname) as groupname, 
  max(e.unit) as unit, 
  sum(e.qnt) as qnt,
  sum(e.qnt_itm) as qnt_itm
from
  v_estimate_add e,
  orders o,
  order_items i
where
  i.id_order = o.id and
  e.id_order_item = i.id
group by
  e.name, o.id
)  
;

drop view v_aggregate_estimate_or1;
create or replace view v_aggregate_estimate_or1 as (
select
  i.id_order,
  e.name, 
  e.artikul,
  e.id_order_item,
  i.pos,
  e.groupname as groupname, 
  e.unit as unit, 
  e.qnt as qnt,
  e.qnt_itm as qnt_itm
from
  v_estimate_add e,
  v_orders o,
  v_order_items i
where
  i.id_order = o.id and
  e.id_order_item = i.id
)  
;       

--------------------------------------------------------------------------------
create or replace view v_std_items_errors as
select
--проверка несоответствия наименований в сметах отгрузочных стандартных изделий самим изделиям
--проверяем только списки со словом Производство и галкой Учет по СШП для изделий, и сметные позиции,
--начинающиеся с префикса изделий из той же группы но с наименованием Производство
--если в группе изделий будет два списка, включающих слово Производство, вьюха поломается.
  si.id,
  --fep.prefix, fep.id,
  orf.name || ' (' ||  fe.name || ')' as name_format, 
  si.name as name_otgr,
  sip.name as name_prod,
  bn.name as name_est,
  case when substr(bn.name, length(fep.prefix) + 2) <> si.name then 1 else 0 end as err_otgr,
  case when sip.name is null then 1 else 0 end as err_prod
from
  or_std_items si
  inner join or_format_estimates fe
  on lower(fe.name) like '%отгрузка%' and si.id_or_format_estimates = fe.id
  inner join or_formats orf
  on orf.id = fe.id_format and orf.id > 1
  left outer join or_format_estimates fep
  on fep.id_format = fe.id_format and lower(fep.name) like '%производство%'
  inner join estimates e
  on e.id_std_item = si.id
  inner join estimate_items ei
  on ei.id_estimate = e.id
  inner join bcad_nomencl bn
  on bn.id = ei.id_name and bn.name like fep.prefix || '_' || '%'
  left outer join or_std_items sip
  on sip.id_or_format_estimates = fep.id and substr(bn.name, length(fep.prefix) + 2) = sip.name
where
  si.by_sgp = 1 and fep.id is not null and (
  substr(bn.name, length(fep.prefix) + 2) <> si.name
  or sip.name is null
  )
order by 
  name_format, name_otgr
;

--------------------------------------------------------------------------------
--!query
--запрос позиций, по которым сметное наименование соввпадает с наименованием изделия
--для смет по стандартным изделиям для заказов (нарушает расчет цены)
select
  b.name as b_name
from
  v_or_std_items i,
  or_format_estimates fi,
  estimates e,
  estimate_items ei,
  bcad_nomencl b
where
  id_or_format_estimates = fi.id
  and e.id_std_item = i.id
  and ei.id_estimate = e.id
  and b.id = ei.id_name
  and ((b.name = i.name) or (b.name = i.fullname)) 
;

--------------------------------------------------------------------------------

-- ======================================================================
-- функция, возвращающая id сметы для записи estimate_items
-- ======================================================================
create or replace function f_get_dependent_estimate(
  p_id_name in bcad_nomencl.id%type,
  p_id_estimate in estimates.id%type
) return number is
  v_result number;
  v_name bcad_nomencl.name%type;
begin
  --получаем наименование номенклатуры
  select b.name
    into v_name
    from bcad_nomencl b
    where b.id = p_id_name;

  --ищем стандартное изделие по совпадению имени со сметной позицией
  --имя проверяем в том числе и в нестандартных изделиях
  --совпадение отслеживаем как с префиксом так и без префикса изделия
  begin
    select i2.id
      into v_result
      from
        or_std_items i2,
        or_format_estimates fi2
      where
        i2.id_or_format_estimates = fi2.id (+)
        and (
          (case when fi2.id = 0 then '' else fi2.prefix || '_' end) || i2.name = v_name
          or i2.name = v_name
        )
        and rownum = 1;
  exception
    when no_data_found then
      v_result := null;
  end;

  -- если нашли стандартное изделие, ищем смету, которая его использует
  if v_result is not null then
    begin
      select e.id
        into v_result
        from estimates e
        where
          e.id_std_item = v_result
          and e.id <> p_id_estimate
          and rownum = 1;
    exception
      when no_data_found then
        v_result := null;
    end;
  end if;

  return v_result;
end f_get_dependent_estimate;
/


--==============================================================================
--заполним данные для сметных позиций, являющихся сметами
--------------------------------------------------------------------------------
--таблицы для логирования (выполните один раз)
create table temp_upd_est (
  id number,               -- идентификатор обработанной записи estimate_items
  dt date,                 -- дата/время обработки
  processed_by varchar2(30) default user
);

delete from temp_upd_est;

--блок обработки
--при 700000 записей порядка 2ч работы на 11хе
declare
  v_cnt number := 0;
begin
  for rec in (select id, id_name, id_estimate 
                from estimate_items 
                where id_dependent_estimate is null 
                  --and id > 610000
                order by id desc)   -- начинаем с больших id
  loop
    -- обновление текущей записи
    update estimate_items
      set id_dependent_estimate = f_get_dependent_estimate(rec.id_name, rec.id_estimate)
      where id = rec.id;
    
    
    v_cnt := v_cnt + 1;
    
    -- каждые 1000 записей фиксируем изменения и выводим сообщение
    if mod(v_cnt, 1000) = 0 then
      commit;
      -- логирование обработанного id (вставляем в таблицу лога)
      insert into temp_upd_est (id, dt) values (rec.id, sysdate);
      dbms_output.put_line('обработано и зафиксировано: ' || v_cnt);
    end if;
  end loop;
  
  -- финальный коммит для оставшихся записей
  commit;
  dbms_output.put_line('всего обновлено: ' || v_cnt);
end;
/





select 
  e.id_estimate,
  e.id_name,
  ed.id,
  e.name,
  i.fullname 
from 
  v_estimate e, estimates ed, v_or_std_items i
where
 e.id_dependent_estimate is not null
 and ed.id = e.id_dependent_estimate 
 and ed.id_std_item = i.id
 ;
 and e.name <> i.fullname;
 
 and e.id_dependent_estimate = (select f_get_dependent_estimate(2760, 96074) from dual); 
; 

select f_get_dependent_estimate(2760, 96074) from dual;


/*

===============================================================================

*/

--------------------------------------------------------------------------------
-- обновляем связи сметных позиций со стандартными изделиями
-- работает очень быстро!
create or replace procedure p_update_estimate_items_ref as
begin
  -- Сброс всех значений перед пересчётом
  update estimate_items
  set id_or_std_item = null,
      or_std_item_cnt = 0;
  -- Обновление строк, для которых есть совпадения
  merge into estimate_items ei
  using (
    with matches as (
      select 
        ei.id as estimate_item_id,
        i.id as std_item_id,
        case 
          when (case when fi.id = 0 then '' else fi.prefix || '_' end) || i.name = bn.name then 1
          when i.name = bn.name then 2
        end as match_type
      from estimate_items ei
      join bcad_nomencl bn on bn.id = ei.id_name
      cross join or_std_items i
      left join or_format_estimates fi on i.id_or_format_estimates = fi.id
      where ( (case when fi.id = 0 then '' else fi.prefix || '_' end) || i.name = bn.name
              or i.name = bn.name )
    ),
    ranked as (
      select 
        estimate_item_id,
        std_item_id,
        match_type,
        row_number() over (partition by estimate_item_id order by match_type, std_item_id desc) as rn,
        count(*) over (partition by estimate_item_id, match_type) as cnt
      from matches
    )
    select 
      estimate_item_id,
      std_item_id as id_or_std_item,
      cnt as or_std_item_cnt
    from ranked
    where rn = 1
  ) src
  on (ei.id = src.estimate_item_id)
  when matched then
    update set 
      ei.id_or_std_item = src.id_or_std_item,
      ei.or_std_item_cnt = src.or_std_item_cnt;

  commit;
end;
/
exec p_update_estimate_items_ref; 


exec p_update_estimates_depend_dt;

--------------------------------------------------------------------------------
--обновляет рекурсивно дату изменения влияющей сметы для всех смет, если она 
--стала больше текущей.
--влияет создание, изменение, илли иззменение влияющей сметы для той, от кторой завист эта
create or replace procedure p_update_estimates_depend_dt as
  v_updated number;
begin
  for i in 1..10 loop
    v_updated := 0;

    for rec in (
      select
        e.id,
        max(
          greatest(
            nvl(est.dt_create, to_date('1900-01-01', 'yyyy-mm-dd')),
            nvl(est.dt_changed, to_date('1900-01-01', 'yyyy-mm-dd')),
            nvl(est.dt_changed_depend, to_date('1900-01-01', 'yyyy-mm-dd'))
          )
        ) as max_influence_date
      from estimates e
      join estimate_items ei on ei.id_estimate = e.id
      join or_std_items osi on osi.id = ei.id_or_std_item
      join estimates est on est.id_std_item = osi.id
      where ei.id_or_std_item is not null
      group by e.id
    ) loop
      update estimates
      set dt_changed_depend = rec.max_influence_date
      where id = rec.id
        and (rec.max_influence_date <> date '1900-01-01')
        and (dt_changed_depend is null or rec.max_influence_date > dt_changed_depend);
      v_updated := v_updated + sql%rowcount;
    end loop;

    commit;
    exit when v_updated = 0;
  end loop;

  update scheduler_sync_control
  set last_run_at = sysdate
  where job_name = 'p_update_estimates_depend_dt';
  commit;
end;
/


--изменяем информацию по влияющим сметам для данной - есть ли такие, и если есть проставим текущую дату, пори условии что все они существуют
--Сметы, которые стали загружены (loaded=1) и у которых ранее была дата null или 2026-01-01, получат текущую дату.
--Сметы, которые уже имели реальную дату (не 2026-01-01 и не null), сохранят её.
--Сметы с loaded=0 сбрасывают дату в null.
create or replace procedure p_upd_estimates_infl_batch is
  v_now date := sysdate;
  v_updated number;
  c_default_date constant date := date '2026-01-01';
begin
  delete from tmp_estimate_loaded;

  insert into tmp_estimate_loaded (id, loaded)
  select e.id,
         case when (e.id_std_item is not null and nvl(s.wo_estimate, 0) = 1)
               or not exists (
                    select 1
                      from estimate_items ei
                      where ei.id_estimate = e.id
                        and ei.id_or_std_item is not null
                        and exists (select 1 from estimates e2 where e2.id_std_item = ei.id_or_std_item)
                 )
              then 1 else 0 end
    from estimates e
    left join or_std_items s on s.id = e.id_std_item;

  for i in 1..100 loop
    v_updated := 0;
    update tmp_estimate_loaded t
       set t.loaded = 1
     where t.loaded = 0
       and not exists (
         select 1
           from estimate_items ei
           where ei.id_estimate = t.id
             and ei.id_or_std_item is not null
             and exists (select 1 from estimates e2 where e2.id_std_item = ei.id_or_std_item)
             and not exists (
               select 1 from tmp_estimate_loaded ch
                where ch.id = (select e3.id from estimates e3 where e3.id_std_item = ei.id_or_std_item and rownum=1)
                  and ch.loaded = 1
             )
       );
    v_updated := sql%rowcount;
    exit when v_updated = 0;
  end loop;

  merge into estimates e
  using (
    select t.id,
           case when exists (
                select 1 from estimate_items ei
                where ei.id_estimate = t.id
                  and ei.id_or_std_item is not null
                  and exists (select 1 from estimates e2 where e2.id_std_item = ei.id_or_std_item)
                ) then 1 else 0 end as has_inf,
           t.loaded
      from tmp_estimate_loaded t
  ) src
  on (e.id = src.id)
  when matched then
    update set
      e.has_influencing = src.has_inf,
      e.dt_influencing_ready = case 
                                 when src.loaded = 1 and src.has_inf = 1 and (e.dt_influencing_ready is null or e.dt_influencing_ready = c_default_date)
                                   then v_now
                                 when src.loaded = 0 then null
                                 else e.dt_influencing_ready
                               end;
  commit;
end;
/

--------------------------------------------------------------------------------
--Рекурсивная функция проверки загруженности сметы
drop table tmp_estimate_loaded;
create global temporary table tmp_estimate_loaded (
  id number(11),
  loaded number(1),
  dt date,
  primary key (id)
) on commit delete rows;

create global temporary table tmp_estimate_loaded (
  id  number(11) primary key,
  calc_date date
) on commit delete rows;
;

--------------------------------------------------------------------------------
--лог изменений сметы (кто, когда и что изменил в составе/количестве позиций сметы).
--нужен для отслеживания изменений смет как стандартных изделий, так и изделий заказа
--(в т.ч. при обновлении сметы изделия заказа из сметы стандартного изделия).
--
--изменение количества позиций без изменения состава сметы (пересчет qnt/qnt_itm от
--qnt1/qnt1_itm при изменении количества изделия в заказе, см. p_CorrectEstimateQnt)
--НЕ логируется - см. явное указание в постановке задачи.
--
--source - источник/повод изменения сметы: список кодов через запятую (за одно редактирование
--может быть использовано несколько каналов - например, загрузка из xls с последующей ручной
--правкой нескольких позиций); коды не меняются, просто теперь их может быть несколько сразу -
--см. TEstDlgChannel.SourceUsed/EstDlgChannelAddSource/TFrmOGedtEstimate.MarkManualInputChannel
--в uFrmOGedtEstimate.pas. Расшифровка кодов в текст - на стороне просмотрщика истории изменений
--сметы (uFrmOWrepEstimateChanges.pas), не в БД:
--  0 - первичная загрузка сметы (смета была пуста, isempty/нет позиций)
--  1 - загрузка из xls-файла (Bt_LoadClick в старом диалоге)
--  2 - копирование из "буфера" - временной сметы пользователя (estimates.id_buffer,
--      см. Bt_PasteEstimateClick/Bt_CopyEstimateClick в старом диалоге)
--  3 - ручное редактирование состава сметы в диалоге (см. MarkManualInputChannel)
--  4 - обновление сметы изделия заказа при обновлении из сметы стандартного изделия
--      (RefreshEstimatesToOrder/LoadEstimate, ветка IsOrItemStd; P_CreatePspForSemiproducts)
--для source, содержащего любой из кодов 1,2,3,4, если смета не была пуста, changes должен содержать сравнение
--входного и выходного массивов по наименованию (без учета группы), формат по строкам:
--  <наименование> <ед.изм.> <кол-во> - добавлено
--  <наименование> <ед.изм.> <кол-во> - удалено
--  <наименование> <ед.изм.> <кол-во было> -> <кол-во стало>
--для source = 0 достаточно зафиксировать сам факт первичной загрузки (changes может
--быть пустым либо содержать перечень загруженных позиций - уточняется).
--таблица estimate_change_log
--лог изменений сметы: пользователь, время, источник изменения (первичная загрузка/xls/
--буфер/ручное редактирование/обновление из сметы стандартного изделия) и текст диффа
create table estimate_change_log ( --$+
  id number(11),
  id_estimate number(11),                      --смета, к которой относится изменение
  dt date,                                      --дата/время изменения, проставляется триггером
  id_user number(11),                           --пользователь, выполнивший изменение
  source varchar2(50),                           --источник изменения (список кодов через запятую), см. константы выше
  changes clob,                                 --текст изменений, см. формат выше
  constraint pk_estimate_change_log primary key (id),
  constraint fk_estimate_change_log_est foreign key (id_estimate) references estimates(id) on delete cascade,
  constraint fk_estimate_change_log_user foreign key (id_user) references adm_users(id)
);

--$go begin
--миграция source: number(2) с одним кодом -> varchar2(50) со списком кодов через запятую;
--через modify не проходит (ORA-01439 - таблица уже не пустая, лог уже накапливался), поэтому
--через промежуточный столбец
alter table estimate_change_log add source_txt varchar2(50);
update estimate_change_log set source_txt = to_char(source);
alter table estimate_change_log drop column source;
alter table estimate_change_log rename column source_txt to source;
!rebuild v_estimate_change_log
--$go end

create index idx_estimate_change_log_est on estimate_change_log(id_estimate, dt); --$+

create sequence sq_estimate_change_log start with 100 nocache; --$+

create or replace trigger trg_estimate_change_log_bi_r before insert on estimate_change_log for each row --$+
begin
  if nvl(:new.id, 0) > -1 then
    :new.id := sq_estimate_change_log.nextval;
  end if;
  :new.dt := nvl(:new.dt, sysdate);
end;
/

create or replace view v_estimate_change_log as select --$+
--лог изменений сметы с именем пользователя, сделавшего изменение
  l.*,
  u.name as username
from
  estimate_change_log l,
  adm_users u
where
  l.id_user = u.id (+)
;

--------------------------------------------------------------------------------
--ЗАГЛУШКА. Проверка корректности сметной позиции "на лету", при вводе/выборе значения
--в поле Наименование в новом диалоге сметы (uFrmOGedtEstimate). Заменит со временем
--текущую проверку в p_test_estimate_item (которая пока не трогается и по-прежнему
--вызывается из VerifyRow в диалоге без изменений).
--
--правила (уточняются, будут дописаны позже отдельным заданием):
--  - в производственном изделии нельзя использовать отгрузочное изделие как сметную позицию;
--  - сметная позиция-изделие (производственное/отгрузочное) выбирается только из подгруппы
--    производственных той же группы (той же group/format) - можно ли из другой подгруппы
--    той же группы, можно ли с тем же наименованием, что и контейнер - уточняется;
--  - полуфабрикат можно выбирать из подгрупп типа "полуфабрикат" из любой группы (формата);
--  - в смете нестандартного изделия заказа стандартных изделий, по-видимому, быть не может,
--    но полуфабрикат может (уточняется).
create or replace procedure p_check_estimate_item( --$-
--заглушка: проверка корректности сметной позиции "на лету" по контексту контейнера, правила будут дописаны позже
  p_id_container_std_item in  number,   --айди контейнерного стандартного изделия (владельца сметы), null - смета нестандартного изделия заказа
  p_container_type        in  number,   --тип контейнера: 0-производственное,1-отгрузочное,2-полуфабрикат; null - нестандартное изделие заказа
  p_group_id               in  number,  --айди группы бкад введенной/выбранной позиции
  p_name                   in  varchar2,--введенное или полученное из справочника наименование позиции
  p_id_or_std_item         in  number,  --айди стандартного изделия/полуфабриката, если позиция выбрана из справочника (не введена текстом), иначе null
  p_status                out varchar2, --'OK' / 'WARNING' / 'ERROR'
  p_errtext                out varchar2 --текст сообщения для пользователя, пусто - если ошибок/предупреждений нет
) is
begin
  --TODO: реализовать правила выше, когда они будут окончательно согласованы.
  p_status := 'OK';
  p_errtext := '';
end;
/
