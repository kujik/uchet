{
диалог редактирования списка поставщиков для одной номенклатурной позиции снабжения (dv.namenom_supplier) -
несколько строк-поставщиков на одну номенклатуру, с параметрами (артикул у поставщика, коэффициент
пересчета единиц, признак основного поставщика и т.п.), сохраняемых одной транзакцией по кнопке "Ок".

(09.09.2026) диалог заменяет собой D_SuppliersMinPart.pas (построенный на промежуточном классе
F_MdiGridDialogTemplate.pas), который выводится из работы - переделан по образцу uFrmOGedtEstimate.pas
(диалог редактирования сметы), т.к. интерфейс - многострочный редактируемый грид с сохранением одной
транзакцией, а не форма редактирования одной записи (как у uFrmBasicDbDialog.pas). Логика перенесена как
есть: загрузка/сохранение по строкам, пик-листы поставщика и единицы измерения, кнопки открытия
соответствующих справочников, двойной клик по поставщику и по ссылке, блокировка редактирования строк
с usedcnt > 0 (кроме признака "основной"), взаимоисключающий признак "основной" (только одна строка).

СОХРАНЕНИЕ. Базовый класс (uFrmBasicEditabelGrid) не сохраняет данные грида автоматически - это всегда
делает сама форма-потомок в Save (см. общий комментарий в uFrmBasicEditabelGrid.pas). Поэтому Save здесь,
как и в старом D_SuppliersMinPart.pas, сам проходит по всем строкам грида (Frg1.GetRawCount/GetRawValue)
и вызывает Q.QSave для каждой добавленной/измененной строки, плюс удаляет строки по Frg1.EditData.IdsDeleted
и заранее одним UPDATE сбрасывает is_default у всех строк номенклатуры (чтобы основным остался только тот,
что отмечен в гриде) - все в одной транзакции. Новая (еще не сохраненная) строка отличается по айди -
у нее Frg1 уже проставил условный айди >= MY_IDS_INSERTED_MIN (см. uFrDBGridEh.pas), при сохранении такой
строки в БД передается null (значение id_pos_supplier назначит генератор/секвенция на стороне Q.QSave).
}
unit uFrmOGedtSupplierNomencl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid
  ;

type
  TFrmOGedtSupplierNomencl = class(TFrmBasicEditabelGrid)
    lblCaption: TLabel;
  private
    //загрузка (первичная и повторная, после добавления нового поставщика/ед.изм. через справочник) пик-листов
    //в столбцах "Поставщик" и "Ед.изм."
    procedure LoadPickLists;
    function  PrepareForm: Boolean; override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    function  Save: Boolean; override;
  public
  end;

var
  FrmOGedtSupplierNomencl: TFrmOGedtSupplierNomencl;

implementation

uses
  uWindows,
  ShellApi,
  uFrmDlgRItmSupplier
  ;

{$R *.dfm}

function TFrmOGedtSupplierNomencl.PrepareForm: Boolean;
var
  O: TFrDBGridEditOptions;
begin
  Caption := 'Поставщики для номенклатуры';
  //наименование номенклатуры, для которой редактируется список поставщиков - передается вызывающей формой
  //в AddParam[0]; AddParam[1] - наименование основной ед.изм. номенклатуры (см. Frg1CellValueSave)
  lblCaption.Caption := VarToStr(AddParam[0]);
  Frg1.Opt.SetFields([
    ['id_pos_supplier as id$i','_id','40'],
    ['id_supplier$i','Поставщик','250','e=1:100000000:0:N','bt=Поставщик'],
    ['name_pos as name$s','Наименование','300;w','e=0:1000'],
    ['artikul_sp$s','Артикул','100','e=0:50'],
    ['baseunitname as baseunit$s','Осн. ед. изм.','70'],
    ['id_base_unit as id_unit$i','Ед. изм.','100','e=1:100000000:0:N','bt=Единица измерения'],
    ['base_unit_k$f','Коэфф.','70','e=0.000000:1000000:5:N'],
    ['httplink$s','Ссылка','100','e=0:4000'],
    ['addcomment$s','Примечание','200;w','e=0:4000'],
    ['is_default$i','Осн.','50','chb','e'],
    ['usedcnt$i','Используется','60']
  ]);
  Frg1.Opt.SetTable('v_spl_namenom', 'dv.namenom_supplier');
  //редактирование доступно только в режиме fEdit (открытие в fView - для пользователей без прав, см. вызовы)
  Frg1.Opt.SetGridOperations(S.IIf(Mode = fEdit, 'uaid', ''));
  Frg1.Opt.SetWhere('where id_nomencl = :id$i');
  Frg1.SetInitData('*', [ID]);
  LoadPickLists;
  O.AlwaysVerifyAllTable := True;
  O.FieldsNoRepaeted := ['id_supplier'];
  Frg1.EditOptions := O;
  FOpt.InfoArray := [
    ['Просмотр поставщиков по текущей номенклатурной позиции.', Mode = fView],
    ['Редактирование поставщиков по текущей номенклатурной позиции.'#13#10#13#10+
     'Вы можете выбрать поставщиков для этой номенклатуры и задать параметры.'#13#10+
     'Для этого редактируйте или выбирайте из списка данные в соответствующих ячейках таблицы.'#13#10+
     'В полях "Поставщик" и "Ед.изм." можно нажать кнопку, по которой откроется соответствующий справочник,'#13#10+
     'где вы можете отредактировать данные или добавить новую позицию.'#13#10+
     ''#13#10+
     'Для добавления или удаления строк используйте кнопки внизу окна.'#13#10+
     '(строка не добавится, если хоть в одной строке списка есть ошибка!)'#13#10+
     ''#13#10+
     'Данные будут сохранены (если они корректны) при нажатии кнопки "Ок".'#13#10
    , Mode = fEdit]
  ];
  Result := inherited;
