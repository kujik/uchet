object Dlg_SelectUsers: TDlg_SelectUsers
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Dlg_SelectUsers'
  ClientHeight = 457
  ClientWidth = 556
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  DesignSize = (
    556
    457)
  PixelsPerInch = 96
  TextHeight = 13
  object Img_Info: TImage
    Left = 4
    Top = 433
    Width = 21
    Height = 20
    Anchors = [akLeft, akBottom]
    ExplicitTop = 423
  end
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = 5
    Width = 552
    Height = 422
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    DynProps = <>
    IndicatorOptions = [gioShowRowIndicatorEh, gioShowRecNoEh, gioShowRowselCheckboxesEh]
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
    OptionsEh = [dghFixed3D, dghFrozen3D, dghFooter3D, dghData3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghShowRecNo, dghColumnResize, dghColumnMove, dghExtendVertLines]
    ParentShowHint = False
    ReadOnly = True
    SearchPanel.Enabled = True
    SearchPanel.FilterOnTyping = True
    ShowHint = True
    SortLocal = True
    TabOrder = 0
    OnCellClick = DBGridEh1CellClick
    OnMouseDown = DBGridEh1MouseDown
    OnSelectionChanged = DBGridEh1SelectionChanged
    Columns = <
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'value'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'name'
        Footers = <>
        Title.Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
        Width = 482
        OnGetCellParams = DBGridEh1Columns1GetCellParams
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'id'
        Footers = <>
        Visible = False
      end>
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object Bt_Ok: TBitBtn
    Left = 400
    Top = 428
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    Default = True
    TabOrder = 1
    OnClick = Bt_OkClick
  end
  object Bt_Cancel: TBitBtn
    Left = 477
    Top = 428
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 2
  end
  object Bt_Repeat: TBitBtn
    Left = 31
    Top = 428
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1055#1086#1074#1090#1086#1088#1080#1090#1100
    TabOrder = 3
    OnClick = Bt_RepeatClick
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 200
    Top = 280
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 256
    Top = 280
  end
end
