
Alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
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
--alter table estimates add constraint fk_estimates_std_item foreign key (id_std_item) references or_std_items(id) on delete cascade;
--alter table estimates add dt_changed date;
--alter table estimates add dt_create date;
--alter table estimates add dt_changed_depend date;
create table estimates(
  id number(11),
  id_std_item number(11) unique,              --айди стандартного изделия
  id_order_item number(11) unique,            --айди позиции в заказе (оба поля одновременно не могут быть заданы!)
  id_buffer number(11) unique,                 
  dt date,                                    --дата создания сметы
  dt_create date,                             --дата создания, со временем, фиксируется триггером   
  dt_changed date,                            --дата изменения (вставка/удалени позиций, изменение наименования или количества), со временем, фиксируется триггером
  dt_changed_depend date,                     --дата изменения смет, от которой зависит эта
  isempty number(1) default 0,                --признак того, что смета является пустой 
  constraint pk_estimates primary key (id),
  constraint fk_estimates_std_item foreign key (id_std_item) references or_std_items(id) on delete cascade,
  constraint fk_estimates_order_item foreign key (id_order_item) references order_items(id) on delete cascade
);  


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
  contract number(1) default 0,                --подрядный полуфабрикат
  qnt1 number(15,5),                           --количество на одно изделие, по учету
  qnt number(15,5),                            --количество на все изделия, по учету, только для заказов 
  qnt1_itm number(15,5),                       --количество на одно изделие, по итм
  qnt_itm number(15,5),                        --количество на все изделия, по итм, только для заказов 
  qnt_itm_last number(15,5) default null,      --последнее переданное в итм количество по данной позиции, только для заказов
  id_dependent_estimate number(11),            --ссылка на другую смету, которая использует данную позицию как вложенное изделие (заполняется автоматически) 
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
create or replace trigger trg_estimate_items_aiud_r
  after insert or update or delete on estimate_items
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
create or replace trigger trg_estimate_items_master
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

create or replace procedure p_CreateEstimateItem(
  pid_estimate number,                      --родительская смета
  pid_group number,                         --группа бкад
  pname varchar2,                          --наименование бкад
  pid_unit number,                          --единица измерения
  pcomment varchar2,                       --комментарий из сметы
  pqnt1 number,                           --количество на одно изделие
  pqnt number                            --количество на все изделия   no use
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
  update estimate_items set id_group = pid_group, id_unit = pid_unit, id_comment = idcommentitem, qnt1 = pqnt1, qnt = qntall, qnt1_itm = pqnt1, qnt_itm = qntall, deleted = 0
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
      select max(id) into PId from estimate_items where id_estimate = IdEstimate and id_name = IdNameNew and qnt1 is not null;
      if PId is not null then
        update estimate_items set qnt1_itm = qnt1_itm + PQnt1, qnt_itm = qnt_itm + PQnt where id = PId;
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

create or replace procedure P_CopyEstimate ( 
--копируем смету на стандартное изделие в записи для заказа
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


create or replace procedure P_SendEstimateToItm (
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

create or replace view v_estimate as
select
  ei.*,
  bn.name as bname,
  case
    when si.name is not null
      then decode(fe.prefix, '', '', fe.prefix || '_') || si.name
    else bn.name
  end as name,
  bg.name as groupname,
  bu.name as unit,
  bc.name as comm,
  fe.prefix,
  e.id_order_item,
  e.id_std_item,
  prc.price,
  ei.qnt1_itm * nvl(prc.price, 0) as sum1,
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

create or replace view v_estimate_for_edit_dlg as --!!!
select
--вью для редактора сметы
  e.*,
  case when e.id_or_std_item is not null then 1 else 0 end as is_std_item,
  n.artikul,
  s.qnt as qnt_on_stock
from
  v_estimate e,
  dv.nomenclatura n,
  v_spl_qntonstocks_sum_2 s
where
  e.name = n.name (+)
  and e.name = s.name (+) 
;

alter table estimate_items drop column id_name_resale;


select * from v_estimate where bname is null;
select * from v_estimate where id = 115201;
delete from estimate_items t where t.ID_NAME is null;

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
create or replace procedure p_update_estimates_depend_dt is
-- процедура обновления поля dt_changed_depend в таблице estimates
-- находит все сметы, которые зависят от изменённых смет (через цепочку стандартных изделий)
-- и проставляет им текущую дату в dt_changed_depend
-- запускается по расписанию (раз в 5 мин)
  v_last_run date;
  v_now      date := sysdate;
  v_root_id  estimates.id%type;
  cursor c_changed is
    select id from estimates where dt_changed > v_last_run;
  cursor c_deps(p_child_id number) is
    select distinct connect_by_root child_id as root_id
    from (
      select ei.id_estimate as parent_id, ei.id_dependent_estimate as child_id
      from estimate_items ei
      where ei.id_dependent_estimate is not null
    )
    start with child_id = p_child_id
    connect by nocycle prior parent_id = child_id;
begin
  -- получить время последнего запуска (как выше)
  begin
    select last_run_at into v_last_run
      from scheduler_sync_control
      where job_name = 'p_update_estimates_depend_dt';
  exception
    when no_data_found then
      insert into scheduler_sync_control (job_name, last_run_at)
        values ('p_update_estimates_depend_dt', date '1900-01-01');
      commit;
      v_last_run := date '1900-01-01';
  end;

  for ch in c_changed loop
    for dep in c_deps(ch.id) loop
      update estimates
        set dt_changed_depend = v_now
        where id = dep.root_id
          and (dt_changed_depend is null or dt_changed_depend < v_now);
    end loop;
  end loop;

  update scheduler_sync_control
    set last_run_at = v_now
    where job_name = 'p_update_estimates_depend_dt';

  commit;

exception
  when others then
    rollback;
    raise;
end p_update_estimates_depend_dt;
/

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


--------------------------------------------------------------------------------
--обновляем поле, содержащее айди сметы, зависящей от данной позиции
--работает быстро
create or replace procedure p_update_dependent_estimate as
begin
  -- сбрасываем старые значения
  update estimate_items set id_dependent_estimate = null;

  -- для каждой позиции, которая является стандартным изделием,
  -- находим смету (id_estimate), в которой это изделие используется как комплектующее
  merge into estimate_items ei
  using (
    select
      ei.id as item_id,
      max(ei2.id_estimate) as dep_est_id
    from estimate_items ei
    join estimate_items ei2 on ei2.id_or_std_item = ei.id_or_std_item
    where ei.id_or_std_item is not null
      and ei2.id_estimate != ei.id_estimate   -- не та же самая смета
    group by ei.id
  ) src
  on (ei.id = src.item_id)
  when matched then
    update set ei.id_dependent_estimate = src.dep_est_id;

  commit;
end;
/

exec p_update_dependent_estimate;


--update estimates set dt_changed_depend = null;;


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



    




