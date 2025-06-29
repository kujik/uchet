inherited FrmODedtSplCategoryes: TFrmODedtSplCategoryes
  Caption = 'FrmODedtSplCategoryes'
  ClientHeight = 126
  ClientWidth = 585
  ExplicitWidth = 597
  ExplicitHeight = 164
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 585
    Height = 110
    ExplicitWidth = 848
    ExplicitHeight = 400
    inherited pnlFrmClient: TPanel
      Width = 575
      Height = 61
      ExplicitWidth = 838
      ExplicitHeight = 351
      object edt_UserNames: TDBEditEh
        Left = 83
        Top = 35
        Width = 488
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
      Top = 66
      Width = 575
      ExplicitTop = 356
      ExplicitWidth = 838
      inherited bvlFrmBtnsTl: TBevel
        Width = 573
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 573
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 573
        ExplicitWidth = 836
        inherited pnlFrmBtnsMain: TPanel
          Left = 474
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 246
          ExplicitLeft = 509
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 375
          ExplicitLeft = 638
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 106
          ExplicitWidth = 369
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 110
    Width = 585
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 493
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
