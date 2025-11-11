{
инфа из ИТМ
повторяющиеся артикулы
повторяющиеся наименования
папка Номенклатура из CAD
папка На удаление

в папке На удаление:
  по двойному клику просмотр, где номенклатура используется
  по F8 удаление номенклатуры после запроса
}

unit D_ItmInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI, Vcl.ExtCtrls, Vcl.ComCtrls, System.Types,
  Vcl.Buttons, Vcl.StdCtrls, DBCtrlsEh, ToolCtrlsEh,
  DBGridEhToolCtrls, MemTableDataEh, Data.DB, MemTableEh,
  GridsEh, DBAxisGridsEh, DBGridEh, Data.Win.ADODB, DataDriverEh,
  ADODataDriverEh, Vcl.Menus, EhLibVclUtils, DBGridEhGrouping, DynVarsEh,
  Vcl.Mask;

type
  TDlg_ItmInfo = class(TForm_MDI)
    pnl_Top: TPanel;
    Pc_1: TPageControl;
    ts_Artikul: TTabSheet;
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    ts_Nomencl: TTabSheet;
    DBGridEh2: TDBGridEh;
    DBEditEh1: TDBEditEh;
    ADODataDriverEh1: TADODataDriverEh;
    ADODataDriverEh2: TADODataDriverEh;
    DataSource2: TDataSource;
    MemTableEh2: TMemTableEh;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    ts_FromCAD: TTabSheet;
    ts_ToDel: TTabSheet;
    ADODataDriverEh3: TADODataDriverEh;
    DataSource3: TDataSource;
    MemTableEh3: TMemTableEh;
    ADODataDriverEh4: TADODataDriverEh;
    DataSource4: TDataSource;
    MemTableEh4: TMemTableEh;
    DBGridEh3: TDBGridEh;
    DBEditEh2: TDBEditEh;
    DBGridEh4: TDBGridEh;
    DBEditEh3: TDBEditEh;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    Bt_Go: TSpeedButton;
    Pm_3: TPopupMenu;
    procedure Bt_GoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBGridEh4DblClick(Sender: TObject);
    procedure DBGridEh4KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGridEh3DblClick(Sender: TObject);
  private
    { Private declarations }
    function Prepare: Boolean; override;
    procedure GetData;
    procedure DelNom(Del: Boolean = False);
    procedure MenuClick(Sender: TObject); virtual;
    procedure MoveNomToNewGroup(AIdNomencl, AIdGroup: Integer);
  public
    { Public declarations }
  end;

var
  Dlg_ItmInfo: TDlg_ItmInfo;

implementation

{$R *.dfm}

uses

  uSettings,
  uForms,
  uDBOra,
  uString,
  uData,
  uMessages,
  uWindows,
  uOrders,

  uFrmBasicInput,
  uFrmODedtNomenclFiles,
  F_TestTree
  ;





procedure TDlg_ItmInfo.DelNom(Del: Boolean = False);
var
  va: TVarDynArray;
  st: string;
  i, j, res: Integer;
  tables: TVarDynArray;
