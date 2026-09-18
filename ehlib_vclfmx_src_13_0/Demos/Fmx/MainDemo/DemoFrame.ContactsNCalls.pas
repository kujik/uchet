unit DemoFrame.ContactsNCalls;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrameDemoBase,
  FMX.TabControl, FMX.Controls.Presentation, FMX.Objects;

type
  TfrContactsNCalls = class(TfrDemoBase)
    TabControl1: TTabControl;
    tiContacts: TTabItem;
    tiCalls: TTabItem;
    Panel1: TPanel;
    Text1: TText;
    Button1: TButton;
    SpeedButtonBack: TSpeedButton;
    procedure SpeedButtonBackClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

uses EhLibFmx.Types,
     DemoFrame.Contacts,
     DemoFrame.Calls;

{ TfrContactsNCalls }

constructor TfrContactsNCalls.Create(AOwner: TComponent);
var
  FrameContacts: TFrame;
  FrameCalls: TFrame;
begin
  inherited Create(AOwner);
  SpeedButtonBack.Visible := TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen;

  FrameContacts := TfrContacts.Create(Self);
  FrameContacts.Align := TAlignLayout.Client;
  tiContacts.AddObject(FrameContacts);

  FrameCalls := TfrCalls.Create(Self);
  FrameCalls.Align := TAlignLayout.Client;
  tiCalls.AddObject(FrameCalls);
end;

procedure TfrContactsNCalls.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked;
end;

end.
