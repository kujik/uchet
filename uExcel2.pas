{
функции работы с LibXL
}
unit uExcel2;

interface

uses
  Graphics, Classes, StrUtils, DateUtils, Variants, SysUtils, uString, LibXL, ShellApi, Windows
  ;



function BookCreateAndLoad(var Book: TBook; FileName: string; var IsXML: Boolean): Boolean;
function myxlsGetSheet(var Book: TBook; SheetName: Variant; var Sheet: TSheet): Boolean;
function myxlsLoadSheetToArray(FileName: string; SheetName: Variant; r1, c1, r2, c2, rmax, cmax: Integer; var Res: TVarDynArray2): Boolean;



implementation

uses
  Math,
  uMessages
  ;

function myxlsReadCell(Sheet: TSheet; r, c: Integer): Variant;
begin
  case Sheet.getCellType(r, c) of
    CELLTYPE_NUMBER: Result:=Sheet.readNum(r, c);
    CELLTYPE_STRING: Result:=Sheet.readStr(r, c);
    CELLTYPE_BOOLEAN: Result:=Sheet.readBool(r, c);
    else Result:='';
  end;
end;


procedure myxlsSetKey(var Book: TBook);
//установить лицензионный ключ для доступа ко всем функциям и всему размеру листа (без него первые 100 строк)
begin
  Book.setKey('GCCG', 'windows-282123090cc0e6036db16b60a1o3p0h9');
end;

function BookCreateAndLoad(var Book: TBook; FileName: string; var IsXML: Boolean): Boolean;
//создать книгу, вернуть объект книги, открыв файл эксель
//формат книги определяется расширением файла, возвращается в IsXML
//возвращает результат успешного открытия
begin
  Result:= True;
  try
  IsXML:=(Pos('.xlsx', LowerCase(FileName)) = Length(FileName) - 4)or(Pos('.xlsm', LowerCase(FileName)) = Length(FileName) - 4);
  if IsXML
    then Book := TXmlBook.Create
    else Book := TBinBook.Create;
  myxlsSetKey(Book);
  Book.Load(S.StringToPAnsiChar(FileName));
  except
  Result:= False;
  end;
end;

function myxlsGetSheet(var Book: TBook; SheetName: Variant; var Sheet: TSheet): Boolean;
var
  i: Integer;
begin
  try
  Result:=False;
  if VarIsNumeric(SheetName) then begin
    if (SheetName < 0)and(SheetName >= Book.sheetCount) then Exit;
    Sheet:=Book.getSheet(SheetName);
    Result:=True;
  end
  else begin
    for i:=0 to Book.sheetCount - 1 do begin
      Sheet:=Book.getSheet(i);
      if Sheet.name = SheetName
        then begin
          Result:=True;
          Break;
        end
        else Sheet.Free;
    end;
  end;
  except
  end;
end;


function myxlsLoadSheetToArray(FileName: string; SheetName: Variant; r1, c1, r2, c2, rmax, cmax: Integer; var Res: TVarDynArray2): Boolean;
var
  Book: TBook;
  BookTempl: TBook;
  Sheet: TSheet;
  i,j,rep: Integer;
  t1, t2, tcnt: Integer;
  Sity, Addr: string;
  st, st1, st2: string;
  b, IsXML: Boolean;
  SheetNo: Integer;
  e: extended;
begin
  try
  repeat
  Result:=False;
  Res:=[];
//  FileName:='r:\kb1.xlsx';
  Book:=nil; Sheet:=nil;
  if not BookCreateAndLoad(Book, FileName, IsXML) then Break;
  if not myxlsGetSheet(Book, SheetName, Sheet) then Break;
  r2:=Min(rmax, Sheet.LastRow);
  c2:=Min(cmax, Sheet.LastCol);
  if (r2 < r1) or (c2 < c1) then Break;
  Res:=[];
  SetLength(Res, r2 - r1 + 1);
  for i:=r1 to r2 do begin
    SetLength(Res[i - r1], c2 - c1 + 1);
    for j:=c1 to c2 do
      Res[i - r1][j - c1]:= Sheet.readCell(i, j) //Sheet.readStr(i, j);
  end;
  {
//j:=Sheet.getCellType(20,17);
//i:=Sheet.getCellType(21,17);
st:=  Sheet.readStr(20, 17);
st:=  Sheet.readStr(21, 17);
//e:=  Sheet.readNum(20, 17);
if Sheet.getCellType(21,17) = CELLTYPE_NUMBER
  then e:=Sheet.readNum(21, 17);
st:=  Sheet.readStr(22, 17);
}
  Result:=True;
  until True;
  finally
  try
  if Sheet <> nil then Sheet.Free;
  if Book <> nil then Book.Free;
  except
  end;
  end;