begin
  inherited;
  tables:=
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
  if  MemTableEh4.RecordCount = 0 then Exit;
  va:=Q.QCallStoredProc('P_Itm_DelNomencl','IdNom$i;ToDelete$i;NomUsed$so', [MemTableEh4.Fields[0].AsInteger, 0, -1]);
  st:= 'Номенклатура'#13#10'"' + MemTableEh4.Fields[1].AsString + '"'#13#10+
    S.IIf(S.NSt(va[2]) = '', 'нигде не используется.', 'используется:'#13#10#13#10 + va[2]);
  if Del
    then begin
      if MyQuestionMessage(st + #13#10#13#10 + 'Удалить ее?') <> mrYes then Exit;
      res:=0;
      Q.QBeginTrans(True); //в режиме пакета
      for i:=0 to High(tables) do begin
        Q.QExecSql('delete from dv.' + tables[i] + ' where id_nomencl = :id$i', [MemTableEh4.Fields[0].AsInteger]); //, False
        if Q.PackageMode = -1 then Break;
      end;
      Q.QExecSql('delete from dv.nomenclatura where id_nomencl = :id$i', [MemTableEh4.Fields[0].AsInteger]);
      Q.QCommitOrRollback();
      MemTableEh4.Refresh;
    end
    else MyInfoMessage(st);
end;

procedure TDlg_ItmInfo.MoveNomToNewGroup(AIdNomencl, AIdGroup: Integer);
{
if IdGroup <> '' then
  begin
    for i:= 0 to ReestrNomencl.SelectedCount - 1 do
    begin
      IDStr := ReestrNomencl.SelectedNodes[i].Strings[0];
      Artikul_ := GetValue('select CreateArtikul(' + IdGroup + ') from dual');
      ExecuteSQL('update nomenclatura set id_group=' + IdGroup +
        ', artikul=' + QuotedStr(Artikul_) + ' where id_nomencl=' + IDStr);
      ExecuteSQL('update groups g set g.count_item=nvl(g.count_item, 0) + 1 where g.id_group=' + IdGroup);
    end;

    bRefresh.Click;
  end;}
var
  i, j: Integer;
  va1, va2: TVarDynArray;
begin
  if (AIdGroup = -1)or(MemTableEh3.RecordCount = 0) then Exit;
  Q.QBeginTrans(True);
  //получим максимальное значение артикула (из тех, в котором последние 4 символа есть цифры)
  //нужно, так как иначе неверно работает, если были внесены позиции с артикулом вручную - счетчик в этом случае не обновляется
  va1:= Q.QLoadToVarDynArrayOneCol('select artikul from dv.nomenclatura where id_group = :id_group$i', [AIdGroup]);
  va2:=[];
  for i:= 0 to High(va1) do begin
    j:= StrToIntDef(S.Right(S.NSt(va1[i]), 4), -1);
    if j <> -1
      then va2:= va2 + [j];
  end;
  A.VarDynArraySort(va2, False);
  if Length(va2) = 0
    then i:= 0 else i:= va2[0];
  Q.QExecSQL('update dv.groups set count_item = :count_item$i where id_group = :id_group$i', [i, AIdGroup]);
  //адаптация кода из итм
  Q.QExecSQL(
    'update dv.nomenclatura set id_group=:id_group$i, artikul=(select dv.CreateArtikul(:id_group1$i) from dual) where id_nomencl=:id$i',
    [AIdGroup, AIdGroup, MemTableEh3.FieldByName('id_nomencl').AsString]
  );
  Q.QExecSQL('update dv.groups set count_item=nvl(count_item, 0) + 1 where id_group = :id_group$i', [AIdGroup]);
  Q.QCommitOrRollback;
  MemTableEh3.Refresh;
end;

procedure TDlg_ItmInfo.MenuClick(Sender: TObject);
var
  va, va0: TVarDynArray;
begin
  if TMenuItem(Sender).Tag = mbtCustom_MoveToGroup then begin
    if MemTableEh3.RecordCount > 0
      then MoveNomToNewGroup(0, Form_TestTree.ShowDialog(null));
  end
  else if TMenuItem(Sender).Tag = mbtCustom_SupplierNom then begin
    Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView),
      MemTableEh3.FieldByName('id_nomencl').Value,
      VararrayOf([MemTableEh3.FieldByName('name').AsString, ''])
    );
  end
  else if TMenuItem(Sender).Tag = mbtAttach then begin
    TFrmODedtNomenclFiles.ShowDialog(Self, MemTableEh3.FieldByName('id_nomencl').Value);
  end
  else if TMenuItem(Sender).Tag = mbtCustom_PriceCheck then begin
    //зададим контрольную цену номенклатуры
    if MemTableEh3.RecordCount = 0 then Exit;
      //олучим текущую
      va0:=Q.QSelectOneRow('select max(price_check) from spl_itm_nom_props where id = :id$i', [MemTableEh3.FieldByName('id_nomencl').Value]);
      //диалог ввода (число с 2 знаками п.з. или пустое поле
      if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '', 200, 100,
//      if Dlg_BasicInput.ShowDialog(Self, '', 200, 100, fEdit,
          [[cntNEdit, 'Контрольная цена', '0:100000000:2:+', 80]],  //в позиции 3 не ставим N, тк не нужно требовать непустго значения
          va0, va,
          [['Контрольная цена']],
           nil
        ) < 0 then Exit;
      //сохраним
      Q.QCallStoredProc('P_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([MemTableEh3.FieldByName('id_nomencl').Value, 7, S.NullIfEmpty(va[0])]));
  end;
end;


procedure TDlg_ItmInfo.Bt_GoClick(Sender: TObject);
begin
  inherited;
  GetData;
end;

procedure TDlg_ItmInfo.DBGridEh3DblClick(Sender: TObject);
//по даблклику в гриде Номенклатура из CAD - открываем диалог ввода номенклатуры поставщиков
begin
  inherited;
    Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView),
      MemTableEh3.FieldByName('id_nomencl').Value,
      VararrayOf([MemTableEh3.FieldByName('name').AsString, ''])
    );
