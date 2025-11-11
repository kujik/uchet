unit V_MDI;
{
форма-предок для всех МДИЧАЙЛД-форм

если здесь добавить обработчики событий, то из форм-наследников, бывших на момент добавления, эти события вызываться не будут
чтобы исправить, нужно открыть dfm и убрать в верхней части строки типа OnCreate = nil, либо переопределять события в самой форме и вызывать inherited

формы можно создать через меню дельфи, или же создавать обычную форму, и сразу в ней исправить class(TForm) на class(TForm_MDI)
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
}


//запретить двойной клике  по заголовку чтобы не привязывалась форма
//добавить свойстров центрорования формы прит показе
//некорректно работает позицинирование при расхлопывании Модал формы (наезжает на меню, и при первом показе тоже сверху


//ПЕРЕДЕЛАЛ ЗАПУСК SHOWMODAL
//было сдлеано переключение в мдичайлд формы после showmodal, в результате собатие закрытие два раза при азкрытии формы и мерцание
//убрал переключение режима, а в любой форме в onclose action=cafree
//но при этом послле закрытия для диалога вызывается онклозе, а зате опять оактивате и оншов
//снижает мелькания установка FPreventShow в онклозе

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, GridsEh, DBAxisGridsEh, DBGridEh, Math, uData, Vcl.StdCtrls, uLabelColors;

const
  mycHiddenFormLeft = -10000;

type
  TForm_MDI = class(TForm)
    tmrAfterCreate: TTimer;
    pnl_StatusBar: TPanel;
    lbl_StatusBar_Right: TLabel;
    lbl_StatusBar_Left: TLabel;
    procedure tmrAfterCreateTimer(Sender: TObject);
    //не допускает уменьшение формы ниже минимального размера или больше максимальных
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    //восстанавливаем размеры и положение окна, если таковые сохранены в бд
    //это невозможно сделать в oncreate в случае если запуск модальный
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    //выполняет caFree
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FToLoaddata: Boolean;
    FTextLeft, FTextRight: Variant;
    FStatusBarHeight: Integer;
    FIISetStatusBar: Boolean;
    FIsFormShown: Boolean;
    //в режиме showdialog после закрытия диалога он вызывается еще раз. данный флаг блокирует повторный вызов.
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
  public
    { Public declarations }
    ModuleId: Integer;
    FPreventShow: Boolean;
//    FormObject: TComponent;
//    bbb: Boolean;
    //ид документа
    FormDoc: string;
    //родительская форма, должно устанавливаться в потомках в перекрытом конструкторе
    ParentForm: TComponent;
    //режим формы, не важен для списков
    Mode: TDialogType;
    //айди записи, не важно для списков.
    id: Variant;
    AddParam: Variant;
    //(myfoModal, myfoDialog, myfoDefault, myfoMultiCopy, myfoMultiCopyWoId, myfoOneCopy, myfoEnableMaximize, myfoSizeable, myfoRefreshParent)
    MyFormOptions: TMyFormOptions;
    //флаг того что находится в процедуре загрузки данных
    InPrepare: Boolean;
    InFormShow: Boolean;
    //результат выполнения функции препаре
    PrepareResult: Boolean;
    FormDialogResult: Integer;
    //контрол, в который помещается фокус при открытии окна, или при переходе на новую запись, если NoCloseIfAdd
    DefFocusedControl: TWinControl;
    AutoSaveWindowPos: Boolean;
