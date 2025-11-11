inherited Dlg_J_Montage: TDlg_J_Montage
  Caption = 'Dlg_J_Montage'
  ClientHeight = 315
  ClientWidth = 399
  ExplicitWidth = 415
  ExplicitHeight = 354
  TextHeight = 13
  object lbl_Act: TLabel [0]
    Left = 36
    Top = 256
    Width = 60
    Height = 13
    Caption = #1060#1072#1081#1083' '#1089#1095#1077#1090#1072
  end
  object lbl_Photos: TLabel [1]
    Left = 191
    Top = 256
    Width = 60
    Height = 13
    Caption = #1060#1072#1081#1083' '#1089#1095#1077#1090#1072
  end
  object Img_Info: TImage [2]
    Left = 8
    Top = 282
    Width = 21
    Height = 20
    Anchors = [akLeft, akBottom]
    ExplicitTop = 262
  end
  object lbl_Caption: TLabel [3]
    Left = 8
    Top = 8
    Width = 64
    Height = 13
    Caption = 'lbl_Caption'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  inherited pnl_StatusBar: TPanel
    Top = 296
    Width = 399
    ExplicitTop = 296
    ExplicitWidth = 399
  end
  object Bt_OK: TBitBtn [5]
    Left = 227
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_OK'
    TabOrder = 1
    OnClick = Bt_OKClick
  end
  object Bt_Cancel: TBitBtn [6]
    Left = 308
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Bt_Cancel'
    ModalResult = 2
    TabOrder = 2
    OnClick = Bt_CancelClick
  end
  object dedt_Beg: TDBDateTimeEditEh [7]
    Left = 113
    Top = 28
    Width = 111
    Height = 21
    ControlLabel.Width = 101
    ControlLabel.Height = 26
    ControlLabel.Caption = #1044#1072#1090#1072#13#10#1085#1072#1095#1072#1083#1072' '#1084#1086#1085#1090#1072#1078#1072'      '
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 3
    Visible = True
  end
  object dedt_End: TDBDateTimeEditEh [8]
    Left = 113
    Top = 55
    Width = 111
    Height = 21
    ControlLabel.Width = 101
    ControlLabel.Height = 26
    ControlLabel.Caption = #1044#1072#1090#1072#13#10#1086#1082#1086#1085#1095#1072#1085#1080#1103' '#1084#1086#1085#1090#1072#1078#1072
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 4
    Visible = True
  end
  object chb_RC: TDBCheckBoxEh [9]
    Left = 245
    Top = 32
    Width = 185
    Height = 17
    Caption = #1047#1072#1084#1077#1095#1072#1085#1080#1103' '#1079#1072#1082#1072#1079#1095#1080#1082#1072
    DynProps = <>
    TabOrder = 5
  end
  object chb_RI: TDBCheckBoxEh [10]
    Left = 245
    Top = 57
    Width = 185
    Height = 17
    Caption = #1047#1072#1084#1077#1095#1072#1085#1080#1103' '#1084#1086#1085#1090#1072#1078#1085#1080#1082#1086#1074
    DynProps = <>
    TabOrder = 6
  end
  object mem_Comm: TDBMemoEh [11]
    Left = 8
    Top = 100
    Width = 393
    Height = 145
    ControlLabel.Width = 73
    ControlLabel.Height = 13
    ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081':'
    ControlLabel.Visible = True
    Lines.Strings = (
      'mem_Comm')
    AutoSize = False
    DynProps = <>
    EditButtons = <>
    TabOrder = 7
    Visible = True
    WantReturns = True
  end
  object Bt_Act: TBitBtn [12]
    Left = 5
    Top = 251
    Width = 25
    Height = 25
    Hint = #1055#1088#1080#1082#1088#1077#1087#1080#1090#1100' '#1092#1072#1081#1083
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    OnClick = Bt_ActClick
    OnExit = Bt_ActExit
  end
  object Bt_Photos: TBitBtn [13]
    Left = 160
    Top = 251
    Width = 25
    Height = 25
    Hint = #1055#1088#1080#1082#1088#1077#1087#1080#1090#1100' '#1092#1072#1081#1083
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
    OnClick = Bt_PhotosClick
    OnExit = Bt_PhotosExit
  end
  inherited tmrAfterCreate: TTimer
    Left = 320
    Top = 280
  end
  object OpenDialog1: TOpenDialog
    Left = 51
    Top = 267
  end
end
