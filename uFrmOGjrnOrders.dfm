inherited FrmOGjrnOrders: TFrmOGjrnOrders
  Caption = 'FrmOGjrnOrders'
  ClientHeight = 537
  ExplicitWidth = 800
  ExplicitHeight = 575
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Height = 521
    ExplicitWidth = 788
    ExplicitHeight = 521
    inherited pnlFrmClient: TPanel
      Height = 472
      ExplicitWidth = 774
      ExplicitHeight = 471
      inherited pnlTop: TPanel
        ExplicitWidth = 774
      end
      inherited pnlBottom: TPanel
        Top = 426
        ExplicitWidth = 774
      end
      inherited pnlLeft: TPanel
        Height = 417
      end
      inherited pnlGrid1: TPanel
        Height = 417
        ExplicitWidth = 764
        ExplicitHeight = 416
        inherited Frg1: TFrDBGridEh
          Height = 415
          ExplicitWidth = 762
          ExplicitHeight = 414
          inherited pnlGrid: TPanel
            Height = 361
            ExplicitWidth = 752
            inherited DbGridEh1: TDBGridEh
              Width = 754
              OnKeyDown = Frg1DbGridEh1KeyDown
            end
            inherited pnlStatusBar: TPanel
              Width = 754
              ExplicitTop = 339
            end
          end
          inherited pnlLeft: TPanel
            Height = 361
          end
          inherited pnlTop: TPanel
            ExplicitWidth = 762
          end
          inherited pnlContainer: TPanel
            ExplicitWidth = 762
          end
          inherited pnlBottom: TPanel
            Top = 415
            ExplicitWidth = 762
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
        Top = 431
        ExplicitTop = 430
        ExplicitWidth = 774
        inherited Frg2: TFrDBGridEh
          ExplicitWidth = 772
          inherited pnlGrid: TPanel
            ExplicitWidth = 762
            inherited DbGridEh1: TDBGridEh
              Width = 764
            end
            inherited pnlStatusBar: TPanel
              Width = 764
            end
          end
          inherited pnlTop: TPanel
            ExplicitWidth = 772
          end
          inherited pnlContainer: TPanel
            ExplicitWidth = 772
          end
          inherited pnlBottom: TPanel
            ExplicitWidth = 772
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
        Height = 417
        ExplicitLeft = 769
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 477
      ExplicitTop = 476
      ExplicitWidth = 774
      inherited bvlFrmBtnsTl: TBevel
        Width = 776
        ExplicitWidth = 780
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 776
        ExplicitWidth = 780
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 776
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 521
    ExplicitWidth = 784
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
