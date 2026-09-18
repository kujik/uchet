unit FrameAbout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  AppUnit, EhLibUtils, OpenViewUrl, FrameDemoBase,
  FMX.Controls.Presentation, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TfrAbout = class(TfrDemoBase)
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Label1: TLabel;
    textBuild: TText;
    textVer: TText;
    Image1: TImage;
    Layout4: TLayout;
    bSysInfo: TButton;
    bCopy: TButton;
    Line1: TLine;
    Memo1: TMemo;
    Layout5: TLayout;
    Line2: TLine;
    Layout6: TLayout;
    lTechSupport: TText;
    Text3: TText;
    Text4: TText;
    lForumRef: TLabel;
    lSupportRef: TLabel;
    Layout7: TLayout;
    Line3: TLine;
    Layout8: TLayout;
    Button2: TButton;
    ScrollBox1: TScrollBox;
    procedure Button2Click(Sender: TObject);
    procedure bSysInfoClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure lForumRefClick(Sender: TObject);
    procedure lSupportRefClick(Sender: TObject);
  private
    { Private declarations }
  public
    Memo1Info: String;
    SysInfoMode: Boolean;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frAbout: TfrAbout;

implementation

{$R *.fmx}

constructor TfrAbout.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  bCopy.Visible := False;
  Memo1Info := Memo1.Text;
  textVer.Text := EhLibVerInfo;
  textBuild.Text := EhLibBuildInfo;
end;

destructor TfrAbout.Destroy;
begin
  inherited Destroy;
end;

procedure TfrAbout.bSysInfoClick(Sender: TObject);
begin
  if (SysInfoMode) then
  begin
    Memo1.Text := Memo1Info;
    bCopy.Visible := False;
    bSysInfo.Text := 'SysInfo';
    SysInfoMode := False;
  end else
  begin
    Memo1.Text := GetEhLibSysInfoAsString;
    bCopy.Visible := True;
    bSysInfo.Text := 'AboutInfo';
    SysInfoMode := True;
  end;
end;

procedure TfrAbout.Button2Click(Sender: TObject);
begin
  BackButtonClicked;
end;

procedure TfrAbout.Label1Click(Sender: TObject);
begin
  OpenURL('http://www.ehlib.com');
end;

procedure TfrAbout.lForumRefClick(Sender: TObject);
begin
  OpenURL('http://forum.ehlib.com');
end;

procedure TfrAbout.lSupportRefClick(Sender: TObject);
begin
  OpenURL('mailto:support@ehlib.com');
end;

end.
