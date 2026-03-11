inherited FrmWDedtCreatePayrollN: TFrmWDedtCreatePayrollN
  Caption = 'FrmWDedtCreatePayrollN'
  ClientHeight = 208
  ClientWidth = 499
  ExplicitWidth = 511
  ExplicitHeight = 246
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 499
    Height = 192
    ExplicitWidth = 495
    ExplicitHeight = 191
    inherited pnlFrmClient: TPanel
      Width = 489
      Height = 143
      ExplicitWidth = 485
      ExplicitHeight = 142
      object pgcMain: TPageControl
        Left = 0
        Top = 0
        Width = 489
        Height = 201
        ActivePage = ts_Divisions
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 485
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
      Top = 148
      Width = 489
      ExplicitTop = 147
      ExplicitWidth = 485
      inherited bvlFrmBtnsTl: TBevel
        Width = 487
        ExplicitWidth = 343
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 487
        ExplicitWidth = 343
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 487
        ExplicitWidth = 483
        inherited pnlFrmBtnsMain: TPanel
          Left = 388
          ExplicitLeft = 384
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 160
          ExplicitLeft = 156
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 289
          ExplicitLeft = 285
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 20
          ExplicitWidth = 16
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 192
    Width = 499
    ExplicitTop = 191
    ExplicitWidth = 495
    inherited lblStatusBarR: TLabel
      Left = 426
      Height = 14
      ExplicitLeft = 426
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
