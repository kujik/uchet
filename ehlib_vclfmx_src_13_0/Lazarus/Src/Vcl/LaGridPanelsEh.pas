{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{                     LaGridPanelsEh                    }
{                                                       }
{    Copyright (c) 2022-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}

unit LaGridPanelsEh;

interface

{$SCOPEDENUMS ON}

uses
  Types, Classes, Math, Messages, SysUtils, Variants,
  {$IFDEF FPC}
    EhLibLclUtils,
  {$ELSE}
    EhLibVclUtils,
  {$ENDIF}
  Generics.Collections, DB,
  LaObjectsEh, LaControlsEh, PrntsEh,
  ImgList, Graphics, Controls, Forms, Dialogs;

type
  TLaSizeStyleEh = (Pixel, Weight, Auto);

  TLaGridPanelEh = class;

  EGridPanelException = class(Exception);

  TCellItem = class(TCollectionItem)
  private
    FSizeStyle: TLaSizeStyleEh;
    FValue: Double;
    FSize: Integer;
    FNeededSize: Integer;
    FAutoAdded: Boolean;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure SetSizeStyle(Value: TLaSizeStyleEh);
    procedure SetValue(Value: Double);

    property Size: Integer read FSize write FSize;
    property AutoAdded: Boolean read FAutoAdded write FAutoAdded;
  public
    constructor Create(Collection: TCollection); override;
  published
    property SizeStyle: TLaSizeStyleEh read FSizeStyle write SetSizeStyle default TLaSizeStyleEh.Weight;
    property Value: Double read FValue write SetValue;
  end;

  TRowItem = class(TCellItem);

  TColumnItem = class(TCellItem);

  TCellCollection = class(TOwnedCollection)
  protected
    function GetAttrCount: Integer; override;
    function GetAttr(Index: Integer): string; override;
    function GetItemAttr(Index, ItemIndex: Integer): string; override;
    function GetItem(Index: Integer): TCellItem;
    procedure SetItem(Index: Integer; Value: TCellItem);
    procedure Update(Item: TCollectionItem); override;
  public
    function Owner: TLaGridPanelEh;
    procedure EquallySplitPercentages;
    property Items[Index: Integer]: TCellItem read GetItem write SetItem; default;
  end;

  TCellSpan = 1..MaxInt;

  TRowCollection = class(TCellCollection)
  protected
    function GetItem(Index: Integer): TRowItem;
    procedure SetItem(Index: Integer; Value: TRowItem);

    function GetItemAttr(Index, ItemIndex: Integer): string; override;
    procedure Notify(Item: TCollectionItem; Action: Classes.TCollectionNotification); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TRowItem;
    property Items[Index: Integer]: TRowItem read GetItem write SetItem; default;
  end;

  TColumnCollection = class(TCellCollection)
  protected
    function GetItem(Index: Integer): TColumnItem;
    procedure SetItem(Index: Integer; Value: TColumnItem);

    function GetItemAttr(Index, ItemIndex: Integer): string; override;
    procedure Notify(Item: TCollectionItem; Action: Classes.TCollectionNotification); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TColumnItem;
    property Items[Index: Integer]: TColumnItem read GetItem write SetItem; default;
  end;

  TControlItem = class(TCollectionItem)
  private
    FControl: TLaObjectEh;
    FColumn: Integer;
    FRow: Integer;
    FColumnSpan: TCellSpan;
    FRowSpan: TCellSpan;
    FPushed: Integer;
    function GetGridPanel: TLaGridPanelEh;
    function GetPushed: Boolean;
    procedure SetColumn(Value: Integer);
    procedure SetColumnSpan(Value: TCellSpan);
    procedure SetControl(Value: TLaObjectEh);
    procedure SetRow(Value: Integer);
    procedure SetRowSpan(Value: TCellSpan);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure InternalSetLocation(AColumn, ARow: Integer; APushed: Boolean; MoveExisting: Boolean);
    property GridPanel: TLaGridPanelEh read GetGridPanel;
    property Pushed: Boolean read GetPushed;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure SetLocation(AColumn, ARow: Integer; APushed: Boolean = False);
  published
    property Control: TLaObjectEh read FControl write SetControl;

    property Column: Integer read FColumn write SetColumn;
    property ColumnSpan: TCellSpan read FColumnSpan write SetColumnSpan default 1;

    property Row: Integer read FRow write SetRow;
    property RowSpan: TCellSpan read FRowSpan write SetRowSpan default 1;
  end;

  TControlCollection = class(TOwnedCollection)
  protected
    function GetControl(AColumn, ARow: Integer): TLaObjectEh;
    function GetControlItem(AColumn, ARow: Integer): TControlItem;
    function GetItem(Index: Integer): TControlItem;
    procedure SetControl(AColumn, ARow: Integer; Value: TLaObjectEh);
    procedure SetItem(Index: Integer; Value: TControlItem);
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TControlItem;

    procedure AddControl(AControl: TLaObjectEh; AColumn: Integer = -1; ARow: Integer = -1);
    procedure RemoveControl(AControl: TLaObjectEh);

    function IndexOf(AControl: TLaObjectEh): Integer;
    function Owner: TLaGridPanelEh;

    property Controls[AColumn, ARow: Integer]: TLaObjectEh read GetControl write SetControl;
    property ControlItems[AColumn, ARow: Integer] : TControlItem read GetControlItem;
    property Items[Index: Integer]: TControlItem read GetItem write SetItem; default;
  end;

  TLaGridPanelEh = class(TLaControlEh)
  private
    FRowCollection: TRowCollection;
    FColumnCollection: TColumnCollection;
    FControlCollection: TControlCollection;
    FRecalcCellSizes: Boolean;
    FRecalcCellSizesDisabled: Integer;
    FRecalcCellPercentsDisabled: Boolean;
    FClientSize: TSize;
    FGridQuerySize: TSize;
    FGridQrCalcSize: TSize;

    FDummyColumnWidth: Integer;
    FDummyRowHeight: Integer;
    FDummyNeededColumnWidth: Integer;
    FDummyNeededRowHeight: Integer;

    function GetCellCount: Integer;
    function GetCellSizes(AColumn, ARow: Integer): TSize;
    function GetCellRect(AColumn, ARow: Integer): TRect;
    function GetColumnSpanIndex(AColumn, ARow: Integer): Integer;
    function GetRowSpanIndex(AColumn, ARow: Integer): Integer;
    function GetRecalcCellSizesEnabled: Boolean;
    function GetRecalcCellPercentsEnabled: Boolean;

    procedure SetColumnCollection(const Value: TColumnCollection);
    procedure SetControlCollection(const Value: TControlCollection);
    procedure SetRowCollection(const Value: TRowCollection);
    procedure RecalcCellDimensions(const APanelSize: TSize; ACanvas: TCanvas); overload;
    procedure RecalcCellDimensions(const APanelSize: TSize; ACanvas: TBasePrinterCanvas); overload;
    procedure CMControlChange(var Message: TCMControlChange); message CM_CONTROLCHANGE;
    function GetColLayoutCount: Integer;
    function GetRowLayoutCount: Integer;
    procedure InitNeededSize(AInitSize: TSize);
    procedure PrepareForRecalcCellDimensions;
  protected
    function AutoAddColumn: TColumnItem;
    function AutoAddRow: TRowItem;
    function CellToCellIndex(AColumn, ARow: Integer): Integer;

    procedure CellIndexToCell(AIndex: Integer; var AColumn, ARow: Integer);
    procedure RemoveEmptyAutoAddColumns;
    procedure RemoveEmptyAutoAddRows;
  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function DoQueryLayoutClientArea(QuerySize: TSize; ACanvas: TCanvas): TSize; overload; override;
    function DoPerformLayoutClientArea(ClientRect: TRect; ACanvas: TCanvas): TSize; overload; override;

    function DoQueryLayoutClientArea(QuerySize: TSize; ACanvas: TBasePrinterCanvas): TSize; overload; override;
    function DoPerformLayoutClientArea(ClientRect: TRect; ACanvas: TBasePrinterCanvas): TSize; overload; override;

    procedure BeginUpdate;
    procedure EndUpdate;
    function IsColumnEmpty(AColumn: Integer): Boolean;
    function IsRowEmpty(ARow: Integer): Boolean;

    procedure UpdateControlsColumn(AColumn: Integer);
    procedure UpdateControlsRow(ARow: Integer);

    property ColumnSpanIndex[AColumn, ARow: Integer]: Integer read GetColumnSpanIndex;
    property CellCount: Integer read GetCellCount;
    property CellSize[AColumn, ARow: Integer]: TSize read GetCellSizes;
    property CellRect[AColumn, ARow: Integer]: TRect read GetCellRect;
    property ColLayoutCount: Integer read GetColLayoutCount;
    property RowLayoutCount: Integer read GetRowLayoutCount;
    property RecalcCellSizesEnabled: Boolean read GetRecalcCellSizesEnabled;
    property RecalcCellPercentsEnabled: Boolean read GetRecalcCellPercentsEnabled;
    property ControlCollection: TControlCollection read FControlCollection write SetControlCollection;
    property ColumnCollection: TColumnCollection read FColumnCollection write SetColumnCollection;
    property RowCollection: TRowCollection read FRowCollection write SetRowCollection;
    property RowSpanIndex[AColumn, ARow: Integer]: Integer read GetRowSpanIndex;
    property ClientSize: TSize read FClientSize;
  end;

implementation

const
  sCannotAddFixedSize = 'Cannot add columns or rows while expand style is fixed size';
  sInvalidSpan = '''%d'' is not a valid span';
  sInvalidRowIndex = 'Row index, %d, out of bounds';
  sInvalidColumnIndex = 'Column index, %d, out of bounds';
  sInvalidControlItem = 'ControlItem.Control cannot be set to owning GridPanel';
  sCellMember = 'Member';
  sCellSizeType = 'Size Type';
  sCellValue = 'Value';
  sCellAutoSize = 'Auto';
  sCellPercentSize = 'Percent';
  sCellAbsoluteSize = 'Absolute';
  sCellColumn = 'Column%d';
  sCellRow = 'Row%d';

{ TLaGridPanelEh }

function TLaGridPanelEh.AutoAddColumn: TColumnItem;
begin
  Result := FColumnCollection.Add;
  Result.SizeStyle := TLaSizeStyleEh.Weight;
  Result.Value := 1;
  Result.AutoAdded := True;
end;

function TLaGridPanelEh.AutoAddRow: TRowItem;
begin
  Result := FRowCollection.Add;
  Result.SizeStyle := TLaSizeStyleEh.Weight;
  Result.Value := 1;
  Result.AutoAdded := True;
end;

procedure TLaGridPanelEh.CellIndexToCell(AIndex: Integer; var AColumn, ARow: Integer);
begin
  AColumn := AIndex div FRowCollection.Count;
  ARow := AIndex mod FRowCollection.Count;
end;

function TLaGridPanelEh.CellToCellIndex(AColumn, ARow: Integer): Integer;
begin
  Result := ColumnSpanIndex[AColumn, ARow];
end;

procedure TLaGridPanelEh.CMControlChange(var Message: TCMControlChange);
begin

end;

constructor TLaGridPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRowCollection := TRowCollection.Create(Self);
  FColumnCollection := TColumnCollection.Create(Self);
  FControlCollection := TControlCollection.Create(Self);
  FRecalcCellSizes := True;
end;

destructor TLaGridPanelEh.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FRowCollection);
  FreeAndNil(FColumnCollection);
  FreeAndNil(FControlCollection);
end;

function TLaGridPanelEh.DoQueryLayoutClientArea(QuerySize: TSize; ACanvas: TCanvas): TSize;
begin
  RecalcCellDimensions(QuerySize, ACanvas);
  InitNeededSize(QuerySize);
  Result := FGridQrCalcSize;
end;

function TLaGridPanelEh.DoQueryLayoutClientArea(QuerySize: TSize; ACanvas: TBasePrinterCanvas): TSize;
begin
  RecalcCellDimensions(QuerySize, ACanvas);
  InitNeededSize(QuerySize);
  Result := FGridQrCalcSize;
end;

function TLaGridPanelEh.DoPerformLayoutClientArea(ClientRect: TRect; ACanvas: TCanvas): TSize;
var
  I: Integer;
  VCellRect: TRect;
  CtlItem: TControlItem;
begin
  RecalcCellDimensions(RectSize(ClientRect), ACanvas);
  FClientSize.cx := RectWidth(ClientRect);
  FClientSize.cy := RectHeight(ClientRect);

  for I := 0 to ControlCollection.Count - 1 do
  begin
    CtlItem := ControlCollection[I];
    VCellRect := CellRect[CtlItem.Column, CtlItem.Row];
    CtlItem.Control.PerformLayout(VCellRect, ACanvas);
  end;

  Result.cx := RectWidth(ClientRect);
  Result.cy := RectHeight(ClientRect);
end;

function TLaGridPanelEh.DoPerformLayoutClientArea(ClientRect: TRect; ACanvas: TBasePrinterCanvas): TSize;
var
  I: Integer;
  VCellRect: TRect;
  CtlItem: TControlItem;
begin
  RecalcCellDimensions(RectSize(ClientRect), ACanvas);
  FClientSize.cx := RectWidth(ClientRect);
  FClientSize.cy := RectHeight(ClientRect);

  for I := 0 to ControlCollection.Count - 1 do
  begin
    CtlItem := ControlCollection[I];
    VCellRect := CellRect[CtlItem.Column, CtlItem.Row];
    CtlItem.Control.PerformLayout(VCellRect, ACanvas);
  end;

  Result.cx := RectWidth(ClientRect);
  Result.cy := RectHeight(ClientRect);
end;

function TLaGridPanelEh.GetCellCount: Integer;
begin
  Result := FRowCollection.Count * FColumnCollection.Count;
end;

procedure TLaGridPanelEh.InitNeededSize(AInitSize: TSize);
var
  I: Integer;
  Sz: Integer;
begin
  FGridQuerySize.cx := AInitSize.cx;
  FGridQuerySize.cy := AInitSize.cy;

  FDummyNeededColumnWidth := FDummyColumnWidth;
  if ColumnCollection.Count > 0 then
  begin
    FGridQrCalcSize.cx := 0;
    for I := 0 to ColumnCollection.Count - 1 do
    begin
      Sz := ColumnCollection[I].FSize;
      ColumnCollection[I].FNeededSize := Sz;
      FGridQrCalcSize.cx := FGridQrCalcSize.cx + Sz;
    end;
  end
  else
  begin
    FGridQrCalcSize.cx := FDummyNeededColumnWidth;
  end;

  FDummyNeededRowHeight := FDummyRowHeight;
  if RowCollection.Count > 0 then
  begin
    FGridQrCalcSize.cy := 0;
    for I := 0 to RowCollection.Count - 1 do
    begin
      Sz := RowCollection[I].FSize;
      RowCollection[I].FNeededSize := Sz;
      FGridQrCalcSize.cy := FGridQrCalcSize.cy + Sz;
    end;
  end
  else
  begin
    FGridQrCalcSize.cy := FDummyNeededRowHeight;
  end;
end;

function TLaGridPanelEh.GetCellRect(AColumn, ARow: Integer): TRect;
var
  I: Integer;
  ACellSize: TSize;
begin
  Result.Left := 0;
  Result.Top := 0;
  for I := 0 to AColumn - 1 do
    Inc(Result.Left, FColumnCollection[I].Size);
  for I := 0 to ARow - 1 do
    Inc(Result.Top, FRowCollection[I].Size);
  ACellSize := CellSize[AColumn, ARow];
  Result.BottomRight := Point(ACellSize.cx, ACellSize.cy);
  Inc(Result.Bottom, Result.Top);
  Inc(Result.Right, Result.Left);
end;

function TLaGridPanelEh.GetCellSizes(AColumn, ARow: Integer): TSize;
begin
  if (AColumn = -1) then
  begin
    if (IsInQueryLayout)
      then Result.cx := FGridQuerySize.cx
      else Result.cx := FClientSize.cx;
  end else
  begin
    Result.cx := FColumnCollection[AColumn].Size;
  end;

  if (ARow = -1) then
  begin
    if (IsInQueryLayout)
      then Result.cy := FGridQuerySize.cy
      else Result.cy := FClientSize.cy;
  end else
  begin
    Result.cy := FRowCollection[ARow].Size;
  end;
end;

function TLaGridPanelEh.GetColumnSpanIndex(AColumn, ARow: Integer): Integer;
begin
  Result := AColumn + (ARow * FColumnCollection.Count);
end;

function TLaGridPanelEh.GetRowSpanIndex(AColumn, ARow: Integer): Integer;
begin
  Result := ARow + (AColumn * FRowCollection.Count);
end;

function TLaGridPanelEh.IsColumnEmpty(AColumn: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (AColumn > -1) and (AColumn < FColumnCollection.Count) then
  begin
    for I := 0 to FRowCollection.Count -1 do
      if ControlCollection.Controls[AColumn, I] <> nil then
        Exit;
    Result := True;
  end else
    raise EGridPanelException.CreateFmt(sInvalidColumnIndex, [AColumn]);
end;

function TLaGridPanelEh.IsRowEmpty(ARow: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (ARow > -1) and (ARow < FRowCollection.Count) then
  begin
    for I := 0 to FColumnCollection.Count -1 do
      if ControlCollection.Controls[I, ARow] <> nil then
        Exit;
    Result := True;
  end else
    raise EGridPanelException.CreateFmt(sInvalidRowIndex, [ARow]);
end;

procedure TLaGridPanelEh.RecalcCellDimensions(const APanelSize: TSize; ACanvas: TCanvas);
var
  I: Integer;
  XSize, YSize: Integer;
  ColItem: TCellItem;
  RowItem: TCellItem;
  SumXWeight, SumYWeight: Double;
  WeightXSize, WeightYSize: Integer;
  ACellAutoSize: TSize;

  function CalcCellAutoSize(Col, Row: Integer): TSize;
  var
    I: Integer;
    CtlItem: TControlItem;
    ACellSize: TSize;
    ControlNeededSize: TSize;
  begin
    Result.cx := 0;
    Result.cy := 0;
    for I := 0 to ControlCollection.Count - 1 do
    begin
      CtlItem := ControlCollection[I];
      if (Col = CtlItem.Column) and (Row = CtlItem.Row) then
      begin
        ACellSize := CellSize[CtlItem.Column, CtlItem.Row];
        ControlNeededSize := CtlItem.Control.QueryLayout(ACellSize, ACanvas);
        if ControlNeededSize.cx > Result.cx then
          Result.cx := ControlNeededSize.cx;
        if ControlNeededSize.cy > Result.cy then
          Result.cy := ControlNeededSize.cy;
      end;
    end;
  end;

  function CalcAutoSizedColWidth(Col: Integer): Integer;
  var
    R: Integer;
  begin
    Result := 0;
    for R := 0 to FRowCollection.Count - 1 do
    begin
      ACellAutoSize := CalcCellAutoSize(Col, R);

      if (ACellAutoSize.cx > Result) then
        Result := ACellAutoSize.cx;
    end;
  end;

  function CalcAutoSizedRowHeight(Row: Integer): Integer;
  var
    C: Integer;
  begin
    Result := 0;
    for C := 0 to FColumnCollection.Count - 1 do
    begin
      ACellAutoSize := CalcCellAutoSize(C, Row);

      if (ACellAutoSize.cy > Result) then
        Result := ACellAutoSize.cy;
    end;
  end;

begin
  if not RecalcCellSizesEnabled then
    Exit;

  PrepareForRecalcCellDimensions();

  XSize := APanelSize.cx;
  YSize := APanelSize.cy;

  WeightXSize := 0;
  WeightYSize := 0;
  SumXWeight := 0;
  SumYWeight := 0;

  if FColumnCollection.UpdateCount = 0 then
  begin
    if FColumnCollection.Count > 0 then
    begin
      for I := 0 to FColumnCollection.Count - 1 do
      begin
        ColItem := FColumnCollection[I];
        if ColItem.SizeStyle = TLaSizeStyleEh.Pixel then
        begin
          ColItem.FSize := Trunc(ColItem.Value);
          Dec(XSize, ColItem.FSize);
        end
        else if ColItem.SizeStyle = TLaSizeStyleEh.Auto then
        begin
          ColItem.FSize := CalcAutoSizedColWidth(I);
          Dec(XSize, ColItem.FSize);
        end
        else if (ColItem.SizeStyle = TLaSizeStyleEh.Weight) then
        begin
          SumXWeight := SumXWeight + ColItem.Value;
        end;
      end;
    end else
    begin
      FDummyColumnWidth := CalcAutoSizedColWidth(-1);
      Dec(XSize, FDummyColumnWidth);
    end;

    WeightXSize := XSize;
    if WeightXSize < 0 then
      WeightXSize := 0;
  end;

  
  if FColumnCollection.UpdateCount = 0 then
  begin
    for I := 0 to FColumnCollection.Count - 1 do
    begin
      ColItem := FColumnCollection[I];
      if ColItem.SizeStyle = TLaSizeStyleEh.Weight then
      begin
        ColItem.Size := Round(ColItem.Value * WeightXSize / SumXWeight);
      end;
    end;
  end;

  
  
  if FRowCollection.UpdateCount = 0 then
  begin
    if FRowCollection.Count > 0 then
    begin
      for I := 0 to FRowCollection.Count - 1 do
      begin
        RowItem := FRowCollection[I];
        if RowItem.SizeStyle = TLaSizeStyleEh.Pixel then
        begin
          RowItem.FSize := Trunc(RowItem.Value);
          Dec(YSize, RowItem.FSize)
        end
        else if RowItem.SizeStyle = TLaSizeStyleEh.Auto then
        begin
          RowItem.FSize := CalcAutoSizedRowHeight(I);
          Dec(YSize, RowItem.FSize);
        end
        else if (RowItem.SizeStyle = TLaSizeStyleEh.Weight) then
        begin
          SumYWeight := SumYWeight + RowItem.Value;
        end;
      end;
    end else
    begin
      FDummyRowHeight := CalcAutoSizedRowHeight(-1);
      Dec(YSize, FDummyRowHeight);
    end;

    WeightYSize := YSize;
    if WeightYSize < 0 then
      WeightYSize := 0;
  end;

  
  if FRowCollection.UpdateCount = 0 then
  begin
    for I := 0 to FRowCollection.Count - 1 do
    begin
      RowItem := FRowCollection[I];
      if RowItem.SizeStyle = TLaSizeStyleEh.Weight then
      begin
        RowItem.Size := Round(RowItem.Value * WeightYSize / SumYWeight);
      end;
    end;
  end;

  FRecalcCellSizes := False;
  FRecalcCellPercentsDisabled := False;
end;

procedure TLaGridPanelEh.RecalcCellDimensions(const APanelSize: TSize; ACanvas: TBasePrinterCanvas);
var
  I: Integer;
  XSize, YSize: Integer;
  ColItem: TCellItem;
  RowItem: TCellItem;
  SumXWeight, SumYWeight: Double;
  WeightXSize, WeightYSize: Integer;
  ACellAutoSize: TSize;

  function CalcCellAutoSize(Col, Row: Integer): TSize;
  var
    I: Integer;
    CtlItem: TControlItem;
    ACellSize: TSize;
    ControlNeededSize: TSize;
  begin
    Result.cx := 0;
    Result.cy := 0;
    for I := 0 to ControlCollection.Count - 1 do
    begin
      CtlItem := ControlCollection[I];
      if (Col = CtlItem.Column) and (Row = CtlItem.Row) then
      begin
        ACellSize := CellSize[CtlItem.Column, CtlItem.Row];
        ControlNeededSize := CtlItem.Control.QueryLayout(ACellSize, ACanvas);
        if ControlNeededSize.cx > Result.cx then
          Result.cx := ControlNeededSize.cx;
        if ControlNeededSize.cy > Result.cy then
          Result.cy := ControlNeededSize.cy;
      end;
    end;
  end;

  function CalcAutoSizedColWidth(Col: Integer): Integer;
  var
    R: Integer;
  begin
    Result := 0;
    for R := 0 to FRowCollection.Count - 1 do
    begin
      ACellAutoSize := CalcCellAutoSize(Col, R);

      if (ACellAutoSize.cx > Result) then
        Result := ACellAutoSize.cx;
    end;
  end;

  function CalcAutoSizedRowHeight(Row: Integer): Integer;
  var
    C: Integer;
  begin
    Result := 0;
    for C := 0 to FColumnCollection.Count - 1 do
    begin
      ACellAutoSize := CalcCellAutoSize(C, Row);

      if (ACellAutoSize.cy > Result) then
        Result := ACellAutoSize.cy;
    end;
  end;

begin
  if not RecalcCellSizesEnabled then
    Exit;

  PrepareForRecalcCellDimensions();

  XSize := APanelSize.cx;
  YSize := APanelSize.cy;

  WeightXSize := 0;
  WeightYSize := 0;
  SumXWeight := 0;
  SumYWeight := 0;

  
  
  if FColumnCollection.UpdateCount = 0 then
  begin
    if FColumnCollection.Count > 0 then
    begin
      for I := 0 to FColumnCollection.Count - 1 do
      begin
        ColItem := FColumnCollection[I];
        if ColItem.SizeStyle = TLaSizeStyleEh.Pixel then
        begin
          ColItem.FSize := Trunc(ColItem.Value);
          
          ColItem.Size := Round(ColItem.Size * ACanvas.DisplayToDeviceScaleX);
          Dec(XSize, ColItem.FSize);
        end
        else if ColItem.SizeStyle = TLaSizeStyleEh.Auto then
        begin
          ColItem.FSize := CalcAutoSizedColWidth(I);
          Dec(XSize, ColItem.FSize);
        end
        else if (ColItem.SizeStyle = TLaSizeStyleEh.Weight) then
        begin
          SumXWeight := SumXWeight + ColItem.Value;
        end;
      end;
    end else
    begin
      FDummyColumnWidth := CalcAutoSizedColWidth(-1);
      Dec(XSize, FDummyColumnWidth);
    end;

    WeightXSize := XSize;
    if WeightXSize < 0 then
      WeightXSize := 0;
  end;

  
  if FColumnCollection.UpdateCount = 0 then
  begin
    for I := 0 to FColumnCollection.Count - 1 do
    begin
      ColItem := FColumnCollection[I];
      if ColItem.SizeStyle = TLaSizeStyleEh.Weight then
      begin
        ColItem.Size := Round(ColItem.Value * WeightXSize / SumXWeight);
      end;
    end;
  end;

  if FRowCollection.UpdateCount = 0 then
  begin
    if FRowCollection.Count > 0 then
    begin
      for I := 0 to FRowCollection.Count - 1 do
      begin
        RowItem := FRowCollection[I];
        if RowItem.SizeStyle = TLaSizeStyleEh.Pixel then
        begin
          RowItem.FSize := Trunc(RowItem.Value);
          
          RowItem.Size := Round(RowItem.Size * ACanvas.DisplayToDeviceScaleY);
          Dec(YSize, RowItem.FSize)
        end
        else if RowItem.SizeStyle = TLaSizeStyleEh.Auto then
        begin
          RowItem.FSize := CalcAutoSizedRowHeight(I);
          Dec(YSize, RowItem.FSize);
        end
        else if (RowItem.SizeStyle = TLaSizeStyleEh.Weight) then
        begin
          SumYWeight := SumYWeight + RowItem.Value;
        end;
      end;
    end else
    begin
      FDummyRowHeight := CalcAutoSizedRowHeight(-1);
      Dec(YSize, FDummyRowHeight);
    end;

    WeightYSize := YSize;
    if WeightYSize < 0 then
      WeightYSize := 0;
  end;

  if FRowCollection.UpdateCount = 0 then
  begin
    for I := 0 to FRowCollection.Count - 1 do
    begin
      RowItem := FRowCollection[I];
      if RowItem.SizeStyle = TLaSizeStyleEh.Weight then
      begin
        RowItem.Size := Round(RowItem.Value * WeightYSize / SumYWeight);
      end;
    end;
  end;

  FRecalcCellSizes := False;
  FRecalcCellPercentsDisabled := False;
end;

procedure TLaGridPanelEh.PrepareForRecalcCellDimensions;
var
  I: Integer;
  ColItem: TCellItem;
  RowItem: TCellItem;
begin

  for I := 0 to FColumnCollection.Count - 1 do
  begin
    ColItem := FColumnCollection[I];
    ColItem.FSize := 0;
  end;

  for I := 0 to FRowCollection.Count - 1 do
  begin
    RowItem := FRowCollection[I];
    RowItem.FSize := 0;
  end;
end;

procedure TLaGridPanelEh.RemoveEmptyAutoAddColumns;
var
  I: Integer;
begin
  for I := FColumnCollection.Count - 1 downto 0 do
  begin
    if FColumnCollection[I].AutoAdded and IsColumnEmpty(I)
      then FColumnCollection.Delete(I)
      else Exit;
  end;
end;

procedure TLaGridPanelEh.RemoveEmptyAutoAddRows;
var
  I: Integer;
begin
  for I := FRowCollection.Count - 1 downto 0 do
  begin
    if FRowCollection[I].AutoAdded and IsRowEmpty(I)
      then FRowCollection.Delete(I)
      else Exit;
  end;
end;

procedure TLaGridPanelEh.SetControlCollection(const Value: TControlCollection);
begin
  FControlCollection.Assign(Value);
end;

procedure TLaGridPanelEh.SetRowCollection(const Value: TRowCollection);
begin
  FRowCollection.Assign(Value);
end;

procedure TLaGridPanelEh.SetColumnCollection(const Value: TColumnCollection);
begin
  FColumnCollection.Assign(Value);
end;

procedure TLaGridPanelEh.UpdateControlsColumn(AColumn: Integer);
var
  I, J: Integer;
  AControlItem: TControlItem;
begin
  for I := AColumn + 1 to FColumnCollection.Count - 1 do
    for J := 0 to FRowCollection.Count - 1 do
    begin
      AControlItem := FControlCollection.ControlItems[I, J];
      if (AControlItem <> nil) and
         (AControlItem.Column = I) and
         (AControlItem.Row = J)
      then
        AControlItem.SetColumn(AControlItem.Column - 1);
    end;
end;

procedure TLaGridPanelEh.UpdateControlsRow(ARow: Integer);
var
  I, J: Integer;
  AControlItem: TControlItem;
begin
  for I := 0 to FColumnCollection.Count - 1 do
    for J := ARow + 1 to FRowCollection.Count - 1 do
    begin
      AControlItem := FControlCollection.ControlItems[I, J];
      if (AControlItem <> nil) and
         (AControlItem.Column = I) and
         (AControlItem.Row = J)
      then
        AControlItem.SetRow(AControlItem.Row - 1);
    end;
end;

function TLaGridPanelEh.GetRecalcCellSizesEnabled: Boolean;
begin
  Result := FRecalcCellSizesDisabled = 0;
end;

function TLaGridPanelEh.GetRecalcCellPercentsEnabled: Boolean;
begin
  Result := not FRecalcCellPercentsDisabled;
end;

procedure TLaGridPanelEh.BeginUpdate;
begin
  Inc(FRecalcCellSizesDisabled);
  FColumnCollection.BeginUpdate;
  FRowCollection.BeginUpdate;
end;

procedure TLaGridPanelEh.EndUpdate;
begin
  if FRecalcCellSizesDisabled > 0 then
  begin
    FColumnCollection.EndUpdate;
    FRowCollection.EndUpdate;
    Dec(FRecalcCellSizesDisabled);
    if FRecalcCellSizesDisabled = 0 then
    begin
      FRecalcCellSizes := True;
    end;
  end;
end;

function TLaGridPanelEh.GetColLayoutCount: Integer;
begin
  if (ColumnCollection.Count = 0)
    then Result := 1
    else Result := ColumnCollection.Count;
end;

function TLaGridPanelEh.GetRowLayoutCount: Integer;
begin
  if (RowCollection.Count = 0)
    then Result := 1
    else Result := RowCollection.Count;
end;

procedure TLaGridPanelEh.Assign(Source: TPersistent);
var
  i: Integer;
  SrcCtlItem: TControlItem;
  CtlItem: TControlItem;
  CtlIndex: Integer;
begin
  inherited Assign(Source);

  if (Source is TLaGridPanelEh) then
  begin
    ColumnCollection :=  TLaGridPanelEh(Source).ColumnCollection;
    RowCollection := TLaGridPanelEh(Source).RowCollection;

    ControlCollection.Clear;
    for i := 0 to TLaGridPanelEh(Source).ControlCollection.Count - 1 do
    begin
      SrcCtlItem := TLaGridPanelEh(Source).ControlCollection[i];
      CtlItem := ControlCollection.Add;
      CtlIndex := TLaGridPanelEh(Source).Children.IndexOf(SrcCtlItem.Control);
      ctlItem.Column := SrcCtlItem.Column;
      ctlItem.ColumnSpan := SrcCtlItem.ColumnSpan;
      ctlItem.Row := SrcCtlItem.Row;
      ctlItem.RowSpan := SrcCtlItem.RowSpan;
      ctlItem.Control := Children[CtlIndex];
    end;
  end;
end;

{ TCellItem }

constructor TCellItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FSizeStyle := TLaSizeStyleEh.Weight;
end;

procedure TCellItem.AssignTo(Dest: TPersistent);
var
  DestCellItem: TCellItem;
begin
  if Dest is TCellItem then
  begin
    DestCellItem := TCellItem(Dest);
    begin
      DestCellItem.FSizeStyle := Self.FSizeStyle;
      DestCellItem.FValue := Self.FValue;
      DestCellItem.FSize := Self.FSize;
    end;
  end;
end;

procedure TCellItem.SetSizeStyle(Value: TLaSizeStyleEh);
begin
  if Value <> FSizeStyle then
  begin
    FSizeStyle := Value;
    Changed(False);
  end;
end;

procedure TCellItem.SetValue(Value: Double);
begin
  if Value <> FValue then
  begin
    if FSizeStyle = TLaSizeStyleEh.Pixel then
    begin
      FSize := Trunc(Value);
      FValue := FSize;
    end else
      FValue := Value;
    Changed(False);
  end;
end;

{ TCellCollection }

function TCellCollection.GetAttr(Index: Integer): string;
begin
  case Index of
    0: Result := sCellMember;
    1: Result := sCellSizeType;
    2: Result := sCellValue;
  else
    Result := '';
  end;
end;

function TCellCollection.GetAttrCount: Integer;
begin
  Result := 3;
end;

function TCellCollection.GetItem(Index: Integer): TCellItem;
begin
  Result := TCellItem(inherited GetItem(Index));
end;

function TCellCollection.GetItemAttr(Index, ItemIndex: Integer): string;

  function GetSizeStyleString(Index: Integer): string;
  var
    CellItem: TCellItem;
  begin
    CellItem := Items[Index];
      case CellItem.SizeStyle of
        TLaSizeStyleEh.Pixel: Result := sCellAbsoluteSize;
        TLaSizeStyleEh.Weight: Result := sCellPercentSize;
      else
        Result := '';
      end;
  end;

  function GetValueString(Index: Integer): string;
  var
    CellItem: TCellItem;
  begin
    CellItem := Items[Index];
    if CellItem.SizeStyle = TLaSizeStyleEh.Pixel then
      Result := IntToStr(Trunc(CellItem.Value))
    else if CellItem.SizeStyle = TLaSizeStyleEh.Weight then
      Result := Format('%3.2f%%', [CellItem.Value]) 
    else Result := sCellAutoSize;
  end;

begin
  case Index of
    1: Result := GetSizeStyleString(ItemIndex);
    2: Result := GetValueString(ItemIndex);
  else
    Result := '';
  end;
end;

function TCellCollection.Owner: TLaGridPanelEh;
begin
  Result := GetOwner as TLaGridPanelEh;
end;

procedure TCellCollection.SetItem(Index: Integer; Value: TCellItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TCellCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if Owner <> nil then
  begin
    begin
      Owner.FRecalcCellSizes := True;
    end;
  end;
end;

procedure TCellCollection.EquallySplitPercentages;
var
  I: Integer;
  CellItem: TCellItem;
begin
  BeginUpdate;
  try
    for I := 0 to Count - 1 do
    begin
      CellItem := Items[I];
      if CellItem.SizeStyle = TLaSizeStyleEh.Weight then
      begin
        CellItem.Size := 0;
        CellItem.Value := 0;
      end;
    end;
  finally
    EndUpdate;
  end;
end;

{ TRowCollection }

constructor TRowCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TRowItem);
end;

function TRowCollection.Add: TRowItem;
begin
  Result := TRowItem(inherited Add);
end;

function TRowCollection.GetItemAttr(Index, ItemIndex: Integer): string;
begin
  if Index = 0 then
    Result := Format(sCellRow, [ItemIndex])
  else
    Result := inherited GetItemAttr(Index, ItemIndex);
end;

procedure TRowCollection.Notify(Item: TCollectionItem;
  Action: Classes.TCollectionNotification);
begin
  inherited Notify(Item, Action);
end;

function TRowCollection.GetItem(Index: Integer): TRowItem;
begin
  Result := TRowItem(inherited Items[Index]);
end;

procedure TRowCollection.SetItem(Index: Integer; Value: TRowItem);
begin
  inherited Items[Index] := Value;
end;

{ TColumnCollection }

constructor TColumnCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TColumnItem);
end;

function TColumnCollection.Add: TColumnItem;
begin
  Result := TColumnItem(inherited Add);
end;

function TColumnCollection.GetItemAttr(Index, ItemIndex: Integer): string;
begin
  if Index = 0 then
    Result := Format(sCellColumn, [ItemIndex])
  else
    Result := inherited GetItemAttr(Index, ItemIndex);
end;

procedure TColumnCollection.Notify(Item: TCollectionItem;
  Action: Classes.TCollectionNotification);
begin
  inherited Notify(Item, Action);
end;

function TColumnCollection.GetItem(Index: Integer): TColumnItem;
begin
  Result := TColumnItem(inherited Items[Index]);
end;

procedure TColumnCollection.SetItem(Index: Integer; Value: TColumnItem);
begin
  inherited Items[Index] := Value;
end;

{ TControlCollection }

function TControlCollection.Add: TControlItem;
begin
  Result := TControlItem(inherited Add);
end;

procedure TControlCollection.AddControl(AControl: TLaObjectEh; AColumn, ARow: Integer);

  procedure PlaceInCell(ControlItem: TControlItem);
  begin
    try
      ControlItem.Control := AControl;
      ControlItem.FRow := ARow;
      ControlItem.FColumn := AColumn;
    except
      ControlItem.Control := nil;
      Free;
      raise;
    end;
  end;

begin
  if IndexOf(AControl) < 0 then
    PlaceInCell(Add);
end;

constructor TControlCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TControlItem);
end;

function TControlCollection.GetControl(AColumn, ARow: Integer): TLaObjectEh;
var
  ControlItem: TControlItem;
begin
  ControlItem := GetControlItem(AColumn, ARow);
  if ControlItem <> nil then
    Result := ControlItem.Control
  else
    Result := nil;
end;

function TControlCollection.GetControlItem(AColumn, ARow: Integer): TControlItem;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := TControlItem(Items[I]);
    if (ARow >= Result.Row) and (ARow <= Result.Row + Result.RowSpan - 1) and
      (AColumn >= Result.Column) and (AColumn <= Result.Column + Result.ColumnSpan - 1) then
      Exit;
  end;
  Result := nil;
end;

function TControlCollection.GetItem(Index: Integer): TControlItem;
begin
  Result := TControlItem(inherited GetItem(Index));
end;

function TControlCollection.IndexOf(AControl: TLaObjectEh): Integer;
begin
  for Result := 0 to Count - 1 do
    if TControlItem(Items[Result]).Control = AControl then
      Exit;
  Result := -1;
end;

function TControlCollection.Owner: TLaGridPanelEh;
begin
  Result := TLaGridPanelEh(GetOwner);
end;

procedure TControlCollection.RemoveControl(AControl: TLaObjectEh);
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if Items[I].Control = AControl then
    begin
      Items[I].Control := nil;
      Delete(I);
      Exit;
    end;
end;

procedure TControlCollection.SetControl(AColumn, ARow: Integer; Value: TLaObjectEh);
var
  Index: Integer;
  ControlItem: TControlItem;
begin
  if Owner <> nil then
  begin
    if (AColumn < 0) or (AColumn >= Owner.ColumnCollection.Count) then
      raise EGridPanelException.CreateFmt(sInvalidColumnIndex, [AColumn]);
    if (ARow < 0) or (ARow >= Owner.RowCollection.Count) then
      raise EGridPanelException.CreateFmt(sInvalidRowIndex, [ARow]);
    Index := IndexOf(Value);
    if Index > -1 then
    begin
      ControlItem := Items[Index];
      ControlItem.FColumn := AColumn;
      ControlItem.FRow := ARow;
    end else
    begin
      AddControl(Value, AColumn, ARow);
    end;
  end;
end;

procedure TControlCollection.SetItem(Index: Integer; Value: TControlItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TControlCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if Owner <> nil then
  begin
    Owner.FRecalcCellSizes := True;
  end;
end;

{ TControlItem }

procedure TControlItem.AssignTo(Dest: TPersistent);
var
  DestItCtl: TControlItem;
begin
  if Dest is TControlItem then
  begin
    DestItCtl := TControlItem(Dest);
    begin
      DestItCtl.FControl := Self.Control;
      DestItCtl.FRow := Self.Row;
      DestItCtl.FColumn := Self.Column;
      DestItCtl.FRowSpan := Self.RowSpan;
      DestItCtl.FColumnSpan := Self.ColumnSpan;
      DestItCtl.Changed(False);
    end;
  end;
end;

constructor TControlItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FRowSpan := 1;
  FColumnSpan := 1;
  FColumn := -2;
  FRow := -2;
end;

destructor TControlItem.Destroy;
begin
  inherited Destroy;
end;

function TControlItem.GetGridPanel: TLaGridPanelEh;
var
  Owner: TControlCollection;
begin
  Owner := TControlCollection(GetOwner);
  if Owner <> nil
    then Result := Owner.Owner
    else Result := nil;
end;

procedure TControlItem.SetControl(Value: TLaObjectEh);
begin
  if FControl <> Value then
  begin
    if Value = GridPanel then
      raise EGridPanelException.Create(sInvalidControlItem);
    FControl := Value;
    Changed(False);
  end;
end;

procedure TControlItem.SetColumn(Value: Integer);
begin
  if FColumn <> Value then
  begin
    InternalSetLocation(Value, FRow, False, True);
  end;
end;

procedure TControlItem.SetRow(Value: Integer);
begin
  if FRow <> Value then
  begin
    InternalSetLocation(FColumn, Value, False, True);
  end;
end;

type
  TNewLocationRec = record
    ControlItem: TControlItem;
    NewColumn, NewRow: Integer;
    Pushed: Boolean;
  end;
  TNewLocationRecs = array of TNewLocationRec;

  TNewLocations = class
  private
    FNewLocations: TNewLocationRecs;
    FCount: Integer;
  public
    function AddNewLocation(AControlItem: TControlItem; ANewColumn, ANewRow: Integer; APushed: Boolean = False): Integer;
    procedure ApplyNewLocations;
    property Count: Integer read FCount;
    property NewLocations: TNewLocationRecs read FNewLocations;
  end;

function TNewLocations.AddNewLocation(AControlItem: TControlItem; ANewColumn, ANewRow: Integer; APushed: Boolean): Integer;
begin
  if FCount = Length(FNewLocations) then
    SetLength(FNewLocations, Length(FNewLocations) + 10);
  Result := FCount;
  Inc(FCount);
  begin
    FNewLocations[Result].ControlItem := AControlItem;
    FNewLocations[Result].NewColumn := ANewColumn;
    FNewLocations[Result].NewRow := ANewRow;
    FNewLocations[Result].Pushed := APushed;
  end;
end;

procedure TNewLocations.ApplyNewLocations;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    if FNewLocations[I].ControlItem <> nil then
      FNewLocations[I].ControlItem.InternalSetLocation(
        FNewLocations[I].NewColumn,
        FNewLocations[I].NewRow,
        FNewLocations[I].Pushed,
        False);
  end;
end;

procedure TControlItem.SetRowSpan(Value: TCellSpan);
var
  I, Delta: Integer;
  Collection: TControlCollection;
  ControlItem: TControlItem;
  NumToAdd, NumRows, MoveBy: Integer;
  NewLocations: TNewLocations;
begin
  if FRowSpan <> Value then
  begin
    if Value < 1 then
      raise EGridPanelException.CreateFmt(sInvalidSpan, [Value]);
    Collection := TControlCollection(GetOwner);
    if Collection = nil then Exit;
    try
      NewLocations := TNewLocations.Create;
      try
        if FRowSpan > Value then
        begin
          Delta := FRowSpan - Value;
          FRowSpan := Value;

          NumRows := GridPanel.RowCollection.Count;
          for I := FRow + FRowSpan + Delta to NumRows - 1 do
          begin
            ControlItem := Collection.ControlItems[FColumn, I];
            if ControlItem <> nil then
              if ControlItem.Pushed then
                NewLocations.AddNewLocation(ControlItem, FColumn, I - Delta, False)
              else
                Break;
          end;
          NewLocations.ApplyNewLocations;
          GridPanel.RemoveEmptyAutoAddRows;
        end else
        begin
          NumRows := GridPanel.RowCollection.Count;
          Delta := Value - FRowSpan;
          
          
          for I := Min(FRow + FRowSpan, NumRows) to Min(FRow + Value - 1, NumRows - 1) do
            if Collection.Controls[FColumn, I] = nil then
              Dec(Delta)
            else
              Break;
          MoveBy := Delta;
          
          for I := NumRows - 1 downto NumRows - MoveBy do
            if Collection.Controls[FColumn, I] = nil then
              Dec(Delta)
            else
              Break;
          NumToAdd := Delta;

          
          if {(GridPanel.ExpandStyle = emFixedSize) and} (NumToAdd > 0) then
            raise EGridPanelException.Create(sCannotAddFixedSize);
          while NumToAdd > 0 do
          begin
            GridPanel.AutoAddRow;
            Dec(NumToAdd);
          end;
          NumRows := GridPanel.RowCollection.Count;
          for I := NumRows - 1 downto NumRows - Delta do
          begin
            ControlItem := Collection.ControlItems[FColumn, I - MoveBy];
            if (ControlItem <> nil) and (ControlItem <> Self) then
              NewLocations.AddNewLocation(ControlItem, FColumn, I, True);
          end;
          NewLocations.ApplyNewLocations;

          FRowSpan := Value;
        end;
        Changed(False);
      finally
        NewLocations.Free;
      end;
    finally
    end;
  end;
end;

procedure TControlItem.SetColumnSpan(Value: TCellSpan);
var
  I, Delta: Integer;
  Collection: TControlCollection;
  ControlItem: TControlItem;
  NumToAdd, NumColumns, MoveBy: Integer;
  NewLocations: TNewLocations;
begin
  if FColumnSpan <> Value then
  begin
    if Value < 1 then
      raise EGridPanelException.CreateFmt(sInvalidSpan, [Value]);
    Collection := TControlCollection(GetOwner);
    if Collection = nil then Exit;
    try
      NewLocations := TNewLocations.Create;
      try
        if FColumnSpan > Value then
        begin
          Delta := FColumnSpan - Value;
          FColumnSpan := Value;

          NumColumns := GridPanel.ColumnCollection.Count;
          
          for I := FColumn + FColumnSpan + Delta to NumColumns - 1 do
          begin
            ControlItem := Collection.ControlItems[I, FRow];
            if ControlItem <> nil then
              if ControlItem.Pushed then
                NewLocations.AddNewLocation(ControlItem, I - Delta, FRow, False)
              else
                Break;
          end;
          NewLocations.ApplyNewLocations;
          GridPanel.RemoveEmptyAutoAddColumns;
        end else
        begin
          NumColumns := GridPanel.ColumnCollection.Count;
          Delta := Value - FColumnSpan;
          
          
          for I := Min(FColumn + FColumnSpan, NumColumns) to Min(FColumn + Value - 1, NumColumns - 1) do
            if Collection.Controls[I, FRow] = nil then
              Dec(Delta)
            else
              Break;
          MoveBy := Delta;
          
          for I := NumColumns - 1 downto NumColumns - MoveBy do
            if Collection.Controls[I, FRow] = nil then
              Dec(Delta)
            else
              Break;
          NumToAdd := Delta;

          
          if {(GridPanel.ExpandStyle = emFixedSize) and} (NumToAdd > 0) then
            raise EGridPanelException.Create(sCannotAddFixedSize);
          while NumToAdd > 0 do
          begin
            GridPanel.AutoAddColumn;
            Dec(NumToAdd);
          end;
          NumColumns := GridPanel.ColumnCollection.Count;
          for I := NumColumns - 1 downto NumColumns - Delta do
          begin
            ControlItem := Collection.ControlItems[I - MoveBy, FRow];
            if (ControlItem <> nil) and (ControlItem <> Self) then
              NewLocations.AddNewLocation(ControlItem, I, FRow, True);
          end;
          NewLocations.ApplyNewLocations;

          FColumnSpan := Value;
        end;
        Changed(False);
      finally
        NewLocations.Free;
      end;
    finally
    end;
  end;
end;

procedure TControlItem.InternalSetLocation(AColumn, ARow: Integer; APushed, MoveExisting: Boolean);
var
  Collection: TControlCollection;
  CurrentItem: TControlItem;
begin
  if (AColumn <> FColumn) or (ARow <> FRow) then
  begin
    if MoveExisting then
    begin
      Collection := TControlCollection(GetOwner);
      if Collection <> nil then
        CurrentItem := Collection.ControlItems[AColumn, ARow]
      else
        CurrentItem := nil;
      if CurrentItem <> nil then
        CurrentItem.InternalSetLocation(FColumn, FRow, False, False);
    end;
    FColumn := AColumn;
    FRow := ARow;
    if APushed then
      Inc(FPushed)
    else if FPushed > 0 then
      Dec(FPushed);
    Changed(False);
  end;
end;

procedure TControlItem.SetLocation(AColumn, ARow: Integer; APushed: Boolean);
begin
  InternalSetLocation(AColumn, ARow, APushed, True);
end;

function TControlItem.GetPushed: Boolean;
begin
  Result := FPushed > 0;
end;

end.
