inherited FrmOGinfSgp: TFrmOGinfSgp
  Caption = 'FrmOGinfSgp'
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    inherited pnlFrmClient: TPanel
      inherited pnlTop: TPanel
        Height = 25
        ExplicitHeight = 25
        object lblCaption: TLabel
          Left = 11
          Top = 7
          Width = 47
          Height = 13
          Caption = 'lblCaption'
        end
      end
      inherited pnlLeft: TPanel
        Top = 25
        Height = 401
        ExplicitTop = 25
        ExplicitHeight = 400
      end
      inherited pnlGrid1: TPanel
        Top = 25
        Height = 401
        ExplicitTop = 25
        ExplicitHeight = 401
        inherited Frg1: TFrDBGridEh
          Height = 399
          ExplicitHeight = 399
          inherited pnlGrid: TPanel
            Height = 345
            ExplicitHeight = 344
            inherited DbGridEh1: TDBGridEh
              Height = 322
            end
            inherited pnlStatusBar: TPanel
              Top = 323
              ExplicitTop = 322
            end
          end
          inherited pnlLeft: TPanel
            Height = 345
            ExplicitHeight = 344
          end
          inherited pnlBottom: TPanel
            Top = 399
            ExplicitTop = 398
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E31393034317D5C766965
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
        inherited Frg2: TFrDBGridEh
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E31393034317D5C766965
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
        Top = 25
        Height = 401
        ExplicitTop = 25
        ExplicitHeight = 400
      end
    end
  end
  inherited pnlStatusBar: TPanel
    inherited lblStatusBarR: TLabel
      Left = 727
      ExplicitLeft = 727
    end
  end
end
