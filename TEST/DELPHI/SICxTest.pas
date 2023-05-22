unit SICxTest;

// SICx test functions

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

{$I version.inc}

{$IFDEF FPC} // Lazarus
  {$ASMMODE INTEL}
{$ENDIF}

interface

uses
  Windows, SysUtils,
  {$IFDEF SIC_OCX}
  {$IFDEF CPUX64} SICx64_TLB, {$ELSE} SICx32_TLB, {$ENDIF}
  {$ELSE}
  SICxTypes,
  {$IFDEF SIC_DYNAMIC} SICxDProcs, {$ELSE} SICxProcs, {$ENDIF}
  {$ENDIF}
  SICxDefs;

procedure X5FPU;
procedure X5SSE;

function  is_even_(D: Double): Integer;
function  fra_po_(x, y: Double): Double;

implementation

uses
  SICxFPU, SICxSSE;

{
}
procedure X5FPU;
var
  v1, v2, v3, v4, v5: Double;
  u1, u2, u3, u4, u5: Double;
begin
  v1 := 1;
  v2 := 2;
  v3 := 3;
  v4 := 4;
  v5 := 5;
  u1 := 8;
  u2 := 8;
  u3 := 8;
  u4 := 8;
  u5 := 8;

  PushFPU (v1, v2, v3, v4, v5);
  PopFPU (u1, u2, u3, u4, u5);
end;

{
}
procedure X5SSE;
var
  v1, v2, v3, v4, v5: Double;
  u1, u2, u3, u4, u5: Double;
begin
  v1 := 1;
  v2 := 2;
  v3 := 3;
  v4 := 4;
  v5 := 5;
  u1 := 8;
  u2 := 8;
  u3 := 8;
  u4 := 8;
  u5 := 8;

  PushSSE (v1, v2, v3, v4, v5);
  PopSSE (u1, u2, u3, u4, u5);
end;

{
  D is even - Result <> 0
  D is odd  - Result == 0
}
function is_even_(D: Double): Integer;
asm
{$IFDEF CPUX64}
    movq rax, xmm0
    mov  rdx, rax
    shr  rax, 52
    and  rax, $7FF
    jnz  @E
@Denorm:
    inc  rax
@E:
    sub  rax, 1023 // rax = exponent

@D:
    mov  r10, $000FFFFFFFFFFFFF
    and  rdx, r10 // rdx = mantissa
    bsf  rdx, rdx
    jz   @R
    sub  rdx, 52

@R:
    add  rax, rdx
{$ELSE}
    mov  eax, [esp + 12] // eax = D.HI
    shr  eax, 20
    and  eax, $7FF
    jnz  @E
@Denorm:
    inc  eax
@E:
    sub  eax, 1023 // eax = exponent

@D_LO:
    mov  edx, [esp + 8] // edx = mantissa.LO
    bsf  edx, edx
    jz   @D_HI
    sub  edx, 52
    jmp  @R

@D_HI:
    mov  edx, [esp + 12]
    and  edx, $000FFFFF // edx = mantissa.HI
    bsf  edx, edx
    jz   @R
    sub  edx, 20

@R:
    add  eax, edx
{$ENDIF}
end;

var
  C_1_0 : Double = 1.0;

// x^y, |y| < 1
function fra_po_(x, y: Double): Double;
{$IFDEF CPUX64}
asm
        movq    rax, xmm1
        mov     rdx, rax
        mov     rcx, rax
        shl     rax, 12

    @A:
        shr     rcx, 64-12
        and     rcx, $07FF
        cmp     rcx, 1023-63
        jae     @A8                             // jump if |y| >= 2^(-63)
    @A2:
        movsd   xmm0, C_1_0                     // |y| < 2^(-63) | x^y = 1
        jmp     @leave
    @A8:
        sub     rcx, 1023

    @B:
        test    rdx, rdx
        jns     @B8
        movsd   xmm1, xmm0
        movsd   xmm0, C_1_0
        divsd   xmm0, xmm1                      // xmm0 = 1/x
    @B8:

    @D:
        sqrtsd  xmm0, xmm0
        inc     rcx
        jnz     @D

        sqrtsd  xmm1, xmm0
        jmp     @2
    @1:
        sqrtsd  xmm1, xmm1
    @2: shl     rax, 1
        jnc     @1
        mulsd   xmm0, xmm1
        jnz     @1

    @leave:
end;
{
asm
        pextrd  eax, xmm1, 1                    // eax = y.HI
        pextrd  edx, xmm1, 0                    // edx = y.LO
//      movd    edx, xmm1                       // edx = y.LO
        mov     ecx, eax
        shld    eax, edx, 12
        shl     edx, 12

    @B:
        test    ecx, ecx
        jns     @B8
        movsd   xmm1, xmm0
        movsd   xmm0, C_1_0
        divsd   xmm0, xmm1                      // xmm0 = 1/x
    @B8:

    @A:
        shr     ecx, 32-12
        and     ecx, $07FF
        cmp     ecx, 1023-63
        jae     @A8                             // jump if |y| >= 2^(-63)
    @A2:
        movsd   xmm0, C_1_0                     // |y| < 2^(-63) | x^y = 1
        jmp     @leave
    @A8:
        sub     ecx, 1023

    @D:
        sqrtsd  xmm0, xmm0
        inc     ecx
        jnz     @D

        sqrtsd  xmm1, xmm0
        jmp     @2
    @1:
        sqrtsd  xmm1, xmm1
    @2: shl     eax, 1
        jnc     @1
        mulsd   xmm0, xmm1
        jnz     @1

        test    edx, edx
        jz      @assign
    @3:
        sqrtsd  xmm1, xmm1
    @4: shl     edx, 1
        jnc     @3
        mulsd   xmm0, xmm1
        jnz     @3

    @assign:
    @leave:
end;
}
{$ELSE}
asm
        mov     eax, [ebp + 12] // eax = y.HI
        mov     edx, [ebp + 08] // edx = y.LO
        mov     ecx, eax
        shld    eax, edx, 12
        shl     edx, 12

        fld     qword ptr [ebp + 16]            // load x
    @B:
        test    ecx, ecx
        jns     @B8
        fld1
        fdivrp                                  // st0 = 1/x
    @B8:

    @A:
        shr     ecx, 32-12
        and     ecx, $07FF
        cmp     ecx, 1023-63
        jae     @A8                             // jump if |y| >= 2^(-63)
    @A2:
        fstp    st(0)
        fld1                                    // |y| < 2^(-63) | x^y = 1
        jmp     @leave
    @A8:
        sub     ecx, 1023

    @D:
        fsqrt
        inc     ecx
        jnz     @D

        fld     st(0)
        fsqrt
        jmp     @2
    @1:
        fsqrt
    @2: shl     eax, 1
        jnc     @1
        fmul    st(1), st(0)
        jnz     @1

        test    edx, edx
        jz      @assign
    @3:
        fsqrt
    @4: shl     edx, 1
        jnc     @3
        fmul    st(1), st(0)
        jnz     @3

    @assign:
        fstp    st(0)

    @leave:
end;
{$ENDIF}

end.
