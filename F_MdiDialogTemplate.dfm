inherited Form_MdiDialogTemplate: TForm_MdiDialogTemplate
  Caption = 'Form_MdiDialogTemplate'
  ClientHeight = 360
  ClientWidth = 580
  ExplicitWidth = 596
  ExplicitHeight = 399
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 341
    Width = 580
    TabOrder = 1
    ExplicitTop = 342
    ExplicitWidth = 584
    inherited lbl_StatusBar_Right: TLabel
      Left = 495
      ExplicitLeft = 495
    end
  end
  object pnl_Bottom: TPanel [1]
    Left = 0
    Top = 310
    Width = 580
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      580
      31)
    object Img_Info: TImage
      Left = 8
      Top = 8
      Width = 20
      Height = 20
    end
    object bvl1: TBevel
      Left = 0
      Top = 0
      Width = 580
      Height = 2
      Align = alTop
      ExplicitLeft = 264
      ExplicitTop = -8
      ExplicitWidth = 50
    end
    object Bt_OK: TBitBtn
      Left = 409
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_OK'
      TabOrder = 0
      OnClick = Bt_OKClick
      ExplicitLeft = 417
      ExplicitTop = 3
    end
    object Bt_Cancel: TBitBtn
      Left = 490
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Bt_Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = Bt_CancelClick
      ExplicitLeft = 498
      ExplicitTop = 3
    end
    object chb_NoClose: TCheckBox
      Left = 282
      Top = 9
      Width = 121
      Height = 16
      Anchors = [akRight, akBottom]
      Caption = #1053#1077' '#1079#1072#1082#1088#1099#1074#1072#1090#1100' '#1086#1082#1085#1086
      TabOrder = 2
      ExplicitLeft = 290
      ExplicitTop = 8
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 240
    Top = 160
  end
end
