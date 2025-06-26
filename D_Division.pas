unit D_Division;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, F_MDIDlg1,
  Vcl.ExtCtrls;

type
  TDlg_Division = class(TForm_MDIDlg1)
    Cb_IsOffice: TDBComboBoxEh;
    Cb_Head: TDBComboBoxEh;
    E_Name: TDBEditEh;
    E_users: TDBEditEh;
    E_Code: TDBEditEh;
    Chb_Active: TDBCheckBoxEh;
    Img_Info: TImage;
    procedure E_usersEditButtons0Click(Sender: TObject; var Handled: Boolean);
  private
    { Private declarations }
    Users: string;
    function Load: Boolean; override;
    function Save: Boolean; override;
  public
    { Public declarations }
  end;

var
  Dlg_Division: TDlg_Division;

implementation

uses
  D_SelectUsers
  ;

{$R *.dfm}

procedure TDlg_Division.E_usersEditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
  if Dlg_SelectUsers.ShowDialog(FormDoc + '_1',  Users, True, NewIds, NewNames) <> mrOk then exit;
  E_Users.Value:=NewNames;
  Users:=NewIds;
end;

function TDlg_Division.Load: Boolean;
var
  v: Variant;
begin
  Result:=False;
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || ''  '' || w.o as name, id from ref_workers w order by name', [], Cb_Head, cntComboLK);
  if Mode = fAdd
    then v:=VarArrayOf([1,'','','','','','','1'])
    else v:=Q.QSelectOneRow('select id, office, name, id_head, editusers, editusernames, code, active from v_ref_divisions where id = :id', [ID]);
  if v[0] = null then begin MsgRecordIsDeleted; Exit; end;
  Cb_IsOffice.Value:=v[1];
  E_Name.Value:=v[2];
  Cb_Head.Value:=v[3];
  Users:=S.NSt(v[4]);
  E_users.value:=v[5];
  E_Code.Value:=v[6];
  Cth.SetControlValue(Chb_Active, v[7]);
  //параметры проверки контролов
  Cth.SetControlsVerification(
    [E_Name, Cb_IsOffice, Cb_Head, E_users, E_Code],
    ['1:400:0:T', '1:400', '1:400', '1:4000:0', '0:5:0:T']
  );
  Cth.SetInfoIcon(
    Img_Info,
    S.IIFStr(Mode in [fView, fDelete], '',
      'Данные подразделения.'#13#10+
      'Введите название подразделения, выберите относится ли оно к офису или цеху.'#13#10+
      'Выберите руководителя из списка работников.'#13#10+
      'Введите код подразделения (используется в бухгалтерии).'#13#10+
      'Выберите одного или нескольких пользователей, которые будут заполнять ТУРВ'#13#10+
      'для данного подразделения, нажав на кнопку спава в поле ввода и отметив нужные фамилии.'#13#10+
      'Если подразделение существуует сейчас и в него требуется прием работников '#13#10+
      'и учет рабочего времени, то отметьте галку "Используется"'#13#10
    ),
    20);
  Result:=True;
end;

function TDlg_Division.Save: Boolean;
var
  v: TVarDynArray;
  i, j: Integer;
  IUDMode: char;
begin
  Result:= (Q.QIUD(Q.QFModeToIUD(Mode), 'ref_divisions', 'sq_ref_divisions', 'id;name;office;id_head;editusers;code;active',
    [ID, Cth.GetControlValue(E_Name), Cth.GetControlValue(Cb_Isoffice), Cth.GetControlValue(Cb_Head), Users, Cth.GetControlValue(E_Code), Cth.GetControlValue(Chb_Active)]
  ) >= 0);
end;


end.
