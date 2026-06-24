--перенкомпилировать невалидные объекты схемы
begin
  sys.dbms_utility.compile_schema(schema => 'DV');
  -- аргумент compile_all => false (по умолчанию) компилирует только невалидные объекты[reference:4]
end;
/

EXEC DBMS_STATS.GATHER_SCHEMA_STATS('DV');

ALTER SYSTEM SET DB_FILE_MULTIBLOCK_READ_COUNT = 128 SCOPE=BOTH;

EXEC DBMS_STATS.GATHER_SCHEMA_STATS('DV', OPTIONS => 'GATHER AUTO');


ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE = '11.2.0.4';
select /*+ PARALLEL(6) */ * from dv.V_SPINVOICES;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

ALTER SYSTEM SET INMEMORY_SIZE = 2G SCOPE=SPFILE;