inherited FrmODedtOrStdItem: TFrmODedtOrStdItem
  Caption = 'FrmODedtOrStdItem'
  ClientHeight = 544
  ClientWidth = 833
  ExplicitWidth = 845
  ExplicitHeight = 582
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 833
    Height = 528
    ExplicitWidth = 829
    ExplicitHeight = 527
    inherited pnlFrmClient: TPanel
      Width = 823
      Height = 479
      ExplicitWidth = 819
      ExplicitHeight = 478
      object lblSemiproductErrors: TLabel
        Left = 82
        Top = 152
        Width = 98
        Height = 13
        Cursor = crHandPoint
        Caption = 'lblSemiproductErrors'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsUnderline]
        ParentFont = False
        Visible = False
        OnClick = lblSemiproductErrorsClick
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
        Width = 737
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
        ExplicitWidth = 733
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 484
      Width = 823
      ExplicitTop = 483
      ExplicitWidth = 819
      inherited bvlFrmBtnsTl: TBevel
        Width = 821
        ExplicitWidth = 768
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 821
        ExplicitWidth = 768
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 821
        ExplicitWidth = 817
        inherited pnlFrmBtnsMain: TPanel
          Left = 722
          ExplicitLeft = 718
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 494
          ExplicitLeft = 490
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 623
          ExplicitLeft = 619
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 354
          ExplicitWidth = 350
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 528
    Width = 833
    ExplicitTop = 527
    ExplicitWidth = 829
    inherited lblStatusBarR: TLabel
      Left = 760
      Height = 14
      ExplicitLeft = 760
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
