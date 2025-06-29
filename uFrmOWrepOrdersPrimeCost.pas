unit uFrmOWrepOrdersPrimeCost;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, DBCtrlsEh, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Mask, Vcl.ComCtrls, Vcl.ExtCtrls, uLabelColors, Math
  ;

type
  TFrmOWrepOrdersPrimeCost = class(TFrmBasicMdi)
    pnl_Main: TPanel;
    lbl_1: TLabel;
    lbl_2: TLabel;
    lbl_3: TLabel;
    nedt_1_R: TDBNumberEditEh;
    nedt_1_O: TDBNumberEditEh;
    nedt_1_I: TDBNumberEditEh;
    nedt_2_R: TDBNumberEditEh;
    nedt_2_O: TDBNumberEditEh;
    nedt_2_I: TDBNumberEditEh;
    nedt_3_R: TDBNumberEditEh;
    nedt_3_O: TDBNumberEditEh;
    nedt_3_I: TDBNumberEditEh;
    cmb_DtB: TDBComboBoxEh;
    cmb_DtE: TDBComboBoxEh;
    lbl_1_Caption: TLabel;
  private
    FDtB, FDtE: TDateTime;
    FInCalculateReport: Boolean;
    FReportCalculated: Boolean;
    function  Prepare: Boolean; override;
    procedure btnClick(Sender: TObject); override;
    procedure btnOkClick(Sender: TObject); override;
    procedure SetReportCaption;
    function  GetDateFromComboBox(st: string; LastDay: Boolean = False): TDateTime;
    procedure CalculateReport;
  public
  end;

var
  FrmOWrepOrdersPrimeCost: TFrmOWrepOrdersPrimeCost;

implementation

uses
  DateUtils,
  uSettings,
  uForms,
  uDBOra,
  uString,
  uData,
  uMessages,
  uLabelColors2
  ;


{$R *.dfm}

function  TFrmOWrepOrdersPrimeCost.Prepare: Boolean;
var
  i, j: Integer;
begin
  Caption := '����� �� ������������� �������';
  Mode := fNone;
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(pnlFrmClient, []);
  FOpt.DlgButtonsR:=[[mbtGo, True, True, 160, '������������ �����', '', 120]];
  FOpt.StatusBarMode:=stbmCustom;
  Cth.AlignControls(pnlFrmBtnsL, [], True, 2);
  FDtB := EncodeDate(2000, 1, 1);
  cmb_DtB.Items.Clear;
  cmb_DtE.Items.Clear;
  for i := 2024 to YearOf(Date) do
    for j := 1 to S.IIf(i = YearOf(Date), MonthOf(Date), 12) do begin
      cmb_DtB.Items.Insert(0, IntToStr(i) + ', ' + MonthsRu[j]);
      cmb_DtE.Items.Insert(0, IntToStr(i) + ', ' + MonthsRu[j]);
    end;
  if cmb_DtB.ItemIndex = -1 then
    cmb_DtB.ItemIndex := 0;
  if cmb_DtE.ItemIndex = -1 then
    cmb_DtE.ItemIndex := 0;
  FDtB := EncodeDate(2000, 1, 1);
  SetReportCaption;
  RefreshStatusBar('����� �� �����������', '', True);
  Result := True;
end;

procedure TFrmOWrepOrdersPrimeCost.btnOkClick(Sender: TObject);
begin
end;


procedure TFrmOWrepOrdersPrimeCost.btnClick(Sender: TObject);
begin
  if (cmb_DtB.ItemIndex = -1) or (cmb_DtE.ItemIndex = -1) or (cmb_DtE.ItemIndex > cmb_DtB.ItemIndex) then begin
    MyWarningMessage('������� ����� ������!');
    Exit;
  end;
  FDtB := GetDateFromComboBox(cmb_DtB.Value);
  FDtE := GetDateFromComboBox(cmb_DtE.Value, True);
  CalculateReport;
end;

procedure TFrmOWrepOrdersPrimeCost.SetReportCaption;
begin
  if FInCalculateReport then
    lbl_1_Caption.SetCaptionAr2(['$FF00FF', '   ����� �����������.'])
  else if not FReportCalculated then
    lbl_1_Caption.SetCaptionAr2(['$0000FF', '   ����� �� �����������!'])
  else
    lbl_1_Caption.SetCaptionAr2(['$000000', '   ����� �� ������ � ', '$FF0000', DateToStr(FDtB), '$000000', ' �� ', '$FF0000', DateToStr(FDtE)])
end;

function TFrmOWrepOrdersPrimeCost.GetDateFromComboBox(st: string; LastDay: Boolean = False): TDateTime;
//������� ���� �� �� ��������� ������ ���� 2024, ����
//���� LastDay �� ��������� ������ ������, ����� ������ ������
//���� ������ ������� ����, �� ������ ������� ����
var
  i: Integer;
