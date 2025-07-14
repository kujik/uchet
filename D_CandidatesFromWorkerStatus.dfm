inherited Dlg_CandidatesFromWorkerStatus: TDlg_CandidatesFromWorkerStatus
  BorderStyle = bsDialog
  Caption = 'Dlg_CandidatesFromWorkerStatus'
  ClientHeight = 164
  ClientWidth = 663
  ExplicitWidth = 679
  ExplicitHeight = 203
  TextHeight = 13
  object lbl1: TLabel
    Left = 8
    Top = 143
    Width = 167
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1047#1072#1076#1072#1081#1090#1077' '#1089#1090#1072#1090#1091#1089' '#1076#1083#1103' '#1089#1086#1080#1089#1082#1072#1090#1077#1083#1103'.'
    Color = clBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ExplicitTop = 91
  end
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = 0
    Width = 663
    Height = 130
    Align = alTop
    DataSource = DataSource1
    DynProps = <>
    Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
    RowDetailPanel.Height = 250
    TabOrder = 0
    OnMouseDown = DBGridEh1MouseDown
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
    Left = 580
    Top = 136
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 1
    OnClick = Bt_CancelClick
    ExplicitLeft = 903
    ExplicitTop = 88
  end
  object Bt_Ok: TBitBtn
    Left = 504
    Top = 136
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    ModalResult = 1
    TabOrder = 2
    OnClick = Bt_OkClick
    ExplicitLeft = 827
    ExplicitTop = 88
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 558
    Top = 3
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 603
    Top = 6
  end
end
