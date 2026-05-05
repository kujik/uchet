unit uADUpdater;

interface

uses
  System.SysUtils, System.Variants, System.Win.ComObj, Winapi.ActiveX, Web.Win.ADsTypes, ActiveDs_TLB;


function UpdateADAttributes(const ADsPath, AdminUser, AdminPassword: string; const AttrNames: array of string; const AttrValues: array of Variant): Boolean;

implementation


function UpdateADAttributes(const ADsPath, AdminUser, AdminPassword: string;
  const AttrNames: array of string; const AttrValues: array of Variant): Boolean;
var
  UserObj: IADsUser;
  HRes: HRESULT;
  i: Integer;
  vValue: Variant;
begin
  Result := False;
  if Length(AttrNames) <> Length(AttrValues) then
    raise Exception.Create('Количество имён атрибутов и значений не совпадает');

  // Инициализация COM для текущего потока (обязательно!)
  CoInitialize(nil);
  try
    // Подключаемся к объекту пользователя с явной аутентификацией
    HRes := ADsOpenObject(
      PWideChar(ADsPath),
      PWideChar(AdminUser),
      PWideChar(AdminPassword),
      ADS_SECURE_AUTHENTICATION,
      IADsUser,
      UserObj
    );

    if HRes <> S_OK then
      raise Exception.CreateFmt('Не удалось подключиться к объекту: %s. Ошибка: 0x%.8x', [ADsPath, HRes]);

    // Загружаем текущие значения в кэш
    UserObj.GetInfo;

    // Применяем изменения
    for i := Low(AttrNames) to High(AttrNames) do
    begin
      vValue := AttrValues[i];

      // Пустая строка или Null — удаляем атрибут
      if VarIsNull(vValue) or (VarIsStr(vValue) and (Trim(VarToStr(vValue)) = '')) then
        UserObj.PutEx(ADS_PROPERTY_CLEAR, AttrNames[i], Unassigned)
      else
        UserObj.Put(AttrNames[i], vValue);
    end;

    // Сохраняем изменения на сервере
    UserObj.SetInfo;
    Result := True;
  finally
    CoUninitialize;
  end;
end;

end.

