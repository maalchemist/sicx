
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (trigonometric functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; sine
; |x| < 2^63

macro @@sin.sse.fpu
{
$usprocf @@sin

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsin
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@sin.fpu
{
$usprocf @@sin

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsin
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sin.sse.fpu
$else
  @@sin.fpu
$end

; ------------------------------------------------------------------------------

; cosine
; |x| < 2^63

macro @@cos.sse.fpu
{
$usprocf @@cos

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fcos
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@cos.fpu
{
$usprocf @@cos

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fcos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@cos.sse.fpu
$else
  @@cos.fpu
$end

; ------------------------------------------------------------------------------

; sine & cosine
; |x| < 2^63
;
; return_1 = st1 = sin
; return_2 = st0 = cos

macro @@sincos.sse.fpu
{
$usprocf @@sincos

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos | st1 = sin
    .return:
        @@.fstp.xmm1                            ; xmm1 = cos
        @@.fstp.xmm0                            ; xmm0 = sin
        retn
$endp
}

macro @@sincos.fpu
{
$usprocf @@sincos

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos | st1 = sin
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sincos.sse.fpu
$else
  @@sincos.fpu
$end

; ------------------------------------------------------------------------------

; sine & cosine
; double co.sincos ( double *sin, double *cos, double x )
; |x| < 2^63
;
; x = rsp
;
; rax = sin offset
; rdx = cos offset
;
; return_1 = st1 = sin
; return_2 = st0 = cos
;
; return   = st0 = sin

macro @@co.sincos.sse.fpu
{
$usprocf @@co.sincos

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos | st1 = sin
    .return:
        fstp    qword [rdx]
        fstp    qword [rax]
        ;
        movsd   xmm0, qword [rax]               ; xmm0 = sin
;       movsd   xmm1, qword [rdx]               ; xmm1 = cos
        retn
$endp
}

macro @@co.sincos.fpu
{
$usprocf @@co.sincos

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos | st1 = sin
    .return:
        fstp    qword [rdx]
        fst     qword [rax]
        retn
$endp
}

$ifdef _SSEX
  @@co.sincos.sse.fpu
$else
  @@co.sincos.fpu
$end

; ------------------------------------------------------------------------------

; cosine & sine
; |x| < 2^63
;
; return_1 = st1 = cos
; return_2 = st0 = sin

macro @@cossin.sse.fpu
{
$usprocf @@cossin

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos | st1 = sin
    .return:
        @@.fstp.xmm0                            ; xmm0 = cos
        @@.fstp.xmm1                            ; xmm1 = sin
        retn
$endp
}

macro @@cossin.fpu
{
$usprocf @@cossin

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos | st1 = sin
        fxch                                    ; st0 = sin | st1 = cos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@cossin.sse.fpu
$else
  @@cossin.fpu
$end

; ------------------------------------------------------------------------------

; cosine & sine
; double co.cossin ( double *cos, double *sin, double x )
; |x| < 2^63
;
; x = rsp
;
; rax = cos offset
; rdx = sin offset
;
; return_1 = st1 = cos
; return_2 = st0 = sin
;
; return   = st0 = cos

macro @@co.cossin.sse.fpu
{
$usprocf @@co.cossin

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos | st1 = sin
    .return:
        fstp    qword [rax]
        fstp    qword [rdx]
        ;
        movsd   xmm0, qword [rax]               ; xmm0 = cos
;       movsd   xmm1, qword [rdx]               ; xmm1 = sin
        retn
$endp
}

macro @@co.cossin.fpu
{
$usprocf @@co.cossin

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos | st1 = sin
        fxch                                    ; st0 = sin | st1 = cos
    .return:
        fstp    qword [rdx]
        fst     qword [rax]
        retn
$endp
}

$ifdef _SSEX
  @@co.cossin.sse.fpu
$else
  @@co.cossin.fpu
$end

; ------------------------------------------------------------------------------

; secant
; f(x) = 1 / cos(x)
; |x| < 2^63

macro @@sec.sse.fpu
{
$usprocf @@sec

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        fdivrp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@sec.fpu
{
$usprocf @@sec

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sec.sse.fpu
$else
  @@sec.fpu
$end

; ------------------------------------------------------------------------------

; cosecant
; f(x) = 1 / sin(x)
; |x| < 2^63

macro @@csc.sse.fpu
{
$usprocf @@csc

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        fdivrp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@csc.fpu
{
$usprocf @@csc

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@csc.sse.fpu
$else
  @@csc.fpu
$end

; ------------------------------------------------------------------------------

; tangent
; |x| < 2^63

macro @@tan.sse.fpu
{
$usprocf @@tan

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.tan.cotan.core.reduce
        fptan
        fstp    st0
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@tan.fpu
{
$usprocf @@tan

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.tan.cotan.core.reduce
        fptan
        fstp    st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@tan.sse.fpu
$else
  @@tan.fpu
$end

; ------------------------------------------------------------------------------

; cotangent
; |x| < 2^63

macro @@cotan.sse.fpu
{
$usprocf @@cotan

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.tan.cotan.core.reduce
        fptan
        fdivrp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@cotan.fpu
{
$usprocf @@cotan

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.tan.cotan.core.reduce
        fptan
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@cotan.sse.fpu
$else
  @@cotan.fpu
$end

; ------------------------------------------------------------------------------

; versed sine
; f(x) = 1 - cos(x)
; |x| < 2^63

macro @@versine.sse.fpu
{
$usprocf @@versine

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        fsubrp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@versine.fpu
{
$usprocf @@versine

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        fsubrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@versine.sse.fpu
$else
  @@versine.fpu
$end

; ------------------------------------------------------------------------------

; versed cosine
; f(x) = 1 + cos(x)
; |x| < 2^63

macro @@vercosine.sse.fpu
{
$usprocf @@vercosine

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        faddp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@vercosine.fpu
{
$usprocf @@vercosine

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        faddp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vercosine.sse.fpu
$else
  @@vercosine.fpu
$end

; ------------------------------------------------------------------------------

; coversed sine
; f(x) = 1 - sin(x)
; |x| < 2^63

macro @@coversine.sse.fpu
{
$usprocf @@coversine

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        fsubrp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@coversine.fpu
{
$usprocf @@coversine

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        fsubrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@coversine.sse.fpu
$else
  @@coversine.fpu
$end

; ------------------------------------------------------------------------------

; coversed cosine
; f(x) = 1 + sin(x)
; |x| < 2^63

macro @@covercosine.sse.fpu
{
$usprocf @@covercosine

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        faddp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@covercosine.fpu
{
$usprocf @@covercosine

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        faddp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@covercosine.sse.fpu
$else
  @@covercosine.fpu
$end

; ------------------------------------------------------------------------------

; haversed sine
; f(x) = [1 - cos(x)] / 2
; |x| < 2^63

macro @@haversine.sse.fpu
{
$usprocf @@haversine

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        fsubrp
        fmulq   ??.0.5
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@haversine.fpu
{
$usprocf @@haversine

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        fsubrp
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@haversine.sse.fpu
$else
  @@haversine.fpu
$end

; ------------------------------------------------------------------------------

; haversed cosine
; f(x) = [1 + cos(x)] / 2
; |x| < 2^63

macro @@havercosine.sse.fpu
{
$usprocf @@havercosine

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        faddp
        fmulq   ??.0.5
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@havercosine.fpu
{
$usprocf @@havercosine

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        faddp
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@havercosine.sse.fpu
$else
  @@havercosine.fpu
$end

; ------------------------------------------------------------------------------

; hacoversed sine
; f(x) = [1 - sin(x)] / 2
; |x| < 2^63

macro @@hacoversine.sse.fpu
{
$usprocf @@hacoversine

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        fsubrp
        fmulq   ??.0.5
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@hacoversine.fpu
{
$usprocf @@hacoversine

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        fsubrp
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@hacoversine.sse.fpu
$else
  @@hacoversine.fpu
$end

; ------------------------------------------------------------------------------

; hacoversed cosine
; f(x) = [1 + sin(x)] / 2
; |x| < 2^63

macro @@hacovercosine.sse.fpu
{
$usprocf @@hacovercosine

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        faddp
        fmulq   ??.0.5
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@hacovercosine.fpu
{
$usprocf @@hacovercosine

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        faddp
        fmulq   ??.0.5
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@hacovercosine.sse.fpu
$else
  @@hacovercosine.fpu
$end

; ------------------------------------------------------------------------------

; exsecant
; f(x) = sec(x) - 1 = 1 / cos(x) - 1
; |x| < 2^63

macro @@exsec.sse.fpu
{
$usprocf @@exsec

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        fdivrp
        fld1
        fsubp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@exsec.fpu
{
$usprocf @@exsec

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fcos
        fld1
        fdivrp
        fld1
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@exsec.sse.fpu
$else
  @@exsec.fpu
$end

; ------------------------------------------------------------------------------

; excosecant
; f(x) = csc(x) - 1 = 1 / sin(x) - 1
; |x| < 2^63

macro @@excsc.sse.fpu
{
$usprocf @@excsc

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        fdivrp
        fld1
        fsubp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@excsc.fpu
{
$usprocf @@excsc

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@st0.sin.cos.core.reduce
        fsin
        fld1
        fdivrp
        fld1
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@excsc.sse.fpu
$else
  @@excsc.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; inverse sine
; asin(x) = atan2[x, sqrt(1 - x * x)]

macro @@asin.sse.fpu
{
$usprocf @@asin

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0
        fmul    st0, st0
        fld1
        fsubrp
        fsqrt                                   ; st0 = sqrt(1 - x * x), st1 = x
        fpatan
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@asin.fpu
{
$usprocf @@asin

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0
        fmul    st0, st0
        fld1
        fsubrp
        fsqrt                                   ; st0 = sqrt(1 - x * x), st1 = x
        fpatan
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@asin.sse.fpu
$else
  @@asin.fpu
$end

; ------------------------------------------------------------------------------

; inverse cosine
; acos(x) = atan2[sqrt(1 - x * x), x]

macro @@acos.sse.fpu
{
$usprocf @@acos

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
        fxch
        fpatan
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@acos.fpu
{
$usprocf @@acos

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0
        fmul    st0, st0
        fld1
        fsubrp
        fsqrt
        fxch
        fpatan
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@acos.sse.fpu
$else
  @@acos.fpu
$end

; ------------------------------------------------------------------------------

; inverse secant
; asec(x) = acos(1 / x) = atan2[sqrt(x * x - 1), 1]

macro @@asec.sse.fpu
{
$usprocf @@asec

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fmul    st0, st0
        fld1
        fsubp
        fsqrt
        fld1                                    ; st0 = 1, st1 = sqrt(x * x - 1)
        fpatan
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@asec.fpu
{
$usprocf @@asec

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmul    st0, st0
        fld1
        fsubp
        fsqrt
        fld1                                    ; st0 = 1, st1 = sqrt(x * x - 1)
        fpatan
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@asec.sse.fpu
$else
  @@asec.fpu
$end

; ------------------------------------------------------------------------------

; inverse cosecant
; acsc(x) = asin(1 / x) = atan2[1, sqrt(x * x - 1)]

macro @@acsc.sse.fpu
{
$usprocf @@acsc

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fmul    st0, st0
        fld1
        fsubp
        fsqrt
        fld1
        fxch                                    ; st0 = sqrt(x * x - 1), st1 = 1
        fpatan
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@acsc.fpu
{
$usprocf @@acsc

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmul    st0, st0
        fld1
        fsubp
        fsqrt
        fld1
        fxch                                    ; st0 = sqrt(x * x - 1), st1 = 1
        fpatan
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@acsc.sse.fpu
$else
  @@acsc.fpu
$end

; ------------------------------------------------------------------------------

; inverse tangent
; atan(x)

macro @@atan.sse.fpu
{
$usprocf @@atan

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld1                                    ; st0 = 1, st1 = x
        fpatan
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@atan.fpu
{
$usprocf @@atan

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1                                    ; st0 = 1, st1 = x
        fpatan
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@atan.sse.fpu
$else
  @@atan.fpu
$end

; ------------------------------------------------------------------------------

; inverse tangent of y/x
; double atan2 ( double y, double x )
; y = rsp
; x = rsp + 8
;
; atan2(y,x) = atan(y/x)

macro @@atan2.sse.fpu
{
$usprocf @@atan2

        movsd   xmm0, qword [rsp]
        movsd   xmm1, qword [rsp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; xmm0 = y | xmm1 = x
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = x | st1 = y
        ;
        fpatan
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@atan2.fpu
{
$usprocf @@atan2

        fld     qword [rsp]
        fld     qword [rsp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; st0 = x | st1 = y
        fpatan
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@atan2.sse.fpu
$else
  @@atan2.fpu
$end

; ------------------------------------------------------------------------------

; inverse tangent of y/x
; double atan2r ( double x, double y )
; y = rsp
; x = rsp + 8
;
; atan2r(x,y) = atan(y/x)

macro @@atan2r.sse.fpu
{
$usprocf @@atan2r

        movsd   xmm0, qword [rsp]
        movsd   xmm1, qword [rsp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; xmm0 = x | xmm1 = y
        @@.fld.xmm1
        @@.fld.xmm0                             ; st0 = x | st1 = y
        ;
        fpatan
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@atan2r.fpu
{
$usprocf @@atan2r

        fld     qword [rsp]
        fld     qword [rsp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:                                     ; st0 = y | st1 = x
        fxch                                    ; st0 = x | st1 = y
        fpatan
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@atan2r.sse.fpu
$else
  @@atan2r.fpu
$end

; ------------------------------------------------------------------------------

; inverse cotangent
; acotan(x) = pi/2 - atan(x)

macro @@acotan.sse.fpu
{
$usprocf @@acotan

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        ftst                                    ; compare x to 0
        fnjne  .x.ne.0                          ; jump if x <> 0
    .x.eq.0:
        fstp    st0
        fldq    ??.pi2                          ; x = 0, return PI/2
        jmp    .return
    .x.ne.0:                                    ; st0 = x
        fld1                                    ; st0 = 1, st1 = x
        fpatan
        fsubrq  ??.pi2
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@acotan.fpu
{
$usprocf @@acotan

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fnjne  .x.ne.0                          ; jump if x <> 0
    .x.eq.0:
        fstp    st0
        fldq    ??.pi2                          ; x = 0, return PI/2
        jmp    .return
    .x.ne.0:                                    ; st0 = x
        fld1                                    ; st0 = 1, st1 = x
        fpatan
        fsubrq  ??.pi2
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@acotan.sse.fpu
$else
  @@acotan.fpu
$end

; ------------------------------------------------------------------------------
