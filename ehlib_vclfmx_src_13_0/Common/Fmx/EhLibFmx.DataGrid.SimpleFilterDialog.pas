{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{         EhLibFmx.DataGrid.SimpleFilterDialog          }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.SimpleFilterDialog;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Rtti,
  EhLibUtils, DBUtilsEh,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.ListBox,
  FMX.Objects,
  FMX.Controls.Presentation,

  EhLibFmx.DataGrid.Columns
  ;

type
  TDataGridEhSimpleFilterDialog = class(TForm)
    Label1: TLabel;
    Line1: TLine;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    ComboBox2: TComboBox;
    Edit2: TEdit;
    rbAnd: TRadioButton;
    rbOr: TRadioButton;
    Label2: TLabel;
    Label3: TLabel;
    bOk: TButton;
    bCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
  protected
    procedure ResourceLanguageChanged; virtual;
  public
    FieldValueList: IMemTableDataFieldValueListEh;
    Column: TDataGridBaseColumnEh;
    procedure Init;
    procedure InitSignComboBox(ComboBox: TComboBox);
    procedure FillDialogFromColumnFilter(Expression: TSTValueFilterExpressionEh);
    procedure FillDialogFromColumnFilter1(Operator: TSTFilterOperatorEh; Operand: TValue; OperatorComboBox: TComboBox; OperandTextBox: TEdit);
    procedure SetFilterFromDialog;
    procedure SetFilterFromDialog1(out FilterString: String; OperatorComboBox: TComboBox; OperandTextBox: TEdit);

    procedure FillColumnFilter1FromDialog(OperatorComboBox: TComboBox; OperandTextBox: TEdit; out AOperator: TSTFilterOperatorEh; out Operand: TValue);
  end;

var
  DataGridEhSimpleFilterDialog: TDataGridEhSimpleFilterDialog;

function StartDataGridColumnFilterDialogEh(Column: TDataGridBaseColumnEh): Boolean;

implementation

{$R *.fmx}

uses EhLibLangConsts;

{
0  ''
1  '='        
2  '<>'       
3  '>'        
4  '>='       
5  '<'        
6  '<='       
7  '%~'       
8  'Not %~'   
9  '~%'       
10 'Not ~%'   
11 '%~%'      
12 'Not %~%'  
13 '~'        
14 'Not ~'    
15 'In'       
16 'Not In'   
17 'Null'     
18 'Not Null' 
}

function StartDataGridColumnFilterDialogEh(Column: TDataGridBaseColumnEh): Boolean;
begin
  if DataGridEhSimpleFilterDialog = nil then
    DataGridEhSimpleFilterDialog := TDataGridEhSimpleFilterDialog.Create(Application);

  DataGridEhSimpleFilterDialog.Column := Column;
  DataGridEhSimpleFilterDialog.Init;
  Result := False;
  if DataGridEhSimpleFilterDialog.ShowModal = mrOk then
    Result := True;
end;

procedure TDataGridEhSimpleFilterDialog.FormCreate(Sender: TObject);
begin
  ResourceLanguageChanged;
end;

procedure TDataGridEhSimpleFilterDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := False;
  if ModalResult = mrOk then
    SetFilterFromDialog;
  CanClose := True;
end;

procedure TDataGridEhSimpleFilterDialog.Init;
begin
  InitSignComboBox(ComboBox1);
  InitSignComboBox(ComboBox2);
  FillDialogFromColumnFilter(Column.Title.FilterItem.Expression);
end;

procedure TDataGridEhSimpleFilterDialog.InitSignComboBox(ComboBox: TComboBox);
var
  CanLike: Boolean;
  CanCheckForGreaterLess: Boolean;
begin
  CanLike := True;
  CanCheckForGreaterLess := True;


  ComboBox.Items.Clear;
  ComboBox.Items.AddObject('',                 __TObject(0));
  ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_equals,           __TObject(1));
  ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_does_not_equal,   __TObject(2));

  if CanCheckForGreaterLess then
  begin
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_is_greater_than,   __TObject(3));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_is_greater_than_or_equal_to, __TObject(4));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_is_less_than,     __TObject(5));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_is_less_than_or_equal_to, __TObject(6));
  end;

  if CanLike then
  begin
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_begins_with,      __TObject(7));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_does_not_begin_with, __TObject(8));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_ends_with,        __TObject(9));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_does_not_end_with,__TObject(10));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_contains,         __TObject(11));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_does_not_contain, __TObject(12));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_like,             __TObject(13));
    ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_not_like,         __TObject(14));
  end;

  ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_in_list,          __TObject(15));
  ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_not_in_list,      __TObject(16));
  ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_is_blank,         __TObject(17));
  ComboBox.Items.AddObject(EhLibLanguageConsts.SimpFilter_is_not_blank,     __TObject(18));

  ComboBox.DropDownCount := ComboBox.Items.Count;
