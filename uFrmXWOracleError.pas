{
Диалог подробностей ошибки при работе с базой данных.
отображает сообщение об ошибке, текст запроса и значения параметров.
TODO:
сделать копирование в буфер запроса с подставленными в него параметрами.
}
unit uFrmXWOracleError;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi,
  Vcl.Imaging.pngimage, Vcl.Mask
  ;

type
  TFrmXWOracleError = class(TFrmBasicMdi)
    pnlCenter: TPanel;
    pnlLeft: TPanel;
    MError: TDBMemoEh;
    MSql: TDBMemoEh;
    MParams: TDBMemoEh;
    Image1: TImage;
    procedure FormActivate(Sender: TObject);
  private
    procedure btnClick(Sender: TObject); override;
  public
    //покажем окно с ошибкой, запросом и параметрами запроса к БД
    //если заданы строковые значения AError и т.д., то будут показаны они
    //иначе будет показан запрос из лога по переданной строке (при -1 - послений)
    procedure ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
  end;

var
  FrmXWOracleError: TFrmXWOracleError;

implementation

uses
  uDB,
  uWindows
  ;


{$R *.dfm}

procedure TFrmXWOracleError.btnClick(Sender: TObject);
begin
  Wh.ExecReference(myfrm_Srv_SqlMonitor);
end;


procedure TFrmXWOracleError.FormActivate(Sender: TObject);
begin
  inherited;
  Top := 200;
end;

procedure TFrmXWOracleError.ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
//покажем окно с ошибкой, запросом и параметрами запроса к БД
//если заданы строковые значения AError и т.д., то будут показаны они
//иначе будет показан запрос из лога по переданной строке (при -1 - послений)
begin
  PrepareCreatedForm(Application, myfrm_Dlg_OracleError, '~Ошибка при работе с БД', fView, null, [myfoModal, myfoDialog, myfoDialogButtonsB, myfoSizeable], False);
  FOpt.DlgButtonsR := [[1000, True, True, 120, 'Журнал запросов', 'view']];
  ARow := Min(S.IIf(ARow < 0, MaxInt, ARow), High(Q.LogArray));
  Caption := ModuleRecArr[uData.cMainModule].Caption + ' - Ошибка!';
  Module.SetBitmapFromResource(Image1.Picture.Bitmap, PChar('error64'));
  MError.Text := '';
  MSql.Text := '';
  MParams.Text := '';
  if AError + AQuery + AParams <> '' then begin
    MError.Text := AError;
    MSql.Text := AQuery;
    MParams.Text := AParams;
  end
  else if ARow >= 0 then begin
    MError.Text := Q.LogArray[ARow][cmydbLogError];
    MSql.Text := Q.LogArray[ARow][cmydbLogQuery];
    MParams.Text := Q.LogArray[ARow][cmydbLogParams];
  end;
  Self.ShowModal;
end;

end.
