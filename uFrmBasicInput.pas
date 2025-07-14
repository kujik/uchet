(*
Настраиваемый диалог ввода/редактирования данных.
Вид диалога (поля ввода, размеры, расположание, значения проверки) задаются параметрами.

Имеет две классных функции:
- ShowDialog для вызова модального диалога, передача начальных и возврат конечных значений в параметрах-массивах
- ShowDialogDB для вызова модального или mdi диалога, с загрузкой и сохранением данных в бд

Настройка внешнего вида, поведения и проверки данных идентичны.

Вызов callback-функций до конца не реализован, в процессе

Форма НЕ ДОЛЖНА перекрываться!

*)


unit uFrmBasicInput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls,
  uWindows, uString, uForms, uDBOra, uMessages, uData, uFrmBasicMdi
  ;

type

  //опции диалога
  TDlgBasicInputOption = (
    dbioModal,      //модальный (в случае без БД всегда модальный)
    dbioSizeable,   //ширина может изменяться
    dbioChbNoClose, //чекбокс повтора ввода
    dbioStatusBar   //статусбар с сообщениями (тип ввода, данные изменены, ошибка)
    {, dbioDbLock, dbioRefreshParent}
  );

  TDlgBasicInputOptions = set of TDlgBasicInputOption;


  TFrmBasicInput = class(TFrmBasicMdi)
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    UseDB: Boolean;
    Ctrls: array of TControl;               //контролы, только для ввода данных (bevel и label сюда не попадут)
    Fields: string;                         //строка полей через ;
    FieldsSave: string;                     //строка полей для операции записи через ;. если не передана то совпадает с Ctrls

    FieldsDef: TVarDynArray2;               //первоначальное (переданное в параметре вызова) определение полей
    FieldsDefAdd: TVarDynArray2;            //дополненное определение полей.

    View: string;                           //таблица/вью из которой загружаем данные
    Table: string;                          //таблица, в которую записываем данные
    Sequence: string;                       //секвенция, если нужна
    IdField: string;                        //имя поля первичного ключа

    FCaption: string;                       //заголовок формы
    FWidth: Integer;                        //переданная ширина формы
    FLeft: Integer;                         //передеанный левый отступ контролов

    FieldsBegValues: Variant;               //начальные значения полей (массив)

    MyDlgFormOptions: TDlgBasicInputOptions;//опции диалога

    DisabledControls: TControlArray;        //контролы, которые в любом случае disabled

    Info: TVarDynArray2;                    //массив информации

    DlgFunction: TDlgFunction;
    function  Prepare: Boolean; override;
    procedure SetControlsAdd;
    function  Load: Boolean;
    function  Save: Boolean; override;
  public
    { Public declarations }
    FieldsNewValues: TVarDynArray;          //новые значения полей, для передачи из функции класса ShowDialog
    //показ диалога с передачей данных и их возвратом в массивах-параметрах
    //возвращает -1 если была отмена, 0 если данные не изменены, и 1 если данные были изменены
    class function ShowDialog(
      AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType;
      ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AFieldsBegValues: TVarDynArray;
      var AFieldsNewValues: TVarDynArray; AInfo: TVarDynArray2;
      ADlgFunction:TDlgFunction=nil): Integer;
    //показ диалога (мди или модального) в режиме работы с БД
    //передаются данные для чтения и записи данных в БД, устанавливается блокировка, вызывающая форма обновляется
    class function ShowDialogDB2(
      AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType; AID: Variant; ATable: string;
      ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AFieldsBegValues: TVarDynArray;
      var AFieldsNewValues: TVarDynArray; AInfo: TVarDynArray2;
      ADlgFunction:TDlgFunction=nil): Integer;
    class function ShowDialogDB(
      AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType; AID: Variant; ATable: string;
      ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AInfo: TVarDynArray2;
      ADlgFunction:TDlgFunction=nil): Integer;
    class function _TestFunction(): Integer;
    class function _TestFunctionDB(): Integer;
  end;

var
  FrmBasicInput: TFrmBasicInput;

implementation

uses
  uFrmMain
  ;

{$R *.dfm}

var
  //переменные для передачи параметров функции класса внутрь конструктора
  GFieldsDef: TVarDynArray2;
  GFieldsBegValues: TVarDynArray;
  GMyFormOptions: TDlgBasicInputOptions;