_noshow: Boolean;
    //конструктор
    //передается родитель (всегда должен быть Аппликейшен), Идентификатор типа документа, номер окна документа такого типа (нигде вроде не использется)
    constructor Create(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant); reintroduce; virtual;
    //вызываем эти функции для показа формы вместо конструктора!!!
    class function ShowDialogClass(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TForm; overload; virtual;
    class function ShowDialogClass(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AAddParam: Variant): TForm; overload; virtual;
    //установим левую и правую надпись в статусбаре окна (по факту в панели) и его видимость
    //лейблы колоризованные и параметры могут принимать как массив так и строку (формат см в uLabelColors)
    //если невидим, то форма уменьшитсЯ автоматически, устанавливать в потомках высоту статусбара = 0 или скрывать кроме этой процедуры не надо
    //в потомках может быть установлена любая ваысота статусбара, это корректно обрабатывается
    //если в процессе работы формы посредством вызова SetStatusBar меняется его статус видимсоти, то он появится или исчезнет, высота формы скорректируется (увеличится/уменшится вниз)
    //если форма сделана не путем создания Инхеритед через мастер - эту процедуру вообще не ваызывать - поломает размер формы
    procedure SetStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
  protected
    //минимальные высота и ширина, иожно установить в конструкторе или препаре. обрабатываются здесь в onCanResize
    MinWidth, MinHeight, MaxWidth, MaxHeight: Integer;
    //значения, сохраненные для схлопывания/расхлопывания, вместо стандартных в событиях
    PrevLeft, PrevTop, PrevWidth, PrewHeight: Integer;
    //была ли сделана блокировка, результат FormDbLock = Mode, если здесь будет fDelete or FEdit то блокировка автоматом снимается при закрытии формы
    //если True, то при закрытии формы блокирока снимается, используя как ключи FormDoc и ID
    LockInDB: TDialogType;
    IsMaximized: Boolean;
    InMaxMin: Boolean;
    //не которые формы могут изменять размер, несмотря на то что стоит bsDialog, глюк? для неизменения размера
    PreventResize: Boolean;
    //выполняет загрузку данных (Prepare) и в зависимости от результата показывает форму или завершает
    //вызывается апвтоматически в коснтрукторе если RunAfterCreateProc=True или не указан, если в коснтуркторе надо установить дополнительные параметры,
    //то этот должен быть обозначен как False и AfterCreate
    //должен быть обязательно вызван в конструкторе потомка после вызова родительского конструктора и инициализации полей (напр айди, режим),
    //или же как вариант в событии формы onCreate если только эта логика не пререкрытв
    //можно было бы сделать вызов onCreate и все, но в потомках mdi_grid1 не вызывется без перекрытия
    //СДЕЛАЛ КАК ВЫШЕ, ЯВНО НЕ ВЫЗЫВАТЬ!
    procedure AfterCreate;
    procedure AfterStart; virtual;
    //должна быть вызвана, если азвершение происходит до показа формы, в конструторе
    procedure ExitWithoutShow; virtual;
    //вызывается после создания формы в конструкторе,
    //если возвращает ложь то происходит выход из конструктора с закрытием формы ExitWithoutShow
    //(то есть False блокирет отображение формы);
    //перекрывается.
    function  Prepare(): Boolean; reintroduce; virtual;
    procedure AfterPrepare; virtual;
    //должен вызываться после отображения формы (в таймере срабатывающем после отрисовки)
    function RefreshParentForm: Boolean;
    //запросить блокировку по формдок и айди. вызывается вручную в препаре, возвращает новый режим формы в переменной формы, при возврате fNone должен быть выход из Prepere с False
    function FormDbLock(msg: string = '*|*'): TDialogType;
    procedure GetFormLTWH;
    //получить значение контрола на форме по его имени
    //если установлено NullIfEmpty то вернуть null если значение равно пустое или ''
    function GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
    function ScrollBarVisible(isVert: Boolean = True): Boolean;
    //нажна для подмены стиля формы.
    //исходный стиль в дизайнере стал теперь fsNormal!!!
    procedure InitializeNewForm; override;
    //отображение формы в зависимости от режима FormStyle, вызывается в class function инициализации
    class procedure ShowForm(AForm: TForm);
    //проверяем, запущены ли уже экземпляры такой формы
    //вернет True, если можно запускать форму
    //в любом случае переключит на передний план форму, если найдет с таким формдок и айди
    //для myfoMultiCopy, для режимов добавления/кпинрования, fNone - откроет новую форму
    //но если найдет, независимо от айди, и нет myfoMultiCopy, то не разрешит открыть новую
    class function TestMultiInstances(AFormDoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant): Boolean;
  end;

var
  Form_MDI: TForm_MDI;

implementation

uses
  uWindows, uSettings, uFrmMain, uDBOra, uForms, uMessages, uString, uFrDbGridEh, uFrmBasicMdi
  ;

{$R *.dfm}

class function TForm_MDI.ShowDialogClass(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TForm;
//функция класса. для создания окна необходимо ВЫЗЫВАТЬ ЕЕ А НЕ КОНСТРУКТОР
//используем ее, чтобы проверить, можно ли показывать форму в зависимости от условий (например, форма такого типа допустима только одна и она уже есть)
//проверять в конструкторе хуже, тк при создании форма уже отображается, а здесь она просто не создастся.
//также тут и отобразим форму после создания разными способами - как MdiChild или Modal
//! в дочерних формах, если в нее передаются дополнительные параметры, нужно создавать свою функцию класса и повторять там эти строки кода,
//так как до создания эксземпляра (до вызова конструктора) мы не можем инициализировать дополнительные поля, а они ему будут уже нужны.
//если бы был один экземпляр объекта, можно было бы использовать конструкцию типа class OK но тогда эти переменные станут общими для всех экземпляров класса
begin
  if not TestMultiInstances(ADoc, AMyFormOptions, AMode, AID) then
    Result := Create(AOwner, ADoc, AMyFormOptions, AMode, AID, AAddParam);
  Result := Create(AOwner, ADoc, AMyFormOptions, AMode, AID, null);
  ShowForm(Result);
end;

class function TForm_MDI.ShowDialogClass(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AAddParam: Variant): TForm;
begin
{  if not TestMultiInstances(ADoc, AId, AMyFormOptions) then
    Exit;
  if Wh.IsModalFormOpen then
    Include(AMyFormOptions, myfoModal);
  Result := Create(AOwner, ADoc, AMyFormOptions, fNone, null, AAddParam);
  if (myfoModal in AMyFormOptions) then
    TForm_MDI(Result).AfterCreate;
  ShowForm(Result);}
end;

constructor TForm_MDI.Create(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; Aid: Variant; AAddParam: Variant);
//конструктор класса
var
  i :Integer;
begin
  ModuleId := cMainModule;
  MyFormOptions := AMyFormOptions;
  FStatusBarHeight := -1;
  //если активна какаяя-либо модальная форма, автоматически добавим для созщдаваемой модальный режим
  if Wh.IsModalFormOpen then
    Include(MyFormOptions, myfoModal);
  //проверим, может ли быть запущен экземпляр формы, если уже такой есть и AMyFormOptions не разрешает повтор
  if not TestMultiInstances(ADoc, MyFormOptions, AMode, Aid) then
    Exit;
  //создадим объект
  //в этот момент он отобразится! независимо от режима модал/мди
  inherited Create(Application);
  i:=Self.Width;
//  Self.Width := 500;
  //сдвинем форму влево, по идет обработка данных, чтобы она не была видна
  Left := mycHiddenFormLeft;
 // Hide;
{ Application.CreateForm(TForm_MDI, self);
  if myfoAutoShowModal in MyFormOptions then
    Self.FormStyle := fsNormal
  else
    Self.FormStyle := fsNormal;}
  //установим переданные свойства
  FormDoc := ADoc;
  Mode := AMode;
  id := Aid;
  ParentForm := AOwner;
  AddParam := AAddParam;
  ModalResult := mrNone;
//  tmrAfterCreate.Enabled := True;
  //Wh.SelectDialogResult := [];
  //Wh.SelectDialogResult2 := [];
  FormDialogResult := mrNone;
  //видимость панели статусбара
  pnl_StatusBar.Visible := not (myfoDialog in MyFormOptions);
  pnl_StatusBar.BevelInner:=bvNone;
  pnl_StatusBar.BevelOuter:=bvNone;
  pnl_StatusBar.Color:=cl3DLight;
  //очистим обе метки на нем
  //++SetStatusBar('', '', pnl_StatusBar.Visible);
  //запретим развертывание окна в максимум (надо еще запретить по даблклику на заголовке)
  if (myfoDialog in MyFormOptions) and (not (myfoEnableMaximize in MyFormOptions)) then
    if biMaximize in BorderIcons then
      Self.BorderIcons := Self.BorderIcons - [biMaximize];
  //сдвинем форму влево, по идет обработка данных, чтобы она не была видна
  Left := mycHiddenFormLeft;
  //if (myfoModal in AMyFormOptions) then
  //здесь полуим пользовательские данные, в том числе и запрет на отображение окна FPreventShow
//  AfterCreate;
  //(пере)покажем форму

  ShowForm(Self);
end;

procedure TForm_MDI.InitializeNewForm;
//нажна для подмены стиля формы.
//исходный стиль в дизайнере стал теперь fsNormal!!!
var
  FS: ^TFormStyle;
  v: Variant;
begin
  inherited;
  if not (myfoModal in MyFormOptions) then begin
    FS := @FormStyle;
    FS^ := fsMDIChild;
  end
  else begin
    FS := @FormStyle;
    FS^ := fsNormal;
  end;
end;

class procedure TForm_MDI.ShowForm(AForm: TForm);
//отображение формы в зависимости от режима FormStyle, вызывается в class function инициализации
begin
  if AForm.Formstyle = fsnormal then
    AForm.Hide;
  //обработка отображения формы в случае модального режима
  if AForm.Formstyle = fsnormal then begin
    TForm_MDI(AForm).FToLoadData := True;
    //загрузим данные в форму и настроим ее в потомке
    TForm_MDI(AForm).AfterCreate;
    //если функция Prepare (вызывается в AfterCreate) вернула False, то показывать форму не будем
    if TForm_MDI(AForm).PrepareResult then AForm.ShowModal;
  end
  //обработка отображения формы в случае режима MDI_Child
  else begin
    //AForm.Left := 200;
    TForm_MDI(AForm).FToLoadData := True;
    //загрузим данные в форму и настроим ее в потомке
    //здесь, так как это непосредственно перед финальным отображением, и форма не мелькает,
    //пока грузятся данные она не видна (как и было ранее)
    TForm_MDI(AForm).AfterCreate;
    AForm.Show;
  end;
end;

class function TForm_MDI.TestMultiInstances(AFormDoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant): Boolean;
//проверяем, запущены ли уже экземпляры такой формы
//вернет True, если можно запускать форму
//в любом случае переключит на передний план форму, если найдет с таким формдок и айди
//для myfoMultiCopy, для режимов добавления/кпинрования, fNone - откроет новую форму
//но если найдет, независимо от айди, и нет myfoMultiCopy, то не разрешит открыть новую
var
  nm: Integer;
begin
  Result := True;
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

procedure TForm_MDI.AfterCreate;
//действия после создания формы (точнее, вызываем ее конструкторе, после стандартного, перед самым показом формы)
//вызываем функцию потомка загрузки данных и настроки Prepare, выходит буз показа формы если она вернула False
//вызывает функцию потомка AfterPrepare, для совершения дополнительных действий
begin
  InPrepare := True;
  Cth.SetWaitCursor;
  PrepareResult:= Prepare;
  if not PrepareResult then begin
  //  InPrepare := False;
    ExitWithoutShow;
  end;
  InPrepare := False;
  AfterPrepare;
  //устанавливаем возможность изменения размеров формы (установив соотв бордерстайл)
  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;
  ;
end;

procedure TForm_MDI.FormActivate(Sender: TObject);
//вызовем событие для информирования о создании нового окна
var
  st: string;
begin
  st:=Self.Name;
  Cth.SetWaitCursor(False);
  if FPreventShow then
    exit;
  if Left < 0 then
    Left := 10;
  Wh.ChildFormActivate(Self);
  if DefFocusedControl <> nil then
    DefFocusedControl.SetFocus;
end;

procedure TForm_MDI.FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
//проверяем, возможно ли изменение формы
//учитываем и максимальные и минимальные значения
//если максимальное равно минимальному, то в этом направлении форму растянуть/сузить нельзя
begin
//  Resize := False; exit;
  if not FIsFormShown then begin
    Resize := True;  exit;
  end;
  if FIISetStatusBar then
    Exit;
  //разрешаем произвольные изменения размеров формы на этапе подготовке данных в потомке
  if InFormShow then
    Exit;
  if InPrepare then
    Exit;
  Resize := False;
  if PreventResize then
    Exit;
  if BorderStyle = bsDialog then
    Exit;
  Resize := True;
  if (NewWidth > MaxWidth) and (MaxWidth > 0) then
    NewWidth := MaxWidth;
  if (NewWidth < MinWidth) and (MinWidth > 0) then
    NewWidth := MinWidth;
  if (NewHeight > MaxHeight) and (MaxHeight > 0) then
    NewHeight := MaxHeight;
  if (NewHeight < MinHeight) and (MinHeight > 0) then
    NewHeight := MinHeight;
  if not InMaxMin then
    GetFormLTWH;
end;

procedure TForm_MDI.FormClose(Sender: TObject; var Action: TCloseAction);
//!!!в случае диалогового окна сюда попадает два раза почему-то, сначала
//с fsnormal потом с fsMDIChild
var
  i: Integer;
  pr: Boolean;
begin
//        PreventResize:=True;
  Cth.SetWaitCursor(False);
//  if FPreventShow then begin Exit;
  try
 //   if FormStyle = fsMDIChild then
      Action := caFree;        //!!! всегда разрушаем форму

    if (Self.Left > mycHiddenFormLeft) then begin
      if AutoSaveWindowPos then
        Settings.SaveWindowPos(Self, FormDoc);
//    Left:=mycHiddenFormLeft;
    end;
//Self.Left := mycHiddenFormLeft;
    if (not FPreventShow) then begin
      if (LockInDB = fEdit) or (LockInDB = fDelete) then
        Q.DBLock(False, FormDoc, VarToStr(id));
    end;
    FPreventShow:=True;
    Wh.ChildFormDestroy(Sender);
  except
  end;
end;

procedure TForm_MDI.FormCreate(Sender: TObject);
begin
//  close;
//fterCreate;
//bbb:=True;
end;

procedure TForm_MDI.FormShow(Sender: TObject);
var
  x, y, i: Integer;
  b: Boolean;
begin
  if FPreventShow then begin
    Left := mycHiddenFormLeft;
    Exit;
  end;
  InFormShow := True;
  if (myfoDialog in MyFormOptions) and (ParentForm <> nil) and (ParentForm is TForm) then begin
    //для диалоговых отцентрируем относительно родительской формы

    x := FrmMain.Height;
    i := FrmMain.ClientHeight;
    x := FrmMain.lbl_GetTop.top;
    i := FrmMain.lbl_GetBottom.top;

    x := TForm(ParentForm).Left + TForm(ParentForm).Width div 2 - Self.Width div 2;
//    i:=FrmMain.Width div 2 - Self.Width div 2;
//    x:=min(x, i);
    if x + Self.Width > FrmMain.ClientWidth - 10 then
      x := FrmMain.ClientWidth - Self.Width - 30;
    Self.Left := max(x, 0);

    x := TForm(ParentForm).Top + TForm(ParentForm).Height div 2 - Self.Height div 2;
    if x + Self.Height > FrmMain.FormsList.Top - FrmMain.lbl_GetTop.Top - 10 then
      x := FrmMain.FormsList.Top - FrmMain.lbl_GetTop.Top - Self.Height - 10;
    Self.Top := max(x, 0);

  end;
  Self.Top := Max(FrmMain.lbl_GetTop.Top, Self.Top);

  //восстанавливаем размеры и положение окна, если таковые сохранены в бд
  //это невозможно сделать в oncreate в случае если запуск модальный
  Settings.RestoreWindowPos(Self, FormDoc);
  InFormShow := False;
  FIsFormShown := True;
end;

procedure TForm_MDI.tmrAfterCreateTimer(Sender: TObject);
begin
  tmrAfterCreate.Enabled := False;
  AfterStart;
end;

procedure TForm_MDI.AfterStart;
begin
end;

function TForm_MDI.FormDbLock(msg: string = '*|*'): TDialogType;
begin
  Mode := Q.DBLock(True, FormDoc, VarToStr(id), msg, Mode)[3];
  LockInDB := Mode;
  Result := Mode;
end;

procedure TForm_MDI.FormDestroy(Sender: TObject);
begin
  try
    inherited;
  except
  end;
end;

procedure TForm_MDI.ExitWithoutShow;
begin
  //==FPreventShow := True;
  Left := mycHiddenFormLeft;
  FormStyle := fsMDIChild;
  Self.Close;
end;

function TForm_MDI.Prepare: Boolean;
begin
  Result := True;
end;

procedure TForm_MDI.AfterPrepare;
begin
end;

function TForm_MDI.RefreshParentForm: Boolean;
var
  i: Integer;
  Form: TForm;
begin
{ //++ проверить и доделать
  Form:=Wh.GetFormFromWindows(TForm(ParentForm));
  if form <> nil then myinfomessage('!!!');
Exit;
  For i:=0 to High(Wh.Windows) do

 }
  if ParentForm <> nil then
  try
{    if (ParentForm is TForm_MDI_Grid1) then begin
      TForm_MDI_Grid1(ParentForm).Refresh;
    end;}
    if (ParentForm is TFrmBasicMdi) then begin
      if TFrmBasicMdi(ParentForm).FindComponent('Frg1') <> nil then
        TFrDbGridEh(TFrmBasicMdi(ParentForm).FindComponent('Frg1')).RefreshGrid;
    end;
  except
  end;
end;

procedure TForm_MDI.SetStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
//установим левую и правую надпись в статусбаре окна (по факту в панели) и его видимость
//лейблы колоризованные и параметры могут принимать как массив так и строку (формат см в uLabelColors)
//если невидим, то форма уменьшитсЯ автоматически, устанавливать в потомках высоту статусбара = 0 или скрывать кроме этой процедуры не надо
//в потомках может быть установлена любая ваысота статусбара, это корректно обрабатывается
//если в процессе работы формы посредством вызова SetStatusBar меняется его статус видимсоти, то он появится или исчезнет, высота формы скорректируется (увеличится/уменшится вниз)
//если форма сделана не путем создания Инхеритед через мастер - эту процедуру вообще не ваызывать - поломает размер формы
var
  b: Boolean;
begin
  //проверка обязательна! в mdi_grid1 сейчас вызывается в repaint и если не проверять очень тормозит при изменении размера
  if (pnl_StatusBar.Visible = AVisible) and (VarToStr(TextLeft) = S.NSt(FTextLeft)) and (VarToStr(TextRight) = S.NSt(FTextRight)) and (FStatusBarHeight = pnl_StatusBar.Height) then
    Exit;
  FIISetStatusBar := True;
  b := (pnl_StatusBar.Visible = AVisible) or (FStatusBarHeight = -1);
  if FStatusBarHeight = -1 then
    FStatusBarHeight := pnl_StatusBar.Height;
  pnl_StatusBar.Visible := AVisible;
  //фиксим баг, когда статусбар может уехать в середину формы при наличии панелей с выравнивание alBotoom, alcleent...
  //if pnl_StatusBar.Visible then
  if not b then
    Self.ClientHeight := Self.ClientHeight + S.IIf(AVisible, FStatusBarHeight, -FStatusBarHeight);
  if InPrepare and not AVisible then
    Self.ClientHeight := Self.ClientHeight - FStatusBarHeight;
  if AVisible then
    pnl_StatusBar.Height := FStatusBarHeight;
  if not AVisible then
    pnl_StatusBar.Height := 0;
  if AVisible then
    pnl_StatusBar.Top := 1000
  else
    pnl_StatusBar.Top := Self.ClientHeight - pnl_StatusBar.Height;
//  pnl_StatusBar.Top:=1000;
//  if AVisible and (pnl_StatusBar.Height = 0) then Self.ClientHeight:=Self.ClientHeight + FStatusBarHeight;

  Self.ClientHeight := pnl_StatusBar.Top + pnl_StatusBar.Height;

//  if not b then Self.ClientHeight:=Self.ClientHeight + S.IIf(AVisible, FStatusBarHeight, -FStatusBarHeight);

  FTextLeft := TextLeft;
  FTextRight := TextRight;

  lbl_StatusBar_Left.ResetColors;
  lbl_StatusBar_Left.Caption := '';
  if VarIsArray(TextLeft) then
    lbl_StatusBar_Left.SetCaptionAr2(TextLeft)
  else
    lbl_StatusBar_Left.SetCaption2(TextLeft);

  lbl_StatusBar_Right.ResetColors;
  lbl_StatusBar_Right.Caption := '';
  if VarIsArray(TextRight) then
    lbl_StatusBar_Right.SetCaptionAr2(TextRight)
  else
    lbl_StatusBar_Right.SetCaption2(TextRight);
  FIISetStatusBar := False;
end;

function TForm_MDI.ScrollBarVisible(isVert: Boolean = True): Boolean; //(WindowHandle: THandle)
begin
  if isVert then
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_VSCROLL) <> 0
  else
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_HSCROLL) <> 0;
end;