begin
  Result := EncodeDate(2000, 1, 1);
  try
    i := 1;
    while Copy(st, 7) <> MonthsRu[i] do
      inc(i);
    Result := EncodeDate(StrToInt(Copy(st, 1, 4)), i, 1);
    if LastDay then
      Result := IncDay(IncMonth(Result, 1), -1);
    if Result > Date then
      Result := Date;
  except
    Exit;
  end;
end;

procedure TFrmOWrepOrdersPrimeCost.CalculateReport;
var
  i, j: Integer;
  va1, va2: TVarDynArray;
  e1: Extended;
begin
  FInCalculateReport := True;
  //FDtB := encodedate(2024, 06, 01);
  //FDtE := encodedate(2024, 06, 05);
  nedt_1_R.Value := null;
  nedt_1_O.Value := null;
  nedt_1_I.Value := null;
  nedt_2_R.Value := null;
  nedt_2_O.Value := null;
  nedt_2_I.Value := null;
  nedt_3_R.Value := null;
  nedt_3_O.Value := null;
  nedt_3_I.Value := null;
  Q.QSetContextValue('order_finreport_dtbeg', FDtB);
  Q.QSetContextValue('order_finreport_dtend', FDtE);

  //Bt_Cancel.Enabled := False;
  //Bt_Ok.Enabled := False;

  SetReportCaption;

  //�������, ������� �� ��������� ����
  //�������, �� ��������� � � �
  RefreshStatusBar(' $000000������������ ������: $FF0000������ �� �������� (�������)', '$0000FF�����!  ', True);
  nedt_1_R.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_order_items where (id_order > 0) and (ornum like ''�%'' or ornum like ''�%'') and (dt_beg >= :FDtB$d) and (dt_beg <= :FDtE$d)', [FDtB, FDtE]);
  if Length(va1) > 0 then
    nedt_1_R.Value := S.NNum(va1[0]);
  //���, �� ��������� � � �
  RefreshStatusBar(' $000000������������ ������: $FF0000������ �� �������� (���)', '$0000FF�����!  ', True);
  nedt_1_O.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (ornum like ''�%'' or ornum like ''�%'') and (dt_beg >= :FDtB$d) and (dt_beg <= :FDtE$d)', [FDtB, FDtE]);
  if Length(va1) > 0 then
    nedt_1_O.Value := S.NNum(va1[0]);
  nedt_1_I.Value := nedt_1_R.Value + nedt_1_O.Value;

  //��������, ������� �� ���� �������� � ���
  RefreshStatusBar(' $000000������������ ������: $FF0000������ �� �������� (�������)', '$0000FF�����!  ', True);
  nedt_2_R.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''�'',''�'')) and (dt_from_sgp >= :FDtB$d) and (dt_from_sgp <= :FDtE$d)', [FDtB, FDtE]);
  if Length(va1) > 0 then
    nedt_2_R.Value := S.NNum(va1[0]);
  RefreshStatusBar(' $000000������������ ������: $FF0000������ �� �������� (���)', '$0000FF�����!  ', True);
  nedt_2_O.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''�'',''�'')) and (dt_from_sgp >= :FDtB$d) and (dt_from_sgp <= :FDtE$d)', [FDtB, FDtE]);
  if Length(va1) > 0 then
    nedt_2_O.Value := S.NNum(va1[0]);
  nedt_2_I.Value := nedt_2_R.Value + nedt_2_O.Value;

  //����������, ������� �� ���� �������� ������
  RefreshStatusBar(' $000000������������ ������: $FF0000������ �� ���������� (�������)', '$0000FF�����!  ', True);
  nedt_3_R.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''�'',''�'')) and (dt_end >= :FDtB$d) and (dt_end <= :FDtE$d)', [FDtB, FDtE]);
  if Length(va1) > 0 then
    nedt_3_R.Value := S.NNum(va1[0]);
  RefreshStatusBar(' $000000������������ ������: $FF0000������ �� ���������� (���)', '$0000FF�����!  ', True);
  nedt_3_O.Value := 0;
  Application.ProcessMessages;
  va1 := Q.QLoadToVarDynArrayOneRow('select sum(sum0) from v_orders where (id > 0) and (prefix in (''�'',''�'')) and (dt_end >= :FDtB$d) and (dt_end <= :FDtE$d)', [FDtB, FDtE]);
  if Length(va1) > 0 then
    nedt_3_O.Value := S.NNum(va1[0]);
  nedt_3_I.Value := nedt_3_R.Value + nedt_3_O.Value;

  //Bt_Cancel.Enabled := True;
  //Bt_Ok.Enabled := True;
  FInCalculateReport := False;
  FReportCalculated := True;

  SetReportCaption;
  RefreshStatusBar('����� �����������', '', True);
end;





end.
