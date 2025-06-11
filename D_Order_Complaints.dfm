object Dlg_Order_Complaints: TDlg_Order_Complaints
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = #1055#1088#1080#1095#1080#1085#1099' '#1088#1077#1082#1083#1072#1084#1072#1094#1080#1081
  ClientHeight = 242
  ClientWidth = 428
  Color = clBtnFace
  Constraints.MinHeight = 34
  Constraints.MinWidth = 34
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = CustomDropDownFormEhCreate
  DropDownMode = True
  OnInitForm = CustomDropDownFormEhInitForm
  OnReturnParams = CustomDropDownFormEhReturnParams
  DesignSize = (
    428
    242)
  PixelsPerInch = 96
  TextHeight = 13
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = -2
    Width = 428
    Height = 203
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    DynProps = <>
    Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
    RowDetailPanel.Height = 250
    TabOrder = 2
    OnMouseDown = DBGridEh1MouseDown
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
    Left = 264
    Top = 209
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Ok'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = Bt_OkClick
  end
  object Bt_Cancel: TBitBtn
    Left = 345
    Top = 209
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'BitBtn1'
    ModalResult = 2
    TabOrder = 4
    OnClick = Bt_CancelClick
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 515
    Top = 3
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 515
    Top = 6
  end
end
