{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{               EhLibFmx.DataGrid.ImpExp                }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.ImpExp;

interface

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

uses System.SysUtils, System.Classes, System.Types, System.Contnrs,
  System.StrUtils, Variants,
  System.Generics.Collections, Rtti,
  Data.DB,
  EhLib.TableLinks,
  EhLib.GridTableViews,
  FMX.Types, FMX.Controls, System.UITypes, System.Math, FMX.Platform,
  FMX.Clipboard,
  EhLibUtils, DBUtilsEh,

  EhLibFmx.DataAxisGrids,

  EhLibFmx.CustomDataGrids,
  EhLibFmx.DataGrid.ToolControls,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.Columns
  ;

type
  TFooterValues = array of Variant;

{ TDataGridStringExportOptionsEh }

  TDataGridStringExportOptionsEh = class(TPersistent)
  private
    FUseFormatSettings: Boolean;
    FLineDelimiter: String;
    FCellDelimiter: String;
    FUseEditFormat: Boolean;
    FQuoteChar: Char;
    FIsExportTitle: Boolean;
    FTrailingLineDelimiter: Boolean;
    FFormatSettings: TFormatSettings;
    FIsExportFooter: Boolean;
    FIsExportSelecting: Boolean;
    FExportColumns: TColumnsListEh;

    procedure SetExportColumns(const Value: TColumnsListEh);

  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    property IsExportSelecting: Boolean read FIsExportSelecting write FIsExportSelecting;
    property CellDelimiter: String read FCellDelimiter write FCellDelimiter;
    property LineDelimiter: String read FLineDelimiter write FLineDelimiter;
    property TrailingLineDelimiter: Boolean read FTrailingLineDelimiter write FTrailingLineDelimiter;
    property QuoteChar: Char read FQuoteChar write FQuoteChar;
    property IsExportTitle: Boolean read FIsExportTitle write FIsExportTitle;
    property IsExportFooter: Boolean read FIsExportFooter write FIsExportFooter;
    property UseEditFormat: Boolean read FUseEditFormat write FUseEditFormat;
    property FormatSettings: TFormatSettings read FFormatSettings write FFormatSettings;
    property UseFormatSettings: Boolean read FUseFormatSettings write FUseFormatSettings;
    property ExportColumns: TColumnsListEh read FExportColumns write SetExportColumns;
  end;

{ TDataGridToStringExporterEh }

  TDataGridToStringExporterEh = class
  private
    FGrid: TCustomDataGridEh;
    FExportOptions: TDataGridStringExportOptionsEh;
    FExpCols: TColumnsListEh;
    FooterValues: TFooterValues;
    FStringBuilder: TStringBuilder;
    procedure SetExportOptions(const Value: TDataGridStringExportOptionsEh);
    function GetResultString: String;

  protected
    FLastLineBuffer: String;

    function CreateExportOptions: TDataGridStringExportOptionsEh; virtual;
    function GetFooterValue(ARowIndex, AColIndex: Integer): String; virtual;
    function CheckQuoteString(s: String): String; virtual;

    procedure CalcFooterValues; virtual;
    procedure PushLastLineBuffer; virtual;

    procedure WritePrefix; virtual;
    procedure WriteSuffix; virtual;
    procedure WriteRecord(Row: TDataGridRowEh); virtual;
    procedure WriteTitle; virtual;
    procedure WriteFooter; virtual;
    procedure WriteFooterRow(FooterNo: Integer); virtual;
    procedure WriteString(s: String); virtual;
    procedure WriteValue(s: String); virtual;
    procedure WriteEndOfCell; virtual;
    procedure WriteEndOfLine; virtual;
    procedure WriteDataCell(Column: TDataGridBaseColumnEh; Row: TDataGridRowEh); virtual;
    procedure WriteFooterCell(Column: TDataGridBaseColumnEh; const Text: String); virtual;

  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure ExportGrid; virtual;

    property Grid: TCustomDataGridEh read FGrid write FGrid;
    property ExportOptions: TDataGridStringExportOptionsEh read FExportOptions write SetExportOptions;
    property ResultString: String read GetResultString;
  end;

procedure DataGridEh_DoCutAction(DataGridEh: TCustomDataGridEh; ForWholeGrid: Boolean);
procedure DataGridEh_DoCopyAction(DataGridEh: TCustomDataGridEh; ForWholeGrid: Boolean);
procedure DataGridEh_DoPasteAction(DataGridEh: TCustomDataGridEh; ForWholeGrid: Boolean);
procedure DataGridEh_DoDeleteAction(DataGridEh: TCustomDataGridEh; ForWholeGrid: Boolean);

function WriteDataGridEhToString(DataGridEh: TCustomDataGridEh; ExportOptions: TDataGridStringExportOptionsEh): String;

function ClipboardToVarDynaTable: TVarDynaTableEh;

implementation

uses EhLibLangConsts;

function TextToVarDynaTable(Text: String): TVarDynaTableEh;
var
  StrList: TStringList;
  LineList: TStringList;
  I: Integer;
  J: Integer;
begin
  StrList := TStringList.Create;
  LineList := TStringList.Create;
  LineList.Delimiter := #09; 
  LineList.StrictDelimiter := True;
  try
    StrList.Text := Text;
    SetLength(Result, StrList.Count);

    for I := 0 to StrList.Count - 1 do
    begin
      LineList.DelimitedText := StrList[I];
      SetLength(Result[I], LineList.Count);
      for J := 0 to LineList.Count - 1 do
      begin
        Result[I][J] := LineList[J];
      end;
    end;
  finally
    StrList.Free;
  end;
end;

function ClipboardToVarDynaTable: TVarDynaTableEh;
var
  LClipBoardSvc: IFMXExtendedClipboardService;
  AClipText: String;
begin
  AClipText := '';
  if (TPlatformServices.Current.SupportsPlatformService(IFMXExtendedClipboardService, LClipBoardSvc)) then
  begin
    if LClipBoardSvc.HasText then
      AClipText := LClipBoardSvc.GetText;
  end;

  if AClipText <> '' then
  begin
    Result := TextToVarDynaTable(AClipText);
  end;
end;

procedure PasteVarDynaTableToDataGridEh(VarDynaTable: TVarDynaTableEh;
 DataGridEh: TCustomDataGridEh; ForWholeGrid: Boolean);
var
  i: Integer;
  ColList: TColumnsListEh;
  Inserting: Boolean;
  Appending: Boolean;
  AGrid: TCustomDataGridEh;
  TableView: TBaseGridTableViewEh;
  LineNo: Integer;
  FIgnoreAll: Boolean;

  Eos: Boolean;

  TableColIndex: Integer;
  TableRowIndex: Integer;
  TableRowCount: Integer;
  ASelectedRows: TList<TDataGridRowEh>;
  ASelectedRect: TRect;
//  ARow: TDataGridRowEh;
  RI: Integer;
  PasteSelectionType: TDataGridSelectionTypeEh;

  procedure ReadDataCell(Column: TDataGridBaseColumnEh; CellValue: Variant);
  var
    Field: TTableFieldLinkEh;
    ARow: TDataGridRowEh;
  begin
    ARow := AGrid.CurrentRow;
    if Column.CanModifyCellValue(ARow) then
    begin
      Field := Column.Field;

      if Field.CanModify then
      begin
        TableView.EditCurrentRow;
        if TableView.CurrentRowView.EditState in [TRowLinkEditStateEh.Edit, TRowLinkEditStateEh.Insert] then
        begin
          try
            Column.SetValueAsText(String(CellValue));
          except
            on E: Exception do
            begin
              FIgnoreAll := True;
            end;
          end;
        end;
      end;
    end;
  end;

  procedure ReadRecord(ImpCols: TColumnsListEh);
  var
    i: Integer;
    CellValue: Variant;
  begin
    TableColIndex := 0;

    for i := 0 to ImpCols.Count - 1 do
    begin
      if TableColIndex >= Length(VarDynaTable[TableRowIndex]) then
        Break;
      CellValue := VarDynaTable[TableRowIndex][TableColIndex];
      if AGrid.CurrentRow is TDataGridDataRowEh then
      begin
        ReadDataCell(ImpCols[i], CellValue);
      end;
      Inc(TableColIndex);
    end;

    TableView.PostCurrentRow;
    Inc(TableRowIndex);

    if (TableRowIndex = TableRowCount) then
    begin
      if (PasteSelectionType = TDataGridSelectionTypeEh.Non) then
        Eos := True
      else
        TableRowIndex := 0;
    end;
  end;

  procedure ReadRecordWithInsert(ImpCols: TColumnsListEh);
  begin
    while not Eos do
    begin
      if (LineNo > 0) and
         (TableView.CurrentRowView.EditState in [TRowLinkEditStateEh.Edit, TRowLinkEditStateEh.Insert])
      then
        TableView.PostCurrentRow;

      if Appending
        then TableView.AppendNewRow
        else TableView.InsertNewRow;

      ReadRecord(ImpCols);

      if not Appending and not Eos then
        TableView.GotoNextRow;

      Inc(LineNo);
    end;

    if (LineNo > 1) and
       (TableView.CurrentRowView.EditState in [TRowLinkEditStateEh.Edit, TRowLinkEditStateEh.Insert])
    then
      TableView.PostCurrentRow;
  end;

begin
  Eos := False;
  FIgnoreAll := False;

  TableRowCount := Length(VarDynaTable);
  TableColIndex := 0;
  TableRowIndex := 0;
  AGrid := DataGridEh;
  PasteSelectionType := AGrid.Selection.SelectionType;

  begin

    if ForWholeGrid then
    begin
      AGrid.Selection.Clear;
      AGrid.TableView.GotoFirstRow;
    end;

    TableView := AGrid.TableView;

    begin
      if AGrid.Eof
        then Appending := True
        else Appending := False;

      if (TableView.CurrentRowView <> nil) and
         (TableView.CurrentRowView.EditState = TRowLinkEditStateEh.Insert) then
        Inserting := True
      else
        Inserting := False;

      if not Inserting then
        AGrid.SaveBookmark;

      try
        case AGrid.Selection.SelectionType of

          TDataGridSelectionTypeEh.RecordBookmarks:
            begin
              ColList := TColumnsListEh.Create;
              ColList.Assign(AGrid.VisibleColumns);
              try
                if Inserting then
                  ReadRecordWithInsert(ColList)
                else
                begin
                  ASelectedRows := TList<TDataGridRowEh>.Create;
                  AGrid.Selection.GetSelectedRows(ASelectedRows);

                  for i := 0 to ASelectedRows.Count - 1 do
                  begin
                    AGrid.CurrentRow := ASelectedRows[I];
                    ReadRecord(ColList);
                  end;
                  ASelectedRows.Free;
                end;
              finally
                ColList.Free;
              end;
            end;

          TDataGridSelectionTypeEh.Rectangle:
            begin
              ColList := TColumnsListEh.Create;
              try
                ASelectedRect := AGrid.Selection.GetSelectedRect;
                for i := ASelectedRect.Left to ASelectedRect.Right do
                  ColList.Add(AGrid.VisibleColumns[i]);
                if Inserting then
                  ReadRecordWithInsert(ColList)
                else
                begin
                  for RI := ASelectedRect.Top to ASelectedRect.Bottom do
                  begin
                    AGrid.CurrentRow := AGrid.VisibleRows[RI];
                    ReadRecord(ColList);
                  end;
                end;
              finally
                ColList.Free;
              end;
            end;

          TDataGridSelectionTypeEh.Columns:
            begin
              if Inserting then
                ReadRecordWithInsert(TColumnsListEh(AGrid.Selection.Columns))
              else
              begin
                TableView.GotoFirstRow;
                while TableView.AtEndOfRowsList = False do
                begin
                  ReadRecord(TColumnsListEh(AGrid.Selection.Columns));
                  TableView.GotoNextRow;
                end;
              end;
            end;

          TDataGridSelectionTypeEh.All:
            begin
              ColList := TColumnsListEh.Create;
              ColList.Assign(AGrid.VisibleColumns);
              try
                if Inserting then
                  ReadRecordWithInsert(ColList)
                else
                begin
                  TableView.GotoFirstRow;
                  while TableView.AtEndOfRowsList = False do
                  begin
                    ReadRecord(ColList);
                    TableView.GotoNextRow;
                  end;
                end;
              finally
                ColList.Free;
              end;
            end;

          TDataGridSelectionTypeEh.Non:
            begin
              ColList := TColumnsListEh.Create;
              try
                for i := AGrid.CurrentColIndex to AGrid.VisibleColumns.Count - 1 do
                  ColList.Add(AGrid.VisibleColumns[i]);
                LineNo := 0;
                if Inserting then
                  ReadRecordWithInsert(ColList)
                else
                begin
                  AGrid.RestoreBookmark;
                  while True do
                  begin
                    ReadRecord(ColList);
                    if Eos then Break;
                    TableView.GotoNextRow;
                    Inc(LineNo);
                    if TableView.AtEndOfRowsList then Break;
                  end;
                  if (LineNo >= 1) and
                     (TableView.CurrentRowView.EditState in [TRowLinkEditStateEh.Edit, TRowLinkEditStateEh.Insert])
                  then
                    TableView.PostCurrentRow;
                  if TDataGridAllowedOperationEh.Append in DataGridEh.AllowedOperations then
                  begin
                    Inserting := True;
                    Appending := True;
                    ReadRecordWithInsert(ColList);
                  end;
                end;
              finally
                ColList.Free;
              end;
            end;
        end;
      finally
        if not Inserting then
          AGrid.RestoreBookmark;
      end;
    end;

  end;
end;

procedure DataGridEh_DoCutAction(DataGridEh: TCustomDataGridEh; ForWholeGrid: Boolean);
begin
  DataGridEh_DoCopyAction(DataGridEh, ForWholeGrid);
  DataGridEh_DoDeleteAction(DataGridEh, ForWholeGrid);
end;

procedure DataGridEh_DoCopyAction(DataGridEh: TCustomDataGridEh; ForWholeGrid: Boolean);
var
  GridDataStr: String;
  ExportOptions: TDataGridStringExportOptionsEh;
  ClipService: IFMXClipboardService;
begin
  ExportOptions := TDataGridStringExportOptionsEh.Create;

  ExportOptions.IsExportSelecting := not ForWholeGrid;
  ExportOptions.IsExportFooter := False;
  ExportOptions.IsExportTitle := False;

  GridDataStr := WriteDataGridEhToString(DataGridEh, ExportOptions);
  ExportOptions.Free;

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipService) then
    ClipService.SetClipboard(GridDataStr);
