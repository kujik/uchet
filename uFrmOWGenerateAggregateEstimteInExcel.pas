{
Формирование общей заявки СН (сметы) в Excel по выбранным заказам: пользователь добавляет заказы, нажимает "Старт",
для каждого заказа ищутся файлы смет/заявок СН в каталоге заказа (папка "СН"), данные распознаются и суммируются,
результат выгружается в xlsx-шаблон через TA7Rep. Не привязана к конкретной записи (Mode/ID/AddParam не используются),
инструмент вызывается из главного меню (пункт "Общая смета по выбранным заказам").
Вызывается только из uFrmMain.pas (см. также исходный TDlg_Rep_Smeta/D_Rep_Smeta).
}
unit uFrmOWGenerateAggregateEstimteInExcel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  System.Math, System.IOUtils, System.Types, ComObj,
  uFrmBasicMdi, uString
  ;

type
  TFrmOWGenerateAggregateEstimteInExcel = class(TFrmBasicMdi)
    Bt_Go: TBitBtn;
    lbl_AddOrders: TLabel;
    Bt_AddOrders: TBitBtn;
    Memo1: TMemo;
    Bt_Stop: TBitBtn;
    lbl_Progress: TLabel;
    procedure Bt_AddOrdersClick(Sender: TObject);
    procedure Bt_GoClick(Sender: TObject);
    procedure Bt_StopClick(Sender: TObject);
  private
    { Private declarations }
    OrIds, OrNum: string;
    OrCnt: Integer;
    Orders: TVarDynArray2;
    Stop: Boolean;
    Excel, Sh: Variant;
    ExcelExecute: Boolean;
    a1: TVarDynArray2;
    procedure SetLb_AddOrders;
    procedure Go;
    function LoadSmeta(FileName: string): Integer;
    procedure ExportToXlsxA7;
    procedure AfterFormActivate; override;
  public
    { Public declarations }
  end;

var
  FrmOWGenerateAggregateEstimteInExcel: TFrmOWGenerateAggregateEstimteInExcel;

implementation

{$R *.dfm}

uses
  uForms,
  uData,
  uWindows,
  uMessages,
  uExcel
  ;

procedure TFrmOWGenerateAggregateEstimteInExcel.Bt_AddOrdersClick(Sender: TObject);
var
  vv: Variant;
const
  MaxCnt = 10000;
