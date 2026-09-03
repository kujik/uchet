{
инфа из ИТМ
повторяющиеся артикулы
повторяющиеся наименования
папка Номенклатура из CAD
папка На удаление

в папке На удаление:
  по двойному клику просмотр, где номенклатура используется
  кнопка/пункт меню Удалить - удаление номенклатуры после запроса
}

unit uFrmOWItmInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Buttons, Vcl.StdCtrls, uFrDBGridEh, uString, uData;

type
  TFrmOWItmInfo = class(TFrmBasicMdi)
    pnlTop: TPanel;
    lblArtikul: TLabel;
    lblNomencl: TLabel;
    lblFromCAD: TLabel;
    lblToDel: TLabel;
    btnGo: TSpeedButton;
    pgcMain: TPageControl;
    tsArtikul: TTabSheet;
    tsNomencl: TTabSheet;
    tsFromCAD: TTabSheet;
    tsToDel: TTabSheet;
    FrgArtikul: TFrDBGridEh;
    FrgNomencl: TFrDBGridEh;
    FrgFromCAD: TFrDBGridEh;
    FrgToDel: TFrDBGridEh;
    procedure btnGoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    function Prepare: Boolean; override;
    procedure SetArtikulLabel;
    procedure SetNomenclLabel;
    procedure SetFromCadLabel;
    procedure SetToDelLabel;
    procedure DelNom(ADel: Boolean = False);
    procedure MoveNomToNewGroup(AIdGroup: Integer);
    procedure FrgArtikulButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure FrgNomenclButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure FrgFromCADButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure FrgFromCADOnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
    procedure FrgToDelButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure FrgToDelOnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
  public
    { Public declarations }
  end;

var
  FrmOWItmInfo: TFrmOWItmInfo;

implementation

{$R *.dfm}

uses

  uSettings,
  uForms,
  uDBOra,
  uMessages,
  uWindows,
  uOrders,

  uFrmBasicInput,
  uFrmODedtNomenclFiles,
  uFrmOGselItmGroupFromTree
  ;




procedure TFrmOWItmInfo.DelNom(ADel: Boolean = False);
//удаление номенклатуры (после запроса, где используется) из папки "На удаление"
var
  va: TVarDynArray;
  st: string;
  i: Integer;
  LIdNomencl: Integer;
  LTables: TVarDynArray;
