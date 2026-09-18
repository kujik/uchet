unit MainUnit;

interface

{$REGION 'uses'}
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.IOUtils,
  System.Actions, System.ImageList, FMX.ImgList,
  System.Generics.Collections, System.Generics.Defaults,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Menus,
  FMX.ActnList,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Styles,
  EhLibUtils,
  MemTableDataEh,
  Data.DB,
  MemTableEh,
  EhLib.TableLinks,
  EhLibFmx.ToolControls,
  FMX.Layouts, EhLibFmx.Api,
  FrameDemoList, FrameSolutionList, FMX.TabControl, FMX.WebBrowser
  ;
{$ENDREGION 'uses'}

type
  TMainForm = class(TFormEh)
    MainMenu1: TMainMenu;
    miExit: TMenuItem;
    miLanguage: TMenuItem;
    miAbout: TMenuItem;
    ActionList1: TActionList;
    actExit: TAction;
    actAbout: TAction;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Panel1: TPanel;
    ImageList1: TImageList;
    StyleBook1: TStyleBook;
    PopupMenu1: TPopupMenu;
    ltDemoList: TLayout;
    Splitter1: TSplitter;
    TabControl1: TTabControl;
    tiDemos: TTabItem;
    tiSolutions: TTabItem;
    DemoTabControl: TTabControl;
    TabItemDemoView: TTabItem;
    TabItemDemoDescr: TTabItem;
    WebBrowser1: TWebBrowser;
    miStyle: TMenuItem;
    txStyleName: TText;
    procedure actExitExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure TabControl1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure WebBrowser1ShouldStartLoadWithRequest(ASender: TObject; const URL: string);
  private
    procedure ResourceLanguageChanged;
    procedure BuildLanguageMenu;
    procedure BuildStylesMenu;
    procedure InitDemoListFrame;
    procedure CurrentDemoFrameChanged(Sender: TObject);
    procedure InitSolutionListFrame;
    procedure StyleButton(AButton: TSpeedButton);
    procedure PopulateStylesMenu(miStyles: TMenuItem; const StyleFiles: TStringList);
    procedure StyleMenuClick(Sender: TObject);
    procedure ApplyCustomStyle(AStyleName, AFileName: String);
    procedure StyleColorModeChanged(Sender: TObject);

  protected
    procedure DoStyleChanged; override;

  public
    Frame: TFrame;
    frMainGrid: TFrame;
    DemoListFrame: TfrDemoList;
    SolutionListFrame: TfrSolutionList;
    CurrentStyleName: String;
    CurrentStyleFileName: String;

    procedure DataSource1DataChange(Sender: TObject; Field: TField);
  end;

var
  MainForm: TMainForm;

implementation

uses EhLibFmx.ObjectInspectors,
     EhLibFmx.FormElementsViewer,
     OpenViewUrl,
     FormAbout;

{$R *.fmx}

type
  TControlClass = class of TControl;

function GetStyleFilesInSubfolder: TStringList;
var
  AppPath, StylesPath: string;
  Files: TArray<string>;
  FileName: string;
begin
  Result := TStringList.Create;
  AppPath := ExtractFilePath(ParamStr(0));
//  StylesPath := System.IOUtils.TPath.Combine(AppPath, 'Styles');
  if TDirectory.Exists(System.IOUtils.TPath.Combine(AppPath, 'Styles')) then
    StylesPath := System.IOUtils.TPath.Combine(AppPath, 'Styles')
  else if TDirectory.Exists(System.IOUtils.TPath.Combine(AppPath, '..\Styles')) then
    StylesPath := System.IOUtils.TPath.Combine(AppPath, '\..\Styles')
  else if TDirectory.Exists(System.IOUtils.TPath.Combine(AppPath, '..\..\Styles')) then
    StylesPath := System.IOUtils.TPath.Combine(AppPath, '..\..\Styles')
  else
    Exit;

  Files := TDirectory.GetFiles(StylesPath, '*.style');
  for FileName in Files do
    Result.Add(FileName);
  Files := TDirectory.GetFiles(StylesPath, '*.fsf');
  for FileName in Files do
    Result.Add(FileName);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin

  Caption := 'EhLib.Fmx Main Complex Demo. ' +
    EhLibVerInfo + ' ' + EhLibBuildInfo;

  BuildLanguageMenu;
  BuildStylesMenu;
  InitDemoListFrame;
  InitSolutionListFrame;

  StyleButton(SpeedButton1);
  StyleButton(SpeedButton2);
  txStyleName.Text := '';
  TStyleManagerEh.Current.OnStyleColorModeChange := StyleColorModeChanged;
