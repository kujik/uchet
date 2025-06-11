{
отображает информацию об ошибках, сохраненных в логе
вызывается из лога ошибок
основное показыввает в отдельных вкладках, но есть также вкладка полного отчета, и скриншота
в отдельную вынесены ошибки оракла

все данные грузит из бд сам, получая только айди таблицы лога. диск не используем (отключил запись на диск в uErrors, все пишем в бд)

пока не разоборался как через memorystrim и гружу скриншот через промежуточный временный файл
}


unit D_J_Error_Log;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI,
  fs_synmemo, Vcl.ExtCtrls, Vcl.StdCtrls, MemTableDataEh, Data.DB,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, Vcl.Mask,
  DBCtrlsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, MemTableEh,
  Vcl.ComCtrls, IoUtils, uString, uLabelColors;

{(*}
type
  TDlg_J_Error_Log = class(TForm_MDI)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    MemTableEh1: TMemTableEh;
    DBGridEh1: TDBGridEh;
    E_PPComment: TDBEditEh;
    DataSource1: TDataSource;
    Lb_Module: TLabel;
    Lb_User: TLabel;
    Lb_Ver: TLabel;
    Lb_Compile: TLabel;
    M_ErrorText: TDBMemoEh;
    Lb_ErrDt: TLabel;
    DBGridEh2: TDBGridEh;
    TabSheet4: TTabSheet;
    Panel1: TPanel;
    M_SourceFile: TfsSyntaxMemo;
    Lb_SrcPath: TLabel;
    Lb_FileName: TLabel;
    Lb_ErrorInfo: TLabel;
    TabSheet5: TTabSheet;
    Panel2: TPanel;
    M_OraParams: TDBMemoEh;
    Panel3: TPanel;
    M_OraError: TDBMemoEh;
    Panel4: TPanel;
    M_OraSQL: TDBMemoEh;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    M_FullReport: TfsSyntaxMemo;
    Im_Pict: TImage;
    //даблклик по гриду стека вызовов, пытаемся загрузить исходник в соседнюю вкладку
    procedure DBGridEh2DblClick(Sender: TObject);
    //активация закладки скриншота
    procedure TabSheet6Show(Sender: TObject);
  private
    { Private declarations }
    ErrorArr: TVarDynArray;
    Fields: string;
    PictFile: string;
    function Prepare: Boolean; override;
  public
    { Public declarations }
  end;

var
  Dlg_J_Error_Log: TDlg_J_Error_Log;

implementation

uses
  uModule,
  uData,
  uForms,
  uErrors,
  uDBOra,
  uMessages,
  uSys
  ;

{*)}

{$R *.dfm}

const
//определены в uErrors
{  cmyerrId = 0;
  cmyerrTime = 1;
  cmyerrModule = 2;
  cmyerrModuleVer = 3;
  cmyerrModuleCompile = 4;
  cmyerrUserLogin = 5;
  cmyerrGeneral = 6;
  cmyerrMashineUser = 7;
  cmyerrMessage = 8;
  cmyerrSql = 9;
  cmyerrSqlParams = 10;
  cmyerrStack = 11;
  cmyerrHandled = 12;
  ide = 13;
  }
//дополнительные
  cmyerrUserName = 14;
  cmyerrFullReport = 15;
  cmyerrPict = 16;



function TDlg_J_Error_Log.Prepare: Boolean;
var
  i, j, k: Integer;
  st, st1, st2: string;
  va, va1: TVarDynArray;
  va2: TVarDynArray2;
  b, b1, b2: Boolean;
