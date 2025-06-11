inherited FrmXDedtMemo: TFrmXDedtMemo
  Caption = 'FrmXDedtMemo'
  ClientHeight = 304
  ClientWidth = 604
  ExplicitWidth = 620
  ExplicitHeight = 343
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 604
    Height = 288
    ExplicitWidth = 604
    ExplicitHeight = 288
    inherited PMDIClient: TPanel
      Width = 594
      Height = 239
      ExplicitWidth = 594
      ExplicitHeight = 239
      object PCaption: TPanel
        Left = 0
        Top = 0
        Width = 594
        Height = 25
        Align = alTop
        Caption = 'PCaption'
        TabOrder = 0
        object LbCaption: TLabel
          Left = 9
          Top = 6
          Width = 48
          Height = 13
          Caption = 'LbCaption'
        end
      end
      object MMain: TDBMemoEh
        Left = 0
        Top = 25
        Width = 594
        Height = 214
        Lines.Strings = (
          'M_Main')
        Align = alClient
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
        WantReturns = True
      end
    end
    inherited PDlgPanel: TPanel
      Top = 244
      Width = 594
      ExplicitTop = 244
      ExplicitWidth = 594
      inherited BvDlg: TBevel
        Width = 592
        ExplicitWidth = 592
      end
      inherited BvDlgBottom: TBevel
        Width = 592
        ExplicitWidth = 592
      end
      inherited PDlgMain: TPanel
        Width = 592
        ExplicitWidth = 592
        inherited PDlgBtnForm: TPanel
          Left = 493
          ExplicitLeft = 493
        end
        inherited PDlgChb: TPanel
          Left = 265
          ExplicitLeft = 265
        end
        inherited PDlgBtnR: TPanel
          Left = 394
          ExplicitLeft = 394
        end
        inherited PDlgCenter: TPanel
          Width = 125
          ExplicitWidth = 125
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 288
    Width = 604
    ExplicitTop = 288
    ExplicitWidth = 604
    inherited LbStatusBarRight: TLabel
      Left = 512
      Height = 14
      ExplicitLeft = 512
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
  inherited Timer_AfterStart: TTimer
    Top = 248
  end
end
