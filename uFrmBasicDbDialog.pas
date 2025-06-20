unit uFrmBasicDbDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  uData, uForms, uDBOra, uString, uMessages, V_MDI, uLabelColors, uFrmBasicMdi
  ;

type
  TFrmBasicDbDialog = class(TFrmBasicMdi)
  private
  protected
    View: string;                           //таблица/вью из которой загружаем данные
    Table: string;                          //таблица, в которую записываем данные
    Sequence: string;                       //секвенция, если нужна
    IdAfterInsert: Variant;                 //В процедуре Save сюдф записывается Айди, полученное при вставке записи (нужно, если требуются доп. действия в потомке после стандартной записи)
    function  Prepare: Boolean; override;
    function  Load: Boolean; virtual;
    function  Save: Boolean; override;
    function  LoadComboBoxes: Boolean; virtual;
    procedure SetStatusBarText(VisibleStatusBar: Boolean; Text: string); virtual;
  public
  end;

var
  FrmBasicDbDialog: TFrmBasicDbDialog;

implementation

Uses
  uErrors,
  ufields
  ;


{$R *.dfm}


procedure TFrmBasicDbDialog.SetStatusBarText(VisibleStatusBar: Boolean; Text: string);
var
  st: string;
begin
end;

function TFrmBasicDbDialog.Load(): Boolean;
//загрузка данных
//по уже подготовленным глобальным переменным, также в глобальную CtrlValues
//результат пока не влияет ни на что, если не был получен массив, далее проверяется и выдается сообщениеоб удаленной строке
var
  FieldsSt: string;
  CtrlValues: TVarDynArray2;
  i: Integer;
begin
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameL) <> '' then begin
      S.ConcatStP(FieldsSt, F.GetProp(i, fvtFNameL), ';');
    end;
  CtrlValues := Q.QLoadToVarDynArray2(Q.QSIUDSql('s', View, FieldsSt), [id]);
  if Length(CtrlValues) = 0 then begin
    MsgRecordIsDeleted;
  end;
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameL) <> '' then begin
      F.SetPropP(i, CtrlValues[0][i], fvtVBeg);
    end;
  Result := True;
end;

function TFrmBasicDbDialog.Save(): Boolean;
//сохранение данных
var
  ChildHandled: Boolean;
  i, res: Integer;
  CtrlValues2: TVarDynArray;
  FieldsSave2: string;
begin
  Result := False;
  FieldsSave2 := '';
  CtrlValues2 := [];
  //получим поля и их значения, по тем для которых указано сохранение
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameS) <> '' then begin
      S.ConcatStP(FieldsSave2, F.GetProp(i, fvtFNameS), ';');
      CtrlValues2 := CtrlValues2 + [S.NullIfEmpty(F.GetProp(i, fvtVCurr))];
    end;
  //сохраняем заголовочную часть
  Q.QBeginTrans(True);
  res := Q.QIUD(Q.QFModeToIUD(Mode), Table, Sequence, FieldsSave2, CtrlValues2);
  IdAfterInsert:= res;
  if not (Mode in [fEdit, fDelete]) then
    ID := res;
  Result := Q.QCommitOrRollback;
end;

function TFrmBasicDbDialog.LoadComboBoxes: Boolean;
//перекрываем для загрузки дополнительных данных, например комбобоксов
//вызывается после загрузки основных данных
begin
  Result := True;
end;


function TFrmBasicDbDialog.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
begin
  Result := False;
  //проверим блокировку, выйдем если нельзя взять (при попытке редактирования уйдет в просмотр, при удалении - выход)
  if FormDbLock = fNone then
    Exit;

  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;
  FOpt.AutoAlignControls := True;

  Cth.MakePanelsFlat(PMDIClient, []);
  F.PrepareDefineFieldsAdd;
  if Table = '' then
    Table := View;
  if Mode <> fAdd then
    Load;
  //загрузим комбобоксы и сделаем другие кастомные действия
  if not LoadComboBoxes then
    Exit;
  F.SetPropsControls;
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  Result := True;
end;






end.

(*

массив Props синхронизирован с контролами.

если он создан в препаре, то по его данным выставляются парраметры (возможные) контролов.
если массив не создан, то напротив, он создаетя по данным кнтролов, имещих родителем PMDIClient

в дальнейшем обращение через Props, изменение данных того типа, которые реалиуемы на контролах,
передается на соотвествующие контролы, а при чтении - читается с них.





в  Props прописываются свойства, соотвествующие им поля бд для чтения и записи,
правила проверки значений, начальное значение (в этом качестве остается также загруженное в Prepere),
признак инфертирования очистки значения при повторе ввода в форме, признак недоступности контрола,
признак сравнивать начальное значение с текущим для котроля, были ли изменены данные,
наименование свойства, статус ошибки, если это не контрол.

со свойствами ассоциируются поля для чтения и записи - не обязательно, если не начинаются с _
со свойствами ассоциируются контролы, если найден контрол с именем ХХ_имя_свойства

по всем свойствам определяется валидность формы. для этого это должен быть контрол, или свойство
с непустым признаком проверки, его значение проверяется как строка, или любой контрол или свойство
может иметь непустой текст ошибки.

по всем свойства определяется признак изменения данных в форме, значение свойства или контрола
сравнивается с начальным его значением, сохраненным после отработки Prepare

могут быть сохранены текущие значения всех или выбранных свойств и контролов по пиереданным
названиям свойств

могут быть загружены в начальной или текущее значения свойств и контролов все или же выбранные по названиям


GetProp(PropName: string; PropValueType: TDefFiledcValueType);
GetProp(PropName: string; PropValueType: Integer);

FieldNmesFromSelect(Sql: string; AliasesOnly: Boolean = False);

QLoadToProps(PropNames: string = '')
QSaveToProps(PropNames: string = '')

*)
