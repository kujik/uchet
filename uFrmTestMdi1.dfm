inherited FrmTestMdi1: TFrmTestMdi1
  Caption = 'FrmTestMdi1'
  ClientHeight = 493
  ClientWidth = 612
  ExplicitWidth = 628
  ExplicitHeight = 532
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 612
    Height = 477
    ExplicitWidth = 612
    ExplicitHeight = 477
    inherited pnlFrmClient: TPanel
      Width = 606
      Height = 432
      ExplicitWidth = 602
      ExplicitHeight = 431
      object l1: TLabel
        Left = 176
        Top = 26
        Width = 16
        Height = 13
        Caption = 'top'
      end
      object l2: TLabel
        Left = 104
        Top = 45
        Width = 210
        Height = 13
        Caption = '22222222222222222222222222222222222'
      end
      object bv3: TBevel
        Left = 32
        Top = 63
        Width = 305
        Height = 3
      end
      object bvl1: TBevel
        Tag = -100
        Left = 25
        Top = 175
        Width = 305
        Height = 3
        ParentShowHint = False
        ShowHint = False
      end
      object edt_1: TDBEditEh
        Left = 33
        Top = 18
        Width = 121
        Height = 21
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Text = 'top'
        Visible = True
      end
      object bt_44: TBitBtn
        Left = 240
        Top = 18
        Width = 21
        Height = 21
        Caption = 'bt_44'
        TabOrder = 1
      end
      object e4: TDBEditEh
        Left = 33
        Top = 72
        Width = 48
        Height = 21
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Text = '44444444444444444444444'
        Visible = True
      end
      object chb4: TCheckBox
        Left = 160
        Top = 82
        Width = 97
        Height = 17
        Caption = '44444444444444444'
        TabOrder = 3
      end
      object DBEditEh1: TDBEditEh
        Left = 169
        Top = 129
        Width = 181
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 4
        Text = 'top'
        Visible = True
        ExplicitWidth = 177
      end
      object DBEditEh2: TDBEditEh
        Left = 25
        Top = 129
        Width = 112
        Height = 21
        ControlLabel.Width = 12
        ControlLabel.Height = 39
        ControlLabel.Caption = '11'#13#10'22'#13#10'33'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 5
        Text = 'top'
        Visible = True
      end
      object DBMemoEh1: TDBMemoEh
        Left = 25
        Top = 225
        Width = 181
        Height = 38
        ControlLabel.Width = 59
        ControlLabel.Height = 26
        ControlLabel.Caption = 'DBMemoEh1'#13#10#1087#1086#1083#1077' '#1074#1074#1086#1076#1072
        ControlLabel.Visible = True
        Lines.Strings = (
          'DBMemoEh'
          '1')
        Anchors = [akLeft, akTop, akRight, akBottom]
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 6
        Visible = True
        WantReturns = True
      end
      object DBEditEh3: TDBEditEh
        Left = 140
        Top = 287
        Width = 121
        Height = 21
        DynProps = <>
        EditButtons = <>
        TabOrder = 7
        Text = 'top'
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 436
      Width = 602
      Height = 40
      ExplicitTop = 436
      ExplicitWidth = 602
      ExplicitHeight = 40
      inherited bvlFrmBtnsTl: TBevel
        Width = 604
        ExplicitWidth = 419
      end
      inherited bvlFrmBtnsB: TBevel
        Top = 36
        Width = 604
        ExplicitTop = 36
        ExplicitWidth = 419
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 604
        Height = 32
        ExplicitWidth = 600
        ExplicitHeight = 32
        inherited pnlFrmBtnsMain: TPanel
          Left = 505
          Height = 24
          ExplicitLeft = 501
          ExplicitHeight = 24
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 277
          Height = 24
          ExplicitLeft = 273
          ExplicitHeight = 24
          inherited chbNoclose: TCheckBox
            Top = -63
            ExplicitTop = -63
          end
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 406
          Height = 24
          ExplicitLeft = 402
          ExplicitHeight = 24
        end
        inherited pnlFrmBtnsInfo: TPanel
          Height = 24
          ExplicitHeight = 24
        end
        inherited pnlFrmBtnsL: TPanel
          Height = 24
          ExplicitHeight = 24
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 137
          Height = 24
          ExplicitWidth = 133
          ExplicitHeight = 24
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 477
    Width = 612
    ExplicitTop = 477
    ExplicitWidth = 612
    inherited lblStatusBarR: TLabel
      Left = 543
      ExplicitLeft = 543
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 96
    Top = 368
  end
end
