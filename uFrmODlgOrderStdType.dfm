inherited FrmODlgOrderStdType: TFrmODlgOrderStdType
  Caption = 'FrmODlgOrderStdType'
  ClientHeight = 219
  ClientWidth = 356
  ExplicitWidth = 372
  ExplicitHeight = 258
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 356
    Height = 203
    inherited pnlFrmClient: TPanel
      Width = 350
      Height = 155
      ExplicitWidth = 350
      ExplicitHeight = 155
      object lblTemplate: TLabel
        Left = 12
        Top = 96
        Width = 44
        Height = 13
        Caption = #1064#1072#1073#1083#1086#1085':'
      end
      object rbProduction: TRadioButton
        Left = 12
        Top = 8
        Width = 320
        Height = 17
        Caption = #1055#1088#1086#1080#1079#1074#1086#1076#1089#1090#1074#1077#1085#1085#1086#1077
        TabOrder = 0
        OnClick = RbTypeClick
      end
      object rbShipment: TRadioButton
        Left = 12
        Top = 34
        Width = 320
        Height = 17
        Caption = #1054#1090#1075#1088#1091#1079#1086#1095#1085#1086#1077
        TabOrder = 1
        OnClick = RbTypeClick
      end
      object rbSemiproduct: TRadioButton
        Left = 12
        Top = 60
        Width = 320
        Height = 17
        Caption = #1055#1086#1083#1091#1092#1072#1073#1088#1080#1082#1072#1090
        TabOrder = 2
        OnClick = RbTypeClick
      end
      object cmbTemplate: TComboBox
        Left = 12
        Top = 114
        Width = 326
        Height = 21
        Style = csDropDownList
        TabOrder = 3
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 159
      Width = 346
      inherited bvlFrmBtnsTl: TBevel
        Width = 348
        ExplicitWidth = 348
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 348
        ExplicitWidth = 348
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 348
        inherited pnlFrmBtnsMain: TPanel
          Left = 249
          ExplicitLeft = 249
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 40
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 150
          ExplicitLeft = 150
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 203
    Width = 356
    ExplicitTop = 204
    ExplicitWidth = 360
    inherited lblStatusBarR: TLabel
      Left = 287
      ExplicitLeft = 287
    end
  end
end
