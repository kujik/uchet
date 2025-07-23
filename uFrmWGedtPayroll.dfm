inherited FrmWGedtPayroll: TFrmWGedtPayroll
  Caption = 'FrmWGedtPayroll'
  ClientWidth = 800
  ExplicitHeight = 574
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 800
    ExplicitHeight = 520
    inherited pnlFrmClient: TPanel
      Width = 790
      inherited pnlTop: TPanel
        Width = 790
      end
      inherited pnlBottom: TPanel
        Width = 790
      end
      inherited pnlGrid1: TPanel
        Width = 780
        inherited Frg1: TFrDBGridEh
          Width = 778
          inherited pnlGrid: TPanel
            Width = 768
            inherited DbGridEh1: TDBGridEh
              Height = 337
              OnApplyFilter = Frg1DbGridEh1ApplyFilter
            end
            inherited pnlStatusBar: TPanel
              Top = 338
            end
          end
          inherited pnlTop: TPanel
            Width = 778
          end
          inherited pnlContainer: TPanel
            Width = 778
          end
          inherited pnlBottom: TPanel
            Width = 778
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
        Width = 790
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
        Left = 785
      end
    end
    inherited pnlFrmBtns: TPanel
      Width = 790
      inherited bvlFrmBtnsTl: TBevel
        Width = 788
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 788
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 788
        ExplicitWidth = 788
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Width = 800
    inherited lblStatusBarR: TLabel
      Left = 727
      Height = 14
      ExplicitLeft = 727
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  object PrintDBGridEh1: TPrintDBGridEh
    DBGridEh = Frg1.DbGridEh1
    Options = [pghColored, pghRowAutoStretch]
    PageFooter.Font.Charset = DEFAULT_CHARSET
    PageFooter.Font.Color = clWindowText
    PageFooter.Font.Height = -11
    PageFooter.Font.Name = 'Tahoma'
    PageFooter.Font.Style = []
    PageHeader.Font.Charset = DEFAULT_CHARSET
    PageHeader.Font.Color = clWindowText
    PageHeader.Font.Height = -11
    PageHeader.Font.Name = 'Tahoma'
    PageHeader.Font.Style = []
    Units = MM
    Left = 708
    Top = 99
    BeforeGridText_Data = {
      7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
      7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
      305C666E696C5C666368617273657430205461686F6D613B7D7B5C66315C666E
      696C5C6663686172736574323034205461686F6D613B7D7D0D0A7B5C2A5C6765
      6E657261746F722052696368656432302031302E302E31393034317D5C766965
      776B696E64345C756331200D0A5C706172645C66305C667332385C6C616E6731
      303333207361736173617361646173615C66315C667331365C6C616E67313034
      395C7061720D0A7D0D0A00}
  end
end
