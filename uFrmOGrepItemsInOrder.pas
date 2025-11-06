{
Формирует сводный отчет по составу заказов для заказов по указанному проекту за указанный период
}

unit uFrmOGrepItemsInOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions, Vcl.Mask,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmOGrepItemsInOrder = class(TFrmBasicGrid2)
    P_Left: TPanel;
    LbAddOrders: TLabel;
    CbProekt: TDBComboBoxEh;
    De1: TDBDateTimeEditEh;
    De2: TDBDateTimeEditEh;
    BtAddOrders: TBitBtn;
    BtDelProekt: TBitBtn;
    EOrIds: TDBEditEh;
    EOrNum: TDBEditEh;
    EOrCnt: TDBEditEh;
    CbCustomer: TDBComboBoxEh;
    procedure BtAddOrdersClick(Sender: TObject);
    procedure LbAddOrdersClick(Sender: TObject);
    procedure BtDelProektClick(Sender: TObject);
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);  override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure ReadSettings;
    procedure LoadProekts;
    procedure SetLb_AddOrders;
  public
  end;

var
  FrmOGrepItemsInOrder: TFrmOGrepItemsInOrder;

implementation

uses
  uWindows
  ;

{$R *.dfm}

function  TFrmOGrepItemsInOrder.PrepareForm: Boolean;
begin
  Caption:='Отчет по изделиям в заказах';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['slash','Слеш','100'],
    ['name','Изделие','300;h'],
    ['qnt','Кол-во','70'],
    ['orqnt','Кол-во заказов','70'],
    ['cntbyor','Кол-во на заказ','70']
  ]);
  Frg1.Opt.SetButtons(1,[[mbtGo],[],[mbtExcel],[mbtPrintGrid],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtGo]);
  Frg1.InfoArray:=[[
    'Отчет по заказам.'#13#10+
    'Формирует сводный отчет по составу заказов для заказов по указанному проекту за указанный период.'#13#10+
    '(для указания проекта регитр букв не важен, используйте символ * как синоним любого количества любых символов).'#13#10+
    'Список заданных проектов сохраняется, для удаления из списка нажмите кнопку "-"'#13#10+
    'Если выбран Заказчик, то список формируется только по его заказам, иначе для всех заказчиков.'#13#10+
    'Также можно добавить заказы, не входящие в заданный временной промежуток, которые также будут обрабатываться.'#13#10+
    'Вы также можете фильтровать и сортировать данные в таблице, распечатать отчет и выгрузить его в формате Excel.'#13#10
  ]];
  Frg1.Prepare;
  ReadSettings;
  Result := True;
end;

procedure TFrmOGrepItemsInOrder.BtAddOrdersClick(Sender: TObject);
var
  v: TVarDynArray;
  i, j:Integer;
  st1, st2: string;
  vv: Variant;
