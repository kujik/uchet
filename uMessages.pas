{
���������������� ������ ������ ��������� �� ���� ������������ CreateMessageDialog
-�������������� ������
-����� ������������� ���� ������
-������������� �� ������������� ����, � �� �� ��������
-����������� ������ ����� �� � Label � � Memo �� ��� �� ��������
-���� ����� ������� �� ��������� � ������� ������� �����, �� ��� ������� �����������,
 � � ���� ������ ������������� ����� � Memo
-������� ��������� ���������� ������� ��� ����������, ��������������, �������
}

unit uMessages;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, uData, Jpeg, uString, PngImage, Math,
  uForms;

//����� ����������� ����� ��������� � ������������ ������
//������ ����� ����������� �� ����� � ���������������� �������, �� ���������������� ������� ����������, ���� ��� ��������!
//���� ����������� Memo =1 ��� =2, �� ����� ������������ � TMemo ������ TLabel, ��� 1 ��� ��� ����� ����
//��������� � ��� ������������, ������ ���� ����� �� ��������� � ����
//���� ���� �� ��������� � �������� ����� �� ������, �� ��� ����������� ��� ������ � � ����� ������ ����� ����� � TMemo
function  MyMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; ButtonCaptions: string = ''; Memo: Integer = 0): Integer;

{
DefMessages: TVarDynArray - �������� � ����:
['*������ �� ���������!', '-', ...]
����� ���� ���������� ��������� ����� ������� ������� ������, �� ��������� ��������� ������;
���� ������ ��� ���� �� ������ �������, �� ������ �� ������������
}

//����� ��������� � ����� ������� �� (���������� �����������)
procedure MyInfoMessage(const Msg: string; Memo: Integer = 0); overload;
procedure MyInfoMessage(Msg: string; DefMessages: TVarDynArray; Memo: Integer = 0); overload;
//��������� - �������
function  MyQuestionMessage(const Msg: string; Memo: Integer = 0): Integer;
//��������� - ��������������
function  MyWarningMessage(const Msg: string; Memo: Integer = 0): Integer; overload;
function  MyWarningMessage(Msg: string; DefMessages: TVarDynArray; Memo: Integer = 0): Integer; overload;
//��������, ��� ������ ���� ������� ������ �������������. �������� ������!
procedure MsgRecordIsDeleted;
//'������� �������� ������!', '��� ������ ������ �������, ��� ��� ��� ��� ������������!
procedure MsgDefDlgError(Mode: TDialogType);


implementation

uses
  uFrmMain;

{
mbOK	mrOk
mbCancel	mrCancel
mbYes	mrYes
mbNo	mrNo
mbAbort	mrAbort
mbRetry	mrRetry
mbIgnore	mrIgnore
mbAll	mrAll
mbNoToAll	mrNoToAll
mbYesToAll	mrYesToAll

mtWarning	A message box containing a yellow exclamation point symbol.
mtError	A message box containing a red stop sign.
mtInformation	A message box containing a blue "i".
mtConfirmation	A message box containing a green question mark.
mtCustom	A message box containing no bitmap. The caption of the message box is the name of the application's executable file.
}

//������ ��������� � ������� ��
procedure MyInfoMessage(const Msg: string; Memo: Integer = 0);
begin
  myMessageDlg(Msg, mtInformation, [mbYes], '', Memo);
end;

procedure MyInfoMessage(Msg: string; DefMessages: TVarDynArray; Memo: Integer = 0);
var
  i: Integer;
begin
  for i := 0 to High(DefMessages) do
    if DefMessages[i] <> '' then begin
      if Msg = Copy(DefMessages[i], 1, 1) then
        Msg := Copy(DefMessages[i], 2);
    end;
  if Msg <> '' then
    myMessageDlg(Msg, mtInformation, [mbYes], '', Memo);
end;

function MyQuestionMessage(const Msg: string; Memo: Integer = 0): Integer;
begin
  Result := myMessageDlg(Msg, mtConfirmation, mbYesNo, '', Memo);
end;

function MyWarningMessage(const Msg: string; Memo: Integer = 0): Integer;
begin
  Result := myMessageDlg(Msg, mtWarning, [mbOk], '', Memo);
end;

function MyWarningMessage(Msg: string; DefMessages: TVarDynArray; Memo: Integer = 0): Integer;
var
  i: Integer;
begin
  for i := 0 to High(DefMessages) do
    if DefMessages[i] <> '' then begin
      if Msg = Copy(DefMessages[i], 1, 1) then
        Msg := Copy(DefMessages[i], 2);
    end;
  if Msg = '' then
    Result := mrOk
  else
    Result := myMessageDlg(Msg, mtWarning, [mbOk], '', Memo);
end;

