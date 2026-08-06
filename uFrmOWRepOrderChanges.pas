{
история изменений заказа (по переданному в ExecDialog id заказа)
вверху - инфа по текущему шагу истории (номер заказа+проект, дата/время события, пользователь, операция)
внизу - два грида (изменения шапки заказа / изменения позиций заказа), с перетаскиваемой границей между ними
навигация по истории - кнопки "Назад"/"Вперед" на стандартной панели кнопок (DlgButtonsR)

загрузка данных (LoadOrderGeneralChanges/LoadOrderTitleChanges/LoadOrderItemsChanges) - реализуется отдельно
}

unit uFrmOWRepOrderChanges;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  uFrDBGridEh, uData;

type
  TFrmOWRepOrderChanges = class(TFrmBasicMdi)
    pnlTop: TPanel;
    lblOrder: TLabel;
    lblDateTime: TLabel;
    lblUser: TLabel;
    lblOperation: TLabel;
    FrgTitle: TFrDBGridEh;
    Splitter1: TSplitter;
    FrgItems: TFrDBGridEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FStep: Integer;   // текущий шаг (индекс события) истории изменений заказа
    function Prepare: Boolean; override;
    procedure btnClick(Sender: TObject); override;
    //загрузка общей инфы о шаге истории (номер заказа+проект, дата/время, пользователь, операция) в лейблы верхней панели
    //реализация - отдельно
    procedure LoadOrderGeneralChanges(AStep: Integer);
    //загрузка изменений шапки заказа для грида FrgTitle
    //реализация - отдельно (Opt.SetFields/SetInitData/Prepare/RefreshGrid)
    procedure LoadOrderTitleChanges(AStep: Integer);
    //загрузка изменений позиций заказа для грида FrgItems
    //реализация - отдельно (Opt.SetFields/SetInitData/Prepare/RefreshGrid)
    procedure LoadOrderItemsChanges(AStep: Integer);
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
  uString,
  uMessages
  ;


procedure TFrmOWRepOrderChanges.LoadOrderGeneralChanges(AStep: Integer);
//загрузка общей инфы о шаге истории (номер заказа+проект, дата/время, пользователь, операция) в лейблы верхней панели
begin
  //реализация - отдельно
end;

procedure TFrmOWRepOrderChanges.LoadOrderTitleChanges(AStep: Integer);
//загрузка изменений шапки заказа для грида FrgTitle
begin
  //реализация - отдельно (Opt.SetFields/SetInitData/Prepare/RefreshGrid)
end;

procedure TFrmOWRepOrderChanges.LoadOrderItemsChanges(AStep: Integer);
//загрузка изменений позиций заказа для грида FrgItems
begin
  //реализация - отдельно (Opt.SetFields/SetInitData/Prepare/RefreshGrid)
end;

procedure TFrmOWRepOrderChanges.btnClick(Sender: TObject);
//кнопки "Назад"/"Вперед" стандартной панели кнопок (DlgButtonsR) - сдвигают FStep и обновляют данные
begin
  if not (Sender is TControl) then
    Exit;
  if TControl(Sender).Tag = mbtPrev then
    Dec(FStep)
  else if TControl(Sender).Tag = mbtNext then
    Inc(FStep)
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
//начальная подготовка формы - панель кнопок Назад/Вперед, минимальная настройка гридов, первая загрузка данных (FStep = 0)
begin
  Result := False;
  Caption := '~История заказа';
  BorderStyle := bsSizeable;
  if not inherited then
    Exit;

  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.DlgButtonsR := [
    [mbtPrev, True, True, 120, 'Назад'],
    [mbtNext, True, True, 120, 'Вперед']
  ];

  FrgTitle.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgTitle.Opt.Caption := 'Изменения шапки заказа';

  FrgItems.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgItems.Opt.Caption := 'Изменения позиций заказа';

  FStep := 0;
  LoadOrderGeneralChanges(FStep);
  LoadOrderTitleChanges(FStep);
  LoadOrderItemsChanges(FStep);

  Result := True;
end;


end.
