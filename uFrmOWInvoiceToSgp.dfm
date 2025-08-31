inherited FrmOWInvoiceToSgp: TFrmOWInvoiceToSgp
  Caption = 'FrmOWInvoiceToSgp'
  ClientHeight = 446
  ClientWidth = 687
  ExplicitWidth = 699
  ExplicitHeight = 484
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 687
    Height = 430
    ExplicitWidth = 687
    ExplicitHeight = 430
    inherited pnlFrmClient: TPanel
      Width = 677
      Height = 381
      ExplicitWidth = 673
      ExplicitHeight = 380
      object pnlSelectOrder: TPanel
        Left = 0
        Top = 0
        Width = 677
        Height = 41
        Align = alTop
        Caption = 'pnlSelectOrder'
        TabOrder = 0
        ExplicitWidth = 673
        object bvl1: TBevel
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
      object pnlTitle: TPanel
        Left = 0
        Top = 41
        Width = 677
        Height = 80
        Align = alTop
        Caption = 'pnlTitle'
        TabOrder = 1
        ExplicitWidth = 673
        object lblInvoice: TLabel
          Left = 10
          Top = 6
          Width = 45
          Height = 13
          Caption = 'lblInvoice'
        end
        object lblOrder: TLabel
          Left = 8
          Top = 25
          Width = 38
          Height = 13
          Caption = 'lblOrder'
        end
        object lblM: TLabel
          Left = 8
          Top = 44
          Width = 18
          Height = 13
          Caption = 'lblM'
        end
        object lblS: TLabel
          Left = 8
          Top = 61
          Width = 16
          Height = 13
          Caption = 'lblS'
        end
      end
      object pnlGrid: TPanel
        Left = 0
        Top = 121
        Width = 677
        Height = 260
        Align = alClient
        Caption = 'pnlGrid'
        TabOrder = 2
        ExplicitWidth = 673
        ExplicitHeight = 259
        inline Frg1: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 675
          Height = 258
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 671
          ExplicitHeight = 257
          inherited pnlGrid: TPanel
            Width = 665
            Height = 204
            ExplicitWidth = 661
            ExplicitHeight = 203
            inherited DbGridEh1: TDBGridEh
              Width = 663
              Height = 181
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitTop = 35
                ExplicitWidth = 32
                ExplicitHeight = 120
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 182
              Width = 663
              ExplicitTop = 181
              ExplicitWidth = 659
              inherited lblStatusBarL: TLabel
                Height = 13
                ExplicitHeight = 13
              end
            end
            inherited CProp: TDBEditEh
              Height = 21
              ExplicitHeight = 21
            end
          end
          inherited pnlLeft: TPanel
            Height = 204
            ExplicitHeight = 203
          end
          inherited pnlTop: TPanel
            Width = 675
            ExplicitWidth = 671
          end
          inherited pnlContainer: TPanel
            Width = 675
            ExplicitWidth = 671
          end
          inherited pnlBottom: TPanel
            Top = 258
            Width = 675
            ExplicitTop = 257
            ExplicitWidth = 671
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
    end
    inherited pnlFrmBtns: TPanel
      Top = 386
      Width = 677
      ExplicitTop = 385
      ExplicitWidth = 673
      inherited bvlFrmBtnsTl: TBevel
        Width = 675
        ExplicitWidth = 675
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 675
        ExplicitWidth = 675
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 675
        ExplicitWidth = 671
        inherited pnlFrmBtnsMain: TPanel
          Left = 576
          ExplicitLeft = 572
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 348
          ExplicitLeft = 344
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 477
          ExplicitLeft = 473
        end
        inherited pnlFrmBtnsL: TPanel
          Width = 272
          ExplicitWidth = 272
          object cmbOrder: TDBComboBoxEh
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
            Text = 'cmbOrder'
            Visible = True
          end
          object btnFill: TBitBtn
            Left = 169
            Top = 2
            Width = 96
            Height = 25
            Caption = #1047#1072#1087#1086#1083#1085#1080#1090#1100
            TabOrder = 1
            OnClick = BtFillClick
          end
        end
        inherited pnlFrmBtnsC: TPanel
          Left = 313
          Width = 35
          ExplicitLeft = 313
          ExplicitWidth = 31
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 430
    Width = 687
    ExplicitTop = 429
    ExplicitWidth = 683
    inherited lblStatusBarR: TLabel
      Left = 614
      Height = 14
      ExplicitLeft = 614
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 168
    Top = 424
  end
end
