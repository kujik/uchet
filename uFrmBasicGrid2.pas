unit uFrmBasicGrid2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh
  ;

type
  TFrmBasicGrid2 = class(TFrmBasicMdi)
    PTop: TPanel;
    PBottom: TPanel;
    PLeft: TPanel;
    PGrid1: TPanel;
    Frg1: TFrDBGridEh;
    ImgTemp: TImage;
    Frg2: TFrDBGridEh;
    PFrg2: TPanel;
    PRight: TPanel;
    {����������� �������, ������������ � ������ ������. � �������� ������ ���� ����������� � ���� �� ������}
    //� ���� ������� � �������� ������������ ����� � ��� �����; � �������� ����������� �������� inherited
    procedure Frg1DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState); virtual;
    procedure Frg2DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState); virtual;
    procedure Timer_AfterStartTimer(Sender: TObject);
  private
    procedure FrgSetEvents(AFrg: TFrDBGridEh);
  protected
    //�������� ������� �����
    function  Prepare: Boolean; override;
    function  PrepareForm: Boolean; virtual;

    //������� ������� (���������) ������ �����
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); virtual;
    function  Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; virtual;
    //����� ������������� ���������� where-����� ������� � �������������� ��������� � �������
    //(���������� ������, ������ ��� ��� ��������������� �������, ����� ������������ ��������� � ��� �������� �������, ������ �� ��������� ������ � ������ ��������
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); virtual;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); virtual;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); virtual;
    //����� ������ ������������� ��������� ������ (����� ��������, readonly) � ����������� �� ������ � ������� ������
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); virtual;
    //������� ���� � �������
    //�� ��������� �������� �������������� ��� �������� ������
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); virtual;
    //dbgvBefore - ����� ��������� ��������� �������� ��� ������� ��������� �� ������
    //dbgvCell - ����� ������ ���������� �������� � ���������� ������, ���������� ��������������� ������ � �������� � 1
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); virtual;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); virtual;


    //������� ������� (� rorowDetailPanel) ������ �����
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); virtual;
    function  Frg2OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; virtual;
    //����� ������������� ���������� where-����� ������� � �������������� ��������� � �������
    //(���������� ������, ������ ��� ��� ��������������� �������, ����� ������������ ��������� � ��� �������� �������, ������ �� ��������� ������ � ������ ��������
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); virtual;
    procedure Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); virtual;
    procedure Frg2AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); virtual;
    //����� ������ ������������� ��������� ������ (����� ��������, readonly) � ����������� �� ������ � ������� ������
    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); virtual;
    //������� ���� � �������
    //�� ��������� �������� �������������� ��� �������� ������
    procedure Frg2OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); virtual;
    procedure Frg2VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); virtual;
    procedure Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); virtual;
  public
  end;

var
  FrmBasicGrid2: TFrmBasicGrid2;

  bbb:Boolean;

implementation

uses
  uFrmMain,
  uSys,
  uTasks,
  uErrors,
  uLabelColors2,
  uWindows,
  uFrmXWGridAdminOptions
  ;


{$R *.dfm}


function TFrmBasicGrid2.PrepareForm: Boolean;
begin
  if Length(Frg1.Opt.Sql.FieldsDef) = 0 then begin
    MyWarningMessage('������! FormDoc �� ������ ��� �������� ���� �� �����!');
    Exit;
  end;
  if Length(Frg2.Opt.Sql.FieldsDef) > 0 then
    Frg2.Prepare;
  Frg1.Grid2 := Frg2;
  Frg1.Prepare;
  Frg1.RefreshGrid;
  Result := True;
end;


procedure TFrmBasicGrid2.Timer_AfterStartTimer(Sender: TObject);
begin
  inherited;
end;

{=========================  ������� ������� ����� =============================}

procedure TFrmBasicGrid2.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

function  TFrmBasicGrid2.Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string;
begin
end;

procedure TFrmBasicGrid2.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
end;

procedure TFrmBasicGrid2.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
end;

procedure TFrmBasicGrid2.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
end;

procedure TFrmBasicGrid2.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
end;

