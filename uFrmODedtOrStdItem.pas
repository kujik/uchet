{
Редактирование стандартного изделия.
В дополнительном параметре всегда передается айди сметной группы (id_or_format_estimates).
Редактировать цену можно только обладая правом на это.
}


unit uFrmODedtOrStdItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFields, uFrmBasicDbDialog,
  Vcl.Mask
  ;

type
  //одна вкладка синхронизации парных изделий (произв./отгруз.) - см. общий комментарий к LoadCounterpartTabs.
  //FTabs[0] - всегда само редактируемое/добавляемое изделие (своя TTabSheet создается наравне с остальными -
  //см. LoadCounterpartTabs, иначе индексы FTabs и pgcFormat.Pages расходятся), FTabs[1..] - парные подгруппы
  //(тот же id_format, тот же sync_group, противоположный тип О/П). SyncChecked/NotCreateChecked - состояние
  //чекбоксов "Синхронизировать"/"Не создавать" для вкладки; сами чекбоксы общие на форму (chb_TabSync/
  //chb_TabNotCreate под pgcFormat), а не по одному на вкладку - см. SetTabsControlsState/ChbSyncClick.
  TCounterpartTab = record
    IdOrFormatEstimate: Variant;
    ItemType: Integer;
    Sheet: TTabSheet;
    SyncChecked: Boolean;
    NotCreateChecked: Boolean;
    //массив уже существующих изделий этой подгруппы (or_std_items.id_or_format_estimates = IdOrFormatEstimate),
    //предзагруженный ОДИН РАЗ при построении вкладки (см. LoadCounterpartTabs/LoadExistingNamesForTab) - чтобы
    //проверка "такое наименование уже есть" по мере ввода в edt_name (см. CheckNameDuplicates) не дёргала БД на
    //каждое нажатие клавиши, а искала в уже загруженном в память списке. Столбцы (см. LoadExistingNamesForTab):
    //[0]=наименование, [1]=id, [2..]=price_base/wo_estimate/r0/r1..rN - строго тем же полям и в том же порядке,
    //что и FSyncFields (см. общий комментарий там же). Собственная запись редактируемого изделия (ID) в выборку
    //не включается (она не может быть "дубликатом самой себя").
    ExistingNames: TVarDynArray2;
    //найдено ли ПРЯМО СЕЙЧАС (по текущему тексту edt_name) совпадение среди ExistingNames этой вкладки, и
    //индекс найденной строки (используются в pgcFormatDrawTab - маркер+цвет на заголовке вкладки - и в
    //CheckNameDuplicates/ApplyExistingItemToTabSlot - подстановка данных найденного изделия в поля вкладки)
    DuplicateFound: Boolean;
    DuplicateRow: Integer;
  end;

  TFrmODedtOrStdItem = class(TFrmBasicDbDialog)
    pgcFormat: TPageControl;
    cmb_id_or_format_estimates: TDBComboBoxEh;
    edt_prefix: TDBEditEh;
    edt_name: TDBEditEh;
    chb_R0: TDBCheckBoxEh;
    chb_Wo_Estimate: TDBCheckBoxEh;
    nedt_price_base: TDBNumberEditEh;
    chb_by_sgp: TDBCheckBoxEh;
    bvlTabSync: TBevel;
    chb_TabSync: TCheckBox;
    chb_TabNotCreate: TCheckBox;
    btn_TabCopyRoute: TSpeedButton;
  private
    FRcount: Integer;
    FNameOld : string;
    FWoEstimateOld: Integer;
    FIdEstimateGroup: Variant;
    FPrefix: string ;
    FIsRouteChanged: Boolean;
    FIdOrFormatEstimate: Variant;
    //режим вызова диалога, AddParam[1] - см. общий комментарий в начале Prepare (VarArrayOf([IdOrFormatEstimate,
    //CallMode])): 1 - обычный вызов из справочника (uFrmOGrefOrStdItems), 2 - только добавление с выбором
    //подгруппы по прежней (ограниченной по группе/типу) логике, 3 - только добавление с выбором ЛЮБОЙ активной
    //подгруппы любой активной группы, любого типа изделий (см. LoadCbFormatEstimates)
    FCallMode: Integer;
    //группа (id_format) и тип (см. STDITEM_TYPE_* в uOrders) переданной (исходной) подгруппы - см. LoadCbFormatEstimates
    FIdFormat: Variant;
    FItemType: Integer;
    //вкладки синхронизации парных изделий (см. TCounterpartTab) и текущая активная вкладка (индекс в FTabs)
    FTabs: array of TCounterpartTab;
    FActiveTab: Integer;
    //список полей (через ;), которые копируются между вкладками при синхронизации - см. SwitchToTab;
    //наименование (синхронизируется всегда, отдельно) и by_sgp (никогда не синхронизируется) сюда не входят
    FSyncFields: string;
    //признак чекбокса "Создать одно"/"Редактировать одно" в левой панели кнопок - см. ChbOneOnlyClick
    FOneOnly: Boolean;
    //признак, что первоначальное автовыравнивание/подгонка размеров формы (CorrectFormSize, вызывается один раз
    //из FormShow) уже произошла - пока False, SetTabsControlsState НЕ трогает видимость bvlTabSync/chb_TabSync/
    //chb_TabNotCreate/btn_TabCopyRoute (кроме случая полного отсутствия вкладок - см. там же), чтобы на момент
    //авторасчета высоты формы (Cth.AlignControls в uForms.pas) эти контролы посчитались как обычные видимые и
    //под них было зарезервировано место - иначе (см. подробный комментарий у TFrmBasicMdi.CorrectFormSize)
    //авторасчет полностью проигнорирует их (место не резервируется под изначально невидимые контролы), и при
    //первом же переключении на парную вкладку они окажутся ниже реально показанной высоты панели - формально
    //Visible = True, но невидимы, пока пользователь не растянет форму вручную. Взводится в AfterFormActivate
    //(гарантированно после CorrectFormSize) - см. там же.
    FTabsVisReady: Boolean;
    function  Prepare: Boolean; override;
    procedure AfterFormActivate; override;
    procedure ControlOnChange(Sender: TObject); override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    //заполняет комбобокс Формат по правилам, зависящим от типа исходной подгруппы (FItemType) - см. реализацию
    procedure LoadCbFormatEstimates;
    //обновляет FPrefix и поле "Префикс" по текущему значению, выбранному в комбобоксе Формат
    procedure SetPrefixByFormat;
    //пересоздает вкладки парных изделий (FTabs[1..]) по коду синхронизации (or_format_estimates.sync_group)
    procedure LoadCounterpartTabs;
    procedure pgcFormatChange(Sender: TObject);
    procedure pgcFormatDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
    //переключение общих контролов (FSyncFields) на данные другой вкладки - см. реализацию
    procedure SwitchToTab(ANewIndex: Integer);
    procedure ChbSyncClick(Sender: TObject);
    procedure ChbNotCreateClick(Sender: TObject);
    procedure BtnCopyRouteClick(Sender: TObject);
    procedure ChbOneOnlyClick(Sender: TObject);
    //блокировка/разблокировка общих полей в зависимости от активной вкладки и ее состояния синхронизации
    procedure SetTabsControlsState;
    //предзагружает ATab.ExistingNames - см. общий комментарий у TCounterpartTab.ExistingNames; вызывается из
    //LoadCounterpartTabs для каждой вкладки (включая FTabs[0]) сразу при её построении
    procedure LoadExistingNamesForTab(var ATab: TCounterpartTab);
    //ищет AName (уже нормализованное - UpperCase(Trim(...))) среди ATab.ExistingNames; -1, если не найдено
    function  FindExistingNameRow(const ATab: TCounterpartTab; const AName: string): Integer;
    //живая (без обращения к БД) проверка совпадения текущего edt_name с уже существующими изделиями по каждой
    //вкладке - см. подробный комментарий у реализации; вызывается из VerifyAdd на каждое изменение любого поля
    procedure CheckNameDuplicates;
    //подставляет в поля вкладки ATabIndex (через её слот fvtCustom, см. общий комментарий в SwitchToTab) данные
    //найденного изделия (строка ARow в ExistingNames этой вкладки) и снимает синхронизацию на этой вкладке -
    //см. подробный комментарий у реализации
    procedure ApplyExistingItemToTabSlot(ATabIndex, ARow: Integer);
    //обратное действие ApplyExistingItemToTabSlot - совпадение по имени на вкладке ATabIndex пропало,
    //возвращаем синхронизацию по умолчанию (True)
    procedure ResetTabSlotSync(ATabIndex: Integer);
    //показывает/прячет чекбокс "Создать одно"/"Редактировать одно" по текущему FItemType (не для полуфабрикатов) -
    //отдельным методом, а не только в Prepare, т.к. тип может смениться уже после Prepare, если пользователь
    //выбирает другую подгруппу в комбобоксе Формат (актуально для CallMode = 3, см. ControlOnChange)
    procedure UpdateChbOneOnlyVisible;
  protected
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure SetRoute;
  public
  end;

