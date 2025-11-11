unit uFrmWDedtEmployeeProperties;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicDbDialog, Vcl.ExtCtrls,
  Vcl.StdCtrls, DBCtrlsEh, Vcl.Mask;

type
  TFrmWDedtEmployeeProperties = class(TFrmBasicDbDialog)
    cmb_type: TDBComboBoxEh;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmWDedtEmployeeProperties: TFrmWDedtEmployeeProperties;

implementation

{$R *.dfm}

end.