//------------------------------------------------------------------------------
//функция вызова модального диалога с передачей исходных и введенных данных в параметрах-массивах.
class function TFrmBasicInput.ShowDialog(
  AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType;
  ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AFieldsBegValues: TVarDynArray;
  var AFieldsNewValues: TVarDynArray; AInfo: TVarDynArray2;
  ADlgFunction:TDlgFunction=nil): Integer; //overload;
var
  i: Integer;
  myFormOptions1: TMyFormOptions;
  F: TForm;
procedure PSetControlsProc(ASelf: TObject; AControlValues: TVarDynArray);
//вспомогательная функция для передачи параметров функции вызова формы внутрь конструктора
begin
  TFrmBasicInput(ASelf).UseDB := False;
  TFrmBasicInput(ASelf).FWidth := AControlValues[0];
  TFrmBasicInput(ASelf).FLeft := AControlValues[1];
  TFrmBasicInput(ASelf).FCaption := AControlValues[2];
  TFrmBasicInput(ASelf).FieldsDef := GFieldsDef;
  TFrmBasicInput(ASelf).FieldsBegValues := GFieldsBegValues;
  TFrmBasicInput(ASelf).MyDlgFormOptions := GMyFormOptions;
  TFrmBasicInput(ASelf).FOpt.InfoArray := AControlValues[3];
end;
begin
  GFieldsDef := AFieldsDef;
  GFieldsBegValues := AFieldsBegValues;
  GMyFormOptions := AMyFormOptions;
  if dbioSizeable in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoSizeable];
  F := Create(AOwner, ADoc, [myfoModal, myfoDialog] + myFormOptions1, AMode, null, null,
    [AWidth, ALeft, ACaption, AInfo],
    @PSetControlsProc
  );
  Result := S.IIf(TFrmBasicMdi(F).ModalResult <> mrOk, -1, S.IIf(TFrmBasicMdi(F).IsDataChanged, 1, 0));
  AFieldsNewValues := TFrmBasicInput(F).FieldsNewValues;
  AfterFormClose(F);
end;

//------------------------------------------------------------------------------
//функция вызова диалога (mdi или модального окна) с загрузкой исходных данных из БД и их записью в БД
class function TFrmBasicInput.ShowDialogDB2(
  AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType; AID: Variant; ATable: string;
  ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AFieldsBegValues: TVarDynArray;
  var AFieldsNewValues: TVarDynArray; AInfo: TVarDynArray2;
  ADlgFunction:TDlgFunction=nil): Integer; //overload;
var
  i: Integer;
  myFormOptions1: TMyFormOptions;
  F: TForm;
procedure PSetControlsProc(ASelf: TObject; AControlValues: TVarDynArray);
//вспомогательная функция для передачи параметров функции вызова формы внутрь конструктора
var
  va: TVarDynArray;
begin
  TFrmBasicInput(ASelf).UseDB := True;
  TFrmBasicInput(ASelf).FWidth := AControlValues[0];
  TFrmBasicInput(ASelf).FLeft := AControlValues[1];
  TFrmBasicInput(ASelf).FCaption := AControlValues[2];
  TFrmBasicInput(ASelf).FieldsDef := GFieldsDef;
  TFrmBasicInput(ASelf).FieldsBegValues := GFieldsBegValues;
  TFrmBasicInput(ASelf).MyDlgFormOptions := GMyFormOptions;
  TFrmBasicInput(ASelf).FOpt.InfoArray := AControlValues[3];
  //получим из разделенной ; строки вью, таблицу, последовательность и поле айди (обязательно только первое значение)
  va:=A.Explode(AControlValues[4], ';') + ['','',''];
  TFrmBasicInput(ASelf).View:=va[0];
  TFrmBasicInput(ASelf).Table:=S.IIf(va[1] = '', va[0], va[1]);
  TFrmBasicInput(ASelf).Sequence:=S.IIf(va[2] = '', '', va[2]);
  TFrmBasicInput(ASelf).IdField:=S.IIf(va[3] = '', 'id$i', va[3]);
end;
begin
  GFieldsDef := AFieldsDef;
  GFieldsBegValues := AFieldsBegValues;
  GMyFormOptions := AMyFormOptions;
  if dbioModal in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoModal];
  if dbioSizeable in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoSizeable];
  F := Create(AOwner, ADoc, [myfoDialog] + myFormOptions1, AMode, AID, null,
    [AWidth, ALeft, ACaption, AInfo, ATAble],
    @PSetControlsProc
  );
  Result := S.IIf(TFrmBasicMdi(F).ModalResult <> mrOk, -1, S.IIf(TFrmBasicMdi(F).IsDataChanged, 1, 0));
  AFieldsNewValues := TFrmBasicInput(F).FieldsNewValues;
  AfterFormClose(F);
