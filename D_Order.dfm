inherited Dlg_Order: TDlg_Order
  Caption = 'Dlg_Order'
  ClientHeight = 672
  ClientWidth = 1272
  OnCloseQuery = FormCloseQuery
  OnResize = FormResize
  ExplicitWidth = 1284
  ExplicitHeight = 710
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 628
    Width = 1272
    TabOrder = 4
    ExplicitTop = 627
    ExplicitWidth = 1268
    inherited lbl_StatusBar_Right: TLabel
      Left = 1185
      Height = 17
      ExplicitLeft = 1185
    end
    inherited lbl_StatusBar_Left: TLabel
      Height = 17
    end
  end
  object pnl_Top: TPanel [1]
    Left = 0
    Top = 0
    Width = 1272
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 1268
    object lbl_ITM: TLabel
      Left = 228
      Top = 7
      Width = 54
      Height = 29
      Caption = #1048#1058#1052
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHotLight
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lbl_ItmStatus: TLabel
      Left = 288
      Top = 14
      Width = 60
      Height = 13
      Caption = 'lbl_ItmStatus'
    end
    object Bt_Ok: TBitBtn
      Left = 8
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Bt_Ok'
      TabOrder = 0
      OnClick = Bt_OkClick
    end
    object Bt_Cancel: TBitBtn
      Left = 104
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Bt_Cancel'
      TabOrder = 1
      OnClick = Bt_CancelClick
    end
    object pnl_Top_1: TPanel
      Left = 667
      Top = 1
      Width = 604
      Height = 39
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 4
      ExplicitLeft = 663
      DesignSize = (
        604
        39)
      object edt_TemplateName: TDBEditEh
        Left = 145
        Top = 14
        Width = 452
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        ControlLabel.Width = 123
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1096#1072#1073#1083#1086#1085#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 0
        Visible = True
      end
    end
    object BitBtn1: TBitBtn
      Left = 493
      Top = 10
      Width = 75
      Height = 25
      Caption = 'BitBtn1'
      TabOrder = 3
      Visible = False
      OnClick = BitBtn1Click
    end
    object Bt_CreateXLS: TBitBtn
      Left = 200
      Top = 10
      Width = 22
      Height = 25
      Caption = 'Bt_CreateXLS'
      TabOrder = 2
      OnClick = Bt_CreateXLSClick
    end
  end
  object pnl_Bottom: TPanel [2]
    Left = 0
    Top = 647
    Width = 1272
    Height = 25
    Align = alBottom
    TabOrder = 3
    Visible = False
    ExplicitTop = 646
    ExplicitWidth = 1268
    object lbl_OrderSaveStatus: TLabel
      Left = 8
      Top = 6
      Width = 97
      Height = 13
      Caption = 'lbl_OrderSaveStatus'
    end
    object chb_ViewEmptyItems: TCheckBox
      Left = 113
      Top = 4
      Width = 200
      Height = 17
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1089' '#1085#1091#1083#1077#1074#1099#1084' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086#1084
      TabOrder = 0
      OnClick = chb_ViewEmptyItemsClick
    end
  end
  object pnl_Center: TPanel [3]
    Left = 0
    Top = 309
    Width = 1272
    Height = 319
    Align = alClient
    TabOrder = 2
    ExplicitWidth = 1268
    ExplicitHeight = 318
    object DBGridEh1: TDBGridEh
      Left = 1
      Top = 1
      Width = 1270
      Height = 317
      Align = alClient
      DataSource = DataSource1
      DynProps = <>
      PopupMenu = PopupMenu1
      TabOrder = 0
      OnColEnter = DBGridEh1ColEnter
      OnEnter = DBGridEh1Enter
      OnExit = DBGridEh1Exit
      OnGetCellParams = DBGridEh1GetCellParams
      OnKeyDown = DBGridEh1KeyDown
      object RowDetailData: TRowDetailPanelControlEh
      end
    end
  end
  object pnl_Header: TPanel [4]
    Left = 0
    Top = 41
    Width = 1272
    Height = 268
    Align = alTop
    TabOrder = 1
    OnClick = pnl_HeaderClick
    object pnl_Header_3: TPanel
      Left = 691
      Top = 1
      Width = 193
      Height = 176
      Align = alRight
      TabOrder = 0
      ExplicitLeft = 687
      object dedt_Beg: TDBDateTimeEditEh
        Left = 72
        Top = 9
        Width = 115
        Height = 21
        ControlLabel.Width = 64
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072#13#10#1086#1092#1086#1088#1084#1083#1077#1085#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 0
        Visible = True
      end
      object dedt_Otgr: TDBDateTimeEditEh
        Left = 72
        Top = 63
        Width = 115
        Height = 21
        ControlLabel.Width = 66
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072'            '#13#10#1086#1090#1075#1088#1091#1079#1082#1080'       '
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 2
        Visible = True
      end
      object dedt_Change: TDBDateTimeEditEh
        Left = 72
        Top = 36
        Width = 115
        Height = 21
        ControlLabel.Width = 65
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072#13#10#1080#1079#1084#1077#1085#1077#1085#1080#1103'   '
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        Enabled = False
        EditButton.Visible = False
        EditButtons = <>
        Kind = dtkDateTimeEh
        TabOrder = 1
        Visible = True
      end
      object dedt_MontageBeg: TDBDateTimeEditEh
        Left = 72
        Top = 90
        Width = 115
        Height = 21
        ControlLabel.Width = 66
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072' '#1085#1072#1095#1072#1083#1072#13#10#1084#1086#1085#1090#1072#1078#1072'       '
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 3
        Visible = True
      end
      object dedt_MontageEnd: TDBDateTimeEditEh
        Left = 72
        Top = 117
        Width = 115
        Height = 21
        ControlLabel.Width = 66
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072' '#1086#1082#1086#1085#1095'.'#13#10#1084#1086#1085#1090#1072#1078#1072'       '
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 4
        Visible = True
      end
    end
    object pnl_Header_Bottom: TPanel
      Left = 1
      Top = 177
      Width = 1270
      Height = 90
      Align = alBottom
      TabOrder = 1
      ExplicitWidth = 1266
      object pnl_Header_11: TPanel
        Left = 1
        Top = 1
        Width = 689
        Height = 88
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 685
        DesignSize = (
          689
          88)
        object mem_Comment: TDBMemoEh
          Left = 64
          Top = 32
          Width = 615
          Height = 53
          ControlLabel.Width = 63
          ControlLabel.Height = 13
          ControlLabel.Caption = #1044#1086#1087#1086#1083#1085#1077#1085#1080#1077
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          DynProps = <>
          EditButtons = <>
          MaxLength = 4000
          TabOrder = 1
          Visible = True
          WantReturns = True
          OnKeyDown = mem_CommentKeyDown
          ExplicitWidth = 611
        end
        object edt_Complaints: TDBEditEh
          Left = 65
          Top = 5
          Width = 614
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ControlLabel.Width = 62
          ControlLabel.Height = 26
          ControlLabel.Caption = #1055#1088#1080#1095#1080#1085#1099#13#10#1088#1077#1082#1083#1072#1084#1072#1094#1080#1080
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <
            item
              DropDownFormParams.Align = daRight
            end>
          MaxLength = 400
          TabOrder = 0
          Visible = True
          OnCloseDropDownForm = edt_ComplaintsCloseDropDownForm
          OnOpenDropDownForm = edt_ComplaintsOpenDropDownForm
          ExplicitWidth = 610
        end
        object nedt_Attention: TDBNumberEditEh
          Left = 240
          Top = 52
          Width = 29
          Height = 21
          ControlLabel.Caption = #1044#1086#1087#1086#1083#1085#1077#1085#1080#1077
          DynProps = <>
          EditButtons = <>
          TabOrder = 2
          Visible = False
        end
      end
      object pnl_Header_12: TPanel
        Left = 690
        Top = 1
        Width = 579
        Height = 88
        Align = alRight
        TabOrder = 1
        ExplicitLeft = 686
        DesignSize = (
          579
          88)
        object lbl_Files: TLabel
          Left = 6
          Top = 33
          Width = 56
          Height = 26
          Caption = #1042#1085#1077#1096#1085#1080#1077#13#10#1076#1086#1082#1091#1084#1077#1085#1090#1099
        end
        object DBGridEh2: TDBGridEh
          Left = 76
          Top = 6
          Width = 495
          Height = 79
          Anchors = [akLeft, akTop, akRight]
          DataSource = DataSource2
          DynProps = <>
          PopupMenu = Pm_Files
          TabOrder = 0
          OnDblClick = DBGridEh2DblClick
          OnGetCellParams = DBGridEh2GetCellParams
          object RowDetailData: TRowDetailPanelControlEh
          end
        end
      end
    end
    object pnl_Header_2: TPanel
      Left = 341
      Top = 1
      Width = 350
      Height = 176
      Align = alClient
      TabOrder = 2
      ExplicitWidth = 346
      DesignSize = (
        350
        176)
      object cmb_CustomerName: TDBComboBoxEh
        Left = 86
        Top = 11
        Width = 258
        Height = 21
        ControlLabel.Width = 48
        ControlLabel.Height = 13
        ControlLabel.Caption = #1047#1072#1082#1072#1079#1095#1080#1082
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 0
        Visible = True
        OnGetItemImageIndex = cmb_CustomerNameGetItemImageIndex
        ExplicitWidth = 254
      end
      object cmb_CustomerMan: TDBComboBoxEh
        Left = 86
        Top = 38
        Width = 258
        Height = 21
        ControlLabel.Width = 59
        ControlLabel.Height = 26
        ControlLabel.Caption = #1050#1086#1085#1090#1072#1082#1090#1085#1086#1077#13#10#1083#1080#1094#1086
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 1
        Visible = True
        OnGetItemImageIndex = cmb_CustomerManGetItemImageIndex
        ExplicitWidth = 254
      end
      object edt_CustomerContacts: TDBEditEh
        Left = 86
        Top = 65
        Width = 258
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 49
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1085#1090#1072#1082#1090#1099
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 2
        Visible = True
        ExplicitWidth = 254
      end
      object cmb_CustomerLegalName: TDBComboBoxEh
        Left = 86
        Top = 92
        Width = 182
        Height = 21
        ControlLabel.Width = 74
        ControlLabel.Height = 26
        ControlLabel.Caption = #1070#1088#1080#1076#1080#1095#1077#1089#1082#1086#1077#13#10#1085#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 3
        Visible = True
        OnGetItemImageIndex = cmb_CustomerLegalNameGetItemImageIndex
        ExplicitWidth = 178
      end
      object edt_CustomerINN: TDBEditEh
        Left = 265
        Top = 92
        Width = 79
        Height = 21
        Anchors = [akTop, akRight]
        ControlLabel.Caption = #1048#1053#1053
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 12
        TabOrder = 4
        Text = '123456789023'
        Visible = True
        ExplicitLeft = 261
      end
      object edt_Account: TDBEditEh
        Left = 232
        Top = 118
        Width = 112
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 34
        ControlLabel.Height = 26
        ControlLabel.Caption = #1053#1086#1084#1077#1088#13#10#1089#1095#1077#1090#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 6
        Visible = True
        ExplicitWidth = 108
      end
      object cmb_CashType: TDBComboBoxEh
        Left = 88
        Top = 119
        Width = 105
        Height = 21
        ControlLabel.Width = 59
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1080#1076' '#1086#1087#1083#1072#1090#1099
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 5
        Text = #1073'/'#1085' ('#1085#1077#1090' '#1089#1095#1077#1090#1072')'
        Visible = True
      end
      object edt_Address: TDBEditEh
        Left = 88
        Top = 145
        Width = 256
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 45
        ControlLabel.Height = 26
        ControlLabel.Caption = #1040#1076#1088#1077#1089#13#10#1086#1090#1075#1088#1091#1079#1082#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 7
        Visible = True
        ExplicitWidth = 252
      end
    end
    object pnl_Header_1: TPanel
      Left = 1
      Top = 1
      Width = 340
      Height = 176
      Align = alLeft
      TabOrder = 3
      DesignSize = (
        340
        176)
      object cmb_Organization: TDBComboBoxEh
        Left = 66
        Top = 11
        Width = 156
        Height = 21
        ControlLabel.Width = 47
        ControlLabel.Height = 13
        ControlLabel.Caption = #1070#1088'. '#1051#1080#1094#1086
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Visible = True
      end
      object edt_OrderNum: TDBEditEh
        Left = 65
        Top = 38
        Width = 89
        Height = 21
        ControlLabel.Width = 31
        ControlLabel.Height = 13
        ControlLabel.Caption = #1047#1072#1082#1072#1079
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Enabled = False
        TabOrder = 2
        Visible = True
      end
      object cmb_OrderType: TDBComboBoxEh
        Left = 136
        Top = 38
        Width = 108
        Height = 21
        ControlLabel.Caption = #1042#1080#1076' '#1079#1072#1082#1072#1079#1072
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <
          item
            Style = ebsEllipsisEh
            OnClick = cmb_OrderTypeEditButtons0Click
          end>
        TabOrder = 3
        Visible = True
      end
      object cmb_Format: TDBComboBoxEh
        Left = 65
        Top = 65
        Width = 269
        Height = 21
        ControlLabel.Width = 47
        ControlLabel.Height = 26
        ControlLabel.Caption = #1060#1086#1088#1084#1072#1090#13#10#1087#1072#1089#1087#1086#1088#1090#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 5
        Visible = True
      end
      object cmb_Project: TDBComboBoxEh
        Left = 65
        Top = 92
        Width = 269
        Height = 21
        ControlLabel.Width = 37
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1088#1086#1077#1082#1090
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        PopupMenu = Pm_Format
        TabOrder = 6
        Visible = True
      end
      object edt_Manager: TDBEditEh
        Left = 66
        Top = 146
        Width = 268
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 53
        ControlLabel.Height = 13
        ControlLabel.Caption = #1052#1077#1085#1077#1076#1078#1077#1088
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 8
        Text = #1055#1088#1086#1082#1086#1087#1077#1085#1082#1086' '#1057'.'#1042'.'
        Visible = True
      end
      object cmb_EstimatePath: TDBComboBoxEh
        Left = 65
        Top = 119
        Width = 269
        Height = 21
        ControlLabel.Width = 34
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1084#1077#1090#1099
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        LimitTextToListValues = True
        TabOrder = 7
        Visible = True
      end
      object cmb_OrderReference: TDBComboBoxEh
        Left = 241
        Top = 38
        Width = 93
        Height = 21
        ControlLabel.Caption = #1056#1077#1082#1083#1072#1084#1072#1094#1080#1103' '#1085#1072
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akTop, akRight]
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 4
        Visible = True
      end
      object cmb_Area: TDBComboBoxEh
        Left = 280
        Top = 11
        Width = 54
        Height = 21
        ControlLabel.Width = 53
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1083#1086#1097#1072#1076#1082#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
      end
    end
    object pnl_Header_5: TPanel
      Left = 884
      Top = 1
      Width = 387
      Height = 176
      Align = alRight
      TabOrder = 4
      ExplicitLeft = 880
      object lbl1: TLabel
        Left = 64
        Top = 12
        Width = 94
        Height = 13
        Caption = #1057#1091#1084#1084#1072' '#1073#1077#1079' '#1089#1082#1080#1076#1082#1080
      end
      object lbl2: TLabel
        Left = 172
        Top = 12
        Width = 44
        Height = 13
        Caption = #1053#1072#1094#1077#1085#1082#1072
      end
      object lbl3: TLabel
        Left = 229
        Top = 12
        Width = 37
        Height = 13
        Caption = #1057#1082#1080#1076#1082#1072
      end
      object lbl4: TLabel
        Left = 285
        Top = 12
        Width = 30
        Height = 13
        Caption = #1048#1090#1086#1075#1086
      end
      object nedt_Trans_0: TDBNumberEditEh
        Left = 64
        Top = 117
        Width = 95
        Height = 21
        ControlLabel.Width = 55
        ControlLabel.Height = 26
        ControlLabel.Caption = #1057#1090#1086#1080#1084#1086#1089#1090#1100#13#10#1076#1086#1089#1090#1072#1074#1082#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        EditButton.DefaultAction = True
        EditButton.Visible = True
        EditButtons = <>
        TabOrder = 12
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Montage_0: TDBNumberEditEh
        Left = 64
        Top = 90
        Width = 95
        Height = 21
        ControlLabel.Width = 55
        ControlLabel.Height = 26
        ControlLabel.Caption = #1057#1090#1086#1080#1084#1086#1089#1090#1100#13#10#1084#1086#1085#1090#1072#1078#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        EditButton.DefaultAction = True
        EditButton.Visible = True
        EditButtons = <>
        TabOrder = 8
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Sum: TDBNumberEditEh
        Left = 64
        Top = 144
        Width = 89
        Height = 21
        ControlLabel.Width = 30
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1090#1086#1075#1086
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 16
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_AC_0: TDBNumberEditEh
        Left = 64
        Top = 63
        Width = 95
        Height = 21
        ControlLabel.Width = 35
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1086#1087'.'#13#10#1082#1086#1084#1087#1083'.'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 4
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Items_0: TDBNumberEditEh
        Left = 64
        Top = 36
        Width = 95
        Height = 21
        ControlLabel.Width = 44
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1079#1076#1077#1083#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 0
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Items_M: TDBNumberEditEh
        Left = 172
        Top = 36
        Width = 41
        Height = 21
        ControlLabel.Width = 6
        ControlLabel.Height = 13
        ControlLabel.Caption = '+'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 500.000000000000000000
        TabOrder = 1
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Items_D: TDBNumberEditEh
        Left = 228
        Top = 36
        Width = 41
        Height = 21
        ControlLabel.Width = 3
        ControlLabel.Height = 13
        ControlLabel.Caption = '-'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 100.000000000000000000
        TabOrder = 2
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Items: TDBNumberEditEh
        Left = 284
        Top = 36
        Width = 95
        Height = 21
        ControlLabel.Width = 6
        ControlLabel.Height = 13
        ControlLabel.Caption = '='
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 3
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_AC_M: TDBNumberEditEh
        Left = 172
        Top = 63
        Width = 41
        Height = 21
        ControlLabel.Width = 6
        ControlLabel.Height = 13
        ControlLabel.Caption = '+'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 500.000000000000000000
        TabOrder = 5
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_AC_D: TDBNumberEditEh
        Left = 229
        Top = 63
        Width = 41
        Height = 21
        ControlLabel.Width = 3
        ControlLabel.Height = 13
        ControlLabel.Caption = '-'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 100.000000000000000000
        TabOrder = 6
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_AC: TDBNumberEditEh
        Left = 284
        Top = 63
        Width = 95
        Height = 21
        ControlLabel.Width = 6
        ControlLabel.Height = 13
        ControlLabel.Caption = '='
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 7
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Montage_M: TDBNumberEditEh
        Left = 172
        Top = 90
        Width = 41
        Height = 21
        ControlLabel.Width = 6
        ControlLabel.Height = 13
        ControlLabel.Caption = '+'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 500.000000000000000000
        TabOrder = 9
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Montage_D: TDBNumberEditEh
        Left = 228
        Top = 90
        Width = 41
        Height = 21
        ControlLabel.Width = 3
        ControlLabel.Height = 13
        ControlLabel.Caption = '-'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 100.000000000000000000
        TabOrder = 10
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Montage: TDBNumberEditEh
        Left = 284
        Top = 90
        Width = 95
        Height = 21
        ControlLabel.Width = 6
        ControlLabel.Height = 13
        ControlLabel.Caption = '='
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 11
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Trans_M: TDBNumberEditEh
        Left = 172
        Top = 117
        Width = 41
        Height = 21
        ControlLabel.Width = 6
        ControlLabel.Height = 13
        ControlLabel.Caption = '+'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 500.000000000000000000
        TabOrder = 13
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Trans_D: TDBNumberEditEh
        Left = 228
        Top = 117
        Width = 41
        Height = 21
        ControlLabel.Width = 3
        ControlLabel.Height = 13
        ControlLabel.Caption = '-'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 100.000000000000000000
        TabOrder = 14
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Trans: TDBNumberEditEh
        Left = 284
        Top = 117
        Width = 95
        Height = 21
        ControlLabel.Width = 6
        ControlLabel.Height = 13
        ControlLabel.Caption = '='
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 15
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Discount: TDBNumberEditEh
        Left = -28
        Top = 156
        Width = 77
        Height = 21
        ControlLabel.Width = 9
        ControlLabel.Height = 13
        ControlLabel.Caption = '+-'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 17
        Value = 12235123.050000000000000000
        Visible = False
      end
      object nedt_SumWoNds: TDBNumberEditEh
        Left = 185
        Top = 144
        Width = 80
        Height = 21
        ControlLabel.Width = 24
        ControlLabel.Height = 26
        ControlLabel.Caption = #1041#1077#1079#13#10#1053#1044#1057
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 18
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Sum_Av: TDBNumberEditEh
        Left = 300
        Top = 144
        Width = 77
        Height = 21
        ControlLabel.Width = 31
        ControlLabel.Height = 13
        ControlLabel.Caption = #1040#1074#1072#1085#1089
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 19
        Value = 12235123.050000000000000000
        Visible = True
      end
      object nedt_Items_NoSgp: TDBNumberEditEh
        Left = 60
        Top = 167
        Width = 77
        Height = 21
        ControlLabel.Width = 91
        ControlLabel.Height = 13
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        Enabled = False
        EditButton.DefaultAction = True
        EditButtons = <>
        TabOrder = 20
        Value = 0.000000000000000000
        Visible = False
      end
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 300
    Top = 548
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 161
    Top = 742
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    AfterEdit = MemTableEh1AfterEdit
    AfterScroll = MemTableEh1AfterScroll
    Left = 41
    Top = 735
  end
  object Il_Item_Status: TImageList
    Left = 416
    Top = 549
    Bitmap = {
      494C010103001400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFD7AB7E00C88C4F00C88C5000D7AB7F00FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF9F6C8D00986AB1008F67E0008F67E0008F67E0008F67E0009E6C9400B48E
      A600FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFA29BF3004336E7004234E6009E97F100FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFCA8E5100F0BC8500FDCC9800FDCC9800FDCC9800FDCC9800F0BC8500CA8E
      5100FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF9F6C
      8D008F67E0008F67E0009978ED009978ED009978ED009978ED008F67E0008F67
      E0009F6C8D00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF4F43EA004032EB003D2FEA003B2CE9003829E8003627E7003424E6004031
      E400FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9D1BA00F1BD
      8600FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800F0BC8600E9D3BB00FFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFF9F6C8D008F67
      E0009978ED009978ED009978ED009978ED009978ED009978ED009978ED009978
      ED008F67E0009F6C8D00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF473A
      ED004537EC004235EB004032EB003D2FEA003B2CE9003829E8003627E7003424
      E6003121E500FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1BE8700FDCC
      9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800FDCC9800F0BC8600FFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF9F6C8D008F67E0009978
      ED009F6C8D009F6C8D009978ED009978ED009978ED009978ED009F6C8D009E6E
      97009978ED008F67E000B48EA600FFFFFFFFFFFFFFFFFFFFFFFF574BED004A3D
      EE00473AED004537EC004235EB004032EB003D2FEA003B2CE9003829E8003627
      E7003424E6003E30E500FFFFFFFFFFFFFFFFFFFFFFFFC98E5000FDCC9800FDCC
      9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800FDCC9800FDCC9800CA8E5100FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF8F67DF00936DE5009978
      ED009F6C8D00DEEFFA009F6C8D009978ED009978ED009F6C8D00E6F2FC009F6C
      8D009978ED008F67E0009E6C9400FFFFFFFFFFFFFFFFFFFFFFFF4E41EF004C3F
      EF004A3DEE00473AED004537EC004235EB004032EB003D2FEA003B2CE9003829
      E8003627E7003424E600FFFFFFFFFFFFFFFFFFFFFFFFF0BC8500FDCC9800FDCC
      9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800FDCC9800FDCC9800EFBB8400FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF8F67E0009978ED009C73
      C5009978ED009F6C8D00DEEFFA009F6C8D009F6C8D00E6F2FC009F6C8D009978
      ED009978ED009978ED008F67E000FFFFFFFFFFFFFFFFABA4F6005043F0004E41
      EF004C3FEF004A3DEE00473AED004537EC004235EB004032EB003D2FEA003B2C
      E9003829E8003627E7009E97F100FFFFFFFFD8AA7E00FDCC9800FDCC9800FDCC
      9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800FDCC9800FDCC9800FDCC9800D7AB7F000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000AE85A0008F67E0009978ED009978
      ED009978ED009978ED009F6C8D00DEEFFA00E6F2FC009F6C8D009978ED009978
      ED009978ED009978ED008F67E000FFFFFFFFFFFFFFFF5C53F1005245F1005043
      F000D3D1F500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CFCC
      F4003B2CE9003829E8004436E700FFFFFFFFC88C5000FDCC9800FDCC9800FDCC
      9800FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FDCC9800FDCC9800FDCC9800C88E50000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A77A97008F67E0009978ED009978
      ED009978ED009978ED009F6C8D00E6F2FC00F0F7FF009F6C8D009A76D7009978
      ED009978ED009978ED008F67E000FFFFFFFFFFFFFFFF5F55F1005348F2005245
      F100D5D3F600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D0CE
      F4003D2FEA003B2CE9004638E700FFFFFFFFC88C5000FDCC9800FDCC9800FDCC
      9800FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FDCC9800FDCC9800FDCC9800C88E50000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF8F67E0009978ED009978
      ED009978ED009F6C8D00E6F2FC009F6C8D009F6C8D00F0F7FF009F6C8D009978
      ED009B73C5009978ED008F67E000FFFFFFFFFFFFFFFFADA7F700554AF2005348
      F2005245F1005043F0004E41EF004C3FEF004A3DEE00473AED004537EC004235
      EB004032EB003D2FEA00A29BF300FFFFFFFFD8AC7E00FDCC9800FDCC9800FDCC
      9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800FDCC9800FDCC9800FDCC9800D7AB7F000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF8F67E0009875EB009978
      ED009F6C8D00E6F2FC009F6C8D009978ED009978ED009F6C8D00F0F7FF009F6C
      8D009978ED008F67E000996AB000FFFFFFFFFFFFFFFFFFFFFFFF574CF300554A
      F2005348F2005245F1005043F0004E41EF004C3FEF004A3DEE00473AED004537
      EC004235EB004032EB00FFFFFFFFFFFFFFFFFFFFFFFFF0BC8600FDCC9800FDCC
      9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800FDCC9800FDCC9800F0BC8500FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFF9F6C8D008F67E0009978
      ED009F6C8D009F6C8D009978ED009978ED009978ED009978ED009F6C8D009F6C
      8D009978ED008F67E0009F6C8D00FFFFFFFFFFFFFFFFFFFFFFFF635AF200574C
      F300554AF2005348F2005245F1005043F0004E41EF004C3FEF004A3DEE00473A
      ED004537EC004D41E800FFFFFFFFFFFFFFFFFFFFFFFFC98E5000FDCC9800FDCC
      9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800FDCC9800FDCC9800CA8E5100FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFF9A6BA4008F67
      E0009978ED009978ED009978ED009978ED009978ED009978ED009978ED009978
      ED008F67E0009F6C8D00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF594E
      F400574CF300554AF2005348F2005245F1005043F0004E41EF004C3FEF004A3D
      EE00473AED00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2BE8700FDCC
      9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800FDCC9800F1BD8600FFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF9A6B
      A4008F67E0009774EB009978ED009978ED009978ED009978ED00926DE4008F67
      E0009F6C8D00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF6358F200574CF300554AF2005348F2005245F1005043F0004E41EF00574B
      ED00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9D1B900F2BE
      8700FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC9800FDCC
      9800F1BE8700E9D1BA00FFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF9F6C8D008F67E0008F67E0008F67E0008F67E0008F67E0008F67DF009F6C
      8D00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFADA7F7005E53F0005D52F000ABA4F600FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFC98E5000F0BD8500FDCC9800FDCC9800FDCC9800FDCC9800F0BC8500C98E
      5000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFA77A9700AE85A000FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFD8AA7E00C88D4D00C88D4D00D8AA7E00FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object PopupMenu1: TPopupMenu
    Left = 236
    Top = 549
    object Pmi1_DeleteRow: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1089#1090#1088#1086#1082#1091
      OnClick = Pmi1_DeleteRowClick
    end
    object Pmi_RecalcPrices: TMenuItem
      Caption = #1055#1077#1088#1077#1089#1095#1080#1090#1072#1090#1100' '#1094#1077#1085#1099
      OnClick = Pmi_RecalcPricesClick
    end
    object Pmi1_ShowColumns: TMenuItem
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1089#1083#1091#1078#1077#1073#1085#1099#1077
      OnClick = Pmi1_ShowColumnsClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Pmi1_LoadKB: TMenuItem
      Caption = #1055#1072#1089#1087#1086#1088#1090' '#1050#1041' '#1080#1079' '#1092#1072#1081#1083#1072
    end
  end
  object DataSource2: TDataSource
    DataSet = MemTableEh2
    Left = 73
    Top = 549
  end
  object MemTableEh2: TMemTableEh
    Params = <>
    AfterEdit = MemTableEh1AfterEdit
    AfterScroll = MemTableEh1AfterScroll
    Left = 17
    Top = 549
  end
  object Pm_Files: TPopupMenu
    Left = 1032
    Top = 255
  end
  object OpenDialog1: TOpenDialog
    Left = 944
    Top = 251
  end
  object Pm_Format: TPopupMenu
    Left = 440
    Top = 5
    object Pmi_Format_LoadKB: TMenuItem
      Caption = #1048#1084#1087#1086#1088#1090' '#1087#1072#1089#1087#1086#1088#1090#1072' '#1050#1041
      OnClick = Pmi_Format_LoadKBClick
    end
    object Pmi_Format_LoadKBLog: TMenuItem
      Caption = #1051#1086#1075' '#1080#1084#1087#1086#1088#1090#1072' '#1050#1041
      OnClick = Pmi_Format_LoadKBLogClick
    end
  end
  object Il_ItemsTypes: TImageList
    Width = 3
    Left = 568
    Top = 549
  end
  object Il_Columns: TImageList
    Width = 3
    Left = 496
    Top = 549
    Bitmap = {
      494C01010200CC00040003001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      00000000000036000000280000000C0000001000000001002000000000000003
      00000000000000000000000000000000000032CD320032CD320032CD3200FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      000032CD320032CD320032CD3200FF000000FF000000FF000000000000000000
      00000000000000000000000000000000000032CD320032CD320032CD3200FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      000032CD320032CD320032CD3200FF000000FF000000FF000000000000000000
      00000000000000000000000000000000000032CD320032CD320032CD3200FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      000032CD320032CD320032CD3200FF000000FF000000FF000000000000000000
      00000000000000000000000000000000000032CD320032CD320032CD3200FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      000032CD320032CD320032CD3200FF000000FF000000FF000000000000000000
      00000000000000000000000000000000000032CD320032CD320032CD3200FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      000032CD320032CD320032CD3200FF000000FF000000FF000000000000000000
      00000000000000000000000000000000000032CD320032CD320032CD3200FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      000032CD320032CD320032CD3200FF000000FF000000FF000000000000000000
      00000000000000000000000000000000000032CD320032CD320032CD3200FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      000032CD320032CD320032CD3200FF000000FF000000FF000000000000000000
      00000000000000000000000000000000000032CD320032CD320032CD3200FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      000032CD320032CD320032CD3200FF000000FF000000FF000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      280000000C000000100000000100010000000000400000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
end
