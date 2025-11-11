inherited FrmBasicDbDialog: TFrmBasicDbDialog
  Caption = 'FrmBasicDbDialog'
  ClientHeight = 116
  ClientWidth = 241
  ExplicitWidth = 257
  ExplicitHeight = 155
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 241
    Height = 100
    ExplicitWidth = 245
    ExplicitHeight = 101
    inherited pnlFrmClient: TPanel
      Width = 235
      Height = 52
      ExplicitWidth = 838
      ExplicitHeight = 351
    end
    inherited pnlFrmBtns: TPanel
      Top = 57
      Width = 235
      ExplicitTop = 57
      ExplicitWidth = 235
      inherited bvlFrmBtnsTl: TBevel
        Width = 233
        ExplicitWidth = 848
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 233
        ExplicitWidth = 848
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 233
        ExplicitWidth = 233
        inherited pnlFrmBtnsMain: TPanel
          Left = 134
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -94
          ExplicitLeft = -94
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 35
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
    Top = 100
    Width = 241
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 176
      ExplicitLeft = 176
    end
  end
end
