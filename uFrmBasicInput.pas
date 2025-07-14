(*
������������� ������ �����/�������������� ������.
��� ������� (���� �����, �������, ������������, �������� ��������) �������� �����������.

����� ��� �������� �������:
- ShowDialog ��� ������ ���������� �������, �������� ��������� � ������� �������� �������� � ����������-��������
- ShowDialogDB ��� ������ ���������� ��� mdi �������, � ��������� � ����������� ������ � ��

��������� �������� ����, ��������� � �������� ������ ���������.

����� callback-������� �� ����� �� ����������, � ��������

����� �� ������ �������������!

*)


unit uFrmBasicInput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls,
  uWindows, uString, uForms, uDBOra, uMessages, uData, uFrmBasicMdi
  ;

type

  //����� �������
  TDlgBasicInputOption = (
    dbioModal,      //��������� (� ������ ��� �� ������ ���������)
    dbioSizeable,   //������ ����� ����������
    dbioChbNoClose, //������� ������� �����
    dbioStatusBar   //��������� � ����������� (��� �����, ������ ��������, ������)
    {, dbioDbLock, dbioRefreshParent}
  );

  TDlgBasicInputOptions = set of TDlgBasicInputOption;


  TFrmBasicInput = class(TFrmBasicMdi)
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    UseDB: Boolean;
    Ctrls: array of TControl;               //��������, ������ ��� ����� ������ (bevel � label ���� �� �������)
    Fields: string;                         //������ ����� ����� ;
    FieldsSave: string;                     //������ ����� ��� �������� ������ ����� ;. ���� �� �������� �� ��������� � Ctrls

    FieldsDef: TVarDynArray2;               //�������������� (���������� � ��������� ������) ����������� �����
    FieldsDefAdd: TVarDynArray2;            //����������� ����������� �����.

    View: string;                           //�������/��� �� ������� ��������� ������
    Table: string;                          //�������, � ������� ���������� ������
    Sequence: string;                       //���������, ���� �����
    IdField: string;                        //��� ���� ���������� �����

    FCaption: string;                       //��������� �����
    FWidth: Integer;                        //���������� ������ �����
    FLeft: Integer;                         //����������� ����� ������ ���������

    FieldsBegValues: Variant;               //��������� �������� ����� (������)

    MyDlgFormOptions: TDlgBasicInputOptions;//����� �������

    DisabledControls: TControlArray;        //��������, ������� � ����� ������ disabled

    Info: TVarDynArray2;                    //������ ����������

    DlgFunction: TDlgFunction;
    function  Prepare: Boolean; override;
    procedure SetControlsAdd;
    function  Load: Boolean;
    function  Save: Boolean; override;
  public
    { Public declarations }
    FieldsNewValues: TVarDynArray;          //����� �������� �����, ��� �������� �� ������� ������ ShowDialog
    //����� ������� � ��������� ������ � �� ��������� � ��������-����������
    //���������� -1 ���� ���� ������, 0 ���� ������ �� ��������, � 1 ���� ������ ���� ��������
    class function ShowDialog(
      AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType;
      ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AFieldsBegValues: TVarDynArray;
      var AFieldsNewValues: TVarDynArray; AInfo: TVarDynArray2;
      ADlgFunction:TDlgFunction=nil): Integer;
    //����� ������� (��� ��� ����������) � ������ ������ � ��
    //���������� ������ ��� ������ � ������ ������ � ��, ��������������� ����������, ���������� ����� �����������
    class function ShowDialogDB2(
      AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType; AID: Variant; ATable: string;
      ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AFieldsBegValues: TVarDynArray;
      var AFieldsNewValues: TVarDynArray; AInfo: TVarDynArray2;
      ADlgFunction:TDlgFunction=nil): Integer;
    class function ShowDialogDB(
      AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType; AID: Variant; ATable: string;
      ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AInfo: TVarDynArray2;
      ADlgFunction:TDlgFunction=nil): Integer;
    class function _TestFunction(): Integer;
    class function _TestFunctionDB(): Integer;
  end;

