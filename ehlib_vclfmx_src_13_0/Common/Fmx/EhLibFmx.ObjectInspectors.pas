{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{              EhLibFmx.ObjectInspectors                }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.ObjectInspectors;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  FMX.Platform, System.Variants, FMX.Layouts, FMX.Objects,
  System.Generics.Collections, System.Generics.Defaults,
  MemTreeEh, System.UIConsts,
  System.RTTI, System.TypInfo, System.StrUtils,
  EhLibUtils,
  EhLib.TableLink.TypedLists,
  EhLibFmx.Utils,
  EhLibFmx.ToolControls,
  EhLibFmx.Grid.InplaceEditors,
  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,
  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.Styles,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.DataAxisGrids,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.DataCells,
  EhLibFmx.DataAxisGrid.ComboDataCells,
  EhLibFmx.DataGrids;

type
  TPropTreeListEh = class;
  TPropTreeNodeEh = class;

  TRttiPropListArray = array of TRttiProperty;
  TObjectMemberKind = (omkProperty, omkField);
  TObjectMemberKinds = set of TObjectMemberKind;

  TTreeNodeExpandedStateChangedEventEh = procedure (Sender: TPropTreeListEh; PropTreeNode: TPropTreeNodeEh) of object;

{ TPropTreeNodeEh }

  TPropTreeNodeEh = class(TBaseTreeNodeEh)
  private
    FColorList: TStrings;
    FInstance: TObject;
    FIsComponentSubprops: Boolean;
    FIsSetValue: Boolean;
    FPropInfo: PPropInfo;
    FRttiProp: TRttiMember;
    FPropName: String;
    FPropStrValue: String;
    FSetIndex: Integer;
    FChildrenLoaded: Boolean;

    function GetItem(const Index: Integer): TPropTreeNodeEh; reintroduce;
    function GetNodeOwner: TPropTreeListEh;
    function GetNodeParent: TPropTreeNodeEh;
    function GetVisibleItem(const Index: Integer): TPropTreeNodeEh;

    procedure SetNodeParent(const Value: TPropTreeNodeEh);
    function GetRttiType: TRttiType;
    function GetTypeInfo: PTypeInfo;
    procedure SetPropStrValue(const Value: String);

  protected
    procedure GetColorStrProc(const S: string);

  public
    constructor Create; override;
    destructor Destroy; override;

    function GetFontStyle: TFontStyles;
    function GetEditStyle: TEditStyle;

    procedure Collapse;
    procedure Expand;
    procedure GetListValues(Items: TStrings);
    procedure RefreshValue;
    procedure SetValueAsString(const SValue: String);
    procedure ExpandedStateChanged();

    property Expanded;
    property HasChildren;
    property Instance: TObject read FInstance write FInstance;
    property IsComponentSubprops: Boolean read FIsComponentSubprops;
    property IsSetValue: Boolean read FIsSetValue write FIsSetValue;
    property Items[const Index: Integer]: TPropTreeNodeEh read GetItem; default;
    property Owner: TPropTreeListEh read GetNodeOwner;
    property Parent: TPropTreeNodeEh read GetNodeParent write SetNodeParent;
    property RttiProp: TRttiMember read FRttiProp write FRttiProp;
    property PropInfo: PPropInfo read FPropInfo write FPropInfo;
    property SetIndex: Integer read FSetIndex write FSetIndex;
    property RttiType: TRttiType read GetRttiType;
    property TypeInfo: PTypeInfo read GetTypeInfo;
    property VisibleItem[const Index: Integer]: TPropTreeNodeEh read GetVisibleItem;
    property ChildrenLoaded: Boolean read FChildrenLoaded write FChildrenLoaded;
  published
    property PropName: String read FPropName write FPropName;
    property PropStrValue: String read FPropStrValue write SetPropStrValue;
  end;

  TPropTreeNodeClassEh = class of TPropTreeNodeEh;

{ TPropTreeListEh }

  TPropTreeListEh = class(TTreeListEh)
  private
    FVisibleExpandedItems: TObjectList;
    FVisibleItemsObsolete: Boolean;
    FOnVisibleListChanged: TNotifyEvent;
    FOnTreeNodeExpandedStateChanged: TTreeNodeExpandedStateChangedEventEh;
    function GetRoot: TPropTreeNodeEh;
    function GetVisibleExpandedItems: TObjectList;

  protected
    function GetVisibleCount: Integer;
    function GetVisibleExpandedItem(const Index: Integer): TPropTreeNodeEh; virtual;
    procedure VisibleListChanged;

  public
    constructor Create(ItemClass: TPropTreeNodeClassEh);
    destructor Destroy; override;

    procedure BuildVisibleItems;
    procedure VisibleItemsBecomeObsolete;
    procedure RefreshAllValues;
    procedure ExpandedStateChanged(PropTreeNode: TPropTreeNodeEh);

    property Root: TPropTreeNodeEh read GetRoot;
    property VisibleExpandedCount: Integer read GetVisibleCount;
    property VisibleExpandedItem[const Index: Integer]: TPropTreeNodeEh read GetVisibleExpandedItem; default;
    property VisibleExpandedItems: TObjectList read GetVisibleExpandedItems;
    property VisibleItemsObsolete: Boolean read FVisibleItemsObsolete;

    property OnVisibleListChanged: TNotifyEvent read FOnVisibleListChanged write FOnVisibleListChanged;
    property OnTreeNodeExpandedStateChanged: TTreeNodeExpandedStateChangedEventEh read FOnTreeNodeExpandedStateChanged write FOnTreeNodeExpandedStateChanged;

  end;

{ TDataGridObjectInspectorEh }

  TDataGridObjectInspectorEh = class(TLayout)
  private
    FObservableObject: TObject;

    FPropTreeList: TPropTreeListEh;
    FTypeKinds: TTypeKinds;
    FMemberVisibilities: TMemberVisibilities;
    FObjectMemberKinds: TObjectMemberKinds;
    FPropNameFilter: String;
    FObjInsInternalUpdating: Boolean;
    FOnCurrentChange: TDataGridEventEh;

    class function GetDefaultInspectorForm: TCustomForm; static;

    function GetComponent: TObject;
    function FilterMemberList(PropList: TArray<TRttiMember>): TArray<TRttiMember>;

    procedure SetComponent(const Value: TObject);
    procedure SetObjectMemberKind(const Value: TObjectMemberKinds);
    procedure InitNodeByObjectMember(AComponent: TObject; ANode: TPropTreeNodeEh; DataMember: TRttiMember);
    procedure SetPropNameFilter(const Value: String);
    procedure SetMemberVisibilities(const Value: TMemberVisibilities);
    procedure TreeListViewChanged(Sender: TObject);
    procedure LoadChildren(ANode: TPropTreeNodeEh);
    function GetCurrentDataRow: TDataGridDataRowEh;

  protected
    FDataGrid: TDataGridEh;
    ListTableLink: TListTableLinkEh;
    PropStrValueComboboxCellMan: TDataAxisGridComboboxCellManagerEh;

    procedure DataGridCurrentChanged(Sender: TObject; Params: TDataGridEventParamsEh);
    procedure ComponentChanged;
    procedure PropStrValueGetStyleParams(Sender: TObject; Params: TDataGridStringDataCellStyleParamsEh);
    procedure PropStrValueGetDataCellManager(Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
    procedure PropStrValueInitEditParams(Sender: TObject; Params: TDataGridDataCellInitEditParamsEh);
    procedure PropStrValueInitEditor(Sender: TObject; Params: TDataGridInitEditorParamsEh);
    procedure PropStrValueStartEdit(Sender: TObject; Params: TDataGridDataCellStartEditParamsEh);
    procedure PropStrValueSetValue(Sender: TObject; Params: TDataGridDataCellSetValueParamsEh);
    procedure PropStrValueCanModify(Sender: TObject; Params: TDataGridDataCellCanModifyParamsEh);
    procedure PropStrValueEditorDblClicked(Sender: TObject);

    procedure CreateLaPropNameControls(Sender: TObject; Params: TDataGridCreateDataCellContentParamsEh);
    procedure InitPropNameCellContent(Sender: TObject; Params: TDataGridInitDataCellContentParamsEh);
    procedure TreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);
    procedure TreeNodeExpandedStateChanged(Sender: TPropTreeListEh; PropTreeNode: TPropTreeNodeEh);
    procedure RaiseOnCurrentChange();

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetPropValueAsString(Instance: TObject; RttiProp: TRttiMember): String;

    class procedure ShowInspectorForm(Component: TObject; FormBounds: TRect; NewForm: Boolean = False);
    class property DefaultInspectorForm: TCustomForm read GetDefaultInspectorForm;

    property PropTreeList: TPropTreeListEh read FPropTreeList;
    property CurrentDataRow: TDataGridDataRowEh read GetCurrentDataRow;
    property DataGrid: TDataGridEh read FDataGrid;

  published
    property Component: TObject read GetComponent write SetComponent;
    property TypeKinds: TTypeKinds read FTypeKinds write FTypeKinds;
    property MemberVisibilities: TMemberVisibilities read FMemberVisibilities write SetMemberVisibilities;
    property ObjectMemberKinds: TObjectMemberKinds read FObjectMemberKinds write SetObjectMemberKind;
    property PropNameFilter: String read FPropNameFilter write SetPropNameFilter;

    property OnCurrentChange: TDataGridEventEh read FOnCurrentChange write FOnCurrentChange;
  end;

procedure ShowObjectInspectorForm(Component: TObject; FormBounds: TRect;
  NewForm: Boolean = False);

function GetRttiMemberListAsArray(ATypeInfo: TClass;
                                  TypeKinds: TTypeKinds = DefaultPropListTypeKinds;
                                  MemberVisibilities: TMemberVisibilities = DefaultPropListMemberVisibilities;
                                  ObjectMemberKinds: TObjectMemberKinds = [TObjectMemberKind.omkProperty]): TArray<TRttiMember>;

var
  ObjectInspectorForm: TCustomForm;

implementation

uses FMX.BehaviorManager,
     EhLibFmx.ImageReses,
     EhLibFmx.LaGridPanels,
     EhLibFmx.LaPanels,
     EhLibFmx.LaObjects,
     EhLibFmx.LaControls;

type

 { TLaPropNameCellEh }

  TLaPropNameCellEh = class(TLaLayoutPanelEh)
  private
    FTreeSignExpanded: Boolean;
    FTreeSignVisible: Boolean;
    FTreeSignImage: TImage;
    FTreeSignPanel: TLaObjectEh;
    FIndentPanel: TLaObjectEh;
    FIndentLevel: Integer;
    procedure SetTreeSignExpanded(const Value: Boolean);
    procedure SetTreeSignVisible(const Value: Boolean);
    function GetOnTreeSignMouseDown: TControlMouseButtonEventEh;
    procedure SetOnTreeSignMouseDown(const Value: TControlMouseButtonEventEh);
    procedure SetIndentLevel(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateLaPropNameControls();

    property TreeSignExpanded: Boolean read FTreeSignExpanded write SetTreeSignExpanded;
    property TreeSignVisible: Boolean read FTreeSignVisible write SetTreeSignVisible;
    property IndentLevel: Integer read FIndentLevel write SetIndentLevel;
    property OnTreeSignMouseDown: TControlMouseButtonEventEh read GetOnTreeSignMouseDown write SetOnTreeSignMouseDown;
  end;

constructor TLaPropNameCellEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateLaPropNameControls();
end;

destructor TLaPropNameCellEh.Destroy;
begin

  inherited Destroy;
end;

function TLaPropNameCellEh.GetOnTreeSignMouseDown: TControlMouseButtonEventEh;
begin
  Result := FTreeSignPanel.OnMouseDown;
end;

procedure TLaPropNameCellEh.SetOnTreeSignMouseDown(const Value: TControlMouseButtonEventEh);
begin
  FTreeSignPanel.OnMouseDown := Value;
end;

procedure TLaPropNameCellEh.SetTreeSignExpanded(const Value: Boolean);
begin
  if FTreeSignExpanded <> Value then
  begin
    FTreeSignExpanded := Value;
    if FTreeSignExpanded then
      FTreeSignImage.MultiResBitmap := EhLibImageResources.ExpanderSignExpanded
    else
      FTreeSignImage.MultiResBitmap := EhLibImageResources.ExpanderSignCollapsed;
  end;
end;

procedure TLaPropNameCellEh.SetTreeSignVisible(const Value: Boolean);
begin
  if FTreeSignVisible <> Value then
  begin
    FTreeSignVisible := Value;
    FTreeSignImage.Visible := FTreeSignVisible;
  end;
end;

procedure TLaPropNameCellEh.SetIndentLevel(const Value: Integer);
begin
  if FIndentLevel <> Value then
  begin
    FIndentLevel := Value;
    FIndentPanel.Width := FIndentLevel * 14;
  end;
end;

procedure TLaPropNameCellEh.CreateLaPropNameControls();
var
  ATextBlock: TLaTextBlockEh;
begin
  with TLaGridPanelEh.CreateWith(Self, Self) do
  begin
    Margins.Rect := TRectF.Create(1, 0, 1, 0);

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
      Value := 0;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
      Value := 0;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 0, -1);
      Width := 0;
      FIndentPanel := RefSelf;
    end;

    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 1, -1);
      Margins.Rect := TRectF.Create(2, 1, 2, 1);
      VertAlignment := TLaVertAlignmentEh.Center;
      Width := 10;
      Height := 14;
      FTreeSignPanel := RefSelf;
      HitTest := True;

      with TLaControlsGenericHelper.CreateControlWith<TImage>(RefSelf, RefSelf) do
      begin
        WrapMode := TImageWrapMode.Center;
        MultiResBitmap := nil;
        HitTest := False;
        Locked := True;
        MultiResBitmap := EhLibImageResources.ExpanderSignCollapsed;
        FTreeSignImage := TImage(RefSelf);
        FTreeSignImage.Visible := FTreeSignVisible;
      end;
    end;

    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 2, -1);

      ATextBlock := TLaTextBlockEh.CreateWith(RefSelf, RefSelf);
      ATextBlock.Padding.Rect := RectF(2, 0, 2, 1);
      ATextBlock.VertAlignment := TLaVertAlignmentEh.Center;
      ATextBlock.HorzAlignment := TLaHorzAlignmentEh.Left;
      ATextBlock.FieldName := 'PropName';
    end;
  end;