begin
  vv := VarArrayOf(['%', OrIds, 'dt_beg', 'Дата распила']);
  Wh.ExecReference(myfrm_J_Orders_SEL_1, Self, [myfoDialog, myfoModal, myfoSizeable], VarArrayOf(['%', '', '', '']));
  if Length(Wh.SelectDialogResult) = 0 then Exit;
  OrIds := '';
  OrNum := '';
  if Length(Wh.SelectDialogResult2) > MaxCnt
    then MyWarningMessage('Выбрано слишшком много заказов!'#13#10'Будут добавлены только 300 первых заказов.');

  OrCnt := Min(Length(Wh.SelectDialogResult2), MaxCnt);
  for var i := 0 to Min(High(Wh.SelectDialogResult2), MaxCnt - 1) do begin
    OrIds := OrIds + S.IIFStr(Length(OrIds) = 0, '', ';') + IntToStr(Integer(Wh.SelectDialogResult2[i][0]));
    OrNum := OrNum + S.IIFStr(Length(OrNum) = 0, '', ';  ') + Wh.SelectDialogResult2[i][2];
  end;
  SetLb_AddOrders;
  Orders := Copy(Wh.SelectDialogResult2);
end;

procedure TFrmOWGenerateAggregateEstimteInExcel.SetLb_AddOrders;
begin
  lbl_AddOrders.Caption := S.IIFStr(OrCnt = 0,
    'Заказы не выбраны!',
    IntToStr(OrCnt) +
    ' заказ' + S.GetEnding(OrCnt, '', 'а', 'ов'));
end;

procedure TFrmOWGenerateAggregateEstimteInExcel.Bt_GoClick(Sender: TObject);
begin
  Go;
end;

procedure TFrmOWGenerateAggregateEstimteInExcel.Bt_StopClick(Sender: TObject);
begin
  Stop := True;
end;

procedure TFrmOWGenerateAggregateEstimteInExcel.Go;
var
  i, j, sm: Integer;
  st: string;
  Err: string;
  SnFiles: TStringDynArray;
  b: Boolean;
const
  smtypes: array of string = ['формат не распознан!', 'смета старого образца', 'смета нового образца', 'заявка СН', 'заявка СН общая'];
begin
  Stop := False;
  Memo1.Lines.Clear;
  lbl_Progress.Caption := '';
  a1 := [[]];
  SetLength(a1, 50000);
  for i := 0 to High(Orders) do begin
    Application.ProcessMessages;
    if Stop then Exit;
    Err := '';
    repeat;
    st := Module.GetPath_OrderCurrent(Orders[i, 3]) + '\' + Orders[i, 1];
    if not DirectoryExists(st) then begin
      st := Module.GetPath_OrderArchive(Orders[i, 3]) + '\' + Orders[i, 1];
      if not DirectoryExists(st) then
        begin Err := 'Не найден каталог заказа!'; Break; end;
    end;
    if not DirectoryExists(st + '\СН') then
      begin Err := 'Не найден каталог СН!'; Break; end;
    SnFiles := [];
    try
      SnFiles := TDirectory.GetFiles(st + '\СН', '*xls');
    finally
    end;
    if Length(SnFiles) = 0 then
      begin Err := 'Нет ни одной сметы!'; Break; end;
    b := True;
    for j := 0 to High(SnFiles) do begin
      sm := LoadSmeta(SnFiles[j]);
      b := (sm > 0) and b;
    end;
    if not(b)
      then begin Err := 'Файлы в СН не являются файлами сметы!'; Break; end
      else begin Err := smtypes[sm]; end;
    until True;
    if Err <> '' then begin
      Memo1.Lines.Add(Orders[i, 2] + ':  ' + Err);
    end;
    Application.ProcessMessages;
    lbl_Progress.Caption := 'обработано:  ' + IntToStr(i + 1) + ' из ' + IntToStr(Length(Orders));
  end;
  lbl_Progress.Caption := 'Подготовка отчета';
  ExportToXlsxA7;
  lbl_Progress.Caption := 'Завершено';
end;

procedure TFrmOWGenerateAggregateEstimteInExcel.ExportToXlsxA7;
var
  i, j, k: Integer;
  Rep: TA7Rep;
  FileName, gr: string;
  buf: Variant;
  a2: TVarDynArray;
  st: string;
begin
  for k := 0 to High(a1) do
    if High(a1[k]) = -1 then Break;
  SetLength(a1, k);
  A.VarDynArray2Sort(a1, +1);
  FileName := 'Заявка СН общая';
  FileName := Module.GetReportFileXls(FileName);
  if FileName = '' then Exit;
  Rep := TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName);
  except
    Rep.Free;
    Exit;
  end;
  Rep.OpenWorkSheet('СН');
  Rep.PasteBand('HEADER');
  gr := '';
  j := 0;
  for i := 0 to High(a1) do begin
    if High(a1[i]) = -1 then Break;
    try
    if S.NSt(a1[i][0]) <> gr then begin
      Rep.PasteBand('TABLE');
      gr := S.NSt(a1[i][0]);
      Rep.SetValue('#N#', VarToStr(gr));
      Rep.SetValue('#NAME#', '');
      Rep.SetValue('#CODE#', '');
      Rep.SetValue('#DIM#', '');
      Rep.SetValue('#QNT#', '');
      Rep.SetValue('#COMM#', '');
    end;
    inc(j);
    Rep.PasteBand('TABLE');
    Rep.SetValue('#N#', VarToStr(j));
    Rep.SetValue('#NAME#', VarToStr(a1[i][1]));
    Rep.SetValue('#CODE#', VarToStr(a1[i][2]));
    Rep.SetValue('#DIM#', VarToStr(a1[i][3]));
    if S.IsNumber(a1[i][4], -999999999999, +999999999999, 10)
      then Rep.SetValue('#QNT#', VarToStr(a1[i][4]))
      else Rep.SetValue('#QNT#', '');
    st := '';
    if VarToStr(a1[i][5]) <> '' then begin
      A.ExplodeP(VarToStr(a1[i][5]), '|', False, a2);
      A.VarDynArraySort(a2, True);
      buf := ''; st := '';
      for k := 0 to High(a2) do begin
        if a2[k] <> buf then begin
          buf := a2[k];
          st := st + S.IIf(st = '', '', '|') + buf;
        end;
      end;
    end;
    Rep.SetValue('#COMM#', st);
    except
    end;
  end;
  Rep.DeleteCol1;
  Rep.Show;
  Rep.Free;