var
  FrmBasicInput: TFrmBasicInput;

implementation

uses
  uFrmMain
  ;

{$R *.dfm}

var
  //���������� ��� �������� ���������� ������� ������ ������ ������������
  GFieldsDef: TVarDynArray2;
  GFieldsBegValues: TVarDynArray;
  GMyFormOptions: TDlgBasicInputOptions;

//------------------------------------------------------------------------------
//������� ������ ���������� ������� � ��������� �������� � ��������� ������ � ����������-��������.
class function TFrmBasicInput.ShowDialog(
  AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType;
  ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AFieldsBegValues: TVarDynArray;
  var AFieldsNewValues: TVarDynArray; AInfo: TVarDynArray2;
  ADlgFunction:TDlgFunction=nil): Integer; //overload;
var
  i: Integer;
  myFormOptions1: TMyFormOptions;
  F: TForm;
procedure PSetControlsProc(ASelf: TObject; AControlValues: TVarDynArray);
//��������������� ������� ��� �������� ���������� ������� ������ ����� ������ ������������
begin
  TFrmBasicInput(ASelf).UseDB := False;
  TFrmBasicInput(ASelf).FWidth := AControlValues[0];
  TFrmBasicInput(ASelf).FLeft := AControlValues[1];
  TFrmBasicInput(ASelf).FCaption := AControlValues[2];
  TFrmBasicInput(ASelf).FieldsDef := GFieldsDef;
  TFrmBasicInput(ASelf).FieldsBegValues := GFieldsBegValues;
  TFrmBasicInput(ASelf).MyDlgFormOptions := GMyFormOptions;
  TFrmBasicInput(ASelf).FOpt.InfoArray := AControlValues[3];
end;
begin
  GFieldsDef := AFieldsDef;
  GFieldsBegValues := AFieldsBegValues;
  GMyFormOptions := AMyFormOptions;
  if dbioSizeable in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoSizeable];
  F := Create(AOwner, ADoc, [myfoModal, myfoDialog] + myFormOptions1, AMode, null, null,
    [AWidth, ALeft, ACaption, AInfo],
    @PSetControlsProc
  );
  Result := S.IIf(TFrmBasicMdi(F).ModalResult <> mrOk, -1, S.IIf(TFrmBasicMdi(F).IsDataChanged, 1, 0));
  AFieldsNewValues := TFrmBasicInput(F).FieldsNewValues;
  AfterFormClose(F);
end;

//------------------------------------------------------------------------------
//������� ������ ������� (mdi ��� ���������� ����) � ��������� �������� ������ �� �� � �� ������� � ��
class function TFrmBasicInput.ShowDialogDB2(
  AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType; AID: Variant; ATable: string;
  ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AFieldsBegValues: TVarDynArray;
  var AFieldsNewValues: TVarDynArray; AInfo: TVarDynArray2;
  ADlgFunction:TDlgFunction=nil): Integer; //overload;
var
  i: Integer;
  myFormOptions1: TMyFormOptions;
  F: TForm;
procedure PSetControlsProc(ASelf: TObject; AControlValues: TVarDynArray);
//��������������� ������� ��� �������� ���������� ������� ������ ����� ������ ������������
var
  va: TVarDynArray;
begin
  TFrmBasicInput(ASelf).UseDB := True;
  TFrmBasicInput(ASelf).FWidth := AControlValues[0];
  TFrmBasicInput(ASelf).FLeft := AControlValues[1];
  TFrmBasicInput(ASelf).FCaption := AControlValues[2];
  TFrmBasicInput(ASelf).FieldsDef := GFieldsDef;
  TFrmBasicInput(ASelf).FieldsBegValues := GFieldsBegValues;
  TFrmBasicInput(ASelf).MyDlgFormOptions := GMyFormOptions;
  TFrmBasicInput(ASelf).FOpt.InfoArray := AControlValues[3];
  //������� �� ����������� ; ������ ���, �������, ������������������ � ���� ���� (����������� ������ ������ ��������)
  va:=A.Explode(AControlValues[4], ';') + ['','',''];
  TFrmBasicInput(ASelf).View:=va[0];
  TFrmBasicInput(ASelf).Table:=S.IIf(va[1] = '', va[0], va[1]);
  TFrmBasicInput(ASelf).Sequence:=S.IIf(va[2] = '', '', va[2]);
  TFrmBasicInput(ASelf).IdField:=S.IIf(va[3] = '', 'id$i', va[3]);
