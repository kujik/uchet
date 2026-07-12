unit uFrmBasicMdi;

{
  Базовый класс для всех MDI и диалоговых окон приложения.
  Предоставляет общую функциональность: панель кнопок, статусбар,
  управление данными, проверку ввода, сериализацию, блокировки в БД.
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, DBGridEhToolCtrls, DBCtrlsEh, TypInfo,
  MemTableDataEh, Db, ADODB, DataDriverEh, GridsEh, DBAxisGridsEh, DBGridEh,
  Math, Vcl.StdCtrls, Buttons, uLabelColors, uData, uString, uFields,
  Generics.Collections; // <-- добавлено для TDictionary

{$R *.dfm}

const
  mycHiddenFormLeft = -10000; // смещение для скрытых форм

type
  TCustomFormMy = class(TCustomForm);

  // процедура для установки значений контролов при открытии диалога
  TSetControlsProc = procedure(ASelf: TObject; AControlValues: TVarDynArray);

  // стиль размещения панели кнопок
  TMDIDlgPanelStyle = (
    dpsNone,          // без панели
    dpsBottomRight,   // внизу справа
    dpsBottomLeft,    // внизу слева
    dpsTopRight,      // вверху справа
    dpsTopLeft        // вверху слева
  );

  // режим отображения статусбара
  TMDIStatusMode = (
    stbmNone,        // не показывать
    stbmCustom,      // произвольный текст
    stbmGrid,        // информация о гриде (кол-во строк, фильтр)
    stbmDialog       // режим работы, ошибки, изменение данных
  );

  // реакция на закрытие формы при изменённых данных
  TMDICloseQuery = (
    cqNone,   // закрыть без предупреждения
    cqYN,     // спросить "Данные изменены. Закрыть? (Y/N)"
    cqYNC     // спросить "Сохранить? (Да/Нет/Отмена)"
  );

  // результат работы формы (для диалогов)
  TMDIResult = record
    ModalResult: Integer;       // ModalResult формы
    Data: Variant;              // одиночное значение
    DataA: TVarDynArray2;       // массив значений
  end;

  // опции поведения формы (устанавливаются в Prepare потомка)
  TMDIOpt = record
    DlgPanelStyle: TMDIDlgPanelStyle;        // стиль панели кнопок
    StatusBarMode: TMDIStatusMode;           // режим статусбара
    DlgButtonsM: TVarDynArray2;              // кастомное задание кнопок на основной панели. автоматические в зависимости от режива в этом случае не создаются
    DlgButtonsL: TVarDynArray2;              // кастомные кнопки слева
    DlgButtonsR: TVarDynArray2;              // кастомные кнопки справа
    UseChbNoClose: Boolean;                  // показывать чекбокс "Не закрывать" (для fAdd/fCopy)
    AutoAlignControls: Boolean;              // автоматически выравнивать контролы в pnlFrmClient
    ControlsWoAligment: TControlArray;       // контролы, не участвующие в автовыравнивании
    AutoControlDataChanged: Boolean;         // автоматически отслеживать изменение данных в контролах
    RequestWhereClose: TMDICloseQuery;       // реакция на закрытие
    DefFocusedControl: TWinControl;          // контрол для установки фокуса при открытии
    NoSerializeCtrls: Boolean;               // отключить сериализацию значений контролов
    RefreshParent: Boolean;                  // обновить родительскую форму при нажатии Ок
    NoDbLock: Boolean;                       // не использовать блокировку в БД
    InfoArray: TVarDynArray2;                // информация для иконки справки
  end;

  TFrmBasicMdi = class(TForm)
    pnlFrmMain: TPanel;
    pnlFrmClient: TPanel;
    pnlFrmBtns: TPanel;
    bvlFrmBtnsTl: TBevel;
    bvlFrmBtnsB: TBevel;
    pnlFrmBtnsContainer: TPanel;
    pnlFrmBtnsMain: TPanel;
    pnlFrmBtnsChb: TPanel;
    chbNoclose: TCheckBox;
    pnlFrmBtnsR: TPanel;
    pnlFrmBtnsInfo: TPanel;
    imgFrmInfo: TImage;
    pnlFrmBtnsL: TPanel;
    pnlFrmBtnsC: TPanel;
    pnlStatusBar: TPanel;
    lblStatusBarR: TLabel;
    lblStatusBarL: TLabel;
    tmrAfterCreate: TTimer;

    // события формы
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrAfterCreateTimer(Sender: TObject);
  private
    FFormDoc: string;               // идентификатор документа
    FMode: TDialogType;             // режим работы (fView, fEdit, fAdd, fCopy, fDelete)
    FParentForm: TComponent;        // родительская форма
    FParentControl: TComponent;     // родительский контрол
    FID: Variant;                   // идентификатор записи
    FAddParam: Variant;             // дополнительные параметры
    FMyFormOptions: TMyFormOptions; // опции поведения формы
    FModuleId: Integer;             // номер модуля
    FTextLeft, FTextRight: Variant; // текст в статусбаре (левый/правый)
    FStatusBarHeight: Integer;      // высота статусбара
    FInSetStatusBar: Boolean;       // флаг рекурсивного обновления статусбара
    FPreventShow: Boolean;          // запрет показа формы
    FToLoadData: Boolean;           // нужно ли загружать данные
    FDlgPanelMinWidth: Integer;     // минимальная ширина панели кнопок
    FWinSizeCorrected: Boolean;     // была ли скорректирована форма
    FCtrlBegValuesStr, FCtrlCurrValuesStr: string; // сериализованные значения контролов
    FTab0Control: TWinControl;      // контрол, получающий фокус при Tab
    FHasError: Boolean;             // наличие ошибки в данных
    FPanelOrderCache: TDictionary<TPanel, TControlArray>; // кеш порядка контролов для панелей

    procedure BuildPanelOrder(APanel: TPanel);
    function GetPanelOrder(APanel: TPanel): TControlArray;
    function ArrayContainsId(const AArray: TVarDynArray; AId: Integer): Boolean;
    function ArrayContainsName(const AArray: TVarDynArray; const AName: string): Boolean;
    procedure SetPanelControlsVisibility(APanel: TPanel; const ShowIDs, HideIDs: TVarDynArray);
    procedure ArrangeAllPanels;

    procedure HandleCheckBoxRadioGroup(Sender: TObject);
    procedure ClearCheckBoxGroup(GroupStartTag, GroupEndTag: Integer); overload;
    procedure ClearCheckBoxGroup; overload;
    procedure DisableCheckBoxGroup(GroupStartTag, GroupEndTag: Integer; Disabled: Boolean); overload;
    procedure DisableCheckBoxGroup(Disabled: Boolean); overload;

    procedure SetError(Value: Boolean);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
  protected
    FPrepareResult: Boolean;            // результат Prepare
    FControlVerifycations: TVarDynArray; // правила проверки полей [контрол, правило, ...]
    FOpt: TMDIOpt;                      // опции формы
    FPrevLeft, FPrevTop, FPrevWidth, FPrewHeight: Integer; // для восстановления размеров
    FIsMaximized: Boolean;
    FInMaxMin: Boolean;
    FInBtOkClick: Boolean;
    FInBtCancelClick: Boolean;
    FInPrepare: Boolean;
    FInControlOnChaange: Boolean;
    FAfterFormShow: Boolean;
    FLockInDB: TDialogType;                // была ли блокировка в БД
    FErrorMessage: string;                 // сообщение об ошибке (блокирует Ок)
    FIsDataChanged: Boolean;               // данные изменены
    FWHBounds: TCoord;                     // ограничения размеров формы
    FWHCorrected: TCoord;                  // скорректированные размеры клиентской части
    FDisableClose: Boolean;                // запрет закрытия
    FQueryCloseMessage: string;            // сообщение при закрытии с изменениями
    btnOk: TBitBtn;                        // кнопка Ок
    btnCancel: TBitBtn;                    // кнопка Отмена
    FAllreadyCreated: Boolean;             // признак уже созданного экземпляра
    F: TFields;                            // объект для работы с полями формы
    FFormNotCreatedByApplication: Boolean; // форма создана не через Application
    FFormResult: TMDIResult;               // результат работы формы

    property HasError: Boolean read FHasError write SetError;
    property FormResult: TMDIResult read FFormResult write FFormResult;

    // конструктор (перекрыт)
    constructor Create(AOwner: TComponent; ADoc: string;
      AMyFormOptions: TMyFormOptions; AMode: TDialogType;
      AID: Variant; AAddParam: Variant; AControlValues: TVarDynArray;
      APSetControls: pointer = nil); reintroduce; virtual;

    // вызывается после создания формы (в конструкторе)
    procedure AfterCreate; virtual;
    // вызывается таймером после отображения формы
    procedure AfterStart; virtual;
    // завершение без показа формы (в конструкторе)
    procedure ExitWithoutShow; virtual;
    // вызывается при активации формы
    procedure AfterFormActivate; virtual;
    // подготовка формы (загрузка данных, настройка) – перекрывается
    function Prepare: Boolean; reintroduce; virtual;
    // подготовка динамически созданной формы с предустановками
    function PrepareCreatedForm(AOwner: TObject; AFormDoc, ACaption: string;
      AMode: TDialogType; AID: Variant; AInfoArray: TVarDynArray2;
      AOptions: TMyFormOptions = [myfoModal, myfoDialog, myfoDialogButtonsB];
      AAutoAlign: Boolean = True): Boolean;
    // выполняется после Prepare
    procedure AfterPrepare; virtual;
    // обновить родительскую форму
    function RefreshParentForm: Boolean;
    // скорректировать размеры формы по FWHCorrected
    procedure CorrectFormSize;
    // настроить иконку справки
    procedure SetMainInfoIcon;
    // центрировать форму по родительской
    procedure CenteringByParent;
    // запросить блокировку записи в БД
    function FormDbLock(msg: string = '*|*'): TDialogType;
    // проверка всех фреймов TFrMyPanelCaption на наличие ошибок в их родительских панелях
    procedure CheckPanelCaptionErrors;
    // проверка гридов
    procedure VerirfyGrids(Sender: TObject; var AHasError: Boolean; var AErrorSt: string; var AIsChanged: Boolean);
    // проверка всех фреймов TFrMyPanelCaption на наличие ошибок
    procedure VerifyPanels(Sender: TObject; var AHasError: Boolean; var AErrorSt: string; var AIsChanged: Boolean);
    // дополнительная проверка (перекрывается в потомках)
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; virtual;
    // проверка перед сохранением
    procedure VerifyBeforeSave; virtual;
    // сохранение данных (перекрывается)
    function Save: Boolean; virtual;
    // обработчик изменения данных в контролах
    procedure ControlOnChangeEvent(Sender: TObject); virtual;
    procedure ControlOnChange(Sender: TObject); virtual;
    procedure ControlOnEnter(Sender: TObject); virtual;
    procedure ControlOnExit(Sender: TObject); virtual;
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean); virtual;
    procedure ControlClick(Sender: TObject); virtual;
    procedure ControlDblClick(Sender: TObject); virtual;
    procedure ControlKeyPress(Sender: TObject; var Key: Char); virtual;    procedure btnOkClick(Sender: TObject); virtual;
    procedure btnCancelClick(Sender: TObject); virtual;
    // обработчик клика по кнопкам в панели кнопок
    procedure btnClick(Sender: TObject); virtual;
    // обработчик клика по кнопкам в клиентской области
    procedure btnClientClick(Sender: TObject); virtual;
    // обработчик клика по встроенным кнопкам в Eh-контролах
    procedure EditButtonsClick(Sender: TObject; var Handled: Boolean); virtual;
    // получение размеров и позиции формы (для восстановления)
    procedure GetFormLTWH;
    // получение значения контрола по имени
    function GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant; overload;
    function GetControlValue(Control: TControl; NullIfEmpty: Boolean = False): Variant; overload;
    function GetControlValues(ControlNames: TVarDynArray; NullIfEmpty: Boolean = False): TVarDynArray; overload;
    function GetControlValues(Controls: TControlArray; NullIfEmpty: Boolean = False): TVarDynArray; overload;
    // установка значения контрола по имени
    procedure SetControlValue(ControlName: string; const Value: Variant); overload;
    // установка значения контрола по ссылке
    procedure SetControlValue(Control: TControl; const Value: Variant); overload;
    // массовая установка значений по именам контролов
    procedure SetControlValues(ControlNames: TVarDynArray; const Values: TVarDynArray); overload;
    // массовая установка значений по ссылкам на контролы
    procedure SetControlValues(Controls: TControlArray; const Values: TVarDynArray); overload;
    // установка одного значения на несколько контролов (по именам)
    procedure SetControlValues(ControlNames: TVarDynArray; const Value: Variant); overload;
    // установка одного значения на несколько контролов (по ссылкам)
    procedure SetControlValues(Controls: TControlArray; const Value: Variant); overload;    // установить события и проверки для контролов
    // установка событий
    procedure SetControlEvents;
    // установка дополнительных событий (OnClick, OnDblClick, OnKeyPress)
    procedure SetControlEventsEx; virtual;    // установить редактируемость контролов
    procedure SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True;  Disabled: Boolean = False; Parent: TControl = nil);
    procedure SetControlsEditableForParent(AConrols: array of TControl; Editable: Boolean = True; Disabled: Boolean = False; Parent: TControl = nil);
    // сериализация/десериализация значений контролов
    procedure Serialize; virtual;
    // обновить панель кнопок
    procedure RefreshDlgPanel;
    // обновить статусбар
    procedure RefreshStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
    // проверить видимость скроллбара
    function IsScrollBarVisible(isVert: Boolean = True): Boolean;
    // инициализация новой формы (переопределение)
    procedure InitializeNewForm; override;

    // деструктор формы
    destructor Destroy;
    // показать форму в зависимости от опций
    class procedure ShowForm(AForm: TForm);
    // показать как MDI-дочернюю
    procedure ShowFormAsMdi;
    // действия после закрытия формы (для немодальных)
    class procedure AfterFormClose(AForm: TForm);
    // проверка, можно ли создать новый экземпляр (с учётом myfoMultiCopy)
    class function TestMultiInstances(AFormDoc: string;
      AMyFormOptions: TMyFormOptions; AMode: TDialogType;
      AID: Variant): Boolean;
    // поиск компонента по имени и суффиксу
    function FindCmp(AParent: TWinControl; AControlName: string; ASuffix: Integer = 0): TComponent;
  public
    // свойства для доступа к данным
    property ModuleId: Integer read FModuleId;
    property FormDoc: string read FFormDoc write FFormDoc;
    property Mode: TDialogType read FMode write FMode;
    property ParentForm: TComponent read FParentForm;
    property ParentControl: TComponent read FParentControl;
    property ID: Variant read FID write FID;
    property AddParam: Variant read FAddParam;
    property MyFormOptions: TMyFormOptions read FMyFormOptions write FMyFormOptions;
    property IsDataChanged: Boolean read FIsDataChanged;

    // проверка ввода
    procedure Verify(Sender: TObject; onInput: Boolean = False); virtual;
    // глобальное событие (для расширения)
    procedure GlobalEvent(AEvent: Integer); virtual;

    // методы управления видимостью кнопок и пересчёта положения панелей
    procedure ArrangeControlsOnPanel(APanel: TPanel);                                  // расстановка контролов на панели с центрированием
    procedure SetButtonsVisibilityAndArrange(const ShowIDs, HideIDs: TVarDynArray); overload;   // для всех панелей (Main, L, R, C)
    procedure SetButtonsVisibilityAndArrange(APanelName: string; const ShowIDs, HideIDs: TVarDynArray); overload; // для конкретной панели по имени

    // статические методы для создания и отображения формы
    class function Show(AOwner: TComponent; ADoc: string;
      AMyFormOptions: TMyFormOptions; AMode: TDialogType;
      AID: Variant; AAddParam: Variant): TMDIResult; virtual;
    class function ShowModal2(AOwner: TComponent; ADoc: string;
      AMyFormOptions: TMyFormOptions; AMode: TDialogType;
      AID: Variant; AAddParam: Variant): TMDIResult; virtual;
  end;

