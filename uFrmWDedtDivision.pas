unit uFrmWDedtDivision;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog,
  uData, uForms, uDBOra, uString, uMessages, uFields
  ;

type
  TFrmWDedtDivision = class(TFrmBasicDbDialog)
    cmb_Office: TDBComboBoxEh;
    edt_Code: TDBEditEh;
    edt_name: TDBEditEh;
    cmb_id_head: TDBComboBoxEh;
    edt_editusernames: TDBEditEh;
    chb_Active: TDBCheckBoxEh;
    procedure edt_usersEditButtons0Click(Sender: TObject; var Handled: Boolean);
  private
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
  public
  end;

var
  FrmWDedtDivision: TFrmWDedtDivision;

implementation

uses
  D_SelectUsers
  ;

{$R *.dfm}

function TFrmWDedtDivision.Prepare: Boolean;
begin
  Caption := 'Подразделение';
  F.DefineFields:=[
    ['id$i'],
    ['office$i','v=1:400'],
    ['name$s','v=1:400:0:T'],
    ['id_head$i','v=1:40000'],
    ['editusers$s',''],
    ['editusernames$s;0','v=1:4000:0', True],
    ['code$s','v=0:5:0:T'],
    ['active$i','']
  ];
  View := 'v_ref_divisions';
  Table := 'ref_divisions';
  FOpt.UseChbNoClose := False;
  FOpt.InfoArray:= [[
    'Данные подразделения.'#13#10+
    'Введите название подразделения, выберите относится ли оно к офису или цеху.'#13#10+
    'Выберите руководителя из списка работников.'#13#10+
    'Введите код подразделения (используется в бухгалтерии).'#13#10+
    'Выберите одного или нескольких пользователей, которые будут заполнять ТУРВ'#13#10+
    'для данного подразделения, нажав на кнопку спава в поле ввода и отметив нужные фамилии.'#13#10+
    'Если подразделение существуует сейчас и в него требуется прием работников '#13#10+
    'и учет рабочего времени, то отметьте галку "Используется"'#13#10
    ,not (Mode in [fView, fDelete])
  ]];
  Result:=inherited;
  if not Result then
    Exit;
  edt_editusernames.ReadOnly := True;
end;


function TFrmWDedtDivision.LoadComboBoxes: Boolean;
begin
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || ''  '' || w.o as name, id from ref_workers w order by name', [], cmb_id_head, cntComboLK);
  Cth.AddToComboBoxEh(cmb_office, [['Цех',0], ['Офис',1]]);
  Result := True;
end;

procedure TFrmWDedtDivision.edt_usersEditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
  if Dlg_SelectUsers.ShowDialog(FormDoc + '_1', F.GetProp('editusers'), True, NewIds, NewNames) <> mrOk then
    exit;
  edt_editusernames.Value := NewNames;
  F.SetProp('editusers', NewIds);
end;


end.
