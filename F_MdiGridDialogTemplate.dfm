inherited Form_MdiGridDialogTemplate: TForm_MdiGridDialogTemplate
  Caption = 'Form_MdiGridDialogTemplate'
  ClientHeight = 433
  ClientWidth = 755
  ExplicitWidth = 771
  ExplicitHeight = 472
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 414
    Width = 755
    ExplicitTop = 414
    ExplicitWidth = 755
    inherited lbl_StatusBar_Right: TLabel
      Left = 666
      ExplicitLeft = 666
    end
  end
  object pnl_Buttons: TPanel [1]
    Left = 0
    Top = 381
    Width = 755
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      755
      33)
    object Img_Info: TImage
      Left = 8
      Top = 6
      Width = 23
      Height = 25
      Anchors = [akLeft, akBottom]
      ExplicitTop = 3
    end
    object Bev_Buttons: TBevel
      Left = 579
      Top = 2
      Width = 3
      Height = 25
      Anchors = [akRight, akBottom]
      ExplicitLeft = 618
      ExplicitTop = -1
    end
    object Bt_OK: TBitBtn
      Left = 588
      Top = 2
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_OK'
      TabOrder = 0
      OnClick = Bt_OKClick
    end
    object Bt_Cancel: TBitBtn
      Left = 669
      Top = 2
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Bt_Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = Bt_CancelClick
    end
    object chb_NoClose: TCheckBox
      Left = 373
      Top = 3
      Width = 121
      Height = 16
      Anchors = [akRight, akBottom]
      Caption = #1053#1077' '#1079#1072#1082#1088#1099#1074#1072#1090#1100' '#1086#1082#1085#1086
      TabOrder = 2
    end
    object Bt_Add: TBitBtn
      Left = 517
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 3
      OnClick = Bt_AddClick
    end
    object Bt_Del: TBitBtn
      Left = 548
      Top = 2
      Width = 25
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Bt_Add'
      TabOrder = 4
      OnClick = Bt_DelClick
    end
  end
  object pnl_Bottom: TPanel [2]
    Left = 0
    Top = 356
    Width = 755
    Height = 25
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
  end
  object pnl_Top: TPanel [3]
    Left = 0
    Top = 0
    Width = 755
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
  end
  object pnl_Client: TPanel [4]
    Left = 0
    Top = 25
    Width = 755
    Height = 331
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 4
    object DBGridEh1: TDBGridEh
      Left = 0
      Top = 0
      Width = 755
      Height = 331
      Align = alClient
      AllowedOperations = [alopUpdateEh]
      DataSource = DataSource1
      DynProps = <>
      Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
      RowDetailPanel.Height = 250
      TabOrder = 0
      OnAdvDrawDataCell = DBGridEh1AdvDrawDataCell
      OnColEnter = DBGridEh1ColEnter
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
  end
  inherited tmrAfterCreate: TTimer
    Left = 112
    Top = 416
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    AfterOpen = MemTableEh1AfterOpen
    AfterPost = MemTableEh1AfterPost
    AfterScroll = MemTableEh1AfterScroll
    AfterRefresh = MemTableEh1AfterRefresh
    Left = 123
    Top = 380
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 95
    Top = 380
  end
end
