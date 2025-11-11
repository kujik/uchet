unit uStringCalculator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, uMessages, uData,
  ToolCtrlsEh, DBGridEhToolCtrls,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math;


function CalculateStr (Line1: string): real;


implementation

type ECalcError = class (Exception)
end;

const Sign: set of char = ['+', '-', '*', '/'];
var Digits: set of char = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ','];
type TFunc = function (x: real): real;
const MaxFunctionID = 2; // - ?????????? ?????????????? ???????

function _sin(x: real):real;
begin
 result := sin(x);
end;
function _cos(x: real):real;
begin
 result := cos(x);
end;

const sfunc: array [1..MaxFunctionID] of string[7]= ('sin', 'cos');
const ffunc: array [1..MaxFunctionID] of TFunc = (_sin, _cos);

function GetFunction (Line: string; index: Integer): Integer;
var i: Integer;
begin
 for i:= 1 to MaxFunctionID do
 if sfunc[i] = copy(Line, index, length(sfunc[i])) then
 begin
 result := i;
 exit;
 end;
 result := 0;
end;

function CalculateFunction (Fid: Integer; x: real): real;
begin
 result := ffunc[Fid](x);
end;

function GetFunctionNameLength (Fid: Integer): Integer;
begin
 result := length (sfunc[Fid]);
end;

function CalculateLists (s1, s2: TStringList): real;
var
 i: Integer;
 a,b,r1: real;
 c: char;
begin
 r1 := 0;
// ???? ????? ????????? ??? ???????
i := 0;
if s2.Count>0 then
while (s2.Find('*', i)or(s2.Find('/', i))) do
begin
 c := s2[i][1];
 a := strtofloat(s1[i]);
 b := strtofloat(s1[i+1]);
 case c of
 '*': r1 := a*b;
 '/': r1 := a/b;
 end;
 s1.Delete(i);
 s1.Delete(i);
 s1.Insert(i, floattostr(r1));
 s2.Delete(i);
end;
// ???????? ? ????????? ///
if s2.Count>0 then
repeat
 c := s2[0][1];
 a := strtofloat(s1[0]);
 b := strtofloat(s1[1]);
 case c of
 '+': r1 := a+b;
 '-': r1 := a-b;
 end;
 s1.Delete(0);
 s1.Delete(0);
 s1.Insert(0, floattostr(r1));
 s2.Delete(0);
 if s1.Count = 1 then break;
 if s2.Count = 0 then break;
until False;
 result := strtofloat(s1[0]);
end;

function CalculateStr (Line1: string): real;
var z, d: TStringList; // - z –список знаков; d – список чисел
 i, j, c: Integer; //
 w, l, Line: string; // begw – ?начало числа
 begw, ok: Boolean;
 res: real; // - результат?
 e: ECalcError; // - ошибка
 id : Integer; // - номер функции
begin
 w := '';
 Line := Line1;
 begw := False;
 ok := False;
 z := TStringList.Create;
 d := TStringList.Create;
//// разбиение строки на два списка ////
 i := 1;
 repeat
 //// если знак операции ////
 if Line[i] in Sign then
 begin
 z.Add(Line[i]);
 if begw then d.Add(w);
 w := '';
 begw := True;
 end
 //// если цифра ////
 else if Line[i] in digits then
 begin
 begw := True;
 w := w + Line[i];
 end
 //// если скобка ////
 else if Line[i]='(' then
 begin
 c := 1;
 for j := i+1 to length (Line) do
 begin
 if Line[j]='(' then c := c + 1;
 if Line[j]=')' then c := c - 1;
 if c=0 then
 begin
 ok := True;
 break;
 end;
 end;
 if not ok then
 begin
 e := ECalcError.Create('Не найдена закрывающая скобка к символу ' + inttostr(i));
 raise e;
 e.Free;
 end;
 l := copy (Line, i+1, j-i-1);
 d.Add(floattostr(CalculateStr(l)));
 delete (Line, i, j-i+1);
 i := i - 1;
 end
 /// проверка на функцию
 else if (GetFunction (Line, i)<>0) then
 begin
 id := GetFunction (Line, i);
 if Line[i+GetFunctionNameLength(id)]<>'(' then {если нет скобки}
 begin
 e := ECalcError.Create('Не найдена скобка после функции в символе '+ inttostr(i));
 raise e;
 e.Free;
 end;
{----если есть скобка----------}
 c := 1;
 for j := i+GetFunctionNameLength(id)+1 to length (Line) do
 begin
 if Line[j]='(' then c := c + 1;
 if Line[j]=')' then c := c - 1;
 if c=0 then
 begin
 ok := True;
 break;
 end;
 end;
 if not ok then
 begin
 e := ECalcError.Create('Не найдена закрывающая скобка к символу' + inttostr(i));
 raise e;
 e.Free;
 end;
 l := copy (Line, i+GetFunctionNameLength(id)+1, j-i-GetFunctionNameLength(id)-1);
 d.Add(floattostr(CalculateFunction(id, CalculateStr(l))));
 delete (Line, i, j-i+1);
 i := i - 1;
 end
 //// если Неизвестный символ ///
 else
 begin
 e := ECalcError.Create('Неизвестный символ : '+inttostr(i));
 raise e;
 e.Free;
 end;
 i := i + 1;
 j := Length (Line);
 if i>J then break;
 until False;
 if w<>'' then d.Add(w);
 res := (CalculateLists(d, z));
 z.Free;
 d.Free;
 result := res;
end;

end.
