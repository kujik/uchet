inherited Dlg_SuppliersMinPart: TDlg_SuppliersMinPart
  Caption = 'Dlg_SuppliersMinPart'
  ClientHeight = 247
  ClientWidth = 748
  ExplicitWidth = 764
  ExplicitHeight = 286
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 228
    Width = 748
    ExplicitTop = 228
    ExplicitWidth = 748
    inherited lbl_StatusBar_Right: TLabel
      Left = 659
      ExplicitLeft = 659
    end
  end
  inherited pnl_Buttons: TPanel
    Top = 195
    Width = 748
    ExplicitTop = 195
    ExplicitWidth = 748
    inherited Bev_Buttons: TBevel
      Left = 572
      ExplicitLeft = 572
    end
    inherited Bt_OK: TBitBtn
      Left = 581
      ExplicitLeft = 581
    end
    inherited Bt_Cancel: TBitBtn
      Left = 662
      ExplicitLeft = 662
    end
    inherited chb_NoClose: TCheckBox
      Left = 366
      ExplicitLeft = 366
    end
    inherited Bt_Add: TBitBtn
      Left = 510
      ExplicitLeft = 510
    end
    inherited Bt_Del: TBitBtn
      Left = 541
      ExplicitLeft = 541
    end
  end
  inherited pnl_Bottom: TPanel
    Top = 170
    Width = 748
    ExplicitTop = 170
    ExplicitWidth = 748
  end
  inherited pnl_Top: TPanel
    Width = 748
    ExplicitWidth = 748
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
    ExplicitWidth = 748
    ExplicitHeight = 145
    inherited DBGridEh1: TDBGridEh
      Width = 748
      Height = 145
      OnKeyDown = DBGridEh1KeyDown
    end
  end
end
