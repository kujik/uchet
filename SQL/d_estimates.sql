
Alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
alter session set nls_sort =  binary;



--+++++++++++
--������� ����� ���������� bCAD
--������ ������ ��������� ������� ����� ����������, ��� �������� ����� ��������������
--������ ������� ������
--alter table bcad_groups add is_semiproduct number(1) default 0; 
create table bcad_groups(
  id number(11),
  name varchar2(1000) unique not null,     --������������
  is_production number(1) default 0,       --��� ������, ���������� ������� �������  
  is_semiproduct number(1) default 0,       --��� ������, ���������� �������������  
  constraint pk_bcad_groups primary key (id)
);

create sequence sq_bcad_groups start with 100 nocache;
 
insert into bcad_groups (id, name) values (1, '��');
insert into bcad_groups (id, name) values (2, '��');
insert into bcad_groups (id, name) values (3, '������: ��������� ������');
insert into bcad_groups (id, name) values (4, '������: ��������� ������');

create or replace trigger trg_bcad_groups_bi_r before insert on bcad_groups for each row
begin
  if :new.id is null then
    select sq_bcad_groups.nextval into :new.id from dual;
  end if;
end;
/

--������� ��������� bCad
create table bcad_units(
  id number(11),
  name varchar2(50) unique not null,     --������������
  constraint pk_bcad_units primary key (id)
);

create sequence sq_bcad_units start with 100 nocache;
 
insert into bcad_units (id, name) values (1, '��.');

create or replace trigger trg_bcad_units_bi_r before insert on bcad_units for each row
begin
  if :new.id is null then
    select sq_bcad_units.nextval into :new.id from dual;
  end if;
end;
/

--������������ ���������� bCad (� �� ����, ������� ��� � bCad)
--������� ������ ������������, ��� �������� ����� � ������ �������������!
--�� ������ ������������ ��� ����� ��������!
create table bcad_nomencl(
  id number(11),
  name varchar2(1000) unique not null,     --������������
  constraint pk_bcad_nomencl primary key (id)
);

--create unique index idx_bcad_nomencl on bcad_nomencl(lower(name)); 

create sequence sq_bcad_nomencl start with 100 nocache;

create or replace trigger trg_bcad_nomencl_bi_r before insert on bcad_nomencl for each row
begin
  select sq_bcad_nomencl.nextval into :new.id from dual;
end;
/

--����������� � �������� �� ������ ����
create table bcad_comments(
  id number(11),
  name varchar2(1000) unique not null,     --������������
  constraint pk_bcad_comments primary key (id)
);

--create unique index idx_bcad_comments on bcad_comments(lower(name)); 

create sequence sq_bcad_comments start with 100 nocache;

create or replace trigger trg_bcad_comments_bi_r before insert on bcad_comments for each row
begin
  select sq_bcad_comments.nextval into :new.id from dual;
end;
/

--��� ����������� ������������ ����
--������� �������, �������������� � ������, �� ������ ������� bcad_nomencl
--�������������� ���������, ��� ������, ��.��� � �������, �������� � ���������� ����� � � bcad_nomencl �� ���������,
--������ ������� ��������� (������������ ��� ������� ������������) ��� ��������� �� ������ ������������ ����  
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




--������� ���������� ������� � ������ ��� �� �������� � ���
create table ref_estimate_replace(
  id_old number(11) not null,           --���� ���������� �������
  id_new number(11),                    --���� ����� �������, ��� null, ���� ������� ���� ������ �������
  constraint pk_ref_estimate_replace primary key (id_old),
  constraint fk_ref_estimate_replace_old foreign key (id_old) references bcad_nomencl(id) on delete cascade,
  constraint fk_ref_estimate_replace_new foreign key (id_new) references bcad_nomencl(id) on delete cascade
);

--��� ��� ������� ���������� ����
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

