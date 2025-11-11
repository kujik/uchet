inherited Dlg_Rep_Smeta: TDlg_Rep_Smeta
  BorderStyle = bsDialog
  Caption = #1054#1073#1097#1072#1103' '#1089#1084#1077#1090#1072' '#1087#1086' '#1079#1072#1082#1072#1079#1072#1084
  ClientHeight = 364
  ClientWidth = 410
  OnActivate = FormActivate
  ExplicitWidth = 426
  ExplicitHeight = 403
  TextHeight = 13
  object lbl_AddOrders: TLabel
    Left = 8
    Top = 39
    Width = 123
    Height = 13
    Caption = #1053#1077#1090' '#1074#1099#1073#1088#1072#1085#1085#1099#1093' '#1079#1072#1082#1072#1079#1086#1074
  end
  object lbl_Progress: TLabel
    Left = 8
    Top = 58
    Width = 152
    Height = 13
    Caption = #1053#1077#1090' '#1076#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1093' '#1079#1072#1082#1072#1079#1086#1074
  end
  object Bt_Go: TBitBtn
    Left = 171
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Bt_Go'
    TabOrder = 0
    OnClick = Bt_GoClick
  end
  object Bt_AddOrders: TBitBtn
    Left = 8
    Top = 8
    Width = 157
    Height = 25
    Hint = #1059#1076#1072#1083#1080#1090#1100' '#1087#1088#1086#1077#1082#1090' '#1080#1079' '#1089#1087#1080#1089#1082#1072
    Caption = '+'#1047#1072#1082#1072#1079#1099
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = Bt_AddOrdersClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 78
    Width = 398
    Height = 274
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object Bt_Stop: TBitBtn
    Left = 331
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Bt_Go'
    TabOrder = 3
    OnClick = Bt_StopClick
  end
end
