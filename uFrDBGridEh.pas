unit uFrDBGridEh;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  MemTableDataEh, Data.DB, Data.Win.ADODB, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
  DataDriverEh, ADODataDriverEh, MemTableEh, Math, PrnDbgEh, ClipBrd,
  ComCtrls, Buttons, Vcl.Menus, DBCtrlsEh, Vcl.Mask,
  uData, uString, uLabelColors, Vcl.Imaging.pngimage
  ;

const
  yrefT = -1;
  yrefB = -2;
  yrefC = -3;

  mydefGridRowHeight = 18;    //��������� ������ ������ �����

  MY_IDS_INSERTED_MIN = MaxInt - 100000;


type

  TDBGridEhMy = class(TDBGridEh);
  {
  ����� �������� ���� � ������������ �����, � �������� ���������� ����� ����� Options � OptionsEh � ��������� �������������� ����.
  ������ ������ ������� ��������� � �������� ����!
  }

  TFrDBGridOption = (
    myogColoredTitle,                         //��������� ���������
    myogColoredEven,                          //��������� ������/�������� �����
    myogPanelFilter,                          //������ � ������
    myogPanelFind,                            //����� � ������ (������ �������)
    myogColumnFilter,                         //������ � ��������� StFilter
    myogSorting,                              //����������. ���������������� �������� ������
    myogSavePosWhenSorting,                   //��������� ������� ��� ����������. ����� ���������� ������� �� ������� �������
    myogColumnMove,                           //��������� ������ ������� �������
    myogColumnResize,                         //��������� �������� ������� �������
    myogSaveFilter,                           //��������� ������ �������� � ��������� � �������������� ��� ����� ��������
    myogMultiSelect,                          //��������������� �����
    myogIndicatorCheckBoxes,                  //�������� � ������������ �������. ���� ���� ��������������� �����, �� ����� �������� ���������, ����� ����
    myogHiglightEditableColumns,              //��������� ������� �������� ����� ������������� ��������
    myogHiglightEditableCells,                //��������� ������� �������� ����� ������� ������, ���� ��� ������������
    myogHasStatusBar,                         //��������� � ����� (� ���������� - ��������� � ���������� �������, � ������� ������������� � �������)
    myogGridLabels,                           //������� ����� ��� �����, ��� �����, �������� ���� ���� FormDoc,
    myogGrayedWhenRefresh,                    //�������� ���� ��� ����������
    myogIndicatorColumn,                      //�������� ������������ �������
    myogAutoFitColWidths,                     //��������� ������ �������, ����� ������� ���� ��������/��������� � ��������� �������
    myogAutoFitRowHeight,                     //��������� ������ ����� � ����������� �� �����������
    myogSaveOptions,                          //��������� ����� � ����� ��������
    myogDefMenu,                              //-������������ ���� ����� � ���������� ��������, ���� ���� �� ��������� ����
    myogRowDetailPanel,                       //�������� ��������� ������ � �����
    myogLoadAfterVisible,                     //�������� ����, �� ��������� �������� ������
    myogPrintGrid,                            //��������� ������ � ������� �����, �������� ���� ����� � ����
    myogHideColumns,                          //��������� ������� ������� ����� ���� ��������
    myogFroozeColumn                          //��������� ���������� ������� ����� ���� ��������
  );

  TFrDBGridOptions = set of TFrDBGridOption;

const FrDBGridOptionDesc : array [0..26] of string = (
  '��������� ���������',
  '��������� ������/�������� �����',
  '������ � ������',
  '����� � ������ (������ �������)',
  '������ � ��������� StFilter',
  '����������. ���������������� �������� ������',
  '��������� ������� ��� ����������. ����� ���������� ������� �� ������� �������',
  '��������� ������ ������� �������',
  '��������� �������� ������� �������',
  '��������� ������ �������� � ��������� � �������������� ��� ����� ��������',
  '��������������� �����',
  '�������� � ������������ �������. ���� ���� ��������������� �����, �� ����� �������� ���������, ����� ����',
  '��������� ������� �������� ����� ������������� ��������',
  '��������� ������� �������� ����� ������� ������, ���� ��� ������������',
  '��������� � ����� (� ���������� - ��������� � ���������� �������, � ������� ������������� � �������)',
  '������� ����� ��� �����, ��� �����, �������� ���� ���� FormDoc,',
  '�������� ���� ��� ����������',
  '�������� ������������ �������',
  '��������� ������ �������, ����� ������� ���� ��������/��������� � ��������� �������',
  '��������� ������ ����� � ����������� �� �����������',
  '��������� ����� � ����� ��������',
  '-������������ ���� ����� � ���������� ��������, ���� ���� �� ��������� ����',
  '�������� ��������� ������ � �����',
  '�������� ����, �� ��������� �������� ������',
  '��������� ������ � ������� �����, �������� ���� ����� � ����',
  '��������� ������� ������� ����� ���� ��������',
  '��������� ���������� ������� ����� ���� ��������'
);

const
  //������� ����� ����� ��� ���� ������
  FrDBGridOptionDef : TFrDBGridOptions =
    [myogIndicatorColumn, myogColoredTitle, myogColoredEven, myogHiglightEditableCells, myogHiglightEditableColumns, myogSavePosWhenSorting, myogGrayedWhenRefresh];
  //�������������� � ���� ����� ��� ������ ��������� ������������
  FrDBGridOptionRefDef : TFrDBGridOptions =
    [myogSorting, myogPanelFilter, myogColumnMove, myogColumnResize, myogColumnFilter, myogSaveOptions, myogHasStatusBar, myogPrintGrid, myogHideColumns, myogFroozeColumn];
  //����� ����� ��� ���������� � ��
  FrDBGridOptionSave : TFrDBGridOptions = [myogPanelFilter, myogPanelFind, myogColumnFilter, myogSorting, myogSaveFilter, myogAutoFitColWidths, myogAutoFitRowHeight, myogSavePosWhenSorting];




type

  TFrDBGridVerifyMode = (
    dbgvBefore,
    dbgvCell,
    dbgvRow,
    dbgvTable
  );

  TFrDBGridRowOperationMode = (
    dbgroBeforeAdd,
    dbgroBeforeInsert,
    dbgroBeforeDelete,
    dbgroAfterAdd,
    dbgroAfterInsert,
    dbgroAfterDelete,
    dbgroOnVerifyRow,
    dbgroOnVerifyTable
  );


  //����� ������ � ������� �������� � �����
  TFrDBGridDataMode = (
    myogdmWithAdoDriver,            //����������� AdoDriver, ������� ����� ������
    myogdmFromArray,                //������ ����������� ����� �� �������, ������� �������
    myogdmFromSql                   //������ ����������� sql-�������� ��� �������� ��� �������, ������� �������
  );

  //������ ���������� ��� ������� �����
  TFrDBGridRecFieldsList = record
                                    //st$s as name     (������ ������ ������������ ��� ����� ��� ����� ����������� null)
    Name: string;                   //������������ ���� (������� �� $ ��� �����), ����������� � ����� � MemTable) - name
    NameDb: string;                 //������������ ���� � �� - st
    FullName: string;               //������������ ���� ������, ��� ��� ���� ������� � ������� ����������� ����� - st$s as name
    Caption: string;                //��������� ����
    DataType: TFieldType;           //��� ������, ������������ �� ������������ ���� ���� id$i
    FieldSize: Integer;             //������ ������, �� ������������
    DefOptions: string;             //��������� ����������� ������� - ������, ������������ �� ������, ������
    Width: Integer;                 //�� ���������
    MaxWidth: Integer;              //�� ���������
    Visible: Boolean;               //����������� ��������� ������� � ����������
    Invisible: Boolean;             //���� �����������, �� ��������� ������, �� ��� �� �������� �� ����������� ��������� ��������� � ��
    AddProps: TVarDynArray2;
    FChb: Boolean;                  //������� � �������
    FChbPic: string;                //��������� ��������, ������� ��������� ������ ��������, ���� ��� ������� �� �������������
    FChbt: Boolean;                 //������� � ������� � �������
    FChbtPic: string;               //��������� ��������, ������� ��������� ������ ��������, ���� ��� ������� �� �������������
    FBt: string;                    //������ ����������� ������ � �������
    FPic: string;                   //������ ����������� �������� � �������
    Editable: Boolean;              //������ � ������� �������������
    FVerify: string;                //������ ����������� ������ ��� ���������������
    FFormat: string;                //������ ����������� ������� ����������� ������ � ������� � ������
    FIsNull: Boolean;               //�������, ��� ������ ������ ����������� ������ ��������; ������� ����� ������
    FTags: string;                  //���� ��� �������� ������� � ������ �����, � ������ ���� ����� ���� ��������� ����� ,
  end;

  //������ ������� �������� �����
  TFrDBGridFieldsList = array of TFrDBGridRecFieldsList;

  //������ ��������� ������, ������� ������ ������������� ���� ������ ������ (�� ����� ���� ���������)
  TFrDBGridEhRecButtons = array of record
    A: TVarDynArray2;            //������ ���������� ������ �� ������
    T: Integer;                  //��� ������ cbttXXXX (��� ����� ��� �������� ����������� ������ ����� �����), �� ��������� cbttSBig
    H: Integer;                  //������ ������ ������, �� ��������� ����������� �� ���� ������ � ��������� �� ���  = 2
    V: Boolean;                  //������������ ������������ ������, �� ��������� �������������, ���� ������ ������ �� PLeft
    P: TPanel;                   //������, � ������� ������������� ������. ���� ������ ������ ������ ������ ��� ������� 0, �� ��� ������ PTop
                                 //������ ����� � �� ������������ ������, ���� �� �����
  end;

  //����������� ������ � ������� ���
  TFrDBGridEhRecSQL = record
    View: string;               //��� ��� �������, �� ������� ������ ������ ��� ������ ������
    Table: string;              //�������, ������� ���������
    FieldsDef: TVarDynArray2;   //������ ��������������� ����������� ����� (��������� ��������)
    FieldNames: string;
    Captions: string;
    IdField: string;            //��� ���� ����, ������������ ������������� ��� ������ ���� � FieldsDef
    RefreshBeforeSave: Boolean;//��������� ������ �� �� ����� ���������� ������ � ������
    RefreshAfterSave: Boolean; //��������� ������ �� �� ����� ��������� ������ � ������
    Select: string;             //������ ��������� ���� �������. ���� ������, ����������� �� ��������� ������ �����, WhereAllways � ������� GetWhere
                                //���� ��������, �� WhereAllways ������������
                                //������� ������� GetWhere �������� ������ "/*WHERE*/" ��� �� �������, ����� ���������� � Select ����� WhereAllways ����� and
    GetRec: string;             //���������� ������ ����� ������� �� ��
    Update: string;             //������ ������ ������� � ��
    Delete: string;             //�������� ������ � ��
    Insert: string;             //�������� ������ � ��
    WhereAllways: string;       //���������� ����� ������� �������, ����� ���� ���� �������� 'where dt_beg=:dt$d', 'where a > 0 /*WHERE*/ order by dt', 'where (a > 1 or b >1)', 'group by name'
                                //��� /*WHERE|ANDWHERE|WHEREONLY*/ ��������� �� 'where %GetWhere%', " and (%GetWhere%)
    Fields: TFrDBGridFieldsList;    //������ ������� �����/�������� ��� �����, ���������� �� ��������� �������� ������ � ��������� �������
  end;

  //����������� ����������� ������� ��� ��������
  TFrDBGridEhPickRec = record
    FieldName: string;
    PickList: TVarDynArray;
    KeyList: TVarDynArray;
    LimitTextToListValues: Boolean;
    AlwaysShowEditButton: Boolean;
  end;

  TFrDBGridEhPickRecList = array of TFrDBGridEhPickRec;


  TFrDBGridEhDataGrouping = record
    Fields: TVarDynArray;
    Fonts: TFontsArray;
    Colors: TColorsArray;
    Active: Boolean;
  end;

  {
  ��������� ������ � ����� �����
  (����, ������� ������� �����, ������, �������� � ������ � �������, ������ �����),
  ��������� ��� �� ���������.
  ����� �������� � ������, ������� ��������������� �� ���������������, � ��� ��������� ��������� �����, � ����������� ���
  � �������� ������ �����.
  }
  TFrDBGridEhOpt = class(TObject)
  private
    //������ ������� ������. ����� ���� ����������. ������� ����� ��, ��� ������� ����� ������ ������ � ������. ������ �� ����������� �� ������.
    FButtons: TFrDBGridEhRecButtons;
    //���� ������, ������� �������� ���� ���� ������� �����
    FButtonsIfEmpty: TVarDynArray;
    //���, �������, �������, ��������� ����������� �����
    FSql: TFrDBGridEhRecSql;
    //����� ��������� ������ (� �������������, �� �������, ��� ��� �������� ������ ����������� �� ������ ������ ����� ��������, � ����� ������ � ���� ��������)
    FDataMode: TFrDBGridDataMode;
    //����������� �������� � ������
    FAllowedOperations: TDBGridEhAllowedOperations;
    //������ ����������� (������� �����, ������ ������������ ����� ����������, ������� � ������ ���� - ����� ���� �������), � ���������� �����������.
    FDataGrouping: TFrDBGridEhDataGrouping;
    //��� ������������� �������
    FFrozenColumn: string;
    //��������� �������������� sql-������� (����� �������� ���������� �� ����� �� ������ ������ � ������������ sql-��������, � �� ��������� ������� DBGridEh)
    FFilterRules: TVarDynArray2;
    //�������������� ������ �� ������ � ����� �������������� sql-�������, ������ �� ������� ������� �������� where-����� ��� ��������� �������
    FFilterResult: string;
    //��������� �������, ������������ � ���������� � � ����������
    FCaption: string;
    //��������� ��� ������� �����
    FColumnsInfo: TVarDynArray2;
    //�����, ������� ������������ �� ����� ������ ����� ������ ��������� (�������� ����, ��� ��������� ����������, ��� ��������� �� �� - ����� ����������� ������ ��������� ���������)
    FFrozenGridOptions: TFrDBGridOptions;
    //������ (�� name), ��� ������� �������� ���������, �� ��� �������������, ����������� � �� � ����������������� �� ���
    //���� ����� ���� �������� '*', �� ��� �������� �������������� ��������� ����������� ��� ��� ������ ��������� �������� ����
    FPanelsSaved: TVarDynArray;
    //������ ���������� ������� ��� ���� �����
    FPickLists: TFrDBGridEhPickRecList;
    //���� ������, ����������� Wh.ExecDialog(FDialogFormDoc, Fr.ID, null)
    FDialogFormDoc: string;
    //��������������� ���������
    procedure SetFrValue(var fr: TFrDBGridRecFieldsList; AValue: string; ASet: Boolean = False);
  public
    //�����, � �������� ����������� ���������
    FrDBGridEh: TObject;
    //�����������
    constructor Create(AOwner: TComponent);
    //��������
    property Caption: string read FCaption write FCaption;
    property Buttons: TFrDBGridEhRecButtons read FButtons;
    property Sql: TFrDBGridEhRecSql read FSql;
    property DataMode: TFrDBGridDataMode read FDataMode;
    property AllowedOperations: TDBGridEhAllowedOperations read FAllowedOperations;
    property FilterRules: TVarDynArray2 read FFilterRules write FFilterRules;
    property FilterResult: string read FFilterResult write FFilterResult;
    property DataGrouping: TFrDBGridEhDataGrouping read FDataGrouping;
    property ColumnsInfo: TVarDynArray2 read FColumnsInfo write FColumnsInfo;
    property FrozenColumn: string read FFrozenColumn write FFrozenColumn;
    property FrozenGridOptions: TFrDBGridOptions read FFrozenGridOptions write FFrozenGridOptions;
    property PickLists: TFrDBGridEhPickRecList read FPickLists;
    property DialogFormDoc: string read FDialogFormDoc write FDialogFormDoc;
    //��������� ��������� �������
    //��������� ������� ������ � ����
    procedure SetButtons(AIndex: Integer; AButtons: TVarDynArray2; AType: Integer = 1; APanel: TPanel = nil; AHeight: Integer = 0; AVertical: Boolean = False); overload;
    //������� ��������� ������ ������, ������ ����������� �������, ���� ����� ���������
    procedure SetButtons(AIndex: Integer; AButtons: string = ''; ARight: Boolean = True); overload;
    //��������� ������, ������� �������� ��� ������ �����. ���� �� ���������� - ��� ����� ������ �� ���������
    //���������� ������ ���������� � ��� ��� �� ���������!. ����� ��������, ������� ��������� ������ ������!
    procedure SetButtonsIfEmpty(AButtonsIfEmpty: TVarDynArray);
    //���������� ������ ��������������� ����������� �����
    procedure SetFields(AFields: TVarDynArray2);
    //��������� �������� �����, ���������� ����� ;, AFeatype ���������� ������� � ��� �� ���� ��� ��� ����������� �����
    procedure SetColFeature(AFields: string; AFeatype: string; ASet: Boolean = true; AClearOther: Boolean = False);
    //��������� sql ��� �������
    procedure SetTable(AView: string; ATable: string = ''; AIdField: string = ''; ARefreshBeforeSave: Boolean = True; ARefreshAfterSave: Boolean = True);
    //������� sql, ���� ��� �� ����������� �������������� �� ��������� ����������� �����
    procedure SetSql(ASelect: string = ''; AGetRec: string = ''; AUpdate: string = ''; AInsert: string = ''; ADelete: string = '');
    //����������� where-����� �������, ������� ������ ��������� � ������� select
    procedure SetWhere(AWhereAllways: string = '');
    //����� ������ � ������� (� ������������� ������, �������� �� ������� ���� ���, �������� �� �������)
    procedure SetDataMode(ADataMode: TFrDBGridDataMode = myogdmWithAdoDriver);
    //���������� ��� ����� ��������,
    //���������� ������� � ����� ��������, ������� �����-���� �������� ��������� �� ('uiad')
    //���� ��� ������� �� �������, � ����� ����� ��������� alopUpdateEh
    procedure SetGridOperations(AOperations: string = 'u');
    //�����������
    //���������� ���� � ������ ���������� �����������. ���� ���� �� �������� - ��� �� ����������.
    //���� ����� ��� ����������� ��� - ��� �� ���������
    procedure SetGrouping(AFields: TVarDynArray; AFonts: TFontsArray; AColors: TColorsArray; AActive: Boolean);
    //��������� ������ � ������ ����������� ���������� ������� � �������� �����
    procedure SetPick(AFieldName: string; APickList: TVarDynArray; AKeyList: TVarDynArray; ALimitTextToListValues: Boolean; AAlwaysShowEditButton: Boolean = True);
    //��������� ������� ���� ������� �������������� �������� ���������
    procedure SetPanelsSaved(APanelsSaved: TVarDynArray);

    //�������� �������� (������) ��� ������� �� ������������ ����
    function  GetFieldRec(AFieldName: string): TFrDBGridRecFieldsList;

    //��������������� ���������
    //��������� ����� ��� ��������� �������� ��������� ������� � ������� ������� ����� �� ������� �������� (���� ��������, ������ �������� �� ��)
    procedure SetFieldVisible(AFieldName: string; AVisible: Boolean);
  end;

  //������ ��� ��������� �������� ��� ���������� ����� � �������-������
  TFrDBGridInitData = record
    IsDefined: Boolean;
    SQl: string;
    Params: TVarDynArray;
    Arr: TVarDynArray2;
    ArrFields: string;
    ArrN: TNamedArr;
  end;

  //������, �������������� ��� �������������� ����� � �������-������
  TFrDBGridEditData = record
    FieldsParams: TVarDynArray2;
    FieldsErrors: TVarDynArray2;
    IdsChanged: TVarDynArray;
    IdsDeleted: TVarDynArray;
    CellsWithErrors: TVarDynArray;
    IdAdded: Integer;
  end;

  //��������� ��� �������������� ����� (�������)
  TFrDBGridEditOptions = record
