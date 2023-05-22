
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; export functions macros

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; DV - double value
; DO - double offset
; IV - integer value
; IO - integer offset

; ------------------------------------------------------------------------------

macro @@.sic_proc.save.xmm6.xmm7
{
    $ifdef _X64
        movdqa  dqword [.xmm6], xmm6
        movdqa  dqword [.xmm7], xmm7
    $else
        movdqu  dqword [.xmm6], xmm6
        movdqu  dqword [.xmm7], xmm7
    $end
}

macro @@.sic_proc.restore.xmm6.xmm7
{
    $ifdef _X64
        movdqa  xmm6, dqword [.xmm6]
        movdqa  xmm7, dqword [.xmm7]
    $else
        movdqu  xmm6, dqword [.xmm6]
        movdqu  xmm7, dqword [.xmm7]
    $end
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

macro @@.sic_proc.DV.sse.64 @proc
{
    locals
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
    endl

        push    rbx rdi
        @@.sic_proc.save.xmm6.xmm7              ; built-in functions can modify xmm6, xmm7 registers

        call    @proc

        @@.sic_proc.restore.xmm6.xmm7
        pop     rdi rbx
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.sic_proc.DV.sse.32 @proc
{
    locals
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
       .mem     dq 2 dup ?
    endl

        push    ebx edi
        @@.sic_proc.save.xmm6.xmm7              ; built-in functions can modify xmm6, xmm7 registers

        movsd   xmm0, qword [ebp + 8]
        call    @proc

        movsd   qword [.mem], xmm0
        fld     qword [.mem]

        @@.sic_proc.restore.xmm6.xmm7
        pop     edi ebx
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.sic_proc.DV.fpu.64 @proc
{
    locals
       .mem     dq 2 dup ?
    endl

        push    rbx rdi

        movsd   [.mem], xmm0
        fld     qword [.mem]
        call    @proc

        fstp    qword [.mem]
        movsd   xmm0, qword [.mem]

        pop     rdi rbx
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.sic_proc.DV.fpu.32 @proc
{
        push    ebx edi

        fld     qword [ebp + 8]
        call    @proc

        pop     edi ebx
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

macro @@.sic_proc.DV.DV.sse.64 @proc
{
    locals
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
    endl

        push    rbx rdi
        @@.sic_proc.save.xmm6.xmm7              ; built-in functions can modify xmm6, xmm7 registers

        call    @proc

        @@.sic_proc.restore.xmm6.xmm7
        pop     rdi rbx
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.sic_proc.DV.DV.sse.32 @proc
{
    locals
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
       .mem     dq 2 dup ?
    endl

        push    ebx edi
        @@.sic_proc.save.xmm6.xmm7              ; built-in functions can modify xmm6, xmm7 registers

        movsd   xmm0, qword [ebp + 8]
        movsd   xmm1, qword [ebp + 16]
        call    @proc

        movsd   qword [.mem], xmm0
        fld     qword [.mem]

        @@.sic_proc.restore.xmm6.xmm7
        pop     edi ebx
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.sic_proc.DV.DV.fpu.64 @proc
{
    locals
       .mem     dq 2 dup ?
    endl

        push    rbx rdi

        movsd   [.mem], xmm0
        fld     qword [.mem]
        movsd   [.mem], xmm1
        fld     qword [.mem]
        call    @proc

        fstp    qword [.mem]
        movsd   xmm0, qword [.mem]

        pop     rdi rbx
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.sic_proc.DV.DV.fpu.32 @proc
{
        push    ebx edi

        fld     qword [ebp + 8]
        fld     qword [ebp + 16]
        call    @proc

        pop     edi ebx
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

macro @@.sic_proc.DV.IO.sse.64 @proc, @IO.reg
{
    locals
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
    endl

        push    rbx rdi
        @@.sic_proc.save.xmm6.xmm7              ; built-in functions can modify xmm6, xmm7 registers

        push    rdx                             ; save input variable offset
        call    @proc
        pop     rdx                             ; restore input variable offset
        test    rdx, rdx
        jz      @F
        mov     [rdx], @IO.reg                  ; assign variable value
    @@:

        @@.sic_proc.restore.xmm6.xmm7
        pop     rdi rbx
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.sic_proc.DV.IO.sse.32 @proc, @IO.reg
{
    locals
       .xmm6    dq 2 dup ?                      ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7    dq 2 dup ?                      ; !!! declaration must be at the begin of locals
       .mem     dq 2 dup ?
    endl

        push    ebx edi
        @@.sic_proc.save.xmm6.xmm7              ; built-in functions can modify xmm6, xmm7 registers

        movsd   xmm0, qword [ebp + 8]
        mov     edx, dword [ebp + 16]           ; save input variable offset
        push    edx
        call    @proc
        pop     edx                             ; restore input variable offset
        test    edx, edx
        jz      @F
        mov     [edx], @IO.reg                  ; assign variable value
    @@:

        movsd   qword [.mem], xmm0
        fld     qword [.mem]

        @@.sic_proc.restore.xmm6.xmm7
        pop     edi ebx
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.sic_proc.DV.IO.fpu.64 @proc, @IO.reg
{
    locals
       .mem     dq 2 dup ?
    endl

        push    rbx rdi

        movsd   [.mem], xmm0
        fld     qword [.mem]
        push    rdx                             ; save input variable offset
        call    @proc
        pop     rdx                             ; restore input variable offset
        test    rdx, rdx
        jz      @F
        mov     [rdx], @IO.reg                  ; assign variable value
    @@:

        fstp    qword [.mem]
        movsd   xmm0, qword [.mem]

        pop     rdi rbx
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@.sic_proc.DV.IO.fpu.32 @proc, @IO.reg
{
        push    ebx edi

        fld     qword [ebp + 8]
        mov     edx, dword [ebp + 16]           ; save input variable offset
        push    edx
        call    @proc
        pop     edx                             ; restore input variable offset
        test    edx, edx
        jz      @F
        mov     [edx], @IO.reg                  ; assign variable value
    @@:

        pop     edi ebx
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; export function

; @ename - export name
; @proc  - internal function offset

; double proc ( double a )

macro @@.sic_export.DV @ename, @proc
{
macro @@.#@ename#.DV.sse.64
\{
$align 16
proc @ename, a

        @@.sic_proc.DV.sse.64 @proc
   .return:
        ret
endp
\}

macro @@.#@ename#.DV.sse.32
\{
$align 16
proc @ename, a, a.HI

        @@.sic_proc.DV.sse.32 @proc
   .return:
        ret
endp
\}

macro @@.#@ename#.DV.fpu.64
\{
$align 16
proc @ename, a

        @@.sic_proc.DV.fpu.64 @proc
   .return:
        ret
endp
\}

macro @@.#@ename#.DV.fpu.32
\{
$align 16
proc @ename, a, a.HI

        @@.sic_proc.DV.fpu.32 @proc
   .return:
        ret
endp
\}

$ifdef _SSEX
$ifdef _X64
  @@.#@ename#.DV.sse.64
$else
  @@.#@ename#.DV.sse.32
$end
$else
$ifdef _X64
  @@.#@ename#.DV.fpu.64
$else
  @@.#@ename#.DV.fpu.32
$end
$end
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; double proc ( double a, double b )

macro @@.sic_export.DV.DV @ename, @proc
{
macro @@.#@ename#.DV.DV.sse.64
\{
$align 16
proc @ename, a, b

        @@.sic_proc.DV.DV.sse.64 @proc
   .return:
        ret
endp
\}

macro @@.#@ename#.DV.DV.sse.32
\{
$align 16
proc @ename, a, a.HI, b, b.HI

        @@.sic_proc.DV.DV.sse.32 @proc
   .return:
        ret
endp
\}

macro @@.#@ename#.DV.DV.fpu.64
\{
$align 16
proc @ename, a, b

        @@.sic_proc.DV.DV.fpu.64 @proc
   .return:
        ret
endp
\}

macro @@.#@ename#.DV.DV.fpu.32
\{
$align 16
proc @ename, a, a.HI, b, b.HI

        @@.sic_proc.DV.DV.fpu.32 @proc
   .return:
        ret
endp
\}

$ifdef _SSEX
$ifdef _X64
  @@.#@ename#.DV.DV.sse.64
$else
  @@.#@ename#.DV.DV.sse.32
$end
$else
$ifdef _X64
  @@.#@ename#.DV.DV.fpu.64
$else
  @@.#@ename#.DV.DV.fpu.32
$end
$end
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; double proc ( double a, pinteger b )

macro @@.sic_export.DV.IO @ename, @proc, @IO.reg
{
macro @@.#@ename#.DV.IO.sse.64
\{
$align 16
proc @ename, a, b

        @@.sic_proc.DV.IO.sse.64 @proc, @IO.reg
   .return:
        ret
endp
\}

macro @@.#@ename#.DV.IO.sse.32
\{
$align 16
proc @ename, a, a.HI, b

        @@.sic_proc.DV.IO.sse.32 @proc, @IO.reg
   .return:
        ret
endp
\}

macro @@.#@ename#.DV.IO.fpu.64
\{
$align 16
proc @ename, a, b

        @@.sic_proc.DV.IO.fpu.64 @proc, @IO.reg
   .return:
        ret
endp
\}

macro @@.#@ename#.DV.IO.fpu.32
\{
$align 16
proc @ename, a, a.HI, b

        @@.sic_proc.DV.IO.fpu.32 @proc, @IO.reg
   .return:
        ret
endp
\}

$ifdef _SSEX
$ifdef _X64
  @@.#@ename#.DV.IO.sse.64
$else
  @@.#@ename#.DV.IO.sse.32
$end
$else
$ifdef _X64
  @@.#@ename#.DV.IO.fpu.64
$else
  @@.#@ename#.DV.IO.fpu.32
$end
$end
}

; ------------------------------------------------------------------------------
