unit uSys;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Jpeg, MemTableDataEh, Db,
  ADODB, DataDriverEh, GridsEh, DBGridEh, PropStorageEh, DBAxisGridsEh,
  PngImage, uString, IniFiles, DBCtrlsEh, ShellApi, IOUtils, Types,
  frxClass, frxDesgn, Vcl.Styles,
  IdHTTP, Xml.xmldom,
  IdIOHandler, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  Data.DBXOracle, Menus, System.TypInfo,
  ShlObj, ClipBrd;

type
  NTSTATUS = LongInt;
  THREAD_BASIC_INFORMATION = record
    ExitStatus: NTSTATUS;
    TebBaseAddress: Pointer;
    ClientId: record
      UniqueProcess: THandle;
      UniqueThread: THandle;
    end;
    AffinityMask: ULONG_PTR;
    Priority: LongInt;
    BasePriority: LongInt;
  end;

const
  ThreadBasicInformation = 0;

function NtQueryInformationThread(
  ThreadHandle: THandle;
  ThreadInformationClass: DWORD;
  ThreadInformation: Pointer;
  ThreadInformationLength: ULONG;
  ReturnLength: PULONG
): NTSTATUS; stdcall; external 'ntdll.dll';

type
  TSysHelper = record
    //возвращает значение переменной окружения
    function GetEnvVar(const AVarName: string): string;
    //получить путь к временному каталогу Windows
    function GetWinTemp: string;
    //получить путь к папке Мои документы
    function GetMyDocumentsPath: string;
    //выполнить файл (открыть стандартной программой)
    procedure ExecFile(const AFileName: string);
    //получить имя временного файла в каталоге Temp Windows
    function GetWinTempFileName: string;
    //выполнить файл, если он существует, иначе вывести сообщение об ошибке
    procedure ExecFileIfExists(const AFileName, AErrorMessage: string);
    //получаем признак наличия файла "dev" в каталоге программы
    function GetDevFile: Boolean;
    //получение списка файлов в каталоге рекурсивно (старыми средствами)
    procedure GetFilesInDirectoryRecursive(const ADir: string; AStrings: TStrings);
    //получить список файлов (не каталогов) в каталоге без рекурсии
    function GetFileInDirectoryOnly(const ADirName: string): TStringDynArray;
    //если в папке один файл, открыть файл, если несколько – открыть папку в проводнике, если нет – выдать сообщение
    function OpenFileOrDirectory(const ADirName: Variant; const AErrorMessage: string = ''; const AMask: string = ''): Boolean;
    //получить размер файла
    function GetFileSize(const AFilename: string): Int64;
    //запись строки в лог-файл по имени модуля (с временем записи)
    procedure LogToFile(const AModuleName, AText: string);
    //получить дату модификации файла, если не удалось – вернуть BadDate
    function GetFileAge(const AFileName: string): TDateTime;
    //скачать файл из интернета по ссылке
    function LoadFileFromWWW(const ALink, AFileName: string): Boolean;
    //запись строки в текстовый файл (дозапись или перезапись)
    function SaveTextToFile(const AFileName, AText: string; const AAppendFile: Boolean = False): Boolean;
    //сохранить TVarDynArray2 в файл для отладки
    procedure SaveArray2ToFile(const AArray: TVarDynArray2; const AFileName: string; const AIDEOnly: Boolean = True);
    //копирование файлов в буфер обмена (можно передать несколько через #0)
    procedure CopyFilesToClipboard(const AFileList: string);
    //получить имя исполняемого файла по хендлу окна
    function GetModuleFileByHandle(const AHandle: HWND): string;
    //получить заголовок окна по его хендлу
    function GetWindowHeader(const AHandle: HWND): string;
    //проверить наличие свойства у компонента
    function HasProp(const AComponent: TComponent; const APropName: string): Boolean;
    //установить строковое свойство компонента
    procedure SetCompPropString(const AComponent: TComponent; const APropName, AValue: string);
    //установить объектное свойство компонента
    procedure SetCompPropObj(const AComponent: TComponent; const APropName: string; const APropValue: TObject);
    //вспомогательная функция для получения индекса свойства (не рекомендуется к использованию)
    function GetComponentPropNo(const AComponent: TComponent; const APropName: string; var APropList: PPropList): Integer;
    //установить свойство компонента (объект)
    procedure SetComponentProp(const AComponent: TComponent; const APropName: string; const APropValue: TObject); overload;
    //установить свойство компонента (строка)
    procedure SetComponentProp(const AComponent: TComponent; const APropName: string; const APropValue: string); overload;
    //установить свойство компонента (целое)
    procedure SetComponentProp(const AComponent: TComponent; const APropName: string; const APropValue: Integer); overload;
    //установить свойство компонента (Variant)
    procedure SetComponentProp(const AComponent: TComponent; const APropName: string; const APropValue: Variant); overload;
    //получить информацию о стеке потока (для отладки)
    function GetThreadStackInfo(const AThreadHandle: THandle): string;
  end;

