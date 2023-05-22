unit cordic;

// CORDIC-based approximations

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

{$IFDEF FPC} // Lazarus
  {$ASMMODE INTEL}
{$ENDIF}

{$DEFINE __CORDIC_AUTO_BREAK}
{$UNDEF __CORDIC_AUTO_BREAK}

interface

function  cordic_cos (X: Double; N: Integer): Double;
function  cordic_sin (X: Double; N: Integer): Double;
procedure cordic_sincos (X: Double; var ASin, ACos: Double; N: Integer); overload;
procedure cordic_sincos (X, Factor: Double; var AFSin, AFCos: Double; N: Integer); overload;
procedure cordic_atan2 (X, Y: Double; var ATan, AHyp: Double; N: Integer); overload;
function  cordic_atan2 (X, Y: Double; N: Integer): Double; overload;
function  cordic_atan (Y: Double; N: Integer): Double;

procedure cordic_sincos_test;
procedure cordic_atan_test;

implementation

uses
  Math;

const
  PI2 : Double = pi/2;

const
  // arctan(2^(-n))
  atan_2mn : array [0..64] of Int64 = (
    $3FE921FB54442D18 ,
    $3FDDAC670561BB4F ,
    $3FCF5B75F92C80DD ,
    $3FBFD5BA9AAC2F6E ,
    $3FAFF55BB72CFDEA ,
    $3F9FFD55BBA97625 ,
    $3F8FFF555BBB729B ,
    $3F7FFFD555BBBA97 ,
    $3F6FFFF5555BBBB7 ,
    $3F5FFFFD5555BBBC ,
    $3F4FFFFF55555BBC ,
    $3F3FFFFFD55555BC ,
    $3F2FFFFFF555555C ,
    $3F1FFFFFFD555556 ,
    $3F0FFFFFFF555555 ,
    $3EFFFFFFFFD55555 ,
    $3EEFFFFFFFF55555 ,
    $3EDFFFFFFFFD5555 ,
    $3ECFFFFFFFFF5555 ,
    $3EBFFFFFFFFFD555 ,
    $3EAFFFFFFFFFF555 ,
    $3E9FFFFFFFFFFD55 ,
    $3E8FFFFFFFFFFF55 ,
    $3E7FFFFFFFFFFFD5 ,
    $3E6FFFFFFFFFFFF5 ,
    $3E5FFFFFFFFFFFFD ,
    $3E4FFFFFFFFFFFFF ,
    $3E40000000000000 ,
    $3E30000000000000 ,
    $3E20000000000000 ,
    $3E10000000000000 ,
    $3E00000000000000 ,
    $3DF0000000000000 ,
    $3DE0000000000000 ,
    $3DD0000000000000 ,
    $3DC0000000000000 ,
    $3DB0000000000000 ,
    $3DA0000000000000 ,
    $3D90000000000000 ,
    $3D80000000000000 ,
    $3D70000000000000 ,
    $3D60000000000000 ,
    $3D50000000000000 ,
    $3D40000000000000 ,
    $3D30000000000000 ,
    $3D20000000000000 ,
    $3D10000000000000 ,
    $3D00000000000000 ,
    $3CF0000000000000 ,
    $3CE0000000000000 ,
    $3CD0000000000000 ,
    $3CC0000000000000 ,
    $3CB0000000000000 ,
    $3CA0000000000000 ,
    $3C90000000000000 ,
    $3C80000000000000 ,
    $3C70000000000000 ,
    $3C60000000000000 ,
    $3C50000000000000 ,
    $3C40000000000000 ,
    $3C30000000000000 ,
    $3C20000000000000 ,
    $3C10000000000000 ,
    $3C00000000000000 ,
    $3BF0000000000000
  );