var
  FrmBasicMdi: TFrmBasicMdi;

implementation

uses
  uWindows, uSettings, uFrmMain, uDBOra, uForms, uMessages, uFrDbGridEh, uWaitForm, uFrMyPanelCaption;

{$R *.dfm}

//-----------------------------------------------------------------------------
// Вспомогательные процедуры модуля
//-----------------------------------------------------------------------------

function FindControl(AParent: TWinControl; const AName: string): TControl;
// поиск контрола по имени среди дочерних контролов (рекурсивно)
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to AParent.ControlCount - 1 do
    if S.CompareStI(AParent.Controls[i].Name, AName) then begin
      Result := AParent.Controls[i];
      Exit;
    end;
end;

procedure SetPanelsAlign(AParent: TWinControl; const AVertical: Boolean = False);
// выравнивание панелей в контейнере по горизонтали.
// порядок панелей указывается тегами: положительные – слева (начиная с 1),
// отрицательные – справа (самая правая с тегом -1),
// с тегом 0 – alClient (такая должна быть одна или ни одной).
// AVertical пока не обрабатывается.
var
  i: Integer;
  Panel: TPanel;
  PanelInfo: TVarDynArray2;
  CurrentPos, LeftPos: Integer;
begin
  PanelInfo := [];
  for i := AParent.ControlCount - 1 downto 0 do
    if AParent.Controls[i] is TPanel then begin
      Panel := TPanel(AParent.Controls[i]);
      PanelInfo := PanelInfo + [[i, Panel.Tag, Panel.Name]];
      Panel.Align := alNone;
      Panel.Anchors := [];
    end;

  A.VarDynArray2Sort(PanelInfo, 0);
  A.VarDynArraySort(PanelInfo, 1);

  LeftPos := 0;
  CurrentPos := 0;
  for i := 0 to High(PanelInfo) do
    if PanelInfo[i, 1] > 0 then begin
      Panel := TPanel(AParent.Controls[PanelInfo[i][0]]);
      Panel.Left := CurrentPos;
      Panel.Align := alLeft;
      CurrentPos := Panel.Left + Panel.Width;
    end;

  LeftPos := CurrentPos;
  CurrentPos := AParent.Width;
  for i := High(PanelInfo) downto 0 do
    if PanelInfo[i, 1] < 0 then begin
      Panel := TPanel(AParent.Controls[PanelInfo[i][0]]);
      Panel.Left := CurrentPos - Panel.Width - 10;
      Panel.Align := alRight;
      CurrentPos := Panel.Left;
    end;

  for i := 0 to High(PanelInfo) do
    if PanelInfo[i, 1] = 0 then begin
      Panel := TPanel(AParent.Controls[PanelInfo[i][0]]);
      Panel.Left := LeftPos;
      Panel.Align := alClient;
    end;
end;

procedure VertAlignCtrls(AParent: TWinControl);
// вертикальное центрирование контролов в родителе
var
  i: Integer;
begin
  for i := AParent.ComponentCount - 1 downto 0 do
    if AParent.Components[i] is TBitBtn then
      TBitBtn(AParent.Components[i]).Top := (AParent.Height - TBitBtn(AParent.Components[i]).Height) div 2;

  for i := AParent.ControlCount - 1 downto 0 do
    AParent.Controls[i].Top := (AParent.Height - AParent.Controls[i].Height) div 2;
end;

procedure SortControlsByLeft(var AControls: TControlArray);
var
  i, j: Integer;
  Temp: TControl;
begin
  for i := Low(AControls) to High(AControls) - 1 do
    for j := i + 1 to High(AControls) do
      if AControls[i].Left > AControls[j].Left then
      begin
        Temp := AControls[i];
        AControls[i] := AControls[j];
        AControls[j] := Temp;
      end;
end;

//-----------------------------------------------------------------------------
// Методы TFrmBasicMdi
//-----------------------------------------------------------------------------

procedure TFrmBasicMdi.BuildPanelOrder(APanel: TPanel);
var
  i: Integer;
  Arr: TControlArray;
begin
  SetLength(Arr, APanel.ControlCount);
  for i := 0 to APanel.ControlCount - 1 do
    Arr[i] := APanel.Controls[i];
  SortControlsByLeft(Arr);
  FPanelOrderCache.AddOrSetValue(APanel, Arr);
end;