end;

procedure DataGridEh_DoPasteAction(DataGridEh: TCustomDataGridEh; ForWholeGrid: Boolean);
var
 VarDynaTable: TVarDynaTableEh;
begin
  VarDynaTable := ClipboardToVarDynaTable;
  if Length(VarDynaTable) = 0 then Exit;

  PasteVarDynaTableToDataGridEh(VarDynaTable, DataGridEh, ForWholeGrid);
end;

procedure DataGridEh_DoDeleteAction(DataGridEh: TCustomDataGridEh; ForWholeGrid: Boolean);
var
  i: Integer;
  RI: Integer;
  ColList: TColumnsListEh;
  ASelectionType: TDataGridSelectionTypeEh;
  AGrid: TCustomDataGridEh;
  ASelectedRows: TList<TDataGridRowEh>;
  ASelectedRect: TRect;

  procedure ClearColumns;
  var
    i: Integer;
    Column: TDataGridBaseColumnEh;
  begin
    if ColList.Count = 0 then Exit;

    AGrid.TableView.EditCurrentRow();
    for i := 0 to ColList.Count - 1 do
    begin
      if ColList[i].CanModifyCellValue(AGrid.CurrentRow) then
      begin
        Column := ColList[i];
        Column.SetCurrentListItemValue(TValue.Empty);
      end;
    end;
    AGrid.TableView.PostCurrentRow();
  end;

  function DeletePrompt: Boolean;
  var
    Msg: string;
  begin
    Result := True;
    if ASelectionType = TDataGridSelectionTypeEh.RecordBookmarks then
    begin
      if (DataGridEh.Selection.SelectedRowCount > 1) then
        Msg := Format(EhLibLanguageConsts.DeleteMultipleRecordsQuestionEh, [DataGridEh.Selection.SelectedRowCount])
      else
        Msg := 'SDeleteRecordQuestion';
    end
    else if ASelectionType = TDataGridSelectionTypeEh.All then
      Msg := EhLibLanguageConsts.DeleteAllRecordsQuestionEh
    else if ASelectionType = TDataGridSelectionTypeEh.Rectangle then
      Msg := EhLibLanguageConsts.ClearSelectedCells
    else
      Exit;
  end;