const
// K[i] = 1/sqrt(1+2^(-2*i))
// Kn = K[0]*K[1]*...K[n-1]
  cordic_Kn : array [0..64] of Int64 = (
    $3FE6A09E667F3BCD ,
    $3FE43D136248490F ,
    $3FE3A261BA6D7A37 ,
    $3FE37B9141DEB3FE ,
    $3FE371DAC182EEF6 ,
    $3FE36F6CFABD961F ,
    $3FE36ED1869F27E9 ,
    $3FE36EAAA970B20F ,
    $3FE36EA0F222A6D1 ,
    $3FE36E9E844EFD24 ,
    $3FE36E9DE8DA104B ,
    $3FE36E9DC1FCD4EE ,
    $3FE36E9DB8458614 ,
    $3FE36E9DB5D7B25E ,
    $3FE36E9DB53C3D70 ,
    $3FE36E9DB5156034 ,
    $3FE36E9DB50BA8E6 ,
    $3FE36E9DB5093B12 ,
    $3FE36E9DB5089F9D ,
    $3FE36E9DB50878C0 ,
    $3FE36E9DB5086F08 ,
    $3FE36E9DB5086C9B ,
    $3FE36E9DB5086BFF ,
    $3FE36E9DB5086BD8 ,
    $3FE36E9DB5086BCF ,
    $3FE36E9DB5086BCC ,
    $3FE36E9DB5086BCC ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB ,
    $3FE36E9DB5086BCB
  );

{$IFDEF VER120} // Delphi 4.0
function Sign (X: Double): Integer;
begin
  Result := 0;
  if X > 0 then Result := +1 else
  if X < 0 then Result := -1 ;
end;
{$ENDIF}

{
  Result = X / 2^N, N>=0
}
{$IFDEF CPUX64}
function div2n (X: Double; N: Integer): Double; assembler;
// xmm0 | X |
// rdx  | N |
// r8   |   |
// r9   |   |
asm
//      test    edx, edx
//      jz      @@RET                           // return X
//      js      @@RET

        movq    rax, xmm0
        mov     rcx, rax
        shr     rcx, 52
        and     rcx, $07FF                      // rcx = 11-bit exponent
        sub     rcx, rdx
        jns     @@EXP
  @@R0:                                         // return 0
        xorpd   xmm0, xmm0
        jmp     @@RET
  @@EXP:                                        // update exponent
        shl     rcx, 52
        mov     r10, $800FFFFFFFFFFFFF
        and     rax, r10                        // clear exponent
        or      rax, rcx                        // assign exponent
  @@FLD:
        movq    xmm0, rax
  @@RET:
end;
{$ELSE}
function div2n (X: Double; N: Integer): Double; assembler;
// [esp+8] | X |
// eax     | N |
// edx     |   |
// ecx     |   |
asm
//      test    eax, eax
//      jz      @@FLD                           // return X
//      js      @@FLD

        mov     edx, [esp + 12]
        mov     ecx, edx
        shr     edx, 20
        and     edx, $07FF                      // edx = 11-bit exponent
        sub     edx, eax
        jns     @@EXP
  @@R0:                                         // return 0
        fldz
        jmp     @@RET
  @@EXP:                                        // update exponent
        shl     edx, 20
        and     ecx, $800FFFFF                  // clear exponent
        or      ecx, edx                        // assign exponent
        mov     [esp + 12], ecx
  @@FLD:
        fld     qword [esp + 8]
  @@RET:
end;
{$ENDIF}

{
  Result = A + X / 2^N, N>=0
}
{$IFDEF CPUX64}
function add_div2n (A, X: Double; N: Integer): Double; assembler;
// xmm0 | A |
// xmm1 | X |
// r8   | N |
// r9   |   |
asm
//      test    r8d, r8d
//      jz      @@ADD                           // return A+X
//      js      @@ADD

        movq    rax, xmm1
        mov     rcx, rax
        shr     rcx, 52
        and     rcx, $07FF                      // rcx = 11-bit exponent
        sub     rcx, r8
        js      @@RET                           // return A
  @@EXP:                                        // update exponent
        shl     rcx, 52
        mov     r10, $800FFFFFFFFFFFFF
        and     rax, r10                        // clear exponent
        or      rax, rcx                        // assign exponent
        movq    xmm1, rax
  @@ADD:
        addsd   xmm0, xmm1
  @@RET:
end;
{$ELSE}
function add_div2n (A, X: Double; N: Integer): Double; assembler;
// [esp+8]  | X |
// [esp+16] | A |
// eax      | N |
// edx      |   |
// ecx      |   |
asm
//      test    eax, eax
//      jz      @@ADD                           // return A+X
//      js      @@ADD

        mov     edx, [esp + 12]
        mov     ecx, edx
        shr     edx, 20
        and     edx, $07FF                      // edx = 11-bit exponent
        sub     edx, eax
        jns     @@EXP
        fld     qword [esp + 16]                // return A
        jmp     @@RET
  @@EXP:                                        // update exponent
        shl     edx, 20
        and     ecx, $800FFFFF                  // clear exponent
        or      ecx, edx                        // assign exponent
        mov     [esp + 12], ecx
  @@ADD:
        fld     qword [esp + 16]
        fld     qword [esp + 8]
        faddp
  @@RET:
end;
{$ENDIF}

{
  Result = A - X / 2^N, N>=0
}
{$IFDEF CPUX64}
function sub_div2n (A, X: Double; N: Integer): Double; assembler;
// xmm0 | A |
// xmm1 | X |
// r8   | N |
// r9   |   |
asm
//      test    r8d, r8d
//      jz      @@SUB                           // return A-X
//      js      @@SUB

        movq    rax, xmm1
        mov     rcx, rax
        shr     rcx, 52
        and     rcx, $07FF                      // rcx = 11-bit exponent
        sub     rcx, r8
        js      @@RET                           // return A
  @@EXP:                                        // update exponent
        shl     rcx, 52
        mov     r10, $800FFFFFFFFFFFFF
        and     rax, r10                        // clear exponent
        or      rax, rcx                        // assign exponent
        movq    xmm1, rax
  @@SUB:
        subsd   xmm0, xmm1
  @@RET:
end;
{$ELSE}
function sub_div2n (A, X: Double; N: Integer): Double; assembler;
// [esp+8]  | X |
// [esp+16] | A |
// eax      | N |
// edx      |   |
// ecx      |   |
asm
//      test    eax, eax
//      jz      @@SUB                           // return A-X
//      js      @@SUB

        mov     edx, [esp + 12]
        mov     ecx, edx
        shr     edx, 20
        and     edx, $07FF                      // edx = 11-bit exponent
        sub     edx, eax
        jns     @@EXP
        fld     qword [esp + 16]                // return A
        jmp     @@RET
  @@EXP:                                        // update exponent
        shl     edx, 20
        and     ecx, $800FFFFF                  // clear exponent
        or      ecx, edx                        // assign exponent
        mov     [esp + 12], ecx
  @@SUB:
        fld     qword [esp + 16]
        fld     qword [esp + 8]
        fsubp
  @@RET:
end;
{$ENDIF}

{
  N - the number of iterations
}
function cordic_cos (X: Double; N: Integer): Double;
var
  I       : Integer;
  X_abs   : Double;
  Xn      : Integer;
  Xq      : Integer;
  X0      : Double;
  X_i     : Double;
  X_i_1   : Double;
  Y_i     : Double;
  Y_i_1   : Double;
  Z_i     : Double;
  CK_I    : Int64;
  CK_D    : Double absolute CK_I;
  AT_I    : Int64;
  AT_D    : Double absolute AT_I;

  {$IFDEF __CORDIC_AUTO_BREAK}
  X_I64   : Int64 absolute X_i;
  X_I64_1 : Int64 absolute X_i_1;
  X_I64_D : Int64;
  Y_I64   : Int64 absolute Y_i;
  Y_I64_1 : Int64 absolute Y_i_1;
  Y_I64_D : Int64;
  {$ENDIF}
begin
  if N < 1 then N := 1 else
  if N > 64 then N := 64;

  if X = 0 then begin
    Result := 1;
    Exit;
  end;

  X_abs := Abs(X);

  Xn := Trunc(X_abs/PI2);
  Xq := Xn and $03; // Xn mod 4;
  X0 := X_abs - Xn*PI2;

  CK_I := cordic_Kn[N-1];

  X_i := CK_D;
  Y_i := 0;
  Z_i := X0;

  for I := 0 to N - 2 do begin
    AT_I := atan_2mn[I];

    if Z_i >= 0 then begin
      Z_i := Z_i - AT_D;
      X_i_1 := sub_div2n (X_i, Y_i, I);
      Y_i_1 := add_div2n (Y_i, X_i, I);
    end else begin
      Z_i := Z_i + AT_D;
      X_i_1 := add_div2n (X_i, Y_i, I);
      Y_i_1 := sub_div2n (Y_i, X_i, I);
    end;

    {$IFDEF __CORDIC_AUTO_BREAK}
    X_I64_D := X_I64_1 - X_I64;
    Y_I64_D := Y_I64_1 - Y_I64;
    if (X_I64_D = 0) and (Y_I64_D = 0) then begin
      Break;
    end;
    {$ENDIF}

    X_i := X_i_1;
    Y_i := Y_i_1;
  end;

  // ACos := X_i;
  // ASin := Y_i;

  // X = X0 + Xn*(pi/2)

  // Xn = 0
  // X = X0
  if Xq = 0 then begin
    Result := X_i;
    Exit;
  end;

  // Xn = 1
  // X = X0 + pi/2
  // cos(1*pi/2+x) = -sin(x)
  // sin(1*pi/2+x) =  cos(x)
  if Xq = 1 then begin
    Result := -Y_i;
    Exit;
  end;

  // Xn = 2
  // X = X0 + pi
  // cos(2*pi/2+x) = -cos(x)
  // sin(2*pi/2+x) = -sin(x)
  if Xq = 2 then begin
    Result := -X_i;
    Exit;
  end;

  // Xn = 3
  // X = X0 + pi*3/2
  // cos(3*pi/2+x) =  sin(x)
  // sin(3*pi/2+x) = -cos(x)
  Result := Y_i;
