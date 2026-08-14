{
Просмотр истории изменений (estimate_change_log) КОНКРЕТНОЙ сметы - к стандартному изделию либо к
позиции (изделию) заказа. По входным параметрам (ID/AddParam) и логике их разбора полностью
повторяет диалог редактирования сметы (см. uFrmOGedtEstimate.TFrmOGedtEstimate.PrepareForm) -
AddParam = 1 - стандартное изделие, ID = его айди; иначе - позиция заказа, ID = айди order_items.

Открывается через Wh.ExecDialog(myfrm_Rep_EstimateChanges, ..., fView, AId, AAddParam) - см. пункты
меню (без кнопки, см. отрицательный тег в SetButtons) в справочнике стандартных изделий
(uFrmOGrefOrStdItems.pas, Frg1) и в журнале заказов (uFrmOGjrnOrders.pas, Frg2 - позиции заказа;
на уровне самого заказа (Frg1) пункт не добавлен - у заказа может быть несколько позиций/смет,
однозначного соответствия позиция->смета на уровне заказа в целом нет).

Вверху - заголовок сметы (как в диалоге сметы) и инфа по текущему шагу истории (когда, кем и через
какой канал/каналы внесено изменение - source, см. estimate_change_log.source в d_estimates.sql,
хранится как список кодов через запятую, расшифровка кодов в текст - см. SourceCodesToText).
Внизу - текст изменений (estimate_change_log.changes).
Навигация по истории - кнопки "Назад"/"Вперед" на стандартной панели кнопок (DlgButtonsR); при
открытии сразу показывается последняя (самая свежая) запись истории.
}
unit uFrmOWrepEstimateChanges;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  DBCtrlsEh, uData, Vcl.Mask, uString, uLabelColors;

type
  TFrmOWrepEstimateChanges = class(TFrmBasicMdi)
    pnlTop: TPanel;
    lblCapt1: TLabel;
    lblCapt2: TLabel;
    lblDateTime: TLabel;
    lblUser: TLabel;
    lblSource: TLabel;
    lblStep: TLabel;
    mmoChanges: TDBMemoEh;
  private
    { Private declarations }
    FRows: TVarDynArray2;  //строки v_estimate_change_log по текущей смете (dt;username;source;changes), по возрастанию id
    FStep: Integer;        //индекс текущей записи истории в FRows
    function  Prepare: Boolean; override;
    procedure AfterStart; override;
    procedure btnClick(Sender: TObject); override;
    //перевод списка кодов источника (через запятую) в читаемый текст, см. общий комментарий в начале модуля
    function  SourceCodesToText(const ASource: string): string;
    //отобразить запись истории с индексом AStep (без изменений, если индекс вне границ FRows)
    procedure LoadStep(AStep: Integer);
    //включить/выключить кнопки Назад/Вперед по текущему FStep - актуальные компоненты кнопок появляются
    //только после Prepare (см. TFrmBasicMdi.RefreshDlgPanel, вызывается из FormShow), поэтому дополнительно
    //вызывается из AfterStart; вызов до появления кнопок безопасен (просто ничего не делает)
    procedure SetNavButtonsEnabled;
  public
    { Public declarations }
  end;

var
  FrmOWrepEstimateChanges: TFrmOWrepEstimateChanges;

implementation

{$R *.dfm}

uses
  uSettings,
  uForms,
  uDBOra,
  uMessages
  ;

function TFrmOWrepEstimateChanges.SourceCodesToText(const ASource: string): string;
const
  cCodes: array[0..4] of string = ('0', '1', '2', '3', '4');
  cNames: array[0..4] of string = (
    'первичная загрузка сметы (создание)',
    'загрузка из xls-файла',
    'копирование из буфера',
    'ручное редактирование',
    'обновление из сметы стандартного изделия'
  );
var
  va: TVarDynArray;
  i, k, j: Integer;
  st: string;
begin
  Result := '';
  if Trim(ASource) = '' then
    Exit('не определен');
  va := A.ExplodeV(ASource, ',');
  for i := 0 to High(va) do begin
    st := Trim(VarToStr(va[i]));
    if st = '' then
      Continue;
    j := -1;
    for k := 0 to High(cCodes) do
      if cCodes[k] = st then begin
        j := k;
        Break;
      end;
    S.ConcatStP(Result, S.IIfStr(j >= 0, cNames[j], 'код ' + st), ', ');
  end;
end;

