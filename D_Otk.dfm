inherited Dlg_Otk: TDlg_Otk
  BorderStyle = bsDialog
  Caption = 'Dlg_Otk'
  ClientHeight = 271
  ClientWidth = 190
  OnActivate = FormActivate
  OnKeyPress = FormKeyPress
  ExplicitWidth = 196
  ExplicitHeight = 300
  PixelsPerInch = 96
  TextHeight = 13
  object Img_Info: TImage
    Left = 0
    Top = 238
    Width = 21
    Height = 20
    Anchors = []
    ExplicitTop = 185
  end
  object Lb_Caption: TLabel
    Left = 8
    Top = 5
    Width = 54
    Height = 13
    Caption = 'Lb_Caption'
  end
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = 24
    Width = 190
    Height = 208
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    DynProps = <>
    Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
    RowDetailPanel.Height = 250
    TabOrder = 0
    object RowDetailData: TRowDetailPanelControlEh
      object E_PPComment: TDBEditEh
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
        Text = 'E_PPComment'
        Visible = False
      end
    end
  end
  object Bt_Ok: TBitBtn
    Left = 27
    Top = 238
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    ModalResult = 1
    TabOrder = 1
    OnClick = Bt_OkClick
    ExplicitLeft = 30
  end
  object Bt_Cancel: TBitBtn
    Left = 108
    Top = 238
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 2
    ExplicitLeft = 111
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
