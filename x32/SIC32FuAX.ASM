
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (approximate functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

DEFINE SIC_AX.LOGE_PQ TRUE
DEFINE SIC_AX.LOGE_RS FALSE

; include '..\xCommon\SICFuCO_AX.ASM'

; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/exp2.c
; Base 2 exponential function

; exp2(x) = 1 + 2*x*P(x^2)/(Q(x^2) - x*P(x^2))
;
; P =      1.51390680115615096133E+3 +  // P2
;   (x^2)*(2.02020656693165307700E+1 +  // P1
;   (x^2)*(2.30933477057345225087E-2 )) // P0
;
; Q =      4.36821166879210612817E+3 +  // Q2
;   (x^2)*(2.33184211722314911771E+2 +  // Q1
;   (x^2)*(1.00000000000000000000E+0 )) // Q0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_exp.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fexp2.sse
{
; |x| < 0.5
$asprocf @@fexp2.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     edx, ??.PD_fexp2_PQ
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]              ; xmm4 = P:Q
        ;
        mulsd   xmm0, xmm4                      ; xmm0 = x*P
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        subsd   xmm4, xmm0                      ; xmm4 = Q-x*P
        divsd   xmm0, xmm4                      ; xmm0 = x*P/(Q-x*P)
        addsd   xmm0, xmm0                      ; xmm0 = 2*x*P/(Q-x*P)
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5                      ; xmm0 = 1 + 2*x*P/(Q-x*P)
   .return:
        retn
$endp

$asprocf @@fexp2

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        mulsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fexp2.fpu
{
; |x| < 0.5
$asprocf @@fexp2.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2   | st1 = x

        mov     edx, ??.SD_fexp2_Qn
        fld     st0                             ; Q0 = 1.0
;       fld     qword [edx + 0*8]
;       fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]               ; st0 = Q     | st1 = x^2 | st2 = x
        ;
        mov     edx, ??.SD_fexp2_Pn
        fxch                                    ; st0 = x^2   | st1 = Q   | st2 = x
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmulp
        fadd    qword [edx + 2*8]               ; st0 = P     | st1 = Q   | st2 = x
        ;
        fmulp   st2, st0                        ; st0 = Q     | st1 = x*P
        fsub    st0, st1                        ; st0 = Q-x*P | st1 = x*P
        fdivp                                   ; st0 = x*P/(Q-x*P)
        fadd    st0, st0                        ; st0 = 2*x*P/(Q-x*P)
        fld1
        faddp                                   ; st0 = 1 + 2*x*P/(Q-x*P)
   .return:
        retn
$endp

$asprocf @@fexp2

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        fmulp
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fexp2.sse
$else
  @@fexp2.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fexp2L.sse
{
; |x| < 0.5
$asprocf @@fexp2L.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     edx, ??.PD_fexp2L_PQ
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 3*16]              ; xmm4 = P:Q
        ;
        mulsd   xmm0, xmm4                      ; xmm0 = x*P
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        subsd   xmm4, xmm0                      ; xmm4 = Q-x*P
        divsd   xmm0, xmm4                      ; xmm0 = x*P/(Q-x*P)
        addsd   xmm0, xmm0                      ; xmm0 = 2*x*P/(Q-x*P)
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5                      ; xmm0 = 1 + 2*x*P/(Q-x*P)
   .return:
        retn
$endp

$asprocf @@fexp2L

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2L.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        mulsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fexp2L.fpu
{
; |x| < 0.5
$asprocf @@fexp2L.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2   | st1 = x

        mov     edx, ??.SD_fexp2L_Qn
        fld     st0                             ; Q0 = 1.0
;       fld     qword [edx + 0*8]
;       fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]               ; st0 = Q     | st1 = x^2 | st2 = x
        ;
        mov     edx, ??.SD_fexp2L_Pn
        fxch                                    ; st0 = x^2   | st1 = Q   | st2 = x
        fld     qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmulp
        fadd    qword [edx + 3*8]               ; st0 = P     | st1 = Q   | st2 = x
        ;
        fmulp   st2, st0                        ; st0 = Q     | st1 = x*P
        fsub    st0, st1                        ; st0 = Q-x*P | st1 = x*P
        fdivp                                   ; st0 = x*P/(Q-x*P)
        fadd    st0, st0                        ; st0 = 2*x*P/(Q-x*P)
        fld1
        faddp                                   ; st0 = 1 + 2*x*P/(Q-x*P)
   .return:
        retn
$endp

$asprocf @@fexp2L

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2L.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        fmulp
   .return:
        retn
$endp
}

$ifdef _SSEX
; @@fexp2L.sse
$else
; @@fexp2L.fpu
$end

