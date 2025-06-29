unit D_Order_Stages_Otk2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, MemTableDataEh, Data.DB,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh,
  DBAxisGridsEh, DBGridEh, MemTableEh, uLabelColors, Math,
  uData
  ;

type
  TDlg_Order_Stages_Otk2 = class(TForm_Normal)
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    lbl_Caption: TLabel;
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    Bt_Cancel: TBitBtn;
    Bt_Ok: TBitBtn;
    Img_Info: TImage;
    Bt_Add: TBitBtn;
    Bt_Del: TBitBtn;
    bvl1: TBevel;
    tmr1: TTimer;
    procedure DBGridEh1SumListAfterRecalcAll(Sender: TObject);
    procedure MemTableEh1AfterPost(DataSet: TDataSet);
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    procedure DBGridEh1KeyPress(Sender: TObject; var Key: Char);
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure Bt_OkClick(Sender: TObject);
    procedure Bt_DelClick(Sender: TObject);
    procedure Bt_AddClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  private
    { Private declarations }
    ID_Order, ID_Order_Item: Integer;
    Qnt: Extended;
    DtEditMin: TDateTime; //редактирование записей и ввод дат запрещен ранее этой даты
    DtEditCurr: TDateTime; //дата по умолчанию, за которую ставятся числа
    Changed: Boolean;
    InLoad: Boolean;
    DeletedItems: TVariantDynArray;
    procedure SetCaptionLabel;
    procedure AddRow;
    procedure DelRow;
    procedure RowDisable;
  public
    { Public declarations }
    function ShowDialog(aMode: TDialogType; aID_Order_Item, aID_Stage: Integer; aDtEditMin: TDateTime; aDtEditCurr: TDateTime): Boolean;
  end;

var
  Dlg_Order_Stages_Otk2: TDlg_Order_Stages_Otk2;

implementation

{$R *.dfm}

uses
  DateUtils,
  uSettings,
  uForms,
  uDBOra,
  uString,
  uMessages
  ;

procedure TDlg_Order_Stages_Otk2.RowDisable;
begin
  //блокируем изменение строк по датам, для которых (раньше вчера и больше текущей) недопустимо правами доступа
  MemTableEh1.ReadOnly:=(Mode <> fEdit)or
    (MemTableEh1.RecordCount >0)and(MemTableEh1.FieldByName('dt').Value <> null)and(MemTableEh1.FieldByName('dt').Value < DtEditMin);
end;

procedure TDlg_Order_Stages_Otk2.Bt_AddClick(Sender: TObject);
begin
  inherited;
  AddRow;
end;

procedure TDlg_Order_Stages_Otk2.Bt_DelClick(Sender: TObject);
begin
  inherited;
  DelRow;
end;

procedure TDlg_Order_Stages_Otk2.Bt_OkClick(Sender: TObject);
var
  i, r: Integer;
  qnt: extended;
  d, erra: TVarDynArray;
  err: Boolean;
  res: Integer;
  smode: Char;
begin
  Mth.Post(MemTableEh1);
  if not Changed then begin
