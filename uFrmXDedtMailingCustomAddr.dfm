inherited FrmXDedtMailingCustomAddr: TFrmXDedtMailingCustomAddr
  Caption = 'FrmXDedtMailingCustomAddr'
  ClientHeight = 121
  ClientWidth = 632
  ExplicitWidth = 648
  ExplicitHeight = 160
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 632
    Height = 105
    ExplicitWidth = 632
    ExplicitHeight = 105
    inherited pnlFrmClient: TPanel
      Width = 626
      Height = 57
      ExplicitWidth = 622
      ExplicitHeight = 56
      object edtAddr: TDBEditEh
        Left = 8
        Top = 24
        Width = 611
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 307
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1074#1077#1076#1080#1090#1077' '#1072#1076#1088#1077#1089#1072' '#1101#1083#1077#1082#1090#1088#1086#1085#1085#1086#1081' '#1087#1086#1095#1090#1099', '#1088#1072#1079#1076#1077#1083#1103#1103' '#1080#1093' '#1079#1072#1087#1103#1090#1099#1084#1080
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Text = 'edtAddr'
        Visible = True
        ExplicitWidth = 607
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 62
      Width = 626
      ExplicitTop = 61
      ExplicitWidth = 622
      inherited bvlFrmBtnsTl: TBevel
        Width = 624
        ExplicitWidth = 624
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 624
        ExplicitWidth = 624
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 624
        ExplicitWidth = 620
        inherited pnlFrmBtnsMain: TPanel
          Left = 525
          ExplicitLeft = 521
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 297
          ExplicitLeft = 293
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 426
          ExplicitLeft = 422
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 157
          ExplicitWidth = 153
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 105
    Width = 632
    ExplicitTop = 105
    ExplicitWidth = 632
    inherited lblStatusBarR: TLabel
      Left = 563
      ExplicitLeft = 563
    end
  end
end
