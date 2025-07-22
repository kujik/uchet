{
выбор пользователей (одного или нескольких, в заваисмости от параметра) из списка.
возвращаетс€ айди пользователей через зап€тую и имена через точку с зап€той
поддерживаетс€ копирование отметки в буфер и вставка из буфера
}

unit uFrmXGsesUsersChoice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid, uLabelColors
  ;

type
  TFrmXGsesUsersChoice = class(TFrmBasicEditabelGrid)
  private
    function  PrepareForm: Boolean; override;
    function  PrepareFormAdd: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure SetButtonsState;
  public
    class function ShowDialog(AOwner: TComponent; AMultiSelect: Boolean; var AIds: string; var ANames: string): Integer;
  end;

var
  FrmXGsesUsersChoice: TFrmXGsesUsersChoice;

procedure UsersChoiceCellButtonClick(Sender: TObject; var Handled: Boolean);


implementation

var
  GUsersInClipboard : TVarDynArray;

{$R *.dfm}

function TFrmXGsesUsersChoice.PrepareForm: Boolean;
begin
  Caption:='¬ыбор пользователей';
  Frg1.Options := FrDBGridOptionDef + [myogIndicatorCheckBoxes, myogPanelFilter, myogSorting];
  if AddParam[0] = True then
    Frg1.Options := Frg1.Options + [myogMultiselect];
  Mode := fEdit;
  Frg1.Opt.SetFields([
    ['id$i','_id','100'],
    ['name$s','ѕользователь','300;w;h'],
    ['comm$s','ѕримечание','220;w']
  ]);
  Frg1.SetInitData('select id, name, comm from v_users where id > 0 order by name',[]);
  Result := inherited;
  if Length(AddParam[1]) > 0 then
    Frg1.SetIndicatorCheckBoxesByField('id', A.Explode(S.NSt(AddParam[1]), ','));
  SetButtonsState;
end;

function TFrmXGsesUsersChoice.PrepareFormAdd: Boolean;
begin
  Frg1.Opt.SetButtons(4, [[mbtToClipboard], [mbtFromClipboard] ,[mbtDividorA], [mbtSpace, True, True, 4]], cbttBSmall, pnlFrmBtnsR);
  Result := True;
end;

procedure TFrmXGsesUsersChoice.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtToClipboard then begin
    GUsersInClipboard := A.VarDynArray2ColToVD1(Gh.GetGridArrayOfChecked(Frg1.DbGridEh1, -1), 0);
    SetButtonsState;
  end
  else if Tag = mbtFromClipboard then begin
    Gh.SetGridIndicatorSelection(Frg1.DbGridEh1, -1);
    Frg1.SetIndicatorCheckBoxesByField('id', GUsersInClipboard)
  end
  else
    inherited;
end;

procedure TFrmXGsesUsersChoice.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
  SetButtonsState;
end;

procedure TFrmXGsesUsersChoice.SetButtonsState;
begin
  Frg1.SetBtnNameEnabled(mbtFromclipboard, null, Length(GUsersInClipboard) > 0);
  Cth.SetBtnAndMenuEnabled(Self, nil, mbtFromclipboard, Length(GUsersInClipboard) > 0, '');
end;

procedure UsersChoiceCellButtonClick(Sender: TObject; var Handled: Boolean);
begin
end;


class function TFrmXGsesUsersChoice.ShowDialog(AOwner: TComponent; AMultiSelect: Boolean; var AIds: string; var ANames: string): Integer;
var
  F: TFrmXGsesUsersChoice;
  va2: TVarDynArray2;
begin
  F:= Create(AOwner, myfrm_Dlg_UsersChoice, [myfoModal, myfoSizeable, myfoDialog], FEdit, null, VarArrayOf([AMultiSelect, AIds]), []);
  Result := TFrmXGsesUsersChoice(F).ModalResult;
  if Result = mrOk then begin
    va2 := Gh.GetGridArrayOfChecked(TFrmXGsesUsersChoice(F).Frg1.DbGridEh1, -1);
    AIds := A.Implode(A.VarDynArray2ColToVD1(va2, 0), ',');
    ANames := A.Implode(A.VarDynArray2ColToVD1(va2, 1), ';');
  end;
  AfterFormClose(F);
end;



end.