begin
  LTables :=
    ['rs_clbill_spec',
    'nomencl_price_dynamics',
    'bcad_nom',
    'material_es',
    'namenom_supplier',
    'nomencl_units',
    'nom_pictures',
    'birki_spec',
    'mnf_nom_in_job',
    'mnf_spec_properties',
    'nome_sets',
    'price_list_spec',
    'actcomp_spec',
    'act_spec_nomencl',
    'broke_bill_spec',
    'in_bill_spec',
    'inventory_spec',
    'mnf_plan_spec',
    //'mnf_struct_element', id_itemnomencl
    'move_bill_spec',
    'namenom_supplier',
    'nomenclatura_in_izdel',
    'nomencl_units',
    'nom_pictures',
    'off_minus_spec',
    'out_bill_spec',
    'post_plus_spec',
    'prime_cost_temp',
    'return_mnf_spec',
    'rs_bill_spec',
    'rs_clbill_spec',
    'stock',
    'zakaznomencl_spec',
    'demand_supplier_spec',
    'sp_schet_spec'
    ];
  if FrgToDel.GetCount(False) = 0 then Exit;
  LIdNomencl := FrgToDel.GetValueI('id_nomencl');
  va := Q.QCallStoredProc('P_Itm_DelNomencl', 'IdNom$i;ToDelete$i;NomUsed$so', [LIdNomencl, 0, -1]);
  st := 'Номенклатура'#13#10'"' + FrgToDel.GetValueS('name') + '"'#13#10 +
    S.IIf(S.NSt(va[2]) = '', 'нигде не используется.', 'используется:'#13#10#13#10 + va[2]);
  if ADel then begin
    if MyQuestionMessage(st + #13#10#13#10 + 'Удалить ее?') <> mrYes then Exit;
    Q.QBeginTrans(True); //в режиме пакета
    for i := 0 to High(LTables) do begin
      Q.QExecSql('delete from dv.' + LTables[i] + ' where id_nomencl = :id$i', [LIdNomencl]);
      if Q.PackageMode = -1 then Break;
    end;
    Q.QExecSql('delete from dv.nomenclatura where id_nomencl = :id$i', [LIdNomencl]);
    Q.QCommitOrRollback();
    FrgToDel.RefreshGrid;
    SetToDelLabel;
  end
  else MyInfoMessage(st);
end;

procedure TFrmOWItmInfo.MoveNomToNewGroup(AIdGroup: Integer);
//перенос номенклатуры (текущая строка грида "Номенклатура из CAD") в выбранную группу
var
  i, j: Integer;
  va1, va2: TVarDynArray;
begin
  if (AIdGroup = -1) or (FrgFromCAD.GetCount(False) = 0) then Exit;
  Q.QBeginTrans(True);
  //получим максимальное значение артикула (из тех, в котором последние 4 символа есть цифры)
  //нужно, так как иначе неверно работает, если были внесены позиции с артикулом вручную - счетчик в этом случае не обновляется
  va1 := Q.QLoadCol('select artikul from dv.nomenclatura where id_group = :id_group$i', [AIdGroup]);
  va2 := [];
  for i := 0 to High(va1) do begin
    j := StrToIntDef(S.Right(S.NSt(va1[i]), 4), -1);
    if j <> -1
      then va2 := va2 + [j];
  end;
  A.VarDynArraySort(va2, False);
  if Length(va2) = 0
    then i := 0 else i := va2[0];
  Q.QExecSQL('update dv.groups set count_item = :count_item$i where id_group = :id_group$i', [i, AIdGroup]);
  //адаптация кода из итм
  Q.QExecSQL(
    'update dv.nomenclatura set id_group=:id_group$i, artikul=(select dv.CreateArtikul(:id_group1$i) from dual) where id_nomencl=:id$i',
    [AIdGroup, AIdGroup, FrgFromCAD.GetValueS('id_nomencl')]
  );
  Q.QExecSQL('update dv.groups set count_item=nvl(count_item, 0) + 1 where id_group = :id_group$i', [AIdGroup]);
  Q.QCommitOrRollback;
  FrgFromCAD.RefreshGrid;
  SetFromCadLabel;
end;


procedure TFrmOWItmInfo.SetArtikulLabel;
//текст лейбла над окном по количеству найденных дублирующихся артикулов
begin
  if FrgArtikul.GetCount(False) = 0 then begin
    lblArtikul.Caption := 'Повторяющихся артикулов не найдено';
    lblArtikul.Font.Color := clWindowText;
  end
  else begin
    lblArtikul.Caption := 'Найдено ' + IntToStr(FrgArtikul.GetCount(False)) + ' повторяющихся артикулов!';
    lblArtikul.Font.Color := clRed;
  end;
end;

procedure TFrmOWItmInfo.SetNomenclLabel;
//текст лейбла по количеству найденных дублирующихся наименований
begin
  if FrgNomencl.GetCount(False) = 0 then begin
    lblNomencl.Caption := 'Повторяющихся наименований не найдено';
    lblNomencl.Font.Color := clWindowText;
  end
  else begin
    lblNomencl.Caption := 'Найдено ' + IntToStr(FrgNomencl.GetCount(False)) + ' повторяющихся наименований!';
    lblNomencl.Font.Color := clRed;
  end;
end;

procedure TFrmOWItmInfo.SetFromCadLabel;
//текст лейбла по количеству номенклатуры в папке "Номенклатура из CAD"
begin
  if FrgFromCAD.GetCount(False) = 0 then begin
    lblFromCAD.Caption := 'Папка "' + Group_NomFromCAD_Name + '" пуста';
    lblFromCAD.Font.Color := clWindowText;
  end
  else begin
    lblFromCAD.Caption := 'В папке "' + Group_NomFromCAD_Name + '" ' + IntToStr(FrgFromCAD.GetCount(False)) + ' наименований!';
    lblFromCAD.Font.Color := clBlue;
  end;
end;

procedure TFrmOWItmInfo.SetToDelLabel;
//текст лейбла по количеству номенклатуры в папке "На удаление"
begin
  if FrgToDel.GetCount(False) = 0 then begin
    lblToDel.Caption := 'Папка "' + Group_NomToDel_Name + '" пуста';
    lblToDel.Font.Color := clWindowText;
  end
  else begin
    lblToDel.Caption := 'В папке "' + Group_NomToDel_Name + '" ' + IntToStr(FrgToDel.GetCount(False)) + ' наименований!';
    lblToDel.Font.Color := clBlue;
  end;
end;


procedure TFrmOWItmInfo.FrgArtikulButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//кнопки грида "Артикулы"
begin
  if Tag = mbtRefresh then begin
    Handled := True;
    Fr.RefreshGrid;
    SetArtikulLabel;
  end;
end;

procedure TFrmOWItmInfo.FrgNomenclButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//кнопки грида "Наименования"
begin
  if Tag = mbtRefresh then begin
    Handled := True;
    Fr.RefreshGrid;
    SetNomenclLabel;
  end;
end;

procedure TFrmOWItmInfo.FrgFromCADButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//кнопки/пункты меню грида "Номенклатура из CAD"
var
  va, va0: TVarDynArray;
begin
  if Tag = mbtRefresh then begin
    Handled := True;
    Fr.RefreshGrid;
    SetFromCadLabel;
  end
  else if Tag = mbtCustom_MoveToGroup then begin
    Handled := True;
    if Fr.GetCount(False) > 0
      then MoveNomToNewGroup(FrmOGselItmGroupFromTree.ShowDialog(Self, null));
  end
  else if Tag = mbtCustom_SupplierNom then begin
    Handled := True;
    Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView),
      Fr.GetValue('id_nomencl'),
      VararrayOf([Fr.GetValueS('name'), ''])
    );
  end
  else if Tag = mbtAttach then begin
    Handled := True;
    TFrmODedtNomenclFiles.ShowDialog(Self, Fr.GetValue('id_nomencl'));
  end
  else if Tag = mbtCustom_PriceCheck then begin
    Handled := True;
    //зададим контрольную цену номенклатуры
    if Fr.GetCount(False) = 0 then Exit;
    //получим текущую
    va0 := Q.QLoadRow('select max(price_check) from spl_itm_nom_props where id = :id$i', [Fr.GetValue('id_nomencl')]);
    //диалог ввода (число с 2 знаками п.з. или пустое поле)
    if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '', 200, 100,
        [[cntNEdit, 'Контрольная цена', '0:100000000:2:+', 80]],  //в позиции 3 не ставим N, тк не нужно требовать непустого значения
        va0, va,
        [['Контрольная цена']],
         nil
      ) < 0 then Exit;
    //сохраним
    Q.QCallStoredProc('P_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.GetValue('id_nomencl'), 7, S.NullIfEmpty(va[0])]));
  end;
end;

procedure TFrmOWItmInfo.FrgFromCADOnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//по даблклику в гриде "Номенклатура из CAD" - открываем диалог ввода номенклатуры поставщиков
begin
  Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView),
    Fr.GetValue('id_nomencl'),
    VararrayOf([Fr.GetValueS('name'), ''])
  );
