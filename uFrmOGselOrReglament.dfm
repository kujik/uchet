inherited FrmOGselOrReglament: TFrmOGselOrReglament
  Anchors = [akTop, akRight]
  Caption = 'FrmOGselOrReglament'
  ClientHeight = 505
  ClientWidth = 349
  ExplicitWidth = 361
  ExplicitHeight = 543
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 349
    Height = 499
    ExplicitWidth = 796
    ExplicitHeight = 520
    inherited pnlFrmClient: TPanel
      Width = 339
      Height = 450
      ExplicitWidth = 782
      ExplicitHeight = 470
      inherited pnlTop: TPanel
        Width = 339
        Height = 35
        ExplicitWidth = 339
        ExplicitHeight = 35
        object lblName: TLabel
          Left = 11
          Top = 11
          Width = 37
          Height = 13
          Caption = 'lblName'
        end
        object lblDeadline: TLabel
          Left = 303
          Top = 5
          Width = 22
          Height = 24
          Anchors = [akTop, akRight]
          Caption = '34'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = 24
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
      end
      inherited pnlBottom: TPanel
        Top = 404
        Width = 339
        ExplicitTop = 424
        ExplicitWidth = 782
      end
      inherited pnlLeft: TPanel
        Top = 35
        Height = 369
        ExplicitHeight = 415
      end
      inherited pnlGrid1: TPanel
        Top = 35
        Width = 329
        Height = 369
        ExplicitWidth = 772
        ExplicitHeight = 415
        inherited Frg1: TFrDBGridEh
          Width = 327
          Height = 367
          ExplicitWidth = 770
          ExplicitHeight = 413
          inherited pnlGrid: TPanel
            Width = 317
            Height = 313
            ExplicitWidth = 760
            ExplicitHeight = 359
            inherited DbGridEh1: TDBGridEh
              Width = 315
              Height = 290
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitHeight = 120
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 291
              Width = 315
              ExplicitTop = 337
              ExplicitWidth = 758
            end
            inherited CProp: TDBEditEh
              Left = 369
              Top = 367
              ControlLabel.ExplicitLeft = 369
              ControlLabel.ExplicitTop = 349
              ExplicitLeft = 369
              ExplicitTop = 367
            end
          end
          inherited pnlLeft: TPanel
            Height = 313
            ExplicitHeight = 359
          end
          inherited pnlTop: TPanel
            Width = 327
            ExplicitWidth = 770
          end
          inherited pnlContainer: TPanel
            Width = 327
            ExplicitWidth = 770
          end
          inherited pnlBottom: TPanel
            Top = 367
            Width = 327
            ExplicitTop = 413
            ExplicitWidth = 770
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
        Top = 409
        Width = 339
        ExplicitTop = 429
        ExplicitWidth = 782
        inherited Frg2: TFrDBGridEh
          Width = 337
          ExplicitWidth = 780
          inherited pnlGrid: TPanel
            Width = 327
            ExplicitWidth = 770
            inherited DbGridEh1: TDBGridEh
              Width = 325
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitWidth = 32
              end
            end
            inherited pnlStatusBar: TPanel
              Width = 325
              ExplicitWidth = 768
            end
          end
          inherited pnlTop: TPanel
            Width = 337
            ExplicitWidth = 780
          end
          inherited pnlContainer: TPanel
            Width = 337
            ExplicitWidth = 780
          end
          inherited pnlBottom: TPanel
            Width = 337
            ExplicitWidth = 780
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
        Left = 334
        Top = 35
        Height = 369
        ExplicitLeft = 777
        ExplicitHeight = 415
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 455
      Width = 339
      ExplicitTop = 475
      ExplicitWidth = 782
      inherited bvlFrmBtnsTl: TBevel
        Width = 337
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 337
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 337
        ExplicitWidth = 780
        inherited pnlFrmBtnsMain: TPanel
          Left = 238
          ExplicitLeft = 681
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 10
          ExplicitLeft = 453
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 139
          ExplicitLeft = 582
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 44
          ExplicitWidth = 313
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 499
    Width = 349
    Height = 6
    ExplicitTop = 530
    ExplicitHeight = 6
    inherited lblStatusBarR: TLabel
      Left = 276
      Height = 4
    end
    inherited lblStatusBarL: TLabel
      Height = 4
    end
  end
end
