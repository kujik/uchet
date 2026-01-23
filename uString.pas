unit uString;

//{$mode objfpc}

//тип string = ansistring $H+

interface

uses
  Graphics, Classes, DateUtils, Variants, Types, SysUtils;

type
  TVarDynArray = array of Variant;

  TVarDynArray2 = array of array of Variant;

  TCharDynArray = array of Char;

  TByteSet = set of Byte;

  TCharSet = set of Char;

  TNamedArr = record
    FFull: TVarDynArray;
    F: TVarDynArray;
    V: TVarDynArray2;
    procedure Create(Fields: TVarDynArray; Len: Integer);
    function  Col(Field: string): Integer;
    function  G(RowNo: Integer; Field: string): Variant; overload;
    function  G(Field: string): Variant; overload;
    function  GetValue(RowNo: Integer; Field: string): Variant; overload;
    function  GetValue(Field: string): Variant; overload;
    function  GetRow(RowNo: Integer): TVarDynArray;
    procedure SetValue(RowNo: Integer; Field: string; NewValue: Variant); overload;
    procedure SetValue(Field: string; NewValue: Variant); overload;
    function  Find(Value: Variant; Field: string): Integer;
    function  Empty: Boolean;
    function  Count: Integer;
    function  High: Integer;
    procedure IncLength;
    procedure SetLen(ALength: Integer);
    function  FieldsCount: Integer;
    procedure Clear;
    procedure SetNull; overload;
    procedure SetNull(RowNo: Integer); overload;
  end;

  TNamedArr2 = array of TNamedArr;


type
  TArrayOperation = (aoIntersection, aoUnion, aoDifference);

  TStringDirection = (sdLeft, sdRight, sdBoth);

  TMyStringLocation = (stlLeft, stlRight, stlBoth);

