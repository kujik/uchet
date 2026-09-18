unit SolutionFrame.AnimatedGifs;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Contnrs, FMX.Objects,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.Api, EhLibRtl.Api,
  FMX.GIFImage,
  EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids, FMX.Controls.Presentation;

type
  TfrAnimatedGifs1 = class(TFrame)
    Panel1: TPanel;
    Button1: TButton;
    DataGridEh1: TDataGridEh;
    DataGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    DataGridStringColumnEh1: TDataGridStringColumnEh;
    procedure Button1Click(Sender: TObject);
    procedure DataGridLayoutColumnEh1CreateDataCellContent(Sender: TObject;
      Params: TDataGridCreateDataCellContentParamsEh);
    procedure DataGridLayoutColumnEh1DataCellInitContent(Sender: TObject;
      Params: TDataGridInitDataCellContentParamsEh);
  private
    procedure LoadDataFromResource;
  public
    FPictureList: TObjectList;
    FPictureTableLink: TListTableLinkEh;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  end;

implementation

{$R *.fmx}

type
{ TAnimationRow }

  TAnimationRow = class(TObject)
  private
    FFileName: String;
    FDescription: String;
    FGIFData: TGIFData;
  public
    destructor Destroy; override;

    property FileName: String read FFileName write FFileName;
    property Description: String read FDescription write FDescription;
    property GIFData: TGIFData read FGIFData;
  end;

destructor TAnimationRow.Destroy;
begin
  FreeAndNil(FGIFData);
  inherited Destroy;
end;


constructor TfrAnimatedGifs1.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Button1Click(nil);
end;

destructor TfrAnimatedGifs1.Destroy;
begin
  FreeAndNil(FPictureList);
  inherited Destroy;
end;

procedure TfrAnimatedGifs1.LoadDataFromResource;

  procedure AddResource(ResName, Description: String);
  var
    Stream: TResourceStream;
    AnimationRow: TAnimationRow;
  begin
    AnimationRow := TAnimationRow.Create;
    Stream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
    AnimationRow.FGIFData := TGIFData.Create;
    AnimationRow.FGIFData.LoadFromStream(Stream);
    AnimationRow.Description := Description;
    FPictureList.Add(AnimationRow);
    Stream.Free;
  end;

begin
  AddResource('RES_GIFS_DANCING_GIRL', 'Dancing girl');
  AddResource('Res_Gifs_Giraffe', 'Giraffe peeking out from behind wall');
  AddResource('Res_Gifs_Hen', 'Hen with chicks');
  AddResource('Res_Gifs_Jumping_frog', 'Jumping frog in cap');
  AddResource('Res_Gifs_Mice_carrying_loaf', 'Mice carrying loaf of bread');
  AddResource('Res_Gifs_Penguin', 'Penguin on ball');
  AddResource('Res_Gifs_Rotating_kart', 'Rotating kart');
  AddResource('Res_Gifs_Running_Dog', 'Running Dog');
  AddResource('Res_Gifs_Snowball_Christmas', 'Snowball and Christmas tree');
  AddResource('Res_Gifs_Snowball_ball', 'Snowball throwing ball');
  AddResource('Res_Gifs_Walking_Man', 'Walking Man');
  AddResource('Res_Gifs_Walking_Smurf', 'Walking Smurf');
  AddResource('Res_Gifs_White_Running_Dog', 'White running dog');
  AddResource('Res_Gifs_�at_scared', '�at got scared');
end;

procedure TfrAnimatedGifs1.Button1Click(Sender: TObject);
begin
  if FPictureList = nil then
  begin
    FPictureList := TObjectList.Create;

    LoadDataFromResource;

    FPictureTableLink := TListTableLinkEh.Create(Self);
    FPictureTableLink.SetList(FPictureList, TypeInfo(TAnimationRow));

    DataGridEh1.DataSource := FPictureTableLink;
  end;
end;

procedure TfrAnimatedGifs1.DataGridLayoutColumnEh1CreateDataCellContent(
  Sender: TObject; Params: TDataGridCreateDataCellContentParamsEh);
begin
  with TLaLayoutPanelEh.CreateWith(Params.ContentParent, Params.ContentParent) do
  begin
    HorzAlignment := TLaHorzAlignmentEh.Center;
    Margins.Rect := TRectF.Create(4, 4, 4, 4);

    with TLaControlsGenericHelper.CreateControlWith<TGIFImage>(RefSelf, RefSelf) do
    begin
      HitTest := False;
      WrapMode := TImageWrapMode.Place;
      Size.DefaultValue := TSizeF.Create(200, 40);
//      Width := 200;
//      Height := 20;
    end;

    Params.CellContent := TLaControlEh(RefSelf);
  end;
end;

procedure TfrAnimatedGifs1.DataGridLayoutColumnEh1DataCellInitContent(
  Sender: TObject; Params: TDataGridInitDataCellContentParamsEh);
var
  GIFImage: TGIFImage;
begin
  if Params.Row = nil then Exit;

  GIFImage := TGIFImage(TLaLayoutPanelEh(Params.CellContent).Children[0]);
  GIFImage.GIFData := TAnimationRow(Params.Row.SourceObjectItem).GIFData;
  Params.CellContent.Width := GIFImage.GIFData.Header.ScreenWidth;
  Params.CellContent.Height := GIFImage.GIFData.Header.ScreenHeight;
//  GIFImage.Width := GIFImage.GIFData.Header.ScreenWidth;
//  GIFImage.Height := GIFImage.GIFData.Header.ScreenHeight;
  GIFImage.Play;
end;

end.
