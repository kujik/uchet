inherited FrmBasicDbDialog: TFrmBasicDbDialog
  Caption = 'FrmBasicDbDialog'
  ClientHeight = 113
  ClientWidth = 229
  ExplicitWidth = 245
  ExplicitHeight = 152
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 229
    Height = 97
    ExplicitWidth = 233
    ExplicitHeight = 98
    inherited pnlFrmClient: TPanel
      Width = 223
      Height = 49
      ExplicitWidth = 838
      ExplicitHeight = 351
    end
    inherited pnlFrmBtns: TPanel
      Top = 54
      Width = 223
      ExplicitTop = 54
      ExplicitWidth = 223
      inherited bvlFrmBtnsTl: TBevel
        Width = 221
        ExplicitWidth = 848
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 221
        ExplicitWidth = 848
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 221
        ExplicitWidth = 221
        inherited pnlFrmBtnsMain: TPanel
          Left = 122
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -106
          ExplicitLeft = -106
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 23
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
    Top = 97
    Width = 229
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 176
      Height = 13
      ExplicitLeft = 176
    end
    inherited lblStatusBarL: TLabel
      Height = 13
    end
  end
end
