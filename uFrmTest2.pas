unit uFrmTest2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls, uString, uMessages,
  uPSCompiler, uPSRuntime, Vcl.Buttons, uNamedArr
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

procedure TestProcedure1;
procedure TestProcedure2;
procedure TestProcedure3;


implementation

uses
  uFrmMain,
  uForms,
  uDB,
  uDBOra,
  uWindows,
  uData,
  uTurv,
  uExcel,
  ZLib,
  uWaitForm,
  uTasks,
  uOrders,
  uExportToXlsx,
  uServerTasks,
  uFrmChooseDialog,
  uFrmOWItmInfo,
  uSys,
  uErrors,
  uFrmCWAcoountBasis,
  uFrmOWedtProdCalculation,
  uFrmXDedtMemo,
  idmessage,
  uFrmXWAbout,
  uFrmTestMdi1,
  uFrmBasicInput,
  uFrmOGedtSnMain,
  uFrmCDedtCashRevision,
  uFrmBasicEditabelGrid,
  uFrmOWOrder,
  uFrmOGedtEstimate,
  uFrmCDedtAccount,
  uFrmWWedtWorkSchedule,
  uFrmXDinputPwd
  ;

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
  ResultVar: PIFVariant;
  v : variant;
begin
  Compiler := TPSPascalCompiler.Create; // create an instance of the compiler.
  Compiler.OnUses := ScriptOnUses; // assign the OnUses event.
  if not Compiler.Compile(Script) then  // Compile the Pascal script into bytecode.
  begin
    Compiler.Free;
     // You could raise an exception here.
    //showmessage(Compiler.CompilerErrorToStr(0));
    Exit;
  end;

  Compiler.GetOutput(Data); // Save the output of the compiler in the string Data.
  //Compiler.AddUsedVariableN('s', 'Longint');
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
//  VGetInt(Compiler.GetVariable('MYVAR')).
  v:=Exec.GetVar('s');
  ResultVar:=Exec.GetVar2('s');
  Exec.Free; // Free the executer.
end;
(*
procedure pppp;
var
  Script: TPSExec;
  ResultVar: PIFVariant;
  Value: Integer;
begin
  Script := TPSExec.Create(nil);
  try
    Script.Text :=
      'var ResultValue: Integer; begin ResultValue := 100 + 50; end.';

    if Script.Compile and Script.Exec.Run then
    begin
      // Получаем переменную ResultValue
      ResultVar := Script.GetVar2('ResultValue');
      if Assigned(ResultVar) then
      begin
        Value := @ResultVar.Data.ToInteger;
        ShowMessage('Результат: ' + IntToStr(Value)); // 150
      end;
    end;
  finally
    Script.Free;
  end;
end;

*)

