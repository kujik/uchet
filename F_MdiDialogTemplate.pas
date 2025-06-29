unit F_MdiDialogTemplate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  uData, uForms, uDBOra, uString, uMessages, V_MDI, uLabelColors;

type
  TForm_MdiDialogTemplate = class(TForm_MDI)
    pnl_Bottom: TPanel;
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    Img_Info: TImage;
    chb_NoClose: TCheckBox;
    bvl1: TBevel;
    procedure ControlOnChange(Sender: TObject); virtual;
    procedure ControlOnExit(Sender: TObject); virtual;
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean); virtual;
    procedure Bt_OKClick(Sender: TObject); virtual;
    procedure Bt_CancelClick(Sender: TObject); virtual;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    //сериализация всех контролов, для проверки, были ли изменения
    //сейчас проверяются все данные на форме, если это не устраивает в конкретном случае,
    //то или отключать проверку, или перекрывать Serialize для получения строк данных
    CtrlBegValuesStr, CtrlCurrValuesStr: string;
  protected
    Fields: string;                         //строка полей через ;
    FieldsSave: string;                     //строка полей для операции записи через ;. если не передана то совпадает с Fields
                                            //если в таблице поля называются не так как во вью то могут быть изменены
                                            //если поле надо исключить из записи, то в его позиции поставить 0
    FieldsArr: TVarDynArray;                //массив имен полей (без алиасов и модификаторов). создается автоматически.
    Ctrls: array of TControl;               //контролы, соттвествуют именам полей, могут быть nil
                                            //автоматически находятся по названиям после префикса
    CtrlNames: TVarDynArray;
    CtrlValues: TVarDynArray;               //массив значений; загружается из бд при старте формы,
                                            //обновляется из контролов при попытке записи
                                            //для полей, для которых контролы не найдены и не заданы, останутся исходные данные,
                                            //при необходимости перед записью менять вручную
    CtrlValuesDefault: TVarDynArray;        //массив дефолтных значений контролов (или полей при остутствии контрола) (в режиме fAdd)
    CtrlVerifications: TVarDynArray;        //массив правил проверок значений контролов
    View: string;                           //таблица/вью из которой загружаем данные
    Table: string;                          //таблица, в которую записываем данные
    Sequence: string;                       //секвенция, если нужна
    Info, InfoView, InfoDelete: string;     //подсказка, для просмотра и удаления отдкельные (обычно пустая),
                                            //для остальных режимов Info. Если в потомке ее не задать, то иконки не будет
    NoCloseIfAdd: Boolean;                  //использовать галку Не закрывать окно для режима добавления
    NoSerializeCtrls: Boolean;              //если задано, то всегда возвращает '' без проверки

    Ok: Boolean;                            //статус проверки

    InChange: Boolean;                      //находимся в событии ControlOnChange (устанавливается в потомках)
    InChControlName: string;                //название текущего контрола в событии изменения
    InChControlValue: Variant;              //значение текущего контрола в событии изменения

    IdAfterInsert: Variant;                 //В процедуре Save сюдф записывается Айди, полученное при вставке записи (нужно, если требуются доп. действия в потомке после стандартной записи)

    function Prepare: Boolean; override;

    //процедура проверки верности вввода
    //проверяет только по массиву условий проверов
    //если Sender = nil то проверяет все контролы, иначе переданный
    //onInput указывает что проверка производится в момент изменения значений контрола
    //если хотя бы один контрол не валиден, выставляется для него статус Error
    //таким образом, все проверяемые контролы должны быть типа Eh
    //общий статус ОК проверяетсмя на основе встроенных статусов Eh - контролов,
    //если ОК не True, то кнопка ОК блокирется
    //процедра здесь вызывается в собылиях изменения и потери фокуса для контрола, а полная проверка
    //при показе окна и при нажатии ОК
    procedure Verify(Sender: TObject; onInput: Boolean = False); virtual;
    //дополнительная проверка, всегда вызывается в основной после всех ее проверок
    //должна скорректировать статус Error у контролов по более сложным алгоритмам, если это нужно
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; virtual;
    //обработка дополнительной проверки перед записью, если Verify вернуло Ок = True (а иначе кнопка Ок недоступна)
    //должно скорректировать Ок, если что-то не в порядке
    //если вернет в Result True, то будет выдано сообщение "Данные не корректны!", иначе
    //сама может выдать сообщение
    //может использоваться для дополнительных действий или ваывода информации перед записьбю данных
    //вызывается также и при удалении, но не при просмотре
    function VerifyBeforeSave: Boolean; virtual;
    //загружает массив CtrlValues, читая из Fields
    function Load(): Boolean; virtual;
    //сохраняет даннные
    //если не перекрывать эту процедуру
    //то будет сделана запись в таблицу значений из массива Ctrls,
    //в который данные будут установлены из найденных для соотвесттвующих полей контролов
    function Save: Boolean; virtual;
    function LoadComboBoxes: Boolean; virtual;
    //устанавливает редактируемыми или нет (Editable) все контролы из массива AConrols;
    //если последний пустой, то все контролы формы (кнопки и чекбокс повтора всегда исключаются из этой процедуры)
    procedure SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True);
    //сериализуется значения контролов формы (всех, кроме галки повтора формы)
    //если задано NoSerializeCtrls, то всегда возвращает '' без проверки
    procedure Serialize; virtual;
    //выдает доп информацуию, если показан тсатусбар:
    ///режим редактирования
    //что даннные не верны
    //что данные изменены (обновляется при уходе фокуса)
    //если стутусбар не нужен, сделать в препаре SetStatusBar('','',False);
    procedure SetStatusBarText(VisibleStatusBar: Boolean; Text: string); virtual;
  public
    { Public declarations }
  end;

