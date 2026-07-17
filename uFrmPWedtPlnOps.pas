unit uFrmPWedtPlnOps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uTurv, uNamedArr,
  uFrmBasicDbDialog, Vcl.Mask, uFrMyPanelCaption, uLabelColors
  ;

type
  TFrmPWedtPlnOps = class(TFrmBasicDbDialog)
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
    tsLaser: TTabSheet;
    frmpcLaser: TFrMyPanelCaption;
    pnlLaserBottom: TPanel;
    lblLaser: TLabel;
    chbLaserDataEntered: TDBCheckBoxEh;
    FrgLaser: TFrDBGridEh;
    tsDrilling: TTabSheet;
    nedtDrilling: TDBNumberEditEh;
    frmpcDrilling: TFrMyPanelCaption;
    pnlDrillingBottom: TPanel;
    lblDrilling: TLabel;
    chbDrillingDataEntered: TDBCheckBoxEh;
    lblAllDataEntered: TLabel;
    nedtDrillingForAll: TDBNumberEditEh;
  private
    FIdOrItem: Variant;
    FIStdrItem: Variant;
    FPaintingData: TNamedArr;
    FPaintingItems: TNamedArr;
    FCncData: TNamedArr;
    FCncItems: TNamedArr;
    FLaserData: TNamedArr;
    FLaserItems: TNamedArr;
    FDrillingData: TNamedArr;
    FEstimateBoardsNomencl: TVarDynArray2;
    //настройки при создании формы
    function  Prepare: Boolean; override;
    procedure PreparePainting;
    procedure PrepareCnc;
    procedure PrepareLaser;
    procedure PrepareDrilling;
    function  Save: Boolean; override;
    procedure SaveTable(var ARec: TNamedArr; ATable: string; AChanged: Boolean; ANoOps: Boolean; ACheckBox: TDBCheckBoxEh);
    procedure SavePainting;
    procedure SaveCnc;
    procedure SaveLaser;
    procedure SaveDrilling;
    procedure SetCaption;
    procedure LoadFromXml;
    procedure LoadBoardsNomenclListFromEstimate;
    procedure SetOpsCaption(ARec: TNamedArr; ALabel: TLabel; ACheckBox: TDBCheckBoxEh);
    procedure SetAllDataEnteredCaption;
    procedure ControlOnChange(Sender: TObject); override;
    procedure EditButtonsClick(Sender: TObject; var Handled: Boolean); override;
    procedure FrgCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
  public
  end;

var
  FrmPWedtPlnOps: TFrmPWedtPlnOps;

implementation

{$R *.dfm}

uses
  uOrders;

function TFrmPWedtPlnOps.Prepare: Boolean;
var
  LFields: TVarDynArray2;
begin
  Result := False;
  Caption := 'Производственные операции';
  FOpt.RefreshParent := True;
  if AddParam = THIS_IS_STD_ITEM then begin
    F.DefineFields := [
      ['id$i;0'],
      ['fullname as name$s;0'],
      ['or_format_name || '' - '' || or_format_estimate_name as parent_name$s;0'],
      ['type;0']   //0 - производственное, 2 - ПФ
    ];
    View := 'v_or_std_items';
  end
  else begin
    F.DefineFields := [
      ['id$i;0'],
      ['itemname as name$s;0'],
      ['slash || '' - '' || customer || '' - '' || project as parent_name$s;0'],
      ['qnt;0'],
      ['nstd;0'],
      ['id_thn;0']
    ];
    View := 'v_order_items';
  end;
  FOpt.InfoArray := [[
    'Ввод или просмотр производственных операций для изделия.'#13#10+
    ''#13#10+
    'Введите необходимые данные для каждой возможной производственной операции.'#13#10+
    '(если какой-то тип операций для изделия не предусмотрен, очистите список или поставьте 0, в зависимости от операции)'#13#10+
    ''#13#10+
    'Чтобы данные считались введенными и обрабатывались, необходимо поставить соответствующую галочку для этой операции.'
  ]];
  if not inherited then
    Exit;
  Cth.AlignControls(pnlBottom, [], True);
  //для стд. изд. выйдем, если это не производственное или не полуфабрикат
  if (AddParam = THIS_IS_STD_ITEM) and not (F.GetPropB('type').AsInteger in [0..2]) then
    Exit;
  //для изделия заказа выйдем, если нет технолога
  if (AddParam = THIS_IS_ORDER_ITEM) and ((F.GetPropB('id_thn') = -100) or (F.GetPropB('qnt') = 0)) then
    Exit;
  SetCaption;
  LoadBoardsNomenclListFromEstimate;
  PreparePainting;
  PrepareCnc;
  PrepareLaser;
  PrepareDrilling;
  pgcMain.ActivePageIndex := 0;
  Result := True;
