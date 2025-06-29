inherited Dlg_Turv_FromParsec: TDlg_Turv_FromParsec
  BorderStyle = bsDialog
  Caption = #1048#1084#1087#1086#1088#1090' '#1080#1079' '#1055#1072#1088#1089#1077#1082
  ClientHeight = 120
  ClientWidth = 228
  ExplicitWidth = 234
  ExplicitHeight = 149
  PixelsPerInch = 96
  TextHeight = 13
  object edt_FileName: TDBEditEh
    Left = 12
    Top = 27
    Width = 208
    Height = 21
    ControlLabel.Width = 164
    ControlLabel.Height = 13
    ControlLabel.Caption = #1060#1072#1081#1083' '#1074#1099#1075#1088#1091#1079#1082#1080' '#1080#1079' '#1055#1072#1088#1089#1077#1082' (.xlsx)'
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <
      item
        DefaultAction = False
        Style = ebsEllipsisEh
        OnClick = edt_FileNameEditButtons0Click
      end>
    ReadOnly = True
    TabOrder = 0
    Visible = True
  end
  object dedt_1: TDBDateTimeEditEh
    Left = 12
    Top = 54
    Width = 90
    Height = 21
    ControlLabel.Width = 7
    ControlLabel.Height = 13
    ControlLabel.Caption = #1057
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    HighlightRequired = True
    Kind = dtkDateEh
    TabOrder = 1
    Visible = True
  end
  object dedt_2: TDBDateTimeEditEh
    Left = 129
    Top = 54
    Width = 90
    Height = 21
    ControlLabel.Width = 12
    ControlLabel.Height = 13
    ControlLabel.Caption = #1087#1086
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    HighlightRequired = True
    Kind = dtkDateEh
    TabOrder = 2
    Visible = True
  end
  object Bt_Ok: TBitBtn
    Left = 60
    Top = 84
    Width = 75
    Height = 25
    Caption = 'Bt_Ok'
    Default = True
    TabOrder = 3
    OnClick = Bt_OkClick
  end
  object Bt_Cancel: TBitBtn
    Left = 144
    Top = 84
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 4
  end
  object OpenDialog1: TOpenDialog
    Left = 3
    Top = 90
  end
end