end;

var
  RttiContext: TRttiContext;

function RttiPropGetValue(RttiMember: TRttiMember; Instance: Pointer): TValue;
begin
  try
    if RttiMember is TRttiField then
    begin
      Result := TRttiField(RttiMember).GetValue(Instance);
    end
    else if RttiMember is TRttiProperty then
    begin
      if TRttiProperty(RttiMember).IsReadable then
        Result := TRttiProperty(RttiMember).GetValue(Instance)
      else
        Result := '<IsNotReadable>';
    end else
    begin
      Result := TValue.Empty;
    end;
  except on E: Exception do
    Result := TValue.Empty;
  end;
end;

function GetInstancePropValueAsString(Instance: TObject; APropInfo: PPropInfo): String; overload;
var
  APropType: PTypeInfo;
  ATypeKind: TTypeKind;

  function SetAsString(Value: Integer): String;
  var
    I: Integer;
    BaseType: PTypeInfo;
  begin
    BaseType := GetTypeData(APropType)^.CompType^;
    Result := '[';
    for I := 0 to SizeOf(TIntegerSet) * 8 - 1 do
      if I in TIntegerSet(Value) then
      begin
        if Length(Result) <> 1 then Result := Result + ',';
        Result := Result + GetEnumName(BaseType, I);
      end;
    Result := Result + ']';
  end;


  function IntPropAsString(IntType: PTypeInfo; Value: Longint): String;
  var
    Ident: string;
    IntToIdent: TIntToIdent;
  begin
    Ident := '';
    IntToIdent := FindIntToIdent(IntType);
    if Assigned(IntToIdent) and IntToIdent(Value, Ident) then
      Result := Ident
    else
      Result := IntToStr(Value);
  end;

  function CollectionAsString(Collection: TCollection): String;
  begin
    Result := '(' + Collection.ClassName + ')';
  end;

  function OrdPropAsString: String;
  var
    Value: NativeInt;
  begin
    Value := GetOrdProp(Instance, APropInfo);
    case PropType_GetKind(APropType) of
      tkInteger:
        Result := IntPropAsString(PropInfo_getPropType(APropInfo), Integer(Value));
      tkChar:
        Result := Chr(Value);
      tkSet:
        Result := SetAsString(Value);
      tkEnumeration:
        Result := GetEnumName(APropType, Value);
    end;
  end;

  function FloatPropAsString: String;
  var
    Value: Extended;
  begin
    Value := GetFloatProp(Instance, APropInfo);
    Result := FloatToStr(Value);
  end;

  function Int64PropAsString: String;
  var
    Value: Int64;
  begin
    Value := GetInt64Prop(Instance, APropInfo);
    Result := IntToStr(Value);
  end;

  function StrPropAsString: String;
  begin
{$IFDEF NEXTGEN}
    Result := String(GetStrProp(Instance, APropInfo));
{$ELSE}
    Result := String(GetWideStrProp(Instance, APropInfo));
{$ENDIF}
  end;

  function MethodPropAsString: String;
  var
    Value: TMethod;
  begin
    Value := GetMethodProp(Instance, APropInfo);
    if Value.Code = nil then
      Result := ''
    else
      Result := Instance.MethodName(Value.Code);
  end;

  function ObjectPropAsString: String;
  var
    Value: TObject;
  begin
    Value := GetObjectProp(Instance, APropInfo);
    if Value = nil
      then Result := ''
      else Result := '(' + Value.ClassName + ')';
  end;

  function VariantPropAsString: String;
  var
    Value: Variant;
  begin
    Value := GetVariantProp(Instance, APropInfo);
    Result := VarToStr(Value);
  end;

  function InterfacePropAsString: String;
  var
    Intf: IInterface;
    Value: TComponent;
    SR: IInterfaceComponentReference;
  begin
    Result := '';
    Intf := GetInterfaceProp(Instance, APropInfo);
    if Intf = nil then
    begin
      Result := '';
    end
    else if Supports(Intf, IInterfaceComponentReference, SR) then
    begin
      Value := SR.GetComponent;
      Result := Value.Name;
    end;
  end;

  function StrPropAsBool: String;
  var
    Value: Longint;
  begin
    Value := GetOrdProp(Instance, APropInfo);
    Result := BooleanIdents[Boolean(Value)];
  end;