var
  FrmODedtOrStdItem: TFrmODedtOrStdItem;

implementation

 uses
   uOrders
   ;

 {$R *.dfm}

function TFrmODedtOrStdItem.Prepare: Boolean;
var
  i, j: Integer;
  va: TVarDynArray;
  va1, va2: TVarDynArray2;
begin
  Result := False;
  Caption:='Стандартное изделие';

  //айди переданной (исходной) подгруппы и режим вызова диалога - см. общий комментарий вверху модуля.
  //AddParam теперь VarArrayOf([IdOrFormatEstimate, CallMode]) - см. также объявление FCallMode:
  //  CallMode = 1 - обычный вызов из справочника (uFrmOGrefOrStdItems) или на просмотр (uFrmOGedtEstimate) -
  //    вся прежняя логика без изменений;
  //  CallMode = 2 - вызов ТОЛЬКО на добавление (например, из диалога сметы) - подгруппа выбирается в комбобоксе
  //    Формат по прежней, ограниченной по группе форматов/типу логике (как и раньше при добавлении);
  //  CallMode = 3 - вызов только на добавление, но подгруппу можно выбрать из ЛЮБОЙ активной подгруппы любой
  //    активной группы форматов, любого типа изделий (не только совпадающего с переданной) - см.
  //    LoadCbFormatEstimates. Переданная подгруппа (AddParam[0]) в этом случае может быть Null - тогда в
  //    комбобоксе изначально просто ничего не выбрано.
  //Для CallMode 2 и 3 принудительно выставляем Mode := fAdd, чтобы не ошибиться, если вызывающий код передал
  //что-то другое - режимы добавления по смыслу и не предполагают ничего, кроме добавления.
  FIdOrFormatEstimate := AddParam[0];
  FCallMode := S.NInt(AddParam[1]);
  if FCallMode in [2, 3] then
    Mode := fAdd;

  //группа форматов (id_format) и тип (О/П/ПФ) исходной подгруппы нужны для формирования списка комбобокса
  //Формат (см. LoadCbFormatEstimates); делаем это до вызова inherited, т.к. в режиме редактирования inherited
  //сразу загружает из БД и устанавливает в комбобокс текущее значение поля id_or_format_estimates, а список
  //комбобокса должен быть заполнен заранее, иначе значение не отобразится.
  //Для CallMode = 3 переданная подгруппа может отсутствовать (Null/0) - тогда группу/тип изначально не знаем,
  //определятся уже по факту выбора пользователем в комбобоксе (см. ControlOnChange); до этого момента считаем
  //тип "неизвестным" (не полуфабрикатом, чтобы не спрятать чекбокс "Создать одно" раньше времени - см. ниже).
  if S.NNum(FIdOrFormatEstimate) > 0 then begin
    va := Q.QLoadRow('select id_format, type from or_format_estimates where id = :id$i', [FIdOrFormatEstimate]);
    FIdFormat := va[0];
    FItemType := S.NInt(va[1]);
  end
  else begin
    FIdFormat := Null;
    FItemType := -1;
  end;
  LoadCbFormatEstimates;
  //поле Формат доступно для выбора только при добавлении/копировании - см. LoadCbFormatEstimates (в остальных
  //режимах в списке остается только одна, текущая строка, и поле недоступно)
  cmb_id_or_format_estimates.Enabled := Mode in [fAdd, fCopy];

  //чекбокс "Создать одно"/"Редактировать одно" - в левой панели кнопок; полностью отключает вкладки парных
  //изделий (см. ChbOneOnlyClick); не показывается для полуфабрикатов (для них вкладок нет вообще) и в
  //режиме просмотра/удаления (там нечего создавать/менять). Создаём его здесь один раз (если режим вообще
  //допускает), а видимость по типу подгруппы обновляем отдельно (UpdateChbOneOnlyVisible) - тип подгруппы может
  //поменяться уже после Prepare, если пользователь выбирает другую подгруппу в комбобоксе (актуально для
  //CallMode = 3, где в комбобоксе вперемешку подгруппы всех типов, включая полуфабрикаты - см. ControlOnChange).
  FOneOnly := False;
  if not (Mode in [fView, fDelete]) then begin
    Cth.CreateControls(pnlFrmBtnsL, cntCheck, S.IIfStr(Mode = fEdit, 'Редактировать одно', 'Создать одно'), 'chb_OneOnly', '', 0, 4, 4);
    TDBCheckBoxEh(Self.FindComponent('chb_OneOnly')).OnClick := ChbOneOnlyClick;
    //Cth.CreateControls не задаёт ширину чекбокса по тексту (см. её реализацию в uForms.pas) - для более
    //длинного варианта подписи ("Редактировать одно") текст обрезался; подгоняем ширину под фактический текст
    Cth.AutoSizeCheckBoxes(pnlFrmBtnsL, [], [], ['chb_OneOnly'], []);
  end;
  //видимость (по типу подгруппы) и раскладка панели - см. подробный комментарий в UpdateChbOneOnlyVisible про
  //CorrectFormSize и ширину панели (актуально в т.ч. когда чекбокс выше вообще не создавался - тогда просто выйдет)
  UpdateChbOneOnlyVisible;

  //вкладки парных изделий (произв./отгруз.) - см. LoadCounterpartTabs; при просмотре/удалении показываем
  //ридонли (сами блокировки полей обеспечит общий механизм диалога для этих режимов).
  //OnClick общих контролов синхронизации назначаем здесь, кодом, а не через .dfm - методы приватные, и при
  //потоковой загрузке формы (DFM streaming) Delphi не резолвит приватные методы в OnClick ("invalid property
  //value" при открытии формы) - см. также chb_OneOnly ниже, тот же паттерн.
  pgcFormat.OwnerDraw := True;
  pgcFormat.OnDrawTab := pgcFormatDrawTab;
  chb_TabSync.OnClick := ChbSyncClick;
  chb_TabNotCreate.OnClick := ChbNotCreateClick;
  btn_TabCopyRoute.OnClick := BtnCopyRouteClick;
  FActiveTab := 0;
  LoadCounterpartTabs;

  for i := 0 to High(RouteFields) do begin
    Cth.CreateControls(pnlFrmClient, cntCheck, RouteFields[i], 'chb_r' + IntToStr(i + 1), '', 0, edt_name.Left + i * 50, edt_name.Top + edt_name.Height + MY_FORMPRM_H_EDGES);
    TDBCheckBoxEh(Self.FindComponent('chb_r' + IntToStr(i + 1))).Caption := RouteFields[i];
    va2 :=  va2 + [['r' + IntToStr(i + 1) + '$i']];
  end;

  //список полей, синхронизируемых между вкладками (наименование - отдельно, всегда; by_sgp - никогда, см. SwitchToTab)
  FSyncFields := 'price_base;wo_estimate;r0';
  for i := 0 to High(RouteFields) do
    FSyncFields := FSyncFields + ';r' + IntToStr(i + 1);

  F.DefineFields:=[
    ['id$i'],
    ['name$s','V=1:400::T'],
    ['price_base$f','V=0:9999999:2:n'],
    //['price_pp$f','V=0:9999999:2:n'],
    ['wo_estimate$i'],
    ['r0$i'],
    ['by_sgp$i'],
    ['id_or_format_estimates$i','V=1:400:1']
  ] + va2;

  View := 'v_or_std_items';
  Table := 'or_std_items';
  FOpt.UseChbNoClose:= True;
  //Opt.RequestWhereClose:= cqYNC;
  FOpt.InfoArray:= [[
     'Ввод параметров стандартного изделия.'#13#10+
     'Введите или измените все необходимые данные.'#13#10+
     'При изменении наименования оно будет автоматически изменено во всех изделиях Учета и ИТМ'#13#10+
     '(но если такое наименование есть в качестве позиции в смете, то там оно изменено не будет!)'#13#10+
     'При изменении маршрута или цен по изделию, они будут скорректированы во всех шаблонах папортов.'#13#10
  ]];

  //ранее была ошибочная гипотеза, что нижние (chb_TabSync/chb_TabNotCreate/btn_TabCopyRoute) контролы были не
  //видны после автоподгонки высоты формы из-за размеров формы - на самом деле причина была в том, что на
  //момент автоподгонки (CorrectFormSize, вызывается позже, из FormShow) они уже были Visible = False (см.
  //SetTabsControlsState, FActiveTab = 0 при первом показе) - под изначально невидимые контролы место не
  //резервируется, см. подробный комментарий у TFrmBasicMdi.CorrectFormSize (uFrmBasicMdi.pas). Решение - именно
  //FTabsVisReady/AfterFormActivate (см. объявление FTabsVisReady выше и AfterFormActivate ниже), FWHBounds.Y2
  //ниже к этой проблеме отношения не имеет и трогать его для её решения не нужно было.
  //
  //FWHBounds.Y2 := -1 ниже - отдельная, намеренная настройка: форма сделана горизонтально растягиваемой
  //(myfoSizeable + якоря akRight у pgcFormat/edt_name/bvlTabSync), но НЕ вертикально - логика расположения
  //контролов (Cth.AlignControls в uForms.pas) не расчитана на вертикальное растягивание. -1 здесь не означает
  //"без ограничения" - по логике CorrectFormSize (uFrmBasicMdi.pas) это прижимает максимум высоты к уже
  //посчитанному минимуму, т.е. именно запрещает расти по вертикали - здесь это то, что нужно.
  FWHBounds.Y2 := -1;
  Result := inherited;
  if not Result then
    Exit;
  if Mode <> fDelete then begin
    FNameOld := S.NSt(F.GetPropB('name'));
    FWoEstimateOld:=S.NInt(F.GetPropB('wo_estimate'));
    //AddParam теперь массив (см. общий комментарий в начале Prepare) - берём уже разобранное значение группы
    FIdEstimateGroup := FIdOrFormatEstimate;
    F.SetProp('id_or_format_estimates$i',FIdOrFormatEstimate);
    //FPrefix/FIdEstimateGroup - см. SetPrefixByFormat; вызывается и здесь (для начального значения), и из
    //ControlOnChange при смене выбора в комбобоксе Формат (актуально в режиме добавления/копирования)
    SetPrefixByFormat;
  end;
  if (Mode = fEdit) and not User.Role(rOr_R_StdItems_Set_Prices) then begin
    nedt_price_base.ReadOnly := True;
    //nedt_Price_PP.ReadOnly := True;
  end;
  SetRoute;
  //обработчик переключения вкладок подключаем только теперь, когда F полностью готов (иначе сработает уже
  //при создании самих TTabSheet в LoadCounterpartTabs, до готовности полей)
  pgcFormat.OnChange := pgcFormatChange;
  SetTabsControlsState;
