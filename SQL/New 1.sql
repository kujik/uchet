DROP DIRECTORY export_dir;
CREATE DIRECTORY export_dir AS '/home/oracle/exports';
GRANT READ, WRITE ON DIRECTORY export_dir TO uchet22;