function TFrmBasicMdi.GetPanelOrder(APanel: TPanel): TControlArray;
begin
  if not FPanelOrderCache.TryGetValue(APanel, Result) then
  begin
    BuildPanelOrder(APanel);
    FPanelOrderCache.TryGetValue(APanel, Result);
  end;
end;

function TFrmBasicMdi.ArrayContainsId(const AArray: TVarDynArray; AId: Integer): Boolean;
// проверяет, содержится ли число AId в массиве вариантов
var
  V: Variant;
begin
  Result := False;
  for V in AArray do
    if (S.VarType(V) = varInteger) and (Integer(V) = AId) then
      Exit(True);
end;

function TFrmBasicMdi.ArrayContainsName(const AArray: TVarDynArray; const AName: string): Boolean;
// проверяет, содержится ли строка AName в массиве вариантов
var
  V: Variant;
begin
  Result := False;
  for V in AArray do
    if (S.VarType(V) = varString) and (string(V) = AName) then
      Exit(True);
end;

procedure TFrmBasicMdi.SetPanelControlsVisibility(APanel: TPanel; const ShowIDs, HideIDs: TVarDynArray);
// устанавливает видимость контролов на панели в соответствии с массивами ShowIDs и HideIDs,
// обрабатывает разделители (оставляет только первый из подряд идущих), затем пересчитывает расположение.
var
  Order: TControlArray;
  Ctrl: TControl;
  LastWasBevel: Boolean;
begin
  if APanel = nil then Exit;
  Order := GetPanelOrder(APanel);

  // 1. установка видимости по переданным массивам
  for Ctrl in Order do
  begin
    if Ctrl is TBitBtn then
    begin
      if ArrayContainsId(ShowIDs, Ctrl.Tag) then
        Ctrl.Visible := True
      else if ArrayContainsId(HideIDs, Ctrl.Tag) then
        Ctrl.Visible := False;
      // иначе оставляем как есть
    end
    else if Ctrl is TBevel then
    begin
      // разделители пока не трогаем
    end
    else
    begin
      // другие контролы (чекбоксы, панели и т.д.) – управляем по имени
      if ArrayContainsName(ShowIDs, Ctrl.Name) then
        Ctrl.Visible := True
      else if ArrayContainsName(HideIDs, Ctrl.Name) then
        Ctrl.Visible := False;
    end;
  end;

  // 2. обработка разделителей: если подряд идут несколько Bevel, оставляем только первый
  LastWasBevel := False;
  for Ctrl in Order do
  begin
    if Ctrl is TBevel then
    begin
      if LastWasBevel then
        Ctrl.Visible := False
      else
        LastWasBevel := True;
    end
    else
    begin
      // если есть видимый не-Bevel контрол, сбрасываем флаг для последующих разделителей
      if Ctrl.Visible then
        LastWasBevel := False;
    end;
  end;

  // 3. расстановка и центрирование
  ArrangeControlsOnPanel(APanel);
end;

procedure TFrmBasicMdi.ArrangeControlsOnPanel(APanel: TPanel);
// расставляет видимые контролы на панели по горизонтали с отступом MY_FORMPRM_BTN_H_MARGIN
// и центрирует их по вертикали внутри панели, кроме разделителей bvlV*
var
  Order: TControlArray;
  Ctrl: TControl;
  X, Y: Integer;
  BevelHeight: Integer;
begin
  if APanel = nil then
    Exit;
  Order := GetPanelOrder(APanel);
  X := MY_FORMPRM_BTN_H_MARGIN;
  for Ctrl in Order do
    if Ctrl.Visible then begin
      // специальная обработка вертикальных разделителей bvlV*
      if (Ctrl is TBevel) and (Pos('bvlV', Ctrl.Name) = 1) then begin
        Ctrl.Width := 2;
        BevelHeight := APanel.Height - 8; // отступы 4 сверху и 4 снизу
        if BevelHeight < 2 then
          BevelHeight := 2;
        Ctrl.Height := BevelHeight;
        Ctrl.Top := 4;
      end
      else begin
        // вертикальное центрирование для остальных контролов
        Y := (APanel.Height - Ctrl.Height) div 2;
        if Y < 0 then
          Y := 0;
        Ctrl.Top := Y;
      end;
      Ctrl.Left := X;
      X := X + Ctrl.Width + MY_FORMPRM_BTN_H_MARGIN;
    end;
  // устанавливаем ширину панели
  if X > MY_FORMPRM_BTN_H_MARGIN then
    APanel.Width := X
  else
    APanel.Width := 0;
end;
procedure TFrmBasicMdi.ArrangeAllPanels;
// пересчёт расположения контролов на всех основных панелях
begin
  ArrangeControlsOnPanel(pnlFrmBtnsMain);
  ArrangeControlsOnPanel(pnlFrmBtnsL);
  ArrangeControlsOnPanel(pnlFrmBtnsR);
  ArrangeControlsOnPanel(pnlFrmBtnsC);
end;

procedure TFrmBasicMdi.SetButtonsVisibilityAndArrange(const ShowIDs, HideIDs: TVarDynArray);
// публичный метод для всех панелей (Main, L, R, C)
var
  Panels: array[0..3] of TPanel;
  P: TPanel;
begin
  Panels[0] := pnlFrmBtnsMain;
  Panels[1] := pnlFrmBtnsL;
  Panels[2] := pnlFrmBtnsR;
  Panels[3] := pnlFrmBtnsC;
  for P in Panels do
    if Assigned(P) then
      SetPanelControlsVisibility(P, ShowIDs, HideIDs);
end;

procedure TFrmBasicMdi.SetButtonsVisibilityAndArrange(APanelName: string; const ShowIDs, HideIDs: TVarDynArray);
// публичный метод для конкретной панели по имени
var
  P: TPanel;
begin
  P := FindComponent(APanelName) as TPanel;
  if Assigned(P) then
    SetPanelControlsVisibility(P, ShowIDs, HideIDs)
  else
    raise Exception.CreateFmt('Панель "%s" не найдена', [APanelName]);
end;

{
обработка чекбоксов
}


procedure TFrmBasicMdi.HandleCheckBoxRadioGroup(Sender: TObject);
// обработка чекбоксов, работающих как радиокнопки, с возможностью снятия всех
// теги от CHECKBOX_GROUP_START_TAG до CHECKBOX_GROUP_END_TAG (-20..-1)
// поддиапазон CHECKBOX_RADIO_GROUP_START_TAG..CHECKBOX_GROUP_END_TAG (-10..-1) - радио (нельзя снять все)
// поддиапазон CHECKBOX_GROUP_START_TAG..CHECKBOX_RADIO_GROUP_START_TAG-1 (-20..-11) - можно снять все
var
  i: Integer;
begin
  if not (Sender is TDBCheckBoxEh) then Exit;
  if (TControl(Sender).Tag < CHECKBOX_GROUP_START_TAG) or (TControl(Sender).Tag > CHECKBOX_GROUP_END_TAG) then Exit;
  // сначала снимаем все чекбоксы в группе
  for i := 0 to ComponentCount - 1 do
    if (Components[i] is TDBCheckBoxEh) and (Sender <> Components[i]) and
       (TControl(Components[i]).Tag >= CHECKBOX_GROUP_START_TAG) and
       (TControl(Components[i]).Tag <= CHECKBOX_GROUP_END_TAG) then
      TDBCheckBoxEh(Components[i]).Checked := False;
  // если тег в диапазоне радио (нельзя снять все), то если после снятия чекбокс не выбран,
  // восстанавливаем его в True и выходим
  if (TControl(Sender).Tag >= CHECKBOX_RADIO_GROUP_START_TAG) and
     (TControl(Sender).Tag <= CHECKBOX_GROUP_END_TAG) and
     (not TDBCheckBoxEh(Sender).Checked) then
  begin
    TDBCheckBoxEh(Sender).Checked := True;
    FInControlOnChaange := False; // предотвращаем повторный вход
    Exit;
  end;
end;

procedure TFrmBasicMdi.ClearCheckBoxGroup(GroupStartTag, GroupEndTag: Integer);
// снять все чекбоксы в указанном диапазоне тегов
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
    if (Components[i] is TDBCheckBoxEh) and
       (TControl(Components[i]).Tag >= GroupStartTag) and
       (TControl(Components[i]).Tag <= GroupEndTag) then
      TDBCheckBoxEh(Components[i]).Checked := False;
end;

procedure TFrmBasicMdi.ClearCheckBoxGroup;
begin
  ClearCheckBoxGroup(CHECKBOX_GROUP_START_TAG, CHECKBOX_GROUP_END_TAG);
end;

procedure TFrmBasicMdi.DisableCheckBoxGroup(GroupStartTag, GroupEndTag: Integer; Disabled: Boolean);
// отключить/включить чекбоксы в указанном диапазоне тегов
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
    if (Components[i] is TDBCheckBoxEh) and
       (TControl(Components[i]).Tag >= GroupStartTag) and
       (TControl(Components[i]).Tag <= GroupEndTag) then
      TDBCheckBoxEh(Components[i]).Enabled := not Disabled;
end;

procedure TFrmBasicMdi.DisableCheckBoxGroup(Disabled: Boolean);
begin
  DisableCheckBoxGroup(CHECKBOX_GROUP_START_TAG, CHECKBOX_GROUP_END_TAG, Disabled);
end;

// ----- остальные методы -----

procedure TFrmBasicMdi.RefreshStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
// обновление статусбара: установка текста (левый/правый) и видимости.
// лейблы колоризованные, параметры могут быть массивом или строкой.
// при изменении видимости высота формы корректируется.
var
  b: Boolean;
  st: string;
