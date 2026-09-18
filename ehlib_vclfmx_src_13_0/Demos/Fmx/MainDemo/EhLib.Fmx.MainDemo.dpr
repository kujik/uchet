program EhLib.Fmx.MainDemo;

uses
  System.StartUpCopy,
  SysUtils,
  {$IFDEF MSWINDOWS}
  EhLibFmx.Canvas.D2D,
  {$ELSE}
  {$ENDIF }
  FMX.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  FormAbout in 'FormAbout.pas' {fAbout},
  OpenViewUrl in 'OpenViewUrl.pas',
  DemoFrame.MainGrid in 'DemoFrame.MainGrid.pas' {frMainGrid: TFrame},
  DemoFrame.MasterDetail in 'DemoFrame.MasterDetail.pas' {frMasterDetail: TFrame},
  DemoFrame.FishFacts in 'DemoFrame.FishFacts.pas' {frFishFacts: TFrame},
  MainMobileUnit in 'MainMobileUnit.pas' {MainMobileForm},
  FrameDemoList in 'FrameDemoList.pas' {frDemoList: TFrame},
  FrameTest in 'FrameTest.pas' {frTest: TFrame},
  AppUnit in 'AppUnit.pas',
  FrameDemoBase in 'FrameDemoBase.pas' {frDemoBase: TFrame},
  FrameAbout in 'FrameAbout.pas' {frAbout: TFrame},
  DemoFrame.SearchPanel in 'DemoFrame.SearchPanel.pas' {frSearchPanel: TFrame},
  DemoFrame.LaObjectFishFacts in 'DemoFrame.LaObjectFishFacts.pas' {frLaObjectFishFacts: TFrame},
  DataModuleUnit in 'DataModuleUnit.pas' {DataModule1: TDataModule},
  DemoFrame.CellFormating in 'DemoFrame.CellFormating.pas' {frCellFormating: TFrame},
  DemoFrame.ContactsNCalls in 'DemoFrame.ContactsNCalls.pas' {frContactsNCalls: TFrame},
  DemoFrame.Contacts in 'DemoFrame.Contacts.pas' {frContacts: TFrame},
  DemoFrame.Calls in 'DemoFrame.Calls.pas' {frCalls: TFrame},
  FrameSolutionList in 'FrameSolutionList.pas' {frSolutionList: TFrame},
  SolutionFrame.GridThreeTextBlocksInCell in 'SolutionFrame.GridThreeTextBlocksInCell.pas' {frSolGridThreeTextBlocksInCell: TFrame},
  SolutionFrame.FindInFiles in 'SolutionFrame.FindInFiles.pas' {frSolFindInFiles: TFrame},
  DemoFrame.FileExplorer in 'DemoFrame.FileExplorer.pas' {frFileExplorer: TFrame},
  FoldersTreeList in 'FoldersTreeList.pas',
  SolutionFrame.AnimatedGifs in 'SolutionFrame.AnimatedGifs.pas' {frAnimatedGifs1: TFrame},
  FMX.GIFImage in 'ExtraLibs\GIFImages\FMX.GIFImage.pas',
  CustomCells.ProgressBar in 'CustomCells.ProgressBar.pas',
  SolutionFrame.ProgressBars in 'SolutionFrame.ProgressBars.pas' {frProgressBar: TFrame},
  DemoFrame.VerticalGrid in 'DemoFrame.VerticalGrid.pas' {frVerticalGrid: TFrame},
  SolutionFrame.ComboBoxes in 'SolutionFrame.ComboBoxes.pas' {frComboBoxes: TFrame},
  SolutionFrame.ImageAndTextInCell in 'SolutionFrame.ImageAndTextInCell.pas' {frImageAndTextInCell: TFrame},
  SolutionFrame.ImageAndTextInCell2 in 'SolutionFrame.ImageAndTextInCell2.pas' {frImageAndTextInCell2: TFrame},
  CustomCells.ImageAndTextEdit in 'CustomCells.ImageAndTextEdit.pas',
  SolutionFrame.TreeViewWithMemTableEh in 'SolutionFrame.TreeViewWithMemTableEh.pas' {frTreeViewWithMemTableEh: TFrame},
  SolutionFrame.TreeViewWithTreeListEh in 'SolutionFrame.TreeViewWithTreeListEh.pas' {frTreeViewWithTreeListEh: TFrame},
  SolutionFrame.RowAsWhole in 'SolutionFrame.RowAsWhole.pas' {frSolutionRowAsWhole: TFrame},
  MarkdownCommonMark in 'ExtraLibs\delphi-markdown\MarkdownCommonMark.pas',
  MarkdownDaringFireball in 'ExtraLibs\delphi-markdown\MarkdownDaringFireball.pas',
  MarkdownHTMLEntities in 'ExtraLibs\delphi-markdown\MarkdownHTMLEntities.pas',
  MarkdownProcessor in 'ExtraLibs\delphi-markdown\MarkdownProcessor.pas',
  MarkdownUnicodeUtils in 'ExtraLibs\delphi-markdown\MarkdownUnicodeUtils.pas',
  SolutionFrame.HighlightingLinksFormatTextSections in 'SolutionFrame.HighlightingLinksFormatTextSections.pas' {frHighlightingLinksFormatTextSections: TFrame},
  DemoFrame.DataGrouping in 'DemoFrame.DataGrouping.pas' {frDataGrouping: TFrame};

{$R *.res}
{$R TestDemo-Resources.RES}

begin
{$IFDEF MSWINDOWS}
  UseEhLibDirect2DCanvas();
{$ELSE}
{$ENDIF}

  Application.Initialize;
  CreateMainForm();
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.