begin

  APropType := PropInfo_getPropType(APropInfo);
  ATypeKind := PropType_getKind(APropType);
  case ATypeKind of
    tkInteger, tkChar, tkEnumeration, tkSet:
      Result := OrdPropAsString;
    tkFloat:
      Result := FloatPropAsString;
    tkString, tkLString, tkWString:
      Result := StrPropAsString;
    TTypeKind.tkClass:
      Result := ObjectPropAsString;
    tkMethod:
      Result := MethodPropAsString;
    tkVariant:
      Result := VariantPropAsString;
    tkInt64:
      Result := Int64PropAsString;
    tkInterface:
      Result := InterfacePropAsString;
    tkUString:
      Result := StrPropAsString;
  end;
end;

function GetInstancePropValueAsString(Instance: TObject; RttiProp: TRttiProperty): String; overload;
var
  AValue: TValue;
begin
  try
    AValue := RttiProp.GetValue(Instance);
    Result := AValue.ToString();
  except
    on Exception do
      Result := '<' + Exception.ClassName + '>';
  end;
end;

function StringToTValue(RttiType: TRttiType; const StrValue: string): TValue;
var
  ASetValue: Integer;
begin
  if RttiType.TypeKind = tkEnumeration then
  begin
    if SameText(RttiType.Handle^.NameFld.ToString, 'Boolean') then
    begin
      Result := SameText(StrValue, 'True');
    end
    else
    begin
      Result := TValue.FromOrdinal(RttiType.Handle, GetEnumValue(RttiType.Handle, StrValue));
    end;
  end
  else if RttiType.TypeKind = tkSet then
  begin
    ASetValue := StringToSet(RttiType.Handle, StrValue);
    TValue.Make(@ASetValue, RttiType.Handle, Result);
  end else if RttiType.TypeKind = tkInteger then
  begin
    Result := TValue.From<Integer>(StrToInt(StrValue));
  end
  else if RttiType.TypeKind = tkFloat then
  begin
    if RttiType.Handle = TypeInfo(TDateTime) then
      Result := TValue.From<TDateTime>(StrToDateTime(StrValue))
    else
      Result := TValue.From<Double>(StrToFloat(StrValue));
  end
  else if RttiType.TypeKind = tkString then
  begin
    Result := TValue.From<string>(StrValue);
  end
  else if RttiType.TypeKind = tkUString then
  begin
    Result := TValue.From<UnicodeString>(StrValue);
  end
  else if RttiType.TypeKind = tkChar then
  begin
    if Length(StrValue) <> 1 then
      raise Exception.Create('Expected single character');
    Result := TValue.From<Char>(StrValue[1]);
  end
  else
    raise Exception.CreateFmt('Unsupported type: %s', [RttiType.ToString]);
end;

type
  TObjectInspectorFormEh = class(TCustomForm)
    procedure DoClose(var Action: TCloseAction); override;
  end;

