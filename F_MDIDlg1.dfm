object Form_MDIDlg1: TForm_MDIDlg1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Form_MDIDlg1'
  ClientHeight = 141
  ClientWidth = 343
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  DesignSize = (
    343
    141)
  PixelsPerInch = 96
  TextHeight = 13
  object Bt_Cancel: TBitBtn
    Left = 260
    Top = 108
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Bt_Cancel'
    ModalResult = 2
    TabOrder = 0
    OnClick = Bt_CancelClick
  end
  object Bt_OK: TBitBtn
    Left = 179
    Top = 108
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_OK'
    TabOrder = 1
    OnClick = Bt_OKClick
  end
end
