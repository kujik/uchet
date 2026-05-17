inherited FrmXDinputPwd: TFrmXDinputPwd
  Caption = 'FrmXDinputPwd'
  ExplicitWidth = 278
  ExplicitHeight = 135
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    inherited pnlFrmClient: TPanel
      object edtPwd: TDBEditEh
        Left = 4
        Top = 8
        Width = 248
        Height = 21
        DynProps = <>
        EditButtons = <>
        PasswordChar = '*'
        TabOrder = 0
        Text = 'edtPwd'
        Visible = True
        OnKeyPress = edtPwdKeyPress
      end
    end
  end
  inherited pnlStatusBar: TPanel
    inherited lblStatusBarR: TLabel
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