end;

procedure TDataGridEhSimpleFilterDialog.FillDialogFromColumnFilter(Expression: TSTValueFilterExpressionEh);
begin
  FillDialogFromColumnFilter1(
    Expression.Operator1, Expression.Operand1,
    ComboBox1, Edit1
  );

  rbOr.IsChecked := (Expression.Relation = foOR);
  rbAnd.IsChecked := not rbOr.IsChecked;

  FillDialogFromColumnFilter1(
    Expression.Operator2, Expression.Operand2,
    ComboBox2, Edit2
  );
end;

procedure TDataGridEhSimpleFilterDialog.FillDialogFromColumnFilter1(
  Operator: TSTFilterOperatorEh; Operand: TValue;
  OperatorComboBox: TComboBox; OperandTextBox: TEdit);
var
  StartMultiChar, EndMultiChar: Boolean;
begin
  StartMultiChar := False;
  EndMultiChar := False;
  OperandTextBox.Text := Column.Title.FilterItem.GetOperandAsString(Operator, Operand);

  case Operator of
    foNon:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(0));
    foEqual:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(1));
    foNotEqual:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(2));
    foGreaterThan:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(3));
    foLessThan:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(5));
    foGreaterOrEqual:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(4));
    foLessOrEqual:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(6));
    foLike:
      begin
        OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(13));
        if (CharAtPos(OperandTextBox.Text, 1) = '%') and
          (CharAtPos(OperandTextBox.Text, 2) <> '%')
        then
          StartMultiChar := True;
        if (CharAtPos(OperandTextBox.Text, Length(OperandTextBox.Text)) = '%') and
          (CharAtPos(OperandTextBox.Text, Length(OperandTextBox.Text)-1) <> '%')
        then
          EndMultiChar := True;
        if StartMultiChar and EndMultiChar then
        begin
          OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(11));
          OperandTextBox.Text := Copy(OperandTextBox.Text, 2, Length(OperandTextBox.Text)-2);
        end else if StartMultiChar then
        begin
          OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(9));
          OperandTextBox.Text := Copy(OperandTextBox.Text, 2, Length(OperandTextBox.Text)-1);
        end else if EndMultiChar then
        begin
          OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(7));
          OperandTextBox.Text := Copy(OperandTextBox.Text, 1, Length(OperandTextBox.Text)-1);
        end;
      end;
    foNotLike:
      begin
        OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(14));
        if (CharAtPos(OperandTextBox.Text, 1) = '%') and
          (CharAtPos(OperandTextBox.Text, 2) <> '%')
        then
          StartMultiChar := True;
        if (CharAtPos(OperandTextBox.Text, Length(OperandTextBox.Text)) = '%') and
          (CharAtPos(OperandTextBox.Text, Length(OperandTextBox.Text)-1) <> '%')
        then
          EndMultiChar := True;
        if StartMultiChar and EndMultiChar then
        begin
          OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(12));
          OperandTextBox.Text := Copy(OperandTextBox.Text, 2, Length(OperandTextBox.Text)-2);
        end else if StartMultiChar then
        begin
          OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(10));
          OperandTextBox.Text := Copy(OperandTextBox.Text, 2, Length(OperandTextBox.Text)-1);
        end else if EndMultiChar then
        begin
          OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(8));
          OperandTextBox.Text := Copy(OperandTextBox.Text, 1, Length(OperandTextBox.Text)-1);
        end;
      end;
    foIn:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(15));
    foNotIn:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(16));
    foNull:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(17));
    foNotNull:
      OperatorComboBox.ItemIndex := OperatorComboBox.Items.IndexOfObject(__TObject(18));
  end;
end;

procedure TDataGridEhSimpleFilterDialog.FillColumnFilter1FromDialog(
  OperatorComboBox: TComboBox; OperandTextBox: TEdit;
  out AOperator: TSTFilterOperatorEh; out Operand: TValue);
