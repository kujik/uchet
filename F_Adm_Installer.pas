{

��������� ������� �����

��������� ������ �� ����� ���������� ������������ � ������� ����� ���������.
����� ����������� ���������� ��������������� �������������� ������ (������������ ��������� �� �����),
���������� ������ ��������� �� F9 �� ������. ������ �����, ������ ��� ��������� ������� �� �����, � �� uchet.exe.
� ������ ���� ��������� ��� ������� ����� ��-��� ���.

� ������� ���������� ������ �� ������. ������� ���� � ������� ���� ��������� ���� ���������� � ����, �� ����� ���� ��������.

���� ���� ������� pas/dfm �����, ����� ���� ����������� ���������������� �����, ����� ������ ��������������, �� ���������� �� �����������.

����� ���������� ���� � �������� ���������� ��������� � ������� upx, upx.exe ������ ���������� � ����� �������.

� ������� ������������ ���������� � ��������� ����� ������ � � ��� ��� ��������� � ������� �����, � ����� ������������, � ���� �� ������.

�� ����� �� ������ ���� ��������� � ��������� �������� ���������� ���� � �������, ������ �� �����������, ������� ����������� ��� � 10���,
���� �� ���������� ������. ����� ����� ����� pas/dfm ���������� �� �������� ���������� � ������� (Data/Src/���������__������__��������������).
���� �� ���������� ����������� � ���� !.txt, � ���������� ����������� ���� � ����� BACKUP

��� ��������� ������ � ������� �������� ��� ������ ���������� �� [Ctrl]-F9, �� � ���� ������� ��� ������ Ctrl-Shift-F9 � ����������� �������!!!


��������� ���������!!!
����� ����� ���������� � ����� ��������� �������� �� ��
������ ������� � ��
������ �������� ����� �� ������

}

unit F_Adm_Installer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI,
  Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, Vcl.ExtCtrls, uLabelColors, IOUtils, Types,
  Vcl.Buttons, ShellApi, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, GridsEh, DBAxisGridsEh, DBGridEh, AdoDB, DB, Vcl.ComCtrls,
  EhLibVclUtils;

