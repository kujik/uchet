{
Диалог "О программе"
}

unit uFrmXWAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, uData, uForms, uString, uMessages,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, V_Normal;

  type
  TFrmXWAbout = class(TForm_Normal)
    pnlMain: TPanel;
    btnOk: TButton;
    imgMain: TImage;
    lblUchet: TLabel;
    lblAuthor: TLabel;
    lblYears: TLabel;
    lblRandom: TLabel;
    lblModule: TLabel;
    lblVersion: TLabel;
    lblDate: TLabel;
    pnlLinks: TPanel;
    lblSql: TLabel;
    lblErrors: TLabel;
    procedure lblAuthorDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgMainClick(Sender: TObject);
    procedure lblSqlClick(Sender: TObject);
    procedure lblErrorsClick(Sender: TObject);
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


procedure TFrmXWAbout.imgMainClick(Sender: TObject);
begin
  inherited;
  pnlLinks.Visible:=True;
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
  if not lblRandom.Visible then Exit;
  if Key in ['0'..'9'] then begin
    Pwd:=Pwd+Key;
  end
  else if (Key = #8)and(Length(Pwd) > 0) then begin
    delete(Pwd, Length(Pwd),1);
  end;
  if pwd=S.IIf(StrToInt(lblRandom.Caption) <5, '0', '9') + '3251158' + IntToStr(StrToInt(lblRandom.Caption) * 3)
    then begin
      MyInfoMessage('!!!');
    end;
end;

procedure TFrmXWAbout.FormShow(Sender: TObject);
begin
  inherited;
  lblRandom.Hide;
  lblModule.Caption:=ModuleRecArr[cMainModule].Caption;
  lblVersion.Caption:='сборка: ' + Module.Version;
  lblDate.Caption:='время сборки: ' + Module.CompileDate;
  lblYears.Caption:='2022-' + Copy(Module.CompileDate, 1, 4);
  pnlLinks.Visible:=False;//User.IsDeveloper;
end;

procedure TFrmXWAbout.lblAuthorDblClick(Sender: TObject);
begin
  Randomize;
  RndVal:=Random(9);
  lblRandom.Caption:=IntToStr(RndVal);
  lblRandom.Show;
end;

procedure TFrmXWAbout.lblErrorsClick(Sender: TObject);
begin
  inherited;
  Wh.ExecReference(myfrm_J_Error_Log);
end;

procedure TFrmXWAbout.lblSqlClick(Sender: TObject);
begin
  inherited;
  Wh.ExecReference(myfrm_Srv_SqlMonitor);
end;

end.
