object FrmTest: TFrmTest
  Left = 0
  Top = 0
  Caption = 'FrmTest'
  ClientHeight = 739
  ClientWidth = 1215
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Visible = True
  TextHeight = 13
  object lbl1: TLabel
    Left = 377
    Top = 390
    Width = 16
    Height = 13
    Caption = 'lbl1'
    OnClick = lbl1Click
  end
  object btn1: TSpeedButton
    Left = 25
    Top = 421
    Width = 23
    Height = 22
    OnClick = SpeedButton1Click
  end
  object lbl2: TLabel
    Left = 880
    Top = 584
    Width = 16
    Height = 13
    Caption = 'lbl2'
  end
  object Image2: TImage
    Left = 801
    Top = 292
    Width = 105
    Height = 105
  end
  object SpeedButton2: TSpeedButton
    Left = 840
    Top = 346
    Width = 56
    Height = 57
  end
  object BitBtn1: TBitBtn
    Left = 25
    Top = 30
    Width = 145
    Height = 25
    Caption = 'BitBtn1'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object DBComboBoxEh1: TDBComboBoxEh
    Left = 24
    Top = 115
    Width = 121
    Height = 21
    DynProps = <
      item
        Name = 'Verify'
        Value = 'aaaa'
      end>
    EditButtons = <>
    Items.Strings = (
      'qwerty'
      'dfgt')
    LimitTextToListValues = True
    MRUList.Active = True
    TabOrder = 1
    Text = 'DBComboBoxEh1'
    Visible = True
  end
  object DBCheckBoxEh1: TDBCheckBoxEh
    Left = 311
    Top = 28
    Width = 97
    Height = 17
    Caption = 'DBCheckBoxEh1'
    DynProps = <>
    State = cbGrayed
    TabOrder = 2
    ValueChecked = 'true'
  end
  object DBRadioGroupEh1: TDBRadioGroupEh
    Left = 432
    Top = 28
    Width = 185
    Height = 105
    Caption = 'DBRadioGroupEh1'
    ParentBackground = True
    TabOrder = 3
  end
  object DBCheckBoxEh2: TDBCheckBoxEh
    Left = 440
    Top = 48
    Width = 97
    Height = 17
    Caption = 'DBCheckBoxEh2'
    DynProps = <>
    TabOrder = 4
  end
  object DBCheckBoxEh3: TDBCheckBoxEh
    Left = 440
    Top = 71
    Width = 97
    Height = 17
    Caption = 'DBCheckBoxEh3'
    DynProps = <>
    TabOrder = 5
  end
  object DBNumberEditEh1: TDBNumberEditEh
    Left = 24
    Top = 88
    Width = 121
    Height = 21
    currency = False
    DynProps = <>
    EditButton.DefaultAction = True
    EditButton.Style = ebsEllipsisEh
    EditButtons = <>
    HighlightRequired = True
    TabOrder = 6
    Visible = True
    OnChange = DBNumberEditEh1Change
  end
  object DBDateTimeEditEh1: TDBDateTimeEditEh
    Left = 24
    Top = 61
    Width = 121
    Height = 21
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 7
    Visible = True
  end
  object bt_fromxls: TBitBtn
    Left = 24
    Top = 142
    Width = 121
    Height = 25
    Caption = 'bt_fromxls'
    TabOrder = 8
    OnClick = bt_fromxlsClick
  end
  object StringGrid1: TStringGrid
    Left = 24
    Top = 173
    Width = 320
    Height = 204
    TabOrder = 9
  end
  object BitBtn2: TBitBtn
    Left = 625
    Top = -2
    Width = 75
    Height = 25
    Caption = 'TURV'
    TabOrder = 10
    OnClick = BitBtn2Click
  end
  object BitBtn3: TBitBtn
    Left = 625
    Top = 29
    Width = 75
    Height = 25
    Caption = 'Users'
    TabOrder = 11
    OnClick = BitBtn3Click
  end
  object Button1: TButton
    Left = 624
    Top = 358
    Width = 153
    Height = 25
    Caption = 'Button1'
    TabOrder = 12
    OnClick = Button1Click
  end
  object Bt_LoadXLSM: TBitBtn
    Left = 625
    Top = 57
    Width = 75
    Height = 25
    Caption = 'LoadXLSM'
    TabOrder = 13
    OnClick = Bt_LoadXLSMClick
  end
  object LabeledEdit1: TLabeledEdit
    Left = 593
    Top = 430
    Width = 121
    Height = 21
    EditLabel.Width = 61
    EditLabel.Height = 13
    EditLabel.Caption = 'LabeledEdit1'
    TabOrder = 14
    Text = ''
    OnChange = LabeledEdit1Change
  end
  object Bt_Dlg_BasicInput: TBitBtn
    Left = 625
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Bt_Dlg_BasicInput'
    TabOrder = 15
    OnClick = Bt_Dlg_BasicInputClick
  end
  object Bt_LoadXLS: TBitBtn
    Left = 625
    Top = 119
    Width = 75
    Height = 25
    Caption = 'LoadXLS'
    TabOrder = 16
    OnClick = Bt_LoadXLSClick
  end
  object Bt_SaveXLSX: TBitBtn
    Left = 625
    Top = 150
    Width = 75
    Height = 25
    Caption = 'Save XLSX'
    TabOrder = 17
    OnClick = Bt_SaveXLSXClick
  end
  object Edit1: TEdit
    Left = 176
    Top = 61
    Width = 121
    Height = 21
    TabOrder = 18
    Text = 'Edit1'
  end
  object DBDateTimeEditEh2: TDBDateTimeEditEh
    Left = 579
    Top = 243
    Width = 121
    Height = 21
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 19
    Visible = True
  end
  object Bt_FastReport: TBitBtn
    Left = 625
    Top = 181
    Width = 75
    Height = 25
    Caption = 'FastReport'
    TabOrder = 20
    OnClick = Bt_FastReportClick
  end
  object Button2: TButton
    Left = 25
    Top = 390
    Width = 75
    Height = 25
    Caption = 'Button2'
    DropDownMenu = PopupMenu1
    Style = bsSplitButton
    TabOrder = 21
  end
  object Bt_Tree: TBitBtn
    Left = 625
    Top = 212
    Width = 75
    Height = 25
    Caption = 'Tree'
    TabOrder = 22
    OnClick = Bt_TreeClick
  end
  object DBLookupComboboxEh1: TDBLookupComboboxEh
    Left = 24
    Top = 449
    Width = 177
    Height = 21
    DynProps = <>
    DataField = ''
    EditButtons = <>
    TabOrder = 23
    Visible = True
  end
  object ProgressBar1: TProgressBar
    Left = 400
    Top = 173
    Width = 150
    Height = 17
    Style = pbstMarquee
    TabOrder = 24
  end
  object pnl_Btns: TPanel
    Left = 8
    Top = 511
    Width = 529
    Height = 41
    TabOrder = 25
  end
  object CheckBox1: TCheckBox
    Left = 603
    Top = 457
    Width = 97
    Height = 25
    Caption = 'CheckBox1'
    TabOrder = 26
  end
  object pnl1: TPanel
    Left = 720
    Top = 8
    Width = 495
    Height = 278
    Caption = 'pnl1'
    TabOrder = 27
    object l1: TLabel
      Left = 176
      Top = 26
      Width = 16
      Height = 13
      Caption = 'top'
    end
    object l2: TLabel
      Left = 104
      Top = 45
      Width = 210
      Height = 13
      Caption = '22222222222222222222222222222222222'
    end
    object bv3: TBevel
      Left = 32
      Top = 63
      Width = 305
      Height = 3
    end
    object edt_1: TDBEditEh
      Left = 33
      Top = 18
      Width = 121
      Height = 21
      DynProps = <>
      EditButtons = <>
      TabOrder = 0
      Text = 'top'
      Visible = True
    end
    object e4: TDBEditEh
      Left = 33
      Top = 72
      Width = 48
      Height = 21
      DynProps = <>
      EditButtons = <>
      TabOrder = 1
      Text = '44444444444444444444444'
      Visible = True
    end
    object chb4: TCheckBox
      Left = 160
      Top = 82
      Width = 97
      Height = 17
      Caption = '44444444444444444'
      TabOrder = 2
    end
    object bt_44: TBitBtn
      Left = 240
      Top = 18
      Width = 21
      Height = 21
      Caption = 'bt_44'
      TabOrder = 3
    end
    object DBEditEh1: TDBEditEh
      Left = 169
      Top = 129
      Width = 200
      Height = 21
      DynProps = <>
      EditButtons = <>
      TabOrder = 4
      Text = 'top'
      Visible = True
    end
    object DBEditEh2: TDBEditEh
      Left = 25
      Top = 129
      Width = 112
      Height = 21
      DynProps = <>
      EditButtons = <>
      TabOrder = 5
      Text = 'top'
      Visible = True
    end
  end
  object Bt_Align: TBitBtn
    Left = 720
    Top = 292
    Width = 75
    Height = 25
    Caption = 'Align'
    TabOrder = 28
    OnClick = Bt_AlignClick
  end
  object FlowPanel2: TFlowPanel
    AlignWithMargins = True
    Left = 3
    Top = 662
    Width = 1209
    Height = 74
    Align = alBottom
    Alignment = taLeftJustify
    AutoSize = True
    AutoWrap = False
    BevelEdges = [beTop]
    BevelOuter = bvNone
    BevelWidth = 3
    BorderStyle = bsSingle
    Caption = 'Fp1'
    DockSite = True
    FlowStyle = fsRightLeftTopBottom
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 4
    Padding.Bottom = 4
    TabOrder = 29
    ExplicitTop = 661
    ExplicitWidth = 1205
    object Panel2: TPanel
      Left = 1160
      Top = 4
      Width = 41
      Height = 44
      Align = alLeft
      Caption = 'pnlFrmBtnsInfo'
      TabOrder = 0
      object Image1: TImage
        Left = 8
        Top = 16
        Width = 20
        Height = 20
      end
    end
    object Panel3: TPanel
      Left = 1061
      Top = 4
      Width = 99
      Height = 44
      Align = alLeft
      Caption = 'pnlFrmBtnsL'
      TabOrder = 1
    end
    object Panel4: TPanel
      Left = 962
      Top = 4
      Width = 99
      Height = 62
      Align = alRight
      Caption = 'pnlFrmBtnsR'
      TabOrder = 2
    end
    object Panel5: TPanel
      Left = 863
      Top = 4
      Width = 99
      Height = 44
      Align = alRight
      Caption = 'pnlFrmBtnsMain'
      TabOrder = 3
    end
    object Panel6: TPanel
      Left = 734
      Top = 4
      Width = 129
      Height = 44
      Align = alRight
      Caption = 'pnlFrmBtnsChb'
      TabOrder = 4
      DesignSize = (
        129
        44)
      object CheckBox2: TCheckBox
        Left = 6
        Top = 6
        Width = 121
        Height = 16
        Anchors = [akRight, akBottom]
        Caption = #1053#1077' '#1079#1072#1082#1088#1099#1074#1072#1090#1100' '#1086#1082#1085#1086
        TabOrder = 0
      end
    end
  end
  object DBGridEh1: TDBGridEh
    Left = 907
    Top = 292
    Width = 305
    Height = 285
    DataSource = MemTableEh1
    DynProps = <>
    TabOrder = 30
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object BitBtn4: TBitBtn
    Left = 1140
    Top = 584
    Width = 75
    Height = 25
    Caption = 'BitBtn4'
    TabOrder = 31
    OnClick = BitBtn4Click
  end
  object OpenDialog1: TOpenDialog
    Left = 304
    Top = 416
  end
  object OpenDialog2: TOpenDialog
    Left = 136
    Top = 240
  end
  object IdSMTP1: TIdSMTP
    SASLMechanisms = <>
    Left = 487
    Top = 325
  end
  object DataSource1: TDataSource
    Left = 480
    Top = 424
  end
  object PopupMenu1: TPopupMenu
    Left = 216
    Top = 408
    object N11: TMenuItem
      Caption = '1'
    end
    object N21: TMenuItem
      Caption = '2'
    end
    object N31: TMenuItem
      Caption = '3'
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 776
    Top = 440
    object asdasd1: TMenuItem
      Caption = 'asdasd'
    end
    object asdadasdsadasdsaf1: TMenuItem
      Bitmap.Data = {
        36200000424D3620000000000000360000002800000040000000200000000100
        20000000000000200000C30E0000C30E00000000000000000000FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00A486883D9E6C8CA99F6C8CE69F6C8DF99F6C
        8DE69F6C8DAAA387873FFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF008A8A8A3D7B7B7BA97B7B7BE67B7B7BF97B7B
        7BE67B7B7BAA8A8A8A3FFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00A9988E039F698A96A07789FEA8A37CFFADBF75FFAEC773FFADBE
        75FFA8A37CFFA17789FF9F698999A5948104FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF009696960379797996818181FE979797FFA6A6A6FFABABABFFA6A6
        A6FF979797FF818181FF7878789990909004FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00A37B8E96A38685FFAEC573FFAFCA72FFAFCA72FFAFCA72FFAFCA
        72FFAFCA72FFAEC573FFA38586FF9D6A9099FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF0085858596898989FFA9A9A9FFACACACFFACACACFFACACACFFACAC
        ACFFACACACFFA9A9A9FF888888FF7B7B7B99FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00A87C99859F6C8DF89F6C8DFF9F6C8DFF9F6C8DFF9F6C
        8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C
        8DFF9F6C8DFFA17889FFAEC573FFAFCA72FFAFCA72FFAFCA72FFD8EAE8FFAFCA
        72FFAFCA72FFAFCA72FFAEC573FFA07789FEA588883FFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00898989857B7B7BF87B7B7BFF7B7B7BFF7B7B7BFF7B7B
        7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B
        7BFF7B7B7BFF818181FFA9A9A9FFACACACFFACACACFFACACACFFE7E7E7FFACAC
        ACFFACACACFFACACACFFA9A9A9FF818181FE8B8B8B3FFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DF8EBEEF8FFF0F7FFFFF0F7FFFFF0F7FFFFF0F7
        FFFFF0F7FFFFF0F7FFFFE7F3FCFFDEEFFAFFDEEFFAFFDEEFFAFFDEEFFAFFDEEF
        FAFFB497B1FFA8A47CFFAFCA72FFAFCA72FFAFCA72FFAFCA72FFDEEFF9FFAFCA
        72FFAFCA72FFAFCA72FFAFCA72FFA8A37CFF9F6B8CABFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BF8F0F0F0FFF8F8F8FFF8F8F8FFF8F8F8FFF8F8
        F8FFF8F8F8FFF8F8F8FFF4F4F4FFF0F0F0FFF0F0F0FFF0F0F0FFF0F0F0FFF0F0
        F0FFA2A2A2FF989898FFACACACFFACACACFFACACACFFACACACFFF0F0F0FFACAC
        ACFFACACACFFACACACFFACACACFF979797FF7A7A7AABFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFF0F7FFFFA17090FFF0F7FFFFC8B3C7FFC8B3
        C7FFF0F7FFFFA17090FFF0F7FFFFC6B2C6FFBFAFC5FFDEEFFAFFA16F90FFDEEF
        FAFFA57897FFADBF75FFAFCA72FFAFCA72FFAFCA72FFAFCA72FFDEEFF9FFAFCA
        72FFAFCA72FFAFCA72FFAFCA72FFADBF75FF9F6C8DE8FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFF8F8F8FF7F7F7FFFF8F8F8FFBBBBBBFFBBBB
        BBFFF8F8F8FF7F7F7FFFF8F8F8FFBABABAFFB7B7B7FFF0F0F0FF7E7E7EFFF0F0
        F0FF868686FFA6A6A6FFACACACFFACACACFFACACACFFACACACFFF0F0F0FFACAC
        ACFFACACACFFACACACFFACACACFFA6A6A6FF7B7B7BE8FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFDCE3EAFF65465AFFB3B8BEFFBEAABDFFC8B3
        C7FFF0F7FFFF996A89FFB8BEC4FF817380FF9F90A1FFDBECF7FFA06F90FFDEEF
        FAFF906381FF7B8D50FF7C8F50FFCADBD9FFDEEFF9FFDEEFF9FFDEEFF9FFDEEF
        F9FFDEEFF9FFD8EAE8FFAFCA72FFAEC872FF9F6C8DFCFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFE4E4E4FF4F4F4FFFB9B9B9FFB1B1B1FFBBBB
        BBFFF8F8F8FF787878FFBFBFBFFF787878FF969696FFEDEDEDFF7E7E7EFFF0F0
        F0FF717171FF787878FF797979FFD8D8D8FFF0F0F0FFF0F0F0FFF0F0F0FFF0F0
        F0FFF0F0F0FFE7E7E7FFACACACFFABABABFF7B7B7BFCFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFBBC1C7FF070707FF515356FFCED4DBFFF0F7
        FFFFF0F7FFFFC7CCD3FF4D4F52FF0D0E0EFF6D7074FFD4DFE7FFDEEFFAFFDEEF
        FAFF7A586FFF282C1BFF282E1AFF8FA55DFFAEC972FFAFCA72FFDEEFF9FFAFCA
        72FFAFCA72FFAFCA72FFAFCA72FFADBF75FF9F6C8DE8FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFC2C2C2FF070707FF535353FFD5D5D5FFF8F8
        F8FFF8F8F8FFCDCDCDFF4F4F4FFF0D0D0DFF707070FFE0E0E0FFF0F0F0FFF0F0
        F0FF626262FF262626FF272727FF8C8C8CFFABABABFFACACACFFF0F0F0FFACAC
        ACFFACACACFFACACACFFACACACFFA6A6A6FF7B7B7BE8FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFBBC1C7FF070707FF515356FFCED4DBFFF0F7
        FFFFEEF5FDFFACB1B7FF282A2BFF070707FF47494BFFC0C6CCFFE7F3FCFFDEEF
        FAFF847082FF27261DFF282E1AFF8FA55DFFAEC972FFAFCA72FFDEEFF9FFAFCA
        72FFAFCA72FFAFCA72FFAFCA72FFA8A37DFF9E6C8CAAFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFC2C2C2FF070707FF535353FFD5D5D5FFF8F8
        F8FFF6F6F6FFB2B2B2FF2A2A2AFF070707FF494949FFC7C7C7FFF4F4F4FFF0F0
        F0FF777777FF232323FF272727FF8C8C8CFFABABABFFACACACFFF0F0F0FFACAC
        ACFFACACACFFACACACFFACACACFF989898FF7B7B7BAAFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFB1BDC4FF070707FF515356FFCED4DBFFF0F7
        FFFFE2E8F0FF888B90FF222324FF141415FF252627FFA2A7ACFFEDF4FCFFE7F3
        FCFF9899A4FF251C20FF282D1AFF8FA55DFFAEC972FFAFCA72FFD8EBE9FFAFCA
        72FFAFCA72FFAFCA72FFAEC573FFA07789FFA589873FFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBDBDBDFF070707FF535353FFD5D5D5FFF8F8
        F8FFE9E9E9FF8C8C8CFF232323FF141414FF262626FFA7A7A7FFF5F5F5FFF4F4
        F4FF9C9C9CFF1E1E1EFF262626FF8C8C8CFFABABABFFACACACFFE8E8E8FFACAC
        ACFFACACACFFACACACFFA9A9A9FF818181FF8B8B8B3FFFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFADBBC3FF060707FF525456FFCED4DBFFF0F7
        FFFFCFD5DCFF5B5E61FF38393BFF4A4D4FFF222324FF7D8185FFDFE6EDFFF0F7
        FFFFAAB3BAFF2B252BFF251E1EFF8EA15EFFAEC972FFAFCA72FFAFCA72FFAFCA
        72FFAFCA72FFAEC573FFA38685FFA16D8D99FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBBBBBBFF060606FF545454FFD5D5D5FFF8F8
        F8FFD6D6D6FF5E5E5EFF393939FF4D4D4DFF232323FF818181FFE7E7E7FFF8F8
        F8FFB4B4B4FF272727FF1E1E1EFF8A8A8AFFABABABFFACACACFFACACACFFACAC
        ACFFACACACFFA9A9A9FF898989FF7C7C7C99FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFB4BEC5FF060707FF525455FFCDD4DBFFEEF5
        FDFFB8BEC4FF363739FF505255FF969A9FFF3D3F41FF55575AFFC9CFD6FFF0F7
        FFFFB1B6BCFF35383AFF2A242AFF836270FFA7A37DFFADBF75FFAEC872FFADBF
        75FFA8A47CFFA17889FF9F698A98A6948503FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBEBEBEFF060606FF545454FFD5D5D5FFF6F6
        F6FFBFBFBFFF373737FF525252FF9B9B9BFF3F3F3FFF575757FFD0D0D0FFF8F8
        F8FFB7B7B7FF383838FF262626FF696969FF989898FFA6A6A6FFABABABFFA6A6
        A6FF989898FF818181FF7979799891919103FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFBBC1C7FF060707FF4B5154FFC3D0D8FFE4EB
        F3FF969A9FFF2B2D2EFF73767AFFCDD3DAFF5A5D60FF313234FFB0B5BBFFEEF5
        FDFFB1B6BCFF38393BFF353739FFA8A9B6FFB397B0FFA57897FFA06F8FFFA578
        97FF9F6C8DFFA98E963EFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFC2C2C2FF060606FF515151FFD0D0D0FFECEC
        ECFF9B9B9BFF2D2D2DFF767676FFD4D4D4FF5D5D5DFF323232FFB6B6B6FFF6F6
        F6FFB7B7B7FF393939FF373737FFACACACFFA1A1A1FF868686FF7E7E7EFF8686
        86FF7B7B7BFF9393933EFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFBBC1C7FF070707FF4E5255FF8F6A83FF8F61
        7FFF46303EFF241820FF68465CFF966685FF4F3546FF191116FF5D3F52FFC5B7
        C7FFB1B6BCFF38393BFF37383AFFBCC6CEFFDDEEF9FFDEEFFAFFDEEFFAFFDEEF
        FAFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFC2C2C2FF070707FF525252FF757575FF6F6F
        6FFF363636FF1B1B1BFF505050FF747474FF3D3D3DFF131313FF484848FFBDBD
        BDFFB7B7B7FF393939FF383838FFC7C7C7FFEFEFEFFFF0F0F0FFF0F0F0FFF0F0
        F0FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFB4BEC5FF070707FF515356FFC5CFD6FFB6C4
        CDFF404447FF434547FFC7CCD3FFE9F0F8FF989CA1FF313234FF64676AFFD2D8
        DFFFB1B6BCFF38393BFF37383AFFC4C9D0FFE6F2FBFFDEEFFAFFDEEFFAFFDEEF
        FAFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBEBEBEFF070707FF535353FFCFCFCFFFC5C5
        C5FF444444FF454545FFCDCDCDFFF1F1F1FF9D9D9DFF323232FF676767FFD9D9
        D9FFB7B7B7FF393939FF383838FFCACACAFFF3F3F3FFF0F0F0FFF0F0F0FFF0F0
        F0FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFAFBBC3FF060707FF515356FF89657EFF6746
        5BFF20161DFF412C3AFF936482FF9E6B8CFF7F5670FF2C1E27FF271B23FF7852
        6BFF724E65FF271D24FF37383AFFC4C9D0FFEFF6FEFFE7F3FCFFDEEFFAFFDEEF
        FAFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBCBCBCFF060606FF535353FF707070FF5050
        50FF191919FF323232FF727272FF7A7A7AFF626262FF222222FF1E1E1EFF5D5D
        5DFF585858FF202020FF383838FFCACACAFFF7F7F7FFF4F4F4FFF0F0F0FFF0F0
        F0FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFB9C0C6FF060707FF4E5255FFB9BFC5FF6D70
        74FF2B2E2FFF838E94FFD8E7EFFFEFF7FFFFD9E0E7FF626568FF292B2CFF8E92
        97FFA2A7ACFF38393BFF37383AFFC4C9D0FFEFF6FEFFF0F7FFFFE7F3FCFFDEEF
        FAFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFC0C0C0FF060606FF525252FFC0C0C0FF7070
        70FF2D2D2DFF8E8E8EFFE7E7E7FFF8F8F8FFE1E1E1FF656565FF2B2B2BFF9393
        93FFA7A7A7FF393939FF383838FFCACACAFFF7F7F7FFF8F8F8FFF4F4F4FFF0F0
        F0FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFB4BEC5FF070707FF494E51FF9EA6ACFF494C
        4EFF343537FFB2BCC3FFDCEDF8FFE3F2FBFFE3EAF2FF888C91FF292B2CFF6669
        6CFF979BA0FF38393BFF37383AFFC4C9D0FFEFF6FEFFF0F7FFFFF0F7FFFFE7F3
        FCFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBEBEBEFF070707FF4E4E4EFFA6A6A6FF4C4C
        4CFF353535FFBCBCBCFFEEEEEEFFF2F2F2FFEBEBEBFF8D8D8DFF2B2B2BFF6969
        69FF9C9C9CFF393939FF383838FFCACACAFFF7F7F7FFF8F8F8FFF8F8F8FFF4F4
        F4FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFADBBC3FF060707FF484A4DFF5A4353FF2217
        1EFF32222CFF895D79FF9F6C8DFF9F6C8DFF9D6A8BFF765069FF241820FF2E1F
        28FF594252FF353638FF37383AFFC4C9D0FFEFF6FEFFF0F7FFFFF0F7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBBBBBBFF060606FF4A4A4AFF4A4A4AFF1A1A
        1AFF262626FF6A6A6AFF7B7B7BFF7B7B7BFF797979FF5B5B5BFF1B1B1BFF2323
        23FF494949FF363636FF383838FFCACACAFFF7F7F7FFF8F8F8FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFADBBC3FF060707FF404446FF5B5F62FF2124
        25FF6E7378FFDAE1E8FFF0F7FFFFE7F3FCFFDEEFFAFFC2CFD7FF525457FF3132
        34FF5B5E61FF2D2E30FF37383AFFC4C9D0FFEFF6FEFFF0F7FFFFF0F7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBBBBBBFF060606FF444444FF5F5F5FFF2323
        23FF737373FFE2E2E2FFF8F8F8FFF4F4F4FFF0F0F0FFCFCFCFFF545454FF3232
        32FF5E5E5EFF2E2E2EFF383838FFCACACAFFF7F7F7FFF8F8F8FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFADBBC3FF040505FF2D3133FF271D24FF1710
        14FF68475CFF9A6989FF9F6C8DFF9F6C8DFF9F6C8DFF936482FF553F4FFF2628
        29FF261C23FF191116FF261C23FFC4C9D0FFEFF6FEFFF0F7FFFFF0F7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBBBBBBFF040404FF313131FF202020FF1111
        11FF515151FF787878FF7B7B7BFF7B7B7BFF7B7B7BFF727272FF464646FF2828
        28FF1F1F1FFF131313FF1F1F1FFFCACACAFFF7F7F7FFF8F8F8FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFADBBC3FF020202FF111314FF18191AFF3A3D
        3FFFBAC1C7FFE0F0FAFFE7F3FCFFF0F7FFFFF0F7FFFFE2EDF6FF97A2AAFF272A
        2BFF131314FF121213FF343537FFC4C9D0FFEFF6FEFFF0F7FFFFF0F7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBBBBBBFF020202FF131313FF191919FF3D3D
        3DFFC1C1C1FFF1F1F1FFF4F4F4FFF8F8F8FFF8F8F8FFEEEEEEFFA3A3A3FF2929
        29FF131313FF121212FF353535FFCACACAFFF7F7F7FFF8F8F8FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFADBBC3FF010101FF030404FF101112FF5B62
        67FFCAD5DCFFEDF6FEFFE0F0FAFFE7F3FCFFF0F7FFFFF0F7FFFFBAC3CBFF4044
        48FF09090AFF040404FF323335FFC4C9D0FFEFF6FEFFF0F7FFFFF0F7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBBBBBBFF010101FF030303FF111111FF6262
        62FFD5D5D5FFF7F7F7FFF1F1F1FFF4F4F4FFF8F8F8FFF8F8F8FFC4C4C4FF4444
        44FF090909FF040404FF333333FFCACACAFFF7F7F7FFF8F8F8FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6C8DFFADBBC3FF000000FF000000FF161719FF828C
        92FFD5E6F0FFE7F3FCFFEDF6FEFFE0F0FAFFE7F3FCFFF0F7FFFFD5DBE2FF676D
        71FF111213FF000000FF323335FFC9CCD0FFF0F6FEFFF0F7FFFFF0F7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7BFFBBBBBBFF000000FF000000FF171717FF8C8C
        8CFFE7E7E7FFF4F4F4FFF7F7F7FFF1F1F1FFF4F4F4FFF8F8F8FFDCDCDCFF6D6D
        6DFF121212FF000000FF333333FFCCCCCCFFF7F7F7FFF8F8F8FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009F6B8CF4865B77FF2D1E28FF2E1F29FF412C3AFF7E57
        71FFBDAAC1FFDEEFFAFFE7F3FCFFEDF6FEFFE0F0FAFFE7F3FCFFE8EFF7FFA8AD
        B3FF54595CFF3F4347FF686B6DFFDCDCDDFFFBFCFEFFF2F8FFFFF0F7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007A7A7AF4686868FF222222FF232323FF323232FF6363
        63FFB3B3B3FFF0F0F0FFF4F4F4FFF7F7F7FFF1F1F1FFF4F4F4FFF0F0F0FFAEAE
        AEFF595959FF434343FF6B6B6BFFDCDCDCFFFCFCFCFFF9F9F9FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009D6A9095B78D9BFFE3C9ABFFE5CDACFFE8CFAFFFEED3
        B4FFA06F8FFFDEEFFAFFDEEFFAFFE9F4FDFFF3F9FEFFE0F0FAFFE7F3FCFFE9F0
        F8FFDFE6EDFFD4DFE7FFD2E1EAFFF5F9FBFFF5FAFFFFF0F7FFFFF0F7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF007B7B7B95959595FFC2C2C2FFC5C5C5FFC8C8C8FFCCCC
        CCFF7E7E7EFFF0F0F0FFF0F0F0FFF5F5F5FFF9F9F9FFF1F1F1FFF4F4F4FFF1F1
        F1FFE7E7E7FFE0E0E0FFE1E1E1FFF9F9F9FFFAFAFAFFF8F8F8FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00B791A505A06B8CAEB98F9DFFF7DBBAFFF9DEBBFFF9DE
        BBFF9F6C8DFFDEEFFAFFDEEFFAFFEFF7FCFFFBFDFEFFEFF6FEFFE0F0FAFFE7F3
        FCFFF0F7FFFFF0F7FFFFE7F3FCFFE2F1FAFFE3F2FBFFEFF7FFFFF0F7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF009B9B9B057A7A7AAE979797FFD4D4D4FFD6D6D6FFD6D6
        D6FF7B7B7BFFF0F0F0FFF0F0F0FFF7F7F7FFFDFDFDFFF7F7F7FFF1F1F1FFF4F4
        F4FFF8F8F8FFF8F8F8FFF4F4F4FFF1F1F1FFF2F2F2FFF8F8F8FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00B98E9F05A06B8CAEB98F9DFFF7DBBAFFF9DE
        BBFF9F6C8DFFDEEFFAFFDEEFFAFFDEEFFAFFE2F1FAFFE7F3FCFFEDF6FEFFE0F0
        FAFFE7F3FCFFF0F7FFFFF0F7FFFFE7F3FCFFDEEFFAFFE3F2FBFFEFF7FFFFF0F7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00979797057A7A7AAE979797FFD4D4D4FFD6D6
        D6FF7B7B7BFFF0F0F0FFF0F0F0FFF0F0F0FFF1F1F1FFF4F4F4FFF7F7F7FFF1F1
        F1FFF4F4F4FFF8F8F8FFF8F8F8FFF4F4F4FFF0F0F0FFF2F2F2FFF8F8F8FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BB8E9B05A06B8CAEB98F9DFFF7DB
        BAFF9F6C8DFFDEEFFAFFDEEFFAFFDEEFFAFFDEEFFAFFDEEFFAFFE7F3FCFFEDF6
        FEFFE0F0FAFFE7F3FCFFF0F7FFFFF0F7FFFFE7F3FCFFDEEFFAFFE3F2FBFFEFF7
        FFFF9F6C8DFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00979797057A7A7AAE979797FFD4D4
        D4FF7B7B7BFFF0F0F0FFF0F0F0FFF0F0F0FFF0F0F0FFF0F0F0FFF4F4F4FFF7F7
        F7FFF1F1F1FFF4F4F4FFF8F8F8FFF8F8F8FFF4F4F4FFF0F0F0FFF2F2F2FFF8F8
        F8FF7B7B7BFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B98C9B05A06B8CAFB98F
        9DFF9F6C8DFFDEEFFAFFDEEFFAFFDEEFFAFFDEEFFAFFDEEFFAFFDEEFFAFFE7F3
        FCFFEDF6FEFFE0F0FAFFE7F3FCFFF0F7FFFFF0F7FFFFE7F3FCFFDEEFFAFFDFEA
        F5FF9F6C8DF8FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00959595057A7A7AAF9797
        97FF7B7B7BFFF0F0F0FFF0F0F0FFF0F0F0FFF0F0F0FFF0F0F0FFF0F0F0FFF4F4
        F4FFF7F7F7FFF1F1F1FFF4F4F4FFF8F8F8FFF8F8F8FFF4F4F4FFF0F0F0FFECEC
        ECFF7B7B7BF8FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B890A3059D6A
        90959F6B8CF49F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C
        8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C8DFF9F6C
        8DF8AA819E85FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009A9A9A057B7B
        7B957A7A7AF47B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B
        7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B7BFF7B7B
        7BF88E8E8E85FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
      Caption = 'asdadasdsadasdsaf'
    end
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 1136
    Top = 536
  end
end
