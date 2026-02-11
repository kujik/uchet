inherited FrmBasicDbDialog: TFrmBasicDbDialog
  Caption = 'FrmBasicDbDialog'
  ClientHeight = 114
  ClientWidth = 233
  ExplicitWidth = 249
  ExplicitHeight = 153
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 233
    Height = 98
    ExplicitWidth = 237
    ExplicitHeight = 99
    inherited pnlFrmClient: TPanel
      Width = 227
      Height = 50
      ExplicitWidth = 838
      ExplicitHeight = 351
    end
    inherited pnlFrmBtns: TPanel
      Top = 55
      Width = 227
      ExplicitTop = 55
      ExplicitWidth = 227
      inherited bvlFrmBtnsTl: TBevel
        Width = 225
        ExplicitWidth = 848
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 225
        ExplicitWidth = 848
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 225
        ExplicitWidth = 225
        inherited pnlFrmBtnsMain: TPanel
          Left = 126
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -102
          ExplicitLeft = -102
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 27
          ExplicitLeft = 638
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 6
          ExplicitWidth = 369
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 98
    Width = 233
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 176
      ExplicitLeft = 176
    end
  end
end
