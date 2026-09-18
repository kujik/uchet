{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{  TPdfType0FontEh, TPdfCIDFontEh, TPdfToUnicodeMapEh,  }
{     TPdfFontDescriptorEh, TPdfFontFileEh classes      }
{                                                       }
{   Copyright (c) 2021-2025 by Dmitry V. Bolshakov      }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}

unit PdfFontsEh;

{$SCOPEDENUMS ON}

interface

uses
  SysUtils, Variants, Classes, Types,
  ZLib,
  PdfElementsEh,
{$IFDEF FPC}
  LCLType, Generics.Collections, Generics.Defaults,
{$ELSE}
  Generics.Defaults, Generics.Collections,
{$ENDIF}
  EhLibUtils, Graphics;

type
  TPdfType0FontEh = class;
  TPdfCIDFontEh = class;
  TPdfToUnicodeMapEh = class;
  TPdfFontDescriptorEh = class;
  TPdfFontFileEh = class;

  TOpenTypeFontDataEh = class;
  TOpenTypeFontDataLoaderEh = class;

  TOpenTypeCMapTableEh = class; 
  TOpenTypeCMapFmt4TableEh = class;
  TOpenTypeFontHeaderTableEh = class; 
  TOpenTypeHorizontalHeaderTableEh = class; 
  TOpenTypeHorizontalMetricsTableEh = class; 
  TOpenTypeMaximumProfileTableEh = class; 
  TOpenTypeNamingTableEh = class; 
  TOpenTypeOS2TableEh = class; 
  TOpenTypePostScriptInfoTableEh = class; 

  TOpenTypeControlValueTableEh = class; 
  TOpenTypeFontProgramTableEh = class;  
  TOpenTypeGlyphDataTableEh = class;  
  TOpenTypeIndexToLocationTableEh = class;  
  TOpenTypeControlValueProgramTableEh = class; 

  TOpenTypeGlyphSubstitutionTableEh = class;


{ TOpenTypeOffsetTableEh }

  TOpenTypeOffsetTableEh = record
    Version: UInt32;
    TableCount: Integer;
    SearchRange: UInt16;
    EntrySelector: UInt16;
    RangeShift: UInt16;
  end;

{ TOpenTypeTableDirectoryEntryEh }

  TOpenTypeTableDirectoryEntryEh = class(TObject)
      TableTag: String;
      CheckSum: UInt32;
      Offset: Int32;
      Length: UInt32;

    procedure ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeHorizontalMetricsEh }

  TOpenTypeHorizontalMetricsEh = record
    AdvanceWidth: UInt16; 
    Lsb: Int16; 
  end;

{ TOpenTypeFontNameRecordEh }

  TOpenTypeFontNameRecordEh = record
    PlatformID: UInt16;
    EncodingID: UInt16;
    LanguageID: UInt16;
    NameID: UInt16;
    Length: UInt16;
    Offset: UInt16;
  end;


{ TPdfOutlineTextMetricEh }

  TPdfOutlineTextMetricEh = record
    TextMetricsAscent: Longint;
    TextMetricsDescent: Longint;
    TextMetricsHeight: Longint;
    TextMetricsCharSet: Byte;
    TextMetricsInternalLeading: Longint;
    TextMetricsExternalLeading: Longint;
    TextMetricsWeight: Longint;
    TextMetricsOverhang: Longint;
    ItalicAngle: Integer;
    FontBox: TRect;
  end;

{ TUsedCharRecEh }

  TUsedCharRecEh = record
    CharCode: WideChar;
    GlyphIndex: Word;
  end;

{ TUsedCharsEh }

  TUsedCharsEh = class(TSortedListEh<TUsedCharRecEh>)
  private type

    TUsedCharComparer = class(TComparer<TUsedCharRecEh>)
    public
      {$IFDEF FPC}
      function Compare(constref Left, Right: TUsedCharRecEh): Integer; override;
      {$ELSE}
      function Compare(const Left, Right: TUsedCharRecEh): Integer; override;
      {$ENDIF}
    end;

  public
    constructor Create; overload;
  end;

{ TUsedGlyphRecEh }

  TUsedGlyphRecEh = record
    GlyphIndex: Word;
    GlyphWidth: Integer;
  end;

{ TUsedGlyphsEh }

  TUsedGlyphsEh = class(TSortedListEh<TUsedGlyphRecEh>)
  private type

    TUsedGlyphsComparer = class(TComparer<TUsedGlyphRecEh>)
    public
      {$IFDEF FPC}
      function Compare(constref Left, Right: TUsedGlyphRecEh): Integer; override;
      {$ELSE}
      function Compare(const Left, Right: TUsedGlyphRecEh): Integer; override;
      {$ENDIF}
    end;

  public
    constructor Create; overload;
  end;

{ TPdfType0FontEh }

  TPdfType0FontEh = class(TPdfIndirectDictionaryObjectEh)
  private
    FDescendantFont: TPdfCIDFontEh;
    FPdfToUnicodeMap: TPdfToUnicodeMapEh;
    FFontKeyName: String;
    FFontCode: String;
    FFontName: String;
    FIsBold: Boolean;
    FIsItalic: Boolean;
    FOutlineTextMetric: TPdfOutlineTextMetricEh;
    FFontLayoutStream: TMemoryStream;
    FOpenTypeFontData: TOpenTypeFontDataEh;
    FUsedChars: TUsedCharsEh;
    FUsedGlyphs: TUsedGlyphsEh;
    FUnitsPerEm: UInt16;
    FUnderlineShift: Integer;
    FUnderlineSize: Integer;
    FStrikeoutShift: Integer;
    FStrikeoutSize: Integer;

    procedure InitFont;
    procedure InitMetrics;
    procedure InitFontStream;
    procedure InitOpenTypeFontTables;
    procedure AddUsedChar(Ch: WideChar);
    function AddUsedCharGetGlyphIndex(Ch: WideChar): Word;
    procedure AddUsedFontFileGlyphIndex(FontFileGlyphIndex: Word);

  protected
  public
    constructor Create(ADocument: TPdfBaseDocumentEh; AFontKeyName: String; AFontName: String; AIsBold: Boolean; AIsItalic: Boolean; AFontCode: String);
    destructor Destroy; override;

    procedure AddUsedChars(Text: String);
    function AddUsedCharsGetGlyphIndexes(Text: String): TWordDynArray;
    function CreateFontSubsetFileData: TBytes;

    class function CreateFontKeyName(AFontName: String; AIsBold: Boolean; AIsItalic: Boolean): String;

    property DescendantFont: TPdfCIDFontEh read FDescendantFont;
    property PdfToUnicodeMap: TPdfToUnicodeMapEh read FPdfToUnicodeMap;
    property FontKeyName: String read FFontKeyName;
    property FontCode: String read FFontCode;
    property UnitsPerEm: UInt16 read FUnitsPerEm;

    property UnderlineShift: Integer read FUnderlineShift;
    property UnderlineSize: Integer read FUnderlineSize;
    property StrikeoutShift: Integer read FStrikeoutShift;
    property StrikeoutSize: Integer read FStrikeoutSize;
    property OutlineTextMetric: TPdfOutlineTextMetricEh read FOutlineTextMetric;
    property OpenTypeFontData: TOpenTypeFontDataEh read FOpenTypeFontData;
  end;

{ TPdfCIDFontEh }

  TPdfCIDFontEh = class(TPdfIndirectDictionaryObjectEh)
  private
    FMasterFont: TPdfType0FontEh;
    FFontDescriptor: TPdfFontDescriptorEh;

    procedure InitFont;
    function GetName: String;

  protected
  public
    constructor Create(AMasterFont: TPdfType0FontEh);
    destructor Destroy; override;

    procedure PrepareForExport; override;

    property Name: String read GetName;
    property FontDescriptor: TPdfFontDescriptorEh read FFontDescriptor;
  end;

{ TPdfFontDescriptorEh }

  TPdfFontDescriptorEh = class(TPdfIndirectDictionaryObjectEh)
  private
    FMasterFont: TPdfCIDFontEh;
    FFontFile: TPdfFontFileEh;
    FAscent: TPdfIntegerNumberEh;

    procedure InitFontDescriptor;

  protected
  public
    constructor Create(AMasterFont: TPdfCIDFontEh);
    destructor Destroy; override;

    procedure PrepareForExport; override;

    property Ascent: TPdfIntegerNumberEh read FAscent write FAscent;

  end;

{ TPdfFontFileEh }

  TPdfFontFileEh = class(TPdfIndirectDictionaryObjectEh)
  private
    FFontDescriptor: TPdfFontDescriptorEh;

  protected
    function CreateBoundStream: TPdfDictionaryStreamEh; override;

  public
    constructor Create(AFontDescriptor: TPdfFontDescriptorEh);
    destructor Destroy; override;

    procedure PrepareForExport; override;
  end;

{ TPdfToUnicodeMapEh }

  TPdfToUnicodeMapEh = class(TPdfIndirectDictionaryObjectEh)
  private
    FMasterFont: TPdfType0FontEh;

    procedure InitMap;
    function GetBoundStream: TPdfAsciiStreamEh;
    procedure PrepareStream;
  protected
    function CreateBoundStream: TPdfDictionaryStreamEh; override;

  public
    constructor Create(AMasterFont: TPdfType0FontEh);
    destructor Destroy; override;

    procedure PrepareForExport; override;

    property BoundStream: TPdfAsciiStreamEh read GetBoundStream;
  end;

