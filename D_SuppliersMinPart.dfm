inherited Dlg_SuppliersMinPart: TDlg_SuppliersMinPart
  Caption = 'Dlg_SuppliersMinPart'
  ClientHeight = 245
  ClientWidth = 740
  ExplicitWidth = 756
  ExplicitHeight = 284
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 226
    Width = 740
    ExplicitTop = 226
    ExplicitWidth = 740
    inherited lbl_StatusBar_Right: TLabel
      Left = 657
      ExplicitLeft = 657
    end
  end
  inherited pnl_Buttons: TPanel
    Top = 193
    Width = 740
    ExplicitTop = 193
    ExplicitWidth = 740
    inherited Bev_Buttons: TBevel
      Left = 556
      ExplicitLeft = 572
    end
    inherited Bt_OK: TBitBtn
      Left = 565
      ExplicitLeft = 561
    end
    inherited Bt_Cancel: TBitBtn
      Left = 646
      ExplicitLeft = 642
    end
    inherited chb_NoClose: TCheckBox
      Left = 350
      ExplicitLeft = 346
    end
    inherited Bt_Add: TBitBtn
      Left = 494
      ExplicitLeft = 490
    end
    inherited Bt_Del: TBitBtn
      Left = 525
      ExplicitLeft = 521
    end
  end
  inherited pnl_Bottom: TPanel
    Top = 168
    Width = 740
    ExplicitTop = 168
    ExplicitWidth = 740
  end
  inherited pnl_Top: TPanel
    Width = 740
    ExplicitWidth = 740
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
    ExplicitWidth = 740
    ExplicitHeight = 143
    inherited DBGridEh1: TDBGridEh
      Width = 744
      Height = 144
      OnDblClick = DBGridEh1DblClick
      OnKeyDown = DBGridEh1KeyDown
    end
  end
end
