inherited Dlg_Grid1: TDlg_Grid1
  Caption = 'Dlg_Grid1'
  ClientHeight = 117
  ClientWidth = 737
  OnKeyUp = FormKeyUp
  ExplicitWidth = 753
  ExplicitHeight = 156
  TextHeight = 13
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = 0
    Width = 737
    Height = 117
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
    Left = 577
    Top = 14
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 511
    Top = 14
  end
end
