{
окно с подробностями ошибки при выполнении запроса Oracle
вызывается по кнопке из обработчика ошибок
(доделать вызов из лога)
(доделать копирование запроса в буфер со вставкой параметров как значений в запрос)

информация берется из лога базы по указанному номеру строки, если он < 0, то из последней

содержит инфу:
тест ошибки - из вызвавшего обработчика
текст скл - поледний текст запроса из объекта БД
значения параметров - последние значения параметров при установке их в объекте дб

}


unit D_OraError;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, uData, Jpeg, uString, PngImage, Math;

type
  TDlg_OraError = class(TForm)
    MM_Error: TMemo;
    MM_Sql: TMemo;
    MM_Params: TMemo;
    Bt_Ok: TBitBtn;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Bt_Log: TBitBtn;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Bt_LogClick(Sender: TObject);
  private
    Err: string;
    { Private declarations }
  public
    { Public declarations }
    //покажем окно с ошибкой, запросом и параметрами запроса к БД
    //если заданы строковые значения AError и т.д., то будут показаны они
    //иначе будет показан запрос из лога по переданной строке (при -1 - послений)
    procedure ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
  end;

var
  Dlg_OraError: TDlg_OraError;

implementation

{$R *.dfm}

uses
  uDBOra,
  uDB,
  //F_SQLMonitor,
  uWindows,
  uForms
  ;

procedure TDlg_OraError.Bt_LogClick(Sender: TObject);
begin
  Wh.ExecReference(myfrm_Srv_SqlMonitor)
end;

procedure TDlg_OraError.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

procedure TDlg_OraError.FormShow(Sender: TObject);
begin
  Bt_Ok.SetFocus;
end;

procedure TDlg_OraError.ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
//покажем окно с ошибкой, запросом и параметрами запроса к БД
//если заданы строковые значения AError и т.д., то будут показаны они
//иначе будет показан запрос из лога по переданной строке (при -1 - послений)
begin
  ARow:=Min(S.IIf(ARow < 0, MaxInt, ARow), High(Q.LogArray));
  Caption:= ModuleRecArr[uData.cMainModule].Caption + ' - Ошибка!';
  Module.SetBitmapFromResource(Image1.Picture.Bitmap, PChar('error64'));
  MM_Error.Text:=''; MM_Sql.Text:=''; MM_Params.Text:='';
  if AError+AQuery+AParams <> '' then begin
    MM_Error.Text:= AError;
    MM_Sql.Text:= AQuery;
    MM_Params.Text:= AParams;
  end
  else if ARow >=0 then begin
    MM_Error.Text:=Q.LogArray[ARow][cmydbLogError];
    MM_Sql.Text:=Q.LogArray[ARow][cmydbLogQuery];
    MM_Params.Text:=Q.LogArray[ARow][cmydbLogParams];
  end;
  Cth.SetBtn(Bt_Ok, myBtClose, False);
  Cth.SetBtn(Bt_Log, mybtView, False, 'Лог');
  ShowModal;
end;

end.