//    AddLast: Boolean;                       //�� ������ �������� ��������� ������ � ����� ������� (����� � ������� �������)
//    AddIfNotempty: Boolean;                 //��������� ������ ������ ���� ������� (��� AddLast ���������) ��������� ���������� (����� ���� id)
//    OneRowOnOpen: Boolean;                  //���� ���� ����������� ������ � ������ ������������� ��� ����������, �� ����� �������� ������ ������
//    AddRowIfFAddOnOpen: Boolean;            //���� fAdd �� ����� ������� ������ � �����
    AllowEmptyTable: Boolean;                 //��� ������� �� ������� ������ ������� ���������� �����������
    FieldsNoRepaeted: TVarDynArray;           //����, �������� ������� � ������� ������� �� ������ �����������
    AlwaysVerifyAllTable: Boolean;            //��� ����� ����� ������ � �������� ������ ������ ��������� ��� �������
  end;



  {
  ������� ������
  ����� �� ��� ��������� ������� �����/��������
  ��� �������� ���������� ������ ������, ��������� �������
  No �� ������������
  }
  TFrDBGridEh = Class;
  //��� ������� ������ ��� ������ ����, ������� ������� ������������ ����� Tag, fMode ������������ �� ���� ��� ������ ��������������, ����� fNone
  TFrDBGridEhButtonClickEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean) of object;
  //OnChange ��� OnClick ��� ������������� ����������� ��������� (������ � ������� ������)
  TFrDBGridEhAddControlChangeEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject) of object;
  //������� ���� � �������. �� ��������� �������� �������������� ��� �������� ������
  TFrDBGridEhDblClickEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean) of object;
  //���� �� ������ � ������, ��� ���� CellButtons �����, ������ ���������� �� ����� � ���
  TFrDBGridEhCellButtonClickEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean) of object;
  //����������, ����� �������� ������� � �����, ��� ������ ��� � �������, ��� ����� ����� ���������� �������� ������-���� ���� � ������
  //������������ ��� ��������� �������, ��������� �� ������ (��������, ����������� �����-���� ������, ������������ �������� �����)
  TFrDBGridEhSelectedDataChangeEvent = procedure (var Fr: TFrDBGridEh; const No: Integer) of object;
  //����� ������������� ���������� where-����� ������� � �������������� ��������� � �������
  //SqlWhere ���������� ����� �������� ��� ��������� ���������� �������, ���� �� ���� � � ���� ������ ������ ���� ��� sql-������� ��� ���������
  //(���������� ������, ������ ��� ��� ��������������� �������, ����� ������������� ��������� � ��� ������� �������, ������ �� ��������� ������ � ������ ��������
  TFrDBGridEhSetSqlParamsEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string) of object;
  //���������� ��� ������ ����� ������ � ������ �����
  //��� �������, ����� �� �����������, ��� ����������� ��� �������� � ���������� ������������ �������
  TFrDBGridEhColumnsUpdateDataEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean) of object;
  //����� ����� ������������� ��������� ������ (����� ��������, readonly, ���, �����) � ����������� �� ������ � ������� ������
  TFrDBGridEhColumnsGetCellParamsEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh) of object;
  //������ ������ ReadOnly ��� ������ (�������� � ����������� �� ������), ���� ��� � ������������� �������, �� ������ �� ������������� ������
  TGetFrDBGridEhCellReadOnlyEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean) of object;
  //���������� ��� ��������� ������ � ������� � ������� Mode � ����������� �� ���� ������
  //dbgvBefore - ����� �������� ������� �� ��� �� �������� � �������, ����� �������� �������� ��� ������ ��������� �� ������
  //dbgvCell - ����� �������� � ������ ���� �������� �������
  TFrDBGridEhVeryfyAndCorrectValuesEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string) of object;
  //���������� ����� ������� ����� ������ � ������ �������, ����� ��������� �������� � ��������
  //����� ����� ��������� �������� ������ ���� �� ���� ����������� TFrDBGridEhColumnsUpdateDataEvent
  TFrDBGridEhCellValueSaveEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean) of object;
  //���������� ����� � ����� �������� �������, ����������, �������� ������ � ������� �������;
  //��������� �������� ��������, ������ ��������� (����� � ��������), ���� ��������� �������� ����� �������� (������������� ������, ������ ��������)
  //����� ���������� ��� ������������ �� �������� ������ � �������
  TFrDBGridEhRowOperationEvent = procedure (var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridRowOperationMode; Row: Integer; var Handled: Boolean; var Cancel: Boolean; var Msg: string) of object;


  {
  ������ ������
  }
  TFrDBGridEh = class(TFrame)
    PContainer: TPanel;
    PGrid: TPanel;
    PTop: TPanel;
    PLeft: TPanel;
    PBottom: TPanel;
    PStatus: TPanel;
    PRowDetailPanel: TPanel;
    LbStatusBarLeft: TLabel;
    PmGrid: TPopupMenu;
    MemTableEh1: TMemTableEh;
    ADODataDriverEh1: TADODataDriverEh;
    DataSource1: TDataSource;
    DbGridEh1: TDBGridEh;
    PrintDBGridEh1: TPrintDBGridEh;
    MemTableEh1Field1: TIntegerField;
    TimerAfterStart: TTimer;
    CProp: TDBEditEh;
    ImgState: TImage;
    {������� ������}
    procedure FrameResize(Sender: TObject);
    procedure TimerAfterStartTimer(Sender: TObject);
    procedure PStatusResize(Sender: TObject);
    {������� ��������}
    procedure MemTableEh1AfterInsert(DataSet: TDataSet);
    procedure MemTableEh1AfterDelete(DataSet: TDataSet);
    procedure MemTableEh1BeforeInsert(DataSet: TDataSet);
    procedure MemTableEh1AfterOpen(DataSet: TDataSet);
    procedure MemTableEh1BeforeClose(DataSet: TDataSet);
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    {������� ���������}
    procedure DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean); virtual;
    procedure DbGridEh1ColEnter(Sender: TObject);
    procedure DbGridEh1SortMarkingChanged(Sender: TObject);
    procedure DbGridEh1DblClick(Sender: TObject);
    procedure DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DbGridEh1CellClick(Column: TColumnEh);
    procedure DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure DbGridEh1SearchPanelSearchEditChange(Grid: TCustomDBGridEh; SearchEdit: TDBGridSearchPanelTextEditEh);
    procedure DbGridEh1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure DbGridEh1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DbGridEh1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DbGridEh1CellMouseClick(Grid: TCustomGridEh; Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Processed: Boolean);
    procedure DbGridEh1FillSTFilterListValues(Sender: TCustomDBGridEh; Column: TColumnEh; Items: TStrings; var Processed: Boolean);
    procedure DbGridEh1ApplyFilter(Sender: TObject);
    procedure DbGridEh1RowDetailPanelHide(Sender: TCustomDBGridEh; var CanHide: Boolean);
    procedure DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
    procedure MemTableEh1AfterPost(DataSet: TDataSet);
  private
    {���� ��� ������� ������}
    //����� ������, ���� ������������ ����� ����� � ���������
    FNo: Integer;
    //���������� ��� ����������
    FInfoArray: TVarDynArray2;
    //����� �������� ���� � ������������ �����, ����������� ���������� ����� Options � OptionsEh
    FOptions: TFrDBGridOptions;
    //������ ����������� ������ ������
    FOpt: TFrDBGridEhOpt;
    //����� ��� �������������� ����� � �������-������
    FEditOptions: TFrDBGridEditOptions;
    //������, ������������ ��� �������������� �����
    FEditData: TFrDBGridEditData;
    //������ ��� ��������� �������� (sql, ������ ��� TNamedArr), ���� ���-�� ���� ��
    //DataMode ��������������� � FromArray � ������ ������������� �����������.
    //Sql=* ��������� sql ��������� �� ������ �����
    FInitData: TFrDBGridInitData;
    //������ �� ����� ��� ��������� ������ �����

    FGrid2: TFRDbgridEh;

    //������� ������ � �����. ����������� ������������ ������
    FHasError: Boolean;
    //��������� �� ������ � �����. ����������� ������������ ������
    FErrorMessage: string;
    //������� ����������� ������ � �����. ����������� ������������ ������
    FIsDataChanged: Boolean;
    //����� ������ ���������, ������������ �������� AfterScroll
    FLastRecNo: Integer;

    {���������� ����������}
    //��������� ������� ��� ���������� ������� � ������� ������� �����, �������� � �����������, ���� ��������� ����������� ��������
    ColumnTemp: TColumnEh;
    //�������, ��� ���� ����������� FIsDataChanged � ����� ��������� ������
    FIsGrid2Changed: Boolean;
    //���������� ����� ����� ��� ��������� ���������
    //(���������� ����� ������� ���������� ����� � SearchString, ����� �������� ��� ������, ��� ���������� ������)
    FLastRecordCount: Integer;
    //�������� ������ ��� �������� �� ������� ������� ��� ������, ����������
    FKeyString: string;
    //������, � ������� ����������� ������
    FPanelsBtn: TComponentsArray;
    //��� ���� ������ � ������� ����
    FBtnIds: TVarDynArray;
    //������������ �������� ��� � ���� DbEh-Controls
    FDynProps: TDynVarsEh;
    //���� ��������� ��������� ����� ����� ������� �������� ��������, �� ������������� �����
    FIsPrepared: Boolean;
    //���������� ������ �����, ��� ������� ������ �����
    FMouseCoord: TGridCoord;
    //���� ��������� �������� ������ � �������� �� �������/�������
    FInLoadData: Boolean;
    //���� ������ ��������� ����� (�� Ctrl+F3)
    FDevVisibleHidden: Boolean;
    //����, ������������, ��� �������� �������������� ���������� ��� ��������� �� ��
    FIsAddControlsLoaded: Boolean;
    //��������� ��������� ������, ��� ������� ������/��������������
    FLastFilter: TVarDynArray2;
    //���� ID ��� �������, �� ������� ���� �����
    FGridLabelsIds: TVarDynArray2;
    //��� ���� �� ������ ������� � �������
    FLastFilterClick: Boolean;
    //����������� ���������� ���� ��� ����������; ���� �� �����, �� ����� ���� � ���������� �������; �������� ��������� ����������
    FStatusBarText: string;
    //��������� ���� � ���������� (����� �� �������������� ���������; ��� ���� ��������)
    FLastStatusBarText: string;
    //� ����������� ������� ��������� ���. ��������
    FInAddControlChange: Boolean;
    FDisableChangeSelectedData: Boolean;
    //������ �������������� ������� �� ��������� ���������. ��� ����� ���������� ����� �������� �������, ����� ��������� �����������
    FLabelsColored: TVaRDynArray2;
    //�������
    FOnCellButtonClick: TFrDBGridEhCellButtonClickEvent;
    FOnButtonClick: TFrDBGridEhButtonClickEvent;
    FOnSelectedDataChange: TFrDBGridEhSelectedDataChangeEvent;
    FOnSetSqlParams: TFrDBGridEhSetSqlParamsEvent;
    FOnColumnsUpdateData: TFrDBGridEhColumnsUpdateDataEvent;
    FOnAddControlChange: TFrDBGridEhAddControlChangeEvent;
    FOnColumnsGetCellParams: TFrDBGridEhColumnsGetCellParamsEvent;
    FOnGetCellReadOnly: TGetFrDBGridEhCellReadOnlyEvent;
    FOnDbClick: TFrDBGridEhDblClickEvent;
    FOnVeryfyAndCorrectValues: TFrDBGridEhVeryfyAndCorrectValuesEvent;
    FOnCellValueSave: TFrDBGridEhCellValueSaveEvent;
    FOnRowOperation: TFrDBGridEhRowOperationEvent;
  protected
    {������� � ��������� ��� ��������� � ��������� ������� ���� ������� ���������� � ������� Private}

    function  GetID: Variant;
    function  GetRecNo: Integer;
    function  GetRecordCount: Integer;
    function  GetCurrField: string;
    function  GetCurrValue: Variant;
    procedure SetOptions(Value: TFrDBGridOptions);

    {������� ��� �������� ������, ������������� �����������}

    //������� ����� �� ������ ��� ������ ������ ������������ ����
    procedure ButtonOrPopupMenuClick(Sender: TObject); virtual;
    //������� onChange ����������� ����������� �������������� ���������
    //��� ���������� ��������� � �������, ������� onChange �� ����������!
    procedure AddControlChange(Sender: TObject);
    //�������� ����� �� ������ � ������
    procedure CellButtonClick(Sender: TObject; var Handled: Boolean);
    //������� ��������� ������ � ������
    procedure CellButtonDraw(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; Canvas: TCanvas; Cell, AreaCell: TGridCoord; const ARect: TRect; ButtonDrawParams: TCellButtonDrawParamsEh; var Handled: Boolean);
    //������� ��� ����� ������ � ������ ������� ����� ��������
    procedure ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    //����� ���������� ��������� ������, �������� ������ ��������������
    procedure ColumnsGetCellParams(Sender: TObject; EditMode: Boolean; Params: TColCellParamsEh);
    {����� ���������}
    //�������� �������������� ������ � ������� ������ ������
    procedure CreateInfoIcon;
    //�������� ������� ������� �����, ������� ���� � ������ ������, ����������� � �����������
    procedure GetColumnEvents;
    //��������� ������� � ���� ��� ������ � ������������� � ����������� �� ����
    //��������� ������� ��������, ������������ � ������, � �������� �������, ������������ ��� �������, ���������� � �����, � �����������
    procedure SetColumnsAndEvents;
    //��������� (��������� ������ TLaberl) � ������ ���������� �����
    procedure PrintStatusBar;
  public
    {������� ������}
    property OnCellButtonClick: TFrDBGridEhCellButtonClickEvent read FOnCellButtonClick write FOnCellButtonClick;
    property OnButtonClick: TFrDBGridEhButtonClickEvent read FOnButtonClick write FOnButtonClick;
    property OnSelectedDataChange: TFrDBGridEhSelectedDataChangeEvent read FOnSelectedDataChange write FOnSelectedDataChange;
    property OnSetSqlParams: TFrDBGridEhSetSqlParamsEvent read FOnSetSqlParams write FOnSetSqlParams;
    property OnColumnsUpdateData: TFrDBGridEhColumnsUpdateDataEvent read FOnColumnsUpdateData write FOnColumnsUpdateData;
    property OnAddControlChange: TFrDBGridEhAddControlChangeEvent read FOnAddControlChange write FOnAddControlChange;
    property OnColumnsGetCellParams: TFrDBGridEhColumnsGetCellParamsEvent read FOnColumnsGetCellParams write FOnColumnsGetCellParams;
    property OnGetCellReadOnly: TGetFrDBGridEhCellReadOnlyEvent read FOnGetCellReadOnly write FOnGetCellReadOnly;
    property OnDbClick: TFrDBGridEhDblClickEvent read FOnDbClick write FOnDbClick;
    property OnVeryfyAndCorrectValues: TFrDBGridEhVeryfyAndCorrectValuesEvent read FOnVeryfyAndCorrectValues write FOnVeryfyAndCorrectValues;
    property OnCellValueSave: TFrDBGridEhCellValueSaveEvent read FOnCellValueSave write FOnCellValueSave;
    property OnRowOperation: TFrDBGridEhRowOperationEvent read FOnRowOperation write FOnRowOperation;

    {��������� �������� ������}

    property InfoArray: TVarDynArray2 read FInfoArray write FInfoArray;
    //����� ������ (�����), ������� ��������� ������ �� ��������, ���� ��� �� ����� �� ����� -1
    property No: Integer read FNo;
    property Options: TFrDBGridOptions read FOptions write SetOptions;
    property Opt: TFrDBGridEhOpt read FOpt write FOpt;
    property EditOptions: TFrDBGridEditOptions read FEditOptions write FEditOptions;
    property EditData: TFrDBGridEditData read FEditData;
    property InitData: TFrDBGridInitData read FInitData;
    property Grid2: TFRDbgridEh read FGrid2 write FGrid2;
    //������� ������, ����� ������, ������� ����������� ������ � ����� (��������������� �������)
    property HasError: Boolean read FHasError;
    property ErrorMessage: string read FErrorMessage;
    property IsDataChanged: Boolean read FIsDataChanged;
    //���� ������� ������ (������ ����������; ���� ������� ���������, �� null)
    property ID: Variant read GetID;
    //��� �������� ���� ��������
    property CurrField: string read GetCurrField;
    //�������� �������� ���� �������� (���� ������� ���� �� Unassigned)
    property CurrValue: Variant read GetCurrValue;
    //������ ����� ������ ���������
    property RecNo: Integer read GetRecNo;
    //����� ������ ���������, ������������ �������� AfterScroll (�� ������ �����; �� ���������� �������� ��� ��������� ����� ��-�� ��������� ������� �� ��������� �������� �������)
    property LastRecNo: Integer read FLastRecNo;
    //���������� ������� � ��������
    property RecordCount: Integer read GetRecordCount;
    //������������ ��������, ���������� DbEh-���������
    property DynProps: TDynVarsEh read FDynProps;
    //����������� ����� ������� �������� �����
    property IsPrepared: Boolean read FIsPrepared;
    //������� ����, ��� ������������ �������� � ��������, ��������� � �������� ��������� � ��������
    property InLoadData: Boolean read FInLoadData write FInLoadData;
    //� ����������� ������� ��������� ���. ��������
    property InAddControlChange: Boolean read FInAddControlChange write FInAddControlChange;

    {����������� � ����������}

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    {��������� ������� ��������/��������� ������� � ��������}

    procedure SetInitData(Sql: string; Params: TVarDynArray); overload;
    procedure SetInitData(Arr: TVarDynArray2; ArrFields: string); overload;
    procedure SetInitData(ArrN: TNamedArr); overload;

    //���� ���� (� ������ ��������)
    function  IsEmpty: Boolean;
    //���� �� ����
    function  IsNotEmpty: Boolean;
    //�������� ���������� ����� ������� (�������������� ��� ���)
    function  GetCount(Filtered: Boolean = true): Integer;
    //�������� �������� ���� � ������� ������ �����
    function  GetValue(FieldName: string = ''): Variant; overload;
    function  GetValueI(FieldName: string = ''): Integer; overload;
    function  GetValueF(FieldName: string = ''): Extended overload;
    function  GetValueS(FieldName: string = ''): string; overload;
    function  GetValueD(FieldName: string = ''): TDateTime; overload;
    //�������� �������� ���� �� ����������� ������� (��������������� ��� ���� ��������)
    function  GetValue(FieldName: string; Pos: Integer; Filtered: Boolean = true): Variant; overload;
    function  GetValueI(FieldName: string; Pos: Integer; Filtered: Boolean = true): Integer; overload;
    function  GetValueF(FieldName: string; Pos: Integer; Filtered: Boolean = true): Extended; overload;
    function  GetValueS(FieldName: string; Pos: Integer; Filtered: Boolean = true): string; overload;
    function  GetValueD(FieldName: string; Pos: Integer; Filtered: Boolean = true): TDateTime; overload;
    //���������� �������� ���� � ������� ������. ���� ���� �� ������, ����������� ���� �������� �������. �� ��������� ������ Post
    procedure SetValue(FieldName: string; NewValue: Variant; Post: Boolean = True); overload;
    //���������� �������� ���� �� ���������� ������� (��������������� ��� ���� ��������)
    procedure SetValue(FieldName: string; Pos: Integer; Filtered: Boolean; NewValue: Variant); overload;
    //�������� ��� ���� ����������� ������� � ������ ��������; ���� ������� �� �������, �� ������������ ������� ����
    function  GetColumnFieldName(Column: TObject = nil): string;
    //�������� ������� � ������� �������� Columns �� �������� DBGridEh1.Col ��� Cell.X
    function  GetCol(Col: Integer = -1): Integer;
    //�������, �������� �� ������ ������� ��������������
    function  IsColumnEditable(FieldName: string = ''): Boolean;
    //���������� ������� � ������������ ������� ��� ���������� �������� ���������� ����
    procedure SetIndicatorCheckBoxesByField(FieldName: string; Values: TVarDynArray);

    {������� ��������� ������, ���������� ��� ���������� �� ����� ����������}

    //��������� ���������� �������
    //���������� ������� ���� ��� ����� ������� ��������� �������� ������
    function  Prepare: Boolean;
    //������� ������� �� ������ ������� �����; ������������ � ������ �������� �� ������� ��� �������� ���, �� �� � DataDriver
    procedure CreateDataSet;
    //��������� � ������� ������, ���������� sql-�������� �� ������ ������ ����� ������,
    procedure LoadSourceDataFromSql(ASqlParams: TVarDynArray; AEmptyBefore: Boolean = true);
    //��������� � ������� ������ �� ������� (�������������� ������� �������)
    procedure LoadSourceDataFromArray(AValues: TVarDynArray2; AArrayColumns: string = ''; AEmptyBefore: Boolean = true);
    procedure LoadData(AParams: TVarDynArray); overload;
    procedure LoadData(ASql: string; AParams: TVarDynArray; AEmptyTable: Boolean = true); overload;
    procedure LoadData(AValues: TVarDynArray2; AArrayColumns: string; AEmptyTable: Boolean = true); overload;
    procedure LoadData(AValues: TNamedArr; AEmptyTable: Boolean = true); overload;


    //������ ������ ������������� ��������� ��������� �� ����� �������� ������������, ���� �� ���� ��� ��������, ��� Force
    //�������� ������������� ��� ������ �������� ��� ����� ������� ������� � �����-���������
    procedure ReadControlValues(Force: Boolean = False);
    //������ �������� � ���� �������� ������������; ���������� ������������� ��� �������� �������� ��� ���������� ������
    procedure WriteControlValues;
    //������������ �������� ��������� � ���������� ������ (��������, ����������...), � ����������� �������, ���������, ���������� (x, y (yrefT))
    //���������� ��� ������, ���� ������� �� �������, �� ��� ��������� � ����������� �� �������,
    //������ �� ��������� � �������� ���������, � �� ������ ������ 32.
    //����� ������ � ���������� ����������� � ������ ������, ��� ������ ���� ���� 'PTopBtnsCtl2'.
    //���� ��� - ������ �����, �� ������������ ��� ��� ������� � ������� ������.
    procedure CreateAddControls(ParentName: string; CType: TMyControlType; CLabel: string = ''; CName:
      string= ''; CVerify: string = ''; x: Integer = 1; y: Integer = yrefC; Width: Integer = 0; Tag: Integer = 0);
    //��������� ������ �������� ����� (�������, ������, �������, ��������...) �� ������ ������� Opt.Fields ������
    //���������� ������������� ��� �������� ��������, �� ����� ���� ������ ������� � ������ ���� ����
    //��������� ���������� ������ Opt.SetColFeature
    //������� ������ � ����������� ��������, ������� ������ �������������
    procedure SetColumnsPropertyes;
    //������� ������ ���� �������
    procedure RefreshGrid;
    //��������� ������� ������ �����, ��� ������ ������ ��������� �� ��������� ������
    //������ False � ������ ����������� ������ � ��, ��� ���� ��� ���� �� ���������������� ����� ����� ����������
    function  RefreshRecord: Boolean;
    //������������� ����������� ������ � ���� ��� ��������� ������/�������, � ����������� � Opt.FButtonsIfEmpty; ������ ���������� � ChangeSelectedData
    procedure SetButtonsState;
    //������ ��������� ������ ��� ��� ������ (��� SpeedButton ������ Hint), � �������� Enabled,
    //������ ������� � ���������� ����������� �� ����
    //����� �� ������ ������ ��� ����� ���������, � ������ ����� ������� null!
    procedure SetBtnNameEnabled(ATag: Integer; AName: Variant; AEnabled: Variant);
    //��������/������ �������, � ����������� � �� �����������
    procedure SetColumnsVisible;
    //���������� ������� �� ������� � ��������� ����� � Opt.FrozenColumn ,������������; ���� ������ - ����� ���������
    //���������� � SetColumnsVisible
    procedure FrozeColumn;
    //��� ������ �������� - �������� ���� � ������� ���������� �����
    procedure BeginOperation(AMessage: string = '');
    //��� ������ �������� - ��������� (������ ����� � ���������)
    procedure EndOperation(AMessage: string = '');
    //����� �������� ST-Filter � ������������ ���, � ��� ��������������, �������� �� ��� ��� �� Ctrl-Q
    procedure ClearOrRestoreFilter;
    //��������� �������� ����� �� ������ �����
    procedure SetGridLabel(Mode: Integer = 0);
    //������� � ���������� ������ (+1 - ����, -1 = �����)
    procedure GoToGridLabel(Mode: Integer = +1);
    //���������� ������� ����� (���������, ������, ������ ������). �������� ������ ����� ��� ���������.
    //���� �������� �������� ��� null, �� ��� �� ��������
    procedure SetState(AIsDataChanged, AHasError, AErrorMessage: Variant);
    //���������� ������������ ���� � ����������; ���� ������, �� ����� ���������� ���������
    procedure SetStatusBarCaption(Caption: string = ''; AProcessMessages: Boolean = False);
    //�������� �������� �������� �� ������ �� ��� �����
    //���� ����������� NullIfEmpty �� ������� null ���� �������� ����� ������ ��� ''
    function  GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
    //���������� �������� �������� �������������� ������ �� ����������� ����� ��������
    procedure SetControlValue(ControlName: string; Value: Variant);
    //������ ������ � ������� � ������� �������
    function InsertRow: Boolean;
    //���������� ������ � ����� �������
    function AddRow: Boolean;
    //�������� ������
    function DeleteRow: Boolean;
    //��������, ��� ��� ���� ������ ������ (����� ���������, ������ � ����������� � _)
    function IsRowNotEmpty(RowNum: Integer = -1): Boolean;
    //�������� ������������ ������
    function IsRowCorrect(RowNum: Integer = -1): Boolean;
    //�������� ����, ��� ��� ������� ����� (�� ���������� ��������� �����)
    function IsTableEmpty: Boolean;
    //�������� ������������ ���� �������
    function IsTableCorrect: Boolean;
    //�������� ���������
    procedure Test;

    {�������, ���������� ��������� �� ����� ������ ��� ��������� ������}

    //�������� ������ � �������� � ����������� ���� �� ��������� ���������� ����������
    function  SetButtonsAndMenu: Integer;
    //��������� ��������� � ������� ������� ������
    procedure SetPanels;
    //���������� ������� ������ ��� ������������
    //�������� ������, ��� ��� ����� �������� �� ������� � �������� ������ (�������� ��-�� ���������� ������� �� ������ �������)
    procedure SetDataDriverCommandSelect;
    //�������� ������� ������������
    procedure SetDataDriverCommands;
    //���������� ��������� ������� CommandType (���������� ������� ����� ;)
    //���� �������� �� ������ � �������, �� �� ������������
    procedure SetSqlParameters(ParamNames: string; ParamValues: TVarDynArray; CommandType: string = 's');
    //�������� �� ���� �������, ����� ���� ���������� �������, ��� �������� ������ � ������� ������
    //��������� ��������� �������� ��� ���� (����������� ������...) � �������� �������������� ������� ������
    procedure ChangeSelectedData;
    //������������� ������� rorowDetailPanel; ���������� � ������� ������ ������
    procedure SetRowDetailPanelSize;
    //������ ����� ������� �� ��, ���������� � Prepare
    procedure ReadGridLabels;
    //�������� ����������-��������� �� �������� �������, ���� ��� ���� � ����������.
    //���������� � ����� �� F1
    procedure ShowColumnInfo;
    //����������� � �������� ��� ��������� ����������� �� ������ ��������; ���������� � SetColumnsPropertyes
    //������ �������� ��� ��������� ����� ��������� �����
    procedure DataGrouping;
 end;


