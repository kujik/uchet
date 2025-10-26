unit uFrMyPanelCaption;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  uString
  ;

type
  TFrMyPanelCaption = class(TFrame)
    bvl1: TBevel;
    pnlCaption: TPanel;
    lblCaption: TLabel;
    pnlInfo: TPanel;
    imgInfo: TImage;
    pnlError: TPanel;
    imgError: TImage;
    procedure imgErrorClick(Sender: TObject);
  private
  public
    procedure SetParameters(AVisible: Boolean; ACaption: Variant; AInfo: TVarDynArray2; AError: Variant);
    procedure SetError(AHasError: Boolean; AErrorMessage: string);
  end;

implementation

uses
  uForms,
  uMessages
  ;

{$R *.dfm}

procedure TFrMyPanelCaption.SetParameters(AVisible: Boolean; ACaption: Variant; AInfo: TVarDynArray2; AError: Variant);
//создаем информационную иконку в верхней панели кнопок, если таковая есть
begin
  lblCaption.Caption := ' ' + ACaption + ' ';
  pnlCaption.AutoSize := False;
  pnlCaption.Refresh;
  pnlCaption.AutoSize := True;
  pnlCaption.Width := lblCaption.Width;
  pnlInfo.Visible := Length(AInfo) > 0;
  pnlInfo.Left := pnlCaption.Left + pnlCaption.Width + 8;
  Cth.SetInfoIcon(TImage(imgInfo), Cth.SetInfoIconText(TForm(Self), AInfo), 18);
  pnlError.Visible := AError = True;
  pnlError.Left := pnlInfo.Left + S.IIf(pnlInfo.Visible, pnlInfo.Width + 8, 0);
end;

procedure TFrMyPanelCaption.SetError(AHasError: Boolean; AErrorMessage: string);
begin
  pnlError.Visible := AHasError;
  pnlError.Hint := S.IIf(AErrorMessage = '', 'Ошибка в данных!',AErrorMessage);
end;

procedure TFrMyPanelCaption.imgErrorClick(Sender: TObject);
begin
  MyWarningMessage(pnlError.Hint, 1);
end;

end.
