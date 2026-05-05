unit uLdapHelper;

interface

uses
  Windows, SysUtils;

type
  TLDAPHandle = Pointer;

// Подключение к LDAP (Active Directory) с явной аутентификацией
// Server   - IP или имя контроллера домена (например '10.1.1.11' или 'dc.fresh.local')
// Username - в формате 'domain\user' или 'user@domain.local'
// Password - пароль
// Возвращает дескриптор или nil при ошибке (используйте LdapGetLastError)
function LdapConnect(const Server, Username, Password: string): TLDAPHandle;

// Отключение от LDAP
procedure LdapDisconnect(Handle: TLDAPHandle);

// Установка одного атрибута пользователя
// Handle   - дескриптор, полученный от LdapConnect
// UserDN   - Distinguished Name пользователя (например 'CN=Иванов,OU=Users,DC=fresh,DC=local')
// AttrName - имя атрибута (например 'title')
// NewValue - новое значение (пустая строка = удалить атрибут)
// Возвращает True при успехе
function LdapSetAttribute(Handle: TLDAPHandle; const UserDN, AttrName, NewValue: string): Boolean;

// Получить текст последней ошибки
function LdapGetLastError: string;

implementation

const
  LDAP_PORT = 389;
  LDAP_OPT_PROTOCOL_VERSION = $0011;
  LDAP_OPT_REFERRALS = $0008;
  LDAP_OPT_DEREF = $0002;
  DEREF_NEVER = 0;
  LDAP_MOD_REPLACE = $00000002;
  LDAP_MOD_DELETE  = $00000001;
  LDAP_SUCCESS = 0;

type
  PLDAPMod = ^TLDAPMod;
  TLDAPMod = record
    mod_op: ULONG;
    mod_type: PAnsiChar;   // имя атрибута в UTF-8
    mod_vals: record
      case Integer of
        0: (modv_strvals: PPAnsiChar);
        1: (modv_bvals: Pointer);
      end;
  end;

// Импорт Unicode-функций из wldap32.dll
function ldap_openW(HostName: PWideChar; PortNumber: ULONG): TLDAPHandle; stdcall; external 'wldap32.dll' name 'ldap_openW';
function ldap_set_option(ld: TLDAPHandle; option: Integer; optdata: Pointer): ULONG; stdcall; external 'wldap32.dll';
function ldap_bind_sW(ld: TLDAPHandle; dn: PWideChar; cred: PWideChar; method: ULONG): ULONG; stdcall; external 'wldap32.dll' name 'ldap_bind_sW';
function ldap_modify_s(ld: TLDAPHandle; dn: PAnsiChar; mods: PLDAPMod): ULONG; stdcall; external 'wldap32.dll' name 'ldap_modify_sA';
procedure ldap_unbind(ld: TLDAPHandle); stdcall; external 'wldap32.dll';
function ldap_sslinitW(HostName: PWideChar; PortNumber: ULONG; secure: Integer): TLDAPHandle; stdcall; external 'wldap32.dll' name 'ldap_sslinitW';

var
  LastError: Integer = 0;

// Конвертация строки в UTF-8
function StringToUTF8(const s: string): AnsiString;
var
  Len: Integer;
begin
  if s = '' then
    Result := ''
  else begin
    Len := WideCharToMultiByte(CP_UTF8, 0, PWideChar(s), Length(s), nil, 0, nil, nil);
    SetLength(Result, Len);
    WideCharToMultiByte(CP_UTF8, 0, PWideChar(s), Length(s), PAnsiChar(Result), Len, nil, nil);
  end;
end;


