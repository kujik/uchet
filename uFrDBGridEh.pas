unit uFrDBGridEh;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  MemTableDataEh, Data.DB, Data.Win.ADODB, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, GridsEh, DBAxisGridsEh, DBGridEh,
  DataDriverEh, ADODataDriverEh, MemTableEh, Math, PrnDbgEh, ClipBrd,
  ComCtrls, Buttons, Vcl.Menus, DBCtrlsEh, Vcl.Mask,
  uData, uString, uLabelColors, Vcl.Imaging.pngimage, EhLibVclUtils
  ;

const
  yrefT = -1;
  yrefB = -2;
  yrefC = -3;

  mydefGridRowHeight = 18;    //дефолтная высота строки грида

  MY_IDS_INSERTED_MIN = MaxInt - 100000;


type

  TDBGridEhMy = class(TDBGridEh);
  {
  Опции внешнего вида и особенностей грида, в основном компиляция опций грида Options и OptionsEh и некоторые дополнительные фичи.
  Нельзя менять порядок элементов в описании типа!
  }

  TFrDBGridOption = (
    myogColoredTitle,                         //раскраска заголовка
    myogColoredEven,                          //раскраска четных/нечетных строк
    myogPanelFilter,                          //фильтр в панели
    myogPanelFind,                            //поиск в панели (вместо фильтра)
    myogColumnFilter,                         //фильтр в стоолбцых StFilter
    myogSorting,                              //сортировка. мультисортировка включена всегда
    myogSavePosWhenSorting,                   //сохранять позицию при сортировке. иначе происходит переход на верхнюю позицию
    myogColumnMove,                           //разрешаем менять колонки местами
    myogColumnResize,                         //разрешает изменять размеры колонок
    myogSaveFilter,                           //сохранять фильтр столбцов в настроках и востанавливать при новом открытии
    myogMultiSelect,                          //мультивыделение строк
    myogIndicatorCheckBoxes,                  //чекбоксы в индикаторном столбце. если есть мультивыделение строк, то можно отметить несколько, иначе один
    myogHiglightEditableColumns,              //подсветак зеленой полоской слева редактируемых столбцов
    myogHiglightEditableCells,                //подсветка зеленой полоской снизу текущей ячейки, если она редактируема
    myogHasStatusBar,                         //статусбар к гриду (в информации - заголовок и количество записей, и сколько отфильтровано и выбрано)
    myogGridLabels,                           //цветные метки для строк, три цвета, доступны если есть FormDoc,
    myogGrayedWhenRefresh,                    //затенять грид при обновлении
    myogIndicatorColumn,                      //включить индикаторный столбец
    myogAutoFitColWidths,                     //подгонять ширину колонок, чтобы таблица была умещщена/растянута в видидимую область
    myogAutoFitRowHeight,                     //подгонять высоту строк в зависимости от содержимого
    myogSaveOptions,                          //сохранять опции в файле настроек
    myogDefMenu,                              //-использовать меню грида с дефолтными пунктами, если меню не настроено явно
    myogRowDetailPanel,                       //включить детальную панель в гриде
    myogLoadAfterVisible,                     //показать грид, не дожидайсь загрузки данных
    myogPrintGrid,                            //разрешить печать и экспорт грида, показать этот пункт в меню
    myogHideColumns,                          //разрешать прятать столбцы через окно настроек
    myogFroozeColumn,                         //разрешать заморозить столбцы через окно настроек
    myogNoTextEditing                         //запретить открытие InplaceEditor
  );

  TFrDBGridOptions = set of TFrDBGridOption;

const FrDBGridOptionDesc : array [0..26] of string = (
  'раскраска заголовка',
  'раскраска четных/нечетных строк',
  'фильтр в панели',
  'поиск в панели (вместо фильтра)',
  'фильтр в стоолбцых StFilter',
  'сортировка. мультисортировка включена всегда',
  'сохранять позицию при сортировке. иначе происходит переход на верхнюю позицию',
  'разрешаем менять колонки местами',
  'разрешает изменять размеры колонок',
  'сохранять фильтр столбцов в настроках и востанавливать при новом открытии',
  'мультивыделение строк',
  'чекбоксы в индикаторном столбце. если есть мультивыделение строк, то можно отметить несколько, иначе один',
  'подсветак зеленой полоской слева редактируемых столбцов',
  'подсветка зеленой полоской снизу текущей ячейки, если она редактируема',
  'статусбар к гриду (в информации - заголовок и количество записей, и сколько отфильтровано и выбрано)',
  'цветные метки для строк, три цвета, доступны если есть FormDoc,',
  'затенять грид при обновлении',
  'включить индикаторный столбец',
  'подгонять ширину колонок, чтобы таблица была умещщена/растянута в видидимую область',
  'подгонять высоту строк в зависимости от содержимого',
  'сохранять опции в файле настроек',
  '-использовать меню грида с дефолтными пунктами, если меню не настроено явно',
  'включить детальную панель в гриде',
  'показать грид, не дожидайсь загрузки данных',
  'разрешить печать и экспорт грида, показать этот пункт в меню',
  'разрешать прятать столбцы через окно настроек',
  'разрешать заморозить столбцы через окно настроек'
);

const
  //обычный набор опций для всех гридов
  FrDBGridOptionDef : TFrDBGridOptions =
    [myogIndicatorColumn, myogColoredTitle, myogColoredEven, myogHiglightEditableCells, myogHiglightEditableColumns, myogSavePosWhenSorting, myogGrayedWhenRefresh];
  //дополнительный к нему набор для гридов просмотра справочников
  FrDBGridOptionRefDef : TFrDBGridOptions =
    [myogSorting, myogPanelFilter, myogColumnMove, myogColumnResize, myogColumnFilter, myogSaveOptions, myogHasStatusBar, myogPrintGrid, myogHideColumns, myogFroozeColumn];
  //набор опций для сохранения в бд
  FrDBGridOptionSave : TFrDBGridOptions = [myogPanelFilter, myogPanelFind, myogColumnFilter, myogSorting, myogSaveFilter, myogAutoFitColWidths, myogAutoFitRowHeight, myogSavePosWhenSorting];




type

  TFrDBGridVerifyMode = (
    dbgvBefore,
    dbgvCell,
    dbgvRow,
    dbgvTable
  );

  TFrDBGridRowOperationMode = (
    dbgroBeforeAdd,
    dbgroBeforeInsert,
    dbgroBeforeDelete,
    dbgroAfterAdd,
    dbgroAfterInsert,
    dbgroAfterDelete,
    dbgroOnVerifyRow,
    dbgroOnVerifyTable
  );


  //режим работы с данными датасета и грида
  TFrDBGridDataMode = (
    myogdmWithAdoDriver,            //испольуется AdoDriver, датасет будет онлайн
    myogdmFromArray,                //данные загружаются сразу из массива, датасет оффлайн
    myogdmFromSql                   //данные загружаются sql-запросом при создании или вручную, датасет оффлайн
  );

  //запись параметров для столбца грида
  TFrDBGridRecFieldsList = record
                                    //st$s as name     (алиасы нельзя использовать для полей где будет подстановка null)
    Name: string;                   //наименование поля (краткое до $ или алиас), совпадающее с полем в MemTable) - name
    NameDb: string;                 //наименование поля в БД - st
    FullName: string;               //наименование поля полное, как оно было указано в массиве определения полей - st$s as name
    Caption: string;                //заголовок поля
    DataType: TFieldType;           //тип данных, определяется из наименования поля типа id$i
    FieldSize: Integer;             //размер данных, не используется
    DefOptions: string;             //параметры отображения столбца - ширина, растягивание по ширине, высоте
    Width: Integer;                 //не использем
    MaxWidth: Integer;              //не использем
    Visible: Boolean;               //установлена видимость колонки в настройках
    Invisible: Boolean;             //если установлено, то кололонка скрыта, но это не повлияет на сохраненные настройки видимости в БД
    AddProps: TVarDynArray2;
    FChb: Boolean;                  //чекбокс в столбце
    FChbPic: string;                //параметры картинки, которая выводится вместо чекбокса, если его столбец не редактируемый
    FChbt: Boolean;                 //чекбокс с текстом в столбце
    FChbtPic: string;               //параметры картинки, которая выводится вместо чекбокса, если его столбец не редактируемый
    FBt: string;                    //строка определения кнопок в столбце
    FPic: string;                   //строка определения картинки в столбце
    Editable: Boolean;              //данные в столбце редактируются
    FVerify: string;                //строка верификации данных при редактированиии
    FFormat: string;                //строка определения формата отображения данных в столбце и футере
    FIsNull: Boolean;               //признак, что вместо данных загружается пустое значение; столбцы будут скрыты
    FTags: string;                  //теги для быстрого доступа к группе полей, у одного поля может быть несколько через ,
  end;

  //массив свойств столбцов грида
  TFrDBGridFieldsList = array of TFrDBGridRecFieldsList;

  //запись опредения кнопок, кажадая запись соответствует одно панели кнопок (их может быть несколько)
  TFrDBGridEhRecButtons = array of record
    A: TVarDynArray2;            //массив определяет кнопки на панели
    T: Integer;                  //тип кнопок cbttXXXX (или число что означает стандартную кнопку такой длины), по умолчанию cbttSBig
    H: Integer;                  //высота панели кнопок, по умолчанию подгоняется по типу кнопок с отступами от них  = 2
    V: Boolean;                  //вертикальное расположиние кнопок, по умолчанию горизонтально, если только панель не pnlLeft
    P: TPanel;                   //панель, в которой располагаются кнопки. если задана только массив кнопок для индекса 0, то она станет pnlTop
                                 //панель может и не принадлежать фрейму, быть на форме
  end;

  //определение таблиц и зпросов скл
  TFrDBGridEhRecSQL = record
    View: string;               //вью или таблица, из которой делаем селект при чтении данных
    Table: string;              //таблица, которую обновляем
    FieldsDef: TVarDynArray2;   //массив первоначального определения полей (строковые значения)
    FieldNames: string;
    Captions: string;
    IdField: string;            //имя поля айди, поределяется автоматически как первое поле в FieldsDef
    RefreshBeforeSave: Boolean;//обновлять строку из бд перед изменением данных в ячейке
    RefreshAfterSave: Boolean; //обновлять строку из бд после изменения данных в ячейке
    Select: string;             //запрос занпрузки всей таблицы. если пустой, формируется на основании списка полей, WhereAllways и функции GetWhere
                                //если непустой, то WhereAllways игнорируется
                                //возврат функции GetWhere заменяет строку "/*WHERE*/" при ее наличии, иначе добавлется к Select перед WhereAllways через and
    GetRec: string;             //обновление строки грида чтением из БД
    Update: string;             //апдейт строки таблицы в БД
    Delete: string;             //удаление строки в БД
    Insert: string;             //удаление строки в БД
    WhereAllways: string;       //постоянная часть условия запроса, может быть вида например 'where dt_beg=:dt$d', 'where a > 0 /*WHERE*/ order by dt', 'where (a > 1 or b >1)', 'group by name'
                                //где /*WHERE|ANDWHERE|WHEREONLY*/ заменится на 'where %GetWhere%', " and (%GetWhere%)
    Fields: TFrDBGridFieldsList;    //массив свойств грида/датасета для полей, формирется на основании исходных данных и настройки свойств
  end;

  //определение ввыпадающих списков для столбцов
  TFrDBGridEhPickRec = record
    FieldName: string;
    PickList: TVarDynArray;
    KeyList: TVarDynArray;
    LimitTextToListValues: Boolean;
    AlwaysShowEditButton: Boolean;
  end;

  TFrDBGridEhPickRecList = array of TFrDBGridEhPickRec;


  TFrDBGridEhDataGrouping = record
    Fields: TVarDynArray;
    Fonts: TFontsArray;
    Colors: TColorsArray;
    Active: Boolean;
  end;

  {
  параметры данных и опций грида
  (поля, запросы выборки даннх, кнопки, картинки и кнопки в ячейках, формат полей),
  процедуры для их установки.
  также частично и данные, которые устанавливаются не непосредственно, а как результат обработки опций, и испольуются уже
  в процессе работы грида.
  }
  TFrDBGridEhOpt = class(TObject)
  private
    //Массив панелей кнопок. может быть невсколько. созданы будут те, для которых задан массив кнопок и панель. панели не обязательно во фрейме.
    FButtons: TFrDBGridEhRecButtons;
    //АйДи кнопок, которые доступны даже если таблица пуста
    FButtonsIfEmpty: TVarDynArray;
    //АйДи кнопок, статус которых не меняется автоматически. если задать [0] то никакие кнопки апвтоматически не управляются
    FButtonsNoAutoState: TVarDynArray;
    //Вью, таблица, запросы, первичное поределение полей
    FSql: TFrDBGridEhRecSql;
    //режим получения данных (С датадрайвором, из массива, или при открытии читает создаваемым на основе списка полей запросом, а далее работа с этим массивом)
    FDataMode: TFrDBGridDataMode;
    //допустимыен операции с гридом
    FAllowedOperations: TDBGridEhAllowedOperations;
    //данные группировки (масиивы полей, каждое соотвествует уроню групировки, шрифтов и цветов фона - могут быть пустыми), и активность группировки.
    FDataGrouping: TFrDBGridEhDataGrouping;
    //имя замороженного столбца
    FFrozenColumn: string;
    //настройки универсального sql-фильтра (форма которого вызывается по клику на кнопке Фильтр и применяетсяк sql-запросам, а не дефолтные фильтра DBGridEh)
    FFilterRules: TVarDynArray2;
    //результирующая строка по данным с формы универсального sql-фильтра, исходя из анализа которой меняется where-часть или параметры запроса
    FFilterResult: string;
    //заголовок таблицы, отображается в сообщениях и в статусбаре
    FCaption: string;
    //подсказки для колонок грида
    FColumnsInfo: TVarDynArray2;
    //опции, которые пользователь не может менять через диалог настройки (остаются теми, что настроены программно, или прочитаны из бд - тогда обязательно стразу настроить дефолтные)
    FFrozenGridOptions: TFrDBGridOptions;
    //панели (их name), для которых значения контролов, на них расположенных, сохраняются в БД и восстанавливаются из нее
    //если здесь есть значение '*', то при создании дополнительных контролов создаваемая для них панель автоматом попадает сюда
    FPanelsSaved: TVarDynArray;
    //массив выпадающих списков для всех полей
    FPickLists: TFrDBGridEhPickRecList;
    //если задано, запускается Wh.ExecDialog(FDialogFormDoc, Fr.ID, null)
    FDialogFormDoc: string;
    //вспомогательная процедура
    procedure SetFrValue(var fr: TFrDBGridRecFieldsList; AValue: string; ASet: Boolean = False);
  public
    //фрейм, к которому применяются настройки
    FrDBGridEh: TObject;
    //конструктор
    constructor Create(AOwner: TComponent);
    //свойства
    property Caption: string read FCaption write FCaption;
    property Buttons: TFrDBGridEhRecButtons read FButtons;
    property ButtonsNoAutoState: TVarDynArray read FButtonsNoAutoState write FButtonsNoAutoState;
    property Sql: TFrDBGridEhRecSql read FSql;
    property DataMode: TFrDBGridDataMode read FDataMode;
    property AllowedOperations: TDBGridEhAllowedOperations read FAllowedOperations;
    property FilterRules: TVarDynArray2 read FFilterRules write FFilterRules;
    property FilterResult: string read FFilterResult write FFilterResult;
    property DataGrouping: TFrDBGridEhDataGrouping read FDataGrouping;
    property ColumnsInfo: TVarDynArray2 read FColumnsInfo write FColumnsInfo;
    property FrozenColumn: string read FFrozenColumn write FFrozenColumn;
    property FrozenGridOptions: TFrDBGridOptions read FFrozenGridOptions write FFrozenGridOptions;
    property PickLists: TFrDBGridEhPickRecList read FPickLists;
    property DialogFormDoc: string read FDialogFormDoc write FDialogFormDoc;
    //процедуры установки свойств
    //настройка панелей кнопок и меню
    procedure SetButtons(AIndex: Integer; AButtons: TVarDynArray2; AType: Integer = 1; APanel: TPanel = nil; AHeight: Integer = 0; AVertical: Boolean = False); overload;
    //простая настройка панели кнопок, только стандартные строкой, меню будет совпадать
    procedure SetButtons(AIndex: Integer; AButtons: string = ''; ARight: Boolean = True); overload;
    //установка кнопок, которые доступны при пустом гриде. если не вызывалась - там будут кнопки по умолчанию
    //переданные кнопки добаляются к тем что по умолчанию!. чтобы очистить, сначала передайте пустой массив!
    procedure SetButtonsIfEmpty(AButtonsIfEmpty: TVarDynArray);
    //передается массив первоначального определения полей
    procedure SetFields(AFields: TVarDynArray2);
    //настройка свойства полей, переданных через ;, AFeatype передается строкой в том же виде как при определении полей
    procedure SetColFeature(AFields: string; AFeatype: string; ASet: Boolean = true; AClearOther: Boolean = False);
    //параметры sql для запроса
    procedure SetTable(AView: string; ATable: string = ''; AIdField: string = ''; ARefreshBeforeSave: Boolean = True; ARefreshAfterSave: Boolean = True);
    //запросы sql, если они не формируются автоматичеески на основании определения полей
    procedure SetSql(ASelect: string = ''; AGetRec: string = ''; AUpdate: string = ''; AInsert: string = ''; ADelete: string = '');
    //определение where-части запроса, которая всегда добавлена к запросу select
    procedure SetWhere(AWhereAllways: string = '');
    //режим работы с данными (с датадрайвером онлайн, загрузка из запроса один раз, загрузка из массива)
    procedure SetDataMode(ADataMode: TFrDBGridDataMode = myogdmWithAdoDriver);
    //допустимые для грида операции,
    //передаются строкой в любом регистре, наличие буквы-кода операции разрешает ее ('uiad')
    //если эта функция не вызвана, в гриде будет разрешена alopUpdateEh
    procedure SetGridOperations(AOperations: string = 'u');
    //группировка
    //передаются поля и статус активности группировки. если поля не переданы - они не изменяются.
    //Если полей для группировки нет - она не включится
    procedure SetGrouping(AFields: TVarDynArray; AFonts: TFontsArray; AColors: TColorsArray; AActive: Boolean);
    //добавляет запись в массив определений выпадающих списков в столбцах грида
    procedure SetPick(AFieldName: string; APickList: TVarDynArray; AKeyList: TVarDynArray; ALimitTextToListValues: Boolean; AAlwaysShowEditButton: Boolean = True);
    //установка массива имен панелей автосохранения значений контролов
    procedure SetPanelsSaved(APanelsSaved: TVarDynArray);

    //получить свойства (запись) для столбца по наименованию поля
    function  GetFieldRec(AFieldName: string): TFrDBGridRecFieldsList;

    //вспомогательная процедура
    //процедура нужна для установки свойства видимости столбца в рабочем массиве полей во внешних объектах (окно настроек, чтение настроек из бд)
    procedure SetFieldVisible(AFieldName: string; AVisible: Boolean);
  end;

  //данные для начальной загрузки или обновления грида в оффлайн-режиме
  TFrDBGridInitData = record
    IsDefined: Boolean;
    SQl: string;
    Params: TVarDynArray;
    Arr: TVarDynArray2;
    ArrFields: string;
    ArrColumns: string;
    ArrN: TNamedArr;
  end;

  //данные, использующиеся для редактирования грида в оффлайн-режиме
  TFrDBGridEditData = record
    FieldsParams: TVarDynArray2;
    FieldsErrors: TVarDynArray2;
    IdsChanged: TVarDynArray;
    IdsDeleted: TVarDynArray;
    CellsWithErrors: TVarDynArray;
    IdAdded: Integer;
  end;

  //параметры для редактируемого грида (оффлайн)
  TFrDBGridEditOptions = record