implementation

uses
  madExcept,
  uErrors,
  uForms,
  uDBOra,
  uSettings,
  uWindows,
  uMessages,
  uSys,
  uLabelColors2,
  uFrmMain,
  uFrmBasicMdi,
  uFrmXWGridOptions,
  uFrmXDedtGridFilter
  ;



type TTest= Integer;

{$R *.dfm}


{
TFrDBGridEhOpt
}

constructor TFrDBGridEhOpt.Create(AOwner: TComponent);
//�������� ����� �����
//�������� ����� �� ���������
begin
  inherited Create;
  FrDBGridEh := AOwner;
  //�������� ��������� �� ���������
  //�� ��������� ��������� ������ ������ � �����
  TFrDBGridEh(FrDBGridEh).DbGridEh1.AllowedOperations := [alopUpdateEh];
  //������, ������� �������� ��� ������ �����
  FButtonsIfEmpty := [btnRefresh, btnAdd, btnGridFilter, btnGridSettings];
end;

procedure TFrDBGridEhOpt.SetFields(AFields: TVarDynArray2);
var
  i, j, k: Integer;
  st, st1: string;
  va1, va2, va3: TVarDynArray;
  fr: TFrDBGridRecFieldsList;

function GetNext: Boolean;
var
  i1, i2: Integer;
begin
  Result := True;
  //��������� ��� ������� ��������, ������� � ��������
  while (j <= High(FSql.FieldsDef[i])) and (uString.S.VarType(FSql.FieldsDef[i][j]) = varBoolean) do
    inc(j);
  if j > High(FSql.FieldsDef[i]) then Exit;
  //���� ��������� ������� ����� � ��� ����, �������� �� ��������� (����� �� ������������ ������� ��������)
  if (j < High(FSql.FieldsDef[i])) and (uString.S.VarType(FSql.FieldsDef[i][j + 1]) = varBoolean) and (FSql.FieldsDef[i][j + 1] = False) then
    inc(j);
  if j > High(FSql.FieldsDef[i]) then Exit;
  Result := False;
end;

begin
  FSql.FieldsDef := AFields;
  FSql.Fields:=[];
  if Length(FSql.FieldsDef) = 0 then begin
    va1:= A.Explode(FSql.FieldNames, ';');
    if (Length(va2) = 0) then va2:= va1;
    va2:= A.Explode(FSql.Captions, ';');
    if (Length(va1) = 0) or (Length(va1) <> Length(va2)) then Exit;
    for i:= 0 to High(va1) do
      FSql.FieldsDef:= FSql.FieldsDef + [[va1[i], va2[i], '', true]];
  end;
  {
  for i:= 0 to High(FSql.FieldsDef) do begin
    SetLength(FSql.FieldsDef[i], 10);
    for j:= 0 to 2 do
      if VarIsClear(FSql.FieldsDef[i][j]) then FSql.FieldsDef[i][j]:= '';
    if VarIsClear(FSql.FieldsDef[i][3]) then FSql.FieldsDef[i][3]:= true;
  end;}
  for i:= 0 to High(FSql.FieldsDef) do begin
    //������ ������� ������� ������ ����������� ����, ��������� ��� �� ������������
    fr.FullName := FSql.FieldsDef[i][0];
    Q.ParseFieldNameFull(FSql.FieldsDef[i][0], st, fr.Name, fr.NameDb, st, fr.DataType, fr.FieldSize);
    //������ ������� ������ ���������
    fr.Caption:= FSql.FieldsDef[i][1];
    //���� ���������� � ������������� - ��� ��������� ����
    fr.Invisible:=Pos('_', fr.Caption) = 1;
    //���� ������ ������� (����� ��� ���� � ���������) �������, � �� False, �� ���� �� ����� ������
    if (High(FSql.FieldsDef[i]) >= 2) and (uString.S.VarType(FSql.FieldsDef[i][2]) = varBoolean) and (FSql.FieldsDef[i][2] = False) then begin
      Continue;
    end;
    j := 1;
    SetFrValue(fr, 'D');
    SetFrValue(fr, 'CHB');
    SetFrValue(fr, 'CHBT');
    SetFrValue(fr, 'PIC');
    SetFrValue(fr, 'BT');
    SetFrValue(fr, 'E');
    SetFrValue(fr, 'V');
    SetFrValue(fr, 'F');
    SetFrValue(fr, 'NULL');
    SetFrValue(fr, 'T');
    SetFrValue(fr, 'I');
    fr.Visible := True;
//    SetFrValue(fr, '');
    repeat
      if GetNext then
        Break;
      SetFrValue(fr, FSql.FieldsDef[i][j], True);
      inc(j);
    until False;
    FSql.Fields := FSql.Fields + [fr];
  end;
  FSql.FieldNames:=''; FSql.Captions:='';
  for i:= 0 to High(FSql.Fields) do begin
    uString.S.ConcatStP(FSql.FieldNames, FSql.Fields[i].Name, ';');
    uString.S.ConcatStP(FSql.Captions, FSql.Fields[i].Caption, ';');
  end;
  if FSql.IdField =''
    then FSql.IdField:= FSql.Fields[0].Name;
end;

procedure TFrDBGridEhOpt.SetColFeature(AFields: string; AFeatype: string; ASet: Boolean = true; AClearOther: Boolean = False);
var
  i, j, k : Integer;
  st, st1: string;
  va: TVarDynArray;
begin
  if AClearOther then
    for i := 0 to High(FSql.Fields) do
      SetFrValue(FSql.Fields[i], AFeatype, False);
  va := A.Explode(AFields, ';');
  for j := 0 to High(va) do
    for i := 0 to High(FSql.Fields) do
      if (FSql.Fields[i].Name = va[j]) or uString.S.InCommaStr(va[j], FSql.Fields[i].FTags, ',') then
        SetFrValue(FSql.Fields[i], AFeatype, ASet);
end;

procedure TFrDBGridEhOpt.SetButtons(AIndex: Integer; AButtons: TVarDynArray2; AType: Integer = 1; APanel: TPanel = nil; AHeight: Integer = 0; AVertical: Boolean = False);
begin
  if High(FButtons) < AIndex then SetLength(FButtons, AIndex + 1);
  FButtons[AIndex].A := AButtons;
  FButtons[AIndex].T := AType;
  FButtons[AIndex].P := APanel;
  FButtons[AIndex].V := AVertical;
  FButtons[AIndex].H := AHeight;
end;

procedure TFrDBGridEhOpt.SetButtons(AIndex: Integer; AButtons: string = ''; ARight: Boolean = True);
const
  CButtons = 'rveacdo';
begin
  if AButtons = ''
    then AButtons := CButtons
    else if Pos('+', AButtons) = 1
      then AButtons := CButtons + Copy(AButtons, 2);
  SetButtons(AIndex, [
    [btnSelectFromList, Pos('l', AButtons) > 0], [], [btnRefresh, Pos('r', AButtons) > 0], [], [btnView, Pos('v', AButtons) > 0], [],
    [btnEdit, (Pos('e', AButtons) > 0) and ARight], [btnAdd, (Pos('a', AButtons) > 0) and ARight],
    [btnCopy, (Pos('c', AButtons) > 0) and ARight], [btnDelete, (Pos('d', AButtons) > 0) and ARight], [],
    [btnGridFilter, (Pos('f', AButtons) > 0)], [], [btnGridSettings, (Pos('s', AButtons) > 0)], [],
    [btnCtlPanel, (Pos('p', AButtons) > 0)]
  ]);
end;

procedure TFrDBGridEhOpt.SetTable(AView: string; ATable: string = ''; AIdField: string = ''; ARefreshBeforeSave: Boolean = True; ARefreshAfterSave: Boolean = True);
begin
  FSql.View := AView;
  FSql.Table := ATable;
  if (FSql.Table = '') and (Pos('v_', FSql.View) <> 1) then
    FSql.Table := FSql.View;
  if FSql.Table = '*' then
    FSql.Table := FSql.View;
  if AIdField <> '' then
    FSql.IdField := AIdField;
  FSql.RefreshBeforeSave := ARefreshBeforeSave;
  FSql.RefreshAfterSave := ARefreshAfterSave;
end;

procedure TFrDBGridEhOpt.SetSql(ASelect: string = ''; AGetRec: string = ''; AUpdate: string = ''; AInsert: string = ''; ADelete: string = '');
begin
  FSql.Select := ASelect;
  FSql.GetRec := AGetRec;
  FSql.Update := AUpdate;
  FSql.Insert := AInsert;
  FSql.Delete := ADelete;
end;

procedure TFrDBGridEhOpt.SetWhere(AWhereAllways: string = '');
begin
  FSql.WhereAllways := AWhereAllways;
end;

procedure TFrDBGridEhOpt.SetDataMode(ADataMode: TFrDBGridDataMode = myogdmWithAdoDriver);
begin
  FDataMode:= ADataMode;
end;

procedure TFrDBGridEhOpt.SetGridOperations(AOperations: string = 'u');
//���������� ��� ����� ��������
//���������� ������� � ����� ��������, ������� �����-���� �������� ��������� �� ('uiad')
//���� ��� ������� �� �������, � ����� ����� ��������� alopUpdateEh
begin
  AOperations := UpperCase(AOperations);
  TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := [];
  if Pos('U', AOperations) > 0 then
    TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations + [alopUpdateEh];
  if Pos('U', AOperations) > 0 then
    FAllowedOperations := FAllowedOperations + [alopUpdateEh];
  if Pos('I', AOperations) > 0 then
    FAllowedOperations := FAllowedOperations + [alopInsertEh];
  if Pos('D', AOperations) > 0 then
    FAllowedOperations := FAllowedOperations + [alopDeleteEh];
  if Pos('A', AOperations) > 0 then
    FAllowedOperations := FAllowedOperations + [alopAppendEh];

{  if Pos('I', AOperations) > 0 then
    TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations + [alopInsertEh];
  if Pos('D', AOperations) > 0 then
    TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations + [alopDeleteEh];
  if Pos('A', AOperations) > 0 then
    TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations := TFrDBGridEh(FrDBGridEh).DBGridEh1.AllowedOperations + [alopAppendEh];}
end;

procedure TFrDBGridEhOpt.SetGrouping(AFields: TVarDynArray; AFonts: TFontsArray; AColors: TColorsArray; AActive: Boolean);
//�����������
//���������� ���� � ������ ���������� �����������. ���� ���� �� �������� - ��� �� ����������.
//���� ����� ��� ����������� ��� - ��� �� ���������
begin
  if Length(AFields) > 0
    then FDataGrouping.Fields := AFields;
  FDataGrouping.Fonts := AFonts;
  FDataGrouping.Colors := AColors;
  if Length(FDataGrouping.Fields) > 0
    then FDataGrouping.Active := AActive
    else FDataGrouping.Active := False;
end;

procedure TFrDBGridEhOpt.SetPick(AFieldName: string; APickList: TVarDynArray; AKeyList: TVarDynArray; ALimitTextToListValues: Boolean; AAlwaysShowEditButton: Boolean = True);
//��������� ������ � ������ ����������� ���������� ������� � �������� �����
var
  i: integer;
  rec: TFrDBGridEhPickRec;
begin
  i := 0;
  while (i <= High(FPickLists)) and (FPickLists[i].FieldName <> AFieldName) do
    inc(i);
  if i > High(FPickLists) then
    FPickLists := FPickLists +[rec];
  FPickLists[i].FieldName := AFieldName;
  FPickLists[i].PickList := APickList;
  FPickLists[i].KeyList := AKeyList;
  FPickLists[i].LimitTextToListValues := ALimitTextToListValues;
  FPickLists[i].AlwaysShowEditButton := AAlwaysShowEditButton;
end;


procedure TFrDBGridEhOpt.SetButtonsIfEmpty(AButtonsIfEmpty: TVarDynArray);
//��������� ������, ������� �������� ��� ������ �����. ���� �� ���������� - ��� ����� ������ �� ���������
//���������� ������ ���������� � ��� ��� �� ���������!. ����� ��������, ������� ��������� ������ ������!
begin
  if Length(AButtonsIfEmpty) = 0
    then FButtonsIfEmpty := []
    else FButtonsIfEmpty := FButtonsIfEmpty + AButtonsIfEmpty;
end;

procedure TFrDBGridEhOpt.SetPanelsSaved(APanelsSaved: TVarDynArray);
begin
  FPanelsSaved := APanelsSaved;
end;

procedure TFrDBGridEhOpt.SetFieldVisible(AFieldName: string; AVisible: Boolean);
//��������������� ���������
//��������� ����� ��� ��������� �������� ��������� ������� � ������� ������� ����� �� ������� �������� (���� ��������, ������ �������� �� ��)
var
  i: Integer;
begin
  for i := 0 to High(FSql.Fields) do
    if S.CompareStI(AFieldName, FSql.Fields[i].Name) then begin
      FSql.Fields[i].Visible := AVisible;
      Exit;
    end;
end;

function TFrDBGridEhOpt.GetFieldRec(AFieldName: string): TFrDBGridRecFieldsList;
var
  i: Integer;
begin
  for i := 0 to High(FSql.Fields) do
    if S.CompareStI(AFieldName, FSql.Fields[i].Name) then begin
      Result := FSql.Fields[i];
      Exit;
    end;
end;

procedure TFrDBGridEhOpt.SetFrValue(var fr: TFrDBGridRecFieldsList; AValue: string; ASet: Boolean = False);
var
  i, j, k: Integer;
  st, st1: string;
begin
  st := uString.A.Explode(uString.S.ToUpper(AValue), '=')[0];
  k := Length(st);
  if Pos('=', AValue) = k + 1 then
    Inc(k);
  st1 := Copy(AValue, k + 1);
  if (st = 'D') then
    if ASet
      then fr.DefOptions := st1
      else fr.DefOptions := '';
  if uString.S.IsInt(Copy(AValue, 1, 1)) then
    if ASet
      then fr.DefOptions := AValue
      else fr.DefOptions := '';
  if (st = 'CHB') then
    if ASet then begin
      fr.FChb := True;
      fr.FChbPic := st1;
    end
    else begin
      fr.FChb := False;
      fr.FChbPic := '';
    end;
  if (st = 'CHBT') then
    if ASet then begin
      fr.FChbt := True;
      fr.FChbtPic := st1;
    end
    else begin
      fr.FChbt := False;
      fr.FChbtPic := '';
    end;
  if (st = 'PIC') then
    if ASet
      then fr.FPic := uString.S.IIf(st1 = '', '1', st1)
      else fr.FPic := '';
  if (st = 'BT') then
    if ASet
      then fr.FBt := st1
      else fr.FBt := '';
  if (st = 'E') then
    if ASet then begin
      fr.Editable := True;
      if st1 <> '' then
        fr.FVerify := st1;
    end
    else
      fr.Editable := False;
  if (st = 'V') then
    if ASet
      then fr.FVerify := st1
      else fr.FVerify := '';
  if (st = 'F') then
    if ASet
      then fr.FFormat := uString.S.IIf(st1 = '', 'r', st1)
      else fr.FFormat := '';
  if (st = 'NULL') then
    if ASet
      then fr.FIsNull := True
      else fr.FIsNull := False;
  if (st = 'I') then
    if ASet
      then fr.Invisible := True
      else fr.Invisible := False;
  if (st = 'T') then
    if ASet
      then fr.FTags := st1
      else fr.FTags := '';
end;










{===============================================================================

      TFrDBGridEh

===============================================================================}


{
����������� � ����������
}

constructor TFrDBGridEh.Create(AOwner: TComponent);
//�����������
begin
  inherited Create(AOwner);
  FOpt := TFrDBGridEhOpt.Create(Self);
  FDynProps := TDynVarsEh.Create(Self);
  FDynProps.CreateDynVar('vvv', 'qqq');
  PStatus.Height := 1;
  ColumnTemp := nil;
end;

destructor TFrDBGridEh.Destroy;
//����������
begin
  //��������� �������� ������, ���� ������� ��� ������
  //���� � ������� �������� ���������� ���������� ��������, �� ������� �� ��������� ��� �����������, ����� ���� ����� ���� ��������� MemTableEh1.Close !
  if (TFrmBasicMdi(Owner).FormDoc <> '') and (myogSaveOptions in Options) and (MemTableEh1.Active) then
    Settings.WriteFrDBGridEhSettings(TFrmBasicMdi(Owner).FormDoc, Self, False);
  if (TFrmBasicMdi(Owner).FormDoc <> '') then
    WriteControlValues;
  //����������� �������������� �������
  FOpt.Destroy;
  FDynProps.Destroy;
  if ColumnTemp <> nil then
    ColumnTemp.Destroy;
  inherited;
//  MadExcept.GetLeakReport;
end;

{
������� ������
}

procedure TFrDBGridEh.FrameResize(Sender: TObject);
//��� ��������� �������� ������
var
  c, p: TControl;
begin
  //������������� ������ (�������� �� ������������ �����, ���� �� ������ �� ��������� � ���� �������, �� ���������������� �� ��������)
  PGrid.Left:=PLeft.Left + PLeft.Width;
  PGrid.Width:=PTop.Width - PLeft.Width;
  PGrid.Top:=PTop.Top + PTop.Height;
  PGrid.Height:=PLeft.Height;
  //���� ���� ������ ��������� (������ � ������� ������ ������), �� ������� �� ���������)
  c:=TControl(FindComponent('ImgInfo'));
  if c <> nil then begin
    c.Left := PGrid.Width - 36;
    //������ ������, ���� ���� ��� ������
    c.Visible := c.Left > TControl(FindComponent('PTopBtns')).Width;
  end;
end;

procedure TFrDBGridEh.TimerAfterStartTimer(Sender: TObject);
//������� ������� ����� �������� ������
//���� ����������� � ������, �� ������� ������� ���� � �������, � ������� �������� ���� ��� ������
//(�������� ������ �� ������������� �������)
//� ����� ���������� ������, ��� ������������ �������� � ���������� �����
begin
  if not (myogLoadAfterVisible in Options) then begin
    TimerAfterStart.Enabled := False;
    Exit;
  end;
  if not TForm(Self.Owner).Visible then
    Exit;
  TimerAfterStart.Enabled := False;
  RefreshGrid;
end;

procedure TFrDBGridEh.PStatusResize(Sender: TObject);
//����������� �������� ������ ���������/������ � ����������.
//���� �� ������ ������ �����, ���������� ��� ��������� ��������.
begin
  ImGState.Left := PStatus.Width - 18;
end;


{
������� ���������
}

procedure TFrDBGridEh.MemTableEh1AfterDelete(DataSet: TDataSet);
begin
//  IsTableCorrect;
end;

procedure TFrDBGridEh.MemTableEh1AfterInsert(DataSet: TDataSet);
begin
  if InLoadData then
    Exit;
//  Mth.PostAndEdit(MemTableEh1);
//  IsRowCorrect;
//  IsTableCorrect;
end;

procedure TFrDBGridEh.MemTableEh1AfterOpen(DataSet: TDataSet);
//������� ��� �������� ��������
begin
  //������ ���� ��� �������� ������ �� �������
  if InLoadData then
    Exit;
  //��������� ������� ��� �������� �����
  SetColumnsAndEvents;
  //��������� �������� �������� �����, �������� � ���������� �������� � ����
  SetColumnsPropertyes;
  //��������� ��������� ����� � ��������, ����������� � �� ��� ������������
  if (TFrmBasicMdi(Owner).FormDoc <> '') and (myogSaveOptions in Options) then
    Settings.RestoreFrDBGridEhSettings(TFrmBasicMdi(Owner).FormDoc, Self);
  //����� ��� �������� ����� �������� ������
  SetColumnsVisible;
  //��������� ����
  FIsPrepared := True;
  //�������� ����� �����
  SetOptions(Options);
  //��������� ����
  if myogSorting in Options then
    DBGridEh1.DefaultApplySorting;
  //�������� ������� �������
  DBGridEh1.DefaultApplyFilter;
  //������� ����������� ������
  ChangeSelectedData;
end;

procedure TFrDBGridEh.MemTableEh1AfterPost(DataSet: TDataSet);
//����� ���������� Post;
begin
  if not ((alopInsertEh in FOpt.AllowedOperations) or (alopAppendEh in FOpt.AllowedOperations)) or
    (GetValue(FOpt.Sql.IdField) <> null) or (FOpt.DataMode = myogdmWithAdoDriver) then
    Exit;
  //������ ���� ���� ��������� ������ � �������-������ - ������� ����, ���� �� ��� �����
  //(��� ����� �������� ��� ����������)
  inc(FEditData.IdAdded);
  SetValue(FOpt.Sql.IdField, MY_IDS_INSERTED_MIN + FEditData.IdAdded);
end;

procedure TFrDBGridEh.MemTableEh1BeforeClose(DataSet: TDataSet);
//������� ����� ��������� ��������
//�������� ��������� ����� � �������� �������������� ���������
begin
  //�������� ��������� ����� ��� ������������, � ������, ���� �������� ��� �������
  if (TFrmBasicMdi(Owner).FormDoc <> '') and (myogSaveOptions in Options) and (MemTableEh1.Active) then
    Settings.WriteFrDBGridEhSettings(TFrmBasicMdi(Owner).FormDoc, Self, False);
  //�������� �������� �������������� ���������
  if (TFrmBasicMdi(Owner).FormDoc <> '') then
    WriteControlValues;
  //������ ������� ��������� ������ � ����� � ������
  SetState(False, False, '');
  //������� ����
  FIsPrepared := False;
end;

procedure TFrDBGridEh.MemTableEh1BeforeInsert(DataSet: TDataSet);
begin
  //
end;

procedure TFrDBGridEh.MemTableEh1AfterScroll(DataSet: TDataSet);
//������� ��� ����������� �� ������� ��������
begin
  if InLoadData then Exit;
  FLastRecNo:=MemTableEh1.RecNo;
  ChangeSelectedData;
