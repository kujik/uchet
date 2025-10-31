unit uFrmOWedtOrReglament;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, Vcl.ComCtrls,
  uLabelColors, uFrmBasicMdi, uFrDBGridEh, uFrMyPanelCaption, uString
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
    FAllProperties: TVarDynArray2;
    function  Prepare: Boolean; override;
    procedure LoadData;
    procedure LoadProperties;
    procedure FrgTypesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
  public
  end;

var
  FrmOWedtOrReglament: TFrmOWedtOrReglament;

implementation

uses
  uWindows,
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


  FrgTypes.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','№','80'],
    ['name$s','Тип заказа','300;w;h'],
    ['used$i','X','40','chb','e']
  ]);
  FrgTypes.Opt.SetGridOperations('u');
  //FrgTypes.Opt.SetCaption
  FrgTypes.OnColumnsUpdateData := FrgTypesColumnsUpdateData;

  FrgTypes.SetInitData('select id, pos, name, 0 as used from v_order_types order by pos',[]);
  FrgTypes.Prepare;
  FrgTypes.RefreshGrid;

  FrgProperties.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','№','80'],
    ['name$s','Свойство заказа','300;w;h'],
    ['used$i','X','40','chb','e']
  ]);
  FrgProperties.Opt.SetGridOperations('u');
  FrgProperties.SetInitData([]);
  FrgProperties.Prepare;
  FrgProperties.RefreshGrid;
  LoadProperties;




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

procedure TFrmOWedtOrReglament.LoadProperties;
var
  i, j: Integer;
  st: string;
begin
  st := '';
  j := 0;
  for i := 0 to FrgTypes.GetCount(False) - 1 do
    if FrgTypes.GetValueI('used', i, False) = 1 then begin
      S.ConcatStP(st, FrgTypes.GetValueS('id', i, False), ',');
      Inc(j);
    end;
  if j = 0 then
    FrgProperties.SetInitData([])
  else
    FrgProperties.SetInitData(
      'select id, max(pos) as pos, max(name) as name, 0 as used '+
      'from v_order_properties_for_type '+
      'where id_type in ('+ st + ') and used = 1 ' +
      'group by id '+
      'having count(distinct id_type) = ' + IntToStr(j) + ' '+
      'order by pos',
      []
    );
  FrgProperties.RefreshGrid;
end;

procedure TFrmOWedtOrReglament.LoadData;
begin
  //FAllProperties := Q.QLoadToVarDynArray2('select ')
end;

procedure TFrmOWedtOrReglament.FrgTypesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Fr.SetValue('', Value, True);
  LoadProperties;
end;

end.