begin
  if not pnlStatusBar.Visible then Exit;
  FInSetStatusBar := True;
  pnlStatusBar.Visible := (FOpt.StatusBarMode <> stbmNone);
  pnlStatusBar.BevelInner := bvNone;
  pnlStatusBar.BevelOuter := bvNone;
  pnlStatusBar.Color := cl3DLight;

  repeat
    b := (pnlStatusBar.Visible = AVisible) or (FStatusBarHeight = -1);
    if FStatusBarHeight = -1 then
      FStatusBarHeight := pnlStatusBar.Height;

    if not b then
      Self.ClientHeight := Self.ClientHeight + S.IIf(AVisible, FStatusBarHeight, -FStatusBarHeight);
    if FInPrepare and not AVisible then
      Self.ClientHeight := Self.ClientHeight - FStatusBarHeight;
    if AVisible then
      pnlStatusBar.Height := FStatusBarHeight
    else
      pnlStatusBar.Height := 0;
    if AVisible then
      pnlStatusBar.Top := 1000
    else
      pnlStatusBar.Top := Self.ClientHeight - pnlStatusBar.Height;
    if not pnlStatusBar.Visible then Break;

    if FAfterFormShow or FInPrepare then begin
      if FOpt.StatusBarMode = stbmDialog then begin
        if HasError then
          TextRight := '$0000FFНекорректные данные!'
        else if FIsDataChanged then
          TextRight := '$FF00FFДанные ' + S.Iif(Mode = fAdd, 'введены.', 'изменены.')
        else
          TextRight := '';
        TextLeft := Cth.FModeToCaption(Mode);
      end;

      // если передан '*', оставляем предыдущее значение
      if TextLeft = '*' then
        TextLeft := FTextLeft;
      if TextRight = '*' then
        TextRight := FTextRight;

      if (VarToStr(TextLeft) = S.NSt(FTextLeft)) and
         (VarToStr(TextRight) = S.NSt(FTextRight)) and
         (FStatusBarHeight = pnlStatusBar.Height) then Break;

      if TextLeft <> '*' then
        FTextLeft := TextLeft;
      if TextRight <> '*' then
        FTextRight := TextRight;

      // установка левого текста
      if VarIsArray(FTextLeft) then
        lblStatusBarL.SetCaptionAr2(FTextLeft)
      else
        lblStatusBarL.SetCaption2(FTextLeft);

      // установка правого текста с возможным цветом
      if VarIsArray(FTextRight) then
        lblStatusBarR.SetCaptionAr2(FTextRight)
      else begin
        st := Trim(VarToStr(FTextRight));
        if (st = '') or (st[1] <> '$') then begin
          lblStatusBarR.Font.Color := clBlack;
          lblStatusBarR.Caption := st;
        end else begin
          lblStatusBarR.Font.Color := StrToInt(Copy(st, 1, 7));
          lblStatusBarR.Caption := Copy(st, 8);
        end;
      end;
    end;
  until True;
  FInSetStatusBar := False;
end;

procedure TFrmBasicMdi.RefreshDlgPanel;
// обновление панели кнопок: создание кнопок, настройка видимости и позиционирование.
var
  i: Integer;
  Panel: TPanel;
  c: TComponent;
begin
  if FAllreadyCreated then Exit;
  if FOpt.DlgPanelStyle = dpsNone then begin
    pnlFrmBtns.Height := 0;
    pnlFrmBtns.Visible := False;
    Exit;
  end;

  pnlFrmBtnsContainer.Padding.Top := MY_FORMPRM_BTNPANEL_V_EDGES;
  pnlFrmBtnsContainer.Padding.Bottom := pnlFrmBtnsContainer.Padding.Top;
  pnlFrmBtns.Height := Max(pnlFrmBtns.Height, MY_FORMPRM_BTN_DEF_H + pnlFrmBtnsContainer.Padding.Top * 2 + 2 * 2 + 4);

  // если панель кнопок сверху – меняем align
  if FOpt.DlgPanelStyle in [dpsTopLeft, dpsTopRight] then begin
    pnlFrmClient.Align := alNone;
    pnlFrmBtns.Align := alTop;
    pnlFrmClient.Align := alClient;
    pnlFrmBtnsContainer.Top := 0;
  end;

  bvlFrmBtnsB.Visible := FOpt.DlgPanelStyle in [dpsTopLeft, dpsTopRight];
  bvlFrmBtnsTl.Visible := not bvlFrmBtnsB.Visible;

  // настройка панелей: сброс bevel, высота
  for i := pnlFrmBtnsContainer.ControlCount - 1 downto 0 do
    if pnlFrmBtnsContainer.Controls[i] is TPanel then begin
      Panel := TPanel(pnlFrmBtnsContainer.Controls[i]);
      Panel.Caption := '';
      Panel.BevelInner := bvNone;
      Panel.BevelOuter := bvNone;
      Panel.Height := pnlFrmBtnsContainer.Height;
    end;

  // назначение тегов для SetPanelsAlign
  if FOpt.DlgPanelStyle in [dpsTopLeft, dpsBottomLeft] then begin
    pnlFrmBtnsMain.Tag := 1;
    pnlFrmBtnsChb.Tag := 2;
    pnlFrmBtnsL.Tag := 3;
    pnlFrmBtnsR.Tag := -2;
    pnlFrmBtnsInfo.Tag := -1;
  end else begin
    pnlFrmBtnsChb.Tag := -3;
    pnlFrmBtnsR.Tag := -2;
    pnlFrmBtnsMain.Tag := -1;
  end;

  SetPanelsAlign(pnlFrmBtnsContainer);

  // создание основных кнопок Ок / Отмена
  btnOk :=  nil;
  btnCancel := nil;
  if Length(FOpt.DlgButtonsM) > 0 then begin
     if Length(FOpt.DlgButtonsM[0]) > 0 then
       Cth.CreateButtons(pnlFrmBtnsMain, FOpt.DlgButtonsM, btnClick, cbttBNormal, '', 0, 0, False)
     else
       pnlFrmBtnsMain.Width := 0;
  end
  else begin
    Cth.CreateButtons(pnlFrmBtnsMain,
      [
        [mbtOk, Mode in [fEdit, fAdd, fCopy, fDelete], S.Decode([Mode, fDelete, 'Удалить', 'Ок']), S.Decode([Mode, fDelete, 'delete', 'ok'])],
        [mbtCancel, True, S.Decode([Mode, fView, 'Закрыть', fNone, 'Закрыть', 'Отмена']), S.Decode([Mode, fView, 'viewclose', fNone, 'cancel', 'cancel'])]
      ],
      btnCancelClick, cbttBNormal, '', 0, 0, False
    );

    // временно увеличиваем ширину панели, чтобы избежать сдвигов
    pnlFrmBtnsMain.AutoSize := False;
    pnlFrmBtnsMain.Width := 1024 * 10;

    // назначение обработчиков для кнопок
    if Mode in [fView, fNone] then
      btnCancel := TBitBtn(pnlFrmBtnsMain.Controls[0])
    else begin
      btnOk := TBitBtn(pnlFrmBtnsMain.Controls[0]);
      btnCancel := TBitBtn(pnlFrmBtnsMain.Controls[1]);
    end;

    if btnOk <> nil then begin
      TButton(btnOk).OnClick := btnOkClick;
      TButton(btnOk).Cancel := False;
      TButton(btnOk).ModalResult := mrNone;
    end;
    if btnCancel <> nil then begin
      TButton(btnCancel).OnClick := btnCancelClick;
      TButton(btnCancel).Cancel := FMode in [fView, fDelete];
      TButton(btnCancel).ModalResult := mrCancel;
    end;
  end;

  Self.ModalResult := mrNone;

  // левая панель
  if Length(FOpt.DlgButtonsL) > 0 then
    Cth.CreateButtons(pnlFrmBtnsL, FOpt.DlgButtonsL, btnClick, cbttBNormal, '', 0, 0, False)
  else if pnlFrmBtnsL.ControlCount = 0 then
    pnlFrmBtnsL.Width := 0;

  // правая панель
  if Length(FOpt.DlgButtonsR) > 0 then
    Cth.CreateButtons(pnlFrmBtnsR, FOpt.DlgButtonsR, btnClick, cbttBNormal, '', 0, 0, False)
  else if pnlFrmBtnsR.ControlCount = 0 then
    pnlFrmBtnsR.Width := 0;

  // удаление лишних разделителей
  if (pnlFrmBtnsL.ControlCount = 1) and (pnlFrmBtnsL.Controls[0] is TBevel) then
    pnlFrmBtnsL.Controls[0].Free;
  if (pnlFrmBtnsR.ControlCount = 1) and (pnlFrmBtnsR.Controls[0] is TBevel) then
    pnlFrmBtnsR.Controls[0].Free;

  pnlFrmBtnsChb.Visible := FOpt.UseChbNoClose and (Mode in [fAdd, fCopy]);

  // настройка иконки Info
  c := FindComponent('ImgInfoMain');
  if (c = nil) and (Length(Cth.SetInfoIconText(Self, FOpt.InfoArray)) > 0) then begin
    imgFrmInfo.Left := 3;
    imgFrmInfo.Name := 'ImgInfoMain';
  end;
  c := FindComponent('ImgInfoMain');
  if (c <> nil) and (TControl(c).Parent = pnlFrmBtnsInfo) then
    pnlFrmBtnsInfo.Width := MY_FORMPRM_BTN_DEF_H + 4
  else
    pnlFrmBtnsInfo.Width := 0;

  // вертикальное центрирование контролов в каждой панели
  for i := pnlFrmBtnsContainer.ControlCount - 1 downto 0 do begin
    TWinControl(pnlFrmBtnsContainer.Controls[i]).Height := pnlFrmBtnsContainer.ClientHeight;
    VertAlignCtrls(TWinControl(pnlFrmBtnsContainer.Controls[i]));
  end;

  // дополнительная расстановка с учётом кеша (для единообразия с публичными методами)
  ArrangeAllPanels;

  pnlFrmBtnsMain.AutoSize := True;
  FDlgPanelMinWidth := Self.Width - pnlFrmBtnsC.Width;
end;

//-----------------------------------------------------------------------------
// Статические методы создания и отображения формы
//-----------------------------------------------------------------------------

class function TFrmBasicMdi.Show(AOwner: TComponent; ADoc: string;
  AMyFormOptions: TMyFormOptions; AMode: TDialogType;
  AID: Variant; AAddParam: Variant): TMDIResult;
var
  F: TForm;
begin
  F := Create(AOwner, ADoc, AMyFormOptions, AMode, AID, AAddParam, []);
  Result := TFrmBasicMdi(F).FFormResult;
  AfterFormClose(F);
end;

class function TFrmBasicMdi.ShowModal2(AOwner: TComponent; ADoc: string;
  AMyFormOptions: TMyFormOptions; AMode: TDialogType;
  AID: Variant; AAddParam: Variant): TMDIResult;
var
  F: TForm;
