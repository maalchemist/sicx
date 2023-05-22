
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (base functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; test function with 2 return values
; double double test_r2 ( double x, double y )
; x = rsp
; y = rsp + 8
;
; return_1 = st1 = x+y
; return_2 = st0 = x-y

macro @@.test_r2
{
$usprocf @@test_r2

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld     st1                             ; st0 = x, st1 = y, st2 = x
        fld     st1                             ; st0 = y, st1 = x, st2 = y, st3 = x
        fsubp                                   ; st0 = x-y, st1 = y, st2 = x
        fxch                                    ; st0 = y, st1 = x-y, st2 = x
        faddp   st2, st0                        ; st0 = x-y, st1 = x+y
   .return:
        retn
$endp
}
; ------------------------------------------------------------------------------

; test function with 4 return values
; double double double double test_r4 ( double x )
; x = rsp
;
; return_1 = st3 = x
; return_2 = st2 = x*x
; return_3 = st1 = x*x*x
; return_4 = st0 = x*x*x*x

macro @@.test_r4
{
$usprocf @@test_r4

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld     st0                             ; st0 = x, st1 = x
        fmul    st0, st1                        ; st0 = x*x, st1 = x
        fld     st0                             ; st0 = x*x, st1 = x*x, st2 = x
        fmul    st0, st2                        ; st0 = x*x*x, st1 = x*x, st2 = x
        fld     st0                             ; st0 = x*x*x, st1 = x*x*x, st2 = x*x, st3 = x
        fmul    st0, st3                        ; st0 = x*x*x*x, st1 = x*x*x, st2 = x*x, st3 = x
   .return:
        retn
$endp
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; returns the arithmetic average of two values
; double mean ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@mean.sse
{
$usprocf @@mean

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        addsd   xmm0, xmm1                      ; xmm0 = x + y
        xmulsd  xmm0, ??.0.5                    ; xmm0 = 0.5 * (x + y)

   .return:
        retn
$endp
}

macro @@mean.fpu
{
$usprocf @@mean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        faddp                                   ; st0 = x + y
        fmulq   ??.0.5                          ; st0 = 0.5 * (x + y)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@mean.sse
$else
  @@mean.fpu
$end

; ------------------------------------------------------------------------------

; returns the delta average of two values
; f(x,y) = (x-y)/2
; double dmean ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@dmean.sse
{
$usprocf @@dmean

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        subsd   xmm0, xmm1                      ; xmm0 = x - y
        xmulsd  xmm0, ??.0.5                    ; xmm0 = 0.5 * (x - y)

   .return:
        retn
$endp
}

macro @@dmean.fpu
{
$usprocf @@dmean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fsubp                                   ; st0 = x - y
        fmulq   ??.0.5                          ; st0 = 0.5 * (x - y)

   .return:
        retn
$endp
}

$ifdef _SSEX
; @@dmean.sse
$else
; @@dmean.fpu
$end

; ------------------------------------------------------------------------------

; returns the reverse delta average of two values
; f(x,y) = (y-x)/2
; double dmeanr ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@dmeanr.sse
{
$usprocf @@dmeanr

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        subsd   xmm1, xmm0                      ; xmm1 = y - x
        xmulsd  xmm1, ??.0.5                    ; xmm1 = 0.5 * (y - x)
        movsd   xmm0, xmm1                      ; xmm0 = 0.5 * (y - x)

   .return:
        retn
$endp
}

macro @@dmeanr.fpu
{
$usprocf @@dmeanr

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fsubrp                                  ; st0 = y - x
        fmulq   ??.0.5                          ; st0 = 0.5 * (y - x)

   .return:
        retn
$endp
}

$ifdef _SSEX
; @@dmeanr.sse
$else
; @@dmeanr.fpu
$end

; ------------------------------------------------------------------------------

; returns the geometric average of two values
; double gmean ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@gmean.sse
{
$usprocf @@gmean

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        sqrtsd  xmm0, xmm0                      ; xmm0 = x^(1/2)
        sqrtsd  xmm1, xmm1                      ; xmm1 = y^(1/2)
        mulsd   xmm0, xmm1                      ; xmm0 = (x * y)^(1/2)

   .return:
        retn
$endp
}

macro @@gmean.fpu
{
$usprocf @@gmean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fsqrt
        fxch
        fsqrt
        fmulp                                   ; st0 = (x * y)^(1/2)

   .return:
        retn
$endp
}

macro @@gmean.fpu.V2
{
$usprocf @@gmean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulp                                   ; st0 = x * y
        fsqrt                                   ; st0 = (x * y)^(1/2)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@gmean.sse
$else
  @@gmean.fpu
$end

; ------------------------------------------------------------------------------

; returns the harmonic average of two values
; double hmean ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@hmean.sse
{
$usprocf @@hmean

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm1                      ; xmm2 = y
        addsd   xmm2, xmm0                      ; xmm2 = x + y
        mulsd   xmm0, xmm1                      ; xmm0 = x * y
        divsd   xmm0, xmm2                      ; xmm0 = x * y / (x + y)
        addsd   xmm0, xmm0                      ; xmm0 = 2 * x * y / (x + y)

   .return:
        retn
$endp
}

macro @@hmean.fpu
{
$usprocf @@hmean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld     st1                             ; st0 = x, st1 = y, st1 = x
        fld     st1                             ; st0 = y, st1 = x, st2 = y, st4 = x
        fmulp                                   ; st0 = x * y, st1 = y, st2 = x
        fxch    st2                             ; st0 = x, st1 = y, st2 = x * y
        faddp                                   ; st0 = x + y, st1 = x * y
        fdivp                                   ; st0 = x * y / (x + y)
        fld     st0
        faddp                                   ; st0 = 2 * x * y / (x + y)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@hmean.sse
$else
  @@hmean.fpu
$end

; ------------------------------------------------------------------------------

; returns the contraharmonic average of two values
; double chmean ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@chmean.sse
{
$usprocf @@chmean

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm1                      ; xmm2 = y
        addsd   xmm2, xmm0                      ; xmm2 = x + y
        mulsd   xmm0, xmm0                      ; xmm0 = x^2
        mulsd   xmm1, xmm1                      ; xmm1 = y^2
        addsd   xmm0, xmm1                      ; xmm0 = x^2 + y^2
        divsd   xmm0, xmm2                      ; xmm0 = (x^2 + y^2) / (x + y)

   .return:
        retn
$endp
}

macro @@chmean.fpu
{
$usprocf @@chmean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld     st1                             ; st0 = x, st1 = y, st2 = x
        fmul    st2, st0                        ; st0 = x, st1 = y, st2 = x^2
        fld     st1                             ; st0 = y, st1 = x, st2 = y, st3 = x^2
        fmul    st2, st0                        ; st0 = y, st1 = x, st2 = y^2, st3 = x^2
        faddp                                   ; st0 = x + y, st1 = y^2, st2 = x^2
        fxch    st2                             ; st0 = x^2, st1 = y^2, st2 = x + y
        faddp                                   ; st0 = x^2 + y^2, st1 = x + y
        fdivrp                                  ; st0 = (x^2 + y^2) / (x + y)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@chmean.sse
$else
  @@chmean.fpu
$end

; ------------------------------------------------------------------------------

; returns the quadratic average of two values
; double qmean ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@qmean.sse
{
$usprocf @@qmean

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
        jmp    .3
   .2:                                          ; |X|<>0
        divsd   xmm0, xmm1                      ; xmm0 = |X|/|Y|
        mulsd   xmm0, xmm0                      ; xmm0 = sqr(|X|/|Y|)
        xaddsd  xmm0, ??.1.0                    ; xmm0 = 1+sqr(|X|/|Y|)
        sqrtsd  xmm0, xmm0                      ; xmm0 = sqrt(1+sqr(|X|/|Y|))
        mulsd   xmm0, xmm1                      ; xmm0 = |Y|*sqrt(1+sqr(|X|/|Y|))
   .3:
        xmulsd  xmm0, ??.2m0.5                  ; xmm0 = (1/SQRT(2))*sqrt(x^2 + y^2)

   .return:
        retn
$endp
}

macro @@qmean.sse.V2
{
$usprocf @@qmean

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm0                      ; xmm0 = x^2
        mulsd   xmm1, xmm1                      ; xmm1 = y^2
        addsd   xmm0, xmm1                      ; xmm0 = x^2 + y^2
        sqrtsd  xmm0, xmm0                      ; xmm0 = sqrt(x^2 + y^2)
        xmulsd  xmm0, ??.2m0.5                  ; xmm0 = (1/SQRT(2))*sqrt(x^2 + y^2)

   .return:
        retn
$endp
}

macro @@qmean.fpu
{
$usprocf @@qmean                                ; -------------------------------------------------
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
        fstp    st0                             ; |Y|                      | ?            | ?     |
        jmp    .3                               ;                          |              |       |
                                                ;                          |              |       |
   .2:  fdiv    st0, st1                        ; |X|/|Y|                  | |Y|          | ?     |
        fmul    st0, st0                        ; sqr(|X|/|Y|)             | |Y|          | ?     |
        fld1                                    ; 1                        | sqr(|X|/|Y|) | |Y|   |
        faddp                                   ; 1+sqr(|X|/|Y|)           | |Y|          | ?     |
        fsqrt                                   ; sqrt(1+sqr(|X|/|Y|))     | |Y|          | ?     |
        fmulp                                   ; |Y|*sqrt(1+sqr(|X|/|Y|)) | ?            | ?     |
   .3:                                          ; -------------------------------------------------
        fmulq   ??.2m0.5                        ; st0 = (1/SQRT(2))*sqrt(x^2 + y^2)
   .return:
        retn
$endp
}

macro @@qmean.fpu.V2
{
$usprocf @@qmean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmul    st0, st0                        ; st0 = y^2, st1 = x
        fxch                                    ; st0 = x, st1 = y^2
        fmul    st0, st0                        ; st0 = x^2, st1 = y^2
        faddp                                   ; st0 = x^2 + y^2
        fsqrt                                   ; st0 = sqrt(x^2 + y^2)
        fmulq   ??.2m0.5                        ; st0 = (1/SQRT(2))*sqrt(x^2 + y^2)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@qmean.sse
$else
  @@qmean.fpu
$end

; ------------------------------------------------------------------------------

; returns the heronian average of two values
; double hemean ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@hemean.sse
{
$usprocf @@hemean

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0                      ; xmm2 = x
        sqrtsd  xmm2, xmm2                      ; xmm2 = sqrt(x)
        movsd   xmm3, xmm1                      ; xmm3 = y
        sqrtsd  xmm3, xmm3                      ; xmm3 = sqrt(y)
        mulsd   xmm2, xmm3                      ; xmm2 = sqrt(x * y)
        addsd   xmm0, xmm2                      ; xmm0 = x + sqrt(x * y)
        addsd   xmm0, xmm1                      ; xmm0 = (x + sqrt(x * y) + y)
        xmulsd  xmm0, ??.1D3                    ; xmm0 = (x + sqrt(x * y) + y) * (1/3)

   .return:
        retn
$endp
}

macro @@hemean.sse.V2
{
$usprocf @@hemean

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm1                      ; xmm2 = y
        mulsd   xmm2, xmm0                      ; xmm2 = x * y
        sqrtsd  xmm2, xmm2                      ; xmm2 = sqrt(x * y)
        addsd   xmm0, xmm2                      ; xmm0 = x + sqrt(x * y)
        addsd   xmm0, xmm1                      ; xmm0 = (x + sqrt(x * y) + y)
        xmulsd  xmm0, ??.1D3                    ; xmm0 = (x + sqrt(x * y) + y) * (1/3)

   .return:
        retn
$endp
}

macro @@hemean.fpu
{
$usprocf @@hemean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld     st1                             ; st0 = x, st1 = y, st2 = x
        fsqrt                                   ; st0 = sqrt(x), st1 = y, st2 = x
        fld     st1                             ; st0 = y, st1 = sqrt(x), st2 = y, st3 = x
        fsqrt                                   ; st0 = sqrt(y), st1 = sqrt(x), st2 = y, st3 = x
        fmulp                                   ; st0 = sqrt(x * y), st1 = y, st2 = x
        faddp                                   ; st0 = sqrt(x * y) + y, st1 = x
        faddp                                   ; st0 = (x + sqrt(x * y) + y)
        fmulq   ??.1D3                          ; st0 = (x + sqrt(x * y) + y) * (1/3)

   .return:
        retn
$endp
}

macro @@hemean.fpu.V2
{
$usprocf @@hemean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld     st0                             ; st0 = y, st1 = y, st2 = x
        fmul    st0, st2                        ; st0 = x * y, st1 = y, st2 = x
        fsqrt                                   ; st0 = sqrt(x * y), st1 = y, st2 = x
        faddp                                   ; st0 = sqrt(x * y) + y, st1 = x
        faddp                                   ; st0 = (x + sqrt(x * y) + y)
        fmulq   ??.1D3                          ; st0 = (x + sqrt(x * y) + y) * (1/3)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@hemean.sse
$else
  @@hemean.fpu
$end

; ------------------------------------------------------------------------------

; returns the centroidal average of two values
; double cemean ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@cemean.sse
{
$usprocf @@cemean

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0                      ; xmm2 = x
        mulsd   xmm2, xmm2                      ; xmm2 = x^2
        movsd   xmm3, xmm1                      ; xmm3 = y
        mulsd   xmm3, xmm3                      ; xmm3 = y^2
        addsd   xmm3, xmm2                      ; xmm3 = x^2 + y^2
        movsd   xmm2, xmm0                      ; xmm2 = x
        mulsd   xmm0, xmm1                      ; xmm0 = x * y
        addsd   xmm0, xmm3                      ; xmm0 = (x^2 + (x * y) + y^2)
        addsd   xmm1, xmm2                      ; xmm1 = (x + y)
        divsd   xmm0, xmm1                      ; xmm0 = (x^2 + (x * y) + y^2) / (x + y)
        xmulsd  xmm0, ??.2D3                    ; xmm0 = (x^2 + (x * y) + y^2) / (x + y) * (2/3)

   .return:
        retn
$endp
}

macro @@cemean.fpu
{
$usprocf @@cemean

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld     st1                             ; st0 = x, st1 = y, st2 = x
        fld     st1                             ; st0 = y, st1 = x, st2 = y, st3 = x
        fadd    st3, st0                        ; st0 = y, st1 = x, st2 = y, st3 = (x + y)
        fmul    st2, st0                        ; st0 = y, st1 = x, st2 = y^2, st3 = (x + y)
        fld     st1                             ; st0 = x, st1 = y, st2 = x, st3 = y^2, st4 = (x + y)
        fmul    st2, st0                        ; st0 = x, st1 = y, st2 = x^2, st3 = y^2, st4 = (x + y)
        fmulp                                   ; st0 = (x * y), st1 = x^2, st2 = y^2, st3 = (x + y)
        faddp                                   ; st0 = x^2 + (x * y), st1 = y^2, st2 = (x + y)
        faddp                                   ; st0 = (x^2 + (x * y) + y^2), st1 = (x + y)
        fdivrp                                  ; st0 = (x^2 + (x * y) + y^2) / (x + y)
        fmulq   ??.2D3                          ; st0 = (x^2 + (x * y) + y^2) / (x + y) * (2/3)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cemean.sse
$else
  @@cemean.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
;
; returns the smaller of two values
; double min ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@min.sse
{
$usprocf @@min

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        minsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@min.fpu
{
$usprocf @@min

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcom                                    ; compare y to x
        fnjl   .y                               ; jump if y < x

    .x: fstp    st0                             ; return x, y >= x
        jmp    .return
    .y: fstp    st1                             ; return y, y < x

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@min.sse
$else
  @@min.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the smaller of two values
; double min ( integer x, integer y )
; x = rsp
; y = rsp + 8

macro @@_min_int.sse
{
$usprocf @@_min_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rcx, qword [rsp + 8]            ; rcx = y
        cmp     rax, rcx
        jle    .load
        mov     rax, rcx

    .load:
        cvtsi2sd xmm0, rax

    .return:
        retn
$endp
}

macro @@_min_int.fpu
{
$usprocf @@_min_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rcx, qword [rsp + 8]            ; rcx = y
        cmp     rax, rcx
        jle    .load
        mov     rax, rcx

    .load:
        mov     [rsp - 8], rax
        fild    qword [rsp - 8]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_min_int.sse
$else
  @@_min_int.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the smaller of two values
; double min ( integer x, integer y )
; x = rax
; y = rcx

macro @@_min_reg.sse
{
$usprocf @@_min_reg

        cmp     rax, rcx
        jle    .load
        mov     rax, rcx

    .load:
        cvtsi2sd xmm0, rax

    .return:
        retn
$endp
}

macro @@_min_reg.fpu
{
$usprocf @@_min_reg

        cmp     rax, rcx
        jle    .load
        mov     rax, rcx

    .load:
        mov     [rsp - 8], rax
        fild    qword [rsp - 8]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_min_reg.sse
$else
  @@_min_reg.fpu
$end

; ------------------------------------------------------------------------------

; returns the larger of two values
; double max ( double x, double y )
; x = rsp
; y = rsp + 8

macro @@max.sse
{
$usprocf @@max

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        maxsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@max.fpu
{
$usprocf @@max

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcom                                    ; compare y to x
        fnjge  .y                               ; jump if y >= x

    .x: fstp    st0                             ; return x, y < x
        jmp    .return
    .y: fstp    st1                             ; return y, y >= x

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@max.sse
$else
  @@max.fpu
$end

; ------------------------------------------------------------------------------

; returns the larger of two values
; double max ( integer x, integer y )
; x = rsp
; y = rsp + 8

macro @@_max_int.sse
{
$usprocf @@_max_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rcx, qword [rsp + 8]            ; rcx = y
        cmp     rax, rcx
        jge    .load
        mov     rax, rcx

    .load:
        cvtsi2sd xmm0, rax

    .return:
        retn
$endp
}

macro @@_max_int.fpu
{
$usprocf @@_max_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rcx, qword [rsp + 8]            ; rcx = y
        cmp     rax, rcx
        jge    .load
        mov     rax, rcx

    .load:
        mov     [rsp - 8], rax
        fild    qword [rsp - 8]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_max_int.sse
$else
  @@_max_int.fpu
$end

; ------------------------------------------------------------------------------

; returns the larger of two values
; double max ( integer x, integer y )
; x = rax
; y = rcx

macro @@_max_reg.sse
{
$usprocf @@_max_reg

        cmp     rax, rcx
        jge    .load
        mov     rax, rcx

    .load:
        cvtsi2sd xmm0, rax

    .return:
        retn
$endp
}

macro @@_max_reg.fpu
{
$usprocf @@_max_reg

        cmp     rax, rcx
        jge    .load
        mov     rax, rcx

    .load:
        mov     [rsp - 8], rax
        fild    qword [rsp - 8]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_max_reg.sse
$else
  @@_max_reg.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the smaller and the larger of two values
; double double minmax ( double x, double y )
; x = rsp
; y = rsp + 8
;
; return_1 = st1 = min
; return_2 = st0 = max

macro @@minmax.sse
{
$usprocf @@minmax

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        jbe    .return
        pxor    xmm0, xmm1                      ; exchange xmm0 and xmm1
        pxor    xmm1, xmm0
        pxor    xmm0, xmm1
    .return:
        retn
$endp
}

macro @@minmax.fpu
{
$usprocf @@minmax

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcom                                    ; compare y to x
        fnjg   .return                          ; jump if y > x
        fxch
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@minmax.sse
$else
  @@minmax.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the smaller and the larger of two values
; double co.minmax ( double *min, double *max, double x, double y )
; x = rsp
; y = rsp + 8
;
; rax = min offset
; rdx = max offset
;
; return_1 = st1 = min
; return_2 = st0 = max

macro @@co.minmax.sse
{
$usprocf @@co.minmax

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        jbe    .assign
        pxor    xmm0, xmm1                      ; exchange xmm0 and xmm1
        pxor    xmm1, xmm0
        pxor    xmm0, xmm1
    .assign:
        movsd   qword [rax], xmm0
        movsd   qword [rdx], xmm1
    .return:
        retn
$endp
}

macro @@co.minmax.fpu
{
$usprocf @@co.minmax

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     r10, rax                        ; save rax
        fcom                                    ; compare y to x
        fnjg   .assign                          ; jump if y > x
        fxch
    .assign:
        fstp    qword [rdx]
        fst     qword [r10]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.minmax.sse
$else
  @@co.minmax.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the larger and the smaller of two values
; double double maxmin ( double x, double y )
; x = rsp
; y = rsp + 8
;
; return_1 = st1 = max
; return_2 = st0 = min

macro @@maxmin.sse
{
$usprocf @@maxmin

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        jae    .return
        pxor    xmm0, xmm1                      ; exchange xmm0 and xmm1
        pxor    xmm1, xmm0
        pxor    xmm0, xmm1
    .return:
        retn
$endp
}

macro @@maxmin.fpu
{
$usprocf @@maxmin

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcom                                    ; compare y to x
        fnjl   .return                          ; jump if y < x
        fxch
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@maxmin.sse
$else
  @@maxmin.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the larger and the smaller of two values
; double co.maxmin ( double *max, double *min, double x, double y )
; x = rsp
; y = rsp + 8
;
; rax = max offset
; rdx = min offset
;
; return_1 = st1 = max
; return_2 = st0 = min

macro @@co.maxmin.sse
{
$usprocf @@co.maxmin

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        jae    .assign
        pxor    xmm0, xmm1                      ; exchange xmm0 and xmm1
        pxor    xmm1, xmm0
        pxor    xmm0, xmm1
    .assign:
        movsd   qword [rax], xmm0
        movsd   qword [rdx], xmm1
    .return:
        retn
$endp
}

macro @@co.maxmin.fpu
{
$usprocf @@co.maxmin

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     r10, rax                        ; save rax
        fcom                                    ; compare y to x
        fnjl   .assign                          ; jump if y < x
        fxch
    .assign:
        fstp    qword [rdx]
        fst     qword [r10]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.maxmin.sse
$else
  @@co.maxmin.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the value of the absolute deviation
; double adev ( double x, double y )
; deviation = abs(x - y)
;
; x = rsp
; y = rsp + 8

macro @@adev.sse
{
$usprocf @@adev

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        subsd   xmm0, xmm1
        @@.abs  xmm0

    .return:
        retn
$endp
}

macro @@adev.fpu
{
$usprocf @@adev

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
    .enter:
        fsubp
        fabs

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@adev.sse
$else
  @@adev.fpu
$end

; ------------------------------------------------------------------------------

; returns the value of the absolute deviation
; double adev ( integer x, integer y )
; deviation = abs(x - y)
;
; x = rsp
; y = rsp + 8

macro @@_adev_int.sse
{
$usprocf @@_adev_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rcx, qword [rsp + 8]            ; rcx = y
        sub     rax, rcx
        jge    .load
        neg     rax
    .load:
        cvtsi2sd xmm0, rax

    .return:
        retn
$endp
}

macro @@_adev_int.fpu
{
$usprocf @@_adev_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rcx, qword [rsp + 8]            ; rcx = y
        sub     rax, rcx
        jge    .load
        neg     rax
    .load:
        mov     qword [rsp], rax
        fild    qword [rsp]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_adev_int.sse
$else
  @@_adev_int.fpu
$end

; ------------------------------------------------------------------------------

; returns the value of the absolute deviation
; double adev ( integer x, integer y )
; deviation = abs(x - y)
;
; x = rax
; y = rcx

macro @@_adev_reg.sse
{
$usprocf @@_adev_reg

        sub     rax, rcx
        jge    .load
        neg     rax
    .load:
        cvtsi2sd xmm0, rax

    .return:
        retn
$endp
}

macro @@_adev_reg.fpu
{
$usprocf @@_adev_reg

        sub     rax, rcx
        jge    .load
        neg     rax
    .load:
        mov     qword [rsp], rax
        fild    qword [rsp]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_adev_reg.sse
$else
  @@_adev_reg.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the value of the negative absolute deviation
; double nadev ( double x, double y )
; deviation = -abs(x - y)
;
; x = rsp
; y = rsp + 8

macro @@nadev.sse
{
$usprocf @@nadev

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        subsd   xmm0, xmm1
        @@.nabs xmm0

    .return:
        retn
$endp
}

macro @@nadev.fpu
{
$usprocf @@nadev

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
    .enter:
        fsubp
        fabs
        fchs

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@nadev.sse
$else
  @@nadev.fpu
$end

; ------------------------------------------------------------------------------

; returns the value of the negative absolute deviation
; double nadev ( integer x, integer y )
; deviation = -abs(x - y)
;
; x = rsp
; y = rsp + 8

macro @@_nadev_int.sse
{
$usprocf @@_nadev_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rcx, qword [rsp + 8]            ; rcx = y
        sub     rax, rcx
        jle    .load
        neg     rax
    .load:
        cvtsi2sd xmm0, rax

    .return:
        retn
$endp
}

macro @@_nadev_int.fpu
{
$usprocf @@_nadev_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rcx, qword [rsp + 8]            ; rcx = y
        sub     rax, rcx
        jle    .load
        neg     rax
    .load:
        mov     qword [rsp], rax
        fild    qword [rsp]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_nadev_int.sse
$else
  @@_nadev_int.fpu
$end

; ------------------------------------------------------------------------------

; returns the value of the negative absolute deviation
; double nadev ( integer x, integer y )
; deviation = -abs(x - y)
;
; x = rax
; y = rcx

macro @@_nadev_reg.sse
{
$usprocf @@_nadev_reg

        sub     rax, rcx
        jle    .load
        neg     rax
    .load:
        cvtsi2sd xmm0, rax

    .return:
        retn
$endp
}

macro @@_nadev_reg.fpu
{
$usprocf @@_nadev_reg

        sub     rax, rcx
        jle    .load
        neg     rax
    .load:
        mov     qword [rsp], rax
        fild    qword [rsp]

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_nadev_reg.sse
$else
  @@_nadev_reg.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the value of the smaller absolute deviation
; double min.adev ( double x, double y, double a )
; deviation[i] = abs(a - x[i])
;
; x = rsp
; y = rsp + 8
; a = rsp + 16

macro @@min.adev.sse
{
$usprocf @@min.adev

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = a
    .enter:
        subsd   xmm0, xmm2
        subsd   xmm1, xmm2
        @@.abss xmm0, xmm1
        minsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@min.adev.fpu
{
$usprocf @@min.adev

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = a, st1 = y, st2 = x
    .enter:
        fld     st0                             ; st0 = a, st1 = a, st2 = y, st3 = x
        fsubp   st2, st0                        ; st0 = a, st1 = (y - a), st2 = x
        fsubp   st2, st0                        ; st0 = (y - a), st1 = (x - a)
        fabs                                    ; st0 = abs(y - a), st1 = (x - a)
        fxch                                    ; st0 = (x - a), st1 = abs(y - a)
        fabs                                    ; st0 = abs(x - a), st1 = abs(y - a)
        fcom                                    ; compare abs(x - a) to abs(y - a)
        fnjle  .x                               ; jump if abs(x - a) <= abs(y - a)

    .y: fstp    st0                             ; return abs(y - a)
        jmp    .return
    .x: fstp    st1                             ; return abs(x - a)

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@min.adev.sse
$else
  @@min.adev.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the value with the smaller absolute deviation
; prefer argument with a lower index
; double minl.adev ( double x, double y, double a )
; deviation[i] = abs(a - x[i])
;
; x = rsp
; y = rsp + 8
; a = rsp + 16

macro @@minl.adev.sse
{
$usprocf @@minl.adev

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = a
    .enter:
        movsd   xmm3, xmm2                      ; xmm3 = a
        subsd   xmm2, xmm0
        @@.abs  xmm2
        subsd   xmm3, xmm1
        @@.abs  xmm3
        comisd  xmm2, xmm3
        jbe    .return
        movsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@minl.adev.fpu
{
$usprocf @@minl.adev

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = a, st1 = y, st2 = x
    .enter:
        fld     st0                             ; st0 = a, st1 = a, st2 = y, st3 = x
        fsub    st0, st2                        ; st0 = (a - y), st1 = a, st2 = y, st3 = x
        fabs                                    ; st0 = abs(a - y), st1 = a, st2 = y, st3 = x
        fxch                                    ; st0 = a, st1 = abs(a - y), st2 = y, st3 = x
        fsub    st0, st3                        ; st0 = a - x, st1 = abs(a - y), st2 = y, st3 = x
        fabs                                    ; st0 = abs(a - x), st1 = abs(a - y), st2 = y, st3 = x
        fcompp                                  ; compare abs(a - x) to abs(a - y) ; st0 = y, st1 = x
        fnjle  .x                               ; jump if abs(a - x) <= abs(a - y)

    .y: fstp    st1                             ; return y, abs(a - y) < abs(a - x)
        jmp    .return
    .x: fstp    st0                             ; return x, abs(a - x) <= abs(a - y)

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@minl.adev.sse
$else
  @@minl.adev.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the value with the smaller absolute deviation
; prefer argument with a higher index
; double minh.adev ( double x, double y, double a )
; deviation[i] = abs(a - x[i])
;
; x = rsp
; y = rsp + 8
; a = rsp + 16

macro @@minh.adev.sse
{
$usprocf @@minh.adev

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = a
    .enter:
        movsd   xmm3, xmm2                      ; xmm3 = a
        subsd   xmm2, xmm0
        @@.abs  xmm2
        subsd   xmm3, xmm1
        @@.abs  xmm3
        comisd  xmm2, xmm3
        jb     .return
        movsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@minh.adev.fpu
{
$usprocf @@minh.adev

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = a, st1 = y, st2 = x
    .enter:
        fld     st0                             ; st0 = a, st1 = a, st2 = y, st3 = x
        fsub    st0, st2                        ; st0 = (a - y), st1 = a, st2 = y, st3 = x
        fabs                                    ; st0 = abs(a - y), st1 = a, st2 = y, st3 = x
        fxch                                    ; st0 = a, st1 = abs(a - y), st2 = y, st3 = x
        fsub    st0, st3                        ; st0 = a - x, st1 = abs(a - y), st2 = y, st3 = x
        fabs                                    ; st0 = abs(a - x), st1 = abs(a - y), st2 = y, st3 = x
        fcompp                                  ; compare abs(a - x) to abs(a - y) ; st0 = y, st1 = x
        fnjge  .y                               ; jump if abs(a - x) >= abs(a - y)

    .x: fstp    st0                             ; return x, abs(a - x) < abs(a - y)
        jmp    .return
    .y: fstp    st1                             ; return y, abs(a - y) <= abs(a - x)

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@minh.adev.sse
$else
  @@minh.adev.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the value of the larger absolute deviation
; double max.adev ( double x, double y, double a )
; deviation[i] = abs(a - x[i])
;
; x = rsp
; y = rsp + 8
; a = rsp + 16

macro @@max.adev.sse
{
$usprocf @@max.adev

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = a
    .enter:
        subsd   xmm0, xmm2
        subsd   xmm1, xmm2
        @@.abss xmm0, xmm1
        maxsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@max.adev.fpu
{
$usprocf @@max.adev

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = a, st1 = y, st2 = x
    .enter:
        fld     st0                             ; st0 = a, st1 = a, st2 = y, st3 = x
        fsubp   st2, st0                        ; st0 = a, st1 = (y - a), st2 = x
        fsubp   st2, st0                        ; st0 = (y - a), st1 = (x - a)
        fabs                                    ; st0 = abs(y - a), st1 = (x - a)
        fxch                                    ; st0 = (x - a), st1 = abs(y - a)
        fabs                                    ; st0 = abs(x - a), st1 = abs(y - a)
        fcom                                    ; compare abs(x - a) to abs(y - a)
        fnjge  .x                               ; jump if abs(x - a) >= abs(y - a)

    .y: fstp    st0                             ; return abs(y - a)
        jmp    .return
    .x: fstp    st1                             ; return abs(x - a)

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@max.adev.sse
$else
  @@max.adev.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the value with the larger absolute deviation
; prefer argument with a lower index
; double maxl.adev ( double x, double y, double a )
; deviation[i] = abs(a - x[i])
;
; x = rsp
; y = rsp + 8
; a = rsp + 16

macro @@maxl.adev.sse
{
$usprocf @@maxl.adev

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = a
    .enter:
        movsd   xmm3, xmm2                      ; xmm3 = a
        subsd   xmm2, xmm0
        @@.abs  xmm2
        subsd   xmm3, xmm1
        @@.abs  xmm3
        comisd  xmm2, xmm3
        jae    .return
        movsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@maxl.adev.fpu
{
$usprocf @@maxl.adev

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = a, st1 = y, st2 = x
    .enter:
        fld     st0                             ; st0 = a, st1 = a, st2 = y, st3 = x
        fsub    st0, st2                        ; st0 = (a - y), st1 = a, st2 = y, st3 = x
        fabs                                    ; st0 = abs(a - y), st1 = a, st2 = y, st3 = x
        fxch                                    ; st0 = a, st1 = abs(a - y), st2 = y, st3 = x
        fsub    st0, st3                        ; st0 = a - x, st1 = abs(a - y), st2 = y, st3 = x
        fabs                                    ; st0 = abs(a - x), st1 = abs(a - y), st2 = y, st3 = x
        fcompp                                  ; compare abs(a - x) to abs(a - y) ; st0 = y, st1 = x
        fnjge  .x                               ; jump if abs(a - x) >= abs(a - y)

    .y: fstp    st1                             ; return y, abs(a - y) > abs(a - x)
        jmp    .return
    .x: fstp    st0                             ; return x, abs(a - x) >= abs(a - y)

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@maxl.adev.sse
$else
  @@maxl.adev.fpu
$end

; ------------------------------------------------------------------------------
;
; returns the value with the larger absolute deviation
; prefer argument with a higher index
; double maxh.adev ( double x, double y, double a )
; deviation[i] = abs(a - x[i])
;
; x = rsp
; y = rsp + 8
; a = rsp + 16

macro @@maxh.adev.sse
{
$usprocf @@maxh.adev

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = a
    .enter:
        movsd   xmm3, xmm2                      ; xmm3 = a
        subsd   xmm2, xmm0
        @@.abs  xmm2
        subsd   xmm3, xmm1
        @@.abs  xmm3
        comisd  xmm2, xmm3
        ja     .return
        movsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@maxh.adev.fpu
{
$usprocf @@maxh.adev

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = a, st1 = y, st2 = x
    .enter:
        fld     st0                             ; st0 = a, st1 = a, st2 = y, st3 = x
        fsub    st0, st2                        ; st0 = (a - y), st1 = a, st2 = y, st3 = x
        fabs                                    ; st0 = abs(a - y), st1 = a, st2 = y, st3 = x
        fxch                                    ; st0 = a, st1 = abs(a - y), st2 = y, st3 = x
        fsub    st0, st3                        ; st0 = a - x, st1 = abs(a - y), st2 = y, st3 = x
        fabs                                    ; st0 = abs(a - x), st1 = abs(a - y), st2 = y, st3 = x
        fcompp                                  ; compare abs(a - x) to abs(a - y) ; st0 = y, st1 = x
        fnjle  .y                               ; jump if abs(a - x) <= abs(a - y)

    .x: fstp    st0                             ; return x, abs(a - x) > abs(a - y)
        jmp    .return
    .y: fstp    st1                             ; return y, abs(a - y) >= abs(a - x)

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@maxh.adev.sse
$else
  @@maxh.adev.fpu
$end

; ------------------------------------------------------------------------------

; returns equal or zero
; double eoz ( double x, double y )
; x = rsp
; y = rsp + 8
;
; returns: x , x = y
;          0 , otherwise

macro @@.eoz.sse
{
$usprocf @@eoz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ucomisd xmm0, xmm1                      ; compare x to y
        jnz    .x.neq.y
        jnp    .return
    .x.neq.y:                                   ; x <> y
        xorpd   xmm0, xmm0

    .return:
        retn
$endp
}

macro @@.eoz.fpu
{
$usprocf @@eoz

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcomp                                   ; compare y to x, pop y
                                                ; st0 = x
        fnje   .return                          ; jump if y = x
    .0: fstp    st0
        fldz

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; returns not equal or zero
; double neoz ( double x, double y )
; x = rsp
; y = rsp + 8
;
; returns: x , x != y
;          0 , otherwise

macro @@.neoz.sse
{
$usprocf @@neoz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ucomisd xmm0, xmm1                      ; compare x to y
        jnz    .x.neq.y
        jp     .x.neq.y
    .x.eq.y:                                    ; x = y
        xorpd   xmm0, xmm0
        jmp    .return
    .x.neq.y:                                   ; x <> y

    .return:
        retn
$endp
}

macro @@.neoz.fpu
{
$usprocf @@neoz

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcomp                                   ; compare y to x, pop y
                                                ; st0 = x
        fnjne  .return                          ; jump if y != x
    .0: fstp    st0
        fldz

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; returns equal or value
; double eov ( double x, double y, double v )
; x = rsp
; y = rsp + 8
; v = rsp + 16
;
; returns: x , x = y
;          v , otherwise

macro @@.eov.sse
{
$usprocf @@eov

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = v
    .enter:
        ucomisd xmm0, xmm1                      ; compare x to y
        jnz    .x.neq.y
        jnp    .return
    .x.neq.y:                                   ; x <> y
        movsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@.eov.fpu
{
$usprocf @@eov

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = v, st1 = y, st2 = x
    .enter:
        fxch    st2                             ; st0 = x, st1 = y, st2 = v
        fcomp                                   ; compare x to y, pop x
                                                ; st0 = y, st1 = v
        fnje   .return                          ; jump if x = y
    .0: fxch                                    ; st0 = v, st1 = y

    .return:
        fstp    st1
        retn
$endp
}

; ------------------------------------------------------------------------------

; returns not equal or value
; double neov ( double x, double y, double v )
; x = rsp
; y = rsp + 8
; v = rsp + 16
;
; returns: x , x != y
;          v , otherwise

macro @@.neov.sse
{
$usprocf @@neov

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = v
    .enter:
        ucomisd xmm0, xmm1                      ; compare x to y
        jnz    .x.neq.y
        jp     .x.neq.y
    .x.eq.y:                                    ; x = y
        movsd   xmm0, xmm2
        jmp    .return
    .x.neq.y:                                   ; x <> y

    .return:
        retn
$endp
}

macro @@.neov.fpu
{
$usprocf @@neov

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = v, st1 = y, st2 = x
    .enter:
        fxch    st2                             ; st0 = x, st1 = y, st2 = v
        fxch                                    ; st0 = y, st1 = x, st2 = v
        fcomp                                   ; compare y to x, pop y
                                                ; st0 = x, st1 = v
        fnjne  .return                          ; jump if y != x
    .0: fxch                                    ; st0 = v, st1 = x

    .return:
        fstp    st1
        retn
$endp
}

; ------------------------------------------------------------------------------

; returns a value with the magnitude of x and the sign of y
; the zero sign is considered positive
; double xsigny ( double x, double y )
;
; x = rsp
; y = rsp + 8

macro @@xsigny.sse
{
$usprocf @@xsigny

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmovsd  xmm5, ??.0x7FFFFFFFFFFFFFFF
        pand    xmm0, xmm5
        xmovsd  xmm5, ??.0x8000000000000000
        pand    xmm1, xmm5
        por     xmm0, xmm1
    .return:
        retn
$endp
}

macro @@xsigny.fpu
{
$usprocf @@xsigny

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare y to 0
        fnjgep .y.pos                           ; st0 = x
        fabs
        fchs
        jmp    .return
    .y.pos:
        fabs
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@xsigny.sse
$else
  @@xsigny.fpu
$end

; ------------------------------------------------------------------------------

; returns a value with the magnitude of y and the sign of x
; the zero sign is considered positive
; double ysignx ( double x, double y )
;
; x = rsp
; y = rsp + 8

macro @@ysignx.sse
{
$usprocf @@ysignx

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmovsd  xmm5, ??.0x8000000000000000
        pand    xmm0, xmm5
        xmovsd  xmm5, ??.0x7FFFFFFFFFFFFFFF
        pand    xmm1, xmm5
        por     xmm0, xmm1
    .return:
        retn
$endp
}

macro @@ysignx.fpu
{
$usprocf @@ysignx

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxch                                    ; st0 = x, st1 = y
        ftst                                    ; compare x to 0
        fnjgep .x.pos                           ; st0 = y
        fabs
        fchs
        jmp    .return
    .x.pos:
        fabs
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ysignx.sse
$else
  @@ysignx.fpu
$end

; ------------------------------------------------------------------------------

; returns a value with the magnitude of x and the sign of sign(x)*sign(y)
; the zero sign is considered positive
; double xcosign ( double x, double y )
;
; x = rsp
; y = rsp + 8

macro @@xcosign.sse
{
$usprocf @@xcosign

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm2, xmm0
        xmovsd  xmm5, ??.0x8000000000000000
        pand    xmm1, xmm5
        pand    xmm2, xmm5
        pxor    xmm1, xmm2
        xmovsd  xmm5, ??.0x7FFFFFFFFFFFFFFF
        pand    xmm0, xmm5
        por     xmm0, xmm1
    .return:
        retn
$endp
}

macro @@xcosign.fpu
{
$usprocf @@xcosign

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare y to 0
        fnjgep .y.pos                           ; st0 = x
    .y.neg:
        ftst                                    ; compare x to 0
        fnjge  .neg
        jmp    .pos
    .y.pos:
        ftst                                    ; compare x to 0
        fnjge  .pos
        jmp    .neg
    .neg:
        fabs
        fchs
        jmp    .return
    .pos:
        fabs
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@xcosign.sse
$else
  @@xcosign.fpu
$end

; ------------------------------------------------------------------------------

; returns a value with the magnitude of y and the sign of sign(x)*sign(y)
; the zero sign is considered positive
; double ycosign ( double x, double y )
;
; x = rsp
; y = rsp + 8

macro @@ycosign.sse
{
$usprocf @@ycosign

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm2, xmm1
        xmovsd  xmm5, ??.0x8000000000000000
        pand    xmm0, xmm5
        pand    xmm2, xmm5
        pxor    xmm0, xmm2
        xmovsd  xmm5, ??.0x7FFFFFFFFFFFFFFF
        pand    xmm1, xmm5
        por     xmm0, xmm1
    .return:
        retn
$endp
}

macro @@ycosign.fpu
{
$usprocf @@ycosign

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fxch                                    ; st0 = x, st1 = y
        ftst                                    ; compare x to 0
        fnjgep .x.pos                           ; st0 = y
    .x.neg:
        ftst                                    ; compare y to 0
        fnjge  .neg
        jmp    .pos
    .x.pos:
        ftst                                    ; compare y to 0
        fnjge  .pos
        jmp    .neg
    .neg:
        fabs
        fchs
        jmp    .return
    .pos:
        fabs
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ycosign.sse
$else
  @@ycosign.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double add.mul ( double z, double x, double y )
; f(z,x,y) = z + x*y
; add & mul
;
; z = rsp
; x = rsp + 8
; y = rsp + 16

macro @@add.mul.sse
{
$usprocf @@add.mul

        movsd   xmm0, qword [rsp]               ; xmm0 = z
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y
    .enter:
        mulsd   xmm1, xmm2
        addsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@add.mul.fpu
{
$usprocf @@add.mul

        fld     qword [rsp]                     ; st0 = z
        fld     qword [rsp + 8]                 ; st0 = x, st1 = z
        fld     qword [rsp + 16]                ; st0 = y, st1 = x, st2 = z
    .enter:
        fmulp                                   ; st0 = x*y, st1 = z
        faddp                                   ; st0 = z + x*y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@add.mul.sse
$else
  @@add.mul.fpu
$end

; ------------------------------------------------------------------------------

; double add.div ( double z, double x, double y )
; f(z,x,y) = z + x/y
; add & div
;
; z = rsp
; x = rsp + 8
; y = rsp + 16

macro @@add.div.sse
{
$usprocf @@add.div

        movsd   xmm0, qword [rsp]               ; xmm0 = z
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y
    .enter:
        divsd   xmm1, xmm2
        addsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@add.div.fpu
{
$usprocf @@add.div

        fld     qword [rsp]                     ; st0 = z
        fld     qword [rsp + 8]                 ; st0 = x, st1 = z
        fld     qword [rsp + 16]                ; st0 = y, st1 = x, st2 = z
    .enter:
        fdivp                                   ; st0 = x/y, st1 = z
        faddp                                   ; st0 = z + x/y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@add.div.sse
$else
  @@add.div.fpu
$end

; ------------------------------------------------------------------------------

; double add.divr ( double z, double x, double y )
; f(z,x,y) = z + y/x
; add & divr
;
; z = rsp
; x = rsp + 8
; y = rsp + 16

macro @@add.divr.sse
{
$usprocf @@add.divr

        movsd   xmm0, qword [rsp]               ; xmm0 = z
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y
    .enter:
        divsd   xmm2, xmm1
        addsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@add.divr.fpu
{
$usprocf @@add.divr

        fld     qword [rsp]                     ; st0 = z
        fld     qword [rsp + 8]                 ; st0 = x, st1 = z
        fld     qword [rsp + 16]                ; st0 = y, st1 = x, st2 = z
    .enter:
        fdivrp                                  ; st0 = y/x, st1 = z
        faddp                                   ; st0 = z + y/x

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@add.divr.sse
$else
  @@add.divr.fpu
$end

; ------------------------------------------------------------------------------

; double sub.mul ( double z, double x, double y )
; f(z,x,y) = z - x*y
; sub & mul
;
; z = rsp
; x = rsp + 8
; y = rsp + 16

macro @@sub.mul.sse
{
$usprocf @@sub.mul

        movsd   xmm0, qword [rsp]               ; xmm0 = z
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y
    .enter:
        mulsd   xmm1, xmm2
        subsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@sub.mul.fpu
{
$usprocf @@sub.mul

        fld     qword [rsp]                     ; st0 = z
        fld     qword [rsp + 8]                 ; st0 = x, st1 = z
        fld     qword [rsp + 16]                ; st0 = y, st1 = x, st2 = z
    .enter:
        fmulp                                   ; st0 = x*y, st1 = z
        fsubp                                   ; st0 = z - x*y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sub.mul.sse
$else
  @@sub.mul.fpu
$end

; ------------------------------------------------------------------------------

; double sub.div ( double z, double x, double y )
; f(z,x,y) = z - x/y
; sub & div
;
; z = rsp
; x = rsp + 8
; y = rsp + 16

macro @@sub.div.sse
{
$usprocf @@sub.div

        movsd   xmm0, qword [rsp]               ; xmm0 = z
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y
    .enter:
        divsd   xmm1, xmm2
        subsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@sub.div.fpu
{
$usprocf @@sub.div

        fld     qword [rsp]                     ; st0 = z
        fld     qword [rsp + 8]                 ; st0 = x, st1 = z
        fld     qword [rsp + 16]                ; st0 = y, st1 = x, st2 = z
    .enter:
        fdivp                                   ; st0 = x/y, st1 = z
        fsubp                                   ; st0 = z - x/y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sub.div.sse
$else
  @@sub.div.fpu
$end

; ------------------------------------------------------------------------------

; double sub.divr ( double z, double x, double y )
; f(z,x,y) = z - y/x
; sub & divr
;
; z = rsp
; x = rsp + 8
; y = rsp + 16

macro @@sub.divr.sse
{
$usprocf @@sub.divr

        movsd   xmm0, qword [rsp]               ; xmm0 = z
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y
    .enter:
        divsd   xmm2, xmm1
        subsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@sub.divr.fpu
{
$usprocf @@sub.divr

        fld     qword [rsp]                     ; st0 = z
        fld     qword [rsp + 8]                 ; st0 = x, st1 = z
        fld     qword [rsp + 16]                ; st0 = y, st1 = x, st2 = z
    .enter:
        fdivrp                                  ; st0 = y/x, st1 = z
        fsubp                                   ; st0 = z - y/x

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sub.divr.sse
$else
  @@sub.divr.fpu
$end

; ------------------------------------------------------------------------------

; double subr.mul ( double z, double x, double y )
; f(z,x,y) = x*y - z
; subr & mul
;
; z = rsp
; x = rsp + 8
; y = rsp + 16

macro @@subr.mul.sse
{
$usprocf @@subr.mul

        movsd   xmm0, qword [rsp]               ; xmm0 = z
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y
    .enter:
        mulsd   xmm1, xmm2
        subsd   xmm1, xmm0
        movsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@subr.mul.fpu
{
$usprocf @@subr.mul

        fld     qword [rsp]                     ; st0 = z
        fld     qword [rsp + 8]                 ; st0 = x, st1 = z
        fld     qword [rsp + 16]                ; st0 = y, st1 = x, st2 = z
    .enter:
        fmulp                                   ; st0 = x*y, st1 = z
        fsubrp                                  ; st0 = x*y - z

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@subr.mul.sse
$else
  @@subr.mul.fpu
$end

; ------------------------------------------------------------------------------

; double subr.div ( double z, double x, double y )
; f(z,x,y) = x/y - z
; subr & div
;
; z = rsp
; x = rsp + 8
; y = rsp + 16

macro @@subr.div.sse
{
$usprocf @@subr.div

        movsd   xmm0, qword [rsp]               ; xmm0 = z
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y
    .enter:
        divsd   xmm1, xmm2
        subsd   xmm1, xmm0
        movsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@subr.div.fpu
{
$usprocf @@subr.div

        fld     qword [rsp]                     ; st0 = z
        fld     qword [rsp + 8]                 ; st0 = x, st1 = z
        fld     qword [rsp + 16]                ; st0 = y, st1 = x, st2 = z
    .enter:
        fdivp                                   ; st0 = x/y, st1 = z
        fsubrp                                  ; st0 = x/y - z

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@subr.div.sse
$else
  @@subr.div.fpu
$end

; ------------------------------------------------------------------------------

; double subr.divr ( double z, double x, double y )
; f(z,x,y) = y/x - z
; subr & divr
;
; z = rsp
; x = rsp + 8
; y = rsp + 16

macro @@subr.divr.sse
{
$usprocf @@subr.divr

        movsd   xmm0, qword [rsp]               ; xmm0 = z
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y
    .enter:
        divsd   xmm2, xmm1
        subsd   xmm2, xmm0
        movsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@subr.divr.fpu
{
$usprocf @@subr.divr

        fld     qword [rsp]                     ; st0 = z
        fld     qword [rsp + 8]                 ; st0 = x, st1 = z
        fld     qword [rsp + 16]                ; st0 = y, st1 = x, st2 = z
    .enter:
        fdivrp                                  ; st0 = y/x, st1 = z
        fsubrp                                  ; st0 = y/x - z

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@subr.divr.sse
$else
  @@subr.divr.fpu
$end

; ------------------------------------------------------------------------------

; double mul.add ( double x, double y, double z )
; f(x,y,z) = x*y + z
; mul & add
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

macro @@mul.add.sse
{
$usprocf @@mul.add

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
    .enter:
        mulsd   xmm0, xmm1
        addsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@mul.add.fpu
{
$usprocf @@mul.add

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fmulp                                   ; st0 = x*y
        fld     qword [rsp + 16]                ; st0 = z, st1 = x*y
        faddp                                   ; st0 = x*y + z

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mul.add.sse
$else
  @@mul.add.fpu
$end

; ------------------------------------------------------------------------------

; double mul.sub ( double x, double y, double z )
; f(x,y,z) = x*y - z
; mul & sub
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

macro @@mul.sub.sse
{
$usprocf @@mul.sub

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
    .enter:
        mulsd   xmm0, xmm1
        subsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@mul.sub.fpu
{
$usprocf @@mul.sub

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fmulp                                   ; st0 = x*y
        fld     qword [rsp + 16]                ; st0 = z, st1 = x*y
        fsubp                                   ; st0 = x*y - z

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mul.sub.sse
$else
  @@mul.sub.fpu
$end

; ------------------------------------------------------------------------------

; double mul.subr ( double x, double y, double z )
; f(x,y,z) = z - x*y
; mul & subr
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

macro @@mul.subr.sse
{
$usprocf @@mul.subr

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
    .enter:
        mulsd   xmm0, xmm1
        subsd   xmm2, xmm0
        movsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@mul.subr.fpu
{
$usprocf @@mul.subr

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fmulp                                   ; st0 = x*y
        fld     qword [rsp + 16]                ; st0 = z, st1 = x*y
        fsubrp                                  ; st0 = z - x*y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mul.subr.sse
$else
  @@mul.subr.fpu
$end

; ------------------------------------------------------------------------------

; double div.add ( double x, double y, double z )
; f(x,y,z) = x/y + z
; div & add
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

macro @@div.add.sse
{
$usprocf @@div.add

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
    .enter:
        divsd   xmm0, xmm1
        addsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@div.add.fpu
{
$usprocf @@div.add

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fdivp                                   ; st0 = x/y
        fld     qword [rsp + 16]                ; st0 = z, st1 = x/y
        faddp                                   ; st0 = x/y + z

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@div.add.sse
$else
  @@div.add.fpu
$end

; ------------------------------------------------------------------------------

; double div.sub ( double x, double y, double z )
; f(x,y,z) = x/y - z
; div & sub
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

macro @@div.sub.sse
{
$usprocf @@div.sub

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
    .enter:
        divsd   xmm0, xmm1
        subsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@div.sub.fpu
{
$usprocf @@div.sub

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fdivp                                   ; st0 = x/y
        fld     qword [rsp + 16]                ; st0 = z, st1 = x/y
        fsubp                                   ; st0 = x/y - z

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@div.sub.sse
$else
  @@div.sub.fpu
$end

; ------------------------------------------------------------------------------

; double div.subr ( double x, double y, double z )
; f(x,y,z) = z - x/y
; div & subr
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

macro @@div.subr.sse
{
$usprocf @@div.subr

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
    .enter:
        divsd   xmm0, xmm1
        subsd   xmm2, xmm0
        movsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@div.subr.fpu
{
$usprocf @@div.subr

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fdivp                                   ; st0 = x/y
        fld     qword [rsp + 16]                ; st0 = z, st1 = x/y
        fsubrp                                  ; st0 = z - x/y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@div.subr.sse
$else
  @@div.subr.fpu
$end

; ------------------------------------------------------------------------------

; double divr.add ( double x, double y, double z )
; f(x,y,z) = y/x + z
; divr & add
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

macro @@divr.add.sse
{
$usprocf @@divr.add

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
    .enter:
        divsd   xmm1, xmm0
        addsd   xmm1, xmm2
        movsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@divr.add.fpu
{
$usprocf @@divr.add

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fdivrp                                  ; st0 = y/x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y/x
        faddp                                   ; st0 = y/x + z

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@divr.add.sse
$else
  @@divr.add.fpu
$end

; ------------------------------------------------------------------------------

; double divr.sub ( double x, double y, double z )
; f(x,y,z) = y/x - z
; divr & sub
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

macro @@divr.sub.sse
{
$usprocf @@divr.sub

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
    .enter:
        divsd   xmm1, xmm0
        subsd   xmm1, xmm2
        movsd   xmm0, xmm1

    .return:
        retn
$endp
}

macro @@divr.sub.fpu
{
$usprocf @@divr.sub

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fdivrp                                  ; st0 = y/x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y/x
        fsubp                                   ; st0 = y/x - z

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@divr.sub.sse
$else
  @@divr.sub.fpu
$end

; ------------------------------------------------------------------------------

; double divr.subr ( double x, double y, double z )
; f(x,y,z) = z - y/x
; divr & subr
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

macro @@divr.subr.sse
{
$usprocf @@divr.subr

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
    .enter:
        divsd   xmm1, xmm0
        subsd   xmm2, xmm1
        movsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@divr.subr.fpu
{
$usprocf @@divr.subr

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fdivrp                                  ; st0 = y/x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y/x
        fsubrp                                  ; st0 = z - y/x

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@divr.subr.sse
$else
  @@divr.subr.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; clamp x in range between min and max
; double clamp ( double x, double min, double max )
; x   = rsp
; min = rsp + 8
; max = rsp + 16
;
; returns: max , x > max
;          min , x < min
;          x   , otherwise

macro @@clamp.sse
{
$usprocf @@clamp

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = ?min
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = ?max
    .enter:
        comisd  xmm1, xmm2
        jbe    .x
        pxor    xmm1, xmm2                      ; exchange xmm1 and xmm2
        pxor    xmm2, xmm1
        pxor    xmm1, xmm2
    .x:                                         ; xmm1 = min
                                                ; xmm2 = max
        comisd  xmm0, xmm2                      ; compare x to max
        jae    .x.gt.max
        comisd  xmm0, xmm1                      ; compare x to min
        jae    .return
    .x.lt.min:
        movsd   xmm0, xmm1                      ; xmm0 = min
        jmp    .return
    .x.gt.max:
        movsd   xmm0, xmm2                      ; xmm0 = max
        jmp    .return

    .return:
        retn
$endp
}

macro @@clamp.fpu
{
$usprocf @@clamp

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = ?min, st1 = x
        fld     qword [rsp + 16]                ; st0 = ?max, st1 = ?min, st2 = x
    .enter:
        fcom                                    ; compare ?max to ?min
        fnjge  .x                               ; jump if ?max >= ?min
        fxch
    .x:                                         ; st0 = max, st1 = min, st2 = x
        fcom    st2                             ; compare max to x
        fnjge  .x.le.max                        ; jump if max >= x (x <= max)
    .x.gt.max:                                  ; • x > max
        fstp    st1                             ; st0 = max, st1 = x
        fstp    st1                             ; st0 = max
        jmp    .return                          ; return max
    .x.le.max:                                  ; • x <= max
        fstp    st0                             ; st0 = min, st1 = x
        fcom                                    ; compare min to x
        fnjle  .x.ge.min                        ; jump if min <= x (x >= min)
    .x.lt.min:                                  ; • x < min
        fstp    st1                             ; st0 = min
        jmp    .return                          ; return min
    .x.ge.min:                                  ; • x >= min
        fstp    st0                             ; st1 = x

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@clamp.sse
$else
  @@clamp.fpu
$end

; ------------------------------------------------------------------------------

; clamp x in range between 0 and 1
; double saturate ( double x )
; x = rsp
;
; returns: 1 , x > 1
;          0 , x < 0
;          x , otherwise

macro @@saturate.sse
{
$usprocf @@saturate

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm1, xmm1                      ; xmm1 = min = 0
        xmovsd  xmm2, ??.1.0                    ; xmm2 = max = 1
    .x:
        comisd  xmm0, xmm2                      ; compare x to max
        jae    .x.gt.max
        comisd  xmm0, xmm1                      ; compare x to min
        jae    .return
    .x.lt.min:
        movsd   xmm0, xmm1                      ; xmm0 = min
        jmp    .return
    .x.gt.max:
        movsd   xmm0, xmm2                      ; xmm0 = max
        jmp    .return

    .return:
        retn
$endp
}

macro @@saturate.fpu
{
$usprocf @@saturate

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1                                    ; st0 = 1, st1 = x
        fcom                                    ; compare 1 to x
        fnjge  .x.le.1                          ; jump if 1 >= x (x <= 1)
    .x.gt.1:                                    ; • x > 1
        fstp    st1                             ; st0 = 1
        jmp    .return                          ; return 1
    .x.le.1:                                    ; • x <= 1
        fstp    st0                             ; st0 = x
        fldz                                    ; st0 = 0, st1 = x
        fcom                                    ; compare 0 to x
        fnjle  .x.ge.0                          ; jump if 0 <= x (x >= 0)
    .x.lt.0:                                    ; • x < 0
        fstp    st1                             ; st0 = 0
        jmp    .return                          ; return 0
    .x.ge.0:                                    ; • x >= 0
        fstp    st0                             ; st1 = x

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@saturate.sse
$else
  @@saturate.fpu
$end

; ------------------------------------------------------------------------------

; delta function
; double delta ( double x, double a )
; x = rsp
; a = rsp + 8
;
; returns: 1, x = a
;          0, x <> a

macro @@delta.sse
{
$usprocf @@delta

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ucomisd xmm0, xmm1                      ; compare x to a
        jnz    .0
        jp     .0
    .1:                                         ; x = y
        xmovsd  xmm0, ??.1.0                    ; return 1
        jmp    .return
    .0:                                         ; x <> a
        xorpd   xmm0, xmm0                      ; return 0

    .return:
        retn
$endp
}

macro @@delta.fpu
{
$usprocf @@delta

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = a, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare a to x
        fnje   .1                               ; jump if x = a (a = x)

    .0: fldz                                    ; return 0, x <> a
        jmp    .return
    .1: fld1                                    ; return 1, x = a

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@delta.sse
$else
  @@delta.fpu
$end

; ------------------------------------------------------------------------------

; deltab function
; double deltab ( double x, double a, double b )
; x = rsp
; a = rsp + 8
; b = rsp + 16
;
; returns: 1, (x >= a) and (x <= b)
;          0, otherwise

macro @@deltab.sse
{
$usprocf @@deltab

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = a
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = b
    .enter:
        comisd  xmm0, xmm2
        ja     .0
        comisd  xmm0, xmm1
        jb     .0
    .1: xmovsd  xmm0, ??.1.0                    ; return 1
        jmp    .return
    .0: xorpd   xmm0, xmm0                      ; return 0

    .return:
        retn
$endp
}

macro @@deltab.fpu
{
$usprocf @@deltab

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = a, st1 = x
        fld     qword [rsp + 16]                ; st0 = b, st1 = a, st2 = x
    .enter:
        fcomp   st2                             ; compare b to x
        fnjge  .x.le.b                          ; jump if x <= b (b >= x)
        fstp    st0
        fstp    st0
        jmp    .0
    .x.le.b:                                    ; st0 = a, st1 = x
        fcompp                                  ; compare a to x
        fnjle  .x.ge.a                          ; jump if x >= a (a <= x)
        jmp    .0
    .x.ge.a:
        fld1                                    ; return 1
        jmp    .return
    .0: fldz                                    ; return 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deltab.sse
$else
  @@deltab.fpu
$end

; ------------------------------------------------------------------------------

; teta function
; double teta ( double x, double a )
; x = rsp
; a = rsp + 8
;
; returns: 1, x > a
;          0, x <= a

macro @@teta.sse
{
$usprocf @@teta

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1
        ja     .1
    .0: xorpd   xmm0, xmm0                      ; return 0, x <= a
        jmp    .return
    .1: xmovsd  xmm0, ??.1.0                    ; return 1, x > a

    .return:
        retn
$endp
}

macro @@teta.fpu
{
$usprocf @@teta

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = a, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare a to x
        fnjl   .1                               ; jump if x > a (a < x)

    .0: fldz                                    ; return 0, x <= a
        jmp    .return
    .1: fld1                                    ; return 1, x > a

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@teta.sse
$else
  @@teta.fpu
$end

; ------------------------------------------------------------------------------

; tetae function
; double tetae ( double x, double a )
; x = rsp
; a = rsp + 8
;
; returns: 1, x >= a
;          0, x < a

macro @@tetae.sse
{
$usprocf @@tetae

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1
        jae    .1
    .0: xorpd   xmm0, xmm0                      ; return 0, x <= a
        jmp    .return
    .1: xmovsd  xmm0, ??.1.0                    ; return 1, x > a

    .return:
        retn
$endp
}

macro @@tetae.fpu
{
$usprocf @@tetae

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = a, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare a to x
        fnjle  .1                               ; jump if x >= a (a <= x)

    .0: fldz                                    ; return 0, x < a
        jmp    .return
    .1: fld1                                    ; return 1, x >= a

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@tetae.sse
$else
  @@tetae.fpu
$end

; ------------------------------------------------------------------------------

; cycle function
;
; double cycle ( x, a, P )
; x = rsp
; a = rsp + 8
; P = rsp + 16
;
; period = P
; returns: P + (x - a) mod P, x - a < 0
;              (x - a) mod P, x - a >= 0
;                          0, P <= 0

macro @@cycle.sse
{
$usprocf @@cycle

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = a
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = P
    .enter:
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        comisd  xmm2, xmm3                      ; compare P to 0
        ja     .p
    .n:                                         ; P <= 0
        xorpd   xmm0, xmm0
        jmp    .return
    .p:                                         ; P > 0
        subsd   xmm0, xmm1                      ; xmm0 = x - a
        movsd   xmm1, xmm0                      ; xmm1 = x - a
        divsd   xmm1, xmm2                      ; xmm1 = (x - a) / P
        xintsd  xmm1, xmm1                      ; xmm1 = int((x - a) / P)
        mulsd   xmm1, xmm2                      ; xmm1 = P * int((x - a) / P)
        subsd   xmm0, xmm1                      ; xmm0 = (x - a) mod P
        comisd  xmm0, xmm3                      ; compare xmm0 to 0
        jae    .return
        addsd   xmm0, xmm2

    .return:
        retn
$endp
}

macro @@cycle.fpu
{
$usprocf @@cycle

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = a, st1 = x
        fsubp                                   ; st0 = x - a

        fld     qword [rsp + 16]                ; st0 = P, st1 = x - a
        ftst
        fnjg   .p

    .n: fstp    st1                             ; P <= 0
        fldz                                    ; return 0
        jmp    .return                          ; st0 = 0, st1 = x - a

    .p: fxch                                    ; P > 0
        fld     st0                             ; st0 = x - a, st1 = x - a, st2 = P
        fdiv    st0, st2                        ; st0 = (x - a) / P, st1 = x - a, st2 = P
        @@.int.st0                              ; st0 = int((x - a) / P), st1 = x - a, st2 = P
        fmul    st0, st2                        ; st0 = P * int((x - a) / P), st1 = x - a, st2 = P
        fsubp                                   ; st0 = (x - a) mod P, st1 = P

        ftst
        fnjge  .return
        fadd    st0, st1                        ; st0 = P + (x - a) mod P, st1 = P

    .return:
        fstp    st1
        retn
$endp
}

$ifdef _SSEX
  @@cycle.sse
$else
  @@cycle.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; greatest common divisor
; highest common factor
; Euclid`s algorithm
;
; integer igcd ( integer x, integer y )
; integer ihcf ( integer x, integer y )
;
; x = rsp
; y = rsp + 8
; x & y in [0..2^63-1] range

$usprocf @@igcd

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        mov     rdx, rcx
        test    rdx, rdx
        jz     .return

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .return:                                     ; rax = gcd(x,y)
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; greatest common divisor
; highest common factor
; Euclid`s algorithm
;
; double gcd ( double x, double y )
; double hcf ( double x, double y )
;
; x = rsp
; y = rsp + 8
; x & y in [0..2^63-1] range

macro @@gcd.sse
{
$usprocf @@gcd

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
      cvttsd2si rax, xmm0                       ; rax = int(x):int64
      cvttsd2si rdx, xmm1                       ; rdx = int(y):int64

        test    rdx, rdx
        jz     .result

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .result:                                     ; rax = gcd(x,y)
       cvtsi2sd xmm0, rax

   .return:
        retn
$endp
}

macro @@gcd.fpu
{
$usprocf @@gcd

       .int_x   EQU rsp - 24
       .int_y   EQU rsp - 16

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        frndint                                 ; st0 = int(y)
        fistp   qword [.int_y]                  ; [.int_y] = int(y):int64
        frndint                                 ; st0 = int(x)
        fistp   qword [.int_x]                  ; [.int_x] = int(x):int64

        @@.fpu.cw.restore                       ; restore control word

        mov     rax, qword [.int_x]             ; rax = x
        mov     rdx, qword [.int_y]             ; rdx = y

        test    rdx, rdx
        jz     .load                            ; [.int_x] = rax

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .result:                                     ; rax = gcd(x,y)
        mov     qword [.int_x], rax
   .load:
        fild    qword [.int_x]                  ; st0 = gcd(x,y)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@gcd.sse
$else
  @@gcd.fpu
$end

; ------------------------------------------------------------------------------

; greatest common divisor
; highest common factor
; Euclid`s algorithm
;
; double gcd ( integer x, integer y )
; double hcf ( integer x, integer y )
;
; x = rsp
; y = rsp + 8
; x & y in [0..2^63-1] range

macro @@_gcd_int.sse
{
$usprocf @@_gcd_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rdx, qword [rsp + 8]            ; rdx = y

        test    rdx, rdx
        jz     .result

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .result:                                     ; rax = gcd(x,y)
       cvtsi2sd xmm0, rax

   .return:
        retn
$endp
}

macro @@_gcd_int.fpu
{
$usprocf @@_gcd_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rdx, qword [rsp + 8]            ; rdx = y

        test    rdx, rdx
        jz     .load                            ; [rsp] = rax

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .result:                                     ; rax = gcd(x,y)
        mov     qword [rsp], rax
   .load:
        fild    qword [rsp]                     ; st0 = gcd(x,y)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_gcd_int.sse
$else
  @@_gcd_int.fpu
$end

; ------------------------------------------------------------------------------

; greatest common divisor
; highest common factor
; Euclid`s algorithm
;
; double gcd ( integer x, integer y )
; double hcf ( integer x, integer y )
;
; x = rax
; y = rcx

macro @@_gcd_reg.sse
{
$usprocf @@_gcd_reg

        mov     rdx, rcx
        test    rdx, rdx
        jz     .result

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .result:                                     ; rax = gcd(x,y)
       cvtsi2sd xmm0, rax

   .return:
        retn
$endp
}

macro @@_gcd_reg.fpu
{
$usprocf @@_gcd_reg

        mov     rdx, rcx
        test    rdx, rdx
        jz     .result

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .result:                                     ; rax = gcd(x,y)
        mov     qword [rsp - 8], rax
        fild    qword [rsp - 8]                 ; st0 = gcd(x,y)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_gcd_reg.sse
$else
  @@_gcd_reg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; least common multiple
; integer ilcm ( integer x, integer y )
;
; x = rsp
; y = rsp + 8
; x & y in [1..2^63-1] range

$usprocf @@ilcm

       .y       EQU rsp - 16

        mov     rax, qword [rsp]                ; rax = x integer value
        mov     rcx, qword [rsp + 8]            ; rcx = y integer value
   .enter:
        mov     rdx, rcx                        ; rdx = y
        mov     rbx, rax                        ; rbx = x
        mov     qword [.y], rdx                 ; [.y] = y

        test    rdx, rdx
        jz     .final

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .final:
        test    rax, rax                        ; rax = gcd(x,y)
        jz     .result
        mov     rcx, rax                        ; rcx = gcd(x,y)
        mov     rax, rbx                        ; rax = x (rdx = 0)
        div     rcx                             ; rax = x div gcd(x,y)

   .result:
        mul     qword [.y]                      ; rax = [x div gcd(x,y)] * y = lcm(x,y)

   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; least common multiple
; double lcm ( double x, double y )
;
; x = rsp
; y = rsp + 8
; x & y in [1..2^63-1] range

macro @@lcm.sse
{
$usprocf @@lcm

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
      cvttsd2si rax, xmm0                       ; rax = int(x):int64
      cvttsd2si rdx, xmm1                       ; rdx = int(y):int64

        mov     rbx, rax                        ; rbx = x
       cvtsi2sd xmm2, rdx                       ; xmm2 = y

        test    rdx, rdx
        jz     .final

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .final:
        test    rax, rax                        ; rax = gcd(x,y)
        jz     .result
        mov     rcx, rax                        ; rcx = gcd(x,y)
        mov     rax, rbx                        ; rax = x (rdx = 0)
        div     rcx                             ; rax = x div gcd(x,y)

   .result:
       cvtsi2sd xmm0, rax
        mulsd   xmm0, xmm2                      ; xmm0 = [x div gcd(x,y)] * y = lcm(x,y)

   .return:
        retn
$endp
}

macro @@lcm.fpu
{
$usprocf @@lcm

       .int_x   EQU rsp - 24
       .int_y   EQU rsp - 16

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        frndint                                 ; st0 = int(y)
        fistp   qword [.int_y]                  ; [.int_y] = int(y):int64
        frndint                                 ; st0 = int(x)
        fistp   qword [.int_x]                  ; [.int_x] = int(x):int64

        @@.fpu.cw.restore                       ; restore control word

        mov     rax, qword [.int_x]             ; rax = x
        mov     rdx, qword [.int_y]             ; rdx = y
        mov     rbx, rax                        ; rbx = x

        test    rdx, rdx
        jz     .final

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .final:
        test    rax, rax                        ; rax = gcd(x,y)
        jz     .result
        mov     rcx, rax                        ; rcx = gcd(x,y)
        mov     rax, rbx                        ; rax = x (rdx = 0)
        div     rcx                             ; rax = x div gcd(x,y)

   .result:
        mov     qword [.int_x], rax
        fild    qword [.int_x]
;       fimul   qword [.int_y]                  ; st0 = [x div gcd(x,y)] * y = lcm(x,y)
        fild    qword [.int_y]
        fmulp                                   ; st0 = [x div gcd(x,y)] * y = lcm(x,y)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@lcm.sse
$else
  @@lcm.fpu
$end

; ------------------------------------------------------------------------------

; least common multiple
; double lcm ( integer x, integer y )
;
; x = rsp
; y = rsp + 8
; x & y in [1..2^63-1] range

macro @@_lcm_int.sse
{
$usprocf @@_lcm_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rdx, qword [rsp + 8]            ; rdx = y

        mov     rbx, rax                        ; rbx = x
       cvtsi2sd xmm2, rdx                       ; xmm2 = y

        test    rdx, rdx
        jz     .final

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .final:
        test    rax, rax                        ; rax = gcd(x,y)
        jz     .result
        mov     rcx, rax                        ; rcx = gcd(x,y)
        mov     rax, rbx                        ; rax = x (rdx = 0)
        div     rcx                             ; rax = x div gcd(x,y)

   .result:
       cvtsi2sd xmm0, rax
        mulsd   xmm0, xmm2                      ; xmm0 = [x div gcd(x,y)] * y = lcm(x,y)

    .return:
        retn
$endp
}

macro @@_lcm_int.fpu
{
$usprocf @@_lcm_int

        mov     rax, qword [rsp]                ; rax = x
        mov     rdx, qword [rsp + 8]            ; rdx = y

        mov     rbx, rax                        ; rbx = x

        test    rdx, rdx
        jz     .final

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .final:
        test    rax, rax                        ; rax = gcd(x,y)
        jz     .result
        mov     rcx, rax                        ; rcx = gcd(x,y)
        mov     rax, rbx                        ; rax = x (rdx = 0)
        div     rcx                             ; rax = x div gcd(x,y)

   .result:
        mov     qword [rsp], rax
        fild    qword [rsp]
;       fimul   qword [rsp + 8]                 ; st0 = [x div gcd(x,y)] * y = lcm(x,y)
        fild    qword [rsp + 8]
        fmulp                                   ; st0 = [x div gcd(x,y)] * y = lcm(x,y)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_lcm_int.sse
$else
  @@_lcm_int.fpu
$end

; ------------------------------------------------------------------------------

; least common multiple
; double lcm ( integer x, integer y )
;
; x = rax
; y = rcx

macro @@_lcm_reg.sse
{
$usprocf @@_lcm_reg

        mov     rbx, rax                        ; rbx = x
        mov     rdx, rcx                        ; rdx = y
       cvtsi2sd xmm2, rdx                       ; xmm2 = y

        test    rdx, rdx
        jz     .final

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .final:
        test    rax, rax                        ; rax = gcd(x,y)
        jz     .result
        mov     rcx, rax                        ; rcx = gcd(x,y)
        mov     rax, rbx                        ; rax = x (rdx = 0)
        div     rcx                             ; rax = x div gcd(x,y)

   .result:
       cvtsi2sd xmm0, rax
        mulsd   xmm0, xmm2                      ; xmm0 = [x div gcd(x,y)] * y = lcm(x,y)

   .return:
        retn
$endp
}

macro @@_lcm_reg.fpu
{
$usprocf @@_lcm_reg

       .rax     EQU rsp - 16
       .rdx     EQU rsp - 24

        mov     rbx, rax                        ; rbx = x
        mov     rdx, rcx                        ; rdx = y
        mov     [.rdx], rdx

        test    rdx, rdx
        jz     .final

   .loop.in:
        mov     rcx, rdx                        ; rcx = y
        xor     rdx, rdx                        ; rdx = 0
        div     rcx                             ; rax = x div y
        mov     rax, rcx                        ; rdx = x mod y
   .test.rdx:
        test    rdx, rdx
        jnz    .loop.in                         ; repeat while x mod y (rdx) <> 0

   .final:
        test    rax, rax                        ; rax = gcd(x,y)
        jz     .result
        mov     rcx, rax                        ; rcx = gcd(x,y)
        mov     rax, rbx                        ; rax = x (rdx = 0)
        div     rcx                             ; rax = x div gcd(x,y)

   .result:
        mov     qword [.rax], rax
        fild    qword [.rax]
;       fimul   qword [.rdx]                    ; st0 = [x div gcd(x,y)] * y = lcm(x,y)
        fild    qword [.rdx]
        fmulp                                   ; st0 = [x div gcd(x,y)] * y = lcm(x,y)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_lcm_reg.sse
$else
  @@_lcm_reg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; coefficients of linear function passing through the points (x_1,y_1) and (x_2,y_2)
; double double lineco ( double x_1, double y_1, double x_2, double y_2 )
; f(x) = a*x + b
;
; x_1 = rsp + 00
; y_1 = rsp + 08
; x_2 = rsp + 16
; y_2 = rsp + 24
;
; return_1 = st1 = a
; return_2 = st0 = b

macro @@lineco.sse
{
$usprocf @@lineco

        movsd   xmm0, qword [rsp]               ; xmm0 = x_1
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y_1
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = x_2
        movsd   xmm3, qword [rsp + 24]          ; xmm3 = y_2
    .enter:
        subsd   xmm3, xmm1                      ; xmm3 = (y_2-y_1) = Dy
        subsd   xmm2, xmm0                      ; xmm2 = (x_2-x_1) = Dx
        divsd   xmm3, xmm2                      ; xmm3 = Dy/Dx = a
        mulsd   xmm0, xmm3                      ; xmm0 = x_1*a
        subsd   xmm1, xmm0                      ; xmm1 = b
        movsd   xmm0, xmm3                      ; xmm0 = a
    .return:
        retn
$endp
}

macro @@lineco.fpu
{
$usprocf @@lineco

        fld     qword [rsp + 24]
        fld     qword [rsp + 08]                ; st0 = y_1       | st1 = y_2
        fsub    st1, st0                        ; st0 = y_1       | st1 = (y_2-y_1)
        fld     qword [rsp + 16]
        fld     qword [rsp + 00]                ; st0 = x_1       | st1 = x_2       | st2 = y_1       | st3 = (y_2-y_1)
        fsub    st1, st0                        ; st0 = x_1       | st1 = (x_2-x_1) | st2 = y_1       | st3 = (y_2-y_1)
        fxch    st1                             ; st0 = (x_2-x_1) | st1 = x_1       | st2 = y_1       | st3 = (y_2-y_1)
        fdivp   st3, st0                        ; st0 = x_1       | st1 = y_1       | st2 = Dy/Dx = a
        fmul    st0, st2                        ; st0 = x_1*a     | st1 = y_1       | st2 = a
        fsubp                                   ; st0 = b         | st1 = a
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@lineco.sse
$else
  @@lineco.fpu
$end

; ------------------------------------------------------------------------------

; coefficients of linear function passing through the points (x_1,y_1) and (x_2,y_2)
; double co.lineco ( double *a, double *b, double x_1, double y_1, double x_2, double y_2 )
; f(x) = a*x + b
;
; x_1 = rsp + 00
; y_1 = rsp + 08
; x_2 = rsp + 16
; y_2 = rsp + 24
;
; rax = a offset
; rdx = b offset
;
; return_1 = st1 = a
; return_2 = st0 = b
;
; return   = st0 = a

macro @@co.lineco.sse
{
$usprocf @@co.lineco

        movsd   xmm0, qword [rsp]               ; xmm0 = x_1
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y_1
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = x_2
        movsd   xmm3, qword [rsp + 24]          ; xmm3 = y_2
    .enter:
        subsd   xmm3, xmm1                      ; xmm3 = (y_2-y_1) = Dy
        subsd   xmm2, xmm0                      ; xmm2 = (x_2-x_1) = Dx
        divsd   xmm3, xmm2                      ; xmm3 = Dy/Dx = a
        mulsd   xmm0, xmm3                      ; xmm0 = x_1*a
        subsd   xmm1, xmm0                      ; xmm1 = b
        movsd   xmm0, xmm3                      ; xmm0 = a
    .assign:
        movsd   qword [rax], xmm0
        movsd   qword [rdx], xmm1
    .return:
        retn
$endp
}

macro @@co.lineco.fpu
{
$usprocf @@co.lineco

        fld     qword [rsp + 24]
        fld     qword [rsp + 08]                ; st0 = y_1       | st1 = y_2
        fsub    st1, st0                        ; st0 = y_1       | st1 = (y_2-y_1)
        fld     qword [rsp + 16]
        fld     qword [rsp + 00]                ; st0 = x_1       | st1 = x_2       | st2 = y_1       | st3 = (y_2-y_1)
        fsub    st1, st0                        ; st0 = x_1       | st1 = (x_2-x_1) | st2 = y_1       | st3 = (y_2-y_1)
        fxch    st1                             ; st0 = (x_2-x_1) | st1 = x_1       | st2 = y_1       | st3 = (y_2-y_1)
        fdivp   st3, st0                        ; st0 = x_1       | st1 = y_1       | st2 = Dy/Dx = a
        fmul    st0, st2                        ; st0 = x_1*a     | st1 = y_1       | st2 = a
        fsubp                                   ; st0 = b         | st1 = a
    .assign:
        fstp    qword [rdx]
        fst     qword [rax]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.lineco.sse
$else
  @@co.lineco.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; rescale
; double rescale ( double x, double x_1, double y_1, double x_2, double y_2 )
;
; x   = rsp
; x_1 = rsp + 08
; y_1 = rsp + 16
; x_2 = rsp + 24
; y_2 = rsp + 32
;
; returns:
; y_1 + (x-x_1) * (y_2-y_1) / (x_2-x_1)

macro @@rescale.sse
{
$usprocf @@rescale

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x_1
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y_1
        movsd   xmm3, qword [rsp + 24]          ; xmm3 = x_2
        movsd   xmm4, qword [rsp + 32]          ; xmm4 = y_2
    .enter:
        subsd   xmm0, xmm1                      ; xmm0 = (x-x_1)
        subsd   xmm4, xmm2                      ; xmm4 = (y_2-y_1)
        subsd   xmm3, xmm1                      ; xmm3 = (x_2-x_1)
        divsd   xmm4, xmm3                      ; xmm4 = Dy/Dx
        mulsd   xmm0, xmm4                      ; xmm0 = (x-x_1)*Dy/Dx
        addsd   xmm0, xmm2                      ; xmm0 = (x-x_1)*Dy/Dx + y_1
    .return:
        retn
$endp
}

macro @@rescale.fpu
{
$usprocf @@rescale

        fld     qword [rsp]
        fld     qword [rsp + 08]
        fld     qword [rsp + 24]
        fld     qword [rsp + 32]
        fld     qword [rsp + 16]
    .enter:                                     ; st0 = y_1       | st1 = y_2       | st2 = x_2       | st3 = x_1     | st4 = x
        fsub    st1, st0                        ; st0 = y_1       | st1 = (y_2-y_1) | st2 = x_2       | st3 = x_1     | st4 = x
        fxch    st3                             ; st0 = x_1       | st1 = (y_2-y_1) | st2 = x_2       | st3 = y_1     | st4 = x
        fsub    st2, st0                        ; st0 = x_1       | st1 = (y_2-y_1) | st2 = (x_2-x_1) | st3 = y_1     | st4 = x
        fsubp   st4, st0                        ; st0 = (y_2-y_1) | st1 = (x_2-x_1) | st2 = y_1       | st3 = (x-x_1) |
        fdivrp                                  ; st0 = Dy/Dx     | st1 = y_1       | st2 = (x-x_1)   |               |
        fmulp   st2, st0                        ; st0 = y_1       | st2 = (x-x_1)*Dy/Dx
        faddp                                   ; st0 = (x-x_1)*Dy/Dx + y_1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rescale.sse
$else
  @@rescale.fpu
$end

; ------------------------------------------------------------------------------

; resclip
; rescale with clipping
; double resclip ( double x, double x_1, double y_1, double x_2, double y_2 )
;
; x   = rsp
; x_1 = rsp + 08
; y_1 = rsp + 16 = rsp + 08 + 08
; x_2 = rsp + 24
; y_2 = rsp + 32 = rsp + 24 + 08
;
; returns:
; y(x_min) : x <= x_min
; y(x_max) : x >= x_max
; y_1 + (x-x_1) * (y_2-y_1) / (x_2-x_1) : otherwise

macro @@resclip.sse
{
$usprocf @@resclip

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = x_1
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = y_1
        movsd   xmm3, qword [rsp + 24]          ; xmm3 = x_2
        movsd   xmm4, qword [rsp + 32]          ; xmm4 = y_2
    .enter:
        comisd  xmm1, xmm3                      ; compare x_1 to x_2
        jb     .main
        @@.xch  xmm1, xmm3
        @@.xch  xmm2, xmm4
    .main:
        comisd  xmm0, xmm3                      ; compare x to x_max
        jae    .x_max
        comisd  xmm0, xmm1                      ; compare x to x_min
        ja     .rescale
    .x_min:
        movsd   xmm0, xmm2                      ; return y(x_min)
        jmp    .return
    .x_max:
        movsd   xmm0, xmm4                      ; return y(x_max)
        jmp    .return
    .rescale:
        subsd   xmm0, xmm1                      ; xmm0 = (x-x_1)
        subsd   xmm4, xmm2                      ; xmm4 = (y_2-y_1)
        subsd   xmm3, xmm1                      ; xmm3 = (x_2-x_1)
        divsd   xmm4, xmm3                      ; xmm4 = Dy/Dx
        mulsd   xmm0, xmm4                      ; xmm0 = (x-x_1)*Dy/Dx
        addsd   xmm0, xmm2                      ; xmm0 = (x-x_1)*Dy/Dx + y_1

    .return:
        retn
$endp
}

macro @@resclip.fpu
{
$usprocf @@resclip

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        mov     rdx, 08                         ; rdx = x_min (x_1)
        mov     rcx, 24                         ; rcx = x_max (x_2)
        fld     qword [rsp + rdx]               ; st0 = x_1 | st1 = x
        fcom    qword [rsp + rcx]               ; compare x_1 to x_2
        fnjle   @F                              ; jump if x_1 <= x_2
        mov     rdx, 24                         ; rdx = x_min (x_2)
        mov     rcx, 08                         ; rcx = x_max (x_1)
        fstp    st0
        fld     qword [rsp + rdx]
                                                ; x_1 EQU x_min
                                                ; x_2 EQU x_max
    @@:                                         ; st0 = x_1 | st1 = x
        fcom    st1                             ; compare x_1 to x
        fnjl    @F                              ; jump if x_1 < x (x > x_1)
        fstp    st0                             ; st0 = x
        fstp    st0
        fld     qword [rsp + rdx + 08]          ; st0 = y_1
        jmp    .return                          ; x <= x_1
    @@:
        fld     qword [rsp + rcx]               ; st0 = x_2 | st1 = x_1 | st2 = x
        fcom    st2                             ; compare x_2 to x
        fnjg    @F                              ; jump if x_2 > x (x < x_2)
        fstp    st0                             ; st0 = x_1 | st1 = x
        fstp    st0                             ; st0 = x
        fstp    st0
        fld     qword [rsp + rcx + 08]          ; st0 = y_2
        jmp    .return                          ; x >= x_2
    @@:                                         ; st0 = x_2       | st1 = x_1       | st2 = x         |               |
        fld     qword [rsp + rcx + 08]          ; st0 = y_2       | st1 = x_2       | st2 = x_1       | st3 = x       |
        fld     qword [rsp + rdx + 08]          ; st0 = y_1       | st1 = y_2       | st2 = x_2       | st3 = x_1     | st4 = x
        fsub    st1, st0                        ; st0 = y_1       | st1 = (y_2-y_1) | st2 = x_2       | st3 = x_1     | st4 = x
        fxch    st3                             ; st0 = x_1       | st1 = (y_2-y_1) | st2 = x_2       | st3 = y_1     | st4 = x
        fsub    st2, st0                        ; st0 = x_1       | st1 = (y_2-y_1) | st2 = (x_2-x_1) | st3 = y_1     | st4 = x
        fsubp   st4, st0                        ; st0 = (y_2-y_1) | st1 = (x_2-x_1) | st2 = y_1       | st3 = (x-x_1) |
        fdivrp                                  ; st0 = Dy/Dx     | st1 = y_1       | st2 = (x-x_1)   |               |
        fmulp   st2, st0                        ; st0 = y_1       | st2 = (x-x_1)*Dy/Dx
        faddp                                   ; st0 = (x-x_1)*Dy/Dx + y_1

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@resclip.sse
$else
  @@resclip.fpu
$end

; ------------------------------------------------------------------------------