(*
procedure pppp;
var
  Messages: string;
  compiled: boolean;
  ce: TPSScript;
begin
  ce.Script.Text := 'begin end.';
  Compiled := Ce.Compile;
  for i := 0 to ce.CompilerMessageCount -1 do
    Messages := Messages +
                ce.CompilerMessages[i].MessageToString +
                #13#10;
  if Compiled then
    Messages := Messages + 'Succesfully compiled'#13#10;
  ShowMessage('Compiled Script: '#13#10+Messages);
  if Compiled then begin
    if Ce.Execute then
      ShowMessage('Succesfully Executed')
    else
      ShowMessage('Error while executing script: '+
                  Ce.ExecErrorToString);
  end;
end;
*)

const
//  Script = 'var s: string; begin s := ''Test''; S := s + ''ing;''; end.';
  Script = 'var s: integer; begin s := 5 + 10; end.';

  (*

procedure QQQQQ;
var
  MyA, MyB: Integer;
  MyName: string;
  Exec: TPSExec;
begin
  MyA := 5;
  MyB := 7;
  MyName := 'Иван';

  //Label1.Caption := Format('До: A=%d, B=%d, Name=%s', [MyA, MyB, MyName]);

  // Создаём выполнитель
  Exec := TPSExec.Create;
  try
    // Компилируем скрипт
    if Exec.Compile(Script := Memo1.Text) then
    begin
      // Передаём переменные в скрипт
      Exec.RegisterVar('A', 'Integer', @MyA);
      Exec.Exec.RegisterVar('B', 'Integer', @MyB);
      Exec.Exec.RegisterVar('Name', 'String', @MyName);

      // Выполняем
      if Exec.Exec.Run then
      begin
        // После выполнения значения изменены!
        Label2.Caption := Format('После: A=%d, B=%d, Name=%s', [MyA, MyB, MyName]);
        ShowMessage('Скрипт выполнен успешно!');
      end
      else
      begin
        ShowMessage('Ошибка выполнения: ' + Exec.Exec.ErrorMsg);
      end;
    end
    else
    begin
      ShowMessage('Ошибка компиляции: ' + Exec.Comp.Errors.Text);
    end;
  finally
    Exec.Free;
  end;
end;

*)

//==============================================================================
//==============================================================================
//==============================================================================


procedure TestProcedure1;
begin

end;

procedure TestProcedure2;
var
  res: TFrmXWAbout;
  va: TVarDynArray;
//  Form: TFrmMDI;
  i: Integer;
  st: string;
begin
TasksS.ReportForPlannedShipments; Exit;
TasksS.ReportForSuppliersNegativeDemand; Exit;

TasksS.ReportForNegativeQuantityOnSgp;
TasksS.ReportForOrdersPlannedToStartTomorrow;
TasksS.ReportForRequiredMaterialsForPlannedOrdersTomorrow;
Exit;

TasksS.ReportForEstimatesOverdue(1);TasksS.ReportForEstimatesOverdue(2);Exit;
TasksS.ReportForOverdueOrdersByStartTpoProductionDate; Exit;
TasksS.ReportForOverdueOrders(False);TasksS.ReportForOverdueOrders(True);Exit;
FrmXDinputPwd.ShowDialogP(APPlication);

exit;
//TFrmOWOrder.Show(Application, myfrm_Dlg_UsersAndRoles, [myfoSizeable, myfoDialog, myfoEnableMaximize], fNone, null, null); exit;
//TasksS.ReportForActsWriteoffReceipt; exit;
//TasksS.ReportForSupplyisOnwaySurplus; exit;
//TasksS.ReportForYesterdayOrders(5);
//TasksS.ReportForYesterdayOrders(6);
TasksS.ReportForYesterdayOrders(1);
TasksS.ReportForYesterdayOrders(3);
Exit;
//TasksS.ReportForYesterdayOrders(False);Exit;
TasksS.ReportForEarlyCompletionActs;Exit;
va:=[1,2];
va.Add(2);
va.Add(3);
Exit;
  Wh.ExecReference(myfrm_R_Itm_Nomencl_SEL, nil, [myfoDialog,  myfoSizeable], null);
Exit;
//  q.QExecSql('select 1 from www', [1]); exit;

  TFrmOWOrder.Show(Application, myfrm_Dlg_UsersAndRoles, [myfoSizeable, myfoDialog, myfoEnableMaximize], fNone, null, null); exit;

  Exit;
  //Wh.ExecReference(myfrm_Rep_PlannedMaterials); Exit;
//  TFrmGridRef.Show(Self, 'myfrm_R_StdProjects_1', [myfoSizeable], fNone, 10, null); exit;
  TFrmTestMdi1.Show(Application, '123456789', [], fNone, 0, null); exit;
//TfrmDlgRItmSupplier.Create(Self, 'dddddddd', [myfoMultiCopy, myfoDialog, myfoSizeable, myfoModal], fView, 5753, null);   //id 5753
//i:=TFrmDlgRItmSupplier.ShowModal(Self, 'dddddddd', [myfoMultiCopy, myfoDialog{, myfoSizeable}, myfoModal], fView, 5753, '444444444');   //id 5753
//i:=TFrmDlgRItmSupplier.Show(Self, 'dddddddd', [myfoMultiCopy, myfoDialog, myfoSizeable], fView, 5753, null);   //id 5753
//i:=FrmMDI.width;
//st:=TFrmDlgRItmSupplier(FrmMdi).BitBtn1.Caption;
//TFrmDlgRItmSupplier(FrmMdi).btnOk.free;
//st:=TFrmDlgRItmSupplier(FrmMdi).btnOk.Caption;
//st:=TFrmDlgRItmSupplier(FrmMdi).BitBtn1.Caption;
//TFrmDlgRItmSupplier(FrmMdi).btnOk.OnClick(nil);
//st:=TFrmDlgRItmSupplier(FrmMdi).dbediteh1.Text;
//st:=TFrmDlgRItmSupplier(FrmMdi).edt_name_org.text;
exit;

//  TFrmDlgFindNameInEstimates.Show(Self, 'ddd', [myfoSizeable], fNone, null, null);  exit;

//  TFrmAWUsersAndRoles.Show(Self, 'dddddddd', [myfoSizeable], fNone, null, null);
//  Form:= TFrmMDI.Create(Application, 'sdfsdfgdsfgd', [], fNone, 0, null);
exit;

  Wh.ExecReference(myfrm_R_MinRemainsI);
  Exit;
  //старый диалог ввода сметы удален (D_NewEstimateInput), см. TFrmOGedtEstimate






//TForm_References.Create(Self, myfrm_R_DelayedInprodReasons, [myfoEnableMaximize, myfoMultiCopy, myfoSizeable], fNone, 0, null);
//  res := TFrmXWAbout.Create(Self, False);
//  res.ShowModal;
end;

procedure TestProcedure3;
var
//  res: TFrmXWAbout;
  res: TForm;
  i: Integer;
  st: string;
  va2: tvardynarray2;
  v: TVarDynArray;
  na: TNamedArr;
  //===== ТЕСТ СКОРОСТИ ADO/FD НА ЗАГРУЗКЕ В МАССИВ (см. !алгоритмы.txt, раздел 6.7) =====
  //отдельный экземпляр TmyDBOra - чтобы не трогать состояние (соединение/транзакции) "боевого" Q
  TestQ: TmyDBOra;
  TestVolumes: array of Integer;
  TestReport: string;

  procedure RunVolumeTest(ABackend: TmyDbBackend; const ABackendName: string);
  //прогоняет QLoadToRec с ограничением rownum <= N для каждого объема из TestVolumes на бэкенде
  //ABackend, дописывает время (мс) и число полученных строк в TestReport
  var
    vi, RowLimit: Integer;
    StartTick, ElapsedMs: UInt64;
    Rec: TNamedArr;
    TestSql: string;
  begin
    //ВАЖНО: подставьте сюда реальный текст SELECT "большой таблицы" (тот же, что уходит в
    //FFdPendingSelectSql / ADODataDriverEh1.SelectSQL для экрана "большая таблица"/OGlstSnMain) -
    //в этой сессии текст этого запроса недоступен (модуль экрана не выгружался). Внешний
    //"select * from (...) where rownum <= :n" позволяет ограничить объем без переписывания
    //самого запроса - ORDER BY внутри подзапроса лучше убрать/не важен для замера чистой выборки.
    TestSql := 'select * from v_spl_minremains where rownum <= :n$i';
    TestQ.Backend := ABackend;
    //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, 6.8): "прогревочный" запрос ДО замера - у FireDAC
    //FdConnection создаётся и подключается лениво при первом реальном обращении (см.
    //TmyDB.GetFdConnection), а у ADO соединение уже открыто заранее в CreateObject; без прогрева
    //время установления FireDAC-подключения попадало бы в замер первого (самого маленького) объема
    //и искажало бы сравнение - поэтому засекаем и показываем его отдельной строкой.
    StartTick := GetTickCount64;
    TestQ.QLoadValue('select 1 from dual', []);
    ElapsedMs := GetTickCount64 - StartTick;
    TestReport := TestReport + '--- ' + ABackendName + ' (прогрев/установление соединения: ' + IntToStr(ElapsedMs) + ' мс) ---' + sLineBreak;
    for vi := 0 to High(TestVolumes) do begin
      RowLimit := TestVolumes[vi];
      StartTick := GetTickCount64;
      Rec := TestQ.QLoadToRec(TestSql, [RowLimit]);
      ElapsedMs := GetTickCount64 - StartTick;
      TestReport := TestReport + Format('  rownum <= %d: %d мс, получено строк: %d', [RowLimit, ElapsedMs, Length(Rec.V)]) + sLineBreak;
    end;
  end;

begin
  //===== ТЕСТ СКОРОСТИ ADO/FD НА ЗАГРУЗКЕ В МАССИВ (см. !алгоритмы.txt, раздел 6.7) =====
  TestVolumes := [100, 1000, 5000, 20000, 100000];
  TestReport := '';
  TestQ := TmyDBOra.CreateObject(Application, 'connect', True);
  try
    RunVolumeTest(mydbbAdo, 'ADO');
    RunVolumeTest(mydbbFireDac, 'FireDAC');
  finally
    TestQ.Free;
  end;
  MyInfoMessage(TestReport, 1);
  Exit;

  Wh.ExecReference(myfrm_Dlg_MainSettings);exit;
  Orders.ConvertOrders2026;  Exit;

  va2 := Q.QLoad('select id, format_name,slash,name,qnt_psp_sell,qnt_psp_prod,qnt_sgp_registered,qnt_shipped,qnt,qnt_in_prod,qnt_to_shipped,qnt_min,qnt_need,price,summ,priceraw,sumraw from v_sgp_items where id_format_est  = :id_format_est$i', [26]);
  Exit;


var ln := Cth.GetTextWidth('sdfsdfsd', frmmain.Font);
  FrmChooseDialog.ShowDialog('Test', 'отступы между кнопками и по веритикали и по горизонтали для панелей из TSpeedButton', ['выбор 1', 'самый-самый правильный выбора','1','1','1','1','1'], [['ququ']]); exit;
//FrmExportToXlsx.RunExport;Exit;
  Wh.ExecReference(myfrm_Dlg_MainSettings);exit;

  Q.QLoad('SELECT /*+ PARALLEL(4) */ * FROM v_orders', [], na);
  myinfomessage('!!!');
  exit;

//Exit;
Turv.SaveAllTurvToExportTable; Exit;
//  ShowWaitForm('111111111111', nil, True, 1);
  ShowWaitForm;
  Sleep(3000);
  //i:=i div i;
  //FrmCWAcoountBasis.ShowDialog(nil, 0, fAdd, 0);
  ShowWaitForm('Привет!'#13#10'Производится очень долгая операция!');
  Sleep(3000);



  Exit;


Turv.SaveAllTurvToExportTable; Exit;

  na.Create([[1,2]]);
  na.g('3');
  Exit;


  TFrmCDEdtAccount.Show(Application, '2222212', [myfoDialog, myfoSizeable], fEdit, 38236, null); exit;
//  Exit;
//Turv.LoadDataFromParsec; Exit;
//  Tasks.SplMonitorReportDay; Exit;



  v:=Q.QLoadRow('select count(*) from adm_user_cfg', []);
  exit;


  //LoadPersonnelNumber; Exit;

    Orders.LoadEstimate(null, null, 1129); exit;

   TFrmOGedtEstimate.Show(Application, '222221', [myfoDialog, myfoSizeable], fEdit, 32098, null); exit;



  TFrmBasicEditabelGrid.Show(Application, '2222', [myfoSizeable], fNone, 0, null); exit;

  FrmXDedtMemo.ShowDialog(nil, 'AttachAggregateEstimate', 'Комментарий к общей смете', 'wqewqe', st);exit;


  Wh.ExecReference(myfrm_Rep_Salary);exit; //myfrm_J_Parsec
  TFrmOGedtSnMain.Show(FrmMain, 'dddddddd', [myfoSizeable], fNone, 1, null); exit;



  FrmCWAcoountBasis.ShowDialog(nil, 0, fAdd, 0); exit;
  TFrmCDedtCashRevision.Show(FrmMain, 'dddddddd', [], fNone, 1, null); exit;

  Wh.ExecReference(myfrm_Rep_SnCalendar_AccMontage);exit;

  q.QLoad('select id_act,id_docstate,actnum,actdate,numzakaz,zakazname,itogo,comments,zakazcostend,firm,doc_owner,doc_date from dv.v_acts', []);
  myinfomessage('!!!');exit;


  i:=i div i; Exit;
//  TFrmGMtPspCreate.Show(Self, '1234567890-3', [myfoSizeable], fNone, 10, null); exit;
TFrmBasicInput._TestFunctionDB;
//i:=FrmMDI.width;
//st:=TFrmDlgRItmSupplier(FrmMdi).Edit1.Text;
//st:=TFrmDlgRItmSupplier(FrmMdi).edt_name_org.text;
exit;

//  TFrmDlgRItmSupplier.Create(Self, 'dddddddd', [myfoMultiCopy, myfoSizeable], fAdd, null, null); exit;
//myfoMultiCopyWoID - не реализовано нигде
//myfoMultiCopy - запускает несколько копий всегда в режимах fNone, fAdd, fCopy, иначе только если нет формы с таким ID
  TFrmTestMdi1.Show(FrmMain, 'dddddddd', [myfoMultiCopy, myfoSizeable], fAdd, 1, null);
//  TFrmTestMdi1.Create(Self, 'dddddddd', [myfoMultiCopy, myfoSizeable], fNone, 2, null);
//  TFrmTestMdi1.Create(Self, 'dddddddd', [myfoMultiCopy, myfoSizeable], fEdit, 1, null);
  Exit;


//  TForm_Grid.Show(Self, 'dddddddd', [myfoSizeable], fNone, null, null);
  Exit;


Q.QBeginTrans;
q.QLoadRow('select 1, 45, sysdate from dual where id = :id$s and sysdate = :sysdate$d', [1,date]);
Q.QRollbackTrans;
exit;


end;

//==============================================================================
//==============================================================================
//==============================================================================


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









