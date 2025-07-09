inherited Dlg_NewEstimateInput: TDlg_NewEstimateInput
  Caption = 'Dlg_NewEstimateInput'
  TextHeight = 13
  inherited pnl_Buttons: TPanel
    inherited chb_NoClose: TCheckBox
      Left = 257
      Top = 6
      ExplicitLeft = 253
      ExplicitTop = 6
    end
    object Bt_Load: TBitBtn
      Left = 482
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 5
      OnClick = Bt_LoadClick
      ExplicitLeft = 478
    end
    object Bt_LoadSelf: TBitBtn
      Left = 451
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 6
      OnClick = Bt_LoadSelfClick
      ExplicitLeft = 447
    end
    object Bt_PasteEstimate: TBitBtn
      Left = 420
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 7
      OnClick = Bt_PasteEstimateClick
      ExplicitLeft = 416
    end
    object Bt_CopyEstimate: TBitBtn
      Left = 389
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 8
      Visible = False
      OnClick = Bt_CopyEstimateClick
      ExplicitLeft = 385
    end
  end
  inherited pnl_Top: TPanel
    Height = 33
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
    Height = 323
    ExplicitTop = 33
    ExplicitHeight = 322
    inherited DBGridEh1: TDBGridEh
      Height = 323
      OnGetCellParams = DBGridEh1GetCellParams
      OnKeyDown = DBGridEh1KeyDown
    end
  end
end
