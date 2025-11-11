unit F_MdiGridDialogTemplate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, MemTableDataEh, Data.DB,
  ToolCtrlsEh, DBGridEhToolCtrls, Vcl.Mask,
  DBCtrlsEh, GridsEh, DBAxisGridsEh, DBGridEh, MemTableEh, uData,
  uForms, uString, uMessages, V_MDI, EhLibVclUtils, DBGridEhGrouping, DynVarsEh;

type
  TForm_MdiGridDialogTemplate = class(TForm_MDI)
    pnl_Buttons: TPanel;
    Img_Info: TImage;
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    chb_NoClose: TCheckBox;
    Bt_Add: TBitBtn;
    Bt_Del: TBitBtn;
    Bev_Buttons: TBevel;
    pnl_Bottom: TPanel;
    pnl_Top: TPanel;
    pnl_Client: TPanel;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    //MemTableEh
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    procedure MemTableEh1AfterPost(DataSet: TDataSet);
    //DbGridEh
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); virtual;
    procedure CellButtonClick(Sender: TObject; var Handled: Boolean); virtual;
    //Buttons
    procedure Bt_OKClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_DelClick(Sender: TObject);
    procedure Bt_AddClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
      AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
      var Params: TColCellParamsEh; var Processed: Boolean);
    procedure MemTableEh1AfterOpen(DataSet: TDataSet);
    procedure MemTableEh1AfterRefresh(DataSet: TDataSet);
    procedure DBGridEh1ColEnter(Sender: TObject);
  private
    { Private declarations }
  protected
    Ok: Boolean;                            //статус проверки
    InfoArr: TVarDynArray2;                 //массив посказок [[test1{False|True}],[text2...],]
    AddLast: Boolean;                       //по кнопке Добавить вставлять строку в конец таблицы (иначе в текущую позицию)
    AddIfNotempty: Boolean;                 //добавлять строку только если текущая (при AddLast последняя) заполнена полнгостью (кроме поля id)
    OneRowOnOpen: Boolean;                  //если грид открывается пустым в режиме редактрования или добалетния, то сразу добавить пустую строку
    AddRowIfFAddOnOpen: Boolean;            //если fAdd то сразу добавим строку в конец
    AllowEmptyTable: Boolean;               //При нажатии Ок считать пустую таблицу корректным результатом
    FieldsEmpty: string;                    //имена полей через запятую, которые допускаются пустыми всегда  /не используется
    FieldsService: string;                  //сервисные поля (обычно скрытые) по умолчанию тут "id"
    FieldsReadOnly: string;
    ColumnsVerifications: TVarDynArray;     //массив правил проверок значений столбцов
    FieldsNoRepaeted: string;               //строка полей через ;, повторов которых в строках грида быть не должно (проверяется в IsTableCorrect)
    IdFieldName: string;

    IdFieldPos: Integer;                    //номер поля ID в MemTable, -1 если его нет

    FieldNameCurr: string;
    RowId: Variant;


    DeletedIds: TVarDynArray;               //если в таблице есть поле 'id', то при удалении строки они помещаются в этот массив
                                            //в нем могут быть и айди впоследствии удаленных строк
    ChangedIds: TVarDynArray;               //если в данной строке был ручной ввод, то сюда помещается значение поля 'id' этой строки
                                            //но фактически изменений могло и не быть, то что данные остались такими же, не проверяется.

    IncorrectRowNo: Integer;
    IncorrectRowColumn: Integer;
    IncorrectRowMsg: string;



    function Prepare: Boolean; override;
    //добавляем или вставляем строку в грид
    //если AddLast то добавит в конец, иначе вставит
    //добавим только если текущая строка заполнена хотя бы частично (при AddIfNotempty)
    //и текущая строка корректна (данная процедура перекрывается и по умолчанию возвращает True:
    //при этом нужно еще блокировать перемещение из неверной строки, иначе блокирока по ней теряет смысл)
    procedure AddRow; virtual;
    //удаляем строку из грида
    procedure DelRow; virtual;
    procedure RowDisable; virtual;
    //создаем грид и мемтейбл (поля, настройки...). вызывается в Prepare, обязательно перекрывается.
    //если не вернет True, форма не будет показана
    function InitGrid: Boolean; virtual;
    //Дополнительные действия потомка, которые вызывается в Prepare.
    //если не вернет True, форма не будет показана
    function InitAdd: Boolean; virtual;
    //установить событие при вводе данных в ячейку грида вручную.
    procedure SetDBGridEh1ColumnsUpdateData;
    //Вернет True, если в строке хоть одно не сервисное поле не null (при путой таблице также True)
    function IsRowNotEmpty: Boolean; virtual;
    //Вернет труе, если строка заполнена корректно
    //по умолчанию проверяет в соотвествии с ColumnsVerify (если последний не задан то вернет True)
    //пустые строки игнорирует
    function IsRowCorrect: Boolean; virtual;
    //Вернет труе, если в таблице все строки верные
    //при этом пустые строки считаются верными
    function IsTableCorrect: Boolean;
    //Вернет труе, если в таблице нет строк либо она содержить лишь пустые строки
    function IsTableEmpty: Boolean;
    //должна проверить пересд сохранение правильность данных и вернуть сообщение,
    //которое выведетсяв окне при нажатии кнопки Ок после проверки, если есть ошибки;
    //если сообщение путое, то это признак верности данных
    //если оно равно "-", то данные неверны, но ничего не выведется,
    //если "*" выведется "Данные не корректны!"
    //по умолчанию проверяет корректнорсть IsTableCorrect, и если не AllowEmptyTable то IsTableEmpty
    function  VerifyBeforeSave: string; virtual;
    //вызывается при изменении текущей записи в мемтейбл или текущего столбца, или при обновлении данных строки/столбца
    procedure ChangeSelectedData; virtual;
    //вызывается при изменении текущей ячейки и изменяет возможность редактирования путем
    //установки свойств ReadOnly для всей таблицы
    procedure SetCellEditable; virtual;
    //возвращает True, если в таблице есть добавленные строки.
    function  IsTableAdded: Boolean;
    //сохраняет таблицу. должна быть перекрыта при необходимости сохранения при нажатии ок
    //вызовится если в таблице нет ошибочных данных (после VerifyBeforeSave)
    function  Save: Boolean; virtual;
  public
    { Public declarations }
  end;

