inherited Form_TestTree: TForm_TestTree
  Caption = 'Form_TestTree'
  ClientHeight = 441
  ClientWidth = 349
  ExplicitWidth = 365
  ExplicitHeight = 480
  TextHeight = 13
  object DBGridEh1: TDBGridEh
    Left = 8
    Top = 8
    Width = 343
    Height = 385
    AllowedOperations = [alopUpdateEh]
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    DynProps = <>
    Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
    RowDetailPanel.Height = 250
    TabOrder = 0
    OnDblClick = DBGridEh1DblClick
    object RowDetailData: TRowDetailPanelControlEh
      object edt_PPComment: TDBEditEh
        Left = 299
        Top = 215
        Width = 494
        Height = 21
        ControlLabel.Width = 67
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Text = 'edt_PPComment'
        Visible = False
      end
    end
  end
  object Bt_Ok: TBitBtn
    Left = 266
    Top = 408
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1042#1099#1073#1088#1072#1090#1100
    TabOrder = 1
    OnClick = Bt_OkClick
  end
  object Bt_Collapse: TBitBtn
    Left = 8
    Top = 408
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1057#1074#1077#1088#1085#1091#1090#1100
    TabOrder = 2
    OnClick = Bt_CollapseClick
  end
  object Bt_Expand: TBitBtn
    Left = 89
    Top = 408
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1056#1072#1089#1082#1088#1099#1090#1100
    TabOrder = 3
    OnClick = Bt_ExpandClick
  end
  object chb_Materials: TDBCheckBoxEh
    Left = 170
    Top = 412
    Width = 97
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #1052#1072#1090#1077#1088#1080#1072#1083#1099
    DynProps = <>
    TabOrder = 4
    OnClick = chb_MaterialsClick
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 31
    Top = 218
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh1
    TreeList.Active = True
    Left = 107
    Top = 203
  end
  object ADODataDriverEh1: TADODataDriverEh
    ADOConnection = myDBOra.AdoConnection
    DynaSQLParams.Options = []
    MacroVars.Macros = <>
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    Left = 168
    Top = 240
  end
end
