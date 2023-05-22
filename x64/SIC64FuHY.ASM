
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (hyperbolic functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; hyperbolic sine
; sh(x) = 0.5 * [exp(x) - 1 / exp(x)]

macro @@sh.sse.fpu
{
$usprocf @@sh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(x)
        fld     st0
        fld1
        fdivrp
        fsubp
        fmulq   ??.0.5
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@sh.fpu
{
$usprocf @@sh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp(x)
        fld     st0
        fld1
        fdivrp
        fsubp
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sh.sse.fpu
$else
  @@sh.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosine
; ch(x) = 0.5 * [exp(x) + 1 / exp(x)]

macro @@ch.sse.fpu
{
$usprocf @@ch

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(x)
        fld     st0
        fld1
        fdivrp
        faddp
        fmulq   ??.0.5
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@ch.fpu
{
$usprocf @@ch

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp(x)
        fld     st0
        fld1
        fdivrp
        faddp
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ch.sse.fpu
$else
  @@ch.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic sine and cosine
; sh(x) = 0.5 * [exp(x) - 1 / exp(x)]
; ch(x) = 0.5 * [exp(x) + 1 / exp(x)]
;
; return_1 = st1 = sh(x)
; return_2 = st0 = ch(x)

macro @@shch.sse.fpu
{
$usprocf @@shch

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(x)
        mov     rax, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        fsubp
        fmul    qword [rax]                     ; st0 = sh(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = sh(x)
        faddp
        fmul    qword [rax]                     ; st0 = ch(x)    | st1 = sh(x)
    .return:
        @@.fstp.xmm1                            ; xmm1 = ch(x)
        @@.fstp.xmm0                            ; xmm0 = sh(x)
        retn
$endp

$asprocf @@shch.enter.fpu

        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(x)
        mov     rax, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        fsubp
        fmul    qword [rax]                     ; st0 = sh(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = sh(x)
        faddp
        fmul    qword [rax]                     ; st0 = ch(x)    | st1 = sh(x)
    .return:
        retn
$endp
}

macro @@shch.fpu
{
$usprocf @@shch

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp(x)
        mov     rax, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        fsubp
        fmul    qword [rax]                     ; st0 = sh(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = sh(x)
        faddp
        fmul    qword [rax]                     ; st0 = ch(x)    | st1 = sh(x)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@shch.sse.fpu
$else
  @@shch.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic sine and cosine
; sh(x) = 0.5 * [exp(x) - 1 / exp(x)]
; ch(x) = 0.5 * [exp(x) + 1 / exp(x)]
;
; rax = sh offset
; rdx = ch offset
;
; return_1 = st1 = sh(x)
; return_2 = st0 = ch(x)
;
; return   = st0 = sh(x)

macro @@co.shch.sse.fpu
{
$usprocf @@co.shch

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rcx, @@exp.enter.fpu
        call    rcx                             ; st0 = exp(x)
        mov     rcx, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        fsubp
        fmul    qword [rcx]                     ; st0 = sh(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = sh(x)
        faddp
        fmul    qword [rcx]                     ; st0 = ch(x)    | st1 = sh(x)
    .return:
        fstp    qword [rdx]
        fstp    qword [rax]
        ;
        movsd   xmm0, qword [rax]               ; xmm0 = sh(x)
;       movsd   xmm1, qword [rdx]               ; xmm1 = ch(x)
        retn
$endp
}

macro @@co.shch.fpu
{
$usprocf @@co.shch

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rcx, @@exp.enter
        call    rcx                             ; st0 = exp(x)
        mov     rcx, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        fsubp
        fmul    qword [rcx]                     ; st0 = sh(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = sh(x)
        faddp
        fmul    qword [rcx]                     ; st0 = ch(x)    | st1 = sh(x)
    .return:
        fstp    qword [rdx]
        fst     qword [rax]
        retn
$endp
}

$ifdef _SSEX
  @@co.shch.sse.fpu
$else
  @@co.shch.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosine and sine
; ch(x) = 0.5 * [exp(x) + 1 / exp(x)]
; sh(x) = 0.5 * [exp(x) - 1 / exp(x)]
;
; return_1 = st1 = ch(x)
; return_2 = st0 = sh(x)

macro @@chsh.sse.fpu
{
$usprocf @@chsh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(x)
        mov     rax, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        faddp
        fmul    qword [rax]                     ; st0 = ch(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = ch(x)
        fsubrp
        fmul    qword [rax]                     ; st0 = sh(x)    | st1 = ch(x)
    .return:
        @@.fstp.xmm1                            ; xmm1 = sh(x)
        @@.fstp.xmm0                            ; xmm0 = ch(x)
        retn
$endp

$asprocf @@chsh.enter.fpu

        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(x)
        mov     rax, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        faddp
        fmul    qword [rax]                     ; st0 = ch(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = ch(x)
        fsubrp
        fmul    qword [rax]                     ; st0 = sh(x)    | st1 = ch(x)
    .return:
        retn
$endp
}

macro @@chsh.fpu
{
$usprocf @@chsh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp(x)
        mov     rax, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        faddp
        fmul    qword [rax]                     ; st0 = ch(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = ch(x)
        fsubrp
        fmul    qword [rax]                     ; st0 = sh(x)    | st1 = ch(x)
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@chsh.sse.fpu
$else
  @@chsh.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosine and sine
; ch(x) = 0.5 * [exp(x) + 1 / exp(x)]
; sh(x) = 0.5 * [exp(x) - 1 / exp(x)]
;
; rax = ch offset
; rdx = sh offset
;
; return_1 = st1 = ch(x)
; return_2 = st0 = sh(x)
;
; return   = st0 = ch(x)

macro @@co.chsh.sse.fpu
{
$usprocf @@co.chsh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rcx, @@exp.enter.fpu
        call    rcx                             ; st0 = exp(x)
        mov     rcx, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        faddp
        fmul    qword [rcx]                     ; st0 = ch(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = ch(x)
        fsubrp
        fmul    qword [rcx]                     ; st0 = sh(x)    | st1 = ch(x)
    .return:
        fstp    qword [rdx]
        fstp    qword [rax]
        ;
        movsd   xmm0, qword [rax]               ; xmm0 = ch(x)
;       movsd   xmm1, qword [rdx]               ; xmm1 = sh(x)
        retn
$endp
}

macro @@co.chsh.fpu
{
$usprocf @@co.chsh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rcx, @@exp.enter
        call    rcx                             ; st0 = exp(x)
        mov     rcx, ??.0.5
        fld     st0
        fld1
        fdivrp                                  ; st0 = 1/exp(x) | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = 1/exp(x) | st1 = exp(x)   | st2 = 1/exp(x) | st3 = exp(x)
        faddp
        fmul    qword [rcx]                     ; st0 = ch(x)    | st1 = 1/exp(x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)   | st1 = 1/exp(x) | st2 = ch(x)
        fsubrp
        fmul    qword [rcx]                     ; st0 = sh(x)    | st1 = ch(x)
    .return:
        fstp    qword [rdx]
        fst     qword [rax]
        retn
$endp
}

$ifdef _SSEX
  @@co.chsh.sse.fpu
$else
  @@co.chsh.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic secant
; sch(x) = 1 / ch(x) = 2 / [exp(x) + 1 / exp(x)]

macro @@sch.sse.fpu
{
$usprocf @@sch

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(x)
        fld     st0
        fld1
        fdivrp
        faddp
        fldq    ??.2.0
        fdivrp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@sch.fpu
{
$usprocf @@sch

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp(x)
        fld     st0
        fld1
        fdivrp
        faddp
        fldq    ??.2.0
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sch.sse.fpu
$else
  @@sch.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosecant
; csh(x) = 1 / sh(x) = 2 / [exp(x) - 1 / exp(x)]

macro @@csh.sse.fpu
{
$usprocf @@csh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(x)
        fld     st0
        fld1
        fdivrp
        fsubp
        fldq    ??.2.0
        fdivrp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@csh.fpu
{
$usprocf @@csh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp(x)
        fld     st0
        fld1
        fdivrp
        fsubp
        fldq    ??.2.0
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@csh.sse.fpu
$else
  @@csh.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic tangent
; th(x) = [exp(2 * x) - 1] / [exp(2 * x) + 1]
; maximum x = 354.89135644669199842 // Ln(2^1024)/2

macro @@th.sse.fpu
{
$usprocf @@th

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rax, ??.max.cth
        fcom    qword [rax]
        fnjle  .1
    .0:
        fstp    st0
        fld1
        jmp    .return
    .1:
        fadd    st0, st0                        ; st0 = 2x
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(2x)
        fld     st0
        fld1
        fsubp
        fxch
        fld1
        faddp
        fdivp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@th.fpu
{
$usprocf @@th

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rax, ??.max.cth
        fcom    qword [rax]
        fnjle  .1
    .0:
        fstp    st0
        fld1
        jmp    .return
    .1:
        fadd    st0, st0                        ; st0 = 2x
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp(2x)
        fld     st0
        fld1
        fsubp
        fxch
        fld1
        faddp
        fdivp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@th.sse.fpu
$else
  @@th.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cotangent
; cth(x) = [exp(2 * x) + 1] / [exp(2 * x) - 1]
; maximum x = 354.89135644669199842 // Ln(2^1024)/2

macro @@cth.sse.fpu
{
$usprocf @@cth

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        mov     rax, ??.max.cth
        fcom    qword [rax]
        fnjle  .1
    .0:
        fstp    st0
        fld1
        jmp    .return
    .1:
        fadd    st0, st0                        ; st0 = 2x
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp(2x)
        fld     st0
        fld1
        faddp
        fxch
        fld1
        fsubp
        fdivp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@cth.fpu
{
$usprocf @@cth

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rax, ??.max.cth
        fcom    qword [rax]
        fnjle  .1
    .0:
        fstp    st0
        fld1
        jmp    .return
    .1:
        fadd    st0, st0                        ; st0 = 2x
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp(2x)
        fld     st0
        fld1
        faddp
        fxch
        fld1
        fsubp
        fdivp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@cth.sse.fpu
$else
  @@cth.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; inverse hyperbolic sine
; arsh(x) = ln[x + sqrt(x * x + 1)]

macro @@arsh.sse.fpu
{
$usprocf @@arsh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0
        fmul    st0, st0
        fld1
        faddp
        fsqrt
        faddp
        fldln2
        fxch
        fyl2x
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@arsh.fpu
{
$usprocf @@arsh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0
        fmul    st0, st0
        fld1
        faddp
        fsqrt
        faddp
        fldln2
        fxch
        fyl2x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arsh.sse.fpu
$else
  @@arsh.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic cosine
; arch(x) = ln[x + sqrt(x * x - 1)]

macro @@arch.sse.fpu
{
$usprocf @@arch

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0
        fmul    st0, st0
        fld1
        fsubp
        fsqrt
        faddp
        fldln2
        fxch
        fyl2x
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@arch.fpu
{
$usprocf @@arch

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0
        fmul    st0, st0
        fld1
        fsubp
        fsqrt
        faddp
        fldln2
        fxch
        fyl2x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arch.sse.fpu
$else
  @@arch.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic secant
; arsch(x) = ln[(1 + sqrt[1 - x * x]) / x]

macro @@arsch.sse.fpu
{
$usprocf @@arsch

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0
        fmul    st0, st0
        fld1
        fsubrp
        fsqrt
        fld1
        faddp
        fdivrp
        fldln2
        fxch
        fyl2x
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@arsch.fpu
{
$usprocf @@arsch

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0
        fmul    st0, st0
        fld1
        fsubrp
        fsqrt
        fld1
        faddp
        fdivrp
        fldln2
        fxch
        fyl2x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arsch.sse.fpu
$else
  @@arsch.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic cosecant
; arcsh(x) = ln[(1 + sqrt[1 + x * x]) / x]

macro @@arcsh.sse.fpu
{
$usprocf @@arcsh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0
        fmul    st0, st0
        fld1
        faddp
        fsqrt
        fld1
        faddp
        fdivrp
        fldln2
        fxch
        fyl2x
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@arcsh.fpu
{
$usprocf @@arcsh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0
        fmul    st0, st0
        fld1
        faddp
        fsqrt
        fld1
        faddp
        fdivrp
        fldln2
        fxch
        fyl2x
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arcsh.sse.fpu
$else
  @@arcsh.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic tangent
; arth(x) = 0.5 * ln[(1 + x) / (1 - x)]

macro @@arth.sse.fpu
{
$usprocf @@arth

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0
        fld1
        faddp
        fxch
        fld1
        fsubrp
        fdivp
        fldln2
        fxch
        fyl2x
        fmulq   ??.0.5
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@arth.fpu
{
$usprocf @@arth

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0
        fld1
        faddp
        fxch
        fld1
        fsubrp
        fdivp
        fldln2
        fxch
        fyl2x
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arth.sse.fpu
$else
  @@arth.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic cotangent
; arcth(x) = 0.5 * ln[(x + 1) / (x - 1)]

macro @@arcth.sse.fpu
{
$usprocf @@arcth

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0
        fld1
        faddp
        fxch
        fld1
        fsubp
        fdivp
        fldln2
        fxch
        fyl2x
        fmulq   ??.0.5
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@arcth.fpu
{
$usprocf @@arcth

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0
        fld1
        faddp
        fxch
        fld1
        fsubp
        fdivp
        fldln2
        fxch
        fyl2x
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arcth.sse.fpu
$else
  @@arcth.fpu
$end

; ------------------------------------------------------------------------------
