unit uSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBCtrlsEh, Buttons, DBGridEh, DBAxisGridsEh, GridsEh,
  ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, System.Generics.Collections,
  MemTableDataEh, Db, MemTableEh, Math, ExtCtrls, Types,
  IniFiles,  SearchPanelsEh,
  PropFilerEh,
  ActnList,
  uData, Jpeg, uString, PngImage,
  uFrDBGridEh
  ;

type
  TSettings = class(tobject)
  private
    U: TStringList;
    M: TMemIniFile;
    MA: TMemIniFile;
    MAChanged: Boolean;
    procedure SetCurrGridWriteDoDef(Value: Boolean);
    function  GetCurrGridWriteDoDef: Boolean;
    procedure EnsureGrid2Prepared(Grid: TFrDBGridEh);
  public
    CurrGridWriteDoDef: Boolean;
    InterfaceDialogsN: Integer;
    InterfaceFormsN: Integer;
    InterfaceQuit: Integer;
    InterfaceStyle: string;
    constructor Create;
    procedure Save;
    procedure Load;
//    procedure Write(Section: string; Name: string; Value: Variant);
//    function  Read(Section: string; Name: string; DefaultValue: Variant): Variant;
    procedure WriteGridSettings(Section: string; Grid: TDBGridEh; ToDef: Boolean = False);
    procedure RestoreGridSettings(Section: string; Grid: TDBGridEh; SetDefault: Boolean = False);
    procedure SaveWindowPos(Form: TForm; Section: string);
    procedure RestoreWindowPos(Form: TForm; Section: string);
    procedure WriteFormSettings(Form: TForm);
    procedure RestoreFormSettings(Form: TForm);
    procedure WriteMDIGrid1Property(Form: TForm; Name, Value: string);
    function  ReadMDIGrid1Property(Form: TForm; Name: string): string;
    procedure WriteProperty(Section, Name, Value: string);
    function  ReadProperty(Section, Name: string; Def: string = ''): string;
    procedure WriteInterfaceSettings(Style: string; ToQuit: Integer; FormsN: Integer; DlgsN: Integer; ToDef: Boolean = False);
    procedure ReadInterfaceSettings(ReadDefault: Boolean = False);
    procedure SetStyle;
    function  IsDefaultExists(Section: string; Grid: TDBGridEh): Boolean;
 //   property CurrGridWriteDoDef: Boolean  read GetCurrGridWriteDoDef write SetCurrGridWriteDoDef;

    procedure WriteFrDBGridEhSettings(Section: string; Grid: TFrDBGridEh; ToDef: Boolean = False; IsPresetMode: Boolean = False);
    procedure RestoreFrDBGridEhSettings(Section: string; Grid: TFrDBGridEh; SetDefault: Boolean = False; IsPresetMode: Boolean = False);
    function  IsDefaultFrDBGridEhSettingsExists(Section: string; Grid: TFrDBGridEh): Boolean;

    //пресеты грида (см. опцию myogUsePresets у TFrDBGridEh) - именованные наборы настроек грида (видимость/
    //порядок столбцов, при желании - сортировка, фильтры в столбцах, гридфильтр) с быстрым переключением.
    //личные пресеты видны только своему автору, общие - всем пользователям модуля (создание/удаление общих
    //пресетов требует права rAdm_Other_InterfaceAdmin). если у грида задан Grid2 (связанный грид в детальной
    //панели), настройки обоих гридов сохраняются/восстанавливаются одним пресетом
    function  GridPresetSection(const Section, APresetName: string): string;
    function  GetGridPresetNames(Section: string; out Personal, Shared: TStringDynArray): Boolean;
    function  GridPresetExists(Section: string; const PresetName: string; AShared: Boolean): Boolean;
    function  GetGridPresetFlags(Section: string; const PresetName: string; AShared: Boolean;
                out AIncludeSort, AIncludeColumnFilters, AIncludeGridFilter: Boolean): Boolean;
    procedure SaveGridPreset(Section: string; Grid: TFrDBGridEh; const PresetName: string; AShared: Boolean;
                AIncludeSort: Boolean = True; AIncludeColumnFilters: Boolean = True; AIncludeGridFilter: Boolean = True);
    procedure ApplyGridPreset(Section: string; Grid: TFrDBGridEh; const PresetName: string; AShared: Boolean);
    procedure DeleteGridPreset(Section: string; const PresetName: string; AShared: Boolean);

  end;

var
  Settings: TSettings;

implementation

uses
  VCL.Themes,
  uSys,
  uForms,
  uMessages,

  uFrmMain
  ;

const
  //переключатель алгоритма восстановления порядка столбцов детального грида (см. RestoreFrDBGridEhSettings).
  //True - новый алгоритм: та же сборка целевого порядка (va), но переиндексация обернута в BeginUpdate/EndUpdate
  //+ LayoutChanged (как это делает сам EhLib в оригинальном TCustomDBGridEh.RestoreColumnsLayoutProducer), и
  //отдельная "битая" запись (сохраненное имя поля, которого больше нет в гриде) пропускается без прерывания
  //всего цикла. False - старый алгоритм (с тем же минимальным фиксом пропуска битой записи, но без
  //BeginUpdate/EndUpdate/LayoutChanged) - оставлен для быстрого отката/сравнения, если новый алгоритм
  //проявит себя хуже на реальных данных
  cUseNewGridColumnReorderAlgorithm: Boolean = True;

  //маркер, отделяющий имя секции пресета от имени секции обычных (авто-сохраняемых) настроек грида (см.
  //GridPresetSection). личные пресеты хранятся в M (как обычные личные настройки), общие - в MA (как
  //настройки "по умолчанию"); в остальном формат данных внутри секции идентичен обычным настройкам
  cGridPresetSectionMarker = '~Preset~';

//создаем ИНИ-Файл либо пользовательский, либо дефолтный
//дефолтный используется если в пользовательском не найдена секция, если ForceToUser (ставить при записи в файл!) то всегда пользовательский
//каталоги при их отсутствии создаются, в папке из которой запускается программа
//ВАЖНО!!!
//после чтения из БД (или при записи?) - (а не после чтения из настроечного файла!) крайние справа в строке записываемого параметра #1, #2... и пробелы удаляются!!!


constructor TSettings.Create;
begin
  inherited;
  M:=TMemIniFile.Create('');
  MA:=TMemIniFile.Create('');
  MAChanged:=False;
  CurrGridWriteDoDef:=False;
end;

procedure TSettings.Save;
var
  S:TStringList;
begin
  S:=TStringList.Create;
  M.GetStrings(S);
//  S.SaveToFile('r:\123');
  User.SaveCfgToDB(S.Text);
  if MAChanged then begin
    S.Text:='';
    MA.GetStrings(S);
//  S.SaveToFile('r:\1234');
    User.SaveCfgToDB(S.Text, True);
  end;
  S.Free;
end;

procedure TSettings.Load;
var
  S:TStringList;
begin
  S:=TStringList.Create;
  S.Text:=User.LoadCfgFromDB;
  M.SetStrings(S);
  S.Text:=User.LoadCfgFromDB(True);
  MA.SetStrings(S);
  S.Free;
end;

procedure TSettings.SaveWindowPos(Form: TForm; Section: string);
begin
  M.WriteInteger(Section + '.WINDOW', 'width', Form.Width);
  M.WriteInteger(Section + '.WINDOW', 'height', Form.Height);
  M.WriteInteger(Section + '.WINDOW', 'left', Form.Left);
  M.WriteInteger(Section + '.WINDOW', 'top', Form.Top);
  M.WriteBool(Section + '.WINDOW', 'maximized', Form.WindowState = wsMaximized);
end;

procedure TSettings.RestoreWindowPos(Form: TForm; Section: string);
var
  DW, DH, W, H, L, T: Integer;
  WorkArea: TRect;