var
  Form_MdiDialogTemplate: TForm_MdiDialogTemplate;

implementation

  Uses
    uErrors
    ;

{$R *.dfm}

procedure TForm_MdiDialogTemplate.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TForm_MdiDialogTemplate.Bt_OKClick(Sender: TObject);
begin
  if (Mode = fView) then begin
    Close;
    Exit;
  end;
  if Mode <> fDelete then begin
    if not Ok then
      Exit;
  end;
  if Mode <> fView then begin
    if VerifyBeforeSave then
      MyWarningMessage('Данные не корректны!');
    if not Ok then begin
      Ok := True;  //если не сделать, то в случае ошибки, если в VerifyBeforeSave ok утановлен в Folse, уже не сможем записать данные после внесения исправлений
      Exit;
    end;
  end;
  if not Save then
    Exit;
  RefreshParentForm;
  if DefFocusedControl <> nil then
    DefFocusedControl.SetFocus;
  if (not chb_NoClose.Visible) or (not chb_NoClose.Checked) then begin
    Close;
  end;
end;

function TForm_MdiDialogTemplate.VerifyBeforeSave: Boolean;
//обработка дополнительной проверки перед записью, если Verify вернуло Ок = True
//должно скорректировать Ок, если что-то не в порядке: если вернет в Result True,
//то будет выдано сообщение "Данные не корректны!"
begin
  Result := False;
end;

procedure TForm_MdiDialogTemplate.SetStatusBarText(VisibleStatusBar: Boolean; Text: string);
var
  st: string;
begin
  if not Ok then
    st := '  $0000FF Некорректные данные!  '
  else if CtrlCurrValuesStr <> CtrlBegValuesStr then
    st := ' $FF00FF Данные ' + S.Iif(Mode = fAdd, 'введены.', 'изменены.')
  else
    st := '';
  if pnl_StatusBar.Visible then begin
    SetStatusBar(Cth.FModeToCaption(Mode), st, True);
  end;
end;

procedure TForm_MdiDialogTemplate.SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True);
var
  i, j: Integer;
  c: TControl;
  va: TVarDynArray;
begin
  va := [];
  for i := 0 to High(AConrols) do
    va := va + [AConrols[i].Name];
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TControl then begin
      c := TControl(Components[i]);
      if A.PosInArray(c.Name, ['pnl_statusbar', 'lbl_StatusBar_Left', 'lbl_StatusBar_Right', 'pnl_bottom', 'bt_ok', 'bt_cancel', 'chb_NoClose'], True) >= 0 then
        Continue;
      if (Length(AConrols) = 0) or (A.PosInArray(c.Name, va, True) >= 0) then begin
        Cth.SetControlNoTEditable(c, not Editable, False, True);
        if c is TCustomdbeditEh then
          Cth.SetEhControlEditButtonState(c, Editable, Editable);
      end;
    end;
end;

function TForm_MdiDialogTemplate.Load(): Boolean;
//загрузка данных
//по уже подготовленным глобальным переменным, также в глобальную CtrlValues
//результат пока не влияет ни на что, если не был получен массив, далее проверяется и выдается сообщениеоб удаленной строке
begin
  CtrlValues := Q.QLoadToVarDynArrayOneRow(Q.QSIUDSql('s', View, Fields), [id]);
  Result := True;
