{*******************************************************}
{                                                       }
{                     EhLib.Fmx 12.1                    }
{                 EhLibFmx.LaGridPanels                 }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

unit EhLibFmx.LaGridPanels;

interface

uses
  Types, Classes, Math,
  SysUtils, Variants,
  Generics.Collections, DB,
  FMX.ImgList, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  EhLibFmx.LaObjects, EhLibFmx.LaControls;

type
  TLaGridPanelSizeStyleEh = (Pixel, Weight, Auto);

  TLaGridPanelEh = class;

  EGridPanelException = class(Exception);

  TCellItem = class(TCollectionItem)
  private
    FSizeStyle: TLaGridPanelSizeStyleEh;
    FValue: Double;
    FSize: Single;
    FNeededSize: Single;
    FAutoAdded: Boolean;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure SetSizeStyle(Value: TLaGridPanelSizeStyleEh);
    procedure SetValue(Value: Double);

    property Size: Single read FSize write FSize;
    property AutoAdded: Boolean read FAutoAdded write FAutoAdded;
  public
    constructor Create(Collection: TCollection); override;
  published
    property SizeStyle: TLaGridPanelSizeStyleEh read FSizeStyle write SetSizeStyle default TLaGridPanelSizeStyleEh.Weight;
    property Value: Double read FValue write SetValue;
  end;

{ TRowItem }

  TRowItem = class(TCellItem);

{ TColumnItem }

  TColumnItem = class(TCellItem);

{ TCellCollection }

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

{ TRowCollection }

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

{ TColumnCollection }

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

{ TControlItem }

  TControlItem = class(TCollectionItem)
  private
    FControl: TLaObjectEh;
    FColIndex: Integer;
    FRowIndex: Integer;
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
    procedure InternalSetLocation(AColIndex, ARowIndex: Integer; APushed: Boolean; MoveExisting: Boolean);
    property GridPanel: TLaGridPanelEh read GetGridPanel;
    property Pushed: Boolean read GetPushed;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure SetLocation(AColIndex, ARowIndex: Integer; APushed: Boolean = False);
  published
    property Control: TLaObjectEh read FControl write SetControl;

    property ColIndex: Integer read FColIndex write SetColumn;
    property ColumnSpan: TCellSpan read FColumnSpan write SetColumnSpan default 1;

    property RowIndex: Integer read FRowIndex write SetRow;
    property RowSpan: TCellSpan read FRowSpan write SetRowSpan default 1;
  end;

{ TControlCollection }

  TControlCollection = class(TOwnedCollection)
  protected
    function GetControl(AColIndex, ARowIndex: Integer): TLaObjectEh;
    function GetControlItem(AColIndex, ARowIndex: Integer): TControlItem;
    function GetItem(Index: Integer): TControlItem;
    procedure SetControl(AColIndex, ARowIndex: Integer; Value: TLaObjectEh);
    procedure SetItem(Index: Integer; Value: TControlItem);
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TControlItem;

    procedure AddControl(AControl: TLaObjectEh; AColIndex: Integer = -1; ARowIndex: Integer = -1);
    procedure RemoveControl(AControl: TLaObjectEh);

    function IndexOf(AControl: TLaObjectEh): Integer;
    function Owner: TLaGridPanelEh;

    property Controls[AColIndex, ARowIndex: Integer]: TLaObjectEh read GetControl write SetControl;
    property ControlItems[AColIndex, ARowIndex: Integer] : TControlItem read GetControlItem;
    property Items[Index: Integer]: TControlItem read GetItem write SetItem; default;
  end;

{ TLaGridPanelCellPosEh }

  TLaGridPanelCellPosEh = record
    ColIndex: Integer;
    RowIndex: Integer;

    constructor Create(AColIndex: Integer; ARowIndex: Integer);
  end;

