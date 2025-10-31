unit uFrmOWedtOrReglament;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils,
  uLabelColors, uFrmBasicMdi, uFrDBGridEh, uFrMyPanelCaption, Vcl.ComCtrls
  ;

type
  TFrmOWedtOrReglament = class(TFrmBasicMdi)
    pnlTop: TPanel;
    pgcMain: TPageControl;
    tsPrioperties: TTabSheet;
    tsDays: TTabSheet;
    pnlTypes: TPanel;
    pnlProperties: TPanel;
    frmpcProperties: TFrMyPanelCaption;
    frmpcTypes: TFrMyPanelCaption;
    FrgTypes: TFrDBGridEh;
    FrgProperties: TFrDBGridEh;
    FrgDays: TFrDBGridEh;
    edt_name: TDBEditEh;
    nedtDeadline: TDBNumberEditEh;
  private
    function  Prepare: Boolean; override;
  public
  end;

var
  FrmOWedtOrReglament: TFrmOWedtOrReglament;

implementation

uses
  uWindows,
  uString,
  uForms,
  uDBOra,
  uMessages,
  uData,
  uErrors,
  uPrintReport,
  uOrders
  ;

{$R *.dfm}

function TFrmOWedtOrReglament.Prepare: Boolean;
//подготовка к открытию формы
//в AddParam:
//[статус, area, FOrNumъ
var
  i, j: Integer;
  c: TControl;
  va: TVarDynArray2;
begin
  Result := False;
//  FWHBounds.Y := 500;
//  FWHBounds.X := 500;
  Caption := 'Регламент заказа';
  Result := True;
(*


  Cth.MakePanelsFlat(pnlFrmClient, []);
  Cth.SetBtn(btnFill, mybtGo, False, 'Заполнить');
//  FWHCorrected.X:=0;
  //Cth.AlignControls(pnlSelectOrder, [], True);
  pnlSelectOrder.Height := 0;
  Cth.AlignControls(pnlTitle, [], True, 2);
  FOpt.DlgButtonsR:=[[mbtPrint, Mode <> FEdit], [mbtGo, (Mode = FEdit), 'Заполнить'], [mbtDividor], [mbtSpace, 4]];
  FOpt.StatusBarMode := stbmNone; //stbmDialog;
  FOpt.RefreshParent := True;
  if Mode <> fAdd then begin
    cmbOrder.Visible := False;
    btnFill.Visible := False;
  end;
  //настроим фрейм гида
  Frg1.Options := [myogIndicatorColumn, myogColoredTitle, myogHiglightEditableCells, myogHiglightEditableColumns, myogHasStatusBar];
  Frg1.Opt.SetDataMode(myogdmFromArray);
  Frg1.Opt.SetFields([
    ['id$s', '_id', '40'], ['id_order_item$s', '_id_oi', '40'], ['slash$s', 'Слеш', '80'], ['name$s', 'Наименование', '300;W'],
    ['qnt$i', 'Кол-во в заказе', '60'],
    ['qnt_max$i', S.IIfStr(Mode in [fView, fEdit], '_') + 'Кол-во непринятых', '60'],
    ['qnt_m$i', 'Кол-во передано', '60', 'e', Mode = fAdd],
    ['qnt_s$i', S.IIfStr(not((Mode = fEdit) or (AddParam[0] > 0)), '_') + 'Кол-во принято', '60', 'e', Mode = fEdit]
    ]
  );
{  if Mode = fAdd then
    Frg1.Opt.S(gotColEditable, [['qnt_m']]);
  if Mode = fEdit then
    Frg1.Opt.S(gotColEditable, [['qnt_s']]);}
  Frg1.Opt.Caption := 'Изделия';
  Frg1.Opt.SetGridOperations('u');
  Frg1.OnColumnsUpdateData := Frg1ColumnsUpdateData;
  Frg1.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;
  Frg1.OnSelectedDataChange := Frg1ChangeSelectedData;
  //подготовим фрейм грида
  Frg1.Prepare;
  //минимальные размеры формы
  FWHBounds.Y := 300;
  FWHBounds.X := 300;
  Caption := 'Накладная перемещения на СГП';
  //загрузим данные
  LoadData;
    //подсказка
  FOpt.InfoArray:=[
    ['Заполнение накладной передачи на СГП (мастером)'#13#10]
  ];
  Result := True;*)
end;

end.
