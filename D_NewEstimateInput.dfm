inherited Dlg_NewEstimateInput: TDlg_NewEstimateInput
  Caption = 'Dlg_NewEstimateInput'
  ClientHeight = 432
  ClientWidth = 747
  ExplicitHeight = 470
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 413
    Width = 747
    ExplicitTop = 412
    ExplicitWidth = 743
    inherited lbl_StatusBar_Right: TLabel
      Left = 660
      Height = 17
      ExplicitLeft = 660
    end
    inherited lbl_StatusBar_Left: TLabel
      Height = 17
    end
  end
  inherited pnl_Buttons: TPanel
    Top = 380
    Width = 747
    ExplicitWidth = 743
    inherited chb_NoClose: TCheckBox
      Left = 241
      Top = 6
      ExplicitLeft = 237
      ExplicitTop = 6
    end
    object Bt_Load: TBitBtn
      Left = 466
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 5
      OnClick = Bt_LoadClick
      ExplicitLeft = 462
    end
    object Bt_LoadSelf: TBitBtn
      Left = 435
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 6
      OnClick = Bt_LoadSelfClick
      ExplicitLeft = 431
    end
    object Bt_PasteEstimate: TBitBtn
      Left = 404
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 7
      OnClick = Bt_PasteEstimateClick
      ExplicitLeft = 400
    end
    object Bt_CopyEstimate: TBitBtn
      Left = 373
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 8
      Visible = False
      OnClick = Bt_CopyEstimateClick
      ExplicitLeft = 369
    end
  end
  inherited pnl_Bottom: TPanel
    Top = 355
    Width = 747
    ExplicitTop = 354
    ExplicitWidth = 743
  end
  inherited pnl_Top: TPanel
    Width = 747
    Height = 33
    ExplicitWidth = 743
    ExplicitHeight = 33
    object lbl_Caption: TLabel
      Left = 8
      Top = 14
      Width = 52
      Height = 13
      Caption = 'lbl_Caption'
      Color = clBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object lbl_Type: TLabel
      Left = 8
      Top = 1
      Width = 40
      Height = 13
      Caption = 'lbl_Type'
    end
  end
  inherited pnl_Client: TPanel
    Top = 33
    Width = 747
    Height = 322
    ExplicitTop = 33
    ExplicitWidth = 743
    ExplicitHeight = 321
    inherited DBGridEh1: TDBGridEh
      Width = 747
      Height = 322
      OnGetCellParams = DBGridEh1GetCellParams
      OnKeyDown = DBGridEh1KeyDown
    end
  end
end
