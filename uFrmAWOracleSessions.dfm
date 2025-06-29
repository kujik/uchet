inherited FrmAWOracleSessions: TFrmAWOracleSessions
  Caption = 'FrmAWOracleSessions'
  ClientWidth = 800
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 800
    Height = 535
    ExplicitHeight = 536
    inherited pnlFrmClient: TPanel
      Width = 790
      Height = 528
      ExplicitHeight = 528
      inherited pnlTop: TPanel
        Width = 790
      end
      inherited pnlBottom: TPanel
        Top = 522
        Width = 790
        ExplicitTop = 522
      end
      inherited pnlLeft: TPanel
        Width = 193
        Height = 513
        ExplicitWidth = 193
        ExplicitHeight = 513
        object btnCloseModules: TBitBtn
          Left = 6
          Top = 482
          Width = 181
          Height = 25
          Anchors = [akLeft, akRight, akBottom]
          Caption = 'btnCloseModules'
          TabOrder = 0
          OnClick = btnCloseModulesClick
        end
        object nedtIdle: TDBNumberEditEh
          Left = 4
          Top = 455
          Width = 97
          Height = 21
          ControlLabel.Width = 103
          ControlLabel.Height = 13
          ControlLabel.Caption = #1042#1088#1077#1084#1103' '#1087#1088#1086#1089#1090#1086#1103', '#1084#1080#1085'.'
          ControlLabel.Visible = True
          Anchors = [akLeft, akBottom]
          DecimalPlaces = 0
          DynProps = <>
          EditButtons = <>
          MaxValue = 9999.000000000000000000
          MinValue = 5.000000000000000000
          TabOrder = 1
          Visible = True
        end
      end
      inherited pnlGrid1: TPanel
        Left = 193
        Width = 592
        Height = 513
        ExplicitLeft = 193
        ExplicitWidth = 588
        ExplicitHeight = 513
        inherited Frg1: TFrDBGridEh
          Width = 590
          Height = 511
          ExplicitWidth = 586
          ExplicitHeight = 511
          inherited pnlGrid: TPanel
            Width = 580
            Height = 457
            ExplicitWidth = 576
            ExplicitHeight = 457
            inherited DbGridEh1: TDBGridEh
              Width = 578
              Height = 434
            end
            inherited pnlStatusBar: TPanel
              Top = 435
              Width = 578
              ExplicitTop = 435
              ExplicitWidth = 574
            end
          end
          inherited pnlLeft: TPanel
            Height = 457
            ExplicitHeight = 457
          end
          inherited pnlTop: TPanel
            Width = 590
            ExplicitWidth = 586
          end
          inherited pnlContainer: TPanel
            Width = 590
            ExplicitWidth = 586
          end
          inherited pnlBottom: TPanel
            Top = 511
            Width = 590
            ExplicitTop = 511
            ExplicitWidth = 586
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E32323030307D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
              66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
              720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
              205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
              34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
              305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlFrg2: TPanel
        Top = 527
        Width = 790
        Height = 1
        ExplicitTop = 527
        ExplicitHeight = 1
        inherited Frg2: TFrDBGridEh
          Width = 788
          inherited pnlGrid: TPanel
            Width = 778
          end
          inherited pnlTop: TPanel
            Width = 788
          end
          inherited pnlContainer: TPanel
            Width = 788
          end
          inherited pnlBottom: TPanel
            Width = 788
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E32323030307D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
              66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
              720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
              205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
              34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
              305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlRight: TPanel
        Left = 785
        Height = 513
        ExplicitHeight = 513
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 533
      Width = 790
      Height = 1
      ExplicitTop = 533
      ExplicitHeight = 1
      inherited bvlFrmBtnsB: TBevel
        Top = -3
        ExplicitTop = -3
      end
      inherited pnlFrmBtnsContainer: TPanel
        inherited pnlFrmBtnsChb: TPanel
          ExplicitLeft = 457
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 535
    Width = 800
    Height = 1
    ExplicitTop = 535
    ExplicitHeight = 1
    inherited lblStatusBarR: TLabel
      Left = 727
    end
  end
  object tmr1: TTimer
    Interval = 5000
    OnTimer = tmr1Timer
    Left = 630
    Top = 281
  end
end
