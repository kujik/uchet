unit uFrmPWedtPnlOps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uTurv, uNamedArr,
  uFrmBasicDbDialog, Vcl.Mask, uFrMyPanelCaption, uLabelColors
  ;

type
  TFrmPWedtPnlOps = class(TFrmBasicDbDialog)
    pnlTop: TPanel;
    pnlBottom: TPanel;
    pgcMain: TPageControl;
    tsPainting: TTabSheet;
    frmpcPainting: TFrMyPanelCaption;
    pnlPaintingBottom: TPanel;
    FrgPainting: TFrDBGridEh;
    lblCaption1: TLabel;
    lblCaption2: TLabel;
    chbPaintingDataEntered: TDBCheckBoxEh;
    lblPainting: TLabel;
    tsCnc: TTabSheet;
    FrgCnc: TFrDBGridEh;
    pnlCncBottom: TPanel;
    lblCnc: TLabel;
    chbCncDataEntered: TDBCheckBoxEh;
    frmpcCnc: TFrMyPanelCaption;
  private
    FIdOrItem: Variant;
    FIStdrItem: Variant;
    FPaintingData: TNamedArr;
    FPaintingItems: TNamedArr;
    FCncData: TNamedArr;
    FCncItems: TNamedArr;
    //настройки при создании формы
    function  Prepare: Boolean; override;
    procedure PreparePainting;
    procedure PrepareCnc;
    function  Save: Boolean; override;
    procedure SaveTable(var ARec: TNamedArr; ATable: string; AChanged: Boolean; ACheckBox: TDBCheckBoxEh);
    procedure SavePainting;
    procedure SaveCnc;
    procedure SetCaption;
    procedure SetOpsCaption(ARec: TNamedArr; ALabel: TLabel; ACheckBox: TDBCheckBoxEh);
    procedure ControlOnChange(Sender: TObject); override;
  public
  end;

var
  FrmPWedtPnlOps: TFrmPWedtPnlOps;

implementation

{$R *.dfm}

function TFrmPWedtPnlOps.Prepare: Boolean;
begin
  Result := False;
  Caption := 'Производственные операции';
  FOpt.RefreshParent := True;
  F.DefineFields := [
    ['id$i;0'],
    ['fullname as name$s;0'],
    ['or_format_name || '' - '' || or_format_estimate_name as parent_name$s;0']
  ];
  View := S.IIf(AddParam = THIS_IS_STD_ITEM, 'v_or_std_items', 'order_items');
  if not inherited then
    Exit;
  SetCaption;
  PreparePainting;
  PrepareCnc;
  pgcMain.ActivePageIndex := 0;
  Result := True;
end;

procedure TFrmPWedtPnlOps.PreparePainting;
begin
  frmpcPainting.SetParameters(True, 'Операции по лакокраске',
    [['Проставьте площадь покраски на одно изделие по тем операциям, которые в данном изделии присутствуют. Если операции нет, можно поставить 0 или оставить пустое значение.']],
    False
  );

  Cth.AlignControls(pnlPaintingBottom, [], True);

  Q.QLoad('select * from pnl_ops_painting where ' +  S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') + ' = :id$i',
    [ID], FPaintingData
  );

  Cth.SetControlValue(chbPaintingDataEntered, FPaintingData.GN('is_data_entered').AsInteger);

  FrgPainting.Options := [myogColoredTitle, myogIndicatorColumn, myogHiglightEditableColumns, myogHiglightEditableCells, myogHasStatusBar];
  FrgPainting.Opt.SetFields([
    ['id$i', '_id', '40'],
    ['id_ops_painting$i', '_id_ops', '40'],
    ['id_ref_ops_painting$i', '_id_ref', '40'],
    ['name$s', 'Операция', '300;w'],
    ['area_per_item$f', 'Площадь на одно изделие', '90', 'e=0:1000:2'],
    ['norm$f', 'Норма, мин./м.кв.', '90'],
    ['area_per_all_items$f', 'Площадь на все изделия', '90', 'i', AddParam = THIS_IS_STD_ITEM]
//      ['$', '', ''],
  ]);
  FrgPainting.Opt.SetGridOperations('u');
  FrgPainting.SetInitData([]);
  FrgPainting.Prepare;
  FrgPainting.RefreshGrid;
  Q.QLoad('select ' + FrgPainting.GetFieldNames.Implode(', ') +
    ' from v_pnl_ops_painting_items_dlg where ' +
    S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') +
    ' is null and id_order_item is null or id_std_item = :id$i order by pos',
    [ID], FPaintingItems
  );
  FrgPainting.SetInitData(FPaintingItems);
  FrgPainting.Opt.Caption := '';
  FrgPainting.RefreshGrid;
  FrgPainting.SetState(False, False, null);

  SetOpsCaption(FPaintingData, lblPainting, chbPaintingDataEntered);
end;

procedure TFrmPWedtPnlOps.PrepareCnc;
var
  LEstimateNomencl: TVarDynArray2;
