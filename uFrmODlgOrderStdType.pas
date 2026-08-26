{
  Модуль uFrmODlgOrderStdType предоставляет диалоговое окно для выбора типа стандартных изделий,
  по которому создаётся заказ, и (опционально) шаблона заказа этого же типа для копирования.

  Назначение:
    Используется при создании нового заказа (журнал заказов, кнопка "Добавить" - см.
    TFrmOGjrnOrders.Frg1ButtonClick в uFrmOGjrnOrders.pas). Пользователь выбирает один из трёх типов
    стандартных изделий радиокнопками (см. STDITEM_TYPE_* в uOrders.pas), после чего в комбобоксе ниже
    подгружается список активных шаблонов заказа этого типа (первой строкой - "[без шаблона]").
    Результат работы ShowDialog - выбранный тип и, если выбран не "[без шаблона]", id шаблона для
    копирования (иначе Null) - по нему вызывающий код сам решает, каким режимом (fAdd/fCopy) открыть
    диалог заказа (myfrm_Dlg_Order).

    Для справочника "Шаблоны заказов" (myfrm_R_OrderTemplates, см. uFrmXGlstMain.pas) этот диалог не
    используется - там нужен выбор только типа, без шаблона для копирования, поэтому там применяется
    напрямую uFrmChooseDialog.pas (простой выбор варианта из списка).

  Форма построена по образцу uFrmChooseDialog.pas: PrepareCreatedForm + VerifyAdd для блокировки кнопки
  ОК, пока не выбран ни один тип - но, в отличие от uFrmChooseDialog.pas, здесь добавлен зависимый от
  выбора типа комбобокс со списком шаблонов (перезагружается при каждой смене радиокнопки).
}

unit uFrmODlgOrderStdType;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls, uString;

type
  TFrmODlgOrderStdType = class(TFrmBasicMdi)
    rbProduction: TRadioButton;
    rbShipment: TRadioButton;
    rbSemiproduct: TRadioButton;
    lblTemplate: TLabel;
    cmbTemplate: TComboBox;
    procedure RbTypeClick(Sender: TObject);
  private
    //id шаблонов, параллельно cmbTemplate.Items - элемент [0] всегда Null ("[без шаблона]")
    FTemplateIds: TVarDynArray;
    //-1, если ни одна радиокнопка не выбрана - иначе STDITEM_TYPE_* (см. uOrders.pas)
    function GetSelectedType: Integer;
    //перезагружает cmbTemplate по выбранному типу AType (активные шаблоны этого типа + "[без шаблона]" первой строкой)
    procedure LoadTemplatesForType(AType: Integer);
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
  public
      //Возвращает True, если пользователь нажал ОК (тип выбран - иначе ОК недоступен, см. VerifyAdd).
      //AType - выбранный тип стандартных изделий (STDITEM_TYPE_*, см. uOrders.pas).
      //AIdTemplate - id выбранного для копирования шаблона заказа, либо Null, если выбрано "[без шаблона]".
    function ShowDialog(out AType: Integer; out AIdTemplate: Variant): Boolean;
  end;

var
  FrmODlgOrderStdType: TFrmODlgOrderStdType;

implementation

uses
  uData, uForms, uOrders, uDBOra;

{$R *.dfm}

const
  cNoTemplateCaption = '[без шаблона]';

function TFrmODlgOrderStdType.GetSelectedType: Integer;
begin
  if rbProduction.Checked then
    Result := STDITEM_TYPE_PRODUCTION
  else if rbShipment.Checked then
    Result := STDITEM_TYPE_SHIPMENT
  else if rbSemiproduct.Checked then
    Result := STDITEM_TYPE_SEMIPRODUCT
  else
    Result := -1;
end;

procedure TFrmODlgOrderStdType.LoadTemplatesForType(AType: Integer);
var
  va2: TVarDynArray2;
  i: Integer;
begin
  cmbTemplate.Items.BeginUpdate;
  try
    cmbTemplate.Items.Clear;
    FTemplateIds := [null];
    cmbTemplate.Items.Add(cNoTemplateCaption);
    //активные шаблоны заказа (orders.id < 0) выбранного типа - тип шаблона определяется через
    //or_format_estimates.type по привязанному orders.id_or_format_estimates (см. TOrders.LinkOrderTemplate
    //в uOrders.pas - там та же связка используется для поиска шаблонов противоположного типа)
    va2 := Q.QLoad(
      'select templatename, id from orders where id < 0 and active = 1 ' +
      'and id_or_format_estimates in (select id from or_format_estimates where type = :type$i and active = 1) ' +
      'order by templatename',
      [AType]);
    for i := 0 to High(va2) do begin
      cmbTemplate.Items.Add(VarToStr(va2[i][0]));
      FTemplateIds := FTemplateIds + [va2[i][1]];
    end;
  finally
    cmbTemplate.Items.EndUpdate;
  end;
  cmbTemplate.ItemIndex := 0;
end;

procedure TFrmODlgOrderStdType.RbTypeClick(Sender: TObject);
begin
  LoadTemplatesForType(GetSelectedType);
  Verify(nil);
end;

function TFrmODlgOrderStdType.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result := GetSelectedType = -1;   //пока не выбран ни один тип - сохранение (ОК) недоступно
end;

function TFrmODlgOrderStdType.ShowDialog(out AType: Integer; out AIdTemplate: Variant): Boolean;
begin
  PrepareCreatedForm(Application, '', '~Тип заказа', fEdit, null,
    [['Выберите тип стандартных изделий, по которому создаётся заказ.'#13#10 +
      'Если нужно скопировать данные из существующего шаблона заказа - выберите его в списке ниже'#13#10 +
      '(показаны только активные шаблоны выбранного типа), иначе оставьте "' + cNoTemplateCaption + '".']],
    [myfoDialog, myfoDialogButtonsB]);
  rbProduction.Checked := False;
  rbShipment.Checked := False;
  rbSemiproduct.Checked := False;
  cmbTemplate.Items.Clear;
  cmbTemplate.Items.Add(cNoTemplateCaption);
  cmbTemplate.ItemIndex := 0;
  FTemplateIds := [null];
  Result := ShowModal = mrOk;
  if not Result then
    Exit;
  AType := GetSelectedType;
  if (cmbTemplate.ItemIndex > 0) and (cmbTemplate.ItemIndex <= High(FTemplateIds)) then
    AIdTemplate := FTemplateIds[cmbTemplate.ItemIndex]
  else
    AIdTemplate := null;
end;

end.
