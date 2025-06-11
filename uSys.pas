unit uSys;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Jpeg, MemTableDataEh, Db,
  ADODB, DataDriverEh, ADODataDriverEh, MemTableEh, GridsEh, DBGridEh, PropStorageEh, DBAxisGridsEh,
  ImgList, PngImage, uString, IniFiles, DBCtrlsEh, ShellApi, IOUtils, Types,
  System.ImageList, frxClass, frxDesgn, Vcl.Themes, Vcl.Styles, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Xml.xmldom, Xml.XMLIntf,
  Xml.XMLDoc, IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP, iDMessage,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  Data.DBXOracle, Data.SqlExpr, frxTableObject, frxDBSet, Menus, System.TypInfo,
  ShlObj, ClipBrd
  ;

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

type TSysHelper = record
  //���������� �������� ���������� ���������
  function GetEnvVar(const VarName: string): string;
  //�������� ���� � ��������� ���������� ��������
  function GetWinTemp: string;
  //��������� ���� (������� ����������� ����������)
  //�������� ��� ���������� ����� � �������� Temp �������
  //��� ������ ����� ������, ���� 'c:\temp\tmp74D0.tmp'.
  function GetWinTempFileName: string;
  procedure ExecFile(FileName: string);
  //��������� ���� (������� ����������� ����������), ���� ����� ��� ��, � ������ ���� ������ ��������� �� ������ �� ������� ���
  procedure ExecFileIfExists(FileName: string; ErrorMessage: string = '');
  //�������� ������� ������� ����� "dev" � �������� ��������� (��������� �� ���������� ����� ����������)
  //����� - ��� ��� ����� �������� �� �������� ������� TModule
  function GetDevFile: Boolean;
  //��������� ������ ������ (�� ����������) � �������� ����������, ������� ����������
  procedure GetFilesInDirectoryRecursive(Dir: string; Strings: TStrings); //ListFilesInDirectory
  //�������� ������ ������ (�� ���������) � ��������, ��� ��������, ������ ������ ������ �����
  function GetFileInDirectoryOnly(DirName: string): TStringDynArray;  //GetFileListInDirectory
  //���� � ����� ���� ����, �� ������� ���� � �������� ���������, ���� ��������� ������ �� ������� ����� � ����������, ���� ������ ��� ������ ���������
  function OpenFileOrDirectory(DirName: Variant; ErrorMessage: string = ''; Mask: string = ''): Boolean;
  //�������� ������ �����
  function GetFileSize(const aFilename: string): Int64;
  //������ ������ � ��� �� ����� ������, ����� ������ ������� ������ ����� ������
  //�������� ���� \����������� ����� � ������� TDateTime; ���� �� ������ ������� ����, �� ������ BadDate;
  function GetFileAge(FileName: string): TDateTime;
  //������� ���� �� ���������
  function LoadFileFromWWW(Link, FileName: string): Boolean;
  //������ ������ � ��������� ����
  function SaveTextToFile(FileName, Text: string; AppendFile: Boolean = False): Boolean;
  //��������� VarDynArray2 � ����, ��� �������
  procedure SaveArray2ToFile(var va2: TVarDynArray2; FName: string; IDEonly: Boolean = True); //Array2ToFile
  //����������� ����� � ����� ������ (����� ����� �������� � ����������
  //����� �������� ����� ��������� ������ � ����� ������, ����� ����������� #0
  procedure CopyFilesToClipboard(FileList: string);
  //�������� ��� ������������ ����� �� ������ (���������) ����
  function GetModuleFileByHandle(Handle: HWND): string;
  //�������� ��������� ���� �� ��� ������
  function GetWindowHeader(Handle: HWND): string;
  function HasProp(comp: TComponent; const prop: string): Boolean;
  //������������� �������� �������� � ������ ������ (prop) �� ������� (comp)
  //����� ��������, ��� �������� ��������� ���� ���� ������.
  procedure SetCompPropString(comp: TComponent; const prop, s: string);
  procedure SetCompPropObj(comp: TComponent; PropName: string; Prop: TObject);

  //!!!�� ��������
  function GetComponentPropNo(AComponent: TComponent; APropName: string; var PropList: PPropList): Integer;
  procedure SetComponentProp(AComponent: TComponent; APropName: string; APropValue: TObject); overload;
  procedure SetComponentProp(AComponent: TComponent; APropName: string; APropValue: string); overload;
  procedure SetComponentProp(AComponent: TComponent; APropName: string; APropValue: Integer); overload;
