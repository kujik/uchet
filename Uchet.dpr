program Uchet;

{$MINSTACKSIZE 2097152} // Минимальный стек = 2 МБ
(*{$MAXSTACKSIZE 2097152} // Максимальный стек = 2 МБ*)

{
git:
https://github.com/kujik/uchet.git
kujik/psv116@ 1. - k .. s - g

madwexcept:
в настройках ставить галку включения.
загрузить иконку для кнопки печать query1_16.bmp

иконка:
в uchet.dproj удалить строку mainicon, перезапустить дельфи

cnpack:
в информации о версии - установть сохранение даты сборки и автоинкремент веорсии при компиляции

}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  EhLibVclMTE,
  Forms,
  Windows,
  SysUtils,
  uDBParsec in 'uDBParsec.pas' {myDBParsec: TDataModule},
  uMessages in 'uMessages.pas',
  uFields in 'uFields.pas',
  uLabelColors in 'uLabelColors.pas',
  uLabelColors2 in 'uLabelColors2.pas',
  uData in 'uData.pas' {MyData: TDataModule},
  uDB in 'uDB.pas' {myDB: TDataModule},
  uDBOra in 'uDBOra.pas' {myDBOra: TDataModule},
  uModule in 'uModule.pas',
  uUser in 'uUser.pas',
  uSettings in 'uSettings.pas',
  uPrintReport in 'uPrintReport.pas' {PrintReport: TDataModule},
  uSys in 'uSys.pas',
  uOrders in 'uOrders.pas',
  uWindows in 'uWindows.pas' {Dlg_DelayedInProd},
  uStringCalculator in 'uStringCalculator.pas',
  uErrors in 'uErrors.pas',
  uUtils in 'uUtils.pas',
  uTasks in 'uTasks.pas',
  uTurv in 'uTurv.pas',
  uString in 'uString.pas',
  uExcel2 in 'uExcel2.pas',
  uExcel in 'uExcel.pas',
  uForms in 'uForms.pas',
  uMailingInterface in 'uMailingInterface.pas',
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  V_MDI in 'V_MDI.pas' {Form_MDI},
  V_Normal in 'V_Normal.pas' {Form_Normal},
  uFrmXWAbout in 'uFrmXWAbout.pas' {FrmXWAbout},
  D_ExpenseItems in 'D_ExpenseItems.pas' {Dlg_ExpenseItems},
  uFrmXDmsgNoConnection in 'uFrmXDmsgNoConnection.pas' {Dlg_D_SQLNoConnection},
  D_Sn_Calendar in 'D_Sn_Calendar.pas' {Dlg_Sn_Calendar},
  uFrmXDsrvAuth in 'uFrmXDsrvAuth.pas' {FrmXDsrvAuth},
  uFrmTest in 'uFrmTest.pas' {FrmTest},
  D_SnOrder in 'D_SnOrder.pas' {Dlg_SnOrder},
  uFrmXWNoConnectionAfterStart in 'uFrmXWNoConnectionAfterStart.pas' {FrmXWNoConnectionAfterStart},
  D_SetPassword in 'D_SetPassword.pas' {Dlg_SetPassword},
  D_MainSettings in 'D_MainSettings.pas' {Dlg_MainSettings},
  D_ModuleSettings in 'D_ModuleSettings.pas' {Dlg_ModuleSettings},
  D_Rep_Smeta in 'D_Rep_Smeta.pas' {Dlg_Rep_Smeta},
  uFrmXDmsgIncorrectDate in 'uFrmXDmsgIncorrectDate.pas' {FrmXDmsgIncorrectDate},
  D_Otk in 'D_Otk.pas' {Dlg_Otk},
  D_Order in 'D_Order.pas' {Dlg_Order},
  D_Order_Complaints in 'D_Order_Complaints.pas' {Dlg_Order_Complaints: TCustomDropDownFormEh},
  D_LoadKB in 'D_LoadKB.pas' {dlg_LoadKB},
  D_LoadKBLog in 'D_LoadKBLog.pas' {Dlg_LoadKBLog},
  D_OrderPrintLabels in 'D_OrderPrintLabels.pas' {Dlg_OrderPrintLabels},
  D_Order_Stages1 in 'D_Order_Stages1.pas' {Dlg_Order_Stages1},
  D_R_Order_Plans in 'D_R_Order_Plans.pas' {Dlg_R_Order_Plans},
  D_ItmInfo in 'D_ItmInfo.pas' {Dlg_ItmInfo},
  D_DelayedInProd in 'D_DelayedInProd.pas' {Dlg_DelayedInProd},
  D_Order_Stages_Otk2 in 'D_Order_Stages_Otk2.pas' {Dlg_Order_Stages_Otk2},
  D_J_Montage in 'D_J_Montage.pas' {Dlg_J_Montage},
  F_TestTree in 'F_TestTree.pas' {Form_TestTree},
  D_Order_UPD in 'D_Order_UPD.pas' {Dlg_Order_UPD},
  D_R_EstimateReplace in 'D_R_EstimateReplace.pas' {Dlg_R_EstimateReplace},
  F_MdiDialogTemplate in 'F_MdiDialogTemplate.pas' {Form_MdiDialogTemplate},
  F_Adm_Installer in 'F_Adm_Installer.pas' {Form_Adm_Installer},
  D_J_Error_Log in 'D_J_Error_Log.pas' {Dlg_J_Error_Log},
  D_R_OrStdItems in 'D_R_OrStdItems.pas' {Dlg_R_OrStdItems},
  F_MdiGridDialogTemplate in 'F_MdiGridDialogTemplate.pas' {Form_MdiGridDialogTemplate},
  D_NewEstimateInput in 'D_NewEstimateInput.pas' {Dlg_NewEstimateInput},
  D_SuppliersMinPart in 'D_SuppliersMinPart.pas' {Dlg_SuppliersMinPart},
  D_Spl_InfoGrid in 'D_Spl_InfoGrid.pas' {Dlg_Spl_InfoGrid},
  uFrmTestDropDownEh in 'uFrmTestDropDownEh.pas' {FrmTestDropDownEh: TCustomDropDownFormEh},
  uFrDBGridEh in 'uFrDBGridEh.pas' {FrDBGridEh: TFrame},
  uFrmXWGridAdminOptions in 'uFrmXWGridAdminOptions.pas' {FrmXWGridAdminOptions},
  uFrmTestMdi1 in 'uFrmTestMdi1.pas' {FrmTestMdi1},
  uFrmDlgRItmSupplier in 'uFrmDlgRItmSupplier.pas' {FrmDlgRItmSupplier},
  uFrmBasicInput in 'uFrmBasicInput.pas' {FrmBasicInput},
  uFrmOWInvoiceToSgp in 'uFrmOWInvoiceToSgp.pas' {FrmOWInvoiceToSgp},
  uFrmODedtNomenclFiles in 'uFrmODedtNomenclFiles.pas' {FrmDlgDrawingAddAndView},
  uFrmOWPlannedOrder in 'uFrmOWPlannedOrder.pas' {FrmOWPlannedOrder},
  uFrmXWGridOptions in 'uFrmXWGridOptions.pas' {FrmXWGridOptions},
  uFrmXDedtGridFilter in 'uFrmXDedtGridFilter.pas' {FrmXDedtGridFilter},
  uFrmOGjrnOrders in 'uFrmOGjrnOrders.pas' {FrmOGjrnOrders},
  uFrmDlgEditNomenclatura in 'uFrmDlgEditNomenclatura.pas' {FrmDlgEditNomenclatura},
  uFrmBasicMdi in 'uFrmBasicMdi.pas' {FrmBasicMdi},
  uFrmOGjrnSemiproducts in 'uFrmOGjrnSemiproducts.pas' {FrmOGjrnSemiproducts},
  uFrmODedtTasks in 'uFrmODedtTasks.pas' {FrmODedtTasks},
  uFrmAWUsersAndRoles in 'uFrmAWUsersAndRoles.pas' {FrmAWUsersAndRoles},
  uFrmBasicDbDialog in 'uFrmBasicDbDialog.pas' {FrmBasicDbDialog},
  uFrmOGedtSnMain in 'uFrmOGedtSnMain.pas' {FrmOGedtSnMain},
  uFrmCGrepPaymentsByMonth in 'uFrmCGrepPaymentsByMonth.pas' {FrmCGrepPaymentsByMonth},
  uFrmCWCash in 'uFrmCWCash.pas' {FrmCWCash},
  uFrmCDedtCashRevision in 'uFrmCDedtCashRevision.pas' {FrmCDedtCashRevision},
  uFrmAWOracleSessions in 'uFrmAWOracleSessions.pas' {FrmAWOracleSessions},
  uFrmCWAcoountBasis in 'uFrmCWAcoountBasis.pas' {FrmCWAcoountBasis},
  uFrmOGedtOrderStageTimes in 'uFrmOGedtOrderStageTimes.pas' {FrmOGedtOrderStageTimes},
  uFrmWGjrnParsec in 'uFrmWGjrnParsec.pas' {FrmWGjrnParsec},
  uFrmOGjrnUchetLog in 'uFrmOGjrnUchetLog.pas' {FrmOGjrnUchetLog},
  uFrmOGrefOrStdItems in 'uFrmOGrefOrStdItems.pas' {FrmOGrefOrStdItems},
  uFrmOGrepSgp in 'uFrmOGrepSgp.pas' {FrmOGrepSgp},
  uFrmWGrepSalary in 'uFrmWGrepSalary.pas' {FrmWGrepSalary},
  uFrmOGjrnOrderStages in 'uFrmOGjrnOrderStages.pas' {FrmOGjrnOrderStages},
  uFrmOGrepItemsInOrder in 'uFrmOGrepItemsInOrder.pas' {FrmOGrepItemsInOrder},
  uFrmODrepFinByOrders in 'uFrmODrepFinByOrders.pas' {FrmODrepFinByOrders},
  uFrmODedtOrStdItems in 'uFrmODedtOrStdItems.pas' {FrmODedtOrStdItems},
  uFrmOGedtSnByAreas in 'uFrmOGedtSnByAreas.pas' {FrmOGedtSnByAreas},
  uFrmBasicGrid2 in 'uFrmBasicGrid2.pas' {FrmBasicGrid2},
  uFrmOGlstEstimate in 'uFrmOGlstEstimate.pas' {FrmOGlstEstimate},
  uFrmXGlstMain in 'uFrmXGlstMain.pas' {FrmXGlstMain},
  uFrmXDedtMemo in 'uFrmXDedtMemo.pas' {FrmXDedtMemo},
  uFrmADedtItmCopyRigths in 'uFrmADedtItmCopyRigths.pas' {FrmADedtItmCopyRigths},
  uFrmOGinfSgp in 'uFrmOGinfSgp.pas' {FrmOGinfSgp},
  uFrmBasicEditabelGrid in 'uFrmBasicEditabelGrid.pas' {FrmBasicEditabelGrid},
  uFrmOWOrder in 'uFrmOWOrder.pas' {FrmOWOrder},
  uFrmOGedtSgpRevision in 'uFrmOGedtSgpRevision.pas' {FrmOGedtSgpRevision},
  uFrmXGsrvSqlMonitor in 'uFrmXGsrvSqlMonitor.pas' {FrmXGsrvSqlMonitor},
  uFrmXWOracleError in 'uFrmXWOracleError.pas' {FrmXWOracleError},
  uFrmOGedtEstimate in 'uFrmOGedtEstimate.pas' {FrmOGedtEstimate},
  uFrmXWndUserInterface in 'uFrmXWndUserInterface.pas' {FrmXWndUserInterface},
  uFrmODedtDevel in 'uFrmODedtDevel.pas' {FrmODedtDevel},
  uFrmODedtItmUnits in 'uFrmODedtItmUnits.pas' {FrmODedtItmUnits},
  uFrmODedtSplCategoryes in 'uFrmODedtSplCategoryes.pas' {FrmODedtSplCategoryes},
  uFrmOWSearchInEstimates in 'uFrmOWSearchInEstimates.pas' {FrmOWSearchInEstimates},
  uFrmOWrepItmInfo in 'uFrmOWrepItmInfo.pas' {FrmOWrepItmInfo},
  uFrmOWrepOrdersPrimeCost in 'uFrmOWrepOrdersPrimeCost.pas' {FrmOWrepOrdersPrimeCost},
  D_Grid1 in 'D_Grid1.pas' {Dlg_Grid1},
  D_Vacancy in 'D_Vacancy.pas' {Dlg_Vacancy},
  D_Candidate in 'D_Candidate.pas' {Dlg_Candidate},
  D_CandidatesFromWorkerStatus in 'D_CandidatesFromWorkerStatus.pas' {Dlg_CandidatesFromWorkerStatus},
  uFrmWDedtDivision in 'uFrmWDedtDivision.pas' {FrmWDedtDivision},
  uFrmWDAddTurv in 'uFrmWDAddTurv.pas' {FrmWDAddTurv},
  uFrmWDedtWorkerStatus in 'uFrmWDedtWorkerStatus.pas' {FrmWDedtWorkerStatus},
  uFrmXDedtMailingCustomAddr in 'uFrmXDedtMailingCustomAddr.pas' {FrmXDedtMailingCustomAddr},
  uFrmXGsesUsersChoice in 'uFrmXGsesUsersChoice.pas' {FrmXGsesUsersChoice},
  uFrmWGEdtTurv in 'uFrmWGEdtTurv.pas' {FrmWGEdtTurv},
  uFrmWWsrvTurvComment in 'uFrmWWsrvTurvComment.pas' {FrmWWsrvTurvComment},
  uFrmWGedtPayroll in 'uFrmWGedtPayroll.pas' {FrmWGedtPayroll},
  uFrmWDedtCreatePayroll in 'uFrmWDedtCreatePayroll.pas' {FrmWDedtCreatePayroll},
  uFrmTest2 in 'uFrmTest2.pas' {FrmTest2},
  uFrmWGrepPersonal1 in 'uFrmWGrepPersonal1.pas' {FrmWGrepPersonal1},
  uFrmWGrepStaffSchedule in 'uFrmWGrepStaffSchedule.pas' {FrmWGrepStaffSchedule},
  uFrmAGlstDomainUsers in 'uFrmAGlstDomainUsers.pas' {FrmAGlstDomainUsers},
  uFrmAGLstLdapUsers in 'uFrmAGLstLdapUsers.pas' {FrmAGLstLdapUsers},
  uFrmOGrepSnHistory in 'uFrmOGrepSnHistory.pas' {FrmOGrepSnHistory},
  uFrmCDedtAccount in 'uFrmCDedtAccount.pas' {FrmCDedtAccount},
  uFrMyPanelCaption in 'uFrMyPanelCaption.pas' {FrMyPanelCaption: TFrame},
  uFrmOWedtOrReglament in 'uFrmOWedtOrReglament.pas' {FrmOWedtOrReglament},
  uFrmOGrepEstimatePrices in 'uFrmOGrepEstimatePrices.pas' {FrmOGrepEstimatePrices},
  uFrmOGselOrReglament in 'uFrmOGselOrReglament.pas' {FrmOGselOrReglament},
  uFrmOGrepOrReglament in 'uFrmOGrepOrReglament.pas' {FrmOGrepOrReglament};

var
  MT: Integer;
  NamedMutex: string;
  MNum: integer;

function CheckInstance(Name: PChar): Integer;
//проверка, запущен ли экземпляр прлграммы
var
  r: integer;
  Mutex: Integer;
begin
  Mutex := CreateMutex(nil, true, Name);
  r := GetLastError();
  if (r <> 0) then
    Result := 0
  else
    Result := Mutex;
end;

//включим ресурсы
{$R Main.RES}
{$R Uchet.RES}



begin
  //посчистаем количество ключей компиляции, указывающийх тип модуля
  MNum := 0;
  //иконки в зависимости от модуля (обязательно удалить иконку (всю строку <Icon_MainIcon> !) из Uchet.dproj)
  {$IFDEF  ADMIN}
  {$R 'Icons\Uchet_Icon_0.res' 'Icons\Uchet_Icon_0.rc'}
  inc(MNum);
  {$ENDIF}
  {$IFDEF  PC}
  {$R 'Icons\Uchet_Icon_1.res' 'Icons\Uchet_Icon_1.rc'}
  inc(MNum);
  {$ENDIF}
  {$IFDEF  PICK}
  {$R 'Icons\Uchet_Icon_2.res' 'Icons\Uchet_Icon_2.rc'}
  inc(MNum);
  {$ENDIF}
  {$IFDEF  TURV}
  {$R 'Icons\Uchet_Icon_3.res' 'Icons\Uchet_Icon_3.rc'}
  inc(MNum);
  {$ENDIF}
  {$IFDEF  SRV}
  {$R 'Icons\Uchet_Icon_4.res' 'Icons\Uchet_Icon_4.rc'}
  inc(MNum);
  {$ENDIF}
  {$IFDEF  PROD}
  {$R 'Icons\Uchet_Icon_5.res' 'Icons\Uchet_Icon_5.rc'}
  inc(MNum);
  {$ENDIF}
  {$IFDEF  OR}
  {$R 'Icons\Uchet_Icon_6.res' 'Icons\Uchet_Icon_6.rc'}
  inc(MNum);
  {$ENDIF}
  //если задано 0 или больше одного ключа компиляции, указывающего тип модуля, то предуплерим и выйдем
  if MNum <> 1 then begin
    MessageBox(0, pWideChar('Неверные ключи компиляции!!!'), 'Ошибка', 0);
    Halt;
  end;

  //получим Mutex для контроля повторного запуска приложения
  {$IFDEF SRV}
  //для вырианта "Ссервер"
  //обязательно должен быть один параметр
  if ParamCount <> 1 then
    Halt;
    //получем мютекс с учетом имени модуля и параметра
  MT := CheckInstance(pChar(ModuleRecArr[cMainModule].FileNameEn + '-' + ParamStr(1)));
  {$ELSE}
  //для других модулей (не сервер)
  //получем мютекс с учетом имени модуля
  MT := CheckInstance(pChar(ModuleRecArr[cMainModule].FileNameEn + '-OneOnly'));
  {$ENDIF}
  //если не удалось создать Mutex (то есть модуль уже запущен) -
  //выдадим сообщение и завершим программу
  //(если только в каталоге программы не находится файл "dev" - это нужно для отладки
  //  if (MT=0)and not((ParamCount >= 1)and(ParamStr(1) = '/multicopy')) then begin
  if (MT = 0) and not Sys.GetDevFile then begin
    {$IFDEF SRV}
    Halt;
    {$ENDIF}
    MessageBox(0, pWideChar('Приложение "' + string(ModuleRecArr[cMainModule].Caption) + '" уже запущено'), 'Ошибка', 0);
    Halt;
  end;


  //инициализация прилдожения
  Application.Initialize;

  //создаем форму данных (разныые объекты данных программы)
  Application.CreateForm(TMyData, MyData);
  Application.CreateForm(TmyDBParsec, myDBParsec);
  //!!!!
  //создаем форму работы с отчетами fr3
  Application.CreateForm(TPrintReport, PrintReport);
  //созадем объект TModule (общие параметры и методы модуля)
  Module := TModule.Create;
  //Создаем экземпляр БД Oracle и пытаемся подключиться к БД
  Q := TmyDBOra.CreateObject(Application, 'connect', True);
  //Создаем экземпляр БД типа MsSQL для подключения Парсек
  myDBParsec := TmyDBParsec.CreateObject(Application, 'parsec', False);

  AfterProgramStart := true;

  if not TFrmXWNoConnectionAfterStart.Execute then
    Exit;
  if not TFrmXDmsgIncorrectDate.Execute then
    Exit;
  Module.Init;
  User := TUser.Create;
  PrintReport := TPrintReport.Create;
  {$IFDEF SRV}
  User.LoginAsServer;
  {$ELSE}
  TFrmXDsrvAuth.Execute;
  {$ENDIF}
  if not User.IsLogged then
    Exit;

 //   Halt;


  Application.Title := ModuleRecArr[cMainModule].Caption;
  Application.CreateForm(TFrmMain, FrmMain);

  Application.CreateForm(TForm_Normal, Form_Normal);
  Application.CreateForm(TFrmXWAbout, FrmXWAbout);
  Application.CreateForm(TFrmXDmsgNoConnection, FrmXDmsgNoConnection);
  Application.CreateForm(TDlg_SnOrder, Dlg_SnOrder);
  Application.CreateForm(TDlg_SetPassword, Dlg_SetPassword);
  Application.CreateForm(TDlg_MainSettings, Dlg_MainSettings);
  Application.CreateForm(TDlg_ModuleSettings, Dlg_ModuleSettings);
  Application.CreateForm(TDlg_Rep_Smeta, Dlg_Rep_Smeta);
  Application.CreateForm(TDlg_Otk, Dlg_Otk);
  Application.CreateForm(TDlg_Order_Complaints, Dlg_Order_Complaints);
  Application.CreateForm(TDlg_LoadKBLog, Dlg_LoadKBLog);
  Application.CreateForm(TDlg_OrderPrintLabels, Dlg_OrderPrintLabels);
  Application.CreateForm(TDlg_Order_Stages1, Dlg_Order_Stages1);
  Application.CreateForm(TDlg_R_Order_Plans, Dlg_R_Order_Plans);
  Application.CreateForm(TDlg_DelayedInProd, Dlg_DelayedInProd);
  Application.CreateForm(TDlg_Order_Stages_Otk2, Dlg_Order_Stages_Otk2);
  Application.CreateForm(TForm_TestTree, Form_TestTree);
  Application.CreateForm(TDlg_Order_UPD, Dlg_Order_UPD);
  Application.CreateForm(TDlg_R_EstimateReplace, Dlg_R_EstimateReplace);
  Application.CreateForm(TFrmTestDropDownEh, FrmTestDropDownEh);

  Application.CreateForm(TFrmCWAcoountBasis, FrmCWAcoountBasis);
  Application.CreateForm(TFrmADedtItmCopyRigths, FrmADedtItmCopyRigths);
  Application.CreateForm(TFrmXDedtMemo, FrmXDedtMemo);
  Application.CreateForm(TFrmXWOracleError, FrmXWOracleError);
  Application.CreateForm(TFrmXDedtMailingCustomAddr, FrmXDedtMailingCustomAddr);
  Application.CreateForm(TFrmWWsrvTurvComment, FrmWWsrvTurvComment);

  Application.Run;

end.
{
  Application.CreateForm(TDlg_Grid1, Dlg_Grid1);
  Application.CreateForm(TDlg_CandidatesFromWorkerStatus, Dlg_CandidatesFromWorkerStatus);
}