procedure TFrmBasicGrid2.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
begin
  inherited;
  Frg1.DbGridEh1GetCellParams(Sender, Column, AFont, Background, State);
end;


{=========================  ������� ������� ����� =============================}

procedure TFrmBasicGrid2.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

function  TFrmBasicGrid2.Frg2OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string;
begin
end;

procedure TFrmBasicGrid2.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
end;

procedure TFrmBasicGrid2.Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
begin
  Frg2.DbGridEh1GetCellParams(Sender, Column, AFont, Background, State);
end;

procedure TFrmBasicGrid2.Frg2AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
end;

procedure TFrmBasicGrid2.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
end;

procedure TFrmBasicGrid2.Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
end;

procedure TFrmBasicGrid2.Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
end;



{==============================================================================}

procedure TFrmBasicGrid2.FrgSetEvents(AFrg: TFrDBGridEh);
//��������� ������� ����������� ������
begin
  AFrg.Options:= FrDBGridOptionDef + FrDBGridOptionRefDef;
  AFrg.Opt.SetDataMode;

  Frg1.Opt.SetPanelsSaved(['*']);

  if AFrg = Frg1 then begin
    AFrg.OnButtonClick := Frg1ButtonClick;
    AFrg.OnCellButtonClick := Frg1CellButtonClick;
    AFrg.OnSelectedDataChange := Frg1SelectedDataChange;
    AFrg.OnSetSqlParams := Frg1OnSetSqlParams;
    AFrg.OnColumnsUpdateData := Frg1ColumnsUpdateData;
    AFrg.OnAddControlChange := Frg1AddControlChange;
    AFrg.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;
    AFrg.OnDbClick := Frg1OnDbClick;
    AFrg.OnGetCellReadOnly := Frg1GetCellReadOnly;
    AFrg.OnVeryfyAndCorrectValues := Frg1VeryfyAndCorrect;
    AFrg.OnCellValueSave := Frg1CellValueSave;
  end;

  if AFrg = Frg2 then begin
    AFrg.OnButtonClick := Frg2ButtonClick;
    AFrg.OnCellButtonClick := Frg2CellButtonClick;
    AFrg.OnSelectedDataChange := Frg2SelectedDataChange;
    AFrg.OnSetSqlParams := Frg2OnSetSqlParams;
    AFrg.OnColumnsUpdateData := Frg2ColumnsUpdateData;
    AFrg.OnAddControlChange := Frg2AddControlChange;
    AFrg.OnColumnsGetCellParams := Frg2ColumnsGetCellParams;
    AFrg.OnDbClick := Frg2OnDbClick;
    AFrg.OnGetCellReadOnly := Frg2GetCellReadOnly;
    AFrg.OnVeryfyAndCorrectValues := Frg2VeryfyAndCorrect;
    AFrg.OnCellValueSave := Frg2CellValueSave;
  end;
end;

function TFrmBasicGrid2.Prepare: Boolean;
var
  c: TControl;
begin
  Result := False;
  try
  Cth.MakePanelsFlat(PMDIClient, []);
  if PTop.Height < 10 then PTop.Visible := False;
  if PBottom.Height < 10 then PBottom.Visible := False;
  if PLeft.Width < 10 then PLeft.Visible := False;
  if PRight.Width < 10 then PRight.Visible := False;
  PFrg2.Visible := False;

  FrgSetEvents(Frg1);
  FrgSetEvents(Frg2);

  if not PrepareForm then Exit;

  FWHBounds.X := PLeft.Width + Frg1.PTop.Width + 60;
  FWHBounds.Y := 300;
  Result := True;
  except on E: Exception do begin
    Errors.SetErrorCapt(Self.Name, '������ ��� ��������� FormDoc = ' + FormDoc);
    Application.ShowException(E);
    Errors.SetErrorCapt;
    Cth.SetWaitCursor(False);
    Result := False;
    end;
  end;
end;



end.

