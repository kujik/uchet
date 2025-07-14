inherited Dlg_LoadKBLog: TDlg_LoadKBLog
  Caption = 'Dlg_LoadKBLog'
  ClientHeight = 295
  ClientWidth = 628
  OnShow = nil
  ExplicitWidth = 644
  ExplicitHeight = 334
  TextHeight = 13
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = 0
    Width = 628
    Height = 295
    Align = alClient
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
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 515
    Top = 3
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 515
    Top = 62
  end
end
