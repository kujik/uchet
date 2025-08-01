--create user DV identified by DV default tablespace users temporary tablespace temp;
DROP USER DV CASCADE;

CREATE USER DV
  IDENTIFIED BY 111
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT
  ACCOUNT UNLOCK;
  

-- 3 Roles for DV 
GRANT CONNECT TO DV;
GRANT DBA TO DV;
GRANT RESOURCE TO DV;
ALTER USER DV DEFAULT ROLE ALL;

-- 17 System Privileges for DV 
GRANT ALTER ANY MATERIALIZED VIEW TO DV;
GRANT ALTER ANY PROCEDURE TO DV;
GRANT ALTER ANY SEQUENCE TO DV;
GRANT ALTER ANY TABLE TO DV;
GRANT ALTER ANY TRIGGER TO DV;
GRANT CREATE ANY CONTEXT TO DV;
GRANT CREATE ANY INDEX TO DV;
GRANT CREATE ANY INDEXTYPE TO DV;
GRANT CREATE ANY TYPE TO DV;
GRANT CREATE MATERIALIZED VIEW TO DV;
GRANT CREATE PROCEDURE TO DV;
GRANT CREATE SEQUENCE TO DV;
GRANT CREATE TRIGGER TO DV;
GRANT CREATE VIEW TO DV;
GRANT SELECT ANY DICTIONARY TO DV;
GRANT SELECT ANY TABLE TO DV;
GRANT UNLIMITED TABLESPACE TO DV;

-- 1 Tablespace Quota for DV 
ALTER USER DV QUOTA UNLIMITED ON USERS;

GRANT EXECUTE ON SYS.DBMS_CRYPTO TO DV;
GRANT EXECUTE ON SYS.DBMS_SESSION TO DV;

CREATE DIRECTORY dump_dir AS 'D:\orracle\dumps';
GRANT READ, WRITE ON DIRECTORY dump_dir TO system;
