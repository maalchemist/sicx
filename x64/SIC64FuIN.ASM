
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (inline functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; do  - double offset
; doo - double offset offset
; dv  - double value
; io  - integer offset
; ioo - integer offset offset
; iv  - integer value
; so  - string offset
; soo - string offset offset
; sv  - string value

; ------------------------------------------------------------------------------

; integer typecast
; value on stack
; x = ST0(xmm0)
; return int64 in rax

macro @@__int64.sse
{
$asprocf @@__int64

    .enter:
        cvttsd2si rax, xmm0
    .return:
        retn
$endp
}

macro @@__int64.fpu
{
$asprocf @@__int64

       .int64   EQU rsp - 16

    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fistp   qword [.int64]
        mov     rax, qword [.int64]             ; save result

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@__int64.sse
$else
  @@__int64.fpu
$end

; ------------------------------------------------------------------------------

; integer typecast
; value on stack
; x = rsp

macro @@_dv.rsp_as_int64.sse
{
$usprocf @@_dv.rsp_as_int64

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       add     rsp, 8                          ; remove x from stack
;       add     rsp, -8                         ; allocate memory for qword
;       add     rsp, 8-8
        cvttsd2si rax, xmm0                     ; rax = int64 value
        mov     [rsp], rax                      ; [rsp] = int64 value
    .return:
        retn
$endp
}

macro @@_dv.rsp_as_int64.fpu
{
$usprocf @@_dv.rsp_as_int64

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
;       add     rsp, 8                          ; remove x from stack
;       add     rsp, -8                         ; allocate memory for qword
;       add     rsp, 8-8
        mov     rax, @@__int64
        call    rax                             ; rax = int64 value
        mov     [rsp], rax
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_dv.rsp_as_int64.sse
$else
  @@_dv.rsp_as_int64.fpu
$end

; ------------------------------------------------------------------------------

; integer typecast
; value by reference
; rcx = offset of x

macro @@_do.rcx_as_int64.sse
{
$usprocf @@_do.rcx_as_int64

        movsd   xmm0, qword [rcx]
   .enter:
        add     rsp, -8                         ; allocate memory for qword
        cvttsd2si rax, xmm0                     ; rax = int64 value
        mov     [rsp], rax                      ; [rsp] = int64 value
   .return:
        retn
$endp
}

macro @@_do.rcx_as_int64.fpu
{
$usprocf @@_do.rcx_as_int64

        fld     qword [rcx]
   .enter:
        add     rsp, -8                         ; allocate memory for qword
        mov     rax, @@__int64
        call    rax                             ; rax = int64 value
        mov     [rsp], rax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_do.rcx_as_int64.sse
$else
  @@_do.rcx_as_int64.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; load native integer x
; rax = offset of x

macro @@_io.rax_as_double.sse
{
$usprocf @@_io.rax_as_double

        cvtsi2sd xmm0, qword [rax]
        add     rsp, -8
    .return:
        retn
$endp
}

macro @@_io.rax_as_double.fpu
{
$usprocf @@_io.rax_as_double

        fild    qword [rax]
        add     rsp, -8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_io.rax_as_double.sse
$else
  @@_io.rax_as_double.fpu
$end

; ------------------------------------------------------------------------------

; load native integer x
; rcx = offset of x

macro @@_io.rcx_as_double.sse
{
$usprocf @@_io.rcx_as_double

        cvtsi2sd xmm0, qword [rcx]
        add     rsp, -8
    .return:
        retn
$endp
}

macro @@_io.rcx_as_double.fpu
{
$usprocf @@_io.rcx_as_double

        fild    qword [rcx]
        add     rsp, -8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_io.rcx_as_double.sse
$else
  @@_io.rcx_as_double.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy integer src to double dst
; rcx = dst offset
; rsp = src value

macro @@_copy_do.rcx_iv.rsp.sse
{
$usprocf @@_copy_do.rcx_iv.rsp

        cvtsi2sd xmm0, qword [rsp]
        movsd   qword [rcx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_do.rcx_iv.rsp.fpu
{
$usprocf @@_copy_do.rcx_iv.rsp

        fild    qword [rsp]
        fst     qword [rcx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_do.rcx_iv.rsp.sse
$else
  @@_copy_do.rcx_iv.rsp.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to double dst
; rcx = dst offset
; rax = src offset

macro @@_copy_do.rcx_io.rax.sse
{
$usprocf @@_copy_do.rcx_io.rax

        cvtsi2sd xmm0, qword [rax]
        movsd   qword [rcx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_do.rcx_io.rax.fpu
{
$usprocf @@_copy_do.rcx_io.rax

        fild    qword [rax]
        fst     qword [rcx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_do.rcx_io.rax.sse
$else
  @@_copy_do.rcx_io.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; rdx  = dst offset offset
; xmm0 = src value
; ST0  = src value

macro @@_copy_doo.rdx_dv.xmm0.sse
{
$usprocf @@_copy_doo.rdx_dv.xmm0

        mov     rdx, [rdx]
        test    rdx, rdx
        jz     .return
    .copy:
        movsd   qword [rdx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_doo.rdx_dv.st0.fpu
{
$usprocf @@_copy_doo.rdx_dv.st0

        mov     rdx, [rdx]
        test    rdx, rdx
        jz     .return
    .copy:
        fst     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_doo.rdx_dv.xmm0.sse
$else
  @@_copy_doo.rdx_dv.st0.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; rdx = dst offset
; rsp = src value

macro @@_copy_do.rdx_dv.rsp.sse
{
$usprocf @@_copy_do.rdx_dv.rsp

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .copy:
        movsd   qword [rdx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_do.rdx_dv.rsp.fpu
{
$usprocf @@_copy_do.rdx_dv.rsp

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .copy:
        fst     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_do.rdx_dv.rsp.sse
$else
  @@_copy_do.rdx_dv.rsp.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; rdx = dst offset offset
; rsp = src value

macro @@_copy_doo.rdx_dv.rsp.sse
{
$usprocf @@_copy_doo.rdx_dv.rsp

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        mov     rdx, [rdx]
        test    rdx, rdx
        jz     .return
    .copy:
        movsd   qword [rdx], xmm0
    .return:
        retn
$endp
}

macro @@_copy_doo.rdx_dv.rsp.fpu
{
$usprocf @@_copy_doo.rdx_dv.rsp

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        mov     rdx, [rdx]
        test    rdx, rdx
        jz     .return
    .copy:
        fst     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_doo.rdx_dv.rsp.sse
$else
  @@_copy_doo.rdx_dv.rsp.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; rdx = dst offset offset
; rax = src value

macro @@_copy_doo.rdx_dv.rax.sse
{
$usprocf @@_copy_doo.rdx_dv.rax

        mov     rdx, [rdx]
        test    rdx, rdx
        jnz    .copy
        mov     [rsp - 8], rax
        movsd   xmm0, qword [rsp - 8]
        jmp    .return
    .copy:
        mov     [rdx], rax
        movsd   xmm0, qword [rdx]
    .return:
        retn
$endp
}

macro @@_copy_doo.rdx_dv.rax.fpu
{
$usprocf @@_copy_doo.rdx_dv.rax

        mov     rdx, [rdx]
        test    rdx, rdx
        jnz    .copy
        mov     [rsp - 8], rax
        fld     qword [rsp - 8]
        jmp    .return
    .copy:
        mov     [rdx], rax
        fld     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_doo.rdx_dv.rax.sse
$else
  @@_copy_doo.rdx_dv.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; rdx = dst offset offset
; rax = src offset

macro @@_copy_doo.rdx_do.rax.sse
{
$usprocf @@_copy_doo.rdx_do.rax

        mov     rdx, [rdx]
        mov     rax, [rax]
        test    rdx, rdx
        jnz    .copy
        mov     [rsp - 8], rax
        movsd   xmm0, qword [rsp - 8]
        jmp    .return
    .copy:
        mov     [rdx], rax
        movsd   xmm0, qword [rdx]
    .return:
        retn
$endp
}

macro @@_copy_doo.rdx_do.rax.fpu
{
$usprocf @@_copy_doo.rdx_do.rax

        mov     rdx, [rdx]
        mov     rax, [rax]
        test    rdx, rdx
        jnz    .copy
        mov     [rsp - 8], rax
        fld     qword [rsp - 8]
        jmp    .return
    .copy:
        mov     [rdx], rax
        fld     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_doo.rdx_do.rax.sse
$else
  @@_copy_doo.rdx_do.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to double dst
; rdx = dst offset offset
; rcx = src offset

macro @@_copy_doo.rdx_do.rcx.sse
{
$usprocf @@_copy_doo.rdx_do.rcx

        mov     rdx, [rdx]
        mov     rcx, [rcx]
        test    rdx, rdx
        jnz    .copy
        mov     [rsp - 8], rcx
        movsd   xmm0, qword [rsp - 8]
        jmp    .return
    .copy:
        mov     [rdx], rcx
        movsd   xmm0, qword [rdx]
    .return:
        retn
$endp
}

macro @@_copy_doo.rdx_do.rcx.fpu
{
$usprocf @@_copy_doo.rdx_do.rcx

        mov     rdx, [rdx]
        mov     rcx, [rcx]
        test    rdx, rdx
        jnz    .copy
        mov     [rsp - 8], rcx
        fld     qword [rsp - 8]
        jmp    .return
    .copy:
        mov     [rdx], rcx
        fld     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_doo.rdx_do.rcx.sse
$else
  @@_copy_doo.rdx_do.rcx.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy double src to integer dst
; rcx  = dst offset
; xmm0 = src value
; ST0  = src value

macro @@_copy_io.rcx_dv.xmm0.sse
{
$usprocf @@_copy_io.rcx_dv.xmm0

        cvttsd2si rax, xmm0                     ; rax = truncated xmm0
        mov       [rcx], rax
        cvtsi2sd  xmm0, rax
    .return:
        retn
$endp
}

macro @@_copy_io.rcx_dv.st0.fpu
{
$usprocf @@_copy_io.rcx_dv.st0

        mov     rax, @@__int64
        call    rax
    .copy:
        mov     [rcx], rax
        fild    qword [rcx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.rcx_dv.xmm0.sse
$else
  @@_copy_io.rcx_dv.st0.fpu
$end

; ------------------------------------------------------------------------------

; copy double src to integer dst
; rcx = dst offset
; rax = src offset

macro @@_copy_io.rcx_do.rax.sse
{
$usprocf @@_copy_io.rcx_do.rax

        movsd   xmm0, qword [rax]
    .enter:
        cvttsd2si rax, xmm0
    .copy:
        mov     [rcx], rax
        cvtsi2sd xmm0, rax
    .return:
        retn
$endp
}

macro @@_copy_io.rcx_do.rax.fpu
{
$usprocf @@_copy_io.rcx_do.rax

        fld     qword [rax]
    .enter:
        mov     rax, @@__int64
        call    rax
    .copy:
        mov     [rcx], rax
        fild    qword [rcx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.rcx_do.rax.sse
$else
  @@_copy_io.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; rcx = dst offset
; rax = src value

macro @@_copy_io.rcx_iv.rax.sse
{
$usprocf @@_copy_io.rcx_iv.rax

    .copy:
        mov     [rcx], rax
        cvtsi2sd xmm0, rax
    .return:
        retn
$endp
}

macro @@_copy_io.rcx_iv.rax.fpu
{
$usprocf @@_copy_io.rcx_iv.rax

    .copy:
        mov     [rcx], rax
        fild    qword [rcx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.rcx_iv.rax.sse
$else
  @@_copy_io.rcx_iv.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; rcx = dst offset
; rax = src value

macro @@_copy_io.rcx_iv.rax_rsp.sse
{
$usprocf @@_copy_io.rcx_iv.rax_rsp

    .copy:
        mov     [rcx], rax
        cvtsi2sd xmm0, rax
    .return:
        add     rsp, 8
        retn
$endp
}

macro @@_copy_io.rcx_iv.rax_rsp.fpu
{
$usprocf @@_copy_io.rcx_iv.rax_rsp

    .copy:
        mov     [rcx], rax
        fild    qword [rcx]
    .return:
        add     rsp, 8
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.rcx_iv.rax_rsp.sse
$else
  @@_copy_io.rcx_iv.rax_rsp.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; rdx = dst offset offset
; rax = src value

macro @@_copy_ioo.rdx_iv.rax.sse
{
$usprocf @@_copy_ioo.rdx_iv.rax

        mov     rdx, [rdx]
        test    rdx, rdx
        jz     .load
    .copy:
        mov     [rdx], rax
    .load:
        cvtsi2sd xmm0, rax
    .return:
        retn
$endp
}

macro @@_copy_ioo.rdx_iv.rax.fpu
{
$usprocf @@_copy_ioo.rdx_iv.rax

        mov     rdx, [rdx]
        test    rdx, rdx
        jnz    .copy
        mov     [rsp - 8], rax
        fild    qword [rsp - 8]
        jmp    .return
    .copy:
        mov     [rdx], rax
        fild    qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_ioo.rdx_iv.rax.sse
$else
  @@_copy_ioo.rdx_iv.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; rcx = dst offset
; rax = src offset

macro @@_copy_io.rcx_io.rax.sse
{
$usprocf @@_copy_io.rcx_io.rax

        mov     rax, [rax]
    .copy:
        mov     [rcx], rax
        cvtsi2sd xmm0, rax
    .return:
        retn
$endp
}

macro @@_copy_io.rcx_io.rax.fpu
{
$usprocf @@_copy_io.rcx_io.rax

        mov     rax, [rax]
    .copy:
        mov     [rcx], rax
        fild    qword [rcx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_io.rcx_io.rax.sse
$else
  @@_copy_io.rcx_io.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy integer src to integer dst
; rdx = dst offset offset
; rax = src offset

macro @@_copy_ioo.rdx_io.rax.sse
{
$usprocf @@_copy_ioo.rdx_io.rax

        mov     rdx, [rdx]
        mov     rax, [rax]
        test    rdx, rdx
        jz     .load
    .copy:
        mov     [rdx], rax
    .load:
        cvtsi2sd xmm0, rax
    .return:
        retn
$endp
}

macro @@_copy_ioo.rdx_io.rax.fpu
{
$usprocf @@_copy_ioo.rdx_io.rax

        mov     rdx, [rdx]
        mov     rax, [rax]
        test    rdx, rdx
        jnz    .copy
        mov     [rsp - 8], rax
        fild    qword [rsp - 8]
        jmp    .return
    .copy:
        mov     [rdx], rax
        fild    qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy_ioo.rdx_io.rax.sse
$else
  @@_copy_ioo.rdx_io.rax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy string src to string dst
; rdx = dst offset
; rax = src value

$usprocf @@_copy_so.rdx_sv.rax

    .copy:
        mov     [rdx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy string src to string dst
; rdx = dst offset offset
; rax = src value

$usprocf @@_copy_soo.rdx_sv.rax

        mov     rdx, [rdx]
        test    rdx, rdx
        jz     .return
    .copy:
        mov     [rdx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy string src to string dst
; rdx = dst offset offset
; rax = src offset

$usprocf @@_copy_soo.rdx_so.rax

        mov     rdx, [rdx]
        mov     rax, [rax]
        test    rdx, rdx
        jz     .return
    .copy:
        mov     [rdx], rax
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy int double src to double dst
; double dst offset = rcx
; double src offset = rax

macro @@_copy.int_do.rcx_do.rax.sse
{
$usprocf @@_copy.int_do.rcx_do.rax

        movsd   xmm0, qword [rax]               ; xmm0 = src
        xintsd  xmm0, xmm0                      ; xmm0 = int(src)
        movsd   qword [rcx], xmm0               ; int(src)->dst
    .return:
        retn
$endp
}

macro @@_copy.int_do.rcx_do.rax.fpu
{
$usprocf @@_copy.int_do.rcx_do.rax

        fld     qword [rax]                     ; st0 = src
        @@.int.st0                              ; st0 = int(src)
        fst     qword [rcx]                     ; int(src)->dst ; st0 = int(src)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.int_do.rcx_do.rax.sse
$else
  @@_copy.int_do.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy int double src to double dst
; double dst offset = rcx
; double src        = st0|xmm0

macro @@_copy.int_do.rcx_dv.cpu.sse
{
$usprocf @@_copy.int_do.rcx_dv.cpu

        xintsd  xmm0, xmm0                      ; xmm0 = int(src)
        movsd   qword [rcx], xmm0               ; int(src)->dst
        add     rsp, 8
    .return:
        retn
$endp
}

macro @@_copy.int_do.rcx_dv.cpu.fpu
{
$usprocf @@_copy.int_do.rcx_dv.cpu

        @@.int.st0                              ; st0 = int(src)
        fst     qword [rcx]                     ; int(src)->dst ; st0 = int(src)
        add     rsp, 8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.int_do.rcx_dv.cpu.sse
$else
  @@_copy.int_do.rcx_dv.cpu.fpu
$end

; ------------------------------------------------------------------------------

; copy frac double src to double dst
; double dst offset = rcx
; double src offset = rax

macro @@_copy.frac_do.rcx_do.rax.sse
{
$usprocf @@_copy.frac_do.rcx_do.rax

        movsd   xmm0, qword [rax]               ; xmm0 = src
        xfracsd xmm0, xmm0                      ; xmm0 = frac(src)
        movsd   qword [rcx], xmm0               ; frac(src)->dst
    .return:
        retn
$endp
}

macro @@_copy.frac_do.rcx_do.rax.fpu
{
$usprocf @@_copy.frac_do.rcx_do.rax

        fld     qword [rax]                     ; st0 = src
        @@.frac.st0                             ; st0 = frac(src)
        fst     qword [rcx]                     ; frac(src)->dst ; st0 = frac(src)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.frac_do.rcx_do.rax.sse
$else
  @@_copy.frac_do.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy frac double src to double dst
; double dst offset = rcx
; double src        = st0|xmm0

macro @@_copy.frac_do.rcx_dv.cpu.sse
{
$usprocf @@_copy.frac_do.rcx_dv.cpu

        xfracsd xmm0, xmm0                      ; xmm0 = frac(src)
        movsd   qword [rcx], xmm0               ; frac(src)->dst
        add     rsp, 8
    .return:
        retn
$endp
}

macro @@_copy.frac_do.rcx_dv.cpu.fpu
{
$usprocf @@_copy.frac_do.rcx_dv.cpu

        @@.frac.st0                             ; st0 = frac(src)
        fst     qword [rcx]                     ; frac(src)->dst ; st0 = frac(src)
        add     rsp, 8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.frac_do.rcx_dv.cpu.sse
$else
  @@_copy.frac_do.rcx_dv.cpu.fpu
$end

; ------------------------------------------------------------------------------

; copy round double src to double dst
; double dst offset = rcx
; double src offset = rax

macro @@_copy.round_do.rcx_do.rax.sse
{
$usprocf @@_copy.round_do.rcx_do.rax

        movsd   xmm0, qword [rax]               ; xmm0 = src
        xrndsd  xmm0, xmm0                      ; xmm0 = round(src)
        movsd   qword [rcx], xmm0               ; round(src)->dst
    .return:
        retn
$endp
}

macro @@_copy.round_do.rcx_do.rax.fpu
{
$usprocf @@_copy.round_do.rcx_do.rax

        fld     qword [rax]                     ; st0 = src
        @@.round.st0                            ; st0 = round(src)
        fst     qword [rcx]                     ; round(src)->dst ; st0 = round(src)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.round_do.rcx_do.rax.sse
$else
  @@_copy.round_do.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy round double src to double dst
; double dst offset = rcx
; double src        = st0|xmm0

macro @@_copy.round_do.rcx_dv.cpu.sse
{
$usprocf @@_copy.round_do.rcx_dv.cpu

        xrndsd  xmm0, xmm0                      ; xmm0 = round(src)
        movsd   qword [rcx], xmm0               ; round(src)->dst
        add     rsp, 8
    .return:
        retn
$endp
}

macro @@_copy.round_do.rcx_dv.cpu.fpu
{
$usprocf @@_copy.round_do.rcx_dv.cpu

        @@.round.st0                            ; st0 = round(src)
        fst     qword [rcx]                     ; round(src)->dst ; st0 = round(src)
        add     rsp, 8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.round_do.rcx_dv.cpu.sse
$else
  @@_copy.round_do.rcx_dv.cpu.fpu
$end

; ------------------------------------------------------------------------------

; copy round double src to integer dst
; integer dst offset = rcx
; double src offset  = rax

macro @@_copy.round_io.rcx_do.rax.sse
{
$usprocf @@_copy.round_io.rcx_do.rax

        movsd     xmm0, qword [rax]             ; xmm0 = src
        xrndsd    xmm0, xmm0                    ; xmm0 = round(src)
        cvttsd2si rdx, xmm0                     ; rdx = round(src)
        mov       qword [rcx], rdx              ; round(src)->dst
    .return:
        retn
$endp
}

macro @@_copy.round_io.rcx_do.rax.fpu
{
$usprocf @@_copy.round_io.rcx_do.rax

        fld     qword [rax]                     ; st0 = src
        @@.round.st0                            ; st0 = round(src)
        fld     st0
        fistp   qword [rcx]                     ; round(src)->dst ; st0 = round(src)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.round_io.rcx_do.rax.sse
$else
  @@_copy.round_io.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------

; copy round double src to integer dst
; integer dst offset = rcx
; double src         = st0|xmm0

macro @@_copy.round_io.rcx_dv.cpu.sse
{
$usprocf @@_copy.round_io.rcx_dv.cpu

        xrndsd    xmm0, xmm0                    ; xmm0 = round(src)
        cvttsd2si rdx, xmm0                     ; rdx = round(src)
        mov       qword [rcx], rdx              ; round(src)->dst
        add       rsp, 8
    .return:
        retn
$endp
}

macro @@_copy.round_io.rcx_dv.cpu.fpu
{
$usprocf @@_copy.round_io.rcx_dv.cpu

        @@.round.st0                            ; st0 = round(src)
        fld     st0
        fistp   qword [rcx]                     ; round(src)->dst ; st0 = round(src)
        add     rsp, 8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_copy.round_io.rcx_dv.cpu.sse
$else
  @@_copy.round_io.rcx_dv.cpu.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap double src and double dst
; double dst offset = rcx
; double src offset = rax

macro @@_swap_do.rcx_do.rax.sse
{
$usprocf @@_swap_do.rcx_do.rax

        movsd   xmm0, qword [rax]               ; xmm0 = src
        movsd   xmm1, qword [rcx]               ; xmm1 = dst
        movsd   qword [rax], xmm1               ; dst->src
        movsd   qword [rcx], xmm0               ; src->dst
    .return:
        retn
$endp
}

macro @@_swap_do.rcx_do.rax.fpu
{
$usprocf @@_swap_do.rcx_do.rax

        fld     qword [rax]                     ; st0 = src
        fld     qword [rcx]                     ; st0 = dst, st1 = src
        fstp    qword [rax]                     ; dst->src ; st0 = src
        fst     qword [rcx]                     ; src->dst ; st0 = src
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap_do.rcx_do.rax.sse
$else
  @@_swap_do.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------

; swap integer src and double dst
; double dst offset  = rcx
; integer src offset = rax

macro @@_swap_do.rcx_io.rax.sse
{
$usprocf @@_swap_do.rcx_io.rax

        cvtsi2sd  xmm0, qword [rax]             ; xmm0 = src
        movsd     xmm1, qword [rcx]             ; xmm1 = dst
        cvttsd2si rdx, xmm1
        mov       qword [rax], rdx              ; dst->src
        movsd     qword [rcx], xmm0             ; src->dst
    .return:
        retn
$endp
}

macro @@_swap_do.rcx_io.rax.fpu
{
$usprocf @@_swap_do.rcx_io.rax

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fild    qword [rax]                     ; st0 = src
        fld     qword [rcx]                     ; st0 = dst, st1 = src
        fistp   qword [rax]                     ; dst->src ; st0 = src
        fst     qword [rcx]                     ; src->dst ; st0 = src

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap_do.rcx_io.rax.sse
$else
  @@_swap_do.rcx_io.rax.fpu
$end

; ------------------------------------------------------------------------------

; swap double src and integer dst
; integer dst offset = rcx
; double src offset  = rax

macro @@_swap_io.rcx_do.rax.sse
{
$usprocf @@_swap_io.rcx_do.rax

        movsd     xmm0, qword [rax]             ; xmm0 = src
        cvtsi2sd  xmm1, qword [rcx]             ; xmm1 = dst
        movsd     qword [rax], xmm1             ; dst->src
        cvttsd2si rdx, xmm0
        mov       qword [rcx], rdx              ; src->dst
    .return:
        retn
$endp
}

macro @@_swap_io.rcx_do.rax.fpu
{
$usprocf @@_swap_io.rcx_do.rax

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fild    qword [rcx]                     ; st0 = dst
        fld     qword [rax]                     ; st0 = src, st1 = dst
        fistp   qword [rcx]                     ; src->dst ; st0 = dst
        fstp    qword [rax]                     ; dst->src
        fild    qword [rcx]                     ; st0 = src

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap_io.rcx_do.rax.sse
$else
  @@_swap_io.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------

; swap integer src and integer dst
; integer dst offset = rcx
; integer src offset = rax

macro @@_swap_io.rcx_io.rax.sse
{
$usprocf @@_swap_io.rcx_io.rax

        mov     rdx, [rax]                      ; rdx = src
        mov     r10, [rcx]
        mov     [rax], r10
        mov     [rcx], rdx
        cvtsi2sd xmm0, rdx                      ; xmm0 = src
    .return:
        retn
$endp
}

macro @@_swap_io.rcx_io.rax.fpu
{
$usprocf @@_swap_io.rcx_io.rax

        mov     rdx, [rax]                      ; rdx = src
        mov     r10, [rcx]
        mov     [rax], r10
        mov     [rcx], rdx
        fild    qword [rcx]                     ; st0 = src
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap_io.rcx_io.rax.sse
$else
  @@_swap_io.rcx_io.rax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap int double src and int double dst
; double dst offset = rcx
; double src offset = rax

macro @@_swap.int_do.rcx_do.rax.sse
{
$usprocf @@_swap.int_do.rcx_do.rax

        movsd   xmm0, qword [rax]               ; xmm0 = src
        movsd   xmm1, qword [rcx]               ; xmm1 = dst

        mov     rdx, @@__int2p
        call    rdx                             ; xmm0 = (src), xmm1 = (dst)

        movsd   qword [rax], xmm1               ; (dst)->src
        movsd   qword [rcx], xmm0               ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.int_do.rcx_do.rax.fpu
{
$usprocf @@_swap.int_do.rcx_do.rax

        fld     qword [rax]                     ; st0 = src
        fld     qword [rcx]                     ; st0 = dst, st1 = src

        mov     rdx, @@__int2p
        call    rdx                             ; st0 = (src), st1 = (dst)

        fstp    qword [rcx]                     ; (src)->dst ; st0 = (dst)
        fst     qword [rax]                     ; (dst)->src ; st0 = (dst)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.int_do.rcx_do.rax.sse
$else
  @@_swap.int_do.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap frac double src and frac double dst
; double dst offset = rcx
; double src offset = rax

macro @@_swap.frac_do.rcx_do.rax.sse
{
$usprocf @@_swap.frac_do.rcx_do.rax

        movsd   xmm0, qword [rax]               ; xmm0 = src
        movsd   xmm1, qword [rcx]               ; xmm1 = dst

        mov     rdx, @@__frac2p
        call    rdx                             ; xmm0 = (src), xmm1 = (dst)

        movsd   qword [rax], xmm1               ; (dst)->src
        movsd   qword [rcx], xmm0               ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.frac_do.rcx_do.rax.fpu
{
$usprocf @@_swap.frac_do.rcx_do.rax

        fld     qword [rax]                     ; st0 = src
        fld     qword [rcx]                     ; st0 = dst, st1 = src

        mov     rdx, @@__frac2p
        call    rdx                             ; st0 = (src), st1 = (dst)

        fstp    qword [rcx]                     ; (src)->dst ; st0 = (dst)
        fst     qword [rax]                     ; (dst)->src ; st0 = (dst)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.frac_do.rcx_do.rax.sse
$else
  @@_swap.frac_do.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; swap round double src and round double dst
; double dst offset = rcx
; double src offset = rdx

macro @@_swap.round_do.rcx_do.rdx.sse
{
$usprocf @@_swap.round_do.rcx_do.rdx

        movsd   xmm0, qword [rdx]               ; xmm0 = src
        movsd   xmm1, qword [rcx]               ; xmm1 = dst

        mov     rax, @@__round2p
        call    rax                             ; xmm0 = (src), xmm1 = (dst)

        movsd   qword [rdx], xmm1               ; (dst)->src
        movsd   qword [rcx], xmm0               ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.round_do.rcx_do.rdx.fpu
{
$usprocf @@_swap.round_do.rcx_do.rdx

        fld     qword [rdx]                     ; st0 = src
        fld     qword [rcx]                     ; st0 = dst, st1 = src

        mov     rax, @@__round2p
        call    rax                             ; st0 = (src), st1 = (dst)

        fstp    qword [rcx]                     ; (src)->dst ; st0 = (dst)
        fst     qword [rdx]                     ; (dst)->src ; st0 = (dst)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.round_do.rcx_do.rdx.sse
$else
  @@_swap.round_do.rcx_do.rdx.fpu
$end

; ------------------------------------------------------------------------------

; swap round integer src and round double dst
; double dst offset  = rcx
; integer src offset = rax

macro @@_swap.round_do.rcx_io.rax.sse
{
$usprocf @@_swap.round_do.rcx_io.rax

        movsd     xmm0, qword [rcx]             ; xmm0 = dst

        mov       rdx, @@round.enter
        call      rdx                           ; xmm0 = (dst)

        cvttsd2si rdx, xmm0                     ; rdx = (dst)
        cvtsi2sd  xmm0, qword [rax]             ; xmm0 = (src)
        mov       qword [rax], rdx              ; (dst)->src
        movsd     qword [rcx], xmm0             ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.round_do.rcx_io.rax.fpu
{
$usprocf @@_swap.round_do.rcx_io.rax

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fild    qword [rax]                     ; st0 = (src)
        fld     qword [rcx]                     ; st0 = dst, st1 = (src)

        mov     rdx, @@round.enter
        call    rdx                             ; st0 = (dst), st1 = (src)

        fistp   qword [rax]                     ; (dst)->src ; st0 = (src)
        fst     qword [rcx]                     ; (src)->dst ; st0 = (src)

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.round_do.rcx_io.rax.sse
$else
  @@_swap.round_do.rcx_io.rax.fpu
$end

; ------------------------------------------------------------------------------

; swap round double src and round integer dst
; integer dst offset = rcx
; double src offset  = rax

macro @@_swap.round_io.rcx_do.rax.sse
{
$usprocf @@_swap.round_io.rcx_do.rax

        movsd     xmm0, qword [rax]             ; xmm0 = src

        mov       rdx, @@round.enter
        call      rdx                           ; xmm0 = (src)

        cvtsi2sd  xmm1, qword [rcx]             ; xmm1 = (dst)
        movsd     qword [rax], xmm1             ; (dst)->src
        cvttsd2si rdx, xmm0                     ; rdx = (src)
        mov       qword [rcx], rdx              ; (src)->dst
    .return:
        retn
$endp
}

macro @@_swap.round_io.rcx_do.rax.fpu
{
$usprocf @@_swap.round_io.rcx_do.rax

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fild    qword [rcx]                     ; st0 = (dst)
        fld     qword [rax]                     ; st0 = src, st1 = (dst)

        mov     rdx, @@round.enter
        call    rdx                             ; st0 = (src), st1 = (dst)

        fistp   qword [rcx]                     ; (src)->dst ; st0 = (dst)
        fstp    qword [rax]                     ; (dst)->src
        fild    qword [rcx]                     ; st0 = (src)

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_swap.round_io.rcx_do.rax.sse
$else
  @@_swap.round_io.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; assign zero
; double offset = rcx

macro @@_assign.zero_do.rcx.sse
{
$usprocf @@_assign.zero_do.rcx

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        movsd   qword [rcx], xmm0               ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zero_do.rcx.fpu
{
$usprocf @@_assign.zero_do.rcx

        fldz                                    ; st0 = 0
        fst     qword [rcx]                     ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zero_do.rcx.sse
$else
  @@_assign.zero_do.rcx.fpu
$end

; ------------------------------------------------------------------------------

; assign zero
; integer offset = rcx

macro @@_assign.zero_io.rcx.sse
{
$usprocf @@_assign.zero_io.rcx

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xor     rdx, rdx
        mov     qword [rcx], rdx                ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zero_io.rcx.fpu
{
$usprocf @@_assign.zero_io.rcx

        fldz                                    ; st0 = 0
        xor     rdx, rdx
        mov     qword [rcx], rdx                ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zero_io.rcx.sse
$else
  @@_assign.zero_io.rcx.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; assign zeroes
; double offset  = rcx
; integer offset = rax

macro @@_assign.zeroes_do.rcx_io.rax.sse
{
$usprocf @@_assign.zeroes_do.rcx_io.rax

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xor     rdx, rdx
        mov     qword [rax], rdx                ; 0->
        movsd   qword [rcx], xmm0               ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zeroes_do.rcx_io.rax.fpu
{
$usprocf @@_assign.zeroes_do.rcx_io.rax

        fldz                                    ; st0 = 0
        xor     rdx, rdx
        mov     qword [rax], rdx                ; 0->
        fst     qword [rcx]                     ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zeroes_do.rcx_io.rax.sse
$else
  @@_assign.zeroes_do.rcx_io.rax.fpu
$end

; ------------------------------------------------------------------------------

; assign zeroes
; integer offset = rcx
; double offset  = rax

macro @@_assign.zeroes_io.rcx_do.rax.sse
{
$usprocf @@_assign.zeroes_io.rcx_do.rax

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xor     rdx, rdx
        movsd   qword [rax], xmm0               ; 0->
        mov     qword [rcx], rdx                ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zeroes_io.rcx_do.rax.fpu
{
$usprocf @@_assign.zeroes_io.rcx_do.rax

        fldz                                    ; st0 = 0
        xor     rdx, rdx
        fst     qword [rax]                     ; 0->
        mov     qword [rcx], rdx                ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zeroes_io.rcx_do.rax.sse
$else
  @@_assign.zeroes_io.rcx_do.rax.fpu
$end

; ------------------------------------------------------------------------------

; assign zeroes
; integer offset = rcx
; integer offset = rax

macro @@_assign.zeroes_io.rcx_io.rax.sse
{
$usprocf @@_assign.zeroes_io.rcx_io.rax

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xor     rdx, rdx
        mov     qword [rax], rdx                ; 0->
        mov     qword [rcx], rdx                ; 0->
    .return:
        retn
$endp
}

macro @@_assign.zeroes_io.rcx_io.rax.fpu
{
$usprocf @@_assign.zeroes_io.rcx_io.rax

        fldz                                    ; st0 = 0
        xor     rdx, rdx
        mov     qword [rax], rdx                ; 0->
        mov     qword [rcx], rdx                ; 0->
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_assign.zeroes_io.rcx_io.rax.sse
$else
  @@_assign.zeroes_io.rcx_io.rax.fpu
$end

; ------------------------------------------------------------------------------
