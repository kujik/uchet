inherited Dlg_R_Spl_Categoryes: TDlg_R_Spl_Categoryes
  Caption = 'Dlg_R_Spl_Categoryes'
  ClientHeight = 115
  ClientWidth = 632
  ExplicitWidth = 638
  ExplicitHeight = 144
  PixelsPerInch = 96
  TextHeight = 13
  inherited P_StatusBar: TPanel
    Top = 96
    Width = 632
    BevelOuter = bvNone
    ExplicitTop = 96
    ExplicitWidth = 632
    inherited Lb_StatusBar_Right: TLabel
      Left = 544
      Top = 0
      Height = 19
      ExplicitLeft = 544
      ExplicitTop = 0
    end
    inherited Lb_StatusBar_Left: TLabel
      Left = 0
      Top = 0
      Height = 19
      Anchors = [akLeft, akTop]
      ExplicitLeft = 0
      ExplicitTop = 0
    end
  end
  inherited P_Bottom: TPanel
    Top = 65
    Width = 632
    ExplicitTop = 65
    ExplicitWidth = 632
    inherited Img_Info: TImage
      Top = 4
      Anchors = []
      ExplicitTop = 4
    end
    inherited Bevel1: TBevel
      Width = 632
      ExplicitWidth = 632
    end
    inherited Bt_OK: TBitBtn
      Left = 465
      ExplicitLeft = 465
    end
    inherited Bt_Cancel: TBitBtn
      Left = 546
      ExplicitLeft = 546
    end
    inherited Chb_NoClose: TCheckBox
      Left = 338
      ExplicitLeft = 338
    end
  end
  object E_Name: TDBEditEh [2]
    Left = 83
    Top = 8
    Width = 270
    Height = 21
    ControlLabel.Width = 76
    ControlLabel.Height = 13
    ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 2
    Visible = True
  end
  object E_UserNames: TDBEditEh [3]
    Left = 83
    Top = 35
    Width = 541
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ControlLabel.Width = 37
    ControlLabel.Height = 13
    ControlLabel.Caption = #1044#1086#1089#1090#1091#1087
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <
      item
        OnClick = E_UserNamesEditButtons0Click
      end>
    ReadOnly = True
    TabOrder = 3
    Visible = True
  end
end