end;
begin
  GFieldsDef := AFieldsDef;
  GFieldsBegValues := AFieldsBegValues;
  GMyFormOptions := AMyFormOptions;
  if dbioModal in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoModal];
  if dbioSizeable in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoSizeable];
  F := Create(AOwner, ADoc, [myfoDialog] + myFormOptions1, AMode, AID, null,
    [AWidth, ALeft, ACaption, AInfo, ATAble],
    @PSetControlsProc
  );
  Result := S.IIf(TFrmBasicMdi(F).ModalResult <> mrOk, -1, S.IIf(TFrmBasicMdi(F).IsDataChanged, 1, 0));
  AFieldsNewValues := TFrmBasicInput(F).FieldsNewValues;
  AfterFormClose(F);
end;

class function TFrmBasicInput.ShowDialogDB(
  AOwner: TComponent; ADoc: string; AMyFormOptions: TDlgBasicInputOptions; AMode: TDialogType; AID: Variant; ATable: string;
  ACaption: string; aWidth: Integer; aLeft: Integer; AFieldsDef: TVarDynArray2; AInfo: TVarDynArray2;
  ADlgFunction:TDlgFunction=nil): Integer; //overload;
var
  i: Integer;
  myFormOptions1: TMyFormOptions;
  F: TForm;
procedure PSetControlsProc(ASelf: TObject; AControlValues: TVarDynArray);
//��������������� ������� ��� �������� ���������� ������� ������ ����� ������ ������������
var
  va: TVarDynArray;
begin
  TFrmBasicInput(ASelf).UseDB := True;
  TFrmBasicInput(ASelf).FWidth := AControlValues[0];
  TFrmBasicInput(ASelf).FLeft := AControlValues[1];
  TFrmBasicInput(ASelf).FCaption := AControlValues[2];
  TFrmBasicInput(ASelf).FieldsDef := GFieldsDef;
  TFrmBasicInput(ASelf).FieldsBegValues := VaRArrayOf([]);
  TFrmBasicInput(ASelf).MyDlgFormOptions := GMyFormOptions;
  TFrmBasicInput(ASelf).FOpt.InfoArray := AControlValues[3];
  //������� �� ����������� ; ������ ���, �������, ������������������ � ���� ���� (����������� ������ ������ ��������)
  va:=A.Explode(AControlValues[4], ';') + ['','',''];
  TFrmBasicInput(ASelf).View:=va[0];
  TFrmBasicInput(ASelf).Table:=S.IIf(va[1] = '', va[0], va[1]);
  TFrmBasicInput(ASelf).Sequence:=S.IIf(va[2] = '', '', va[2]);
  TFrmBasicInput(ASelf).IdField:=S.IIf(va[3] = '', 'id$i', va[3]);
end;
begin
  GFieldsDef := AFieldsDef;
  GMyFormOptions := AMyFormOptions;
  if dbioModal in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoModal];
  if dbioSizeable in AMyFormOptions then
    myFormOptions1 := myFormOptions1 + [myfoSizeable];
  F := Create(AOwner, ADoc, [myfoDialog] + myFormOptions1, AMode, AID, null,
    [AWidth, ALeft, ACaption, AInfo, ATAble],
    @PSetControlsProc
  );
  Result := S.IIf(TFrmBasicMdi(F).ModalResult <> mrOk, -1, S.IIf(TFrmBasicMdi(F).IsDataChanged, 1, 0));
  AfterFormClose(F);
