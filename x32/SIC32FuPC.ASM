
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (percent functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; what is x percent of y
; x *% y = (x * y) / 100 = (x * y) * 0.01

macro @@percent.mul.sse
{
$usprocf @@percent.mul

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm1, ??.0.01
        mulsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@percent.mul.fpu
{
$usprocf @@percent.mul

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fmulp
        fmulq   ??.0.01
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@percent.mul.sse
$else
  @@percent.mul.fpu
$end

; ------------------------------------------------------------------------------

; x is what percent of y
; x /% y = (x / y) * 100

macro @@percent.div.sse
{
$usprocf @@percent.div

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        divsd   xmm0, xmm1                      ; xmm0 = x/y
        xmulsd  xmm0, ??.100.0
    .return:
        retn
$endp
}

macro @@percent.div.fpu
{
$usprocf @@percent.div

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivp                                   ; st0 = x/y
        fmulq   ??.100.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@percent.div.sse
$else
  @@percent.div.fpu
$end

; ------------------------------------------------------------------------------

; y is what percent of x
; x ~/% y = (y / x) * 100

macro @@percent.divr.sse
{
$usprocf @@percent.divr

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        divsd   xmm1, xmm0                      ; xmm1 = y/x
        movsd   xmm0, xmm1                      ; xmm0 = y/x
        xmulsd  xmm0, ??.100.0
    .return:
        retn
$endp
}

macro @@percent.divr.fpu
{
$usprocf @@percent.divr

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivrp                                  ; st0 = y/x
        fmulq   ??.100.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@percent.divr.sse
$else
  @@percent.divr.fpu
$end

; ------------------------------------------------------------------------------

; what is the percentage increase from x to y
; x +% y = [(y - x) / x] * 100 = (y / x - 1) * 100

macro @@percent.inc.sse
{
$usprocf @@percent.inc

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        divsd   xmm1, xmm0                      ; xmm1 = y/x
        movsd   xmm0, xmm1                      ; xmm0 = y/x
        xsubsd  xmm0, ??.1.0
        xmulsd  xmm0, ??.100.0
    .return:
        retn
$endp
}

macro @@percent.inc.fpu
{
$usprocf @@percent.inc

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivrp                                  ; st0 = y/x
        fld1
        fsubp
        fmulq   ??.100.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@percent.inc.sse
$else
  @@percent.inc.fpu
$end

; ------------------------------------------------------------------------------

; what is the percentage increase from y to x
; x ~+% y = [(x - y) / y] * 100 = (x / y - 1) * 100

macro @@percent.incr.sse
{
$usprocf @@percent.incr

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        divsd   xmm0, xmm1                      ; xmm0 = x/y
        xsubsd  xmm0, ??.1.0
        xmulsd  xmm0, ??.100.0
    .return:
        retn
$endp
}

macro @@percent.incr.fpu
{
$usprocf @@percent.incr

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivp                                   ; st0 = x/y
        fld1
        fsubp
        fmulq   ??.100.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@percent.incr.sse
$else
  @@percent.incr.fpu
$end

; ------------------------------------------------------------------------------

; what is the percentage decrease from x to y
; x -% y = [(x - y) / x] * 100 = (1 - y / x) * 100

macro @@percent.dec.sse
{
$usprocf @@percent.dec

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        divsd   xmm1, xmm0                      ; xmm1 = y/x
        xmovsd  xmm0, ??.1.0
        subsd   xmm0, xmm1                      ; xmm0 = 1-y/x
        xmulsd  xmm0, ??.100.0
    .return:
        retn
$endp
}

macro @@percent.dec.fpu
{
$usprocf @@percent.dec

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivrp                                  ; st0 = y/x
        fld1
        fsubrp
        fmulq   ??.100.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@percent.dec.sse
$else
  @@percent.dec.fpu
$end

; ------------------------------------------------------------------------------

; what is the percentage decrease from y to x
; x ~-% y = [(y - x) / y] * 100 = (1 - x / y) * 100

macro @@percent.decr.sse
{
$usprocf @@percent.decr

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        divsd   xmm0, xmm1                      ; xmm0 = x/y
        movsd   xmm1, xmm0                      ; xmm1 = x/y
        xmovsd  xmm0, ??.1.0
        subsd   xmm0, xmm1                      ; xmm0 = 1-x/y
        xmulsd  xmm0, ??.100.0
    .return:
        retn
$endp
}

macro @@percent.decr.fpu
{
$usprocf @@percent.decr

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivp                                   ; st0 = x/y
        fld1
        fsubrp
        fmulq   ??.100.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@percent.decr.sse
$else
  @@percent.decr.fpu
$end

; ------------------------------------------------------------------------------