; ------------------------------------------------------------------------------

; e^x
;
; exp(x) = exp2(z)
; z = x*log2(e)

macro @@fexp.sse
{
$asprocf @@fexp

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        mulsd   xmm0, xmm5
   .return:
        retn
$endp

macro @@.fexp
\{
$asprocf @@fexp.PQ

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     edx, ??.PD_fexp_PQ
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 3*16]              ; xmm4 = P:Q
        ;
        mulsd   xmm4, xmm0                      ; xmm4 = x*P:Q
        movapd  xmm5, xmm4                      ; xmm5 = x*P:Q
    $ifdef _SSE3
        hsubpd  xmm5, xmm5                      ; xmm5 = x*P-Q
    $else
        oops hsubpd
    $end
        divsd   xmm4, xmm5                      ; xmm4 = x*P/(x*P-Q)
        addsd   xmm4, xmm4                      ; xmm4 = 2*x*P/(x*P-Q)
        xmovsd  xmm0, SIC_AX.1.0
        subsd   xmm0, xmm4                      ; xmm0 = 1 - 2*x*P/(x*P-Q) = 1 + 2*x*P/(Q-x*P)
   .return:
        retn
$endp

$asprocf @@fexp

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        xmovsd  xmm5, SIC_AX.ln.2
        mulsd   xmm0, xmm5
        mov     eax, @@fexp.PQ.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        mulsd   xmm0, xmm5
   .return:
        retn
$endp
\}
}

macro @@fexp.fpu
{
$asprocf @@fexp

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulq   SIC_AX.log2.e
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        fmulp
   .return:
        retn
$endp

macro @@.fexp
\{
$asprocf @@fexp.PQ

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2   | st1 = x

        mov     edx, ??.SD_fexp_Qn
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]               ; st0 = Q     | st1 = x^2 | st2 = x
        ;
        mov     edx, ??.SD_fexp_Pn
        fxch                                    ; st0 = x^2   | st1 = Q   | st2 = x
        fld     qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmulp
        fadd    qword [edx + 3*8]               ; st0 = P     | st1 = Q   | st2 = x
        ;
        fmulp   st2, st0                        ; st0 = Q     | st1 = x*P
        fsub    st0, st1                        ; st0 = Q-x*P | st1 = x*P
        fdivp                                   ; st0 = x*P/(Q-x*P)
        fadd    st0, st0                        ; st0 = 2*x*P/(Q-x*P)
        fld1
        faddp                                   ; st0 = 1 + 2*x*P/(Q-x*P)
   .return:
        retn
$endp

$asprocf @@fexp

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulq   SIC_AX.log2.e
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        fmulq   SIC_AX.ln.2
        mov     eax, @@fexp.PQ.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        fmulp
   .return:
        retn
$endp
\}
}

$ifdef _SSEX
  @@fexp.sse
$else
  @@fexp.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fexpL.sse
{
$asprocf @@fexpL

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2L.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        mulsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fexpL.fpu
{
$asprocf @@fexpL

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulq   SIC_AX.log2.e
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2L.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        fmulp
   .return:
        retn
$endp
}

$ifdef _SSEX
; @@fexpL.sse
$else
; @@fexpL.fpu
$end

; ------------------------------------------------------------------------------

; 10^x
;
; exp10(x) = exp2(z)
; z = x*log2(10)

macro @@fexp10.sse
{
$asprocf @@fexp10

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xmovsd  xmm5, SIC_AX.log2.10
        mulsd   xmm0, xmm5
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        mulsd   xmm0, xmm5
   .return:
        retn
$endp

macro @@.fexp10
\{
$asprocf @@fexp10.PQ

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     edx, ??.PD_fexp10_PQ
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 3*16]              ; xmm4 = P:Q
        ;
        mulsd   xmm4, xmm0                      ; xmm4 = x*P:Q
        movapd  xmm5, xmm4                      ; xmm5 = x*P:Q
    $ifdef _SSE3
        hsubpd  xmm5, xmm5                      ; xmm5 = x*P-Q
    $else
        oops hsubpd
    $end
        divsd   xmm4, xmm5                      ; xmm4 = x*P/(x*P-Q)
        addsd   xmm4, xmm4                      ; xmm4 = 2*x*P/(x*P-Q)
        xmovsd  xmm0, SIC_AX.1.0
        subsd   xmm0, xmm4                      ; xmm0 = 1 - 2*x*P/(x*P-Q) = 1 + 2*x*P/(Q-x*P)
   .return:
        retn
$endp

$asprocf @@fexp10

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xmovsd  xmm5, SIC_AX.log2.10
        mulsd   xmm0, xmm5
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp10.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        xmovsd  xmm5, SIC_AX.log10.2
        mulsd   xmm0, xmm5
        mov     eax, @@fexp10.PQ.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        mulsd   xmm0, xmm5
   .return:
        retn
$endp
\}
}

