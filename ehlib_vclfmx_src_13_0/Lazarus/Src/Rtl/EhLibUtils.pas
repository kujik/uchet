{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{                       EhLibUtils                      }
{                                                       }
{   Copyright (c) 2024-2025 by Dmitry V. Bolshakov      }
{                                                       }
{*******************************************************}

unit EhLibUtils;

{$I ..\Incl\EhLib.Inc}

interface

uses
  SysUtils, DB, TypInfo,
  {$IFDEF FPC}
    LazVersion, LCLPlatformDef, InterfaceBase,
    XMLWrite, XMLRead, DOM, xmlutils, Process,
    System.UITypes, LCLProc, lazutf8, LCLType,
  {$ELSE}
    SqlTimSt,
  {$ENDIF}
  Variants, FmtBcd, Types,
{$IFDEF EH_LIB_17} 
  System.UITypes,
{$ELSE} 
  Graphics,
{$ENDIF}
  Rtti, Math,
  Generics.Defaults, Generics.Collections, Classes, Contnrs;

{$I EhLibVerInfo.Inc}
{$I EhLibEditionInfo.Inc}

const
  DefaultPropListTypeKinds =
     [
      tkInteger,
      tkChar,
      tkEnumeration,
      tkFloat,
      tkString,
      tkSet,
      tkClass,
      
      tkWChar,
      tkLString,
      tkWString,
      tkVariant,
      tkArray,
      tkRecord,
      tkInt64,
      tkDynArray,
      tkUString,
      tkClassRef
      
      
      
     ];

  DefaultPropListMemberVisibilities = [mvPublic, mvPublished];

{$IFDEF FPC}
  {$IFDEF WINDOWS}
  
  {$ELSE}
  
  WM_SETTINGCHANGE = 26; 
  {$ENDIF}
{$ELSE}
{$ENDIF}

type

{$IFNDEF EH_LIB_16} 
  TSizeF = record
    cx: Single;
    cy: Single;
  public
    property Width: Single read cx write cx;
    property Height: Single read cy write cy;
  end;

{$IFDEF FPC}
{$ELSE}
  TPointF = record
    x: Single;
    y: Single;
  end;

  TRectF = record
  case Integer of
    0: (Left, Top, Right, Bottom: Single);
    1: (TopLeft, BottomRight: TPointF);
  end;
{$ENDIF}

{$ENDIF} 

{$IFDEF FPC} 
  TLocaleID = DWORD;
  TStreamOriginalFormat = (sofUnknown, sofBinary, sofText);

  {$IFDEF FPC_WINDOWS}
  {$ELSE} 
  TPanose = record
    bFamilyType: Byte;
    bSerifStyle: Byte;
    bWeight: Byte;
    bProportion: Byte;
    bContrast: Byte;
    bStrokeVariation: Byte;
    bArmStyle: Byte;
    bLetterform: Byte;
    bMidline: Byte;
    bXHeight: Byte;
  end;

  TOutlineTextMetric = record
  private
  public
    otmSize: UINT;
    otmTextMetrics: TTextMetric;
    otmFiller: Byte;
    otmPanoseNumber: TPanose;
    otmfsSelection: UINT;
    otmfsType: UINT;
    otmsCharSlopeRise: Integer;
    otmsCharSlopeRun: Integer;
    otmItalicAngle: Integer;
    otmEMSquare: UINT;
    otmAscent: Integer;
    otmDescent: Integer;
    otmLineGap: UINT;
    otmsCapEmHeight: UINT;
    otmsXHeight: UINT;
    otmrcFontBox: TRect;
    otmMacAscent: Integer;
    otmMacDescent: Integer;
    otmMacLineGap: UINT;
    otmusMinimumPPEM: UINT;
    otmptSubscriptSize: TPoint;
    otmptSubscriptOffset: TPoint;
    otmptSuperscriptSize: TPoint;
    otmptSuperscriptOffset: TPoint;
    otmsStrikeoutSize: UINT;
    otmsStrikeoutPosition: Integer;
    otmsUnderscoreSize: Integer;
    otmsUnderscorePosition: Integer;
  end;
  {$ENDIF} 

{$ELSE} 

  {$IFDEF EH_LIB_16} 
    
  {$ELSE} 
    TLocaleID = DWORD;
  {$ENDIF}
{$ENDIF} 

{$IFNDEF EH_LIB_16} 
  IntPtr = NativeInt;
{$ENDIF} 

  TObjectListEh = class;

{$IFDEF NEXTGEN}
{$ELSE}
 __TObject = class(TObject);
 __Int = Integer;
{$ENDIF}

{$IFDEF EH_LIB_29} 
  TListItemIndex = NativeInt;
{$ELSE}
  TMemberVisibilities = set of TMemberVisibility;
  TListItemIndex = Integer;
{$ENDIF}

  TPointArrayEh = array of TPoint;
  TDWORDArrayEh = array of DWORD;
  TVariantDynArray = array of Variant;
  TRectDynArray = array of TRect;

  TVarDynaTableEh = array of TVariantDynArray;

  TSortOrderEh = (soAscEh, soDescEh);

  ISideOwnedComponentEh = interface
    ['{C08052DC-C187-4BD3-B818-F26E7D245600}']
    function IsSideParentedBy(AComponent: TComponent): Boolean;
    procedure SetSideParent(AComponent: TComponent);
  end;

  ICalcFieldEh = interface
    ['{E564FFA8-A1D5-4A02-B64F-9E47F5C8F2DF}']
    function CanModifyWithoutEditMode: Boolean;
  end;

  IObjectRefInterface = interface
    ['{8FF448B0-EF45-454A-91EA-15648D848A63}']
    function GetObject: TObject;
  end;

  IDefaultItemsCollectionEh = interface
    ['{382EF9DE-34D2-4E23-82C8-5DC51B8E1CCE}']
    function CanAddDefaultItems: Boolean;
    procedure AddAllItems(DeleteExisting: Boolean);
  end;

  IDataContextEh = interface
  ['{EEBA9933-63C8-42C6-A136-E79B4AD6FC72}']
    function GetFieldValue(AFieldName: String): TValue;
    function GetComponent: TComponent;
  end;

  TVariantArrayEh = array of Variant;

  TLSAutoFilterTypeEh = (lsftBeginsWithEh, lsftContainsEh);

{$IFDEF NEXTGEN}

  TObjectListEh = class(TObjectList)
  public
    constructor Create; overload;
    constructor Create(AOwnsObjects: Boolean); overload;

    procedure Sort(Compare: TListSortCompare);
  end;

{$ELSE} 

  TObjectListEh = class(TObjectList)
  public
    constructor Create; overload;
    constructor Create(AOwnsObjects: Boolean); overload;

    procedure Sort(Compare: TListSortCompare);
  end;

{$ENDIF} 

{$IFDEF FPC} 
  TSortedListEh<T> = class(TSortedList<T>)
  end;

{ TStreamWriter }

  TStreamWriter = class(TObject)
  private
    FStream: TStream;
  public
    constructor Create(Stream: TStream; Encoding: TEncoding);
    destructor Destroy; override;
    procedure Write(Value: Boolean); overload;
    procedure Write(Value: Char); overload;
    procedure Write(const Value: string); overload;
  end;

{ TStreamReader }

  TStreamReader = class(TObject)
  private
    FStream: TStream;
    function GetEndOfStream: Boolean;
  public
    constructor Create(Stream: TStream; Encoding: TEncoding; DetectBOM: Boolean = False);
    destructor Destroy; override;
    function Peek: Integer;
    function Read: Integer;
    property EndOfStream: Boolean read GetEndOfStream;
  end;

  TXMLDocOption = (doNodeAutoCreate, doNodeAutoIndent, doAttrNull,
    doAutoPrefix, doNamespaceDecl, doAutoSave);
  TXMLDocOptions = set of TXMLDocOption;

  IRefObject = interface
    ['{D1E0064F-497C-4BC6-A72B-690394EB64FB}']
    function GetObject: TObject;
  end;

  IXMLNode = interface;

  IXMLNodeList = interface
    ['{395950C1-7E5D-11D4-83DA-00C04F60B2DD}']
    function GetCount: Integer;
    function Add(const Node: IXMLNode): Integer;
    function FindNode(NodeName: String): IXMLNode;
    function Delete(const Name: String): Integer;
    procedure Insert(Index: Integer; const Node: IXMLNode);
    function GetNode(const IndexOrName: OleVariant): IXMLNode;
  { Property Accessors }
    property Count: Integer read GetCount;
    property Nodes[const IndexOrName: OleVariant]: IXMLNode read GetNode; default;
  end;

  IXMLNode = interface
    ['{395950C0-7E5D-11D4-83DA-00C04F60B2DD}']
    function GetAttribute(const AttrName: String): OleVariant;
    procedure SetAttribute(const AttrName: String; const Value: OleVariant);
    function GetChildNodes: IXMLNodeList;
    function GetText: String;
    procedure SetText(const Value: String);
    function AddChild(const TagName: String; Index: Integer = -1): IXMLNode; overload;
    function AddChild(const TagName, NamespaceURI: String; GenPrefix: Boolean = False; Index: Integer = -1): IXMLNode; overload;
    function GetParentNode: IXMLNode;
    function  GetNodeName: String;
    function  GetNodeValue: String;
    procedure SetNodeValue(const AValue: String);
    procedure DeclareNamespace(const Prefix, URI: String);
  { Properties }
    property Attributes[const AttrName: String]: OleVariant read GetAttribute write SetAttribute;
    property ChildNodes: IXMLNodeList read GetChildNodes;
    property Text: String read GetText write SetText;
    property NodeName: String read GetNodeName;
    property NodeValue: String read GetNodeValue write SetNodeValue;
  end;

  IXMLDocument = interface(IInterface)
    ['{395950C3-7E5D-11D4-83DA-00C04F60B2DD}']
    function GetOptions: TXMLDocOptions;
    procedure SetOptions(const Value: TXMLDocOptions);
    function GetEncoding: String;
    procedure SetEncoding(const Value: String);
    function GetStandAlone: String;
    procedure SetStandAlone(const Value: String);
    procedure SaveToFile(const AFileName: String);
    procedure SaveToStream(const Stream: TStream);
    function AddChild(const TagName: String): IXMLNode; overload;
    function AddChild(const TagName, NamespaceURI: String): IXMLNode; overload;
    function CreateElement(const TagOrData, NamespaceURI: String): IXMLNode;
    function GetDocumentElement: IXMLNode;
    function GetChildNodes: IXMLNodeList;

    { Properties }
    property ChildNodes: IXMLNodeList read GetChildNodes;
    property Options: TXMLDocOptions read GetOptions write SetOptions;
    property Encoding: String read GetEncoding write SetEncoding;
    property StandAlone: String read GetStandAlone write SetStandAlone;
    property DocumentElement: IXMLNode read GetDocumentElement;
  end;

{ TXMLNodeListEh }

  TXMLNodeListEh = class(TInterfacedObject, IXMLNodeList)
  private
    FDOMElement: TDOMElement;

    function GetCount: Integer;
    function Add(const Node: IXMLNode): Integer;
    function FindNode(NodeName: String): IXMLNode;
    function Delete(const Name: String): Integer;
    procedure Insert(Index: Integer; const Node: IXMLNode);
    function GetNode(const IndexOrName: OleVariant): IXMLNode;

  public
    constructor Create(ADOMElement: TDOMElement);
    destructor Destroy; override;

  end;

{ TXMLNodeEh }

  TXMLNodeEh = class(TInterfacedObject, IXMLNode, IRefObject)
  private
    FDOMElement: TDOMElement;

    function AddChild(const TagName: String; Index: Integer = -1): IXMLNode;  overload;
    function AddChild(const TagName, NamespaceURI: String; GenPrefix: Boolean = False; Index: Integer = -1): IXMLNode;  overload;
    function GetParentNode: IXMLNode;
    function GetAttribute(const AttrName: String): OleVariant;
    function GetChildNodes: IXMLNodeList;
    function GetText: String;
    function  GetNodeName: String;
    function  GetNodeValue: String;
    procedure DeclareNamespace(const Prefix, URI: String);
    procedure SetNodeValue(const AValue: String);

    procedure SetAttribute(const AttrName: String; const Value: OleVariant);
    procedure SetText(const Value: String);

    function GetObject: TObject;

  public
    constructor Create(ADOMElement: TDOMElement);
    destructor Destroy; override;

  end;

{ TXMLDocumentEh }

  TXMLDocumentEh = class(TInterfacedObject, IXMLDocument)
  private
    FXMLDoc: TXMLDocument;

    function GetOptions: TXMLDocOptions;
    function GetEncoding: String;
    function GetStandAlone: String;
    function GetChildNodes: IXMLNodeList;
    function AddChild(const TagName: String): IXMLNode; overload;
    function AddChild(const TagName, NamespaceURI: String): IXMLNode; overload;
    function CreateElement(const TagOrData, NamespaceURI: String): IXMLNode;
    function GetDocumentElement: IXMLNode;

    procedure SetOptions(const Value: TXMLDocOptions);
    procedure SetEncoding(const Value: String);
    procedure SetStandAlone(const Value: String);
    procedure SaveToFile(const AFileName: String);
    procedure SaveToStream(const Stream: TStream);

  public
    constructor Create; overload;
    constructor Create(AXMLDoc: TXMLDocument); overload;
    destructor Destroy; override;
  end;

{$ELSE} 

  TSortedListEh<T> = class(TList<T>)
  private
    FDuplicates: TDuplicates;

  public
    function Add(const Value: T): Integer;
    procedure Insert(Index: Integer; const Value: T);

    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
  end;

{$IFNDEF EH_LIB_17} 

type

{ TFormatSettingsProxyEh }

  TFormatSettingsProxyEh = class(TObject)
  private
    function GetDecimalSeparator: Char;
    function GetDateSeparator: Char;
    function GetTimeSeparator: Char;
    function GetThousandSeparator: Char;
    function GetShortDateFormat: String;
    function GetLongDateFormat: String;
    function GetLongTimeFormat: String;
    function GetCurrencyDecimals: Byte;
    function GetShortMonthNames(Index: Integer) : String;
    function GetLongMonthNames(Index: Integer) : String;
    function GetShortDayNames(Index: Integer) : String;
    function GetLongDayNames(Index: Integer) : String;
    function GetTwoDigitYearCenturyWindow: Word;
    function GetShortTimeFormat: String;
    function GetTimeAMString: String;
    function GetTimePMString: String;

    procedure SetCurrencyDecimals(Value: Byte);
    procedure SetDateSeparator(Value: Char);
    procedure SetDecimalSeparator(Value: Char);
    procedure SetLongDateFormat(Value: String);
    procedure SetLongDayNames(Index: Integer; Value: String);
    procedure SetLongMonthNames(Index: Integer; Value: String);
    procedure SetLongTimeFormat(Value: String);
    procedure SetShortDateFormat(Value: String);
    procedure SetShortDayNames(Index: Integer; Value: String);
    procedure SetShortMonthNames(Index: Integer; Value: String);
    procedure SetShortTimeFormat(const Value: String);
    procedure SetThousandSeparator(Value: Char);
    procedure SetTimeAMString(const Value: String);
    procedure SetTimePMString(const Value: String);
    procedure SetTimeSeparator(Value: Char);
    procedure SetTwoDigitYearCenturyWindow(Value: Word);
  public
    property DecimalSeparator: Char read GetDecimalSeparator write SetDecimalSeparator;
    property DateSeparator: Char read GetDateSeparator write SetDateSeparator;
    property TimeSeparator: Char read GetTimeSeparator write SetTimeSeparator;
    property CurrencyDecimals: Byte read GetCurrencyDecimals write SetCurrencyDecimals;
    property ThousandSeparator: Char read GetThousandSeparator write SetThousandSeparator;
    property ShortDateFormat: String read GetShortDateFormat write SetShortDateFormat;
    property ShortTimeFormat: String read GetShortTimeFormat write SetShortTimeFormat;
    property LongDateFormat: String read GetLongDateFormat write SetLongDateFormat;
    property LongTimeFormat: String read GetLongTimeFormat write SetLongTimeFormat;

    property ShortMonthNames[Value: Integer] : String read GetShortMonthNames write SetShortMonthNames;
    property LongMonthNames[Value: Integer] : String read GetLongMonthNames write SetLongMonthNames;
    property ShortDayNames[Value: Integer] : String read GetShortDayNames write SetShortDayNames;
    property LongDayNames[Value: Integer] : String read GetLongDayNames write SetLongDayNames;
    property TimeAMString: String read GetTimeAMString write SetTimeAMString;
    property TimePMString: String read GetTimePMString write SetTimePMString;

    property TwoDigitYearCenturyWindow: Word read GetTwoDigitYearCenturyWindow write SetTwoDigitYearCenturyWindow;
  end;

function FormatSettings: TFormatSettingsProxyEh;

{$ENDIF} 

{$ENDIF} 

{$IFDEF FPC} 
function VarTypeToDataType(VarType: Integer): TFieldType;
function TestStreamFormat(Stream: TStream): TStreamOriginalFormat;
function WStrCopy(Dest: PWideChar; const Source: PWideChar): PWideChar;
function NewXMLDocument(Version: DOMString = '1.0'): IXMLDocument;
function GetUltimateOwner(APersistent: TPersistent): TPersistent;
{$ELSE} 
{$ENDIF}

procedure FreeObjectEh(obj: TObject);
procedure DoNothing();

function CharInSetEh(C: Char; const CharSet: TSysCharSet): Boolean;
function StringSearch(const SubStr, S: string; CaseInsensitive: Boolean; WholeWord: Boolean; Offset: Integer = 1): Integer;

function PropInfo_getPropType(APropInfo: PPropInfo): PTypeInfo;
function PropInfo_getName(APropInfo: PPropInfo): String;
function PropType_getKind(APropType: PTypeInfo): TTypeKind;
function GetClassPropertiesAsArray(ATypeInfo: TClass;
                                   TypeKinds: TTypeKinds = DefaultPropListTypeKinds;
                                    MemberVisibilities: TMemberVisibilities = DefaultPropListMemberVisibilities): TArray<TRttiProperty>;

function GetEnumPropValueAsString(Instance: TObject; const PropName: string): String;
procedure SetEnumPropValueAsString(Instance: TObject; const PropName: string; AValue: String);

procedure VarArrayRedimEh(var A : Variant; HighBound: Integer);
function VarEquals(const V1, V2: Variant): Boolean;
function VarIsNumericType(const Value: Variant): Boolean;
function VarIsStringType(const Value: Variant): Boolean;
function IsVarTypeNumeric(const AVarType: TVarType): Boolean;
function VarToAnsiStr(const V: Variant): AnsiString;
procedure VarSetNull(var V: Variant); {$IFDEF EH_LIB_8} inline;{$ENDIF}
function VarIsNullEh(const V: Variant): Boolean; {$IFDEF EH_LIB_8} inline;{$ENDIF}
function VarToStrEh(const V: Variant): String;
function TryVarToStr(const VarValue: Variant; var StrValue: String): Boolean;
function SysStrToVar(const Value: String; VarType: Word): Variant;
function SysVarToStr(const Value: Variant): String;
function SysStrToFloat(const S: string): Extended;
function SysFloatToStr(const Val: Extended): string;
function DBVarCompareValue(const A, B: Variant): TVariantRelationship;
function AnyVarToStrEh(const V: Variant): String;
function MiddleDotChar: Char;

function CompareValue(const A, B: TValue): TVariantRelationship;
function SameValue(const A, B: TValue): Boolean;
function CastSameValue(const A, B: TValue): Boolean;
function ValueIsNullOrEmpty(const V: TValue): Boolean;
function ValueIsArrayOfValues(const V: TValue): Boolean;
function FormatValue(const Format: string; const Value: TValue): String;
function ValueToString(const V: TValue): String;
function ValueToInteger(const V: TValue; OnEmptyValue: Integer = 0): Integer;
function ValueToInt64(const V: TValue; OnEmptyValue: Int64 = 0): Int64;
function ValueToUInt64(const V: TValue; OnEmptyValue: UInt64 = 0): UInt64;
function IsTypeNumeric(const ATypeInfo: PTypeInfo): Boolean;
function ValueIsStringType(const V: TValue): Boolean;
function RttiValueToVariantValue(const V: TValue): Variant;

function CastValueToBcdValue(const Value: TValue): TValue;
function CastValueToBcd(const Value: TValue): TBcd;
//function CanCastValueToBcd(const Value: TValue): Boolean;
function ValueIsNumeric(const Value: TValue): Boolean;

function NlsUpperCase(const S: String): String;
function NlsLowerCase(const S: String): String;
function NlsCompareStr(const S1, S2: String): Integer;
function NlsCompareText(const S1, S2: String): Integer;

function StrLength(s: String): Integer;
function TextLength(s: String): Integer;
function TextCopy(S: String; Index: Integer; Count: Integer): string;
procedure TextDelete(var S: string; const Index: Integer; const Count: Integer);

function VariantToRefObject(VarValue: Variant): TObject;
function RefObjectToVariant(ARefObject: TObject): Variant;

function IsLeadCharEh(C: Char): Boolean;
function GetAllStrEntry(S, SubStr: String; var StartPoses: TIntegerDynArray; CaseInsensitive, WholeWord, StartOfString: Boolean): Boolean;

{$IFDEF NEXTGEN}
{$ELSE}
function WideStringCompare(const ws1, ws2: WideString; CharCount: Integer = 0; CaseInsensitive: Boolean = False): Integer;
function AnsiStringCompare(const s1, s2: String; CharCount: Integer = 0; CaseInsensitive: Boolean = False): Integer;
{$ENDIF}

function TruncDateTimeToSeconds(dt: TDateTime): TDateTime;

function HexToBinEh(Text: Pointer; out Buffer: TBytes; CharCount: Integer): Integer; overload;
function HexToBinEh(Text: String; out Buffer: TBytes; CharCount: Integer): Integer; overload;

procedure BinToHexEh(Buffer: TBytes; out Text: String; Count: Integer);
function EmptyRect: TRect;
function CenterRect(const SourceRect: TRect; const ACenteredRect: TRect): TRect;

function IsObjectAndIntegerRefSame(AObject: TObject; IntRef: IntPtr): Boolean;
function IntPtrToObject(AIntPtr: IntPtr): TObject;
function ObjectToIntPtr(AObject: TObject): IntPtr;
function IntPtrToString(AIntPtr: IntPtr): String;

function RGBToColorEh(R, G, B: Byte): TColor;
procedure GetRGB(Col: TColor; var R, G, B: Byte);
function ColorToRGB(Color: TColor): Longint;

function GetTickCountEh: UInt64;
function IsByteDynArrayEqual(const A, B: TByteDynArray): Boolean;

function GetEhLibSysInfoAsString: String;

var
  WordDelimitersEh: String =
    ' .;,:(){}"''/\<>!?[]-+*='#$09#$91#$92#$93#$94#$A0#$D0#$84;
  EhLibDebugChecks: Boolean;
  ColorToRGBProc: function (Color: TColor): Longint;

{$IFDEF FPC}
const
  STextTrue: String = 'True';
  STextFalse: String = 'False';
  FilerSignature: array[1..4] of Char = 'TPF0';
{$ELSE}
{$ENDIF}

implementation

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  RTLConsts,
  DateUtils,
  StrUtils;

function IsByteDynArrayEqual(const A, B: TByteDynArray): Boolean;
var
  L: Integer;
begin
  if Pointer(A) = Pointer(B) then Exit(True);
  L := Length(A);
  if L <> Length(B) then Exit(False);
  Result := CompareMem(Pointer(A), Pointer(B), Sizeof(Byte) * L);
end;

{$IFDEF FPC} 
function TestStreamFormat(Stream: TStream): TStreamOriginalFormat;
var
  Pos: Int64;
  Signature: Integer;
begin
  Pos := Stream.Position;
  Signature := 0;
  Stream.Read(Signature, sizeof(Signature));
  Stream.Position := Pos;
  if (Byte(Signature) = $FF) or (Signature = Integer(FilerSignature)) then
    Result := sofBinary
  else if Char(Signature) in ['o','O','i','I',' ',#13,#11,#9] then
    Result := sofText
  else if (Signature and $00FFFFFF) = $00BFBBEF then
    Result := sofText
  else
    Result := sofUnknown;
end;

function VarTypeToDataType(VarType: Integer): TFieldType;
begin
  case VarType of
    varSmallint: Result := ftSmallInt;
    varShortInt: Result := ftSmallInt;
    varByte: Result := ftSmallInt;
    varWord: Result := ftWord;
    varInteger: Result := ftInteger;
    varCurrency: Result := ftBCD;
    varLongWord: Result := ftWord;
    varSingle: Result := ftFloat;
    varDouble: Result := ftFloat;
    varDate: Result := ftDateTime;
    varBoolean: Result := ftBoolean;
    varString: Result := ftString;
    varUString, varOleStr: Result := ftWideString;
    varInt64: Result := ftLargeInt;
  else
    if ((VarType and varArray) = varArray) and ((VarType and varTypeMask) = varByte) then
      Result := ftBlob
    else
      Result := ftUnknown;
  end;
end;

function WStrCopy(Dest: PWideChar; const Source: PWideChar): PWideChar;
var
  Src : PWideChar;
begin
  Result := Dest;
  Src := Source;
  while (Src^ <> #$00) do
  begin
    Dest^ := Src^;
    Inc(Src);
    Inc(Dest);
  end;
  Dest^ := #$00;
end;

procedure StreamWriteAnsiString(Stream: TStream; S: AnsiString);
begin
  Stream.Write(PAnsiChar(S)^, Length(S));
end;

type
  TPersistentCracker = class(TPersistent);

function GetUltimateOwner(APersistent: TPersistent): TPersistent;
begin
  Result := TPersistentCracker(APersistent).GetOwner;
end;

{ TStreamWriter }

constructor TStreamWriter.Create(Stream: TStream; Encoding: TEncoding);
begin
  inherited Create;
  FStream := Stream;
end;

destructor TStreamWriter.Destroy;
begin
  inherited Destroy;
end;

procedure TStreamWriter.Write(Value: Boolean);
begin
  StreamWriteAnsiString(FStream, BoolToStr(Value, True));
end;

procedure TStreamWriter.Write(Value: Char);
begin
  StreamWriteAnsiString(FStream, String(Value));
end;

procedure TStreamWriter.Write(const Value: string);
begin
  StreamWriteAnsiString(FStream, Value);
end;

{ TStreamReader }

constructor TStreamReader.Create(Stream: TStream; Encoding: TEncoding;
  DetectBOM: Boolean = False);
begin
  inherited Create;
  FStream := Stream;
end;

destructor TStreamReader.Destroy;
begin
  inherited Destroy;
end;

function TStreamReader.Read: Integer;
var
  c: Char;
begin
  Result := -1;
  c := #0;
  if EndOfStream then Exit;
  FStream.Read(c, 1);
  Result := Integer(c);
end;

function TStreamReader.GetEndOfStream: Boolean;
begin
  Result := (FStream.Size = FStream.Position);
end;

function TStreamReader.Peek: Integer;
begin
  Result := -1;
  if EndOfStream then Exit;
  Result := Read;
  FStream.Position := FStream.Position - 1;
end;

{ TXMLDocumentEh }

constructor TXMLDocumentEh.Create;
begin
  FXMLDoc := TXMLDocument.Create;
end;

constructor TXMLDocumentEh.Create(AXMLDoc: TXMLDocument);
begin
  FXMLDoc := AXMLDoc;
end;

destructor TXMLDocumentEh.Destroy;
begin
  FreeAndNil(FXMLDoc);
  inherited Destroy;
end;

function TXMLDocumentEh.GetOptions: TXMLDocOptions;
begin
  Result := [];
end;

procedure TXMLDocumentEh.SetOptions(const Value: TXMLDocOptions);
begin

end;

function TXMLDocumentEh.GetEncoding: String;
begin
  Result := String(FXMLDoc.XMLEncoding);
end;

procedure TXMLDocumentEh.SetEncoding(const Value: String);
begin
  FXMLDoc.SetHeaderData(xmlVersion10, DOMString(Value));
end;

function TXMLDocumentEh.GetStandAlone: String;
begin
  if (FXMLDoc.XMLStandalone) then
    Result := 'yes'
  else
    Result := 'no';
end;

procedure TXMLDocumentEh.SetStandAlone(const Value: String);
begin
  if (SameText(Value,'yes')) then
    FXMLDoc.XMLStandalone := True
  else
    FXMLDoc.XMLStandalone := False;
end;

procedure TXMLDocumentEh.SaveToFile(const AFileName: String);
begin
  WriteXMLFile(FXMLDoc, AFileName);
end;

procedure TXMLDocumentEh.SaveToStream(const Stream: TStream);
begin
  WriteXMLFile(FXMLDoc, Stream);
end;

function TXMLDocumentEh.AddChild(const TagName: String): IXMLNode;
var
  de: TDOMElement;
begin
  de := FXMLDoc.CreateElement(DOMString(TagName));
  FXMLDoc.AppendChild(de);
  Result := TXMLNodeEh.Create(de);
end;

function TXMLDocumentEh.AddChild(const TagName, NamespaceURI: String): IXMLNode;
begin
  Result := AddChild(TagName);
end;

function TXMLDocumentEh.CreateElement(const TagOrData, NamespaceURI: String): IXMLNode;
var
  de: TDOMElement;
begin
  de := FXMLDoc.CreateElement(DOMString(TagOrData));
  Result := TXMLNodeEh.Create(de);
end;

function TXMLDocumentEh.GetDocumentElement: IXMLNode;
begin
  Result := TXMLNodeEh.Create(FXMLDoc.DocumentElement);
end;

function TXMLDocumentEh.GetChildNodes: IXMLNodeList;
begin
  Result := TXMLNodeListEh.Create(FXMLDoc.DocumentElement);
end;

{ TXMLNodeEh }

constructor TXMLNodeEh.Create(ADOMElement: TDOMElement);
begin
  FDOMElement := ADOMElement;
end;

destructor TXMLNodeEh.Destroy;
begin
  inherited Destroy;
end;

function TXMLNodeEh.AddChild(const TagName: String; Index: Integer): IXMLNode;
var
  de: TDOMElement;
begin
  de := FDOMElement.OwnerDocument.CreateElement(DOMString(TagName));
  FDOMElement.AppendChild(de);
  Result := TXMLNodeEh.Create(de);
end;

function TXMLNodeEh.AddChild(const TagName, NamespaceURI: String;
  GenPrefix: Boolean; Index: Integer): IXMLNode;
begin
  Result := AddChild(TagName, Index);
end;

function TXMLNodeEh.GetParentNode: IXMLNode;
begin
  Result := TXMLNodeEh.Create(TDOMElement(FDOMElement.ParentNode));
end;

procedure TXMLNodeEh.SetAttribute(const AttrName: String; const Value: OleVariant);
begin
  FDOMElement.AttribStrings[DOMString(AttrName)] := DOMString(VarToStr(Value));
end;

function TXMLNodeEh.GetAttribute(const AttrName: String): OleVariant;
begin
  Result := FDOMElement.AttribStrings[DOMString(AttrName)];
end;

function TXMLNodeEh.GetChildNodes: IXMLNodeList;
begin
  Result := TXMLNodeListEh.Create(FDOMElement);
end;

function TXMLNodeEh.GetText: String;
begin
  Result := String(FDOMElement.TextContent);
end;

procedure TXMLNodeEh.SetText(const Value: String);
begin
  FDOMElement.TextContent := DOMString(Value);
end;

function TXMLNodeEh.GetObject: TObject;
begin
  Result := Self;
end;

function TXMLNodeEh.GetNodeName: String;
begin
  Result := String(FDOMElement.TagName);
end;

function  TXMLNodeEh.GetNodeValue: String;
begin
  Result := GetText;
end;

procedure TXMLNodeEh.SetNodeValue(const AValue: String);
begin
  SetText(AValue);
end;

procedure TXMLNodeEh.DeclareNamespace(const Prefix, URI: String);
begin
  SetAttribute('xmlns', URI);
end;

{ TXMLNodeListEh }

constructor TXMLNodeListEh.Create(ADOMElement: TDOMElement);
begin
  FDOMElement := ADOMElement;
end;

destructor TXMLNodeListEh.Destroy;
begin
  inherited Destroy;
end;

function TXMLNodeListEh.GetCount: Integer;
begin
  Result := FDOMElement.ChildNodes.Count;
end;

function TXMLNodeListEh.Add(const Node: IXMLNode): Integer;
var
  RefObj: IRefObject;
  Obj: TObject;
  SysNode: TXMLNodeEh;
begin
  RefObj := Node as IRefObject;
  Obj := RefObj.GetObject();
  SysNode := Obj as TXMLNodeEh;
  FDOMElement.AppendChild(SysNode.FDOMElement);
  Result := -1;
end;

function TXMLNodeListEh.FindNode(NodeName: String): IXMLNode;
var
  de: TDOMElement;
begin
  de := FDOMElement.FindNode(DOMString(NodeName)) as TDOMElement;
  if (de <> nil) then
    Result := TXMLNodeEh.Create(de)
  else
    Result := nil;
end;

function TXMLNodeListEh.Delete(const Name: String): Integer;
var
  de: TDOMElement;
begin
  de := FDOMElement.FindNode(DOMString(Name)) as TDOMElement;
  FDOMElement.RemoveChild(de);
  Result := -1;
end;

procedure TXMLNodeListEh.Insert(Index: Integer; const Node: IXMLNode);
var
  RefObj: IRefObject;
  Obj: TObject;
  SysNode: TXMLNodeEh;
  PosNode: TDOMNode;
begin
  RefObj := Node as IRefObject;
  Obj := RefObj.GetObject();
  SysNode := Obj as TXMLNodeEh;

  PosNode := FDOMElement.ChildNodes[Index];
  FDOMElement.InsertBefore(SysNode.FDOMElement, PosNode);
end;

function TXMLNodeListEh.GetNode(const IndexOrName: OleVariant): IXMLNode;
var
  idx: Integer;
  de: TDOMElement;
begin
  if (VarIsNumeric(IndexOrName)) then
  begin
    idx := Integer(IndexOrName);
    de := FDOMElement.ChildNodes[idx] as TDOMElement;
    Result := TXMLNodeEh.Create(de);
  end else
  begin
    Result := FindNode(String(IndexOrName));
  end;
end;

{ NewXMLDocument }

function NewXMLDocument(Version: DOMString = '1.0'): IXMLDocument;
begin
  Result := TXMLDocumentEh.Create;
end;

procedure GetRGB(Col: TColor; var R, G, B: Byte);
var
  ColorRec: TColorRec;
begin
  ColorRec.Color := ColorToRGB(Col);
  R := ColorRec.R;
  G := ColorRec.G;
  B := ColorRec.B;
end;

function RGBToColorEh(R, G, B: Byte): TColor;
var
  ColorRec: TColorRec;
begin
  ColorRec.R := R;
  ColorRec.G := G;
  ColorRec.B := B;
  ColorRec.A := 0;
  Result := ColorRec.Color;
end;

{$ELSE} 

procedure GetRGB(Col: TColor; var R, G, B: Byte);
{$IFDEF EH_LIB_17} 
var
  ColorRec: TColorRec;
begin
  ColorRec.Color := ColorToRGB(Col);
  R := ColorRec.R;
  G := ColorRec.G;
  B := ColorRec.B;
end;
{$ELSE}
begin
  Col := ColorToRGB(Col);
  R := GetRValue(Col);
  G := GetGValue(Col);
  B := GetBValue(Col);
end;
{$ENDIF}

function RGBToColorEh(R, G, B: Byte): TColor;
{$IFDEF EH_LIB_17} 
var
  ColorRec: TColorRec;
begin
  ColorRec.R := R;
  ColorRec.G := G;
  ColorRec.B := B;
  ColorRec.A := 0;
  Result := ColorRec.Color;
end;
{$ELSE}
begin
  Result := RGB(R, G, B);
end;
{$ENDIF}


{$IFNDEF EH_LIB_17}  

{ TFormatSettingsProxyEh }

function TFormatSettingsProxyEh.GetTwoDigitYearCenturyWindow: Word;
begin
{$IFDEF EH_LIB_14} //XE
    Result := SysUtils.FormatSettings.TwoDigitYearCenturyWindow;
{$ELSE}
    Result := SysUtils.TwoDigitYearCenturyWindow;
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetTwoDigitYearCenturyWindow(Value: Word);
begin
{$IFDEF EH_LIB_14} //XE
    SysUtils.FormatSettings.TwoDigitYearCenturyWindow := Value;
{$ELSE}
    SysUtils.TwoDigitYearCenturyWindow := Value;
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetShortMonthNames(Index : Integer) : String;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.ShortMonthNames[Index];
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.ShortMonthNames[Index];
  {$ELSE}
  Result := SysUtils.ShortMonthNames[Index];
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetShortMonthNames(Index: Integer; Value: String);
begin
{$IFDEF EH_LIB_14} //XE
    SysUtils.FormatSettings.ShortMonthNames[Index] := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.ShortMonthNames[Index] := Value;
  {$ELSE}
  SysUtils.ShortMonthNames[Index] := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetLongMonthNames(Index : Integer) : String;
begin
{$IFDEF EH_LIB_14} //XE
    Result := SysUtils.FormatSettings.LongMonthNames[Index];
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.LongMonthNames[Index];
  {$ELSE}
  Result := SysUtils.LongMonthNames[Index];
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetLongMonthNames(Index: Integer; Value: String);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.LongMonthNames[Index] := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.LongMonthNames[Index] := Value;
  {$ELSE}
  SysUtils.LongMonthNames[Index] := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetShortDayNames(Index : Integer) : String;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.ShortDayNames[Index];
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.ShortDayNames[Index];
  {$ELSE}
  Result := SysUtils.ShortDayNames[Index];
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetShortDayNames(Index: Integer; Value: String);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.ShortDayNames[Index] := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.ShortDayNames[Index] := Value;
  {$ELSE}
  SysUtils.ShortDayNames[Index] := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetlongDayNames(Index : Integer) : String;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.longDayNames[Index];
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.LongDayNames[Index];
  {$ELSE}
  Result := SysUtils.LongDayNames[Index];
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetlongDayNames(Index: Integer; Value: String);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.longDayNames[Index] := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.LongDayNames[Index] := Value;
  {$ELSE}
  SysUtils.LongDayNames[Index] := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetDecimalSeparator: Char;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.DecimalSeparator;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.DecimalSeparator;
  {$ELSE}
  Result := SysUtils.DecimalSeparator;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetDecimalSeparator(Value: Char);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.DecimalSeparator := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.DecimalSeparator := Value;
  {$ELSE}
  SysUtils.DecimalSeparator := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetDateSeparator: Char;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.DateSeparator;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.DateSeparator;
  {$ELSE}
  Result := SysUtils.DateSeparator;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetDateSeparator(Value: Char);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.DateSeparator := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.DateSeparator := Value;
  {$ELSE}
  SysUtils.DateSeparator := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetTimeSeparator: Char;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.TimeSeparator;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.TimeSeparator;
  {$ELSE}
  Result := SysUtils.TimeSeparator;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetTimeSeparator(Value: Char);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.TimeSeparator := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.TimeSeparator := Value;
  {$ELSE}
  SysUtils.TimeSeparator := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetThousandSeparator: Char;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.ThousandSeparator;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.ThousandSeparator;
  {$ELSE}
  Result := SysUtils.ThousandSeparator;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetThousandSeparator(Value: Char);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.ThousandSeparator := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.ThousandSeparator := Value;
  {$ELSE}
  SysUtils.ThousandSeparator := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetShortDateFormat: String;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.ShortDateFormat;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.ShortDateFormat;
  {$ELSE}
  Result := SysUtils.ShortDateFormat;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetShortDateFormat(Value: String);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.ShortDateFormat := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.ShortDateFormat := Value;
  {$ELSE}
  SysUtils.ShortDateFormat := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetLongDateFormat: String;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.LongDateFormat;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.LongDateFormat;
  {$ELSE}
  Result := SysUtils.LongDateFormat;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetLongDateFormat(Value: String);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.LongDateFormat := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.LongDateFormat := Value;
  {$ELSE}
  SysUtils.LongDateFormat := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetLongTimeFormat: String;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.LongTimeFormat;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.LongTimeFormat;
  {$ELSE}
  Result := SysUtils.LongTimeFormat;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetLongTimeFormat(Value: String);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.LongTimeFormat := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.LongTimeFormat := Value;
  {$ELSE}
  SysUtils.LongTimeFormat := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetCurrencyDecimals: Byte;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.CurrencyDecimals;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.CurrencyDecimals;
  {$ELSE}
  Result := SysUtils.CurrencyDecimals;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetCurrencyDecimals(Value: Byte);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.CurrencyDecimals:= Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.CurrencyDecimals := Value;
  {$ELSE}
  SysUtils.CurrencyDecimals := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetShortTimeFormat: String;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.ShortTimeFormat;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.ShortTimeFormat;
  {$ELSE}
  Result := SysUtils.ShortTimeFormat;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetShortTimeFormat(const Value: String);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.ShortTimeFormat := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.ShortTimeFormat := Value;
  {$ELSE}
  SysUtils.ShortTimeFormat := Value;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetTimeAMString: String;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.TimeAMString;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.TimeAMString;
  {$ELSE}
  Result := SysUtils.TimeAMString;
  {$ENDIF}
{$ENDIF}
end;

function TFormatSettingsProxyEh.GetTimePMString: String;
begin
{$IFDEF EH_LIB_14} //XE
  Result := SysUtils.FormatSettings.TimePMString;
{$ELSE}
  {$IFDEF FPC}
  Result := DefaultFormatSettings.TimePMString;
  {$ELSE}
  Result := SysUtils.TimePMString;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetTimeAMString(const Value: String);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.TimeAMString := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.TimeAMString := Value;
  {$ELSE}
  SysUtils.TimeAMString := Value;
  {$ENDIF}
{$ENDIF}
end;

procedure TFormatSettingsProxyEh.SetTimePMString(const Value: String);
begin
{$IFDEF EH_LIB_14} //XE
  SysUtils.FormatSettings.TimePMString := Value;
{$ELSE}
  {$IFDEF FPC}
  DefaultFormatSettings.TimePMString := Value;
  {$ELSE}
  SysUtils.TimePMString := Value;
  {$ENDIF}
{$ENDIF}
end;

{ FormatSettingsEh }

var
  FFormatSettings: TFormatSettingsProxyEh;

function FormatSettings: TFormatSettingsProxyEh;
begin
  if FFormatSettings = nil then
    FFormatSettings := TFormatSettingsProxyEh.Create;
  Result := FFormatSettings;
end;

{$ENDIF} 

{$ENDIF} 

function ColorToRGB(Color: TColor): Longint;
begin
  Result := ColorToRGBProc(Color);
end;

procedure FreeObjectEh(obj: TObject);
begin
{$IFDEF NEXTGEN}
{$ELSE}
  obj.Free;
{$ENDIF}
end;

procedure DoNothing();
begin
  
end;

function CharInSetEh(C: Char; const CharSet: TSysCharSet): Boolean;
begin
{$IFDEF EH_LIB_12}
  Result := CharInSet(C, CharSet);
{$ELSE}
  Result := C in CharSet;
{$ENDIF}
end;

function StringSearch(const SubStr, S: string; CaseInsensitive: Boolean;
  WholeWord: Boolean; Offset: Integer = 1): Integer;
var
  S1, SubStr1: String;
  NewOffset, HalfResult: Integer;
  BefC, AfC: Char;
  S1Len, SubStr1Len: Integer;
  BefDelOk, AfDelOk: Boolean;

  function FindChar(C: Char; S: String): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 1 to Length(S) do
      if S[i] = C then
      begin
        Result := i;
        Break;
      end;
  end;

begin
  if CaseInsensitive then
  begin
    S1 := AnsiUpperCase(S);
    SubStr1 := AnsiUpperCase(SubStr);
  end else
  begin
    S1 := S;
    SubStr1 := SubStr;
  end;

  if WholeWord = False then
    Result := PosEx(SubStr1, S1, Offset)
  else
  begin
    S1Len := Length(S1);
    SubStr1Len := Length(SubStr1);
    NewOffset := Offset;
    while True do
    begin
      HalfResult := PosEx(SubStr1, S1, NewOffset);
      if HalfResult = 0 then
      begin
        Result := 0;
        Exit;
      end;
      if HalfResult = 1
        then BefC := #0
        else BefC := S1[HalfResult-1];
      if HalfResult + SubStr1Len - 1 = S1Len
        then AfC := #0
        else AfC := S1[HalfResult + SubStr1Len];
      if (BefC = #0) or (FindChar(BefC, WordDelimitersEh) > 0)
        then BefDelOk := True
        else BefDelOk := False;
      if (AfC = #0) or (FindChar(AfC, WordDelimitersEh) > 0)
        then AfDelOk := True
        else AfDelOk := False;
      if BefDelOk and AfDelOk then
      begin
        Result := HalfResult;
        Exit;
      end else if AfC = #0 then
      begin
        Result := 0;
        Exit;
      end;
      NewOffset := NewOffset + SubStr1Len;
    end;
  end;
end;

function PropInfo_getPropType(APropInfo: PPropInfo): PTypeInfo;
begin
  {$IFDEF FPC}
  Result := APropInfo^.PropType;
  {$ELSE}
  Result := APropInfo^.PropType^;
  {$ENDIF}
end;

function PropInfo_getName(APropInfo: PPropInfo): String;
begin
{$IFDEF NEXTGEN}
  Result := GetPropName(APropInfo);
{$ELSE}
  Result := String(APropInfo^.Name);
{$ENDIF}
end;

function PropType_getKind(APropType: PTypeInfo): TTypeKind;
begin
  Result := APropType^.Kind;
end;

function GetEnumPropValueAsString(Instance: TObject; const PropName: string): String;
var
  PropInfo: PPropInfo;
  PropType: PTypeInfo;
  Value: Integer;
begin
  PropInfo := GetPropInfo(Instance, PropName);
  Value := GetOrdProp(Instance, PropInfo);
  PropType := PropInfo_getPropType(PropInfo);
  Result := GetEnumName(PropType, Value);
end;

procedure SetEnumPropValueAsString(Instance: TObject; const PropName: string; AValue: String);
var
  PropInfo: PPropInfo;
  PropType: PTypeInfo;
  Value: Integer;
begin
  PropInfo := GetPropInfo(Instance, PropName);
  PropType := PropInfo_getPropType(PropInfo);
  Value := GetEnumValue(PropType, AValue);
  SetOrdProp(Instance, PropInfo, Value);
end;

function GetClassPropertiesAsArray(ATypeInfo: TClass;
                                   TypeKinds: TTypeKinds = DefaultPropListTypeKinds;
                                    MemberVisibilities: TMemberVisibilities = DefaultPropListMemberVisibilities): TArray<TRttiProperty>;
var
  LType: TRttiType;
  AllProps: TArray<TRttiProperty>;
  ResultList: TList<TRttiProperty>;
  Prop: TRttiProperty;
  RttiContext: TRttiContext;
  i: Integer;
begin
  RttiContext := TRttiContext.Create;
  LType := RttiContext.GetType(ATypeInfo);
  AllProps := LType.GetProperties();
  ResultList := TList<TRttiProperty>.Create;
  for Prop in AllProps do
  begin
    if (Prop.PropertyType.TypeKind in TypeKinds) and
       (Prop.Visibility in MemberVisibilities) then
    begin
      ResultList.Add(Prop);
    end;
  end;
  SetLength(Result, ResultList.Count);
  for i := 0 to ResultList.Count - 1 do
    Result[i] := ResultList[i];

  ResultList.Free;
  RttiContext.Free;
end;

procedure VarArrayRedimEh(var A : Variant; HighBound: Integer);
begin
  VarArrayRedim(A, HighBound);
end;

function VarEquals(const V1, V2: Variant): Boolean;
var
  i: Integer;
begin
  Result := not (VarIsArray(V1) xor VarIsArray(V2));
  if not Result then Exit;
  Result := False;
  try
    if VarIsArray(V1) and VarIsArray(V2) and
      (VarArrayDimCount(V1) = VarArrayDimCount(V2)) and
      (VarArrayLowBound(V1, 1) = VarArrayLowBound(V2, 1)) and
      (VarArrayHighBound(V1, 1) = VarArrayHighBound(V2, 1))
    then
      for i := VarArrayLowBound(V1, 1) to VarArrayHighBound(V1, 1) do
      begin
        Result := V1[i] = V2[i];
        if not Result then Exit;
      end
    else
      begin
        Result := not (VarIsEmpty(V1) xor VarIsEmpty(V2));
        if not Result
          then Exit
          else Result := (V1 = V2);
      end;
  except
    Result := False;
  end;
end;

function IsVarTypeString(const AVarType: TVarType): Boolean;
begin
 if (AVarType = varOleStr) or
    (AVarType = varString) or
    (AVarType = varUString)
 then
   Result := True
 else
   Result := False;
end;

function VarIsStringType(const Value: Variant): Boolean;
begin
  Result := IsVarTypeString(VarType(Value));
end;

function VarIsNumericType(const Value: Variant): Boolean;
begin
  Result := IsVarTypeNumeric(VarType(Value));
end;

function IsVarTypeNumeric(const AVarType: TVarType): Boolean;
begin
 if (AVarType in [varSmallint, varInteger, varSingle, varDouble, varCurrency,
     varShortInt, varWord, varInt64, varLongWord, varUInt64,
      varByte
      ]) or (AVarType = VarFMTBcd)
  then
    Result := True
  else
    Result := False;
end;

function VarToAnsiStr(const V: Variant): AnsiString;
begin
  if not VarIsNull(V)
    then Result := AnsiString(V)
    else Result := AnsiString('');
end;

procedure VarSetNull(var V: Variant);
const
  varDeepData = $BFE8;
begin
  if (TVarData(V).VType and varDeepData) = 0 then
    TVarData(V).VType := varNull
  else
  begin
    VarClear(V);
    TVarData(V).VType := varNull;
  end;
end;

function VarIsNullEh(const V: Variant): Boolean;
begin
  Result := TVarData(V).VType = varNull;
end;

function TryVarToStr(const VarValue: Variant; var StrValue: String): Boolean;
var
  AVarType: TVarType;
begin
  AVarType := VarType(VarValue);
  if (AVarType = varDispatch) or (AVarType =  varUnknown) then
  begin
    StrValue := '<varDispatch>';
    Result := False;
  end else if (AVarType =  varUnknown) then
  begin
    StrValue := '<varUnknown>';
    Result := False;
  end else
  begin
    StrValue := VarToStr(VarValue);
    Result := True;
  end;
end;

function VarToStrEh(const V: Variant): String;
begin
  if VarType(V) =  varDate then
    Result := DateTimeToStr(V)
  else
    Result := VarToStr(V);
end;

function SysStrToVar(const Value: String; VarType: Word): Variant;
var
  OldDecimalSeparator: Char;
  OldDateSeparator: Char;
  OldShortDateFormat: String;
  OldTimeSeparator: Char;
  OldShortTimeFormat: String;
begin
  Result := Null;
  OldDecimalSeparator := FormatSettings.DecimalSeparator;
  OldDateSeparator := FormatSettings.DateSeparator;
  OldShortDateFormat := FormatSettings.ShortDateFormat;
  OldTimeSeparator := FormatSettings.TimeSeparator;
  OldShortTimeFormat := FormatSettings.ShortTimeFormat;

  FormatSettings.DecimalSeparator := '.';
  FormatSettings.DateSeparator := '-';
  FormatSettings.ShortDateFormat := 'YYYY/MM/DD';
  FormatSettings.TimeSeparator := ':';
  FormatSettings.ShortTimeFormat := 'HH:NN:SS';
  try
    VarCast(Result, Value, VarType);
  finally
    FormatSettings.DecimalSeparator := OldDecimalSeparator;
    FormatSettings.DateSeparator := OldDateSeparator;
    FormatSettings.ShortDateFormat := OldShortDateFormat;
    FormatSettings.TimeSeparator := OldTimeSeparator;
    FormatSettings.ShortTimeFormat := OldShortTimeFormat;
  end;
end;

function SysVarToStr(const Value: Variant): String;
var
  OldDecimalSeparator: Char;
  OldDateSeparator: Char;
  OldShortDateFormat: String;
  OldTimeSeparator: Char;
  OldShortTimeFormat: String;
begin
  OldDecimalSeparator := FormatSettings.DecimalSeparator;
  OldDateSeparator := FormatSettings.DateSeparator;
  OldShortDateFormat := FormatSettings.ShortDateFormat;
  OldTimeSeparator := FormatSettings.TimeSeparator;
  OldShortTimeFormat := FormatSettings.ShortTimeFormat;

  FormatSettings.DecimalSeparator := '.';
  FormatSettings.DateSeparator := '-';
  FormatSettings.ShortDateFormat := 'YYYY/MM/DD';
  FormatSettings.TimeSeparator := ':';
  FormatSettings.ShortTimeFormat := 'HH:NN:SS';
  try
    if VarType(Value) = varCurrency then
      Result := CurrToStr(Value)
    else if VarType(Value) = varDate then
      Result := DateTimeToStr(Value)
    else
      Result := VarToStr(Value);
  finally
    FormatSettings.DecimalSeparator := OldDecimalSeparator;
    FormatSettings.DateSeparator := OldDateSeparator;
    FormatSettings.ShortDateFormat := OldShortDateFormat;
    FormatSettings.TimeSeparator := OldTimeSeparator;
    FormatSettings.ShortTimeFormat := OldShortTimeFormat;
  end;
end;

function SysStrToFloat(const S: string): Extended;
var
  ASep: Char;
begin
  ASep := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    Result := StrToFloat(S);
  finally
    FormatSettings.DecimalSeparator := ASep;
  end;
end;

function SysFloatToStr(const Val: Extended): string;
var
  ASep: Char;
begin
  ASep := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    Result := FloatToStr(Val);
  finally
    FormatSettings.DecimalSeparator := ASep;
  end;
end;

function AnyVarToStrEh(const V: Variant): String;
var
  i: Integer;
begin
  Result := '';
  if VarIsArray(V) then
  begin
    for i := VarArrayLowBound(V, 1) to VarArrayHighBound(V, 1) do
    begin
      if Result = ''
        then Result := '['+AnyVarToStrEh(V[i])
        else Result := Result + ', ' + AnyVarToStrEh(V[i])
    end;
    Result := Result + ']';
  end else
    Result := VarToStr(V);
end;

function MiddleDotChar: Char;
begin
  {$IFDEF FPC}
  Result := '.';
  {$ELSE}
  Result := Char($B7);
  {$ENDIF}
end;

function NlsUpperCase(const S: String): String;
begin
  Result := AnsiUpperCase(S);
end;

function NlsLowerCase(const S: String): String;
begin
  Result := AnsiLowerCase(S);
end;

function NlsCompareStr(const S1, S2: String): Integer;
begin
  Result := AnsiCompareStr(S1, S2);
end;

function NlsCompareText(const S1, S2: String): Integer;
begin
  Result := AnsiCompareText(S1, S2);
end;

procedure TextDelete(var S: string; const Index: Integer; const Count: Integer);
begin
{$IFDEF FPC}
  UTF8Delete(S, Index, Count);
{$ELSE}
  Delete(S, Index, Count);
{$ENDIF}
end;

function TextCopy(S: String; Index: Integer; Count: Integer): string;
begin
{$IFDEF FPC}
  Result := UTF8Copy(S, Index, Count);
{$ELSE}
  Result := Copy(S, Index, Count);
{$ENDIF}
end;

function StrLength(s: String): Integer;
begin
{$IFDEF FPC}
  Result := UTF8Length(s);
{$ELSE}
  Result := Length(s);
{$ENDIF}
end;

function TextLength(s: String): Integer;
begin
  Result := StrLength(s);
end;

function FormatValue(const Format: string; const Value: TValue): String;
begin
{$IFDEF FPC}
  Result := ValueToString(Value);
{$ELSE}
  if (Value.Kind = TTypeKind.tkVariant) and (VarType(Value.AsVariant) = varDate) then
    Result := FormatDateTime(Format, Value.AsType<TDateTime>)
  else if Value.IsType<Double>() then
    Result := FormatFloat(Format, Value.AsType<Double>)
  else if Value.IsType<Int64>() then
    Result := FormatFloat(Format, Value.AsType<Int64>)
  else if Value.IsType<TBcd>() then
    Result := FormatBcd(Format, Value.AsType<TBcd>)
  else if Value.IsType<TSQLTimeStamp>() then
    Result := SQLTimeStampToStr(Format, Value.AsType<TSQLTimeStamp>)
  else if Value.IsEmpty then
    Result := ''
  else if ValueIsNullOrEmpty(Value) then
    Result := ''
  else
    Result := ValueToString(Value);
{$ENDIF}
end;

function ValueToString(const V: TValue): String;
begin
{$IFDEF FPC}
  Result := V.ToString();
{$ELSE}
  if V.IsType<String> then
    Result := V.AsType<String>
  else if (V.Kind = TTypeKind.tkVariant) and (VarIsNullEh(V.AsVariant)) then
    Result := ''
  else if V.IsType<TBcd>() then
    Result := BcdToStr(V.AsType<TBcd>)
  else if V.IsType<TSQLTimeStamp>() then
    Result := SQLTimeStampToStr('', V.AsType<TSQLTimeStamp>)
  else
    Result := V.ToString();
{$ENDIF}
end;

function ValueIsStringType(const V: TValue): Boolean;
begin
  if (V.Kind = tkString) then
    Result := True
{$IFDEF FPC}
{$ELSE}
  else if (V.Kind = TTypeKind.tkVariant) and (IsVarTypeString(VarType(V.AsVariant))) then
    Result := True
{$ENDIF}
  else
    Result := False;
end;

function RttiValueToVariantValue(const V: TValue): Variant;
begin
{$IFDEF FPC}
  case V.Kind of
    tkInteger:   Result := V.AsInteger;
    tkInt64:     Result := V.AsInt64;
    tkFloat:     Result := V.AsExtended;
    tkChar:      Result := V.AsString;
    tkString,
    tkLString,
    tkUString,
    tkWString:   Result := V.AsString;
    tkEnumeration: Result := V.AsOrdinal;
    tkSet:         Result := V.AsOrdinal;
  else
    raise Exception.CreateFmt('Cannot convert TValue of kind %s to Variant',
      [GetEnumName(TypeInfo(TTypeKind), Ord(V.Kind))]);
  end;
{$ELSE}
  Result := V.AsVariant;
{$ENDIF}
end;

function CastValueToBcdValue(const Value: TValue): TValue;
begin
  Result := TValue.From<TBcd>(CastValueToBcd(Value));
end;

function CastValueToBcd(const Value: TValue): TBcd;
{$IFDEF FPC}
begin
  Result := StrToBcd(Value.ToString());
end;
{$ELSE}
  function IsNumeric(): Boolean;
  begin
    Result := Value.Kind in [tkInteger, tkChar, tkEnumeration, tkFloat, tkWChar, tkInt64];
  end;

begin
{$IFDEF EH_LIB_28} 
  if Value.IsType<Double>() then
    Result := DoubleToBcd(Value.AsType<Double>)
  else if Value.IsType<TBcd>() then
    Result := Value.AsType<TBcd>
   else
{$ELSE}
{$ENDIF} 
        if Value.IsEmpty then
    Result := IntegerToBcd(0)
  else if ValueIsNullOrEmpty(Value) then
    Result := IntegerToBcd(0)
  else
    Result := StrToBcd(Value.ToString());
end;
{$ENDIF}

//function CanCastValueToBcd(const Value: TValue): Boolean;
//{$IFDEF FPC}
//begin
//  Result := False;
//end;
//{$ELSE}
//begin
//{$IFDEF EH_LIB_28} 
//  if Value.IsType<Double>() then
//    Result := True
//  else if Value.IsType<TBcd>() then
//    Result := True
//   else
//{$ELSE}
//{$ENDIF} 
//    Result := False;
//end;
//{$ENDIF}

function ValueIsNumeric(const Value: TValue): Boolean;
{$IFDEF FPC}
begin
  Result := IsTypeNumeric(Value.TypeInfo);
end;
{$ELSE}
begin
  if Value.TypeInfo = TypeInfo(Variant) then
  begin
    Result := VarIsNumericType(Value.AsVariant)
  end else
  begin
    Result := IsTypeNumeric(Value.TypeInfo);
  end;
end;
{$ENDIF}

function IsTypeNumeric(const ATypeInfo: PTypeInfo): Boolean;
begin
  if ATypeInfo = nil then
    Result := False
  else if (ATypeInfo.Kind in [tkInteger, tkFloat, tkInt64]) or (ATypeInfo = TypeInfo(TBcd)) then
    Result := True
  else
    Result := False;
end;

function ValueToInteger(const V: TValue; OnEmptyValue: Integer = 0): Integer;
{$IFDEF FPC}
begin
  Result := V.AsInteger();
end;
{$ELSE}
var
  VarValue: Variant;
begin
  if V.IsEmpty then
    Result := OnEmptyValue
  else if (V.Kind = TTypeKind.tkVariant) and (VarIsNullEh(V.AsVariant)) then
    Result := OnEmptyValue
  else if (V.Kind = TTypeKind.tkVariant) then
  begin
    VarCast(VarValue, V.AsVariant, varInteger);
    Result := Integer(VarValue);
  end else if V.IsType<Integer> then
    Result := V.AsType<Integer>
  else if V.IsType<TBcd>() then
    Result := BcdToInteger(V.AsType<TBcd>)
  else
    Result := V.AsInteger();
end;
{$ENDIF}

function ValueToInt64(const V: TValue; OnEmptyValue: Int64 = 0): Int64;
{$IFDEF FPC}
begin
  Result := V.AsInteger();
end;
{$ELSE}
var
  VarValue: Variant;
begin
  if V.IsEmpty then
    Result := OnEmptyValue
  else if (V.Kind = TTypeKind.tkVariant) and (VarIsNullEh(V.AsVariant)) then
    Result := OnEmptyValue
  else if (V.Kind = TTypeKind.tkVariant) then
  begin
    VarCast(VarValue, V.AsVariant, varInt64);
{$IFDEF EH_LIB_16} 
    Result := Int64(VarValue);
{$ELSE} 
    Result := VarValue;
{$ENDIF}
  end
  else if V.IsType<Int64> then
    Result := V.AsType<Int64>
  else if V.IsType<Integer> then
    Result := V.AsType<Integer>
  else if V.IsType<TBcd>() then
    Result := BcdToInteger(V.AsType<TBcd>)
  else
    Result := V.AsInteger();
end;
{$ENDIF}

function ValueToUInt64(const V: TValue; OnEmptyValue: UInt64 = 0): UInt64;
{$IFDEF FPC}
begin
  Result := V.AsInteger();
end;
{$ELSE}
var
  VarValue: Variant;
begin
  if V.IsEmpty then
    Result := OnEmptyValue
  else if (V.Kind = TTypeKind.tkVariant) and (VarIsNullEh(V.AsVariant)) then
    Result := OnEmptyValue
  else if (V.Kind = TTypeKind.tkVariant) then
  begin
    VarCast(VarValue, V.AsVariant, varUInt64);
{$IFDEF EH_LIB_16} 
    Result := UInt64(VarValue);
{$ELSE} 
    Result := VarValue;
{$ENDIF}
  end
  else if V.IsType<Int64> then
    Result := V.AsType<Int64>
  else if V.IsType<Integer> then
    Result := V.AsType<Integer>
  else if V.IsType<TBcd>() then
    Result := BcdToInteger(V.AsType<TBcd>)
  else
    Result := V.AsInteger();
end;
{$ENDIF}

function ValueIsArrayOfValues(const V: TValue): Boolean;
begin
  Result := V.TypeInfo = TypeInfo(TArray<TValue>);
end;

function ValueIsNullOrEmpty(const V: TValue): Boolean;
{$IFDEF FPC}
begin
  Result := False;
end;
{$ELSE}
var
  VarV: Variant;
begin
  if (V.TypeInfo = TypeInfo(Variant)) then
  begin
    VarV := V.AsVariant;
    if VarIsNullEh(VarV) then
      Result := True
    else if VarIsEmpty(VarV) then
      Result := True
    else if (VarIsStringType(VarV) and (VarV = '')) then
      Result := True
    else
      Result := False;
  end
  else if V.IsEmpty then
    Result := True
  else if (V.Kind in [tkString, tkLString, tkWString, tkUString]) and (V.AsString = '') then
    Result := True
  else
    Result := False;
end;
{$ENDIF}

function CastSameValue(const A, B: TValue): Boolean;
begin
  if (ValueIsNullOrEmpty(A) = True) and (ValueIsNullOrEmpty(B) = True) then
    Result := True
  else if ValueIsNullOrEmpty(A) <> ValueIsNullOrEmpty(B) then
    Result := False
  else
    Result := SameValue(A, B);
end;

function SameValue(const A, B: TValue): Boolean;
begin
  Result := CompareValue(A, B) = TVariantRelationship.vrEqual;
end;

var
  Context: TRttiContext;

function CompareValue(const A, B: TValue): TVariantRelationship;
{$IFDEF FPC}
begin
  Result := TVariantRelationship.vrNotEqual;
end;
{$ELSE}
const
  EmptyResults: array[Boolean, Boolean] of TVariantRelationship =
    ((TVariantRelationship.vrEqual, TVariantRelationship.vrLessThan),
     (TVariantRelationship.vrGreaterThan, TVariantRelationship.vrEqual));

  function ValRelToVarRel(RelValue: Integer): TVariantRelationship;
  begin
    if RelValue < 0 then Result := TVariantRelationship.vrLessThan
    else if RelValue > 0 then Result := TVariantRelationship.vrGreaterThan
    else Result := TVariantRelationship.vrEqual;
  end;

  function ValIsString(const V: TValue): Boolean;
  begin
   if (V.Kind in [tkChar, tkString, tkWChar, tkLString, tkWString, tkUString]) then
     Result := True
   else if (V.Kind in [tkVariant]) and (VarIsStringType(V.AsType<Variant>)) then
     Result := True
   else
     Result := False;
  end;

  function ValToString(const V: TValue): String;
  begin
    Result := V.AsType<String>();
  end;

  function GetRttiType(const V: TValue): TRttiType;
  begin
     Result := Context.GetType(V.TypeInfo);
  end;

  function TryGetMethod(const VT: TRttiType; const AName: string; out AMethod: TRttiMethod): Boolean;
  begin
    AMethod := VT.GetMethod(AName);
    Result := Assigned(AMethod);
  end;

  function CompareValue_Record(const Left, Right: TValue): Integer;
  var
    LMethod: TRttiMethod;
  begin
    if TryGetMethod(GetRttiType(Left), '&op_Equality', LMethod) then
    begin
      if LMethod.Invoke(nil, [Left, Right]).AsBoolean then
        Result := 0
      else
        Result := -1;
    end else
      Result := 0;
  end;

  function CompareValue_Array(const Left, Right: TValue): TVariantRelationship;
  var
    i: Integer;
  begin
    if Left.GetArrayLength <> Right.GetArrayLength then Exit(TVariantRelationship.vrNotEqual);

    for i := 0 to Left.GetArrayLength - 1 do
    begin
      Result := CompareValue(Left.GetArrayElement(i), Right.GetArrayElement(i));
      if Result <> TVariantRelationship.vrEqual then
        Exit(Result);
    end;

    Result := TVariantRelationship.vrEqual;
  end;

  function TryValueToVariant(const Value: TValue): Variant;
  begin
    Result := Unassigned;
    if Value.TypeInfo = TypeInfo(Boolean) then
      Result := Value.AsBoolean
    else if Value.IsOrdinal then
      Result := Value.AsOrdinal
    else if (Value.Kind = tkFloat) then
      Result := Value.AsExtended
    else if (Value.TypeInfo = TypeInfo(TBcd)) then
      Result := VarFMTBcdCreate(Value.AsType<TBcd>);
  end;

var
  leftIsEmpty, rightIsEmpty: Boolean;
  BAsVrnt, AAsVrnt: Variant;
begin
  leftIsEmpty := A.IsEmpty;
  rightIsEmpty := B.IsEmpty;
  if leftIsEmpty or rightIsEmpty then
    Result := EmptyResults[leftIsEmpty, rightIsEmpty]
  else if A.IsOrdinal and B.IsOrdinal then
    Result := ValRelToVarRel(Math.CompareValue(A.AsOrdinal, B.AsOrdinal))
  else if (A.Kind = tkFloat) and (B.Kind = tkFloat) then
    Result := ValRelToVarRel(Math.CompareValue(A.AsExtended, B.AsExtended))
  else if ValIsString(A) and ValIsString(B) then
    Result := ValRelToVarRel(SysUtils.AnsiCompareStr(ValToString(A), ValToString(B)))
  else if A.IsObject and B.IsObject then
  begin
    if A.AsObject = B.AsObject then
      Result := TVariantRelationship.vrEqual
    else
      Result := TVariantRelationship.vrNotEqual;
  end else if (A.Kind = tkInterface) and (B.Kind = tkInterface) then
  begin
    if A.AsInterface = B.AsInterface then
      Result := TVariantRelationship.vrEqual
    else
      Result := TVariantRelationship.vrNotEqual;
  end else if (A.Kind = tkRecord) and (B.Kind = tkRecord) then
    Result := ValRelToVarRel(CompareValue_Record(A, B))
  else if A.IsArray and B.IsArray then
    Result := CompareValue_Array(A, B)
  else if (A.TypeInfo = System.TypeInfo(Variant)) and
          (B.TypeInfo = System.TypeInfo(Variant)) then
  begin
    Result := DBVarCompareValue(A.AsVariant, B.AsVariant);
  end
  else if (A.TypeInfo = System.TypeInfo(Variant)) then
  begin
    BAsVrnt := TryValueToVariant(B);
    Result := DBVarCompareValue(A.AsVariant, BAsVrnt);
  end
  else if (B.TypeInfo = System.TypeInfo(Variant)) then
  begin
    AAsVrnt := TryValueToVariant(A);
    Result := DBVarCompareValue(AAsVrnt, B.AsVariant);
  end else
    Result := TVariantRelationship.vrNotEqual;
end;
{$ENDIF}

function VarCompareValueWithString(const Data1, Data2: Variant): TVariantRelationship;
var
  vt1, vt2: TVarType;
  s1, s2: String;
  r: Integer;
begin
  vt1 := VarType(Data1);
  vt2 := VarType(Data2);
  if ((vt1 = varString) and (vt2 = varString)) or
{$IFDEF EH_LIB_12}
     ((vt1 = varUString) and (vt2 = varUString)) or
{$ENDIF}
     ((vt1 = varOleStr) and (vt2 = varOleStr))
  then
  begin
    s1 := VarToStr(Data1);
    s2 := VarToStr(Data2);
    r := AnsiCompareStr(s1,s2);
    if (r = 0) then
      Result := vrEqual
    else if  (r < 0) then
      Result := vrLessThan
    else
      Result := vrGreaterThan;
  end else
  begin
    Result := VarCompareValue(Data1, Data2);
  end;
end;

function DBVarCompareOneValue(const A, B: Variant): TVariantRelationship;
begin
  if VarIsNull(A) and VarIsNull(B) then
    Result := vrEqual
  else if VarIsNull(A) then
    Result := vrLessThan
  else if VarIsNull(B) then
    Result := vrGreaterThan
  else if (VarIsStringType(A) = True) and (A = '') and (VarIsStringType(B) = False) then
    Result := vrNotEqual
  else if (VarIsStringType(B) = True) and (B = '') and (VarIsStringType(A) = False) then
    Result := vrNotEqual
  else
    Result := VarCompareValueWithString(A, B);
end;

function DBVarCompareValue(const A, B: Variant): TVariantRelationship;
var
  i: Integer;
  IsComparable: Boolean;
begin
  Result := vrNotEqual;
  IsComparable := not (VarIsArray(A) xor VarIsArray(B));
  if not IsComparable then Exit;
  if VarIsArray(A) and VarIsArray(B) and
    (VarArrayDimCount(A) = VarArrayDimCount(B)) and
    (VarArrayLowBound(A, 1) = VarArrayLowBound(B, 1)) and
    (VarArrayHighBound(A, 1) = VarArrayHighBound(B, 1))
    then
    for i := VarArrayLowBound(A, 1) to VarArrayHighBound(A, 1) do
    begin
      Result := DBVarCompareOneValue(A[i], B[i]);
      if Result <> vrEqual then Exit;
    end
  else
    Result := DBVarCompareOneValue(A, B);
end;

type
  TInterfacedObjectWrapper = class(TInterfacedObject, IObjectRefInterface)
  private
    FRefObject: TObject;
    function GetObject: TObject;
  public
    constructor Create(ARefObject: TObject);

    property RefObject: TObject read FRefObject;
  end;

constructor TInterfacedObjectWrapper.Create(ARefObject: TObject);
begin
  FRefObject := ARefObject;
end;

function TInterfacedObjectWrapper.GetObject: TObject;
begin
  Result := FRefObject;
end;

function VariantToRefObject(VarValue: Variant): TObject;
var
  itfc: IInterface;
begin
  itfc := IInterface(VarValue);
  Result := (itfc as IObjectRefInterface).GetObject;
end;

function RefObjectToVariant(ARefObject: TObject): Variant;
var
  io: TInterfacedObject;
begin
  io := TInterfacedObjectWrapper.Create(ARefObject);
  Result := io as IInterface;
end;

function GetAllStrEntry(S, SubStr: String; var StartPoses: TIntegerDynArray;
  CaseInsensitive, WholeWord, StartOfString: Boolean): Boolean;
var
  Pos: Integer;
begin
  Pos := 1;
  SetLength(StartPoses, 0);
  if CaseInsensitive  then
  begin
    S := AnsiUpperCase(S);
    SubStr := AnsiUpperCase(SubStr);
  end;
  Result := False;
  while True do
  begin
    if CaseInsensitive
      then Pos := StringSearch(SubStr, S, True, WholeWord, Pos)
      else Pos := StringSearch(SubStr, S, False, WholeWord, Pos);
    if Pos = 0 then
    begin
      Result := Result or False;
      Exit;
    end;
    SetLength(StartPoses, Length(StartPoses)+1);
    StartPoses[Length(StartPoses)-1] := Pos-1;

    if StartOfString then
    begin
      if Pos = 1
        then Result := True
        else Result := False;
      Exit;
    end;

    Inc(Pos);
    Result := True;
  end;
end;

function IsLeadCharEh(C: Char): Boolean;
begin
{$IFDEF NEXTGEN}
  Result := IsLeadChar(C);
{$ELSE}
  Result := CharInSetEh(C, LeadBytes);
{$ENDIF}
end;

{$IFDEF FPC}
function WideStringCompare(const ws1, ws2: WideString; CharCount: Integer = 0; CaseInsensitive: Boolean = False): Integer;
begin
  Result := -1;
end;

function AnsiStringCompare(const s1, s2: String; CharCount: Integer = 0; CaseInsensitive: Boolean = False): Integer;
begin
  Result := -1;
end;
{$ELSE} 

function WideStringCompare(const ws1, ws2: WideString; CharCount: Integer = 0; CaseInsensitive: Boolean = False): Integer;
  {$IFDEF MSWINDOWS}
var
  dwCmpFlags: LongWord;
  cchCount: Integer;
begin
  if CaseInsensitive
    then dwCmpFlags := NORM_IGNORECASE
    else dwCmpFlags := 0;

  if CharCount = 0
    then cchCount := -1
    else cchCount := CharCount;

  Result := CompareStringW(LOCALE_USER_DEFAULT, dwCmpFlags, PWideChar(ws1),
      cchCount, PWideChar(ws2), cchCount) - 2;
end;
  {$ELSE}
begin
  Result := String.Compare(ws1, 0, ws2, 0, CharCount, CaseInsensitive);
end;
  {$ENDIF} 

function AnsiStringCompare(const s1, s2: String; CharCount: Integer = 0; CaseInsensitive: Boolean = False): Integer;
  {$IFDEF MSWINDOWS}
var
  dwCmpFlags: LongWord;
  cchCount: Integer;
begin
  if CaseInsensitive
    then dwCmpFlags := NORM_IGNORECASE
    else dwCmpFlags := 0;

  if CharCount = 0
    then cchCount := -1
    else cchCount := CharCount;

  Result := CompareString(LOCALE_USER_DEFAULT, dwCmpFlags, PChar(s1),
      cchCount, PChar(s2), cchCount) - 2;
end;
   {$ELSE}
begin
  Result := String.Compare(s1, 0, s2, 0, CharCount, CaseInsensitive);
end;
  {$ENDIF} 
{$ENDIF} 

function TruncDateTimeToSeconds(dt: TDateTime): TDateTime;
var
  AYear, AMonth, ADay,
  AHour, AMinute, ASecond, AMilliSecond: Word;
begin
  DecodeDateTime(dt, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
  Result := EncodeDateTime(AYear, AMonth, ADay, AHour, AMinute, ASecond, 0);
end;

function HexToBinEh(Text: Pointer; out Buffer: TBytes; CharCount: Integer): Integer;
begin
  SetLength(Buffer, 0);
  SetLength(Buffer, CharCount div 2);
{$IFDEF EH_LIB_22}
  Result := HexToBin(TBytes(Text), 0, TBytes(Buffer), 0, CharCount div 2);
{$ELSE}
  Result := HexToBin(PAnsiChar(Text), PAnsiChar(Buffer), CharCount div 2);
{$ENDIF}
end;

function HexToBinEh(Text: String; out Buffer: TBytes; CharCount: Integer): Integer; overload;
{$IFDEF NEXTGEN}
begin
  SetLength(Buffer, Count);
  Result := HexToBin(PWideChar(Text), 0, Buffer, 0, Count);
end;
{$ELSE}
var
  AnsString: AnsiString;
begin
  AnsString := AnsiString(Text);
  Result := HexToBinEh(Pointer(AnsString), Buffer, CharCount);
end;
{$ENDIF}

procedure BinToHexEh(Buffer: TBytes; out Text: String; Count: Integer);
{$IFDEF EH_LIB_22}
var
  aData, aBuff: TBytes;
begin
    SetLength(aBuff, Count * 2);
    BinToHex(aData, 0, aBuff, 0, Count);
    Text := StringOf(aBuff);
end;
{$ELSE}
var
  AnsiText: AnsiString;
begin
  System.SetString(AnsiText, nil, Count*2);
  BinToHex(PAnsiChar(Buffer), PAnsiChar(AnsiText), Count);
  Text := String(AnsiText);
end;
{$ENDIF}

function EmptyRect: TRect;
begin
  Result := Classes.Rect(0, 0, 0, 0);
end;

function CenterRect(const SourceRect: TRect; const ACenteredRect: TRect): TRect;
var
  Width, Height: Integer;
  X, Y: Integer;
begin
  Width := ACenteredRect.Right - ACenteredRect.Left;
  Height := ACenteredRect.Bottom - ACenteredRect.Top;
  X := (SourceRect.Right + SourceRect.Left) div 2;
  Y := (SourceRect.Top + SourceRect.Bottom) div 2;
  Result := Classes.Rect(X - Width div 2, Y - Height div 2, X + (Width + 1) div 2, Y + (Height + 1) div 2);
end;

function IsObjectAndIntegerRefSame(AObject: TObject; IntRef: IntPtr): Boolean;
begin
  Result := (IntPtr(AObject) = IntRef);
end;

function IntPtrToObject(AIntPtr: IntPtr): TObject;
begin
  Result := TObject(AIntPtr);
end;

function ObjectToIntPtr(AObject: TObject): IntPtr;
begin
  Result := IntPtr(AObject);
end;

function IntPtrToString(AIntPtr: IntPtr): String;
begin
{$WARNINGS OFF}
{$HINTS OFF}
  Result := String(PChar(AIntPtr));
{$HINTS ON}
{$WARNINGS ON}
end;

function GetTickCountEh: UInt64;
begin
{$IFDEF FPC}
  Result := UInt64(GetTickCount64);
{$ELSE}
    {$IFDEF EH_LIB_28} 
  Result := TThread.GetTickCount64;
    {$ELSE}
      {$IFDEF MSWINDOWS}
  Result := UInt64(GetTickCount);
      {$ELSE}
  Result := UInt64(TThread.GetTickCount);
      {$ENDIF}
    {$ENDIF} 
{$ENDIF}
end;

function GetEhLibSysDelphiCompilerInfo(): String;
begin
{$IFDEF FPC}
  Result := 'Lazarus: ' + laz_version;
{$ELSE}
  {$IFDEF EH_LIB_29} 
  if RTLVersion = 36 then
  begin
    Result := 'RADStudio 12.0, RTLVersion = ' + GetRTLVersion.ToString +
      ', CompilerVersion = ' + GetCompilerVersion.ToString;
  end;
  {$ENDIF} 
  if RTLVersion = 35 then
  begin
    Result := 'RADStudio 11.0';
    {$IF Declared(RTLVersion111)}
    Result := 'RADStudio 11.1';
    {$IFEND}
    {$IF Declared(RTLVersion112)}
    Result := 'RADStudio 11.2';
    {$IFEND}
    {$IF Declared(RTLVersion113)}
    Result := 'RADStudio 11.3';
    {$IFEND}
  end;
  if RTLVersion = 34 then
  begin
    Result := 'RADStudio 10.4 Sydney';
  end;
  if RTLVersion = 33 then
  begin
    Result := 'RADStudio 10.3 Rio';
  end;
  if RTLVersion = 32 then
  begin
    Result := 'RADStudio 10.2 Tokyo';
  end;
  if RTLVersion = 31 then
  begin
    Result := 'RADStudio 10.1 Berlin';
  end;
  if RTLVersion = 30 then
  begin
    Result := 'Delphi 10 Seattle';
  end;
  if RTLVersion = 29 then
  begin
    Result := 'Delphi XE8';
  end;
  if RTLVersion = 28 then
  begin
    Result := 'Delphi XE7';
  end;
  if RTLVersion = 27 then
  begin
    Result := 'Delphi XE6';
  end;
  if RTLVersion = 26 then
  begin
    Result := 'Delphi XE5';
  end;
  if RTLVersion = 25 then
  begin
    Result := 'Delphi XE4';
  end;
  if RTLVersion = 24 then
  begin
    Result := 'Delphi XE3';
  end;
  if RTLVersion = 23 then
  begin
    Result := 'Delphi XE2';
  end;
  if RTLVersion = 22 then
  begin
    Result := 'Delphi XE';
  end;
  if RTLVersion = 21 then
  begin
    Result := 'Delphi 2010';
  end;
  if RTLVersion = 20 then
  begin
    Result := 'Delphi 2009';
  end;
  {$ENDIF}
end;

function GetEhLibSysRTLVersionInfo(): String;
begin
  {$IFDEF FPC}
  Result := '';
  {$ELSE}
  Result := FormatFloat('#.00', RTLVersion);
  {$ENDIF}
end;

function GetEhLibSysCompilerVersion: String;
begin
  {$IFDEF FPC}
  Result := '';
  {$ELSE}
  Result := FormatFloat('#.00', CompilerVersion);
  {$ENDIF}
end;

{$IFDEF FPC}
function GetCompiledTargetCPU: string;
begin
  Result := LowerCase({$I %FPCTARGETCPU%});
end;

function GetCompiledTargetOS: string;
begin
  Result := LowerCase({$I %FPCTARGETOS%});
end;
{$ENDIF}

function GetEhLibSysDelphiPlatformInfo(): String;
begin
Result := '';
{$IFDEF IOS32} Result := 'IOS32'; {$ENDIF}
{$IFDEF IOS64} Result := 'IOS64'; {$ENDIF}
{$IFDEF WIN32} Result := 'WIN32'; {$ENDIF}
{$IFDEF WIN64} Result := 'WIN64'; {$ENDIF}
{$IFDEF MACOS32} Result := 'MACOS32'; {$ENDIF}
{$IFDEF MACOS64} Result := 'MACOS64'; {$ENDIF}
{$IFDEF LINUX32} Result := 'LINUX32'; {$ENDIF}
{$IFDEF LINUX64} Result := 'LINUX64'; {$ENDIF}
{$IFDEF ANDROID32} Result := 'ANDROID32'; {$ENDIF}

{$IFDEF FPC}
Result := Result + ' - ' +
  GetCompiledTargetCPU + '-' +
  GetCompiledTargetOS + '-' +
  LCLPlatformDisplayNames[GetDefaultLCLWidgetType];
{$ENDIF}
end;

type
  TOSInfo = record
    Kernel: String;
    OSName: String;
    OSVersion: String;
    Architecture: String;
  end;

function GetOSInfo: TOSInfo;
{$IFDEF CROSSVCL}
begin
  Result.Kernel := '';
  {$IFDEF EH_LIB_16} 
  Result.OSName := TOSVersion.ToString;
  {$ELSE}
  Result.OSName := 'Windows';
  {$ENDIF}
  Result.OSVersion := '';
  Result.Architecture := '';
end;
{$ELSE}

{$IFDEF FPC}
{$IFDEF LINUX} 
var
  P: TProcess;

  function ExecParam(Param: String): String;
  begin
    P.Parameters[0] := '-' + Param;
    P.Execute;
    SetLength(Result, 1000);
    SetLength(Result, P.Output.Read(Result[1], Length(Result)));
    while (Length(Result) > 0) and
          (Result[Length(Result)] in [#8..#13,#32]) do
    begin
      SetLength(Result, Length(Result) - 1);
    end;
  end;
begin
  P:= TProcess.Create(Nil);
  P.Options:= [poWaitOnExit, poUsePipes];
  P.Executable:= 'uname';
  P.Parameters.Add('');

  Result.Kernel := ExecParam('s') + ' ' + ExecParam('r');
  Result.OSName := ExecParam('o');
  Result.OSVersion := ExecParam('v');
  Result.Architecture := ExecParam('m');
  P.Free;
end;
{$ELSE} 
begin
  Result.Kernel := '';
  {$IFDEF EH_LIB_16} 
  Result.OSName := TOSVersion.ToString;
  {$ELSE}
  Result.OSName := 'Windows';
  {$ENDIF}
  Result.OSVersion := '';
  Result.Architecture := '';
end;
{$ENDIF} 
{$ELSE} 
begin
  Result.Kernel := '';
  {$IFDEF EH_LIB_16} 
  Result.OSName := TOSVersion.ToString;
  {$ELSE}
  Result.OSName := 'Windows';
  {$ENDIF}
  Result.OSVersion := '';
  Result.Architecture := '';
end;
{$ENDIF} 
{$ENDIF} 

function GetEhLibSysInfoAsString: String;
var
  OSInfo: TOSInfo;
begin
  Result := '';
  Result := Result + EhLibVerInfo + ' ' + EhLibBuildInfo + sLineBreak;
  Result := Result + GetEhLibSysDelphiCompilerInfo() + sLineBreak;
  Result := Result + 'Platform: ' + GetEhLibSysDelphiPlatformInfo() + sLineBreak;

  OSInfo := GetOSInfo;
  if (OSInfo.Kernel <> '') then
    Result := Result + 'OS.Kernel: ' + OSInfo.Kernel + sLineBreak;
  if (OSInfo.OSName <> '') then
    Result := Result + 'OS.OSName: ' + OSInfo.OSName + sLineBreak;
  if (OSInfo.OSVersion <> '') then
    Result := Result + 'OS.OSVersion: ' + OSInfo.OSVersion + sLineBreak;
  if (OSInfo.Architecture <> '') then
    Result := Result + 'OS.Architecture: ' + OSInfo.Architecture + sLineBreak;
end;

{ TObjectListEh }

constructor TObjectListEh.Create;
begin
  inherited Create(False);
end;

constructor TObjectListEh.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);
end;

procedure TObjectListEh.Sort(Compare: TListSortCompare);
begin
  inherited Sort(Compare);
end;

{$IFDEF FPC}
{$ELSE}
function TSortedListEh<T>.Add(const Value: T): Integer;
var
  SearchFound: Boolean;
begin
  SearchFound := BinarySearch(Value, Result);

  if SearchFound then
  begin
    case FDuplicates of
      dupAccept: inherited Insert(Result, Value);
      dupIgnore: Exit;
      dupError: EListError.CreateFmt(SDuplicateItem, [Result]);
    end;
  end
  else
  begin
    inherited Insert(Result, Value);
  end;
end;

procedure TSortedListEh<T>.Insert(Index: Integer; const Value: T);
begin
  raise EListError.Create('TSortedListEh<T>.Insert is not supported');
end;
{$ENDIF} 

initialization
finalization
{$IFDEF FPC}
{$ELSE}
  {$IFNDEF EH_LIB_17}
  FreeAndNil(FFormatSettings);
  {$ENDIF}
{$ENDIF}
end.
