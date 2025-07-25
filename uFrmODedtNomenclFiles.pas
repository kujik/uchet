(*
������������ ������ (������� � ��������� ������) � ������� ������ ������������.
(� ������������ � ����������� �������� ������ � ���������� �����).

�������� �������������� ������.

��� �������������� ������ ������ ����������� ���� �� ������� ������.
��� ��������� ����� ����������� ������. ����������� �������, ����� ���� ����������� ���
�������, ���� �� ����, �� ������ ��� �� �����.

����� ����� ���������� �� ��������� �� ������ � ������, ���������� ���������� ��.

����������� ����� � ������� ������ ����� (� �������� ��������) - ���������� ��,
��� ������ ���������� ��������.
*)

unit uFrmODedtNomenclFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, ClipBrd,
  uLabelColors, uFrmBasicMdi, uFrDBGridEh
  ;

type
  TFrmODedtNomenclFiles = class(TFrmBasicMdi)
    pnlNomencl: TPanel;
    lblNomencl: TLabel;
    OpenDialog1: TOpenDialog;
    pnlGrid: TPanel;
    Frg1: TFrDBGridEh;
    procedure Frg1DbGridEh1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FPath: string;
    FQntFiles: Integer;
    function  Prepare: Boolean; override;
    procedure btnClick(Sender: TObject); override;
    procedure GetExistFiles;
  public
    class procedure ShowDialog(AOwner: TComponent; AID: Variant);
  end;

var
  FrmODedtNomenclFiles: TFrmODedtNomenclFiles;

implementation

{$R *.dfm}

uses
  uString,
  uForms,
  uMessages,
  uData,
  uErrors,
  uSys,
  uDBOra,
  uWindows
  ;


class procedure TFrmODedtNomenclFiles.ShowDialog(AOwner: TComponent; AID: Variant);
var
  F: TForm;
begin
  F:= Create(AOwner, myfrm_Dlg_NomenclFiles, [myfoDialog, myfoSizeable], fNone, AID, null, []);
  AfterFormClose(F);
end;


procedure TFrmODedtNomenclFiles.btnClick(Sender: TObject);
//��������� ������� ������ (����� �������� ������ �������)
var
  i: Integer;
  st: string;
  State : TKeyboardState;
  b: Boolean;
