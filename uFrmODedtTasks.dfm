inherited FrmODedtTasks: TFrmODedtTasks
  Caption = 'FrmDlgJTasks'
  ClientHeight = 491
  ClientWidth = 847
  ExplicitWidth = 863
  ExplicitHeight = 530
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 847
    Height = 475
    ExplicitWidth = 847
    ExplicitHeight = 475
    inherited pnlFrmClient: TPanel
      Width = 841
      Height = 427
      ExplicitWidth = 837
      ExplicitHeight = 426
      object cmb_type: TDBComboBoxEh
        Left = 104
        Top = 8
        Width = 201
        Height = 21
        ControlLabel.Width = 58
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1080#1076' '#1079#1072#1076#1072#1095#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Text = 'cmb_type'
        Visible = True
      end
      object cmb_id_order: TDBComboBoxEh
        Left = 104
        Top = 86
        Width = 734
        Height = 21
        ControlLabel.Width = 29
        ControlLabel.Height = 13
        ControlLabel.Caption = #1047#1072#1082#1072#1079
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Text = 'DBComboBoxEh1'
        Visible = True
      end
      object cmb_id_order_item: TDBComboBoxEh
        Left = 105
        Top = 113
        Width = 733
        Height = 21
        ControlLabel.Width = 43
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1079#1076#1077#1083#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Text = 'DBComboBoxEh1'
        Visible = True
      end
      object edt_user1: TDBEditEh
        Left = 104
        Top = 62
        Width = 201
        Height = 21
        ControlLabel.Width = 55
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1085#1080#1094#1080#1072#1090#1086#1088
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 3
        Text = 'DBEditEh1'
        Visible = True
      end
      object cmb_id_user2: TDBComboBoxEh
        Left = 400
        Top = 62
        Width = 209
        Height = 21
        ControlLabel.Width = 66
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 4
        Text = 'DBComboBoxEh1'
        Visible = True
      end
      object mem_Comm1: TDBMemoEh
        Left = 105
        Top = 140
        Width = 734
        Height = 89
        ControlLabel.Width = 67
        ControlLabel.Height = 26
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081#13#10#1080#1085#1080#1094#1080#1072#1090#1086#1088#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Lines.Strings = (
          'DBMemoEh1')
        ScrollBars = ssVertical
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 5
        Visible = True
        WantReturns = True
      end
      object dedt_dt: TDBDateTimeEditEh
        Left = 104
        Top = 236
        Width = 121
        Height = 21
        ControlLabel.Width = 59
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072#13#10#1087#1086#1089#1090#1072#1085#1086#1074#1082#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 6
        Visible = True
      end
      object dedt_dt_planned: TDBDateTimeEditEh
        Left = 304
        Top = 236
        Width = 121
        Height = 21
        ControlLabel.Width = 58
        ControlLabel.Height = 26
        ControlLabel.Caption = #1055#1083#1072#1085#1086#1074#1072#1103#13#10#1076#1072#1090#1072' '#1089#1076#1072#1095#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 7
        Visible = True
      end
      object cmb_id_state: TDBComboBoxEh
        Left = 104
        Top = 263
        Width = 209
        Height = 21
        ControlLabel.Width = 36
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1090#1072#1090#1091#1089
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 8
        Text = 'DBComboBoxEh1'
        Visible = True
      end
      object dedt_dt_beg: TDBDateTimeEditEh
        Left = 104
        Top = 290
        Width = 121
        Height = 21
        ControlLabel.Width = 36
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072#13#10#1085#1072#1095#1072#1083#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 9
        Visible = True
      end
      object dedt_dt_end: TDBDateTimeEditEh
        Left = 304
        Top = 290
        Width = 121
        Height = 21
        ControlLabel.Width = 67
        ControlLabel.Height = 26
        ControlLabel.Caption = #1060#1072#1082#1090#1080#1095#1077#1089#1082#1072#1103#13#10#1076#1072#1090#1072' '#1089#1076#1072#1095#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 10
        Visible = True
      end
      object mem_Comm2: TDBMemoEh
        Left = 104
        Top = 317
        Width = 734
        Height = 89
        ControlLabel.Width = 67
        ControlLabel.Height = 26
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081#13#10#1080#1089#1087#1086#1083#1085#1080#1090#1077#1083#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Lines.Strings = (
          'DBMemoEh1')
        ScrollBars = ssVertical
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 11
        Visible = True
        WantReturns = True
      end
      object chb_confirmed: TDBCheckBoxEh
        Left = 725
        Top = 410
        Width = 112
        Height = 17
        Caption = #1055#1086#1076#1090#1074#1077#1088#1078#1078#1076#1077#1085#1072
        DynProps = <>
        TabOrder = 12
      end
      object edt_name: TDBEditEh
        Left = 105
        Top = 35
        Width = 734
        Height = 21
        ControlLabel.Width = 37
        ControlLabel.Height = 13
        ControlLabel.Caption = #1047#1072#1076#1072#1095#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 13
        Text = 'edt_name'
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 431
      Width = 837
      ExplicitTop = 431
      ExplicitWidth = 837
      inherited bvlFrmBtnsTl: TBevel
        Width = 839
        ExplicitWidth = 839
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 839
        ExplicitWidth = 839
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 839
        ExplicitWidth = 835
        inherited pnlFrmBtnsMain: TPanel
          Left = 740
          ExplicitLeft = 736
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 512
          ExplicitLeft = 508
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 641
          ExplicitLeft = 637
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 372
          ExplicitWidth = 368
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 475
    Width = 847
    ExplicitTop = 475
    ExplicitWidth = 847
    inherited lblStatusBarR: TLabel
      Left = 778
      ExplicitLeft = 778
    end
  end
end
