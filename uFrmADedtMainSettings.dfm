inherited FrmADedtMainSettings: TFrmADedtMainSettings
  Caption = 'FrmADedtMainSettings'
  ClientHeight = 463
  ClientWidth = 946
  ExplicitWidth = 958
  ExplicitHeight = 501
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 946
    Height = 447
    ExplicitWidth = 942
    ExplicitHeight = 446
    inherited pnlFrmClient: TPanel
      Width = 936
      Height = 398
      ExplicitWidth = 932
      ExplicitHeight = 397
      object pnlMessage: TPanel
        Left = 0
        Top = 368
        Width = 936
        Height = 30
        Align = alBottom
        TabOrder = 0
        ExplicitTop = 367
        ExplicitWidth = 932
        object lbl_Warning: TLabel
          Left = 4
          Top = 9
          Width = 758
          Height = 13
          Caption = 
            #1042#1085#1080#1084#1072#1085#1080#1077'! '#1048#1079#1084#1077#1085#1103#1081#1090#1077' '#1101#1090#1080' '#1076#1072#1085#1085#1099#1077', '#1090#1086#1083#1100#1082#1086' '#1082#1086#1075#1076#1072' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080' '#1085#1077' '#1088#1072#1073 +
            #1086#1090#1072#1102#1090' '#1074' '#1087#1088#1086#1075#1088#1072#1084#1084#1077'. '#1055#1086#1089#1083#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080' '#1091#1073#1077#1076#1080#1090#1077#1089#1100' '#1095#1090#1086' '#1074#1089#1077' '#1088#1072#1073#1086#1090#1072#1077#1090' '#1087#1088 +
            #1072#1074#1080#1083#1100#1085#1086'.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 0
        Width = 936
        Height = 368
        ActivePage = tsMail
        Align = alClient
        TabOrder = 1
        ExplicitWidth = 932
        ExplicitHeight = 367
        object tsPaths: TTabSheet
          Caption = #1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1076#1072#1085#1085#1099#1093
          DesignSize = (
            928
            340)
          object lbl1: TLabel
            Left = 3
            Top = 37
            Width = 563
            Height = 13
            Caption = 
              '* '#1059#1078#1077' '#1080#1084#1077#1102#1097#1080#1077#1089#1103' '#1076#1072#1085#1085#1099#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1099' '#1053#1045' '#1073#1091#1076#1091#1090' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1087#1077#1088#1077#1085#1077#1089#1077 +
              #1085#1099' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1076#1072#1085#1085#1086#1081' '#1085#1072#1089#1090#1088#1086#1081#1082#1080'!'
          end
          object lbl2: TLabel
            Left = 0
            Top = 327
            Width = 928
            Height = 13
            Align = alBottom
            Caption = 
              '* '#1041#1091#1076#1100#1090#1077' '#1074#1085#1080#1084#1072#1090#1077#1083#1100#1085#1099'! '#1057#1091#1097#1077#1089#1090#1074#1086#1074#1072#1085#1080#1077' '#1080' '#1076#1086#1089#1090#1091#1087#1085#1086#1089#1090#1100' '#1091#1082#1072#1079#1072#1085#1085#1099#1093' '#1082#1072#1090#1072 +
              #1083#1086#1075#1086#1074' '#1085#1077' '#1087#1088#1086#1074#1077#1088#1103#1077#1090#1089#1103'!!!'
            ExplicitWidth = 491
          end
          object edt_filespath: TDBEditEh
            Left = 3
            Top = 15
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 668
            ControlLabel.Height = 13
            ControlLabel.Caption = 
              #1055#1091#1090#1100' '#1082' '#1085#1072#1089#1090#1088#1086#1082#1072#1084' '#1087#1088#1086#1075#1088#1072#1084#1084#1099' '#1080' '#1087#1088#1080#1082#1088#1077#1087#1083#1077#1085#1085#1099#1084' '#1092#1072#1081#1083#1072#1084' ('#1076#1086#1083#1078#1077#1085' '#1073#1099#1090#1100' '#1074 +
              #1089#1077#1075#1076#1072' '#1076#1086#1089#1090#1091#1087#1077#1085' '#1074#1089#1077#1084' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103#1084' '#1085#1072' '#1095#1090#1077#1085#1080#1077' '#1080' '#1079#1097#1072#1087#1080#1089#1100'!)'
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Text = 'edt_filespath'
            Visible = True
          end
          object edt_ordercurrentpath: TDBEditEh
            Left = 3
            Top = 93
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 317
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1072#1087#1082#1072' '#1079#1072#1082#1072#1079#1086#1074' - '#1042' '#1088#1072#1073#1086#1090#1091'    ('#1089#1090#1088#1086#1082#1072' YYYY '#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1091#1077#1090' '#1075#1086#1076#1091')'
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <>
            TabOrder = 1
            Text = 'edt_PathToFiles'
            Visible = True
          end
          object edt_orderarchivepath: TDBEditEh
            Left = 3
            Top = 135
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 315
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1072#1087#1082#1072' '#1079#1072#1082#1072#1079#1086#1074' - '#1040#1088#1093#1080#1074'        ('#1089#1090#1088#1086#1082#1072' YYYY '#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1091#1077#1090' '#1075#1086#1076#1091')'
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <>
            TabOrder = 2
            Text = 'edt_PathToFiles'
            Visible = True
          end
        end
        object tsMail: TTabSheet
          Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1087#1086#1095#1090#1099
          ImageIndex = 1
          DesignSize = (
            928
            340)
          object edt_MailingOrdersCh: TDBEditEh
            Left = 3
            Top = 19
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 162
            ControlLabel.Height = 13
            ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <
              item
              end>
            ReadOnly = True
            TabOrder = 0
            Visible = True
            ExplicitWidth = 914
          end
          object edt_MailingAttachSmeta: TDBEditEh
            Left = 3
            Top = 60
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 162
            ControlLabel.Height = 13
            ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <
              item
              end>
            ReadOnly = True
            TabOrder = 1
            Visible = True
            ExplicitWidth = 914
          end
          object edt_MailingReportSmeta: TDBEditEh
            Left = 3
            Top = 100
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 162
            ControlLabel.Height = 13
            ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <
              item
              end>
            ReadOnly = True
            TabOrder = 2
            Visible = True
            ExplicitWidth = 914
          end
          object edt_MailingAttachTHN: TDBEditEh
            Left = 3
            Top = 140
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 162
            ControlLabel.Height = 13
            ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <
              item
              end>
            ReadOnly = True
            TabOrder = 3
            Visible = True
            ExplicitWidth = 914
          end
          object edt_mailing_order_fin: TDBEditEh
            Left = 3
            Top = 185
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 162
            ControlLabel.Height = 13
            ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <
              item
              end>
            ReadOnly = True
            TabOrder = 4
            Visible = True
            ExplicitWidth = 914
          end
          object edt_mailing_sn: TDBEditEh
            Left = 3
            Top = 228
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 162
            ControlLabel.Height = 13
            ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <
              item
              end>
            ReadOnly = True
            TabOrder = 5
            Visible = True
            ExplicitWidth = 914
          end
          object edt_mailing_early_acts: TDBEditEh
            Left = 3
            Top = 268
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 162
            ControlLabel.Height = 13
            ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <
              item
              end>
            ReadOnly = True
            TabOrder = 6
            Visible = True
            ExplicitWidth = 914
          end
          object edt_mailing_for_stocks: TDBEditEh
            Left = 3
            Top = 308
            Width = 918
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 162
            ControlLabel.Height = 13
            ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            DynProps = <>
            EditButtons = <
              item
              end>
            ReadOnly = True
            TabOrder = 7
            Visible = True
          end
        end
        object tsDeleteOld: TTabSheet
          Caption = #1059#1076#1072#1083#1077#1085#1080#1077' '#1076#1072#1085#1085#1099#1093
          ImageIndex = 2
          object nedt_or_to_archive: TDBNumberEditEh
            Left = 0
            Top = 16
            Width = 81
            Height = 21
            ControlLabel.Width = 249
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1077#1088#1077#1085#1086#1089' '#1079#1072#1082#1072#1079#1086#1074' '#1074' '#1072#1088#1093#1080#1074', '#1061' '#1076#1085#1077#1081' '#1087#1086#1089#1083#1077' '#1086#1090#1075#1088#1091#1079#1082#1080
            ControlLabel.Visible = True
            DecimalPlaces = 0
            DynProps = <>
            EditButton.DefaultAction = True
            EditButton.Style = ebsUpDownEh
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 99999.000000000000000000
            MinValue = 7.000000000000000000
            TabOrder = 0
            Visible = True
          end
          object nedt_orders_n: TDBNumberEditEh
            Left = 0
            Top = 56
            Width = 81
            Height = 21
            ControlLabel.Width = 298
            ControlLabel.Height = 13
            ControlLabel.Caption = #1059#1076#1072#1083#1077#1085#1080#1077' '#1079#1072#1082#1072#1079#1086#1074', '#1089#1090#1072#1088#1096#1077' '#1061' '#1076#1085#1077#1081' '#1087#1088#1086#1089#1083#1077' '#1086#1090#1075#1088#1091#1079#1082#1080' '#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            DecimalPlaces = 0
            DynProps = <>
            EditButton.DefaultAction = True
            EditButton.Style = ebsUpDownEh
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 99999.000000000000000000
            MinValue = 14.000000000000000000
            TabOrder = 1
            Visible = True
          end
          object nedt_accounts_n: TDBNumberEditEh
            Left = 0
            Top = 96
            Width = 81
            Height = 21
            ControlLabel.Width = 242
            ControlLabel.Height = 13
            ControlLabel.Caption = #1059#1076#1072#1083#1077#1085#1080#1077' '#1089#1095#1077#1090#1086#1074', '#1089#1090#1072#1088#1096#1077' '#1061' '#1076#1085#1077#1081' '#1087#1086#1089#1083#1077' '#1086#1087#1083#1072#1090#1099
            ControlLabel.Visible = True
            DecimalPlaces = 0
            DynProps = <>
            EditButton.DefaultAction = True
            EditButton.Style = ebsUpDownEh
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 99999.000000000000000000
            MinValue = 14.000000000000000000
            TabOrder = 2
            Visible = True
          end
          object nedt_turv: TDBNumberEditEh
            Left = 0
            Top = 136
            Width = 81
            Height = 21
            ControlLabel.Width = 617
            ControlLabel.Height = 13
            ControlLabel.Caption = 
              #1059#1076#1072#1083#1077#1085#1080#1077' '#1058#1059#1056#1042', '#1089#1090#1072#1088#1096#1077' '#1061' '#1087#1077#1088#1080#1086#1076#1086#1074' ('#1087#1077#1088#1080#1086#1076' '#1088#1072#1074#1077#1085' '#1076#1074#1091#1084' '#1085#1077#1076#1077#1083#1103#1084', '#1087#1088#1080 +
              ' '#1091#1089#1090#1072#1085#1086#1074#1082#1077' 1 '#1091#1076#1072#1083#1103#1102#1090#1089#1103' '#1087#1086#1089#1083#1077#1076#1085#1080#1077' '#1079#1072#1074#1077#1088#1096#1077#1085#1085#1099#1077')'
            ControlLabel.Visible = True
            DecimalPlaces = 0
            DynProps = <>
            EditButton.DefaultAction = True
            EditButton.Style = ebsUpDownEh
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 99999.000000000000000000
            MinValue = 3.000000000000000000
            TabOrder = 3
            Visible = True
          end
          object nedt_payrolls: TDBNumberEditEh
            Left = 0
            Top = 176
            Width = 81
            Height = 21
            ControlLabel.Width = 437
            ControlLabel.Height = 13
            ControlLabel.Caption = 
              #1059#1076#1072#1083#1077#1085#1080#1077' '#1079#1072#1088#1087#1083#1072#1090#1085#1099#1093' '#1074#1077#1076#1086#1084#1086#1089#1090#1077#1081', '#1089#1090#1072#1088#1096#1077' '#1061' '#1087#1077#1088#1080#1086#1076#1086#1074' ('#1087#1077#1088#1080#1086#1076' '#1088#1072#1074#1077#1085' ' +
              #1076#1074#1091#1084' '#1085#1077#1076#1077#1083#1103#1084')'
            ControlLabel.Visible = True
            DecimalPlaces = 0
            DynProps = <>
            EditButton.DefaultAction = True
            EditButton.Style = ebsUpDownEh
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 99999.000000000000000000
            MinValue = 3.000000000000000000
            TabOrder = 4
            Visible = True
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 403
      Width = 936
      ExplicitTop = 402
      ExplicitWidth = 932
      inherited bvlFrmBtnsTl: TBevel
        Width = 934
        ExplicitWidth = 1026
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 934
        ExplicitWidth = 1026
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 934
        ExplicitWidth = 930
        inherited pnlFrmBtnsMain: TPanel
          Left = 835
          ExplicitLeft = 831
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 607
          ExplicitLeft = 603
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 736
          ExplicitLeft = 732
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 467
          ExplicitWidth = 463
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 447
    Width = 946
    ExplicitTop = 446
    ExplicitWidth = 942
    inherited lblStatusBarR: TLabel
      Left = 873
      Height = 14
      ExplicitLeft = 873
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 257
    Top = 408
  end
end
