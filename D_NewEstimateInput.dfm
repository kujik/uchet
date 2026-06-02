inherited Dlg_NewEstimateInput: TDlg_NewEstimateInput
  Caption = 'Dlg_NewEstimateInput'
  ClientWidth = 747
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Width = 747
    ExplicitTop = 411
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
    Width = 747
    ExplicitTop = 378
    ExplicitWidth = 743
    inherited chb_NoClose: TCheckBox
      Left = 233
      Top = 6
      ExplicitLeft = 229
      ExplicitTop = 6
    end
    object Bt_Load: TBitBtn
      Left = 458
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 5
      OnClick = Bt_LoadClick
      ExplicitLeft = 454
    end
    object Bt_LoadSelf: TBitBtn
      Left = 427
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 6
      OnClick = Bt_LoadSelfClick
      ExplicitLeft = 423
    end
    object Bt_PasteEstimate: TBitBtn
      Left = 396
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 7
      OnClick = Bt_PasteEstimateClick
      ExplicitLeft = 392
    end
    object Bt_CopyEstimate: TBitBtn
      Left = 365
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 8
      Visible = False
      OnClick = Bt_CopyEstimateClick
      ExplicitLeft = 361
    end
  end
  inherited pnl_Bottom: TPanel
    Width = 747
    ExplicitTop = 353
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
    Height = 320
    ExplicitTop = 33
    ExplicitWidth = 743
    ExplicitHeight = 320
    inherited DBGridEh1: TDBGridEh
      Width = 747
      Height = 320
      OnGetCellParams = DBGridEh1GetCellParams
      OnKeyDown = DBGridEh1KeyDown
    end
  end
end