//������������� �������� �������� � ������ ������ (prop) �� ������� (comp)
  procedure SetComponentProp(AComponent: TComponent; APropName: string; APropValue: Variant); overload;

  function GetThreadStackInfo(hThread: THandle): string;
end;

var
  Sys: TSysHelper;



implementation

uses
  uDBOra,
  uMessages,
  uForms,
  uSettings,
  uFrmMain,
  uErrors,
  uModule,
  uData
  ;

procedure TSysHelper.ExecFile(FileName: string);
begin
  ShellExecute(Application.Handle, nil, pWideChar(FileName), nil, nil, SW_SHOWNORMAL);
end;

function TSysHelper.GetDevFile: Boolean;
//�������� ������� ������� ����� "dev" � �������� ��������� (��������� �� ���������� ����� ����������)
//����� - ��� ��� ����� �������� �� �������� ������� TModule
begin
  Result:= FileExists(ExtractFilePath(ParamStr(0)) + '\dev');
end;

function TSysHelper.GetModuleFileByHandle(Handle: HWND): string;
//�������� ��� ������������ ����� �� ������ (���������) ����
var
  h: dword;
  buf: array[0..255] of char;
begin
  GetWindowThreadProcessId(Handle, h);
  GetModuleFileName(windows.OpenProcess(0, False, h), @buf[0], 255);
  Result:= buf;
end;

function TSysHelper.GetWindowHeader(Handle: HWND): string;
//�������� ��������� ���� �� ��� ������
var
  buf: array[0..254] of char;
begin
  GetWindowText(Handle, buf, Length(buf));
  Result:=buf;
end;


procedure TSysHelper.ExecFileIfExists(FileName: string; ErrorMessage: string = '');
begin
  if FileExists(FileName)
    then Sys.ExecFile(FileName)
    else if ErrorMessage<>'' then myMessageDlg(ErrorMessage, mtWarning, [mbOk])
end;

function TSysHelper.GetEnvVar(const VarName: string): string;
//���������� �������� ���������� ���������
begin
  Result := GetEnvironmentVariable(VarName);
end;

procedure TSysHelper.GetFilesInDirectoryRecursive(Dir: string; Strings: TStrings);
//��������� ������ ������ � �������� ����������, ������� ����������
var
  rSearchRec: TSearchRec;
begin
  if ((Dir = '') or (not Assigned(Strings))) then
    Exit;
  Dir := IncludeTrailingPathDelimiter(Dir);
  if FindFirst(Dir + '*.*', faAnyFile, rSearchRec) = 0 then
    try
      repeat
        if ((rSearchRec.Name <> '.') and (rSearchRec.Name <> '..')) then
          if (rSearchRec.Attr and faDirectory) <> 0 then
            GetFilesInDirectoryRecursive(Dir + rSearchRec.Name, Strings)
          else
            Strings.Add(Dir + rSearchRec.Name);
      until FindNext(rSearchRec) <> 0;
    finally
      FindClose(rSearchRec);
    end;
end;

function TSysHelper.OpenFileOrDirectory(DirName: Variant; ErrorMessage: string = ''; Mask: string = ''): Boolean;
//��������� - ���� ��� ������ ����� � ������ (������ �������, ��� ������������ \), ��������� ���� �� ������,  ����� �����
//���� � ����� ���� ���� (��� ���� ����������� ��� �����), �� ������� ���� � �������� ���������,
//���� ��������� ������ �� ������� ����� � ����������, ���� ������ ��� ������ ���������
//system, ioutils, types
//���� ������� ������ ����� �� �������� ������� ���� � ������ �������, ���� ������� �� ���������, ���� �� ���� �� ������ �� ������ ��������� �� ������
var
  s: string;
  a: TStringDynArray;
  i,j: Integer;
  DirNames, Masks: TVarDynArray;
  b: Boolean;
