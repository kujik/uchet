unit uFrmOWedtOrReglament;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, Vcl.ComCtrls,
  uLabelColors, uFrmBasicMdi, uFrmBasicDbDialog, uFrDBGridEh, uFrMyPanelCaption, uString
  ;

type
  TFrmOWedtOrReglament = class(TFrmBasicDbDialog)
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
    nedt_deadline: TDBNumberEditEh;
    procedure nedt_deadlineButtonClick(Sender: TObject; var Handled: Boolean);
  private
    FAllProperties: TVarDynArray2;
    function  Prepare: Boolean; override;
    procedure SetGridValues;
    procedure LoadProperties;
    procedure GetPropertiesResult;
    function  Save: Boolean;
    procedure FrgTypesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure FrgPropertiesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
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
  uOrders,
  uFrmBasicInput
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
  F.DefineFields:=[
    ['id$i'],
    ['name$s','V=1:4000::T'],
    ['deadline$i','V=1:365:0:N'],
    ['ids_types$s'],
    ['ids_properties$s'],
    ['types$s'],
    ['properties$s']
  ];

  View := 'order_reglaments';
  Table := 'order_reglaments';

  Result := inherited;
  if not Result then
    Exit;
  nedt_deadline.ReadOnly := True;
  //SetControlsEditable([], True);



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
  FrgProperties.OnColumnsUpdateData := FrgPropertiesColumnsUpdateData;
  FrgProperties.SetInitData([]);
  FrgProperties.Prepare;
  FrgProperties.RefreshGrid;
  SetGridValues;



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
  st, st2: string;
begin
  st := '';
  st2 := '';
  j := 0;
  for i := 0 to FrgTypes.GetCount(False) - 1 do
    if FrgTypes.GetValueI('used', i, False) = 1 then begin
      S.ConcatStP(st, FrgTypes.GetValueS('id', i, False), ',');
      S.ConcatStP(st2, FrgTypes.GetValueS('name', i, False), '; ');
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
  F.SetProp('ids_types', st);
  F.SetProp('types', st2);
end;

procedure TFrmOWedtOrReglament.nedt_deadlineButtonClick(Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
begin
  va := [nedt_deadline.Value];
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~Дней по регламенту', 150, 80,
   [[cntNEdit, 'Дней:', '1:365:0:N', 50]], va, va, [['']], nil) >= 0 then begin
    nedt_deadline.Value := va[0].AsInteger;
  end;
end;

procedure TFrmOWedtOrReglament.GetPropertiesResult;
var
  i, j: Integer;
  st, st2: string;
begin
  st := '';
  st2 := '';
  j := 0;
  for i := 0 to FrgProperties.GetCount(False) - 1 do
    if FrgProperties.GetValueI('used', i, False) = 1 then begin
      S.ConcatStP(st, FrgProperties.GetValueS('id', i, False), ',');
      S.ConcatStP(st2, FrgProperties.GetValueS('name', i, False), '; ');
      Inc(j);
    end;
  F.SetProp('ids_properties', st);
  F.SetProp('properties', st2);
end;


procedure TFrmOWedtOrReglament.SetGridValues;
var
  i: Integer;
  va: TVarDynArray;
begin
  va := A.Explode(F.GetProp('ids_types'), ',', True);
  for i := 0 to FrgTypes.GetCount(False) - 1 do
    if A.InArray(FrgTypes.GetValueI('id', i, False), va) then
      FrgTypes.SetValue('used', i, False, 1);
  FrgTypes.Invalidate;
  LoadProperties;
  va := A.Explode(F.GetProp('ids_properties'), ',', True);
  for i := 0 to FrgProperties.GetCount(False) - 1 do
    if A.InArray(FrgProperties.GetValueI('id', i, False), va) then
      FrgProperties.SetValue('used', i, False, 1);
  FrgProperties.Invalidate;
end;

function TFrmOWedtOrReglament.Save: Boolean;
var
  st, st1: string;
begin
  Result := inherited;
  if (Mode = fDelete) then
    Exit;
end;


procedure TFrmOWedtOrReglament.FrgTypesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Fr.SetValue('', Value, True);
  LoadProperties;
end;

procedure TFrmOWedtOrReglament.FrgPropertiesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Fr.SetValue('', Value, True);
  GetPropertiesResult;
end;


end.