macro @@fexp10.fpu
{
$asprocf @@fexp10

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulq   SIC_AX.log2.10
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        fmulp
   .return:
        retn
$endp

macro @@.fexp10
\{
$asprocf @@fexp10.PQ

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2   | st1 = x

        mov     edx, ??.SD_fexp10_Qn
        fld     st0                             ; Q0 = 1.0
;       fld     qword [edx + 0*8]
;       fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]               ; st0 = Q     | st1 = x^2 | st2 = x
        ;
        mov     edx, ??.SD_fexp10_Pn
        fxch                                    ; st0 = x^2   | st1 = Q   | st2 = x
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmulp
        fadd    qword [edx + 3*8]               ; st0 = P     | st1 = Q   | st2 = x
        ;
        fmulp   st2, st0                        ; st0 = Q     | st1 = x*P
        fsub    st0, st1                        ; st0 = Q-x*P | st1 = x*P
        fdivp                                   ; st0 = x*P/(Q-x*P)
        fadd    st0, st0                        ; st0 = 2*x*P/(Q-x*P)
        fld1
        faddp                                   ; st0 = 1 + 2*x*P/(Q-x*P)
   .return:
        retn
$endp

$asprocf @@fexp10

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulq   SIC_AX.log2.10
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp10.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        fmulq   SIC_AX.log10.2
        mov     eax, @@fexp10.PQ.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        fmulp
   .return:
        retn
$endp
\}
}

$ifdef _SSEX
  @@fexp10.sse
