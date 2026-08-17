{
история изменений заказа (по переданному в ExecDialog id заказа)
вверху - инфа по текущему шагу истории (номер заказа+проект, дата/время события, пользователь, статус заказа
"было -> стало")
внизу - два поля TDBMemoEh (изменения шапки заказа / изменения позиций заказа), с перетаскиваемой границей между ними
навигация по истории - кнопки "Назад"/"Вперед" на стандартной панели кнопок (DlgButtonsR); там же кнопка
переключения краткий/полный вариант текста изменений (см. FShowFull)

данные читаются из order_changes/v_order_changes (см. SQL/d_orders.sql, TFrmOWOrder.FixOrderChanges/SaveOrderChanges
в uFrmOWOrder.pas). Кроме сохраненной в бд истории, форма умеет показывать "текущие" (еще не сохраненные) изменения
активной сессии редактирования заказа - для этого при открытии из диалога заказа (uFrmOWOrder.pas, кнопка
"Просмотреть историю изменений") в ExecDialog передается AddParam - variant-массив вида:
  [True, <id_status до>, <id_status после>, <шапка кратко>, <шапка полностью>, <позиции кратко>, <позиции полностью>]
(см. TFrmOWOrder.FixOrderChanges - вызывается непосредственно перед открытием, чтобы данные были актуальными).
Если форма открыта не из диалога заказа (например, из журнала заказов) - AddParam не передается (Null), и
показывается только сохраненная в бд история, без "текущих" изменений. "текущие" изменения, если переданы,
показываются отдельным (самым свежим) шагом истории, после всех сохраненных в бд записей.
}

unit uFrmOWRepOrderChanges;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  DBCtrlsEh, uData, Vcl.Mask, uString, uLabelColors;

type
  TFrmOWRepOrderChanges = class(TFrmBasicMdi)
    pnlTop: TPanel;
    lblOrder: TLabel;
    lblDateTime: TLabel;
    lblUser: TLabel;
    lblOperation: TLabel;
    mmoTitle: TDBMemoEh;
    Splitter1: TSplitter;
    mmoItems: TDBMemoEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    //строки v_order_changes по текущему заказу (dt;username;id_status_before;id_status_after;title_changes_short;
    //title_changes_full;items_changes_short;items_changes_full), по возрастанию dt
    FRows: TVarDynArray2;
    //переданы ли "текущие" (несохраненные) изменения через AddParam - см. комментарий в шапке модуля
    FHasCurrent: Boolean;
    //данные "текущего" шага: [id_status_before, id_status_after, title_short, title_full, items_short, items_full]
    FCurrentRow: TVarDynArray;
    //индекс текущего шага истории; Length(FRows) - это "текущие" изменения (если FHasCurrent)
    FStep: Integer;
    //показывать полный вариант текста изменений (иначе - краткий); переключается кнопкой на панели
    FShowFull: Boolean;
    function Prepare: Boolean; override;
    procedure btnClick(Sender: TObject); override;
    //загрузка общей инфы о шаге истории (дата/время, пользователь, статус "было -> стало") в лейблы верхней панели
    procedure LoadOrderGeneralChanges(AStep: Integer);
    //загрузка изменений шапки заказа в поле mmoTitle (кратко/полно - см. FShowFull)
    procedure LoadOrderTitleChanges(AStep: Integer);
    //загрузка изменений позиций заказа в поле mmoItems (кратко/полно - см. FShowFull)
    procedure LoadOrderItemsChanges(AStep: Integer);
    //признак, что шаг AStep - это "текущие" (несохраненные) изменения, переданные через AddParam, а не запись из бд
    function  IsCurrentStep(AStep: Integer): Boolean;
    //текст статуса по id_status; упрощенно, без учета статусов ИТМ (см. полную логику статуса в v_orders/d_orders.sql) -
    //для истории изменений точность до статусов ИТМ не требуется
    function  StatusCaption(AIdStatus: Variant): string;
    //включить/выключить кнопки Назад/Вперед, обновить подпись кнопки переключения кратко/полно
    procedure SetNavButtonsState;
  public
    { Public declarations }
  end;

var
  FrmOWRepOrderChanges: TFrmOWRepOrderChanges;

