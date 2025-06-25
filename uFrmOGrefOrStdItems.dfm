inherited FrmOGrefOrStdItems: TFrmOGrefOrStdItems
  Caption = 'FrmOGrefOrStdItems'
  ClientWidth = 800
  OnDestroy = FormDestroy
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 800
    inherited PMDIClient: TPanel
      Width = 790
      ExplicitWidth = 790
      inherited PTop: TPanel
        Width = 790
      end
      inherited PBottom: TPanel
        Width = 790
      end
      inherited PGrid1: TPanel
        Width = 780
        ExplicitWidth = 780
        inherited Frg1: TFrDBGridEh
          Width = 778
          inherited PGrid: TPanel
            Width = 768
            inherited DbGridEh1: TDBGridEh
              Height = 337
            end
            inherited PStatus: TPanel
              Top = 338
            end
          end
          inherited PTop: TPanel
            Width = 778
          end
          inherited PContainer: TPanel
            Width = 778
          end
          inherited PBottom: TPanel
            Width = 778
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
      inherited PFrg2: TPanel
        Width = 790
        inherited Frg2: TFrDBGridEh
          Width = 788
          inherited PGrid: TPanel
            Width = 778
          end
          inherited PTop: TPanel
            Width = 788
          end
          inherited PContainer: TPanel
            Width = 788
          end
          inherited PBottom: TPanel
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
      inherited PRight: TPanel
        Left = 785
      end
    end
    inherited PDlgPanel: TPanel
      Width = 790
      ExplicitTop = 476
      inherited BvDlg: TBevel
        ExplicitWidth = 788
      end
      inherited BvDlgBottom: TBevel
        ExplicitWidth = 788
      end
    end
  end
  inherited PStatusBar: TPanel
    Width = 800
    inherited LbStatusBarRight: TLabel
      Height = 14
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
  inherited Timer_AfterStart: TTimer
    OnTimer = Timer_AfterStartTimer
  end
end