{ TOpenTypeFontDataEh }

  TOpenTypeFontDataEh = class(TObject)
  private
    FOffsetTable: TOpenTypeOffsetTableEh;
    FTableDictionary: TDictionary<String, TOpenTypeTableDirectoryEntryEh>;

    FCmapTable: TOpenTypeCMapTableEh; 
    FHeadTable: TOpenTypeFontHeaderTableEh; 
    FHrztlHeadTable: TOpenTypeHorizontalHeaderTableEh; 
    FHrztlMetricsTable: TOpenTypeHorizontalMetricsTableEh; 
    FMaxpTable: TOpenTypeMaximumProfileTableEh; 
    FNamingTable: TOpenTypeNamingTableEh; 
    FOs2Table: TOpenTypeOS2TableEh; 
    FPostScriptTable: TOpenTypePostScriptInfoTableEh; 

    FControlValueTable: TOpenTypeControlValueTableEh; 
    FFontProgramTable: TOpenTypeFontProgramTableEh; 
    FGlyphDataTable: TOpenTypeGlyphDataTableEh; 
    FIndexToLocationTable: TOpenTypeIndexToLocationTableEh; 
    FControlValueProgramTable: TOpenTypeControlValueProgramTableEh; 

    FGsubTable: TOpenTypeGlyphSubstitutionTableEh;
    procedure LoadTables(Loader: TOpenTypeFontDataLoaderEh); 

    
    
  protected
    {$IFDEF FPC}
    procedure TableDicItemNotification(Sender: TObject; constref Item: TOpenTypeTableDirectoryEntryEh; Action: TCollectionNotification);
    {$ELSE}
    procedure TableDicItemNotification(Sender: TObject; const Item: TOpenTypeTableDirectoryEntryEh; Action: TCollectionNotification);
    {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    function GlyphIndexByCharCode(Chr: WideChar): Word;
    function GlyphWidthByGlyphIndex(GlyphIndex: Word; Normalize: Boolean): Integer;

    procedure LoadFromDataStream(AFontDataStream: TMemoryStream);

    property CmapTable: TOpenTypeCMapTableEh read FCmapTable; 
    property HeadTable: TOpenTypeFontHeaderTableEh read FHeadTable; 
    property HrztlHeadTable: TOpenTypeHorizontalHeaderTableEh read FHrztlHeadTable; 
    property HrztlMetricsTable: TOpenTypeHorizontalMetricsTableEh read FHrztlMetricsTable; 
    property MaxpTable: TOpenTypeMaximumProfileTableEh read FMaxpTable; 
    property NamingTable: TOpenTypeNamingTableEh read FNamingTable; 
    property Os2Table: TOpenTypeOS2TableEh read FOs2Table; 
    property PostScriptTable: TOpenTypePostScriptInfoTableEh read FPostScriptTable; 

    property ControlValueTable: TOpenTypeControlValueTableEh read FControlValueTable; 
    property FontProgramTable: TOpenTypeFontProgramTableEh read FFontProgramTable; 
    property GlyphDataTable: TOpenTypeGlyphDataTableEh read FGlyphDataTable; 
    property IndexToLocationTable: TOpenTypeIndexToLocationTableEh read FIndexToLocationTable; 
    property ControlValueProgramTable: TOpenTypeControlValueProgramTableEh read FControlValueProgramTable; 

    property GsubTable: TOpenTypeGlyphSubstitutionTableEh read FGsubTable;

  end;

{ TOpenTypeFontDataLoaderEh }

  TOpenTypeFontDataLoaderEh = class(TObject)
  private
    function ReadLongRec: LongRec;
    function ReadWordRec: WordRec;
    function GetPosition: Int64;
    procedure SetPosition(const Value: Int64);
    function ReadInt64Rec: Int64Rec;
  protected
    FFontDataStream: TMemoryStream;

  public
    constructor Create(AFontDataStream: TMemoryStream); overload;

    function ReadTag4B: TBytes;
    function ReadInt8: Int8;
    function ReadUInt8: UInt8;
    function ReadInt16: Int16;
    function ReadUInt16: UInt16;
    function ReadInt32: Int32;
    function ReadUInt32: UInt32;
    function ReadInt64: Int64;
    function ReadBytes(ASize: Int64): TBytes;
    function ReadString(ASize: Int64): String;
    function ReadSingle: Single;

    procedure LoadInitStream(FontName: TFontName; FontSize: Integer; FontStyle: TFontStyles);

    property Position: Int64 read GetPosition write SetPosition;
    property FontDataStream: TMemoryStream read FFontDataStream;
  end;

{ TOpenTypeBaseTableEh }

  TOpenTypeBaseTableEh = class(TObject)
  public

    procedure ReadFrom(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh); virtual;
    constructor Create(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
  end;

  

{ TOpenTypeCMapTableEh }

  
  

  TOpenTypePlatformIdEh = (Apple, Mac, Iso, Win);
  TOpenTypeWinEncodingIdEh = (Symbol, Unicode);

  TOpenTypeCMapTableEh = class(TOpenTypeBaseTableEh)
  public
    Version: UInt16;
    NumTables: UInt16;

    IsSymbol: Boolean; 

    CMap4Table: TOpenTypeCMapFmt4TableEh;

    constructor Create(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
    destructor Destroy; override;

    procedure ReadFrom(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh); override;

  end;

  

{ TOpenTypeCMapFmt4TableEh }

  TOpenTypeCMapFmt4TableEh = class(TObject)
  public
    EncodingId: TOpenTypeWinEncodingIdEh;
    Format: UInt16;
    Length: UInt16;
    Language: UInt16;
    SegCountX2: UInt16;
    SearchRange: UInt16;
    EntrySelector: UInt16;
    RangeShift: UInt16;

    EndCount: TArray<UInt16>; 
    StartCount: TArray<UInt16>; 
    IdDelta: TArray<Int16>; 
    IdRangeOffs: TArray<UInt16>; 
    GlyphCount: Integer; 
    GlyphIdArray: TArray<UInt16>;     

    procedure ReadFrom(Loader: TOpenTypeFontDataLoaderEh);

    constructor Create(Loader: TOpenTypeFontDataLoaderEh; AnEncodingId: TOpenTypeWinEncodingIdEh);
  end;

{ TOpenTypeFontHeaderTableEh }

  TOpenTypeFontHeaderTableEh = class(TObject) 
  public
    MajorVersion: UInt16;
    MinorVersion: UInt16;
    FontRevision: Int32;
    CheckSumAdjustment: UInt32;
    MagicNumber: UInt32; 
    Flags: UInt16;
    UnitsPerEm: UInt16; 
    Created: Int64;
    Modified: Int64;
    XMin: Int16;
    YMin: Int16; 
    XMax: Int16;
    YMax: Int16; 
    MacStyle: UInt16;
    LowestRecPPEM: UInt16;
    FontDirectionHint: Int16;
    IndexToLocFormat: Int16; 
    GlyphDataFormat: Int16; 

    procedure ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeHorizontalHeaderTableEh }

  TOpenTypeHorizontalHeaderTableEh = class(TObject) 
  public
    MajorVersion: UInt16;
    MinorVersion: UInt16;
    Ascender: Int16; 
    Descender: Int16; 
    LineGap: Int16; 
    AdvanceWidthMax: UInt16;
    MinLeftSideBearing: Int16;
    MinRightSideBearing: Int16;
    XMaxExtent: Int16;
    CaretSlopeRise: Int16;
    CaretSlopeRun: Int16;
    Reserved1: Int16;
    Reserved2: Int16;
    Reserved3: Int16;
    Reserved4: Int16;
    Reserved5: Int16;
    MetricDataFormat: Int16;
    NumberOfHMetrics: UInt16;

    procedure ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeHorizontalMetricsTableEh }

  TOpenTypeHorizontalMetricsTableEh = class(TObject) 
  public
    HorMetrics: TArray<TOpenTypeHorizontalMetricsEh>;
    LeftSideBearing: TArray<Int16>;

    procedure ReadFrom(FontData: TOpenTypeFontDataEh; Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(FontData: TOpenTypeFontDataEh; Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeMaximumProfileTableEh }

  TOpenTypeMaximumProfileTableEh = class(TObject) 
  public
    MajorVersion: UInt16;
    MinorVersion: UInt16;
    NumGlyphs: UInt16;
    MaxPoints: UInt16;
    MaxContours: UInt16;
    MaxCompositePoints: UInt16;
    MaxCompositeContours: UInt16;
    MaxZones: UInt16;
    MaxTwilightPoints: UInt16;
    MaxStorage: UInt16;
    MaxFunctionDefs: UInt16;
    MaxInstructionDefs: UInt16;
    MaxStackElements: UInt16;
    MaxSizeOfInstructions: UInt16;
    MaxComponentElements: UInt16;
    MaxComponentDepth: UInt16;

    procedure ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeNamingTableEh }

  
  

  TOpenTypeNamingTableEh = class(TObject)
  public
    Version: UInt16; 
    Count: UInt16; 
    StorageOffset: UInt16;	
    NameRecords: TArray<TOpenTypeFontNameRecordEh>; 
    

    Name: String;
    Style: String;
    FullFontName: String;

    procedure ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeOS2TableEh }

  
  

  TOpenTypeOS2TableEh = class(TObject) 
  public
    Version: UInt16;
    XAvgCharWidth: Int16;
    UsWeightClass: UInt16;
    UsWidthClass: UInt16;
    FsType: UInt16;
    YSubscriptXSize: Int16;
    YSubscriptYSize: Int16;
    YSubscriptXOffset: Int16;
    YSubscriptYOffset: Int16;
    YSuperscriptXSize: Int16;
    YSuperscriptYSize: Int16;
    YSuperscriptXOffset: Int16;
    YSuperscriptYOffset: Int16;
    YStrikeoutSize: Int16;
    YStrikeoutPosition: Int16;
    SFamilyClass: Int16;
    Panose: TBytes; 
    UlUnicodeRange1: UInt32; 
    UlUnicodeRange2: UInt32; 
    UlUnicodeRange3: UInt32; 
    UlUnicodeRange4: UInt32; 
    AchVendID: String; 
    FsSelection: UInt16;
    UsFirstCharIndex: UInt16;
    UsLastCharIndex: UInt16;
    STypoAscender: Int16;
    STypoDescender: Int16;
    STypoLineGap: Int16;
    UsWinAscent: UInt16;
    UsWinDescent: UInt16;
    
    UlCodePageRange1: UInt32; 
    UlCodePageRange2: UInt32; 
    
    SxHeight: Int16;
    SCapHeight: Int16;
    UsDefaultChar: UInt16;
    UsBreakChar: UInt16;
    UsMaxContext: UInt16;
    
    UsLowerOpticalPointSize: UInt16;
    UsUpperOpticalPointSize: UInt16;

    procedure ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypePostScriptInfoTableEh }

  
  

  TOpenTypePostScriptInfoTableEh = class(TObject)
  public
    MajorVersion: UInt16;
    MinorVersion: UInt16;
    
    ItalicAngle: Single;
    UnderlinePosition: Int16;
    UnderlineThickness: Int16;
    IsFixedPitch: UInt32;
    MinMemType42: UInt32;
    MaxMemType42: UInt32;
    MinMemType1: UInt32;
    MaxMemType1: UInt32;

    procedure ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeControlValueTableEh }

  
  

  TOpenTypeControlValueTableEh = class(TObject)
  public
    ControlValues: TArray<Int16>;

    procedure ReadFrom(TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeFontProgramTable }

  
  

  TOpenTypeFontProgramTableEh = class(TObject)
  public
    Instructions: TArray<UInt8>;

    procedure ReadFrom(TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeGlyphDataTable }

  
  

  TOpenTypeGlyphDataTableEh = class(TObject)
  public

    procedure ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeIndexToLocationTable }

  
  

  TOpenTypeIndexToLocationTableEh = class(TObject)
  public
    LocalOffset: TArray<UInt32>;

    procedure ReadFrom(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
    constructor Create(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeControlValueProgramTable }

  
  

  TOpenTypeControlValueProgramTableEh = class(TOpenTypeBaseTableEh)
  public
    Instructions: TArray<UInt8>;

    procedure ReadFrom(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh); override;
    constructor Create(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
  end;

{ TOpenTypeGlyphSubstitutionTable }

  
  

  TOpenTypeGlyphSubstitutionTableEh = class(TOpenTypeBaseTableEh)
  public

    procedure ReadFrom(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh); override;
    constructor Create(FontData: TOpenTypeFontDataEh; TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
  end;


implementation

uses
{$IFDEF FPC}
  {$IFDEF FPC_WINDOWS}
    Windows,
  {$ENDIF}
{$ELSE}
  Windows,
{$ENDIF}
  PdfDocumentsEh;


{$IFDEF MSWINDOWS}
var
  CreateFontPackage: function (puchSrcBuffer: Pointer;
                           ulSrcBufferSize: Cardinal;
                           puchFontPackageBuffer: PPointer;
                           pulFontPackageBufferSize: PCardinal;
                           pulBytesWritten: PCardinal;
                           usFlags,
                           usTTCIndex,
                           usSubsetFormat,
                           usSubsetLanguage,
                           usSubsetPlatform,
                           usSubsetEncoding: Word;
                           pusSubsetKeepList: PWordArray;
                           usSubsetKeepListCount: Word;
                           lpfnAllocate,
                           lpfnReAllocate,
                           lpfnFree,
                           Reserved: Pointer): Cardinal; stdcall;

{$ELSE}
  
{$ENDIF}

var
  FontSubLibrary: THandle;

procedure InitUnit;
begin
{$IFDEF MSWINDOWS}
  FontSubLibrary := LoadLibrary('FontSub.dll');
  if FontSubLibrary > 0 then
  begin
    CreateFontPackage := GetProcAddress(FontSubLibrary, 'CreateFontPackage');
  end;
{$ENDIF}
end;

procedure FreeUnit;
begin
{$IFDEF MSWINDOWS}
  if (FontSubLibrary <> 0) then
  begin
    FreeLibrary(FontSubLibrary);
    FontSubLibrary := 0;

    CreateFontPackage := nil;
  end;
{$ENDIF}
end;

const
  PDF_FONT_SYMBOLIC    = 4;
  PDF_FONT_STD_CHARSET = 32;

var
  ScreenCanvas: TCanvas;

function GetScreenCanvas: TCanvas;
begin
  if (ScreenCanvas = nil) then
  begin
    ScreenCanvas := TCanvas.Create;
    {$IFDEF FPC_LINUX}
    {$ELSE}
    ScreenCanvas.Handle := GetDC(0);
    {$ENDIF}
  end;
  Result := ScreenCanvas;
end;

procedure FreeScreenCanvas;
begin
  if (ScreenCanvas <> nil) then
  begin
    {$IFDEF FPC_LINUX}
    {$ELSE}
    ReleaseDC(0, ScreenCanvas.Handle);
    ScreenCanvas.Handle := 0;
    {$ENDIF}
  end;
  FreeAndNil(ScreenCanvas);
end;

function BytesToString(Bytes: TBytes): String;
var
  I: Integer;
begin
  SetLength(Result, Length(Bytes));
  for I := 0 to Length(Bytes) - 1 do
    Result[I+1] := Char(AnsiChar(Bytes[I]));
end;

{ TWindowsFontDataLoader }

constructor TOpenTypeFontDataLoaderEh.Create(AFontDataStream: TMemoryStream);
begin
  FFontDataStream := AFontDataStream;
end;

procedure TOpenTypeFontDataLoaderEh.LoadInitStream(FontName: TFontName; FontSize: Integer; FontStyle: TFontStyles);
{$IFDEF FPC_LINUX}
begin
  
end;
{$ELSE}
var
  ACanvas: TCanvas;
  BufSize: Integer;
begin
  ACanvas := GetScreenCanvas;

  ACanvas.Font.Name := FontName;
  ACanvas.Font.Size := FontSize;
  ACanvas.Font.Style := FontStyle;

  BufSize := Windows.GetFontData(ACanvas.Handle, 0, 0, nil, 0);

  if (BufSize < 0 ) then
    raise Exception.Create('"Cannot retrieve font data.');

  FFontDataStream := TMemoryStream.Create;
  FontDataStream.Size := BufSize;

  Windows.GetFontData(ACanvas.Handle, 0, 0, FontDataStream.Memory, BufSize);
end;
{$ENDIF}

function TOpenTypeFontDataLoaderEh.ReadWordRec: WordRec;
var
  TmpByte: Byte;
begin
  FontDataStream.Read(Result, 2);
  TmpByte := Result.Lo;
  Result.Lo := Result.Hi;
  Result.Hi := TmpByte;
end;

function TOpenTypeFontDataLoaderEh.GetPosition: Int64;
begin
  Result := FontDataStream.Position;
end;

procedure TOpenTypeFontDataLoaderEh.SetPosition(const Value: Int64);
begin
  FontDataStream.Position := Value;
end;

function TOpenTypeFontDataLoaderEh.ReadLongRec: LongRec;
var
  TmpWord: Word;
begin
  FontDataStream.Read(Result, SizeOf(LongRec));

  TmpWord := Result.Lo;
  Result.Lo := Result.Hi;
  Result.Hi := TmpWord;

  Result.Lo := Swap(Result.Lo);
  Result.Hi := Swap(Result.Hi);
end;

function TOpenTypeFontDataLoaderEh.ReadInt64Rec: Int64Rec;
var
  TmpByte: Byte;
begin
  FontDataStream.Read(Result, SizeOf(Int64Rec));

  TmpByte := Result.Bytes[0];
  Result.Bytes[0] := Result.Bytes[7];
  Result.Bytes[7] := TmpByte;

  TmpByte := Result.Bytes[1];
  Result.Bytes[1] := Result.Bytes[6];
  Result.Bytes[6]:= TmpByte;

  TmpByte := Result.Bytes[2];
  Result.Bytes[2] := Result.Bytes[5];
  Result.Bytes[5]:= TmpByte;

  TmpByte := Result.Bytes[3];
  Result.Bytes[3] := Result.Bytes[4];
  Result.Bytes[4]:= TmpByte;
end;

function TOpenTypeFontDataLoaderEh.ReadInt8: Int8;
begin
  FontDataStream.Read(Result, SizeOf(Int8));
end;

function TOpenTypeFontDataLoaderEh.ReadUInt8: UInt8;
begin
  FontDataStream.Read(Result, SizeOf(UInt8));
end;

function TOpenTypeFontDataLoaderEh.ReadInt16: Int16;
begin
  Result := Int16(ReadWordRec);
end;

function TOpenTypeFontDataLoaderEh.ReadUInt16: UInt16;
begin
  Result := UInt16(ReadWordRec);
end;

function TOpenTypeFontDataLoaderEh.ReadInt32: Int32;
begin
  Result := Int32(ReadLongRec);
end;

function TOpenTypeFontDataLoaderEh.ReadUInt32: UInt32;
begin
  Result := UInt32(ReadLongRec);
end;

function TOpenTypeFontDataLoaderEh.ReadTag4B: TBytes;
begin
  Result := ReadBytes(4);
end;

function TOpenTypeFontDataLoaderEh.ReadInt64: Int64;
begin
  Result := Int64(ReadInt64Rec);
end;

function TOpenTypeFontDataLoaderEh.ReadSingle: Single;
var
  VInt32: Int32;
begin
  VInt32 := ReadInt32;
  Result := VInt32 / 65536;
end;

function TOpenTypeFontDataLoaderEh.ReadBytes(ASize: Int64): TBytes;
var
  ResPtr: Pointer;
begin
  SetLength(Result, ASize);
  ResPtr := Pointer(Result);
  FontDataStream.Read(ResPtr^, ASize);
end;

function TOpenTypeFontDataLoaderEh.ReadString(ASize: Int64): String;
var
  Bytes: TBytes;
begin
  Bytes := ReadBytes(ASize);
  Result := TEncoding.ASCII.GetString(Bytes);
end;

{ TOpenTypeFontData }

constructor TOpenTypeFontDataEh.Create;
begin
  inherited Create;
  FTableDictionary := TDictionary<String, TOpenTypeTableDirectoryEntryEh>.Create;
  FTableDictionary.OnValueNotify := TableDicItemNotification;
end;

destructor TOpenTypeFontDataEh.Destroy;
begin
  FreeAndNil(FTableDictionary);

  FreeAndNil(FCmapTable);
  FreeAndNil(FHeadTable);
  FreeAndNil(FHrztlHeadTable);
  FreeAndNil(FHrztlMetricsTable);
  FreeAndNil(FMaxpTable);
  FreeAndNil(FNamingTable);
  FreeAndNil(FOs2Table);
  FreeAndNil(FPostScriptTable);

  FreeAndNil(FControlValueTable);
  FreeAndNil(FFontProgramTable);
  FreeAndNil(FGlyphDataTable);
  FreeAndNil(FIndexToLocationTable);
  FreeAndNil(FControlValueProgramTable);
  FreeAndNil(FGsubTable);

  inherited Destroy;
end;

{$IFDEF FPC}
procedure TOpenTypeFontDataEh.TableDicItemNotification(Sender: TObject;
  constref Item: TOpenTypeTableDirectoryEntryEh; Action: TCollectionNotification);
{$ELSE}
procedure TOpenTypeFontDataEh.TableDicItemNotification(Sender: TObject;
  const Item: TOpenTypeTableDirectoryEntryEh; Action: TCollectionNotification);
{$ENDIF}
begin
  if Action = cnRemoved then
    Item.Free;
end;

function TOpenTypeFontDataEh.GlyphIndexByCharCode(Chr: WideChar): Word;
var
  CMap4: TOpenTypeCMapFmt4TableEh;
  SegCount: Integer;
  SegIndex: Integer;
  I: Integer;
  CharCode: UInt16;
  Idx: Integer;
begin
  CharCode := UInt16(Chr);
  SegIndex := 0;
  CMap4 := FCmapTable.CMap4Table;
  SegCount := CMap4.segCountX2 div 2;

  for I := 0 to SegCount - 1 do
  begin
    if (CharCode <= CMap4.EndCount[I]) then
    begin
      SegIndex := I;
      Break;
    end;
  end;

  if (CharCode < CMap4.StartCount[SegIndex]) then
  begin
    Result := 0;
    Exit;
  end;

  if (CMap4.IdRangeOffs[SegIndex] = 0) then
  begin
    
    Result := CharCode + CMap4.IdDelta[SegIndex];
    Exit;
  end;

  Idx := CMap4.IdRangeOffs[SegIndex] div 2 +
         (CharCode - CMap4.StartCount[SegIndex]) -
         (SegCount - SegIndex);

  if (CMap4.GlyphIdArray[Idx] = 0) then
  begin
    Result := 0;
    Exit;
  end;

  Result := CMap4.GlyphIdArray[Idx] + CMap4.IdDelta[SegIndex];
end;

function TOpenTypeFontDataEh.GlyphWidthByGlyphIndex(GlyphIndex: Word; Normalize: Boolean): Integer;
var
  NumOfHMetrics: Integer;
  UnitsPerEm: Integer;
  Width: Integer;
begin
  NumOfHMetrics := FHrztlHeadTable.NumberOfHMetrics;
  UnitsPerEm := FHeadTable.UnitsPerEm;

  if (GlyphIndex >= NumOfHMetrics) then
      GlyphIndex := NumOfHMetrics - 1;

  Width := FHrztlMetricsTable.HorMetrics[GlyphIndex].AdvanceWidth;

  Result := Width;
  if (Normalize) then
  begin
    
    if (UnitsPerEm <> 1000) then
      Result := Width * 1000 div UnitsPerEm;
  end;
end;

procedure TOpenTypeFontDataEh.LoadFromDataStream(AFontDataStream: TMemoryStream);
var
  Loader: TOpenTypeFontDataLoaderEh;
begin
  Loader := TOpenTypeFontDataLoaderEh.Create(AFontDataStream);
  LoadTables(Loader);
  Loader.Free;
end;

procedure TOpenTypeFontDataEh.LoadTables(Loader: TOpenTypeFontDataLoaderEh);
var
  Tag: TBytes;
  I: Integer;
  OTTable: TOpenTypeTableDirectoryEntryEh;
begin
  Tag := Loader.ReadTag4B;
  if (Length(Tag) <> 4) then
    raise Exception.Create('TOpenTypeFontData.LoadFontData: Tag Length is not 4');

  if (Tag[0] = 0) and (Tag[1] = 1) and (Tag[2] = 0) and (Tag[3] = 0) then
    
  else
    raise Exception.Create('TOpenTypeFontData.LoadFontData: Tag is incorrect');

  FOffsetTable.Version := 1;
  FOffsetTable.TableCount := Loader.ReadUInt16;
  FOffsetTable.SearchRange := Loader.ReadUInt16;
  FOffsetTable.EntrySelector := Loader.ReadUInt16;
  FOffsetTable.RangeShift := Loader.ReadUInt16;

  for I := 0 to FOffsetTable.TableCount - 1 do
  begin
    OTTable := TOpenTypeTableDirectoryEntryEh.Create;
    OTTable.ReadFrom(Loader);
    FTableDictionary.Add(OTTable.TableTag, OTTable);
  end;

  

  
  if (FTableDictionary.TryGetValue('cmap', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FCmapTable := TOpenTypeCMapTableEh.Create(Self, OTTable, Loader);
  end;

  
  if (FTableDictionary.TryGetValue('head', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FHeadTable := TOpenTypeFontHeaderTableEh.Create(Loader);
  end;

  
  if (FTableDictionary.TryGetValue('hhea', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FHrztlHeadTable := TOpenTypeHorizontalHeaderTableEh.Create(Loader);
  end;

  
  if (FTableDictionary.TryGetValue('maxp', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FMaxpTable := TOpenTypeMaximumProfileTableEh.Create(Loader);
  end;

  
  if (FTableDictionary.TryGetValue('name', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FNamingTable := TOpenTypeNamingTableEh.Create(Loader);
  end;

  
  if (FTableDictionary.TryGetValue('OS/2', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FOs2Table := TOpenTypeOS2TableEh.Create(Loader);
  end;

  
  if (FTableDictionary.TryGetValue('hmtx', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FHrztlMetricsTable := TOpenTypeHorizontalMetricsTableEh.Create(Self, Loader);
  end;

  
  if (FTableDictionary.TryGetValue('post', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FPostScriptTable := TOpenTypePostScriptInfoTableEh.Create(Loader);
  end;

  

  
  if (FTableDictionary.TryGetValue('cvt ', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FControlValueTable := TOpenTypeControlValueTableEh.Create(OTTable, Loader);
  end;

  
  if (FTableDictionary.TryGetValue('fpgm', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FFontProgramTable := TOpenTypeFontProgramTableEh.Create(OTTable, Loader);
  end;

  
  if (FTableDictionary.TryGetValue('glyf', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FGlyphDataTable := TOpenTypeGlyphDataTableEh.Create(Loader);
  end;

  
  if (FTableDictionary.TryGetValue('loca', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FIndexToLocationTable := TOpenTypeIndexToLocationTableEh.Create(Self, OTTable, Loader);
  end;

  
  if (FTableDictionary.TryGetValue('prep', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FControlValueProgramTable := TOpenTypeControlValueProgramTableEh.Create(Self, OTTable, Loader);
  end;

  
  if (FTableDictionary.TryGetValue('GSUB', OTTable)) then
  begin
    Loader.Position := OTTable.Offset;
    FGsubTable := TOpenTypeGlyphSubstitutionTableEh.Create(Self, OTTable, Loader);
  end;

  
end;

{ TOpenTypeBaseTable }

constructor TOpenTypeBaseTableEh.Create(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(FontData, TableEntry, Loader);
end;

procedure TOpenTypeBaseTableEh.ReadFrom(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
begin
end;

{ TOpenTypeTableDirectoryEntry }

procedure TOpenTypeTableDirectoryEntryEh.ReadFrom(
  Loader: TOpenTypeFontDataLoaderEh);
begin
  TableTag := BytesToString(Loader.ReadTag4B);
  CheckSum := Loader.ReadUInt32;
  Offset := Loader.ReadInt32;
  Length := Loader.ReadUInt32;
end;

{ TOpenTypeCMapTable }

constructor TOpenTypeCMapTableEh.Create(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create(FontData, TableEntry, Loader);
end;

destructor TOpenTypeCMapTableEh.Destroy;
begin
  FreeAndNil(CMap4Table);
  inherited Destroy;
end;

procedure TOpenTypeCMapTableEh.ReadFrom(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
var
  TableOffset: Int64;
  IsOk: Boolean;
  I: Integer;
  CurrentPosition: Int64;
  PlatformId: TOpenTypePlatformIdEh;
  EncodingId: TOpenTypeWinEncodingIdEh;
  Offset: Integer;
begin
  TableOffset := Loader.Position;

  Version := Loader.ReadUInt16();
  NumTables := Loader.ReadUInt16();

  IsOk := False;
  for I := 0 to NumTables - 1 do
  begin

    PlatformId := TOpenTypePlatformIdEh(Loader.ReadUInt16);
    EncodingId := TOpenTypeWinEncodingIdEh(Loader.ReadUInt16);
    Offset := Loader.ReadUInt32;

    CurrentPosition := Loader.Position;

    
    if ( (PlatformId = TOpenTypePlatformIdEh.Win) and
         ((EncodingId = TOpenTypeWinEncodingIdEh.Symbol) or (EncodingId = TOpenTypeWinEncodingIdEh.Unicode))
       )
    then
    begin
        IsSymbol := (EncodingId = TOpenTypeWinEncodingIdEh.Symbol);

        Loader.Position := tableOffset + offset;
        CMap4Table := TOpenTypeCMapFmt4TableEh.Create(Loader, EncodingId);
        Loader.Position := currentPosition;

        IsOk := True;
        Break;
    end;
  end;

  if (IsOk = False) then
    raise Exception.Create('TOpenTypeCMapTable.ReadFrom: Can find platform or encoding ID.');
end;

{ TOpenTypeCMapFmt4Table }

constructor TOpenTypeCMapFmt4TableEh.Create(Loader: TOpenTypeFontDataLoaderEh; AnEncodingId: TOpenTypeWinEncodingIdEh);
begin
  EncodingId := AnEncodingId;
  ReadFrom(Loader);
end;

procedure TOpenTypeCMapFmt4TableEh.ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
var
  SegCount: Integer;
  I: Integer;
begin
  Format := Loader.ReadUInt16();
  Length := Loader.ReadUInt16();
  Language := Loader.ReadUInt16();  
  SegCountX2 := Loader.ReadUInt16();
  SearchRange := Loader.ReadUInt16();
  EntrySelector := Loader.ReadUInt16();
  RangeShift := Loader.ReadUInt16();

  SegCount := SegCountX2 div 2;
  GlyphCount := (length - (16 + 8 * segCount)) div 2;

  SetLength(EndCount, SegCount);
  SetLength(StartCount, SegCount);
  SetLength(IdDelta, SegCount);
  SetLength(IdRangeOffs, SegCount);

  SetLength(GlyphIdArray, GlyphCount);

  for I := 0 to SegCount - 1 do
   EndCount[I] := Loader.ReadUInt16;

  Loader.ReadUInt16;

  for I := 0 to SegCount - 1 do
    StartCount[I] := Loader.ReadUInt16;

  for I := 0 to SegCount - 1 do
    IdDelta[I] := Loader.ReadInt16;

  for I := 0 to SegCount - 1 do
    IdRangeOffs[I] := Loader.ReadUInt16;

  for I := 0 to GlyphCount - 1 do
    GlyphIdArray[I] := Loader.ReadUInt16;
end;

{ TOpenTypeFontHeaderTable }

constructor TOpenTypeFontHeaderTableEh.Create(Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(Loader);
end;

procedure TOpenTypeFontHeaderTableEh.ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
begin
  MajorVersion := Loader.ReadUInt16();
  MinorVersion := Loader.ReadUInt16();
  FontRevision := Loader.ReadInt32();
  CheckSumAdjustment := Loader.ReadUInt32();
  MagicNumber := Loader.ReadUInt32();
  Flags := Loader.ReadUInt16();
  UnitsPerEm := Loader.ReadUInt16();
  Created := Loader.ReadInt64();
  Modified := Loader.ReadInt64();
  XMin := Loader.ReadInt16();
  YMin := Loader.ReadInt16();
  XMax := Loader.ReadInt16();
  YMax := Loader.ReadInt16();
  MacStyle := Loader.ReadUInt16();
  LowestRecPPEM := Loader.ReadUInt16;
  FontDirectionHint := Loader.ReadInt16;
  IndexToLocFormat := Loader.ReadInt16; 
  GlyphDataFormat := Loader.ReadInt16; 
end;

{ TOpenTypeHorizontalHeaderTable }

constructor TOpenTypeHorizontalHeaderTableEh.Create(Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(Loader);
end;

procedure TOpenTypeHorizontalHeaderTableEh.ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
begin
  MajorVersion := Loader.ReadUInt16();
  MinorVersion := Loader.ReadUInt16();
  Ascender := Loader.ReadInt16();
  Descender := Loader.ReadInt16();
  LineGap := Loader.ReadInt16();
  AdvanceWidthMax := Loader.ReadUInt16();
  MinLeftSideBearing := Loader.ReadInt16();
  MinRightSideBearing := Loader.ReadInt16();
  XMaxExtent := Loader.ReadInt16();
  CaretSlopeRise := Loader.ReadInt16();
  CaretSlopeRun := Loader.ReadInt16();
  Reserved1 := Loader.ReadInt16();
  Reserved2 := Loader.ReadInt16();
  Reserved3 := Loader.ReadInt16();
  Reserved4 := Loader.ReadInt16();
  Reserved5 := Loader.ReadInt16();
  MetricDataFormat := Loader.ReadInt16();
  NumberOfHMetrics := Loader.ReadUInt16();
end;

{ TOpenTypeHorizontalMetricsTable }

constructor TOpenTypeHorizontalMetricsTableEh.Create(FontData: TOpenTypeFontDataEh; Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(FontData, Loader);
end;

procedure TOpenTypeHorizontalMetricsTableEh.ReadFrom(FontData: TOpenTypeFontDataEh; Loader: TOpenTypeFontDataLoaderEh);
var
  NumberOfHMetrics: Integer;
  I: Integer;
  LeftSideBearingsCount: Integer;
begin
  if (FontData.FHrztlHeadTable <> nil) and (FontData.FMaxpTable <> nil) then
  begin
      NumberOfHMetrics := FontData.FHrztlHeadTable.NumberOfHMetrics;
      LeftSideBearingsCount := FontData.FMaxpTable.NumGlyphs - NumberOfHMetrics;

      System.Assert(NumberOfHMetrics <> 0);
      System.Assert(LeftSideBearingsCount >= 0);

      SetLength(HorMetrics, NumberOfHMetrics);
      for I := 0 to NumberOfHMetrics - 1 do
      begin
        HorMetrics[I].AdvanceWidth := Loader.ReadUInt16;
        HorMetrics[I].Lsb := Loader.ReadInt16;
      end;

      if (LeftSideBearingsCount > 0) then
      begin
        SetLength(LeftSideBearing, LeftSideBearingsCount);
        for I := 0 to LeftSideBearingsCount - 1 do
          LeftSideBearing[I] := Loader.ReadInt16();
      end;
  end;
end;

{ TOpenTypeMaximumProfileTable }

constructor TOpenTypeMaximumProfileTableEh.Create(Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(Loader);
end;

procedure TOpenTypeMaximumProfileTableEh.ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
begin
  MajorVersion := Loader.ReadUInt16();
  MinorVersion := Loader.ReadUInt16();
  NumGlyphs := Loader.ReadUInt16();
  MaxPoints := Loader.ReadUInt16();
  MaxContours := Loader.ReadUInt16();
  MaxCompositePoints := Loader.ReadUInt16();
  MaxCompositeContours := Loader.ReadUInt16();
  MaxZones := Loader.ReadUInt16();
  MaxTwilightPoints := Loader.ReadUInt16();
  MaxStorage := Loader.ReadUInt16();
  MaxFunctionDefs := Loader.ReadUInt16();
  MaxInstructionDefs := Loader.ReadUInt16();
  MaxStackElements := Loader.ReadUInt16();
  MaxSizeOfInstructions := Loader.ReadUInt16();
  MaxComponentElements := Loader.ReadUInt16();
  MaxComponentDepth := Loader.ReadUInt16();
end;

{ TOpenTypeNamingTable }

constructor TOpenTypeNamingTableEh.Create(Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(Loader);
end;

procedure TOpenTypeNamingTableEh.ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
var
  I: Integer;
  NameRecord: TOpenTypeFontNameRecordEh;
  TextBuffer: TBytes;
  P1, P2: Pointer;
  ThisTablePos: Int64;
begin
  ThisTablePos := Loader.FontDataStream.Position;

  Version := Loader.ReadUInt16();
  Count := Loader.ReadUInt16();
  StorageOffset := Loader.ReadUInt16();

  SetLength(NameRecords, Count);

  for I := 0 to Count - 1 do
  begin
    NameRecord.PlatformID := Loader.ReadUInt16();
    NameRecord.EncodingID := Loader.ReadUInt16();
    NameRecord.LanguageID := Loader.ReadUInt16();
    NameRecord.NameID := Loader.ReadUInt16();
    NameRecord.Length := Loader.ReadUInt16();
    NameRecord.Offset := Loader.ReadUInt16();

    SetLength(TextBuffer, NameRecord.Length);
    P1 := PByte(Loader.FontDataStream.Memory) + ThisTablePos + StorageOffset + NameRecord.Offset;
    P2 := Pointer(TextBuffer);
    Move(P1^, P2^, NameRecord.length);

    
    
    if (NameRecord.PlatformID = 0) or (NameRecord.PlatformID = 3) then
    begin

      
      if (NameRecord.NameID = 1) and (NameRecord.LanguageID = $0409) then
      begin
        if (Name = '') then
          Name := TEncoding.BigEndianUnicode.GetString(TextBuffer, 0, Length(TextBuffer));
      end;

      
      if (NameRecord.NameID = 2) and (NameRecord.LanguageID = $0409) then
      begin
        if (Style = '') then
          Style := TEncoding.BigEndianUnicode.GetString(TextBuffer, 0, Length(TextBuffer));
      end;

      

      
      if (NameRecord.NameID = 4) and (NameRecord.LanguageID = $0409) then
      begin
        if (FullFontName = '') then
          FullFontName := TEncoding.BigEndianUnicode.GetString(TextBuffer, 0, Length(TextBuffer));
      end;
    end;
  end;
end;

{ TOpenTypeOS2Table }

constructor TOpenTypeOS2TableEh.Create(Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(Loader);
end;

procedure TOpenTypeOS2TableEh.ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
begin
  Version := Loader.ReadUInt16;
  XAvgCharWidth := Loader.ReadInt16;
  UsWeightClass := Loader.ReadUInt16;
  UsWidthClass := Loader.ReadUInt16;
  FsType := Loader.ReadUInt16;
  YSubscriptXSize := Loader.ReadInt16;
  YSubscriptYSize := Loader.ReadInt16;
  YSubscriptXOffset := Loader.ReadInt16;
  YSubscriptYOffset := Loader.ReadInt16;
  YSuperscriptXSize := Loader.ReadInt16;
  YSuperscriptYSize := Loader.ReadInt16;
  YSuperscriptXOffset := Loader.ReadInt16;
  YSuperscriptYOffset := Loader.ReadInt16;
  YStrikeoutSize := Loader.ReadInt16;
  YStrikeoutPosition := Loader.ReadInt16;
  SFamilyClass := Loader.ReadInt16;
  Panose := Loader.ReadBytes(10);
  UlUnicodeRange1 := Loader.ReadUInt32; 
  UlUnicodeRange2 := Loader.ReadUInt32; 
  UlUnicodeRange3 := Loader.ReadUInt32; 
  UlUnicodeRange4 := Loader.ReadUInt32; 
  AchVendID := Loader.ReadString(4);
  FsSelection := Loader.ReadUInt16;
  UsFirstCharIndex := Loader.ReadUInt16;
  UsLastCharIndex := Loader.ReadUInt16;
  STypoAscender := Loader.ReadInt16;
  STypoDescender := Loader.ReadInt16;
  STypoLineGap := Loader.ReadInt16;
  UsWinAscent := Loader.ReadUInt16;
  UsWinDescent := Loader.ReadUInt16;

  if (Version >= 1) then
  begin
    
    UlCodePageRange1 :=  Loader.ReadUInt32; 
    UlCodePageRange2 :=  Loader.ReadUInt32; 

    if (Version >= 2) then
    begin
      
      SxHeight :=  Loader.ReadInt16;
      SCapHeight :=  Loader.ReadInt16;
      UsDefaultChar :=  Loader.ReadUInt16;
      UsBreakChar :=  Loader.ReadUInt16;
      UsMaxContext :=  Loader.ReadUInt16;

      if (Version >= 5) then
      begin
        
        UsLowerOpticalPointSize :=  Loader.ReadUInt16;
        UsUpperOpticalPointSize :=  Loader.ReadUInt16;
      end;
    end;
  end;
end;

{ TOpenTypePostScriptInfoTable }

constructor TOpenTypePostScriptInfoTableEh.Create(Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(Loader);
end;

procedure TOpenTypePostScriptInfoTableEh.ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
begin
  MajorVersion := Loader.ReadUInt16;
  MinorVersion := Loader.ReadUInt16;
  
  ItalicAngle := Loader.ReadSingle;
  UnderlinePosition := Loader.ReadInt16;
  UnderlineThickness := Loader.ReadInt16;
  IsFixedPitch := Loader.ReadUInt32;
  MinMemType42 := Loader.ReadUInt32;
  MaxMemType42 := Loader.ReadUInt32;
  MinMemType1 := Loader.ReadUInt32;
  MaxMemType1 := Loader.ReadUInt32;
end;

{ TOpenTypeControlValueTable }

constructor TOpenTypeControlValueTableEh.Create(TableEntry: TOpenTypeTableDirectoryEntryEh;
  Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(TableEntry, Loader);
end;

procedure TOpenTypeControlValueTableEh.ReadFrom(TableEntry: TOpenTypeTableDirectoryEntryEh;
  Loader: TOpenTypeFontDataLoaderEh);
var
  I: Integer;
begin
  SetLength(ControlValues, TableEntry.Length div 2);
  for I := 0 to Length(ControlValues) - 1 do
    ControlValues[I] := Loader.ReadInt16;
end;

{ TOpenTypeFontProgramTable }

constructor TOpenTypeFontProgramTableEh.Create(TableEntry: TOpenTypeTableDirectoryEntryEh;
  Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(TableEntry, Loader);
end;

procedure TOpenTypeFontProgramTableEh.ReadFrom(TableEntry: TOpenTypeTableDirectoryEntryEh;
  Loader: TOpenTypeFontDataLoaderEh);
var
  I: Integer;
begin
  SetLength(Instructions, TableEntry.Length);
  for I := 0 to Length(Instructions) - 1 do
    Instructions[I] := Loader.ReadUInt8;
end;

{ TOpenTypeGlyphDataTable }

constructor TOpenTypeGlyphDataTableEh.Create(Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(Loader);
end;

procedure TOpenTypeGlyphDataTableEh.ReadFrom(Loader: TOpenTypeFontDataLoaderEh);
begin
end;

{ TOpenTypeIndexToLocationTable }

constructor TOpenTypeIndexToLocationTableEh.Create(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create;
  ReadFrom(FontData, TableEntry, Loader);
end;

procedure TOpenTypeIndexToLocationTableEh.ReadFrom(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
var
  I: Integer;
begin
  if (FontData.FHeadTable.IndexToLocFormat = 0) then
  begin
    SetLength(LocalOffset, TableEntry.Length div 2);
    for I := 0 to Length(LocalOffset) - 1 do
      LocalOffset[I] := 2 * Loader.ReadUInt16();
  end else
  begin
    SetLength(LocalOffset, TableEntry.Length div 4);
    for I := 0 to Length(LocalOffset) - 1 do
      LocalOffset[I] := Loader.ReadUInt32();
  end;
end;

{ TOpenTypeControlValueProgramTable }

constructor TOpenTypeControlValueProgramTableEh.Create(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create(FontData, TableEntry, Loader);
end;

procedure TOpenTypeControlValueProgramTableEh.ReadFrom(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
var
  I: Integer;
begin
  SetLength(Instructions, TableEntry.Length);
  for I := 0 to Length(Instructions) - 1 do
    Instructions[I] := Loader.ReadUInt8;
end;

{ TOpenTypeGlyphSubstitutionTable }

constructor TOpenTypeGlyphSubstitutionTableEh.Create(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
begin
  inherited Create(FontData, TableEntry, Loader);
end;

procedure TOpenTypeGlyphSubstitutionTableEh.ReadFrom(FontData: TOpenTypeFontDataEh;
  TableEntry: TOpenTypeTableDirectoryEntryEh; Loader: TOpenTypeFontDataLoaderEh);
begin
end;

{ TPdfType0FontEh }

constructor TPdfType0FontEh.Create(ADocument: TPdfBaseDocumentEh; AFontKeyName: String;
  AFontName: String; AIsBold: Boolean; AIsItalic: Boolean; AFontCode: String);
begin
  inherited Create(ADocument);

  FFontKeyName := AFontKeyName;
  FFontName := AFontName;
  FIsBold := AIsBold;
  FIsItalic := AIsItalic;
  FFontCode := AFontCode;
  
  FDescendantFont := TPdfCIDFontEh.Create(Self);
  FPdfToUnicodeMap := TPdfToUnicodeMapEh.Create(Self);
  FUsedChars := TUsedCharsEh.Create;
  FUsedGlyphs := TUsedGlyphsEh.Create;

  InitFontStream;
  InitOpenTypeFontTables;
  InitMetrics;

  InitFont;
end;

destructor TPdfType0FontEh.Destroy;
begin
  Items.Clear();

  FreeAndNil(FFontLayoutStream);
  FreeAndNil(FDescendantFont);
  FreeAndNil(FPdfToUnicodeMap);
  FreeAndNil(FUsedChars);
  FreeAndNil(FUsedGlyphs);
  FreeAndNil(FOpenTypeFontData);

  inherited Destroy;
end;

class function TPdfType0FontEh.CreateFontKeyName(AFontName: String; AIsBold,
  AIsItalic: Boolean): String;
begin
  Result := AFontName;
  if (AIsBold) then
    Result := Result  + ':Bold';
  if (AIsItalic) then
    Result := Result  + ':Italic';
end;

function TPdfType0FontEh.AddUsedCharsGetGlyphIndexes(Text: String): TWordDynArray;
var
  I: Integer;
  WideText: WideString;
begin
  WideText := WideString(Text);
  SetLength(Result, Length(WideText));
  for I := 1 to Length(WideText) do
  begin
    Result[I-1] := AddUsedCharGetGlyphIndex(WideText[I]);
  end;
end;

function TPdfType0FontEh.AddUsedCharGetGlyphIndex(Ch: WideChar): Word;
var
  {$IFDEF FPC}
  FoundIndex: SizeInt;
  {$ELSE}
  FoundIndex: Integer;
  {$ENDIF}
  DummyRec: TUsedCharRecEh;
  FontFileGlyphIndex: Word;
begin
  DummyRec.CharCode := Ch;
  DummyRec.GlyphIndex := 0;
  FoundIndex := 0;

  if (FUsedChars.Count > 0) and
     (FUsedChars.BinarySearch(DummyRec, FoundIndex) = True) then
  begin
    Result := FUsedChars[FoundIndex].GlyphIndex;
  end else
  begin
    FontFileGlyphIndex := FOpenTypeFontData.GlyphIndexByCharCode(Ch);
    AddUsedFontFileGlyphIndex(FontFileGlyphIndex);
    DummyRec.GlyphIndex := FontFileGlyphIndex;
    FUsedChars.Add(DummyRec);
    Result := FontFileGlyphIndex;
  end;
end;

procedure TPdfType0FontEh.AddUsedChars(Text: String);
var
  I: Integer;
begin
  for I := 1 to Length(Text) do
  begin
    AddUsedChar(Text[I]);
  end;
end;

procedure TPdfType0FontEh.AddUsedChar(Ch: WideChar);
var
  {$IFDEF FPC}
  FoundIndex: SizeInt;
  {$ELSE}
  FoundIndex: Integer;
  {$ENDIF}
  DummyRec: TUsedCharRecEh;
  FontFileGlyphIndex: Word;
begin
  DummyRec.CharCode := Ch;
  DummyRec.GlyphIndex := 0;

  if not (FUsedChars.BinarySearch(DummyRec, FoundIndex)) then
  begin
    FontFileGlyphIndex := FOpenTypeFontData.GlyphIndexByCharCode(Ch);
    AddUsedFontFileGlyphIndex(FontFileGlyphIndex);
    DummyRec.GlyphIndex := FontFileGlyphIndex;
    FUsedChars.Insert(FoundIndex, DummyRec);
  end;
end;

procedure TPdfType0FontEh.AddUsedFontFileGlyphIndex(FontFileGlyphIndex: Word);
var
  DummyRec: TUsedGlyphRecEh;
  {$IFDEF FPC}
  FoundIndex: SizeInt;
  {$ELSE}
  FoundIndex: Integer;
  {$ENDIF}
begin
  DummyRec.GlyphIndex := FontFileGlyphIndex;
  DummyRec.GlyphWidth := -1;

  if (FUsedGlyphs.Count > 0) and
     (FUsedGlyphs.BinarySearch(DummyRec, FoundIndex) = True) then
  begin
    DoNothing();
  end else
  begin
    DummyRec.GlyphWidth := FOpenTypeFontData.GlyphWidthByGlyphIndex(FontFileGlyphIndex, True);
    FUsedGlyphs.Add(DummyRec);
  end;
end;

procedure TPdfType0FontEh.InitMetrics;
var
  ACanvas: TCanvas;
  Style: TFontStyles;
{$IFDEF MSWINDOWS}
  AOutlineTextMetric: TOutlineTextMetric;
{$ELSE}
{$ENDIF}
begin
  ACanvas := GetScreenCanvas;

  ACanvas.Font.Name := FFontName;
  FUnitsPerEm := FOpenTypeFontData.HeadTable.UnitsPerEm;
  ACanvas.Font.Height := - UnitsPerEm;

  FUnderlineShift := FOpenTypeFontData.PostScriptTable.UnderlinePosition;
  FUnderlineSize := FOpenTypeFontData.PostScriptTable.UnderlineThickness;

  FStrikeoutShift := FOpenTypeFontData.Os2Table.YStrikeoutPosition;
  FStrikeoutSize :=  FOpenTypeFontData.Os2Table.YStrikeoutSize;

  Style := [];
  if (FIsBold = True) then
    Style := Style + [fsBold];
  if (FIsItalic  = True) then
    Style := Style + [fsItalic];

  ACanvas.Font.Style := Style;

{$IFDEF MSWINDOWS}
  AOutlineTextMetric.otmSize := SizeOf(TOutlineTextMetric);
  GetOutlineTextMetrics(ACanvas.Handle, SizeOf(AOutlineTextMetric), @AOutlineTextMetric);
  FOutlineTextMetric.TextMetricsAscent := AOutlineTextMetric.otmTextMetrics.tmAscent;
  FOutlineTextMetric.TextMetricsDescent := AOutlineTextMetric.otmTextMetrics.tmDescent;
  FOutlineTextMetric.TextMetricsHeight := AOutlineTextMetric.otmTextMetrics.tmHeight;
  FOutlineTextMetric.TextMetricsCharSet := AOutlineTextMetric.otmTextMetrics.tmCharSet;
  FOutlineTextMetric.TextMetricsInternalLeading := AOutlineTextMetric.otmTextMetrics.tmInternalLeading;
  FOutlineTextMetric.TextMetricsExternalLeading := AOutlineTextMetric.otmTextMetrics.tmExternalLeading;
  FOutlineTextMetric.TextMetricsWeight := AOutlineTextMetric.otmTextMetrics.tmWeight;
  FOutlineTextMetric.TextMetricsOverhang := AOutlineTextMetric.otmTextMetrics.tmOverhang;
  FOutlineTextMetric.ItalicAngle := AOutlineTextMetric.otmItalicAngle;
  FOutlineTextMetric.FontBox := AOutlineTextMetric.otmrcFontBox;
{$ELSE}
  FOutlineTextMetric.TextMetricsAscent := 0;
  FOutlineTextMetric.TextMetricsDescent := 0;
  FOutlineTextMetric.TextMetricsHeight := 0;
  FOutlineTextMetric.TextMetricsCharSet := 0;
  FOutlineTextMetric.TextMetricsInternalLeading := 0;
  FOutlineTextMetric.TextMetricsExternalLeading := 0;
  FOutlineTextMetric.ItalicAngle := 0;
  FOutlineTextMetric.FontBox := Rect(0, 0, 0, 0);
{$ENDIF}
end;

procedure TPdfType0FontEh.InitFont;
var
  DescendantFonts: TPdfArrayEh;
begin
  FDescendantFont.InitFont;

  Items.Add('/BaseFont', TPdfNameEh.Create('/' + FontKeyName));
  Items.Add('/Encoding', TPdfNameEh.Create('/Identity-H'));
  Items.Add('/Type', TPdfNameEh.Create('/Font'));
  Items.Add('/Subtype', TPdfNameEh.Create('/Type0'));

  DescendantFonts := TPdfArrayEh.Create;
  DescendantFonts.Items.Add(DescendantFont);
  Items.Add('/DescendantFonts', DescendantFonts);
end;

procedure TPdfType0FontEh.InitFontStream;
{$IFDEF FPC_LINUX}
begin
end;
{$ELSE}
var
  ACanvas: TCanvas;
  Style: TFontStyles;
  BufSize: Integer;
begin
  ACanvas := GetScreenCanvas;

  ACanvas.Font.Name := FFontName;
  ACanvas.Font.Size := 1000;

  Style := [];
  if (FIsBold = True) then
    Style := Style + [fsBold];
  if (FIsItalic  = True) then
    Style := Style + [fsItalic];

  ACanvas.Font.Style := Style;

  BufSize := Windows.GetFontData(ACanvas.Handle, 0, 0, nil, 0);

  if (BufSize < 0 ) then
    raise Exception.Create('TPdfType0Font.InitFontLayout: Cannot retrieve font data.');

  FFontLayoutStream := TMemoryStream.Create;
  FFontLayoutStream.Size := BufSize;

  Windows.GetFontData(ACanvas.Handle, 0, 0, FFontLayoutStream.Memory, BufSize);
end;
{$ENDIF}

procedure TPdfType0FontEh.InitOpenTypeFontTables;
begin
  FOpenTypeFontData := TOpenTypeFontDataEh.Create;
  FOpenTypeFontData.LoadFromDataStream(FFontLayoutStream);
end;

function lpfnAllocate(Size: Integer): Pointer; cdecl;
begin
  GetMem(result,Size);
end;

function lpfnReAllocate(Buffer: pointer; Size: Integer): Pointer; cdecl;
begin
  ReallocMem(Buffer, Size);
  result := Buffer;
end;

procedure lpfnFree(Buffer: Pointer); cdecl;
begin
  FreeMem(Buffer);
end;

{$IFDEF MSWINDOWS}
function CreateFontPackageProc(SrcBuffer: Pointer;
                               SrcBufferSize: Cardinal;
                               UsedUniCodeChars: TWordDynArray): TBytes;
const
  TTFMFP_SUBSET = 0;
  TTFCFP_MS_PLATFORMID = 3;
  TTFCFP_UNICODE_CHAR_SET = 1;
  TTFCFP_FLAGS_SUBSET = 1;
var
  SubSetData: Pointer;
  SubSetMem: Cardinal;
  SubSetSize: Cardinal;
  usFlags: Word;
  ttcIndex: Word;
begin
  SubSetData := nil;
  SubSetMem := 0;
  SubSetSize := 0;
  usFlags := TTFCFP_FLAGS_SUBSET;
  ttcIndex := 0;

  if CreateFontPackage(SrcBuffer, SrcBufferSize,
      @SubSetData, @SubSetMem,  @SubSetSize,
      usFlags,  ttcIndex, TTFMFP_SUBSET,  0,
      TTFCFP_MS_PLATFORMID, TTFCFP_UNICODE_CHAR_SET,
      Pointer(UsedUniCodeChars), Length(UsedUniCodeChars),
      @lpfnAllocate, @lpfnReAllocate, @lpfnFree, nil) = 0 then
  begin
    SetLength(Result, Integer(SubSetSize));
    Move(SubSetData^, Result[0], SubSetSize);
    FreeMem(SubSetData);
  end;
end;

{$ELSE}
function CreateFontPackageProc(SrcBuffer: Pointer;
                               SrcBufferSize: Cardinal;
                               UsedUniCodeChars: TWordDynArray): TBytes;
begin
  Result := nil;
end;
{$ENDIF} 

function TPdfType0FontEh.CreateFontSubsetFileData: TBytes;
var
  UsedUniCodeChars: TWordDynArray;
  I: Integer;
begin
  UsedUniCodeChars := nil;
  SetLength(UsedUniCodeChars, FUsedChars.Count);
  for I := 0 to FUsedChars.Count - 1 do
    UsedUniCodeChars[I] := Word(FUsedChars[I].CharCode);

  Result := CreateFontPackageProc(FFontLayoutStream.Memory,
                                  Cardinal(FFontLayoutStream.Size),
                                  UsedUniCodeChars);
end;

{ TPdfCIDFontEh }

constructor TPdfCIDFontEh.Create(AMasterFont: TPdfType0FontEh);
begin
  inherited Create(AMasterFont.Document);

  FMasterFont := AMasterFont;
  FFontDescriptor := TPdfFontDescriptorEh.Create(Self);
end;

destructor TPdfCIDFontEh.Destroy;
begin
  Items.Clear;
  FreeAndNil(FFontDescriptor);
  inherited Destroy;
end;

function TPdfCIDFontEh.GetName: String;
begin
  Result := FMasterFont.FontKeyName;
end;

procedure TPdfCIDFontEh.InitFont;
var
  CIDSystemInfo: TPdfDictionaryEh;
begin
  FFontDescriptor.InitFontDescriptor;

  Items.Add('/Type', TPdfNameEh.Create('/Font'));
  Items.Add('/Subtype', TPdfNameEh.Create('/CIDFontType2'));
  Items.Add('/BaseFont', TPdfNameEh.Create('/' + Name));

  CIDSystemInfo := TPdfDictionaryEh.Create;
  CIDSystemInfo.Items.Add('/Ordering', TPdfStringEh.Create('Identity', TPdfStringType.Regular));
  CIDSystemInfo.Items.Add('/Registry', TPdfStringEh.Create('Adobe', TPdfStringType.Regular));
  CIDSystemInfo.Items.Add('/Supplement', TPdfIntegerNumberEh.Create(0));
  Items.Add('/CIDSystemInfo', CIDSystemInfo);

  Items.Add('/FontDescriptor', FFontDescriptor);
end;

procedure TPdfCIDFontEh.PrepareForExport;
var
  WidthsObj: TPdfObjectEh;
  WidthsArr: TPdfArrayEh;
  I: Integer;
  UsedGlyph: TUsedGlyphRecEh;
  GlyphWidthArr: TPdfArrayEh;
begin
  inherited PrepareForExport;

  if (Items.TryGetValue('/W', WidthsObj) = False) then
  begin
    WidthsArr := TPdfArrayEh.Create;
    Items.Add('/W', WidthsArr);
  end else
  begin
    WidthsArr := TPdfArrayEh(WidthsObj);
  end;

  WidthsArr.Items.Clear;

  for I := 0 to FMasterFont.FUsedGlyphs.Count - 1 do
  begin
    UsedGlyph := FMasterFont.FUsedGlyphs[I];
    WidthsArr.Items.Add(TPdfIntegerNumberEh.Create(UsedGlyph.GlyphIndex));

    GlyphWidthArr := TPdfArrayEh.Create;
    GlyphWidthArr.Items.Add(TPdfIntegerNumberEh.Create(UsedGlyph.GlyphWidth));
    WidthsArr.Items.Add(GlyphWidthArr);
  end;
end;

{ TPdfToUnicodeMapEh }

constructor TPdfToUnicodeMapEh.Create(AMasterFont: TPdfType0FontEh);
begin
  inherited Create(AMasterFont.Document);
  FMasterFont := AMasterFont;
  InitMap;
end;

destructor TPdfToUnicodeMapEh.Destroy;
begin
  inherited Destroy;
end;

function TPdfToUnicodeMapEh.CreateBoundStream: TPdfDictionaryStreamEh;
begin
  Result := TPdfAsciiStreamEh.Create;
end;

function TPdfToUnicodeMapEh.GetBoundStream: TPdfAsciiStreamEh;
begin
  Result := TPdfAsciiStreamEh(inherited BoundStream);
end;

procedure TPdfToUnicodeMapEh.InitMap;
begin
end;

procedure TPdfToUnicodeMapEh.PrepareStream;
var
  MinChar, MaxChar: WideChar;
  I: Integer;
  HexCh: String;
begin
  if (FMasterFont.FUsedChars.Count = 0) then Exit;

  MinChar := FMasterFont.FUsedChars[0].CharCode;
  MaxChar := FMasterFont.FUsedChars[FMasterFont.FUsedChars.Count - 1].CharCode;

  BoundStream.WriteLineStr('/CIDInit /ProcSet findresource begin');
  BoundStream.WriteLineStr('12 dict begin');
  BoundStream.WriteLineStr('begincmap');
  BoundStream.WriteLineStr('/CIDSystemInfo << /Registry (Adobe)/Ordering (UCS)/Supplement 0>> def');
  BoundStream.WriteLineStr('/CMapName /Adobe-Identity-UCS def /CMapType 2 def');
  BoundStream.WriteLineStr('1 begincodespacerange');
  BoundStream.WriteLineStr('<' + CharToHexEh(MinChar) + '><' + CharToHexEh(MaxChar) +'>'); 
  BoundStream.WriteLineStr('endcodespacerange');
  BoundStream.WriteLineStr('12 beginbfrange');

  for I := 0 to FMasterFont.FUsedChars.Count - 1 do
  begin
    HexCh := CharToHexEh(FMasterFont.FUsedChars[I].CharCode);
    BoundStream.WriteLineStr('<' + HexCh + '><' + HexCh + '><' + HexCh +'>'); 
  end;

  BoundStream.WriteLineStr('endbfrange');
  BoundStream.WriteLineStr('endcmap CMapName currentdict /CMap defineresource pop end end');
end;

procedure TPdfToUnicodeMapEh.PrepareForExport;
begin
  inherited PrepareForExport;

  BoundStream.Clear;
  PrepareStream;

  Items.Add('/Length', TPdfIntegerNumberEh.Create(BoundStream.Size));
end;

{ TPdfFontDescriptorEh }

constructor TPdfFontDescriptorEh.Create(AMasterFont: TPdfCIDFontEh);
begin
  inherited Create(AMasterFont.Document);
  FMasterFont := AMasterFont;
  FFontFile := TPdfFontFileEh.Create(Self);
end;

destructor TPdfFontDescriptorEh.Destroy;
begin
  Items.Clear;
  FreeAndNil(FFontFile);
  inherited Destroy;
end;

procedure TPdfFontDescriptorEh.InitFontDescriptor;
var
  MF: TPdfType0FontEh;
  Flags: Integer;
  MediaBoxArr: TPdfArrayEh;
  IntValue: Integer;
  FontBox: TRect;
  UPE: UInt16;
begin
  Items.Add('/Type', TPdfNameEh.Create('/FontDescriptor'));

  MF := FMasterFont.FMasterFont;

  Items.Add('/FontName', TPdfNameEh.Create('/' + MF.FontKeyName));

  UPE := FMasterFont.FMasterFont.UnitsPerEm;
  IntValue := Round(MF.FOutlineTextMetric.TextMetricsAscent / UPE * 1000);
  Items.Add('/Ascent', TPdfIntegerNumberEh.Create(IntValue)); 

  Items.Add('/CapHeight', TPdfIntegerNumberEh.Create(0));

  IntValue := Round(MF.FOutlineTextMetric.TextMetricsDescent / UPE * 1000);
  Items.Add('/Descent',TPdfIntegerNumberEh.Create(IntValue)); 

  Items.Add('/ItalicAngle', TPdfIntegerNumberEh.Create(MF.FOutlineTextMetric.ItalicAngle));
  Items.Add('/StemV', TPdfIntegerNumberEh.Create(0));

  if MF.FOutlineTextMetric.TextMetricsCharSet = SYMBOL_CHARSET
    then Flags := PDF_FONT_SYMBOLIC
    else Flags := PDF_FONT_STD_CHARSET;
  Items.Add('/Flags', TPdfIntegerNumberEh.Create(Flags));

  MediaBoxArr := TPdfArrayEh.Create;
  FontBox.Left := Round(MF.FOutlineTextMetric.FontBox.Left / UPE * 1000);
  FontBox.Bottom := Round(MF.FOutlineTextMetric.FontBox.Bottom / UPE * 1000);
  FontBox.Right := Round(MF.FOutlineTextMetric.FontBox.Right / UPE * 1000);
  FontBox.Top := Round(MF.FOutlineTextMetric.FontBox.Top / UPE * 1000);

  MediaBoxArr.Items.Add(TPdfIntegerNumberEh.Create(FontBox.Left));
  MediaBoxArr.Items.Add(TPdfIntegerNumberEh.Create(FontBox.Bottom));
  MediaBoxArr.Items.Add(TPdfIntegerNumberEh.Create(FontBox.Right));
  MediaBoxArr.Items.Add(TPdfIntegerNumberEh.Create(FontBox.Top));
  Items.Add('/FontBBox', MediaBoxArr);

  Items.Add('/FontFile2', FFontFile);
end;

procedure TPdfFontDescriptorEh.PrepareForExport;
begin
  inherited PrepareForExport;
end;

{ TPdfFontFileEh }

constructor TPdfFontFileEh.Create(AFontDescriptor: TPdfFontDescriptorEh);
begin
  inherited Create(AFontDescriptor.FMasterFont.Document);
  FFontDescriptor := AFontDescriptor;
end;

function TPdfFontFileEh.CreateBoundStream: TPdfDictionaryStreamEh;
begin
  Result := TPdfDictionaryStreamEh.Create;
end;

destructor TPdfFontFileEh.Destroy;
begin
  inherited Destroy;
end;

procedure ZipStream(SourceStream, DistantStream: TStream);
begin
  {$IFDEF FPC}
  
  raise Exception.Create('ZCompressStream is not supported in FPC version');
  {$ELSE}
  ZCompressStream(SourceStream, DistantStream);
  {$ENDIF}
end;

procedure TPdfFontFileEh.PrepareForExport;
var
  FontSubsetFileData: TBytes;
  FontSubsetFileDataPtr: Pointer;
  ZippedStream: TMemoryStream;
  SourceStream: TMemoryStream;
  PdfDocument: TPdfDocumentEh;
  Type0Font: TPdfType0FontEh;
begin
  inherited PrepareForExport;

  
  Type0Font := FFontDescriptor.FMasterFont.FMasterFont;
  FontSubsetFileData := Type0Font.CreateFontSubsetFileData;

  SourceStream := TMemoryStream.Create;

  FontSubsetFileDataPtr := Pointer(FontSubsetFileData);
  SourceStream.Write(FontSubsetFileDataPtr^, Length(FontSubsetFileData));
  SourceStream.Position := 0;

  PdfDocument := TPdfDocumentEh(Type0Font.Document);

  if (PdfDocument.CompressStreams) then
  begin
    ZippedStream := TMemoryStream.Create;
    ZipStream(SourceStream, ZippedStream);
    ZippedStream.Position := 0;

    BoundStream.Clear;
    BoundStream.ReadFromGeneralStream(ZippedStream);
    ZippedStream.Free;

    Items.Add('/Length', TPdfIntegerNumberEh.Create(BoundStream.Size));
    Items.Add('/Length1', TPdfIntegerNumberEh.Create(SourceStream.Size));
    Items.Add('/Filter', TPdfNameEh.Create('/FlateDecode'));
  end else
  begin
    BoundStream.Clear;
    BoundStream.ReadFromGeneralStream(SourceStream);

    Items.Add('/Length', TPdfIntegerNumberEh.Create(BoundStream.Size));
  end;

  SourceStream.Free;
end;

{ TUsedChars.TAuthURIComparer }

{$IFDEF FPC}
function TUsedCharsEh.TUsedCharComparer.Compare(constref Left, Right: TUsedCharRecEh): Integer;
{$ELSE}
function TUsedCharsEh.TUsedCharComparer.Compare(const Left, Right: TUsedCharRecEh): Integer;
{$ENDIF}
begin
  Result := Word(Left.CharCode) - Word(Right.CharCode);
end;

{ TUsedCharsEh }

constructor TUsedCharsEh.Create;
begin
  inherited Create(TUsedCharComparer.Create);
  Duplicates := dupError;
end;

{ TUsedGlyphs.TUsedGlyphsComparer }

{$IFDEF FPC}
function TUsedGlyphsEh.TUsedGlyphsComparer.Compare(constref Left, Right: TUsedGlyphRecEh): Integer;
{$ELSE}
function TUsedGlyphsEh.TUsedGlyphsComparer.Compare(const Left, Right: TUsedGlyphRecEh): Integer;
{$ENDIF}
begin
  Result := Word(Left.GlyphIndex) - Word(Right.GlyphIndex);
end;

{ TUsedGlyphsEh }

constructor TUsedGlyphsEh.Create;
begin
  inherited Create(TUsedGlyphsComparer.Create);
  Duplicates := dupError;
end;

initialization
  InitUnit;
finalization
  FreeScreenCanvas;
  FreeUnit;
end.

