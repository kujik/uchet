inherited FrmWDAddTurv: TFrmWDAddTurv
  Caption = 'FrmWDAddTurv'
  ClientHeight = 146
  ClientWidth = 468
  ExplicitWidth = 484
  ExplicitHeight = 185
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 468
    Height = 130
    ExplicitWidth = 468
    ExplicitHeight = 130
    inherited pnlFrmClient: TPanel
      Width = 462
      Height = 82
      ExplicitWidth = 458
      ExplicitHeight = 81
      object lbl_AllCreated: TLabel
        Left = 92
        Top = 62
        Width = 129
        Height = 13
        Caption = #1042#1089#1077' '#1090#1072#1073#1077#1083#1080' '#1091#1078#1077' '#1089#1086#1079#1076#1072#1085#1099'!'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object cmb_Division: TDBComboBoxEh
        Left = 93
        Top = 35
        Width = 373
        Height = 21
        ControlLabel.Width = 80
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Visible = True
      end
      object cmb_Period: TDBComboBoxEh
        Left = 92
        Top = 8
        Width = 373
        Height = 21
        ControlLabel.Width = 38
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1077#1088#1080#1086#1076
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
        OnChange = cmb_PeriodChange
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 87
      Width = 462
      ExplicitTop = 86
      ExplicitWidth = 458
      inherited bvlFrmBtnsTl: TBevel
        Width = 460
        ExplicitWidth = 464
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 460
        ExplicitWidth = 464
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 460
        ExplicitWidth = 456
        inherited pnlFrmBtnsMain: TPanel
          Left = 361
          ExplicitLeft = 357
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 133
          ExplicitLeft = 129
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 262
          ExplicitLeft = 258
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 0
          ExplicitWidth = 0
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 130
    Width = 468
    ExplicitTop = 130
    ExplicitWidth = 468
    inherited lblStatusBarR: TLabel
      Left = 399
      ExplicitLeft = 399
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 40
    Top = 360
  end
end
