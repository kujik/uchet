{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{                 LaObjectTreeViewForms                 }
{                                                       }
{    Copyright (c) 2022-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}

unit LaObjectTreeViewForms;

interface

uses
  Messages, SysUtils, Variants, Classes, Graphics, Types,
  {$IFDEF FPC}
    DBGridEh,
  {$ELSE}
    DBGridEh,
  {$ENDIF}
  Controls, Forms, Dialogs, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, GridsEh, DBAxisGridsEh,
  LaObjectsEh, ObjectInspectorEh,
  StdCtrls,
{$IFDEF EH_LIB_13} Rtti, {$ENDIF} 
  ExtCtrls, MemTableDataEh, DB, MemTableEh;

type
  TLaObjectTreeViewForm = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    DBGridEh1: TDBGridEh;
    ObjInsPanel: TPanel;
    Button1: TButton;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    bTest: TButton;
    procedure FormCreate(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure Button1Click(Sender: TObject);
  private
    FLaHost: TLaHost;
    FObjIns: TObjectInspectorEh;
    procedure SetLaHost(const Value: TLaHost);
    procedure FillLaObjectTreeViewForParent(ParentId: Int64; ALaObject: TLaObjectEh);
  public
    procedure FillLaObjectTreeView;

    property LaHost: TLaHost read FLaHost write SetLaHost;
  end;

var
  LaObjectTreeViewForm: TLaObjectTreeViewForm;

procedure ShowLaObjectTreeViewForm(LaHost: TLaHost; FormBounds: TRect;
  NewForm: Boolean = False);

implementation

{$R *.dfm}

procedure ShowLaObjectTreeViewForm(LaHost: TLaHost; FormBounds: TRect;
  NewForm: Boolean = False);
var
  Form: TLaObjectTreeViewForm;
begin
  if NewForm or (LaObjectTreeViewForm = nil) then
  begin
    Form := TLaObjectTreeViewForm.Create(Application);
    if not NewForm then
      LaObjectTreeViewForm := Form;
  end else
  begin
    Form := LaObjectTreeViewForm;
  end;

  Form.LaHost := LaHost;

  Form.SetBounds(FormBounds.Left, FormBounds.Top,
    FormBounds.Right-FormBounds.Left, FormBounds.Bottom-FormBounds.Top);
  Form.Show;
end;

{ TLaObjectTreeViewForm }

procedure TLaObjectTreeViewForm.FillLaObjectTreeView;
var
  LaObject: TLaObjectEh;
begin
  MemTableEh1.DisableControls;
  try
    if (LaHost <> nil)
      then LaObject := LaHost.LaObject
      else LaObject := nil;

    MemTableEh1.EmptyTable;
    if (LaObject = nil) then Exit;

    FillLaObjectTreeViewForParent(-1, LaObject);
  finally
    MemTableEh1.First;
    MemTableEh1.EnableControls;
  end;
end;

procedure TLaObjectTreeViewForm.FillLaObjectTreeViewForParent(ParentId: Int64; ALaObject: TLaObjectEh);
var
  I: Integer;
  DisplayName: String;
  RefObjectItfs: IRefObjectInterface;
  LaChild: TLaObjectEh;
  RecId: Int64;
begin

  DisplayName := ALaObject.ClassName;
  RefObjectItfs := TInterfacedRefObject.Create(ALaObject, False);

  MemTableEh1.Append;
  MemTableEh1.Fields[1].Value := ParentId;
  MemTableEh1.Fields[2].Value := DisplayName;
  MemTableEh1.Fields[3].Value := ''; 
  MemTableEh1.Fields[4].Value := RefObjectItfs;
  MemTableEh1.Post;
{$IFDEF EH_LIB_13} 
  RecId := MemTableEh1.Fields[0].AsLargeInt;
{$ELSE}
  RecId := MemTableEh1.Fields[0].AsInteger;
{$ENDIF}

  for I := 0 to ALaObject.ChildrenCount - 1 do
  begin
    LaChild := ALaObject.Children[I];
    FillLaObjectTreeViewForParent(RecId, LaChild);
  end;
end;

procedure TLaObjectTreeViewForm.FormCreate(Sender: TObject);
begin
  FObjIns := TObjectInspectorEh.Create(Self);
  FObjIns.Parent := ObjInsPanel;
  FObjIns.Align := TAlign.alClient;
  FObjIns.Flat := True;
  FObjIns.ParentFont := True;
  FObjIns.LabelColWidth := 100;
  FObjIns.Options := [goFixedVertLineEh, goVertLineEh, goEditingEh, goAlwaysShowEditorEh];
  FObjIns.Name := 'ObjectInspectorEh';
  FObjIns.PropDataAccessWay := TPropDataAccessWayEh.Rtti;
end;

procedure TLaObjectTreeViewForm.SetLaHost(const Value: TLaHost);
begin
  if (FLaHost <> Value) then
  begin
    FLaHost := Value;
    FillLaObjectTreeView;
  end;
end;

procedure TLaObjectTreeViewForm.Button1Click(Sender: TObject);
var
  ALaHost: TLaHost;
begin
  ALaHost := LaHost;
  LaHost := nil;
  LaHost := ALaHost;
end;

procedure TLaObjectTreeViewForm.DataSource1DataChange(Sender: TObject;
  Field: TField);
var
  Val: Variant;
  RefObj: IRefObjectInterface;
begin
  Val := MemTableEh1.Fields[4].Value;
  if (not VarIsNull(Val)) then
  begin
    RefObj := IRefObjectInterface(IInterface(Val));
    FObjIns.Component := RefObj.GetObject;
    if (LaHost <> nil) then
      LaHost.DesignBacklightObject := TLaObjectEh(RefObj.GetObject);
  end;
end;

end.
