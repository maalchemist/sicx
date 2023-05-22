unit SICxUDF;

// SICx user defined function

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

{$I version.inc}

interface

uses
  Windows,
  {$IFDEF SIC_OCX}
  {$IFDEF CPUX64} SICx64_TLB, {$ELSE} SICx32_TLB, {$ENDIF}
  {$ELSE}
  SICxTypes,
  {$IFDEF SIC_DYNAMIC} SICxDProcs, {$ELSE} SICxProcs, {$ENDIF}
  {$ENDIF}
  SICxDefs;

const
  pNaN : Double = +0.0 / 0.0;
  nNaN : Double = -0.0 / 0.0;
  pInf : Double = +1.0 / 0.0;
  nInf : Double = -1.0 / 0.0;

function c_np_i4r: Integer; cdecl;
function c_dp_i4r (X: Double): Integer; cdecl;
function s_np_i4r: Integer; stdcall;
function s_dp_i4r (X: Double): Integer; stdcall;

function random_c: Double; cdecl;
function random_s: Double; stdcall;

procedure nope_c; cdecl;
procedure nope_s; stdcall;

function sinn (X: Double): Double; cdecl;
function coss (X: Double): Double; cdecl;

function sinnn (X: Double): Double; stdcall;
function cosss (X: Double): Double; stdcall;

function aadd (X, Y: Double): Double; cdecl;

function ITEST (X: INT_PTR): Double; cdecl;
function IITEST (X1, X2, X3, X4: INT_PTR): INT_PTR; cdecl;
function PTEST (X: PDouble): Double; cdecl;
procedure NRTEST (var X: Double); cdecl;
procedure NRTEST2 (X: Double); cdecl;
function STEST (S: PAnsiChar): Double; cdecl;
function VTEST (X: Double): Double; cdecl;
function STDCALL_TEST (X: Double): Double; stdcall;
function STDCALL_ITEST (X: Double): Integer; stdcall;

function CDECL_I64 (I: Integer): Int64; cdecl;
function STDCALL_I64 (I: Integer): Int64; stdcall;

function UF_2x2x (I1: Integer; P1: Double; I2: Integer; P2: Double): Double; cdecl;
function UF_REF (var P: Double): Double; cdecl;
function UF_REFF (I1: Integer; P1: Double; I2: Integer; P2: Double; var P: Double): Double; cdecl;
function UF_IREF (I1: INT_PTR; var P: INT_PTR; I2: INT_PTR): Double; cdecl;
function UF_Int64 (I: Int64): Double; cdecl;

function UF_0P (): Double; cdecl;
function UF_1P (P1: Double): Double; cdecl;
function UF_2P (P1, P2: Double): Double; cdecl;
function UF_3P (P1, P2, P3: Double): Double; cdecl;
function UF_4P (P1, P2, P3, P4: Double): Double; cdecl;
function UF_5P (P1, P2, P3, P4, P5: Double): Double; cdecl;
function UF_6P (P1, P2, P3, P4, P5, P6: Double): Double; cdecl;

function CoTest (var P1, P2: TSIC_Complex): Double; cdecl;

procedure CallProc;
procedure Sic2Proc;

procedure CDECL_RE2 (P1: Double); cdecl;
procedure STDCALL_RE2 (P1: Double); stdcall;
procedure CDECL_RE3 (P1: Double); cdecl;
procedure STDCALL_RE3 (P1: Double); stdcall;
procedure CDECL_RE4 (P1: Double); cdecl;
procedure STDCALL_RE4 (P1: Double); stdcall;

procedure CDECL_2P_RE2 (P1, P2: Double); cdecl;
procedure STDCALL_2P_RE2 (P1, P2: Double); stdcall;
procedure CDECL_2P_RE3 (P1, P2: Double); cdecl;
procedure STDCALL_2P_RE3 (P1, P2: Double); stdcall;
procedure CDECL_2P_RE4 (P1, P2: Double); cdecl;
procedure STDCALL_2P_RE4 (P1, P2: Double); stdcall;