begin
  F := Create(AOwner, ADoc, AMyFormOptions + [myfoModal], AMode, AID, AAddParam, []);
  Result := TFrmBasicMdi(F).FFormResult;
  Result.ModalResult := TFrmBasicMdi(F).ModalResult;
  AfterFormClose(F);
end;

constructor TFrmBasicMdi.Create(AOwner: TComponent; ADoc: string;
  AMyFormOptions: TMyFormOptions; AMode: TDialogType;
  AID: Variant; AAddParam: Variant;
  AControlValues: TVarDynArray; APSetControls: pointer = nil);
// конструктор класса
  procedure PSetControlsProc;
  begin
    TSetControlsProc(APSetControls)(Self, AControlValues);
  end;
begin
  FFormNotCreatedByApplication := True;
  if APSetControls <> nil then
    PSetControlsProc;

  if not PrepareCreatedForm(AOwner, ADoc, '', AMode, AID, FOpt.InfoArray, AMyFormOptions, False) then
    Exit;
  FAddParam := AAddParam;
  ShowForm(Self);
end;

procedure TFrmBasicMdi.InitializeNewForm;
// подмена стиля формы: если не myfoModal – fsMDIChild, иначе fsNormal
var
  FS: ^TFormStyle;
begin
  inherited;
  if not FFormNotCreatedByApplication then begin
    FModuleId := cMainModule;
    FStatusBarHeight := -1;
    Exit;
  end;
  // инициализация кеша порядка контролов
  FPanelOrderCache := TDictionary<TPanel, TControlArray>.Create;
  if not (myfoModal in MyFormOptions) then begin
    FS := @FormStyle;
    FS^ := fsMDIChild;
  end else begin
    FS := @FormStyle;
    FS^ := fsNormal;
  end;
end;

destructor TFrmBasicMdi.Destroy;
begin
  FPanelOrderCache.Free;
  inherited;
end;

class procedure TFrmBasicMdi.ShowForm(AForm: TForm);
// отображение формы в зависимости от стиля (fsNormal – модально, fsMDIChild – как MDI)
begin
  if not TFrmBasicMdi(AForm).FFormNotCreatedByApplication then Exit;
  if AForm.FormStyle = fsNormal then
    AForm.Hide;

  if AForm.FormStyle = fsNormal then begin
    TFrmBasicMdi(AForm).FToLoadData := True;
    TFrmBasicMdi(AForm).AfterCreate;
    if TFrmBasicMdi(AForm).FPrepareResult then
      TFrmBasicMdi(AForm).FFormResult.ModalResult := AForm.ShowModal;
  end else begin
    TFrmBasicMdi(AForm).FToLoadData := True;
    TFrmBasicMdi(AForm).AfterCreate;
    if TFrmBasicMdi(AForm).FPrepareResult then
      AForm.Show;
  end;
end;

procedure TFrmBasicMdi.ShowFormAsMdi;
// показать скрытую MDI-дочернюю форму
begin
  Self.FormStyle := fsMDIChild;
  TCustomForm(Self).Show;
  ShowWindow(Handle, SW_SHOW);
  Wh.ChildFormActivate(Self);
end;

class procedure TFrmBasicMdi.AfterFormClose(AForm: TForm);
// действия после закрытия формы: установка фокуса на родителя и освобождение
begin
  if TFrmBasicMdi(AForm).FormStyle <> fsNormal then Exit;
  if TFrmBasicMdi(AForm).ParentForm = nil then
    FrmMain.SetFocus
  else
    TForm(TFrmBasicMdi(AForm).ParentForm).SetFocus;
  TFrmBasicMdi(AForm).Free;
end;

class function TFrmBasicMdi.TestMultiInstances(AFormDoc: string;
  AMyFormOptions: TMyFormOptions; AMode: TDialogType;
  AID: Variant): Boolean;
// проверка, можно ли открыть новый экземпляр формы.
// если myfoMultiCopy и режим добавления/копирования – разрешено;
// иначе пытаемся активировать существующую форму.
begin
  Result := True;
  if AFormDoc = '' then Exit;
  if (myfoMultiCopy in AMyFormOptions) and (AMode in [fNone, fAdd, fCopy]) then Exit;
  if (myfoMultiCopy in AMyFormOptions) then
    Result := Wh.BringToFrontIfExists(AFormDoc, AID)
  else
    Result := Wh.BringToFrontIfExists(AFormDoc, Null);
end;

//-----------------------------------------------------------------------------
// Жизненный цикл формы
//-----------------------------------------------------------------------------

procedure TFrmBasicMdi.AfterCreate;
// выполняется после создания, перед показом формы: вызов Prepare и AfterPrepare
begin
  FInPrepare := True;
  Cth.SetWaitCursor;
  FPrepareResult := Prepare;
  Cth.SetWaitCursor(False);
  if not FPrepareResult then begin
    ExitWithoutShow;
    Exit;
  end;
  FInPrepare := False;
  Cth.SetWaitCursor;
  AfterPrepare;
  Cth.SetWaitCursor(False);

  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;
end;

procedure TFrmBasicMdi.GlobalEvent(AEvent: Integer);
// глобальное событие (заглушка)
begin
  // MyInfoMessage('!!!');
end;

procedure TFrmBasicMdi.CenteringByParent;
// центрирование формы относительно родительской формы
var
  x, y: Integer;
begin
  if ParentForm = nil then Exit;
  x := TForm(ParentForm).Left + TForm(ParentForm).Width div 2 - Self.Width div 2;
  if x + Self.Width > FrmMain.ClientWidth - 10 then
    x := FrmMain.ClientWidth - Self.Width - 30;
  Self.Left := Max(x, 0);

  y := TForm(ParentForm).Top + TForm(ParentForm).Height div 2 - Self.Height div 2;
  if y + Self.Height > FrmMain.FormsList.Top - FrmMain.lbl_GetTop.Top - 10 then
    y := FrmMain.FormsList.Top - FrmMain.lbl_GetTop.Top - Self.Height - 10;
  Self.Top := Max(y, 0);
end;

procedure TFrmBasicMdi.tmrAfterCreateTimer(Sender: TObject);
begin
  tmrAfterCreate.Enabled := False;
  AfterStart;
end;

procedure TFrmBasicMdi.AfterStart;
begin
  // перекрывается в потомках
end;

function TFrmBasicMdi.FormDbLock(msg: string = '*|*'): TDialogType;
// попытка взять блокировку записи в БД. возвращает реальный режим (если блокировка не удалась – fView или fNone)
begin
  FLockInDB := FMode;
  Result := FMode;
  if (FFormDoc = '') or (FID = Null) or (FOpt.NoDbLock) then Exit;
  FMode := Q.DBLock(True, FFormDoc, VarToStr(FID), msg, FMode)[3];
  FLockInDB := FMode;
  Result := FMode;
end;

procedure TFrmBasicMdi.ExitWithoutShow;
// закрытие формы без отображения (сдвиг влево)
begin
  Left := mycHiddenFormLeft;
  Self.Close;
end;

function TFrmBasicMdi.Prepare: Boolean;
// подготовка данных (перекрывается в потомках)
begin
  Result := True;
end;

procedure TFrmBasicMdi.AfterPrepare;
// действия после Prepare (перекрывается)
begin
  // RefreshDlgPanel; и т.д.
end;

procedure TFrmBasicMdi.SetMainInfoIcon;
// настройка иконки справки (ImgInfoMain)
var
  c: TComponent;
  wh: Integer;
begin
  c := FindComponent('ImgInfoMain');
  if c = nil then Exit;
  if S.Right(c.Name, 4) = 'main' then
    wh := MY_FORMPRM_BTN_DEF_H
  else if S.Right(c.Name, 4) = 'MAIN' then
    wh := MY_FORMPRM_SPEEDBTN_DEF_H
  else
    wh := TImage(c).Width;
  if not (c is TImage) then Exit;
  Cth.SetInfoIcon(TImage(c), Cth.SetInfoIconText(Self, FOpt.InfoArray), wh);
end;

function TFrmBasicMdi.RefreshParentForm: Boolean;
// обновление родительской формы/грида после сохранения
begin
  if not FOpt.RefreshParent then Exit;
  try
    if (ParentControl <> nil) and (ParentControl is TFrDbGridEh) then
      TFrDbGridEh(ParentControl).RefreshGrid(Mode, 0, StrToUIntDef(ID.AsString, MaxInt))
    else if (ParentForm <> nil) and (ParentForm is TFrmBasicMdi) and
            (TFrmBasicMdi(ParentForm).FindComponent('Frg1') <> nil) then
      TFrDbGridEh(TFrmBasicMdi(ParentForm).FindComponent('Frg1')).RefreshGrid(Mode, 0, StrToUIntDef(ID.AsString, MaxInt));
  except
  end;
end;

function TFrmBasicMdi.IsScrollBarVisible(isVert: Boolean = True): Boolean;
// проверка видимости скроллбара
begin
  if isVert then
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_VSCROLL) <> 0
  else
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_HSCROLL) <> 0;
end;

procedure TFrmBasicMdi.GetFormLTWH;
// сохранение текущих размеров и позиции
begin
  FPrevLeft := Left;
  FPrevTop := Top;
  FPrevWidth := Width;
  FPrewHeight := Height;
end;

procedure TFrmBasicMdi.CorrectFormSize;
// корректировка размеров формы по данным FWHCorrected и панелям
var
  i: Integer;
  RightAnchoredControls, BottomAnchoredControls: TControlArray;
  c: TComponent;
  MinWidth: Integer;
