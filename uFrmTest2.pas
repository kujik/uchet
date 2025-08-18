unit uFrmTest2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls, uDbOra, uString, uMessages
  , uPSCompiler, uPSRuntime, uPSUtils, Vcl.Buttons
  ;

type
  TFrmTest2 = class(TFrmBasicMdi)
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
    Script: TPSExec;
    function  Prepare: Boolean; override;
    procedure AddOutput(const S: string);  public
    { Public declarations }
  end;

var
  FrmTest2: TFrmTest2;

implementation

{$R *.dfm}

procedure TFrmTest2.BitBtn1Click(Sender: TObject);
begin
 (* Script := TPSExec.Create;
  // Компиляция
  if Script.Compile(Memo1.Text) then
  begin
    // Регистрация ShowMessage
    Script.RegisterStdProc('ShowMessage', @AddOutput);

    // Выполнение
    if Script.Exec.Run then
      AddOutput('✅ Выполнено успешно')
    else
      AddOutput('❌ Ошибка выполнения: ' + Script.Exec.PSError);
  end
  else
  begin
    AddOutput('❌ Ошибка компиляции:');
    AddOutput(Script.Compiler.Msgs.Text);
  end;*)
end;

function  TFrmTest2.Prepare: Boolean;
begin
  Result := True;
end;

procedure TFrmTest2.AddOutput(const S: string);
begin
  MyInfoMessage(S);
end;

function ScriptOnUses(Sender: TPSPascalCompiler; const Name: AnsiString): Boolean;
{ the OnUses callback function is called for each "uses" in the script.
  It's always called with the parameter 'SYSTEM' at the top of the script.
  For example: uses ii1, ii2;
  This will call this function 3 times. First with 'SYSTEM' then 'II1' and then 'II2'.
}
begin
  if Name = 'SYSTEM' then
  begin
    Result := True;
  end else
    Result := False;
end;

procedure ExecuteScript(const Script: string);
var
  Compiler: TPSPascalCompiler;
  { TPSPascalCompiler is the compiler part of the scriptengine. This will
    translate a Pascal script into a compiled form the executer understands. }
  Exec: TPSExec;
   { TPSExec is the executer part of the scriptengine. It uses the output of
    the compiler to run a script. }
  Data: AnsiString;
begin
  Compiler := TPSPascalCompiler.Create; // create an instance of the compiler.
  Compiler.OnUses := ScriptOnUses; // assign the OnUses event.
  if not Compiler.Compile(Script) then  // Compile the Pascal script into bytecode.
  begin
    Compiler.Free;
     // You could raise an exception here.
    Exit;
  end;

  Compiler.GetOutput(Data); // Save the output of the compiler in the string Data.
  Compiler.Free; // After compiling the script, there is no need for the compiler anymore.

  Exec := TPSExec.Create;  // Create an instance of the executer.
  if not  Exec.LoadData(Data) then // Load the data from the Data string.
  begin
    { For some reason the script could not be loaded. This is usually the case when a
      library that has been used at compile time isn't registered at runtime. }
    Exec.Free;
     // You could raise an exception here.
    Exit;
  end;

  Exec.RunScript; // Run the script.
  Exec.Free; // Free the executer.
end;

const
  Script = 'var s: string; begin s := ''Test''; S := s + ''ing;''; end.';


var
  v : variant;
  i: integer;
  st: string;
begin
  ExecuteScript(Script); exit;
//  i := q.QSelectOneRow('select 2 from dual', [])[0].tointeger;
  st :=     'var x, y, result: Integer;' + #13#10 +
    'begin' + #13#10 +
    '  x := 5;' + #13#10 +
    '  y := 10;' + #13#10 +
    '  result := x * y + 20;' + #13#10 +
    '  ShowMessage(''Результат: '' + IntToStr(result));' + #13#10 +
    'end.';
end.
