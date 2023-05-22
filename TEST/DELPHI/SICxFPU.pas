unit SICxFPU;

// FPU utils

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

procedure PushFPU (var a1: Double); overload; register;
procedure PopFPU (var a1: Double); overload; register;
procedure PushFPU (var a1, a2: Double); overload; register;
procedure PopFPU (var a1, a2: Double); overload; register;
procedure PushFPU (var a1, a2, a3: Double); overload; register;
procedure PopFPU (var a1, a2, a3: Double); overload; register;
procedure PushFPU (var a1, a2, a3, a4: Double); overload; register;
procedure PopFPU (var a1, a2, a3, a4: Double); overload; register;
procedure PushFPU (var a1, a2, a3, a4, a5: Double); overload; register;
procedure PopFPU (var a1, a2, a3, a4, a5: Double); overload; register;
procedure PushFPU (var a1, a2, a3, a4, a5, a6: Double); overload; register;
procedure PopFPU (var a1, a2, a3, a4, a5, a6: Double); overload; register;
procedure PushFPU (var a1, a2, a3, a4, a5, a6, a7: Double); overload; register;
procedure PopFPU (var a1, a2, a3, a4, a5, a6, a7: Double); overload; register;
procedure PushFPU (var a1, a2, a3, a4, a5, a6, a7, a8: Double); overload; register;
procedure PopFPU (var a1, a2, a3, a4, a5, a6, a7, a8: Double); overload; register;

implementation

