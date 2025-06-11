inherited FrmODedtNomenclFiles: TFrmODedtNomenclFiles
  Caption = 'FrmDlgDrawingAddAndView'
  ClientHeight = 250
  ClientWidth = 772
  ExplicitWidth = 788
  ExplicitHeight = 288
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 772
    Height = 234
    ExplicitWidth = 772
    ExplicitHeight = 234
    inherited PMDIClient: TPanel
      Width = 762
      Height = 185
      ExplicitWidth = 762
      ExplicitHeight = 185
      object PNomencl: TPanel
        Left = 0
        Top = 0
        Width = 762
        Height = 17
        Align = alTop
        Caption = 'PNomencl'
        TabOrder = 0
        object LbNomencl: TLabel
          Left = 4
          Top = -2
          Width = 51
          Height = 13
          Caption = 'LbNomencl'
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 17
        Width = 762
        Height = 168
        Align = alClient
        Caption = 'Panel1'
        TabOrder = 1
        inline Frg1: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 760
          Height = 166
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 760
          ExplicitHeight = 166
          inherited PGrid: TPanel
            Top = 22
            Width = 750
            Height = 144
            ExplicitTop = 22
            ExplicitWidth = 750
            ExplicitHeight = 144
            inherited DbGridEh1: TDBGridEh
              Width = 748
              Height = 121
              OnDblClick = Frg1DbGridEh1DblClick
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitHeight = 82
                inherited PRowDetailPanel: TPanel
                  Height = 80
                  ExplicitHeight = 80
                end
              end
            end
            inherited PStatus: TPanel
              Top = 122
              Width = 748
              ExplicitTop = 122
              ExplicitWidth = 748
            end
          end
          inherited PLeft: TPanel
            Top = 22
            Height = 144
            ExplicitTop = 22
            ExplicitHeight = 144
          end
          inherited PTop: TPanel
            Top = 17
            Width = 760
            ExplicitTop = 17
            ExplicitWidth = 760
          end
          inherited PContainer: TPanel
            Width = 760
            Height = 17
            ExplicitWidth = 760
            ExplicitHeight = 17
          end
          inherited PBottom: TPanel
            Top = 166
            Width = 760
            ExplicitTop = 166
            ExplicitWidth = 760
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
    end
    inherited PDlgPanel: TPanel
      Top = 190
      Width = 762
      ExplicitTop = 190
      ExplicitWidth = 762
      inherited BvDlg: TBevel
        Width = 760
        ExplicitWidth = 760
      end
      inherited BvDlgBottom: TBevel
        Width = 760
        ExplicitWidth = 760
      end
      inherited PDlgMain: TPanel
        Width = 760
        ExplicitWidth = 760
        inherited PDlgBtnForm: TPanel
          Left = 661
          ExplicitLeft = 661
        end
        inherited PDlgChb: TPanel
          Left = 399
          ExplicitLeft = 399
        end
        inherited PDlgBtnR: TPanel
          Left = 528
          Width = 133
          ExplicitLeft = 528
          ExplicitWidth = 133
        end
        inherited PDlgCenter: TPanel
          Width = 259
          ExplicitWidth = 259
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 234
    Width = 772
    ExplicitTop = 234
    ExplicitWidth = 772
    inherited LbStatusBarRight: TLabel
      Left = 680
      Height = 13
      ExplicitLeft = 680
    end
    inherited LbStatusBarLeft: TLabel
      Height = 13
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 88
    Top = 184
  end
  object OpenDialog1: TOpenDialog
    Left = 139
    Top = 171
  end
end