begin
  b:=False;
    if VarIsArray(DirName)
      then DirNames:=DirName
      else DirNames:=VarArrayOf([DirName]);
    for j:=0 to High(DirNames) do begin
      try
        //getfiles �������� ����������, ���� ���� �� ������, ����� ������ ������ ����������� ��� ����� ������
        if Mask = ''
          then a:=TDirectory.GetFiles(DirNames[j])
          else a:=TDirectory.GetFiles(DirNames[j], Mask);
        i:=Length(a);
        if i>0 then begin
          //����� �������
          b:= True;
          if i = 1
            //���� ���� ������� � �������, ������� ����, ����� ����� ������� �����
            then Sys.ExecFile(a[0])
            else Sys.ExecFile(DirNames[j]);
          Break;
        end;
      except
      end;
    end;
    if not b
      then begin
        if ErrorMessage<>'' then myMessageDlg(ErrorMessage, mtWarning, [mbOk]);
      end;
    Result:=b;
{  except
    if ErrorMessage<>'' then myMessageDlg(ErrorMessage, mtWarning, [mbOk])
  end;}
end;

//�������� ������ ������ (�� ���������) � ��������, ��� ��������, ������ ������ ������ �����
function TSysHelper.GetFileInDirectoryOnly(DirName: string): TStringDynArray;
//�������� ������ ������ (�� ���������) � ��������, ��� ��������, ������ ������ ������ �����
begin
  try
    Result:=[];
    if DirectoryExists(DirName) then Result:=TDirectory.GetFiles(DirName);
  finally
  end;
end;

function TSysHelper.LoadFileFromWWW(Link, FileName: string): Boolean;
//������� ���� �� ���������
var
  MS:TMemoryStream;
begin
  Result:=False;
  MS :=TMemoryStream.Create;
  try
    MyData.IdHTTP1.Get(Link, MS);
    MS.SaveToFile(FileName);
    Result:=True;
    MS.Free;
  except
    MS.Free;
  end;
end;

function TSysHelper.GetWinTemp: string;
//�������� ���� � ��������� ���������� ��������
begin
  Result:=GetEnvironmentVariable('temp');
end;

function TSysHelper.GetWinTempFileName: string;
//�������� ��� ���������� ����� � �������� Temp �������
//��� ������ ����� ������, ���� 'c:\temp\tmp74D0.tmp'.
begin
  Result:=TPath.GetTempFileName;
end;

function TSysHelper.GetFileSize(const aFilename: string): Int64;
var
  info: TWin32FileAttributeData;
begin
  result := -1;
  if not GetFileAttributesEx(PChar(aFilename), GetFileExInfoStandard, @info) then
    EXIT;
  result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
end;

function TSysHelper.GetFileAge(FileName: string): TDateTime;
//�������� ���� \����������� ����� � ������� TDateTime; ���� �� ������ ������� ����, �� ������ BadDate;
var
  FileDate   : Integer;
begin
  Result:=S.BadDate;
  FileDate := FileAge(FileName);
  // �� �������� �������� �����?
  if fileDate > -1 then
  Result := FileDateToDateTime(fileDate);
end;

function TSysHelper.SaveTextToFile(FileName, Text: string; AppendFile: Boolean = False): Boolean;
var
  f : TextFile;
begin
  try
    assign(f, FileName);
    if (not FileExists(FileName)) or not AppendFile
      then Rewrite(f)
      else Append(f);
    write(f, Text);
    Close(f);
    Result:=True;
  except
    Close(f);
    Result:=False;
  end;
end;

procedure TSysHelper.SaveArray2ToFile(var va2: TVarDynArray2; FName: string; IDEonly: Boolean = True);
var
  i, j: Integer;
  fs: TFileStream;
  fw: TWriter;
  st: string;