{
  push 1 double value onto the FPU register stack
}
procedure PushFPU (var a1: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx |     |
// r8  |     |
// r9  |     |
asm
        fld     qword [rcx]
end;
{$ELSE}
// eax | @a1 |
// edx |     |
// ecx |     |
//     |     |
asm
        fld     qword [eax]
end;
{$ENDIF}

{
  pop 1 double value from the FPU register stack
}
procedure PopFPU (var a1: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx |     |
// r8  |     |
// r9  |     |
asm
        fstp    qword [rcx]
end;
{$ELSE}
// eax | @a1 |
// edx |     |
// ecx |     |
//     |     |
asm
        fstp    qword [eax]
end;
{$ENDIF}

{
  push 2 double values onto the FPU register stack
}
procedure PushFPU (var a1, a2: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  |     |
// r9  |     |
asm
        fld     qword [rcx]
        fld     qword [rdx]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx |     |
//     |     |
asm
        fld     qword [eax]
        fld     qword [edx]
end;
{$ENDIF}

{
  pop 2 double values from the FPU register stack
}
procedure PopFPU (var a1, a2: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  |     |
// r9  |     |
asm
        fstp    qword [rdx]
        fstp    qword [rcx]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx |     |
//     |     |
asm
        fstp    qword [edx]
        fstp    qword [eax]
end;
{$ENDIF}

{
  push 3 double values onto the FPU register stack
}
procedure PushFPU (var a1, a2, a3: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  |     |
asm
        fld     qword [rcx]
        fld     qword [rdx]
        fld     qword [r8]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     |     |
asm
        fld     qword [eax]
        fld     qword [edx]
        fld     qword [ecx]
end;
{$ENDIF}

{
  pop 3 double values from the FPU register stack
}
procedure PopFPU (var a1, a2, a3: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  |     |
asm
        fstp    qword [r8]
        fstp    qword [rdx]
        fstp    qword [rcx]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     |     |
asm
        fstp    qword [ecx]
        fstp    qword [edx]
        fstp    qword [eax]
end;
{$ENDIF}

{
  push 4 double values onto the FPU register stack
}
procedure PushFPU (var a1, a2, a3, a4: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
asm
        fld     qword [rcx]
        fld     qword [rdx]
        fld     qword [r8]
        fld     qword [r9]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
asm
        fld     qword [eax]
        fld     qword [edx]
        fld     qword [ecx]
        mov     ecx, DWORD PTR a4
        fld     qword [ecx]
end;
{$ENDIF}

{
  pop 4 double values from the FPU register stack
}
procedure PopFPU (var a1, a2, a3, a4: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
asm
        fstp    qword [r9]
        fstp    qword [r8]
        fstp    qword [rdx]
        fstp    qword [rcx]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
asm
        push    ecx
        mov     ecx, DWORD PTR a4
        fstp    qword [ecx]
        pop     ecx
        fstp    qword [ecx]
        fstp    qword [edx]
        fstp    qword [eax]
end;
{$ENDIF}

{
  push 5 double values onto the FPU register stack
}
procedure PushFPU (var a1, a2, a3, a4, a5: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
asm
        fld     qword [rcx]
        fld     qword [rdx]
        fld     qword [r8]
        fld     qword [r9]
        mov     r10, QWORD PTR a5
        fld     qword [r10]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
asm
        fld     qword [eax]
        fld     qword [edx]
        fld     qword [ecx]
        mov     ecx, DWORD PTR a4
        fld     qword [ecx]
        mov     ecx, DWORD PTR a5
        fld     qword [ecx]
end;
{$ENDIF}

{
  pop 5 double values from the FPU register stack
}
procedure PopFPU (var a1, a2, a3, a4, a5: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
asm
        mov     r10, QWORD PTR a5
        fstp    qword [r10]
        fstp    qword [r9]
        fstp    qword [r8]
        fstp    qword [rdx]
        fstp    qword [rcx]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
asm
        push    ecx
        mov     ecx, DWORD PTR a5
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a4
        fstp    qword [ecx]
        pop     ecx
        fstp    qword [ecx]
        fstp    qword [edx]
        fstp    qword [eax]
end;
{$ENDIF}

{
  push 6 double values onto the FPU register stack
}
procedure PushFPU (var a1, a2, a3, a4, a5, a6: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
//     | @a6 |
asm
        fld     qword [rcx]
        fld     qword [rdx]
        fld     qword [r8]
        fld     qword [r9]
        mov     r10, QWORD PTR a5
        fld     qword [r10]
        mov     r10, QWORD PTR a6
        fld     qword [r10]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
//     | @a6 |
asm
        fld     qword [eax]
        fld     qword [edx]
        fld     qword [ecx]
        mov     ecx, DWORD PTR a4
        fld     qword [ecx]
        mov     ecx, DWORD PTR a5
        fld     qword [ecx]
        mov     ecx, DWORD PTR a6
        fld     qword [ecx]
end;
{$ENDIF}

{
  pop 6 double values from the FPU register stack
}
procedure PopFPU (var a1, a2, a3, a4, a5, a6: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
//     | @a6 |
asm
        mov     r10, QWORD PTR a6
        fstp    qword [r10]
        mov     r10, QWORD PTR a5
        fstp    qword [r10]
        fstp    qword [r9]
        fstp    qword [r8]
        fstp    qword [rdx]
        fstp    qword [rcx]
end;
{$ELSE}
// eax | @a1 |
// edx | @a2 |
// ecx | @a3 |
//     | @a4 |
//     | @a5 |
//     | @a6 |
asm
        push    ecx
        mov     ecx, DWORD PTR a6
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a5
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a4
        fstp    qword [ecx]
        pop     ecx
        fstp    qword [ecx]
        fstp    qword [edx]
        fstp    qword [eax]
end;
{$ENDIF}

{
  push 7 double values onto the FPU register stack
}
procedure PushFPU (var a1, a2, a3, a4, a5, a6, a7: Double); register;
{$IFDEF CPUX64}
// rcx | @a1 |
// rdx | @a2 |
// r8  | @a3 |
// r9  | @a4 |
//     | @a5 |
//     | @a6 |
//     | @a7 |
asm
        fld     qword [rcx]
        fld     qword [rdx]
        fld     qword [r8]
        fld     qword [r9]
        mov     r10, QWORD PTR a5
        fld     qword [r10]
        mov     r10, QWORD PTR a6
        fld     qword [r10]
        mov     r10, QWORD PTR a7
        fld     qword [r10]
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
        fld     qword [eax]
        fld     qword [edx]
        fld     qword [ecx]
        mov     ecx, DWORD PTR a4
        fld     qword [ecx]
        mov     ecx, DWORD PTR a5
        fld     qword [ecx]
        mov     ecx, DWORD PTR a6
        fld     qword [ecx]
        mov     ecx, DWORD PTR a7
        fld     qword [ecx]
end;
{$ENDIF}

{
  pop 7 double values from the FPU register stack
}
procedure PopFPU (var a1, a2, a3, a4, a5, a6, a7: Double); register;
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
        fstp    qword [r10]
        mov     r10, QWORD PTR a6
        fstp    qword [r10]
        mov     r10, QWORD PTR a5
        fstp    qword [r10]
        fstp    qword [r9]
        fstp    qword [r8]
        fstp    qword [rdx]
        fstp    qword [rcx]
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
        push    ecx
        mov     ecx, DWORD PTR a7
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a6
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a5
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a4
        fstp    qword [ecx]
        pop     ecx
        fstp    qword [ecx]
        fstp    qword [edx]
        fstp    qword [eax]
end;
{$ENDIF}

{
  push 8 double values onto the FPU register stack
}
procedure PushFPU (var a1, a2, a3, a4, a5, a6, a7, a8: Double); register;
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
        fld     qword [rcx]
        fld     qword [rdx]
        fld     qword [r8]
        fld     qword [r9]
        mov     r10, QWORD PTR a5
        fld     qword [r10]
        mov     r10, QWORD PTR a6
        fld     qword [r10]
        mov     r10, QWORD PTR a7
        fld     qword [r10]
        mov     r10, QWORD PTR a8
        fld     qword [r10]
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
        fld     qword [eax]
        fld     qword [edx]
        fld     qword [ecx]
        mov     ecx, DWORD PTR a4
        fld     qword [ecx]
        mov     ecx, DWORD PTR a5
        fld     qword [ecx]
        mov     ecx, DWORD PTR a6
        fld     qword [ecx]
        mov     ecx, DWORD PTR a7
        fld     qword [ecx]
        mov     ecx, DWORD PTR a8
        fld     qword [ecx]
end;
{$ENDIF}

{
  pop 5 double values from the FPU register stack
}
procedure PopFPU (var a1, a2, a3, a4, a5, a6, a7, a8: Double); register;
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
        fstp    qword [r10]
        mov     r10, QWORD PTR a7
        fstp    qword [r10]
        mov     r10, QWORD PTR a6
        fstp    qword [r10]
        mov     r10, QWORD PTR a5
        fstp    qword [r10]
        fstp    qword [r9]
        fstp    qword [r8]
        fstp    qword [rdx]
        fstp    qword [rcx]
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
        push    ecx
        mov     ecx, DWORD PTR a8
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a7
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a6
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a5
        fstp    qword [ecx]
        mov     ecx, DWORD PTR a4
        fstp    qword [ecx]
        pop     ecx
        fstp    qword [ecx]
        fstp    qword [edx]
        fstp    qword [eax]
end;
{$ENDIF}

end.

