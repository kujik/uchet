inherited FrmWDedtPayrollCalcMethod: TFrmWDedtPayrollCalcMethod
  Caption = 'FrmWDedtPayrollCalcMethod'
  ClientHeight = 218
  ClientWidth = 294
  ExplicitWidth = 306
  ExplicitHeight = 256
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 294
    Height = 202
    ExplicitWidth = 266
    ExplicitHeight = 81
    inherited pnlFrmClient: TPanel
      Width = 284
      Height = 153
      object rgOvertime: TRadioGroup
        Left = 0
        Top = 73
        Width = 284
        Height = 72
        Align = alTop
        Caption = #1056#1072#1089#1095#1077#1090' '#1087#1077#1088#1077#1088#1072#1073#1086#1090#1086#1082
        TabOrder = 0
        OnClick = rgOvertimeClick
        ExplicitWidth = 331
      end
      object rgMethod: TRadioGroup
        Left = 0
        Top = 0
        Width = 284
        Height = 73
        Align = alTop
        Caption = #1052#1077#1090#1086#1076' '#1088#1072#1089#1095#1077#1090#1072
        TabOrder = 1
        OnClick = rgMethodClick
        ExplicitWidth = 582
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 158
      Width = 284
      ExplicitTop = 37
      ExplicitWidth = 256
      inherited bvlFrmBtnsTl: TBevel
        Width = 282
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 282
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 282
        ExplicitWidth = 254
        inherited pnlFrmBtnsMain: TPanel
          Left = 183
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -45
          ExplicitLeft = -73
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 84
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 4
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 202
    Width = 294
    inherited lblStatusBarR: TLabel
      Left = 221
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 80
    Top = 216
  end
end