end;

procedure TFrmODedtOrStdItem.ControlOnChange(Sender: TObject);
var
  va: TVarDynArray;
begin
  if (A.InArray(TControl(Sender).Name, ['chb_R0', 'chb_Wo_Estimate'])) or (Copy(TControl(Sender).Name, 1, 6) = 'chb_r') then
    SetRoute;
  if TControl(Sender).Name = 'cmb_id_or_format_estimates' then begin
    SetPrefixByFormat;
    //подгруппа сменилась (возможно только в режиме добавления/копирования - в остальных комбобокс задизейблен) -
    //пересчитаем состав вкладок парных изделий по новой подгруппе (у нее может быть другой id_format/sync_group)
    FIdOrFormatEstimate := Cth.GetControlValue(cmb_id_or_format_estimates);
    va := Q.QLoadRow('select id_format, type from or_format_estimates where id = :id$i', [FIdOrFormatEstimate]);
    FIdFormat := va[0];
    FItemType := S.NInt(va[1]);
    FActiveTab := 0;
    LoadCounterpartTabs;
    SetTabsControlsState;
    //тип выбранной подгруппы мог смениться (актуально для CallMode = 3, где в комбобоксе вперемешку подгруппы
    //всех типов, включая полуфабрикаты) - обновляем видимость чекбокса "Создать одно" под новый тип
    UpdateChbOneOnlyVisible;
  end;
  inherited;
end;

procedure TFrmODedtOrStdItem.LoadCbFormatEstimates;
//заполняет cmb_id_or_format_estimates (комбобокс Формат):
//- при CallMode = 3 (см. общий комментарий в Prepare) - вообще без ограничений: все активные подгруппы всех
//  активных групп, любого типа изделий (произв./отгруз./ПФ вперемешку) - используется при вызове диалога только
//  на добавление откуда угодно (не из справочника), когда исходная подгруппа не важна или вовсе не задана;
//- иначе (CallMode 1/2), если исходная подгруппа - полуфабрикат (STDITEM_TYPE_SEMIPRODUCT) - все подгруппы всех
//  групп с типом "полуфабрикат", при этом подгруппы, принадлежащие текущей группе (FIdFormat), идут сразу за
//  верхней строкой;
//- иначе (отгрузочное/производственное) - только подгруппы той же группы форматов (того же id_format, FIdFormat)
//  и того же типа.
//самая верхняя строка списка - всегда исходная подгруппа (FIdOrFormatEstimate), см. decode(e.id, ..., 0, 1) -
//если она не задана (Null/0, допустимо при CallMode = 3), верхняя строка ничем не выделяется, список идет в
//обычном алфавитном порядке (decode с NULL-параметром ни с одной реальной e.id не совпадёт).
//в режиме, отличном от добавления/копирования, в списке остается только эта одна (верхняя) строка -
//см. cmb_id_or_format_estimates.Enabled в Prepare
var
  i: Integer;
begin
  if FCallMode = 3 then
    Q.QLoadToDBComboBoxEh(
      'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' +
      'from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and (e.active = 1 or e.id = :idsel1$i) ' +
      'order by decode(e.id, :idsel2$i, 0, 1), f.name, e.name',
      [FIdOrFormatEstimate, FIdOrFormatEstimate],
      cmb_id_or_format_estimates, cntComboLK
    )
  else if FItemType = STDITEM_TYPE_SEMIPRODUCT then
    Q.QLoadToDBComboBoxEh(
      'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' +
      'from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and e.type = :type1$i and (e.active = 1 or e.id = :idsel1$i) ' +
      'order by decode(e.id, :idsel2$i, 0, 1), decode(e.id_format, :idformat1$i, 0, 1), f.name, e.name',
      [STDITEM_TYPE_SEMIPRODUCT, FIdOrFormatEstimate, FIdOrFormatEstimate, FIdFormat],
      cmb_id_or_format_estimates, cntComboLK
    )
  else
    Q.QLoadToDBComboBoxEh(
      'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' +
      'from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and e.id_format = :idformat1$i and e.type = :type1$i and (e.active = 1 or e.id = :idsel1$i) ' +
      'order by decode(e.id, :idsel2$i, 0, 1), f.name, e.name',
      [FIdFormat, FItemType, FIdOrFormatEstimate, FIdOrFormatEstimate],
      cmb_id_or_format_estimates, cntComboLK
    );
  if not (Mode in [fAdd, fCopy]) then
    //вне добавления/копирования подгруппа изделия уже определена и не должна меняться - оставим только
    //верхнюю (см. order by выше - это всегда исходная подгруппа) строку списка
    for i := cmb_id_or_format_estimates.Items.Count - 1 downto 1 do begin
      cmb_id_or_format_estimates.Items.Delete(i);
      cmb_id_or_format_estimates.KeyItems.Delete(i);
    end;