end;

function TForm_MdiDialogTemplate.Save(): Boolean;
//сохранение данных
//возвращает статус удачного сохранения
//может быть перекрыта, с или без вызова inherited
var
  ChildHandled: Boolean;
  i, res: Integer;
  FieldsSave2, CtrlValues2: TVarDynArray;
  FieldsSaveNew: string;
begin
  Result := False;
  try
    for i := 0 to High(Ctrls) do
      if Ctrls[i] <> nil then
        CtrlValues[i] := S.NullIfEmpty(Cth.GetControlValue(Ctrls[i]));
  except
    on E: Exception do begin
      Application.ShowException(E);
      Exit;
    end;
  end;
  CtrlValues2:= Copy(CtrlValues);
  FieldsSave2:= A.Explode(FieldsSave, ';');
  for i:= high(FieldsSave2) downto 0 do
    if FieldsSave2[i] = '0' then begin
      Delete(FieldsSave2, i, 1);
      Delete(CtrlValues2, i, 1);
    end;
  FieldsSaveNew:= A.Implode(FieldsSave2, ';');
  res := Q.QIUD(Q.QFModeToIUD(Mode), Table, Sequence, FieldsSaveNew, CtrlValues2);
  IdAfterInsert:= res;
  Result := res <> -1;
end;

function TForm_MdiDialogTemplate.LoadComboBoxes: Boolean;
//перекрываем для загрузки дополнительных данных, например комбобоксов
//вызывается после загрузки основных данных
begin
  Result := True;
end;

procedure TForm_MdiDialogTemplate.Serialize;
//
begin
  if NoSerializeCtrls then begin
    CtrlCurrValuesStr := '';
    Exit;
  end;
  CtrlCurrValuesStr := Cth.SerializeControlValuesArr2(Cth.GetControlValuesArr2(Self, nil, [], ['chb_NoClose']))
end;

procedure TForm_MdiDialogTemplate.ControlOnChange(Sender: TObject);
//событие изменения данных контрола
begin
  //выход если в процедуре загрузки
  if InPrepare then
    Exit;
  //проверим, признак что в этом событии проверка
  Serialize;
  Verify(Sender, True);
end;

//уход фокуса с контрола
procedure TForm_MdiDialogTemplate.ControlOnExit(Sender: TObject);
begin
  //выход если в процедуре загрузки
  if InPrepare then
    Exit;
  //проверим
  Verify(Sender);
end;

procedure TForm_MdiDialogTemplate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(lbl_StatusBar_Left);
  FreeAndNil(lbl_StatusBar_Right);
  inherited;
end;

procedure TForm_MdiDialogTemplate.FormShow(Sender: TObject);
begin
  inherited;
  pnl_Bottom.Width := Self.ClientWidth;
  Bt_Cancel.Left := pnl_Bottom.Width - Bt_Cancel.Width - 5;
  Bt_Ok.Left := pnl_Bottom.Width - Bt_Cancel.Width - 5 - Bt_Ok.Width - 5;
  Bt_Cancel.Top := 2;
  Bt_Ok.Top := 2;
  Img_Info.Left := 5;
  Img_Info.Top := 2;
  //приходится помещать сюда
  //если режим Добавление записи, то при вызове из Prepare происходит смазываение правого лейбла, при режиме редактирования все нормально
  //а для первого показа нам статусбар нужен
  SetStatusBarText(True, '');
end;

{
procedure TForm_MdiDialogTemplate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Settings.SaveWindowPos(Self, FormDoc);
end;}

procedure TForm_MdiDialogTemplate.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

function TForm_MdiDialogTemplate.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result := True;
end;

procedure TForm_MdiDialogTemplate.Verify(Sender: TObject; onInput: Boolean = False);
//проверка правильности данных
//передается контрол для проверки, или нил - проверить все
//и признак что проверка при вводе данных в контроле (в событии onChange)
var
  i, j, s: Integer;
  c: TControl;
  ok1: Boolean;
begin
  //я просмотра и удаления всегда Ок
  if (Mode = fView) or (Mode = fDelete) then begin
    Ok := True;
    Bt_Ok.Enabled := Ok;
    Exit;
  end;
  if Sender = nil then //проверим все DbEh
    Cth.VerifyAllDbEhControls(Self)
  else //проверим текущий
    Cth.VerifyControl(TControl(Sender), onInput);
  //дополнительная проверка (для того, что не покрывается условиями проверки в массиве)
  //должна отметить SetErrorMarker для контролов по более сложным алгоритмам, не охватываемым заданным правилам в массиве
  VerifyAdd(Sender, onInput);
  //получим статус проверки и визуализируем
  Ok := Cth.VerifyVisualise(Self);
  //статус кнопки Ок
  Bt_Ok.Enabled := Ok;
  if not InPrepare then
    SetStatusBarText(True, '');