var
  Sys: TSysHelper;

implementation

uses
  psapi,
  uMessages,
  uForms,
  uModule,
  uData;

//==============================================================================
// TSysHelper
//==============================================================================

function TSysHelper.GetEnvVar(const AVarName: string): string;
//возвращает значение переменной окружения
begin
  Result := GetEnvironmentVariable(AVarName);
end;

function TSysHelper.GetWinTemp: string;
//получить путь к временному каталогу Windows
begin
  Result := GetEnvironmentVariable('temp');
end;

function TSysHelper.GetMyDocumentsPath: string;
//получить путь к папке Мои документы
begin
  Result := TPath.GetDocumentsPath;
end;

function TSysHelper.GetWinTempFileName: string;
//получить имя временного файла в каталоге Temp Windows
begin
  Result := TPath.GetTempFileName;
end;

procedure TSysHelper.ExecFile(const AFileName: string);
//выполнить файл (открыть стандартной программой)
begin
  ShellExecute(Application.Handle, nil, PChar(AFileName), nil, nil, SW_SHOWNORMAL);
end;

procedure TSysHelper.ExecFileIfExists(const AFileName, AErrorMessage: string);
//выполнить файл, если он существует, иначе вывести сообщение об ошибке
begin
  if FileExists(AFileName) then
    Sys.ExecFile(AFileName)
  else if AErrorMessage <> '' then
    MyMessageDlg(AErrorMessage, mtWarning, [mbOk]);
end;

function TSysHelper.GetDevFile: Boolean;
//получаем признак наличия файла "dev" в каталоге программы (отладочный режим)
begin
  Result := FileExists(ExtractFilePath(ParamStr(0)) + '\dev');
end;

procedure TSysHelper.GetFilesInDirectoryRecursive(const ADir: string; AStrings: TStrings);
//получение списка файлов в каталоге рекурсивно (старыми средствами)
var
  SearchRec: TSearchRec;
  DirPath: string;
begin
  if (ADir = '') or not Assigned(AStrings) then
    Exit;
  DirPath := IncludeTrailingPathDelimiter(ADir);
  if FindFirst(DirPath + '*.*', faAnyFile, SearchRec) = 0 then
  try
    repeat
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        if (SearchRec.Attr and faDirectory) <> 0 then
          GetFilesInDirectoryRecursive(DirPath + SearchRec.Name, AStrings)
        else
          AStrings.Add(DirPath + SearchRec.Name);
    until FindNext(SearchRec) <> 0;
  finally
    FindClose(SearchRec);
  end;
end;

function TSysHelper.GetFileInDirectoryOnly(const ADirName: string): TStringDynArray;
//получить список файлов (не каталогов) в каталоге без рекурсии
begin
  Result := [];
  if DirectoryExists(ADirName) then
    Result := TDirectory.GetFiles(ADirName);
