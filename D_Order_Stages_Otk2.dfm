inherited Dlg_Order_Stages_Otk2: TDlg_Order_Stages_Otk2
  BorderStyle = bsDialog
  Caption = 'Dlg_Order_Stages_Otk2'
  ClientHeight = 266
  ClientWidth = 923
  ExplicitWidth = 929
  ExplicitHeight = 294
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_Caption: TLabel
    Left = 8
    Top = 5
    Width = 54
    Height = 13
    Caption = 'lbl_Caption'
  end
  object Img_Info: TImage
    Left = 8
    Top = 238
    Width = 21
    Height = 20
    Anchors = [akLeft, akBottom]
  end
  object bvl1: TBevel
    Left = 748
    Top = 231
    Width = 3
    Height = 25
    Anchors = [akRight, akBottom]
  end
  object DBGridEh1: TDBGridEh
    Left = 8
    Top = 24
    Width = 907
    Height = 201
    AllowedOperations = [alopUpdateEh]
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    DynProps = <>
    Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
    RowDetailPanel.Height = 250
    TabOrder = 0
    OnKeyPress = DBGridEh1KeyPress
    OnSumListAfterRecalcAll = DBGridEh1SumListAfterRecalcAll
    object RowDetailData: TRowDetailPanelControlEh
      object edt_PPComment: TDBEditEh
        Left = 299
        Top = 215
        Width = 494
        Height = 21
        ControlLabel.Width = 67
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
  object Bt_Cancel: TBitBtn
    Left = 840
    Top = 233
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 1
  end
  object Bt_Ok: TBitBtn
    Left = 759
    Top = 233
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    ModalResult = 1
    TabOrder = 2
    OnClick = Bt_OkClick
  end
  object Bt_Add: TBitBtn
    Left = 684
    Top = 233
    Width = 25
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Add'
    TabOrder = 3
    OnClick = Bt_AddClick
  end
  object Bt_Del: TBitBtn
    Left = 715
    Top = 233
    Width = 25
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Add'
    TabOrder = 4
    OnClick = Bt_DelClick
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 47
    Top = 76
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    AfterPost = MemTableEh1AfterPost
    AfterScroll = MemTableEh1AfterScroll
    Left = 75
    Top = 76
  end
  object tmr1: TTimer
    Interval = 100
    OnTimer = tmr1Timer
    Left = 48
    Top = 232
  end
end
