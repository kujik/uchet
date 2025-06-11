inherited FrmOWInvoiceToSgp: TFrmOWInvoiceToSgp
  Caption = 'FrmOWInvoiceToSgp'
  ClientHeight = 446
  ClientWidth = 687
  ExplicitWidth = 703
  ExplicitHeight = 484
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 687
    Height = 430
    ExplicitWidth = 687
    ExplicitHeight = 430
    inherited PMDIClient: TPanel
      Width = 677
      Height = 381
      ExplicitWidth = 677
      ExplicitHeight = 381
      object PSelectOrder: TPanel
        Left = 0
        Top = 0
        Width = 677
        Height = 41
        Align = alTop
        Caption = 'PSelectOrder'
        TabOrder = 0
        object Bevel1: TBevel
          Left = 1
          Top = 38
          Width = 675
          Height = 2
          Align = alBottom
          ExplicitLeft = 416
          ExplicitTop = 24
          ExplicitWidth = 50
        end
      end
      object PTitle: TPanel
        Left = 0
        Top = 41
        Width = 677
        Height = 80
        Align = alTop
        Caption = 'PTitle'
        TabOrder = 1
        object LbInvoice: TLabel
          Left = 10
          Top = 6
          Width = 46
          Height = 13
          Caption = 'LbInvoice'
        end
        object LbOrder: TLabel
          Left = 8
          Top = 25
          Width = 39
          Height = 13
          Caption = 'LbOrder'
        end
        object LbM: TLabel
          Left = 8
          Top = 44
          Width = 19
          Height = 13
          Caption = 'LbM'
        end
        object LbS: TLabel
          Left = 8
          Top = 61
          Width = 17
          Height = 13
          Caption = 'LbS'
        end
      end
      object PGrid: TPanel
        Left = 0
        Top = 121
        Width = 677
        Height = 260
        Align = alClient
        Caption = 'PGrid'
        TabOrder = 2
        inline Frg1: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 675
          Height = 258
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 675
          ExplicitHeight = 258
          inherited PGrid: TPanel
            Width = 665
            Height = 204
            ExplicitWidth = 665
            ExplicitHeight = 204
            inherited DbGridEh1: TDBGridEh
              Width = 663
              Height = 181
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 0
                ExplicitTop = 0
                ExplicitWidth = 0
                ExplicitHeight = 0
              end
            end
            inherited PStatus: TPanel
              Top = 182
              Width = 663
              ExplicitTop = 182
              ExplicitWidth = 663
            end
          end
          inherited PLeft: TPanel
            Height = 204
            ExplicitHeight = 204
          end
          inherited PTop: TPanel
            Width = 675
            ExplicitWidth = 675
          end
          inherited PContainer: TPanel
            Width = 675
            ExplicitWidth = 675
          end
          inherited PBottom: TPanel
            Top = 258
            Width = 675
            ExplicitTop = 258
            ExplicitWidth = 675
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
      Top = 386
      Width = 677
      ExplicitTop = 386
      ExplicitWidth = 677
      inherited BvDlg: TBevel
        Width = 675
        ExplicitWidth = 675
      end
      inherited BvDlgBottom: TBevel
        Width = 675
        ExplicitWidth = 675
      end
      inherited PDlgMain: TPanel
        Width = 675
        ExplicitWidth = 675
        inherited PDlgBtnForm: TPanel
          Left = 576
          ExplicitLeft = 576
        end
        inherited PDlgChb: TPanel
          Left = 348
          ExplicitLeft = 348
        end
        inherited PDlgBtnR: TPanel
          Left = 477
          ExplicitLeft = 477
        end
        inherited PDlgBtnL: TPanel
          Width = 272
          ExplicitWidth = 272
          object CbOrder: TDBComboBoxEh
            Left = 42
            Top = 4
            Width = 121
            Height = 19
            ControlLabel.Width = 29
            ControlLabel.Height = 13
            ControlLabel.Caption = #1047#1072#1082#1072#1079
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            LimitTextToListValues = True
            TabOrder = 0
            Text = 'CbOrder'
            Visible = True
          end
          object BtFill: TBitBtn
            Left = 169
            Top = 2
            Width = 96
            Height = 25
            Caption = #1047#1072#1087#1086#1083#1085#1080#1090#1100
            TabOrder = 1
            OnClick = BtFillClick
          end
        end
        inherited PDlgCenter: TPanel
          Left = 313
          Width = 35
          ExplicitLeft = 313
          ExplicitWidth = 35
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 430
    Width = 687
    ExplicitTop = 430
    ExplicitWidth = 687
    inherited LbStatusBarRight: TLabel
      Left = 595
      Height = 13
      ExplicitLeft = 595
    end
    inherited LbStatusBarLeft: TLabel
      Height = 13
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 168
    Top = 424
  end
end