const
  micntBadDate: Double = 365;  //30.12.1900

  {
  cdThisDay = 0;
  cdLastDay = 0;
  cdThis = 0;
  cdLast = 0;
  }

  RubDividor: ShortString = ' ';
  KopDividor: ShortString = ' . ';
  Kop2Dividor: ShortString = '';
  PriceNewMode = True;
  fopCaseSensetive = $01;
  fopWholeField = $02;
  fopUseMask = $04;
  EngChars: set of Char = ['A'..'Z', 'a'..'z'];
  EngChars_: set of Char = ['A'..'Z', 'a'..'z', '_'];
  DaysOfWeek2: array[1..7] of string = ('Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс');
  MonthsRu: array[1..12] of string = ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь');
  DigitsChars: set of Char = ['0'..'9'];
  DigitsChars_: set of Char = ['0'..'9', '.', ',', '+', '-'];
  DivSymbols =[' ', ',', '.', ':', ';', '?', '!', '"', '=', '-', '_', '(', ')', '%', '/', '\', '*'];
  DatePeriods: array[0..11] of string = ('Сегодня', 'Вчера', 'Эта неделя', 'Прошлая неделя', 'Эта половина месяца', 'Прошлая половина месяца', 'Этот месяц', 'Прошлый месяц', 'Этот квартал', 'Прошлый квартал','Этот год', 'Прошлый год');

type
  TMyStringHelper = record

//----------- Обрезка пробелов и управляющих символов

//Удалим переданные символы слева, справа или с обеих сторон строки;
//если не передан массив символов, то удаляем пробел и табуляцию
    function TrimSt(const St: string; TrimCh: TCharDynArray = []; Mode: TMyStringLocation = stlBoth): string;
//Процедура. Удалим переданные символы слева, справа или с обеих сторон строки;
//если не передан массив символов, то удаляем пробел и табуляцию
    procedure TrimStP(var St: string; TrimCh: TCharDynArray = []; Mode: TMyStringLocation = stlBoth);
//удалим символы с левой части строки
    procedure DelLeft(var st: string; TrimCh: TCharDynArray = []);
//удалим символы с правой части строки
    procedure DelRight(var st: string; TrimCh: TCharDynArray = []);
//Удаление переданного массива символов с обоих концов строки
    procedure DelBoth(var st: string; TrimCh: TCharDynArray = []);

//----------- Замена символов в строке

//если в строке идут несколько пробелов подряд, то приводит их к одному пробелу
//mode=True  заменяет в строке все символы из [ch] на символ chnew[i]
//mode=False заменяет в строке все символы из not[ch] на символ chnew[i]
//если ChNew = [], то исхдные символы удаляютсмя,
//если ChNew имеет только один элемент, то для всех искомых испольуется он,
//иначе, если длина входеных и выходных различается, генереруется ошибка
    function ReplaceChars(St: string; Chars: TCharDynArray; ChNew: TCharDynArray; Mode: Boolean): string;
//если в строке идут несколько пробелов подряд, то приводит их к одному пробелу
    function DeleteRepSpaces(St: string; Ch: Char = ' '): string;
//удаляем все символы Ch из строки
    function DeleteChar(St: string; Ch: char): string;
//mode=True  удаляет в строке все символы из [ch]
//mode=False удаляет в строке все символы из not[ch]
    function DeleteChars(St: string; Chars: TCharDynArray; Mode: Boolean): string;
//mode=True  заменяет в строке все символы из [ch] на символ chnew
//mode=False заменяет в строке все символы из not[ch] на символ chnew
    function ChangeChars(st: string; ch: tcharset; chnew: char; mode: Boolean): string;
//возвращает сроку символов Fill
    function FillString(Length: Integer; Chr: Char): string;
//если в строке идут подряд последовательности символов (подстроки), то оставляет только первую из них
//не доделано!!! работает для уборки последовательносте типа ("1212ыыыы12", "12"), но не из повторяющихся символов (не должна быть последовательность "00"!!!
function DeleteRepSubstr(St: string; SubSt: string): string;

//---------Выравнивание текста за счёт установки пробелов или других символов
{
 Writeln('123'.PadLeft(5));  //'  123'
 Writeln('12345'.PadLeft(5));  //'12345'
 Writeln('Выводы '.PadRight(20, '-') + ' стр. 7'); //'Выводы ------------- стр. 7'
}

//дополняет строку переданным символом (по умолчанию пробел) слева, до переданной длины
    function PadLeft(St: string; Len: Integer; Ch: Char = ' '): string;
//дополняет строку переданным символом (по умолчанию пробел) справа, до переданной длины
    function PadRight(St: string; Len: Integer; Ch: Char = ' '): string;

//---------Проверка корректности типа строки (формат числа, даты...)

//проверяет, является ли строка целым числом.
    function IsInt(St: string): Boolean;
//проверяет, является ли строка числом с плавающей точкой
    function IsFloat(St: string): Boolean;
//проверяет, является ли строка числом в заданном диапозоне с заданным числом десятичных знаков
//если число десятичных знаков не нужно, передать -1, если нажно целоое число, передать 0
    function IsNumber(St: string; MinI, MaxI: Extended; FDigits: Integer = -1): Boolean;
//проверка строки на то что содержит дату/время
//DtType = dt - должно быть датой или датой со временем, DT - обязательно дата и время, d,D -только дата, t - только время
//предполагается что разделитель даты и времени - пробел (практически всегда это так), а часов и минут - ":"
    function IsDateTime(St: string; DtType: string = 'dt'): Boolean;
//если строка есть число (целое положительное) возвр его длинну
//если начало строки есть число возвр длинну этой части со знаком -
    function IsNumberLeftPart(St: string): Integer;
//проверяетвалидность почтового адреса по формальным признакам (адрес должен соответствовать стандарту)
    function IsValidEmail(const Value: string): Boolean;

//---------Перевод строки в простые типы

//проверяем, является ли строка числом в заданном диапозоне с заданным количеством чисел после запятой (не более)
//в качестве разделителей принимаем точку и запятую
//возвращаем число в Res: extended, а Result - истина или ложь /если не удалось преобразовать в число/
    function StrToNumberCommaDot(V: Variant; MinI, MaxI: Extended; var Res: Extended; FDigits: Integer = -1): Boolean;
//преобразует тип Variant в Integer; при неудаче возвращает значение Def
    function VarToInt(v: Variant; Def: Integer = -1): Integer;
//преобразует тип Variant в Extended; при неудаче возвращает значение Def
    function VarToFloat(v: Variant; Def: extended = -1): extended;
//преобразовывает число в строку длиной не менее Len, позиции перед числом заполняет символом Ch
    function NumToString(Number: Extended; Len: byte; Ch: Char): string;
//преобразует строку из трех или пяти чисел, разделенных пробелами (дефисами, точками), в TDateTime
//если ошиибка возвращает BadDate
//использовать только при вводе вручную или при явно корректном формате так как в среде будет вызываться исключение
    function SpacedStToDate(St: string; FullDateTime: Boolean = False): TDateTime;
//преобразует TDateTime в число (Double) и возвращает в  виде строки
//сервисная функция
    function DateTimeToIntStr(dt: TDateTime): string;

//--------- Обработка значений типа Null, переданных в параметре Varint

//возвращает пустую строку, если значение Empty или Null
    function NSt(St: Variant): string;
//возвращает 0 с типом extended, если значение Empty или Null
//    function NNum(St: Variant): extended;
    function NNum(St: Variant; Default: Extended = 0): Extended;
//возвращает 0 с типом Integer, если значение Empty или Null
    function NInt(St: Variant): Integer;
//возвращает -1 с типом Integer, если значение Empty или Null
    function NIntM(St: Variant): Integer;
//возвращает нулл если v=null or VarToString(v) ='', иначе вернет переданное значение
    function NullIfEmpty(v: Variant): Variant;
//возвращает нулл если v=0 (0.00), иначе вернет переданное значение
    function NullIf0(v: Variant): Variant;

//--------- Изменение регистра строки
{
Writeln(LowerCase('АбВгД - AbCdE')); //В нижний регистр меняются только латинские буквы. Результат будет 'АбВгД - abcde'.
Writeln('АбВгД - AbCdE'.ToLower); //В нижний регистр меняются и русские и латинские буквы. Результат будет 'абвгд - abcde'.
}
//изменить регистр строки (и латинские и русские буквы
    function ChangeCaseStr(St: string; ToUpper: Boolean): string;
//изменить регистр символа (и латинские и русские буквы
    function ChangeCaseCh(Ch: Char; ToUpper: Boolean): string;
//строку в верхний регистр
    function ToUpper(St: string): string;
//строку в нижний регистр
    function ToLower(St: string): string;

//получает Cnt правых символов строки
    function Right(St: string; Cnt: Integer = 1): string;


//---------- Поиск вхождений, вычленение позиций вхождений ы строку.

//находит позицию подстроки в строке без учета регистра
    function PosI(StPart, StFull: string): Integer;
//проверяет, содержится ли подстрока в строке значений, разделенных запятыми
    function InCommaStr(stpart, stall: string; ch: Char = ','; IgnoreCase: Boolean = False): Boolean;
//проверяет, содержится ли подстрока в строке значений, разделенных запятыми, без учета регистра
    function InCommaStrI(stpart, stall: string; ch: Char = ','): Boolean;
//подсчитывает количество символов из переданного набора в строке, начиная с позиции р1 и до р2 (если -1 то до конца строки)
    function GetCharCountInStr(St: string; Chars: TCharSet; p1: Integer = 1; p2: Integer = -1): Integer;
//ищем позицию начяала слова в строке, передается начальная позиция поиска,
//счетчик идет назад пока не встретистся символ из DivSymbols
    function FindBegWord(Start: Integer; St: string; DivSymbols: TCharSet = [' ']): Integer;
//ищем позицию конца слова в строке, передается начальная позиция поиска,
//счетчик идет вперед пока не встретистся символ из DivSymbols
    function FindEndWord(Start: byte; st: string; DivSymbols: TCharSet = [' ']): Integer;
//разбиение строки St на 3 части: St1 -до кавычек, St2 - в кавычках, St3 - после
//кавычки учитываются как двойные так и одинарные
//осталось от старого
    procedure DivisionQuotetStr(st, st1, st2, st3: string);
//получает подстроку номер NumSubSt из строки, которую разбивает по строковым разделителям DivSt
//возвращает также позицию найденной подстроки в строке
//если не смог выделить подстроку, то возвращает -2 и ''
    function GetSubSt(SourceSt: string; NumSubSt: Integer; DivSt: string; var PosSt: Integer): string;
//Поиск по маске:  Сpавнение стpоки St с шаблоном Mask. В шаблоне можно
//yпотpеблять знаки '?'(любой знак) и '*' (любое количество любых знаков)
    function FindMaskInStr(var Mask, St: string): Boolean;
//Поиск по маске:  Сpавнение стpоки St с шаблоном Mask. В шаблоне можно
//yпотpеблять знаки '?'(любой знак) и '*' (любое количество любых знаков)}
    function FindADDMaskInStr(Mask, St: string): Boolean;

//---------- Специальные преобразования строки (число в цену прописью и т.п.

//преобразование числа в строку прописью
    function NumToWords(Num: longint; Mode: char): string;
//преобразование числа в строку цены прописью
    function NumToPriceWords(Num: longInt; Mode: Boolean): string;
//преобразует число в сцену в рублях и копейках в виде числа а не слов
//работает тут НЕПРАВИЛЬНО, цена в целом числе, 2 последние это копейки
    function NumToPriceStr(Num: longint): string;
//сервисная функция для вывода цены с включением слов Рублей и Копеек
    function PriceWord(Num: longint; Mode: Char): string;
//преобразование числа в строку телефона с разделителями
    function NumToPhoneStr(Num: longint): string;
//форматирование строки как строки телефона с разделителями
    function StrToPhoneStr(StT: string): string;
//выбирает окончание по количеству
//(передается окончание для кол-ва 1, 2{3,4}, 5(6,7,8,9,10)
    function GetEnding(Num: longint; St1, St2, St3: string): string;
//(передается количество, основная часть слова, окончание для кол-ва 1, 2{3,4}, 5(6,7,8,9,10)
    function GetEndingFull(Num: longint; Main, St1, St2, St3: string): string;
//выбирает окончание по количеству (толькко ед/множ число)
    function GetEndingOneOrMany(Num: longint; St1, St2: string): string;
    //заключить строку в круглые скобки, если она не пустая
    function AddBracket(st: string): string;
    //форматируем число в строку. если есть дробная часть, то она будет дана через запятую (по умолчанию) или точку
    function FormatNumberWithComma(Value: Extended; DivIsComma: Boolean = True): string;


//-------------------------- Условные функции
//-- Важно: в отличии от выражений параметры в функциях будут вычислены ВСЕГДА при их в нее передаче

//если Expr истина, то вернет Par1, иначе Par2
//варианта для аргументов Variant, string, Integer, extended
    function IIf(Expr: Boolean; Par1, Par2: Variant): Variant;
    function IIfV(Expr: Boolean; Par1, Par2: Variant): Variant;
    function IIFStr(Expr: Boolean; Par1: string; Par2: string = ''): string; overload;  //второй параметр можно не задавать, если должен быть пустой
    //если первый аргумент не пуст, возвращает его, иначе - второй
    function IfEmptyStr(St: string; StIfEmpty: string): string;
//заменяет в маске символ #0 на строку, если строка непустая; если пустая, вернет ''
    function IfNotEmptyStr(St: string; Mask: string = #0; StIfEmpty: string = ''): string;
    function IIfInt(Expr: Boolean; Par1, Par2: Integer): Integer;
    function IIfFloat(Expr: Boolean; Par1, Par2: extended): Extended;
    //Если AValue = AIfValeu, то вернет AIfValeu, иначе AElseValue
    function IfEl(AValue, AIfValeu, AElseValue: Variant): Variant;
//если ValueFact = ValueCheck, то вернет ValueFact, иначе ValueRes
    function IfNotEqual(ValueFact, ValueCheck, ValueRes: Variant): Variant;
//если ValueFact не пустое (empty, '', null), то вернет ValueFact, иначе ValueRes
    function IfNotEmpty(ValueFact, ValueRes: Variant): Variant;
//возвращает из массива результат, соответствующий нулевому значению
//value, case1, value1, case2, value2, {valueelse}
    function Decode(ar: TVarDynArray): Variant;
//сравнить две строки без учета регистра
    function CompareStI(st1, st2: string): Boolean;

//-------------------------- конкатенация строк

//добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
    function ConcatSt(StAll, StPart: string; Dividor: string = ','; IfNotEmpty: Boolean = False): string;
//процедура. добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
    procedure ConcatStP(var StAll: string; StPart: string; Dividor: string = ','; IfNotEmpty: Boolean = False); overload;
    procedure ConcatStP(var StAll: Variant; StPart: Variant; Dividor: Variant; IfNotEmpty: Boolean = False); overload;

//-------------------------- функции для sql-запросов

//форматирует дяту в тот вид, который можно вставить в скл
//в сам текст, в параметра передается просто сам тип даты)
    function SQLdate(dt: TDateTime): ansistring;
//преобразование даты, включая временнУю часть, в строку соотв формату даты в выбранной БД
    function SQLdateTime(dt: TDateTime): ansistring;

//-------------------- математические ------------------------------------------

//выбирает максимальное значение из вариантного массива
    function MaxOf(const Values: array of Variant): Variant;
//выбирает минимальное значение из вариантного массива
    function MinOf(const Values: array of Variant): Variant;

//-------------------------- служебные -----------------------------------------

//возвращает дату, которую условились считать признаком неверной даты/времени
    function BadDate: TDateTime;
//производит обмен значениями между двумя переменными
    procedure SwapPlaces(v1, v2: Variant);
//не знаю для чего делал
//function DivisionText(St:string;canvas:TCanvas;width,field:Integer):TStringList;
//пасрсит строку Csv в массив
//функция устаревшая, если использовать надо будет переделывать
//function ParseCsv(St: string; DivCh: Char): tSplitArray;
//скорректируем строку для использования в качестве имени файла
    function CorrectFileName(st: string): string;
//проверка ИНН
    function ValidateInn(inn: Variant): string;
//конвертация типа string в PAnsiChar c проверкой (при ошибке исключение)
    function StringToPAnsiChar(stringVar: string): PAnsiChar;
//возвращает имя поля в таблице из имени поля в селесте   например из '1 as field' вернет 'field'
//например из '1 as field$s' вернет 'field$s'
    function WideStringToString(const ws: WideString; codePage: Word): AnsiString;
    function StringToWideString(const s: AnsiString; codePage: Word): WideString;
    function GetFieldNameFromSt(st: string): string;
    //возвращает имя поля в таблице из имени поля в селесте
    //например из '1 as field$s' вернет 'field', а если установлен WithMod, то 'field$s'
    function GetDBFieldNameFromSt(st: string; WithMod: Boolean = False): string;
    //возвращает назавание периода в зависимсоти от количества дней:
    //неделя, 4 дня, месяц, 3 месяца, полгода, год, 68 дней - с допусками несколько дней для градаций по месяцам
    function GetDaysCountToName(Days: Integer): string;
    //проверка значения строки, по правилам переданным в verify, с учетом типа данных, указанных в ValueType
    //для строк возможна коррекция значений
    function VeryfyValue(ValueType: string; Verify: string; Value: string; var CorrectValue: Variant): Boolean;
    //возвращает НЕКОТОРЫЕ сводные типы переменной Variant
    //например любое целое иудет varInteger
    function VarType(Value: Variant): Integer;
    //проверяет, задано ли значение переменной типа Variant
    function VarIsClear(const V: Variant): Boolean;
    //возвращает даты начала и конца периода по массиву DatePeriods (по номеру элемента или названию). если не найдено - возвращает сегодня
    procedure GetDatePeriod(Period: Variant; dt0: TDateTime; var dt1: TDateTime; var dt2: TDateTime);
    procedure GetDatesFromPeriodString(st: string; var dt1: TDateTime; var dt2: TDateTime);
  end;

//------------------------------------------------------------------------------
//------------- Работа с массивами
  TMyArrayHelper = record
//разбивает исходную строку на подстроки, используя как разделитель строку DivSt
//исходная строка может быть и массивом, тогда будет возвращен этот массив
//если не установлено IgnoreEmpty, то элементы могут быть пустыми, и пустая строка станет массивом [''].
//вернет одномерный вариантный массив
    function Explode(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TVarDynArray;
//просто алиас Explode
    function ExplodeV(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TVarDynArray;
//тоже самое, но возвращает TStringDynArray (перекрыть нельзя, тк определяется только по входным параметрам)
    function ExplodeS(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TStringDynArray;
//то же в виде процедур
    procedure ExplodeP(V: Variant; DivSt: string; var Arr: TVarDynArray); overload;
    procedure ExplodeP(V: Variant; DivSt: string; var Arr: TStringDynArray); overload;
    procedure ExplodeP(V: Variant; DivSt: string; IgnoreEmpty: Boolean; var Arr: TVarDynArray); overload;
    procedure ExplodeP(V: Variant; DivSt: string; IgnoreEmpty: Boolean; var Arr: TStringDynArray); overload;

//сливаем одномерный вариантный массив в строку через разделитель;
//если IgnoreEmpty установлен, то игнорируем пустые значения массива
    function Implode(Arr: array of Variant; Delim: string; IgnoreEmpty: Boolean = False): string; overload;
//сливаем одномерный строковый массив в строку через разделитель;
//если IgnoreEmpty установлен, то игнорируем пустые значения массива
    function Implode(Arr: TStringDynArray; Delim: string; IgnoreEmpty: Boolean = False): string; overload;
//сливаем в строку переданную колонку двумерного массива
    function Implode(Arr: TVarDynArray2; Col: Integer; Delim: string; IgnoreEmpty: Boolean = False): string; overload;
//сливаем в строку весь двухмерный массив по указанным колонкам, разделители для первого и второ уровня разные
    function Implode(Arr: TVarDynArray2; Columns: TByteSet; Delim1: string; Delim2: string; IgnoreEmpty: Boolean = False): string; overload;
//сливаем в строку переданную колонку двумерного массива
//сливаем одномерный вариантный массив в строку через разделитель;
//пустые элементы всегда игнорируем
    function ImplodeNotEmpty(Arr: array of Variant; Delim: string): string;
//склеивает текст из TStrings, при этом игнорирует пустые строки с конца списка
    function ImplodeStringList(var sl: TStringList; Dividor: string = ','): string;
//находит позицию V в одномерном массиве Arr типа Variant; может не различать регистр; Если не найдена,
//возвращает -1 (или если массив сначигнается с меньшей нуля индекса, то Low(Arr) - 1
    function PosInArray(V: Variant; Arr: array of Variant; IgnoreCase: Boolean = False): Integer; overload;
//находит позицию V в одномерном массиве Arr типа строк; может не различать регистр
    function PosInArray(St: string; Arr: TStringDynArray; IgnoreCase: Boolean = False): Integer; overload;
    function PosInArray(V: Variant; Arr: TVarDynArray; IgnoreCase: Boolean = False): Integer; overload;
//находит позицию первого уровня для двумерного массива, в которой в поле FNo находится значение V
    function PosInArray(V: Variant; Arr: TVarDynArray2; FNo: Integer = 0; IgnoreCase: Boolean = False): Integer; overload;
    //найдет позицию в массиве, для которой совпадаю все переданные значения в переданных столбцах
    function PosInArray(V: TVarDynArray; Arr: TVarDynArray2; FNo: TVarDynArray; IgnoreCase: Boolean = False): Integer; overload;
    //найдет позицию в массиве Source, при которой все поля совпадаются со строкой массива Needle (размерности 2 уровня должны быть одинаковы, что не провряется)
    function PosRowInArray(Needle, Source: TVarDynArray2; NeedleRow: Integer): Integer;
//вернет истину, если строка присутствует в массиве
    function InArray(V: Variant; Arr: array of Variant): Boolean;
//возвращает значение из столбца ValueFNo, для которого значения в столбце KeyFNo = KeyValue
    function FindValueInArray2(FindValue: Variant; FindFNo: Integer; ResultFNo: Integer; Arr: TVarDynArray2; IgnoreCase: Boolean = False): Variant;
    //заменяем найденное поле в массиве в строке новым значением; возвращает, была ли замена
    function ReplaceInArray(FindValue: Variant; NewValue: Variant; Arr: TVarDynArray; IgnoreCase: Boolean = False): Boolean; overload;
    //заменяем поле в массиве в строке, найденной по значению какого-либо (другого или того же) поля, была ли замена
    function ReplaceInArray(FindValue: Variant; NewValue: Variant; Arr: TVarDynArray2; FindFNo, ReplaceFNo: Integer; IgnoreCase: Boolean = False): Boolean; overload;
//заменяем поле в массиве в строке, найденной по значению какого-либо поля
//возвращает столбец двухмерного массива Column в одномерном массиве
    function VarDynArray2ColToVD1(arr: TVarDynArray2; Column: Integer): TVarDynArray;
//возвращает столбец двухмерного массива Column в одномерном массиве
    function VarDynArray2RowToVD1(arr: TVarDynArray2; Row: Integer): TVarDynArray;
//модифицирует двумерный массив вставкой или заменой его элемента первого уровня массивом TVarDynArray
//при параметрах по умолчанию просто добавит массив TVarDynArray в конец массива TVarDynArray2
procedure VarDynArray2InsertArr(var arr2: TVarDynArray2; arr1: TVarDynArray; Pos: Integer = -1; ToInsert: Boolean = True);
//сортировка одномерного вариантного массива
    procedure VarDynArraySort(var Arr: TVarDynArray; Asc: Boolean = True); overload;
//сортировка двухмерного вариантгного массива по переданному полю
    procedure VarDynArraySort(var Arr: TVarDynArray2; Col: Integer; Asc: Boolean = True); overload;
//сортировка двухмерного вариантгного массива по переданному полю
//поле передается на 1 больше чем в массиве, если с + то по возрастанию, а с - то по убыванию, ту при сортировке по убыванию по нулевой колонке передать -1
    procedure VarDynArray2Sort(var Arr: TVarDynArray2; Key: Integer);
//возвращает одномерный массив, являющийся пересечением, объединением или различием двух массивов
    function ArrCompare(const AVar1, AVar2: array of Variant; Operation: TArrayOperation): TVarDynArray;
//передается или целое число, или вариантный массив, или строка чисел через запятую,
//возвращается массив
    function VarIntToArray(v: Variant): TVarDynArray;
    //получает массив строк, возвращает вариантный массив
    function StringDynArrayToVarDynArray(sa: TStringDynArray): TVarDynArray;
    //удаляем дублирующиеся знаения из массива
    function RemoveDuplicates(const AValues: TVarDynArray): TVarDynArray;
    //сравнение двух двумерных массивов (или одной их строки)
    //будут одинаковы, если совпадают размерности массивов и все их значения
    function IsArraysEqual(const A, B: TVarDynArray2; ARow: Integer = -1): Boolean;
    procedure SetNull(var Arr: TVarDynArray); overload;
    procedure SetNull(var Arr: TVarDynArray2; Row: Integer = -1); overload;
    procedure IncLength(var Arr: TVarDynArray); overload;
    procedure IncLength(var Arr: TVarDynArray2); overload;
end;

var
  A: TMyArrayHelper;

var
  S: TMyStringHelper;


type
  TVariantHelper = record helper for Variant
  public
    function IsNull: Boolean;
    function IsEmpty: Boolean;
    function IsNumeric: Boolean;
    function AsString: string;
    function AsInteger: Integer;
    function AsIntegerM: Integer;
    function AsFloat: Extended;
    function AsBoolean: Boolean;
    function AsDateTime: TDatetime;
    function NullIf0: Variant;
    function NullIfEmpty: Variant;
  end;

//НЕ разобрался пока что
function WordPosition(const N: Integer; const S: string; WordDelims: TCharSet): Integer;
//нужно для EhLib

function ExtractWordPos(N: Integer; const S: string; WordDelims: TCharSet; var Pos: Integer): string;
//нужно для EhLib

function ExtractWord(N: Integer; const S: string; WordDelims: TCharSet): string;


//const
//  IsNumber: function (St:string; MinI, MaxI: Extended; FDigits: Integer = -1): Boolean =
//    TMyStringHelper.IsNumber(St:string; MinI, MaxI: Extended; FDigits: Integer = -1): Boolean;



//-------------- РАЗНОЕ -------------------------------------------------------
procedure Txt2File(St: string; Fname: string);
function VTxt(var v: Variant; name: string = ''): string; overload;
function VTxt(var va2: TVarDynArray2; name: string = ''): string; overload;
function VTxt(var va: TVarDynArray; name: string = ''): string; overload;
function VTxt(var na: TNamedArr; name: string = ''): string; overload;
procedure MsgDbg(Values: TVarDynArray; Name: string = ''; Skip: Boolean = False);



{-------------------------------------------------------------------}

implementation

uses
  Math, uErrors, uMessages, uFrmMain;


















//-----------------------------------------------------








//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//ОБРАБОТКА СТРОК

//----------- Обрезка пробелов и управляющих символов
(*
можно использовать helper:
string.trimleft([]) удаляет eghfdkz.obt cbvdjks? gthtdjls cnhjr? ghj,tks
string.trimstart([]) удаляет перечисленные символы слева (массив символов обязателен)
string.trim{([]])}
st.TrimLeft //только управляющие символы
*)

function TMyStringHelper.TrimSt(const St: string; TrimCh: TCharDynArray = []; Mode: TMyStringLocation = stlBoth): string;
//Удалим переданные символы слева, справа или с обеих сторон строки;
//если не передан массив символов, то удаляем пробел и табуляцию
begin
  if Length(TrimCh) = 0 then
    TrimCh := [' ', #9];
  if (Mode = stlLeft) or (Mode = stlBoth) then
    St.TrimEnd(TrimCh);
  if (Mode = stlRight) or (Mode = stlBoth) then
    St.TrimStart(TrimCh);
  Result := St;
end;

procedure TMyStringHelper.TrimStP(var St: string; TrimCh: TCharDynArray = []; Mode: TMyStringLocation = stlBoth);
//Процедура. Удалим переданные символы слева, справа или с обеих сторон строки;
//если не передан массив символов, то удаляем пробел и табуляцию
begin
  St := TrimSt(St, TrimCh, Mode);
end;

procedure TMyStringHelper.DelLeft(var st: string; TrimCh: TCharDynArray = []);
//удалим символы с левой части строки
begin
  TrimStP(st, TrimCh, stlLeft);
end;

procedure TMyStringHelper.DelRight(var st: string; TrimCh: TCharDynArray = []);
//удалим символы с правой части строки
begin
  TrimStP(st, TrimCh, stlRight);
end;

procedure TMyStringHelper.DelBoth(var st: string; TrimCh: TCharDynArray = []);
//Удаление переданного массива символов с обоих концов строки
begin
  TrimStP(st, TrimCh, stlBoth);
end;


//----------- Удаление.замена символов в строке

function TMyStringHelper.ReplaceChars(St: string; Chars: TCharDynArray; ChNew: TCharDynArray; Mode: Boolean): string;
//mode=True  заменяет в строке все символы из [ch] на символ chnew[i]
//mode=False заменяет в строке все символы из not[ch] на символ chnew[i]
//если ChNew = [], то исхдные символы удаляютсмя,
//если ChNew имеет только один элемент, то для всех искомых испольуется он,
//иначе, если длина входеных и выходных различается, генереруется ошибка
var
  i, j: Integer;
  ch: Char;
  m: Integer;
  b: Boolean;
begin
  m := 0;
  if Length(ChNew) = 0 then
    m := -1;
  if Length(ChNew) = 1 then begin
    m := 1;
    ch := ChNew[1];
  end;
  if (m = 0) and (Length(Chars) <> Length(ChNew)) then begin
    Errors.SetParam('ReplaceChars', 'Не совпадают размеры параметров Chars и ChNew');
    raise Exception.Create('');
  end;
  for i := Length(St) downto 1 do begin
    b := False;
    for j := 0 to High(Chars) do
      if St[i] = Chars[j] then begin
        b := True;
        Break;
      end;
    if (Mode and b) or (not Mode and not b) then
      case m of
        0:
          St[i] := ChNew[j];
        1:
          St[i] := ch;
        2:
          Delete(St, i, 1);
      end;
  end;
  Result := St;
end;

function TMyStringHelper.DeleteRepSubstr(St: string; SubSt: string): string;
//если в строке идут подряд последовательности символов (подстроки), то оставляет только первую из них
//не доделано!!! работает для уборки последовательносте типа ("1212ыыыы12", "12"), но не из повторяющихся символов (не должна быть последовательность "00"!!!
var
  i, j: Integer;
begin
  Result:= St;
  i:= 1;
  repeat
    j:= Pos(SubSt, Result, i);
    if j = 0 then Exit;
    if j = i + 1{Length(SubSt)} then begin
      Delete(Result, j, Length(SubSt))
    end
    else i:= j + 1;//Length(SubSt);
  until False;
end;

function TMyStringHelper.DeleteRepSpaces(St: string; Ch: Char = ' '): string;
//если в строке идут несколько пробелов подряд, то приводит их к одному пробелу
var
  i: Integer;
begin
  for i := Length(St) downto 1 do
    if (St[i] = Ch) and (St[i - 1] = Ch) then
      Delete(St, i, 1);
  Result := St;
end;

function TMyStringHelper.DeleteChar(St: string; Ch: char): string;
//удаляем все символы Ch из строки
var
  i: byte;
begin
  for i := Length(St) downto 1 do
    if St[i] = Ch then
      Delete(St, i, 1);
  Result := St;
end;

function TMyStringHelper.DeleteChars(St: string; Chars: TCharDynArray; Mode: Boolean): string;
//mode=True  удаляет в строке все символы из [ch]
//mode=False удаляет в строке все символы из not[ch]
var
  i: byte;
begin
  Result := ReplaceChars(St, Chars, [], Mode);
end;

function TMyStringHelper.ChangeChars(st: string; ch: tcharset; chnew: char; mode: Boolean): string;
//mode=True  заменяет в строке все символы из [ch] на символ chnew
//mode=False заменяет в строке все символы из not[ch] на символ chnew
var
  i: byte;
begin
  for i := 1 to length(st) do
    if ((st[i] in ch) and (mode)) or ((not (st[i] in ch)) and (not mode)) then
      st[i] := chnew;
  Result := st;
end;

function TMyStringHelper.FillString(Length: Integer; Chr: Char): string;
//возвращает сроку символов Fill
begin
  SetLength(Result, Length);
  FillChar(Result[1], Length, Chr);
end;





//---------Выравнивание текста за счёт установки пробелов или других символов
{
 Writeln('123'.PadLeft(5));  //'  123'
 Writeln('12345'.PadLeft(5));  //'12345'
 Writeln('Выводы '.PadRight(20, '-') + ' стр. 7'); //'Выводы ------------- стр. 7'
}

function TMyStringHelper.PadLeft(St: string; Len: Integer; Ch: Char = ' '): string;
//дополняет строку переданным символом (по умолчанию пробел) слева, до переданной длины
begin
  Result := St.PadLeft(Len, Ch);
end;

function TMyStringHelper.PadRight(St: string; Len: Integer; Ch: Char = ' '): string;
//дополняет строку переданным символом (по умолчанию пробел) справа, до переданной длины
begin
  Result := St.PadRight(Len, Ch);
end;


//---------Проверка корректности типа строки (формат числа, даты...)

function TMyStringHelper.IsInt(St: string): Boolean;
//проверяет, является ли строка целым числом.
var
  i, j: Integer;
begin
  i := StrToIntDef(St, 0);
  j := StrToIntDef(St, 1);
  Result := (i = j);
end;

function TMyStringHelper.IsFloat(St: string): Boolean;
//проверяет, является ли строка числом с плавающей точкой
var
  i, j: Extended;
begin
  i := StrToFloatDef(St, 0);
  j := StrToFloatDef(St, 1);
  Result := (i = j);
end;

function TMyStringHelper.IsNumber(St: string; MinI, MaxI: Extended; FDigits: Integer = -1): Boolean;
//проверяет, является ли строка числом в заданном диапозоне с заданным числом десятичных знаков
//если число десятичных знаков не нужно, передать -1, если нажно целоое число, передать 0
var
  e, f1, f2: Extended;
  i, j: Integer;
begin
  Result := False;
  if St = null then
    Exit;
  f1 := StrToFloatDef(St, 0);
  f2 := StrToFloatDef(St, 1);
  if f1 <> f2 then
    Exit;
  if f1 < MinI then
    Exit;
  if f1 > MaxI then
    Exit;
  i := Pos(FormatSettings.DecimalSeparator, St);
  if i <> 0 then
    i := Length(St) - i;
  if (FDigits <> -1) and (FDigits < i) then
    Exit;
  Result := True;
end;

//проверка строки на то что содержит дату/время
//DtType = dt - должно быть датой или датой со временем, DT - обязательно дата и время, d,D -только дата, t - только время
//предполагается что разделитель даты и времени - пробел (практически всегда это так), а часов и минут - ":"
function TMyStringHelper.IsDateTime(St: string; DtType: string = 'dt'): Boolean;
begin
  Result := False;
  if StrToDateTimeDef(St, EncodeDate(1900, 1, 1)) <> StrToDateTimeDef(St, EncodeDate(1900, 1, 2)) then
    Exit;
  if (pos(' ', St) > 0) and ((DtType = 'd') or (DtType = 'D') or (DtType = 't') or (DtType = 'T')) then
    exit;
  if (pos(':', St) = 0) and ((DtType = 't') or (DtType = 'T')) then
    exit;
  if (pos(' ', St) = 0) and (DtType = 'DT') then
    exit;
  Result := True;
end;

function TMyStringHelper.IsNumberLeftPart(St: string): Integer;
//если строка есть число возвр его длинну
//если начало строки есть число возвр длинну этой части со знаком -
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(St) do
    if St[i] in ['0'..'9'] then
      inc(Result)
    else begin
      Result := -Result;
      Break;
    end;
end;

function TMyStringHelper.IsValidEmail(const Value: string): Boolean;
//проверяетвалидность почтового адреса по формальным признакам (адрес должен соответствовать стандарту)

  function CheckAllowed(const s: string): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := 1 to Length(s) do begin
      if not (s[i] in ['a'..'z', 'A'..'Z', '0'..'9', '_', '-', '.']) then
        Exit;
    end;
    Result := True;
  end;

var
  i: Integer;
  namePart, serverPart: string;
begin
  Result := False;
  i := Pos('@', Value);
  if i = 0 then
    Exit;
  namePart := Copy(Value, 1, i - 1);
  serverPart := Copy(Value, i + 1, Length(Value));
  if (Length(namePart) = 0) or ((Length(serverPart) < 5)) then
    Exit;
  i := Pos('.', serverPart);
  if (i = 0) or (i > (Length(serverPart) - 2)) then
    Exit;
  Result := CheckAllowed(namePart) and CheckAllowed(serverPart);
end;

//---------Перевод строки в простые типы

function TMyStringHelper.StrToNumberCommaDot(V: Variant; MinI, MaxI: Extended; var Res: Extended; FDigits: Integer = -1): Boolean;
//проверяем, является ли строка числом в заданном диапозоне с заданным количеством чисел после запятой (не более)
//в качестве разделителей принимаем точку и запятую
//возвращаем число в Res: extended, а Result - истина или ложь /если не удалось преобразовать в число/
var
  e, f1, f2: Extended;
  i, j: Integer;
  St: string;
begin
  Result := False;
  St := NSt(V);
  if St = '' then
    Exit;
  St := StringReplace(St, '.', ',', [rfReplaceAll]);
  i := Pos(',', St);
  f1 := StrToFloatDef(St, 0);
  f2 := StrToFloatDef(St, 1);
  if f1 <> f2 then begin
    St := StringReplace(St, ',', '.', [rfReplaceAll]);
    i := Pos('.', St);
    f1 := StrToFloatDef(St, 0);
    f2 := StrToFloatDef(St, 1);
    if f1 <> f2 then
      Exit;
  end;
  if f1 < MinI then
    Exit;
  if f1 > MaxI then
    Exit;
  if i <> 0 then
    i := Length(St) - i;
  if (FDigits <> -1) and (FDigits < i) then
    Exit;
  Res:= f1;
  Result := True;
end;

function TMyStringHelper.VarToInt(v: Variant; Def: Integer = -1): Integer;
//преобразует тип Variant в Integer; при неудаче возвращает значение Def
var
  st: string;
begin
  st := v;
  if IsInt(st) then
    Result := v
  else
    Result := Def;
end;

function TMyStringHelper.VarToFloat(v: Variant; Def: extended = -1): extended;
//преобразует тип Variant в Extended; при неудаче возвращает значение Def
var
  st: string;
begin
  st := NSt(v);
  if IsFloat(st) then
    Result := v
  else
    Result := Def;
end;

function TMyStringHelper.SpacedStToDate(St: string; FullDateTime: Boolean = False): TDateTime;
//преобразует строку из трех или пяти чисел, разделенных пробелами (дефисами, точками), в TDateTime
//если ошиибка возвращает BadDate
//использовать только при вводе вручную или при явно корректном формате так как в среде будет вызываться исключение
var
  i: Integer;
  ar: TStringDynArray;
  y: Integer;
begin
  Result := BadDate;
  St := ChangeChars(St, ['-', '.'], ' ', True);
  St := ChangeChars(St, [' ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], '!', False);
  if pos('!', St) > 0 then
    Exit;
  A.ExplodeP(St, ' ', ar);
  if High(ar) < 2 then
    Exit;
  try
    y := StrToIntDef(iif(Length(ar[2]) = 2, '20' + ar[2], ar[2]), -1);
    if (y < 2000) or (y > 2100) then
      exit;
    if FullDateTime then
      Result := EncodeDateTime(y, StrToInt(ar[1]), StrToInt(ar[0]), StrToInt(ar[3]), StrToInt(ar[4]), 0, 0)
    else
      Result := EncodeDate(StrToInt(iif(Length(ar[2]) = 2, '20' + ar[2], ar[2])), StrToInt(ar[1]), StrToInt(ar[0]));
  except
    Result := BadDate;
  end;
end;

function TMyStringHelper.NumToString(Number: Extended; Len: byte; Ch: Char): string;
//преобразовывает число в строку длиной не менее Len, позиции перед числом заполняет символом Ch
var
  St: string;
  i: byte;
begin
  if Len > 0 then
    str(Number: Len, St)
  else
    str(Number, St);
  i := 1;
  while St[i] = ' ' do begin
    St[i] := Ch;
    inc(i);
  end;
  Result := St;
end;

function TMyStringHelper.DateTimeToIntStr(dt: TDateTime): string;
//преобразует TDateTime в число (Double) и возвращает в  виде строки
//сервисная функция
begin
  Result := FloatToStr(Double(dt));
end;



//--------- Обработка значений типа Null, переданных в параметре Varint

function TMyStringHelper.NSt(St: Variant): string;
//возвращает пустую строку, если значение Empty или Null
begin
  if VarIsEmpty(St) or (St = null) then begin
    Result := '';
    exit;
  end;
  Result := St;
end;

function TMyStringHelper.NNum(St: Variant; Default: Extended = 0): Extended;
//возвращает 0 с типом extended, если значение Empty или Null
begin
  Result := Default;
  if NSt(St) = '' then
    Exit;
  Result := St;
end;

function TMyStringHelper.NInt(St: Variant): Integer;
//возвращает 0 с типом Integer, если значение Empty или Null
begin
  Result := 0;
  if NSt(St) = '' then
    Exit;
  Result := St;
end;

function TMyStringHelper.NIntM(St: Variant): Integer;
//возвращает -1 с типом Integer, если значение Empty или Null
begin
  Result := -1;
  if NSt(St) = '' then
    Exit;
  Result := St;
end;

function TMyStringHelper.NullIfEmpty(v: Variant): Variant;
//возвращает нулл если v=null or VarToString(v) ='', иначе вернет переданное значение
begin
  Result := v;
  if Result = null then
    Exit;
  if VarToStr(v) = '' then
    Result := null;
//  if (VarType(v) and VarTypeMask = varString) and (v = '') then Result:=null;
end;

function TMyStringHelper.NullIf0(v: Variant): Variant;
//возвращает нулл если v=0 (0.00), иначе вернет переданное значение
begin
  Result := v;
  if Result = null then
    Exit;
  if extended(v) = 0 then
    Result := null;
end;

//--------------- Изменение регистра строк и символов

function TMyStringHelper.ChangeCaseStr(St: string; ToUpper: Boolean): string;
//изменить регистр строки (и латинские и русские буквы
begin
  if ToUpper then
    Result := St.ToUpper
  else
    Result := St.ToLoWer;
end;

function TMyStringHelper.ToUpper(St: string): string;
//строку в верхний регистр
begin
  Result := St.ToUpper;
end;

function TMyStringHelper.ToLower(St: string): string;
//строку в нижний регистр
begin
  Result := St.ToLower;
end;

function TMyStringHelper.ChangeCaseCh(Ch: Char; ToUpper: Boolean): string;
//изменить регистр символа (и латинские и русские буквы
begin
  Result := ChangeCaseStr(Ch, ToUpper)[1];
end;

function TMyStringHelper.Right(St: string; Cnt: Integer = 1): string;
begin
  Result:=Copy(St, Max(1, Length(St) - Cnt + 1), Cnt);
end;


//---------- Поиск входждений, вычленение позиций вхождений ы строку.

function TMyStringHelper.PosI(StPart, StFull: string): Integer;
//находит позицию подстроки в строке без учета регистра
begin
  Result := Pos(StPart.ToUpper, StFull.ToUpper);
end;

function TMyStringHelper.InCommaStr(stpart, stall: string; ch: Char = ','; IgnoreCase: Boolean = False): Boolean;
//проверяет, содержится ли подстрока в строке значений, разделенных запятыми
begin
  if IgnoreCase
    then Result := Pos(ch + ToUpper(stpart) + ch, ch + ToUpper(stall) + ch) > 0
    else Result := Pos(ch + stpart + ch, ch + stall + ch) > 0;
end;

function TMyStringHelper.InCommaStrI(stpart, stall: string; ch: Char = ','): Boolean;
//проверяет, содержится ли подстрока в строке значений, разделенных запятыми, без учета регистра
begin
  Result := Pos(ch + stpart.ToLower + ch, ch + stall.ToLower + ch) > 0;
end;

function TMyStringHelper.GetCharCountInStr(St: string; Chars: TCharSet; p1: Integer = 1; p2: Integer = -1): Integer;
//подсчитывает количество символов из переданного набора в строке, начиная с позиции р1 и до р2 (если -1 то до конца строки)
var
  i: Integer;
begin
  if p2 < 0 then
    p2 := Length(St);
  Result := 0;
  for i := p1 to p2 do
    if St[i] in Chars then
      inc(Result);
end;

function TMyStringHelper.FindBegWord(Start: Integer; St: string; DivSymbols: TCharSet = [' ']): Integer;
//ищем позицию начяала слова в строке, передается начальная позиция поиска,
//счетчик идет назад пока не встретистся символ из DivSymbols
var
  i: Integer;
begin
  i := Start;
  while (i > 0) and not (St[i] in DivSymbols) do
    dec(i);
  inc(i);
  FindBegWord := i;
end;

function TMyStringHelper.FindEndWord(Start: byte; st: string; DivSymbols: TCharSet = [' ']): Integer;
//ищем позицию конца слова в строке, передается начальная позиция поиска,
//счетчик идет вперед пока не встретистся символ из DivSymbols
var
  i: Integer;
begin
  i := Start;
  while (i <= Length(st)) and not (st[i] in DivSymbols) do
    inc(i);
  if i > Length(st) then
    dec(i);
  FindEndWord := i;
end;

function CharInSetEh(C: Char; const CharSet: TSysCharSet): Boolean;
begin
{$IFDEF EH_LIB_12}
  Result := CharInSet(C, CharSet);
{$ELSE}
  Result := C in CharSet;
{$ENDIF}
end;

function ExtractWordPos(N: Integer; const S: string; WordDelims: TCharSet; var Pos: Integer): string;
//нужно для EhLib
var
  I, Len: Integer;
begin
  Len := 0;
  I := WordPosition(N, S, WordDelims);
  Pos := I;
  Result := '';
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and not ({$IFNDEF CIL}
      (ByteType(S, I) = mbSingleByte) and{$ENDIF}
      CharInSetEh(S[I], WordDelims)) do begin
      { add the I'th character to result }
      Inc(Len);
      Result := Result + S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;

function ExtractWord(N: Integer; const S: string; WordDelims: TCharSet): string;
//нужно для EhLib
var
  I: Word;
  Len: Integer;
begin
  Result := '';
  Len := 0;
  I := WordPosition(N, S, WordDelims);
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and not ({$IFNDEF CIL}
      (ByteType(S, I) = mbSingleByte) and{$ENDIF}
      CharInSetEh(S[I], WordDelims)) do begin
      { add the I'th character to result }
      Inc(Len);
      Result := Result + S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;

function VarIndex(Value: Variant; const AVar: array of Variant): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(AVar) - 1 do
    if AVar[i] = Value then begin
      Result := i;
      Break;
    end;
end;

function WordPosition(const N: Integer; const S: string; WordDelims: TCharSet): Integer;
//НЕ разобрался пока что
var
  Count, I: Integer;
begin
  Count := 0;
  I := 1;
  Result := 0;
  while (I <= Length(S)) and (Count <> N) do begin
    { skip over delimiters }
    while (I <= Length(S)) and (      {$IFNDEF CIL}
      (ByteType(S, I) = mbSingleByte) and      {$ENDIF}
      CharInSetEh(S[I], WordDelims)) do
      Inc(I);
      { if we're not beyond end of S, we're at the start of a word }
    if I <= Length(S) then
      Inc(Count);
      { if not finished, find the end of the current word }
    if Count <> N then
      while (I <= Length(S)) and not (          {$IFNDEF CIL}
        (ByteType(S, I) = mbSingleByte) and          {$ENDIF}
        CharInSetEh(S[I], WordDelims)) do
        Inc(I)
    else
      Result := I;
  end;
end;

procedure TMyStringHelper.DivisionQuotetStr(st, st1, st2, st3: string);
//разбиение строки St на 3 части: St1 -до кавычек, St2 - в кавычках, St3 - после
//кавычки учитываются как двойные так и одинарные
//осталось от старого
var
  a, b, i, j: Integer;
begin
  st1 := '';
  st2 := '';
  st3 := '';
  {Выделение подстроки, заключенной в кавычки (начало - a, конец - b}
  a := 1;
  b := 0;
  while (a < Length(st)) and not (st[a] in ['"', '''']) do
    inc(a);
  if st[a] in ['"', ''''] then begin
    b := a + 1;
    while (b < Length(st)) and not (st[b] in ['"', '''']) do
      inc(b);
    if not (st[b] in ['"', '''']) and (b > a) then begin
      b := 0;
      a := 0;
    end;
  end
  else
    a := 0;
  {удаление пробелов на концах подстроки, заключенной в кавычки}
  if (a <> 0) and (b <> 0) and (b > a + 1) then begin
    i := a + 1;
    j := b - 1;
    while (i < j) and (st[i] = ' ') do
      inc(i);
    while (i < j) and (st[j] = ' ') do
      dec(j);
    if (i <> j) then
      st2 := copy(st, i, j - i + 1);
  end;
  if a = 0 then
    st1 := st
  else
    st1 := copy(st, 0, a - 1);
  if b = 0 then
    st3 := ''
  else
    st3 := copy(st, b + 1, Length(st) - b);
end;

function TMyStringHelper.GetSubSt(SourceSt: string; NumSubSt: Integer; DivSt: string; var PosSt: Integer): string;
//получает подстроку номер NumSubSt из строки, которую разбивает по строковым разделителям DivSt
//возвращает также позицию найденной подстроки в строке
//если не смог выделить подстроку, то возвращает -2 и ''
var
  St1: string;
  i, j: byte;
begin
  PosSt := 1;
  St1 := SourceSt;
  for i := 1 to NumSubSt do begin
    j := Pos(DivSt, St1);
    if i = NumSubSt then begin
      if j <> 0 then
        St1 := Copy(St1, 1, j - 1);
      Break;
    end
    else begin
      if (j = 0) or (j >= Length(St1)) then begin
        PosSt := -1;
        Break;
      end;
      St1 := Copy(St1, j + Length(DivSt), Length(St1) - j);
      PosSt := PosSt + j + Length(DivSt) - 1;
    end;
  end;
  if PosSt > 0 then
    GetSubSt := St1
  else
    GetSubSt := '';
end;

function TMyStringHelper.FindMaskInStr(var Mask, St: string): Boolean;
//Поиск по маске:  Сpавнение стpоки St с шаблоном Mask. В шаблоне можно
//yпотpеблять знаки '?'(любой знак) и '*' (любое количество любых знаков)
var
  i, j, k, Cp: Integer;
  Sp, Mp, Last: Integer;
  Sl, Ml: Integer;
begin
  Result := False;
  Sp := 1;
  Mp := 1;
  Sl := Length(St);
  Ml := Length(Mask);
  {Сpавнить начало (до пеpвого символа '*') шаблона с именем}
  repeat
    if (Sp > Sl) then begin
      Result := Mp > Ml;
      Exit;
    end;
    if (Mask[Mp] <> '?') and (Mask[Mp] <> St[Sp]) then
      Break;
    inc(Mp);
    inc(Sp);
  until False;
  if Mask[Mp] <> '*' then begin
    Result := False;
    Exit;
  end;
  repeat
    {Если символ гpyппы, значит стаpая гpyппа совпала и  }
    {нyжно запомнить новые стаpтовые позиции сpавнения   }
    while (Mask[Mp] = '*') do  {while - защита от "**"}
    begin
      inc(Mp);
      Last := Mp;
        {Если '*' стоит в конце шаблона, то сканиpовать }
        {хвост стpоки не тpебyется                      }
      if (Mp > Ml) then begin
        Result := True;
        Exit;
      end;
    end;
    {Если кончилось имя, веpнyть pезyльтат сpавнения     }
    if (Sp > Sl) then begin
      Result := Mp > Ml;
      Exit;
    end;
    if (Mask[Mp] <> '?') and (Mask[Mp] <> St[Sp]) then begin
        {Если знак шаблона не совпадает со знаком имени,  }
        {нyжно отстyпить к началy подстpоки и попытаться  }
        {найти её со следyющей позиции имени              }
      Sp := Sp - ((Mp - Last) - 1);
      Mp := Last;
    end
    else begin
      inc(Mp);
      inc(Sp);
    end;
  until False;
end;

function TMyStringHelper.FindADDMaskInStr(Mask, St: string): Boolean;
//Поиск по маске:  Сpавнение стpоки St с шаблоном Mask. В шаблоне можно
//yпотpеблять знаки '?'(любой знак) и '*' (любое количество любых знаков)}
var
  i, j, k, Cp: Integer;
  Sp, Mp, Last: Integer;
  Sl, Ml: Integer;
begin
  Result := False;
  Sp := 1;
  Mp := 1;
  Sl := Length(St);
  Ml := Length(Mask);
  {Сpавнить начало (до пеpвого символа '*') шаблона с именем}
  repeat
    if (Sp > Sl) then begin
      Result := Mp > Ml;
      Exit;
    end;
    if ((Mask[Mp] = #1) and (St[Sp] in ['0'..'9'])) or ((Mask[Mp] = #2) and (St[Sp] in ['1'..'9'])) or ((Mask[Mp] = #3) and (St[Sp] in ['a'..'z', 'A'..'Z'])) or ((Mask[Mp] = #4) and (St[Sp] in ['A'..'Z'])) or ((Mask[Mp] = #5) and (St[Sp] in ['a'..'z']))//       or
//!!!!
//       ((Mask[Mp] = #6)and (St[Sp] in ['а'..'я','А'..'Я','ё','Ё']))or
//       ((Mask[Mp] = #7)and (St[Sp] in ['А'..'Я','Ё']))or
//       ((Mask[Mp] = #8)and (St[Sp] in ['а'..'я','ё']))
      then begin
    end
    else if (Mask[Mp] <> '?') and (Mask[Mp] <> St[Sp]) then
      Break;
    inc(Mp);
    inc(Sp);
  until False;
  if Mask[Mp] <> '*' then begin
    Result := False;
    Exit;
  end;
  repeat
    {Если символ гpyппы, значит стаpая гpyппа совпала и  }
    {нyжно запомнить новые стаpтовые позиции сpавнения   }
    while (Mask[Mp] = '*') do  {while - защита от "**"}
    begin
      inc(Mp);
      Last := Mp;
        {Если '*' стоит в конце шаблона, то сканиpовать }
        {хвост стpоки не тpебyется                      }
      if (Mp > Ml) then begin
        Result := True;
        Exit;
      end;
    end;
    {Если кончилось имя, веpнyть pезyльтат сpавнения     }
    if (Sp > Sl) then begin
      Result := Mp > Ml;
      Exit;
    end;
    if (Mask[Mp] <> '?') and (Mask[Mp] <> St[Sp]) then begin
        {Если знак шаблона не совпадает со знаком имени,  }
        {нyжно отстyпить к началy подстpоки и попытаться  }
        {найти её со следyющей позиции имени              }
      Sp := Sp - ((Mp - Last) - 1);
      Mp := Last;
    end
    else begin
      inc(Mp);
      inc(Sp);
    end;
  until False;
end;


//-------------------- Преобразования на основе строк/чисел в строковую инфу
//-- например, вывод цены в рублях и копецках

function TMyStringHelper.NumToPhoneStr(Num: longint): string;
//преобразование числа в строку телефона с разделителями
var
  St: string;
begin
  Str(Num: 6, St);
  if Length(St) <= 7 then begin
    insert('-', St, Length(St) - 1);
    insert('-', St, Length(St) - 4);
  end;
  NumToPhoneStr := St;
end;

function TMyStringHelper.StrToPhoneStr(StT: string): string;
//форматирование строки как строки телефона с разделителями
var
  St: string;
  i, j: longint;
  er: Integer;
begin
  St := StT;
  DelBoth(St, [' ']);
  er := 0;
  for i := 1 to Length(St) do
    if not (St[i] in ['0'..'9']) then
      er := -1;
  if (Length(St) <= 7) and (er = 0) then begin
    insert('-', St, Length(St) - 1);
    insert('-', St, Length(St) - 4);
  end;
  StrToPhoneStr := St;
end;

function TMyStringHelper.NumToPriceWords(Num: longInt; Mode: Boolean): string;
//преобразование числа в строку цены прописью
var
  Num1: longint;
  St: string;
begin
  if Mode then begin
    Num1 := Num mod 100;
    Num := Num div 100;
    St := NumToWords(Num, 'm') + PriceWord(Num, 'r') + ' ';
    if Num1 < 10 then
      St := St + 'ноль ';
    St := St + NumToWords(Num1, 'f') + PriceWord(Num1, 'k');
  end
  else begin
    Num := Num * 10;
    St := NumToWords(Num, 'm') + PriceWord(Num, 'r');
  end;
  Result := St;
end;

function TMyStringHelper.NumToWords(Num: longint; Mode: char): string;
//преобразование числа в строку прописью
var
  n, n1: Integer;
  St, St1: string;
  i, j: ShortInt;
  Rank: longint;
  a: Boolean;
const
  NumWords: array[1..3, 1..9] of string[11] = (('один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять'), ('десять', 'двадцать', 'тридцать', 'сорок', 'пятьдесят', 'шестьдесят', 'семьдесят', 'восемьдесят', 'девяносто'), ('сто', 'двести', 'триста', 'четыреста', 'пятьсот', 'шестьсот', 'семьсот', 'восемьсот', 'девятьсот'));
  NumWords_1X: array[0..9] of string[12] = ('десять', 'одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать');
  NumWords_F: array[1..2] of string[4] = ('одна', 'две');
  NumWords_N: array[1..1] of string[4] = ('одно');
  RankWords: array[1..2, 1..3] of string[9] = (('тысяча', 'тысячи', 'тысяч'), ('миллион', 'миллиона', 'миллионов'));
  Zero: string[4] = 'ноль';
begin
  if Num = 0 then begin
    NumToWords := Zero + ' ';
    Exit;
  end;
  Mode := UpCase(Mode);
  St := '';
  Rank := 100000000;
  i := 2;
  repeat
    j := 3;
    a := False;
    repeat
      n1 := n;
      n := Num mod (Rank * 10) div Rank;
      if ((n > 0) and not ((j = 2) and (n = 1))) or ((j = 1) and (n1 = 1)) then begin
        if (j = 1) and (n1 = 1) then
          St := St + NumWords_1X[n] + ' '
        else begin
          if (j = 1) and (n < 3) and ((i = 1) or ((Mode = 'F') and (i = 0))) then
            St := St + NumWords_F[n] + ' '
          else begin
            if (j = 1) and (n < 2) and (Mode = 'N') and (i = 0) then
              St := St + NumWords_N[n] + ' '
            else
              St := St + NumWords[j][n] + ' ';
          end;
        end;
        a := True;
      end;
      dec(j);
      Rank := Rank div 10;
    until j = 0;
    if a and (i <> 0) then begin
      if n1 <> 1 then
        case n of
          1:
            St := St + RankWords[i][1];
          2..4:
            St := St + RankWords[i][2];
        else
          St := St + RankWords[i][3];
        end
      else
        St := St + RankWords[i][3];
      if i > 0 then
        St := St + ' ';
    end;
    dec(i)
  until i = -1;
  Result := St;
end;

function TMyStringHelper.PriceWord(Num: longint; Mode: Char): string;
//сервисная функция для вывода цены с включением слов Рублей и Копеек
begin
  Mode := UpCase(Mode);
  case Mode of
    'R':
      if (Num div 10) <> 1 then
        case (Num mod 10) of
          1:
            PriceWord := 'рубль';
          2..4:
            PriceWord := 'рубля';
        else
          PriceWord := 'рублей';
        end
      else
        PriceWord := 'рублей';
    'K':
      if (Num div 10) <> 1 then
        case (Num mod 10) of
          1:
            PriceWord := 'копейка';
          2..4:
            PriceWord := 'копейки';
        else
          PriceWord := 'копеек';
        end
      else
        PriceWord := 'копеек';
  end;
end;

function TMyStringHelper.NumToPriceStr(Num: longint): string;
//преобразует число в сцену в рублях и копейках в виде числа а не слов
//работает тут НЕПРАВИЛЬНО, цена в целом числе, 2 последние это копейки
var
  St: string[20];
  Minus: Boolean;
begin
  Minus := False;
  if Num < 0 then begin
    Minus := True;
    Num := abs(Num)
  end;
  str(Num, St);
  if (Num = 0) then
    St := '0' + KopDividor + '00'
  else if (Num < 10) then
    St := '0' + KopDividor + '0' + St
  else if (Num < 100) then
    St := '0' + KopDividor + St
  else begin
    System.Insert(KopDividor, St, Length(St) - 1);
    if RubDividor <> '0' then begin
      if (Length(St) > 5 + Length(KopDividor)) then
        System.Insert(RubDividor, St, Length(St) - 4 - Length(KopDividor));
      if (Length(St) > 8 + Length(RubDividor) + Length(KopDividor)) then
        System.Insert(RubDividor, St, Length(St) - 7 - Length(RubDividor) + Length(KopDividor));
      if (Length(St) > 11 + 2 * Length(RubDividor) + Length(KopDividor)) then
        System.Insert(RubDividor, St, Length(St) - 10 - 2 * Length(RubDividor) + Length(KopDividor));
    end;
  end;
  if Kop2Dividor <> '' then begin
    if Num < 100 then
      System.Delete(St, 1, 1 + Length(KopDividor));
    St := St + Kop2Dividor;
  end;
  if Minus then
    St := '-' + St;
  NumToPriceStr := St;
end;

function TMyStringHelper.GetEnding(Num: longint; St1, St2, St3: string): string;
//выбирает окончание по количеству
//(передается окончание для кол-ва 1, 2{3,4}, 5(6,7,8,9,10)
begin
  if not ((Num mod 100) in [10..20]) then
    case (Num mod 10) of
      1:
        GetEnding := St1;
      2..4:
        GetEnding := St2;
    else
      GetEnding := St3;
    end
  else
    Result := St3;
end;

function TMyStringHelper.GetEndingFull(Num: longint; Main, St1, St2, St3: string): string;
begin
  Result:=InttoStr(Num) + ' ' + Main + Getending(Num, St1, St2, St3);
end;


function TMyStringHelper.GetEndingOneOrMany(Num: longint; St1, St2: string): string;
//выбирает окончание по количеству (толькко ед/множ число)
begin
  if Num = 1 then
    Result := St1
  else
    Result := St2;
end;

function TMyStringHelper.AddBracket(st: string): string;
//заключить строку в круглые скобки, если она не пустая
begin
  Result := st;
  if Result <> '' then
    Result := '(' + Result + ')';
end;

function TMyStringHelper.FormatNumberWithComma(Value: Extended; DivIsComma: Boolean = True): string;
//форматируем число в строку. если есть дробная часть, то она будет дана через запятую (по умолчанию) или точку
var
  s: string;
begin
  if SameValue(Value, Int(Value), 1E-9) then
    s := FormatFloat('0', Value)
  else
    s := FormatFloat('0.########', Value);
  if DivIsComma then
    Result := StringReplace(s, '.', ',', [rfReplaceAll])
  else
    Result := StringReplace(s, ',', '.', [rfReplaceAll]);
end;








//-------------------------- Условные функции
//-- Важно: в отличии от выражений параметры в функциях будут вычислены ВСЕГДА при их в нее передаче

function TMyStringHelper.IIf(Expr: Boolean; Par1, Par2: Variant): Variant;
//если Expr истина, то вернет Par1, иначе Par2
//варианта для аргументов Variant, string, Integer, extended
begin
  if Expr then
    Result := Par1
  else
    Result := Par2;
end;

function TMyStringHelper.IIfV(Expr: Boolean; Par1, Par2: Variant): Variant;
begin
  if Expr then
    Result := Par1
  else
    Result := Par2;
end;

function TMyStringHelper.IIFStr(Expr: Boolean; Par1: string; Par2: string = ''): string;
begin
  if Expr then
    Result := Par1
  else
    Result := Par2;
end;

function TMyStringHelper.IfEmptyStr(St: string; StIfEmpty: string): string;
begin
  Result := St;
  if Result = '' then
    Result := StIfEmpty;
end;

function TMyStringHelper.IfNotEmptyStr(St: string; Mask: string = #0; StIfEmpty: string = ''): string;
begin
  Result := St;
  if Result <> '' then
    Result := StringReplace(Mask, #0, Result, [rfReplaceAll])
  else
    Result := StIfEmpty;
end;


function TMyStringHelper.IIfInt(Expr: Boolean; Par1, Par2: Integer): Integer;
begin
  if Expr then
    Result := Par1
  else
    Result := Par2;
end;

function TMyStringHelper.IIfFloat(Expr: Boolean; Par1, Par2: extended): Extended;
begin
  if Expr then
    Result := Par1
  else
    Result := Par2;
end;

function TMyStringHelper.IfEl(AValue, AIfValeu, AElseValue: Variant): Variant;
//Если AValue = AIfValeu, то вернет AIfValeu, иначе AElseValue
begin
  if AValue = AIfValeu then Result:= AIfValeu else Result:= AElseValue;
end;


function TMyStringHelper.IfNotEqual(ValueFact, ValueCheck, ValueRes: Variant): Variant;
//если ValueFact не пустое (empty, '', null), то вернет ValueFact, иначе ValueRes
begin
  if ValueFact = ValueCheck then
    Result := ValueFact
  else
    Result := ValueRes;
end;

function TMyStringHelper.IfNotEmpty(ValueFact, ValueRes: Variant): Variant;
//возвращает из массива результат, соответствующий нулевому значению
begin
  if not (VarIsEmpty(ValueFact) or (VarToStr(ValueFact) = '')) then
    Result := ValueFact
  else
    Result := ValueRes;
end;

function TMyStringHelper.Decode(ar: TVarDynArray): Variant;
//возвращает из массива результат, соответствующий нулевому значению
//value, case1, value1, case2, value2, {valueelse}
var
  i, j: Integer;
  v: Variant;
begin
  Result := null;
  i := 1;
  while i < High(ar) do begin
    if ar[0] = ar[i] then begin
      Result := ar[i + 1];
      Exit;
    end;
    i := i + 2;
  end;
  if i = High(ar) then
    Result := ar[i];
end;

//сравнить две строки без учета регистра
function TMyStringHelper.CompareStI(st1, st2: string): Boolean;
begin
  Result := ToUpper(st1) = ToUpper(st2);
end;


//-------------------------- конкатенация строк

function TMyStringHelper.ConcatSt(StAll, StPart: string; Dividor: string = ','; IfNotEmpty: Boolean = False): string;
//добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
begin
  Result := StAll;
  if IfNotEmpty and (StPart = '') then
    Exit;
  if StAll <> '' then
    Result := Result + Dividor;
  Result := Result + StPart;
end;

procedure TMyStringHelper.ConcatStP(var StAll: string; StPart: string; Dividor: string = ','; IfNotEmpty: Boolean = False);
//процедура. добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
begin
  if IfNotEmpty and (StPart = '') then
    Exit;
  if StAll <> '' then
    StAll := StAll + Dividor;
  StAll := StAll + StPart;
end;

procedure TMyStringHelper.ConcatStP(var StAll: Variant; StPart: Variant; Dividor: Variant; IfNotEmpty: Boolean = False);
//процедура. добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
begin
  if IfNotEmpty and (VarToStr(StPart) = '') then
    Exit;
  if VarToStr(StAll) <> '' then
    StAll := VarToStr(StAll) + VarToStr(Dividor);
  StAll := VarToStr(StAll) + VarToStr(StPart);
end;



//-------------------------- функции для sql-запросов

function TMyStringHelper.SQLdate(dt: TDateTime): ansistring;
//преобразование даты в строку соотв формату даты в выбранной БД
//форматирует дfту в тот вид, который можно вставить в скл
//в сам текст, в параметра передается просто сам тип даты)
var
  Y, M, D: word;
begin
  DecodeDate(dt, Y, M, D);
  Result := IntToStr(Y) + IifStr(M < 10, '0', '') + IntToStr(M) + IifStr(D < 10, '0', '') + IntToStr(D);
end;

function TMyStringHelper.SQLdateTime(dt: TDateTime): ansistring;
//преобразование даты, включая временнУю часть, в строку соотв формату даты в выбранной БД
var
  Y, M, D, th, tm, ts, tms: word;
begin
  DecodeDateTime(Date, Y, M, D, th, tm, ts, tms);
  Result := IntToStr(Y) + IifStr(M < 10, '0', '') + IntToStr(M) + IifStr(D < 10, '0', '') + IntToStr(D) + IifStr(th < 10, '0', '') + IntToStr(th) + IifStr(tm < 10, '0', '') + IntToStr(tm) + IifStr(ts < 10, '0', '') + IntToStr(ts);
end;



//-------------------------- служебные -----------------------------------------

function TMyStringHelper.GetFieldNameFromSt(st: string): string;
//возвращает имя поля в таблице из имени поля в селесте
//например из '1 as field$s' вернет 'field$s'
var
  ar: TStringDynArray;
begin
  ar := a.ExplodeS(st, ' ');
  Result := ar[High(ar)];
end;

function TMyStringHelper.GetDaysCountToName(Days: Integer): string;
//неделя, 4 дня, месяц, 3 месяца, полгода, год, 68 дней - с допусками несколько дней для градаций по месяцам
begin
  case Days of
    7: Result:='неделя';
    14: Result:='2 недели';
    21: Result:='3 недели';
    29,30,31: Result:='месяц';
    60,61,62: Result:='2 месяца';
    90..93: Result:='3 месяца';
    120..124: Result:='4 месяца';
    30*5..31*5: Result:='4 месяца';
    30*6..31*6: Result:='полгода';
    30*7..31*7: Result:='7 месяцев';
    30*8..31*8: Result:='8 месяцев';
    30*9..31*9: Result:='9 месяцев';
    30*10..31*10: Result:='10 месяцев';
    30*11..31*11: Result:='11 месяцев';
    365..366: Result:='год';
  else
    Result:=InttoStr(Days) + ' ' + GetEnding(Days, 'день','дня','дней');
  end;
end;


function TMyStringHelper.GetDBFieldNameFromSt(st: string; WithMod: Boolean = False): string;
//возвращает имя поля в таблице из имени поля в селесте
//например из '1 as field$s' вернет 'field', а если установлен WithMod, то 'field$s'
var
  ar: TStringDynArray;
begin
  ar := a.ExplodeS(st, ' ');
  if WithMod
    then Result:=ar[High(ar)]
    else begin
      ar := a.ExplodeS(ar[High(ar)], '$');
      Result := ar[0];
    end;
end;

procedure TMyStringHelper.SwapPlaces(v1, v2: Variant);
//производит обмен значениями между двумя переменными
var
  v: Variant;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

(*function ParseCsv(St: string; DivCh: Char): tSplitArray;
//пасрсит строку Csv в массив
//функция устаревшая, если использовать надо будет переделывать
var
  i,j,p,q:Integer;
  ParseCsv_:tsplitarray;
begin
//"""",,"qwerty","1,2",1,3
//корректная строка/подстрока не должна содержать непарную кавычку
  p:=0;q:=0;
  ParseCsv_[1]:='';
  if st[length(st)]<>DivCh then st:=st+DivCh;
  for i:=1 to length(st) do
    begin
      if st[i]='"' then q:=q+1;
      if ((st[i]=DivCh)and(q mod 2 = 0)) then
        begin
          p:=p+1;q:=0;
          if pos('"',ParseCsv_[p])=1 then
            ParseCsv_[p]:=copy(ParseCsv_[p],2,length(ParseCsv_[p])-2);
          ParseCsv_[p+1]:='';
        end
        else ParseCsv_[p+1]:=ParseCsv_[p+1]+st[i];
    end;
  ParseCsv_[0]:=inttostr(p);
  REsult:=ParseCsv_;
end;*)

function TMyStringHelper.CorrectFileName(st: string): string;
//скорректируем строку для использования в качестве имени файла
var
  i: Integer;
  ch: Char;
begin
  Result := Trim(st);
  //заменим надопустимые символы
  Result := StringReplace(Result, #9, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '''', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '\', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '|', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '-', [rfReplaceAll]);
  Result := StringReplace(Result, ':', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '*', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '?', '-', [rfReplaceAll]);
  //уберем точки справа
  //для самбы - если создаются каталоги с правой точнокоЙ, то в винде получается непонятное испорченное короткое имя каталога,
  //в линкс же каталог не виден вообще, но при этом существует
  while (Length(Result) > 0) and (Result[Length(Result)] = '.') do
    Delete(Result, Length(Result), 1);
 { for i:=Length(Result) downto 1 do begin
    Ch:=Char(Copy(Result, i, 1));
    if not (TPath.IsValidFileNameChar(Ch) and TPath.IsValidPathChar(Ch))
      then Delete(Result, i);
  end;}
end;

function TMyStringHelper.ValidateInn(inn: Variant): string;
//проверка валидности ИНН, возвращает пустую строку если нет ошибки, или текстовое описание ошибки
var
  error_code: Integer;
  error_message: string;
  n11: Integer;
  n12: Integer;

  function check_digit(inn: string; coefficients: TVarDynArray): Integer;
  var
    i, n: Integer;
  begin
    n := 0;
    for i := 0 to High(coefficients) do
      n := n + coefficients[i] * StrToInt(inn[i + 1]);
    Result := n mod 11 mod 10;
  end;

begin
  error_message := '';
  result := error_message;
  error_code := 0;
  inn := VarToStr(inn);
  if (inn = '') then begin
    error_code := 1;
    error_message := 'ИНН пуст';
  end
  else if StrToFloatDef(inn, -1) = -1 then begin
    error_code := 2;
    error_message := 'ИНН может состоять только из цифр';
  end
  else if not (Length(inn) in [10, 12]) then begin
    error_code := 3;
    error_message := 'ИНН может состоять только из 10 или 12 цифр';
  end
  else begin
    if (Length(inn) = 10) and (check_digit(inn, [2, 4, 10, 3, 5, 9, 4, 6, 8]) = StrToInt(VarToStr(inn)[10])) then
      Exit
    else if (Length(inn) = 12) then begin
      n11 := check_digit(inn, [7, 2, 4, 10, 3, 5, 9, 4, 6, 8]);
      n12 := check_digit(inn, [3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8]);
      if (n11 = StrToInt(VarToStr(inn)[11])) and (n12 = StrToInt(VarToStr(inn)[12])) then
        Exit;
    end;
    error_code := 4;
    error_message := 'Неправильное контрольное число';
  end;
  result := error_message;
end;

function TMyStringHelper.StringToPAnsiChar(stringVar: string): PAnsiChar;
//конвертация типа string в PAnsiChar c проверкой (при ошибке исключение)
var
  AnsString: AnsiString;
  InternalError: Boolean;
begin
  InternalError := False;
  Result := '';
  try
    if stringVar <> '' then begin
      AnsString := AnsiString(stringVar);
      Result := PAnsiChar(PAnsiString(AnsString));
    end;
  except
    InternalError := True;
  end;
  if InternalError or (string(Result) <> stringVar) then begin
    raise Exception.Create('Conversion from string to PAnsiChar failed!');
  end;
end;


//-------------------- математические ------------------------------------------

function TMyStringHelper.MaxOf(const Values: array of Variant): Variant;
//выбирает максимальное значение из вариантного массива
var
  I: Cardinal;
begin
  Result := Values[0];
  for I := 0 to High(Values) do
    if Values[I] > Result then
      Result := Values[I];
end;

function TMyStringHelper.MinOf(const Values: array of Variant): Variant;
//выбирает минимальное значение из вариантного массива
var
  I: Cardinal;
begin
  Result := Values[0];
  for I := 0 to High(Values) do
    if Values[I] < Result then
      Result := Values[I];
end;


(*

TUnicodeHeper.StringToWideString(s, 1252);
*)

function TMyStringHelper.WideStringToString(const ws: WideString; codePage: Word): AnsiString;
var
  l: Integer;
begin
(*  if ws = '' then
    Result := ''
  else begin
    l := WideCharToMultiByte(codePage, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, @ws[1], -1, nil, 0, nil, nil);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(codePage, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, @ws[1], -1, @Result[1], l - 1, nil, nil);
  end;*)
end;

function TMyStringHelper.StringToWideString(const s: AnsiString; codePage: Word): WideString;
{:Converts Ansi string to Unicode string using specified code page.
  @param   s        Ansi string.
  @param   codePage Code page to be used in conversion.
  @returns Converted wide string.
 }
var
  l: Integer;
begin
(*  if s = '' then
    Result := ''
  else begin
    l := MultiByteToWideChar(codePage, MB_PRECOMPOSED, PChar(@s[1]), -1, nil, 0);
    SetLength(Result, l - 1);
    if l > 1 then
      MultiByteToWideChar(codePage, MB_PRECOMPOSED, PChar(@s[1]), -1, PWideChar(@Result[1]), l - 1);
  end;*)
end;

function TMyStringHelper.VarType(Value: Variant): Integer;
//возвращает НЕКОТОРЫЕ сводные типы переменной Variant
//например любое целое иудет varInteger
begin
 Result:= Variants.VarType(Value) and VarTypeMask;
 if Result = 16 then Result:= varInteger;  //так получилось целой отрицательное опытным путем
 if Result in [varSmallInt, varByte, varInteger, varWord, varInt64, 19{целое отрицательное -MaxInt}] then Result:= varInteger;
 if Result in [varSingle, varDouble, varCurrency] then Result:= varDouble;
 if Variants.VarType(Value) and varString = varString then Result:= varString;  //иначе не определяется
{
  case basicType of
    varEmpty     : Result := 'varEmpty';
    varNull      : typeString := 'varNull';
    varSmallInt  : typeString := 'varSmallInt';
    varInteger   : typeString := 'varInteger';
    varSingle    : typeString := 'varSingle';
    varDouble    : typeString := 'varDouble';
    varCurrency  : typeString := 'varCurrency';
    varDate      : typeString := 'varDate';
    varOleStr    : typeString := 'varOleStr';
    varDispatch  : typeString := 'varDispatch';
    varError     : typeString := 'varError';
    varBoolean   : typeString := 'varBoolean';
    varVariant   : typeString := 'varVariant';
    varUnknown   : typeString := 'varUnknown';
    varByte      : typeString := 'varByte';
    varWord      : typeString := 'varWord';
    varLongWord  : typeString := 'varLongWord';
    varInt64     : typeString := 'varInt64';
    varStrArg    : typeString := 'varStrArg';
    varString    : typeString := 'varString';
    varAny       : typeString := 'varAny';
    varTypeMask  : typeString := 'varTypeMask';
  end;
  }
end;

function TMyStringHelper.VarIsClear(const V: Variant): Boolean;
//проверяет, задано ли значение переменной типа Variant
var
  LHandler: TCustomVariantType;
  LVarData: TVarData;
begin
  LVarData := FindVarData(V)^;
  with LVarData do
    if True{VType < CFirstUserType} then
      Result := (VType = varEmpty) or
                (((VType = varDispatch) or (VType = varUnknown)) and
                  (VDispatch = nil))
    else if FindCustomVariantType(VType, LHandler) then
      Result := LHandler.IsClear(LVarData)
    else
      Result := False;
end;

procedure TMyStringHelper.GetDatePeriod(Period: Variant; dt0: TDateTime; var dt1: TDateTime; var dt2: TDateTime);
//возвращает даты начала и конца периода по массиву DatePeriods (по номеру элемента или названию). если не найдено - возвращает сегодня
//('Сегодня', 'Вчера', 'Эта неделя', 'Прошлая неделя', 'Эти две недели', 'Прошлые две недели', 'Этот месяц', 'Прошлый месяц', ==7
//'Этот квартал', 'Прошлый квартал','Этот год', 'Прошлый год');
var
  i, d, d1, d2, p, y, q, m: Integer;
  dt: TDateTime;
  sa: TStringDynArray;
begin
  dt := Date;
  dt1 := Date;
  dt2 := Date;
  if VarType(Period) = varInteger
    then p := Period
    else begin
      p := 0;
      for p := 1 to High(DatePeriods) do
        if ToUpper(Period) = ToUpper(DatePeriods[p])
          then Break;
    end;
  if (p <= 0) or (p > High(DatePeriods)) then
    Exit;
  case p of
    1: begin dt1 := IncDay(Date, -1); dt2 := dt1; end;
    2: begin dt1 := Date - (DayOfWeek(dt) - 2); dt2 := Date - (DayOfWeek(dt) - 2) + 6; end;
    3: begin dt1 := Date - (DayOfWeek(dt) - 2) - 7; dt2 := Date - (DayOfWeek(dt) - 2) + 6 - 7; end;
    4: begin d := IIf(DayOf(dt) < 16, 1, 16); d2 := Min(d + 15, DaysInMonth(Date)); dt1 := EncodeDate(YearOf(dt), MonthOf(Dt), d); dt2 := EncodeDate(YearOf(dt), MonthOf(Dt), d2); end;
    5: begin dt := IncDay(dt, -14); d := IIf(DayOf(dt) < 16, 1, 16); d2 := Min(d + 15, DaysInMonth(dt)); dt1 := EncodeDate(YearOf(dt), MonthOf(Dt), d); dt2 := EncodeDate(YearOf(dt), MonthOf(Dt), d2); end;
    6: begin dt1 := EncodeDate(YearOf(Date), MonthOf(Date), 1); dt2 := EncodeDate(YearOf(Date), MonthOf(Date), DaysInMonth(Date)); end;
    7: begin dt := IncMonth(Date, -1);  dt1 := EncodeDate(YearOf(dt), MonthOf(dt), 1); dt2 := EncodeDate(YearOf(dt), MonthOf(dt), DaysInMonth(dt)); end;
    8: begin Q := (MonthOf(dt) - 1) div 3 + 1; M := (Q - 1) * 3 + 1; dt1 := EncodeDate(YearOf(dt), M, 1); dt2 := EndOfTheMonth(EncodeDate(YearOf(dt), M + 2, 1)); end;
    9: begin Q := (MonthOf(dt) - 1) div 3 + 1; M := (Q - 1) * 3 + 1; dt1 := EncodeDate(YearOf(dt), M, 1); dt2 := EndOfTheMonth(EncodeDate(YearOf(dt), M + 2, 1)); dt1 := IncMonth(dt1, -3); dt2 := IncMonth(dt2, -3); end;
    10: begin dt1 := EncodeDate(YearOf(Date), 1, 1); dt2 := EncodeDate(YearOf(Date), 12, 31); end;
    11: begin dt1 := EncodeDate(YearOf(Date) - 1, 1, 1); dt2 := EncodeDate(YearOf(Date) - 1, 12, 31); end;
  end;
end;

procedure TMyStringHelper.GetDatesFromPeriodString(st: string; var dt1: TDateTime; var dt2: TDateTime);
begin
  var va := A.Explode(st, ' - ');
  dt1 := StrToDate(va[0]);
  dt2 := StrToDate(va[1]);
end;



function TMyStringHelper.VeryfyValue(ValueType: string; Verify: string; Value: string; var CorrectValue: Variant): Boolean;
//проверка значения строки, по правилам переданным в verify, с учетом типа данных, указанных в ValueType
//для строк возможна коррекция значений

//для числа "min:max:fdigits:N:M"
//(min:max по умолчанию 0, fdigits - не более стольких десятичных цифр, N - не разрешать null, M - подгонять под границы /пока не реализовано/)

//для строки
//CVerify - min:max:digits:inult:validchars:invalidcars
//минимальное и максимальная длина строки
//4 - n - допустимо пустой значение
//4 - i - для комбобокса - значение должно быть в списке
//4 - u/l - для комбо и эдит - вводятся большие или маленькие буквы
//4 - t - трим, p-удалить двойные проьбелы, u,l-регистр
//5 - инвалидные символы
//6 - валидные символы

//для даты
//(0) * - дата обязательна, не допускается пустое, но произвольная
//(0) инт  S.DateTimeToIntStr(Date) - нач дата
//(1) инт  кон. дата
//(2) если '-' то допустимо пустая дата

var
  i, j: Integer;
  v1: string;
  ver: TStringDynArray;
  st, st1, st2, st3: string;
  dt: TDateTime;
  dte: extended;
  b: Boolean;
begin
  Result := True;
  v1 := verify;
  if v1 = '' then
    Exit;
  ver := A.ExplodeS(v1 + '::::::', ':');
  //st := C.Field.AsString;
  st := Value;
  if (ValueType[1] in ['I','i','F','f']) then begin
    if st = '' then
      Result := (pos('N', S.ChangeCaseStr(ver[3], True)) = 0)
    else
      Result := S.IsNumber(st, StrToFloatDef(ver[0], 0), StrToFloatDef(ver[1], 0), StrToIntDef(ver[2], -1));
  end
  else if (ValueType[1] in ['D','d']) then begin
    b :=IsDateTime(st, 'dt');
    if b then
      dt := StrToDateTime(st);
    if (ver[2] = '-') and (st = '') then
      Result := True
    else begin
      if ver[0] = '*' then
        Result := b
      else if IsInt(ver[0]) then
        Result := b and (dt >= StrToInt(ver[0]));
      if IsInt(ver[1]) then
        Result := Result and b and (dt <= StrToInt(ver[1]));
    end;
  end
  else if (ValueType[1] in ['S','s','T','t']) then begin
    st2 := st;
      //регистр - на самом деле не нужно, так как контролл сам приводит к нужному регистру
    if Pos('U', S.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := S.ChangeCaseStr(st2, True);
    if Pos('L', S.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := S.ChangeCaseStr(st2, False);
    if Pos('T', S.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := Trim(st2);
    if Pos('P', S.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := DeleteRepSpaces(st2, ' ');
    st3 := ver[7];
      //уберем невалидные символы
    for j := 1 to Length(st3) do
      st2 := StringReplace(st2, st3[j], '', [rfReplaceAll, rfIgnoreCase]);
      //если строка изменена, то обновим значение
    if st2 <> st then
      st := st2;
     //длина строки в указанных пределах
    Result := (Length(st2) >= StrToIntDef(ver[0], 1)) and (Length(st2) <= StrToIntDef(ver[1], 1));
          //для комбобокса, если нужно, проверим еще в списке ли ли значение
{      if Result and (C is TDBComboboxEh) and (Pos('I', S.ChangeCaseStr(ver[3], True)) > 0) then begin
        Result := (TDBComboboxEh(C).ItemIndex >= 0)
      end;}
  end;
  CorrectValue:=st;
end;




//==============================================================================
//-------------------- массивы ------------------------------------------
//==============================================================================

function TMyArrayHelper.Explode(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TVarDynArray;
//разбивает исходную строку на подстроки, используя как разделитель строку DivSt
//исходная строка может быть и массивом, тогда будет возвращен этот массив
//если не установлено IgnoreEmpty, то элементы могут быть пустыми, и пустая строка станет массивом [''].
//вернет одномерный вариантный массив
var
  St, St1: string;
  i, j: Integer;
begin
  if VarIsArray(V) then begin
    if not IgnoreEmpty then begin
      Result := V;
      Exit;
    end
    else begin
      Result := V;
      Exit;
    end;  //++ добавить проверку когда передан массив и не нужны пустые
  end;
  St1 := VarToStr(V);
  i := -1;
  SetLength(Result, 0);
  repeat
    j := Pos(DivSt, St1);
    if j = 0 then
      j := Length(St1) + 1;
    if not IgnoreEmpty or (j > 1) then begin
      i := i + 1;
      SetLength(Result, i + 1);
      Result[i] := Copy(St1, 1, j - 1);
    end;
    if (j > Length(St1)) then
      Break;
    St1 := Copy(St1, j + Length(DivSt), Length(St1) - j);
  until False;
end;

function TMyArrayHelper.ExplodeV(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TVarDynArray;
//просто алиас Explode
begin
  Result := Explode(V, DivSt, IgnoreEmpty);
end;

function TMyArrayHelper.ExplodeS(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TStringDynArray;
//тоже самое, но возвращает TStringDynArray (перекрыть нельзя, тк определяется только по входным параметрам)
var
  va: TVarDynArray;
  i: Integer;
begin
  Result := [];
  va := Explode(V, DivSt, IgnoreEmpty);
  for i := 0 to High(va) do
    Result := Result + [VarToStr(va[i])];
end;

procedure TMyArrayHelper.ExplodeP(V: Variant; DivSt: string; IgnoreEmpty: Boolean; var Arr: TVarDynArray);
//то же в виде процедур
begin
  Arr := Explode(V, DivSt, IgnoreEmpty);
end;

procedure TMyArrayHelper.ExplodeP(V: Variant; DivSt: string; var Arr: TVarDynArray);
begin
  Arr := Explode(V, DivSt, False);
end;

procedure TMyArrayHelper.ExplodeP(V: Variant; DivSt: string; IgnoreEmpty: Boolean; var Arr: TStringDynArray);
begin
  Arr := ExplodeS(V, DivSt, IgnoreEmpty);
end;

procedure TMyArrayHelper.ExplodeP(V: Variant; DivSt: string; var Arr: TStringDynArray);
begin
  Arr := ExplodeS(V, DivSt, False);
end;

function TMyArrayHelper.Implode(Arr: array of Variant; Delim: string; IgnoreEmpty: Boolean = False): string;
//сливаем одномерный вариантный массив в строку через разделитель;
//если IgnoreEmpty установлен, то игнорируем пустые значения массива
var
  i: Integer;
begin
  Result := '';
  for i := 0 to High(Arr) do begin
    if (IgnoreEmpty) and (VarToStr(Arr[i]) = '') then
      Continue;
    if Length(Result) > 0 then
      Result := Result + Delim;
    Result := Result + VarToStr(Arr[i]);
  end;
end;

function TMyArrayHelper.Implode(Arr: TStringDynArray; Delim: string; IgnoreEmpty: Boolean = False): string;
//сливаем одномерный строковый массив в строку через разделитель;
//если IgnoreEmpty установлен, то игнорируем пустые значения массива
var
  i: Integer;
begin
  Result := '';
  for i := 0 to High(Arr) do begin
    if (IgnoreEmpty) and (VarToStr(Arr[i]) = '') then
      Continue;
    if Length(Result) > 0 then
      Result := Result + Delim;
    Result := Result + VarToStr(Arr[i]);
  end;
end;

function TMyArrayHelper.Implode(Arr: TVarDynArray2; Col: Integer; Delim: string; IgnoreEmpty: Boolean = False): string;
//сливаем в строку переданную колонку двумерного массива
var
  i: Integer;
begin
  Result := '';
  for i := 0 to High(Arr) do
    if (VarToStr(Arr[i][Col]) <> '') or not IgnoreEmpty then
      s.ConcatStP(Result, Arr[i][Col], Delim);
end;

function TMyArrayHelper.Implode(Arr: TVarDynArray2; Columns: TByteSet; Delim1: string; Delim2: string; IgnoreEmpty: Boolean = False): string;
//сливаем в строку весь двухмерный массив по указанным колонкам, разделители для первого и второ уровня разные
var
  i, j: Integer;
  st: string;
begin
  Result := '';
  for i := 0 to High(Arr) do begin
    st := '';
    for j := 0 to High(Arr[i]) do
      if ((Columns = []) or (j in Columns)) and ((VarToStr(Arr[i][j]) <> '') or not IgnoreEmpty) then
        s.ConcatStP(st, VarToStr(Arr[i][j]), Delim1);
    s.ConcatStP(Result, st, Delim2);
  end;
end;

function TMyArrayHelper.ImplodeNotEmpty(Arr: array of Variant; Delim: string): string;
//сливаем одномерный вариантный массив в строку через разделитель;
//пустые элементы всегда игнорируем
begin
  Result := Implode(Arr, Delim, True);
end;

function TMyArrayHelper.ImplodeStringList(var sl: TStringList; Dividor: string = ','): string;
//склеивает текст из TStrings, при этом игнорирует пусты строки с конца списка
begin
  Result := s.TrimSt(sl.Text, [#10, #13], stlBoth);
  Result := StringReplace(sl.text, #13#10, Dividor, [rfReplaceAll]);
end;

function TMyArrayHelper.PosInArray(V: Variant; Arr: array of Variant; IgnoreCase: Boolean = False): Integer;
//находит позицию V в одномерном массиве Arr типа Variant; может не различать регистр
var
  i: Integer;
begin
  Result := Min(-1, Low(Arr) - 1);
  for i := Low(Arr) to High(Arr) do begin
    if (Arr[i] = V) or (IgnoreCase and (s.ToUpper(VarToStr(Arr[i])) = s.ToUpper(VarToStr(V)))) then begin
      Result := i;
      Exit;
    end;
  end;
end;

function TMyArrayHelper.PosInArray(St: string; Arr: TStringDynArray; IgnoreCase: Boolean = False): Integer;
//находит позицию V в одномерном массиве Arr типа строк; может не различать регистр
var
  i: Integer;
begin
  Result := Min(-1, Low(Arr) - 1);
  for i := Low(Arr) to High(Arr) do begin
    if (Arr[i] = St) or (IgnoreCase and (s.ToUpper(Arr[i]) = s.ToUpper(St))) then begin
      Result := i;
      Exit;
    end;
  end;
end;

function TMyArrayHelper.PosInArray(V: Variant; Arr: TVarDynArray; IgnoreCase: Boolean = False): Integer;
//находит позицию V в одномерном массиве Arr типа Variant; может не различать регистр
var
  i: Integer;
begin
  Result := Min(-1, Low(Arr) - 1);
  for i := Low(Arr) to High(Arr) do begin
    if (Arr[i] = V) or (IgnoreCase and (s.ToUpper(VarToStr(Arr[i])) = s.ToUpper(VarToStr(V)))) then begin
      Result := i;
      Exit;
    end;
  end;
end;

function TMyArrayHelper.PosInArray(V: Variant; Arr: TVarDynArray2; FNo: Integer = 0; IgnoreCase: Boolean = False): Integer;
//находит позицию первого уровня для двумерного массива, в которой в поле FNo находится значение V
var
  i: Integer;
begin
  Result := Low(Arr) - 1;
  for i := Low(Arr) to High(Arr) do begin
    if (High(Arr[i]) >= FNo) and ((Arr[i][FNo] = V) or (IgnoreCase and (s.ToUpper(VarToStr(Arr[i][FNo])) = s.ToUpper(VarToStr(V))))) then begin
      Result := i;
      Exit;
    end;
  end;
end;

function TMyArrayHelper.PosInArray(V: TVarDynArray; Arr: TVarDynArray2; FNo: TVarDynArray; IgnoreCase: Boolean = False): Integer;
//найдет позицию в массиве, для которой совпадаю все переданные значения в переданных столбцах\
begin
  Result := Low(Arr) - 1;
  for var i := Low(Arr) to High(Arr) do begin
    var b := True;
    for var j := Low(Arr[i]) to High(Arr[i]) do
      if not ((Arr[i][FNo[j].AsInteger] = V[j]) or (IgnoreCase and (s.ToUpper(VarToStr(Arr[i][FNo[j].AsInteger])) = s.ToUpper(VarToStr(V[j]))))) then begin
        b := False;
        Break;
      end;
    if b then begin
      Result := i;
      Exit;
    end;
  end;
end;

function TMyArrayHelper.PosRowInArray(Needle, Source: TVarDynArray2; NeedleRow: Integer): Integer;
//найдет позицию в массиве Source, при которой все поля совпадаются со строкой массива Needle (размерности 2 уровня должны быть одинаковы, что не провряется)
begin
  Result := Low(Source) - 1;
  for var i := Low(Source) to High(Source) do begin
    var b := True;
    for var j := Low(Source[i]) to High(Source[i]) do
      if not (Source[i][j] = Needle[NeedleRow][j]) then begin
        b := False;
        Break;
      end;
    if b then begin
      Result := i;
      Exit;
    end;
  end;
end;



function TMyArrayHelper.FindValueInArray2(FindValue: Variant; FindFNo: Integer; ResultFNo: Integer; Arr: TVarDynArray2; IgnoreCase: Boolean = False): Variant;
//возвращает значение из столбца ValueFNo, для которого значения в столбце KeyFNo = KeyValue
var
  i: Integer;
begin
  Result := null;
  for i := Low(Arr) to High(Arr) do begin
    if (High(Arr[i]) >= Max(ResultFNo, FindFNo)) and ((Arr[i][FindFNo] = FindValue) or (IgnoreCase and (s.ToUpper(VarToStr(Arr[i][FindFNo])) = s.ToUpper(VarToStr(FindValue))))) then begin
      Result := Arr[i][ResultFNo];
      Exit;
    end;
  end;
end;

function TMyArrayHelper.ReplaceInArray(FindValue: Variant; NewValue: Variant; Arr: TVarDynArray; IgnoreCase: Boolean = False): Boolean;
//заменяем найденное поле в массиве в строке новым значением; возвращает, была ли замена
var
  i: Integer;
begin
  Result := False;
  i := PosInArray(FindValue, Arr, IgnoreCase);
  if (i < Low(Arr))or(Arr[i] = NewValue) then Exit;
  Arr[i] := NewValue;
  Result := True;
end;


function TMyArrayHelper.ReplaceInArray(FindValue: Variant; NewValue: Variant; Arr: TVarDynArray2; FindFNo, ReplaceFNo: Integer; IgnoreCase: Boolean = False): Boolean;
//заменяем поле в массиве в строке, найденной по значению какого-либо (другого или того же) поля, была ли замена
var
  i: Integer;
begin
  Result := False;
  i := PosInArray(FindValue, Arr, FindFNo, IgnoreCase);
  if (i < Low(Arr))or(Arr[i][ReplaceFNo] = NewValue) then Exit;
  Arr[i][ReplaceFNo] := NewValue;
  Result := True;
end;


function TMyArrayHelper.InArray(V: Variant; Arr: array of Variant): Boolean;
//вернет истину, если строка присутствует в массиве
begin
  Result := (PosInArray(V, Arr) <> -1);
end;

function TMyArrayHelper.VarDynArray2ColToVD1(arr: TVarDynArray2; Column: Integer): TVarDynArray;
//возвращает столбец двухмерного массива Column в одномерном массиве
var
  i: Integer;
begin
  Result := [];
  for i := Low(arr) to High(arr) do
    Result := Result + [arr[i][Column]];
end;

function TMyArrayHelper.VarDynArray2RowToVD1(arr: TVarDynArray2; Row: Integer): TVarDynArray;
//возвращает столбец двухмерного массива Кщц в одномерном массиве
var
  i: Integer;
begin
  Result := [];
  for i := Low(arr[Row]) to High(arr[Row]) do
    Result := Result + [arr[Row][i]];
end;


procedure TMyArrayHelper.VarDynArray2InsertArr(var arr2: TVarDynArray2;
  arr1: TVarDynArray; Pos: Integer = -1; ToInsert: Boolean = True);
//модифицирует двумерный массив вставкой или заменой его элемента первого уровня массивом TVarDynArray
//при параметрах по умолчанию просто добавит массив TVarDynArray в конец массива TVarDynArray2
var
  i, j, p: Integer;
  a: Array of Variant;
begin
  if (Pos > High(arr2))or(Pos = -1) then begin
    arr2:= arr2 + [[]];
    Pos:= high(arr2);
  end
  else if ToInsert then begin
    insert([[]], arr2, Pos)
  end;
  SetLength(arr2[Pos], Length(arr1));
  for i:= 0 to High(arr1)
    do arr2[Pos][i]:=arr1[i];
end;


procedure TMyArrayHelper.VarDynArraySort(var arr: TVarDynArray; Asc: Boolean = True);
//сортировка одномерного вариантного массива
var
  i, j, k: Integer;
  changed, tosort: Boolean;
  buf: Variant;
begin
  repeat
    changed := False;
    for k := 0 to High(arr) - 1 do
      if (Asc and (arr[k] > arr[k + 1])) or (not Asc and (arr[k] < arr[k + 1])) then begin // обменяем k-й и k+1-й элементы
        buf := arr[k];
        arr[k] := arr[k + 1];
        arr[k + 1] := buf;
        changed := True;
      end;
  until not changed;
end;

procedure TMyArrayHelper.VarDynArraySort(var Arr: TVarDynArray2; Col: Integer; Asc: Boolean = True);
//сортировка двухмерного вариантгного массива по переданному полю
var
  i, j, k: Integer;
  changed, tosort: Boolean;
  buf: Variant;
begin
  repeat
    changed := False;
    for k := 0 to High(Arr) - 1 do
      if (Asc and (Arr[k][Col] > Arr[k + 1][Col])) or (not Asc and (Arr[k][Col] < Arr[k + 1][Col])) then begin
        for j := 0 to High(Arr[k]) do begin
          buf := Arr[k][j];
          Arr[k][j] := Arr[k + 1][j];
          Arr[k + 1][j] := buf;
        end;
        changed := True;
      end;
  until not changed;
end;

procedure TMyArrayHelper.VarDynArray2Sort(var Arr: TVarDynArray2; Key: Integer);
//сортировка двухмерного вариантгного массива по переданному полю
//поле передается на 1 больше чем в массиве!!!, если с + то по возрастанию, а с - то по убыванию, ту при сортировке по убыванию по нулевой колонке передать -1
var
  i, j, k: Integer;
  changed, tosort: Boolean;
  buf: Variant;
begin
  repeat
    changed := False;
    for k := 0 to High(Arr) - 1 do
      if ((Key > 0) and (Arr[k][Key - 1] > Arr[k + 1][Key - 1])) or ((Key < 0) and (Arr[k][Key - 1] < Arr[k + 1][Key - 1])) then begin // обменяем k-й и k+1-й элементы
        for j := 0 to High(Arr[k]) do begin
          buf := Arr[k][j];
          Arr[k][j] := Arr[k + 1][j];
          Arr[k + 1][j] := buf;
        end;
        changed := True;
      end;
  until not changed;
end;

function TMyArrayHelper.ArrCompare(const AVar1, AVar2: array of Variant; Operation: TArrayOperation): TVarDynArray;
//возвращает одномерный массив, являющийся пересечением, объединением или различием двух массивов
var
  i: Integer;
begin
  SetLength(Result, 0);
  case Operation of
    aoIntersection:
      for i := 0 to Length(AVar1) - 1 do
        if VarIndex(AVar1[i], AVar2) <> -1 then begin
          SetLength(Result, Length(Result) + 1);
          Result[High(Result)] := AVar1[i];
        end;
    aoUnion:
      begin
        for i := 0 to Length(AVar1) - 1 do
          if VarIndex(AVar1[i], Result) = -1 then begin
            SetLength(Result, Length(Result) + 1);
            Result[High(Result)] := AVar1[i];
          end;
        for i := 0 to Length(AVar2) - 1 do
          if VarIndex(AVar2[i], Result) = -1 then begin
            SetLength(Result, Length(Result) + 1);
            Result[High(Result)] := AVar2[i];
          end;
      end;
    aoDifference:
      begin
        for i := 0 to Length(AVar1) - 1 do
          if VarIndex(AVar1[i], AVar2) = -1 then begin
            SetLength(Result, Length(Result) + 1);
            Result[High(Result)] := AVar1[i];
          end;
        for i := 0 to Length(AVar2) - 1 do
          if VarIndex(AVar2[i], AVar1) = -1 then begin
            SetLength(Result, Length(Result) + 1);
            Result[High(Result)] := AVar2[i];
          end;
      end;
  end;
end;

function TMyArrayHelper.VarIntToArray(v: Variant): TVarDynArray;
//передается или целое число, или вариантный массив, или строка чисел через запятую,
//возвращается массив
begin
  Result := [];
  if VarType(v) and varInteger = varInteger then begin
    Result := [v];
  end
  else if VarType(v) and varString = varString then begin
    Result := ExplodeV(VarToStr(v), ',');
  end
  else if VarType(v) and varArray = varArray then begin
    Result := v;
  end;
end;

function TMyArrayHelper.StringDynArrayToVarDynArray(sa: TStringDynArray): TVarDynArray;
//получает массив строк, возвращает вариантный массив
var
  i: Integer;
begin
  Result:=[];
  for i:=0 to High(sa) do Result:=Result + [sa[i]];
end;


function TMyArrayHelper.RemoveDuplicates(const AValues: TVarDynArray): TVarDynArray;
//удаляем дублирующиеся знаения из массива
var
  i, j: Integer;
  isDuplicate: Boolean;
  resultArray: TVarDynArray;
begin
  SetLength(resultArray, 0);
  for i := 0 to High(AValues) do
  begin
    isDuplicate := False;
    for j := 0 to High(resultArray) do
    begin
      if VarCompareValue(AValues[i], resultArray[j]) = vrEqual then
      begin
        isDuplicate := True;
        Break;
      end;
    end;
    if not isDuplicate then
    begin
      SetLength(resultArray, Length(resultArray) + 1);
      resultArray[High(resultArray)] := AValues[i];
    end;
  end;
  Result := resultArray;
end;

function TMyArrayHelper.IsArraysEqual(const A, B: TVarDynArray2; ARow: Integer = -1): Boolean;
//сравнение двух двумерных массивов (или одной их строки)
//будут одинаковы, если совпадают размерности массивов и все их значения
var
  i, j: Integer;
  RowCountA, RowCountB: Integer;
  ColCountA, ColCountB: Integer;
begin
  RowCountA := Length(A);
  RowCountB := Length(B);
  // Сравнение всей матрицы
  if ARow = -1 then
  begin
    if RowCountA <> RowCountB then begin
      Result := False;
      Exit;
    end;
    // Проверяем каждую строку
    for i := 0 to RowCountA - 1 do begin
      ColCountA := Length(A[i]);
      ColCountB := Length(B[i]);
      if ColCountA <> ColCountB then begin
        Result := False;
        Exit;
      end;
      for j := 0 to ColCountA - 1 do begin
        // Используем VarCompareValue для корректного сравнения Variant
        if VarCompareValue(A[i, j], B[i, j]) <> vrEqual then begin
          Result := False;
          Exit;
        end;
      end;
    end;
    Result := True;
    Exit;
  end;
  // Сравнение только указанной строки ARow
  if (ARow < 0) or (ARow >= RowCountA) or (ARow >= RowCountB) then begin
    // Одна из матриц не содержит строку ARow → не равны
    Result := False;
    Exit;
  end;
  ColCountA := Length(A[ARow]);
  ColCountB := Length(B[ARow]);
  if ColCountA <> ColCountB then begin
    Result := False;
    Exit;
  end;
  for j := 0 to ColCountA - 1 do begin
    if VarCompareValue(A[ARow, j], B[ARow, j]) <> vrEqual then begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

procedure TMyArrayHelper.SetNull(var Arr: TVarDynArray);
begin
  for var i := 0 to High(Arr) do
      Arr[i] := null;
end;

procedure TMyArrayHelper.SetNull(var Arr: TVarDynArray2; Row: Integer = -1);
begin
  if Row = -1 then
    for var i := 0 to High(Arr) do
      for var j := 0 to High(Arr[i]) do
        Arr[i][j] := null
  else
    for var i := 0 to High(Arr[Row]) do
      Arr[Row][i] := null;
end;

procedure TMyArrayHelper.IncLength(var Arr: TVarDynArray);
begin
  SetLength(Arr, Length(Arr) + 1);
end;

procedure TMyArrayHelper.IncLength(var Arr: TVarDynArray2);
begin
  SetLength(Arr, Length(Arr) + 1);
  SetLength(Arr[High(Arr)], Length(Arr[0]));
end;













procedure TNamedArr.Create(Fields: TVarDynArray; Len: Integer);
var
  i, j: Integer;
begin
  FFull := Copy(Fields);
  F := Copy(Fields);
  for j := 0 to System.High(F) do begin
    i := Pos('$', F[j]);
    if i > 0 then
      F[j] := Copy(F[j], 1, i - 1);
  end;
  //в любом случае очистим массив данных
  SetLength(V, 0);
  SetLength(V, Len);
  for i := 0 to Len - 1 do
    SetLength(V[i], Length(F));
end;

function TNamedArr.Col(Field: string): Integer;
var
  i : Integer;
begin
  i := Pos('$', Field);
  if i > 0 then
    Field := Copy(Field, 1, i - 1);
  i := A.PosInArray(Field, F, True);
  if i < 0 then
    raise Exception.Create('Поле ' + Field + ' не найдено в NamedArr');
  Result := i;
end;

function TNamedArr.G(RowNo: Integer; Field: string): Variant;
begin
  Result := GetValue(RowNo, Field);
end;

function TNamedArr.G(Field: string): Variant;
var
  i : Integer;
begin
  Result := GetValue(0, Field);
end;

function TNamedArr.GetValue(RowNo: Integer; Field: string): Variant;
var
  i : Integer;
begin
  i := Col(Field);
  if (RowNo < 0) or (RowNo > System.High(V)) then
    raise Exception.Create('Строка ' + InttoStr(RowNo) + ' для поля ' + Field + ' вне диапозона в NamedArr');
  Result := V[RowNo][i];
end;

function TNamedArr.GetValue(Field: string): Variant;
var
  i : Integer;
begin
  Result := GetValue(0, Field);
end;

function TNamedArr.GetRow(RowNo: Integer): TVarDynArray;
begin
  if (RowNo < 0) or (RowNo > System.High(V)) then
    raise Exception.Create('Строка ' + InttoStr(RowNo) + ' вне диапозона в NamedArr');
  Result := A.VarDynArray2RowToVD1(V, RowNo);
end;

procedure TNamedArr.SetValue(RowNo: Integer; Field: string; NewValue: Variant);
var
  i : Integer;
begin
  i := Col(Field);
  if (RowNo < 0) or (RowNo > System.High(V)) then
    raise Exception.Create('Строка ' + InttoStr(RowNo) + ' для поля ' + Field + ' вне диапозона в NamedArr');
  V[RowNo][i] := NewValue;
end;

procedure TNamedArr.SetValue(Field: string; NewValue: Variant);
begin
  SetValue(0, Field, NewValue);
end;

function TNamedArr.Find(Value: Variant; Field: string): Integer;
begin
  Result := A.PosInArray(Value, V, Col(Field));
end;

function TNamedArr.Empty: Boolean;
begin
  Result := Length(V) = 0;
end;

function TNamedArr.Count: Integer;
begin
  Result := Length(V);
end;

function TNamedArr.High: Integer;
begin
  Result := System.High(V);
end;

procedure TNamedArr.IncLength;
begin
  SetLength(V, Length(V) + 1);
  SetLength(V[System.High(V)], Length(F));
end;

procedure TNamedArr.SetLen(ALength: Integer);
begin
  SetLength(V, ALength);
  for var i := 0 to Length(V) - 1 do
    SetLength(V[i], Length(F));
end;


function TNamedArr.FieldsCount: Integer;
begin
  Result := Length(F);
end;

procedure TNamedArr.Clear;
begin
  FFull := [];
  F := [];
  V := [];
end;

procedure TNamedArr.SetNull;
begin
  for var i := 0 to System.High(V) do
    for var j := 0 to System.High(V[i]) do
      V[i][j] := null;
end;

procedure TNamedArr.SetNull(RowNo: Integer);
begin
  for var j := 0 to System.High(V[RowNo]) do
    V[RowNo][j] := null;
end;



//==============================================================================
//==============================================================================
//==============================================================================

//возвращает дату, которую условились считать признаком неверной даты/времени
function BadDate: TDateTime;
begin
  Result := EncodeDate(1900, 12, 30);
end;

function TMyStringHelper.BadDate: TDateTime;
begin
  Result := EncodeDate(1900, 12, 30);
end;




//==============================================================================
function TVariantHelper.IsNull: Boolean;
begin
  Result := VarIsNull(Self);
end;

function TVariantHelper.IsEmpty: Boolean;
begin
  Result := VarIsEmpty(Self);
end;

function TVariantHelper.IsNumeric: Boolean;
begin
  case VarType(Self) of
    varByte, varSmallint, varInteger, varShortInt,
    varWord, varLongWord, varInt64,
    varSingle, varDouble, varCurrency://, varDecimal:
      Result := True;
  else
    Result := False;
  end;
end;

function TVariantHelper.AsString: string;
begin
  if IsNull or IsEmpty then
    Result := ''
  else
    Result := VarToStr(Self);
end;

function TVariantHelper.AsInteger: Integer;
begin
  Result := S.NInt(Self);
{  if IsNumeric then
    Result := S.VarToInt(Self)
  else
    Result := 0;}
end;

function TVariantHelper.AsIntegerM: Integer;
begin
  Result := S.NIntM(Self);
end;

function TVariantHelper.AsFloat: Extended;
begin
  Result := S.NNum(Self);
{  if IsNumeric then
    Result := Self
  else
    Result := 0;}
end;

function TVariantHelper.AsBoolean: Boolean;
begin
  if IsNull or IsEmpty then
    Result := False
  else
    Result := Self; //VarToBoolean(Self);
end;

function TVariantHelper.AsDateTime: TDatetime;
begin
  Result := Self
end;

function TVariantHelper.NullIf0: Variant;
begin
  Result := S.NullIf0(Self);
end;

function TVariantHelper.NullIfEmpty: Variant;
begin
  Result := S.NullIfEmpty(Self);
end;

function VTxt(var v: Variant; name: string = ''): string;
var
  i, j: Integer;
begin
  Result := name + ':  ' + VarToStr(v);
end;

function VTxt(var va2: TVarDynArray2; name: string = ''): string;
var
  i, j: Integer;
begin
  Result := name + ':'#10#13;
  for i := 0 to High(va2) do begin
    for j := 0 to High(va2[i]) do
      s.ConcatStP(Result, VarToStr('[' + IntToStr(i) + ']' + '[' + IntToStr(j) + '] => ' + VarToStr(va2[i][j])), '   ');
  end;
end;

function VTxt(var va: TVarDynArray; name: string = ''): string;
var
  i, j: Integer;
begin
  Result := name + ':'#10#13;
  for i := 0 to High(va) do begin
    s.ConcatStP(Result, VarToStr('[' + IntToStr(i) + '] => ' + VarToStr(va[i])), '   ');
  end;
end;

function VTxt(var na: TNamedArr; name: string = ''): string;
var
  i, j: Integer;
begin
  Result := name + ':'#10#13;
  for i := 0 to na.Count - 1 do begin
    for j := 0 to na.FieldsCount - 1 do
      s.ConcatStP(Result, VarToStr('[' + IntToStr(i) + ']' + '[' + na.F[j] + '] => ' + VarToStr(na.V[i][j])), '   ');
  end;
end;

procedure MsgDbg(Values: TVarDynArray; Name: string = ''; Skip: Boolean = False);
var
  i: Integer;
  st: string;
begin
  if Skip and not FrmMain.DeveloperMode then
    Exit;
  st := '';
  if Name <> '' then
    st := '<' + Name + '>'#13#10#13#10;
  for i := 0 to High(Values) do
    S.ConcatStP(st, Values[i], '---------------------------'#13#10#13#10);
  MyInfoMessage(st);
end;

procedure Txt2File(St: string; Fname: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  SL.Text := St;
  SL.SaveToFile(s.Iif(Fname <> '', Fname, 'debug.txt'));
  SL.Free;
end;

var
  dt111, dt112: TDateTime;
  i111: Integer;
  d111: Double;
  V: Variant;
  st111: string;
  va1: tvardynarray;
  st: string;
  i : Integer;

begin
//Exit;
{dt111:=BadDate;
d111:=double(dt111);
dt112:=TDateTime(d111);
i111:=0;
   i:=maxof([1,2,3]);
va1:=Explode('',';');
va1:=Explode('',';', True);
va1:=Explode(';2;3;',';', True);
va1:=Explode('1;;3;9',';', False);
va1:=[];
//   i:=isvaliddate(

//   dt111:=strtodatedef(
v:=GetFormulaValue('2*3');
v:=GetFormulaValue('2*(4+(6*(2+1)))+SQRT(4)');}

st:=s.DeleteRepSubstr('1ab23ababab4ababa', 'ab');

//i:=DaysInMonth(2024,02);

end.