implementation

{$R *.dfm}

uses
  uSettings,
  uForms,
  uDBOra,
  uMessages
  ;

const
  mbtOrderChangesToggleFull = 1002;

function TFrmOWRepOrderChanges.StatusCaption(AIdStatus: Variant): string;
begin
  Result := S.Decode([AIdStatus,
    -2, 'удален',
    -1, 'остановлен',
    0, 'на оформлении',
    1, 'проведен',
    2, 'запущен в работу',
    3, 'выполняется',
    'статус ' + S.NSt(AIdStatus)
  ]);
end;

function TFrmOWRepOrderChanges.IsCurrentStep(AStep: Integer): Boolean;
begin
  Result := FHasCurrent and (AStep = Length(FRows));
end;

procedure TFrmOWRepOrderChanges.LoadOrderGeneralChanges(AStep: Integer);
//загрузка общей инфы о шаге истории (дата/время, пользователь, статус "было -> стало") в лейблы верхней панели
var
  LDt, LUser, LIdStatusBefore, LIdStatusAfter: Variant;
  LTotal: Integer;
begin
  LTotal := Length(FRows) + Ord(FHasCurrent);
  if (LTotal = 0) or (AStep < 0) or (AStep >= LTotal) then begin
    lblDateTime.Caption := '';
    lblUser.Caption := '';
    lblOperation.SetCaption2('История изменений отсутствует');
    SetNavButtonsState;
    Exit;
  end;
  if IsCurrentStep(AStep) then begin
    LUser := User.GetName;
    LIdStatusBefore := FCurrentRow[0];
    LIdStatusAfter := FCurrentRow[1];
  end
  else begin
    LDt := FRows[AStep][0];
    LUser := FRows[AStep][1];
    LIdStatusBefore := FRows[AStep][2];
    LIdStatusAfter := FRows[AStep][3];
  end;
  lblDateTime.SetCaption2('Дата/время изменения: $FF0000' + S.IIfStr(IsCurrentStep(AStep), 'текущие несохраненные изменения', DateTimeToStr(VarToDateTime(LDt))));
  lblUser.SetCaption2('Пользователь: $FF0000' + VarToStr(LUser));
  if VarToStr(LIdStatusBefore) = VarToStr(LIdStatusAfter) then
    lblOperation.SetCaption2('Статус заказа: $FF0000' + StatusCaption(LIdStatusAfter))
  else
    lblOperation.SetCaption2('Статус заказа: $FF0000' + StatusCaption(LIdStatusBefore) + ' $000000-> $FF0000' + StatusCaption(LIdStatusAfter));
  SetNavButtonsState;
end;

procedure TFrmOWRepOrderChanges.LoadOrderTitleChanges(AStep: Integer);
//загрузка изменений шапки заказа в поле mmoTitle
var
  LShort, LFull: Variant;
begin
  LShort := '';
  LFull := '';
  if IsCurrentStep(AStep) then begin
    LShort := FCurrentRow[2];
    LFull := FCurrentRow[3];
  end
  else if (AStep >= 0) and (AStep <= High(FRows)) then begin
    LShort := FRows[AStep][4];
    LFull := FRows[AStep][5];
  end;
  mmoTitle.Lines.Text := VarToStr(S.IIfV(FShowFull, LFull, LShort));
end;

procedure TFrmOWRepOrderChanges.LoadOrderItemsChanges(AStep: Integer);
//загрузка изменений позиций заказа в поле mmoItems
var
  LShort, LFull: Variant;
begin
  LShort := '';
  LFull := '';
  if IsCurrentStep(AStep) then begin
    LShort := FCurrentRow[4];
    LFull := FCurrentRow[5];
  end
  else if (AStep >= 0) and (AStep <= High(FRows)) then begin
    LShort := FRows[AStep][6];
    LFull := FRows[AStep][7];
  end;
  mmoItems.Lines.Text := VarToStr(S.IIfV(FShowFull, LFull, LShort));
end;

procedure TFrmOWRepOrderChanges.SetNavButtonsState;
//включить/выключить кнопки Назад/Вперед по текущему FStep, обновить подпись кнопки кратко/полно;
//актуальные компоненты кнопок появляются только после Prepare, вызов до их появления безопасен (ничего не делает)
var
  i, LTotal: Integer;