end;

procedure TFrmODedtOrStdItem.SetPrefixByFormat;
//обновляет FPrefix/FIdEstimateGroup и отображаемое поле "Префикс" по подгруппе, выбранной в данный момент
//в комбобоксе Формат (FIdEstimateGroup используется далее в VerifyBeforeSave/Save для проверки уникальности
//наименования и синхронизации переименования с ИТМ - см. эти процедуры)
var
  LId: Variant;
begin
  LId := Cth.GetControlValue(cmb_id_or_format_estimates);
  FIdEstimateGroup := LId;
  if S.NNum(LId) > 0 then
    FPrefix := Q.QLoadValue('select prefix from or_format_estimates where id = :id$i', [LId]).AsString
  else
    FPrefix := '';
  edt_prefix.Text := FPrefix;
end;

procedure TFrmODedtOrStdItem.LoadCounterpartTabs;
//пересоздает вкладки парных изделий - подгруппы того же id_format (FIdFormat), того же кода синхронизации
//(or_format_estimates.sync_group), что и у исходной подгруппы (FIdOrFormatEstimate), и ПРОТИВОПОЛОЖНОГО типа
//О/П (произв./отгруз.); sync_group = 0 у исходной подгруппы означает, что синхронизация для нее не предлагается
//вообще (вкладок не будет); учитываются только активные (active=1) подгруппы. Полуфабрикаты (тип
//STDITEM_TYPE_SEMIPRODUCT) в парах никогда не участвуют - ни как исходная подгруппа (тогда вкладок нет вообще,
//см. проверку FItemType ниже), ни как кандидат в пару (см. "and e.type <> :tsp$i" в запросе) - у них своя,
//отдельная логика (см. общий комментарий по ПФ), даже если по ошибке/по умолчанию у них тот же sync_group.
//
//TTabSheet создается для КАЖДОГО элемента FTabs, включая FTabs[0] (само редактируемое/добавляемое изделие) -
//это важно, чтобы pgcFormat.Pages[i] всегда 1-в-1 соответствовал FTabs[i] (иначе переключение вкладок съезжает
//на один индекс - см. pgcFormatChange/SwitchToTab). "Содержимое" любой вкладки - это общие поля формы
//(edt_name/nedt_price_base/маршрут и т.д.), всегда видимые под pgcFormat и переключаемые между вкладками -
//см. SwitchToTab, где объясняется сам механизм. Чекбоксы "Синхронизировать"/"Не создавать" и кнопка копирования
//маршрута - тоже общие на форму (chb_TabSync/chb_TabNotCreate/btn_TabCopyRoute под pgcFormat), не по одному на
//вкладку - см. SetTabsControlsState.
//
//Если пары не нашлось - вкладок не создается вообще (в т.ч. и для FTabs[0]) - pgcFormat остается пуст и скрыт.
//
//Вызывается из Prepare, а также повторно из ControlOnChange при смене выбора в комбобоксе Формат (только в
//режиме добавления/копирования - см. там же).
var
  i: Integer;
  va2: TVarDynArray2;
  LSyncGroup: Variant;
  LSheet: TTabSheet;
  LCapt0: string;
begin
  while pgcFormat.PageCount > 0 do
    pgcFormat.Pages[0].Free;
  SetLength(FTabs, 1);
  FTabs[0].IdOrFormatEstimate := FIdOrFormatEstimate;
  FTabs[0].ItemType := FItemType;
  FTabs[0].Sheet := nil;
  FTabs[0].DuplicateFound := False;
  FTabs[0].DuplicateRow := -1;
  //предзагрузка списка существующих изделий своей же подгруппы - нужна независимо от наличия парных вкладок
  //(см. CheckNameDuplicates - подсветка edt_name при добавлении, если наименование уже занято в этой подгруппе)
  LoadExistingNamesForTab(FTabs[0]);

  if FItemType <> STDITEM_TYPE_SEMIPRODUCT then begin
    LSyncGroup := Q.QLoadValue('select sync_group from or_format_estimates where id = :id$i', [FIdOrFormatEstimate]);
    if S.NNum(LSyncGroup) > 0 then
      va2 := Q.QLoad(
        'select e.id, e.type, f.name || '' ['' || e.name || '']'' as capt ' +
        'from or_formats f, or_format_estimates e ' +
        'where e.id_format = f.id and e.id_format = :idf$i and e.active = 1 and e.sync_group = :sg$i ' +
        'and e.type <> :t$i and e.type <> :tsp$i ' +
        'order by e.type, capt',
        [FIdFormat, LSyncGroup, FItemType, STDITEM_TYPE_SEMIPRODUCT]
      );
  end;

  if Length(va2) > 0 then begin
    //своя вкладка (FTabs[0]) - см. общий комментарий выше
    LCapt0 := VarToStr(Q.QLoadValue(
      'select f.name || '' ['' || e.name || '']'' from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and e.id = :id$i',
      [FIdOrFormatEstimate]
    ));
    LSheet := TTabSheet.Create(Self);
    LSheet.PageControl := pgcFormat;
    //3 пробела спереди - зарезервированное место под маркер совпадения (см. pgcFormatDrawTab/CheckNameDuplicates).
    //Ширина таба, которую реально выделяет Windows/VCL под кнопку вкладки, считается ОДИН РАЗ по этой, статической
    //Caption - то, что рисуется в OnDrawTab (pgcFormatDrawTab), на эту ширину уже не влияет. Если добавлять
    //маркер только при обнаружении (меняя длину текста), текст вылезает за пределы уже отведенной под таб
    //области и не стирается корректно при снятии маркера, пока не перерисуется соседняя вкладка. Поэтому длину
    //Caption фиксируем сразу, а маркер потом только подменяет первый символ на месте (см. pgcFormatDrawTab).
    //Пробелов взято 3, а не 2 - шрифт не моноширный, и маркер "●" визуально немного шире одного пробела, двух
    //впритык не хватало (текст всё равно слегка наезжал на соседнюю вкладку); один запасной пробел с гарантией
    //покрывает эту разницу.
    LSheet.Caption := '   ' + LCapt0;
    FTabs[0].Sheet := LSheet;

    for i := 0 to High(va2) do begin
      SetLength(FTabs, Length(FTabs) + 1);
      FTabs[High(FTabs)].IdOrFormatEstimate := va2[i][0];
      FTabs[High(FTabs)].ItemType := S.NInt(va2[i][1]);
      FTabs[High(FTabs)].SyncChecked := True;
      FTabs[High(FTabs)].NotCreateChecked := False;
      FTabs[High(FTabs)].DuplicateFound := False;
      FTabs[High(FTabs)].DuplicateRow := -1;
      LoadExistingNamesForTab(FTabs[High(FTabs)]);
      LSheet := TTabSheet.Create(Self);
      LSheet.PageControl := pgcFormat;
      //см. комментарий про 3 пробела спереди у LCapt0/FTabs[0] выше
      LSheet.Caption := '   ' + VarToStr(va2[i][2]);
      FTabs[High(FTabs)].Sheet := LSheet;
    end;
  end;

  pgcFormat.Visible := (not FOneOnly) and (pgcFormat.PageCount > 0);
end;