end;

procedure TFrmOGedtSupplierNomencl.LoadPickLists;
begin
  Frg1.Opt.SetPick('id_supplier',
    Q.QLoad('select k.name_org, k.id_kontragent from dv.kontragent k, dv.kontragent_pri_kon_post kp '+
      'where k.id_kontragent = kp.id_kontragent (+) order by k.name_org', []),
    True
  );
  Frg1.Opt.SetPick('id_unit',
    Q.QLoad('select name_unit, id_unit from dv.unit order by name_unit', []),
    True
  );
end;

procedure TFrmOGedtSupplierNomencl.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//клик по кнопке в ячейке "Поставщик"/"Ед.изм." - открывает соответствующий справочник для выбора;
//после возврата справочник мог измениться (добавлена новая позиция) - обновим пик-листы
begin
  Wh.SelectDialogResult := [];
  if TCellButtonEh(Sender).Hint = 'Поставщик' then begin
    Wh.ExecReference(myfrm_R_Itm_Suppliers, Self, [myfoDialog, myfoModal], ID);
    LoadPickLists;
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('id_supplier', Wh.SelectDialogResult[0]);
  end
  else if TCellButtonEh(Sender).Hint = 'Единица измерения' then begin
    Wh.ExecReference(myfrm_R_Itm_Units, Self, [myfoDialog, myfoModal], ID);
    LoadPickLists;
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('id_unit', Wh.SelectDialogResult[0]);
  end;
end;

procedure TFrmOGedtSupplierNomencl.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
//после ручного ввода данных в ячейку
var
  i: Integer;
begin
  //признак "основной" - взаимоисключающий: при установке в текущей строке сбросим его во всех остальных
  //(перенесено как есть из старого DBGridEh1ColumnsUpdateData)
  if (FieldName = 'is_default') and (Value = 1) then
    for i := 0 to Fr.GetRawCount - 1 do
      if i <> Fr.RecNo - 1 then
        Fr.SetValue('is_default', i, False, 0);
  //осн. ед. изм. номенклатуры - одна и та же для всех строк, передана вызывающей формой в AddParam[1]
  //(перенесено как есть из старого DBGridEh1ColumnsUpdateData - актуально в первую очередь для вновь
  //добавленных строк, у которых это поле еще не загружено из БД)
  Fr.SetValue('baseunit', AddParam[1]);
end;

procedure TFrmOGedtSupplierNomencl.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
//строки, уже где-то используемые (usedcnt > 0), редактировать нельзя - кроме признака "основной"
begin
  if (Fr.GetValueI('usedcnt') > 0) and (Fr.CurrField <> 'is_default') then
    ReadOnly := True;
end;

procedure TFrmOGedtSupplierNomencl.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  //двойной клик по поставщику - откроем карточку поставщика
  if (Fr.CurrField = 'id_supplier') and (Fr.GetValue('id_supplier') <> null) then
    TFrmDlgRItmSupplier.Show(Self, myfrm_Dlg_R_Itm_Suppliers, [myfoMultiCopy, myfoDialog, myfoSizeable],
      S.IIf(User.Role(rOr_R_Itm_Suppliers_Ch), fEdit, fView), Fr.GetValue('id_supplier'), null)
  //двойной клик по ссылке - откроем ее
  else if (Fr.CurrField = 'httplink') and (Fr.GetValueS('httplink') <> '') then
    ShellExecute(Application.Handle, 'Open', PChar(Fr.GetValueS('httplink')), nil, nil, SW_SHOWNORMAL);
end;

function TFrmOGedtSupplierNomencl.Save: Boolean;
var
  i: Integer;
  IdVal: Variant;
  qmode: string;
begin
  Q.QBeginTrans(True);
  for i := 0 to High(Frg1.EditData.IdsDeleted) do
    Q.QExecSql('delete from dv.namenom_supplier where id_pos_supplier = :id$i', [Frg1.EditData.IdsDeleted[i]]);
  Q.QExecSql('update dv.namenom_supplier set is_default = 0 where id_nomencl = :id$i', [ID]);
  for i := 0 to Frg1.GetRawCount - 1 do begin
    IdVal := Frg1.GetRawValue('id', i);
    qmode := S.IIf(IdVal >= MY_IDS_INSERTED_MIN, 'i',
      S.IIf(A.InArray(IdVal, Frg1.EditData.IdsChanged) or (Frg1.GetRawValueI('is_default', i) = 1), 'u', ''));
    if qmode <> '' then
      Q.QSave(qmode, 'dv.namenom_supplier', '',
        'id_pos_supplier$i;id_nomencl$i;id_supplier$i;name_pos$s;artikul_sp$s;id_base_unit$i;base_unit_k$f;is_default$i;addcomment$s;httplink$s',
        [ S.IIf(qmode = 'i', null, IdVal), ID, Frg1.GetRawValue('id_supplier', i),
          Frg1.GetRawValue('name', i), Frg1.GetRawValue('artikul_sp', i),
          Frg1.GetRawValue('id_unit', i), Frg1.GetRawValue('base_unit_k', i),
          Frg1.GetRawValue('is_default', i), Frg1.GetRawValue('addcomment', i),
          Frg1.GetRawValue('httplink', i) ]
        );
  end;
  Result := Q.PackageMode <> -1;
  Q.QCommitTrans;
end;

end.
