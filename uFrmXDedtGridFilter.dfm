inherited FrmXDedtGridFilter: TFrmXDedtGridFilter
  Caption = 'FrmXDedtGridFilter'
  ClientHeight = 159
  ClientWidth = 386
  ExplicitWidth = 402
  ExplicitHeight = 198
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 386
    Height = 143
    ExplicitWidth = 386
    ExplicitHeight = 143
    inherited pnlFrmClient: TPanel
      Width = 376
      Height = 94
      ExplicitWidth = 376
      ExplicitHeight = 94
      object bvl1: TBevel
        Left = 8
        Top = 84
        Width = 352
        Height = 2
      end
      object dedt1: TDBDateTimeEditEh
        Left = 103
        Top = 30
        Width = 121
        Height = 21
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <
          item
            DropdownMenu = pmPeriod
            Style = ebsPlusEh
          end>
        Kind = dtkDateEh
        TabOrder = 0
        Visible = True
      end
      object dedt2: TDBDateTimeEditEh
        Left = 247
        Top = 32
        Width = 121
        Height = 21
        ControlLabel.Width = 12
        ControlLabel.Height = 13
        ControlLabel.Caption = #1087#1086
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 1
        Visible = True
      end
      object nedtDays: TDBNumberEditEh
        Left = 103
        Top = 57
        Width = 121
        Height = 21
        ControlLabel.Width = 25
        ControlLabel.Height = 13
        ControlLabel.Caption = #1076#1085#1077#1081
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpRightCenterEh
        DecimalPlaces = 0
        DynProps = <>
        EditButton.DefaultAction = True
        EditButton.Style = ebsUpDownEh
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 10000.000000000000000000
        MinValue = 1.000000000000000000
        TabOrder = 2
        Visible = True
      end
      object cmbField: TDBComboBoxEh
        Left = 103
        Top = 3
        Width = 265
        Height = 21
        ControlLabel.Width = 67
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1090#1086#1083#1073#1077#1094'        '
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 3
        Text = 'cmbField'
        Visible = True
      end
      object cmbPeriod: TDBCheckBoxEh
        Left = 8
        Top = 34
        Width = 97
        Height = 17
        Caption = #1047#1072' '#1087#1077#1088#1080#1086#1076' '#1089
        DynProps = <>
        TabOrder = 4
      end
      object cmbDays: TDBCheckBoxEh
        Left = 9
        Top = 57
        Width = 88
        Height = 17
        Caption = #1047#1072' '#1087#1086#1089#1083#1077#1076#1085#1080#1077
        DynProps = <>
        TabOrder = 5
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 99
      Width = 376
      ExplicitTop = 99
      ExplicitWidth = 376
      inherited bvlFrmBtnsTl: TBevel
        Width = 374
        ExplicitWidth = 370
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 374
        ExplicitWidth = 370
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 374
        ExplicitWidth = 374
        inherited pnlFrmBtnsMain: TPanel
          Left = 275
          ExplicitLeft = 275
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 47
          ExplicitLeft = 47
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 176
          ExplicitLeft = 176
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 28
          ExplicitWidth = 28
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 143
    Width = 386
    ExplicitTop = 143
    ExplicitWidth = 386
    inherited lblStatusBarR: TLabel
      Left = 294
      Height = 13
      ExplicitLeft = 294
    end
    inherited lblStatusBarL: TLabel
      Height = 13
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 96
    Top = 424
  end
  object pmPeriod: TPopupMenu
    Left = 341
    Top = 61
  end
end