begin
  vv := VarArrayOf([AnsiUpperCase(StringReplace(CbProekt.Text, '*', '%', [])), EOrIds.Text, '', '']);
  Wh.ExecReference(myfrm_J_Orders_SEL_1, Self, [myfoDialog, myfoModal], vv);
  if Length(Wh.SelectDialogResult) = 0 then
    Exit;
  EOrIds.Text := '';
  EOrNum.Text := '';
  if Length(Wh.SelectDialogResult2) > 50 then
    MyWarningMessage('Выбрано слишшком много заказов!'#13#10'Будут добавлены только 50 первых заказов.');
  EOrCnt.Text := IntToStr(Min(Length(Wh.SelectDialogResult2), 50));
  for i := 0 to Min(High(Wh.SelectDialogResult2), 49) do begin
    EOrIds.Text := EOrIds.Text + S.IIFStr(Length(EOrIds.Text) = 0, '', ';') + IntToStr(Integer(Wh.SelectDialogResult2[i][0]));
    EOrNum.Text := EOrNum.Text + S.IIFStr(Length(EOrNum.Text) = 0, '', ';  ') + Wh.SelectDialogResult2[i][2];
  end;
  SetLb_AddOrders;
end;

procedure TFrmOGrepItemsInOrder.BtDelProektClick(Sender: TObject);
begin
  //удалим из таблицы-списка значение
  if (CbProekt.Text = '') then
    Exit;
  Q.QExecSql('delete from sn_orders_qntreport_proekts where name = :name', [CbProekt.Text], False);
  CbProekt.Text := '';
  LoadProekts;
end;

procedure TFrmOGrepItemsInOrder.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtGo then begin
    if (CbProekt.Text = '') or (not Cth.DteValueIsDate(De1)) or (not Cth.DteValueIsDate(De2)) then
      Exit;
    //вставим в таблицу списка используемых проектов, если там не существует еще такой записи
    //может быть ошибка, если различается регистром, тк там регистронезависимый индекс
    Q.QExecSql('insert into sn_orders_qntreport_proekts (name) ' +
      'select :name1 from dual where not exists (select 1 from sn_orders_qntreport_proekts where name = :name2)',
      [CbProekt.Text, CbProekt.Text], False
    );
    Fr.RefreshGrid;
    LoadProekts;
  end
  else inherited;
end;

procedure TFrmOGrepItemsInOrder.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
var
  ids: string;
begin
  if EOrIds.Text <> ''
    then ids:='or o.id=' + StringReplace(EOrIds.Text, ';', ' or o.id=', [rfReplaceAll])
    else ids:='';
    //Frg1.ADODataDriverEh1.SelectSQL.Text:=
    Frg1.Opt.SetSql(
      'select '+
      '  max(pos) as id, '+
      '  max(pos) as slash, '+
      '  max(name) as name, '+
      '  sum(qnt) as qnt, '+
      '  sum(orqnt) as orqnt, '+
      '  ceil(sum(qnt) / sum(orqnt)) as cntbyor '+
      'from ( '+
      'select '+
      '  i.pos, '+
      '  i.itemname as name, '+
      '  i.qnt, '+
      '  o.dt_beg, '+
      '  o.project, '+
      '  o.organization, '+
      '  o.id, '+
      '  1 as orqnt '+
      'from '+
      '  v_orders o, '+
      '  v_order_items i '+
      'where '+
      '  o.id = i.id_order '+
      '  and '+
      '  o.id_organization <> -1 '+
      '  and '+
      '  o.dt_beg >= :dt_beg$d '+
      '  and '+
      '  o.dt_beg <= :dt_end$d '+
      '  and '+
      '  (o.id_customer = :id_customer$i'+
        S.IIFStr(Cth.GetControlValue(CbCustomer).AsString = '', ' or o.id_customer > 0', '')+')'+
      '  and ('+
      '  (upper(o.project) like :proekt$s)'+
      ids +') '+
      'order by '+
      '  name, id '+
      ') '+
      'group by name '+
      'order by slash '
      );
   Frg1.SetSqlParameters('dt_beg$d;dt_end$d;proekt$s;id_customer$i',
    [
      S.IIf(Cth.DteValueIsDate(De1), De1.Value, IncMonth(Date, +1000)),
      S.IIf(Cth.DteValueIsDate(De2), De2.Value, IncMonth(Date, +1000)),
      AnsiUpperCase(StringReplace(CbProekt.Text,'*','%',[])),
      S.NNum(Cth.GetControlValue(CbCustomer))
    ]);
end;

procedure TFrmOGrepItemsInOrder.ReadSettings;
begin
  LoadProekts;
  Cth.SetControlValuesArr2(Self, Cth.DeSerializeControlValuesArr2(Settings.ReadProperty(FormDoc, 'Settings')));
  Cth.SetBtn(BtDelProekt, mybtDelete, True, '');
  Cth.SetBtn(BtAddOrders, mybtAdd, False, 'Добавить заказы');
  SetLb_AddOrders;
end;

procedure TFrmOGrepItemsInOrder.LbAddOrdersClick(Sender: TObject);
begin
  if StrToIntDef(EOrCnt.Text, 0) = 0 then
    Exit;
  MyInfoMessage(EOrNum.Text);
end;

procedure TFrmOGrepItemsInOrder.LoadProekts;
begin
  Q.QLoadToDBComboBoxEh('select name from sn_orders_qntreport_proekts order by name', [], CbProekt, cntComboL, 0);
  Q.QLoadToDBComboBoxEh('select name, id from ref_customers order by name',[], CbCustomer, cntComboLK0, 0);
end;

procedure TFrmOGrepItemsInOrder.SetLb_AddOrders;
begin
  LbAddOrders.Caption:=S.IIFStr(StrtoIntDef(EOrCnt.Text, 0) = 0,
    'Нет дополнительных заказов',
    EOrCnt.Text +
    ' дополнительн' + S.GetEnding(StrtoIntDef(EOrCnt.Text, 0),'ый','ых','ых') +
    ' заказ' + S.GetEnding(StrtoIntDef(EOrCnt.Text, 0),'','а','ов'));
end;



end.
