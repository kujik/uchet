inherited FrmWDedtEmployeeProperties: TFrmWDedtEmployeeProperties
  Caption = 'FrmWDedtEmployeeProperties'
  ClientHeight = 425
  ClientWidth = 498
  ExplicitWidth = 510
  ExplicitHeight = 463
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 498
    Height = 409
    ExplicitWidth = 494
    ExplicitHeight = 408
    inherited pnlFrmClient: TPanel
      Width = 488
      Height = 360
      ExplicitWidth = 484
      ExplicitHeight = 359
      object cmb_id_mode: TDBComboBoxEh
        Left = 90
        Top = 8
        Width = 115
        Height = 21
        ControlLabel.Width = 50
        ControlLabel.Height = 13
        ControlLabel.Caption = #1054#1087#1077#1088#1072#1094#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Text = 'cmb_id_mode'
        Visible = True
      end
      object dedt_dt_beg: TDBDateTimeEditEh
        Left = 90
        Top = 35
        Width = 115
        Height = 21
        ControlLabel.Width = 65
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1072#1090#1072' '#1085#1072#1095#1072#1083#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 1
        Visible = True
      end
      object cmb_id_departament: TDBComboBoxEh
        Left = 90
        Top = 62
        Width = 397
        Height = 21
        ControlLabel.Width = 80
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Text = 'DBComboBoxEh1'
        Visible = True
        ExplicitWidth = 393
      end
      object cmb_id_job: TDBComboBoxEh
        Left = 90
        Top = 89
        Width = 397
        Height = 21
        ControlLabel.Width = 55
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1088#1086#1092#1077#1089#1089#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 3
        Text = 'cmb_id_job'
        Visible = True
        ExplicitWidth = 393
      end
      object cmb_id_schedule: TDBComboBoxEh
        Left = 91
        Top = 209
        Width = 113
        Height = 21
        ControlLabel.Width = 79
        ControlLabel.Height = 13
        ControlLabel.Caption = #1043#1088#1072#1092#1080#1082' '#1088#1072#1073#1086#1090#1099
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 4
        Text = 'cmb_id_job'
        Visible = True
      end
      object edt_comm: TDBEditEh
        Left = 89
        Top = 286
        Width = 395
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 67
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 5
        Text = 'DBEditEh1'
        Visible = True
        ExplicitWidth = 391
      end
      object chb_is_trainee: TDBCheckBoxEh
        Left = 92
        Top = 143
        Width = 97
        Height = 17
        Caption = #1059#1095#1077#1085#1080#1082
        DynProps = <>
        TabOrder = 6
      end
      object chb_is_foreman: TDBCheckBoxEh
        Left = 92
        Top = 166
        Width = 97
        Height = 17
        Caption = #1041#1088#1080#1075#1072#1076#1080#1088
        DynProps = <>
        TabOrder = 7
      end
      object chb_is_concurrent: TDBCheckBoxEh
        Left = 92
        Top = 189
        Width = 97
        Height = 17
        Caption = #1057#1086#1074#1084#1077#1089#1090#1080#1090#1077#1083#1100
        DynProps = <>
        TabOrder = 8
      end
      object cmb_id_organization: TDBComboBoxEh
        Left = 91
        Top = 236
        Width = 392
        Height = 21
        ControlLabel.Width = 66
        ControlLabel.Height = 13
        ControlLabel.Caption = #1054#1088#1075#1072#1085#1080#1079#1072#1094#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 9
        Text = 'cmb_id_job'
        Visible = True
        ExplicitWidth = 388
      end
      object edt_personnel_number: TDBEditEh
        Left = 91
        Top = 263
        Width = 113
        Height = 21
        ControlLabel.Width = 89
        ControlLabel.Height = 13
        ControlLabel.Caption = #1058#1072#1073#1077#1083#1100#1085#1099#1081' '#1085#1086#1084#1077#1088
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 10
        Text = 'edt_personnel_number'
        Visible = True
      end
      object cmb_grade: TDBComboBoxEh
        Left = 92
        Top = 116
        Width = 113
        Height = 21
        ControlLabel.Width = 36
        ControlLabel.Height = 13
        ControlLabel.Caption = #1056#1072#1079#1088#1103#1076
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 11
        Text = 'cmb_id_job'
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 365
      Width = 488
      ExplicitTop = 364
      ExplicitWidth = 484
      inherited bvlFrmBtnsTl: TBevel
        Width = 486
        ExplicitWidth = 486
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 486
        ExplicitWidth = 486
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 486
        ExplicitWidth = 482
        inherited pnlFrmBtnsMain: TPanel
          Left = 387
          ExplicitLeft = 383
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 159
          ExplicitLeft = 155
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 288
          ExplicitLeft = 284
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 19
          ExplicitWidth = 15
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 409
    Width = 498
    ExplicitTop = 408
    ExplicitWidth = 494
    inherited lblStatusBarR: TLabel
      Left = 425
      Height = 14
      ExplicitLeft = 425
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 96
    Top = 304
  end
end
