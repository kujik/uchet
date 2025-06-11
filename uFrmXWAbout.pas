{
Диалог "О программе"
}

unit uFrmXWAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, V_Normal;

  type
  TFrmXWAbout = class(TForm_Normal)
    PMain: TPanel;
    BtOk: TButton;
    ImgMain: TImage;
    LbUchet: TLabel;
    LbAuthor: TLabel;
    LbYears: TLabel;
    LbRandom: TLabel;
    LbModule: TLabel;
    LbVersion: TLabel;
    LbDate: TLabel;
    PLinks: TPanel;
    LbSql: TLabel;
    LbErrors: TLabel;
    procedure LbAuthorDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImgMainClick(Sender: TObject);
    procedure LbSqlClick(Sender: TObject);
    procedure LbErrorsClick(Sender: TObject);
  private
    { Private declarations }
    RndVal: Integer;
    Pwd: string;
    IsMdiChild: Boolean;
  public
    { Public declarations }
    DoYourCheckForMDI: Boolean;
    constructor Create(AOwner: TComponent; AIsMdiChild: Boolean = False); reintroduce;
  protected
    procedure InitializeNewForm; override;
  end;

var
  FrmXWAbout: TFrmXWAbout;

implementation

uses
  uWindows;
{$R *.dfm}

constructor TFrmXWAbout.Create(AOwner: TComponent; AIsMdiChild: Boolean = False);
begin
  IsMdiChild:=AIsMdiChild;
  inherited Create(AOwner);
end;


procedure TFrmXWAbout.ImgMainClick(Sender: TObject);
begin
  inherited;
  PLinks.Visible:=True;
end;

procedure TFrmXWAbout.InitializeNewForm;
var
  FS: ^TFormStyle;
begin
  inherited;
  if IsMdiChild then
    begin
      FS := @FormStyle;
      FS^ := fsMDIChild;
    end;
end;

procedure TFrmXWAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if FormStyle = fsMDIChild
    then Action := caFree;
end;

procedure TFrmXWAbout.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if pwd = '-' then begin
  end;
  if not LbRandom.Visible then Exit;
  if Key in ['0'..'9'] then begin
    Pwd:=Pwd+Key;
  end
  else if (Key = #8)and(Length(Pwd) > 0) then begin
    delete(Pwd, Length(Pwd),1);
  end;
  if pwd=S.IIf(StrToInt(LbRandom.Caption) <5, '0', '9') + '3251158' + IntToStr(StrToInt(LbRandom.Caption) * 3)
    then begin
      MyInfoMessage('!!!');
    end;
end;

procedure TFrmXWAbout.FormShow(Sender: TObject);
begin
  inherited;
  LbRandom.Hide;
  LbModule.Caption:=ModuleRecArr[cMainModule].Caption;
  LbVersion.Caption:='сборка: ' + Module.Version;
  LbDate.Caption:='время сборки: ' + Module.CompileDate;
  LbYears.Caption:='2022-' + Copy(Module.CompileDate, 1, 4);
  PLinks.Visible:=False;//User.IsDeveloper;
end;

procedure TFrmXWAbout.LbAuthorDblClick(Sender: TObject);
begin
  Randomize;
  RndVal:=Random(9);
  LbRandom.Caption:=IntToStr(RndVal);
  LbRandom.Show;
end;

procedure TFrmXWAbout.LbErrorsClick(Sender: TObject);
begin
  inherited;
  Wh.ExecReference(myfrm_J_Error_Log);
end;

procedure TFrmXWAbout.LbSqlClick(Sender: TObject);
begin
  inherited;
  Wh.ExecReference(myfrm_Srv_SqlMonitor);
end;

end.