var
  Oper: Integer;
  SValue: String;
begin
  if OperatorComboBox.ItemIndex < 0 then
    OperatorComboBox.ItemIndex := 0;

  Oper := Integer(OperatorComboBox.Items.Objects[OperatorComboBox.ItemIndex]);
  case Oper of
    0: AOperator := foNon;
    1: AOperator := foEqual;  
    2: AOperator := foNotEqual; 

    3: AOperator := foGreaterThan;  
    4: AOperator := foGreaterOrEqual; 
    5: AOperator := foLessThan;  
    6: AOperator := foLessOrEqual; 

    7: AOperator := foLike;  
    8: AOperator := foNotLike; 
    9: AOperator := foLike;  
    10: AOperator := foNotLike;  
    11: AOperator := foLike;   
    12: AOperator := foNotLike;  
    13: AOperator := foLike;   
    14: AOperator := foNotLike;  

    15: AOperator := foIn;  
    16: AOperator := foNotIn; 

    17: AOperator := foNull;  
    18: AOperator := foNotNull; 
  end;

  SValue := OperandTextBox.Text;

  if Oper in [7,8,11,12] then
    SValue := SValue + '%';
  if Oper in [9,10,11,12] then
    SValue := '%' + SValue;

  Operand := Column.Title.FilterItem.ParseOperandFromString(AOperator, SValue);
end;

procedure TDataGridEhSimpleFilterDialog.SetFilterFromDialog;
var
  AOperator1: TSTFilterOperatorEh;
  Operand1: TValue;
  Relation: TSTFilterOperatorEh;
  AOperator2: TSTFilterOperatorEh;
  Operand2: TValue;
begin
  FillColumnFilter1FromDialog(ComboBox1, Edit1, AOperator1, Operand1);
  FillColumnFilter1FromDialog(ComboBox2, Edit2, AOperator2, Operand2);

  if AOperator2 = foNon then
    Relation := foNon
  else if rbOr.IsChecked then
    Relation := foOR
  else
    Relation := foAND;

  Column.Title.FilterItem.SetExpression(AOperator1, Operand1, Relation, AOperator2, Operand2);

end;

procedure TDataGridEhSimpleFilterDialog.SetFilterFromDialog1(
  out FilterString: String; OperatorComboBox: TComboBox;
  OperandTextBox: TEdit);
var
  Oper: Integer;
begin
  FilterString := '';
  if OperatorComboBox.ItemIndex < 0 then
    OperatorComboBox.ItemIndex := 0;
  Oper := Integer(OperatorComboBox.Items.Objects[OperatorComboBox.ItemIndex]);
  case Oper of
    0: FilterString := '';
    1: FilterString := '=';  
    2: FilterString := '<>'; 
    3: FilterString := '>';  
    4: FilterString := '>='; 
    5: FilterString := '<';  
    6: FilterString := '<='; 

    7: FilterString := '~';  
    8: FilterString := '!~'; 
    9: FilterString := '~';  
    10: FilterString := '!~';  
    11: FilterString := '~';   
    12: FilterString := '!~';  
    13: FilterString := '~';   
    14: FilterString := '!~';  

    15: FilterString := 'in';  
    16: FilterString := '!in'; 

    17: FilterString := '=Null';  
    18: FilterString := '<>Null'; 
  end;

end;

procedure TDataGridEhSimpleFilterDialog.ResourceLanguageChanged;
begin
  Caption := EhLibLanguageConsts.DBGridEhSimpleFilterDialog_Caption; 
  Label1.Text := EhLibLanguageConsts.DBGridEhSimpleFilterDialog_ShowRecordsWhere; 
  Label2.Text:= EhLibLanguageConsts.DBGridEhSimpleFilterDialog_OneCharWildcardInfo; 
  Label3.Text:= EhLibLanguageConsts.DBGridEhSimpleFilterDialog_SeveralCharsWildcardInfo; 
  rbOr.Text:= EhLibLanguageConsts.DBGridEhSimpleFilterDialog_Or_Caption; 
  rbAnd.Text:= EhLibLanguageConsts.DBGridEhSimpleFilterDialog_And_Caption; 

  bOk.Text:= EhLibLanguageConsts.OKButtonEh;
  bCancel.Text := EhLibLanguageConsts.CancelButtonEh;
end;

end.
