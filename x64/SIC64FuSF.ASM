
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (special functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; natural logarithm of factorial
; double factln ( double x )
;
; factln(x) = lgamma(x+1)

macro @@factln.sse
{
$usprocf @@factln

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5
        mov     rax, @@flgamma.enter
        call    rax
    .return:
        retn
$endp
}

macro @@factln.fpu
{
$usprocf @@factln

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1
        faddp
        mov     rax, @@flgamma.enter
        call    rax
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@factln.sse
$else
  @@factln.fpu
$end

; ------------------------------------------------------------------------------

; natural logarithm of factorial
; double factln ( integer x )
;
; factln(x) = lgamma(x+1)

macro @@_factln_int.sse
{
$usprocf @@_factln_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5
        mov     rax, @@flgamma.enter
        call    rax
    .return:
        retn
$endp
}

macro @@_factln_int.fpu
{
$usprocf @@_factln_int

        fild    qword [rsp]
    .enter:
        fld1
        faddp
        mov     rax, @@flgamma.enter
        call    rax
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_factln_int.sse
$else
  @@_factln_int.fpu
$end

; ------------------------------------------------------------------------------

; floating-point factorial !
; double fact ( double x )
;
; fact(x) = tgamma(x+1)

macro @@fact.sse
{
$usprocf @@fact

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5
        mov     rax, @@ftgamma.enter
        call    rax
    .return:
        retn
$endp
}

macro @@fact.fpu
{
$usprocf @@fact

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1
        faddp
        mov     rax, @@ftgamma.enter
        call    rax
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fact.sse
$else
  @@fact.fpu
$end

; ------------------------------------------------------------------------------

; floating-point factorial !
; double fact ( integer x )
;
; fact(x) = tgamma(x+1)

macro @@_fact_int.sse
{
$usprocf @@_fact_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5
        mov     rax, @@ftgamma.enter
        call    rax
    .return:
        retn
$endp
}

macro @@_fact_int.fpu
{
$usprocf @@_fact_int

        fild    qword [rsp]
    .enter:
        fld1
        faddp
        mov     rax, @@ftgamma.enter
        call    rax
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fact_int.sse
$else
  @@_fact_int.fpu
$end

; ------------------------------------------------------------------------------

; double factorial !!
; double fact2 ( double x )

macro @@fact2.sse ; TODO
{
$usprocf @@fact2

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
    .return:
        retn
$endp
}

macro @@fact2.fpu ; TODO
{
$usprocf @@fact2

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fact2.sse
$else
  @@fact2.fpu
$end

; ------------------------------------------------------------------------------

; double factorial !!
; double fact2 ( integer x )

macro @@_fact2_int.sse ; TODO
{
$usprocf @@_fact2_int

        cvtsi2sd xmm0, qword [rsp]
    .return:
        retn
$endp
}

macro @@_fact2_int.fpu ; TODO
{
$usprocf @@_fact2_int

        fild    qword [rsp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_fact2_int.sse
$else
  @@_fact2_int.fpu
$end

; ------------------------------------------------------------------------------