end;

{
������� ���������
}

procedure TFrDBGridEh.DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh;
  const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
//��������� ������
//����� ������������ ��������� ������� ������������ ������ � �������������� �������,
//� ������� ����� ���� ������� ������ �������������
var
  Rect: TRect;
begin
{
//��� ����� ���������� ������������ �� ��������� ������
//�� ���������� �����������, ��� ���������� ������ ��� ��������� � ������������ �������������� �� ����������
DbGridEh1.OptionsEh:=DbGridEh1.OptionsEh - [dghHighlightfocus, dghRowHighlight, dghHotTrack];
DbGridEh1.Options:=DbGridEh1.Options - [dgalwaysshowselection, dgalwaysshowEditor];
DbGridEh1.ShowHint := false;
if (areacell.y <= 3) and (areacell.X = 2) then begin
DbGridEh1.OptionsEh:=DbGridEh1.OptionsEh - [dghHighlightfocus, dghRowHighlight];
     Rect := ARect;
        Rect.Top := Rect.Top - 18*areacell.y;
        Rect.Height := 18*3;
      DBGridEh1.Canvas.FillRect(Rect);
      DBGridEh1.Canvas.TextOut(Rect.Left, Rect.Top + 2, 'QQQQQQQQQQ');
    end
    else
    Sender.DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
exit;
}
  if IsColumnEditable(Column.FieldName) then begin
    //�������� ������� ������� ����� ��� �������������� �������
    Sender.DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
    if myogHiglightEditableColumns in Options then
 //���� ����� ���������, �� ����� ������������ ������������ ������� ������ � ������������� ������, �� ��� ����� ���������, ���� ������������
 //     if not Params.ReadOnly then
      with Sender.Canvas, ARect do begin
        if A.InArray(IntToStr(Cell.Y) + '-' + IntToStr(Cell.X), FEditData.CellsWithErrors)
          then Pen.Color := Rgb(255, 0, 0)
          else Pen.Color := Rgb(150, 255, 150);
        Pen.Style := psSolid;
        MoveTo(Left + 1, Top);
        LineTo(Left + 1, Bottom);
        MoveTo(Left + 2, Top);
        LineTo(Left + 2, Bottom);
        MoveTo(Left + 3, Top);
        LineTo(Left + 3, Bottom);
        MoveTo(Left + 4, Top);
        LineTo(Left + 4, Bottom);
      end;
    Processed := True;
    //��������� ������ �� �������, �� ������� ��� ������� � MemTableEh1AfterScroll (FRecNo)
    //��������� ����� ������������ � ��� ������ �������������� �������, ���� ������ ��� ��������,
    //�� ��� �������� ������������ �� ����� (����� �������������)
    if MemTableEh1.Active and (MemTableEh1.RecordCount > 0) and (LastRecNo = RecNo) and (Column.Index = GetCol) //DBGridEh1.Col - S.IIf(myogIndicatorColumn in FOptions, 1, 0))
      and (myogHiglightEditableCells in Options) then begin
      if not Params.ReadOnly then
        //�������� ������� ������� ����� � ������� (���������) ������, ���� ��� �������������
        with Sender.Canvas, ARect do begin
          Pen.Color := Rgb(150, 255, 150);
          Pen.Style := psSolid;
          MoveTo(Left, Bottom);
          LineTo(Right, Bottom);
          MoveTo(Left, Bottom - 1);
          LineTo(Right, Bottom - 1);
          MoveTo(Left, Bottom + 1);
          LineTo(Right, Bottom + 1);
        end;
      Processed := True;
    end;
  end;
  //�������� ��� ��������� ����������, �� ���� ����� ��� ������� ������ ��� ������ � ������� ������
  //����� �� �������������� ��������� ��� ������ ��������� ������ �����, ������ ��� ������ ��� ������ ������� ��� ��� ��������� ������� ������ ��������
  if ((MemTableEh1.RecordCount = 0) or (Cell.Y = MemTableEh1.RecNo){ or DbGridEh1.DataGrouping.Active})
    then PrintStatusBar;
  //��� ����� �����������/���������� ������� ��� ������ ������ � SearchPanel
  //� ������� SearchPanel onChange ������� �����������, �.�. ��� ����������� �� ���������� ��������,
  //� ������� AfterScroll � �������� ��� ������� �� ����������
  if (MemTableEh1.RecordCount <> FLastRecordCount) then begin
    FLastRecordCount := MemTableEh1.RecordCount;
    ChangeSelectedData;
  end;
end;

procedure TFrDBGridEh.DbGridEh1ApplyFilter(Sender: TObject);
begin
  FLastFilterClick := False;
  DBGridEh1.DefaultApplyFilter;
end;

procedure TFrDBGridEh.DbGridEh1CellClick(Column: TColumnEh);
//������� �� ����� �� �������
begin
  ChangeSelectedData;
end;

procedure TFrDBGridEh.DbGridEh1CellMouseClick(Grid: TCustomGridEh; Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Processed: Boolean);
//���� ���� � ����� ������� �����
var
  i, j, k : Integer;
  ACol, ARow: Integer;
  AreaCol, AreaRow: Integer;
  Area: TCellAreaTypeEh;
begin
  //������� ��������� �������
  Area := DBGridEh1.GetCellAreaType(ACol, ARow, AreaCol, AreaRow);
  if Area.VertType = vctDataEh then;
  //Area.HorzType/VertType  ��� ������ ���������� �����, �� �� ��������! ���������� �����������, � � ������ �������� ��-�������
  //���������� ���
  if myogColumnFilter in Options then
    if (Area.HorzType = hctDataEh) {and (Area.VertType = vctDataEh)} and (Cell.Y > 0) and (Button = mbLeft) and FLastFilterClick then begin
      //���� ���� ������ ������ ������� � �� �� ���������� (� ������� OnApplyFilter ���� ���������)
      //�� �������� ������ �� ����� � ��������� ����� �����
      DbGridEh1.DefaultApplyFilter;
      FLastFilterClick := False;
    end;
  if myogColumnFilter in Options then
    if (Area.HorzType = hctDataEh) {and (Area.VertType = vctDataEh)} and (Cell.Y = 0) and (Button = mbLeft) then begin
      //������� ����� �������, ������� �����������, ���� ���� �������������, �� ��� ���� ����� -1
      k := GetCol(Cell.X);
      if (k >= 0) and (X >= DBGridEh1.Columns[GetCol(Cell.X)].Width - 16) then begin
        //��� ������ �������� ��������� ��������, �� �� ��������!
        Processed := True;
        //��������, ��� ��� ����� ����� ����� ������
        FLastFilterClick := True;
        //MyInfoMessage(inttostr(Cell.X) + '  ' + DBGridEh1.Columns[GetCol(Cell.X)].Title.Caption);
      end;
    end;
  //������ ����� � ������������ �������, ��� ������, ����� ��� ������ ���� ������������ (hctIndicatorEh ����� �� ��������)
  if (Area.HorzType = hctDataEh) {and (Area.VertType = vctDataEh)} and (Cell.Y > 0) and (Cell.X = 0) and (Button = mbLeft) then begin
    if ((myogIndicatorCheckBoxes in Options) and not (myogMultiSelect in Options)) then  begin
      DBGridEh1.SelectedRows.Clear;
      DBGridEh1.SelectedRows.CurrentRowSelected := True;
    end;
    ChangeSelectedData;
    PrintStatusBar;
  end;
end;

procedure TFrDBGridEh.DbGridEh1ColEnter(Sender: TObject);
//������� ��� �������� � �������
begin
  ChangeSelectedData;
end;

procedure TFrDBGridEh.DbGridEh1ContextPopup(Sender: TObject; MousePos: TPoint;  var Handled: Boolean);
//���� ������� ��� ������ ����������� ����
begin
  ChangeSelectedData;
  inherited;
end;

procedure TFrDBGridEh.DbGridEh1DblClick(Sender: TObject);
//������� ���� �� �����
var
  Handled: Boolean;
  BtnE, BtnV: TSpeedButton;
  T: Tpoint;
  MouseTop, MouseLeft: Integer;
  c: TComponent;
  i, j: Integer;
const
  MouseLeftIgnore = 70;
begin
   //������� ��������� ������� ���� ������������ �����
  T := ScreenToClient(Self.FDesignSize);
  MouseTop := Mouse.CursorPos.Y + T.y;
  MouseLeft := Mouse.CursorPos.X + T.x;
//  if DBGridEh1.DataGrouping.Active and (DBGridEh1.Col < 4) then Exit;
  //���� ���� ��������������, �� �������� � ������ ���� �������������, ��� ��� ����� ��� ����� �� + ����������� ���� ��������������
  //���� ��� ��� �������� ���� ��������� � ��������� ������
  if DBGridEh1.RowDetailPanel.Active and (MouseLeft < MouseLeftIgnore) then
    Exit;
  //������� �������
  if Assigned(FOnDbClick) then
    FOnDbClick(Self, No, Sender, Handled);
  //������, ���� ����������
  if Handled then
    Exit;
  //������� ������� � ��������� ������ (��� ��� ���� � ����)
  c := nil;
  for j := PmGrid.ComponentCount - 1 downto 0 do begin
    c := PmGrid.Components[j];
    if (c.Tag = btnSelectFromList) and (TMenuItem(c).Enabled) then
      Break;
  end;
  if j = -1 then
    for j := PmGrid.ComponentCount - 1 downto 0 do begin
      c := PmGrid.Components[j];
      if (c.Tag = btnEdit) and (TMenuItem(c).Enabled) then
        Break;
    end;
  if j = -1 then
    for j := PmGrid.ComponentCount - 1 downto 0 do begin
      c := PmGrid.Components[j];
      if (c.Tag = btnView) and (TMenuItem(c).Enabled) then
        Break;
    end;
  if (j >= 0) and (c <> nil) then
    TMenuItem(c).Click;
end;

procedure TFrDBGridEh.DbGridEh1FillSTFilterListValues(Sender: TCustomDBGridEh; Column: TColumnEh; Items: TStrings; var Processed: Boolean);
begin
  //������������ ������ ��� �����, ���������� ������� ������ - ���������� �� �������� � ������� � ������� ���� ������
  if Column.Field.DataType = ftDateTime then
    Gh.GridDateFilterModify(Sender, Column, Items, Processed, [S.ToLower(Column.FieldName)]);
end;

procedure TFrDBGridEh.DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh;
  AFont: TFont; var Background: TColor; State: TGridDrawState);
//����� ������������ ����� (������ ���� ������ ����� �������)
var
  i, labelnum: Integer;
  currid: Variant;
  color: Integer;
  b: Boolean;
begin
  //��������� ���������� ������, ���� ����� ������������
  if myogGridLabels in Options then begin
    currid := ID;
    labelnum := 0;
    for i := 0 to High(FGridLabelsIds) do
      if FGridLabelsIds[i][0] = currid then begin
        labelnum := FGridLabelsIds[i][1];
        Break;
      end;
    case labelnum of
      0:
        color := clWindowText;
      1:
        color := clRed;
      2:
        color := clBlue;
      3:
        color := clFuchsia; //clGreen; //clLime
    end;
    if Abs(AFont.Color) <> Abs(color) then begin
      AFont.Color := color;
    end;
  end;
end;

procedure TFrDBGridEh.DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//������� ������ � �����
var
  i: Integer;
  st: string;
begin
  //���������� ����� ��������� ����� �� Ctrl-F3, ��� ���������� ��� � DeveloperMode
  if (User.IsDeveloper or FrmMain.DeveloperMode) and (Key = VK_F3) and (Shift = [ssCtrl]) then begin
    FDevVisibleHidden := not FDevVisibleHidden;
    SetColumnsVisible;
  end;
  //�������� ������� ������
  if (Key = Ord('R')) and (Shift = [ssCtrl]) then
    RefreshRecord;
  //��������� ������� ������
  //�������������, ��� ��� ��������� ������ �� ��������, ���������� � ���������� ����
  if (Key = VK_F3) then
    DbGridEh1.DefaultApplyFilter;
  //��������� �� �������
  if (Key = VK_F1) then
    ShowColumnInfo;
  //����������� � ����� ������� ��������
  if (Key = Ord('C')) and (Shift = [ssCtrl]) then
    Clipboard.AsText := S.NSt(GetValue);
  if (Key = VK_DOWN) and (MemTableEh1.RecNo = MemTableEh1.RecordCount) then
    AddRow;
{  if (Key = VK_INSERT)  then
    InsertRow;}
end;

procedure TFrDBGridEh.DbGridEh1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//���� ������
begin
//
end;

procedure TFrDBGridEh.DbGridEh1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FMouseCoord := DbGridEh1.MouseCoord(X, Y);
end;

procedure TFrDBGridEh.DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
//��������� ��������� ������
begin
  if FGrid2 = nil then
    Exit;
  //��������� ������� ���������� ����� � ��������� � ��������� ������� (��������� ��������, ����)
  FGrid2.RefreshGrid;
  //����� ����� ��������� ������� ��������� ������, �������� ������ ������ � �����
  SetRowDetailPanelSize;
end;

procedure TFrDBGridEh.DbGridEh1RowDetailPanelHide(Sender: TCustomDBGridEh; var CanHide: Boolean);
//������� ��������� ������
var
  v : Variant;
begin
  if FGrid2 = nil then
    Exit;
  //����� ����� ��������� ������� ������ ���������� ����� � ��������� ��������� ������
  CanHide := not FGrid2.HasError and (FGrid2.ErrorMessage = '');
  if FGrid2.ErrorMessage <> '' then
    MyWarningMessage(FGrid2.ErrorMessage);
  if not CanHide then
    Exit;
  //��������� ���� �������?
  FIsGrid2Changed := FGrid2.IsDataChanged;
  FGrid2.MemTableEh1.Active := False;
  //���������� ������ ��������� �����, ���� ��� ������� ���������
  if FIsGrid2Changed then
    RefreshRecord;
end;

procedure TFrDBGridEh.DbGridEh1SearchPanelSearchEditChange(Grid: TCustomDBGridEh; SearchEdit: TDBGridSearchPanelTextEditEh);
//��������� ������ ������/������� ��� ��������
begin
  //����������� �� ������ ���������, �� ������� �������� ����� ����������� �������
//  ChangeSelectedData;
end;

procedure TFrDBGridEh.DbGridEh1SortMarkingChanged(Sender: TObject);
//���������� ��� ��������� �������� ���������� �����, �������� ������ �� ���������
//���� ����������, �� ���������� � ��� ���� �������� �������
begin
  inherited;
  //�������� �������� ����
  FKeyString := Gh.GetGridServiceFields(DBGridEh1);
  if FKeyString <> '' then
    DBGridEh1.SaveVertPos(FKeyString);
  //�������� ����������
  DBGridEh1.DefaultApplySorting;
  //����������� �������� ����, ���� ���� ��� �����, � ������� �������� ������
  if (FKeyString <> '') and (myogSavePosWhenSorting in Options) then
    DBGridEh1.RestoreVertPos(FKeyString);
  //���� ��� ����� ���������� �������, ���������� �����
  if not (myogSavePosWhenSorting in Options) then
    MemTableEh1.First;
  ChangeSelectedData;
end;


{
������� � ��������� ��� ��������� � ��������� ������� ���� ������� ���������� � ������� pRIVATE
}

function TFrDBGridEh.GetID: Variant;
//������� ���� ������� ������
//���� ������� ���������, ��� �� ������ ���� ����, ������ ����
begin
  Result := null;
  if MemTableEh1.Active and (FOpt.Sql.IdField <> '')
    then Result := MemTableEh1.FieldByName(FOpt.Sql.IdField).AsVariant;
end;

function TFrDBGridEh.GetRecNo: Integer;
begin
  Result := MemTableEh1.RecNo;
end;

function TFrDBGridEh.GetRecordCount: Integer;
begin
  Result := MemTableEh1.RecordCount;
end;


function TFrDBGridEh.GetCurrField: string;
//������� ������������ �������� ���� (���� ������ �������� �������) � ������ ��������
begin
//  Result := LowerCase(DBGridEh1.Columns[DBGridEh1.Col - S.IIf(myogIndicatorColumn in FOptions, 1, 0)].Field.FieldName);
  Result := LowerCase(DBGridEh1.Columns[GetCol].Field.FieldName);
end;

function TFrDBGridEh.GetCurrValue: Variant;
//������� �������� ������� ������ (unassigned ���� ������� �������� ��� � ��� ��� �����)
begin
  Result := GetValue;
end;

procedure TFrDBGridEh.SetOptions(Value: TFrDBGridOptions);
//��������� ������� ����� ����� Options � OptionsEh �� ������ ����� ����� � ��� ������������,
//������� � ��� �����������, ��� ��������� �������� ���� ������ � ��� �����������.
//����� ��������� ������������� ������� TFrDBGridEh.Options
var
  b: Boolean;
  i:Integer;
begin
  FOptions := Value;
  //�� ������������� ������� ������������� �� ����������� ����, � ������ ������ ����� ����� �����
  //��������� �� ����� ����� �������� � ��������� ����������� � ������
  if not FIsPrepared then
    Exit;
  //������ ������������� �������������:
  if True then begin

    //3D-����� �����
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghFixed3D, dghFrozen3D, dghFooter3D, dghData3D];
    //��������� ����������
    DBGridEh1.TitleParams.BorderInFillStyle := False; //True;
    //����������� �������
    DBGridEh1.TitleParams.FillStyle := cfstGradientEh;
    //����������� ���������� � ������������
    DBGridEh1.TitleParams.MultiTitle := True;
    //��� ������� ������� ����������, ��� ����������� �����
    if myogColoredTitle in FOptions then begin
      DBGridEh1.TitleParams.FillStyle := cfstGradientEh;
      if Module.StyleName = '' then DBGridEh1.TitleParams.SecondColor := clSkyBlue;
    end
    else begin
      DBGridEh1.TitleParams.FillStyle := cfstDefaultEh;
    end;
    //����� ���������� ����� ������
    //��� ��������� ����� ������, ��� ��� ����� (�����) ������
    if (myogColoredEven in FOptions)and(Module.StyleName = '') then begin
      DBGridEh1.EvenRowColor := clWindow;
      DBGridEh1.OddRowColor := clCream;
    end
    else DBGridEh1.OddRowColor := clWindow;
    //
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghResizeWholeRightPart];
  //  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghAutoSortMarking];
    //���������� �� ���������� ��������
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghMultisortMarking];
    //����������� �� ����� �� �����
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghEnterAsTab];
    //��������� ���� ������
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghRowHighlight];
    //��������� ������, ��� ������� ��������� ������
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghHotTrack];
    //�������� ����� ������ � ����
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghShowRecNo];
    //��������� � ���� ������
    DBGridEh1.ColumnDefValues.Title.TitleButton := True;
  //  DBGridEh1.IndicatorOptions:=[gioShowRowIndicatorEh,gioShowRecNoEh,gioShowRowselCheckboxesEh];
    DBGridEh1.ShowHint := True;
    {Column.ToolTips
    Column.Title.ToolTips
    Column.Title.Hint}
    DBGridEh1.ColumnDefValues.ToolTips := true;
    DBGridEh1.ColumnDefValues.Title.ToolTips := true;
    //����������� � �������� ������ ����� � ���, ��� ������� ���
    DBGridEh1.EmptyDataInfo.Active := True;
    DBGridEhEmptyDataInfoText := '������ �����������';
    //��������� ������ �������
    DBGridEh1.Options := DBGridEh1.Options - [dgRowSelect];
    //��������� ������ ������
    DBGridEhDefaultStyle.IsDrawFocusRect := False;
  end;
  //��������� ���������� � ����������
  DBGridEh1.SortLocal := True;
  //��������� ����������
  DBGridEh1.STFilter.local := True;
  //������ � ��������
  b := (myogColumnFilter in FOptions);
  DBGridEh1.STFilter.Visible := b;
  //������ � ��������� ������ (����� ��� ����������)
  DBGridEh1.STFilter.Location := stflInTitleFilterEh;
  //������� ������� ���������� � ��������, ���� ������ ����� �������
  if not (b) and MemTableEh1.Active then
    Gh.GridFilterClear(DbGridEh1, True, False);
  if b then begin
    //!!! �� ����� ���� �� ��� ��������
    DBGridEh1.STFilter.InstantApply := False;
  end;
  //������ ��� ����� � ������
  b:=(myogPanelFilter in FOptions) or (myogPanelFind  in FOptions); //(myogColumnFilter in FOptions) or
  DBGridEh1.SearchPanel.Visible := (myogPanelFilter in FOptions) or (myogPanelFind  in FOptions);
  DBGridEh1.SearchPanel.Enabled := b; //(myogPanelFilter in FOptions) or (myogPanelFind  in FOptions);
  //������ ������ ��������� ����, ����� �����+����������� ��������� � �����
  DBGridEh1.SearchPanel.FilterOnTyping := myogPanelFilter in FOptions;
  //���������� �� ����� �� �������
  if myogSorting in FOptions then
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghAutoSortMarking, dghMultiSortMarking]    //�������� ����������� ���������� (����� ���� ������ ��� �� �������� � ������ ��������� ����������, ���� ���-�� ����)
    //�������� ����������� ���������� (����� ���� ������ ��� �� �������� � ������ ��������� ����������, ���� ���-�� ����)
    else begin
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh - [dghAutoSortMarking, dghMultiSortMarking];
    end;
  //��������� ������� ��������
  if myogColumnMove in FOptions
    then DBGridEh1.OptionsEh := DBGridEh1.OptionsEh + [dghColumnMove]
    else DBGridEh1.OptionsEh := DBGridEh1.OptionsEh - [dghColumnMove];
  //��������� ������ ��������
  if myogColumnResize in FOptions
    then DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh + [dghColumnResize]
    else DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh - [dghColumnResize];
  //���� ��� ��� ������������ �������
  if myogIndicatorColumn in FOptions
    then DBGridEh1.IndicatorOptions := DBGridEh1.IndicatorOptions + [gioShowRowIndicatorEh, gioShowRecNoEh]
    else DBGridEh1.IndicatorOptions := DBGridEh1.IndicatorOptions - [gioShowRowIndicatorEh, gioShowRecNoEh];
  //���� ��� ��� �������� � ������������ ������� (� ���������� ������ ��� ������ ������, ���������� �������������� ��� ����� � �������)
  if myogIndicatorCheckBoxes in FOptions then begin
     DBGridEh1.IndicatorOptions := DBGridEh1.IndicatorOptions + [gioShowRowSelCheckBoxesEh];
     DBGridEh1.OptionsEh := DBGridEh1.OptionsEh - [dghClearSelection];
   end
   else begin
    DBGridEh1.IndicatorOptions := DBGridEh1.IndicatorOptions - [gioShowRowSelCheckBoxesEh];
   end;
   //��������������� ����� (� ������������ ���������)
   if myogMultiSelect in FOptions
     then DBGridEh1.Options := DbGridEh1.Options + [dgMultiSelect]
     else DBGridEh1.Options := DbGridEh1.Options - [dgMultiSelect];
   //������������ ������ �����
   if myogAutoFitRowHeight in FOptions
     then DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh + [dghAutoFitRowHeight]
     else DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh - [dghAutoFitRowHeight];
   //������������ ������ �������� ��� ���������� �������� ���� �������
   if myogAutoFitColWidths in FOptions then begin
     DBGridEh1.AutoFitColWidths := True;
     //!!!�������� �������. ��� ������ ������, ��� �������� ������ ����� ����� (-1, 2���) ���������� � ������� � �������� ��������� ��������
     //DBGridEh1.OptimizeAllColsWidth(-1, 2);
   end
   else DBGridEh1.AutoFitColWidths := False;
