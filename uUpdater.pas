{
Запуск автообновления программы с сервера.

Вклюючается только если программа запускается из C:\Users\username\AppData\Local\Uchet

В последнем каталоге содержится подкаталог Updater и в нем файлы
updater.cfg - список файлов в ANSI по троке на файл, которые надо копировать, за исключением исполняемых ффайлов модулей
updater.dir - путь на сервере к дистрибутиву Учета, без заключающего слэша.
на сервере по этому пути содержатся:
папка Application - включает все необходимые файлы для локального запуска Учета.
папка Updater - содержит программу-обновлятор Uchet_updater.exe, и указанные выше конфигурационные файлы.

процедура CheckForUpdatesAndRunUpdater вызывается в проекте после проверки майтекса и выполняет следующие действия:
(если программы в нужном каталоге)
проверяет актуальность запущенного файла, сравнивая дату с файлом на сервере, а если они идентичны,
то проверяет также и файлы из updater.dir.
если актульно, то далее программа выполняется как обычно.
если нет, то сначала обновляет все файлы в папке Updater, а потом
запускает из нее файл Uchet_updater.exe с параметром соответствующим айди модуля и завершает программу.

программы Uchet_updater.exe делает следующее:
орбновляет с сервера переданный файл модуля и все вспомогательные файлы.
пишет лог обновления в папку Updater\Log
имеет графический интерфейс, который отображается во время обновления, отображает прогресс,
в потоке копируется только исполняемый файл модуля, при этом процесс дожидается пока обновляемый файл будет закрыт.
в случае удачного копирования запускает обновленный модуль Учёте.

}

unit uUpdater;

interface

procedure CheckForUpdatesAndRunUpdater;

implementation

uses
  System.SysUtils, System.IOUtils, System.Classes, Winapi.Windows, Winapi.ShellAPI,
  uData;

procedure CheckForUpdatesAndRunUpdater;
var
  ExeFullPath, ExeDir, ExeName, ExeBaseName: string;
  LocalAppDataPath, TargetAppDataDir: string;
  IsInTargetDir: Boolean;
  UpdaterDir, LogDir, LogFileName: string;
  ServerBasePath, ServerAppDir, ServerUpdaterDir: string;
  CfgLines: TStringList;
  FileName, LocalFile, ServerFile: string;
  NeedUpdate: Boolean;
  Code: Integer;
  UpdaterExe: string;
  ServerFiles: TArray<string>;
  S: string;
begin
  ExeFullPath := ParamStr(0);
  ExeDir := ExtractFilePath(ExeFullPath);
  ExeName := ExtractFileName(ExeFullPath);
  ExeBaseName := ChangeFileExt(ExeName, '');

//    MessageBox(0, pWideChar('1'), 'Ошибка', 0);


  // Определяем целевую папку установки: %LOCALAPPDATA%\Uchet\
  LocalAppDataPath := GetEnvironmentVariable('LOCALAPPDATA');
  if LocalAppDataPath <> '' then
    TargetAppDataDir := IncludeTrailingPathDelimiter(LocalAppDataPath) + 'Uchet\'
  else
    TargetAppDataDir := '';

  // Проверяем, находится ли текущий каталог программы внутри TargetAppDataDir
  IsInTargetDir := (TargetAppDataDir <> '') and (Length(ExeDir) >= Length(TargetAppDataDir)) and (CompareText(Copy(ExeDir, 1, Length(TargetAppDataDir)), TargetAppDataDir) = 0);

  if not IsInTargetDir then
    Exit; // не из целевой папки – пропускаем обновление

  // Определяем пути
  UpdaterDir := ExeDir + 'Updater' + PathDelim;
  LogDir := ExeDir + 'Log' + PathDelim;

  // Создаём папку для логов, если её нет
  if not TDirectory.Exists(LogDir) then
    TDirectory.CreateDirectory(LogDir);

  // Имя лог-файла: ИмяПрограммы_ГГГГММДД_ЧЧММСС.log
  LogFileName := LogDir + ExeBaseName + '_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.log';

  try
    // --- Чтение updater.dir ---
    if not TFile.Exists(UpdaterDir + 'updater.dir') then
      raise Exception.Create('Не найден файл updater.dir');


    with TStringList.Create do
    try
      LoadFromFile(UpdaterDir + 'updater.dir', TEncoding.ANSI);
      if Count = 0 then
        raise Exception.Create('Файл updater.dir пуст');
      ServerBasePath := Trim(Strings[0]);
    finally
      Free;
    end;

    ServerBasePath := IncludeTrailingPathDelimiter(ServerBasePath);
    ServerAppDir := ServerBasePath + 'Application' + PathDelim;
    ServerUpdaterDir := ServerBasePath + 'Updater' + PathDelim;

    // --- Проверка необходимости обновления ---
    NeedUpdate := False;

    // Проверяем текущий исполняемый файл
    LocalFile := ExeFullPath;
    ServerFile := ServerAppDir + ExeName;
    if TFile.Exists(ServerFile) then begin
      if (not TFile.Exists(LocalFile)) or (TFile.GetLastWriteTime(LocalFile) <> TFile.GetLastWriteTime(ServerFile)) then begin
        NeedUpdate := True;
