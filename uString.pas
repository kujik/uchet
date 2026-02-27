unit uString;
//==============================================================================
//Модуль содержит вспомогательные записи для работы со строками, вариантами
//и массивами. Запись S предоставляет методы для строк и вариантов, запись A
//для работы с одномерными и двумерными массивами Variant (TVarDynArray,
//TVarDynArray2). Также имеется хелпер TVariantHelper, добавляющий удобные
//методы к типу Variant.
//
//ВНИМАНИЕ: Все методы, работающие с наборами символов, переделаны для поддержки
//Unicode. Вместо множеств (TCharSet) рекомендуется использовать TCharDynArray.
//Старые перегрузки с TCharSet оставлены для совместимости, но они не поддерживают
//символы с кодом >255 (например, русские буквы). Для полной поддержки Unicode
//используйте версии с TCharDynArray (те же имена, но параметры изменились).
//В случае вызова с TCharSet будет выдано предупреждение о deprecated.
//==============================================================================

interface

uses
  Graphics, Classes, DateUtils, Variants, Types, SysUtils, Math, StrUtils;

type
  TVarDynArray = array of Variant;

  TVarDynArray2 = array of TVarDynArray;

  TCharDynArray = array of Char;

  TByteSet = set of Byte;

  TCharSet = set of Char; // устаревший тип, не поддерживает Unicode

  //Тип операции для сравнения массивов
  TArrayOperation = (aoIntersection, aoUnion, aoDifference);

  //Направление обрезки строки
  TStringDirection = (sdLeft, sdRight, sdBoth);

  TMyStringLocation = (stlLeft, stlRight, stlBoth); //для совместимости