procedure TObjectInspectorFormEh.DoClose(var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  if Self = ObjectInspectorForm then
    ObjectInspectorForm := nil;
end;

procedure ShowObjectInspectorForm(Component: TObject; FormBounds: TRect; NewForm: Boolean = False);
var
  Form: TObjectInspectorFormEh;
  FObjIns: TDataGridObjectInspectorEh;
begin
  if NewForm or (ObjectInspectorForm = nil) then
  begin
    Form := TObjectInspectorFormEh.CreateNew(Application);

    FObjIns := TDataGridObjectInspectorEh.Create(Form);
    FObjIns.Parent := Form;
    FObjIns.Left := 100;
    FObjIns.Top := 100;
    FObjIns.Align :=  TAlignLayout.Client;
    FObjIns.Name := 'ObjectInspectorEh';
    if not NewForm then
      ObjectInspectorForm := Form;
  end else
    Form := TObjectInspectorFormEh(ObjectInspectorForm);

  TDataGridObjectInspectorEh(Form.FindComponent('ObjectInspectorEh')).Component := Component;
  if Component <> nil then
  begin
    if Component is TComponent then
      Form.Caption := TComponent(Component).Name + ': ';
    Form.Caption := Form.Caption + Component.ClassName
  end else
    Form.Caption := '';

  if FormBounds.IsEmpty = False then
  begin
    Form.SetBounds(FormBounds.Left, FormBounds.Top, FormBounds.Width, FormBounds.Height);
  end;

  Form.Show;
end;

const
  DefaultPropListTypeKinds =
     [
      tkInteger,
      tkChar,
      tkEnumeration,
      tkFloat,
      tkString,
      tkSet,
      tkClass,
      tkWChar,
      tkLString,
      tkWString,
      tkVariant,
      tkArray,
      tkRecord,
      tkInt64,
      tkDynArray,
      tkUString,
      tkClassRef
     ];

  DefaultPropListMemberVisibilities = [mvPublic, mvPublished];

function GetRttiMemberListAsArray(ATypeInfo: TClass;
                                  TypeKinds: TTypeKinds = DefaultPropListTypeKinds;
                                  MemberVisibilities: TMemberVisibilities = DefaultPropListMemberVisibilities;
                                  ObjectMemberKinds: TObjectMemberKinds = [TObjectMemberKind.omkProperty]): TArray<TRttiMember>;
var
  LType: TRttiType;
  AllProps: TArray<TRttiProperty>;
  AllFields: TArray<TRttiField>;
  ResultList: TList<TRttiMember>;
  ResultFinalList: TList<TRttiMember>;
  Prop: TRttiProperty;
  Field: TRttiField;
  I: Integer;
  Item: TRttiMember;
begin
  LType := RttiContext.GetType(ATypeInfo);
  ResultList := TList<TRttiMember>.Create;

  if TObjectMemberKind.omkProperty in ObjectMemberKinds then
  begin
    AllProps := LType.GetProperties();
    for Prop in AllProps do
    begin
      if (Prop.PropertyType.TypeKind in TypeKinds) and
         (Prop.Visibility in MemberVisibilities) then
      begin
        ResultList.Add(Prop);
      end;
    end;
  end;

  if TObjectMemberKind.omkField in ObjectMemberKinds then
  begin
    AllFields := LType.GetFields();
    for Field in AllFields do
    begin
      if (Field.FieldType <> nil) and
         (Field.FieldType.TypeKind in TypeKinds) and
         (Field.Visibility in MemberVisibilities) then
      begin
        ResultList.Add(Field);
      end;
    end;
  end;

  ResultList.Sort(TComparer<TRttiMember>.Construct(
    function(const ALeft, ARight: TRttiMember): Integer
    begin
      Result := AnsiStringCompare(ALeft.Name, ARight.Name);
    end
  ));

  ResultFinalList := TList<TRttiMember>.Create;

  if ResultList.Count > 0 then
  begin
    Item := ResultList[0];
    ResultFinalList.Add(Item);
  end else
  begin
    Item := nil;
  end;

  for I := 1 to ResultList.Count - 1 do
  begin
    if Item.Name = ResultList[I].Name then
      DoNothing()
    else
      ResultFinalList.Add(ResultList[I]);

    Item := ResultList[I];
  end;

  Result := ResultFinalList.ToArray;
  ResultList.Free;
  ResultFinalList.Free;
end;

function GetRttiPropListAsArray(ATypeInfo: TClass;
                                TypeKinds: TTypeKinds = DefaultPropListTypeKinds;
                                MemberVisibilities: TMemberVisibilities = DefaultPropListMemberVisibilities): TArray<TRttiProperty>;
var
  LType: TRttiType;
  AllProps: TArray<TRttiProperty>;
  ResultList: TList<TRttiProperty>;
  Prop: TRttiProperty;
begin
  LType := RttiContext.GetType(ATypeInfo);
  AllProps := LType.GetProperties();
  ResultList := TList<TRttiProperty>.Create;
  for Prop in AllProps do
  begin
    if (Prop.PropertyType.TypeKind in TypeKinds) and
       (Prop.Visibility in MemberVisibilities) then
    begin
      ResultList.Add(Prop);
    end;
  end;
  Result := ResultList.ToArray;
  ResultList.Free;
end;


function RttiPropGetDataType(RttiMember: TRttiMember): TRttiType;
begin
  if RttiMember is TRttiField then
    Result := TRttiField(RttiMember).FieldType
  else if RttiMember is TRttiProperty then
    Result := TRttiProperty(RttiMember).PropertyType
  else
    Result := nil;
end;

function GetInstancePropValueAsString(Instance: TObject; RttiProp: TRttiMember; SubPropTypeKinds: TTypeKinds; SubPropMemberVisibilities: TMemberVisibilities): String; overload;

  function RecordPropAsString: String;
  var
    AValue: TValue;
    PointFValue: TPointF;
    PointValue: TPoint;
    SizeFValue: TSizeF;
    SizeValue: TSize;
  begin
    AValue := RttiPropGetValue(RttiProp, Instance);
    if AValue.IsType<TPointF>() then
    begin
      PointFValue := AValue.AsType<TPointF>();
      Result := '(' + PointFValue.X.ToString + ', ' + PointFValue.X.ToString + ')';
    end
    else if AValue.IsType<TPoint>() then
    begin
      PointValue := AValue.AsType<TPoint>();
      Result := '(' + PointValue.X.ToString + ', ' + PointValue.X.ToString + ')';
    end
    else if AValue.IsType<TSizeF>() then
    begin
      SizeFValue := AValue.AsType<TSizeF>();
      Result := '(' + SizeFValue.Width.ToString + ', ' + SizeFValue.Height.ToString + ')';
    end
    else if AValue.IsType<TSize>() then
    begin
      SizeValue := AValue.AsType<TSize>();
      Result := '(' + SizeValue.Width.ToString + ', ' + SizeValue.Height.ToString + ')';
    end else
    begin
      Result := String(AValue.TypeInfo.Name);
    end;
  end;

  function ObjectPropAsString: String;
  var
    ValueAsObject: TObject;
    PropList: TArray<TRttiProperty>;
    i: Integer;
    RttiChildProp: TRttiProperty;
    PropStrValue: String;
    PropListStr: String;
    PropName: String;
    AValue: TValue;
  begin
    AValue := RttiPropGetValue(RttiProp, Instance);
    ValueAsObject := AValue.AsObject;

    if ValueAsObject = nil then
    begin
      Exit('(nil)');
    end;

    PropList := GetRttiPropListAsArray(ValueAsObject.ClassType, SubPropTypeKinds, SubPropMemberVisibilities);

    PropListStr := '(';
    for i := 0 to Length(PropList)-1 do
    begin
      RttiChildProp := PropList[i];

      if RttiChildProp.PropertyType.TypeKind in [tkInteger, tkChar, tkEnumeration, tkFloat,
                          tkString, tkSet, tkWChar, tkLString,
                          tkWString, tkInt64, tkUString] then
      begin
        PropName := String(PropList[i].Name);
        PropStrValue := GetInstancePropValueAsString(ValueAsObject, PropList[i], SubPropTypeKinds, SubPropMemberVisibilities);
        if PropListStr <> '(' then
          PropListStr := PropListStr + ', ';
        PropListStr := PropListStr + Copy(PropName, 1, 1) + ':' + PropStrValue;
      end;
      if i = 9 then
        Break;
    end;
    PropListStr := PropListStr + ')';

    Result := PropListStr + ' (' + ValueAsObject.ClassName + ')';
  end;

var
  AValue: TValue;
begin
  if RttiPropGetDataType(RttiProp).TypeKind = TTypeKind.tkClass then
  begin
    Result := ObjectPropAsString;
  end
  else if RttiPropGetDataType(RttiProp).TypeKind = TTypeKind.tkRecord then
  begin
    Result := RecordPropAsString;
  end else
  begin
    try
      AValue := RttiPropGetValue(RttiProp, Instance);
      if (AValue.TypeInfo = System.TypeInfo(TAlphaColor)) then
        Result := Cardinal(AValue.AsType<TAlphaColor>).ToString
      else
        Result := AValue.ToString();
    except
      on Exception do
        Result := '<' + Exception.ClassName + '>';
    end;
  end;
end;

{ TPropTreeNodeEh }

constructor TPropTreeNodeEh.Create;
begin
  inherited Create;
  ChildrenLoaded := False;
end;

destructor TPropTreeNodeEh.Destroy;
begin
  inherited Destroy;
end;

procedure TPropTreeNodeEh.Collapse;
begin
  Expanded := False;
  ExpandedStateChanged();
end;

procedure TPropTreeNodeEh.Expand;
begin
  if (HasChildren = False) or (Expanded = True) then Exit;

  Expanded := True;
  ExpandedStateChanged();
end;

procedure TPropTreeNodeEh.ExpandedStateChanged;
begin
  Owner.ExpandedStateChanged(Self);
end;

function TPropTreeNodeEh.GetItem(const Index: Integer): TPropTreeNodeEh;
begin
  Result := TPropTreeNodeEh(inherited Items[Index]);
end;

function TPropTreeNodeEh.GetNodeOwner: TPropTreeListEh;
begin
  Result := TPropTreeListEh(inherited TreeList);
end;

function TPropTreeNodeEh.GetNodeParent: TPropTreeNodeEh;
begin
  Result := TPropTreeNodeEh(inherited Parent);
end;

function TPropTreeNodeEh.GetVisibleItem(const Index: Integer): TPropTreeNodeEh;
begin
  Result := TPropTreeNodeEh(inherited VisibleItems[Index])
end;

procedure TPropTreeNodeEh.SetNodeParent(const Value: TPropTreeNodeEh);
begin
  inherited Parent := Value;
end;

procedure TPropTreeNodeEh.SetPropStrValue(const Value: String);
begin
  FPropStrValue := Value;
end;

function TPropTreeNodeEh.GetEditStyle: TEditStyle;
begin
  Result := TEditStyle.Simple;
  if (RttiType.Handle <> nil) and (RttiType.Handle.Kind = TTypeKind.tkEnumeration) then
    Result := TEditStyle.PickList
  else if IsSetValue then
    Result := TEditStyle.PickList
  else if RttiType.Handle = System.TypeInfo(TColor) then
    Result := TEditStyle.PickList
  ;
end;

procedure TPropTreeNodeEh.GetListValues(Items: TStrings);
var
  ASetTypeData: PTypeData;
  I: Integer;
  S: String;
begin
  if IsSetValue then
  begin
    Items.Add('True');
    Items.Add('False');
  end
  else if TypeInfo.Kind = tkEnumeration then
  begin
    ASetTypeData := GetTypeData(TypeInfo);

    for I := ASetTypeData.MinValue to ASetTypeData.MaxValue do
    begin
      S := GetEnumName(TypeInfo, I);
      Items.Add(S);
    end;
  end else if TypeInfo = System.TypeInfo(TColor) then
  begin
    FColorList := Items;
    GetColorValues(GetColorStrProc);
  end;
end;

function TPropTreeNodeEh.GetFontStyle: TFontStyles;
begin
  Result := [];
  if (Parent.Instance <> nil) and
     (PropInfo <> nil) and
     IsStoredProp(Parent.Instance, PropInfo)
     and not IsDefaultPropertyValue(Parent.Instance, PropInfo, nil)
  then
    Result := [TFontStyle.fsBold];
end;

procedure TPropTreeNodeEh.SetValueAsString(const SValue: String);
var
  S: TIntegerSet;
  SourceItem: Pointer;
  Prop: TRttiProperty;
  ValTest: TValue;
begin
  if IsSetValue then
  begin
    Integer(S) :=  StringToSet(Parent.PropInfo, Parent.PropStrValue);
    if CompareText(SValue, BooleanIdents[True]) = 0 then
      Include(S, SetIndex)
    else
      Exclude(S, SetIndex);
    Parent.SetValueAsString(SetToString(Parent.PropInfo, Integer(S)));
  end
  else
  begin
    SourceItem := Parent.Instance;
    if RttiProp is TRttiProperty then
    begin
      Prop := RttiProp as TRttiProperty;
      ValTest := StringToTValue(RttiType, SValue);
      Prop.SetValue(SourceItem, ValTest);
    end;
  end;

  PropStrValue := SValue;
end;

procedure TPropTreeNodeEh.GetColorStrProc(const S: string);
begin
  FColorList.Add(S);
end;

procedure TPropTreeNodeEh.RefreshValue;
begin
  if IsSetValue then
  else if PropInfo <> nil then
    PropStrValue := GetInstancePropValueAsString(Parent.Instance, PropInfo);
end;

function TPropTreeNodeEh.GetRttiType: TRttiType;
begin
  Result := RttiPropGetDataType(RttiProp);
end;

function TPropTreeNodeEh.GetTypeInfo: PTypeInfo;
begin
  if RttiType <> nil then
    Result := RttiType.Handle
  else
    Result := nil;
end;

{ TPropTreeListEh }

constructor TPropTreeListEh.Create(ItemClass: TPropTreeNodeClassEh);
begin
  inherited Create(ItemClass);
  FVisibleExpandedItems := TObjectListEh.Create;
end;

destructor TPropTreeListEh.Destroy;
begin
  FreeAndNil(FVisibleExpandedItems);
  inherited Destroy;
end;

procedure TPropTreeListEh.ExpandedStateChanged(PropTreeNode: TPropTreeNodeEh);
begin
  if Assigned(OnTreeNodeExpandedStateChanged) then
    OnTreeNodeExpandedStateChanged(Self, PropTreeNode);
end;

procedure TPropTreeListEh.BuildVisibleItems;
var
  CurNode: TBaseTreeNodeEh;
begin
  FVisibleExpandedItems.Clear;
  CurNode := GetFirstVisible;
  while CurNode <> nil do
  begin
    FVisibleExpandedItems.Add(CurNode);
    CurNode := GetNextVisible(CurNode, True);
  end;

  FVisibleItemsObsolete := False;
end;

function TPropTreeListEh.GetVisibleCount: Integer;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  Result := FVisibleExpandedItems.Count;
end;

function TPropTreeListEh.GetVisibleExpandedItem(const Index: Integer): TPropTreeNodeEh;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  if (Index < 0) or (Index > FVisibleExpandedItems.Count-1) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TPropTreeNodeEh(FVisibleExpandedItems.Items[Index]);
end;

function TPropTreeListEh.GetVisibleExpandedItems: TObjectList;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  Result := FVisibleExpandedItems;
end;

procedure TPropTreeListEh.VisibleItemsBecomeObsolete;
begin
  FVisibleItemsObsolete := True;
end;

procedure TPropTreeListEh.VisibleListChanged;
begin
  if Assigned(OnVisibleListChanged) then
    OnVisibleListChanged(Self);
end;

function TPropTreeListEh.GetRoot: TPropTreeNodeEh;
begin
  Result := TPropTreeNodeEh(inherited Root);
end;

procedure TPropTreeListEh.RefreshAllValues;
var
  CurNode: TBaseTreeNodeEh;
begin
  CurNode := GetFirst;
  while CurNode <> nil do
  begin
    TPropTreeNodeEh(CurNode).RefreshValue;
    CurNode := GetNext(CurNode);
  end;
end;

{ TDataGridObjectInspectorEh }

constructor TDataGridObjectInspectorEh.Create(AOwner: TComponent);
var
  Col: TDataGridStringColumnEh;
  LaCol: TDataGridLayoutColumnEh;
begin
  inherited Create(AOwner);
  FDataGrid := TDataGridEh.Create(Self);
  FDataGrid.Parent := Self;
  FDataGrid.Align := TAlignLayout.Client;
  FDataGrid.AutoGenerateColumns := False;
  FDataGrid.IndicatorColumn.Visible := False;
  FDataGrid.ColumnOptions.Padding.Rect := TRectF.Create(2, 1, 2, 1);
  FDataGrid.ScrollAnimation := TBehaviorBoolean.False;
  FDataGrid.Title.Filter.Enabled := False;
  FDataGrid.OnCurrentChange := DataGridCurrentChanged;
  FDataGrid.Name := 'ObjectInspectorGrid';

  Col := TDataGridStringColumnEh.Create(Self);
  Col.ColSizeUnit := TGridColSizeUnitEh.Weight;
  Col.Width := 25;
  Col.Title.Text := 'Prop Name';
  Col.FieldName := 'PropName';
  Col.Visible := False;
  DataGrid.StaticColumns.Add(Col);

  LaCol := TDataGridLayoutColumnEh.Create(Self);
  LaCol.ColSizeUnit := TGridColSizeUnitEh.Weight;
  LaCol.Width := 25;
  LaCol.Title.Text := 'La Prop Name';
  LaCol.OnCreateDataCellContent := CreateLaPropNameControls;
  LaCol.OnDataCellInitContent := InitPropNameCellContent;
  DataGrid.StaticColumns.Add(LaCol);

  Col := TDataGridStringColumnEh.Create(Self);
  Col.ColSizeUnit := TGridColSizeUnitEh.Weight;
  Col.Width := 50;
  Col.Title.Text := 'Prop Value';
  Col.FieldName := 'PropStrValue';
  Col.OnDataCellGetStyleParams := PropStrValueGetStyleParams;
  Col.OnGetDataCellManager := PropStrValueGetDataCellManager;
  Col.OnDataCellInitEditParams := PropStrValueInitEditParams;
  Col.OnDataCellInitEditor := PropStrValueInitEditor;
  Col.OnDataCellStartEdit := PropStrValueStartEdit;
  Col.OnDataCellSetValue := PropStrValueSetValue;
  Col.OnDataCellCanModify := PropStrValueCanModify;

  DataGrid.StaticColumns.Add(Col);

  ListTableLink := TListTableLinkEh.Create(Self);
  FPropTreeList := TPropTreeListEh.Create(TPropTreeNodeEh);
  FPropTreeList.OnVisibleListChanged := TreeListViewChanged;
  FPropTreeList.OnTreeNodeExpandedStateChanged := TreeNodeExpandedStateChanged;

  FTypeKinds := DefaultPropListTypeKinds;
  FMemberVisibilities := DefaultPropListMemberVisibilities;
  FObjectMemberKinds := [TObjectMemberKind.omkProperty];

  PropStrValueComboboxCellMan := TDataAxisGridComboboxCellManagerEh.Create(Self);
end;

procedure TDataGridObjectInspectorEh.CreateLaPropNameControls(Sender: TObject;
  Params: TDataGridCreateDataCellContentParamsEh);
var
  LaPropNameCell: TLaPropNameCellEh;
begin
  LaPropNameCell := TLaPropNameCellEh.CreateWith(Params.ContentParent, Params.ContentParent);
  LaPropNameCell.OnTreeSignMouseDown := TreeSignMouseDown;
  Params.CellContent := LaPropNameCell;
end;

procedure TDataGridObjectInspectorEh.InitPropNameCellContent(Sender: TObject; Params: TDataGridInitDataCellContentParamsEh);
var
  PropTreeNode: TPropTreeNodeEh;
  LaPropNameCell: TLaPropNameCellEh;
begin
  if (Params.Row <> nil) and (Params.CellContent <> nil) then
  begin
    PropTreeNode := TPropTreeNodeEh(Params.Row.SourceObjectItem);
    LaPropNameCell := Params.CellContent as TLaPropNameCellEh;
    LaPropNameCell.TreeSignVisible := PropTreeNode.HasChildren;
    LaPropNameCell.TreeSignExpanded := PropTreeNode.Expanded;
    LaPropNameCell.IndentLevel := PropTreeNode.Level - 1;
  end;
end;

destructor TDataGridObjectInspectorEh.Destroy;
begin
  FreeAndNil(FPropTreeList);
  inherited Destroy;
end;

class procedure TDataGridObjectInspectorEh.ShowInspectorForm(Component: TObject;
  FormBounds: TRect; NewForm: Boolean);
begin
  ShowObjectInspectorForm(Component, FormBounds, NewForm);
end;

class function TDataGridObjectInspectorEh.GetDefaultInspectorForm: TCustomForm;
begin
  Result := ObjectInspectorForm;
end;

function TDataGridObjectInspectorEh.FilterMemberList(PropList: TArray<TRttiMember>): TArray<TRttiMember>;
var
  PropList1: TList<TRttiMember>;
  Prop: TRttiMember;
begin
  if PropNameFilter = '' then
  begin
    Result := PropList;
    Exit;
  end;

  PropList1 := TList<TRttiMember>.Create;

  for Prop in PropList do
  begin
    if ContainsText(Prop.Name, PropNameFilter) then
    begin
      PropList1.Add(Prop);
    end;
  end;

  Result := PropList1.ToArray();

  PropList1.Free;
end;

procedure TDataGridObjectInspectorEh.TreeListViewChanged(Sender: TObject);
begin
  ListTableLink.SetList(FPropTreeList.VisibleExpandedItems, TypeInfo(TPropTreeNodeEh));
end;

procedure TDataGridObjectInspectorEh.TreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);

  function GetContextListItemLink(TreeSignLaObject: TLaObjectEh): TTypedListItemLinkEh;
  begin
    if (TreeSignLaObject.DataContext <> nil) and (TreeSignLaObject.DataContext.GetComponent <> nil) then
      Result := TreeSignLaObject.DataContext.GetComponent as TTypedListItemLinkEh
    else
      Result := nil;
  end;

