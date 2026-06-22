--перенкомпилировать невалидные объекты схемы
begin
  sys.dbms_utility.compile_schema(schema => 'DV');
  -- аргумент compile_all => false (по умолчанию) компилирует только невалидные объекты[reference:4]
end;
/

EXEC DBMS_STATS.GATHER_SCHEMA_STATS('DV');

ALTER SYSTEM SET DB_FILE_MULTIBLOCK_READ_COUNT = 128 SCOPE=BOTH;

EXEC DBMS_STATS.GATHER_SCHEMA_STATS('DV', OPTIONS => 'GATHER AUTO');