//        TFile.AppendAllText(LogFileName, FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ': ' + 'Требуется обновление основного файла.' + sLineBreak);
      end;
    end;

    // Если exe актуален, проверяем файлы из updater.cfg
    if not NeedUpdate and TFile.Exists(UpdaterDir + 'updater.cfg') then begin
      CfgLines := TStringList.Create;
      try
        CfgLines.LoadFromFile(UpdaterDir + 'updater.cfg', TEncoding.ANSI);
        for FileName in CfgLines do begin
          if FileName = '' then
            Continue;
          LocalFile := ExeDir + Trim(FileName);
          ServerFile := ServerAppDir + Trim(FileName);
          if not TFile.Exists(ServerFile) then
            Continue;
          if (not TFile.Exists(LocalFile)) or (TFile.GetLastWriteTime(LocalFile) <> TFile.GetLastWriteTime(ServerFile)) then begin
            NeedUpdate := True;
            Break;
          end;
        end;
      except
        CfgLines.Free;
      end;
    end;
    // Если обновление не требуется, просто выходим – программа продолжит работу
    if not NeedUpdate then
      Exit;

    // --- Обновление локальной папки Updater с сервера ---
    if TDirectory.Exists(ServerUpdaterDir) then begin
      if not TDirectory.Exists(UpdaterDir) then
        TDirectory.CreateDirectory(UpdaterDir);

      ServerFiles := TDirectory.GetFiles(ServerUpdaterDir, '*.*', TSearchOption.soTopDirectoryOnly);
      for S in ServerFiles do begin
        LocalFile := UpdaterDir + ExtractFileName(S);
        if (not TFile.Exists(LocalFile)) or (TFile.GetLastWriteTime(LocalFile) <> TFile.GetLastWriteTime(S)) then begin
          TFile.Copy(S, LocalFile, True);
        end;
      end;
    end;

    UpdaterExe := UpdaterDir + 'Uchet_Updater.exe';
    if not TFile.Exists(UpdaterExe) then
      raise Exception.Create('Не найден файл обновлятора: ' + UpdaterExe);

    // Запускаем обновлятор с параметром-кодом
    ShellExecute(0, 'open', PChar(UpdaterExe), PChar(IntToStr(cMainModule)), nil, SW_SHOWNORMAL);

    // Завершаем текущую программу (обновлятор возьмёт управление на себя)
    Halt(0);

  except
    on E: Exception do begin
      // Запись ошибки в лог
      try
        TFile.AppendAllText(LogFileName, FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ': ' + E.Message + sLineBreak);
      except
      end;
      // Показываем сообщение пользователю
      MessageBox(0, PChar('Ошибка при обновлении программы ' + ExeBaseName + '.'#13#10'Программа будет завершена.'), 'Ошибка', MB_OK + MB_ICONERROR);
      Halt(1);
    end;
  end;
end;

end.
