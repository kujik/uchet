create table turtles 
as
select 'Сплинтер' name, 'Крыса' essence from dual union all
select 'Леонардо', 'Художник' from dual union all
select 'Рафаэль', 'Художник' from dual union all
select 'Микеланджело', 'Художник'  from dual union all
select 'Донателло', 'Художник'  from dual;


drop trigger tr_turtles_ue;
create or replace trigger tr_turtles_ue
  for update of essence
  on turtles
  compound trigger
    bUpdPainters  boolean;
 
  before each row is
  begin
    if :new.name = 'Сплинтер' and :old.essence = 'Крыса' and :new.essence = 'Сэнсэй' then
      bUpdPainters := true;
    end if;
  end before each row;
  
  after statement is
  begin
    if bUpdPainters then
      update Turtles
         set essence = 'Ниндзя'
       where essence = 'Художник';
    end if;
  end after statement;
end tr_turtles_ue; 


update turtles
   set essence = 'Сэнсэй'
 where name = 'Сплинтер';
 
 
 
 
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
         set essence = 'Ниндзя'
       where essence = 'Художник';
    end if;
  end;  
end pkg_around_mutation;
/

create or replace trigger tr_turtles_bue
before update of essence
on turtles
for each row
when (
  new.name = 'Сплинтер' and old.essence = 'Крыса' and new.essence = 'Сэнсэй' 
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
