inherited FrmOWedtSetOrderRoute: TFrmOWedtSetOrderRoute
  Caption = 'FrmOWedtSetOrderRoute'
  ClientHeight = 348
  ClientWidth = 837
  ExplicitWidth = 849
  ExplicitHeight = 386
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 837
    Height = 332
    ExplicitWidth = 833
    ExplicitHeight = 331
    inherited pnlFrmClient: TPanel
      Width = 827
      Height = 283
      ExplicitWidth = 823
      ExplicitHeight = 282
      object chb_R0: TDBCheckBoxEh
        Left = 9
        Top = 7
        Width = 95
        Height = 17
        Caption = #1041#1077#1079' '#1084#1072#1088#1096#1088#1091#1090#1072
        DynProps = <>
        TabOrder = 0
      end
      object chb_Wo_Estimate: TDBCheckBoxEh
        Left = 110
        Top = 7
        Width = 82
        Height = 17
        Caption = #1041#1077#1079' '#1089#1084#1077#1090#1099
        DynProps = <>
        TabOrder = 1
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 288
      Width = 827
      ExplicitTop = 287
      ExplicitWidth = 823
      inherited bvlFrmBtnsTl: TBevel
        Width = 825
        ExplicitWidth = 768
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 825
        ExplicitWidth = 768
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 825
        ExplicitWidth = 821
        inherited pnlFrmBtnsMain: TPanel
          Left = 726
          ExplicitLeft = 722
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 498
          ExplicitLeft = 494
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 627
          ExplicitLeft = 623
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 358
          ExplicitWidth = 354
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 332
    Width = 837
    ExplicitTop = 331
    ExplicitWidth = 833
    inherited lblStatusBarR: TLabel
      Left = 764
      Height = 14
      ExplicitLeft = 764
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 168
    Top = 256
  end
end