begin
  Result := False;
  Caption := 'Информация об ошибке';

  //читаем данные из вьюхи
  Fields:='id;dt;modulename;ver;compile_dt;userlogin;general;mashineinfo;message;sql;sqlparams;stack;handled;ide;username;fullreportc;pictc';
  ErrorArr:= Q.QLoadToVarDynArrayOneRow(Q.QSIUDsql('s', 'v_adm_error_log', Fields), [ID]);

  //в статусбар
  SetStatusBar('$0000FFОшибка: $000000[$FF0000' + VaRToStr(ErrorArr[cmyerrModule]) +
    '$000000 - $FF0000' + VaRToStr(ErrorArr[cmyerrUserLogin]) + '$000000 - $FF0000' + VaRToStr(VartoDatetime(ErrorArr[cmyerrTime]))+ '$000000]$FF0000'
    , '', True
  );

  //на главной вкладке
  Lb_Module.ResetColors;
  Lb_Module.SetCaption(Lb_Module.Caption + '  $FF0000' + ErrorArr[cmyerrModule]);
  Lb_Ver.ResetColors;
  Lb_Ver.SetCaption(Lb_Ver.Caption + '  $FF0000' + ErrorArr[cmyerrModuleVer]);
  Lb_Compile.ResetColors;
  Lb_Compile.SetCaption(Lb_Compile.Caption + '  $FF0000' + VarToStr(ErrorArr[cmyerrModuleCompile]));
  Lb_User.ResetColors;
  Lb_User.SetCaption(Lb_User.Caption + '  $FF0000' + S.NSt(ErrorArr[cmyerrUserName]) +  '(' + S.NSt(ErrorArr[cmyerrUserLogin]) + ')');
  Lb_ErrDt.ResetColors;
  Lb_ErrDt.SetCaption(Lb_ErrDt.Caption + '  $FF0000' + VarToStr(ErrorArr[cmyerrTime]));
  M_ErrorText.Text:= ErrorArr[cmyerrMessage];


  //вкладка General
  va1:=A.Explode(ErrorArr[cmyerrGeneral], #13#10);
  va2:=[];
  for i:=0 to High(va1) do begin
    va:=A.Explode(va1[i], ':');
    st1:=Trim(va[0]);
    Delete(va, 0, 1);
    va2:=va2 + [[st1, Trim(A.Implode(va, ':'))]];
  end;
  //поле, тип данных, размер данных, заголовок (может с " ", "_", "|"), отображаемая ширина, видимость, автоподгонка ширины, перенос для столбца по словам
  Mth.CreateTableGrid(
    DBGridEh1, True, True, False, False,
    [['name', ftString, 60, 'Property', 250, True, False, False],
     ['value', ftString, 60, 'Value', 400, True, True, True]],
    va2, '', ''
  );

  //Call stack
  //текст стека может не поместиться в 4000 символов, и резаные строки портят разбор
  //удаляем все строки короче 70 символов, цифра достаточно условна
  va1:=A.Explode(ErrorArr[cmyerrStack], #13#10);
  for i:=high(va1) downto 0 do
    if length(va1[i]) < 30
      then Delete(va1, i,1);
      //va1[i]:=va1[i];
  va2:=[];
  va:=[1];
  k:=0;
  for i:=0 to high(va1) do
    if k < Length(va1[i]) then k:= Length(va1[i]);
  for i:= 1 to k do begin
    b:=False;
    for j:=0 to high(va1) do begin
      if Copy(va1[j], i, 1) <> ' ' then
        begin b:=True; Break; end;
    end;
    if not b then va := va + [i];
  end;
  va:=va + [k];
  for i:= High(va) downto 1 do
    if va[i-1] = va[i] - 1 then Delete(va, i, 1);
  for i:= 0 to high(va1) do begin
    va2:=va2+[['','','','','','','']];
    for j:=1 to high(va) do begin
      st:=copy(va1[i], s.vartoint(va[j-1]), s.vartoint(va[j])-s.vartoint(va[j-1]) + 1);
      if j <= Length(va2[i]) then
        va2[i][j-1]:=Trim(st);
    end;
  end;
  i:=high(va2);
  //поле, тип данных, размер данных, заголовок (может с " ", "_", "|"), отображаемая ширина, видимость, автоподгонка ширины, перенос для столбца по словам
   //address;rel;module;unit;address;rel;function
  Mth.CreateTableGrid(
    DBGridEh2, True, True, False, False,[
    ['address', ftString, 60, 'address', 70, True, False, False],
    ['rel', ftString, 60, 'rel', 70, True, False, False],
    ['module', ftString, 100, 'module', 200, True, True, True],
    ['unit', ftString, 50, 'unit', 200, True, True, True],
    ['addressf', ftString, 60, 'address', 70, True, False, False],
    ['relf', ftString, 60, 'rel', 70, True, False, False],
    ['function', ftString, 100, 'function', 200, True, True, True]],
    va2, '', ''
  );

  //ошибки базы данных Oracle
  M_OraError.Lines.Text:=S.NSt(ErrorArr[cmyerrMessage]); M_OraError.ReadOnly:= True;
  M_OraSQL.Lines.Text:=S.NSt(ErrorArr[cmyerrSql]); M_OraSQL.ReadOnly:= True;
  M_OraParams.Lines.Text:=S.NSt(ErrorArr[cmyerrSqlParams]); M_OraParams.ReadOnly:= True;
//  M_OraSQL.Lines.Text:=S.NSt(Copy(ErrorArr[cmyerrSql], Pos(': ', ErrorArr[cmyerrSql]) + 2)); M_OraSql.ReadOnly:= True;
//  M_OraParams.Lines.Text:=S.NSt(Copy(ErrorArr[cmyerrSqlParams], Pos(': ', ErrorArr[cmyerrSqlParams]) + 2)); M_OraParams.ReadOnly:= True;

  //полный отчет в Тмемо
  M_FullReport.Lines.Clear;
  M_FullReport.Lines.Text:=S.NSt(ErrorArr[cmyerrFullReport]);

  PageControl1.ActivePageIndex:=0;
  Result := True;
end;

procedure TDlg_J_Error_Log.TabSheet6Show(Sender: TObject);
//скриншот загружаем из бд при открытии формы, но показываем только при первом переходе на вкладку скриншота
//сделано пока криво, текст из бд сохраняется во временный файл виндовс, читается в картинку, затем файл стирается
begin
  inherited;
  Exit; //!!!
  //скриншот
  if PictFile <> '' then Exit;
  PictFile:=Sys.GetWinTempFileName+'.bmp';
  Sys.SaveTextToFile(PictFile, ErrorArr[cmyerrPict]);
  Im_Pict.Picture.LoadFromFile(PictFile);
  TFile.Delete(PictFile);
end;

procedure TDlg_J_Error_Log.DBGridEh2DblClick(Sender: TObject);
//дабл-клик по гриду стека вызовов
var
  st, fname, dir: string;
  i,j: Integer;
  dt: TDateTime;
  strno: Integer;
begin
  inherited;
  dir:=Module.Getpath_SrcForVersion(ErrorArr[cmyerrModule], ErrorArr[cmyerrModuleVer], ErrorArr[cmyerrModuleCompile]);
  if not DirectoryExists(dir) then begin
    MyInfoMessage('Исходники для данной версии модуля не найдены!');
    Exit;
  end;
  fname:=S.NSt(TMemTableEh(DBGridEh2.DataSource.DataSet).FieldByName('unit').AsString) + '.pas';
  st:=dir + '\' + fname;
  if not FileExists(st) then begin
    MyInfoMessage('Файл "' + fname + '" в исходниках не найден!');
    Exit;
  end;
  {$I-}
  Lb_FileName.SetCaption2('Файл:  $FF0000' + fname);
  Lb_SrcPath.SetCaption2('Путь:  $FF0000' + dir);
  Lb_ErrorInfo.SetCaption2('Место вызова:  Функция "$FF0000' +
    S.NSt(TMemTableEh(DBGridEh2.DataSource.DataSet).FieldByName('function').AsString) + '$000000" в строке $FF0000' +
    S.NSt(TMemTableEh(DBGridEh2.DataSource.DataSet).FieldByName('addressf').AsString) + '$000000   ($FF0000' +
    S.NSt(TMemTableEh(DBGridEh2.DataSource.DataSet).FieldByName('relf').AsString) + '$000000)');
  M_SourceFile.Lines.Clear;
  M_SourceFile.Lines.LoadFromFile(st);
  strno:=S.VarToInt(TMemTableEh(DBGridEh2.DataSource.DataSet).FieldByName('addressf').Value);
  if strno = -1 Then exit;
  try
  M_SourceFile.AddBookmark(TMemTableEh(DBGridEh2.DataSource.DataSet).FieldByName('addressf').AsInteger - 1, 1);
  M_SourceFile.GotoBookmark(1);
  except
  end;
  {$I+}
end;


end.

