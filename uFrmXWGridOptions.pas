unit uFrmXWGridOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, ClipBrd, TypInfo,
  uLabelColors, uString, uData, uFrmBasicMdi, uFrDBGridEh
  ;

type
  TFrmXWGridOptions = class(TFrmBasicMdi)
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlLeftTop: TPanel;
    pnlRightTop: TPanel;
    Frg1: TFrDBGridEh;
    lbl1: TLabel;
    lbl2: TLabel;
    procedure FormShow(Sender: TObject);
  private
    FFrDbGrid: TFrDBGridEh;
    FChbs: TVarDynArray2;
    FChbsH: Integer;
    FOwnerFormDoc: string;
    FFrozenColumn: string;
    function  Prepare: Boolean; override;
    procedure SetCheckBoxes;
    procedure LoaDGridOptions;
    procedure btnOkClick(Sender: TObject); override;
    procedure btnClick(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); virtual;
//    procedure Frg1DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure SetLoadDefaultEnabled;
  public
  end;

var
  FrmXWGridOptions: TFrmXWGridOptions;

implementation

uses
  uForms,
  uMessages,
  uErrors,
  uSys,
  uDBOra,
  uWindows,
  uSettings,
  V_MDI,
  uFrmXWGridAdminOptions
  ;

const
  mydefFomHeight = 200;
  mydefRowHeight = 17;
  mydefGridMaxHeight = 800;
  mydefHeightAdd=40;


{$R *.dfm}

procedure TFrmXWGridOptions.SetLoadDefaultEnabled;
begin
//  Cth.SetButtonsAndPopupMenuCaptionEnabled([pnlFrmBtnsR], 1000, null, Settings.IsDefaultFrDBGridEhSettingsExists(FOwnerFormDoc, FFrDbGrid), '');
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, 1000, null, Settings.IsDefaultFrDBGridEhSettingsExists(FOwnerFormDoc, FFrDbGrid), '');
end;

procedure TFrmXWGridOptions.SetCheckBoxes;
var
  sa: TStringDynArray;
  i: Integer;
  c: TControl;
