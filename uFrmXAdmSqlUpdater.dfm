inherited FrmXAdmSqlUpdater: TFrmXAdmSqlUpdater
  Caption = 'FrmXAdmSqlUpdater'
  ClientHeight = 480
  ClientWidth = 820
  ExplicitWidth = 832
  ExplicitHeight = 518
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 820
    Height = 464
    ExplicitWidth = 820
    ExplicitHeight = 464
    inherited pnlFrmClient: TPanel
      Width = 810
      Height = 415
      ExplicitWidth = 806
      ExplicitHeight = 414
      inherited pnlTop: TPanel
        Width = 810
        ExplicitWidth = 806
      end
      inherited pnlBottom: TPanel
        Top = 369
        Width = 810
        ExplicitTop = 368
        ExplicitWidth = 806
      end
      inherited pnlLeft: TPanel
        Height = 360
        ExplicitHeight = 359
      end
      inherited pnlGrid1: TPanel
        Width = 800
        Height = 360
        ExplicitWidth = 796
        ExplicitHeight = 359
        inherited Frg1: TFrDBGridEh
          Width = 798
          Height = 358
          ExplicitWidth = 794
          ExplicitHeight = 357
          inherited pnlGrid: TPanel
            Width = 788
            Height = 304
            ExplicitWidth = 784
            ExplicitHeight = 303
            inherited DbGridEh1: TDBGridEh
              Width = 786
              Height = 281
            end
            inherited pnlStatusBar: TPanel
              Top = 282
              Width = 786
              ExplicitTop = 281
              ExplicitWidth = 782
            end
          end
          inherited pnlLeft: TPanel
            Height = 304
            ExplicitHeight = 303
          end
          inherited pnlTop: TPanel
            Width = 798
            ExplicitWidth = 794
          end
          inherited pnlContainer: TPanel
            Width = 798
            ExplicitWidth = 794
          end
          inherited pnlBottom: TPanel
            Top = 358
            Width = 798
            ExplicitTop = 357
            ExplicitWidth = 794
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E32363130307D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
              63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
              3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
              333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlFrg2: TPanel
        Top = 374
        Width = 810
        ExplicitTop = 373
        ExplicitWidth = 806
        inherited Frg2: TFrDBGridEh
          Width = 808
          ExplicitWidth = 804
          inherited pnlGrid: TPanel
            Width = 798
            ExplicitWidth = 794
            inherited DbGridEh1: TDBGridEh
              Width = 796
            end
            inherited pnlStatusBar: TPanel
              Width = 796
              ExplicitWidth = 792
            end
          end
          inherited pnlTop: TPanel
            Width = 808
            ExplicitWidth = 804
          end
          inherited pnlContainer: TPanel
            Width = 808
            ExplicitWidth = 804
          end
          inherited pnlBottom: TPanel
            Width = 808
            ExplicitWidth = 804
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
        Left = 805
        Height = 360
        ExplicitLeft = 801
        ExplicitHeight = 359
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 420
      Width = 810
      ExplicitTop = 419
      ExplicitWidth = 806
      inherited bvlFrmBtnsTl: TBevel
        Width = 808
        ExplicitWidth = 808
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 808
        ExplicitWidth = 808
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 808
        ExplicitWidth = 804
        inherited pnlFrmBtnsMain: TPanel
          Left = 709
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 481
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 610
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 341
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 464
    Width = 820
    ExplicitTop = 463
    ExplicitWidth = 816
    inherited lblStatusBarR: TLabel
      Left = 747
      Height = 14
      ExplicitLeft = 747
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  object OpenLogDialog: TOpenDialog
    Filter = '*.log|*.log|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Left = 40
    Top = 424
  end
end
