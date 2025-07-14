unit uFrmODedtOrStdItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions, Vcl.Mask,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput, uFields, uFrmBasicDbDialog
  ;

type
  TFrmODedtOrStdItems = class(TFrmBasicDbDialog)
    edt_name: TDBEditEh;
    chb_R0: TDBCheckBoxEh;
    chb_Wo_Estimate: TDBCheckBoxEh;
    nedt_Price: TDBNumberEditEh;
    nedt_Price_PP: TDBNumberEditEh;
    chb_by_sgp: TDBCheckBoxEh;
    cmb_type_of_semiproduct_: TDBComboBoxEh;
    cmb_id_or_format_estimates: TDBComboBoxEh;
  private
    FRcount: Integer;
    FNameOld : string;
    FWoEstimateOld: Integer;
    FIdEstimateGroup: Variant;
    FPrefix: string ;
    FIsRouteChanged: Boolean;
    FIsSemiproduct: Boolean;
    function  Prepare: Boolean; override;
    function  Load: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
  protected
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure SetRoute;
  public
  end;

var
  FrmODedtOrStdItems: TFrmODedtOrStdItems;

implementation

 uses
   uOrders
   ;

 {$R *.dfm}

function TFrmODedtOrStdItems.Prepare: Boolean;
var
  i, j: Integer;
  va: TVarDynArray;
  va1, va2: TVarDynArray2;
begin
  Caption:='����������� �������';

  va1 := Q.QLoadToVarDynArray2('select code, id from work_cell_types where pos is not null order by pos', []);

  for i:=0 to High(va1) do begin
    Cth.CreateControls(pnlFrmClient, cntCheck, va1[i][0], 'chb_r_' + S.NSt(va1[i][1]), '', 0, edt_name.Left + i * 50, edt_name.Top + edt_name.Height + MY_FORMPRM_H_EDGES);
    va2 :=  va2 + [['chb_r_' + S.NSt(va1[i][1]) + ';0;0']];
  end;

  va2 := [
    ['id$i'],
    ['name$s','V=1:400::T'],
    ['price$f','V=0:9999999:2:n'],
    ['price_pp$f','V=0:9999999:2:n'],
    ['wo_estimate$i'],
    ['r0$i'],
    ['by_sgp$i'],
    ['id_or_format_estimates$i','V=1:400:1'],
    ['type_of_semiproduct$i','V=0:400']
  ] ;


  F.DefineFields:=va2;
  View := 'or_std_items';
  Table := 'or_std_items';
  FOpt.UseChbNoClose:= True;
  //Opt.RequestWhereClose:= cqYNC;
  FOpt.InfoArray:= [
    ['���� ���������� ������������ �������.'#13#10+
     ''#13#10
    ]
  ];
  Result := inherited;
  if Mode <> fDelete then begin
    FNameOld := S.NSt(F.GetPropB('name'));
    FWoEstimateOld:=S.NInt(F.GetPropB('wo_estimate'));
    FIdEstimateGroup := AddParam;
    va := Q.QSelectOneRow('select prefix, is_semiproduct from or_format_estimates where id = :id$i', [FIdEstimateGroup]);
    FPrefix := S.NSt(va[0]);
    FIsSemiproduct := va[1] = 1;
  end;
  SetRoute;
  i:=f.GetPropB('id_or_format_estimates');
end;

function  TFrmODedtOrStdItems.Load: Boolean;
var
  i, j: Integer;
  va2 : TVarDynArray2;
begin
  Result := inherited;
  if not Result then
    Exit;
  va2 := Q.QLoadToVarDynArray2('select id_work_cell_type from or_std_item_route where id_or_std_item = :id$i', [ID]);
  FRcount := High(va2);
  for i := 0 to High(va2) do
    TDBCheckBoxEh(Self.FindComponent('chb_r_' + S.NSt(va2[i][0]))).Checked := True;
//  FIsSemiproduct = Q.QloadOneRow('select is_semiproduct from or_format_estimates where id = :id$i' [FIDEsti]);
end;

function TFrmODedtOrStdItems.LoadComboBoxes: Boolean;
begin
//exit;
  Q.QLoadToDBComboBoxEh(
    'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' +
    'from or_formats f, or_format_estimates e ' +
    'where e.id_format > 1 and e.id_format = f.id and e.active = 1 and (f.active = 1 or  e.id = :id$i) order by 1 asc'
    ,[AddParam], cmb_id_or_format_estimates, cntComboLK);
  Q.QLoadToDBComboBoxEh('select code, id from work_cell_types where pos is not null order by pos', [], cmb_type_of_semiproduct_, cntComboLk);
