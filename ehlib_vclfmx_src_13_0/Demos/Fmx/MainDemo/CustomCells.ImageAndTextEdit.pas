unit CustomCells.ImageAndTextEdit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  EhLibFmx.Api, EhLibRtl.Api,
  FMX.TextLayout,
  DataModuleUnit,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics;

type

{ TDataAxisImageTextCellManagerEh }

  TDataAxisImageTextCellManagerEh = class(TDataAxisTextCellManagerEh)
  protected
    function CreateGridCell(ACellArea: TGridBaseCellAreaEh): TGridBaseCellEh; override;
  end;

{ TDataAxisImageTextCellEh }

  TDataAxisImageTextCellEh = class(TDataAxisTextCellEh)
  private
    FInCellImage: TLaImageEh;
  protected
    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;
  public
    property InCellImage: TLaImageEh read FInCellImage;
  end;


implementation

function TDataAxisImageTextCellManagerEh.CreateGridCell(ACellArea: TGridBaseCellAreaEh): TGridBaseCellEh;
begin
  Result := TDataAxisImageTextCellEh.Create(ACellArea);
end;

{ TDataAxisImageTextCellEh }

function TDataAxisImageTextCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
var
  BaseContent: TLaObjectEh;
begin
  with TLaGridPanelEh.CreateWith(AParentObject) do
  begin
    Result := RefSelf;
    Name := 'ImageTextContent';

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
      Value := -1;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    //Col1 Image
    with TLaImageEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 0, -1);
      Name := 'InCellImage';
      FInCellImage := RefSelf as TLaImageEh;
      Width := 24;
      Height := 24;
      VertAlignment := TLaVertAlignmentEh.Center;
      Margins.Rect := TRectF.Create(10, 0, 0, 0);
    end;

    //Col2 Text
    BaseContent := inherited CreateDefaultCellContentControls(RefSelf);
    ControlCollection.AddControl(BaseContent, 1, -1);
  end;

end;

end.
