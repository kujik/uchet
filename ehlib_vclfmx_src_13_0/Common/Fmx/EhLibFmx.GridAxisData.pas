{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                EhLibFmx.GridAxisData                  }
{                                                       }
{     Copyright (c) 2024-2025 by Dmitry V. Bolshakov    }
{                                                       }
{*******************************************************}

unit EhLibFmx.GridAxisData;

interface

{$SCOPEDENUMS ON}

uses System.SysUtils, System.Classes, System.Types, FMX.Controls,
  EhLibFmx.Types;

type
{ TGridAxisDataEh }

  TGridAxisDataEh = class(TPersistent)
  private
    FContraCelCount: Integer;
    FContraCelLens: TIntegerDynArray;
    FDefaultCelLen: Integer;
    FFixedCelCount: Integer;
    FFixedCelLens: TIntegerDynArray;
    FFrozenCelCount: Integer;
    FGrid: TControl;
    FRollCelCount: Integer;
    FRolCelLens: TIntegerDynArray;
    FRollStartVisCel: Integer;
    FRollStartVisibleCellOffset: Integer;
    FRollStartVisPos: Int64;

    function GetCelCount: Integer;
    function GetCelLens(Index: Integer): Integer;
    function GetContraCelLens(Index: Integer): Integer;
    function GetFixedCelLens(Index: Integer): Integer;
    function GetFullCelCount: Integer;
    function GetGridClientLen: Integer;
    function GetGridClientStart: Integer;
    function GetGridClientStop: Integer;
    function GetRollCelLens(Index: Integer): Integer;
    function GetRollClientLen: Integer;
    function GetRollInClientBoundary: Integer;
    function GetRollLastFullVisCel: Integer;
    function GetRollLastVisCel: Integer;
    function GetRollLen: Int64;
    function GetRollLocCelPosArr(Index: Integer): Int64;
    function GetRollStopVisPos: Int64;
    function GetStartVisCel: Integer;

    procedure SetCelLens(Index: Integer; const Value: Integer);
    procedure SetContraCelCount(const Value: Integer);
    procedure SetContraCelLens(Index: Integer; const Value: Integer);
    procedure SetDefaultCelLen(const Value: Integer);
    procedure SetFixedCelLens(Index: Integer; const Value: Integer);
    procedure SetFrozenCelCount(const Value: Integer);
    procedure SetRollCelCount(const Value: Integer);
    procedure SetRollCelLens(Index: Integer; const Value: Integer);
    procedure SetRollLocCelPosArr(Index: Integer; const Value: Int64);
    procedure SetRollStartVisPos(const Value: Int64);
    procedure SetFixedCelCount(const Value: Integer);
    function GetInEndOfRoll: Boolean;

  protected
    FRollLocCelPosArrObsolete: Boolean;
    FFrozenLen: Integer;
    FFixedBoundary: Integer;
    FContraStart: Integer;
    FContraLen: Integer;
    FGridClientStart: Integer;
    FGridClientStop: Integer;
    FWinClientBoundSta: Integer;
    FWinClientBoundSto: Integer;
    FRollLocCelPosArr: TInt64DynArray;
    FRollLastVisCel: Integer;
    FRollLastFullVisCel: Integer;

    procedure GetLastVisibleCell(var LastVisCell, LastFullVisCell: Integer);
    procedure UpdateRollCelPosArr;
    procedure InsertRollCells(const Pos, Count: Integer);
    procedure DeleteRollCells(const Pos, Count: Integer);

  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    function CheckRollStartVisPos(const ARolStartVisPos: Int64): Int64;
    function GetScrollStep: Integer;
    function GetRollStartVisCel(NewStartCell: Integer; ScrollStepType: TScrollStepTypeEh = TScrollStepTypeEh.ByPixel): Integer;
    function CalcMaxStartCellFor(RolFinishCell: Integer): Integer;
    function GetFixedCelPos(Index: Integer): Integer;

    procedure RollCellAtPos(Pos: Int64; var ACel, ACelOffset: Integer);
    procedure CheckUpdateRollCelPosArr;
    procedure CheckUpdateAxises;
    procedure MoveCel(FromIndex, ToIndex: Integer);
    procedure SwapRightToLeftPoses(var Pos1, Pos2: Integer);
    function RightToLeftReflect(const APos: Integer): Integer;
    procedure UpdateVisCells;

    property FixedCelCount: Integer read FFixedCelCount write SetFixedCelCount;
    property FrozenCelCount: Integer read FFrozenCelCount write SetFrozenCelCount;
    property RollCelCount: Integer read FRollCelCount write SetRollCelCount;
    property ContraCelCount: Integer read FContraCelCount write SetContraCelCount;

    property CelCount: Integer read GetCelCount;
    property FullCelCount: Integer read GetFullCelCount;

    property WinClientBoundSta: Integer read FWinClientBoundSta;
    property WinClientBoundSto: Integer read FWinClientBoundSto;
    property GridClientStart: Integer read GetGridClientStart;
    property GridClientStop: Integer read GetGridClientStop;
    property GridClientLen: Integer read GetGridClientLen;

    property FixedBoundary: Integer read FFixedBoundary;
    property RollClientLen: Integer read GetRollClientLen;

    property ContraStart: Integer read FContraStart;
    property ContraLen: Integer read FContraLen;

    property FrozenLen: Integer read FFrozenLen;

    property RollStartVisPos: Int64 read FRollStartVisPos write SetRollStartVisPos;
    property RollStopVisPos: Int64 read GetRollStopVisPos;

    property RollLen: Int64 read GetRollLen;
    property RollInClientBoundary: Integer read GetRollInClientBoundary;
    property InEndOfRol: Boolean read GetInEndOfRoll;

    property RollStartVisCel: Integer read FRollStartVisCel;
    property RollStartVisibleCellOffset: Integer read  FRollStartVisibleCellOffset;
    property RollLastVisCel: Integer read GetRollLastVisCel;
    property RollLastFullVisCel: Integer read GetRollLastFullVisCel;

    property StartVisCel: Integer read GetStartVisCel;

    property FixedCelLens[Index: Integer]: Integer read GetFixedCelLens write SetFixedCelLens;
    property RollCelLens[Index: Integer]: Integer read GetRollCelLens write SetRollCelLens;
    property ContraCelLens[Index: Integer]: Integer read GetContraCelLens write SetContraCelLens;

    property CelLens[Index: Integer]: Integer read GetCelLens write SetCelLens;
    property DefaultCelLen: Integer read FDefaultCelLen write SetDefaultCelLen;
    property RollLocCelPosArr[Index: Integer]: Int64 read GetRollLocCelPosArr write SetRollLocCelPosArr;

  end;

