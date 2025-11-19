inherited FrmOGrefOrStdItems: TFrmOGrefOrStdItems
  Caption = 'FrmOGrefOrStdItems'
  ClientHeight = 538
  OnDestroy = FormDestroy
  ExplicitWidth = 812
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Height = 522
    ExplicitHeight = 522
    inherited pnlFrmClient: TPanel
      Height = 473
      ExplicitWidth = 786
      inherited pnlBottom: TPanel
        Top = 427
        ExplicitTop = 426
      end
      inherited pnlLeft: TPanel
        Height = 418
        ExplicitHeight = 417
      end
      inherited pnlGrid1: TPanel
        Height = 418
        ExplicitWidth = 776
        inherited Frg1: TFrDBGridEh
          Height = 416
          ExplicitWidth = 774
          inherited pnlGrid: TPanel
            Height = 362
            ExplicitHeight = 361
            inherited DbGridEh1: TDBGridEh
              Height = 339
            end
            inherited pnlStatusBar: TPanel
              Top = 340
            end
          end
          inherited pnlLeft: TPanel
            Height = 362
            ExplicitHeight = 361
          end
          inherited pnlBottom: TPanel
            Top = 416
            ExplicitTop = 415
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
        Top = 432
        ExplicitWidth = 786
        inherited Frg2: TFrDBGridEh
          ExplicitWidth = 784
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
        Height = 418
        ExplicitHeight = 417
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 478
      inherited bvlFrmBtnsTl: TBevel
        ExplicitWidth = 788
      end
      inherited bvlFrmBtnsB: TBevel
        ExplicitWidth = 788
      end
      inherited pnlFrmBtnsContainer: TPanel
        ExplicitWidth = 784
        inherited pnlFrmBtnsChb: TPanel
          ExplicitLeft = 457
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 522
    ExplicitTop = 521
    inherited lblStatusBarR: TLabel
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    OnTimer = tmrAfterCreateTimer
  end
end
