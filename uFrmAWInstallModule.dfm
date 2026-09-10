inherited FrmAWInstallModule: TFrmAWInstallModule
  Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
  ClientHeight = 628
  ClientWidth = 807
  ExplicitWidth = 819
  ExplicitHeight = 666
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 807
    Height = 612
    ExplicitWidth = 807
    ExplicitHeight = 600
    inherited pnlFrmClient: TPanel
      Width = 797
      Height = 563
      ExplicitWidth = 793
      ExplicitHeight = 550
      object lbl_CompareInfo: TLabel
        Left = 8
        Top = 51
        Width = 98
        Height = 16
        Caption = 'lbl_CompareInfo'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object lbl_InstallLog: TLabel
        Left = 8
        Top = 303
        Width = 91
        Height = 13
        Caption = #1059#1089#1090#1072#1085#1086#1074#1082#1080' '#1088#1072#1085#1077#1077':'
      end
      object lbl_FilesStatus: TLabel
        Left = 4
        Top = 489
        Width = 87
        Height = 16
        Anchors = [akLeft, akBottom]
        Caption = 'lbl_FilesStatus'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ExplicitTop = 550
      end
      object lbl_ResultStatus: TLabel
        Left = 8
        Top = 489
        Width = 96
        Height = 16
        Anchors = [akLeft, akBottom]
        Caption = 'lbl_ResultStatus'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ExplicitTop = 477
      end
      object cmb_Module: TDBComboBoxEh
        Left = 8
        Top = 24
        Width = 241
        Height = 21
        ControlLabel.Width = 175
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1084#1086#1076#1091#1083#1100' '#1076#1083#1103' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1103
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        LimitTextToListValues = True
        TabOrder = 0
        Text = 'cmb_Module'
        Visible = True
        OnChange = ModuleParamsChange
      end
      object edt_NewVersion: TDBEditEh
        Left = 272
        Top = 24
        Width = 241
        Height = 21
        Color = clBtnFace
        ControlLabel.Width = 75
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1077#1088#1089#1080#1103' '#1084#1086#1076#1091#1083#1103
        ControlLabel.Color = clBtnText
        ControlLabel.ParentColor = False
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        ReadOnly = True
        TabOrder = 1
        Visible = True
      end
      object edt_NewCompileDt: TDBEditEh
        Left = 545
        Top = 24
        Width = 241
        Height = 21
        Color = clBtnFace
        ControlLabel.Width = 89
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1072#1090#1072' '#1082#1086#1084#1087#1080#1083#1103#1094#1080#1080
        ControlLabel.Color = clBtnText
        ControlLabel.ParentColor = False
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        ReadOnly = True
        TabOrder = 2
        Visible = True
      end
      object edt_SrcPath: TDBEditEh
        Left = 8
        Top = 89
        Width = 377
        Height = 21
        ControlLabel.Width = 105
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1072#1090#1072#1083#1086#1075' '#1080#1089#1093#1086#1076#1085#1080#1082#1086#1074
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        TabOrder = 3
        Visible = True
        OnChange = ModuleParamsChange
      end
      object edt_DstPath: TDBEditEh
        Left = 409
        Top = 89
        Width = 377
        Height = 21
        ControlLabel.Width = 88
        ControlLabel.Height = 13
        ControlLabel.Caption = #1062#1077#1083#1077#1074#1086#1081' '#1082#1072#1090#1072#1083#1086#1075
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        TabOrder = 4
        Visible = True
        OnChange = ModuleParamsChange
      end
      object mem_Users: TDBMemoEh
        Left = 8
        Top = 136
        Width = 778
        Height = 49
        ControlLabel.Width = 232
        ControlLabel.Height = 13
        ControlLabel.Caption = #1052#1086#1076#1091#1083#1100' '#1086#1090#1082#1088#1099#1090' '#1091' '#1089#1083#1077#1076#1091#1102#1097#1080#1093' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
        ControlLabel.Visible = True
        Lines.Strings = (
          'mem_Users')
        AutoSize = False
        Color = clBtnFace
        DynProps = <>
        EditButtons = <>
        TabOrder = 5
        Visible = True
        WantReturns = True
      end
      object mem_Comment: TDBMemoEh
        Left = 8
        Top = 208
        Width = 778
        Height = 89
        ControlLabel.Width = 132
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081' '#1082' '#1091#1089#1090#1072#1085#1086#1074#1082#1077
        ControlLabel.Visible = True
        Lines.Strings = (
          'mem_Comment')
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        HighlightRequired = True
        MaxLength = 4000
        TabOrder = 6
        Visible = True
        WantReturns = True
      end
      inline FrgInstallLog: TFrDBGridEh
        Left = 8
        Top = 322
        Width = 778
        Height = 118
        TabOrder = 7
        ExplicitLeft = 8
        ExplicitTop = 322
        ExplicitWidth = 778
        ExplicitHeight = 118
        inherited pnlGrid: TPanel
          Width = 768
          Height = 64
          ExplicitWidth = 768
          ExplicitHeight = 64
          inherited DbGridEh1: TDBGridEh
            Width = 766
            Height = 41
            inherited RowDetailData: TRowDetailPanelControlEh
              ExplicitLeft = 30
              ExplicitTop = 35
              ExplicitWidth = 32
              ExplicitHeight = 2
              inherited PRowDetailPanel: TPanel
                Height = 0
                ExplicitHeight = 0
              end
            end
          end
          inherited pnlStatusBar: TPanel
            Top = 42
            Width = 766
            ExplicitTop = 42
            ExplicitWidth = 766
            inherited lblStatusBarL: TLabel
              Height = 13
              ExplicitHeight = 13
            end
          end
          inherited CProp: TDBEditEh
            Height = 21
            ExplicitHeight = 21
          end
        end
        inherited pnlLeft: TPanel
          Height = 64
          ExplicitHeight = 64
        end
        inherited pnlTop: TPanel
          Width = 778
          ExplicitWidth = 778
        end
        inherited pnlContainer: TPanel
          Width = 778
          ExplicitWidth = 778
        end
        inherited pnlBottom: TPanel
          Top = 118
          Width = 778
          ExplicitTop = 118
          ExplicitWidth = 778
        end
        inherited PrintDBGridEh1: TPrintDBGridEh
          BeforeGridText_Data = {
            7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
            7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
            305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
            666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
            6E657261746F722052696368656432302031302E302E32363130307D5C766965
            776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
            66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
            720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
            205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
            34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
            305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
        end
      end
      object mem_InstallLogComment: TDBMemoEh
        Left = 8
        Top = 456
        Width = 777
        Height = 81
        ControlLabel.Width = 67
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        ControlLabel.Visible = True
        AutoSize = False
        Color = clMenuBar
        DynProps = <>
        EditButtons = <>
        MaxLength = 4000
        ReadOnly = True
        TabOrder = 8
        Visible = True
        WantReturns = True
      end
      object chb_CloseSessions: TDBCheckBoxEh
        Left = 590
        Top = 488
        Width = 195
        Height = 17
        Anchors = [akLeft, akBottom]
        Caption = #1047#1072#1074#1077#1088#1096#1080#1090#1100' '#1089#1077#1089#1089#1080#1080' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
        DynProps = <>
        TabOrder = 9
        ExplicitTop = 475
      end
      object pgb_Install: TProgressBar
        Left = 4
        Top = 511
        Width = 580
        Height = 33
        Anchors = [akLeft, akBottom]
        Style = pbstMarquee
        MarqueeInterval = 20
        Step = 20
        TabOrder = 10
        ExplicitTop = 498
      end
      object Bt_Install: TBitBtn
        Left = 590
        Top = 511
        Width = 195
        Height = 33
        Anchors = [akRight, akBottom]
        Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1084#1086#1076#1091#1083#1100
        TabOrder = 11
        OnClick = Bt_InstallClick
        ExplicitLeft = 586
        ExplicitTop = 498
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 568
      Width = 797
      ExplicitTop = 555
      ExplicitWidth = 793
      inherited bvlFrmBtnsTl: TBevel
        Width = 795
        ExplicitWidth = 838
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 795
        ExplicitWidth = 838
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 795
        ExplicitWidth = 791
        inherited pnlFrmBtnsMain: TPanel
          Left = 696
          ExplicitLeft = 692
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 468
          ExplicitLeft = 464
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 597
          ExplicitLeft = 593
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 328
          ExplicitWidth = 324
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 612
    Width = 807
    ExplicitTop = 599
    ExplicitWidth = 803
    inherited lblStatusBarR: TLabel
      Left = 734
      Height = 14
      ExplicitLeft = 734
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 168
    Top = 48
  end
  object tmr_Poll: TTimer
    Interval = 10000
    OnTimer = tmr_PollTimer
    Left = 288
    Top = 572
  end
end
