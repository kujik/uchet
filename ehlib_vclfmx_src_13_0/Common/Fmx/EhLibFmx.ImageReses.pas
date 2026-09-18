{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                  EhLibFmx.ImageReses                  }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.ImageReses;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  System.TypInfo, Data.DB,
  Data.DBConsts, System.RTLConsts, System.UITypes, System.Contnrs,
  System.Generics.Collections,
  FMX.Graphics, FMX.ImgList, FMX.MultiresBitmap,
  EhLibUtils, DBUtilsEh,
  EhLibFmx.Types;
{$ENDREGION 'uses'}

type

{ TResourceImageItemEh }

  TResourceImageItemEh = class(TPersistent)
  private
    FBitmap: TBitmap;

  protected
    procedure ClearImages(Images: TObjectList); virtual;

  public
    constructor Create;
    destructor Destroy; override;

    procedure InitGraphics(AStdImages: TBitmap; ADisableImages: TBitmap); virtual;

    function GetGraphic(MaxSize: TSize; ScaleFactor: Double; IsDisabled: Boolean; IsDarkTheme: Boolean): TBitmap; virtual;
    function GetImageForScale(Images: TObjectList; MaxSize: TSize; ScaleFactor: Double): TBitmap; virtual;
  end;

{ TEhLibImageResources }

  TEhLibImageResources = class(TPersistent)
  private
    FGridScrollBarNavCancelImageItem: TResourceImageItemEh;
    FGridScrollBarNavDeleteImageItem: TResourceImageItemEh;
    FGridScrollBarNavEditImageItem: TResourceImageItemEh;
    FGridScrollBarNavFirstImageItem: TResourceImageItemEh;
    FGridScrollBarNavInsertImageItem: TResourceImageItemEh;
    FGridScrollBarNavLastImageItem: TResourceImageItemEh;
    FGridScrollBarNavNextImageItem: TResourceImageItemEh;
    FGridScrollBarNavPostImageItem: TResourceImageItemEh;
    FGridScrollBarNavPriorImageItem: TResourceImageItemEh;
    FGridScrollBarNavRefreshImageItem: TResourceImageItemEh;
    FSearchPanelCancelSearchImageItem: TResourceImageItemEh;
    FSearchPanelFilterImageItem: TResourceImageItemEh;
    FSearchPanelFindNextImageItem: TResourceImageItemEh;
    FSearchPanelFindPriorImageItem: TResourceImageItemEh;
    FSearchPanelMenuImageItem: TResourceImageItemEh;
    FCustomizeColumnsDialogRight: TResourceImageItemEh;
    FCustomizeColumnsDialogDown: TResourceImageItemEh;
    FCustomizeColumnsDialogUp: TResourceImageItemEh;
    FCustomizeColumnsDialogLeft: TResourceImageItemEh;
    FCustomizeColumnsDialogSetColWidth: TResourceImageItemEh;

    FStyleResource: TDictionary<string, TBitmap>;

    FResourcesLoaded: Boolean;
    FGridCurrentRowSign: TFixedMultiResBitmap;
    FGridEditRowSign: TFixedMultiResBitmap;
    FGridNewRowSign: TFixedMultiResBitmap;
    FDropDownSign: TFixedMultiResBitmap;
    FDropDownArrowHasFilter: TFixedMultiResBitmap;

    FExpanderSignCollapsed: TFixedMultiResBitmap;
    FExpanderSignExpanded: TFixedMultiResBitmap;

    function GetBitmapStyleResource(ResourceName: String): TBitmap;
    function LoadBitmapStyleResource(ResourceName: String): TBitmap;

    procedure LoadResources;
    function GetGridScrollBarNavFirstImageItem: TResourceImageItemEh;
    function GetCustomizeColumnsDialogDown: TResourceImageItemEh;
    function GetCustomizeColumnsDialogLeft: TResourceImageItemEh;
    function GetCustomizeColumnsDialogRight: TResourceImageItemEh;
    function GetCustomizeColumnsDialogSetColWidth: TResourceImageItemEh;
    function GetCustomizeColumnsDialogUp: TResourceImageItemEh;
    function GetGridScrollBarNavCancelImageItem: TResourceImageItemEh;
    function GetGridScrollBarNavDeleteImageItem: TResourceImageItemEh;
    function GetGridScrollBarNavEditImageItem: TResourceImageItemEh;
    function GetGridScrollBarNavInsertImageItem: TResourceImageItemEh;
    function GetGridScrollBarNavLastImageItem: TResourceImageItemEh;
    function GetGridScrollBarNavNextImageItem: TResourceImageItemEh;
    function GetGridScrollBarNavPostImageItem: TResourceImageItemEh;
    function GetGridScrollBarNavPriorImageItem: TResourceImageItemEh;
    function GetGridScrollBarNavRefreshImageItem: TResourceImageItemEh;
    function GetSearchPanelCancelSearchImageItem: TResourceImageItemEh;
    function GetSearchPanelFilterImageItem: TResourceImageItemEh;
    function GetSearchPanelFindNextImageItem: TResourceImageItemEh;
    function GetSearchPanelFindPriorImageItem: TResourceImageItemEh;
    function GetSearchPanelMenuImageItem: TResourceImageItemEh;

  public
    constructor Create;
    destructor Destroy; override;

    procedure CheckLoadResources;
    procedure ResetResources;

    property GridScrollBarNavFirstImageItem: TResourceImageItemEh read GetGridScrollBarNavFirstImageItem;
    property GridScrollBarNavPriorImageItem: TResourceImageItemEh read GetGridScrollBarNavPriorImageItem;
    property GridScrollBarNavNextImageItem: TResourceImageItemEh read GetGridScrollBarNavNextImageItem;
    property GridScrollBarNavLastImageItem: TResourceImageItemEh read GetGridScrollBarNavLastImageItem;
    property GridScrollBarNavInsertImageItem: TResourceImageItemEh read GetGridScrollBarNavInsertImageItem;
    property GridScrollBarNavDeleteImageItem: TResourceImageItemEh read GetGridScrollBarNavDeleteImageItem;
    property GridScrollBarNavEditImageItem: TResourceImageItemEh read GetGridScrollBarNavEditImageItem;
    property GridScrollBarNavPostImageItem: TResourceImageItemEh read GetGridScrollBarNavPostImageItem;
    property GridScrollBarNavCancelImageItem: TResourceImageItemEh read GetGridScrollBarNavCancelImageItem;
    property GridScrollBarNavRefreshImageItem: TResourceImageItemEh read GetGridScrollBarNavRefreshImageItem;

    property SearchPanelCancelSearchImageItem: TResourceImageItemEh read GetSearchPanelCancelSearchImageItem;
    property SearchPanelFindNextImageItem: TResourceImageItemEh read GetSearchPanelFindNextImageItem;
    property SearchPanelFindPriorImageItem: TResourceImageItemEh read GetSearchPanelFindPriorImageItem;
    property SearchPanelMenuImageItem: TResourceImageItemEh read GetSearchPanelMenuImageItem;
    property SearchPanelFilterImageItem: TResourceImageItemEh read GetSearchPanelFilterImageItem;

    property CustomizeColumnsDialogDown: TResourceImageItemEh read GetCustomizeColumnsDialogDown;
    property CustomizeColumnsDialogUp: TResourceImageItemEh read GetCustomizeColumnsDialogUp;
    property CustomizeColumnsDialogLeft: TResourceImageItemEh read GetCustomizeColumnsDialogLeft;
    property CustomizeColumnsDialogRight: TResourceImageItemEh read GetCustomizeColumnsDialogRight;
    property CustomizeColumnsDialogSetColWidth: TResourceImageItemEh read GetCustomizeColumnsDialogSetColWidth;

    property BitmapResource[ResourceName: String]: TBitmap read GetBitmapStyleResource;

