inherited Form_Adm_Installer: TForm_Adm_Installer
  Anchors = [akLeft, akTop, akBottom]
  Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
  ClientHeight = 514
  ClientWidth = 784
  ExplicitWidth = 796
  ExplicitHeight = 552
  TextHeight = 13
  object lbl_InstalledInfo: TLabel [0]
    Left = 8
    Top = 51
    Width = 92
    Height = 16
    Caption = 'lbl_InstalledInfo'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lbl_FilesInfo: TLabel [1]
    Left = 8
    Top = 450
    Width = 92
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'lbl_InstalledInfo'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ExplicitTop = 451
  end
  object lbl_Status: TLabel [2]
    Left = 480
    Top = 480
    Width = 92
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'lbl_InstalledInfo'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ExplicitTop = 481
  end
  object lbl_PrevInstall: TLabel [3]
    Left = 8
    Top = 303
    Width = 91
    Height = 13
    Caption = #1059#1089#1090#1072#1085#1086#1074#1082#1080' '#1088#1072#1085#1077#1077':'
  end
  inherited pnl_StatusBar: TPanel
    Top = 513
    Width = 784
    Height = 1
    Visible = False
    ExplicitTop = 512
    ExplicitWidth = 780
    ExplicitHeight = 1
    inherited lbl_StatusBar_Right: TLabel
      Left = 697
      ExplicitLeft = 706
    end
    inherited lbl_StatusBar_Left: TLabel
      Anchors = [akLeft, akBottom]
    end
  end
  object cmb_Module: TDBComboBoxEh [5]
    Left = 8
    Top = 24
    Width = 241
    Height = 21
    ControlLabel.Width = 174
    ControlLabel.Height = 13
    ControlLabel.Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1084#1086#1076#1091#1083#1100' '#1076#1083#1103' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1103
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    LimitTextToListValues = True
    TabOrder = 1
    Text = 'cmb_Module'
    Visible = True
    OnChange = cmb_ModuleChange
  end
  object edt_Version: TDBEditEh [6]
    Left = 272
    Top = 24
    Width = 241
    Height = 21
    Color = clBtnFace
    ControlLabel.Width = 77
    ControlLabel.Height = 13
    ControlLabel.Caption = #1042#1077#1088#1089#1080#1103' '#1084#1086#1076#1091#1083#1103
    ControlLabel.Color = clBtnText
    ControlLabel.ParentColor = False
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    ReadOnly = True
    TabOrder = 2
    Visible = True
  end
  object edt_DtCompiled: TDBEditEh [7]
    Left = 545
    Top = 24
    Width = 241
    Height = 21
    Color = clBtnFace
    ControlLabel.Width = 91
    ControlLabel.Height = 13
    ControlLabel.Caption = #1044#1072#1090#1072' '#1082#1086#1084#1087#1080#1083#1103#1094#1080#1080
    ControlLabel.Color = clBtnText
    ControlLabel.ParentColor = False
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    ReadOnly = True
    TabOrder = 3
    Visible = True
  end
  object edt_SrcPath: TDBEditEh [8]
    Left = 8
    Top = 89
    Width = 377
    Height = 21
    ControlLabel.Width = 103
    ControlLabel.Height = 13
    ControlLabel.Caption = #1050#1072#1090#1072#1083#1086#1075' '#1080#1089#1093#1086#1076#1085#1080#1082#1086#1074
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    TabOrder = 4
    Visible = True
    OnChange = cmb_ModuleChange
  end
  object edt_DstPath: TDBEditEh [9]
    Left = 409
    Top = 89
    Width = 377
    Height = 21
    ControlLabel.Width = 87
    ControlLabel.Height = 13
    ControlLabel.Caption = #1062#1077#1083#1077#1074#1086#1081' '#1082#1072#1090#1072#1083#1086#1075
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    TabOrder = 5
    Visible = True
    OnChange = cmb_ModuleChange
  end
  object mem_Users: TDBMemoEh [10]
    Left = 8
    Top = 136
    Width = 778
    Height = 49
    ControlLabel.Width = 225
    ControlLabel.Height = 13
    ControlLabel.Caption = #1052#1086#1076#1091#1083#1100' '#1086#1090#1082#1088#1099#1090' '#1091' '#1089#1083#1077#1076#1091#1102#1097#1080#1093' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
    ControlLabel.Visible = True
    Lines.Strings = (
      'mem_Users')
    AutoSize = False
    Color = clBtnFace
    DynProps = <>
    EditButtons = <>
    TabOrder = 6
    Visible = True
    WantReturns = True
  end
  object mem_Comment: TDBMemoEh [11]
    Left = 8
    Top = 208
    Width = 778
    Height = 89
    ControlLabel.Width = 134
    ControlLabel.Height = 13
    ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081' '#1082' '#1091#1089#1090#1072#1085#1086#1074#1082#1077
    ControlLabel.Visible = True
    Lines.Strings = (
      'mem_Users')
    AutoSize = False
    DynProps = <>
    EditButtons = <>
    HighlightRequired = True
    MaxLength = 4000
    TabOrder = 7
    Visible = True
    WantReturns = True
  end
  object Bt_Ok: TBitBtn [12]
    Left = 569
    Top = 473
    Width = 195
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1084#1086#1076#1091#1083#1100
    TabOrder = 8
    OnClick = Bt_OkClick
    ExplicitLeft = 565
    ExplicitTop = 472
  end
  object Dbg_PrevInstall: TDBGridEh [13]
    Left = 8
    Top = 322
    Width = 265
    Height = 127
    Color = clMenuBar
    DynProps = <>
    ReadOnly = True
    TabOrder = 9
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object mem_PrevInstalllcomment: TDBMemoEh [14]
    Left = 279
    Top = 322
    Width = 498
    Height = 127
    ControlLabel.Width = 70
    ControlLabel.Height = 13
    ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
    ControlLabel.Visible = True
    AutoSize = False
    Color = clMenuBar
    DynProps = <>
    EditButtons = <>
    MaxLength = 4000
    ReadOnly = True
    TabOrder = 10
    Visible = True
    WantReturns = True
  end
  object chb_CloseSessions: TDBCheckBoxEh [15]
    Left = 592
    Top = 455
    Width = 195
    Height = 17
    Caption = #1047#1072#1074#1077#1088#1096#1080#1090#1100' '#1089#1077#1089#1089#1080#1080' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
    DynProps = <>
    TabOrder = 11
  end
  object ProgressBar1: TProgressBar [16]
    Left = 8
    Top = 477
    Width = 457
    Height = 33
    Style = pbstMarquee
    MarqueeInterval = 20
    Step = 20
    TabOrder = 12
  end
  inherited tmrAfterCreate: TTimer
    Left = 152
    Top = 544
  end
  object tmr1: TTimer
    Interval = 10000
    OnTimer = tmr1Timer
    Left = 184
    Top = 749
  end
  object Timer2: TTimer
    OnTimer = Timer2Timer
    Left = 120
    Top = 544
  end
end
