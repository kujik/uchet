inherited Dlg_Or_FindNameInEstimates: TDlg_Or_FindNameInEstimates
  Caption = 'Dlg_Or_FindNameInEstimates'
  ClientWidth = 621
  OnKeyDown = FormKeyDown
  ExplicitWidth = 627
  ExplicitHeight = 500
  PixelsPerInch = 96
  TextHeight = 13
  inherited P_StatusBar: TPanel
    Width = 621
    ExplicitWidth = 621
    inherited Lb_StatusBar_Right: TLabel
      Left = 532
      Height = 17
      ExplicitLeft = 532
    end
    inherited Lb_StatusBar_Left: TLabel
      Height = 17
    end
  end
  object P_Top: TPanel [1]
    Left = 0
    Top = 0
    Width = 621
    Height = 67
    Align = alTop
    TabOrder = 1
    DesignSize = (
      621
      67)
    object Bt_Go: TSpeedButton
      Left = 585
      Top = 4
      Width = 32
      Height = 32
      Anchors = [akTop, akRight]
      OnClick = Bt_GoClick
      ExplicitLeft = 748
    end
    object Img_Info: TImage
      Left = 597
      Top = 42
      Width = 20
      Height = 20
    end
    object E_Name: TDBEditEh
      Left = 4
      Top = 15
      Width = 569
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ControlLabel.Width = 167
      ControlLabel.Height = 13
      ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1089#1084#1077#1090#1085#1086#1081' '#1087#1086#1079#1080#1094#1080#1080
      ControlLabel.Visible = True
      DynProps = <>
      EditButtons = <>
      TabOrder = 0
      Visible = True
    end
    object Chb_InclosedOrders: TCheckBox
      Left = 4
      Top = 42
      Width = 173
      Height = 17
      Caption = #1048#1089#1082#1072#1090#1100' '#1074' '#1079#1072#1082#1088#1099#1090#1099#1093' '#1079#1072#1082#1072#1079#1072#1093
      TabOrder = 1
    end
    object Chb_Like: TCheckBox
      Left = 183
      Top = 42
      Width = 114
      Height = 17
      Caption = #1048#1089#1082#1072#1090#1100' '#1087#1086' '#1084#1072#1089#1082#1077
      TabOrder = 2
    end
  end
  object Pc_1: TPageControl [2]
    Left = 0
    Top = 67
    Width = 621
    Height = 385
    ActivePage = Ts_Orders
    Align = alClient
    TabOrder = 2
    object Ts_Items: TTabSheet
      Caption = #1057#1090#1072#1085#1076#1072#1088#1090#1085#1099#1077' '#1080#1079#1076#1077#1083#1080#1103
      object DBGridEh1: TDBGridEh
        Left = 0
        Top = 0
        Width = 613
        Height = 357
        Align = alClient
        DataSource = DataSource1
        DynProps = <>
        Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
        RowDetailPanel.Height = 250
        TabOrder = 0
        OnDblClick = DBGridEh1DblClick
        object RowDetailData: TRowDetailPanelControlEh
          object E_PPComment: TDBEditEh
            Left = 299
            Top = 215
            Width = 494
            Height = 21
            ControlLabel.Width = 70
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Text = 'E_PPComment'
            Visible = False
          end
        end
      end
    end
    object Ts_Orders: TTabSheet
      Caption = #1047#1072#1082#1072#1079#1099
      ImageIndex = 1
      object DBGridEh2: TDBGridEh
        Left = 0
        Top = 0
        Width = 613
        Height = 357
        Align = alClient
        DataSource = DataSource2
        DynProps = <>
        Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
        RowDetailPanel.Height = 250
        TabOrder = 0
        OnDblClick = DBGridEh2DblClick
        object RowDetailData: TRowDetailPanelControlEh
          object DBEditEh1: TDBEditEh
            Left = 299
            Top = 215
            Width = 494
            Height = 21
            ControlLabel.Width = 70
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Text = 'E_PPComment'
            Visible = False
          end
        end
      end
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 744
    Top = 64
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh1
    Left = 739
    Top = 123
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 739
    Top = 182
  end
  object ADODataDriverEh1: TADODataDriverEh
    ADOConnection = myDBOra.AdoConnection
    DynaSQLParams.SkipUnchangedFields = True
    DynaSQLParams.Options = []
    MacroVars.Macros = <>
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    Left = 40
    Top = 385
  end
  object ADODataDriverEh2: TADODataDriverEh
    ADOConnection = myDBOra.AdoConnection
    DynaSQLParams.SkipUnchangedFields = True
    DynaSQLParams.Options = []
    MacroVars.Macros = <>
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    Left = 120
    Top = 389
  end
  object DataSource2: TDataSource
    DataSet = MemTableEh2
    Left = 205
    Top = 386
  end
  object MemTableEh2: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh2
    Left = 265
    Top = 403
  end
end