//    MyWarningMessage('Данные не изменены!');
    ModalResult:=mrCancel;
    Exit;
  end;
  d:=[];
  qnt:=0;
  //проверим данные
  //здесь просто должно быть заполнено все, кроме комментария, и количество не быть отрицательным
  err:=False;
  r:=MemTableEh1.RecNo;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    if MemTableEh1.FieldByName('qnt').AsFloat = 0 then Continue;
    if ((MemTableEh1.FieldByName('dt').AsVariant = null) or (MemTableEh1.FieldByName('dt').AsDateTime > Date))
      then begin err:=True; Break; end;
      d:=d + [MemTableEh1.FieldByName('dt').AsDateTime];
    if MemTableEh1.FieldByName('qnt').AsFloat < 0
      then begin err:=True; Break; end;
    qnt:=qnt+MemTableEh1.FieldByName('qnt').AsFloat;
    if MemTableEh1.FieldByName('reason').AsString = ''
      then begin err:=True; Break; end;
  end;
  MemTableEh1.RecNo:=r;
  if err then begin
    MyWarningMessage('Данные некорректны!');
    ModalResult:=mrNone;
    Exit;
  end;
  //сохраним результат (в транзакции)
  //пока переписывавем все записи (не только измененные) - надо поправить
  res:=0;
  Q.QBeginTrans;
  MemTableEh1.DisableControls;
  //удалим то что удаляли по кнопке
  for i:=0 to High(DeletedItems) do begin
    res:=Q.QIUD('d', 'or_otk_rejected', '', 'id$i', [DeletedItems[i]]);
    if res < 0 then Break;
  end;
  if res >= 0 then
    //пройдем по таблице
    for i:=1 to MemTableEh1.RecordCount do begin
      MemTableEh1.RecNo:=i;
      smode:=#0;
      //с нулевым количеством, если это старая запись - удалим
      if (MemTableEh1.FieldByName('id').Value <> null)and(MemTableEh1.FieldByName('qnt').AsFloat = 0) then smode:= 'd';
      //старая с ненулевым - апдейт
      if (MemTableEh1.FieldByName('id').Value <> null)and(MemTableEh1.FieldByName('qnt').AsFloat <> 0) then smode:= 'u';
      //новая с ненулевым - инсерт
      if (MemTableEh1.FieldByName('id').Value = null)and(MemTableEh1.FieldByName('qnt').AsFloat <> 0) then smode:= 'i';
      res:=Q.QIUD(smode, 'or_otk_rejected', '', 'id$i;id_order_item$i;dt$d;qnt$f;id_reason$i;comm$s',
        [
          MemTableEh1.FieldByName('id').AsInteger,
          id_order_item,
          MemTableEh1.FieldByName('dt').AsDateTime,
          MemTableEh1.FieldByName('qnt').AsFloat,
          MemTableEh1.FieldByName('reason').Value,
          MemTableEh1.FieldByName('comm').AsString
        ]);
      if res < 0 then Break;
    end;
  Q.QCommitOrRollback(res >= 0);
  MemTableEh1.EnableControls;
  //если ошибка
  if res < 0 then begin
    MyWarningMessage('Не удалось сохранить данные!');
    ModalResult:=mrNone;
    Exit;
  end;
  ModalResult:=mrOk;
//  ModalResult:=mrnone;
end;

procedure TDlg_Order_Stages_Otk2.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//При обновлении данных редактированием
var
  NoErr:Boolean;
  i,j,i1: Integer;
  FieldName: string;
  dt: TDateTime;
  v:Variant;
  procedure SetFieldValue;
  begin
    if UseText then TColumnEh(Sender).Field.AsString := S.NSt(Value) else TColumnEh(Sender).Field.AsVariant := Value;
  end;
begin
  FieldName:= LowerCase(DBGridEh1.Columns[DBGridEh1.Col-1].Field.FieldName);
  if UseText then Value := Text else Value := Value;
  IF S.NSt(Value) = '' then Exit;
  //сбросим дату, если введена в недопустимом диапозоне
  //проверка на диапозон дат, недопустимых правами доступа
  if (FieldName = 'dt') and ((VarToDateTime(Value) > Date)or(VarToDateTime(Value) < DtEditMin))
    then Value:=null;
  //нельзя выбрать для одной строки количество, более общего количества изделий в слеше
  if (FieldName = 'qnt') and (S.NNum(Value) > Qnt)
    then Value:=null;
  SetFieldValue; //установим поле
  //TColumnEh(Sender).Field.AsVariant := Value;
  Mth.PostAndEdit(MemTableEh1);
//  Handled:=True;     //хаднлед не ставим!!!????
end;

