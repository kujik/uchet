inherited FrmAWOracleSessions: TFrmAWOracleSessions
  Caption = 'FrmAWOracleSessions'
  ClientWidth = 796
  ExplicitWidth = 808
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 796
    Height = 536
    ExplicitWidth = 796
    ExplicitHeight = 536
    inherited pnlFrmClient: TPanel
      Width = 786
      Height = 529
      ExplicitWidth = 782
      ExplicitHeight = 528
      inherited pnlTop: TPanel
        Width = 786
      end
      inherited pnlBottom: TPanel
        Top = 523
        Width = 786
        ExplicitTop = 522
      end
      inherited pnlLeft: TPanel
        Width = 193
        Height = 514
        ExplicitWidth = 193
        ExplicitHeight = 513
        object btnCloseModules: TBitBtn
          Left = 6
          Top = 483
          Width = 181
          Height = 25
          Anchors = [akLeft, akRight, akBottom]
          Caption = 'btnCloseModules'
          TabOrder = 0
          OnClick = btnCloseModulesClick
          ExplicitTop = 482
        end
        object nedtIdle: TDBNumberEditEh
          Left = 4
          Top = 456
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
          ExplicitTop = 455
        end
      end
      inherited pnlGrid1: TPanel
        Left = 193
        Width = 588
        Height = 514
        ExplicitLeft = 193
        ExplicitWidth = 584
        ExplicitHeight = 513
        inherited Frg1: TFrDBGridEh
          Width = 586
          Height = 512
          ExplicitWidth = 582
          ExplicitHeight = 511
          inherited pnlGrid: TPanel
            Width = 576
            Height = 458
            ExplicitWidth = 572
            ExplicitHeight = 457
            inherited DbGridEh1: TDBGridEh
              Width = 574
              Height = 435
            end
            inherited pnlStatusBar: TPanel
              Top = 436
              Width = 574
              ExplicitTop = 435
              ExplicitWidth = 570
            end
          end
          inherited pnlLeft: TPanel
            Height = 458
            ExplicitHeight = 457
          end
          inherited pnlTop: TPanel
            Width = 586
            ExplicitWidth = 582
          end
          inherited pnlContainer: TPanel
            Width = 586
            ExplicitWidth = 582
          end
          inherited pnlBottom: TPanel
            Top = 512
            Width = 586
            ExplicitTop = 511
            ExplicitWidth = 582
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
      end
      inherited pnlFrg2: TPanel
        Top = 528
        Width = 786
        Height = 1
        ExplicitTop = 527
        ExplicitWidth = 782
        ExplicitHeight = 1
        inherited Frg2: TFrDBGridEh
          Width = 784
          ExplicitWidth = 780
          inherited pnlGrid: TPanel
            Width = 774
            inherited DbGridEh1: TDBGridEh
              Width = 772
            end
            inherited pnlStatusBar: TPanel
              Width = 772
            end
          end
          inherited pnlTop: TPanel
            Width = 784
          end
          inherited pnlContainer: TPanel
            Width = 784
          end
          inherited pnlBottom: TPanel
            Width = 784
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
      end
      inherited pnlRight: TPanel
        Left = 781
        Height = 514
        ExplicitHeight = 513
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 534
      Width = 786
      Height = 1
      ExplicitTop = 533
      ExplicitWidth = 782
      ExplicitHeight = 1
      inherited bvlFrmBtnsTl: TBevel
        Width = 784
        ExplicitWidth = 784
      end
      inherited bvlFrmBtnsB: TBevel
        Top = -3
        Width = 784
        ExplicitTop = -3
        ExplicitWidth = 784
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 784
        ExplicitWidth = 780
        inherited pnlFrmBtnsMain: TPanel
          Left = 685
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 457
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 586
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 317
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 536
    Width = 796
    Height = 1
    ExplicitTop = 535
    ExplicitHeight = 1
    inherited lblStatusBarR: TLabel
      Left = 723
      ExplicitLeft = 723
    end
  end
  object tmr1: TTimer
    Interval = 5000
    OnTimer = tmr1Timer
    Left = 630
    Top = 281
  end
end
