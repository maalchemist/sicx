unit SICxSSE;

// SSE utils

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

{$DEFINE __SSE}
{$IFDEF VER120} {$UNDEF __SSE} {$ENDIF} // Delphi 4.0

interface

procedure PushSSE (var a1: Double); overload; register;
procedure PopSSE (var a1: Double); overload; register;
procedure PushSSE (var a1, a2: Double); overload; register;
procedure PopSSE (var a1, a2: Double); overload; register;
procedure PushSSE (var a1, a2, a3: Double); overload; register;
procedure PopSSE (var a1, a2, a3: Double); overload; register;
procedure PushSSE (var a1, a2, a3, a4: Double); overload; register;
procedure PopSSE (var a1, a2, a3, a4: Double); overload; register;
procedure PushSSE (var a1, a2, a3, a4, a5: Double); overload; register;
procedure PopSSE (var a1, a2, a3, a4, a5: Double); overload; register;
procedure PushSSE (var a1, a2, a3, a4, a5, a6: Double); overload; register;
procedure PopSSE (var a1, a2, a3, a4, a5, a6: Double); overload; register;
procedure PushSSE (var a1, a2, a3, a4, a5, a6, a7: Double); overload; register;
procedure PopSSE (var a1, a2, a3, a4, a5, a6, a7: Double); overload; register;
procedure PushSSE (var a1, a2, a3, a4, a5, a6, a7, a8: Double); overload; register;
procedure PopSSE (var a1, a2, a3, a4, a5, a6, a7, a8: Double); overload; register;

implementation