end;



procedure TFrmODedtOrStdItems.ControlOnExit(Sender: TObject);
begin
  inherited;
end;

procedure TFrmODedtOrStdItems.ControlOnChange(Sender: TObject);
begin
  if (A.InArray(TControl(Sender).Name, ['chb_R0', 'chb_Wo_Estimate'])) or (Copy(TControl(Sender).Name, 1, 6) = 'chb_r_') then
    SetRoute;
  inherited;
end;

function TFrmODedtOrStdItems.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//�������� ����� �������:
//���� �� ����� �������, ����� �� ������ ����
//���� ���� ����������� ������ �����
var
  i, j: Integer;
begin
  j := 0;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 6) = 'chb_r_') and (TDBCheckBoxEh(Components[i]).Checked) then
      j := j + 1;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 6) = 'chb_r_') then
      Cth.SetErrorMarker(TDBCheckBoxEh(Components[i]), TDBCheckBoxEh(Components[i]).Enabled and (j = 0));
  //���� ����������� �� ������ ���� ������ ����� ����
  Cth.SetErrorMarker(nedt_Price_PP, (nedt_Price_PP.Value > nedt_Price.Value) or (nedt_Price_PP.Value = null));
end;

function TFrmODedtOrStdItems.Save: Boolean;
//������ ����������� � ��
//��� ��������� �������� �������� ��� ����� � ������ �������������� ��� ���� ���������� ����� ����� ������ �������� �������
//(���� ����� ���� �����, �� ��������� ������ �����, ���� �� ����� ����������, �� ����� ������ ������� - ����� ��������� ����� � ���������)
var
  name, nameold, prefix: string;
  i: Integer;
  Res: Integer;
begin
  Q.QBeginTrans(True);
  repeat
  //�������� �������� ������
    Result := inherited;
    if (Mode <> fDelete) and FIsRouteChanged then begin
      Q.QExecSql('delete from or_std_item_route where id_or_std_item = :id$i', [ID]);
      for i := 0 to ComponentCount - 1 do
        if (Copy(Components[i].name, 1, 6) = 'chb_r_') and (TDBCheckBoxEh(Components[i]).Checked) then
          Q.QExecSql('insert into or_std_item_route (id_or_std_item, id_work_cell_type) values (:ido$i, :idt$i)', [ID, Copy(Components[i].name, 7)])
    end;
    if (Mode = fEdit) and (edt_name.Text <> FNameOld) then begin
    //���� ��� �������������� � ������������ ���������� - ��������� �������� ��� � � �� ��� (� ������ ��������)
    //������� ������� ������
      prefix := '';
      if FIdEstimateGroup > 0 then
        prefix := Q.QSelectOneRow('select prefix from or_format_estimates where id = :id$i', [FIdEstimateGroup])[0];
    //������ � ����� ���
      name := S.IIFStr(prefix <> '', prefix + '_', '') + Trim(edt_name.Text);
      nameold := S.IIFStr(prefix <> '', prefix + '_', '') + FNameOld;
    //��������, ���� �� ��� � ��� � ��������� ������ ��������������� ������ �����
      Res := Q.QSelectOneRow('select count(1) from dv.nomenclatura where id_group = :ig_group$i and name = :name$s', [ItmGroups_Production_ID, name])[0];
      if Res = 0 then begin
      //���� ���, �� ����������� ������ �� ������ ������ � ����� (���� ��� ����������� ����)
        Result := Q.QExecSql('update dv.nomenclatura set name = :name$s, fullname = :fullname$s where id_group = :ig_group$i and name = :nameold$s', [name, name, ItmGroups_Production_ID, nameold]) >= 0;
      end;
    end;
    if not Result then
      Break;
    if (Mode = fEdit) and (Cth.GetControlValue(chb_Wo_Estimate) <> FWoEstimateOld) then begin
    //���� ��������� ������� "��� �����", �� ������� �����
    //(� �������� ����� ������� �������, ���� ��� ���� ���� ���������� �������� �����)
      Result := Orders.RemoveEstimateForStdItem(id, True);
    end;
    if (Mode = fEdit) then begin
    //��������� � �������� ���� � ������� �������, ��������������� �������
      Result := Q.QExecSql('update order_items set ' + 'price = :price$f, price_pp = :price_pp$f ' + 'where id_order < 0 and id_std_item = :id_std_item$i', [nedt_Price.Value, nedt_Price_PP.Value, ID]) >= 0;
      if Result then begin
{      Result:= Q.QExecSql(
        'update order_items set '+
        'r0 = :r0$i, r1 = :r1$i, r2 = :r2$i, r3 = :r3$i, r4 = :r4$i, r5 = :r5$i, r6 = :r6$i, r7 = :r7$i '+
        'where id_order < 0 and id_std_item = :id_std_item$i and nvl(sgp, 0) <> 1',
        [Cth.GetControlValue(chb_R0),Cth.GetControlValue(chb_R1),Cth.GetControlValue(chb_R2),Cth.GetControlValue(chb_R3),
         Cth.GetControlValue(chb_R4),Cth.GetControlValue(chb_R5),Cth.GetControlValue(chb_R6),Cth.GetControlValue(chb_R7),
         ID
        ]
      ) >= 0;}
      end;
    end;
  until True;
  Q.QCommitOrRollback(Result);
