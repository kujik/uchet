{
Установщик модулей Учета (перенос актуального exe/pas/dfm из каталога разработки в рабочую папку программы).
Вызывается только из uWindows.pas (Wh.ExecReference, myfrm_Adm_Installer) - как правило, вручную, при установке
новой версии модуля после компиляции в Delphi.

Логика работы не менялась (см. также исходный F_Adm_Installer.pas/TForm_Adm_Installer): в диалоге выбирается
модуль из списка (Исходный и Целевой каталоги заданы константами, см. PATH_SRC/PATH_DST, но доступны для правки
прямо в полях). Если найдены pas/dfm/dpr/dproj файлы новее скомпилированного исполняемого файла - выводится
предупреждение, но установка не блокируется. Перед установкой исполняемый файл в каталоге разработки сжимается
через upx (upx.exe должен быть в каталоге проекта). По кнопке "Установить модуль" файл сжимается и копируется на
место с заменой; сессии не проверяются, при неудаче (файл заблокирован) копирование повторяется раз в 10 сек
(см. tmr_Poll) до успеха. После этого файлы pas/dfm/dpr/dproj копируются из каталога разработки в архив
исходников (Data\Src\Модуль__Версия__ДатаКомпиляции), туда же - комментарий к установке (!.txt).

ИСПРАВЛЕНО (по задаче): бэкап исполняемого файла в архиве (папка BACKUP) был полностью нерабочим - в исходном
Bt_OkClick копирование заменяемого файла во временную папку было закомментировано, поэтому последующее
копирование из этой (пустой) временной папки в BACKUP всегда молча ничего не делало (результат CopyFile не
проверялся). Теперь в архив сохраняются ОБА файла: заменяемый (предыдущий) - копируется в
BACKUP\<Модуль>_prev.exe непосредственно перед перезаписью, и только что установленный (текущий) - в
BACKUP\<Модуль>.exe после успешной установки, см. TryInstall.

Замена F_Adm_Installer.pas/TForm_Adm_Installer (наследник устаревшего V_MDI/TForm_MDI) на TFrmAWInstallModule
(наследник TFrmBasicMdi). Так как форма не привязана к конкретной редактируемой записи (а выполняет разовое
действие по кнопке, как в uFrmOGedtOrderPrintLabels.pas), а состоит в основном из произвольных контролов (не
грида) - по аналогии с uFrmODedtMontage.pas взята напрямую от TFrmBasicMdi (без Grid2); панель кнопок диалога
(FOpt.DlgPanelStyle) не используется - кнопка "Установить модуль" (Bt_Install) размещена как обычный TBitBtn
прямо на форме, как и в исходном диалоге.

Грид истории установок (Dbg_PrevInstall: TDBGridEh, только чтение, без сохранения в БД) заменен на фрейм
FrgInstallLog: TFrDBGridEh в оффлайн-режиме (SetInitData(Sql, Params) - данные грида загружаются одним запросом,
подробнее см. общий комментарий в uFrmOGedtOrderPrintLabels.pas). Так как фрейм размещен не в стандартном Grid2,
а как самостоятельный контрол - его подготовка (Prepare/RefreshGrid) и события (OnSelectedDataChange)
вызываются/привязываются вручную в Prepare формы (см. также аналогичный FrgItems в uFrmOWOrder.pas). Обработчики
выбора строки Dbg_PrevInstallAfterScroll/Dbg_PrevInstallCellClick объединены в один
FrgInstallLogSelectedDataChange (общее событие смены выбранных данных грида).

Переименованы неочевидные объекты/переменные для ясности (см. также исходные названия в F_Adm_Installer.pas):
Verify -> RefreshModuleInfo, GetFileList -> CollectSourceFiles, Install -> TryInstall, Bt_Ok -> Bt_Install,
Bt_OkClick -> Bt_InstallClick, tmr1 -> tmr_Poll, tmr1Timer -> tmr_PollTimer, cmb_ModuleChange ->
ModuleParamsChange (один обработчик на выбор модуля и оба пути), edt_Version/edt_DtCompiled ->
edt_NewVersion/edt_NewCompileDt (версия/дата компиляции файла-источника, а не установленного),
lbl_InstalledInfo -> lbl_CompareInfo, lbl_FilesInfo -> lbl_FilesStatus, lbl_Status -> lbl_ResultStatus,
lbl_PrevInstall -> lbl_InstallLog, mem_PrevInstalllcomment (опечатка в исходном имени) -> mem_InstallLogComment,
ProgressBar1 -> pgb_Install, FileList -> FSourceFiles, InInstall -> FInstallPending,
MinCompressedFileSize/MaxCompressedFileSize -> FMinCompressedSize/FMaxCompressedSize.

Удален Timer2/Timer2Timer - обработчик был полностью нерабочим (по факту не делал ничего, кроме
Application.ProcessMessages - вся содержательная часть кода была недостижима из-за безусловного exit в начале,
см. исходный Timer2Timer).

Также убрано заведомо всегда истинное условие "if True or (mem_Users.Text = '') then" в Install/TryInstall
(результат проверки сессий не влиял на решение - оставлена только реально работающая проверка через
cmb_Module.Value = '0').
}
unit uFrmAWInstallModule;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi,
  Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, Vcl.ExtCtrls, uLabelColors, IOUtils, Types,
  Vcl.Buttons, ShellApi, ToolCtrlsEh, DBGridEhToolCtrls, Math,
  GridsEh, DBAxisGridsEh, DBGridEh, AdoDB, DB, Vcl.ComCtrls,
  EhLibVclUtils, MemTableDataEh, DBGridEhGrouping, DynVarsEh,
  DataDriverEh, Clipbrd, Menus, PrnDbgEh, uFrDBGridEh;

