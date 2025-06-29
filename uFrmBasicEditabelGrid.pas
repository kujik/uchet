{
������� ����� ��� �������������� �����.
� �������� ����������� ������ ���� ��������� ��������� ����� (��� ������� ���� � ������ ��������)
Frg1.Opt.SetGridOperations('uaid');
Frg1.SetInitData('*',[]) ��� Frg1.SetInitData(va2, '')
��� ����� ������������� PrepareForm, ��� ����� ������������� � ��������� �����.

������ �� ���� ������ �������������� � ������� ����� �����

�� ��������� ������� � ����� ���������� ������ �������� ������ �������, �
�������������� ������ �������� ���������� ������� �������������� �����.

����� �������� (���������) �������-����������, � ����� � ������� ������ ��������� ������� �����.

������� ������ �������� ���� � ��� ��� �� ������ ����������.

���������� ������ ������ ������ �������������� � �������� ��������� ����� ���������� ������� Save;

}
unit uFrmBasicEditabelGrid;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uLabelColors
  ;

type
  TFrmBasicEditabelGrid = class(TFrmBasicGrid2)
  private
    //��������� ������������� ��������� �����
    procedure PrepareTestGrid;
  protected
    //������ ������� ���������� ��� ������� � ������� ������
    FTitleTexts: TVarDynArray;
    //������ �����������, ��� ����������� ��������� ����� � �����
    function  PrepareForm: Boolean; override;
    //����� ��������� ��� �������� ����� �������������� �����;
    //�� ��������� ��� ������������� ������ � ������ ����� �������������� ���������� ���������
    function  PrepareFormAdd: Boolean; virtual;
    //���������� �� ��. ����� ��������� ��� �������� � ��������� ��������� �� ������/������� � ������ ��������
    //�� ��������� ���������� ����������� �������� myFrDBGridEh
    procedure VerifyBeforeSave; override;
  public
  end;

const
  MY_BASICEDITABELGRID_TEST_ID = -9876543210000;

var
  FrmBasicEditabelGrid: TFrmBasicEditabelGrid;

implementation


function TFrmBasicEditabelGrid.PrepareForm: Boolean;
var
  i, j: integer;
  va: TVarDynArray;
  FldDef: TVarDynArray2;
begin
  Result := False;
  FOpt.DlgPanelStyle := dpsBottomRight;
  i := Cth.CreateLabelColors(pnlTop, FTitleTexts);
  if i > 0 then
    pnlTop.Height := i;
  pnlTop.Visible := pnlTop.ControlCount > 0;
  if not PrepareFormAdd then
    Exit;
  Result := Inherited;
  Frg1.IsTableCorrect;
end;

function TFrmBasicEditabelGrid.PrepareFormAdd: Boolean;
begin
  Frg1.Opt.SetButtons(4, [[mbtInsertRow, alopInsertEh in Frg1.Opt.AllowedOperations], [mbtAddRow, alopAppendEh in Frg1.Opt.AllowedOperations],
    [mbtDeleteRow, alopDeleteEh in Frg1.Opt.AllowedOperations],[mbtDividorA],[-4]], cbttBSmall, pnlFrmBtnsR
  );
  Result := True;
end;


procedure TFrmBasicEditabelGrid.VerifyBeforeSave;
begin
  Frg1.IsTableCorrect;
end;

procedure TFrmBasicEditabelGrid.PrepareTestGrid;
//��������� ������������� ��������� �����
begin
  if ID <> MY_BASICEDITABELGRID_TEST_ID then
    Exit;
  Mode := fEdit;
  Frg1.Opt.SetFields([
    ['null as i$i','_i','40'],
    ['id$i','id','100'],
    ['name$s','������','300','e=0:15'],
    ['null as name2$s','Name','100','e=1:20::T']
  ]);
  Frg1.Opt.SetGridOperations('uaid');
  Frg1.Opt.SetTable('bcad_groups');
  Frg1.SetInitData('*',[]);
//  Frg1.EditOptions.;}
end;


{$R *.dfm}

end.