end;

procedure TFrmOWItmInfo.FrgToDelButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//кнопки/пункты меню грида "На удаление"
begin
  if Tag = mbtRefresh then begin
    Handled := True;
    Fr.RefreshGrid;
    SetToDelLabel;
  end
  else if Tag = mbtDelete then begin
    Handled := True;
    DelNom(True);
  end;
end;

procedure TFrmOWItmInfo.FrgToDelOnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//по даблклику в гриде "На удаление" - покажем, где используется номенклатура (без удаления)
begin
  DelNom(False);
end;

procedure TFrmOWItmInfo.btnGoClick(Sender: TObject);
//обновление данных сразу во всех гридах
begin
  FrgArtikul.RefreshGrid;
  SetArtikulLabel;
  FrgNomencl.RefreshGrid;
  SetNomenclLabel;
  FrgFromCAD.RefreshGrid;
  SetFromCadLabel;
  FrgToDel.RefreshGrid;
  SetToDelLabel;
end;

procedure TFrmOWItmInfo.FormClose(Sender: TObject; var Action: TCloseAction);
//сохраним позицию окна
begin
  inherited;
  Settings.SaveWindowPos(Self, FormDoc);
end;


function TFrmOWItmInfo.Prepare: Boolean;
//начальная подготовка формы - настройка всех 4 гридов и загрузка данных
begin
  Result := False;
  Caption := 'Информация по ИТМ';
  BorderStyle := bsSizeable;
  if not inherited then
    Exit;
  Cth.SetSpeedButton(btnGo, mybtRefresh, True);

  FrgArtikul.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgArtikul.Opt.Caption := 'Артикулы';
  FrgArtikul.Opt.SetFields([
    ['artikul$s', 'Артикул', '400;w'],
    ['cnt$i', 'Количество', '80']
  ]);
  FrgArtikul.Opt.SetGridOperations('');
  FrgArtikul.Opt.SetButtons(1, [[mbtRefresh]]);
  FrgArtikul.OnButtonClick := FrgArtikulButtonClick;
  FrgArtikul.SetInitData(
    'select artikul, cnt from (select n.artikul, count(1) as cnt from dv.nomenclatura n ' +
    'where n.id_nomencltype>=0 and n.artikul is not null group by n.artikul) where cnt > 1 order by artikul',
    []
  );
  FrgArtikul.Prepare;
  FrgArtikul.RefreshGrid;
  FrgArtikul.GridReadOnly := True;
  SetArtikulLabel;

  FrgNomencl.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgNomencl.Opt.Caption := 'Наименования';
  FrgNomencl.Opt.SetFields([
    ['name$s', 'Наименование', '400;w'],
    ['cnt$i', 'Количество', '80']
  ]);
  FrgNomencl.Opt.SetGridOperations('');
  FrgNomencl.Opt.SetButtons(1, [[mbtRefresh]]);
  FrgNomencl.OnButtonClick := FrgNomenclButtonClick;
  FrgNomencl.SetInitData(
    'select name, cnt from (select n.name, count(1) as cnt from dv.nomenclatura n ' +
    'where n.id_nomencltype>=0 group by n.name) where cnt > 1 order by name',
    []
  );
  FrgNomencl.Prepare;
  FrgNomencl.RefreshGrid;
  FrgNomencl.GridReadOnly := True;
  SetNomenclLabel;

  FrgFromCAD.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgFromCAD.Opt.Caption := 'Номенклатура из CAD';
  FrgFromCAD.Opt.SetFields([
    ['id_nomencl$i', '_id_nomencl', '40'],
    ['name$s', 'Наименование', '400;w']
  ]);
  FrgFromCAD.Opt.SetGridOperations('');
  FrgFromCAD.Opt.SetButtons(1, [
    [mbtRefresh], [],
    [mbtCustom_MoveToGroup], [-mbtCustom_SupplierNom], [-mbtCustom_PriceCheck, User.Role(rOr_Other_R_MinRemains_chPriceCheck)], [-mbtAttach]
  ]);
  FrgFromCAD.OnButtonClick := FrgFromCADButtonClick;
  FrgFromCAD.OnDbClick := FrgFromCADOnDbClick;
  FrgFromCAD.SetInitData(
    'select id_nomencl, name from dv.nomenclatura n where n.id_group = :id_group$i order by name',
    [Group_NomFromCAD_Id]
  );
  FrgFromCAD.Prepare;
  FrgFromCAD.RefreshGrid;
  FrgFromCAD.GridReadOnly := True;
  SetFromCadLabel;

  FrgToDel.Options := [myogIndicatorColumn, myogHasStatusBar];
  FrgToDel.Opt.Caption := 'На удаление';
  FrgToDel.Opt.SetFields([
    ['id_nomencl$i', '_id_nomencl', '40'],
    ['name$s', 'Наименование', '400;w']
  ]);
  FrgToDel.Opt.SetGridOperations('');
  FrgToDel.Opt.SetButtons(1, [[mbtRefresh], [], [mbtDelete]]);
  FrgToDel.OnButtonClick := FrgToDelButtonClick;
  FrgToDel.OnDbClick := FrgToDelOnDbClick;
  FrgToDel.SetInitData(
    'select id_nomencl, name from dv.nomenclatura n where n.id_group = :id_group$i order by name',
    [Group_NomToDel_Id]
  );
  FrgToDel.Prepare;
  FrgToDel.RefreshGrid;
  FrgToDel.GridReadOnly := True;
  SetToDelLabel;

  pgcMain.ActivePageIndex := 0;
  Result := True;
end;


end.