end;

{
  N - the number of iterations
}
function cordic_sin (X: Double; N: Integer): Double;
var
  I       : Integer;
  X_sign  : Integer;
  X_abs   : Double;
  Xn      : Integer;
  Xq      : Integer;
  X0      : Double;
  X_i     : Double;
  X_i_1   : Double;
  Y_i     : Double;
  Y_i_1   : Double;
  Z_i     : Double;
  CK_I    : Int64;
  CK_D    : Double absolute CK_I;
  AT_I    : Int64;
  AT_D    : Double absolute AT_I;

  {$IFDEF __CORDIC_AUTO_BREAK}
  X_I64   : Int64 absolute X_i;
  X_I64_1 : Int64 absolute X_i_1;
  X_I64_D : Int64;
  Y_I64   : Int64 absolute Y_i;
  Y_I64_1 : Int64 absolute Y_i_1;
  Y_I64_D : Int64;
  {$ENDIF}
begin
  if N < 1 then N := 1 else
  if N > 64 then N := 64;

  if X = 0 then begin
    Result := 0;
    Exit;
  end;

  if X > 0 then begin
    X_sign := +1;
  end else begin
    X_sign := -1;
  end;

  X_abs := Abs(X);

  Xn := Trunc(X_abs/PI2);
  Xq := Xn and $03; // Xn mod 4;
  X0 := X_abs - Xn*PI2;

  CK_I := cordic_Kn[N-1];

  X_i := CK_D;
  Y_i := 0;
  Z_i := X0;

  for I := 0 to N - 2 do begin
    AT_I := atan_2mn[I];

    if Z_i >= 0 then begin
      Z_i := Z_i - AT_D;
      X_i_1 := sub_div2n (X_i, Y_i, I);
      Y_i_1 := add_div2n (Y_i, X_i, I);
    end else begin
      Z_i := Z_i + AT_D;
      X_i_1 := add_div2n (X_i, Y_i, I);
      Y_i_1 := sub_div2n (Y_i, X_i, I);
    end;

    {$IFDEF __CORDIC_AUTO_BREAK}
    X_I64_D := X_I64_1 - X_I64;
    Y_I64_D := Y_I64_1 - Y_I64;
    if (X_I64_D = 0) and (Y_I64_D = 0) then begin
      Break;
    end;
    {$ENDIF}

    X_i := X_i_1;
    Y_i := Y_i_1;
  end;

  // ACos := X_i;
  // ASin := Y_i;

  // X = X0 + Xn*(pi/2)

  // Xn = 0
  // X = X0
  if Xq = 0 then begin
    Result := Y_i*X_sign;
    Exit;
  end;

  // Xn = 1
  // X = X0 + pi/2
  // cos(1*pi/2+x) = -sin(x)
  // sin(1*pi/2+x) =  cos(x)
  if Xq = 1 then begin
    Result := X_i*X_sign;
    Exit;
  end;

  // Xn = 2
  // X = X0 + pi
  // cos(2*pi/2+x) = -cos(x)
  // sin(2*pi/2+x) = -sin(x)
  if Xq = 2 then begin
    Result := -Y_i*X_sign;
    Exit;
  end;

  // Xn = 3
  // X = X0 + pi*3/2
  // cos(3*pi/2+x) =  sin(x)
  // sin(3*pi/2+x) = -cos(x)
  Result := -X_i*X_sign;
end;

