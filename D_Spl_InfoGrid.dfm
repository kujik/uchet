inherited Dlg_Spl_InfoGrid: TDlg_Spl_InfoGrid
  Caption = 'Dlg_Spl_InfoGrid'
  ClientHeight = 431
  ClientWidth = 747
  ExplicitWidth = 763
  ExplicitHeight = 470
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 412
    Width = 747
    ExplicitTop = 413
    ExplicitWidth = 751
    inherited lbl_StatusBar_Right: TLabel
      Left = 668
      ExplicitLeft = 668
    end
  end
  inherited pnl_Buttons: TPanel
    Top = 379
    Width = 747
    ExplicitTop = 380
    ExplicitWidth = 751
  end
  inherited pnl_Bottom: TPanel
    Top = 354
    Width = 747
    ExplicitTop = 355
    ExplicitWidth = 751
  end
  inherited pnl_Top: TPanel
    Width = 747
    ExplicitWidth = 751
    object lbl_Caption: TLabel
      Left = 8
      Top = 6
      Width = 52
      Height = 13
      Caption = 'lbl_Caption'
    end
  end
  inherited pnl_Client: TPanel
    Width = 747
    Height = 329
    ExplicitWidth = 751
    ExplicitHeight = 330
    inherited DBGridEh1: TDBGridEh
      RowDetailPanel.Active = True
      RowDetailPanel.Width = 200
      OnDblClick = DBGridEh1DblClick
      OnRowDetailPanelShow = DBGridEh1RowDetailPanelShow
      inherited RowDetailData: TRowDetailPanelControlEh
        ExplicitLeft = 30
        ExplicitTop = 35
        ExplicitWidth = 200
        ExplicitHeight = 250
        object DBGridEh2: TDBGridEh
          Left = 0
          Top = 0
          Width = 198
          Height = 248
          Align = alClient
          AllowedOperations = [alopUpdateEh]
          DataSource = DataSource2
          DynProps = <>
          Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
          OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
          RowDetailPanel.Width = 200
          RowDetailPanel.Height = 250
          TabOrder = 1
          object RowDetailData: TRowDetailPanelControlEh
            object DBEditEh1: TDBEditEh
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
    end
  end
  object DataSource2: TDataSource
    DataSet = MemTableEh2
    Left = 183
    Top = 380
  end
  object MemTableEh2: TMemTableEh
    Params = <>
    AfterPost = MemTableEh1AfterPost
    AfterScroll = MemTableEh1AfterScroll
    Left = 211
    Top = 380
  end
end