{function LdapConnect(const Server, Username, Password: string): TLDAPHandle;
var
  ld: TLDAPHandle;
  version: ULONG;
  ret: ULONG;
const
  // Значение 1158 — это LDAP_AUTH_NEGOTIATE (стандартный безопасный метод для AD)
  LDAP_AUTH_NEGOTIATE = 1158;
begin
  Result := nil;
  LastError := 0;

  // 1. Открываем защищённое соединение на порту 636 (LDAPS)
  ld := ldap_sslinitW(PWideChar(Server), 636, 1);
  if ld = nil then
  begin
    LastError := GetLastError;
    Exit;
  end;

  // 2. Устанавливаем версию протокола LDAP 3 (обязательно для современных операций)
  version := 3;
  ret := ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, @version);
  if ret <> LDAP_SUCCESS then
  begin
    ldap_unbind(ld);
    LastError := ret;
    Exit;
  end;

  // 3. Аутентифицируемся с помощью безопасного метода Negotiate
  //    Для этого передаем имя пользователя и пароль.
  //    Важно: Имя пользователя передается в виде, например, 'fresh\administrator'.
  ret := ldap_bind_sW(ld, nil, PWideChar(Username), LDAP_AUTH_NEGOTIATE);
  if ret <> LDAP_SUCCESS then
  begin
    ldap_unbind(ld);
    LastError := ret; // Здесь будет 7, если метод не поддерживается
    Exit;
  end;

  Result := ld;
end;  }


function LdapConnect(const Server, Username, Password: string): TLDAPHandle;
var
  ld: TLDAPHandle;
  version: ULONG;
  ret: ULONG;
begin
  Result := nil;
  LastError := 0;
  try
    ld := ldap_openW(PWideChar(Server), LDAP_PORT);
    if ld = nil then
    begin
      LastError := GetLastError;
      Exit;
    end;

    version := 3;
    if ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, @version) <> LDAP_SUCCESS then
    begin
      ldap_unbind(ld);
      LastError := -1;
      Exit;
    end;

    // Отключаем автоматическое следование рефералам (опционально)
    ret := DEREF_NEVER;
    ldap_set_option(ld, LDAP_OPT_DEREF, @ret);

    // Аутентификация
    ret := ldap_bind_sW(ld, nil, PWideChar(Username), 0);
    if ret <> LDAP_SUCCESS then
    begin
      ldap_unbind(ld);
      LastError := ret;
      Exit;
    end;

    Result := ld;
  except
    LastError := -2;
  end;
end;


procedure LdapDisconnect(Handle: TLDAPHandle);
begin
  if Handle <> nil then
    ldap_unbind(Handle);
end;

function LdapSetAttribute(Handle: TLDAPHandle; const UserDN, AttrName, NewValue: string): Boolean;
var
  mods: array[0..1] of PLDAPMod;
  modStruct: TLDAPMod;
  dnUTF8, attrUTF8, valueUTF8: AnsiString;
  values: array[0..1] of PAnsiChar;
  ret: ULONG;
begin
  Result := False;
  LastError := 0;
  if (Handle = nil) or (UserDN = '') or (AttrName = '') then
    Exit;

  dnUTF8 := StringToUTF8(UserDN);
  attrUTF8 := StringToUTF8(AttrName);

  FillChar(modStruct, SizeOf(modStruct), 0);

  if NewValue = '' then
  begin
    // Удаление атрибута
    modStruct.mod_op := LDAP_MOD_DELETE;
    modStruct.mod_type := PAnsiChar(attrUTF8);
    modStruct.mod_vals.modv_strvals := nil;
  end
  else
  begin
    // Замена значения
    valueUTF8 := StringToUTF8(NewValue);
    modStruct.mod_op := LDAP_MOD_REPLACE;
    modStruct.mod_type := PAnsiChar(attrUTF8);
    values[0] := PAnsiChar(valueUTF8);
    values[1] := nil;
    modStruct.mod_vals.modv_strvals := @values[0];
  end;

  mods[0] := @modStruct;
  mods[1] := nil;

  ret := ldap_modify_s(Handle, PAnsiChar(dnUTF8), @mods[0]);
  if ret = LDAP_SUCCESS then
    Result := True
  else
    LastError := ret;
end;

function LdapGetLastError: string;
begin
  if LastError = 0 then
    Result := 'Success'
  else if LastError = -1 then
    Result := 'Failed to set LDAP protocol version'
  else if LastError = -2 then
    Result := 'Exception during connection'
  else
    Result := Format('LDAP error code: %d', [LastError]);
end;

end.
