inherited Dlg_SuppliersMinPart: TDlg_SuppliersMinPart
  Caption = 'Dlg_SuppliersMinPart'
  ClientHeight = 247
  ClientWidth = 748
  ExplicitWidth = 760
  ExplicitHeight = 285
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 228
    Width = 748
    ExplicitTop = 227
    ExplicitWidth = 744
    inherited lbl_StatusBar_Right: TLabel
      Left = 661
      Height = 17
      ExplicitLeft = 661
    end
    inherited lbl_StatusBar_Left: TLabel
      Height = 17
    end
  end
  inherited pnl_Buttons: TPanel
    Top = 195
    Width = 748
    ExplicitTop = 194
    ExplicitWidth = 744
    inherited Bev_Buttons: TBevel
      Left = 568
      ExplicitLeft = 572
    end
    inherited Bt_OK: TBitBtn
      Left = 577
      ExplicitLeft = 573
    end
    inherited Bt_Cancel: TBitBtn
      Left = 658
      ExplicitLeft = 654
    end
    inherited chb_NoClose: TCheckBox
      Left = 362
      ExplicitLeft = 358
    end
    inherited Bt_Add: TBitBtn
      Left = 506
      ExplicitLeft = 502
    end
    inherited Bt_Del: TBitBtn
      Left = 537
      ExplicitLeft = 533
    end
  end
  inherited pnl_Bottom: TPanel
    Top = 170
    Width = 748
    ExplicitTop = 169
    ExplicitWidth = 744
  end
  inherited pnl_Top: TPanel
    Width = 748
    ExplicitWidth = 744
    object lbl_Caption: TLabel
      Left = 8
      Top = 6
      Width = 52
      Height = 13
      Caption = 'lbl_Caption'
    end
  end
  inherited pnl_Client: TPanel
    Width = 748
    Height = 145
    ExplicitWidth = 744
    ExplicitHeight = 144
    inherited DBGridEh1: TDBGridEh
      Width = 748
      Height = 145
      OnKeyDown = DBGridEh1KeyDown
    end
  end
end