procedure MsgRecordIsDeleted;
begin
  myMessageDlg('��������, ��� ������ ���� ������� ������ �������������. �������� ������!', mtWarning, [mbOK]);
end;

procedure MsgDefDlgError(Mode: TDialogType);
begin
  MyMessageDlg(S.IIf(Mode <> fDelete, '������� �������� ������!', '��� ������ ������ �������, ��� ��� ��� ��� ������������!'), mtWarning, [mbOk]);
end;



function MyMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; ButtonCaptions: string = ''; Memo: Integer = 0): Integer;
var
  i, j, k: Integer;
  va: TVarDynArray;
  c: tComponent;
  ActiveForm: TForm;
  st: string;
  w, h, d: Integer;
  LMessage: Tlabel;
  MMessage: TMemo;
  F : TForm;
begin
  F := CreateMessageDialog(Msg, DlgType, Buttons);
  with F do
  try
    d := Max(F.Height - Max(FrmMain.Height - 40, 100), 0);
    if (d > 0) and (Memo = 0) then
      Memo := 1;
    //��������� ��������� ������
    (FindComponent('Ok') as TButton).Caption := 'Ok';
    (FindComponent('OK') as TButton).Caption := 'Ok';
    (FindComponent('Cancel') as TButton).Caption := '������';
    (FindComponent('Yes') as TButton).Caption := '��';
    (FindComponent('No') as TButton).Caption := '���';
    (FindComponent('Abort') as TButton).Caption := '��������';
    (FindComponent('Retry') as TButton).Caption := '���������';
    (FindComponent('Ignore') as TButton).Caption := '������������';
    (FindComponent('All') as TButton).Caption := '���';
    (FindComponent('NoToAll') as TButton).Caption := '��� ��� ����';
    (FindComponent('YesToAll') as TButton).Caption := '�� ��� ����';
    //���� �� ����� ���� ������������ ����� ������, �� ����� ��������� ����� �� Esc
    i := 0;
    k := -1;
    for j := 0 to ComponentCount - 1 do begin
      if Components[j] is Tlabel then begin
        LMessage:=TLabel(Components[j]);
        LMessage.Height := LMessage.Height - d;
        if Memo > 0 then begin
          MMessage := TMemo.Create(F);
          MMessage.Parent := F;
          MMessage.Top := LMessage.Top;
          MMessage.Left := LMessage.Left;
          MMessage.Width := LMessage.Width + 20;
          MMessage.Height := LMessage.Height + 7;
          MMessage.Text := LMessage.Caption;
          F.Width := F.Width + 20;
          if Memo = 1 then
            MMessage.ParentColor := True;
          if d > 0 then
            MMessage.ScrollBars := ssVertical;
        end;
      end;
      if Components[j] is TButton then begin
        TButton(Components[j]).Top := TButton(Components[j]).Top - d;
        if Memo > 0 then
          TButton(Components[j]).Left := TButton(Components[j]).Left + 10;
        if k < 0 then k := j;
        inc(i);
      end;
    end;
    F.Height := F.Height - d;
    if i = 1 then begin
      TButton(Components[k]).ModalResult := mrCancel;
      TButton(Components[k]).Cancel := True;
    end;
     //��������� ������ �����, ���� �� ����� ���� - !!! �������� ��������� ����� ��� �� ����� ��������
    Caption := ModuleRecArr[cMainModule].Caption;
     //�������� �� ������ ���������, � ���������, ������
//     SetBitmapFromResource((FindComponent('Ok') as TBitBtn).Glyph, PChar('apply'));
    if ButtonCaptions <> '' then begin
      va := A.ExplodeV(ButtonCaptions, ';');
      i := -1;
      for j := 0 to ComponentCount - 1 do
        if Components[j] is TButton then begin
          inc(i);
          if i <= High(va) then
            TButton(Components[j]).Caption := va[i];
        end
    end;
    // ���������� �������� �����
    ActiveForm := Screen.ActiveForm;
    // ���� �������� ����� ��� ��� ��� �� �������� MDIChild, ���������� MainForm
    if (ActiveForm = nil) or not (ActiveForm is TForm) then
      ActiveForm := Application.MainForm;
    // ������������� ��������� �������
//    Position :=  poOwnerFormCenter;
//    st := ActiveForm.Caption;
//    PopupParent := ActiveForm;
    //��� ������� ���� - �� ���������� ������������ PopupParent!. ������ ������������� ����!
    Position := poDesigned;
    Left := Max(ActiveForm.Left + (ActiveForm.Width - Width) div 2, 0);
    Top := Max(ActiveForm.Top + (ActiveForm.Height - Height) div 2, 0);
    //������� �����
    Result := ShowModal;
  finally
    F.Free;
  end;
end;


end.