//    AddLast: Boolean;                       //по кнопке Добавить вставлять строку в конец таблицы (иначе в текущую позицию)
//    AddIfNotempty: Boolean;                 //добавлять строку только если текущая (при AddLast последняя) заполнена полнгостью (кроме поля id)
//    OneRowOnOpen: Boolean;                  //если грид открывается пустым в режиме редактрования или добалетния, то сразу добавить пустую строку
//    AddRowIfFAddOnOpen: Boolean;            //если fAdd то сразу добавим строку в конец
    AllowEmptyTable: Boolean;                 //При нажатии Ок считать пустую таблицу корректным результатом
    FieldsNoRepaeted: TVarDynArray;           //поля, значения которых в строках таблицы не должны повторяться
    AlwaysVerifyAllTable: Boolean;            //при любом вводе данных и удалении строки всегда проверять всю таблицу
  end;



  {
  события фрейма
  часть из них повторяет события грида/столбцов
  для удобства передается объект фрейма, вызвашего событие
  No не используется
  }
  TFrDBGridEh = Class;
  //при нажатии кнопки или пункта меню, нажатый элемент определяется полем Tag, fMode определяется по тэгу для кнопок редактирования, иначе fNone
  TFrDBGridEhButtonClickEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean) of object;
  //OnChange или OnClick для дополнительно создаваемых контролов (обычно в панелях кнопок)
  TFrDBGridEhAddControlChangeEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject) of object;
  //двойной клик в таблице. по умолчанию вызывает редактирование или просмотр записи
  TFrDBGridEhDblClickEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean) of object;
  //клик на кнопке в ячейке, для всех CellButtons грида, кнопку определяем по хинту к ней
  TFrDBGridEhCellButtonClickEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean) of object;
  //вызывается, когда меняется позиция в гриде, как записи так и столбца, или когда могло измениться значение какого-либо поля в записи
  //используется для установки свойств, зависящих от данных (например, доступности каких-либо кнопок, повторителей значений ячеек)
  TFrDBGridEhSelectedDataChangeEvent = procedure (var Fr: TFrDBGridEh; const No: Integer) of object;
  //здесь устанавливаем переменную where-часть запроса и инициализируем параметры в запросе
  //SqlWhere изначально суюда попадает как результат дефолтного фильтра, если он есть и у него заданы фильтр даты или sql-правила для чекбоксов
  //(вызывается дважды, первый раз для конструирования запроса, затем устанавливает параметры в уже готовом запросе, потому их установку делать с флагом пропуска
  TFrDBGridEhSetSqlParamsEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string) of object;
  //вызывается при ручном вводе данных в ячейку грида
  //как правило, можно не перекрывать, там выполняются все проверки и вызываются сопуствующие события
  TFrDBGridEhColumnsUpdateDataEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean) of object;
  //здесь можем устанавливать параметры ячейки (номер картинки, readonly, фон, шрифт) в зависимости от данных в текущей записи
  TFrDBGridEhColumnsGetCellParamsEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh) of object;
  //задать статус ReadOnly для ячейки (например в зависимости от данных), если она в редактируемом столбце, но именно ее редактировать нельзя
  TGetFrDBGridEhCellReadOnlyEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean) of object;
  //вызывается при изменении данных в таблице с разными Mode в зависимости от типа вызова
  //dbgvBefore - когда значение введено но еще не записано в таблицу, можно изменить значение или задать сообщение об ошибке
  //dbgvCell - когда значение в ячейке было изменено вручную
  TFrDBGridEhVeryfyAndCorrectValuesEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string) of object;
  //вызывается после ручного ввода данных в ячейку таблицы, после установки значения в мемтейбл
  //здесь можно сохранить значение ячейки если не надо перекрывать TFrDBGridEhColumnsUpdateDataEvent
  TFrDBGridEhCellValueSaveEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean) of object;
  //вызывается перед и после операций вставки, добавления, удаления строки в таблице вручную;
  //позволяет отменить операцию, выдать сообщение (можно с вопросом), либо выполнить действия после операции (зафиксировать строку, ввести значения)
  //также вызывается при сопуствующих им проверке строки и таблицы
  TFrDBGridEhRowOperationEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridRowOperationMode; Row: Integer; var Handled: Boolean; var Cancel: Boolean; var Msg: string) of object;


  {
  объект фрейма
  }
  TFrDBGridEh = class(TFrame)
    pnlContainer: TPanel;
    pnlGrid: TPanel;
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlBottom: TPanel;
    pnlStatusBar: TPanel;
    PRowDetailPanel: TPanel;
    lblStatusBarL: TLabel;
    PmGrid: TPopupMenu;
    MemTableEh1: TMemTableEh;
    ADODataDriverEh1: TADODataDriverEh;
    DataSource1: TDataSource;
    DbGridEh1: TDBGridEh;
    PrintDBGridEh1: TPrintDBGridEh;
    MemTableEh1Field1: TIntegerField;
    tmrAfterCreate: TTimer;
    CProp: TDBEditEh;
    ImgState: TImage;
    {собития фрейма}
    procedure FrameResize(Sender: TObject);
    procedure tmrAfterCreateTimer(Sender: TObject);
    procedure PStatusResize(Sender: TObject);
    {события датасета}
    procedure MemTableEh1AfterInsert(DataSet: TDataSet);
    procedure MemTableEh1AfterDelete(DataSet: TDataSet);
    procedure MemTableEh1BeforeInsert(DataSet: TDataSet);
    procedure MemTableEh1AfterOpen(DataSet: TDataSet);
    procedure MemTableEh1BeforeClose(DataSet: TDataSet);
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    {события датагрида}
    procedure DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean); virtual;
    procedure DbGridEh1ColEnter(Sender: TObject);
    procedure DbGridEh1SortMarkingChanged(Sender: TObject);
    procedure DbGridEh1DblClick(Sender: TObject);
    procedure DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DbGridEh1CellClick(Column: TColumnEh);
    procedure DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure DbGridEh1SearchPanelSearchEditChange(Grid: TCustomDBGridEh; SearchEdit: TDBGridSearchPanelTextEditEh);
    procedure DbGridEh1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure DbGridEh1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DbGridEh1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DbGridEh1CellMouseClick(Grid: TCustomGridEh; Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Processed: Boolean);
    procedure DbGridEh1FillSTFilterListValues(Sender: TCustomDBGridEh; Column: TColumnEh; Items: TStrings; var Processed: Boolean);
    procedure DbGridEh1ApplyFilter(Sender: TObject);
    procedure DbGridEh1RowDetailPanelHide(Sender: TCustomDBGridEh; var CanHide: Boolean);
    procedure DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
    procedure MemTableEh1AfterPost(DataSet: TDataSet);
  private
    {поля для свойств фрейма}
    //номер фрейма, если наименование имеет цифры в окончании
    FNo: Integer;
    //информация для инфоиконки
    FInfoArray: TVarDynArray2;
    //опции внешнего вида и возможностей грида, объединение комбинаций опций Options и OptionsEh
    FOptions: TFrDBGridOptions;
    //объект определения свойст фрейма
    FOpt: TFrDBGridEhOpt;
    //опции для редактирования грида в оффлайн-режиме
    FEditOptions: TFrDBGridEditOptions;
    //данные, используемые при редактировании грида
    FEditData: TFrDBGridEditData;
    //данные для начальной загрузки (sql, массив или TNamedArr), если что-то есть то
    //DataMode устанавливается в FromArray и данные автоматически загружаются.
    //Sql=* формирует sql автоматом по данным полей
    FInitData: TFrDBGridInitData;
    //ссылка на фрейм для детальной панели грида

    FGrid2: TFRDbgridEh;

    //признак ошибки в гриде. учитывается родительской формой
    FHasError: Boolean;
    //сообщение об ошибке в гриде. учитывается родительской формой
    FErrorMessage: string;
    //признак модификации данных в гриде. учитывается родительской формой
    FIsDataChanged: Boolean;
    //номер строки мемтейбла, возвращенный событием AfterScroll
    FLastRecNo: Integer;

    {внутренние переменные}
    //временный столбец для присвоения свойств и событий столбца грида, заданных в дизайнтайме, всем созданным динамически столбцам
    ColumnTemp: TColumnEh;
    //признак, что было установлено FIsDataChanged в гриде детальной панели
    FIsGrid2Changed: Boolean;
    //количество строк грида при последней отрисовке
    //(используем чтобы поймать фильтрацию грида в SearchString, когда исчезают все строки, или появляется первая)
    FLastRecordCount: Integer;
    //ключевая строка для возврата на прежнюю позицию при рефреш, сортировке
    FKeyString: string;
    //панели, в которых создавались кнопки
    FPanelsBtn: TComponentsArray;
    //Все АйДи кнопок и пунктов меню
    FBtnIds: TVarDynArray;
    //динамические свойства как у всех DbEh-Controls
    FDynProps: TDynVarsEh;
    //была выполнена настройка грида после первого открытия датасета, до поределенного этапа
    FIsPrepared: Boolean;
    //координаты ячейки грида, над которой сейчас мышка
    FMouseCoord: TGridCoord;
    //флаг процедуры загрузки данных в мемтейбл из массива/запроса
    FInLoadData: Boolean;
    //флаг показа служебных полей (по Ctrl+F3)
    FDevVisibleHidden: Boolean;
    //флаг, показывающий, что значения дополнительных колнтролов уже загружены из БД
    FIsAddControlsLoaded: Boolean;
    //последней применный фильтр, для быстрой отмены/восстановления
    FLastFilter: TVarDynArray2;
    //поля ID для таблицы, по которым есть метки
    FGridLabelsIds: TVarDynArray2;
    //был клик по иконке фильтра в столбце
    FLastFilterClick: Boolean;
    //произвольно задаваемый тект для статусбара; если не задан, то будет инфа о количестве записей; задается публичной процедурой
    FStatusBarText: string;
    //последний тект в статусбаре (чтобы не перерисовывать постоянно; при этом тормозит)
    FLastStatusBarText: string;
    //в обработчике события изменения доп. контрола
    FInAddControlChange: Boolean;
    FDisableChangeSelectedData: Boolean;
    //массив колоризованных лейблов из созданных контролов. они будут отрисованы после подгонки панелей, иначе сбивается отображение
    FLabelsColored: TVaRDynArray2;
    //события
    FOnCellButtonClick: TFrDBGridEhCellButtonClickEvent;
    FOnButtonClick: TFrDBGridEhButtonClickEvent;
    FOnSelectedDataChange: TFrDBGridEhSelectedDataChangeEvent;
    FOnSetSqlParams: TFrDBGridEhSetSqlParamsEvent;
    FOnColumnsUpdateData: TFrDBGridEhColumnsUpdateDataEvent;
    FOnAddControlChange: TFrDBGridEhAddControlChangeEvent;
    FOnColumnsGetCellParams: TFrDBGridEhColumnsGetCellParamsEvent;
    FOnGetCellReadOnly: TGetFrDBGridEhCellReadOnlyEvent;
    FOnDbClick: TFrDBGridEhDblClickEvent;
    FOnVeryfyAndCorrectValues: TFrDBGridEhVeryfyAndCorrectValuesEvent;
    FOnCellValueSave: TFrDBGridEhCellValueSaveEvent;
    FOnRowOperation: TFrDBGridEhRowOperationEvent;
  protected
    {функции и процедуры для получения и установки свойств поля которых определеня в разделе Private}

    function  GetID: Variant;
    function  GetRecNo: Integer;
    function  GetRecordCount: Integer;
    function  GetCurrField: string;
    function  GetCurrValue: Variant;
    procedure SetOptions(Value: TFrDBGridOptions);

    {события для объектов фрейма, присваеваемые динамически}

    //событие клика по кнопке или вызова пункта контекстного меню
    procedure ButtonOrPopupMenuClick(Sender: TObject); virtual;
    //событие onChange создаваемых динамически дополнительных контролов
    //при изменениии контролов в событии, событие onChange не вызывается!
    procedure AddControlChange(Sender: TObject);
    //собыьтие клика по кнопке в ячейке
    procedure CellButtonClick(Sender: TObject; var Handled: Boolean);
    //событие отрисовки кнопки в ячейке
    procedure CellButtonDraw(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; Canvas: TCanvas; Cell, AreaCell: TGridCoord; const ARect: TRect; ButtonDrawParams: TCellButtonDrawParamsEh; var Handled: Boolean);
    //событие при вводе данных в ячейку вручную через редактор
    procedure ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    //здесь получаются параметры ячейки, например запрет редактирования
    procedure ColumnsGetCellParams(Sender: TObject; EditMode: Boolean; Params: TColCellParamsEh);
    {общие процедуры}
    //создание информационной иконки в верхней панели кнопок
    procedure CreateInfoIcon;
    //получаем события столбца грида, которые есть в фрейме стразу, назначенные в дизайнтайме
    procedure GetColumnEvents;
    //добавляем столбцы в грид при работе с датадрайвером и присваиваем им поля
    //добавляем события столбцов, определенные в фрейме, и копируем события, определенные для столбца, имеющегося в гриде, в дизайнтайме
    procedure SetColumnsAndEvents;
    //отрисовка (изменение текста TLaberl) в панели статусбара грида
    procedure PrintStatusBar;
  public
    {события фрейма}
    property OnCellButtonClick: TFrDBGridEhCellButtonClickEvent read FOnCellButtonClick write FOnCellButtonClick;
    property OnButtonClick: TFrDBGridEhButtonClickEvent read FOnButtonClick write FOnButtonClick;
    property OnSelectedDataChange: TFrDBGridEhSelectedDataChangeEvent read FOnSelectedDataChange write FOnSelectedDataChange;
    property OnSetSqlParams: TFrDBGridEhSetSqlParamsEvent read FOnSetSqlParams write FOnSetSqlParams;
    property OnColumnsUpdateData: TFrDBGridEhColumnsUpdateDataEvent read FOnColumnsUpdateData write FOnColumnsUpdateData;
    property OnAddControlChange: TFrDBGridEhAddControlChangeEvent read FOnAddControlChange write FOnAddControlChange;
    property OnColumnsGetCellParams: TFrDBGridEhColumnsGetCellParamsEvent read FOnColumnsGetCellParams write FOnColumnsGetCellParams;
    property OnGetCellReadOnly: TGetFrDBGridEhCellReadOnlyEvent read FOnGetCellReadOnly write FOnGetCellReadOnly;
    property OnDbClick: TFrDBGridEhDblClickEvent read FOnDbClick write FOnDbClick;
    property OnVeryfyAndCorrectValues: TFrDBGridEhVeryfyAndCorrectValuesEvent read FOnVeryfyAndCorrectValues write FOnVeryfyAndCorrectValues;
    property OnCellValueSave: TFrDBGridEhCellValueSaveEvent read FOnCellValueSave write FOnCellValueSave;
    property OnRowOperation: TFrDBGridEhRowOperationEvent read FOnRowOperation write FOnRowOperation;

    {публичные свойства фрейма}

    property InfoArray: TVarDynArray2 read FInfoArray write FInfoArray;
    //номер фрейма (число), берется последний символ из названия, если это не цифра то будет -1
    property No: Integer read FNo;
    property Options: TFrDBGridOptions read FOptions write SetOptions;
    property Opt: TFrDBGridEhOpt read FOpt write FOpt;
    property EditOptions: TFrDBGridEditOptions read FEditOptions write FEditOptions;
    property EditData: TFrDBGridEditData read FEditData;
    property InitData: TFrDBGridInitData read FInitData;
    property Grid2: TFRDbgridEh read FGrid2 write FGrid2;
    //признак ошибки, тескт ошибки, признак модификации данных в гриде (устанавливаются вручную)
    property HasError: Boolean read FHasError;
    property ErrorMessage: string read FErrorMessage;
    property IsDataChanged: Boolean read FIsDataChanged;
    //айди текущей записи (всегда корректный; если датасет неактивен, то null)
    property ID: Variant read GetID;
    //имя текущего поля датасета
    property CurrField: string read GetCurrField;
    //значение текущего поля датасета (если датасет пуст то Unassigned)
    property CurrValue: Variant read GetCurrValue;
    //текущй номер строки мемтейбла
    property RecNo: Integer read GetRecNo;
    //номер строки мемтейбла, возвращенный событием AfterScroll (он бывает нужен; не вызывается например при прогрутке грида из-за присмения фильтра на изменение текущего столбца)
    property LastRecNo: Integer read FLastRecNo;
    //количество записей в датасете
    property RecordCount: Integer read GetRecordCount;
    //динамические свойства, аналогично DbEh-контролам
    property DynProps: TDynVarsEh read FDynProps;
    //прохождения этапа первого открытия грида
    property IsPrepared: Boolean read FIsPrepared;
    //признак того, что производится загрузка в мемтейбл, проверять в событиях мемтейбла в потомках
    property InLoadData: Boolean read FInLoadData write FInLoadData;
    //в обработчике события изменения доп. контрола
    property InAddControlChange: Boolean read FInAddControlChange write FInAddControlChange;

    {конструктор и деструктор}

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    {публичные функции возврата/установки свойств и значений}

    procedure SetInitData(Sql: string; Params: TVarDynArray); overload;
    procedure SetInitData(Arr: TVarDynArray2; ArrFields: string = ''; ArrColumns: string = ''); overload;
    procedure SetInitData(ArrN: TNamedArr); overload;

    //грид пуст (с учетом фитрации)
    function  IsEmpty: Boolean;
    //грид не пуст
    function  IsNotEmpty: Boolean;
    //получить количество строк таблицы (отфильрованных или нет)
    function  GetCount(Filtered: Boolean = true): Integer;
    //получить значение поля в текущей строке грида
    function  GetValue(FieldName: string = ''): Variant; overload;
    function  GetValueI(FieldName: string = ''): Integer; overload;
    function  GetValueF(FieldName: string = ''): Extended overload;
    function  GetValueS(FieldName: string = ''): string; overload;
    function  GetValueD(FieldName: string = ''): TDateTime; overload;
    //получить значение поля из внутреннего массива (отфильтрованных или всех зщаписей)
    function  GetValue(FieldName: string; Pos: Integer; Filtered: Boolean = true): Variant; overload;
    function  GetValueI(FieldName: string; Pos: Integer; Filtered: Boolean = true): Integer; overload;
    function  GetValueF(FieldName: string; Pos: Integer; Filtered: Boolean = true): Extended; overload;
    function  GetValueS(FieldName: string; Pos: Integer; Filtered: Boolean = true): string; overload;
    function  GetValueD(FieldName: string; Pos: Integer; Filtered: Boolean = true): TDateTime; overload;
    //установить значение поля в текущей записи. если поле не задано, использется поле текущего столбца. по умолчанию делает Post
    procedure SetValue(FieldName: string; NewValue: Variant; Post: Boolean = True); overload;
    //установить значение поля во внутреннем массиве (отфильтрованных или всех зщаписей)
    procedure SetValue(FieldName: string; Pos: Integer; Filtered: Boolean; NewValue: Variant); overload;
    //получить имя поля переданного столбца в нижнем регистре; если столбец не передан, то возвращается текущее поле
    function  GetColumnFieldName(Column: TObject = nil): string;
    //получить позицию в массиве столбцов Columns по значению DBGridEh1.Col или Cell.X
    function  GetCol(Col: Integer = -1): Integer;
    //получим, является ли данный столбец реадактируемыи
    function  IsColumnEditable(FieldName: string = ''): Boolean;
    //установить отметку в индикаторном столбце для переданных значений выбранного поля
    procedure SetIndicatorCheckBoxesByField(FieldName: string; Values: TVarDynArray);
    //получить ширину таблицы, посчитав ширины видимых столбцов
    function  GetTableWidth: Integer;


    {функции настройки фрейма, управления его свойствами во время выполнения}

    //начальная подготовка фркейма
    //вызывается вручную один раз после задания первичных настроек фрейма
    function  Prepare: Boolean;
    //создаем датасет по данным массива полей; используется в режиме загрузки из массива или командой скл, но не с DataDriver
    procedure CreateDataSet;
    //загружаем в таблицу данные, получаемые sql-запросом на основе списка полей данных,
    procedure LoadSourceDataFromSql(ASqlParams: TVarDynArray; AEmptyBefore: Boolean = true);
    //загружаем в таблицу данные из массива (предварительно таблицу очистив)
    procedure LoadSourceDataFromArray(AValues: TVarDynArray2; AFieldNames: string = ''; AArrayColumns: string = ''; AEmptyBefore: Boolean = true);
    procedure LoadData(AParams: TVarDynArray); overload;
    procedure LoadData(ASql: string; AParams: TVarDynArray; AEmptyTable: Boolean = true); overload;
    procedure LoadData(AValues: TVarDynArray2; AArrayFields: string; AArrayColumns: string; AEmptyTable: Boolean = true); overload;
    procedure LoadData(AValues: TNamedArr; AEmptyTable: Boolean = true); overload;


    //читает данные дополнительно созданных контролов из файла настроек пользователя, если не были уже прочитаы, или Force
    //срабоает автоматически при первом открытии или можно вызвать вручную в форме-владельце
    procedure ReadControlValues(Force: Boolean = False);
    //запись значений в файл настроек пользователя; вызывается автоматически при закрытии датасета или разрушении фрейма
    procedure WriteControlValues;
    //динамическое создание контролов в переданной панели (чекбоксы, комбобоксы...), с переданными именами, размерами, положением (x, y (yrefT))
    //передается имя панели, если таковой не найдено, то она создается и подгоняется по размеру,
    //исходя из положения и размеров контролов, а по высоте всегда 32.
    //чтобы панели с контролами вставлялись в панели кнопок, имя должно быть типа 'pnlTopBtnsCtl2'.
    //если имя - просто число, то генерируется имя для вставки в верхнюю панель.
    procedure CreateAddControls(ParentName: string; CType: TMyControlType; CLabel: string = ''; CName:
      string= ''; CVerify: string = ''; x: Integer = 1; y: Integer = yrefC; Width: Integer = 0; Tag: Integer = 0);
    //настройка свойст столбцов грида (размеры, кнопки, форматы, картинки...) по данным массива Opt.Fields фрейма
    //вызывается автоматически при открытии датасета, но может быть вызван вручную в случае если была
    //настройка параметров полецй Opt.SetColFeature
    //функция удалит и пересоздаст элементы, которые нельзя перенастроить
    procedure SetColumnsPropertyes;
    //обновим данные всей таблицы
    procedure RefreshGrid;
    //обновляем текущую строку грида, при ошибке выдаем сообщение об отсутсвии записи
    //вернем False в случае отстутствия записи в БД, или если она ушла из отфильтрованного грида после обновления
    function  RefreshRecord: Boolean;
    //устанавливает доступность кнопок и меню при изменении данных/позиции, в соотвествии с Opt.FButtonsIfEmpty; Всегда вызывается в ChangeSelectedData
    procedure SetButtonsState;
    //меняет заголовок пункта ПКМ или кнопки (для SpeedButton меняет Hint), и свойство Enabled,
    //находя элемент в переданных компонентах по тегу
    //чтобы не менять статус или текст заголовка, в данных полях ставить null!
    procedure SetBtnNameEnabled(ATag: Integer; AName: Variant; AEnabled: Variant);
    //показать/скрыть столбцы, в соотвествии с их настройками
    procedure SetColumnsVisible;
    //заморозить столбцы до столбца с указанным полем в Opt.FrozenColumn ,включительно; если пустое - снять заморозку
    //вызывается в SetColumnsVisible
    procedure FrozeColumn;
    //для долгих операций - затенить грид и вывести поясняющий текст
    procedure BeginOperation(AMessage: string = '');
    //для долгих операций - завершить (убрать текст и затенение)
    procedure EndOperation(AMessage: string = '');
    //сброс текущего ST-Filter с запоминанием его, и его восстановление, делается из ПКМ или по Ctrl-Q
    procedure ClearOrRestoreFilter;
    //установка цветовой метки на строке грида
    procedure SetGridLabel(Mode: Integer = 0);
    //переход к помеченной записи (+1 - вниз, -1 = вверх)
    procedure GoToGridLabel(Mode: Integer = +1);
    //установить статусы грида (изменения, ошибка, строка ошибки). обновить статус формы при изменении.
    //если значение передано как null, то оно не меняется
    procedure SetState(AIsDataChanged, AHasError, AErrorMessage: Variant);
    //установить произвольный тект в статусбаре; если пустой, то будет установлен дефолтный
    procedure SetStatusBarCaption(Caption: string = ''; AProcessMessages: Boolean = False);
    //получить значение контрола на фрейме по его имени
    //если установлено NullIfEmpty то вернуть null если значение равно пустое или ''
    function  GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
    //установить значение контрола принадлежащего фрейму по переданному имени контрола
    procedure SetControlValue(ControlName: string; Value: Variant);
    //ставка строки в таблицу в текущую позицию
    function InsertRow: Boolean;
    //добавление строки в конец таблицы
    function AddRow: Boolean;
    //удаление строки
    function DeleteRow: Boolean;
    //проверка, что все поля строки пустые (кроме невидимых, точнее с заголовками с _)
    function IsRowNotEmpty(RowNum: Integer = -1): Boolean;
    //проверка корректности строки
    function IsRowCorrect(RowNum: Integer = -1): Boolean;
    //проверка того, что вся таблица пуста (за исключение сервисных полей)
    function IsTableEmpty: Boolean;
    //проверка корректности всей таблицы
    function IsTableCorrect: Boolean;
    //зщдгчить размеры грида
    procedure GetGridDimensions(var AWidth, AHeight: Integer);
    //тестовая процедура
    procedure Test;

    {функции, вызываемые событиями во время работы или настройки фрейма}

    //настроим тулбар с кнопками и контекстное меню на основании переденных параметров
    function  SetButtonsAndMenu: Integer;
    //установим видимость и размеры панелей фрейма
    procedure SetPanels;
    //сформируем команду Селект для датадрайвера
    //вынесено потому, что она может меняться от условий в процессе работы (например из-за применения фильтра по кнопке тулбара)
    procedure SetDataDriverCommandSelect;
    //настроим команды датадрайвера
    procedure SetDataDriverCommands;
    //установить параметры запроса CommandType (переданные строкой через ;)
    //если параметр не найден в запросе, то он игнорируется
    procedure SetSqlParameters(ParamNames: string; ParamValues: TVarDynArray; CommandType: string = 's');
    //вызываем во всех случаях, когда мола измениться локация, или занчения данных в текущей строке
    //выполняет дефолтные действия при этом (доступность кнопок...) и вызывает соотвествующее события фрейма
    procedure ChangeSelectedData;
    //устанавливает размеры rorowDetailPanel; вызывается в событии показа панели
    procedure SetRowDetailPanelSize;
    //чтение меток таблицы из БД, вызывается в Prepare
    procedure ReadGridLabels;
    //показать информацию-подсказку по текущему столбку, если она есть в параметрах.
    //вызывается в гриде по F1
    procedure ShowColumnInfo;
    //настраивает и включает или отключает группировку по данным настроек; вызывается в SetColumnsPropertyes
    //просто включить или отключить можно свойством грида
    procedure DataGrouping;
 end;