begin
  if TControl(Sender).Tag = mbtAdd then begin
    try
      OpenDialog1.Options:=[ofAllowMultiSelect, ofFileMustExist];
      if not OpenDialog1.Execute then Exit;
      st := Module.GetPath_Nomencl_Drawings(ID);
      ForceDirectories(st);
      FPath := st;
      for i:=0 to OpenDialog1.Files.Count-1 do
        if FileExists(OpenDialog1.Files[i])
          then CopyFile(PChar(OpenDialog1.Files[i]), PChar(FPath + '\' + ExtractFileName(OpenDialog1.Files[i])), False)  //False - �������������� ����, True - ����� ������ ���� ����������
          else myMessageDlg('���� �� ������!', mtWarning, [mbOk]);
    finally
      GetExistFiles;
    end;
  end;
  if TControl(Sender).Tag = mbtDelete then begin
    try
      if (Frg1.RecNo = 0) or (MyQuestionMessage('������� ����'#13#10'"' + Frg1.GetValue + '"'#13#10'?') <> mrYes)
        then Exit;
      DeleteFile(FPath + '\' + Frg1.GetValue);
    finally
      GetExistFiles;
    end;
  end;
  if TControl(Sender).Tag = 1000 then begin
    try
      GetKeyboardState(State);
      if (State[vk_Control] and 128) <> 0 then begin
        st := '';
        for i := 0 to Frg1.GetCount - 1 do
          S.ConcatStP(st, '"' +  FPath + '\' + Frg1.GetValue('name', i) + '"', ' ');
        Clipboard.AsText := st;
      end
      else if (State[vk_Shift] and 128) <> 0
        then Sys.CopyFilesToClipboard(FPath + '\' + Frg1.GetValue)
        else Clipboard.AsText := '"' + FPath + '\' + Frg1.GetValue + '"';
    finally
    end;
  end;
end;

procedure TFrmODedtNomenclFiles.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ((FQntFiles = 0) and (Frg1.RecordCount > 0)) or ((FQntFiles > 0) and (Frg1.RecordCount = 0)) then begin
    Q.QCallStoredProc('p_SetSplDemandValue', 'id$i;op$i;v$i', [ID, 8, Min(Frg1.RecordCount, 1)]);
    RefreshParentForm;
  end;
  inherited;
end;

procedure TFrmODedtNomenclFiles.Frg1DbGridEh1DblClick(Sender: TObject);
begin
  try
  Sys.ExecFile(FPath + '\' + Frg1.GetValueS);
  finally
  end;
end;

procedure TFrmODedtNomenclFiles.GetExistFiles;
var
  sa: TStringDynArray;
  va2: TVarDynArray2;
  i: Integer;
begin
  sa:= Sys.GetFileInDirectoryOnly(FPath);
  va2:=[];
  for i := 0 to High(sa) do
    va2 := va2 + [[ExtractFileName(sa[i]), DateTimeToStr(FileDateToDateTime(FileAge(sa[i])))]];
  Frg1.LoadSourceDataFromArray(va2);
end;


function  TFrmODedtNomenclFiles.Prepare: Boolean;
begin
  Result := False;
  if User.Role(rOr_R_ITM_Nomencl_AttachFiles)
    then Mode := fNone
    else Mode := fView;
//    FMode := fNone;
//FMode := fView;
  Caption := '~����� � ������������';
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(pnlFrmClient, []);
//  if FMode = fNone then
    FOpt.DlgButtonsR:=[[mbtAdd, Mode = fNone], [mbtDelete, 1], [mbtDividor], [1000, '� �����'], [mbtDividor, True], [mbtSpace, True, 1]];
 // FOpt.DlgButtonsR:= FOpt.DlgButtonsR + [[mbtDividor],[1000, '� �����']];
  FOpt.StatusBarMode:=stbmNone;
  lblNomencl.Caption := S.NSt(Q.QSelectOneRow('select name from dv.nomenclatura where id_nomencl = :id$i', [ID])[0]);
  Cth.AlignControls(pnlNomencl, [], True, 2);
  //�������� ����� ����
  Frg1.Options:=[myogIndicatorColumn, myogColoredTitle, myogHiglightEditableCells, myogHiglightEditableColumns{, myogMultiSelect, myogIndicatorCheckBoxes}];
  Frg1.Opt.SetDataMode(myogdmFromArray);
  Frg1.Opt.SetFields([['name$s', '������������ �����', '300;W'], ['dt$s', '���� �����', '120']]);
//  Frg1.Opt.S(gotAllowedOperations, [alopUpdateEh]);
  //���������� ����� �����
  Frg1.Prepare;
  Frg1.DbGridEh1.FindFieldColumn('name').TextEditing := False;
//Frg1.DBGridEh1.IndicatorOptions := Frg1.DBGridEh1.IndicatorOptions + [gioShowRowSelCheckBoxesEh];
//Frg1.DBGridEh1.OptionsEh:=Frg1.DBGridEh1.OptionsEh - [dghClearSelection];
  if ID <> 0 then begin
    FPath := Module.GetPath_Nomencl_Drawings(ID);
    GetExistFiles;
  end;
  FQntFiles := Frg1.RecordCount;
  //����������� ������� ����� (������ ����, ������ ������������ ������� ������)
  FWHBounds.Y:= 200;
  //FWHBounds.X:=300;
  //���������
  FOpt.InfoArray:=[
    ['������������� ����� ��� ������������.'#13#10],
    [''#13#10+
     '����������� ������ "��������" ��� ������������ ������.'#13#10+
     '��� ���� ��������� ������ ������, ����� ������� ��������� ������ �����.'#13#10+
     '���� ���� � ����� �� ������� ��� �������� �����, �� �� ����� ���������.'#13#10+
     '��� �������� ����� ������� ������ "�������".'#13#10+
     '����� ����������� ����� ��, �� ����������, ���� ������� ���� ���������.'#13#10, Mode <> fView
    ],
    [''#13#10+
     '��� ��������� �����, ������ �������� �� ��� ������������.'#13#10
    ],
    ['������� ������ "� �����", ����� �������� ��� ���������� ����� � ����� ������ ,'#13#10+
     '(� ����� �������� � ������� ������������ �����, ��������, � �������� �������),'#13#10+
     '��� ��� �� ������, ����� ������� Ctrl, ����� ����������� ��� ����� ������,'#13#10+
     '��� ����� Shift, ����� ����������� ��� ���� (����� ��� ����� ����� �������� � ����������)'#13#10
    ]
  ];
  Result := True;
end;


end.