var
  TreeSignLaObject: TLaObjectEh;
  PropTreeNode: TPropTreeNodeEh;
  ListItemLink: TTypedListItemLinkEh;
begin
  TreeSignLaObject := (Sender as TLaObjectEh);
  ListItemLink := GetContextListItemLink(TreeSignLaObject);

  if (ListItemLink <> nil) then
  begin
    PropTreeNode := TPropTreeNodeEh(ListItemLink.SourceItem);
    if PropTreeNode.Expanded
      then PropTreeNode.Collapse
      else PropTreeNode.Expand;
    RaiseOnCurrentChange();
  end;
end;

procedure TDataGridObjectInspectorEh.TreeNodeExpandedStateChanged(Sender: TPropTreeListEh;
  PropTreeNode: TPropTreeNodeEh);
var
  LastPropTreeNode: TPropTreeNodeEh;
  LastVertRollPos: Int64;
begin
  FObjInsInternalUpdating := True;
  if (PropTreeNode.Expanded = True) and (PropTreeNode.ChildrenLoaded = False) then
    LoadChildren(PropTreeNode);

  if DataGrid.CurrentRow <> nil then
    LastPropTreeNode := TPropTreeNodeEh(DataGrid.CurrentRow.SourceObjectItem)
  else
    LastPropTreeNode := nil;

  LastVertRollPos := DataGrid.VertAxis.RollStartVisPos;
  PropTreeList.BuildVisibleItems;
  ListTableLink.SetList(PropTreeList.VisibleExpandedItems, TypeInfo(TPropTreeNodeEh));

  if LastPropTreeNode <> nil then
  begin
    DataGrid.LocateRow(
      function(ADataRow: TDataGridRowEh): Boolean
      begin
        if ADataRow.SourceObjectItem = LastPropTreeNode then
          Result := True
        else
          Result := False;
      end);
  end;

  DataGrid.Invalidate;
  DataGrid.CheckUpdateViewLayout;
  DataGrid.SafeSetTopRollPos(LastVertRollPos);
  FObjInsInternalUpdating := False;