//    property ImageList: TImageList read FImageList;

    property GridCurrentRowSign: TFixedMultiResBitmap read FGridCurrentRowSign;
    property GridEditRowSign: TFixedMultiResBitmap read FGridEditRowSign;
    property GridNewRowSign: TFixedMultiResBitmap read FGridNewRowSign;

    property DropDownSign: TFixedMultiResBitmap read FDropDownSign;
    property DropDownArrowHasFilter: TFixedMultiResBitmap read FDropDownArrowHasFilter;

    property ExpanderSignCollapsed: TFixedMultiResBitmap read FExpanderSignCollapsed;
    property ExpanderSignExpanded: TFixedMultiResBitmap read FExpanderSignExpanded;
  end;

function EhLibImageResources: TEhLibImageResources;

implementation

uses
  EhLibFmx.Styles,
  EhLibFmx.ToolControls;

var
  FEhLibImageResources: TEhLibImageResources;

function EhLibImageResources: TEhLibImageResources;
begin
  Result := FEhLibImageResources;
end;

function ReloadImage(const SourceBitmap: TBitmap): TBitmap;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  SourceBitmap.SaveToStream(Stream);
  Stream.Position := 0;
  Result := TBitmap.Create;
  Result.LoadFromStream(Stream);
  Stream.Free;
