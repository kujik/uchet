inherited FrmOGrefOrStdItems: TFrmOGrefOrStdItems
  Caption = 'FrmOGrefOrStdItems'
  OnDestroy = FormDestroy
  ExplicitWidth = 808
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    ExplicitWidth = 796
    inherited pnlFrmClient: TPanel
      ExplicitWidth = 782
      inherited pnlTop: TPanel
        ExplicitWidth = 782
      end
      inherited pnlBottom: TPanel
        ExplicitWidth = 782
      end
      inherited pnlGrid1: TPanel
        ExplicitWidth = 772
        inherited Frg1: TFrDBGridEh
          ExplicitWidth = 770
          inherited pnlGrid: TPanel
            ExplicitWidth = 760
            inherited DbGridEh1: TDBGridEh
              Width = 762
              Height = 337
            end
            inherited pnlStatusBar: TPanel
              Top = 338
              Width = 762
            end
          end
          inherited pnlTop: TPanel
            ExplicitWidth = 770
          end
          inherited pnlContainer: TPanel
            ExplicitWidth = 770
          end
          inherited pnlBottom: TPanel
            ExplicitWidth = 770
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
        ExplicitWidth = 782
        inherited Frg2: TFrDBGridEh
          ExplicitWidth = 780
          inherited pnlGrid: TPanel
            ExplicitWidth = 770
            inherited DbGridEh1: TDBGridEh
              Width = 772
            end
            inherited pnlStatusBar: TPanel
              Width = 772
            end
          end
          inherited pnlTop: TPanel
            ExplicitWidth = 780
          end
          inherited pnlContainer: TPanel
            ExplicitWidth = 780
          end
          inherited pnlBottom: TPanel
            ExplicitWidth = 780
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
        ExplicitLeft = 777
      end
    end
    inherited pnlFrmBtns: TPanel
      ExplicitTop = 476
      ExplicitWidth = 782
      inherited bvlFrmBtnsTl: TBevel
        Width = 784
        ExplicitWidth = 788
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 784
        ExplicitWidth = 788
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
    ExplicitWidth = 792
    inherited lblStatusBarR: TLabel
      Left = 723
      Height = 14
      ExplicitLeft = 723
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    OnTimer = tmrAfterCreateTimer
  end
end
