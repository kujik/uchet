inherited Dlg_NewEstimateInput: TDlg_NewEstimateInput
  Caption = 'Dlg_NewEstimateInput'
  ClientHeight = 432
  ExplicitWidth = 755
  ExplicitHeight = 470
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 413
    ExplicitTop = 412
    ExplicitWidth = 739
    inherited lbl_StatusBar_Right: TLabel
      Left = 656
      Height = 17
    end
    inherited lbl_StatusBar_Left: TLabel
      Height = 17
    end
  end
  inherited pnl_Buttons: TPanel
    Top = 380
    ExplicitWidth = 739
    inherited chb_NoClose: TCheckBox
      Left = 245
      Top = 6
      ExplicitLeft = 241
      ExplicitTop = 6
    end
    object Bt_Load: TBitBtn
      Left = 470
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 5
      OnClick = Bt_LoadClick
      ExplicitLeft = 466
    end
    object Bt_LoadSelf: TBitBtn
      Left = 439
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 6
      OnClick = Bt_LoadSelfClick
      ExplicitLeft = 435
    end
    object Bt_PasteEstimate: TBitBtn
      Left = 408
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 7
      OnClick = Bt_PasteEstimateClick
      ExplicitLeft = 404
    end
    object Bt_CopyEstimate: TBitBtn
      Left = 377
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 8
      Visible = False
      OnClick = Bt_CopyEstimateClick
      ExplicitLeft = 373
    end
  end
  inherited pnl_Bottom: TPanel
    Top = 355
    ExplicitTop = 354
    ExplicitWidth = 739
  end
  inherited pnl_Top: TPanel
    Height = 33
    ExplicitWidth = 739
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
    Height = 322
    ExplicitTop = 33
    ExplicitWidth = 739
    ExplicitHeight = 321
    inherited DBGridEh1: TDBGridEh
      Width = 743
      Height = 322
      OnGetCellParams = DBGridEh1GetCellParams
      OnKeyDown = DBGridEh1KeyDown
    end
  end
end
