{
Причина задержки заказа в производстве (просрочки). Вызывается из журнала просрочки в производстве
(uFrmOGjrnOrderStages.pas, клик по колонке "delreasonname"). Данные - таблица delayed_prod_reasons,
одна строка на заказ (id = id заказа), причина - из справочника ref_delayed_prod_reasons, плюс произвольный
комментарий.
ВНИМАНИЕ, ИСПРАВЛЕН БАГ: в исходном TDlg_DelayedInProd.ShowDialog параметр aMode фактически не использовался -
вместо него читалось/писалось поле Mode (унаследованное от V_Normal, персистентное для формы-синглтона), которое
после самого первого открытия диалога навсегда становилось fEdit и уже не возвращалось к fView. Из-за этого
диалог всегда открывался в режиме редактирования, даже когда вызывающий код (uFrmOGjrnOrderStages.pas, по
FEditMode) явно запрашивал только просмотр (fView) - то есть проверка права на изменение реально не работала.
Здесь параметр aMode используется по назначению, и поля формы дополнительно блокируются в режиме fView.
}
unit uFrmODEdtOrdersDelayedInProduction;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Mask,
  DBCtrlsEh,
  uFrmBasicMdi, uData
  ;

type
  TFrmODEdtOrdersDelayedInProduction = class(TFrmBasicMdi)
    cmb_Reason: TDBComboBoxEh;
    mem_Comment: TDBMemoEh;
  private
    { Private declarations }
    FID_Order: Integer;
    function Save: Boolean; override;
  public
    { Public declarations }
    function ShowDialog(AOwner: TObject; aMode: TDialogType; aID_Order: Integer): Boolean;
  end;

var
  FrmODEdtOrdersDelayedInProduction: TFrmODEdtOrdersDelayedInProduction;

implementation

{$R *.dfm}

uses
  uString,
  uDBOra,
  uForms
  ;

function TFrmODEdtOrdersDelayedInProduction.ShowDialog(AOwner: TObject; aMode: TDialogType; aID_Order: Integer): Boolean;
//см. также аналогичный исходный TDlg_DelayedInProd.ShowDialog
var
  va: TVarDynArray;
begin
  Result := False;
  if aMode <> fView then aMode := fEdit;
  FID_Order := aID_Order;
  va := Q.QLoadRow('select id, id_reason, comm from delayed_prod_reasons where id = :id$i', [FID_Order]);
  if va[0] = null then begin
    va := [0, null, ''];
    if aMode <> fView then aMode := fAdd;
  end;
  PrepareCreatedForm(AOwner, Self.Name, '~Причина задержки', aMode, FID_Order, [
   ['Выберите причину задержки заказа из списка.'#13#10+
    'Также вы можете ввести произвольный комментарий.']
  ], [myfoModal, myfoDialog, myfoDialogButtonsB]);
  Q.QLoadToDBComboBoxEh('select name, id from ref_delayed_prod_reasons where active = 1 or id = :id$i', [va[1]], cmb_Reason, cntComboLK0);
  Cth.SetControlValue(cmb_Reason, va[1]);
  Cth.SetControlValue(mem_Comment, va[2]);
  cmb_Reason.Enabled := Mode <> fView;
  mem_Comment.Enabled := Mode <> fView;
  Result := ShowModal = mrOk;
end;

function TFrmODEdtOrdersDelayedInProduction.Save: Boolean;
begin
  Result := Q.QSave(Q.QFModeToIUD(Mode), 'delayed_prod_reasons', 'id', 'id$i;id_reason$i;comm$s',
    [FID_Order, S.NullIfEmpty(Cth.GetControlValue(cmb_Reason)), Cth.GetControlValue(mem_Comment)]
  ) <> -1;
end;

end.