{
  ASin = sin(x)
  ACos = cos(x)
  N - the number of iterations
}
procedure cordic_sincos (X: Double; var ASin, ACos: Double; N: Integer);
var
  I       : Integer;
  X_sign  : Integer;
  X_abs   : Double;
  Xn      : Integer;
  Xq      : Integer;
  X0      : Double;
  X_i     : Double;
  X_i_1   : Double;
  Y_i     : Double;
  Y_i_1   : Double;
  Z_i     : Double;
  CK_I    : Int64;
  CK_D    : Double absolute CK_I;
  AT_I    : Int64;
  AT_D    : Double absolute AT_I;

  {$IFDEF __CORDIC_AUTO_BREAK}
  X_I64   : Int64 absolute X_i;
  X_I64_1 : Int64 absolute X_i_1;
  X_I64_D : Int64;
  Y_I64   : Int64 absolute Y_i;
  Y_I64_1 : Int64 absolute Y_i_1;
  Y_I64_D : Int64;
  {$ENDIF}
begin
  if N < 1 then N := 1 else
  if N > 64 then N := 64;

  if X = 0 then begin
    ACos := 1;
    ASin := 0;
    Exit;
  end;

  if X > 0 then begin
    X_sign := +1;
  end else begin
    X_sign := -1;
  end;

  X_abs := Abs(X);

  Xn := Trunc(X_abs/PI2);
  Xq := Xn and $03; // Xn mod 4;
  X0 := X_abs - Xn*PI2;

  CK_I := cordic_Kn[N-1];

  X_i := CK_D;
  Y_i := 0;
  Z_i := X0;

  for I := 0 to N - 2 do begin
    AT_I := atan_2mn[I];

    if Z_i >= 0 then begin
      Z_i := Z_i - AT_D;
      X_i_1 := sub_div2n (X_i, Y_i, I);
      Y_i_1 := add_div2n (Y_i, X_i, I);
    end else begin
      Z_i := Z_i + AT_D;
      X_i_1 := add_div2n (X_i, Y_i, I);
      Y_i_1 := sub_div2n (Y_i, X_i, I);
    end;

    {$IFDEF __CORDIC_AUTO_BREAK}
    X_I64_D := X_I64_1 - X_I64;
    Y_I64_D := Y_I64_1 - Y_I64;
    if (X_I64_D = 0) and (Y_I64_D = 0) then begin
      Break;
    end;
    {$ENDIF}

    X_i := X_i_1;
    Y_i := Y_i_1;
  end;

  // ACos := X_i;
  // ASin := Y_i;

  // X = X0 + Xn*(pi/2)

  // Xn = 0
  // X = X0
  if Xq = 0 then begin
    ACos := X_i;
    ASin := Y_i*X_sign;
    Exit;
  end;

  // Xn = 1
  // X = X0 + pi/2
  // cos(1*pi/2+x) = -sin(x)
  // sin(1*pi/2+x) =  cos(x)
  if Xq = 1 then begin
    ACos := -Y_i;
    ASin :=  X_i*X_sign;
    Exit;
  end;

  // Xn = 2
  // X = X0 + pi
  // cos(2*pi/2+x) = -cos(x)
  // sin(2*pi/2+x) = -sin(x)
  if Xq = 2 then begin
    ACos := -X_i;
    ASin := -Y_i*X_sign;
    Exit;
  end;

  // Xn = 3
  // X = X0 + pi*3/2
  // cos(3*pi/2+x) =  sin(x)
  // sin(3*pi/2+x) = -cos(x)
  ACos :=  Y_i;
  ASin := -X_i*X_sign;
end;

{
  AFSin = factor*sin(x)
  AFCos = factor*cos(x)
  N - the number of iterations
}
procedure cordic_sincos (X, Factor: Double; var AFSin, AFCos: Double; N: Integer);
var
  I       : Integer;
  X_sign  : Integer;
  X_abs   : Double;
  Xn      : Integer;
  Xq      : Integer;
  X0      : Double;
  X_i     : Double;
  X_i_1   : Double;
  Y_i     : Double;
  Y_i_1   : Double;
  Z_i     : Double;
  CK_I    : Int64;
  CK_D    : Double absolute CK_I;
  AT_I    : Int64;
  AT_D    : Double absolute AT_I;

  {$IFDEF __CORDIC_AUTO_BREAK}
  X_I64   : Int64 absolute X_i;
  X_I64_1 : Int64 absolute X_i_1;
  X_I64_D : Int64;
  Y_I64   : Int64 absolute Y_i;
  Y_I64_1 : Int64 absolute Y_i_1;
  Y_I64_D : Int64;
  {$ENDIF}