procedure TForm_MDI.GetFormLTWH;
begin
  PrevLeft := Left;
  PrevTop := Top;
  PrevWidth := Width;
  PrewHeight := Height;
end;

//обработчик сообщений
procedure TForm_MDI.WMSysCommand(var Msg: TWMSysCommand);
begin
//  DefaultHandler(Msg);Exit;
  if Msg.CmdType = SC_ZOOM then
  //по кнопке восстановить/раскрыть
  //так как МДИ, и все окна могут быть в одном статусе одновременно только
  //эмулируем работу сворачивания/разворачивания
  begin
    Self.WindowState := wsNormal;
    if IsMaximized then begin
      //вернем ранее запомненные положания и размер
      InMaxMin := True;
      Self.Top := PrevTop;
      Self.Left := PrevLeft;
      Self.Width := PrevWidth;
      Self.Height := PrewHeight;
      Msg.Result := 0;
      InMaxMin := False;
      InMaxMin := False;
      IsMaximized := False;
      Exit;
    end
    else begin
      //расхлопнем на весь экран
      //высота не совсем корректно сделана, условно вычитаем ширину на скроллер и высоту на меню/панели, методом подгонки
      InMaxMin := True;
      GetFormLTWH;
      Self.Top := 0;
      Self.Left := 0;
      Self.Width := FrmMain.ClientWidth - 5;
      Self.Height := FrmMain.ClientHeight - 45;
      //если все-таки скроллбар появился, то вычтем его размеры (по идее, он должен исчезнуть, а окно останется меньше чем ширина экрана)
      if ScrollBarVisible(False) then
        Self.Width := Self.Width - 15;
      if ScrollBarVisible(True) then
        Self.Height := Self.Height - 15;
      Msg.Result := 0;
      InMaxMin := False;
      IsMaximized := True;
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

