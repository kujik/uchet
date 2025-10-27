
unit uFrmBasicMdi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DBCtrlsEh, DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, ADODataDriverEh, MemTableEh, GridsEh,
  DBAxisGridsEh, DBGridEh, Math, Vcl.StdCtrls, Vcl.Mask, Buttons,
  uLabelColors, uData, uString,
  uFields
  ;



{$R *.dfm}



const
  mycHiddenFormLeft = -10000;

type
  TCustomFormMy = class(TCustomForm);


  //такая процедура может быть опредена в потомке в функции вызова формы, имеет смысл в диалоговом окне
  //в этом случае в конструктор передается указатель на нее и массив параметров,
  //непосредственно в процедуре реализуется установка значений котролов формы на основании значений массива
  TSetControlsProc= procedure(ASelf: TObject; AControlValues: TVarDynArray);

  //тип панели кнопок
  TMDIDlgPanelStyle = (
    dpsNone, dpsBottomRight, dpsBottomLeft, dpsTopRight, dpsTopLeft
  );

  //информация в статусбаре
  TMDIStatusMode = (
    stbmNone, stbmCustom, stbmGrid, stbmDialog
  );

  //реакция на закрытие формы по крестику или при закрытии приложения
  //cqNone - по умолчанию, закрывается без сохранения
  //cqYN - если данные изменены, спросит: "Данные изменены. Все равно закрыть? (Y/N)"
  //cqYNC - если данные изменены, спросит: "Данные изменены. Сохранить? (да/нет отмена)"
  TMDICloseQuery = (
    cqNone, cqYN, cqYNC
  );

  TMDIResult = record
    ModalResult: Integer;
    Data: Variant;
    DataA: TVarDynArray2;
  end;

  //опции формы, устанавливаются в потомках (в перекрытой функции Prepare)
  TMDIOpt = record
    //Наличие и размещение панели кнопок
    DlgPanelStyle: TMDIDlgPanelStyle;
    //Режрежим статусбара (нет, произвольный,  информация грида (кол-во строк, отфильтровано..),
    //  информация диалогового окна (режим работы, ошибка, данные изменены)
    StatusBarMode: TMDIStatusMode;
    //Кастомные кнопки слева
    DlgButtonsL: TVarDynArray2;
    //Кастомные кнопки справа
    DlgButtonsR: TVarDynArray2;
    //создать и использовать чекбокс "Не закрывать" в панели кнопок, при режимах fAdd и fCopy
    UseChbNoClose: Boolean;
    //автоматическое выравнивание контролов, можно применять если они все располдожены в pnlFrmClient; произойдет и подгонка размеров формы.
    AutoAlignControls: Boolean;
    ControlsWoAligment: TControlArray;
    AutoControlDataChanged: Boolean;
    //реакция на закрытие формы по крестику или при закрытии приложения
    RequestWhereClose: TMDICloseQuery;
    //контрол, в который помещается фокус при открытии окна, или при переходе на новую запись, если NoCloseIfAdd
    DefFocusedControl: TWinControl;
    //если задано, то всегда возвращает '' без проверки
    NoSerializeCtrls: Boolean;
    //обновлять данные в вызвавшей форме при нажатии Ок
    RefreshParent: Boolean;
    //информация, выводима по клику на соответствующей иконке
    InfoArray: TVarDynArray2;
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
    {события формы}
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrAfterCreateTimer(Sender: TObject);
  private
    FFormDoc: string;
    FMode: TDialogType;
    FParentForm: TComponent;
    FParentControl: TComponent;
    FID: Variant;
    FAddParam: Variant;
    FMyFormOptions: TMyFormOptions;


    FModuleId: Integer;
    FTextLeft, FTextRight: Variant;
    FStatusBarHeight: Integer;
    FInSetStatusBar: Boolean;
    FPreventShow: Boolean;
    FToLoadData: Boolean;
    FFormResult: TMDIResult;
    FDlgPanelMinWidth: Integer;
    FWinSizeCorrected: Boolean;
    FCtrlBegValuesStr, FCtrlCurrValuesStr: string;
    //в режиме showdialog после закрытия диалога он вызывается еще раз. данный флаг блокирует повторный вызов.
    FTab0Control: TWinControl;
    FHasError: Boolean;
    procedure SetError(Value: Boolean);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
  protected
    //результат выполнения функции препаре
    FPrepareResult: Boolean;
    //правила проверки полей ввода, формат: ['ControlName1', 'rule1', 'ControlName2', 'rule2', ...]
    FControlVerifycations: TVarDynArray;
    //дополнительные настройки формы, как правило задаются в потомках на этапе выполнения (в Prepare)
    FOpt: TMDIOpt;
    //значения, сохраненные для схлопывания/расхлопывания, вместо стандартных в событиях
    FPrevLeft, FPrevTop, FPrevWidth, FPrewHeight: Integer;
    FIsMaximized: Boolean;
    FInMaxMin: Boolean;
    FInBtOkClick: Boolean;
    FInBtCancelClick: Boolean;
    FInPrepare: Boolean;
    FInControlOnChaange: Boolean;
    FAfterFormShow: Boolean;
    //была ли сделана блокировка, результат FormDbLock = Mode, если здесь будет fDelete or FEdit то блокировка автоматом снимается при закрытии формы
    //если True, то при закрытии формы блокирока снимается, используя как ключи FormDoc и ID
    FLockInDB: TDialogType;
    //не которые формы могут изменять размер, несмотря на то что стоит bsDialog, глюк? для неизменения размера
