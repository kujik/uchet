unit D_Turv_FromParsec;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, DBCtrlsEh, Vcl.StdCtrls,
  Vcl.Mask, Vcl.Buttons, Math;

type
  TDlg_Turv_FromParsec = class(TForm_Normal)
    edt_FileName: TDBEditEh;
    dedt_1: TDBDateTimeEditEh;
    dedt_2: TDBDateTimeEditEh;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure Bt_OkClick(Sender: TObject);
    procedure edt_FileNameEditButtons0Click(Sender: TObject;
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
  b1:= Cth.VerifyControl(dedt_1);
  b2:= Cth.VerifyControl(dedt_2);
  if b1 and (dedt_1.Value > Date) then Cth.SetErrorMarker(dedt_1, True);
  if b2 and ((dedt_2.Value > Date)or(dedt_2.Value < dedt_1.Value)) then Cth.SetErrorMarker(dedt_2,True);
  Cth.SetErrorMarker(edt_FileName, (Length(edt_FileName.Text) < 6) or not FileExists(FileName));
  b:=Cth.VerifyVisualise(Self);
  ModalResult:=S.IIf(b, mrOk, mrNone);
end;

procedure TDlg_Turv_FromParsec.edt_FileNameEditButtons0Click(Sender: TObject;
  var Handled: Boolean);
begin
  inherited;
  if OpenDialog1.Execute then begin
    FileName:=OpenDialog1.FileName;
    edt_FileName.Text:=ExtractFileName(FileName);
  end;
end;

function TDlg_Turv_FromParsec.ShowDialog(dt1, dt2: TDateTime): Boolean;
var
  dt: TDateTime;
begin
  Cth.SetBtn(Bt_Ok, mybtOk, False);
  Cth.SetBtn(Bt_Cancel, mybtCancel, False);
  if not Cth.DteValueIsDate(dedt_1) then dedt_1.Value:=dt1;
  if not Cth.DteValueIsDate(dedt_2) then dedt_2.Value:=min(dt2, Date);
  Cth.SetControlsVerification([dedt_1, dedt_2], [
    S.DateTimeToIntStr(dt1) + ':' + S.DateTimeToIntStr(dt2),
    S.DateTimeToIntStr(dt1) + ':' + S.DateTimeToIntStr(dt2)
  ]);
  OpenDialog1.Filter := 'Файлы Excel 2007+|*.xlsx';
  Result:=(ShowModal = mrOk)and(MyQuestionMessage(
    'В ТУРВ будут внесены данные по приходу и уходу работников и просчитано их рабочее время.'#13#10'Продолжить?') = mrYes
  );
end;


end.