procedure TFrmODedtOrStdItem.LoadExistingNamesForTab(var ATab: TCounterpartTab);
//см. общий комментарий у TCounterpartTab.ExistingNames. Список полей после name/id - price_base, wo_estimate,
//r0, r1..rN - специально повторяет порядок построения FSyncFields (см. Prepare, тот же цикл по RouteFields);
//на момент вызова (из LoadCounterpartTabs, а она - из Prepare, до объявления FSyncFields) сама переменная
//FSyncFields еще не построена, поэтому колонки строим напрямую по RouteFields, а не через FSyncFields -
//при изменении состава FSyncFields в Prepare не забыть поправить и здесь.
var
  i: Integer;
  LFields: string;
begin
  LFields := 'price_base, wo_estimate, r0';
  for i := 0 to High(RouteFields) do
    LFields := LFields + ', r' + IntToStr(i + 1);
  ATab.ExistingNames := Q.QLoad(
    'select name, id, ' + LFields + ' from or_std_items where id_or_format_estimates = :idf$i and id <> :id$i',
    [ATab.IdOrFormatEstimate, ID]
  );
end;

function TFrmODedtOrStdItem.FindExistingNameRow(const ATab: TCounterpartTab; const AName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  if AName = '' then
    Exit;
  for i := 0 to High(ATab.ExistingNames) do
    if UpperCase(Trim(VarToStr(ATab.ExistingNames[i][0]))) = AName then begin
      Result := i;
      Exit;
    end;
end;

procedure TFrmODedtOrStdItem.CheckNameDuplicates;
//по текущему тексту edt_name проверяет по каждой вкладке (FTabs[i]), нет ли уже среди ExistingNames этой
//вкладки изделия с таким же наименованием - без обращения к БД (см. LoadExistingNamesForTab). Вызывается из
//VerifyAdd, т.е. фактически на каждое изменение любого поля формы (не только edt_name) - лишняя работа
//(лишний проход по уже загруженным в память небольшим массивам), но по-другому не выйдет без отдельного
//OnChange именно для edt_name, а общий диспетчер (ControlOnChangeEvent -> Verify -> VerifyAdd) уже вызывается
//централизованно на любое изменение, см. uFrmBasicMdi.pas.
//
//Для вкладок i > 0 (парные подгруппы) совпадение означает, что там уже есть отдельно существующее изделие с
//таким наименованием - подставляем его данные (цена/маршрут) в поля этой вкладки и снимаем синхронизацию по
//умолчанию (ApplyExistingItemToTabSlot) - подставляем заново при КАЖДОМ обнаружении, пока совпадение держится
//(так проще и предсказуемее, чем отслеживать "трогал ли пользователь вкладку вручную", но означает, что ручные
//правки полей на этой вкладке будут затёрты повторной подстановкой при следующем изменении любого поля формы,
//пока наименование продолжает совпадать).
//Для вкладки 0 (само добавляемое/редактируемое изделие) совпадение - это НЕ пара, а обычный конфликт
//уникальности (тот же случай, что и так уже блокируется на сохранении - см. VerifyBeforeSave); данные никуда
//не подставляются, только маркер на вкладке (см. pgcFormatDrawTab) и, только в режиме добавления, подсветка
//самого поля edt_name (Cth.SetErrorMarker) - в режиме редактирования подсветка поля избыточна, при
//редактировании без смены имени собственная запись уже исключена запросом (id <> :id$i в LoadExistingNamesForTab).
var
  i, LRow: Integer;
  LName: string;
  LRedraw: Boolean;
begin
  LName := UpperCase(Trim(edt_name.Text));
  LRedraw := False;
  for i := 0 to High(FTabs) do begin
    LRow := FindExistingNameRow(FTabs[i], LName);
    if (LRow >= 0) <> FTabs[i].DuplicateFound then
      LRedraw := True;
    if LRow >= 0 then begin
      FTabs[i].DuplicateFound := True;
      FTabs[i].DuplicateRow := LRow;
      if i > 0 then
        ApplyExistingItemToTabSlot(i, LRow);
    end
    else begin
      if FTabs[i].DuplicateFound and (i > 0) then
        ResetTabSlotSync(i);
      FTabs[i].DuplicateFound := False;
      FTabs[i].DuplicateRow := -1;
    end;
  end;
  if LRedraw and (pgcFormat.PageCount > 0) then
    pgcFormat.Invalidate;
  Cth.SetErrorMarker(edt_name, (Mode = fAdd) and (Length(FTabs) > 0) and FTabs[0].DuplicateFound);
end;

procedure TFrmODedtOrStdItem.ApplyExistingItemToTabSlot(ATabIndex, ARow: Integer);
//подставляет в слот fvtCustom[ATabIndex] значения полей найденного изделия (строка ARow в ExistingNames этой
//вкладки - см. общий комментарий у TCounterpartTab.ExistingNames про порядок столбцов) и снимает синхронизацию
//на этой вкладке (SyncChecked := False) - раз изделие уже существует независимо, синхронизировать его с
//первой вкладкой по умолчанию не нужно. Если ATabIndex - активная вкладка прямо сейчас, дополнительно
//обновляем видимые контролы и их состояние (замок/разблокировка) - см. SwitchToTab/SetTabsControlsState,
//логика та же, что при обычном переключении на несинхронизированную вкладку.
var
  LFields: TVarDynArray;
  j: Integer;
begin
  LFields := A.ExplodeV(FSyncFields, ';');
  for j := 0 to High(LFields) do
    if j + 2 <= High(FTabs[ATabIndex].ExistingNames[ARow]) then
      F.SetProp(VarToStr(LFields[j]), FTabs[ATabIndex].ExistingNames[ARow][j + 2], ATabIndex);
  FTabs[ATabIndex].SyncChecked := False;
  if ATabIndex = FActiveTab then begin
    F.SetPropsFromCustom(FSyncFields, ATabIndex, fvtVCurr, True);
    SetTabsControlsState;
  end;
end;

procedure TFrmODedtOrStdItem.ResetTabSlotSync(ATabIndex: Integer);
//см. ApplyExistingItemToTabSlot - обратное действие, когда совпадение по имени на вкладке ATabIndex пропало
//(наименование поменяли на другое, для которого пары уже нет): возвращаем синхронизацию по умолчанию (как в
//LoadCounterpartTabs при первом построении вкладки)
begin
  FTabs[ATabIndex].SyncChecked := True;
  if ATabIndex = FActiveTab then begin
    F.SetPropsFromCustom(FSyncFields, 0, fvtVCurr, True);
    SetTabsControlsState;
  end;
end;

procedure TFrmODedtOrStdItem.UpdateChbOneOnlyVisible;
//показывает/прячет чекбокс "Создать одно"/"Редактировать одно" по ТЕКУЩЕМУ FItemType (не показываем для
//полуфабрикатов - для них вкладок парных изделий нет вообще, чекбокс не нужен, см. LoadCounterpartTabs).
//Отдельным методом, а не только внутри Prepare - потому что тип может смениться уже ПОСЛЕ Prepare, если
//пользователь выбирает другую подгруппу в комбобоксе Формат (актуально для CallMode = 3, где в комбобоксе
//вперемешку подгруппы всех типов - см. ControlOnChange). Чекбокс может быть вовсе не создан (режим
//просмотра/удаления - см. Prepare) - тогда просто ничего не делаем.
//
//После изменения Visible пересчитываем раскладку панели (ArrangeControlsOnPanel) - без этого место под чекбокс
//на панели не пересчитывается само по себе при смене Visible/Width (тот же нюанс, что и при первоначальной
//подгонке ширины чекбокса в Prepare, см. подробный комментарий там про CorrectFormSize).
var
  LChbOneOnly: TDBCheckBoxEh;
begin
  LChbOneOnly := TDBCheckBoxEh(FindComponent('chb_OneOnly'));
  if not Assigned(LChbOneOnly) then
    Exit;
  LChbOneOnly.Visible := FItemType <> STDITEM_TYPE_SEMIPRODUCT;
  ArrangeControlsOnPanel(pnlFrmBtnsL);
end;

procedure TFrmODedtOrStdItem.pgcFormatDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
//раскраска заголовков вкладок в зависимости от типа (произв./отгруз.) - см. FTabs[TabIndex].ItemType; отдельно -
//маркер и цвет текста, если на этой вкладке найдено совпадение по наименованию с уже существующим изделием
//(FTabs[TabIndex].DuplicateFound, см. CheckNameDuplicates) - это важнее признака активности вкладки, т.к.
//должно быть видно сразу на ВСЕХ вкладках одновременно, не переключаясь на них.
var
  LType: Integer;
  LCaption: string;
begin
  if TabIndex > High(FTabs) then
    Exit;
  LType := FTabs[TabIndex].ItemType;
  if LType = STDITEM_TYPE_PRODUCTION then
    Control.Canvas.Brush.Color := clMoneyGreen
  else
    Control.Canvas.Brush.Color := clSkyBlue;
  Control.Canvas.FillRect(Rect);
  Control.Canvas.Brush.Style := bsClear;
  //активную вкладку (без совпадения) выделяем цветом шрифта, а не жирным - жирный текст шире обычного и
  //вылезает на соседнюю вкладку (см. правку пользователя выше по TTabControl(Control).Tabs[TabIndex])
  if FTabs[TabIndex].DuplicateFound then
    Control.Canvas.Font.Color := clRed
  else if Active then
    Control.Canvas.Font.Color := clNavy
  else
    Control.Canvas.Font.Color := clWindowText;
  //подменяем ПЕРВЫЙ символ уже готового (заранее дополненного 2 пробелами, см. LoadCounterpartTabs) заголовка на
  //маркер или обратно на пробел - длина строки не меняется, поэтому ширина, реально выделенная Windows/VCL под
  //кнопку вкладки (посчитанная один раз по статической Caption при создании), не расходится с тем, что рисуем
  //здесь, и текст не вылезает за пределы вкладки при появлении/исчезновении маркера
  LCaption := TTabControl(Control).Tabs[TabIndex];
  if (Length(LCaption) > 0) then begin
    if FTabs[TabIndex].DuplicateFound then
      LCaption[1] := '●'
    else
      LCaption[1] := ' ';
  end;
  Control.Canvas.TextOut(Rect.Left + 6, Rect.Top + 3, LCaption);
end;

procedure TFrmODedtOrStdItem.pgcFormatChange(Sender: TObject);
begin
  SwitchToTab(pgcFormat.ActivePageIndex);
end;

procedure TFrmODedtOrStdItem.SwitchToTab(ANewIndex: Integer);
//переключение общих контролов (FSyncFields) на данные вкладки ANewIndex. Реальных отдельных наборов контролов
//на вкладках нет (см. общий комментарий в LoadCounterpartTabs) - вместо этого используются пользовательские
//слоты значений полей (см. uFields.pas, fvtCustom/CopyPropToCustom/SetPropsFromCustom), по одному на вкладку
//(индекс слота = индекс вкладки в FTabs). При уходе с вкладки её текущие значения запоминаются в её же слот
//(в т.ч. для вкладки 0 - как источник данных для синхронизированных вкладок). При приходе на вкладку: если
//это вкладка 0, либо на ней включена синхронизация - подставляются значения из слота 0 (то есть от первой
//вкладки); иначе - значения из собственного слота этой вкладки (последнее, что там было независимо введено).
//Наименование (edt_name) в это не входит - оно всегда одно, отдельно управляется в SetTabsControlsState.
begin
  if (ANewIndex = FActiveTab) or (ANewIndex < 0) or (ANewIndex > High(FTabs)) then
    Exit;
  F.CopyPropToCustom(FSyncFields, fvtVCurr, FActiveTab);
  FActiveTab := ANewIndex;
  if (FActiveTab = 0) or FTabs[FActiveTab].SyncChecked then
    F.SetPropsFromCustom(FSyncFields, 0, fvtVCurr, True)
  else
    F.SetPropsFromCustom(FSyncFields, FActiveTab, fvtVCurr, True);
  SetTabsControlsState;
end;

procedure TFrmODedtOrStdItem.ChbSyncClick(Sender: TObject);
//включение/выключение синхронизации на активной вкладке. chb_TabSync - общий контрол на форму (виден только
//при FActiveTab > 0 - см. SetTabsControlsState), поэтому всегда относится именно к текущей активной вкладке.
//При включении - если независимые значения полей на этой вкладке отличаются от значений первой вкладки,
//переспрашиваем перед тем как их перезаписать. Сравниваем через S.NNum, а не VarToStr - все поля FSyncFields
//числовые (price_base/wo_estimate/r0..rN, см. Prepare), S.NNum безопасно приводит и Null (в т.ч. пустое поле)
//к 0, так что отдельная проверка на "оба пустые" не нужна. VarToStr сравнивал СТРОКОВОЕ представление - одно и
//то же число в разных Variant-подтипах (Integer/Double/Currency) или с разным форматированием давало ложное
//расхождение и лишний вопрос пользователю, даже когда реальной разницы не было.
var
  LFields: TVarDynArray;
  i: Integer;
  LDiffers: Boolean;
begin
  if FActiveTab = 0 then
    Exit; //подстраховка - контрол не должен быть видим/активен на первой (своей) вкладке
  if chb_TabSync.Checked then begin
    LFields := A.ExplodeV(FSyncFields, ';');
    LDiffers := False;
    for i := 0 to High(LFields) do
      if S.NNum(F.GetProp(VarToStr(LFields[i]), fvtVCurr)) <> S.NNum(F.GetProp(VarToStr(LFields[i]), 0)) then begin
        LDiffers := True;
        Break;
      end;
    if LDiffers and (MyQuestionMessage('Значения на этой вкладке отличаются от значений первой вкладки.'#13#10'Заменить их значениями первой вкладки?') <> mrYes) then begin
      chb_TabSync.Checked := False;
      Exit;
    end;
    F.SetPropsFromCustom(FSyncFields, 0, fvtVCurr, True);
  end;
  FTabs[FActiveTab].SyncChecked := chb_TabSync.Checked;
  SetTabsControlsState;
end;

procedure TFrmODedtOrStdItem.ChbNotCreateClick(Sender: TObject);
begin
  if FActiveTab = 0 then
    Exit;
  FTabs[FActiveTab].NotCreateChecked := chb_TabNotCreate.Checked;
  if FTabs[FActiveTab].NotCreateChecked then
    FTabs[FActiveTab].SyncChecked := False; //раз изделие на этой вкладке не создаём - синхронизировать нечего
  SetTabsControlsState;
end;

procedure TFrmODedtOrStdItem.BtnCopyRouteClick(Sender: TObject);
//разовое копирование цены/маршрута с первой вкладки в текущую - независимо от состояния "Синхронизировать",
//удобно как отправная точка при независимом (несинхронизированном) заполнении
begin
  if FActiveTab = 0 then
    Exit;
  F.SetPropsFromCustom(FSyncFields, 0, fvtVCurr, True);
end;

procedure TFrmODedtOrStdItem.ChbOneOnlyClick(Sender: TObject);
//при отметке "Создать одно"/"Редактировать одно" вкладки парных изделий скрываются целиком (см. ниже) -
//синхронизация на них теряет смысл, снимаем её на всех, чтобы при повторном показе вкладок (снятии галки)
//не оставалось "зависшего" состояния синхронизации от предыдущего раза. Сам чекбокс имеет смысл только на
//первой вкладке (см. SetTabsControlsState, где он же блокируется на остальных) - но на случай программного
//вызова/старого состояния всё равно всегда явно переходим на вкладку 0.
var
  i: Integer;
begin
  FOneOnly := TDBCheckBoxEh(Sender).Checked;
  if FOneOnly then
    for i := 1 to High(FTabs) do
      FTabs[i].SyncChecked := False;
  pgcFormat.Visible := (not FOneOnly) and (pgcFormat.PageCount > 0);
  //ВАЖНО: программная установка ActivePageIndex, в отличие от переключения вкладки самим пользователем, НЕ
  //вызывает событие OnChange (pgcFormatChange) - это стандартное поведение VCL, TCustomTabControl.Change
  //вызывается только из обработки уведомления TCN_SELCHANGE, т.е. по факту действия пользователя. Поэтому
  //полагаться на pgcFormatChange -> SwitchToTab(0) здесь нельзя (раньше это иногда "срабатывало" - на самом
  //деле нет, и именно поэтому чекбоксы под разделителем не убирались, если "Создать одно" отмечали не с
  //первой вкладки) - переключаем вкладку и обновляем состояние контролов явно, кодом.
  pgcFormat.ActivePageIndex := 0;
  SwitchToTab(0); //если уже были на вкладке 0 - ничего не сделает (см. защиту в начале SwitchToTab), тогда
                   //состояние контролов всё равно обновит SetTabsControlsState ниже
  SetTabsControlsState; //гарантированно подхватывает новое значение pgcFormat.Visible (видимость bvlTabSync и
                         //т.п.) независимо от того, был ли выше реальный переход между вкладками
end;

procedure TFrmODedtOrStdItem.SetTabsControlsState;
//блокировка/разблокировка общих полей (кроме наименования - см. отдельно) в зависимости от активной вкладки:
//если это вкладка 0 или синхронизация на активной вкладке выключена - поля доступны на обычных условиях
//(с учетом права на изменение цены и правил маршрута - см. SetRoute); если синхронизация включена - поля
//заблокированы (они зеркалят первую вкладку, см. SwitchToTab).
//
//Также здесь же управляем видимостью и состоянием общих (не по одному на вкладку) контролов синхронизации
//bvlTabSync/chb_TabSync/chb_TabNotCreate/btn_TabCopyRoute (под pgcFormat, см. .dfm) - показываем их только
//когда вообще есть парные вкладки (pgcFormat.Visible) и активна не первая, "своя" вкладка.
var
  i: Integer;
  LLocked: Boolean;
  LCtrls: array of TControl;
  LChbOneOnly: TDBCheckBoxEh;
begin
  edt_name.ReadOnly := (FActiveTab <> 0) or (Mode in [fView, fDelete]);
  //ReadOnly сам по себе фон не перекрашивает (см. также ниже про nedt_price_base/edt_prefix/формат) - явно
  //красим/возвращаем фон в зависимости от активной вкладки, как и для остальных заблокированных полей, иначе
  //наименование выглядит редактируемым (белый фон), даже когда фактически заблокировано
  if edt_name.ReadOnly then
    Cth.SetEhControlColor(edt_name, clmyDisabled)
  else
    Cth.SetEhControlColor(edt_name, clWindow);

  //Префикс (edt_prefix) - чисто информационное поле (выводится по выбранному Формату, см. SetPrefixByFormat),
  //неизменяемо НИКОГДА, ни на какой вкладке, ни в каком режиме - оно и в .dfm по умолчанию ReadOnly = True.
  //Раньше здесь (в ветке "не заблокировано") ошибочно возвращалось ReadOnly := False вместе с остальными полями -
  //из-за этого поле становилось редактируемым на первой вкладке/при отключенной синхронизации. Выставляем
  //постоянно, безусловно, вне веток LLocked ниже - так проще не забыть и не завязывать на состояние синхронизации.
  edt_prefix.ReadOnly := True;
  Cth.SetEhControlColor(edt_prefix, clmyDisabled);

  //чекбокс "Создать одно"/"Редактировать одно" имеет смысл только на первой ("своей") вкладке - именно по ней
  //решается, создаём мы новое изделие или нет; на остальных вкладках блокируем его, чтобы не провоцировать
  //повторное переключение на вкладку 0 не глядя и не путать с блокировкой полей самой вкладки. Чекбокс создаётся
  //не всегда (см. Prepare - для полуфабрикатов и в режиме просмотра/удаления его нет вовсе), поэтому по имени.
  LChbOneOnly := TDBCheckBoxEh(FindComponent('chb_OneOnly'));
  if Assigned(LChbOneOnly) then
    LChbOneOnly.Enabled := (FActiveTab = 0);

  LLocked := (FActiveTab > 0) and FTabs[FActiveTab].SyncChecked;
  if LLocked then begin
    //SetControlsEditable вместо прямой установки ReadOnly/Enabled - помимо блокировки, дополнительно красит
    //фон полей серым (см. SetControlsEditable -> Cth.SetControlNotEditable(..., Greyed=True) -> clmyDisabled) -
    //так виднее, что поля именно временно заблокированы синхронизацией с первой вкладкой, а не недоступны вовсе.
    //Формат (cmb_id_or_format_estimates) раньше сюда не входил и оставался доступен для редактирования на любой
    //вкладке независимо от синхронизации - тоже блокируем его здесь. Префикс (edt_prefix) сюда не входит - он
    //заблокирован всегда и безусловно, см. отдельно в начале процедуры.
    SetLength(LCtrls, 4);
    LCtrls[0] := nedt_price_base;
    LCtrls[1] := chb_R0;
    LCtrls[2] := chb_Wo_Estimate;
    LCtrls[3] := cmb_id_or_format_estimates;
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].Name, 1, 5) = 'chb_r' then begin
        SetLength(LCtrls, Length(LCtrls) + 1);
        LCtrls[High(LCtrls)] := TControl(Components[i]);
      end;
    SetControlsEditable(LCtrls, False);
  end
  else begin
    //разрешаем менять цену, если есть право User.Role(rOr_R_StdItems_Set_Prices) (иначе только просмотр)
    nedt_price_base.ReadOnly := (Mode = fEdit) and not User.Role(rOr_R_StdItems_Set_Prices);
    //ReadOnly сам по себе фон не перекрашивает - если до этого вкладка была заблокирована синхронизацией
    //(см. блок LLocked выше, SetControlsEditable закрашивает фон серым), явно возвращаем обычный белый фон,
    //иначе поле визуально выглядит заблокированным, даже когда оно уже редактируемо
    Cth.SetEhControlColor(nedt_price_base, clWindow);
    chb_R0.Enabled := True;
    chb_Wo_Estimate.Enabled := True;
    //возвращаем Формат к его обычному (не зависящему от вкладки) состоянию - см. то же поле в Prepare.
    //Префикс сюда не входит - он заблокирован всегда и безусловно, см. отдельно в начале процедуры.
    cmb_id_or_format_estimates.Enabled := Mode in [fAdd, fCopy];
    Cth.SetEhControlColor(cmb_id_or_format_estimates, clWindow);
    SetRoute; //своими правилами восстановит доступность строк маршрута (r0/без сметы)
  end;

  //до первого автовыравнивания формы (FTabsVisReady = False, взводится в AfterFormActivate) НЕ трогаем
  //видимость этих контролов - см. подробный комментарий у поля FTabsVisReady в interface-секции: пусть
  //остаются видимыми по умолчанию (как в .dfm), чтобы CorrectFormSize/Cth.AlignControls зарезервировали под
  //них место. Единственное исключение - вкладок вообще нет (PageCount = 0): тогда скрыть их можно сразу,
  //это никак не связано с переключением между вкладками и на авторасчет высоты не влияет по-другому.
  if FTabsVisReady or (pgcFormat.PageCount = 0) then begin
    bvlTabSync.Visible := pgcFormat.Visible;
    chb_TabSync.Visible := pgcFormat.Visible and (FActiveTab > 0);
    chb_TabNotCreate.Visible := pgcFormat.Visible and (FActiveTab > 0);
    btn_TabCopyRoute.Visible := pgcFormat.Visible and (FActiveTab > 0);
  end;
  if FActiveTab > 0 then begin
    chb_TabSync.Checked := FTabs[FActiveTab].SyncChecked;
    chb_TabNotCreate.Checked := FTabs[FActiveTab].NotCreateChecked;
    chb_TabSync.Enabled := not FTabs[FActiveTab].NotCreateChecked;
  end;
end;

procedure TFrmODedtOrStdItem.AfterFormActivate;
//вызывается из TFrmBasicMdi.FormActivate, т.е. гарантированно ПОСЛЕ FormShow/CorrectFormSize (см. подробности
//там же и у поля FTabsVisReady) - здесь впервые разрешаем SetTabsControlsState реально скрыть
//bvlTabSync/chb_TabSync/chb_TabNotCreate/btn_TabCopyRoute, если активна вкладка 0 (обычный случай при
//первом открытии формы).
begin
  inherited;
  FTabsVisReady := True;
  SetTabsControlsState;
end;

function TFrmODedtOrStdItem.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//проверим здесь моменты:
//если не задан маршрут, когда он должен быть
//если цена перепродажи больше общей
//если наименование совпадает с уже существующим изделием на какой-либо из вкладок (см. CheckNameDuplicates)
var
  i, j: Integer;
begin
  Result := False;
  CheckNameDuplicates;
  j := 0;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 6) = 'chb_r') and (TDBCheckBoxEh(Components[i]).Checked) then
      j := j + 1;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 6) = 'chb_r') then
      Cth.SetErrorMarker(TDBCheckBoxEh(Components[i]), TDBCheckBoxEh(Components[i]).Enabled and (j = 0));
  //цена перепродажи не должна быть больше общей цены
