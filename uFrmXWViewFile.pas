{
Простой многооконный (MDI, myfoMulticopy) просмотрщик/редактор текстовых файлов на TMemo.
Используется SqlUpdater-ом для просмотра исходных sql-скриптов и файлов лога.
Путь к файлу передаётся через AddParam (AAddParam в Show/Create), заголовок окна -
имя файла.

Галка "Разрешить редактирование" переводит memMain в режим редактора (ReadOnly:=False) и
показывает кнопку "Сохранить" - сохраняет текст обратно в файл (cp1251, без учета кодировки
исходного файла - соглашение проекта для .sql).

Навигация по меткам SqlUpdater-а (теги действия имеют три состояния - см. uSqlUpdaterCore):
  F3 - следующее (по кругу) взведенное ("!") - --!!!, --!-, --!go begin, --!+;
  F4 - следующее обработанное ("$") - --$-, --$go begin, --$+;
  F5 - следующее финальное - --$dropped, --$completed begin.
Ctrl+F - поиск текста (простой диалог "Найти", поиск вперед от каретки, по кругу).
}

unit uFrmXWViewFile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls,
  IOUtils,
  uData, uMessages, uFrmBasicMdi
  ;

type
  TFrmXWViewFile = class(TFrmBasicMdi)
    memMain: TMemo;
    pnlTop: TPanel;
    chkEditable: TCheckBox;
    btnSave: TButton;
    procedure chkEditableClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure memMainKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FFileName: string;
    FLastSearchText: string;
    function Prepare: Boolean; override;
    procedure GoToNextMarker(ATier: Integer);
    procedure DoFindText;
    procedure FindNextOccurrence(const ASearchText: string);
  public
  end;

var
  FrmXWViewFile: TFrmXWViewFile;

implementation

{$R *.dfm}

function TFrmXWViewFile.Prepare: Boolean;
var
  Enc: TEncoding;
begin
  Result := False;
  FFileName := VarToStr(AddParam);
  if not TFile.Exists(FFileName) then begin
    MyWarningMessage('Файл не найден: ' + FFileName);
    Exit;
  end;
  Caption := ExtractFileName(FFileName);
  try
    Enc := TEncoding.GetEncoding(1251);
    try
      memMain.Text := TFile.ReadAllText(FFileName, Enc);
    finally
      Enc.Free;
    end;
  except
    on E: Exception do begin
      MyWarningMessage('Не удалось прочитать файл: ' + E.Message);
      Exit;
    end;
  end;
  memMain.ReadOnly := True;
  chkEditable.Checked := False;
  btnSave.Visible := False;
  memMain.OnKeyDown := memMainKeyDown;
  Result := inherited;
end;

procedure TFrmXWViewFile.chkEditableClick(Sender: TObject);
begin
  memMain.ReadOnly := not chkEditable.Checked;
  btnSave.Visible := chkEditable.Checked;
end;

procedure TFrmXWViewFile.btnSaveClick(Sender: TObject);
begin
  if MyQuestionMessage('Сохранить изменения в файл "' + ExtractFileName(FFileName) + '"?') <> mrYes then
    Exit;
  try
    TFile.WriteAllText(FFileName, memMain.Text, TEncoding.GetEncoding(1251));
    MyInfoMessage('Файл сохранен.', []);
  except
    on E: Exception do
      MyWarningMessage('Не удалось сохранить файл: ' + E.Message);
  end;
end;

procedure TFrmXWViewFile.memMainKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (Shift = [ssCtrl]) then begin
    DoFindText;
    Key := 0;
  end
  else if Key = VK_F3 then begin
    GoToNextMarker(3);
    Key := 0;
  end
  else if Key = VK_F4 then begin
    GoToNextMarker(4);
    Key := 0;
  end
  else if Key = VK_F5 then begin
    GoToNextMarker(5);
    Key := 0;
  end;
end;

function EndsWithActiveTag(const S, ATag: string): Boolean;
//S заканчивается ровно на ATag (например '--!-') и перед ATag нет еще одного дефиса
//(иначе это была бы отключенная ---... конструкция - три и более дефиса)
var
  L, TL: Integer;
begin
  L := Length(S);
  TL := Length(ATag);
  Result := (L >= TL) and SameText(Copy(S, L - TL + 1, TL), ATag)
    and not ((L > TL) and (S[L - TL] = '-'));
end;

procedure TFrmXWViewFile.GoToNextMarker(ATier: Integer);
//переход к следующей (по кругу) строке с меткой нужного уровня, начиная поиск со строки
//сразу после текущей позиции каретки:
//  3 - взведенные: --!!!, --!-, --!go begin, --!+
//  4 - обработанные: --$-, --$go begin, --$+
//  5 - финальные: --$dropped, --$completed begin
var
  i, StartLine, CurLine, Cnt: Integer;
  Ln: string;
  Found: Boolean;

  function Matches(const S: string): Boolean;
  begin
    case ATier of
      3: Result := (Copy(S, 1, 5) = '--!!!') or EndsWithActiveTag(S, '--!-') or EndsWithActiveTag(S, '--!+') or SameText(S, '--!go begin');
      4: Result := EndsWithActiveTag(S, '--$-') or EndsWithActiveTag(S, '--$+') or SameText(S, '--$go begin');
      5: Result := EndsWithActiveTag(S, '--$dropped') or SameText(S, '--$completed begin');
      else Result := False;
    end;
  end;

begin
  Cnt := memMain.Lines.Count;
  if Cnt = 0 then
    Exit;
  CurLine := memMain.CaretPos.Y; //0-based номер строки, где сейчас каретка
  Found := False;
  for i := 1 to Cnt do begin
    StartLine := (CurLine + i) mod Cnt;
    Ln := Trim(memMain.Lines[StartLine]);
    if Matches(Ln) then begin
      memMain.SelStart := memMain.Perform(EM_LINEINDEX, StartLine, 0);
      memMain.SelLength := Length(memMain.Lines[StartLine]);
      memMain.Perform(EM_SCROLLCARET, 0, 0);
      Found := True;
      Break;
    end;
  end;
  if not Found then
    MyInfoMessage('Больше нет таких меток.', []);
end;

procedure TFrmXWViewFile.DoFindText;
var
  S: string;
begin
  S := FLastSearchText;
  if not InputQuery('Найти', 'Текст для поиска:', S) then
    Exit;
  if Trim(S) = '' then
    Exit;
  FLastSearchText := S;
  FindNextOccurrence(S);
end;

procedure TFrmXWViewFile.FindNextOccurrence(const ASearchText: string);
//ищет ASearchText (без учета регистра) начиная сразу после текущего выделения, по кругу
var
  StartPos, FoundPos: Integer;
  UpperText, UpperSearch: string;
begin
  if Trim(ASearchText) = '' then
    Exit;
  UpperText := UpperCase(memMain.Text);
  UpperSearch := UpperCase(ASearchText);
  StartPos := memMain.SelStart + memMain.SelLength + 1;
  FoundPos := Pos(UpperSearch, Copy(UpperText, StartPos, MaxInt));
  if FoundPos > 0 then
    FoundPos := FoundPos + StartPos - 1
  else
    FoundPos := Pos(UpperSearch, UpperText); //не нашли дальше по тексту - ищем с начала (по кругу)
  if FoundPos = 0 then begin
    MyInfoMessage('Текст "' + ASearchText + '" не найден.', []);
    Exit;
  end;
  memMain.SelStart := FoundPos - 1;
  memMain.SelLength := Length(ASearchText);
  memMain.Perform(EM_SCROLLCARET, 0, 0);
end;

end.
