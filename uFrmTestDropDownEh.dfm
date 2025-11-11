object FrmTestDropDownEh: TFrmTestDropDownEh
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'FrmTestDropDownEh'
  ClientHeight = 240
  ClientWidth = 320
  Color = clBtnFace
  Constraints.MinHeight = 34
  Constraints.MinWidth = 34
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poDesigned
  DropDownMode = True
  DesignSize = (
    320
    240)
  TextHeight = 13
  object DBEditEh1: TDBEditEh
    Left = 8
    Top = 24
    Width = 121
    Height = 21
    DynProps = <>
    EditButtons = <>
    TabOrder = 2
    Text = 'DBEditEh1'
    Visible = True
  end
  object BitBtn1: TBitBtn
    Left = 160
    Top = 160
    Width = 75
    Height = 25
    Caption = 'BitBtn1'
    TabOrder = 3
    OnClick = BitBtn1Click
  end
end