--��� ����������� ������ ������������
--��� ��� ������, �������, ����������� � ��� �� ���������
--(� ��������� � ������� �������� � ������ �����)
--�� ���� �� �� �����
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

--������� ����� �� ������� ������ ��� ����������� �������
--�� ������ ������� ����� ���� ������ ���� ������ � ���� �������
--alter table estimates add constraint fk_estimates_std_item foreign key (id_std_item) references or_std_items(id) on delete cascade;
--alter table estimates add isempty number(1) default 0;
alter table estimates add id_buffer number(11) unique;
create table estimates(
  id number(11),
  id_std_item number(11) unique,              --���� ������������ �������
  id_order_item number(11) unique,            --���� ������� � ������ (��� ���� ������������ �� ����� ���� ������!)
  id_buffer number(11) unique,                 
  dt date,                                    --���� �������� �����
  isempty number(1) default 0,                --������� ����, ��� ����� �������� ������ 
  constraint pk_estimates primary key (id),
  constraint fk_estimates_std_item foreign key (id_std_item) references or_std_items(id) on delete cascade,
  constraint fk_estimates_order_item foreign key (id_order_item) references order_items(id) on delete cascade
);  

create sequence sq_estimates start with 100 nocache;

create or replace trigger trg_estimates_bi_r before insert on estimates for each row
begin
  if nvl(:new.id, 0) > -1 then 
    select sq_estimates.nextval into :new.id from dual;
  end if;
end;
/