end;

procedure TDlg_ItmInfo.DBGridEh4DblClick(Sender: TObject);
begin
  inherited;
  DelNom(False);
end;

procedure TDlg_ItmInfo.DBGridEh4KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Key = VK_F8 then
    DelNom(True);
end;

procedure TDlg_ItmInfo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Settings.SaveWindowPos(Self, FormDoc);
end;

procedure TDlg_ItmInfo.GetData;
begin
  ADODataDriverEh1.SelectSQL.Text:=
    'select artikul, cnt from (select n.artikul, count(1) as cnt from dv.nomenclatura n where n.id_nomencltype>=0 and n.artikul is not null group by n.artikul) where cnt > 1 order by artikul';
  MemTableEh1.Active:=False;
  MemTableEh1.Active:=True;
  DBGridEh1.AutoFitColWidths:=True;
//  DBGridEh1.Columns[0].Visible:=False;
  //Gh._SetDBGridEhCaptions(DBGridEh1,'artikul;cnt','Артикул;Количество');
  Gh.SetGridColumnsProperty(DBGridEh1, cptCaption, 'artikul;cnt','Артикул;Количество');
  DBGridEh1.AutoFitColWidths:=False;
//  Gh._SetDBGridEhWidths(DBGridEh1,'artikul;cnt', '400;80');
  Gh.SetGridColumnsProperty(DBGridEh1, cptWidth,'artikul;cnt', '400;80');
  DBGridEh1.AutoFitColWidths:=True;
  DbGridEh1.Enabled:=True;
  if MemTableEh1.RecordCount = 0 then begin
    lbl1.Caption:='Повторяющихся артикулов не найдено';
    lbl1.Font.Color:=clWindowText;
  end
  else begin
    lbl1.Caption:='Найдено ' + IntToStr(MemTableEh1.RecordCount) + ' повторяющихся артикулов!';
    lbl1.Font.Color:=clRed;
  end;

  ADODataDriverEh2.SelectSQL.Text:=
    'select name, cnt from (select n.name, count(1) as cnt from dv.nomenclatura n where n.id_nomencltype>=0 group by n.name) where cnt > 1 order by name';
  MemTableEh2.Active:=False;
  MemTableEh2.Active:=True;
  DBGridEh2.AutoFitColWidths:=True;
//  Gh._SetDBGridEhCaptions(DBGridEh2,'name;cnt','Наименование;Количество');
  Gh.SetGridColumnsProperty(DBGridEh2, cptCaption, 'name;cnt','Наименование;Количество');
  DBGridEh2.AutoFitColWidths:=False;
//  Gh._SetDBGridEhWidths(DBGridEh2,'name;cnt', '400;80');
  Gh.SetGridColumnsProperty(DBGridEh2, cptWidth,'name;cnt', '400;80');
  DBGridEh2.AutoFitColWidths:=True;
  DbGridEh2.Enabled:=True;
  if MemTableEh2.RecordCount = 0 then begin
    lbl2.Caption:='Повторяющихся наименований не найдено';
    lbl2.Font.Color:=clWindowText;
  end
  else begin
    lbl2.Caption:='Найдено ' + IntToStr(MemTableEh2.RecordCount) + ' повторяющихся наименований!';
    lbl2.Font.Color:=clRed;
  end;

  ADODataDriverEh3.SelectSQL.Text:=
    'select id_nomencl, name from dv.nomenclatura n where n.id_group = :id_group order by name';
  ADODataDriverEh3.SelectCommand.Parameters.ParamByName('id_group').Value:=Group_NomFromCAD_Id;
  ADODataDriverEh3.SelectCommand.Parameters.ParamByName('id_group').DataType:=ftInteger;
  MemTableEh3.Active:=False;
  MemTableEh3.Active:=True;
  DBGridEh3.AutoFitColWidths:=True;
