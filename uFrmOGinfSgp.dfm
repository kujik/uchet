inherited FrmOGinfSgp: TFrmOGinfSgp
  Caption = 'FrmOGinfSgp'
  ExplicitWidth = 320
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    inherited pnlFrmClient: TPanel
      inherited pnlTop: TPanel
        Height = 25
        ExplicitHeight = 25
        object lblCaption: TLabel
          Left = 11
          Top = 7
          Width = 48
          Height = 13
          Caption = 'lblCaption'
        end
      end
      inherited pnlLeft: TPanel
        Top = 25
        Height = 401
        ExplicitTop = 25
        ExplicitHeight = 401
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
            ExplicitHeight = 345
            inherited DbGridEh1: TDBGridEh
              Height = 322
            end
            inherited pnlStatusBar: TPanel
              Top = 323
              ExplicitTop = 323
            end
          end
          inherited pnlLeft: TPanel
            Height = 345
            ExplicitHeight = 345
          end
          inherited pnlBottom: TPanel
            Top = 399
            ExplicitTop = 399
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6465
              666C616E67313034397B5C666F6E7474626C7B5C66305C666E696C5C66636861
              72736574323034205461686F6D613B7D7B5C66315C666E696C5C666368617273
              657430205461686F6D613B7D7D0D0A5C766965776B696E64345C7563315C7061
              72645C66305C667331365C2763665C2766305C2765655C2765355C2765615C27
              66323A20255B50726F656B745D5C7061720D0A5C2763665C2765355C2766305C
              2765385C2765655C276534205C276631205C6C616E67313033335C6631202025
              5B4474315D205C6C616E67313034395C66305C2765665C2765655C6C616E6731
              3033335C66312020255B4474325D5C6C616E67313034395C66305C7061720D0A
              5C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlFrg2: TPanel
        inherited Frg2: TFrDBGridEh
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6465
              666C616E67313034397B5C666F6E7474626C7B5C66305C666E696C5C66636861
              72736574323034205461686F6D613B7D7B5C66315C666E696C5C666368617273
              657430205461686F6D613B7D7D0D0A5C766965776B696E64345C7563315C7061
              72645C66305C667331365C2763665C2766305C2765655C2765355C2765615C27
              66323A20255B50726F656B745D5C7061720D0A5C2763665C2765355C2766305C
              2765385C2765655C276534205C276631205C6C616E67313033335C6631202025
              5B4474315D205C6C616E67313034395C66305C2765665C2765655C6C616E6731
              3033335C66312020255B4474325D5C6C616E67313034395C66305C7061720D0A
              5C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlRight: TPanel
        Top = 25
        Height = 401
        ExplicitTop = 25
        ExplicitHeight = 401
      end
    end
  end
end