begin
  FChbs := [
    ['FilterPanel',
     'Панель фильтра',
     myogPanelFilter,
    'Если установлено, над таблицей отображается строка фильтра.'+chr(10)+chr(13)+
    'При вводе в нем текста, в таблице отображаются только строки, содержащие этот текст.'+chr(10)+chr(13)+
    'Справа от строки ввода находится кнопка, позволяющая менять параметры фильтра (например, поиск только по текущему столбцу)'+chr(10)+chr(13)+
    'Использование фильтра очень удобно!'+chr(10)+chr(13)
    ],
    ['SearchPanel',
     'Панель поиска',
     myogPanelFind,
    'Если установлено, над таблицей отображается строка поиска.'+chr(10)+chr(13)+
    'При вводе в ней текста, в таблице подсвечиваются совпадающие строки.'+chr(10)+chr(13)+
    'Этот режим не совместим с режимом панели фильтра, выберите что-то одно.'+chr(10)+chr(13)+
    'Кстати, обычный поиск доступен в таблице по Ctrl-F'+chr(10)+chr(13)
    ],
    ['STFilter',
     'Фильтр в стобцах',
     myogColumnfilter,
    'Включает фильтр в заголовках столбцов.'+chr(10)+chr(13)+
    'Этот фильтр очень похож на автофильтр Exel.'+chr(10)+chr(13)+
    'Вы можете фильтровать таблицу по нескольким столбцам.'+chr(10)+chr(13)
    ],
    ['Sorting',
     'Сортировка',
     myogSorting,
    'Сортировка таблицы.'+chr(10)+chr(13)+
    'Позволяет сортировать таблицу по значениям данных в столбце кликом на заголовке столбца.'+chr(10)+chr(13)+
    'Возможна сортировка сразу по нескольким столбцам, для этого выберите их в нужном порядке кликом на заголовках,'+chr(10)+chr(13)+
    '  удерживая клавишу Ctrl/'+chr(10)+chr(13)+
    'Обязательно включите эту опцию!'+chr(10)+chr(13)
    ],
    ['AutoHeight',
     'Автоподбор высоты строк',
    myogAutoFitRoWHeight,
    'Если опция включена, то строки таблицы будут увеличиваться в высоту так, чтобы в текст помещался в ячейку целиком.'+chr(10)+chr(13)+
    'При этот текст в ячеках переносится по словам. Ячейки, работающие в таком режиме, надо отметить в таблице колонок справа в этом окне.'+chr(10)+chr(13)
    ],
    ['AutoWidth',
     'Автоподбор ширины столбцов',
    myogAutoFitColWidths,
    'Если опция установлена, система пытается выбрать оптимальную ширину столбцов'+chr(10)+chr(13)+
    '(для тех столбцов, у которых проставлена галочка Подгонять ширину в таблице справа в этом окне).'+chr(10)+chr(13)
    ],
    ['SaveFilter',
     'Сохранять фильтр в столбцах',
    myogSaveFilter,
    'Если опция установлена, фильтр в столбцах сохраняется при закрытии документа и восстанавливается при повторном открытии'+chr(10)+chr(13)+
    '(даже после перезапуска программы).'+chr(10)+chr(13)
    ],
    ['SavePosWhenSorting',
     'Сохранять позицию при сортировке',
    myogSavePosWhenSorting,
    'Если опция установлена, то при сортировке сохраняется текущая запись в таблице (например, активной останется строка с тем же номером заказа).'+chr(10)+chr(13)+
    'В противном случае, при сортировке произойдет переход к первой строке таблицы.'+chr(10)+chr(13)
    ]
  ];
  for i:= 0 to High(FChbs) do begin
    c:=Cth.CreateControls(pnlLeft, cntCheck, FChbs[i][1], 'FChbs' + FChbs[i][0], '', 0);
    c.Left := 4;
    c.Width := 180;
    c.Top := pnlLeftTop.Height + 4 + i * MY_FORMPRM_CONTROL_H;
    c := TImage.Create(Self);
    c.Name := 'Img' + FChbs[i][0];
    c.Parent := pnlLeft;
    c.Left := 194;
    c.Top := pnlLeftTop.Height + 4 + i * MY_FORMPRM_CONTROL_H;
    FChbsH := c.Top;
    Cth.SetInfoIcon(TImage(c), Cth.SetInfoIconText(TForm(Self), [[FChbs[i][3]]]), MY_FORMPRM_CONTROL_H);
  end;
//  pnlRight.Width := 4 + MY_FORMPRM_CONTROL_H + 4;
  c := TImage.Create(Self);
  c.Parent := pnlRightTop;
  c.Top := 2;
  c.Left := lbl2.Width + 4 + 4; //pnlRightTop.Width - MY_FORMPRM_CONTROL_H - 4;
  c.Name := 'ImgGrid';
  Cth.SetInfoIcon(TImage(c), Cth.SetInfoIconText(TForm(Self),
    [[
    'Список столбцов таблицы.'#13#10+
    'Галочки задают:'#13#10+
    '- видимость столбца.'#13#10+
    '- будет ли текст в ячейке столбка переноситься по высоте (если включен автоподбор высоты строк)'#13#10+
    '- будет ли столбец подгоняться по ширине в зависимости от ширины таблицы (если включен автоподбор ширины столбцов)'#13#10+
    'Также вы можете закрепить столбцы в левой части таблицы по клику правой кнопкой мышки'#13#10+
    '(это может быть удобно, если в таблице много колонок и они не умещаются на экран)'#13#10
//    ''#13#10+
    ]]
  ), MY_FORMPRM_CONTROL_H);
end;


procedure TFrmXWGridOptions.LoaDGridOptions;
var
  sa: TStringDynArray;
  va2: TVarDynArray2;
  c: TDBCheckBoxEh;
  i: Integer;
begin
  va2 := [];
  //отобразим только те столбцы, которые пользователь имеет право видеть
  //в порядке, в котором они находятся сейчас в гриде
  //(не сервисные с _, не нулл, и не скрытые
  for i:=0 to FFrDbGrid.DBGridEh1.Columns.Count-1 do
    begin
