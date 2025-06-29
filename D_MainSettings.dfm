object Dlg_MainSettings: TDlg_MainSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1054#1089#1085#1086#1074#1085#1099#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
  ClientHeight = 421
  ClientWidth = 919
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 919
    Height = 386
    ActivePage = ts_Mail
    Align = alClient
    TabOrder = 0
    object ts_Paths: TTabSheet
      Caption = #1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1076#1072#1085#1085#1099#1093
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        911
        358)
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
        Top = 345
        Width = 911
        Height = 13
        Align = alBottom
        Caption = 
          '* '#1041#1091#1076#1100#1090#1077' '#1074#1085#1080#1084#1072#1090#1077#1083#1100#1085#1099'! '#1057#1091#1097#1077#1089#1090#1074#1086#1074#1072#1085#1080#1077' '#1080' '#1076#1086#1089#1090#1091#1087#1085#1086#1089#1090#1100' '#1091#1082#1072#1079#1072#1085#1085#1099#1093' '#1082#1072#1090#1072 +
          #1083#1086#1075#1086#1074' '#1085#1077' '#1087#1088#1086#1074#1077#1088#1103#1077#1090#1089#1103'!!!'
        ExplicitWidth = 491
      end
      object edt_PathToFiles: TDBEditEh
        Left = 0
        Top = 15
        Width = 908
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
        Text = 'edt_PathToFiles'
        Visible = True
      end
      object edt_ZCurrent: TDBEditEh
        Left = 0
        Top = 93
        Width = 908
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
      object edt_ZArchive: TDBEditEh
        Left = 0
        Top = 135
        Width = 908
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
    object ts_Mail: TTabSheet
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1087#1086#1095#1090#1099
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        911
        358)
      object bvl1: TBevel
        Left = 11
        Top = 141
        Width = 897
        Height = 3
      end
      object edt_EMailDomain: TDBEditEh
        Left = 11
        Top = 23
        Width = 430
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 85
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1086#1095#1090#1086#1074#1099#1081' '#1076#1086#1084#1077#1085
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        MaxLength = 200
        TabOrder = 0
        Visible = True
      end
      object edt_EmailUser: TDBEditEh
        Left = 475
        Top = 23
        Width = 430
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 288
        ControlLabel.Height = 13
        ControlLabel.Caption = #1051#1086#1075#1080#1085' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' ('#1086#1090' '#1080#1084#1077#1085#1080' '#1082#1086#1090#1086#1088#1086#1075#1086' '#1087#1086#1081#1076#1091#1090' '#1087#1080#1089#1100#1084#1072')'
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        MaxLength = 200
        TabOrder = 1
        Visible = True
      end
      object edt_EmailServer: TDBEditEh
        Left = 11
        Top = 63
        Width = 430
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 75
        ControlLabel.Height = 13
        ControlLabel.Caption = #1040#1076#1088#1077#1089' '#1089#1077#1088#1074#1077#1088#1072
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        MaxLength = 200
        TabOrder = 2
        Visible = True
      end
      object edt_EMailLogin: TDBEditEh
        Left = 475
        Top = 63
        Width = 430
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 178
        ControlLabel.Height = 13
        ControlLabel.Caption = #1051#1086#1075#1080#1085' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1091
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        MaxLength = 200
        TabOrder = 3
        Visible = True
      end
      object edt_EMailPassword: TDBEditEh
        Left = 11
        Top = 103
        Width = 430
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 96
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1072#1088#1086#1083#1100' '#1085#1072' '#1089#1077#1088#1074#1077#1088#1077
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        MaxLength = 200
        PasswordChar = '*'
        TabOrder = 4
        Visible = True
      end
      object edt_EMailPassword2: TDBEditEh
        Left = 478
        Top = 103
        Width = 430
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 76
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1086#1074#1090#1086#1088' '#1087#1072#1088#1086#1083#1103
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        MaxLength = 200
        PasswordChar = '*'
        TabOrder = 5
        Visible = True
      end
      object edt_MailingOrdersCh: TDBEditEh
        Left = 11
        Top = 164
        Width = 897
        Height = 21
        ControlLabel.Width = 162
        ControlLabel.Height = 13
        ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <
          item
            OnClick = edt_MailingOrdersChEditButtons0Click
          end>
        ReadOnly = True
        TabOrder = 6
        Visible = True
      end
      object edt_MailingOrdersChITM: TDBEditEh
        Left = 11
        Top = 204
        Width = 897
        Height = 21
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
      object edt_MailingAttachSmeta: TDBEditEh
        Left = 11
        Top = 244
        Width = 897
        Height = 21
        ControlLabel.Width = 162
        ControlLabel.Height = 13
        ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <
          item
          end>
        ReadOnly = True
        TabOrder = 8
        Visible = True
      end
      object edt_MailingReportSmeta: TDBEditEh
        Left = 11
        Top = 284
        Width = 897
        Height = 21
        ControlLabel.Width = 162
        ControlLabel.Height = 13
        ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <
          item
          end>
        ReadOnly = True
        TabOrder = 9
        Visible = True
      end
      object edt_MailingAttachTHN: TDBEditEh
        Left = 11
        Top = 324
        Width = 897
        Height = 21
        ControlLabel.Width = 162
        ControlLabel.Height = 13
        ControlLabel.Caption = #1056#1072#1089#1089#1099#1083#1082#1072' '#1087#1088#1080' '#1080#1079#1084#1077#1085#1077#1085#1080#1080' '#1079#1072#1082#1072#1079#1072
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <
          item
          end>
        ReadOnly = True
        TabOrder = 10
        Visible = True
      end
    end
    object ts_DeleteOld: TTabSheet
      Caption = #1059#1076#1072#1083#1077#1085#1080#1077' '#1076#1072#1085#1085#1099#1093
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object nedt_MoveToArchive: TDBNumberEditEh
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
      object nedt_DeleteOrders: TDBNumberEditEh
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
      object nedt_DeleteAccounts: TDBNumberEditEh
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
      object nedt_DeleteTurv: TDBNumberEditEh
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
      object nedt_DeletePayrolls: TDBNumberEditEh
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
  object pnl1: TPanel
    Left = 0
    Top = 386
    Width = 919
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      919
      35)
    object lbl_Warning: TLabel
      Left = 4
      Top = 12
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
    object Bt_Ok: TBitBtn
      Left = 759
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Bt_Ok'
      Default = True
      TabOrder = 0
      OnClick = Bt_OkClick
    end
    object Bt_Cancel: TBitBtn
      Left = 840
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Bt_Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
