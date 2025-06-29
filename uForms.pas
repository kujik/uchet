unit uForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBCtrlsEh, Buttons, DBGridEh, DBAxisGridsEh, GridsEh,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh,
  Db, MemTableEh, EhLibVCL, Math, ExtCtrls, Vcl.Menus, Types, Registry, IniFiles,
  GridToolCtrlsEh, SearchPanelsEh, DBLookupUtilsEh, PropFilerEh, MemTreeEh,
  DataDriverEh, ADODataDriverEh, ImgList, StdActns, ActnList, Jpeg, PngImage,
  ShellApi, XlsMemFilesEh, DBGridEhXlsMemFileExporters, DBGridEhImpExp, TypInfo,
  uData, uString, uSettings, uExcel, uDBOra, uSys;

type
  TmyCustomDBEditEh = class(TCustomDBEditEh)
  public
    Color: TColor;
  end;

const
  //константы, задающие размеры контролов на форме, отступы между ними и тп
  MY_FORMPRM_V_TOP = 4;                    //отступ от верха формы/панели до верха первого контрола
  MY_FORMPRM_V_MARGIN = 6;                 //вертикальное расстояние между контролами
  MY_FORMPRM_H_EDGES = 4;                  //горизонтальные рассотяния между краями панели и крайними контролами
  MY_FORMPRM_BTN_DEF_H = 25;               //дефолтная высота кнопки
  MY_FORMPRM_BTN_DEF_W = 75 + 10;          //дефолтная ширина кнопки
  MY_FORMPRM_BTN_H_MARGIN = 4;             //дефолтное расстояние между кнопками по горизонтали
  MY_FORMPRM_BTN_V_MARGIN = 4;             //дефолтное расстояние между кнопками по вертикали
  MY_FORMPRM_SPEEDBTN_DEF_H = 32;          //дофотная высота для большой кнопки TSpeedButton
  MY_FORMPRM_SPEEDBTN_VH_MARGIN = 1;       //отступы между кнопками и по веритикали и по горизонтали для панелей из TSpeedButton
  MY_FORMPRM_BTNPANEL_V_EDGES = 3;         //отступы по вертикали сверху и снизу от кнопок для панели кнопок внизу диалоговых окон
  MY_FORMPRM_BTNPANEL_TOP_BEVEL = True;    //использовать разделительную черту, отделяющую панель кнокоп на форме
  MY_FORMPRM_LABEL_H = 13;
  MY_FORMPRM_CONTROL_H = 21;

  //типы кнопок
  cbttSBig = 1;        //TSpeedButton MY_FORMPRM_SPEEDBTN_DEF_H - большой квадратный
  cbttSSmall = 2;      //TSpeedButton MY_FORMPRM_BTN_DEF_H - малый квадратный
  cbttBNormal = 3;        //TBiеBtn высотой MY_FORMPRM_CONTROL_H длиной MY_FORMPRM_BTN_DEF_W - обычный диный
  cbttBSmall = 4;      //TBiеBtn MY_FORMPRM_BTN_DEF_H - обычный квадратный
  cbttBCtl = 5;        //TBiеBtn MY_FORMPRM_CONTROL_H - обычный квадратный по размеру контрола типа TEdit
                       //при другом чиле TBiеBtn высотой MY_FORMPRM_CONTROL_H длиной равной числу

  //предопределенные типы переменных DynProp для DbEh-Controls
  dpVerify = 'verify';
  dpError = 'error';
  dpErrorMsg = 'ErrorMsg';
  dpIsChanged = 'IsChanged';
  dpSaveValue = 'SaveValue';