end;

class function TFrmBasicInput.ShowDialogDB(
  AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType; AID: Variant; ATable: string;
  ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AInfo: TVarDynArray2;
  ADlgFunction:TDlgFunction=nil): Integer; //overload;
var
  i: Integer;
  myFormOptions1: TMyFormOptions;
  F: TForm;
procedure PSetControlsProc(ASelf: TObject; AControlValues: TVarDynArray);
//вспомогательная функция для передачи параметров функции вызова формы внутрь конструктора
var
  va: TVarDynArray;
begin
  TFrmBasicInput(ASelf).UseDB := True;
  TFrmBasicInput(ASelf).FWidth := AControlValues[0];
  TFrmBasicInput(ASelf).FLeft := AControlValues[1];
  TFrmBasicInput(ASelf).FCaption := AControlValues[2];
  TFrmBasicInput(ASelf).FieldsDef := GFieldsDef;
  TFrmBasicInput(ASelf).FieldsBegValues := VaRArrayOf([]);
  TFrmBasicInput(ASelf).MyDlgFormOptions := GMyFormOptions;
  TFrmBasicInput(ASelf).FOpt.InfoArray := AControlValues[3];
  //получим из разделенной ; строки вью, таблицу, последовательность и поле айди (обязательно только первое значение)
  va:=A.Explode(AControlValues[4], ';') + ['','',''];
  TFrmBasicInput(ASelf).View:=va[0];
  TFrmBasicInput(ASelf).Table:=S.IIf(va[1] = '', va[0], va[1]);
  TFrmBasicInput(ASelf).Sequence:=S.IIf(va[2] = '', '', va[2]);
  TFrmBasicInput(ASelf).IdField:=S.IIf(va[3] = '', 'id$i', va[3]);
end;
begin
  GFieldsDef := AFieldsDef;
  GMyFormOptions := AMyFormOptions;
  if dbioModal in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoModal];
  if dbioSizeable in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoSizeable];
  F := Create(AOwner, ADoc, [myfoDialog] + myFormOptions1, AMode, AID, null,
    [AWidth, ALeft, ACaption, AInfo, ATAble],
    @PSetControlsProc
  );
  Result := S.IIf(TFrmBasicMdi(F).ModalResult <> mrOk, -1, S.IIf(TFrmBasicMdi(F).IsDataChanged, 1, 0));
  AfterFormClose(F);
end;



procedure TFrmBasicInput.SetControlsAdd;
(*
пустой массив - разделитель
0="имя_поля{;имя_поля_для_записи}" - может не быть, тогда создается контрол без привязки к полю. если поле для записи не задано, используется то же поле
1=тип контрола
2=заголовок
3=условие проверки, может не быть
4=ширина, может не быть. если нет или 0 или 1, то в этом случае тедит и комбо растягиваются по ширине окна, а намбер и тп дефолтная ширина при w = 0 и по окну при w =1
5=если задано, то это правый отступ, контрол будет не перенесн на следующую строку, а установлен в текущей справа в этой координате
*)
var
  c: TVarDynArray;
  va: TVarDynArray;
  va2: TVarDynArray2;
  i, j, k, h, h1, r :Integer;
  st:string;