//      if (Pos('_', FFrDbGrid.DBGridEh1.Columns[i].Title.Caption) = 1) then Continue;
      if FFrDbGrid.Opt.Sql.Fields[i].Invisible or FFrDbGrid.Opt.Sql.Fields[i].FIsNull or (Pos('_', FFrDbGrid.Opt.Sql.Fields[i].Caption) = 1) then
        Continue;
      va2 := va2 + [[
        i,
        FFrDbGrid.DBGridEh1.Columns[i].FieldName,
        FFrDbGrid.DBGridEh1.Columns[i].Title.Caption,
        S.IIf(FFrDbGrid.DBGridEh1.Columns[i].Visible, 1, 0),
        S.IIf(FFrDbGrid.DBGridEh1.Columns[i].WordWrap, 1, 0),
        S.IIf(FFrDbGrid.DBGridEh1.Columns[i].AutoFitColWidth, 1, 0)
      ]];
    end;
  Frg1.LoadSourceDataFromArray(va2);
  for i := 0 to High(FChbs) do
    if FChbs[i][2] <> - 1 then begin
      c := TDBCheckBoxEh(Self.FindComponent('FChbs' + FChbs[i][0]));
      c.Checked := TFrDBGridOption(FChbs[i][2]) in FFrDbGrid.Options;
    end;
  FFrozenColumn := FFrDbGrid.Opt.FrozenColumn;
  Frg1.MemTableEh1.First;
  Frg1.OnColumnsUpdateData := Frg1ColumnsUpdateData;
  Frg1.OnButtonClick := Frg1ButtonClick;
  Frg1.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;
end;

procedure TFrmXWGridOptions.FormShow(Sender: TObject);
begin
  inherited;
  SetLoadDefaultEnabled;
  pnlFrmBtnsMain.Width := pnlFrmBtnsMain.Width + 4 + MY_FORMPRM_CONTROL_H + 4;
end;

procedure TFrmXWGridOptions.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Frg1.SetValue('', Value);
  handled := True;
end;

procedure TFrmXWGridOptions.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  inherited;
  if FFrozenColumn = Fr.GetValue('field') then
    Params.Background := clSkyBlue;
end;


procedure TFrmXWGridOptions.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if FFrozenColumn = Fr.GetValue('field')
    then FFrozenColumn := ''
    else FFrozenColumn := Fr.GetValue('field');
end;

procedure TFrmXWGridOptions.ControlOnChange(Sender: TObject);
begin
  if (TControl(Sender).Name = 'ChbFilterPanel') and TDBCheckBoxEh(Sender).Checked then
    TDBCheckBoxEh(FindComponent('ChbSearchPanel')).Checked := False;
  if (TControl(Sender).Name = 'ChbSearchPanel') and TDBCheckBoxEh(Sender).Checked then
    TDBCheckBoxEh(FindComponent('ChbFilterPanel')).Checked := False;
end;

procedure TFrmXWGridOptions.btnClick(Sender: TObject);
begin
  if TButton(Sender).Tag = 1001 then begin
    //to Default
    if FOwnerFormDoc <> '' then
      Settings.WriteFrDBGridEhSettings(FOwnerFormDoc, FFrDbGrid, True);
    SetLoadDefaultEnabled;
  end;
  if TButton(Sender).Tag = 1002 then begin
    FrmXWGridAdminOptions.ShowDialog(FFrDbGrid);
  end;
  if TButton(Sender).Tag = 1000 then begin
    //По умолчанию
    if MyQuestionMessage('Установить для таблицы вид по умолчанию?') <> mrYes then
      Exit;
    if FOwnerFormDoc <> '' then
      Settings.RestoreFrDBGridEhSettings(FOwnerFormDoc, FFrDbGrid, True);
    MyInfoMessage('Вид по умолчанию установлен!');
  end;
end;

procedure TFrmXWGridOptions.btnOkClick(Sender: TObject);
var
  c: TDBCheckBoxEh;
  i, j: Integer;
  st: string;