--������� � �����
--alter table estimate_items drop column id_name_resale_std;
--alter table estimate_items add contract number(1) default 0;
--alter table estimate_items add  constraint fk_estimate_items_std foreign key (id_or_std_item) references or_std_items(id);
create table estimate_items(
  id number(11),
  id_estimate number(11),                      --������������ �����
  id_or_std_item number(11),                   --���� ������������ �������, ���� ����� �������� ����������� ��������
  id_group number(11),                         --������ ����
  id_name number(11),                          --������������ ����
  id_unit number(11),                          --������� ���������
  id_comment number(11),                       --����������� �� �����
  contract number(1) default 0,                --��������� ������������
  qnt1 number(15,5),                           --���������� �� ���� �������, �� �����
  qnt number(15,5),                            --���������� �� ��� �������, �� ����� 
  qnt1_itm number(15,5),                       --���������� �� ���� �������, �� ���
  qnt_itm number(15,5),                        --���������� �� ��� �������, �� ��� 
  qnt_itm_last number(15,5) default null,      --��������� ���������� � ��� ���������� �� ������ ������� 
  deleted number(1) default 0,                 --�������, ��� ������ ������� ������� (=1)
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

--�� p�������� ����� � ����� �� ������ �������/����� ��������� ���������� ������������!!!
create unique index idx_estimate_items_estname_uq on estimate_items(id_estimate, id_name);

create sequence sq_estimate_items start with 100 nocache;

create or replace trigger trg_estimate_items_bi_r before insert on estimate_items for each row
begin
  select sq_estimate_items.nextval into :new.id from dual;
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
    insert into estimate_items (id_estimate, id_group, id_name, id_unit, qnt1, id_comment)
      select -AIdUser, id_group, id_name, id_unit, qnt1, id_comment from v_estimate where id_std_item = AIdStdItem;
  elsif AIdOrItem is not null then  
    insert into estimate_items (id_estimate, id_group, id_name, id_unit, qnt1, id_comment)
      select -AIdUser, id_group, id_name, id_unit, qnt1, id_comment from v_estimate where id_order_item = AIdOrItem;
  end if;
end; 
/ 

call P_CopyEstimateToUserTemp(33,0,0);

--------------------------------------------------------------------------------
create or replace procedure p_createbcadnamecomm(
--�������� ������ � �������� ������������ � ����������� ���� ��� ����
--������ ���� ��������� ���� �������� �������
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
  pid_estimate number,                      --������������ �����
  pid_group number,                         --������ ����
  pname varchar2,                          --������������ ����
  pid_unit number,                          --������� ���������
  pcomment varchar2,                       --����������� �� �����
  pqnt1 number,                           --���������� �� ���� �������
  pqnt number                            --���������� �� ��� �������   no use
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
  --������ � ������������ ������� - ������ ����
  begin
    select id_order_item, id_std_item into idorderitem, idstditem from estimates where id = pid_estimate;
  exception
    when no_data_found then Return;
  end;
  isstdoritem := null;
  qntall := null;
  qntinor := 1;
  if idstditem is null then 
    --��� ������� � ������ 
    select std, qnt into isstdoritem, qntinor from order_items where id = idorderitem;
    --��� ����������� ������� � ������
    if isstdoritem = 1 then 
      Return;
    end if;
    --� ���� ������� ������� ���������� �� ������ ������� - �� ������� �����
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

--++ ��������� ��������� ����� � ������ ����������� ����������
create or replace procedure P_CorrectEstimateWithReplace (
--������������ ��������� ����� � ������ ������ ����������
--���������� � ����� ����������� ��� ����� � ��� ���������
--���� ������� � ����� ������� � ������ ����������, �� ��� ����� ������� ���������� � ����� ��� ��� ������������� � null
--���� ���� ���� �� ������� ��������, �� �������� �����, ���� �� ����� ������� ��� � ������ �����, � ������ ���������� ��������� � ��� ���������� ����� ���������� ���
--� ������ ����������� � ����� �������, �� ������� ��������, �� ��������� �� � ���������� ����������� ��� ���, � ����������� ��� ����� ������ null
--!����� ����������� �������� ���� ���� ���������� ������ ����� (���������� ����� � ����� id_name), ��������� � �������� - ��� �� ��������� �������������
  IdEstimate in number       --������ � estimates
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
--�������� ����� �� ����������� ������� � ������ ��� ������
  IdEstimate in number,       --������ � estimates ������ ���� �������
  IdStdEstimate in number,    --���� �����������, �� ������� ��������
  OrQnt in number             --���������� ������� � ������ 
)  
is
  cursor c1 is
    select
      id_group, id_name, id_unit, id_comment, qnt1, qnt1_itm        
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
  st varchar2(400);
begin
  update estimate_items set deleted = 1 where id_estimate = IdEstimate;
  open c1;
  loop
    fetch c1 into IdGroup, IdName, IdUnit, IdComment, PQnt1, PQnt1_Itm;
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
      QntAll := Ceil(PQnt1 * OrQnt * 10) / 10; 
    end if;
    QntAll_Itm := null;
    if (OrQnt is not null)and(PQnt1_Itm is not null) then
      QntAll_Itm := Ceil(PQnt1_Itm * OrQnt * 10) / 10; 
    end if;
    update estimate_items 
      set id_group = IdGroup, id_unit = IdUnit, id_comment = IdComment, qnt1 = PQnt1, qnt = QntAll, qnt1_itm = PQnt1_Itm, qnt_itm = QntAll_ITM, deleted = 0
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
--�������� ����� � ���
  IdEstimate in number,       --������ � estimates � �����
  IdZakaz in number,          --���� ������ � ���
  IdParentIzdel in number,    --���� ������� � ��� 
  ResCount out number)        --��������, ������� ����������� ����� 
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
  --��������� ���� ��� ������� ����� �� ������� ������� � ���, ��� ������������ �������� �������, ������� ����� ���
  update dv.nomenclatura_in_izdel niz
    set niz.checked=1
    where niz.id_zakaz=IdZakaz
      and niz.id_nomizdel_parent_t=IdParentIzdel
      and niz.id_nominizdel <> IdParentIzdel;
  --��������� ������� ������� � ���
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
  --������ �� ��� �������, ������� ��� ����� � �����
  delete from dv.nomenclatura_in_izdel niz
    where niz.checked=1 and niz.id_zakaz=IdZakaz and niz.id_nomizdel_parent_t=IdParentIzdel;
  insert into adm_db_log (itemname, comm) values ('P_SendEstimateToItm ', 'id_zakaz ' || IdZakaz || '; id_parent_izdel ' || IdParentIzdel || '  ���=' || FlagCnt);
end;
/ 

create or replace procedure P_CorrectEstimateQnt (
--����������� ���������� � ����� ��� ������ ������� � ������,
--���� � ������ ���������� = 0, �� ������� ��� ����� �� ��������
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



create or replace procedure P_DeleteFreeEstimate (
--������ ������ �� �����, � ������� ��� �������, ���� ������ ��� �� ���������� ��� ������ �����
  IdEstimate in number
)   
is
begin
  delete from estimates where id = IdEstimate and isempty <> 1 and (select count(*) from estimate_items where id_estimate = IdEstimate) = 0;
end;  



create or replace function F_TestEstimateItem(
--�������� ������������ � ������� ������� �������, ������ � ������
--1� ������ = 0 ���� ��� ����� ������ � ����������� ������������ ����
--2� ������ = 0 - ������ ��� ������������ �� ������ ������� - ��� ������ ������� � v_or_std_items
--3� ������ = 0 - ������ ��� ������������ �� ������ ������� ������� ���� - ������������ ������� � ������ �������, ��� ���� ������� ���������� �������� ������ 
  GroupId number,                         --������ ����
  Pname varchar2                          --������������ ����
) 
return varchar2
is 
  isprod number(1);            --��� ������� (�� �������� ������)
  isnew number(1);             --0, ���� ��� ����� ��������
  isproderr number(1);         --���� ������� � ������ �������, � �� ������� � ������ ������� � ������ ��������
  isbcaderr number(1);         --���� ������� � ������ ������������ �� ����, � ������� � ������ ������� � ������ ��������
  cnt number(1); 
begin
  --select count(*) into isnew from bcad_nomencl where name = Pname; 
  select nvl(is_production,0) into isprod from bcad_groups where id = GroupId;
  isproderr:=1;
  isbcaderr:=1;
  select count(*) into cnt from v_or_std_items where fullname = Pname;
  --������� ����������� ������ ���� � ����������� ����������� (� ������������� ��� ��) �������
  if isprod = 1 and cnt <> 1 then 
    isproderr :=0;
  end if;
  if isprod = 0 and cnt <> 0 then 
  --�������� �� ����� ���� �������� 
    isbcaderr :=0;
  end if;
  if isprod = 1 then 
    --��������� ������� �� ���� �����
    select count(*) into isnew from bcad_nomencl where name = Pname; 
  else 
    --��������� ��������� �� ���� ���
    select count(*) into isnew from dv.nomenclatura where name = Pname and id_nomencltype = 0; 
  end if;
  return isnew || isproderr || isbcaderr;
end;
/



create or replace function F_TestEstimateItem_New(
--�������� ������������ � ������� ������� �������, ������ � ������
--1� ������ = 0 ���� ��� ����� ������ � ����������� ������������ ����
--2� ������ = 0 - ������ ��� ������������ �� ������ ������� - ��� ������ ������� � v_or_std_items
--3� ������ = 0 - ������ ��� ������������ �� ������ ������� ������� ���� - ������������ ������� � ������ �������, ��� ���� ������� ���������� �������� ������ 
  AGroupId number,                         --������ ����
  Aname varchar2,                         --������������ ����
  AGroupStd number                         --������ ������ �������, �� �������� �����
) 
return varchar2
is 
  Fisprod number(1);            --��� ������� (�� �������� ������)
  Fissem  number(1);            --��� ������������  
  FCnt number;
  FCnt2 number;
  FIdFormat number;
begin
  --select count(*) into isnew from bcad_nomencl where name = Pname; 
  select is_production, is_semiproduct into Fisprod, Fissem from bcad_groups where id = AGroupId;
  select count(*), nvl(max(id_format), -1) into FCnt, FIdFormat from v_or_std_items where fullname = Aname and type = 0 and id_format <> 0;
  if Fcnt <> 0 and Fisprod = 0 then
    return '1-������ ������� �������� ��������!';
  end if;
  if Fcnt <> 0 and FIdFormat <> AGroupStd then
    return '1-������� �� ���� ������ ����������� � ���� �����!';
  end if;
  select count(*), nvl(max(id_format), -1) into FCnt, FIdFormat from v_or_std_items where fullname = Aname and type = 2;
  if Fcnt <> 0 and Fissem = 0 then
    return '1-������ ������� �������� ��������������!';
  end if;
  if Fcnt <> 0 and not (FIdFormat = AGroupStd or FIdFormat = 1) then
    return '1-������������ �� ���� ������ ���������� � ���� �����!';
  end if;
  if (Fisprod = 1 or Fissem = 1) and FCnt = 0 then
    return '2-��� ������� ���������� ������ � ���������� ����������� �������!';
  end if;
  if Fisprod = 1 and FCnt <> 0 then
    select count(*) into FCnt2 from estimates where id_std_item = (select id from v_or_std_items where fullname = Aname);
    if FCnt2 = 0 then
      return '3-� ����� ������� ������ ���� ���������� �����!';
    end if;
  end if;
  if Fissem = 1 and FCnt <> 0 then
    select count(*) into FCnt2 from estimates where id_std_item = (select id from v_or_std_items where fullname = Aname);
    if FCnt2 = 0 then
      return '3-� ����� ������������� ������ ���� ���������� �����!';
    end if;
  end if;
  if (Fisprod = 0 and Fissem = 0) then
    select count(*) into FCnt2 from dv.nomenclatura where name = Aname and id_nomencltype = 0; 
    if FCnt2 = 0 then
      return '0-��������! ���� ������� ��� ��� � ���� ���!';
    end if;
  end if;
  return '';
end;
/



--------------------------------------------------------------------------------
/*
create or replace view v_estimate as (
  select
    ei.*,
    bn.name as bname,
    (case 
      when bn.name is not null then bn.name else si.name end
    ) as name,
    (case 
      when si.name is not null 
        then decode(fe.prefix, '', '', fe.prefix || '_') || si.name
        else bn.name
      end 
    ) as fullname,
    bg.name as groupname,
    bu.name as unit,
    bc.name as comm,
    fe.prefix as prefix,
    e.id_order_item,
    e.id_std_item,
    prc.price,
    prc.sum as sum1
  from
    estimate_items ei,
    bcad_nomencl bn,
    bcad_units bu,
    bcad_comments bc,
    bcad_groups bg,
    or_std_items si,
    or_std_items sii,
    or_format_estimates fe,
    v_fin_estitem_raw_prices prc,    
    estimates e
  where
    ei.id_name = bn.id (+) and
    ei.id_name_resale = si.id (+) and
    ei.id_unit = bu.id (+) and
    ei.id_comment = bc.id (+) and
    ei.id_group = bg.id (+) and
    si.id_or_format_estimates = fe.id (+) and
    ei.id_or_std_item = sii.id (+) and
    ei.id = prc.id (+) and
    ei.id_estimate = e.id
);
*/

create or replace view v_estimate as (
  select
    ei.*,
    bn.name as bname,
    (case 
      when si.name is not null 
        then decode(fe.prefix, '', '', fe.prefix || '_') || si.name
        else bn.name
      end 
    ) as name,
    --!!!decode(fe.type, null, bg.name, 2, (select name from bcad_groups t where t.id = 2), (select name from bcad_groups t where t.id = 104)) as groupname, 
    bg.name as groupname,
    bu.name as unit,
    bc.name as comm,
    fe.prefix as prefix,
    e.id_order_item,
    e.id_std_item,
    prc.price,
    prc.sum as sum1,
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
    v_fin_estitem_raw_prices prc,    
    estimates e
  where
    ei.id_name = bn.id (+) and
    ei.id_unit = bu.id (+) and
    ei.id_comment = bc.id (+) and
    ei.id_group = bg.id (+) and
    si.id_or_format_estimates = fe.id (+) and
    ei.id_or_std_item = si.id (+) and
    ei.id = prc.id (+) and
    ei.id_estimate = e.id
);


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
--����� ����� �� ������� ������� � ������ ����������� �������
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
--����� ����� �� ������� ������� � ������ �� �������� � �������
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


--����� ����� �� ��������� �������
--���������� ���� ���� �� ����������, �� ������ ������ ������� � �����������
create or replace view v_aggregate_estimate as (
select
  max(o.id) as id_order,
  e.name, 
  max(e.groupname) as groupname, 
  max(e.unit) as unit, 
  sum(e.qnt) as qnt,
  sum(e.qnt_itm) as qnt_itm
from
  v_estimate e,
  v_orders o,
  v_order_items i
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
  e.id_order_item,
  i.pos,
  e.groupname as groupname, 
  e.unit as unit, 
  e.qnt as qnt,
  e.qnt_itm as qnt_itm
from
  v_estimate e,
  v_orders o,
  v_order_items i
where
  i.id_order = o.id and
  e.id_order_item = i.id
)  
;       




select 1 as id, max(groupname) as groupname, max(name) as name, max(unit) as unit, sum(qnt) as qnt, 0 as chb from v_aggregate_estimate_or1 where pos in (1,4) group by name;

select to_char(rownum) as id, max(groupname) as groupname, max(name) as name, max(unit) as unit, sum(qnt) as qnt, 0 as chb from v_aggregate_estimate_or1 where pos in (1,4) and id_order = 1234 group by name;

 
        

select * from v_aggregate_estimate_or1 where id_order = 1199 and id_order_item = 35127;
--select * from v_estimate;-- where id_order = 180;
  


select name from dv.nomenclatura where id_nomencl = 14984;


select id;groupname;name;unit;qnt1;qnt;comm from v_estimate where deleted = 0 and id_order_item = :id$i

id_zakaz = 7290
id_nominizdel = 15066
id_nomencl = 15004 ������� � �����

declare
IdSpec number;
begin
--P_DeleteFreeEstimate(123);
--      DV.P_SyncSpecIzdel(IdZakaz, IdParentIzdel, FullName, Unit, Qnt, Comment, IdSpec);
--      DV.P_SyncSpecIzdel(7290, 15066, '����1', '��.', 2, 10, IdSpec);
end;
/      

SELECT ceil(0.009*10)/10 "Round" FROM DUAL;
select * from dv.nomenclatura_in_izdel where id_zakaz = 7294; --15023
--� �������� ������������ (������� �������) ���� id_nomizdel_parent_t <> null

select * from estimate_items where id = 10570;

select to_char(rownum) as id, groupname, name, unit, qnt from v_aggregate_estimate where id_order = 180;






create or replace view v_std_items_errors as
select
--�������� �������������� ������������ � ������ ����������� ����������� ������� ����� ��������
--��������� ������ ������ �� ������ ������������ � ������ ���� �� ��� ��� �������, � ������� �������,
--������������ � �������� ������� �� ��� �� ������ �� � ������������� ������������
--���� � ������ ������� ����� ��� ������, ���������� ����� ������������, ����� ����������.
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
  on lower(fe.name) like '%��������%' and si.id_or_format_estimates = fe.id
  inner join or_formats orf
  on orf.id = fe.id_format and orf.id > 1
  left outer join or_format_estimates fep
  on fep.id_format = fe.id_format and lower(fep.name) like '%������������%'
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

















select * from or_std_items;