begin
  if not M.SectionExists(Section + '.WINDOW') then
    Exit;
  try
    with Form do begin
      with M do begin
        if (Form = FrmMain) and M.ReadBool(Section + '.WINDOW', 'maximized', True) then begin
          WindowState := wsMaximized;
          Exit;
        end;
        WindowState := wsNormal;
        SystemParametersInfo(SPI_GETWORKAREA, 0, @WorkArea, 0);
        with WorkArea do begin
          DW := Right - Left;
          DH := Bottom - Top;
        end;
        W := Min(ReadInteger(Section + '.WINDOW', 'width', Width), DW);
        H := Min(ReadInteger(Section + '.WINDOW', 'height', Height), DH);
        L := Max(ReadInteger(Section + '.WINDOW', 'left', Left), 0);
        T := Max(ReadInteger(Section + '.WINDOW', 'top', Top), 0);
        if (L + W > DW) then
          L := Max(0, DW - W);
        if (T + H > DH) then
          T := Max(0, DH - H);
        Left := L;
        //T := Max(FrmMain.lbl_GetTop.Top, T);
        Top := T;
//        if not (Form is TFrmBasicMdi) or (myfoSizeable in TFrmBasicMdi(Form).MyFormOptions) then begin
        if Form.BorderStyle = bsSizeable then begin
          Width := W;
          Height := H;
        end;
//        SetBounds(L, T, W, H);
      end
    end;
  except
  end;
end;

{procedure TSettings.Write(Section: string; Name: string; Value: Variant);
var
  i:Integer;
begin
  i:=U.IndexOfName(Section + '.' + Name);
  if i <> -1 then U.Delete(i);
  U.Add(Section + '.' + Name + '=' + VarToStr(Value))
end;

function TSettings.Read(Section: string; Name: string; DefaultValue: Variant): Variant;
var
  i:Integer;
begin
  i:=U.IndexOfName(Section + '.' + Name);
  if i = -1
    then Result:=DefaultValue
    else Result:=U.ValueFromIndex[i];
end;
}


procedure TSettings.SetCurrGridWriteDoDef(Value: Boolean);
begin
  CurrGridWriteDoDef:= Value;
end;

function TSettings.GetCurrGridWriteDoDef: Boolean;
begin
  Result:= CurrGridWriteDoDef;
end;

procedure TSettings.EnsureGrid2Prepared(Grid: TFrDBGridEh);
//Grid.Grid2 (детальная панель строки, см. myogRowDetailPanel) готовится (IsPrepared становится True) лениво -
//только когда пользователь раскрыл детальную панель хотя бы у одной строки (см.
//TFrDBGridEh.DbGridEh1RowDetailPanelShow, который в этот момент вызывает Grid2.RefreshGrid). если ни одна
//строка не была раскрыта, Grid2.IsPrepared=False, и настройки Grid2 недоступны для сохранения/восстановления
//в пресете - поэтому перед операциями с пресетом принудительно готовим Grid2 тем же способом (Grid2.RefreshGrid),
//если у грида вообще включена детальная панель (иначе, если она не раскрыта пользователем, ничего не делаем)
begin
  if (myogRowDetailPanel in Grid.Options) and Assigned(Grid.Grid2) and not Grid.Grid2.IsPrepared then
    Grid.Grid2.RefreshGrid;
end;