end;

function TDataGridObjectInspectorEh.GetComponent: TObject;
begin
  Result := FObservableObject;
end;

procedure TDataGridObjectInspectorEh.SetComponent(const Value: TObject);
begin
  if Value <> FObservableObject then
  begin
    FObservableObject := Value;
    ComponentChanged;
  end;
end;

procedure TDataGridObjectInspectorEh.SetMemberVisibilities(const Value: TMemberVisibilities);
begin
  if FMemberVisibilities <> Value then
  begin
    FMemberVisibilities := Value;
    ComponentChanged();
  end;
end;

procedure TDataGridObjectInspectorEh.SetObjectMemberKind(const Value: TObjectMemberKinds);
begin
  if FObjectMemberKinds <> Value then
  begin
    FObjectMemberKinds := Value;
    ComponentChanged();
  end;
end;

procedure TDataGridObjectInspectorEh.SetPropNameFilter(const Value: String);
begin
  if FPropNameFilter <> Value then
  begin
    FPropNameFilter := Value;
    ComponentChanged();
  end;
end;

function TDataGridObjectInspectorEh.GetPropValueAsString(Instance: TObject; RttiProp: TRttiMember): String;
begin
  Result := GetInstancePropValueAsString(Instance, RttiProp, TypeKinds, MemberVisibilities);
