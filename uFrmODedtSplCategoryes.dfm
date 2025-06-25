inherited FrmODedtSplCategoryes: TFrmODedtSplCategoryes
  Caption = 'FrmODedtSplCategoryes'
  ClientHeight = 126
  ClientWidth = 585
  ExplicitWidth = 597
  ExplicitHeight = 164
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 585
    Height = 110
    ExplicitWidth = 848
    ExplicitHeight = 400
    inherited PMDIClient: TPanel
      Width = 575
      Height = 61
      ExplicitWidth = 838
      ExplicitHeight = 351
      object E_UserNames: TDBEditEh
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
            OnClick = E_UserNamesEditButtons0Click
          end>
        ReadOnly = True
        TabOrder = 0
        Visible = True
      end
      object E_Name: TDBEditEh
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
    inherited PDlgPanel: TPanel
      Top = 66
      Width = 575
      ExplicitTop = 356
      ExplicitWidth = 838
      inherited BvDlg: TBevel
        Width = 573
      end
      inherited BvDlgBottom: TBevel
        Width = 573
      end
      inherited PDlgMain: TPanel
        Width = 573
        ExplicitWidth = 836
        inherited PDlgBtnForm: TPanel
          Left = 474
          ExplicitLeft = 737
        end
        inherited PDlgChb: TPanel
          Left = 246
          ExplicitLeft = 509
        end
        inherited PDlgBtnR: TPanel
          Left = 375
          ExplicitLeft = 638
        end
        inherited PDlgCenter: TPanel
          Width = 106
          ExplicitWidth = 369
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 110
    Width = 585
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited LbStatusBarRight: TLabel
      Left = 493
      Height = 14
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