//      DBGridEh1.STFilter.InstantApply := False;
   //������-��, ���� ������ ������ ������� ��� ������� �� ������ = 0 �� ���� ���������.
   //PStatus.Visible:= False;//myogHasStatusBar in FOptions;
  PStatus.Height := S.IIf(myogHasStatusBar in FOptions, MY_FORMPRM_LABEL_H + 4, 1);
  LbStatusBarLeft.Top := 2;
end;



{
������� ��� �������� ������, ������������� �����������
}

procedure TFrDBGridEh.ButtonOrPopupMenuClick(Sender: TObject);
//���� �� ������ ��� (c����) ������ ��� �� ������ ����������� ���� �� ������ �����
//�������� ������ ���������� ������, ���� ���������� �� �������� ���, � ������ �� ����� ������
//������� ��� � ������� ������� ��������, ���� ���������.
//���� �� ���������, ��� ������� �� ���������� ���� ���, �� ���������� ��������� �� �������
var
  Tag: Integer;
  St: string;
  Handled: Boolean;
  i, j: Integer;
  fMode: TDialogType;
begin
  //����� �� ��������� � ��� ����� ����������� �������� � ����������� �� ������� ������
  Tag:= -1;
  ChangeSelectedData;
  //� ���� ������ �� ���������������, ������� ��������
  if Sender is TSpeedButton then
    if TSpeedButton(Sender).Enabled then
      Tag:=Integer(TSpeedButton(Sender).Tag);
  if Sender is TMenuItem then
    if TMenuItem(Sender).Enabled then
      Tag:=Integer(TSpeedButton(Sender).Tag);
  //���� ������ ���������������, �� �������
  if Tag = -1 then Exit;
  //������� ����� (�����������, ��������, ��������, �������, �����������)
  fMode:=Cth.BtnModeToFMode(Tag);
  //���� ���� fMode � ����� FDialogFormDoc, ������� ������, ������� �������� �� ��������
  if (FOpt.FDialogFormDoc <> '') and (fMode <> fNone) then begin
    Wh.ExecDialog(FOpt.FDialogFormDoc, TForm(Owner), [], fMode, ID, null);
    Exit;
  end;
  //������� ������� ��������
  Handled:= False;
  if Assigned(FOnButtonClick)
    then FOnButtonClick(Self, FNo, Tag, fMode, Handled);
  //���� ������ ���������� - ������
  if Handled then Exit;
  //���� �� ����������
  //���������� ��������� �������
  if Tag = btnRefresh then begin
    //���� �� ����� ����, �� �����-�� �������� � ��� ������� ������ �������� � �������� ��������� �����, � ������� ���� ���������,
    //�� � ��������� ���������� ��������� ����� �� memtableeh1.refresh ������
    //!!! ���������, ��� ���������� ��� ������� ������ ������ ��� ���� �����
//-    InRowPanelDataChanged := False;
    RefreshGrid;
//-    ChangeSelectedData;
  end
  else if Tag = btnExcel then begin
    Gh.ExportGridToXlsxNew(DBGridEh1, Module.RunSaveDialog(StringReplace(Caption + ' ' + DateTimeToStr(Now), ':', '-', [rfReplaceAll]), 'xlsx'), true, Caption + ' ' + DateTimeToStr(Now), '');
  end
  else if (Tag = btnPrint) or (Tag = btnPrintGrid) then begin
    PrintDBGridEh1.SetSubstitutes(['%[Today]', DateTimeToStr(Now), '%[UserName]', User.GetName, '%[Document]', Caption]);
    PrintDBGridEh1.Preview;
  end
  else if Tag = btnAddRow then begin
    AddRow;
  end
  else if Tag = btnInsertRow then begin
    InsertRow;
  end
  else if Tag = btnDeleteRow then begin
    DeleteRow;
  end
  else if Tag = btnSetGridLabel then begin
    //��������� ����� �� ������� ������ � �����
    SetGridLabel(-1);
  end
  else if Tag = btnClearGridLabels then begin
    //������� ��� ����� �� �������
    SetGridLabel(-2);
  end
  else if Tag = btnToGridLabelDown then begin
    //��������� ����� �� ������� ������ � �����
    GoToGridLabel(+1);
  end
  else if Tag = btnClearOrRestoreGridFilter then begin
    //�������/����������� ������
    ClearOrRestoreFilter;
  end
  else if Tag = btnSelectAll then begin
    //������� ��� ��������������� ������, ������� �� �������
    FDisableChangeSelectedData := True;
    Gh.SetGridIndicatorSelection(DbGridEh1, 1);
    FDisableChangeSelectedData := False;
    ChangeSelectedData;
  end
  else if Tag = btnDeSelectAll then begin
    FDisableChangeSelectedData := True;
    Gh.SetGridIndicatorSelection(DbGridEh1, -1);
    FDisableChangeSelectedData := False;
    ChangeSelectedData;
  end
  else if Tag = btnInvertSelection then begin
    FDisableChangeSelectedData := True;
    Gh.SetGridIndicatorSelection(DbGridEh1, 0);
    FDisableChangeSelectedData := False;
    ChangeSelectedData;
  end
  else if Tag = btnGridSettings then begin
//    Dlg_GridOptions.DlgShow(Self, DBGridEh1);
    TFrmXWGridOptions.Show(Self, '', [myfoModal, myfoDialog, myfoSizeable], fNone, 1, null);
  end
  else if Tag = btnGridFilter then begin
    if TFrmXDedtGridFilter.ShowModal2(Self, '', [myfoDialog], fEdit, 1, null).ModalResult = mrOk then
      RefreshGrid;
  end
  else if Tag = btnSelectFromList then begin
    if MemTableEh1.RecordCount > 0 then begin
      //������ ������/�������� ����, ������������ � �������� � ������� ���� �������� ������/������, ��� ������� � ��������� ������
      DbGridEh1.Datasource.DataSet.DisableControls;
      //�������� ���������� ������ ������� ������� ������
      SetLength(Wh.SelectDialogResult, MemTableEh1.Fields.Count);
      for i := 0 to MemTableEh1.Fields.Count - 1 do
        Wh.SelectDialogResult[i] := MemTableEh1.fields[i].AsVariant;
      //�������� ���������� ������ ������� ���� ���������� �����
      SetLength(Wh.SelectDialogResult2, 0);
      if (myogIndicatorCheckBoxes in Options) and (myogMultiSelect in Options) then begin
        //������ � ������� �� ������, � ���������� � �� ������ ������� �� �����, ��!!! ��� ���������� ������� ������ ���������� �����
        //MemTableEh1.RecordsView.MemTableData.RecordsList
        //DBGridEh1.STFilter.IsEmpty
        //DBGridEh1.ClearFilter;
        //DBGridEh1.DefaultApplyFilter;
        //������� ������ � ������ ���� ����
        if DBGridEh1.SearchPanel.SearchingText <> '' then begin
          DBGridEh1.SearchPanel.SearchingText := '';
          DBGridEh1.SearchPanel.ApplySearchFilter;
        end;
        //������� ��� ���������� ������, ���������� �� ����������
        for i := 0 to DBGridEh1.SelectedRows.Count - 1 do begin
          if not DBGridEh1.DataSource.DataSet.BookmarkValid(DBGridEh1.SelectedRows[i]) then
            Continue;
          try
            DBGridEh1.DataSource.DataSet.Bookmark := DBGridEh1.SelectedRows[i];          //������ ��� ������� �����, BookmarkValid �� ��������
            SetLength(Wh.SelectDialogResult2, Length(Wh.SelectDialogResult2) + 1);
            SetLength(Wh.SelectDialogResult2[i], DBGridEh1.DataSource.DataSet.Fields.Count);
            for j := 0 to DBGridEh1.DataSource.DataSet.Fields.Count - 1 do
              Wh.SelectDialogResult2[i][j] := DBGridEh1.DataSource.DataSet.Fields[j].AsVariant;
          finally
          end;
        end;
      end;
      DbGridEh1.Datasource.DataSet.EnableControls;
    end;
    TForm(Owner).Close;
  end;
end;

procedure TFrDBGridEh.AddControlChange(Sender: TObject);
//������� onChange ����������� ����������� �������������� ���������
//��� ���������� ��������� � �������, ������� OnAddControlChange �� ����������!
var i: Integer;
begin
  if FInAddControlChange then
    Exit;
  FInAddControlChange := True;
  //�������� � ����� -2..-10 ���������� ��� ������������, � -11..-20 ��� ��, �� � ������������ ������
  if (Sender is TDBCheckBoxEh) and (TControl(Sender).Tag >= -20) and (TControl(Sender).Tag <= -1) and IsPrepared then begin
    for i := 0 to ComponentCount - 1 do
      if (Components[i] is TDBCheckBoxEh) and (Sender <> Components[i]) and (TControl(Components[i]).Tag >= -20) and (TControl(Components[i]).Tag <= -1) then
        TDBCheckBoxEh(Components[i]).Checked := False;
    if (TControl(Sender).Tag >= -10) and (TControl(Sender).Tag <= -1) and (not TDBCheckBoxEh(Sender).Checked) then begin
      TDBCheckBoxEh(Sender).Checked := True;
      FInAddControlChange := False;
      Exit;
    end;
  end;
  if Assigned(FOnAddControlChange)
    then FOnAddControlChange(Self, FNo, Sender);
  FInAddControlChange := False;
end;

procedure TFrDBGridEh.CellButtonClick(Sender: TObject; var Handled: Boolean);
//������� ����� ������ � ������
begin
  if Assigned(FOnCellButtonClick) and (IsNotEmpty) then
    FOnCellButtonClick(Self, No, Sender, Handled);
end;

procedure TFrDBGridEh.CellButtonDraw(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; Canvas: TCanvas; Cell, AreaCell: TGridCoord; const ARect: TRect; ButtonDrawParams: TCellButtonDrawParamsEh; var Handled: Boolean);
//��������� ������ � �����
//���� ��� �������, �� �������� ����� ������� ��� ����� �������� � ���� ����, � ����� ���� ��� �� �����
//��� �������� ��������� ���������
var
  fr: TFrDBGridRecFieldsList;
begin
  fr := Opt.GetFieldRec(Column.FieldName);
  if fr.FChbt then begin
    if MemTableEh1.FieldByName(Column.FieldName).Value = null
      then ButtonDrawParams.ImageIndex := 0
      else ButtonDrawParams.ImageIndex := 1;
  end
  else
    inherited;
end;

procedure TFrDBGridEh.ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//������� ��� ��������� ������ ������� (����� ������ � ������)
var
  ReadOnly: Boolean;
  CorrectValue: Variant;
  FRec: TFrDBGridRecFieldsList;
  IsValueCorrect: Boolean;
  Msg: string;
  st: string;
  OldId: Variant;
  EvSaveHandled: Boolean;
begin
  if Assigned(FOnColumnsUpdateData)
    then FOnColumnsUpdateData(Self, No, Sender, Text, Value, UseText, Handled);
  if Handled then Exit;
  FRec := Opt.GetFieldRec(TColumnEh(Sender).FieldName);
  ReadOnly := False;
  Msg := '';
  if (FOpt.FDataMode = myogdmWithAdoDriver) and FOpt.Sql.RefreshBeforeSave then begin
    OldId := GetValue(FOpt.Sql.IdField);
    //������, ���� ������ ������� ����� ���������� (���� ����� ������ ��� ���������� ������� ������)
    if not RefreshRecord then
      Exit;
    //������, ���� ����� ���������� ���������� ���� ������� ������ � ����� (��������, ����������� ������ ������� ��-�� ����������� ������� � �����)
    if OldId <> GetValue(FOpt.Sql.IdField) then
      Exit;
  end;
  //��������, �� ����� �� ������� ������ ���������������, ���������� ���������� ������ ������� ������ �� ��
  if Assigned(FOnGetCellReadOnly) then
    FOnGetCellReadOnly(Self, No, Sender, ReadOnly);
  if ReadOnly then begin
    //���� ������������� ������, ������� (Cancel ������ �� ����������� ���� ������ Handled)
    Handled := True;
    Exit;
  end;
//st:=q.QGetDataTypeAsChar(MemTableEh1.fieldbyname(TColumnEh(Sender).FieldName).DataType);
  IsValueCorrect := (FRec.FVerify = '') or S.VeryfyValue(q.QGetDataTypeAsChar(TColumnEh(Sender).Field.DataType), FRec.FVerify, VarToStr(Value), CorrectValue);
  if IsValueCorrect and Assigned(FOnVeryfyAndCorrectValues) then
    FOnVeryfyAndCorrectValues(Self, No, dbgvBefore, RecNo, S.ToLower(TColumnEh(Sender).FieldName), Value, Msg);
  if not IsValueCorrect or (Msg <> '') then begin
    if Msg <> '-' then
      MyWarningMessage(S.IIf((Msg = '') or (Msg = '*'), '������������ ��������!', Msg));
    MemTableEh1.Cancel;
    Handled := True;
    Exit;
  end;
  //��������� � ������� ������, �� ��������� ������ Post (������ � ������� ���������)
  if (FOpt.FDataMode <> myogdmWithAdoDriver) or not FOpt.Sql.RefreshAfterSave then
    SetValue(TColumnEh(Sender).FieldName, S.IIf(Text = '', null, Value));
  //�������� ������ ��� ��� �������
  if EditOptions.AlwaysVerifyAllTable then
    IsTableCorrect
  else
    IsRowCorrect;
  if Assigned(FOnCellValueSave) then
    FOnCellValueSave(Self, No, S.ToLower(TColumnEh(Sender).FieldName), S.IIf(Text = '', null, Value), EvSaveHandled);
  //���� �� ���������, �� ��������� ��������� ����
  if (FOpt.FDataMode = myogdmWithAdoDriver) then
    if FOpt.Sql.RefreshAfterSave
      then RefreshRecord;
  if Assigned(FOnVeryfyAndCorrectValues) then
    FOnVeryfyAndCorrectValues(Self, No, dbgvCell, RecNo, S.ToLower(TColumnEh(Sender).FieldName), Value, Msg);
  //�����������
  Handled := True;
end;

procedure TFrDBGridEh.ColumnsGetCellParams(Sender: TObject; EditMode: Boolean; Params: TColCellParamsEh);
//������� ��������� �������������� ���������� ������
var
  ReadOnly: Boolean;
  fr: TFrDBGridRecFieldsList;
begin
  //��������� ����������� �������������� �������� � ������.
  //������� ���� ���������, ���� �� ������� � ������ ������������, � ��� �� ������� ��� ������� �������������� ���������� ������ � ����������� �� ������
  //� ���������� ������ ���������� ������� OnColumnsGetCellParams ������ ������� Params.ReadOnly = true
  fr := Opt.GetFieldRec(TColumnEh(Sender).FieldName);
  if Assigned(FOnColumnsGetCellParams) then
    FOnColumnsGetCellParams(Self, No, Sender, LowerCase(TColumnEh(Sender).FieldName), EditMode, Params);
  ReadOnly := Params.ReadOnly;
  if Assigned(FOnGetCellReadOnly) then
    FOnGetCellReadOnly(Self, No, Sender, ReadOnly);
  Params.ReadOnly := ReadOnly;
  Params.ReadOnly := not IsColumnEditable  or DbGridEh1.ReadOnly or Params.ReadOnly;
  //�� �������� ������������� ������ ���� � ��� �������� �������� � ������ (�� �����������, ����� ��� ����� �� ������)
  if fr.FChbt and (TColumnEh(Sender).PickList.Count = 0) then
    Params.ReadOnly := True;
end;


procedure TFrDBGridEh.CreateInfoIcon;
//������� �������������� ������ � ������� ������ ������, ���� ������� ����
var
  c: TControl;
begin
  if (PTop.Height < 10) or (Length(FInfoArray) = 0) then
    Exit;
  c := TImage.Create(Self);
  c.Name := 'ImgInfo';
  c.Parent := PTop;
  c.Left := PGrid.width;
  c.Top := 2;
  Cth.SetInfoIcon(TImage(c), Cth.SetInfoIconText(TForm(Self), InfoArray), S.IIf(PTop.Height > 10, 32, 24));
end;

procedure TFrDBGridEh.GetColumnEvents;
//�������� ������� ������� �����, ������� ���� � ������ ������, ����������� � �����������
var
  i: Integer;
begin
  ColumnTemp := TColumnEh.Create(nil);
  ColumnTemp.OnCellDataLinkClick := DbGridEh1.Columns[0].OnCellDataLinkClick;
  ColumnTemp.OnDropDownBoxTitleBtnClick := DbGridEh1.Columns[0].OnDropDownBoxTitleBtnClick;
  ColumnTemp.OnAdvDrawDataCell := DbGridEh1.Columns[0].OnAdvDrawDataCell;
end;

procedure TFrDBGridEh.SetColumnsAndEvents;
//��������� ������� � ���� ��� ������ � ������������� � ����������� �� ����
//��������� ������� ��������, ������������ � ������, �
//�������� �������, ������������ ��� �������, ���������� � �����, � �����������
var
  i, j: Integer;
begin
  //��������� ������� � ����.
  //��� ���������� ������ ��-�� ����, ��� � ����������� ������ ������� (����� �� ����������� ������� �������,\
  //����������� � �����������, �� ������ �������).
  //� ������ ���� ����� �� ���� ������� ���� �� ������ ��������� �������� � ������������, ������� ���������� �������� � ���� �� �����������!
  j:= DbGridEh1.Columns.Count;
  for i:= 0 to MemTableEh1.Fields.Count - 1 do begin
    if i >= j then begin
      DbGridEh1.Columns.Add;
    end;
{    if Assigned(DbGridEh1.Columns[0].onGetCellParams)
      then DbGridEh1.Columns[DbGridEh1.Columns.Count - 1].onGetCellParams := DbGridEh1.Columns[0].onGetCellParams;
      DbGridEh1.Columns[DbGridEh1.Columns.Count - 1].onUpdateData := DbGridEh1.Columns[0].onUpdateData;
      if Assigned(DbGridEh1.Columns[0].onEditButtonClick)
        then DbGridEh1.Columns[DbGridEh1.Columns.Count - 1].onEditButtonClick := DbGridEh1.Columns[0].onEditButtonClick;
    end;
    DbGridEh1.Columns[i].onGetCellParams:= ColumnsGetCellParams;
    DbGridEh1.Columns[i].OnUpdateData:= ColumnsUpdateData;}
    DbGridEh1.Columns[i].Field :=MemTableEh1.Fields[i];
  end;

  //!!! ���� �������� ������ �������
  for i := 0 to DbGridEh1.Columns.Count - 1 do begin
    //��������� ������� ��������, ������������ � ������
    DbGridEh1.Columns[i].onGetCellParams := ColumnsGetCellParams;
    DbGridEh1.Columns[i].OnUpdateData := ColumnsUpdateData;
    //�������� �������, ������������ ��� �������, ���������� � �����, � �����������
    DbGridEh1.Columns[i].OnCellDataLinkClick := ColumnTemp.OnCellDataLinkClick;
    DbGridEh1.Columns[i].OnDropDownBoxTitleBtnClick := ColumnTemp.OnDropDownBoxTitleBtnClick;
    DbGridEh1.Columns[i].OnAdvDrawDataCell := ColumnTemp.OnAdvDrawDataCell;
  end;
//  ColumnTemp.Destroy;
end;

procedure TFrDBGridEh.PrintStatusBar;
//���� �� ������� � ����������
var
  st, st1: string;
begin
  try
  //������, ���� ��� ���������� (��� ����������� ������ = 1)
  if PStatus.Height < 10 then Exit;
  //�������� � ������, ���� ����� ����� ����� ��, ��� ��������� �����������
  st1 := Opt.FCaption;
  if FStatusBarText = '' then begin
    if Pos('~', st1) = 1 then
      Delete(st1, 1, 1);
    st := S.IIfStr(st1 <> '', '$FF0000' + st1 + '$000000' + ':  ') + Gh.GetGridInfoStr(DbGridEh1);
  end
  else st := FStatusBarText;
  if st = FLastStatusBarText then begin
    st := '';
    Exit;
  end;
  FLastStatusBarText := st;
  //��������� ������� ����� � ������
  LbStatusBarLeft.SetCaption2(st);
  //������� ��������� ��������� ����� (����� ����� ���� ������������ �������� �� ��������� ��������� ������� � ��������� � ����������)
  ChangeSelectedData;
  except
  end;
end;



{
��������� ������� ��������/��������� ������� � ��������
}

procedure TFrDBGridEh.SetInitData(Sql: string; Params: TVarDynArray);
//������������� ��������� ������ ��� ��������, ���� ���� �� ������
begin
  FInitData.IsDefined := True;
  Opt.SetDataMode(myogdmFromArray);
  FInitData.Sql := Sql;
  FInitData.Params := Params;
end;

procedure TFrDBGridEh.SetInitData(Arr: TVarDynArray2; ArrFields: string);
begin
  FInitData.IsDefined := True;
  Opt.SetDataMode(myogdmFromArray);
  FInitData.Arr := Arr;
  FInitData.ArrFields := ArrFields;
end;

procedure TFrDBGridEh.SetInitData(ArrN: TNamedArr);
begin
  FInitData.IsDefined := True;
  Opt.SetDataMode(myogdmFromArray);
  FInitData.ArrN := ArrN;
end;

function TFrDBGridEh.IsEmpty: Boolean;
//������ True, ���� ������� �����
begin
  Result:= (not MemTableEh1.Active) or (MemTableEh1.RecordCount = 0);
end;

function TFrDBGridEh.IsNotEmpty: Boolean;
//������ True, ���� ������� �� �����
begin
  Result:= not IsEmpty;
end;

function TFrDBGridEh.GetCount(Filtered: Boolean = True): Integer;
//�������� ���������� ����� ������� (�������������� ��� ���)
begin
  if Filtered
    then Result:= MemTableEh1.RecordsView.Count
    else Result:= MemTableEh1.RecordsView.MemTableData.RecordsList.Count;
end;

function TFrDBGridEh.GetValue(FieldName: string = ''): Variant;
//�������� �������� ���� � ������� ������ �����
begin
  Result := null;
  if (not MemTableEh1.Active) or (MemTableEh1.RecordCount = 0) then Exit;
  if FieldName = '' then FieldName:= GetCurrField;
  Result:= MemTableEh1.FieldByName(FieldName).Value;
end;

function TFrDBGridEh.GetValueI(FieldName: string = ''): Integer;
begin
  Result := S.NInt(GetValue(FieldName));
end;

function  TFrDBGridEh.GetValueF(FieldName: string = ''): Extended;
begin
  Result := S.NNum(GetValue(FieldName));