procedure TDlg_Order_Stages_Otk2.AddRow;
begin
  MemTableEh1.Last;
  //добавим только если последняя строка заполнена
  if (MemTableEh1.RecordCount > 0) and
     ((MemTableEh1.FieldByName('dt').AsVariant=null)or
     (MemTableEh1.FieldByName('qnt').AsVariant=null)or
     (MemTableEh1.FieldByName('reason').AsVariant=null))
    then Exit;
  MemTableEh1.ReadOnly:=False;
  MemTableEh1.Append;
  MemTableEh1.FieldByName('dt').Value:=DtEditCurr;
end;


procedure TDlg_Order_Stages_Otk2.DelRow;
var
  oldid: Variant;
begin
  if MemTableEh1.RecordCount = 0 then Exit;
  //если недоступна на редактирование, то не трогаем
  RowDisable;
  if MemTableEh1.ReadOnly then Exit;
  if (MemTableEh1.FieldByName('id').Value <> null)and(VarToDateTime(MemTableEh1.FieldByName('id').Value) < DtEditMin) then Exit;
  oldid:=MemTableEh1.FieldByName('id').Value;
  if not((oldid = null)or(MyQuestionMessage('Удалить запись?') = mrYes)) then Exit;
  if oldid <> null then begin
    DeletedItems:=DeletedItems + [MemTableEh1.FieldByName('id').Value];
    Changed:=True;
  end;
  MemTableEh1.ReadOnly:=False;
  MemTableEh1.Delete;
  RowDisable;
end;


procedure TDlg_Order_Stages_Otk2.FormShow(Sender: TObject);
begin
  //если не корректировать здесь, то значек поднят вверх
  //если скорректировать так же в ShowDialog то
  //при первом запуске значек поднят вверх, про последующих (когда форма уже натроена - все нормально, победить не смог)
  //а коррекция здесь нормально работает
  inherited;
  Img_Info.top:=bt_ok.top+4;
end;

procedure TDlg_Order_Stages_Otk2.DBGridEh1KeyPress(Sender: TObject;
  var Key: Char);
begin
  //по нажатии клавиши + добавим в конец пустую строку
  //в DBGridEh1KeyDown нельзя это помещать, там символ плюс пролетает в имплейсэдитор, избежать этого не удалдось, также как и убрать его уже после появления в нем
  //(но можно сделать там напр по F2, которые в эдитор не улети)
  inherited;
  if Mode = fView then Exit;
  //не получваетя иначе отследить, что мы начали редактирование
  //так проверяем, что или текст в редакторе уже изменен, или курсов в редакторе не в самом начале строки
  if (DBGridEh1.InplaceEditor.SelStart <> 0)or(DBGridEh1.InplaceEditor.Modified) then Exit;
  if key = '+' then begin
    AddRow;
    Key:=#0;
  end;
  if ((key = '=')or(key = ' ')) and (not MemTableEh1.ReadOnly) then begin
    Key:=#0;  //это обязательно, иначе в редакторе появится симол =
    //в поле даты поставим текущую
    if DBGridEh1.Columns[DBGridEh1.Col-1].FieldName = 'dt' then MemTableEh1.FieldByName('dt').Value:=Date;
    //в поле количества дополним до полного
    if DBGridEh1.Columns[DBGridEh1.Col-1].FieldName = 'qnt'
      then MemTableEh1.FieldByName('qnt').Value:= Max(0, Qnt - (S.NNum(Gh.GetGridColumn(DBGridEh1, 'qnt').Footer.SumValue) - S.NNum(MemTableEh1.FieldByName('qnt').Value)));
    Mth.PostAndEdit(MemTableEh1);
  end;
end;

procedure TDlg_Order_Stages_Otk2.DBGridEh1SumListAfterRecalcAll(
  Sender: TObject);
begin
  inherited;
  SetCaptionLabel;
end;

procedure TDlg_Order_Stages_Otk2.MemTableEh1AfterPost(DataSet: TDataSet);
begin
  inherited;
  Changed:=True;
end;