implementation

uses
  madExcept,
  uErrors,
  uForms,
  uDBOra,
  uSettings,
  uWindows,
  uMessages,
  uSys,
  uLabelColors2,
  uFrmMain,
  uFrmBasicMdi,
  uFrmXWGridOptions,
  uFrmXDedtGridFilter
  ;



type TTest= Integer;

{$R *.dfm}


{
TFrDBGridEhOpt
}

constructor TFrDBGridEhOpt.Create(AOwner: TComponent);
//создадим класс опций
//присвоим опции по умолчанию
begin
  inherited Create;
  FrDBGridEh := AOwner;
  //поставим настройки по умолчанию
  //по умолчанию допускаем апдейт данных в гриде
  TFrDBGridEh(FrDBGridEh).DbGridEh1.AllowedOperations := [alopUpdateEh];
  //кнопки, которые доступны при пустом гриде
  FButtonsIfEmpty := [mbtRefresh, mbtAdd, mbtGridFilter, mbtGridSettings];
end;

procedure TFrDBGridEhOpt.SetFields(AFields: TVarDynArray2);
var
  i, j, k: Integer;
  st, st1: string;
  va1, va2, va3: TVarDynArray;
  fr: TFrDBGridRecFieldsList;

function GetNext: Boolean;
var
  i1, i2: Integer;
begin
  Result := True;
  //пропустим все булевые элементы, начиная с текущего
  while (j <= High(FSql.FieldsDef[i])) and (uString.S.VarType(FSql.FieldsDef[i][j]) = varBoolean) do
    inc(j);
  if j > High(FSql.FieldsDef[i]) then Exit;
  //если следующий элемент булев и это Ложь, перейдем на следующий (чтобы не обрабатывать текущее значение)
  if (j < High(FSql.FieldsDef[i])) and (uString.S.VarType(FSql.FieldsDef[i][j + 1]) = varBoolean) and (FSql.FieldsDef[i][j + 1] = False) then
    inc(j);
  if j > High(FSql.FieldsDef[i]) then Exit;
  Result := False;
end;

begin
  FSql.FieldsDef := AFields;
  FSql.Fields:=[];
  if Length(FSql.FieldsDef) = 0 then begin
    va1:= A.Explode(FSql.FieldNames, ';');
    if (Length(va2) = 0) then va2:= va1;
    va2:= A.Explode(FSql.Captions, ';');
    if (Length(va1) = 0) or (Length(va1) <> Length(va2)) then Exit;
    for i:= 0 to High(va1) do
      FSql.FieldsDef:= FSql.FieldsDef + [[va1[i], va2[i], '', true]];
  end;
  {
  for i:= 0 to High(FSql.FieldsDef) do begin
    SetLength(FSql.FieldsDef[i], 10);
    for j:= 0 to 2 do
      if VarIsClear(FSql.FieldsDef[i][j]) then FSql.FieldsDef[i][j]:= '';
    if VarIsClear(FSql.FieldsDef[i][3]) then FSql.FieldsDef[i][3]:= true;
  end;}
  for i:= 0 to High(FSql.FieldsDef) do begin
    //первый элемент массива всегда определение поля, разбиваем его на составляющие
    fr.FullName := FSql.FieldsDef[i][0];
    Q.ParseFieldNameFull(FSql.FieldsDef[i][0], st, fr.Name, fr.NameDb, st, fr.DataType, fr.FieldSize);
    //второй элемент всегда заголовок
    fr.Caption:= FSql.FieldsDef[i][1];
    //если начинается с подчеркивание - это служебное поле
    fr.Invisible:=Pos('_', fr.Caption) = 1;
    //если третий элемент (после имя поля и заголовка) булевый, и он False, то поле не будет учтено
    if (High(FSql.FieldsDef[i]) >= 2) and (uString.S.VarType(FSql.FieldsDef[i][2]) = varBoolean) and (FSql.FieldsDef[i][2] = False) then begin
      Continue;
    end;
    j := 1;
    SetFrValue(fr, 'D');
    SetFrValue(fr, 'CHB');
    SetFrValue(fr, 'CHBT');
    SetFrValue(fr, 'PIC');
    SetFrValue(fr, 'BT');
    SetFrValue(fr, 'E');
    SetFrValue(fr, 'V');
    SetFrValue(fr, 'F');
    SetFrValue(fr, 'NULL');
    SetFrValue(fr, 'T');
    SetFrValue(fr, 'I');
    fr.Visible := True;
//    SetFrValue(fr, '');
    repeat
      if GetNext then
        Break;
      SetFrValue(fr, FSql.FieldsDef[i][j], True);
      inc(j);
    until False;
    FSql.Fields := FSql.Fields + [fr];
  end;
  FSql.FieldNames:=''; FSql.Captions:='';
  for i:= 0 to High(FSql.Fields) do begin
    uString.S.ConcatStP(FSql.FieldNames, FSql.Fields[i].Name, ';');
    uString.S.ConcatStP(FSql.Captions, FSql.Fields[i].Caption, ';');
  end;
  if FSql.IdField =''
    then FSql.IdField:= FSql.Fields[0].Name;
end;

procedure TFrDBGridEhOpt.SetColFeature(AFields: string; AFeatype: string; ASet: Boolean = true; AClearOther: Boolean = False);
var
  i, j, k : Integer;
  st, st1: string;
  va: TVarDynArray;
begin
  if AClearOther then
    for i := 0 to High(FSql.Fields) do
      SetFrValue(FSql.Fields[i], AFeatype, False);
  va := A.Explode(AFields, ';');
  for j := 0 to High(va) do
    for i := 0 to High(FSql.Fields) do
      if (FSql.Fields[i].Name = va[j]) or uString.S.InCommaStr(va[j], FSql.Fields[i].FTags, ',') then
        SetFrValue(FSql.Fields[i], AFeatype, ASet);
end;

procedure TFrDBGridEhOpt.SetButtons(AIndex: Integer; AButtons: TVarDynArray2; AType: Integer = 1; APanel: TPanel = nil; AHeight: Integer = 0; AVertical: Boolean = False);
begin
  if High(FButtons) < AIndex then SetLength(FButtons, AIndex + 1);
  FButtons[AIndex].A := AButtons;
  FButtons[AIndex].T := AType;
  FButtons[AIndex].P := APanel;
  FButtons[AIndex].V := AVertical;
  FButtons[AIndex].H := AHeight;
end;

procedure TFrDBGridEhOpt.SetButtons(AIndex: Integer; AButtons: string = ''; ARight: Boolean = True);
const
  CButtons = 'rveacdo';
begin
  if AButtons = ''
    then AButtons := CButtons
    else if Pos('+', AButtons) = 1
      then AButtons := CButtons + Copy(AButtons, 2);
  SetButtons(AIndex, [
    [mbtSelectFromList, Pos('l', AButtons) > 0], [], [mbtRefresh, Pos('r', AButtons) > 0], [], [mbtView, Pos('v', AButtons) > 0], [],
    [mbtEdit, (Pos('e', AButtons) > 0) and ARight], [mbtAdd, (Pos('a', AButtons) > 0) and ARight],
    [mbtCopy, (Pos('c', AButtons) > 0) and ARight], [mbtDelete, (Pos('d', AButtons) > 0) and ARight], [],
    [mbtGridFilter, (Pos('f', AButtons) > 0)], [], [mbtGridSettings, (Pos('s', AButtons) > 0)], [],
    [mbtCtlPanel, (Pos('p', AButtons) > 0)]
  ]);
end;

procedure TFrDBGridEhOpt.SetTable(AView: string; ATable: string = ''; AIdField: string = ''; ARefreshBeforeSave: Boolean = True; ARefreshAfterSave: Boolean = True);
begin
  FSql.View := AView;
  FSql.Table := ATable;
  if (FSql.Table = '') and (Pos('v_', FSql.View) <> 1) then
    FSql.Table := FSql.View;
  if FSql.Table = '*' then
    FSql.Table := FSql.View;
  if AIdField <> '' then
    FSql.IdField := AIdField;
  FSql.RefreshBeforeSave := ARefreshBeforeSave;
  FSql.RefreshAfterSave := ARefreshAfterSave;
end;

procedure TFrDBGridEhOpt.SetSql(ASelect: string = ''; AGetRec: string = ''; AUpdate: string = ''; AInsert: string = ''; ADelete: string = '');
begin
  FSql.Select := ASelect;
  FSql.GetRec := AGetRec;
  FSql.Update := AUpdate;
  FSql.Insert := AInsert;
  FSql.Delete := ADelete;
end;

procedure TFrDBGridEhOpt.SetWhere(AWhereAllways: string = '');
begin
  FSql.WhereAllways := AWhereAllways;
end;

procedure TFrDBGridEhOpt.SetDataMode(ADataMode: TFrDBGridDataMode = myogdmWithAdoDriver);
begin
  FDataMode:= ADataMode;
end;

procedure TFrDBGridEhOpt.SetGridOperations(AOperations: string = 'u');
//допустимые для грида операции
//передаются строкой в любом регистре, наличие буквы-кода операции разрешает ее ('uiad')
//если эта функция не вызвана, в гриде будет разрешена alopUpdateEh
begin
  AOperations := UpperCase(AOperations);
  TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := [];
  if Pos('U', AOperations) > 0 then
    TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations + [alopUpdateEh];
  if Pos('U', AOperations) > 0 then
    FAllowedOperations := FAllowedOperations + [alopUpdateEh];
  if Pos('I', AOperations) > 0 then
    FAllowedOperations := FAllowedOperations + [alopInsertEh];
  if Pos('D', AOperations) > 0 then
    FAllowedOperations := FAllowedOperations + [alopDeleteEh];
  if Pos('A', AOperations) > 0 then
    FAllowedOperations := FAllowedOperations + [alopAppendEh];

{  if Pos('I', AOperations) > 0 then
    TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations + [alopInsertEh];
  if Pos('D', AOperations) > 0 then
    TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations + [alopDeleteEh];
  if Pos('A', AOperations) > 0 then
    TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations + [alopAppendEh];}
end;

procedure TFrDBGridEhOpt.SetGrouping(AFields: TVarDynArray; AFonts: TFontsArray; AColors: TColorsArray; AActive: Boolean);
//группировка
//передаются поля и статус активности группировки. если поля не переданы - они не изменяются.
//Если полей для группировки нет - она не включится
begin
  if Length(AFields) > 0
    then FDataGrouping.Fields := AFields;
  FDataGrouping.Fonts := AFonts;
  FDataGrouping.Colors := AColors;
  if Length(FDataGrouping.Fields) > 0
    then FDataGrouping.Active := AActive
    else FDataGrouping.Active := False;
end;

procedure TFrDBGridEhOpt.SetPick(AFieldName: string; APickList: TVarDynArray; AKeyList: TVarDynArray; ALimitTextToListValues: Boolean; AAlwaysShowEditButton: Boolean = True);
//добавляет запись в массив определений выпадающих списков в столбцах грида
var
  i: integer;
  rec: TFrDBGridEhPickRec;
begin
  i := 0;
  while (i <= High(FPickLists)) and (FPickLists[i].FieldName <> AFieldName) do
    inc(i);
  if i > High(FPickLists) then
    FPickLists := FPickLists +[rec];
  FPickLists[i].FieldName := AFieldName;
  FPickLists[i].PickList := APickList;
  FPickLists[i].KeyList := AKeyList;
  FPickLists[i].LimitTextToListValues := ALimitTextToListValues;
  FPickLists[i].AlwaysShowEditButton := AAlwaysShowEditButton;
end;


procedure TFrDBGridEhOpt.SetButtonsIfEmpty(AButtonsIfEmpty: TVarDynArray);
//установка кнопок, которые доступны при пустом гриде. если не вызывалась - там будут кнопки по умолчанию
//переданные кнопки добаляются к тем что по умолчанию!. чтобы очистить, сначала передайте пустой массив!
begin
  if Length(AButtonsIfEmpty) = 0
    then FButtonsIfEmpty := []
    else FButtonsIfEmpty := FButtonsIfEmpty + AButtonsIfEmpty;
end;

procedure TFrDBGridEhOpt.SetPanelsSaved(APanelsSaved: TVarDynArray);
begin
  FPanelsSaved := APanelsSaved;
end;

procedure TFrDBGridEhOpt.SetFieldVisible(AFieldName: string; AVisible: Boolean);
//вспомогательная процедура
//процедура нужна для установки свойства видимости столбца в рабочем массиве полей во внешних объектах (окно настроек, чтение настроек из бд)
var
  i: Integer;
begin
  for i := 0 to High(FSql.Fields) do
    if S.CompareStI(AFieldName, FSql.Fields[i].Name) then begin
      FSql.Fields[i].Visible := AVisible;
      Exit;
    end;
end;

function TFrDBGridEhOpt.GetFieldRec(AFieldName: string): TFrDBGridRecFieldsList;
var
  i: Integer;
begin
  for i := 0 to High(FSql.Fields) do
    if S.CompareStI(AFieldName, FSql.Fields[i].Name) then begin
      Result := FSql.Fields[i];
      Exit;
    end;
end;

procedure TFrDBGridEhOpt.SetFrValue(var fr: TFrDBGridRecFieldsList; AValue: string; ASet: Boolean = False);
var
  i, j, k: Integer;
  st, st1: string;
begin
  st := uString.A.Explode(uString.S.ToUpper(AValue), '=')[0];
  k := Length(st);
  if Pos('=', AValue) = k + 1 then
    Inc(k);
  st1 := Copy(AValue, k + 1);
  if (st = 'D') then
    if ASet
      then fr.DefOptions := st1
      else fr.DefOptions := '';
  if uString.S.IsInt(Copy(AValue, 1, 1)) then
    if ASet
      then fr.DefOptions := AValue
      else fr.DefOptions := '';
  if (st = 'CHB') then
    if ASet then begin
      fr.FChb := True;
      fr.FChbPic := st1;
    end
    else begin
      fr.FChb := False;
      fr.FChbPic := '';
    end;
  if (st = 'CHBT') then
    if ASet then begin
      fr.FChbt := True;
      fr.FChbtPic := st1;
    end
    else begin
      fr.FChbt := False;
      fr.FChbtPic := '';
    end;
  if (st = 'PIC') then
    if ASet
      then fr.FPic := uString.S.IIf(st1 = '', '1', st1)
      else fr.FPic := '';
  if (st = 'BT') then
    if ASet
      then fr.FBt := st1
      else fr.FBt := '';
  if (st = 'E') then
    if ASet then begin
      fr.Editable := True;
      if st1 <> '' then
        fr.FVerify := st1;
    end
    else
      fr.Editable := False;
  if (st = 'V') then
    if ASet
      then fr.FVerify := st1
      else fr.FVerify := '';
  if (st = 'F') then
    if ASet
      then fr.FFormat := uString.S.IIf(st1 = '', 'r', st1)
      else fr.FFormat := '';
  if (st = 'NULL') then
    if ASet
      then fr.FIsNull := True
      else fr.FIsNull := False;
  if (st = 'I') then
    if ASet
      then fr.Invisible := True
      else fr.Invisible := False;
  if (st = 'T') then
    if ASet
      then fr.FTags := st1
      else fr.FTags := '';
  if (st = 'C') then begin
    fr.Caption := st1;
  end;
end;










{===============================================================================

      TFrDBGridEh

===============================================================================}


{
КОНСТРУКТОР И ДЕСТРУКТОР
}

constructor TFrDBGridEh.Create(AOwner: TComponent);
//конструктор
begin
  inherited Create(AOwner);
  FOpt := TFrDBGridEhOpt.Create(Self);
  FDynProps := TDynVarsEh.Create(Self);
  FDynProps.CreateDynVar('vvv', 'qqq');
  pnlStatusBar.Height := 1;
  ColumnTemp := nil;
end;

destructor TFrDBGridEh.Destroy;
//деструктор
//будет вызван при разрушении главной формы для не-mdi-child
//в результате на данном этапе не работают запросы типа select - всегда разу получает признак EOF !!!
begin
  //сохраняем настроки фрейма, если датасет еще открыт
  //хотя в событии закрытия вызывается сохранение настроек, но событие не вызовется при разрушщении, дажде если здесь явно прописать MemTableEh1.Close !
  if (TFrmBasicMdi(Owner).FormDoc <> '') and (myogSaveOptions in Options) and (MemTableEh1.Active) then
    Settings.WriteFrDBGridEhSettings(TFrmBasicMdi(Owner).FormDoc, Self, False);
  if (TFrmBasicMdi(Owner).FormDoc <> '') then
    WriteControlValues;
  //разрцугшаем дополнительные объекты
  FOpt.Destroy;
  FDynProps.Destroy;
  if ColumnTemp <> nil then
    ColumnTemp.Destroy;
  inherited;
//  MadExcept.GetLeakReport;
end;

{
СОБЫТИЯ ФРЕЙМА
}

procedure TFrDBGridEh.FrameResize(Sender: TObject);
//при изменении размеров фрейма
var
  c, p: TControl;
begin
  //скорректируем панели (несмотря на выставленные якоря, если не менять их положение в этом событии, то авторасположение не работает)
  pnlGrid.Left:=pnlLeft.Left + pnlLeft.Width;
  pnlGrid.Width:=pnlTop.Width - pnlLeft.Width;
  pnlGrid.Top:=pnlTop.Top + pnlTop.Height;
  pnlGrid.Height:=pnlLeft.Height;
  //если есть иконка подсказки (всегад в верхней панеле кнопок), то изменим ее положение)
  c:=TControl(FindComponent('ImgInfo'));
  if c <> nil then begin
    c.Left := pnlGrid.Width - 36;
    //скроем иконку, если ушла под кнопки
    c.Visible := c.Left > TControl(FindComponent('pnlTopBtns')).Width;
  end;
end;

procedure TFrDBGridEh.tmrAfterCreateTimer(Sender: TObject);
//события таймера после создания фрейма
//если установлено в опциях, то сначала покажем окно с фреймом, в котором загружен грид без данных
//(загрузка данных по невыполнимому условию)
//а после подгружаем данные, что отображается надписью и затенением грида
begin
  if not (myogLoadAfterVisible in Options) then begin
    tmrAfterCreate.Enabled := False;
    Exit;
  end;
  if not TForm(Self.Owner).Visible then
    Exit;
  tmrAfterCreate.Enabled := False;
  RefreshGrid;
end;

procedure TFrDBGridEh.PStatusResize(Sender: TObject);
//выравнивает картинку стауса изменения/ошибки в статусбаре.
//если ей просто задать алигн, торможения при изменении размеров.
begin
  ImGState.Left := pnlStatusBar.Width - 18;
end;


{
СОБЫТИЯ МЕМТЕЙБЛА
}

procedure TFrDBGridEh.MemTableEh1AfterDelete(DataSet: TDataSet);
begin
//  IsTableCorrect;
end;

procedure TFrDBGridEh.MemTableEh1AfterInsert(DataSet: TDataSet);
begin
  if InLoadData then
    Exit;
//  Mth.PostAndEdit(MemTableEh1);
//  IsRowCorrect;
//  IsTableCorrect;
end;

procedure TFrDBGridEh.MemTableEh1AfterOpen(DataSet: TDataSet);
//событие при открытии датасета
begin
  //выйдем если это загрузка данных из массива
  if InLoadData then
    Exit;
  //установим события для столбцов грида
  SetColumnsAndEvents;
  //установим свойства столбцов грида, заданные в параметрах настроек в коде
  SetColumnsPropertyes;
  //установим параметры грида и столбцов, сохраненные в бд для пользователя
  if (TFrmBasicMdi(Owner).FormDoc <> '') and (myogSaveOptions in Options) then
    Settings.RestoreFrDBGridEhSettings(TFrmBasicMdi(Owner).FormDoc, Self);
  //метод для потомков после загрузки данных
  SetColumnsVisible;
  //установим флаг
  FIsPrepared := True;
  //установи опции грида
  SetOptions(Options);
  //сортируем грид
  if myogSorting in Options then
    DBGridEh1.DefaultApplySorting;
  //применим текущий филььтр
  DBGridEh1.DefaultApplyFilter;
  //событие перемещения фокуса
  ChangeSelectedData;
end;

procedure TFrDBGridEh.MemTableEh1AfterPost(DataSet: TDataSet);
//после выполнения Post;
begin
  if not ((alopInsertEh in FOpt.AllowedOperations) or (alopAppendEh in FOpt.AllowedOperations)) or
    (GetValue(FOpt.Sql.IdField) <> null) or (FOpt.DataMode = myogdmWithAdoDriver) then
    Exit;
  //только если была добавлена строка в оффлайн-режиме - вставим айди, если он еще путой
  //(это нужно например для сортировки)
  inc(FEditData.IdAdded);
  SetValue(FOpt.Sql.IdField, MY_IDS_INSERTED_MIN + FEditData.IdAdded);
end;

procedure TFrDBGridEh.MemTableEh1BeforeClose(DataSet: TDataSet);
//событие перед закрытием датасета
//сохраним настройки грида и значения дополнительных контролов
begin
  //сохраним настройки грида для пользователя, в случае, если мемтейбл еще активен
  if (TFrmBasicMdi(Owner).FormDoc <> '') and (myogSaveOptions in Options) and (MemTableEh1.Active) then
    Settings.WriteFrDBGridEhSettings(TFrmBasicMdi(Owner).FormDoc, Self, False);
  //сохраним значения дополнительных контролов
  if (TFrmBasicMdi(Owner).FormDoc <> '') then
    WriteControlValues;
  //снимем статусы изменения данных в гриде и ошибки
  SetState(False, False, '');
  //сбросим флаг
  FIsPrepared := False;
end;

procedure TFrDBGridEh.MemTableEh1BeforeInsert(DataSet: TDataSet);
begin
  //
end;

procedure TFrDBGridEh.MemTableEh1AfterScroll(DataSet: TDataSet);
//событие при перемещении по записям датасета
begin
  if InLoadData then Exit;
  FLastRecNo:=MemTableEh1.RecNo;
  ChangeSelectedData;
end;

{
СОБЫТИЯ ДАТАГРИДА
}

procedure TFrDBGridEh.DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh;
  const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
//отрисовка ячейки
//здесь отрабатываем отрисовку зеленой вертикальной полосы в редактируемызх стобцах,
//и полоски снизу если текущая ячейка редактируемая
var
  Rect: TRect;