begin
  if FOpt.AutoAlignControls then
    FWHCorrected := Cth.AlignControls(pnlFrmClient, FOpt.ControlsWoAligment, False);
  if FOpt.AutoAlignControls then
    Cth.MakePanelsFlat(pnlFrmClient, []);

  // сброс якорей для контролов, чтобы они не мешали
  for i := 0 to Self.ComponentCount - 1 do begin
    c := Self.Components[i];
    if c is TControl then begin
      if not Cth.IsChildControl(pnlFrmClient, TControl(c), True) then
        Continue;
      if (akRight in TControl(c).Anchors) or (c.Tag = -100) then begin
        RightAnchoredControls := RightAnchoredControls + [TControl(c)];
        TWinControl(c).Anchors := TControl(c).Anchors - [akRight];
      end;
      if akBottom in TControl(c).Anchors then begin
        BottomAnchoredControls := BottomAnchoredControls + [TControl(c)];
        TWinControl(c).Anchors := TControl(c).Anchors - [akBottom];
      end;
    end;
  end;

  // минимальная ширина панели кнопок
  MinWidth := 0;
  if FOpt.DlgPanelStyle <> dpsNone then
    MinWidth := pnlFrmBtnsMain.Width + pnlFrmBtnsL.Width + pnlFrmBtnsR.Width + S.IIf(pnlFrmBtnsChb.Visible, pnlFrmBtnsChb.Width, 0) + S.IIf(pnlFrmBtnsInfo.Visible, pnlFrmBtnsInfo.Width, 0) + 12;

  if FWHCorrected.X <> 0 then
    ClientWidth := FWHCorrected.X + MY_FORMPRM_H_EDGES + 2;
  if ClientWidth < MinWidth then
    ClientWidth := MinWidth;
  if FWHBounds.X = 0 then
    FWHBounds.X := Width;

  if FWHCorrected.Y <> 0 then
    ClientHeight := FWHCorrected.Y + MY_FORMPRM_V_TOP * 2 + pnlFrmBtns.Height + S.IIf(pnlStatusBar.Visible and (FOpt.StatusBarMode <> stbmNone), pnlStatusBar.Height, 0);
  if FWHBounds.Y = 0 then
    FWHBounds.Y := Height;

  // восстановление якорей
  for i := 0 to High(RightAnchoredControls) do
    TControl(RightAnchoredControls[i]).Anchors := TControl(RightAnchoredControls[i]).Anchors + [akRight];
  for i := 0 to High(BottomAnchoredControls) do
    TControl(BottomAnchoredControls[i]).Anchors := TControl(BottomAnchoredControls[i]).Anchors + [akBottom];

  if (FWHBounds.X2 <> 0) and ((FWHBounds.X2 = -1) or (FWHBounds.X2 < FWHBounds.X)) then
    FWHBounds.X2 := FWHBounds.X;
  if (FWHBounds.Y2 <> 0) and ((FWHBounds.Y2 = -1) or (FWHBounds.Y2 < FWHBounds.Y)) then
    FWHBounds.Y2 := FWHBounds.Y;

  FWinSizeCorrected := True;
end;

procedure TFrmBasicMdi.WMSysCommand(var Msg: TWMSysCommand);
// перехват системных команд для управления разворачиванием/сворачиванием
begin
  if Msg.CmdType = SC_ZOOM then begin
    if FIsMaximized then begin
      FInMaxMin := True;
      Self.Top := FPrevTop;
      Self.Left := FPrevLeft;
      Self.Width := FPrevWidth;
      Self.Height := FPrewHeight;
      Msg.Result := 0;
      FInMaxMin := False;
      FIsMaximized := False;
      Exit;
    end
    else begin
      FInMaxMin := True;
      GetFormLTWH;
      Self.Top := 0;
      Self.Left := 0;
      Self.Width := FrmMain.ClientWidth - 5;
      Self.Height := FrmMain.ClientHeight - 45;
      if IsScrollBarVisible(False) then
        Self.Width := Self.Width - 15;
      if IsScrollBarVisible(True) then
        Self.Height := Self.Height - 15;
      Msg.Result := 0;
      FInMaxMin := False;
      FIsMaximized := True;
      Exit;
    end;
  end;
  DefaultHandler(Msg);
  if WindowState = wsMaximized then
    WindowState := wsNormal;
end;

function TFrmBasicMdi.FindCmp(AParent: TWinControl; AControlName: string; ASuffix: Integer = 0): TComponent;
// поиск компонента по имени (рекурсивно)
var
  i: Integer;
  c: TComponent;
  ControlName: string;
begin
  Result := nil;
  ControlName := AControlName;
  if ASuffix <> 0 then
    ControlName := ControlName + 'Sfx' + IntToStr(ASuffix);
  for i := 0 to AParent.ComponentCount - 1 do begin
    c := AParent.Components[i];
    if S.CompareStI(c.Name, ControlName) then begin
      Result := c;
      Exit;
    end
    else if (c is TWinControl) or (c is TFrame) then
      FindCmp(TWinControl(c), ControlName, ASuffix);
  end;
end;


//-----------------------------------------------------------------------------
// Управление контролами и событиями
//-----------------------------------------------------------------------------

procedure TFrmBasicMdi.SetControlEvents;
// назначение событий для всех контролов на форме (OnChange, OnExit, OnClick и т.д.)
begin
  Cth.SetControlsVerification(Self, FControlVerifycations);
  Cth.SetControlsEhEvents(pnlFrmClient, False, True, nil, ControlOnExit, ControlOnChangeEvent, ControlCheckDrawRequiredState, EditButtonsClick);
  Cth.SetControlsEhEvents(pnlFrmBtnsC, False, True, nil, ControlOnExit, ControlOnChangeEvent, ControlCheckDrawRequiredState, EditButtonsClick);
  Cth.SetButtonsOnClick(pnlFrmClient, btnClientClick);
  SetControlEventsEx;
end;

procedure TFrmBasicMdi.SetControlEventsEx;
var
  i: Integer;
  c: TControl;
  PropInfo: PPropInfo;
  Meth: TMethod;
  MethodPtr: Pointer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if not (Components[i] is TControl) then Continue;
    c := TControl(Components[i]);
    if not (Cth.IsChildControl(pnlFrmClient, c, True) or Cth.IsChildControl(pnlFrmBtnsC, c, True)) then Continue;

    // OnClick
    PropInfo := GetPropInfo(c.ClassInfo, 'OnClick');
    if (PropInfo <> nil) and (PropInfo.PropType^.Kind = tkMethod) then
    begin
      Meth := GetMethodProp(c, PropInfo);
      if Meth.Code = nil then
      begin
        Meth.Code := @TFrmBasicMdi.ControlClick;
        Meth.Data := Self;
        SetMethodProp(c, PropInfo, Meth);
      end;
    end;

    // OnDblClick
    PropInfo := GetPropInfo(c.ClassInfo, 'OnDblClick');
    if (PropInfo <> nil) and (PropInfo.PropType^.Kind = tkMethod) then
    begin
      Meth := GetMethodProp(c, PropInfo);
      if Meth.Code = nil then
      begin
        Meth.Code := @TFrmBasicMdi.ControlDblClick;
        Meth.Data := Self;
        SetMethodProp(c, PropInfo, Meth);
      end;
    end;

    // OnKeyPress
    PropInfo := GetPropInfo(c.ClassInfo, 'OnKeyPress');
    if (PropInfo <> nil) and (PropInfo.PropType^.Kind = tkMethod) then
    begin
      Meth := GetMethodProp(c, PropInfo);
      if Meth.Code = nil then
      begin
        Meth.Code := @TFrmBasicMdi.ControlKeyPress;
        Meth.Data := Self;
        SetMethodProp(c, PropInfo, Meth);
      end;
    end;
  end;
end;

procedure TFrmBasicMdi.SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True;
  Disabled: Boolean = False; Parent: TControl = nil);
// установка редактируемости для списка контролов (или всех, если список пуст)
var
  i: Integer;
  c: TControl;
  ControlNames: TVarDynArray;
begin
  if Parent = nil then
    Parent := pnlFrmClient;
  ControlNames := [];
  for i := 0 to High(AConrols) do
    ControlNames := ControlNames + [AConrols[i].Name];
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TWinControl then begin
      c := TControl(Components[i]);
      if not Cth.IsChildControl(TWinControl(Parent), TWinControl(c), True) then Continue;
      if (Length(AConrols) = 0) or (A.PosInArray(c.Name, ControlNames, True) >= 0) then begin
        Cth.SetControlNotEditable(c, not Editable, False, True);
        if c is TCustomDBEditEh then
          Cth.SetEhControlEditButtonState(c, Editable, Editable);
      end;
    end;
end;

procedure TFrmBasicMdi.SetControlsEditableForParent(AConrols: array of TControl; Editable: Boolean = True;
  Disabled: Boolean = False; Parent: TControl = nil);
// заглушка, не используется
begin
  // пусто
end;

procedure TFrmBasicMdi.Serialize;
// сериализация значений контролов в строку
begin
  if FOpt.NoSerializeCtrls then
    FCtrlCurrValuesStr := ''
  else
    FCtrlCurrValuesStr := Cth.SerializeControlValuesArr2(Cth.GetControlValuesArr2(Self, nil, [], ['chb_NoClose']));
end;

//-----------------------------------------------------------------------------
// Получение значений контролов
//-----------------------------------------------------------------------------

function TFrmBasicMdi.GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
// получить значение контрола по имени
begin
  Result := Cth.GetControlValue(TControl(Self.FindComponent(ControlName)));
  if NullIfEmpty then
    Result := S.NullIfEmpty(Result);
end;

function TFrmBasicMdi.GetControlValue(Control: TControl; NullIfEmpty: Boolean = False): Variant;
begin
  Result := Cth.GetControlValue(Control);
  if NullIfEmpty then
    Result := S.NullIfEmpty(Result);
end;

function TFrmBasicMdi.GetControlValues(ControlNames: TVarDynArray; NullIfEmpty: Boolean = False): TVarDynArray;
var
  i: Integer;
begin
  Result := [];
  for i := 0 to High(ControlNames) do begin
    Result := Result + [Cth.GetControlValue(TControl(Self.FindComponent(ControlNames[i])))];
    if NullIfEmpty then
      Result[High(Result)] := S.NullIfEmpty(Result[High(Result)]);
  end;
end;

function TFrmBasicMdi.GetControlValues(Controls: TControlArray; NullIfEmpty: Boolean = False): TVarDynArray;
var
  i: Integer;
begin
  Result := [];
  for i := 0 to High(Controls) do begin
    Result := Result + [Cth.GetControlValue(Controls[i])];
    if NullIfEmpty then
      Result[High(Result)] := S.NullIfEmpty(Result[High(Result)]);
  end;
end;

//-----------------------------------------------------------------------------
// Установка значений контролов
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Установка значений контролов
//-----------------------------------------------------------------------------