end;



procedure TFrmBasicInput.SetControlsAdd;
(*
������ ������ - �����������
0="���_����{;���_����_���_������}" - ����� �� ����, ����� ��������� ������� ��� �������� � ����. ���� ���� ��� ������ �� ������, ������������ �� �� ����
1=��� ��������
2=���������
3=������� ��������, ����� �� ����
4=������, ����� �� ����. ���� ��� ��� 0 ��� 1, �� � ���� ������ ����� � ����� ������������� �� ������ ����, � ������ � �� ��������� ������ ��� w = 0 � �� ���� ��� w =1
5=���� ������, �� ��� ������ ������, ������� ����� �� �������� �� ��������� ������, � ���������� � ������� ������ � ���� ����������
*)
var
  c: TVarDynArray;
  va: TVarDynArray;
  va2: TVarDynArray2;
  i, j, k, h, h1, r :Integer;
  st:string;
begin
  va2:=[];
  DisabledControls := [];
  for i:=0 to High(FieldsDef) do begin
    va2:= va2 + [[cntBevel, ''{caption}, ''{verify}, 0{width}, 0{left}, 0, 0, '', '']];
    if High(FieldsDef[i]) < 0 then Continue;
    j:= 0;
    if UseDB or ((High(FieldsDef[i]) >= 0) and (S.VarType(FieldsDef[i][0]) = varString)) then begin
      va:=a.Explode(FieldsDef[i][0] + ';', ';');
      S.ConcatStP(Fields, va[0], ';');
      S.ConcatStP(FieldsSave, S.IIFStr(va[1] = '', va[0], va[1]), ';');
      j:= 1;
    end;
    for k:= j to High(FieldsDef[i]) do begin
      va2[i][k-j]:= FieldsDef[i][k];
    end;
  end;
  SetLength(Ctrls, Length(va2));

  //������ ����� �� ����������� � ������ ���������
  Width := FWidth;

  h := 3;
  k := 0;
  for i := 0 to High(va2) do begin
    Ctrls[i]:= Cth.CreateControls(pnlFrmClient, va2[i][0], va2[i][1], 'Ctrl_'+IntToStr(i), va2[i][2]);
    Ctrls[i].Left:=FLeft;
    Ctrls[i].Top:=h;
    //���� ��������� �������� - ���������� ������� �� ��� �� ������, � ������� � ������ ����� ���������
    if (va2[i][4] > 0) then begin
      Ctrls[i].Left := va2[i][4];
      Ctrls[i].Top := Ctrls[i - 1].Top;
    end;
    //��������� ��������
    //�������� ������ 0 �������� ��� �������� ����-��������� ������ ������ �� �������, ��� ������� ������ �� ����� ����
    //������ = 1 �������� ����������� �������� �� ����� ���� �� ���� �������, � � ������ ����������� ������� - ������ �����
    h1 := Ctrls[i].Height + 3 + S.IIf(va2[i][0] = cntBevel, 6, 0);
    h := h + h1;
    //�������������� �����������
    if va2[i][0] = cntBevel then begin
      Ctrls[i].Left := 2; //MY_FORMPRM_H_EDGES;
      Ctrls[i].Width := 1;  //������ �� ��� ����
    end
    else begin
      if(va2[i][3]) = 0 then begin
        if not (TMyControlType(va2[i][0]) in [cntNEdit, cntNEditC, cntNEditS, cntDEdit, cntTEdit, cntDTEdit]) then
          Ctrls[i].Width:= 1;
      end
      else if(va2[i][3]) = 1 then
        Ctrls[i].Width:= 1
      else if va2[i][3] > 1
        then Ctrls[i].Width:=va2[i][3];
      if Copy(va2[i][1], 1, 1) = ' ' then
        DisabledControls := DisabledControls + [Ctrls[i]];
    end;
    //������������ ������
    r := Max(r, Ctrls[i].Left + Ctrls[i].Width);
  end;

  //������������ ��������� � �������� �����
  //�� 2025-01-21 �������� ���
  if myfoSizeable in MyFormOptions then begin
    FWHBounds.Y2:=-1;
    ClientWidth:= Max(r + 3, 5);
    FWHCorrected:= Cth.AlignControls(pnlFrmClient, [], False) ;
    FWHCorrected.X:= Max(r + 3, FWidth);
    ClientWidth := FWHCorrected.X + MY_FORMPRM_H_EDGES + 2;
  //  FOpt.AutoAlignControls:=True;
  end
  else begin
    FWHCorrected:= Cth.AlignControls(pnlFrmClient, [], False) ;
    FWHCorrected.X:= Max(r + 3, FWidth);
    ClientWidth := FWHCorrected.X + MY_FORMPRM_H_EDGES + 2;
  end;

  //�������� �������� � �������  = 1 �� ����� ����
  for i := 0 to High(Ctrls) do
    if Ctrls[i].Width = 1 then begin
      Ctrls[i].Width:= ClientWidth - Ctrls[i].Left - MY_FORMPRM_H_EDGES * 2 - 2;
      //���� ����� ����������� �� ������, ��� ����� �����. �� ���� ������� �� �����, �� ��� �������
      //������ ������� � ��������� � ��������� Tag, �� �������� � ������ � TFrmMDI.CorrectFormSize ��������������� �����
      //!!!��������������� ������������� Tag!!!
      if myfoSizeable in MyFormOptions then
        Ctrls[i].Tag := -100;
       //Ctrls[i].Anchors := [akLeft, akTop, akRight];
    end;


  FieldsDefAdd := Copy(va2);

  //�������� ������ �� ������� ���������, ��� ��� ��� �� ����� �������� � ����� ������
  for i := High(va2) downto 0 do
    if va2[i][0] = cntBevel
      then Delete(Ctrls, i, 1);

