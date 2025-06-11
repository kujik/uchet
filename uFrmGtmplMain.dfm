inherited FrmBasicGrid2: TFrmBasicGrid2
  Caption = 'FrmBasicGrid2'
  ClientHeight = 537
  ClientWidth = 800
  ExplicitWidth = 816
  ExplicitHeight = 576
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 800
    Height = 521
    ExplicitWidth = 800
    ExplicitHeight = 521
    inherited PMDIClient: TPanel
      Width = 790
      Height = 472
      ExplicitWidth = 790
      ExplicitHeight = 472
      object PTop: TPanel
        Left = 0
        Top = 0
        Width = 790
        Height = 9
        Align = alTop
        Caption = 'PTop'
        TabOrder = 0
      end
      object PBottom: TPanel
        Left = 0
        Top = 426
        Width = 790
        Height = 5
        Align = alBottom
        Caption = 'PBottom'
        TabOrder = 1
      end
      object PLeft: TPanel
        Left = 0
        Top = 9
        Width = 5
        Height = 417
        Align = alLeft
        Caption = 'PLeft'
        TabOrder = 2
      end
      object PGrid1: TPanel
        Left = 5
        Top = 9
        Width = 780
        Height = 417
        Align = alClient
        Caption = 'PGrid1'
        TabOrder = 3
        object ImgTemp: TImage
          Left = 720
          Top = 2
          Width = 24
          Height = 24
        end
        inline Frg1: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 778
          Height = 415
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 778
          ExplicitHeight = 415
          inherited PGrid: TPanel
            Width = 768
            Height = 361
            ExplicitWidth = 768
            ExplicitHeight = 361
            inherited DbGridEh1: TDBGridEh
              Width = 766
              Height = 338
              OnGetCellParams = Frg1DbGridEh1GetCellParams
              Columns = <
                item
                  CellButtons = <>
                  DynProps = <>
                  EditButtons = <>
                  FieldName = 'iii'
                  Footers = <>
                end>
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitWidth = 46
                inherited PRowDetailPanel: TPanel
                  Width = 44
                  ExplicitWidth = 44
                end
              end
            end
            inherited PStatus: TPanel
              Top = 339
              Width = 766
              ExplicitTop = 339
              ExplicitWidth = 766
            end
          end
          inherited PLeft: TPanel
            Height = 361
            ExplicitHeight = 361
          end
          inherited PTop: TPanel
            Width = 778
            ExplicitWidth = 778
          end
          inherited PContainer: TPanel
            Width = 778
            ExplicitWidth = 778
          end
          inherited PBottom: TPanel
            Top = 415
            Width = 778
            ExplicitTop = 415
            ExplicitWidth = 778
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
      object PFrg2: TPanel
        Left = 0
        Top = 431
        Width = 790
        Height = 41
        Align = alBottom
        Caption = 'PFrg2'
        TabOrder = 4
        inline Frg2: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 788
          Height = 39
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 788
          ExplicitHeight = 39
          inherited PGrid: TPanel
            Top = 34
            Width = 778
            Height = 5
            ExplicitTop = 34
            ExplicitWidth = 778
            ExplicitHeight = 5
            inherited DbGridEh1: TDBGridEh
              Width = 776
              Height = 41
              OnGetCellParams = Frg2DbGridEh1GetCellParams
              Columns = <
                item
                  CellButtons = <>
                  DynProps = <>
                  EditButtons = <>
                  Footers = <>
                end>
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitHeight = 2
                inherited PRowDetailPanel: TPanel
                  Height = 0
                  ExplicitHeight = 0
                end
              end
            end
            inherited PStatus: TPanel
              Top = -17
              Width = 776
              ExplicitTop = -17
              ExplicitWidth = 776
            end
          end
          inherited PLeft: TPanel
            Top = 34
            Height = 5
            ExplicitTop = 34
            ExplicitHeight = 5
          end
          inherited PTop: TPanel
            Top = 29
            Width = 788
            ExplicitTop = 29
            ExplicitWidth = 788
          end
          inherited PContainer: TPanel
            Width = 788
            Height = 29
            ExplicitWidth = 788
            ExplicitHeight = 29
          end
          inherited PBottom: TPanel
            Top = 39
            Width = 788
            ExplicitTop = 39
            ExplicitWidth = 788
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
      object PRight: TPanel
        Left = 785
        Top = 9
        Width = 5
        Height = 417
        Align = alRight
        Caption = 'PLeft'
        TabOrder = 5
      end
    end
    inherited PDlgPanel: TPanel
      Top = 477
      Width = 790
      ExplicitTop = 477
      ExplicitWidth = 790
      inherited BvDlg: TBevel
        Width = 788
        ExplicitWidth = 506
      end
      inherited BvDlgBottom: TBevel
        Width = 788
        ExplicitWidth = 506
      end
      inherited PDlgMain: TPanel
        Width = 788
        ExplicitWidth = 788
        inherited PDlgBtnForm: TPanel
          Left = 689
          ExplicitLeft = 689
        end
        inherited PDlgChb: TPanel
          Left = 461
          ExplicitLeft = 461
        end
        inherited PDlgBtnR: TPanel
          Left = 590
          ExplicitLeft = 590
        end
        inherited PDlgCenter: TPanel
          Width = 321
          ExplicitWidth = 321
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 521
    Width = 800
    ExplicitTop = 521
    ExplicitWidth = 800
    inherited LbStatusBarRight: TLabel
      Left = 708
      Height = 13
      ExplicitLeft = 708
    end
    inherited LbStatusBarLeft: TLabel
      Height = 13
    end
  end
end
