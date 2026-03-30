unit uFrmXWNonActualVersion;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.Buttons, uData, uMessages, uDBOra;

type
  TFrmXWNonActualVersion = class(TForm)
    imgError: TImage;
    lblText: TLabel;
    lblMessage: TLabel;
    btnOk: TBitBtn;
  private
  public
    class function Execute: Boolean;
  end;

var
  FrmXWNonActualVersion: TFrmXWNonActualVersion;

implementation

uses
  uString, uModule;

{$R *.dfm}

class function TFrmXWNonActualVersion.Execute: Boolean;
begin
  Result := True;
  {$IFDEF SRV}
  Exit;
  {$ENDIF}
  if Module.DevFileExists then
    Exit;
  var va := Q.QLoadRow0('select module_version, check_module_version from adm_modules where id = :id$i', [cMainModule]) + [Module.VersionString];
  if (va[1] <> 1) or (va[2] = va[0].AsString) then
    Exit;
  FrmXWNonActualVersion := TFrmXWNonActualVersion.Create(nil);
  FrmXWNonActualVersion.Caption := ModuleRecArr[cMainModule].Caption;
//  FrmXWNonActualVersion.Caption:=va.Implode(';');
  FrmXWNonActualVersion.ShowModal;
  Result := False;
end;

end.
