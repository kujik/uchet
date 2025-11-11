inherited Dlg_Otk: TDlg_Otk
  BorderStyle = bsDialog
  Caption = 'Dlg_Otk'
  ClientHeight = 268
  ClientWidth = 178
  OnActivate = FormActivate
  OnKeyPress = FormKeyPress
  ExplicitWidth = 194
  ExplicitHeight = 307
  TextHeight = 13
  object Img_Info: TImage
    Left = 0
    Top = 235
    Width = 21
    Height = 20
    Anchors = []
    ExplicitTop = 185
  end
  object lbl_Caption: TLabel
    Left = 8
    Top = 5
    Width = 53
    Height = 13
    Caption = 'lbl_Caption'
  end
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = 24
    Width = 166
    Height = 205
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    DynProps = <>
    Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
    RowDetailPanel.Height = 250
    TabOrder = 0
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
    Left = 3
    Top = 235
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    ModalResult = 1
    TabOrder = 1
    OnClick = Bt_OkClick
  end
  object Bt_Cancel: TBitBtn
    Left = 84
    Top = 235
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 2
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    AfterPost = MemTableEh1AfterPost
    Left = 297
    Top = 3
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 297
    Top = 6
  end
end
