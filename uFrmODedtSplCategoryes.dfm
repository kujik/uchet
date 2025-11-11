inherited FrmODedtSplCategoryes: TFrmODedtSplCategoryes
  Caption = 'FrmODedtSplCategoryes'
  ClientHeight = 123
  ClientWidth = 573
  ExplicitWidth = 589
  ExplicitHeight = 162
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 573
    Height = 107
    ExplicitWidth = 573
    ExplicitHeight = 107
    inherited pnlFrmClient: TPanel
      Width = 567
      Height = 59
      ExplicitWidth = 563
      ExplicitHeight = 58
      object edt_UserNames: TDBEditEh
        Left = 83
        Top = 35
        Width = 480
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 37
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1086#1089#1090#1091#1087
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <
          item
            OnClick = edt_UserNamesEditButtons0Click
          end>
        ReadOnly = True
        TabOrder = 0
        Visible = True
        ExplicitWidth = 476
      end
      object edt_name: TDBEditEh
        Left = 83
        Top = 8
        Width = 270
        Height = 21
        ControlLabel.Width = 73
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 64
      Width = 567
      ExplicitTop = 63
      ExplicitWidth = 563
      inherited bvlFrmBtnsTl: TBevel
        Width = 565
        ExplicitWidth = 573
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 565
        ExplicitWidth = 573
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 565
        ExplicitWidth = 561
        inherited pnlFrmBtnsMain: TPanel
          Left = 466
          ExplicitLeft = 462
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 238
          ExplicitLeft = 234
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 367
          ExplicitLeft = 363
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 98
          ExplicitWidth = 94
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 107
    Width = 573
    ExplicitTop = 107
    ExplicitWidth = 573
    inherited lblStatusBarR: TLabel
      Left = 504
      ExplicitLeft = 504
    end
  end
end
