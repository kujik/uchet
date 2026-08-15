inherited FrmODedtOrStdItem: TFrmODedtOrStdItem
  Caption = 'FrmODedtOrStdItem'
  ClientHeight = 429
  ClientWidth = 837
  ExplicitWidth = 849
  ExplicitHeight = 467
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 837
    Height = 413
    ExplicitWidth = 837
    ExplicitHeight = 413
    inherited pnlFrmClient: TPanel
      Width = 827
      Height = 364
      ExplicitWidth = 823
      ExplicitHeight = 363
      object bvlTabSync: TBevel
        Left = 8
        Top = 260
        Width = 815
        Height = 2
        Anchors = [akLeft, akTop, akRight]
      end
      object btn_TabCopyRoute: TSpeedButton
        Left = 310
        Top = 268
        Width = 24
        Height = 21
        Hint = #1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1084#1072#1088#1096#1088#1091#1090' '#1080' '#1094#1077#1085#1091' '#1089' '#1087#1077#1088#1074#1086#1081' '#1074#1082#1083#1072#1076#1082#1080
        Caption = '<<'
        ParentShowHint = False
        ShowHint = True
      end
      object pgcFormat: TPageControl
        Left = 8
        Top = 8
        Width = 815
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 7
        ExplicitWidth = 811
      end
      object cmb_id_or_format_estimates: TDBComboBoxEh
        Left = 82
        Top = 73
        Width = 350
        Height = 21
        ControlLabel.Width = 38
        ControlLabel.Height = 13
        ControlLabel.Caption = #1060#1086#1088#1084#1072#1090
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 0
        Visible = True
      end
      object edt_prefix: TDBEditEh
        Left = 82
        Top = 100
        Width = 120
        Height = 21
        ControlLabel.Width = 44
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1088#1077#1092#1080#1082#1089
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 20
        ReadOnly = True
        TabOrder = 1
        Text = 'edt_prefix'
        Visible = True
      end
      object nedt_price_base: TDBNumberEditEh
        Left = 85
        Top = 205
        Width = 104
        Height = 21
        ControlLabel.Width = 79
        ControlLabel.Height = 13
        ControlLabel.Caption = #1062#1077#1085#1072' ('#1073#1077#1079' '#1053#1044#1057')'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DynProps = <>
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 999999999.000000000000000000
        TabOrder = 5
        Visible = True
      end
      object chb_by_sgp: TDBCheckBoxEh
        Left = 86
        Top = 232
        Width = 96
        Height = 17
        Caption = #1059#1095#1077#1090' '#1087#1086' '#1057#1043#1055
        DynProps = <>
        TabOrder = 6
      end
      object chb_R0: TDBCheckBoxEh
        Left = 85
        Top = 182
        Width = 95
        Height = 17
        Caption = #1041#1077#1079' '#1084#1072#1088#1096#1088#1091#1090#1072
        DynProps = <>
        TabOrder = 3
      end
      object chb_Wo_Estimate: TDBCheckBoxEh
        Left = 194
        Top = 182
        Width = 82
        Height = 17
        Caption = #1041#1077#1079' '#1089#1084#1077#1090#1099
        DynProps = <>
        TabOrder = 4
      end
      object edt_name: TDBEditEh
        Left = 82
        Top = 127
        Width = 741
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 73
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 2
        Text = 'edt_name'
        Visible = True
        ExplicitWidth = 737
      end
      object chb_TabSync: TCheckBox
        Left = 8
        Top = 271
        Width = 140
        Height = 17
        Caption = #1057#1080#1085#1093#1088#1086#1085#1080#1079#1080#1088#1086#1074#1072#1090#1100
        TabOrder = 8
      end
      object chb_TabNotCreate: TCheckBox
        Left = 160
        Top = 271
        Width = 140
        Height = 17
        Caption = #1053#1077' '#1089#1086#1079#1076#1072#1074#1072#1090#1100
        TabOrder = 9
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 369
      Width = 827
      ExplicitTop = 368
      ExplicitWidth = 823
      inherited bvlFrmBtnsTl: TBevel
        Width = 825
        ExplicitWidth = 768
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 825
        ExplicitWidth = 768
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 825
        ExplicitWidth = 821
        inherited pnlFrmBtnsMain: TPanel
          Left = 726
          ExplicitLeft = 722
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 498
          ExplicitLeft = 494
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 627
          ExplicitLeft = 623
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 358
          ExplicitWidth = 354
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 413
    Width = 837
    ExplicitTop = 412
    ExplicitWidth = 833
    inherited lblStatusBarR: TLabel
      Left = 764
      Height = 14
      ExplicitLeft = 764
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 168
    Top = 256
  end
end
