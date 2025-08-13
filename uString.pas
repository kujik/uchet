unit uString;

//{$mode objfpc}

//��� string = ansistring $H+

interface

uses
  Graphics, Classes, StrUtils, DateUtils, Variants, Types, IOUtils, SysUtils;

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
    function Col(Field: string): Integer;
    function G(RowNo: Integer; Field: string): Variant; overload;
    function G(Field: string): Variant; overload;
    procedure SetValue(RowNo: Integer; Field: string; NewValue: Variant);
    function Empty: Boolean;
    function Count: Integer;
    function FieldsCount: Integer;
    procedure Clear;
  end;


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
  DaysOfWeek2: array[1..7] of string = ('��', '��', '��', '��', '��', '��', '��');
  MonthsRu: array[1..12] of string = ('������', '�������', '����', '������', '���', '����', '����', '������', '��������', '�������', '������', '�������');
  DigitsChars: set of Char = ['0'..'9'];
  DigitsChars_: set of Char = ['0'..'9', '.', ',', '+', '-'];
  DivSymbols =[' ', ',', '.', ':', ';', '?', '!', '"', '=', '-', '_', '(', ')', '%', '/', '\', '*'];
  DatePeriods: array[0..11] of string = ('�������', '�����', '��� ������', '������� ������', '��� �������� ������', '������� �������� ������', '���� �����', '������� �����', '���� �������', '������� �������','���� ���', '������� ���');

type
  TMyStringHelper = record

//----------- ������� �������� � ����������� ��������

//������ ���������� ������� �����, ������ ��� � ����� ������ ������;
//���� �� ������� ������ ��������, �� ������� ������ � ���������
    function TrimSt(const St: string; TrimCh: TCharDynArray = []; Mode: TMyStringLocation = stlBoth): string;
//���������. ������ ���������� ������� �����, ������ ��� � ����� ������ ������;
//���� �� ������� ������ ��������, �� ������� ������ � ���������
    procedure TrimStP(var St: string; TrimCh: TCharDynArray = []; Mode: TMyStringLocation = stlBoth);
//������ ������� � ����� ����� ������
    procedure DelLeft(var st: string; TrimCh: TCharDynArray = []);
//������ ������� � ������ ����� ������
    procedure DelRight(var st: string; TrimCh: TCharDynArray = []);
//�������� ����������� ������� �������� � ����� ������ ������
    procedure DelBoth(var st: string; TrimCh: TCharDynArray = []);

//----------- ������ �������� � ������

//���� � ������ ���� ��������� �������� ������, �� �������� �� � ������ �������
//mode=True  �������� � ������ ��� ������� �� [ch] �� ������ chnew[i]
//mode=False �������� � ������ ��� ������� �� not[ch] �� ������ chnew[i]
//���� ChNew = [], �� ������� ������� ����������,
//���� ChNew ����� ������ ���� �������, �� ��� ���� ������� ����������� ��,
//�����, ���� ����� �������� � �������� �����������, ������������ ������
    function ReplaceChars(St: string; Chars: TCharDynArray; ChNew: TCharDynArray; Mode: Boolean): string;
//���� � ������ ���� ��������� �������� ������, �� �������� �� � ������ �������
    function DeleteRepSpaces(St: string; Ch: Char = ' '): string;
//������� ��� ������� Ch �� ������
    function DeleteChar(St: string; Ch: char): string;
//mode=True  ������� � ������ ��� ������� �� [ch]
//mode=False ������� � ������ ��� ������� �� not[ch]
    function DeleteChars(St: string; Chars: TCharDynArray; Mode: Boolean): string;
//mode=True  �������� � ������ ��� ������� �� [ch] �� ������ chnew
//mode=False �������� � ������ ��� ������� �� not[ch] �� ������ chnew
    function ChangeChars(st: string; ch: tcharset; chnew: char; mode: Boolean): string;
//���������� ����� �������� Fill
    function FillString(Length: Integer; Chr: Char): string;
//���� � ������ ���� ������ ������������������ �������� (���������), �� ��������� ������ ������ �� ���
//�� ��������!!! �������� ��� ������ ������������������ ���� ("1212����12", "12"), �� �� �� ������������� �������� (�� ������ ���� ������������������ "00"!!!
function DeleteRepSubstr(St: string; SubSt: string): string;

//---------������������ ������ �� ���� ��������� �������� ��� ������ ��������
{
 Writeln('123'.PadLeft(5));  //'  123'
 Writeln('12345'.PadLeft(5));  //'12345'
 Writeln('������ '.PadRight(20, '-') + ' ���. 7'); //'������ ------------- ���. 7'
}

//��������� ������ ���������� �������� (�� ��������� ������) �����, �� ���������� �����
    function PadLeft(St: string; Len: Integer; Ch: Char = ' '): string;
//��������� ������ ���������� �������� (�� ��������� ������) ������, �� ���������� �����
    function PadRight(St: string; Len: Integer; Ch: Char = ' '): string;

//---------�������� ������������ ���� ������ (������ �����, ����...)

//���������, �������� �� ������ ����� ������.
    function IsInt(St: string): Boolean;
//���������, �������� �� ������ ������ � ��������� ������
    function IsFloat(St: string): Boolean;
//���������, �������� �� ������ ������ � �������� ��������� � �������� ������ ���������� ������
//���� ����� ���������� ������ �� �����, �������� -1, ���� ����� ������ �����, �������� 0
    function IsNumber(St: string; MinI, MaxI: Extended; FDigits: Integer = -1): Boolean;
//�������� ������ �� �� ��� �������� ����/�����
//DtType = dt - ������ ���� ����� ��� ����� �� ��������, DT - ����������� ���� � �����, d,D -������ ����, t - ������ �����
//�������������� ��� ����������� ���� � ������� - ������ (����������� ������ ��� ���), � ����� � ����� - ":"
    function IsDateTime(St: string; DtType: string = 'dt'): Boolean;
//���� ������ ���� ����� (����� �������������) ����� ��� ������
//���� ������ ������ ���� ����� ����� ������ ���� ����� �� ������ -
    function IsNumberLeftPart(St: string): Integer;
//������������������� ��������� ������ �� ���������� ��������� (����� ������ ��������������� ���������)
    function IsValidEmail(const Value: string): Boolean;

//---------������� ������ � ������� ����

//���������, �������� �� ������ ������ � �������� ��������� � �������� ����������� ����� ����� ������� (�� �����)
//� �������� ������������ ��������� ����� � �������
//���������� ����� � Res: extended, � Result - ������ ��� ���� /���� �� ������� ������������� � �����/
    function StrToNumberCommaDot(V: Variant; MinI, MaxI: Extended; var Res: Extended; FDigits: Integer = -1): Boolean;
//����������� ��� Variant � Integer; ��� ������� ���������� �������� Def
    function VarToInt(v: Variant; Def: Integer = -1): Integer;
//����������� ��� Variant � Extended; ��� ������� ���������� �������� Def
    function VarToFloat(v: Variant; Def: extended = -1): extended;
//��������������� ����� � ������ ������ �� ����� Len, ������� ����� ������ ��������� �������� Ch
    function NumToString(Number: Extended; Len: byte; Ch: Char): string;
//����������� ������ �� ���� ��� ���� �����, ����������� ��������� (��������, �������), � TDateTime
//���� ������� ���������� BadDate
//������������ ������ ��� ����� ������� ��� ��� ���� ���������� ������� ��� ��� � ����� ����� ���������� ����������
    function SpacedStToDate(St: string; FullDateTime: Boolean = False): TDateTime;
//����������� TDateTime � ����� (Double) � ���������� �  ���� ������
//��������� �������
    function DateTimeToIntStr(dt: TDateTime): string;

//--------- ��������� �������� ���� Null, ���������� � ��������� Varint

//���������� ������ ������, ���� �������� Empty ��� Null
    function NSt(St: Variant): string;
//���������� 0 � ����� extended, ���� �������� Empty ��� Null
//    function NNum(St: Variant): extended;
    function NNum(St: Variant; Default: Extended = 0): Extended;
//���������� 0 � ����� Integer, ���� �������� Empty ��� Null
    function NInt(St: Variant): Integer;
//���������� ���� ���� v=null or VarToString(v) ='', ����� ������ ���������� ��������
    function NullIfEmpty(v: Variant): Variant;
//���������� ���� ���� v=0 (0.00), ����� ������ ���������� ��������
    function NullIf0(v: Variant): Variant;

//--------- ��������� �������� ������
{
Writeln(LowerCase('����� - AbCdE')); //� ������ ������� �������� ������ ��������� �����. ��������� ����� '����� - abcde'.
Writeln('����� - AbCdE'.ToLower); //� ������ ������� �������� � ������� � ��������� �����. ��������� ����� '����� - abcde'.
}
//�������� ������� ������ (� ��������� � ������� �����
    function ChangeCaseStr(St: string; ToUpper: Boolean): string;
//�������� ������� ������� (� ��������� � ������� �����
    function ChangeCaseCh(Ch: Char; ToUpper: Boolean): string;
//������ � ������� �������
    function ToUpper(St: string): string;
//������ � ������ �������
    function ToLower(St: string): string;

//�������� Cnt ������ �������� ������
    function Right(St: string; Cnt: Integer = 1): string;


//---------- ����� ���������, ���������� ������� ��������� � ������.

//������� ������� ��������� � ������ ��� ����� ��������
    function PosI(StPart, StFull: string): Integer;
//���������, ���������� �� ��������� � ������ ��������, ����������� ��������
    function InCommaStr(stpart, stall: string; ch: Char = ','; IgnoreCase: Boolean = False): Boolean;
//���������, ���������� �� ��������� � ������ ��������, ����������� ��������, ��� ����� ��������
    function InCommaStrI(stpart, stall: string; ch: Char = ','): Boolean;
//������������ ���������� �������� �� ����������� ������ � ������, ������� � ������� �1 � �� �2 (���� -1 �� �� ����� ������)
    function GetCharCountInStr(St: string; Chars: TCharSet; p1: Integer = 1; p2: Integer = -1): Integer;
//���� ������� ������� ����� � ������, ���������� ��������� ������� ������,
//������� ���� ����� ���� �� ����������� ������ �� DivSymbols
    function FindBegWord(Start: Integer; St: string; DivSymbols: TCharSet = [' ']): Integer;
//���� ������� ����� ����� � ������, ���������� ��������� ������� ������,
//������� ���� ������ ���� �� ����������� ������ �� DivSymbols
    function FindEndWord(Start: byte; st: string; DivSymbols: TCharSet = [' ']): Integer;
//��������� ������ St �� 3 �����: St1 -�� �������, St2 - � ��������, St3 - �����
//������� ����������� ��� ������� ��� � ���������
//�������� �� �������
    procedure DivisionQuotetStr(st, st1, st2, st3: string);
//�������� ��������� ����� NumSubSt �� ������, ������� ��������� �� ��������� ������������ DivSt
//���������� ����� ������� ��������� ��������� � ������
//���� �� ���� �������� ���������, �� ���������� -2 � ''
    function GetSubSt(SourceSt: string; NumSubSt: Integer; DivSt: string; var PosSt: Integer): string;
//����� �� �����:  �p������� ��p��� St � �������� Mask. � ������� �����
//y���p������ ����� '?'(����� ����) � '*' (����� ���������� ����� ������)
    function FindMaskInStr(var Mask, St: string): Boolean;
//����� �� �����:  �p������� ��p��� St � �������� Mask. � ������� �����
//y���p������ ����� '?'(����� ����) � '*' (����� ���������� ����� ������)}
    function FindADDMaskInStr(Mask, St: string): Boolean;

//---------- ����������� �������������� ������ (����� � ���� �������� � �.�.

//�������������� ����� � ������ ��������
    function NumToWords(Num: longint; Mode: char): string;
//�������������� ����� � ������ ���� ��������
    function NumToPriceWords(Num: longInt; Mode: Boolean): string;
//����������� ����� � ����� � ������ � �������� � ���� ����� � �� ����
//�������� ��� �����������, ���� � ����� �����, 2 ��������� ��� �������
    function NumToPriceStr(Num: longint): string;
//��������� ������� ��� ������ ���� � ���������� ���� ������ � ������
    function PriceWord(Num: longint; Mode: Char): string;
//�������������� ����� � ������ �������� � �������������
    function NumToPhoneStr(Num: longint): string;
//�������������� ������ ��� ������ �������� � �������������
    function StrToPhoneStr(StT: string): string;
//�������� ��������� �� ����������
//(���������� ��������� ��� ���-�� 1, 2{3,4}, 5(6,7,8,9,10)
    function GetEnding(Num: longint; St1, St2, St3: string): string;
//(���������� ����������, �������� ����� �����, ��������� ��� ���-�� 1, 2{3,4}, 5(6,7,8,9,10)
    function GetEndingFull(Num: longint; Main, St1, St2, St3: string): string;
//�������� ��������� �� ���������� (������� ��/���� �����)
    function GetEndingOneOrMany(Num: longint; St1, St2: string): string;
    //��������� ������ � ������� ������, ���� ��� �� ������
    function AddBracket(st: string): string;

//-------------------------- �������� �������
//-- �����: � ������� �� ��������� ��������� � �������� ����� ��������� ������ ��� �� � ��� ��������

//���� Expr ������, �� ������ Par1, ����� Par2
//�������� ��� ���������� Variant, string, Integer, extended
    function IIf(Expr: Boolean; Par1, Par2: Variant): Variant;
    function IIfV(Expr: Boolean; Par1, Par2: Variant): Variant;
    function IIFStr(Expr: Boolean; Par1: string; Par2: string = ''): string; overload;  //������ �������� ����� �� ��������, ���� ������ ���� ������
    //���� ������ �������� �� ����, ���������� ���, ����� - ������
    function IfEmptyStr(St: string; StIfEmpty: string): string;
//�������� � ����� ������ #0 �� ������, ���� ������ ��������; ���� ������, ������ ''
    function IfNotEmptyStr(St: string; Mask: string = #0): string;
    function IIfInt(Expr: Boolean; Par1, Par2: Integer): Integer;
    function IIfFloat(Expr: Boolean; Par1, Par2: extended): Extended;
    //���� AValue = AIfValeu, �� ������ AIfValeu, ����� AElseValue
    function IfEl(AValue, AIfValeu, AElseValue: Variant): Variant;
//���� ValueFact = ValueCheck, �� ������ ValueFact, ����� ValueRes
    function IfNotEqual(ValueFact, ValueCheck, ValueRes: Variant): Variant;
//���� ValueFact �� ������ (empty, '', null), �� ������ ValueFact, ����� ValueRes
    function IfNotEmpty(ValueFact, ValueRes: Variant): Variant;
//���������� �� ������� ���������, ��������������� �������� ��������
//value, case1, value1, case2, value2, {valueelse}
    function Decode(ar: TVarDynArray): Variant;
//�������� ��� ������ ��� ����� ��������
    function CompareStI(st1, st2: string): Boolean;

//-------------------------- ������������ �����

//��������� ������ StPart � StAll ����� �����������. ���� ������ IfNotEmpty, �� ������ ������ �� ��������������
    function ConcatSt(StAll, StPart: string; Dividor: string = ','; IfNotEmpty: Boolean = False): string;
//���������. ��������� ������ StPart � StAll ����� �����������. ���� ������ IfNotEmpty, �� ������ ������ �� ��������������
    procedure ConcatStP(var StAll: string; StPart: string; Dividor: string = ','; IfNotEmpty: Boolean = False); overload;
    procedure ConcatStP(var StAll: Variant; StPart: Variant; Dividor: Variant; IfNotEmpty: Boolean = False); overload;

//-------------------------- ������� ��� sql-��������

//����������� ���� � ��� ���, ������� ����� �������� � ���
//� ��� �����, � ��������� ���������� ������ ��� ��� ����)
    function SQLdate(dt: TDateTime): ansistring;
//�������������� ����, ������� ��������� �����, � ������ ����� ������� ���� � ��������� ��
    function SQLdateTime(dt: TDateTime): ansistring;

//-------------------- �������������� ------------------------------------------

//�������� ������������ �������� �� ����������� �������
    function MaxOf(const Values: array of Variant): Variant;
//�������� ����������� �������� �� ����������� �������
    function MinOf(const Values: array of Variant): Variant;

//-------------------------- ��������� -----------------------------------------

//���������� ����, ������� ���������� ������� ��������� �������� ����/�������
    function BadDate: TDateTime;
//���������� ����� ���������� ����� ����� �����������
    procedure SwapPlaces(v1, v2: Variant);
//�� ���� ��� ���� �����
//function DivisionText(St:string;canvas:TCanvas;width,field:Integer):TStringList;
//������� ������ Csv � ������
//������� ����������, ���� ������������ ���� ����� ������������
//function ParseCsv(St: string; DivCh: Char): tSplitArray;
//������������� ������ ��� ������������� � �������� ����� �����
    function CorrectFileName(st: string): string;
//�������� ���
    function ValidateInn(inn: Variant): string;
//����������� ���� string � PAnsiChar c ��������� (��� ������ ����������)
    function StringToPAnsiChar(stringVar: string): PAnsiChar;
//���������� ��� ���� � ������� �� ����� ���� � �������   �������� �� '1 as field' ������ 'field'
//�������� �� '1 as field$s' ������ 'field$s'
    function WideStringToString(const ws: WideString; codePage: Word): AnsiString;
    function StringToWideString(const s: AnsiString; codePage: Word): WideString;
    function GetFieldNameFromSt(st: string): string;
    //���������� ��� ���� � ������� �� ����� ���� � �������
    //�������� �� '1 as field$s' ������ 'field', � ���� ���������� WithMod, �� 'field$s'
    function GetDBFieldNameFromSt(st: string; WithMod: Boolean = False): string;
    //���������� ��������� ������� � ����������� �� ���������� ����:
    //������, 4 ���, �����, 3 ������, �������, ���, 68 ���� - � ��������� ��������� ���� ��� �������� �� �������
    function GetDaysCountToName(Days: Integer): string;
    //�������� �������� ������, �� �������� ���������� � verify, � ������ ���� ������, ��������� � ValueType
    //��� ����� �������� ��������� ��������
    function VeryfyValue(ValueType: string; Verify: string; Value: string; var CorrectValue: Variant): Boolean;
    //���������� ��������� ������� ���� ���������� Variant
    //�������� ����� ����� ����� varInteger
    function VarType(Value: Variant): Integer;
    //���������, ������ �� �������� ���������� ���� Variant
    function VarIsClear(const V: Variant): Boolean;
    //���������� ���� ������ � ����� ������� �� ������� DatePeriods (�� ������ �������� ��� ��������). ���� �� ������� - ���������� �������
    procedure GetDatePeriod(Period: Variant; dt0: TDateTime; var dt1: TDateTime; var dt2: TDateTime);
  end;

//------------------------------------------------------------------------------
//------------- ������ � ���������
  TMyArrayHelper = record
//��������� �������� ������ �� ���������, ��������� ��� ����������� ������ DivSt
//�������� ������ ����� ���� � ��������, ����� ����� ��������� ���� ������
//���� �� ����������� IgnoreEmpty, �� �������� ����� ���� �������, � ������ ������ ������ �������� [''].
//������ ���������� ���������� ������
    function Explode(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TVarDynArray;
//������ ����� Explode
    function ExplodeV(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TVarDynArray;
//���� �����, �� ���������� TStringDynArray (��������� ������, �� ������������ ������ �� ������� ����������)
    function ExplodeS(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TStringDynArray;
//�� �� � ���� ��������
    procedure ExplodeP(V: Variant; DivSt: string; var Arr: TVarDynArray); overload;
    procedure ExplodeP(V: Variant; DivSt: string; var Arr: TStringDynArray); overload;
    procedure ExplodeP(V: Variant; DivSt: string; IgnoreEmpty: Boolean; var Arr: TVarDynArray); overload;
    procedure ExplodeP(V: Variant; DivSt: string; IgnoreEmpty: Boolean; var Arr: TStringDynArray); overload;

//������� ���������� ���������� ������ � ������ ����� �����������;
//���� IgnoreEmpty ����������, �� ���������� ������ �������� �������
    function Implode(Arr: array of Variant; Delim: string; IgnoreEmpty: Boolean = False): string; overload;
//������� ���������� ��������� ������ � ������ ����� �����������;
//���� IgnoreEmpty ����������, �� ���������� ������ �������� �������
    function Implode(Arr: TStringDynArray; Delim: string; IgnoreEmpty: Boolean = False): string; overload;
//������� � ������ ���������� ������� ���������� �������
    function Implode(Arr: TVarDynArray2; Col: Integer; Delim: string; IgnoreEmpty: Boolean = False): string; overload;
//������� � ������ ���� ���������� ������ �� ��������� ��������, ����������� ��� ������� � ����� ������ ������
    function Implode(Arr: TVarDynArray2; Columns: TByteSet; Delim1: string; Delim2: string; IgnoreEmpty: Boolean = False): string; overload;
//������� � ������ ���������� ������� ���������� �������
//������� ���������� ���������� ������ � ������ ����� �����������;
//������ �������� ������ ����������
    function ImplodeNotEmpty(Arr: array of Variant; Delim: string): string;
//��������� ����� �� TStrings, ��� ���� ���������� ������ ������ � ����� ������
    function ImplodeStringList(var sl: TStringList; Dividor: string = ','): string;
//������� ������� V � ���������� ������� Arr ���� Variant; ����� �� ��������� �������; ���� �� �������,
//���������� -1 (��� ���� ������ ������������ � ������� ���� �������, �� Low(Arr) - 1
    function PosInArray(V: Variant; Arr: array of Variant; IgnoreCase: Boolean = False): Integer; overload;
//������� ������� V � ���������� ������� Arr ���� �����; ����� �� ��������� �������
    function PosInArray(St: string; Arr: TStringDynArray; IgnoreCase: Boolean = False): Integer; overload;
    function PosInArray(V: Variant; Arr: TVarDynArray; IgnoreCase: Boolean = False): Integer; overload;
//������� ������� ������� ������ ��� ���������� �������, � ������� � ���� FNo ��������� �������� V
    function PosInArray(V: Variant; Arr: TVarDynArray2; FNo: Integer = 0; IgnoreCase: Boolean = False): Integer; overload;
//������ ������, ���� ������ ������������ � �������
    function InArray(V: Variant; Arr: array of Variant): Boolean;
//���������� �������� �� ������� ValueFNo, ��� �������� �������� � ������� KeyFNo = KeyValue
    function FindValueInArray2(FindValue: Variant; FindFNo: Integer; ResultFNo: Integer; Arr: TVarDynArray2; IgnoreCase: Boolean = False): Variant;
    //�������� ��������� ���� � ������� � ������ ����� ���������; ����������, ���� �� ������
    function ReplaceInArray(FindValue: Variant; NewValue: Variant; Arr: TVarDynArray; IgnoreCase: Boolean = False): Boolean; overload;
    //�������� ���� � ������� � ������, ��������� �� �������� ������-���� (������� ��� ���� ��) ����, ���� �� ������
    function ReplaceInArray(FindValue: Variant; NewValue: Variant; Arr: TVarDynArray2; FindFNo, ReplaceFNo: Integer; IgnoreCase: Boolean = False): Boolean; overload;
//�������� ���� � ������� � ������, ��������� �� �������� ������-���� ����
//���������� ������� ����������� ������� Column � ���������� �������
    function VarDynArray2ColToVD1(arr: TVarDynArray2; Column: Integer): TVarDynArray;
//���������� ������� ����������� ������� Column � ���������� �������
    function VarDynArray2RowToVD1(arr: TVarDynArray2; Row: Integer): TVarDynArray;
//������������ ��������� ������ �������� ��� ������� ��� �������� ������� ������ �������� TVarDynArray
//��� ���������� �� ��������� ������ ������� ������ TVarDynArray � ����� ������� TVarDynArray2
procedure VarDynArray2InsertArr(var arr2: TVarDynArray2; arr1: TVarDynArray; Pos: Integer = -1; ToInsert: Boolean = True);
//���������� ����������� ����������� �������
    procedure VarDynArraySort(var Arr: TVarDynArray; Asc: Boolean = True); overload;
//���������� ����������� ������������ ������� �� ����������� ����
    procedure VarDynArraySort(var Arr: TVarDynArray2; Col: Integer; Asc: Boolean = True); overload;
//���������� ����������� ������������ ������� �� ����������� ����
//���� ���������� �� 1 ������ ��� � �������, ���� � + �� �� �����������, � � - �� �� ��������, �� ��� ���������� �� �������� �� ������� ������� �������� -1
    procedure VarDynArray2Sort(var Arr: TVarDynArray2; Key: Integer);
//���������� ���������� ������, ���������� ������������, ������������ ��� ��������� ���� ��������
    function ArrCompare(const AVar1, AVar2: array of Variant; Operation: TArrayOperation): TVarDynArray;
//���������� ��� ����� �����, ��� ���������� ������, ��� ������ ����� ����� �������,
//������������ ������
    function VarIntToArray(v: Variant): TVarDynArray;
    //�������� ������ �����, ���������� ���������� ������
    function StringDynArrayToVarDynArray(sa: TStringDynArray): TVarDynArray;
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
    function AsFloat: Extended;
    function AsBoolean: Boolean;
    function AsDateTime: TDatetime;
  end;

//�� ���������� ���� ���
function WordPosition(const N: Integer; const S: string; WordDelims: TCharSet): Integer;
//����� ��� EhLib

function ExtractWordPos(N: Integer; const S: string; WordDelims: TCharSet; var Pos: Integer): string;
//����� ��� EhLib

function ExtractWord(N: Integer; const S: string; WordDelims: TCharSet): string;


//const
//  IsNumber: function (St:string; MinI, MaxI: Extended; FDigits: Integer = -1): Boolean =
//    TMyStringHelper.IsNumber(St:string; MinI, MaxI: Extended; FDigits: Integer = -1): Boolean;



//-------------- ������ -------------------------------------------------------
procedure Txt2File(St: string; Fname: string);


{-------------------------------------------------------------------}

implementation

uses
  Math, uErrors;


















//-----------------------------------------------------








//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//��������� �����

//----------- ������� �������� � ����������� ��������
(*
����� ������������ helper:
string.trimleft([]) ������� eghfdkz.obt cbvdjks? gthtdjls cnhjr? ghj,tks
string.trimstart([]) ������� ������������� ������� ����� (������ �������� ����������)
string.trim{([]])}
st.TrimLeft //������ ����������� �������
*)

function TMyStringHelper.TrimSt(const St: string; TrimCh: TCharDynArray = []; Mode: TMyStringLocation = stlBoth): string;
//������ ���������� ������� �����, ������ ��� � ����� ������ ������;
//���� �� ������� ������ ��������, �� ������� ������ � ���������
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
//���������. ������ ���������� ������� �����, ������ ��� � ����� ������ ������;
//���� �� ������� ������ ��������, �� ������� ������ � ���������
begin
  St := TrimSt(St, TrimCh, Mode);
end;

procedure TMyStringHelper.DelLeft(var st: string; TrimCh: TCharDynArray = []);
//������ ������� � ����� ����� ������
begin
  TrimStP(st, TrimCh, stlLeft);
end;

procedure TMyStringHelper.DelRight(var st: string; TrimCh: TCharDynArray = []);
//������ ������� � ������ ����� ������
begin
  TrimStP(st, TrimCh, stlRight);
end;

procedure TMyStringHelper.DelBoth(var st: string; TrimCh: TCharDynArray = []);
//�������� ����������� ������� �������� � ����� ������ ������
begin
  TrimStP(st, TrimCh, stlBoth);
end;


//----------- ��������.������ �������� � ������

function TMyStringHelper.ReplaceChars(St: string; Chars: TCharDynArray; ChNew: TCharDynArray; Mode: Boolean): string;
//mode=True  �������� � ������ ��� ������� �� [ch] �� ������ chnew[i]
//mode=False �������� � ������ ��� ������� �� not[ch] �� ������ chnew[i]
//���� ChNew = [], �� ������� ������� ����������,
//���� ChNew ����� ������ ���� �������, �� ��� ���� ������� ����������� ��,
//�����, ���� ����� �������� � �������� �����������, ������������ ������
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
    Errors.SetParam('ReplaceChars', '�� ��������� ������� ���������� Chars � ChNew');
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
//���� � ������ ���� ������ ������������������ �������� (���������), �� ��������� ������ ������ �� ���
//�� ��������!!! �������� ��� ������ ������������������ ���� ("1212����12", "12"), �� �� �� ������������� �������� (�� ������ ���� ������������������ "00"!!!
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
//���� � ������ ���� ��������� �������� ������, �� �������� �� � ������ �������
var
  i: Integer;
begin
  for i := Length(St) downto 1 do
    if (St[i] = Ch) and (St[i - 1] = Ch) then
      Delete(St, i, 1);
  Result := St;
end;

function TMyStringHelper.DeleteChar(St: string; Ch: char): string;
//������� ��� ������� Ch �� ������
var
  i: byte;
begin
  for i := Length(St) downto 1 do
    if St[i] = Ch then
      Delete(St, i, 1);
  Result := St;
end;

function TMyStringHelper.DeleteChars(St: string; Chars: TCharDynArray; Mode: Boolean): string;
//mode=True  ������� � ������ ��� ������� �� [ch]
//mode=False ������� � ������ ��� ������� �� not[ch]
var
  i: byte;
begin
  Result := ReplaceChars(St, Chars, [], Mode);
end;

function TMyStringHelper.ChangeChars(st: string; ch: tcharset; chnew: char; mode: Boolean): string;
//mode=True  �������� � ������ ��� ������� �� [ch] �� ������ chnew
//mode=False �������� � ������ ��� ������� �� not[ch] �� ������ chnew
var
  i: byte;
begin
  for i := 1 to length(st) do
    if ((st[i] in ch) and (mode)) or ((not (st[i] in ch)) and (not mode)) then
      st[i] := chnew;
  Result := st;
end;

function TMyStringHelper.FillString(Length: Integer; Chr: Char): string;
//���������� ����� �������� Fill
begin
  SetLength(Result, Length);
  FillChar(Result[1], Length, Chr);
end;





//---------������������ ������ �� ���� ��������� �������� ��� ������ ��������
{
 Writeln('123'.PadLeft(5));  //'  123'
 Writeln('12345'.PadLeft(5));  //'12345'
 Writeln('������ '.PadRight(20, '-') + ' ���. 7'); //'������ ------------- ���. 7'
}

function TMyStringHelper.PadLeft(St: string; Len: Integer; Ch: Char = ' '): string;
//��������� ������ ���������� �������� (�� ��������� ������) �����, �� ���������� �����
begin
  Result := St.PadLeft(Len, Ch);
end;

function TMyStringHelper.PadRight(St: string; Len: Integer; Ch: Char = ' '): string;
//��������� ������ ���������� �������� (�� ��������� ������) ������, �� ���������� �����
begin
  Result := St.PadRight(Len, Ch);
end;


//---------�������� ������������ ���� ������ (������ �����, ����...)

function TMyStringHelper.IsInt(St: string): Boolean;
//���������, �������� �� ������ ����� ������.
var
  i, j: Integer;
begin
  i := StrToIntDef(St, 0);
  j := StrToIntDef(St, 1);
  Result := (i = j);
end;

function TMyStringHelper.IsFloat(St: string): Boolean;
//���������, �������� �� ������ ������ � ��������� ������
var
  i, j: Extended;
begin
  i := StrToFloatDef(St, 0);
  j := StrToFloatDef(St, 1);
  Result := (i = j);
end;

function TMyStringHelper.IsNumber(St: string; MinI, MaxI: Extended; FDigits: Integer = -1): Boolean;
//���������, �������� �� ������ ������ � �������� ��������� � �������� ������ ���������� ������
//���� ����� ���������� ������ �� �����, �������� -1, ���� ����� ������ �����, �������� 0
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

//�������� ������ �� �� ��� �������� ����/�����
//DtType = dt - ������ ���� ����� ��� ����� �� ��������, DT - ����������� ���� � �����, d,D -������ ����, t - ������ �����
//�������������� ��� ����������� ���� � ������� - ������ (����������� ������ ��� ���), � ����� � ����� - ":"
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
//���� ������ ���� ����� ����� ��� ������
//���� ������ ������ ���� ����� ����� ������ ���� ����� �� ������ -
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
//������������������� ��������� ������ �� ���������� ��������� (����� ������ ��������������� ���������)

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

//---------������� ������ � ������� ����

function TMyStringHelper.StrToNumberCommaDot(V: Variant; MinI, MaxI: Extended; var Res: Extended; FDigits: Integer = -1): Boolean;
//���������, �������� �� ������ ������ � �������� ��������� � �������� ����������� ����� ����� ������� (�� �����)
//� �������� ������������ ��������� ����� � �������
//���������� ����� � Res: extended, � Result - ������ ��� ���� /���� �� ������� ������������� � �����/
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
//����������� ��� Variant � Integer; ��� ������� ���������� �������� Def
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
//����������� ��� Variant � Extended; ��� ������� ���������� �������� Def
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
//����������� ������ �� ���� ��� ���� �����, ����������� ��������� (��������, �������), � TDateTime
//���� ������� ���������� BadDate
//������������ ������ ��� ����� ������� ��� ��� ���� ���������� ������� ��� ��� � ����� ����� ���������� ����������
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
//��������������� ����� � ������ ������ �� ����� Len, ������� ����� ������ ��������� �������� Ch
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
//����������� TDateTime � ����� (Double) � ���������� �  ���� ������
//��������� �������
begin
  Result := FloatToStr(Double(dt));
end;



//--------- ��������� �������� ���� Null, ���������� � ��������� Varint

function TMyStringHelper.NSt(St: Variant): string;
//���������� ������ ������, ���� �������� Empty ��� Null
begin
  if VarIsEmpty(St) or (St = null) then begin
    Result := '';
    exit;
  end;
  Result := St;
end;

function TMyStringHelper.NNum(St: Variant; Default: Extended = 0): Extended;
//���������� 0 � ����� extended, ���� �������� Empty ��� Null
begin
  Result := Default;
  if NSt(St) = '' then
    Exit;
  Result := St;
end;

function TMyStringHelper.NInt(St: Variant): Integer;
//���������� 0 � ����� Integer, ���� �������� Empty ��� Null
begin
  Result := 0;
  if NSt(St) = '' then
    exit;
  Result := St;
end;

function TMyStringHelper.NullIfEmpty(v: Variant): Variant;
//���������� ���� ���� v=null or VarToString(v) ='', ����� ������ ���������� ��������
begin
  Result := v;
  if Result = null then
    Exit;
  if VarToStr(v) = '' then
    Result := null;
//  if (VarType(v) and VarTypeMask = varString) and (v = '') then Result:=null;
end;

function TMyStringHelper.NullIf0(v: Variant): Variant;
//���������� ���� ���� v=0 (0.00), ����� ������ ���������� ��������
begin
  Result := v;
  if Result = null then
    Exit;
  if extended(v) = 0 then
    Result := null;
end;

//--------------- ��������� �������� ����� � ��������

function TMyStringHelper.ChangeCaseStr(St: string; ToUpper: Boolean): string;
//�������� ������� ������ (� ��������� � ������� �����
begin
  if ToUpper then
    Result := St.ToUpper
  else
    Result := St.ToLoWer;
end;

function TMyStringHelper.ToUpper(St: string): string;
//������ � ������� �������
begin
  Result := St.ToUpper;
end;

function TMyStringHelper.ToLower(St: string): string;
//������ � ������ �������
begin
  Result := St.ToLower;
end;

function TMyStringHelper.ChangeCaseCh(Ch: Char; ToUpper: Boolean): string;
//�������� ������� ������� (� ��������� � ������� �����
begin
  Result := ChangeCaseStr(Ch, ToUpper)[1];
end;

function TMyStringHelper.Right(St: string; Cnt: Integer = 1): string;
begin
  Result:=Copy(St, Max(1, Length(St) - Cnt + 1), Cnt);
end;


//---------- ����� ����������, ���������� ������� ��������� � ������.

function TMyStringHelper.PosI(StPart, StFull: string): Integer;
//������� ������� ��������� � ������ ��� ����� ��������
begin
  Result := Pos(StPart.ToUpper, StFull.ToUpper);
end;

function TMyStringHelper.InCommaStr(stpart, stall: string; ch: Char = ','; IgnoreCase: Boolean = False): Boolean;
//���������, ���������� �� ��������� � ������ ��������, ����������� ��������
begin
  if IgnoreCase
    then Result := Pos(ch + ToUpper(stpart) + ch, ch + ToUpper(stall) + ch) > 0
    else Result := Pos(ch + stpart + ch, ch + stall + ch) > 0;
end;

function TMyStringHelper.InCommaStrI(stpart, stall: string; ch: Char = ','): Boolean;
//���������, ���������� �� ��������� � ������ ��������, ����������� ��������, ��� ����� ��������
begin
  Result := Pos(ch + stpart.ToLower + ch, ch + stall.ToLower + ch) > 0;
end;

function TMyStringHelper.GetCharCountInStr(St: string; Chars: TCharSet; p1: Integer = 1; p2: Integer = -1): Integer;
//������������ ���������� �������� �� ����������� ������ � ������, ������� � ������� �1 � �� �2 (���� -1 �� �� ����� ������)
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
//���� ������� ������� ����� � ������, ���������� ��������� ������� ������,
//������� ���� ����� ���� �� ����������� ������ �� DivSymbols
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
//���� ������� ����� ����� � ������, ���������� ��������� ������� ������,
//������� ���� ������ ���� �� ����������� ������ �� DivSymbols
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
//����� ��� EhLib
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
//����� ��� EhLib
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
//�� ���������� ���� ���
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
//��������� ������ St �� 3 �����: St1 -�� �������, St2 - � ��������, St3 - �����
//������� ����������� ��� ������� ��� � ���������
//�������� �� �������
var
  a, b, i, j: Integer;
begin
  st1 := '';
  st2 := '';
  st3 := '';
  {��������� ���������, ����������� � ������� (������ - a, ����� - b}
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
  {�������� �������� �� ������ ���������, ����������� � �������}
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
//�������� ��������� ����� NumSubSt �� ������, ������� ��������� �� ��������� ������������ DivSt
//���������� ����� ������� ��������� ��������� � ������
//���� �� ���� �������� ���������, �� ���������� -2 � ''
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
//����� �� �����:  �p������� ��p��� St � �������� Mask. � ������� �����
//y���p������ ����� '?'(����� ����) � '*' (����� ���������� ����� ������)
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
  {�p������ ������ (�� ��p���� ������� '*') ������� � ������}
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
    {���� ������ �py���, ������ ���p�� �py��� ������� �  }
    {�y��� ��������� ����� ���p����� ������� �p�������   }
    while (Mask[Mp] = '*') do  {while - ������ �� "**"}
    begin
      inc(Mp);
      Last := Mp;
        {���� '*' ����� � ����� �������, �� �����p����� }
        {����� ��p��� �� �p��y����                      }
      if (Mp > Ml) then begin
        Result := True;
        Exit;
      end;
    end;
    {���� ��������� ���, ��p�y�� p��y����� �p�������     }
    if (Sp > Sl) then begin
      Result := Mp > Ml;
      Exit;
    end;
    if (Mask[Mp] <> '?') and (Mask[Mp] <> St[Sp]) then begin
        {���� ���� ������� �� ��������� �� ������ �����,  }
        {�y��� ����y���� � �����y �����p��� � ����������  }
        {����� � �� ����y���� ������� �����              }
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
//����� �� �����:  �p������� ��p��� St � �������� Mask. � ������� �����
//y���p������ ����� '?'(����� ����) � '*' (����� ���������� ����� ������)}
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
  {�p������ ������ (�� ��p���� ������� '*') ������� � ������}
  repeat
    if (Sp > Sl) then begin
      Result := Mp > Ml;
      Exit;
    end;
    if ((Mask[Mp] = #1) and (St[Sp] in ['0'..'9'])) or ((Mask[Mp] = #2) and (St[Sp] in ['1'..'9'])) or ((Mask[Mp] = #3) and (St[Sp] in ['a'..'z', 'A'..'Z'])) or ((Mask[Mp] = #4) and (St[Sp] in ['A'..'Z'])) or ((Mask[Mp] = #5) and (St[Sp] in ['a'..'z']))//       or
//!!!!
//       ((Mask[Mp] = #6)and (St[Sp] in ['�'..'�','�'..'�','�','�']))or
//       ((Mask[Mp] = #7)and (St[Sp] in ['�'..'�','�']))or
//       ((Mask[Mp] = #8)and (St[Sp] in ['�'..'�','�']))
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
    {���� ������ �py���, ������ ���p�� �py��� ������� �  }
    {�y��� ��������� ����� ���p����� ������� �p�������   }
    while (Mask[Mp] = '*') do  {while - ������ �� "**"}
    begin
      inc(Mp);
      Last := Mp;
        {���� '*' ����� � ����� �������, �� �����p����� }
        {����� ��p��� �� �p��y����                      }
      if (Mp > Ml) then begin
        Result := True;
        Exit;
      end;
    end;
    {���� ��������� ���, ��p�y�� p��y����� �p�������     }
    if (Sp > Sl) then begin
      Result := Mp > Ml;
      Exit;
    end;
    if (Mask[Mp] <> '?') and (Mask[Mp] <> St[Sp]) then begin
        {���� ���� ������� �� ��������� �� ������ �����,  }
        {�y��� ����y���� � �����y �����p��� � ����������  }
        {����� � �� ����y���� ������� �����              }
      Sp := Sp - ((Mp - Last) - 1);
      Mp := Last;
    end
    else begin
      inc(Mp);
      inc(Sp);
    end;
  until False;
end;


//-------------------- �������������� �� ������ �����/����� � ��������� ����
//-- ��������, ����� ���� � ������ � ��������

function TMyStringHelper.NumToPhoneStr(Num: longint): string;
//�������������� ����� � ������ �������� � �������������
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
//�������������� ������ ��� ������ �������� � �������������
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
//�������������� ����� � ������ ���� ��������
var
  Num1: longint;
  St: string;
begin
  if Mode then begin
    Num1 := Num mod 100;
    Num := Num div 100;
    St := NumToWords(Num, 'm') + PriceWord(Num, 'r') + ' ';
    if Num1 < 10 then
      St := St + '���� ';
    St := St + NumToWords(Num1, 'f') + PriceWord(Num1, 'k');
  end
  else begin
    Num := Num * 10;
    St := NumToWords(Num, 'm') + PriceWord(Num, 'r');
  end;
  Result := St;
end;

function TMyStringHelper.NumToWords(Num: longint; Mode: char): string;
//�������������� ����� � ������ ��������
var
  n, n1: Integer;
  St, St1: string;
  i, j: ShortInt;
  Rank: longint;
  a: Boolean;
const
  NumWords: array[1..3, 1..9] of string[11] = (('����', '���', '���', '������', '����', '�����', '����', '������', '������'), ('������', '��������', '��������', '�����', '���������', '����������', '���������', '�����������', '���������'), ('���', '������', '������', '���������', '�������', '��������', '�������', '���������', '���������'));
  NumWords_1X: array[0..9] of string[12] = ('������', '�����������', '����������', '����������', '������������', '����������', '�����������', '����������', '������������', '������������');
  NumWords_F: array[1..2] of string[4] = ('����', '���');
  NumWords_N: array[1..1] of string[4] = ('����');
  RankWords: array[1..2, 1..3] of string[9] = (('������', '������', '�����'), ('�������', '��������', '���������'));
  Zero: string[4] = '����';
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
//��������� ������� ��� ������ ���� � ���������� ���� ������ � ������
begin
  Mode := UpCase(Mode);
  case Mode of
    'R':
      if (Num div 10) <> 1 then
        case (Num mod 10) of
          1:
            PriceWord := '�����';
          2..4:
            PriceWord := '�����';
        else
          PriceWord := '������';
        end
      else
        PriceWord := '������';
    'K':
      if (Num div 10) <> 1 then
        case (Num mod 10) of
          1:
            PriceWord := '�������';
          2..4:
            PriceWord := '�������';
        else
          PriceWord := '������';
        end
      else
        PriceWord := '������';
  end;
end;

function TMyStringHelper.NumToPriceStr(Num: longint): string;
//����������� ����� � ����� � ������ � �������� � ���� ����� � �� ����
//�������� ��� �����������, ���� � ����� �����, 2 ��������� ��� �������
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
//�������� ��������� �� ����������
//(���������� ��������� ��� ���-�� 1, 2{3,4}, 5(6,7,8,9,10)
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
//�������� ��������� �� ���������� (������� ��/���� �����)
begin
  if Num = 1 then
    Result := St1
  else
    Result := St2;
end;

function TMyStringHelper.AddBracket(st: string): string;
//��������� ������ � ������� ������, ���� ��� �� ������
begin
  Result:= st;
  if Result <> '' then Result := '(' + Result + ')';
end;



//-------------------------- �������� �������
//-- �����: � ������� �� ��������� ��������� � �������� ����� ��������� ������ ��� �� � ��� ��������

function TMyStringHelper.IIf(Expr: Boolean; Par1, Par2: Variant): Variant;
//���� Expr ������, �� ������ Par1, ����� Par2
//�������� ��� ���������� Variant, string, Integer, extended
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

function TMyStringHelper.IfNotEmptyStr(St: string; Mask: string = #0): string;
begin
  Result := St;
  if Result <> '' then
    Result := StringReplace(Mask, #0, Result, [rfReplaceAll]);
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
//���� AValue = AIfValeu, �� ������ AIfValeu, ����� AElseValue
begin
  if AValue = AIfValeu then Result:= AIfValeu else Result:= AElseValue;
end;


function TMyStringHelper.IfNotEqual(ValueFact, ValueCheck, ValueRes: Variant): Variant;
//���� ValueFact �� ������ (empty, '', null), �� ������ ValueFact, ����� ValueRes
begin
  if ValueFact = ValueCheck then
    Result := ValueFact
  else
    Result := ValueRes;
end;

function TMyStringHelper.IfNotEmpty(ValueFact, ValueRes: Variant): Variant;
//���������� �� ������� ���������, ��������������� �������� ��������
begin
  if not (VarIsEmpty(ValueFact) or (VarToStr(ValueFact) = '')) then
    Result := ValueFact
  else
    Result := ValueRes;
end;

function TMyStringHelper.Decode(ar: TVarDynArray): Variant;
//���������� �� ������� ���������, ��������������� �������� ��������
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

//�������� ��� ������ ��� ����� ��������
function TMyStringHelper.CompareStI(st1, st2: string): Boolean;
begin
  Result := ToUpper(st1) = ToUpper(st2);
end;


//-------------------------- ������������ �����

function TMyStringHelper.ConcatSt(StAll, StPart: string; Dividor: string = ','; IfNotEmpty: Boolean = False): string;
//��������� ������ StPart � StAll ����� �����������. ���� ������ IfNotEmpty, �� ������ ������ �� ��������������
begin
  Result := StAll;
  if IfNotEmpty and (StPart = '') then
    Exit;
  if StAll <> '' then
    Result := Result + Dividor;
  Result := Result + StPart;
end;

procedure TMyStringHelper.ConcatStP(var StAll: string; StPart: string; Dividor: string = ','; IfNotEmpty: Boolean = False);
//���������. ��������� ������ StPart � StAll ����� �����������. ���� ������ IfNotEmpty, �� ������ ������ �� ��������������
begin
  if IfNotEmpty and (StPart = '') then
    Exit;
  if StAll <> '' then
    StAll := StAll + Dividor;
  StAll := StAll + StPart;
end;

procedure TMyStringHelper.ConcatStP(var StAll: Variant; StPart: Variant; Dividor: Variant; IfNotEmpty: Boolean = False);
//���������. ��������� ������ StPart � StAll ����� �����������. ���� ������ IfNotEmpty, �� ������ ������ �� ��������������
begin
  if IfNotEmpty and (VarToStr(StPart) = '') then
    Exit;
  if VarToStr(StAll) <> '' then
    StAll := VarToStr(StAll) + VarToStr(Dividor);
  StAll := VarToStr(StAll) + VarToStr(StPart);
end;



//-------------------------- ������� ��� sql-��������

function TMyStringHelper.SQLdate(dt: TDateTime): ansistring;
//�������������� ���� � ������ ����� ������� ���� � ��������� ��
//����������� �f�� � ��� ���, ������� ����� �������� � ���
//� ��� �����, � ��������� ���������� ������ ��� ��� ����)
var
  Y, M, D: word;
begin
  DecodeDate(dt, Y, M, D);
  Result := IntToStr(Y) + IifStr(M < 10, '0', '') + IntToStr(M) + IifStr(D < 10, '0', '') + IntToStr(D);
end;

function TMyStringHelper.SQLdateTime(dt: TDateTime): ansistring;
//�������������� ����, ������� ��������� �����, � ������ ����� ������� ���� � ��������� ��
var
  Y, M, D, th, tm, ts, tms: word;
begin
  DecodeDateTime(Date, Y, M, D, th, tm, ts, tms);
  Result := IntToStr(Y) + IifStr(M < 10, '0', '') + IntToStr(M) + IifStr(D < 10, '0', '') + IntToStr(D) + IifStr(th < 10, '0', '') + IntToStr(th) + IifStr(tm < 10, '0', '') + IntToStr(tm) + IifStr(ts < 10, '0', '') + IntToStr(ts);
end;



//-------------------------- ��������� -----------------------------------------

function TMyStringHelper.GetFieldNameFromSt(st: string): string;
//���������� ��� ���� � ������� �� ����� ���� � �������
//�������� �� '1 as field$s' ������ 'field$s'
var
  ar: TStringDynArray;
begin
  ar := a.ExplodeS(st, ' ');
  Result := ar[High(ar)];
end;

function TMyStringHelper.GetDaysCountToName(Days: Integer): string;
//������, 4 ���, �����, 3 ������, �������, ���, 68 ���� - � ��������� ��������� ���� ��� �������� �� �������
begin
  case Days of
    7: Result:='������';
    14: Result:='2 ������';
    21: Result:='3 ������';
    29,30,31: Result:='�����';
    60,61,62: Result:='2 ������';
    90..93: Result:='3 ������';
    120..124: Result:='4 ������';
    30*5..31*5: Result:='4 ������';
    30*6..31*6: Result:='�������';
    30*7..31*7: Result:='7 �������';
    30*8..31*8: Result:='8 �������';
    30*9..31*9: Result:='9 �������';
    30*10..31*10: Result:='10 �������';
    30*11..31*11: Result:='11 �������';
    365..366: Result:='���';
  else
    Result:=InttoStr(Days) + ' ' + GetEnding(Days, '����','���','����');
  end;
end;


function TMyStringHelper.GetDBFieldNameFromSt(st: string; WithMod: Boolean = False): string;
//���������� ��� ���� � ������� �� ����� ���� � �������
//�������� �� '1 as field$s' ������ 'field', � ���� ���������� WithMod, �� 'field$s'
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
//���������� ����� ���������� ����� ����� �����������
var
  v: Variant;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

(*function ParseCsv(St: string; DivCh: Char): tSplitArray;
//������� ������ Csv � ������
//������� ����������, ���� ������������ ���� ����� ������������
var
  i,j,p,q:Integer;
  ParseCsv_:tsplitarray;
begin
//"""",,"qwerty","1,2",1,3
//���������� ������/��������� �� ������ ��������� �������� �������
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
//������������� ������ ��� ������������� � �������� ����� �����
var
  i: Integer;
  ch: Char;
begin
  Result := Trim(st);
  //������� ������������ �������
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
  //������ ����� ������
  //��� ����� - ���� ��������� �������� � ������ ��������, �� � ����� ���������� ���������� ����������� �������� ��� ��������,
  //� ����� �� ������� �� ����� ������, �� ��� ���� ����������
  while (Length(Result) > 0) and (Result[Length(Result)] = '.') do
    Delete(Result, Length(Result), 1);
 { for i:=Length(Result) downto 1 do begin
    Ch:=Char(Copy(Result, i, 1));
    if not (TPath.IsValidFileNameChar(Ch) and TPath.IsValidPathChar(Ch))
      then Delete(Result, i);
  end;}
end;

function TMyStringHelper.ValidateInn(inn: Variant): string;
//�������� ���������� ���, ���������� ������ ������ ���� ��� ������, ��� ��������� �������� ������
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
    error_message := '��� ����';
  end
  else if StrToFloatDef(inn, -1) = -1 then begin
    error_code := 2;
    error_message := '��� ����� �������� ������ �� ����';
  end
  else if not (Length(inn) in [10, 12]) then begin
    error_code := 3;
    error_message := '��� ����� �������� ������ �� 10 ��� 12 ����';
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
    error_message := '������������ ����������� �����';
  end;
  result := error_message;
end;

function TMyStringHelper.StringToPAnsiChar(stringVar: string): PAnsiChar;
//����������� ���� string � PAnsiChar c ��������� (��� ������ ����������)
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


//-------------------- �������������� ------------------------------------------

function TMyStringHelper.MaxOf(const Values: array of Variant): Variant;
//�������� ������������ �������� �� ����������� �������
var
  I: Cardinal;
begin
  Result := Values[0];
  for I := 0 to High(Values) do
    if Values[I] > Result then
      Result := Values[I];
end;

function TMyStringHelper.MinOf(const Values: array of Variant): Variant;
//�������� ����������� �������� �� ����������� �������
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
//���������� ��������� ������� ���� ���������� Variant
//�������� ����� ����� ����� varInteger
begin
 Result:= Variants.VarType(Value) and VarTypeMask;
 if Result = 16 then Result:= varInteger;  //��� ���������� ����� ������������� ������� �����
 if Result in [varSmallInt, varByte, varInteger, varWord, varInt64, 19{����� ������������� -MaxInt}] then Result:= varInteger;
 if Result in [varSingle, varDouble, varCurrency] then Result:= varDouble;
 if Variants.VarType(Value) and varString = varString then Result:= varString;  //����� �� ������������
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
//���������, ������ �� �������� ���������� ���� Variant
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
//���������� ���� ������ � ����� ������� �� ������� DatePeriods (�� ������ �������� ��� ��������). ���� �� ������� - ���������� �������
//('�������', '�����', '��� ������', '������� ������', '��� ��� ������', '������� ��� ������', '���� �����', '������� �����', ==7
//'���� �������', '������� �������','���� ���', '������� ���');
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



function TMyStringHelper.VeryfyValue(ValueType: string; Verify: string; Value: string; var CorrectValue: Variant): Boolean;
//�������� �������� ������, �� �������� ���������� � verify, � ������ ���� ������, ��������� � ValueType
//��� ����� �������� ��������� ��������

//��� ����� "min:max:fdigits:N:M"
//(min:max �� ��������� 0, fdigits - �� ����� �������� ���������� ����, N - �� ��������� null, M - ��������� ��� ������� /���� �� �����������/)

//��� ������
//CVerify - min:max:digits:inult:validchars:invalidcars
//����������� � ������������ ����� ������
//4 - n - ��������� ������ ��������
//4 - i - ��� ���������� - �������� ������ ���� � ������
//4 - u/l - ��� ����� � ���� - �������� ������� ��� ��������� �����
//4 - t - ����, p-������� ������� ��������, u,l-�������
//5 - ���������� �������
//6 - �������� �������

//��� ����
//(0) * - ���� �����������, �� ����������� ������, �� ������������
//(0) ���  S.DateTimeToIntStr(Date) - ��� ����
//(1) ���  ���. ����
//(2) ���� '-' �� ��������� ������ ����

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
      //������� - �� ����� ���� �� �����, ��� ��� �������� ��� �������� � ������� ��������
    if Pos('U', S.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := S.ChangeCaseStr(st2, True);
    if Pos('L', S.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := S.ChangeCaseStr(st2, False);
    if Pos('T', S.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := Trim(st2);
    if Pos('P', S.ChangeCaseStr(ver[3], True)) > 0 then
      st2 := DeleteRepSpaces(st2, ' ');
    st3 := ver[7];
      //������ ���������� �������
    for j := 1 to Length(st3) do
      st2 := StringReplace(st2, st3[j], '', [rfReplaceAll, rfIgnoreCase]);
      //���� ������ ��������, �� ������� ��������
    if st2 <> st then
      st := st2;
     //����� ������ � ��������� ��������
    Result := (Length(st2) >= StrToIntDef(ver[0], 1)) and (Length(st2) <= StrToIntDef(ver[1], 1));
          //��� ����������, ���� �����, �������� ��� � ������ �� �� ��������
{      if Result and (C is TDBComboboxEh) and (Pos('I', S.ChangeCaseStr(ver[3], True)) > 0) then begin
        Result := (TDBComboboxEh(C).ItemIndex >= 0)
      end;}
  end;
  CorrectValue:=st;
end;




//==============================================================================
//-------------------- ������� ------------------------------------------
//==============================================================================

function TMyArrayHelper.Explode(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TVarDynArray;
//��������� �������� ������ �� ���������, ��������� ��� ����������� ������ DivSt
//�������� ������ ����� ���� � ��������, ����� ����� ��������� ���� ������
//���� �� ����������� IgnoreEmpty, �� �������� ����� ���� �������, � ������ ������ ������ �������� [''].
//������ ���������� ���������� ������
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
    end;  //++ �������� �������� ����� ������� ������ � �� ����� ������
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
//������ ����� Explode
begin
  Result := Explode(V, DivSt, IgnoreEmpty);
end;

function TMyArrayHelper.ExplodeS(V: Variant; DivSt: string; IgnoreEmpty: Boolean = False): TStringDynArray;
//���� �����, �� ���������� TStringDynArray (��������� ������, �� ������������ ������ �� ������� ����������)
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
//�� �� � ���� ��������
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
//������� ���������� ���������� ������ � ������ ����� �����������;
//���� IgnoreEmpty ����������, �� ���\�������� ������ �������� �������
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
//������� ���������� ��������� ������ � ������ ����� �����������;
//���� IgnoreEmpty ����������, �� ���������� ������ �������� �������
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
//������� � ������ ���������� ������� ���������� �������
var
  i: Integer;
begin
  Result := '';
  for i := 0 to High(Arr) do
    if (VarToStr(Arr[i][Col]) <> '') or not IgnoreEmpty then
      s.ConcatStP(Result, Arr[i][Col], Delim);
end;

function TMyArrayHelper.Implode(Arr: TVarDynArray2; Columns: TByteSet; Delim1: string; Delim2: string; IgnoreEmpty: Boolean = False): string;
//������� � ������ ���� ���������� ������ �� ��������� ��������, ����������� ��� ������� � ����� ������ ������
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
//������� ���������� ���������� ������ � ������ ����� �����������;
//������ �������� ������ ����������
begin
  Result := Implode(Arr, Delim, True);
end;

function TMyArrayHelper.ImplodeStringList(var sl: TStringList; Dividor: string = ','): string;
//��������� ����� �� TStrings, ��� ���� ���������� ����� ������ � ����� ������
begin
  Result := s.TrimSt(sl.Text, [#10, #13], stlBoth);
  Result := StringReplace(sl.text, #13#10, Dividor, [rfReplaceAll]);
end;

function TMyArrayHelper.PosInArray(V: Variant; Arr: array of Variant; IgnoreCase: Boolean = False): Integer;
//������� ������� V � ���������� ������� Arr ���� Variant; ����� �� ��������� �������
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
//������� ������� V � ���������� ������� Arr ���� �����; ����� �� ��������� �������
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
//������� ������� V � ���������� ������� Arr ���� Variant; ����� �� ��������� �������
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
//������� ������� ������� ������ ��� ���������� �������, � ������� � ���� FNo ��������� �������� V
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

function TMyArrayHelper.FindValueInArray2(FindValue: Variant; FindFNo: Integer; ResultFNo: Integer; Arr: TVarDynArray2; IgnoreCase: Boolean = False): Variant;
//���������� �������� �� ������� ValueFNo, ��� �������� �������� � ������� KeyFNo = KeyValue
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
//�������� ��������� ���� � ������� � ������ ����� ���������; ����������, ���� �� ������
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
//�������� ���� � ������� � ������, ��������� �� �������� ������-���� (������� ��� ���� ��) ����, ���� �� ������
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
//������ ������, ���� ������ ������������ � �������
begin
  Result := (PosInArray(V, Arr) <> -1);
end;

function TMyArrayHelper.VarDynArray2ColToVD1(arr: TVarDynArray2; Column: Integer): TVarDynArray;
//���������� ������� ����������� ������� Column � ���������� �������
var
  i: Integer;
begin
  Result := [];
  for i := Low(arr) to High(arr) do
    Result := Result + [arr[i][Column]];
end;

function TMyArrayHelper.VarDynArray2RowToVD1(arr: TVarDynArray2; Row: Integer): TVarDynArray;
//���������� ������� ����������� ������� ��� � ���������� �������
var
  i: Integer;
begin
  Result := [];
  for i := Low(arr[Row]) to High(arr[Row]) do
    Result := Result + [arr[Row][i]];
end;


procedure TMyArrayHelper.VarDynArray2InsertArr(var arr2: TVarDynArray2;
  arr1: TVarDynArray; Pos: Integer = -1; ToInsert: Boolean = True);
//������������ ��������� ������ �������� ��� ������� ��� �������� ������� ������ �������� TVarDynArray
//��� ���������� �� ��������� ������ ������� ������ TVarDynArray � ����� ������� TVarDynArray2
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
//���������� ����������� ����������� �������
var
  i, j, k: Integer;
  changed, tosort: Boolean;
  buf: Variant;
begin
  repeat
    changed := False;
    for k := 0 to High(arr) - 1 do
      if (Asc and (arr[k] > arr[k + 1])) or (not Asc and (arr[k] < arr[k + 1])) then begin // �������� k-� � k+1-� ��������
        buf := arr[k];
        arr[k] := arr[k + 1];
        arr[k + 1] := buf;
        changed := True;
      end;
  until not changed;
end;

procedure TMyArrayHelper.VarDynArraySort(var Arr: TVarDynArray2; Col: Integer; Asc: Boolean = True);
//���������� ����������� ������������ ������� �� ����������� ����
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
//���������� ����������� ������������ ������� �� ����������� ����
//���� ���������� �� 1 ������ ��� � �������!!!, ���� � + �� �� �����������, � � - �� �� ��������, �� ��� ���������� �� �������� �� ������� ������� �������� -1
var
  i, j, k: Integer;
  changed, tosort: Boolean;
  buf: Variant;
begin
  repeat
    changed := False;
    for k := 0 to High(Arr) - 1 do
      if ((Key > 0) and (Arr[k][Key - 1] > Arr[k + 1][Key - 1])) or ((Key < 0) and (Arr[k][Key - 1] < Arr[k + 1][Key - 1])) then begin // �������� k-� � k+1-� ��������
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
//���������� ���������� ������, ���������� ������������, ������������ ��� ��������� ���� ��������
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
//���������� ��� ����� �����, ��� ���������� ������, ��� ������ ����� ����� �������,
//������������ ������
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
//�������� ������ �����, ���������� ���������� ������
var
  i: Integer;
begin
  Result:=[];
  for i:=0 to High(sa) do Result:=Result + [sa[i]];
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
    raise Exception.Create('���� �� ' + Field + ' ������� � NamedArr');
  Result := i;
end;

function TNamedArr.G(RowNo: Integer; Field: string): Variant;
var
  i : Integer;
begin
  i := Col(Field);
  if (RowNo < 0) or (RowNo > High(V)) then
    raise Exception.Create('������ ' + InttoStr(RowNo) + ' ��� ���� ' + Field + ' ��� ��������� � NamedArr');
  Result := V[RowNo][i];
end;

function TNamedArr.G(Field: string): Variant;
var
  i : Integer;
begin
  Result := G(0, Field);
end;

procedure TNamedArr.SetValue(RowNo: Integer; Field: string; NewValue: Variant);
var
  i : Integer;
begin
  i := Col(Field);
  if (RowNo < 0) or (RowNo > High(V)) then
    raise Exception.Create('������ ' + InttoStr(RowNo) + ' ��� ���� ' + Field + ' ��� ��������� � NamedArr');
  V[RowNo][i] := NewValue;
end;


function TNamedArr.Empty: Boolean;
begin
  Result := Length(V) = 0;
end;

function TNamedArr.Count: Integer;
begin
  Result := Length(V);
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



//==============================================================================
//==============================================================================
//==============================================================================

//���������� ����, ������� ���������� ������� ��������� �������� ����/�������
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

