
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (power functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; power function
; safe implementation
; st0 = base
; st1 = exponent

macro @@.pow.fpu
{
       .Base    EQU rsp - 24
       .IntExp  EQU rsp - 16

   .inter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fstp    qword [.Base]                   ; save & pop Base
                                                ; st0 = exp
        fld     st0
        fabs                                    ; abs(exp)
        fldq    ??.max.int64                    ; max.int64
        fcompp                                  ; leave exp in st(0)
        fnstsw  ax
        sahf
        jb     .power                           ; exp > max.int64
        fld     st0                             ; exp in st(0) and st(1)
        frndint                                 ; round(exp)
        fcomp                                   ; compare exp and round(exp)
        fnstsw  ax
        sahf
        jne    .power

   .int.power:
        fistp   qword [.IntExp]                 ; IntExp
        mov     rax, [.IntExp]                  ; rax = Int(Exponent)
        mov     rcx, rax
        cqo
        fld1                                    ; Result = 1
        xor     rax, rdx
        sub     rax, rdx                        ; abs(exp)
        jz     .leave
        fld     qword [.Base]                   ; Base
        jmp    .int.power.entry
   .int.power.loop:
        fmul    st0, st0                        ; Base * Base
   .int.power.entry:
        shr     rax, 1
        jnc    .int.power.loop
        fmul    st1, st0                        ; Result * X
        jnz    .int.power.loop
        fstp    st0
        cmp     rcx, 0
        jge    .leave
        fld1
        fdivrp                                  ; 1/Result
        jmp    .leave

   .power:
        fld     qword [.Base]                   ; Base
   .power.enter:
        ftst
        fnstsw  ax
        sahf
        jz     .power.done
        fldln2
        fxch
        fyl2x
        fxch
        fmulp   st1, st0
        fldl2e
        fmulp   st1, st0
        fld     st0
        frndint
        fsub    st1, st0
        fxch    st1
        f2xm1
        fld1
        faddp   st1, st0
        fscale
   .power.done:
        fstp    st1

   .leave:
        @@.fpu.cw.restore                       ; restore control word
}

; double power function
; st0 = base
; st1 = exponent

macro @@.dpow.fpu
{
   .power.enter:
        ftst
        fnstsw  ax
        sahf
        jz     .power.done

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fldln2
        fxch
        fyl2x
        fxch
        fmulp   st1, st0
        fldl2e
        fmulp   st1, st0
        fld     st0
        frndint
        fsub    st1, st0
        fxch    st1
        f2xm1
        fld1
        faddp   st1, st0
        fscale

        @@.fpu.cw.restore                       ; restore control word
   .power.done:
        fstp    st1

   .leave:
}

; ------------------------------------------------------------------------------

; power function
; double pow ( double base, double exponent )
; base     = rsp
; exponent = rsp + 8

macro @@pow.sse.fpu
{
$usprocf @@pow

        movsd   xmm0, qword [rsp]               ; xmm0 = base
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = exponent
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm1                             ; st0 = exponent
        @@.fld.xmm0                             ; st0 = base, st1 = exponent
        ;
        @@.pow.fpu
   .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@pow.enter.fpu                        ; st0 = exponent, st1 = base

        fxch
        @@.pow.fpu
   .return:
        retn
$endp
}

macro @@pow.fpu
{
$usprocf @@pow

        fld     qword [rsp]                     ; st0 = base
        fld     qword [rsp + 8]                 ; st0 = exponent, st1 = base
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fxch                                    ; st0 = base, st1 = exponent
        @@.pow.fpu
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@pow.sse.fpu
$else
  @@pow.fpu
$end

; ------------------------------------------------------------------------------

$usprocf @@.pow.??

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

$usprocf @@.powr.??

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; power function
; double apow ( double base, double exponent )
; base     = rsp
; exponent = rsp + 8

macro @@apow.sse.fpu
{
$usprocf @@apow

        movsd   xmm0, qword [rsp]               ; xmm0 = base
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = exponent
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm1                             ; st0 = exponent
        @@.fld.xmm0                             ; st0 = base, st1 = exponent
        ;
        fabs                                    ; st0 = abs(base), st1 = exponent
        @@.pow.fpu
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@apow.fpu
{
$usprocf @@apow

        fld     qword [rsp]                     ; st0 = base
        fld     qword [rsp + 8]                 ; st0 = exponent, st1 = base
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxch                                    ; st0 = base, st1 = exponent
        fabs                                    ; st0 = abs(base), st1 = exponent
        @@.pow.fpu
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@apow.sse.fpu
$else
  @@apow.fpu
$end

; ------------------------------------------------------------------------------

; reverse power function
; double powr ( double exponent, double base )
; exponent = rsp
; base     = rsp + 8

macro @@powr.sse.fpu
{
$usprocf @@powr

        movsd   xmm0, qword [rsp]               ; xmm0 = exponent
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = base
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0                             ; st0 = exponent
        @@.fld.xmm1                             ; st0 = base, st1 = exponent
        ;
        @@.pow.fpu
    .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@powr.enter.fpu                       ; st0 = base, st1 = exponent

        @@.pow.fpu
    .return:
        retn
$endp
}

macro @@powr.fpu
{
$usprocf @@powr

        fld     qword [rsp]                     ; st0 = exponent
        fld     qword [rsp + 8]                 ; st0 = base, st1 = exponent
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.pow.fpu
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@powr.sse.fpu
$else
  @@powr.fpu
$end

; ------------------------------------------------------------------------------

; reverse power function
; double apowr ( double exponent, double base )
; exponent = rsp
; base     = rsp + 8

macro @@apowr.sse.fpu
{
$usprocf @@apowr

        movsd   xmm0, qword [rsp]               ; xmm0 = exponent
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = base
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0                             ; st0 = exponent
        @@.fld.xmm1                             ; st0 = base, st1 = exponent
        ;
        fabs                                    ; st0 = abs(base), st1 = exponent
        @@.pow.fpu
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@apowr.fpu
{
$usprocf @@apowr

        fld     qword [rsp]                     ; st0 = exponent
        fld     qword [rsp + 8]                 ; st0 = base, st1 = exponent
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fabs                                    ; st0 = abs(base), st1 = exponent
        @@.pow.fpu
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@apowr.sse.fpu
$else
  @@apowr.fpu
$end

; ------------------------------------------------------------------------------

; double power function
; double dpow ( double base, double exponent )
; base     = rsp
; exponent = rsp + 8

macro @@dpow.sse.fpu
{
$usprocf @@dpow

        movsd   xmm0, qword [rsp]               ; xmm0 = base
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = exponent
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm1                             ; st0 = exponent
        @@.fld.xmm0                             ; st0 = base, st1 = exponent
        ;
        @@.dpow.fpu
    .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@dpow.enter.fpu                       ; st0 = exponent, st1 = base

        fxch
        @@.dpow.fpu
    .return:
        retn
$endp
}

macro @@dpow.fpu
{
$usprocf @@dpow

        fld     qword [rsp]                     ; st0 = base
        fld     qword [rsp + 8]                 ; st0 = exponent, st1 = base
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxch                                    ; st0 = base, st1 = exponent
        @@.dpow.fpu
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@dpow.sse.fpu
$else
  @@dpow.fpu
$end

; ------------------------------------------------------------------------------

; reverse double power function
; double dpowr ( double exponent, double base )
; exponent = rsp
; base     = rsp + 8

macro @@dpowr.sse.fpu
{
$usprocf @@dpowr

        movsd   xmm0, qword [rsp]               ; xmm0 = exponent
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = base
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0                             ; st0 = exponent
        @@.fld.xmm1                             ; st0 = base, st1 = exponent
        ;
        @@.dpow.fpu
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@dpowr.fpu
{
$usprocf @@dpowr

        fld     qword [rsp]                     ; st0 = exponent
        fld     qword [rsp + 8]                 ; st0 = base, st1 = exponent
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.dpow.fpu
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@dpowr.sse.fpu
$else
  @@dpowr.fpu
$end

; ------------------------------------------------------------------------------

; integer power function
; double ipow ( double base, integer exponent )
; base     = rsp
; exponent = rsp + 8
;
; exponent in [-2^63..2^63-1] range
; returns: base ** exponent

macro @@ipow.sse
{
$usprocf @@ipow

        movsd   xmm0, qword [rsp]               ; xmm0 = base
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        mov     rax, [rsp + 8]                  ; rax = integer exponent
    .enter:
        xmovsd  xmm1, ??.1.0                    ; xmm1 = result = 1
        test    rax, rax
        jz     .assign

    .0: mov     rcx, rax
        cqo
        xor     rax, rdx
        sub     rax, rdx                        ; rax = abs(exponent)
        jz     .assign
        jmp    .2
    .1: mulsd   xmm0, xmm0                      ; x = base * base
    .2: shr     rax, 1
        jnc    .1
        mulsd   xmm1, xmm0                      ; result = result * x
        jnz    .1
        cmp     rcx, 0
        jge    .assign
        xmovsd  xmm0, ??.1.0
        divsd   xmm0, xmm1                      ; result = 1 / result
        jmp    .leave
    .assign:
        movsd   xmm0, xmm1                      ; xmm0 = result

    .leave:
    .return:
        retn
$endp

$asprocf @@ipow.enter.fpu
                                                ; st0 = base, rax = integer exponent
        fld1                                    ; result = 1
        test    rax, rax
        jz     .leave

    .0: mov     rcx, rax
        cqo
        xor     rax, rdx
        sub     rax, rdx                        ; rax = abs(exponent)
        jz     .leave
        fxch                                    ; st0 = base, st1 = 1
        jmp    .2
    .1: fmul    st0, st0                        ; x = base * base
    .2: shr     rax, 1
        jnc    .1
        fmul    st1, st0                        ; result = result * x
        jnz    .1
        fxch                                    ; st0 = result
        cmp     rcx, 0
        jge    .leave
        fld1
        fdivrp                                  ; result = 1 / result

    .leave:
        fstp    st1
    .return:
        retn
$endp
}

macro @@ipow.fpu
{
$usprocf @@ipow

        fld     qword [rsp]                     ; st0 = base
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        mov     rax, [rsp + 8]                  ; rax = integer exponent
    .enter:
        fld1                                    ; result = 1
        test    rax, rax
        jz     .leave

    .0: mov     rcx, rax
        cqo
        xor     rax, rdx
        sub     rax, rdx                        ; rax = abs(exponent)
        jz     .leave
        fxch                                    ; st0 = base, st1 = 1
        jmp    .2
    .1: fmul    st0, st0                        ; x = base * base
    .2: shr     rax, 1
        jnc    .1
        fmul    st1, st0                        ; result = result * x
        jnz    .1
        fxch                                    ; st0 = result
        cmp     rcx, 0
        jge    .leave
        fld1
        fdivrp                                  ; result = 1 / result

    .leave:
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ipow.sse
$else
  @@ipow.fpu
$end

; ------------------------------------------------------------------------------

; value raised to a power of 2

macro @@pow2.sse
{
$usprocf @@pow2

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mulsd   xmm0, xmm0
    .return:
        retn
$endp
}

macro @@pow2.fpu
{
$usprocf @@pow2

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmul    st0, st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pow2.sse
$else
  @@pow2.fpu
$end

; ------------------------------------------------------------------------------

; value raised to a power of 3

macro @@pow3.sse
{
$usprocf @@pow3

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm1, xmm0
        mulsd   xmm0, xmm0
        mulsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@pow3.fpu
{
$usprocf @@pow3

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0
        fmul    st0, st0
        fmulp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pow3.sse
$else
  @@pow3.fpu
$end

; ------------------------------------------------------------------------------

; value raised to a power of 4

macro @@pow4.sse
{
$usprocf @@pow4

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mulsd   xmm0, xmm0
        mulsd   xmm0, xmm0
    .return:
        retn
$endp
}

macro @@pow4.fpu
{
$usprocf @@pow4

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmul    st0, st0
        fmul    st0, st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pow4.sse
$else
  @@pow4.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; root function
; x^(1/y)

macro @@root.sse.fpu
{
$usprocf @@root

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm1                             ; st0 = y
        @@.fld.xmm0                             ; st0 = x, st1 = y
        ;
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(x)
        fdivrp                                  ; st0 = 1/y * ln(x)
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp[1/y * ln(x)]
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@root.fpu
{
$usprocf @@root

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxch                                    ; st0 = x, st1 = y
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(x)
        fdivrp                                  ; st0 = 1/y * ln(x)
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp[1/y * ln(x)]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@root.sse.fpu
$else
  @@root.fpu
$end

; ------------------------------------------------------------------------------

; reverse root function
; y^(1/x)

macro @@rootr.sse.fpu
{
$usprocf @@rootr

        movsd   xmm0, qword [rsp]               ; xmm0 = y
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0                             ; st0 = y
        @@.fld.xmm1                             ; st0 = x, st1 = y
        ;
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(x)
        fdivrp                                  ; st0 = 1/y * ln(x)
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp[1/y * ln(x)]
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@rootr.fpu
{
$usprocf @@rootr

        fld     qword [rsp]                     ; st0 = y
        fld     qword [rsp + 8]                 ; st0 = x, st1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(x)
        fdivrp                                  ; st0 = 1/y * ln(x)
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp[1/y * ln(x)]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rootr.sse.fpu
$else
  @@rootr.fpu
$end

; ------------------------------------------------------------------------------

; square root
; x^(1/2)

macro @@root2.sse
{
$usprocf @@root2

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        sqrtsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@root2.fpu
{
$usprocf @@root2

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsqrt
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@root2.sse
$else
  @@root2.fpu
$end

; ------------------------------------------------------------------------------

; root function
; x^(1/3)

macro @@root3.sse.fpu
{
$usprocf @@root3

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(x)
        fmulq   ??.1D3                          ; st0 = 1/3 * ln(x)
        mov     rax, @@exp.enter.fpu
        call    rax                             ; st0 = exp[1/3 * ln(x)]
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@root3.fpu
{
$usprocf @@root3

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(x)
        fmulq   ??.1D3                          ; st0 = 1/3 * ln(x)
        mov     rax, @@exp.enter
        call    rax                             ; st0 = exp[1/3 * ln(x)]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@root3.sse.fpu
$else
  @@root3.fpu
$end

; ------------------------------------------------------------------------------

; root function
; x^(1/4)

macro @@root4.sse
{
$usprocf @@root4

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        sqrtsd  xmm0, xmm0
        sqrtsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@root4.fpu
{
$usprocf @@root4

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsqrt
        fsqrt
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@root4.sse
$else
  @@root4.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; hypotenuse (pythagoras): sqrt(sqr(x) + sqr(y)])
; double hypot ( double x, double y )
; x = rsp
; y = rsp + 8
;
; hypot = |Y| * sqrt(1 + sqr(|X|/|Y|))
; |Y| = max(|x|,|y|)

macro @@hypot.sse
{
$usprocf @@hypot

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.abss xmm0, xmm1                      ; xmm0 = |x|
                                                ; xmm1 = |y|
        comisd  xmm0, xmm1                      ; compare |x| to |y|
        jbe    .1                               ; jump if |x| <= |y|
        movsd   xmm2, xmm0
        movsd   xmm0, xmm1
        movsd   xmm1, xmm2
   .1:                                          ; xmm0 = |X|
                                                ; xmm1 = |Y|
        xorpd   xmm2, xmm2                      ; xmm2 = 0
        ucomisd xmm0, xmm2                      ; compare |X| to 0
        jnz    .2
        jp     .2
   .xz:                                         ; |X|=0
        movsd   xmm0, xmm1                      ; xmm0 = |Y|
        jmp    .return
   .2:                                          ; |X|<>0
        divsd   xmm0, xmm1                      ; xmm0 = |X|/|Y|
        mulsd   xmm0, xmm0                      ; xmm0 = sqr(|X|/|Y|)
        xaddsd  xmm0, ??.1.0                    ; xmm0 = 1+sqr(|X|/|Y|)
        sqrtsd  xmm0, xmm0                      ; xmm0 = sqrt(1+sqr(|X|/|Y|))
        mulsd   xmm0, xmm1                      ; xmm0 = |Y|*sqrt(1+sqr(|X|/|Y|))
   .return:
        retn
$endp
}

macro @@hypot.fpu
{
$usprocf @@hypot                                ; -------------------------------------------------
                                                ; ST(0)                    | ST(1)        | ST(2) |
                                                ; -------------------------------------------------
        fld     qword [rsp]                     ; x                        | ?            | ?     |
        fld     qword [rsp + 8]                 ; y                        | x            | ?     |
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ;                          |              |       |
        fabs                                    ; |y|                      | x            | ?     |
        fxch                                    ; x                        | |y|          | ?     |
        fabs                                    ; |x|                      | |y|          | ?     |
                                                ; -------------------------------------------------
        fcom                                    ; compare |x| to |y|
        fnjle  .1                               ; jump if |x| <= |y|
                                                ; -------------------------------------------------
        fxch    st1                             ; |X|                      | |Y|          | ?     |
   .1:  fldz                                    ; 0                        | |X|          | |Y|   |
                                                ; -------------------------------------------------
        fcomp                                   ; compare 0 to |X|
                                                ; -------------------------------------------------
                                                ; |X|                      | |Y|          | ?     |
                                                ; -------------------------------------------------
        fnjne  .2                               ; jump if 0 <> |X|
                                                ; -------------------------------------------------
   .xz:                                         ; |X|=0
        fstp    st0                             ; |Y|                      | ?            | ?     |
        jmp    .return                          ;                          |              |       |
                                                ;                          |              |       |
   .2:  fdiv    st0, st1                        ; |X|/|Y|                  | |Y|          | ?     |
        fmul    st0, st0                        ; sqr(|X|/|Y|)             | |Y|          | ?     |
        fld1                                    ; 1                        | sqr(|X|/|Y|) | |Y|   |
        faddp                                   ; 1+sqr(|X|/|Y|)           | |Y|          | ?     |
        fsqrt                                   ; sqrt(1+sqr(|X|/|Y|))     | |Y|          | ?     |
        fmulp                                   ; |Y|*sqrt(1+sqr(|X|/|Y|)) | ?            | ?     |
                                                ; -------------------------------------------------
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@hypot.sse
$else
  @@hypot.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; sqrt(sqr(x) + sqr(y) + sqr(z))
; double hypot3 ( double x, double y, double z )
; x = rsp
; y = rsp + 8
; z = rsp + 16
;
; hypot3 = |Z| * sqrt(1 + sqr(|X|/|Z|) + sqr(|Y|/|Z|))
; |Z| = max(|x|,|y|,|z|)

macro @@hypot3.sse
{
$usprocf @@hypot3

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.abs3 xmm0, xmm1, xmm2                ; xmm0 = |x|
                                                ; xmm1 = |y|
                                                ; xmm2 = |z|
        comisd  xmm2, xmm1                      ; compare |z| to |y|
        ja     .1                               ; jump if |z| > |y|
        @@.xch  xmm2, xmm1
   .1:                                          ; xmm0 = |x|
                                                ; xmm1 = |Y|
                                                ; xmm2 = |Z|
        comisd  xmm2, xmm0                      ; compare |Z| to |x|
        ja     .2                               ; jump if |Z| > |x|
        @@.xch  xmm2, xmm0
   .2:                                          ; xmm0 = |X|
                                                ; xmm1 = |Y|
                                                ; xmm2 = |Z|
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare |Z| to 0
        jnz    .3
        jp     .3
   .zz:                                         ; |Z| = 0
        xorpd   xmm0, xmm0                      ; result = 0
        jmp    .return
   .3:
        divsd   xmm0, xmm2
        mulsd   xmm0, xmm0                      ; xmm0 = (|X|/|Z|)^2
        divsd   xmm1, xmm2
        mulsd   xmm1, xmm1                      ; xmm1 = (|Y|/|Z|)^2
        addsd   xmm0, xmm1
        xaddsd  xmm0, ??.1.0                    ; xmm0 = 1 + (|X|/|Z|)^2 + (|Y|/|Z|)^2
        sqrtsd  xmm0, xmm0                      ; xmm0 = sqrt(1 + (|X|/|Z|)^2 + (|Y|/|Z|)^2)
        mulsd   xmm0, xmm2                      ; xmm0 = |Z|*sqrt(1 + (|X|/|Z|)^2 + (|Y|/|Z|)^2)
   .return:
        retn
$endp
}

macro @@hypot3.fpu
{
$usprocf @@hypot3                               ; ----------------------------------------------------
                                                ; ST(0)                     | ST(1)        | ST(2)   |
                                                ; ----------------------------------------------------
        fld     qword [rsp]                     ; x                         | ?            | ?       |
        fld     qword [rsp + 8]                 ; y                         | x            | ?       |
        fld     qword [rsp + 16]                ; z                         | y            | x       |
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ;                           |              |         |
        fabs                                    ; |z|                       | y            | x       |
        fxch    st1                             ; y                         | |z|          | x       |
        fabs                                    ; |y|                       | |z|          | x       |
        fxch    st2                             ; x                         | |z|          | |y|     |
        fabs                                    ; |x|                       | |z|          | |y|     |
                                                ; ----------------------------------------------------
        fcom                                    ; compare |x| to |z|
        fnjg   .1                               ; jump if |x| > |z|
        fxch
   .1:                                          ; |Z|                       | |X|          | |y|     |
        fcom    st2                             ; compare |Z| to |y|
        fnjg   .2                               ; jump if |Z| > |y|
        fxch    st2
   .2:                                          ; |Z|                       | |X|          | |Y|     |
        fldz
        fcomp                                   ; compare 0 to |Z|
        fnjne  .3                               ; jump if 0 <> |Z|
   .zz:                                         ; |Z| = 0
        fstp    st0
        fstp    st0
        fstp    st0
        fldz                                    ; result = 0
        jmp    .return
   .3:
        fdiv    st1, st0                        ; |Z|                       | |X|/|Z|      | |Y|     |
        fdiv    st2, st0                        ; |Z|                       | |X|/|Z|      | |Y|/|Z| |
        fxch    st2                             ; |Y|/|Z|                   | |X|/|Z|      | |Z|     |
        fmul    st0, st0                        ; (|Y|/|Z|)^2               | |X|/|Z|      | |Z|     |
        fxch    st1                             ; |X|/|Z|                   | (|Y|/|Z|)^2  | |Z|     |
        fmul    st0, st0                        ; (|X|/|Z|)^2               | (|Y|/|Z|)^2  | |Z|     |
        fld1
        faddp
        faddp                                   ; 1+(|X|/|Z|)^2+(|Y|/|Z|)^2 | |Z|          |         |
        fsqrt
        fmulp                                   ; |Z|*sqrt(1+(|X|/|Z|)^2+(|Y|/|Z|)^2)                |
                                                ; ----------------------------------------------------
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@hypot3.sse
$else
  @@hypot3.fpu
$end

; ------------------------------------------------------------------------------