begin
  frmpcCnc.SetParameters(True, 'Операции по ЧПУ',
    [['Выберите используемые материалы и проставьте для каждого колитчество закладок и время на одну закладку (для всего количества изделий в заказе).']],
    False
  );

  Cth.AlignControls(pnlCncBottom, [], True);

  Q.QLoad('select * from pnl_ops_cnc where ' +  S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') + ' = :id$i',
    [ID], FCncData
  );

  Cth.SetControlValue(chbCncDataEntered, FCncData.GN('is_data_entered').AsInteger);

  LEstimateNomencl := Q.QLoad('select name, id_name from v_estimate where id_std_item = :id$i', [ID]);

  FrgCnc.Options := [myogColoredTitle, myogIndicatorColumn, myogHiglightEditableColumns, myogHiglightEditableCells, myogHasStatusBar];
  FrgCnc.Opt.SetFields([
    ['id$i', '_id', '40'],
    ['id_ops_cnc$i', '_id_ops', '40'],
//    ['id_bcad_nomencl$i', '_id_ref', '40'],
//    ['name$s', 'Материал', '300;w'],
    ['id_bcad_nomencl$i', 'Материал', '300;w;L', 'e'],
    ['batch_count$i', 'Количество закладок', '90', 'e=0:1000'],
    ['batch_duration$f', 'Время на однцу закладку, мин.', '90', 'e=0:1000:2']
  ]);
  FrgCnc.Opt.SetGridOperations('uad');
  FrgCnc.SetInitData([]);
  FrgCnc.Opt.SetPick('id_bcad_nomencl', LEstimateNomencl, True, True);
  FrgCnc.Prepare;
  FrgCnc.RefreshGrid;
  Q.QLoad('select ' + FrgCnc.GetFieldNames.Implode(', ') +
    ' from v_pnl_ops_cnc_items_dlg where ' +
    S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') + ' = :id$i order by name, batch_count desc, batch_duration desc',
    [ID], FCncItems
  );
  FrgCnc.SetInitData(FCncItems);
  FrgCnc.Opt.Caption := '';
  FrgCnc.RefreshGrid;
  FrgCnc.AddRow;
  FrgCnc.SetState(False, False, null);

  SetOpsCaption(FCncData, lblCnc, chbCncDataEntered);
end;

function TFrmPWedtPnlOps.Save: Boolean;
begin
  Result := False;
  Q.QBeginTrans(True);
  SavePainting;
  SaveCnc;
  Result := Q.QCommitTrans;
end;

