unit uFrmXWGridOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, EhLibVCL,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, ClipBrd, TypInfo,
  uLabelColors, uString, uData, uFrmBasicMdi, uFrDBGridEh
  ;

type
  TFrmXWGridOptions = class(TFrmBasicMdi)
    PLeft: TPanel;
    PRight: TPanel;
    PLefttTop: TPanel;
    PRightTop: TPanel;
    Frg1: TFrDBGridEh;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
  private
    FrDbGrid: TFrDBGridEh;
    Chb: TVarDynArray2;
    ChbsH: Integer;
    OwnerFormDoc: string;
    FrozenColumn: string;
    function  Prepare: Boolean; override;
    procedure SetCheckBoxes;
    procedure LoaDGridOptions;
    procedure BtOkClick(Sender: TObject); override;
    procedure BtClick(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); virtual;
//    procedure Frg1DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure SetLoadDefaultEnabled;
  public
  end;

var
  FrmXWGridOptions: TFrmXWGridOptions;

implementation

uses
  uForms,
  uMessages,
  uErrors,
  uSys,
  uDBOra,
  uWindows,
  uSettings,
  V_MDI,
  uFrmXWGridAdminOptions
  ;

const
  mydefFomHeight = 200;
  mydefRowHeight = 17;
  mydefGridMaxHeight = 800;
  mydefHeightAdd=40;


{$R *.dfm}

procedure TFrmXWGridOptions.SetLoadDefaultEnabled;
begin
//  Cth.SetButtonsAndPopupMenuCaptionEnabled([PDlgBtnR], 1000, null, Settings.IsDefaultFrDBGridEhSettingsExists(OwnerFormDoc, FrDbGrid), '');
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, 1000, null, Settings.IsDefaultFrDBGridEhSettingsExists(OwnerFormDoc, FrDbGrid), '');
end;

procedure TFrmXWGridOptions.SetCheckBoxes;
var
  sa: TStringDynArray;
  i: Integer;
  c: TControl;