procedure TSettings.WriteProperty(Section, Name, Value: string);
begin
  //заключим в кавычки
  M.WriteString(Section, Name, ''''+Value+'''');
end;

function TSettings.ReadProperty(Section, Name: string; Def: string = ''): string;
begin
  //если в кавычках, то отбросим (проверка нужна, тк сначала было сделано без кавычек)
  Result:= M.ReadString(Section, Name, ''''+Def+'''');
  if Result[1] = '''' then Result:=copy(Result,2,Length(Result)-2);
end;

procedure TSettings.WriteMDIGrid1Property(Form: TForm; Name, Value: string);
begin
{  if (Form is TForm_MDI_Grid1)
    then begin
      M.WriteString(TForm_MDI_Grid1(Form).FormDoc, Name, Value);
    end;}
end;

function TSettings.ReadMDIGrid1Property(Form: TForm; Name: string): string;
begin
{  if Form is TForm_MDI_Grid1
    then begin
      Result:= M.ReadString(TForm_MDI_Grid1(Form).FormDoc, Name, '');
    end;}
end;

procedure TSettings.WriteFormSettings(Form: TForm);
begin
{  if (Form is TForm_MDI_Grid1)
    then begin
      M.WriteString(TForm_MDI_Grid1(Form).FormDoc, 'FilterV1', TForm_MDI_Grid1(Form).FilterStr);
    end;}
end;

procedure TSettings.RestoreFormSettings(Form: TForm);
begin
{  if Form is TForm_MDI_Grid1
    then begin
      TForm_MDI_Grid1(Form).FilterStr:= M.ReadString(TForm_MDI_Grid1(Form).FormDoc, 'FilterV1', '');
    end;}
end;

procedure TSettings.WriteInterfaceSettings(Style: string; ToQuit: Integer; FormsN: Integer; DlgsN: Integer; ToDef: Boolean = False);
var
  MC: TMemIniFile;
begin
  if ToDef
    then begin
      MC:=MA; MAChanged:= True; //CurrGridWriteDoDef:=False
    end
    else MC:=M;
  MC.WriteString('INTERFACE', 'StyleName', Style);
  MC.WriteInteger('INTERFACE', 'ToQuit',  ToQuit);
  MC.WriteInteger('INTERFACE', 'FormsN',  FormsN);
  MC.WriteInteger('INTERFACE', 'DlgsN',  DlgsN);
  InterfaceStyle:=Style;
  InterfaceQuit:=ToQuit;
  InterfaceFormsN:=FormsN;
  InterfaceDialogsN:=DlgsN;
end;

procedure TSettings.ReadInterfaceSettings(ReadDefault: Boolean = False);
var
  MC: TMemIniFile;
const
  Section = 'INTERFACE';
begin
  if M.SectionExists(Section) and not ReadDefault then MC:= M else MC:= MA;
  InterfaceStyle := MC.ReadString(Section, 'StyleName', '');
  InterfaceQuit := MC.ReadInteger(Section, 'ToQuit', 0);
  InterfaceFormsN := MC.ReadInteger(Section, 'FormsN', 0);
  InterfaceDialogsN := MC.ReadInteger(Section, 'DlgsN', 1);
end;

procedure TSettings.SetStyle;
var
  StyleInfo: TStyleInfo;
  Handle:TStyleManager.TStyleServicesHandle;
  FileName: string;
begin
  FileName:= Module.GetPath_Styles + '\' + InterfaceStyle;
  if not FileExists(FileName) then FileName:='';
  if (FileName <> '') and TStyleManager.IsValidStyle(FileName,StyleInfo)=True then  begin
     //проверяем возможность подключения стиля
     if TStyleManager.TrySetStyle(StyleInfo.Name,False)=False then
     begin
       //стиль следует загрузить и зарегистрировать
       Handle:=TStyleManager.LoadFromFile(FileName);
       TStyleManager.SetStyle(Handle);
       Exit;
     end;
  end;
  TStyleManager.SetStyle('windows');
end;

function  TSettings.IsDefaultExists(Section: string; Grid: TDBGridEh): Boolean;
begin
  Result:=MA.SectionExists(Section);
  Result:= Result and (MA.ReadString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), '--') <> '--');
end;

procedure TSettings.WriteGridSettings(Section: string; Grid: TDBGridEh; ToDef: Boolean = False);
var
  I: Integer;
  St: string;
  col: TColumnEh;
  b: Boolean;
  MC: TMemIniFile;
begin
  if ToDef //or CurrGridWriteDoDef
    then begin
      MC:=MA; MAChanged:= True; //CurrGridWriteDoDef:=False
    end
    else MC:=M;
  for i:= 0 to Grid.Columns.Count - 1 do
    begin
      col := Grid.Columns[i];
      St:= Format('%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d', [col.Index,
        col.Width,
        Integer(col.Title.SortMarker),
        Integer(col.Visible),
        col.Title.SortIndex,
        col.DropDownRows,
        col.DropDownWidth,
        col.InRowLinePos,
        col.InRowLineHeight,
        Integer(col.WordWrap),
        Integer(col.AutoFitColWidth)
        ]);
      MC.WriteString(Section, Format('%s.%s', [Grid.Name, col.FieldName]), St);
    end;
  St := Format('%d,%d,%d,%d,%d,%d,%d,%d,%d,%d', [
    Integer(Grid.SearchPanel.Enabled),
    Integer(Grid.SearchPanel.FilterOnTyping),
    Integer(dghAutoSortMarking in Grid.OptionsEh),
    Integer(dghMultiSortMarking in Grid.OptionsEh),
    Integer(dghAutoFitRowHeight in Grid.OptionsEh),
    Integer(dghColumnMove in Grid.OptionsEh),
    Integer(dghColumnResize in Grid.OptionsEh),
    Integer(Grid.AutoFitColWidths),
    Integer(Grid.STFilter.Visible),
    Integer(not(ToDef) and Grid.DynProps.VarExists('SaveSTFilter'))
 ]);
  MC.WriteString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), St);

  //сохраним фильтр в столбцах, если у грида установлено свойство SaveSTFilter, и это не запись дефолтных настроек
  if not(ToDef) and Grid.DynProps.VarExists('SaveSTFilter') then begin
    //запишем фильтр из всех столбцов, с указанием наименования поля столбца
    St:='';
    for i:= 0 to Grid.Columns.Count - 1 do begin
      S.ConcatStP(St, Grid.Columns[i].FieldName + #2 + Grid.Columns[i].STFilter.ExpressionStr, #1);
    end;
    //если слишком длинная строка, очистим ее
    if Length(St) > 4000 then St:='';
    MC.WriteString(Section, Format('%s.%s', [Grid.Name, '(STFilter)']), St+#1+';');
  end;
end;


procedure TSettings.RestoreGridSettings(Section: string; Grid: TDBGridEh; SetDefault: Boolean = False);
type
  TColumnInfo = record
    Column: TColumnEh;
    EndIndex: Integer;
    SortMarker: TSortMarkerEh;
    SortIndex: Integer;
  end;
const
  Delims = [' ', ','];
var
  I, J, k, n: Integer;
  St, SA, SI: string;
  ColumnArray: array of TColumnInfo;
  AAutoFitColWidth: Boolean;
  AutoFitRowHeight_: Boolean;
  col: TColumnEh;
  b: Boolean;
  IniF: tinifile;
  MC: TMemIniFile;
  a1,a2: TStringDynArray;
  ar2: TVarDynArray2;
begin

//!!!  aRegIni:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'\'+'view.ini');
{
inif:=TIniFile.Create('r:\uchet\1view.ini');
inif.writestring('QQQ','AAA','-');
inif.Free;
inif:=TIniFile.Create('r:\uchet\view.ini');
}
//RestoreParams:=[grpColIndexEh,grpColWidthsEh,grpSortMarkerEh,grpColVisibleEh,grpDropDownRowsEh,grpDropDownWidthEh,grpRowPanelColPlacementEh];
  AAutoFitColWidth := False;
  //BeginUpdate;
  try
    if (Grid.AutoFitColWidths) then
    begin
      Grid.AutoFitColWidths := False;
      AAutoFitColWidth := True;
    end;
    SetLength(ColumnArray, Grid.Columns.Count);
    try
      //проверяем есть ли запись в личных настройках для этого грида, и если нет то подключим дефолтные настройки
      //надо проверять параметр кроме секции, тк если окно было просто открыто и закрыто, то секция создастся,
      //а если в первом открытии не открывали детальный грид (не были прочитаны его настройки), то они уже и не прочитаются
      if (M.SectionExists(Section) and not SetDefault)and
         (M.ReadString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), '--') <> '--')
        then MC:= M
        else MC:= MA;
      //получим параметры, общие для грида
      St := MC.ReadString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), '--');
      if St <> '--' then
        begin
          Grid.SearchPanel.Enabled := Boolean(StrToIntDef(ExtractWord(1, St, Delims), Integer(Grid.SearchPanel.Enabled)));
          Grid.SearchPanel.FilterOnTyping := Boolean(StrToIntDef(ExtractWord(2, St, Delims), Integer(Grid.SearchPanel.FilterOnTyping)));
          b:= Boolean(StrToIntDef(ExtractWord(3, St, Delims), Integer(dghAutoSortMarking in Grid.OptionsEh)));
          if b then Grid.OptionsEh:= Grid.OptionsEh + [dghAutoSortMarking] else Grid.OptionsEh:= Grid.OptionsEh - [dghAutoSortMarking];
          b:= Boolean(StrToIntDef(ExtractWord(4, St, Delims), Integer(dghMultiSortMarking in Grid.OptionsEh)));
          if b then Grid.OptionsEh:= Grid.OptionsEh + [dghMultiSortMarking] else Grid.OptionsEh:= Grid.OptionsEh - [dghMultiSortMarking];
          b:= Boolean(StrToIntDef(ExtractWord(5, St, Delims), Integer(dghAutoFitRowHeight in Grid.OptionsEh)));
//          if b then Grid.OptionsEh:= Grid.OptionsEh + [dghAutoFitRowHeight] else Grid.OptionsEh:= Grid.OptionsEh - [dghAutoFitRowHeight];
          AutoFitRowHeight_:=b;
          b:= Boolean(StrToIntDef(ExtractWord(6, St, Delims), Integer(dghColumnMove in Grid.OptionsEh)));
          if b then Grid.OptionsEh:= Grid.OptionsEh + [dghColumnMove] else Grid.OptionsEh:= Grid.OptionsEh - [dghColumnMove];
          b:= Boolean(StrToIntDef(ExtractWord(7, St, Delims), Integer(dghColumnResize in Grid.OptionsEh)));
          if b then Grid.OptionsEh:= Grid.OptionsEh + [dghColumnResize] else Grid.OptionsEh:= Grid.OptionsEh - [dghColumnResize];
          Grid.AutoFitColWidths := Boolean(StrToIntDef(ExtractWord(8, St, Delims), Integer(Grid.AutoFitColWidths)));
          Grid.STFilter.Visible := Boolean(StrToIntDef(ExtractWord(9, St, Delims), Integer(Grid.STFilter.Visible)));
          if not(Boolean(StrToIntDef(ExtractWord(10, St, Delims), Integer(False))))
            then Grid.DynProps.DeleteDynVar('SaveSTFilter')
            else if not Grid.DynProps.VarExists('SaveSTFilter')
              then Grid.DynProps.CreateDynVar('SaveSTFilter','1');
        end;
Grid.OptionsEh:= Grid.OptionsEh - [dghAutoFitRowHeight];

      //получим массив STFilter - фильтр в стольбцах
      //в массиве [[fieldname, stfilter_string],]
      ar2:=[];
      if Grid.STFilter.Visible and Grid.DynProps.VarExists('SaveSTFilter') then begin
        SI:=M.ReadString(Section, Format('%s.%s', [Grid.Name, '(STFilter)']), '');
        if SI <> '' then begin
          a1:=A.ExplodeS(SI, #1);
          SetLength(ar2, Length(a1));
          for i:= 0 to High(a1) do begin
//!!!почему-то в этом варианте возникает ошибка
            //a2:=Ah..ExplodeV(a1[i], #2);
//            a[i]:=[a2[0], a2[1]];         //если включена вот эта срока???
//ошибки совершенно непонятные, не индексы, такое ощущение что портим память, возникают не всегда!!!
//a[i]:=[a2[0],''];
            j:=pos(#2,a1[i]);
            ar2[i]:=[#5,''];
            if j>1 then begin
              ar2[i]:=[copy(a1[i],1,j-1), copy(a1[i],j+1,40000)];
//              a[i]:=[copy(a1[i],1,j-1), 'asdasasdasd'];
            end;
          end;
        end;
      end;

    //      a:=[];
      //параметры столбцов (восстановим из выбранного файла - если есть пользовательский, то из него, иначе из общего. выбор файла был выше)
      for I := 0 to Grid.Columns.Count - 1 do
      begin
        col := Grid.Columns[i];
        St := MC.ReadString(Section, Format('%s.%s', [Grid.Name, col.FieldName]), '');
        //настройки столбца из общего файла, нужны для восстановления параметров столбца, который был добавлен в дефолт после сохранения настроек пользователя
        SA := MA.ReadString(Section, Format('%s.%s', [Grid.Name, col.FieldName]), '');
        ColumnArray[I].Column := col;
        ColumnArray[I].EndIndex := col.Index;
        b:= St <> ''; //есть пользовательские данные по столбцу
        if (St <> '')or(SA <> '') then
        begin
//          if (crpColWidthsEh in RestoreParams) then
          //если нет столбца, восстановим ширину из дефолтного
//if col.FieldName = 'COST'
//  then k := StrToIntDef(ExtractWord(2, St, Delims), -1);
//          k := StrToIntDef(ExtractWord(2, St, Delims), col.Width);
//          if not b then k:= StrToIntDef(ExtractWord(2, St.IIf(b, St, SA), Delims), col.Width);
          col.Width := StrToIntDef(ExtractWord(2, S.IIf(b, St, SA), Delims), col.Width);
          col.WordWrap := Boolean(StrToIntDef(ExtractWord(10, S.IIf(b, St, SA), Delims), Integer(Grid.Columns[I].WordWrap)));
          col.AutoFitColWidth := Boolean(StrToIntDef(ExtractWord(11, S.IIf(b, St, SA), Delims), Integer(Grid.Columns[I].AutoFitColWidth)));
          //все остальное только из пользовательского
          if b then begin
            ColumnArray[I].EndIndex := StrToIntDef(ExtractWord(1, St, Delims), ColumnArray[I].EndIndex);
  //            col.Width := StrToIntDef(ExtractWord(2, St, Delims), col.Width);
  //          if (crpSortMarkerEh in RestoreParams) then
            if True then
              col.Title.SortMarker := TSortMarkerEh(StrToIntDef(ExtractWord(3, St, Delims),
                Integer(col.Title.SortMarker)));
  //          if (crpColVisibleEh in RestoreParams) then
            if True then
              col.Visible := Boolean(StrToIntDef(ExtractWord(4, St, Delims), Integer(col.Visible)));
              //скрываем все столбцы, заголовки которых начинаются на _
  //          if (crpSortMarkerEh in RestoreParams) then
            if True then
              ColumnArray[I].SortIndex := StrToIntDef(ExtractWord(5, St, Delims), 0);
  //          if (crpDropDownRowsEh in RestoreParams) then
              col.DropDownRows := StrToIntDef(ExtractWord(6, St, Delims), col.DropDownRows);
  //          if (crpDropDownWidthEh in RestoreParams) then
              col.DropDownWidth := StrToIntDef(ExtractWord(7, St, Delims), col.DropDownWidth);
    //        if (crpRowPanelColPlacementEh in RestoreParams) then
            if True then
            begin
              col.InRowLinePos := StrToIntDef(ExtractWord(8, St, Delims), col.InRowLinePos);
              col.InRowLineHeight := StrToIntDef(ExtractWord(9, St, Delims), col.InRowLineHeight);
            end;

            //для видимых колонок установим значения фильтра, если он был загружен
            //сопоставление столбцов проводим по имени поля
            if Col.Visible and (High(ar2) >=0) then begin
              for n:=0 to High(ar2)-1 do begin
                if ar2[n][0] = Col.FieldName then begin
                  try
                  if ar2[n][1] <> '' then Col.STFilter.ExpressionStr:=ar2[n][1];
                  except
                  end;
                end;
              end;
            end;
          end;
        end;
        if Pos('_', col.Title.Caption) = 1
          then col.Visible:=False;
        col.MinWidth:=25; //!!!
      end;
//      if (crpSortMarkerEh in RestoreParams) then
      if True then
      begin
        for I := 0 to Grid.Columns.Count - 1 do
          Grid.Columns[i].Title.SortIndex := ColumnArray[I].SortIndex;
      end;
//      if (crpColIndexEh in RestoreParams) then
          if True then
      begin
        for I := 0 to Grid.Columns.Count - 1 do
        begin
          for J := 0 to Grid.Columns.Count - 1 do
          begin
            if ColumnArray[J].EndIndex = I then
            begin
              ColumnArray[J].Column.Index := ColumnArray[J].EndIndex;
              Break;
            end;
          end;
        end;
      end;
    finally
      SetLength(ColumnArray, 0);
    end;
  finally
    Grid.StFilter.Local:=True;
    Grid.SortLocal:=True;
{   for I := 0 to Grid.Columns.Count - 1 do
      begin
            //для видимых колонок установим значения фильтра, если он был загружен
            //сопоставление столбцов проводим по имени поля
            if (High(ar2) >=0) then begin
              for n:=0 to High(ar2)-1 do begin
                if ar2[n][0] = Col.FieldName then begin
                  if ar2[n][1] <> '' then Col.STFilter.ExpressionStr:=ar2[n][1];
                end;
              end;
            end;
      end;   }
    //если быд загружен текст фильра, то применим фильтр
    if High(ar2)>=0 then begin
      Grid.DefaultApplyFilter;
    end;
  { for I := 0 to Grid.Columns.Count - 1 do
      begin
          col.WordWrap := Boolean(StrToIntDef(ExtractWord(10, S.IIf(b, St, SA), Delims), Integer(Grid.Columns[I].WordWrap)));
          col.AutoFitColWidth := Boolean(StrToIntDef(ExtractWord(11, S.IIf(b, St, SA), Delims), Integer(Grid.Columns[I].AutoFitColWidth)));
    end;}
    if AutoFitRowHeight_ then Grid.OptionsEh:= Grid.OptionsEh + [dghAutoFitRowHeight] else Grid.OptionsEh:= Grid.OptionsEh - [dghAutoFitRowHeight];


  {    Grid.StFilter.Local:=True;
    Grid.SortLocal:=True;
    //если быд загружен текст фильра, то применим фильтр
    if High(ar2)>=0 then begin
      Grid.DefaultApplyFilter;
    end;}
    if Grid.AutoFitColWidths then begin
      Grid.OptimizeAllColsWidth(-1, 2);
    end;
  end;
end;

{фрейм грида. сохранение и восстановление настроек}

function TSettings.IsDefaultFrDBGridEhSettingsExists(Section: string; Grid: TFrDBGridEh): Boolean;
//проверим, существуют ли дефолтные настройки для переданного фрейма грида
begin
  Result:=MA.SectionExists(Section);
  Result:= Result and (MA.ReadString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), '--') <> '--');
end;

procedure TSettings.WriteFrDBGridEhSettings(Section: string; Grid: TFrDBGridEh; ToDef: Boolean = False; IsPresetMode: Boolean = False);
//запись настроек грида в ини-файл (в поле БД)
//данные сохраняются в секциях, соответствующих FormDoc родительского окна
//строки начинаются с именти фрейма грида, далее через точку тип значение (.(Version), (.Settings), (.Filter) или имя столбца
var
  i, j, k: Integer;
  st, st1: string;
  b: Boolean;
  MC: TMemIniFile;
  col: TColumnEh;
  o : TFrDBGridOption;
  fr: TFrDBGridRecFieldsList;
  va: TVarDynArray;
begin
  //не сохраняем настройки при закрытом датасете, они будут неправильные
  if not Grid.MemTableEh1.Active then
    Exit;
  //выберем файл для записи - пользовательский или дефолтный
  if ToDef
    then begin
      MC:=MA; MAChanged:= True;
    end
    else MC:=M;
  //сохраним версию настроек
  MC.WriteString(Section, Format('%s.%s', [Grid.Name, '(Version)']), '1');
  //сохранение опций фрейма, которые могут записываться ф настройки
  st := '';
  for o in FrDBGridOptionSave do begin
    S.ConcatStP(st, IntToStr(ord(o)) + #2 + IntToStr(Integer(o in Grid.Options)), #1);
  end;
  MC.WriteString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), St);
  //дополнительные параметры (пока только имя замороженного столбца)
  st := Grid.Opt.FrozenColumn;
  MC.WriteString(Section, Format('%s.%s', [Grid.Name, '(AddSettings)']), St);
  if myogPanelFilter in Grid.Options
    then st := '';
  //сохраним фильтр в столбцах, если у грида установлено свойство SaveSTFilter, и это не запись дефолтных настроек
  //(а не пресета - при сохранении пресета (IsPresetMode) фильтры столбцов пишем даже в общий (MA) пресет,
  //иначе общий пресет не смог бы донести настроенные фильтры столбцов до других пользователей).
  //!!!для пресета (IsPresetMode) пишем фильтры столбцов ВСЕГДА, вне зависимости от myogSaveFilter - это опция
  //обычного (непресетного) поведения грида ("сохранять фильтр столбцов в обычных настройках"), у большинства
  //гридов она не установлена, но это не должно мешать пресету (у которого есть собственный независимый флаг
  //AIncludeColumnFilters, см. SaveGridPreset/ApplyGridPreset) захватывать и восстанавливать фильтры столбцов
  if (not(ToDef) or IsPresetMode) and (IsPresetMode or (myogSaveFilter in Grid.Options)) then begin
    //запишем фильтр из всех столбцов, с указанием наименования поля столбца
    St:='';
    for i:= 0 to Grid.DbGridEh1.Columns.Count - 1 do begin
      S.ConcatStP(St, Grid.DbGridEh1.Columns[i].FieldName + #2 + Grid.DbGridEh1.Columns[i].STFilter.ExpressionStr, #1);
    end;
    //если слишком длинная строка, очистим ее
    if Length(St) > 4000 then St:='';
    MC.WriteString(Section, Format('%s.%s', [Grid.Name, '(Filter)']), St+#1+';');
  end;
  //параметры фильтра в окне
  MC.WriteString(Section, Format('%s.%s', [Grid.Name, '(DefFilter)']), Grid.Opt.FilterResult);
  //сохраним настройки столбцов грида
  st := '';
  for i:= 0 to Grid.DbGridEh1.Columns.Count - 1 do begin
    col := Grid.DbGridEh1.Columns[i];

    fr := Grid.Opt.GetFieldRec(col.FieldName);
    st1 := '0';
    if i > 0 then
      st1 := Grid.DbGridEh1.Columns[i - 1].FieldName;
    S.ConcatStP(st, A.Implode([
      col.FieldName,
      st1,
      col.Width,
      Integer(fr.Visible),
      Integer(col.Title.SortMarker),
      col.Title.SortIndex,
      Integer(col.WordWrap),
      Integer(col.AutoFitColWidth),
      col.DropDownRows,
      col.DropDownWidth,
      col.InRowLinePos,
      col.InRowLineHeight
      ], #2), #1);
   end;
   MC.WriteString(Section, Format('%s.%s', [Grid.Name, '(Columns)']), St);
   //TmyCustomDBGridEh(Grid.DbGridEh1).CallSaveGridLayoutProducer(MC, Section + '_' + Grid.Name + '_GridLayout', False); //+++
   va:=A.Explode(st, #1);
   va:=A.Explode(va[0], #2);
end;

procedure TSettings.RestoreFrDBGridEhSettings(Section: string; Grid: TFrDBGridEh; SetDefault: Boolean = False; IsPresetMode: Boolean = False);
type
  TColumnInfo = record
    Column: TColumnEh;
    EndIndex: Integer;
    SortMarker: TSortMarkerEh;
    SortIndex: Integer;
    PrevCol: string;
  end;
const
  Delims = [' ', ','];
var
  i, j, k, n, p: Integer;
  st, sa, si: string;
  col: TColumnEh;
  ColumnArray: array of TColumnInfo;
  va, va1 : TVarDynArray;
  a1,a2: TStringDynArray;
  ar2: TVarDynArray2;
  b: Boolean;
  MC: TMemIniFile;
  o : TFrDBGridOption;
  AAutoFitColWidth: Boolean;
  AutoFitRowHeight_: Boolean;
  oplus, ominus : TFrDBGridOptions;
  fr: TFrDBGridRecFieldsList;
  cols, colsd : TVarDynArray2;
  FieldNames: array of string;

(*

/// <summary>
/// Формирует порядок отображения столбцов.
/// </summary>
/// <param name="CurrentFieldNames">
/// Массив имён всех существующих полей в дефолтном порядке (из Grid.Opt.Sql.Fields).
/// </param>
/// <param name="PreviousOrder">
/// Предыдущий порядок отображения (TVarDynArray из cols).
/// </param>
/// <returns>
/// TVarDynArray с именами в правильном порядке.
/// </returns>
function ReorderColumns(const CurrentFieldNames: array of string;
  const PreviousOrder: TVarDynArray): TVarDynArray;
var
  ExistingSet: TDictionary<string, Integer>;   // для быстрой проверки наличия
  ResultList: TList<string>;                    // строящийся порядок
  i, j, insertPos: Integer;
  name: string;
  prevName: string;
begin
  // Множество всех актуальных имён (для фильтрации PreviousOrder)
  ExistingSet := TDictionary<string, Integer>.Create;
  try
    for i := 0 to High(CurrentFieldNames) do
      ExistingSet.Add(CurrentFieldNames[i], i);

    ResultList := TList<string>.Create;
    try
      // 1. Берём только те столбцы из PreviousOrder, которые ещё существуют
      for i := 0 to Length(PreviousOrder) - 1 do
      begin
        name := VarToStr(PreviousOrder[i]);
        if ExistingSet.ContainsKey(name) then
          ResultList.Add(name);
      end;

      // 2. Вставляем недостающие поля в соответствии с дефолтным порядком
      for i := 0 to High(CurrentFieldNames) do
      begin
        name := CurrentFieldNames[i];
        // Если имя уже есть в результате — пропускаем
        if ResultList.Contains(name) then
          Continue;

        // Определяем позицию вставки:
        // ищем ближайшего предшественника по CurrentFieldNames,
        // который уже присутствует в ResultList
        insertPos := 0; // по умолчанию в начало
        for j := i - 1 downto 0 do
        begin
          prevName := CurrentFieldNames[j];
          if ResultList.Contains(prevName) then
          begin
            insertPos := ResultList.IndexOf(prevName) + 1;
            Break;
          end;
        end;

        // Вставляем новое имя
        ResultList.Insert(insertPos, name);
      end;

      // 3. Преобразуем TList<string> в TVarDynArray
      SetLength(Result, ResultList.Count);
      for i := 0 to ResultList.Count - 1 do
        Result[i] := ResultList[i];

    finally
      ResultList.Free;
    end;
  finally
    ExistingSet.Free;
  end;
end; *)

begin
//exit;
  try
    oplus := [];
    ominus := [];
    SetLength(ColumnArray, Grid.DbGridEh1.Columns.Count);
    if (M.SectionExists(Section) and not SetDefault) and (M.ReadString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), '--') <> '--') then
      MC := M
    else
      MC := MA;

  //параметры фильтра в окне; читаем даже при неактивном гриде, так как фильтр влияет на параметры загрузки данных
    Grid.Opt.FilterResult := MC.ReadString(Section, Format('%s.%s', [Grid.Name, '(DefFilter)']), '');
  //выйдем, если мемтейбл не открыт
    if not Grid.MemTableEh1.Active then
      Exit;


  //получим параметры, общие для грида
    st := MC.ReadString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), '--');
    if st <> '--' then begin
      va := A.Explode(st, #1);
      for i := 0 to High(va) do begin
        va1 := A.Explode(va[i], #2);
        if va1[1] = '0' then
          ominus := ominus + [TFrDBGridOption(va1[0])]
        else
          oplus := oplus + [TFrDBGridOption(va1[0])];
      end;
      //получим массив STFilter - фильтр в стольбцах
      //в массиве [[fieldname, stfilter_string],]
      ar2 := [];
      //!!!см. аналогичный комментарий в WriteFrDBGridEhSettings - для пресета (IsPresetMode) читаем фильтры
      //столбцов ВСЕГДА, вне зависимости от того, был ли myogSaveFilter установлен у грида на момент сохранения
      //пресета (иначе Write мог записать (Filter), а Read его бы никогда не прочитал)
      if IsPresetMode or (myogSaveFilter in oplus) then begin
        //обычная логика (не пресет) сознательно всегда берет фильтр из M, даже если MC = MA (SetDefault) - это
        //поведение оставлено как было. при восстановлении пресета (IsPresetMode) читаем из MC - то есть оттуда,
        //куда реально был записан пресет (M для личного, MA для общего) - см. Write, там аналогичная логика
        if IsPresetMode
          then si := MC.ReadString(Section, Format('%s.%s', [Grid.Name, '(Filter)']), '')
          else si := M.ReadString(Section, Format('%s.%s', [Grid.Name, '(Filter)']), '');
        if si <> '' then begin
          a1 := A.ExplodeS(si, #1);
          SetLength(ar2, Length(a1));
          for i := 0 to High(a1) do begin
            j := pos(#2, a1[i]);
            ar2[i] := [#5, ''];
            if j > 1 then begin
              ar2[i] := [copy(a1[i], 1, j - 1), copy(a1[i], j + 1, 40000)];
            end;
          end;
        end;
      end;
    end;

  //дополнительные параметры (пока только имя замороженного столбца)
    st := MC.ReadString(Section, Format('%s.%s', [Grid.Name, '(AddSettings)']), '');
    va := A.Explode(st, #1);
    Grid.Opt.FrozenColumn := va[0];

    st := MC.ReadString(Section, Format('%s.%s', [Grid.Name, '(Columns)']), '--');
    va := A.Explode(st, #1);
    cols := [];
    if st <> '--' then
      for i := 0 to High(va) do
        A.VarDynArray2InsertArr(cols, A.Explode(va[i], #2));

    st := MC.ReadString(Section, Format('%s.%s', [Grid.Name, '(Columns)']), '--');
    va := A.Explode(st, #1);
    colsd := [];
    if st <> '--' then
      for i := 0 to High(va) do
        A.VarDynArray2InsertArr(colsd, A.Explode(va[i], #2));

    for i := 0 to High(colsd) do
      if A.PosInArray(colsd[i][0], cols, 0, True) < 0 then
        A.VarDynArray2InsertArr(cols, A.VarDynArray2RowToVD1(colsd, i));

  //нужно для простановки маркеров сортировки, если их несколько!
    Grid.DBGridEh1.OptionsEh := Grid.DBGridEh1.OptionsEh + [dghAutoSortMarking, dghMultiSortMarking];
    for i := 0 to Grid.DbGridEh1.Columns.Count - 1 do begin
      col := Grid.DbGridEh1.Columns[i];
      p := A.PosInArray(col.FieldName, cols, 0, True);
      if p < 0 then
        Continue;
      col.Width := Strtoint(cols[p][2]);
      Grid.Opt.SetFieldVisible(col.FieldName, Boolean(StrToIntDef(cols[p][3], Integer(col.Visible))));
      col.Title.SortIndex := StrToIntDef(cols[p][5], 0);
      col.Title.SortMarker := TSortMarkerEh(StrToIntDef(cols[p][4], Integer(col.Title.SortMarker)));
      col.WordWrap := Boolean(StrToIntDef(cols[p][6], Integer(col.WordWrap)));
      col.AutoFitColWidth := Boolean(StrToIntDef(cols[p][7], Integer(col.AutoFitColWidth)));
      col.DropDownRows := StrToIntDef(cols[p][8], col.DropDownRows);
      col.DropDownWidth := StrToIntDef(cols[p][9], col.DropDownWidth);
      col.InRowLinePos := StrToIntDef(cols[p][10], col.InRowLinePos);
      col.InRowLineHeight := StrToIntDef(cols[p][11], col.InRowLineHeight);
    end;
  //Grid.TestCompareFC;
  //второй проход
    for i := 0 to Grid.DbGridEh1.Columns.Count - 1 do begin
      col := Grid.DbGridEh1.Columns[i];
      p := A.PosInArray(col.FieldName, cols, 0, True);
      if p < 0 then
        Continue;
      fr := Grid.Opt.GetFieldRec(col.FieldName);
    //для видимых колонок установим значения фильтра, если он был загружен
    //сопоставление столбцов проводим по имени поля
      if fr.Visible and (High(ar2) >= 0) then
        for n := 0 to High(ar2) - 1 do
          if (ar2[n][0] = col.FieldName) and (ar2[n][1] <> '') then
          //может быть ошибка из-за несовпадения форматов чисел/дат при сохранении и чтении
          try
            col.STFilter.ExpressionStr := ar2[n][1];
          except
          end;
    end;

  {установим порядок стлбцов. в настройках сохранены имена столбца, идущего перед данным}
  //создадим мааасив имен полей в том порядке, как соотвествующие столбцы должны отображаться, по всем сохраненным столбцам
    va := [];
    st := '0';
    for j := 0 to high(cols) do begin
      for i := 0 to high(cols) do
        if cols[i][1] = st then begin
          va := va + [cols[i][0]];
          st := cols[i][0];
          Break;
        end;
    end;

  //удалим записи с полями, которых более нет в таблице
    for i := High(va) downto 0 do
      if Grid.DbGridEh1.FindFieldColumn(va[i]) = nil then
        Delete(va, i, 1);
  //вставим имена полей, которые есть в таблице определения полей, но нет в сохраненных
  //вставляем так, чтобы он шел за столбцом, который расположен перед ним в описании полей в коде
    st := '0';
    for i := 0 to High(Grid.Opt.Sql.Fields) do begin
      p := A.PosInArray(Grid.Opt.Sql.Fields[i].Name, va, True);
      if i > 0 then
        st := Grid.Opt.Sql.Fields[i - 1].Name;
      if p < 0 then
        if st = '0' then
          Insert(Grid.Opt.Sql.Fields[i].Name, va, 0)
        else begin
          j := A.PosInArray(st, va, True);
          if j >= 0 then
            Insert(Grid.Opt.Sql.Fields[i].Name, va, j + 1)
          else
            va := va + [Grid.Opt.Sql.Fields[i].Name]
        end;
    end;
    //изменим порядок столбцов.
    //!!! в каких-то случаях похоже логическая ошибка при переиндексации, хотя если проверить все стобцы в гриде есть и до и после процедуры, все индексы идут подряд, и их столько же,
    //но в программе в дбгридех исчезают в отображегнии столбцы слева и в ячейках оказываются не те данные, хотя при этом соотвествие и количество
    //в определении полей и гриде также сохраняются (проверяем  Grid.TestCompareFC;)
    //случилось только в деитальной таблице заказов у пользователей при изменении в коде определения полей.
    //также в одном гриде на этой строке может возникать ошибка!
    //
    //РАЗБОР: старая версия оборачивала весь цикл в try/except без какого-либо действия внутри - если
    //FindFieldColumn(va[i]) возвращал nil (сохраненное имя поля больше не соответствует ни одному текущему
    //столбцу), .Index на nil валил исключение, которое try/except молча гасил, но ПРИ ЭТОМ обрывал весь
    //ОСТАЛЬНОЙ цикл - все столбцы, идущие в va после сбойного, оставались с индексами от предыдущего открытия
    //окна. Это объясняет случаи со видимым исключением на этой строке (см. переписку), но не объясняет
    //устойчивый (без исключения) сдвиг именно в загруженной столбцами детальной таблице заказов: там
    //"заголовки верны, а данные в ячейках уезжают" - это похоже на то, что часть внутренних кэшей грида
    //(сопоставление "сырого"/видимого столбца данным в ячейках) не пересчитывается корректно после серии
    //Column.Index:=, если не оборачивать это в BeginUpdate/EndUpdate + завершающий LayoutChanged - именно так
    //поступает сам EhLib в оригинальном TCustomDBGridEh.RestoreColumnsLayoutProducer (см. присланный код).
    //ниже - оба варианта, переключаемые константой cUseNewGridColumnReorderAlgorithm выше, чтобы можно было
    //быстро сравнить/откатиться, если новый вариант проявит себя хуже на реальных данных.
    if cUseNewGridColumnReorderAlgorithm then begin
      //новый алгоритм: пропуск отдельной "битой" записи (Continue) вместо прерывания всего цикла +
      //BeginUpdate/EndUpdate/LayoutChanged вокруг переиндексации (через "cracker"-helper из uForms.pas,
      //т.к. эти методы protected)
      Grid.DbGridEh1.CallBeginUpdate;
      try
        for i := 0 to High(va) do begin
          col := Grid.DbGridEh1.FindFieldColumn(va[i]);
          if col = nil then
            Continue;
          if col.Index <> i then
            col.Index := i;
        end;
      finally
        Grid.DbGridEh1.CallEndUpdate;
        Grid.DbGridEh1.CallLayoutChanged;
      end;
    end
    else begin
      //старый алгоритм с минимальным фиксом (пропуск битой записи вместо try/except на весь цикл),
      //без BeginUpdate/EndUpdate/LayoutChanged - для сравнения/отката через константу выше
      for i := 0 to High(va) do begin
        col := Grid.DbGridEh1.FindFieldColumn(va[i]);
        if col = nil then
          Continue;
        if col.Index <> i then
          col.Index := i;
      end;
    end;

    Grid.Options := Grid.Options + oplus - ominus;
  finally
  end;


end;

{пресеты фрейма грида (см. myogUsePresets)}

function TSettings.GridPresetSection(const Section, APresetName: string): string;
//имя секции, в которой хранится конкретный пресет - обычная секция грида (Section, = FormDoc) с добавленным
//маркером и очищенным от недопустимых для ини-секции символов именем пресета
var
  Nm: string;
  i: Integer;
const
  cMaxPresetNameLen = 60;
begin
  Nm := Trim(APresetName);
  for i := Length(Nm) downto 1 do
    if CharInSet(Nm[i], ['[', ']', '=', #13, #10]) then
      Delete(Nm, i, 1);
  if Length(Nm) > cMaxPresetNameLen then
    Nm := Copy(Nm, 1, cMaxPresetNameLen);
  Result := Section + cGridPresetSectionMarker + Nm;
end;

function TSettings.GetGridPresetNames(Section: string; out Personal, Shared: TStringDynArray): Boolean;
//список имен пресетов для секции (=FormDoc) грида - отдельно личные (из M) и общие (из MA).
//отдельного реестра имен не ведем - список стоится по факту существующих в ини-файле секций с нужным префиксом
var
  Sections: TStringList;
  i: Integer;
  Prefix: string;
begin
  Personal := [];
  Shared := [];
  Prefix := Section + cGridPresetSectionMarker;
  Sections := TStringList.Create;
  try
    M.ReadSections(Sections);
    for i := 0 to Sections.Count - 1 do
      if Pos(Prefix, Sections[i]) = 1 then
        Personal := Personal + [Copy(Sections[i], Length(Prefix) + 1, MaxInt)];
    Sections.Clear;
    MA.ReadSections(Sections);
    for i := 0 to Sections.Count - 1 do
      if Pos(Prefix, Sections[i]) = 1 then
        Shared := Shared + [Copy(Sections[i], Length(Prefix) + 1, MaxInt)];
  finally
    Sections.Free;
  end;
  Result := (Length(Personal) > 0) or (Length(Shared) > 0);
end;

function TSettings.GridPresetExists(Section: string; const PresetName: string; AShared: Boolean): Boolean;
var
  MC: TMemIniFile;
begin
  if AShared then MC := MA else MC := M;
  Result := MC.SectionExists(GridPresetSection(Section, PresetName));
end;

function TSettings.GetGridPresetFlags(Section: string; const PresetName: string; AShared: Boolean;
  out AIncludeSort, AIncludeColumnFilters, AIncludeGridFilter: Boolean): Boolean;
//читает ранее сохраненные флажки пресета (без применения самого пресета) - нужно для диалога
//"Обновить текущий пресет", чтобы предзаполнить его текущим состоянием пресета, а не значениями по умолчанию
var
  MC: TMemIniFile;
  PresetSection, Flags: string;
begin
  AIncludeSort := True;
  AIncludeColumnFilters := True;
  AIncludeGridFilter := True;
  if AShared then MC := MA else MC := M;
  PresetSection := GridPresetSection(Section, PresetName);
  Result := MC.SectionExists(PresetSection);
  if not Result then
    Exit;
  Flags := MC.ReadString(PresetSection, '(PresetFlags)', '1,1,1');
  AIncludeSort          := StrToIntDef(ExtractWord(1, Flags, [',']), 1) <> 0;
  AIncludeColumnFilters  := StrToIntDef(ExtractWord(2, Flags, [',']), 1) <> 0;
  AIncludeGridFilter     := StrToIntDef(ExtractWord(3, Flags, [',']), 1) <> 0;
end;

procedure TSettings.SaveGridPreset(Section: string; Grid: TFrDBGridEh; const PresetName: string; AShared: Boolean;
  AIncludeSort: Boolean = True; AIncludeColumnFilters: Boolean = True; AIncludeGridFilter: Boolean = True);
//сохраняет текущий вид грида (и, если задан, связанного Grid.Grid2) как именованный пресет.
//AIncludeSort/AIncludeColumnFilters/AIncludeGridFilter влияют не на запись (пресет всегда пишется полностью -
//это то же самое, что и обычное сохранение вида грида), а на то, что будет реально применено при
//восстановлении пресета - см. ApplyGridPreset
var
  MC: TMemIniFile;
  PresetSection: string;
begin
  if Trim(PresetName) = '' then
    Exit;
  //общий пресет может создавать/перезаписывать только пользователь с правом "Администрирование интерфейса"
  if AShared and not User.Role(rAdm_Other_InterfaceAdmin) then begin
    MyInfoMessage('Недостаточно прав для сохранения общего пресета!');
    Exit;
  end;
  //если у грида есть детальная панель (myogRowDetailPanel), но Grid2 еще ни разу не готовился (пользователь
  //не раскрывал детальную панель ни у одной строки) - принудительно подготовим его, иначе его настройки
  //никогда не попадут в пресет (см. EnsureGrid2Prepared)
  EnsureGrid2Prepared(Grid);
  PresetSection := GridPresetSection(Section, PresetName);
  WriteFrDBGridEhSettings(PresetSection, Grid, AShared, True);
  if Assigned(Grid.Grid2) and Grid.Grid2.IsPrepared then
    WriteFrDBGridEhSettings(PresetSection, Grid.Grid2, AShared, True);
  if AShared then MC := MA else MC := M;
  MC.WriteString(PresetSection, '(PresetFlags)', Format('%d,%d,%d',
    [Integer(AIncludeSort), Integer(AIncludeColumnFilters), Integer(AIncludeGridFilter)]));
  if AShared then MAChanged := True;
  //пишем в БД сразу, не дожидаясь закрытия программы (см. обсуждение) - иначе для общего пресета до
  //перезапуска программы его не увидит вообще никто, включая автора при следующем открытии этой же формы.
  //другие пользователи в любом случае увидят общий пресет только после перезапуска (M/MA перечитываются
  //из БД один раз при входе), это ограничение архитектуры настроек, а не этого метода
  Save;
end;

procedure TSettings.ApplyGridPreset(Section: string; Grid: TFrDBGridEh; const PresetName: string; AShared: Boolean);
//применяет ранее сохраненный пресет к гриду (и, если задан, к связанному Grid.Grid2)
var
  MC: TMemIniFile;
  PresetSection: string;
  Flags: string;
  IncludeSort, IncludeColumnFilters, IncludeGridFilter: Boolean;
  i: Integer;
begin
  if AShared then MC := MA else MC := M;
  PresetSection := GridPresetSection(Section, PresetName);
  if not MC.SectionExists(PresetSection) then
    Exit;
  Flags := MC.ReadString(PresetSection, '(PresetFlags)', '1,1,1');
  IncludeSort          := StrToIntDef(ExtractWord(1, Flags, [',']), 1) <> 0;
  IncludeColumnFilters  := StrToIntDef(ExtractWord(2, Flags, [',']), 1) <> 0;
  IncludeGridFilter     := StrToIntDef(ExtractWord(3, Flags, [',']), 1) <> 0;

  //см. комментарий в SaveGridPreset про EnsureGrid2Prepared - без этого, если пользователь не раскрывал
  //детальную панель ни у одной строки, настройки Grid2 из пресета никогда не восстановятся
  EnsureGrid2Prepared(Grid);
  RestoreFrDBGridEhSettings(PresetSection, Grid, AShared, True);
  if Assigned(Grid.Grid2) and Grid.Grid2.IsPrepared then
    RestoreFrDBGridEhSettings(PresetSection, Grid.Grid2, AShared, True);
  //RestoreFrDBGridEhSettings только записывает "желаемую" видимость столбцов в модель полей
  //(Grid.Opt.SetFieldVisible) - в обычном потоке (TFrDBGridEh.MemTableEh1AfterOpen) следом ВСЕГДА вызывается
  //Grid.SetColumnsVisible, которая и применяет эту модель к реальным столбцам грида (TColumnEh.Visible).
  //здесь этот вызов происходит не через AfterOpen (датасет не переоткрывается), поэтому его нужно сделать
  //явно - без этого видимость столбцов из пресета визуально не применяется, хотя ширина/порядок/сортировка
  //(они меняются в самих объектах колонок напрямую) применяются нормально
  Grid.SetColumnsVisible;
  if Assigned(Grid.Grid2) and Grid.Grid2.IsPrepared then
    Grid.Grid2.SetColumnsVisible;

  //ниже - откат тех аспектов пресета, которые пользователь не захотел включать при его создании (сам пресет
  //хранит данные полностью, см. SaveGridPreset)
  if not IncludeSort then begin
    for i := 0 to Grid.DbGridEh1.Columns.Count - 1 do begin
      //!!!TSortMarkerEh(0) - в этом проекте нигде не встретился именованный литерал "нет сортировки", ноль
      //использован по аналогии с тем, как эта же величина уже кодируется/раскодируется в этом файле через
      //Integer(col.Title.SortMarker) / TSortMarkerEh(StrToIntDef(...)) - пожалуйста, проверьте при компиляции,
      //что 0 - это действительно "без сортировки" в вашей версии EhLib
      Grid.DbGridEh1.Columns[i].Title.SortMarker := TSortMarkerEh(0);
      Grid.DbGridEh1.Columns[i].Title.SortIndex := -1;
    end;
    if Assigned(Grid.Grid2) and Grid.Grid2.IsPrepared then
      for i := 0 to Grid.Grid2.DbGridEh1.Columns.Count - 1 do begin
        Grid.Grid2.DbGridEh1.Columns[i].Title.SortMarker := TSortMarkerEh(0);
        Grid.Grid2.DbGridEh1.Columns[i].Title.SortIndex := -1;
      end;
  end;
  if not IncludeColumnFilters then begin
    Gh.GridFilterClear(Grid.DbGridEh1, True, False);
    if Assigned(Grid.Grid2) and Grid.Grid2.IsPrepared then
      Gh.GridFilterClear(Grid.Grid2.DbGridEh1, True, False);
  end;
  if not IncludeGridFilter then begin
    Grid.Opt.FilterResult := '';
    if Assigned(Grid.Grid2) and Grid.Grid2.IsPrepared then
      Grid.Grid2.Opt.FilterResult := '';
  end;

  //применим сортировку/фильтр столбцов сразу же, не дожидаясь Grid.RefreshGrid ниже - у RefreshGrid разные
  //внутренние ветки в зависимости от режима данных (см. TFrDBGridEh.RefreshGrid), и не во всех местах
  //однозначно гарантирован повторный вызов DefaultApplySorting/DefaultApplyFilter именно после того, как
  //мы расставили маркеры/фильтры столбцов выше. сами по себе Title.SortMarker/STFilter.ExpressionStr -
  //это только настройка "что должно быть применено"; собственно применение (реальная сортировка/фильтрация
  //уже загруженных данных) делают именно эти два метода (см. также TGridEhHelper.GridFilterRestore в
  //uForms.pas - тот же паттерн: сначала STFilter.ExpressionStr, потом DefaultApplyFilter)
  Grid.DbGridEh1.DefaultApplySorting;
  Grid.DbGridEh1.DefaultApplyFilter;
  if Assigned(Grid.Grid2) and Grid.Grid2.IsPrepared then begin
    Grid.Grid2.DbGridEh1.DefaultApplySorting;
    Grid.Grid2.DbGridEh1.DefaultApplyFilter;
  end;

  //гридфильтр (Opt.FilterResult) влияет на SQL, которым грузятся данные - поэтому для применения на лету
  //нужен полный перезапрос, недостаточно просто перерисовать грид
  Grid.RefreshGrid;
  if Assigned(Grid.Grid2) and Grid.Grid2.IsPrepared then
    Grid.Grid2.RefreshGrid;
end;

procedure TSettings.DeleteGridPreset(Section: string; const PresetName: string; AShared: Boolean);
var
  MC: TMemIniFile;
  PresetSection: string;
begin
  if AShared and not User.Role(rAdm_Other_InterfaceAdmin) then begin
    MyInfoMessage('Недостаточно прав для удаления общего пресета!');
    Exit;
  end;
  if AShared then MC := MA else MC := M;
  PresetSection := GridPresetSection(Section, PresetName);
  if not MC.SectionExists(PresetSection) then
    Exit;
  MC.EraseSection(PresetSection);
  if AShared then MAChanged := True;
  Save;
end;

(*

  //зададим индекс полей (порядок следования их в таблице)
    try
{  SetLength(FieldNames, Length(Grid.Opt.Sql.Fields));
  for i := 0 to High(Grid.Opt.Sql.Fields) do
    FieldNames[i] := Grid.Opt.Sql.Fields[i].Name;
  va := ReorderColumns(FieldNames, va);  }

  var vai: tvardynarray := [];
  var van: tvardynarray := [];
for i:=0 to Grid.DbGridEh1.Columns.count -1 do begin
  //Grid.DbGridEh1.Columns[i].Visible := True;
  vai := vai + [Grid.DbGridEh1.Columns[i].Index];
  van := van + [Grid.DbGridEh1.Columns[i].FieldName];
//  st := Grid.DbGridEh1.Columns[i].FieldName;
//  var st1 := Grid.DbGridEh1.Columns[i].Name;
  end;

      va := va.RemoveDuplicates;
      if Length(va) <> Length(Grid.Opt.Sql.Fields) then
//    Sys.SaveTextToFile('r:\1111', A.Implode(va, ','))
        var bbb := True
      else begin
          var bb1 := False;
  var vai2: tvardynarray := [];
  var van2: tvardynarray := [];
  Grid.DbGridEh1.Columns.BeginUpdate;
        for i := High(va) downto 0 do begin
          j:=Grid.DbGridEh1.FindFieldColumn(va[i]).Index;
          if j <> i then begin
            Grid.DbGridEh1.FindFieldColumn(va[i]).Index := i;
            var stt1 := Grid.DbGridEh1.Columns[i].FieldName;
            var stt2 := Grid.Opt.Sql.Fields[i].Name;
            if stt1 <> stt2 then
              var bbb1 := True;
          end;
        end;
for i:=0 to Grid.DbGridEh1.Columns.Count - 1 do
  Grid.DbGridEh1.FindFieldColumn(va[i]).Index := i;
Grid.DbGridEh1.Columns.EndUpdate;
for i:=0 to Grid.DbGridEh1.Columns.Count -1 do begin
  vai2 := vai2 + [Grid.DbGridEh1.Columns[i].Index];
  van2 := van2 + [Grid.DbGridEh1.Columns[i].FieldName];
  end;
      end;
    except
    end;

  Grid.TestCompareFC;
*)







end.