function TForm_MDI.GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
//получить значение контрола на форме по его имени
//если установлено NullIfEmpty то вернуть null если значение равно пустое или ''
begin
  Result:= Cth.GetControlValue(TControl(Self.FindComponent(ControlName)));
  if NullIfEmpty then Result:=S.NullIfEmpty(Result);
end;

initialization

finalization
  {
  if AllocMemCount <> 0 then ShowMessage('!!!');
  if AllocMemCount <> 0 then ShowMessage(IntToStr(AllocMemCount));
  if AllocMemCount <> 0 then  MessageBox(0, pansichar('An unexpected memory leak has occurred.'+intToStr(AllocMemCount)), 'Unexpected Memory Leak', MB_OK or MB_ICONERROR or MB_TASKMODAL);
}
begin
end;

end.


//чтобы не съезжали элементы, использующие якоря, в дизайнере формы проставляем BorderStyle:=bsDialog;
//форма при этом все равно растягивается
//если этого не надо, в Prepare проставляем PreventResize:=True;
//но мди-форма работает не совсем корректно, если в этой процедуре не выставить BorderStyle:=bsSizeable;



//так можно скрыть форму в событиях оншов, онхиде, где стандартными методами менять статус нельззя
//    PostMessage(Self.Handle, WM_CLOSE, 0, 0);