//  Gh._SetDBGridEhCaptions(DBGridEh3,'name','Наименование');
  Gh.SetGridColumnsProperty(DBGridEh3, cptCaption,'name','Наименование');
  DBGridEh3.FindFieldColumn('id_nomencl').Visible:=False;
  DBGridEh3.AutoFitColWidths:=False;
  DBGridEh3.AutoFitColWidths:=True;
  DbGridEh3.Enabled:=True;
  Pm_3.AutoPopup:=True;
  DBGridEh3.IndicatorOptions := DBGridEh3.IndicatorOptions + [gioShowRowSelCheckBoxesEh];
  DBGridEh3.options := DbGridEh3.options + [dgMultiSelect];
  DBGridEh3.optionseh := DBGridEh3.optionseh - [dghClearSelection];

  if MemTableEh3.RecordCount = 0 then begin
    lbl3.Caption:='Папка "' + Group_NomFromCAD_Name + '" пуста';
    lbl3.Font.Color:=clWindowText;
  end
  else begin
    lbl3.Caption:='В папке "' + Group_NomFromCAD_Name + '" ' + IntToStr(MemTableEh3.RecordCount) + ' наименований!';;
    lbl3.Font.Color:=clBlue;
  end;

  ADODataDriverEh4.SelectSQL.Text:=
    'select id_nomencl, name from dv.nomenclatura n where n.id_group = :id_group order by name';
  ADODataDriverEh4.SelectCommand.Parameters.ParamByName('id_group').Value:=Group_NomToDel_Id;
  ADODataDriverEh4.SelectCommand.Parameters.ParamByName('id_group').DataType:=ftInteger;
  MemTableEh4.Active:=False;
  MemTableEh4.Active:=True;
  DBGridEh4.AutoFitColWidths:=True;
//  Gh._SetDBGridEhCaptions(DBGridEh4,'name','Наименование');
  Gh.SetGridColumnsProperty(DBGridEh4,cptCaption,'name','Наименование');
  DBGridEh4.AutoFitColWidths:=False;
  DBGridEh4.Columns[0].Visible:=False;
  DBGridEh4.AutoFitColWidths:=True;
  DbGridEh4.Enabled:=True;
  if MemTableEh4.RecordCount = 0 then begin
    lbl4.Caption:='Папка "' + Group_NomToDel_Name + '" пуста';
    lbl4.Font.Color:=clWindowText;
  end
  else begin
    lbl4.Caption:='В папке "' + Group_NomToDel_Name + '" ' + IntToStr(MemTableEh4.RecordCount) + ' наименований!';;
    lbl4.Font.Color:=clBlue;
  end;
end;



function TDlg_ItmInfo.Prepare: Boolean;
var
  i: Integer;
  sda: TStringDynArray;
begin
  Result:=False;
  KeyPreview:=True;
  Caption:='Информация по ИТМ';
  BorderStyle:=bsSizeable;
  Cth.SetSpeedButton(Bt_Go, mybtRefresh, True);
  MemTableEh1.FetchAllOnOpen:=True;
  DbGridEh1.ReadOnly:=True;
  DbGridEh1.Enabled:=False;
  Gh.SetGridOptionsDefault(DbGridEh1);
  Gh.SetGridOptionsMain(DbGridEh1, True, True, True);

  MemTableEh2.FetchAllOnOpen:=True;
  DbGridEh2.ReadOnly:=True;
  DbGridEh2.Enabled:=False;
  Gh.SetGridOptionsDefault(DbGridEh2);
  Gh.SetGridOptionsMain(DbGridEh2, True, True, True);

  MemTableEh3.FetchAllOnOpen:=True;
  DbGridEh3.ReadOnly:=True;
  DbGridEh3.Enabled:=False;
  Gh.SetGridOptionsDefault(DbGridEh3);
  Gh.SetGridOptionsMain(DbGridEh3, True, True, True);
  Cth.CreateGridMenu(Self, Pm_3,
    [mybtCustom_MoveToGroup, mybtCustom_SupplierNom, mybtCustom_PriceCheck, mybtAttach],
    [True, True, User.Role(rOr_Other_R_MinRemains_chPriceCheck), True],
    MenuClick ,'3');
  DbGridEh3.PopupMenu:=Pm_3;

  MemTableEh4.FetchAllOnOpen:=True;
  DbGridEh4.ReadOnly:=True;
  DbGridEh4.Enabled:=False;
  Gh.SetGridOptionsDefault(DbGridEh4);
  Gh.SetGridOptionsMain(DbGridEh4, True, True, True);

  Pc_1.ActivePageIndex:=0;
  GetData;
  Result:=True;
end;


end.