begin
  chb := [
    ['FilterPanel',
     '������ �������',
     myogPanelFilter,
    '���� �����������, ��� �������� ������������ ������ �������.'+chr(10)+chr(13)+
    '��� ����� � ��� ������, � ������� ������������ ������ ������, ���������� ���� �����.'+chr(10)+chr(13)+
    '������ �� ������ ����� ��������� ������, ����������� ������ ��������� ������� (��������, ����� ������ �� �������� �������)'+chr(10)+chr(13)+
    '������������� ������� ����� ������!'+chr(10)+chr(13)
    ],
    ['SearchPanel',
     '������ ������',
     myogPanelFind,
    '���� �����������, ��� �������� ������������ ������ ������.'+chr(10)+chr(13)+
    '��� ����� � ��� ������, � ������� �������������� ����������� ������.'+chr(10)+chr(13)+
    '���� ����� �� ��������� � ������� ������ �������, �������� ���-�� ����.'+chr(10)+chr(13)+
    '������, ������� ����� �������� � ������� �� Ctrl-F'+chr(10)+chr(13)
    ],
    ['STFilter',
     '������ � �������',
     myogColumnfilter,
    '�������� ������ � ���������� ��������.'+chr(10)+chr(13)+
    '���� ������ ����� ����� �� ���������� Exel.'+chr(10)+chr(13)+
    '�� ������ ����������� ������� �� ���������� ��������.'+chr(10)+chr(13)
    ],
    ['Sorting',
     '����������',
     myogSorting,
    '���������� �������.'+chr(10)+chr(13)+
    '��������� ����������� ������� �� ��������� ������ � ������� ������ �� ��������� �������.'+chr(10)+chr(13)+
    '�������� ���������� ����� �� ���������� ��������, ��� ����� �������� �� � ������ ������� ������ �� ����������,'+chr(10)+chr(13)+
    '  ��������� ������� Ctrl/'+chr(10)+chr(13)+
    '����������� �������� ��� �����!'+chr(10)+chr(13)
    ],
    ['AutoHeight',
     '���������� ������ �����',
    myogAutoFitRoWHeight,
    '���� ����� ��������, �� ������ ������� ����� ������������� � ������ ���, ����� � ����� ��������� � ������ �������.'+chr(10)+chr(13)+
    '��� ���� ����� � ������ ����������� �� ������. ������, ���������� � ����� ������, ���� �������� � ������� ������� ������ � ���� ����.'+chr(10)+chr(13)
    ],
    ['AutoWidth',
     '���������� ������ ��������',
    myogAutoFitColWidths,
    '���� ����� �����������, ������� �������� ������� ����������� ������ ��������'+chr(10)+chr(13)+
    '(��� ��� ��������, � ������� ����������� ������� ��������� ������ � ������� ������ � ���� ����).'+chr(10)+chr(13)
    ],
    ['SaveFilter',
     '��������� ������ � ��������',
    myogSaveFilter,
    '���� ����� �����������, ������ � �������� ����������� ��� �������� ��������� � ����������������� ��� ��������� ��������'+chr(10)+chr(13)+
    '(���� ����� ����������� ���������).'+chr(10)+chr(13)
    ],
    ['SavePosWhenSorting',
     '��������� ������� ��� ����������',
    myogSavePosWhenSorting,
    '���� ����� �����������, �� ��� ���������� ����������� ������� ������ � ������� (��������, �������� ��������� ������ � ��� �� ������� ������).'+chr(10)+chr(13)+
    '� ��������� ������, ��� ���������� ���������� ������� � ������ ������ �������.'+chr(10)+chr(13)
    ]
  ];
  for i:= 0 to High(chb) do begin
    c:=Cth.CreateControls(PLeft, cntCheck, chb[i][1], 'Chb' + chb[i][0], '', 0);
    c.Left := 4;
    c.Width := 180;
    c.Top := PLefttTop.Height + 4 + i * MY_FORMPRM_CONTROL_H;
    c := TImage.Create(Self);
    c.Name := 'Img' + chb[i][0];
    c.Parent := PLeft;
    c.Left := 194;
    c.Top := PLefttTop.Height + 4 + i * MY_FORMPRM_CONTROL_H;
    ChbsH := c.Top;
    Cth.SetInfoIcon(TImage(c), Cth.SetInfoIconText(TForm(Self), [[chb[i][3]]]), MY_FORMPRM_CONTROL_H);
  end;
//  PRight.Width := 4 + MY_FORMPRM_CONTROL_H + 4;
  c := TImage.Create(Self);
  c.Parent := PRightTop;
  c.Top := 2;
  c.Left := Label2.Width + 4 + 4; //PRightTop.Width - MY_FORMPRM_CONTROL_H - 4;
  c.Name := 'ImgGrid';
  Cth.SetInfoIcon(TImage(c), Cth.SetInfoIconText(TForm(Self),
    [[
    '������ �������� �������.'#13#10+
    '������� ������:'#13#10+
    '- ��������� �������.'#13#10+
    '- ����� �� ����� � ������ ������� ������������ �� ������ (���� ������� ���������� ������ �����)'#13#10+
    '- ����� �� ������� ����������� �� ������ � ����������� �� ������ ������� (���� ������� ���������� ������ ��������)'#13#10+
    '����� �� ������ ��������� ������� � ����� ����� ������� �� ����� ������ ������� �����'#13#10+
    '(��� ����� ���� ������, ���� � ������� ����� ������� � ��� �� ��������� �� �����)'#13#10
//    ''#13#10+
    ]]
  ), MY_FORMPRM_CONTROL_H);
end;


procedure TFrmXWGridOptions.LoaDGridOptions;
var
  sa: TStringDynArray;
  va2: TVarDynArray2;
  c: TDBCheckBoxEh;
  i: Integer;
begin
  va2 := [];
  //��������� ������ �� �������, ������� ������������ ����� ����� ������
  //� �������, � ������� ��� ��������� ������ � �����
  //(�� ��������� � _, �� ����, � �� �������
  for i:=0 to FrDbGrid.DBGridEh1.Columns.Count-1 do
    begin
