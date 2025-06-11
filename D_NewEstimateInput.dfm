inherited Dlg_NewEstimateInput: TDlg_NewEstimateInput
  Caption = 'Dlg_NewEstimateInput'
  PixelsPerInch = 96
  TextHeight = 13
  inherited P_StatusBar: TPanel
    inherited Lb_StatusBar_Right: TLabel
      Height = 17
    end
    inherited Lb_StatusBar_Left: TLabel
      Height = 17
    end
  end
  inherited P_Buttons: TPanel
    inherited Chb_NoClose: TCheckBox
      Left = 261
      Top = 6
      ExplicitLeft = 261
      ExplicitTop = 6
    end
    object Bt_Load: TBitBtn
      Left = 486
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 5
      OnClick = Bt_LoadClick
    end
    object Bt_LoadSelf: TBitBtn
      Left = 455
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 6
      OnClick = Bt_LoadSelfClick
    end
    object Bt_PasteEstimate: TBitBtn
      Left = 424
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 7
      OnClick = Bt_PasteEstimateClick
    end
    object Bt_CopyEstimate: TBitBtn
      Left = 393
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 8
      Visible = False
      OnClick = Bt_CopyEstimateClick
    end
  end
  inherited P_Top: TPanel
    Height = 33
    ExplicitHeight = 33
    object Lb_Caption: TLabel
      Left = 8
      Top = 14
      Width = 54
      Height = 13
      Caption = 'Lb_Caption'
      Color = clBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Lb_Type: TLabel
      Left = 8
      Top = 1
      Width = 42
      Height = 13
      Caption = 'Lb_Type'
    end
  end
  inherited P_Client: TPanel
    Top = 33
    Height = 323
    ExplicitTop = 33
    ExplicitHeight = 323
    inherited DBGridEh1: TDBGridEh
      Height = 323
      OnGetCellParams = DBGridEh1GetCellParams
      OnKeyDown = DBGridEh1KeyDown
    end
  end
end