begin
{
//так можно отрисовать объединенную по вертикали ячейку
//но получается некорректно, при проведении мышкой над ячейкамии в объединенных отрисовывается их содержимое
DbGridEh1.OptionsEh:=DbGridEh1.OptionsEh - [dghHighlightfocus, dghRowHighlight, dghHotTrack];
DbGridEh1.Options:=DbGridEh1.Options - [dgalwaysshowselection, dgalwaysshowEditor];
DbGridEh1.ShowHint := false;
if (areacell.y <= 3) and (areacell.X = 2) then begin
DbGridEh1.OptionsEh:=DbGridEh1.OptionsEh - [dghHighlightfocus, dghRowHighlight];
     Rect := ARect;
        Rect.Top := Rect.Top - 18*areacell.y;
        Rect.Height := 18*3;
      DBGridEh1.Canvas.FillRect(Rect);
      DBGridEh1.Canvas.TextOut(Rect.Left, Rect.Top + 2, 'QQQQQQQQQQ');
    end
    else
    Sender.DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
exit;
}
  if IsColumnEditable(Column.FieldName) and not DbGridEh1.ReadOnly then begin
    //отрисуем зеленую полоску слева для редактируемого столбца
    Sender.DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
    if myogHiglightEditableColumns in Options then
 //если здесь проверять, то можно отрисовывать вертикальную полоску только в редактируемых ячеках, но она может пропадать, надо дорабатывать
 //     if not Params.ReadOnly then
      with Sender.Canvas, ARect do begin
        if A.InArray(IntToStr(Cell.Y) + '-' + IntToStr(Cell.X), FEditData.CellsWithErrors)
          then Pen.Color := Rgb(255, 0, 0)
          else Pen.Color := Rgb(150, 255, 150);
        Pen.Style := psSolid;
        MoveTo(Left + 1, Top);
        LineTo(Left + 1, Bottom);
        MoveTo(Left + 2, Top);
        LineTo(Left + 2, Bottom);
        MoveTo(Left + 3, Top);
        LineTo(Left + 3, Bottom);
        MoveTo(Left + 4, Top);
        LineTo(Left + 4, Bottom);
      end;
    Processed := True;
    //обработка только по строчке, на которую был переход в MemTableEh1AfterScroll (FRecNo)
    //подсветку можно обрабатывать и для каждой отрисовываемой строчки, если убрать эту проверку,
    //но при открытии отрисовывает не сразу (после пролистывания)
    if MemTableEh1.Active and (MemTableEh1.RecordCount > 0) and (LastRecNo = RecNo) and (Column.Index = GetCol) //DBGridEh1.Col - S.IIf(myogIndicatorColumn in FOptions, 1, 0))
      and (myogHiglightEditableCells in Options) then begin
      if not Params.ReadOnly then
        //отрисуем зеленую полоску снизу в текущей (выбранной) ячейке, если она редактируемая
        with Sender.Canvas, ARect do begin
          Pen.Color := Rgb(150, 255, 150);
          Pen.Style := psSolid;
          MoveTo(Left, Bottom);
          LineTo(Right, Bottom);
          MoveTo(Left, Bottom - 1);
          LineTo(Right, Bottom - 1);
          MoveTo(Left, Bottom + 1);
          LineTo(Right, Bottom + 1);
        end;
      Processed := True;
    end;
  end;
  //вызываем тут отрисовку статусбара, не знаю иначе как поймать фильтр при наборе в верхней строке
  //чтобы не перерисовывать статусбар при каждой отрисовки ячейки грида, делаем это только при пустой таблице или при отрисовке текущей строки датасета
  if ((MemTableEh1.RecordCount = 0) or (Cell.Y = MemTableEh1.RecNo){ or DbGridEh1.DataGrouping.Active})
    then PrintStatusBar;
  //тут ловим опустошение/наполнение таблицы при наборе текста в SearchPanel
  //в событии SearchPanel onChange ловится неправильно, т.к. оно вызыввается до фильтрации датасета,
  //а событие AfterScroll в датасете при фильтре не вызывается
  if (MemTableEh1.RecordCount <> FLastRecordCount) then begin
    FLastRecordCount := MemTableEh1.RecordCount;
    ChangeSelectedData;
  end;
end;

procedure TFrDBGridEh.DbGridEh1ApplyFilter(Sender: TObject);
begin
  FLastFilterClick := False;
  DBGridEh1.DefaultApplyFilter;
end;


procedure TFrDBGridEh.DbGridEh1CellClick(Column: TColumnEh);
//событие по клике по столбцу
begin
  ChangeSelectedData;
end;

procedure TFrDBGridEh.DbGridEh1CellMouseClick(Grid: TCustomGridEh; Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Processed: Boolean);
//клик мыши в любой области грида
var
  i, j, k : Integer;
  ACol, ARow: Integer;
  AreaCol, AreaRow: Integer;
  Area: TCellAreaTypeEh;
begin
  //получим параметры области
  Area := DBGridEh1.GetCellAreaType(ACol, ARow, AreaCol, AreaRow);
  if Area.VertType = vctDataEh then;
  //Area.HorzType/VertType  так должен определять тайтл, но не работает! определяет неправильно, и в разных таблицах по-разному
  //определяем так
  if myogColumnFilter in Options then
    if (Area.HorzType = hctDataEh) {and (Area.VertType = vctDataEh)} and (Cell.Y > 0) and (Button = mbLeft) and FLastFilterClick then begin
      //если была нажата кнопка фильтра и он не применился (в событии OnApplyFilter флаг очистится)
      //то применим фильтр по клику в клентской части грида
      DbGridEh1.DefaultApplyFilter;
      FLastFilterClick := False;
    end;
  if myogColumnFilter in Options then
    if (Area.HorzType = hctDataEh) {and (Area.VertType = vctDataEh)} and (Cell.Y = 0) and (Button = mbLeft) then begin
      //получим номер столбца, скрытые учитываются, если есть индикаторнеый, то для него будет -1
      k := GetCol(Cell.X);
      if (k >= 0) and (X >= DBGridEh1.Columns[GetCol(Cell.X)].Width - 16) then begin
        //так должно отменить дефолтное действие, но не работает!
        Processed := True;
        //запомним, что был корее всего нажат фильтр
        FLastFilterClick := True;
        //MyInfoMessage(inttostr(Cell.X) + '  ' + DBGridEh1.Columns[GetCol(Cell.X)].Title.Caption);
      end;
    end;
  //ставим галку в индикаторном столбце, для случая, когда она должна быть единственной (hctIndicatorEh также не работает)
  if (Area.HorzType = hctDataEh) {and (Area.VertType = vctDataEh)} and (Cell.Y > 0) and (Cell.X = 0) and (Button = mbLeft) then begin
    if ((myogIndicatorCheckBoxes in Options) and not (myogMultiSelect in Options)) then  begin
      DBGridEh1.SelectedRows.Clear;
      DBGridEh1.SelectedRows.CurrentRowSelected := True;
    end;
    ChangeSelectedData;
    PrintStatusBar;
  end;
end;

procedure TFrDBGridEh.DbGridEh1ColEnter(Sender: TObject);
//событие при переходе в столбец
begin
  ChangeSelectedData;
end;

procedure TFrDBGridEh.DbGridEh1ContextPopup(Sender: TObject; MousePos: TPoint;  var Handled: Boolean);
//сюда попадем при вызове контектного меню
begin
  ChangeSelectedData;
  inherited;
end;

procedure TFrDBGridEh.DbGridEh1DblClick(Sender: TObject);
//двойной клие на гриде
var
  Handled: Boolean;
  BtnE, mbtV: TSpeedButton;
  T: Tpoint;
  MouseTop, MouseLeft: Integer;
  c: TComponent;
  i, j: Integer;
const
  MouseLeftIgnore = 70;
begin
   //получим положение курсора мыши относительно формы
  T := ScreenToClient(Self.FDesignSize);
  MouseTop := Mouse.CursorPos.Y + T.y;
  MouseLeft := Mouse.CursorPos.X + T.x;
//  if DBGridEh1.DataGrouping.Active and (DBGridEh1.Col < 4) then Exit;
  //если есть ровдетайлпанел, то даблклик с левого края проигнорируем, так как часто при клике по + открывается окно редактирования
  //надо тут еще добавить учет чекбоксов в заголовке строки
  if DBGridEh1.RowDetailPanel.Active and (MouseLeft < MouseLeftIgnore) then
    Exit;
  //вызовем событие
  Handled := False;
  if Assigned(FOnDbClick) then
    FOnDbClick(Self, No, Sender, Handled);
  //выйдем, если обработано
  if Handled then
    Exit;
  //получим наличие и состояние кнопок (они все есть в меню)
  c := nil;
  for j := PmGrid.ComponentCount - 1 downto 0 do begin
    c := PmGrid.Components[j];
    if (c.Tag = mbtSelectFromList) and (TMenuItem(c).Enabled) then
      Break;
  end;
  if j = -1 then
    for j := PmGrid.ComponentCount - 1 downto 0 do begin
      c := PmGrid.Components[j];
      if (c.Tag = mbtEdit) and (TMenuItem(c).Enabled) then
        Break;
    end;
  if j = -1 then
    for j := PmGrid.ComponentCount - 1 downto 0 do begin
      c := PmGrid.Components[j];
      if (c.Tag = mbtView) and (TMenuItem(c).Enabled) then
        Break;
    end;
  if (j >= 0) and (c <> nil) then
    TMenuItem(c).Click;
end;

procedure TFrDBGridEh.DbGridEh1FillSTFilterListValues(Sender: TCustomDBGridEh; Column: TColumnEh; Items: TStrings; var Processed: Boolean);
begin
  //модифицируем фильтр для полей, являющихся полными датами - сортировка по убыванию в фильтре и текущая дата сверху
  if Column.Field.DataType = ftDateTime then
    Gh.GridDateFilterModify(Sender, Column, Items, Processed, [S.ToLower(Column.FieldName)]);
end;

procedure TFrDBGridEh.DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh;
  AFont: TFont; var Background: TColor; State: TGridDrawState);
//здесь отрисовываем метки (меняем цвет шрифта строк таблицы)
var
  i, labelnum: Integer;
  currid: Variant;
  color: Integer;
  b: Boolean;
begin
  //раскрасим помеченные строки, если метки используются
  if myogGridLabels in Options then begin
    currid := ID;
    labelnum := 0;
    for i := 0 to High(FGridLabelsIds) do
      if FGridLabelsIds[i][0] = currid then begin
        labelnum := FGridLabelsIds[i][1];
        Break;
      end;
    case labelnum of
      0:
        color := clWindowText;
      1:
        color := clRed;
      2:
        color := clBlue;
      3:
        color := clFuchsia; //clGreen; //clLime
    end;
    if Abs(AFont.Color) <> Abs(color) then begin
      AFont.Color := color;
    end;
  end;
end;

procedure TFrDBGridEh.DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//нажатие клавиш в гриде
var
  i: Integer;
  st: string;
begin
  //переключим показ сервисных полей по Ctrl-F3, для девелопера или в DeveloperMode
  if (User.IsDeveloper or FrmMain.DeveloperMode) and (Key = VK_F3) and (Shift = [ssCtrl]) then begin
    FDevVisibleHidden := not FDevVisibleHidden;
    SetColumnsVisible;
  end;
  //обновить текущую запись
  if (Key = Ord('R')) and (Shift = [ssCtrl]) then
    RefreshRecord;
  //применить текущий фильтр
  //потребовалось, так как поломался фильтр по условиям, задаваемым в диалоговом окне
  if (Key = VK_F3) then
    DbGridEh1.DefaultApplyFilter;
  //подсказка по столбцу
  if (Key = VK_F1) then
    ShowColumnInfo;
  //скопировать в буфер текущее значение
  if (Key = Ord('C')) and (Shift = [ssCtrl]) then
    Clipboard.AsText := S.NSt(GetValue);
  if (Key = VK_DOWN) and (MemTableEh1.RecNo = MemTableEh1.RecordCount) then
    AddRow;
{  if (Key = VK_INSERT)  then
    InsertRow;}
  if (Key = VK_F8) then begin
    DbGridEh1.DefaultApplySorting;
    DbGridEh1.Invalidate;
  end;
end;

procedure TFrDBGridEh.DbGridEh1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//клик мышкой
begin
//
end;

procedure TFrDBGridEh.DbGridEh1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FMouseCoord := DbGridEh1.MouseCoord(X, Y);
end;

procedure TFrDBGridEh.DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
//раскрытие детальной панели
begin
  if FGrid2 = nil then
    Exit;
  //активирем датасет детального грида и связанные с открытием события (установка столбцов, виде)
  FGrid2.RefreshGrid;
  //после этого установим размеры детальной панели, учитывая размер данных в гриде
  SetRowDetailPanelSize;
end;

procedure TFrDBGridEh.DbGridEh1RowDetailPanelHide(Sender: TCustomDBGridEh; var CanHide: Boolean);
//скрытие детальной панели
var
  v : Variant;
begin
  if FGrid2 = nil then
    Exit;
  //здесь можно проверить статуст ошибки детального грида и запретить зщакрытие панели
  CanHide := not FGrid2.HasError and (FGrid2.ErrorMessage = '');
  if FGrid2.ErrorMessage <> '' then
    MyWarningMessage(FGrid2.ErrorMessage);
  if not CanHide then
    Exit;
  //детальный грид изменен?
  FIsGrid2Changed := FGrid2.IsDataChanged;
  FGrid2.MemTableEh1.Active := False;
  //перечитаем строку основного грида, если был изменен детальный
  if FIsGrid2Changed then
    RefreshRecord;
end;

procedure TFrDBGridEh.DbGridEh1SearchPanelSearchEditChange(Grid: TCustomDBGridEh; SearchEdit: TDBGridSearchPanelTextEditEh);
//изменения строки поиска/фильтра над таблицей
begin
  //срабатывает не совсем корректно, тк событие вызывает перед применением фильтра
//  ChangeSelectedData;
end;

procedure TFrDBGridEh.DbGridEh1SortMarkingChanged(Sender: TObject);
//вызывается при изменении маркеров сортировки грида, например кликом по заголовку
//если определена, то сортировку в ней надо вызывать вручную
begin
  inherited;
  //запомним ключевые поля
  FKeyString := Gh.GetGridServiceFields(DBGridEh1);
  if FKeyString <> '' then
    DBGridEh1.SaveVertPos(FKeyString);
  //применим сортировку
  DBGridEh1.DefaultApplySorting;
  //восстановим ключевые поля, если есть эта опция, и создана ключевая строка
  if (FKeyString <> '') and (myogSavePosWhenSorting in Options) then
    DBGridEh1.RestoreVertPos(FKeyString);
  //если нет опции сохранения позиции, переместим вверх
  if not (myogSavePosWhenSorting in Options) then
    MemTableEh1.First;
  ChangeSelectedData;
end;


{
ФУНКЦИИ И ПРОЦЕДУРЫ ДЛЯ ПОЛУЧЕНИЯ И УСТАНОВКИ СВОЙСТВ ПОЛЯ КОТОРЫХ ОПРЕДЕЛЕНЯ В РАЗДЕЛЕ pRIVATE
}

function TFrDBGridEh.GetID: Variant;
//получим айди текущей записи
//если датасет неактивен, или не задано поле айди, вернем нулл
begin
  Result := null;
  if MemTableEh1.Active and (FOpt.Sql.IdField <> '')
    then Result := MemTableEh1.FieldByName(FOpt.Sql.IdField).AsVariant;
end;

function TFrDBGridEh.GetRecNo: Integer;
begin
  Result := MemTableEh1.RecNo;
end;

function TFrDBGridEh.GetRecordCount: Integer;
begin
  Result := MemTableEh1.RecordCount;
end;


function TFrDBGridEh.GetCurrField: string;
//получим наименование текущего поля (поле данных текущего столбца) в нижнем регистре
begin
//  Result := LowerCase(DBGridEh1.Columns[DBGridEh1.Col - S.IIf(myogIndicatorColumn in FOptions, 1, 0)].Field.FieldName);
  Result := LowerCase(DBGridEh1.Columns[GetCol].Field.FieldName);
end;

function TFrDBGridEh.GetCurrValue: Variant;
//получим значение текущей ячейки (unassigned если таблица неакивна или в ней нет строк)
begin
  Result := GetValue;
end;

procedure TFrDBGridEh.SetOptions(Value: TFrDBGridOptions);
//установка наборов опций грида Options и OptionsEh на основе наших опций в тех комбинацияях,
//которые у нас испольуются, для настройки внешнего вида гридда и его функционала.
//также процедура устанавливает свойсто TFrDBGridEh.Options
var
  b: Boolean;
  i:Integer;
begin
  FOptions := Value;
  //до определенного момента инициализации не настраиваем грид, а только меняем набор своих опций
  //настройка до этого этапа приводит к проблемам отображения и работы
  if not FIsPrepared then
    Exit;
  //свегда устанавливаем преднастройки:
  if True then begin

    //3D-стиль грида
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghFixed3D, dghFrozen3D, dghFooter3D, dghData3D];
    //параметры заголовков
    DBGridEh1.TitleParams.BorderInFillStyle := False; //True;
    //градиентная заливка
    DBGridEh1.TitleParams.FillStyle := cfstGradientEh;
    //объединение заголовков и подзаголовки
    DBGridEh1.TitleParams.MultiTitle := True;
    //или цветная заливка заголовков, или стандартная серая
    if myogColoredTitle in FOptions then begin
      DBGridEh1.TitleParams.FillStyle := cfstGradientEh;
      if Module.StyleName = '' then DBGridEh1.TitleParams.SecondColor := clSkyBlue;
    end
    else begin
      DBGridEh1.TitleParams.FillStyle := cfstDefaultEh;
    end;
    //цвета клиентской части гридда
    //или подсветка через строку, или все одним (белым) цветом
    if (myogColoredEven in FOptions)and(Module.StyleName = '') then begin
      DBGridEh1.EvenRowColor := clWindow;
      DBGridEh1.OddRowColor := clCream;
    end
    else DBGridEh1.OddRowColor := clWindow;
    //
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghResizeWholeRightPart];
  //  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghAutoSortMarking];
    //сортировка по нескольким столбцам
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghMultisortMarking];
    //перемещение по Энтер по гриду
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghEnterAsTab];
    //Подсветка всей строки
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghRowHighlight];
    //подсветка строки, над которой находится курсор
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghHotTrack];
    //Показать номер записи в гиде
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghShowRecNo];
    //Заголовки в виде кнопок
    DBGridEh1.ColumnDefValues.Title.TitleButton := True;
  //  DBGridEh1.IndicatorOptions:=[gioShowRowIndicatorEh,gioShowRecNoEh,gioShowRowselCheckboxesEh];
    DBGridEh1.ShowHint := True;
    {Column.ToolTips
    Column.Title.ToolTips
    Column.Title.Hint}
    DBGridEh1.ColumnDefValues.ToolTips := true;
    DBGridEh1.ColumnDefValues.Title.ToolTips := true;
    //информацияя в окошечке поверх грида о том, что записей нет
    DBGridEh1.EmptyDataInfo.Active := True;
    DBGridEhEmptyDataInfoText := 'Записи отсутствуют';
    //подсветка строки целиком
    DBGridEh1.Options := DBGridEh1.Options - [dgRowSelect];
    //выделение фокуса рамкой
    DBGridEhDefaultStyle.IsDrawFocusRect := False;
  end;
  //локальная сортировка и фильтрация
  DBGridEh1.SortLocal := True;
  //локальная фильтрация
  DBGridEh1.STFilter.local := True;
  //фильтр в столбцах
  b := (myogColumnFilter in FOptions);
  DBGridEh1.STFilter.Visible := b;
  //фильтр в заголовке строки (иначе под заголовком)
  DBGridEh1.STFilter.Location := stflInTitleFilterEh;
  //отменим текущую фильтрацию в столбцах, если убрали опцию фильтра
  if not (b) and MemTableEh1.Active then
    Gh.GridFilterClear(DbGridEh1, True, False);
  if b then begin
    //!!! не понял пока за что ттвечает
    DBGridEh1.STFilter.InstantApply := False;
  end;
  //фильтр или поиск в панели
  b:=(myogPanelFilter in FOptions) or (myogPanelFind  in FOptions); //(myogColumnFilter in FOptions) or
  DBGridEh1.SearchPanel.Visible := (myogPanelFilter in FOptions) or (myogPanelFind  in FOptions);
  DBGridEh1.SearchPanel.Enabled := b; //(myogPanelFilter in FOptions) or (myogPanelFind  in FOptions);
  //панель поиска фильтрует грид, иначе поиск+отображание вхождений в гриде
  DBGridEh1.SearchPanel.FilterOnTyping := myogPanelFilter in FOptions;
  //сортировка по клику на колонке
  if myogSorting in FOptions then
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghAutoSortMarking, dghMultiSortMarking]    //отменяем возможность сортировки (здесь надо пройти еще по колонкам и убрать стрелочки сортировки, если где-то были)
    //отменяем возможность сортировки (здесь надо пройти еще по колонкам и убрать стрелочки сортировки, если где-то были)
    else begin
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh - [dghAutoSortMarking, dghMultiSortMarking];
    end;
  //изменение порядка столбцоы
  if myogColumnMove in FOptions
    then DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghColumnMove]
    else DBGridEh1.OptionsEh := DBGridEh1.OptionsEh - [dghColumnMove];
  //изменение ширины столбцов
  if myogColumnResize in FOptions
    then DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh + [dghColumnResize]
    else DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh - [dghColumnResize];
  //есть или нет индикаторный столбец
  if myogIndicatorColumn in FOptions
    then DBGridEh1.IndicatorOptions := DBGridEh1.IndicatorOptions + [gioShowRowIndicatorEh, gioShowRecNoEh]
    else DBGridEh1.IndicatorOptions := DBGridEh1.IndicatorOptions - [gioShowRowIndicatorEh, gioShowRecNoEh];
  //есть или нет чекбоксы в индикаторном столбце (с выделением многих или только одного, последенее обеспечивается еще кодом в событии)
  if myogIndicatorCheckBoxes in FOptions then begin
     DBGridEh1.IndicatorOptions := DBGridEh1.IndicatorOptions + [gioShowRowSelCheckBoxesEh];
     DBGridEh1.OptionsEh := DBGridEh1.OptionsEh - [dghClearSelection];
   end
   else begin
    DBGridEh1.IndicatorOptions := DBGridEh1.IndicatorOptions - [gioShowRowSelCheckBoxesEh];
   end;
   //мультивыделение строк (и индикаторных чекбоксов)
   if myogMultiSelect in FOptions
     then DBGridEh1.Options := DbGridEh1.Options + [dgMultiSelect]
     else DBGridEh1.Options := DbGridEh1.Options - [dgMultiSelect];
   //автоподгонка высоты строк
   if myogAutoFitRowHeight in FOptions
     then DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh + [dghAutoFitRowHeight]
     else DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh - [dghAutoFitRowHeight];
   //автоподгонка ширины столбцов доя заполнения таблицей всей области
   if myogAutoFitColWidths in FOptions then begin
     DBGridEh1.AutoFitColWidths := True;
     //!!!подгонка таблицы. это НЕЛЬЗЯ делать, при загрузке данных может через (-1, 2сек) вывалиться с ошибкой о нехватке системных ресурсов
     //DBGridEh1.OptimizeAllColsWidth(-1, 2);
   end
   else DBGridEh1.AutoFitColWidths := False;
//      DBGridEh1.STFilter.InstantApply := False;
   //почему-то, если скрыть панель статуса или сделать ее высоту = 0 то грид пропадает.
   //pnlStatusBar.Visible:= False;//myogHasStatusBar in FOptions;
  pnlStatusBar.Height := S.IIf(myogHasStatusBar in FOptions, MY_FORMPRM_LABEL_H + 4, 1);
  lblStatusBarL.Top := 2;
end;



{
СОБЫТИЯ ДЛЯ ОБЪЕКТОВ ФРЕЙМА, ПРИСВАЕВАЕМЫЕ ДИНАМИЧЕСКИ
}

procedure TFrDBGridEh.ButtonOrPopupMenuClick(Sender: TObject);
//клик по кнопке над (cбоку) гридом или по пункту контектного меню на записи грида
//проверит статус вызываемой кнопки, если недоступна то поправит его, и ничего не будет делать
//получит тег и вызовет событие родителя, если назначено.
//если не назначено, или событие не обработало этот тег, то произведет обработку по дефолту
var
  Tag: Integer;
  St: string;
  Handled: Boolean;
  i, j: Integer;
  fMode: TDialogType;
  DocCaption: TStringsEh;
