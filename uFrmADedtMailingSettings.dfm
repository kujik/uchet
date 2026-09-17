inherited FrmADedtMailingSettings: TFrmADedtMailingSettings
  Caption = 'FrmADedtMailingSettings'
  ClientHeight = 473
  ClientWidth = 886
  ExplicitWidth = 898
  ExplicitHeight = 511
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 886
    Height = 457
    ExplicitWidth = 882
    ExplicitHeight = 456
    inherited pnlFrmClient: TPanel
      Width = 876
      Height = 408
      ExplicitWidth = 872
      ExplicitHeight = 407
      object sbxClient: TScrollBox
        Left = 0
        Top = 0
        Width = 876
        Height = 408
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        TabOrder = 0
        ExplicitWidth = 872
        ExplicitHeight = 407
        object pnlClient: TPanel
          Left = 0
          Top = 0
          Width = 876
          Height = 408
          BevelOuter = bvNone
          TabOrder = 0
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 413
      Width = 886
      ExplicitTop = 412
      ExplicitWidth = 882
      inherited bvlFrmBtnsTl: TBevel
        Width = 884
        ExplicitWidth = 884
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 884
        ExplicitWidth = 884
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 884
        ExplicitWidth = 880
        inherited pnlFrmBtnsMain: TPanel
          Left = 785
          ExplicitLeft = 781
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 557
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 686
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 417
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 457
    Width = 886
    ExplicitTop = 456
    ExplicitWidth = 882
    inherited lblStatusBarR: TLabel
      Left = 813
      Height = 14
      ExplicitLeft = 813
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Top = 420
  end
end