begin
  LTotal := Length(FRows) + Ord(FHasCurrent);
  for i := 0 to pnlFrmBtnsR.ControlCount - 1 do begin
    if TControl(pnlFrmBtnsR.Controls[i]).Tag = mbtPrev then
      TControl(pnlFrmBtnsR.Controls[i]).Enabled := FStep > 0
    else if TControl(pnlFrmBtnsR.Controls[i]).Tag = mbtNext then
      TControl(pnlFrmBtnsR.Controls[i]).Enabled := FStep < LTotal - 1
    else if TControl(pnlFrmBtnsR.Controls[i]).Tag = mbtOrderChangesToggleFull then
      TButton(pnlFrmBtnsR.Controls[i]).Caption := S.IIfStr(FShowFull, 'Показать кратко', 'Показать полностью');
  end;
end;

procedure TFrmOWRepOrderChanges.btnClick(Sender: TObject);
//кнопки "Назад"/"Вперед"/"Показать кратко|полностью" стандартной панели кнопок (DlgButtonsR)
var
  LTotal: Integer;
begin
  if not (Sender is TControl) then
    Exit;
  LTotal := Length(FRows) + Ord(FHasCurrent);
  if TControl(Sender).Tag = mbtPrev then begin
    if FStep > 0 then
      Dec(FStep);
  end
  else if TControl(Sender).Tag = mbtNext then begin
    if FStep < LTotal - 1 then
      Inc(FStep);
  end
  else if TControl(Sender).Tag = mbtOrderChangesToggleFull then
    FShowFull := not FShowFull
  else
    Exit;
  LoadOrderGeneralChanges(FStep);
  LoadOrderTitleChanges(FStep);
  LoadOrderItemsChanges(FStep);
end;

procedure TFrmOWRepOrderChanges.FormClose(Sender: TObject; var Action: TCloseAction);
//сохраним позицию окна
begin
  inherited;
  Settings.SaveWindowPos(Self, FormDoc);
end;


function TFrmOWRepOrderChanges.Prepare: Boolean;
//начальная подготовка формы - панель кнопок Назад/Вперед/Кратко-Полностью, минимальная настройка полей
//mmoTitle/mmoItems, разбор AddParam (см. комментарий в шапке модуля), первая загрузка данных
var
  LAdd: Variant;
begin
  Result := False;
  Caption := '~История изменения заказа';
  BorderStyle := bsSizeable;
  FShowFull := True;
  if not inherited then
    Exit;

  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.DlgButtonsR := [
    [mbtPrev, True, True, 120, 'Назад'],
    [mbtNext, True, True, 120, 'Вперед'],
    [mbtOrderChangesToggleFull, True, True, 160, 'Показать полностью']
  ];

  mmoTitle.ReadOnly := True;
  mmoTitle.ScrollBars := ssVertical;
  mmoItems.ReadOnly := True;
  mmoItems.ScrollBars := ssVertical;

  lblOrder.SetCaption2('$FF0000' + VarToStr(Q.QLoadValue('select ornum || '' / '' || project from orders where id = :id$i', [ID])));

  FRows := Q.QLoad('select dt, username, id_status_before, id_status_after, title_changes_short, title_changes_full, items_changes_short, items_changes_full from v_order_changes where id_order = :id_order$i order by dt', [ID]);

  LAdd := AddParam;
  FHasCurrent := VarIsArray(LAdd) and (VarArrayHighBound(LAdd, 1) >= 6) and Boolean(LAdd[0]);
  if FHasCurrent then
    FCurrentRow := [LAdd[1], LAdd[2], LAdd[3], LAdd[4], LAdd[5], LAdd[6]];

  FShowFull := False;
  FStep := Length(FRows) + Ord(FHasCurrent) - 1; //последний шаг - "текущие", если есть, иначе последняя запись из бд
  LoadOrderGeneralChanges(FStep);
  LoadOrderTitleChanges(FStep);
  LoadOrderItemsChanges(FStep);

  Result := True;
end;


end.