begin
  va2:=[];
  DisabledControls := [];
  for i:=0 to High(FieldsDef) do begin
    va2:= va2 + [[cntBevel, ''{caption}, ''{verify}, 0{width}, 0{left}, 0, 0, '', '']];
    if High(FieldsDef[i]) < 0 then Continue;
    j:= 0;
    if UseDB or ((High(FieldsDef[i]) >= 0) and (S.VarType(FieldsDef[i][0]) = varString)) then begin
      va:=a.Explode(FieldsDef[i][0] + ';', ';');
      S.ConcatStP(Fields, va[0], ';');
      S.ConcatStP(FieldsSave, S.IIFStr(va[1] = '', va[0], va[1]), ';');
      j:= 1;
    end;
    for k:= j to High(FieldsDef[i]) do begin
      va2[i][k-j]:= FieldsDef[i][k];
    end;
  end;
  SetLength(Ctrls, Length(va2));

  //ширина формы по переденному в диалог параметру
  Width := FWidth;

  h := 3;
  k := 0;
  for i := 0 to High(va2) do begin
    Ctrls[i]:= Cth.CreateControls(pnlFrmClient, va2[i][0], va2[i][1], 'Ctrl_'+IntToStr(i), va2[i][2]);
    Ctrls[i].Left:=FLeft;
    Ctrls[i].Top:=h;
    //есть четвертый параметр - расположим контрол на той же строке, в позиции Х равном этому параметру
    if (va2[i][4] > 0) then begin
      Ctrls[i].Left := va2[i][4];
      Ctrls[i].Top := Ctrls[i - 1].Top;
    end;
    //расставим контролы
    //параметр ширины 0 означает для коротких едит-контролов родную ширину по дефолту, для длинных ширину до конца окна
    //ширина = 1 означает продолжение контрола до конца окна во всех случаях, и в случае изменяемого размера - правый якорь
    h1 := Ctrls[i].Height + 3 + S.IIf(va2[i][0] = cntBevel, 6, 0);
    h := h + h1;
    //горизонтальный разделитель
    if va2[i][0] = cntBevel then begin
      Ctrls[i].Left := 2; //MY_FORMPRM_H_EDGES;
      Ctrls[i].Width := 1;  //всегда на все окно
    end
    else begin
      if(va2[i][3]) = 0 then begin
        if not (TMyControlType(va2[i][0]) in [cntNEdit, cntNEditC, cntNEditS, cntDEdit, cntTEdit, cntDTEdit]) then
          Ctrls[i].Width:= 1;
      end
      else if(va2[i][3]) = 1 then
        Ctrls[i].Width:= 1
      else if va2[i][3] > 1
        then Ctrls[i].Width:=va2[i][3];
      if Copy(va2[i][1], 1, 1) = ' ' then
        DisabledControls := DisabledControls + [Ctrls[i]];
    end;
    //максимальная ширина
    r := Max(r, Ctrls[i].Left + Ctrls[i].Width);
  end;

  //выравнивание контролов и размеров формы
  //на 2025-01-21 подобрал так
  if myfoSizeable in MyFormOptions then begin
    FWHBounds.Y2:=-1;
    ClientWidth:= Max(r + 3, 5);
    FWHCorrected:= Cth.AlignControls(pnlFrmClient, [], False) ;
    FWHCorrected.X:= Max(r + 3, FWidth);
    ClientWidth := FWHCorrected.X + MY_FORMPRM_H_EDGES + 2;
  //  FOpt.AutoAlignControls:=True;
  end
  else begin
    FWHCorrected:= Cth.AlignControls(pnlFrmClient, [], False) ;
    FWHCorrected.X:= Max(r + 3, FWidth);
    ClientWidth := FWHCorrected.X + MY_FORMPRM_H_EDGES + 2;
  end;

  //растянем контролы с шириной  = 1 до конца окна
  for i := 0 to High(Ctrls) do
    if Ctrls[i].Width = 1 then begin
      Ctrls[i].Width:= ClientWidth - Ctrls[i].Left - MY_FORMPRM_H_EDGES * 2 - 2;
      //если формы расширяемая по ширине, нам нужны якоря. но если ставить их здесь, то все съзжает
      //ставим признак у контролов в параметре Tag, по которому в предке в TFrmMDI.CorrectFormSize устанавливаются якоря
      //!!!стандартизовать использование Tag!!!
      if myfoSizeable in MyFormOptions then
        Ctrls[i].Tag := -100;
       //Ctrls[i].Anchors := [akLeft, akTop, akRight];
    end;


  FieldsDefAdd := Copy(va2);

  //исключим бевели из массива контролов, так как они не несут нагрузки в плане данных
  for i := High(va2) downto 0 do
    if va2[i][0] = cntBevel
      then Delete(Ctrls, i, 1);

end;

procedure TFrmBasicInput.FormActivate(Sender: TObject);
begin
  inherited;
//  Caption := InttoStr(ClientWidth);
end;

function TFrmBasicInput.Load(): Boolean;
//установка значений контролов из переданного массива вариант
var
  s: string;
  f, f1: TVarDynArray;
  i, j, k : Integer;
  v, vcb, vcb_list: TVarDynArray;