end;

function TSysHelper.OpenFileOrDirectory(const ADirName: Variant; const AErrorMessage: string = ''; const AMask: string = ''): Boolean;
//если в папке один файл (или один под маску), открыть файл, если несколько – открыть папку, если нет – выдать сообщение
var
  DirList, MaskList: TVarDynArray;
  i, j: Integer;
  FileArray: TStringDynArray;
  Found: Boolean;
begin
  Found := False;
  if VarIsArray(ADirName) then
    DirList := ADirName
  else
    DirList := VarArrayOf([ADirName]);
  for i := 0 to High(DirList) do
  begin
    try
      if AMask = '' then
        FileArray := TDirectory.GetFiles(VarToStr(DirList[i]))
      else
        FileArray := TDirectory.GetFiles(VarToStr(DirList[i]), AMask);
      if Length(FileArray) > 0 then
      begin
        Found := True;
        if Length(FileArray) = 1 then
          Sys.ExecFile(FileArray[0])
        else
          Sys.ExecFile(VarToStr(DirList[i]));
        Break;
      end;
    except
      // игнорируем ошибки доступа к каталогу
    end;
  end;
  if not Found and (AErrorMessage <> '') then
    MyMessageDlg(AErrorMessage, mtWarning, [mbOk]);
  Result := Found;
end;

function TSysHelper.GetFileSize(const AFilename: string): Int64;
//получить размер файла
var
  FileData: TWin32FileAttributeData;
begin
  Result := -1;
  if not GetFileAttributesEx(PChar(AFilename), GetFileExInfoStandard, @FileData) then
    Exit;
  Result := Int64(FileData.nFileSizeLow) or Int64(FileData.nFileSizeHigh shl 32);
end;

procedure TSysHelper.LogToFile(const AModuleName, AText: string);
//запись строки в лог-файл по имени модуля (с временем записи)
var
  FileName: string;