end;

procedure TFrmPWedtPlnOps.PreparePainting;
begin
  frmpcPainting.SetParameters(True, 'Операции по лакокраске',
    [['Проставьте площадь покраски на одно изделие по тем операциям, которые в данном изделии присутствуют. Если операции нет, можно поставить 0 или оставить пустое значение.']],
    ''
  );

  Cth.AlignControls(pnlPaintingBottom, [], True);

  Q.QLoad('select * from pnl_ops_painting where ' +  S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') + ' = :id$i',
    [ID], FPaintingData
  );

  Cth.SetControlValue(chbPaintingDataEntered, FPaintingData.GN('is_data_entered').AsInteger);

  var LEditable := not((AddParam = THIS_IS_ORDER_ITEM) and (F.GetPropB('nstd').AsInteger = 0));

  FrgPainting.Options := [myogColoredTitle, myogIndicatorColumn, myogHiglightEditableColumns, myogHiglightEditableCells, myogHasStatusBar];
  FrgPainting.Opt.SetFields([
    ['id$i', '_id', '40'],
    ['id_ops_painting$i', '_id_ops', '40'],
    ['id_ref_ops_painting$i', '_id_ref', '40'],
    ['name$s', 'Операция', '300;w'],
    ['area_per_item$f', 'Площадь на одно изделие', '90', 'e=0:1000:2'],
    ['norm$f', 'Норма, мин./м.кв.', '90'],
    ['area_per_all_items$f', 'Площадь на все изделия', '90', 'i', AddParam = THIS_IS_STD_ITEM]
  ]);
  FrgPainting.Opt.SetGridOperations('u');
  FrgPainting.SetInitData([]);
  FrgPainting.Prepare;
  FrgPainting.RefreshGrid;
  Q.QLoad('select ' + FrgPainting.GetFieldNames.Implode(', ') +
    ' from v_pnl_ops_painting_items_dlg where (' +
    S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item is null and id_order_item is null or id_std_item = :id$i' , 'id_std_item is null and id_order_item is null or id_order_item = :id$i') + ')' +
    S.IIfStr(not LEditable, ' and id is not null') +
    ' order by pos'
    ,
    [ID], FPaintingItems
  );
  FrgPainting.SetInitData(FPaintingItems);
  FrgPainting.Opt.Caption := '';
  FrgPainting.RefreshGrid;
  FrgPainting.SetState(False, False, null);
  FrgPainting.onCellValueSave := FrgCellValueSave;
  FrgPainting.GridReadOnly := not LEditable;
  chbPaintingDataEntered.Enabled := LEditable;

  SetOpsCaption(FPaintingData, lblPainting, chbPaintingDataEntered);
end;

