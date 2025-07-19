inherited Dlg_ItmInfo: TDlg_ItmInfo
  Caption = 'Form_MD'
  ClientHeight = 421
  ClientWidth = 656
  ExplicitWidth = 668
  ExplicitHeight = 459
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 402
    Width = 656
    ExplicitTop = 401
    ExplicitWidth = 652
    inherited lbl_StatusBar_Right: TLabel
      Left = 569
      Height = 17
      ExplicitLeft = 567
    end
    inherited lbl_StatusBar_Left: TLabel
      Height = 17
    end
  end
  object pnl_Top: TPanel [1]
    Left = 0
    Top = 0
    Width = 656
    Height = 89
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 652
    DesignSize = (
      656
      89)
    object lbl1: TLabel
      Left = 12
      Top = 8
      Width = 16
      Height = 13
      Caption = 'lbl1'
    end
    object lbl2: TLabel
      Left = 12
      Top = 27
      Width = 16
      Height = 13
      Caption = 'lbl1'
    end
    object lbl3: TLabel
      Left = 12
      Top = 46
      Width = 16
      Height = 13
      Caption = 'lbl1'
    end
    object lbl4: TLabel
      Left = 12
      Top = 65
      Width = 16
      Height = 13
      Caption = 'lbl1'
    end
    object Bt_Go: TSpeedButton
      Left = 612
      Top = 8
      Width = 32
      Height = 32
      Anchors = [akTop, akRight]
      OnClick = Bt_GoClick
      ExplicitLeft = 620
    end
  end
  object Pc_1: TPageControl [2]
    Left = 0
    Top = 89
    Width = 656
    Height = 313
    ActivePage = ts_FromCAD
    Align = alClient
    TabOrder = 2
    object ts_Artikul: TTabSheet
      Caption = #1040#1088#1090#1080#1082#1091#1083#1099
      object DBGridEh1: TDBGridEh
        Left = 0
        Top = 0
        Width = 648
        Height = 285
        Align = alClient
        DataSource = DataSource1
        DynProps = <>
        Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
        RowDetailPanel.Height = 250
        TabOrder = 0
        object RowDetailData: TRowDetailPanelControlEh
          object edt_PPComment: TDBEditEh
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
            Text = 'edt_PPComment'
            Visible = False
          end
        end
      end
    end
    object ts_Nomencl: TTabSheet
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1103
      ImageIndex = 2
      object DBGridEh2: TDBGridEh
        Left = 0
        Top = 0
        Width = 648
        Height = 285
        Align = alClient
        DataSource = DataSource2
        DynProps = <>
        Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
        RowDetailPanel.Height = 250
        TabOrder = 0
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
            Text = 'edt_PPComment'
            Visible = False
          end
        end
      end
    end
    object ts_FromCAD: TTabSheet
      Caption = #1053#1086#1084#1077#1085#1082#1083#1072#1090#1091#1088#1072' '#1080#1079' CAD'
      ImageIndex = 2
      object DBGridEh3: TDBGridEh
        Left = 0
        Top = 0
        Width = 648
        Height = 285
        Align = alClient
        DataSource = DataSource3
        DynProps = <>
        Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghAutoSortMarking, dghDialogFind, dghExtendVertLines]
        RowDetailPanel.Height = 250
        SortLocal = True
        STFilter.Local = True
        STFilter.Location = stflInTitleFilterEh
        STFilter.Visible = True
        TabOrder = 0
        OnDblClick = DBGridEh3DblClick
        object RowDetailData: TRowDetailPanelControlEh
          object DBEditEh2: TDBEditEh
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
            Text = 'edt_PPComment'
            Visible = False
          end
        end
      end
    end
    object ts_ToDel: TTabSheet
      Caption = #1053#1072' '#1091#1076#1072#1083#1077#1085#1080#1077
      ImageIndex = 3
      object DBGridEh4: TDBGridEh
        Left = 0
        Top = 0
        Width = 648
        Height = 285
        Align = alClient
        DataSource = DataSource4
        DynProps = <>
        Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
        RowDetailPanel.Height = 250
        TabOrder = 0
        OnDblClick = DBGridEh4DblClick
        OnKeyDown = DBGridEh4KeyDown
        object RowDetailData: TRowDetailPanelControlEh
          object DBEditEh3: TDBEditEh
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
            PopupMenu = Pm_3
            TabOrder = 0
            Text = 'edt_PPComment'
            Visible = False
          end
        end
      end
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 4
    Top = 132
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
    Left = 80
    Top = 137
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
    Left = 80
    Top = 197
  end
  object DataSource2: TDataSource
    DataSet = MemTableEh2
    Left = 177
    Top = 201
  end
  object MemTableEh2: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh2
    Left = 253
    Top = 205
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 161
    Top = 133
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh1
    Left = 253
    Top = 137
  end
  object ADODataDriverEh3: TADODataDriverEh
    ADOConnection = myDBOra.AdoConnection
    DynaSQLParams.SkipUnchangedFields = True
    DynaSQLParams.Options = []
    MacroVars.Macros = <>
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    Left = 68
    Top = 249
  end
  object DataSource3: TDataSource
    DataSet = MemTableEh3
    Left = 165
    Top = 257
  end
  object MemTableEh3: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh3
    Left = 241
    Top = 257
  end
  object ADODataDriverEh4: TADODataDriverEh
    ADOConnection = myDBOra.AdoConnection
    DynaSQLParams.SkipUnchangedFields = True
    DynaSQLParams.Options = []
    MacroVars.Macros = <>
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    Left = 64
    Top = 313
  end
  object DataSource4: TDataSource
    DataSet = MemTableEh4
    Left = 161
    Top = 317
  end
  object MemTableEh4: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh4
    Left = 237
    Top = 321
  end
  object Pm_3: TPopupMenu
    Left = 308
    Top = 257
  end
end
