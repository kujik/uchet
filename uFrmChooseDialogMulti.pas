{
  Модуль uFrmChooseDialogMulti предоставляет диалоговое окно для выбора пользователем произвольного
  количества вариантов из списка (0..N) - чеклист с флажками.

  Назначение:
    Аналог uFrmChooseDialog.pas (там - выбор ровно одного варианта радиогруппой), но здесь пользователь
    отмечает флажками (TCheckListBox) любое количество вариантов, включая ни одного. Используется, в
    частности, диалогом связывания шаблонов заказа в группу (см. TOrders.LinkOrderTemplate в uOrders.pas) -
    там нужно отметить, какие отгрузочные шаблоны входят в группу данного производственного шаблона.

  Особенности (по образцу uFrmChooseDialog.pas):
    - Автоматический расчёт ширины формы по самому длинному варианту, если AWidth = 0.
    - Автоматический расчёт высоты текстовой подсказки (AText) с переносом слов.
    - Высота формы вычисляется динамически по количеству вариантов.
    - Предустановленные отметки задаются параметром ADefaultChecked (той же длины, что и AVariants).
    - ОК доступен всегда (в отличие от ChooseDialog, здесь допустимо не отметить ни одного варианта -
      это означает "не входит ни в одну группу"/"снять все отметки").
    - Результат работы ShowDialog: True, если нажато ОК (тогда AChecked заполнен итоговыми отметками),
      False - если Cancel (AChecked не изменяется).
}

unit uFrmChooseDialogMulti;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.CheckLst, Math, uString;

type
  TFrmChooseDialogMulti = class(TFrmBasicMdi)
    clbMain: TCheckListBox;
    pnlText: TPanel;
    lblText: TLabel;
  private
  public
      //ACaption        - заголовок формы.
      //AText           - текст пояснения (отображается выше чеклиста). Если пусто, панель с текстом скрывается.
      //AVariants       - массив вариантов (TVarDynArray) для отображения в чеклисте.
      //AInfo           - дополнительная информация (тип TVarDynArray2), передаётся в базовый PrepareCreatedForm.
      //ADefaultChecked - массив отметок (TVarDynArray из True/False), той же длины, что и AVariants -
      //                  начальное состояние флажков.
      //AChecked        - (out) итоговый массив отметок той же длины, что и AVariants - заполняется только
      //                  при результате True.
      //AWidth          - принудительная ширина формы в пикселях (0 = авто-расчёт по самому длинному варианту).
      //Возвращает: True, если пользователь нажал ОК, False - если Cancel.
    function ShowDialog(ACaption, AText: string; AVariants: TVarDynArray; AInfo: TVarDynArray2;
      ADefaultChecked: TVarDynArray; out AChecked: TVarDynArray; AWidth: Integer = 0): Boolean;
  end;

var
  FrmChooseDialogMulti: TFrmChooseDialogMulti;

implementation

uses
  uData, uForms, uMessages, uDBOra;

{$R *.dfm}

function TFrmChooseDialogMulti.ShowDialog(ACaption, AText: string; AVariants: TVarDynArray; AInfo: TVarDynArray2;
  ADefaultChecked: TVarDynArray; out AChecked: TVarDynArray; AWidth: Integer = 0): Boolean;
var
  i, len: Integer;
begin
  PrepareCreatedForm(Application, '', '~' + ACaption, fEdit, null, AInfo, [myfoDialog, myfoDialogButtonsB]);
  if AWidth = 0 then begin
    len := 0;
    for i := 0 to High(AVariants) do begin
      var ln := Cth.GetTextWidth(AVariants[i], clbMain.Font);
      if ln > len then
        len := ln;
    end;
  end
  else
    len := AWidth;
  if AText <> '' then begin
    pnlText.ClientHeight := Cth.GetWordWrapHeight(AText, lblText.Font, len + 40) + 8;
    lblText.Caption := AText;
  end
  else
    pnlText.Height := 0;
  Self.Width := Max(len + 60, 200);
  clbMain.Items.Clear;
  for i := 0 to High(AVariants) do begin
    clbMain.Items.Add(AVariants[i]);
    if (i <= High(ADefaultChecked)) and (ADefaultChecked[i] = True) then
      clbMain.Checked[i] := True;
  end;
  Self.ClientHeight := clbMain.Items.Count * 18 + 15 + pnlText.Height + pnlFrmBtns.Height + 20;
  Result := ShowModal = mrOk;
  if not Result then
    Exit;
  SetLength(AChecked, clbMain.Items.Count);
  for i := 0 to clbMain.Items.Count - 1 do
    AChecked[i] := clbMain.Checked[i];
end;

end.