procedure TFrmPWedtPlnOps.PrepareCnc;
begin
  frmpcCnc.SetParameters(True, 'Операции по ЧПУ',
    [['Выберите используемые материалы и проставьте для каждого колитчество закладок и время на одну закладку (для всего количества изделий в заказе).'#13#10+
    'Номенклатура выбирается из списка, содержащего позиции из сметы в группе "Плитные материалы"'#13#10+
    'Для добавления строки внизу таблицы нажмите клавишу "Стрелка вниз".'#13#10+
    'Если ввести 0 в любом столбце или очистить наименование, то при сохранении строка будет удалена.'#13#10+
    ''#13#10
    ]],
    ''
  );

  Cth.AlignControls(pnlCncBottom, [], True);

  Q.QLoad('select * from pnl_ops_cnc where ' +  S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') + ' = :id$i',
    [ID], FCncData
  );

  Cth.SetControlValue(chbCncDataEntered, FCncData.GN('is_data_entered').AsInteger);

  FrgCnc.Options := [myogColoredTitle, myogIndicatorColumn, myogHiglightEditableColumns, myogHiglightEditableCells, myogHasStatusBar];
  FrgCnc.Opt.SetFields([
    ['id$i', '_id', '40'],
    ['id_ops_cnc$i', '_id_ops', '40'],
    ['id_bcad_nomencl$i', 'Материал', '300;w;L', 'e'],
    ['batch_count$i', 'Количество закладок', '90', 'e=0:1000'],
    ['batch_duration$f', 'Время на однцу закладку, мин.', '90', 'e=0:1000:2']
  ]);
  FrgCnc.Opt.SetGridOperations('uad');
  FrgCnc.SetInitData([]);
  FrgCnc.Opt.SetPick('id_bcad_nomencl', FEstimateBoardsNomencl, True, True);
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
  FrgCnc.onCellValueSave := FrgCellValueSave;

  SetOpsCaption(FCncData, lblCnc, chbCncDataEntered);
end;

procedure TFrmPWedtPlnOps.PrepareLaser;
begin
  frmpcLaser.SetParameters(True, 'Операции по лазеру',
    [['Выберите используемые материалы и проставьте для каждого колитчество закладок и время на одну закладку (для всего количества изделий в заказе).'#13#10+
    'Номенклатура выбирается из списка, содержащего позиции из сметы в группе "Плитные материалы"'#13#10+
    'Для добавления строки внизу таблицы нажмите клавишу "Стрелка вниз".'#13#10+
    'Если ввести 0 в любом столбце или очистить наименование, то при сохранении строка будет удалена.'#13#10+
    ''#13#10
    ]],
    ''
  );

  Cth.AlignControls(pnlLaserBottom, [], True);

  Q.QLoad('select * from pnl_ops_laser where ' +  S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') + ' = :id$i',
    [ID], FLaserData
  );

  Cth.SetControlValue(chbLaserDataEntered, FLaserData.GN('is_data_entered').AsInteger);

  FrgLaser.Options := [myogColoredTitle, myogIndicatorColumn, myogHiglightEditableColumns, myogHiglightEditableCells, myogHasStatusBar];
  FrgLaser.Opt.SetFields([
    ['id$i', '_id', '40'],
    ['id_ops_laser$i', '_id_ops', '40'],
    ['id_bcad_nomencl$i', 'Материал', '300;w;L', 'e'],
    ['batch_count$i', 'Количество закладок', '90', 'e=0:1000'],
    ['batch_duration$f', 'Время на однцу закладку, мин.', '90', 'e=0:1000:2']
  ]);
  FrgLaser.Opt.SetGridOperations('uad');
  FrgLaser.SetInitData([]);
  FrgLaser.Opt.SetPick('id_bcad_nomencl', FEstimateBoardsNomencl, True, True);
  FrgLaser.Prepare;
  FrgLaser.RefreshGrid;
  Q.QLoad('select ' + FrgLaser.GetFieldNames.Implode(', ') +
    ' from v_pnl_ops_laser_items_dlg where ' +
    S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') + ' = :id$i order by name, batch_count desc, batch_duration desc',
    [ID], FLaserItems
  );
  FrgLaser.SetInitData(FLaserItems);
  FrgLaser.Opt.Caption := '';
  FrgLaser.RefreshGrid;
  FrgLaser.AddRow;
  FrgLaser.SetState(False, False, null);
  FrgLaser.onCellValueSave := FrgCellValueSave;

  SetOpsCaption(FLaserData, lblLaser, chbLaserDataEntered);
end;