const
  micntBadDate: Double = 365;  //30.12.1900
  RubDividor: ShortString = ' ';
  KopDividor: ShortString = ' . ';
  Kop2Dividor: ShortString = '';
  PriceNewMode = True;
  fopCaseSensetive = $01;
  fopWholeField = $02;
  fopUseMask = $04;
  EngChars: set of Char = ['A'..'Z', 'a'..'z']; // не используется в методах
  EngChars_: set of Char = ['A'..'Z', 'a'..'z', '_'];
  DaysOfWeek2: array[1..7] of string = ('Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс');
  MonthsRu: array[1..12] of string = ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь');
  DigitsChars: set of Char = ['0'..'9']; // не используется
  DigitsChars_: set of Char = ['0'..'9', '.', ',', '+', '-'];
  DivSymbols =[ ' ',  ',',  '.',  ':',  ';',  '?',  '!',  '"',  '=',  '-',  '_',  '(',  ')',  '%',  '/',  '\',  '*']; // не используется
  DatePeriods: array[0..11] of string = ('Сегодня', 'Вчера', 'Эта неделя', 'Прошлая неделя', 'Эта половина месяца', 'Прошлая половина месяца', 'Этот месяц', 'Прошлый месяц', 'Этот квартал', 'Прошлый квартал', 'Этот год', 'Прошлый год');

type
  //============================================================================
  //Запись TMyStringHelper (глобальная переменная S)
  //Содержит методы для работы со строками и вариантами
  //============================================================================
  TMyStringHelper = record
  private
    //Вспомогательная функция: проверяет, содержится ли символ C в массиве AChars
    function CharInArray(C: Char; const AChars: TCharDynArray): Boolean;
    //Преобразует множество Char в массив (только для символов <256)
    function CharSetToArray(const AChars: TCharSet): TCharDynArray;
  public
    //----------- Обрезка пробелов и управляющих символов
    //Удалим переданные символы слева, справа или с обеих сторон строки;
    //если не передан массив символов, то удаляем пробел и табуляцию
    //+++ переработана для поддержки Unicode: вместо множества используется массив символов
    function TrimStr(const AStr: string; const ATrimChars: TCharDynArray = nil; const AMode: TMyStringLocation = stlBoth): string; overload;
    //Устаревшая версия с множеством (не поддерживает Unicode)
    function TrimStr(const AStr: string; const ATrimChars: TCharSet = []; const AMode: TMyStringLocation = stlBoth): string; overload; deprecated 'Use TrimStr with TCharDynArray for Unicode support';
    //Процедура. Удалим переданные символы слева, справа или с обеих сторон строки;
    //если не передан массив символов, то удаляем пробел и табуляцию
    //+++ переработана для поддержки Unicode
    procedure TrimStrP(var AStr: string; const ATrimChars: TCharDynArray = nil; const AMode: TMyStringLocation = stlBoth); overload;
    //Устаревшая процедура с множеством
    procedure TrimStrP(var AStr: string; const ATrimChars: TCharSet = []; const AMode: TMyStringLocation = stlBoth); overload; deprecated 'Use TrimStrP with TCharDynArray for Unicode support';
    //удалим символы с левой части строки
    //+++ переработана для поддержки Unicode
    procedure DelLeft(var AStr: string; const ATrimChars: TCharDynArray = nil); overload;
    //удалим символы с левой части строки (устаревшая)
    procedure DelLeft(var AStr: string; const ATrimChars: TCharSet = []); overload; deprecated 'Use DelLeft with TCharDynArray for Unicode support';
    //удалим символы с правой части строки
    //+++ переработана для поддержки Unicode
    procedure DelRight(var AStr: string; const ATrimChars: TCharDynArray = nil); overload;
    //удалим символы с правой части строки (устаревшая)
    procedure DelRight(var AStr: string; const ATrimChars: TCharSet = []); overload; deprecated 'Use DelRight with TCharDynArray for Unicode support';
    //Удаление переданного массива символов с обоих концов строки
    //+++ переработана для поддержки Unicode
    procedure DelBoth(var AStr: string; const ATrimChars: TCharDynArray = nil); overload;
    //Удаление переданного множества символов с обоих концов строки (устаревшая)
    procedure DelBoth(var AStr: string; const ATrimChars: TCharSet = []); overload; deprecated 'Use DelBoth with TCharDynArray for Unicode support';
    //----------- Замена символов в строке
    //если в строке идут несколько пробелов подряд, то приводит их к одному пробелу
    //+++ переработана с TStringBuilder для эффективности
    function DeleteRepSpaces(const AStr: string; const AChar: Char = ' '): string;
    //удаляем все символы Ch из строки
    //+++ переработана с TStringBuilder
    function DeleteChar(const AStr: string; const AChar: Char): string;
    //mode=True  удаляет в строке все символы из [ch]
    //mode=False удаляет в строке все символы из not[ch]
    //+++ переработана для поддержки Unicode (параметр TCharDynArray)
    function DeleteChars(const AStr: string; const AChars: TCharDynArray; const AMode: Boolean): string; overload;
    //Устаревшая версия с множеством
    function DeleteChars(const AStr: string; const AChars: TCharSet; const AMode: Boolean): string; overload; deprecated 'Use DeleteChars with TCharDynArray for Unicode support';
    //mode=True  заменяет в строке все символы из [ch] на символ chnew
    //mode=False заменяет в строке все символы из not[ch] на символ chnew
    //+++ переработана для поддержки Unicode (параметр TCharDynArray)
    function ChangeChars(const AStr: string; const AChars: TCharDynArray; const ANewChar: Char; const AMode: Boolean): string; overload;
    //Устаревшая версия с множеством
    function ChangeChars(const AStr: string; const ACharSet: TCharSet; const ANewChar: Char; const AMode: Boolean): string; overload; deprecated 'Use ChangeChars with TCharDynArray for Unicode support';
    //возвращает сроку символов Fill
    function FillString(const ALen: Integer; const AChar: Char): string;
    //если в строке идут подряд последовательности символов (подстроки), то оставляет только первую из них
    //не доделано!!! работает для уборки последовательносте типа ("1212ыыыы12", "12"), но не из повторяющихся символов (не должна быть последовательность "00"!!!
    function DeleteRepSubstr(const AStr: string; const ASubStr: string): string;
    //---------Выравнивание текста за счёт установки пробелов или других символов
    {
     Writeln('123'.PadLeft(5));  //'  123'
     Writeln('12345'.PadLeft(5));  //'12345'
     Writeln('Выводы '.PadRight(20, '-') + ' стр. 7'); //'Выводы ------------- стр. 7'
    }
    //дополняет строку переданным символом (по умолчанию пробел) слева, до переданной длины
    function PadLeft(const AStr: string; const ALen: Integer; const AChar: Char = ' '): string; // {! - использует встроенный TStringHelper.PadLeft}
    //дополняет строку переданным символом (по умолчанию пробел) справа, до переданной длины
    function PadRight(const AStr: string; const ALen: Integer; const AChar: Char = ' '): string; // {! - использует встроенный TStringHelper.PadRight}
    //---------Проверка корректности типа строки (формат числа, даты...)
    //проверяет, является ли строка целым числом.
    //+++ использует TryStrToInt
    function IsInt(const AStr: string): Boolean;
    //проверяет, является ли строка числом с плавающей точкой
    //+++ использует TryStrToFloat
    function IsFloat(const AStr: string): Boolean;
    //проверяет, является ли строка числом в заданном диапозоне с заданным числом десятичных знаков
    //если число десятичных знаков не нужно, передать -1, если нужно целое число, передать 0
    //+++ переработана с использованием TryStrToFloat
    function IsNumber(const AStr: string; const AMin, AMax: Extended; const ADigits: Integer = -1): Boolean;
    //проверка строки на то что содержит дату/время
    //DtType = dt - должно быть датой или датой со временем, DT - обязательно дата и время, d,D -только дата, t - только время
    //предполагается что разделитель даты и времени - пробел (практически всегда это так), а часов и минут - ":"
    //+++ использует TryStrToDateTime
    function IsDateTime(const AStr: string; const ADateTimeType: string = 'dt'): Boolean;
    //если строка есть число (целое положительное) возвр его длинну
    //если начало строки есть число возвр длинну этой части со знаком -
    function IsNumberLeftPart(const AStr: string): Integer;
    //проверяетвалидность почтового адреса по формальным признакам (адрес должен соответствовать стандарту)
    function IsValidEmail(const AValue: string): Boolean;
    //---------Перевод строки в простые типы
    //проверяем, является ли строка числом в заданном диапозоне с заданным количеством чисел после запятой (не более)
    //в качестве разделителей принимаем точку и запятую
    //возвращаем число в Res: extended, а Result - истина или ложь /если не удалось преобразовать в число/
    //+++ переработана с использованием TryStrToFloat и замены разделителя
    function StrToNumberCommaDot(const AValue: Variant; const AMin, AMax: Extended; out ARes: Extended; const ADigits: Integer = -1): Boolean;
    //преобразует тип Variant в Integer; при неудаче возвращает значение Def
    //+++ использует TryStrToInt
    function VarToInt(const AValue: Variant; const ADefault: Integer = -1): Integer;
    //преобразует тип Variant в Extended; при неудаче возвращает значение Def
    //+++ использует TryStrToFloat
    function VarToFloat(const AValue: Variant; const ADefault: Extended = -1): Extended;
    //преобразовывает число в строку длиной не менее Len, позиции перед числом заполняет символом Ch
    function NumToString(const ANumber: Extended; const ALen: Byte; const AChar: Char): string;
    //преобразует строку из трех или пяти чисел, разделенных пробелами (дефисами, точками), в TDateTime
    //если ошиибка возвращает BadDate
    //использовать только при вводе вручную или при явно корректном формате так как в среде будет вызываться исключение
    //+++ улучшена обработка двузначного года
    function SpacedStToDate(const AStr: string; const AFullDateTime: Boolean = False): TDateTime;
    //преобразует TDateTime в число (Double) и возвращает  в виде строки
    //сервисная функция
    function DateTimeToIntStr(const ADateTime: TDateTime): string;
    //--------- Обработка значений типа Null, переданных в параметре Varint
    //возвращает пустую строку, если значение Empty или Null
    function NSt(const AValue: Variant): string;
    //возвращает 0 с типом extended, если значение Empty или Null
    function NNum(const AValue: Variant; const ADefault: Extended = 0): Extended;
    //возвращает 0 с типом Integer, если значение Empty или Null
    function NInt(const AValue: Variant): Integer;
    //возвращает -1 с типом Integer, если значение Empty или Null
    function NIntM(const AValue: Variant): Integer;
    //возвращает нулл если v=null or VarToString(v) ='', иначе вернет переданное значение
    function NullIfEmpty(const AValue: Variant): Variant;
    //возвращает нулл если v=0 (0.00), иначе вернет переданное значение
    function NullIf0(const AValue: Variant): Variant;
    //--------- Изменение регистра строки
    {
    Writeln(LowerCase('АбВгД - AbCdE')); //В нижний регистр меняются только латинские буквы. Результат будет 'АбВгД - abcde'.
    Writeln('АбВгД - AbCdE'.ToLower); //В нижний регистр меняются и русские и латинские буквы. Результат будет 'абвгд - abcde'.
    }
    //изменить регистр строки (и латинские и русские буквы
    //+++ использует встроенные ToUpper/ToLower
    function ChangeCaseStr(const AStr: string; const AToUpper: Boolean): string;
    //изменить регистр символа (и латинские и русские буквы
    //+++ использует TCharacter
    function ChangeCaseCh(const ACh: Char; const AToUpper: Boolean): Char;
    //строку в верхний регистр
    function ToUpper(const AStr: string): string;
    //строку в нижний регистр
    function ToLower(const AStr: string): string;
    //получает Cnt правых символов строки
    function Right(const AStr: string; const ACount: Integer = 1): string;

    //---------- Поиск вхождений, вычленение позиций вхождений ы строку.
    //находит позицию подстроки в строке без учета регистра
    function PosI(const ASubStr, AStr: string): Integer;
    //проверяет, содержится ли подстрока в строке значений, разделенных запятыми
    //+++ переработана с учётом регистра
    function InCommaStr(const APart, AFull: string; const ADelimiter: Char = ','; const AIgnoreCase: Boolean = False): Boolean;
    //проверяет, содержится ли подстрока в строке значений, разделенных запятыми, без учета регистра
    function InCommaStrI(const APart, AFull: string; const ADelimiter: Char = ','): Boolean;
    //подсчитывает количество символов из переданного набора в строке, начиная с позиции р1 и до р2 (если -1 то до конца строки)
    //+++ переработана для поддержки Unicode (TCharDynArray)
    function GetCharCountInStr(const AStr: string; const AChars: TCharDynArray; const AStart: Integer = 1; const AEnd: Integer = -1): Integer; overload;
    //устаревшая версия с множеством
    function GetCharCountInStr(const AStr: string; const AChars: TCharSet; const AStart: Integer = 1; const AEnd: Integer = -1): Integer; overload; deprecated 'Use GetCharCountInStr with TCharDynArray for Unicode support';
    //ищем позицию начяала слова в строке, передается начальная позиция поиска,
    //счетчик идет назад пока не встретистся символ из DivSymbols
    //+++ переработана для поддержки Unicode (TCharDynArray)
    function FindBegWord(const AStartPos: Integer; const AStr: string; const ADelimiters: TCharDynArray = nil): Integer; overload;
    //устаревшая версия с множеством
    function FindBegWord(const AStartPos: Integer; const AStr: string; const ADelimiters: TCharSet = [' ']): Integer; overload; deprecated 'Use FindBegWord with TCharDynArray for Unicode support';
    //ищем позицию конца слова в строке, передается начальная позиция поиска,
    //счетчик идет вперед пока не встретистся символ из DivSymbols
    //+++ переработана для поддержки Unicode (TCharDynArray)
    function FindEndWord(const AStartPos: Byte; const AStr: string; ADelimiters: TCharDynArray = nil): Integer; overload;
    //устаревшая версия с множеством
    function FindEndWord(const AStartPos: Byte; const AStr: string; const ADelimiters: TCharSet = [' ']): Integer; overload; deprecated 'Use FindEndWord with TCharDynArray for Unicode support';
    //разбиение строки St на 3 части: St1 -до кавычек, St2 - в кавычках, St3 - после
    //кавычки учитываются как двойные так и одинарные
    //осталось от старого
    //+++ переработана (незначительно)
    procedure DivisionQuotetStr(const AStr: string; out ALeft, AMid, ARight: string);
    //получает подстроку номер NumSubSt из строки, которую разбивает по строковым разделителям DivSt
    //возвращает также позицию найденной подстроки в строке
    //если не смог выделить подстроку, то возвращает -2 и ''
    //+++ переработана для ясности
    function GetSubStr(const AStr: string; const AIndex: Integer; const ADelimiter: string; out APos: Integer): string;
    //Поиск по маске:  Сpавнение стpоки St с шаблоном Mask. В шаблоне можно
    //yпотpеблять знаки '?'(любой знак) и '*' (любое количество любых знаков)
    function FindMaskInStr(var AMask, AStr: string): Boolean;
    //Поиск по маске:  Сpавнение стpоки St с шаблоном Mask. В шаблоне можно
    //yпотpеблять знаки '?'(любой знак) и '*' (любое количество любых знаков)}
    function FindADDMaskInStr(const AMask, AStr: string): Boolean;
    //---------- Специальные преобразования строки (число в цену прописью и т.п.
    //преобразование числа в строку прописью
    function NumToWords(const ANum: LongInt; const AGender: Char): string;
    //преобразование числа в строку цены прописью
    function NumToPriceWords(const ANum: LongInt; const AMode: Boolean): string;
    //преобразует число в сцену в рублях и копейках в виде числа а не слов
    //работает тут НЕПРАВИЛЬНО, цена в целом числе, 2 последние это копейки
    function NumToPriceStr(const ANum: LongInt): string;
    //сервисная функция для вывода цены с включением слов Рублей и Копеек
    function PriceWord(const ANum: LongInt; const AMode: Char): string;
    //преобразование числа в строку телефона с разделителями
    function NumToPhoneStr(const ANum: LongInt): string;
    //форматирование строки как строки телефона с разделителями
    //+++ переработана с использованием DeleteCharsEx
    function StrToPhoneStr(const APhone: string): string;
    //выбирает окончание по количеству
    //(передается окончание для кол-ва 1, 2{3,4}, 5(6,7,8,9,10)
    function GetEnding(const ANum: LongInt; const AWord1, AWord2, AWord3: string): string;
    //(передается количество, основная часть слова, окончание для кол-ва 1, 2{3,4}, 5(6,7,8,9,10)
    function GetEndingFull(const ANum: LongInt; const AMain, AWord1, AWord2, AWord3: string): string;
    //выбирает окончание по количеству (толькко ед/множ число)
    function GetEndingOneOrMany(const ANum: LongInt; const ASingular, APlural: string): string;
    //заключить строку в круглые скобки, если она не пустая
    function AddBracket(const AStr: string): string;
    //форматируем число в строку. если есть дробная часть, то она будет дана через запятую (по умолчанию) или точку
    function FormatNumberWithComma(const AValue: Extended; const ADividerIsComma: Boolean = True): string;

    //-------------------------- Условные функции
    //-- Важно: в отличии от выражений параметры в функциях будут вычислены ВСЕГДА при их в нее передаче
    //если Expr истина, то вернет Par1, иначе Par2
    //варианта для аргументов Variant, string, Integer, extended
    function IIf(const AExpr: Boolean; const ATrueValue, AFalseValue: Variant): Variant;
    function IIfV(const AExpr: Boolean; const ATrueValue, AFalseValue: Variant): Variant;
    function IIFStr(const AExpr: Boolean; const ATrueStr: string; const AFalseStr: string = ''): string; overload;  //второй параметр можно не задавать, если должен быть пустой
    //если первый аргумент не пуст, возвращает его, иначе - второй
    function IfEmptyStr(const AStr: string; const AEmptyResult: string): string;
    //заменяет в маске символ #0 на строку, если строка непустая; если пустая, вернет ''
    function IfNotEmptyStr(const AStr: string; const AMask: string = #0; const AEmptyResult: string = ''): string;
    function IIfInt(const AExpr: Boolean; const ATrueValue, AFalseValue: Integer): Integer;
    function IIfFloat(const AExpr: Boolean; const ATrueValue, AFalseValue: Extended): Extended;
    //Если AValue = AIfValeu, то вернет AIfValeu, иначе AElseValue
    function IfEl(const AValue, AIfValue, AElseValue: Variant): Variant;
    //если ValueFact = ValueCheck, то вернет ValueFact, иначе ValueRes
    function IfNotEqual(const AValueFact, AValueCheck, AValueRes: Variant): Variant;
    //если ValueFact не пустое (empty, '', null), то вернет ValueFact, иначе ValueRes
    function IfNotEmpty(const AValueFact, AValueRes: Variant): Variant;
    //возвращает из массива результат, соответствующий нулевому значению
    //value, case1, value1, case2, value2, {valueelse}
    function Decode(const AArray: TVarDynArray): Variant;
    //сравнить две строки без учета регистра
    function CompareStI(const AStr1, AStr2: string): Boolean;
    //-------------------------- конкатенация строк
    //добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
    function ConcatStr(const AMain, APart: string; const ADelimiter: string = ','; const AIgnoreEmpty: Boolean = False): string;
    function ConcatSt(const AMain, APart: string; const ADelimiter: string = ','; const AIgnoreEmpty: Boolean = False): string;
    //процедура. добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
    procedure ConcatStrP(var AMain: string; const APart: string; const ADelimiter: string = ','; const AIgnoreEmpty: Boolean = False); overload;
    procedure ConcatStrP(var AMain: Variant; const APart, ADelimiter: Variant; const AIgnoreEmpty: Boolean = False); overload;
    procedure ConcatStP(var AMain: string; const APart: string; const ADelimiter: string = ','; const AIgnoreEmpty: Boolean = False); overload;
    procedure ConcatStP(var AMain: Variant; const APart, ADelimiter: Variant; const AIgnoreEmpty: Boolean = False); overload;
    //-------------------------- функции для sql-запросов
    //форматирует дяту в тот вид, который можно вставить в скл
    //в сам текст, в параметра передается просто сам тип даты)
    function SQLDate(const ADateTime: TDateTime): AnsiString;
    //преобразование даты, включая временнУю часть, в строку соотв формату даты в выбранной БД
    function SQLDateTime(const ADateTime: TDateTime): AnsiString;
    //-------------------- математические ------------------------------------------
    //выбирает максимальное значение из вариантного массива
    function MaxOf(const AValues: array of Variant): Variant;
    //выбирает минимальное значение из вариантного массива
    function MinOf(const AValues: array of Variant): Variant;
    //-------------------------- служебные -----------------------------------------
    //возвращает дату, которую условились считать признаком неверной даты/времени
    function BadDate: TDateTime;
    //производит обмен значениями между двумя переменными
    procedure SwapPlaces(var AValue1, AValue2: Variant);
    //не знаю для чего делал
    //function DivisionText(St:string;canvas:TCanvas;width,field:Integer):TStringList;
    //пасрсит строку Csv в массив
    //функция устаревшая, если использовать надо будет переделывать
    //function ParseCsv(St: string; DivCh: Char): tSplitArray;
    //скорректируем строку для использования в качестве имени файла
    function CorrectFileName(const AStr: string): string;
    //проверка ИНН
    function ValidateInn(const AInn: Variant): string;
    //конвертация типа string в PAnsiChar c проверкой (при ошибке исключение)
    function StringToPAnsiChar(const AString: string): PAnsiChar;
    //возвращает имя поля в таблице из имени поля в селесте   например из '1 as field' вернет 'field'
    //например из '1 as field$s' вернет 'field$s'
    function WideStringToString(const ws: WideString; codePage: Word): AnsiString;
    function StringToWideString(const s: AnsiString; codePage: Word): WideString;
    function GetFieldNameFromSt(const ASqlExpr: string): string;
    //возвращает имя поля в таблице из имени поля в селесте
    //например из '1 as field$s' вернет 'field', а если установлен WithMod, то 'field$s'
    function GetDBFieldNameFromSt(const ASqlExpr: string; const AWithMod: Boolean = False): string;
    //возвращает назавание периода в зависимсоти от количества дней:
    //неделя, 4 дня, месяц, 3 месяца, полгода, год, 68 дней - с допусками несколько дней для градаций по месяцам
    function GetDaysCountToName(const ADays: Integer): string;
    //проверка значения строки, по правилам переданным в verify, с учетом типа данных, указанных в ValueType
    //для строк возможна коррекция значений
//!!!    function VerifyValue(const AValueType, AVerify, AValue: string; out ACorrectValue: Variant): Boolean;
    function VeryfyValue(ValueType: string; Verify: string; Value: string; var CorrectValue: Variant): Boolean;
    //возвращает НЕКОТОРЫЕ сводные типы переменной Variant
    //например любое целое иудет varInteger
    function VarType(const AValue: Variant): Integer;
    //проверяет, задано ли значение переменной типа Variant
    function VarIsClear(const AValue: Variant): Boolean;
    //возвращает даты начала и конца периода по массиву DatePeriods (по номеру элемента или названию). если не найдено - возвращает сегодня
    procedure GetDatePeriod(const APeriod: Variant; const AStartDate: TDateTime; out ADateFrom, ADateTo: TDateTime);
    procedure GetDatesFromPeriodString(const AStr: string; out ADateFrom, ADateTo: TDateTime);
  end;
  //============================================================================
  //Запись TMyArrayHelper (глобальная переменная A)
  //Содержит методы для работы с массивами Variant
  //============================================================================

  TMyArrayHelper = record
  private
    //Внутренняя быстрая сортировка для TVarDynArray
    procedure QuickSortVD1(var AArray: TVarDynArray; L, R: Integer; Asc: Boolean); //+++
  public
    //разбивает исходную строку на подстроки, используя как разделитель строку DivSt
    //исходная строка может быть и массивом, тогда будет возвращен этот массив
    //если не установлено IgnoreEmpty, то элементы могут быть пустыми, и пустая строка станет массивом [''].
    //вернет одномерный вариантный массив
    function Explode(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean = False): TVarDynArray; overload; //+++
    //просто алиас Explode
    function ExplodeV(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean = False): TVarDynArray; //+++
    //тоже самое, но возвращает TStringDynArray (перекрыть нельзя, тк определяется только по входным параметрам)
    function ExplodeS(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean = False): TStringDynArray; //+++
    //то же в виде процедур
    procedure ExplodeP(const AValue: Variant; const ADelimiter: string; var AArray: TVarDynArray); overload; //+++
    procedure ExplodeP(const AValue: Variant; const ADelimiter: string; var AArray: TStringDynArray); overload; //+++
    procedure ExplodeP(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean; var AArray: TVarDynArray); overload; //+++
    procedure ExplodeP(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean; var AArray: TStringDynArray); overload; //+++
    //сливаем одномерный вариантный массив в строку через разделитель;
    //если IgnoreEmpty установлен, то игнорируем пустые значения массива
    function Implode(const AArray: array of Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean = False): string; overload; //+++
    //сливаем одномерный строковый массив в строку через разделитель;
    //если IgnoreEmpty установлен, то игнорируем пустые значения массива
    function Implode(const AArray: TStringDynArray; const ADelimiter: string; const AIgnoreEmpty: Boolean = False): string; overload; //+++
    //сливаем в строку переданную колонку двумерного массива
    function Implode(const AArray: TVarDynArray2; const AColumn: Integer; const ADelimiter: string; const AIgnoreEmpty: Boolean = False): string; overload; //+++
    //сливаем в строку весь двухмерный массив по указанным колонкам, разделители для первого и второ уровня разные
    function Implode(const AArray: TVarDynArray2; const AColumns: TByteSet; const ADelimiter1, ADelimiter2: string; const AIgnoreEmpty: Boolean = False): string; overload; //+++
    //сливаем одномерный вариантный массив в строку через разделитель;
    //пустые элементы всегда игнорируем
    function ImplodeNotEmpty(const AArray: array of Variant; const ADelimiter: string): string; //+++
    //склеивает текст из TStrings, при этом игнорирует пустые строки с конца списка
    function ImplodeStringList(var AList: TStringList; const ADelimiter: string = ','): string; //+++
    //находит позицию V в одномерном массиве Arr типа Variant; может не различать регистр; Если не найдена,
    //возвращает -1 (или если массив начинается с меньшей нуля индекса, то Low(Arr) - 1
    function PosInArray(const AValue: Variant; const AArray: array of Variant; const AIgnoreCase: Boolean = False): Integer; overload; //+++
    function PosInArray(const AValue: string; const AArray: TStringDynArray; const AIgnoreCase: Boolean = False): Integer; overload; //+++
    function PosInArray(const AValue: Variant; const AArray: TVarDynArray; const AIgnoreCase: Boolean = False): Integer; overload; //+++
    //находит позицию первого уровня для двумерного массива, в которой в поле FNo находится значение V
    function PosInArray(const AValue: Variant; const AArray: TVarDynArray2; const AColumn: Integer = 0; const AIgnoreCase: Boolean = False): Integer; overload; //+++
    //найдет позицию в массиве, для которой совпадаю все переданные значения в переданных столбцах
    function PosInArray(const AValues: TVarDynArray; const AArray: TVarDynArray2; const AColumns: TVarDynArray; const AIgnoreCase: Boolean = False): Integer; overload; //+++
    //найдет позицию в массиве Source, при которой все поля совпадаются со строкой массива Needle (размерности 2 уровня должны быть одинаковы, что не провряется)
    function PosRowInArray(const ANeedle, ASource: TVarDynArray2; const ARow: Integer): Integer; //+++
    //вернет истину, если строка присутствует в массиве
    function InArray(const AValue: Variant; const AArray: array of Variant): Boolean; //+++
    //возвращает значение из столбца ValueFNo, для которого значения в столбце KeyFNo = KeyValue
    function FindValueInArray2(const AKeyValue: Variant; const AKeyColumn, AResultColumn: Integer; const AArray: TVarDynArray2; const AIgnoreCase: Boolean = False): Variant; //+++
    //заменяем найденное поле в массиве в строке новым значением; возвращает, была ли замена
    function ReplaceInArray(const AFindValue, ANewValue: Variant; var AArray: TVarDynArray; const AIgnoreCase: Boolean = False): Boolean; overload; //+++
    //заменяем поле в массиве в строке, найденной по значению какого-либо (другого или того же) поля, была ли замена
    function ReplaceInArray(const AFindValue, ANewValue: Variant; var AArray: TVarDynArray2; const AFindColumn, AReplaceColumn: Integer; const AIgnoreCase: Boolean = False): Boolean; overload; //+++
    //возвращает столбец двухмерного массива Column в одномерном массиве
    function VarDynArray2ColToVD1(const AArray: TVarDynArray2; const AColumn: Integer): TVarDynArray; //+++
    //возвращает столбец двухмерного массива Row в одномерном массиве
    function VarDynArray2RowToVD1(const AArray: TVarDynArray2; const ARow: Integer): TVarDynArray; //+++
    //модифицирует двумерный массив вставкой или заменой его элемента первого уровня массивом TVarDynArray
    //при параметрах по умолчанию просто добавит массив TVarDynArray в конец массива TVarDynArray2
    procedure VarDynArray2InsertArr(var ATarget: TVarDynArray2; const ASource: TVarDynArray; const APosition: Integer = -1; const AInsert: Boolean = True); //+++
    //сортировка одномерного вариантного массива
    procedure VarDynArraySort(var AArray: TVarDynArray; const AAscending: Boolean = True); overload; //+++
    //быстрая сортировка одномерного массива
    procedure SortVD1(var AArray: TVarDynArray; const AAscending: Boolean = True); //+++
    //сортировка двухмерного вариантгного массива по переданному полю
    procedure VarDynArraySort(var AArray: TVarDynArray2; const AColumn: Integer; const AAscending: Boolean = True); overload; //+++
    //сортировка двухмерного вариантгного массива по переданному полю
    //поле передается на 1 больше чем в массиве, если с + то по возрастанию, а с - то по убыванию, ту при сортировке по убыванию по нулевой колонке передать -1
    procedure VarDynArray2Sort(var AArray: TVarDynArray2; const AKey: Integer); //+++
    //возвращает одномерный массив, являющийся пересечением, объединением или различием двух массивов
    function ArrCompare(const AArray1, AArray2: array of Variant; const AOperation: TArrayOperation): TVarDynArray; //+++
    //передается или целое число, или вариантный массив, или строка чисел через запятую,
    //возвращается массив
    function VarIntToArray(const AValue: Variant): TVarDynArray; //+++
    //получает массив строк, возвращает вариантный массив
    function StringDynArrayToVarDynArray(const AStringArray: TStringDynArray): TVarDynArray; //+++
    //удаляем дублирующиеся знаения из массива
    function RemoveDuplicates(const AValues: TVarDynArray): TVarDynArray; //+++
    //сравнение двух двумерных массивов (или одной их строки)
    //будут одинаковы, если совпадают размерности массивов и все их значения
    function IsArraysEqual(const A, B: TVarDynArray2; const ARow: Integer = -1): Boolean; //+++
    procedure SetNull(var AArray: TVarDynArray); overload; //+++
    procedure SetNull(var AArray: TVarDynArray2; const ARow: Integer = -1); overload; //+++
    procedure IncLength(var AArray: TVarDynArray); overload; //+++
    procedure IncLength(var AArray: TVarDynArray2); overload; //+++
  end;

var
  S: TMyStringHelper;   //глобальный экземпляр для работы со строками
  A: TMyArrayHelper;     //глобальный экземпляр для работы с массивами

type
  //============================================================================
  //Хелпер для типа Variant
  //============================================================================
  TVariantHelper = record helper for Variant
  public
    //Возвращает True, если значение Null.
    function IsNull: Boolean;
    //Возвращает True, если значение Empty.
    function IsEmpty: Boolean;
    //Возвращает True, если значение является числовым (целым или вещественным).
    function IsNumeric: Boolean;
    //Возвращает строковое представление; для Null/Empty возвращает пустую строку.
    function AsString: string;
    //Возвращает целое число; для Null/Empty возвращает 0.
    function AsInteger: Integer;
    //Возвращает целое число; для Null/Empty возвращает -1.
    function AsIntegerM: Integer;
    //Возвращает вещественное число; для Null/Empty возвращает 0.
    function AsFloat: Extended;
    //Возвращает Boolean; для Null/Empty возвращает False.
    function AsBoolean: Boolean;
    //Возвращает дату/время.
    function AsDateTime: TDateTime;
    //Возвращает Null, если значение равно 0 (как Extended).
    function NullIf0: Variant;
    //Возвращает Null, если значение Null или пустая строка.
    function NullIfEmpty: Variant;
  end;
//------------------------------------------------------------------------------
//Вспомогательные функции, необходимые для EhLib и других внешних модулей
//------------------------------------------------------------------------------

function WordPosition(const N: Integer; const S: string; WordDelims: TCharSet): Integer;

function ExtractWordPos(N: Integer; const S: string; WordDelims: TCharSet; var Pos: Integer): string;

function ExtractWord(N: Integer; const S: string; WordDelims: TCharSet): string;
//------------------------------------------------------------------------------
//Глобальная функция BadDate (для обратной совместимости)
//------------------------------------------------------------------------------

function BadDate: TDateTime;

implementation

uses
  System.IOUtils, System.Character;
//==============================================================================
//Вспомогательные функции TMyStringHelper
//==============================================================================

function TMyStringHelper.CharInArray(C: Char; const AChars: TCharDynArray): Boolean;
//Проверяет, содержится ли символ C в массиве AChars.
var
  i: Integer;
begin
  for i := 0 to High(AChars) do
    if AChars[i] = C then
      Exit(True);
  Result := False;
end;

function TMyStringHelper.CharSetToArray(const AChars: TCharSet): TCharDynArray;
//Преобразует множество Char в массив (только для символов <256).
var
  C: Char;
  i: Integer;
begin
  SetLength(Result, 0);
  for C in AChars do begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := C;
  end;
end;
//==============================================================================
//Методы обрезки пробелов и символов
//==============================================================================

function TMyStringHelper.TrimStr(const AStr: string; const ATrimChars: TCharDynArray; const AMode: TMyStringLocation): string;
//Удалим переданные символы слева, справа или с обеих сторон строки;
//если не передан массив символов, то удаляем пробел и табуляцию
//+++ переработана для поддержки Unicode: вместо множества используется массив символов
var
  lStart, lEnd: Integer;
  lTrimSet: TCharDynArray;
begin
  if ATrimChars = nil then
    lTrimSet := [' ', #9]
  else
    lTrimSet := ATrimChars;
  lStart := 1;
  lEnd := Length(AStr);
  if AMode in [stlLeft, stlBoth] then
    while (lStart <= lEnd) and CharInArray(AStr[lStart], lTrimSet) do
      Inc(lStart);
  if AMode in [stlRight, stlBoth] then
    while (lEnd >= lStart) and CharInArray(AStr[lEnd], lTrimSet) do
      Dec(lEnd);
  Result := Copy(AStr, lStart, lEnd - lStart + 1);
end;

function TMyStringHelper.TrimStr(const AStr: string; const ATrimChars: TCharSet; const AMode: TMyStringLocation): string;
//Устаревшая версия с множеством (не поддерживает Unicode)
begin
  Result := TrimStr(AStr, CharSetToArray(ATrimChars), AMode);
end;

procedure TMyStringHelper.TrimStrP(var AStr: string; const ATrimChars: TCharDynArray; const AMode: TMyStringLocation);
//Процедура. Удалим переданные символы слева, справа или с обеих сторон строки;
//если не передан массив символов, то удаляем пробел и табуляцию
//+++ переработана для поддержки Unicode
begin
  AStr := TrimStr(AStr, ATrimChars, AMode);
end;

procedure TMyStringHelper.TrimStrP(var AStr: string; const ATrimChars: TCharSet; const AMode: TMyStringLocation);
begin
  TrimStrP(AStr, CharSetToArray(ATrimChars), AMode);
end;

procedure TMyStringHelper.DelLeft(var AStr: string; const ATrimChars: TCharDynArray);
//удалим символы с левой части строки
//+++ переработана для поддержки Unicode
begin
  TrimStrP(AStr, ATrimChars, stlLeft);
end;

procedure TMyStringHelper.DelLeft(var AStr: string; const ATrimChars: TCharSet);
begin
  DelLeft(AStr, CharSetToArray(ATrimChars));
end;

procedure TMyStringHelper.DelRight(var AStr: string; const ATrimChars: TCharDynArray);
//удалим символы с правой части строки
//+++ переработана для поддержки Unicode
begin
  TrimStrP(AStr, ATrimChars, stlRight);
end;

procedure TMyStringHelper.DelRight(var AStr: string; const ATrimChars: TCharSet);
begin
  DelRight(AStr, CharSetToArray(ATrimChars));
end;

procedure TMyStringHelper.DelBoth(var AStr: string; const ATrimChars: TCharDynArray);
//Удаление переданного массива символов с обоих концов строки
//+++ переработана для поддержки Unicode
begin
  TrimStrP(AStr, ATrimChars, stlBoth);
end;

procedure TMyStringHelper.DelBoth(var AStr: string; const ATrimChars: TCharSet);
begin
  DelBoth(AStr, CharSetToArray(ATrimChars));
end;
//==============================================================================
//Замена символов
//==============================================================================

function TMyStringHelper.DeleteRepSpaces(const AStr: string; const AChar: Char): string;
//если в строке идут несколько пробелов подряд, то приводит их к одному пробелу
//+++ переработана с TStringBuilder для эффективности
var
  sb: TStringBuilder;
  i: Integer;
  lLastWasSpace: Boolean;
begin
  sb := TStringBuilder.Create;
  try
    lLastWasSpace := False;
    for i := 1 to Length(AStr) do begin
      if AStr[i] = AChar then begin
        if not lLastWasSpace then begin
          sb.Append(AChar);
          lLastWasSpace := True;
        end;
      end
      else begin
        sb.Append(AStr[i]);
        lLastWasSpace := False;
      end;
    end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TMyStringHelper.DeleteChar(const AStr: string; const AChar: Char): string;
//удаляем все символы Ch из строки
//+++ переработана с TStringBuilder
var
  sb: TStringBuilder;
  i: Integer;
begin
  sb := TStringBuilder.Create;
  try
    for i := 1 to Length(AStr) do
      if AStr[i] <> AChar then
        sb.Append(AStr[i]);
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TMyStringHelper.DeleteChars(const AStr: string; const AChars: TCharDynArray; const AMode: Boolean): string;
//mode=True  удаляет в строке все символы из [ch]
//mode=False удаляет в строке все символы из not[ch]
//+++ переработана для поддержки Unicode (параметр TCharDynArray)
var
  sb: TStringBuilder;
  c: Char;
begin
  sb := TStringBuilder.Create;
  try
    for c in AStr do
      if (AMode and CharInArray(c, AChars)) or (not AMode and not CharInArray(c, AChars)) then
        sb.Append(c);
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TMyStringHelper.DeleteChars(const AStr: string; const AChars: TCharSet; const AMode: Boolean): string;
begin
  Result := DeleteChars(AStr, CharSetToArray(AChars), AMode);
end;

function TMyStringHelper.ChangeChars(const AStr: string; const AChars: TCharDynArray; const ANewChar: Char; const AMode: Boolean): string;
//mode=True  заменяет в строке все символы из [ch] на символ chnew
//mode=False заменяет в строке все символы из not[ch] на символ chnew
//+++ переработана для поддержки Unicode (параметр TCharDynArray)
var
  sb: TStringBuilder;
  c: Char;
begin
  sb := TStringBuilder.Create;
  try
    for c in AStr do
      if (AMode and CharInArray(c, AChars)) or (not AMode and not CharInArray(c, AChars)) then
        sb.Append(ANewChar)
      else
        sb.Append(c);
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TMyStringHelper.ChangeChars(const AStr: string; const ACharSet: TCharSet; const ANewChar: Char; const AMode: Boolean): string;
begin
  Result := ChangeChars(AStr, CharSetToArray(ACharSet), ANewChar, AMode);
end;

function TMyStringHelper.FillString(const ALen: Integer; const AChar: Char): string;
//возвращает сроку символов Fill
begin
  SetLength(Result, ALen);
  FillChar(Result[1], ALen, AChar);
end;

function TMyStringHelper.DeleteRepSubstr(const AStr: string; const ASubStr: string): string;
//если в строке идут подряд последовательности символов (подстроки), то оставляет только первую из них
//не доделано!!! работает для уборки последовательносте типа ("1212ыыыы12", "12"), но не из повторяющихся символов (не должна быть последовательность "00"!!!
var
  i, j: Integer;
begin
  Result := AStr;
  i := 1;
  repeat
    j := PosEx(ASubStr, Result, i);
    if j = 0 then
      Exit;
    if j = i + 1 then //после предыдущего вхождения
      Delete(Result, j, Length(ASubStr))
    else
      i := j + 1;
  until False;
end;
//==============================================================================
//Выравнивание текста
//==============================================================================

function TMyStringHelper.PadLeft(const AStr: string; const ALen: Integer; const AChar: Char): string;
//дополняет строку переданным символом (по умолчанию пробел) слева, до переданной длины
begin
  Result := AStr.PadLeft(ALen, AChar);
end;

function TMyStringHelper.PadRight(const AStr: string; const ALen: Integer; const AChar: Char): string;
//дополняет строку переданным символом (по умолчанию пробел) справа, до переданной длины
begin
  Result := AStr.PadRight(ALen, AChar);
end;
//==============================================================================
//Проверка типов
//==============================================================================

function TMyStringHelper.IsInt(const AStr: string): Boolean;
//проверяет, является ли строка целым числом.
//+++ использует TryStrToInt
var
  i: Integer;
begin
  Result := TryStrToInt(AStr, i);
end;

function TMyStringHelper.IsFloat(const AStr: string): Boolean;
//проверяет, является ли строка числом с плавающей точкой
//+++ использует TryStrToFloat
var
  e: Extended;
begin
  Result := TryStrToFloat(AStr, e);
end;

function TMyStringHelper.IsNumber(const AStr: string; const AMin, AMax: Extended; const ADigits: Integer): Boolean;
//проверяет, является ли строка числом в заданном диапозоне с заданным числом десятичных знаков
//если число десятичных знаков не нужно, передать -1, если нужно целое число, передать 0
//+++ переработана с использованием TryStrToFloat
var
  lValue: Extended;
  lSepPos: Integer;
begin
  Result := TryStrToFloat(AStr, lValue) and (lValue >= AMin) and (lValue <= AMax);
  if Result and (ADigits >= 0) then begin
    lSepPos := Pos(FormatSettings.DecimalSeparator, AStr);
    if lSepPos = 0 then
      Result := (ADigits = 0)
    else
      Result := (Length(AStr) - lSepPos) <= ADigits;
  end;
end;

function TMyStringHelper.IsDateTime(const AStr: string; const ADateTimeType: string): Boolean;
//проверка строки на то что содержит дату/время
//DtType = dt - должно быть датой или датой со временем, DT - обязательно дата и время, d,D -только дата, t - только время
//предполагается что разделитель даты и времени - пробел (практически всегда это так), а часов и минут - ":"
//+++ использует TryStrToDateTime
var
  dt: TDateTime;
  lType: string;
begin
  Result := TryStrToDateTime(AStr, dt);
  if not Result then
    Exit;
  lType := UpperCase(ADateTimeType);
  if lType = 'DT' then
    Result := (Pos(' ', AStr) > 0) and (Pos(':', AStr) > 0)
  else if (lType = 'D') or (lType = 'Д') then
    Result := (Pos(' ', AStr) = 0)
  else if (lType = 'T') then
    Result := (Pos(':', AStr) > 0) and (Pos(' ', AStr) = 0);
end;

function TMyStringHelper.IsNumberLeftPart(const AStr: string): Integer;
//если строка есть число (целое положительное) возвр его длинну
//если начало строки есть число возвр длинну этой части со знаком -
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AStr) do
    if AStr[i] in ['0'..'9'] then
      Inc(Result)
    else begin
      Result := -Result;
      Break;
    end;
end;

function TMyStringHelper.IsValidEmail(const AValue: string): Boolean;
//проверяетвалидность почтового адреса по формальным признакам (адрес должен соответствовать стандарту)
var
  i: Integer;
  lName, lDomain: string;
begin
  i := Pos('@', AValue);
  if i = 0 then
    Exit(False);
  lName := Copy(AValue, 1, i - 1);
  lDomain := Copy(AValue, i + 1, MaxInt);
  if (lName = '') or (Length(lDomain) < 5) then
    Exit(False);
  i := Pos('.', lDomain);
  if (i = 0) or (i > Length(lDomain) - 2) then
    Exit(False);
  Result := True;
  for i := 1 to Length(lName) do
    if not CharInSet(lName[i], ['a'..'z', 'A'..'Z', '0'..'9', '_', '-', '.']) then
      Exit(False);
  for i := 1 to Length(lDomain) do
    if not CharInSet(lDomain[i], ['a'..'z', 'A'..'Z', '0'..'9', '_', '-', '.']) then
      Exit(False);
end;
//==============================================================================
//Перевод строки в простые типы
//==============================================================================

function TMyStringHelper.StrToNumberCommaDot(const AValue: Variant; const AMin, AMax: Extended; out ARes: Extended; const ADigits: Integer): Boolean;
//проверяем, является ли строка числом в заданном диапозоне с заданным количеством чисел после запятой (не более)
//в качестве разделителей принимаем точку и запятую
//возвращаем число в Res: extended, а Result - истина или ложь /если не удалось преобразовать в число/
//+++ переработана с использованием TryStrToFloat и замены разделителя
var
  s: string;
  lSepPos: Integer;
begin
  s := VarToStr(AValue);
  s := StringReplace(s, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := TryStrToFloat(s, ARes) and (ARes >= AMin) and (ARes <= AMax);
  if Result and (ADigits >= 0) then begin
    lSepPos := Pos(FormatSettings.DecimalSeparator, s);
    if lSepPos = 0 then
      Result := (ADigits = 0)
    else
      Result := (Length(s) - lSepPos) <= ADigits;
  end;
end;

function TMyStringHelper.VarToInt(const AValue: Variant; const ADefault: Integer): Integer;
//преобразует тип Variant в Integer; при неудаче возвращает значение Def
//+++ использует TryStrToInt
begin
  if not TryStrToInt(VarToStr(AValue), Result) then
    Result := ADefault;
end;

function TMyStringHelper.VarToFloat(const AValue: Variant; const ADefault: Extended): Extended;
//преобразует тип Variant в Extended; при неудаче возвращает значение Def
//+++ использует TryStrToFloat
begin
  if not TryStrToFloat(VarToStr(AValue), Result) then
    Result := ADefault;
end;

function TMyStringHelper.NumToString(const ANumber: Extended; const ALen: Byte; const AChar: Char): string;
//преобразовывает число в строку длиной не менее Len, позиции перед числом заполняет символом Ch
begin
  Result := Format('%' + IntToStr(ALen) + '.' + IntToStr(ALen) + 'f', [ANumber]);
  while (Result <> '') and (Result[1] = ' ') do
    Result[1] := AChar;
end;

function TMyStringHelper.SpacedStToDate(const AStr: string; const AFullDateTime: Boolean): TDateTime;
//преобразует строку из трех или пяти чисел, разделенных пробелами (дефисами, точками), в TDateTime
//если ошиибка возвращает BadDate
//использовать только при вводе вручную или при явно корректном формате так как в среде будет вызываться исключение
//+++ улучшена обработка двузначного года
var
  lParts: TStringDynArray;
  y, m, d, h, n: Integer;
  s: string;
begin
  Result := BadDate;
  s := Trim(AStr);
  s := StringReplace(s, '-', ' ', [rfReplaceAll]);
  s := StringReplace(s, '.', ' ', [rfReplaceAll]);
  lParts := A.ExplodeS(s, ' ', True);
  if Length(lParts) < 3 then
    Exit;
  d := StrToIntDef(lParts[0], 0);
  m := StrToIntDef(lParts[1], 0);
  y := StrToIntDef(lParts[2], 0);
  if (y < 100) then
    y := 2000 + y;
  if not TryEncodeDate(y, m, d, Result) then
    Exit;
  if AFullDateTime and (Length(lParts) >= 5) then begin
    h := StrToIntDef(lParts[3], 0);
    n := StrToIntDef(lParts[4], 0);
    Result := Result + EncodeTime(h, n, 0, 0);
  end;
end;

function TMyStringHelper.DateTimeToIntStr(const ADateTime: TDateTime): string;
//преобразует TDateTime в число (Double) и возвращает  в виде строки
//сервисная функция
begin
  Result := FloatToStr(Double(ADateTime));
end;
//==============================================================================
//Обработка Null/Empty
//==============================================================================

function TMyStringHelper.NSt(const AValue: Variant): string;
//возвращает пустую строку, если значение Empty или Null
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then
    Result := ''
  else
    Result := VarToStr(AValue);
end;

function TMyStringHelper.NNum(const AValue: Variant; const ADefault: Extended): Extended;
//возвращает 0 с типом extended, если значение Empty или Null
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then
    Result := ADefault
  else
    Result := AValue;
end;

function TMyStringHelper.NInt(const AValue: Variant): Integer;
//возвращает 0 с типом Integer, если значение Empty или Null
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then
    Result := 0
  else
    Result := AValue;
end;

function TMyStringHelper.NIntM(const AValue: Variant): Integer;
//возвращает -1 с типом Integer, если значение Empty или Null
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then
    Result := -1
  else
    Result := AValue;
end;

function TMyStringHelper.NullIfEmpty(const AValue: Variant): Variant;
//возвращает нулл если v=null or VarToString(v) ='', иначе вернет переданное значение
begin
  if VarIsNull(AValue) or (VarToStr(AValue) = '') then
    Result := Null
  else
    Result := AValue;
end;

function TMyStringHelper.NullIf0(const AValue: Variant): Variant;
//возвращает нулл если v=0 (0.00), иначе вернет переданное значение
begin
  if VarIsNull(AValue) then
    Result := Null
  else
  try
    if Extended(AValue) = 0 then
      Result := Null
    else
      Result := AValue;
  except
    Result := AValue;
  end;
end;
//==============================================================================
//Регистр
//==============================================================================

function TMyStringHelper.ChangeCaseStr(const AStr: string; const AToUpper: Boolean): string;
//изменить регистр строки (и латинские и русские буквы
//+++ использует встроенные ToUpper/ToLower
begin
  if AToUpper then
    Result := AStr.ToUpper
  else
    Result := AStr.ToLower;
end;

function TMyStringHelper.ChangeCaseCh(const ACh: Char; const AToUpper: Boolean): Char;
//изменить регистр символа (и латинские и русские буквы
//+++ использует TCharacter
begin
  if AToUpper then
    Result := TCharacter.ToUpper(ACh)
  else
    Result := TCharacter.ToLower(ACh);
end;

function TMyStringHelper.ToUpper(const AStr: string): string;
//строку в верхний регистр
begin
  Result := AStr.ToUpper;
end;

function TMyStringHelper.ToLower(const AStr: string): string;
//строку в нижний регистр
begin
  Result := AStr.ToLower;
end;

function TMyStringHelper.Right(const AStr: string; const ACount: Integer): string;
//получает Cnt правых символов строки
begin
  Result := Copy(AStr, Length(AStr) - ACount + 1, ACount);
end;
//==============================================================================
//Поиск вхождений
//==============================================================================

function TMyStringHelper.PosI(const ASubStr, AStr: string): Integer;
//находит позицию подстроки в строке без учета регистра
begin
  Result := Pos(UpperCase(ASubStr), UpperCase(AStr));
end;

function TMyStringHelper.InCommaStr(const APart, AFull: string; const ADelimiter: Char; const AIgnoreCase: Boolean): Boolean;
//проверяет, содержится ли подстрока в строке значений, разделенных запятыми
//+++ переработана с учётом регистра
var
  lPart, lFull: string;
begin
  if AIgnoreCase then begin
    lPart := UpperCase(APart);
    lFull := UpperCase(AFull);
  end
  else begin
    lPart := APart;
    lFull := AFull;
  end;
  Result := Pos(ADelimiter + lPart + ADelimiter, ADelimiter + lFull + ADelimiter) > 0;
end;

function TMyStringHelper.InCommaStrI(const APart, AFull: string; const ADelimiter: Char): Boolean;
//проверяет, содержится ли подстрока в строке значений, разделенных запятыми, без учета регистра
begin
  Result := InCommaStr(APart, AFull, ADelimiter, True);
end;

function TMyStringHelper.GetCharCountInStr(const AStr: string; const AChars: TCharDynArray; const AStart, AEnd: Integer): Integer;
//подсчитывает количество символов из переданного набора в строке, начиная с позиции р1 и до р2 (если -1 то до конца строки)
//+++ переработана для поддержки Unicode (TCharDynArray)
var
  i, lStart, lEnd: Integer;
begin
  lStart := AStart;
  lEnd := AEnd;
  if lEnd = -1 then
    lEnd := Length(AStr);
  Result := 0;
  for i := lStart to lEnd do
    if CharInArray(AStr[i], AChars) then
      Inc(Result);
end;

function TMyStringHelper.GetCharCountInStr(const AStr: string; const AChars: TCharSet; const AStart, AEnd: Integer): Integer;
begin
  Result := GetCharCountInStr(AStr, CharSetToArray(AChars), AStart, AEnd);
end;

function TMyStringHelper.FindBegWord(const AStartPos: Integer; const AStr: string; const ADelimiters: TCharDynArray): Integer;
//ищем позицию начяала слова в строке, передается начальная позиция поиска,
//счетчик идет назад пока не встретистся символ из DivSymbols
//+++ переработана для поддержки Unicode (TCharDynArray)
var
  i: Integer;
  lDelimiters: TCharDynArray;
begin
  if ADelimiters = nil then
    lDelimiters := [' ']
  else
    lDelimiters := ADelimiters;
  i := AStartPos;
  while (i > 0) and not CharInArray(AStr[i], lDelimiters) do
    Dec(i);
  Result := i + 1;
end;

function TMyStringHelper.FindBegWord(const AStartPos: Integer; const AStr: string; const ADelimiters: TCharSet): Integer;
begin
  Result := FindBegWord(AStartPos, AStr, CharSetToArray(ADelimiters));
end;

function TMyStringHelper.FindEndWord(const AStartPos: Byte; const AStr: string; ADelimiters: TCharDynArray): Integer;
//ищем позицию конца слова в строке, передается начальная позиция поиска,
//счетчик идет вперед пока не встретистся символ из DivSymbols
//+++ переработана для поддержки Unicode (TCharDynArray)
var
  i: Integer;
  lDelimiters: TCharDynArray;
begin
  if ADelimiters = nil then
    lDelimiters := [' ']
  else
    lDelimiters := ADelimiters;
  i := AStartPos;
  while (i <= Length(AStr)) and not CharInArray(AStr[i], lDelimiters) do
    Inc(i);
  if i > Length(AStr) then
    Dec(i);
  Result := i;
end;

function TMyStringHelper.FindEndWord(const AStartPos: Byte; const AStr: string; const ADelimiters: TCharSet): Integer;
begin
  Result := FindEndWord(AStartPos, AStr, CharSetToArray(ADelimiters));
end;

procedure TMyStringHelper.DivisionQuotetStr(const AStr: string; out ALeft, AMid, ARight: string);
//разбиение строки St на 3 части: St1 -до кавычек, St2 - в кавычках, St3 - после
//кавычки учитываются как двойные так и одинарные
//осталось от старого
//+++ переработана (незначительно)
var
  a, b, i, j: Integer;
begin
  ALeft := '';
  AMid := '';
  ARight := '';
  a := 1;
  while (a <= Length(AStr)) and not CharInSet(AStr[a], ['"', '''']) do
    Inc(a);
  if a <= Length(AStr) then begin
    b := a + 1;
    while (b <= Length(AStr)) and not CharInSet(AStr[b], ['"', '''']) do
      Inc(b);
    if (b > Length(AStr)) then begin
      a := 0;
      b := 0;
    end;
  end
  else
    a := 0;
  if (a > 0) and (b > a + 1) then begin
    i := a + 1;
    j := b - 1;
    while (i < j) and (AStr[i] = ' ') do
      Inc(i);
    while (i < j) and (AStr[j] = ' ') do
      Dec(j);
    AMid := Copy(AStr, i, j - i + 1);
  end;
  if a = 0 then
    ALeft := AStr
  else
    ALeft := Copy(AStr, 1, a - 1);
  if b = 0 then
    ARight := ''
  else
    ARight := Copy(AStr, b + 1, Length(AStr) - b);
end;

function TMyStringHelper.GetSubStr(const AStr: string; const AIndex: Integer; const ADelimiter: string; out APos: Integer): string;
//получает подстроку номер NumSubSt из строки, которую разбивает по строковым разделителям DivSt
//возвращает также позицию найденной подстроки в строке
//если не смог выделить подстроку, то возвращает -2 и ''
//+++ переработана для ясности
var
  lTemp: string;
  i, j: Integer;
begin
  APos := 1;
  lTemp := AStr;
  for i := 1 to AIndex do begin
    j := Pos(ADelimiter, lTemp);
    if i = AIndex then begin
      if j > 0 then
        Result := Copy(lTemp, 1, j - 1)
      else
        Result := lTemp;
      Exit;
    end;
    if j = 0 then begin
      APos := -2;
      Result := '';
      Exit;
    end;
    lTemp := Copy(lTemp, j + Length(ADelimiter), MaxInt);
    APos := APos + j + Length(ADelimiter) - 1;
  end;
end;

function TMyStringHelper.FindMaskInStr(var AMask, AStr: string): Boolean;
//Поиск по маске:  Сpавнение стpоки St с шаблоном Mask. В шаблоне можно
//yпотpеблять знаки '?'(любой знак) и '*' (любое количество любых знаков)
var
  mp, sp, last: Integer;
  ml, sl: Integer;
begin
  Result := False;
  mp := 1;
  sp := 1;
  sl := Length(AStr);
  ml := Length(AMask);
  repeat
    if (sp > sl) then begin
      Result := (mp > ml);
      Exit;
    end;
    if (AMask[mp] <> '?') and (AMask[mp] <> AStr[sp]) then
      Break;
    Inc(mp);
    Inc(sp);
  until False;
  if AMask[mp] <> '*' then
    Exit(False);
  repeat
    while (mp <= ml) and (AMask[mp] = '*') do begin
      Inc(mp);
      last := mp;
      if mp > ml then begin
        Result := True;
        Exit;
      end;
    end;
    if sp > sl then begin
      Result := (mp > ml);
      Exit;
    end;
    if (AMask[mp] <> '?') and (AMask[mp] <> AStr[sp]) then begin
      sp := sp - ((mp - last) - 1);
      mp := last;
    end
    else begin
      Inc(mp);
      Inc(sp);
    end;
  until False;
end;

function TMyStringHelper.FindADDMaskInStr(const AMask, AStr: string): Boolean;
//Поиск по маске:  Сpавнение стpоки St с шаблоном Mask. В шаблоне можно
//yпотpеблять знаки '?'(любой знак) и '*' (любое количество любых знаков)}
var
  m, s: string;
begin
  m := AMask;
  s := AStr;
  Result := FindMaskInStr(m, s);
end;
//==============================================================================
//Специальные преобразования
//==============================================================================

function TMyStringHelper.NumToWords(const ANum: LongInt; const AGender: Char): string;
//преобразование числа в строку прописью
const
  cNumWords: array[1..3, 1..9] of string = (('один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять'), ('десять', 'двадцать', 'тридцать', 'сорок', 'пятьдесят', 'шестьдесят', 'семьдесят', 'восемьдесят', 'девяносто'), ('сто', 'двести', 'триста', 'четыреста', 'пятьсот', 'шестьсот', 'семьсот', 'восемьсот', 'девятьсот'));
  cNumWords_1X: array[0..9] of string = ('десять', 'одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать');
  cNumWords_F: array[1..2] of string = ('одна', 'две');
  cNumWords_N: array[1..1] of string = ('одно');
  cRankWords: array[1..2, 1..3] of string = (('тысяча', 'тысячи', 'тысяч'), ('миллион', 'миллиона', 'миллионов'));
  cZero: string = 'ноль';
var
  n, n1, i, j, lRank: LongInt;
  lAdded: Boolean;
  lResult: string;
begin
  if ANum = 0 then
    Exit(cZero + ' ');
  lResult := '';
  lRank := 100000000;
  i := 2;
  repeat
    j := 3;
    lAdded := False;
    repeat
      n1 := n;
      n := ANum mod (lRank * 10) div lRank;
      if ((n > 0) and not ((j = 2) and (n = 1))) or ((j = 1) and (n1 = 1)) then begin
        if (j = 1) and (n1 = 1) then
          lResult := lResult + cNumWords_1X[n] + ' '
        else begin
          if (j = 1) and (n < 3) and ((i = 1) or ((AGender = 'F') and (i = 0))) then
            lResult := lResult + cNumWords_F[n] + ' '
          else if (j = 1) and (n < 2) and (AGender = 'N') and (i = 0) then
            lResult := lResult + cNumWords_N[n] + ' '
          else
            lResult := lResult + cNumWords[j][n] + ' ';
        end;
        lAdded := True;
      end;
      Dec(j);
      lRank := lRank div 10;
    until j = 0;
    if lAdded and (i <> 0) then begin
      if n1 <> 1 then
        case n of
          1:
            lResult := lResult + cRankWords[i][1];
          2..4:
            lResult := lResult + cRankWords[i][2];
        else
          lResult := lResult + cRankWords[i][3];
        end
      else
        lResult := lResult + cRankWords[i][3];
      lResult := lResult + ' ';
    end;
    Dec(i);
  until i = -1;
  Result := lResult;
end;

function TMyStringHelper.NumToPriceWords(const ANum: LongInt; const AMode: Boolean): string;
//преобразование числа в строку цены прописью
var
  lRub, lKop: LongInt;
begin
  if AMode then begin
    lKop := ANum mod 100;
    lRub := ANum div 100;
    Result := NumToWords(lRub, 'm') + PriceWord(lRub, 'R') + ' ';
    if lKop < 10 then
      Result := Result + 'ноль ';
    Result := Result + NumToWords(lKop, 'f') + PriceWord(lKop, 'K');
  end
  else begin
    lRub := ANum * 10;
    Result := NumToWords(lRub, 'm') + PriceWord(lRub, 'R');
  end;
end;

function TMyStringHelper.NumToPriceStr(const ANum: LongInt): string;
//преобразует число в сцену в рублях и копейках в виде числа а не слов
//работает тут НЕПРАВИЛЬНО, цена в целом числе, 2 последние это копейки
var
  s: string;
  lMinus: Boolean;
begin
  lMinus := ANum < 0;
  if lMinus then
    s := IntToStr(-ANum)
  else
    s := IntToStr(ANum);
  if ANum = 0 then
    s := '0' + KopDividor + '00'
  else if ANum < 10 then
    s := '0' + KopDividor + '0' + s
  else if ANum < 100 then
    s := '0' + KopDividor + s
  else begin
    Insert(KopDividor, s, Length(s) - 1);
    if RubDividor <> '' then begin
      if Length(s) > 5 + Length(KopDividor) then
        Insert(RubDividor, s, Length(s) - 4 - Length(KopDividor));
      if Length(s) > 8 + Length(RubDividor) + Length(KopDividor) then
        Insert(RubDividor, s, Length(s) - 7 - Length(RubDividor) + Length(KopDividor));
      if Length(s) > 11 + 2 * Length(RubDividor) + Length(KopDividor) then
        Insert(RubDividor, s, Length(s) - 10 - 2 * Length(RubDividor) + Length(KopDividor));
    end;
  end;
  if Kop2Dividor <> '' then begin
    if ANum < 100 then
      Delete(s, 1, 1 + Length(KopDividor));
    s := s + Kop2Dividor;
  end;
  if lMinus then
    s := '-' + s;
  Result := s;
end;

function TMyStringHelper.PriceWord(const ANum: LongInt; const AMode: Char): string;
//сервисная функция для вывода цены с включением слов Рублей и Копеек
var
  lLastDigit, lLastTwoDigits: Integer;
begin
  lLastTwoDigits := Abs(ANum) mod 100;
  lLastDigit := lLastTwoDigits mod 10;
  if AMode = 'R' then begin
    if (lLastTwoDigits >= 10) and (lLastTwoDigits <= 20) then
      Result := 'рублей'
    else
      case lLastDigit of
        1:
          Result := 'рубль';
        2..4:
          Result := 'рубля';
      else
        Result := 'рублей';
      end;
  end
  else //'K'
  begin
    if (lLastTwoDigits >= 10) and (lLastTwoDigits <= 20) then
      Result := 'копеек'
    else
      case lLastDigit of
        1:
          Result := 'копейка';
        2..4:
          Result := 'копейки';
      else
        Result := 'копеек';
      end;
  end;
end;

function TMyStringHelper.NumToPhoneStr(const ANum: LongInt): string;
//преобразование числа в строку телефона с разделителями
var
  s: string;
begin
  s := IntToStr(ANum);
  if Length(s) <= 7 then begin
    Insert('-', s, Length(s) - 1);
    Insert('-', s, Length(s) - 4);
  end;
  Result := s;
end;

function TMyStringHelper.StrToPhoneStr(const APhone: string): string;
//форматирование строки как строки телефона с разделителями
//+++ переработана с использованием DeleteCharsEx
var
  s: string;
begin
  s := Trim(APhone);
  s := DeleteChars(s, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], False);
  Result := NumToPhoneStr(StrToIntDef(s, 0));
end;

function TMyStringHelper.GetEnding(const ANum: LongInt; const AWord1, AWord2, AWord3: string): string;
//выбирает окончание по количеству
//(передается окончание для кол-ва 1, 2{3,4}, 5(6,7,8,9,10)
begin
  if (Abs(ANum) mod 100) in [10..20] then
    Result := AWord3
  else
    case Abs(ANum) mod 10 of
      1:
        Result := AWord1;
      2..4:
        Result := AWord2;
    else
      Result := AWord3;
    end;
end;

function TMyStringHelper.GetEndingFull(const ANum: LongInt; const AMain, AWord1, AWord2, AWord3: string): string;
//(передается количество, основная часть слова, окончание для кол-ва 1, 2{3,4}, 5(6,7,8,9,10)
begin
  Result := IntToStr(ANum) + ' ' + AMain + GetEnding(ANum, AWord1, AWord2, AWord3);
end;

function TMyStringHelper.GetEndingOneOrMany(const ANum: LongInt; const ASingular, APlural: string): string;
//выбирает окончание по количеству (толькко ед/множ число)
begin
  if ANum = 1 then
    Result := ASingular
  else
    Result := APlural;
end;

function TMyStringHelper.AddBracket(const AStr: string): string;
//заключить строку в круглые скобки, если она не пустая
begin
  if AStr = '' then
    Result := ''
  else
    Result := '(' + AStr + ')';
end;

function TMyStringHelper.FormatNumberWithComma(const AValue: Extended; const ADividerIsComma: Boolean): string;
//форматируем число в строку. если есть дробная часть, то она будет дана через запятую (по умолчанию) или точку
begin
  if Abs(AValue - Round(AValue)) < 1E-9 then
    Result := FormatFloat('0', AValue)
  else
    Result := FormatFloat('0.########', AValue);
  if ADividerIsComma then
    Result := StringReplace(Result, '.', ',', [rfReplaceAll])
  else
    Result := StringReplace(Result, ',', '.', [rfReplaceAll]);
end;
//==============================================================================
//Условные функции
//==============================================================================

function TMyStringHelper.IIf(const AExpr: Boolean; const ATrueValue, AFalseValue: Variant): Variant;
//если Expr истина, то вернет Par1, иначе Par2
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function TMyStringHelper.IIfV(const AExpr: Boolean; const ATrueValue, AFalseValue: Variant): Variant;
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function TMyStringHelper.IIFStr(const AExpr: Boolean; const ATrueStr, AFalseStr: string): string;
begin
  if AExpr then
    Result := ATrueStr
  else
    Result := AFalseStr;
end;

function TMyStringHelper.IfEmptyStr(const AStr, AEmptyResult: string): string;
//если первый аргумент не пуст, возвращает его, иначе - второй
begin
  if AStr = '' then
    Result := AEmptyResult
  else
    Result := AStr;
end;

function TMyStringHelper.IfNotEmptyStr(const AStr, AMask, AEmptyResult: string): string;
//заменяет в маске символ #0 на строку, если строка непустая; если пустая, вернет ''
begin
  if AStr <> '' then
    Result := StringReplace(AMask, #0, AStr, [rfReplaceAll])
  else
    Result := AEmptyResult;
end;

function TMyStringHelper.IIfInt(const AExpr: Boolean; const ATrueValue, AFalseValue: Integer): Integer;
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function TMyStringHelper.IIfFloat(const AExpr: Boolean; const ATrueValue, AFalseValue: Extended): Extended;
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function TMyStringHelper.IfEl(const AValue, AIfValue, AElseValue: Variant): Variant;
//Если AValue = AIfValeu, то вернет AIfValeu, иначе AElseValue
begin
  if AValue = AIfValue then
    Result := AIfValue
  else
    Result := AElseValue;
end;

function TMyStringHelper.IfNotEqual(const AValueFact, AValueCheck, AValueRes: Variant): Variant;
//если ValueFact = ValueCheck, то вернет ValueFact, иначе ValueRes
begin
  if AValueFact <> AValueCheck then
    Result := AValueRes
  else
    Result := AValueFact;
end;

function TMyStringHelper.IfNotEmpty(const AValueFact, AValueRes: Variant): Variant;
//если ValueFact не пустое (empty, '', null), то вернет ValueFact, иначе ValueRes
begin
  if not VarIsNull(AValueFact) and not VarIsEmpty(AValueFact) and (VarToStr(AValueFact) <> '') then
    Result := AValueFact
  else
    Result := AValueRes;
end;

function TMyStringHelper.Decode(const AArray: TVarDynArray): Variant;
//возвращает из массива результат, соответствующий нулевому значению
//value, case1, value1, case2, value2, {valueelse}
var
  i: Integer;
begin
  Result := Null;
  if Length(AArray) = 0 then
    Exit;
  i := 1;
  while i < High(AArray) do begin
    if VarCompareValue(AArray[0], AArray[i]) = vrEqual then begin
      Result := AArray[i + 1];
      Exit;
    end;
    Inc(i, 2);
  end;
  if i = High(AArray) then
    Result := AArray[i];
end;

function TMyStringHelper.CompareStI(const AStr1, AStr2: string): Boolean;
//сравнить две строки без учета регистра
begin
  Result := SameText(AStr1, AStr2);
end;
//==============================================================================
//Конкатенация строк
//==============================================================================

function TMyStringHelper.ConcatStr(const AMain, APart, ADelimiter: string; const AIgnoreEmpty: Boolean): string;
//добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
begin
  Result := AMain;
  if AIgnoreEmpty and (APart = '') then
    Exit;
  if Result <> '' then
    Result := Result + ADelimiter;
  Result := Result + APart;
end;

procedure TMyStringHelper.ConcatStrP(var AMain: string; const APart, ADelimiter: string; const AIgnoreEmpty: Boolean);
//процедура. добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
begin
  if AIgnoreEmpty and (APart = '') then
    Exit;
  if AMain <> '' then
    AMain := AMain + ADelimiter;
  AMain := AMain + APart;
end;

procedure TMyStringHelper.ConcatStrP(var AMain: Variant; const APart, ADelimiter: Variant; const AIgnoreEmpty: Boolean);
//процедура. добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
var
  sMain, sPart, sDelim: string;
begin
  sMain := VarToStr(AMain);
  sPart := VarToStr(APart);
  sDelim := VarToStr(ADelimiter);
  if AIgnoreEmpty and (sPart = '') then
    Exit;
  if sMain <> '' then
    sMain := sMain + sDelim;
  sMain := sMain + sPart;
  AMain := sMain;
end;

function TMyStringHelper.ConcatSt(const AMain, APart, ADelimiter: string; const AIgnoreEmpty: Boolean): string;
//добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
begin
  Result := ConcatStr(AMain, APart, ADelimiter, AIgnoreEmpty)
end;

procedure TMyStringHelper.ConcatStP(var AMain: string; const APart, ADelimiter: string; const AIgnoreEmpty: Boolean);
//процедура. добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
begin
  ConcatStrP(AMain, APart, ADelimiter, AIgnoreEmpty);
end;

procedure TMyStringHelper.ConcatStP(var AMain: Variant; const APart, ADelimiter: Variant; const AIgnoreEmpty: Boolean);
//процедура. добавляет строку StPart к StAll через разделитеть. если задано IfNotEmpty, то пустая строка не присоединяется
begin
  ConcatStrP(AMain, APart, ADelimiter, AIgnoreEmpty);
end;

//==============================================================================
//SQL функции
//==============================================================================
function TMyStringHelper.SQLDate(const ADateTime: TDateTime): AnsiString;
//форматирует дяту в тот вид, который можно вставить в скл
//в сам текст, в параметра передается просто сам тип даты)
var
  y, m, d: Word;
begin
  DecodeDate(ADateTime, y, m, d);
  Result := AnsiString(Format('%.4d%.2d%.2d', [y, m, d]));
end;

function TMyStringHelper.SQLDateTime(const ADateTime: TDateTime): AnsiString;
//преобразование даты, включая временнУю часть, в строку соотв формату даты в выбранной БД
var
  y, m, d, h, n, s, ms: Word;
begin
  DecodeDateTime(ADateTime, y, m, d, h, n, s, ms);
  Result := AnsiString(Format('%.4d%.2d%.2d%.2d%.2d%.2d', [y, m, d, h, n, s]));
end;
//==============================================================================
//Математические
//==============================================================================

function TMyStringHelper.MaxOf(const AValues: array of Variant): Variant;
//выбирает максимальное значение из вариантного массива
var
  i: Integer;
begin
  Result := AValues[0];
  for i := 0 to High(AValues) do
    if AValues[i] > Result then
      Result := AValues[i];
end;

function TMyStringHelper.MinOf(const AValues: array of Variant): Variant;
//выбирает минимальное значение из вариантного массива
var
  i: Integer;
begin
  Result := AValues[0];
  for i := 0 to High(AValues) do
    if AValues[i] < Result then
      Result := AValues[i];
end;
//==============================================================================
//Служебные функции
//==============================================================================

function TMyStringHelper.BadDate: TDateTime;
//возвращает дату, которую условились считать признаком неверной даты/времени
begin
  Result := EncodeDate(1900, 12, 30);
end;

procedure TMyStringHelper.SwapPlaces(var AValue1, AValue2: Variant);
//производит обмен значениями между двумя переменными
var
  tmp: Variant;
begin
  tmp := AValue1;
  AValue1 := AValue2;
  AValue2 := tmp;
end;

function TMyStringHelper.CorrectFileName(const AStr: string): string;
//скорректируем строку для использования в качестве имени файла
begin
  Result := Trim(AStr);
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
  while (Result <> '') and (Result[Length(Result)] = '.') do
    Delete(Result, Length(Result), 1);
end;

function TMyStringHelper.ValidateInn(const AInn: Variant): string;
//проверка ИНН
var
  s: string;
  code: Integer;

  function CheckDigit(const S: string; Coef: array of Integer): Integer;
  var
    i, sum: Integer;
  begin
    sum := 0;
    for i := 0 to High(Coef) do
      sum := sum + Coef[i] * (Ord(S[i + 1]) - 48);
    Result := sum mod 11 mod 10;
  end;

begin
  s := VarToStr(AInn);
  if s = '' then
    Exit('ИНН пуст');
  if not TryStrToInt(s, code) then
    Exit('ИНН может состоять только из цифр');
  if not (Length(s) in [10, 12]) then
    Exit('ИНН может состоять только из 10 или 12 цифр');
  if Length(s) = 10 then begin
    if CheckDigit(s, [2, 4, 10, 3, 5, 9, 4, 6, 8]) = StrToInt(s[10]) then
      Result := ''
    else
      Result := 'Неправильное контрольное число';
  end
  else begin
    if (CheckDigit(s, [7, 2, 4, 10, 3, 5, 9, 4, 6, 8]) = StrToInt(s[11])) and (CheckDigit(s, [3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8]) = StrToInt(s[12])) then
      Result := ''
    else
      Result := 'Неправильное контрольное число';
  end;
end;

function TMyStringHelper.StringToPAnsiChar(const AString: string): PAnsiChar;
//конвертация типа string в PAnsiChar c проверкой (при ошибке исключение)
var
  a: AnsiString;
begin
  a := AnsiString(AString);
  Result := PAnsiChar(a);
end;

function TMyStringHelper.WideStringToString(const ws: WideString; codePage: Word): AnsiString;
begin
  // заглушка, при необходимости реализовать
  Result := '';
end;

function TMyStringHelper.StringToWideString(const s: AnsiString; codePage: Word): WideString;
begin
  // заглушка
  Result := '';
end;

function TMyStringHelper.GetFieldNameFromSt(const ASqlExpr: string): string;
//возвращает имя поля в таблице из имени поля в селесте   например из '1 as field' вернет 'field'
//например из '1 as field$s' вернет 'field$s'
var
  parts: TStringDynArray;
begin
  parts := a.ExplodeS(ASqlExpr, ' ');
  if Length(parts) = 0 then
    Result := ''
  else
    Result := parts[High(parts)];
end;

function TMyStringHelper.GetDBFieldNameFromSt(const ASqlExpr: string; const AWithMod: Boolean): string;
//возвращает имя поля в таблице из имени поля в селесте
//например из '1 as field$s' вернет 'field', а если установлен WithMod, то 'field$s'
var
  parts, sub: TStringDynArray;
begin
  parts := a.ExplodeS(ASqlExpr, ' ');
  if Length(parts) = 0 then
    Exit('');
  if AWithMod then
    Result := parts[High(parts)]
  else begin
    sub := a.ExplodeS(parts[High(parts)], '$');
    Result := sub[0];
  end;
end;

function TMyStringHelper.GetDaysCountToName(const ADays: Integer): string;
//возвращает назавание периода в зависимсоти от количества дней:
//неделя, 4 дня, месяц, 3 месяца, полгода, год, 68 дней - с допусками несколько дней для градаций по месяцам
begin
  case ADays of
    7:
      Result := 'неделя';
    14:
      Result := '2 недели';
    21:
      Result := '3 недели';
    29..31:
      Result := 'месяц';
    60..62:
      Result := '2 месяца';
    90..93:
      Result := '3 месяца';
    120..124:
      Result := '4 месяца';
    150..155:
      Result := '5 месяцев';
    180..186:
      Result := '6 месяцев';
    210..217:
      Result := '7 месяцев';
    240..248:
      Result := '8 месяцев';
    270..279:
      Result := '9 месяцев';
    300..310:
      Result := '10 месяцев';
    330..341:
      Result := '11 месяцев';
    365..366:
      Result := 'год';
  else
    Result := IntToStr(ADays) + ' ' + GetEnding(ADays, 'день', 'дня', 'дней');
  end;
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
  v1 := Verify;
  if v1 = '' then
    Exit;
  ver := a.ExplodeS(v1 + '::::::', ':');
  //st := C.Field.AsString;
  st := Value;
  if (ValueType[1] in ['I', 'i', 'F', 'f']) then begin
    if st = '' then
      Result := (pos('N', s.ChangeCaseStr(ver[3], True)) = 0)
    else
      Result := s.IsNumber(st, StrToFloatDef(ver[0], 0), StrToFloatDef(ver[1], 0), StrToIntDef(ver[2], -1));
  end
  else if (ValueType[1] in ['D', 'd']) then begin
    b := IsDateTime(st, 'dt');
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
  else if (ValueType[1] in ['S', 's', 'T', 't']) then begin
    st2 := st;
      //регистр - на самом деле не нужно, так как контролл сам приводит к нужному регистру
    if Pos('U', s.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := s.ChangeCaseStr(st2, True);
    if Pos('L', s.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := s.ChangeCaseStr(st2, False);
    if Pos('T', s.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := Trim(st2);
    if Pos('P', s.ChangeCaseStr(ver[3], True)) > 0 then
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
  CorrectValue := st;
end;

(*
function TMyStringHelper.VerifyValue(const AValueType, AVerify, AValue: string; out ACorrectValue: Variant): Boolean;
//проверка значения строки, по правилам переданным в verify, с учетом типа данных, указанных в ValueType
//для строк возможна коррекция значений
var
  lParts: TStringDynArray;
  lMin, lMax: Extended;
  lDigits: Integer;
begin
  Result := True;
  ACorrectValue := AValue;
  lParts := A.ExplodeS(AVerify + '::::::', ':');
  if (AValueType[1] in ['I','i','F','f']) then
  begin
    lMin := StrToFloatDef(lParts[0], 0);
    lMax := StrToFloatDef(lParts[1], 0);
    lDigits := StrToIntDef(lParts[2], -1);
    Result := IsNumber(AValue, lMin, lMax, lDigits);
  end
  else if (AValueType[1] in ['D','d']) then
  begin
    Result := IsDateTime(AValue, 'dt');
    if Result then
    begin
      if lParts[2] = '-' then
        Result := True
      else
      begin
        if lParts[0] <> '*' then
          Result := Result and (StrToDateTime(AValue) >= StrToIntDef(lParts[0], 0));
        if lParts[1] <> '' then
          Result := Result and (StrToDateTime(AValue) <= StrToIntDef(lParts[1], 0));
      end;
    end;
  end
  else if (AValueType[1] in ['S','s','T','t']) then
  begin
    if lParts[0] <> '' then
      Result := Result and (Length(AValue) >= StrToIntDef(lParts[0], 0));
    if lParts[1] <> '' then
      Result := Result and (Length(AValue) <= StrToIntDef(lParts[1], 0));
    if Pos('T', UpperCase(lParts[3])) > 0 then
      ACorrectValue := Trim(AValue);
    if Pos('P', UpperCase(lParts[3])) > 0 then
      ACorrectValue := DeleteRepSpaces(ACorrectValue, ' ');
    if Pos('U', UpperCase(lParts[3])) > 0 then
      ACorrectValue := ToUpper(ACorrectValue);
    if Pos('L', UpperCase(lParts[3])) > 0 then
      ACorrectValue := ToLower(ACorrectValue);
    if Length(lParts) >= 6 then
      ACorrectValue := DeleteChars(ACorrectValue, lParts[5].ToCharArray, True);
  end;
end;
*)
function TMyStringHelper.VarType(const AValue: Variant): Integer;
//возвращает НЕКОТОРЫЕ сводные типы переменной Variant
//например любое целое иудет varInteger
begin
  Result := Variants.VarType(AValue) and VarTypeMask;
  if Result in [varSmallInt, varByte, varInteger, varWord, varInt64, 19] then
    Result := varInteger;
  if Result in [varSingle, varDouble, varCurrency] then
    Result := varDouble;
  if (Variants.VarType(AValue) and varString) = varString then
    Result := varString;
end;

function TMyStringHelper.VarIsClear(const AValue: Variant): Boolean;
//проверяет, задано ли значение переменной типа Variant
begin
  Result := not (VarIsEmpty(AValue) or VarIsNull(AValue));
end;

procedure TMyStringHelper.GetDatePeriod(const APeriod: Variant; const AStartDate: TDateTime; out ADateFrom, ADateTo: TDateTime);
//возвращает даты начала и конца периода по массиву DatePeriods (по номеру элемента или названию). если не найдено - возвращает сегодня
var
  p, y, m, q, d: Integer;
  dt: TDateTime;
begin
  ADateFrom := Date;
  ADateTo := Date;
  if VarType(APeriod) = varInteger then
    p := APeriod
  else begin
    for p := 1 to High(DatePeriods) do
      if SameText(APeriod, DatePeriods[p]) then
        Break;
  end;
  if (p <= 0) or (p > High(DatePeriods)) then
    Exit;
  case p of
    1:
      begin
        ADateFrom := AStartDate;
        ADateTo := AStartDate;
      end;
    2:
      begin
        ADateFrom := AStartDate - 1;
        ADateTo := AStartDate - 1;
      end;
    3:
      begin
        ADateFrom := AStartDate - (DayOfWeek(AStartDate) - 2);
        ADateTo := ADateFrom + 6;
      end;
    4:
      begin
        ADateFrom := AStartDate - (DayOfWeek(AStartDate) - 2) - 7;
        ADateTo := ADateFrom + 6;
      end;
    5:
      begin
        d := DayOf(AStartDate);
        if d < 16 then
          ADateFrom := EncodeDate(YearOf(AStartDate), MonthOf(AStartDate), 1)
        else
          ADateFrom := EncodeDate(YearOf(AStartDate), MonthOf(AStartDate), 16);
        ADateTo := EncodeDate(YearOf(AStartDate), MonthOf(AStartDate), DaysInMonth(AStartDate));
        if d >= 16 then
          ADateTo := EncodeDate(YearOf(AStartDate), MonthOf(AStartDate), 15);
      end;
    6:
      begin
        dt := IncMonth(AStartDate, -1);
        ADateFrom := EncodeDate(YearOf(dt), MonthOf(dt), 1);
        ADateTo := EncodeDate(YearOf(dt), MonthOf(dt), DaysInMonth(dt));
      end;
    7:
      begin
        ADateFrom := EncodeDate(YearOf(AStartDate), MonthOf(AStartDate), 1);
        ADateTo := EncodeDate(YearOf(AStartDate), MonthOf(AStartDate), DaysInMonth(AStartDate));
      end;
    8:
      begin
        dt := IncMonth(AStartDate, -1);
        ADateFrom := EncodeDate(YearOf(dt), MonthOf(dt), 1);
        ADateTo := EncodeDate(YearOf(dt), MonthOf(dt), DaysInMonth(dt));
      end;
    9:
      begin
        q := (MonthOf(AStartDate) - 1) div 3;
        m := q * 3 + 1;
        ADateFrom := EncodeDate(YearOf(AStartDate), m, 1);
        ADateTo := EncodeDate(YearOf(AStartDate), m + 2, DaysInMonth(AStartDate));
      end;
    10:
      begin
        q := (MonthOf(AStartDate) - 1) div 3;
        m := q * 3 + 1;
        ADateFrom := EncodeDate(YearOf(AStartDate) - 1, m, 1);
        ADateTo := EncodeDate(YearOf(AStartDate) - 1, m + 2, DaysInMonth(AStartDate));
      end;
    11:
      begin
        ADateFrom := EncodeDate(YearOf(AStartDate), 1, 1);
        ADateTo := EncodeDate(YearOf(AStartDate), 12, 31);
      end;
    12:
      begin
        ADateFrom := EncodeDate(YearOf(AStartDate) - 1, 1, 1);
        ADateTo := EncodeDate(YearOf(AStartDate) - 1, 12, 31);
      end;
  end;
end;

procedure TMyStringHelper.GetDatesFromPeriodString(const AStr: string; out ADateFrom, ADateTo: TDateTime);
begin
  var va := a.Explode(AStr, ' - ');
  ADateFrom := StrToDateDef(va[0], BadDate);
  ADateTo := StrToDateDef(va[1], BadDate);
end;
//==============================================================================
//Методы записи A (массивы)
//==============================================================================

procedure TMyArrayHelper.QuickSortVD1(var AArray: TVarDynArray; L, R: Integer; Asc: Boolean);
var
  i, j: Integer;
  lPivot, lTemp: Variant;
begin
  if L < R then begin
    i := L;
    j := R;
    lPivot := AArray[(L + R) div 2];
    repeat
      while (Asc and (AArray[i] < lPivot)) or (not Asc and (AArray[i] > lPivot)) do
        Inc(i);
      while (Asc and (AArray[j] > lPivot)) or (not Asc and (AArray[j] < lPivot)) do
        Dec(j);
      if i <= j then begin
        lTemp := AArray[i];
        AArray[i] := AArray[j];
        AArray[j] := lTemp;
        Inc(i);
        Dec(j);
      end;
    until i > j;
    if L < j then
      QuickSortVD1(AArray, L, j, Asc);
    if i < R then
      QuickSortVD1(AArray, i, R, Asc);
  end;
end;

function TMyArrayHelper.Explode(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean): TVarDynArray;
//разбивает исходную строку на подстроки, используя как разделитель строку DivSt
//исходная строка может быть и массивом, тогда будет возвращен этот массив
//если не установлено IgnoreEmpty, то элементы могут быть пустыми, и пустая строка станет массивом [''].
//вернет одномерный вариантный массив
//+++ переработана для поддержки IgnoreEmpty
var
  s, lPart: string;
  i, j: Integer;
begin
  if VarIsArray(AValue) then begin
    Result := AValue;
    Exit;
  end;
  s := VarToStr(AValue);
  SetLength(Result, 0);
  i := 1;
  while i <= Length(s) do begin
    j := PosEx(ADelimiter, s, i);
    if j = 0 then
      j := Length(s) + 1;
    lPart := Copy(s, i, j - i);
    if (not AIgnoreEmpty) or (lPart <> '') then begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := lPart;
    end;
    i := j + Length(ADelimiter);
  end;
end;

function TMyArrayHelper.ExplodeV(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean): TVarDynArray;
//просто алиас Explode
begin
  Result := Explode(AValue, ADelimiter, AIgnoreEmpty);
end;

function TMyArrayHelper.ExplodeS(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean): TStringDynArray;
//тоже самое, но возвращает TStringDynArray
var
  va: TVarDynArray;
  i: Integer;
begin
  va := Explode(AValue, ADelimiter, AIgnoreEmpty);
  SetLength(Result, Length(va));
  for i := 0 to High(va) do
    Result[i] := VarToStr(va[i]);
end;

procedure TMyArrayHelper.ExplodeP(const AValue: Variant; const ADelimiter: string; var AArray: TVarDynArray);
begin
  AArray := Explode(AValue, ADelimiter, False);
end;

procedure TMyArrayHelper.ExplodeP(const AValue: Variant; const ADelimiter: string; var AArray: TStringDynArray);
begin
  AArray := ExplodeS(AValue, ADelimiter, False);
end;

procedure TMyArrayHelper.ExplodeP(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean; var AArray: TVarDynArray);
begin
  AArray := Explode(AValue, ADelimiter, AIgnoreEmpty);
end;

procedure TMyArrayHelper.ExplodeP(const AValue: Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean; var AArray: TStringDynArray);
begin
  AArray := ExplodeS(AValue, ADelimiter, AIgnoreEmpty);
end;

function TMyArrayHelper.Implode(const AArray: array of Variant; const ADelimiter: string; const AIgnoreEmpty: Boolean): string;
//сливаем одномерный вариантный массив в строку через разделитель;
//если IgnoreEmpty установлен, то игнорируем пустые значения массива
//+++ переработана с TStringBuilder
var
  sb: TStringBuilder;
  i: Integer;
  s: string;
begin
  sb := TStringBuilder.Create;
  try
    for i := 0 to High(AArray) do begin
      s := VarToStr(AArray[i]);
      if AIgnoreEmpty and (s = '') then
        Continue;
      if sb.Length > 0 then
        sb.Append(ADelimiter);
      sb.Append(s);
    end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TMyArrayHelper.Implode(const AArray: TStringDynArray; const ADelimiter: string; const AIgnoreEmpty: Boolean): string;
//сливаем одномерный строковый массив в строку через разделитель;
//если IgnoreEmpty установлен, то игнорируем пустые значения массива
//+++ переработана с TStringBuilder
var
  sb: TStringBuilder;
  i: Integer;
begin
  sb := TStringBuilder.Create;
  try
    for i := 0 to High(AArray) do begin
      if AIgnoreEmpty and (AArray[i] = '') then
        Continue;
      if sb.Length > 0 then
        sb.Append(ADelimiter);
      sb.Append(AArray[i]);
    end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TMyArrayHelper.Implode(const AArray: TVarDynArray2; const AColumn: Integer; const ADelimiter: string; const AIgnoreEmpty: Boolean): string;
//сливаем в строку переданную колонку двумерного массива
//+++ переработана с TStringBuilder
var
  sb: TStringBuilder;
  i: Integer;
  s: string;
begin
  sb := TStringBuilder.Create;
  try
    for i := 0 to High(AArray) do begin
      if (AColumn < 0) or (AColumn > High(AArray[i])) then
        Continue;
      s := VarToStr(AArray[i][AColumn]);
      if AIgnoreEmpty and (s = '') then
        Continue;
      if sb.Length > 0 then
        sb.Append(ADelimiter);
      sb.Append(s);
    end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TMyArrayHelper.Implode(const AArray: TVarDynArray2; const AColumns: TByteSet; const ADelimiter1, ADelimiter2: string; const AIgnoreEmpty: Boolean): string;
//сливаем в строку весь двухмерный массив по указанным колонкам, разделители для первого и второго уровня разные
//+++ переработана с TStringBuilder
var
  sb, rowSb: TStringBuilder;
  i, j: Integer;
  s: string;
begin
  sb := TStringBuilder.Create;
  try
    for i := 0 to High(AArray) do begin
      rowSb := TStringBuilder.Create;
      try
        for j := 0 to High(AArray[i]) do
          if (AColumns = []) or (j in AColumns) then begin
            s := VarToStr(AArray[i][j]);
            if AIgnoreEmpty and (s = '') then
              Continue;
            if rowSb.Length > 0 then
              rowSb.Append(ADelimiter1);
            rowSb.Append(s);
          end;
        if rowSb.Length > 0 then begin
          if sb.Length > 0 then
            sb.Append(ADelimiter2);
          sb.Append(rowSb.ToString);
        end;
      finally
        rowSb.Free;
      end;
    end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TMyArrayHelper.ImplodeNotEmpty(const AArray: array of Variant; const ADelimiter: string): string;
//сливаем одномерный вариантный массив в строку через разделитель;
//пустые элементы всегда игнорируем
begin
  Result := Implode(AArray, ADelimiter, True);
end;

function TMyArrayHelper.ImplodeStringList(var AList: TStringList; const ADelimiter: string): string;
//склеивает текст из TStrings, при этом игнорирует пустые строки с конца списка
//+++ переработана с TStringBuilder
var
  i: Integer;
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    for i := 0 to AList.Count - 1 do begin
      if i > 0 then
        sb.Append(ADelimiter);
      sb.Append(AList[i]);
    end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TMyArrayHelper.PosInArray(const AValue: Variant; const AArray: array of Variant; const AIgnoreCase: Boolean): Integer;
//находит позицию V в одномерном массиве Arr типа Variant; может не различать регистр; Если не найдена,
//возвращает -1 (или если массив начинается с меньшей нуля индекса, то Low(Arr) - 1
var
  i: Integer;
begin
  Result := -1;
  for i := Low(AArray) to High(AArray) do begin
    if AIgnoreCase and (VarType(AValue) = varString) and (VarType(AArray[i]) = varString) then begin
      if SameText(VarToStr(AValue), VarToStr(AArray[i])) then
        Exit(i);
    end
    else if VarCompareValue(AValue, AArray[i]) = vrEqual then
      Exit(i);
  end;
end;

function TMyArrayHelper.PosInArray(const AValue: string; const AArray: TStringDynArray; const AIgnoreCase: Boolean): Integer;
//находит позицию V в одномерном массиве Arr типа строк; может не различать регистр
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(AArray) do begin
    if AIgnoreCase and SameText(AValue, AArray[i]) then
      Exit(i);
    if not AIgnoreCase and (AValue = AArray[i]) then
      Exit(i);
  end;
end;

function TMyArrayHelper.PosInArray(const AValue: Variant; const AArray: TVarDynArray; const AIgnoreCase: Boolean): Integer;
//находит позицию V в одномерном массиве Arr типа Variant; может не различать регистр
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(AArray) do begin
    if AIgnoreCase and (VarType(AValue) = varString) and (VarType(AArray[i]) = varString) then begin
      if SameText(VarToStr(AValue), VarToStr(AArray[i])) then
        Exit(i);
    end
    else if VarCompareValue(AValue, AArray[i]) = vrEqual then
      Exit(i);
  end;
end;

function TMyArrayHelper.PosInArray(const AValue: Variant; const AArray: TVarDynArray2; const AColumn: Integer; const AIgnoreCase: Boolean): Integer;
//находит позицию первого уровня для двумерного массива, в которой в поле FNo находится значение V
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(AArray) do begin
    if (AColumn < 0) or (AColumn > High(AArray[i])) then
      Continue;
    if AIgnoreCase and (VarType(AValue) = varString) and (VarType(AArray[i][AColumn]) = varString) then begin
      if SameText(VarToStr(AValue), VarToStr(AArray[i][AColumn])) then
        Exit(i);
    end
    else if VarCompareValue(AValue, AArray[i][AColumn]) = vrEqual then
      Exit(i);
  end;
end;

function TMyArrayHelper.PosInArray(const AValues: TVarDynArray; const AArray: TVarDynArray2; const AColumns: TVarDynArray; const AIgnoreCase: Boolean): Integer;
//найдет позицию в массиве, для которой совпадаю все переданные значения в переданных столбцах
var
  i, j: Integer;
  ok: Boolean;
begin
  Result := -1;
  for i := 0 to High(AArray) do begin
    ok := True;
    for j := 0 to High(AColumns) do begin
      if (AColumns[j] < 0) or (AColumns[j] > High(AArray[i])) then begin
        ok := False;
        Break;
      end;
      if AIgnoreCase and (VarType(AValues[j]) = varString) and (VarType(AArray[i][AColumns[j].AsInteger]) = varString) then begin
        if not SameText(VarToStr(AValues[j]), VarToStr(AArray[i][AColumns[j].AsInteger])) then begin
          ok := False;
          Break;
        end;
      end
      else if VarCompareValue(AValues[j], AArray[i][AColumns[j].AsInteger]) <> vrEqual then begin
        ok := False;
        Break;
      end;
    end;
    if ok then
      Exit(i);
  end;
end;

function TMyArrayHelper.PosRowInArray(const ANeedle, ASource: TVarDynArray2; const ARow: Integer): Integer;
//найдет позицию в массиве Source, при которой все поля совпадаются со строкой массива Needle
var
  i, j: Integer;
  ok: Boolean;
begin
  Result := -1;
  if (ARow < 0) or (ARow > High(ANeedle)) then
    Exit;
  for i := 0 to High(ASource) do begin
    if High(ASource[i]) <> High(ANeedle[ARow]) then
      Continue;
    ok := True;
    for j := 0 to High(ASource[i]) do begin
      if VarCompareValue(ASource[i][j], ANeedle[ARow][j]) <> vrEqual then begin
        ok := False;
        Break;
      end;
    end;
    if ok then
      Exit(i);
  end;
end;

function TMyArrayHelper.InArray(const AValue: Variant; const AArray: array of Variant): Boolean;
//вернет истину, если строка присутствует в массиве
begin
  Result := PosInArray(AValue, AArray) >= 0;
end;

function TMyArrayHelper.FindValueInArray2(const AKeyValue: Variant; const AKeyColumn, AResultColumn: Integer; const AArray: TVarDynArray2; const AIgnoreCase: Boolean): Variant;
//возвращает значение из столбца ValueFNo, для которого значения в столбце KeyFNo = KeyValue
var
  i: Integer;
begin
  Result := Null;
  i := PosInArray(AKeyValue, AArray, AKeyColumn, AIgnoreCase);
  if i >= 0 then
    Result := AArray[i][AResultColumn];
end;

function TMyArrayHelper.ReplaceInArray(const AFindValue, ANewValue: Variant; var AArray: TVarDynArray; const AIgnoreCase: Boolean): Boolean;
//заменяем найденное поле в массиве в строке новым значением; возвращает, была ли замена
var
  i: Integer;
begin
  i := PosInArray(AFindValue, AArray, AIgnoreCase);
  if i >= 0 then begin
    AArray[i] := ANewValue;
    Result := True;
  end
  else
    Result := False;
end;

function TMyArrayHelper.ReplaceInArray(const AFindValue, ANewValue: Variant; var AArray: TVarDynArray2; const AFindColumn, AReplaceColumn: Integer; const AIgnoreCase: Boolean): Boolean;
//заменяем поле в массиве в строке, найденной по значению какого-либо (другого или того же) поля, была ли замена
var
  i: Integer;
begin
  i := PosInArray(AFindValue, AArray, AFindColumn, AIgnoreCase);
  if i >= 0 then begin
    AArray[i][AReplaceColumn] := ANewValue;
    Result := True;
  end
  else
    Result := False;
end;

function TMyArrayHelper.VarDynArray2ColToVD1(const AArray: TVarDynArray2; const AColumn: Integer): TVarDynArray;
//возвращает столбец двухмерного массива Column в одномерном массиве
var
  i: Integer;
begin
  SetLength(Result, Length(AArray));
  for i := 0 to High(AArray) do
    if (AColumn >= 0) and (AColumn <= High(AArray[i])) then
      Result[i] := AArray[i][AColumn];
end;

function TMyArrayHelper.VarDynArray2RowToVD1(const AArray: TVarDynArray2; const ARow: Integer): TVarDynArray;
//возвращает строку двухмерного массива Row в одномерном массиве
begin
  if (ARow >= 0) and (ARow <= High(AArray)) then
    Result := Copy(AArray[ARow], 0, Length(AArray[ARow]))
  else
    Result := nil;
end;

procedure TMyArrayHelper.VarDynArray2InsertArr(var ATarget: TVarDynArray2; const ASource: TVarDynArray; const APosition: Integer; const AInsert: Boolean);
//модифицирует двумерный массив вставкой или заменой его элемента первого уровня массивом TVarDynArray
//при параметрах по умолчанию просто добавит массив TVarDynArray в конец массива TVarDynArray2
var
  i, j, idx: Integer;
begin
  if APosition = -1 then begin
    SetLength(ATarget, Length(ATarget) + 1);
    idx := High(ATarget);
  end
  else if AInsert then begin
    SetLength(ATarget, Length(ATarget) + 1);
    for i := High(ATarget) downto APosition + 1 do
      ATarget[i] := ATarget[i - 1];
    idx := APosition;
  end
  else
    idx := APosition;
  SetLength(ATarget[idx], Length(ASource));
  for j := 0 to High(ASource) do
    ATarget[idx][j] := ASource[j];
end;

procedure TMyArrayHelper.VarDynArraySort(var AArray: TVarDynArray; const AAscending: Boolean);
//сортировка одномерного вариантного массива (пузырьковая)
var
  i, j: Integer;
  tmp: Variant;
begin
  for i := 0 to High(AArray) - 1 do
    for j := i + 1 to High(AArray) do begin
      if AAscending and (AArray[i] > AArray[j]) then begin
        tmp := AArray[i];
        AArray[i] := AArray[j];
        AArray[j] := tmp;
      end
      else if not AAscending and (AArray[i] < AArray[j]) then begin
        tmp := AArray[i];
        AArray[i] := AArray[j];
        AArray[j] := tmp;
      end;
    end;
end;

procedure TMyArrayHelper.SortVD1(var AArray: TVarDynArray; const AAscending: Boolean);
//быстрая сортировка одномерного массива
begin
  if Length(AArray) > 1 then
    QuickSortVD1(AArray, 0, High(AArray), AAscending);
end;

procedure TMyArrayHelper.VarDynArraySort(var AArray: TVarDynArray2; const AColumn: Integer; const AAscending: Boolean);
//сортировка двухмерного вариантгного массива по переданному полю (пузырьковая)
var
  i, j: Integer;
  tmp: TVarDynArray;
begin
  for i := 0 to High(AArray) - 1 do
    for j := i + 1 to High(AArray) do begin
      if (AColumn < 0) or (AColumn > High(AArray[i])) or (AColumn > High(AArray[j])) then
        Continue;
      if AAscending and (AArray[i][AColumn] > AArray[j][AColumn]) then begin
        tmp := AArray[i];
        AArray[i] := AArray[j];
        AArray[j] := tmp;
      end
      else if not AAscending and (AArray[i][AColumn] < AArray[j][AColumn]) then begin
        tmp := AArray[i];
        AArray[i] := AArray[j];
        AArray[j] := tmp;
      end;
    end;
end;

procedure TMyArrayHelper.VarDynArray2Sort(var AArray: TVarDynArray2; const AKey: Integer);
//сортировка двухмерного вариантгного массива по переданному полю
//поле передается на 1 больше чем в массиве, если с + то по возрастанию, а с - то по убыванию
var
  lAsc: Boolean;
  lCol: Integer;
begin
  lAsc := AKey > 0;
  lCol := Abs(AKey) - 1;
  VarDynArraySort(AArray, lCol, lAsc);
end;

function TMyArrayHelper.ArrCompare(const AArray1, AArray2: array of Variant; const AOperation: TArrayOperation): TVarDynArray;
//возвращает одномерный массив, являющийся пересечением, объединением или различием двух массивов
var
  i: Integer;
begin
  Result := [];
  case AOperation of
    aoIntersection:
      for i := 0 to High(AArray1) do
        if InArray(AArray1[i], AArray2) then
          Result := Result + [AArray1[i]];
    aoUnion:
      begin
        for i := 0 to High(AArray1) do
          if not InArray(AArray1[i], Result) then
            Result := Result + [AArray1[i]];
        for i := 0 to High(AArray2) do
          if not InArray(AArray2[i], Result) then
            Result := Result + [AArray2[i]];
      end;
    aoDifference:
      begin
        for i := 0 to High(AArray1) do
          if not InArray(AArray1[i], AArray2) then
            Result := Result + [AArray1[i]];
        for i := 0 to High(AArray2) do
          if not InArray(AArray2[i], AArray1) then
            Result := Result + [AArray2[i]];
      end;
  end;
end;

function TMyArrayHelper.VarIntToArray(const AValue: Variant): TVarDynArray;
//передается или целое число, или вариантный массив, или строка чисел через запятую,
//возвращается массив
begin
  if VarIsArray(AValue) then
    Result := AValue
  else if VarIsOrdinal(AValue) or (VarType(AValue) = varDouble) or (VarType(AValue) = varSingle) then
    Result := [AValue]
  else
    Result := Explode(AValue, ',', True);
end;

function TMyArrayHelper.StringDynArrayToVarDynArray(const AStringArray: TStringDynArray): TVarDynArray;
//получает массив строк, возвращает вариантный массив
var
  i: Integer;
begin
  SetLength(Result, Length(AStringArray));
  for i := 0 to High(AStringArray) do
    Result[i] := AStringArray[i];
end;

function TMyArrayHelper.RemoveDuplicates(const AValues: TVarDynArray): TVarDynArray;
//удаляем дублирующиеся знаения из массива
var
  i, j: Integer;
  found: Boolean;
begin
  Result := [];
  for i := 0 to High(AValues) do begin
    found := False;
    for j := 0 to High(Result) do
      if VarCompareValue(AValues[i], Result[j]) = vrEqual then begin
        found := True;
        Break;
      end;
    if not found then
      Result := Result + [AValues[i]];
  end;
end;

function TMyArrayHelper.IsArraysEqual(const A, B: TVarDynArray2; const ARow: Integer): Boolean;
//сравнение двух двумерных массивов (или одной их строки)
//будут одинаковы, если совпадают размерности массивов и все их значения
var
  i, j, r: Integer;
begin
  if ARow = -1 then begin
    if Length(A) <> Length(B) then
      Exit(False);
    for i := 0 to High(A) do begin
      if Length(A[i]) <> Length(B[i]) then
        Exit(False);
      for j := 0 to High(A[i]) do
        if VarCompareValue(A[i][j], B[i][j]) <> vrEqual then
          Exit(False);
    end;
    Result := True;
  end
  else begin
    r := ARow;
    if (r < 0) or (r > High(A)) or (r > High(B)) then
      Exit(False);
    if Length(A[r]) <> Length(B[r]) then
      Exit(False);
    for j := 0 to High(A[r]) do
      if VarCompareValue(A[r][j], B[r][j]) <> vrEqual then
        Exit(False);
    Result := True;
  end;
end;

procedure TMyArrayHelper.SetNull(var AArray: TVarDynArray);
var
  i: Integer;
begin
  for i := 0 to High(AArray) do
    AArray[i] := Null;
end;

procedure TMyArrayHelper.SetNull(var AArray: TVarDynArray2; const ARow: Integer);
var
  i, j: Integer;
begin
  if ARow = -1 then begin
    for i := 0 to High(AArray) do
      for j := 0 to High(AArray[i]) do
        AArray[i][j] := Null;
  end
  else if (ARow >= 0) and (ARow <= High(AArray)) then
    for j := 0 to High(AArray[ARow]) do
      AArray[ARow][j] := Null;
end;

procedure TMyArrayHelper.IncLength(var AArray: TVarDynArray);
begin
  SetLength(AArray, Length(AArray) + 1);
end;

procedure TMyArrayHelper.IncLength(var AArray: TVarDynArray2);
begin
  SetLength(AArray, Length(AArray) + 1);
  if Length(AArray) > 0 then
    SetLength(AArray[High(AArray)], 0);
end;
//==============================================================================
//Внешние функции для совместимости с EhLib
//==============================================================================

function CharInSetEh(C: Char; const CharSet: TSysCharSet): Boolean;
begin
  Result := CharInSet(C, CharSet);
end;

function WordPosition(const N: Integer; const S: string; WordDelims: TCharSet): Integer;
var
  lCount, i: Integer;
begin
  lCount := 0;
  i := 1;
  Result := 0;
  while (i <= Length(S)) and (lCount <> N) do begin
    while (i <= Length(S)) and CharInSet(S[i], WordDelims) do
      Inc(i);
    if i <= Length(S) then
      Inc(lCount);
    if lCount <> N then
      while (i <= Length(S)) and not CharInSet(S[i], WordDelims) do
        Inc(i)
    else
      Result := i;
  end;
end;

function ExtractWordPos(N: Integer; const S: string; WordDelims: TCharSet; var Pos: Integer): string;
var
  i, j: Integer;
begin
  Result := '';
  i := WordPosition(N, S, WordDelims);
  Pos := i;
  if i = 0 then
    Exit;
  j := i;
  while (j <= Length(S)) and not CharInSet(S[j], WordDelims) do
    Inc(j);
  Result := Copy(S, i, j - i);
end;

function ExtractWord(N: Integer; const S: string; WordDelims: TCharSet): string;
var
  p: Integer;
begin
  Result := ExtractWordPos(N, S, WordDelims, p);
end;
//==============================================================================
//Глобальная функция BadDate
//==============================================================================

function BadDate: TDateTime;
begin
  Result := EncodeDate(1900, 12, 30);
end;
//==============================================================================
//TVariantHelper методы
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
    varByte, varSmallint, varInteger, varShortInt, varWord, varLongWord, varInt64, varSingle, varDouble, varCurrency:
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
  Result := s.NInt(Self);
end;

function TVariantHelper.AsIntegerM: Integer;
begin
  Result := s.NIntM(Self);
end;

function TVariantHelper.AsFloat: Extended;
begin
  Result := s.NNum(Self);
end;

function TVariantHelper.AsBoolean: Boolean;
begin
  if IsNull or IsEmpty then
    Result := False
  else
    Result := Self;
end;

function TVariantHelper.AsDateTime: TDateTime;
begin
  Result := Self;
end;

function TVariantHelper.NullIf0: Variant;
begin
  Result := s.NullIf0(Self);
end;

function TVariantHelper.NullIfEmpty: Variant;
begin
  Result := s.NullIfEmpty(Self);
end;


//Для избежания предупреждений о неиспользуемых переменных в модуле
initialization
finalization

end.
