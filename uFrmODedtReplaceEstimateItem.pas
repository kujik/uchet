{
Автозамена номенклатуры в сметах: указываем исходную номенклатурную позицию и ту, на которую она будет
заменяться (или пусто - тогда исходная просто удаляется из смет). Данные - таблица ref_estimate_replace,
ключ - id_old (отдельного суррогатного id нет). Вызывается только из uFrmXGlstMain.pas (myfrm_R_EstimatesReplace).
}
unit uFrmODedtReplaceEstimateItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Mask,
  DBCtrlsEh,
  uFrmBasicMdi, uData
  ;

type
  TFrmODedtReplaceEstimateItem = class(TFrmBasicMdi)
    edt_1: TDBEditEh;
    edt_2: TDBEditEh;
    procedure edt_1EditButtons0Click(Sender: TObject; var Handled: Boolean);
    procedure edt_2EditButtons0Click(Sender: TObject; var Handled: Boolean);
  private
    { Private declarations }
    FId: Variant;
    FId1, FId2: Variant;
    procedure SelectNom(Ctl: TDBEditEh);
    procedure VerifyBeforeSave; override;
    function Save: Boolean; override;
  public
    { Public declarations }
    function ShowDialog(AOwner: TObject; AId: Variant; AMode: TDialogType): Boolean;
  end;

var
  FrmODedtReplaceEstimateItem: TFrmODedtReplaceEstimateItem;

implementation

{$R *.dfm}

uses
  uString,
  uDBOra,
  uForms,
  uWindows
  ;

procedure TFrmODedtReplaceEstimateItem.SelectNom(Ctl: TDBEditEh);
begin
  Wh.SelectDialogResult := [];
  Wh.ExecReference(myfrm_R_bCAD_Nomencl_SEL, Self, [myfoDialog, myfoModal], null);
  if Length(Wh.SelectDialogResult) = 0 then Exit;
  Ctl.Text := Wh.SelectDialogResult[2];
end;

procedure TFrmODedtReplaceEstimateItem.edt_1EditButtons0Click(Sender: TObject; var Handled: Boolean);
begin
  SelectNom(edt_1);
end;

procedure TFrmODedtReplaceEstimateItem.edt_2EditButtons0Click(Sender: TObject; var Handled: Boolean);
begin
  SelectNom(edt_2);
end;

function TFrmODedtReplaceEstimateItem.ShowDialog(AOwner: TObject; AId: Variant; AMode: TDialogType): Boolean;
//см. также аналогичный исходный TDlg_R_EstimateReplace.ShowDialog
var
  va: TVarDynArray;
begin
  Result := False;
  FId := AId;
  if AMode <> fAdd
    then va := Q.QLoadRow0('select id_old, oldname, id_new, newname from v_ref_estimate_replace where id_old = :id$i', [FId])
    else va := [-1, '', -1, ''];
  //выходим без диалога, если запись не найдена
  if (Length(va) = 0) and (AMode <> fAdd) then Exit;
  PrepareCreatedForm(AOwner, Self.Name, '~Автозамена номенклатуры', AMode, FId, [
   ['Выберите из списка исходную номенклатуру, и ту, на которую она будет заменяться в сметах, нажав на кнопку.'#13#10+
    'Если исходная номенклатура из смет должна полностью удаляться, то оставьте второе поле ввода пустым.'#13#10+
    'Номенклатуру, которой еще нет в базе учета, ввести нельзя!'#13#10]
  ], [myfoModal, myfoDialog, myfoDialogButtonsB]);
  Cth.SetControlValue(edt_1, va[1]);
  Cth.SetControlValue(edt_2, va[3]);
  edt_1.Enabled := Mode <> fView;
  edt_2.Enabled := Mode <> fView;
  Result := ShowModal = mrOk;
end;

procedure TFrmODedtReplaceEstimateItem.VerifyBeforeSave;
//проверка перед сохранением (см. TFrmBasicMdi.btnOkClick), см. также исходный Bt_OkClick
begin
  edt_1.Text := Trim(edt_1.Text);
  edt_2.Text := Trim(edt_2.Text);
  if (edt_1.Text = '') or (edt_1.Text = edt_2.Text) then begin
    FErrorMessage := 'Данные некорректны!';
    Exit;
  end;
  FId1 := Q.QLoadValue('select id from bcad_nomencl where name = :name$s', [edt_1.Text]);
  if edt_2.Text <> ''
    then FId2 := Q.QLoadValue('select id from bcad_nomencl where name = :name$s', [edt_2.Text])
    else FId2 := -1;
  if (FId1 = null) or (FId2 = null) then
    FErrorMessage := 'Должны быть выбраны существующие номенклатурные позиции!';
end;

function TFrmODedtReplaceEstimateItem.Save: Boolean;
begin
  if (Mode = fEdit) and (FId <> FId1) then begin
    //костыль: удаляем запись, если изменился id заменяемого наименования - тк отдельного id в таблице нет,
    //а общий запрос на update не пройдет из-за двух одинаковых параметров (см. также исходный Bt_OkClick)
    Q.QExecSql('delete from ref_estimate_replace where id_old = :id_old$i', [FId]);
    Mode := fAdd;
  end;
  Result := Q.QSave(Q.QFModeToIUD(Mode), 'ref_estimate_replace', '-', 'id_old$i;id_new$i',
    [FId1, S.IIf(FId2 = -1, null, FId2)]
  ) <> -1;
end;

end.