begin
  for i:=0 to Frg1.GetCount - 1 do
    begin
    st := Frg1.GetValue('field', i);
    j := Frg1.GetValue('visible', i);
//    FFrDbGrid.DBGridEh1.FindFieldColumn(st).Visible := Frg1.GetValue('visible', i) = 1;
    FFrDbGrid.Opt.SetFieldVisible(st, Frg1.GetValue('visible', i) = 1);
    FFrDbGrid.DBGridEh1.FindFieldColumn(st).WordWrap := Frg1.GetValue('wordwrap', i) = 1;
    FFrDbGrid.DBGridEh1.FindFieldColumn(st).AutoFitColWidth := Frg1.GetValue('autofit', i) = 1;
    end;
  for i := 0 to High(FChbs) do
    if FChbs[i][2] <> - 1 then begin
      c := TDBCheckBoxEh(Self.FindComponent('FChbs' + FChbs[i][0]));
      if c.Checked
        then FFrDbGrid.Options := FFrDbGrid.Options + [TFrDBGridOption(FChbs[i][2])]
        else FFrDbGrid.Options := FFrDbGrid.Options - [TFrDBGridOption(FChbs[i][2])];
    end;
  FFrDbGrid.Opt.FrozenColumn := FFrozenColumn;
  FFrDbGrid.SetColumnsVisible;
  inherited;
end;


function TFrmXWGridOptions.Prepare: Boolean;
var
  i, j: Integer;
  va2: TVarDynArray;
begin
  Result := False;
  Mode := FEdit;
  Caption := '~Настройка вида таблицы';
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(pnlFrmClient, []);
  if User.IsDeveloper then
    FOpt.DlgButtonsL:=[[1001, User.IsDeveloper, True, 100, 'To default', 'to_settings'],[1002, User.IsDeveloper, True, 100, 'Admin', 'settings_spanner']];                                //'settings_spanner'
  FOpt.DlgButtonsR:=[[1000, True, True, 120, 'По умолчанию', 'settings_def'], [mbtDividor, True], [mbtSpace, True, 1]];
  FOpt.StatusBarMode:=stbmNone;

  FOwnerFormDoc := '';
  if ParentForm is TFrmBasicMdi
    then FOwnerFormDoc:= TFrmBasicMdi(ParentForm).FormDoc
    else if ParentForm is TForm_MDI
      then FOwnerFormDoc:= TForm_MDI(ParentForm).FormDoc;

  FFrDbGrid := TFrDBGridEh(ParentControl);

  Frg1.Options:=[myogIndicatorColumn, myogColoredTitle, myogHiglightEditableColumns, myogHiglightEditableCells];
  Frg1.Opt.SetDataMode(myogdmFromArray);
  Frg1.Opt.SetFields([
    ['num$i', '_N', '20'],
    ['field$s', '_Поле', '100'],
    ['name$s', 'Столбец', '200;W'],
    ['visible$s', 'Показать', '70', 'chb', 'e'],
    ['wordwrap$s', 'Переносить по словам', '70', 'chb', 'e'],
    ['autofit$s', 'Подгонять ширину', '70', 'chb', 'e']
  ]);
  Frg1.Opt.SetButtons(1, [[-1000, True, 'Закрепить столбец']]);
  Frg1.Prepare;

  SetCheckBoxes;
  LoaDGridOptions;

  i:=Min(Frg1.DBGridEh1.RowCount * mydefRowHeight + 35, mydefGridMaxHeight);
  FWHCorrected.Y:=Max(FChbsH + 4 + MY_FORMPRM_CONTROL_H, i + Frg1.Top{ + pnlFrmBtns.Height + 10});
  FWHCorrected.X:= 800;
  FWHBounds.X:= 800;
  FWHBounds.X2:= -1;
  FWHBounds.Y:= FWHCorrected.Y + 70 + 36;

  FOpt.InfoArray:=[[
  'Настройте внешний вид и функционал таблицы.'#13#10+
  'Эти настройки сохранятся при перезапуске программы.'#13#10
  ]];

  Result := True;
end;


end.