procedure CDECL_4P_RE4 (P1, P2, P3, P4: Double); cdecl;
procedure STDCALL_4P_RE4 (P1, P2, P3, P4: Double); stdcall;

var
  SIC_Config : TSIC_Config;

var
  vsic  : TSIC_Data;
  vsic2 : TSIC_Data;

var
  vsic2_proc : Pointer = @Sic2Proc;

var
  a    : Double = 2;
  b    : Double = 8;
  c    : Double = 16;
  d    : Double = 32;
  x    : Double = 1.1;
  xL   : Double = 11.11;
  y    : Double = 2.2;
  z    : Double = 3.3;
  t    : Double = 4.4;
  u    : array [0..7] of Double = (1, 2, 4, 8, 1, 2, 4, 8);

  l    : Double = 1;
  s    : Double = 1;
  h    : Double = 1;

  u_2D : array [0..4-1, 0..5-1] of Double;
  u_3D : array [0..4-1, 0..5-1, 0..6-1] of Double;

  coa  : TSIC_Complex = (re:1; im:2);
  cob  : TSIC_Complex = (re:3; im:4);

  PPP  : Double = 888;
  III  : INT_PTR = 999;
  JJJ  : INT_PTR = 222;

  STR  : AnsiString = 'AnsiString';
  STR8 : AnsiString = '12345678';

implementation

uses
  SysUtils, Classes, Math, SICxUtils, SICxFPU, SICxSSE;

{$IFDEF VER_LD5} // lower than Delphi 5.0
{
}
function Single_IsNan (const AValue: Single): Boolean;
begin
  Result := ((PLongWord(@AValue)^ and $7F800000)  = $7F800000) and
            ((PLongWord(@AValue)^ and $007FFFFF) <> $00000000);
end;

{
}
function IsNan (const AValue: Double): Boolean;
begin
  Result := ((PInt64(@AValue)^ and $7FF0000000000000)  = $7FF0000000000000) and
            ((PInt64(@AValue)^ and $000FFFFFFFFFFFFF) <> $0000000000000000);
end;

{
}
function Extended_IsNan (const AValue: Extended): Boolean;
type
  TExtented = packed record
    Mantissa: Int64;
    Exponent: Word;
  end;
  PExtended = ^TExtented;
begin
  Result := ((PExtended(@AValue)^.Exponent and $7FFF)  = $7FFF) and
            ((PExtended(@AValue)^.Mantissa and $7FFFFFFFFFFFFFFF) <> 0);
end;

{
}
function IsInfinite (const AValue: Double): Boolean;
begin
  Result := ((PInt64(@AValue)^ and $7FF0000000000000) = $7FF0000000000000) and
            ((PInt64(@AValue)^ and $000FFFFFFFFFFFFF) = $0000000000000000);
end;
{$ENDIF}

{
  no parameters
  i4 result
  cdecl
}
function c_np_i4r: Integer; cdecl;
begin
  Result := 0;
end;

{
  double parameter
  i4 result
  cdecl
}
function c_dp_i4r (X: Double): Integer; cdecl;
begin
  Result := 0;
end;

{
  no parameters
  i4 result
  stdcall
}
function s_np_i4r: Integer; stdcall;
begin
  Result := 0;
end;

{
  double parameter
  i4 result
  stdcall
}
function s_dp_i4r (X: Double): Integer; stdcall;
begin
  Result := 0;
end;

{
}
function random_c: Double; cdecl;
begin
  Result := Random;
end;

{
}
function random_s: Double; stdcall;
begin
  Result := Random;
end;

{
}
procedure nope_c; cdecl;
begin
end;

{
}
procedure nope_s; stdcall;
begin
end;

{
}
function sinn (X: Double): Double;
begin
  if IsNan (X) or IsInfinite (X) then begin
    Result := X;
  end else begin
    Result := sin (X);
  end;
end;

{
}
function coss (X: Double): Double;
begin
  if IsNan (X) or IsInfinite (X) then begin
    Result := X;
  end else begin
    Result := cos (X);
  end;
end;

{
}
function sinnn (X: Double): Double;
begin
  if IsNan (X) or IsInfinite (X) then begin
    Result := X;
  end else begin
    Result := sin (X);
  end;
