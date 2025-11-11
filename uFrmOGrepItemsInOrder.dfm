inherited FrmOGrepItemsInOrder: TFrmOGrepItemsInOrder
  Caption = 'FrmOGrepItemsInOrder'
  ClientWidth = 796
  ExplicitWidth = 812
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 796
    ExplicitHeight = 522
    inherited pnlFrmClient: TPanel
      Width = 786
      ExplicitWidth = 786
      inherited pnlTop: TPanel
        Width = 786
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
      inherited pnlBottom: TPanel
        Width = 786
        ExplicitTop = 426
      end
      inherited pnlLeft: TPanel
        Top = 73
        Height = 353
        ExplicitTop = 73
        ExplicitHeight = 353
      end
      inherited pnlGrid1: TPanel
        Top = 73
        Width = 776
        Height = 353
        ExplicitTop = 73
        ExplicitWidth = 776
        ExplicitHeight = 353
        inherited Frg1: TFrDBGridEh
          Width = 774
          Height = 351
          ExplicitWidth = 774
          ExplicitHeight = 351
          inherited pnlGrid: TPanel
            Width = 764
            Height = 297
            ExplicitHeight = 297
            inherited DbGridEh1: TDBGridEh
              Height = 275
            end
            inherited pnlStatusBar: TPanel
              Top = 276
              ExplicitTop = 275
            end
          end
          inherited pnlLeft: TPanel
            Height = 297
            ExplicitHeight = 297
          end
          inherited pnlTop: TPanel
            Width = 774
          end
          inherited pnlContainer: TPanel
            Width = 774
          end
          inherited pnlBottom: TPanel
            Top = 351
            Width = 774
            ExplicitTop = 351
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
        Width = 786
        ExplicitWidth = 786
        inherited Frg2: TFrDBGridEh
          Width = 784
          ExplicitWidth = 784
          inherited pnlGrid: TPanel
            Width = 774
          end
          inherited pnlTop: TPanel
            Width = 784
          end
          inherited pnlContainer: TPanel
            Width = 784
          end
          inherited pnlBottom: TPanel
            Width = 784
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
        Left = 781
        Top = 73
        Height = 353
        ExplicitTop = 73
        ExplicitHeight = 353
      end
    end
    inherited pnlFrmBtns: TPanel
      Width = 786
      inherited pnlFrmBtnsContainer: TPanel
        inherited pnlFrmBtnsChb: TPanel
          ExplicitLeft = 457
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Width = 796
    ExplicitTop = 521
  end
end
