unit MainMobileUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls,
  FrameDemoList, AppUnit, EhLibUtils,
  System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList, FMX.TabControl;

type
  TMainMobileForm = class(TForm)
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    actExit: TAction;
    actAbout: TAction;
    ImageList1: TImageList;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SlideTabControl1: TTabControl;
    SlideTabItem1: TTabItem;
    SlideTabItem2: TTabItem;
    MainFrStTabControl: TTabControl;
    MainTabItem1: TTabItem;
    StyleBook1: TStyleBook;
    procedure actExitExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToolBar1DblClick(Sender: TObject);
    procedure ToolBar1Click(Sender: TObject);
  private
    CurrentDemoFrame: TFrame;
    DemoListFrame: TfrDemoList;
    MainFrameStack: TFrameStackEh;

    procedure GridItemClicked(Sender: TObject);
    procedure DemoFrameBackClicked(Sender: TObject);
    procedure ApplyToolButtonStyle(ASpeedButton: TSpeedButton);

  public
    procedure ShowAboutForm;
  end;

var
  MainMobileForm: TMainMobileForm;

implementation

uses FrameDemoBase, FrameAbout;

{$R *.fmx}

type
  TTabItemCrack = class(TTabItem);
  TPresentedTextControlCrack = class(TPresentedTextControl);

procedure TMainMobileForm.actAboutExecute(Sender: TObject);
begin
//  ShowAboutForm;
//  SlideTo()
  if frAbout = nil then
  begin
    frAbout := TfrAbout.Create(Application);
    frAbout.Align := TAlignLayout.Client;
  end;
  MainFrameStack.ShowFrameTop(frAbout);
end;

procedure TMainMobileForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainMobileForm.FormCreate(Sender: TObject);
begin
  Caption := 'EhLib.Fmx Main Complex Demo. ' + EhLibVerInfo + ' ' + EhLibBuildInfo;
  DemoListFrame := TfrDemoList.Create(Self);
  TTabItemCrack(SlideTabItem1).Content.AddObject(DemoListFrame);
//  DemoListFrame.OnCurrentDemoFrameChanged := CurrentDemoFrameChanged;
  DemoListFrame.OnGridItemClicked := GridItemClicked;
  MainFrameStack := TFrameStackEh.Create(MainFrStTabControl);

  ApplyToolButtonStyle(SpeedButton1);
  ApplyToolButtonStyle(SpeedButton2);
end;

procedure TMainMobileForm.ApplyToolButtonStyle(ASpeedButton: TSpeedButton);
var
  AGlyph: TGlyph;
begin
  TPresentedTextControlCrack(ASpeedButton).ApplyStyleLookup;
  TPresentedTextControlCrack(ASpeedButton).TextObject.Visible := False;

  ASpeedButton.FindStyleResource<TGlyph>('glyphstyle', AGlyph);
  if AGlyph <> nil then
    AGlyph.Align := TAlignLayout.Center;
end;

procedure TMainMobileForm.GridItemClicked(Sender: TObject);
var
  OldFrame :TFrame;
begin
//  Exit;

  OldFrame := CurrentDemoFrame;
  if CurrentDemoFrame <> DemoListFrame.CurrentFrame then
  begin
    if OldFrame <> nil then
      OldFrame.Parent := nil;
    CurrentDemoFrame := DemoListFrame.CurrentFrame;
    CurrentDemoFrame.Parent := TTabItemCrack(SlideTabItem2).Content;
    CurrentDemoFrame.Align := TAlignLayout.Client;
    if CurrentDemoFrame is TfrDemoBase then
      TfrDemoBase(CurrentDemoFrame).OnBackButtonClicked := DemoFrameBackClicked;
  end;

  SlideTabControl1.GotoVisibleTab(1, TTabTransition.Slide, TTabTransitionDirection.Normal);
//  TabControl1.GotoVisibleTab(1, TTabTransition.None, TTabTransitionDirection.Normal);
end;

procedure TMainMobileForm.DemoFrameBackClicked(Sender: TObject);
begin
  SlideTabControl1.GotoVisibleTab(0, TTabTransition.Slide, TTabTransitionDirection.Normal);
end;

procedure TMainMobileForm.ShowAboutForm;
begin
  ShowMessage('ShowAboutForm');
end;

procedure TMainMobileForm.ToolBar1Click(Sender: TObject);
begin
//
end;

procedure TMainMobileForm.ToolBar1DblClick(Sender: TObject);
begin
//
end;

end.

