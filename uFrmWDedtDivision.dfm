inherited FrmWDedtDivision: TFrmWDedtDivision
  Caption = 'FrmWDedtDivision'
  ClientHeight = 252
  ClientWidth = 672
  ExplicitWidth = 684
  ExplicitHeight = 290
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 672
    Height = 236
    ExplicitWidth = 852
    ExplicitHeight = 401
    inherited pnlFrmClient: TPanel
      Width = 662
      Height = 187
      ExplicitWidth = 842
      ExplicitHeight = 352
      object cmb_Office: TDBComboBoxEh
        Left = 104
        Top = 8
        Width = 121
        Height = 21
        ControlLabel.Width = 51
        ControlLabel.Height = 13
        ControlLabel.Caption = #1062#1077#1093'/'#1054#1092#1080#1089
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Items.Strings = (
          #1062#1077#1093
          #1054#1092#1080#1089)
        KeyItems.Strings = (
          '0'
          '1')
        TabOrder = 0
        Visible = True
      end
      object edt_Code: TDBEditEh
        Left = 104
        Top = 35
        Width = 121
        Height = 21
        ControlLabel.Width = 20
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1076
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 5
        TabOrder = 1
        Text = 'edt_Code'
        Visible = True
      end
      object edt_name: TDBEditEh
        Left = 104
        Top = 62
        Width = 509
        Height = 21
        ControlLabel.Width = 73
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Text = 'edt_name'
        Visible = True
      end
      object cmb_id_head: TDBComboBoxEh
        Left = 104
        Top = 89
        Width = 508
        Height = 21
        ControlLabel.Width = 73
        ControlLabel.Height = 13
        ControlLabel.Caption = #1056#1091#1082#1086#1074#1086#1076#1080#1090#1077#1083#1100
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 3
        Text = 'cmb_Cash'
        Visible = True
      end
      object edt_editusernames: TDBEditEh
        Left = 104
        Top = 116
        Width = 508
        Height = 21
        ControlLabel.Width = 85
        ControlLabel.Height = 13
        ControlLabel.Caption = #1047#1072#1087#1086#1083#1085#1103#1102#1090' '#1058#1059#1056#1042
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <
          item
            OnClick = edt_usersEditButtons0Click
          end>
        ReadOnly = True
        TabOrder = 4
        Visible = True
      end
      object chb_Active: TDBCheckBoxEh
        Left = 101
        Top = 143
        Width = 97
        Height = 17
        Caption = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103
        Color = clRed
        DynProps = <>
        ParentColor = False
        TabOrder = 5
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 192
      Width = 662
      ExplicitTop = 357
      ExplicitWidth = 842
      inherited bvlFrmBtnsTl: TBevel
        Width = 660
        ExplicitWidth = 844
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 660
        ExplicitWidth = 844
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 660
        ExplicitWidth = 840
        inherited pnlFrmBtnsMain: TPanel
          Left = 561
          ExplicitLeft = 741
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 333
          ExplicitLeft = 513
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 462
          ExplicitLeft = 642
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 193
          ExplicitWidth = 373
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 236
    Width = 672
    ExplicitTop = 401
    ExplicitWidth = 852
    inherited lblStatusBarR: TLabel
      Left = 580
      Height = 14
      ExplicitLeft = 764
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
