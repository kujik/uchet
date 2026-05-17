{
модуль общих функций для платежного календаря
}

unit uSnCalendar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBCtrlsEh, Buttons, DBGridEh, DBAxisGridsEh, GridsEh,
  ToolCtrlsEh, DBGridEhToolCtrls,
  MemTableDataEh, Db, Math, ExtCtrls,
  IniFiles, SearchPanelsEh,
  PropFilerEh, ActnList, Jpeg, uString, PngImage, DateUtils,
  uData, uForms, uNamedArr;


type TSnCalendar = record
public
  //перенос выбранных платежей на указанную дату
  function PaymentsDateChange(AIds: TVarDynArray): Boolean;
end;

var
  SnCalendar: TSnCalendar;

implementation

uses
  uMessages,
  uDBOra,
  uFrmBasicInput
  ;

function TSnCalendar.PaymentsDateChange(AIds: TVarDynArray): Boolean;
//перенос выбранных платежей на указанную дату
//перенесуны будут только те платежи, доля которых это возможно
//(не должны быть проведены, и счет должен быть доступен для редактирования пользователем
//(или право редактирования по своим категориям, или своих счетов)
//несколько платежей для одного счета по одной дате проходят и при редактировании счета и не проверяются также и здесь
var
  na: TNamedArr;
  va: TVarDynArray;
  i, cnt: Integer;
  ids: string;
begin
  Result := False;
  if Length(AIds) = 0 then begin
    MyInfoMessage('Отметьте платежи, которые нужно перенести.');
    Exit;
  end;
  if Length(AIds) > 400 then begin
    MyInfoMessage('Для переноса можно выделить не более 400 платежей.');
    Exit;
  end;
  Q.QLoad('select pid, pstatus, useravail, userid, 0 as x from v_sn_calendar_payments where pid in (' + AIds.Implode(',') + ')', [], na);
  cnt := 0;
  ids := '';
  for i := 0 to na.High do begin
    if na.G(i, 'pstatus').AsInteger <> 0 then
      Continue;
    if not (User.Role(rPC_A_ChAll) or
      (User.Role(rPC_A_ChSelfCat) and S.InCommaStr(IntToStr(User.GetId), na.G(i, 'useravail').AsString)) or
      (User.Role(rPC_A_ChSelf) and (na.G(i, 'userid').AsInteger = User.GetId))) then
    Continue;
    Inc(cnt);
    S.ConcatStrP(ids, na.G(i, 'pid'), ',');
    na.SetValue(i, 'x', 1);
  end;
  if cnt = 0 then begin
    MyInfoMessage('Нельзя изменить дату ни для одного платежа.');
    Exit;
  end;
  if MyQuestionMessage(IntToStr(cnt) + ' из ' + S.GetEndingFull(na.Count, 'платеж', '', 'а', 'ей' ) + ' можно перенести.'#13#10'Продолжить?') <> mrYes then
    Exit;
  if TFrmBasicInput.ShowDialog(Application, '', [], fAdd, '~Перенести платежи', 150, 60, [[cntDEdit, 'Дата', ':']], [null], va, [['']], nil) < 0 then
    Exit;
  Q.QExecSql('update sn_calendar_payments set dt = :dt$d where id in (' + ids + ')', [va[0]]);
  Result := True;
end;

end.