end;

{
}
function cosss (X: Double): Double;
begin
  if IsNan (X) or IsInfinite (X) then begin
    Result := X;
  end else begin
    Result := cos (X);
  end;
end;

{
}
function aadd (X, Y: Double): Double;
begin
  Result := X * Y;
end;

{
}
function ITEST (X: INT_PTR): Double; cdecl;
begin
  Result := X;
end;

{
}
function IITEST (X1, X2, X3, X4: INT_PTR): INT_PTR; cdecl;
begin
  Result := X1 + X2 + X3 + X4;
end;

{
}
function PTEST (X: PDouble): Double; cdecl;
begin
  try
    Result := X^;
  except
    Result := pNaN;
  end;
end;

{
}
procedure NRTEST (var X: Double); cdecl;
begin
  X := IntPower (X, 2);
end;

{
}
procedure NRTEST2 (X: Double); cdecl;
begin
//
end;

{
}
function STEST (S: PAnsiChar): Double; cdecl;
{$IFDEF UNICODE}
var
  V : AnsiString;
begin
  V := S;
  Result := Length (V);
end;
{$ELSE}
begin
  Result := StrLen (S);
end;
{$ENDIF}

{
  variable argument count
}
function VTEST (X: Double): Double; cdecl;
var
  I : Integer;
  C : Integer;
  P : PAnsiChar;
  V : Double;
begin
  Result := 0;

  {$IFDEF SIC_OCX}
  C := SIC.va_count;
  {$ELSE}
  C := sic_va_count;
  {$ENDIF}

  if C <= 0 then Exit;

  P := @X;
  for I := 0 to C - 1 do begin
    V := PDouble(P)^;
    Result := Result + V;
    P := P + SizeOf (Double);
  end;
end;

{
}
function STDCALL_TEST (X: Double): Double; stdcall;
begin
  Result := 10 * X;
end;

{
}
function STDCALL_ITEST (X: Double): Integer; stdcall;
begin
  Result := Trunc (X / 10);
end;

{
}
function CDECL_I64 (I: Integer): Int64; cdecl;
begin
  Result := 123;
end;

{
}
function STDCALL_I64 (I: Integer): Int64; stdcall;
begin
  Result := 321;
end;

{
}
function UF_2x2x (I1: Integer; P1: Double; I2: Integer; P2: Double): Double; cdecl;
begin
  Result := I1 * P1 + I2 * P2;
end;

{
}
function UF_REF (var P: Double): Double; cdecl;
begin
  try
    P := 3.333333333333333333333;
    Result := P;
  except
    Result := pNaN;
  end;
end;

{
}
function UF_REFF (I1: Integer; P1: Double; I2: Integer; P2: Double; var P: Double): Double; cdecl;
begin
  try
    P := 2 * (I1 * P1 + I2 * P2);
    Result := P;
  except
    Result := pNaN;
  end;
end;

{
}
function UF_IREF (I1: INT_PTR; var P: INT_PTR; I2: INT_PTR): Double; cdecl;
begin
  try
    Result := P * 1000 + I1 + I2;
  except
    Result := pNaN;
  end;
end;

{
}
function UF_Int64 (I: Int64): Double; cdecl;
begin
  Result := I;
end;

{
}
function UF_0P (): Double; cdecl;
begin
  Result := 222;
end;

{
}
function UF_1P (P1: Double): Double; cdecl;
begin
  Result := 2 * P1;
end;

{
}
function UF_2P (P1, P2: Double): Double; cdecl;
begin
  Result := 2 * (P1 - P2);
end;

{
}
function UF_3P (P1, P2, P3: Double): Double; cdecl;
begin
  Result := 2 * (P1 + P2 + P3);
end;

{
}
function UF_4P (P1, P2, P3, P4: Double): Double; cdecl;
begin
  Result := 2 * (P1 + P2 + P3 + P4);
end;

{
}
function UF_5P (P1, P2, P3, P4, P5: Double): Double; cdecl;
begin
  Result := 2 * (P1 + P2 + P3 + P4 + P5);