begin
  if N < 1 then N := 1 else
  if N > 64 then N := 64;

  if X = 0 then begin
    AFCos := Factor;
    AFSin := 0;
    Exit;
  end;

  if X > 0 then begin
    X_sign := +1;
  end else begin
    X_sign := -1;
  end;

  X_abs := Abs(X);

  Xn := Trunc(X_abs/PI2);
  Xq := Xn and $03; // Xn mod 4;
  X0 := X_abs - Xn*PI2;

  CK_I := cordic_Kn[N-1];

  X_i := CK_D*Factor;
  Y_i := 0;
  Z_i := X0;

  for I := 0 to N - 2 do begin
    AT_I := atan_2mn[I];

    if Z_i >= 0 then begin
      Z_i := Z_i - AT_D;
      X_i_1 := sub_div2n (X_i, Y_i, I);
      Y_i_1 := add_div2n (Y_i, X_i, I);
    end else begin
      Z_i := Z_i + AT_D;
      X_i_1 := add_div2n (X_i, Y_i, I);
      Y_i_1 := sub_div2n (Y_i, X_i, I);
    end;

    {$IFDEF __CORDIC_AUTO_BREAK}
    X_I64_D := X_I64_1 - X_I64;
    Y_I64_D := Y_I64_1 - Y_I64;
    if (X_I64_D = 0) and (Y_I64_D = 0) then begin
      Break;
    end;
    {$ENDIF}

    X_i := X_i_1;
    Y_i := Y_i_1;
  end;

  // AFCos := X_i;
  // AFSin := Y_i;

  // X = X0 + Xn*(pi/2)

  // Xn = 0
  // X = X0
  if Xq = 0 then begin
    AFCos := X_i;
    AFSin := Y_i*X_sign;
    Exit;
  end;

  // Xn = 1
  // X = X0 + pi/2
  // cos(1*pi/2+x) = -sin(x)
  // sin(1*pi/2+x) =  cos(x)
  if Xq = 1 then begin
    AFCos := -Y_i;
    AFSin :=  X_i*X_sign;
    Exit;
  end;

  // Xn = 2
  // X = X0 + pi
  // cos(2*pi/2+x) = -cos(x)
  // sin(2*pi/2+x) = -sin(x)
  if Xq = 2 then begin
    AFCos := -X_i;
    AFSin := -Y_i*X_sign;
    Exit;
  end;

  // Xn = 3
  // X = X0 + pi*3/2
  // cos(3*pi/2+x) =  sin(x)
  // sin(3*pi/2+x) = -cos(x)
  AFCos :=  Y_i;
  AFSin := -X_i*X_sign;
end;

{
  ATan = arctan(y/x)
  AHyp = sqrt(x^2+y^2)
  N - the number of iterations
}
procedure cordic_atan2 (X, Y: Double; var ATan, AHyp: Double; N: Integer);
var
  I     : Integer;
  X_i   : Double;
  X_i_1 : Double;
  Y_i   : Double;
  Y_i_1 : Double;
  Z_i   : Double;
  CK_I  : Int64;
  CK_D  : Double absolute CK_I;
  AT_I  : Int64;
  AT_D  : Double absolute AT_I;
