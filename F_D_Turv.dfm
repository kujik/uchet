inherited Dlg_TURV: TDlg_TURV
  Caption = 'Dlg_TURV'
  ClientHeight = 578
  ClientWidth = 1526
  ExplicitWidth = 1538
  ExplicitHeight = 616
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 559
    Width = 1526
    ExplicitTop = 558
    ExplicitWidth = 1522
    inherited lbl_StatusBar_Right: TLabel
      Left = 1439
      Height = 17
    end
    inherited lbl_StatusBar_Left: TLabel
      Height = 17
    end
  end
  object pnl1: TPanel [1]
    Left = 0
    Top = 0
    Width = 1526
    Height = 43
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 1522
    object pnl_Left: TPanel
      Left = 0
      Top = 0
      Width = 217
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
    end
    object pnl_Center: TPanel
      Left = 217
      Top = 0
      Width = 1269
      Height = 43
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitWidth = 1265
      object lbl_Division: TLabel
        Left = 6
        Top = 4
        Width = 53
        Height = 13
        Caption = 'lbl_Division'
      end
      object lbl_Worker: TLabel
        Left = 6
        Top = 23
        Width = 1243
        Height = 13
        AutoSize = False
        Caption = 'lbl_Worker'
      end
    end
    object pnl_Right: TPanel
      Left = 1486
      Top = 0
      Width = 40
      Height = 43
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 2
      ExplicitLeft = 1482
      DesignSize = (
        40
        43)
      object Img_Info: TImage
        Left = 6
        Top = 0
        Width = 23
        Height = 25
        Anchors = [akLeft, akBottom]
      end
    end
  end
  object DBGridEh1: TDBGridEh [2]
    Left = 0
    Top = 43
    Width = 1526
    Height = 516
    Align = alClient
    AllowedOperations = [alopUpdateEh]
    DataSource = DataSource1
    DynProps = <>
    RowDetailPanel.Active = True
    RowDetailPanel.Width = 500
    RowDetailPanel.Height = 500
    TabOrder = 2
    OnAdvDrawDataCell = DBGridEh1AdvDrawDataCell
    OnCellClick = DBGridEh1CellClick
    OnCellMouseClick = DBGridEh1CellMouseClick
    OnColEnter = DBGridEh1ColEnter
    OnDataHintShow = DBGridEh1DataHintShow
    OnKeyPress = DBGridEh1KeyPress
    OnMouseMove = DBGridEh1MouseMove
    OnHintShowPause = DBGridEh1HintShowPause
    OnRowDetailPanelHide = DBGridEh1RowDetailPanelHide
    OnRowDetailPanelShow = DBGridEh1RowDetailPanelShow
    Columns = <
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'pos'
        Footers = <>
      end
      item
        Alignment = taLeftJustify
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'name'
        Footers = <>
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'job'
        Footers = <>
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'category'
        Footers = <>
      end>
    object RowDetailData: TRowDetailPanelControlEh
      object lbl_Title_Worker: TLabel
        Left = 8
        Top = 8
        Width = 77
        Height = 13
        Caption = 'lbl_Title_Worker'
      end
      object lbl2: TLabel
        Left = 17
        Top = 414
        Width = 120
        Height = 13
        Caption = #1059#1095#1077#1090' '#1088#1072#1073#1086#1095#1077#1075#1086' '#1074#1088#1077#1084#1077#1085#1080
        Visible = False
      end
      object lbl_Comment: TLabel
        Left = 229
        Top = 8
        Width = 44
        Height = 13
        Caption = 'Comment'
      end
      object lbl_Premium: TLabel
        Left = 340
        Top = 8
        Width = 40
        Height = 13
        Caption = 'Premium'
      end
      object DBGridEh2: TDBGridEh
        Left = 8
        Top = 31
        Width = 185
        Height = 134
        DataSource = DataSource2
        DynProps = <>
        TabOrder = 0
        OnAdvDrawDataCell = DBGridEh2AdvDrawDataCell
        OnCellClick = DBGridEh2CellClick
        OnCellMouseClick = DBGridEh2CellMouseClick
        OnColEnter = DBGridEh2ColEnter
        OnDblClick = DBGridEh2DblClick
        OnDataHintShow = DBGridEh2DataHintShow
        Columns = <
          item
            CellButtons = <>
            DynProps = <>
            EditButtons = <>
            FieldName = 'value'
            Footers = <>
          end>
        object RowDetailData: TRowDetailPanelControlEh
        end
      end
      object Bt_Comment: TBitBtn
        Left = 201
        Top = 3
        Width = 22
        Height = 25
        Caption = 'K'
        TabOrder = 1
        OnClick = Bt_CommentClick
      end
      object Bt_Premium: TBitBtn
        Left = 312
        Top = 3
        Width = 22
        Height = 25
        Caption = #1055
        TabOrder = 2
        OnClick = Bt_PremiumClick
      end
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 792
    Top = 472
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    AfterScroll = MemTableEh1AfterScroll
    Left = 824
    Top = 96
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 864
    Top = 96
  end
  object DataSource2: TDataSource
    DataSet = MemTableEh2
    Left = 864
    Top = 152
  end
  object MemTableEh2: TMemTableEh
    Params = <>
    AfterEdit = MemTableEh2AfterEdit
    AfterScroll = MemTableEh2AfterScroll
    Left = 824
    Top = 152
  end
  object MemTableEh3: TMemTableEh
    Params = <>
    Left = 824
    Top = 208
  end
  object DataSource3: TDataSource
    DataSet = MemTableEh3
    Left = 864
    Top = 208
  end
  object Timer_AfterUpdate: TTimer
    Enabled = False
    Interval = 5
    OnTimer = Timer_AfterUpdateTimer
    Left = 876
    Top = 471
  end
  object PM_2: TPopupMenu
    AutoPopup = False
    Left = 860
    Top = 258
    object N_Comment: TMenuItem
      Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
      OnClick = N_CommentClick
    end
    object N_Premium: TMenuItem
      Caption = #1055#1088#1077#1084#1080#1103
      OnClick = N_PremiumClick
    end
    object N_Penalty: TMenuItem
      Caption = #1064#1090#1088#1072#1092
      OnClick = N_PenaltyClick
    end
    object N_Night: TMenuItem
      Caption = #1053#1086#1095#1085#1072#1103' '#1089#1084#1077#1085#1072
      OnClick = N_NightClick
    end
  end
  object PM_1: TPopupMenu
    AutoPopup = False
    Left = 819
    Top = 260
    object N_Komment_1: TMenuItem
      Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
      OnClick = N_Komment_1Click
    end
    object N_Premium_1: TMenuItem
      Caption = #1055#1088#1077#1084#1080#1103
      OnClick = N_Premium_1Click
    end
    object N_Penelty_1: TMenuItem
      Caption = #1064#1090#1088#1072#1092
      OnClick = N_Penelty_1Click
    end
  end
end
