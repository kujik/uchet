unit uFrmTest2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls, uDbOra, ustring;

type
  TFrmTest2 = class(TFrmBasicMdi)
  private
    { Private declarations }
    function  Prepare: Boolean; override;
  public
    { Public declarations }
  end;

var
  FrmTest2: TFrmTest2;

implementation

{$R *.dfm}

function  TFrmTest2.Prepare: Boolean;
begin
  Result := True;
end;


var
  v : variant;
  i: integer;
begin
//  i := q.QSelectOneRow('select 2 from dual', [])[0].tointeger;
end.