procedure BinarySearch(Poses: TInt64DynArray; TargetPos: Int64; var AColIndex, AColOffset: Integer);
procedure FillArray(Arr: TIntegerDynArray; const Pos, Count, Value: Integer);

implementation

uses EhLibFmx.Grids;

type
  TCustomGridEhCrack = class(TCustomGridEh);

  TGridAxisDataEhHelper = class helper for TGridAxisDataEh
  private
    function GetGrid: TCustomGridEhCrack;
  public
    property Grid: TCustomGridEhCrack read GetGrid;
  end;

procedure ArrayMove(var Extents: TIntegerDynArray; FromIndex, ToIndex: Longint);
var
  Extent, I: Integer;
begin
  if Length(Extents) <> 0 then
  begin
    Extent := Extents[FromIndex];
    if FromIndex < ToIndex then
      for I := FromIndex + 1 to ToIndex do
        Extents[I - 1] := Extents[I]
    else if FromIndex > ToIndex then
      for I := FromIndex - 1 downto ToIndex do
        Extents[I + 1] := Extents[I];
    Extents[ToIndex] := Extent;
  end;
end;

procedure FillArray(Arr: TIntegerDynArray; const Pos, Count, Value: Integer);
var
  i: Integer;
begin
  for i := Pos to Pos + Count - 1 do
    Arr[i] := Value;
end;

procedure BinarySearch(Poses: TInt64DynArray; TargetPos: Int64; var AColIndex, AColOffset: Integer);
var
  AMin, AMax: Integer;
  ArrSize, AIdx, ANewIdx: Integer;