end;

function  TFrDBGridEh.GetValueS(FieldName: string = ''): string;
begin
  Result := S.Nst(GetValue(FieldName));
end;

function  TFrDBGridEh.GetValueD(FieldName: string = ''): TDateTime;
begin
  Result := VarToDateTime(GetValue(FieldName));
end;

function TFrDBGridEh.GetValue(FieldName: string; Pos: Integer; Filtered: Boolean = true): Variant;
//�������� �������� ���� �� ����������� ������� (��������������� ��� ���� ��������)
begin
  if Filtered
    then Result:= MemTableEh1.RecordsView[Pos].DataValues[FieldName, dvvValueEh]
    else Result:= MemTableEh1.RecordsView.MemTableData.RecordsList[Pos].DataValues[FieldName, dvvValueEh];
end;

function TFrDBGridEh.GetValueI(FieldName: string; Pos: Integer; Filtered: Boolean = true): Integer;
begin
  Result := S.NInt(GetValue(FieldName, Pos, Filtered));
end;

function TFrDBGridEh.GetValueF(FieldName: string; Pos: Integer; Filtered: Boolean = true): Extended;
begin
  Result := S.NNum(GetValue(FieldName, Pos, Filtered));
end;

function TFrDBGridEh.GetValueS(FieldName: string; Pos: Integer; Filtered: Boolean = true): string;
begin
  Result := S.NSt(GetValue(FieldName, Pos, Filtered));
end;

function TFrDBGridEh.GetValueD(FieldName: string; Pos: Integer; Filtered: Boolean = true): TDateTime;
begin
  Result := VarToDateTime(GetValue(FieldName, Pos, Filtered));
end;

procedure TFrDBGridEh.SetValue(FieldName: string; NewValue: Variant; Post: Boolean = true);
//���������� �������� ���� � ������� ������
begin
  if FieldName = '' then
    FieldName := GetCurrField;
  MemTableEh1.Edit; //!!!
  MemTableEh1.FieldByName(FieldName).Value := NewValue;
  if Post then
    Mth.PostAndEdit(MemTableEh1); //!!!07-06-25
end;

procedure TFrDBGridEh.SetValue(FieldName: string; Pos: Integer; Filtered: Boolean; NewValue: Variant);
//���������� �������� ���� �� ���������� ������� (��������������� ��� ���� ��������)
begin
  if Filtered
    then MemTableEh1.RecordsView[Pos].DataValues[FieldName, dvvValueEh] := NewValue
    else MemTableEh1.RecordsView.MemTableData.RecordsList[Pos].DataValues[FieldName, dvvValueEh] := NewValue;
end;

function TFrDBGridEh.GetColumnFieldName(Column: TObject = nil): string;
//�������� ��� ���� ����������� ������� � ������ ��������; ���� ������� �� �������, �� ������������ ������� ����
begin
  if Column = nil
    then Result := GetCurrField
    else Result := LowerCase(TColumnEh(Column).FieldName);
end;

function TFrDBGridEh.GetCol(Col: Integer = -1): Integer;
//�������� ������� � ������� �������� Columns �� �������� DBGridEh1.Col ��� Cell.X
begin
  Result := S.IIf(Col = -1, DBGridEh1.Col, Col) - S.IIf(myogIndicatorColumn in FOptions, 1, 0);
end;

function TFrDBGridEh.IsColumnEditable(FieldName: string = ''): Boolean;
//�������, �������� �� ������ ������� ��������������
var
  i: Integer;
begin
  Result := False;
  if FieldName = '' then
    FieldName := CurrField;
  for i := 0 to High(FOpt.Sql.Fields) do
    if S.CompareStI(FOpt.Sql.Fields[i].Name, FieldName) then begin
      Result := FOpt.Sql.Fields[i].Editable;
      Exit;
    end;
end;

procedure TFrDBGridEh.SetIndicatorCheckBoxesByField(FieldName: string; Values: TVarDynArray);
//���������� ������� � ������������ ������� ��� ���������� �������� ���������� ����
var
  rn: Integer;
  va2: TVarDynArray2;
  KeyString: string;
begin
  if Length(Values) = 0 then
    Exit;
  InLoadData := True;
  va2 := Gh.GridFilterSave(DbGridEh1);
  //KeyString := Gh.GetGridServiceFields(DBGridEh1);
  //DBGridEh1.SaveVertPos(KeyString);
  Gh.GridFilterClear(DbGridEh1);
  MemTableEh1.DisableControls;
  rn := MemTableEh1.RecNo;
  MemTableEh1.First;
  while not MemTableEh1.Eof do begin
//    DbGridEh1.SelectedRows.CurrentRowSelected := A.InArray(MemTableEh1.FieldByName(FieldName).Value, Values);
    if A.InArray(MemTableEh1.FieldByName(FieldName).Value, Values) then
      DbGridEh1.SelectedRows.CurrentRowSelected := True;
    MemTableEh1.Next;
  end;
  MemTableEh1.RecNo := rn;
  Gh.GridFilterRestore(DbGridEh1, va2);
  InLoadData := False;
  MemTableEh1.EnableControls;
  try
    DBGridEh1.RestoreVertPos(KeyString);  //����� ����� ��������� ������, ������� ���� �� ��������.
  except
  end;
end;


{
������� ��������� ������, ���������� ��� ���������� �� ����� ����������
}


function TFrDBGridEh.Prepare: Boolean;
//��������� ���������� �������
//���������� ������� ���� ��� ����� ������� ��������� �������� ������
var
  i: Integer;
begin
  //�������� ������ ������� ������, ������������ � �����������, ���������� �������
  GetColumnEvents;
  //������� �������
  MemTableEh1.Fields.Clear;
  //������� ����� ������
  FNo := StrToIntDef(S.Right(Self.Name, 1), -1);
  //��������� ������, ���� �� �� �����, ������������ � ��������� ����� (�����, �� ��� �������� ������ ����� �� ���� ��������� �����)
  if Opt.Caption = '' then
    Opt.Caption := TForm(Owner).Caption;
  //��������� ��������� ����� � ��������, ����������� � �� ��� ������������
  //��� ��� ������� ���������, ����������� ������ ��������� �������
  if (TFrmBasicMdi(Owner).FormDoc <> '') and (myogSaveOptions in Options) then
    Settings.RestoreFrDBGridEhSettings(TFrmBasicMdi(Owner).FormDoc, Self);
  //�������� ������� ��� ������� ��� �����������
  if FOpt.DataMode <> myogdmWithAdoDriver then
    CreateDataSet;
  //�������� ������ ������ � ���������� ����
  SetButtonsAndMenu;
  //�������� �������������� ������ ������
  SetPanels;
  //�������� �������������� ������
  for i := 0 to High(FLabelsColored) do
    TLabelClr(FindComponent(FLabelsColored[i][0])).SetCaption2(FLabelsColored[i][1]);
  //��������� ������ ����������
  CreateInfoIcon;
  //�������� ���������������� ����� ��� �������
  ReadGridLabels;
  //���� ����� ���� ��� ��������� ������, ���������� ������, �������� �������� ����� �� ���, ������� ���� �������
  if (FGrid2 <> nil) and (Length(FGrid2.Opt.Sql.FieldsDef) > 0) then begin
    FOptions := FOptions + [myogRowDetailPanel];
    FGrid2.Parent := PRowDetailPanel;
    FGrid2.Visible := True;
  end;
  //������� RowDetailPanel
  DbGridEh1.RowDetailPanel.Active := myogRowDetailPanel in FOptions;
  //������� ��������� ���� � ����� �� �������� � ����������
  ImGState.OnMouseEnter := Module.InfoOnMouseEnter;
  ImGState.OnMouseLeave := Module.InfoOnMouseLeave;
  ImGState.OnClick := Module.InfoOnClick;
  Result := True;
end;

procedure TFrDBGridEh.CreateDataSet;
//������� ������� �� ������ ������� �����; ������������ � ������ �������� �� ������� ��� �������� ���, �� �� � DataDriver
var
  i: Integer;
begin
  MemTableEh1.Active := False;
  MemTableEh1.DataDriver := nil;
  MemTableEh1.FieldDefs.Clear;
  for i := 0 to High(Opt.Sql.Fields) do
    MemTableEh1.FieldDefs.Add(Opt.Sql.Fields[i].Name, Opt.Sql.Fields[i].DataType, Opt.Sql.Fields[i].FieldSize, False);
  MemTableEh1.CreateDataset;
  MemTableEh1.Active := True;
end;

procedure TFrDBGridEh.LoadSourceDataFromSql(ASqlParams: TVarDynArray; AEmptyBefore: Boolean = true);
//��������� � ������� ������, ���������� sql-�������� �� ������ ������ ����� ������,
begin
  InLoadData := true;
  MemTableEh1.ReadOnly := False;
  Q.QLoadToMemTableEh(Q.QSIUDSql('s', Opt.Sql.View, Opt.Sql.FieldNames), ASqlParams, MemTableEh1, '', 0);
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadSourceDataFromArray(AValues: TVarDynArray2; AArrayColumns: string = ''; AEmptyBefore: Boolean = true);
//��������� � ������� ������ �� ������� (�������������� ������� �������)
var
  i, j:Integer;
begin
  InLoadData := true;
  MemTableEh1.ReadOnly := False;
  Mth.LoadGridFromVa2(DBGridEh1, AValues, Opt.Sql.FieldNames, AArrayColumns, AEmptyBefore);
  MemTableEh1.First;
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadData(AParams: TVarDynArray);
begin
  InLoadData := True;
  SetDataDriverCommandSelect;
  Q.QLoadFromQuery(ADODataDriverEh1.SelectSQL.Text, AParams, DBGridEh1, True);
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadData(ASql: string; AParams: TVarDynArray; AEmptyTable: Boolean = true);
begin
  InLoadData := True;
  if ASql = '*' then
    LoadData(AParams)
  else
    Q.QLoadFromQuery(ASql, AParams, DBGridEh1, True);
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadData(AValues: TVarDynArray2; AArrayColumns: string; AEmptyTable: Boolean = true);
begin
  InLoadData := True;
  MemTableEh1.ReadOnly := False;
  Mth.LoadGridFromVa2(DBGridEh1, AValues, Opt.Sql.FieldNames, AArrayColumns, AEmptyTable);
  MemTableEh1.First;
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.LoadData(AValues: TNamedArr; AEmptyTable: Boolean = true);
begin
  InLoadData := True;
  Mth.LoadGridFromNamedArray(DBGridEh1, AValues, True, AEmptyTable);
  MemTableEh1.First;
  InLoadData := False;
  ChangeSelectedData;
end;

procedure TFrDBGridEh.ReadControlValues(Force: Boolean = False);
//������ ������ ������������� ��������� ��������� �� ����� �������� ������������, ���� �� ���� ��� ��������, ��� Force
begin
  if FIsAddControlsLoaded and not Force then
    Exit;
  if Length(Opt.FPanelsSaved) > 0 then
    Cth.SetControlValuesArr2(TForm(Self), Cth.DeSerializeControlValuesArr2(Settings.ReadProperty(TFrmBasicMdi(Owner).FormDoc, Name + '.Controls')));
  FIsAddControlsLoaded := True;
end;

procedure TFrDBGridEh.WriteControlValues;
//������ �������� � ���� �������� ������������; ���������� ������������� ��� �������� �������� ��� ���������� ������
var
  st : string;
  i: Integer;
  va: TVarDynArray;
  va2: TVarDynArray2;
begin
  if Length(Opt.FPanelsSaved) = 0 then
    Exit;
  va2 := [];
  va := [];
  for i := 0 to High(Opt.FPanelsSaved) do begin
    if FindComponent(Opt.FPanelsSaved[i]) <> nil then
      if not A.InArray(Opt.FPanelsSaved[i], va) then begin
        va2 := va2 + Cth.GetControlValuesArr2(TForm(Self), FindComponent(Opt.FPanelsSaved[i]), [], []);
        va := va + [Opt.FPanelsSaved[i]];
      end;
  end;
  if Length(va2) <> 0 then
    Settings.WriteProperty(TFrmBasicMdi(Owner).FormDoc, Name + '.Controls', Cth.SerializeControlValuesArr2(va2));
end;

procedure TFrDBGridEh.CreateAddControls(ParentName: string; CType: TMyControlType; CLabel: string = ''; CName: string= ''; CVerify: string = ''; x: Integer = 1; y: Integer = yrefC; Width: Integer = 0; Tag: Integer = 0);
//������������ �������� ��������� � ���������� ������ (��������, ����������...), � ����������� �������, ���������, ���������� (x, y (yrefT))
//���������� ��� ������, ���� ������� �� �������, �� ��� ��������� � ����������� �� �������,
//������ �� ��������� � �������� ���������, � �� ������ ������ 32.
//����� ������ � ���������� ����������� � ������ ������, ��� ������ ���� ���� 'PTopBtnsCtl2'.
//���� ��� - ������ �����, �� ������������ ��� ��� ������� � ������� ������.
var
  C:TControl;
  P: TPanel;
  r, i: Integer;
begin
{ cntEdit = 1;  cntNEdit = 2;  cntNEditC; cntNEditS; cntDEdit = 3;  cntTEdit = 4;  cntDTEdit = 5;  cntCheck = 6;  cntCheck3 = 7 //checkbox � ������ greed
  cntComboL = 8 //��������� - ������;  cntComboLK = 9 //��������� - ������ � �������;  cntComboE = 10 //��������� - ����;
  cntComboEK = 11 //��������� - ���� � �������;  cntComboL0 = 12 //� ����������� ������ ������� � ����;  cntComboLK0 = 13;}
  if S.IsNumber(ParentName, 1, 100, 0)
    then ParentName := 'PTopBtnsCtl' + ParentName;
  P:=TPanel(FindComponent(ParentName));
  if P = nil then begin
    P:=TPanel.Create(Self);
    P.Name := ParentName;
    P.Height := 32;
    P.Tag := -1;
    P.Width := 0;
    //�������� ������������ ������ � ������, ��� �������� ����������� �������� ��������� � ��
    if A.InArray('*', Opt.FPanelsSaved) then
      Opt.FPanelsSaved := Opt.FPanelsSaved + [ParentName];
  end;
  //���� x ������� -1, �� �������� ��� �� ������ ������� ������������� ��������
  if x = -1 then begin
    x := 4;
    for i := 0 to P.ControlCount - 1 do
      x := Max(x, P.Controls[i].Left + P.Controls[i].Width + 4);
  end;
  if CType = cntLabelClr then begin
    FLabelsColored := FLabelsColored + [[CName, CLabel]];
    CLabel := '';
  end;
  c:=Cth.CreateControls(Self, CType, CLabel, CName, CVerify, Tag);
  c.Parent:=P;
  c.left:=x;
  if y = yrefC then begin
    y:=P.Height div 2 - c.Height div 2;
  end;
  if y = yrefT then begin
    y:=(P.Height - c.Height * 2) div 3;
  end;
  if y = yrefB then begin
    y:=((P.Height - c.Height * 2) div 3) * 2 + c.Height;
  end;
  c.Top:=y;
  if c.Width > 0 then c.Width:= Width;
  if P.Tag = -1 then begin
    P.Width := Max(P.Width, c.Left + c.Width + 4);
  end;
  c.Tag := Tag;
  if not ((CType = cntLabel) or (CType = cntLabelClr)) then begin
    Cth.SetControlValue(c, null);
    if (CType = cntCheck) or (CType = cntCheck3)
      then TDBCheckboxEh(c).OnClick := AddControlChange
      else TDBEditEh(c).OnChange := AddControlChange;
  end;
end;

procedure TFrDBGridEh.SetColumnsPropertyes;
//��������� ������ �������� ����� (�������, ������, �������, ��������...) �� ������ ������� Opt.Fields ������
//���������� ������������� ��� �������� ��������, �� ����� ���� ������ ������� � ������ ���� ����
//��������� ���������� ������ Opt.SetColFeature
//������� ������ � ����������� ��������, ������� ������ �������������
var
  i, j, k, p, w: Integer;
  b, b1, b2: Boolean;
  col: TColumnEh;
  va, va1, va11: TVarDynArray;
  st: string;
  ebt: TEditButtonStyleEh;
  ebtp: TEditButtonHorzPlacementEh;
const
  ebsn: array of string = ['dd', '', 'g', 'ud' ,'+', '-', 'add', 'aud'];
  ebs: array of TEditButtonStyleEh = [ebsDropDownEh, ebsEllipsisEh, ebsGlyphEh, ebsUpDownEh,  ebsPlusEh, ebsMinusEh, ebsAltDropDownEh, ebsAltUpDownEh];
begin
  if not FIsPrepared then
    DBGridEh1.AutoFitColWidths := False;
  DBGridEh1.FooterRowCount := 0;
  DBGridEh1.SumList.Active := False;
  for i:= 0 to DBGridEh1.Columns.Count - 1 do begin
    col := DBGridEh1.Columns[i];
    if not FIsPrepared then begin
      //��������� �� ���������, ����������� � ����. ������ ����� ������� �������� �����
      col.AutoFitColWidth := False;
      col.WordWrap := False;
      va := A.Explode(Opt.Sql.Fields[i].DefOptions, ';');
      for j := 0 to High(va) do begin
        if UpperCase(va[j]) = 'H' then begin
          col.WordWrap := true;
          b1 := true;
        end;
        if UpperCase(va[j]) = 'W' then begin
          col.AutoFitColWidth := true;
          b2 := true;
        end;
        if UpperCase(va[j]) = 'L' then
          col.Alignment:= taLeftJustify;
        if UpperCase(va[j]) = 'R' then
          col.Alignment:= taRightJustify;
        if UpperCase(va[j]) = 'C' then
          col.Alignment:= taCenter;
        w := StrToIntDef(va[j], -1);
        if w > -1 then begin
          col.Width := w;
        end;
      end;
    end;
    if col.Width < 15 then
       col.Width:=Min(col.Width, 40);
    //������� �������� �������, ������� ��� ��������� ����� ���� ���������
    //(���������, ��� �� ���������!!
    //-�������� ��� ��������� SetGridInCellImagesAdd ���� �������
    //������
    col.CellButtons.Clear;
    //��������
    if col.Checkboxes then begin
      col.Checkboxes := true;
      col.KeyList.Add('1');
      col.KeyList.Add('0;');
    end;
    //������� � �����
    Col.DisplayFormat := '';
    col.Footer.ValueType := fvtNon;
    col.Footer.DisplayFormat := '';

    //������� ��������� �������
    col.Title.Caption := Opt.Sql.Fields[i].Caption;
    //������� � �������
    if Opt.Sql.Fields[i].FChb then begin
      st := Opt.Sql.Fields[i].FChbPic;
      if (st <> '')and(not IsColumnEditable(col.FieldName)) then begin
        //������� ����� ��� 1, ��� 0 ����������
        if st = '+' then st := '0;1';
        Gh.SetGridInCellImagesAdd(DbGridEh1, [[col.FieldName, '1;0', st, true, 0]])
      end
      else begin
        Gh.SetGridInCellCheckBoxes(DBGridEh1, col.FieldName, '1;', -1);
      end;
    end;
    if Opt.Sql.Fields[i].FChbt then begin
      st := Opt.Sql.Fields[i].FChbtPic;
      if (st <> '')and(not IsColumnEditable(col.FieldName)) then begin
        //������� ����� ��� ��������, ��� ������ ����������
        if st = '+' then st := '0;1';
        Gh.SetGridInCellImagesAdd(DbGridEh1, [[col.FieldName + '+', '', st, true, 0]])
      end
      else begin
        Gh.SetGridInCellButtonsChb(DBGridEh1, col.FieldName, '' {����� ���� � ��������, �� ������}, CellButtonClick, nil);
      end;
    end;
    if Opt.Sql.Fields[i].FBt <> '' then begin
      //������
      //���� ���������, �� �������� ����������� ������ � �������
      va := A.Explode(Opt.Sql.Fields[i].FBt, ';');
      for j := 0 to High(va) do begin
        //��������� ������ ����� :
        //���������
        //��� ������, ���� ������ �� �������, ���� ����� �� ��������, ����� �� ����������� ['dd', '', 'g', 'ud' ,'+', '-', 'add', 'aud']
        //���� l �� ������������ �� ������ ����
        //���� h, �� ������ ���������� ����� �� ��� �� �������� �����
        //��������� ������ ������, � ������ ������ ��������� ���������
        va1 := A.Explode(va[j], ':') + ['', '', '', '', ''];
//        va11 := TVarDynArray(ebsn);
        k := A.PosInArray(va1[1], ['dd', '', 'g', 'ud' ,'+', '-', 'add', 'aud']);
        ebt := ebsEllipsisEh;
        if (k = -1) and S.IsInt(va1[1]) then begin
          ebt := ebsGlyphEh;
          k := va1[1];
        end
        else if k >= 0 then begin
          ebt := ebs[k];
          k := -1;
        end;
        if va1[2] <> 'l'
          then ebtp := ebhpRightEh
          else ebtp := ebhpLeftEh;
        Gh.SetGridInCellButtons(DBGridEh1, col.FieldName, va1[0], CellButtonClick, ebtp, ebt, k ,'', va1[3] = 'h');
//        Gh.SetGridInCellButtons(DBGridEh1, col.FieldName, va1[0], CellButtonClick, ebhpRightEh, ebsGlyphEh, 21 ,'', False);
      end;
    end;
    if Opt.Sql.Fields[i].FPic <> '' then begin
      //��������, � ������ ����� ":"
      //1 - �������� �����, ����� ����� � �������
      //2 - ��������������� �� ������� ��������
      //3 - ���� +, �� ����������� � �����
      //���� ������ �� ������, �� ����� ����� ��� �������� "1", ���� ����� ������ ���� ��������, �� ����� ����� ��� ����
      va := A.Explode(Opt.Sql.Fields[i].FPic, ':') + ['', '', ''];
      if va[0] = '' then va[0] := '1';
      if va[1] = '' then va[1] := '1';
      Gh.SetGridInCellImagesAdd(DbGridEh1, [[col.FieldName + S.IIfStr(va[2] = '+', '+'), va[0], va[1], true, 0 {��� Il_All16}]])
    end;
    if Opt.Sql.Fields[i].FFormat <> '' then begin
      //������ ������ � ������
      //�� ��������� - �������� ������ ������ ��� ������ (����� ���������)
      //���� ���� ":", �� ��� �������� ������ ������, ���� ��� ��������� � ������, �� ������ ������ ����� �� ��� � ������
      //r - ������ � ������ � ��������
      va := A.Explode(Opt.Sql.Fields[i].FFormat, ':') + ['', '', ''];
      if va[0] = 'r' then
        va[0] := '###,###,##0.00';
      if va[0] = 'f' then
        va[0] := '###,###,###0.###';
      if va[1] = '' then
        va[1] := va[0];
      if va[1] = 'r' then
        va[1] := '###,###,##0.00';
      if va[1] = 'f' then
        va[1] := '###,###,###0.###';
      if va[1] = '' then
        va[1] := va[0];
      Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, col.FieldName, VarToStr(va[0]));
      if Pos(':', Opt.Sql.Fields[i].FFormat) > 0 then
        Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, col.FieldName, VarToStr(va[1]));
    end;
    //���������� ���������� ������ � ��������
    for j := 0 to High(FOpt.PickLists) do
      if UpperCase(FOpt.PickLists[j].FieldName) = UpperCase(col.FieldName) then begin
        col.PickList.Clear;
        col.KeyList.Clear;
        for k := 0 to High(FOpt.PickLists[j].KeyList) do
          col.KeyList.Add(S.NSt(FOpt.PickLists[j].KeyList[k]));
        for k := 0 to High(FOpt.PickLists[j].PickList) do
          col.PickList.Add(S.NSt(FOpt.PickLists[j].PickList[k]));
        col.LimitTextToListValues := FOpt.PickLists[j].LimitTextToListValues;
        col.AlwaysShowEditButton := FOpt.PickLists[j].AlwaysShowEditButton;
      end;
  end;
  //������� ������� �������� ������ � ������ (����� ��� ��������� � �������)
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    for j := 0 to DBGridEh1.Columns[i].CellButtons.Count - 1 do
      DBGridEh1.Columns[i].CellButtons[j].OnDraw := CellButtonDraw;
  if b1 then
    Options := Options + [myogAutoFitRowHeight];
  if b2 then
    Options := Options + [myogAutoFitColWidths];

  //����������� �����������
  DataGrouping;