begin
  //здесь мы проверяем в том числе доступность действия в зависимости от текущих данных
  Tag:= -1;
  ChangeSelectedData;
  //и если кнопка не заблокировалась, вызовем действие
  if (Sender is TButton) or  (Sender is TBitBtn) or (Sender is TSpeedButton) then
    if TButton(Sender).Enabled then
      Tag:=Integer(TButton(Sender).Tag);
  if Sender is TMenuItem then
    if TMenuItem(Sender).Enabled then
      Tag:=Integer(TSpeedButton(Sender).Tag);
  //если кнопка заблокировалась, то выходим
  if Tag = -1 then Exit;
  //получим режим (просмотреть, добавить, изменить, удалить, скопировать)
  fMode:=Cth.BtnModeToFMode(Tag);
  //если если fMode и задан FDialogFormDoc, вызовем диалог, событие родителя не вызываем
  if (FOpt.FDialogFormDoc <> '') and (fMode <> fNone) then begin
    Wh.ExecDialog(FOpt.FDialogFormDoc, TForm(Owner), [], fMode, ID, null);
    Exit;
  end;
  //вызовем событие родителя
  Handled:= False;
  if Assigned(FOnButtonClick)
    then FOnButtonClick(Self, FNo, Tag, fMode, Handled);
  //если кнопка обработана - выйдем
  if Handled then Exit;
  //если не обработана
  //обработаем дефолтные функции
  if Tag = mbtRefresh then begin
    //если не снять флаг, то какой-то конфликт и при нажатии кнопки Обновить и открытом детальном гриде, в котором были изменения,
    //то в процедуре обновления основного грида на memtableeh1.refresh виснет
    //!!! проверить, что происходит при нажатии других кнопок при этом флаге
//-    InRowPanelDataChanged := False;
    RefreshGrid;
//-    ChangeSelectedData;
  end
  else if Tag = mbtExcel then begin
    Gh.ExportGridToXlsxNew(DBGridEh1, Module.RunSaveDialog(StringReplace(Caption + ' ' + DateTimeToStr(Now), ':', '-', [rfReplaceAll]), 'xlsx'), true, Caption + ' ' + DateTimeToStr(Now), '');
  end
  else if (Tag = mbtPrint) or (Tag = mbtPrintGrid) then begin
    //DocCaption := TStringsEh.Create;
    //PrintDBGridEh1.BeforeGridText := DocCaption;
    //DocCaption.Append('---------%[Document] %[Today] %[UserName]');
    {PrintDBGridEh1.SetSubstitutes(['%[Today]', DateTimeToStr(Now), '%[UserName]', User.GetName, '%[Document]', Caption]);
    PrintDBGridEh1.Preview;}
    //DocCaption.Destroy;
    FrmMain.PrintDBGridEh1.DBGridEh := DbGridEh1;
    FrmMain.PrintDBGridEh1.SetSubstitutes(['%[Today]', DateTimeToStr(Now), '%[UserName]', User.GetName, '%[Document]', {TForm(Self.Owner).Caption]}Opt.FCaption]);
    FrmMain.PrintDBGridEh1.Preview;
  end
  else if Tag = mbtAddRow then begin
    AddRow;
  end
  else if Tag = mbtInsertRow then begin
    InsertRow;
  end
  else if Tag = mbtDeleteRow then begin
    DeleteRow;
  end
  else if Tag = mbtSetGridLabel then begin
    //установим метку на текущую запись в цикле
    SetGridLabel(-1);
  end
  else if Tag = mbtClearGridLabels then begin
    //очистим все метки по таблице
    SetGridLabel(-2);
  end
  else if Tag = mbtToGridLabelDown then begin
    //установим метку на текущую запись в цикле
    GoToGridLabel(+1);
  end
  else if Tag = mbtClearOrRestoreGridFilter then begin
    //сбросим/восстановим фильтр
    ClearOrRestoreFilter;
  end
  else if Tag = mbtSelectAll then begin
    //отметим все ОТФИЛЬТРОВАННЫЕ строки, скрытые не трогаем
    FDisableChangeSelectedData := True;
    Gh.SetGridIndicatorSelection(DbGridEh1, 1);
    FDisableChangeSelectedData := False;
    ChangeSelectedData;
  end
  else if Tag = mbtDeSelectAll then begin
    FDisableChangeSelectedData := True;
    Gh.SetGridIndicatorSelection(DbGridEh1, -1);
    FDisableChangeSelectedData := False;
    ChangeSelectedData;
  end
  else if Tag = mbtInvertSelection then begin
    FDisableChangeSelectedData := True;
    Gh.SetGridIndicatorSelection(DbGridEh1, 0);
    FDisableChangeSelectedData := False;
    ChangeSelectedData;
  end
  else if Tag = mbtGridSettings then begin
//    Dlg_GridOptions.DlgShow(Self, DBGridEh1);
    TFrmXWGridOptions.Show(Self, '', [myfoModal, myfoDialog, myfoSizeable], fNone, 1, null);
  end
  else if Tag = mbtGridFilter then begin
    if TFrmXDedtGridFilter.ShowModal2(Self, '', [myfoDialog], fEdit, 1, null).ModalResult = mrOk then
      RefreshGrid;
  end
  else if Tag = mbtSelectFromList then begin
    if MemTableEh1.RecordCount > 0 then begin
      //кнопка выбора/закрытия окна, используется в таблицах в которых надо выбраьть запись/записи, как правило в модальном режиме
      DbGridEh1.DataSet.DisableControls;
      //заполним одномерный массив данными текущей строки
      SetLength(Wh.SelectDialogResult, MemTableEh1.Fields.Count);
      for i := 0 to MemTableEh1.Fields.Count - 1 do
        Wh.SelectDialogResult[i] := MemTableEh1.fields[i].AsVariant;
      //заполним двухмерный массив данными всех отмеченных строк
      SetLength(Wh.SelectDialogResult2, 0);
      if (myogIndicatorCheckBoxes in Options) and (myogMultiSelect in Options) then begin
        //фильтр в толбцах не мешает, и собираются и те строки которые не видны, но!!! при включенном фильтре ПАНЕЛИ происходит ошика
        //MemTableEh1.RecordsView.MemTableData.RecordsList
        //DBGridEh1.STFilter.IsEmpty
        //DBGridEh1.ClearFilter;
        //DBGridEh1.DefaultApplyFilter;
        //сбросим фильтр в панели если есть
        if DBGridEh1.SearchPanel.SearchingText <> '' then begin
          DBGridEh1.SearchPanel.SearchingText := '';
          DBGridEh1.SearchPanel.ApplySearchFilter;
        end;
        //соберем все отмеченные записи, независимо от фильтрации
        for i := 0 to DBGridEh1.SelectedRows.Count - 1 do begin
          if not DBGridEh1.DataSet.BookmarkValid(DBGridEh1.SelectedRows[i]) then
            Continue;
          try
            DBGridEh1.DataSet.Bookmark := DBGridEh1.SelectedRows[i];          //ошибка при фильтре здесь, BookmarkValid не помогает
            SetLength(Wh.SelectDialogResult2, Length(Wh.SelectDialogResult2) + 1);
            SetLength(Wh.SelectDialogResult2[i], DBGridEh1.DataSet.Fields.Count);
            for j := 0 to DBGridEh1.DataSet.Fields.Count - 1 do
              Wh.SelectDialogResult2[i][j] := DBGridEh1.DataSet.Fields[j].AsVariant;
          except
          end;
        end;
      end;
      DbGridEh1.DataSet.EnableControls;
    end;
    TForm(Owner).Close;
  end;
end;

procedure TFrDBGridEh.AddControlChange(Sender: TObject);
//событие onChange создаваемых динамически дополнительных контролов
//при изменениии контролов в событии, событие OnAddControlChange не вызывается!
var i: Integer;
begin
  if FInAddControlChange then
    Exit;
  FInAddControlChange := True;
  //чекбоксы с тегом -2..-10 обработаем как радиобаттоны, а -11..-20 так же, но с возможностью снятия
  if (Sender is TDBCheckBoxEh) and (TControl(Sender).Tag >= -20) and (TControl(Sender).Tag <= -1) and IsPrepared then begin
    for i := 0 to ComponentCount - 1 do
      if (Components[i] is TDBCheckBoxEh) and (Sender <> Components[i]) and (TControl(Components[i]).Tag >= -20) and (TControl(Components[i]).Tag <= -1) then
        TDBCheckBoxEh(Components[i]).Checked := False;
    if (TControl(Sender).Tag >= -10) and (TControl(Sender).Tag <= -1) and (not TDBCheckBoxEh(Sender).Checked) then begin
      TDBCheckBoxEh(Sender).Checked := True;
      FInAddControlChange := False;
      Exit;
    end;
  end;
  if Assigned(FOnAddControlChange)
    then FOnAddControlChange(Self, FNo, Sender);
  FInAddControlChange := False;
end;

procedure TFrDBGridEh.CellButtonClick(Sender: TObject; var Handled: Boolean);
//события клика кнопки в ячейке
begin
  if Assigned(FOnCellButtonClick) and (IsNotEmpty) then
    FOnCellButtonClick(Self, No, Sender, Handled);
end;

procedure TFrDBGridEh.CellButtonDraw(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; Canvas: TCanvas; Cell, AreaCell: TGridCoord; const ARect: TRect; ButtonDrawParams: TCellButtonDrawParamsEh; var Handled: Boolean);
//отрисовка кнопок в гриде
//если это чекбокс, то отрисуем путой квадрат при путом значении в этом поле, и галку если оно не путое
//для остльных дефолтная отрисовка
var
  fr: TFrDBGridRecFieldsList;
begin
  fr := Opt.GetFieldRec(Column.FieldName);
  if fr.FChbt then begin
    if MemTableEh1.FieldByName(Column.FieldName).Value = null
      then ButtonDrawParams.ImageIndex := 0
      else ButtonDrawParams.ImageIndex := 1;
  end
  else
    inherited;
end;

procedure TFrDBGridEh.ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//событие при изменении данных вручную (вводе данных в ячейке)
var
  ReadOnly: Boolean;
  CorrectValue: Variant;
  FRec: TFrDBGridRecFieldsList;
  IsValueCorrect: Boolean;
  Msg: string;
  st: string;
  OldId: Variant;
  EvSaveHandled: Boolean;
begin
  if Assigned(FOnColumnsUpdateData)
    then FOnColumnsUpdateData(Self, No, Sender, Text, Value, UseText, Handled);
  if Handled then Exit;
  FRec := Opt.GetFieldRec(TColumnEh(Sender).FieldName);
  ReadOnly := False;
  Msg := '';
  if (FOpt.FDataMode = myogdmWithAdoDriver) and FOpt.Sql.RefreshBeforeSave then begin
    OldId := GetValue(FOpt.Sql.IdField);
    //выйдем, если запись исчезла после обновления (была любая ошибка при обновлении текущей записи)
    if not RefreshRecord then
      Exit;
    //выйдем, если после обновления изменилось айди текущей записи в гриде (например, обновленная запись исчезла из-за включенного фильтра в гриде)
    if OldId <> GetValue(FOpt.Sql.IdField) then
      Exit;
  end;
  //проверим, не стала ли текущая ячейка нередактируемой, вследствви обновления данных текущей строки из бд
  if Assigned(FOnGetCellReadOnly) then
    FOnGetCellReadOnly(Self, No, Sender, ReadOnly);
  if ReadOnly then begin
    //если редактировать нельзя, выходим (Cancel делать не обязательно если ставим Handled)
    Handled := True;
    Exit;
  end;
//st:=q.QGetDataTypeAsChar(MemTableEh1.fieldbyname(TColumnEh(Sender).FieldName).DataType);
  IsValueCorrect := (FRec.FVerify = '') or S.VeryfyValue(q.QGetDataTypeAsChar(TColumnEh(Sender).Field.DataType), FRec.FVerify, VarToStr(Value), CorrectValue);
  if IsValueCorrect and Assigned(FOnVeryfyAndCorrectValues) then
    FOnVeryfyAndCorrectValues(Self, No, dbgvBefore, RecNo, S.ToLower(TColumnEh(Sender).FieldName), Value, Msg);
  if not IsValueCorrect or (Msg <> '') then begin
    if Msg <> '-' then
      MyWarningMessage(S.IIf((Msg = '') or (Msg = '*'), 'Некорректное значение!', Msg));
    MemTableEh1.Cancel;
    Handled := True;
    Exit;
  end;
  //установим в текущей строке, по умолчанию делаем Post (фильтр в столбце сработает)
  if (FOpt.FDataMode <> myogdmWithAdoDriver) or not FOpt.Sql.RefreshAfterSave then
    SetValue(TColumnEh(Sender).FieldName, S.IIf(Text = '', null, Value));
  //проверим строку или всю таблицу
  if EditOptions.AlwaysVerifyAllTable then
    IsTableCorrect
  else
    IsRowCorrect;
  if Assigned(FOnCellValueSave) then
    FOnCellValueSave(Self, No, S.ToLower(TColumnEh(Sender).FieldName), S.IIf(Text = '', null, Value), EvSaveHandled);
  //если не обновлять, не изменятся зависимые поля
  if (FOpt.FDataMode = myogdmWithAdoDriver) then
    if FOpt.Sql.RefreshAfterSave
      then RefreshRecord;
  if Assigned(FOnVeryfyAndCorrectValues) then
    FOnVeryfyAndCorrectValues(Self, No, dbgvCell, RecNo, S.ToLower(TColumnEh(Sender).FieldName), Value, Msg);
  //обязательно
  Handled := True;
end;

procedure TFrDBGridEh.ColumnsGetCellParams(Sender: TObject; EditMode: Boolean; Params: TColCellParamsEh);
//событие установки дополнительных параметров ячейки
var
  ReadOnly: Boolean;
  fr: TFrDBGridRecFieldsList;
begin
  //установим возможность редактирования значения в ячейке.
  //функция ниже проверяет, есть ли столбец в списке редктируемых, и нет ли условий для запрета редактирования конкретной ячейки в зависимости от данных
  //в последенем случае обработчик события OnColumnsGetCellParams должен вернуть Params.ReadOnly = true
  fr := Opt.GetFieldRec(TColumnEh(Sender).FieldName);
  if Assigned(FOnColumnsGetCellParams) then
    FOnColumnsGetCellParams(Self, No, Sender, LowerCase(TColumnEh(Sender).FieldName), EditMode, Params);
  ReadOnly := Params.ReadOnly;
  if Assigned(FOnGetCellReadOnly) then
    FOnGetCellReadOnly(Self, No, Sender, ReadOnly);
  Params.ReadOnly := ReadOnly;
  Params.ReadOnly := not IsColumnEditable  or DbGridEh1.ReadOnly or Params.ReadOnly;
  //не разрешим редактировать ячейку если в ней имитация чекбокса с тектом (за исключением, когда там выбор из списка)
  if fr.FChbt and (TColumnEh(Sender).PickList.Count = 0) then
    Params.ReadOnly := True;
end;


procedure TFrDBGridEh.CreateInfoIcon;
//создаем информационную иконку в верхней панели кнопок, если таковая есть
var
  c: TControl;
begin
  if (pnlTop.Height < 10) or (Length(FInfoArray) = 0) then
    Exit;
  c := TImage.Create(Self);
  c.Name := 'ImgInfo';
  c.Parent := pnlTop;
  c.Left := pnlGrid.width;
  c.Top := 2;
  Cth.SetInfoIcon(TImage(c), Cth.SetInfoIconText(TForm(Self), InfoArray), S.IIf(pnlTop.Height > 10, 32, 24));
end;

procedure TFrDBGridEh.GetColumnEvents;
//получаем события столбца грида, которые есть в фрейме стразу, назначенные в дизайнтайме
var
  i: Integer;
begin
  ColumnTemp := TColumnEh.Create(nil);
  ColumnTemp.OnCellDataLinkClick := DbGridEh1.Columns[0].OnCellDataLinkClick;
  ColumnTemp.OnDropDownBoxTitleBtnClick := DbGridEh1.Columns[0].OnDropDownBoxTitleBtnClick;
  ColumnTemp.OnAdvDrawDataCell := DbGridEh1.Columns[0].OnAdvDrawDataCell;
end;

procedure TFrDBGridEh.SetColumnsAndEvents;
//добавляем столбцы в грид при работе с датадрайвером и присваиваем им поля
//добавляем события столбцов, определенные в фрейме, и
//копируем события, определенные для столбца, имеющегося в гриде, в дизайнтайме
var
  i, j: Integer;
begin
  //добавляем столбцы в грид.
  //это приходится делать из-за того, что в дизайнтайме создан столбец (задел на копирование событий столбуа,\
  //присвоенных в дизайнтайме, на другие столбцы).
  //в случае если хоотя бы один столбец есть на момент активации датасета с адодрайвером, столбцы полученные запросом в грид не добавляются!
  j:= DbGridEh1.Columns.Count;
  for i:= 0 to MemTableEh1.Fields.Count - 1 do begin
    if i >= j then begin
      DbGridEh1.Columns.Add;
    end;
{    if Assigned(DbGridEh1.Columns[0].onGetCellParams)
      then DbGridEh1.Columns[DbGridEh1.Columns.Count - 1].onGetCellParams := DbGridEh1.Columns[0].onGetCellParams;
      DbGridEh1.Columns[DbGridEh1.Columns.Count - 1].onUpdateData := DbGridEh1.Columns[0].onUpdateData;
      if Assigned(DbGridEh1.Columns[0].onEditButtonClick)
        then DbGridEh1.Columns[DbGridEh1.Columns.Count - 1].onEditButtonClick := DbGridEh1.Columns[0].onEditButtonClick;
    end;
    DbGridEh1.Columns[i].onGetCellParams:= ColumnsGetCellParams;
    DbGridEh1.Columns[i].OnUpdateData:= ColumnsUpdateData;}
    DbGridEh1.Columns[i].Field :=MemTableEh1.Fields[i];
  end;

  //!!! сюда добавить другие события
  for i := 0 to DbGridEh1.Columns.Count - 1 do begin
    //добавляем события столбцов, определенные в фрейме
    DbGridEh1.Columns[i].onGetCellParams := ColumnsGetCellParams;
    DbGridEh1.Columns[i].OnUpdateData := ColumnsUpdateData;
    //копируем события, определенные для столбца, имеющегося в гриде, в дизайнтайме
    DbGridEh1.Columns[i].OnCellDataLinkClick := ColumnTemp.OnCellDataLinkClick;
    DbGridEh1.Columns[i].OnDropDownBoxTitleBtnClick := ColumnTemp.OnDropDownBoxTitleBtnClick;
    DbGridEh1.Columns[i].OnAdvDrawDataCell := ColumnTemp.OnAdvDrawDataCell;
  end;
//  ColumnTemp.Destroy;
end;

procedure TFrDBGridEh.PrintStatusBar;
//инфа по таблице в статусбаре
var
  st, st1: string;
begin
  try
  //выйдем, если нет статусбара (при остсутствии высота = 1)
  if pnlStatusBar.Height < 10 then Exit;
  //проверим и выйдем, если новый текст такой же, как последний отрисованны
  st1 := Opt.FCaption;
  if FStatusBarText = '' then begin
    if Pos('~', st1) = 1 then
      Delete(st1, 1, 1);
    st := S.IIfStr(st1 <> '', '$FF0000' + st1 + '$000000' + ':  ') + Gh.GetGridInfoStr(DbGridEh1);
  end
  else st := FStatusBarText;
  if st = FLastStatusBarText then begin
    st := '';
    Exit;
  end;
  FLastStatusBarText := st;
  //установим цветной текст в лейбле
  lblStatusBarL.SetCaption2(st);
  //событие изменения состояния ячеек (чтобы можно было среагировать например на измениние состояния фильтра и чекбоксов в индикаторе)
  ChangeSelectedData;
  except
  end;
end;



{
ПУБЛИЧНЫЕ ФУНКЦИИ ВОЗВРАТА/УСТАНОВКИ СВОЙСТВ И ЗНАЧЕНИЙ
}

procedure TFrDBGridEh.SetInitData(Sql: string; Params: TVarDynArray);
//устанавливает начальные данные для загрузки, если грид не онлайн
begin
  FInitData.IsDefined := True;
  Opt.SetDataMode(myogdmFromArray);
  FInitData.Sql := Sql;
  FInitData.Params := Params;
end;

procedure TFrDBGridEh.SetInitData(Arr: TVarDynArray2; ArrFields: string = ''; ArrColumns: string = '');
begin
  FInitData.IsDefined := True;
  Opt.SetDataMode(myogdmFromArray);
  FInitData.Arr := Arr;
  FInitData.ArrFields := ArrFields;
  FInitData.ArrColumns := ArrColumns;
end;

procedure TFrDBGridEh.SetInitData(ArrN: TNamedArr);
begin
  FInitData.IsDefined := True;
  Opt.SetDataMode(myogdmFromArray);
  FInitData.ArrN := ArrN;
end;

function TFrDBGridEh.IsEmpty: Boolean;
//вернем True, если таблица пуста
begin
  Result:= (not MemTableEh1.Active) or (MemTableEh1.RecordCount = 0);
end;

function TFrDBGridEh.IsNotEmpty: Boolean;
//вернем True, если таблица не пуста
begin
  Result:= not IsEmpty;
end;

function TFrDBGridEh.GetCount(Filtered: Boolean = True): Integer;
//получить количество строк таблицы (отфильрованных или нет)
begin
  if Filtered
    then Result:= MemTableEh1.RecordsView.Count
    else Result:= MemTableEh1.RecordsView.MemTableData.RecordsList.Count;
end;

function TFrDBGridEh.GetValue(FieldName: string = ''): Variant;
//получить значение поля в текущей строке грида
begin
  Result := null;
  if (not MemTableEh1.Active) or (MemTableEh1.RecordCount = 0) then Exit;
  if FieldName = '' then FieldName:= GetCurrField;
  Result:= MemTableEh1.FieldByName(FieldName).Value;
end;

function TFrDBGridEh.GetValueI(FieldName: string = ''): Integer;
begin
  Result := S.NInt(GetValue(FieldName));
end;

function  TFrDBGridEh.GetValueF(FieldName: string = ''): Extended;
begin
  Result := S.NNum(GetValue(FieldName));
end;

function  TFrDBGridEh.GetValueS(FieldName: string = ''): string;
begin
  Result := S.Nst(GetValue(FieldName));
end;

function  TFrDBGridEh.GetValueD(FieldName: string = ''): TDateTime;
begin
  Result := VarToDateTime(GetValue(FieldName));
end;

function TFrDBGridEh.GetValue(FieldName: string; Pos: Integer; Filtered: Boolean = true): Variant;
//получить значение поля из внутреннего массива (отфильтрованных или всех зщаписей)
begin
  if Filtered
    then Result:= MemTableEh1.RecordsView[Pos].DataValues[FieldName, dvvValueEh]
    else Result:= MemTableEh1.RecordsView.MemTableData.RecordsList[Pos].DataValues[FieldName, dvvValueEh];
end;

function TFrDBGridEh.GetValueI(FieldName: string; Pos: Integer; Filtered: Boolean = true): Integer;
begin
  Result := S.NInt(GetValue(FieldName, Pos, Filtered));
end;

function TFrDBGridEh.GetValueF(FieldName: string; Pos: Integer; Filtered: Boolean = true): Extended;
begin
  Result := S.NNum(GetValue(FieldName, Pos, Filtered));