procedure TFrmPWedtPlnOps.PrepareDrilling;
begin
  frmpcDrilling.SetParameters(True, 'Операции по свеловке',
    [['Введите количество панелей (на одно изделие), для которых есть сверловка.'#13#10+
    'Если таковых нет, поставьте ноль.'#13#10+
    'Можно загрузить данные по сверловке из XML-файла, для этого нажмите кнопку в поле ввода.'#13#10
    ]],
    ''
  );
  Cth.AlignControls(pnlDrillingBottom, [], True);

  var LEditable := not((AddParam = THIS_IS_ORDER_ITEM) and (F.GetPropB('nstd').AsInteger = 0));

  if LEditable then
    Cth.SetEditButtons(nedtDrilling, [[38, 'Загрузить из XML']]);

  Q.QLoad('select * from pnl_ops_drilling where ' +  S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') + ' = :id$i',
    [ID], FDrillingData
  );

  Cth.SetControlValue(chbDrillingDataEntered, FDrillingData.GN('is_data_entered').AsInteger);
  Cth.SetControlValue(nedtDrilling, FDrillingData.GN('qnt_panels_with_drill').AsInteger);
  if AddParam = THIS_IS_ORDER_ITEM then
      nedtDrillingForAll.Value := nedtDrilling.Value * F.GetPropB('qnt');

  SetOpsCaption(FDrillingData, lblDrilling, chbDrillingDataEntered);

  nedtDrilling.ReadOnly := not LEditable;
  chbDrillingDataEntered.Enabled := LEditable;

end;

function TFrmPWedtPlnOps.Save: Boolean;
begin
  Result := False;
  Q.QBeginTrans(True);
  SavePainting;
  SaveCnc;
  SaveLaser;
  SaveDrilling;
  Result := Q.QCommitTrans;
end;