end;

procedure TFrDBGridEh.RefreshGrid;
//���������� �������� �������, ���������� �� ������, ���� �� �� ������ ��������
var
  charr: TVarDynArray2;
  KeyString: string;
begin
  try
    //��������� �� �� � ��������� �������� �������������� ��������� (���� ����� �� ���� ��� ������ ������ �������)
    ReadControlValues;
    SetDataDriverCommands;
    //���������� ����� � �������-������
    if (Opt.DataMode <> myogdmWithAdoDriver) and InitData.IsDefined then begin
      if myogIndicatorCheckBoxes in Options then begin
        charr := Gh.GetGridArrayOfChecked(DBGridEh1, DBGridEh1.FindFieldColumn(Opt.Sql.IdField).Index);
        DBGridEh1.SelectedRows.Clear;
      end;
      //��������� � ���������� �������� ���� - ���� ������, �� ������������ ������
      //if myogGrayedWhenRefresh in Options then BeginOperation('�������� ������..');
      KeyString := Gh.GetGridServiceFields(DBGridEh1);
      if KeyString <> '' then
        DBGridEh1.SaveVertPos(KeyString);
      if FInitData.Sql <> '' then
        LoadData(InitData.Sql, InitData.Params)
      else if InitData.ArrN.FieldsCount > 0 then
        LoadData(InitData.ArrN)
      else
        LoadData(InitData.Arr, InitData.ArrFields);
      DBGridEh1.DefaultApplySorting;
      DBGridEh1.DefaultApplyFilter;
      if KeyString <> '' then
        DBGridEh1.RestoreVertPos(KeyString);
      //if myogIndicatorCheckBoxes in Options then EndOperation;
      if myogIndicatorCheckBoxes in Options then
        SetIndicatorCheckBoxesByField(Opt.Sql.IdField, A.VarDynArray2ColToVD1(charr, 0));
    end
    //���������� ����� � ������-������
    else begin
      if MemTableEh1.Active then begin
        if myogIndicatorCheckBoxes in Options then begin
          charr := Gh.GetGridArrayOfChecked(DBGridEh1, DBGridEh1.FindFieldColumn(Opt.Sql.IdField).Index);
          DBGridEh1.SelectedRows.Clear;
        end;
        Gh.GridRefresh(DBGridEh1, myogGrayedWhenRefresh in Options);
        if myogIndicatorCheckBoxes in Options then
          SetIndicatorCheckBoxesByField(Opt.Sql.IdField, A.VarDynArray2ColToVD1(charr, 0));
      end
      else begin
        MemTableEh1.Open;
        MemTableEh1.First;
      end;
      ChangeSelectedData;
    end;
  finally
  end;
end;

function TFrDBGridEh.RefreshRecord: Boolean;
//��������� ������� ������ �����, ��� ������ ������ ��������� �� ��������� ������
//������ False � ������ ����������� ������ � ��, ��� ���� ��� ���� �� ���������������� ����� ����� ����������
var
  OldID: Variant;
begin
  Result := False;
  try
    //������� ���� ������� ������. ����� ������ �������� ����� ���������� ������, �� ������� �� �� ����� ��� ��-�� �������� �������
    OldID := GetValue(Opt.Sql.IdField);
    MemTableEh1.RefreshRecord;
    ChangeSelectedData;
    if OldID = GetValue(Opt.Sql.IdField) then
      Result := True;
  except
    MyWarningMessage('��� ������ ���� �������.')
  end;
end;

procedure TFrDBGridEh.SetButtonsState;
//������� Enabled ���� ������ � ������� ���� � ����������� �� ����, ���� �� ������ � �������, � ���� �� ������ � Opt.FButtonsIfEmpty
var
  i: Integer;
begin
  for i := 0 to High(FBtnIds) do
    SetBtnNameEnabled(FBtnIds[i], null, IsNotEmpty or A.InArray(FBtnIds[i], Opt.FButtonsIfEmpty));
end;

procedure TFrDBGridEh.SetBtnNameEnabled(ATag: Integer; AName: Variant; AEnabled: Variant);
//������ ��������� ������ ��� ��� ������ (��� SpeedButton ������ Hint), � �������� Enabled,
//������ ������� � ���������� ����������� �� ����
//����� �� ������ ������ ��� ����� ���������, � ������ ����� ������� null!
begin
  //!!!����� ������������ ������ �������? ���� ���������, ������� � ��������, �� �������������� ������, ���������� � ���������� �������
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FPanelsBtn, ATag, AName, AEnabled, '');
end;

procedure TFrDBGridEh.SetColumnsVisible;
//���������� ������ �����, ������� ������ ���� �����
//����� � ������� ����������� ���� Visible (�� ����������� � ����������), �� ���������� Invisible (��� ��������� ������ ����� ����� �� ������� ��������),
//������� �� ���� ������� �� ����������� (NULL) � ��������� ����� ������ ���� ��������� ���� FDevVisibleHidden
var
  i : Integer;
begin
  for i := 0 to High(Opt.Sql.Fields) do
    if DbGridEh1.FindFieldColumn(Opt.Sql.Fields[i].Name) <> nil then
      DbGridEh1.FindFieldColumn(Opt.Sql.Fields[i].Name).Visible :=
        Opt.Sql.Fields[i].Visible and not Opt.Sql.Fields[i].Invisible and not Opt.Sql.Fields[i].FIsNull and ((Pos('_', Opt.Sql.Fields[i].Caption) <> 1) or FDevVisibleHidden);
  FrozeColumn;
end;

procedure TFrDBGridEh.FrozeColumn;
//���������� ������� �� ������� � ��������� ����� � Opt.FrozenColumn ,������������; ���� ������ - ����� ���������
var
  i, j : Integer;
begin
  //���������� ����������� �������� ����������� ��� ������� ��������!
  DBGridEh1.FrozenCols := 0;
  if Opt.FrozenColumn = '' then
    Exit;
  if DBGridEh1.FindFieldColumn(Opt.FrozenColumn) = nil then
    Exit;
  for i := 0 to DBGridEh1.FindFieldColumn(Opt.FrozenColumn).Index do begin
    if DBGridEh1.Columns[i].Visible then
      DBGridEh1.FrozenCols := DBGridEh1.FrozenCols + 1;
  end;
end;

procedure TFrDBGridEh.BeginOperation(AMessage: string = '');
//��� ������ �������� - �������� ���� � ������� ���������� �����
begin
  //� ���� ��������� �������� ������ � ���� ����������
  if MemTableEh1.ControlsDisabled then Exit;
  if AMessage = '' then
    AMessage := '��������� ������...';
  DBGridEh1.StartLoadingStatus(AMessage, 0);
end;

procedure TFrDBGridEh.EndOperation(AMessage: string = '');
//��� ������ �������� - ����� ���������� �����
begin
  try
  if MemTableEh1.ControlsDisabled then Exit;
  DBGridEh1.FinishLoadingStatus(0);
  DBGridEh1.StartLoadingStatus('���������!', 0);
  DBGridEh1.FinishLoadingStatus(0);
  finally
  end;
end;

procedure TFrDBGridEh.ClearOrRestoreFilter;
begin
    //�� Ctrl-Q - ���������/����� ������� � ��������
    //���� ���� ������ � �������� � ��� ������������ �������, �� �������� ������� � ������ ������ � ��������
    //���� ���� �����������, �� ����������� ���, ���������� �� ���� ���� �� ������ � �������� ������
    //��� ��� ��������/�������������
    if (Length(FLastFilter) = 0) and not Gh.GridFilterInColumnUsed(DbGridEh1) then
      Exit;
    if Length(FLastFilter) = 0 then begin
      FLastFilter := Gh.GridFilterSave(DbGridEh1);
      Gh.GridFilterClear(DbGridEh1, true, False);
    end
    else begin
      if Length(FLastFilter) = 0 then
        Exit;
      Gh.GridFilterRestore(DbGridEh1, FLastFilter, true, False);
      FLastFilter := [];
    end;
end;

procedure TFrDBGridEh.SetGridLabel(Mode: Integer = 0);
//��������� �������� ����� �� ������ �������
//���� Mode = -1, �� ��������� ����� � �����, ���� >=0 �� ��������� ������ ���� ����� �����, ���� -2 �� ������� ��� ����� �� ���� �������
var
  i, labelnum: Integer;
  b: Boolean;
  updsql: string;
begin
  if IsEmpty or not (myogGridLabels in Options) then
    Exit;
  if Mode >= -1 then begin
    for i := 0 to High(FGridLabelsIds) do
      if FGridLabelsIds[i][0] = id
        then Break;
    if i > High(FGridLabelsIds) then begin
      labelnum := 0;
      FGridLabelsIds := FGridLabelsIds + [[id, labelnum]];
    end;
    if Mode = -1
      then Inc(FGridLabelsIds[i][1])
      else FGridLabelsIds[i][1] := Mode;
    labelnum := FGridLabelsIds[i][1];
    if not(Integer(FGridLabelsIds[i][1]) in [1..3]) then begin
      Delete(FGridLabelsIds, i, 1);
      labelnum := 0;
    end;
  end
  else begin
    if MyQuestionMessage('�������� ��� ����� � �������?') <> mrYes then
      Exit;
    FGridLabelsIds := [];
  end;
  Q.QCallStoredProc('P_SetGridLabel', 'pdoc$s;piduser$i;ptablerow$i;ptablenum$i;plabelnum$i',
    [TFrmBasicMdi(Owner).FormDoc, User.GetId, S.IIf(Mode < -1, -1, ID), 1, labelnum
  ]);
{    if pos('0 as collabel', Pr[1].Fields) > 0 then begin
      b := MemTableEh1.ReadOnly;
      MemTableEh1.ReadOnly := False;
      MemTableEh1.Edit;
      MemTableEh1.FieldByName('collabel').Value := labelnum;
      ADODataDriverEh1.UpdateSQL.Text := 'select 1 from dual';
      MemTableEh1.Post;
      ADODataDriverEh1.UpdateSQL.Text := updsql;
      MemTableEh1.ReadOnly := b;
    end;}
  DbGridEh1.Repaint;
end;

procedure TFrDBGridEh.GoToGridLabel(Mode: Integer = +1);
//������� � ���������� ������ (+1 - ����, -1 = �����)
var
  i, j, k, RecNo: Integer;
begin
  if IsEmpty or not (myogGridLabels in Options) then
    Exit;
  RecNo := MemTableEh1.RecNo;
  i := RecNo - 1;
  k := 0;
  //������ �� ��������������� ������� (���� �� ����, �� ���: MemTableEh1.RecordsView.MemTableData.RecordsList[i])
  repeat
    i := i + Mode;
    inc(k);
    if i >= MemTableEh1.RecordsView.Count then
      i := 0;
    if i < 0 then
      i := MemTableEh1.RecordsView.Count - 1;
    if A.PosInArray(MemTableEh1.RecordsView[i].DataValues[FOpt.SQL.IdField, dvvValueEh], FGridLabelsIds, 0) >= 0 then begin
      MemTableEh1.RecNo := i + 1;
      Break;
    end;
    if k > MemTableEh1.RecordsView.Count then
      Break;
  until False;
end;

procedure TFrDBGridEh.SetState(AIsDataChanged, AHasError, AErrorMessage: Variant);
//���������� ������� ����� (���������, ������, ������ ������). �������� ������ ����� ��� ���������.
//���� �������� �������� ��� null, �� ��� �� ��������
var
  b: Boolean;
  c: TControl;
begin
  try
  if (AIsDataChanged <> null)and(AIsDataChanged <> FIsDataChanged) then begin
    FIsDataChanged := AIsDataChanged;
    b := True;
  end;
  if (AHasError <> null)and(AHasError <> FHasError) then begin
    FHasError := AHasError;
    b := True;
  end;
  if (AErrorMessage <> null)and(AErrorMessage <> FErrorMessage) then begin
    FErrorMessage := AErrorMessage;
    b := True;
  end;
  if FErrorMessage <> '' then begin
//    MyData.IlAll24.GetBitmap(2, ImGState.Picture.Bitmap);
    ImGState.Hint := S.IIf(FErrorMessage = '', '������ � ������!', FErrorMessage);
    Cth.LoadBitmap(MyData.IlAll24, 2, ImGState.Picture.Bitmap);
    //ImGState.Repaint;
  end
  else if FHasError then begin
//    MyData.IlAll24.GetBitmap(2, ImGState.Picture.Bitmap);
    ImGState.Hint := S.IIf(FErrorMessage = '', '������ � ������!', FErrorMessage);
    Cth.LoadBitmap(MyData.IlAll24, 2, ImGState.Picture.Bitmap);
    //ImGState.Repaint;
  end
  else if FIsDataChanged then begin
{    ImGState.Transparent := True;
    ImGState.Picture.Bitmap.Transparent:=True;
    MyData.IlAll24.GetBitmap(1, ImGState.Picture.Bitmap);
    ImGState.Picture.Bitmap.Transparent:=True;}
    Cth.LoadBitmap(MyData.IlAll24, 1, ImGState.Picture.Bitmap);
    ImGState.Hint := '������ ���� ��������.';
    //ImGState.Repaint;
  end
  else begin
{    ImGState.Transparent := True;
    ImGState.Picture.Bitmap.Transparent:=True;
    ImGState.Picture.Bitmap.Canvas.Brush.Color := clNone;
    MyData.IlAll24.GetBitmap(0, ImGState.Picture.Bitmap);
    ImGState.Picture.Bitmap.Canvas.Brush.Color := clNone;
    ImGState.Picture.Bitmap.Transparent:=True;
    ImGState.Transparent := True;
    ImGState.Repaint;}
    Cth.LoadBitmap(MyData.IlAll24, 0, ImGState.Picture.Bitmap);
    ImGState.Hint := '';
  end;
  if (Owner is TFrmBasicMdi) and b then
    TFrmBasicMdi(Owner).Verify(Self);
  except
  end;
end;

procedure TFrDBGridEh.SetStatusBarCaption(Caption: string = ''; AProcessMessages: Boolean = False);
//���������� ������������ ���� � ����������; ���� ������, �� ����� ���������� ���������
begin
  FStatusBarText := Caption;
  PrintStatusBar;
  if AProcessMessages then
    Application.ProcessMessages;
end;

function TFrDBGridEh.GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
//�������� �������� �������� �� ������ �� ��� �����
//���� ����������� NullIfEmpty �� ������� null ���� �������� ����� ������ ��� ''
begin
  Result:= Cth.GetControlValue(Self, ControlName);
  if NullIfEmpty then Result:=S.NullIfEmpty(Result);
end;

procedure TFrDBGridEh.SetControlValue(ControlName: string; Value: Variant);
begin
  Cth.SetControlValue(TControl(Self.FindComponent(ControlName)), Value);
end;





{
�������, ���������� ��������� �� ����� ������ ��� ��������� ������
}


function TFrDBGridEh.SetButtonsAndMenu: Integer;
//�������� ������ ������ � ����
var
  i: Integer;
  Panel: TPanel;
  Vert, b: Boolean;
  MenuItems: TVarDynArray2;
  st: string;
begin
 //�������� ������ ������
  FPanelsBtn:= [];
  MenuItems:= [];
  FBtnIds:= [];
  for i:= Low(Opt.Buttons) to High(Opt.Buttons) do
    if Length(Opt.Buttons[i].A) > 0 then begin
      if (i = 1) and (Opt.Buttons[i].P = nil) then Opt.Buttons[i].P:= PTop;
      if Opt.Buttons[i].P = PLeft then Opt.Buttons[i].V:= true;
      if Opt.Buttons[i].P <> nil then begin
        if (Opt.Buttons[i].P = PTop) or (Opt.Buttons[i].P = PLeft) or (Opt.Buttons[i].P = PBottom)
          then begin
            Panel:=TPanel.Create(Self);
            Panel.Parent:= Opt.Buttons[i].P;
            Panel.Name:= Opt.Buttons[i].P.Name + 'Btns';
          end
          else Panel:= Opt.Buttons[i].P;
          FPanelsBtn:= FPanelsBtn + [Panel];
        if Opt.Buttons[i].T = 0 then Opt.Buttons[i].T := cbttSBig;
        Cth.CreateButtons(Panel, Opt.Buttons[i].A, ButtonOrPopupMenuClick, Opt.Buttons[i].T, S.IIfStr(i > 1, IntToStr(i)), 2, Opt.Buttons[i].H, Opt.Buttons[i].V);
        if uString.A.PosInArray(btnToAlRight, Opt.Buttons[i].A, 0) >= 0 then begin
          Panel.Align:=alClient;
        end;
        MenuItems:= MenuItems + Opt.Buttons[i].A;
      end;
    end;
  for i := 0 to High(MenuItems) do
    if (MenuItems[i][0] = btnPrintGrid) or (MenuItems[i][0] = btnExcel) or (MenuItems[i][0] = btnGridSettings) then begin
      MenuItems[i][0] := btnDividor;
    end;
    if myogGridLabels in Options then
      MenuItems := MenuItems + [[btnDividor], [btnSetGridLabel], [btnToGridLabelDown], {[btnShowGridLabels],} [btnClearGridLabels]];
    if myogColumnFilter in Options then
      MenuItems := MenuItems + [[btnDividor], [btnClearOrRestoreGridFilter]];
    if (myogIndicatorCheckBoxes in Options) and (myogMultiSelect in Options) then
      MenuItems := MenuItems + [[btnDividor], [btnSelectAll], [btnDeSelectAll], [btnInvertSelection]];
    if myogSaveOptions in Options then
      MenuItems := MenuItems + [[btnDividor], [btnGridSettings]];
    if myogPrintGrid in Options then
      MenuItems := MenuItems + [[btnDividor], [btnPrintGrid], [btnExcel]];
  if Length(MenuItems) > 0 then begin
    for i := 0 to High(MenuItems) do
      if High(MenuItems[i]) >= 0 then begin
        if MenuItems[i][0] < 0
          then MenuItems[i][0] := -MenuItems[i][0];
        if S.VarType(MenuItems[i][0]) = varInteger then
          if not A.InArray(MenuItems[i][0], FBtnIds) then
            FBtnIds := FBtnIds + [MenuItems[i][0]];
      end;
    Cth.CreatePopupMenu(PmGrid, MenuItems, ButtonOrPopupMenuClick, '');
    FPanelsBtn:= FPanelsBtn + [DBGridEh1.PopupMenu];
  end;
end;

procedure TFrDBGridEh.SetPanels;
//�����������/�������/��������� �������� �������
//(�������, ������, �������), � ����������� �� ���� ���� �� � ��� ��������
//(��������, ������ ��� ����������� ������ � ����������
var
  i: Integer;

  procedure SetPanelState(APanel: TPanel);
  begin
    if APanel.ControlCount > 0 then begin
      APanel.Width:= APanel.Controls[0].Width;
      APanel.Height:= APanel.Controls[0].Height;
      APanel.Visible:=true;
    end
    else begin
      APanel.Width:= 0;
      APanel.Height:= 0;
      //���� ��� ��������, �� ��� ��������, ����� ������ ���� ����� ����� ������
      //APanel.Visible:=False;
    end;
  end;

begin
  //������ ���� ������� ��������� � �������
  For i:=0 to Self.ComponentCount - 1 do
    if Self.Components[i] is TPanel then begin
      TPanel(Self.Components[i]).Caption:='';
      TPanel(Self.Components[i]).BevelInner:= bvNone;
      TPanel(Self.Components[i]).BevelOuter:= bvNone;
    end;
  SetPanelState(PContainer);
  SetPanelState(PTop);
  SetPanelState(PBottom);
  SetPanelState(PLeft);
  FrameResize(nil);
end;

procedure TFrDBGridEh.SetDataDriverCommandSelect;
//���������� ������� ������ ��� ������������
//�������� ������, ��� ��� ����� �������� �� ������� � �������� ������ (�������� ��-�� ���������� ������� �� ������ �������)
var
  st, sts, stw, stwa: string;
  i, j: Integer;
  FieldsOld: string;

  function GetFieldsStr: string;
  //������� �������� ������ ����� �� �������, � ��������� �� ������ �������� ����, ������� �� ����� ���������
  var
    i, j: Integer;
    st, st1: string;
  begin
    Result := '';
    for i := 0 to High(Opt.Sql.Fields) do begin
      st := A.Explode(Opt.Sql.Fields[i].NameDb, '$')[0];
      if st <> Opt.Sql.Fields[i].Name then
        st := st + ' as ' + Opt.Sql.Fields[i].Name;
      st1 := '';
      if Opt.Sql.Fields[i].FIsNull then begin
        if Opt.Sql.Fields[i].DataType = ftString then
          st1 := '''  '''
        else if Opt.Sql.Fields[i].DataType = ftFloat then
          st1 := '0.0'
        else if Opt.Sql.Fields[i].DataType = ftInteger then
          st1 := '0'
        else
          st1 := 'null';
        st1 := st1 + ' as ';
      end;
      S.ConcatStP(Result, st1 + st, ';');
    end;
  end;
