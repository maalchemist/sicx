
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (FPU and SSE functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; finit
; Initialize FPU after checking for pending unmasked floating-point exceptions

macro @@finit.sse
{
$usprocf @@finit

       .mem     EQU esp - 16

        mov     dword [.mem], 0x00001F80        ; default MXCSR value 0 00 111111 0 000000
        ldmxcsr dword [.mem]
    .return:
        retn
$endp
}

macro @@finit.fpu
{
$usprocf @@finit

        finit
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@finit.sse
$else
  @@finit.fpu
$end

; ------------------------------------------------------------------------------

; fninit
; Initialize FPU without checking for pending unmasked floating-point exceptions

macro @@fninit.sse
{
$usprocf @@fninit

       .mem     EQU esp - 16

        mov     dword [.mem], 0x00001F80        ; default MXCSR value 0 00 111111 0 000000
        ldmxcsr dword [.mem]
    .return:
        retn
$endp
}

macro @@fninit.fpu
{
$usprocf @@fninit

        fninit
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fninit.sse
$else
  @@fninit.fpu
$end

; ------------------------------------------------------------------------------

; fclex
; Clear floating-point exception flags after checking for pending unmasked floating-point exceptions

macro @@fclex.sse
{
$usprocf @@fclex

       .mem     EQU esp - 16

        stmxcsr dword [.mem]
        and     dword [.mem], 0xFFFFFFC0        ; 1 11 111111 1 000000
        ldmxcsr dword [.mem]
    .return:
        retn
$endp
}

macro @@fclex.fpu
{
$usprocf @@fclex

        fclex
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fclex.sse
$else
  @@fclex.fpu
$end

; ------------------------------------------------------------------------------

; fnclex
; Clear floating-point exception flags without checking for pending unmasked floating-point exceptions

macro @@fnclex.sse
{
$usprocf @@fnclex

       .mem     EQU esp - 16

        stmxcsr dword [.mem]
        and     dword [.mem], 0xFFFFFFC0        ; 1 11 111111 1 000000
        ldmxcsr dword [.mem]
    .return:
        retn
$endp
}

macro @@fnclex.fpu
{
$usprocf @@fnclex

        fnclex
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fnclex.sse
$else
  @@fnclex.fpu
$end

; ------------------------------------------------------------------------------

; fstp

macro @@fstp.sse
{
$usprocf @@fstp

        nop
;       retn
$endp
}

macro @@fstp.fpu
{
$usprocf @@fstp

        fstp    st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fstp.sse
$else
  @@fstp.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; store FPU status word
; check for pending unmasked floating-point exceptions

$usprocf @@fstsw

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; store FPU status word
; check for pending unmasked floating-point exceptions
; eax = integer variable offset

macro @@_fstsw_io.eax.sse
{
$usprocf @@_fstsw_io.eax

        stmxcsr dword [eax]
    .return:
        retn
$endp
}

macro @@_fstsw_io.eax.fpu
{
$usprocf @@_fstsw_io.eax

        fstsw   word [eax]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fstsw_io.eax.sse
$else
  @@_fstsw_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; store FPU status word
; no check for pending unmasked floating-point exceptions

$usprocf @@fnstsw

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; store FPU status word
; no check for pending unmasked floating-point exceptions
; eax = integer variable offset

macro @@_fnstsw_io.eax.sse
{
$usprocf @@_fnstsw_io.eax

        stmxcsr dword [eax]
    .return:
        retn
$endp
}

macro @@_fnstsw_io.eax.fpu
{
$usprocf @@_fnstsw_io.eax

        fnstsw  word [eax]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fnstsw_io.eax.sse
$else
  @@_fnstsw_io.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; store FPU exception flags
; check for pending unmasked floating-point exceptions

$usprocf @@fstef

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; store FPU exception flags
; check for pending unmasked floating-point exceptions
; eax = integer variable offset

macro @@_fstef_io.eax.sse
{
$usprocf @@_fstef_io.eax

        stmxcsr dword [eax]
        and     dword [eax], 0x3F               ; 00111111
    .return:
        retn
$endp
}

macro @@_fstef_io.eax.fpu
{
$usprocf @@_fstef_io.eax

        fstsw   word [eax]
        and     word [eax], 0x3F                ; 00111111
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fstef_io.eax.sse
$else
  @@_fstef_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; store FPU exception flags
; no check for pending unmasked floating-point exceptions

$usprocf @@fnstef

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; store FPU exception flags
; no check for pending unmasked floating-point exceptions
; eax = integer variable offset

macro @@_fnstef_io.eax.sse
{
$usprocf @@_fnstef_io.eax

        stmxcsr dword [eax]
        and     dword [eax], 0x3F               ; 00111111
    .return:
        retn
$endp
}

macro @@_fnstef_io.eax.fpu
{
$usprocf @@_fnstef_io.eax

        fnstsw  word [eax]
        and     word [eax], 0x3F                ; 00111111
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fnstef_io.eax.sse
$else
  @@_fnstef_io.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; store FPU control word
; check for pending unmasked floating-point exceptions

$usprocf @@fstcw

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; store FPU control word
; check for pending unmasked floating-point exceptions
; eax = integer variable offset

macro @@_fstcw_io.eax.sse
{
$usprocf @@_fstcw_io.eax

        stmxcsr dword [eax]
    .return:
        retn
$endp
}

macro @@_fstcw_io.eax.fpu
{
$usprocf @@_fstcw_io.eax

        fstcw   word [eax]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fstcw_io.eax.sse
$else
  @@_fstcw_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; store FPU control word
; no check for pending unmasked floating-point exceptions

$usprocf @@fnstcw

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; store FPU control word
; no check for pending unmasked floating-point exceptions
; eax = integer variable offset

macro @@_fnstcw_io.eax.sse
{
$usprocf @@_fnstcw_io.eax

        stmxcsr dword [eax]
    .return:
        retn
$endp
}

macro @@_fnstcw_io.eax.fpu
{
$usprocf @@_fnstcw_io.eax

        fnstcw  word [eax]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fnstcw_io.eax.sse
$else
  @@_fnstcw_io.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; load FPU control word

$usprocf @@fldcw

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; load FPU control word
; eax = integer variable offset

macro @@_fldcw_io.eax.sse
{
$usprocf @@_fldcw_io.eax

        ldmxcsr dword [eax]
    .return:
        retn
$endp
}

macro @@_fldcw_io.eax.fpu
{
$usprocf @@_fldcw_io.eax

        fldcw   word [eax]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fldcw_io.eax.sse
$else
  @@_fldcw_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; load FPU control word
; eax = integer value

macro @@_fldcw_iv.eax.sse
{
$usprocf @@_fldcw_iv.eax

       .mem     EQU esp - 16

        mov     dword [.mem], eax
        ldmxcsr dword [.mem]
    .return:
        retn
$endp
}

macro @@_fldcw_iv.eax.fpu
{
$usprocf @@_fldcw_iv.eax

       .mem     EQU esp - 16

        mov     word [.mem], ax
        fldcw   word [.mem]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fldcw_iv.eax.sse
$else
  @@_fldcw_iv.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; mask FPU exceptions
; check for pending unmasked floating-point exceptions

$usprocf @@fmaske

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; mask FPU exceptions
; check for pending unmasked floating-point exceptions
; eax = integer variable offset

macro @@_fmaske_io.eax.sse
{
$usprocf @@_fmaske_io.eax

       .mem     EQU esp - 16

        mov     edx, dword [eax]
        and     edx, 0x3F                       ; 00 111111
        shl     edx, 7
        stmxcsr dword [.mem]
        and     dword [.mem], 0xFFFFE07F        ; 11111111111111111110000001111111 ; reset exception mask
        or      dword [.mem], edx
        ldmxcsr dword [.mem]
    .return:
        retn
$endp
}

macro @@_fmaske_io.eax.fpu
{
$usprocf @@_fmaske_io.eax

       .mem     EQU esp - 16

        mov     edx, dword [eax]
        and     edx, 0x3F                       ; 00 111111
        fnstcw  word [.mem]
        and     word [.mem], 0xFFC0             ; 1111111111000000 ; reset exception mask
        or      word [.mem], dx
        fldcw   word [.mem]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fmaske_io.eax.sse
$else
  @@_fmaske_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; mask FPU exceptions
; check for pending unmasked floating-point exceptions
; eax = integer value

macro @@_fmaske_iv.eax.sse
{
$usprocf @@_fmaske_iv.eax

       .mem     EQU esp - 16

        and     eax, 0x3F                       ; 00 111111
        shl     eax, 7
        stmxcsr dword [.mem]
        and     dword [.mem], 0xFFFFE07F        ; 11111111111111111110000001111111 ; reset exception mask
        or      dword [.mem], eax
        ldmxcsr dword [.mem]
    .return:
        retn
$endp
}

macro @@_fmaske_iv.eax.fpu
{
$usprocf @@_fmaske_iv.eax

       .mem     EQU esp - 16

        and     eax, 0x3F                       ; 00 111111
        fnstcw  word [.mem]
        and     word [.mem], 0xFFC0             ; 1111111111000000 ; reset exception mask
        or      word [.mem], ax
        fldcw   word [.mem]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fmaske_iv.eax.sse
$else
  @@_fmaske_iv.eax.fpu
$end

; ------------------------------------------------------------------------------

; mask FPU exceptions
; no check for pending unmasked floating-point exceptions

$usprocf @@fnmaske

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; mask FPU exceptions
; no check for pending unmasked floating-point exceptions
; eax = integer variable offset

macro @@_fnmaske_io.eax.sse
{
$usprocf @@_fnmaske_io.eax

       .mem     EQU esp - 16

        mov     edx, dword [eax]
        and     edx, 0x3F                       ; 00 111111
        shl     edx, 7
        stmxcsr dword [.mem]
        and     dword [.mem], 0xFFFFE07F        ; 11111111111111111110000001111111 ; reset exception mask
        or      dword [.mem], edx
        ldmxcsr dword [.mem]
    .return:
        retn
$endp
}

macro @@_fnmaske_io.eax.fpu
{
$usprocf @@_fnmaske_io.eax

       .mem     EQU esp - 16

        mov     edx, dword [eax]
        and     edx, 0x3F                       ; 00 111111
        fnstcw  word [.mem]
        and     word [.mem], 0xFFC0             ; 1111111111000000 ; reset exception mask
        or      word [.mem], dx
        fldcw   word [.mem]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fnmaske_io.eax.sse
$else
  @@_fnmaske_io.eax.fpu
$end

; ------------------------------------------------------------------------------

; mask FPU exceptions
; no check for pending unmasked floating-point exceptions
; eax = integer value

macro @@_fnmaske_iv.eax.sse
{
$usprocf @@_fnmaske_iv.eax

       .mem     EQU esp - 16

        and     eax, 0x3F                       ; 00 111111
        shl     eax, 7
        stmxcsr dword [.mem]
        and     dword [.mem], 0xFFFFE07F        ; 11111111111111111110000001111111 ; reset exception mask
        or      dword [.mem], eax
        ldmxcsr dword [.mem]
    .return:
        retn
$endp
}

macro @@_fnmaske_iv.eax.fpu
{
$usprocf @@_fnmaske_iv.eax

       .mem     EQU esp - 16

        and     eax, 0x3F                       ; 00 111111
        fnstcw  word [.mem]
        and     word [.mem], 0xFFC0             ; 1111111111000000 ; reset exception mask
        or      word [.mem], ax
        fldcw   word [.mem]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fnmaske_iv.eax.sse
$else
  @@_fnmaske_iv.eax.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; load +0.0

macro @@fldz.sse
{
$usprocf @@fldz

        xorpd   xmm0, xmm0
    .return:
        retn
$endp
}

macro @@fldz.fpu
{
$usprocf @@fldz

        fldz
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fldz.sse
$else
  @@fldz.fpu
$end

; ------------------------------------------------------------------------------

; load +1.0

macro @@fld1.sse
{
$usprocf @@fld1

        xmovsd  xmm0, ??.1.0
    .return:
        retn
$endp
}

macro @@fld1.fpu
{
$usprocf @@fld1

        fld1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fld1.sse
$else
  @@fld1.fpu
$end

; ------------------------------------------------------------------------------

; load PI

macro @@fldpi.sse
{
$usprocf @@fldpi

        xmovsd  xmm0, ??.pi
    .return:
        retn
$endp
}

macro @@fldpi.fpu
{
$usprocf @@fldpi

        fldpi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fldpi.sse
$else
  @@fldpi.fpu
$end

; ------------------------------------------------------------------------------

; load log[2](10)

macro @@fldl2t.sse
{
$usprocf @@fldl2t

        xmovsd  xmm0, ??.log2.10
    .return:
        retn
$endp
}

macro @@fldl2t.fpu
{
$usprocf @@fldl2t

        fldl2t
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fldl2t.sse
$else
  @@fldl2t.fpu
$end

; ------------------------------------------------------------------------------

; load log[2](e)

macro @@fldl2e.sse
{
$usprocf @@fldl2e

        xmovsd  xmm0, ??.log2.e
    .return:
        retn
$endp
}

macro @@fldl2e.fpu
{
$usprocf @@fldl2e

        fldl2e
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fldl2e.sse
$else
  @@fldl2e.fpu
$end

; ------------------------------------------------------------------------------

; load log[10](2)

macro @@fldlg2.sse
{
$usprocf @@fldlg2

        xmovsd  xmm0, ??.log10.2
    .return:
        retn
$endp
}

macro @@fldlg2.fpu
{
$usprocf @@fldlg2

        fldlg2
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fldlg2.sse
$else
  @@fldlg2.fpu
$end

; ------------------------------------------------------------------------------

; load log[e](2)

macro @@fldln2.sse
{
$usprocf @@fldln2

        xmovsd  xmm0, ??.ln.2
    .return:
        retn
$endp
}

macro @@fldln2.fpu
{
$usprocf @@fldln2

        fldln2
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fldln2.sse
$else
  @@fldln2.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; 2^x-1
; |x| < 1
; x = esp

macro @@f2xm1.sse.fpu
{
$usprocf @@f2xm1

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        f2xm1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@f2xm1.fpu
{
$usprocf @@f2xm1

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        f2xm1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@f2xm1.sse.fpu
$else
  @@f2xm1.fpu
$end

; ------------------------------------------------------------------------------

; y*log[2](x)
; x > 0
; x = esp
; y = esp + 8

macro @@fyl2x.sse.fpu
{
$usprocf @@fyl2x

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        ;
        fyl2x
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@fyl2x.fpu
{
$usprocf @@fyl2x

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fyl2x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fyl2x.sse.fpu
$else
  @@fyl2x.fpu
$end

; ------------------------------------------------------------------------------

; y*log[2](x+1)
; x = esp
; y = esp + 8

macro @@fyl2xp1.sse.fpu
{
$usprocf @@fyl2xp1

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        ;
        fyl2xp1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@fyl2xp1.fpu
{
$usprocf @@fyl2xp1

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fyl2xp1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fyl2xp1.sse.fpu
$else
  @@fyl2xp1.fpu
$end

; ------------------------------------------------------------------------------

; partial remainder
; x = esp
; y = esp + 8

macro @@fprem.sse.fpu
{
$usprocf @@fprem

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm1
        @@.fld.xmm0
        ;
        fprem
        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@fprem.fpu
{
$usprocf @@fprem

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; st0 = y, st1 = x
        fxch
        fprem
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fprem.sse.fpu
$else
  @@fprem.fpu
$end

; ------------------------------------------------------------------------------

; reverse partial remainder
; x = esp
; y = esp + 8

macro @@frprem.sse.fpu
{
$usprocf @@frprem

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        ;
        fprem
        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@frprem.fpu
{
$usprocf @@frprem

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; st0 = y, st1 = x
        fprem
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@frprem.sse.fpu
$else
  @@frprem.fpu
$end

; ------------------------------------------------------------------------------

; IEEE partial remainder
; x = esp
; y = esp + 8

macro @@fprem1.sse.fpu
{
$usprocf @@fprem1

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm1
        @@.fld.xmm0
        ;
        fprem1
        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@fprem1.fpu
{
$usprocf @@fprem1

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; st0 = y, st1 = x
        fxch
        fprem1
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fprem1.sse.fpu
$else
  @@fprem1.fpu
$end

; ------------------------------------------------------------------------------

; reverse IEEE partial remainder
; x = esp
; y = esp + 8

macro @@frprem1.sse.fpu
{
$usprocf @@frprem1

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        ;
        fprem1
        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@frprem1.fpu
{
$usprocf @@frprem1

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; st0 = y, st1 = x
        fprem1
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@frprem1.sse.fpu
$else
  @@frprem1.fpu
$end

; ------------------------------------------------------------------------------

; scale by power of 2
; scale(x,y) = x*(2^y)
; x = esp
; y = esp + 8

macro @@fscale.sse
{
$usprocf @@fscale

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        cvttsd2si eax, xmm1                     ; eax = integer exponent
   .e.p1024.test:
        cmp     eax, +1024
        jl     .e.p1024.out
   .e.GE.p1024:                                 ; e >= +1024
;       xmovsd  xmm5, ??.max.Double
        xmovsd  xmm5, ??.PInf
        jmp    .return
   .e.p1024.out:

   .e.m1023.test:
        cmp     eax, -1023
        jg     .e.m1023.out
   .e.LE.m1023:                                 ; e <= -1023
        xmovsd  xmm5, ??.2m1023
        mov     edx, -1023
        sub     edx, eax
        jz     .scale
        movd    xmm4, edx
        psrlq   xmm5, xmm4
        jmp    .scale
   .e.m1023.out:

   .main:                                       ; -1023 < e < +1024
        mov     edx, 0x000003FF
        add     edx, eax
        shl     edx, 64-12
   .assign:
    $ifdef _X64
        movq    xmm5, rdx
    $else
        movd    xmm5, edx
        pslldq  xmm5, 4
    $end
   .scale:                                      ; xmm5 = 2^eax
        mulsd   xmm0, xmm5                      ; xmm0 = x

   .return:
        retn
$endp
}

macro @@fscale.sse.fpu
{
$usprocf @@fscale

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm1
        @@.fld.xmm0
        ;
        fscale
        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@fscale.fpu
{
$usprocf @@fscale

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; st0 = y, st1 = x
        fxch
        fscale
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fscale.sse
; @@fscale.sse.fpu
$else
  @@fscale.fpu
$end

; ------------------------------------------------------------------------------

; reverse scale by power of 2
; rscale(x,y) = y*(2^x)
; x = esp
; y = esp + 8

macro @@frscale.sse
{
$usprocf @@frscale

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        cvttsd2si eax, xmm0                     ; eax = integer exponent
   .e.p1024.test:
        cmp     eax, +1024
        jl     .e.p1024.out
   .e.GE.p1024:                                 ; e >= +1024
;       xmovsd  xmm0, ??.max.Double
        xmovsd  xmm0, ??.PInf
        jmp    .return
   .e.p1024.out:

   .e.m1023.test:
        cmp     eax, -1023
        jg     .e.m1023.out
   .e.LE.m1023:                                 ; e <= -1023
        xmovsd  xmm0, ??.2m1023
        mov     edx, -1023
        sub     edx, eax
        jz     .scale
        movd    xmm4, edx
        psrlq   xmm0, xmm4
        jmp    .scale
   .e.m1023.out:

   .main:                                       ; -1023 < e < +1024
        mov     edx, 0x000003FF
        add     edx, eax
        shl     edx, 64-12
   .assign:
    $ifdef _X64
        movq    xmm0, rdx
    $else
        movd    xmm0, edx
        pslldq  xmm0, 4
    $end
   .scale:                                      ; xmm0 = 2^eax
        mulsd   xmm0, xmm1                      ; xmm1 = x

   .return:
        retn
$endp
}

macro @@frscale.sse.fpu
{
$usprocf @@frscale

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        ;
        fscale
        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@frscale.fpu
{
$usprocf @@frscale

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; st0 = y, st1 = x
        fscale
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@frscale.sse
; @@frscale.sse.fpu
$else
  @@frscale.fpu
$end

; ------------------------------------------------------------------------------

; extract significant
; x = esp

; fxtracts(0)    = +0
; fxtracts(NaN)  = NaN
; fxtracts(PInf) = PInf
; fxtracts(NInf) = NInf

macro @@fxtracts.sse.64
{
$usprocf @@fxtracts

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .arg.Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .return                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .return                          ; f(NaN) = NaN
        jmp    .main
   .arg.Zero:
        xorpd   xmm0, xmm0
        jmp    .return

   .main:
        movq    r9, xmm0
        ror     r9, 64-12
        mov     r10, r9
        mov     rcx, r9
        and     rcx, 0x7FF
        jnz    .enz
   .ez:                                         ; ecx = 0
        mov     r8, r9
        shr     r8, 12                          ; r8 = mantissa
        jz     .return                          ; return if xmm0 = 0
   .snz:                                        ; denormalized value
        bsr     r9, r8
        mov     rcx, 51+1
        sub     rcx, r9
        shl     r8, cl
;       add     ecx, 1023-1                     ; ecx = exponent
;       neg     ecx
        and     r10, 0x800
        or      r10, 0x3FF                      ; set exponent = 1023
        ror     r10, 12
        or      r10, r8
        movq    xmm0, r10                       ; xmm0 = significant
        jmp    .return
   .enz:                                        ; normalized value
;       sub     ecx, 1023                       ; ecx = exponent
        mov     r8, 0xFFFFFFFFFFFFF800
        and     r9, r8
        or      r9, 0x3FF                       ; set exponent = 1023
        ror     r9, 12
        movq    xmm0, r9                        ; xmm0 = significant

   .return:
        retn
$endp
}

macro @@fxtracts.sse.fpu
{
$usprocf @@fxtracts

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .update
        fnclex
        jmp    .return
    .update:
        fstp    st1                             ; st0 = significant
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@fxtracts.fpu
{
$usprocf @@fxtracts

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .update
        fnclex
        jmp    .return
    .update:
        fstp    st1                             ; st0 = significant
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@fxtracts.sse.64
$else
  @@fxtracts.sse.fpu
$end
$else
  @@fxtracts.fpu
$end

; ------------------------------------------------------------------------------

; extract exponent
; x = esp

; fxtracte(0)    = +0
; fxtracte(NaN)  = NaN
; fxtracte(PInf) = PInf
; fxtracte(NInf) = PInf

macro @@fxtracte.sse.64
{
$usprocf @@fxtracte

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .arg.Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .return                          ; f(PInf) = PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .arg.NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .return                          ; f(NaN) = NaN
        jmp    .main
   .arg.NInf:
        xmovsd  xmm0, ??.PInf
        jmp    .return
   .arg.Zero:
        xorpd   xmm0, xmm0
        jmp    .return

   .main:
        movq    r9, xmm0
        ror     r9, 64-12
        mov     rcx, r9
        and     rcx, 0x7FF
        jnz    .enz
   .ez:                                         ; ecx = 0
        mov     r8, r9
        shr     r8, 12                          ; r8 = mantissa
        jz     .leave                           ; leave if xmm0 = 0
   .snz:                                        ; denormalized value
        bsr     r9, r8
        mov     rcx, 51+1
        sub     rcx, r9
        shl     r8, cl
        add     ecx, 1023-1                     ; ecx = exponent
        neg     ecx
        jmp    .leave
   .enz:                                        ; normalized value
        sub     ecx, 1023                       ; ecx = exponent

   .leave:
        cvtsi2sd xmm0, ecx                      ; xmm0 = exponent
   .return:
        retn
$endp
}

macro @@fxtracte.sse.fpu
{
$usprocf @@fxtracte

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .update
        fnclex
        jmp    .return
    .update:
        fstp    st0                             ; st0 = exponent
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@fxtracte.fpu
{
$usprocf @@fxtracte

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .update
        fnclex
        jmp    .return
    .update:
        fstp    st0                             ; st0 = exponent
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@fxtracte.sse.64
$else
  @@fxtracte.sse.fpu
$end
$else
  @@fxtracte.fpu
$end

; ------------------------------------------------------------------------------

; extract significant & exponent
; x = esp
;
; return_1 = st1 = significant
; return_2 = st0 = exponent

; fxtractse(0)    = +0   : +0
; fxtractse(NaN)  = NaN  : NaN
; fxtractse(PInf) = PInf : PInf
; fxtractse(NInf) = NInf : PInf

macro @@fxtractse.sse.64
{
$usprocf @@fxtractse

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .arg.Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .arg.PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .arg.NInf
        test    cx, 0x0004                      ; test nan flag
        jz     .main
   .arg.NaN:
        movsd   xmm1, xmm0
        jmp    .return
   .arg.NInf:
        xmovsd  xmm1, ??.PInf
        jmp    .return
   .arg.PInf:
        movsd   xmm1, xmm0
        jmp    .return
   .arg.Zero:
        xorpd   xmm0, xmm0
        movsd   xmm1, xmm0
        jmp    .return

   .main:
        movq    r9, xmm0
        ror     r9, 64-12
        mov     r10, r9
        mov     rcx, r9
        and     rcx, 0x7FF
        jnz    .enz
   .ez:                                         ; ecx = 0
        mov     r8, r9
        shr     r8, 12                          ; r8 = mantissa
        jz     .leave                           ; leave if xmm0 = 0
   .snz:                                        ; denormalized value
        bsr     r9, r8
        mov     rcx, 51+1
        sub     rcx, r9
        shl     r8, cl
        add     ecx, 1023-1                     ; ecx = exponent
        neg     ecx
        and     r10, 0x800
        or      r10, 0x3FF                      ; set exponent = 1023
        ror     r10, 12
        or      r10, r8
        movq    xmm0, r10                       ; xmm0 = significant
        jmp    .leave
   .enz:                                        ; normalized value
        sub     ecx, 1023                       ; ecx = exponent
        mov     r8, 0xFFFFFFFFFFFFF800
        and     r9, r8
        or      r9, 0x3FF                       ; set exponent = 1023
        ror     r9, 12
        movq    xmm0, r9                        ; xmm0 = significant

   .leave:
        cvtsi2sd xmm1, ecx                      ; xmm1 = exponent
   .return:
        retn
$endp
}

macro @@fxtractse.sse.fpu
{
$usprocf @@fxtractse

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .return
        fnclex
        fldz
    .return:
        @@.fstp.xmm0                            ; st0 = exponent
        @@.fstp.xmm1
        retn
$endp
}

macro @@fxtractse.fpu
{
$usprocf @@fxtractse

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .update
        fnclex
        fldz
        jmp    .return
    .update:
        fxch                                    ; st0 = exponent    | st1 = significant
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@fxtractse.sse.64
$else
  @@fxtractse.sse.fpu
$end
$else
  @@fxtractse.fpu
$end

; ------------------------------------------------------------------------------
;
; extract significant & exponent
; double co.fxtractse ( double *significant, double *exponent, double x )
; x = esp
;
; eax = significant offset
; edx = exponent offset
;
; return_1 = st1 = significant
; return_2 = st0 = exponent
;
; return   = st0 = significant

; fxtractse(0)    = +0   : +0
; fxtractse(NaN)  = NaN  : NaN
; fxtractse(PInf) = PInf : PInf
; fxtractse(NInf) = NInf : PInf

macro @@co.fxtractse.sse.64
{
$usprocf @@co.fxtractse

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .arg.Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .arg.PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .arg.NInf
        test    cx, 0x0004                      ; test nan flag
        jz     .main
   .arg.NaN:
        movsd   xmm1, xmm0
        jmp    .assign
   .arg.NInf:
        xmovsd  xmm1, ??.PInf
        jmp    .assign
   .arg.PInf:
        movsd   xmm1, xmm0
        jmp    .assign
   .arg.Zero:
        xorpd   xmm0, xmm0
        movsd   xmm1, xmm0
        jmp    .assign

   .main:
        movq    r9, xmm0
        ror     r9, 64-12
        mov     r10, r9
        mov     rcx, r9
        and     rcx, 0x7FF
        jnz    .enz
   .ez:                                         ; ecx = 0
        mov     r8, r9
        shr     r8, 12                          ; r8 = mantissa
        jz     .leave                           ; leave if xmm0 = 0
   .snz:                                        ; denormalized value
        bsr     r9, r8
        mov     rcx, 51+1
        sub     rcx, r9
        shl     r8, cl
        add     ecx, 1023-1                     ; ecx = exponent
        neg     ecx
        and     r10, 0x800
        or      r10, 0x3FF                      ; set exponent = 1023
        ror     r10, 12
        or      r10, r8
        movq    xmm0, r10                       ; xmm0 = significant
        jmp    .leave
   .enz:                                        ; normalized value
        sub     ecx, 1023                       ; ecx = exponent
        mov     r8, 0xFFFFFFFFFFFFF800
        and     r9, r8
        or      r9, 0x3FF                       ; set exponent = 1023
        ror     r9, 12
        movq    xmm0, r9                        ; xmm0 = significant

   .leave:
        cvtsi2sd xmm1, ecx                      ; xmm1 = exponent
   .assign:
        movsd   qword [rax], xmm0
        movsd   qword [rdx], xmm1
   .return:
        retn
$endp
}

macro @@co.fxtractse.sse.fpu
{
$usprocf @@co.fxtractse

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        push    eax
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .assign
        fnclex
        fldz
    .assign:
        pop     eax
        fstp    qword [eax]
        fstp    qword [edx]
        ;
        movsd   xmm0, qword [eax]               ; xmm0 = significant
;       movsd   xmm1, qword [edx]               ; xmm1 = exponent
    .return:
        retn
$endp
}

macro @@co.fxtractse.fpu
{
$usprocf @@co.fxtractse

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        push    eax
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .update
        fnclex
        fldz
        jmp    .assign
    .update:
        fxch
    .assign:
        pop     eax
        fstp    qword [edx]
        fst     qword [eax]
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@co.fxtractse.sse.64
$else
  @@co.fxtractse.sse.fpu
$end
$else
  @@co.fxtractse.fpu
$end

; ------------------------------------------------------------------------------

; extract exponent & significant
; x = esp
;
; return_1 = st1 = exponent
; return_2 = st0 = significant

; fxtractes(0)    = +0   : +0
; fxtractes(NaN)  = NaN  : NaN
; fxtractes(PInf) = PInf : PInf
; fxtractes(NInf) = PInf : NInf

macro @@fxtractes.sse.64
{
$usprocf @@fxtractes

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .arg.Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .arg.PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .arg.NInf
        test    cx, 0x0004                      ; test nan flag
        jz     .main
   .arg.NaN:
        movsd   xmm1, xmm0
        jmp    .return
   .arg.NInf:
        movsd   xmm1, xmm0
        @@.chs  xmm0
        jmp    .return
   .arg.PInf:
        movsd   xmm1, xmm0
        jmp    .return
   .arg.Zero:
        xorpd   xmm0, xmm0
        movsd   xmm1, xmm0
        jmp    .return

   .main:
        movsd   xmm1, xmm0
        ;
        movq    r9, xmm1
        ror     r9, 64-12
        mov     r10, r9
        mov     rcx, r9
        and     rcx, 0x7FF
        jnz    .enz
   .ez:                                         ; ecx = 0
        mov     r8, r9
        shr     r8, 12                          ; r8 = mantissa
        jz     .leave                           ; leave if xmm1 = 0
   .snz:                                        ; denormalized value
        bsr     r9, r8
        mov     rcx, 51+1
        sub     rcx, r9
        shl     r8, cl
        add     ecx, 1023-1                     ; ecx = exponent
        neg     ecx
        and     r10, 0x800
        or      r10, 0x3FF                      ; set exponent = 1023
        ror     r10, 12
        or      r10, r8
        movq    xmm1, r10                       ; xmm1 = significant
        jmp    .leave
   .enz:                                        ; normalized value
        sub     ecx, 1023                       ; ecx = exponent
        mov     r8, 0xFFFFFFFFFFFFF800
        and     r9, r8
        or      r9, 0x3FF                       ; set exponent = 1023
        ror     r9, 12
        movq    xmm1, r9                        ; xmm1 = significant

   .leave:
        cvtsi2sd xmm0, ecx                      ; xmm0 = exponent
   .return:
        retn
$endp
}

macro @@fxtractes.sse.fpu
{
$usprocf @@fxtractes

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .return
        fnclex
        fldz
    .return:
        @@.fstp.xmm1                            ; st0 = exponent
        @@.fstp.xmm0
        retn
$endp
}

macro @@fxtractes.fpu
{
$usprocf @@fxtractes

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .return
        fnclex
        fldz
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@fxtractes.sse.64
$else
  @@fxtractes.sse.fpu
$end
$else
  @@fxtractes.fpu
$end

; ------------------------------------------------------------------------------
;
; extract exponent & significant
; double co.fxtractes ( double *exponent, double *significant, double x )
; x = esp
;
; eax = exponent offset
; edx = significant offset
;
; return_1 = st1 = exponent
; return_2 = st0 = significant
;
; return   = st0 = exponent

; fxtractes(0)    = +0   : +0
; fxtractes(NaN)  = NaN  : NaN
; fxtractes(PInf) = PInf : PInf
; fxtractes(NInf) = PInf : NInf

macro @@co.fxtractes.sse.64
{
$usprocf @@co.fxtractes

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .arg.Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .arg.PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .arg.NInf
        test    cx, 0x0004                      ; test nan flag
        jz     .main
   .arg.NaN:
        movsd   xmm1, xmm0
        jmp    .assign
   .arg.NInf:
        movsd   xmm1, xmm0
        @@.chs  xmm0
        jmp    .assign
   .arg.PInf:
        movsd   xmm1, xmm0
        jmp    .assign
   .arg.Zero:
        xorpd   xmm0, xmm0
        movsd   xmm1, xmm0
        jmp    .assign

   .main:
        movsd   xmm1, xmm0
        ;
        movq    r9, xmm1
        ror     r9, 64-12
        mov     r10, r9
        mov     rcx, r9
        and     rcx, 0x7FF
        jnz    .enz
   .ez:                                         ; ecx = 0
        mov     r8, r9
        shr     r8, 12                          ; r8 = mantissa
        jz     .leave                           ; leave if xmm1 = 0
   .snz:                                        ; denormalized value
        bsr     r9, r8
        mov     rcx, 51+1
        sub     rcx, r9
        shl     r8, cl
        add     ecx, 1023-1                     ; ecx = exponent
        neg     ecx
        and     r10, 0x800
        or      r10, 0x3FF                      ; set exponent = 1023
        ror     r10, 12
        or      r10, r8
        movq    xmm1, r10                       ; xmm1 = significant
        jmp    .leave
   .enz:                                        ; normalized value
        sub     ecx, 1023                       ; ecx = exponent
        mov     r8, 0xFFFFFFFFFFFFF800
        and     r9, r8
        or      r9, 0x3FF                       ; set exponent = 1023
        ror     r9, 12
        movq    xmm1, r9                        ; xmm1 = significant

   .leave:
        cvtsi2sd xmm0, ecx                      ; xmm0 = exponent
   .assign:
        movsd   qword [rax], xmm0
        movsd   qword [rdx], xmm1
   .return:
        retn
$endp
}

macro @@co.fxtractes.sse.fpu
{
$usprocf @@co.fxtractes

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        push    eax
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .assign
        fnclex
        fldz
    .assign:
        pop     eax
        fstp    qword [edx]
        fstp    qword [eax]
        ;
        movsd   xmm0, qword [eax]               ; xmm0 = exponent
;       movsd   xmm1, qword [edx]               ; xmm1 = significant
    .return:
        retn
$endp
}

macro @@co.fxtractes.fpu
{
$usprocf @@co.fxtractes

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        push    eax
        fxtract                                 ; st0 = significant | st1 = exponent?
        fnjnZE .assign
        fnclex
        fldz
    .assign:
        pop     eax
        fstp    qword [edx]
        fst     qword [eax]
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _X64
  @@co.fxtractes.sse.64
$else
  @@co.fxtractes.sse.fpu
$end
$else
  @@co.fxtractes.fpu
$end

; ------------------------------------------------------------------------------
