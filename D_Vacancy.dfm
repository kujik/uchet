inherited Dlg_Vacancy: TDlg_Vacancy
  Caption = 'Dlg_Vacancy'
  ClientHeight = 421
  ClientWidth = 878
  ExplicitWidth = 894
  ExplicitHeight = 460
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 402
    Width = 878
  end
  object pnl_Top: TPanel [1]
    Left = 0
    Top = 0
    Width = 878
    Height = 94
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object cmb_Division: TDBComboBoxEh
      Left = 91
      Top = 7
      Width = 546
      Height = 21
      ControlLabel.Width = 80
      ControlLabel.Height = 13
      ControlLabel.Caption = #1055#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1077
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 0
      Visible = True
    end
    object cmb_Job: TDBComboBoxEh
      Left = 91
      Top = 34
      Width = 546
      Height = 21
      ControlLabel.Width = 58
      ControlLabel.Height = 13
      ControlLabel.Caption = #1055#1088#1086#1092#1077#1089#1089#1080#1103
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 1
      Visible = True
    end
    object cmb_Head: TDBComboBoxEh
      Left = 91
      Top = 61
      Width = 546
      Height = 21
      ControlLabel.Width = 79
      ControlLabel.Height = 13
      ControlLabel.Caption = #1054#1090#1074#1077#1090#1089#1090#1074#1077#1085#1085#1099#1081
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 2
      Visible = True
    end
    object dedt_Dt: TDBDateTimeEditEh
      Left = 732
      Top = 7
      Width = 140
      Height = 21
      ControlLabel.Width = 77
      ControlLabel.Height = 13
      ControlLabel.Caption = #1044#1072#1090#1072' '#1086#1090#1082#1088#1099#1090#1080#1103
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      Kind = dtkDateEh
      TabOrder = 3
      Visible = True
    end
    object cmb_Status: TDBComboBoxEh
      Left = 732
      Top = 34
      Width = 140
      Height = 21
      ControlLabel.Width = 34
      ControlLabel.Height = 13
      ControlLabel.Caption = #1057#1090#1072#1090#1091#1089
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 4
      Visible = True
    end
    object nedt_Qnt: TDBNumberEditEh
      Left = 732
      Top = 61
      Width = 46
      Height = 21
      ControlLabel.Width = 59
      ControlLabel.Height = 13
      ControlLabel.Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DecimalPlaces = 0
      DynProps = <>
      EditButton.Visible = True
      EditButtons = <>
      MaxValue = 50000.000000000000000000
      TabOrder = 5
      Visible = True
    end
    object nedt_QntOpen: TDBNumberEditEh
      Left = 826
      Top = 61
      Width = 46
      Height = 21
      ControlLabel.Width = 44
      ControlLabel.Height = 13
      ControlLabel.Caption = #1054#1090#1082#1088#1099#1090#1086
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DecimalPlaces = 0
      DynProps = <>
      EditButton.Visible = True
      EditButtons = <>
      MaxValue = 50000.000000000000000000
      TabOrder = 6
      Visible = True
    end
  end
  object pnl_Grid: TPanel [2]
    Left = 0
    Top = 94
    Width = 878
    Height = 222
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object lbl_Candidates: TLabel
      Left = 18
      Top = 105
      Width = 60
      Height = 13
      Caption = #1057#1086#1080#1089#1082#1072#1090#1077#1083#1080
    end
    object DBGridEh1: TDBGridEh
      Left = 91
      Top = 0
      Width = 781
      Height = 211
      DataSource = DataSource1
      DynProps = <>
      Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
      RowDetailPanel.Height = 250
      TabOrder = 0
      OnDblClick = DBGridEh1DblClick
      object RowDetailData: TRowDetailPanelControlEh
        object edt_PPComment: TDBEditEh
          Left = 299
          Top = 215
          Width = 494
          Height = 21
          ControlLabel.Width = 70
          ControlLabel.Height = 13
          ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          TabOrder = 0
          Text = 'edt_PPComment'
          Visible = False
        end
      end
    end
    object Bt_Refresh: TBitBtn
      Left = 3
      Top = 124
      Width = 82
      Height = 25
      Caption = 'Bt_Ok'
      TabOrder = 1
      OnClick = Bt_RefreshClick
    end
    object Bt_Add: TBitBtn
      Left = 3
      Top = 155
      Width = 82
      Height = 25
      Caption = 'Bt_Ok'
      TabOrder = 2
      OnClick = Bt_AddClick
    end
    object Bt_Edit: TBitBtn
      Left = 3
      Top = 186
      Width = 82
      Height = 25
      Caption = 'Bt_Ok'
      TabOrder = 3
      OnClick = Bt_EditClick
    end
  end
  object pnl_Bottom: TPanel [3]
    Left = 0
    Top = 316
    Width = 878
    Height = 75
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object lbl_comm: TLabel
      Left = 15
      Top = 39
      Width = 70
      Height = 13
      Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
    end
    object dedt_DtEnd: TDBDateTimeEditEh
      Left = 326
      Top = 1
      Width = 140
      Height = 21
      ControlLabel.Width = 64
      ControlLabel.Height = 13
      ControlLabel.Caption = #1044#1072#1090#1072' '#1089#1085#1103#1090#1080#1103
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      Kind = dtkDateEh
      TabOrder = 0
      Visible = True
    end
    object cmb_Reason: TDBComboBoxEh
      Left = 577
      Top = 1
      Width = 295
      Height = 21
      ControlLabel.Width = 81
      ControlLabel.Height = 13
      ControlLabel.Caption = #1055#1088#1080#1095#1080#1085#1072' '#1089#1085#1103#1090#1080#1103
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 1
      Visible = True
    end
    object mem_Comm: TMemo
      Left = 91
      Top = 28
      Width = 781
      Height = 41
      Lines.Strings = (
        'mem_Comm')
      TabOrder = 2
    end
    object chb_Close: TCheckBox
      Left = 91
      Top = 1
      Width = 97
      Height = 17
      Caption = #1042#1072#1082#1072#1085#1089#1080#1103' '#1089#1085#1103#1090#1072
      TabOrder = 3
      OnClick = chb_CloseClick
    end
  end
  object pnl_Buttons: TPanel [4]
    Left = 0
    Top = 391
    Width = 878
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 4
    DesignSize = (
      878
      30)
    object Img_Info: TImage
      Left = 3
      Top = 2
      Width = 23
      Height = 25
      Anchors = [akLeft, akBottom]
    end
    object Bt_Ok: TBitBtn
      Left = 716
      Top = 0
      Width = 75
      Height = 25
      Caption = 'Bt_Ok'
      TabOrder = 0
      OnClick = Bt_OkClick
    end
    object Bt_Cancel: TBitBtn
      Left = 797
      Top = 0
      Width = 75
      Height = 25
      Caption = 'BitBtn1'
      TabOrder = 1
      OnClick = Bt_CancelClick
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 32
    Top = 486
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 496
    Top = 125
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 562
    Top = 125
  end
end