{ TLaGridPanelCellEh }

  TLaGridPanelCellEh = class(TLaObjectEh)
  public
    function DoQueryLayout(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; override;
    function DoPerformLayout(const PerfSize: TSizeF; ACanvas: TCanvas): TSizeF; override;
  end;

{ TLaGridPanelEh }

  TLaGridPanelEh = class(TLaControlEh)
  private
    FRowCollection: TRowCollection;
    FColumnCollection: TColumnCollection;
    FControlCollection: TControlCollection;
    FRecalcCellSizes: Boolean;
    FRecalcCellSizesDisabled: Integer;
    FRecalcCellPercentsDisabled: Boolean;
    FClientSize: TSizeF;
    FGridQuerySize: TSizeF;
    FGridQueryCalculatedSize: TSizeF;

    FDummyColumnWidth: Single;
    FDummyRowHeight: Single;
    FDummyNeededColumnWidth: Single;
    FDummyNeededRowHeight: Single;

    FGridCells: TDictionary<TLaGridPanelCellPosEh, TLaGridPanelCellEh>;

    function GetCellCount: Integer;
    function GetCellSizes(AColIndex, ARowIndex: Integer): TSizeF;
    function GetCellRect(AColIndex, ARowIndex: Integer): TRectF;
    function GetColumnSpanIndex(AColIndex, ARowIndex: Integer): Integer;
    function GetRowSpanIndex(AColIndex, ARowIndex: Integer): Integer;
    function GetRecalcCellSizesEnabled: Boolean;
    function GetRecalcCellPercentsEnabled: Boolean;

    procedure SetColumnCollection(const Value: TColumnCollection);
    procedure SetControlCollection(const Value: TControlCollection);
    procedure SetRowCollection(const Value: TRowCollection);
    procedure RecalcCellDimensions(const APanelSize: TSizeF; ACanvas: TCanvas; IsQueryLayout: Boolean); overload;
    function GetColLayoutCount: Integer;
    function GetRowLayoutCount: Integer;
    procedure InitNeededSize(AInitSize: TSizeF);
    procedure PrepareForRecalcCellDimensions;
  protected
    function AutoAddColumn: TColumnItem;
    function AutoAddRow: TRowItem;
    function CellToCellIndex(AColIndex, ARowIndex: Integer): Integer;

    procedure CellIndexToCell(AIndex: Integer; var AColIndex, ARowIndex: Integer);
    procedure RemoveEmptyAutoAddColumns;
    procedure RemoveEmptyAutoAddRows;
    procedure AddControlToCell(AColumnIndex, ARowIndex: Integer; AControl: TLaObjectEh);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; overload; override;
    function DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF; overload; override;

    procedure BeginUpdate; reintroduce;
    procedure EndUpdate; reintroduce;
    function IsColumnEmpty(AColIndex: Integer): Boolean;
    function IsRowEmpty(ARowIndex: Integer): Boolean;

    procedure UpdateControlsColumn(AColIndex: Integer);
    procedure UpdateControlsRow(ARowIndex: Integer);

    property ColumnSpanIndex[AColIndex, ARowIndex: Integer]: Integer read GetColumnSpanIndex;
    property CellCount: Integer read GetCellCount;
    property CellSize[AColIndex, ARowIndex: Integer]: TSizeF read GetCellSizes;
    property CellRect[AColIndex, ARowIndex: Integer]: TRectF read GetCellRect;
    property ColLayoutCount: Integer read GetColLayoutCount;
    property RowLayoutCount: Integer read GetRowLayoutCount;
    property RecalcCellSizesEnabled: Boolean read GetRecalcCellSizesEnabled;
    property RecalcCellPercentsEnabled: Boolean read GetRecalcCellPercentsEnabled;
    property ControlCollection: TControlCollection read FControlCollection write SetControlCollection;
    property ColumnCollection: TColumnCollection read FColumnCollection write SetColumnCollection;
    property RowCollection: TRowCollection read FRowCollection write SetRowCollection;
    property RowSpanIndex[AColIndex, ARowIndex: Integer]: Integer read GetRowSpanIndex;
    property ClientSize: TSizeF read FClientSize;
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
  Result.SizeStyle := TLaGridPanelSizeStyleEh.Weight;
  Result.Value := 1;
  Result.AutoAdded := True;
end;

function TLaGridPanelEh.AutoAddRow: TRowItem;
begin
  Result := FRowCollection.Add;
  Result.SizeStyle := TLaGridPanelSizeStyleEh.Weight;
  Result.Value := 1;
  Result.AutoAdded := True;
end;

procedure TLaGridPanelEh.CellIndexToCell(AIndex: Integer; var AColIndex, ARowIndex: Integer);
begin
  AColIndex := AIndex div FRowCollection.Count;
  ARowIndex := AIndex mod FRowCollection.Count;
end;

function TLaGridPanelEh.CellToCellIndex(AColIndex, ARowIndex: Integer): Integer;
begin
  Result := ColumnSpanIndex[AColIndex, ARowIndex];
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

function TLaGridPanelEh.DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
begin
  PrepareForRecalcCellDimensions();
  FGridQuerySize.cx := QuerySize.cx;
  FGridQuerySize.cy := QuerySize.cy;
  RecalcCellDimensions(QuerySize, ACanvas, False);
  RecalcCellDimensions(QuerySize, ACanvas, True);
  InitNeededSize(QuerySize);
  Result := FGridQueryCalculatedSize;
end;

function TLaGridPanelEh.DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF;
var
  I: Integer;
  VCellRect: TRectF;
  CtlItem: TControlItem;
begin
  PrepareForRecalcCellDimensions();
  RecalcCellDimensions(ClientRect.Size, ACanvas, False);
  FClientSize.cx := RectWidth(ClientRect);
  FClientSize.cy := RectHeight(ClientRect);

  for I := 0 to ControlCollection.Count - 1 do
  begin
    CtlItem := ControlCollection[I];
    VCellRect := CellRect[CtlItem.ColIndex, CtlItem.RowIndex];
    if CtlItem.Control.Visible then
      CtlItem.Control.PerformLayout(VCellRect, ACanvas, VCellRect);
  end;

  Result.cx := RectWidth(ClientRect);
  Result.cy := RectHeight(ClientRect);
end;

function TLaGridPanelEh.GetCellCount: Integer;
begin
  Result := FRowCollection.Count * FColumnCollection.Count;
end;

procedure TLaGridPanelEh.InitNeededSize(AInitSize: TSizeF);
var
  I: Integer;
  Sz: Single;
begin
  FDummyNeededColumnWidth := FDummyColumnWidth;
  if ColumnCollection.Count > 0 then
  begin
    FGridQueryCalculatedSize.cx := 0;
    for I := 0 to ColumnCollection.Count - 1 do
    begin
      Sz := ColumnCollection[I].FSize;
      ColumnCollection[I].FNeededSize := Sz;
      FGridQueryCalculatedSize.cx := FGridQueryCalculatedSize.cx + Sz;
    end;
  end
  else
  begin
    FGridQueryCalculatedSize.cx := FDummyNeededColumnWidth;
  end;

  FDummyNeededRowHeight := FDummyRowHeight;
  if RowCollection.Count > 0 then
  begin
    FGridQueryCalculatedSize.cy := 0;
    for I := 0 to RowCollection.Count - 1 do
    begin
      Sz := RowCollection[I].FSize;
      RowCollection[I].FNeededSize := Sz;
      FGridQueryCalculatedSize.cy := FGridQueryCalculatedSize.cy + Sz;
    end;
  end
  else
  begin
    FGridQueryCalculatedSize.cy := FDummyNeededRowHeight;
  end;
end;

function TLaGridPanelEh.GetCellRect(AColIndex, ARowIndex: Integer): TRectF;
var
  I: Integer;
  ACellSize: TSizeF;
begin
  Result.Left := 0;
  Result.Top := 0;
  for I := 0 to AColIndex - 1 do
    Result.Left := Result.Left + FColumnCollection[I].Size;
  for I := 0 to ARowIndex - 1 do
    Result.Top := Result.Top + FRowCollection[I].Size;
  ACellSize := CellSize[AColIndex, ARowIndex];
  Result.BottomRight := PointF(ACellSize.cx, ACellSize.cy);
  Result.Bottom := Result.Bottom + Result.Top;
  Result.Right := Result.Right + Result.Left;
end;

function TLaGridPanelEh.GetCellSizes(AColIndex, ARowIndex: Integer): TSizeF;
begin
  if (AColIndex = -1) then
  begin
    if (IsInQueryLayout)
      then Result.cx := FGridQuerySize.cx
      else Result.cx := FClientSize.cx;
  end else
  begin
    Result.cx := FColumnCollection[AColIndex].Size;
  end;

  if (ARowIndex = -1) then
  begin
    if (IsInQueryLayout)
      then Result.cy := FGridQuerySize.cy
      else Result.cy := FClientSize.cy;
  end else
  begin
    Result.cy := FRowCollection[ARowIndex].Size;
  end;
end;

function TLaGridPanelEh.GetColumnSpanIndex(AColIndex, ARowIndex: Integer): Integer;
begin
  Result := AColIndex + (ARowIndex * FColumnCollection.Count);
end;

function TLaGridPanelEh.GetRowSpanIndex(AColIndex, ARowIndex: Integer): Integer;
begin
  Result := ARowIndex + (AColIndex * FRowCollection.Count);
end;

function TLaGridPanelEh.IsColumnEmpty(AColIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (AColIndex > -1) and (AColIndex < FColumnCollection.Count) then
  begin
    for I := 0 to FRowCollection.Count -1 do
      if ControlCollection.Controls[AColIndex, I] <> nil then
        Exit;
    Result := True;
  end else
    raise EGridPanelException.CreateFmt(sInvalidColumnIndex, [AColIndex]);
end;

function TLaGridPanelEh.IsRowEmpty(ARowIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (ARowIndex > -1) and (ARowIndex < FRowCollection.Count) then
  begin
    for I := 0 to FColumnCollection.Count -1 do
      if ControlCollection.Controls[I, ARowIndex] <> nil then
        Exit;
    Result := True;
  end else
    raise EGridPanelException.CreateFmt(sInvalidRowIndex, [ARowIndex]);
end;

procedure TLaGridPanelEh.RecalcCellDimensions(const APanelSize: TSizeF; ACanvas: TCanvas; IsQueryLayout: Boolean);
var
  I: Integer;
  XSize, YSize: Single;
  ColItem: TCellItem;
  RowItem: TCellItem;
  SumXWeight, SumYWeight: Double;
  WeightXSize, WeightYSize: Single;
  ACellAutoSize: TSizeF;

  function CalcCellAutoSize(AColIndex, ARowIndex: Integer): TSizeF;
  var
    I: Integer;
    CtlItem: TControlItem;
    ACellSize: TSizeF;
    ControlNeededSize: TSizeF;
  begin
    Result.cx := 0;
    Result.cy := 0;
    for I := 0 to ControlCollection.Count - 1 do
    begin
      CtlItem := ControlCollection[I];
      if (AColIndex = CtlItem.ColIndex) and
         (ARowIndex = CtlItem.RowIndex) and
         (CtlItem .Control.Visible = True) then
      begin
        ACellSize := CellSize[CtlItem.ColIndex, CtlItem.RowIndex];
        ControlNeededSize := CtlItem.Control.QueryLayout(ACellSize, ACanvas);
        if ControlNeededSize.cx > Result.cx then
          Result.cx := ControlNeededSize.cx;
        if ControlNeededSize.cy > Result.cy then
          Result.cy := ControlNeededSize.cy;
      end;
    end;
  end;

  function CalcAutoSizedColWidth(AColIndex: Integer): Single;
  var
    R: Integer;
  begin
    Result := 0;
    for R := 0 to FRowCollection.Count - 1 do
    begin
      ACellAutoSize := CalcCellAutoSize(AColIndex, R);

      if (ACellAutoSize.cx > Result) then
        Result := ACellAutoSize.cx;
    end;

    ACellAutoSize := CalcCellAutoSize(AColIndex, -1);
    if (ACellAutoSize.cx > Result) then
      Result := ACellAutoSize.cx;
  end;

  function CalcAutoSizedRowHeight(Row: Integer): Single;
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

    ACellAutoSize := CalcCellAutoSize(-1, Row);
    if (ACellAutoSize.cy > Result) then
      Result := ACellAutoSize.cy;
  end;

begin
  if not RecalcCellSizesEnabled then
    Exit;

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
        if ColItem.SizeStyle = TLaGridPanelSizeStyleEh.Pixel then
        begin
          ColItem.FSize := Trunc(ColItem.Value);
          XSize := XSize - ColItem.FSize;
        end
        else if (ColItem.SizeStyle = TLaGridPanelSizeStyleEh.Auto) then
        begin
          if (IsQueryLayout = False) then
            ColItem.FSize := CalcAutoSizedColWidth(I);
          XSize := XSize - ColItem.FSize;
        end
        else if (ColItem.SizeStyle = TLaGridPanelSizeStyleEh.Weight) then
        begin
          if IsQueryLayout then
          begin
            ColItem.FSize := CalcAutoSizedColWidth(I);
            XSize := XSize - ColItem.FSize;
          end else
          begin
            SumXWeight := SumXWeight + ColItem.Value;
          end;
        end;
      end;
    end else
    begin
      FDummyColumnWidth := CalcAutoSizedColWidth(-1);
      XSize := XSize - FDummyColumnWidth;
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
      if (ColItem.SizeStyle = TLaGridPanelSizeStyleEh.Weight) and
         (IsQueryLayout = False) then
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
        if RowItem.SizeStyle = TLaGridPanelSizeStyleEh.Pixel then
        begin
          RowItem.FSize := Trunc(RowItem.Value);
          YSize := YSize - RowItem.FSize;
        end
        else if RowItem.SizeStyle = TLaGridPanelSizeStyleEh.Auto then
        begin
          RowItem.FSize := CalcAutoSizedRowHeight(I);
          YSize := YSize - RowItem.FSize;
        end
        else if (RowItem.SizeStyle = TLaGridPanelSizeStyleEh.Weight) then
        begin
          if IsQueryLayout then
          begin
            RowItem.FSize := CalcAutoSizedRowHeight(I);
            YSize := YSize - RowItem.FSize;
          end else
          begin
            SumYWeight := SumYWeight + RowItem.Value;
          end;
        end;
      end;
    end else
    begin
      FDummyRowHeight := CalcAutoSizedRowHeight(-1);
      YSize := YSize - FDummyRowHeight;
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
      if (RowItem.SizeStyle = TLaGridPanelSizeStyleEh.Weight) and
         (IsQueryLayout = False) then
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

procedure TLaGridPanelEh.UpdateControlsColumn(AColIndex: Integer);
var
  I, J: Integer;
  AControlItem: TControlItem;
begin
  for I := AColIndex + 1 to FColumnCollection.Count - 1 do
    for J := 0 to FRowCollection.Count - 1 do
    begin
      AControlItem := FControlCollection.ControlItems[I, J];
      if (AControlItem <> nil) and
         (AControlItem.ColIndex = I) and
         (AControlItem.RowIndex = J)
      then
        AControlItem.SetColumn(AControlItem.ColIndex - 1);
    end;
end;

procedure TLaGridPanelEh.UpdateControlsRow(ARowIndex: Integer);
var
  I, J: Integer;
  AControlItem: TControlItem;
begin
  for I := 0 to FColumnCollection.Count - 1 do
    for J := ARowIndex + 1 to FRowCollection.Count - 1 do
    begin
      AControlItem := FControlCollection.ControlItems[I, J];
      if (AControlItem <> nil) and
         (AControlItem.ColIndex = I) and
         (AControlItem.RowIndex = J)
      then
        AControlItem.SetRow(AControlItem.RowIndex - 1);
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

      CtlItem.ColIndex := SrcCtlItem.ColIndex;
      CtlItem.ColumnSpan := SrcCtlItem.ColumnSpan;
      CtlItem.RowIndex := SrcCtlItem.RowIndex;
      CtlItem.RowSpan := SrcCtlItem.RowSpan;
      CtlItem.Control := TLaObjectEh(Children[CtlIndex]);
    end;
  end;
end;

procedure TLaGridPanelEh.AddControlToCell(AColumnIndex, ARowIndex: Integer; AControl: TLaObjectEh);
var
  PanelCell: TLaGridPanelCellEh;
  PanelCellPos: TLaGridPanelCellPosEh;
begin
  PanelCellPos := TLaGridPanelCellPosEh.Create(AColumnIndex, ARowIndex);
  if not FGridCells.TryGetValue(PanelCellPos, PanelCell) then
  begin
    PanelCell := TLaGridPanelCellEh.Create(Self);
    FGridCells.Add(PanelCellPos, PanelCell);
  end;

  PanelCell.AddObject(AControl);
end;

{ TCellItem }

constructor TCellItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FSizeStyle := TLaGridPanelSizeStyleEh.Weight;
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

procedure TCellItem.SetSizeStyle(Value: TLaGridPanelSizeStyleEh);
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
    if FSizeStyle = TLaGridPanelSizeStyleEh.Pixel then
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
        TLaGridPanelSizeStyleEh.Pixel: Result := sCellAbsoluteSize;
        TLaGridPanelSizeStyleEh.Weight: Result := sCellPercentSize;
      else
        Result := '';
      end;
  end;

  function GetValueString(Index: Integer): string;
  var
    CellItem: TCellItem;
  begin
    CellItem := Items[Index];
    if CellItem.SizeStyle = TLaGridPanelSizeStyleEh.Pixel then
      Result := IntToStr(Trunc(CellItem.Value))
    else if CellItem.SizeStyle = TLaGridPanelSizeStyleEh.Weight then
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
      if CellItem.SizeStyle = TLaGridPanelSizeStyleEh.Weight then
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

constructor TControlCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TControlItem);
end;

function TControlCollection.Add: TControlItem;
begin
  Result := TControlItem(inherited Add);
end;

procedure TControlCollection.AddControl(AControl: TLaObjectEh; AColIndex, ARowIndex: Integer);
var
  ControlItem: TControlItem;
begin
  if IndexOf(AControl) < 0 then
  begin
    ControlItem := Add();
    try
      ControlItem.Control := AControl;
      ControlItem.FColIndex := AColIndex;
      ControlItem.FRowIndex := ARowIndex;
    except
      ControlItem.Control := nil;
      Free;
      raise;
    end;
  end;
end;

function TControlCollection.GetControl(AColIndex, ARowIndex: Integer): TLaObjectEh;
var
  ControlItem: TControlItem;
begin
  ControlItem := GetControlItem(AColIndex, ARowIndex);
  if ControlItem <> nil then
    Result := ControlItem.Control
  else
    Result := nil;
end;

function TControlCollection.GetControlItem(AColIndex, ARowIndex: Integer): TControlItem;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := TControlItem(Items[I]);
    if (ARowIndex >= Result.RowIndex) and (ARowIndex <= Result.RowIndex + Result.RowSpan - 1) and
      (AColIndex >= Result.ColIndex) and (AColIndex <= Result.ColIndex + Result.ColumnSpan - 1) then
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

procedure TControlCollection.SetControl(AColIndex, ARowIndex: Integer; Value: TLaObjectEh);
var
  Index: Integer;
  ControlItem: TControlItem;
begin
  if Owner <> nil then
  begin
    if (AColIndex < 0) or (AColIndex >= Owner.ColumnCollection.Count) then
      raise EGridPanelException.CreateFmt(sInvalidColumnIndex, [AColIndex]);
    if (ARowIndex < 0) or (ARowIndex >= Owner.RowCollection.Count) then
      raise EGridPanelException.CreateFmt(sInvalidRowIndex, [ARowIndex]);
    Index := IndexOf(Value);
    if Index > -1 then
    begin
      ControlItem := Items[Index];
      ControlItem.FColIndex := AColIndex;
      ControlItem.FRowIndex := ARowIndex;
    end else
    begin
      AddControl(Value, AColIndex, ARowIndex);
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
      DestItCtl.FRowIndex := Self.RowIndex;
      DestItCtl.FColIndex := Self.ColIndex;
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
  FColIndex := -2;
  FRowIndex := -2;
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
  if FColIndex <> Value then
  begin
    InternalSetLocation(Value, FRowIndex, False, True);
  end;
end;

procedure TControlItem.SetRow(Value: Integer);
begin
  if FRowIndex <> Value then
  begin
    InternalSetLocation(FColIndex, Value, False, True);
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
          for I := FRowIndex + FRowSpan + Delta to NumRows - 1 do
          begin
            ControlItem := Collection.ControlItems[FColIndex, I];
            if ControlItem <> nil then
              if ControlItem.Pushed then
                NewLocations.AddNewLocation(ControlItem, FColIndex, I - Delta, False)
              else
                Break;
          end;
          NewLocations.ApplyNewLocations;
          GridPanel.RemoveEmptyAutoAddRows;
        end else
        begin
          NumRows := GridPanel.RowCollection.Count;
          Delta := Value - FRowSpan;
          for I := Min(FRowIndex + FRowSpan, NumRows) to Min(FRowIndex + Value - 1, NumRows - 1) do
            if Collection.Controls[FColIndex, I] = nil then
              Dec(Delta)
            else
              Break;
          MoveBy := Delta;
          for I := NumRows - 1 downto NumRows - MoveBy do
            if Collection.Controls[FColIndex, I] = nil then
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
            ControlItem := Collection.ControlItems[FColIndex, I - MoveBy];
            if (ControlItem <> nil) and (ControlItem <> Self) then
              NewLocations.AddNewLocation(ControlItem, FColIndex, I, True);
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
          for I := FColIndex + FColumnSpan + Delta to NumColumns - 1 do
          begin
            ControlItem := Collection.ControlItems[I, FRowIndex];
            if ControlItem <> nil then
              if ControlItem.Pushed then
                NewLocations.AddNewLocation(ControlItem, I - Delta, FRowIndex, False)
              else
                Break;
          end;
          NewLocations.ApplyNewLocations;
          GridPanel.RemoveEmptyAutoAddColumns;
        end else
        begin
          NumColumns := GridPanel.ColumnCollection.Count;
          Delta := Value - FColumnSpan;
          for I := Min(FColIndex + FColumnSpan, NumColumns) to Min(FColIndex + Value - 1, NumColumns - 1) do
            if Collection.Controls[I, FRowIndex] = nil then
              Dec(Delta)
            else
              Break;
          MoveBy := Delta;

          for I := NumColumns - 1 downto NumColumns - MoveBy do
            if Collection.Controls[I, FRowIndex] = nil then
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
            ControlItem := Collection.ControlItems[I - MoveBy, FRowIndex];
            if (ControlItem <> nil) and (ControlItem <> Self) then
              NewLocations.AddNewLocation(ControlItem, I, FRowIndex, True);
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

procedure TControlItem.InternalSetLocation(AColIndex, ARowIndex: Integer; APushed, MoveExisting: Boolean);
var
  Collection: TControlCollection;
  CurrentItem: TControlItem;
begin
  if (AColIndex <> FColIndex) or (ARowIndex <> FRowIndex) then
  begin
    if MoveExisting then
    begin
      Collection := TControlCollection(GetOwner);
      if Collection <> nil then
        CurrentItem := Collection.ControlItems[AColIndex, ARowIndex]
      else
        CurrentItem := nil;
      if CurrentItem <> nil then
        CurrentItem.InternalSetLocation(FColIndex, FRowIndex, False, False);
    end;
    FColIndex := AColIndex;
    FRowIndex := ARowIndex;
    if APushed then
      Inc(FPushed)
    else if FPushed > 0 then
      Dec(FPushed);
    Changed(False);
  end;
end;

procedure TControlItem.SetLocation(AColIndex, ARowIndex: Integer; APushed: Boolean);
begin
  InternalSetLocation(AColIndex, ARowIndex, APushed, True);
end;

function TControlItem.GetPushed: Boolean;
begin
  Result := FPushed > 0;
end;

{ TLaGridPanelCellEh }

function TLaGridPanelCellEh.DoQueryLayout(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
var
  FmxObject: TFmxObject;
  FmxControl: TControl;
  LaObject: TLaObjectEh;
  ASize: TSizeF;
  I: Integer;
begin
  Result := TSizeF.Create(0, 0);

  for I := 0 to ChildrenCount - 1 do
  begin
    FmxObject := Children[I];
    FmxControl := nil;
    LaObject := nil;

    if FmxObject is TControl then
      FmxControl := TControl(FmxObject);
    if FmxObject is TLaObjectEh then
      LaObject := TLaObjectEh(FmxObject);

    if (LaObject <> nil) then
    begin
      ASize := LaObject.QueryLayout(QuerySize, ACanvas);
    end
    else if (FmxControl <> nil) then
    begin
      ASize := FmxControl.Size.Size;
    end;

    if (ASize.cx > Result.cx) then
      Result.cx := ASize.cx;
    if (ASize.cy > Result.cy) then
      Result.cy := ASize.cy;
  end;
end;

function TLaGridPanelCellEh.DoPerformLayout(const PerfSize: TSizeF; ACanvas: TCanvas): TSizeF;
var
  FmxObject: TFmxObject;
  FmxControl: TControl;
  LaObject: TLaObjectEh;
  ASize: TSizeF;
  I: Integer;
  PerfRect: TRectF;
begin
  Result := TSizeF.Create(0, 0);
  PerfRect := RectF(0, 0, PerfSize.Width, PerfSize.Height);

  for I := 0 to ChildrenCount - 1 do
  begin
    FmxObject := Children[I];
    FmxControl := nil;
    LaObject := nil;

    if FmxObject is TControl then
      FmxControl := TControl(FmxObject);
    if FmxObject is TLaObjectEh then
      LaObject := TLaObjectEh(FmxObject);

    if (LaObject <> nil) then
    begin
      ASize := LaObject.PerformLayout(PerfRect, ACanvas, UnlimitedRect);
    end
    else if (FmxControl <> nil) then
    begin
      FmxControl.SetBounds(PerfRect.Left, PerfRect.Top, PerfRect.Width, PerfRect.Height);
      ASize := PerfRect.Size;
    end;

    Result := PerfSize;
  end;
end;

{ TLaGridPanelCellPosEh }

constructor TLaGridPanelCellPosEh.Create(AColIndex, ARowIndex: Integer);
begin
  ColIndex := AColIndex;
  RowIndex := ARowIndex;
end;

end.
