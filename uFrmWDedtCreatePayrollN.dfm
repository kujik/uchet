inherited FrmWDedtCreatePayrollN: TFrmWDedtCreatePayrollN
  Caption = 'FrmWDedtCreatePayrollN'
  ClientHeight = 209
  ClientWidth = 503
  ExplicitWidth = 515
  ExplicitHeight = 247
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 503
    Height = 193
    ExplicitWidth = 499
    ExplicitHeight = 192
    inherited pnlFrmClient: TPanel
      Width = 493
      Height = 144
      ExplicitWidth = 489
      ExplicitHeight = 143
      object pgcMain: TPageControl
        Left = 0
        Top = 0
        Width = 493
        Height = 201
        ActivePage = ts_Divisions
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 489
        object ts_Divisions: TTabSheet
          Caption = #1042#1089#1077' '#1087#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1103
          object lbl1: TLabel
            Left = 3
            Top = 8
            Width = 306
            Height = 26
            Caption = 
              #1057#1086#1079#1076#1072#1085#1080#1077' '#1079#1072#1088#1087#1083#1072#1090#1085#1099#1093' '#1074#1077#1076#1086#1084#1086#1089#1090#1077#1081' '#1079#1072' '#1091#1082#1072#1079#1072#1085#1085#1099#1081' '#1087#1077#1088#1080#1086#1076' '#1087#1086' '#1074#1089#1077#1084' '#1087#1086#1076#1088#1072 +
              #1079#1076#1077#1083#1077#1085#1080#1103#1084'.'
            WordWrap = True
          end
          object cmbPeriodD: TDBComboBoxEh
            Left = 54
            Top = 40
            Width = 195
            Height = 21
            ControlLabel.Width = 38
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1077#1088#1080#1086#1076
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Visible = True
          end
        end
        object ts_Worker: TTabSheet
          Caption = #1056#1072#1073#1086#1090#1085#1080#1082
          ImageIndex = 1
          object lbl2: TLabel
            Left = 6
            Top = 11
            Width = 319
            Height = 26
            Caption = 
              #1057#1086#1079#1076#1072#1085#1080#1077' '#1079#1072#1088#1087#1083#1072#1090#1085#1099#1093' '#1074#1077#1076#1086#1084#1086#1089#1090#1077#1081' '#1076#1083#1103' '#1074#1099#1073#1088#1072#1085#1085#1086#1075#1086' '#1088#1072#1073#1086#1090#1085#1080#1082#1072' '#1079#1072' '#1090#1077#1082#1091#1097 +
              #1080#1081' '#1080'/'#1080#1083#1080' '#1087#1088#1077#1076#1099#1076#1091#1097#1080#1081' '#1087#1077#1088#1080#1086#1076'.'
            WordWrap = True
          end
          object cmbWorker: TDBComboBoxEh
            Left = 54
            Top = 68
            Width = 425
            Height = 21
            ControlLabel.Width = 48
            ControlLabel.Height = 13
            ControlLabel.Caption = #1056#1072#1073#1086#1090#1085#1080#1082
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Visible = True
          end
          object cmbPeriodW: TDBComboBoxEh
            Left = 54
            Top = 41
            Width = 195
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
            OnChange = cmbPeriodWChange
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 149
      Width = 493
      ExplicitTop = 148
      ExplicitWidth = 489
      inherited bvlFrmBtnsTl: TBevel
        Width = 491
        ExplicitWidth = 343
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 491
        ExplicitWidth = 343
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 491
        ExplicitWidth = 487
        inherited pnlFrmBtnsMain: TPanel
          Left = 392
          ExplicitLeft = 388
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 164
          ExplicitLeft = 160
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 293
          ExplicitLeft = 289
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 24
          ExplicitWidth = 20
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 193
    Width = 503
    ExplicitTop = 192
    ExplicitWidth = 499
    inherited lblStatusBarR: TLabel
      Left = 430
      Height = 14
      ExplicitLeft = 430
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