type
  TForm_Adm_Installer = class(TForm_MDI)
    cmb_Module: TDBComboBoxEh;
    edt_Version: TDBEditEh;
    edt_DtCompiled: TDBEditEh;
    lbl_InstalledInfo: TLabel;
    edt_SrcPath: TDBEditEh;
    edt_DstPath: TDBEditEh;
    mem_Users: TDBMemoEh;
    tmr1: TTimer;
    mem_Comment: TDBMemoEh;
    Bt_Ok: TBitBtn;
    lbl_FilesInfo: TLabel;
    lbl_Status: TLabel;
    Timer2: TTimer;
    lbl_PrevInstall: TLabel;
    Dbg_PrevInstall: TDBGridEh;
    mem_PrevInstalllcomment: TDBMemoEh;
    chb_CloseSessions: TDBCheckBoxEh;
    ProgressBar1: TProgressBar;
    procedure cmb_ModuleChange(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure Bt_OkClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Dbg_PrevInstallAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    //������ ������ ��� ����������� � ���������
    FileList: TStringDynArray;
    //� ��������� ���������
    InInstall: Boolean;
    //������������ � ����������� ������� ������� ����� - ��� �������� ��� �� ��� ����, ��� ��� ������ upx ��� ��������, �������� � Prepare
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
  //���� � ����������
  PATH_SRC = 'R:\Projects\Uchet';
  //���� ������������ �������� �����
  PATH_DST = '\\10.1.1.14\Uchet\����';
  //���� ����������� (������ ���������� �� �����, ���� �� ������
  PATH_LAUNCHER_STORAGE = '\launcher_storage\Uchet';

{$R *.dfm}

procedure TForm_Adm_Installer.Bt_OkClick(Sender: TObject);
var
  i, j: Integer;
begin
  inherited;
  if Trim(mem_Comment.Text) = '' then Exit;
  InInstall := False;
  if MyQuestionMessage('�������� ������ "' + cmb_Module.Text + '"?') <> mrYes then
    Exit;
  Bt_Ok.Enabled := False;
  cmb_Module.Enabled := False;
  mem_Comment.Enabled := False;
  edt_SrcPath.Enabled := False;
  edt_DstPath.Enabled := False;
  {$R-}
  CopyFile(pwidechar(edt_DstPath.Text + PATH_LAUNCHER_STORAGE + '\' + cmb_Module.Text + '.exe'), pwidechar(Sys.GetWinTemp + '\' + cmb_Module.Text + '.exe'), False);
  {$R+}
  ProgressBar1.Visible:= True;
  if chb_CloseSessions.Checked
    then Q.QExecSql('update adm_modules set autoclosedt = (select sysdate from dual), autoclosemin = :idle$i where id = :id$i', [4, Cth.GetControlValue(cmb_Module)]);
  ShellExecute(Application.Handle, nil, pWideChar(edt_SrcPath.Text + '\' + 'upx.exe'), pWideChar(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe'), nil, SW_HIDE);
  for i := 0 to 30 do begin
    sleep(1000);
    Application.ProcessMessages;
    j := Sys.GetFileSize(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe');
    if (j > MinCompressedFileSize) and (j < MaxCompressedFileSize) then
      Break;
  end;
  InInstall := True;
end;

procedure TForm_Adm_Installer.cmb_ModuleChange(Sender: TObject);
begin
  Verify;
end;

procedure TForm_Adm_Installer.Verify;
var
  Ver1, Ver2, Dt1, Dt2: string;
  va2: TVarDynArray2;
begin
  inherited;
  edt_Version.Text := '';
  edt_DtCompiled.Text := '';
  mem_Users.Text := '';
  lbl_InstalledInfo.ResetColors;
  lbl_InstalledInfo.SetCaption('');
  lbl_FilesInfo.ResetColors;
  lbl_FilesInfo.SetCaption('');
  lbl_Status.ResetColors;
  lbl_Status.SetCaption('');
  InInstall := False;
  Bt_Ok.Enabled := False;

  if not (DirectoryExists(edt_SrcPath.Text)) then begin
    lbl_InstalledInfo.SetCaption('$0000FF������� ����� ���� � ����������!');
    Exit;
  end;

  if not (DirectoryExists(edt_DstPath.Text)) then begin
    lbl_InstalledInfo.SetCaption('$0000FF������� ����� ������� ����!');
    Exit;
  end;

  if cmb_Module.Text = '' then begin
    lbl_InstalledInfo.SetCaption('$000000������ ��� ��������� �� ������!');
    Exit;
  end
  else begin
    if not FileExists(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe') then begin
      lbl_InstalledInfo.SetCaption('$0000FF������ ��� ��������� �� ������ � �������� ����������!');
      exit;
    end;
  end;
  Ver1 := Module.GetFileVersion(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe');
  Dt1 := Module.GetFileVersion(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe', 'LastCompiledTime');
  edt_Version.Text := Ver1;
  edt_DtCompiled.Text := Dt1;
  Bt_Ok.Enabled := True;

  Ver2 := '';
  Dt2 := '';
  Ver2 := Module.GetFileVersion(edt_DstPath.Text + PATH_LAUNCHER_STORAGE + '\' + cmb_Module.Text + '.exe');
  Dt2 := Module.GetFileVersion(edt_DstPath.Text + PATH_LAUNCHER_STORAGE + '\' + cmb_Module.Text + '.exe', 'LastCompiledTime');
  if Ver2 + Dt2 = '' then begin
    lbl_InstalledInfo.SetCaption('$FF00FF������ ����������� � ������� ��������!');
  end
  else if Dt2 > Dt1 then begin
    lbl_InstalledInfo.SetCaption('$3300FF������ � ������� �������� ����� �����!!! ($FF0000v' + Ver2 + ' �� ' + Dt2 + '$FF00FF)');
  end
  else if (Dt2 = Dt1) and (Ver1 = Ver2) then begin
    lbl_InstalledInfo.SetCaption('$3300FF������ � ������� �������� ����� ��!!! ($FF0000v' + Ver2 + ' �� ' + Dt2 + '$FF00FF)');
  end
  else begin
    lbl_InstalledInfo.SetCaption('$FF00FF������ � ������� �������� ����� ������ ������ ($FF0000v' + Ver2 + ' �� ' + Dt2 + '$FF00FF)');
  end;
  tmr1Timer(nil);
  if not GetFileList then begin
    lbl_FilesInfo.SetCaption('$0000FF����� ���������� ����� ���������������� ���������. ���������� ����������������� ������!');
  end
  else begin
    lbl_FilesInfo.SetCaption('$FF0000����� ���������� - ������� ' + IntToStr(Length(FileList)) + ' ��.');
  end;

  mem_PrevInstalllcomment.Text:='';
  va2:=Q.QLoadToVarDynArray2(
    'select dt, compile_dt, ver, comm from adm_install_log where id_module = :id$i order by dt desc',
    [Cth.Getcontrolvalue(cmb_module)]
  );
  Mth.CreateTableGrid(
    Dbg_PrevInstall, False, False, False, False,[
    ['dt', ftDate, 0, '����', 70, True, False, False],
    ['compile_dt', ftString, 100, '����������', 105, True, False, False],
    ['ver', ftString, 100, '������', 80, True, False, False],
    ['comm', ftString, 4000, '�����������', 70, False, False, False]],
    va2, '', ''
  );
  Dbg_PrevInstall.DataSet.AfterScroll:=Dbg_PrevInstallAfterScroll;
  Dbg_PrevInstall.DataSet.Last;
  Dbg_PrevInstall.DataSet.First;
end;

procedure TForm_Adm_Installer.Dbg_PrevInstallAfterScroll(DataSet: TDataSet);
begin
  inherited;
//1  mem_PrevInstalllcomment.Text:=Dbg_PrevInstall.DataSource.DataSet.FieldByName('comm').AsString;
end;

function TForm_Adm_Installer.Prepare: Boolean;
var
  i, j: Integer;
  st: string;
  Cb: TCheckBox;
  Dt: TdateTime;
begin
  Result := False;
  cmb_Module.Items.clear;
  cmb_Module.KeyItems.clear;
  for i := 0 to cMainModulesCount - 1 do begin
    cmb_Module.Items.Add(ModuleRecArr[i].Caption);
    cmb_Module.KeyItems.Add(IntToStr(i));
  end;
  edt_SrcPath.Text := PATH_SRC;
  edt_DstPath.Text := PATH_DST;
//  edt_DstPath.Text := '\\10.1.1.14\Uchet\����\launcher_storage\Uchet';
  cmb_Module.Text := '';
  mem_Comment.Text := '';
  mem_Comment.MaxLength := 4000;
  MinCompressedFileSize := 3 * 1024 * 1024;
  MaxCompressedFileSize := 8 * 1024 * 1024;
  tmr1Timer(nil);
  SetStatusBar('', '', False);
  {
  Mth.CreateTableGrid(
    Dbg_PrevInstall, False, False, False, False,[
    ['dt', ftDate, 0, '����', 70, True, False, False],
    ['compile_dt', ftString, 100, '����������', 100, True, False, False],
    ['ver', ftString, 100, '������', 100, True, False, False],
    ['comm', ftString, 60, '�����������', 70, False, False, False]],
    [], '', ''
  );
  }
  ProgressBar1.Visible:= False;
  Result := True;
end;

procedure TForm_Adm_Installer.tmr1Timer(Sender: TObject);
var
  va: TVarDynArray2;
begin
  if cmb_Module.Text = '' then begin
    mem_Users.Text := '';
    mem_Users.ControlLabel.Caption := '������';
    Exit;
  end;
  va := Q.QLoadToVarDynArray2('select osuser from v$session where username = :username$s and module = :module$s group by username, module, machine, osuser order by osuser', [S.ToUpper(Q.CurrentShema), cmb_Module.Text + '.exe']);
  mem_Users.Text := A.Implode(A.VarDynArray2ColToVD1(va, 0), ', ');
  mem_Users.ControlLabel.Font.Color := S.IIf(Length(va) = 0, clblue, clRed);
  mem_Users.ControlLabel.Caption := S.IIf(Length(va) = 0, '������ �� �������.', '������ ������ � ��������� ������������� (' + IntToStr(Length(va)) + ')');
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
  //lbl_Status.Font.Size:=20;
  lbl_Status.Font.Style := [fsBold];
  lbl_Status.Tag := lbl_Status.Tag + 1;
  if lbl_Status.Tag > 30 then
    lbl_Status.Tag := 1;
  va := ['$50FF00', '$50FF22', '$50FF44', '$50FF66', '$50FF88', '$50FFAA', '$50FFCC'];
  va := ['$0000FF', '$00FF00', '$FF0000', '$FFFF00', '$FFFF00', '$FF00FF'];
  va := ['$0000FF', '$00FF00', '$FF0000'];
  Chr := '_';
  st := '';
  for i := 0 to lbl_Status.Tag do
    st := st + va[i mod Length(va)] + Chr;  //Utf8Encode(9724)
  lbl_Status.ResetColors;
  lbl_Status.SetCaption(st);
  Application.ProcessMessages;
end;

function TForm_Adm_Installer.GetFileList: Boolean;
var
  s: string;
  dt1: TDateTime;
  i: Integer;
begin
  Result := False;
  dt1 := Sys.GetFileAge(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe');
  FileList := TDirectory.GetFiles(edt_SrcPath.Text, '*.pas'); // TSearchOption.soAllDirectories
  FileList := FileList + TDirectory.GetFiles(edt_SrcPath.Text, '*.dfm');
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
  if True or (mem_Users.Text = '') then begin
    {$R-}
    Result := CopyFile(
      pwidechar(edt_SrcPath.Text + '\' + cmb_Module.Text + '.exe'),
      pwidechar(edt_DstPath.Text + PATH_LAUNCHER_STORAGE + '\' + cmb_Module.Text + '.exe'), False
    );
    {$R+}
    if (Result) or (cmb_Module.Value = '0') then begin
      InInstall := False;
      dn := edt_DstPath.Text + '\Data\Src\' + cmb_Module.Text + '__' + edt_Version.Text + '__' + StringReplace(edt_DtCompiled.Text, ':', '.', [rfReplaceAll]);
      {$R-}
      ForceDirectories(dn);
      ForceDirectories(dn + '\BACKUP');
      for i := 0 to High(FileList) do begin
        Application.ProcessMessages;
        CopyFile(pwidechar(FileList[i]), pwidechar(dn + '\' + ExtractFileName(FileList[i])), False);
      end;
      CopyFile(pwidechar(Sys.GetWinTemp + '\' + cmb_Module.Text + '.exe'), pwidechar(dn + '\BACKUP\' + cmb_Module.Text + '.exe'), False);
      Sys.SaveTextToFile(dn + '\!.txt', DateTimeToStr(Now) + #13#10#13#10'������:'#13#10 + lbl_InstalledInfo.Caption + #13#10#13#10 + mem_Comment.Text);
      {$R+}
      lbl_Status.ResetColors;
      lbl_Status.SetCaption('$00AA00������!');
      if not Result then begin
        MyWarningMessage('������ "' + cmb_Module.Text + '" �� ��� ����������, ������ ��� ��������� �������� ��������� �������. �������� ���� ������ � ���������� ����������� ���� �������!');
        Result := True;
      end;
      Q.QExecSql(
        'insert into adm_install_log (id_module, compile_dt, ver, comm) values (:id_module$i, :compile_dt$s, :ver$s, :comm$s)',
        [Cth.GetcontrolValue(cmb_Module), Cth.GetcontrolValue(edt_DtCompiled), Cth.GetcontrolValue(edt_Version), Cth.GetcontrolValue(mem_Comment)]
      );
      Bt_Ok.Enabled := True;
      cmb_Module.Enabled := True;
      mem_Comment.Enabled := True;
      edt_SrcPath.Enabled := True;
      edt_DstPath.Enabled := True;
      Verify;
      ProgressBar1.Visible:= False;
      MyInfoMessage('������!');
      Exit;
    end;
  end;
end;

end.
