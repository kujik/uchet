object Dlg_ExpenseItems: TDlg_ExpenseItems
  Left = 1097
  Top = 475
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Dlg_ExpenseItems'
  ClientHeight = 220
  ClientWidth = 638
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  DesignSize = (
    638
    220)
  PixelsPerInch = 96
  TextHeight = 13
  object Img_Info: TImage
    Left = 8
    Top = 187
    Width = 23
    Height = 25
    Anchors = [akLeft, akBottom]
  end
  object E_Name: TDBEditEh
    Left = 88
    Top = 35
    Width = 535
    Height = 21
    ControlLabel.Width = 76
    ControlLabel.Height = 13
    ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 1
    Visible = True
    OnChange = E_NameChange
  end
  object Cb_Active: TDBCheckBoxEh
    Left = 95
    Top = 165
    Width = 97
    Height = 17
    Caption = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103
    Color = clRed
    DynProps = <>
    ParentColor = False
    TabOrder = 8
    OnClick = Cb_ActiveClick
  end
  object Bt_OK: TBitBtn
    Left = 474
    Top = 187
    Width = 75
    Height = 25
    Caption = 'Bt_OK'
    TabOrder = 9
    OnClick = Bt_OKClick
  end
  object Bt_Cancel: TBitBtn
    Left = 555
    Top = 187
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Bt_Cancel'
    ModalResult = 2
    TabOrder = 10
    OnClick = Bt_CancelClick
  end
  object E_users: TDBEditEh
    Left = 88
    Top = 62
    Width = 535
    Height = 21
    ControlLabel.Width = 37
    ControlLabel.Height = 13
    ControlLabel.Caption = #1044#1086#1089#1090#1091#1087
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <
      item
        OnClick = E_usersEditButtons0Click
      end>
    ReadOnly = True
    TabOrder = 2
    Visible = True
    OnChange = E_NameChange
  end
  object E_Agreed: TDBEditEh
    Left = 88
    Top = 89
    Width = 535
    Height = 21
    ControlLabel.Width = 72
    ControlLabel.Height = 13
    ControlLabel.Caption = #1057#1086#1075#1083#1072#1089#1086#1074#1072#1085#1080#1077
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <
      item
        OnClick = E_AgreedEditButtons0Click
      end>
    ReadOnly = True
    TabOrder = 3
    Visible = True
    OnChange = E_NameChange
  end
  object Cb_Group: TDBComboBoxEh
    Left = 88
    Top = 8
    Width = 535
    Height = 21
    ControlLabel.Width = 35
    ControlLabel.Height = 13
    ControlLabel.Caption = #1043#1088#1091#1087#1087#1072
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 0
    Visible = True
  end
  object Chb_RecvReceipt: TDBCheckBoxEh
    Left = 95
    Top = 142
    Width = 121
    Height = 17
    Caption = #1058#1088#1077#1073#1091#1077#1090#1089#1103' '#1079#1072#1103#1074#1082#1072
    Color = clRed
    DynProps = <>
    ParentColor = False
    TabOrder = 7
    OnClick = Cb_ActiveClick
  end
  object Chb_AccountTO: TDBCheckBoxEh
    Left = 95
    Top = 119
    Width = 138
    Height = 17
    Caption = #1058#1088#1072#1085#1089#1087#1086#1088#1090' '#1086#1090#1075#1088#1091#1079#1082#1072
    Color = clRed
    DynProps = <>
    ParentColor = False
    TabOrder = 4
    OnClick = Chb_AccountTOClick
  end
  object Chb_AccountTS: TDBCheckBoxEh
    Left = 247
    Top = 119
    Width = 146
    Height = 17
    Caption = #1058#1088#1072#1085#1089#1087#1086#1088#1090' '#1089#1085#1072#1073#1078#1077#1085#1080#1077
    Color = clRed
    DynProps = <>
    ParentColor = False
    TabOrder = 5
    OnClick = Chb_AccountTSClick
  end
  object Chb_AccountM: TDBCheckBoxEh
    Left = 415
    Top = 119
    Width = 146
    Height = 17
    Caption = #1055#1086#1076#1088#1103#1076#1095#1080#1082#1080' '#1087#1086' '#1084#1086#1085#1090#1072#1078#1091
    Color = clRed
    DynProps = <>
    ParentColor = False
    TabOrder = 6
    OnClick = Chb_AccountMClick
  end
end
