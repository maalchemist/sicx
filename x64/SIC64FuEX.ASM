
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (exponential functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; exponential function

macro @@exp.sse.fpu
{
$usprocf @@exp

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fldl2e
        fmulp
        fld     st0
        frndint
        fsub    st1, st0
        fxch
        f2xm1
        fld1
        faddp
        fscale
        fstp    st1

        @@.fpu.cw.restore                       ; restore control word
    .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@exp.enter.fpu

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fldl2e
        fmulp
        fld     st0
        frndint
        fsub    st1, st0
        fxch
        f2xm1
        fld1
        faddp
        fscale
        fstp    st1

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

macro @@exp.fpu
{
$usprocf @@exp

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fldl2e
        fmulp
        fld     st0
        frndint
        fsub    st1, st0
        fxch
        f2xm1
        fld1
        faddp
        fscale
        fstp    st1

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@exp.sse.fpu
$else
  @@exp.fpu
$end

; ------------------------------------------------------------------------------

; 2 raised to a power of x

macro @@exp2.sse.fpu
{
$usprocf @@exp2

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fld     st0
        frndint
        fsub    st1, st0
        fxch
        f2xm1
        fld1
        faddp
        fscale
        fstp    st1

        @@.fpu.cw.restore                       ; restore control word
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@exp2.fpu
{
$usprocf @@exp2

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fld     st0
        frndint
        fsub    st1, st0
        fxch
        f2xm1
        fld1
        faddp
        fscale
        fstp    st1

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@exp2.sse.fpu
$else
  @@exp2.fpu
$end

; ------------------------------------------------------------------------------

; 10 raised to a power of x

macro @@exp10.sse.fpu
{
$usprocf @@exp10

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fldl2t
        fmulp
        fld     st0
        frndint
        fsub    st1, st0
        fxch
        f2xm1
        fld1
        faddp
        fscale
        fstp    st1

        @@.fpu.cw.restore                       ; restore control word
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@exp10.fpu
{
$usprocf @@exp10

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fldl2t
        fmulp
        fld     st0
        frndint
        fsub    st1, st0
        fxch
        f2xm1
        fld1
        faddp
        fscale
        fstp    st1

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@exp10.sse.fpu
$else
  @@exp10.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; natural logarithm
; ln(x) = log2(x) * ln(2)

macro @@ln.sse.fpu
{
$usprocf @@ln

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fldln2
        fxch                                    ; st0 = x, st1 = ln(2)
        fyl2x                                   ; st0 = log2(x) * ln(2)
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@ln.fpu
{
$usprocf @@ln

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldln2
        fxch                                    ; st0 = x, st1 = ln(2)
        fyl2x                                   ; st0 = log2(x) * ln(2)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ln.sse.fpu
$else
  @@ln.fpu
$end

; ------------------------------------------------------------------------------

; base-2 logarithm

macro @@log2.sse.fpu
{
$usprocf @@log2

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld1
        fxch                                    ; st0 = x, st1 = 1
        fyl2x                                   ; st0 = log2(x) * 1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@log2.fpu
{
$usprocf @@log2

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1
        fxch                                    ; st0 = x, st1 = 1
        fyl2x                                   ; st0 = log2(x) * 1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@log2.sse.fpu
$else
  @@log2.fpu
$end

; ------------------------------------------------------------------------------

; base-10 logarithm
; log10(x) = log2(x) * log10(2)

macro @@log10.sse.fpu
{
$usprocf @@log10

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fldlg2
        fxch                                    ; st0 = x, st1 = log10(2)
        fyl2x                                   ; st0 = log2(x) * log10(2)
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@log10.fpu
{
$usprocf @@log10

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldlg2
        fxch                                    ; st0 = x, st1 = log10(2)
        fyl2x                                   ; st0 = log2(x) * log10(2)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@log10.sse.fpu
$else
  @@log10.fpu
$end

; ------------------------------------------------------------------------------

; base-n logarithm
; double logn ( double n, double x )
; logn(n,x) = log2(x) / log2(n)

macro @@logn.sse.fpu
{
$usprocf @@logn

        movsd   xmm0, qword [rsp]               ; xmm0 = n
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0                             ; st0 = n
        @@.fld.xmm1                             ; st0 = x, st1 = n
        ;
        fld1
        fxch
        fyl2x                                   ; st0 = log2(x)
        fxch                                    ; st0 = n
        fld1
        fxch
        fyl2x                                   ; st0 = log2(n)
        fdivp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@logn.fpu
{
$usprocf @@logn

        fld     qword [rsp]                     ; st0 = n
        fld     qword [rsp + 8]                 ; st0 = x, st1 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1
        fxch
        fyl2x                                   ; st0 = log2(x)
        fxch                                    ; st0 = n
        fld1
        fxch
        fyl2x                                   ; st0 = log2(n)
        fdivp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@logn.sse.fpu
$else
  @@logn.fpu
$end

; ------------------------------------------------------------------------------

; reverse base-n logarithm
; double lognr ( double n, double x )
; lognr(n,x) = log2(n) / log2(x)

macro @@lognr.sse.fpu
{
$usprocf @@lognr

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm1                             ; st0 = n
        @@.fld.xmm0                             ; st0 = x, st1 = n
        ;
        fld1
        fxch
        fyl2x                                   ; st0 = log2(x)
        fxch                                    ; st0 = n
        fld1
        fxch
        fyl2x                                   ; st0 = log2(n)
        fdivp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@lognr.fpu
{
$usprocf @@lognr

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = n, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxch                                    ; st0 = x, st1 = n
        fld1
        fxch
        fyl2x                                   ; st0 = log2(x)
        fxch                                    ; st0 = n
        fld1
        fxch
        fyl2x                                   ; st0 = log2(n)
        fdivp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@lognr.sse.fpu
$else
  @@lognr.fpu
$end

; ------------------------------------------------------------------------------
