{
редактирование татьи расходов
}

unit uFrmCDedtExpenseItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog, ToolCtrlsEh,
  uData, uForms, uDBOra, uString, uMessages, uFields, Vcl.Mask
  ;

type
  TFrmCDedtExpenseItem = class(TFrmBasicDbDialog)
    cmb_id_group: TDBComboBoxEh;
    edt_name: TDBEditEh;
    edt_usernames: TDBEditEh;
    edt_agreednames: TDBEditEh;
    chb_accounttype_1: TDBCheckBoxEh;
    chb_accounttype_2: TDBCheckBoxEh;
    chb_accounttype_3: TDBCheckBoxEh;
    chb_recvreceipt: TDBCheckBoxEh;
    chb_active: TDBCheckBoxEh;
  private
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnChange(Sender: TObject); override;
    procedure EditButtonsClick(Sender: TObject; var Handled: Boolean); override;
    procedure OpenChooseUsersDialog(AIdsName, ANamesName: string);
    procedure OnAccountTypeClick(Sender: TObject);
  public
  end;

var
  FrmCDedtExpenseItem: TFrmCDedtExpenseItem;

implementation

{$R *.dfm}

uses
  uFrmXGsesUsersChoice
  ;


function TFrmCDedtExpenseItem.Prepare: Boolean;
begin
  Result := False;
  Caption := 'Статья расходов';
  //поля
  F.DefineFields:=[
    ['id$i'],
    ['id_group$i','v=1:400'],
    ['name$s','v=1:400:0:T'],
    ['usernames$s;0',''],
    ['useravail$s',''],
    ['agreednames$s;0',''],
    ['agreed$s',''],
    ['recvreceipt$i',''],
    ['accounttype$i',''],
    ['active$i','']
  ];
  //параметры доступа к данным
  View := 'v_ref_expenseitems';
  Table := 'ref_expenseitems';
  Sequence := 'sq_ref_expenseitems';
  FOpt.UseChbNoClose := False;
  //установим кнопки в полях выбора пользователей
  Cth.SetEditButtons(edt_usernames, [[30, 'Выбрать пользователей']]);
  Cth.SetEditButtons(edt_agreednames, [[30, 'Выбрать пользователей']]);
  //информация
  FOpt.InfoArray:= [[
    'Редактирование статьи расходов.'#13#10+
    'Выберите группу из списка существующих, наименование статьи расходов.'#13#10+
    'Выберите в открывающемся окне пользователей, которые могут создавать счета по данной статье расходов'#13#10+
    '(пользователей может быть несколько).'#13#10+
    'Также выберите сотрудников, которые ставят согласование для счетов по данной статье.'#13#10+
    'Выберите при необходимости тип счета для данной статьи'#13#10+
    '(может быть обычный счет, транспорт снабжения, транспорт отгрузки, либо счет подрядчика по монтажу).'#13#10+
    'Поставьте галочку, если по этим счетам требуется загружать заявку на снабжение'#13#10+
    '(заявка не обязательна, если сумма счета не превышает значения, установленного в настройках программы).'#13#10
    ,not (Mode in [fView, fDelete])
  ]];
  //растягиваем только по ширине
  FWHBounds.Y2:= -1;
  //подительский метод
  Result := inherited;
  if not Result then
    Exit;
  //поля выбора пользователей должны быть ридонли
  edt_usernames.ReadOnly := True;
  edt_agreednames.ReadOnly := True;
  //установим чекбокс с типом счта для статьи (транспортные, монтаж), если 0 то все будут без отметки
  Cth.SetControlValue(Self, 'chb_accounttype_' + F.GetPropB('accounttype').AsString, 1);
end;

function TFrmCDedtExpenseItem.LoadComboBoxes: Boolean;
//загрузим данные в комбобокс
begin
  Result := False;
  Q.QLoadToDBComboBoxEh('select name, id from ref_grexpenseitems order by name', [], cmb_id_group, cntComboLK);
  Result := True;
end;

procedure TFrmCDedtExpenseItem.ControlOnChange(Sender: TObject);
//при изменении данных в полях ввода
begin
  OnAccountTypeClick(Sender);
  inherited;
end;

procedure TFrmCDedtExpenseItem.EditButtonsClick(Sender: TObject; var Handled: Boolean);
//при клики на едитбаттон
var
  LNewIds, LNewNames: string;
begin
  if (TEditButtonControlEh(Sender).Owner = edt_usernames) then
    OpenChooseUsersDialog('useravail', 'usernames');
  if (TEditButtonControlEh(Sender).Owner = edt_agreednames) then
    OpenChooseUsersDialog('agreed', 'agreednames');
end;

procedure TFrmCDedtExpenseItem.OpenChooseUsersDialog(AIdsName, ANamesName: string);
//вызов диалога выбора пользователей, передаем имена свойтв для айдишников и наименований пользователей
var
  LNewIds, LNewNames: string;
begin
  LNewIds := F.GetProp(AIdsName);
  LNewNames := F.GetProp(ANamesName);
  if TFrmXGsesUsersChoice.ShowDialog(Application, True, LNewIds, LNewNames) <> mrOk then
    Exit;
  F.SetProp(AIdsName, LNewIds);
  F.SetProp(ANamesName, LNewNames);
end;

procedure TFrmCDedtExpenseItem.OnAccountTypeClick(Sender: TObject);
//процедура для обработки клика на чекбоксе выбора типа счета (может быть выбран один из них или ни одного)
var
  i: Integer;
begin
  //нужные контролы определим по префиксу
  if Mode in [fDelete, fView] or (Pos('chb_accounttype_', TComponent(Sender).Name) <> 1) then
    Exit;
  //снимем пометку с остальных, если текущий отмечен, и установим свойство для типа счета
  if TDBCheckBoxEh(Sender).Checked then begin
    for i := 0 to ComponentCount - 1 do
      if (Pos('chb_accounttype_', Components[i].Name) = 1) and (Components[i].Name <> TComponent(Sender).Name) then
        TDBCheckBoxEh(Components[i]).Checked := False;
    F.SetProp('accounttype', StrToInt(S.Right(TComponent(Sender).Name, 1)));
  end
  else
    F.SetProp('accounttype', 0);
end;

end.
