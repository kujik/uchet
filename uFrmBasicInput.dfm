inherited FrmBasicInput: TFrmBasicInput
  Caption = 'FrmBasicInput'
  ClientHeight = 159
  ClientWidth = 174
  ExplicitWidth = 190
  ExplicitHeight = 198
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 174
    Height = 143
    ExplicitWidth = 174
    ExplicitHeight = 143
    inherited PMDIClient: TPanel
      Width = 164
      Height = 94
      ExplicitWidth = 164
      ExplicitHeight = 94
    end
    inherited PDlgPanel: TPanel
      Top = 99
      Width = 164
      ExplicitTop = 99
      ExplicitWidth = 164
      inherited BvDlg: TBevel
        Width = 162
        ExplicitWidth = 389
      end
      inherited BvDlgBottom: TBevel
        Width = 162
        ExplicitWidth = 389
      end
      inherited PDlgMain: TPanel
        Width = 162
        ExplicitWidth = 162
        inherited PDlgBtnForm: TPanel
          Left = 63
          ExplicitLeft = 63
        end
        inherited PDlgChb: TPanel
          Left = -165
          ExplicitLeft = -165
        end
        inherited PDlgBtnR: TPanel
          Left = -36
          ExplicitLeft = -36
        end
        inherited PDlgCenter: TPanel
          Width = 11
          ExplicitWidth = 11
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 143
    Width = 174
    ExplicitTop = 143
    ExplicitWidth = 174
    inherited LbStatusBarRight: TLabel
      Left = 82
      Height = 13
      ExplicitLeft = 82
    end
    inherited LbStatusBarLeft: TLabel
      Height = 13
    end
  end
end
