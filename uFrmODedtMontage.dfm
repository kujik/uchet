inherited FrmODedtMontage: TFrmODedtMontage
  Caption = 'FrmODedtMontage'
  ClientHeight = 310
  ClientWidth = 501
  ExplicitWidth = 513
  ExplicitHeight = 348
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 501
    Height = 294
    ExplicitWidth = 497
    ExplicitHeight = 293
    inherited pnlFrmClient: TPanel
      Width = 491
      Height = 245
      ExplicitWidth = 487
      ExplicitHeight = 244
      object lbl_Act: TLabel
        Left = 8
        Top = 215
        Width = 155
        Height = 13
        Caption = #1060#1072#1081#1083' '#1089#1095#1077#1090#1072
      end
      object lbl_Photos: TLabel
        Left = 280
        Top = 215
        Width = 145
        Height = 13
        Caption = #1060#1072#1081#1083' '#1089#1095#1077#1090#1072
      end
      object dedt_Beg: TDBDateTimeEditEh
        Left = 112
        Top = 22
        Width = 97
        Height = 21
        ControlLabel.Width = 101
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072#13#10#1085#1072#1095#1072#1083#1072' '#1084#1086#1085#1090#1072#1078#1072'      '
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 0
        Visible = True
      end
      object chb_RC: TDBCheckBoxEh
        Left = 280
        Top = 24
        Width = 200
        Height = 17
        Caption = #1047#1072#1084#1077#1095#1072#1085#1080#1103' '#1079#1072#1082#1072#1079#1095#1080#1082#1072
        DynProps = <>
        TabOrder = 1
      end
      object dedt_End: TDBDateTimeEditEh
        Left = 112
        Top = 49
        Width = 97
        Height = 21
        ControlLabel.Width = 101
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072#13#10#1086#1082#1086#1085#1095#1072#1085#1080#1103' '#1084#1086#1085#1090#1072#1078#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 2
        Visible = True
      end
      object chb_RI: TDBCheckBoxEh
        Left = 280
        Top = 51
        Width = 200
        Height = 17
        Caption = #1047#1072#1084#1077#1095#1072#1085#1080#1103' '#1084#1086#1085#1090#1072#1078#1085#1080#1082#1086#1074
        DynProps = <>
        TabOrder = 3
      end
      object mem_Comm: TDBMemoEh
        Left = 8
        Top = 95
        Width = 472
        Height = 110
        ControlLabel.Width = 71
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081':'
        ControlLabel.Visible = True
        Lines.Strings = (
          'mem_Comm')
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 4
        Visible = True
        WantReturns = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 250
      Width = 491
      ExplicitTop = 249
      ExplicitWidth = 487
      inherited bvlFrmBtnsTl: TBevel
        Width = 489
        ExplicitWidth = 489
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 489
        ExplicitWidth = 489
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 489
        ExplicitWidth = 485
        inherited pnlFrmBtnsMain: TPanel
          Left = 390
          ExplicitLeft = 386
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 162
          ExplicitLeft = 158
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 291
          ExplicitLeft = 287
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 22
          ExplicitWidth = 18
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 294
    Width = 501
    ExplicitTop = 293
    ExplicitWidth = 497
    inherited lblStatusBarR: TLabel
      Left = 428
      Height = 14
      ExplicitLeft = 428
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
