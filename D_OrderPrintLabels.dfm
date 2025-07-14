inherited Dlg_OrderPrintLabels: TDlg_OrderPrintLabels
  Caption = 'Dlg_OrderPrintLabels'
  ClientHeight = 263
  ClientWidth = 394
  ExplicitWidth = 410
  ExplicitHeight = 302
  TextHeight = 13
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = 0
    Width = 394
    Height = 225
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
  object Bt_Print: TBitBtn
    Left = 311
    Top = 231
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Print'
    TabOrder = 1
    OnClick = Bt_PrintClick
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 27
    Top = 27
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 75
    Top = 30
  end
end
