inherited FrmXWGridAdminOptions: TFrmXWGridAdminOptions
  BorderStyle = bsDialog
  Caption = 'FrmXWGridAdminOptions'
  ClientHeight = 585
  ClientWidth = 1022
  ExplicitWidth = 1038
  ExplicitHeight = 624
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 954
    Top = 554
    Width = 75
    Height = 25
    Caption = #1054#1082
    ModalResult = 1
    TabOrder = 0
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1022
    Height = 548
    Align = alTop
    TabOrder = 1
    object DBGridEh1: TDBGridEh
      Left = 1
      Top = 1
      Width = 1024
      Height = 546
      Align = alClient
      DynProps = <>
      TabOrder = 0
      object RowDetailData: TRowDetailPanelControlEh
      end
    end
  end
end
