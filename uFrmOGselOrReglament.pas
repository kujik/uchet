{

uses
  Windows, Messages, Variants, Types, RegularExpressions, Math, DateUtils, IOUtils, Clipbrd,   //basic
  Db, ADODB, //db
  Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, StdCtrls, Buttons, Menus, //vcl basic
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, PrnDbgEh, DBCtrlsEh, DynVarsEh, MemTableDataEh, DataDriverEh, ADODataDriverEh, MemTableEh, DBAxisGridsEh, DBGridEh, GridsEh, //ehlib
  uData, uSettings, uSys, uForms, uDBOra, uString, uMessages, uWindows, uPrintReport, uLabelColors, uFrmBasicInput, uFrDBGridEh, uFrMyPanelCaption, uFrmBasicMdi, //my
  uFrmBasicEditabelGrid //parentform
  ;


}




{
Автоматический выбора регламента зазака для данного типа заказа.
В гриде отображаются свойства, доступные для данного типа, они выбираются отметкой чекбоксами,
на основании выбранных свойств подбирается регламент с наибольшим сроком выполнения.

Диалог вызывается из формы редактирования заказа.
}

unit uFrmOGselOrReglament;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, StdCtrls, Buttons, Menus, //basic
  ToolCtrlsEh, DBGridEhToolCtrls, PrnDbgEh, DBCtrlsEh, MemTableDataEh, DataDriverEh, DBAxisGridsEh, DBGridEh, GridsEh, //ehlib
  uData, uString, uLabelColors, uFrDBGridEh,  //my
  uFrmBasicEditabelGrid //parentform
  ;

type
  TFrmOGselOrReglament = class(TFrmBasicEditabelGrid)
    lblName: TLabel;
    lblDeadline: TLabel;
  private
    FReglaments: TVarDynArray2;
    FReglament: Integer;
    FProperties: string;
    function  PrepareForm: Boolean; override;
    procedure VerifyBeforeSave; override;
    procedure FindReglament;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
  public
  end;

var
  FrmOGselOrReglament: TFrmOGselOrReglament;

implementation

uses
  SysUtils, Variants, Types, Math, Clipbrd,   //basi
  uForms, uDBOra, uMessages, uWindows, uFrmBasicMdi   //my basic
  ;

{$R *.dfm}

function TFrmOGselOrReglament.PrepareForm: Boolean;
begin
  Caption := 'Свойства заказа';
  Frg1.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','_№','80'],
    ['name$s','Свойство заказа','300;w;h'],
    ['used$i','X','40','chb','e']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.SetInitData('select id, pos, name, 0 as used from v_order_properties_for_type where id_type = :id$i and used = 1 order by pos', [ID]);
//  Frg1.EditOptions.;
  Result := inherited;
  for var i: Integer := 0 to Frg1.GetCount(False) - 1 do
    if S.InCommaStr(Frg1.GetValueS('id', i, False), AddParam.AsString) then
      Frg1.SetValue('used', i, False, 1);
  FReglaments := Q.QLoadToVarDynArray2('select id, name, ids_properties, deadline, ids_types from order_reglaments order by deadline desc', []);
  FindReglament;
end;

procedure TFrmOGselOrReglament.VerifyBeforeSave;
begin
  FFormResult.DataA := [[FReglaments[FReglament][0], FProperties, FReglaments[FReglament][3]]];
end;

procedure TFrmOGselOrReglament.FindReglament;
var
  i, j: Integer;
begin
  FProperties := '';
  FReglament := -1;
  for i := 0 to High(FReglaments) do
    for j := 0 to Frg1.GetCount(False) - 1 do
      if (Frg1.GetValueI('used', j, False) = 1) then begin
        S.ConcatStP(FProperties, Frg1.GetValueS('id', j, False), ',');
        if (FReglament = -1) and S.InCommaStr(Frg1.GetValueS('id', j, False), FReglaments[i][2].AsString) and S.InCommaStr(ID, FReglaments[i][4].AsString) then begin
          FReglament := i;
          Break;
        end;
      end;
  if FReglament = -1 then begin
    lblName.Caption := 'Регламент не найден!';
    lblName.Font.Color :=  clRed;
    lblDeadline.Caption := '';
  end
  else begin
    lblName.Caption := FReglaments[FReglament][1];
    lblName.Font.Color :=  clBlack;
    lblDeadline.Caption := IntToStr(FReglaments[FReglament][3]);
  end;
  Frg1.SetState(null, FReglament = -1, S.IIfStr(FReglament = -1, 'Регламент для этого набора свойств не найден!'));
end;

procedure TFrmOGselOrReglament.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Fr.SetValue('used', Value);
  Handled := True;
  FindReglament;
end;


end.