end;

procedure TMainForm.DoStyleChanged;
begin
  inherited DoStyleChanged;
end;

procedure TMainForm.StyleColorModeChanged(Sender: TObject);
begin
  StyleButton(SpeedButton1);
  StyleButton(SpeedButton2);
  if TStyleManagerEh.Current.StyleColorMode = TStyleColorModeEh.Dark
    then txStyleName.TextSettings.FontColor := TAlphaColorRec.White
    else txStyleName.TextSettings.FontColor := TAlphaColorRec.Black;
end;

procedure TMainForm.ApplyCustomStyle(AStyleName, AFileName: String);
var
  FileName: String;
begin
  CurrentStyleName := AStyleName;
  CurrentStyleFileName := AFileName;

  if AFileName = 'Default' then
  begin
    TStyleManager.SetStyle(nil);
    txStyleName.Text := '';
    Exit;
  end;

  if FileExists(AFileName) then
  begin
    TStyleManager.SetStyleFromFile(AFileName);
    txStyleName.Text := 'Style: ' + CurrentStyleName;
  end else
  begin
    ShowMessage(FileName + ' not found!');
  end;

end;

procedure TMainForm.PopulateStylesMenu(miStyles: TMenuItem; const StyleFiles: TStringList);
var
  i: Integer;
  FullPath, BaseName: string;
  MI: TMenuItem;
//  MenuItemCheck: TMenuItem;
begin
  miStyles.Clear;

//  MenuItemCheck := TMenuItem.Create(Self);
//  MenuItemCheck.Text := 'Dynamic Composed Styles';
//  MenuItemCheck.TagString := 'Composing';
//  MenuItemCheck.IsChecked := False;
//  MenuItemCheck.AutoCheck := True;
//  MenuItemCheck.OnClick := StyleMenuClick;
//  miStyles.AddObject(MenuItemCheck);

//  with TMenuItem.Create(Self) do
//  begin
//    Text := '-';
//    Enabled := False;
//    Parent := miStyles;
//  end;

  if (StyleFiles = nil) or (StyleFiles.Count = 0) then
    Exit;

  for i := 0 to StyleFiles.Count - 1 do
  begin
    FullPath := StyleFiles[i];
    if not TFile.Exists(FullPath) then
      Continue;

    if ExtractFilePath(FullPath) = '' then
      Continue;

    BaseName := System.IOUtils.TPath.GetFileNameWithoutExtension(ExtractFileName(FullPath));

    MI := TMenuItem.Create(miStyles);
    MI.Text      := BaseName;
    MI.TagString := FullPath;
    MI.OnClick   := StyleMenuClick;

    miStyles.AddObject(MI);
  end;

  MI := TMenuItem.Create(miStyles);
  MI.Text      := 'Default';
  MI.TagString := 'Default';
  MI.OnClick   := StyleMenuClick;
  miStyles.AddObject(MI);
end;

procedure TMainForm.StyleMenuClick(Sender: TObject);
var
  Mi: TMenuItem;
begin
  Mi := Sender as TMenuItem;
  if Mi.TagString = 'Composing' then
  begin
    if Mi.IsChecked = True
      then TStyleManagerEh.Current.StyleOrigin := TStyleOriginEh.Composed
      else TStyleManagerEh.Current.StyleOrigin := TStyleOriginEh.BuiltIn;
    ApplyCustomStyle(CurrentStyleName, CurrentStyleFileName);
  end else
  begin
    if Mi.TagString = 'Default' then
    begin
      TStyleManagerEh.Current.StyleOrigin := TStyleOriginEh.BuiltIn;
      ApplyCustomStyle(Mi.Text, Mi.TagString);
    end else
    begin
      TStyleManagerEh.Current.StyleOrigin := TStyleOriginEh.Composed;
      ApplyCustomStyle(Mi.Text, Mi.TagString);
    end;
  end;