begin
  AGrid := DataGridEh;
  begin
    if ForWholeGrid
      then ASelectionType := TDataGridSelectionTypeEh.All
      else ASelectionType := AGrid.Selection.SelectionType;
    if (ASelectionType = TDataGridSelectionTypeEh.Non) or
       (AGrid.TableView.Active = False) or
        not DeletePrompt
    then
      Exit;
    begin
      AGrid.SaveBookmark;
      try
        case ASelectionType of

          TDataGridSelectionTypeEh.RecordBookmarks:
            begin
              try
                try
                  ASelectedRows := TList<TDataGridRowEh>.Create;
                  AGrid.Selection.GetSelectedRows(ASelectedRows);

                  for i := ASelectedRows.Count - 1 downto 0 do
                  begin
                    AGrid.CurrentRow := ASelectedRows[I];
                    AGrid.TableView.DeleteCurrentRow;
                  end;
                  ASelectedRows.Free;
                  AGrid.Selection.Clear;
                finally
                end;
              finally
              end;
            end;

          TDataGridSelectionTypeEh.Rectangle:
            begin
              ColList := TColumnsListEh.Create;
              try
                ASelectedRect := AGrid.Selection.GetSelectedRect;
                for i := ASelectedRect.Left to ASelectedRect.Right do
                  ColList.Add(AGrid.VisibleColumns[i]);
                for RI := ASelectedRect.Top to ASelectedRect.Bottom do
                begin
                  AGrid.CurrentRow := AGrid.VisibleRows[RI];
                  ClearColumns();
                end;
              finally
                ColList.Free;
              end;
            end;

          TDataGridSelectionTypeEh.Columns:
            begin
            end;

          TDataGridSelectionTypeEh.All:
            begin
            end;
        end;
      finally
      end;
    end;
  end;