type
  TGridEhHelper = record
  private
    //разобьем переданные в параметрах строки полей и значений (через ;) на массивы
    //если установлено, проверим совпадение длин полученных массивов.
    //вернем статус ошибки
    function FieldsAndValuesToArr(AFields, AValues: Variant; var Fields: TVarDynArray; var Values: TVarDynArray; CheckLength: Boolean = False): Boolean;
  public
    //устанавливем дефолтные свойства грида
    procedure SetGridOptionsDefault(DBGridEh: TDBGridEh; Excl: TmyDbEhSet = []);
    //устанавливает основные опции кастомизации грида (фильтр, стфильтр, сортировка
    procedure SetGridOptionsMain(DBGridEh: TDBGridEh; Filter: Boolean = True; STFilter: Boolean = True; Sort: Boolean = True);
    //установить внешний вид заголовка (градиент по стандартным цветам или серый)
    procedure SetGridOptionsTitleAppearance(DBGridEh1: TDBGridEh; Gradient: Boolean = True);
    //вернуть номер колонки грида по названию поля (регистр значения не имеет). если не найден - вернет -1
    function GetGridColumnNo(DBGridEh1: TDBGridEh; FieldName: string): Integer;
    //вернуть объект колонки грида по названию поля (регистр значения не имеет). если не найден - вернет nil;
    function GetGridColumn(DBGridEh1: TDBGridEh; FieldName: string): TColumnEh;
    //возвращает строку служдебных полей грида через ;
    //служебными считаются поля, чьи ЗАГОЛОВКИ начинаются с _
    //2024-01-26 изменено - если есть _ID или _id то только по этому полю,
    //так как служебные в общем могут меняться при редактировании записи
    function GetGridServiceFields(DBGridEh1: TDBGridEh): string;
    //устанавливавет свойства столбца грида для данного поля (тип свойства TColumnPropertyType)
    function SetGridColumnProperty(DBGridEh1: TDBGridEh; PropType: TColumnPropertyType; Field: string; Value: Variant): Boolean;
    //устанавливает свойства перечисленных через ; столбцов грида
    //значения Values тоже перечисляются через ; и приводятся к нужному типу
    //их должно быть столько же, сколько полей или меньше, в этом случае для недостающих будет использовано последнее значение
    function SetGridColumnsProperty(DBGridEh1: TDBGridEh; PropType: TColumnPropertyType; Fields: string; Values: Variant): Boolean;
    //установка картинок в столбцах грида
    //передается массив массиво следующего вида:
    //[[Fields, Values, Indexes, Use default True, ImageList default IL_All16],..]
    //каждый подмассив содержит условие выбора картинки единое для перечисленных через ; полей
    //если после поля стоит "+" то в ячейке будет отображаться и текст
    //Values - значения полей через, в любом порядке, и соответствующие им имиджиндекс могут быть в любом порядке ;
    //Indexes - соответствующие им значения  ImageIndex через ;, если из больше то следующее берется в качестве дефолтной картинки
    //Use - использовать этот подмассив, если True или просто не задано; если False то игнорируем - для учета прав доступа
    procedure SetGridInCellImagesAdd(DBGridEh1: TDBGridEh; Params: TVarDynArray2);
    //установка картинок в столбцах грида - упрощенная версия
    procedure SetGridInCellImages(DBGridEh1: TDBGridEh; Fields: string; Image: TImageList; Keys: string; KeyOther: Integer = -1);
    //добавляет кнопки в ячейки грида
    procedure SetGridInCellButtons(DBGridEh1: TDBGridEh; Fields: string; AHints: string; AButtonClickEventEh: TButtonClickEventEh; AHPosition: TEditButtonHorzPlacementEh = ebhpRightEh; AStyle: TEditButtonStyleEh = ebsEllipsisEh; AImageIndex: Integer = -1; ACaption: string = ''; AAutoFade: Boolean = True); //
    //создает кнопки в ячейках грида в виде чекбоксов
    procedure SetGridInCellButtonsChb(DBGridEh1: TDBGridEh; Fields: string; Hints: string; ButtonClickEventEh: TButtonClickEventEh; ButtonDrawEventEh: TDrawCellButtonEventEh);
    //установка в ячейках грида обычных чекбоксов
    //эта процедура поддерживает только чекбоксы для значений поля 0 и 1
    procedure SetGridInCellCheckBoxes(DBGridEh1: TDBGridEh; Fields: string; Keys: string; KeyOther: Integer = -1);
    //устанавливает выпадающий список для стошлбца, найденного по имени поля
    //передается список значений, список ключей (в одномерных вариант массивах), и признак возможности выбрать только из списка
    //список ключей может быть пустой и тогда не устанавливается
    procedure SetGridColumnPickList(DBGridEh1: TDBGridEh; AFielDName: string; APickList: TVarDynArray; AKeyList: TVarDynArray; ALimitTextToListValues: Boolean = False); overload;
    //устанавливает выпадающий список для стошлбца, найденного по имени поля
    //передается список значений, список ключей (в двухмерном массиве, переадются номера столбцов для значения и ключа), и признак возможности выбрать только из списка
    procedure SetGridColumnPickList(DBGridEh1: TDBGridEh; AFielDName: string; APickKeyList: TVarDynArray2; APickPos: Integer = 0; AKeyPos: Integer = 1; ALimitTextToListValues: Boolean = False); overload;
    //проверяет, используется ли в гриде фильтр в столбцах
    function GridFilterInColumnUsed(DbGridEh1: TDbGridEh): Boolean;
    //сохраняет в массиве значения фильтра в строке и в столбцах
    function GridFilterSave(DbGridEh1: TDbGridEh): TVarDynArray2;
    //очищает фильтр в столбцах и в строке (опции ColumnFilter и StFilter)
    procedure GridFilterClear(DbGridEh1: TDbGridEh; ColumnFilter: Boolean = True; StFilter: Boolean = True);
    //восстанавливает фильтр в столбцах и в строке из сохранения
    procedure GridFilterRestore(DbGridEh1: TDbGridEh; FilterArr: TVarDynArray2; ColumnFilter: Boolean = True; StFilter: Boolean = True);
    //инвертирует порядок дат в выподающем фильтре по дате
    procedure GridDateFilterModify(Sender: TCustomDBGridEh; Column: TColumnEh; Items: TStrings; var Processed: Boolean; FieldNames: TVarDynArray);
    //ставит/снимает/инвертирует (1/-1/0) отметку ВИДИМЫХ строк в гриде (будут отмечены чекбоксы в индикаторном столбце)
    procedure SetGridIndicatorSelection(DbGridEh1: TDbGridEh; Mode: Integer);
    //вернем двумерный массив всех отмеченных чекбоксами строк грида
    //если задан FieldNo >= 0, то по этому полю, иначе все поля данных
    function GetGridArrayOfChecked(DbGridEh1: TDbGridEh; FieldNo: Integer): TVarDynArray2;
    //вернем тектовую инфу о количестве записей в гриде (всего, выделено, отфильтровано)
    function GetGridInfoStr(DbGridEh1: TDbGridEh): string;
    //задается текст подсказки
    //исходные данные передаются в массиве вида [[text, active],[text2],[text3,active3]]
    //также заменяются дефолтные подстроки
    //передается форма для взятия заголовка
    procedure GridRefresh(DBGridEh: TDbGridEh; Grayed: Boolean = False);
    procedure DBGridEhAdvDrawDataCellDefault(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
    //экспортирует грид в формат Excel, использую встроенные средства EhLib
    procedure ExportGridToXlsxNew(DBGridEh1: TDBGridEh; FileName: string; AutoOpen: Boolean; Header: string = ''; Footer: string = ''; FontFormat: Boolean = False; CreateAutoFilter: Boolean = False);
    procedure SetVeryfyCoumnEhRule(C: TColumnEh; CVerify: string = '');
    function  VeryfyCoumnEhValue(C: TColumnEh; NewValue: Variant; var CorrectValue: Variant): Boolean;
    //для режима DBGridEh.DataGrouping раскроем/схлопнем рекурсивно корневую группу,
    //на которой (или на дочерней записи в пределах которой) находится курсор
    //AExpand: -1 - схопнуть, 1 - раскрыть, 0 - инвертировать
    procedure RootGroupExpandCollapse(DBGridEh: TDBGridEh; AExpand: Integer = 0);
    //для режима DBGridEh.DataGrouping раскроем/схлопнем все группы
    //если Level < 0 то только для групп данного уровня
    //иначе раскроем начиная с корневого уровня и до указанного
    procedure AllGroupsExpandCollapse(DBGridEh: TDBGridEh; Level: Integer = 0; Expand: Boolean = True);
  end;

var
  Gh: TGridEhHelper;

type
  TTempBtnRec = record
     BtnId: Integer; BtnVis, LastBtnVis: Boolean; IsDropDown: Integer; BtnCapt, BtnPict: string; ShortCut: Integer; BtnState: Boolean; BtnW: Integer
  end;



type
  TControlsHelper = record
  private
    //вспомогательная функция для создания панелей кнопок и меню
    //получает параметры кнопки по данным массива параметров кнопок и некоторах вспомогательных переменных
//    function GetButtonParams(AButtons: TVarDynArray2; p: Integer; var BtnRec: TTempBtnRec): Boolean;
    function GetButtonParams(AButtons: TVarDynArray2; p: Integer; var BtnRec: TmybtRec; var BtnId: Integer; var BtnVis, LastBtnVis: Boolean;
      var IsDropDown: Integer; var BtnG: Integer;
      var BtnCapt, BtnPict: string; var ShortCut: Integer; var BtnState: Boolean; var BtnW: Integer): Boolean;
  public
//найти все дочерние (по Parent) контролы родителя, если Recursive то и его дочерних элементов
//вернет массив контролов
function GetChildControls(Parent: TWinControl; Recursive: Boolean = True): TControlArray;
//найти все дочерние (по Parent) контролы родителя, если Recursive то и его дочерних элементов
//вернет иена контролов
function GetChildControlNames(Parent: TWinControl; Recursive: Boolean = True): TVarDynArray;
//выравнивает контролы в переданном конейнере, устанавливает порядок табуляции
//подгоняются друг под друга, расстояния по верикали и отступы по константам приложания
//проверить, является ли контрол дочерним (по Parent) элементом родителя, рекурсивно или нет
function IsChildControl(Parent: TWinControl; Control: TControl; Recursive: Boolean = True): Boolean; overload;
function IsChildControl(Parent: TWinControl; Control: string; Recursive: Boolean = True): Boolean; overload;
//сделать все дочерние панели (кроме [Exclude]) плоскими и без captions
procedure MakePanelsFlat(Parent: TWinControl; Exclude: TControlArray; Recursive: Boolean = True; Flat: Boolean = True; NoCaption: Boolean = True);
//выравнивает контролы в переданном конейнере, устанавливает порядок табуляции
//подгоняются друг под друга, расстояния по верикали и отступы по константам приложания
//если ResizeParent, то подгоняет высоту родителя
//возвращает в массиве получающуюся высоту и ширину
function AlignControls(AParent: TObject; Exclude: TControlArray; ResizeParent: Boolean = False; VMargin: Integer = 0; LabelsToLeft: Boolean = False): TCoord;
//устанвливает TabOrder в переданном контейнере по контролам, слева направо, сверху вниз
procedure FixTabOrder(const Parent: TWinControl);
//вернет контрол, имеющий нулевой TabOrder
//НЕВЕРНО!!!
function GetFirstTabControl(const Parent: TWinControl): TWinControl;
//установим (создадим или ззаменим) DynProps для DbEh контролов, данные возьмем из массива
//[[PropName {,Value}, {True=установить, False=Удалить}], [PropName2 {,Value2}]..
procedure SetDynProps(Control: TObject; DynProps: TVarDynArray2);
//возвращает значение свойства с именем DynProp для DbEh контролов
//если свойство не найдено, возвращает пустую строку
function GetDynProp(Control: TObject; DynProp: string): Variant;
function GetOwneredControlNames(AOwner: TComponent): TVarDynArray;
procedure SetControlsEhEvents(AParent: TWinControl; AOnlyFields: Boolean; AIfEmptyEvent: Boolean; AOnEnter, AOnExit, AOnChange: TNotifyEvent; AOnCheckDrawRS: TOnCheckDrawRequiredStateEventEh);
procedure LoadBitmap(ImageList: TImageList; Number: Integer; Bitmap: TBitmap);
    procedure SetControlValue(c: TControl; v: Variant); overload;
    procedure SetControlValue(f: TObject; c: string; v: Variant); overload;
    //вазвращаем значения из DBEhCtrls
    function GetControlValue(c: TObject): Variant; overload;
function GetControlValue(AOwner: TComponent; CName: string): Variant; overload;
    //создаем контролы
    function CreateControls(AParent: TWinControl; CType: TMyControlType; CLabel: string = ''; CName: string = ''; CVerify: string = ''; Tag: Integer = 0; Left: Integer = 0; Top: Integer = 0): TControl;
    //проверка значения, для проверкки используется маска в динварс
    //CVerify - min:max:digits:inult:validchars:invalidcars
    //1,2,3 минимальное значение и максимальное и количество дробных знаков для чисел, 4 не '' - недопустимо null
    //  или минимальное и максимальная длина строки
    //4 - n - допустимо пустой значение
    //4 - i - для комбобокса - значение должно быть в списке
    //4 - u/l - для комбо и эдит - вводятся большие или маленькие буквы
    //4 - t - трим для строки, только если не OnInput
    //5 - инвалидные символы
    //6 - валидные символы
    //1 для даты, если =1 то недопустимо пустое значение
    //{Дата}:{Дата} для даты, для задания минимального и максимального диапозона дат, обе не обязательны
    function VerifyControl(C: TControl; OnInput: Boolean = True): Boolean;
    //устанавливает или снимает в зависимости от HasError динамическую переменную 'error' в DinProps
    //для контрола, чтобы в дальнейшем визуализировать и проверить на ошибки
    procedure SetErrorMarker(c: TControl; HasError: Boolean);
    //визуализирует ошибочные значения контролов на всей форме, подчеркиванием красной пунктирной линией
    //ориентируясь на переменную Еррор в динпропс
    function VerifyVisualise(f: TForm): Boolean;
    //установить контрол редактируемым или нет; если нет, то или disabled, или readonly. если Greyed то затемнить
    procedure SetControlNotEditable(AControl: TControl; Disabled: Boolean = False; DisabledOrReadOnly: Boolean = True; Greyed: Boolean = False);
    //устанавливает статус Енаблед для всех контролов диалоговой формы кроме основных кнопок в зависимости от режима диалога
    //если диалог не делете или вью то может поставить кастомные статусы контролдам, переданным в массиве
    procedure DlgSetControlsEnabled(F: TForm; Mode: TDialogType; CustomCtrls: array of TControl; CustomState: TVarDynArray);
//условия проверки контрола записываются в динварс, и также выставляются граничные условия контролов по этим данным
procedure SetControlVerification(Control: TControl; Verify: string);
    //передается массив контролдов и массив условий проверки
    //условия проверки записываются в динварс, и также выставляются граничные условия контролов по этим данным
    procedure SetControlsVerification(Controls: array of TControl; Verify: TVarDynArray); overload;
    procedure SetControlsVerification(Owner: TComponent; ControlsVerifycation: TVarDynArray); overload;
    //установить вссем дбэх контролам формы пустые значения
    procedure SetControlsEmptyText(ASelf: TForm);
    //установить вссем дбэх контролам формы событития ончейнж
    //используем Self.ComponentCount а не Self.ControlCount, так как последний проходит только по родителю, а не по всей форме, те не проставит например если контролы на панелях
    procedure SetControlsOnChange(ASelf: TForm; c: TNotifyEvent; WithCheckboxes: Boolean = False);
    //найдем компонент на форме, соответствующие названию поля
    //(поле может быть с модификатором и алиасом)
    function FindControlByFieldName(ASelf: TForm; FieldName: string): TControl;
    //установить вссем дбэх контролам формы событития onExit
    procedure SetControlsOnExit(ASelf: TForm; c: TNotifyEvent);
    //создает несколько колоризованных лейблов друг под другом; если символ "$" в заголовке не найден, создается просто TLabel
    function  CreateLabelColors(AParent: TWinControl; ACaptions: TVarDynArray): Integer;
    //задает цвет фона контрола
    procedure SetEhControlColor(AControl: TControl; Color: TColor);
    //показывает/скрывает кнопки в полях ввода
    procedure SetEhControlEditButtonState(AControl: TControl; Visible, Enabled: Boolean);
    //установить вссем дбэх контролам формы событития OnCheckDrawRequiredState
    procedure SetControlsOnCheckDrawRequired(ASelf: TForm; c: TOnCheckDrawRequiredStateEventEh);
    //проверить все дбэх контролы на форме
    procedure VerifyAllDbEhControls(ASelf: TForm);
    //найти родительскую форму для контрола
    function GetParentForm(C: TControl): TForm;

function CreateButtons(APanel: TPanel; AButtons: TVaRDynArray2; AOnClick: TNotifyEvent; AButtonType: Integer = 1 ; ASuffix: string = ''; APanMargins: Integer = 0; AHeight: Integer = 0; AVertical: Boolean = False): Integer;
//создает меню ПКМ
procedure CreatePopupMenu(AComponent: TComponent; AButtons: TVaRDynArray2; AOnClick: TNotifyEvent; ASuffix: string = '');
//меняет заголовок пункта ПКМ или кнопки (для SpeedButton меняет Hint), и свойство Enabled,
//находя элемент в переданных компонентах по тегу
procedure SetButtonsAndPopupMenuCaptionEnabled(AComponents: TComponentsArray; ATag: Integer; ACaption: Variant; AEnabled: Variant; ASuffix: string = ''); overload;
//меняет заголовок пункта ПКМ или кнопки (для SpeedButton меняет Hint), и свойство Enabled, для всех элементов этого типа принадлежащих AOwner
//(если задан тег то проверяет его в имени компонента)
//чтобы не менять статус или текст заголовка, в данных полях ставить null!
procedure SetButtonsAndPopupMenuCaptionEnabled(AOwner: TComponent; ATag: Integer; ACaption: Variant; AEnabled: Variant; ASuffix: string = ''); overload;
//настраивает уже созданную МенюИтем по данным элемента массива кнопок
//если заданы ANewCaption или ANewEnabled, то меняет их, но в этом случае если к кнопке кастомная картинка была при сощздании,
//а здесь не задана, то она не станет серой при дисейблед меню, надо задавать явно здесь
//если задан гроупиндекс то пункты становятся с чекбоксами, но последние не видны,
//если к к нопке есть картинка, а если ее нет, то заголовки съезжают влево
procedure SetMenuItem(AMenuItem: TMenuItem; AButton: TVarDynArray; ANewCaption: string = ''; ANewEnabled: Integer = -1); overload;
//Устанавливает параметры кнопки типа TBitBtn или TSpeedButto,
//паредается кнопка, айди btnXXX (если есть в дефолтных то параметры берутся из него), событие нажатия (если nil то не изменяеится),
//тип cbttSBig,cbttSSmall,cbttBNormal,cbttBSmall,cbttBCtrl или Int - cbttBBig с шириной этим числом,
//но ширина может быть также задана явно (не 0), тогда она имеет приоритет
//если ширина кнопки больше 42 то заголовок указывается явно
//также для TSpeedButton устанавливается GroupIndes = AGroup, если оно меньше 100 то кнопки работают отдельно, иначе групповыми
procedure SetBtn(ABtn: TControl; ABtnId: Integer; AOnClick: TNotifyEvent = nil; ABtnType: Integer =cbttBNormal; AWidth: Integer = 0; AGroup: Integer = 0; ACaption: string = ''; APicture: string = ''); overload;
//создает массив из всех компонентов указанного родителя и его дочерних компонентов рекурсивно, используя заданные уусловия
//прередается имя компонента, суффикс и тег. все не обязательно. если не указано ничего, то переберет все компоненты
function  EnumComponents(AParent: TComponent; AControlName: string; ASuffix: Integer = 0; ATag: Integer = 0): TComponentsArray;


    //создает кнопки для редактирования грида на переданной форме в переданной панели, задаются массив произвольных записей кнопок а также рапзделителей
    //кнопки создаются в порядке, переданном в массиве
    function CreateGridBtns(AForm: TForm; APanel: TPanel; AButtons: TmybtArr; AButtonsState: TVarDynArray; AOnClick: TNotifyEvent; ASuffix: string = ''; Vertical: Boolean = False): Integer;
    //возвращает SpeedButton с данным тэгом в имени, созданный процедурой CreateGridBtns
    function GetSpeedBtn(Owner: TComponent; Tag: Integer; ASuffix: string = ''): TSpeedButton;
    //создает меню ПКМ
    procedure CreateGridMenu(AForm: TForm; Pm: TPopupMenu; AButtons: TmybtArr; AButtonsState: TVarDynArray; AOnClick: TNotifyEvent; ASuffix: string = '');
    //устанавливает SpeedButton.Enabled с данным тэгом в имени, созданный процедурой CreateGridBtns
    procedure SetSpeedBtnEnabled(Owner: TComponent; Tag: Integer; Enabled: Boolean = True);
    //устанавливает SpeedButton.Enabled с данным тэгом в имени, созданный процедурой CreateGridBtns
    //НЕВЕРНО работет если есть два набора кнопок или два меню, с префиксом в тэге
    procedure SetBtnAndMenuEnabled(Owner: TComponent; Pm: TPopupMenu; Tag: Integer; Enabled: Boolean = True; ASuffix: string = '');
    //настраивает уже созданную МенюИтем по данным записи для кнопки (используется тот же формат записей чяято и для кнопки)
    procedure SetMenuItem(Btn: TMenuItem; const BtnProps: TmybtRec; UsePicture: Boolean = False; Caption: string = ''); overload;
    //формируем массив наименований и значений компонентов с указанной формы, и указанным родителем (или всех, если nil)
    //если передан массив IncludeNames, то формируем только по этим компонентам
    //если передан ExcludeNames, то эти компоненты исключаем
    //регистр имен компонентов значений не имеет, но в выходном массиве они будут в верхнем регистре
    //получим массив виде [[NAME1, value1], [NAME2, value2]]
    function GetControlValuesArr2(F: TForm; Parent: TComponent; IncludeNames, ExcludeNames: TVarDynArray): TVarDynArray2;
    //установим значений контролов на форме из переданного двухмерного массива
    //в формате возврата GetControlValuesArr2
    procedure SetControlValuesArr2(F: TForm; v: TVarDynArray2);
    //сериализает массив возврата GetControlValuesArr2
    //[[NAME1, value1], [NAME2, value2]]
    //в строку   NAME1#1value1#0NAME2#1value2#0
    //если в значенийя массив присутствуют Chr(1) или Chr(2), то результата будут неверным!!!
    //ВАЖНО!!!
    //после чтения из БД (или при записи?) - (а не после чтения из настроечного файла!) крайние справа в строке записываемого параметра #1 и #2 удаляются!!!
    //также будут удалены пробелы в колнце строки
    function SerializeControlValuesArr2(v: TVarDynArray2): string;
    //возвращает массив по строке, созданной SerializeControlValuesArr2
    function DeSerializeControlValuesArr2(st: string): TVarDynArray2;
    //найти контрол на форме и получить значение в вариант, если не найден будет ''
    function GetFindControlValue(Form: TForm; Name: string): Variant;
    //найти контрол на форме и получить значение в string, если не найден будет ''
    function GetFindControlText(Form: TForm; Name: string): Variant;
    //добавляет значения в комбобокс из массива [[value1,key1,condition1],[value2,...
    //где в массивах обязателен только нулевой элемент
    procedure AddToComboBoxEh(DBComboboxEh: TDBComboboxEh; v: TVarDynArray2; Append: Boolean = False);
    //проверяет, является ли датой текущее значение контрола типа DBDateTimeEditEh
    function DteValueIsDate(DBDateTimeEditEh1: TDBDateTimeEditEh): Boolean;
    //отрисовать красную линию подчеркивания в указанном контроле для индикации ошибки
    procedure DotRedLine(Control: TControl; DrawLine: Boolean = True);
    //Устанавливает параметры кнопки типа TBitBtn
    procedure SetBtn(Btn: TBitBtn; const BtnProps: TmybtRec; SmallBtn: Boolean = False; Caption: string = ''); overload;
  //Deperecates
    procedure SetSpeedButton(Btn: TSpeedButton; const BtnProps: TmybtRec; SmallBtn: Boolean = False; Caption: string = '');
    procedure AlignControlsL(Controls: TControlArray);
    procedure AlignControlsR(Controls: TControlArray);
    //++убрать
    procedure CreateBtns(AForm: TForm; APanel: TPanel; AButtons: TByteSet);

    //настривает диалоговое окно стандартного типа (добавить/изменить/удалить/просмотреть)
    //задает заголовок - переданный плюс через - режим дилога
    //настраивает кнопки (для просмотра - закрыть, для удаления - удалить и отмена, иначе Ок и отмена)
    procedure SetDialogForm(Form: TForm; Mode: TDialogType; Caption: string);
    //настраивает заголовок диалогового окна стандартного типа (добавить/изменить/удалить/просмотреть)
    //если заголовок начинается на '~', то к нему ничего не добавляется, символ удаляется
    procedure SetDialogCaption(Form: tObject; Mode: TDialogType; Caption: string);
    //получает строку соответствующую типу операции для диалогового окна
    function FModeToCaption(fMode: TDialogType): string;
    //возвращает соответствие между тэгами кнопок и вызываемыми ими режимами диалога
    function BtnModeToFMode(btn: Integer): TDialogType;
    //возвращает соответствие между тэгами кнопок и вызываемыми ими режимами диалога
    function FModeToBtnMode(fMode: TDialogType): Integer;
    //возвращает запись дефолтной для вызова данного типа диалога кнопки
    function FModeToBtnRec(fMode: TDialogType): TMyBtRec;
    //подготавливает картинку-хелп
    //передается картинка, текст, размер картинки (масштабируется из ресурса 32*32)
    //если текст разделен ___ то что до этого разделителя выводится в подсказке, а что после - в окне
    //если тект разделен ... то в хинте выводится с начала текста, включая ..., в окне выводится полностью, многоточие вырезается
    //если без разделителей то выводится все и в хинте и в окне
    function SetInfoIconText(Form: TForm; Info: TVarDynArray2): string;
    procedure SetInfoIcon(Pict: TImage; Info: string; Width: Integer = 20);
    //устанавливает или сбрасывае курсов в  виде песочныч часво
    procedure SetWaitCursor(Wait: Boolean = True);
  end;

var
  Cth: TControlsHelper;

type
  TTableHelper = record
    //выдает Пост для таблицы, если статус dsEdit or dsInsert
    procedure Post(MemTableEh: TMemTableEh);
    //выдает Пост для таблицы, если статус dsEdit or dsInsert, и после переводит ее в состояние Edit
    procedure PostAndEdit(MemTableEh: TMemTableEh);
    //добавляет столбец в грид, но не в memtable
    procedure AddGridColumn(DBGridEh1: TDBGridEh; aFieldName: string; aCaption: string; aWidth: Integer; aVisible: Boolean);
    //добавляет столбец в memtable и в грид
    //если заголовок начинается с пробела, то он располагается вертикально
    procedure AddTableColumn(DBGridEh1: TDBGridEh; aFieldName: string; aFieldType: TFieldType; aFieldSize: Integer; aCaption: string; aWidth: Integer; aVisible: Boolean = True; aAutoFitColWidth: Boolean = False; aWordWrap: Boolean = False);
    //загружает мемтейбл, являющийся источником данных дбгрида, из массива
    //если переданы и AMemTableFields(через ;) и AArrayColumns(№ колонки массива через ;), то сопоставит поля и колонки массива,
    //иначе загрузит грид один в один
    procedure LoadGridFromVa2(DBGridEh1: TDBGridEh; AValues: TVarDynArray2; AMemTableFields: string; AArrayColumns: string; AClearTable: Boolean = True);
    function  LoadMemTableFromNamedArray(MemTableEh: TMemTableEh; Values: TNamedArr; ByFieldNames: Boolean = True; AClearTable: Boolean = True): Boolean;
    function  LoadGridFromNamedArray(DBGridEh1: TDBGridEh; Values: TNamedArr; ByFieldNames: Boolean = True; AClearTable: Boolean = True): Boolean;
    //заполняет пареаметры таблицу DBGridEh и ее MemTable
    //передаются параметры столбцов в 2х мерном массиве
    //поле, тип данных, размер данных, заголовок (может с " ", "_", "|"), отображаемая ширина, видимость, автоподгонка ширины, перенос для столбца по словам
    //в зависимости от параметров заголовков корректируется заголовок таблицы (вертикальные, многострочные, скрываются столбцы с _
    //если установлен ADefaultVis, то применяются дефолтные настройки (раскраска, индикаторный столбец...)
    //задаются требования установить фильтр в строке, столбцах и сортировку
    //если передан непустой двухмерный массив, то пытается заполнить данными из него, по порядку массива и полей если не переданы AColumns и AValues
    //если последние переданы, то должну содержать первый список полей через ; а второй номера столбцов в исходном массиве через ;
    procedure CreateTableGrid(DBGridEh1: TDBGridEh; ADefaultVis: Boolean; AFilter: Boolean; ASTFilter: Boolean; ASort: Boolean; const AColumns: TVarDynArray2; AValues: TVarDynArray2; AMemTableFields: string; AArrayColumns: string);
    //тестовая процедуры, обновить/добавить/удалитть строки в гриде после диалога изменения, по переданным айди, чтобы не обновлять всю таблицу
    function AppendGrid(DBGridEh1: TDBGridEh; Table: string; IDs: TVarDynArray2): Integer;
  end;

function clmyPink: Cardinal;
function clmyYelow: Cardinal;
function clmyGreen: Cardinal;
function clmyGray: Cardinal;


var
  Mth: TTableHelper;

implementation

uses
  uFrmMain, uMessages, V_Normal, uLabelColors2, uFrDBGridEh, uFrmBasicMdi;


function clmyPink: Cardinal;
begin
  Result := RGB(255, 180, 180);  //розовый
end;
function clmyYelow: Cardinal;
begin
  Result := RGB(255, 255, 100);  //желтый
end;
function clmyGreen: Cardinal;
begin
  Result := RGB(180, 255, 180);  //зеленоватый
end;
function clmyGray: Cardinal;
begin
  Result := RGB(200, 200, 200);  //серый
end;



//==============================================================================
//  TGridEhHelper.
//==============================================================================

//-----------------------работа со свойствами столбцов--------------------------

function TGridEhHelper.FieldsAndValuesToArr(AFields, AValues: Variant; var Fields: TVarDynArray; var Values: TVarDynArray; CheckLength: Boolean = False): Boolean;
//разобьем переданные в параметрах строки полей и значений (через ;) на массивы
//если установлено, проверим совпадение длин полученных массивов.
//вернем статус ошибки
begin
  Result := False;
  A.ExplodeP(AFields, ';', Fields);
  A.ExplodeP(AValues, ';', Values);
  if (Length(Fields) = Length(Values)) or not CheckLength then
    Result := True;
end;

function TGridEhHelper.SetGridColumnsProperty(DBGridEh1: TDBGridEh; PropType: TColumnPropertyType; Fields: string; Values: Variant): Boolean;
//устанавливает свойства перечисленных через ; столбцов грида
//значения Values тоже перечисляются через ; и приводятся к нужному типу
//их должно быть столько же, сколько полей или меньше, в этом случае для недостающих будет использовано последнее значение
var
  FieldNames, PropValues: TVarDynArray;
  i: Integer;
begin
  FieldsAndValuesToArr(Fields, Values, FieldNames, PropValues);
  //FieldNames
  for i := 0 to High(FieldNames) do
    SetGridColumnProperty(DBGridEh1, PropType, FieldNames[i], PropValues[Min(i, High(PropValues))]);
end;

function TGridEhHelper.SetGridColumnProperty(DBGridEh1: TDBGridEh; PropType: TColumnPropertyType; Field: string; Value: Variant): Boolean;
//устанавливавет свойства столбца грида для данного поля (тип свойства TColumnPropertyType)
var
  Col: TColumnEh;
begin
  Result := False;
  try
    Col := DBGridEh1.FindFieldColumn(S.ToUpper(S.GetFieldNameFromSt(Field)));
    if Col = nil then
      Exit;
    case PropType of
      cptCaption:
        Col.Title.Caption := VarToStr(Value);
      cptWidth:
        Col.Width := S.VarToInt(Value);
      cptEditable:
        Col.ReadOnly := False;
      cptReadOnly:
        Col.ReadOnly := True;
      cptVisible:
        Col.Visible := True;
      cptDisplayFormat:
        Col.DisplayFormat := VarToStr(Value);
      cptSumFooter:
        begin
          DBGridEh1.FooterRowCount := 1;
          DBGridEh1.SumList.Active := True;
          Col.Footer.ValueType := fvtSum;
          Col.Footer.DisplayFormat := VarToStr(Value);
        end;
    end;
    Result := True;
  except
    on E: Exception do
      Application.ShowException(E);
  end;
end;

(*
function TGridEhHelper.SetGridColumnProperty(DBGridEh1: TDBGridEh; PropType: TColumnPropertyType; Field: string; Value: Variant): Boolean;
//устанавливавет свойства столбца грида для данного поля (тип свойства TColumnPropertyType)
var
  Col: TColumnEh;
begin
  Result := False;
  try
    Col := DBGridEh1.FindFieldColumn(S.ToUpper(S.GetFieldNameFromSt(Field)));
    if Col = nil then
      Exit;
    case PropType of
      cptCaption:
        Col.Title.Caption := VarToStr(Value);
      cptWidth:
        Col.Width := S.VarToInt(Value);
      cptEditable:
        Col.ReadOnly := Value;
      cptReadOnly:
        Col.ReadOnly := Value;
      cptVisible:
        Col.Visible :=Value;
      cptDisplayFormat:
        Col.DisplayFormat := VarToStr(Value);
      cptSumFooter:
        begin
          DBGridEh1.FooterRowCount := 1;
          DBGridEh1.SumList.Active := True;
          Col.Footer.ValueType := fvtSum;
          Col.Footer.DisplayFormat := VarToStr(Value);
        end;
    end;
    Result := True;
  except
    on E: Exception do
      Application.ShowException(E);
  end;
end;   *)

function TGridEhHelper.GetGridServiceFields(DBGridEh1: TDBGridEh): string;
//возвращает строку служдебных полей грида через ;
//служебными считаются поля, чьи ЗАГОЛОВКИ начинаются с _
//2024-01-26 изменено - если есть _ID или _id то только по этому полю,
//так как служебные в общем могут меняться при редактировании записи
var
  i: Integer;
begin
  Result := '';
  for i := 0 to DBGridEh1.Columns.Count - 1 do begin
    if Pos('_', DBGridEh1.Columns[i].Title.Caption) = 1 then
      S.ConcatStP(Result, DBGridEh1.Columns[i].FieldName, ';');
    if (DBGridEh1.Columns[i].Title.Caption = '_ID') or (DBGridEh1.Columns[i].Title.Caption = '_id') then begin
      Result := DBGridEh1.Columns[i].FieldName;
      Exit;
    end;
  end;
end;

//------------------- получение столбца грида ----------------------------------------

function TGridEhHelper.GetGridColumnNo(DBGridEh1: TDBGridEh; FieldName: string): Integer;
//вернуть номер колонки грида по названию поля (регистр значения не имеет). если не найден - вернет -1
var
  Col: TColumnEh;
begin
  Result := -1;
  Col := DBGridEh1.FindFieldColumn(S.ToUpper(FieldName));
  if Col <> nil then
    Result := Col.Index;
end;

function TGridEhHelper.GetGridColumn(DBGridEh1: TDBGridEh; FieldName: string): TColumnEh;
//вернуть объект колонки грида по названию поля (регистр значения не имеет). если не найден - вернет nil;
begin
  Result := DBGridEh1.FindFieldColumn(S.ToUpper(FieldName));
end;


//------------------- установка кнопок, картинок, чекбоксов в столбцах --------------

procedure TGridEhHelper.SetGridInCellImagesAdd(DBGridEh1: TDBGridEh; Params: TVarDynArray2);
//установка картинок в столбцах грида
//передается массив массиво следующего вида:
//[[Fields, Values, Indexes, Use default True, ImageList default IL_All16],..]
//каждый подмассив содержит условие выбора картинки единое для перечисленных через ; полей
//если после поля стоит "+" то в ячейке будет отображаться и текст
//Values - значения полей через, в любом порядке, и соответствующие им имиджиндекс могут быть в любом порядке ;
//Indexes - соответствующие им значения  ImageIndex через ;, если их больше то следующее берется в качестве дефолтной картинки
//Use - использовать этот подмассив, если True или просто не задано; если False то игнорируем - для учета прав доступа
var
  i, j, k, m: Integer;
  IL: TImageList;
  b: Boolean;
  va1, va2, va3, keys: TVarDynArray;
  col: TColumnEh;
  vtext: Boolean;
  defkey: Integer;
  st: string;
const
  notexistsval = #1#2#3;

  procedure Sort(var arr, arr2: TVarDynArray);
  var
    i, j, k: Integer;
    changed, tosort: Boolean;
    buf, buf2: Variant;
  begin
    repeat
      changed := False;
      for k := 0 to High(arr) - 1 do
        if (S.VarToInt(arr[k]) > S.VarToInt(arr[k + 1])) then begin
          buf := arr[k];
          arr[k] := arr[k + 1];
          arr[k + 1] := buf;
          buf2 := arr2[k];
          arr2[k] := arr2[k + 1];
          arr2[k + 1] := buf2;
          changed := True;
        end;
    until not changed;
  end;

begin
  for i := 0 to High(Params) do begin
    b := (High(Params[i]) < 3) or (Params[i][3]);
    IL := nil;
    if (High(Params[i]) < 4) or (Params[i][4] = 0) then
      IL := MyData.Il_All16;
    if IL = nil then
      Continue;
    va1 := A.ExplodeV(UpperCase(Params[i][0]), ';'); //поля
    va2 := A.ExplodeV(Params[i][1], ';');            //значения поля
    va3 := A.ExplodeV(Params[i][2], ';');            //индекс картинки
    defkey := -1;
    if Length(va3) > Length(va2) then begin
      defkey := va3[High(va2) + 1];
      va3 := Copy(va3, 0, Length(va2));
    end;
    //в KeyList перечислены значения и им соответствуют картинки в имиджлист и имиджиндекс равным позиции в кейлисте
    //поэтому, чтобы выбирать картинки не подряд, вставляем в пустые позиции значения полей, которые ни с чем не совпадут
    //перед этим еще сортируем массив
    Sort(va3, va2);
    keys := [];
    k := 0;
    for j := 0 to S.VarToInt(va3[High(va3)]) do begin
      if j <> S.VarToInt(va3[k]) then
        keys := keys + [notexistsval]
      else begin
        keys := keys + [va2[k]];
        k := k + 1;
      end;
    end;
    for j := 0 to High(va1) do begin
      vtext := False;
      if VarToStr(va1[j])[Length(va1[j])] = '+' then begin
        vtext := True;
        va1[j] := Copy(VartoStr(va1[j]), 1, Length(va1[j]) - 1);
      end;
      col := DBGridEh1.FindFieldColumn(va1[j]);
      if col = nil then
        Continue;
      col.ImageList := nil;
      if not b then
        Continue;
      col.ImageList := IL;
      col.KeyList.Clear;
      for k := 0 to High(keys) do
        col.KeyList.Add(keys[k]);
      col.NotInKeyListIndex := defkey;
      col.ShowImageAndText := vtext;
    end;
  end;
end;

procedure TGridEhHelper.SetGridInCellImages(DBGridEh1: TDBGridEh; Fields: string; Image: TImageList; Keys: string; KeyOther: Integer = -1);
//установка картинок в столбцах грида - упрощенная версия
//установим параметры столбцов грида, в которых надо отображать картинки (напр, галочки)
//передаются:
//имена полей в столбцах грида, в одной строке через ; (несколько столбцов перечисляются только в случае одинакового алгоритма выбора картинки для них)
//timagelist с соответствующими картинками
//ключевые значения столбца, в порядке соответствия индекса в компоненте имиджлист
//индекс картинки, которая выводится в случае если значения столбца нет в перечисленных; если таковая не нужна - значение меньше 0
var
  i, j, m: Integer;
  k, f: TVarDynArray;
begin
  A.ExplodeP(Fields, ';', f);
  A.ExplodeP(Keys, ';', k);
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    for j := 0 to High(f) do
      if S.ChangeCaseStr(DBGridEh1.Columns[i].FieldName, True) = S.GetFieldNameFromSt(S.ChangeCaseStr(f[j], True)) then begin
        DBGridEh1.Columns[i].ImageList := Image;
        for m := 0 to High(k) do
          DBGridEh1.Columns[i].KeyList.Add(k[m]);
        if KeyOther >= 0 then
          DBGridEh1.Columns[i].NotInKeyListIndex := KeyOther;
        Break;
      end;
end;

procedure TGridEhHelper.SetGridInCellButtons(DBGridEh1: TDBGridEh; Fields: string; AHints: string; AButtonClickEventEh: TButtonClickEventEh; AHPosition: TEditButtonHorzPlacementEh = ebhpRightEh; AStyle: TEditButtonStyleEh = ebsEllipsisEh; AImageIndex: Integer = -1; ACaption: string = ''; AAutoFade: Boolean = True);
//не присваивает события клика, никак его не передеать
var
  i, j, m: Integer;
  k, f: TVarDynArray;
  bmp: TBitMap;
//  ebsDropDownEh, Ellipsis, Glyph, UpDown,  Plus, Minus, AltDropDown, AltUpDown
//ebhpLeftEh - кнопка прижимается к левому краю ячейки.  ebhpRightEh - кнопка прижимается к правому краю ячейки. ebhpInContentEh
begin
  A.ExplodeP(Fields, ';', f);
  A.ExplodeP(AHints, ';', k);
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    for j := 0 to High(f) do
      if S.ChangeCaseStr(DBGridEh1.Columns[i].FieldName, True) = S.GetFieldNameFromSt(S.ChangeCaseStr(f[j], True)) then begin
//          bmp:=TBitmap.Create;
//          MyData.IL_CellButtons.GetBitmap(2, bmp);
  //        .Glyph:=bmp;
        DBGridEh1.Columns[i].CellButtons.Add;
        with DBGridEh1.Columns[i].CellButtons[DBGridEh1.Columns[i].CellButtons.Count - 1] do begin
          OnClick := AButtonClickEventEh;
          Style := AStyle;
          if AImageIndex > -1 then begin
            Style := ebsGlyphEh;
            Images.NormalImages := MyData.IL_CellButtons;
            Images.NormalIndex := AImageIndex;
          end;
          hint := k[j];
          AutoFade := AAutoFade;
          Caption := ACaption;
          HorzPlacement := AHPosition;
        end;
//        DBGridEh1.Columns[i].CellButtons[DBGridEh1.Columns[i]].Color
      end;
end;

procedure TGridEhHelper.SetGridInCellButtonsChb(DBGridEh1: TDBGridEh; Fields: string; Hints: string; ButtonClickEventEh: TButtonClickEventEh; ButtonDrawEventEh: TDrawCellButtonEventEh);
//создает кнопки в ячейках грида в виде чекбоксов
var
  i, j, m: Integer;
  k, f: TVarDynArray;
begin
  A.ExplodeP(Fields, ';', f);
  A.ExplodeP(Hints, ';', k);
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    for j := 0 to High(f) do
      if S.ChangeCaseStr(DBGridEh1.Columns[i].FieldName, True) = S.GetFieldNameFromSt(S.ChangeCaseStr(f[j], True)) then begin
        DBGridEh1.Columns[i].CellButtons.Add;
        DBGridEh1.Columns[i].CellButtons[0].Width := 24;  //для возможжности отрисовки зеленой полосы слева при редактируемости
        with DBGridEh1.Columns[i].CellButtons[0] do begin
          Images.NormalImages := MyData.IL_CellButtons;
          Style := ebsGlyphEh;
          DrawBackTime := edbtNeverEh;  //Убрать отрисовку фона кнопки
          OnClick := ButtonClickEventEh;
          HorzPlacement := ebhpLeftEh;
          Pressable := False;           //Чтобы при нажатии на кнопку не былу эффекта нажатия/сдвига
            //OnDraw := ButtonDrawEventEh;
          hint := k[j];
        end;
      end;
end;

procedure TGridEhHelper.SetGridInCellCheckBoxes(DBGridEh1: TDBGridEh; Fields: string; Keys: string; KeyOther: Integer = -1);
//установка в ячейках грида обычных чекбоксов
//эта процедура поддерживает только чекбоксы для значений поля 0 и 1
var
  i, j, m: Integer;
  k, f: TVarDynArray;
begin
  A.ExplodeP(Fields, ';', f);
  A.ExplodeP(Keys, ';', k);
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    for j := 0 to High(f) do
      if S.ChangeCaseStr(DBGridEh1.Columns[i].FieldName, True) = S.GetFieldNameFromSt(S.ChangeCaseStr(f[j], True)) then begin
        DBGridEh1.Columns[i].Checkboxes := True;
        DBGridEh1.Columns[i].KeyList.Add('1');
        DBGridEh1.Columns[i].KeyList.Add('0;');
        if KeyOther >= 0 then
          DBGridEh1.Columns[i].NotInKeyListIndex := KeyOther;
        Break;
      end;
end;

procedure TGridEhHelper.SetGridColumnPickList(DBGridEh1: TDBGridEh; AFielDName: string; APickList: TVarDynArray; AKeyList: TVarDynArray; ALimitTextToListValues: Boolean = False);
//устанавливает выпадающий список для стошлбца, найденного по имени поля
//передается список значений, список ключей (в одномерных вариант массивах), и признак возможности выбрать только из списка
//список ключей может быть пустой и тогда не устанавливается
var
  i: Integer;
begin
  Gh.GetGridColumn(DBGridEh1, AFielDName).PickList.Clear;
  Gh.GetGridColumn(DBGridEh1, AFielDName).KeyList.Clear;
  for i := 0 to High(APickList) do begin
    Gh.GetGridColumn(DBGridEh1, AFielDName).PickList.Add(S.NSt(APickList[i]));
    if Length(AKeyList) = Length(APickList) then
      Gh.GetGridColumn(DBGridEh1, AFielDName).KeyList.Add(S.NSt(AKeyList[i]));
  end;
  Gh.GetGridColumn(DBGridEh1, AFielDName).LimitTextToListValues := True;
end;

procedure TGridEhHelper.SetGridColumnPickList(DBGridEh1: TDBGridEh; AFielDName: string; APickKeyList: TVarDynArray2; APickPos: Integer = 0; AKeyPos: Integer = 1; ALimitTextToListValues: Boolean = False);
//устанавливает выпадающий список для стошлбца, найденного по имени поля
//передается список значений, список ключей (в двухмерном массиве, переадются номера столбцов для значения и ключа), и признак возможности выбрать только из списка
var
  i: Integer;
begin
  gh.GetGridColumn(DBGridEh1, AFielDName).PickList.Clear;
  Gh.GetGridColumn(DBGridEh1, AFielDName).KeyList.Clear;
  for i := 0 to High(APickKeyList) do begin
    Gh.GetGridColumn(DBGridEh1, AFielDName).PickList.Add(S.NSt(APickKeyList[i, APickPos]));
    Gh.GetGridColumn(DBGridEh1, AFielDName).KeyList.Add(S.NSt(APickKeyList[i, AKeyPos]));
  end;
  Gh.GetGridColumn(DBGridEh1, AFielDName).LimitTextToListValues := True;
end;


//------------------- опции всего грида ----------------------------------------

procedure TGridEhHelper.SetGridOptionsDefault(DBGridEh: TDBGridEh; Excl: TmyDbEhSet = []);
//устанавливем дефолтные свойства грида
var
  st: string;
  i, mode, iii: Integer;
  b: Boolean;
begin
//excl:=excl+[mygsColors];
  if True then begin
  //разрешаем изменение данных в гриде
    DBGridEh.AllowedOperations := [alopInsertEh, alopUpdateEh, alopDeleteEh, alopAppendEh];
  end;
  if not (mygsStyle in Excl) then begin
    //3D-стиль грида
    DBGridEh.OptionsEh := DBGridEh.OptionsEh + [dghFixed3D, dghFrozen3D, dghFooter3D, dghData3D];
    //параметры заголовков
    DBGridEh.TitleParams.BorderInFillStyle := False; //True;
    DBGridEh.TitleParams.FillStyle := cfstGradientEh;
    DBGridEh.TitleParams.MultiTitle := True;
    if not (mygsStyle in Excl) and not (mygsColors in Excl) then begin
      if module.StyleName = '' then
        DBGridEh.TitleParams.SecondColor := clSkyBlue;
      DBGridEh.TitleParams.Color := clWindow;
    end;
    //
    DBGridEh.OptionsEh := DBGridEh.OptionsEh + [dghResizeWholeRightPart];
  //  DBGridEh.OptionsEh:=DBGridEh.OptionsEh+[dghAutoSortMarking];
    //сортировка по нескольким столбцам
    DBGridEh.OptionsEh := DBGridEh.OptionsEh + [dghMultisortMarking];
    //перемещение по Энтер по гриду
    DBGridEh.OptionsEh := DBGridEh.OptionsEh + [dghEnterAsTab];
    //Подсветка всей строки
    DBGridEh.OptionsEh := DBGridEh.OptionsEh + [dghRowHighlight];
    //подсветка строки, над которой находится курсор
    DBGridEh.OptionsEh := DBGridEh.OptionsEh + [dghHotTrack];
    //Показать номер записи в гиде
    DBGridEh.OptionsEh := DBGridEh.OptionsEh + [dghShowRecNo];
    //Заголовки в виде кнопок
    DBGridEh.ColumnDefValues.Title.TitleButton := True;
  //  DBGridEh.IndicatorOptions:=[gioShowRowIndicatorEh,gioShowRecNoEh,gioShowRowselCheckboxesEh];
    DBGridEh.IndicatorOptions := [gioShowRowIndicatorEh, gioShowRecNoEh];
    DBGridEh.ShowHint := True;
    {Column.ToolTips
    Column.Title.ToolTips
    Column.Title.Hint}
    DBGridEh.ColumnDefValues.ToolTips := True;
    DBGridEh.ColumnDefValues.Title.ToolTips := True;

    DBGridEh.EmptyDataInfo.Active := True;
    DBGridEhEmptyDataInfoText := 'Записи отсутствуют';
    //подсветка строки целиком
    DBGridEh.Options := DBGridEh.Options - [dgRowSelect];
    //выделение фокуса рамкой
    DBGridEhDefaultStyle.IsDrawFocusRect := False;
  end;
  //цвета клиентской части гридда
  if module.StyleName = '' then
    if not (mygsStyle in Excl) and not (mygsColors in Excl) then begin
      DBGridEh.EvenRowColor := clWindow;
      DBGridEh.OddRowColor := clCream;
    end;
  //локальная сортировка и фильтрация
  if not (mygsSortFilterLocal in Excl) then begin
    DBGridEh.SortLocal := True;
  end;
  DBGridEh.STFilter.Location := stflInTitleFilterEh;

//  Settings.RestoreGridSettings(Section,'',DBGridEh);
//  RestoreGridLayoutIni(DBGridEh, IniFileName, Section, [grpColIndexEh,grpColWidthsEh,grpSortMarkerEh,grpColVisibleEh,grpDropDownRowsEh,grpDropDownWidthEh,grpRowPanelColPlacementEh]);
//  end;
{
    DBGridEh.OptionsEh:=DBGridEh.OptionsEh+[dghAutoFitRowHeight];
    DBGridEh.OptionsEh:=DBGridEh.OptionsEh+[dghHotTrack];

//  DBGridEh.ColumnDefValues.Title.

//  TDBGridEh.SearchPanel.FilterEnabled:=True;
//  TDBGridEh.SearchPanel.PersistentShowing:=True;
//  TDBGridEh.SearchPanel.FilterEnabled:=True;


//  TDBGridEh.STFilter.Visible в True
//  STFilter.Location в stflInTitleFilterEh



TColumnEh.Width, Используйте свойства TColumnEh.MaxWidth и TColumnEh.MinWidth



  //требовать непустую запись при редактировании
  DBGridEh.ColumnDefValues.HighlightRequired:=True;
  //TColumnEh.HighlightRequired,

  DBGridEh.Options:=DBGridEh.Options+[dgConfirmDelete, dgIndicator];

  //DBGridEh.SearchPanel.Enabled:=False;

  //-------------------------------------
  //параметры поведения
  DBGridEh.SortLocal:=True;

  //постоянные параметры внешнего вида

  //подсветка строки целиком
  DBGridEh.Options:=DBGridEh.Options-[dgRowSelect];
  //выделение фокуса рамкой
  DBGridEhDefaultStyle.IsDrawFocusRect := False;


  //цвета
  DBGridEh.EvenRowColor:=clWindow;
  DBGridEh.OddRowColor:=clCream;

//  TDBGridEh.Color и TDBGridEh.FixedColor
//  TColumnEh.Color
//  Чтобы вернуть столбец в состояние, когда он использует цвет TDBGridEh.Color, необходимо убрать значение cvColor из свойства TColumnEh.AssignedValues


  DBGridEh.Font.Size:=8;

  //параметры заголовков
  DBGridEh.TitleParams.BorderInFillStyle:=False;//True;
  DBGridEh.TitleParams.FillStyle:=cfstGradientEh;
  DBGridEh.TitleParams.MultiTitle:=True;
  DBGridEh.TitleParams.SecondColor:=clSkyBlue;
  DBGridEh.TitleParams.Color:=clWindow;
  //параметры столбцов
  for i:=0 to DBGridEh.Columns.Count-1 do
    begin
      DBGridEh.Columns[i].Visible:=MemTableEh1.FieldByName('visible').value;
      DBGridEh.Columns[i].WordWrap:=MemTableEh1.FieldByName('wordwrap').value;
      DBGridEh.Columns[i].AutoFitColWidth:=MemTableEh1.FieldByName('autofit').value;
      MemTableEh1.Next;
    end;
  MemTableEh1.Active:=False;
  //панель поиска/фильтра видна
  b:=chb_FilterPanel.Checked or chb_SearchPanel.Checked;
  DBGridEh.SearchPanel.Enabled := b;
  //панель поиска фильтрует грид, иначе поиск+отображание вхождений в гриде
  DBGridEh.SearchPanel.FilterOnTyping := chb_FilterPanel.Checked;
  //выпадающий фильтр в стобцах
  b:=chb_STFilter.Checked;
  DBGridEh.STFilter.Visible:=b;
  if b then begin
    //локальная фильтрация
    DBGridEh.STFilter.Local:=True;
    //фильтр в заголовке строки (иначе под заголовком)
    DBGridEh.STFilter.Location:=stflInTitleFilterEh;
    //!!! не понял пока за что ттвечает
    DBGridEh.STFilter.InstantApply:=False;
  end;
  //сортировка по клику на колонке
  b:=chb_Sorting.checked;
  if b
    then begin
      DBGridEh.OptionsEh:=DBGridEh.OptionsEh+[dghAutoSortMarking, dghMultiSortMarking];
    end
    else begin
      //отменяем возможность сортировки (здесь надо пройти еще по колонкам и убрать стрелочки сортировки, если где-то были)
      DBGridEh.OptionsEh:=DBGridEh.OptionsEh-[dghAutoSortMarking, dghMultiSortMarking];
    end;
  //автоподгонка высоты строк
  b:=chb_AutoHeight.Checked;
  if b
    then begin
      DBGridEh.OptionsEh:=DBGridEh.OptionsEh+[dghAutoFitRowHeight];
      //нужно только при изменении некоторых свойств, например шрифта грида
      //DBGridEh.UpdateAllDataRowHeights;
    end
    else begin
      DBGridEh.OptionsEh:=DBGridEh.OptionsEh-[dghAutoFitRowHeight];
    end;
  //перемещение столбцов
  DBGridEh.OptionsEh:=DBGridEh.OptionsEh+[dghColumnMove];
  //изменение ширины столбцов
  DBGridEh.OptionsEh:=DBGridEh.OptionsEh+[dghColumnResize];
  //автоподгонка ширины столбцов чтобы они занимали всю ширину видимой области грида, а не выходили за пределы видимой области
  b:=chb_AutoWidth.Checked;
  DBGridEh.AutoFitColWidths:=b;
  //автоподгонка ширины столбцовюю
  //TDBGridEh.MinAutoFitWidth     //минимальная ширина грилда, при которой происходит подгонка
  //TColumnEh.AutoFitColWidth     //использовать этот столбец для подгонки
  //Оптимизирует ширину столбцов так, чтобы весь текст был виден внутри ячейки (количество строк для анализа, макс время работы)
  if b then DBGridEh.OptimizeAllColsWidth(-1, 2);
end;
}
end;

procedure TGridEhHelper.SetGridOptionsMain(DBGridEh: TDBGridEh; Filter: Boolean = True; STFilter: Boolean = True; Sort: Boolean = True);
//устанавливает основные опции кастомизации грида (фильтр, стфильтр, сортировка
begin
  DBGridEh.SearchPanel.Enabled := Filter;
  //панель поиска фильтрует грид, иначе поиск+отображание вхождений в гриде
  DBGridEh.SearchPanel.FilterOnTyping := Filter;
  //выпадающий фильтр в стобцах
  DBGridEh.STFilter.Visible := STFilter;
  if STFilter then begin
    //локальная фильтрация
    DBGridEh.STFilter.local := True;
    //фильтр в заголовке строки (иначе под заголовком)
    DBGridEh.STFilter.Location := stflInTitleFilterEh;
    //!!! не понял пока за что ттвечает
    DBGridEh.STFilter.InstantApply := False;
  end;
  //сортировка по клику на колонке
  if Sort then begin
    DBGridEh.OptionsEh := DBGridEh.OptionsEh + [dghAutoSortMarking, dghMultiSortMarking];
  end
  else begin
      //отменяем возможность сортировки (здесь надо пройти еще по колонкам и убрать стрелочки сортировки, если где-то были)
    DBGridEh.OptionsEh := DBGridEh.OptionsEh - [dghAutoSortMarking, dghMultiSortMarking];
  end;
end;

procedure TGridEhHelper.SetGridOptionsTitleAppearance(DBGridEh1: TDBGridEh; Gradient: Boolean = True);
//установить внешний вид заголовка (градиент по стандартным цветам или серый)
begin
  if Gradient then begin
    DBGridEh1.TitleParams.FillStyle := cfstGradientEh;
    DBGridEh1.TitleParams.SecondColor := clSkyBlue;
    DBGridEh1.TitleParams.Color := clWindow;
  end
  else begin
    DBGridEh1.TitleParams.FillStyle := cfstSolidEh;
    DBGridEh1.TitleParams.Color := clBtnFace;
  end;
end;

function TGridEhHelper.GridFilterInColumnUsed(DbGridEh1: TDbGridEh): Boolean;
//проверяет, используется ли в гриде фильтр в столбцах
var
  i: Integer;
begin
  Result := False;
  for i := 0 to DbGridEh1.Columns.Count - 1 do begin
    Result := DbGridEh1.Columns[i].STFilter.ExpressionStr <> '';
    if Result then
      Break;
  end;
end;

function TGridEhHelper.GridFilterSave(DbGridEh1: TDbGridEh): TVarDynArray2;
//сохраняет в массиве значения фильтра в строке и в столбцах
var
  i, j: Integer;
begin
  Result := [['#stfilter', DbGridEh1.SearchPanel.SearchingText]];
  for i := 0 to DbGridEh1.Columns.Count - 1 do begin
    Result := Result + [[LowerCase(DbGridEh1.Columns[i].FieldName), DbGridEh1.Columns[i].STFilter.ExpressionStr]];
  end;
end;

procedure TGridEhHelper.GridFilterClear(DbGridEh1: TDbGridEh; ColumnFilter: Boolean = True; StFilter: Boolean = True);
//очищает фильтр в столбцах и в строке (опции ColumnFilter и StFilter)
var
  i, j: Integer;
begin
  DbGridEh1.Datasource.DataSet.DisableControls;
  if StFilter then
    if DbGridEh1.SearchPanel.SearchingText <> '' then begin
      DbGridEh1.SearchPanel.SearchingText := '';
      DbGridEh1.SearchPanel.ApplySearchFilter;
    end;
  if ColumnFilter then
    for i := 0 to DbGridEh1.Columns.Count - 1 do begin
      DbGridEh1.Columns[i].StFilter.ExpressionStr := ''
    end;
  DbGridEh1.Datasource.DataSet.EnableControls;
  DbGridEh1.DefaultApplyFilter;
end;

procedure TGridEhHelper.GridFilterRestore(DbGridEh1: TDbGridEh; FilterArr: TVarDynArray2; ColumnFilter: Boolean = True; StFilter: Boolean = True);
//восстанавливает фильтр в столбцах и в строке из сохранения
var
  i, j: Integer;
begin
  if Length(FilterArr) < 1 then
    Exit;
  if ColumnFilter then
    for i := 0 to DbGridEh1.Columns.Count - 1 do begin
      j := A.PosInArray(LowerCase(DbGridEh1.Columns[i].FieldName), FilterArr);
      if j >= 0 then
        DbGridEh1.Columns[i].StFilter.ExpressionStr := FilterArr[j][1];
    end;
  DbGridEh1.DefaultApplyFilter;
  if StFilter then begin
    DbGridEh1.SearchPanel.SearchingText := FilterArr[0][1];
    DbGridEh1.SearchPanel.ApplySearchFilter;
  end;
end;

procedure TGridEhHelper.GridDateFilterModify(Sender: TCustomDBGridEh; Column: TColumnEh; Items: TStrings; var Processed: Boolean; FieldNames: TVarDynArray);
//инвертирует порядок дат в выподающем фильтре по дате
//++ перенести строку Пустые наверх
var
  i, j, k: Integer;
begin
  for i := 0 to High(FieldNames) do
    FieldNames[i] := S.ChangeCaseStr(FieldNames[i], True);
  if not A.InArray(Column.FieldName, FieldNames) then
    Exit;
  Sender.DefaultFillSTFilterListValues(Column, Items);
  i := Items.Count;
  for j := 1 to i do begin
    Items.InsertObject(Items.Count - j + 1, Items[0], PopupListboxItemEhData);
    Items.Delete(0);
  end;
  k := 0;
  for j := 0 to i - 1 do
    if Items[j] = DateToStr(Date) then begin
      k := j;
      Break;
    end;
  if k > 0 then
    Items.InsertObject(0, DateToStr(Date), PopupListboxItemEhData);
  //Items.InsertObject(0, 'Сегодня', PopupListboxItemEhData);
  //Items.InsertObject(0, '', PopupListboxItemEhNotEmties);
  Processed := True;
end;

procedure TGridEhHelper.SetGridIndicatorSelection(DbGridEh1: TDbGridEh; Mode: Integer);//
//ставит/снимает/инвертирует (1/-1/0) отметку ВИДИМЫХ строк в гриде (будут отмечены чекбоксы в индикаторном столбце)
var
  rn: Integer;
begin
  try
  if DbGridEh1.Datasource.DataSet.RecordCount = 0 then
    Exit;
  rn := DbGridEh1.Datasource.DataSet.RecNo;
  DbGridEh1.Datasource.DataSet.DisableControls;
  if Mode = 1 then begin
    //отметим все ОТФИЛЬТРОВАННЫЕ строки, скрытые не трогаем
    with DbGridEh1.Datasource.DataSet do begin
      First;
      while not eof do begin
        if not DbGridEh1.SelectedRows.CurrentRowSelected then
          DbGridEh1.SelectedRows.CurrentRowSelected := True;
        Next;
      end;
    end;
  end
  else if Mode = -1 then begin
//    DBGridEh1.SelectedRows.Clear; //это снимет отметку не только на отфильтрованных, но и на всех строках
    with DbGridEh1.Datasource.DataSet do begin
      First;
      while not eof do begin
        if DbGridEh1.SelectedRows.CurrentRowSelected then
          DbGridEh1.SelectedRows.CurrentRowSelected := False;
        Next;
      end;
    end;
  end
  else if Mode = 0 then begin
    with DbGridEh1.Datasource.DataSet do begin
      First;
      while not eof do begin
        DbGridEh1.SelectedRows.CurrentRowSelected := not DbGridEh1.SelectedRows.CurrentRowSelected;
        Next;
      end;
    end;
  end;
  except
  end;
  DbGridEh1.Datasource.DataSet.RecNo := rn;
  DbGridEh1.Datasource.DataSet.EnableControls;
end;

function TGridEhHelper.GetGridArrayOfChecked(DbGridEh1: TDbGridEh; FieldNo: Integer): TVarDynArray2;
//вернем двумерный массив всех отмеченных чекбоксами строк грида
//если задан FieldNo >= 0, то по этому полю, иначе все поля данных
var
  st: string;
  i, j: Integer;
  rn: Integer;
begin
  Result := [];
  DbGridEh1.Datasource.DataSet.DisableControls;
  rn := TMemTableEh(DbGridEh1.Datasource.DataSet).RecNo;
  //фильтр в толбцах не мешает, и собираются и те строки которые не видны, но!!! при включенном фильтре ПАНЕЛИ происходит ошика
  //сбросим фильтр в панели если есть
  st := DbGridEh1.SearchPanel.SearchingText;
  if st <> '' then begin
    DbGridEh1.SearchPanel.SearchingText := '';
    DbGridEh1.SearchPanel.ApplySearchFilter;
  end;
  //соберем все отмеченные записи, независимо от фильтрации
  for i := 0 to DbGridEh1.SelectedRows.Count - 1 do begin
    if not DbGridEh1.DataSource.DataSet.BookmarkValid(DbGridEh1.SelectedRows[i]) then
      Continue;
    try
      DbGridEh1.DataSource.DataSet.Bookmark := DbGridEh1.SelectedRows[i];          //ошибка при фильтре здесь, BookmarkValid не помогает
      SetLength(Result, Length(Result) + 1);
      if FieldNo >= 0 then begin
        Result[i] := [DbGridEh1.DataSource.DataSet.Fields[j].AsVariant];
      end
      else begin
        SetLength(Result[i], DbGridEh1.DataSource.DataSet.Fields.Count);
        for j := 0 to DbGridEh1.DataSource.DataSet.Fields.Count - 1 do
          Result[i][j] := DbGridEh1.DataSource.DataSet.Fields[j].AsVariant;
      end;
    except
    end;
  end;
  if st <> '' then begin
    DbGridEh1.SearchPanel.SearchingText := st;
    DbGridEh1.SearchPanel.ApplySearchFilter;
  end;
  TMemTableEh(DbGridEh1.Datasource.DataSet).RecNo := rn;
  DbGridEh1.Datasource.DataSet.EnableControls;
end;

function TGridEhHelper.GetGridInfoStr(DbGridEh1: TDbGridEh): string; //
//вернем тектовую инфу о количестве записей в гриде (всего, выделено, отфильтровано)
var
  st: string;
  q, qm, qma, qmas: Integer;
begin
  //Чтобы пройтись по отфильтрованному списку записей используете список MemTableEh1.RecordsView
  //Чтобы пройтись по полному списку записей используйте список MemTableEh1.RecordsView.MemTableData.RecordsList
  Result := '';
  if not TMemTableEh(DbGridEh1.Datasource.DataSet).Active then
    Exit;
  qm := TMemTableEh(DbGridEh1.Datasource.DataSet).RecordCount;
  qma := TMemTableEh(DbGridEh1.Datasource.DataSet).RecordsView.MemTableData.RecordsList.Count;
  qmas := DbGridEh1.SelectedRows.Count;
  Result := IntToStr(qm) + ' запис' + S.GetEnding(qm, 'ь', 'и', 'ей') + '' + S.IIFStr(qma > qm, ' из ' + IntToStr(qma) + '', '') + S.IIf(qmas > 0, ' (отмечено ' + IntToStr(qmas) + ')', '') + '';
end;

procedure TGridEhHelper.RootGroupExpandCollapse(DBGridEh: TDBGridEh; AExpand: Integer = 0);
//для режима DBGridEh.DataGrouping раскроем/схлопнем рекурсивно корневую группу,
//на которой (или на дочерней записи в пределах которой) находится курсор
//AExpand: -1 - схопнуть, 1 - раскрыть, 0 - инвертировать
var
  i, j: Integer;
  st, st1 : string;
  Expand: Boolean;
  procedure ProcessNode(Node: TGroupDataTreeNodeEh);
  var
    j: Integer;
  begin
    Node.Expanded := Expand;
    for j := 0 to Node.Count - 1 do
      ProcessNode(Node[j]);
  end;
begin
  if not DBGridEh.DataGrouping.Active then
    Exit;
  //получим значение поля, соотвествующего корневой группе, в текущей записи
  st := DBGridEh.DataSource.DataSet.FieldByName(TColumnEh(DBGridEh.DataGrouping.GroupLevels[0].Column).FieldName).AsString;
  //пройдем по всем корневым нодам
  for i := 0 to DBGridEh.DataGrouping.GroupDataTree.Root.count - 1 do begin
    //получим для ноды номер записи в мемтейбле, начиная с 0, это будет номер ее первой строки - не группы
    j := DBGridEh.DataGrouping.GroupDataTree.Root[i].DataSetRecordViewNo;
//    j := DBGridEh.DataGrouping.GroupDataTree.FlatVisibleItem[i].DataSetRecordViewNo;
    //если значение ключевого поля для этой строки совпадает со значением его в текеущей строке, то расхлопнем группу рекурсивно
    st1 := TMemTableEh(DBGridEh.DataSource.DataSet).RecordsView[j].DataValues[TColumnEh(DBGridEh.DataGrouping.GroupLevels[0].Column).FieldName, dvvValueEh];
    if st = st1 then begin
      //полуучим режим (схлопнуть/расхлопнуть)
      Expand := S.Decode([AExpand, -1, False, 1, True, not DBGridEh.DataGrouping.GroupDataTree.Root[i].Expanded]);
      TMemTableEh(DBGridEh.DataSource.DataSet).DisableControls;
      //рекурсивно применим ко всем дочерним нодам
      ProcessNode(DBGridEh.DataGrouping.GroupDataTree.Root[i]);
      TMemTableEh(DBGridEh.DataSource.DataSet).EnableControls;
      Exit;
    end;
  end;
end;

procedure TGridEhHelper.AllGroupsExpandCollapse(DBGridEh: TDBGridEh; Level: Integer = 0; Expand: Boolean = True);
//для режима DBGridEh.DataGrouping раскроем/схлопнем все группы
//если Level < 0 то только для групп данного уровня
//иначе раскроем начиная с корневого уровня и до указанного
var
  i, j: Integer;
begin
  if not DBGridEh.DataGrouping.Active then
    Exit;
  if Level < 0 then begin
    if Expand
      then DBGridEh.DataGrouping.GroupLevels[-Level].ExpandNodes
      else DBGridEh.DataGrouping.GroupLevels[-Level].CollapseNodes;
    Exit;
  end;
  TMemTableEh(DBGridEh.DataSource.DataSet).DisableControls;
  for i := 0 to Min(Level, DBGridEh.DataGrouping.GroupLevels.Count - 1) do
    if Expand
      then DBGridEh.DataGrouping.GroupLevels[i].ExpandNodes
      else DBGridEh.DataGrouping.GroupLevels[i].CollapseNodes;
  TMemTableEh(DBGridEh.DataSource.DataSet).EnableControls;
end;


procedure TGridEhHelper.GridRefresh(DBGridEh: TDbGridEh; Grayed: Boolean = False);
//обновление грида с применением сортировки и фильтра
var
  KeyString: string;
begin
  if Grayed then
    DBGridEh.StartLoadingStatus(GLoadingCaption, GLoadingBlackout);
  KeyString := GetGridServiceFields(DBGridEh);
  if KeyString <> '' then
    DBGridEh.SaveVertPos(KeyString);
  TMemTableEh(DBGridEh.DataSource.DataSet).Refresh;
  DBGridEh.DefaultApplySorting;
  DBGridEh.DefaultApplyFilter;
  if KeyString <> '' then
    DBGridEh.RestoreVertPos(KeyString);
  if Grayed then
    DBGridEh.FinishLoadingStatus(GLoadingBlackout);
end;

procedure TGridEhHelper.DBGridEhAdvDrawDataCellDefault(Sender: TCustomDBGridEh;
  Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
  var Params: TColCellParamsEh; var Processed: Boolean);
begin
  if (not Column.ReadOnly) then begin
    Sender.DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
    if True then
    with Sender.Canvas, ARect do begin
      Pen.Color := Rgb(150, 255, 150);
      Pen.Style := psSolid;
      MoveTo(Left + 1, Top);
      LineTo(Left + 1, Bottom);
      MoveTo(Left + 2, Top);
      LineTo(Left + 2, Bottom);
      MoveTo(Left + 3, Top);
      LineTo(Left + 3, Bottom);
      //MoveTo(Left + 4, Top);
      //LineTo(Left + 4, Bottom);
    end;
    Processed := True;
{    if (Pr[GridNo]._CurrFieldEditable)and
       (LowerCase(Column.FieldName) = Pr[GridNo]._FieldNameCurr)and
       (MemTables[GridNo].FieldByName(Pr[GridNo].IdField).Value = S.IIf(GridNo = 1, id, id2)) then begin}
    if (not TDbGridEh(Sender).ReadOnly)and(not Column.ReadOnly)and
       (Column.Index = TDbGridEh(Sender).Col - 1)and
       (TMemTableEh(TDbGridEh(Sender).DataSource.DataSet).RecNo = TDbGridEh(Sender).Row)
      then begin
      if True then
      with Sender.Canvas, ARect do begin
        Pen.Color := Rgb(150, 255, 150);
        Pen.Style := psSolid;
        MoveTo(Left, Bottom);
        LineTo(Right, Bottom);
        MoveTo(Left, Bottom - 1);
        LineTo(Right, Bottom - 1);
        MoveTo(Left, Bottom + 1);
        LineTo(Right, Bottom + 1);
  //      MoveTo(Left, Bottom-2);
  //      LineTo(Right, Bottom-2);
      end;
      Processed := True;
    end
  end;
end;


procedure TGridEhHelper.ExportGridToXlsxNew(DBGridEh1: TDBGridEh; FileName: string; AutoOpen: Boolean; Header: string = ''; Footer: string = ''; FontFormat: Boolean = False; CreateAutoFilter: Boolean = False);
//экспортирует грид в формат Excel, использую встроенные средства EhLib
var
  ExportOptions: TDBGridEhXlsMemFileExportOptions;
begin
  if FileName = '' then
    Exit;
  ExportOptions := TDBGridEhXlsMemFileExportOptions.Create;
//  ExportOptions.IsExportAll := True;
  ExportOptions.IsExportTitle := True;
  ExportOptions.IsExportFooter := True;
  ExportOptions.IsExportFontFormat := FontFormat;
  ExportOptions.IsExportFillColor := False;
  ExportOptions.IsCreateAutoFilter := CreateAutoFilter;
  ExportOptions.IsExportFreezeZones := True;
  ExportOptions.IsFooterSumsAsFormula := True;
  ExportOptions.IsExportDisplayFormat := True;
  ExportOptions.IsExportDataGrouping := True;
  ExportOptions.SheetName := 'Лист1';
  ExportOptions.GridHeaderText := Header;
  ExportOptions.GridHeaderFont := DBGridEh1.Font;
  ExportOptions.GridHeaderFont.Size := 12;
  ExportOptions.GridFooterText := Footer;
  DBGridEhImpExp.ExportDBGridEhToXlsx(DBGridEh1, FileName, ExportOptions);
  ExportOptions.Free;
  if AutoOpen then
    ShellExecute(Application.Handle, nil, PChar(FileName), nil, nil, SW_SHOWNORMAL);
end;



//================= END TGridHelper ============================================




//==============================================================================
//  TControlsHelper
//==============================================================================
procedure TControlsHelper.SetControlValue(f: TObject; c: string; v: Variant);
begin
  if TForm(f).FindComponent(c) <> nil then
    SetControlValue(TControl(TForm(f).FindComponent(c)), v);
end;


procedure TControlsHelper.SetControlValue(c: TControl; v: Variant);
//установим значения контролов из переменной вариант
begin
  if c = nil then
    Exit;
  if c is TDbCheckBoxEh then begin
    TDbCheckBoxEh(c).Checked := (v = 1) or (v = True);
  end
  else if c is TDbEditEh then begin
    TDbEditEh(c).Value := v;
  end
  else if c is TDBDateTimeEditEh then begin
      //если вариант не является валидной датой, поставим пустое значение
//      TDBDateTimeEditEh(c).Kind=dtkDateEh
      //v='10.11.23 12:06';
    if v = null then
      TDBDateTimeEditEh(c).Value := null
    else if S.IsNumber(v, 0, 9999999999999999) then
      TDBDateTimeEditEh(c).Value := v
    else if S.IsDateTime(v, 'dt') then
      TDBDateTimeEditEh(c).Value := v
    else
      TDBDateTimeEditEh(c).Value := null;
  end
  else if c is TDBNumberEditEh then begin
    if (v <> null) and (S.IsFloat(v)) then
      TDbEditEh(c).Value := v
    else
      TDbEditEh(c).Text := '';
  end
  else if c is TDBComboBoxEh then begin
    TDbComboBoxEh(c).Value := v;
  end
  else if c is TCheckBox then begin
    TCheckBox(c).Checked := (v = 1) or (v = True);
  end
  else if c is TRadioButton then begin
    TRadioButton(c).Checked := (v = 1) or (v = True);
  end
  else if c is TDbMemoEh then begin
    TDbMemoEh(c).Text := VarToStr(v);
  end
  else if c is TMemo then begin
    TMemo(c).Text := VarToStr(v);
  end
  else if c is TLabel then begin
    TLabel(c).Caption := VarToStr(v);
  end;
end;

function TControlsHelper.GetControlValue(c: TObject): Variant;
//вазвращаем значения из DBEhCtrls
begin
  if c is TDbCheckBoxEh then begin
      //для чекбокса вернем 1 для установленного и 0 если не установлен
    if TDbCheckBoxEh(c).Checked then
      Result := 1
    else
      Result := 0;
  end
  else if c is TDbEditEh then begin
    Result := TDbEditEh(c).Value;
  end
  else if c is TDBDateTimeEditEh then begin
    Result := TDBDateTimeEditEh(c).Value;
    if Result = null then
      Result := '';
  end
  else if c is TDBNumberEditEh then begin
    Result := TDbNumberEditEh(c).Value;
  end
  else if c is TDBMemoEh then begin
    Result := TDbMemoEh(c).Text;
  end
  else if c is TMemo then begin
    Result := TMemo(c).Text;
  end
  else if c is TDBComboBoxEh then begin
      //для комбобокса это будет значение, если не заданые KeyItems, иначе ключ
    Result := TDbComboBoxEh(c).Value;
  end;
end;

function TControlsHelper.GetControlValue(AOwner: TComponent; CName: string): Variant;
//вазвращаем значения из DBEhCtrls
begin
  Result := GetControlValue(TControl(AOwner.FindComponent(CName)));
end;


function TControlsHelper.CreateControls(AParent: TWinControl; CType: TMyControlType; CLabel: string = ''; CName: string = ''; CVerify: string = ''; Tag: Integer = 0; Left: Integer = 0; Top: Integer = 0): TControl;
//создает контролы
var
  FSelf: TComponent;
  c: TVarDynArray;
  i, j, h, l, w: Integer;
  st: string;
  ver: TVarDynArray;
  cnt: TControl;

{  cntEdit = 1;
  cntNEdit = 2;
  cntDEdit = 3;
  cntTEdit = 4;
  cntDTEdit = 5;
  cntCheck = 6;
  cntCheck3 = 7;          //checkbox с опцией greed
  cntComboL = 8;          //комбобокс - список
  cntComboLK = 9;         //комбобокс - список с ключами
  cntComboE = 10;         //комбобокс - эдит
  cntComboEK = 11;        //комбобокс - эдит с ключами
  cntComboL0 = 12;        //с добавленной пустой строкой в лист
  cntComboLK0 = 13;}
begin
  if (AParent is TForm)or(AParent is TFrame)
    then FSelf := TComponent(AParent)
    else FSelf := AParent.Owner;
  ver := A.ExplodeV(S.IIFStr(CVerify = '', ':::::::::', CVerify + ':::::::::'), ':');
  if CType = cntBevel then begin
    Result := TBevel.Create(FSelf);
    Result.Parent := AParent;
    Result.Height:=2;
    if CName <> '' then
      Result.Name := CName;
    Exit;
  end;
  if CType = cntLabel then begin
    Result := TLabel.Create(FSelf);
    Result.Parent := AParent;
    if CName <> '' then
      Result.Name := CName;
    if CLabel <> '' then
      TLabel(Result).Caption := CLabel;
    Exit;
  end;
  if CType = cntLabelClr then begin
    Result := TLabelClr.Create(FSelf);
    Result.Parent := AParent;
    if CName <> '' then
      Result.Name := CName;
    if CLabel <> '' then
      TLabelClr(Result).SetCaption2(CLabel);
    Exit;
  end;
  if CType = cntEdit then begin
    Result := TDbEditEh.Create(FSelf);
    TDbEditEh(Result).MaxLength := StrToIntDef(ver[1], DefEditMaxLength);
    if pos('U', S.ChangeCaseStr(ver[3], True)) > 0 then
      TDbEditEh(Result).CharCase := ecUpperCase;
    if pos('L', S.ChangeCaseStr(ver[3], True)) > 0 then
      TDbEditEh(Result).CharCase := ecLowerCase;
  end;
  if A.InArray(CType, [cntNEdit, cntNEditC, cntNEditS]) then begin
    Result := TDbNumberEditEh.Create(FSelf);
    TDbNumberEditEh(Result).MinValue := StrToIntDef(ver[0], 0);
    TDbNumberEditEh(Result).MaxValue := StrToIntDef(ver[1], 999999999999);
    TDbNumberEditEh(Result).DecimalPlaces := StrToIntDef(ver[2], 0);
    if CType = cntNEditC then begin
      TDbNumberEditEh(Result).EditButton.Visible := True;
      TDbNumberEditEh(Result).EditButton.DefaultAction := True;
      TDbNumberEditEh(Result).EditButton.Style := ebsEllipsisEh;
    end;
    if CType = cntNEditS then begin
      TDbNumberEditEh(Result).EditButton.Visible := True;
      TDbNumberEditEh(Result).EditButton.DefaultAction := True;
      TDbNumberEditEh(Result).EditButton.Style := ebsUpDownEh;
    end;
  end;
  if CType = cntDEdit then begin
    Result := TDbDateTimeEditEh.Create(FSelf);
  end;
  if CType = cntTEdit then begin
    Result := TDbDateTimeEditEh.Create(FSelf);
  end;
  if CType = cntDTEdit then begin
    Result := TDbDateTimeEditEh.Create(FSelf);
  end;
  if A.InArray(CType, [cntComboL, cntComboLK, cntComboL0, cntComboE, cntComboEK, cntComboLK0]) then begin
    Result := TDbComboBoxEh.Create(FSelf);
    TDbComboboxEh(Result).MaxLength := StrToIntDef(ver[1], DefEditMaxLength);
    if A.InArray(CType, [cntComboL, cntComboLK, cntComboL0, cntComboLK0]) then begin
      TDbComboBoxEh(Result).LimitTextToListValues := True;
    end;
    if pos('U', S.ChangeCaseStr(ver[3], True)) > 0 then
      TDbComboboxEh(Result).CharCase := ecUpperCase;
    if pos('L', S.ChangeCaseStr(ver[3], True)) > 0 then
      TDbComboboxEh(Result).CharCase := ecLowerCase;
  end;
  if CType = cntCheck then begin
    Result := TDbCheckBoxEh.Create(FSelf);
  end;
  if CType = cntCheckX then begin
    Result := TDbCheckBoxEh.Create(FSelf);
    TDbCheckBoxEh(Result).Checked := True;
  end;
  Result.Parent := AParent;
  if CName <> '' then
    Result.Name := CName;
  if CLabel <> '' then begin
    if not A.InArray(CType, [cntCheck, cntCheckX, cntCheck3]) then begin
      TDBEditEh(Result).ControlLabel.Visible := True;
      TDbEditEh(Result).ControlLabelLocation.Position := lpLeftCenterEh;
      TDbEditEh(Result).ControlLabel.Caption := CLabel;
 //       TDBEditEh(Fields[i]).ControlLabelLocation.Spacing:= Max(l-TDBDateTimeEditEh(Fields[i]).ControlLabel.Width - 5, 2);
    end
    else
      TDBCheckboxeh(Result).Caption := CLabel;
  end;
  if CVerify <> '' then begin
    TDbEditEh(Result).DynProps.CreateDynVar(dpVerify, CVerify + ':::::::::');
  end;
  Result.Left := Left;
  Result.Top := Top;
end;

function TControlsHelper.VerifyControl(C: TControl; OnInput: Boolean = True): Boolean;
//проверка значения, для проверкки используется маска в динварс
//CVerify - min:max:digits:inult:validchars:invalidcars
//1,2,3 минимальное значение и максимальное и количество дробных знаков для чисел
//  или минимальное и максимальная длина строки
//4 - n - допустимо пустой значение
//4 - i - для комбобокса - значение должно быть в списке
//4 - u/l - для комбо и эдит - вводятся большие или маленькие буквы
//4 - t - трим для строки, только если не OnInput
//5 - инвалидные символы
//6 - валидные символы
//1 для даты, если =1 то недопустимо пустое значение
//function VerifyControl(C: TControl; OnInput: Boolean = True; ManualState: Integer = 0): Boolean;
var
  i, j: Integer;
  v1: string;
  ver: TStringDynArray;
  st, st1, st2, st3: string;
  dte: extended;
begin
  Result := True;
  if not (C is TCustomDBEditEh) then
    Exit;
  v1 := GetDynProp(C, dpVerify);
//  if v1 = '' then
//    Exit;
  ver := A.ExplodeS(v1, ':');
  if ver[0] = '' then begin
    SetErrorMarker(C, False);
    Exit;
  end;
  //!!! 2024-01-15 - убрал строку нен понимаю зачем она, но может повлиять на все проверки
//  if TDBEditEh(c).Text = '' then Result:= (ver[3] <> '');
  if Result then
    if C is TDBNumberEditEh      //намбередит
      //(0): N - требовать непустое значение
      //(0) число - мин значение
      //(1) число - макс макс
      then begin
        //для намберэдит
        //проверка при наборе будет всегда возвращать истину, ту проверяется value, а оно уже при наборе имеет значение с учетом min и maxvalue!!!!
      st := TDBNumberEditEh(C).Text;
      if st = '' then
        Result := (pos('N', S.ChangeCaseStr(ver[3], True)) = 0)
      else
        Result := (TDBNumberEditEh(C).Value <= StrToFloatDef(ver[1], 0)) and (TDBNumberEditEh(C).Value >= StrToFloatDef(ver[0], 0))
    end
    else if C is TDBDateTimeEditEh      //дата
      //(0) * - дата обязательна, не допускается пустое, но произвольная
      //(0) инт  S.DateTimeToIntStr(Date) - нач дата
      //(1) инт  кон. дата
      //(2) если '-' то допустимо пустая дата
      then begin
      if (Length(ver) >= 3) and (ver[2] = '-') and (TDBDateTimeEditEh(C).Value = null) then
        Result := True
      else begin
        if ver[0] = '*' then
          Result := DteValueIsDate(TDBDateTimeEditEh(C))
        else if S.IsInt(ver[0]) then
          Result := (DteValueIsDate(TDBDateTimeEditEh(C))) and (TDBDateTimeEditEh(C).Value >= StrToInt(ver[0]));
        if S.IsInt(ver[1]) then
          Result := Result and (DteValueIsDate(TDBDateTimeEditEh(C))) and (TDBDateTimeEditEh(C).Value <= StrToInt(ver[1]));
      end;
    end
    else if (C is TDBEditEh) or (C is TDBComboboxEh) or (C is TDBMemoEh) then begin
          //дбэдит и дбкомбобокс
      st := TDBEditEh(C).Text;
      st2 := st;
  //        s:=TDBEditEh(c).SelStart;
          //регистр - на самом деле не нужно, так как контролл сам приводит к нужному регистру
      if Pos('U', S.ChangeCaseStr(ver[3], True)) > 0 then
        st2 := S.ChangeCaseStr(st2, True);
      if Pos('L', S.ChangeCaseStr(ver[3], True)) > 0 then
        st2 := S.ChangeCaseStr(st2, False);
          //если не проверка при наборе и Трим, то отсекаем пробелы
      if not (OnInput) then
        if Pos('T', S.ChangeCaseStr(ver[3], True)) > 0 then
          st2 := Trim(st2);
      st3 := ver[7];
          //уберем невалидные символы
      for j := 1 to Length(st3) do
        st2 := StringReplace(st2, st3[j], '', [rfReplaceAll, rfIgnoreCase]);
          //если строка изменена, то обновим значение
      if st2 <> st then
        TDBEditEh(C).Text := st2;
          //длина строки в указанных пределах
      Result := (Length(st2) >= StrToIntDef(ver[0], 1)) and (Length(st2) <= StrToIntDef(ver[1], 1));
          //для комбобокса, если нужно, проверим еще в списке ли ли значение
      if Result and (C is TDBComboboxEh) and (Pos('I', S.ChangeCaseStr(ver[3], True)) > 0) then begin
        Result := (TDBComboboxEh(C).ItemIndex >= 0)
      end;
    end;
  SetErrorMarker(C, not Result);
end;

procedure TControlsHelper.SetErrorMarker(c: TControl; HasError: Boolean);
//устанавливает или снимает в зависимости от HasError динамическую переменную 'error'
//для контрола, чтобы в дальнейшем визуализировать и проверить на ошибки
begin
  SetDynProps(c, [[dpError, '', HasError]]);
end;

function TControlsHelper.VerifyVisualise(F: TForm): Boolean;
//визуализирует ошибочные значения контролов на всей форме, подчеркиванием красной пунктирной линией
var
  i, j, k, h: Integer;
  c: TControl;
  b: Boolean;
  st: string;
  dc: HDC;
  cnv: TCanvas;
  r: TRect;
begin
  Result := True;
  for i := 0 to f.ComponentCount - 1 do begin
    c := TControl(f.Components[i]);
    st := c.name;
    if c.name = 'cmb_id_unit' then
      st := c.name;
    if c is TDBCheckBoxEh then begin
      //для чекбокса отрисуем линию на самой форме под чекбоксом
      b := not TDbCheckboxEh(c).DynProps.VarExists(dpError);
      h := TDbCheckboxEh(c).Height;
//      dc := GetDC(TDbCheckboxEh(c).Handle);
      dc := GetDC(TDbCheckboxEh(c).Parent.Handle);
      cnv := TCanvas.Create;
      cnv.Handle := dc;
      with cnv, ClipRect do begin
        if not b then begin
          cnv.pen.Color := Rgb(254, 0, 0);
          Pen.Style := psDot;
          MoveTo(c.left, c.top + c.height + 1);
          LineTo(c.left + c.width, c.top + c.height + 1);
          MoveTo(c.left, c.top + c.height + 2);
          LineTo(c.left + c.width, c.top + c.height + 2);
        end
        else begin
          //если нет статуса ошибки, сотрем линию
          for j := c.left to c.left + c.width do begin
            pixels[j, c.top + c.height + 1] := clBtnFace;
            pixels[j, c.top + c.height + 2] := clBtnFace;
          end;
        end;
      end;
      Result := Result and b;
    end
    else if c is TDBDateTimeEditEh then begin
      b := not TDBDateTimeEditEh(c).DynProps.VarExists(dpError);
      if (c.name = 'dedt_Otgr') and not b then
        st := c.name;
      if b then
        DotRedLine(c, False)
      else
        DotRedLine(c);
      Result := Result and b;
    end
    else if c is TCustomDBEditEh then begin
      b := not TCustomDbEditEh(c).DynProps.VarExists(dpError);
//          if b
//            then TCustomDbEditEh(c).ControlLabel.Font.Color:=clWindowText
//            else TCustomDBEditEh(c).ControlLabel.Font.Color:=clRed;
      if b then
        DotRedLine(c, False)
      else
        DotRedLine(c);
      Result := Result and b;
    end;
  end;
end;

function TControlsHelper.CreateLabelColors(AParent: TWinControl; ACaptions: TVarDynArray): Integer;
//создает несколько колоризованных лейблов друг под другом; если символ "$" в заголовке не найден, создается просто TLabel
var
  i, j: integer;
  c: TControl;
  b: Boolean;
begin
  j := MY_FORMPRM_V_TOP;
  for i := 0 to High(ACaptions) do begin
    if Pos('$', ACaptions[i]) > 0 then
      c := Cth.CreateControls(AParent, cntLabelClr, ACaptions[i], '', '', 0, MY_FORMPRM_H_EDGES, j)
    else
      c := Cth.CreateControls(AParent, cntLabel, ACaptions[i], '', '', 0, MY_FORMPRM_H_EDGES, j);
    c.Top := j;
    j := j + MY_FORMPRM_V_MARGIN + MY_FORMPRM_LABEL_H;
    b := True;
  end;
  if b then
    Result := j + MY_FORMPRM_V_TOP
  else
    Result := 0;
end;

procedure TControlsHelper.SetEhControlColor(AControl: TControl; Color: TColor);
//задает цвет фона контрола
begin
  if AControl is TDBEditEh then
    TDBEditEh(AControl).Color := Color;
  if AControl is TDBComboBoxEh then
    TDBComboBoxEh(AControl).Color := Color;
  if AControl is TDBNumberEditEh then
    TDBNumberEditEh(AControl).Color := Color;
  if AControl is TDBDateTimeEditEh then
    TDBDateTimeEditEh(AControl).Color := Color;
  if AControl is TDBMemoEh then
    TDBMemoEh(AControl).Color := Color;
end;

procedure TControlsHelper.SetEhControlEditButtonState(AControl: TControl; Visible, Enabled: Boolean);
//показывает/скрывает кнопки в полях ввода
var
  i: Integer;
begin
  if AControl is TDBEditEh then
    for i := 0 to TdbeditEh(AControl).EditButtons.Count - 1 do begin
      TdbeditEh(AControl).EditButtons[i].Visible := Visible;
      TdbeditEh(AControl).EditButtons[i].Enabled := Enabled;
    end;
  if AControl is TDBComboBoxEh then begin
    TDBComboBoxEh(AControl).EditButton.Visible := Visible;
    TDBComboBoxEh(AControl).EditButton.Enabled := Enabled;
    for i := 0 to TDBComboBoxEh(AControl).EditButtons.Count - 1 do begin
      TDBComboBoxEh(AControl).EditButtons[i].Visible := Visible;
      TDBComboBoxEh(AControl).EditButtons[i].Enabled := Enabled;
    end;
  end;
  if AControl is TDBNumberEditEh then begin
    TDBNumberEditEh(AControl).EditButton.Visible := Visible;
    TDBNumberEditEh(AControl).EditButton.Enabled := Enabled;
    for i := 0 to TDBNumberEditEh(AControl).EditButtons.Count - 1 do begin
      TDBNumberEditEh(AControl).EditButtons[i].Visible := Visible;
      TDBNumberEditEh(AControl).EditButtons[i].Enabled := Enabled;
    end;
  end;
  if AControl is TDBDateTimeEditEh then begin
    TDBDateTimeEditEh(AControl).EditButton.Visible := Visible;
    TDBDateTimeEditEh(AControl).EditButton.Enabled := Enabled;
    for i := 0 to TDBDateTimeEditEh(AControl).EditButtons.Count - 1 do begin
      TDBDateTimeEditEh(AControl).EditButtons[i].Visible := Visible;
      TDBDateTimeEditEh(AControl).EditButtons[i].Enabled := Enabled;
    end;
  end;
  if AControl is TDBMemoEh then
    for i := 0 to TDBMemoEh(AControl).EditButtons.Count - 1 do begin
      TDBMemoEh(AControl).EditButtons[i].Visible := Visible;
      TDBMemoEh(AControl).EditButtons[i].Enabled := Enabled;
    end;
end;

procedure TControlsHelper.SetControlNotEditable(AControl: TControl; Disabled: Boolean = False; DisabledOrReadOnly: Boolean = True; Greyed: Boolean = False);
//установить контрол редактируемым или нет; если нет, то или disabled, или readonly. если Greyed то затемнить
var
  st: string;
begin
  if not Disabled then begin
    AControl.Enabled := True;
    if AControl is TCustomDBEditEh then begin
      TCustomDBEditEh(AControl).Readonly := False;
      SetEhControlColor(AControl, clWindow);
    end
    else if AControl is TDBCheckboxEh
    then TDBCheckboxEh(AControl).Enabled := True
    else if AControl is TDBGridEh
    then TDBGridEh(AControl).Readonly := False;
  end
  else begin
    if (DisabledOrReadOnly) then begin
      AControl.Enabled := False;
      st := AControl.Name;
    end
    else begin
      if AControl is TCustomDBEditEh then begin
        if DisabledOrReadOnly
          then AControl.Enabled := False
          else TCustomDBEditEh(AControl).Readonly := True
      end
      else if AControl is TDBCheckboxEh then begin
        AControl.Enabled := False
      end
      else if AControl is TDBGridEh then begin
        if DisabledOrReadOnly
          then AControl.Enabled := False
          else TDBGridEh(AControl).Readonly := True;
      end
      else if AControl is TFrDBGridEh then begin
        TFrDBGridEh(AControl).DBGridEh1.ReadOnly := True;
      end;
    end;
    if Greyed and (AControl is TCustomDBEditEh) then begin
      SetEhControlColor(AControl, RGB(230, 230, 230));
    end;
  end;
end;

procedure TControlsHelper.DlgSetControlsEnabled(F: TForm; Mode: TDialogType; CustomCtrls: array of TControl; CustomState: TVarDynArray);
//устанавливает статус Енаблед для всех контролов диалоговой формы кроме основных кнопок в зависимости от режима диалога
//если диалог не делете или вью то может поставить кастомные статусы контролдам, переданным в массиве
var
  i: Integer;
  c: TControl;
  b: Boolean;
begin
  for i := 0 to F.ComponentCount - 1 do begin
    if F.Components[i] is TControl then begin
      //не блокирем доступ к панели и групбоксу!!!
      c := TControl(F.Components[i]);
      if c is TPanel then
        continue;
      if c is TGroupBox then
        continue;
        //Не блокирем кнопки Ок и Санкел
      if (c.Name = 'Bt_Ok') or (c.Name = 'Bt_Cancel') then
        Continue;
      c.Enabled := ((Mode <> fView) and (Mode <> fDelete));
    end;
  end;
  for i := 0 to High(CustomCtrls) do begin
    CustomCtrls[i].Enabled := CustomState[i];
  end;
end;

procedure TControlsHelper.SetControlVerification(Control: TControl; Verify: string);
//условия проверки контрола записываются в динварс, и также выставляются граничные условия контролов по этим данным
var
  i, j: Integer;
  ver: TVarDynArray;
begin
  if Control = nil then Exit;
  ver := A.ExplodeV(S.IIFStr(Verify = '', ':::::::::', Verify + ':::::::::'), ':');
  if Control is TDbEditEh then begin
    TDbEditEh(Control).MaxLength := StrToIntDef(ver[1], DefEditMaxLength);
    if pos('U', S.ChangeCaseStr(ver[3], True)) > 0 then
      TDbEditEh(Control).CharCase := ecUpperCase;
    if pos('L', S.ChangeCaseStr(ver[3], True)) > 0 then
      TDbEditEh(Control).CharCase := ecLowerCase;
  end;
  if Control is TDbNumberEditEh then begin
    TDbNumberEditEh(Control).MinValue := StrToIntDef(ver[0], 0);
    TDbNumberEditEh(Control).MaxValue := StrToIntDef(ver[1], 999999999999);
    TDbNumberEditEh(Control).DecimalPlaces := StrToIntDef(ver[2], 0);
  end;
  if Control is TDbComboboxEh then begin
    if pos('U', S.ChangeCaseStr(ver[3], True)) > 0 then
      TDbComboboxEh(Control).CharCase := ecUpperCase;
    if pos('L', S.ChangeCaseStr(ver[3], True)) > 0 then
      TDbComboboxEh(Control).CharCase := ecLowerCase;
  end;
  if Control is TDBCheckBoxEh then Exit;
  if Control is TCheckBox then Exit;
  SetDynProps(Control, [[dpVerify, S.IIFStr(Verify <> '', Verify + ':::::::::')]]); //!!!
end;


procedure TControlsHelper.SetControlsVerification(Controls: array of TControl; Verify: TVarDynArray);
//передается массив контролдов и массив условий проверки
//условия проверки записываются в динварс, и также выставляются граничные условия контролов по этим данным
var
  i, j: Integer;
begin
  for i := 0 to High(Controls) do
    SetControlVerification(Controls[i], Verify[i]);
end;

procedure TControlsHelper.SetControlsVerification(Owner: TComponent; ControlsVerifycation: TVarDynArray);
//передается массив имен контролов и их условий проверки [cname1, cver1, cname2, cver2...]
//условия проверки записываются в динварс, и также выставляются граничные условия контролов по этим данным
var
  i: Integer;
  Ctrls: TControlArray;
  CtrlVer: TVarDynArray;
  C: TComponent;
  st: string;
begin
  if High(ControlsVerifycation) = -1 then Exit;
  for i:= 0 to High(ControlsVerifycation) div 2 do begin
//    st := ControlsVerifycation[i];
    c:=Owner.FindComponent(ControlsVerifycation[i * 2]);
    if c <> nil then
      SetControlVerification(TControl(c), ControlsVerifycation[i * 2 + 1]);
  end;
end;


function TControlsHelper.FindControlByFieldName(ASelf: TForm; FieldName: string): TControl;
//найдем компонент на форме, соответствующие названию поля
//(поле может быть с модификатором и алиасом)
var
  i, j: Integer;
  st: string;
  va: TStringDynArray;
begin
  Result := nil;
  for i := 0 to ASelf.ComponentCount - 1 do
    if (ASelf.Components[i] is TCustomDBEditEh) or (ASelf.Components[i] is TCheckBox) or (ASelf.Components[i] is TDBCheckBoxEh) or (ASelf.Components[i] is TDBMemoEh) or (ASelf.Components[i] is TMemo) then begin
      j := Pos('_', TControl(ASelf.Components[i]).Name);
      if j = 0 then Continue;
      if S.CompareStI(Copy(TControl(ASelf.Components[i]).Name, j + 1), FieldName) then begin
        Result := TControl(ASelf.Components[i]);
        Exit;
      end;
    end;
end;

procedure TControlsHelper.SetControlsEmptyText(ASelf: TForm);
//установить вссем дбэх контролам формы пустые значения
var
  i, j: Integer;
begin
  for i := 0 to ASelf.ComponentCount - 1 do
    if ASelf.Components[i] is TCustomDBEditEh then
      TCustomDBEditEh(ASelf.Components[i]).Text := '';
end;

procedure TControlsHelper.SetControlsOnChange(ASelf: TForm; c: TNotifyEvent; WithCheckboxes: Boolean = False);
//установить вссем дбэх контролам формы событития ончейнж
//используем ASelf.ComponentCount а не ASelf.ControlCount, так как последний проходит только по родителю, а не по всей форме, те не проставит например если контролы на панелях
var
  i, j: Integer;
  st: string;
begin
  for i := 0 to ASelf.ComponentCount - 1 do
    if ASelf.Components[i] is TCustomDBEditEh then begin
      st := ASelf.Components[i].Name;
      TDBEditEh(ASelf.Components[i]).OnChange := c;
    end
    else if (ASelf.Components[i] is TDBCheckBoxEh) and (WithCheckboxes) then begin
      st := ASelf.Components[i].Name;
      TDBCheckBoxEh(ASelf.Components[i]).OnClick := c;
    end;
end;

procedure TControlsHelper.SetControlsOnExit(ASelf: TForm; c: TNotifyEvent);
//установить вссем дбэх контролам формы событития onExit
var
  i, j: Integer;
begin
  for i := 0 to ASelf.ComponentCount - 1 do
    if ASelf.Components[i] is TCustomDBEditEh then
      TDBEditEh(ASelf.Components[i]).OnExit := c;
end;

procedure TControlsHelper.SetControlsOnCheckDrawRequired(ASelf: TForm; c: TOnCheckDrawRequiredStateEventEh);
//установить вссем дбэх контролам формы событития OnCheckDrawRequiredState
var
  i, j: Integer;
begin
  for i := 0 to ASelf.ComponentCount - 1 do
    if ASelf.Components[i] is TCustomDBEditEh then begin
      TDBEditEh(ASelf.Components[i]).OnCheckDrawRequiredState := c;
    end;
end;

procedure TControlsHelper.VerifyAllDbEhControls(ASelf: TForm);
//проверить все дбэх контролы на форме
var
  i, j: Integer;
  st: string;
begin
  for i := 0 to ASelf.ComponentCount - 1 do
    if ASelf.Components[i] is TCustomDBEditEh then begin
      st := TCustomDBEditEh(ASelf.Components[i]).Name;
      VerifyControl(TDBEditEh(ASelf.Components[i]), False);
    end;
end;

function TControlsHelper.GetParentForm(C: TControl): TForm;
//найти родительскую форму для контрола
var
  i: Integer;
  cc: TControl;
begin
  cc := C.Parent;
  while not (cc is TForm) do
    cc := cc.Parent;
  Result := TForm(cc);
end;

function TControlsHelper.GetButtonParams(AButtons: TVarDynArray2; p: Integer; var BtnRec: TmybtRec; var BtnId: Integer; var BtnVis, LastBtnVis: Boolean;
  var IsDropDown: Integer;  var BtnG: Integer;
  var BtnCapt, BtnPict: string; var ShortCut: Integer; var BtnState: Boolean; var BtnW: Integer): Boolean;
//вспомогательная функция для создания панелей кнопок и меню
//получает параметры кнопки по данным массива параметров кнопок и некоторах вспомогательных переменных
var
  pp, i, j: Integer;
  b: Boolean;
begin
  Result:= False;
  //если элемент массива (он сам массив) пустой, или его начальный элемент не целое число, выйдем и вернем False
  if High(AButtons[p]) = -1 then begin
    AButtons[p] := [mbtDividor];
    //Exit;
  end;
  if (S.VarType(AButtons[p][0]) <> varInteger) then
    if S.VarType(AButtons[p][0]) = varDouble then begin
      //если дробное число, то сделает эту кнопку разделителем с этой шириной
      AButtons[p] := [mbtSpace, True, round(AButtons[p][0])];
    end;
  if (S.VarType(AButtons[p][0]) <> varInteger) then Exit;
  //айди кнопки
  BtnID:= AButtons[p][0];
  //получим параметр видимости кнопки, а также и сохраним последнее его значение
  pp:= 1;
  if (High(AButtons[p]) = 0) then begin
    BtnVis:= True;
    LastBtnVis:= True;
  end
  else begin
    if VarType(AButtons[p][1]) and VarTypeMask = varBoolean then begin
      BtnVis:= AButtons[p][1];
      LastBtnVis:= BtnVis;
      pp:= 2;
    end
    else if VarType(AButtons[p][1]) and VarTypeMask = varByte then begin
      BtnVis:= LastBtnVis;
      pp:= 2;
    end;
  end;
  //кнопки с таким же айди не должны повторяться
  if BtnVis and not (BtnID in [mbtDividor, mbtDividorM, mbtSpace, mbtCtlPanel, mbtToAlRight]) then begin
    for i:= 0 to p - 1 do
      if (High(AButtons[i]) >= 0)and(S.VarType(AButtons[i][0]) = varInteger)and(AButtons[i][0] = BtnId)
        then Exit;
  end;
  //полчим индикатор создания подмен./выпадающего списка для кнопки
  if (BtnId = mbtDividorM) and (BtnVis) then
    if IsDropDown = -1 then
      IsDropDown := p + 1
    else
      IsDropDown := -1;
    //получим параметры кнопок
  BtnCapt:='';
  BtnPict:='';
  ShortCut:= 0;
  BtnState:= True;
  BtnW:= 0;
  BtnG:= 0;
  //из массива стандартных кнопок, если с этим айди в нем найдена
  for i:= 0 to High(myDefaultBtns) do
    if myDefaultBtns[i].Bt = Abs(BtnId) then begin
      BtnCapt:= myDefaultBtns[i].Caption;
      BtnPict:= myDefaultBtns[i].Pict;
      ShortCut:= myDefaultBtns[i].ShortCut;
      Break;
    end;
  //параметры кнопки (все могут быть пропущены; для установки какого параметра используем элемент массива, определяется его типом данных
  //если меньше 0, то задает GroupIndex для SpeedButton, чтобы кнопка могла нажиматься. Если меньше -100, то одиночное нажатие, иначе переключатель
  if (High(AButtons[p]) >= pp)and(S.VarType(AButtons[p][pp]) = varInteger)and(AButtons[p][pp] < 0) then begin
    BtnG:= AButtons[p][pp];
    inc(pp);
  end;
  //статус кнопки (enabled/disabled), чтобы этот параметр сработал, оябзательно нужен второй параметр - создавать ли кнопку
  if (High(AButtons[p]) >= pp)and(S.VarType(AButtons[p][pp]) = varBoolean) then begin
    BtnState:= AButtons[p][pp];
    inc(pp);
  end;
  //если есть, то 0 - оставить ширину как есть, 1 (для bitbtn) - использовать не тот тип как далы всех (короткую вместо длинной или наоборот), другой число - длина кнопки
  if (High(AButtons[p]) >= pp)and(S.VarType(AButtons[p][pp]) = varInteger) then begin
    BtnW:= AButtons[p][pp];
    inc(pp);
  end;
  //заголовок кнопки
  if (High(AButtons[p]) >= pp)and(S.VarType(AButtons[p][pp]) = varString) then begin
    BtnCapt:= AButtons[p][pp];
    inc(pp);
  end;
  //картинка
  if (High(AButtons[p]) >= pp)and(S.VarType(AButtons[p][pp]) = varString) then begin
    BtnPict:= AButtons[p][pp];
    inc(pp);
  end;
  //быстрые клавиши для меню
  if (High(AButtons[p]) >= pp)and(S.VarType(AButtons[p][pp]) = varInteger) then begin
    ShortCut:= AButtons[p][pp];
    inc(pp);
  end;
  //поля записи кнопки
  BtnRec.Bt:= BtnID;
  BtnRec.Pict:= BtnPict;
  BtnRec.Caption:= BtnCapt;
  BtnRec.ShortCut:= ShortCut;
  Result:= True;
end;



function TControlsHelper.CreateButtons(APanel: TPanel; AButtons: TVaRDynArray2; AOnClick: TNotifyEvent; AButtonType: Integer = 1 ; ASuffix: string = ''; APanMargins: Integer = 0; AHeight: Integer = 0; AVertical: Boolean = False): Integer;
//создает кнопки на панели по спецификации кнопок, переденной в двумерном массиве вариант
//размер панели подгоняет под размер созданных кнопок + APanMargins (и длину и ширину), если не задан AHeight , если ни одной не создолось будет 0,
//при вертикальном расположании и кастомной ширине кнопок ширина панели бет по мактимльной кнопке или AHeight а высота по последнему элементу
//кнопки могут быть расположены как горизонтально так и вертикально
//тип кнопок определяется AButtonType (1 - спидбаттон32, 2 - спидбаттон25, 3- bitbtn стандартной дины, 4 -bitbtn квадратные маленькие без заголовков
//могут создаваться кнопки с выпадающим списком
//могут создаваться разделители и путое простарнство между кнопками
//может создаваться панель, тогда она получает имя APanel + 'Ctl' + NoCtlPanel
//кнопкам присваивается теги и событие обработчика
//если кнопки уже были ранее в панели созлданы, то они пересоздаются
{
AButtons: [[инфа по кнопкеъ],[],..].
Инфа переменной длины
- btnID - константа btnXX, обязательна, если найдена в массиве кнопок то инфа берется из него. Обязательна.
Все остальные не обязательны, если нет значения подходящего типа то пытается натий следующее.
- статус видимости - если не задан или True то кнопка видна и создается, если False то не создается, если 1, то статус такой же, как прошлый элемент
  /Dividor создается всегда, но если оказались повторяющиеся разделители - повторяющийся не создается/
- GroupIndex для SpeedButton, если меньше 0
- статус кнопки (enable/disabled); если здесь не значение Boolean, то он пропускается (переход к следующему)
- инвертировать размер кнопки или задать длину (число)
  имеет смысл если AButtonType = 3,4 (TBitBtn маленькие, большие), в этом случае
  значение 1 инвертирует размер (если заданы длиные кнопки, то делает квадратную и наоборот), другое задает длину кнопки явно
  если этот параметр не число, то он пропускается (переход к заголовку)
- заголовок
- картинка (наименование)
- shortcut (Integer) по типу: scCtrl + ord('S')

для создания кнопки с меню:
  [... [btnDividorM], [btnPrint], [btnPrintPassport], [btnPrintLabels], [btnDividorM] ...]
будет создана кнопка с заголовком из btnPrint, по ней выпадет меню из дух позиций: btnPrintPassport, btnPrintLabels

btnDividor созает разделитель, в случае вертикальных кнопок подгонятеся по ширине панели
если в качестве айди кнопки задать дробное число (напромер 50.0), то будет создано путой пространство шириной 50 пикселей
также и btnSpace создает пустой пространство заданной ширины (в третьем параметре; если не задано то дефолтной ширине кнопки для данного режима

}
const
  cBtnBH = MY_FORMPRM_BTN_DEF_H;
  cBtnBW = MY_FORMPRM_BTN_DEF_W;
  cBtnH = MY_FORMPRM_SPEEDBTN_DEF_H;
var
  i, j, k, L, m, w: Integer;
  MaxBtnWidth: Integer;
  b: Boolean;

  Btn: TControl;
  Dividor: TBevel;
  PCtl: TPanel;
  Pm: TPopupMenu;
  Mi: TMenuItem;
  BtnID: Integer;
  BtnVis, LastBtnVis, BtnState: Boolean;
  BtnW, BtnH, BtnG: Integer;
  BtnCapt, BtnPict: string;
  ShortCut: Integer;
  BtnRec: TmybtRec;
  BtnType: Integer;
  IsDropDown: Integer;
  IsDiv: Integer;
  PCtlN: Integer;
  AlRight: Boolean;
  FirstRight: Integer;
begin
  Result := 0;
  L := 5;
  IsDiv := 0;
  IsDropDown := -1;
  //удалим все компоненты (кнопки и меню) с панели
  for i:= APanel.ComponentCount - 1 downto 0 do begin
    APanel.Components[i].Destroy;
  end;
  //проход по массиву кнопок
  for i := 0 to High(AButtons) do begin
    Btn := nil;
    //получим параметры кнопки для данного элемента и некоторые вспомогательные переменные
    if not GetButtonParams(AButtons, i, BtnRec, BtnId, BtnVis, LastBtnVis, IsDropDown, BtnG, BtnCapt, BtnPict, ShortCut, BtnState, BtnW)
      then Continue;
    if BtnId < 0 then Continue;
    if (BtnID = mbtToAlRight) then begin
      AlRight:= True;
      FirstRight:= L;
    end;
    if ((BtnID = mbtDividor) and (IsDiv > 0)) or (BtnID = mbtDividorA) then begin
      //создаем разделитель (только если они не идут подряд)
      Dividor := TBevel.Create(APanel.Owner);
      Dividor.Parent := APanel;
      if AVertical then begin
        Dividor.Top := L + 4;
        Dividor.Left := 2;
        Dividor.Width := 32;
        Dividor.Height := 2;
      end
      else begin
        Dividor.Top := 2;
        Dividor.Left := L + 4;
        Dividor.Width := 2;
        if AlRight then Dividor.Anchors:=[akRight, akTop];
        Dividor.Height := S.Decode([AButtonType, 1, cBtnH, cBtnBH]);
      end;
      L := L + 2 + 8;
      Result := L;
      if BtnID <> mbtDividorA then
        IsDiv := -1;
    end;
    if (BtnID = mbtSpace) and BtnVis then begin
      //создаем путое пространство
      L:= L + BtnW;
      Result := L;
      IsDiv := 1;
    end;
    if (BtnID = mbtCtlPanel){ and BtnVis} then begin
      //создаем панель контролов
      //если панель с таким именем уже есть, то используем ее, в этом случае можно не указывать видимость и ширину (ширина будет по размеру панели тогда)
      inc(PCtlN);
      PCtl := TPanel(APanel.Owner.FindComponent(APanel.Name + 'Ctl' + IntToStr(PCtlN)));
      if PCtl <> nil then
        BtnVis := True;
      if BtnVis then begin
        if PCtl = nil then
          PCtl := TPanel.Create(APanel.Owner);
        PCtl.Parent := APanel;
        PCtl.Align := alNone;
        PCtl.Name := APanel.Name + 'Ctl' + IntToStr(PCtlN);
      //PCtl.Caption:=PCtl.Name;
        PCtl.BevelOuter := bvNone;
        PCtl.Left := S.IIf(AVertical, APanMargins, L);
        if BtnW > 0 then
          PCtl.Width := BtnW;
        L := L + PCtl.Width; //BtnW;
        Result := L;
        IsDiv := 1;
      end;
    end;
    if BtnVis and not (BtnID in [mbtDividor, mbtDividorA, mbtDividorM, mbtSpace, mbtCtlPanel, mbtToAlRight]) and
      ((IsDropDown = i) or (IsDropDown = -1)) then begin
      //создаем обычную кнопку
      if AButtonType in [cbttSBig, cbttSSmall]
        then Btn := TSpeedButton.Create(APanel.Owner)
        else Btn := TBitBtn.Create(APanel.Owner);
      BtnType:= AButtonType;
      if BtnW = 1 then begin
        case BtnType of
          cbttSBig: btnType:= cbttSSmall;
          cbttSSmall: btnType:= cbttSBig;
          cbttBNormal: btnType:= cbttBSmall;
          cbttBSmall: btnType:= cbttBNormal;
        end;
        if BtnType > 10 then btnType:= cbttBSmall;
      end;
      Btn.Parent := APanel;
      Btn.Name := 'Bt_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(BtnID);
      SetBtn(Btn, BtnID, AOnClick, BtnType, S.IIf(BtnW > MY_FORMPRM_CONTROL_H, BtnW, 0), BtnG, BtnCapt, BtnPict);
 //TButton(Btn).Caption := Btn.Name;
      //положение
      Btn.Left := S.IIf(AVertical, APanMargins, L);
      Btn.Top := S.IIf(AVertical, L, APanMargins);
      Btn.Enabled := BtnState;
      //установим кнопку, содержащую выпадающий список (первая после btnDividorM)
      if IsDropDown = i then begin
        //для спидбаттона добавим ширину, для битбаттона останется такая же
        if AButtonType in [1..2] then Btn.Width := Btn.Width + 10;
        //добавим к заголовку "Треуголитник вниз" как индикатор наличия подменю
        TSpeedButton(Btn).Caption := TSpeedButton(Btn).Caption + '' + #$25BC;
        //уберем хинт
        Btn.Hint := '';
        //событие - описано глобально в объекте Module для таких кнопок
        TSpeedButton(Btn).OnClick := Module.MenuSpeedButton1Click;
        //создадим меню для выпадающего списка
        Pm := TPopupMenu.Create(APanel.Owner);
        Pm.Name := 'MBt_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(BtnID);
      end;
      //увеличим счетчик дилины/высоты
      //if Btn <> nil then
      if AVertical then
        L := Btn.Top + Btn.Height + S.IIf(AButtonType in [1..2], MY_FORMPRM_SPEEDBTN_VH_MARGIN, MY_FORMPRM_BTN_V_MARGIN)
      else begin
        L := Btn.Left + Btn.Width + S.IIf(AButtonType in [1..2], MY_FORMPRM_SPEEDBTN_VH_MARGIN, MY_FORMPRM_BTN_H_MARGIN);
  //      APanel.Width := Result;
        //if AlRight then Btn.Anchors:=[akRight, akTop];
      end;
      MaxBtnWidth:= Max(MaxBtnWidth, Btn.Width);
      IsDiv := 1;
      //в результат - текущую длину/высоту
      Result := L;
    end
    else if BtnVis and not (BtnID in [mbtDividor, mbtDividorM, mbtSpace, mbtCtlPanel, mbtToAlRight]) and (IsDropDown <> -1) then begin
      //если это кнопки, задающие пунсты выпадающего меню (вторая и далее после btnDividorM) - содадим пункты меню
      Mi := TMenuItem.Create(Pm);
      Mi.Name := 'MMi_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(BtnID);
      SetMenuItem(Mi, BtnRec, True);
      Pm.Items.Add(Mi);
      Mi.OnClick := AOnClick;
    end;
  end;
  //удалим повторяющийся разделитель если таковой оказался
  if IsDiv = -1 then
    Dividor.Destroy;
  //если не было создано кнопок то поанель сделаем пустой
//Result:=Result+10;
  if Result = 0 then begin
    APanel.Height := 0;
    APanel.Width := 0;
  end
  //иначе установим размеры панели
  else if not AVertical then begin
    //для горизонтальной высоту по типу снопок + оступы
    if AHeight = 0 then APanel.Height := S.Decode([AButtonType, 1, cBtnH, cBtnBH]) + APanMargins * 2 else APanel.Height := AHeight;
    APanel.Width := Result + APanMargins;
    //выровняем все элементы по центру
    for i:= APanel.ControlCount - 1 downto 0 do begin
      if APanel.Controls[i] is TBevel
        then APanel.Controls[i].Height:= APanel.Height - APanMargins * 2
        else APanel.Controls[i].Top:= (APanel.Height - APanel.Controls[i].Height) div 2;
      if (FirstRight > 0) and (APanel.Controls[i].Left >= FirstRight)
        then APanel.Controls[i].Anchors:= [akRight, akTop];
    end;
  end
  else begin
    //для вертикльной высоту, а ширину по макс кширине кнопки
    if AHeight = 0 then APanel.Width := MaxBtnWidth + APanMargins * 2 else APanel.Width := AHeight;
    APanel.Height := Result + APanMargins;
    //и подгоним ширину разделителей на максимальную для кнопки
    for i:= APanel.ControlCount - 1 downto 0 do
      if APanel.Controls[i] is TBevel
        then APanel.Controls[i].Width := MaxBtnWidth
  end;
end;

procedure TControlsHelper.CreatePopupMenu(AComponent: TComponent; AButtons: TVaRDynArray2; AOnClick: TNotifyEvent; ASuffix: string = '');
//создаем меню ПКМ
//передается или контрол, для которого создается меню (пока только DBGridEh),
//или уже созданное меню
//передается массив кнопок
var
  Pm: TPopupMenu;
  i, j: Integer;
  b: Boolean;
  mi, mi1: TMenuItem;
  isSubMenu: Integer;
  BtnID: Integer;
  BtnVis, LastBtnVis, BtnState: Boolean;
  BtnW, BtnH, BtnG: Integer;
  BtnCapt, BtnPict: string;
  ShortCut: Integer;
  BtnRec: TmybtRec;
  BtnType: Integer;
  IsDiv: Integer;
  PCtlN: Integer;

begin
  try
  if AComponent is TPopupMenu then begin
    Pm:= TPopupMenu(AComponent);
    Pm.Items.Clear;
  end
  else if AComponent is TDBGridEh
  then TDBGridEh(AComponent).PopupMenu:= Pm
  else if GetPropInfo(AComponent.ClassInfo, 'PopupMenu') <> nil then begin
    //!!!этот вариант работает но при разрушении возникает ошибка
    //(проверено на TFrDBGridEh, ошибка при закрытии окна, а само меню работает
    //и если сделать после создания DBGridEh1.PopupMenu.Destroy то это проходит нормально
    //на других формах не проверял пока.
    Pm:=TPopupMenu.Create(AComponent);
    Pm.Name:=AComponent.Name + 'Pm';
    Pm.AutoPopup:=True;
    Sys.SetCompPropObj(AComponent, 'PopupMenu', Pm);
  end;
  IsDiv := 0;
  isSubMenu := -1;
  for i := 0 to High(AButtons) do begin
    if not GetButtonParams(AButtons, i, BtnRec, BtnId, BtnVis, LastBtnVis, isSubMenu, BtnG, BtnCapt, BtnPict, ShortCut, BtnState, BtnW)
      then Continue;
    if (BtnID = mbtDividor) and (IsDiv > 0) then begin
      mi := TMenuItem.Create(Pm);
      mi.Caption := '-';
      Pm.Items.Add(mi);
    end;
    if BtnVis and not (BtnID in [mbtDividor, mbtDividorA, mbtDividorM, mbtSpace, mbtCtlPanel, mbtToAlRight]) then begin
      mi := TMenuItem.Create(Pm);
      if isSubMenu = i then begin
        mi1 := mi;
        Pm.Items.Add(mi1);
        mi1.Name := 'MiSub_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(BtnId);
        SetMenuItem(mi1, A.VarDynArray2RowToVD1(AButtons, i));
        mi1.Tag := 0;
      end
      else begin
        mi.Name := 'Mi_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(BtnId);
//        SetMenuItem(mi, BtnRec, True);
        SetMenuItem(mi, A.VarDynArray2RowToVD1(AButtons, i));
        if isSubMenu = -1 then
          Pm.Items.Add(mi)
        else
          mi1.Add(mi);
        mi.OnClick := AOnClick;
//mi.Caption:=mi.Name;
      end;
      IsDiv := 1;
    end;
  end;
  finally
  end;
end;

function CopyBitmapRect(BitmapSrc: TBitmap; x1,y1,x2,y2:Integer): TBitmap;
var
  ARect: TRect;
  Bitmap: TBitmap;
  DCanvas: TControlCanvas;
  h,w:Integer;
begin
  ARect:= Rect(x1, y1, x2, y2);
  Bitmap:= TBitmap.Create;
  Bitmap.Width:= x2 - x1 + 1;
  Bitmap.Height:= x2 - x1 + 1;
  with Bitmap.Canvas do
    CopyRect(Bitmap.Canvas.ClipRect, BitmapSrc.Canvas, ARect);
  Result:=Bitmap;
end;

procedure TControlsHelper.SetMenuItem(AMenuItem: TMenuItem; AButton: TVarDynArray; ANewCaption: string = ''; ANewEnabled: Integer = -1);
//настраивает уже созданную МенюИтем по данным элемента массива кнопок
//если заданы ANewCaption или ANewEnabled, то меняет их, но в этом случае если к кнопке кастомная картинка была при сощздании,
//а здесь не задана, то она не станет серой при дисейблед меню, надо задавать явно здесь
//если задан гроупиндекс то пункты становятся с чекбоксами, но последние не видны,
//если к к нопке есть картинка, а если ее нет, то заголовки съезжают влево
var
  i, j: Integer;
  BtnID: Integer;
  BtnVis, LastBtnVis, BtnState: Boolean;
  BtnW, BtnH, BtnG: Integer;
  BtnCapt, BtnPict: string;
  ShortCut: Integer;
  BtnRec: TmybtRec;
  BtnType: Integer;
  IsDiv: Integer;
  PCtlN: Integer;
  isSubMenu: Integer;
  Bitmap, Bitmap2, BitmapOld, BitmapDis: TBitmap;
  h, w: Integer;
  ToRefresh, ANewEnabledb: Boolean;
  ARect: TRect;
  AButtons: TVarDynArray2;
begin
  ToRefresh := not ((ANewCaption = '') and (ANewEnabled = -1));
  AButtons := [];
  A.VarDynArray2InsertArr(AButtons, AButton);
  if not GetButtonParams(AButtons, i, BtnRec, BtnID, BtnVis, LastBtnVis, isSubMenu, BtnG, BtnCapt, BtnPict, ShortCut, BtnState, BtnW) then
    Exit;
  if BtnPict = '' then
    BtnPict := 'empty';
  if BtnPict <> '' then
    AMenuItem.Hint := BtnPict;
  if (BtnPict = '') and (AMenuItem.Hint <> '') then
    BtnPict := AMenuItem.Hint;
  if (BtnID in [mbtDividor, mbtDividorA, mbtDividorM, mbtSpace, mbtCtlPanel]) then
    Exit;
  if not ToRefresh then
    AMenuItem.Caption := S.IIf(BtnID = mbtDividor, '-', BtnCapt)
  else if ANewCaption <> '' then
    AMenuItem.Caption := ANewCaption;

 {   if Abs(BtnG) > 0 then begin
      AMenuItem.GroupIndex:= Abs(BtnG);
      AMenuItem.AutoCheck:= True;
    end
    else begin
      AMenuItem.GroupIndex:= 0;
      AMenuItem.AutoCheck:= False;
    end;   } //!!!
  if not ToRefresh then
    ANewEnabledb := True
  else
    ANewEnabledb := S.Decode([ANewEnabled, 0, False, 1, True, 255, True, AMenuItem.Enabled]);
  AMenuItem.Enabled := ANewEnabledb;
  if BtnPict <> '' then begin
    try
      //приходится делать перерисовкой, иначе глюки отображения
      Bitmap := TBitmap.Create;
      h := 20;
      //загрузим изображение, размер будет или 16 или 20
      Module.SetBitmapFromResource(Bitmap, PChar(BtnPict));
      //если не найдено, загрузим пустой прозрачное (розовое) изображение, иначе эти пункты в меню визуально сдвигаются влево
      if (Bitmap.Height = 0) then
        Module.SetBitmapFromResource(Bitmap, PChar('empty'));
      if AMenuItem.GroupIndex <> 0 then
        if AMenuItem.Checked then
          Module.SetBitmapFromResource(Bitmap, PChar('ok'))
        else
          Module.SetBitmapFromResource(Bitmap, PChar('empty'));
      //получим высоту
      h := Bitmap.Width;
      h := Bitmap.Height;
      //установим размеры
      Bitmap.SetSize(h * 2, h);
      if not ANewEnabledb then begin
        Bitmap2 := CopyBitmapRect(Bitmap, h, 0, h * 2, h);
        Bitmap.Free;
        Bitmap := Bitmap2;
      end;
      //AMenuItem.Bitmap := Bitmap; //.Canvas.Draw(0,0,ic);
      AMenuItem.Bitmap.SetSize(h, h);  //здесь может возникать ошибка!!!
      AMenuItem.Bitmap.Canvas.Draw(0, 0, Bitmap);
      if BtnRec.ShortCut <> 0 then
        AMenuItem.ShortCut := BtnRec.ShortCut; //  ShortCut(VK_F1, [ssCtrl]);
    finally
      Bitmap.Free;
    end;
  end;
  if AMenuItem.Tag = 0 then
    AMenuItem.Tag := BtnID;
end;


procedure TControlsHelper.SetButtonsAndPopupMenuCaptionEnabled(AComponents: TComponentsArray; ATag: Integer; ACaption: Variant; AEnabled: Variant; ASuffix: string = '');
//меняет заголовок пункта ПКМ или кнопки (для SpeedButton меняет Hint), и свойство Enabled,
//находя элемент в переданных компонентах по тегу
//чтобы не менять статус или текст заголовка, в данных полях ставить null!
var
  i, j: Integer;
  c: TComponent;
  capt, st: string;
  en: Integer;
begin
  for i:= 0 to High(AComponents) do begin
    st := AComponents[i].Name;
    if AComponents[i] is TPopupMenu then
      for j:= AComponents[i].ComponentCount - 1 downto 0 do begin
        c:= AComponents[i].Components[j];
        if (c.Tag =ATag)and(c is TMenuItem) then begin
          capt:= TMenuItem(c).Caption;
          if S.VarType(ACaption) = varString then capt := ACaption;
          en:= -1;
          if S.VarType(AEnabled) = varBoolean then en:= byte(AEnabled);
          SetMenuItem(TMenuItem(c), [ATag], capt, en);
        end;
      end
    else
      for j:= TWinControl(AComponents[i]).ControlCount - 1 downto 0 do begin
        c:= TWinControl(AComponents[i]).Controls[j];
        st := c.Name;
        if (c.Tag =ATag)and((c is TBitBtn)or(c is TSpeedButton)) then begin
          if S.VarType(ACaption) = varString then begin
            if TBitBtn(c).Width > MY_FORMPRM_SPEEDBTN_DEF_H
              then TBitBtn(c).Caption:= ACaption
              else TBitBtn(c).Hint:= ACaption;
          end;
          if S.VarType(AEnabled) = varBoolean then TSpeedButton(c).Enabled := AEnabled;
        end;
      end;
  end;
end;

procedure TControlsHelper.SetButtonsAndPopupMenuCaptionEnabled(AOwner: TComponent; ATag: Integer; ACaption: Variant; AEnabled: Variant; ASuffix: string = '');
//меняет заголовок пункта ПКМ или кнопки (для SpeedButton меняет Hint), и свойство Enabled, для всех элементов этого типа принадлежащих AOwner
//(если задан тег то проверяет его в имени компонента)
//чтобы не менять статус или текст заголовка, в данных полях ставить null!
var
  i, j: Integer;
  c: TComponent;
  capt, st: string;
  en: Integer;
  va: TVarDynArray;
begin
  for i:= 0 to AOwner.ComponentCount - 1 do begin
    c := AOwner.Components[i];
    //если находим PopupMenu, то вызовем рекурсивно для него, тк для TMenuItem выладельцем является само меню а не форма/грид
    if c is TPopupMenu then
      SetButtonsAndPopupMenuCaptionEnabled(c, ATag, ACaption, AEnabled, ASuffix);
    if (c.Tag <> ATag) then
      Continue;
    va := A.Explode(c.Name, '_');
    if (ASuffix <> '') then begin
      if Length(va) < 3 then
        Continue;
      if not (S.IsInt(va[High(va)]) and (va[High(va)] = ASuffix)) then
        Continue;
    end
    else begin
      if S.IsInt(va[High(va)]) and (Length(va) > 2) then
        Continue;
    end;
    if (c is TMenuItem) then begin
      capt := TMenuItem(c).Caption;
      if S.VarType(ACaption) = varString then
        capt := ACaption;
      en := -1;
      if S.VarType(AEnabled) = varBoolean then
        en := byte(AEnabled);
      SetMenuItem(TMenuItem(c), [ATag], capt, en);
    end
    else if (c is TBitBtn) or (c is TSpeedButton) then begin
      if S.VarType(ACaption) = varString then begin
        if TBitBtn(c).Width > MY_FORMPRM_SPEEDBTN_DEF_H then
          TBitBtn(c).Caption := ACaption
        else
          TBitBtn(c).Hint := ACaption;
      end;
      if S.VarType(AEnabled) = varBoolean then
        TSpeedButton(c).Enabled := AEnabled;
    end;
  end;
end;


function TControlsHelper.EnumComponents(AParent: TComponent; AControlName: string; ASuffix: Integer = 0; ATag: Integer = 0): TComponentsArray;
//создает массив из всех компонентов указанного родителя и его дочерних компонентов рекурсивно, используя заданные уусловия
//прередается имя компонента, суффикс и тег. все не обязательно. если не указано ничего, то переберет все компоненты
var
  ca: TComponentsArray;
procedure EnumC(AParent: TComponent; AControlName: string; ASuffix: Integer = 0; ATag: Integer = 0);
var
  i: Integer;
  c: TComponent;
  st: string;
  b: Boolean;
begin
  for i:=0 to AParent.ComponentCount - 1 do begin
    c:= AParent.Components[i];
    st:= S.ToUpper(c.Name);
    b:= True;
    if ASuffix <> 0 then b:= S.Right(st, 4) = 'SFX' + IntToStr(ASuffix);
    if AControlName <> '' then b:= S.CompareStI(st + S.IIfStr(ASuffix <> 0, 'SFX' + IntToStr(i)), AControlName);
    b:= b and ((ATag = 0) or (c.Tag = ATag));
    if b then begin
      ca:= ca + [c];
    end;
    EnumC(c, AControlName, ASuffix, ATag);
  end;
end;
begin
  ca:= [];
  EnumC(AParent, AControlName, ASuffix, ATag);
  Result:= ca;
end;








function TControlsHelper.CreateGridBtns(AForm: TForm; APanel: TPanel; AButtons: TmybtArr; AButtonsState: TVarDynArray; AOnClick: TNotifyEvent; ASuffix: string = ''; Vertical: Boolean = False): Integer;
//создает кнопки для редактирования грида на переданной форме в переданной панели, задаются массив произвольных записей кнопок а также рапзделителей
//кнопки создаются в порядке, переданном в массиве
//передается массив статусов кнопок, True соответствует тому что кнопку надо создавать и она видима, если False то кнопка не создается, если
//передано не булевой значениее, то статус создания будет такой же, как у кнопки слева (чтобы не делать проверки напр для всех кнопок изменения
//дублирующие, начальные, конечные дивидоры не создаются
//ASuffix, если задан, добавляется к имени кнопки, нужно если надо на одной форме создать несколько панелей кнопок
//возвращаетдлину созданной панели кнопок (правую границу последне кнопки)
//2024-03-30
//сделана кнопка с выпадающим списком (меню)
//для этого обрамить кнопки типом mybtDividorM, первая кнопка после него будет заголовочной, к ней добавится стрелка вниз,
//она не будет вызавать событие нажатия, а при этом развернет подменю; все остальные кнопки будут добавлены как подменю,
//до замыкающего DividorM.
//корректность, когда не совпадают открывающие или закрывающие дивм, или не должна быть кнопка видна вообще по статусам - не обрабатываются
//точно также обрабатывает подменю и CreateGridMenu
var
  i, j, k, L, m: Integer;
  Btn: TSpeedButton;
  Pm: TPopupMenu;
  Mi: TMenuItem;
  Dividor: TBevel;
  ls: Integer;
  b, blast: Boolean;
  IsDropDown: Integer;
begin
  Result := 0;
  L := 5;
  ls := 0;
  IsDropDown := -1;
  for i := 0 to High(AButtons) do begin
    if (VarType(AButtonsState[i]) and VarTypeMask = varBoolean) then begin
      b := AButtonsState[i];
      blast := b;
    end
    else
      b := blast;
    if (AButtons[i].Bt = mbtDividorM) then begin
      if IsDropDown = -1 then
        IsDropDown := i + 1
      else
        IsDropDown := -1;
    end;
    if (AButtons[i].Bt = mbtDividor) and (ls > 0) then begin
      Dividor := TBevel.Create(APanel);
      Dividor.Parent := APanel;
      if Vertical then begin
        Dividor.Top := L + 4;
        Dividor.Left := 2;
        Dividor.Width := 32;
        Dividor.Height := 2;
      end
      else begin
        Dividor.Top := 2;
        Dividor.Left := L + 4;
        Dividor.Width := 2;
        Dividor.Height := 32;
      end;
      L := L + 2 + 8;
      ls := -1;
    end;
    if b and not (AButtons[i].Bt in [mbtDividor, mbtDividorM]) and ((IsDropDown = i) or (IsDropDown = -1)) then begin
      Btn := TSpeedButton.Create(APanel);
      Btn.Parent := APanel;
      Btn.Tag := AButtons[i].Bt;
      Btn.Name := 'Bt_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(AButtons[i].Bt);
      SetSpeedButton(Btn, AButtons[i], True);
      Btn.Height := 34;
      Btn.Width := Btn.height;
      Btn.Left := S.IIf(Vertical, 2, L);
      Btn.Top := S.IIf(Vertical, L, 2);
      Btn.OnClick := AOnClick;
      if IsDropDown = i then begin
        Btn.Width := Btn.Width + 10;
        Btn.Caption := '' + #$25BC;
        Btn.Hint := '';
        Btn.OnClick := Module.MenuSpeedButton1Click;
        //IsDropDown:= -1;
        Pm := TPopupMenu.Create(APanel);
        Pm.Name := 'MBt_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(AButtons[i].Bt);
      end;
      if Vertical then
        L := Btn.Top + Btn.Height + 1
      else
        L := Btn.Left + Btn.Width + 1;
      ls := 1;
      Result := L;
    end
    else if b and not (AButtons[i].Bt in [mbtDividor, mbtDividorM]) and (IsDropDown <> -1) then begin
      Mi := TMenuItem.Create(Pm);
      Mi.Name := 'MMi_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(AButtons[i].Bt);
      SetMenuItem(Mi, AButtons[i], True);
      Pm.Items.Add(Mi);
      Mi.OnClick := AOnClick;
    end;
  end;
  if ls = -1 then
    Dividor.Destroy;
  if not Vertical then begin
    APanel.Height := 34 + 2;
  end;
end;

function TControlsHelper.GetSpeedBtn(Owner: TComponent; Tag: Integer; ASuffix: string = ''): TSpeedButton;
//возвращает SpeedButton с данным тэгом в имени, созданный процедурой CreateGridBtns
begin
  Result := TSpeedButton(Owner.FindComponent('Bt_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(Tag)));
end;

procedure TControlsHelper.CreateGridMenu(AForm: TForm; Pm: TPopupMenu; AButtons: TmybtArr; AButtonsState: TVarDynArray; AOnClick: TNotifyEvent; ASuffix: string = '');
//устанавливает SpeedButton.Enabled с данным тэгом в имени, созданный процедурой CreateGridBtns
var
  i, j, k, L, m: Integer;
  Btn: TSpeedButton;
  Dividor: TBevel;
  ls: Integer;
  b, b1, blast: Boolean;
  mi, mi1: TMenuItem;
  isSubMenu: Integer;
begin
  L := 5;
  ls := 0;
  isSubMenu := -1;
  for i := 0 to High(AButtons) do begin
    if (VarType(AButtonsState[i]) and VarTypeMask = varBoolean) then begin
      b := AButtonsState[i];
      if AButtons[i].bt = mbtTest then
        b := AButtonsState[i];
      blast := b;
    end
    else
      b := blast;
    if (AButtons[i].Bt = mbtDividor) and (ls > 0) then begin
      mi := TMenuItem.Create(Pm);
      mi.Caption := '-';
      Pm.Items.Add(mi);
    end;
    if (AButtons[i].Bt = mbtDividorM) then begin
      if isSubMenu = -1 then
        isSubMenu := i + 1
      else
        isSubMenu := -1;
    end;
    if b and not (AButtons[i].Bt = mbtDividor) and not (AButtons[i].Bt = mbtDividorM) then begin
      b1 := True;
      for j := 0 to i - 1 do
        if AButtons[i].Bt = AButtons[j].Bt then begin
          b1 := False;
          Break;
        end;
      if b1 then begin
        mi := TMenuItem.Create(Pm);
{        if isSubMenu = -1
          then Mi:=TMenuItem.Create(Pm)
          else Mi:=TMenuItem.Create(mi1);}
        //Mi.Caption:= AButtons[i].Caption;
        //Mi.Tag:=AButtons[i].Bt;
//        Pm.Items.Add(Mi);
        if isSubMenu = i then begin
          mi1 := mi;
          Pm.Items.Add(mi1);
          mi1.Name := 'MiSub_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(AButtons[i].Bt);
          SetMenuItem(mi1, AButtons[i], True);
          mi1.Tag := 0;
        end
        else begin
          mi.Name := 'Mi_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(AButtons[i].Bt);
          SetMenuItem(mi, AButtons[i], True);
          if isSubMenu = -1 then
            Pm.Items.Add(mi)
          else
            mi1.Add(mi);
          mi.OnClick := AOnClick;
        end;
        ls := 1;
      end;
    end;
  end;
//  if ls = -1 then Dividor.Destroy;
end;

procedure TControlsHelper.SetSpeedBtnEnabled(Owner: TComponent; Tag: Integer; Enabled: Boolean = True);
//устанавливает SpeedButton.Enabled с данным тэгом в имени, созданный процедурой CreateGridBtns
var
  Btn: TSpeedButton;
begin
  Btn := GetSpeedBtn(Owner, Tag);
  if Btn <> nil then
    Btn.Enabled := Enabled;
end;

procedure TControlsHelper.SetBtnAndMenuEnabled(Owner: TComponent; Pm: TPopupMenu; Tag: Integer; Enabled: Boolean = True; ASuffix: string = '');
//устанавливает SpeedButton.Enabled с данным тэгом в имени, созданный процедурой CreateGridBtns
//НЕВЕРНО работет если есть два набора кнопок или два меню, с префиксом в тэге
var
  Btn: TSpeedButton;
  Mi: TMenuItem;
begin
  Btn := GetSpeedBtn(Owner, Tag, ASuffix);
  //Btn := TSpeedButton(Owner.FindComponent('Bt_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(Tag)));
  if Btn <> nil then
    Btn.Enabled := Enabled;
  if Pm <> nil then begin
    Mi := TMenuItem(Pm.FindComponent('Mi_' + S.IIf(ASuffix = '', '', ASuffix + '_') + IntToStr(Tag)));
    if Mi <> nil then
      Mi.Enabled := Enabled;
  end;
end;

procedure TControlsHelper.SetMenuItem(Btn: TMenuItem; const BtnProps: TmybtRec; UsePicture: Boolean = False; Caption: string = '');
//настраивает уже созданную МенюИтем по данным записи для кнопки (используется тот же формат записей чяято и для кнопки)
var
  ic: TBitmap;
  h, w: Integer;
begin
  try
    Btn.Caption := S.IIf(Caption = '', BtnProps.Caption, Caption);
    Btn.Bitmap := nil;
    if UsePicture then begin
      //приходится делать перерисовкой,Ю иначе глюки отображения
      ic := tbitmap.create;
      h := 20;
      //загрузим изображение, размер будет или 16 или 20
      Module.SetBitmapFromResource(ic, PChar(BtnProps.Pict));
      //если не найдено, загрузим пустой прозрачное (розовое) изображение, иначе эти пункты в меню визуально сдвигаются влево
      if ic.height = 0 then
        Module.SetBitmapFromResource(ic, PChar('empty'));
      //получим высоту
      h := ic.Height;
      //установим размеры
      ic.SetSize(h * 2, h);
      Btn.Bitmap := ic; //.Canvas.Draw(0,0,ic);
      Btn.Bitmap.SetSize(h, h);
      Btn.Bitmap.Canvas.Draw(0, 0, ic);
      if BtnProps.ShortCut <> 0
      then  Btn.ShortCut:=BtnProps.ShortCut; //  ShortCut(VK_F1, [ssCtrl]);
    end;
    if Btn.Tag = 0 then
      Btn.Tag := BtnProps.Bt;
  finally
  end;
end;


function TControlsHelper.GetControlValuesArr2(F: TForm; Parent: TComponent; IncludeNames, ExcludeNames: TVarDynArray): TVarDynArray2;
//формируем массив наименований и значений компонентов с указанной формы, и указанным родителем (или всех, если nil)
//если передан массив IncludeNames, то формируем только по этим компонентам
//если передан ExcludeNames, то эти компоненты исключаем
//регистр имен компонентов значений не имеет, но в выходном массиве они будут в верхнем регистре
//получим массив виде [[NAME1, value1], [NAME2, value2]]
var
  i: Integer;
  c: TControl;
  b: Boolean;
  n, st: string;
  v: Variant;
begin
  Result := [];
  for i := 0 to High(IncludeNames) do
    IncludeNames[i] := UpperCase(IncludeNames[i]);
  for i := 0 to High(ExcludeNames) do
    ExcludeNames[i] := UpperCase(ExcludeNames[i]);
  //если перебирать Components, те переберем все компонеты формы, если Controls то только непосредственно на ней, а не на дочерних элементах
  for i := 0 to F.ComponentCount - 1 do begin
    c := TControl(F.Components[i]);
    if (c is TLabel) then
      Continue;
    b := (Parent = nil) or (c.Parent = Parent);
    if b then
      if (Length(IncludeNames) > 0) then begin
        b := A.InArray(UpperCase(F.name), IncludeNames);
      end
      else if (Length(ExcludeNames) > 0) then begin
        b := not A.InArray(UpperCase(F.name), ExcludeNames);
      end;
    if b then begin
      v := GetControlValue(c);
      if not VarIsEmpty(v) then begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := [c.Name, GetControlValue(c)];
      end;
    end;
  end;
end;

//установим значений контролов на форме из переданного двухмерного массива
//в формате возврата GetControlValuesArr2
procedure TControlsHelper.SetControlValuesArr2(F: TForm; v: TVarDynArray2);
var
  i: Integer;
  c: TControl;
  v0, v1: Variant;
begin
  for i := 0 to High(v) do begin
    if Length(v[i]) < 2 then
      Continue;
    c := TControl(F.FindComponent(v[i][0]));
    if c <> nil then begin
      v0 := GetControlValue(c);
      SetControlValue(c, v[i][1]);
      v1 := GetControlValue(c);
      //онклик/ончейнж не вызовется если значение контрола не изменилось, но вызовется, если изменилось;
      //так как событие может использоваться для утановки чего/либо, вызовем вручную, если изменений не было,
      //чтобы сработало в любом случае
      if VarToStr(v0) = VarToStr(v1) then begin
        if (c is TDbCheckBoxEh) and Assigned(TDbCheckBoxEh(c).OnClick) then
          TDbCheckBoxEh(c).OnClick(c);
        if (c is TDbEditEh) and Assigned(TDbEditEh(c).OnChange) then
          TDbEditEh(c).OnChange(c);
      end;
    end;
  end;
end;

function TControlsHelper.SerializeControlValuesArr2(v: TVarDynArray2): string;
//сериализает массив возврата GetControlValuesArr2
//[[NAME1, value1], [NAME2, value2]]
//в строку   NAME1#1value1#0NAME2#1value2#0
//если в значенийя массив присутствуют Chr(1) или Chr(2), то результата будут неверным!!!
//ВАЖНО!!!
//после чтения из БД (или при записи?) - (а не после чтения из настроечного файла!) крайние справа в строке записываемого параметра #1 и #2 удаляются!!!
//также будут удалены пробелы в колнце строки
var
  i, j: Integer;
  c: TControl;
  b: Boolean;
  n, st, st1, st2: string;
  ch1, ch2: char;
begin
  Result := '';
  st1 := '';
  for i := 0 to High(v) do begin
    st1 := st1 + VarToStr(v[i][0]) + #2 + VarToStr(v[i][1]) + #1;
  end;
  Result := copy(st1, 1, length(st1) - 1);
//  Result:=''''+copy(st1, 1, length(st1)-1)+'''';
end;

function TControlsHelper.DeSerializeControlValuesArr2(st: string): TVarDynArray2;
//возвращает массив по строке, созданной SerializeControlValuesArr2
var
  i, j: Integer;
  v1, v2: TStringDynArray;
begin
  Result := [];
//  v1:=Ah..ExplodeV(copy(st, 2, length(st)-2), #1);
  v1 := A.ExplodeS(st, #1);
  for i := 0 to High(v1) do begin
    v2 := A.ExplodeS(v1[i], #2);
    if Length(v2) = 2 then begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := [v2[0], v2[1]];
    end;
  end;
end;

function TControlsHelper.GetFindControlValue(Form: TForm; Name: string): Variant;
//найти контрол на форме и получить значение в вариант, если не найден будет ''
begin
  Result := GetControlValue(TControl(Form.FindComponent(Name)))
end;

function TControlsHelper.GetFindControlText(Form: TForm; Name: string): Variant;
//найти контрол на форме и получить значение в string, если не найден будет ''
begin
  Result := VarToStr(GetFindControlValue(Form, Name));
end;

procedure TControlsHelper.AddToComboBoxEh(DBComboboxEh: TDBComboboxEh; v: TVarDynArray2; Append: Boolean = False);
//добавляет значения в комбобокс из массива [[value1,key1,condition1],[value2,...
//где в массивах обязателен только нулевой элемент
var
  res, i, j: Integer;
begin
  if not Append then begin
    DBComboboxEh.Items.Clear;
    DBComboboxEh.KeyItems.Clear;
  end;
  for i := 0 to High(v) do
    if (High(v[i]) < 2) or (High(v[i]) >= 2) and (v[i][2] = True) then begin
      DBComboboxEh.Items.Add(v[i][0]);
      if High(v[i]) >= 1 then
        DBComboboxEh.KeyItems.Add(VarToStr(v[i][1]));
    end;
end;

function TControlsHelper.DteValueIsDate(DBDateTimeEditEh1: TDBDateTimeEditEh): Boolean;
//проверяет, является ли датой текущее значение контрола типа DBDateTimeEditEh
begin
  result := (length(DBDateTimeEditEh1.Text) = 10) and (pos(' ', DBDateTimeEditEh1.Text) = 0) and (DBDateTimeEditEh1.Value <> null) and (S.IsDateTime(DBDateTimeEditEh1.Value, 'd'));
end;

procedure TControlsHelper.DotRedLine(Control: TControl; DrawLine: Boolean = True);
//отрисовать красную линию подчеркивания в указанном контроле для индикации ошибки
var
  Canvas: TControlCanvas;
begin
//DrawLine:=True;
  Canvas := TControlCanvas.Create;
  try
    Canvas.Control := Control;
    with Canvas, ClipRect do begin
      if DrawLine then
        Pen.Color := RGB(224, 0, 0)
      else
      Pen.Color := clWindow;
      Pen.Style := psDot;
      MoveTo(Left, Bottom - 2);
      LineTo(Right, Bottom - 2);
      MoveTo(Left, Bottom - 1);
      LineTo(Right, Bottom - 1);
    end;
  finally
    Canvas.Free;
  end;
end;

procedure TControlsHelper.SetBtn(Btn: TBitBtn; const BtnProps: TmybtRec; SmallBtn: Boolean = False; Caption: string = '');
//Устанавливает параметры кнопки типа TBitBtn
begin
  try
  //  Btn.Height:=40; //S.IIf(SmallBtn, , False);
    if SmallBtn then
      Btn.Width := Btn.Height;
    Btn.Caption := S.IIf(SmallBtn, '', S.IIf(Caption = '', BtnProps.Caption, Caption));
    Btn.Hint := S.IIf(not SmallBtn, '', S.IIf(Caption = '', BtnProps.Caption, Caption));
    Btn.ShowHint := S.IIf(SmallBtn, True, False);
    Btn.Glyph := nil;
//    Btn.NumGlyphs:=2;
    Module.SetBitmapFromResource(Btn.Glyph, PChar(BtnProps.Pict + ''));
    if Btn.Glyph.Width > 24 then
      Btn.NumGlyphs := 2
    else
      Btn.NumGlyphs := 1;
  finally
  end;
end;

procedure TControlsHelper.SetBtn(ABtn: TControl; ABtnId: Integer; AOnClick: TNotifyEvent = nil; ABtnType: Integer =cbttBNormal; AWidth: Integer = 0; AGroup: Integer = 0; ACaption: string = ''; APicture: string = '');
//Устанавливает параметры кнопки типа TBitBtn или TSpeedButto,
//паредается кнопка, айди btnXXX (если есть в дефолтных то параметры берутся из него), событие нажатия (если nil то не изменяеится),
//тип cbttSBig,cbttSSmall,cbttBNormal,cbttBSmall,cbttBCtrl или Int - cbttBBig с шириной этим числом,
//но ширина может быть также задана явно (не 0), тогда она имеет приоритет
//если ширина кнопки больше 42 то заголовок указывается явно
//также для TSpeedButton устанавливается GroupIndes = AGroup, если оно меньше 100 то кнопки работают отдельно, иначе групповыми
var
  IsBitBtn: Boolean;
  i: Integer;
  va: TVarDynArray;
begin
  if ABtn is TSpeedButton
    then IsBitBtn := False
    else if ABtn is TBitBtn
      then IsBitBtn := True
      elsE Exit;
  if IsBitBtn and (ABtnType in [cbttSBig,cbttSSmall]) then ABtnType:= cbttBNormal;
  if not IsBitBtn and not(ABtnType in [cbttSBig,cbttSSmall]) then ABtnType:= cbttSBig;
  ABtn.Tag:= ABtnID;
  for i:= 0 to High(myDefaultBtns) do
    if myDefaultBtns[i].Bt = ABtnId then begin
      if ACaption ='' then ACaption:= myDefaultBtns[i].Caption;
      if APicture ='' then APicture:= myDefaultBtns[i].Pict;
      Break;
    end;
  ABtn.Height:= S.Decode([ABtnType, cbttSBig, MY_FORMPRM_SPEEDBTN_DEF_H, cbttBCtl, MY_FORMPRM_CONTROL_H, MY_FORMPRM_BTN_DEF_H]);
  ABtn.Width:= S.Decode([ABtnType, cbttSBig, MY_FORMPRM_SPEEDBTN_DEF_H, cbttSSmall, MY_FORMPRM_BTN_DEF_H, cbttBSmall, MY_FORMPRM_BTN_DEF_H, cbttBNormal, MY_FORMPRM_BTN_DEF_W, cbttBCtl, MY_FORMPRM_CONTROL_H, ABtnType]);
  if AWidth <> 0 then ABtn.Width:=AWidth;
  if Assigned(AOnClick)
    then TSpeedButton(ABtn).OnClick := AOnClick;
  if IsBitBtn then begin
    TBitBtn(ABtn).Glyph := nil;
    if APicture <> '' then begin
      Module.SetBitmapFromResource(TBitBtn(ABtn).Glyph, PChar(APicture + S.IIfStr(ABtn.Height >= MY_FORMPRM_SPEEDBTN_DEF_H, '32')));
      TBitBtn(ABtn).NumGlyphs := S.IIf(TBitBtn(ABtn).Glyph.Width > 24, 2, 1);
    end;
  end
  else begin
    TSpeedButton(ABtn).Glyph := nil;
    if APicture <> '' then begin
      Module.SetBitmapFromResource(TSpeedButton(ABtn).Glyph, PChar(APicture + S.IIfStr(ABtn.Height >= MY_FORMPRM_SPEEDBTN_DEF_H, '32')));
      TSpeedButton(ABtn).NumGlyphs := S.IIf(TSpeedButton(ABtn).Glyph.Width > 24, 2, 1);
      if Abs(AGroup) > 0 then begin
        TSpeedButton(ABtn).GroupIndex:= Abs(AGroup);
        TSpeedButton(ABtn).AllowAllup:= Abs(AGroup) <= 100
      end;
    end;
    TSpeedButton(ABtn).Flat := True;
  end;
  va:=A.Explode(ACaption, ';');
  TBitBtn(ABtn).Caption:= S.IIfStr(not(ABtnType in [cbttSBig, cbttBSmall, cbttSSmall, cbttBCtl]), va[0]);
  if TBitBtn(ABtn).width > 42
    then TBitBtn(ABtn).Caption:= va[0];
  TSpeedButton(ABtn).Hint:= S.IIfStr(ABtnType in [cbttSBig, cbttBSmall, cbttSSmall, cbttBCtl], va[0]);
  if Length(va) > 1
    then TSpeedButton(ABtn).Hint:= va[1];
  TBitBtn(ABtn).ShowHint:= TBitBtn(ABtn).Hint <> '';
end;


procedure TControlsHelper.SetSpeedButton(Btn: TSpeedButton; const BtnProps: TmybtRec; SmallBtn: Boolean = False; Caption: string = '');
begin
  try
  //  Btn.Height:=40; //S.IIf(SmallBtn, , False);
    if SmallBtn then
      Btn.Width := Btn.Height;
    Btn.Caption := S.IIf(SmallBtn, '', S.IIf(Caption = '', BtnProps.Caption, Caption));
    Btn.Hint := S.IIf(not SmallBtn, '', S.IIf(Caption = '', BtnProps.Caption, Caption));
    Btn.ShowHint := S.IIf(SmallBtn, True, False);
    Btn.Glyph := nil;
    Btn.NumGlyphs := 2;
    Btn.Flat := True;
    Module.SetBitmapFromResource(Btn.Glyph, PChar(BtnProps.Pict + '32'));
    if Btn.Tag = 0 then
      Btn.Tag := BtnProps.Bt;
  finally
  end;
end;

procedure TControlsHelper.AlignControlsL(Controls: TControlArray);
var
  i, j: Integer;
  c: TControl;
begin
  j := Controls[0].Left;
  for i := 0 to High(Controls) do begin
    c := Controls[i];
    c.Left := j;
    if c.Visible then
      j := j + c.Width + DefHorizMargin;
  end;
end;

procedure TControlsHelper.AlignControlsR(Controls: TControlArray);
var
  i, j: Integer;
  c: TControl;
begin
  j := Controls[High(Controls)].Left + Controls[High(Controls)].Width;
  for i := High(Controls) downto 0 do begin
    c := Controls[i];
    c.Left := j - c.Width;
    if c.Visible then
      j := j - c.Width - DefHorizMargin;
  end;
end;

procedure TControlsHelper.CreateBtns(AForm: TForm; APanel: TPanel; AButtons: TByteSet);
//++убрать
var
  Btns: array of TmybtRec;
  i, j, k, l: Integer;
  Buttons: array of TControl;
begin
  APanel.Height := 28;
  SetLength(Buttons, 15);
  SetLength(Btns, 15);
  for i := 0 to High(Buttons) do
    Btns[i] := mybtNone;
  if mbtRefresh in AButtons then
    Btns[0] := mybtRefresh;
//  if (btnFirst in AButtons)and UseNavigateButtons then Btns[1]:=mybtFirst;
//  if (btnLast in AButtons) and UseNavigateButtons then Btns[2]:=mybtLast;
  Btns[3] := mybtDividor;
  if mbtView in AButtons then
    Btns[4] := mybtView;
  if mbtAdd in AButtons then
    Btns[5] := mybtAdd;
  if mbtCopy in AButtons then
    Btns[6] := mybtCopy;
  if mbtEdit in AButtons then
    Btns[7] := mybtEdit;
  if mbtDelete in AButtons then
    Btns[8] := mybtDelete;
  if mbtApply in AButtons then
    Btns[9] := mybtApply;
  if mbtCancel in AButtons then
    Btns[10] := mybtCancel;
  Btns[11] := mybtDividor;
  if mbtGridFilter in AButtons then
    Btns[12] := mybtGridFilter;
//  Btns[13]:=mybtDividor;
  if mbtPrint in AButtons then
    Btns[13] := mybtPrint;
  if mbtGridSettings in AButtons then
    Btns[14] := mybtGridSettings;
  l := 5;
  k := 0;
  for i := 0 to High(Buttons) do begin
    if Btns[i].Bt = mbtDividor then begin
      k := i - 1;
      while (k >= 0) and (Btns[k].Bt = mbtNone) do
        Dec(k);
      if (k >= 0) and (Btns[k].bt <> mbtDividor) then
        l := l + 0; //7;
    end
    else if Btns[i].Bt <> mbtNone then begin
//          Buttons[i]:= TBitBtn.Create(Apanel);
      Buttons[i] := TSpeedButton.Create(APanel);
      Buttons[i].Parent := APanel;
      Buttons[i].Tag := Btns[i].Bt;
//          SetBtn(Buttons[i] as TBitBtn, Btns[i], True);
      SetSpeedButton(Buttons[i] as TSpeedButton, Btns[i], True);
      Buttons[i].height := 34;
      Buttons[i].Width := Buttons[i].height;
      Buttons[i].Left := l;
      l := Buttons[i].Left + Buttons[i].Width + 1;
//          TBitBtn(Buttons[i]).OnClick := Bt_Click;
    end;
  end;
//  APanel.Height:=Buttons[0]. Height + 2;
  APanel.Height := 34 + 2;
end;

procedure TControlsHelper.SetDialogForm(Form: TForm; Mode: TDialogType; Caption: string);
//настривает диалоговое окно стандартного типа (добавить/изменить/удалить/просмотреть)
//задает заголовок - переданный плюс через - режим дилога
//настраивает кнопки (для просмотра - закрыть, для удаления - удалить и отмена, иначе Ок и отмена)
var
  st: string;
  c: TComponent;
begin
  SetdialogCaption(Form, Mode, Caption);
  c := Form.FindComponent('Bt_Ok');
  if c = nil then
    c := Form.FindComponent('btnOk');
  if c <> nil then
    if Mode <> fDelete
      then Cth.SetBtn((c as TBitBtn), mybtOk, False)
      else Cth.SetBtn((c as TBitBtn), mybtDelete, False);
  (c as TBitBtn).Visible := (Mode <> fView);
  c := Form.FindComponent('Bt_Cancel');
  if c = nil then
    c := Form.FindComponent('btnCancel');
  if c <> nil then
    if Mode <> fView
      then Cth.SetBtn((c as TBitBtn), mybtCancel, False)
      else Cth.SetBtn((c as TBitBtn), mybtViewClose, False);
end;

procedure TControlsHelper.SetDialogCaption(Form: tobject; Mode: TDialogType; Caption: string);
//настраивает заголовок диалогового окна стандартного типа (добавить/изменить/удалить/просмотреть)
//если заголовок начинается на '~', то к нему ничего не добавляется, символ удаляется
var
  St: string;
begin
  if not (Form is TForm) then Exit;
  if Copy(Caption, 1, 1) = '~' then begin
    TForm(Form).Caption := Copy(Caption, 2);
    Exit;
  end;
  St := FModeToCaption(Mode);
  TForm(Form).Caption := Caption + S.IIfStr(St <> '', ' - ' + St);
end;

function TControlsHelper.FModeToCaption(fMode: TDialogType): string;
//получает строку соответствующую типу операции для диалогового окна
begin
  case fMode of
    fAdd:
      Result := 'Добавить';
    fCopy:
      Result := 'Скопировать';
    fEdit:
      Result := 'Изменить';
    fView:
      Result := 'Просмотр';
    fDelete:
      Result := 'Удалить';
  else
    Result := '';
  end;
end;

function TControlsHelper.BtnModeToFMode(btn: Integer): TDialogType;
//возвращает соответствие между тэгами кнопок и вызываемыми ими режимами диалога
begin
  Result := fNone;
  case btn of
    mbtView:
      Result := fView;
    mbtEdit:
      Result := fEdit;
    mbtAdd:
      Result := fAdd;
    mbtCopy:
      Result := fCopy;
    mbtDelete:
      Result := fDelete;
  end;
end;

function TControlsHelper.FModeToBtnMode(fMode: TDialogType): Integer;
//возвращает соответствие между тэгами кнопок и вызываемыми ими режимами диалога
begin
  Result := -1;
  case fMode of
    fView:
      Result := mbtView;
    fEdit:
      Result := mbtEdit;
    fAdd:
      Result := mbtAdd;
    fCopy:
      Result := mbtCopy;
    fDelete:
      Result := mbtDelete;
  end;
end;

function TControlsHelper.FModeToBtnRec(fMode: TDialogType): TMyBtRec;
//возвращает запись дефолтной для вызова данного типа диалога кнопки
begin
  Result := mybtCancel;
  case fMode of
    fView:
      Result := mybtView;
    fEdit:
      Result := mybtEdit;
    fAdd:
      Result := mybtAdd;
    fCopy:
      Result := mybtCopy;
    fDelete:
      Result := mybtDelete;
  end;
end;

function TControlsHelper.SetInfoIconText(Form: TForm; Info: TVarDynArray2): string;
//задается текст подсказки
//исходные данные передаются в массиве вида [[text, active],[text2],[text3,active3]]
//также заменяются дефолтные подстроки
//передается форма для взятия заголовка
var
  i: Integer;
  fMode: TDialogType;
begin
  try
    fMode := fNone;
    Result := '';
    for i := 0 to High(Info) do begin
      if (High(Info[i]) = 0) or (Info[i][1] = True) then
        Result := Result + Info[i][0];
    end;
    if Form <> nil then begin
      Result := StringReplace(Result, 'caption', Form.Caption + #13#10, []);
      if Form is TFrmBasicMdi then
        fMode := TFrmBasicMdi(Form).Mode;
    end
    else
      Result := StringReplace(Result, 'caption', '', []);
    Result := StringReplace(Result, 'refview', 'Вы можете только просматривать данные в этом документе.', []);
    Result := StringReplace(Result, 'refedit', 'Используйте кнопки над таблицей для операций с записями. Также Вы можеть выбрать дейтвие в меню по правому клику мыши.'#13#10, []);
    Result := StringReplace(Result, 'refoptions', 'Настройте внешний вид и функционал таблицы для удобства работы, нажав на кнопку "Настроить вид"'#13#10, []);
    Result := StringReplace(Result, 'reffilter', 'Используйте кнопку "фильтр" для настройки загрузки только нужных данных, что также может ускорить работу.'#13#10, []);
    if fMode in [fAdd, fCopy, fEdit] then begin
      Result := StringReplace(Result, 'dlgedit', 'Введите или откорректируйте требуемые данные. В случае недопустимых значений, поля ввода будут отмечены красным.'#13#10, []);
      Result := StringReplace(Result, 'dlgactive', 'Поставьте галочку "Используется", чтобы эта запись была доступна при создании новых документов.'#13#10, []);
    end;
    Result := StringReplace(Result, '`', ''#13#10, []);
  finally
  end;
end;

procedure TControlsHelper.SetInfoIcon(Pict: TImage; Info: string; Width: Integer = 20);
//подготавливает картинку-хелп
//для картинки задаются размеры, текст подсказки (если он пут, то картинка скрывается)
//обработчики событий устанавливаются, они глобальные, не требуются у родителя
begin
  Pict.Visible := (Info <> '');
  Pict.Width := Width;
  Pict.Height := Pict.Width;
  Pict.Stretch := True;
  Module.SetBitmapFromResource(Pict.Picture.Bitmap, PChar('infopict32'));
  Pict.Hint := Info;
  Pict.OnMouseEnter := Module.InfoOnMouseEnter;
  Pict.OnMouseLeave := Module.InfoOnMouseLeave;
  Pict.OnClick := Module.InfoOnClick;
end;

procedure TControlsHelper.SetWaitCursor(Wait: Boolean = True);
//устанавливает или сбрасывае курсов в  виде песочныч часво
begin
  if Wait then
    Screen.Cursor := crHourGlass
  else
    Screen.Cursor := crDefault;
end;




//==============================================================================
//  TTableHelper
//==============================================================================

function TTableHelper.AppendGrid(DBGridEh1: TDBGridEh; Table: string; IDs: TVarDynArray2): Integer;
var
  i, j: Integer;
  GetRecSQL, UpdateSQL, DeleteSQL, InsertSQL: string;
  st: string;
  Dd: TADODataDriverEh;
  Mt: TMemTableEh;
  SearchOptions: TLocateOptions;
  IDField: string;
begin
//  try
  Mt := TMemTableEh(DBGridEh1.DataSource.DataSet);
  Dd := TADODataDriverEh(Mt.DataDriver);
  GetRecSQL := Dd.GetrecSQL.Text;
  UpdateSQL := Dd.UpdateSQL.Text;
  DeleteSQL := Dd.DeleteSQL.Text;
  InsertSQL := Dd.InsertSQL.Text;
  IDField := 'id_dimension'; //Dd.KeyFields
 // IDField:=Dd.KeyFields;
//  Dd.GetrecSQL.Text:='select * from ' + Table + ' where ' + Dd.KeyFields + ' = :' + Dd.KeyFields;
  Dd.UpdateSQL.Text := 'select 1 from dual';
  Dd.DeleteSQL.Text := 'select 1 from dual';
  Dd.InsertSQL.Text := 'select 1 from dual';
//  Dd.GetrecSQL.Text:='select * from ' + Table + ' where ' + IDField + '=29';//' = :' + Dd.KeyFields;
  Dd.GetrecSQL.Text := 'select * from ' + Table + ' where ' + IDField + '=' + VarToStr(IDs[i][0]); //' = :' + Dd.KeyFields;
  Mt.ReadOnly := False;
  Mt.Edit;
  if True then begin
    for i := 0 to high(IDs) do begin
      if not Mt.Locate(IDField, IDs[i][0], SearchOptions) then begin
        if IDs[i][1] <> -1 then begin
          Mt.Append;
          Dd.InsertSQL.Text := 'select 1 from dual';
          Mt.Post;
//              Dd.GetrecSQL.Text:='select * from ' + Table + ' where ' + IDField + '=' + VarToStr(IDs[i][0]);//' = :' + Dd.KeyFields;
            //  Mt.FieldByName(IDField).Value:=Ids[i][0];
        end;
      end
      else begin
        if IDs[i][1] <> -1 then begin
          Mt.RefreshRecord;
        end
        else begin
          Mt.Delete;
        end;
      end;
    end;
  end;
  if not (Mt.State in [dsBrowse]) then
    Mt.Post;
  Mt.ReadOnly := True;

//  if GetRecSQL then
{ MemTableEh1.Append;
  adodatadrivereh1.InsertSQL.text:='select 1 from dual';
  MemTableEh1.Post;
  adodatadrivereh1.GetrecSQL.text:='select * from pas3 where id_dimension = 1000';}
//  except
//  end;
  Dd.GetrecSQL.Text := GetRecSQL;
  Dd.UpdateSQL.Text := UpdateSQL;
  Dd.DeleteSQL.Text := DeleteSQL;
  Dd.InsertSQL.Text := InsertSQL;
end;

procedure TTableHelper.Post(MemTableEh: TMemTableEh);
//выдает Пост для таблицы, если статус dsEdit or dsInsert
begin
  if MemTableEh.State in [dsInsert, dsEdit] then
    MemTableEh.Post;
end;

procedure TTableHelper.PostAndEdit(MemTableEh: TMemTableEh);
//выдает Пост для таблицы, если статус dsEdit or dsInsert, и после переводит ее в состояние Edit
begin
  if MemTableEh.State in [dsInsert, dsEdit] then
    MemTableEh.Post;
  MemTableEh.Edit;
end;

procedure TTableHelper.AddGridColumn(DBGridEh1: TDBGridEh; aFieldName: string; aCaption: string; aWidth: Integer; aVisible: Boolean);
//добавляет столбец в memtable и в грид
begin
  DBGridEh1.Columns.Add.Title.Caption;
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].Title.Caption := aCaption;
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].Width := aWidth;
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].Visible := aVisible;
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].FieldName := aFieldName;
end;

procedure TTableHelper.AddTableColumn(DBGridEh1: TDBGridEh; aFieldName: string; aFieldType: TFieldType; aFieldSize: Integer; aCaption: string; aWidth: Integer; aVisible: Boolean = True; aAutoFitColWidth: Boolean = False; aWordWrap: Boolean = False);
//добавляет столбец в memtable и в грид
//если заголовок начинается с пробела, то он располагается вертикально
//как минимум при передаче параметра равным 50 происходит сбой - колонки расползаются в длину намного больше, непонятно что это такое. пока сделал такой хак.
var
  AColWidth: Integer;
begin
  DBGridEh1.Columns.Add.Title.Caption;
  TMemTableEh(DBGridEh1.DataSource.Dataset).FieldDefs.Add(aFieldName, aFieldType, aFieldSize, False);
  aWidth := aWidth + 1;
  if Copy(aCaption, 1, 1) = ' ' then
    DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].Title.Orientation := tohVertical;
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].Width := aWidth;
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].Title.Caption := Trim(aCaption){+ inttostr(aWidth)};
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].Visible := aVisible;
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].FieldName := aFieldName;
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].AutoFitColWidth := aAutoFitColWidth;
  DBGridEh1.Columns[DBGridEh1.Columns.Count - 1].WordWrap := aWordWrap;
end;

procedure TTableHelper.CreateTableGrid(DBGridEh1: TDBGridEh; ADefaultVis: Boolean; AFilter: Boolean; ASTFilter: Boolean; ASort: Boolean; const AColumns: TVarDynArray2; AValues: TVarDynArray2; AMemTableFields: string; AArrayColumns: string);
    //заполняет пареаметры таблицу DBGridEh и ее MemTable
    //передаются параметры столбцов в 2х мерном массиве
    //поле, тип данных, размер данных, заголовок (может с " ", "_", "|"), отображаемая ширина, видимость, автоподгонка ширины, перенос для столбца по словам
    //в зависимости от параметров заголовков корректируется заголовок таблицы (вертикальные, многострочные, скрываются столбцы с _
    //если установлен ADefaultVis, то применяются дефолтные настройки (раскраска, индикаторный столбец...)
    //задаются требования установить фильтр в строке, столбцах и сортировку
    //если передан непустой двухмерный массив, то пытается заполнить данными из него, по порядку массива и полей если не переданы AColumns и AValues
    //если последние переданы, то должну содержать первый список полей через ; а второй номера столбцов в исходном массиве через ;
var
  i, j: Integer;
  b1, b2, b3: Boolean;
  f, p: TVarDynArray;
begin
  if DBGridEh1.DataSource = nil then begin
    DBGridEh1.DataSource := TDataSource.Create(DBGridEh1.Owner);
    DBGridEh1.DataSource.Name := 'DataSource_' + DBGridEh1.Name + '_autocreated';
  end;
  if DBGridEh1.DataSource.DataSet = nil then begin
    DBGridEh1.DataSource.DataSet := TMemTableEh.Create(DBGridEh1.Owner);
    DBGridEh1.DataSource.Name := 'MemTableEh_' + DBGridEh1.Name + '_autocreated';
  end;
  TMemTableEh(DBGridEh1.DataSource.Dataset).Close;
  TMemTableEh(DBGridEh1.DataSource.Dataset).FieldDefs.Clear;
  DBGridEh1.AutoFitColWidths := False;
  DBGridEh1.OptionsEh := DBGridEh1.OptionsEh - [dghAutoFitRowHeight];
  for i := 0 to High(AColumns) do begin
    AddTableColumn(DBGridEh1, AColumns[i][0], AColumns[i][1], AColumns[i][2], AColumns[i][3], AColumns[i][4], AColumns[i][5], AColumns[i][6], AColumns[i][7]);
    if AColumns[i][6] then
      b1 := True;
    if AColumns[i][7] then
      b2 := True;
    if Pos('|', AColumns[i][3]) > 0 then
      b3 := True;
  end;
  TMemTableEh(DBGridEh1.DataSource.Dataset).CreateDataset;
  if b1 then
    DBGridEh1.AutoFitColWidths := True;
  if b2 then
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghAutoFitRowHeight];
  if b3 then
    DBGridEh1.TitleParams.MultiTitle := True;
  if ADefaultVis then
    Gh.SetGridOptionsDefault(DBGridEh1);
  Gh.SetGridOptionsMain(DBGridEh1, AFilter, ASTFilter, ASort);
  if Length(AValues) <> 0 then begin
    TMemTableEh(DBGridEh1.DataSource.Dataset).DisableControls;
    f := A.Explode(AMemTableFields, ';', True);
    p := A.Explode(AArrayColumns, ';', True);
    if (Length(f) = 0) or (Length(p) = 0) then begin
      for i := 0 to High(AValues) do begin
        TMemTableEh(DBGridEh1.DataSource.Dataset).Append;
        for j := 0 to min(TMemTableEh(DBGridEh1.DataSource.Dataset).FieldCount - 1, High(AValues[i])) do
          TMemTableEh(DBGridEh1.DataSource.Dataset).Fields[j].Value := AValues[i, j];
        TMemTableEh(DBGridEh1.DataSource.Dataset).Post;
      end;
    end
    else begin
      for i := 0 to High(AValues) do begin
        TMemTableEh(DBGridEh1.DataSource.Dataset).Append;
        for j := 0 to High(p) do
          TMemTableEh(DBGridEh1.DataSource.Dataset).FieldByName(f[j]).Value := AValues[i, S.VarToInt(p[j])];
        TMemTableEh(DBGridEh1.DataSource.Dataset).Post;
      end;
    end;
    TMemTableEh(DBGridEh1.DataSource.Dataset).First;
    TMemTableEh(DBGridEh1.DataSource.Dataset).EnableControls;
  end;
end;

function TTableHelper.LoadMemTableFromNamedArray(MemTableEh: TMemTableEh; Values: TNamedArr; ByFieldNames: Boolean = True; AClearTable: Boolean = True): Boolean;
var
  i, j: Integer;
  fld: TField;
begin
  Result := False;
  MemTableEh.ReadOnly := False;
//  MemTableEh.Edit;
  if AClearTable then
    MemTableEh.EmptyTable;
  if ByFieldNames then begin
    for i := 0 to Values.FieldsCount - 1 do begin
      if MemTableEh.FieldByName(Values.F[i]) = nil then
        raise Exception.Create('LoadMemTableFromNamedArray: поле ' + Values.F[i] + ' не найдено в MemTableEh');
    end;
    for i := 0 to High(Values.V) do begin
      MemTableEh.Append;
      for j := 0 to Values.FieldsCount - 1 do
        MemTableEh.FieldByName(Values.F[j]).Value := Values.V[i][j];
      MemTableEh.Post;
    end;
  end
  else begin
    for i := 0 to High(Values.V) do begin
      MemTableEh.Append;
      for j := 0 to Values.FieldsCount - 1 do
        MemTableEh.Fields[j].Value := Values.V[i][j];
      MemTableEh.Post;
    end;
  end;
  MemTableEh.First;
end;

function TTableHelper.LoadGridFromNamedArray(DBGridEh1: TDBGridEh; Values: TNamedArr; ByFieldNames: Boolean = True; AClearTable: Boolean = True): Boolean;
begin
  TMemTableEh(DBGridEh1.DataSource.Dataset).DisableControls;
  LoadMemTableFromNamedArray(TMemTableEh(DBGridEh1.DataSource.Dataset), Values, ByFieldNames, AClearTable);
  TMemTableEh(DBGridEh1.DataSource.Dataset).EnableControls;
end;

procedure TTableHelper.LoadGridFromVa2(DBGridEh1: TDBGridEh; AValues: TVarDynArray2; AMemTableFields: string; AArrayColumns: string; AClearTable: Boolean = True);
//(MemTableEh: TDBGridEh; AValues: TVarDynArray2; AMemTableFields: string; AArrayColumns: string; AClearTable: Boolean = True);
//загружает мемтейбл, являющийся источником данных дбгрида, из массива
//если переданы и AMemTableFields(через ;) и AArrayColumns(№ колонки массива через ;), то сопоставит поля и колонки массива,
//иначе загрузит грид один в один
var
  i, j: Integer;
  f, p: TVarDynArray;
  v : Variant;
begin
  if AClearTable then TMemTableEh(DBGridEh1.DataSource.Dataset).EmptyTable;
  if Length(AValues) <> 0 then begin
    TMemTableEh(DBGridEh1.DataSource.Dataset).DisableControls;
    f := A.Explode(AMemTableFields, ';', True);
    p := A.Explode(AArrayColumns, ';', True);
    if (Length(f) = 0) or (Length(p) = 0) then begin
      for i := 0 to High(AValues) do begin
        TMemTableEh(DBGridEh1.DataSource.Dataset).Append;
        for j := 0 to min(TMemTableEh(DBGridEh1.DataSource.Dataset).FieldCount - 1, High(AValues[i])) do
          TMemTableEh(DBGridEh1.DataSource.Dataset).Fields[j].Value := AValues[i, j];
        TMemTableEh(DBGridEh1.DataSource.Dataset).Post;
      end;
    end
    else begin
      for i := 0 to High(AValues) do begin
        TMemTableEh(DBGridEh1.DataSource.Dataset).Append;
        for j := 0 to High(p) do
          TMemTableEh(DBGridEh1.DataSource.Dataset).FieldByName(f[j]).Value := AValues[i, S.VarToInt(p[j])];
        TMemTableEh(DBGridEh1.DataSource.Dataset).Post;
      end;
    end;
    TMemTableEh(DBGridEh1.DataSource.Dataset).First;
    TMemTableEh(DBGridEh1.DataSource.Dataset).EnableControls;
  end;
end;


function TGridEhHelper.VeryfyCoumnEhValue(C: TColumnEh; NewValue: Variant; var CorrectValue: Variant): Boolean;
//проверка значения столбца DbGridEh, по правилам переданным в DynVar('verify'), с учетом типа данных столбца
//проверка производится по тем же правилам, что и для контролов
//для строк возможна коррекция значений

//для числа "min:max:fdigits:N:M"
//(min:max по умолчанию 0, fdigits - не более стольких десятичных цифр, N - не разрешать null, M - подгонять под границы /пока не реализовано/)

//для строки
//CVerify - min:max:digits:inult:validchars:invalidcars
//минимальное и максимальная длина строки
//4 - n - допустимо пустой значение
//4 - i - для комбобокса - значение должно быть в списке
//4 - u/l - для комбо и эдит - вводятся большие или маленькие буквы
//4 - t - трим для строки
//5 - инвалидные символы
//6 - валидные символы

//для даты
//(0) * - дата обязательна, не допускается пустое, но произвольная
//(0) инт  S.DateTimeToIntStr(Date) - нач дата
//(1) инт  кон. дата
//(2) если '-' то допустимо пустая дата

var
  i, j: Integer;
  v1: string;
  ver: TStringDynArray;
  st, st1, st2, st3: string;
  dt: TDateTime;
  dte: extended;
  b: Boolean;
  vt: string;
begin
  Result := True;
  v1 := Cth.GetDynProp(C, dpVerify);
//if c.FieldName = 'baseunit'
//  then;
  if v1 = '' then
    Exit;
  st := VarToStr(NewValue);
  vt := q.QGetDataTypeAsChar(C.Field.DataType);
  Result := S.VeryfyValue(vt, v1, st, CorrectValue);
end;

procedure TGridEhHelper.SetVeryfyCoumnEhRule(C: TColumnEh; CVerify: string = '');
begin
  Cth.SetDynProps(C, [[dpVerify, S.IIFStr(CVerify <> '', CVerify + ':::::::::')]]);
end;











function TControlsHelper.GetChildControls(Parent: TWinControl; Recursive: Boolean = True): TControlArray;
//найти все дочерние (по Parent) контролы родителя, если Recursive то и его дочерних элементов
//вернет массив контролов
var
  i : Integer;
  procedure Add(Control : TControl);
  var
    i : Integer;
  begin
    if Control is TWinControl then
    with TWinControl(Control) do
    for i := 0 to Controlcount-1 do
      Add(Controls[i]);
      if Control <> Parent  then
        Result:= Result + [TWinControl(Control)];
  end;
begin
 Result := [];
 if Recursive
   then Add(Parent)
   else
     for i := 0 to Parent.Controlcount-1 do
       Result:= Result + [TWinControl(Parent.Controls[i])];
end;

function TControlsHelper.GetChildControlNames(Parent: TWinControl; Recursive: Boolean = True): TVarDynArray;
//найти все дочерние (по Parent) контролы родителя, если Recursive то и его дочерних элементов
//вернет иена контролов
var
  i : Integer;
  procedure Add(Control : TControl);
  var
    i : Integer;
  begin
    if Control is TWinControl then
    with TWinControl(Control) do
    for i := 0 to Controlcount-1 do
      Add(Controls[i]);
      if Control <> Parent  then
        Result:= Result + [Control.Name];
  end;
begin
 Result := [];
 if Recursive
   then Add(Parent)
   else
     for i := 0 to Parent.Controlcount-1 do
       Result:= Result + [Parent.Controls[i].Name];
end;

function TControlsHelper.IsChildControl(Parent: TWinControl; Control: string; Recursive: Boolean = True): Boolean;
//проверить, является ли контрол дочерним (по Parent) элементом родителя, рекурсивно или нет
var
  i : Integer;
  cp: TComponent;
  c: TControl;
  procedure Test(Control : TControl);
  var
    i : Integer;
  begin
    Result:= Control.Parent = Parent;
    if Result or (Control.Parent = nil) or (Control.Parent = FrmMain)
      then Exit
      else Test(Control.Parent);
  end;
begin
 Result := False;
 if Parent is TForm
   then cp:= Parent.FindComponent(Control)
   else cp:= Parent.Owner.FindComponent(Control);
 if (cp = nil) or not (cp is TControl) then Exit;
 c:= TControl(cp);
 if Recursive
   then Test(C)
   else Result:= C.Parent = Parent;
end;

function TControlsHelper.IsChildControl(Parent: TWinControl; Control: TControl; Recursive: Boolean = True): Boolean;
//проверить, является ли контрол дочерним (по Parent) элементом родителя, рекурсивно или нет
var
  i : Integer;
  procedure Test(Control : TControl);
  var
    i : Integer;
  begin
    Result:= Control.Parent = Parent;
    if Result or (Control.Parent = nil) or (Control.Parent = FrmMain)
      then Exit
      else Test(Control.Parent);
  end;
begin
 Result := False;
 if Recursive
   then Test(Control)
   else Result:= Control.Parent = Parent;
end;

procedure TControlsHelper.MakePanelsFlat(Parent: TWinControl; Exclude: TControlArray; Recursive: Boolean = True; Flat: Boolean = True; NoCaption: Boolean = True);
//сделать все дочерние панели (кроме [Exclude]) плоскими и без captions
var
  i : Integer;
  procedure ChPanel(c: TControl);
  var
    p: TPanel;
    i: Integer;
  begin
    if not(c is TPanel) then Exit;
    for i:= 0 to High(Exclude) do
      if Exclude[i] = c
        then Exit;
    p:= TPanel(c);
    if NoCaption then p.Caption:= '';
    if Flat then begin
      p.BevelOuter:= bvNone;
    end;
  end;
  procedure Add(Control : TControl);
  var
    i : Integer;
  begin
    if Control is TWinControl then
    with TWinControl(Control) do
    for i := 0 to Controlcount-1 do
      Add(Controls[i]);
      if Control <> Parent  then ChPanel(Control)
  end;
begin
 if Recursive
   then Add(Parent)
   else
     for i := 0 to Parent.Controlcount-1 do
       ChPanel(Parent.Controls[i]);
end;


procedure TControlsHelper.FixTabOrder(const Parent: TWinControl);
//устанвливает TabOrder в переданном контейнере по контролам, слева направо, сверху вниз
var
  ctl, L: Integer;
  List: TList;
begin
  List := TList.Create;
  try
    for ctl := 0 to Parent.ControlCount - 1 do
    begin
      if Parent.Controls[ctl] is TWinControl then
      begin
        if List.Count = 0 then
          L := 0
         else
         begin
           with Parent.Controls[ctl] do
             for L := 0 to List.Count - 1 do
               if (Top < TControl(List[L]).Top) or ((
                   Top = TControl(List[L]).Top) and (
                   Left < TControl(List[L]).Left)) then Break;
         end;
         List.Insert(L, Parent.Controls[ctl]) ;
         FixTabOrder(TWinControl(Parent.Controls[ctl])) ;
         end;
       end;
     for ctl := 0 to List.Count - 1 do begin
       TWinControl(List[ctl]).TabOrder := ctl;
     end;
   finally
     List.Free;
   end;
end;

function TControlsHelper.GetFirstTabControl(const Parent: TWinControl): TWinControl;
//вернет контрол, имеющий нулевой TabOrder
//НЕВЕРНО!!!
var
  i: Integer;
  va: TVarDynArray2;
begin
  Result:= nil;
  for i:= 0 to Parent.ComponentCount - 1 do
    if (Parent.Components[i] is TWinControl) and not (Parent.Components[i] is TPanel)
      then va:=va + [[Parent.Components[i].Name, TWinControl(Parent.Components[i]).TabOrder]];
  A.VarDynArray2Sort(va, 1);
  if Length(va) > 0
    then Result:= TWinControl(Parent.FindComponent(va[0][0]));
end;

procedure TControlsHelper.SetDynProps(Control: TObject; DynProps: TVarDynArray2);
//установим (создадим или ззаменим) DynProps для DbEh контролов, данные возьмем из массива
//[[PropName {,Value}], [PropName2 {,Value2}]..
var
  i: Integer;
begin
  for i := 0 to High(DynProps) do begin
    if Control is TDBCheckBoxEh then begin
      if (High(DynProps[i]) > 1) and (DynProps[i][2] = False) then
        TDBCheckBoxEh(Control).DynProps.DeleteDynVar(DynProps[i][0])
      else begin
        if not TDBCheckBoxEh(Control).DynProps.VarExists(DynProps[i][0]) then
          TDBCheckBoxEh(Control).DynProps.CreateDynVar(DynProps[i][0], '');
        if High(DynProps[i]) > 0 then
          TDBCheckBoxEh(Control).DynProps.FindDynVar(DynProps[i][0]).Value := VarToStr(DynProps[i][1]);
      end;
    end;
    if Control is TColumnEh then begin
      if (High(DynProps[i]) > 1) and (DynProps[i][2] = False) then
        TColumnEh(Control).DynProps.DeleteDynVar(DynProps[i][0])
      else begin
        if not TColumnEh(Control).DynProps.VarExists(DynProps[i][0]) then
          TColumnEh(Control).DynProps.CreateDynVar(DynProps[i][0], '');
        if High(DynProps[i]) > 0 then
          TColumnEh(Control).DynProps.FindDynVar(DynProps[i][0]).Value := VarToStr(DynProps[i][1]);
      end;
    end;
    if Control is TCustomDBEditEh then begin
      if (High(DynProps[i]) > 1) and (DynProps[i][2] = False) then
        TCustomDBEditEh(Control).DynProps.DeleteDynVar(DynProps[i][0])
      else begin
        if not TCustomDBEditEh(Control).DynProps.VarExists(DynProps[i][0]) then
          TCustomDBEditEh(Control).DynProps.CreateDynVar(DynProps[i][0], '');
        if High(DynProps[i]) > 0 then
          TCustomDBEditEh(Control).DynProps.FindDynVar(DynProps[i][0]).Value := VarToStr(DynProps[i][1]);
      end;
    end;
    if Control is TFrDBGridEh then begin
      if (High(DynProps[i]) > 1) and (DynProps[i][2] = False) then
        TFrDBGridEh(Control).DynProps.DeleteDynVar(DynProps[i][0])
      else begin
        if not TFrDBGridEh(Control).DynProps.VarExists(DynProps[i][0]) then
          TFrDBGridEh(Control).DynProps.CreateDynVar(DynProps[i][0], '');
        if High(DynProps[i]) > 0 then
          TFrDBGridEh(Control).DynProps.FindDynVar(DynProps[i][0]).Value := VarToStr(DynProps[i][1]);
      end;
    end;
  end;
end;

function TControlsHelper.GetDynProp(Control: TObject; DynProp: string): Variant;
//возвращает значение свойства с именем DynProp для DbEh контролов
//если свойство не найдено, возвращает пустую строку
begin
  Result := '';
  if Control is TColumnEh then begin
    if TColumnEh(Control).DynProps.VarExists(DynProp) then
      Result := TColumnEh(Control).DynProps.FindDynVar(DynProp).Value;
  end;
  if Control is TDBCheckBoxEh then begin
    if TDBCheckBoxEh(Control).DynProps.VarExists(DynProp) then
      Result := TDBCheckBoxEh(Control).DynProps.FindDynVar(DynProp).Value;
  end;
  if Control is TCustomDBEditEh then begin
    if TCustomDBEditEh(Control).DynProps.VarExists(DynProp) then
      Result := TCustomDBEditEh(Control).DynProps.FindDynVar(DynProp).Value;
  end;
  if Control is TFrDBGridEh then begin
    if TFrDBGridEh(Control).DynProps.VarExists(DynProp) then
      Result := TFrDBGridEh(Control).DynProps.FindDynVar(DynProp).Value;
  end;
end;


function TControlsHelper.GetOwneredControlNames(AOwner: TComponent): TVarDynArray;
var
  i: Integer;
  c: TComponent;
begin
  Result:=[];
  for i := 0 to AOwner.ComponentCount -1 do begin
    c := AOwner.Components[i];
    //if (c is TCustomDBEditEh)or(c is TDBGridEh)or(c is TFrDBGridEh)
      //then
      Result := Result + [AOwner.Components[i].Name];
  end;
end;

procedure TControlsHelper.SetControlsEhEvents(AParent: TWinControl; AOnlyFields: Boolean; AIfEmptyEvent: Boolean; AOnEnter, AOnExit, AOnChange: TNotifyEvent; AOnCheckDrawRS: TOnCheckDrawRequiredStateEventEh);
var
  i, j: Integer;
  Owner, c: TComponent;
  ParentIsForm: Boolean;
  st : string;
begin
  ParentIsForm := False;
  if (AParent is TForm) or (AParent is TFrame) then begin
    Owner := TComponent(AParent);
    ParentIsForm := True;
  end
  else
    Owner := AParent.Owner;
  for i := 0 to Owner.ComponentCount - 1 do begin
    c := Owner.Components[i];
    if not (c is TControl) then
      Continue;
    if not (ParentIsForm or IsChildControl(AParent, TControl(c), True)) then
      Continue;
    st := TControl(c).Name;
    if c is TCustomDBEditEh then begin
      if Assigned(AOnChange) and not AIfEmptyEvent or not Assigned(TDBEditEh(c).OnChange) then
        TDBEditEh(c).OnChange := AOnChange;
      if Assigned(AOnEnter) and not AIfEmptyEvent or not Assigned(TDBEditEh(c).OnEnter) then
        TDBEditEh(c).OnEnter := AOnEnter;
      if Assigned(AOnExit) and not AIfEmptyEvent or not Assigned(TDBEditEh(c).OnExit) then
        TDBEditEh(c).OnExit := AOnExit;
      if Assigned(AOnCheckDrawRS) and not AIfEmptyEvent or not Assigned(TDBEditEh(c).OnCheckDrawRequiredState) then
        TDBEditEh(c).OnCheckDrawRequiredState := AOnCheckDrawRS;
    end
    else if c is TDBCheckBoxEh then begin
      if Assigned(AOnChange) and not AIfEmptyEvent or not Assigned(TDBCheckBoxEh(c).OnClick) then
        TDBCheckBoxEh(c).OnClick := AOnChange;
      if Assigned(AOnEnter) and not AIfEmptyEvent or not Assigned(TDBCheckBoxEh(c).OnEnter) then
        TDBCheckBoxEh(c).OnEnter := AOnEnter;
      if Assigned(AOnExit) and not AIfEmptyEvent or not Assigned(TDBCheckBoxEh(c).OnExit) then
        TDBCheckBoxEh(c).OnExit := AOnExit;
    end;
  end;
end;

procedure TControlsHelper.LoadBitmap(ImageList: TImageList; Number: Integer; Bitmap: TBitmap);
var
  ActiveBitmap: TBitmap;
begin
  ActiveBitmap := TBitmap.Create;
  try
    ImageList.GetBitmap(Number, ActiveBitmap);
    Bitmap.Transparent := True;
    Bitmap.Height := ActiveBitmap.Height;
    Bitmap.Width := ActiveBitmap.Width;
    Bitmap.Canvas.Draw(0, 0, ActiveBitmap);
  finally
    ActiveBitmap.Free;
  end;
end;



function TControlsHelper.AlignControls(AParent: TObject; Exclude: TControlArray; ResizeParent: Boolean = False; VMargin: Integer = 0; LabelsToLeft: Boolean = False): TCoord;
//выравнивает контролы в переданном конейнере, устанавливает порядок табуляции
//подгоняются друг под друга, расстояния по верикали и отступы по константам приложания
//если ResizeParent, то подгоняет высоту родителя
//возвращает в массиве получающуюся высоту и ширину
const
  PrecisionH = 30;
  StepH = 13;
var
  i, j, k, m, n, t, h, r, TabOrder: Integer;
  pr, pt: Integer;
  c: TControl;
  Ctrls, CtrlsH, CtrlsHP : TVarDynArray2;
  ar, ab: TControlArray;
  CtrlsHH : TVarDynArray;
  st: string;
  va2: TVarDynArray2;
  b: Boolean;
begin
  pr:= 0; pt:= 0;  //размеры контейнера для его подгонки
  Ctrls:=[];
  //массив контролов и их параметров
  for i:=0 to TPanel(AParent).ControlCount - 1 do begin
    c:= TPanel(AParent).Controls[i];
    if not c.Visible then
      Continue;
    //проверим, не в исключениях ли контрол
    for j:= 0 to High(Exclude) do
      if TPanel(AParent).Controls[i] = Exclude[j]
        then Break;
    //если не в исключениях, добавим в массив
    if j > High(Exclude) then begin
      b:= True;
      //контрольлейблы для Eh-controls тоже поадут в массив,
      //исключим их, кроме варианта расположения лейбла сверху-слеева надо основным контролом
      if TPanel(AParent).Controls[i].Name = 'SubLabel' then begin
        if TCustomDBEditEh(TControlLabelEh(TPanel(AParent).Controls[i]).Owner).ControlLabelLocation.Position <> lpAboveLeftEh
          then b:= False;
      end;
      if b then
      Ctrls:= Ctrls + [[
        i,
        TPanel(AParent).Controls[i].Top,
        TPanel(AParent).Controls[i].Left,
        TPanel(AParent).Controls[i].Height,
        TPanel(AParent).Controls[i].Width,
        TPanel(AParent).Controls[i].Name
      ]];
    end;
    if akRight in (TWinControl(c).Anchors) then begin
      ar:= ar + [TWinControl(c)];
      TWinControl(c).Anchors:= TWinControl(c).Anchors - [akRight];
    end;
    if akBottom in (TWinControl(c).Anchors) then begin
      ab:= ab + [TWinControl(c)];
      TWinControl(c).Anchors:= TWinControl(c).Anchors - [akBottom];
    end;
  end;
  //отсортируем по left контрола
  A.VarDynArray2Sort(Ctrls, 3);
  //отсортируем по top контрола
  A.VarDynArray2Sort(Ctrls, 2);
  //сформируем массив котролов по строкам
  CtrlsH:=[];
  CtrlsHP:=[];
  CtrlsHH:=[];
  j:= -100;
  k:= -1;
  for i:= 0 to High(Ctrls) do begin
    //как только верх очередного контрола окажется ниже низа предыдущего, формируем новую строку массива
    if Ctrls[i][1] > j then begin
      CtrlsH:= CtrlsH + [[]];
      CtrlsHP:= CtrlsHP + [[]];
      CtrlsHH:= CtrlsHH + [0];
      j:= Ctrls[i][1] + Ctrls[i][3];
      k:= k + 1;
    end;
    //и добавим туда номер в массиве контролов
    CtrlsH[k] := CtrlsH[High(CtrlsH)] + [i];
    CtrlsHP[k] := CtrlsHP[k] + [Ctrls[i][2], Ctrls[i][2] + Ctrls[i][4]];
    CtrlsHH[k] := Max(CtrlsHH[k], Ctrls[i][3]);
  end;
  t:= MY_FORMPRM_V_TOP;
  for i:= 0 to High(CtrlsH) do begin
    h:= MY_FORMPRM_CONTROL_H;
    h:= CtrlsHH[i];
    for j:= 0 to High(CtrlsH[i]) do begin
//      c:= TPanel(AParent).Controls[Ctrls[Integer(CtrlsH[i][j])][0]];
      c:= TPanel(AParent).Controls[Ctrls[Integer(CtrlsH[i][j])][0]];
      if c is TBevel then begin
        c.Top:= t + (h - 2) div 2;
        h:= 3;
        c.Height:= h;
      end
      else if c is TLabel then begin
        c.Top:= t + (h - c.Height) div 2;
      end
      else if (c is TCheckBox) then begin
        c.Top:= t + (h - c.Height) div 2;
      end
      else begin
        c.Top:= t + (h - c.Height) div 2;
      end;
      //else c.Top:= t; ///!!!
      if True {c.Name='DBEditEh1'} then begin
        for m:= i - 1 downto 0 do
          for n:= 0 to High(CtrlsH[m]) do begin
            if Abs(c.Left - CtrlsHP[m][n * 2]) < PrecisionH
              then begin c.Left:= CtrlsHP[m][n * 2];  Break; end;
          end;
        for m:= i - 1 downto 0 do
          for n:= 0 to High(CtrlsH[m]) do begin
            if Abs(c.Left + c.Width - CtrlsHP[m][n * 2 + 1]) < PrecisionH
              then begin c.Width:= CtrlsHP[m][n * 2 + 1] - c.Left; Break; end;
          end;
      end;
      pr:= Max(pr, c.Left + c.Width + MY_FORMPRM_H_EDGES);
      pt:= Max(pt, c.Top + c.Height + MY_FORMPRM_V_TOP);
    end;
    t:= t + h + S.Iif(VMargin = 0, MY_FORMPRM_V_MARGIN, VMargin);
  end;
  FixTabOrder(TWincontrol(AParent));
  for i:= 0 to High(ar) do
    TWinControl(ar[i]).Anchors:= TWinControl(ar[i]).Anchors + [akRight];
  for i:= 0 to High(ab) do
    TWinControl(ab[i]).Anchors:= TWinControl(ab[i]).Anchors + [akBottom];
  if ResizeParent then begin
    TWinControl(AParent).Width:= pr;
    TWinControl(AParent).Height:= pt;
  end;
  Result.X:= pr;
  Result.Y:= pt;
end;

end.
{


найти компонент на форме можно так, даже если он в дочерней панеле (без учета регистра)
  st:=VarToStr(GetControlValue(TControl(ASelf.FindComponent('dedt_1'))));
  st:=VarToStr(GetControlValue(TControl(pnl_left.FindChildControl('dedt_1'))));
но не пойдет
  st:=VarToStr(GetControlValue(TControl(pnl_left.FindComponent('dedt_1'))));
Components - массив компонентов, которыми владеет данный элемент. FindComponent ищет по Owner
Controls - массив контролов по Parent

-------------------

надо ли проверять
if Form.TComponents[i] is TControl
или можнор преобразовывать сразу TControl(Form.TComponents[i]) ??? !!!

-------------------
Чтобы пройтись по отфильтрованному списку записей используете список MemTableEh1.RecordsView
Чтобы пройтись по полному списку записей используйте список MemTableEh1.RecordsView.MemTableData.RecordsList

Код:
procedure TForm3.Button2Click(Sender: TObject);
var
s: string;
i: Integer;
begin
  for i:= 0 to MemTableEh1.RecordsView.Count-1 do
  begin
    s := VarToStr(MemTableEh1.RecordsView[i].DataValues['Name', dvvValueEh]);
  end;

  for i:= 0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count-1 do
  begin
    s := VarToStr(MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['Name', dvvValueEh]);
  end;
end;


Для доступа к внутренним структурам данных используйте следующие свойства объекта TMemTableEh:

RecordsView: TRecordsViewEh
Ссылка на отфильтрованный список записей.

RecordsView.Rec[Index: Integer]: TMemoryRecordEh
Доступ к конкретной записи в массиве отфильтрованных значений.

RecordsView.Count: Integer
Количество записей в отфильтрованном списке. В режиме TreeView учитываются только раскрытые ветви.

RecordsView.MemTableData.RecordsList[Index: Integer]: TMemoryRecordEh
Доступ к конкретной записи в массиве всех записей.

RecordsView.MemTableData.RecordsList.Count
Количество записей в списке всех записей.

RecordsView.MemTableData.RecordsList[Index: Integer].DataValues[const FieldNames: string; DataValueVersion: TDataValueVersionEh]: Variant
Доступ к значению поля или полей в записи с номером Index.


}



TFlowPanel !!!!
