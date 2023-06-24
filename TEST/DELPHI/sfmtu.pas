unit sfmtu;

// SIMD oriented Fast Mersenne Twister pseudorandom number generator (SFMT)
// Utils

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com
//
// Free for any use.
// No warranty of any kind.

interface

function SysIntToStr_(const AValue: Integer): string;

function GetN2UInt32 (AValue: UInt32): UInt32;
function GetN2UInt64 (AValue: UInt64): UInt64;
function GetN4UInt32 (AValue: UInt32): UInt32;
function GetN4UInt64 (AValue: UInt64): UInt64;

function GetN8UInt32 (AValue: UInt32): UInt32;
function GetN8UInt64 (AValue: UInt64): UInt64;
function GetN16UInt32 (AValue: UInt32): UInt32;
function GetN16UInt64 (AValue: UInt64): UInt64;
function GetN32UInt32 (AValue: UInt32): UInt32;
function GetN32UInt64 (AValue: UInt64): UInt64;
function GetN64UInt32 (AValue: UInt32): UInt32;
function GetN64UInt64 (AValue: UInt64): UInt64;

function GetA8Memory (var ASize: UInt32; var APointer: Pointer): Pointer;
function GetA16Memory (var ASize: UInt32; var APointer: Pointer): Pointer;
function GetA32Memory (var ASize: UInt32; var APointer: Pointer): Pointer;
function GetA64Memory (var ASize: UInt32; var APointer: Pointer): Pointer;

implementation

{
}
function SysIntToStr_(const AValue: Integer): string;
var
  S : ShortString;
begin
  System.STR (AValue, S);
  Result := string(S);
end;

{
  Result = N * 2
  Result >= AValue
}
function GetN2UInt32 (AValue: UInt32): UInt32;
begin
  // $01 = 00000001 = 1
  // $FE = 11111110
  if (AValue and $1) <> 0 then AValue := (AValue + 1) and $FFFFFFFE;
  Result := AValue;
end;

{
  Result = N * 2
  Result >= AValue
}
function GetN2UInt64 (AValue: UInt64): UInt64;
begin
  // $01 = 00000001 = 1
  // $FE = 11111110
  if (AValue and $1) <> 0 then AValue := (AValue + 1) and $FFFFFFFFFFFFFFFE;
  Result := AValue;
end;

{
  Result = N * 4
  Result >= AValue
}
function GetN4UInt32 (AValue: UInt32): UInt32;
begin
  // $03 = 00000011 = 3
  // $FC = 11111100
  if (AValue and $3) <> 0 then AValue := (AValue + 3) and $FFFFFFFC;
  Result := AValue;
end;

{
  Result = N * 4
  Result >= AValue
}
function GetN4UInt64 (AValue: UInt64): UInt64;
begin
  // $03 = 00000011 = 3
  // $FC = 11111100
  if (AValue and $3) <> 0 then AValue := (AValue + 3) and $FFFFFFFFFFFFFFFC;
  Result := AValue;
end;

{
  Result = N * 8
  Result >= AValue
}
function GetN8UInt32 (AValue: UInt32): UInt32;
begin
  // $07 = 00000111 = 7
  // $F8 = 11111000
  if (AValue and $7) <> 0 then AValue := (AValue + 7) and $FFFFFFF8;
  Result := AValue;
end;

{
  Result = N * 8
  Result >= AValue
}
function GetN8UInt64 (AValue: UInt64): UInt64;
begin
  // $07 = 00000111 = 7
  // $F8 = 11111000
  if (AValue and $7) <> 0 then AValue := (AValue + 7) and $FFFFFFFFFFFFFFF8;
  Result := AValue;
end;

{
  Result = N * 16
  Result >= AValue
}
function GetN16UInt32 (AValue: UInt32): UInt32;
begin
  // $0F = 00001111 = 15
  // $F0 = 11110000
  if (AValue and $F) <> 0 then AValue := (AValue + 15) and $FFFFFFF0;
  Result := AValue;
end;

{
  Result = N * 16
  Result >= AValue
}
function GetN16UInt64 (AValue: UInt64): UInt64;
begin
  // $0F = 00001111 = 15
  // $F0 = 11110000
  if (AValue and $F) <> 0 then AValue := (AValue + 15) and $FFFFFFFFFFFFFFF0;
  Result := AValue;
end;

{
  Result = N * 32
  Result >= AValue
}
function GetN32UInt32 (AValue: UInt32): UInt32;
begin
  // $1F = 00011111 = 31
  // $E0 = 11100000
  if (AValue and $1F) <> 0 then AValue := (AValue + 31) and $FFFFFFE0;
  Result := AValue;
end;

{
  Result = N * 32
  Result >= AValue
}
function GetN32UInt64 (AValue: UInt64): UInt64;
begin
  // $1F = 00011111 = 31
  // $E0 = 11100000
  if (AValue and $1F) <> 0 then AValue := (AValue + 31) and $FFFFFFFFFFFFFFE0;
  Result := AValue;
end;

{
  Result = N * 64
  Result >= AValue
}
function GetN64UInt32 (AValue: UInt32): UInt32;
begin
  // $3F = 00111111 = 63
  // $C0 = 11000000
  if (AValue and $3F) <> 0 then AValue := (AValue + 63) and $FFFFFFC0;
  Result := AValue;
end;

{
  Result = N * 64
  Result >= AValue
}
function GetN64UInt64 (AValue: UInt64): UInt64;
begin
  // $3F = 00111111 = 63
  // $C0 = 11000000
  if (AValue and $3F) <> 0 then AValue := (AValue + 63) and $FFFFFFFFFFFFFFC0;
  Result := AValue;
end;

{
  Allocate a 8-byte aligned memory block
  APointer - 8-byte aligned pointer
}
function GetA8Memory (var ASize: UInt32; var APointer: Pointer): Pointer;
var
  P : Pointer;
  B : Byte absolute P;
begin
  ASize := GetN8UInt32 (ASize + 7);
  Result := GetMemory (ASize);
  P := PAnsiChar(Result) + 7;
  B := B and $F8;
  APointer := P;
end;

{
  Allocate a 16-byte aligned memory block
  APointer - 16-byte aligned pointer
}
function GetA16Memory (var ASize: UInt32; var APointer: Pointer): Pointer;
var
  P : Pointer;
  B : Byte absolute P;
begin
  ASize := GetN16UInt32 (ASize + 15);
  Result := GetMemory (ASize);
  P := PAnsiChar(Result) + 15;
  B := B and $F0;
  APointer := P;
end;

{
  Allocate a 32-byte aligned memory block
  APointer - 32-byte aligned pointer
}
function GetA32Memory (var ASize: UInt32; var APointer: Pointer): Pointer;
var
  P : Pointer;
  B : Byte absolute P;
begin
  ASize := GetN32UInt32 (ASize + 31);
  Result := GetMemory (ASize);
  P := PAnsiChar(Result) + 31;
  B := B and $E0;
  APointer := P;
end;

{
  Allocate a 64-byte aligned memory block
  APointer - 64-byte aligned pointer
}
function GetA64Memory (var ASize: UInt32; var APointer: Pointer): Pointer;
var
  P : Pointer;
  B : Byte absolute P;
begin
  ASize := GetN64UInt32 (ASize + 63);
  Result := GetMemory (ASize);
  P := PAnsiChar(Result) + 63;
  B := B and $C0;
  APointer := P;
end;

end.