end;

function InvertBitmapColors(const SourceBitmap: TBitmap): TBitmap;
var
  x, y: Integer;
  SrcColor, InvColor: TAlphaColor;
  SrcData, DstData: TBitmapData;
  TmpBitmap: TBitmap;
begin
  Result := nil;

  if not Assigned(SourceBitmap) then
    Exit;

  Result := TBitmap.Create(SourceBitmap.Width, SourceBitmap.Height);
  Result.CopyFromBitmap(SourceBitmap);
//  Exit;

  if SourceBitmap.Map(TMapAccess.Read, SrcData) then
  try
    if Result.Map(TMapAccess.Write, DstData) then
    try
      for y := 0 to SourceBitmap.Height - 1 do
        for x := 0 to SourceBitmap.Width - 1 do
        begin
          SrcColor := SrcData.GetPixel(x, y);

          InvColor :=
            (SrcColor and $FF000000) or  // keep Alpha
            ((not SrcColor) and $00FFFFFF);

          DstData.SetPixel(x, y, InvColor);
        end;
    finally
      Result.Unmap(DstData);
    end;
  finally
    SourceBitmap.Unmap(SrcData);
  end;

  TmpBitmap := Result;
  Result := ReloadImage(TmpBitmap);
  TmpBitmap.Free;
end;

{ TResourceImageItemEh }

constructor TResourceImageItemEh.Create;
begin
  FBitmap := TBitmap.Create;
end;

destructor TResourceImageItemEh.Destroy;
begin
  FreeAndNil(FBitmap);
  inherited Destroy;
end;

procedure TResourceImageItemEh.ClearImages(Images: TObjectList);
begin
end;

procedure TResourceImageItemEh.InitGraphics(AStdImages, ADisableImages: TBitmap);
begin
  FBitmap.Assign(AStdImages);
end;

function TResourceImageItemEh.GetGraphic(MaxSize: TSize; ScaleFactor: Double;
  IsDisabled, IsDarkTheme: Boolean): TBitmap;
begin
  Result := FBitmap;
end;

function TResourceImageItemEh.GetImageForScale(Images: TObjectList; MaxSize: TSize; ScaleFactor: Double): TBitmap;
begin
  Result := FBitmap;
end;

{ TEhLibImageResources }

constructor TEhLibImageResources.Create;
begin
  FStyleResource := TDictionary<string, TBitmap>.Create;
end;

destructor TEhLibImageResources.Destroy;
var
  Pair: TPair<string, TBitmap>;
begin
  for Pair in FStyleResource do
    Pair.Value.Free;
  FreeAndNil(FStyleResource);

  FreeAndNil(FGridScrollBarNavCancelImageItem);
  FreeAndNil(FGridScrollBarNavDeleteImageItem);
  FreeAndNil(FGridScrollBarNavEditImageItem);
  FreeAndNil(FGridScrollBarNavFirstImageItem);
  FreeAndNil(FGridScrollBarNavInsertImageItem);
  FreeAndNil(FGridScrollBarNavLastImageItem);
  FreeAndNil(FGridScrollBarNavNextImageItem);
  FreeAndNil(FGridScrollBarNavPostImageItem);
  FreeAndNil(FGridScrollBarNavPriorImageItem);
  FreeAndNil(FGridScrollBarNavRefreshImageItem);
  FreeAndNil(FSearchPanelCancelSearchImageItem);
  FreeAndNil(FSearchPanelFilterImageItem);
  FreeAndNil(FSearchPanelFindNextImageItem);
  FreeAndNil(FSearchPanelFindPriorImageItem);
  FreeAndNil(FSearchPanelMenuImageItem);

  FreeAndNil(FCustomizeColumnsDialogRight);
  FreeAndNil(FCustomizeColumnsDialogDown);
  FreeAndNil(FCustomizeColumnsDialogUp);
  FreeAndNil(FCustomizeColumnsDialogLeft);
  FreeAndNil(FCustomizeColumnsDialogSetColWidth);

  FreeAndNil(FGridCurrentRowSign);
  FreeAndNil(FGridEditRowSign);
  FreeAndNil(FGridNewRowSign);
  FreeAndNil(FDropDownSign);
  FreeAndNil(FDropDownArrowHasFilter);

  FreeAndNil(FExpanderSignCollapsed);
  FreeAndNil(FExpanderSignExpanded);

  inherited Destroy;
