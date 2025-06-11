inherited FrmCWAcoountBasis: TFrmCWAcoountBasis
  Caption = 'FrmCWAcoountBasis'
  ClientHeight = 427
  ClientWidth = 796
  ExplicitWidth = 812
  ExplicitHeight = 466
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 796
    Height = 411
    ExplicitWidth = 796
    ExplicitHeight = 411
    inherited PMDIClient: TPanel
      Width = 786
      Height = 362
      ExplicitWidth = 786
      ExplicitHeight = 362
      object PBottom: TPanel
        Left = 0
        Top = 321
        Width = 786
        Height = 41
        Align = alBottom
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 306
        ExplicitWidth = 842
        DesignSize = (
          786
          41)
        object SpeedButton1: TSpeedButton
          Left = 414
          Top = 9
          Width = 23
          Height = 22
        end
        object ImgInfomain: TImage
          Left = 4
          Top = 8
          Width = 21
          Height = 20
          Anchors = []
          ExplicitLeft = 5
        end
        object EBasis: TEdit
          Left = 32
          Top = 9
          Width = 615
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ReadOnly = True
          TabOrder = 0
          ExplicitWidth = 671
        end
        object NePrc: TDBNumberEditEh
          Left = 664
          Top = 9
          Width = 49
          Height = 21
          ControlLabel.Width = 11
          ControlLabel.Height = 13
          ControlLabel.Caption = '%'
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          Anchors = [akTop, akRight]
          DecimalPlaces = 0
          DynProps = <>
          EditButtons = <>
          MaxValue = 100.000000000000000000
          TabOrder = 1
          Visible = True
          ExplicitLeft = 720
        end
        object BtOk: TBitBtn
          Left = 739
          Top = 6
          Width = 42
          Height = 25
          Anchors = [akTop, akRight]
          Caption = '>>>'
          TabOrder = 2
          OnClick = BtOkClick
        end
      end
      object PgMain: TPageControl
        Left = 0
        Top = 0
        Width = 786
        Height = 321
        ActivePage = TsOrders
        Align = alClient
        TabOrder = 1
        OnChange = PgMainChange
        ExplicitWidth = 842
        ExplicitHeight = 305
        object TsOrders: TTabSheet
          Caption = #1047#1072#1082#1072#1079#1099
          inline Frg1: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 778
            Height = 293
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 778
            ExplicitHeight = 293
            inherited PGrid: TPanel
              Width = 768
              Height = 239
              ExplicitWidth = 768
              ExplicitHeight = 361
              inherited DbGridEh1: TDBGridEh
                Width = 766
                Height = 216
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
                Top = 217
                Width = 766
                ExplicitTop = 339
                ExplicitWidth = 766
              end
            end
            inherited PLeft: TPanel
              Height = 239
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
              Top = 293
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
        object TsAccounts: TTabSheet
          Caption = #1057#1095#1077#1090#1072
          ImageIndex = 1
          inline Frg2: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 778
            Height = 293
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 778
            ExplicitHeight = 293
            inherited PGrid: TPanel
              Width = 768
              Height = 239
              ExplicitWidth = 768
              ExplicitHeight = 361
              inherited DbGridEh1: TDBGridEh
                Width = 766
                Height = 216
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
                Top = 217
                Width = 766
                ExplicitTop = 339
                ExplicitWidth = 766
              end
            end
            inherited PLeft: TPanel
              Height = 239
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
              Top = 293
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
      end
    end
    inherited PDlgPanel: TPanel
      Top = 367
      Width = 786
      ExplicitTop = 367
      ExplicitWidth = 786
      inherited BvDlg: TBevel
        Width = 784
        ExplicitWidth = 784
      end
      inherited BvDlgBottom: TBevel
        Width = 784
        ExplicitWidth = 784
      end
      inherited PDlgMain: TPanel
        Width = 784
        ExplicitWidth = 784
        inherited PDlgBtnForm: TPanel
          Left = 685
          ExplicitLeft = 685
        end
        inherited PDlgChb: TPanel
          Left = 457
          ExplicitLeft = 457
        end
        inherited PDlgBtnR: TPanel
          Left = 586
          ExplicitLeft = 586
        end
        inherited PDlgCenter: TPanel
          Width = 317
          ExplicitWidth = 317
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 411
    Width = 796
    ExplicitTop = 411
    ExplicitWidth = 796
    inherited LbStatusBarRight: TLabel
      Left = 704
      Height = 13
      ExplicitLeft = 704
    end
    inherited LbStatusBarLeft: TLabel
      Height = 13
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 264
    Top = 360
  end
end