procedure TFrmBasicMdi.SetControlValue(ControlName: string; const Value: Variant);
// установка значения контрола по имени
begin
  Cth.SetControlValue(TControl(Self.FindComponent(ControlName)), Value);
end;

procedure TFrmBasicMdi.SetControlValue(Control: TControl; const Value: Variant);
// установка значения контрола по ссылке
begin
  Cth.SetControlValue(Control, Value);
end;

procedure TFrmBasicMdi.SetControlValues(ControlNames: TVarDynArray; const Values: TVarDynArray);
// массовая установка значений по именам контролов (длины массивов должны совпадать)
var
  i: Integer;
begin
  if Length(ControlNames) <> Length(Values) then
    raise Exception.Create('SetControlValues: количество имён контролов не совпадает с количеством значений');
  for i := 0 to High(ControlNames) do
    Cth.SetControlValue(TControl(Self.FindComponent(ControlNames[i])), Values[i]);
end;

procedure TFrmBasicMdi.SetControlValues(Controls: TControlArray; const Values: TVarDynArray);
// массовая установка значений по ссылкам на контролы (длины массивов должны совпадать)
var
  i: Integer;
begin
  if Length(Controls) <> Length(Values) then
    raise Exception.Create('SetControlValues: количество контролов не совпадает с количеством значений');
  for i := 0 to High(Controls) do
    Cth.SetControlValue(Controls[i], Values[i]);
end;

procedure TFrmBasicMdi.SetControlValues(ControlNames: TVarDynArray; const Value: Variant);
// установка одного значения на несколько контролов (по именам)
var
  i: Integer;
begin
  for i := 0 to High(ControlNames) do
    Cth.SetControlValue(TControl(Self.FindComponent(ControlNames[i])), Value);
end;

procedure TFrmBasicMdi.SetControlValues(Controls: TControlArray; const Value: Variant);
// установка одного значения на несколько контролов (по ссылкам)
var
  i: Integer;
begin
  for i := 0 to High(Controls) do
    Cth.SetControlValue(Controls[i], Value);
end;

//-----------------------------------------------------------------------------
// События контролов
//-----------------------------------------------------------------------------

procedure TFrmBasicMdi.ControlOnChangeEvent(Sender: TObject);
// обработка изменения значения контрола
begin
  if FInPrepare then Exit;
  if not FInControlOnChaange then begin
    FInControlOnChaange := True;
    ControlOnChange(Sender);
    FInControlOnChaange := False;
  end;
  Serialize;
  Verify(Sender, True);
end;

procedure TFrmBasicMdi.ControlOnChange(Sender: TObject);
// перекрываемый обработчик изменения
begin
  // пусто
end;

procedure TFrmBasicMdi.ControlOnEnter(Sender: TObject);
begin
  if FInPrepare then Exit;
end;

procedure TFrmBasicMdi.ControlOnExit(Sender: TObject);
begin
  if FInPrepare then Exit;
  Verify(Sender);
end;

procedure TFrmBasicMdi.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

procedure TFrmBasicMdi.ControlClick(Sender: TObject);
// базовый обработчик OnClick (перекрывается в потомках)
begin
  // пусто
end;

procedure TFrmBasicMdi.ControlDblClick(Sender: TObject);
// базовый обработчик OnDblClick (перекрывается в потомках)
begin
  // пусто
end;

procedure TFrmBasicMdi.ControlKeyPress(Sender: TObject; var Key: Char);
// базовый обработчик OnKeyPress (перекрывается в потомках)
begin
  // пусто
end;

procedure TFrmBasicMdi.CheckPanelCaptionErrors;
// проверка фреймов-заголовков с AutoErrorMode=True
// для каждого такого фрейма проверяем наличие ошибок во всех дочерних контролах его родительской панели
// и устанавливаем статус ошибки фрейму соответственно
var
  i, j: Integer;
  c: TComponent;
  PanelCaption: TFrMyPanelCaption;
  ParentPanel: TWinControl;
  HasError: Boolean;
  ErrorMsg: string;
  ChildCtrl: TControl;
begin
  for i := 0 to ComponentCount - 1 do begin
    if Components[i] is TFrMyPanelCaption then begin
      PanelCaption := TFrMyPanelCaption(Components[i]);
      // обрабатываем только те, у которых включен авторежим
      if not PanelCaption.AutoErrorMode then
        Continue;
      if PanelCaption.HasError and not PanelCaption.AutoClearError then
        Continue;
      ParentPanel := PanelCaption.Parent;
      if ParentPanel = nil then
        Continue;
      // Проверяем наличие ошибок во всех потомках ParentPanel (рекурсивно)
      HasError := False;
      ErrorMsg := '';
      for j := 0 to ParentPanel.ControlCount - 1 do begin
        ChildCtrl := ParentPanel.Controls[j];
        // Проверяем, является ли контрол потомком панели (рекурсивно)
        if Cth.IsChildControl(ParentPanel, ChildCtrl, True) then begin
          // Проверяем наличие ошибки у контрола
          if (ChildCtrl is TCustomDBEditEh) and TCustomDBEditEh(ChildCtrl).DynProps.VarExists(dpError) then
            HasError := True;
          if (ChildCtrl is TDBCheckBoxEh) and TDBCheckBoxEh(ChildCtrl).DynProps.VarExists(dpError) then
            HasError := True;
          if (ChildCtrl is TDBMemoEh) and TDBMemoEh(ChildCtrl).DynProps.VarExists(dpError) then
            HasError := True;
        end;
      end;
      // Устанавливаем статус фрейму (всегда вызываем, чтобы сбросить, если ошибок нет)
      PanelCaption.SetError(HasError, '')
    end;
  end;
end;

procedure TFrmBasicMdi.VerirfyGrids(Sender: TObject; var AHasError: Boolean; var AErrorSt: string; var AIsChanged: Boolean);
// проверка гридов (TFrDBGridEh) на наличие ошибок и изменений
var
  i: Integer;
