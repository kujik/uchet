{

Установка модулей Учета

Выбранный модуль из папки разработки перемещается в рабочую папку программы.
Перед применением желательно непосредственно скомпилировать проект (пересобирать полностью не нужно),
оптимально просто запустить по F9 из дельфи. Запуск важен, модуль для установки берется по имени, а не uchet.exe.
А данный файл создается при запуске учета из-под ИДЕ.

в диалоге выбирается модуль из списка. Иходный путь и Целевой путь прописаны пока статически в коде, но могут быть изменены.

если были найдены pas/dfm файлы, новее даты модификации устанавливаемого файла, будет выдано предупреждение, но устиановка не блокируется.

перед установкой файл в каталоге разработки сжимается с помощью upx, upx.exe должен находиться в папке проекта.

в диалоге отображаются информация о выбранном новом модуле и о том что находится в целевой папке, а также пользователи, у кого он открыт.

по клику на кнопке файл сжимается и программа пытается копировать файл с заменой, сессии не проверяются, попытки повторяются раз в 10сек,
пока не закончатся удачей. после этого файлы pas/dfm копируются из каталога разработки в целевой (Data/Src/ИмяМодуля__Версия__ДатаКомпиляции).
туда же копируется комментария в файл !.txt, и замененный исполняемый файл в папку BACKUP

ВСЕ ПАРАМЕТРЫ ВЕРСИИ В ПРОЕКТЕ МЕНЯЮТСЯ ПРИ КАЖДОЙ КОМПИЛЯЦИИ ПО [Ctrl]-F9, НО В ФАЙЛ ПИШУТСЯ ПРИ СБОРКЕ Ctrl-Shift-F9 и последующем запуске!!!


возможные доработки!!!
выбор места исходников и места установки например из БД
запись события в БД
кнопка возврата файла из бэкапа

}

unit F_Adm_Installer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI,
  Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, Vcl.ExtCtrls, uLabelColors, IOUtils, Types,
  Vcl.Buttons, ShellApi, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, AdoDB, DB, Vcl.ComCtrls;

type
  TForm_Adm_Installer = class(TForm_MDI)
    Cb_Module: TDBComboBoxEh;
    E_Version: TDBEditEh;
    E_DtCompiled: TDBEditEh;
    Lb_InstalledInfo: TLabel;
    E_SrcPath: TDBEditEh;
    E_DstPath: TDBEditEh;
    M_Users: TDBMemoEh;
    Timer1: TTimer;
    M_Comment: TDBMemoEh;
    Bt_Ok: TBitBtn;
    Lb_FilesInfo: TLabel;
    Lb_Status: TLabel;
    Timer2: TTimer;
    Lb_PrevInstall: TLabel;
    Dbg_PrevInstall: TDBGridEh;
    M_PrevInstalllcomment: TDBMemoEh;
    Chb_CloseSessions: TDBCheckBoxEh;
    ProgressBar1: TProgressBar;
    procedure Cb_ModuleChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Bt_OkClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Dbg_PrevInstallAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    //список файлов для копирования в исходники
    FileList: TStringDynArray;
    //в процедуре установки
    InInstall: Boolean;
    //максимальный и минимальный размеры сжатого файла - для контроля что он был сжат, так как запуск upx без ожидания, ставятся в Prepare
    MinCompressedFileSize, MaxCompressedFileSize: Integer;
    function Prepare: Boolean; override;
    procedure Verify;
    function GetFileList: Boolean;
    function Install: Boolean;
  public
    { Public declarations }
  end;

var
  Form_Adm_Installer: TForm_Adm_Installer;

implementation

uses
  uData, uDBOra, uString, uMessages, uForms, uModule, uSys;

const
  //путь к исходникам
  PATH_SRC = 'R:\Projects\Uchet';
  //путь расположения каталога Учета
  PATH_DST = '\\10.1.1.14\Uchet\Учет';
  //путь репозитория (должен начинаться со слеша, если не пустой
  PATH_LAUNCHER_STORAGE = '\launcher_storage\Uchet';

{$R *.dfm}

procedure TForm_Adm_Installer.Bt_OkClick(Sender: TObject);
var
  i, j: Integer;
