inherited Dlg_DelayedInProd: TDlg_DelayedInProd
  BorderStyle = bsDialog
  Caption = 'Dlg_DelayedInProd'
  ClientHeight = 267
  ClientWidth = 503
  ExplicitWidth = 509
  ExplicitHeight = 296
  PixelsPerInch = 96
  TextHeight = 13
  object Img_Info: TImage
    Left = 8
    Top = 233
    Width = 21
    Height = 20
    Anchors = []
    ExplicitTop = 224
  end
  object Bt_Ok: TBitBtn
    Left = 339
    Top = 234
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    ModalResult = 1
    TabOrder = 0
    OnClick = Bt_OkClick
    ExplicitLeft = 329
    ExplicitTop = 224
  end
  object Bt_Cancel: TBitBtn
    Left = 420
    Top = 234
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 1
    ExplicitLeft = 410
    ExplicitTop = 224
  end
  object cmb_Reason: TDBComboBoxEh
    Left = 8
    Top = 20
    Width = 487
    Height = 21
    ControlLabel.Width = 103
    ControlLabel.Height = 13
    ControlLabel.Caption = #1055#1088#1080#1095#1080#1085#1072' '#1087#1088#1086#1089#1088#1086#1095#1082#1080':'
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    TabOrder = 2
    Text = 'cmb_Reason'
    Visible = True
  end
  object mem_Comment: TDBMemoEh
    Left = 8
    Top = 64
    Width = 487
    Height = 163
    ControlLabel.Width = 71
    ControlLabel.Height = 13
    ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081':'
    ControlLabel.Visible = True
    Lines.Strings = (
      'mem_Comment')
    AutoSize = False
    DynProps = <>
    EditButtons = <>
    TabOrder = 3
    Visible = True
    WantReturns = True
  end
end