begin
  ArrSize := Length(Poses);
  AMin := 0;
  AMax := ArrSize-1;
  if Poses[AMin] >= TargetPos then
  begin
    AColIndex := AMin;
    AColOffset := TargetPos - Poses[AMin];
    Exit;
  end else if Poses[AMax] <= TargetPos then
  begin
    AColIndex := AMax;
    AColOffset := TargetPos - Poses[AMax];
    Exit;
  end;

  AIdx := (AMax - AMin) div 2;
  ANewIdx := AIdx;

  while True do
  begin
    if Poses[AIdx] > TargetPos then
    begin
      AMax := AIdx;
      AIdx := (AMax + AMin) div 2;
    end else if Poses[AIdx] < TargetPos then
    begin
      AMin := AIdx;
      AIdx := (AMax + AMin) div 2;
    end else
    begin
      AColIndex := AIdx;
      AColOffset := 0;
      Exit;
    end;
    if ANewIdx = AIdx then
    begin
      AColIndex := AIdx;
      AColOffset := TargetPos - Poses[AIdx];
      Break;
    end;
    ANewIdx := AIdx;
  end;
end;

procedure ArrayInsertRange(var Extents: TIntegerDynArray; StartIndex, Amount: Longint);
var
  I: Integer;
begin
  if Amount < 0 then raise Exception.Create('ArrayInsertRange: (Amount < 0)');
  if StartIndex > Length(Extents) then raise Exception.Create('ArrayInsertRange: StartIndex > Length(Extents)');

  if Length(Extents) = StartIndex then
    SetLength(Extents, Length(Extents)+Amount)
  else
  begin
    SetLength(Extents, Length(Extents)+Amount);
    for I := Length(Extents)- Amount - 1 downto StartIndex do
      Extents[I+Amount] := Extents[I];
  end;
end;

procedure ArrayDeleteRange(var Extents: TIntegerDynArray; StartIndex, Amount: Longint);
var
  I: Integer;
begin
  if Amount < 0 then raise Exception.Create('ArrayDeleteRange: (Amount < 0)');
  if StartIndex + Amount > Length(Extents) then raise Exception.Create('ArrayDeleteRange: StartIndex + Amount > Length(Extents)');

  if StartIndex + Amount < Length(Extents) then
    for I := StartIndex to Length(Extents) - Amount - 1 do
      Extents[I] := Extents[I+Amount];

  SetLength(Extents, Length(Extents)-Amount);
end;

{ TGridAxisDataEhHelper }

function TGridAxisDataEhHelper.GetGrid: TCustomGridEhCrack;
begin
  Result := TCustomGridEhCrack(FGrid);
end;

{ TGridAxisDataEh }

constructor TGridAxisDataEh.Create(AGrid: TControl);
begin
  inherited Create;
  FGrid := AGrid;
end;

destructor TGridAxisDataEh.Destroy;
begin
  inherited Destroy;
end;

procedure TGridAxisDataEh.CheckUpdateAxises;
begin
  Grid.CheckUpdateAxises;
end;

procedure TGridAxisDataEh.CheckUpdateRollCelPosArr;
begin
  if FRollLocCelPosArrObsolete then
  begin
    UpdateRollCelPosArr;
    Grid.RolSizeUpdated;
  end;
end;

procedure TGridAxisDataEh.UpdateRollCelPosArr;
var
  i: Integer;
begin
  FRollLocCelPosArr[0] := 0;
  for i := 1 to RollCelCount-1 do
    FRollLocCelPosArr[i] := FRollLocCelPosArr[i-1] + FRolCelLens[i-1];
  UpdateVisCells;
  FRollLocCelPosArrObsolete := False;
end;

function TGridAxisDataEh.GetCelLens(Index: Integer): Integer;
begin
  if Index < FixedCelCount then
    Result := FixedCelLens[Index]
  else if Index < CelCount then
    Result := FRolCelLens[Index-FixedCelCount]
  else
    Result := FContraCelLens[Index-CelCount];
end;

procedure TGridAxisDataEh.SetCelLens(Index: Integer; const Value: Integer);
begin
  if Index < FixedCelCount then
    FixedCelLens[Index] := Value
  else if Index < CelCount then
    RollCelLens[Index-FixedCelCount] := Value
  else
    ContraCelLens[Index-CelCount] := Value;
end;

function TGridAxisDataEh.GetFixedCelLens(Index: Integer): Integer;
begin
  Result := FFixedCelLens[Index];
end;