end;

procedure TFrmBasicInput.FormActivate(Sender: TObject);
begin
  inherited;
//  Caption := InttoStr(ClientWidth);
end;

function TFrmBasicInput.Load(): Boolean;
//��������� �������� ��������� �� ����������� ������� �������
var
  s: string;
  f, f1: TVarDynArray;
  i, j, k : Integer;
  v, vcb, vcb_list: TVarDynArray;
begin
  Result:= True;
  v:=FieldsBegValues;
  SetLength(FieldsNewValues, Length(Ctrls));
  if not UseDB then begin
  k := -1;
  try
    for i := 0 to High(FieldsDefAdd) do begin
      if TMyControlType(FieldsDefAdd[i][0]) = cntBevel
        then Continue;
      inc(k);
      //��� ����������� ���������� ������ �������� ���� VarArrayOf([value, VarArrayOf([v1, v2]) ,{VarArrayOf([key1, key2])} ])
      if TMyControlType(FieldsDefAdd[i][0]) in [cntComboL, cntComboLK, cntComboLK0, cntComboE, cntComboEK] then begin
        vcb := v[k];
        vcb_list := vcb[1];
        //�������� ��������
        for j := 0 to High(vcb_list) do
          TDBComboBoxEh(Ctrls[k]).Items.Add(vcb_list[j]);
        if TMyControlType(FieldsDefAdd[i][0]) in [cntComboLK, cntComboLK0, cntComboEK] then
          //��� ����������� � �������� �����
          if High(vcb) > 1 then begin
              //���� ������� ������ ��������-������, �� �� ���� �����
            vcb_list := vcb[2];
            for j := 0 to High(vcb_list) do
              TDBComboBoxEh(Ctrls[k]).KeyItems.Add(vcb_list[j]);
          end
          else begin
              //����� ����� ������ ����� ������� � 0
            for j := 0 to High(vcb_list) do
              TDBComboBoxEh(Ctrls[k]).KeyItems.Add(IntToStr(j));
          end;
       //�������� ���������� �� 0�� ��������, ��� ��� ���� ��������, ��� ����
        Cth.SetControlValue(Ctrls[k], vcb[0]);
      end      //��� ������ ������� - ������ ��������� ��������
      else begin
        Cth.SetControlValue(Ctrls[k], v[k]);
      end;
    end;
  except
    Result:= False;
  end;
  end
  else begin
    if Mode <> fAdd then begin
      Result := False;
      Fields:= IdField + ';' + Fields;
      FieldsSave:= IdField + ';' + FieldsSave;
      v := Q.QLoadToVarDynArrayOneRow(Q.QSIUDSql('s', View, Fields), [ID]);
      if Length(v) = 0 then begin
        MsgRecordIsDeleted;
        Exit;
      end;
      for i := 0 to High(Ctrls) do
        Cth.SetControlValue(Ctrls[i], v[i + 1]);
      Result := True;
    end
    else begin
      FieldsSave:= IdField + ';' + FieldsSave;
      for i := 0 to High(Ctrls) do
        if not((Ctrls[i] is TDBCheckBoxEh) and (TDBCheckBoxEh(Ctrls[i]).Checked))
         then Cth.SetControlValue(Ctrls[i], null);
    end;
  end;
