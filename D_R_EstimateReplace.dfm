inherited Dlg_R_EstimateReplace: TDlg_R_EstimateReplace
  BorderStyle = bsDialog
  Caption = 'Dlg_R_EstimateReplace'
  ClientHeight = 119
  ClientWidth = 419
  ExplicitWidth = 425
  ExplicitHeight = 147
  PixelsPerInch = 96
  TextHeight = 13
  object Img_Info: TImage
    Left = 8
    Top = 91
    Width = 21
    Height = 20
    Anchors = [akLeft, akBottom]
    ExplicitTop = 82
  end
  object Bt_Cancel: TBitBtn
    Left = 336
    Top = 91
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Bt_Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object Bt_Ok: TBitBtn
    Left = 257
    Top = 91
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = Bt_OkClick
  end
  object E_1: TDBEditEh
    Left = 8
    Top = 24
    Width = 405
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ControlLabel.Width = 124
    ControlLabel.Height = 13
    ControlLabel.Caption = #1048#1089#1093#1086#1076#1085#1072#1103' '#1085#1086#1084#1077#1085#1082#1083#1072#1090#1091#1088#1072
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <
      item
        Style = ebsPlusEh
        OnClick = E_1EditButtons0Click
      end>
    TabOrder = 2
    Text = 'E_1'
    Visible = True
  end
  object E_2: TDBEditEh
    Left = 8
    Top = 64
    Width = 405
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ControlLabel.Width = 119
    ControlLabel.Height = 13
    ControlLabel.Caption = #1062#1077#1083#1077#1074#1072#1103' '#1085#1086#1084#1077#1085#1082#1083#1072#1090#1091#1088#1072
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <
      item
        Style = ebsPlusEh
        OnClick = E_2EditButtons0Click
      end>
    TabOrder = 3
    Text = 'E_2'
    Visible = True
  end
end