end;

function TForm_MdiDialogTemplate.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
begin
  Result := False;
  //проверим блокировку, выйдем если нельзя взять (при попытке редактирования уйдет в просмотр, при удалении - выход)
  if FormDbLock = fNone then
    Exit;
  //здесь потомок заполняет поля данных, дефолтные значения, параметры проверки, загружает комбобоксы и дополнительные данные.
  //поля для записи по умолчанию те же что для чтения
  if Length(FieldsSave) = 0 then
    FieldsSave := Fields;
  if Table = '' then
    Table := View;
  //создадим массив полей без модификаторов и алиасовж
  FieldsArr := A.ExplodeV(Fields, ';');
  //создадим массив контролов, если он не был создан ранее вручную
  if Length(Ctrls) = 0 then begin
    SetLength(Ctrls, Length(FieldsArr));
    for i := 0 to High(FieldsArr) do
      Ctrls[i] := nil;
  end;
  //заполним массив контролов (позиции не равные nil), контролами, соответствующисми названию поля
  for i := 0 to High(FieldsArr) do begin
    FieldsArr[i] := s.GetDBFieldNameFromSt(FieldsArr[i]);
    if (Ctrls[i] = nil) then
      Ctrls[i] := Cth.FindControlByFieldName(Self, FieldsArr[i]);
  end;
  CtrlNames := [];
  for i := 0 to High(Ctrls) do
    if (Ctrls[i] <> nil) then
      CtrlNames := CtrlNames + [Ctrls[i].Name];
  //прочитаем строку из БД, или, если режим добавления, возьмем начальные значения


  if Mode = fAdd then
    CtrlValues := CtrlValuesDefault
  else    //только читает:     CtrlValues := Q.QLoadToVarDynArrayOneRow(Q.QSIUDSql('s', View, Fields), [id]);
    Load;
  //если строка не найдена, выдадим сообщение и выйдем
  if Length(CtrlValues) = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;

  //в целях отладки (в CtrlNames не будет тех полей бд, для которых нет контролов)
  i:=Length(FieldsArr);
  if (i <> Length(Ctrls)){or(i <> Length(CtrlNames))}or(i <> Length(CtrlValues))or(i <> Length(CtrlValuesDefault))  then begin
    raise Exception.Create('TForm_MdiDialogTemplate.Prepare - не совпадают длины массивов задания параметров');
    Exit;
  end;

  //загрузим комбобоксы и сделаем другие кастомные действия
  if not LoadComboBoxes then
    Exit;
  try
  for i := 0 to High(Ctrls) do
    Cth.SetControlValue(Ctrls[i], CtrlValues[i]);
  except
    on E: Exception do begin
      Errors.SetParam('', 'При установке значения '+ InttoStr(i) + ' - *');
      Application.ShowException(E);
      Exit;
    end;
  end;
  //параметры проверки контролов установив для них
  Cth.SetControlsVerification(Ctrls, CtrlVerifications);
   //события onCahange и  onExit для всех dbeh контролов  (True - + onclick для chbeh)
  Cth.SetControlsOnChange(Self, ControlOnChange, True);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //заголовок формы и кнопки в зависимости от режима
  Cth.SetDialogForm(Self, Mode, Caption);
  //доступность контролов, в зависимости от режима, кроме дат начала/окончания - всегда дисейбл
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  //Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  Cth.SetInfoIcon(Img_Info, s.Decode([Mode, fView, InfoView, fDelete, InfoDelete, Info]), 20);
  //не работает, иконка выравнивается по верхнему краю
  {Img_Info.Align:=alNone;
  Img_Info.Top:=5;
  Img_Info.Left:=3;}
  Serialize;
  CtrlBegValuesStr:= CtrlCurrValuesStr;
  SetStatusBar('', '', True);
  Verify(nil);
  pnl_Bottom.Align := alNone;
//  pnl_Bottom.Top:=Self.ClientHeight - StatusBar.Height - pnl_Bottom.Height;
  pnl_Bottom.Align := alBottom;
  chb_NoClose.Visible := NoCloseIfAdd and (Mode in [fAdd, fCopy]);
  Result := True;
end;

end.

