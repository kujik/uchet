inherited FrmOGselOrReglament: TFrmOGselOrReglament
  Anchors = [akTop, akRight]
  Caption = 'FrmOGselOrReglament'
  ClientHeight = 503
  ClientWidth = 341
  ExplicitWidth = 357
  ExplicitHeight = 542
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 341
    Height = 497
    ExplicitWidth = 345
    ExplicitHeight = 498
    inherited pnlFrmClient: TPanel
      Width = 331
      Height = 448
      ExplicitWidth = 331
      ExplicitHeight = 448
      inherited pnlTop: TPanel
        Width = 331
        Height = 35
        ExplicitWidth = 335
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
        Top = 402
        Width = 331
        ExplicitTop = 403
        ExplicitWidth = 335
      end
      inherited pnlLeft: TPanel
        Top = 35
        Height = 367
        ExplicitTop = 35
        ExplicitHeight = 368
      end
      inherited pnlGrid1: TPanel
        Top = 35
        Width = 321
        Height = 367
        ExplicitTop = 35
        ExplicitWidth = 321
        ExplicitHeight = 367
        inherited Frg1: TFrDBGridEh
          Width = 319
          Height = 365
          ExplicitWidth = 319
          ExplicitHeight = 365
          inherited pnlGrid: TPanel
            Width = 309
            Height = 311
            ExplicitWidth = 313
            ExplicitHeight = 312
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
              ExplicitTop = 290
              ExplicitWidth = 311
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
            Height = 311
            ExplicitHeight = 312
          end
          inherited pnlTop: TPanel
            Width = 319
            ExplicitWidth = 323
          end
          inherited pnlContainer: TPanel
            Width = 319
            ExplicitWidth = 323
          end
          inherited pnlBottom: TPanel
            Top = 365
            Width = 319
            ExplicitTop = 366
            ExplicitWidth = 323
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
        Top = 407
        Width = 331
        ExplicitTop = 407
        ExplicitWidth = 331
        inherited Frg2: TFrDBGridEh
          Width = 329
          ExplicitWidth = 329
          inherited pnlGrid: TPanel
            Width = 319
            ExplicitWidth = 323
            inherited DbGridEh1: TDBGridEh
              Width = 325
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitWidth = 32
              end
            end
            inherited pnlStatusBar: TPanel
              Width = 325
              ExplicitWidth = 321
            end
          end
          inherited pnlTop: TPanel
            Width = 329
            ExplicitWidth = 333
          end
          inherited pnlContainer: TPanel
            Width = 329
            ExplicitWidth = 333
          end
          inherited pnlBottom: TPanel
            Width = 329
            ExplicitWidth = 333
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
        Left = 326
        Top = 35
        Height = 367
        ExplicitLeft = 330
        ExplicitTop = 35
        ExplicitHeight = 368
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 453
      Width = 331
      ExplicitTop = 454
      ExplicitWidth = 335
      inherited bvlFrmBtnsTl: TBevel
        Width = 337
        ExplicitWidth = 337
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 337
        ExplicitWidth = 337
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 337
        ExplicitWidth = 333
        inherited pnlFrmBtnsMain: TPanel
          Left = 238
          ExplicitLeft = 234
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 10
          ExplicitLeft = 6
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 139
          ExplicitLeft = 135
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 44
          ExplicitWidth = 44
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 497
    Width = 341
    Height = 6
    ExplicitTop = 498
    ExplicitWidth = 345
    ExplicitHeight = 6
    inherited lblStatusBarR: TLabel
      Left = 276
      ExplicitLeft = 276
    end
  end
end