end;

function TFrDBGridEh.GetValueS(FieldName: string; Pos: Integer; Filtered: Boolean = true): string;
begin
  Result := S.NSt(GetValue(FieldName, Pos, Filtered));
end;

function TFrDBGridEh.GetValueD(FieldName: string; Pos: Integer; Filtered: Boolean = true): TDateTime;
begin
  Result := VarToDateTime(GetValue(FieldName, Pos, Filtered));
end;

procedure TFrDBGridEh.SetValue(FieldName: string; NewValue: Variant; Post: Boolean = true);
//установить значение поля в текущей записи
begin
  if FieldName = '' then
    FieldName := GetCurrField;
  MemTableEh1.Edit; //!!!
  MemTableEh1.FieldByName(FieldName).Value := NewValue;
  if Post then
    Mth.PostAndEdit(MemTableEh1); //!!!07-06-25
end;

procedure TFrDBGridEh.SetValue(FieldName: string; Pos: Integer; Filtered: Boolean; NewValue: Variant);
//установить значение поля во внутреннем массиве (отфильтрованных или всех зщаписей)
begin
  if Filtered
    then MemTableEh1.RecordsView[Pos].DataValues[FieldName, dvvValueEh] := NewValue
    else MemTableEh1.RecordsView.MemTableData.RecordsList[Pos].DataValues[FieldName, dvvValueEh] := NewValue;
end;

function TFrDBGridEh.GetColumnFieldName(Column: TObject = nil): string;
//получить имя поля переданного столбца в нижнем регистре; если столбец не передан, то возвращается текущее поле
begin
  if Column = nil
    then Result := GetCurrField
    else Result := LowerCase(TColumnEh(Column).FieldName);
end;

function TFrDBGridEh.GetCol(Col: Integer = -1): Integer;
//получить позицию в массиве столбцов Columns по значению DBGridEh1.Col или Cell.X
begin
  Result := S.IIf(Col = -1, DBGridEh1.Col, Col) - S.IIf(myogIndicatorColumn in FOptions, 1, 0);
end;

function TFrDBGridEh.IsColumnEditable(FieldName: string = ''): Boolean;
//получим, является ли данный столбец реадактируемыи
var
  i: Integer;
begin
  Result := False;
  if FieldName = '' then
    FieldName := CurrField;
  for i := 0 to High(FOpt.Sql.Fields) do
    if S.CompareStI(FOpt.Sql.Fields[i].Name, FieldName) then begin
      Result := FOpt.Sql.Fields[i].Editable;
      Exit;
    end;
end;

procedure TFrDBGridEh.SetIndicatorCheckBoxesByField(FieldName: string; Values: TVarDynArray);
//установить отметку в индикаторном столбце для переданных значений выбранного поля
var
  rn: Integer;
  va2: TVarDynArray2;
  KeyString: string;
begin
  if Length(Values) = 0 then
    Exit;
  InLoadData := True;
  va2 := Gh.GridFilterSave(DbGridEh1);
  //KeyString := Gh.GetGridServiceFields(DBGridEh1);
  //DBGridEh1.SaveVertPos(KeyString);
  Gh.GridFilterClear(DbGridEh1);
  MemTableEh1.DisableControls;
  rn := MemTableEh1.RecNo;
  MemTableEh1.First;
  while not MemTableEh1.Eof do begin
//    DbGridEh1.SelectedRows.CurrentRowSelected := A.InArray(MemTableEh1.FieldByName(FieldName).Value, Values);
    if A.InArray(MemTableEh1.FieldByName(FieldName).Value, Values) then
      DbGridEh1.SelectedRows.CurrentRowSelected := True;
    MemTableEh1.Next;
  end;
  MemTableEh1.RecNo := rn;
  Gh.GridFilterRestore(DbGridEh1, va2);
  InLoadData := False;
  MemTableEh1.EnableControls;
  try
    if KeyString <> '' then
      DBGridEh1.RestoreVertPos(KeyString);  //здесь может возникать ошибка, причину пока не отследил.
  except
  end;
end;

function TFrDBGridEh.GetTableWidth: Integer;
//получить ширину таблицы, посчитав ширины видимых столбцов
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    if DBGridEh1.Columns[i].Visible then
      Result := Result + DBGridEh1.Columns[i].Width;
end;


{
ФУНКЦИИ НАСТРОЙКИ ФРЕЙМА, УПРАВЛЕНИЯ ЕГО СВОЙСТВАМИ ВО ВРЕМЯ ВЫПОЛНЕНИЯ
}


function TFrDBGridEh.Prepare: Boolean;
//начальная подготовка фркейма
//вызывается вручную один раз после задания первичных настроек фрейма
var
  i: Integer;
begin
  //скопирем методы столбца фрейма, назаначенные в дизайнтайме, временному столбцу
  GetColumnEvents;
  //очистим датасет
  MemTableEh1.Fields.Clear;
  //получим номер фрейма
  FNo := StrToIntDef(S.Right(Self.Name, 1), -1);
  //заголовок фрейма, если он не задан, приравниваем к заголовку формы (здесь, тк при создании фрейма может не быть заголовка формы)
  if Opt.Caption = '' then
    Opt.Caption := TForm(Owner).Caption;
  //установим параметры грида и столбцов, сохраненные в бд для пользователя
  //так как датасет неактивен, прочитаются только параметры фильтра
  if (TFrmBasicMdi(Owner).FormDoc <> '') and (myogSaveOptions in Options) then
    Settings.RestoreFrDBGridEhSettings(TFrmBasicMdi(Owner).FormDoc, Self);
  //создадим датасет для режимов без адодрайвера
  if FOpt.DataMode <> myogdmWithAdoDriver then
    CreateDataSet;
  //создадим панели кнопок и контектное меню
  SetButtonsAndMenu;
  //настроим дополнительные панели фрейма
  SetPanels;
  //отрисуем колоризованные лейблы
  for i := 0 to High(FLabelsColored) do
    TLabelClr(FindComponent(FLabelsColored[i][0])).SetCaption2(FLabelsColored[i][1]);
  //установим иконку информации
  CreateInfoIcon;
  //загрузим пользовательские метки для таблицы
  ReadGridLabels;
  //если задан грид для детальной панели, активируем панель, поменяем родителя грида на нее, сделаем грид видимым
  if (FGrid2 <> nil) and (Length(FGrid2.Opt.Sql.FieldsDef) > 0) then begin
    FOptions := FOptions + [myogRowDetailPanel];
    FGrid2.Parent := PRowDetailPanel;
    FGrid2.Visible := True;
  end;
  //включим RowDetailPanel
  DbGridEh1.RowDetailPanel.Active := myogRowDetailPanel in FOptions;
  //события начедения мыши и клика по картинке в статусбаре
  ImGState.OnMouseEnter := Module.InfoOnMouseEnter;
  ImGState.OnMouseLeave := Module.InfoOnMouseLeave;
  ImGState.OnClick := Module.InfoOnClick;
  Result := True;
end;

procedure TFrDBGridEh.CreateDataSet;
//создаем датасет по данным массива полей; используется в режиме загрузки из массива или командой скл, но не с DataDriver
var
  i: Integer;
begin
  MemTableEh1.Active := False;
  MemTableEh1.DataDriver := nil;
  MemTableEh1.FieldDefs.Clear;
  for i := 0 to High(Opt.Sql.Fields) do
    MemTableEh1.FieldDefs.Add(Opt.Sql.Fields[i].Name, Opt.Sql.Fields[i].DataType, Opt.Sql.Fields[i].FieldSize, False);
  MemTableEh1.CreateDataset;
  MemTableEh1.Active := True;
end;

procedure TFrDBGridEh.LoadSourceDataFromSql(ASqlParams: TVarDynArray; AEmptyBefore: Boolean = true);
//загружаем в таблицу данные, получаемые sql-запросом на основе списка полей данных,
begin
  InLoadData := true;
  MemTableEh1.ReadOnly := False;
  Q.QLoadToMemTableEh(Q.QSIUDSql('s', Opt.Sql.View, Opt.Sql.FieldNames), ASqlParams, MemTableEh1, '', 0);
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadSourceDataFromArray(AValues: TVarDynArray2; AFieldNames: string = ''; AArrayColumns: string = ''; AEmptyBefore: Boolean = true);
//загружаем в таблицу данные из массива (предварительно таблицу очистив)
var
  i, j:Integer;
begin
  InLoadData := true;
  MemTableEh1.ReadOnly := False;
  Mth.LoadGridFromVa2(DBGridEh1, AValues, AFieldNames, AArrayColumns, AEmptyBefore);
  MemTableEh1.First;
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadData(AParams: TVarDynArray);
begin
  InLoadData := True;
  SetDataDriverCommandSelect;
  Q.QLoadFromQuery(ADODataDriverEh1.SelectSQL.Text, AParams, DBGridEh1, True);
  MemTableEh1.First;
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadData(ASql: string; AParams: TVarDynArray; AEmptyTable: Boolean = true);
begin
  InLoadData := True;
  if ASql = '*' then
    LoadData(AParams)
  else
    Q.QLoadFromQuery(ASql, AParams, DBGridEh1, True);
  MemTableEh1.First;
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadData(AValues: TVarDynArray2; AArrayFields: string; AArrayColumns: string; AEmptyTable: Boolean = true);
begin
  InLoadData := True;
  MemTableEh1.ReadOnly := False;
  Mth.LoadGridFromVa2(DBGridEh1, AValues, S.IfEmptyStr(AArrayFields, Opt.Sql.FieldNames), AArrayColumns, AEmptyTable);
  MemTableEh1.First;
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadData(AValues: TNamedArr; AEmptyTable: Boolean = true);
begin
  InLoadData := True;
  Mth.LoadGridFromNamedArray(DBGridEh1, AValues, True, AEmptyTable);
  MemTableEh1.First;
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.ReadControlValues(Force: Boolean = False);
//читает данные дополнительно созданных контролов из файла настроек пользователя, если не были уже прочитаы, или Force
begin
  if FIsAddControlsLoaded and not Force then
    Exit;
  if Length(Opt.FPanelsSaved) > 0 then
    Cth.SetControlValuesArr2(TForm(Self), Cth.DeSerializeControlValuesArr2(Settings.ReadProperty(TFrmBasicMdi(Owner).FormDoc, Name + '.Controls')));
  FIsAddControlsLoaded := True;
end;

procedure TFrDBGridEh.WriteControlValues;
//запись значений в файл настроек пользователя; вызывается автоматически при закрытии датасета или разрушении фрейма
var
  st : string;
  i: Integer;
  va: TVarDynArray;
  va2: TVarDynArray2;
begin
  if Length(Opt.FPanelsSaved) = 0 then
    Exit;
  va2 := [];
  va := [];
  for i := 0 to High(Opt.FPanelsSaved) do begin
    if FindComponent(Opt.FPanelsSaved[i]) <> nil then
      if not A.InArray(Opt.FPanelsSaved[i], va) then begin
        va2 := va2 + Cth.GetControlValuesArr2(TForm(Self), FindComponent(Opt.FPanelsSaved[i]), [], []);
        va := va + [Opt.FPanelsSaved[i]];
      end;
  end;
  if Length(va2) <> 0 then
    Settings.WriteProperty(TFrmBasicMdi(Owner).FormDoc, Name + '.Controls', Cth.SerializeControlValuesArr2(va2));
end;

procedure TFrDBGridEh.CreateAddControls(ParentName: string; CType: TMyControlType; CLabel: string = ''; CName: string= ''; CVerify: string = ''; x: Integer = 1; y: Integer = yrefC; Width: Integer = 0; Tag: Integer = 0);
//динамическое создание контролов в переданной панели (чекбоксы, комбобоксы...), с переданными именами, размерами, положением (x, y (yrefT))
//передается имя панели, если таковой не найдено, то она создается и подгоняется по размеру,
//исходя из положения и размеров контролов, а по высоте всегда 32.
//чтобы панели с контролами вставлялись в панели кнопок, имя должно быть типа 'pnlTopBtnsCtl2'.
//если имя - просто число, то генерируется имя для вставки в верхнюю панель.
var
  C:TControl;
  P: TPanel;
  r, i: Integer;
begin
{ cntEdit = 1;  cntNEdit = 2;  cntNEditC; cntNEditS; cntDEdit = 3;  cntTEdit = 4;  cntDTEdit = 5;  cntCheck = 6;  cntCheck3 = 7 //checkbox с опцией greed
  cntComboL = 8 //комбобокс - список;  cntComboLK = 9 //комбобокс - список с ключами;  cntComboE = 10 //комбобокс - эдит;
  cntComboEK = 11 //комбобокс - эдит с ключами;  cntComboL0 = 12 //с добавленной пустой строкой в лист;  cntComboLK0 = 13;}
  if S.IsNumber(ParentName, 1, 100, 0)
    then ParentName := 'pnlTopBtnsCtl' + ParentName;
  P:=TPanel(FindComponent(ParentName));
  if P = nil then begin
    P:=TPanel.Create(Self);
    P.Name := ParentName;
    P.Height := 32;
    P.Tag := -1;
    P.Width := 0;
    //добюавим наименование панели в массив, для колторых сохраняются значения контролов в БД
    if A.InArray('*', Opt.FPanelsSaved) then
      Opt.FPanelsSaved := Opt.FPanelsSaved + [ParentName];
  end;
  //если x передан -1, то назначим его по самому правому существующему контролу
  if x = -1 then begin
    x := 4;
    for i := 0 to P.ControlCount - 1 do
      x := Max(x, P.Controls[i].Left + P.Controls[i].Width + 4);
  end;
  if CType = cntLabelClr then begin
    FLabelsColored := FLabelsColored + [[CName, CLabel]];
    CLabel := '';
  end;
  c:=Cth.CreateControls(Self, CType, CLabel, CName, CVerify, Tag);
  c.Parent:=P;
  c.left:=x;
  if y = yrefC then begin
    y:=P.Height div 2 - c.Height div 2;
  end;
  if y = yrefT then begin
    y:=(P.Height - c.Height * 2) div 3;
  end;
  if y = yrefB then begin
    y:=((P.Height - c.Height * 2) div 3) * 2 + c.Height;
  end;
  c.Top:=y;
  if c.Width > 0 then c.Width:= Width;
  if P.Tag = -1 then begin
    P.Width := Max(P.Width, c.Left + c.Width + 4);
  end;
  c.Tag := Tag;
  if not ((CType = cntLabel) or (CType = cntLabelClr)) then begin
    Cth.SetControlValue(c, null);
    if (CType = cntCheck) or (CType = cntCheck3)
      then TDBCheckboxEh(c).OnClick := AddControlChange
      else TDBEditEh(c).OnChange := AddControlChange;
  end;
end;

procedure TFrDBGridEh.SetColumnsPropertyes;
//настройка свойст столбцов грида (размеры, кнопки, форматы, картинки...) по данным массива Opt.Fields фрейма
//вызывается автоматически при открытии датасета, но может быть вызван вручную в случае если была
//настройка параметров полецй Opt.SetColFeature
//функция удалит и пересоздаст элементы, которые нельзя перенастроить
var
  i, j, k, p, w: Integer;
  b, b1, b2: Boolean;
  col: TColumnEh;
  va, va1, va11: TVarDynArray;
  st: string;
  ebt: TEditButtonStyleEh;
  ebtp: TEditButtonHorzPlacementEh;
const
  ebsn: array of string = ['dd', '', 'g', 'ud' ,'+', '-', 'add', 'aud'];
  ebs: array of TEditButtonStyleEh = [ebsDropDownEh, ebsEllipsisEh, ebsGlyphEh, ebsUpDownEh,  ebsPlusEh, ebsMinusEh, ebsAltDropDownEh, ebsAltUpDownEh];
begin
  if not FIsPrepared then
    DBGridEh1.AutoFitColWidths := False;
  DBGridEh1.FooterRowCount := 0;
  DBGridEh1.SumList.Active := False;
  for i:= 0 to DBGridEh1.Columns.Count - 1 do begin
    col := DBGridEh1.Columns[i];
    if not FIsPrepared then begin
      //настройки по умолчанию, прописанные в коде. только после первого открытия грида
      col.AutoFitColWidth := False;
      col.WordWrap := False;
      if myogNoTextEditing in FOptions then
        col.TextEditing := False;
      va := A.Explode(Opt.Sql.Fields[i].DefOptions, ';');
      for j := 0 to High(va) do begin
        if UpperCase(va[j]) = 'H' then begin
          col.WordWrap := true;
          b1 := true;
        end;
        if UpperCase(va[j]) = 'W' then begin
          col.AutoFitColWidth := true;
          b2 := true;
        end;
        if UpperCase(va[j]) = 'L' then
          col.Alignment:= taLeftJustify;
        if UpperCase(va[j]) = 'R' then
          col.Alignment:= taRightJustify;
        if UpperCase(va[j]) = 'C' then
          col.Alignment:= taCenter;
        if UpperCase(va[j]) = 'E' then
         col.TextEditing := not col.TextEditing;
       w := StrToIntDef(va[j], -1);
        if w > -1 then begin
          col.Width := w;
        end;
      end;
    end;
    if col.Width < 15 then
       col.Width:=Min(col.Width, 40);
    //очистим свойства колонок, которые при установке могут быть добавлены
    //(проверить, все ли очищается!!
    //-картинки при установке SetGridInCellImagesAdd сама очищает
    //кнопки
    col.CellButtons.Clear;
    //чекбоксы
    if col.Checkboxes then begin
      col.Checkboxes := true;
      col.KeyList.Add('1');
      col.KeyList.Add('0;');
    end;
    //форматы и футер
    Col.DisplayFormat := '';
    col.Footer.ValueType := fvtNon;
    col.Footer.DisplayFormat := '';

    //зададим заголовок столбца
    if Pos('~', Opt.Sql.Fields[i].Caption) = 1 then begin
      col.Title.Orientation := tohVertical;
      col.Title.Caption := Copy(Opt.Sql.Fields[i].Caption, 2);
    end
    else begin
      col.Title.Orientation := tohHorizontal;
      col.Title.Caption := Opt.Sql.Fields[i].Caption;
    end;

    //чекбокс в колонке
    if Opt.Sql.Fields[i].FChb then begin
      st := Opt.Sql.Fields[i].FChbPic;
      if (st <> '')and(not IsColumnEditable(col.FieldName)) then begin
        //зеленая галка для 1, для 0 прозрачная
        if st = '+' then st := '0;1';
        Gh.SetGridInCellImagesAdd(DbGridEh1, [[col.FieldName, '1;0', st, true, 0]])
      end
      else begin
        Gh.SetGridInCellCheckBoxes(DBGridEh1, col.FieldName, '1;', -1);
      end;
    end;
    if Opt.Sql.Fields[i].FChbt then begin
      st := Opt.Sql.Fields[i].FChbtPic;
      if (st <> '')and(not IsColumnEditable(col.FieldName)) then begin
        //зеленая галка для непустых, для пустых прозрачная
        if st = '+' then st := '0;1';
        Gh.SetGridInCellImagesAdd(DbGridEh1, [[col.FieldName + '+', '', st, true, 0]])
      end
      else begin
        Gh.SetGridInCellButtonsChb(DBGridEh1, col.FieldName, '' {здесь хинт к чекбоксу, не делаем}, CellButtonClick, nil);
      end;
    end;
    if Opt.Sql.Fields[i].FBt <> '' then begin
      //кнопки
      //если несколько, то описания разделяются точкой с запятой
      va := A.Explode(Opt.Sql.Fields[i].FBt, ';');
      for j := 0 to High(va) do begin
        //параметры кнопки через :
        //заголовок
        //тип кнопки, если пустой то эллипсе, если число то картинка, иначе по сокращениям ['dd', '', 'g', 'ud' ,'+', '-', 'add', 'aud'], иначе это текст на кнопке
        //если l то выравнивание по левому краю
        //если h, то кнопка скрывается когда на нее не наведена мышка
        //цвет RGB из трех цифр от 0 до 9 - интенсивность канала, если не задан - черный
        //ширина кнопки, если не задана - 16
        va1 := A.Explode(va[j], ':') + ['', '', '', '', '','',''];
        k := A.PosInArray(va1[1], ['dd', '', 'g', 'ud' ,'+', '-', 'add', 'aud']);
        ebt := ebsEllipsisEh;
        st := '';
        if (k = -1) and S.IsInt(va1[1]) then begin
          ebt := ebsGlyphEh;
          k := va1[1];
        end
        else if k >= 0 then begin
          ebt := ebs[k];
          k := -1;
        end
        else
          st := va1[1];
        if va1[2] <> 'l'
          then ebtp := ebhpRightEh
          else ebtp := ebhpLeftEh;
        Gh.SetGridInCellButtons(DBGridEh1, col.FieldName, va1[0], CellButtonClick, ebtp, ebt, k , st, va1[3] = 'h', va1[4], S.NInt(va1[5]));
      end;
    end;
    if Opt.Sql.Fields[i].FPic <> '' then begin
      //картинка, в строке через ":"
      //1 - значения полей, через точку с запятой
      //2 - соответствующие им индексы картинок
      //3 - если +, то выводитяяся и текст
      //если ничего не задано, то будет галка для значения "1", если задан только один параметр, то будет галка для него
      va := A.Explode(Opt.Sql.Fields[i].FPic, ':') + ['', '', ''];
      if va[0] = '' then va[0] := '1';
      if va[1] = '' then va[1] := '1';
      Gh.SetGridInCellImagesAdd(DbGridEh1, [[col.FieldName + S.IIfStr(va[2] = '+', '+'), va[0], va[1], true, 0 {это Il_All16}]])
    end;
    if Opt.Sql.Fields[i].FFormat <> '' then begin
      //формат ячейки и футера
      //по умолчанию - денежный формат ячейки без футера (суммы кололонки)
      //если есть ":", то оно отделяет формат футера, если оно последнее в строке, то формат футера такой же как в ячейке
      //r - формат в рублях и копейках
      va := A.Explode(Opt.Sql.Fields[i].FFormat, ':') + ['', '', ''];
      if va[0] = 't' then
        va[0] := '';
      if va[0] = 'r' then
        va[0] := '###,###,##0.00';
      if va[0] = 'f' then
        va[0] := '###,###,###0.###';
      if va[1] = '' then
        va[1] := va[0];
      if va[1] = 't' then
        va[1] := 't';
      if va[1] = 'r' then
        va[1] := '###,###,##0.00';
      if va[1] = 'f' then
        va[1] := '###,###,###0.###';
      if va[1] = '' then
        va[1] := va[0];
      Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, col.FieldName, VarToStr(va[0]));
      if Pos(':', Opt.Sql.Fields[i].FFormat) > 0 then
        if va[1] <> 't' then
          Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, col.FieldName, VarToStr(va[1]))
        else
          col.Footer.ValueType := fvtStaticText;
    end;
    //сформируем выпадающие списки в столбцах
    for j := 0 to High(FOpt.PickLists) do
      if UpperCase(FOpt.PickLists[j].FieldName) = UpperCase(col.FieldName) then begin
        col.PickList.Clear;
        col.KeyList.Clear;
        for k := 0 to High(FOpt.PickLists[j].KeyList) do
          col.KeyList.Add(S.NSt(FOpt.PickLists[j].KeyList[k]));
        for k := 0 to High(FOpt.PickLists[j].PickList) do
          col.PickList.Add(S.NSt(FOpt.PickLists[j].PickList[k]));
        col.LimitTextToListValues := FOpt.PickLists[j].LimitTextToListValues;
        col.AlwaysShowEditButton := FOpt.PickLists[j].AlwaysShowEditButton;
      end;
  end;
  //повесим событие отрисоки кнопок в ячеках (нужно для чекбоксов с текстом)
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    for j := 0 to DBGridEh1.Columns[i].CellButtons.Count - 1 do
      DBGridEh1.Columns[i].CellButtons[j].OnDraw := CellButtonDraw;
  if b1 then
    Options := Options + [myogAutoFitRowHeight];
  if b2 then
    Options := Options + [myogAutoFitColWidths];

  //настраивает группировку
  DataGrouping;