end;

procedure TEhLibImageResources.CheckLoadResources;
begin
  if FResourcesLoaded = False then
  begin
    FResourcesLoaded := True;
    LoadResources;
  end;
end;

procedure TEhLibImageResources.ResetResources;
begin
  if FResourcesLoaded = True then
  begin
    FResourcesLoaded := False;
    LoadResources;
  end;
end;

procedure TEhLibImageResources.LoadResources;

  procedure CheckSetResourceByName(var AImageItemField: TResourceImageItemEh;  ABitmapResourceName: String);
  var
    Bmp, Bmp2: TBitmap;
  begin
    Bmp := BitmapResource[ABitmapResourceName];
    if TStyleManagerEh.Current.StyleColorMode = TStyleColorModeEh.Dark
      then Bmp2 := InvertBitmapColors(Bmp)
      else Bmp2 := nil;
    if AImageItemField = nil then
      AImageItemField := TResourceImageItemEh.Create;
    if Bmp2 <> nil then
    begin
      AImageItemField.InitGraphics(Bmp2, nil);
      Bmp2.Free;
    end else
    begin
      AImageItemField.InitGraphics(Bmp, nil);
    end;
  end;

  procedure CheckSetMultiResBitmapByName(var AImageItemField: TFixedMultiResBitmap;  ABitmapResourceName: String);
  var
    Bmp, Bmp2: TBitmap;
    BitmapItem: TCustomBitmapItem;
  begin
    if AImageItemField = nil then
      AImageItemField := TFixedMultiResBitmap.Create(nil);
    Bmp := BitmapResource[ABitmapResourceName];
    BitmapItem := AImageItemField.ItemByScale(1, True, True);
    if BitmapItem = nil then
    begin
      BitmapItem := AImageItemField.Add;
      BitmapItem.Scale := 1;
    end;
    if TStyleManagerEh.Current.StyleColorMode = TStyleColorModeEh.Dark then
    begin
      Bmp2 := InvertBitmapColors(Bmp);
      BitmapItem.Bitmap.Assign(Bmp2);
      Bmp2.Free;
    end else
    begin
      BitmapItem.Bitmap.Assign(Bmp);
    end;
  end;

begin
  CheckSetResourceByName(FGridScrollBarNavFirstImageItem, 'ehlib_fmx_nav_first');
  CheckSetResourceByName(FGridScrollBarNavPriorImageItem, 'ehlib_fmx_nav_previous');
  CheckSetResourceByName(FGridScrollBarNavNextImageItem, 'ehlib_fmx_nav_next');
  CheckSetResourceByName(FGridScrollBarNavLastImageItem, 'ehlib_fmx_nav_last');
  CheckSetResourceByName(FGridScrollBarNavInsertImageItem, 'ehlib_fmx_nav_new_record');
  CheckSetResourceByName(FGridScrollBarNavDeleteImageItem, 'ehlib_fmx_nav_delete_record');
  CheckSetResourceByName(FGridScrollBarNavEditImageItem, 'ehlib_fmx_nav_edit_record');
  CheckSetResourceByName(FGridScrollBarNavPostImageItem, 'ehlib_fmx_nav_post');
  CheckSetResourceByName(FGridScrollBarNavCancelImageItem, 'ehlib_fmx_nav_cancel');
  CheckSetResourceByName(FGridScrollBarNavRefreshImageItem, 'ehlib_fmx_nav_reload');
  CheckSetResourceByName(FSearchPanelCancelSearchImageItem, 'ehlib_fmx_cross');
  CheckSetResourceByName(FSearchPanelFindNextImageItem, 'ehlib_fmx_find_next_down');
  CheckSetResourceByName(FSearchPanelFindPriorImageItem, 'ehlib_fmx_find_prior_up');
  CheckSetResourceByName(FSearchPanelMenuImageItem, 'ehlib_fmx_ellipsis');
  CheckSetResourceByName(FSearchPanelFilterImageItem, 'ehlib_fmx_filter');
  CheckSetResourceByName(FCustomizeColumnsDialogDown, 'cols_dialog_down');
  CheckSetResourceByName(FCustomizeColumnsDialogUp, 'cols_dialog_up');
  CheckSetResourceByName(FCustomizeColumnsDialogLeft, 'cols_dialog_left');
  CheckSetResourceByName(FCustomizeColumnsDialogRight, 'cols_dialog_right');
  CheckSetResourceByName(FCustomizeColumnsDialogSetColWidth, 'cols_dialog_set_col_width');

  CheckSetMultiResBitmapByName(FGridCurrentRowSign, 'ehlib_fmx_grid_current_row');
  CheckSetMultiResBitmapByName(FGridEditRowSign, 'ehlib_fmx_grid_edit_row');
  CheckSetMultiResBitmapByName(FGridNewRowSign, 'ehlib_fmx_grid_new_row');
  CheckSetMultiResBitmapByName(FDropDownSign, 'ehlib_fmx_down_triangle');
  CheckSetMultiResBitmapByName(FDropDownArrowHasFilter, 'ehlib_fmx_has_filter_open');
  CheckSetMultiResBitmapByName(FExpanderSignCollapsed, 'ehlib_fmx_expander_sign_collapsed');
  CheckSetMultiResBitmapByName(FExpanderSignExpanded, 'ehlib_fmx_expander_sign_expanded');
