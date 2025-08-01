//********************************************************************************
//** ����� �������
//*******************************************************************************
unit uUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  MemTableDataEh, Db, ADODB, PropFilerEh, PropStorageEh, DataDriverEh,
  ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh,
  DBCtrls, StdCtrls, Buttons, ExtCtrls, Math, AppEvnts;

//������ ������
function  CheckKeyDown(Key: Integer): Boolean;
//�����, ��������� � ��������, �������;
function  CheckKeyState(Key: Integer): Boolean;
//���������� ������ ������, ������ �������� + ����������� Step; ���� Step=0 �� ���������� ������; ���������� 0 ���� ������ ������ �� �������
function GetFontSize(Font: TFont; Step: Integer): Integer;
//������������� ������ ������, ������ �������� + ����������� Step; ���� Step=0 �� ���������� ������; ���������� ��� ���� ������ ������ �������
function SetFontSize(var Font: TFont; Step: Integer): Boolean;
//������� �������� �������� �� �������� ����� ����������, ���� �������� ��� �� ���
function GetCurrentDBGridEh: TDBGridEh;

implementation

//������������� ������ ������, ������ �������� + ����������� Step; ���� Step=0 �� ���������� ������; ���������� ��� ���� ������ ������ �������
//no use!!!
function SetFontSize(var Font: TFont; Step: Integer): Boolean;
var
  i:Integer;
begin
  Result:=False;
  i:=GetFontSize(Font, Step);
  if i > 0 then
    begin
      Font.Size:=i;
      Result:=True;
    end;
end;

//���������� ������ ������, ������ �������� + ����������� Step; ���� Step=0 �� ���������� ������; ���������� 0 ���� ������ ������ �� �������
function GetFontSize(Font: TFont; Step: Integer): Integer;
var
  i:Integer;
begin
  Result:=0;
  if Step = 0 then i:=8 else i:=Font.Size + Step;
  if i< 4 then i:=4 else if i>36 then i:=36;
  if Font.Size<>i then Result:=i;
end;


//������� �������� �������� �� �������� ����� ����������, ���� �������� ��� �� ���
function GetCurrentDBGridEh: TDBGridEh;
begin
  Result:=nil;
  try
  if Screen.ActiveForm.ActiveControl is TDbGridEh
    then Result:=TDBGridEh(Screen.ActiveForm.ActiveControl);
  except
  end;
end;

//������ ������
function  CheckKeyDown(Key: Integer): Boolean;
begin
  Result:=GetKeyState(Key) and $8000 = $8000;
end;

//�����, ��������� � ��������, �������;
function  CheckKeyState(Key: Integer): Boolean;
begin
  Result:=GetKeyState(Key) and 1 = 1;
end;
{
VK_LBUTTON	Left mouse button
VK_RBUTTON	Right mouse button
VK_CANCEL	Control+Break
VK_MBUTTON	Middle mouse button
VK_BACK	Backspace key
VK_TAB	Tab key
VK_CLEAR	Clear key
VK_RETURN	Enter key
VK_SHIFT	Shift key
VK_CONTROL	Ctrl key
VK_MENU	Alt key
VK_PAUSE	Pause key
VK_CAPITAL	Caps Lock key
VK_KANA	Used with IME
VK_HANGUL	Used with IME
VK_JUNJA	Used with IME
VK_FINAL	Used with IME
VK_HANJA	Used with IME
VK_KANJI	Used with IME
VK_CONVERT	Used with IME

VK_NONCONVERT	Used with IME
VK_ACCEPT	Used with IME
VK_MODECHANGE	Used with IME
VK_ESCAPE	Esc key
VK_SPACE	Space bar
VK_PRIOR	Page Up key
VK_NEXT	Page Down key
VK_END	End key
VK_HOME	Home key
VK_LEFT	Left Arrow key
VK_UP	Up Arrow key
VK_RIGHT	Right Arrow key
VK_DOWN	Down Arrow key
VK_SELECT	Select key
VK_PRINT	Print key (keyboard-specific)
VK_EXECUTE	Execute key
VK_SNAPSHOT	Print Screen key
VK_INSERT	Insert key
VK_DELETE	Delete key
VK_HELP	Help key

VK_LWIN	Left Windows key (Microsoft keyboard)
VK_RWIN	Right Windows key (Microsoft keyboard)
VK_APPS	Applications key (Microsoft keyboard)
VK_NUMPAD0	0 key (numeric keypad)
VK_NUMPAD1	1 key (numeric keypad)
VK_NUMPAD2	2 key (numeric keypad)
VK_NUMPAD3	3 key (numeric keypad)
VK_NUMPAD4	4 key (numeric keypad)
VK_NUMPAD5	5 key (numeric keypad)
VK_NUMPAD6	6 key (numeric keypad)
VK_NUMPAD7	7 key (numeric keypad)
VK_NUMPAD8	8 key (numeric keypad)
VK_NUMPAD9	9 key (numeric keypad)

VK_MULTIPLY	Multiply key (numeric keypad)
VK_ADD	Add key (numeric keypad)
VK_SEPARATOR	Separator key (numeric keypad)
VK_SUBTRACT	Subtract key (numeric keypad)
VK_DECIMAL	Decimal key (numeric keypad)
VK_DIVIDE	Divide key (numeric keypad)
VK_F1	F1 key
VK_F2	F2 key
VK_F3	F3 key
VK_F4	F4 key
VK_F5	F5 key
VK_F6	F6 key
VK_F7	F7 key
VK_F8	F8 key
VK_F9	F9 key
VK_F10	F10 key
VK_F11	F11 key
VK_F12	F12 key
VK_F13	F13 key
VK_F14	F14 key
VK_F15	F15 key

VK_F16	F16 key
VK_F17	F17 key
VK_F18	F18 key
VK_F19	F19 key
VK_F20	F20 key
VK_F21	F21 key
VK_F22	F22 key
VK_F23	F23 key
VK_F24	F24 key
VK_NUMLOCK	Num Lock key
VK_SCROLL	Scroll Lock key
VK_LSHIFT	Left Shift key (only used with GetAsyncKeyState and GetKeyState)
VK_RSHIFT	Right Shift key (only used with GetAsyncKeyState and GetKeyState)
VK_LCONTROL	Left Ctrl key (only used with GetAsyncKeyState and GetKeyState)
VK_RCONTROL	Right Ctrl key (only used with GetAsyncKeyState and GetKeyState)

VK_LMENU	Left Alt key (only used with GetAsyncKeyState and GetKeyState)
VK_RMENU	Right Alt key (only used with GetAsyncKeyState and GetKeyState)
VK_PROCESSKEY	Process key
VK_ATTN	Attn key
VK_CRSEL	CrSel key
VK_EXSEL	ExSel key
VK_EREOF	Erase EOF key
VK_PLAY	Play key
VK_ZOOM	Zoom key
VK_NONAME	Reserved for future use
VK_PA1	PA1 key
VK_OEM_CLEAR	Clear key}

end.
