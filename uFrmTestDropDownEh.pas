unit uFrmTestDropDownEh;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  DropDownFormEh, Dialogs, DynVarsEh, ToolCtrlsEh, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Mask, DBCtrlsEh;

type
  TFrmTestDropDownEh = class(TCustomDropDownFormEh)
    DBEditEh1: TDBEditEh;
    BitBtn1: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmTestDropDownEh: TFrmTestDropDownEh;

implementation

{$R *.dfm}

procedure TFrmTestDropDownEh.BitBtn1Click(Sender: TObject);
begin
  DBEditEh1.Text:=DateTimeToStr(Now);
end;

end.