end;

function WriteDataGridEhToString(DataGridEh: TCustomDataGridEh; ExportOptions: TDataGridStringExportOptionsEh): String;
var
  Exporter: TDataGridToStringExporterEh;
begin
  Exporter := TDataGridToStringExporterEh.Create;

  Exporter.Grid := DataGridEh;
  if ExportOptions <> nil then
    Exporter.ExportOptions := ExportOptions;

  Exporter.ExportGrid;
  Result := Exporter.ResultString;

  Exporter.Free;
end;

{ TDataGridStringExportOptionsEh }

constructor TDataGridStringExportOptionsEh.Create;
begin
  FFormatSettings := System.SysUtils.FormatSettings;
  FUseFormatSettings := False;
  FLineDelimiter := sLineBreak;
  FTrailingLineDelimiter := True;
  FCellDelimiter := #9; 
  FUseEditFormat := False;
  FQuoteChar := '"';
  FIsExportTitle := True;
  FIsExportFooter := True;
  FIsExportSelecting := False;
  FExportColumns := TColumnsListEh.Create;
end;

destructor TDataGridStringExportOptionsEh.Destroy;
begin
  FreeAndNil(FExportColumns);
  inherited Destroy;
end;

procedure TDataGridStringExportOptionsEh.Assign(Source: TPersistent);
var
  SrcOp: TDataGridStringExportOptionsEh;
