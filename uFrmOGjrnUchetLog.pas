{
��� �������� ������������� �� ��������� � �����������
}

unit uFrmOGjrnUchetLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGjrnUchetLog = class(TFrmBasicGrid2)
  private
    FIdOperation: Integer;
    FCapt: string;
    function  PrepareForm: Boolean; override;
    procedure GetIdOperation;
  public
  end;

var
  FrmOGjrnUchetLog: TFrmOGjrnUchetLog;

implementation

const
  mToProd = 1;
  mToSgp = 2;
  mFromSgp = 3;
  mOtk = 4;

  captToProd = '';
  captToSgp = '������ �� ���';
  captFromSgp = '�������� � ���';
  captOtk = '������ ���';

function TFrmOGjrnUchetLog.PrepareForm: Boolean;
var
  va2: TVarDynArray2;
  st: string;
begin
  GetIdOperation;
  Caption:= '������ ������ (' + FCapt + ')';

  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  va2 := [
    ['id$i','_id','40'],
    ['operation','��������','150;h'],
    ['dt_day','���� ��������','75'],
    ['dt','����� ��������','120'],
    ['username','���������','150']
  ];
  if FIdOperation in [mToSgp, mFromSgp, mOtk] then begin
    va2 := va2 +[
      ['document','�������','400;h'],
      ['qnt1','���-��','80'],
      ['dt1','���� ��������','75']
    ];
    st := ';dt1';
  end;
  Frg1.Opt.SetFields(va2);
  Frg1.Opt.SetTable('v_adm_uchet_log');
  Frg1.Opt.SetWhere('where id_operation = ' + IntToStr(FIdOperation));
  Frg1.Opt.FilterRules := [[], ['dt_day' + st]];
  Frg1.Opt.SetButtons(1, 'rfsp');
  Frg1.InfoArray:=[];
  Frg1.Opt.ColumnsInfo:=[];
  Result := inherited;
end;


procedure TFrmOGjrnUchetLog.GetIdOperation;
begin
//  if (FormDoc = myfrm_J_OrderStages_ToProd) then FIdOperation:=mToProd;
  if (FormDoc = myfrm_J_OrderStages_ToSgp_Log) then FIdOperation:=mToSgp;
  if (FormDoc = myfrm_J_OrderStages_FromSgp_Log) then FIdOperation:=mFromSgp;
  if (FormDoc = myfrm_J_OrderStages_Otk_Log) then FIdOperation:=mOtk;
//  if (FormDoc = myfrm_J_Or_DelayedInProd) then FIdOperation:=mDelInProd;
//  if (FormDoc = myfrm_J_Or_Montage) then FIdOperation:=mMontage;
  if (FormDoc = myfrm_J_OrderStages_ToSgp_Log) then FCapt:=captToSgp;
  if (FormDoc = myfrm_J_OrderStages_FromSgp_Log) then FCapt:=captFromSgp;
  if (FormDoc = myfrm_J_OrderStages_Otk_Log) then FCapt:=captOtk;
end;
{$R *.dfm}

end.
