GRANT DBA TO sysmain;

--����
CREATE DIRECTORY dump_dir AS 'r:/oracle/dumps';
GRANT READ, WRITE ON DIRECTORY dump_dir TO sysmain;

--ora 19
CREATE DIRECTORY dump_dir AS '/home/oracle/dumps';
GRANT READ, WRITE ON DIRECTORY dump_dir TO system;


--����������������� ��� ���������� �������
sqlplus / as sysdba
@?/rdbms/admin/utlrp.sql


-- ��������� UNLIMITED
ALTER PROFILE default LIMIT password_life_time unlimited;
ALTER PROFILE default LIMIT password_grace_time unlimited;
-- ����� ������ � ������������
ALTER USER scott IDENTIFIED BY tiger;
