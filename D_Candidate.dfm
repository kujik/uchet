inherited Dlg_Candidate: TDlg_Candidate
  Caption = 'Dlg_Candidate'
  ClientHeight = 470
  ClientWidth = 651
  ExplicitWidth = 667
  ExplicitHeight = 509
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 451
    Width = 651
  end
  object gb_Candidate: TGroupBox [1]
    Left = 0
    Top = 0
    Width = 651
    Height = 94
    Align = alTop
    Caption = #1057#1086#1080#1089#1082#1072#1090#1077#1083#1100
    TabOrder = 1
    object lbl_History: TLabel
      Left = 11
      Top = 70
      Width = 30
      Height = 13
      Caption = 'Found'
      OnClick = lbl_HistoryClick
    end
    object edt_F: TDBEditEh
      Left = 93
      Top = 16
      Width = 140
      Height = 21
      ControlLabel.Width = 49
      ControlLabel.Height = 13
      ControlLabel.Caption = #1060#1072#1084#1080#1083#1080#1103
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      TabOrder = 0
      Text = 'edt_F'
      Visible = True
      OnChange = ControlOnChange
    end
    object dedt_Birth: TDBDateTimeEditEh
      Left = 93
      Top = 43
      Width = 140
      Height = 21
      ControlLabel.Width = 80
      ControlLabel.Height = 13
      ControlLabel.Caption = #1044#1077#1085#1100' '#1088#1086#1078#1076#1077#1085#1080#1103
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      Kind = dtkDateEh
      TabOrder = 3
      Visible = True
    end
    object edt_I: TDBEditEh
      Left = 290
      Top = 16
      Width = 140
      Height = 21
      ControlLabel.Width = 22
      ControlLabel.Height = 13
      ControlLabel.Caption = #1048#1084#1103
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      TabOrder = 1
      Text = 'edt_F'
      Visible = True
    end
    object edt_Phone: TDBEditEh
      Left = 290
      Top = 43
      Width = 349
      Height = 21
      ControlLabel.Width = 45
      ControlLabel.Height = 13
      ControlLabel.Caption = #1058#1077#1083#1077#1092#1086#1085
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      TabOrder = 4
      Text = 'edt_F'
      Visible = True
    end
    object edt_O: TDBEditEh
      Left = 493
      Top = 16
      Width = 146
      Height = 21
      ControlLabel.Width = 47
      ControlLabel.Height = 13
      ControlLabel.Caption = #1054#1090#1095#1077#1089#1090#1074#1086
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      TabOrder = 2
      Text = 'edt_F'
      Visible = True
    end
  end
  object gb_Vacancy: TGroupBox [2]
    Left = 0
    Top = 94
    Width = 651
    Height = 148
    Align = alTop
    Caption = #1042#1072#1082#1072#1085#1089#1080#1103
    TabOrder = 2
    object pnl_Vacancy: TPanel
      Left = 2
      Top = 46
      Width = 647
      Height = 100
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object cmb_Division: TDBComboBoxEh
        Left = 91
        Top = 7
        Width = 546
        Height = 21
        ControlLabel.Width = 80
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        LimitTextToListValues = True
        TabOrder = 0
        Visible = True
      end
      object cmb_Job: TDBComboBoxEh
        Left = 91
        Top = 34
        Width = 546
        Height = 21
        ControlLabel.Width = 58
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1088#1086#1092#1077#1089#1089#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        LimitTextToListValues = True
        TabOrder = 1
        Visible = True
      end
      object cmb_Head: TDBComboBoxEh
        Left = 91
        Top = 64
        Width = 546
        Height = 21
        ControlLabel.Width = 79
        ControlLabel.Height = 13
        ControlLabel.Caption = #1054#1090#1074#1077#1090#1089#1090#1074#1077#1085#1085#1099#1081
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        LimitTextToListValues = True
        TabOrder = 2
        Visible = True
      end
    end
    object cmb_Vacancy: TDBComboBoxEh
      Left = 93
      Top = 19
      Width = 546
      Height = 21
      ControlLabel.Width = 49
      ControlLabel.Height = 13
      ControlLabel.Caption = #1042#1072#1082#1072#1085#1089#1080#1103
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 1
      Visible = True
      OnChange = cmb_VacancyChange
    end
  end
  object gb_Status: TGroupBox [3]
    Left = 0
    Top = 242
    Width = 651
    Height = 78
    Align = alTop
    Caption = #1057#1090#1072#1090#1091#1089
    TabOrder = 3
    object lbl_StatusError: TLabel
      Left = 248
      Top = 20
      Width = 310
      Height = 13
      Caption = #1053#1077' '#1074#1089#1077' '#1076#1072#1085#1085#1099#1077' '#1074#1074#1077#1076#1077#1085#1099' '#1080#1083#1080' '#1085#1077#1087#1088#1072#1074#1080#1083#1100#1085#1086' '#1074#1099#1089#1090#1072#1074#1083#1077#1085#1099' '#1076#1072#1090#1099'!'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lbl_Dt1: TLabel
      Left = 53
      Top = 48
      Width = 37
      Height = 13
      Caption = #1055#1088#1080#1085#1103#1090
    end
    object lbl_Dt2: TLabel
      Left = 254
      Top = 48
      Width = 38
      Height = 13
      Caption = #1059#1074#1086#1083#1077#1085
    end
    object dedt_Dt: TDBDateTimeEditEh
      Left = 93
      Top = 13
      Width = 140
      Height = 21
      ControlLabel.Width = 55
      ControlLabel.Height = 13
      ControlLabel.Caption = #1054#1073#1088#1072#1090#1080#1083#1089#1103
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      Kind = dtkDateEh
      TabOrder = 0
      Visible = True
    end
    object dedt_Pr: TDBDateTimeEditEh
      Left = 93
      Top = 43
      Width = 140
      Height = 21
      ControlLabel.Caption = #1054#1073#1088#1072#1090#1080#1083#1089#1103
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      Kind = dtkDateEh
      TabOrder = 1
      Visible = True
    end
    object dedt_Uv: TDBDateTimeEditEh
      Left = 297
      Top = 43
      Width = 140
      Height = 21
      ControlLabel.Caption = #1054#1073#1088#1072#1090#1080#1083#1089#1103
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      Kind = dtkDateEh
      TabOrder = 2
      Visible = True
    end
    object cmb_Status: TDBComboBoxEh
      Left = 498
      Top = 43
      Width = 140
      Height = 21
      ControlLabel.Width = 34
      ControlLabel.Height = 13
      ControlLabel.Caption = #1057#1090#1072#1090#1091#1089
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 3
      Visible = True
    end
  end
  object gb_Comment: TGroupBox [4]
    Left = 0
    Top = 320
    Width = 651
    Height = 114
    Align = alTop
    Caption = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1077
    TabOrder = 4
    DesignSize = (
      651
      114)
    object pnl_Comment: TPanel
      Left = 11
      Top = 18
      Width = 626
      Height = 61
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelOuter = bvNone
      TabOrder = 0
      object mem_Comment: TMemo
        Left = 0
        Top = 0
        Width = 626
        Height = 61
        Align = alClient
        Lines.Strings = (
          'mem_Comment')
        TabOrder = 0
      end
    end
    object cmb_Ad: TDBComboBoxEh
      Left = 134
      Top = 85
      Width = 473
      Height = 21
      ControlLabel.Width = 115
      ControlLabel.Height = 13
      ControlLabel.Caption = #1048#1089#1090#1086#1095#1085#1080#1082' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 1
      Visible = True
    end
    object Bt_SelectAd: TBitBtn
      Left = 613
      Top = 85
      Width = 25
      Height = 25
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1087#1086#1089#1090#1072#1074#1097#1080#1082#1086#1074
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      TabStop = False
      OnClick = Bt_SelectAdClick
    end
  end
  object pnl_Buttons: TPanel [5]
    Left = 0
    Top = 434
    Width = 651
    Height = 37
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 5
    ExplicitLeft = -2
    ExplicitTop = 436
    DesignSize = (
      651
      37)
    object Img_Info: TImage
      Left = 2
      Top = 6
      Width = 23
      Height = 25
      Anchors = [akLeft, akBottom]
    end
    object lbl_VClosed: TLabel
      Left = 35
      Top = 6
      Width = 402
      Height = 25
      AutoSize = False
      Caption = 
        #1042#1072#1082#1072#1085#1089#1080#1103', '#1085#1072' '#1082#1086#1090#1086#1088#1091#1102' '#1087#1088#1080#1085#1103#1090'/'#1087#1088#1077#1090#1077#1085#1076#1091#1077#1090' '#1088#1072#1073#1086#1090#1085#1080#1082', '#1079#1072#1082#1088#1099#1090#1072'! '#1042#1099' '#1085#1077' ' +
        #1084#1086#1078#1077#1090#1077' '#1087#1086#1084#1077#1085#1103#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1087#1086' '#1074#1072#1082#1072#1085#1089#1080#1080' '#1080' '#1089#1090#1072#1090#1091#1089' ('#1084#1086#1078#1085#1086' '#1090#1086#1083#1100#1082#1086' '#1087#1086#1089#1090#1072#1074 +
        #1080#1090#1100' "'#1091#1074#1086#1083#1077#1085'"'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object Bt_Ok: TBitBtn
      Left = 482
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Bt_Ok'
      TabOrder = 0
      OnClick = Bt_OkClick
    end
    object Bt_Cancel: TBitBtn
      Left = 563
      Top = 6
      Width = 75
      Height = 25
      Caption = 'BitBtn1'
      TabOrder = 1
      OnClick = Bt_CancelClick
    end
    object Bt_AddWorker: TBitBtn
      Left = 451
      Top = 6
      Width = 25
      Height = 25
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100'/'#1087#1088#1080#1085#1103#1090#1100' '#1088#1072#1073#1086#1090#1085#1080#1082#1072
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      TabStop = False
      OnClick = Bt_AddWorkerClick
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 65532
    Top = 633
  end
end
