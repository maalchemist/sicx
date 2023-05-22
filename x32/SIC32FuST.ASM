
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (statistical functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; for internal use only
; returns total variance
; [esp + 4] -> argument count
; xmm5      -> argument count

macro @@.vvar.sse
{
$asprocf @@.vvar

        xorpd   xmm1, xmm1
    .next.arg:
        movsd   xmm2, qword [esp + ecx * 8 - 4]
        addsd   xmm1, xmm2                      ; xmm1 = sum(x[i])
        mulsd   xmm2, xmm2
        addsd   xmm0, xmm2                      ; xmm0 = sum(x[i]^2)
        dec     ecx
        jnz    .next.arg
        mulsd   xmm1, xmm1                      ; xmm1 = sum(x[i])^2
        divsd   xmm1, xmm5                      ; xmm1 = [sum(x[i])^2]/n
        subsd   xmm0, xmm1                      ; xmm0 = [total variance] = sum(x[i]^2) - [sum(x[i])^2]/n
        retn
$endp
}

macro @@.vvar.fpu
{
$asprocf @@.vvar

    .next.arg:
        fld     qword [esp + ecx * 8]
        fld     st0
        fmul    st0, st0
        fadd    st0, st2
        fxch
        fadd    st0, st3
        fstp    st3
        fstp    st1
        dec     ecx
        jnz    .next.arg                        ; ST(0)            ST(1)
        fxch                                    ; sum(x[i])        sum(x[i]^2)
        fmul    st0, st0                        ; sum(x[i])^2      sum(x[i]^2)
        fidiv   dword [esp + 4]                 ; [sum(x[i])^2]/n  sum(x[i]^2)
        fsubp                                   ; [total variance]
        retn
$endp
}

$ifdef _SSEX
  @@.vvar.sse
$else
  @@.vvar.fpu
$end

; ------------------------------------------------------------------------------

; total variance (VART): sum(i=1,n)[(x[i] - mean)^2]
; variable number of arguments
; ecx -> argument count, min=1

macro @@vvart.sse
{
$usprocf @@vvart

        xorpd   xmm0, xmm0
        test    ecx, ecx
        jz     .return

        cvtsi2sd xmm5, ecx                      ; xmm5 = argument count
        xorpd   xmm1, xmm1
    .next.arg:
        movsd   xmm2, qword [esp + ecx * 8 - 08]
        addsd   xmm1, xmm2                      ; xmm1 = sum(x[i])
        mulsd   xmm2, xmm2
        addsd   xmm0, xmm2                      ; xmm0 = sum(x[i]^2)
        dec     ecx
        jnz    .next.arg
        mulsd   xmm1, xmm1                      ; xmm1 = sum(x[i])^2
        divsd   xmm1, xmm5                      ; xmm1 = [sum(x[i])^2]/n
        subsd   xmm0, xmm1                      ; xmm0 = [total variance] = sum(x[i]^2) - [sum(x[i])^2]/n
    .return:
        retn
$endp
}

macro @@vvart.fpu
{
$usprocf @@vvart

        fldz
        test    ecx, ecx
        jz     .return

        fldz
        add     esp, -4
        mov     [esp], ecx                      ; save argument count
        mov     eax, @@.vvar
        call    eax                             ; st0 = [total variance]
        add     esp, 4
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vvart.sse
$else
  @@vvart.fpu
$end

; ------------------------------------------------------------------------------

; variance (sample variance) (VARS): [total variance] / [n-1]
; variable number of arguments
; ecx -> argument count, min=2

macro @@vvars.sse
{
$usprocf @@vvars

        xorpd   xmm0, xmm0
        test    ecx, ecx
        jz     .return

        cvtsi2sd xmm5, ecx                      ; xmm5 = argument count
        mov     eax, @@.vvar
        call    eax                             ; xmm0 = [total variance]
        xsubsd  xmm5, ??.1.0                    ; xmm5 = [n-1]
        divsd   xmm0, xmm5                      ; xmm0 = [variance]
    .return:
        retn
$endp
}

macro @@vvars.fpu
{
$usprocf @@vvars

        fldz
        test    ecx, ecx
        jz     .return

        fldz
        add     esp, -4
        mov     [esp], ecx                      ; save argument count
        mov     eax, @@.vvar
        call    eax                             ; st0 = [total variance]
        fild    dword [esp]
        fld1
        fsubp                                   ; st0 = [n-1]
        fdivp                                   ; st0 = [variance]
        add     esp, 4
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vvars.sse
$else
  @@vvars.fpu
$end

; ------------------------------------------------------------------------------

; population variance (VAR or VARP): [total variance] / [n]
; variable number of arguments
; ecx -> argument count, min=1

macro @@vvarp.sse
{
$usprocf @@vvarp

        xorpd   xmm0, xmm0
        test    ecx, ecx
        jz     .return

        cvtsi2sd xmm5, ecx                      ; xmm5 = argument count
        mov     eax, @@.vvar
        call    eax                             ; xmm0 = [total variance]
        divsd   xmm0, xmm5                      ; xmm0 = [population variance]
    .return:
        retn
$endp
}

macro @@vvarp.fpu
{
$usprocf @@vvarp

        fldz
        test    ecx, ecx
        jz     .return

        fldz
        add     esp, -4
        mov     [esp], ecx                      ; save argument count
        mov     eax, @@.vvar
        call    eax                             ; st0 = [total variance]
        fidiv   dword [esp]                     ; st0 = [population variance]
        add     esp, 4
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vvarp.sse
$else
  @@vvarp.fpu
$end

; ------------------------------------------------------------------------------

; standard deviation (sample standard deviation) (STD): sqrt[variance]
; variable number of arguments
; ecx -> argument count, min=2

macro @@vstd.sse
{
$usprocf @@vstd

        xorpd   xmm0, xmm0
        test    ecx, ecx
        jz     .return

        cvtsi2sd xmm5, ecx                      ; xmm5 = argument count
        mov     eax, @@.vvar
        call    eax                             ; xmm0 = [total variance]
        xsubsd  xmm5, ??.1.0                    ; xmm5 = [n-1]
        divsd   xmm0, xmm5                      ; xmm0 = [variance]
        sqrtsd  xmm0, xmm0                      ; xmm0 = [standard deviation]
    .return:
        retn
$endp
}

macro @@vstd.fpu
{
$usprocf @@vstd

        fldz
        test    ecx, ecx
        jz     .return

        fldz
        add     esp, -4
        mov     [esp], ecx                      ; save argument count
        mov     eax, @@.vvar
        call    eax                             ; st0 = [total variance]
        fild    dword [esp]
        fld1
        fsubp                                   ; st0 = [n-1]
        fdivp                                   ; st0 = [variance]
        fsqrt                                   ; st0 = [standard deviation]
        add     esp, 4
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vstd.sse
$else
  @@vstd.fpu
$end

; ------------------------------------------------------------------------------

; population standard deviation (STDP): sqrt[population variance]
; variable number of arguments
; ecx -> argument count, min=1

macro @@vstdp.sse
{
$usprocf @@vstdp

        xorpd   xmm0, xmm0
        test    ecx, ecx
        jz     .return

        cvtsi2sd xmm5, ecx                      ; xmm5 = argument count
        mov     eax, @@.vvar
        call    eax                             ; xmm0 = [total variance]
        divsd   xmm0, xmm5                      ; xmm0 = [population variance]
        sqrtsd  xmm0, xmm0                      ; xmm0 = [population standard deviation]
    .return:
        retn
$endp
}

macro @@vstdp.fpu
{
$usprocf @@vstdp

        fldz
        test    ecx, ecx
        jz     .return

        fldz
        add     esp, -4
        mov     [esp], ecx                      ; save argument count
        mov     eax, @@.vvar
        call    eax                             ; st0 = [total variance]
        fidiv   dword [esp]                     ; st0 = [population variance]
        fsqrt                                   ; st0 = [population standard deviation]
        add     esp, 4
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vstdp.sse
$else
  @@vstdp.fpu
$end

; ------------------------------------------------------------------------------
