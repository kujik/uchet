{*******************************************************}
{                                                       }
{                        EhLib 12.1                     }
{                      SpreadGridsEh                    }
{                                                       }
{   Copyright (c) 2015-2025 by Dmitry V. Bolshakov      }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}

unit SpreadGridsEh;

interface

uses
{$IFDEF EH_LIB_17} System.Generics.Collections, {$ENDIF}
{$IFDEF EH_LIB_17} System.UITypes, {$ENDIF}
{$IFDEF CIL}
  EhLibVCLNET,
  WinUtils,
{$ELSE}
  {$IFDEF FPC}
  {$ELSE}
  Windows, Messages, UxTheme,
  {$ENDIF}
{$ENDIF}
  SysUtils, Classes, Forms, Controls, StdCtrls, TypInfo,
  Contnrs, Variants, Types, Themes,
  GridsEh, ToolCtrlsEh, Graphics;

type

{ TDrawSpreadCellArgsEh }

  TDrawSpreadCellArgsEh = class(TPersistent)
  private
    FColIndex: Integer;
    FRowIndex: Integer;
    FState: TGridDrawState;
    FCellRect: TRect;
    FCellVisibleRect: TRect;
  public
    property ColIndex: Integer read FColIndex;
    property RowIndex: Integer read FRowIndex;
    property CellRect: TRect read FCellRect;
    property CellVisibleRect: TRect read FCellVisibleRect;
    property State: TGridDrawState read FState write FState;
  end;

  TSpreadCellShowHintParamsEh = class(TPersistent)
  private
    FBaseHintInfo: PHintInfo;
    FCellRect: TRect;
    FCellVisibleRect: TRect;
    FColIndex: Integer;
    FRowIndex: Integer;
    function GetHintStr: string;
    procedure SetHintStr(const Value: string);
    function GetHintPos: TPoint;
    procedure SetHintPos(const Value: TPoint);
    function GetCursorRect: TRect;
    procedure SetCursorRect(const Value: TRect);

  public
    property BaseHintInfo: PHintInfo read FBaseHintInfo;
    property CellRect: TRect read FCellRect;
    property CellVisibleRect: TRect read FCellVisibleRect;
    property ColIndex: Integer read FColIndex;
    property RowIndex: Integer read FRowIndex;

    property HintStr: string read GetHintStr write SetHintStr;
    property HintPos: TPoint read GetHintPos write SetHintPos;
    property CursorRect: TRect read GetCursorRect write SetCursorRect;
  end;

{ TSpreadGridCellMergingEh }

  TSpreadGridCellMergingEh = class(TPersistent)
  private
    FMasterMergeColOffset: Integer;
    FMasterMergeRowOffset: Integer;
    FMergeColCount: Integer;
    FMergeRowCount: Integer;
  public
    constructor Create;
    procedure Clear; virtual;
    property MasterMergeColOffset: Integer read FMasterMergeColOffset;
    property MasterMergeRowOffset: Integer read FMasterMergeRowOffset;
    property MergeColCount: Integer read FMergeColCount;
    property MergeRowCount: Integer read FMergeRowCount;
  end;

  TSpreadGridCellMergingArrayEh = array of array of TSpreadGridCellMergingEh;

{ TSpreadGridCellEh }

  TSpreadGridCellEh = class(TPersistent)
  private
    FValue: Variant;
  public
    constructor Create;
    property Value: Variant read FValue;
  end;

  TSpreadGridCellsArray = array of array of TSpreadGridCellEh;