function TGridAxisDataEh.GetFixedCelPos(Index: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Index-1 do
    Result := Result + FixedCelLens[i];
end;

procedure TGridAxisDataEh.SetFixedCelCount(const Value: Integer);
var
  Delta: Integer;
begin
  if FFixedCelCount <> Value then
  begin
    if Value < 0 then
      raise Exception.Create('RolColCount can''t be less then 0');
    Delta := Value - FFixedCelCount;
    SetLength(FFixedCelLens, Value);
    if Delta > 0 then
      FillArray(FFixedCelLens, FFixedCelCount, Delta, DefaultCelLen);
    FFixedCelCount := Value;
    Grid.CellCountChanged;
    Grid.UpdateBoundaries;
  end;
end;

procedure TGridAxisDataEh.SetFixedCelLens(Index: Integer; const Value: Integer);
var
  OldLen: Integer;
begin
  if FFixedCelLens[Index] <> Value then
  begin
    OldLen := FFixedCelLens[Index];
    FFixedCelLens[Index] := Value;
    Grid.CelLenChanged(Self, Index, OldLen);
  end;
end;

function TGridAxisDataEh.GetContraCelLens(Index: Integer): Integer;
begin
  Result := FContraCelLens[Index];
end;

procedure TGridAxisDataEh.SetContraCelCount(const Value: Integer);
var
  Delta: Integer;
begin
  if FContraCelCount <> Value then
  begin
    if Value < 0 then
      raise Exception.Create('ContraCelCount can''t be less then 0');
    Delta := Value - FContraCelCount;
    SetLength(FContraCelLens, Value);
    if Delta > 0 then
      FillArray(FContraCelLens, FContraCelCount, Delta, DefaultCelLen);
    FContraCelCount := Value;
    Grid.CellCountChanged;
    Grid.UpdateBoundaries;
  end;
end;

procedure TGridAxisDataEh.SetContraCelLens(Index: Integer; const Value: Integer);
var
  OldLen: Integer;
begin
  if FContraCelLens[Index] <> Value then
  begin
    OldLen := FContraCelLens[Index];
    FContraCelLens[Index] := Value;
    Grid.CelLenChanged(Self, Index + CelCount, OldLen + CelCount);
  end;
end;

function TGridAxisDataEh.GetRollCelLens(Index: Integer): Integer;
begin
  Result := FRolCelLens[Index];
end;

procedure TGridAxisDataEh.SetRollCelLens(Index: Integer; const Value: Integer);
var
  OldLen: Integer;
begin
  if FRolCelLens[Index] <> Value then
  begin
    OldLen := FRolCelLens[Index];
    FRolCelLens[Index] := Value;
    FRollLocCelPosArrObsolete := True;
    Grid.CelLenChanged(Self, Index + FixedCelCount, OldLen + FixedCelCount);
    Grid.CellCountChanged;
  end;
end;

function TGridAxisDataEh.GetRollClientLen: Integer;
begin
  Result := ContraStart - FixedBoundary;
  if Result < 0 then Result := 0;
end;

function TGridAxisDataEh.GetRollLocCelPosArr(Index: Integer): Int64;
begin
  CheckUpdateRollCelPosArr;
  Result := FRollLocCelPosArr[Index];
end;

procedure TGridAxisDataEh.SetRollLocCelPosArr(Index: Integer; const Value: Int64);
begin
  FRollLocCelPosArr[Index] := Value;
end;

function TGridAxisDataEh.GetCelCount: Integer;
begin
  Result := FixedCelCount + RollCelCount;
end;

function TGridAxisDataEh.GetFullCelCount: Integer;
begin
  Result := FixedCelCount + RollCelCount + ContraCelCount;
end;

function TGridAxisDataEh.GetRollLastFullVisCel: Integer;
begin
  CheckUpdateRollCelPosArr;
  Result := FRollLastFullVisCel;
end;

function TGridAxisDataEh.GetRollLastVisCel: Integer;
begin
  CheckUpdateRollCelPosArr;
  Result := FRollLastVisCel;
end;

function TGridAxisDataEh.GetRollLen: Int64;
begin
  Result := RollLocCelPosArr[Length(FRollLocCelPosArr)-1] + RollCelLens[Length(FRolCelLens)-1];
end;

function TGridAxisDataEh.GetRollInClientBoundary: Integer;
begin
  Result := FixedBoundary - RollStartVisPos + RollLen;
  if Result > ContraStart then
    Result := ContraStart;
end;

function TGridAxisDataEh.GetInEndOfRoll: Boolean;
var
  RolBound: Integer;
begin
  RolBound := FixedBoundary - RollStartVisPos + RollLen;
  if RolBound <= ContraStart then
    Result := True
  else
    Result := False;
end;

function TGridAxisDataEh.GetRollStopVisPos: Int64;
begin
  Result := RollStartVisPos + RollLen;
end;

function TGridAxisDataEh.GetGridClientLen: Integer;
begin
  Result := GridClientStop - GridClientStart;
end;

function TGridAxisDataEh.GetGridClientStart: Integer;
begin
  CheckUpdateAxises;
  Result := FGridClientStart;
end;

function TGridAxisDataEh.GetGridClientStop: Integer;
begin
  CheckUpdateAxises;
  Result := FGridClientStop;
end;

procedure TGridAxisDataEh.GetLastVisibleCell(var LastVisCell, LastFullVisCell: Integer);
var
  ATargetPos, ATargetCellOffset: Integer;
  i: Integer;
begin
  LastVisCell := -1;
  LastFullVisCell := -1;
  if FixedBoundary >= ContraStart then
  begin
    LastVisCell := RollStartVisCel;
    LastFullVisCell := RollStartVisCel;
  end else
  begin
    ATargetPos := RollStartVisPos + RollClientLen - 1;
    BinarySearch(FRollLocCelPosArr, ATargetPos, LastVisCell, ATargetCellOffset);

    for i := LastVisCell+1 to RollCelCount-1 do
    begin
      if FRollLocCelPosArr[i] <= ATargetPos then
      begin
        LastVisCell := LastVisCell + 1;
      end else
        Break;
    end;

    if (ATargetCellOffset < RollCelLens[LastVisCell]-1) and (LastVisCell > RollStartVisCel)
      then LastFullVisCell := LastVisCell - 1
      else LastFullVisCell := LastVisCell;
  end;
end;

procedure TGridAxisDataEh.SetRollCelCount(const Value: Integer);
var
  Delta: Integer;
begin
  if FRollCelCount <> Value then
  begin
    if Value < 1 then
      raise Exception.Create('RolCelCount can''t be less then 1');
    Delta := Value - FRollCelCount;
    if Delta > 0 then
      InsertRollCells(FRollCelCount, Delta)
    else if Delta < 0 then
      DeleteRollCells(FRollCelCount+Delta, -Delta);
  end;
end;

procedure TGridAxisDataEh.InsertRollCells(const Pos, Count: Integer);
begin
  ArrayInsertRange(FRolCelLens, Pos, Count);
  FillArray(FRolCelLens, Pos, Count, DefaultCelLen);

  SetLength(FRollLocCelPosArr, Length(FRolCelLens));

  FRollCelCount := Length(FRolCelLens);
  FRollLocCelPosArrObsolete := True;
  Grid.CellCountChanged;
end;

procedure TGridAxisDataEh.DeleteRollCells(const Pos, Count: Integer);
begin
  ArrayDeleteRange(FRolCelLens, Pos, Count);
  SetLength(FRollLocCelPosArr, Length(FRolCelLens));
  FRollCelCount := Length(FRolCelLens);
  FRollLocCelPosArrObsolete := True;
  Grid.CellCountChanged;
end;

procedure TGridAxisDataEh.MoveCel(FromIndex, ToIndex: Integer);
begin
  if (FromIndex <= FixedCelCount-1) and (ToIndex <= FixedCelCount-1)  then
    ArrayMove(FFixedCelLens, FromIndex, ToIndex)
  else if (FromIndex >= FixedCelCount) and (FromIndex <= CelCount-1) and
          (ToIndex >= FixedCelCount) and (ToIndex <= CelCount-1) then
  begin
    ArrayMove(FRolCelLens, FromIndex-FixedCelCount, ToIndex-FixedCelCount);
    FRollLocCelPosArrObsolete := True;
  end else if (FromIndex >= CelCount) and (FromIndex <= FullCelCount-1) and
          (ToIndex >= CelCount) and (ToIndex <= FullCelCount-1) then
    ArrayMove(FContraCelLens, FromIndex-CelCount, ToIndex-CelCount)
  else
    raise Exception.Create(
      Format('MoveCel in different areas[FromIndex:%D, ToIndex:%D', [FromIndex, ToIndex]));
  Grid.AxisMoved(Self, FromIndex, ToIndex);
end;

procedure TGridAxisDataEh.SetDefaultCelLen(const Value: Integer);
begin
  if FDefaultCelLen <> Value then
  begin
    FDefaultCelLen := Value;
  end;
end;

function TGridAxisDataEh.GetScrollStep: Integer;
begin
  Result := (ContraStart - FixedBoundary) div 20;
  if Result = 0 then
    Result := 1;
end;

function TGridAxisDataEh.GetStartVisCel: Integer;
begin
  Result := RollStartVisCel + FixedCelCount;
end;

procedure TGridAxisDataEh.SetRollStartVisPos(const Value: Int64);
var
  OldRolStartVisPos: Integer;
begin
  if FRollStartVisPos <> Value then
  begin
    if Value > RollLen then
      raise Exception.Create('RolStartVisPos can''t be > RolLen');
    OldRolStartVisPos := FRollStartVisPos;
    FRollStartVisPos := Value;
    CheckUpdateRollCelPosArr;
    UpdateVisCells;
    Grid.RolPosAxisChanged(Self, OldRolStartVisPos);
  end;
end;

procedure TGridAxisDataEh.UpdateVisCells;
begin
  BinarySearch(FRollLocCelPosArr, FRollStartVisPos, FRollStartVisCel, FRollStartVisibleCellOffset);
  GetLastVisibleCell(FRollLastVisCel, FRollLastFullVisCel);
end;

procedure TGridAxisDataEh.SwapRightToLeftPoses(var Pos1, Pos2: Integer);
var
  TmpVal: Integer;
begin
  TmpVal := Pos2;
  Pos2  := WinClientBoundSto - WinClientBoundSta - Pos1;
  Pos1  := WinClientBoundSto - WinClientBoundSta - TmpVal;
end;

function TGridAxisDataEh.RightToLeftReflect(const APos: Integer): Integer;
begin
  Result := WinClientBoundSto - WinClientBoundSta - APos;
end;

function TGridAxisDataEh.CheckRollStartVisPos(const ARolStartVisPos: Int64): Int64;
begin
  Result := ARolStartVisPos;
  if Result > RollLen - RollClientLen then
    Result := RollLen - RollClientLen;
  if Result < 0 then
    Result := 0;
end;

function TGridAxisDataEh.GetRollStartVisCel(NewStartCell: Integer;
  ScrollStepType: TScrollStepTypeEh = TScrollStepTypeEh.ByPixel): Integer;
begin
  if NewStartCell < 0 then NewStartCell := 0;
  if NewStartCell >= RollCelCount then NewStartCell := RollCelCount-1;

  Result := RollLocCelPosArr[NewStartCell];
  if Result > RollLen - RollClientLen then
  begin
    if ScrollStepType = TScrollStepTypeEh.ByPixel then
    begin
      Result := RollLen - RollClientLen;
      Result := CheckRollStartVisPos(Result);
    end else
    begin
      NewStartCell := CalcMaxStartCellFor(RollCelCount-1);
      Result := RollLocCelPosArr[NewStartCell];
    end;
  end else
    Result := CheckRollStartVisPos(Result);
end;

function TGridAxisDataEh.CalcMaxStartCellFor(RolFinishCell: Integer): Integer;
var
  i: Integer;
begin
  Result := RolFinishCell;
  for i := RolFinishCell downto 0 do
  begin
    if ((RollLocCelPosArr[RolFinishCell] + RollCelLens[RolFinishCell]) - RollLocCelPosArr[i]) > RollClientLen then
      Break;
    Result := i;
  end;
end;

procedure TGridAxisDataEh.RollCellAtPos(Pos: Int64; var ACel, ACelOffset: Integer);
begin
  BinarySearch(FRollLocCelPosArr, Pos, ACel, ACelOffset);
end;

procedure TGridAxisDataEh.SetFrozenCelCount(const Value: Integer);
begin
  if FFrozenCelCount <> Value then
  begin
    FFrozenCelCount := Value;
    Grid.UpdateBoundaries;
  end;
end;


end.