begin
  AHasError := False;
  AErrorSt := '';
  AIsChanged := False;

  if Sender = nil then begin
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TFrDBGridEh then begin
        if TFrDBGridEh(Components[i]).HasError then AHasError := True;
        if TFrDBGridEh(Components[i]).ErrorMessage <> '' then AErrorSt := TFrDBGridEh(Components[i]).ErrorMessage;
        if TFrDBGridEh(Components[i]).IsDataChanged then AIsChanged := True;
      end;
  end;

  if Sender is TFrDBGridEh then begin
    if TFrDBGridEh(Sender).HasError then AHasError := True;
    if TFrDBGridEh(Sender).ErrorMessage <> '' then AErrorSt := TFrDBGridEh(Sender).ErrorMessage;
    if TFrDBGridEh(Sender).IsDataChanged then AIsChanged := True;
  end;

  if Sender = nil then
    S.ConcatStP(FErrorMessage, AErrorSt, #13#10);
end;

procedure TFrmBasicMdi.VerifyPanels(Sender: TObject; var AHasError: Boolean; var AErrorSt: string; var AIsChanged: Boolean);
// проверка всех фреймов TFrMyPanelCaption на наличие ошибок
var
  i: Integer;
  c: TComponent;
  PanelCaption: TFrMyPanelCaption;
begin
  AHasError := False;
  AErrorSt := '';
  AIsChanged := False;

  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TFrMyPanelCaption then
    begin
      PanelCaption := TFrMyPanelCaption(Components[i]);
      if PanelCaption.HasError then
      begin
        AHasError := True;
        if PanelCaption.pnlError.Hint <> '' then
          S.ConcatStP(AErrorSt, PanelCaption.pnlError.Hint, #13#10);
      end;
    end;
  end;
end;

function TFrmBasicMdi.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
// дополнительная проверка (перекрывается в потомках)
begin
  Result := False;
end;

procedure TFrmBasicMdi.VerifyBeforeSave;
// проверка перед сохранением (перекрывается)
begin
  // пусто
end;

procedure TFrmBasicMdi.Verify(Sender: TObject; onInput: Boolean = False);
// основная проверка данных: контролы, гриды, панели, дополнительная проверка
var
  GridsErr, PanelsErr: Boolean;
  GridsErrSt, PanelsErrSt: string;
  GridsCh, PanelsCh: Boolean;
  b: Boolean;
  i: Integer;
begin
  if FInPrepare and (Sender <> nil) then
    Exit;
  FErrorMessage := '';

  if (Mode = fView) or (Mode = fDelete) then begin
    HasError := False;
    FIsDataChanged := False;
    if btnOk <> nil then
      btnOk.Enabled := not HasError;
    Exit;
  end;

  // проверка гридов
  VerirfyGrids(nil, GridsErr, GridsErrSt, GridsCh);

  // проверка конкретного контрола (если передан)
  if Sender <> nil then
    Cth.VerifyControl(TControl(Sender), onInput)
  // проверка всех контролов, кроме гридов и заголовков
  else
    Cth.VerifyAllDbEhControls(Self);

  // дополнительная проверка (перекрывается в потомках)
  b := VerifyAdd(Sender, onInput);

  // проверка фреймов-заголовков (они используют статусы контролов, уже установленные выше)
  CheckPanelCaptionErrors;

  // сбор ошибок фреймов
  PanelsErr := False;
  PanelsErrSt := '';
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TFrMyPanelCaption then
      if TFrMyPanelCaption(Components[i]).HasError then begin
        PanelsErr := True;
        if TFrMyPanelCaption(Components[i]).pnlError.Hint <> '' then
          S.ConcatStP(PanelsErrSt, TFrMyPanelCaption(Components[i]).pnlError.Hint, #13#10);
      end;

  // общий статус ошибки
  HasError := not Cth.VerifyVisualise(Self) or b or GridsErr or PanelsErr;

  // сбор сообщений об ошибках
  FErrorMessage := '';
  if GridsErrSt <> '' then
    S.ConcatStP(FErrorMessage, GridsErrSt, #13#10);
  if PanelsErrSt <> '' then
    S.ConcatStP(FErrorMessage, PanelsErrSt, #13#10);

  // признак изменения данных (только для контролов и гридов, панели не вносят изменений)
  if not FInPrepare then
    FIsDataChanged := (FCtrlCurrValuesStr <> FCtrlBegValuesStr) or GridsCh;

  RefreshStatusBar('*', '*', True);
end;

procedure TFrmBasicMdi.SetError(Value: Boolean);
// установка статуса ошибки (блокирует кнопку Ок)
var
  b: Boolean;
begin
  b := FHasError <> Value;
  FHasError := Value;
  if b then
    RefreshStatusBar('*', '*', True);
  if btnOk <> nil then
    btnOk.Enabled := not HasError;
end;

function TFrmBasicMdi.Save: Boolean;
// сохранение данных (перекрывается)
begin
  Result := True;
end;


//-----------------------------------------------------------------------------
// Обработчики кнопок
//-----------------------------------------------------------------------------

procedure TFrmBasicMdi.btnOkClick(Sender: TObject);
// нажатие кнопки Ок
begin
  FInBtOkClick := True;
  repeat
    if Mode = fView then begin
      Self.ModalResult := mrCancel;
      if FormStyle <> fsNormal then Close;
      Break;
    end;

    Verify(nil);
    if Mode <> fDelete then
      if HasError then Break;

    VerifyBeforeSave;
    if FErrorMessage <> '' then begin
      if Pos('?', FErrorMessage) = 1 then begin
        if MyQuestionMessage(Copy(FErrorMessage, 2)) <> mrYes then
          Break;
      end else begin
        MyWarningMessage(FErrorMessage, ['-', '*Данные не корректны!']);
        Break;
      end;
    end;

    if HasError then begin
      HasError := False;
      Break;
    end;

    if not Save then Break;
    RefreshParentForm;
    if FOpt.DefFocusedControl <> nil then
      FOpt.DefFocusedControl.SetFocus;

    if (not chbNoclose.Visible) or (not chbNoclose.Checked) then begin
      Self.ModalResult := mrOk;
      if FormStyle <> fsNormal then Close;
      Break;
    end;
    Break;
  until False;
  FInBtOkClick := False;
end;

procedure TFrmBasicMdi.btnCancelClick(Sender: TObject);
begin
  FInBtCancelClick := True;
  ModalResult := mrNone;
  Close;
  FInBtCancelClick := False;
end;

procedure TFrmBasicMdi.btnClick(Sender: TObject);
// обработчик для кастомных кнопок (перекрывается)
begin
  // пусто
end;

procedure TFrmBasicMdi.btnClientClick(Sender: TObject);
// обработчик для кнопок в клиентской области
begin
  // пусто
end;

procedure TFrmBasicMdi.EditButtonsClick(Sender: TObject; var Handled: Boolean);
// обработчик встроенных кнопок в Eh-контролах
begin
  // по умолчанию – пусто
end;

//-----------------------------------------------------------------------------
// События формы
//-----------------------------------------------------------------------------

procedure TFrmBasicMdi.FormActivate(Sender: TObject);
begin
  HideWaitForm;
  Cth.SetWaitCursor(False);
  if FPreventShow then Exit;
  if Left < 0 then Left := 10;
  Wh.ChildFormActivate(Self);
  AfterFormActivate;
end;

procedure TFrmBasicMdi.AfterFormActivate;
begin
  // перекрывается
end;

procedure TFrmBasicMdi.FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
  Resize := True;
  if FInSetStatusBar or not FWinSizeCorrected or FInPrepare then Exit;
  if BorderStyle = bsDialog then begin
    Resize := False;
    Exit;
  end;
  if (NewWidth > FWHBounds.X2) and (FWHBounds.X2 > 0) then
    NewWidth := FWHBounds.X2;
  if (NewWidth < FWHBounds.X) and (FWHBounds.X > 0) then
    NewWidth := FWHBounds.X;
  if (NewHeight > FWHBounds.Y2) and (FWHBounds.Y2 > 0) then
    NewHeight := FWHBounds.Y2;
  if (NewHeight < FWHBounds.Y) and (FWHBounds.Y > 0) then
    NewHeight := FWHBounds.Y;
  if not FInMaxMin then
    GetFormLTWH;
end;

procedure TFrmBasicMdi.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Cth.SetWaitCursor(False);
  try
    Action := caFree;
    if FormDoc <> '' then begin
      if Self.Left > mycHiddenFormLeft then
        Settings.SaveWindowPos(Self, FormDoc);
      if not FPreventShow then
        if (FLockInDB = fEdit) or (FLockInDB = fDelete) then
          Q.DBLock(False, FormDoc, VarToStr(ID));
    end;
    FPreventShow := True;
    Wh.ChildFormDestroy(Sender);
  except
  end;
end;

procedure TFrmBasicMdi.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  mr: Integer;
  QueryMsg: string;
  EscPressed: Boolean;
begin
  if FrmMain.InFormClose then begin
    CanClose := True;
    Exit;
  end;
  if FDisableClose then begin
    CanClose := False;
    Exit;
  end;

  EscPressed := False;
  if (FMode in [fAdd, fCopy, fEdit, fNone]) and FIsDataChanged and (btnCancel <> nil) and not btnCancel.Focused then
    EscPressed := True;
  EscPressed := False; // отключаем обработку Esc, т.к. она нестабильна

  if FInBtOkClick then
    CanClose := True
  else if (EscPressed or (FOpt.RequestWhereClose = cqYN)) and FIsDataChanged then begin
    if FQueryCloseMessage <> '' then
      QueryMsg := FQueryCloseMessage
    else
      QueryMsg := 'Данные были изменены?'#13#10'Все равно закрыть диалог?';
    CanClose := MyQuestionMessage(QueryMsg) = mrYes;
  end else if (EscPressed or (FOpt.RequestWhereClose = cqYNC)) and FIsDataChanged then begin
    if FQueryCloseMessage <> '' then
      QueryMsg := FQueryCloseMessage
    else
      QueryMsg := 'Данные были изменены?'#13#10'Сохранить?';
    mr := MyMessageDlg(QueryMsg, mtConfirmation, [mbYes, mbNo, mbCancel]);
    CanClose := mr = mrNo;
    if mr = mrYes then
      btnOkClick(btnOk);
  end;

  // для форм, созданных не через Application (скрываем вместо закрытия)
  if (not FFormNotCreatedByApplication) and (FormStyle <> fsNormal) then begin
    Settings.SaveWindowPos(Self, FormDoc);
    if (FLockInDB = fEdit) or (FLockInDB = fDelete) then
      Q.DBLock(False, FormDoc, VarToStr(ID));
    ShowWindow(Handle, SW_HIDE);
    Wh.ChildFormDestroy(Sender);
    if not FrmMain.ApplicationQueryClose then
      CanClose := False;
    Exit;
  end;
end;

procedure TFrmBasicMdi.FormCreate(Sender: TObject);
begin
  if F = nil then
    F := TFields.Create(Self);
  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;
end;

procedure TFrmBasicMdi.FormShow(Sender: TObject);
var
  i: Integer;
begin
  if FPreventShow then begin
    Left := mycHiddenFormLeft;
    Exit;
  end;

  FAfterFormShow := True;
  RefreshDlgPanel;
  CorrectFormSize;

  if not F.IsFieldsPrepared then
    F.PrepareDefineFieldsAdd;
  if not F.IsPropControlsSet then
    F.SetPropsControls;

  SetControlEvents;
  Cth.FixTabOrder(Self);

  if FOpt.DefFocusedControl = nil then
    FOpt.DefFocusedControl := Cth.GetFirstTabControl(Self);
  if FOpt.DefFocusedControl <> nil then
    FOpt.DefFocusedControl.SetFocus;

  Cth.SetDialogCaption(Self, Mode, Self.Caption);
  SetMainInfoIcon;
  Serialize;
  FCtrlBegValuesStr := FCtrlCurrValuesStr;

  if FFormDoc <> '' then
    Settings.RestoreWindowPos(Self, FormDoc);
  Self.Top := Max(Self.Top, 0);

  Verify(nil);
  RefreshStatusBar('*', '*', True);

  if (myfoDialog in MyFormOptions) and (ParentForm <> nil) and
     ((ParentForm is TForm) or (ParentForm is TFrDBGridEh)) then
    CenteringByParent;

  if btnOk <> nil then
    btnOk.Focused;
  FAllreadyCreated := True;
end;

function TFrmBasicMdi.PrepareCreatedForm(AOwner: TObject; AFormDoc, ACaption: string;
  AMode: TDialogType; AID: Variant; AInfoArray: TVarDynArray2;
  AOptions: TMyFormOptions = [myfoModal, myfoDialog, myfoDialogButtonsB];
  AAutoAlign: Boolean = True): Boolean;
// подготовка динамически созданной формы с предустановками
begin
  Result := False;
  FModuleId := cMainModule;
  FMyFormOptions := AOptions;
  FStatusBarHeight := -1;

  if wh.IsModalFormOpen then
    Include(FMyFormOptions, myfoModal);

  if not TestMultiInstances(AFormDoc, MyFormOptions, AMode, AID) then
    Exit;

  if FFormNotCreatedByApplication then
    inherited Create(Application);
  F := TFields.Create(Self);

  if FFormNotCreatedByApplication then
    Left := mycHiddenFormLeft;

  FFormDoc := AFormDoc;
  if FFormDoc = '*' then
    FFormDoc := Self.Name;
  Caption := ACaption;
  FMode := AMode;
  FID := AID;
  FOpt.InfoArray := AInfoArray;

  if myfoDialogButtonsB in FMyFormOptions then
    FOpt.DlgPanelStyle := dpsBottomRight;
  if myfoDialogButtonsT in FMyFormOptions then
    FOpt.DlgPanelStyle := dpsTopLeft;
  if myfoShowStatusbar in FMyFormOptions then
    FOpt.StatusBarMode := stbmDialog;

  FOpt.AutoAlignControls := AAutoAlign;
  FParentControl := TWinControl(AOwner);
  if (AOwner is TApplication) or (AOwner = nil) then
    FParentForm := FrmMain
  else if AOwner is TForm then
    FParentForm := TForm(AOwner)
  else
    FParentForm := TWinControl(AOwner).Owner;

  ModalResult := mrNone;

  if (myfoDialog in MyFormOptions) and (not (myfoEnableMaximize in MyFormOptions)) then
    if biMaximize in BorderIcons then
      Self.BorderIcons := Self.BorderIcons - [biMaximize];

  if FFormNotCreatedByApplication then
    Left := mycHiddenFormLeft;

  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;

  Result := True;
end;

end.