end;


function TFrmBasicInput.Save: Boolean;
//���������� ������
//���������� ������ �������� ����������
//����� ���� ���������, � ��� ��� ������ inherited
var
  ChildHandled: Boolean;
  i, res: Integer;
  FieldsSave2, CtrlValues2: TVarDynArray;
  FieldsSaveNew: string;
begin
  Result := False;
  if not UseDB then begin
    for i := 0 to High(Ctrls) do
      FieldsNewValues[i] := Cth.GetControlValue(Ctrls[i]);
    Result := True;
    Exit;
  end;

  try
    for i := 0 to High(Ctrls) do
      FieldsNewValues[i] := S.NullIfEmpty(Cth.GetControlValue(Ctrls[i]));
  except
    on E: Exception do begin
      Application.ShowException(E);
      Exit;
    end;
  end;
  CtrlValues2:= Copy(FieldsNewValues);
  FieldsSave2:= A.Explode(FieldsSave, ';');
  for i:= high(FieldsSave2) downto 0 do
    if FieldsSave2[i] = '0' then begin
      Delete(FieldsSave2, i, 1);
      Delete(CtrlValues2, i, 1);
    end;
  CtrlValues2 := [S.IIf(Mode in [fEdit, fDelete], ID, -1)] + CtrlValues2;
//  FieldsSaveNew:= IdField + ';' + A.Implode(FieldsSave2, ';');
  FieldsSaveNew:= A.Implode(FieldsSave2, ';');
  res := Q.QIUD(Q.QFModeToIUD(Mode), Table, Sequence, FieldsSaveNew, CtrlValues2);
  Result := res <> -1;
end;

function TFrmBasicInput.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
begin
  Result := False;
  //�������� ����� ����������. �� �����������, ���� ��� foformDoc ��� ID = null
  if FormDbLock = fNone then
    Exit;
  //������������� ������������ ������������ �����
  MyFormOptions := MyFormOptions + [myfoDialog];
  //������ ������ �����
  FOpt.DlgPanelStyle := dpsBottomRight;
  //���������
  if dbioStatusBar in MyDlgFormOptions then
    FOpt.StatusBarMode := stbmDialog;
  //������� ������� �����
  if dbioChbNoClose in MyDlgFormOptions then
    FOpt.UseChbNoClose := True;
  //��� ������ � ����� - ��������� ������������ ����� ��� ��
  if UseDB then
    FOpt.RefreshParent := True;
  //���������. �� �������� ���� ���� ������!
  Caption := FCaption;
  //������� �������� ��� �����, ����������� �� � ��������� ������ �����
  SetControlsAdd;
  //��������� ������
  if not Load then
    Exit;
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  if Length(DisabledControls) > 0 then
    SetControlsEditable(DisabledControls, False);
  //�������� ����� ��������
  Verify(nil);
  Result := True;