//      if (Pos('_', FrDbGrid.DBGridEh1.Columns[i].Title.Caption) = 1) then Continue;
      if FrDbGrid.Opt.Sql.Fields[i].Invisible or FrDbGrid.Opt.Sql.Fields[i].FIsNull or (Pos('_', FrDbGrid.Opt.Sql.Fields[i].Caption) = 1) then
        Continue;
      va2 := va2 + [[
        i,
        FrDbGrid.DBGridEh1.Columns[i].FieldName,
        FrDbGrid.DBGridEh1.Columns[i].Title.Caption,
        S.IIf(FrDbGrid.DBGridEh1.Columns[i].Visible, 1, 0),
        S.IIf(FrDbGrid.DBGridEh1.Columns[i].WordWrap, 1, 0),
        S.IIf(FrDbGrid.DBGridEh1.Columns[i].AutoFitColWidth, 1, 0)
      ]];
    end;
  Frg1.LoadSourceDataFromArray(va2);
  for i := 0 to High(Chb) do
    if Chb[i][2] <> - 1 then begin
      c := TDBCheckBoxEh(Self.FindComponent('Chb' + Chb[i][0]));
      c.Checked := TFrDBGridOption(Chb[i][2]) in FrDbGrid.Options;
    end;
  FrozenColumn := FrDbGrid.Opt.FrozenColumn;
  Frg1.MemTableEh1.First;
  Frg1.OnColumnsUpdateData := Frg1ColumnsUpdateData;
  Frg1.OnButtonClick := Frg1ButtonClick;
  Frg1.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;
end;

procedure TFrmXWGridOptions.FormShow(Sender: TObject);
begin
  inherited;
  SetLoadDefaultEnabled;
  PDlgBtnForm.Width := PDlgBtnForm.Width + 4 + MY_FORMPRM_CONTROL_H + 4;
end;

procedure TFrmXWGridOptions.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Frg1.SetValue('', Value);
  handled := True;
end;

procedure TFrmXWGridOptions.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  inherited;
  if FrozenColumn = Fr.GetValue('field') then
    Params.Background := clSkyBlue;
end;


procedure TFrmXWGridOptions.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if FrozenColumn = Fr.GetValue('field')
    then FrozenColumn := ''
    else FrozenColumn := Fr.GetValue('field');
end;

procedure TFrmXWGridOptions.ControlOnChange(Sender: TObject);
begin
  if (TControl(Sender).Name = 'ChbFilterPanel') and TDBCheckBoxEh(Sender).Checked then
    TDBCheckBoxEh(FindComponent('ChbSearchPanel')).Checked := False;
  if (TControl(Sender).Name = 'ChbSearchPanel') and TDBCheckBoxEh(Sender).Checked then
    TDBCheckBoxEh(FindComponent('ChbFilterPanel')).Checked := False;
end;

procedure TFrmXWGridOptions.BtClick(Sender: TObject);
begin
  if TButton(Sender).Tag = 1001 then begin
    //to Default
    if OwnerFormDoc <> '' then
      Settings.WriteFrDBGridEhSettings(OwnerFormDoc, FrDbGrid, True);
    SetLoadDefaultEnabled;
  end;
  if TButton(Sender).Tag = 1002 then begin
    FrmXWGridAdminOptions.ShowDialog(FrDbGrid);
  end;
  if TButton(Sender).Tag = 1000 then begin
    //�� ���������
    if MyQuestionMessage('���������� ��� ������� ��� �� ���������?') <> mrYes then
      Exit;
    if OwnerFormDoc <> '' then
      Settings.RestoreFrDBGridEhSettings(OwnerFormDoc, FrDbGrid, True);
    MyInfoMessage('��� �� ��������� ����������!');
  end;
end;

procedure TFrmXWGridOptions.BtOkClick(Sender: TObject);
var
  c: TDBCheckBoxEh;
  i, j: Integer;
  st: string;
