unit FormAbout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo,
  EhLibUtils
  ;

type
  TfAbout = class(TForm)
    Rectangle1: TRectangle;
    textVer: TText;
    Image1: TImage;
    Line1: TLine;
    Line2: TLine;
    Line3: TLine;
    Memo1: TMemo;
    Label1: TLabel;
    textBuild: TText;
    bSysInfo: TButton;
    bCopy: TButton;
    lForumRef: TLabel;
    lSupportRef: TLabel;
    lTechSupport: TText;
    Text3: TText;
    Text4: TText;
    btnClose: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure bSysInfoClick(Sender: TObject);
    procedure bCopyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lForumRefClick(Sender: TObject);
    procedure lSupportRefClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Memo1Info: String;
    SysInfoMode: Boolean;
  end;

var
  fAbout: TfAbout;

procedure ShowAboutForm;

implementation

uses OpenViewUrl;

{$R *.fmx}

procedure ShowAboutForm;
begin
  fAbout := TfAbout.Create(Application);
  try
    fAbout.ShowModal;
  finally
    FreeAndNil(fAbout);
  end
end;

procedure TfAbout.bCopyClick(Sender: TObject);
begin
//
end;

procedure TfAbout.bSysInfoClick(Sender: TObject);
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

procedure TfAbout.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfAbout.FormCreate(Sender: TObject);
begin
  bCopy.Visible := False;
  Memo1Info := Memo1.Text;
  textVer.Text := EhLibVerInfo;
  textBuild.Text := EhLibBuildInfo;
end;

procedure TfAbout.Label1Click(Sender: TObject);
begin
  //ShellExecute(Application.Handle, 'Open', 'http://www.ehlib.com', nil, nil, SW_SHOWNORMAL);
  OpenURL('http://www.ehlib.com');
end;

procedure TfAbout.lForumRefClick(Sender: TObject);
begin
  OpenURL('http://forum.ehlib.com');
end;

procedure TfAbout.lSupportRefClick(Sender: TObject);
begin
  OpenURL('mailto:support@ehlib.com');
end;

end.