end;

{
myfoSizeable
�������� � ������ 0/1 (����� �� ������� ����) �������� ����, ������������ � ����������� ����
���� �� ���������, ����� �� �������������� �� ��������
}


class function TFrmBasicInput._TestFunction(): Integer;
var
  va: TVarDynArray;
begin
  Result:= TFrmBasicInput.ShowDialog(FrmMain, '', [], fAdd, '���� �����������', 800, 100,
   [[cntEdit, '������������','1:30'],
    [cntEdit, '���������','0:100:0:N'],
    [],
    [cntCheck,  '������������',''],
    [cntNEditS, '�����','-1:30:2', 0, 250],
    [cntDTEdit, '����','' + S.DateTimeToIntStr(Date) + ':*'], //floattostr(extended(dt))
    [cntBevel],
    [cntComboE, '���������','1:50:0', 400],
    [cntComboLK, '����� � ������','0:50:0:N']
   ],
   VarArrayOf([
     'name','req', 1, -40.5, Date,
     VarArrayOf(['0', VarArrayOf(['0','1','2'])]),
     VarArrayOf(['2', VarArrayOf(['item 0','item 1','item 2']), VarArrayOf(['0','2','1'])])
   ]),
   va,
   [['��� ����� ����� ������������ ������ � �������� �� ��������.']],
   nil
   //,
   //DlgFunction
  );
end;

class function TFrmBasicInput._TestFunctionDB(): Integer;
var
  va: TVarDynArray;
begin
  Result:= TFrmBasicInput.ShowDialogDB(FrmMain, '', [dbioChbNoClose, {bioSizeable,}dbioStatusBar], fAdd, 35, 'or_format_estimates', '������ �����', 400, 100,    //35 - test
   [['name$s', cntEdit, '������������','1:30'],
    ['prefix$s', cntEdit, '�������','1:20', 150],
    [],
    ['active$i', cntCheckX, '������������']
   ],
{   VarArrayOf([
     'name','req', 1, -40.5, Date,
     VarArrayOf(['0', VarArrayOf(['0','1','2'])]),
     VarArrayOf(['2', VarArrayOf(['item 0','item 1','item 2'])])
   ]),
   va,}
   [['��� ����� ����� ������������ ������ � �������� �� ��������.']],
   nil
  );
end;

end.

2025-01-09
��� ��������� ������������ ������������ ����� (��� ���� ������ � �������)
��� ���� ������ ���������� � ��

--------------------------------------------------------------------------------

�����:
dbioModal - ����� � ��������� ������, ��������� ������ ��� ShowDialogDB,
��� ���� ������ ���������.

� ������ dbioSizeable ����� ������������� �� �����������, ����� ������� ���������.
�� ������ ������ ����������� �� ����������� (������� ���������).
�� �����������, ���� ����� � ��������� ������� �������� ������, ��� ����� ������� ������ ����
�������� ���������� �����, �� ����� ����� ����������� �� ��� ����, ���� �� ����� ������,
�� ������ ��������� ������ ��. ��� ���������� �����, ���� �� ������ ����� ���������� ����������.

dbioChbNoClose - ��������� ������� � ���������� ����� ������ � ������ fAdd/fCopy
��� �������� ����.
�� ������ ������ ���������� �� ���������!

dbioStatusBar - ��������� ��������� � ����� � ������ �������.

dbioDbLock - ��������� ���������� ������� ����������.
�� ������������! � ������ � �� �� ������ ����, � ������� ������� ���!
��������, ������ ���� ����� FormDoc � ID (� �� ���� ��� ������� � ��).
������� ���� ����� �������������� ��� ��������. ��� �������� ���������� � ������
�������������� - ��������� � ������ ���������, � ����������, � ������ ��������
�� ��������� �  ����������. ���������� �������� ���� ��� ������ ��� ������ ��.