end;

procedure TFrDBGridEh.RefreshGrid;
//обновление основной таблицы, вызываемое по кнопке, либо же ее первая загрузка
var
  charr: TVarDynArray2;
  KeyString: string;
begin
  try
    //прочитаем из бд и установим значения дополнительных контролов (если ранее не было уже вызова данной функции)
    ReadControlValues;
    SetDataDriverCommands;
    //обновление грида в оффлайн-режиме
    if (Opt.DataMode <> myogdmWithAdoDriver) and InitData.IsDefined then begin
      if myogIndicatorCheckBoxes in Options then begin
        charr := Gh.GetGridArrayOfChecked(DBGridEh1, DBGridEh1.FindFieldColumn(Opt.Sql.IdField).Index);
        DBGridEh1.SelectedRows.Clear;
      end;
      //затенение с сообщением вызывает глюк - град темный, не отображаются данные
      //if myogGrayedWhenRefresh in Options then BeginOperation('Загрузка данных..');
      KeyString := Gh.GetGridServiceFields(DBGridEh1);
      if (KeyString <> '') and (MemTableEh1.Active) then
        DBGridEh1.SaveVertPos(KeyString);
      if FInitData.Sql <> '' then
        LoadData(InitData.Sql, InitData.Params)
      else if InitData.ArrN.FieldsCount > 0 then
        LoadData(InitData.ArrN)
      else
        LoadData(InitData.Arr, InitData.ArrFields, InitData.ArrColumns);
      DBGridEh1.DefaultApplySorting;
      DBGridEh1.DefaultApplyFilter;
      if (KeyString <> '') and (MemTableEh1.Active) then
        DBGridEh1.RestoreVertPos(KeyString);
      //if myogIndicatorCheckBoxes in Options then EndOperation;
      if myogIndicatorCheckBoxes in Options then
        SetIndicatorCheckBoxesByField(Opt.Sql.IdField, A.VarDynArray2ColToVD1(charr, 0));
    end
    //обновление грида в онлайн-режиме
    else begin
      if MemTableEh1.Active then begin
        if myogIndicatorCheckBoxes in Options then begin
          charr := Gh.GetGridArrayOfChecked(DBGridEh1, DBGridEh1.FindFieldColumn(Opt.Sql.IdField).Index);
          DBGridEh1.SelectedRows.Clear;
        end;
        Gh.GridRefresh(DBGridEh1, myogGrayedWhenRefresh in Options);
        if myogIndicatorCheckBoxes in Options then
          SetIndicatorCheckBoxesByField(Opt.Sql.IdField, A.VarDynArray2ColToVD1(charr, 0));
      end
      else begin
        MemTableEh1.Open;
        MemTableEh1.First;
      end;
      ChangeSelectedData;
    end;
  except on E: Exception do begin
    Errors.SetErrorCapt(Self.Name, 'Ошибка при обновлении грида ' + TFrmBasicMdi(Owner).FormDoc + '.' + Name);
    Application.ShowException(E);
    Errors.SetErrorCapt;
    end;
  end;
end;

function TFrDBGridEh.RefreshRecord: Boolean;
//обновляем текущую строку грида, при ошибке выдаем сообщение об отсутсвии записи
//вернем False в случае отстутствия записи в БД, или если она ушла из отфильтрованного грида после обновления
var
  OldID: Variant;
begin
  Result := False;
  try
    //получим айди текущей записи. далее делаем проверку после обновления записи, не исчезла ли из грида она из-за действия фильтра
    OldID := GetValue(Opt.Sql.IdField);
    MemTableEh1.RefreshRecord;
    ChangeSelectedData;
    if OldID = GetValue(Opt.Sql.IdField) then
      Result := True;
  except
    MyWarningMessage('Эта запись была удалена.')
  end;
end;

procedure TFrDBGridEh.SetButtonsState;
//изменим Enabled всех кнопок и пунктов меню в зависимости от того, есть ли данные в таблице, и есть ли кнопка в Opt.FButtonsIfEmpty
var
  i: Integer;
begin
  for i := 0 to High(FBtnIds) do
    if not (A.InArray(FBtnIds[i], Opt.FButtonsNoAutoState) or A.InArray(0, Opt.FButtonsNoAutoState)) then
      SetBtnNameEnabled(FBtnIds[i], null, IsNotEmpty or A.InArray(FBtnIds[i], Opt.FButtonsIfEmpty));
end;

procedure TFrDBGridEh.SetBtnNameEnabled(ATag: Integer; AName: Variant; AEnabled: Variant);
//меняет заголовок пункта ПКМ или кнопки (для SpeedButton меняет Hint), и свойство Enabled,
//находя элемент в переданных компонентах по тегу
//чтобы не менять статус или текст заголовка, в данных полях ставить null!
begin
  //!!!можно использовать другую функцию? пока непонятно, вопросы с кнопками, не принадлежащими фрейму, созданными в переданных панелях
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FPanelsBtn, ATag, AName, AEnabled, '');
end;

procedure TFrDBGridEh.SetColumnsVisible;
//отобразить стобцы грида, которые должны быть видны
//видны у который установлена флаг Visible (он сохраняется в настройках), не установлен Invisible (это позволяет скрыть набор полей не изменяя настроек),
//никогда не видн которые не загружаются (NULL) и служебные видны только если служебный флаг FDevVisibleHidden
var
  i : Integer;
begin
  for i := 0 to High(Opt.Sql.Fields) do
    if DbGridEh1.FindFieldColumn(Opt.Sql.Fields[i].Name) <> nil then
      DbGridEh1.FindFieldColumn(Opt.Sql.Fields[i].Name).Visible :=
        Opt.Sql.Fields[i].Visible and not Opt.Sql.Fields[i].Invisible and not Opt.Sql.Fields[i].FIsNull and ((Pos('_', Opt.Sql.Fields[i].Caption) <> 1) or FDevVisibleHidden);
  FrozeColumn;
end;

procedure TFrDBGridEh.FrozeColumn;
//заморозить столбцы до столбца с указанным полем в Opt.FrozenColumn ,включительно; если пустое - снять заморозку
var
  i, j : Integer;
begin
  //количество замороженнх столбцов указывается для видимых столбцов!
  DBGridEh1.FrozenCols := 0;
  if Opt.FrozenColumn = '' then
    Exit;
  if DBGridEh1.FindFieldColumn(Opt.FrozenColumn) = nil then
    Exit;
  for i := 0 to DBGridEh1.FindFieldColumn(Opt.FrozenColumn).Index do begin
    if DBGridEh1.Columns[i].Visible then
      DBGridEh1.FrozenCols := DBGridEh1.FrozenCols + 1;
  end;
end;

procedure TFrDBGridEh.BeginOperation(AMessage: string = '');
//для долгих операций - затенить грид и вывести поясняющий текст
begin
  //в этом состоянии вызывает ошибку в коде библиотеки
  if MemTableEh1.ControlsDisabled then Exit;
  if AMessage = '' then
    AMessage := 'Обработка данных...';
  DBGridEh1.StartLoadingStatus(AMessage, 0);
end;

procedure TFrDBGridEh.EndOperation(AMessage: string = '');
//для долгих операций - снять затемнение грида
begin
  try
  if MemTableEh1.ControlsDisabled then Exit;
  DBGridEh1.FinishLoadingStatus(0);
  DBGridEh1.StartLoadingStatus('Завершено!', 0);
  DBGridEh1.FinishLoadingStatus(0);
  except
  end;
end;

procedure TFrDBGridEh.ClearOrRestoreFilter;
begin
    //по Ctrl-Q - установка/сброс фильтра в столбцах
    //если есть фильтр в столбцах и нет запомненного фильтра, то запомним текущий и снимим фильтр в столбцах
    //если есть запомненный, то восстановим его, независимо от того есть ли фильтр в столбцах сейчас
    //все без вопросов/подтверждений
    if (Length(FLastFilter) = 0) and not Gh.GridFilterInColumnUsed(DbGridEh1) then
      Exit;
    if Length(FLastFilter) = 0 then begin
      FLastFilter := Gh.GridFilterSave(DbGridEh1);
      Gh.GridFilterClear(DbGridEh1, true, False);
    end
    else begin
      if Length(FLastFilter) = 0 then
        Exit;
      Gh.GridFilterRestore(DbGridEh1, FLastFilter, true, False);
      FLastFilter := [];
    end;
end;

procedure TFrDBGridEh.SetGridLabel(Mode: Integer = 0);
//установим цветовые метки на строку таблицы
//если Mode = -1, то установим метки в цикле, если >=0 то установим именно этот номер метки, если -2 то сбросим все метки по этой таблице
var
  i, labelnum: Integer;
  b: Boolean;
  updsql: string;
begin
  if IsEmpty or not (myogGridLabels in Options) then
    Exit;
  if Mode >= -1 then begin
    for i := 0 to High(FGridLabelsIds) do
      if FGridLabelsIds[i][0] = id
        then Break;
    if i > High(FGridLabelsIds) then begin
      labelnum := 0;
      FGridLabelsIds := FGridLabelsIds + [[id, labelnum]];
    end;
    if Mode = -1
      then Inc(FGridLabelsIds[i][1])
      else FGridLabelsIds[i][1] := Mode;
    labelnum := FGridLabelsIds[i][1];
    if not(Integer(FGridLabelsIds[i][1]) in [1..3]) then begin
      Delete(FGridLabelsIds, i, 1);
      labelnum := 0;
    end;
  end
  else begin
    if MyQuestionMessage('Очистить все метки в таблице?') <> mrYes then
      Exit;
    FGridLabelsIds := [];
  end;
  Q.QCallStoredProc('p_SetGridLabel', 'pdoc$s;piduser$i;ptablerow$i;ptablenum$i;plabelnum$i',
    [TFrmBasicMdi(Owner).FormDoc, User.GetId, S.IIf(Mode < -1, -1, ID), 1, labelnum
  ]);
{    if pos('0 as collabel', Pr[1].Fields) > 0 then begin
      b := MemTableEh1.ReadOnly;
      MemTableEh1.ReadOnly := False;
      MemTableEh1.Edit;
      MemTableEh1.FieldByName('collabel').Value := labelnum;
      ADODataDriverEh1.UpdateSQL.Text := 'select 1 from dual';
      MemTableEh1.Post;
      ADODataDriverEh1.UpdateSQL.Text := updsql;
      MemTableEh1.ReadOnly := b;
    end;}
  DbGridEh1.Repaint;
end;

procedure TFrDBGridEh.GoToGridLabel(Mode: Integer = +1);
//переход к помеченной записи (+1 - вниз, -1 = вверх)
var
  i, j, k, RecNo: Integer;
begin
  if IsEmpty or not (myogGridLabels in Options) then
    Exit;
  RecNo := MemTableEh1.RecNo;
  i := RecNo - 1;
  k := 0;
  //проход по отфильтрованным записям (если по всем, то так: MemTableEh1.RecordsView.MemTableData.RecordsList[i])
  repeat
    i := i + Mode;
    inc(k);
    if i >= MemTableEh1.RecordsView.Count then
      i := 0;
    if i < 0 then
      i := MemTableEh1.RecordsView.Count - 1;
    if A.PosInArray(MemTableEh1.RecordsView[i].DataValues[FOpt.SQL.IdField, dvvValueEh], FGridLabelsIds, 0) >= 0 then begin
      MemTableEh1.RecNo := i + 1;
      Break;
    end;
    if k > MemTableEh1.RecordsView.Count then
      Break;
  until False;
end;

procedure TFrDBGridEh.SetState(AIsDataChanged, AHasError, AErrorMessage: Variant);
//установить статусы грида (изменения, ошибка, строка ошибки). обновить статус формы при изменении.
//если значение передано как null, то оно не меняется
var
  b: Boolean;
  c: TControl;
begin
  try
  if (AIsDataChanged <> null)and(AIsDataChanged <> FIsDataChanged) then begin
    FIsDataChanged := AIsDataChanged;
    b := True;
  end;
  if (AHasError <> null)and(AHasError <> FHasError) then begin
    FHasError := AHasError;
    b := True;
  end;
  if (AErrorMessage <> null)and(AErrorMessage <> FErrorMessage) then begin
    FErrorMessage := AErrorMessage;
    b := True;
  end;
  if FErrorMessage <> '' then begin
//    MyData.IlAll24.GetBitmap(2, ImGState.Picture.Bitmap);
    ImGState.Hint := S.IIf(FErrorMessage = '', 'Ошибка в данных!', FErrorMessage);
    Cth.LoadBitmap(MyData.IlAll24, 2, ImGState.Picture.Bitmap);
    //ImGState.Repaint;
  end
  else if FHasError then begin
//    MyData.IlAll24.GetBitmap(2, ImGState.Picture.Bitmap);
    ImGState.Hint := S.IIf(FErrorMessage = '', 'Ошибка в данных!', FErrorMessage);
    Cth.LoadBitmap(MyData.IlAll24, 2, ImGState.Picture.Bitmap);
    //ImGState.Repaint;
  end
  else if FIsDataChanged then begin
{    ImGState.Transparent := True;
    ImGState.Picture.Bitmap.Transparent:=True;
    MyData.IlAll24.GetBitmap(1, ImGState.Picture.Bitmap);
    ImGState.Picture.Bitmap.Transparent:=True;}
    Cth.LoadBitmap(MyData.IlAll24, 1, ImGState.Picture.Bitmap);
    ImGState.Hint := 'Данные были изменены.';
    //ImGState.Repaint;
  end
  else begin
{    ImGState.Transparent := True;
    ImGState.Picture.Bitmap.Transparent:=True;
    ImGState.Picture.Bitmap.Canvas.Brush.Color := clNone;
    MyData.IlAll24.GetBitmap(0, ImGState.Picture.Bitmap);
    ImGState.Picture.Bitmap.Canvas.Brush.Color := clNone;
    ImGState.Picture.Bitmap.Transparent:=True;
    ImGState.Transparent := True;
    ImGState.Repaint;}
    Cth.LoadBitmap(MyData.IlAll24, 0, ImGState.Picture.Bitmap);
    ImGState.Hint := '';
  end;
  if (Owner is TFrmBasicMdi) and b then
    TFrmBasicMdi(Owner).Verify(Self);
  except
  end;
end;

procedure TFrDBGridEh.SetStatusBarCaption(Caption: string = ''; AProcessMessages: Boolean = False);
//установить произвольный тект в статусбаре; если пустой, то будет установлен дефолтный
begin
  FStatusBarText := Caption;
  PrintStatusBar;
  if AProcessMessages then
    Application.ProcessMessages;
end;

function TFrDBGridEh.GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
//получить значение контрола на фрейме по его имени
//если установлено NullIfEmpty то вернуть null если значение равно пустое или ''
begin
  Result:= Cth.GetControlValue(Self, ControlName);
  if NullIfEmpty then Result:=S.NullIfEmpty(Result);
end;

procedure TFrDBGridEh.SetControlValue(ControlName: string; Value: Variant);
begin
  Cth.SetControlValue(TControl(Self.FindComponent(ControlName)), Value);
end;





{
ФУНКЦИИ, ВЫЗЫВАЕМЫЕ СОБЫТИЯМИ ВО ВРЕМЯ РАБОТЫ ИЛИ НАСТРОЙКИ ФРЕЙМА
}


function TFrDBGridEh.SetButtonsAndMenu: Integer;
//создадим панель кнопок и меню
var
  i: Integer;
  Panel: TPanel;
  Vert, b: Boolean;
  MenuItems: TVarDynArray2;
  st: string;
begin
 //создадим панель кнопок
  FPanelsBtn:= [];
  MenuItems:= [];
  FBtnIds:= [];
  for i:= Low(Opt.Buttons) to High(Opt.Buttons) do
    if Length(Opt.Buttons[i].A) > 0 then begin
      if (i = 1) and (Opt.Buttons[i].P = nil) then Opt.Buttons[i].P:= pnlTop;
      if Opt.Buttons[i].P = pnlLeft then Opt.Buttons[i].V:= true;
      if Opt.Buttons[i].P <> nil then begin
        if (Opt.Buttons[i].P = pnlTop) or (Opt.Buttons[i].P = pnlLeft) or (Opt.Buttons[i].P = pnlBottom)
          then begin
            Panel:=TPanel.Create(Self);
            Panel.Parent:= Opt.Buttons[i].P;
            Panel.Name:= Opt.Buttons[i].P.Name + 'Btns';
          end
          else Panel:= Opt.Buttons[i].P;
          FPanelsBtn:= FPanelsBtn + [Panel];
        if Opt.Buttons[i].T = 0 then Opt.Buttons[i].T := cbttSBig;
        Cth.CreateButtons(Panel, Opt.Buttons[i].A, ButtonOrPopupMenuClick, Opt.Buttons[i].T, S.IIfStr(i > 1, IntToStr(i)), 2, Opt.Buttons[i].H, Opt.Buttons[i].V);
        if uString.A.PosInArray(mbtToAlRight, Opt.Buttons[i].A, 0) >= 0 then begin
          Panel.Align:=alClient;
        end;
        MenuItems:= MenuItems + Opt.Buttons[i].A;
      end;
    end;
  for i := 0 to High(MenuItems) do
    if (MenuItems[i][0] = mbtPrintGrid) or (MenuItems[i][0] = mbtExcel) or (MenuItems[i][0] = mbtGridSettings) then begin
      MenuItems[i][0] := mbtDividor;
    end;
    if myogGridLabels in Options then
      MenuItems := MenuItems + [[mbtDividor], [mbtSetGridLabel], [mbtToGridLabelDown], {[mbtShowGridLabels],} [mbtClearGridLabels]];
    if myogColumnFilter in Options then
      MenuItems := MenuItems + [[mbtDividor], [mbtClearOrRestoreGridFilter]];
    if (myogIndicatorCheckBoxes in Options) and (myogMultiSelect in Options) then
      MenuItems := MenuItems + [[mbtDividor], [mbtSelectAll], [mbtDeSelectAll], [mbtInvertSelection]];
    if myogSaveOptions in Options then
      MenuItems := MenuItems + [[mbtDividor], [mbtGridSettings]];
    if myogPrintGrid in Options then
      MenuItems := MenuItems + [[mbtDividor], [mbtPrintGrid], [mbtExcel]];
  if Length(MenuItems) > 0 then begin
    for i := 0 to High(MenuItems) do
      if High(MenuItems[i]) >= 0 then begin
        if MenuItems[i][0] < 0
          then MenuItems[i][0] := -MenuItems[i][0];
        if S.VarType(MenuItems[i][0]) = varInteger then
          if not A.InArray(MenuItems[i][0], FBtnIds) then
            FBtnIds := FBtnIds + [MenuItems[i][0]];
      end;
    Cth.CreatePopupMenu(PmGrid, MenuItems, ButtonOrPopupMenuClick, '');
    FPanelsBtn:= FPanelsBtn + [DBGridEh1.PopupMenu];
  end;
end;

procedure TFrDBGridEh.SetPanels;
//отображение/скрытие/изменение размеров панелей
//(верхняя, нижняя, боковая), в зависимости от того есть ли в них элементы
//(например, кнопки или вставленные панели с контролами
var
  i: Integer;

  procedure SetPanelState(APanel: TPanel);
  begin
    if APanel.ControlCount > 0 then begin
      APanel.Width:= APanel.Controls[0].Width;
      APanel.Height:= APanel.Controls[0].Height;
      APanel.Visible:=true;
    end
    else begin
      APanel.Width:= 0;
      APanel.Height:= 0;
      //если это оставить, то все ломается, когда должна быть видна левая панель
      //APanel.Visible:=False;
    end;
  end;

begin
  //уберем всем панелям заголовки и границы
  For i:=0 to Self.ComponentCount - 1 do
    if Self.Components[i] is TPanel then begin
      TPanel(Self.Components[i]).Caption:='';
      TPanel(Self.Components[i]).BevelInner:= bvNone;
      TPanel(Self.Components[i]).BevelOuter:= bvNone;
    end;
  SetPanelState(pnlContainer);
  SetPanelState(pnlTop);
  SetPanelState(pnlBottom);
  SetPanelState(pnlLeft);
  FrameResize(nil);
end;

procedure TFrDBGridEh.SetDataDriverCommandSelect;
//сформируем команду Селект для датадрайвера
//вынесено потому, что она может меняться от условий в процессе работы (например из-за применения фильтра по кнопке тулбара)
var
  st, sts, stw, stwa: string;
  i, j: Integer;
  FieldsOld: string;

  function GetFieldsStr: string;
  //функция получает строку полей из массива, и подменяет на пустые значения поля, которые не нужно загружать
  var
    i, j: Integer;
    st, st1: string;
  begin
    Result := '';
    for i := 0 to High(Opt.Sql.Fields) do begin
      st := A.Explode(Opt.Sql.Fields[i].NameDb, '$')[0];
      if st <> Opt.Sql.Fields[i].Name then
        st := st + ' as ' + Opt.Sql.Fields[i].Name;
      st1 := '';
      if Opt.Sql.Fields[i].FIsNull then begin
        if Opt.Sql.Fields[i].DataType = ftString then
          st1 := '''  '''
        else if Opt.Sql.Fields[i].DataType = ftFloat then
          st1 := '0.0'
        else if Opt.Sql.Fields[i].DataType = ftInteger then
          st1 := '0'
        else
          st1 := 'null';
        st1 := st1 + ' as ';
      end;
      S.ConcatStP(Result, st1 + st, ';');
    end;
  end;