end;

procedure TDataGridObjectInspectorEh.InitNodeByObjectMember(AComponent: TObject; ANode: TPropTreeNodeEh; DataMember: TRttiMember);
begin
  ANode.RttiProp := DataMember;
  if DataMember is TRttiInstanceProperty
    then ANode.PropInfo := TRttiInstanceProperty(DataMember).PropInfo
    else ANode.PropInfo := nil;

{$IFDEF NEXTGEN}
  ANode.PropName := DataMember.NameFld.ToString;
{$ELSE}
  ANode.PropName := String(DataMember.Name);
{$ENDIF}

  ANode.PropStrValue := GetPropValueAsString(AComponent, DataMember);
  if (ANode.RttiType.TypeKind = TTypeKind.tkSet) or
     ((ANode.RttiType.TypeKind = TTypeKind.tkClass) and (ANode.PropStrValue <> ''))
  then
  begin
    ANode.HasChildren := True;
    ANode.ChildrenLoaded := False;
  end else
  begin
    ANode.HasChildren := False;
    ANode.ChildrenLoaded := False;
  end;

  if (DataMember is TRttiProperty) and
     (ANode.RttiType.TypeKind = TTypeKind.tkClass) then
  begin
    ANode.Instance := GetObjectProp(AComponent, ANode.PropInfo);
  end else
  begin
    ANode.Instance := nil;
  end;
end;

procedure TDataGridObjectInspectorEh.PropStrValueGetDataCellManager(Sender: TObject;
  Params: TDataGridGetDataCellManagerParamsEh);
var
  PropTreeNode: TPropTreeNodeEh;
begin
  if (Params.Row <> nil) then
  begin
    PropTreeNode := TPropTreeNodeEh(Params.Row.SourceObjectItem);
    if (PropTreeNode.TypeInfo <> nil) and
       (PropTreeNode.TypeInfo.Kind = tkEnumeration)
    then
      Params.CellManager := PropStrValueComboboxCellMan;
  end;
end;

procedure TDataGridObjectInspectorEh.PropStrValueGetStyleParams(Sender: TObject; Params: TDataGridStringDataCellStyleParamsEh);
var
  PropTreeNode: TPropTreeNodeEh;
  FontColor: TAlphaColor;
begin
  if (Params.Row <> nil) then
  begin
    PropTreeNode := TPropTreeNodeEh(Params.Row.SourceObjectItem);
    Params.Font.Style := PropTreeNode.GetFontStyle();
    FontColor := MakeColor(14, 73, 130);
    if TStyleManagerEh.Current.StyleColorMode = TStyleColorModeEh.Dark then
      FontColor := AdjustColorForDarkTheme(FontColor);
    Params.FontColor := FontColor;
  end;
end;

procedure TDataGridObjectInspectorEh.PropStrValueInitEditor(Sender: TObject;
  Params: TDataGridInitEditorParamsEh);
begin
  (Params.Editor as TDBAxisGridLaInplaceTextEdit).InternalEdit.OnDblClick := PropStrValueEditorDblClicked;
end;

procedure TDataGridObjectInspectorEh.PropStrValueEditorDblClicked(Sender: TObject);
var
  PropTreeNode: TPropTreeNodeEh;
  InplaceEdit: TInplaceEdit;
  StrValue: String;
  EnumType: TRttiEnumerationType;
  EnumList: TArray<string>;
  I: Integer;
  NextValIndex: Integer;
  NextStrValue: String;
