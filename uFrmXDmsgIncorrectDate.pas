{
Проверим, не различаются ли дата/время на сервере оракла и на компьютере
Если различие более двух часов, либо же дата не совпадает, то выйдем из программы с сообщением.
}

unit uFrmXDmsgIncorrectDate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TFrmXDmsgIncorrectDate = class(TForm)
    LbCaption: TLabel;
    ImgError: TImage;
    LbMsg: TLabel;
    BtClose: TBitBtn;
  private
  public
    class function Execute: Boolean;
  end;

var
  FrmXDmsgIncorrectDate: TFrmXDmsgIncorrectDate;

implementation

{$R *.dfm}
uses
  uDBOra,
  DateUtils,
  uData
  ;

class function TFrmXDmsgIncorrectDate.Execute: Boolean;
var
  dt: TDateTime;
begin
  Result:=True;
  dt:=Q.QSelectOneRow('select sysdate from dual', [])[0];
  if (abs(HoursBetween(dt , Now)) < 2)and(DayOf(Date) = DayOf(dt)) then Exit;
  Result:=False;
  {$IFDEF SRV}
  Exit;
  {$ENDIF}
  FrmXDmsgIncorrectDate:=TFrmXDmsgIncorrectDate.Create(nil);
  FrmXDmsgIncorrectDate.Caption:=ModuleRecArr[cMainModule].Caption;
  FrmXDmsgIncorrectDate.ShowModal;
end;

end.
