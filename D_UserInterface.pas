unit D_UserInterface;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI;

type
  TDlg_UserInterface = class(TForm_MDI)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Dlg_UserInterface: TDlg_UserInterface;

implementation

{$R *.dfm}

uses
  uData
  ;

end.
