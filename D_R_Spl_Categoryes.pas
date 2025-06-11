unit D_R_Spl_Categoryes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, F_MdiDialogTemplate, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask, DBCtrlsEh;

type
  TDlg_R_Spl_Categoryes = class(TForm_MdiDialogTemplate)
    E_Name: TDBEditEh;
    E_UserNames: TDBEditEh;
    procedure E_UserNamesEditButtons0Click(Sender: TObject; var Handled: Boolean);
  private
    { Private declarations }
    function Prepare: Boolean; override;
  public
    { Public declarations }
  end;

var
  Dlg_R_Spl_Categoryes: TDlg_R_Spl_Categoryes;

implementation

uses
  D_SelectUsers,
  uString,
  uData
  ;

{$R *.dfm}

procedure TDlg_R_Spl_Categoryes.E_UserNamesEditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
  if Dlg_SelectUsers.ShowDialog(FormDoc + '_1',  S.NSt(CtrlValues[3]), True, NewIds, NewNames) <> mrOk then exit;
  E_UserNames.Value:=NewNames;
  CtrlValues[3]:=NewIds;
end;

function TDlg_R_Spl_Categoryes.Prepare: Boolean;
begin
  Caption:='Категории заявок на снабжение';
  Fields:='id$i;name$s;usernames$s;useravail$s';
  FieldsSave:='id$i;name$s;0;useravail$s';
  View:='v_spl_categoryes';
  Table:='spl_categoryes';
  CtrlVerifications:=['','1:50','0:4000',''];
  CtrlValuesDefault:=[0, '', '', ''];
  NoCloseIfAdd:= True;
  Info:=
  'Реадктирование категории заявок на снабжение.'#13#10+
  'Введите наименование категории и выберите пользователей,'#13#10+
  'Которые могут формировать по ним заявки.'#13#10
  ;
  AutoSaveWindowPos:= True;
  MinWidth:=400;
  MinHeight:=148;
  MaxHeight:=148;
  Result:=inherited;
  //не удаляем категорию с айди = 1
  if (Mode = fDelete)and(CtrlValues[0] = 1)
    then Bt_Ok.Enabled:=False;
end;


end.