begin
  {
  //�������� ���� ��� ��� ���� ��������, � ����� �����������.
  //���� �������������� � ������ ������ �� ����.
  //��� �������� � ������, ������� �� ������� ���������, ��� ������� ��� ���������� ����� �� ������ ����� (��� ���������� �������� ������)
  FieldsOld := FOpt.Sql.FieldNames;}
  //��������� sqlwhere �� ������ ���������� �������
  stw := TFrmXDedtGridFilter.GetDefRule(Self);
  //������� ���������� ������� ��� ������� (��������, �� �������)
  //����� � ���� ��������� ����� ��������������� �������� ���� ��� ������ �� ����
  //����� � ���� ������� ��������������� � ���������, ��� ��� ��� ����� ���� ��� �� ������������� �����, ��� ��������� ���������� ���� �������� �������������� ����������
  if Assigned(FOnSetSqlParams)
    then FOnSetSqlParams(Self, FNo, stw);
  stw := Trim(stw);
  st := GetFieldsStr; //FOpt.Sql.FieldNames;
  //������� ���� id �� ������ ������ � �� �����; ���� �������� �� ���������, �� ����� ������ � ��������, ������������ ���� ������ (GetRec, Update...)
  if pos('id;', st) = 1 then begin
    st := 'to_char(id) as id' + Copy(st, 3);
  end;
  st := Q.QSIUDSql('a', FOpt.SQL.View, st);
  sts := FOpt.SQL.Select;
  if (myogLoadAfterVisible in Options) and (TimerAfterStart.Enabled)
    then stwa := 'where 1 = 2'
    else stwa := Trim(FOpt.SQL.WhereAllways);
  if FOpt.SQL.Select = '=' then
    sts := ADODataDriverEh1.SelectSQL.Text
  else if FOpt.SQL.Select = '' then
    sts := st;
  if stw <> '' then begin
    if Pos('/*WHERE*/', sts + stwa) > 0 then
      ADODataDriverEh1.SelectSQL.Text := StringReplace(sts + S.IIf(stwa <> '', ' ' + stwa, ''), '/*WHERE*/', ' where (' + stw + ') ', [])
    else if Pos('/*ANDWHERE*/', sts + stwa) > 0 then
      ADODataDriverEh1.SelectSQL.Text := StringReplace(sts + S.IIf(stwa <> '', ' ' + stwa, ''), '/*ANDWHERE*/', ' and (' + stw + ') ', [])
    else if Pos('/*WHEREONLY*/', sts + stwa) > 0 then
      ADODataDriverEh1.SelectSQL.Text := StringReplace(sts + S.IIf(stwa <> '', ' ' + stwa, ''), '/*WHEREONLY*/', stw, [])
    else begin
      i := pos('where ', stwa);
      if i > 0 then
        Insert(stw + ' and ', stwa, 7)
      else
        stwa := 'where ' + stw + S.IIf(stwa <> '', ' ', '') + stwa;
      ADODataDriverEh1.SelectSQL.Text := sts + S.IIf(stwa <> '', ' ', '') + stwa;
    end;
  end
  else
    ADODataDriverEh1.SelectSQL.Text := sts + S.IIf(stwa <> '', ' ', '') + stwa;
  if FOpt.SQL.GetRec = '' then
    ADODataDriverEh1.GetRecCommand.CommandText.Text := sts + ' where ' + FOpt.SQL.IdField + ' = :' + FOpt.SQL.IdField;
  //����� �������� ������� ��� ��������� ���������� ��� (������ ��� sqlselect � sqlgetrec), ��������� �� ����� ������� where ����� ��� �� ������������
  if Assigned(FOnSetSqlParams)
    then FOnSetSqlParams(Self, FNo, stw);
end;

procedure TFrDBGridEh.SetDataDriverCommands;
//�������� ������� ������������
var
  i, j: Integer;
  st: string;
begin
//if FOpt.Sql.Select <> '' then begin  //!!!
//ADODataDriverEh1.SelectCommand.CommandText.Text := FOpt.Sql.Select;
//exit;
//end;
  //���� ������ ���� ������ ����� "id", �� ������� ��� �� ��������� ��� ��� ������,
  //����� ��������� �������� ���������� ������� ���� refreshrecord, update...
  st := FOpt.Sql.FieldNames;
  if pos('id;', st) = 1 then begin
    st := 'to_char(id) as id' + Copy(st, 3);
  end;
  SetDataDriverCommandSelect;
  if Opt.SQL.Update <> '=' then
    if Opt.SQL.Update = '*' then
      ADODataDriverEh1.UpdateCommand.CommandText.Text := Q.QSIUDSql('u', Opt.SQL.Table, st)
    else if Opt.SQL.Update = '' then
      ADODataDriverEh1.UpdateCommand.CommandText.Text := 'select 1 from dual';
  if Opt.SQL.Insert <> '=' then
    if Opt.SQL.Insert = '*' then
      ADODataDriverEh1.InsertCommand.CommandText.Text := Q.QSIUDSql('i', Opt.SQL.Table, st)
    else if Opt.SQL.Insert = '' then
      ADODataDriverEh1.InsertCommand.CommandText.Text := 'select 1 from dual';
  if Opt.SQL.Delete <> '=' then
    if Opt.SQL.Delete = '*' then
      ADODataDriverEh1.DeleteCommand.CommandText.Text := Q.QSIUDSql('d', Opt.SQL.Table, st)
    else if Opt.SQL.Delete = '' then
      ADODataDriverEh1.DeleteCommand.CommandText.Text := 'select 1 from dual';
  //������ ��� ������
  MemTableEh1.FetchAllOnOpen := true;
end;

procedure TFrDBGridEh.SetSqlParameters(ParamNames: string; ParamValues: TVarDynArray; CommandType: string = 's');
//���������� ��������� ������� CommandType (���������� ������� ����� ;)
//���� �������� �� ������ � �������, �� �� ������������
begin
  Q.QSetParamsEh(ADODataDriverEh1, ParamNames, ParamValues, CommandType, True);
end;

procedure TFrDBGridEh.ChangeSelectedData;
//�������� �� ���� �������, ����� ���� ���������� �������, ��� �������� ������ � ������� ������
//��������� ��������� �������� ��� ���� (����������� ������...) � �������� �������������� ������� ������
var
  i: Integer;
begin
  try
  if InLoadData then Exit;
  if not MemTableEh1.Active then Exit;
  if FDisableChangeSelectedData then Exit;
  //���������� ������ � ������ ���� ���� ���� �����, ����� ����� ������� � ButtonsIfEmpty
  SetButtonsState;
  //������� ������� ��������
  if Assigned(FOnSelectedDataChange)
    then FOnSelectedDataChange(Self, No);
  //�������� ��������� (� ������� ���������� ������ �� ��������� ��� �����������)
  PrintStatusBar;
  except
  end;
end;

procedure TFrDBGridEh.SetRowDetailPanelSize;
//������� ������� ���������� ����� � ���� ������
//���������� �������� �����, ���� ������ 0 �� �������� ��������� ��� ��� ������, ���� ������ 0 �� ���������� �� ������ ��������� �����
//��������� ����� � ������ ������ ��������������� � ������ ��������� ����� � ������� ������
var
  i, j, k, rn, rh, fh: Integer;
function IsHorzScrollBarVisible(hWnd: HWND): Boolean;
var
  style: Integer;
begin
  style := GetWindowLong(hWnd, GWL_STYLE);
  Result := (style and WS_HSCROLL) <> 0;
end;
begin
  FGrid2.Align:=alNone;
  DBGridEh1.RowDetailPanel.Height := TForm(Owner).Height - FGrid2.DBGridEh1.Top - 50;

  rh := 0; fh := 0;
  for i := 0 to TDBGridEhMy(FGrid2.DBGridEh1).RowCount - 1 do
    rh := rh + TDBGridEhMy(FGrid2.DBGridEh1).RowHeights[i];
  for i := 0 to TDBGridEhMy(FGrid2.DBGridEh1).FooterRowCount - 1 do
    fh := fh + mydefGridRowHeight;

  i := Min(DBGridEh1.RowDetailPanel.Height + FGrid2.PGrid.Top - 200,
    FGrid2.PGrid.Top +
    rh +  //������ ����� ����� � ����������
    fh +  //������ ������
//    mydefGridRowHeight * (FGrid2.DBGridEh1.RowCount + 1) + //������ ����� ���������� ���� + ��������� �����
    S.IIf((myogPanelFilter in FGrid2.Options) or (myogPanelFind in FGrid2.Options), 30, 0) +  //����� ������ ������
    //����� ��������� �������������� ��������, ���� ������� (���������� �� ��� �������� ���������, ��������� ����� �� �������)
    S.IIf(FGrid2.DBGridEh1.HorzScrollBar.Visible, 23 , 0)
//    S.IIf(IsHorzScrollBarVisible(FGrid2.DBGridEh1.Handle), 23 , 0)  //����� ��������� �������������� ��������
//    S.IIf(FGrid2.DBGridEh1.HorzScrollBar.VisibleMode <> sbNeverShowEh, FGrid2.DBGridEh1.HorzScrollBar.Height + 1 , 0)  //����� ��������� �������������� ��������
  );
  FGrid2.Height := i;
  if DBGridEh1.RowDetailPanel.Height > FGrid2.Height + 20 then
    DBGridEh1.RowDetailPanel.Height := FGrid2.Height + 20;
  FGrid2.Align:=alClient;
end;

procedure TFrDBGridEh.ReadGridLabels;
//������ ����� ������� �� ��
begin
  if not (myogGridLabels in Options) then
    Exit;
  FGridLabelsIds := Q.QLoadToVarDynArray2('select tablerow, labelnum from grid_labels where doc = :doc$s and id_user = :id_user$i and tablenum = 1', [TFrmBasicMdi(Owner).FormDoc, User.GetId]);
end;

procedure TFrDBGridEh.ShowColumnInfo;
//�������� ����������-��������� �� �������� �������, ���� ��� ���� � ����������.
//���������� � ����� �� F1
var
  i: Integer;
  st: string;
begin
  for i := 0 to High(Opt.ColumnsInfo) do
    if S.InCommaStrI(CurrField, Opt.ColumnsInfo[i][0], ';') then
      Break;
  st := DbGridEh1.FindFieldColumn(CurrField).Title.Caption;
  if i <= High(Opt.ColumnsInfo) then
    st := st + #13#10 + Opt.ColumnsInfo[i][1];
  MyInfoMessage(st);
end;

procedure TFrDBGridEh.DataGrouping;
//����������� � �������� ��� ��������� ����������� �� ������ ��������; ���������� � SetColumnsPropertyes
//������ �������� ��� ��������� ����� ��������� �����
var
  i: Integer;
begin
  DBGridEh1.DataGrouping.GroupLevels.Clear;
  if Length(Opt.DataGrouping.Fields) <> 0 then begin
    for i:= 0 to High(Opt.DataGrouping.Fields) do begin
      DBGridEh1.DataGrouping.GroupLevels.Add;
      DbGridEh1.DataGrouping.GroupLevels[DBGridEh1.DataGrouping.GroupLevels.Count-1].Column:=
        DBGridEh1.FindFieldColumn(Opt.DataGrouping.Fields[i]);
      if High(Opt.DataGrouping.Fonts) >= i then
        DBGridEh1.DataGrouping.GroupLevels[i].Font := Opt.DataGrouping.Fonts[i];
      if High(Opt.DataGrouping.Colors) >= i then
        DBGridEh1.DataGrouping.GroupLevels[i].Color := Opt.DataGrouping.Colors[i];
    end;
  end;
  DbGridEh1.DataGrouping.Active := Opt.DataGrouping.Active;
end;

































{==============================================================================}
{
� ����������
}

{
procedure TFrDBGridEh.AddRow(ALast: Boolean = true; AIfNotempty: Boolean = true);
var
  i: Integer;
  b: Boolean;
begin
  //���� ��������� � ����� - �������� �� �������� ������
//  if ALast then MemTableEh1.Last;
  //������� ������ ���� ������� ������ ��������� ���� �� �������� (��� AddIfNotempty)
  //� ������� ������ ��������� (������ ��������� ������������� � �� ��������� ���������� true:
  //��� ���� ����� ��� ����������� ����������� �� �������� ������, ����� ��������� �� ��� ������ �����)
//  if not ((not AIfNotempty or IsRowNotEmpty) and IsRowCorrect) then Exit;
  DBGridEh1.AllowedOperations := [alopInsertEh, alopUpdateEh, alopDeleteEh, alopAppendEh];
  DbGridEh1.ReadOnly := False;
  MemTableEh1.ReadOnly := False;
  if ALast
    then MemTableEh1.Append
    else MemTableEh1.Insert;
end;
}


procedure TFrDBGridEh.Test;
var
  i, j: Integer;
begin
//  DBGridEh1.OnShowFilterDialog
end;

function TFrDBGridEh.InsertRow: Boolean;
//������� ������ � �������, ���� �������� ��� ��������
//���� �������� �������� ����������, �� ������� � �����
//�������� �� ������ � �� VK_INSERT
begin
  if (MemTableEh1.State in [dsInsert]) or not ((alopInsertEh in FOpt.AllowedOperations) or (alopAppendEh in FOpt.AllowedOperations)) then
    Exit;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations + [alopInsertEh];
  if not (alopInsertEh in FOpt.AllowedOperations) then
    MemTableEh1.Append
  else
    MemTableEh1.Insert;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations - [alopInsertEh];
end;

function TFrDBGridEh.AddRow: Boolean;
//���� �������� �������� ����������, �� ������� � ������ ����� �������
//�������� �� ������ � �� VK_DOWN �� ��������� ������ �����
begin
  if (MemTableEh1.State in [dsInsert]) or not (alopAppendEh in FOpt.AllowedOperations) then
    Exit;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations + [alopInsertEh];
  MemTableEh1.Append;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations - [alopInsertEh];
end;

function TFrDBGridEh.DeleteRow: Boolean;
//���� �������� �������� ��������, �� ������ � ������ ����� �������
begin
  if (MemTableEh1.State in [dsInsert]) or not (alopInsertEh in FOpt.AllowedOperations) then
    Exit;
  if (ID < MY_IDS_INSERTED_MIN) and not A.InArray(ID, FEditData.IdsDeleted) then
    FEditData.IdsDeleted := FEditData.IdsDeleted + [ID];
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations + [alopDeleteEh];
  MemTableEh1.Delete;
  DBGridEh1.AllowedOperations := DBGridEh1.AllowedOperations - [alopDeleteEh];
end;

function TFrDBGridEh.IsRowNotEmpty(RowNum: Integer = -1): Boolean;
//������ True, ���� � ������ ���� ���� �� ��������� ���� �� null (��� ������ ������� ����� True)
var
  i: Integer;
begin
  Result := True;
  if RowNum = -1 then
    RowNum := MemTableEh1.RecNo - 1;
  if GetCount(False) = 0 then
    Exit;
  for i := 0 to MemTableEh1.Fields.Count - 1 do
    if (Pos('_', DbGridEh1.FindFieldColumn(MemTableEh1.Fields[i].FieldName).Title.Caption) = 0) and (S.NSt(GetValue(MemTableEh1.Fields[i].FieldName, RowNum, False)) <> '') then
      Exit;
  Result := False;
end;

function TFrDBGridEh.IsRowCorrect(RowNum: Integer = -1): Boolean;
//������ ����, ���� ������ ��������� ���������
//�� ��������� ��������� � ����������� � ColumnsVerify (���� ��������� �� ����� �� ������ True)
//������ ������ ����������
//!!! ��� ������������� ������� ������!!!
var
  i, j: Integer;
  v: Variant;
  FRec: TFrDBGridRecFieldsList;
  IsValueCorrect: Boolean;
  Msg: string;
  st: string;
  Value, CorrectValue: Variant;
  b: Boolean;
begin
  Result := True;
  if RowNum = -1 then
    RowNum := MemTableEh1.RecNo - 1;
  b := False;
  for i := 0 to MemTableEh1.Fields.Count - 1 do begin
    FRec := Opt.GetFieldRec(MemTableEh1.Fields[i].FieldName);
    Value := VaRToStr(GetValue(MemTableEh1.Fields[i].FieldName, RowNum, False));
    if Value = '��' then
      b := True;
    IsValueCorrect := (FRec.FVerify = '') or S.VeryfyValue(q.QGetDataTypeAsChar(MemTableEh1.Fields[i].DataType), FRec.FVerify, Value, CorrectValue);
    if IsValueCorrect and Assigned(FOnVeryfyAndCorrectValues) then
      FOnVeryfyAndCorrectValues(Self, No, dbgvBefore, RecNo, MemTableEh1.Fields[i].FieldName, Value, Msg);
    st := IntToStr(RowNum + 1) + '-' + IntToStr(DbGridEh1.FindFieldColumn(MemTableEh1.Fields[i].FieldName).Index + 1);
    j := A.PosInArray(st, FEditData.CellsWithErrors);
    if IsValueCorrect and (i=2)
      then b := True
      else b := False;
    if not IsValueCorrect or (Msg <> '') then
      Result := False;
    if (not IsValueCorrect or (Msg <> '')) and (j = -1) then begin
      FEditData.CellsWithErrors := FEditData.CellsWithErrors + [st];
      b := True;
    end
    else if (IsValueCorrect and (Msg = '')) and (j > -1) then begin
      Delete(FEditData.CellsWithErrors, j, 1);
      b := True;
    end;
   // if b then
      //DbGridEh1.Repaint;
//      IncorrectRowMsg:='��������� �������� ������ ' + InttoStr(MemTableEh1.RecNo) + ' � ������ "' + DBGridEh1.Columns[i].Title.Caption + '"';
  end;
end;

function TFrDBGridEh.IsTableEmpty: Boolean;
//������ ����, ���� � ������� ��� ����� ���� ��� ��������� ���� ������ ������
var
  i: Integer;
begin
  Result := True;
  for i := 0 to GetCount(False) - 1 do begin
    Result := not IsRowNotEmpty(i);
    if not Result then
      Break;
  end;
end;

function TFrDBGridEh.IsTableCorrect: Boolean;
//������ ����, ���� � ������� ��� ������ ������
//��� ���� ������ ������ ��������� �������
var
  i, j, k, m: Integer;
  ERows: string;
begin
  Result := True;
  for i := 0 to GetCount(False) - 1 do begin
    if not IsRowNotEmpty(i) then
      Continue;
    if not IsRowCorrect(i) then begin
      Result := False;
      S.ConcatStP(ERows, IntToStr(i + 1), ', ');
    end;
  end;
  //�������� ������������� ����
  for j := 0 to High(FEditOptions.FieldsNoRepaeted) do begin
    for k := 0 to GetCount(False) - 2 do
      for m := k + 1 to GetCount(False) - 1 do
        if GetValue(FEditOptions.FieldsNoRepaeted[j], k, False) = GetValue(FEditOptions.FieldsNoRepaeted[j], m, False) then begin
          Result := False;
          S.ConcatStP(ERows, '������������� �������� � ������� ' + InttoStr(k + 1) + ' � ' + InttoStr(m + 1) +
            ' � ������� "' + DBGridEh1.FindFieldColumn(FEditOptions.FieldsNoRepaeted[j]).Title .Caption+ '"', #13#10);
          break
        end;
  end;
  //�������� ������; ���� ������� ��������� �� ������, HasError:=False, ����� ��� �������� ������ �� � �� ������� ����������� ������� � ����� ��������� �� ������.
  SetState(null, S.IIf(EditOptions.AlwaysVerifyAllTable, False, not Result), S.IIfStr(not Result, '������������ �������� � �������:'#13#10 + ERows));
end;



end.


















(*









--------------------------------------------------------------------------------
��� ��������, ������� ����� ������, ����� ������ ReadOnly = False. ��������������� ������ ������������
� ������� ColumnsGetCellParams, �� ���������� ���� ��� ��� ���� ������� � ������ ��������������
� ������-������� �� ������� �������.



���������� ��������� ����� ����� �� Prepare ����� � ������, ������������� �������� FOptions � ����� ������,
�� ���� ����������� ����� ������� (����� ���������� � ����� �������, � ����� ��� ��������� ���� ����� ��� ����� ��������)

������ � ������������� ���� �� �������� �� ������ ������, �� �������� � ����, �.�. ����� ������ [-btnAdd], [-1000, '���������']

*)

(*


--------------------------------------------------------------------------------
�������� ��������� ������ � ������.
�������� ������� ��������� ����������
SetState(AIsDataChanged, AHasError, AErrorMessage: Variant)
�������� �� �������. ������������� ���������� Verify ������������ TFrmBasicMdi, ��� nil ��� �������� �����,
� ��� ���������� ������� SetState �������� ��������� Verify ����� ��� ���������.
������ ����� �������������� ������ IsDataChanged ��� ����� � ���������, � ������ ��������� ������� �������
�������� ���� ������������ ������, � ������ ������ � ��������� ����� - �� ����������� ��������� ������
(����� � ���� ������ ����������� �������� ���������� ��������� �����, �������� ������ ���� �����������!
���, ��� �������, ��������� ������ ������ � RefreshGrid, ���� ��� ����� �� �� �������� ����������!!!).
��� ������� ������������, ����� ����������� ������� (� MemTableEh1BeforeClose).
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
�������� � ���������� ��������
�������� ����������� ������ � ��� ������ ���� ���� � ������ myogSaveOptions,
� ������� �������� �������� MemTableEh1BeforeClose, � ��� ���������� ������, ���� ������� ������.
����������� ��� �������� �������� � ������� MemTableEh1AfterOpen, ����� ���������� ��������
�����, �������� ����������� � ���� (�����)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
��� � ��������. ��� ���������� � �������, ���� ��������� ������� � ����, ��� �� �����������, �� ��
�� ���������� ������� OnApplyfilter. �����, �������, �� �������� ������ ���������� � ���� �������.
������ �� ���������� ��������� ��������. ������ ����������� DefaultApplyfilter � ����������� DbGridEh1CellMouseClick,
���� ��� ���� � ������ �������, � �� �� ����������, �� ��������� ��� ����� � ����.
�� ��� DbGridEh1CellMouseClick ������� ���������� ������� ����� ���� (�����, �����, ���������), �� ���� �� ������� � ����.\
������� OnEnter ��� ����� ����� �� ���������, ���� ��� ������� � ���������� ����, �� ��� ����� ��������
� ���������� ��������� ������� ������ ����� ������.
--------------------------------------------------------------------------------
*)





(*

               ����������!
-���������� ����� � ���������� ���� ������� (���� ��� ����� � ��� ����)
-��������� ������������ ����� � �� ����������� � �� ���������������
-������� ������������ ����������� �� ������ � ���������� �� ������� ������ ������
 (��� ������ � frmMDI)
-���������� ������������� ������������ ��������� �������
-��������� ������� ������, ��������� �� �  ������ ������ (����� � ��������, �� ���������!)
-���������� �������� �������� ������, ������, �����
-��������� ��������� ������ �������� �� ��������/�������� � ������� � � �� � ������ ������ ������ ������
-��������� ����������/�������� �����, ������� ����� ���������
-��������� �������
-��� � ��������� ��������, ����������� �� ���� ��������� ������
++��� ������ �������� ����� � ������ �������� �� ������� ������ ����������� �� ��������� ������
-SetButtonsIfEmpty �������� clear
-��� ���� ������ ���������� ���������� � TMDIResult �����
-���: ��� ���������� ������� � ������� ������ � ������ �������������� � ������ �����
-���: ���� ���� ������������ ��������, � ���� �����������, �� ���������� ������� � �������, � ������ ����� �� ���

-� DbGridEh1AdvDrawDataCell �� �������� ��� ��������� ���������� ��� �����������,
� ��������� ����������� ������ ���, ��� ��� ����� ���� � ������ ����������� ������������ ���� � ����������

+2025-04-03
��� ��� ����� ���� �������, �������� ������, ������� �� �������� ���������
�������� try-ex-end � prinntstatusbar � changeselecteddata
*)
