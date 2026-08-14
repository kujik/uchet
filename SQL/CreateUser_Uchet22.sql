-- Create the user 
create user uchet22
  identified by "uchet22"
  default tablespace USERS
  temporary tablespace TEMP
  profile DEFAULT
  quota unlimited on users;
-- Grant/Revoke role privileges 
grant connect to uchet22;
grant dba to uchet22;
grant resource to uchet22;
-- Grant/Revoke system privileges 
grant alter any materialized view to uchet22;
grant alter any procedure to uchet22;
grant alter any sequence to uchet22;
grant alter any table to uchet22;
grant alter any trigger to uchet22;
grant create any index to uchet22;
grant create any indextype to uchet22;
grant create any type to uchet22;
grant create materialized view to uchet22;
grant create procedure to uchet22;
grant create sequence to uchet22;
grant create trigger to uchet22;
grant create view to uchet22;
grant select any dictionary to uchet22;
grant select any table to uchet22;
grant execute on DBMS_CRYPTO to uchet22;
grant execute on dbms_session to uchet22;
grant unlimited tablespace to uchet22;

grant delete on uchet.to_orders to uchet22;
grant delete on uchet.to_orders_versions to uchet22;
grant delete on uchet.to_passport_items to uchet22;
grant delete on uchet.to_passport_semiproducts to uchet22;
grant delete on uchet.to_passport_addcompl to uchet22;
grant delete on uchet.to_passport_extfiles to uchet22;
grant delete on uchet.to_passport_addinfo to uchet22;
grant delete on uchet.to_passport_head to uchet22;
grant select, update, insert, delete on dv.property_values to uchet22;
grant select, update, insert, delete on uchet.mailing to uchet22;