begin
  {
  //сохраним поля как они были исходные, а потом восстановим.
  //поля модифицируются в случае замены на нулл.
  //это приводит к ошибке, которую не удалось отследить, как минимум при обновлении формы из другой формы (при обновлении паспорта заказа)
  FieldsOld := FOpt.Sql.FieldNames;}
  //генерация sqlwhere из правил дефолтного фильтра
  stw := TFrmXDedtGridFilter.GetDefRule(Self);
  //получим переменное условие для запросы (например, из фильтра)
  //также в этой процедуре могут устанавливаться например поля для замены на нулл
  //также в этом событии устанавливаются и параметры, так как они могут быть еще не сгенерированы здесь, при установке используем флаг пропуска несуществующих параметров
  if Assigned(FOnSetSqlParams)
    then FOnSetSqlParams(Self, FNo, stw);
  stw := Trim(stw);
  st := GetFieldsStr; //FOpt.Sql.FieldNames;
  //заменим поле id на запрос строки а не числа; если параметр не строковый, то будут ошибки в командах, использующих айди неявно (GetRec, Update...)
  if pos('id;', st) = 1 then begin
    st := 'to_char(id) as id' + Copy(st, 3);
  end;
  st := Q.QSIUDSql('a', FOpt.SQL.View, st);
  sts := FOpt.SQL.Select;
  if (myogLoadAfterVisible in Options) and (tmrAfterCreate.Enabled)
    then stwa := 'where 1 = 2'
    else stwa := Trim(FOpt.SQL.WhereAllways);
  if FOpt.SQL.Select = '=' then
    sts := ADODataDriverEh1.SelectSQL.Text
  else if FOpt.SQL.Select = '' then
    sts := st;
  if stw <> '' then begin
    if Pos('/*WHERE*/', sts + stwa) > 0 then
      ADODataDriverEh1.SelectSQL.Text := StringReplace(sts + S.IIf(stwa <> '', ' ' + stwa, ''), '/*WHERE*/', ' where (' + stw + ') ', [])
    else if Pos('/*ANDWHERE*/', sts + stwa) > 0 then
      ADODataDriverEh1.SelectSQL.Text := StringReplace(sts + S.IIf(stwa <> '', ' ' + stwa, ''), '/*ANDWHERE*/', ' and (' + stw + ') ', [])
    else if Pos('/*WHEREONLY*/', sts + stwa) > 0 then
      ADODataDriverEh1.SelectSQL.Text := StringReplace(sts + S.IIf(stwa <> '', ' ' + stwa, ''), '/*WHEREONLY*/', stw, [])
    else begin
      i := pos('where ', stwa);
      if i > 0 then
        Insert(stw + ' and ', stwa, 7)
      else
        stwa := 'where ' + stw + S.IIf(stwa <> '', ' ', '') + stwa;
      ADODataDriverEh1.SelectSQL.Text := sts + S.IIf(stwa <> '', ' ', '') + stwa;
    end;
  end
  else
    ADODataDriverEh1.SelectSQL.Text := sts + S.IIf(stwa <> '', ' ', '') + stwa;
  if FOpt.SQL.GetRec = '' then
    ADODataDriverEh1.GetRecCommand.CommandText.Text := sts + ' where ' + FOpt.SQL.IdField + ' = :' + FOpt.SQL.IdField;
  //снова вызываем событие для установки параметров скл (только для sqlselect и sqlgetrec), изменение им части запроса where здесь уже не обрабатываем
  if Assigned(FOnSetSqlParams)
    then FOnSetSqlParams(Self, FNo, stw);
end;

procedure TFrDBGridEh.SetDataDriverCommands;
//настроим команды датадрайвера
var
  i, j: Integer;
  st: string;
begin
//if FOpt.Sql.Select <> '' then begin  //!!!
//ADODataDriverEh1.SelectCommand.CommandText.Text := FOpt.Sql.Select;
//exit;
//end;
  //если первое поле строго равно "id", то заменим его на строковый тип для оракла,
  //чтобы корректно работали встроенные функции типа refreshrecord, update...
  st := FOpt.Sql.FieldNames;
  if pos('id;', st) = 1 then begin
    st := 'to_char(id) as id' + Copy(st, 3);
  end;
  SetDataDriverCommandSelect;
  if Opt.SQL.Update <> '=' then
    if Opt.SQL.Update = '*' then
      ADODataDriverEh1.UpdateCommand.CommandText.Text := Q.QSIUDSql('u', Opt.SQL.Table, st)
    else if Opt.SQL.Update = '' then
      ADODataDriverEh1.UpdateCommand.CommandText.Text := 'select 1 from dual';
  if Opt.SQL.Insert <> '=' then
    if Opt.SQL.Insert = '*' then
      ADODataDriverEh1.InsertCommand.CommandText.Text := Q.QSIUDSql('i', Opt.SQL.Table, st)
    else if Opt.SQL.Insert = '' then
      ADODataDriverEh1.InsertCommand.CommandText.Text := 'select 1 from dual';
  if Opt.SQL.Delete <> '=' then
    if Opt.SQL.Delete = '*' then
      ADODataDriverEh1.DeleteCommand.CommandText.Text := Q.QSIUDSql('d', Opt.SQL.Table, st)
    else if Opt.SQL.Delete = '' then
      ADODataDriverEh1.DeleteCommand.CommandText.Text := 'select 1 from dual';
  //читаем все данные
  MemTableEh1.FetchAllOnOpen := true;
end;

procedure TFrDBGridEh.SetSqlParameters(ParamNames: string; ParamValues: TVarDynArray; CommandType: string = 's');
//установить параметры запроса CommandType (переданные строкой через ;)
//если параметр не найден в запросе, то он игнорируется
begin
  Q.QSetParamsEh(ADODataDriverEh1, ParamNames, ParamValues, CommandType, True);
end;

procedure TFrDBGridEh.ChangeSelectedData;
//вызываем во всех случаях, когда мола измениться локация, или занчения данных в текущей строке
//выполняет дефолтные действия при этом (доступность кнопок...) и вызывает соотвествующее события фрейма
var
  i: Integer;
begin
  try
  if InLoadData then Exit;
  if not MemTableEh1.Active then Exit;
  if FDisableChangeSelectedData then Exit;
  //заблокирем кнопки и пункты меню если грид путой, кроме тегов которые в ButtonsIfEmpty
  SetButtonsState;
  //вызовем событие родителя
  if Assigned(FOnSelectedDataChange)
    then FOnSelectedDataChange(Self, No);
  //отрисуем статусбар (в событии прорисовки данных не вызовется при группировке)
  PrintStatusBar;
  except
  end;
end;

procedure TFrDBGridEh.SetRowDetailPanelSize;
//зададим размеры детального грида и всей панели
//передаются рапзмеры грида, если высота 0 то пытается подогнать под все данные, если ширина 0 то растянется на ширину основного грида
//положение грида и размер панели утсанавливается с учетом видимости левой и верхней панели
var
  i, j, k, rn, rh, fh: Integer;
function IsHorzScrollBarVisible(hWnd: HWND): Boolean;
var
  style: Integer;
begin
  style := GetWindowLong(hWnd, GWL_STYLE);
  Result := (style and WS_HSCROLL) <> 0;
end;
begin
  FGrid2.Align:=alNone;
  DBGridEh1.RowDetailPanel.Height := TForm(Owner).Height - FGrid2.DBGridEh1.Top - 50;

  rh := 0; fh := 0;
  for i := 0 to TDBGridEhMy(FGrid2.DBGridEh1).RowCount - 1 do
    rh := rh + TDBGridEhMy(FGrid2.DBGridEh1).RowHeights[i];
  for i := 0 to TDBGridEhMy(FGrid2.DBGridEh1).FooterRowCount - 1 do
    fh := fh + mydefGridRowHeight;

  i := Min(DBGridEh1.RowDetailPanel.Height + FGrid2.pnlGrid.Top - 200,
    FGrid2.pnlGrid.Top +
    rh +  //высота строк грида с заголовком
    fh +  //высота футера
//    mydefGridRowHeight * (FGrid2.DBGridEh1.RowCount + 1) + //высота строк детального рида + возможный футер
    S.IIf((myogPanelFilter in FGrid2.Options) or (myogPanelFind in FGrid2.Options), 30, 0) +  //учтем панель поиска
    //учтем возможный горизонтальный скроллер, если включен (независимо от его реальной видимости, проверить никак не удается)
    S.IIf(FGrid2.DBGridEh1.HorzScrollBar.Visible, 23 , 0)
//    S.IIf(IsHorzScrollBarVisible(FGrid2.DBGridEh1.Handle), 23 , 0)  //учтем возможный горизонтальный скроллер
//    S.IIf(FGrid2.DBGridEh1.HorzScrollBar.VisibleMode <> sbNeverShowEh, FGrid2.DBGridEh1.HorzScrollBar.Height + 1 , 0)  //учтем возможный горизонтальный скроллер
  );
  FGrid2.Height := i;
  if DBGridEh1.RowDetailPanel.Height > FGrid2.Height + 20 then
    DBGridEh1.RowDetailPanel.Height := FGrid2.Height + 20;
  FGrid2.Align:=alClient;
end;

procedure TFrDBGridEh.ReadGridLabels;
//чтение меток таблицы из БД
begin
  if not (myogGridLabels in Options) then
    Exit;
  FGridLabelsIds := Q.QLoadToVarDynArray2('select tablerow, labelnum from grid_labels where doc = :doc$s and id_user = :id_user$i and tablenum = 1', [TFrmBasicMdi(Owner).FormDoc, User.GetId]);
end;

procedure TFrDBGridEh.ShowColumnInfo;
//показать информацию-подсказку по текущему столбку, если она есть в параметрах.
//вызывается в гриде по F1
var
  i: Integer;
  st: string;
begin
  for i := 0 to High(Opt.ColumnsInfo) do
    if S.InCommaStrI(CurrField, Opt.ColumnsInfo[i][0], ';') then
      Break;
  st := DbGridEh1.FindFieldColumn(CurrField).Title.Caption;
  if i <= High(Opt.ColumnsInfo) then
    st := st + #13#10 + Opt.ColumnsInfo[i][1];
  MyInfoMessage(st);
end;

procedure TFrDBGridEh.DataGrouping;
//настраивает и включает или отключает группировку по данным настроек; вызывается в SetColumnsPropertyes
//просто включить или отключить можно свойством грида
var
  i: Integer;
begin
  DBGridEh1.DataGrouping.GroupLevels.Clear;
  if Length(Opt.DataGrouping.Fields) <> 0 then begin
    for i:= 0 to High(Opt.DataGrouping.Fields) do begin
      DBGridEh1.DataGrouping.GroupLevels.Add;
      DbGridEh1.DataGrouping.GroupLevels[DBGridEh1.DataGrouping.GroupLevels.Count-1].Column:=
        DBGridEh1.FindFieldColumn(Opt.DataGrouping.Fields[i]);
      if High(Opt.DataGrouping.Fonts) >= i then
        DBGridEh1.DataGrouping.GroupLevels[i].Font := Opt.DataGrouping.Fonts[i];
      if High(Opt.DataGrouping.Colors) >= i then
        DBGridEh1.DataGrouping.GroupLevels[i].Color := Opt.DataGrouping.Colors[i];
    end;
  end;
  DbGridEh1.DataGrouping.Active := Opt.DataGrouping.Active;
end;

































{==============================================================================}
{
В РАЗРАБОТКЕ
}

{
procedure TFrDBGridEh.AddRow(ALast: Boolean = true; AIfNotempty: Boolean = true);
var
  i: Integer;
  b: Boolean;
begin
  //если добавляем в конец - перейдем на соседнюю строку
//  if ALast then MemTableEh1.Last;
  //добавим только если текущая строка заполнена хотя бы частично (при AddIfNotempty)
  //и текущая строка корректна (данная процедура перекрывается и по умолчанию возвращает true:
  //при этом нужно еще блокировать перемещение из неверной строки, иначе блокирока по ней теряет смысл)
//  if not ((not AIfNotempty or IsRowNotEmpty) and IsRowCorrect) then Exit;
  DBGridEh1.AllowedOperations := [alopInsertEh, alopUpdateEh, alopDeleteEh, alopAppendEh];
  DbGridEh1.ReadOnly := False;
  MemTableEh1.ReadOnly := False;
  if ALast
    then MemTableEh1.Append
    else MemTableEh1.Insert;
end;
}


procedure TFrDBGridEh.Test;
var
  i, j: Integer;
begin
//  DBGridEh1.OnShowFilterDialog
end;

function TFrDBGridEh.InsertRow: Boolean;
//вставим строку в таблицу, если доступна эта операция
//если доступна операция добавления, то добавим в конец
//вызываем по кнопке и по VK_INSERT
begin
  if (MemTableEh1.State in [dsInsert]) or not ((alopInsertEh in FOpt.AllowedOperations) or (alopAppendEh in FOpt.AllowedOperations)) then
    Exit;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations + [alopInsertEh];
  if not (alopInsertEh in FOpt.AllowedOperations) then
    MemTableEh1.Append
  else
    MemTableEh1.Insert;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations - [alopInsertEh];
end;

function TFrDBGridEh.AddRow: Boolean;
//если доступна операция добавления, то добавим в строку конец таблицы
//вызываем по кнопке и по VK_DOWN на последней строке грида
begin
  if (MemTableEh1.State in [dsInsert]) or not (alopAppendEh in FOpt.AllowedOperations) then
    Exit;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations + [alopInsertEh];
  MemTableEh1.Append;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations - [alopInsertEh];
end;

function TFrDBGridEh.DeleteRow: Boolean;
//если доступна операция удаления, то удалим в строку конец таблицы
begin
  if (MemTableEh1.State in [dsInsert]) or not (alopInsertEh in FOpt.AllowedOperations) then
    Exit;
  if (ID < MY_IDS_INSERTED_MIN) and not A.InArray(ID, FEditData.IdsDeleted) then
    FEditData.IdsDeleted := FEditData.IdsDeleted + [ID];
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations + [alopDeleteEh];
  MemTableEh1.Delete;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations - [alopDeleteEh];
end;

function TFrDBGridEh.IsRowNotEmpty(RowNum: Integer = -1): Boolean;
//Вернет True, если в строке хоть одно не сервисное поле не null (при пустой таблице также True)
var
  i: Integer;
begin
  Result := True;
  if RowNum = -1 then
    RowNum := MemTableEh1.RecNo - 1;
  if GetCount(False) = 0 then
    Exit;
  for i := 0 to MemTableEh1.Fields.Count - 1 do
    if (Pos('_', DbGridEh1.FindFieldColumn(MemTableEh1.Fields[i].FieldName).Title.Caption) = 0) and (S.NSt(GetValue(MemTableEh1.Fields[i].FieldName, RowNum, False)) <> '') then
      Exit;
  Result := False;
end;

function TFrDBGridEh.IsRowCorrect(RowNum: Integer = -1): Boolean;
//Вернет труе, если строка заполнена корректно
//по умолчанию проверяет в соотвествии с ColumnsVerify (если последний не задан то вернет True)
//пустые строки игнорирует
//!!! для индикаторного столбца жестко!!!
var
  i, j: Integer;
  v: Variant;
  FRec: TFrDBGridRecFieldsList;
  IsValueCorrect: Boolean;
  Msg: string;
  st: string;
  Value, CorrectValue: Variant;
  b: Boolean;
begin
  Result := True;
  if RowNum = -1 then
    RowNum := MemTableEh1.RecNo - 1;
  b := False;
  for i := 0 to MemTableEh1.Fields.Count - 1 do begin
    FRec := Opt.GetFieldRec(MemTableEh1.Fields[i].FieldName);
    Value := VaRToStr(GetValue(MemTableEh1.Fields[i].FieldName, RowNum, False));
    if Value = 'ПФ' then
      b := True;
    IsValueCorrect := (FRec.FVerify = '') or S.VeryfyValue(q.QGetDataTypeAsChar(MemTableEh1.Fields[i].DataType), FRec.FVerify, Value, CorrectValue);
    if IsValueCorrect and Assigned(FOnVeryfyAndCorrectValues) then
      FOnVeryfyAndCorrectValues(Self, No, dbgvBefore, RecNo, MemTableEh1.Fields[i].FieldName, Value, Msg);
    st := IntToStr(RowNum + 1) + '-' + IntToStr(DbGridEh1.FindFieldColumn(MemTableEh1.Fields[i].FieldName).Index + 1);
    j := A.PosInArray(st, FEditData.CellsWithErrors);
    if IsValueCorrect and (i=2)
      then b := True
      else b := False;
    if not IsValueCorrect or (Msg <> '') then
      Result := False;
    if (not IsValueCorrect or (Msg <> '')) and (j = -1) then begin
      FEditData.CellsWithErrors := FEditData.CellsWithErrors + [st];
      b := True;
    end
    else if (IsValueCorrect and (Msg = '')) and (j > -1) then begin
      Delete(FEditData.CellsWithErrors, j, 1);
      b := True;
    end;
   // if b then
      //DbGridEh1.Repaint;
//      IncorrectRowMsg:='Ошибочное значение строке ' + InttoStr(MemTableEh1.RecNo) + ' в ячейке "' + DBGridEh1.Columns[i].Title.Caption + '"';
  end;
end;

function TFrDBGridEh.IsTableEmpty: Boolean;
//Вернет труе, если в таблице нет строк либо она содержить лишь пустые строки
var
  i: Integer;
begin
  Result := True;
  for i := 0 to GetCount(False) - 1 do begin
    Result := not IsRowNotEmpty(i);
    if not Result then
      Break;
  end;
end;

function TFrDBGridEh.IsTableCorrect: Boolean;
//Вернет труе, если в таблице все строки верные
//при этом пустые строки считаются верными
var
  i, j, k, m: Integer;
  ERows: string;
  Duplicates:  string;
begin
  Result := True;
  for i := 0 to GetCount(False) - 1 do begin
    if not IsRowNotEmpty(i) then
      Continue;
    if not IsRowCorrect(i) then begin
      Result := False;
      S.ConcatStP(ERows, IntToStr(i + 1), ', ');
    end;
  end;
  //проверим повторяющиеся поля
  for j := 0 to High(FEditOptions.FieldsNoRepaeted) do begin
    Duplicates := '';
    for k := 0 to GetCount(False) - 2 do begin
      for m := k + 1 to GetCount(False) - 1 do
        if GetValue(FEditOptions.FieldsNoRepaeted[j], k, False) = GetValue(FEditOptions.FieldsNoRepaeted[j], m, False) then begin
          Result := False;
          if Duplicates = '' then
            Duplicates := InttoStr(k + 1) + ' и ' + InttoStr(m + 1)
          else
            S.ConcatStP(Duplicates, InttoStr(m + 1), ',');
        end;
    end;
    if Duplicates <> '' then
      S.ConcatStP(ERows, 'Дублирующиеся значения в строках ' + InttoStr(k + 1) + ' и ' + InttoStr(m + 1) + ' в колонке "' + DBGridEh1.FindFieldColumn(FEditOptions.FieldsNoRepaeted[j]).Title.Caption + '"', #13#10);
  end;
  //выставим статус; если таблицу проверяем не всегда, HasError:=False, чтобы был доступен баттон Ок и по нажатии провреилась таблица и вышло сообщение об ошибке.
  SetState(null, S.IIf(EditOptions.AlwaysVerifyAllTable, False, not Result), S.IIfStr(not Result, 'Некорректные значения в строках:'#13#10 + ERows));
end;


procedure TFrDBGridEh.GetGridDimensions(var AWidth, AHeight: Integer);
//получим размер грида (нужно если например надо подогнать панель так чтобы весь грид был виден)
//!!! не учитывал индикаторный столбец
var
  i, j, k, rn, rh, fh, cl: Integer;
function IsHorzScrollBarVisible(hWnd: HWND): Boolean;
var
  style: Integer;
begin
  style := GetWindowLong(hWnd, GWL_STYLE);
  Result := (style and WS_HSCROLL) <> 0;
end;
begin
  rh := 0; fh := 0;
  for i := 0 to TDBGridEhMy(DBGridEh1).RowCount - 1 do
    rh := rh + TDBGridEhMy(DBGridEh1).RowHeights[i];
  for i := 0 to TDBGridEhMy(DBGridEh1).FooterRowCount - 1 do
    fh := fh + mydefGridRowHeight;
  AHeight := rh + fh + 5 + S.IIf((myogPanelFilter in Options) or (myogPanelFind in Options), 30, 0) + S.IIf(DBGridEh1.HorzScrollBar.Visible, 23 , 0);
  cl := 0;
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    if DBGridEh1.Columns[i].Visible then
      cl := cl + DBGridEh1.Columns[i].Width + 1;
  AWidth := cl + 5 + S.IIf(DBGridEh1.VertScrollBar.Visible, 23 , 0);
end;


end.


















(*









--------------------------------------------------------------------------------
для мемтейбл, стобцов грида всегда, грида всегда ReadOnly = False. редактируемость ячейки определяется
в событии ColumnsGetCellParams, на основаниии того что имя поля столбца в списке редактитруемых
и калбэк-функция не вернула ридонли.



выполнение установки опций грида до Prepare ведет к глюкам, устанавливаем значение FOptions в любом случае,
но грид настраиваем после препаре (вызов зетоптионс в конце препаре, и после при изменении поля опций как метод проперти)

кнопки с отрицательным айди не попадают на панель кнопок, но попадают в меню, т.е. можно писать [-btnAdd], [-1000, 'Настройки']

*)

(*


--------------------------------------------------------------------------------
Стастусы изменения данных и ошибки.
Задаются вручную публичной процедурой
SetState(AIsDataChanged, AHasError, AErrorMessage: Variant)
читаются из свойств. обабатываются процедурой Verify родительской TFrmBasicMdi, при nil все дочерние гриды,
а при изменениии статуса SetState вызывает процедуру Verify формы для обработки.
Внутри гридо обрабатывается статус IsDataChanged для грида в ровпанели, в случае установки данного статуса
основной грид перечитывает строку, в случае ошибки в детальном гриде - не закрывается детальная панель
(однко в этом случае некорректно работает обновление основного грида, основные кнопки надо блокировать!
или, как минимум, проверять статус панели в RefreshGrid, если она видна то не вызывать обновление!!!).
Все статусы сбрасываются, когда закрывается датасет (в MemTableEh1BeforeClose).
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
Загрузка и сохранение настроек
настроки сохраняются только в том случае если есть в опциях myogSaveOptions,
в событии закрытии датасета MemTableEh1BeforeClose, и при разрушении фрейма, если датасет открыт.
загружаются при открытии датасета в событии MemTableEh1AfterOpen, после применения настроек
грида, заданных параметрами в коде (опции)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
Баг с фильтром. при фильтрации в столбце, если задаютсмя правила в окне, они не применяются, по Ок
не вызывается событие OnApplyfilter. Также, поъхоже, не работают кнопки сортировки в окне фильтра.
Фильтр по уникальным значениям работает. Фиксим применением DefaultApplyfilter в обработчике DbGridEh1CellMouseClick,
если был клик в кнопку фильтра, и он не применился, то применяем при клике в грид.
но сам DbGridEh1CellMouseClick неверно определяет область клика мыши (тайтл, футер, индикатор), не было бы проблем с этим.\
событие OnEnter для грида также не возникает, хотя был переход в диалоговое окно, но это можно отледить
в дальнейшем используя переход фокуса между окнами.
--------------------------------------------------------------------------------
*)





(*

               ДОРАБОТАТЬ!
-блокировка опций в настройках вида таблицы (поел дял этого в Опт есть)
-установка произвольных опций с их сохранением в бд администратором
-неверно определается ограничение по ширине в зависимоти от размера панели кнопок
 (это видимо к frmMDI)
-пределение вертикального расположения заголовка столбца
-изменения статуса кнопок, созданных не в  панели фрейма (может и работает, не проверено!)
-процеждура проверки значения ячейки, строки, грида
-процедура дефолтной записи значения из редактра/пиклиста в датасет и в бд в случае такого режима работы
-процедуры добывления/удаления тсрок, массивы ацйди удаленных
-сервисная колонка
-хэш в сервисной колоонке, поределение по нему изменения данных
++при первом открытии грида в режиме загрузки из массива запись оказывается на последней строке
-SetButtonsIfEmpty добавить clear
-для форм выбора возвращать результата к TMDIResult формы
-баг: при нескольких кнопках в столбце вторая и дальше отрисовываются с темным фоном
-баг: если есть индикаторные чекбоксы, и есть группировка, не нажимаются плюсики в группах, а только слева от них

-в DbGridEh1AdvDrawDataCell не попадает при отрисовке заголовков при группировке,
а статусбар обновляется только там, так что может быть в случае группировки некорректная инфа в статусбаре

+2025-04-03
три дня новый грид заказов, суплются ошибки, которые не удеается отследить
поставил try-ex-end в prinntstatusbar и changeselecteddata
*)
