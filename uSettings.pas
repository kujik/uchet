unit uSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBCtrlsEh, Buttons, DBGridEh, DBAxisGridsEh, GridsEh,
  ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
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

    procedure WriteFrDBGridEhSettings(Section: string; Grid: TFrDBGridEh; ToDef: Boolean = False);
    procedure RestoreFrDBGridEhSettings(Section: string; Grid: TFrDBGridEh; SetDefault: Boolean = False);
    function  IsDefaultFrDBGridEhSettingsExists(Section: string; Grid: TFrDBGridEh): Boolean;

  end;

var
  Settings: TSettings;

implementation

uses
  VCL.Themes,
  uSys,

  uFrmMain
  ;

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

procedure TSettings.WriteFrDBGridEhSettings(Section: string; Grid: TFrDBGridEh; ToDef: Boolean = False);
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
  if not(ToDef) and (myogSaveFilter in Grid.Options) then begin
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
//    Sys.SaveTextToFile('r:\2222', st);
   va:=A.Explode(st, #1);
   va:=A.Explode(va[0], #2);
end;

procedure TSettings.RestoreFrDBGridEhSettings(Section: string; Grid: TFrDBGridEh; SetDefault: Boolean = False);
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
begin
//exit;
  try
  oplus := [];
  ominus := [];
  SetLength(ColumnArray, Grid.DbGridEh1.Columns.Count);
  if (M.SectionExists(Section) and not SetDefault)and
     (M.ReadString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), '--') <> '--')
    then MC:= M
    else MC:= MA;

  //параметры фильтра в окне; читаем даже при неактивном гриде, так как фильтр влияет на параметры загрузки данных
  Grid.Opt.FilterResult := MC.ReadString(Section, Format('%s.%s', [Grid.Name, '(DefFilter)']), '');
  //выйдем, если мемтейбл не открыт
  if not Grid.MemTableEh1.Active then
    Exit;


  //получим параметры, общие для грида
  st := MC.ReadString(Section, Format('%s.%s', [Grid.Name, '(Settings)']), '--');
  if st <> '--' then  begin
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
    if myogSaveFilter in oplus then begin
      si := M.ReadString(Section, Format('%s.%s', [Grid.Name, '(Filter)']), '');
      if si <> '' then begin
        a1 := A.ExplodeS(si, #1);
        SetLength(ar2, Length(a1));
        for i := 0 to High(a1) do begin
//!!!почему-то в этом варианте возникает ошибка
            //a2:=Ah..ExplodeV(a1[i], #2);
//            a[i]:=[a2[0], a2[1]];         //если включена вот эта срока???
//ошибки совершенно непонятные, не индексы, такое ощущение что портим память, возникают не всегда!!!
//a[i]:=[a2[0],''];
          j := pos(#2, a1[i]);
          ar2[i] := [#5, ''];
          if j > 1 then begin
            ar2[i] := [copy(a1[i], 1, j - 1), copy(a1[i], j + 1, 40000)];
//              a[i]:=[copy(a1[i],1,j-1), 'asdasasdasd'];
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
  Grid.DBGridEh1.OptionsEh:=Grid.DBGridEh1.OptionsEh+[dghAutoSortMarking, dghMultiSortMarking];
  for i:=0 to Grid.DbGridEh1.Columns.Count - 1 do begin
    col := Grid.DbGridEh1.Columns[i];
    p := A.PosInArray(col.FieldName, cols, 0, True);
    if p < 0 then Continue;
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
  //второй проход
  for i:=0 to Grid.DbGridEh1.Columns.Count - 1 do begin
    col := Grid.DbGridEh1.Columns[i];
    p := A.PosInArray(col.FieldName, cols, 0, True);
    if p < 0 then Continue;
    fr := Grid.Opt.GetFieldRec(col.FieldName);
    //для видимых колонок установим значения фильтра, если он был загружен
    //сопоставление столбцов проводим по имени поля
    if fr.Visible and (High(ar2) >=0) then
      for n:=0 to High(ar2)-1 do
        if (ar2[n][0] = col.FieldName) and (ar2[n][1] <> '') then
          //может быть ошибка из-за несовпадения форматов чисел/дат при сохранении и чтении
          try
            col.STFilter.ExpressionStr:=ar2[n][1];
          except
          end;
  end;

  {установим порядок стлбцов. в настройках сохранены имена столбца, идущего перед данным}
  //создадим мааасив имен полей в том порядке, как соотвествующие столбцы должны отображаться, по всем сохраненным столбцам
  va := [];
  st := '0';
  for j := 0 to high(cols) do begin
    for i:=0 to high(cols) do
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
      if st = '0'
        then Insert(Grid.Opt.Sql.Fields[i].Name, va, 0)
        else begin
          j := A.PosInArray(st, va, True);
          if j >= 0
            then Insert(Grid.Opt.Sql.Fields[i].Name, va, j + 1)
            else va := va + [Grid.Opt.Sql.Fields[i].Name]
        end;
  end;
//    Sys.SaveTextToFile('r:\1111', A.Implode(va, ','));
  //зададим индекс полей (порядок следования их в таблице)
  for i := 0 to high(va) do
    Grid.DbGridEh1.FindFieldColumn(va[i]).Index := i;


  Grid.Options := Grid.Options + oplus - ominus;

  finally

  end;

exit;

      //параметры столбцов (восстановим из выбранного файла - если есть пользовательский, то из него, иначе из общего. выбор файла был выше)
      for i := 0 to Grid.DbGridEh1.Columns.Count - 1 do
      begin
        col := Grid.DbGridEh1.Columns[i];
        St := MC.ReadString(Section, Format('%s.%s', [Grid.Name, col.FieldName]), '');
        //настройки столбца из общего файла, нужны для восстановления параметров столбца, который был добавлен в дефолт после сохранения настроек пользователя
        SA := MA.ReadString(Section, Format('%s.%s', [Grid.Name, col.FieldName]), '');
        fr := Grid.Opt.GetFieldRec(col.FieldName);
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
          col.WordWrap := Boolean(StrToIntDef(ExtractWord(10, S.IIf(b, St, SA), Delims), Integer(Grid.DbGridEh1.Columns[I].WordWrap)));
          col.AutoFitColWidth := Boolean(StrToIntDef(ExtractWord(11, S.IIf(b, St, SA), Delims), Integer(Grid.DbGridEh1.Columns[I].AutoFitColWidth)));
          //все остальное только из пользовательского
          if b then begin
            ColumnArray[I].EndIndex := StrToIntDef(ExtractWord(1, St, Delims), ColumnArray[I].EndIndex);
              col.Title.SortMarker := TSortMarkerEh(StrToIntDef(ExtractWord(3, St, Delims), Integer(col.Title.SortMarker)));
 //             col.Visible := Boolean(StrToIntDef(ExtractWord(4, St, Delims), Integer(col.Visible)));
              Grid.Opt.SetFieldVisible(col.FieldName, Boolean(StrToIntDef(ExtractWord(4, St, Delims), Integer(col.Visible))));
              //скрываем все столбцы, заголовки которых начинаются на _
  //          if (crpSortMarkerEh in RestoreParams) then
              ColumnArray[I].SortIndex := StrToIntDef(ExtractWord(5, St, Delims), 0);
  //          if (crpDropDownRowsEh in RestoreParams) then
              col.DropDownRows := StrToIntDef(ExtractWord(6, St, Delims), col.DropDownRows);
  //          if (crpDropDownWidthEh in RestoreParams) then
              col.DropDownWidth := StrToIntDef(ExtractWord(7, St, Delims), col.DropDownWidth);
    //        if (crpRowPanelColPlacementEh in RestoreParams) then
              col.InRowLinePos := StrToIntDef(ExtractWord(8, St, Delims), col.InRowLinePos);
              col.InRowLineHeight := StrToIntDef(ExtractWord(9, St, Delims), col.InRowLineHeight);
              ColumnArray[I].PrevCol :=ExtractWord(12, St, Delims);
            //для видимых колонок установим значения фильтра, если он был загружен
            //сопоставление столбцов проводим по имени поля
            if fr.Visible and (High(ar2) >=0) then begin
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
        for I := 0 to Grid.DbGridEh1.Columns.Count - 1 do
          Grid.DbGridEh1.Columns[i].Title.SortIndex := ColumnArray[I].SortIndex;
      end;
//      if (crpColIndexEh in RestoreParams) then
          if False then
      begin
        for I := 0 to Grid.DbGridEh1.Columns.Count - 1 do
        begin
          for J := 0 to Grid.DbGridEh1.Columns.Count - 1 do
          begin
            if ColumnArray[J].EndIndex = I then
            begin
              ColumnArray[J].Column.Index := ColumnArray[J].EndIndex;
              Break;
            end;
          end;
        end;
      end;

    va:=[];
    st:='0';
    for j:=0 to high(ColumnArray) do begin
    for i:=0 to high(ColumnArray) do
      if ColumnArray[i].PrevCol = st then begin
        va := va + [ColumnArray[i].Column.FieldName];
        st := ColumnArray[i].Column.FieldName;
        Break;
      end;
    end;
//    sys.SaveArray2ToFile([va], 'r:\1111');
    Sys.SaveTextToFile('r:\1111', A.Implode(va, ','));
    for i := 0 to high(va) do
      Grid.DbGridEh1.FindFieldColumn(va[i]).Index := i;

      //    for i:= 0 to high(va)

  Grid.Options := Grid.Options + oplus - ominus;

end;






end.
