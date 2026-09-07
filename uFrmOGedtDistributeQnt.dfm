inherited FrmOGedtDistributeQnt: TFrmOGedtDistributeQnt
  Caption = 'FrmOGedtDistributeQnt'
  ExplicitWidth = 800
  ExplicitHeight = 572
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    ExplicitHeight = 518
    inherited pnlFrmClient: TPanel
      ExplicitWidth = 774
      inherited pnlTop: TPanel
        Height = 55
        ExplicitHeight = 55
        object lblCapt1: TLabel
          Left = 12
          Top = 8
          Width = 46
          Height = 13
          Caption = 'lblCapt1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblCapt2: TLabel
          Left = 12
          Top = 27
          Width = 39
          Height = 13
          Caption = 'lblCapt2'
        end
      end
      inherited pnlLeft: TPanel
        Top = 55
        Height = 368
        ExplicitTop = 55
        ExplicitHeight = 367
      end
      inherited pnlGrid1: TPanel
        Top = 55
        Height = 368
        ExplicitTop = 55
        ExplicitWidth = 764
        ExplicitHeight = 367
        inherited Frg1: TFrDBGridEh
          Height = 366
          ExplicitWidth = 762
          ExplicitHeight = 365
          inherited pnlGrid: TPanel
            Height = 312
            ExplicitHeight = 311
            inherited DbGridEh1: TDBGridEh
              Width = 754
              Height = 289
            end
            inherited pnlStatusBar: TPanel
              Top = 290
              Width = 754
              ExplicitTop = 289
              ExplicitWidth = 750
            end
          end
          inherited pnlLeft: TPanel
            Height = 312
            ExplicitHeight = 311
          end
          inherited pnlBottom: TPanel
            Top = 366
            ExplicitTop = 365
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
        ExplicitWidth = 774
        inherited Frg2: TFrDBGridEh
          ExplicitWidth = 772
          inherited pnlGrid: TPanel
            inherited DbGridEh1: TDBGridEh
              Width = 764
            end
            inherited pnlStatusBar: TPanel
              Width = 764
              ExplicitWidth = 760
            end
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
        Top = 55
        Height = 368
        ExplicitTop = 55
        ExplicitHeight = 367
      end
    end
  end
  inherited pnlStatusBar: TPanel
    inherited lblStatusBarR: TLabel
      Left = 715
      Height = 14
      ExplicitLeft = 715
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