begin
  if not (Source is TDataGridStringExportOptionsEh) then Exit;

  SrcOp := TDataGridStringExportOptionsEh(Source);

  UseFormatSettings := SrcOp.UseFormatSettings;
  LineDelimiter := SrcOp.LineDelimiter;
  CellDelimiter := SrcOp.CellDelimiter;
  UseEditFormat := SrcOp.UseEditFormat;
  QuoteChar := SrcOp.QuoteChar;
  IsExportTitle := SrcOp.IsExportTitle;
  TrailingLineDelimiter := SrcOp.TrailingLineDelimiter;
  FormatSettings := SrcOp.FormatSettings;
  IsExportFooter := SrcOp.IsExportFooter;
  IsExportSelecting := SrcOp.IsExportSelecting;
  ExportColumns := SrcOp.ExportColumns;
end;

procedure TDataGridStringExportOptionsEh.SetExportColumns(const Value: TColumnsListEh);
begin
  FExportColumns.Assign(Value);
end;

{ TDataGridEhToTextExporter }

constructor TDataGridToStringExporterEh.Create;
begin
  FStringBuilder := TStringBuilder.Create;
  FExpCols := TColumnsListEh.Create;
  FExportOptions := CreateExportOptions;
end;

destructor TDataGridToStringExporterEh.Destroy;
begin
  FreeAndNil(FExportOptions);
  FreeAndNil(FStringBuilder);
  FreeAndNil(FExpCols);
  inherited Destroy;
