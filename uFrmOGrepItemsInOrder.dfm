inherited FrmOGrepItemsInOrder: TFrmOGrepItemsInOrder
  Caption = 'FrmOGrepItemsInOrder'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    inherited pnlFrmClient: TPanel
      inherited pnlTop: TPanel
        Height = 73
        ExplicitHeight = 73
        object P_Left: TPanel
          Left = 1
          Top = 1
          Width = 641
          Height = 71
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          ExplicitLeft = 9
          ExplicitTop = 2
          object LbAddOrders: TLabel
            Left = 454
            Top = 44
            Width = 152
            Height = 13
            Caption = #1053#1077#1090' '#1076#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1093' '#1079#1072#1082#1072#1079#1086#1074
            OnClick = LbAddOrdersClick
          end
          object CbProekt: TDBComboBoxEh
            Left = 57
            Top = 36
            Width = 224
            Height = 21
            ControlLabel.Width = 37
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1088#1086#1077#1082#1090
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            HighlightRequired = True
            LimitTextToListValues = False
            TabOrder = 0
            Visible = True
          end
          object De1: TDBDateTimeEditEh
            Left = 344
            Top = 9
            Width = 99
            Height = 21
            ControlLabel.Width = 13
            ControlLabel.Height = 13
            ControlLabel.Caption = 'C  '
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            HighlightRequired = True
            Kind = dtkDateEh
            TabOrder = 1
            Visible = True
          end
          object De2: TDBDateTimeEditEh
            Left = 344
            Top = 36
            Width = 99
            Height = 21
            ControlLabel.Width = 12
            ControlLabel.Height = 13
            ControlLabel.Caption = #1087#1086
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            HighlightRequired = True
            Kind = dtkDateEh
            TabOrder = 2
            Visible = True
          end
          object BtAddOrders: TBitBtn
            Left = 449
            Top = 10
            Width = 157
            Height = 25
            Hint = #1059#1076#1072#1083#1080#1090#1100' '#1087#1088#1086#1077#1082#1090' '#1080#1079' '#1089#1087#1080#1089#1082#1072
            Caption = '+'#1047#1072#1082#1072#1079#1099
            ParentShowHint = False
            ShowHint = True
            TabOrder = 3
            OnClick = BtAddOrdersClick
          end
          object BtDelProekt: TBitBtn
            Left = 287
            Top = 34
            Width = 24
            Height = 25
            Hint = #1059#1076#1072#1083#1080#1090#1100' '#1087#1088#1086#1077#1082#1090' '#1080#1079' '#1089#1087#1080#1089#1082#1072
            Caption = '-'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 4
            OnClick = BtDelProektClick
          end
          object EOrIds: TDBEditEh
            Left = 604
            Top = 6
            Width = 121
            Height = 21
            DynProps = <>
            EditButtons = <>
            TabOrder = 5
            Visible = False
          end
          object EOrNum: TDBEditEh
            Left = 604
            Top = 26
            Width = 121
            Height = 21
            DynProps = <>
            EditButtons = <>
            TabOrder = 6
            Visible = False
          end
          object EOrCnt: TDBEditEh
            Left = 604
            Top = 44
            Width = 121
            Height = 21
            DynProps = <>
            EditButtons = <>
            TabOrder = 7
            Visible = False
          end
          object CbCustomer: TDBComboBoxEh
            Left = 57
            Top = 9
            Width = 254
            Height = 21
            ControlLabel.Width = 47
            ControlLabel.Height = 13
            ControlLabel.Caption = #1047#1072#1082#1072#1079#1095#1080#1082
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            LimitTextToListValues = True
            TabOrder = 8
            Visible = True
          end
        end
      end
      inherited pnlLeft: TPanel
        Top = 73
        Height = 353
      end
      inherited pnlGrid1: TPanel
        Top = 73
        Height = 353
        inherited Frg1: TFrDBGridEh
          Height = 351
          inherited pnlGrid: TPanel
            Height = 297
            inherited DbGridEh1: TDBGridEh
              Height = 274
            end
            inherited pnlStatusBar: TPanel
              Top = 275
            end
          end
          inherited pnlLeft: TPanel
            Height = 297
          end
          inherited pnlBottom: TPanel
            Top = 351
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
        Top = 73
        Height = 353
      end
    end
  end
end