{
  push 1 double value onto the SSE registers
}
procedure PushSSE (var a1: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx |     |
// r8  |     |
// r9  |     |
asm
        movsd   xmm0, qword [rcx]
end;
{$ELSE}
// eax | @a1 |
// edx |     |
// ecx |     |
//     |     |
asm
        {$IFDEF __SSE}
        movsd   xmm0, qword [eax]
        {$ELSE}
        DB      $F2,$0F,$10,$00         // movsd   xmm0, qword [eax]
        {$ENDIF}
end;
{$ENDIF}

{
  pop 1 double value from the SSE registers
}
procedure PopSSE (var a1: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx |     |
// r8  |     |
// r9  |     |
asm
        movsd   qword [rcx], xmm0
end;
{$ELSE}
// eax | @a1 |
// edx |     |
// ecx |     |
//     |     |
asm
        {$IFDEF __SSE}
        movsd   qword [eax], xmm0
        {$ELSE}
        DB      $F2,$0F,$11,$00         // movsd   qword [eax], xmm0
        {$ENDIF}
end;
{$ENDIF}

{
  push 2 double values onto the SSE registers
}
procedure PushSSE (var a1, a2: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  |     |
// r9  |     |
asm
        movsd   xmm0, qword [rcx]
        movsd   xmm1, qword [rdx]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx |     |
//     |     |
asm
        {$IFDEF __SSE}
        movsd   xmm0, qword [eax]
        movsd   xmm1, qword [edx]
        {$ELSE}
        DB      $F2,$0F,$10,$00         // movsd   xmm0, qword [eax]
        DB      $F2,$0F,$10,$0A         // movsd   xmm1, qword [edx]
        {$ENDIF}
end;
{$ENDIF}

{
  pop 2 double values from the SSE registers
}
procedure PopSSE (var a1, a2: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  |     |
// r9  |     |
asm
        movsd   qword [rdx], xmm1
        movsd   qword [rcx], xmm0
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx |     |
//     |     |
asm
        {$IFDEF __SSE}
        movsd   qword [edx], xmm1
        movsd   qword [eax], xmm0
        {$ELSE}
        DB      $F2,$0F,$11,$0A         // movsd   qword [edx], xmm1
        DB      $F2,$0F,$11,$00         // movsd   qword [eax], xmm0
        {$ENDIF}
end;
{$ENDIF}

{
  push 3 double values onto the SSE registers
}
procedure PushSSE (var a1, a2, a3: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  |     |
asm
        movsd   xmm0, qword [rcx]
        movsd   xmm1, qword [rdx]
        movsd   xmm2, qword [r8]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     |     |
asm
        {$IFDEF __SSE}
        movsd   xmm0, qword [eax]
        movsd   xmm1, qword [edx]
        movsd   xmm2, qword [ecx]
        {$ELSE}
        DB      $F2,$0F,$10,$00         // movsd   xmm0, qword [eax]
        DB      $F2,$0F,$10,$0A         // movsd   xmm1, qword [edx]
        DB      $F2,$0F,$10,$11         // movsd   xmm2, qword [ecx]
        {$ENDIF}
end;
{$ENDIF}

{
  pop 3 double values from the SSE registers
}
procedure PopSSE (var a1, a2, a3: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  |     |
asm
        movsd   qword [r8], xmm2
        movsd   qword [rdx], xmm1
        movsd   qword [rcx], xmm0
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     |     |
asm
        {$IFDEF __SSE}
        movsd   qword [ecx], xmm2
        movsd   qword [edx], xmm1
        movsd   qword [eax], xmm0
        {$ELSE}
        DB      $F2,$0F,$11,$11         // movsd   qword [ecx], xmm2
        DB      $F2,$0F,$11,$0A         // movsd   qword [edx], xmm1
        DB      $F2,$0F,$11,$00         // movsd   qword [eax], xmm0
        {$ENDIF}
end;
{$ENDIF}

{
  push 4 double values onto the SSE registers
}
procedure PushSSE (var a1, a2, a3, a4: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
asm
        movsd   xmm0, qword [rcx]
        movsd   xmm1, qword [rdx]
        movsd   xmm2, qword [r8]
        movsd   xmm3, qword [r9]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
asm
        {$IFDEF __SSE}
        movsd   xmm0, qword [eax]
        movsd   xmm1, qword [edx]
        movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        movsd   xmm3, qword [ecx]
        {$ELSE}
        DB      $F2,$0F,$10,$00         // movsd   xmm0, qword [eax]
        DB      $F2,$0F,$10,$0A         // movsd   xmm1, qword [edx]
        DB      $F2,$0F,$10,$11         // movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        DB      $F2,$0F,$10,$19         // movsd   xmm3, qword [ecx]
        {$ENDIF}
end;
{$ENDIF}

{
  pop 4 double values from the SSE registers
}
procedure PopSSE (var a1, a2, a3, a4: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
asm
        movsd   qword [r9], xmm3
        movsd   qword [r8], xmm2
        movsd   qword [rdx], xmm1
        movsd   qword [rcx], xmm0
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
asm
        {$IFDEF __SSE}
        push    ecx
        mov     ecx, DWORD PTR a4
        movsd   qword [ecx], xmm3
        pop     ecx
        movsd   qword [ecx], xmm2
        movsd   qword [edx], xmm1
        movsd   qword [eax], xmm0
        {$ELSE}
        push    ecx
        mov     ecx, DWORD PTR a4
        DB      $F2,$0F,$11,$19         // movsd   qword [ecx], xmm3
        pop     ecx
        DB      $F2,$0F,$11,$11         // movsd   qword [ecx], xmm2
        DB      $F2,$0F,$11,$0A         // movsd   qword [edx], xmm1
        DB      $F2,$0F,$11,$00         // movsd   qword [eax], xmm0
        {$ENDIF}
end;
{$ENDIF}

{
  push 5 double values onto the SSE registers
}
procedure PushSSE (var a1, a2, a3, a4, a5: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
asm
        movsd   xmm0, qword [rcx]
        movsd   xmm1, qword [rdx]
        movsd   xmm2, qword [r8]
        movsd   xmm3, qword [r9]
        mov     r10, QWORD PTR a5
        movsd   xmm4, qword [r10]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
asm
        {$IFDEF __SSE}
        movsd   xmm0, qword [eax]
        movsd   xmm1, qword [edx]
        movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        movsd   xmm3, qword [ecx]
        mov     ecx, DWORD PTR a5
        movsd   xmm4, qword [ecx]
        {$ELSE}
        DB      $F2,$0F,$10,$00         // movsd   xmm0, qword [eax]
        DB      $F2,$0F,$10,$0A         // movsd   xmm1, qword [edx]
        DB      $F2,$0F,$10,$11         // movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        DB      $F2,$0F,$10,$19         // movsd   xmm3, qword [ecx]
        mov     ecx, DWORD PTR a5
        DB      $F2,$0F,$10,$21         // movsd   xmm4, qword [ecx]
        {$ENDIF}
end;
{$ENDIF}

{
  pop 5 double values from the SSE registers
}
procedure PopSSE (var a1, a2, a3, a4, a5: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
asm
        mov     r10, QWORD PTR a5
        movsd   qword [r10], xmm4
        movsd   qword [r9], xmm3
        movsd   qword [r8], xmm2
        movsd   qword [rdx], xmm1
        movsd   qword [rcx], xmm0
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
asm
        {$IFDEF __SSE}
        push    ecx
        mov     ecx, DWORD PTR a5
        movsd   qword [ecx], xmm4
        mov     ecx, DWORD PTR a4
        movsd   qword [ecx], xmm3
        pop     ecx
        movsd   qword [ecx], xmm2
        movsd   qword [edx], xmm1
        movsd   qword [eax], xmm0
        {$ELSE}
        push    ecx
        mov     ecx, DWORD PTR a5
        DB      $F2,$0F,$11,$21         // movsd   qword [ecx], xmm4
        mov     ecx, DWORD PTR a4
        DB      $F2,$0F,$11,$19         // movsd   qword [ecx], xmm3
        pop     ecx
        DB      $F2,$0F,$11,$11         // movsd   qword [ecx], xmm2
        DB      $F2,$0F,$11,$0A         // movsd   qword [edx], xmm1
        DB      $F2,$0F,$11,$00         // movsd   qword [eax], xmm0
        {$ENDIF}
end;
{$ENDIF}

{
  push 6 double values onto the SSE registers
}
procedure PushSSE (var a1, a2, a3, a4, a5, a6: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
//     | @a6 |
asm
        movsd   xmm0, qword [rcx]
        movsd   xmm1, qword [rdx]
        movsd   xmm2, qword [r8]
        movsd   xmm3, qword [r9]
        mov     r10, QWORD PTR a5
        movsd   xmm4, qword [r10]
        mov     r10, QWORD PTR a6
        movsd   xmm5, qword [r10]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
//     | @a6 |
asm
        {$IFDEF __SSE}
        movsd   xmm0, qword [eax]
        movsd   xmm1, qword [edx]
        movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        movsd   xmm3, qword [ecx]
        mov     ecx, DWORD PTR a5
        movsd   xmm4, qword [ecx]
        mov     ecx, DWORD PTR a6
        movsd   xmm5, qword [ecx]
        {$ELSE}
        DB      $F2,$0F,$10,$00         // movsd   xmm0, qword [eax]
        DB      $F2,$0F,$10,$0A         // movsd   xmm1, qword [edx]
        DB      $F2,$0F,$10,$11         // movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        DB      $F2,$0F,$10,$19         // movsd   xmm3, qword [ecx]
        mov     ecx, DWORD PTR a5
        DB      $F2,$0F,$10,$21         // movsd   xmm4, qword [ecx]
        mov     ecx, DWORD PTR a6
        DB      $F2,$0F,$10,$29         // movsd   xmm5, qword [ecx]
        {$ENDIF}
end;
{$ENDIF}

{
  pop 6 double values from the SSE registers
}
procedure PopSSE (var a1, a2, a3, a4, a5, a6: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
//     | @a6 |
asm
        mov     r10, QWORD PTR a6
        movsd   qword [r10], xmm5
        mov     r10, QWORD PTR a5
        movsd   qword [r10], xmm4
        movsd   qword [r9], xmm3
        movsd   qword [r8], xmm2
        movsd   qword [rdx], xmm1
        movsd   qword [rcx], xmm0
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
//     | @a6 |
asm
        {$IFDEF __SSE}
        push    ecx
        mov     ecx, DWORD PTR a6
        movsd   qword [ecx], xmm5
        mov     ecx, DWORD PTR a5
        movsd   qword [ecx], xmm4
        mov     ecx, DWORD PTR a4
        movsd   qword [ecx], xmm3
        pop     ecx
        movsd   qword [ecx], xmm2
        movsd   qword [edx], xmm1
        movsd   qword [eax], xmm0
        {$ELSE}
        push    ecx
        mov     ecx, DWORD PTR a6
        DB      $F2,$0F,$11,$29         // movsd   qword [ecx], xmm5
        mov     ecx, DWORD PTR a5
        DB      $F2,$0F,$11,$21         // movsd   qword [ecx], xmm4
        mov     ecx, DWORD PTR a4
        DB      $F2,$0F,$11,$19         // movsd   qword [ecx], xmm3
        pop     ecx
        DB      $F2,$0F,$11,$11         // movsd   qword [ecx], xmm2
        DB      $F2,$0F,$11,$0A         // movsd   qword [edx], xmm1
        DB      $F2,$0F,$11,$00         // movsd   qword [eax], xmm0
        {$ENDIF}
end;
{$ENDIF}

{
  push 7 double values onto the SSE registers
}
procedure PushSSE (var a1, a2, a3, a4, a5, a6, a7: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
//     | @a6 |
//     | @a7 |
asm
        movsd   xmm0, qword [rcx]
        movsd   xmm1, qword [rdx]
        movsd   xmm2, qword [r8]
        movsd   xmm3, qword [r9]
        mov     r10, QWORD PTR a5
        movsd   xmm4, qword [r10]
        mov     r10, QWORD PTR a6
        movsd   xmm5, qword [r10]
        mov     r10, QWORD PTR a7
        movsd   xmm6, qword [r10]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
//     | @a6 |
//     | @a7 |
asm
        {$IFDEF __SSE}
        movsd   xmm0, qword [eax]
        movsd   xmm1, qword [edx]
        movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        movsd   xmm3, qword [ecx]
        mov     ecx, DWORD PTR a5
        movsd   xmm4, qword [ecx]
        mov     ecx, DWORD PTR a6
        movsd   xmm5, qword [ecx]
        mov     ecx, DWORD PTR a7
        movsd   xmm6, qword [ecx]
        {$ELSE}
        DB      $F2,$0F,$10,$00         // movsd   xmm0, qword [eax]
        DB      $F2,$0F,$10,$0A         // movsd   xmm1, qword [edx]
        DB      $F2,$0F,$10,$11         // movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        DB      $F2,$0F,$10,$19         // movsd   xmm3, qword [ecx]
        mov     ecx, DWORD PTR a5
        DB      $F2,$0F,$10,$21         // movsd   xmm4, qword [ecx]
        mov     ecx, DWORD PTR a6
        DB      $F2,$0F,$10,$29         // movsd   xmm5, qword [ecx]
        mov     ecx, DWORD PTR a7
        DB      $F2,$0F,$10,$31         // movsd   xmm6, qword [ecx]
        {$ENDIF}
end;
{$ENDIF}

{
  pop 7 double values from the SSE registers
}
procedure PopSSE (var a1, a2, a3, a4, a5, a6, a7: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
//     | @a6 |
//     | @a7 |
asm
        mov     r10, QWORD PTR a7
        movsd   qword [r10], xmm6
        mov     r10, QWORD PTR a6
        movsd   qword [r10], xmm5
        mov     r10, QWORD PTR a5
        movsd   qword [r10], xmm4
        movsd   qword [r9], xmm3
        movsd   qword [r8], xmm2
        movsd   qword [rdx], xmm1
        movsd   qword [rcx], xmm0
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
//     | @a6 |
//     | @a7 |
asm
        {$IFDEF __SSE}
        push    ecx
        mov     ecx, DWORD PTR a7
        movsd   qword [ecx], xmm6
        mov     ecx, DWORD PTR a6
        movsd   qword [ecx], xmm5
        mov     ecx, DWORD PTR a5
        movsd   qword [ecx], xmm4
        mov     ecx, DWORD PTR a4
        movsd   qword [ecx], xmm3
        pop     ecx
        movsd   qword [ecx], xmm2
        movsd   qword [edx], xmm1
        movsd   qword [eax], xmm0
        {$ELSE}
        push    ecx
        mov     ecx, DWORD PTR a7
        DB      $F2,$0F,$11,$31         // movsd   qword [ecx], xmm6
        mov     ecx, DWORD PTR a6
        DB      $F2,$0F,$11,$29         // movsd   qword [ecx], xmm5
        mov     ecx, DWORD PTR a5
        DB      $F2,$0F,$11,$21         // movsd   qword [ecx], xmm4
        mov     ecx, DWORD PTR a4
        DB      $F2,$0F,$11,$19         // movsd   qword [ecx], xmm3
        pop     ecx
        DB      $F2,$0F,$11,$11         // movsd   qword [ecx], xmm2
        DB      $F2,$0F,$11,$0A         // movsd   qword [edx], xmm1
        DB      $F2,$0F,$11,$00         // movsd   qword [eax], xmm0
        {$ENDIF}
end;
{$ENDIF}

{
  push 8 double values onto the SSE registers
}
procedure PushSSE (var a1, a2, a3, a4, a5, a6, a7, a8: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
//     | @a6 |
//     | @a7 |
//     | @a8 |
asm
        movsd   xmm0, qword [rcx]
        movsd   xmm1, qword [rdx]
        movsd   xmm2, qword [r8]
        movsd   xmm3, qword [r9]
        mov     r10, QWORD PTR a5
        movsd   xmm4, qword [r10]
        mov     r10, QWORD PTR a6
        movsd   xmm5, qword [r10]
        mov     r10, QWORD PTR a7
        movsd   xmm6, qword [r10]
        mov     r10, QWORD PTR a8
        movsd   xmm7, qword [r10]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
//     | @a6 |
//     | @a7 |
//     | @a8 |
asm
        {$IFDEF __SSE}
        movsd   xmm0, qword [eax]
        movsd   xmm1, qword [edx]
        movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        movsd   xmm3, qword [ecx]
        mov     ecx, DWORD PTR a5
        movsd   xmm4, qword [ecx]
        mov     ecx, DWORD PTR a6
        movsd   xmm5, qword [ecx]
        mov     ecx, DWORD PTR a7
        movsd   xmm6, qword [ecx]
        mov     ecx, DWORD PTR a8
        movsd   xmm7, qword [ecx]
        {$ELSE}
        DB      $F2,$0F,$10,$00         // movsd   xmm0, qword [eax]
        DB      $F2,$0F,$10,$0A         // movsd   xmm1, qword [edx]
        DB      $F2,$0F,$10,$11         // movsd   xmm2, qword [ecx]
        mov     ecx, DWORD PTR a4
        DB      $F2,$0F,$10,$19         // movsd   xmm3, qword [ecx]
        mov     ecx, DWORD PTR a5
        DB      $F2,$0F,$10,$21         // movsd   xmm4, qword [ecx]
        mov     ecx, DWORD PTR a6
        DB      $F2,$0F,$10,$29         // movsd   xmm5, qword [ecx]
        mov     ecx, DWORD PTR a7
        DB      $F2,$0F,$10,$31         // movsd   xmm6, qword [ecx]
        mov     ecx, DWORD PTR a8
        DB      $F2,$0F,$10,$39         // movsd   xmm7, qword [ecx]
        {$ENDIF}
end;
{$ENDIF}

{
  pop 5 double values from the SSE registers
}
procedure PopSSE (var a1, a2, a3, a4, a5, a6, a7, a8: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
//     | @a6 |
//     | @a7 |
//     | @a8 |
asm
        mov     r10, QWORD PTR a8
        movsd   qword [r10], xmm7
        mov     r10, QWORD PTR a7
        movsd   qword [r10], xmm6
        mov     r10, QWORD PTR a6
        movsd   qword [r10], xmm5
        mov     r10, QWORD PTR a5
        movsd   qword [r10], xmm4
        movsd   qword [r9], xmm3
        movsd   qword [r8], xmm2
        movsd   qword [rdx], xmm1
        movsd   qword [rcx], xmm0
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
//     | @a6 |
//     | @a7 |
//     | @a8 |
asm
        {$IFDEF __SSE}
        push    ecx
        mov     ecx, DWORD PTR a8
        movsd   qword [ecx], xmm7
        mov     ecx, DWORD PTR a7
        movsd   qword [ecx], xmm6
        mov     ecx, DWORD PTR a6
        movsd   qword [ecx], xmm5
        mov     ecx, DWORD PTR a5
        movsd   qword [ecx], xmm4
        mov     ecx, DWORD PTR a4
        movsd   qword [ecx], xmm3
        pop     ecx
        movsd   qword [ecx], xmm2
        movsd   qword [edx], xmm1
        movsd   qword [eax], xmm0
        {$ELSE}
        push    ecx
        mov     ecx, DWORD PTR a8
        DB $F2,$0F,$11,$39              // movsd   qword [ecx], xmm7
        mov     ecx, DWORD PTR a7
        DB $F2,$0F,$11,$31              // movsd   qword [ecx], xmm6
        mov     ecx, DWORD PTR a6
        DB $F2,$0F,$11,$29              // movsd   qword [ecx], xmm5
        mov     ecx, DWORD PTR a5
        DB $F2,$0F,$11,$21              // movsd   qword [ecx], xmm4
        mov     ecx, DWORD PTR a4
        DB $F2,$0F,$11,$19              // movsd   qword [ecx], xmm3
        pop     ecx
        DB $F2,$0F,$11,$11              // movsd   qword [ecx], xmm2
        DB $F2,$0F,$11,$0A              // movsd   qword [edx], xmm1
        DB $F2,$0F,$11,$00              // movsd   qword [eax], xmm0
        {$ENDIF}
end;
{$ENDIF}

{
  F2 0F 10 00        movsd       xmm0,mmword ptr [eax]
  F2 0F 10 0A        movsd       xmm1,mmword ptr [edx]
  F2 0F 10 11        movsd       xmm2,mmword ptr [ecx]
  F2 0F 10 19        movsd       xmm3,mmword ptr [ecx]
  F2 0F 10 21        movsd       xmm4,mmword ptr [ecx]
  F2 0F 10 29        movsd       xmm5,mmword ptr [ecx]
  F2 0F 10 31        movsd       xmm6,mmword ptr [ecx]
  F2 0F 10 39        movsd       xmm7,mmword ptr [ecx]

  F2 0F 11 39        movsd       mmword ptr [ecx],xmm7
  F2 0F 11 31        movsd       mmword ptr [ecx],xmm6
  F2 0F 11 29        movsd       mmword ptr [ecx],xmm5
  F2 0F 11 21        movsd       mmword ptr [ecx],xmm4
  F2 0F 11 19        movsd       mmword ptr [ecx],xmm3
  F2 0F 11 11        movsd       mmword ptr [ecx],xmm2
  F2 0F 11 0A        movsd       mmword ptr [edx],xmm1
  F2 0F 11 00        movsd       mmword ptr [eax],xmm0
}

end.