procedure TFrmOWrepEstimateChanges.LoadStep(AStep: Integer);
begin
  if (AStep < 0) or (AStep > High(FRows)) then
    Exit;
  FStep := AStep;
  lblDateTime.SetCaption2('Дата/время изменения: $FF0000' + S.IIfStr(FRows[FStep][0] = null, '', DateTimeToStr(VarToDateTime(FRows[FStep][0]))));
  lblUser.SetCaption2('Пользователь:  $FF0000' + VarToStr(FRows[FStep][1]));
  lblSource.SetCaption2('Источник: $FF0000' + SourceCodesToText(VarToStr(FRows[FStep][2])));
  lblStep.SetCaption2('Запись  $FF0000' + IntToStr(FStep + 1) + ' $000000 из  $FF0000' + IntToStr(Length(FRows)));
  mmoChanges.Lines.Text := VarToStr(FRows[FStep][3]);
  SetNavButtonsEnabled;
end;

procedure TFrmOWrepEstimateChanges.SetNavButtonsEnabled;
var
  i: Integer;
begin
  for i := 0 to pnlFrmBtnsR.ControlCount - 1 do begin
    if TControl(pnlFrmBtnsR.Controls[i]).Tag = mbtPrev then
      TControl(pnlFrmBtnsR.Controls[i]).Enabled := FStep > 0
    else if TControl(pnlFrmBtnsR.Controls[i]).Tag = mbtNext then
      TControl(pnlFrmBtnsR.Controls[i]).Enabled := FStep < High(FRows);
  end;
end;

procedure TFrmOWrepEstimateChanges.btnClick(Sender: TObject);
begin
  if not (Sender is TControl) then
    Exit;
  if TControl(Sender).Tag = mbtPrev then
    LoadStep(FStep - 1)
  else if TControl(Sender).Tag = mbtNext then
    LoadStep(FStep + 1);
end;

procedure TFrmOWrepEstimateChanges.AfterStart;
begin
  inherited;
  SetNavButtonsEnabled;
end;

function TFrmOWrepEstimateChanges.Prepare: Boolean;
//см. общий комментарий в начале модуля - разбор ID/AddParam полностью повторяет
//TFrmOGedtEstimate.PrepareForm (тот же смысл AddParam = 1/стандартное изделие, иначе - позиция заказа)
var
  va: TVarDynArray;
  IdEstimate: Variant;
  LName, LTypeOfItem, LFormatCaption: string;
begin
  Result := False;
  Caption := 'История изменений сметы';
  BorderStyle := bsSizeable;
  if not inherited then
    Exit;

  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.DlgButtonsR := [
    [mbtPrev, True, True, 1, 'Назад'],
    [mbtNext, True, True, 1, 'Вперед']
  ];

  mmoChanges.ReadOnly := True;
  mmoChanges.ScrollBars := ssVertical;

  if AddParam = 1 then begin
    //стандартное изделие - ID это его айди (как и у диалога сметы)
    IdEstimate := Q.QLoadValue('select id from estimates where id_std_item = :id$i', [ID]);
    LName := Q.QLoadValue('select name from v_or_std_items where id = :id$i', [ID]);
    LTypeOfItem := Q.QLoadValue('select type_name from v_or_std_items where id = :id$i', [ID]);
    LFormatCaption := Q.QLoadValue('select or_format_name || '' / '' || or_format_estimate_name || '' ['' || prefix || '']'' from v_or_std_items where id = :id$i', [ID]);
    lblCapt1.SetCaption2('История изменений сметы к ' +
      S.Decode([LTypeOfItem, 'О', 'отгрузочному стандартному изделию', 'П', 'производственному стандартному изделию', 'ПФ', 'полуфабрикату', 'стандартному изделию']) +
      '  $FF0000' + LFormatCaption + ':');
  end
  else begin
    //позиция (изделие) заказа - ID это айди order_items
    IdEstimate := Q.QLoadValue('select id from estimates where id_order_item = :id$i', [ID]);
    va := Q.QLoadRow('select slash || '' '' || name from v_order_items where id = :id$i', [ID]);
    LName := va[0];
    lblCapt1.Caption := 'История изменений сметы к изделию заказа:';
  end;
  lblCapt2.SetCaption2('$FF0000' + LName);

  FRows := [];
  if IdEstimate <> null then
    FRows := Q.QLoad('select dt, username, source, changes from v_estimate_change_log where id_estimate = :id_estimate$i order by id', [IdEstimate]);

  if Length(FRows) = 0 then begin
    lblDateTime.Caption := '';
    lblUser.Caption := '';
    lblSource.Caption := '';
    lblStep.Caption := 'История изменений отсутствует';
    mmoChanges.Lines.Text := '';
    FStep := -1;
    SetNavButtonsEnabled;
  end
  else
    //сразу покажем последнюю (самую свежую) запись
    LoadStep(High(FRows));

  Result := True;
end;

end.
