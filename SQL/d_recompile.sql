--перенкомпилировать невалидные объекты схемы
begin
  sys.dbms_utility.compile_schema(schema => user11);
  -- аргумент compile_all => false (по умолчанию) компилирует только невалидные объекты[reference:4]
end;
/