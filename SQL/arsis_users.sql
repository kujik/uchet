
create user ORD identified by ORD default tablespace users temporary tablespace temp;
grant connect, resources to ORD;
alter user ORD default role all;
grant create procedure to ORD;
grant create sequence to ORD;
grant create session to ORD;
grant create synonym to ORD;
grant create table to ORD;
grant create trigger to ORD;
grant create view to ORD;
grant create materialized view to ORD;
grant unlimited tablespace to ORD;

create user DOC identified by DOC25 default tablespace users temporary tablespace temp;
grant connect, resources to DOC;
alter user DOC default role all;
grant create procedure to DOC;
grant create sequence to DOC;
grant create session to DOC;
grant create synonym to DOC;
grant create table to DOC;
grant create trigger to DOC;
grant create view to DOC;
grant create materialized view to DOC;
grant unlimited tablespace to DOC;

create user MTR identified by MTR25 default tablespace users temporary tablespace temp;
grant connect, resources to MTR;
alter user MTR default role all;
grant create procedure to MTR;
grant create sequence to MTR;
grant create session to MTR;
grant create synonym to MTR;
grant create table to MTR;
grant create trigger to MTR;
grant create view to MTR;
grant create materialized view to MTR;
grant unlimited tablespace to MTR;

create user ADM identified by ADM25 default tablespace users temporary tablespace temp;
grant connect, resources to ADM;
alter user ADM default role all;
grant create procedure to ADM;
grant create sequence to ADM;
grant create session to ADM;
grant create synonym to ADM;
grant create table to ADM;
grant create trigger to ADM;
grant create view to ADM;
grant create materialized view to ADM;
grant unlimited tablespace to ADM;

--------------------------------------------------------------------------------

create user WHS identified by WHS25 default tablespace users temporary tablespace temp;
grant connect, resources to WHS;
alter user WHS default role all;
grant create procedure to WHS;
grant create sequence to WHS;
grant create session to WHS;
grant create synonym to WHS;
grant create table to WHS;
grant create trigger to WHS;
grant create view to WHS;
grant create materialized view to WHS;
grant unlimited tablespace to WHS;

create user M identified by M25 default tablespace users temporary tablespace temp;
grant connect, resources to M;
alter user M default role all;
grant create procedure to M;
grant create sequence to M;
grant create session to M;
grant create synonym to M;
grant create table to M;
grant create trigger to M;
grant create view to M;
grant create materialized view to M;
grant unlimited tablespace to M;
grant select any table to M;
grant execute any procedure to M;

ALTER USER WHS ACCOUNT UNLOCK;

SELECT username, account_status, expiry_date, profile
FROM dba_users
WHERE username = 'M';