{ TCustomSpreadGridEh }

  TCustomSpreadGridEh = class(TCustomGridEh)
  private
    FSpreadCellsArray: TSpreadGridCellsArray;
    FSpreadMergingArray: TSpreadGridCellMergingArrayEh;
    FEmptyCellMerging: TSpreadGridCellMergingEh;
    FDrawnCellArr: array of TGridCoord;
    FEmptyCell: TSpreadGridCellEh;
    FArrColCount: Integer;
    FArrRowCount: Integer;
    function GetVisibleColCount: Integer;
    function GetVisibleRowCount: Integer;
    function GetCell(ACol, ARow: Integer): TSpreadGridCellEh;

  private
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    procedure CMHintsShowPause(var Message: TCMHintShowPause); message CM_HINTSHOWPAUSE;
    function GetCellMerges(ACol, ARow: Integer): TSpreadGridCellMergingEh;
    function GetCellValues(ACol, ARow: Integer): Variant;
    procedure SetCellValues(ACol, ARow: Integer; const Value: Variant);
  protected

    function NeedBufferedPaint: Boolean; override;
    function GetCellDisplayText(ACol, ARow: Integer): String; virtual;
    function CheckCellAreaDrawn(ACol, ARow: Integer): Boolean; virtual;
    function CreateSpreadGridCell(ACol, ARow: Integer): TSpreadGridCellEh; virtual;
    function CreateSpreadGridMergingCell(ACol, ARow: Integer): TSpreadGridCellMergingEh; virtual;
    function SpreadCellRect(ACol, ARow: Integer): TRect;
    function GetOrCreateCellMerging(ACol, ARow: Integer): TSpreadGridCellMergingEh;

    procedure GetSpreadCellHintShowParams(AParams: TSpreadCellShowHintParamsEh); virtual;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;

    procedure RecreateSpreadCellsArray;
    procedure RecreateSpreadMergingArray;
    procedure SetCellDrawn(ACol, ARow: Integer);
    procedure SetSpreadArraySize(AColCount, ARowCount: Integer);
    procedure SetCellCanvasParams(ACol, ARow: Integer; ARect: TRect; State: TGridDrawState); virtual;
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect; State: TGridDrawState); override;
    procedure DrawCellArea(ACol, ARow: Integer; ARect: TRect; State: TGridDrawState); override;
    procedure DrawMasterCell(ACol, ARow: Integer; ARect: TRect; State: TGridDrawState; CellMerging: TSpreadGridCellMergingEh); virtual;
    procedure DrawMasterForMergedCell(ACol, ARow: Integer; ARect: TRect; State: TGridDrawState); virtual;
    procedure DoDrawSpreadCell(ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
    procedure DrawSpreadCell(EvtArg: TDrawSpreadCellArgsEh); virtual;
    procedure DrawBaseCell(ACol, ARow: Integer; ARect: TRect; State: TGridDrawState); virtual;

    procedure SpreadCellMouseDown(const Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect; const GridMousePos, CellMousePos: TPoint); virtual;

    property VisibleColCount: Integer read GetVisibleColCount;
    property VisibleRowCount: Integer read GetVisibleRowCount;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CellRectToVisibleRect(ACol, ARow: Integer; ARect: TRect): TRect;
    function GetOrCreateCell(ACol, ARow: Integer): TSpreadGridCellEh;

    procedure SetGridSize(ANewColCount, ANewContraColCount, ANewRowCount, ANewContraRowCount: Integer); virtual;
    procedure MergeCells(BaseCellCol, BaseCellRow, MergeColCount, MergeRowCount: Integer);
    procedure GetMasterCellByBaseCellCoord(BaseCellCol, BaseCellRow: Integer; out SpreadCellCol, SpreadCellRow: Integer);
    procedure ClearAllMerges;
    procedure ClearCellMerging(BaseCellCol, BaseCellRow: Integer);

    property Cell[ACol, ARow: Integer]: TSpreadGridCellEh read GetCell;
    property CellMerges[ACol, ARow: Integer]: TSpreadGridCellMergingEh read GetCellMerges;
    property CellValues[ACol, ARow: Integer]: Variant read GetCellValues write SetCellValues;
  end;

{ TSpreadGridEh }
  TSpreadGridEh = class(TCustomSpreadGridEh)
  public
    property Col;
    property ColCount;
    property ColWidths;
    property ContraColCount;
    property ContraRowCount;
    property DefaultColWidth;
    property DefaultRowHeight;
    property FixedColCount;
    property FixedRowCount;
    property FrozenColCount;
    property FrozenRowCount;
    property FullColCount;
    property FullRowCount;
    property Row;
    property RowCount;
    property RowHeights;
  end;

implementation

{ TSpreadGridCellEh }

constructor TSpreadGridCellEh.Create;
begin
  FValue := Unassigned;
end;

{ TCustomSpreadGridEh }

constructor TCustomSpreadGridEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FEmptyCellMerging := TSpreadGridCellMergingEh.Create;
  FEmptyCell := CreateSpreadGridCell(-1, -1);

  FArrColCount  := 0;
  FArrRowCount := 0;

  SetGridSize(ColCount, ContraColCount, RowCount, ContraRowCount);

  VertScrollBar.SmoothStep := True;
end;

destructor TCustomSpreadGridEh.Destroy;
begin
  SetSpreadArraySize(0, 0);
  FreeAndNil(FEmptyCellMerging);
  FreeAndNil(FEmptyCell);
  inherited Destroy;
end;

procedure TCustomSpreadGridEh.SetGridSize(ANewColCount, ANewContraColCount, ANewRowCount, ANewContraRowCount: Integer);
begin
  ColCount := ANewColCount;
  ContraColCount := ANewContraColCount;
  RowCount := ANewRowCount;
  ContraRowCount := ANewContraRowCount;

  SetSpreadArraySize(FullColCount, FullRowCount);
end;

procedure TCustomSpreadGridEh.SetSpreadArraySize(AColCount, ARowCount: Integer);
begin
  if (FArrColCount <> AColCount) or (FArrRowCount <> ARowCount) then
  begin
    ClearAllMerges;

    FArrColCount := AColCount;
    FArrRowCount := ARowCount;

    if (FSpreadMergingArray <> nil) then
      RecreateSpreadMergingArray;

    if (FSpreadCellsArray <> nil) then
      RecreateSpreadCellsArray;
  end;
end;

procedure TCustomSpreadGridEh.RecreateSpreadMergingArray;
var
  c,r: Integer;
  OldCC, OldRC: Integer;
  AColCount, ARowCount: Integer;
begin
  AColCount := FArrColCount;
  ARowCount := FArrRowCount;
  if (Length(FSpreadMergingArray) > 0) then
  begin
    OldRC := Length(FSpreadMergingArray[0]);
    OldCC  := Length(FSpreadMergingArray);
    if ARowCount > OldRC then
    begin
      for c := 0 to OldCC-1 do
      begin
        SetLength(FSpreadMergingArray[c], ARowCount);
        for r := OldRC to ARowCount-1 do
          FSpreadMergingArray[c, r] := nil;
      end;
    end else if ARowCount < OldRC then
    begin
      for c := 0 to OldCC-1 do
      begin
        for r := ARowCount to OldRC-1 do
        begin
          FSpreadMergingArray[c, r].Free;
          FSpreadMergingArray[c, r] := nil;
        end;
        SetLength(FSpreadMergingArray[c], ARowCount);
      end;
    end;
  end;

  if AColCount > Length(FSpreadMergingArray) then
  begin
    OldCC  := Length(FSpreadMergingArray);
    SetLength(FSpreadMergingArray, AColCount);
    for c := OldCC to AColCount-1 do
    begin
      SetLength(FSpreadMergingArray[c], ARowCount);
      for r := 0 to ARowCount-1 do
        FSpreadMergingArray[c, r] := nil;
    end;
  end else if AColCount < Length(FSpreadMergingArray) then
  begin
    OldCC  := Length(FSpreadMergingArray);
    for c := AColCount to OldCC-1 do
    begin
      for r := 0 to ARowCount-1 do
      begin
        FSpreadMergingArray[c, r].Free;
        FSpreadMergingArray[c, r] := nil;
      end;
    end;
    SetLength(FSpreadMergingArray, AColCount);
  end;
end;


procedure TCustomSpreadGridEh.RecreateSpreadCellsArray;
var
  c,r: Integer;
  OldCC, OldRC: Integer;
  ARowCount, AColCount: Integer;
begin
  AColCount := FArrColCount;
  ARowCount := FArrRowCount;
  if (Length(FSpreadCellsArray) > 0) then
  begin
    OldRC := Length(FSpreadCellsArray[0]);
    OldCC  := Length(FSpreadCellsArray);
    if ARowCount > OldRC then
    begin
      for c := 0 to OldCC-1 do
      begin
        SetLength(FSpreadCellsArray[c], ARowCount);
        for r := OldRC to ARowCount-1 do
          FSpreadCellsArray[c, r] := nil;
      end;
    end else if ARowCount < OldRC then
    begin
      for c := 0 to OldCC-1 do
      begin
        for r := ARowCount to OldRC-1 do
        begin
          FSpreadCellsArray[c, r].Free;
          FSpreadCellsArray[c, r] := nil;
        end;
        SetLength(FSpreadCellsArray[c], ARowCount);
      end;
    end;
  end;

  if AColCount > Length(FSpreadCellsArray) then
  begin
    OldCC  := Length(FSpreadCellsArray);
    SetLength(FSpreadCellsArray, AColCount);
    for c := OldCC to AColCount-1 do
    begin
      SetLength(FSpreadCellsArray[c], ARowCount);
      for r := 0 to ARowCount-1 do
        FSpreadCellsArray[c, r] := nil;
    end;
  end else if AColCount < Length(FSpreadCellsArray) then
  begin
    OldCC  := Length(FSpreadCellsArray);
    for c := AColCount to OldCC-1 do
    begin
      for r := 0 to ARowCount-1 do
      begin
        FSpreadCellsArray[c, r].Free;
        FSpreadCellsArray[c, r] := nil;
      end;
    end;
    SetLength(FSpreadCellsArray, AColCount);
  end;
end;

function TCustomSpreadGridEh.CreateSpreadGridCell(ACol, ARow: Integer): TSpreadGridCellEh;
begin
  Result := TSpreadGridCellEh.Create;
end;

function TCustomSpreadGridEh.CreateSpreadGridMergingCell(ACol, ARow: Integer): TSpreadGridCellMergingEh;
begin
  Result := TSpreadGridCellMergingEh.Create;
end;

function TCustomSpreadGridEh.GetCell(ACol, ARow: Integer): TSpreadGridCellEh;
begin
  if FSpreadCellsArray = nil then
    Result := FEmptyCell
  else
  begin
    Result := FSpreadCellsArray[ACol, ARow];
    if Result = nil then
      Result := FEmptyCell;
  end;
end;

function TCustomSpreadGridEh.GetOrCreateCell(ACol, ARow: Integer): TSpreadGridCellEh;
begin
  if FSpreadCellsArray = nil then
    RecreateSpreadCellsArray;

  Result := FSpreadCellsArray[ACol, ARow];

  if Result = nil then
  begin
    Result := CreateSpreadGridCell(ACol, ARow);
    FSpreadCellsArray[ACol, ARow] := Result;
  end;

end;

function TCustomSpreadGridEh.GetCellMerges(ACol, ARow: Integer): TSpreadGridCellMergingEh;
begin
  if FSpreadMergingArray = nil then
    Result := FEmptyCellMerging
  else
    Result := FSpreadMergingArray[ACol, ARow];

  if Result = nil then
    Result := FEmptyCellMerging;
end;

function TCustomSpreadGridEh.GetOrCreateCellMerging(ACol, ARow: Integer): TSpreadGridCellMergingEh;
begin
  Result := FSpreadMergingArray[ACol, ARow];
  if Result = nil then
  begin
    Result := CreateSpreadGridMergingCell(ACol, ARow);
    FSpreadMergingArray[ACol, ARow] := Result;
  end;
end;

function TCustomSpreadGridEh.GetCellValues(ACol, ARow: Integer): Variant;
begin
  Result := Cell[ACol, ARow].Value;
end;

procedure TCustomSpreadGridEh.SetCellValues(ACol, ARow: Integer; const Value: Variant);
var
  ACell: TSpreadGridCellEh;
begin
  ACell := GetOrCreateCell(ACol, ARow);
  ACell.FValue := Value;
end;

procedure TCustomSpreadGridEh.MergeCells(BaseCellCol, BaseCellRow,
  MergeColCount, MergeRowCount: Integer);
var
  MastCMerging, SlaveCMerging: TSpreadGridCellMergingEh;
  i, j: Integer;
begin
  if (FSpreadMergingArray = nil) and
     ((MergeColCount > 1) or (MergeRowCount > 1))
  then
    RecreateSpreadMergingArray;

  MastCMerging := CellMerges[BaseCellCol, BaseCellRow];
  if (MastCMerging.MergeColCount = MergeColCount) and
     (MastCMerging.MergeRowCount = MergeRowCount)
  then
    Exit;

  ClearCellMerging(BaseCellCol, BaseCellRow);

  if (MergeColCount = 1) and (MergeRowCount = 1) then
    Exit;

  MastCMerging := GetOrCreateCellMerging(BaseCellCol, BaseCellRow);
  MastCMerging.FMergeColCount := MergeColCount;
  MastCMerging.FMergeRowCount := MergeRowCount;
  MastCMerging.FMasterMergeColOffset := 0;
  MastCMerging.FMasterMergeRowOffset := 0;

  for i := 0 to MergeColCount - 1 do
  begin
    for j := 0 to MergeRowCount - 1 do
    begin
      if (i > 0) or (j > 0) then
      begin
        SlaveCMerging := GetOrCreateCellMerging(BaseCellCol+i, BaseCellRow+j);

        if (SlaveCMerging.FMasterMergeColOffset <> 0) or
           (SlaveCMerging.FMasterMergeColOffset <> 0)
        then
          raise Exception.Create('Merging intersection in position ' +
            IntToStr(BaseCellCol+i) + ':' + IntToStr(BaseCellRow+j));

        SlaveCMerging.FMasterMergeColOffset := i;
        SlaveCMerging.FMasterMergeRowOffset := j;
      end;
    end;
  end;
end;

procedure TCustomSpreadGridEh.ClearCellMerging(BaseCellCol, BaseCellRow: Integer);
var
  BaseCMerging, SlaveCMerging: TSpreadGridCellMergingEh;
  ci, ri: Integer;
begin
  BaseCMerging := FSpreadMergingArray[BaseCellCol, BaseCellRow];
  if (BaseCMerging = nil) then
    Exit;

  if (BaseCMerging.MasterMergeColOffset > 0) or
     (BaseCMerging.MasterMergeRowOffset > 0)
  then
    Exit;

  if (BaseCMerging.MergeColCount > 1) or (BaseCMerging.MergeRowCount > 1) then
  begin
    for ci := 0 to BaseCMerging.MergeColCount - 1 do
    begin
      for ri := 0 to BaseCMerging.MergeRowCount - 1 do
      begin
        if (ci > 0) or (ri > 0) then
        begin
          SlaveCMerging := FSpreadMergingArray[BaseCellCol + ci, BaseCellRow + ri];
          if SlaveCMerging = nil then
            raise Exception.Create('TCustomSpreadGridEh.ClearCellMerging: InMergeCellMrg = nil in the Merged Area');
          SlaveCMerging.FMasterMergeColOffset := 0;
          SlaveCMerging.FMasterMergeRowOffset := 0;
        end;
      end;
    end;
  end;

  BaseCMerging.FMergeColCount := 1;
  BaseCMerging.FMergeRowCount := 1;

end;

procedure TCustomSpreadGridEh.ClearAllMerges;
var
  CI, RI: Integer;
begin
  for CI := 0 to FArrColCount - 1 do
  begin
    for RI:= 0 to FArrRowCount - 1 do
    begin
      MergeCells(CI, RI, 1, 1);
    end;
  end;
end;

function TCustomSpreadGridEh.GetCellDisplayText(ACol, ARow: Integer): String;
begin
  Result := VarToStr(CellValues[ACol, ARow]);
end;

function TCustomSpreadGridEh.GetVisibleColCount: Integer;
begin
  Result := HorzAxis.RolLastVisCel - HorzAxis.RolStartVisCel + 1;
end;

function TCustomSpreadGridEh.GetVisibleRowCount: Integer;
begin
  Result := VertAxis.RolLastVisCel - VertAxis.RolStartVisCel + 1;
end;

procedure TCustomSpreadGridEh.SetCellCanvasParams(ACol, ARow: Integer;
  ARect: TRect; State: TGridDrawState);
begin
  Canvas.Font.Color := StyleServices.GetSystemColor(clWindowText);
  Canvas.Brush.Color := StyleServices.GetSystemColor(clMoneyGreen);
  if (ACol >= FixedColCount-FrozenColCount) and (ARow >= FixedRowCount-FrozenRowCount) then
    Canvas.Brush.Color := StyleServices.GetSystemColor(clWindow);

  if gdCurrent in State then
  begin
    Canvas.Font.Color := StyleServices.GetSystemColor(clHighlightText);
    if gdFocused in State then
      Canvas.Brush.Color := StyleServices.GetSystemColor(clHighlight)
    else
      Canvas.Brush.Color := StyleServices.GetSystemColor(clBtnShadow);
  end;
end;

procedure TCustomSpreadGridEh.DrawCell(ACol, ARow: Integer; ARect: TRect;
  State: TGridDrawState);
begin
  DoDrawSpreadCell(ACol, ARow, ARect, State);
end;

function TCustomSpreadGridEh.CheckCellAreaDrawn(ACol, ARow: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Length(FDrawnCellArr)-1 do
  begin
    if (FDrawnCellArr[i].X = ACol) and (FDrawnCellArr[i].Y = ARow) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TCustomSpreadGridEh.SetCellDrawn(ACol, ARow: Integer);
var
  NewPos: Integer;
begin
  NewPos := Length(FDrawnCellArr);
  SetLength(FDrawnCellArr, NewPos+1);
  FDrawnCellArr[NewPos].X := ACol;
  FDrawnCellArr[NewPos].Y := ARow;
end;

procedure TCustomSpreadGridEh.DrawCellArea(ACol, ARow: Integer; ARect: TRect;
  State: TGridDrawState);
var
  CMerging: TSpreadGridCellMergingEh;
begin
  if CheckCellAreaDrawn(ACol, ARow) then Exit;

  CMerging := CellMerges[ACol, ARow];

  if ((CMerging.MergeColCount > 1) or (CMerging.MergeRowCount > 1)) then
  begin
    DrawMasterCell(ACol, ARow, ARect, State, CMerging);
  end else if ((CMerging.MasterMergeColOffset > 0) or (CMerging.MasterMergeRowOffset > 0)) then
  begin
    DrawMasterForMergedCell(ACol, ARow, ARect, State);
  end else
  begin
    DrawBaseCell(ACol, ARow, ARect, State);
    inherited DrawCellArea(ACol, ARow, ARect, State);
  end;
end;

procedure TCustomSpreadGridEh.DrawMasterCell(ACol, ARow: Integer;
  ARect: TRect; State: TGridDrawState; CellMerging: TSpreadGridCellMergingEh);
var
  i, j: Integer;
  MasterRect: TRect;
  BorderRect: TRect;
  CellBorderTypes: TGridCellBorderTypesEh;
  RIsDraw, BIsDraw: Boolean;
  BaseCellRect: TRect;
begin
  MasterRect := ARect;
  for i := ACol+1 to ACol + CellMerging.MergeColCount - 1 do
    MasterRect.Right := MasterRect.Right + ColWidths[i];
  for j := ARow+1 to ARow + CellMerging.MergeRowCount - 1 do
    MasterRect.Bottom := MasterRect.Bottom + RowHeights[j];

  BorderRect := ARect;
  RIsDraw := False;
  BIsDraw := False;
  for i := ACol to ACol + CellMerging.MergeColCount - 1 do
  begin
    BorderRect.Right := BorderRect.Left + ColWidths[i];
    BorderRect.Top := ARect.Top;
    for j := ARow to ARow + CellMerging.MergeRowCount - 1 do
    begin
      BorderRect.Bottom := BorderRect.Top + RowHeights[j];
      CellBorderTypes := [];
      if i = ACol + CellMerging.MergeColCount - 1 then
        CellBorderTypes := CellBorderTypes + [cbtRightEh];
      if j = ARow + CellMerging.MergeRowCount - 1 then
        CellBorderTypes := CellBorderTypes + [cbtBottomEh];
      BaseCellRect := BorderRect;
      DrawBordersForCellArea(i, j, BaseCellRect, State, CellBorderTypes);
      if BaseCellRect.Right < BorderRect.Right then
        RIsDraw := True;
      if BaseCellRect.Bottom < BorderRect.Bottom then
        BIsDraw := True;

      DrawBaseCell(i, j, BaseCellRect, State);
      SetCellDrawn(i, j);
      BorderRect.Top := BorderRect.Bottom;
    end;
    BorderRect.Left := BorderRect.Right;
  end;
  if RIsDraw then
    Dec(MasterRect.Right);
  if BIsDraw then
    Dec(MasterRect.Bottom);
  DrawCell(ACol, ARow, MasterRect, State);
end;

procedure TCustomSpreadGridEh.DrawMasterForMergedCell(ACol, ARow: Integer;
  ARect: TRect; State: TGridDrawState);
var
  CMerging, MastCMerging: TSpreadGridCellMergingEh;
  i: Integer;
  MasterCellPos: TGridCoord;
begin
  CMerging := CellMerges[ACol, ARow];
  MasterCellPos := GridCoord(ACol - CMerging.MasterMergeColOffset, ARow - CMerging.MasterMergeRowOffset);
  MastCMerging := CellMerges[MasterCellPos.X, MasterCellPos.Y];
  for i := ACol - 1 downto MasterCellPos.X do
    ARect.Left := ARect.Left - ColWidths[i];
  for i := ARow - 1 downto MasterCellPos.Y do
    ARect.Top := ARect.Top - RowHeights[i];
  ARect.Right := ARect.Left + ColWidths[MasterCellPos.X];
  ARect.Bottom := ARect.Top + RowHeights[MasterCellPos.Y];
  DrawMasterCell(MasterCellPos.X, MasterCellPos.Y, ARect, State, MastCMerging);
end;

function TCustomSpreadGridEh.CellRectToVisibleRect(ACol, ARow: Integer;
  ARect: TRect): TRect;
begin
  Result := ARect;
  if (ACol >= FixedColCount) and (ARect.Left < HorzAxis.FixedBoundary) then
    Result.Left := HorzAxis.FixedBoundary;
  if (ARow >= FixedRowCount) and (ARect.Top < VertAxis.FixedBoundary) then
    Result.Top := VertAxis.FixedBoundary;
  if (ACol < ColCount) and (ARect.Right > HorzAxis.ContraStart) then
    Result.Right := HorzAxis.ContraStart;
  if (ARow < RowCount) and (ARect.Bottom > VertAxis.ContraStart) then
    Result.Bottom := VertAxis.ContraStart;
end;

procedure TCustomSpreadGridEh.DoDrawSpreadCell(ACol, ARow: Integer;
  ARect: TRect; State: TGridDrawState);
var
  EvtArg: TDrawSpreadCellArgsEh;
begin
  EvtArg := TDrawSpreadCellArgsEh.Create;
  EvtArg.FColIndex := ACol;
  EvtArg.FRowIndex := ARow;
  EvtArg.FCellRect := ARect;
  EvtArg.FState := State;
  EvtArg.FCellVisibleRect := ARect;
  if (ACol >= FixedColCount) and (ARect.Left < HorzAxis.FixedBoundary) then
    EvtArg.FCellVisibleRect.Left := HorzAxis.FixedBoundary;
  if (ARow >= FixedRowCount) and (ARect.Top < VertAxis.FixedBoundary) then
    EvtArg.FCellVisibleRect.Top := VertAxis.FixedBoundary;
  if (ACol < ColCount) and (ARect.Right > HorzAxis.ContraStart) then
    EvtArg.FCellVisibleRect.Right := HorzAxis.ContraStart;
  if (ARow < RowCount) and (ARect.Bottom > VertAxis.ContraStart) then
    EvtArg.FCellVisibleRect.Bottom := VertAxis.ContraStart;

  DrawSpreadCell(EvtArg);
  EvtArg.Free;
end;

procedure TCustomSpreadGridEh.DrawBaseCell(ACol, ARow: Integer;
  ARect: TRect; State: TGridDrawState);
begin

end;

procedure TCustomSpreadGridEh.DrawSpreadCell(EvtArg: TDrawSpreadCellArgsEh);
var
  AFillRect: TRect;
  Text: String;
begin
  SetCellCanvasParams(EvtArg.ColIndex, EvtArg.RowIndex, EvtArg.CellRect, EvtArg.State);

  AFillRect := EvtArg.CellRect;
  Canvas.FillRect(AFillRect);

  Text := GetCellDisplayText(EvtArg.ColIndex, EvtArg.RowIndex);
  Canvas.TextRect(AFillRect, AFillRect.Left+2, AFillRect.Top+2, Text);
end;

function TCustomSpreadGridEh.NeedBufferedPaint: Boolean;
begin
  Result := True;
end;

procedure TCustomSpreadGridEh.Paint;
begin
  SetLength(FDrawnCellArr, 0);

  inherited Paint;
end;

procedure TCustomSpreadGridEh.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  CellHit: TGridCoord;
  MasterCellHit: TGridCoord;
  MasterCellRect: TRect;
  CellMousePos: TPoint;
begin
  inherited MouseDown(Button, Shift, X, Y);
  CellHit := MouseCoord(X, Y);
  if (CellHit.X < 0) or (CellHit.Y < 0) then Exit;

  GetMasterCellByBaseCellCoord(CellHit.X, CellHit.Y, MasterCellHit.X, MasterCellHit.Y);
  MasterCellRect := SpreadCellRect(MasterCellHit.X, MasterCellHit.Y);
  CellMousePos.X := X - MasterCellRect.Left;
  CellMousePos.Y := Y - MasterCellRect.Top;
  SpreadCellMouseDown(MasterCellHit, Button, Shift, MasterCellRect, Point(X, Y), CellMousePos);
end;

procedure TCustomSpreadGridEh.SpreadCellMouseDown(const Cell: TGridCoord;
  Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect;
  const GridMousePos, CellMousePos: TPoint);
begin

end;

function TCustomSpreadGridEh.SpreadCellRect(ACol, ARow: Integer): TRect;
var
  CMerging: TSpreadGridCellMergingEh;
  CI, RI: Integer;
begin
  CMerging := CellMerges[ACol, ARow];
  if (CMerging.MasterMergeColOffset > 0) or (CMerging.MasterMergeRowOffset > 0) then
    raise Exception.Create('Can''t get Rect for merged slave cell');
  Result := CellRectAbs(ACol, ARow, True);

  for CI := ACol + 1 to ACol + CMerging.MergeColCount - 1 do
    Result.Right := Result.Right + ColWidths[CI];
  for RI := ARow + 1 to ARow + CMerging.MergeRowCount - 1 do
    Result.Bottom := Result.Bottom + RowHeights[RI];
end;

procedure TCustomSpreadGridEh.GetMasterCellByBaseCellCoord(BaseCellCol, BaseCellRow: Integer;
  out SpreadCellCol, SpreadCellRow: Integer);
var
  MastCMerging: TSpreadGridCellMergingEh;
begin
  MastCMerging := CellMerges[BaseCellCol, BaseCellRow];
  if (MastCMerging.MasterMergeColOffset > 0) or (MastCMerging.MasterMergeRowOffset > 0) then
  begin
    SpreadCellCol := BaseCellCol - MastCMerging.MasterMergeColOffset;
    SpreadCellRow := BaseCellRow - MastCMerging.MasterMergeRowOffset;
  end else
  begin
    SpreadCellCol := BaseCellCol;
    SpreadCellRow := BaseCellRow;
  end;
end;

procedure TCustomSpreadGridEh.GetSpreadCellHintShowParams(
  AParams: TSpreadCellShowHintParamsEh);
begin
  AParams.HintStr := VarToStr(CellValues[AParams.ColIndex, AParams.RowIndex]);
end;

procedure TCustomSpreadGridEh.CMHintShow(var Message: TCMHintShow);

  procedure GetMasterCellRectPos(ACol, ARow: Integer;
    out MasterRect: TRect; out MasterVisibleRect: TRect; out MasterCellPos: TGridCoord);
  var
    CMerging, MasterCMerging: TSpreadGridCellMergingEh;
    i, j: Integer;
    ColIdx, RowIdx: Integer;
  begin
    CMerging := CellMerges[ACol, ARow];
    MasterCellPos := GridCoord(ACol - CMerging.FMasterMergeColOffset, ARow - CMerging.FMasterMergeRowOffset);
    MasterCMerging := CellMerges[MasterCellPos.X, MasterCellPos.Y];
    MasterRect := CellRect(MasterCellPos.X, MasterCellPos.Y);

    for i := 1 to MasterCMerging.FMergeColCount - 1 do
    begin
      ColIdx := i + MasterCellPos.X;
      MasterRect.Right := MasterRect.Right + ColWidths[ColIdx];
    end;
    for j := 1 to MasterCMerging.FMergeRowCount - 1 do
    begin
      RowIdx := MasterCellPos.Y + j;
      MasterRect.Bottom := MasterRect.Bottom + RowHeights[RowIdx];
    end;

    MasterVisibleRect := CellRectToVisibleRect(MasterCellPos.X, MasterCellPos.Y, MasterRect);
  end;

var
  HintInfo: PHintInfo;
  CellPos: TGridCoord;
  MasterRect: TRect;
  MasterVisibleRect: TRect;
  MasterCellPos: TGridCoord;
  VHintParams: TSpreadCellShowHintParamsEh;
begin
  HintInfo := Message.HintInfo;
  CellPos := MouseCoord(HitTest.X, HitTest.Y);

  if (CellPos.X >= 0) and (CellPos.Y >= 0) then
  begin
    GetMasterCellRectPos(CellPos.X, CellPos.Y, MasterRect, MasterVisibleRect, MasterCellPos);

    VHintParams := TSpreadCellShowHintParamsEh.Create;
    VHintParams.FBaseHintInfo := HintInfo;
    VHintParams.FColIndex := MasterCellPos.X;
    VHintParams.FRowIndex := MasterCellPos.Y;
    VHintParams.FCellRect := MasterRect;
    VHintParams.FCellVisibleRect := MasterVisibleRect;
    VHintParams.CursorRect := MasterRect;
    GetSpreadCellHintShowParams(VHintParams);
    VHintParams.Free;
  end;
end;

procedure TCustomSpreadGridEh.CMHintsShowPause(var Message: TCMHintShowPause);
begin
  inherited;
end;

{ TSpreadCellShowHintParamsEh }

function TSpreadCellShowHintParamsEh.GetCursorRect: TRect;
begin
  Result := FBaseHintInfo.CursorRect;
end;

procedure TSpreadCellShowHintParamsEh.SetCursorRect(const Value: TRect);
begin
  FBaseHintInfo.CursorRect := Value;
end;

function TSpreadCellShowHintParamsEh.GetHintPos: TPoint;
begin
  Result := FBaseHintInfo.HintPos;
end;

procedure TSpreadCellShowHintParamsEh.SetHintPos(const Value: TPoint);
begin
  FBaseHintInfo.HintPos := Value;
end;

function TSpreadCellShowHintParamsEh.GetHintStr: string;
begin
  Result := FBaseHintInfo.HintStr;
end;

procedure TSpreadCellShowHintParamsEh.SetHintStr(const Value: string);
begin
  FBaseHintInfo.HintStr := Value;
end;

{ TSpreadGridCellMergingEh }

procedure TSpreadGridCellMergingEh.Clear;
begin
  FMasterMergeColOffset := 0;
  FMasterMergeRowOffset := 0;
  FMergeColCount := 1;
  FMergeRowCount := 1;
end;

constructor TSpreadGridCellMergingEh.Create;
begin
  inherited Create;
  Clear;
end;

end.