end;

function TDataGridToStringExporterEh.CreateExportOptions: TDataGridStringExportOptionsEh;
begin
  Result := TDataGridStringExportOptionsEh.Create;
end;

function TDataGridToStringExporterEh.GetResultString: String;
begin
  Result := FStringBuilder.ToString;
end;

procedure TDataGridToStringExporterEh.ExportGrid;
var
  i: Integer;
  ASelectionType: TDataGridSelectionTypeEh;
  ASelectedRows: TList<TDataGridRowEh>;
  ASelectedRect: TRect;
  ACurrentRow: TDataGridRowEh;
  RI: Integer;
begin
  FStringBuilder.Clear;

  if (ExportOptions.ExportColumns.Count > 0)
    then FExpCols.Assign(ExportOptions.ExportColumns)
    else FExpCols.Clear;

  if ExportOptions.IsExportSelecting
    then ASelectionType := Grid.Selection.SelectionType
    else ASelectionType := TDataGridSelectionTypeEh.All;

  try
    case ASelectionType of

      TDataGridSelectionTypeEh.Non:
        begin
          if (Grid.TableView = nil) or
             (Grid.TableView.FilteredRowList.Count = 0 )
          then
            Exit;
          if FExpCols.Count = 0 then
            FExpCols.Add(Grid.CurrentColumn);
          WritePrefix;
          WriteRecord(Grid.CurrentRow);
        end;

      TDataGridSelectionTypeEh.RecordBookmarks:
        begin
          if FExpCols.Count = 0 then
            FExpCols.Assign(Grid.VisibleColumns);
          WritePrefix;
          if (Grid.Title.Visible) and ExportOptions.IsExportTitle then
            WriteTitle;

          ASelectedRows := TList<TDataGridRowEh>.Create;
          Grid.Selection.GetSelectedRows(ASelectedRows);
          CalcFooterValues;

          for i := 0 to ASelectedRows.Count - 1 do
          begin
            WriteRecord(ASelectedRows[I]);
          end;
          ASelectedRows.Free;

          WriteFooter;
        end;

      TDataGridSelectionTypeEh.Rectangle:
        begin
          if FExpCols.Count = 0 then
          begin
            ASelectedRect := Grid.Selection.GetSelectedRect;
            for i := ASelectedRect.Left to ASelectedRect.Right do
            begin
              if Grid.Columns[i].Visible then
                FExpCols.Add(Grid.Columns[i]);
            end;
          end;
          WritePrefix;
          if (Grid.Title.Visible) and ExportOptions.IsExportTitle then
            WriteTitle;

          for RI := ASelectedRect.Top to ASelectedRect.Bottom do
          begin
            ACurrentRow := Grid.VisibleRows[RI];
            WriteRecord(ACurrentRow);
          end;

          WriteFooter;
        end;

      TDataGridSelectionTypeEh.Columns:
        begin
          if FExpCols.Count = 0 then
            FExpCols.Assign(Grid.Selection.Columns);
          SetLength(FooterValues, FExpCols.Count * Grid.FooterRowCount);
          WritePrefix;
          if (Grid.Title.Visible) and ExportOptions.IsExportTitle then
            WriteTitle;

          for RI := 0 to Grid.VisibleRows.Count - 1 do
          begin
            ACurrentRow := Grid.VisibleRows[RI];
            WriteRecord(ACurrentRow);
          end;

          CalcFooterValues;
          WriteFooter;
        end;

      TDataGridSelectionTypeEh.All:
        begin
          if FExpCols.Count = 0 then
            FExpCols.Assign(Grid.VisibleColumns);
          SetLength(FooterValues, FExpCols.Count * Grid.FooterRowCount);
          WritePrefix;
          if (Grid.Title.Visible) and ExportOptions.IsExportTitle then
            WriteTitle;

          for RI := 0 to Grid.VisibleRows.Count - 1 do
          begin
            ACurrentRow := Grid.VisibleRows[RI];
            WriteRecord(ACurrentRow);
          end;

          CalcFooterValues;
          WriteFooter;
        end;
    end;

  finally
  end;

  if ExportOptions.TrailingLineDelimiter then
    PushLastLineBuffer;
  WriteSuffix;
