{
  Модуль uFrmChooseDialog предоставляет диалоговое окно для выбора пользователем одного варианта из списка.

  Назначение:
    Отображает форму с заголовком, текстовым сообщением (опционально), группой радиокнопок (TRadioGroup)
    и стандартными кнопками OK/Cancel (унаследованными от TFrmBasicMdi). Пользователь выбирает один из предложенных
    вариантов, после чего диалог возвращает индекс выбранного элемента.

  Особенности:
    - Автоматический расчёт ширины формы: если параметр AWidth = 0, то ширина определяется по самому длинному тексту
      варианта (с использованием вспомогательного метода Cth.GetTextWidth, предположительно из модуля uString).
    - Автоматический расчёт высоты текстовой метки (lblText) с переносом слов, чтобы текст целиком поместился
      в заданную ширину (используется Cth.GetWordWrapHeight).
    - Высота формы вычисляется динамически на основе количества вариантов, высоты панели с текстом и панели кнопок.
    - Поддерживается предустановленный вариант по умолчанию (ADefaultVariant).
    - Результат работы метода ShowDialog: индекс выбранного элемента или -1 при отмене.
}

unit uFrmChooseDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls, Math, uString;

type
  TFrmChooseDialog = class(TFrmBasicMdi)
    rgMain: TRadioGroup;
    pnlText: TPanel;
    lblText: TLabel;
    procedure rgMainClick(Sender: TObject);
  private
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
  public
      //ACaption        - заголовок формы.
      //AText           - текст пояснения (отображается выше радиогруппы). Если пусто, панель с текстом скрывается.
      //AVariants       - массив вариантов (TVarDynArray) для отображения в радиогруппе.
      //AInfo           - дополнительная информация (тип TVarDynArray2), передаётся в базовый PrepareCreatedForm.
      //AWidth          - принудительная ширина формы в пикселях (0 = авто-расчёт по самому длинному варианту).
      //ADefaultVariant - индекс предварительно выбранного варианта (-1 = ничего не выбрано).
      //Возвращает: индекс выбранного варианта (0..High(AVariants)) или -1, если пользователь нажал Cancel.
    function ShowDialog(ACaption, AText: string; AVariants: TVarDynArray; AInfo: TVarDynArray2; AWidth: Integer = 0; ADefaultVariant: Integer = -1): Integer;
  end;

var
  FrmChooseDialog: TFrmChooseDialog;

implementation

uses
  uData, uForms, uMessages, uDBOra;


{$R *.dfm}

procedure TFrmChooseDialog.rgMainClick(Sender: TObject);
begin
  Verify(nil);
end;

function TFrmChooseDialog.ShowDialog(ACaption, AText: string; AVariants: TVarDynArray; AInfo: TVarDynArray2; AWidth: Integer = 0; ADefaultVariant: Integer = -1): Integer;
var
  i, len: Integer;
begin
  PrepareCreatedForm(Application, '', '~' + ACaption, fEdit, null, AInfo, [myfoDialog, myfoDialogButtonsB]);
  if AWidth = 0 then begin
    len := 0;
    for i := 0 to High(AVariants) do begin
      var ln := Cth.GetTextWidth(AVariants[i], rgMain.Font);
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
  Self.Width := Max(len + 50, 200);
  rgMain.Items.Clear;
  for i := 0 to High(AVariants) do begin
    rgMain.Items.Add(AVariants[i]);
  end;
  rgMain.ItemIndex := ADefaultVariant;
  Self.ClientHeight := rgMain.Items.Count * 18 + 15 + pnlText.Height + pnlFrmBtns.Height + 20;
  Result := -1;
  if ShowModal <> mrOk then
    Exit;
  Result :=rgMain.ItemIndex;
end;

function TFrmChooseDialog.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result := rgMain.ItemIndex = -1;
end;

end.