begin
  InplaceEdit := Sender as TInplaceEdit;
  StrValue := InplaceEdit.Text;
  PropTreeNode := TPropTreeNodeEh(DataGrid.CurrentRow.SourceObjectItem);

  if (PropTreeNode.IsSetValue = True) then
  begin
    if InplaceEdit.Text = 'True' then
      NextStrValue := 'False'
    else
      NextStrValue := 'True';
    PropTreeNode.SetValueAsString(NextStrValue);
    InplaceEdit.Text := NextStrValue;
  end
  else if (PropTreeNode.TypeInfo <> nil) and
          (PropTreeNode.TypeInfo.Kind = tkEnumeration) then
  begin
    EnumType := PropTreeNode.RttiType as TRttiEnumerationType;
    EnumList := EnumType.GetNames();
    NextValIndex := -1;
    for I := 0 to Length(EnumList) - 1 do
    begin
      if EnumList[I] = StrValue then
      begin
        if I < Length(EnumList) - 1 then
        begin
          NextValIndex := I + 1;
          Break;
        end;
      end;
    end;
    if NextValIndex = -1 then NextValIndex := 0;
    NextStrValue := EnumList[NextValIndex];
    PropTreeNode.SetValueAsString(NextStrValue);
    InplaceEdit.Text := NextStrValue;
  end;
end;

procedure TDataGridObjectInspectorEh.PropStrValueInitEditParams(Sender: TObject;
  Params: TDataGridDataCellInitEditParamsEh);
begin
end;

procedure TDataGridObjectInspectorEh.PropStrValueCanModify(Sender: TObject;
  Params: TDataGridDataCellCanModifyParamsEh);
var
  PropTreeNode: TPropTreeNodeEh;
  Prop: TRttiProperty;
begin
  if Params.Row = nil then Exit;
  PropTreeNode := TPropTreeNodeEh(Params.Row.SourceObjectItem);
  if PropTreeNode.RttiProp = nil then Exit;
  if (PropTreeNode.RttiProp is TRttiProperty) = False then Exit;

  Prop := PropTreeNode.RttiProp as TRttiProperty;
  if (Prop.IsWritable = True) and
     (PropTreeNode.TypeInfo <> nil) and
     (PropTreeNode.TypeInfo.Kind in [tkInteger, tkChar, tkEnumeration, tkFloat,
                                     tkString, tkWChar, tkLString, tkWString,
                                     tkVariant, tkInt64, tkUString,
                                     tkClassRef]) then
  begin
    Params.CanModify := True;
    Params.Handled := True;
  end;
end;

procedure TDataGridObjectInspectorEh.PropStrValueStartEdit(Sender: TObject;
  Params: TDataGridDataCellStartEditParamsEh);
begin
  Params.EditingActive := True;
  Params.Handled := True;
end;

procedure TDataGridObjectInspectorEh.PropStrValueSetValue(Sender: TObject;
  Params: TDataGridDataCellSetValueParamsEh);
var
  PropTreeNode: TPropTreeNodeEh;
begin
  PropTreeNode := Params.Row.SourceObjectItem as TPropTreeNodeEh;
  PropTreeNode.SetValueAsString(Params.Value.AsString);
  Params.Handled := True;
end;

procedure TDataGridObjectInspectorEh.LoadChildren(ANode: TPropTreeNodeEh);
var
  PropList: TArray<TRttiMember>;
  NewNode: TPropTreeNodeEh;
  i: Integer;
  AComponent: TObject;
  ASetTypeData: PTypeData;
  AEnumSetTypeInfo: PTypeInfo;
  AEnumSetTypeData: PTypeData;
  ASetValueAsInteger: Integer;
begin
  if ANode.ChildrenLoaded = True then Exit;

  if (ANode.RttiType <> nil) and
      (ANode.RttiType.Handle <> nil) and
      (ANode.RttiType.Handle.Kind = TTypeKind.tkSet) then
  begin
    ASetTypeData := GetTypeData(ANode.RttiType.Handle);
    AEnumSetTypeInfo := ASetTypeData^.CompType^;
    AEnumSetTypeData := GetTypeData(AEnumSetTypeInfo);

    ASetValueAsInteger := GetOrdProp(ANode.Parent.Instance, ANode.PropInfo);

    for I := AEnumSetTypeData.MinValue to AEnumSetTypeData.MaxValue do
    begin
      NewNode := TPropTreeNodeEh(PropTreeList.AddChild('', ANode, nil));
      NewNode.PropInfo := nil;
      NewNode.PropName := GetEnumName(AEnumSetTypeInfo, I);
      NewNode.PropStrValue := BooleanIdents[I in TIntegerSet(ASetValueAsInteger)];
      NewNode.HasChildren := False;
      NewNode.IsSetValue := True;
      NewNode.SetIndex := I;
    end;
  end else
  begin
    PropList := nil;
    AComponent := ANode.Instance;

    if AComponent <> nil then
    begin
      PropList := GetRttiMemberListAsArray(AComponent.ClassType, TypeKinds, MemberVisibilities, ObjectMemberKinds);

      PropList := FilterMemberList(PropList);

      for i := 0 to Length(PropList)-1 do
      begin
        NewNode := TPropTreeNodeEh(PropTreeList.AddChild('', ANode, nil));

        InitNodeByObjectMember(AComponent, NewNode, PropList[i]);
      end;
    end;
  end;

  ANode.ChildrenLoaded := True;
  PropTreeList.VisibleItemsBecomeObsolete;
end;

procedure TDataGridObjectInspectorEh.ComponentChanged;
var
  PropList: TArray<TRttiMember>;
begin
  PropList := nil;
  PropTreeList.Clear;
  PropTreeList.Root.ChildrenLoaded := False;
  PropTreeList.Root.Instance := Component;

  LoadChildren(PropTreeList.Root);

  ListTableLink.SetList(PropTreeList.VisibleExpandedItems, TypeInfo(TPropTreeNodeEh));
  DataGrid.DataSource := ListTableLink;
end;

procedure TDataGridObjectInspectorEh.DataGridCurrentChanged(Sender: TObject; Params: TDataGridEventParamsEh);
var
  PropTreeNode: TPropTreeNodeEh;
  EnumType: TRttiEnumerationType;
begin
  if DataGrid.CurrentRow = nil then Exit;

  PropTreeNode := TPropTreeNodeEh(DataGrid.CurrentRow.SourceObjectItem);
  if (PropTreeNode.TypeInfo <> nil) and
     (PropTreeNode.TypeInfo.Kind = tkEnumeration) then
  begin
    EnumType := PropTreeNode.RttiType as TRttiEnumerationType;
    PropStrValueComboboxCellMan.ListItems.Clear();
    PropStrValueComboboxCellMan.ListItems.AddStrings(EnumType.GetNames());
  end;

  if (FObjInsInternalUpdating = False) and (Assigned(OnCurrentChange)) then
    OnCurrentChange(Self, Params);
end;

procedure TDataGridObjectInspectorEh.RaiseOnCurrentChange;
begin
  if (FObjInsInternalUpdating = False) and (Assigned(OnCurrentChange)) then
    OnCurrentChange(Self, nil);
end;

function TDataGridObjectInspectorEh.GetCurrentDataRow: TDataGridDataRowEh;
begin
  Result := DataGrid.CurrentDataRow;
end;

initialization
  RttiContext := TRttiContext.Create;
end.



