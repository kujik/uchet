inherited Dlg_SuppliersMinPart: TDlg_SuppliersMinPart
  Caption = 'Dlg_SuppliersMinPart'
  ClientHeight = 245
  ClientWidth = 740
  ExplicitWidth = 752
  ExplicitHeight = 283
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 226
    Width = 740
    ExplicitTop = 225
    ExplicitWidth = 736
    inherited lbl_StatusBar_Right: TLabel
      Left = 653
      Height = 17
      ExplicitLeft = 653
    end
    inherited lbl_StatusBar_Left: TLabel
      Height = 17
    end
  end
  inherited pnl_Buttons: TPanel
    Top = 193
    Width = 740
    ExplicitTop = 192
    ExplicitWidth = 736
    inherited Bev_Buttons: TBevel
      Left = 552
      ExplicitLeft = 572
    end
    inherited Bt_OK: TBitBtn
      Left = 561
      ExplicitLeft = 557
    end
    inherited Bt_Cancel: TBitBtn
      Left = 642
      ExplicitLeft = 638
    end
    inherited chb_NoClose: TCheckBox
      Left = 346
      ExplicitLeft = 342
    end
    inherited Bt_Add: TBitBtn
      Left = 490
      ExplicitLeft = 486
    end
    inherited Bt_Del: TBitBtn
      Left = 521
      ExplicitLeft = 517
    end
  end
  inherited pnl_Bottom: TPanel
    Top = 168
    Width = 740
    ExplicitTop = 167
    ExplicitWidth = 736
  end
  inherited pnl_Top: TPanel
    Width = 740
    ExplicitWidth = 736
    object lbl_Caption: TLabel
      Left = 8
      Top = 6
      Width = 52
      Height = 13
      Caption = 'lbl_Caption'
    end
  end
  inherited pnl_Client: TPanel
    Width = 740
    Height = 143
    ExplicitWidth = 736
    ExplicitHeight = 142
    inherited DBGridEh1: TDBGridEh
      Width = 740
      Height = 143
      OnDblClick = DBGridEh1DblClick
      OnKeyDown = DBGridEh1KeyDown
    end
  end
end
