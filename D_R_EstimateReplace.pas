unit D_R_EstimateReplace;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, DBCtrlsEh, Vcl.StdCtrls,
  Vcl.Mask, Vcl.Buttons, uString, Vcl.ExtCtrls, ButtonsEh,
  uData
  ;

type
  TDlg_R_EstimateReplace = class(TForm_Normal)
    Bt_Cancel: TBitBtn;
    Bt_Ok: TBitBtn;
    Img_Info: TImage;
    edt_1: TDBEditEh;
    edt_2: TDBEditEh;
    procedure Bt_OkClick(Sender: TObject);
    procedure edt_1EditButtons0Click(Sender: TObject; var Handled: Boolean);
    procedure edt_2EditButtons0Click(Sender: TObject; var Handled: Boolean);
  private
    { Private declarations }
    Id: Variant;
    va: TVarDynArray;
    procedure SelectNom(Ctl: TDbEditEh);
  public
    { Public declarations }
    function ShowDialog(AId: Variant; AMode: TDialogType): Boolean;
  end;

var
  Dlg_R_EstimateReplace: TDlg_R_EstimateReplace;

implementation

{$R *.dfm}

uses
  uForms,
  uMessages,
  uDBOra,
  uWindows
  ;

procedure TDlg_R_EstimateReplace.SelectNom(Ctl: TDbEditEh);
begin
  Wh.SelectDialogResult:=[];
  Wh.ExecReference(myfrm_R_bCAD_Nomencl_SEL, Self, [myfoDialog, myfoModal], null);
  if Length(Wh.SelectDialogResult) = 0 then Exit;
  Ctl.Text:=Wh.SelectDialogResult[2];
end;

procedure TDlg_R_EstimateReplace.Bt_OkClick(Sender: TObject);
var
  id1, id2: Variant;
  res: Integer;
begin
  inherited;
  edt_1.Text:=Trim(edt_1.Text);
  edt_2.Text:=Trim(edt_2.Text);
  ModalResult:=mrNone;
  if (edt_1.Text = '')or(edt_1.Text = edt_2.Text)
    then begin MyWarningMessage('ƒанные некорректны!'); Exit; end;
  id1:=Q.QSelectOneRow('select id from bcad_nomencl where name = :name$s', [edt_1.Text])[0];
  if edt_2.Text <> ''
    then id2:=Q.QSelectOneRow('select id from bcad_nomencl where name = :name$s', [edt_2.Text])[0]
    else id2 := -1;
  if (id1 = null)or(id2 = null)
    then begin MyWarningMessage('ƒолжны быть выбраны существующие номенклатурные позиции!'); Exit; end;
  if (Mode = fEdit)and(id <> id1) then begin
    //костыль
    //удал€ем запись, если было изменение айди замен€емого наименовани€, тк ид в таблице отдельного у нас нет и общий запрос не пройдет из-за двух одинаковых параметров
    Q.QExecSql('delete from ref_estimate_replace where id_old = :id_old$i', [id]);
    if mode = fEdit then Mode := fAdd;
  end;
  if Q.QIUD(Q.QFModeToIUD(Mode),
    'ref_estimate_replace', '-', 'id_old$i;id_new$i',
    [id1, S.IIf(id2 = -1, null, id2)]
  ) < 0
    then begin MyWarningMessage('ќшибка сохранени€ данных!'); Exit; ModalResult:=mrOk; end;
  ModalResult:=mrOk;
end;

procedure TDlg_R_EstimateReplace.edt_1EditButtons0Click(Sender: TObject; var Handled: Boolean);
begin
  inherited;
  SelectNom(edt_1);
end;

procedure TDlg_R_EstimateReplace.edt_2EditButtons0Click(Sender: TObject; var Handled: Boolean);
begin
  inherited;
  SelectNom(edt_2);
end;

function TDlg_R_EstimateReplace.ShowDialog(AId: Variant; AMode: TDialogType): Boolean;
begin
  Result:= False;
  Id:=AId;
  Mode:=AMode;
  Cth.SetDialogForm(Self, Mode, 'јвтозамена номенклатуры');
  if Mode <> fAdd
    then va:=Q.QLoadToVarDynArrayOneRow('select id_old, oldname, id_new, newname from v_ref_estimate_replace where id_old = :id$i', [ID])
    else va:=[-1, '', -1, ''];
  //выходим без диалога дл€ заказов не того префикса, если заказ не найден, если рекламаци€
  if (Length(va) = 0)and(Mode <> fAdd) then Exit;
  Cth.SetControlValue(edt_1, va[1]);
  Cth.SetControlValue(edt_2, va[3]);
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
    ['¬ыберите из списка исходную номенклатуру, и ту, на которую она будет замен€тьс€ в сметах, нажав на кнопку.'#13#10+
    '≈сли исходна€ номенклатура из смет должна полностью удал€тьс€, то оставьте второе поле ввода пустым.'#13#10+
    'Ќоменклатуру, которой еще нет в базе учета, ввести нельз€!'#13#10]
    ]), 20);
  Img_Info.Top:=Bt_Ok.top;
  Result:=ShowModal = mrOk;
end;

end.