$else
  @@fexp10.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fexp10L.sse
{
$asprocf @@fexp10L

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xmovsd  xmm5, SIC_AX.log2.10
        mulsd   xmm0, xmm5
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2L.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        mulsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fexp10L.fpu
{
$asprocf @@fexp10L

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulq   SIC_AX.log2.10
   .arg:                                        ; argument test
        mov     ebx, @@exp2.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     eax, @@exp2.reduce
        call    eax                             ; ebx = integer exponent
   .main:
        mov     eax, @@fexp2L.base.enter
        call    eax
        ;
        test    ebx, ebx
        jz     .return
        ;
        mov     eax, @@exp2.int                 ; ebx = integer exponent
        call    eax
        fmulp
   .return:
        retn
$endp
}

$ifdef _SSEX
; @@fexp10L.sse
$else
; @@fexp10L.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/log.c
; Natural logarithm
; http://www.moshier.net/double.zip/log2.c
; Base 2 logarithm

; loge(1+z) = z - 0.5*(z^2) + (z^3)*P(z)/Q(z)
;           = z*(1 + z*(-0.5 + z*P(z)/Q(z)))
; z = x-1
; 1 <= x < sqrt(2)
; 0 <= z < sqrt(2)-1
;
; P =    7.70838733755885391666E+0 +        // P5
;   (z)*(1.79368678507819816313E+1 +        // P4
;   (z)*(1.44989225341610930846E+1 +        // P3
;   (z)*(4.70579119878881725854E+0 +        // P2
;   (z)*(4.97494994976747001425E-1 +        // P1
;   (z)*(1.01875663804580931796E-4 )...)    // P0
;
; Q =    2.31251620126765340583E+1 +        // Q5
;   (z)*(7.11544750618563894466E+1 +        // Q4
;   (z)*(8.29875266912776603211E+1 +        // Q3
;   (z)*(4.52279145837532221105E+1 +        // Q2
;   (z)*(1.12873587189167450590E+1 +        // Q1
;   (z)*(1.00000000000000000000E+0 )...)    // Q0

; loge(z) = z + (z^3)*R(z^2)/S(z^2)
;         = z*(1 + (z^2)*R(z^2)/S(z^2))
;         = z*(1 + R'(z^2)/S(z^2))
; z = 2*(x-1)/(x+1)
; 1/sqrt(2) <= x < sqrt(2)
;
; R =      -6.41409952958715622951E+1 +     // R2
;   (z^2)*( 1.63866645699558079767E+1 +     // R1
;   (z^2)*(-7.89580278884799154124E-1 )...) // R0
;
; R' =      0.00000000000000000000E+0 +     // R3
;   (z^2)*(-6.41409952958715622951E+1 +     // R2
;   (z^2)*( 1.63866645699558079767E+1 +     // R1
;   (z^2)*(-7.89580278884799154124E-1 )...) // R0
;
; S =      -7.69691943550460008604E+2 +     // S3
;   (z^2)*( 3.12093766372244180303E+2 +     // S2
;   (z^2)*(-3.56722798256324312549E+1 +     // S1
;   (z^2)*( 1.00000000000000000000E+0 )...) // S0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_log.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@flog.sse
{
macro @@floge.RS.base
\{
; 1/sqrt(2) <= x < sqrt(2)
; z = 2*(x-1)/(x+1)
$asprocf @@floge.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xmovsd  xmm5, SIC_AX.1.0
        xmovx   xmm4, xmm0
        subsd   xmm0, xmm5                      ; xmm0 = x-1
        addsd   xmm4, xmm5                      ; xmm4 = x+1
        divsd   xmm0, xmm4                      ; xmm0 = (x-1)/(x+1)
        addsd   xmm0, xmm0                      ; xmm0 = 2*(x-1)/(x+1)
   .main:
        xddup   xmm5, xmm0                      ; xmm5 = z:z
        mulpd   xmm5, xmm5                      ; xmm5 = z^2:z^2

        mov     edx, ??.PD_floge_RS
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 3*16]              ; xmm4 = R':S
        ;
        movapd  xmm3, xmm4                      ; xmm3 = R':S
;       psrldq  xmm3, 8                         ; xmm3 = S:0
        shufpd  xmm3, xmm3, 1                   ; xmm3 = S:R'
        divsd   xmm4, xmm3                      ; xmm4 = R'/S
        ;
        xmovsd  xmm3, SIC_AX.1.0
        addsd   xmm3, xmm4
        mulsd   xmm0, xmm3                      ; xmm0 = z*(1+R'/S)
   .return:
        retn
$endp
\}

macro @@floge.PQ.base
\{
; 1 <= x < sqrt(2)
; z = x-1
$asprocf @@floge.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xmovsd  xmm5, SIC_AX.1.0
        subsd   xmm0, xmm5                      ; xmm0 = x-1
   .main:
        xddup   xmm5, xmm0                      ; xmm5 = z:z

        mov     edx, ??.PD_floge_PQ
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 4*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 5*16]              ; xmm4 = P:Q
        ;
        movapd  xmm3, xmm4                      ; xmm3 = P:Q
;       psrldq  xmm3, 8                         ; xmm3 = Q:0
        shufpd  xmm3, xmm3, 1                   ; xmm3 = Q:P
        divsd   xmm4, xmm3                      ; xmm4 = P/Q
        ;
        mulsd   xmm4, xmm5                      ; xmm4 = z*P/Q
        xmovsd  xmm3, SIC_AX.m0.5
        addsd   xmm3, xmm4
        mulsd   xmm3, xmm5                      ; xmm3 = z*(-0.5+z*P/Q)
        xmovsd  xmm0, SIC_AX.1.0
        addsd   xmm0, xmm3
        mulsd   xmm0, xmm5
   .return:
        retn
$endp
\}

$ifdef SIC_AX.LOGE_PQ
  @@floge.PQ.base
$else
  @@floge.RS.base
$end

; log2(m*2^N) = log2(m) + N = ln(m)/ln2 + N = log2(e)*ln(m) + N
; log2(x) = log2(x/sqrt(2)) + 0.5, x >= sqrt(2)
$asprocf @@flog2

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@loge.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        SIC_AX.xmm0.extract.se                  ; xmm0 = significant | ecx = exponent
        cvtsi2sd xmm2, ecx                      ; xmm2 = N
        ;
        xmovsd  xmm5, SIC_AX.SQRT2
        comisd  xmm0, xmm5
        jb     .L0
   .L2:                                         ; sqrt(2) <= x < 2
        xmovsd  xmm5, SIC_AX.0.5
        addsd   xmm2, xmm5                      ; xmm2 = N + 0.5
        xmovsd  xmm5, SIC_AX.1D.SQRT2
        mulsd   xmm0, xmm5
   .L0:                                         ; 1 <= x < sqrt(2)
   .main:
        mov     eax, @@floge.base.enter
        call    eax
        ;
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
        addsd   xmm0, xmm2
   .return:
        retn
$endp

; ln(m*2^N) = ln(m) + N*ln(2)
; ln(x) = ln(x/sqrt(2)) + ln(sqrt(2)), x >= sqrt(2)
$asprocf @@floge

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@loge.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        SIC_AX.xmm0.extract.se                  ; xmm0 = significant | ecx = exponent
        cvtsi2sd xmm2, ecx                      ; xmm2 = N
        xmovsd  xmm5, SIC_AX.ln.2
        mulsd   xmm2, xmm5                      ; xmm2 = N*ln(2)
        ;
        xmovsd  xmm5, SIC_AX.SQRT2
        comisd  xmm0, xmm5
        jb     .L0
   .L2:                                         ; sqrt(2) <= x < 2
        xmovsd  xmm5, SIC_AX.ln.SQRT2
        addsd   xmm2, xmm5                      ; xmm2 = N*ln(2) + ln(sqrt(2))
        xmovsd  xmm5, SIC_AX.1D.SQRT2
        mulsd   xmm0, xmm5
   .L0:                                         ; 1 <= x < sqrt(2)
   .main:
        mov     eax, @@floge.base.enter
        call    eax
        ;
        addsd   xmm0, xmm2
   .return:
        retn
$endp

; log10(m*2^N) = log10(m) + N*log10(2) = ln(m)/ln(10) + N*log10(2) = log10(e)*ln(m) + N*log10(2)
; log10(x) = log10(x/sqrt(2)) + log10(sqrt(2)), x >= sqrt(2)
$asprocf @@flog10

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@loge.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        SIC_AX.xmm0.extract.se                  ; xmm0 = significant | ecx = exponent
        cvtsi2sd xmm2, ecx                      ; xmm2 = N
        xmovsd  xmm5, SIC_AX.log10.2
        mulsd   xmm2, xmm5                      ; xmm2 = N*log10(2)
        ;
        xmovsd  xmm5, SIC_AX.SQRT2
        comisd  xmm0, xmm5
        jb     .L0
   .L2:                                         ; sqrt(2) <= x < 2
        xmovsd  xmm5, SIC_AX.log10.SQRT2
        addsd   xmm2, xmm5                      ; xmm2 = N*log10(2) + log10(sqrt(2))
        xmovsd  xmm5, SIC_AX.1D.SQRT2
        mulsd   xmm0, xmm5
   .L0:                                         ; 1 <= x < sqrt(2)
   .main:
        mov     eax, @@floge.base.enter
        call    eax
        ;
        xmovsd  xmm5, SIC_AX.log10.e
        mulsd   xmm0, xmm5
        addsd   xmm0, xmm2
   .return:
        retn
$endp
}

macro @@flog.fpu
{
macro @@floge.RS.base
\{
; 1/sqrt(2) <= x < sqrt(2)
; z = 2*(x-1)/(x+1)
$asprocf @@floge.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0
        fld1
        fsubp                                   ; st0 = x-1 | st1 = x
        fxch                                    ; st0 = x   | st1 = x-1
        fld1
        faddp                                   ; st0 = x+1 | st1 = x-1
        fdivp
        fadd    st0, st0                        ; st0 = 2*(x-1)/(x+1)
   .main:
        fld     st0                             ; st0 = z   | st1 = z
        fmul    st0, st0                        ; st0 = z^2 | st1 = z

        mov     edx, ??.SD_floge_Sn
        fld     st0                             ; S0 = 1.0
;       fld     qword [edx + 0*8]
;       fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]               ; st0 = S       | st1 = z^2 | st2 = z
        ;
        mov     edx, ??.SD_floge_Rn
        fxch                                    ; st0 = z^2     | st1 = S   | st2 = z
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        ;
        fmulp                                   ; st0 = z^2*R   | st1 = S   | st2 = z
        fdivrp                                  ; st0 = z^2*R/S | st1 = z
        fld1
        faddp
        fmulp                                   ; st0 = z*(1+z^2*R/S)
   .return:
        retn
$endp
\}

macro @@floge.PQ.base
\{
; 1 <= x < sqrt(2)
; z = x-1
$asprocf @@floge.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld1
        fsubp                                   ; st0 = x-1
   .main:
        fld     st0                             ; st0 = z | st1 = z

        mov     edx, ??.SD_floge_Qn
        fld     st0                             ; Q0 = 1.0
;       fld     qword [edx + 0*8]
;       fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmul    st0, st1
        fadd    qword [edx + 5*8]               ; st0 = Q     | st1 = z | st2 = z
        ;
        mov     edx, ??.SD_floge_Pn
        fxch                                    ; st0 = z     | st1 = Q | st2 = z
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmul    st0, st1
        fadd    qword [edx + 5*8]
        ;
        fmulp                                   ; st0 = z*P   | st1 = Q | st2 = z
        fdivrp                                  ; st0 = z*P/Q | st1 = z
        faddq   SIC_AX.m0.5
        fmul    st0, st1                        ; st0 = z*(-0.5+z*P/Q)
        fld1
        faddp                                   ; st0 = 1+z*(-0.5+z*P/Q)
        fmulp                                   ; st0 = z*(1+z*(-0.5+z*P/Q))
   .return:
        retn
$endp
\}

$ifdef SIC_AX.LOGE_PQ
  @@floge.PQ.base
$else
  @@floge.RS.base
$end

; log2(m*2^N) = log2(m) + N = ln(m)/ln2 + N = log2(e)*ln(m) + N
; log2(x) = log2(x/sqrt(2)) + 0.5, x >= sqrt(2)
$asprocf @@flog2

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@loge.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        SIC_AX.st0.extract.se                   ; st0 = significant | st1 = exponent
        ;
        fldq    SIC_AX.SQRT2
        fcomp                                   ; compare sqrt(2) to x
        fnjg   .L0                              ; jump if x < sqrt(2) (sqrt(2) > x)
   .L2:                                         ; sqrt(2) <= x < 2
        fldq    SIC_AX.0.5
        faddp   st2, st0                        ; st0 = s | st1 = N + 0.5
        fmulq   SIC_AX.1D.SQRT2
   .L0:                                         ; 1 <= x < sqrt(2)
   .main:
        mov     eax, @@floge.base.enter
        call    eax
        ;
        fldl2e
        fmulp
        faddp
   .return:
        retn
$endp

; ln(m*2^N) = ln(m) + N*ln(2)
; ln(x) = ln(x/sqrt(2)) + ln(sqrt(2)), x >= sqrt(2)
$asprocf @@floge

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@loge.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        SIC_AX.st0.extract.se                   ; st0 = significant | st1 = exponent
        fldln2
        fmulp   st2, st0                        ; st1 = N*ln(2)
        ;
        fldq    SIC_AX.SQRT2
        fcomp                                   ; compare sqrt(2) to x
        fnjg   .L0                              ; jump if x < sqrt(2) (sqrt(2) > x)
   .L2:                                         ; sqrt(2) <= x < 2
        fldq    SIC_AX.ln.SQRT2
        faddp   st2, st0                        ; st0 = s | st1 = N*ln(2) + ln(sqrt(2))
        fmulq   SIC_AX.1D.SQRT2
   .L0:                                         ; 1 <= x < sqrt(2)
   .main:
        mov     eax, @@floge.base.enter
        call    eax
        ;
        faddp
   .return:
        retn
$endp

; log10(m*2^N) = log10(m) + N*log10(2) = ln(m)/ln(10) + N*log10(2) = log10(e)*ln(m) + N*log10(2)
; log10(x) = log10(x/sqrt(2)) + log10(sqrt(2)), x >= sqrt(2)
$asprocf @@flog10

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@loge.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        SIC_AX.st0.extract.se                   ; st0 = significant | st1 = exponent
        fldlg2
        fmulp   st2, st0                        ; st1 = N*log10(2)
        ;
        fldq    SIC_AX.SQRT2
        fcomp                                   ; compare sqrt(2) to x
        fnjg   .L0                              ; jump if x < sqrt(2) (sqrt(2) > x)
   .L2:                                         ; sqrt(2) <= x < 2
        fldq    SIC_AX.log10.SQRT2
        faddp   st2, st0                        ; st0 = s | st1 = N*log10(2) + log10(sqrt(2))
        fmulq   SIC_AX.1D.SQRT2
   .L0:                                         ; 1 <= x < sqrt(2)
   .main:
        mov     eax, @@floge.base.enter
        call    eax
        ;
        fmulq   SIC_AX.log10.e
        faddp
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@flog.sse
$else
  @@flog.fpu
$end

; ------------------------------------------------------------------------------

; logn(n,x)
;
; logn(n,x) = ln(x)/ln(n)

macro @@flogn.sse
{
$asprocf @@flogn

        movsd   xmm0, qword [esp]               ; xmm0 = n
        movsd   xmm1, qword [esp + 8]           ; xmm1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@floge.enter
        call    ebx                             ; xmm0 = ln(n)
        @@.xch  xmm0, xmm1                      ; xmm0 = x | xmm1 = ln(n)
        mov     ebx, @@floge.enter
        call    ebx                             ; xmm0 = ln(x) | xmm1 = ln(n)
        divsd   xmm0, xmm1
   .return:
        retn
$endp
}

macro @@flogn.fpu
{
$asprocf @@flogn

        fld     qword [esp]                     ; st0 = n
        fld     qword [esp + 8]                 ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@floge.enter
        call    ebx                             ; st0 = ln(x) | st1 = n
        fxch                                    ; st0 = n     | st1 = ln(x)
        mov     ebx, @@floge.enter
        call    ebx                             ; st0 = ln(n) | st1 = ln(x)
        fdivp
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@flogn.sse
$else
  @@flogn.fpu
$end

; ------------------------------------------------------------------------------

; lognr(x,n)
;
; lognr(x,n) = ln(x)/ln(n)

macro @@flognr.sse
{
$asprocf @@flognr

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@floge.enter
        call    ebx                             ; xmm0 = ln(x)
        @@.xch  xmm0, xmm1                      ; xmm0 = n | xmm1 = ln(x)
        mov     ebx, @@floge.enter
        call    ebx                             ; xmm0 = ln(n) | xmm1 = ln(x)
        divsd   xmm1, xmm0
        xmovx   xmm0, xmm1
   .return:
        retn
$endp
}

macro @@flognr.fpu
{
$asprocf @@flognr

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     ebx, @@floge.enter
        call    ebx                             ; st0 = ln(n) | st1 = x
        fxch                                    ; st0 = x     | st1 = ln(n)
        mov     ebx, @@floge.enter
        call    ebx                             ; st0 = ln(x) | st1 = ln(n)
        fdivrp
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@flognr.sse
$else
  @@flognr.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; Power function
;
; pow(x,y) = exp2(z)
; z = y*log2(x)

macro @@fpow.sse
{
        local   @mem
        @mem    EQU esp - 64

; x^y
$asprocf @@fpow

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@power.arg                ; !!! use ebx
        call    ebx                             ; edi = y integer flags
        test    ebx, ebx
        jz     .return
   .int.in.range:
    $ifdef      SIC_AX.POW_INT
        test    edi, 0x0010                     ; test y integer in-range flag
        jz     .main
        mov     ebx, @@fpow.int
        call    ebx
        jmp    .return
    $end
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        mulsd   xmm0, xmm1
        mov     ebx, @@fexp2.enter
        call    ebx
   .return:
        retn
$endp

; x^n
$asprocf @@fpow.int

   .enter:                                      ; xmm0 = x | xmm1 = y
        cvttsd2si eax, xmm1                     ; eax = integer exponent

        xmovsd  xmm1, ??.1.0                    ; xmm1 = result = 1
        test    eax, eax
        jz     .assign

   .0:  mov     ecx, eax
        cdq
        xor     eax, edx
        sub     eax, edx                        ; eax = abs(exponent)
        jz     .assign
        jmp    .2
   .1:  mulsd   xmm0, xmm0                      ; x = base * base
   .2:  shr     eax, 1
        jnc    .1
        mulsd   xmm1, xmm0                      ; result = result * x
        jnz    .1
        cmp     ecx, 0
        jge    .assign
        xmovsd  xmm0, ??.1.0
        divsd   xmm0, xmm1                      ; result = 1 / result
        jmp    .leave
   .assign:
        xmovx   xmm0, xmm1                      ; xmm0 = result

   .leave:
   .return:
        retn
$endp

; |x|^y
$asprocf @@fapow

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.abs  xmm0
   .arg:                                        ; argument test
        mov     ebx, @@power.arg                ; !!! use ebx
        call    ebx                             ; edi = y integer flags
        test    ebx, ebx
        jz     .return
   .int.in.range:
    $ifdef      SIC_AX.POW_INT
        test    edi, 0x0010                     ; test y integer in-range flag
        jz     .main
        mov     ebx, @@fpow.int
        call    ebx
        jmp    .return
    $end
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        mulsd   xmm0, xmm1
        mov     ebx, @@fexp2.enter
        call    ebx
   .return:
        retn
$endp

; x^y
$asprocf @@fpow.core

   .enter:
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        mulsd   xmm0, xmm1
        mov     ebx, @@fexp2.core
        call    ebx
   .return:
        retn
$endp

; y^x
$asprocf @@fpowr

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xch  xmm0, xmm1
   .arg:                                        ; argument test
        mov     ebx, @@power.arg                ; !!! use ebx
        call    ebx                             ; edi = y integer flags
        test    ebx, ebx
        jz     .return
   .int.in.range:
    $ifdef      SIC_AX.POW_INT
        test    edi, 0x0010                     ; test y integer in-range flag
        jz     .main
        mov     ebx, @@fpow.int
        call    ebx
        jmp    .return
    $end
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        mulsd   xmm0, xmm1
        mov     ebx, @@fexp2.enter
        call    ebx
   .return:
        retn
$endp

; |y|^x
$asprocf @@fapowr

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xch  xmm0, xmm1
        @@.abs  xmm0
   .arg:                                        ; argument test
        mov     ebx, @@power.arg                ; !!! use ebx
        call    ebx                             ; edi = y integer flags
        test    ebx, ebx
        jz     .return
   .int.in.range:
    $ifdef      SIC_AX.POW_INT
        test    edi, 0x0010                     ; test y integer in-range flag
        jz     .main
        mov     ebx, @@fpow.int
        call    ebx
        jmp    .return
    $end
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        mulsd   xmm0, xmm1
        mov     ebx, @@fexp2.enter
        call    ebx
   .return:
        retn
$endp

; y^x
$asprocf @@fpowr.core

   .enter:
        @@.xch  xmm0, xmm1
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        mulsd   xmm0, xmm1
        mov     ebx, @@fexp2.core
        call    ebx
   .return:
        retn
$endp
}

macro @@fpow.fpu
{
        local   @mem
        @mem    EQU esp - 64

; x^y
$asprocf @@fpow

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fxch                                    ; st0 = x | st1 = y
   .arg:                                        ; argument test
        mov     ebx, @@power.arg                ; !!! use ebx
        call    ebx                             ; edi = y integer flags
        test    ebx, ebx
        jz     .return
   .int.in.range:
    $ifdef      SIC_AX.POW_INT
        test    edi, 0x0010                     ; test y integer in-range flag
        jz     .main
        mov     ebx, @@fpow.int
        call    ebx
        jmp    .return
    $end
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        fmulp
        mov     ebx, @@fexp2.enter
        call    ebx
   .return:
        retn
$endp

; x^n
$asprocf @@fpow.int

   .enter:                                      ; st0 = x | st1 = y
        fxch                                    ; st0 = y | st1 = x
        fistp   dword [@mem]                    ; st0 = x
        mov     eax, dword [@mem]               ; eax = integer exponent

        fld1                                    ; result = 1
        test    eax, eax
        jz     .leave

   .0:  mov     ecx, eax
        cdq
        xor     eax, edx
        sub     eax, edx                        ; eax = abs(exponent)
        jz     .leave
        fxch                                    ; st0 = base, st1 = 1
        jmp    .2
   .1:  fmul    st0, st0                        ; x = base * base
   .2:  shr     eax, 1
        jnc    .1
        fmul    st1, st0                        ; result = result * x
        jnz    .1
        fxch                                    ; st0 = result
        cmp     ecx, 0
        jge    .leave
        fld1
        fdivrp                                  ; result = 1 / result

   .leave:
        fstp    st1
   .return:
        retn
$endp

; |x|^y
$asprocf @@fapow

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fxch                                    ; st0 = x   | st1 = y
        fabs                                    ; st0 = |x| | st1 = y
   .arg:                                        ; argument test
        mov     ebx, @@power.arg                ; !!! use ebx
        call    ebx                             ; edi = y integer flags
        test    ebx, ebx
        jz     .return
   .int.in.range:
    $ifdef      SIC_AX.POW_INT
        test    edi, 0x0010                     ; test y integer in-range flag
        jz     .main
        mov     ebx, @@fpow.int
        call    ebx
        jmp    .return
    $end
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        fmulp
        mov     ebx, @@fexp2.enter
        call    ebx
   .return:
        retn
$endp

; x^y
$asprocf @@fpow.core

   .enter:
        fxch                                    ; st0 = x | st1 = y
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        fmulp
        mov     ebx, @@fexp2.core
        call    ebx
   .return:
        retn
$endp

; y^x
$asprocf @@fpowr

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@power.arg                ; !!! use ebx
        call    ebx                             ; edi = y integer flags
        test    ebx, ebx
        jz     .return
   .int.in.range:
    $ifdef      SIC_AX.POW_INT
        test    edi, 0x0010                     ; test y integer in-range flag
        jz     .main
        mov     ebx, @@fpow.int
        call    ebx
        jmp    .return
    $end
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        fmulp
        mov     ebx, @@fexp2.enter
        call    ebx
   .return:
        retn
$endp

; |y|^x
$asprocf @@fapowr

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fabs                                    ; st0 = |y| | st1 = x
   .arg:                                        ; argument test
        mov     ebx, @@power.arg                ; !!! use ebx
        call    ebx                             ; edi = y integer flags
        test    ebx, ebx
        jz     .return
   .int.in.range:
    $ifdef      SIC_AX.POW_INT
        test    edi, 0x0010                     ; test y integer in-range flag
        jz     .main
        mov     ebx, @@fpow.int
        call    ebx
        jmp    .return
    $end
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        fmulp
        mov     ebx, @@fexp2.enter
        call    ebx
   .return:
        retn
$endp

; y^x
$asprocf @@fpowr.core

   .enter:
   .main:
        mov     ebx, @@flog2.core
        call    ebx
        fmulp
        mov     ebx, @@fexp2.core
        call    ebx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fpow.sse
$else
  @@fpow.fpu
$end

; ------------------------------------------------------------------------------
