inherited FrmCGrepPaymentsByMonth: TFrmCGrepPaymentsByMonth
  Caption = 'FrmCGrepPaymentsByMonth'
  ClientHeight = 609
  ClientWidth = 1140
  ExplicitWidth = 1152
  ExplicitHeight = 647
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1140
    Height = 593
    ExplicitWidth = 1140
    ExplicitHeight = 593
    inherited pnlFrmClient: TPanel
      Width = 1130
      Height = 544
      ExplicitWidth = 1126
      ExplicitHeight = 543
      inherited pnlTop: TPanel
        Width = 1130
        ExplicitWidth = 1126
      end
      inherited pnlBottom: TPanel
        Top = 498
        Width = 1130
        ExplicitTop = 497
        ExplicitWidth = 1126
      end
      inherited pnlLeft: TPanel
        Height = 489
        ExplicitHeight = 488
      end
      inherited pnlGrid1: TPanel
        Width = 507
        Height = 489
        ExplicitWidth = 503
        ExplicitHeight = 488
        inherited Frg1: TFrDBGridEh
          Width = 505
          Height = 487
          ExplicitWidth = 501
          ExplicitHeight = 486
          inherited pnlGrid: TPanel
            Width = 495
            Height = 433
            ExplicitWidth = 491
            ExplicitHeight = 432
            inherited DbGridEh1: TDBGridEh
              Width = 493
              Height = 410
              OnColEnter = Frg1DbGridEh1ColEnter
            end
            inherited pnlStatusBar: TPanel
              Top = 411
              Width = 493
              ExplicitTop = 410
              ExplicitWidth = 489
            end
          end
          inherited pnlLeft: TPanel
            Height = 433
            ExplicitHeight = 432
          end
          inherited pnlTop: TPanel
            Width = 505
            ExplicitWidth = 501
          end
          inherited pnlContainer: TPanel
            Width = 505
            ExplicitWidth = 501
          end
          inherited pnlBottom: TPanel
            Top = 487
            Width = 505
            ExplicitTop = 486
            ExplicitWidth = 501
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E31393034317D5C766965
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
        Top = 503
        Width = 1130
        ExplicitTop = 502
        ExplicitWidth = 1126
        inherited Frg2: TFrDBGridEh
          Width = 1128
          ExplicitWidth = 1124
          inherited pnlGrid: TPanel
            Width = 1118
            ExplicitWidth = 1114
            inherited DbGridEh1: TDBGridEh
              Width = 1116
            end
            inherited pnlStatusBar: TPanel
              Width = 1116
              ExplicitWidth = 1112
            end
          end
          inherited pnlTop: TPanel
            Width = 1128
            ExplicitWidth = 1124
          end
          inherited pnlContainer: TPanel
            Width = 1128
            ExplicitWidth = 1124
          end
          inherited pnlBottom: TPanel
            Width = 1128
            ExplicitWidth = 1124
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E31393034317D5C766965
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
        Left = 512
        Width = 618
        Height = 489
        ExplicitLeft = 508
        ExplicitWidth = 618
        ExplicitHeight = 488
        object Chart1: TChart
          Left = 1
          Top = 1
          Width = 616
          Height = 487
          Title.Text.Strings = (
            'TChart')
          View3DOptions.Elevation = 315
          View3DOptions.Orthogonal = False
          View3DOptions.Perspective = 0
          View3DOptions.Rotation = 360
          Align = alClient
          TabOrder = 0
          ExplicitHeight = 486
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
          object DBLookupComboboxEh1: TDBLookupComboboxEh
            Left = 224
            Top = 440
            Width = 121
            Height = 21
            DynProps = <>
            DataField = ''
            EditButtons = <>
            TabOrder = 1
            Visible = True
          end
          object Series1: TLineSeries
            HoverElement = [heCurrent]
            Brush.BackColor = clDefault
            Pointer.InflateMargins = True
            Pointer.Style = psRectangle
            XValues.Name = 'X'
            XValues.Order = loAscending
            YValues.Name = 'Y'
            YValues.Order = loNone
          end
          object Series2: TPieSeries
            HoverElement = []
            Legend.Visible = False
            Marks.Style = smsLabelPercentValue
            Marks.Tail.Margin = 2
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
      Top = 549
      Width = 1130
      ExplicitTop = 548
      ExplicitWidth = 1126
      inherited bvlFrmBtnsTl: TBevel
        Width = 1128
        ExplicitWidth = 1136
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1128
        ExplicitWidth = 1136
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1128
        ExplicitWidth = 1124
        inherited pnlFrmBtnsMain: TPanel
          Left = 1029
          ExplicitLeft = 1025
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 801
          ExplicitLeft = 797
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 930
          ExplicitLeft = 926
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 661
          ExplicitWidth = 657
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 593
    Width = 1140
    ExplicitTop = 592
    ExplicitWidth = 1136
    inherited lblStatusBarR: TLabel
      Left = 1067
      ExplicitLeft = 1067
    end
  end
end
