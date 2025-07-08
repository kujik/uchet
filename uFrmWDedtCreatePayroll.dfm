inherited FrmWDedtCreatePayroll: TFrmWDedtCreatePayroll
  Caption = 'FrmWDedtCreatePayroll'
  ClientHeight = 210
  ClientWidth = 355
  ExplicitWidth = 367
  ExplicitHeight = 248
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 355
    Height = 194
    ExplicitWidth = 351
    ExplicitHeight = 193
    inherited pnlFrmClient: TPanel
      Width = 345
      Height = 145
      ExplicitWidth = 341
      ExplicitHeight = 144
      object pgcMain: TPageControl
        Left = 0
        Top = 0
        Width = 345
        Height = 201
        ActivePage = ts_Divisions
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 341
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
          object dedtDt1: TDBDateTimeEditEh
            Left = 57
            Top = 50
            Width = 121
            Height = 21
            ControlLabel.Width = 49
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1077#1088#1080#1086#1076' '#1089' '
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 0
            Visible = True
          end
          object dedtDt2: TDBDateTimeEditEh
            Left = 202
            Top = 50
            Width = 121
            Height = 21
            ControlLabel.Width = 15
            ControlLabel.Height = 13
            ControlLabel.Caption = #1087#1086' '
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 1
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
          object chbPrev: TDBCheckBoxEh
            Left = 3
            Top = 76
            Width = 187
            Height = 17
            Caption = 'chbPrev'
            DynProps = <>
            TabOrder = 1
          end
          object chbCurr: TDBCheckBoxEh
            Left = 3
            Top = 94
            Width = 187
            Height = 17
            Caption = 'chb_Prev'
            DynProps = <>
            TabOrder = 2
          end
          object dedtW: TDBDateTimeEditEh
            Left = 204
            Top = 89
            Width = 121
            Height = 21
            ControlLabel.Width = 49
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1077#1088#1080#1086#1076' '#1089' '
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 3
            Visible = True
          end
          object cmbWorker: TDBComboBoxEh
            Left = 56
            Top = 49
            Width = 271
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
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 150
      Width = 345
      ExplicitTop = 149
      ExplicitWidth = 341
      inherited bvlFrmBtnsTl: TBevel
        Width = 343
        ExplicitWidth = 343
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 343
        ExplicitWidth = 343
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 343
        ExplicitWidth = 339
        inherited pnlFrmBtnsMain: TPanel
          Left = 244
          ExplicitLeft = 240
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 16
          ExplicitLeft = 12
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 145
          ExplicitLeft = 141
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 194
    Width = 355
    ExplicitTop = 193
    ExplicitWidth = 351
    inherited lblStatusBarR: TLabel
      Left = 282
      Height = 14
      ExplicitLeft = 282
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
