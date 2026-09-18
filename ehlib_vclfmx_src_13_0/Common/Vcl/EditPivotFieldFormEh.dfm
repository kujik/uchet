object fEditPivotField: TfEditPivotField
  Left = 469
  Top = 149
  Caption = 'Summary function'
  ClientHeight = 313
  ClientWidth = 349
  Color = clBtnFace
  ParentFont = True
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    349
    313)
  TextHeight = 15
  object lFieldName: TLabel
    Left = 16
    Top = 16
    Width = 60
    Height = 15
    Caption = 'lFieldName'
  end
  object fAggrFunc: TLabel
    Left = 16
    Top = 48
    Width = 102
    Height = 15
    Caption = 'Summary function:'
  end
  object lDisplayFormat: TLabel
    Left = 16
    Top = 251
    Width = 82
    Height = 15
    Anchors = [akLeft, akBottom]
    Caption = 'Display Format:'
    ExplicitTop = 252
  end
  object ListBox1: TListBox
    Left = 16
    Top = 64
    Width = 321
    Height = 156
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    Items.Strings = (
      'Sum'
      'Count'
      'Average'
      'Max'
      'Min'
      'Count distinct'
      'Product'
      'StDev'
      'StDevp'
      'Var'
      'Varp')
    TabOrder = 0
  end
  object bOk: TButton
    Left = 182
    Top = 283
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
    ExplicitTop = 284
  end
  object bCancel: TButton
    Left = 262
    Top = 283
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    ExplicitTop = 284
  end
  object cbDisplayFormat: TDBComboBoxEh
    Left = 112
    Top = 247
    Width = 225
    Height = 21
    Anchors = [akLeft, akBottom]
    DynProps = <>
    EditButtons = <>
    TabOrder = 3
    Text = #39'#,00'
    Visible = True
    ExplicitTop = 248
  end
end