begin
  for i:=0 to Frg1.GetCount - 1 do
    begin
    st := Frg1.GetValue('field', i);
    j := Frg1.GetValue('visible', i);
//    FrDbGrid.DBGridEh1.FindFieldColumn(st).Visible := Frg1.GetValue('visible', i) = 1;
    FrDbGrid.Opt.SetFieldVisible(st, Frg1.GetValue('visible', i) = 1);
    FrDbGrid.DBGridEh1.FindFieldColumn(st).WordWrap := Frg1.GetValue('wordwrap', i) = 1;
    FrDbGrid.DBGridEh1.FindFieldColumn(st).AutoFitColWidth := Frg1.GetValue('autofit', i) = 1;
    end;
  for i := 0 to High(Chb) do
    if Chb[i][2] <> - 1 then begin
      c := TDBCheckBoxEh(Self.FindComponent('Chb' + Chb[i][0]));
      if c.Checked
        then FrDbGrid.Options := FrDbGrid.Options + [TFrDBGridOption(Chb[i][2])]
        else FrDbGrid.Options := FrDbGrid.Options - [TFrDBGridOption(Chb[i][2])];
    end;
  FrDbGrid.Opt.FrozenColumn := FrozenColumn;
  FrDbGrid.SetColumnsVisible;
  inherited;
end;


function TFrmXWGridOptions.Prepare: Boolean;
var
  i, j: Integer;
  va2: TVarDynArray;
begin
  Result := False;
  Mode := FEdit;
  Caption := '~��������� ���� �������';
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(PMDIClient, []);
  if User.IsDeveloper then
    FOpt.DlgButtonsL:=[[1001, User.IsDeveloper, True, 100, 'To default', 'to_settings'],[1002, User.IsDeveloper, True, 100, 'Admin', 'settings_spanner']];                                //'settings_spanner'
  FOpt.DlgButtonsR:=[[1000, True, True, 120, '�� ���������', 'settings_def'], [btnDividor, True], [btnSpace, True, 1]];
  FOpt.StatusBarMode:=stbmNone;

  OwnerFormDoc := '';
  if ParentForm is TFrmBasicMdi
    then OwnerFormDoc:= TFrmBasicMdi(ParentForm).FormDoc
    else if ParentForm is TForm_MDI
      then OwnerFormDoc:= TForm_MDI(ParentForm).FormDoc;

  FrDbGrid := TFrDBGridEh(ParentControl);

  Frg1.Options:=[myogIndicatorColumn, myogColoredTitle, myogHiglightEditableColumns, myogHiglightEditableCells];
  Frg1.Opt.SetDataMode(myogdmFromArray);
  Frg1.Opt.SetFields([
    ['num$i', '_N', '20'],
    ['field$s', '_����', '100'],
    ['name$s', '�������', '200;W'],
    ['visible$s', '��������', '70', 'chb', 'e'],
    ['wordwrap$s', '���������� �� ������', '70', 'chb', 'e'],
    ['autofit$s', '��������� ������', '70', 'chb', 'e']
  ]);
  Frg1.Opt.SetButtons(1, [[-1000, True, '��������� �������']]);
  Frg1.Prepare;

  SetCheckBoxes;
  LoaDGridOptions;

  i:=Min(Frg1.DBGridEh1.RowCount * mydefRowHeight + 35, mydefGridMaxHeight);
  FWHCorrected.Y:=Max(ChbsH + 4 + MY_FORMPRM_CONTROL_H, i + Frg1.Top{ + PDlgPanel.Height + 10});
  FWHCorrected.X:= 800;
  FWHBounds.X:= 800;
  FWHBounds.X2:= -1;
  FWHBounds.Y:= FWHCorrected.Y + 70 + 36;

  FOpt.InfoArray:=[[
  '��������� ������� ��� � ���������� �������.'#13#10+
  '��� ��������� ���������� ��� ����������� ���������.'#13#10
  ]];

  Result := True;
end;


end.