end;

{
}
function UF_6P (P1, P2, P3, P4, P5, P6: Double): Double; cdecl;
begin
  Result := 2 * (P5 - P6);
end;

{
}
function CoTest (var P1, P2: TSIC_Complex): Double; cdecl;
begin
  Result := Sqrt(Sqr(P1.re - P2.re) + Sqr(P1.im - P2.im));
end;

{
}
procedure CallProc;
begin
  C := -111;
end;

{
}
procedure Sic2Proc;
var
  E : DWORD;
begin
  {$IFDEF SIC_OCX}
  SIC.Exec (@vsic2, E);
  {$ELSE}
  sic_exec (@vsic2, E);
  {$ENDIF}
end;

{
  Return 2 double values
}
procedure CDECL_RE2 (P1: Double); cdecl;
var
  V1, V2 : Double;
begin
  V1 := P1 - 2;
  V2 := P1 + 2;

  {$IFDEF SIC_SSE}
  // return 2 double values in the SSE registers
  PushSSE (V1, V2);
  {$ELSE}
  // return 2 double values on the FPU register stack
  PushFPU (V1, V2);
  {$ENDIF}
end;

{
  Return 2 double values
}
procedure STDCALL_RE2 (P1: Double); stdcall;
var
  V1, V2 : Double;
begin
  V1 := P1 - 2;
  V2 := P1 + 2;

  {$IFDEF SIC_SSE}
  // return 2 double values in the SSE registers
  PushSSE (V1, V2);
  {$ELSE}
  // return 2 double values on the FPU register stack
  PushFPU (V1, V2);
  {$ENDIF}
end;

{
  Return 3 double values
}
procedure CDECL_RE3 (P1: Double); cdecl;
var
  V1, V2, V3 : Double;
begin
  V1 := P1 - 3;
  V2 := P1 + 3;
  V3 := P1 * P1;

  {$IFDEF SIC_SSE}
  // return 3 double values in the SSE registers
  PushSSE (V1, V2, V3);
  {$ELSE}
  // return 3 double values on the FPU register stack
  PushFPU (V1, V2, V3);
  {$ENDIF}
end;

{
  Return 3 double values
}
procedure STDCALL_RE3 (P1: Double); stdcall;
var
  V1, V2, V3 : Double;
begin
  V1 := P1 - 3;
  V2 := P1 + 3;
  V3 := P1 * P1;

  {$IFDEF SIC_SSE}
  // return 3 double values in the SSE registers
  PushSSE (V1, V2, V3);
  {$ELSE}
  // return 3 double values on the FPU register stack
  PushFPU (V1, V2, V3);
  {$ENDIF}
end;

{
  Return 4 double values
}
procedure CDECL_RE4 (P1: Double); cdecl;
var
  V1, V2, V3, V4 : Double;
begin
  V1 := P1 - 4;
  V2 := P1 + 4;
  V3 := P1 * P1;
  V4 := 888;

  {$IFDEF SIC_SSE}
  // return 4 double values in the SSE registers
  PushSSE (V1, V2, V3, V4);
  {$ELSE}
  // return 4 double values on the FPU register stack
  PushFPU (V1, V2, V3, V4);
  {$ENDIF}
end;

{
  Return 4 double values
}
procedure STDCALL_RE4 (P1: Double); stdcall;
var
  V1, V2, V3, V4 : Double;
begin
  V1 := P1 - 4;
  V2 := P1 + 4;
  V3 := P1 * P1;
  V4 := 888;

  {$IFDEF SIC_SSE}
  // return 4 double values in the SSE registers
  PushSSE (V1, V2, V3, V4);
  {$ELSE}
  // return 4 double values on the FPU register stack
  PushFPU (V1, V2, V3, V4);
  {$ENDIF}
end;

{
  Return 2 double values
}
procedure CDECL_2P_RE2 (P1, P2: Double); cdecl;
var
  V1, V2 : Double;
