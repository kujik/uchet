inherited FrmTestMdi1: TFrmTestMdi1
  Caption = 'FrmTestMdi1'
  ClientHeight = 495
  ClientWidth = 620
  ExplicitWidth = 636
  ExplicitHeight = 533
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 620
    Height = 479
    ExplicitWidth = 620
    ExplicitHeight = 479
    inherited pnlFrmClient: TPanel
      Width = 610
      Height = 433
      ExplicitWidth = 610
      ExplicitHeight = 433
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
        Width = 189
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 4
        Text = 'top'
        Visible = True
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
        Width = 189
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
      Top = 438
      Width = 610
      Height = 40
      ExplicitTop = 438
      ExplicitWidth = 610
      ExplicitHeight = 40
      inherited bvlFrmBtnsTl: TBevel
        Width = 608
        ExplicitWidth = 419
      end
      inherited bvlFrmBtnsB: TBevel
        Top = 36
        Width = 608
        ExplicitTop = 36
        ExplicitWidth = 419
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 608
        Height = 32
        ExplicitWidth = 608
        ExplicitHeight = 32
        inherited pnlFrmBtnsMain: TPanel
          Left = 509
          Height = 24
          ExplicitLeft = 509
          ExplicitHeight = 24
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 281
          Height = 24
          ExplicitLeft = 281
          ExplicitHeight = 24
          inherited chbNoclose: TCheckBox
            Top = -63
            ExplicitTop = -63
          end
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 410
          Height = 24
          ExplicitLeft = 410
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
          Width = 141
          Height = 24
          ExplicitWidth = 141
          ExplicitHeight = 24
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 479
    Width = 620
    ExplicitTop = 479
    ExplicitWidth = 620
    inherited lblStatusBarR: TLabel
      Left = 528
      Height = 14
      ExplicitLeft = 528
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 96
    Top = 368
  end
end