procedure TFrmPWedtPnlOps.SaveTable(var ARec: TNamedArr; ATable: string; AChanged: Boolean; ACheckBox: TDBCheckBoxEh);
//устанавливаем поля в любой родительской таблице по операции в зависимости от фактов изменения данных
//записываем в бд поля, являющиеся общими для данных таблиц
begin
  var LIns := ARec.Count = 0;
  var LDataChanged := False;
  if ARec.Count = 0 then begin
    ARec.IncLength;
    ARec.SetNull(0);
  end;
  if ARec.G('dt_data_entered') = null and ACheckBox.Checked then begin
    ARec.SetValue(0, 'dt_data_entered', Now);
    LDataChanged := True;
  end;
  if not ACheckBox.Checked then begin
    ARec.SetValue(0, 'dt_data_entered', null);
    LDataChanged := True;
  end;
  if ((ARec.G('is_data_entered').AsInteger <> S.IIf(ACheckBox.Checked, 1, 0)) or AChanged) and (ARec.G('dt_data_entered') <> Now) then begin
    ARec.SetValue(0, 'dt_changed', Now);
    LDataChanged := True;
  end;
  if (ARec.G('is_data_entered').AsInteger <> S.IIf(ACheckBox.Checked, 1, 0)) then begin
    ARec.SetValue(0, 'is_data_entered', S.IIf(ACheckBox.Checked, 1, 0));
    LDataChanged := True;
  end;
  if LIns then begin
    ARec.SetValue(0, S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item'), ID);
    LDataChanged := True;
  end;
  var LID := ARec.G('id');
  if LIns or LDataChanged then begin
    LID := Q.QSave(
      S.IIf(LIns, 'i', 'u'), ATable , '', 'id$i;id_std_item$i;id_order_item$i;dt_data_entered$d;dt_changed$d;is_data_entered$i',
      [ARec.G('id'), ARec.G('id_std_item'), ARec.G('id_order_item'), ARec.G('dt_data_entered'), ARec.G('dt_changed'), ARec.G('is_data_entered')]
    );
    ARec.SetValue(0, 'id', LID);
  end;
end;

procedure TFrmPWedtPnlOps.SavePainting;
//сохраним данные по покраске
var
  i, j: Integer;
begin
  var LItemsChanged := False;
  for i := 0 to FPaintingItems.High do
    if FrgPainting.GetRawValue('area_per_item', i) <> FPaintingItems.G(i, 'area_per_item') then begin
      LItemsChanged := True;
      Break;
    end;
  SaveTable(FPaintingData, 'pnl_ops_painting', LItemsChanged, chbPaintingDataEntered);
  if LItemsChanged then
    for i := 0 to FPaintingItems.High do
      if FrgPainting.GetRawValue('area_per_item', i).AsFloat <> FPaintingItems.G(i, 'area_per_item').AsFloat then begin
        var LQnt := FrgPainting.GetRawValue('area_per_item', i).AsFloat;
        var LIdI := FrgPainting.GetRawValue('id', i).AsInteger;
        Q.QSave(
          S.DecodeBool([(LQnt = 0) and (LIdI <> 0), 'd', (LQnt <> 0) and (LIdI = 0), 'i', 'u']),
          'pnl_ops_painting_items', '',
          'id$i;id_ops_painting$i;id_ref_ops_painting$i;area_per_item$f',
          [LIdI, FPaintingData.G('id'), FPaintingItems.G(i, 'id_ref_ops_painting'), LQnt]
        );
      end;
end;

procedure TFrmPWedtPnlOps.SaveCnc;
//сохраним данные по ЧПУ
var
  i, j: Integer;
begin
  var LItemsChanged := False;
  if FrgCnc.GetRawCount <> FCncItems.Count then
    LItemsChanged := True
  else
    for i := 0 to Min(FrgCnc.GetCount(False), FCncItems.Count) - 1 do
      if (FrgCnc.GetRawValue('id_bcad_nomencl', i) <> FCncItems.G(i, 'id_bcad_nomencl')) or
         (FrgCnc.GetRawValue('batch_count', i) <> FCncItems.G(i, 'batch_count')) or
         (FrgCnc.GetRawValue('batch_duration', i) <> FCncItems.G(i, 'batch_duration')) or
         (FrgCnc.GetRawValue('id', i) >= MY_IDS_INSERTED_MIN)
      then begin
        LItemsChanged := True;
        Break;
      end;
  SaveTable(FCncData, 'pnl_ops_cnc', LItemsChanged, chbCncDataEntered);
  if LItemsChanged then
    for i := 0 to FrgCnc.GetCount(False) - 1 do begin
      var LDbOp := '';
      if (FrgCnc.GetRawValueI('id_bcad_nomencl', i) = 0) or (FrgCnc.GetRawValueI('batch_count', i) = 0) or (FrgCnc.GetRawValueF('batch_duration', i) = 0) then begin
        if FrgCnc.GetRawValueI('id', i) < MY_IDS_INSERTED_MIN then
          LDbOp := 'd';
      end
      else if FrgCnc.GetRawValueI('id', i) >= MY_IDS_INSERTED_MIN then begin
        LDbOp := 'i';
      end
      else if
        (FrgCnc.GetRawValue('id_bcad_nomencl', i) <> FCncItems.G(i, 'id_bcad_nomencl')) or
        (FrgCnc.GetRawValue('batch_count', i) <> FCncItems.G(i, 'batch_count')) or
        (FrgCnc.GetRawValue('batch_duration', i) <> FCncItems.G(i, 'batch_duration'))
      then begin
        LDbOp := 'u';
      end;
      if LDbOp <> '' then
        Q.QSave(LDbOp,
          'pnl_ops_cnc_items', '',
          'id$i;id_ops_cnc$i;id_bcad_nomencl$i;batch_count$i;batch_duration$f',
          [FrgCnc.GetRawValueI('id', i), FCncData.G('id'), FrgCnc.GetRawValueI('id_bcad_nomencl', i), FrgCnc.GetRawValueI('batch_count', i), FrgCnc.GetRawValueF('batch_duration', i)]
        );
    end;
end;

procedure TFrmPWedtPnlOps.SetCaption;
//информация по объекту, для которого задаем операции, в верхней панели
begin
  Cth.AlignControls(pnlTop, [], False);
  lblCaption1.SetCaption2('Производственные операции для ' + S.IIf(AddParam = THIS_IS_STD_ITEM, 'стандартного изделия:', 'изделия заказа:'));
  lblCaption2.SetCaption2('$FF0000' + F.GetProp('parent_name') + '$000000  -  $FF0000' + F.GetProp('name'));
end;

procedure TFrmPWedtPnlOps.SetOpsCaption(ARec: TNamedArr; ALabel: TLabel; ACheckBox: TDBCheckBoxEh);
begin
  ALabel.SetCaptionAr2([
    S.IIf(ACheckBox.Checked, '$FF00FFДанные введены' +
    S.IIf(ARec.GN('dt_data_entered') <> null, ' ' + ARec.GN('dt_data_entered').AsDatetimeStr, '.'),
    '$0000FFДанные не введены!'),
    '$000000',
    S.IIFStr(ARec.GN('dt_changed') <> null, '  Изменены $FF0000' + ARec.GN('dt_changed').AsDatetimeStr)
  ]);
end;

procedure TFrmPWedtPnlOps.ControlOnChange(Sender: TObject);
begin
  if Sender = chbPaintingDataEntered then
    SetOpsCaption(FPaintingData, lblPainting, chbPaintingDataEntered)
  else if Sender = chbCncDataEntered then
    SetOpsCaption(FCncData, lblCnc, chbCncDataEntered);
end;

end.
