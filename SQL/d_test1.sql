create table turtles 
as
select '��������' name, '�����' essence from dual union all
select '��������', '��������' from dual union all
select '�������', '��������' from dual union all
select '������������', '��������'  from dual union all
select '���������', '��������'  from dual;


drop trigger tr_turtles_ue;
create or replace trigger tr_turtles_ue
  for update of essence
  on turtles
  compound trigger
    bUpdPainters  boolean;
 
  before each row is
  begin
    if :new.name = '��������' and :old.essence = '�����' and :new.essence = '������' then
      bUpdPainters := true;
    end if;
  end before each row;
  
  after statement is
  begin
    if bUpdPainters then
      update Turtles
         set essence = '������'
       where essence = '��������';
    end if;
  end after statement;
end tr_turtles_ue; 


update turtles
   set essence = '������'
 where name = '��������';
 
 
 
 
------------------------------------------------------------------------------- 
create or replace package pkg_around_mutation 
is
  bUpdPainters boolean;
  procedure update_painters;  
end pkg_around_mutation;
/

create or replace package body pkg_around_mutation
is
  procedure update_painters
  is
  begin   
    if bUpdPainters then
      bUpdPainters := false;
      update turtles
         set essence = '������'
       where essence = '��������';
    end if;
  end;  
end pkg_around_mutation;
/

create or replace trigger tr_turtles_bue
before update of essence
on turtles
for each row
when (
  new.name = '��������' and old.essence = '�����' and new.essence = '������' 
)
begin
  pkg_around_mutation.bUpdPainters := true;  
end tr_turtles_bue; 
/

create or replace trigger tr_turtles_bu
after update
on turtles
begin
  pkg_around_mutation.update_painters;  
end tr_turtles_bu;
/ 
