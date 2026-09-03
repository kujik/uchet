{
Диалог печати этикеток по позициям заказа - для каждой позиции (слеш/изделие) можно задать количество этикеток на
печать (по умолчанию равно количеству изделий по позиции) и распечатать (кнопка "Печать этикеток", формирует отчет
через PrintReport.pnl_OrderLabels - логика самого формирования отчета не менялась). Вызывается только из
uFrmOGjrnOrders.pas (кнопка Tag = mbtPrintLabels в журнале заказов).

Замена D_OrderPrintLabels.pas/TDlg_OrderPrintLabels. По задаче: диалог НЕ модальный (вызывается через Show, а не
ShowModal2 - в отличие от большинства ранее переделанных диалогов) и построен на фрейме грида Frg1 (TFrDBGridEh)
вместо связки DBGridEh1+MemTableEh1 напрямую.

Так как печать - это разовое действие без сохранения данных в БД (введенное количество "На печать" нужно только
для самого отчета и никуда не пишется), а не обычное редактирование записи, класс - потомок TFrmBasicGrid2, а НЕ
TFrmBasicEditabelGrid (там обязателен Save с реальным сохранением, здесь сохранять нечего). Кнопка Ok/Save тоже не
нужна - вызывающий код передает Mode = fView, поэтому в панели кнопок формы будет только "Закрыть"; кнопка
"Печать этикеток" (стандартный тип mbtPrintLabels - тот же, что и на кнопке в журнале заказов, открывающей этот
диалог) добавлена в ту же панель (pnlFrmBtnsR) по аналогии с кнопкой "Создать полуфабрикат" в uFrmOGedtEstimate.pas
(см. PrepareForm/Frg1ButtonClick). Так как диалог не модальный, окно можно не закрывать и напечатать этикетки
несколько раз подряд (например, поправив количество) - как и в исходном диалоге, кнопка печати не закрывает форму.

Данные грида загружаются один раз через Frg1.SetInitData(Sql, Params) (оффлайн-режим, myogdmFromArray - в этом
режиме Frg1 не пытается ни обновлять, ни перечитывать данные из БД при редактировании ячейки, см. общий комментарий
в TFrDBGridEh.ColumnsUpdateData/SetDataDriverCommands - это в точности соответствует исходному поведению, где
MemTableEh1 был чисто локальным разовым буфером без всякой связи с БД на запись). Поле "На печать" (qnt_p) -
единственное редактируемое (признак редактируемости у поля появляется только при наличии подстроки "e=..." в его
описании в SetFields - у остальных полей ее нет, они автоматически нередактируемы, отдельно вызывать
Opt.SetColFeature не потребовалось).

Небольшое сознательное отличие от исходного диалога (см. также комментарий "!!!поправить Integer" в оригинальном
коде - похоже, это и предполагалось поправить): количество на печать теперь проверяется как целое неотрицательное
число (verify-строка 'e=0:999999:0:N') - в исходном диалоге проверок не было вообще никаких (поле было float,
пустая строка молча трактовалась как 0). Теперь пустое значение не допускается (при этом изначально все строки уже
заполнены количеством по позиции, так что пустых ячеек при обычной работе не возникает).
}
unit uFrmOGedtOrderPrintLabels;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmOGedtOrderPrintLabels = class(TFrmBasicGrid2)
  private
    { Private declarations }
    ID_Order: Integer;
    FOrderFields: TVarDynArray; //для PrintReport.pnl_OrderLabels - [0] = project (наименование проекта заказа)
    procedure DoPrint;
  protected
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
  public
  end;

var
  FrmOGedtOrderPrintLabels: TFrmOGedtOrderPrintLabels;

implementation

uses
  uDBOra,
  uPrintReport
  ;

{$R *.dfm}

function TFrmOGedtOrderPrintLabels.PrepareForm: Boolean;
var
  LHeader: TVarDynArray;
begin
  Result := False;
  ID_Order := ID;

  LHeader := Q.QLoadRow('select id, project from v_orders where id = :id_order$i', [ID_Order]);
  if LHeader[0] = null then begin
    MyWarningMessage('Заказ не найден!');
    Exit;
  end;
  FOrderFields := [LHeader[1]];
  Caption := 'Печать этикеток';

  Frg1.Opt.SetFields([
    ['id$i', '_id', '40'],
    ['slash$s', 'Слеш', '100'],
    ['itemname$s', 'Изделие', '300;w'],
    ['qnt$f', 'Кол-во', '80'],
    ['qnt_p$f', 'На печать', '80', 'e=0:999999:0:N']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [[mbtPrintLabels]], cbttBSmall, pnlFrmBtnsR);

  Frg1.SetInitData(
    'select id, slash, itemname, qnt, qnt as qnt_p from v_order_items where id_order = :id_order$i and qnt > 0 order by slash',
    [ID_Order]
  );

  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;
  FOpt.InfoArray := [[
    'Печать этикеток по позициям заказа.'#13#10+
    'По умолчанию количество на печать равно количеству изделий по позиции - при необходимости его можно поправить.'#13#10+
    'Для печати нажмите кнопку "Печать этикеток". Диалог не модальный, окно можно не закрывать и напечатать несколько раз.'#13#10
  ]];
  Result := inherited;
end;

procedure TFrmOGedtOrderPrintLabels.DoPrint;
begin
  if Frg1.GetRawCount = 0 then begin
    MyWarningMessage('В заказе нет позиций для печати!');
    Exit;
  end;
  PrintReport.pnl_OrderLabels(0, Frg1.MemTableEh1, FOrderFields);
end;

procedure TFrmOGedtOrderPrintLabels.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtPrintLabels then begin
    Handled := True;
    DoPrint;
  end
  else
    inherited;
end;

end.
