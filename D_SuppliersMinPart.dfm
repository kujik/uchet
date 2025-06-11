inherited Dlg_SuppliersMinPart: TDlg_SuppliersMinPart
  Caption = 'Dlg_SuppliersMinPart'
  ClientHeight = 247
  ClientWidth = 748
  ExplicitWidth = 754
  ExplicitHeight = 276
  PixelsPerInch = 96
  TextHeight = 13
  inherited P_StatusBar: TPanel
    Top = 228
    Width = 748
    ExplicitTop = 228
    ExplicitWidth = 748
    inherited Lb_StatusBar_Right: TLabel
      Left = 659
      Height = 17
      ExplicitLeft = 659
    end
    inherited Lb_StatusBar_Left: TLabel
      Height = 17
    end
  end
  inherited P_Buttons: TPanel
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
    inherited Chb_NoClose: TCheckBox
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
  inherited P_Bottom: TPanel
    Top = 170
    Width = 748
    ExplicitTop = 170
    ExplicitWidth = 748
  end
  inherited P_Top: TPanel
    Width = 748
    ExplicitWidth = 748
    object Lb_Caption: TLabel
      Left = 8
      Top = 6
      Width = 54
      Height = 13
      Caption = 'Lb_Caption'
    end
  end
  inherited P_Client: TPanel
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
