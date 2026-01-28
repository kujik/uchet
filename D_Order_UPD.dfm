inherited Dlg_Order_UPD: TDlg_Order_UPD
  BorderStyle = bsDialog
  Caption = 'Dlg_Order_UPD'
  ClientHeight = 117
  ClientWidth = 202
  ExplicitWidth = 218
  ExplicitHeight = 156
  TextHeight = 13
  object Img_Info: TImage
    Left = 3
    Top = 84
    Width = 21
    Height = 20
    Anchors = [akLeft, akBottom]
    ExplicitTop = 85
  end
  object Bt_Ok: TBitBtn
    Left = 34
    Top = 84
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = Bt_OkClick
    ExplicitLeft = 42
    ExplicitTop = 85
  end
  object Bt_Cancel: TBitBtn
    Left = 115
    Top = 84
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Bt_Cancel'
    ModalResult = 2
    TabOrder = 1
    ExplicitLeft = 123
    ExplicitTop = 85
  end
  object dedt_Upd_Reg: TDBDateTimeEditEh
    Left = 72
    Top = 8
    Width = 124
    Height = 21
    ControlLabel.Width = 64
    ControlLabel.Height = 26
    ControlLabel.Caption = #1044#1072#1090#1072#13#10#1088#1077#1075#1080#1089#1090#1088#1072#1094#1080#1080
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    HighlightRequired = True
    Kind = dtkDateEh
    TabOrder = 2
    Visible = True
  end
  object dedt_Upd: TDBDateTimeEditEh
    Left = 72
    Top = 35
    Width = 124
    Height = 21
    ControlLabel.Width = 51
    ControlLabel.Height = 13
    ControlLabel.Caption = #1044#1072#1090#1072' '#1059#1055#1044
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 3
    Visible = True
  end
  object edt_Upd: TDBEditEh
    Left = 72
    Top = 62
    Width = 125
    Height = 21
    ControlLabel.Width = 38
    ControlLabel.Height = 13
    ControlLabel.Caption = #8470' '#1059#1055#1044
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 4
    Text = 'edt_Upd'
    Visible = True
  end
end