//    PreventResize: Boolean;
    //статус ошибки в данных - тест. должен устанавливаться в потомках. если установлен, при нажатии Ок будет выведен в диалоговом окне, форма не закроется
    FErrorMessage: string;
    //признак, что данные были изменены. должен устанавливаться в потомках
    FIsDataChanged: Boolean;
    //минимальные и максимальные высота и ширина, иожно установить в конструкторе или препаре. обрабатываются здесь в onCanResize
    //если размеры не установлены, то будут минимальные определяться размеров панели кнопок (по горизотали только) и в случае подгонки размером WHCorrected
    FWHBounds: TCoord;
    //массив [ширина, высота], задает размеры клиентской части формы, под которую подгоняется и сама форма, если данный массив задан
    //может устанавливаться в Prepare, по результатам например автовыравнивания контролов
    FWHCorrected: TCoord;
    //установить для блокировки закрытия формы
    FDisableClose: Boolean;
    //сообщение при попытке закрытия окна по крестику, если при этом установлен флаг IsDataChanged
    FQueryCloseMessage: string;
    //кнопка подтверждения в панели кнопок
    btnOk: TBitBtn;
    //кнопка отмены, пока не инициализируется
    btnCancel: TBitBtn;
    //поля
    FAllreadyCreated: Boolean;
    F: TFields;
    FFormNotCreatedByApplication: Boolean;
    //статус ошибки в данных. должен устанавливаться в потомках. если установлен, кнопка Ок становится недоступной
    property HasError: Boolean read FHasError write SetError;
    //возвращаемые данные для формы, могут быть установлены в любом месте в коде, вернутся функцией класса Show
    property FormResult: TMDIResult read FFormResult write FFormResult;
    //конструктор
    constructor Create(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant; AControlValues: TVarDynArray; APSetControls: pointer = nil); reintroduce; virtual;
    //выполняет загрузку данных (Prepare) и в зависимости от результата показывает форму или завершает
    //вызывается апвтоматически в коснтрукторе если RunAfterCreateProc=True или не указан, если в коснтуркторе надо установить дополнительные параметры,
    //то этот должен быть обозначен как False и AfterCreate
    //должен быть обязательно вызван в конструкторе потомка после вызова родительского конструктора и инициализации полей (напр айди, режим),
    //или же как вариант в событии формы onCreate если только эта логика не пререкрытв
    //можно было бы сделать вызов onCreate и все, но в потомках mdi_grid1 не вызывется без перекрытия
    //СДЕЛАЛ КАК ВЫШЕ, ЯВНО НЕ ВЫЗЫВАТЬ!
    procedure AfterCreate;
    //вызывается таймером после отображения формы
    procedure AfterStart; virtual;
    //должна быть вызвана, если завершение происходит до показа формы, в конструторе
    procedure ExitWithoutShow; virtual;
    //вызывается после создания формы в конструкторе,
    //если возвращает ложь то происходит выход из конструктора с закрытием формы ExitWithoutShow
    //(то есть False блокирет отображение формы);
    //перекрывается.
    function  Prepare(): Boolean; reintroduce; virtual;
    //процедура для установки основных параметров формы, используется в конструкторе в случае динамически создаваемых форм,
    //и может вызываться явно в диалоге формы, созданной в uchet.dpr, с основными предустановками
    //по умолчанию диалоговое окно с кнопками по типау fMode внизу без статусбара
    //AFormDoc = * означет его соответствие имени формы
    function  PrepareCreatedForm(AOwner: TObject; AFormDoc: string; ACaption: string; AMode: TDialogType;
      AID: Variant; AOptions: TMyFormOptions = [myfoModal, myfoDialog, myfoDialogButtonsB]; AAutoAlign: Boolean = True): Boolean;
    procedure AfterPrepare; virtual;
    //должен вызываться после отображения формы (в таймере срабатывающем после отрисовки)
    function  RefreshParentForm: Boolean;
    //корректировка размеров формыформы по данным WHCorrected, если, например, была подгонка контролов
    procedure CorrectFormSize;
    //настройка основной иконки подсказки (ImgInfoMain)
    procedure SetMainInfoIcon;
    //центрирование формы по родительской
    procedure CenteringByParent;
    //запросить блокировку по формдок и айди. вызывается вручную в препаре, возвращает новый режим формы в переменной формы, при возврате fNone должен быть выход из Prepere с False
    function  FormDbLock(msg: string = '*|*'): TDialogType;
    //проверить фреймы гридов
    procedure VerirfyGrids(Sender: TObject; var AHasError: Boolean; var AErrorSt: string; var AIsChanged: Boolean);
    //дополнительная проверка (для того, что не покрывается условиями проверки в массиве)
    //должна отметить SetErrorMarker для контролов по более сложным алгоритмам, не охватываемым заданным правилам в массиве,
    //или сразу вернуть СТАТУС ОШИБКИ (True) - в этом ошибка будет при любом состоянии конкретных контролов
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; virtual;
    //обработка дополнительной проверки перед записью, если Verify вернуло Ок = True (а иначе кнопка Ок недоступна)
    //может скорректировать Ок, если что-то не в порядке, но предпочтительно должна вернуть ErrorMessage
    //(если оно непустое, то будет выведено при нажатии ОК, если начинается со "?", то диалог, при Yes будет сохранение,
    //при "-" сообщения не будет, но и не будет сохранения, при * будет стандартное сообщение
    //может использоваться для дополнительных действий или ваывода информации перед записьбю данных
    //вызывается также и при удалении, но не при просмотре, если проверка при уделании не нужна, в ней это обработать
    procedure VerifyBeforeSave; virtual;
    //сохраняет даннные. должна перекрываться для реального сохранения
    function  Save: Boolean; virtual;
    //событие вызывается для OnCange или для чекбоксов OnClick для всех контролов на форме, кроме дилоговой панели
    procedure ControlOnChangeEvent(Sender: TObject); virtual;
    //событие вызывается нерекурсивно - если изменение значения контрола происходит в этом событии, то оно не вызовется повторно (проверяяет флаг)
    procedure ControlOnChange(Sender: TObject); virtual;
    procedure ControlOnEnter(Sender: TObject); virtual;
    procedure ControlOnExit(Sender: TObject); virtual;
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean); virtual;
    procedure btnOkClick(Sender: TObject); virtual;
    procedure btnCancelClick(Sender: TObject); virtual;
    procedure btnClick(Sender: TObject); virtual;
    procedure EditButtonsClick(Sender: TObject; var Handled: Boolean); virtual;
    procedure GetFormLTWH;
    //получить значение контрола на форме по его имени
    //если установлено NullIfEmpty то вернуть null если значение равно пустое или ''
    function  GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
    //устанавливаем события (изменение, потеря фокуса, отрисовка статуса ошибки),
    //а также условия проверки контролов
    procedure SetControlEvents;
    //устанавливает редактируемыми или нет (Editable) все контролы из массива AConrols;
    //если последний пустой, то все контролы формы (кнопки и чекбокс повтора всегда исключаются из этой процедуры)
    procedure SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True; Disabled: Boolean = False; Parent: TControl = nil);
    //сериализуется значения контролов формы (всех, кроме галки повтора формы)
    //если задано NoSerializeCtrls, то всегда возвращает '' без проверки
    procedure Serialize; virtual;
    //обновим кнопки, их положение, и полождение и видимость диалоговой панели
    procedure RefreshDlgPanel;
    //установим левую и правую надпись в статусбаре окна (по факту в панели) и его видимость
    //лейблы колоризованные и параметры могут принимать как массив так и строку (формат см в uLabelColors)
    //если невидим, то форма уменьшитсЯ автоматически, устанавливать в потомках высоту статусбара = 0 или скрывать кроме этой процедуры не надо
    //в потомках может быть установлена любая ваысота статусбара, это корректно обрабатывается
    //если в процессе работы формы посредством вызова SetStatusBar меняется его статус видимсоти, то он появится или исчезнет, высота формы скорректируется (увеличится/уменшится вниз)
    //если форма сделана не путем создания Инхеритед через мастер - эту процедуру вообще не ваызывать - поломает размер формы
    procedure RefreshStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
    function  IsScrollBarVisible(isVert: Boolean = True): Boolean;
    //нажна для подмены стиля формы.
    //исходный стиль в дизайнере стал теперь fsNormal!!!
    procedure InitializeNewForm; override;



    //отображение формы в зависимости от режима FormStyle, вызывается в class function инициализации
    class procedure ShowForm(AForm: TForm);
    procedure ShowFormAsMdi;
    //действия поле закрытия формы (нужны в случае, если форма была создана в режиме fsNormal,
    //это происходит в случае опсии myfoModal явно, или если вызов из модельного окна)
    class procedure AfterFormClose(AForm: TForm);
    //проверяем, запущены ли уже экземпляры такой формы
    //вернет True, если можно запускать форму
    //в любом случае переключит на передний план форму, если найдет с таким формдок и айди
    //для myfoMultiCopy, для режимов добавления/кпинрования, fNone - откроет новую форму
    //но если найдет, независимо от айди, и нет myfoMultiCopy, то не разрешит открыть новую
    class function TestMultiInstances(AFormDoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant): Boolean;
    function FindCmp(AParent: TWinControl; AControlName: string; ASuffix: Integer = 0): TComponent;
  public
    { Public declarations }
    //айди модуля, требуется для работы панели открытых окон
    property ModuleId: Integer read FModuleId;
    //ид документа
    property FormDoc: string read FFormDoc write FFormDoc;
    //режим формы, не важен для списков
    property Mode: TDialogType read FMode write  FMode;
    //родительская форма, должно устанавливаться в потомках в перекрытом конструкторе
    property ParentForm: TComponent read FParentForm;
    property ParentControl: TComponent read FParentControl;
    //айди записи, не важно для списков.
    property ID: Variant read FID write FID;
    //дополнительные параметры формы (можно передать произвольный массив с помощью VarArrayOf)
    property AddParam: Variant read FAddParam;
    //опции поведения формы, передаваемые как правило при вызове функции ее отображения
    //(myfoModal, myfoDialog, myfoDefault, myfoMultiCopy, myfoMultiCopyWoId, myfoOneCopy, myfoEnableMaximize, myfoSizeable, myfoRefreshParent)
    property MyFormOptions: TMyFormOptions read FMyFormOptions write FMyFormOptions;
    //данные были изменены
    property IsDataChanged: Boolean read FIsDataChanged;

    //процедура проверки верности вввода
    //проверяет только по массиву условий проверов
    //если Sender = nil то проверяет все контролы, иначе переданный
    //onInput указывает что проверка производится в момент изменения значений контрола
    //если хотя бы один контрол не валиден, выставляется для него статус Error
    //таким образом, все проверяемые контролы должны быть типа Eh
    //общий статус HasError проверяетсмя на основе встроенных статусов Eh - контролов,
    //если HasError = True, то кнопка ОК блокирется
    //процедра здесь вызывается в собылиях изменения и потери фокуса для контрола, а полная проверка
    //при показе окна и при нажатии ОК
    procedure Verify(Sender: TObject; onInput: Boolean = False); virtual;

    {--------------------------------------------------------------------------}
    {  эти функции используем для создания и открытия формы-потомка, они достаточны для большинства мди-чайлд форм, в которых происходит отображание
     и изменение данных и не должны в этом случае перекрываться.
       также при создании на основе формы сложного модального диалога может иметь смысл переопределить данную функцию или создать аналогичную, выполнив шаги,
     сделанные в данной реализации. чтобы реализовать логику (утановка контролов по переданным параметрам, вызов окна в диалоговом режиме, возврат значений
     в результате функции или в вар-параметрах, приходится в class function определять локальную процедуру PSetControlsProc(ASelf: TObject; AControlValues: TVarDynArray),
     передавать в конструктор массив занчений контролов и указатель на данную процедуру, и в ней прописывать логику устаноки статических контролов
     (так как отрисовка вызовется уже в конструкторе и далее будет ожидание закрытия формы, и избежать жээтого нельзя. PSetControlsProc вызовется в конструкторе перед отрисовкой.
     после вызова конструктора надо инициализировать возвращаемые параметры значениями контролов
     }

    //вызывает форму с указанными параметрами,
    //возвращает результат типа Vavariant из свойтва формы, устанавливаемый в произвольном месте в коде при ее работе (имеет смысл как правило в режиме ShowModal)
    class function Show(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult; virtual;
    //вызывает форму с указанными параметрами, но всегда в модальном режиме, возвращает MadalResult
    class function ShowModal2(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult; virtual;
  end;



var
  FrmBasicMdi: TFrmBasicMdi;

implementation

uses
  uWindows, uSettings, uFrmMain, uDBOra, uForms, uMessages, uFrDbGridEh
  ;

{$R *.dfm}


procedure TFrmBasicMdi.RefreshStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
//установим левую и правую надпись в статусбаре окна (по факту в панели) и его видимость
//лейблы колоризованные и параметры могут принимать как массив так и строку (формат см в uLabelColors)
//если невидим, то форма уменьшитсЯ автоматически, устанавливать в потомках высоту статусбара = 0 или скрывать кроме этой процедуры не надо
//в потомках может быть установлена любая ваысота статусбара, это корректно обрабатывается
//если в процессе работы формы посредством вызова SetStatusBar меняется его статус видимсоти, то он появится или исчезнет, высота формы скорректируется (увеличится/уменшится вниз)
//если форма сделана не путем создания Инхеритед через мастер - эту процедуру вообще не ваызывать - поломает размер формы
var
  b: Boolean;
  st: string;
begin
  if not pnlStatusBar.Visible then
    Exit;
  FInSetStatusBar := True;
  pnlStatusBar.Visible := (FOpt.StatusBarMode <> stbmNone);
  pnlStatusBar.BevelInner := bvNone;
  pnlStatusBar.BevelOuter := bvNone;
  pnlStatusBar.Color := cl3DLight;

  repeat
    b := (pnlStatusBar.Visible = AVisible) or (FStatusBarHeight = -1);
    if FStatusBarHeight = -1 then
      FStatusBarHeight := pnlStatusBar.Height;
  //фиксим баг, когда статусбар может уехать в середину формы при наличии панелей с выравнивание alBotoom, alcleent...
    if not b then
      Self.ClientHeight := Self.ClientHeight + S.IIf(AVisible, FStatusBarHeight, -FStatusBarHeight);
    if FInPrepare and not AVisible then
      Self.ClientHeight := Self.ClientHeight - FStatusBarHeight;
    if AVisible then
      pnlStatusBar.Height := FStatusBarHeight;
    if not AVisible then
      pnlStatusBar.Height := 0;
    if AVisible then
      pnlStatusBar.Top := 1000
    else
      pnlStatusBar.Top := Self.ClientHeight - pnlStatusBar.Height;
    if not pnlStatusBar.Visible then
      Break;

    if FAfterFormShow or FInPrepare then begin  //!!!
      ;
      if FOpt.StatusBarMode = stbmDialog then begin
        if HasError then
          TextRight := '$0000FFНекорректные данные!'
        else if FIsDataChanged then
          TextRight := '$FF00FFДанные ' + S.Iif(Mode = fAdd, 'введены.', 'изменены.')
        else
          TextRight := '';
        TextLeft := Cth.FModeToCaption(Mode);
      end;

      if TextLeft = '*' then
        TextLeft := FTextLeft;
      if TextRight = '*' then
        TextRight := FTextRight;

      //проверка обязательна! в mdi_grid1 сейчас вызывается в repaint и если не проверять очень тормозит при изменении размера
      if (VarToStr(TextLeft) = S.NSt(FTextLeft)) and (VarToStr(TextRight) = S.NSt(FTextRight)) and (FStatusBarHeight = pnlStatusBar.Height) then
        Break;

      if TextLeft <> '*' then
        FTextLeft := TextLeft;
      if TextRight <> '*' then
        FTextRight := TextRight;

      if VarIsArray(FTextLeft) then
        lblStatusBarL.SetCaptionAr2(FTextLeft)
      else
        lblStatusBarL.SetCaption2(FTextLeft);
      if VarIsArray(FTextRight) then
        lblStatusBarR.SetCaptionAr2(FTextRight)
      else begin
        st := Trim(VarToStr(FTextRight));
        if (st = '') or (st[1] <> '$') then begin
          lblStatusBarR.Font.Color := clBlack;
          lblStatusBarR.Caption := st;
        end
        else begin
          lblStatusBarR.Font.Color := StrToInt(Copy(st, 1, 7));
          lblStatusBarR.Caption := Copy(st, 8);
        end;
      end;
    end;
  until True;
  FInSetStatusBar := False;
end;


function FindControl(AControl: TWinControl; AName: string): TControl;
var
  i, j: Integer;
begin
  Result:= nil;
  for i:= 0 to AControl.ControlCount -1 do
    if S.CompareStI(AControl.Controls[i].Name, AName)
      then begin Result:= AControl.Controls[i]; Exit; end;
  ;
end;

procedure SetPanelsAlign(AParent: TWiNControl; AVertical: Boolean = False);
//выравнивание панелей в контейнере по горизонтали,
//порядок панелей указывается тегами, положительные располагаются слева, начиная с 1,
//отрицательные получают alRight, самой правой будет с тегом -1
//с тегом 0 получают alClient (такая дожня быть одна или ни одной)
//!!! AVertical пока не обрабатывается
var
  i, j, k, l: Integer;
  p: TPanel;
  va: TVarDynArray2;
  st: string;
begin
  va:=[];
  For i:= AParent.ControlCount - 1 downto 0 do
    if AParent.Controls[i] is TPanel then begin
      p:= TPanel(AParent.Controls[i]);
      va:= va + [[i, p.Tag, p.Name]];
      p.Align:= alNone;
      p.Anchors:=[];
      //p.Caption:=inttostr(p.tag);  //для контроля
    end;
  A.VarDynArray2Sort(va, 0);
  A.VarDynArraySort(va, 1);
  l:=0;
  k:=0;
  for i:= 0 to High(va) do begin
    if va[i, 1] > 0 then begin
      p:= TPanel(AParent.Controls[va[i][0]]);
      st:=p.Name;
      p.Left:=k;
      p.Align:= alLeft;
      k:=p.Left+p.Width;
    end;
  end;
  l:=k;
  k:=AParent.Width;
  for i:= High(va) downto 0 do begin
    if va[i, 1] < 0 then begin
      p:= TPanel(AParent.Controls[va[i][0]]);
      st:=p.Name;
      p.Left:=k-p.Width - 10;
      p.Align:= alRight;
      k:=p.Left;
    end;
  end;
  for i:= 0 to High(va) do begin
    if va[i, 1] = 0 then begin
      p:= TPanel(AParent.Controls[va[i][0]]);
      st:=p.Name;
      p.Left:=l;
      p.Align:= alClient;
    end;
  end;
end;

procedure VertAlignCtrls(AParent: TWiNControl);
var
  i, j: Integer;
begin
  For i:= AParent.ComponentCount - 1 downto 0 do begin
    if AParent.Components[i] is TBitBtn
      then TBitBtn(AParent.Components[i]).Top:= (AParent.Height - TBitBtn(AParent.Components[i]).Height) div 2;
  end;
  For i:= AParent.ControlCount - 1 downto 0 do
    AParent.Controls[i].Top:= (AParent.Height - AParent.Controls[i].Height) div 2;
end;


procedure TFrmBasicMdi.RefreshDlgPanel;
//изменим свойства, установим кнопки для диалоговой панели
//(обычно внизу окна)
//содержит основную панель кнопоку, кнопки зависят от режима формы и генерируются динамически, но всегда btnOk и btnCancel, меняются текст и картинка
//панели кнопок слева, справа, панель с чекбоксом повтора ввода, и панель на оставшееся свободной место
//если переданы массивы кнопок в опт, то будут созданы эти кнопки. если ничего не передано, панели будут скрыты
//если высота маленькая, то подгоняется по минимальному размеру кнопок, иначе останется как есть.
//можно создать элементы вручную. автоматически созданные, и контролы первого уровня (и компоненты-кнопки), центрируются по вертикали
//панель может иметь направление кнопо с основными справа (по умолчанию) или слева, быть расположена снизу (по умолчанию) или сверху
//если минимальная длина меньше длины паенли без центрального провежутка, то она устанавливается суммарной длине панели кнопок
var
  i, j: Integer;
  p: TPanel;
  PTemp: TPanel;
  c: TComponent;
  st: string;
begin
  //если форма создана при запуске приложения и уже отображалась, то выйдем
  if FAllreadyCreated then
    Exit;
  if FOpt.DlgPanelStyle = dpsNone then begin
    pnlFrmBtns.Height:= 0;
    pnlFrmBtns.Visible:= False;
    Exit;
  end;
  pnlFrmBtnsContainer.Padding.Top := MY_FORMPRM_BTNPANEL_V_EDGES;
  pnlFrmBtnsContainer.Padding.Bottom := pnlFrmBtnsContainer.Padding.Top;
  pnlFrmBtns.Height:= Max(pnlFrmBtns.Height, MY_FORMPRM_BTN_DEF_H + pnlFrmBtnsContainer.Padding.Top * 2 + 2 * 2 + 4);
  if FOpt.DlgPanelStyle in [dpsTopLeft, dpsTopRight]  then begin
    pnlFrmClient.Align:=alNone;
    pnlFrmBtns.Align:=alTop;
    pnlFrmClient.Align:=alClient;
    pnlFrmBtnsContainer.Top:= 0;
  end;
  bvlFrmBtnsB.Visible:= FOpt.DlgPanelStyle in [dpsTopLeft, dpsTopRight];
  bvlFrmBtnsTl.Visible:= not bvlFrmBtnsB.Visible;
  PTemp:=TPanel.Create(Self);
  i:=pnlFrmBtnsContainer.ControlCount;
  For i:= pnlFrmBtnsContainer.ControlCount - 1 downto 0 do
    if pnlFrmBtnsContainer.Controls[i] is TPanel then begin
      p:= TPanel(pnlFrmBtnsContainer.Controls[i]);
      p.Caption:='';
      p.BevelInner:= bvNone;
      p.BevelOuter:= bvNone;
      p.Height:= pnlFrmBtnsContainer.Height;
    end;
  if FOpt.DlgPanelStyle in [dpsTopLeft, dpsBottomLeft] then begin
    pnlFrmBtnsMain.Tag:= 1;
    pnlFrmBtnsChb.Tag:= 2;
    pnlFrmBtnsL.Tag:= 3;
    pnlFrmBtnsR.Tag:= -2;
    pnlFrmBtnsInfo.Tag:= -1;
  end
  else begin
    pnlFrmBtnsChb.Tag:= -3;
    pnlFrmBtnsR.Tag:= -2;
    pnlFrmBtnsMain.Tag:= -1;
  end;
  SetPanelsAlign(pnlFrmBtnsContainer);
  Cth.CreateButtons(pnlFrmBtnsMain,
    [[mbtOk, Mode in [fEdit, FAdd, fCopy, fDelete], S.Decode([Mode, fDelete, 'Удалить', 'Ок']), S.Decode([Mode, fDelete, 'delete', 'ok'])],
     [mbtCancel, True, S.Decode([Mode, fView, 'Закрыть', fNone, 'Закрыть', 'Отмена']), S.Decode([Mode, fView, 'viewclose', fNone, 'cancel', 'cancel'])]],
    btnCancelClick, cbttBNormal, '', 0, 0, False);
  //если не сделать заведомо длиную панель, может нарушаться порядок панелей, если в какой-либо из них динамически установленная длина превысит ту, что в дизайнере формы
  //в конце поставим pnlFrmBtnsMain.AutoSize := True;
  pnlFrmBtnsMain.AutoSize := False;
  pnlFrmBtnsMain.Width := 1024 * 10;
    //основной кнопке назначим обработчик для закрытия если это просмотр или пустой режим, во всех остальных случаях обработчик OK
  if Mode in [fView, fNone]
    then btnCancel := TBitBtn(pnlFrmBtnsMain.Controls[0])
    else begin
      btnOk := TBitBtn(pnlFrmBtnsMain.Controls[0]);
      btnCancel := TBitBtn(pnlFrmBtnsMain.Controls[1]);
    end;
  if btnOk <> nil then begin
    TButton(btnOk).OnClick:= btnOkClick;
    TButton(btnOk).Cancel := False;
    TButton(btnOk).ModalResult := mrNone;
  end;
  if btnCancel <> nil then begin
    TButton(btnCancel).OnClick:= btnCancelClick;
    TButton(btnCancel).Cancel := FMode in [fView, fDelete];
    TButton(btnCancel).ModalResult := mrCancel;
  end;
  Self.ModalResult := mrNone;
  //btnOk.ModalResult:= mrOk;
  //если есть динамическмие кнопки для левой и правой панели, то создадим кнопки и изменим размер панели,
  //иначе, если в ней нет контролов, то выставим ширину = 0, а если есть то оставим размеры без изменения
  if Length(FOpt.DlgButtonsL) > 0
    then Cth.CreateButtons(pnlFrmBtnsL, FOpt.DlgButtonsL, btnClick, cbttBNormal, '', 0, 0, False)
    else if pnlFrmBtnsL.ControlCount = 0
      then pnlFrmBtnsL.Width := 0;
  if Length(FOpt.DlgButtonsR) > 0
    then begin
      Cth.CreateButtons(pnlFrmBtnsR, FOpt.DlgButtonsR, btnClick, cbttBNormal, '', 0, 0, False);
    end
    else if pnlFrmBtnsR.ControlCount = 0
      then pnlFrmBtnsR.Width := 0;
  //если в панелях есть только разделитель, уберем его
  if (pnlFrmBtnsL.ControlCount = 1) and (pnlFrmBtnsL.Controls[0] is TBevel) then
    pnlFrmBtnsL.Controls[0].Free;
  if (pnlFrmBtnsR.ControlCount = 1) and (pnlFrmBtnsR.Controls[0] is TBevel) then
    pnlFrmBtnsR.Controls[0].Free;
{  for i := 0 to pnlFrmBtnsL.ComponentCount - 1 do
    if (pnlFrmBtnsL.Components[i] is TButton) and not Assigned(TButton(pnlFrmBtnsL.Components[i]).OnClick) then
      TButton(pnlFrmBtnsL.Components[i]).OnClick := BtClick;
  for i := 0 to pnlFrmBtnsR.ComponentCount - 1 do
    if (pnlFrmBtnsL.Components[i] is TButton) and not Assigned(TButton(pnlFrmBtnsL.Components[i]).OnClick) then
      TButton(pnlFrmBtnsL.Components[i]).OnClick := BtClick; }
//  Cth.CreateButtons(pnlFrmBtnsR, FOpt.DlgButtonsR, BtClick, cbttBNormal, '', 0, 0, False);
  pnlFrmBtnsChb.Visible:=FOpt.UseChbNoClose and (Mode in [FAdd, FCopy]);
  //если на форме не найдено картинки с именем ImgInfoMain, то переименуем картинку в этой панели в нее, она станет главной подсказкой формы
  //иначе скроем панель подсказки
  c:= FindComponent('ImgInfoMain');
  if (c = nil) and (Length(Cth.SetInfoIconText(Self, FOpt.InfoArray)) > 0) then begin
    imgFrmInfo.Left:= 3;
    imgFrmInfo.Name:= 'ImgInfoMain';
  end;
  c:= FindComponent('ImgInfoMain');
  if (c <> nil) and (TControl(c).Parent = pnlFrmBtnsInfo)
    then pnlFrmBtnsInfo.Width := MY_FORMPRM_BTN_DEF_H + 4
    else pnlFrmBtnsInfo.Width := 0;
  For i:= pnlFrmBtnsContainer.ControlCount - 1 downto 0 do begin
    TWinControl(pnlFrmBtnsContainer.Controls[i]).Height:= pnlFrmBtnsContainer.ClientHeight;
    VertAlignCtrls(TWinControl(pnlFrmBtnsContainer.Controls[i]));
  end;
  pnlFrmBtnsMain.AutoSize := True;
  FDlgPanelMinWidth:= Self.Width {- pnlFrmBtnsContainer.ClientWidth} - pnlFrmBtnsC.Width;
end;
























class function TFrmBasicMdi.Show(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult;
var
  F: TForm;
begin
  F:= Create(AOwner, ADoc, AMyFormOptions, AMode, AID, AAddParam, []);
  Result := TFrmBasicMdi(F).FFormResult;
  AfterFormClose(F);
end;

class function TFrmBasicMdi.ShowModal2(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult;
var
  F: TForm;
begin
  F:= Create(AOwner, ADoc, AMyFormOptions + [myfoModal], AMode, AID, AAddParam, []);
  Result := TFrmBasicMdi(F).FFormResult;
  Result.ModalResult := TFrmBasicMdi(F).ModalResult;
  AfterFormClose(F);
end;

constructor TFrmBasicMdi.Create(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; Aid: Variant; AAddParam: Variant; AControlValues: TVarDynArray; APSetControls: pointer = nil);
//конструктор класса
procedure PSetControlsProc;
begin
  TSetControlsProc(APSetControls)(Self, AControlValues);
end;
begin
  FFormNotCreatedByApplication := True;
  if APSetControls <> nil then
    PSetControlsProc;
  //(пере)покажем форму
  //вызов не может быть вынесен из конструктора в фуункции класса
  if not PrepareCreatedForm(AOwner, ADoc, '', AMode, Aid, AMyFormOptions, False) then
    Exit;
  FAddParam := AAddParam;
  ShowForm(Self);
end;

procedure TFrmBasicMdi.InitializeNewForm;
//процедура нужна для подмены стиля формы.
var
  FS: ^TFormStyle;
  v: Variant;
begin
  inherited;
  if not FFormNotCreatedByApplication then begin
    FModuleId := cMainModule;
    FStatusBarHeight := -1;
    Exit;
  end;
  if not (myfoModal in MyFormOptions) then begin
    FS := @FormStyle;
    FS^ := fsMDIChild;
  end
  else begin
    FS := @FormStyle;
    FS^ := fsNormal;
  end;
end;

class procedure TFrmBasicMdi.ShowForm(AForm: TForm);
//отображение формы в зависимости от режима FormStyle, вызывается в class function инициализации
begin
  if not TFrmBasicMdi(AForm).FFormNotCreatedByApplication then
    Exit;
 //AForm.Formstyle := fsMDIChild;
  if AForm.Formstyle = fsNormal then
    AForm.Hide;
  //обработка отображения формы в случае модального режима
  if AForm.Formstyle = fsNormal then begin
    TFrmBasicMdi(AForm).FToLoadData := True;
    //загрузим данные в форму и настроим ее в потомке
    TFrmBasicMdi(AForm).AfterCreate;
    //если функция Prepare (вызывается в AfterCreate) вернула False, то показывать форму не будем
    if TFrmBasicMdi(AForm).FPrepareResult then begin
      TFrmBasicMdi(AForm).FFormResult.ModalResult := AForm.ShowModal;
    end;
  end  //обработка отображения формы в случае режима MDI_Child
  else begin
    TFrmBasicMdi(AForm).FToLoadData := True;
    //загрузим данные в форму и настроим ее в потомке
    //здесь, так как это непосредственно перед финальным отображением, и форма не мелькает,
    //пока грузятся данные она не видна (как и было ранее)
    TFrmBasicMdi(AForm).AfterCreate;
    //если функция Prepare (вызывается в AfterCreate) вернула False, то показывать форму не будем
    if TFrmBasicMdi(AForm).FPrepareResult then
      AForm.Show;
  end;
end;

procedure TFrmBasicMdi.ShowFormAsMdi;
//показать скрытую mdi-child форму
begin
  Self.Formstyle := fsMDIChild;
  TCustomForm(Self).Show;
  ShowWindow(Handle, SW_SHOW);
  Wh.ChildFormActivate(Self);
end;

class procedure TFrmBasicMdi.AfterFormClose(AForm: TForm);
//действия поле закрытия формы (нужны в случае, если форма была создана в режиме fsNormal,
//это происходит в случае опсии myfoModal явно, или если вызов из модального окна)
begin
  //форма не в режиме нормал, выйдем.
  if TFrmBasicMdi(AForm).FormStyle <> fsNormal
    then Exit;
  //если модальная форма, и вызов непосредственно из главной формы приложения, то если не было отрисовки самой формы (prepare вернула False)
  //то почему-то все приложение теряет фокус. пофиксим, установив фокус на родительскую форму, если не передана то на главную.
  if TFrmBasicMdi(AForm).ParentForm = nil
    then FrmMain.SetFocus
    else TForm(TFrmBasicMdi(AForm).ParentForm).SetFocus;
  //освободим ресурсы формы
  //в случае fsNormal caFree в FormClose не срабатывает судя по всему, это видно и по коду обработчика в vcl.Forms
  //если использовать Release, то значения полей почему-то остаются доступны
  //если поместить TEdit на форму, то его значения после вызова формы в модальном режиме все рпвно читается.
  //также читается значение контрола, созданного в дочерней форме, при приведении типа формы.
  //После Free будет получено пустой значение контрола этой формы или вообще ошибка, в зависимости от контрола.
  //однако для созданных динамически кнопок например текст возвращается, даже если здесь вызвать явно TFrmBasicMdi(AForm).btnOk.Free;
  //Release посылает себе же сообщение CM_RELEASE, и должно корректно уничтожить форму, из сообщений лучше использовать ее
  //однко Free по справке использовать также корректно
  //владелец объекта отвечает за вызов деструктора этого объекта при вызове своего собственного деструктора, так что динамически
  //созданные объекты должны быть разрушены автоматически
//  TFrmBasicMdi(AForm).Release;
  TFrmBasicMdi(AForm).Free;
end;


class function TFrmBasicMdi.TestMultiInstances(AFormDoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant): Boolean;
//проверяем, запущены ли уже экземпляры такой формы
//вернет True, если можно запускать форму
//в любом случае переключит на передний план форму, если найдет с таким формдок и айди
//для myfoMultiCopy, для режимов добавления/кпинрования, fNone - откроет новую форму
//но если найдет, независимо от айди, и нет myfoMultiCopy, то не разрешит открыть новую
var
  nm: Integer;
begin
  Result := True;
  if AFormDoc = '' then
    Exit;
  //можно много копий, и это или справочники, или же диалог добавления/копирования (айдит не задан) - откроем новую форму
  if (myfoMultiCopy in AMyFormOptions) and (AMode in [fNone, fAdd, fCopy]) then
    Exit;
  //иначе, не важно разрешено ли много копий - форму на передний план
  //если форма с таким айди уже есть - переключит на передний план
  if (myfoMultiCopy in AMyFormOptions) then
    Result := Wh.BringToFrontIfExists(AFormDoc, AID)
  else
    Result := Wh.BringToFrontIfExists(AFormDoc, null);
end;

procedure TFrmBasicMdi.AfterCreate;
//действия после создания формы (точнее, вызываем ее конструкторе, после стандартного, перед самым показом формы)
//вызываем функцию потомка загрузки данных и настроки Prepare, выходит буз показа формы если она вернула False
//вызывает функцию потомка AfterPrepare, для совершения дополнительных действий
begin
  FInPrepare := True;
  Cth.SetWaitCursor;
  FPrepareResult := Prepare;
  Cth.SetWaitCursor(False);
  if not FPrepareResult then begin
    //закроем форму
    ExitWithoutShow;
  end;
  FInPrepare := False;
  Cth.SetWaitCursor;
//  pnlStatusBar.Visible:= Opt.HasStatusBar;
  AfterPrepare;
  Cth.SetWaitCursor(False);
  //устанавливаем возможность изменения размеров формы (установив соотв бордерстайл)
  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;
end;


procedure TFrmBasicMdi.CenteringByParent;
//центрирование формы по родительской
var
  x, y, i: Integer;
  b: Boolean;
  st: string;
begin
  x := FrmMain.Height;
  i := FrmMain.ClientHeight;
  x := FrmMain.lbl_GetTop.top;
  i := FrmMain.lbl_GetBottom.top;
  x := TForm(ParentForm).Left + TForm(ParentForm).Width div 2 - Self.Width div 2;
  if x + Self.Width > FrmMain.ClientWidth - 10 then
    x := FrmMain.ClientWidth - Self.Width - 30;
  Self.Left := max(x, 0);
  x := TForm(ParentForm).Top + TForm(ParentForm).Height div 2 - Self.Height div 2;
  if x + Self.Height > FrmMain.FormsList.Top - FrmMain.lbl_GetTop.Top - 10 then
    x := FrmMain.FormsList.Top - FrmMain.lbl_GetTop.Top - Self.Height - 10;
  Self.Top := max(x, 0);
end;

procedure TFrmBasicMdi.tmrAfterCreateTimer(Sender: TObject);
begin
  tmrAfterCreate.Enabled := False;
  AfterStart;
end;

procedure TFrmBasicMdi.AfterStart;
begin
end;


function TFrmBasicMdi.FormDbLock(msg: string = '*|*'): TDialogType;
//пытается взять блокировку для формы,
//только в случае заданных FFormDoc и ID и только для режимов fNone, fEdit, fDelete
//в результате, если блокировку взять не удалось, выведет сообщение,
//режим формы изменит на fView ели первоначльно было редактирование, или на fNone в случае удаления
//в последднем случае в потомке надо обработать и (обычно) выйти без отображения
begin
  FLockInDB := FMode;
  Result := FMode;
  if (FFormDoc = '')or(FID = null) then Exit;
  FMode := Q.DBLock(True, FFormDoc, VarToStr(FID), msg, FMode)[3];
  FLockInDB := FMode;
  Result := FMode;
end;

procedure TFrmBasicMdi.ExitWithoutShow;
begin
  Left := mycHiddenFormLeft;
  Self.Close;
end;

function TFrmBasicMdi.Prepare: Boolean;
begin
  Result := True;
end;

procedure TFrmBasicMdi.AfterPrepare;
begin
//  RefreshDlgPanel;
//  CorrectFormSize;
//  Cth.SetDialogCaption(Self, Mode, Self.Caption);
//  RefreshStatusBar('','',True);  //при подгонке размеров формы портится правый текст, это не помогает
end;

procedure TFrmBasicMdi.SetMainInfoIcon;
//настроем основную инфо-иконку приложения,
//если найден компонент-TImage с именем ImgInfoMain
//при этом размер будет скорректирован к маленькому если имя кончается на 'main' и к большому если на 'MAIN', иначе размер не изменится
var
  c: TComponent;
  wh: Integer;
begin
  c:= FindComponent('ImgInfoMain');
  if c = nil then Exit;
  if S.Right(c.Name, 4) = 'main'
    then wh := MY_FORMPRM_BTN_DEF_H
    else if S.Right(c.Name, 4) = 'MAIN'
      then wh := MY_FORMPRM_SPEEDBTN_DEF_H
      else wh := TImage(c).Width;
  if (c = nil)or not (c is TImage) then Exit;
  Cth.SetInfoIcon(TImage(c), Cth.SetInfoIconText(Self, FOpt.InfoArray), wh);  //!!
end;


function TFrmBasicMdi.RefreshParentForm: Boolean;
var
  i: Integer;
  Form: TForm;
begin
  if not FOpt.RefreshParent then
    Exit;
  if ParentForm <> nil then
  try
    if (ParentForm is TFrmBasicMdi) then begin
      if TFrmBasicMdi(ParentForm).FindComponent('Frg1') <> nil then
        TFrDbGridEh(TFrmBasicMdi(ParentForm).FindComponent('Frg1')).RefreshGrid;
    end;
  except
  end;
end;


function TFrmBasicMdi.IsScrollBarVisible(isVert: Boolean = True): Boolean; //(WindowHandle: THandle)
begin
  if isVert then
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_VSCROLL) <> 0
  else
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_HSCROLL) <> 0;
end;

procedure TFrmBasicMdi.GetFormLTWH;
begin
  FPrevLeft := Left;
  FPrevTop := Top;
  FPrevWidth := Width;
  FPrewHeight := Height;
end;

procedure TFrmBasicMdi.CorrectFormSize;
//корректировка размеров формыформы по данным WHCorrected, если, например, была подгонка контролов
var
  i, j ,r: Integer;
  ar, at: TControlArray;
  c: TComponent;
  st: string;
begin
  //подгоним/выровняем контролы в основной панели
  if FOpt.AutoAlignControls then
    FWHCorrected := Cth.AlignControls(pnlFrmClient, FOpt.ControlsWoAligment, False);
  if FOpt.AutoAlignControls then
    Cth.MakePanelsFlat(pnlFrmClient, []);
  //запомним контролы, у которых якоря по правому и нижнему краю, и сбросим эти якоря
  for i := 0 to Self.ComponentCount - 1 do begin
    c := Self.Components[i];
    if c is TControl then begin
      if not Cth.IsChildControl(pnlFrmClient, TControl(c), True) then
        Continue;
      if (akRight in (TControl(c).Anchors)) or (c.Tag = -100) then begin
        ar := ar + [TControl(c)];
        TWinControl(c).Anchors := TControl(c).Anchors - [akRight];

      end;
      if akBottom in (TControl(c).Anchors) then begin
        at := at + [TControl(c)];
        TWinControl(c).Anchors := TControl(c).Anchors - [akBottom];
      end;
    end;
  end;
    //если видна панель кнопок, посчитаем ее минимально допустимую ширину
  //!!! пока не учитываем центральную панель, ширина которой автоматическая alClient
  j:= 0;
  if FOpt.DlgPanelStyle <> dpsNone then begin
    j:=pnlFrmBtnsMain.Width + pnlFrmBtnsL.Width + pnlFrmBtnsR.Width + S.IIf(pnlFrmBtnsChb.Visible, pnlFrmBtnsChb.Width, 0) + S.IIf(pnlFrmBtnsInfo.Visible, pnlFrmBtnsInfo.Width, 0) + 12;
  end;
  //минимальная ширина не меньше ширины панели
//  WHBounds.X:= Max(WHBounds.X, FDlgPanelMinWidth);
//  WHCorrected.X:= Max(Max(WHCorrected.X, FDlgPanelMinWidth), WHBounds.X);
  //если есть данные для корректировки, применим их
  //установим размеры клиентской области
  //установим минимальные ширину и высоту
  if (FWHCorrected.X <> 0) then
    ClientWidth := FWHCorrected.X + MY_FORMPRM_H_EDGES + 2;
  if ClientWidth < j then
    ClientWidth := j;
  if (FWHBounds.X = 0) then
    FWHBounds.X := Width;

  if (FWHCorrected.Y <> 0) then
    ClientHeight := FWHCorrected.Y + MY_FORMPRM_V_TOP * 2 + pnlFrmBtns.Height + S.IIf(pnlStatusBar.Visible and (FOpt.StatusBarMode <> stbmNone), pnlStatusBar.Height, 0);
  if (FWHBounds.Y = 0) then
    FWHBounds.Y := Height;

{
  if (FWHCorrected.X <> 0) or (j <> 0) then begin
    ClientWidth := Max(ClientWidth, Max(FWHCorrected.X + MY_FORMPRM_H_EDGES + 2, j));  //почему-то так подгоняется нормально ширина
    if (FWHBounds.X = 0) then
      FWHBounds.X := Width;
  end;}
{  if (FWHCorrected.Y <> 0) or (FOpt.DlgPanelStyle <> dpsNone) then begin
    ClientHeight := FWHCorrected.Y + MY_FORMPRM_V_TOP * 2 + pnlFrmBtns.Height + S.IIf(pnlStatusBar.Visible, pnlStatusBar.Height, 0);
    if (FWHBounds.Y = 0) then
      FWHBounds.Y := Height;
  end;}
    //восстановим якоря
  for i:= 0 to High(ar) do
    TControl(ar[i]).Anchors:= TControl(ar[i]).Anchors + [akRight];
  for i:= 0 to High(at) do
    TControl(at[i]).Anchors:= TControl(at[i]).Anchors + [akBottom];
  //если верхние границы размеров формы -1, или положительные (но не ноль) - установим их равными нижним границам
  if (FWHBounds.X2 <> 0) and ((FWHBounds.X2 = -1) or (FWHBounds.X2 < FWHBounds.X))
    then FWHBounds.X2:= FWHBounds.X;
  if (FWHBounds.Y2 <> 0) and ((FWHBounds.Y2 = -1) or (FWHBounds.Y2 < FWHBounds.Y))
    then FWHBounds.Y2:= FWHBounds.Y;
  //флаг, что размеры формы скорректированы (иначе неверно работает, если минимальная ширина больше проектной или сохраненной - в FormCanResize
  FWinSizeCorrected:= True;
end;

//обработчик сообщений
procedure TFrmBasicMdi.WMSysCommand(var Msg: TWMSysCommand);
begin
//  DefaultHandler(Msg);Exit;
  if Msg.CmdType = SC_ZOOM then
  //по кнопке восстановить/раскрыть
  //так как МДИ, и все окна могут быть в одном статусе одновременно только
  //эмулируем работу сворачивания/разворачивания
  begin
    Self.WindowState := wsNormal;
    if FIsMaximized then begin
      //вернем ранее запомненные положания и размер
      FInMaxMin := True;
      Self.Top := FPrevTop;
      Self.Left := FPrevLeft;
      Self.Width := FPrevWidth;
      Self.Height := FPrewHeight;
      Msg.Result := 0;
      FInMaxMin := False;
      FInMaxMin := False;
      FIsMaximized := False;
      Exit;
    end
    else begin
      //расхлопнем на весь экран
      //высота не совсем корректно сделана, условно вычитаем ширину на скроллер и высоту на меню/панели, методом подгонки
      FInMaxMin := True;
      GetFormLTWH;
      Self.Top := 0;
      Self.Left := 0;
      Self.Width := FrmMain.ClientWidth - 5;
      Self.Height := FrmMain.ClientHeight - 45;
      //если все-таки скроллбар появился, то вычтем его размеры (по идее, он должен исчезнуть, а окно останется меньше чем ширина экрана)
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
{  if Msg.CmdType = SC_RESTORE then
  begin
    if Self.WindowState = wsMaximized then
    begin
      Self.WindowState:= wsNormal;//  wsMinimized;
      Msg.Result:= 0;
      Exit;
    end;
    if Self.WindowState = wsMinimized then
    begin
      Self.WindowState:= wsNormal; //wsMaximized;
      Msg.Result:= 0;
      Exit;
    end;
  end;}
  //запретим фообще wsMaximize по командам (он кроме перехваченных выше возможен по даблклику на заголовке окна)
  DefaultHandler(Msg);
  if WindowState = wsMaximized then
    WindowState := wsNormal;
end;

function TFrmBasicMdi.FindCmp(AParent: TWinControl; AControlName: string; ASuffix: Integer = 0): TComponent;
var
  i: Integer;
  c: TComponent;
begin
  Result:= nil;
  if ASuffix <> 0
    then AControlName := AControlName + 'Sfx' + IntToStr(ASuffix);
  for i:=0 to AParent.ComponentCount - 1 do begin
    c:= AParent.Components[i];
    if S.CompareStI(c.name, AControlName)
      then begin
        Result:= c;
        Exit;
      end
      else if (c is TWinControl) or (c is TFrame)
        then FindCmp(TWinControl(c), AControlName, ASuffix);
  end;
end;

procedure TFrmBasicMdi.SetControlEvents;
//устанавливаем события (изменение, потеря фокуса, отрисовка статуса ошибки),
//а также условия проверки контролов
var
  i: Integer;
begin
  //параметры проверки контролов установив для них
  //передается массив имен контролов и их условий проверки [cname1, cver1, cname2, cver2...]
  Cth.SetControlsVerification(Self, FControlVerifycations);
  //назаначим события всем дб-контролам формы, если они не были назначены явно в дизайнере формы или в Prepare
  Cth.SetControlsEhEvents(pnlFrmClient, False, True, nil, ControlOnExit, ControlOnChangeEvent, ControlCheckDrawRequiredState, EditButtonsClick);
exit;
  Cth.SetControlsOnChange(Self, ControlOnChange, True);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
end;

procedure TFrmBasicMdi.SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True; Disabled: Boolean = False; Parent: TControl = nil);
//устанавливает редактируемыми или нет (Editable) все контролы из массива AConrols;
//если последний пустой, то все контролы формы (кнопки и чекбокс повтора всегда исключаются из этой процедуры)
var
  i, j: Integer;
  c: TControl;
  va: TVarDynArray;
begin
  va := [];
  for i := 0 to High(AConrols) do
    va := va + [AConrols[i].Name];
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TWinControl then begin
      c := TControl(Components[i]);
      if not Cth.IsChildControl(pnlFrmClient, TWinControl(c), True)
        then Continue;
//      if A.PosInArray(c.Name, ['pnl_statusbar', 'lbl_StatusBar_Left', 'lbl_StatusBar_Right', 'pnl_bottom', 'bt_ok', 'bt_cancel', 'chb_NoClose'], True) >= 0 then
//        Continue;
      if (Length(AConrols) = 0) or (A.PosInArray(c.Name, va, True) >= 0) then begin
        Cth.SetControlNotEditable(c, not Editable, False, True);
        if c is TCustomDBEditEh then
          Cth.SetEhControlEditButtonState(c, Editable, Editable);
      end;
    end;
end;

procedure TFrmBasicMdi.Serialize;
//
begin
  if FOpt.NoSerializeCtrls then begin
    FCtrlCurrValuesStr := '';
    Exit;
  end;
  FCtrlCurrValuesStr := Cth.SerializeControlValuesArr2(Cth.GetControlValuesArr2(Self, nil, [], ['chb_NoClose']))
end;





function TFrmBasicMdi.GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
//получить значение контрола на форме по его имени
//если установлено NullIfEmpty то вернуть null если значение равно пустое или ''
begin
  Result:= Cth.GetControlValue(TControl(Self.FindComponent(ControlName)));
//  Result:=FindComponent
  if NullIfEmpty then Result:=S.NullIfEmpty(Result);
end;

procedure TFrmBasicMdi.ControlOnChangeEvent(Sender: TObject);
//событие изменения данных контрола
begin
  //выход если в процедуре загрузки
  if FInPrepare then Exit;
  if not FInControlOnChaange then begin
    FInControlOnChaange := True;
    ControlOnChange(Sender);
  end;
  //проверим, признак что в этом событии проверка
  Serialize;
  Verify(Sender, True);
  FInControlOnChaange := False;
end;

procedure TFrmBasicMdi.ControlOnChange(Sender: TObject);
begin

end;

procedure TFrmBasicMdi.ControlOnEnter(Sender: TObject);
begin
  //выход если в процедуре загрузки
  if FInPrepare then Exit;
end;

procedure TFrmBasicMdi.ControlOnExit(Sender: TObject);
begin
  //выход если в процедуре загрузки
  if FInPrepare then Exit;
  //проверим
  Verify(Sender);
end;

procedure TFrmBasicMdi.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

procedure TFrmBasicMdi.VerirfyGrids(Sender: TObject; var AHasError: Boolean; var AErrorSt: string; var AIsChanged: Boolean);
//проверка переданного TFrDBGridEh или же всех гридов на форме, в том числе дочерних в RowDetailPanel
var
  i, j: Integer;
begin
  AHasError := False;
  AErrorSt := '';
  AIsChanged := False;
  if Sender = nil then begin
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TFrDBGridEh then begin
        if TFrDBGridEh(Components[i]).HasError then
          AHasError := True;
        if TFrDBGridEh(Components[i]).ErrorMessage <> '' then
          AErrorSt := TFrDBGridEh(Components[i]).ErrorMessage;
        if TFrDBGridEh(Components[i]).IsDataChanged then
          AIsChanged := True;
      end;
  end;
  if Sender is TFrDBGridEh then begin
    if TFrDBGridEh(Sender).HasError then
      AHasError := True;
    if TFrDBGridEh(Sender).ErrorMessage <> '' then
      AErrorSt := TFrDBGridEh(Sender).ErrorMessage;
    if TFrDBGridEh(Sender).IsDataChanged then
      AIsChanged := True;
  end;
  if Sender = nil then
    S.ConcatStP(FErrorMessage, AErrorSt, #13#10);
end;


function TFrmBasicMdi.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//дополнительная проверка (для того, что не покрывается условиями проверки в массиве)
//должна отметить SetErrorMarker для контролов по более сложным алгоритмам, не охватываемым заданным правилам в массиве,
//или сразу вернуть статус ошибки (True) - в этом ошибка будет при любом состоянии конкреттных контролов
begin
  Result:= False;
end;

procedure TFrmBasicMdi.VerifyBeforeSave;
//обработка дополнительной проверки перед записью, если Verify вернуло Ок = True
//должно скорректировать Ок, если что-то не в порядке: если вернет в Result True,
//то будет выдано сообщение "Данные не корректны!"
begin
end;

procedure TFrmBasicMdi.Verify(Sender: TObject; onInput: Boolean = False);
//проверка правильности данных
//передается контрол для проверки, или нил - проверить все
//и признак что проверка при вводе данных в контроле (в событии onChange)
//проверяются по умолчанию все DbEh-контролы и TFrDBGridEh
//(в случае TFrDBGridEh он сам вызывает Verify родительской формы,
//или же проверяются все дочерние при nil
var
  i, j, s: Integer;
  c: TControl;
  ok1: Boolean;
  b: Boolean;
  st: string;
  GridsErr: Boolean;
  GridsErrSt: string;
  GridsCh: Boolean;

begin
  //не проверяем при первоначальной загрузки данных.
  //для первоначальной проверки надо в Prepare явно вызвать Verify(nil)
  if FInPrepare and (Sender <> nil) then Exit;
  FErrorMessage := '';
  //для просмотра и удаления всегда Ок
  if (Mode = fView) or (Mode = fDelete) then begin
    HasError := False;
    FIsDataChanged:= False;
    if btnOk <> nil then btnOk.Enabled := not HasError;
    Exit;
  end;
  if Sender = nil then begin
    //проверим все DbEh
    Cth.VerifyAllDbEhControls(Self);
    //почему-то при нажатии кнопки Ок, только на работе, после вызова выше GridsErr оказывается равен True!!!
    VerirfyGrids(nil, GridsErr, GridsErrSt, GridsCh);
  end
  else begin
    //проверим текущий
    Cth.VerifyControl(TControl(Sender), onInput);
    VerirfyGrids({Sender}nil, GridsErr, GridsErrSt, GridsCh);  //!!! вседа проверяем все гриды
  end;
  //дополнительная проверка (для того, что не покрывается условиями проверки в массиве)
  //должна отметить SetErrorMarker для контролов по более сложным алгоритмам, не охватываемым заданным правилам в массиве,
  //либо сразу установить HasError
  b:= VerifyAdd(Sender, onInput);
  //получим статус проверки и визуализируем
  HasError := not Cth.VerifyVisualise(Self) or b or GridsErr;
  if HasError and (Sender <> nil)
    then st:= TControl(Sender).Name;
  if not FInPrepare
    then FIsDataChanged:= (FCtrlCurrValuesStr <> FCtrlBegValuesStr) or (GridsCh);
//  if FOpt.StatusBarMode = stbmDialog then
    RefreshStatusBar('*', '*', True);
end;

procedure TFrmBasicMdi.SetError(Value: Boolean);
var
  b: Boolean;
begin
  b:= FHasError <> Value;
  FHasError := Value;
  //выведем информацию в статусбаре
//  if FOpt.StatusBarMode = stbmDialog then
    if b then RefreshStatusBar('*', '*', True);
  //статус кнопки Ок
  if btnOk <> nil then btnOk.Enabled := not HasError;
end;


function TFrmBasicMdi.Save: Boolean;
begin
  Result:= True;
end;

procedure TFrmBasicMdi.btnOkClick(Sender: TObject);
//обработка кнопки подтверждения
//(контрола, который присвоен полю btnOk)
begin
  FInBtOkClick:= True;
{  TButton(Sender).Cancel := False;
  TButton(Sender).ModalResult := mrNone;
  Self.ModalResult := mrNone;
  Exit;}
  repeat
  if (Mode = fView) then begin
    Self.ModalResult:= mrCancel;
    if Formstyle <> fsNormal then Close;
    Break;
  end;
  Verify(nil);
  if Mode <> fDelete then begin
    if HasError then Break;
  end;
  VerifyBeforeSave;
  if FErrorMessage <> '' then begin
    if Pos('?', FErrorMessage) = 1 then begin
      if MyQuestionMessage(Copy(FErrorMessage, 2)) <> mrYes
        then Break;
    end
    else begin
      MyWarningMessage(FErrorMessage, ['-', '*Данные не корректны!']);
      Break;
    end;
  end;
  if HasError then begin
    //если не сделать, то в случае ошибки, если в VerifyBeforeSave HasError утановлен в True, уже не сможем записать данные после внесения исправлений
    HasError := False;
    Break;
  end;
  if not Save then  Break;
  RefreshParentForm;
  if FOpt.DefFocusedControl <> nil then
    FOpt.DefFocusedControl.SetFocus;
  if (not chbNoclose.Visible) or (not chbNoclose.Checked) then begin
    Self.ModalResult:= mrOk;
    if Formstyle <> fsNormal then Close;
    Break;
  end;
  Break;
  until False;
  FInBtOkClick:= False;
end;

procedure TFrmBasicMdi.btnCancelClick(Sender: TObject);
begin
  FInBtCancelClick:= True;
  ModalResult:= mrNone;
  Close;
  FInBtCancelClick:= False;
end;

procedure TFrmBasicMdi.btnClick(Sender: TObject);
begin
end;

procedure TFrmBasicMdi.EditButtonsClick(Sender: TObject; var Handled: Boolean);
begin
end;







procedure TFrmBasicMdi.FormActivate(Sender: TObject);
//вызовем событие для информирования о создании нового окна
begin
  Cth.SetWaitCursor(False);
  if FPreventShow then Exit;
  if Left < 0 then Left := 10;
  Wh.ChildFormActivate(Self);
end;

procedure TFrmBasicMdi.FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
//проверяем, возможно ли изменение формы
//учитываем и максимальные и минимальные значения
//если максимальное равно минимальному, то в этом направлении форму растянуть/сузить нельзя
begin
  Resize := True;
  //разрешаем произвольные изменения размеров формы, если менем видимость статусбара, еще не скорректированы размеры формы, и на этапе подготовке данных в потомке
  if FInSetStatusBar or not FWinSizeCorrected or FInPrepare then
    Exit;
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
//!в случае диалогового окна сюда попадает два раза почему-то, сначала
//с fsnormal потом с fsMDIChild
var
  i: Integer;
  pr: Boolean;
{procedure TCustomFormMy.VisibleChanging;
begin
  if (FormStyle = fsMDIChild) and Visible and (Parent = nil) then
    raise EInvalidOperation.Create(SMDIChildNotVisible);
end;}
begin
  //сбросим курсор выполения операции
  if (not FFormNotCreatedByApplication) and (FormStyle = fsNormal) then begin
    Settings.SaveWindowPos(Self, FormDoc);
    if (FLockInDB = fEdit) or (FLockInDB = fDelete) then
      Q.DBLock(False, FormDoc, VarToStr(id));
    Wh.ChildFormDestroy(Sender);
    Exit;
  end;
  Cth.SetWaitCursor(False);
  try
    // всегда разрушаем форму
    Action := caFree;
    //если задан идентификатор документа
    if FormDoc <> '' then begin
      if (Self.Left > mycHiddenFormLeft) then begin
        //сохраним размеры и позицию окна
        Settings.SaveWindowPos(Self, FormDoc);
      end;
      if (not FPreventShow) then begin
        //отменим блокировку в БД по документу
        if (FLockInDB = fEdit) or (FLockInDB = fDelete) then
          Q.DBLock(False, FormDoc, VarToStr(id));
      end;
    end;
    FPreventShow:=True;
    Wh.ChildFormDestroy(Sender);
  except
  end;
end;

procedure TFrmBasicMdi.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//проверяем, можно ли форму закрывать
//не закрываем в случае установки флага DisableClose вручную - в критичных местах где нельзя закрыть,
//или выдаем запрос в случае, если данные изменены, и есть опция запроса на закрытие/сохранение
//также в этом случае запрос будет выдан и при закрытии приложения, и в случае отмены закрытия окна приложение также не завершится
var
  mr: Integer;
  FQueryCloseMessageSt: string;
  EscPressed: Boolean;
begin
  //проверка, что мы в процедуре FormClose основной формы. Нужна, так как иначе, в случае если должен
  //появить запрос на закрытие, при закрытии приложения он будет выдан второй раз (если закрытие не было отменено)
  if FQueryCloseMessage <> '' then
    FQueryCloseMessageSt := FQueryCloseMessage
  else if FOpt.RequestWhereClose = cqYNC then
    FQueryCloseMessageSt := 'Данные были изменены?'#13#10'Сохранить?'
  else
    FQueryCloseMessageSt := 'Данные были изменены?'#13#10'Все равно закрыть диалог?';
  if FrmMain.InFormClose then begin
    CanClose:= True;
    Exit;
  end;
  if FDisableClose then begin
    CanClose:= False;
    Exit;
  end;
  //не совсем корректно: обработаем нажатие кнопки со свойством Cancel
  //если фокус не на этой кнопке то считаем что это было нажатие Esc
  EscPressed := False;
  if (FMode in [fAdd, fCopy, fEdit, fNone]) and FIsDataChanged and (btnCancel <> nil) and not btnCancel.Focused then begin
    EscPressed := True;
  end;
  EscPressed := False; //!!!
  //при нажатии Ок в любом случае разрешаем закрытие
  if FInBtOkClick {or FInBtCancelClick} then begin
    CanClose:= True;
  end
  //если было нажато Esc или в любом случае если установлен запрос на закрытие формы, спросим
  else if (EscPressed or (FOpt.RequestWhereClose = cqYN)) and (FIsDataChanged) then begin
    //закроем или оставим
    CanClose:= MyQuestionMessage(FQueryCloseMessageSt) = mrYes;
  end
  else if (EscPressed or (FOpt.RequestWhereClose = cqYNC)) and (FIsDataChanged) then begin
    //закроем без сохранения, сохраним или оставим форму
    mr:= MyMessageDlg(FQueryCloseMessageSt, mtConfirmation, [mbYes, mbNo, mbCancel]);
    CanClose:= mr = mrNo;
    if mr = mrYes
      then btnOkClick(btnOk);
  end;
  //обработка закрытий формы, созданной при старте приложения - скрываем вместо закрытия
  if (not FFormNotCreatedByApplication) and (FormStyle <> fsNormal) then begin
    Settings.SaveWindowPos(Self, FormDoc);
    if (FLockInDB = fEdit) or (FLockInDB = fDelete) then
      Q.DBLock(False, FormDoc, VarToStr(id));
    //скрываем
    ShowWindow(Handle, SW_HIDE);
    Wh.ChildFormDestroy(Sender);
    //если это не закрытие главной формы, то отменяем закрытие
    if not FrmMain.ApplicationQueryClose then
      CanClose:= False;
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
  x, y, i: Integer;
  b: Boolean;
  st: string;
begin
  //если не надо показывать на экране - сдвинеми за край
  if FPreventShow then begin
    Left := mycHiddenFormLeft;
    Exit;
  end;
  FAfterFormShow:= True;
  //создадим панель кнопок
  RefreshDlgPanel;
  //восстанавливаем размеры и положение окна, если таковые сохранены в бд
  //это невозможно сделать в oncreate в случае если запуск модальный
  i := Width;
  CorrectFormSize;
  i := Width;
  //обработаем поля
  if not F.IsFieldsPrepared then
    F.PrepareDefineFieldsAdd;
  if not F.IsPropControlsSet then
    F.SetPropsControls;
  SetControlEvents;
  Cth.FixTabOrder(Self);
//  FTab0Control:= Cth.GetFirstTabControl(Self);  st:=FTab0Control.name;
  if FOpt.DefFocusedControl = nil then
    FOpt.DefFocusedControl := FTab0Control;   //!!!
  if FOpt.DefFocusedControl <> nil then
    FOpt.DefFocusedControl.SetFocus;
  Cth.SetDialogCaption(Self, Mode, Self.Caption);
  SetMainInfoIcon;
  Serialize;
  FCtrlBegValuesStr := FCtrlCurrValuesStr;
  if FFormDoc <> '' then
    Settings.RestoreWindowPos(Self, FormDoc);
  Self.Top := max(Self.Top, 0);
  Verify(nil);
 // if FOpt.StatusBarMode = stbmDialog then
    RefreshStatusBar('*', '*', True); //нужно после изменения размеров, иначе правая надпись может уехать
  //для диалоговых отцентрируем относительно родительской формы
  if (myfoDialog in MyFormOptions) and (ParentForm <> nil) and ((ParentForm is TForm) or (ParentForm is TFrDBGridEh)) then
    CenteringByParent;
  if btnOk <> nil then
    btnOk.Focused;
  FAllreadyCreated := True;
end;


function TFrmBasicMdi.PrepareCreatedForm(AOwner: TObject; AFormDoc: string; ACaption: string; AMode: TDialogType;
  AID: Variant; AOptions: TMyFormOptions = [myfoModal, myfoDialog, myfoDialogButtonsB]; AAutoAlign: Boolean = True): Boolean;
//процедура для вызова в диалоге формы, созданной в uchet.dpr, с основными предустановками
//по умолчанию диалоговое окно с кнопками по типау fMode внизу без статусбара
//AFormDoc = * означет его соответствие имени формы
begin
  Result := False;
  FModuleId := cMainModule;
  FMyFormOptions := AOptions;
  FStatusBarHeight := -1;
  //если активна какаяя-либо модальная форма, автоматически добавим для созщдаваемой модальный режим
  if wh.IsModalFormOpen then
    Include(FMyFormOptions, myfoModal);
  //проверим, может ли быть запущен экземпляр формы, если уже такой есть и AMyFormOptions не разрешает повтор
  if not TestMultiInstances(AFormDoc, MyFormOptions, AMode, AID) then
    Exit;
  //создадим объект
  //в этот момент он отобразится! независимо от режима модал/мди
  if FFormNotCreatedByApplication then
    inherited Create(Application);
  F := TFields.Create(Self);
  //сдвинем форму влево, пока идет обработка данных, чтобы она не была видна
  if FFormNotCreatedByApplication then
    Left := mycHiddenFormLeft;
  FFormDoc := AFormDoc;
  if FFormDoc = '*' then
    FFormDoc := Self.Name;
  Caption := ACaption;
  FMode := AMode;
  FId := AID;
  if myfoDialogButtonsB in FMyFormOptions then
    FOPt.DlgPanelStyle := dpsBottomRight;
  if myfoDialogButtonsT in FMyFormOptions then
    FOPt.DlgPanelStyle := dpsTopLeft;
  if myfoShowStatusbar in FMyFormOptions then
    FOPt.StatusBarMode := stbmDialog;
  FOPt.AutoAlignControls := AAutoAlign;
  FParentControl := TWincontrol(AOwner);
  if (AOwner is TApplication) or (AOwner = nil) then
    FParentForm := FrmMain
  else if AOwner is TForm then
    FParentForm := TForm(AOwner)
  else
    FParentForm := TWincontrol(AOwner).Owner;
  ModalResult := mrNone;
  //запретим развертывание окна в максимум (надо еще запретить по даблклику на заголовке)
  if (myfoDialog in MyFormOptions) and (not (myfoEnableMaximize in MyFormOptions)) then
    if biMaximize in BorderIcons then
      Self.BorderIcons := Self.BorderIcons - [biMaximize];
  //сдвинем форму влево, пока идет обработка данных, чтобы она не была видна
  if FFormNotCreatedByApplication then
    Left := mycHiddenFormLeft;
  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;
  Result := True;
end;




















































//initialization

//finalization
  {
  if AllocMemCount <> 0 then ShowMessage('!!!');
  if AllocMemCount <> 0 then ShowMessage(IntToStr(AllocMemCount));
  if AllocMemCount <> 0 then  MessageBox(0, pansichar('An unexpected memory leak has occurred.'+intToStr(AllocMemCount)), 'Unexpected Memory Leak', MB_OK or MB_ICONERROR or MB_TASKMODAL);
}
//begin
//end;

end.


//чтобы не съезжали элементы, использующие якоря, в дизайнере формы проставляем BorderStyle:=bsDialog;
//форма при этом все равно растягивается
//если этого не надо, в Prepare проставляем PreventResize:=True;
//но мди-форма работает не совсем корректно, если в этой процедуре не выставить BorderStyle:=bsSizeable;

//так можно скрыть форму в событиях оншов, онхиде, где стандартными методами менять статус нельззя
//    PostMessage(Self.Handle, WM_CLOSE, 0, 0);


(*

--------------------------------------------------------------------------------
--Размеры формы, их ограничение и изменение.
WHCorrected.X, Y - к этим размерам корректируется размер формы при показе, если эти
размеры не нулевые. Устанавливать нужно например по данным выравнивания контролов.
Если контролы все на pnlFrmClient, то сделать WHCorrected:=Cth.AlignControls(pnlFrmClient, [], False),
или, что то же, установить Opt.AutoAlignControls
Также, если видна панель кнопок, то ширина будет скорректирована еще и на основании ее содержимого,
с учетом и видимости иконки подсказки.
Могут быть заданы WHBounds, как больше так и меньше проектного размера, WHCorrected не
имеет значения, размер будет не меньше наженй границы и не больше верхней.
Если минимальные границы не установлены явно или при AlignControls, то они будет
приняты равными размеру формы в дизайнтайме!
(изменил - не задаются, но установятся по панели диалога, если она есть)
Если верхняя границы установлена -1, то она окажется равной нижней.
Если на форме есть контролы, у которых выравниваени по правому (нижнему) краю,
надо подогнать их в дизайнтайме, изменение размеров формы в любых случаях при этом
обрабатывается нормально.
За коррекцию размеров формы после вывода на экран отвечает процедура CorrectFormSize

--Иконка подсказки
Иконка подсказки будет отображена, если задан массив Opt.InfoArray и с учетом его условий
формируется текст
(массив вида [['txt1' {, bool}],['txt2' {,bool}],...])
Если на форме заметить TImage с именем ImgInfoMain, то к ней будет привязан текст подсказки
(если его нет, то наоборот она будет скрыта). Если такой иконки нет, то будет создана в
панели кнопок, при наличии панели. Имеет значение регистр имени контрола -
ImgInfoMAIN создает иконку х32, imgInfomain - х24, ImgInfoMain - по ее размеру (ширине)

--Заголовок окна
К заголовку автоматически добавляется тип операции после Caption, если только он не
начинается на '~'. Делается это в AfterPrepare

--Верификация данных
по умолчанию проверяются данные процедурой Verify, вызываемой по событию OnChange и OnExit
любого контрола, а также при отображени формы, и при нажатии кнопки Ок. Для обработки ошибок,
она устанавливает флаг HasError, и может устанавливать независмое от него сообщение ErrorMessage.
Перекрывать эту процедуру не нужно.
Для дополнительной проверки в этих событиях, надо перекрыть процедуру VerifyAdd(Sender, onInput)
последняя должна установить маркеры ошибки у контролов, либо же сразу установить Result := True
(вернуть по конкреному контролу - проверить if (Sender = C1) or (Sender = nil) then ...
можно всегда проверять глобальное для формы сложное условие и при ошибке возвращать Trcue,
независимо от переденного Sender)
В целом, HasError можно установить в любом месте, и в зависимости от этого значения
изменится доступность кнопки Ок и надпись в статусбаре.
В случае, если HasError не установлен, то кнопка Ок доступна для нажатия, и будет вызвана
дополнительна проверка VerifyBeforeSave, которая может установить HasError, но предпочтительно
текст сообщения ErrorMessage, если последний не пустой, то сохранения данных не будет и диалог не
закроется при Ок, текст сообщения будет выведен в диалоговом окне (он можт быть "*", тогда выведется
"Данные не корректны", или "-" - ничего не выведется, но записи не будет (например, надо для более
глубокой обработки в VerifyBeforeSave с вопросами пользователю), или начинаться с "?" - будет выведен
диалог, и при Yes запись и закрытие, иначе диалог не закрывается.


*)

(*
доделать:

- запрос при закрытии формы
- центрирование для диалогов
- запрет на закрытие формы
флаг в TFrmMain.FormClose - проверять при закрытии
*)



(*
2025-01-08
проверено отображение формы, не мелькает при открытии, если есть задержка в загрузке данных:
- в случае, когда открывается как должна, или prepare возвращает False как с сообщением так и без, как при модальном так и мди показе.
*)



(*
СТАРОЕ

{
форма-предок для всех МДИЧАЙЛД-форм

если здесь добавить обработчики событий, то из форм-наследников, бывших на момент добавления, эти события вызываться не будут
чтобы исправить, нужно открыть dfm и убрать в верхней части строки типа OnCreate = nil, либо переопределять события в самой форме и вызывать inherited

формы можно создать через меню дельфи, или же создавать обычную форму, и сразу в ней исправить class(TForm) на class(TFrmBasicMdi)
также созданную форму надо удалить из файла проекта (строку Application.CreateForm(TForm..)

}


{
ФОРМА - ПРЕДОК для большинсва всех форм (есть еще промежуточные ее потомки)
может быть открыта как в режиме FormStyle = fsMdiChild, так и в fsNormal
в дизайнере создана как fsNormal, поэтому в отличии от чайлд она не показывается при создании формы автоматом,
и есть возможность проверить параметры и отменить показ без всяких артефактов.
В противном случае можно решить созданием функций класса, в которых вызывать проверку условий, и в случае успеха
создавать форму. но в этом случае возникают проблемы в потомках при передаче в форму дополнительных параметров,
добавленных в перекрытой функции.
однако проблема и здесь. с мдит-формами вроде все нормально. обычная же если не вызывать ShowModal показывается
как всегда форма нормал в мди приложении - пропадает по клику мимо формы. а если ваызвать showmodal, то после закрытия
диалоговой формы она открывается повторно, и потом закрывается, при этом штатно, отрабатывает и запись в базу и прочее


СДЕЛАЛ ВСЕ ЗАПУСКОМ КОНСТРУКТОРА
тип берется из опции myfoModal, если есть fs = fsNormal и запускается showdialog, иначе fsMdiChild и просто Show;
конструктор при вызове все равно отображает окно, еще без данных, так как обработка данных и присвоение полей
вызывается в основном конструкторе после inherited.
если вызвано в модальном режиме, то после родительского конструктора скрываем форму хидде и делаем шовмодал,
для мди делаем просто Show. чтобы не было мельканий, при настройке формы и ее завершении уводим ее влево за край экрана.
также, при закрытии в модальном режиме происходит повторное отображение формы в том же виде, но при этом в Prepare не заходит.
решил только установкой перед разрушением формы ее режима в fsMdiChild.


В ПОТОМКАХ при переопоределении конструктора сначала устанавливать поля и последней строчкой вызывать innherited!
после innherited не делать никаких настроек, так как конструктор может не создать форму в зависимости от переданных опций
(например, допустим единственный экземпляр), и обращение к полям вызовет ошибку)
настройки делать в функции Prepare!

Если в потомках на форме есть кмпоненты TLabel, то в интерфейсной части обязательно подключать модуль uLabelColors,
иначее возникнет ошибка при разрушении формы!!!


если форма делается модальной, то возникают мелькания при закрытии формы из-за повторного захода в онклозе.


--------------------------------------------------------------------------------
//пример вызова формы, созданной в дизайнтайме, создание которой не убрано в Uchet.dpr
//все события и настройки формы обрабатываются как и в случае с МДИ, но вызывать можно только в модальном режиме
//произвольная процедура формы
procedure TFrmADedtItmCopyRigths.ShowDialog;
begin
  //установка параметров
  PrepareCreatedForm(Application, '', '~Права пользователя ИТМ', fEdit, null, {MyFormOptions=[myfoModal, myfoDialog, myfoDialogButtonsB], AutoAlign});
  F.DefineFields:=[['cmbSrc','V=1:255'], ['cmbDst','V=1:255']];
  //проверка что событие OnCreate формы ужже вызывалось, объекты уже созданы
  if not Self.FAllreadyCreated then Frg1.Prepare;
  Q.QLoadToDBComboBoxEh('select name, id from dv.au_user where id not in (-1, 904) order by name', [], cmbSrc, cntComboLK);
 //вызов всегда должен быть модальный
  Self.ShowModal;
end;
//можно доработать для mdichild - скрытие формы по ShowWindow(Handle, SW_HIDE);


}


//запретить двойной клике  по заголовку чтобы не привязывалась форма
//добавить свойстров центрорования формы прит показе
//некорректно работает позицинирование при расхлопывании Модал формы (наезжает на меню, и при первом показе тоже сверху


неверно устанавливается высота если не установлен myfosizeable,
а если установлен то врено только в случае утановки явно
fwhbounds.y и y2



!!!!
некорректно может быть корректировка размеров
  if (FWHCorrected.X <> 0) or (j <> 0) then begin