end;


procedure TFrmODedtOrStdItems.VerifyBeforeSave;
var
  i, res1, res2, res3: Integer;
  NewEmptyEstimate: Boolean;
begin
  //�������� ��� �������������� ��� ���������� ������ (������ ���� ����������� ������������)
  //��������, ��� �� ������ ������������ ����� ����������� ������� ���� �� ���� ��������
  //����� ������������ � �������� �� ������ ���� � ���� ������� ������������ �����    //!!!
  //� ����� � � ���� ��� � ����� "��������� � �������������"
  if (Mode <> fDelete) and (FIdEstimateGroup > 1) and (edt_name.Text <> FNameOld) then begin
    res1 := Q.QSelectOneRow('select count(1) from or_std_items where id <> :id$i and (id_or_format_estimates = :idf$i) and name = :name$s', [ID, FIdEstimateGroup, edt_name.Text])[0];
    //res2 := Q.QSelectOneRow('select count(1) from bcad_nomencl where name = :name$s', [Prefix + '_' + edt_name.Text])[0];
    res3 := Q.QSelectOneRow('select count(1) from dv.nomenclatura where id_nomencltype = 0 and name = :name$s', [FPrefix + '_' + edt_name.Text])[0];
    if res1 + res2 + res3 > 0 then begin
      MyWarningMessage(S.IIf(res1 > 0, '����� ������������ ��� ���������� � ���� ������ ����������� ������� �����!'#13#10, '') +
          //S.IIf(res2 > 0, '����� ������������ (� ������ ��������) ��� ���������� � ����������� ������� ������� �����!'#13#10, '') +
        S.IIf(res3 > 0, '����� ������������ (� ������ ��������) ��� ���� � ��� ����� ������������ ���� "��������� � �������������"!'#13#10, '') + #13#10'������ �� ����� ���� ���������!');
      HasError := True;
      Exit;
    end;
  end;
  if (Mode = fEdit) and (chb_Wo_Estimate.Checked) then begin
    NewEmptyEstimate := Q.QSelectOneRow('select count(1) from estimates where id_std_item = :id$i and isempty = 0', [id])[0] > 0;
    if NewEmptyEstimate then
      if MyQuestionMessage('��� ����� ������� ������ ��� "��� �����", �� ������ � ���� ��� ���������� �������� �����.'#13#10'��� ����� �������.'#13#10'����������?') <> mrYes then begin
        HasError := True;
        Exit;
      end;
  end;
end;


procedure TFrmODedtOrStdItems.SetRoute;
var
  i: Integer;
begin
  if Mode in [fDelete, fView] then
    Exit;
  if (Cth.GetControlValue(chb_Wo_Estimate) = 1) or (Cth.GetControlValue(chb_R0) = 1) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].Name, 1, 6) = 'chb_r_' then begin
        TDBCheckBoxEh(Components[i]).Checked := False;
        TDBCheckBoxEh(Components[i]).Enabled := False;
      end;
  if (Cth.GetControlValue(chb_Wo_Estimate) = 0) and (Cth.GetControlValue(chb_R0) = 0) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].Name, 1, 6) = 'chb_r_' then begin
        TDBCheckBoxEh(Components[i]).Enabled := True;
      end;
  FIsRouteChanged := True;
end;




end.


