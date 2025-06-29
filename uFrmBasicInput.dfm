inherited FrmBasicInput: TFrmBasicInput
  Caption = 'FrmBasicInput'
  ClientHeight = 159
  ClientWidth = 174
  ExplicitWidth = 190
  ExplicitHeight = 198
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 174
    Height = 143
    ExplicitWidth = 174
    ExplicitHeight = 143
    inherited pnlFrmClient: TPanel
      Width = 164
      Height = 94
      ExplicitWidth = 164
      ExplicitHeight = 94
    end
    inherited pnlFrmBtns: TPanel
      Top = 99
      Width = 164
      ExplicitTop = 99
      ExplicitWidth = 164
      inherited bvlFrmBtnsTl: TBevel
        Width = 162
        ExplicitWidth = 389
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 162
        ExplicitWidth = 389
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 162
        ExplicitWidth = 162
        inherited pnlFrmBtnsMain: TPanel
          Left = 63
          ExplicitLeft = 63
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -165
          ExplicitLeft = -165
        end
        inherited pnlFrmBtnsR: TPanel
          Left = -36
          ExplicitLeft = -36
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 11
          ExplicitWidth = 11
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 143
    Width = 174
    ExplicitTop = 143
    ExplicitWidth = 174
    inherited lblStatusBarR: TLabel
      Left = 82
      Height = 13
      ExplicitLeft = 82
    end
    inherited lblStatusBarL: TLabel
      Height = 13
    end
  end
end
