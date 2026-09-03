unit uFrmXDedtGridPreset;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uFrmBasicMdi, uData
  ;

type
  TFrmXDedtGridPreset = class(TFrmBasicMdi)
    pnlCaption: TPanel;
    lblName: TLabel;
    edtName: TEdit;
    chbIncludeSort: TCheckBox;
    chbIncludeColumnFilters: TCheckBox;
    chbIncludeGridFilter: TCheckBox;
  private
  public
    //диалог ввода имени пресета грида и выбора, что из его настроек реально применять при переключении на
    //пресет (сами данные пресета при сохранении пишутся полностью в любом случае - см. TSettings.SaveGridPreset;
    //эти три флага влияют только на восстановление, см. TSettings.ApplyGridPreset)
    function ShowDialog(AOwner: TObject; AFormDoc, ATitle: string; var AName: string;
      var AIncludeSort, AIncludeColumnFilters, AIncludeGridFilter: Boolean): Boolean;
  end;

var
  FrmXDedtGridPreset: TFrmXDedtGridPreset;

implementation

{$R *.dfm}

function TFrmXDedtGridPreset.ShowDialog(AOwner: TObject; AFormDoc, ATitle: string; var AName: string;
  var AIncludeSort, AIncludeColumnFilters, AIncludeGridFilter: Boolean): Boolean;
begin
  PrepareCreatedForm(AOwner, Self.Name + '_' + AFormDoc, '~' + ATitle, fEdit, null, [], [myfoModal, myfoDialog, myfoDialogButtonsB, myfoSizeable]);
  FOpt.InfoArray := [
    ['Пресет - именованный набор настроек вида грида (ширина, порядок и видимость столбцов), позволяющий быстро переключаться между разными видами таблицы.'#13#10],
    ['В пресет всегда попадает полный текущий вид грида - ширина, порядок и видимость столбцов сохраняются и при переключении на этот пресет применяются всегда, независимо от флажков ниже.'#13#10],
    ['Флажки ниже относятся только к сортировке, фильтрам столбцов и общему фильтру ("гридфильтру"): если флажок снят, при переключении на пресет соответствующая настройка'#13#10+ 'будет СБРОШЕНА, а не оставлена как есть (хотя сами данные для нее в пресете все равно сохраняются - пригодятся, если включить флажок при следующем пересохранении).'#13#10],
    ['Пресет - это "снимок" вида грида на момент сохранения; последующие изменения вида таблицы на него не влияют, пока вы не пересохраните пресет тем же именем.'#13#10],
    ['Общий пресет виден и доступен всем пользователям (создание и удаление требует права "Администрирование интерфейса"); личный пресет виден только своему автору.']
  ];
  pnlCaption.Caption := ATitle;
  edtName.Text := AName;
  chbIncludeSort.Checked := AIncludeSort;
  chbIncludeColumnFilters.Checked := AIncludeColumnFilters;
  chbIncludeGridFilter.Checked := AIncludeGridFilter;
  Result := ShowModal = mrOk;
  if not Result then
    Exit;
  AName := Trim(edtName.Text);
  AIncludeSort := chbIncludeSort.Checked;
  AIncludeColumnFilters := chbIncludeColumnFilters.Checked;
  AIncludeGridFilter := chbIncludeGridFilter.Checked;
  if AName = '' then
    Result := False;
end;

end.
