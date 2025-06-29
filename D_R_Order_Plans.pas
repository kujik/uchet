unit D_R_Order_Plans;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Mask, DBCtrlsEh, Math, uString;

type
  TDlg_R_Order_Plans = class(TForm_Normal)
    Bt_Cancel: TBitBtn;
    Bt_Ok: TBitBtn;
    Img_Info: TImage;
    nedt_Sum1RI: TDBNumberEditEh;
    nedt_Sum1RA: TDBNumberEditEh;
    nedt_Sum1RD: TDBNumberEditEh;
    nedt_Sum1RM: TDBNumberEditEh;
    nedt_Sum1R_: TDBNumberEditEh;
    lbl11: TLabel;
    nedt_Sum1OI: TDBNumberEditEh;
    nedt_Sum1OA: TDBNumberEditEh;
    nedt_Sum1OD: TDBNumberEditEh;
    nedt_Sum1OM: TDBNumberEditEh;
    nedt_Sum1O_: TDBNumberEditEh;
    lbl1: TLabel;
    nedt_Sum2RI: TDBNumberEditEh;
    nedt_Sum2RA: TDBNumberEditEh;
    nedt_Sum2RD: TDBNumberEditEh;
    nedt_Sum2RM: TDBNumberEditEh;
    nedt_Sum2R_: TDBNumberEditEh;
    lbl2: TLabel;
    nedt_Sum2OI: TDBNumberEditEh;
    nedt_Sum2OA: TDBNumberEditEh;
    nedt_Sum2OD: TDBNumberEditEh;
    nedt_Sum2OM: TDBNumberEditEh;
    nedt_Sum2O_: TDBNumberEditEh;
    lbl3: TLabel;
    lbl_Caption: TLabel;
    lbl4: TLabel;
    nedt_Prc3i: TDBNumberEditEh;
    lbl5: TLabel;
    nedt_Sum3A: TDBNumberEditEh;
    nedt_Prc3A: TDBNumberEditEh;
    nedt_Sum3i: TDBNumberEditEh;
    procedure Bt_OkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ControlChange(Sender: TObject);
  private
    { Private declarations }
    DtB: TDateTime;
    IsEmpty: Boolean;
    Fields: TVarDynArray;
    function LoadData: Boolean;
    function SaveData: Boolean;
  public
    { Public declarations }
    procedure ShowDialog(ADt: TDateTime);
  end;

var
  Dlg_R_Order_Plans: TDlg_R_Order_Plans;

implementation

{$R *.dfm}

uses
  DateUtils,
  uSettings,
  uForms,
  uDBOra,
  uData,
  uMessages
  ;


procedure TDlg_R_Order_Plans.ShowDialog(ADt: TDateTime);
begin
  DtB:=EncodeDate(YearOf(ADt), MonthOf(ADt), 1);
  //if DtB < EncodeDate(2024, 01, 01) then Exit;
  lbl_Caption.Caption:=IntToStr(YearOf(DtB)) + ', ' + MonthsRu[MonthOf(DtB)];
  Fields:=[
    'dt$d',
    'sum1ri$i','sum1ra$i','sum1rd$i','sum1rm$i','sum1oi$i','sum1oa$i','sum1od$i','sum1om$i',
    'sum2ri$i','sum2ra$i','sum2rd$i','sum2rm$i','sum2oi$i','sum2oa$i','sum2od$i','sum2om$i',
    'sum3i$i','prc3i$f','sum3a$i','prc3a$f'
  ];
  Cth.SetDialogForm(Self, fNone, 'Справочник планов по заказам');
  Cth.SetControlsOnChange(Self, ControlChange);
  lbl_Caption.Top:=Bt_Ok.Top;
  if not LoadData then Exit;
  ShowModal;
end;

procedure TDlg_R_Order_Plans.ControlChange(Sender: TObject);
begin
  nedt_Sum1R_.Value:=nedt_Sum1RI.Value+nedt_Sum1RA.Value+nedt_Sum1RD.Value+nedt_Sum1RM.Value;
  nedt_Sum1O_.Value:=nedt_Sum1OI.Value+nedt_Sum1OA.Value+nedt_Sum1OD.Value+nedt_Sum1OM.Value;
  nedt_Sum2R_.Value:=nedt_Sum2RI.Value+nedt_Sum2RA.Value+nedt_Sum2RD.Value+nedt_Sum2RM.Value;
  nedt_Sum2O_.Value:=nedt_Sum2OI.Value+nedt_Sum2OA.Value+nedt_Sum2OD.Value+nedt_Sum2OM.Value;
end;


procedure TDlg_R_Order_Plans.Bt_OkClick(Sender: TObject);
begin
  inherited;
  ModalResult:=mrNone;
  if not SaveData then begin
    MyWarningMessage('Не удалось сохранить данные!');
    Exit;
  end;
  ModalResult:=mrOk;
end;

procedure TDlg_R_Order_Plans.FormActivate(Sender: TObject);
begin
  inherited;
  lbl_Caption.Top:=Bt_Ok.Top;
end;

function TDlg_R_Order_Plans.LoadData: Boolean;
var
  i,j:Integer;
  va1: TVarDynArray2;
  c: TComponent;
begin
  Result:=False;
  IsEmpty:=False;
  va1:=Q.QLoadToVarDynArray2(Q.QSIUDSql('s', 'order_plans', A.Implode(Fields, ';')), [DtB]);
  //'select ' + A.Implode(Fields, ', ') +' from order_plans where dt = :dt$d', DtB);
  if Length(va1) = 0 then begin
    IsEmpty:=True;
    SetLength(va1, 1);
    SetLength(va1[0], Length(Fields));
  end;
  for i:= 0 to High(va1[0]) do begin
    c:= Self.FindComponent('nedt_'+Copy(Fields[i], 1, Length(Fields[i]) - 2));
    if c <> nil
      then TDBNumberEditEh(c).Value:= va1[0][i];
  end;
  Result:=True;
end;

function TDlg_R_Order_Plans.SaveData: Boolean;
var
  i,j:Integer;
  va1: TVarDynArray2;
  va: TVarDynArray;
  c: TComponent;
  b: Boolean;
begin
  Result:=False;
  SetLength(va, Length(Fields));
  for i:= 0 to High(Fields) do begin
    c:= Self.FindComponent('nedt_'+Copy(Fields[i], 1, Length(Fields[i]) - 2));
    if c <> nil then begin
      if (S.NSt(TDBNumberEditEh(c).Value) = '')or(TDBNumberEditEh(c).Value = 0)
        then begin
          MyWarningMessage('Не все данные заполнены!');
          Exit;
        end;
      va[i]:=TDBNumberEditEh(c).Value;
    end;
  end;
  va[0]:=DtB;
  Q.QIUD(S.IIFStr(IsEmpty, 'i','u')[1], 'order_plans', '-', A.Implode(Fields, ';'), va);
  Result:=True;
end;


end.