procedure TFrmPWedtPlnOps.SaveTable(var ARec: TNamedArr; ATable: string; AChanged: Boolean; ANoOps: Boolean; ACheckBox: TDBCheckBoxEh);
//устанавливаем поля в любой родительской таблице по операции в зависимости от фактов изменения данных
//записываем в бд поля, являющиеся общими для данных таблиц
begin
  var LDataChanged := False;
  if ARec.Count = 0 then begin
    ARec.IncLength;
    ARec.SetNull(0);
  end;
  var LIns := ARec.G('id') = null;
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
  if (ARec.G('no_ops').AsInteger <> S.IIf(ANoOps, 1, 0)) then begin
    ARec.SetValue(0, 'no_ops', S.IIf(ANoOps, 1, 0));
    LDataChanged := True;
  end;
  if LIns then begin
    ARec.SetValue(0, S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item'), ID);
    LDataChanged := True;
  end;
  var LID := ARec.G('id');
  if LIns or LDataChanged then begin
    LID := Q.QSave(
      S.IIf(LIns, 'i', 'u'), ATable , '', 'id$i;id_std_item$i;id_order_item$i;dt_data_entered$d;dt_changed$d;is_data_entered$i;no_ops$i',
      [ARec.G('id'), ARec.G('id_std_item'), ARec.G('id_order_item'), ARec.G('dt_data_entered'), ARec.G('dt_changed'), ARec.G('is_data_entered'), ARec.G('no_ops')]
    );
    if LIns then
      ARec.SetValue(0, 'id', LID);
  end;
end;

procedure TFrmPWedtPlnOps.SavePainting;
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
  var LNoOps := True;
  for i := 0 to FPaintingItems.High do
    if FrgPainting.GetRawValueF('area_per_item', i) <> 0 then begin
      LNoOps := False;
      Break;
    end;
  SaveTable(FPaintingData, 'pnl_ops_painting', LItemsChanged, LNoOps, chbPaintingDataEntered);
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

procedure TFrmPWedtPlnOps.SaveCnc;
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
  var LNoOps := True;
  for i := 0 to FrgCnc.GetCount(False) - 1 do
    if (FrgCnc.GetRawValueS('id_bcad_nomencl', i) <> '') or
       (FrgCnc.GetRawValueI('batch_count', i) <> 0) or
       (FrgCnc.GetRawValueI('batch_duration', i) <> 0)
    then begin
      LNoOps := False;
      Break;
    end;
  SaveTable(FCncData, 'pnl_ops_cnc', LItemsChanged, LNoOps, chbCncDataEntered);
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

procedure TFrmPWedtPlnOps.SaveLaser;
//сохраним данные по Лазеру
var
  i, j: Integer;
begin
  var LItemsChanged := False;
  if FrgLaser.GetRawCount <> FLaserItems.Count then
    LItemsChanged := True
  else
    for i := 0 to Min(FrgLaser.GetCount(False), FLaserItems.Count) - 1 do
      if (FrgLaser.GetRawValue('id_bcad_nomencl', i) <> FLaserItems.G(i, 'id_bcad_nomencl')) or
         (FrgLaser.GetRawValue('batch_count', i) <> FLaserItems.G(i, 'batch_count')) or
         (FrgLaser.GetRawValue('batch_duration', i) <> FLaserItems.G(i, 'batch_duration')) or
         (FrgLaser.GetRawValue('id', i) >= MY_IDS_INSERTED_MIN)
      then begin
        LItemsChanged := True;
        Break;
      end;
  var LNoOps := True;
  for i := 0 to FrgLaser.GetCount(False) - 1 do
    if (FrgLaser.GetRawValueS('id_bcad_nomencl', i) <> '') or
       (FrgLaser.GetRawValueI('batch_count', i) <> 0) or
       (FrgLaser.GetRawValueI('batch_duration', i) <> 0)
    then begin
      LNoOps := False;
      Break;
    end;
  SaveTable(FLaserData, 'pnl_ops_laser', LItemsChanged, LNoOps, chbLaserDataEntered);
  if LItemsChanged then
    for i := 0 to FrgLaser.GetCount(False) - 1 do begin
      var LDbOp := '';
      if (FrgLaser.GetRawValueI('id_bcad_nomencl', i) = 0) or (FrgLaser.GetRawValueI('batch_count', i) = 0) or (FrgLaser.GetRawValueF('batch_duration', i) = 0) then begin
        if FrgLaser.GetRawValueI('id', i) < MY_IDS_INSERTED_MIN then
          LDbOp := 'd';
      end
      else if FrgLaser.GetRawValueI('id', i) >= MY_IDS_INSERTED_MIN then begin
        LDbOp := 'i';
      end
      else if
        (FrgLaser.GetRawValue('id_bcad_nomencl', i) <> FLaserItems.G(i, 'id_bcad_nomencl')) or
        (FrgLaser.GetRawValue('batch_count', i) <> FLaserItems.G(i, 'batch_count')) or
        (FrgLaser.GetRawValue('batch_duration', i) <> FLaserItems.G(i, 'batch_duration'))
      then begin
        LDbOp := 'u';
      end;
      if LDbOp <> '' then
        Q.QSave(LDbOp,
          'pnl_ops_laser_items', '',
          'id$i;id_ops_laser$i;id_bcad_nomencl$i;batch_count$i;batch_duration$f',
          [FrgLaser.GetRawValueI('id', i), FLaserData.G('id'), FrgLaser.GetRawValueI('id_bcad_nomencl', i), FrgLaser.GetRawValueI('batch_count', i), FrgLaser.GetRawValueF('batch_duration', i)]
        );
    end;
end;

procedure TFrmPWedtPlnOps.SaveDrilling;
//сохраним данные по сверловке
begin
  SaveTable(FDrillingData, 'pnl_ops_Drilling', FDrillingData.GN('qnt_panels_with_drill').AsInteger <> nedtDrilling.Value, nedtDrilling.Value = 0, chbDrillingDataEntered);
  if FDrillingData.G('qnt_panels_with_drill').AsInteger <> nedtDrilling.Value then begin
    Q.QSave('u', 'pnl_ops_drilling', '-', 'id$i;qnt_panels_with_drill$i', [FDrillingData.G('id'), nedtDrilling.Value]);
    if AddParam = THIS_IS_STD_ITEM then
      Q.QExecSql('update or_std_items set is_xml_loaded = 1, qnt_panels_w_drill = :qnt$i where id = :id$i', [nedtDrilling.Value, ID])
    else
      Q.QExecSql('update or_std_items set is_xml_loaded = 1, qnt_panels_w_drill = :qnt$i where id = :id$i', [nedtDrilling.Value, ID]);
  end;
end;

procedure TFrmPWedtPlnOps.SetCaption;
//информация по объекту, для которого задаем операции, в верхней панели
begin
  Cth.AlignControls(pnlTop, [], False);
  lblCaption1.SetCaption2('Производственные операции для ' + S.IIf(AddParam = THIS_IS_STD_ITEM, 'стандартного изделия:', 'изделия заказа:'));
  lblCaption2.SetCaption2('$FF0000' + F.GetProp('parent_name') + '$000000  -  $FF0000' + F.GetProp('name'));
end;

procedure TFrmPWedtPlnOps.LoadFromXml;
//загружаем файл xml
var
  PanelsWDrilling: Integer;
begin
  MyData.OpenDialog1.Options := [ofFileMustExist];
  MyData.OpenDialog1.Filter := 'Файлы XML (*.xml)|*.xml';
  if not MyData.OpenDialog1.Execute then
    Exit;
  Orders.ParseOrItemXML(MyData.OpenDialog1.Files[0], PanelsWDrilling);
  Cth.SetControlValue(nedtDrilling, PanelsWDrilling);
  {if AIdOrItem <> null then
    Q.QExecSql('update order_items set is_xml_loaded = 1, qnt_panels_w_drill = :qnt$i where id = :id$i', [PanelsWDrilling, AIdOrItem]);
  if AIdStdItem <> null then
    Q.QExecSql('update or_std_items set is_xml_loaded = 1, qnt_panels_w_drill = :qnt$i where id = :id$i', [PanelsWDrilling, AIdStdItem]);}
end;

procedure TFrmPWedtPlnOps.LoadBoardsNomenclListFromEstimate;
//загрузка списка плитныых материалов из сметы
begin
  FEstimateBoardsNomencl := Q.QLoad('select name, id_name from v_estimate where ' +  S.IIf(AddParam = THIS_IS_STD_ITEM, 'id_std_item', 'id_order_item') + ' = :id$i and id_group = :id_group$i', [ID, cBcadGroupPlit]);
end;

procedure TFrmPWedtPlnOps.SetOpsCaption(ARec: TNamedArr; ALabel: TLabel; ACheckBox: TDBCheckBoxEh);
//лейбл информации по указанной операцции
begin
  ALabel.SetCaptionAr2([
    S.IIf(ACheckBox.Checked, '$FF00FFДанные введены' +
    S.IIf(ARec.GN('dt_data_entered') <> null, ' ' + ARec.GN('dt_data_entered').AsDatetimeStr, '.'),
    '$0000FFДанные не введены!'),
    '$000000',
    S.IIFStr(ARec.GN('dt_changed') <> null, '  Изменены $FF0000' + ARec.GN('dt_changed').AsDatetimeStr)
  ]);
  SetAllDataEnteredCaption;
end;

procedure TFrmPWedtPlnOps.SetAllDataEnteredCaption;
begin
  if chbPaintingDataEntered.Checked and chbCncDataEntered.Checked and chbLaserDataEntered.Checked and chbDrillingDataEntered.Checked then
    lblAllDataEntered.SetCaption2('$44FF00Все данные введены.')
  else
    lblAllDataEntered.SetCaption2('$0000FFНе все данные введены!');
end;

procedure TFrmPWedtPlnOps.ControlOnChange(Sender: TObject);
//действвия при изменении контролов
//(в данном случае галок Данные введены)
begin
  if Sender = chbPaintingDataEntered then
    SetOpsCaption(FPaintingData, lblPainting, chbPaintingDataEntered)
  else if Sender = chbCncDataEntered then
    SetOpsCaption(FCncData, lblCnc, chbCncDataEntered)
  else if Sender = chbLaserDataEntered then
    SetOpsCaption(FLaserData, lblLaser, chbLaserDataEntered)
  else if Sender = chbDrillingDataEntered then
    SetOpsCaption(FDrillingData, lblDrilling, chbDrillingDataEntered)
  else if (Sender = nedtDrilling) and (AddParam = THIS_IS_ORDER_ITEM) then
    nedtDrillingForAll.Value := nedtDrilling.Value * F.GetPropB('qnt');
end;

procedure TFrmPWedtPlnOps.EditButtonsClick(Sender: TObject; var Handled: Boolean);
//действия по кнопках в полях ввода
begin
  //кнопка загрузки хмл в поле ввода числа панелей со сверловкой
  if (TEditButtonControlEh(Sender).Owner = nedtDrilling) then
    LoadFromXml;
end;

procedure TFrmPWedtPlnOps.FrgCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
//при сохранении ячейки грида
begin
  //проставим статус изменения грида
  Fr.SetState(True, False, null);
end;

end.


