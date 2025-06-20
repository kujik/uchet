inherited FrmOGedtEstimate: TFrmOGedtEstimate
  Caption = 'FrmOGedtEstimate'
  ClientHeight = 399
  ClientWidth = 676
  ExplicitWidth = 688
  ExplicitHeight = 437
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 676
    Height = 383
    ExplicitWidth = 796
    ExplicitHeight = 520
    inherited PMDIClient: TPanel
      Width = 666
      Height = 334
      ExplicitWidth = 782
      ExplicitHeight = 470
      inherited PTop: TPanel
        Width = 666
        ExplicitWidth = 782
      end
      inherited PBottom: TPanel
        Top = 288
        Width = 666
        ExplicitTop = 424
        ExplicitWidth = 782
      end
      inherited PLeft: TPanel
        Height = 279
        ExplicitHeight = 415
      end
      inherited PGrid1: TPanel
        Width = 656
        Height = 279
        ExplicitWidth = 772
        ExplicitHeight = 415
        inherited Frg1: TFrDBGridEh
          Width = 654
          Height = 277
          ExplicitWidth = 770
          ExplicitHeight = 413
          inherited PGrid: TPanel
            Width = 644
            Height = 223
            ExplicitWidth = 760
            ExplicitHeight = 359
            inherited DbGridEh1: TDBGridEh
              Width = 642
              Height = 200
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitTop = 35
                ExplicitHeight = 120
              end
            end
            inherited PStatus: TPanel
              Top = 201
              Width = 642
              ExplicitTop = 337
              ExplicitWidth = 758
            end
          end
          inherited PLeft: TPanel
            Height = 223
            ExplicitHeight = 359
          end
          inherited PTop: TPanel
            Width = 654
            ExplicitWidth = 770
          end
          inherited PContainer: TPanel
            Width = 654
            ExplicitWidth = 770
          end
          inherited PBottom: TPanel
            Top = 277
            Width = 654
            ExplicitTop = 413
            ExplicitWidth = 770
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
        Top = 293
        Width = 666
        ExplicitTop = 429
        ExplicitWidth = 782
        inherited Frg2: TFrDBGridEh
          Width = 664
          ExplicitWidth = 780
          inherited PGrid: TPanel
            Width = 654
            ExplicitWidth = 770
            inherited DbGridEh1: TDBGridEh
              Width = 652
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitTop = 35
                ExplicitWidth = 32
              end
            end
            inherited PStatus: TPanel
              Width = 652
              ExplicitWidth = 768
            end
          end
          inherited PTop: TPanel
            Width = 664
            ExplicitWidth = 780
          end
          inherited PContainer: TPanel
            Width = 664
            ExplicitWidth = 780
          end
          inherited PBottom: TPanel
            Width = 664
            ExplicitWidth = 780
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
        Left = 661
        Height = 279
        ExplicitLeft = 777
        ExplicitHeight = 415
      end
    end
    inherited PDlgPanel: TPanel
      Top = 339
      Width = 666
      ExplicitTop = 475
      ExplicitWidth = 782
      inherited BvDlg: TBevel
        Width = 664
      end
      inherited BvDlgBottom: TBevel
        Width = 664
      end
      inherited PDlgMain: TPanel
        Width = 664
        ExplicitWidth = 780
        inherited PDlgBtnForm: TPanel
          Left = 565
          ExplicitLeft = 681
        end
        inherited PDlgChb: TPanel
          Left = 337
          ExplicitLeft = 453
        end
        inherited PDlgBtnR: TPanel
          Left = 466
          ExplicitLeft = 582
        end
        inherited PDlgCenter: TPanel
          Width = 197
          ExplicitWidth = 313
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 383
    Width = 676
    ExplicitTop = 519
    ExplicitWidth = 792
    inherited LbStatusBarRight: TLabel
      Left = 584
      Height = 14
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