//  Cth.SetErrorMarker(nedt_Price_PP, (nedt_Price_PP.Value > nedt_Price.Value) or (nedt_Price_PP.Value = null));
end;

function TFrmODedtOrStdItem.Save: Boolean;
//запись результатов в бд
//при изменении значения чекбокса Без сметы в режиме редактирования нам надо подправить смету после записи основной таблицы
//(если галка была снята, то загрузить пустую смету, если же галка поставлена, то смету просто удалить - будет требовать ввода в дальнешем)
//запись результатов в бд
//при изменении значения чекбокса Без сметы в режиме редактирования нам надо подправить смету после записи основной таблицы
//(если галка была снята, то загрузить пустую смету, если же галка поставлена, то смету просто удалить - будет требовать ввода в дальнешем)
var
  name, nameold, prefix, fields: string;
  i: Integer;
  Res: Integer;
begin
  Q.QBeginTrans(True);
  //сохраним основные данные
  Result := inherited;
  if not Result then begin
    Q.QRollbackTrans;
    Exit;
  end;
  if (Mode = fEdit) and (edt_name.Text <> FNameOld) then begin
    //если это редактирование и наименование изменилось - попробуем изменить его и в БД ИТМ (с учетом префикса)
    //получим префикс изедия
    prefix := '';
    if FIdEstimateGroup > 0 then
      prefix := Q.QLoadValue('select prefix from or_format_estimates where id = :id$i', [FIdEstimateGroup]);
    //старое и новое имя
    name := S.IIFStr(prefix <> '', prefix + '_', '') + Trim(edt_name.Text);
    nameold := S.IIFStr(prefix <> '', prefix + '_', '') + FNameOld;
    //проверим, есть ли уже в итм в продукции запись соответствующая новому имени
    Res := Q.QLoadValue('select count(1) from dv.nomenclatura where id_group = :ig_group$i and name = :name$s', [ItmGroups_Production_ID, name]);
    if Res = 0 then begin
      //если нет, то переименуем запись со старым именем в новое (если она естественно есть)
      Q.QExecSql('update dv.nomenclatura set name = :name$s, fullname = :fullname$s where id_group = :ig_group$i and name = :nameold$s', [name, name, ItmGroups_Production_ID, nameold]);
    end;
  end;
  if (Mode = fEdit) and (Cth.GetControlValue(chb_Wo_Estimate) <> FWoEstimateOld) then begin
    //если изменился признак "Без сметы", то удаляем смету
    //(в проверке перед записью спросит, если при этом была подгружена непустая смета)
    Orders.RemoveEstimateForStdItem(id, True);
  end;
  if (Mode = fEdit) then begin
    //утсановим в шаблонах цену и маршрут изделий, соответствующих данному
    var FieldsArr: TVarDynArray := ['price_base$f', 'r0$i'];
    for i := 0 to High(RouteFields) do
      FieldsArr := FieldsArr + ['r' + IntToStr(i + 1)];
    var FiealdsVal: TVarDynArray := [];
    for i := 0 to High(FieldsArr) do
      FiealdsVal := FiealdsVal + [F.GetProp(FieldsArr[i].AsString)];
    Q.QExecSql(Q.QGetSql('Q', 'order_items', FieldsArr.Implode(';')) + ' where id_order < 0 and id_order > -100000 and id_std_item = :id_std_item$i', FiealdsVal + [ID]);
  end;
  Result := Q.QCommitTrans;