end;

function TFrmOWGenerateAggregateEstimteInExcel.LoadSmeta(FileName: string): Integer;
var
  i, j, sti, irow: Integer;
  dtype, doctype: Integer;
  nm, gr, st, st2: string;
begin
  if not ExcelExecute then begin
    Excel := CreateOleObject('Excel.Application');
    ExcelExecute := True;
  end;
  Excel.Workbooks.Open(FileName, True, True);
  Excel.DisplayAlerts := False; // for prevent error in SetValue procedure, where VarName not fount for replace
  Excel.Visible := False;
  dtype := 0;
  for i := 1 to Excel.Workbooks[1].WorkSheets.Count do begin
    if Excel.Workbooks[1].WorkSheets[i].Name = 'СН'
      then begin dtype := 1; Break; end
      else if Excel.Workbooks[1].WorkSheets[i].Name = 'Смета печать'
        then begin dtype := 2; Break; end;
  end;
  doctype := 0;
  if dtype > 0 then begin
    sh := Excel.Workbooks[1].WorkSheets[i];
    if S.NSt(sh.Cells[3, 1].Value) = 'Заказчик' then begin
      //смета старого образца
      if (S.NSt(sh.Cells[4, 1].Value) = 'Наименование изделия') and
        (S.NSt(sh.Cells[5, 1].Value) = '№ паспорта заказа СГ') and
        (S.NSt(sh.Cells[16, 1].Value) = 'Смета на материалы') and
        (S.NSt(sh.Cells[17, 1].Value) = '№')
        then begin
          DocType := 1; sti := 18;
        end;
    end
    else if S.NSt(sh.Cells[13, 1].Value) = 'Заказчик:' then begin
      //смета нового образца
      if (S.NSt(sh.Cells[14, 1].Value) = 'Наименование изделия:') and
        (S.NSt(sh.Cells[19, 1].Value) = 'Смета на материалы') and
        (S.NSt(sh.Cells[20, 1].Value) = '№')
        then begin
          DocType := 2; sti := 21;
        end;
    end
    else if Trim(S.NSt(sh.Cells[1, 1].Value)) = 'Бланк заявки на снабжение' then begin
      //заявка СН
      if (Trim(S.NSt(sh.Cells[2, 1].Value)) = 'Номер заказа:') and
        (Trim(S.NSt(sh.Cells[3, 1].Value)) = 'Заказчик:') and
        (Trim(S.NSt(sh.Cells[4, 1].Value)) = 'Изделие')
        then begin
          DocType := 3; sti := 7;
        end;
    end
    else if Trim(S.NSt(sh.Cells[2, 2].Value)) = 'Заказчик' then begin
      //объединенная заявка СН
      if (Trim(S.NSt(sh.Cells[6, 6].Value)) = 'Итого:') and
        (Trim(S.NSt(sh.Cells[6, 7].Value)) = 'Примечание') and
        (Trim(S.NSt(sh.Cells[9, 2].Value)) = 'Наименование')
        then begin
          DocType := 4; sti := 10;
        end;
    end;
  end;
  Result := doctype;
  if Result = 0 then begin
    Excel.Workbooks[1].Close;
    Exit;
  end;

  irow := sh.UsedRange.Row + sh.UsedRange.Rows.Count + 3; //!
  gr := 'Материалы без групп';
  for i := sti to sti + 10000 do begin
    Application.ProcessMessages;
    try
    if (doctype in [1, 3]) then begin
      //старая смета и заявка СН новая
      //заполняем построчно, маркер мателриалла (не группа) - число в первом столбце
      //количество правильно брать из столбца Загрузка в итм (там итоговое на все заказы), а не расчетное
      If Not (((S.NSt(Sh.Cells[i, 1].Value) = '') And (S.NSt(Sh.Cells[i, 2].Value) = '')) Or ((S.NSt(Sh.Cells[i, 1].Value) = '0') And (S.NSt(Sh.Cells[i, 2].Value) = '0'))) Then begin
        If (S.NSt(Sh.Cells[i, 2].Value) <> '') And (S.NSt(Sh.Cells[i, 2].Value) <> '0') Then begin
          nm := sh.cells[i, 2].Value;
          for j := 0 to High(a1) - 1 do
            if (High(a1[j]) = -1) or (S.NSt(a1[j, 1]) = nm)
              then Break;
          st := S.IIFStr(doctype = 1, Sh.Cells[i, 16].Value, Sh.Cells[i, 10].Value);
          if High(a1[j]) = -1
            then a1[j] := [gr, nm, Sh.Cells[i, 3].Value, Sh.Cells[i, 4].Value, S.NNum(Sh.Cells[i, 9].Value), st]
            else begin
              a1[j][4] := a1[j][4] + S.NNum(Sh.Cells[i, 9].Value);
              if st <> '' then a1[j][5] := a1[j][5] + '|' + st;
            end;
        end
        else begin
          gr := S.NSt(Sh.Cells[i, 1].Value);
        end;
      end
      else if i > irow then Break;
    end;
    if (doctype in [2]) then begin
      //новая смета
      //маркер материала - пустой первый столбец, группа как и материал в четвертом
      If Not (((S.NSt(Sh.Cells[i, 1].Value) = '') And (S.NSt(Sh.Cells[i, 4].Value) = '')) Or ((S.NSt(Sh.Cells[i, 1].Value) = '0') And (S.NSt(Sh.Cells[i, 4].Value) = '0'))) Then begin
        If (S.NSt(Sh.Cells[i, 1].Value) <> '') And (S.NSt(Sh.Cells[i, 1].Value) <> '0') Then begin
          nm := sh.cells[i, 4].Value;
          st2 := Sh.Cells[i, 11].Value;
          S.NNum(Sh.Cells[i, 11].Value);
          for j := 0 to High(a1) - 1 do
            if (High(a1[j]) = -1) or (S.NSt(a1[j, 1]) = nm)
              then Break;
          st := S.NSt(Sh.Cells[i, 12].Value);
          if High(a1[j]) = -1
            then a1[j] := [gr, nm, Sh.Cells[i, 6].Value, Sh.Cells[i, 8].Value, S.NNum(Sh.Cells[i, 11].Value), st]
            else begin
              a1[j][4] := a1[j][4] + S.NNum(Sh.Cells[i, 11].Value);
              if st <> '' then a1[j][5] := a1[j][5] + '|' + st;
            end;
        end
        else begin
          gr := S.NSt(Sh.Cells[i, 4].Value);
        end;
      end
      else if i > irow then Break;
    end;
    if (doctype in [4]) then begin
      //заявка СН общая
      //маркер материала - первый столбец является числом, а второй не пустой, группа в первом столбце
      if (S.NSt(Sh.Cells[i, 1].Value) <> '') or (S.NSt(Sh.Cells[i, 2].Value) <> '') then begin
        if S.IsNumber(S.NSt(Sh.Cells[i, 1].Value), 1, 10000) and (S.NSt(Sh.Cells[i, 1].Value) <> '') then begin
          nm := sh.cells[i, 2].Value;
          for j := 0 to High(a1) - 1 do
            if (High(a1[j]) = -1) or (S.NSt(a1[j, 1]) = nm)
              then Break;
          st := S.NSt(Sh.Cells[i, 7].Value);
          if High(a1[j]) = -1
            then a1[j] := [gr, nm, Sh.Cells[i, 5].Value, Sh.Cells[i, 4].Value, S.NNum(Sh.Cells[i, 6].Value), st]
            else begin
              a1[j][4] := a1[j][4] + S.NNum(Sh.Cells[i, 6].Value);
              if st <> '' then a1[j][5] := a1[j][5] + '|' + st;
            end;
        end
        else begin
          gr := S.NSt(Sh.Cells[i, 1].Value);
        end;
      end
      else if i > irow then Break;
    end;
    except
    end;
  end;
  Excel.Workbooks[1].Close;
end;

procedure TFrmOWGenerateAggregateEstimteInExcel.AfterFormActivate;
begin
  inherited;
  Cth.SetBtn(Bt_AddOrders, mybtAdd, False, 'Добавить заказы');
  Cth.SetBtn(Bt_Go, mybtGo, False, 'Старт');
  Cth.SetBtn(Bt_Stop, mybtCancel, False, 'Стоп');
  SetLb_AddOrders;
  lbl_Progress.Caption := '';
  Excel := null;
  ExcelExecute := False;
end;

end.