begin
  Result:= True;
  v:=FieldsBegValues;
  SetLength(FieldsNewValues, Length(Ctrls));
  if not UseDB then begin
  k := -1;
  try
    for i := 0 to High(FieldsDefAdd) do begin
      if TMyControlType(FieldsDefAdd[i][0]) = cntBevel
        then Continue;
      inc(k);
      //для комбобоксов передается массив значений вида VarArrayOf([value, VarArrayOf([v1, v2]) ,{VarArrayOf([key1, key2])} ])
      if TMyControlType(FieldsDefAdd[i][0]) in [cntComboL, cntComboLK, cntComboLK0, cntComboE, cntComboEK] then begin
        vcb := v[k];
        vcb_list := vcb[1];
        //присвоим значений
        for j := 0 to High(vcb_list) do
          TDBComboBoxEh(Ctrls[k]).Items.Add(vcb_list[j]);
        if TMyControlType(FieldsDefAdd[i][0]) in [cntComboLK, cntComboLK0, cntComboEK] then
          //для комбобоксов с ключевым полем
          if High(vcb) > 1 then begin
              //если передан третий параметр-массив, то из него ключи
            vcb_list := vcb[2];
            for j := 0 to High(vcb_list) do
              TDBComboBoxEh(Ctrls[k]).KeyItems.Add(vcb_list[j]);
          end
          else begin
              //иначе ключи просто цифры начиная с 0
            for j := 0 to High(vcb_list) do
              TDBComboBoxEh(Ctrls[k]).KeyItems.Add(IntToStr(j));
          end;
       //значение комбобокса из 0го элемента, это или само значение, или ключ
        Cth.SetControlValue(Ctrls[k], vcb[0]);
      end      //все другие котролы - просто установим занчение
      else begin
        Cth.SetControlValue(Ctrls[k], v[k]);
      end;
    end;
  except
    Result:= False;
  end;
  end
  else begin
    if Mode <> fAdd then begin
      Result := False;
      Fields:= IdField + ';' + Fields;
      FieldsSave:= IdField + ';' + FieldsSave;
      v := Q.QLoadToVarDynArrayOneRow(Q.QSIUDSql('s', View, Fields), [ID]);
      if Length(v) = 0 then begin
        MsgRecordIsDeleted;
        Exit;
      end;
      for i := 0 to High(Ctrls) do
        Cth.SetControlValue(Ctrls[i], v[i + 1]);
      Result := True;
    end
    else begin
      FieldsSave:= IdField + ';' + FieldsSave;
      for i := 0 to High(Ctrls) do
        if not((Ctrls[i] is TDBCheckBoxEh) and (TDBCheckBoxEh(Ctrls[i]).Checked))
         then Cth.SetControlValue(Ctrls[i], null);
    end;
  end;
end;


function TFrmBasicInput.Save: Boolean;
//сохранение данных
//возвращает статус удачного сохранения
//может быть перекрыта, с или без вызова inherited
var
  ChildHandled: Boolean;
  i, res: Integer;
  FieldsSave2, CtrlValues2: TVarDynArray;
  FieldsSaveNew: string;
begin
  Result := False;
  if not UseDB then begin
    for i := 0 to High(Ctrls) do
      FieldsNewValues[i] := Cth.GetControlValue(Ctrls[i]);
    Result := True;
    Exit;
  end;

  try
    for i := 0 to High(Ctrls) do
      FieldsNewValues[i] := S.NullIfEmpty(Cth.GetControlValue(Ctrls[i]));
  except
    on E: Exception do begin
      Application.ShowException(E);
      Exit;
    end;
  end;
  CtrlValues2:= Copy(FieldsNewValues);
  FieldsSave2:= A.Explode(FieldsSave, ';');
  for i:= high(FieldsSave2) downto 0 do
    if FieldsSave2[i] = '0' then begin
      Delete(FieldsSave2, i, 1);
      Delete(CtrlValues2, i, 1);
    end;
  CtrlValues2 := [S.IIf(Mode in [fEdit, fDelete], ID, -1)] + CtrlValues2;
//  FieldsSaveNew:= IdField + ';' + A.Implode(FieldsSave2, ';');
  FieldsSaveNew:= A.Implode(FieldsSave2, ';');
  res := Q.QIUD(Q.QFModeToIUD(Mode), Table, Sequence, FieldsSaveNew, CtrlValues2);
  Result := res <> -1;
end;

