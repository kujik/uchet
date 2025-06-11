unit uFrmODedtOrStdItems;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicDbDialog, Vcl.ExtCtrls,
  Vcl.StdCtrls, DBCtrlsEh, Vcl.Mask;

type
  TFrmODedtOrStdItems = class(TFrmBasicDbDialog)
    E_Name: TDBEditEh;
    Chb_R0: TDBCheckBoxEh;
    Chb_Wo_Estimate: TDBCheckBoxEh;
    Ne_Price: TDBNumberEditEh;
    Ne_Price_PP: TDBNumberEditEh;
    Chb_by_sgp: TDBCheckBoxEh;
  private
    function  Prepare: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
  public
  end;

var
  FrmODedtOrStdItems: TFrmODedtOrStdItems;

implementation

{$R *.dfm}

function TFrmODedtOrStdItems.Prepare: Boolean;
begin
  Caption:='Стандартное изделие';
  F.DefineFields:=[
    ['id$i'],
    ['id_or_format_estimates$i'],
    ['name$s','V=1:400::T'],
    ['price$f','V=0:9999999:2:n'],
    ['price_pp$f','V=0:9999999:2:n'],
    ['wo_estimate$i'],
    ['by_sgp$i']
  ];
  View := 'or_std_items';
  Table := 'or_std_items';
  FOpt.UseChbNoClose:= True;
  //Opt.RequestWhereClose:= cqYNC;
  FOpt.InfoArray:= [
    ['Ввод параметров стандартного изделия.'#13#10+
     ''#13#10
    ]
  ];
  Result := inherited;
end;

procedure TFrmODedtOrStdItems.ControlOnExit(Sender: TObject);
begin
  inherited;
end;

procedure TFrmODedtOrStdItems.ControlOnChange(Sender: TObject);
begin
  inherited;
end;



end.