var
  Form_MdiGridDialogTemplate: TForm_MdiGridDialogTemplate;

implementation

{$R *.dfm}

//Buttons///////////////////////////////////////////////////////////////////////

procedure TForm_MdiGridDialogTemplate.Bt_OKClick(Sender: TObject);
//клик по Ок, предполагает сохранение данных таблицы после проверки
var
  Msg: string;
begin
  inherited;
  //проверим таблицу
  Msg := VerifyBeforeSave;
  if Msg <> '' then begin
    MyWarningMessage(Msg, ['*Данные не корректны!', '-']);
    Exit;
  end;
  if not Save then begin
    MyWarningMessage('Не удалось сохранить данные!');
    Exit;
  end;
  Close;
end;

procedure TForm_MdiGridDialogTemplate.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TForm_MdiGridDialogTemplate.Bt_AddClick(Sender: TObject);
begin
  inherited;
  AddRow;
end;

procedure TForm_MdiGridDialogTemplate.Bt_DelClick(Sender: TObject);
begin
  inherited;
  DelRow;
end;


//MemTableEh///////////////////////////////////////////////////////////////////

procedure TForm_MdiGridDialogTemplate.MemTableEh1AfterOpen(DataSet: TDataSet);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.MemTableEh1AfterPost(DataSet: TDataSet);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.MemTableEh1AfterRefresh(
  DataSet: TDataSet);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.MemTableEh1AfterScroll(DataSet: TDataSet);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.DBGridEh1AdvDrawDataCell(
  Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh;
  const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
begin
  //inherited;
  Gh.DBGridEhAdvDrawDataCellDefault(Sender, Cell, AreaCell, Column, ARect, Params, Processed);
end;

procedure TForm_MdiGridDialogTemplate.DBGridEh1ColEnter(Sender: TObject);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//При обновлении данных редактированием
var
  NoErr: Boolean;
  i, j, i1: Integer;
  FieldName: string;
  dt: TDateTime;
  v: Variant;
  NewValue: Variant;
  b: Boolean;

  procedure SetFieldValue;
  begin
    if UseText then
      TColumnEh(Sender).Field.AsString := S.NSt(Value)
    else
      TColumnEh(Sender).Field.AsVariant := Value;
  end;

begin
  FieldName := LowerCase(DBGridEh1.Columns[DBGridEh1.Col - 1].Field.FieldName);
  Value := S.IIf(UseText, Text, Value);
  NewValue := Value;
  b := Gh.VeryfyCoumnEhValue(TColumnEh(Sender), Value, NewValue);
  if not b then
    NewValue := null;
  if NewValue = '' then
    NewValue := null;
  TColumnEh(Sender).Field.AsVariant := NewValue;
//  SetFieldValue; //установим поле
  Mth.PostAndEdit(MemTableEh1);
  if (IdFieldPos >= 0)and(MemTableEh1.FieldByName('id').Value <> null)and(not A.InArray(MemTableEh1.FieldByName('id').Value, ChangedIds))
    then ChangedIds:=ChangedIds + [MemTableEh1.FieldByName('id').Value];
  Handled := True;     //хаднлед не ставим!!!????
end;

procedure TForm_MdiGridDialogTemplate.CellButtonClick(Sender: TObject; var Handled: Boolean);
begin
 //
end;


//Subroutines///////////////////////////////////////////////////////////////////

procedure TForm_MdiGridDialogTemplate.ChangeSelectedData;
//здесь обрабатываем изменение активной строки, активной колонки, и просто обновления данных в ячейке грида\
//установим текущий столбец
//установим текущий айди
//установим доступность кнопок и пунктов меню
//установим редактируемость поля
var
  i: Integer;
  va: TmybtArr;
begin
  if not MemTableEh1.Active then
    Exit;
  //текущий столбец
  FieldNameCurr := LowerCase(DBGridEh1.Columns[DBGridEh1.Col - 1].Field.FieldName);
  //получим айди текущей записи
  if (IdFieldPos >= 0) then
    RowId := MemTableEh1.Fields[IdFieldPos].AsVariant;
  SetCellEditable;
end;

procedure TForm_MdiGridDialogTemplate.SetCellEditable;
//вызывается при изменении текущей ячейки и изменяет возможность редактирования путем
//установки свойств ReadOnly для всей таблицы
begin
  if Mode in [fView, fDelete] then Exit;
end;

function TForm_MdiGridDialogTemplate.Save: Boolean;
begin
  Result:=True;
end;

procedure TForm_MdiGridDialogTemplate.AddRow;
var
  i: Integer;
  b: Boolean;
begin
  //если добавляем в конец - перейдем на соседнюю строку
  if AddLast then
    MemTableEh1.Last;
  //добавим только если текущая строка заполнена хотя бы частично (при AddIfNotempty)
  //и текущая строка корректна (данная процедура перекрывается и по умолчанию возвращает True:
  //при этом нужно еще блокировать перемещение из неверной строки, иначе блокирока по ней теряет смысл)
  if not ((not AddIfNotempty or IsRowNotEmpty) and IsRowCorrect) then
    Exit;
  MemTableEh1.ReadOnly := False;
  MemTableEh1.Append;
end;

procedure TForm_MdiGridDialogTemplate.DelRow;
var
  oldid: Variant;
begin
//  MemTableEh1.ReadOnly := False;
{  if MemTableEh1.RecordCount = 0 then Exit;
  //если недоступна на редактирование, то не трогаем
  RowDisable;
  if MemTableEh1.ReadOnly then Exit;
  if (MemTableEh1.FieldByName('id').Value <> null)and(VarToDateTime(MemTableEh1.FieldByName('id').Value) < DtEditMin) then Exit;
  oldid:=MemTableEh1.FieldByName('id').Value;
  if not((oldid = null)or(MyQuestionMessage('Удалить запись?') = mrYes)) then Exit;
  if oldid <> null then begin
    DeletedItems:=DeletedItems + [MemTableEh1.FieldByName('id').Value];
    Changed:=True;
  end;         }
  if (IdFieldPos >= 0)and(MemTableEh1.FieldByName('id').Value <> null)and(not A.InArray(MemTableEh1.FieldByName('id').Value, DeletedIds))
    then DeletedIds:=DeletedIds + [MemTableEh1.FieldByName('id').Value];
  Mth.PostAndEdit(MemTableEh1);
  MemTableEh1.ReadOnly:=False;
  MemTableEh1.Delete;
  //RowDisable;
end;

procedure TForm_MdiGridDialogTemplate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  ///
end;

procedure TForm_MdiGridDialogTemplate.RowDisable;
begin
  {(*}
  //блокируем изменение строк по датам, для которых (раньше вчера и больше текущей) недопустимо правами доступа
  MemTableEh1.ReadOnly := (not (Mode in [fView, fDelete]));
  {*)}
end;

function  TForm_MdiGridDialogTemplate.IsTableAdded: Boolean;
begin

end;

function TForm_MdiGridDialogTemplate.IsRowNotEmpty: Boolean;
//Вернет True, если в строке хоть одно не сервисное поле не null (при путой таблице также True)
var
  i: Integer;
begin
  Result := True;
  if (MemTableEh1.RecordCount = 0) then
    Exit;
  for i := 0 to MemTableEh1.Fields.Count - 1 do
    if not s.InCommaStrI(MemTableEh1.Fields[i].FieldName, FieldsService) and (MemTableEh1.Fields[i].Value <> null) then
      Exit;
  Result := False;
end;

function TForm_MdiGridDialogTemplate.IsRowCorrect: Boolean;
//Вернет труе, если строка заполнена корректно
//по умолчанию проверяет в соотвествии с ColumnsVerify (если последний не задан то вернет True)
//пустые строки игнорирует
var
  i: Integer;
  v: Variant;
begin
  Result := True;
  if not IsRowNotEmpty then
    Exit;
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    if not Gh.VeryfyCoumnEhValue(DBGridEh1.Columns[i], DBGridEh1.Columns[i].Field.Value, v) then begin
      Result := False;
      IncorrectRowNo:=MemTableEh1.RecNo;
      IncorrectRowColumn:=i;
      IncorrectRowMsg:='Ошибочное значение строке ' + InttoStr(MemTableEh1.RecNo) + ' в ячейке "' + DBGridEh1.Columns[i].Title.Caption + '"';
      Exit;
    end;
end;

function TForm_MdiGridDialogTemplate.IsTableEmpty: Boolean;
//Вернет труе, если в таблице нет строк либо она содержить лишь пустые строки
var
  rn, i: Integer;
begin
  Result := True;
  rn := MemTableEh1.RecNo;
  MemTableEh1.RecNo := 1;
  for i := 1 to MemTableEh1.RecordCount do begin
    Result := not IsRowNotEmpty;
    if not Result then
      Break;
  end;
  MemTableEh1.RecNo := rn;
end;

function TForm_MdiGridDialogTemplate.IsTableCorrect: Boolean;
//Вернет труе, если в таблице все строки верные
//при этом пустые строки считаются верными
var
  rn, i, j, k, m: Integer;
  va1: TVarDynArray;
begin
  Result := True;
  va1 := A.Explode(FieldsNoRepaeted, ';', True);
  rn := MemTableEh1.RecNo;
  MemTableEh1.RecNo := 1;
  for i := 1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo := i;
    if not IsRowNotEmpty then Continue;  //пустые строки пропускаем
    Result := IsRowCorrect;
    if not Result then
      Break;
  end;
  if Result then
    for j := 0 to High(va1) do begin
      for k := 0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 2 do
        for m := k + 1 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do
          if MemTableEh1.RecordsView.MemTableData.RecordsList[k].DataValues[va1[j], dvvValueEh] = MemTableEh1.RecordsView.MemTableData.RecordsList[m].DataValues[va1[j], dvvValueEh] then begin
            Result := False;
            IncorrectRowMsg:='Дублирующиеся значения в строках ' + InttoStr(k + 1) + ' и ' + InttoStr(m + 1) + ' в колонке "' + DBGridEh1.FindFieldColumn(va1[j]).Title .Caption+ '"';
            break
          end;
    end;
  MemTableEh1.RecNo := rn;
end;

function TForm_MdiGridDialogTemplate.VerifyBeforeSave: string;
//должна проверить пересд сохранение правильность данных и вернуть сообщение,
//которое выведетсяв окне при нажатии кнопки Ок после проверки, если есть ошибки;
//если сообщение путое, то этто признак верности данных
//если оно равно "-", то данные неверны, но ничего не выведется,
//если "*" выведется "Данные не корректны!"
//по умолчанию проверяет корректнорсть IsTableCorrect, и если не AllowEmptyTable то IsTableEmpty
begin
  if (AllowEmptyTable and IsTableEmpty) or (not IsTableEmpty and IsTableCorrect) then
    Result := ''
  else
    Result := IncorrectRowMsg; //'*';
end;

procedure TForm_MdiGridDialogTemplate.SetDBGridEh1ColumnsUpdateData;
var
  i: Integer;
begin
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    if DBGridEh1.Columns[i].Visible then
      DBGridEh1.Columns[i].onUpdateData := DBGridEh1ColumnsUpdateData;
end;



//Prepare///////////////////////////////////////////////////////////////////////

function TForm_MdiGridDialogTemplate.InitGrid: Boolean;
//создаем грид и мемтейбл (поля, настройки...). вызывается в Prepare, обязательно перекрывается.
//если не вернет True, форма не будет показана
begin
  Result := True;
end;

function TForm_MdiGridDialogTemplate.InitAdd: Boolean;
//Дополнительные действия потомка, которые вызывается в Prepare.
//если не вернет True, форма не будет показана
begin
  Result := True;
end;

function TForm_MdiGridDialogTemplate.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
begin
  Result := False;
  //проверим блокировку, выйдем если нельзя взять (при попытке редактирования уйдет в просмотр, при удалении - выход)
  if FormDbLock = fNone then Exit;
  //доступность контролов, в зависимости от режима, кроме дат начала/окончания - всегда дисейбл
//  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  //Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  AutoSaveWindowPos := True;
  FieldsService := 'id';
  //инициализируем и при необходимости заполним грид (перекрыт потомком)
  if not InitGrid then
    Exit;
  //получим позицию поля айди в мемтейбл, если оно есть
  IdFieldPos:=-1;
  if DBGridEh1.FindFieldColumn('id') <> nil
    then IdFieldPos:=MemTableEh1.FieldByName('id').FieldNo;
  //инициализируем доп компоненты (если нужен, перекрыт потомком)
  if not InitAdd then
    Exit;
  if OneRowOnOpen and (MemTableEh1.RecordCount = 0) then
    MemTableEh1.Append;
  if AddRowIfFAddOnOpen and (Mode = fAdd) then
    MemTableEh1.Append;
  //установим событие при редактированиее в толбце
  SetDBGridEh1ColumnsUpdateData;
  for i := 0 to High(ColumnsVerifications) do
    Gh.SetVeryfyCoumnEhRule(DBGridEh1.Columns[i], ColumnsVerifications[i]);
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    if S.InCommaStrI(DBGridEh1.Columns[i].FieldName, FieldsReadOnly, ';') then
      DBGridEh1.Columns[i].ReadOnly := True
    else
      DBGridEh1.Columns[i].ReadOnly := not (Mode in [fAdd, fEdit, fCopy]);
  DBGridEh1.ReadOnly := Mode in [fView, fDelete];
  //заголовок формы и кнопки в зависимости от режима
  Cth.SetDialogForm(Self, Mode, Caption);
  //иконка подсказки
  Cth.SetInfoIcon(Img_Info, Cth.SetInfoIconText(Self, InfoArr), 20);
  ChangeSelectedData;
//  Serialize;
//  CtrlBegValuesStr:= CtrlCurrValuesStr;
  SetStatusBar('', '', False);
//  Verify(nil);
//  pnl_Bottom.Align := alNone;
//  pnl_Bottom.Top:=Self.ClientHeight - StatusBar.Height - pnl_Bottom.Height;
//  pnl_Bottom.Align := alBottom;
  //доп. кнопки
  Cth.SetBtn(Bt_Add, mybtAdd, True);
  Cth.SetBtn(Bt_Del, mybtDelete, True);
  Bt_Add.Visible := Mode in [fEdit, fAdd, fCopy];
  Bt_Del.Visible := Bt_Add.Visible;
  Bev_Buttons.Visible := Bt_Add.Visible;
  chb_NoClose.Visible := False;
  Result := True;
end;

end.