end;


procedure TFrmODedtOrStdItem.VerifyBeforeSave;
var
  i, res1, res2, res3: Integer;
  NewEmptyEstimate: Boolean;
begin
  //проверки при редактировании или добавлении записи (только если изменилорсь наименование)
  //проверим, нет ли такого наименования среди стандартных изделий того же типа паспорта
  //также наименование с преиксом не должно быть в базе сметных наименований учета    //!!!
  //и также и в базе итм с типом "материалы и комплектующие"
  if (Mode <> fDelete) and (FIdEstimateGroup > 1) and (edt_name.Text <> FNameOld) then begin
    res1 := Q.QLoadValue('select count(1) from or_std_items where id <> :id$i and (id_or_format_estimates = :idf$i) and name = :name$s', [ID, FIdEstimateGroup, edt_name.Text]);
    //res2 := Q.QSelectOneRow('select count(1) from bcad_nomencl where name = :name$s', [Prefix + '_' + edt_name.Text])[0];
    res3 := Q.QLoadValue('select count(1) from dv.nomenclatura where id_nomencltype = 0 and name = :name$s', [FPrefix + '_' + edt_name.Text]);
    if res1 + res2 + res3 > 0 then begin
      MyWarningMessage(S.IIf(res1 > 0, 'Такое наименование уже существует в этой группе стандартных изделий Учета!'#13#10, '') +
          //S.IIf(res2 > 0, 'Такое наименование (с учетом префикса) уже существует в справочнике сметных позиций Учета!'#13#10, '') +
        S.IIf(res3 > 0, 'Такое наименование (с учетом префикса) уже есть в ИТМ среди номенклатуры типа "материалы и комплектующие"!'#13#10, '') + #13#10'Данные не могут быть сохранены!');
      HasError := True;
      Exit;
    end;
  end;
  if (Mode = fEdit) and (chb_Wo_Estimate.Checked) then begin
    NewEmptyEstimate := Q.QLoadValue('select count(1) from estimates where id_std_item = :id$i and isempty = 0', [id]) > 0;
    if NewEmptyEstimate then
      if MyQuestionMessage('Для этого изделия выбран тип "без сметы", но сейчас к нему уже подгружена непустая смета.'#13#10'Она будет удалена.'#13#10'Продолжить?') <> mrYes then begin
        HasError := True;
        Exit;
      end;
  end;
end;

procedure TFrmODedtOrStdItem.SetRoute;
var
  i: Integer;
begin
  if Mode in [fDelete, fView] then
    Exit;
  if (Cth.GetControlValue(chb_Wo_Estimate) = 1) or (Cth.GetControlValue(chb_R0) = 1) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].name, 1, 5) = 'chb_r' then begin
        TDBCheckBoxEh(Components[i]).Checked := False;
        TDBCheckBoxEh(Components[i]).Enabled := False;
      end;
  if (Cth.GetControlValue(chb_Wo_Estimate) = 0) and (Cth.GetControlValue(chb_R0) = 0) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].name, 1, 5) = 'chb_r' then begin
        TDBCheckBoxEh(Components[i]).Enabled := True;
      end;
  FIsRouteChanged := True;
end;

end.


