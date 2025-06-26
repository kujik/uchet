unit D_Turv_FromParsec;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, DBCtrlsEh, Vcl.StdCtrls,
  Vcl.Mask, Vcl.Buttons, Math;

type
  TDlg_Turv_FromParsec = class(TForm_Normal)
    E_FileName: TDBEditEh;
    De_1: TDBDateTimeEditEh;
    De_2: TDBDateTimeEditEh;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure Bt_OkClick(Sender: TObject);
    procedure E_FileNameEditButtons0Click(Sender: TObject;
      var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    FileName: string;
    function ShowDialog(dt1, dt2: TDateTime): Boolean;
  end;

var
  Dlg_Turv_FromParsec: TDlg_Turv_FromParsec;

implementation

uses
  uData,
  uForms,
  uString,
  uMessages
  ;

{$R *.dfm}

procedure TDlg_Turv_FromParsec.Bt_OkClick(Sender: TObject);
var
  b, b1, b2: Boolean;
begin
  inherited;
  b1:= Cth.VerifyControl(De_1);
  b2:= Cth.VerifyControl(De_2);
  if b1 and (De_1.Value > Date) then Cth.SetErrorMarker(De_1, True);
  if b2 and ((De_2.Value > Date)or(De_2.Value < De_1.Value)) then Cth.SetErrorMarker(De_2,True);
  Cth.SetErrorMarker(E_FileName, (Length(E_FileName.Text) < 6) or not FileExists(FileName));
  b:=Cth.VerifyVisualise(Self);
  ModalResult:=S.IIf(b, mrOk, mrNone);
end;

procedure TDlg_Turv_FromParsec.E_FileNameEditButtons0Click(Sender: TObject;
  var Handled: Boolean);
begin
  inherited;
  if OpenDialog1.Execute then begin
    FileName:=OpenDialog1.FileName;
    E_FileName.Text:=ExtractFileName(FileName);
  end;
end;

function TDlg_Turv_FromParsec.ShowDialog(dt1, dt2: TDateTime): Boolean;
var
  dt: TDateTime;
begin
  Cth.SetBtn(Bt_Ok, mybtOk, False);
  Cth.SetBtn(Bt_Cancel, mybtCancel, False);
  if not Cth.DteValueIsDate(De_1) then De_1.Value:=dt1;
  if not Cth.DteValueIsDate(De_2) then De_2.Value:=min(dt2, Date);
  Cth.SetControlsVerification([De_1, De_2], [
    S.DateTimeToIntStr(dt1) + ':' + S.DateTimeToIntStr(dt2),
    S.DateTimeToIntStr(dt1) + ':' + S.DateTimeToIntStr(dt2)
  ]);
  OpenDialog1.Filter := 'Файлы Excel 2007+|*.xlsx';
  Result:=(ShowModal = mrOk)and(MyQuestionMessage(
    'В ТУРВ будут внесены данные по приходу и уходу работников и просчитано их рабочее время.'#13#10'Продолжить?') = mrYes
  );
end;


end.
