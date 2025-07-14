inherited FrmODedtSplCategoryes: TFrmODedtSplCategoryes
  Caption = 'FrmODedtSplCategoryes'
  ClientHeight = 125
  ClientWidth = 581
  ExplicitWidth = 597
  ExplicitHeight = 164
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 581
    Height = 109
    ExplicitWidth = 581
    ExplicitHeight = 109
    inherited pnlFrmClient: TPanel
      Width = 575
      Height = 61
      ExplicitWidth = 571
      ExplicitHeight = 60
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
        ExplicitWidth = 484
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
      ExplicitTop = 65
      ExplicitWidth = 571
      inherited bvlFrmBtnsTl: TBevel
        Width = 573
        ExplicitWidth = 573
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 573
        ExplicitWidth = 573
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 573
        ExplicitWidth = 569
        inherited pnlFrmBtnsMain: TPanel
          Left = 474
          ExplicitLeft = 470
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 246
          ExplicitLeft = 242
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 375
          ExplicitLeft = 371
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 106
          ExplicitWidth = 102
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 109
    Width = 581
    ExplicitTop = 109
    ExplicitWidth = 581
    inherited lblStatusBarR: TLabel
      Left = 512
      ExplicitLeft = 512
    end
  end
end