type
  TFrmAWInstallModule = class(TFrmBasicMdi)
    cmb_Module: TDBComboBoxEh;
    edt_NewVersion: TDBEditEh;
    edt_NewCompileDt: TDBEditEh;
    lbl_CompareInfo: TLabel;
    edt_SrcPath: TDBEditEh;
    edt_DstPath: TDBEditEh;
    mem_Users: TDBMemoEh;
    mem_Comment: TDBMemoEh;
    Bt_Install: TBitBtn;
    lbl_FilesStatus: TLabel;
    lbl_ResultStatus: TLabel;
    lbl_InstallLog: TLabel;
    FrgInstallLog: TFrDBGridEh;
    mem_InstallLogComment: TDBMemoEh;
    chb_CloseSessions: TDBCheckBoxEh;
    pgb_Install: TProgressBar;
    tmr_Poll: TTimer;
    procedure ModuleParamsChange(Sender: TObject);
    procedure tmr_PollTimer(Sender: TObject);
    procedure Bt_InstallClick(Sender: TObject);
    procedure FrgInstallLogSelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
  private
    { Private declarations }
    //список файлов исходников для копирования в архив при установке
    FSourceFiles: TStringDynArray;
    //есть ли ожидающая повторной попытки установка (сжатый файл готов, ждем возможности скопировать поверх целевого)
    FInstallPending: Boolean;
    //границы размера сжатого upx файла - для контроля, что сжатие действительно прошло (запуск upx без ожидания завершения)
    FMinCompressedSize, FMaxCompressedSize: Integer;
    function Prepare: Boolean; override;
    procedure RefreshModuleInfo;
    function CollectSourceFiles: Boolean;
    function TryInstall: Boolean;
  public
    { Public declarations }
  end;

var
  FrmAWInstallModule: TFrmAWInstallModule;

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
  PATH_APPLICATION_STORAGE = '\Application';

{$R *.dfm}

function TFrmAWInstallModule.Prepare: Boolean;
var
  i: Integer;
begin
  Result := False;
  cmb_Module.Items.Clear;
  cmb_Module.KeyItems.Clear;
  for i := 0 to cMainModulesCount - 1 do begin
    cmb_Module.Items.Add(ModuleRecArr[i].Caption);
    cmb_Module.KeyItems.Add(IntToStr(i));
  end;
  edt_SrcPath.Text := PATH_SRC;
  edt_DstPath.Text := PATH_DST;
  cmb_Module.Text := '';
  mem_Comment.Text := '';
  mem_Comment.MaxLength := 4000;
  FMinCompressedSize := 3 * 1024 * 1024;
  FMaxCompressedSize := 8 * 1024 * 1024;

  //грид истории установок - только чтение, данные грузятся целиком одним запросом (см. RefreshModuleInfo)
  FrgInstallLog.Options := FrDBGridOptionDef;
  FrgInstallLog.Opt.SetFields([
    ['dt$d', 'Дата', '75'],
    ['compile_dt$s', 'Компиляция', '105'],
    ['ver$s', 'Версия', '80'],
    ['comm$s', 'Комментарий', '70;w']
  ]);
  FrgInstallLog.Opt.SetGridOperations('u');
  //FrgInstallLog.Opt.SetButtons(1, 'r');
  FrgInstallLog.SetInitData([]);
  FrgInstallLog.Prepare;
  FrgInstallLog.OnSelectedDataChange := FrgInstallLogSelectedDataChange;
  FrgInstallLog.RefreshGrid;

  tmr_PollTimer(nil);
  pgb_Install.Visible := False;
  Result := True;
