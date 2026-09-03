inherited FrmODedtReplaceEstimateItem: TFrmODedtReplaceEstimateItem
  Caption = 'FrmODedtReplaceEstimateItem'
  ClientHeight = 165
  ClientWidth = 411
  ExplicitWidth = 423
  ExplicitHeight = 203
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 411
    Height = 149
    ExplicitWidth = 459
    ExplicitHeight = 90
    inherited pnlFrmClient: TPanel
      Width = 401
      Height = 100
      object edt_1: TDBEditEh
        Left = 8
        Top = 24
        Width = 381
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 124
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1089#1093#1086#1076#1085#1072#1103' '#1085#1086#1084#1077#1085#1082#1083#1072#1090#1091#1088#1072
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <
          item
            Style = ebsPlusEh
            OnClick = edt_1EditButtons0Click
          end>
        TabOrder = 0
        Text = 'edt_1'
        Visible = True
        ExplicitWidth = 389
      end
      object edt_2: TDBEditEh
        Left = 8
        Top = 64
        Width = 381
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 119
        ControlLabel.Height = 13
        ControlLabel.Caption = #1062#1077#1083#1077#1074#1072#1103' '#1085#1086#1084#1077#1085#1082#1083#1072#1090#1091#1088#1072
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <
          item
            Style = ebsPlusEh
            OnClick = edt_2EditButtons0Click
          end>
        TabOrder = 1
        Text = 'edt_2'
        Visible = True
        ExplicitWidth = 389
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 105
      Width = 401
      ExplicitTop = 36
      ExplicitWidth = 449
      inherited bvlFrmBtnsTl: TBevel
        Width = 399
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 399
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 399
        ExplicitWidth = 447
        inherited pnlFrmBtnsMain: TPanel
          Left = 298
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -125
          ExplicitLeft = -77
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 4
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 149
    Width = 411
    inherited lblStatusBarR: TLabel
      Left = 338
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
