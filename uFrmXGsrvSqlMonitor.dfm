inherited FrmXGsrvSqlMonitor: TFrmXGsrvSqlMonitor
  Caption = 'FrmXGsrvSqlMonitor'
  ClientHeight = 411
  ClientWidth = 729
  OnDestroy = FormDestroy
  ExplicitWidth = 745
  ExplicitHeight = 450
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 729
    Height = 395
    ExplicitWidth = 729
    ExplicitHeight = 395
    inherited PMDIClient: TPanel
      Width = 719
      Height = 346
      ExplicitWidth = 719
      ExplicitHeight = 346
      inherited PTop: TPanel
        Width = 719
        ExplicitWidth = 719
      end
      inherited PBottom: TPanel
        Top = 300
        Width = 719
        ExplicitTop = 300
        ExplicitWidth = 719
      end
      inherited PLeft: TPanel
        Height = 291
        ExplicitHeight = 291
      end
      inherited PGrid1: TPanel
        Width = 709
        Height = 291
        ExplicitWidth = 709
        ExplicitHeight = 291
        inherited Frg1: TFrDBGridEh
          Width = 707
          Height = 289
          ExplicitWidth = 707
          ExplicitHeight = 289
          inherited PGrid: TPanel
            Width = 697
            Height = 235
            ExplicitWidth = 697
            ExplicitHeight = 235
            inherited DbGridEh1: TDBGridEh
              Width = 695
              Height = 212
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitTop = 35
                ExplicitHeight = 120
              end
            end
            inherited PStatus: TPanel
              Top = 213
              Width = 695
              ExplicitTop = 213
              ExplicitWidth = 695
            end
          end
          inherited PLeft: TPanel
            Height = 235
            ExplicitHeight = 235
          end
          inherited PTop: TPanel
            Width = 707
            ExplicitWidth = 707
          end
          inherited PContainer: TPanel
            Width = 707
            ExplicitWidth = 707
          end
          inherited PBottom: TPanel
            Top = 289
            Width = 707
            ExplicitTop = 289
            ExplicitWidth = 707
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
      inherited PFrg2: TPanel
        Top = 305
        Width = 719
        ExplicitTop = 305
        ExplicitWidth = 719
        inherited Frg2: TFrDBGridEh
          Width = 717
          ExplicitWidth = 717
          inherited PGrid: TPanel
            Width = 707
            ExplicitWidth = 707
            inherited DbGridEh1: TDBGridEh
              Width = 705
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitTop = 35
                ExplicitWidth = 32
              end
            end
            inherited PStatus: TPanel
              Width = 705
              ExplicitWidth = 705
            end
          end
          inherited PTop: TPanel
            Width = 717
            ExplicitWidth = 717
          end
          inherited PContainer: TPanel
            Width = 717
            ExplicitWidth = 717
          end
          inherited PBottom: TPanel
            Width = 717
            ExplicitWidth = 717
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
      inherited PRight: TPanel
        Left = 714
        Height = 291
        ExplicitLeft = 714
        ExplicitHeight = 291
      end
    end
    inherited PDlgPanel: TPanel
      Top = 351
      Width = 719
      ExplicitTop = 351
      ExplicitWidth = 719
      inherited BvDlg: TBevel
        Width = 717
        ExplicitWidth = 717
      end
      inherited BvDlgBottom: TBevel
        Width = 717
        ExplicitWidth = 717
      end
      inherited PDlgMain: TPanel
        Width = 717
        ExplicitWidth = 717
        inherited PDlgBtnForm: TPanel
          Left = 618
          ExplicitLeft = 618
        end
        inherited PDlgChb: TPanel
          Left = 390
          ExplicitLeft = 390
        end
        inherited PDlgBtnR: TPanel
          Left = 519
          ExplicitLeft = 519
        end
        inherited PDlgCenter: TPanel
          Width = 250
          ExplicitWidth = 250
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 395
    Width = 729
    ExplicitTop = 395
    ExplicitWidth = 729
    inherited LbStatusBarRight: TLabel
      Left = 637
      Height = 14
      ExplicitLeft = 637
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
