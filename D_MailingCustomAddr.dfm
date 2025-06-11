inherited Dlg_MailingCustomAddr: TDlg_MailingCustomAddr
  BorderStyle = bsDialog
  Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1077' '#1072#1076#1088#1077#1089#1072' '#1101#1083#1077#1082#1090#1088#1086#1085#1085#1086#1081' '#1087#1086#1095#1090#1099
  ClientHeight = 81
  ClientWidth = 623
  ExplicitWidth = 629
  ExplicitHeight = 110
  PixelsPerInch = 96
  TextHeight = 13
  object Img_Info: TImage
    Left = 8
    Top = 51
    Width = 23
    Height = 25
  end
  object Bt_Ok: TBitBtn
    Left = 463
    Top = 51
    Width = 75
    Height = 25
    Caption = 'Bt_Ok'
    Default = True
    TabOrder = 0
    OnClick = Bt_OkClick
  end
  object Bt_Cancel: TBitBtn
    Left = 544
    Top = 51
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 1
  end
  object E_Addr: TDBEditEh
    Left = 8
    Top = 24
    Width = 611
    Height = 21
    ControlLabel.Width = 307
    ControlLabel.Height = 13
    ControlLabel.Caption = #1042#1074#1077#1076#1080#1090#1077' '#1072#1076#1088#1077#1089#1072' '#1101#1083#1077#1082#1090#1088#1086#1085#1085#1086#1081' '#1087#1086#1095#1090#1099', '#1088#1072#1079#1076#1077#1083#1103#1103' '#1080#1093' '#1079#1072#1087#1103#1090#1099#1084#1080
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    TabOrder = 2
    Text = 'E_Addr'
    Visible = True
  end
end