end;

procedure TFrmAWInstallModule.ModuleParamsChange(Sender: TObject);
begin
  //RefreshModuleInfo;
end;

procedure TFrmAWInstallModule.RefreshModuleInfo;
//см. также исходный Verify - обновляет информацию о выбранном модуле (версия/дата источника, сравнение с
//установленным, список файлов исходников, сессии пользователей, история установок)
var
  LNewVer, LInstalledVer, LNewCompileDt, LInstalledCompileDt: string;
begin
  edt_NewVersion.Text := '';
  edt_NewCompileDt.Text := '';
  mem_Users.Text := '';
  lbl_CompareInfo.ResetColors;
  lbl_CompareInfo.SetCaption('');
  lbl_FilesStatus.ResetColors;
  lbl_FilesStatus.SetCaption('');
  lbl_ResultStatus.ResetColors;
  lbl_ResultStatus.SetCaption('');
  mem_InstallLogComment.Text := '';
  FrgInstallLog.SetInitData([]);
  FrgInstallLog.RefreshGrid;
  FInstallPending := False;
  Bt_Install.Enabled := False;

  if not DirectoryExists(edt_SrcPath.Text) then begin
    lbl_CompareInfo.SetCaption('$0000FFНеверно задан путь к исходникам!');
    Exit;
  end;

  if not DirectoryExists(edt_DstPath.Text) then begin
    lbl_CompareInfo.SetCaption('$0000FFНеверно задан целевой путь!');
    Exit;
  end;

  if cmb_Module.Text = '' then begin
    lbl_CompareInfo.SetCaption('$000000Модуль для установки не выбран!');
    Exit;
  end
  else begin
    if not FileExists(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe') then begin
      lbl_CompareInfo.SetCaption('$0000FFМодуль для установки не найден в каталоге исходников!');
      Exit;
    end;
  end;

  LNewVer := Module.GetFileVersion(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe');
  LNewCompileDt := Module.GetFileVersion(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe', 'LastCompiledTime');
  edt_NewVersion.Text := LNewVer;
  edt_NewCompileDt.Text := LNewCompileDt;
  Bt_Install.Enabled := True;

  LInstalledVer := Module.GetFileVersion(edt_DstPath.Text + PATH_APPLICATION_STORAGE + '\' + cmb_Module.Text + '.exe');
  LInstalledCompileDt := Module.GetFileVersion(edt_DstPath.Text + PATH_APPLICATION_STORAGE + '\' + cmb_Module.Text + '.exe', 'LastCompiledTime');
  if LInstalledVer + LInstalledCompileDt = '' then
    lbl_CompareInfo.SetCaption('$FF00FFМодуль отсутствует в целевом каталоге!')
  else if LInstalledCompileDt > LNewCompileDt then
    lbl_CompareInfo.SetCaption('$3300FFМодуль в целевом каталоге более новый!!! ($FF0000v' + LInstalledVer + ' от ' + LInstalledCompileDt + '$FF00FF)')
  else if (LInstalledCompileDt = LNewCompileDt) and (LNewVer = LInstalledVer) then
    lbl_CompareInfo.SetCaption('$3300FFМодуль в целевом каталоге такой же!!! ($FF0000v' + LInstalledVer + ' от ' + LInstalledCompileDt + '$FF00FF)')
  else
    lbl_CompareInfo.SetCaption('$FF00FFМодуль в целевом каталоге более ранней версии ($FF0000v' + LInstalledVer + ' от ' + LInstalledCompileDt + '$FF00FF)');

  tmr_PollTimer(nil);
  if not CollectSourceFiles then
    lbl_FilesStatus.SetCaption('$0000FFФайлы исходников новее скомпилированной программы. Необходимо перекомпилировать проект!')
  else
    lbl_FilesStatus.SetCaption('$FF0000Файлы исходников - найдено ' + IntToStr(Length(FSourceFiles)) + ' шт.');

  FrgInstallLog.SetInitData(
    'select dt, compile_dt, ver, comm from adm_install_log where id_module = :id_module$i order by dt desc',
    [Cth.GetControlValue(cmb_Module)]
  );
  FrgInstallLog.RefreshGrid;
  mem_InstallLogComment.Text := FrgInstallLog.GetValueS('comm');
end;

procedure TFrmAWInstallModule.FrgInstallLogSelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
//см. также исходные Dbg_PrevInstallAfterScroll/Dbg_PrevInstallCellClick - объединены в одно событие грида
begin
  mem_InstallLogComment.Text := Fr.GetValueS('comm');
end;

procedure TFrmAWInstallModule.tmr_PollTimer(Sender: TObject);
//см. также исходный tmr1Timer - обновляет список сессий, у которых открыт модуль, и повторяет попытку установки,
//если она ожидает (сжатие уже выполнено, но предыдущая попытка скопировать файл поверх целевого не удалась)
var
  LUsers: TVarDynArray2;
begin
  if cmb_Module.Text = '' then begin
    mem_Users.Text := '';
    mem_Users.ControlLabel.Caption := 'Сессии';
    Exit;
  end;
  LUsers := Q.QLoad('select osuser from v$session where username = :username$s and module = :module$s group by username, module, machine, osuser order by osuser', [S.ToUpper(Q.CurrentShema), cmb_Module.Text + '.exe']);
  mem_Users.Text := A.Implode(A.VarDynArray2ColToVD1(LUsers, 0), ', ');
  mem_Users.ControlLabel.Font.Color := S.IIf(Length(LUsers) = 0, clBlue, clRed);
  mem_Users.ControlLabel.Caption := S.IIf(Length(LUsers) = 0, 'Модуль не запущен.', 'Модуль открыт у следующих пользователей (' + IntToStr(Length(LUsers)) + ')');
  if FInstallPending then TryInstall;
end;

function TFrmAWInstallModule.CollectSourceFiles: Boolean;
//см. также исходный GetFileList - список pas/dfm/dpr/dproj файлов модуля для копирования в архив исходников;
//Result = False, если среди них есть файлы новее скомпилированного исполняемого (не пересобран проект)
var
  LNewExeDt: TDateTime;
  i: Integer;
  LMasks: TVarDynArray;
begin
  Result := False;
  LNewExeDt := Sys.GetFileAge(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe');
  LMasks := ['*.pas', '*.dfm', '*.dpr', '*.dproj'];
  FSourceFiles := [];
  for i := 0 to High(LMasks) do
    FSourceFiles := FSourceFiles + TDirectory.GetFiles(edt_SrcPath.Text, LMasks[i]);
  for i := 0 to High(FSourceFiles) do
    if Sys.GetFileAge(FSourceFiles[i]) > LNewExeDt then Exit;
  if High(FSourceFiles) > -1 then
    Result := True;
end;

procedure TFrmAWInstallModule.Bt_InstallClick(Sender: TObject);
//см. также исходный Bt_OkClick
var
  i, j: Integer;
begin
  if Trim(mem_Comment.Text) = '' then Exit;
  FInstallPending := False;
  if MyQuestionMessage('Обновить модуль "' + cmb_Module.Text + '"?') <> mrYes then Exit;
  Bt_Install.Enabled := False;
  cmb_Module.Enabled := False;
  mem_Comment.Enabled := False;
  edt_SrcPath.Enabled := False;
  edt_DstPath.Enabled := False;
  pgb_Install.Visible := True;
  if chb_CloseSessions.Checked then
    Q.QExecSql('update adm_modules set autoclosedt = (select sysdate from dual), autoclosemin = :idle$i where id = :id$i', [4, Cth.GetControlValue(cmb_Module)]);
  lbl_FilesStatus.SetCaption2('$FF0000Сжимаем исполняемый файл');
  ShellExecute(Application.Handle, nil, pWideChar(edt_SrcPath.Text + '\' + 'upx.exe'), pWideChar(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe'), nil, SW_HIDE);
  for i := 0 to 30 do begin
    Sleep(1000);
    Application.ProcessMessages;
    j := Sys.GetFileSize(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe');
    if (j > FMinCompressedSize) and (j < FMaxCompressedSize) then
      Break;
  end;
  FInstallPending := True;
end;

function TFrmAWInstallModule.TryInstall: Boolean;
//см. также исходный Install. Отличие от исходного - реально работающий бэкап исполняемого файла в архиве
//исходников (папка BACKUP): сохраняется и заменяемый (предыдущий), и только что установленный (текущий) файл -
//см. комментарий к модулю в начале файла.
var
  i: Integer;
  LArchiveDir, LTargetExe: string;
begin
  Result := False;
  LTargetExe := edt_DstPath.Text + PATH_APPLICATION_STORAGE + '\' + cmb_Module.Text + '.exe';
  LArchiveDir := edt_DstPath.Text + '\Data\Src\' + cmb_Module.Text + '__' + edt_NewVersion.Text + '__' + StringReplace(edt_NewCompileDt.Text, ':', '.', [rfReplaceAll]);
  {$R-}
  ForceDirectories(LArchiveDir);
  ForceDirectories(LArchiveDir + '\BACKUP');
  //бэкап заменяемого (предыдущего) исполняемого файла - делаем ДО его перезаписи, пока он еще на месте
  if FileExists(LTargetExe) then
    CopyFile(pwidechar(LTargetExe), pwidechar(LArchiveDir + '\BACKUP\' + cmb_Module.Text + '_prev.exe'), False);
  {$R+}
  lbl_FilesStatus.SetCaption2('$FF0000Копируем исполняемый файл');
  Application.ProcessMessages;
  {$R-}
  Result := CopyFile(pwidechar(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe'), pwidechar(LTargetExe), False);
  {$R+}
  if Result or (cmb_Module.Value = '0') then begin
    FInstallPending := False;
    {$R-}
    for i := 0 to High(FSourceFiles) do begin
      CopyFile(pwidechar(FSourceFiles[i]), pwidechar(LArchiveDir + '\' + ExtractFileName(FSourceFiles[i])), False);
      lbl_FilesStatus.SetCaption2('$FF0000Копируем файл $000000  ($FF00FF' + IntToStr(i + 1) + ' из ' + IntToStr(Length(FSourceFiles)) + ' = ' + IntToStr(Round((i + 1) / Length(FSourceFiles) * 100)) + '%$000000) -- $FF00FF' + ExtractFileName(FSourceFiles[i]));
      Application.ProcessMessages;
    end;
    //бэкап только что установленного (текущего) исполняемого файла - на случай его утраты в дальнейшем
    CopyFile(pwidechar(LTargetExe), pwidechar(LArchiveDir + '\BACKUP\' + cmb_Module.Text + '.exe'), False);
    Sys.SaveTextToFile(LArchiveDir + '\!.txt', DateTimeToStr(Now) + #13#10#13#10'Замена:'#13#10 + lbl_CompareInfo.Caption + #13#10#13#10 + mem_Comment.Text);
    {$R+}
    lbl_ResultStatus.ResetColors;
    lbl_FilesStatus.SetCaption2('$FF0000Файлы исходников - найдено ' + IntToStr(Length(FSourceFiles)) + ' шт.');
    lbl_ResultStatus.SetCaption2('$00AA00Готово!');
    Application.ProcessMessages;
    if not Result then begin
      MyWarningMessage('Модуль "' + cmb_Module.Text + '" не был скопирован, однако все остальные действия завершены успешно. Закройте этот модуль и скопируйте исполняемый файл вручную!');
      Result := True;
    end;
    Q.QExecSql(
      'insert into adm_install_log (id_module, compile_dt, ver, comm) values (:id_module$i, :compile_dt$s, :ver$s, :comm$s)',
      [Cth.GetControlValue(cmb_Module), Cth.GetControlValue(edt_NewCompileDt), Cth.GetControlValue(edt_NewVersion), Cth.GetControlValue(mem_Comment)]
    );
    Q.QExecSql('update adm_modules set module_version = :version$s where id = :id$i', [Cth.GetControlValue(edt_NewVersion) + ' (' + Cth.GetControlValue(edt_NewCompileDt) + ')', Cth.GetControlValue(cmb_Module)]);
    Bt_Install.Enabled := True;
    cmb_Module.Enabled := True;
    mem_Comment.Enabled := True;
    edt_SrcPath.Enabled := True;
    edt_DstPath.Enabled := True;
    RefreshModuleInfo;
    pgb_Install.Visible := False;
    MyInfoMessage('Готово!');
    Exit;
  end;
end;

end.
