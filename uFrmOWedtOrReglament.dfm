inherited FrmOWedtOrReglament: TFrmOWedtOrReglament
  Caption = 'FrmOWedtOrReglament'
  ClientHeight = 572
  ClientWidth = 1058
  ExplicitWidth = 1070
  ExplicitHeight = 610
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1058
    Height = 556
    ExplicitWidth = 266
    ExplicitHeight = 81
    inherited pnlFrmClient: TPanel
      Width = 1048
      Height = 507
    end
    inherited pnlFrmBtns: TPanel
      Top = 512
      Width = 1048
      ExplicitTop = 37
      ExplicitWidth = 256
      inherited bvlFrmBtnsTl: TBevel
        Width = 1046
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1046
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1046
        ExplicitWidth = 254
        inherited pnlFrmBtnsMain: TPanel
          Left = 947
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 719
          ExplicitLeft = -73
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 848
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 579
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 556
    Width = 1058
    inherited lblStatusBarR: TLabel
      Left = 985
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 264
    Top = 520
  end
end
