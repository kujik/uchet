{*******************************************************}
{                                                       }
{                      EhLib 12.1                       }
{                      LaPanelsEh                       }
{                                                       }
{    Copyright (c) 2022-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}

unit LaPanelsEh;

interface

{$SCOPEDENUMS ON}

uses
  Types, Classes, Messages, SysUtils, Variants,
  {$IFDEF EH_LIB_17} System.UITypes, {$ENDIF}
  {$IFDEF FPC}
  EhLibLclUtils,
  {$ELSE}
  EhLibVclUtils,
  {$ENDIF}
  Generics.Collections, DB, PrntsEh,
  LaObjectsEh, LaControlsEh,
  ToolCtrlsEh,
  ImgList, StdCtrls,
  Graphics, Controls, Forms, Dialogs;

type
  TLaContentPanelEh = class;
  TLaStackPanelEh = class;

{ TLaContentPanelEh }

  TLaContentPanelEh = class(TLaControlEh)
  private
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function DoQueryLayoutClientArea(QuerySize: TSize; ACanvas: TCanvas): TSize; overload; override;
    function DoPerformLayoutClientArea(ClientRect: TRect; ACanvas: TCanvas): TSize; overload; override;

    function DoQueryLayoutClientArea(QuerySize: TSize; ACanvas: TBasePrinterCanvas): TSize; overload; override;
    function DoPerformLayoutClientArea(ClientRect: TRect; ACanvas: TBasePrinterCanvas): TSize; overload; override;

  published
  end;

{ TLaStackPanelEh }

  TLaStackPanelEh = class(TLaControlEh)
  private
    FOrientation: TLaOrientation;
    procedure SetOrientation(const Value: TLaOrientation);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function DoQueryLayoutClientArea(QuerySize: TSize; ACanvas: TCanvas): TSize; overload; override;
    function DoPerformLayoutClientArea(ClientRect: TRect; ACanvas: TCanvas): TSize; overload; override;

    function DoQueryLayoutClientArea(QuerySize: TSize; ACanvas: TBasePrinterCanvas): TSize; overload; override;
    function DoPerformLayoutClientArea(ClientRect: TRect; ACanvas: TBasePrinterCanvas): TSize; overload; override;

  published
    property Orientation: TLaOrientation read FOrientation write SetOrientation default TLaOrientation.Vertical;
  end;

implementation

{ TLaContentPanelEh }

constructor TLaContentPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TLaContentPanelEh.Destroy;
begin
  inherited Destroy;
end;

procedure TLaContentPanelEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

function TLaContentPanelEh.DoQueryLayoutClientArea(QuerySize: TSize;
  ACanvas: TCanvas): TSize;
var
  I: Integer;
  LaObject: TLaObjectEh;
  ASize: TSize;
begin
  Result := CreateSize(0, 0);
  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := Children[I];
    ASize := LaObject.QueryLayout(QuerySize, ACanvas);
    if (ASize.cx > Result.cx) then
      Result.cx := ASize.cx;
    if (ASize.cy > Result.cy) then
      Result.cy := ASize.cy;
  end;
end;

function TLaContentPanelEh.DoQueryLayoutClientArea(QuerySize: TSize;
  ACanvas: TBasePrinterCanvas): TSize;
var
  I: Integer;
  LaObject: TLaObjectEh;
  ASize: TSize;
begin
  Result := CreateSize(0, 0);
  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := Children[I];
    ASize := LaObject.QueryLayout(QuerySize, ACanvas);
    if (ASize.cx > Result.cx) then
      Result.cx := ASize.cx;
    if (ASize.cy > Result.cy) then
      Result.cy := ASize.cy;
  end;
end;

function TLaContentPanelEh.DoPerformLayoutClientArea(ClientRect: TRect;
  ACanvas: TCanvas): TSize;
var
  I: Integer;
  LaObject: TLaObjectEh;
begin
  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := Children[I];
    LaObject.PerformLayout(ClientRect, ACanvas);
  end;
  Result := RectSize(ClientRect);
end;

function TLaContentPanelEh.DoPerformLayoutClientArea(ClientRect: TRect;
  ACanvas: TBasePrinterCanvas): TSize;
var
  I: Integer;
  LaObject: TLaObjectEh;
begin
  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := Children[I];
    LaObject.PerformLayout(ClientRect, ACanvas);
  end;
  Result := RectSize(ClientRect);
end;

{ TLaStackPanelEh }

constructor TLaStackPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOrientation := TLaOrientation.Vertical;
end;

destructor TLaStackPanelEh.Destroy;
begin
  inherited Destroy;
end;

procedure TLaStackPanelEh.SetOrientation(const Value: TLaOrientation);
begin
  FOrientation := Value;
end;

function TLaStackPanelEh.DoQueryLayoutClientArea(QuerySize: TSize; ACanvas: TCanvas): TSize;
var
  I: Integer;
  LaObject: TLaObjectEh;
  ASize: TSize;
  LaQuerySize: TSize;
begin
  Result := CreateSize(0, 0);

  if (Orientation = TLaOrientation.Vertical) then
  begin
    LaQuerySize.cx := QuerySize.cx;