procedure TDlg_Order_Stages_Otk2.MemTableEh1AfterScroll(DataSet: TDataSet);
begin
  inherited;
  if (InLoad)or(Mode = fView) then Exit;
  RowDisable;
end;


procedure TDlg_Order_Stages_Otk2.SetCaptionLabel;
var
  q: Extended;
begin
  TLabel(lbl_Caption).ResetColors;
  q:=Qnt - S.NNum(Gh.GetGridColumn(DBGridEh1, 'qnt').Footer.SumValue);
  if q  < 0 then q:=-1;
  if q  > 0 then q:= 1;
  TLabel(lbl_Caption).SetCaptionAr([
//  '$000000', 'Общее количество: ', S.Decode([q, 0, '$00FF00', 1, '$FF0000', -1, '$0000FF']), FloatToStr(Qnt) + ' шт.'
  '$000000', 'Общее количество: ', '$FF0000', FloatToStr(Qnt) + ' шт.'
]);
end;

procedure TDlg_Order_Stages_Otk2.tmr1Timer(Sender: TObject);
begin
  inherited;
  //если сделать удаление (похоже, что просто уход фокуса) с таблицы, в которой нет ни одной строки, то
  //сбрасывается режим редактирования, и в нее нельзя никак ввести данные
  //правим этим хаком
  if (not InLoad)and(MemTableEh1.Active)and(MemTableEh1.RecordCount = 0)and(Mode = fEdit)
    then MemTableEh1.Edit;
end;

function TDlg_Order_Stages_Otk2.ShowDialog(aMode: TDialogType; aID_Order_Item, aID_Stage: Integer; aDtEditMin: TDateTime; aDtEditCurr: TDateTime): Boolean;
var
  va: TVarDynArray;
  va2: TVarDynArray2;
  i,j: Integer;