begin
  FileName := Module.ExePath + '\Log\' + AModuleName + '.txt';
  ForceDirectories(ExtractFilePath(FileName));
  SaveTextToFile(FileName, DateTimeToStr(Now) + ' - ' + AText + #13#10, True);
end;

function TSysHelper.GetFileAge(const AFileName: string): TDateTime;
//получить дату модификации файла; если не удалось – вернуть BadDate
var
  FileDate: Integer;
begin
  Result := S.BadDate;
  FileDate := FileAge(AFileName);
  if FileDate > -1 then
    Result := FileDateToDateTime(FileDate);
end;

function TSysHelper.LoadFileFromWWW(const ALink, AFileName: string): Boolean;
//скачать файл из интернета по ссылке
var
  MemoryStream: TMemoryStream;
begin
  Result := False;
  MemoryStream := TMemoryStream.Create;
  try
    MyData.IdHTTP1.Get(ALink, MemoryStream);
    MemoryStream.SaveToFile(AFileName);
    Result := True;
  finally
    MemoryStream.Free;
  end;
end;

function TSysHelper.SaveTextToFile(const AFileName, AText: string; const AAppendFile: Boolean = False): Boolean;
//запись строки в текстовый файл (дозапись или перезапись)
var
  LTextFile: TextFile;
begin
  try
    AssignFile(LTextFile, AFileName);
    if (not FileExists(AFileName)) or not AAppendFile then
      Rewrite(LTextFile)
    else
      Append(LTextFile);
    Write(LTextFile, AText);
    CloseFile(LTextFile);
    Result := True;
  except
    CloseFile(LTextFile);
    Result := False;
  end;
end;

procedure TSysHelper.SaveArray2ToFile(const AArray: TVarDynArray2; const AFileName: string; const AIDEOnly: Boolean = True);
//сохранить TVarDynArray2 в файл для отладки (если AIDEOnly=True, то только при запуске из IDE)
var
  i, j: Integer;
  FileStream: TFileStream;
  Writer: TWriter;
  Line: string;
begin
  if AIDEOnly and not Module.RunFromIDE then
    Exit;
  FileStream := nil;
  Writer := nil;
  try
    FileStream := TFileStream.Create(AFileName, fmCreate or fmShareDenyWrite);
    Writer := TWriter.Create(FileStream, 1024);
    for i := 0 to High(AArray) do
    begin
      Line := '';
      for j := 0 to High(AArray[i]) do
        S.ConcatStP(Line, VarToStr(AArray[i][j]), '||');
      Writer.WriteString(Line + #13#10);
    end;
  finally
    Writer.Free;
    FileStream.Free;
  end;
end;

procedure TSysHelper.CopyFilesToClipboard(const AFileList: string);
//копирование файлов в буфер обмена (можно передать несколько через #0)
var
  DropFiles: PDropFiles;
  GlobalHandle: THandle;
  DataLen: Integer;
begin
  DataLen := Length(AFileList) + 2;
  GlobalHandle := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT,
    SizeOf(TDropFiles) + DataLen * SizeOf(Char));
  if GlobalHandle = 0 then
    raise Exception.Create('Не удалось выделить память для буфера обмена.');
  DropFiles := GlobalLock(GlobalHandle);
  try
    DropFiles^.fWide := True;
    DropFiles^.pFiles := SizeOf(TDropFiles);
    Move(PChar(AFileList)^, (PByte(DropFiles) + SizeOf(TDropFiles))^, DataLen * SizeOf(Char));
  finally
    GlobalUnlock(GlobalHandle);
  end;
  Clipboard.SetAsHandle(CF_HDROP, GlobalHandle);
end;

function TSysHelper.GetModuleFileByHandle(const AHandle: HWND): string;
//получить имя исполняемого файла по хендлу окна
var
  ProcessId: DWORD;
  ProcessHandle: THandle;
  Buffer: array[0..MAX_PATH - 1] of Char;
begin
  GetWindowThreadProcessId(AHandle, ProcessId);
  ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessId);
  if ProcessHandle <> 0 then
  begin
    SetLength(Result, MAX_PATH);
    if GetModuleFileNameEx(ProcessHandle, 0, PChar(Result), MAX_PATH) > 0 then
      Result := PChar(Result)
    else
      Result := '';
    CloseHandle(ProcessHandle);
  end
  else
    Result := '';
end;

function TSysHelper.GetWindowHeader(const AHandle: HWND): string;
//получить заголовок окна по его хендлу
var
  Len: Integer;
begin
  SetLength(Result, 256);
  Len := GetWindowText(AHandle, PChar(Result), Length(Result));
  SetLength(Result, Len);
end;

function TSysHelper.HasProp(const AComponent: TComponent; const APropName: string): Boolean;
//проверить наличие свойства у компонента
var
  PropList: PPropList;
  PropCount, i: Integer;
begin
  Result := False;
  GetMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  try
    PropCount := GetPropList(AComponent.ClassInfo, tkProperties, PropList);
    for i := 0 to PropCount - 1 do
      if SameText(PropList[i]^.Name, APropName) then
      begin
        Result := True;
        Break;
      end;
  finally
    FreeMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  end;
end;

procedure TSysHelper.SetCompPropString(const AComponent: TComponent; const APropName, AValue: string);
//установить строковое свойство компонента
var
  PropList: PPropList;
  PropCount, i: Integer;
begin
  GetMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  try
    PropCount := GetPropList(AComponent.ClassInfo, tkProperties, PropList);
    for i := 0 to PropCount - 1 do
      if SameText(PropList[i]^.Name, APropName) then
      begin
        SetStrProp(AComponent, PropList[i], AValue);
        Break;
      end;
  finally
    FreeMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  end;
end;

procedure TSysHelper.SetCompPropObj(const AComponent: TComponent; const APropName: string; const APropValue: TObject);
//установить объектное свойство компонента
var
  PropList: PPropList;
  PropCount, i: Integer;