begin
  inherited;
  if Trim(M_Comment.Text) = '' then Exit;
  InInstall := False;
  if MyQuestionMessage('Обновить модуль "' + Cb_Module.Text + '"?') <> mrYes then
    Exit;
  Bt_Ok.Enabled := False;
  Cb_Module.Enabled := False;
  M_Comment.Enabled := False;
  E_SrcPath.Enabled := False;
  E_DstPath.Enabled := False;
  {$R-}
  CopyFile(pwidechar(E_DstPath.Text + PATH_LAUNCHER_STORAGE + '\' + Cb_Module.Text + '.exe'), pwidechar(Sys.GetWinTemp + '\' + Cb_Module.Text + '.exe'), False);
  {$R+}
  ProgressBar1.Visible:= True;
  if Chb_CloseSessions.Checked
    then Q.QExecSql('update adm_modules set autoclosedt = (select sysdate from dual), autoclosemin = :idle$i where id = :id$i', [4, Cth.GetControlValue(Cb_Module)]);
  ShellExecute(Application.Handle, nil, pWideChar(E_SrcPath.Text + '\' + 'upx.exe'), pWideChar(E_SrcPath.Text + '\' + Cb_Module.Text + '.exe'), nil, SW_HIDE);
  for i := 0 to 30 do begin
    sleep(1000);
    Application.ProcessMessages;
    j := Sys.GetFileSize(E_SrcPath.Text + '\' + Cb_Module.Text + '.exe');
    if (j > MinCompressedFileSize) and (j < MaxCompressedFileSize) then
      Break;
  end;
  InInstall := True;
end;

procedure TForm_Adm_Installer.Cb_ModuleChange(Sender: TObject);
begin
  Verify;
end;

procedure TForm_Adm_Installer.Verify;
var
  Ver1, Ver2, Dt1, Dt2: string;
  va2: TVarDynArray2;
begin
  inherited;
  E_Version.Text := '';
  E_DtCompiled.Text := '';
  M_Users.Text := '';
  Lb_InstalledInfo.ResetColors;
  Lb_InstalledInfo.SetCaption('');
  Lb_FilesInfo.ResetColors;
  Lb_FilesInfo.SetCaption('');
  Lb_Status.ResetColors;
  Lb_Status.SetCaption('');
  InInstall := False;
  Bt_Ok.Enabled := False;

  if not (DirectoryExists(E_SrcPath.Text)) then begin
    Lb_InstalledInfo.SetCaption('$0000FFНеверно задан путь к исходникам!');
    Exit;
  end;

  if not (DirectoryExists(E_DstPath.Text)) then begin
    Lb_InstalledInfo.SetCaption('$0000FFНеверно задан целевой путь!');
    Exit;
  end;

  if Cb_Module.Text = '' then begin
    Lb_InstalledInfo.SetCaption('$000000Модуль для установки не выбран!');
    Exit;
  end
  else begin
    if not FileExists(E_SrcPath.Text + '\' + Cb_Module.Text + '.exe') then begin
      Lb_InstalledInfo.SetCaption('$0000FFМодуль для установки не найден в каталоге исходников!');
      exit;
    end;
  end;
  Ver1 := Module.GetFileVersion(E_SrcPath.Text + '\' + Cb_Module.Text + '.exe');
  Dt1 := Module.GetFileVersion(E_SrcPath.Text + '\' + Cb_Module.Text + '.exe', 'LastCompiledTime');
  E_Version.Text := Ver1;
  E_DtCompiled.Text := Dt1;
  Bt_Ok.Enabled := True;

  Ver2 := '';
  Dt2 := '';
  Ver2 := Module.GetFileVersion(E_DstPath.Text + PATH_LAUNCHER_STORAGE + '\' + Cb_Module.Text + '.exe');
  Dt2 := Module.GetFileVersion(E_DstPath.Text + PATH_LAUNCHER_STORAGE + '\' + Cb_Module.Text + '.exe', 'LastCompiledTime');
  if Ver2 + Dt2 = '' then begin
    Lb_InstalledInfo.SetCaption('$FF00FFМодуль отсутствует в целевом каталоге!');
  end
  else if Dt2 > Dt1 then begin
    Lb_InstalledInfo.SetCaption('$3300FFМодуль в целевом каталоге более новый!!! ($FF0000v' + Ver2 + ' от ' + Dt2 + '$FF00FF)');
  end
  else if (Dt2 = Dt1) and (Ver1 = Ver2) then begin
    Lb_InstalledInfo.SetCaption('$3300FFМодуль в целевом каталоге такой же!!! ($FF0000v' + Ver2 + ' от ' + Dt2 + '$FF00FF)');
  end
  else begin
    Lb_InstalledInfo.SetCaption('$FF00FFМодуль в целевом каталоге более ранней версии ($FF0000v' + Ver2 + ' от ' + Dt2 + '$FF00FF)');
  end;
  Timer1Timer(nil);
  if not GetFileList then begin
    Lb_FilesInfo.SetCaption('$0000FFФайлы исходников новее скомпилированной программы. Необходимо перекомпилировать проект!');
  end
  else begin
    Lb_FilesInfo.SetCaption('$FF0000Файлы исходников - найдено ' + IntToStr(Length(FileList)) + ' шт.');
  end;

  M_PrevInstalllcomment.Text:='';
  va2:=Q.QLoadToVarDynArray2(
    'select dt, compile_dt, ver, comm from adm_install_log where id_module = :id$i order by dt desc',
    [Cth.Getcontrolvalue(Cb_module)]
  );
  Mth.CreateTableGrid(
    Dbg_PrevInstall, False, False, False, False,[
    ['dt', ftDate, 0, 'Дата', 70, True, False, False],
    ['compile_dt', ftString, 100, 'Компиляция', 105, True, False, False],
    ['ver', ftString, 100, 'Версия', 80, True, False, False],
    ['comm', ftString, 4000, 'Комментарий', 70, False, False, False]],
    va2, '', ''
  );
  Dbg_PrevInstall.DataSource.DataSet.AfterScroll:=Dbg_PrevInstallAfterScroll;
  Dbg_PrevInstall.DataSource.DataSet.Last;
  Dbg_PrevInstall.DataSource.DataSet.First;
end;

procedure TForm_Adm_Installer.Dbg_PrevInstallAfterScroll(DataSet: TDataSet);
begin
  inherited;
  M_PrevInstalllcomment.Text:=Dbg_PrevInstall.DataSource.DataSet.FieldByName('comm').AsString;
end;

function TForm_Adm_Installer.Prepare: Boolean;
var
  i, j: Integer;
  st: string;
  Cb: TCheckBox;
  Dt: TdateTime;
begin
  Result := False;
  Cb_Module.Items.clear;
  Cb_Module.KeyItems.clear;
  for i := 0 to cMainModulesCount - 1 do begin
    Cb_Module.Items.Add(ModuleRecArr[i].Caption);
    Cb_Module.KeyItems.Add(IntToStr(i));
  end;
  E_SrcPath.Text := PATH_SRC;
  E_DstPath.Text := PATH_DST;
//  E_DstPath.Text := '\\10.1.1.14\Uchet\Учет\launcher_storage\Uchet';
  Cb_Module.Text := '';
  M_Comment.Text := '';
  M_Comment.MaxLength := 4000;
  MinCompressedFileSize := 3 * 1024 * 1024;
  MaxCompressedFileSize := 8 * 1024 * 1024;
  Timer1Timer(nil);
  SetStatusBar('', '', False);
  {
  Mth.CreateTableGrid(
    Dbg_PrevInstall, False, False, False, False,[
    ['dt', ftDate, 0, 'Дата', 70, True, False, False],
    ['compile_dt', ftString, 100, 'Компиляция', 100, True, False, False],
    ['ver', ftString, 100, 'Версия', 100, True, False, False],
    ['comm', ftString, 60, 'Комментарий', 70, False, False, False]],
    [], '', ''
  );
  }
  ProgressBar1.Visible:= False;
  Result := True;
end;

procedure TForm_Adm_Installer.Timer1Timer(Sender: TObject);
var
  va: TVarDynArray2;
begin
  if Cb_Module.Text = '' then begin
    M_Users.Text := '';
    M_Users.ControlLabel.Caption := 'Сессии';
    Exit;
  end;
  va := Q.QLoadToVarDynArray2('select osuser from v$session where username = :username$s and module = :module$s group by username, module, machine, osuser order by osuser', [S.ToUpper(Q.CurrentShema), Cb_Module.Text + '.exe']);
  M_Users.Text := A.Implode(A.VarDynArray2ColToVD1(va, 0), ', ');
  M_Users.ControlLabel.Font.Color := S.IIf(Length(va) = 0, clblue, clRed);
  M_Users.ControlLabel.Caption := S.IIf(Length(va) = 0, 'Модуль не запущен.', 'Модуль открыт у следующих пользователей (' + IntToStr(Length(va)) + ')');
  if InInstall then Install;
end;

procedure TForm_Adm_Installer.Timer2Timer(Sender: TObject);
var
  va: TVarDynArray;
  st: string;
  i: Integer;
  Chr: WideChar;
begin
  inherited;
Application.ProcessMessages;
//ProgressBar1.Visible:= InInstall;

exit;
  if not InInstall then
    exit;
  Chr := '='; //Utf8Decode(#9724);
  //Lb_Status.Font.Size:=20;
  Lb_Status.Font.Style := [fsBold];
  Lb_Status.Tag := Lb_Status.Tag + 1;
  if Lb_Status.Tag > 30 then
    Lb_Status.Tag := 1;
  va := ['$50FF00', '$50FF22', '$50FF44', '$50FF66', '$50FF88', '$50FFAA', '$50FFCC'];
  va := ['$0000FF', '$00FF00', '$FF0000', '$FFFF00', '$FFFF00', '$FF00FF'];
  va := ['$0000FF', '$00FF00', '$FF0000'];
  Chr := '_';
  st := '';
  for i := 0 to Lb_Status.Tag do
    st := st + va[i mod Length(va)] + Chr;  //Utf8Encode(9724)
  Lb_Status.ResetColors;
  Lb_Status.SetCaption(st);
  Application.ProcessMessages;
end;

function TForm_Adm_Installer.GetFileList: Boolean;
var
  s: string;
  dt1: TDateTime;
  i: Integer;
begin
  Result := False;
  dt1 := Sys.GetFileAge(E_SrcPath.Text + '\' + Cb_Module.Text + '.exe');
  FileList := TDirectory.GetFiles(E_SrcPath.Text, '*.pas'); // TSearchOption.soAllDirectories
  FileList := FileList + TDirectory.GetFiles(E_SrcPath.Text, '*.dfm');
  for i := 0 to High(FileList) do begin
    if Sys.GetFileAge(FileList[i]) > dt1 then
      Exit;
  end;
  if High(FileList) > -1 then
    Result := True;
end;

function TForm_Adm_Installer.Install: Boolean;
var
  s: string;
  dt1: TDateTime;
  i: Integer;
  dn: string;
begin
  Result := False;
  if True or (M_Users.Text = '') then begin
    {$R-}
    Result := CopyFile(
      pwidechar(E_SrcPath.Text + '\' + Cb_Module.Text + '.exe'),
      pwidechar(E_DstPath.Text + PATH_LAUNCHER_STORAGE + '\' + Cb_Module.Text + '.exe'), False
    );
    {$R+}
    if (Result) or (Cb_Module.Value = '0') then begin
      InInstall := False;
      dn := E_DstPath.Text + '\Data\Src\' + Cb_Module.Text + '__' + E_Version.Text + '__' + StringReplace(E_DtCompiled.Text, ':', '.', [rfReplaceAll]);
      {$R-}
      ForceDirectories(dn);
      ForceDirectories(dn + '\BACKUP');
      for i := 0 to High(FileList) do begin
        Application.ProcessMessages;
        CopyFile(pwidechar(FileList[i]), pwidechar(dn + '\' + ExtractFileName(FileList[i])), False);
      end;
      CopyFile(pwidechar(Sys.GetWinTemp + '\' + Cb_Module.Text + '.exe'), pwidechar(dn + '\BACKUP\' + Cb_Module.Text + '.exe'), False);
      Sys.SaveTextToFile(dn + '\!.txt', DateTimeToStr(Now) + #13#10#13#10'Замена:'#13#10 + Lb_InstalledInfo.Caption + #13#10#13#10 + M_Comment.Text);
      {$R+}
      Lb_Status.ResetColors;
      Lb_Status.SetCaption('$00AA00Готово!');
      if not Result then begin
        MyWarningMessage('Модуль "' + Cb_Module.Text + '" не был скопирован, однако все остальные действия завершены успешно. Закройте этот модуль и скопируйте исполняемый файл вручную!');
        Result := True;
      end;
      Q.QExecSql(
        'insert into adm_install_log (id_module, compile_dt, ver, comm) values (:id_module$i, :compile_dt$s, :ver$s, :comm$s)',
        [Cth.GetcontrolValue(Cb_Module), Cth.GetcontrolValue(E_DtCompiled), Cth.GetcontrolValue(E_Version), Cth.GetcontrolValue(M_Comment)]
      );
      Bt_Ok.Enabled := True;
      Cb_Module.Enabled := True;
      M_Comment.Enabled := True;
      E_SrcPath.Enabled := True;
      E_DstPath.Enabled := True;
      Verify;
      ProgressBar1.Visible:= False;
      MyInfoMessage('Готово!');
      Exit;
    end;
  end;
end;

end.
