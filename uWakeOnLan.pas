unit uWakeOnLan;

{
  Модуль для отправки Wake-on-LAN (WOL) магического пакета
  для удалённого включения компьютера по MAC-адресу.
}

interface

uses
  System.SysUtils, Winapi.Windows, Winapi.Winsock2;

// Отправляет магический пакет на широковещательный адрес (255.255.255.255:9)
// AMac - MAC-адрес в формате 'XX-XX-XX-XX-XX-XX' (допустимы разделители '-' или ':', либо без них)
// Возвращает True, если пакет успешно отправлен
function WakeOnLan(const AMac: string): Boolean; overload;

// Отправляет магический пакет на указанный IP-адрес и порт (по умолчанию порт 9)
function WakeOnLan(const AMac: string; const AIP: string; const APort: Word = 9): Boolean; overload;

implementation

// Преобразует строку MAC-адреса в массив из 6 байт
function MacStringToBytes(const AMac: string; out ABytes: array of Byte): Boolean;
var
  CleanMac: string;
  i: Integer;
begin
  Result := False;
  CleanMac := StringReplace(AMac, '-', '', [rfReplaceAll]);
  CleanMac := StringReplace(CleanMac, ':', '', [rfReplaceAll]);
  if Length(CleanMac) <> 12 then
    Exit;
  for i := 0 to 5 do
  begin
    try
      ABytes[i] := StrToInt('$' + Copy(CleanMac, i * 2 + 1, 2));
    except
      Exit;
    end;
  end;
  Result := True;
end;

// -----------------------------------------------------------------------------
function WakeOnLan(const AMac: string): Boolean;
// Отправка на широковещательный адрес (255.255.255.255:9)
begin
  Result := WakeOnLan(AMac, '255.255.255.255', 9);
end;

// -----------------------------------------------------------------------------
function WakeOnLan(const AMac: string; const AIP: string; const APort: Word): Boolean;
// Отправка на заданный IP и порт
var
  MacBytes: array[0..5] of Byte;
  MagicPacket: array[0..101] of Byte;
  i, j: Integer;
  Sock: TSocket;
  Addr: TSockAddr;
  AddrSize: Integer;
  OptVal: Integer;
begin
  Result := False;
  if not MacStringToBytes(AMac, MacBytes) then
    Exit;

  // Формируем магический пакет: 6 байт 0xFF, затем 16 копий MAC-адреса
  FillChar(MagicPacket, SizeOf(MagicPacket), 0);
  for i := 0 to 5 do
    MagicPacket[i] := $FF;
  for j := 0 to 15 do
    for i := 0 to 5 do
      MagicPacket[6 + j * 6 + i] := MacBytes[i];

  Sock := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if Sock = INVALID_SOCKET then
    Exit;

  try
    OptVal := 1;
    setsockopt(Sock, SOL_SOCKET, SO_BROADCAST, @OptVal, SizeOf(OptVal));

    Addr.sin_family := AF_INET;
    Addr.sin_port := htons(APort);
    Addr.sin_addr.s_addr := inet_addr(PAnsiChar(AnsiString(AIP)));
    AddrSize := SizeOf(Addr);

    if sendto(Sock, MagicPacket[0], SizeOf(MagicPacket), 0, Addr, AddrSize) = SizeOf(MagicPacket) then
      Result := True;
  finally
    closesocket(Sock);
  end;
end;

end.