(*

    Caption:='�������� ������';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    //����, ��� ������ � ������������� ����� ��������� 'id', ��� �������� �� ������� ����������� 'id$i'
    va2 := [
      ['id','_id'],['id_template','_id_template'],['dt','���� ��������','80'],['num','�'],['dt_start','������ ��������','80'],['dt_end','��������� ��������','80'],
      ['dt_change','���� ���������'],['std','���','40','pic'],['templatename','������','200'],['projectname','������','200'],['sum_all','�����','100','f=r:']
    ];
    //������� �����������
    for i := 1 to 1 do
      va2 := va2 + [['sum'+IntToStr(i), MonthsRu[i], '100','f=r:','t=1']];
    //��������� ����, ��� ��������� ������ ����� �����!!!
    Frg1.Opt.SetFields(va2);
    //�������, ������ ����� ���, �� ����� �������� � ������� � ���� ����
    Frg1.Opt.SetTable('v_planned_orders_w_sum');
    //������, � ������������ �����. ���� ���� ��� ��������, ����������� ������� btnCtlPanel, �� ����� �� ��������� ���������� ��� ��������
    Frg1.Opt.SetButtons(1,[
      [btnRefresh],[],[btnView],[btnEdit,User.Role(rOr_J_PlannedOrders_Ch)],[btnCustom_OrderFromTemplate,1],[btnDelete,1],[],[btnGridFilter],[],[btnGridSettings],[btnCtlPanel{, True, 140}]
    ]);
    //���, ���� �� �� ���� ������������� ������, ����� ������� ���, ������ �� ������ ������, �������, ���������/��������������,������,���������,
    //������, ����� ����� �� ��� ����������� � ��������� ��������, � ���� ��� ����� ��������������, �� ��������� ����
     //Frg1.Opt.SetButtons(1, 'rveacdfsp'? ARight);
    Frg1.Opt.SetButtonsIfEmpty([btnCustom_OrderFromTemplate]);
    //������� ��������
    Frg1.CreateAddControls('1', cntCheck, '�� �������', 'ChbMonthsSum', '', 4, yrefC, 130);
    //���� ���� ���� ���������� �������� �����, �� ����������, ����� ���������� �� ��������, � ������� ��������� ��������� �����
    //� ������� ������� ����� �� ������, �������� ����������� � Frg1.Prepare, ����� �������� ��������, ����� ���� ��������� ������� �� ���������
    //(���� ���� �������� ���������� � ����������), ��� ����������� ������
    //(���� ���������� Fr.InPrepare � � ���� ������ �������� �� ������ Refresh ��� SelcolumnsVisible
    Frg1.ReadControlValues;
    if not (User.Role(rOr_J_Orders_Sum)or(User.Role(rOr_J_Orders_PrimeCost))) then begin
      Cth.SetControlValue(TDBCheckBoxEh(Frg1.FindComponent('ChbViewSum')), 0);
      Frg2.Opt.SetColFeature('1', 'null', True, False);
    end;
    Frg2.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);
    //������ (help, ���� ��� ���� �� ����, �������� � �������
    Frg1.Opt.FilterRules := [[], ['dt;dt_start;dt_end;dt_change']];
    //Frg1.Opt.FilterRules := [[], ['dt_beg;dt_otgr;dt_end'], ['�������� �������������', 'Sum0', User.Role(rOr_J_Orders_Sum)]];
    //��������� � ������ ������ ������
    Frg1.InfoArray:=[
      [Caption + '.'#13#10]
    ];

{    FOpt.StatusBarMode := stbmDialog;
    FOpt.DlgPanelStyle := dpsBottomRight;
    Frg1.Opt.SetButtons(1, [[btnAdd]], 4, PDlgBtnR);
    FMode := fView;}

      //��������, � ������ ����� ":"
      //1 - �������� �����, ����� ����� � �������
      //2 - ��������������� �� ������� ��������
      //3 - ���� +, �� ����������� � �����
      //���� ������ �� ������, �� ����� ����� ��� �������� "1", ���� ����� ������ ���� ��������, �� ����� ����� ��� ����


  //��� ���������� ��������� � �������, ������� onChange �� ����������!
  //�������� � ����� -1..-10 ���������� ��� ������������, � -11..-20 ��� ��, �� � ������������ ������

*)


