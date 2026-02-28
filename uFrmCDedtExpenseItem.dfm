inherited FrmCDedtExpenseItem: TFrmCDedtExpenseItem
  Caption = 'FrmCDedtExpenseItem'
  ClientHeight = 277
  ClientWidth = 786
  ExplicitWidth = 798
  ExplicitHeight = 315
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 786
    Height = 261
    ExplicitWidth = 786
    ExplicitHeight = 308
    inherited pnlFrmClient: TPanel
      Width = 776
      Height = 212
      ExplicitWidth = 772
      ExplicitHeight = 258
      object cmb_id_group: TDBComboBoxEh
        Left = 88
        Top = 8
        Width = 683
        Height = 21
        ControlLabel.Width = 36
        ControlLabel.Height = 13
        ControlLabel.Caption = #1043#1088#1091#1087#1087#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Visible = True
        ExplicitWidth = 679
      end
      object edt_name: TDBEditEh
        Left = 88
        Top = 35
        Width = 683
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 73
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
        ExplicitWidth = 679
      end
      object edt_usernames: TDBEditEh
        Left = 88
        Top = 62
        Width = 683
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 37
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1086#1089#1090#1091#1087
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <
          item
          end>
        ReadOnly = True
        TabOrder = 2
        Visible = True
        ExplicitWidth = 679
      end
      object edt_agreednames: TDBEditEh
        Left = 88
        Top = 89
        Width = 683
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 71
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1086#1075#1083#1072#1089#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <
          item
          end>
        ReadOnly = True
        TabOrder = 3
        Visible = True
        ExplicitWidth = 679
      end
      object chb_accounttype_1: TDBCheckBoxEh
        Left = 95
        Top = 119
        Width = 138
        Height = 17
        Caption = #1058#1088#1072#1085#1089#1087#1086#1088#1090' '#1086#1090#1075#1088#1091#1079#1082#1072
        Color = clRed
        DynProps = <>
        ParentColor = False
        TabOrder = 4
      end
      object chb_accounttype_2: TDBCheckBoxEh
        Left = 247
        Top = 119
        Width = 146
        Height = 17
        Caption = #1058#1088#1072#1085#1089#1087#1086#1088#1090' '#1089#1085#1072#1073#1078#1077#1085#1080#1077
        Color = clRed
        DynProps = <>
        ParentColor = False
        TabOrder = 5
      end
      object chb_accounttype_3: TDBCheckBoxEh
        Left = 415
        Top = 119
        Width = 146
        Height = 17
        Caption = #1055#1086#1076#1088#1103#1076#1095#1080#1082#1080' '#1087#1086' '#1084#1086#1085#1090#1072#1078#1091
        Color = clRed
        DynProps = <>
        ParentColor = False
        TabOrder = 6
      end
      object chb_recvreceipt: TDBCheckBoxEh
        Left = 95
        Top = 142
        Width = 121
        Height = 17
        Caption = #1058#1088#1077#1073#1091#1077#1090#1089#1103' '#1079#1072#1103#1074#1082#1072
        Color = clRed
        DynProps = <>
        ParentColor = False
        TabOrder = 7
      end
      object chb_active: TDBCheckBoxEh
        Left = 95
        Top = 165
        Width = 97
        Height = 17
        Caption = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103
        Color = clRed
        DynProps = <>
        ParentColor = False
        TabOrder = 8
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 217
      Width = 776
      ExplicitTop = 263
      ExplicitWidth = 772
      inherited bvlFrmBtnsTl: TBevel
        Width = 774
        ExplicitWidth = 774
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 774
        ExplicitWidth = 774
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 774
        ExplicitWidth = 770
        inherited pnlFrmBtnsMain: TPanel
          Left = 675
          ExplicitLeft = 671
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 447
          ExplicitLeft = 443
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 576
          ExplicitLeft = 572
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 307
          ExplicitWidth = 303
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 261
    Width = 786
    ExplicitTop = 307
    ExplicitWidth = 782
    inherited lblStatusBarR: TLabel
      Left = 713
      Height = 14
      ExplicitLeft = 713
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 240
    Top = 272
  end
end