end;

procedure TDataGridToStringExporterEh.SetExportOptions(const Value: TDataGridStringExportOptionsEh);
begin
  FExportOptions.Assign(Value);
end;

procedure TDataGridToStringExporterEh.WriteValue(s: String);
begin
  s := CheckQuoteString(s);
  WriteString(s);
end;

procedure TDataGridToStringExporterEh.WriteString(s: String);
begin
  FStringBuilder.Append(s);
end;

procedure TDataGridToStringExporterEh.PushLastLineBuffer;
begin
  if (FLastLineBuffer <> '') then
  begin
    WriteString(FLastLineBuffer);
    FLastLineBuffer := '';
  end;
end;

function TDataGridToStringExporterEh.CheckQuoteString(s: String): String;
var
  NeedQuotation: Boolean;
begin
  if ExportOptions.QuoteChar = #0 then
  begin
    Result := s;
  end else
  begin
    NeedQuotation := False;
    if AnsiContainsText(s, ExportOptions.QuoteChar) then
      NeedQuotation := True
    else if AnsiContainsText(s, ExportOptions.CellDelimiter) then
      NeedQuotation := True;

    if (NeedQuotation)
      then Result := AnsiQuotedStr(s, ExportOptions.QuoteChar)
      else Result := s;
  end;
end;

procedure TDataGridToStringExporterEh.WritePrefix;
begin

end;

procedure TDataGridToStringExporterEh.WriteTitle;
var
  i: Integer;
  s: String;
begin
  PushLastLineBuffer;
  for i := 0 to FExpCols.Count - 1 do
  begin
    s := FExpCols[i].Title.Text;
    WriteValue(s);
    if i <> FExpCols.Count - 1 then
      WriteEndOfCell;
  end;
  WriteEndOfLine;
end;

procedure TDataGridToStringExporterEh.WriteRecord(Row: TDataGridRowEh);
var
  i: Integer;
  Column: TDataGridBaseColumnEh;
begin
  PushLastLineBuffer;

  for i := 0 to FExpCols.Count - 1 do
  begin
    Column := FExpCols[i];
    WriteDataCell(Column, Row);
    if i <> FExpCols.Count - 1 then
      WriteEndOfCell;
  end;
  WriteEndOfLine;

end;

procedure TDataGridToStringExporterEh.WriteDataCell(Column: TDataGridBaseColumnEh; Row: TDataGridRowEh);
var
  s: String;
begin
  if ExportOptions.UseEditFormat
    then s := Column.GetRowEditText(Row)
    else s := Column.GetRowDisplayText(Row);
  WriteValue(s);
end;

procedure TDataGridToStringExporterEh.WriteEndOfCell;
begin
  if (ExportOptions.CellDelimiter <> '') then
    WriteString(ExportOptions.CellDelimiter);
end;

procedure TDataGridToStringExporterEh.WriteEndOfLine;
begin
  if (ExportOptions.LineDelimiter <> '') then
  begin
    if (ExportOptions.TrailingLineDelimiter)
      then WriteString(ExportOptions.LineDelimiter)
      else FLastLineBuffer := ExportOptions.LineDelimiter;
  end;
end;

function TDataGridToStringExporterEh.GetFooterValue(ARowIndex, AColIndex: Integer): String;
begin
  Result := '';
end;

procedure TDataGridToStringExporterEh.CalcFooterValues;
begin
end;

procedure TDataGridToStringExporterEh.WriteFooter;
var
  i: Integer;
begin
  if not ExportOptions.IsExportFooter then Exit;
  for i := 0 to Grid.FooterRowCount - 1 do
    WriteFooterRow(i);
end;

procedure TDataGridToStringExporterEh.WriteFooterRow(FooterNo: Integer);
begin
end;

procedure TDataGridToStringExporterEh.WriteFooterCell(Column: TDataGridBaseColumnEh; const Text: String);
begin
  WriteValue(Text);
end;

procedure TDataGridToStringExporterEh.WriteSuffix;
begin

end;

end.
