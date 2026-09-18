unit AppUnit;

interface

uses SysUtils, System.Classes, System.StartUpCopy,
     FMX.Forms, FMX.TabControl,
     EhLibFmx.Api,
     FrameDemoBase
     ;

//var
//  MobileMode: Boolean;

type
//  TBaseInTabFrame = class;

  { TFrameStackEh }

  TFrameStackEh = class(TComponent)
  private
    FTabControl: TTabControl;
  public
    constructor Create(AOwner: TTabControl); reintroduce;
    destructor Destroy; override;

    procedure ShowFrameTop(AFrame: TfrDemoBase);
    procedure CloseFrameBack();
    procedure CloseFrameClicked(Sender: TObject);

  end;

//{ TBaseInTabFrame }
//
//  TBaseInTabFrame = class(TFrame)
//  private
//    FOnCloseFrameClick: TNotifyEvent;
//  public
//    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;
//
//    procedure CloseFrameClicked;
//
//    property OnCloseFrameClick: TNotifyEvent read FOnCloseFrameClick write FOnCloseFrameClick;
//  end;

procedure CreateMainForm();

//    <meta charset="UTF-16">

const
  MarkDownHtmlHead: String = '''
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Markdown to HTML</title>
    <style>

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background-color: #fff;
            color: #1e1e1e;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }

        h1 {
            font-size: 2em;
            color: #1e1e1e;
            border-bottom: 1px solid #eee;
            padding-bottom: 0.3em;
        }

        h2 {
            font-size: 1.5em;
            color: #1e1e1e;
            padding-top: 1em;
        }

        p {
/*          font-size: 16px; */
            color: #383a42;
        }

        pre {
            background-color: #f6f8fa;
            color: #24292e;
            padding: 8px;
            border-radius: 6px;
            overflow-x: auto;
            font-family: 'Consolas', 'Courier New', monospace;
            border: 1px solid #ddd;
        }

        pre code {
            background-color: transparent;
            padding: 0;
            border-radius: 0;
            color: inherit;
            font-family: inherit;
        }

        code {
            background-color: #f6f8fa;
            padding: 0.2em 0.4em;
            border-radius: 4px;
            color: #d73a49;
        }

    </style>
</head>
''';

implementation

uses MainUnit, MainMobileUnit;

procedure CreateMainForm();
begin
  if TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen then
    Application.CreateForm(TMainMobileForm, MainMobileForm)
  else
    Application.CreateForm(TMainForm, MainForm);
end;

procedure ResetMobileMode();
begin
  if CompareText(ParamStr(1), 'MobileMode') = 0 then
  begin
    TEhLibFmxSettings.Default.PlatformWindowSizeType := TPlatformWindowSizeTypeEh.FullScreen;
    TEhLibFmxSettings.Default.TouchTracking := True;
  end else
  begin
  end;
end;

type
  TTabItemCrack = class(TTabItem);

{ TFrameStackEh }

constructor TFrameStackEh.Create(AOwner: TTabControl);
begin
  inherited Create(AOwner);
  FTabControl := AOwner;
end;

destructor TFrameStackEh.Destroy;
begin
  inherited Destroy;
end;

procedure TFrameStackEh.ShowFrameTop(AFrame: TfrDemoBase);
var
  TabItem: TTabItem;
begin
  if (FTabControl.TabIndex = FTabControl.TabCount - 1) then
    TabItem := FTabControl.Add(TTabItem)
  else
    TabItem := FTabControl.Tabs[FTabControl.TabIndex + 1];
  TTabItemCrack(TabItem).Content.AddObject(AFrame);
  AFrame.OnBackButtonClicked := CloseFrameClicked;

  FTabControl.GotoVisibleTab(FTabControl.TabIndex + 1, TTabTransition.Slide, TTabTransitionDirection.Normal);
end;

procedure TFrameStackEh.CloseFrameBack;
begin
  FTabControl.GotoVisibleTab(FTabControl.TabIndex - 1, TTabTransition.Slide, TTabTransitionDirection.Normal);
end;

procedure TFrameStackEh.CloseFrameClicked(Sender: TObject);
begin
  CloseFrameBack;
end;

//{ TBaseInTabFrame }
//
//constructor TBaseInTabFrame.Create(AOwner: TComponent);
//begin
//  inherited Create(AOwner);
//end;
//
//destructor TBaseInTabFrame.Destroy;
//begin
//  inherited Destroy;
//end;
//
//procedure TBaseInTabFrame.CloseFrameClicked;
//begin
//  if (Assigned(OnCloseFrameClick)) then
//    OnCloseFrameClick(Self);
//end;

initialization
  ResetMobileMode();
finalization
end.