begin
  if IdeOnly then
    if not Module.RunFromIDE
      then Exit;
  fs := nil;
  fw := nil;
  try
    fs := TFileStream.Create(fname, fmCreate or fmShareDenyWrite);
    fw := TWriter.Create(fs, 1024);
    for i := 0 to High(va2) do begin
      st:='';
      for j := 0 to High(va2[i]) do
        S.ConcatStP(st, VarToStr(va2[i][j]), '||');
      fw.WriteString(st+#13#10);
    end;
  finally
    fw.Free;
    fs.Free;
  end;
end;

procedure TSysHelper.CopyFilesToClipboard(FileList: string);
//����������� ����� � ����� ������ (����� ����� �������� � ����������
//����� �������� ����� ��������� ������ � ����� ������, ����� ����������� #0
//uses ShlObj, ClipBrd
//CopyFilesToClipboard('C:\Bootlog.Txt'#0'C:\AutoExec.Bat');
var
  DropFiles: PDropFiles;
  hGlobal: THandle;
  iLen: Integer;
begin
  iLen := Length(FileList) + 2;
  FileList := FileList + #0#0;
{  hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT,  SizeOf(TDropFiles) + iLen);    //� �7           }
  hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT, SizeOf(TDropFiles) + iLen * SizeOf(Char));
  if (hGlobal = 0) then raise Exception.Create('Could not allocate memory.');
  begin
    DropFiles := GlobalLock(hGlobal);
    DropFiles^.fWide := True; //�� ���� � �7
    DropFiles^.pFiles := SizeOf(TDropFiles);
{    Move(FileList[1], (PChar(DropFiles) + SizeOf(TDropFiles))^, iLen); //� �7 }
    Move(FileList[1], (PByte(DropFiles) + SizeOf(TDropFiles))^, iLen * SizeOf(Char));
    GlobalUnlock(hGlobal);
    Clipboard.SetAsHandle(CF_HDROP, hGlobal);
  end;
end;


{
function TSysHelper.GetTypeName(V: string;
var
  v: TTest;
  i: Integer;
begin
result:=GetEnumName(TypeInfo(TTest), ord(bb));

  case v of
    bb: Exit;
  end;
end;}

function TSysHelper.HasProp(comp: TComponent; const prop: string): Boolean;
var
  proplist: PPropList;
  numprops, i: Integer;
begin
  result := False;
  getmem(proplist, getTypeData(comp.classinfo)^.propcount * Sizeof(Pointer));
  try
    NumProps := getproplist(comp.classInfo, tkProperties, proplist);
    for i := 0 to pred(NumProps) do
    begin
      if comparetext(proplist[i]^.Name, prop) = 0 then
      begin
        result := True;
        break;
      end;
    end;
  finally
    freemem(proplist, getTypeData(comp.classinfo)^.propcount * Sizeof(Pointer));
  end;
end;

{
function HasProperty(obj: TObject; propertyName: string): Boolean;
var
  Props: TRttiContext;
begin
  Props := TRttiContext.Create;
  try
    for var Prop in Props.GetType(obj.ClassInfo).GetProperties do
      if Prop.Name = propertyName then
        Result := True;
  finally
    Props.Free;
  end;
end;}

procedure TSysHelper.SetCompPropString(comp: TComponent; const prop, s: string);
//������������� �������� �������� � ������ ������ (prop) �� ������� (comp)
//!!!���� ������������� �������� ���� ������, ���� ���������� ���� �������� ���� � ������������� ��������
var
  proplist: PPropList;
  numprops, i: Integer;
  st: string;
begin
  getmem(proplist, getTypeData(comp.classinfo)^.propcount * Sizeof(Pointer));
  try
    NumProps := getproplist(comp.classInfo, tkProperties, proplist);
    for i := 0 to pred(NumProps) do
    begin
      if (comparetext(proplist[i]^.Name, prop) = 0)
        //and (comparetext(proplist[i]^.proptype^.name, 'string') = 0)  //����� ����� ��� ���� ��������
        then  begin
          setStrProp(comp, proplist[i], s);
          st:=proplist[i]^.proptype^.name;
          break;
        end;
    end;
  finally
    freemem(proplist, getTypeData(comp.classinfo)^.propcount * Sizeof(Pointer));
  end;
end;

procedure TSysHelper.SetCompPropObj(comp: TComponent; PropName: string; Prop: TObject);
//������������� �������� �������� � ������ ������ (prop) �� ������� (comp)
var
  proplist: PPropList;
  numprops, i: Integer;
  st: string;
begin
  getmem(proplist, getTypeData(comp.classinfo)^.propcount * Sizeof(Pointer));
  try
    NumProps := getproplist(comp.classInfo, tkProperties, proplist);
    for i := 0 to pred(NumProps) do
    begin
      if (comparetext(proplist[i]^.Name, propname) = 0)
//        and (comparetext(proplist[i]^.proptype^.name, 'string') = 0)  //����� ����� ��� ���� ��������
        then  begin
          System.TypInfo.SetObjectProp(comp, proplist[i], Prop);
          break;
        end;
    end;
  finally
    freemem(proplist, getTypeData(comp.classinfo)^.propcount * Sizeof(Pointer));
  end;
end;

function TSysHelper.GetComponentPropNo(AComponent: TComponent; APropName: string; var PropList: PPropList): Integer;
var
  numprops, i: Integer;
  st: string;
  PropvaList: PPropList;
begin
  getmem(proplist, getTypeData(AComponent.classinfo)^.propcount * Sizeof(Pointer));
  Result:= -1;
  try
    NumProps := getproplist(AComponent.classInfo, tkProperties, proplist);
    for i := 0 to pred(NumProps) do begin
      if (comparetext(proplist[i]^.Name, APropName) = 0)
//        and (comparetext(proplist[i]^.proptype^.name, 'string') = 0)  //����� ����� ��� ���� ��������
        then begin
          Result:= i;
          break;
        end;
    end;
  finally
 //   freemem(proplist, getTypeData(AComponent.classinfo)^.propcount * Sizeof(Pointer));
  end;
end;


procedure TSysHelper.SetComponentProp(AComponent: TComponent; APropName: string; APropValue: TObject);
var
  PropList: PPropList;
  NumProp: Integer;
begin
  try
    NumProp:= GetComponentPropNo(AComponent, APropName, PropList);
    if NumProp >= 0
      then System.TypInfo.SetObjectProp(AComponent, PropList[NumProp], APropValue);
  finally
    freemem(proplist, getTypeData(AComponent.classinfo)^.propcount * Sizeof(Pointer));
  end;
end;

procedure TSysHelper.SetComponentProp(AComponent: TComponent; APropName: string; APropValue: string);
var
  PropList: PPropList;
  NumProp: Integer;
begin
  try
    NumProp:= GetComponentPropNo(AComponent, APropName, PropList);
    if NumProp >= 0
      then System.TypInfo.SetStrProp(AComponent, PropList[NumProp], APropValue);
  finally
    freemem(proplist, getTypeData(AComponent.classinfo)^.propcount * Sizeof(Pointer));
  end;
end;

procedure TSysHelper.SetComponentProp(AComponent: TComponent; APropName: string; APropValue: Integer);
var
  PropList: PPropList;
  NumProp: Integer;
begin
  try
    NumProp:= GetComponentPropNo(AComponent, APropName, PropList);
    if NumProp >= 0
      then System.TypInfo.SetInt64Prop(AComponent, PropList[NumProp], APropValue);
  finally
    freemem(proplist, getTypeData(AComponent.classinfo)^.propcount * Sizeof(Pointer));
  end;
end;

procedure TSysHelper.SetComponentProp(AComponent: TComponent; APropName: string; APropValue: Variant);
var
  PropList: PPropList;
  NumProp: Integer;
begin
  try
    NumProp:= GetComponentPropNo(AComponent, APropName, PropList);
    if NumProp >= 0
      then System.TypInfo.SetPropValue(AComponent, PropList[NumProp], APropValue);
  finally
    freemem(proplist, getTypeData(AComponent.classinfo)^.propcount * Sizeof(Pointer));
  end;
end;

function TSysHelper.GetThreadStackInfo(hThread: THandle): string;
var
  ThreadInfo: THREAD_BASIC_INFORMATION;
  Status: NTSTATUS;
  StackBase, StackLimit: Pointer;
begin
  Status := NtQueryInformationThread(
    hThread,
    ThreadBasicInformation,
    @ThreadInfo,
    SizeOf(ThreadInfo),
    nil
  );

  if Status = 0 then
  begin
    // �������� StackBase � StackLimit �� TEB (Thread Environment Block)
    StackBase := PPointer(PByte(ThreadInfo.TebBaseAddress) + $8)^;  // TIB.StackBase
    StackLimit := PPointer(PByte(ThreadInfo.TebBaseAddress) + $10)^; // TIB.StackLimit

    Result := Format(
      '���� ������: ���� = %p, ����� = %p, ������ = %d ����',
      [StackBase, StackLimit, NativeUInt(StackBase) - NativeUInt(StackLimit)]
    );
  end
  else
    Result := '������: �� ������� �������� ���������� � ����� ������';
end;






begin
end.