begin
  if N < 1 then N := 1 else
  if N > 64 then N := 64;

  CK_I := cordic_Kn[N-1];

  X_i := X;
  Y_i := Y;
  Z_i := 0;
  (*
  X_i := X*CK_D;
  Y_i := Y*CK_D;
  Z_i := 0;
  // *)

  for I := 0 to N - 2 do begin
    AT_I := atan_2mn[I];

    if Y_i < 0 then begin
      Z_i := Z_i - AT_D;
      X_i_1 := sub_div2n (X_i, Y_i, I);
      Y_i_1 := add_div2n (Y_i, X_i, I);
    end else begin
      Z_i := Z_i + AT_D;
      X_i_1 := add_div2n (X_i, Y_i, I);
      Y_i_1 := sub_div2n (Y_i, X_i, I);
    end;

    X_i := X_i_1;
    Y_i := Y_i_1;
  end;

  ATan := Z_i;
  AHyp := X_i*CK_D;
  (*
  ATan := Z_i;
  AHyp := X_i;
  // *)
end;

{
  Result = arctan(y/x)
  N - the number of iterations
}
function cordic_atan2 (X, Y: Double; N: Integer): Double;
var
  I     : Integer;
  X_i   : Double;
  X_i_1 : Double;
  Y_i   : Double;
  Y_i_1 : Double;
  Z_i   : Double;
  CK_I  : Int64;
  CK_D  : Double absolute CK_I;
  AT_I  : Int64;
  AT_D  : Double absolute AT_I;
begin
  if N < 1 then N := 1 else
  if N > 64 then N := 64;

  CK_I := cordic_Kn[N-1];

  X_i := X;
  Y_i := Y;
  Z_i := 0;

  for I := 0 to N - 2 do begin
    AT_I := atan_2mn[I];

    if Y_i < 0 then begin
      Z_i := Z_i - AT_D;
      X_i_1 := sub_div2n (X_i, Y_i, I);
      Y_i_1 := add_div2n (Y_i, X_i, I);
    end else begin
      Z_i := Z_i + AT_D;
      X_i_1 := add_div2n (X_i, Y_i, I);
      Y_i_1 := sub_div2n (Y_i, X_i, I);
    end;

    X_i := X_i_1;
    Y_i := Y_i_1;
  end;

  Result := Z_i;
end;

{
  Result = arctan(y)
  N - the number of iterations
}
function cordic_atan (Y: Double; N: Integer): Double;
var
  I     : Integer;
  X_i   : Double;
  X_i_1 : Double;
  Y_i   : Double;
  Y_i_1 : Double;
  Z_i   : Double;
  CK_I  : Int64;
  CK_D  : Double absolute CK_I;
  AT_I  : Int64;
  AT_D  : Double absolute AT_I;
begin
  if N < 1 then N := 1 else
  if N > 64 then N := 64;

  CK_I := cordic_Kn[N-1];

  X_i := 1;
  Y_i := Y;
  Z_i := 0;

  for I := 0 to N - 2 do begin
    AT_I := atan_2mn[I];

    if Y_i < 0 then begin
      Z_i := Z_i - AT_D;
      X_i_1 := sub_div2n (X_i, Y_i, I);
      Y_i_1 := add_div2n (Y_i, X_i, I);
    end else begin
      Z_i := Z_i + AT_D;
      X_i_1 := add_div2n (X_i, Y_i, I);
      Y_i_1 := sub_div2n (Y_i, X_i, I);
    end;

    X_i := X_i_1;
    Y_i := Y_i_1;
  end;

  Result := Z_i;
end;

{
}
procedure cordic_sincos_test;
var
  x, f   : Double;
  sin_1  : Double;
  sin_2  : Double;
  sin_D  : Double;
  cos_1  : Double;
  cos_2  : Double;
  cos_D  : Double;
  fsin_1 : Double;
  fsin_2 : Double;
  fsin_D : Double;
  fcos_1 : Double;
  fcos_2 : Double;
  fcos_D : Double;
begin
  // x := 1E-88;
  x := -0.555;
  f := 888.222;

  sin_1 := Sin (x);
  cos_1 := Cos (x);
  cordic_sincos (x, sin_2, cos_2, 53);
  sin_D := sin_1 - sin_2;
  cos_D := cos_1 - cos_2;
  if sin_D = cos_D then ;

  fsin_1 := f * Sin (x);
  fcos_1 := f * Cos (x);
  cordic_sincos (x, f, fsin_2, fcos_2, 53);
  fsin_D := fsin_1 - fsin_2;
  fcos_D := fcos_1 - fcos_2;
  if fsin_D = fcos_D then ;
end;

{
}
procedure cordic_atan_test;
var
  x, y    : Double;
  atan_1  : Double;
  atan_2  : Double;
  atan_D  : Double;
  atan2_1 : Double;
  atan2_2 : Double;
  atan2_D : Double;
  hyp_1   : Double;
  hyp_2   : Double;
  hyp_D   : Double;
begin
  x := 2;
  y := 88888888;

  atan_1 := ArcTan (y);
  atan_2 := cordic_atan (y, 53);
  atan_D := atan_1 - atan_2;
  if atan_D = 0 then ;

  atan2_1 := ArcTan (y/x);
  hyp_1 := Hypot (x, y);
  cordic_atan2 (x, y, atan2_2, hyp_2, 53);
  atan2_D := atan2_1 - atan2_2;
  hyp_D := hyp_1 - hyp_2;
  if atan2_D = hyp_D then ;
end;

end.