begin
  GetMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  try
    PropCount := GetPropList(AComponent.ClassInfo, tkProperties, PropList);
    for i := 0 to PropCount - 1 do
      if SameText(PropList[i]^.Name, APropName) then
      begin
        SetObjectProp(AComponent, PropList[i], APropValue);
        Break;
      end;
  finally
    FreeMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  end;
end;

function TSysHelper.GetComponentPropNo(const AComponent: TComponent; const APropName: string; var APropList: PPropList): Integer;
//вспомогательная функция для получения индекса свойства
var
  PropCount, i: Integer;
begin
  Result := -1;
  GetMem(APropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  try
    PropCount := GetPropList(AComponent.ClassInfo, tkProperties, APropList);
    for i := 0 to PropCount - 1 do
      if SameText(APropList[i]^.Name, APropName) then
      begin
        Result := i;
        Break;
      end;
  finally
    // память освобождается вызывающей стороной
  end;
end;

procedure TSysHelper.SetComponentProp(const AComponent: TComponent; const APropName: string; const APropValue: TObject);
//установить свойство компонента (объект)
var
  PropList: PPropList;
  PropIndex: Integer;
begin
  PropIndex := GetComponentPropNo(AComponent, APropName, PropList);
  if PropIndex >= 0 then
  begin
    SetObjectProp(AComponent, PropList[PropIndex], APropValue);
    FreeMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  end;
end;

procedure TSysHelper.SetComponentProp(const AComponent: TComponent; const APropName: string; const APropValue: string);
//установить свойство компонента (строка)
var
  PropList: PPropList;
  PropIndex: Integer;
begin
  PropIndex := GetComponentPropNo(AComponent, APropName, PropList);
  if PropIndex >= 0 then
  begin
    SetStrProp(AComponent, PropList[PropIndex], APropValue);
    FreeMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  end;
end;

procedure TSysHelper.SetComponentProp(const AComponent: TComponent; const APropName: string; const APropValue: Integer);
//установить свойство компонента (целое)
var
  PropList: PPropList;
  PropIndex: Integer;
begin
  PropIndex := GetComponentPropNo(AComponent, APropName, PropList);
  if PropIndex >= 0 then
  begin
    SetInt64Prop(AComponent, PropList[PropIndex], APropValue);
    FreeMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  end;
end;

procedure TSysHelper.SetComponentProp(const AComponent: TComponent; const APropName: string; const APropValue: Variant);
//установить свойство компонента (Variant)
var
  PropList: PPropList;
  PropIndex: Integer;
begin
  PropIndex := GetComponentPropNo(AComponent, APropName, PropList);
  if PropIndex >= 0 then
  begin
    SetPropValue(AComponent, PropList[PropIndex], APropValue);
    FreeMem(PropList, GetTypeData(AComponent.ClassInfo)^.PropCount * SizeOf(Pointer));
  end;
end;

function TSysHelper.GetThreadStackInfo(const AThreadHandle: THandle): string;
//получить информацию о стеке потока (для отладки)
var
  ThreadInfo: THREAD_BASIC_INFORMATION;
  Status: NTSTATUS;
  StackBase, StackLimit: Pointer;
begin
  Status := NtQueryInformationThread(
    AThreadHandle,
    ThreadBasicInformation,
    @ThreadInfo,
    SizeOf(ThreadInfo),
    nil
  );
  if Status = 0 then
  begin
    StackBase := PPointer(PByte(ThreadInfo.TebBaseAddress) + $8)^;
    StackLimit := PPointer(PByte(ThreadInfo.TebBaseAddress) + $10)^;
    Result := Format(
      'Стек потока: База = %p, Лимит = %p, Размер = %d байт',
      [StackBase, StackLimit, NativeUInt(StackBase) - NativeUInt(StackLimit)]
    );
  end
  else
    Result := 'Ошибка: Не удалось получить информацию о стеке потока';
end;

end.