end;

function TEhLibImageResources.GetBitmapStyleResource(ResourceName: String): TBitmap;
begin
  CheckLoadResources;
  if not FStyleResource.TryGetValue(ResourceName, Result) then
  begin
    Result := LoadBitmapStyleResource(ResourceName);
  end;
end;

function TEhLibImageResources.GetGridScrollBarNavFirstImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavFirstImageItem;
end;

function TEhLibImageResources.GetCustomizeColumnsDialogDown: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FCustomizeColumnsDialogDown;
end;

function TEhLibImageResources.GetCustomizeColumnsDialogLeft: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FCustomizeColumnsDialogLeft;
end;

function TEhLibImageResources.GetCustomizeColumnsDialogRight: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FCustomizeColumnsDialogRight;
end;

function TEhLibImageResources.GetCustomizeColumnsDialogSetColWidth: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FCustomizeColumnsDialogSetColWidth;
end;

function TEhLibImageResources.GetCustomizeColumnsDialogUp: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FCustomizeColumnsDialogUp;
end;

function TEhLibImageResources.GetGridScrollBarNavCancelImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavCancelImageItem;
end;

function TEhLibImageResources.GetGridScrollBarNavDeleteImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavDeleteImageItem;
end;

function TEhLibImageResources.GetGridScrollBarNavEditImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavEditImageItem;
end;

function TEhLibImageResources.GetGridScrollBarNavInsertImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavInsertImageItem;
end;

function TEhLibImageResources.GetGridScrollBarNavLastImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavLastImageItem;
end;

function TEhLibImageResources.GetGridScrollBarNavNextImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavNextImageItem;
end;

function TEhLibImageResources.GetGridScrollBarNavPostImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavPostImageItem;
end;

function TEhLibImageResources.GetGridScrollBarNavPriorImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavPriorImageItem;
end;

function TEhLibImageResources.GetGridScrollBarNavRefreshImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FGridScrollBarNavPriorImageItem;
end;

function TEhLibImageResources.GetSearchPanelCancelSearchImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FSearchPanelCancelSearchImageItem;
end;

function TEhLibImageResources.GetSearchPanelFilterImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FSearchPanelFilterImageItem;
end;

function TEhLibImageResources.GetSearchPanelFindNextImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FSearchPanelFindNextImageItem;
end;

function TEhLibImageResources.GetSearchPanelFindPriorImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FSearchPanelFindPriorImageItem;
end;

function TEhLibImageResources.GetSearchPanelMenuImageItem: TResourceImageItemEh;
begin
  CheckLoadResources;
  Result := FSearchPanelMenuImageItem;
end;

function TEhLibImageResources.LoadBitmapStyleResource(ResourceName: String): TBitmap;
var
  Stream: TStream;
  Instance: THandle;
  Bitmap: TBitmap;
begin
  Instance := HInstance;
  Stream := System.Classes.TResourceStream.Create(Instance, ResourceName, RT_RCDATA);
  try
    Bitmap := TBitmap.Create;
    Bitmap.LoadFromStream(Stream);

    Result := Bitmap;
    FStyleResource.Add(ResourceName, Bitmap);

  finally
    Stream.Free;
  end;
end;

initialization
  FEhLibImageResources := TEhLibImageResources.Create;
finalization
  FreeAndNil(FEhLibImageResources);
end.

