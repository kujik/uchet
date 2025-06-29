inherited Dlg_Order_Stages1: TDlg_Order_Stages1
  BorderStyle = bsDialog
  Caption = 'Dlg_Order_Stages1'
  ClientHeight = 308
  ClientWidth = 274
  OnActivate = FormActivate
  ExplicitWidth = 280
  ExplicitHeight = 336
  PixelsPerInch = 96
  TextHeight = 13
  object Img_Info: TImage
    Left = 7
    Top = 272
    Width = 21
    Height = 20
    Anchors = []
    ExplicitLeft = 8
  end
  object lbl_Caption: TLabel
    Left = 8
    Top = 5
    Width = 54
    Height = 13
    Caption = 'lbl_Caption'
  end
  object bvl1: TBevel
    Left = 101
    Top = 272
    Width = 3
    Height = 25
    Anchors = [akRight, akBottom]
    ExplicitLeft = 110
  end
  object DBGridEh1: TDBGridEh
    Left = 8
    Top = 24
    Width = 258
    Height = 242
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
  object Bt_Ok: TBitBtn
    Left = 110
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    ModalResult = 1
    TabOrder = 1
    OnClick = Bt_OkClick
  end
  object Bt_Cancel: TBitBtn
    Left = 191
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 2
  end
  object Bt_Del: TBitBtn
    Left = 70
    Top = 272
    Width = 25
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Add'
    TabOrder = 3
    OnClick = Bt_DelClick
  end
  object Bt_Add: TBitBtn
    Left = 39
    Top = 272
    Width = 25
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Add'
    TabOrder = 4
    OnClick = Bt_AddClick
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    AfterPost = MemTableEh1AfterPost
    AfterScroll = MemTableEh1AfterScroll
    Left = 107
    Top = 211
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 31
    Top = 218
  end
  object tmr1: TTimer
    Interval = 100
    OnTimer = tmr1Timer
    Left = 160
    Top = 8
  end
end