dbioRefreshParent - ��������� ������������ ����� ��� ������� ��, ���� ��� ������������ ���
������� (������ �������, ������ MDI_Grid1 ��������� ������ �������� ����. ���� ����������)
� ������������! � ������ � �� ������ ���������, � ������� ������� ���!
--------------------------------------------------------------------------------

��������� � ��������� ������� (��� ������� ��� ��, ShowDialog):
-������������ ������� (��� ������)
-FormDoc. �� ����������. ���� �����, �� ��� ��������� ��������� ������ �����.
-�����, ���������
-����� �������, �� ���� ������� ������, ����������� �����.
-��������� �����, ������ � ������, ���� �� ����� ������� ��� "��� - ��������"
-������ �����
-����� ����� ���������

-������ ����������� ���������
� ������� TVarDynArray2 ��������� ������ ��������� ���� ��� ��������.
������ - ��� ���������.
������� - ������� �������� ������. ������. ����� ���� ���������, ����� �������� ���
��������� - ����� ���� ����� �������� (��� ���������� ��������������� 0).
��������, ���������� ����� ������� �������� 1, ����� ���������
�� ���� �����, � � ������ ������������� ����� ����� ����� �������������.
�������� 0 �������� ��������� ����� ��������, ��� �� ��������� ��� ������� ��������� ������.
����� - ���� �� ���� - Left ��������, � ���� ������ �� ��������� �� ��� �� ������ ��� �
���������� � �� ��������� �� �����������.
� ������ ������ � ��, ������ ���������� ���� ��� ���� (��� ����_������;����_������),
��������� ��������� ����������.
������ ������� ������� ��������� �������������� �����������.
��������� ��������, ������������ � �������, ������ ���� ������� ��������������� � ����� ������

-����������� ��������� �������� ���������, ��� Variant
����� ���� ��������� ��� VarArrayOf
������ �����������, ������� �������� ������������ �������� Variant � ���� VarArrayOf
��� �����������, �������� ���:
VarArrayOf(['0', VarArrayOf(['0','1','2'])]), //��� �����
VarArrayOf(['2', VarArrayOf(['item 0','item 1','item 2']), VarArrayOf(['0','2','1'])]) //� ������

-������������ ��������, � ������� TVarDynArray.
���� ��������� �� ����, ����� ����� ��������� ���������.

-���������, � ������� TVarDynArray2, � ������� ��� ��� �������
(� ����������� ������, � ������ ��������, ���� ���� - ���������� -
����������, �������� �� ������ � �����)

-Callback-�������, � ����������

���� �� �������� �������� ������������ ������, ������ �� ������ ����������,
����� ������ fDelete.

����� ������� ������:
-1, ���� ���� �������� �� �� ������ ��
0, ���� ������ ��, �� �� ���� ��������� ������
1, ���� ������ �� � ������ ���� ��������.

--------------------------------------------------------------------------------
��������� � ��������� ������� (��� ������� � ��, ShowDialogDB):
-������������ ������� (��� ������)
-FormDoc. �� ����������. ���� �����, �� ��� ��������� ��������� ������ �����.
-�����, ���������
-����� �������, �� ���� ������� ������, ����������� �����, � ����� ������/���������� ������
-ID
-��������� ���������/������ ������, ����� ';', �� ����� ����������� ��� ���� ��� ���������,
 ����� ���� �������� �� ����� �� �������:
 view;table;sequence;id_field
 �� ��������� table = view, sequence �� �����, id_field = 'id$i'
-��������� �����, ������ � ������, ���� �� ����� ������� ��� "��� - ��������"
-������ �����
-����� ����� ���������

�������� ������������ ���������� � ������ �������������� ��� ��������
������ ��������, ���� ������� �������� ���������, ��� ���� �������
���� ���������, �� ������� �� ����������� � ����, ��� ������� �������� ��������� �
������ �� �����������.
����������� ������������ �����

--------------------------------------------------------------------------------

�� �����������
�������� ����������� � ������ ������ � ��
Callback-�������, � ����������
