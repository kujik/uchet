inherited Dlg_R_EstimateReplace: TDlg_R_EstimateReplace
  BorderStyle = bsDialog
  Caption = 'Dlg_R_EstimateReplace'
  ClientHeight = 116
  ClientWidth = 407
  ExplicitWidth = 423
  ExplicitHeight = 155
  TextHeight = 13
  object Img_Info: TImage
    Left = 8
    Top = 88
    Width = 21
    Height = 20
    Anchors = [akLeft, akBottom]
    ExplicitTop = 82
  end
  object Bt_Cancel: TBitBtn
    Left = 312
    Top = 88
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Bt_Cancel'
    ModalResult = 2
    TabOrder = 0
    ExplicitLeft = 320
    ExplicitTop = 89
  end
  object Bt_Ok: TBitBtn
    Left = 233
    Top = 88
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = Bt_OkClick
    ExplicitLeft = 241
    ExplicitTop = 89
  end
  object edt_1: TDBEditEh
    Left = 8
    Top = 24
    Width = 381
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
        OnClick = edt_1EditButtons0Click
      end>
    TabOrder = 2
    Text = 'edt_1'
    Visible = True
    ExplicitWidth = 389
  end
  object edt_2: TDBEditEh
    Left = 8
    Top = 64
    Width = 381
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
        OnClick = edt_2EditButtons0Click
      end>
    TabOrder = 3
    Text = 'edt_2'
    Visible = True
    ExplicitWidth = 389
  end
end