end;

procedure TMainForm.StyleButton(AButton: TSpeedButton);
var
  TxtObj: TFmxObject;
begin
  AButton.ApplyStyleLookup();
  TxtObj := AButton.FindStyleResource('text');
  if Assigned(TxtObj) and (TxtObj is TText) then
    TText(TxtObj).Visible := False;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkF10 then
    ShowObjectInspectorForm(ActiveControl, Rect(100, 100, 500, 1000), False)
  else if Key = vkF11 then
    ShowLaObjectTreeViewForm(Self, Rect(100, 100, 500, 1000), False);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  CurrentDemoFrameChanged(nil);
end;

procedure TMainForm.actAboutExecute(Sender: TObject);
begin
  ShowAboutForm;
end;

procedure TMainForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.BuildLanguageMenu;
begin
  ResourceLanguageChanged;
end;

procedure TMainForm.BuildStylesMenu;
var
  StylesList: TStringList;
begin
  CurrentStyleName := 'Default';
  StylesList := GetStyleFilesInSubfolder();
  PopulateStylesMenu(miStyle, StylesList);
  StylesList.Free;
end;

procedure TMainForm.DataSource1DataChange(Sender: TObject; Field: TField);
begin
end;

procedure TMainForm.Label1Click(Sender: TObject);
begin
//
end;

procedure TMainForm.InitDemoListFrame;
begin
  DemoListFrame := TfrDemoList.Create(Self);
  DemoListFrame.OnCurrentDemoFrameChanged := CurrentDemoFrameChanged;
//  ltDemoList.AddObject(DemoListFrame);
  tiDemos.AddObject(DemoListFrame);
//  CurrentDemoFrameChanged(nil);
end;

procedure TMainForm.InitSolutionListFrame;
begin
  SolutionListFrame := TfrSolutionList.Create(Self);
  SolutionListFrame.OnCurrentDemoFrameChanged := CurrentDemoFrameChanged;
//  ltDemoList.AddObject(DemoListFrame);
  tiSolutions.AddObject(SolutionListFrame);
//  CurrentDemoFrameChanged(nil);
end;


procedure TMainForm.CurrentDemoFrameChanged(Sender: TObject);
var
  OldFrame :TFrame;
begin
  OldFrame := Frame;
  if TabControl1.ActiveTab = tiDemos then
  begin
    Frame := DemoListFrame.CurrentFrame;
    WebBrowser1.LoadFromStrings(DemoListFrame.GetFrameDescriptionAsHtml(), TEncoding.Unicode, '');
  end else
  begin
    Frame := SolutionListFrame.CurrentFrame;
    WebBrowser1.LoadFromStrings(SolutionListFrame.GetFrameDescriptionAsHtml(), TEncoding.Unicode, '');
  end;

//  Frame.Parent := Panel1;
  Frame.Parent := TabItemDemoView;
  Frame.Align := TAlignLayout.Client;
  if OldFrame <> nil then
    OldFrame.Parent := nil;
end;

procedure TMainForm.ResourceLanguageChanged;
begin
end;

procedure TMainForm.SpeedButton4Click(Sender: TObject);
begin
  Width := Width - 1;
end;

procedure TMainForm.TabControl1Change(Sender: TObject);
begin
//TabControl1.ActiveTab;
  CurrentDemoFrameChanged(nil);
end;

procedure TMainForm.WebBrowser1ShouldStartLoadWithRequest(ASender: TObject; const URL: string);
begin
  if URL.StartsWith('http') then
  begin
    OpenURL(URL);
    Abort;
  end;
end;

initialization
//  System.ReportMemoryLeaksOnShutdown := True;
//  SetEhLibDebugDraw(True);
end.