begin
  V1 := P1 - 2;
  V2 := P1 + 2;

  {$IFDEF SIC_SSE}
  // return 2 double values in the SSE registers
  PushSSE (V1, V2);
  {$ELSE}
  // return 2 double values on the FPU register stack
  PushFPU (V1, V2);
  {$ENDIF}
end;

{
  Return 2 double values
}
procedure STDCALL_2P_RE2 (P1, P2: Double); stdcall;
var
  V1, V2 : Double;
begin
  V1 := P1 - 2;
  V2 := P1 + 2;

  {$IFDEF SIC_SSE}
  // return 2 double values in the SSE registers
  PushSSE (V1, V2);
  {$ELSE}
  // return 2 double values on the FPU register stack
  PushFPU (V1, V2);
  {$ENDIF}
end;

{
  Return 3 double values
}
procedure CDECL_2P_RE3 (P1, P2: Double); cdecl;
var
  V1, V2, V3 : Double;
begin
  V1 := P1 - 3;
  V2 := P1 + 3;
  V3 := P1 * P1;

  {$IFDEF SIC_SSE}
  // return 3 double values in the SSE registers
  PushSSE (V1, V2, V3);
  {$ELSE}
  // return 3 double values on the FPU register stack
  PushFPU (V1, V2, V3);
  {$ENDIF}
end;

{
  Return 3 double values
}
procedure STDCALL_2P_RE3 (P1, P2: Double); stdcall;
var
  V1, V2, V3 : Double;
begin
  V1 := P1 - 3;
  V2 := P1 + 3;
  V3 := P1 * P1;

  {$IFDEF SIC_SSE}
  // return 3 double values in the SSE registers
  PushSSE (V1, V2, V3);
  {$ELSE}
  // return 3 double values on the FPU register stack
  PushFPU (V1, V2, V3);
  {$ENDIF}
end;

{
  Return 4 double values
}
procedure CDECL_2P_RE4 (P1, P2: Double); cdecl;
var
  V1, V2, V3, V4 : Double;
begin
  V1 := P1 - 4;
  V2 := P1 + 4;
  V3 := P1 * P2;
  V4 := 888;

  {$IFDEF SIC_SSE}
  // return 4 double values in the SSE registers
  PushSSE (V1, V2, V3, V4);
  {$ELSE}
  // return 4 double values on the FPU register stack
  PushFPU (V1, V2, V3, V4);
  {$ENDIF}
end;

{
  Return 4 double values
}
procedure STDCALL_2P_RE4 (P1, P2: Double); stdcall;
var
  V1, V2, V3, V4 : Double;
begin
  V1 := P1 - 4;
  V2 := P1 + 4;
  V3 := P1 * P2;
  V4 := 888;

  {$IFDEF SIC_SSE}
  // return 4 double values in the SSE registers
  PushSSE (V1, V2, V3, V4);
  {$ELSE}
  // return 4 double values on the FPU register stack
  PushFPU (V1, V2, V3, V4);
  {$ENDIF}
end;

{
  Return 4 double values
}
procedure CDECL_4P_RE4 (P1, P2, P3, P4: Double); cdecl;
var
  V1, V2, V3, V4 : Double;
begin
  V1 := P1 - 4;
  V2 := P2 + 4;
  V3 := P3 * P4;
  V4 := 888;

  {$IFDEF SIC_SSE}
  // return 4 double values in the SSE registers
  PushSSE (V1, V2, V3, V4);
  {$ELSE}
  // return 4 double values on the FPU register stack
  PushFPU (V1, V2, V3, V4);
  {$ENDIF}
end;

{
  Return 4 double values
}
procedure STDCALL_4P_RE4 (P1, P2, P3, P4: Double); stdcall;
var
  V1, V2, V3, V4 : Double;
begin
  V1 := P1 - 4;
  V2 := P2 + 4;
  V3 := P3 * P4;
  V4 := 888;

  {$IFDEF SIC_SSE}
  // return 4 double values in the SSE registers
  PushSSE (V1, V2, V3, V4);
  {$ELSE}
  // return 4 double values on the FPU register stack
  PushFPU (V1, V2, V3, V4);
  {$ENDIF}
end;

end.

