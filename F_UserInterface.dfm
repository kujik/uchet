object Form_UserInterface: TForm_UserInterface
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1080#1085#1090#1077#1088#1092#1077#1081#1089#1072
  ClientHeight = 273
  ClientWidth = 856
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 300
    Top = 240
    Width = 71
    Height = 13
    Caption = #1063#1077#1088#1085#1099#1081' '#1090#1077#1082#1089#1090
  end
  object Label2: TLabel
    Left = 388
    Top = 240
    Width = 76
    Height = 13
    Caption = #1050#1088#1072#1089#1085#1099#1081' '#1090#1077#1082#1089#1090
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 259
    Top = 8
    Width = 3
    Height = 245
  end
  object DBGridEh1: TDBGridEh
    Left = 295
    Top = 16
    Width = 549
    Height = 177
    DataSource = DataSource1
    DynProps = <>
    TabOrder = 0
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object Cb_Styles: TDBComboBoxEh
    Left = 8
    Top = 31
    Width = 226
    Height = 21
    ControlLabel.Width = 96
    ControlLabel.Height = 13
    ControlLabel.Caption = #1057#1090#1080#1083#1100' '#1086#1092#1086#1088#1084#1083#1077#1085#1080#1103
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    LimitTextToListValues = True
    TabOrder = 1
    Text = 'Cb_Styles'
    Visible = True
    OnChange = Cb_StylesChange
  end
  object Bt_1: TBitBtn
    Left = 295
    Top = 204
    Width = 89
    Height = 25
    Caption = 'Bt_1'
    TabOrder = 2
  end
  object CheckBox1: TCheckBox
    Left = 398
    Top = 208
    Width = 73
    Height = 17
    Caption = #1060#1083#1072#1078#1086#1082
    TabOrder = 3
  end
  object RadioButton1: TRadioButton
    Left = 477
    Top = 208
    Width = 113
    Height = 17
    Caption = #1055#1077#1088#1077#1082#1083#1102#1095#1072#1090#1077#1083#1100
    TabOrder = 4
  end
  object DBEditEh1: TDBEditEh
    Left = 669
    Top = 206
    Width = 175
    Height = 21
    ControlLabel.Width = 59
    ControlLabel.Height = 13
    ControlLabel.Caption = #1055#1086#1083#1077' '#1074#1074#1086#1076#1072
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <
      item
      end>
    HighlightRequired = True
    TabOrder = 5
    Visible = True
  end
  object Cb_Q: TDBComboBoxEh
    Left = 8
    Top = 85
    Width = 226
    Height = 21
    ControlLabel.Width = 201
    ControlLabel.Height = 13
    ControlLabel.Caption = #1057#1087#1088#1072#1096#1080#1074#1072#1090#1100' '#1087#1088#1080' '#1079#1072#1082#1088#1099#1090#1080#1080' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    LimitTextToListValues = True
    TabOrder = 6
    Text = 'Cb_Styles'
    Visible = True
    OnChange = Cb_Change
  end
  object Cb_J: TDBComboBoxEh
    Left = 8
    Top = 127
    Width = 226
    Height = 21
    ControlLabel.Width = 154
    ControlLabel.Height = 13
    ControlLabel.Caption = #1054#1082#1085#1072' '#1078#1091#1088#1085#1072#1083#1086#1074'/'#1089#1087#1088#1072#1074#1086#1095#1085#1080#1082#1086#1074
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    LimitTextToListValues = True
    TabOrder = 7
    Text = 'Cb_Styles'
    Visible = True
    OnChange = Cb_Change
  end
  object Cb_D: TDBComboBoxEh
    Left = 8
    Top = 169
    Width = 226
    Height = 21
    ControlLabel.Width = 161
    ControlLabel.Height = 13
    ControlLabel.Caption = #1054#1082#1085#1072' '#1076#1080#1072#1083#1086#1075#1086#1074' ('#1074#1074#1086#1076#1072' '#1076#1072#1085#1085#1099#1093')'
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    LimitTextToListValues = True
    TabOrder = 8
    Text = 'Cb_Styles'
    Visible = True
    OnChange = Cb_Change
  end
  object Bt_Def: TBitBtn
    Left = 8
    Top = 228
    Width = 226
    Height = 25
    Caption = #1055#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
    TabOrder = 9
    OnClick = Bt_DefClick
  end
  object Chb_DesignReports: TCheckBox
    Left = 8
    Top = 196
    Width = 245
    Height = 17
    Caption = #1054#1090#1082#1088#1099#1074#1072#1090#1100' '#1076#1080#1079#1072#1081#1085#1077#1088' '#1086#1090#1095#1077#1090#1086#1074' '#1087#1088#1080' '#1087#1077#1095#1072#1090#1080
    TabOrder = 10
    OnClick = Chb_DesignReportsClick
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 685
    Top = 140
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 734
    Top = 140
  end
end