end;





  (*
  Shee:= Book.getSheet(0);

//  MyInfoMessage(Sheet.readStr(7, 0));
  st:=Trim(Sheet.readStr(7, 0));

  if not((Trim(Sheet.readStr(7, 0)) = 'ЗАКАЗ НА ПОСТАВКУ')or(Trim(Sheet.readStr(7, 0)) = 'ЗАКАЗ НА ПОСТАВКУ И МОНТАЖ') and (Trim(Sheet.readStr(13, 0)) = 'СПЕЦИФИКАЦИЯ НА ПОСТАВКУ'))
    then begin
      MyWarningMessage('Выбранный файл не является заказовм КБ');
      Exit;
    end;
  Sity:=Trim(Sheet.readStr(10, 1));
  Addr:=Trim(Sheet.readStr(10, 3));
  MyInfoMessage(Sity + Addr);
  finally

  end;


    MyInfoMessage(Sheet.readStr(7, 0));

  r1:=0; c1:=0;
  r2:=Sheet.LastRow; c2:=Sheet.LastCol;
  Res:=[];
  SetLength(Res, r2 - r1 + 1);
  for i:=r1 to r2 do begin
    SetLength(Res[i], c2 - c1 + 1);
    for j:=c1 to c2 do
      Res[i][j]:= Sheet.readStr(i, j);
  end;

    MyInfoMessage(IntToStr(r2));

  exit;

{
//Name: GCCG
//Key: windows-282123090cc0e6036db16b60a1o3p0h9

#if TargetMacOS then
// Mac license
XLBookMBS.SetKeyGlobal(“Your Name”, “Your Key”)
#elseif TargetLinux then
// Linux license
XLBookMBS.SetKeyGlobal(“Your Name”, “Your Key”)
#elseif TargetWin32 then
// Win license
XLBookMBS.SetKeyGlobal('GCCG', 'windows-282123090cc0e6036db16b60a1o3p0h9')
#else
// missing
#endif[/code]
}

t1:=-1;
Book.setKey('GCCG', 'windows-282123090cc0e6036db16b60a1o3p0h9');
   for i:=0 to Sheet.LastRow do begin
     if (Sheet.readStr(i, 0) = 'TABLE') then begin
       if (t1 = -1) then t1:=i;
       t2:=i;
     end
     else if (t1 <> -1) then Break;
   end;
   if t1 > -1 then begin
     tcnt:= t2 - t1 + 1;
     for rep:= 0 to 1000 do begin
       Sheet.insertRow(t2 + 1 + rep * tcnt, t2 - t1 + 1);
       for i:=t1 to t2 do begin
         Sheet.setRow(i + (rep + 1) * tcnt, Sheet.rowHeight(i));
         for j:=1 to Sheet.lastCol do begin
          if (Sheet.getCellType(i, j) <> CELLTYPE_EMPTY)
            then Sheet.copyCell(i, j, i + (rep + 1) * tcnt, j);
          Sheet.getMerge(i, j, r1, r2, c1, c2);
          Sheet.setMerge(r1 + (rep + 1) * tcnt, r2 + (rep + 1) * tcnt, c1, c2);
         end;
       end;
     end;
   end;

//  Sheet := Book.addSheet('Sheet1');

//row, col
//  Sheet.writeStr(2, 1, 'Hello, World !');
{  Sheet.insertRow(3, 3);
  for i:=1 to 3 do begin
    sheet.getmerge(2,i,r1,r2,c1,c2);
    sheet.setmerge(3,3,c1,c2);
  end;
  Sheet.copyCell(2, 1, 3, 1);
  Sheet.copyCell(2, 2, 3, 2);
  Sheet.copyCell(2, 3, 3, 3);}
{  Sheet.writeNum(3, 1, 1000);


  dateFormat := Book.addFormat();
  dateFormat.setNumFormat(NUMFORMAT_DATE);
  Sheet.writeNum(4, 1, Book.datePack(2008, 4, 29), dateFormat);
  Sheet.setCol(1, 1, 12);}

//  Book.save('example.xls');
  Book.save('example.xlsx');
  ShellExecute(0, 'open', 'example.xlsx', nil, nil, SW_SHOW);
  Book.Free;
end;
*)

end.