{$IFDEF EH_LIB_18} 
    LaQuerySize.cy := Int32.MaxValue - 10000;
{$ELSE}
    LaQuerySize.cy := High(Integer) - 10000;
{$ENDIF}
  end
  else
  begin
{$IFDEF EH_LIB_18} 
    LaQuerySize.cx := Int32.MaxValue - 10000;
{$ELSE}
    LaQuerySize.cx := High(Integer) - 10000;
{$ENDIF}
    LaQuerySize.cy := QuerySize.cy;
  end;

  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := Children[I];
    ASize := LaObject.QueryLayout(LaQuerySize, ACanvas);

    if (Orientation = TLaOrientation.Vertical) then
    begin
      Result.cy := Result.cy + ASize.cy;
      if (Result.cx < ASize.cx ) then
        Result.cx := ASize.cx;
    end else
    begin
      Result.cx := Result.cx + ASize.cx;
      if (Result.cy < ASize.cy ) then
        Result.cy := ASize.cy;
    end;
  end;
end;

function TLaStackPanelEh.DoQueryLayoutClientArea(QuerySize: TSize;
  ACanvas: TBasePrinterCanvas): TSize;
var
  I: Integer;
  LaObject: TLaObjectEh;
  ASize: TSize;
  LaQuerySize: TSize;
begin
  Result := CreateSize(0, 0);

  if (Orientation = TLaOrientation.Vertical) then
  begin
    LaQuerySize.cx := QuerySize.cx;

{$IFDEF EH_LIB_18} 
    LaQuerySize.cy := Int32.MaxValue - 10000;
{$ELSE}
    LaQuerySize.cy := High(Integer) - 10000;
{$ENDIF}
  end
  else
  begin
{$IFDEF EH_LIB_18} 
    LaQuerySize.cx := Int32.MaxValue - 10000;
{$ELSE}
    LaQuerySize.cx := High(Integer) - 10000;
{$ENDIF}
    LaQuerySize.cy := QuerySize.cy;
  end;

  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := Children[I];
    ASize := LaObject.QueryLayout(LaQuerySize, ACanvas);

    if (Orientation = TLaOrientation.Vertical) then
    begin
      Result.cy := Result.cy + ASize.cy;
      if (Result.cx < ASize.cx ) then
        Result.cx := ASize.cx;
    end else
    begin
      Result.cx := Result.cx + ASize.cx;
      if (Result.cy < ASize.cy ) then
        Result.cy := ASize.cy;
    end;
  end;
end;

function TLaStackPanelEh.DoPerformLayoutClientArea(ClientRect: TRect; ACanvas: TCanvas): TSize;
var
  I: Integer;
  LaObject: TLaObjectEh;
  ASize: TSize;
  PerfRect: TRect;
  CurPos: TPoint;
begin
  CurPos.X := ClientRect.Left;
  CurPos.Y := ClientRect.Top;

  Result := CreateSize(0, 0);
  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := Children[I];
    if (Orientation = TLaOrientation.Vertical) then
    begin
      PerfRect := Rect(CurPos.X,
                       CurPos.Y,
                       CurPos.X + RectWidth(ClientRect),
                       CurPos.Y + LaObject.NeededSize.cy);
      ASize := LaObject.PerformLayout(PerfRect, ACanvas);
      CurPos.Y := CurPos.Y + ASize.cy;
      if (Result.cx < ASize.cx) then
        Result.cx := ASize.cx;
      Result.cy := CurPos.Y;
    end else
    begin
      PerfRect := Rect(CurPos.X,
                       CurPos.Y,
                       CurPos.X + LaObject.NeededSize.cx,
                       CurPos.Y + RectHeight(ClientRect));
      ASize := LaObject.PerformLayout(PerfRect, ACanvas);
      CurPos.X := CurPos.X + ASize.cx;
      if (Result.cy < ASize.cy) then
        Result.cy := ASize.cy;
      Result.cx := CurPos.X;
    end;
  end;
end;

function TLaStackPanelEh.DoPerformLayoutClientArea(ClientRect: TRect;
  ACanvas: TBasePrinterCanvas): TSize;
var
  I: Integer;
  LaObject: TLaObjectEh;
  ASize: TSize;
  PerfRect: TRect;
  CurPos: TPoint;
begin
  CurPos.X := ClientRect.Left;
  CurPos.Y := ClientRect.Top;

  Result := CreateSize(0, 0);
  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := Children[I];
    if (Orientation = TLaOrientation.Vertical) then
    begin
      PerfRect := Rect(CurPos.X,
                       CurPos.Y,
                       CurPos.X + RectWidth(ClientRect),
                       CurPos.Y + LaObject.NeededSize.cy);
      ASize := LaObject.PerformLayout(PerfRect, ACanvas);
      CurPos.Y := CurPos.Y + ASize.cy;
      if (Result.cx < ASize.cx) then
        Result.cx := ASize.cx;
      Result.cy := CurPos.Y;
    end else
    begin
      PerfRect := Rect(CurPos.X,
                       CurPos.Y,
                       CurPos.X + LaObject.NeededSize.cx,
                       CurPos.Y + RectHeight(ClientRect));
      ASize := LaObject.PerformLayout(PerfRect, ACanvas);
      CurPos.X := CurPos.X + ASize.cx;
      if (Result.cy < ASize.cy) then
        Result.cy := ASize.cy;
      Result.cx := CurPos.X;
    end;
  end;
end;

procedure TLaStackPanelEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);

  if (Source is TLaStackPanelEh) then
  begin
    Orientation := TLaStackPanelEh(Source).Orientation;
  end;
end;

end.