function TFrmBasicInput.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
begin
  Result := False;
  //пытаемся взять блокировку. не испольуется, если нет foformDoc или ID = null
  if FormDbLock = fNone then
    Exit;
  //центрировакие относительно родительской формы
  MyFormOptions := MyFormOptions + [myfoDialog];
  //панель кнопок внизу
  FOpt.DlgPanelStyle := dpsBottomRight;
  //статусбар
  if dbioStatusBar in MyDlgFormOptions then
    FOpt.StatusBarMode := stbmDialog;
  //чекбокс повтора ввода
  if dbioChbNoClose in MyDlgFormOptions then
    FOpt.UseChbNoClose := True;
  //при работе с базой - обновляем родительскую форму при Ок
  if UseDB then
    FOpt.RefreshParent := True;
  //заголовок. не забываем если надо тильду!
  Caption := FCaption;
  //создаем контролы для ввода, выравниваем их и подгоняем размер формы
  SetControlsAdd;
  //загружаем данные
  if not Load then
    Exit;
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  if Length(DisabledControls) > 0 then
    SetControlsEditable(DisabledControls, False);
  //проверка после загрузки
  Verify(nil);
  Result := True;
end;

{
myfoSizeable
контролы с длиной 0/1 (якорь по правому краю) работают норм, растягивание и ограничение норм
если не выровнены, форма не корректируется по контролу
}


class function TFrmBasicInput._TestFunction(): Integer;
var
  va: TVarDynArray;
begin
  Result:= TFrmBasicInput.ShowDialog(FrmMain, '', [], fAdd, 'Свои организации', 800, 100,
   [[cntEdit, 'Наименование','1:30'],
    [cntEdit, 'Реквизиты','0:100:0:N'],
    [],
    [cntCheck,  'Используется',''],
    [cntNEditS, 'Число','-1:30:2', 0, 250],
    [cntDTEdit, 'Дата','' + S.DateTimeToIntStr(Date) + ':*'], //floattostr(extended(dt))
    [cntBevel],
    [cntComboE, 'Комбобокс','1:50:0', 400],
    [cntComboLK, 'Комбо с ключом','0:50:0:N']
   ],
   VarArrayOf([
     'name','req', 1, -40.5, Date,
     VarArrayOf(['0', VarArrayOf(['0','1','2'])]),
     VarArrayOf(['2', VarArrayOf(['item 0','item 1','item 2']), VarArrayOf(['0','2','1'])])
   ]),
   va,
   [['Это форма ввода произвольных данных с функцией их проверки.']],
   nil
   //,
   //DlgFunction
  );
end;

class function TFrmBasicInput._TestFunctionDB(): Integer;
var
  va: TVarDynArray;
begin
  Result:= TFrmBasicInput.ShowDialogDB(FrmMain, '', [dbioChbNoClose, {bioSizeable,}dbioStatusBar], fAdd, 35, 'or_format_estimates', 'Формат сметы', 400, 100,    //35 - test
   [['name$s', cntEdit, 'Наименование','1:30'],
    ['prefix$s', cntEdit, 'Префикс','1:20', 150],
    [],
    ['active$i', cntCheckX, 'Используется']
   ],
{   VarArrayOf([
     'name','req', 1, -40.5, Date,
     VarArrayOf(['0', VarArrayOf(['0','1','2'])]),
     VarArrayOf(['2', VarArrayOf(['item 0','item 1','item 2'])])
   ]),
   va,}
   [['Это форма ввода произвольных данных с функцией их проверки.']],
   nil
  );
end;

end.

2025-01-09
нет отработки необновления родительской формы (это надо делать в форммди)
нет пока записи результата в бд

--------------------------------------------------------------------------------

Опции:
dbioModal - вызов в модальном режиме, актуально только для ShowDialogDB,
без базы всегда модельный.

в режиме dbioSizeable форма растягивается по горизонтали, иначе размеры постоянны.
по высоте всегда подгоняется по содержимому (составу контролов).
по горизонтали, если длина в параметре функции окажется меньше, чем самый дальний правый край
контрола постоянной длины, то форма будет уменьшенена до его края, если же длина больше,
то размер останется равным ей. при изменяемой длине, этот же размер будет минимально допустимым.

dbioChbNoClose - добавляет чекбокс и функционал ввода данных в режиме fAdd/fCopy
без закрытия окна.
на данный момент содержимое не очищается!

dbioStatusBar - добавляет статусбар с инфой в режиме диалога.

