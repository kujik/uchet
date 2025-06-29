inherited FrmCGrepPaymentsByMonth: TFrmCGrepPaymentsByMonth
  Caption = 'FrmCGrepPaymentsByMonth'
  ClientHeight = 611
  ClientWidth = 1148
  ExplicitWidth = 1164
  ExplicitHeight = 650
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1148
    Height = 595
    ExplicitWidth = 1148
    ExplicitHeight = 595
    inherited pnlFrmClient: TPanel
      Width = 1138
      Height = 546
      ExplicitWidth = 1138
      ExplicitHeight = 546
      inherited pnlTop: TPanel
        Width = 1138
        ExplicitWidth = 1138
      end
      inherited pnlBottom: TPanel
        Top = 500
        Width = 1138
        ExplicitTop = 500
        ExplicitWidth = 1138
      end
      inherited pnlLeft: TPanel
        Height = 491
        ExplicitHeight = 491
      end
      inherited pnlGrid1: TPanel
        Width = 515
        Height = 491
        ExplicitWidth = 515
        ExplicitHeight = 491
        inherited Frg1: TFrDBGridEh
          Width = 513
          Height = 489
          ExplicitWidth = 513
          ExplicitHeight = 489
          inherited pnlGrid: TPanel
            Width = 503
            Height = 435
            ExplicitWidth = 503
            ExplicitHeight = 435
            inherited DbGridEh1: TDBGridEh
              Width = 501
              Height = 412
              OnColEnter = Frg1DbGridEh1ColEnter
            end
            inherited pnlStatusBar: TPanel
              Top = 413
              Width = 501
              ExplicitTop = 413
              ExplicitWidth = 501
            end
          end
          inherited pnlLeft: TPanel
            Height = 435
            ExplicitHeight = 435
          end
          inherited pnlTop: TPanel
            Width = 513
            ExplicitWidth = 513
          end
          inherited pnlContainer: TPanel
            Width = 513
            ExplicitWidth = 513
          end
          inherited pnlBottom: TPanel
            Top = 489
            Width = 513
            ExplicitTop = 489
            ExplicitWidth = 513
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
        Top = 505
        Width = 1138
        ExplicitTop = 505
        ExplicitWidth = 1138
        inherited Frg2: TFrDBGridEh
          Width = 1136
          ExplicitWidth = 1136
          inherited pnlGrid: TPanel
            Width = 1126
            ExplicitWidth = 1126
            inherited DbGridEh1: TDBGridEh
              Width = 1124
            end
            inherited pnlStatusBar: TPanel
              Width = 1124
              ExplicitWidth = 1124
            end
          end
          inherited pnlTop: TPanel
            Width = 1136
            ExplicitWidth = 1136
          end
          inherited pnlContainer: TPanel
            Width = 1136
            ExplicitWidth = 1136
          end
          inherited pnlBottom: TPanel
            Width = 1136
            ExplicitWidth = 1136
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
      inherited pnlRight: TPanel
        Left = 520
        Width = 618
        Height = 491
        ExplicitLeft = 520
        ExplicitWidth = 618
        ExplicitHeight = 491
        object Chart1: TChart
          Left = 1
          Top = 1
          Width = 616
          Height = 489
          Title.Text.Strings = (
            'TChart')
          View3DOptions.Elevation = 315
          View3DOptions.Orthogonal = False
          View3DOptions.Perspective = 0
          View3DOptions.Rotation = 360
          Align = alClient
          TabOrder = 0
          DefaultCanvas = 'TGDIPlusCanvas'
          ColorPaletteIndex = 13
          object DBComboBoxEh1: TDBComboBoxEh
            Left = 336
            Top = 464
            Width = 121
            Height = 21
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Text = 'DBComboBoxEh1'
            Visible = True
          end
          object Series1: TLineSeries
            Brush.BackColor = clDefault
            Pointer.InflateMargins = True
            Pointer.Style = psRectangle
            XValues.Name = 'X'
            XValues.Order = loAscending
            YValues.Name = 'Y'
            YValues.Order = loNone
          end
          object Series2: TPieSeries
            Legend.Visible = False
            Marks.Style = smsLabelPercentValue
            ShowInLegend = False
            XValues.Order = loAscending
            YValues.Name = 'Pie'
            YValues.Order = loDescending
            Frame.InnerBrush.BackColor = clRed
            Frame.InnerBrush.Gradient.EndColor = clGray
            Frame.InnerBrush.Gradient.MidColor = clWhite
            Frame.InnerBrush.Gradient.StartColor = 4210752
            Frame.InnerBrush.Gradient.Visible = True
            Frame.MiddleBrush.BackColor = clYellow
            Frame.MiddleBrush.Gradient.EndColor = 8553090
            Frame.MiddleBrush.Gradient.MidColor = clWhite
            Frame.MiddleBrush.Gradient.StartColor = clGray
            Frame.MiddleBrush.Gradient.Visible = True
            Frame.OuterBrush.BackColor = clGreen
            Frame.OuterBrush.Gradient.EndColor = 4210752
            Frame.OuterBrush.Gradient.MidColor = clWhite
            Frame.OuterBrush.Gradient.StartColor = clSilver
            Frame.OuterBrush.Gradient.Visible = True
            Frame.Width = 4
            Emboss.Transparency = 48
            ExplodeBiggest = 10
            Gradient.EndColor = 7028779
            Gradient.StartColor = 7028779
            Gradient.Visible = True
            OtherSlice.Legend.Visible = False
            OtherSlice.Style = poBelowPercent
            OtherSlice.Text = #1054#1089#1090#1072#1083#1100#1085#1086#1077
            OtherSlice.Value = 3.500000000000000000
            PieMarks.InsideSlice = True
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 551
      Width = 1138
      ExplicitTop = 551
      ExplicitWidth = 1138
      inherited bvlFrmBtnsTl: TBevel
        Width = 1136
        ExplicitWidth = 1136
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1136
        ExplicitWidth = 1136
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1136
        ExplicitWidth = 1136
        inherited pnlFrmBtnsMain: TPanel
          Left = 1037
          ExplicitLeft = 1037
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 809
          ExplicitLeft = 809
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 938
          ExplicitLeft = 938
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 669
          ExplicitWidth = 669
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 595
    Width = 1148
    ExplicitTop = 595
    ExplicitWidth = 1148
    inherited lblStatusBarR: TLabel
      Left = 1056
      ExplicitLeft = 1056
    end
  end
end