begin
  InLoad:=True;
  Mode:=aMode;
  ID_Order_Item:= aID_Order_Item;
  DtEditMin:=aDtEditMin;
  DtEditCurr:=aDtEditCurr;
  DeletedItems:=[];

  Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
   ['Изменяйте данные по не принятым ОТК изделиям в этой таблице.'#13#10+
    'Ввод части данных может быть недоступным в зависимости от прав доступа (за ранние даты).'#13#10+
    'Для добавления строки и ввода данных за новую дату, нажмите соответствующую кнопку, или клавишу "+".'#13#10+
    'Для удаления записи нажмите кнопку Удалить, или же поставьте нулевое количество для этой даты.'#13#10+
    'Нажмите клавишу "=" или пробел для ввода сегодняшней даты, а в поле Количество будет введено все оставшееся непринятое количество по записи.'#13#10+
    'Для ввода даты доступен календарь, по клику в правойм углу ячейки, а для причины отказа ОТК при этом выпадет список причин.'#13#10+
    'Все поля, кроме комментария, обязательны для заполнения.'#13#10+
    'Если данные не верны, то программа не позволит их сохранить.'#13#10,
   Mode<>fView]
  ]), 20);

  //при первом запуске формы инициализируем грид
  if DBGridEh1.Columns.Count = 1 then begin
    MemTableEh1.DataDriver:=nil;
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.close;
    Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, '_id', 20, True);
    Mth.AddTableColumn(DBGridEh1, 'id_reason', ftInteger, 0, '_id_reason', 20, True);
    Mth.AddTableColumn(DBGridEh1, 'dt', ftDate, 0, 'Дата', 85, True);
    Mth.AddTableColumn(DBGridEh1, 'qnt', ftFloat, 0, 'Кол-во', 85, True);
    Mth.AddTableColumn(DBGridEh1, 'reason', ftString, 400, 'Причина неприемки', 250, True);
    Mth.AddTableColumn(DBGridEh1, 'comm', ftString, 4000, 'Комментарий', 200, True);
    MemTableEh1.CreateDataSet;
    DBGridEh1.Columns[2].AutoFitColWidth:=False;
    DBGridEh1.Columns[3].AutoFitColWidth:=False;
    DBGridEh1.Columns[4].AutoFitColWidth:=False;
    DBGridEh1.Columns[2].AlwaysShowEditButton:=True;
    DBGridEh1.Columns[4].AlwaysShowEditButton:=True;
    DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize, dghColumnMove] + [dghEnterAsTab] + [dghAutoFitRowHeight];
    DBGridEh1.AutoFitColWidths:=True;
    DBGridEh1.AllowedOperations:=[alopUpdateEh];
    //скроем айди
    DBGridEh1.Columns[0].Visible:=False;
    DBGridEh1.Columns[1].Visible:=DBGridEh1.Columns[0].Visible;
    for i:=0 to DBGridEh1.Columns.Count - 1 do
      if DBGridEh1.Columns[i].Visible
        then DBGridEh1.Columns[i].onUpdateData:=DBGridEh1ColumnsUpdateData;
    //Gh._SetDBGridEhSumFooter(DBGridEh1, 'qnt', '0');
    Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'qnt', '0');
    MinWidth:=700;
    MinHeight:=300;
  end;
  MemTableEh1.ReadOnly:=False;
  //получим список причин отказа -все активные, и те неактивные, по которым есть уже записи для данного изделия заказа
  Gh.GetGridColumn(DBGridEh1, 'reason').LimitTextToListValues:=False;
  va2:=Q.QLoadToVarDynArray2(
    'select name, id from ref_otk_reject_reasons where '+
    'active = 1 or (id in (select id_reason from or_otk_rejected where id_order_item = :id_order_item$i)) '+
    'order by name',
    [ID_Order_Item]
  );
  //заполним выпадающий список
  Gh.GetGridColumn(DBGridEh1, 'reason').PickList.Clear;
  Gh.GetGridColumn(DBGridEh1, 'reason').KeyList.Clear;
  for i:=0 to High(va2) do begin
    Gh.GetGridColumn(DBGridEh1, 'reason').PickList.Add(S.NSt(va2[i][0]));
    Gh.GetGridColumn(DBGridEh1, 'reason').KeyList.Add(S.NSt(va2[i][1]));
  end;
  Gh.GetGridColumn(DBGridEh1, 'reason').LimitTextToListValues:=True;

  //читаем данные в таблицу
  Q.QLoadToMemTableEh(
    'select id, dt, qnt, id_reason as reason, comm '+
    'from or_otk_rejected where id_order_item = :id_order_item$i order by dt',
    [ID_Order_Item],
    MemTableEh1,
    ''
  );
  MemTableEh1.Last;
  //if Mode <> fView then MemTableEh1.Append;
  //получим данные по изделию, с которым работаем
  va:= Q.QSelectOneRow('select nvl(qnt,0), id_order, dt_end from v_order_items where id = :id_order_item$i', [ID_Order_Item]);
  if va[0] = null then Exit;
  Qnt:=va[0];
  ID_Order:=va[1];
  //нельзя редактировать завершенный заказ
  if va[2] <> null then Mode:=fView;
  Cth.SetDialogForm(Self, Mode, 'Изделия, не принятые ОТК');
  SetCaptionLabel;
  Bt_Cancel.Cancel:=False;
  DBGridEh1.ReadOnly:=Mode <> fEdit;
  InLoad:=False;
  RowDisable;
  Changed:=False;
  if not MemTableEh1.ReadOnly then MemTableEh1.Edit;
  KeyPreview:=True;
  BorderStyle:=bsSizeable;
  //для автосохранения положения и размеров формы
  AutoSaveWindowPos:=True;
  //доп. кнопки
  Cth.SetBtn(Bt_Add, mybtAdd, True);
  Cth.SetBtn(Bt_Del, mybtDelete, True);
  Bt_Add.Visible:=Mode = fEdit;
  Bt_Del.Visible:=Mode = fEdit;
  bvl1.Visible:=Bt_Add.Visible;
  Result:=ShowModal = mrOk;
end;



end.