dbioDbLock - добавляет функционал запроса блокировки.
НЕ ИСПОЛЬЗУЕТСЯ! В режиме с БД он всегда есть, в диалоге никогда нет!
Работает, только если задан FormDoc и ID (а он есть для диалога с БД).
Ддолжен быть режим редактирования или удаления. При невзятии блокировки в режиме
редактирования - откроется в режиме просмотра, с сообщением, в режиме удаления
не откроется с  сообщением. Блокировка возможна деже при работе без режима БД.

dbioRefreshParent - обновлять родительскую форму при нажатии ОК, если она поддерживает эту
функцию (сейчас ущербно, только MDI_Grid1 обновляет всегда основной грид. надо переделать)
Е ИСПОЛЬЗУЕТСЯ! В режиме с БД всегда обновляет, в диалоге никогда нет!
--------------------------------------------------------------------------------

параметры в заголовке функции (для диалога без БД, ShowDialog):
-Родительский элемент (кем вызван)
-FormDoc. Не обязателен. Если задан, то это позвоолит сохранять размер формы.
-Опции, множество
-Режим диалога, от него зависят кнопки, доступность ввода.
-Заголовок формы, начать с тильды, если не нужна добавка тип "ЧЧЧ - Добавить"
-Шарина формы
-Левый оступ контролов

-Массив определения контролов
в массиве TVarDynArray2 контролов первым элементом идет тип контрола.
вторым - его заголовок.
третьим - правило проверки данных. строка. может быть пропущена, тогда проверки нет
четвертым - длина поля ввода контрола (при остутствии подразумевается 0).
контролы, параметром длины которых передана 1, будут растянуты
до края формы, и в случае растягиваемой формы будут также растягиваться.
параметр 0 означает дефолтную длину контрола, как он создается без задания параметра ширины.
патым - если он есть - Left контрола, в этом случае он находится на той же строке что и
предыдущий и на следующую не переносится.
в случае работы с БД, первым параметром идет имя поля (или поле_чтения;поле_записи),
сотальные параметры сдвигаются.
пустой элемент массива осзначает горизонтальный разделитель.
заголовок контрола, начинающийся с пробела, делает этот контрол нередактируемым в любом случае

-Определение начальных значений контролов, тип Variant
может быть определен как VarArrayOf
кромке комбобоксов, каждому элементу соотвествует значение Variant в этом VarArrayOf
для комбобоксов, задается так:
VarArrayOf(['0', VarArrayOf(['0','1','2'])]), //ьез ключа
VarArrayOf(['2', VarArrayOf(['item 0','item 1','item 2']), VarArrayOf(['0','2','1'])]) //с ключом

-ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ, в массиве TVarDynArray.
если изменений не было, будут равны начальным значениям.

-Подсказка, в массиве TVarDynArray2, в обычной для нее формате
(в подмассивах строка, и второй параметр, если есть - логический -
определяет, добалять ли строку в вывод)

-Callback-функция, в разработке

Если не проходит проверка корректности данных, кнопку Ок нажать невозможно,
кроме режима fDelete.

вызов диалога вернет:
-1, если было закрытие не по кнопке Ок
0, если нажато ОК, но не было изменения данных
1, если нажато ОК и данные были изменены.

--------------------------------------------------------------------------------
параметры в заголовке функции (для диалога с БД, ShowDialogDB):
-Родительский элемент (кем вызван)
-FormDoc. Не обязателен. Если задан, то это позвоолит сохранять размер формы.
-Опции, множество
-Режим диалога, от него зависят кнопки, доступность ввода, и режим показа/обновления данных
-ID
-параметры получения/записи данных, через ';', не нужно перечислять все если они дефолтные,
 также если пропущен то будет по дефолту:
 view;table;sequence;id_field
 по умолчнаию table = view, sequence не нужен, id_field = 'id$i'
-Заголовок формы, начать с тильды, если не нужна добавка тип "ЧЧЧ - Добавить"
-Шарина формы
-Левый оступ контролов

пытается установиться блокировка в случае редактирования или удаления
данные читаются, если неудача выдается сообщение, что были удалены
если корректны, по нажатию Ок сохраняются в базе, при неудаче выдается сообщение и
диалог не закрывается.
обновляется родительская форма

--------------------------------------------------------------------------------

НЕ РЕАЛИЗОВАНА
загрузка комбобоксов в случае работы с бд
Callback-функция, в разработке
