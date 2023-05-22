
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (data modifier functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; mul.2pi data modifier
; double :2pi ( double v )
; v = rsp
; v:mul.2pi = v*(2pi)

macro @@.mul.2pi.sse
{
$usprocf @@.mul.2pi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.2pi
    .return:
        retn
$endp
}

macro @@.mul.2pi.fpu
{
$usprocf @@.mul.2pi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.2pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.mul.2pi.sse
$else
  @@.mul.2pi.fpu
$end

; ------------------------------------------------------------------------------

; mul.2pi data modifier
; double :2pi ( integer v )
; v = rsp
; v:mul.2pi = v*(2pi)

macro @@_mul.2pi_int.sse
{
$usprocf @@_mul.2pi_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.2pi
    .return:
        retn
$endp
}

macro @@_mul.2pi_int.fpu
{
$usprocf @@_mul.2pi_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.2pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul.2pi_int.sse
$else
  @@_mul.2pi_int.fpu
$end

; ------------------------------------------------------------------------------

; mul.pi data modifier
; double :pi ( double v )
; v = rsp
; v:mul.pi = v*(pi)

macro @@.mul.pi.sse
{
$usprocf @@.mul.pi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.pi
    .return:
        retn
$endp
}

macro @@.mul.pi.fpu
{
$usprocf @@.mul.pi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fldpi
        fmulp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.mul.pi.sse
$else
  @@.mul.pi.fpu
$end

; ------------------------------------------------------------------------------

; mul.pi data modifier
; double :pi ( integer v )
; v = rsp
; v:mul.pi = v*(pi)

macro @@_mul.pi_int.sse
{
$usprocf @@_mul.pi_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.pi
    .return:
        retn
$endp
}

macro @@_mul.pi_int.fpu
{
$usprocf @@_mul.pi_int

        fild    qword [rsp]
    .enter:
        fldpi
        fmulp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul.pi_int.sse
$else
  @@_mul.pi_int.fpu
$end

; ------------------------------------------------------------------------------

; mul.pi2 data modifier
; double :pi2 ( double v )
; v = rsp
; v:mul.pi2 = v*(pi/2)

macro @@.mul.pi2.sse
{
$usprocf @@.mul.pi2

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.pi2
    .return:
        retn
$endp
}

macro @@.mul.pi2.fpu
{
$usprocf @@.mul.pi2

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.pi2
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.mul.pi2.sse
$else
  @@.mul.pi2.fpu
$end

; ------------------------------------------------------------------------------

; mul.pi2 data modifier
; double :pi2 ( integer v )
; v = rsp
; v:mul.pi2 = v*(pi/2)

macro @@_mul.pi2_int.sse
{
$usprocf @@_mul.pi2_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.pi2
    .return:
        retn
$endp
}

macro @@_mul.pi2_int.fpu
{
$usprocf @@_mul.pi2_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.pi2
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul.pi2_int.sse
$else
  @@_mul.pi2_int.fpu
$end

; ------------------------------------------------------------------------------

; mul.pi4 data modifier
; double :pi4 ( double v )
; v = rsp
; v:mul.pi4 = v*(pi/4)

macro @@.mul.pi4.sse
{
$usprocf @@.mul.pi4

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.pi4
    .return:
        retn
$endp
}

macro @@.mul.pi4.fpu
{
$usprocf @@.mul.pi4

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.pi4
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.mul.pi4.sse
$else
  @@.mul.pi4.fpu
$end

; ------------------------------------------------------------------------------

; mul.pi4 data modifier
; double :pi4 ( integer v )
; v = rsp
; v:mul.pi4 = v*(pi/4)

macro @@_mul.pi4_int.sse
{
$usprocf @@_mul.pi4_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.pi4
    .return:
        retn
$endp
}

macro @@_mul.pi4_int.fpu
{
$usprocf @@_mul.pi4_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.pi4
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul.pi4_int.sse
$else
  @@_mul.pi4_int.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; div.2pi data modifier
; double :/2pi ( double v )
; v = rsp
; v:div.2pi = v/(2pi) = v*(1/2pi)

macro @@.div.2pi.sse
{
$usprocf @@.div.2pi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1D.2pi
    .return:
        retn
$endp
}

macro @@.div.2pi.fpu
{
$usprocf @@.div.2pi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1D.2pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.div.2pi.sse
$else
  @@.div.2pi.fpu
$end

; ------------------------------------------------------------------------------

; div.2pi data modifier
; double :/2pi ( integer v )
; v = rsp
; v:div.2pi = v/(2pi) = v*(1/2pi)

macro @@_div.2pi_int.sse
{
$usprocf @@_div.2pi_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.1D.2pi
    .return:
        retn
$endp
}

macro @@_div.2pi_int.fpu
{
$usprocf @@_div.2pi_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.1D.2pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div.2pi_int.sse
$else
  @@_div.2pi_int.fpu
$end

; ------------------------------------------------------------------------------

; div.pi data modifier
; double :/pi ( double v )
; v = rsp
; v:div.pi = v/(pi) = v*(1/pi)

macro @@.div.pi.sse
{
$usprocf @@.div.pi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1D.pi
    .return:
        retn
$endp
}

macro @@.div.pi.fpu
{
$usprocf @@.div.pi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1D.pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.div.pi.sse
$else
  @@.div.pi.fpu
$end

; ------------------------------------------------------------------------------

; div.pi data modifier
; double :/pi ( integer v )
; v = rsp
; v:div.pi = v/(pi) = v*(1/pi)

macro @@_div.pi_int.sse
{
$usprocf @@_div.pi_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.1D.pi
    .return:
        retn
$endp
}

macro @@_div.pi_int.fpu
{
$usprocf @@_div.pi_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.1D.pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div.pi_int.sse
$else
  @@_div.pi_int.fpu
$end

; ------------------------------------------------------------------------------

; div.pi2 data modifier
; double :/pi2 ( double v )
; v = rsp
; v:div.pi2 = v/(pi/2) = v*(2/pi)

macro @@.div.pi2.sse
{
$usprocf @@.div.pi2

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.2D.pi
    .return:
        retn
$endp
}

macro @@.div.pi2.fpu
{
$usprocf @@.div.pi2

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.2D.pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.div.pi2.sse
$else
  @@.div.pi2.fpu
$end

; ------------------------------------------------------------------------------

; div.pi2 data modifier
; double :/pi2 ( integer v )
; v = rsp
; v:div.pi2 = v/(pi/2) = v*(2/pi)

macro @@_div.pi2_int.sse
{
$usprocf @@_div.pi2_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.2D.pi
    .return:
        retn
$endp
}

macro @@_div.pi2_int.fpu
{
$usprocf @@_div.pi2_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.2D.pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div.pi2_int.sse
$else
  @@_div.pi2_int.fpu
$end

; ------------------------------------------------------------------------------

; div.pi4 data modifier
; double :/pi4 ( double v )
; v = rsp
; v:div.pi4 = v/(pi/4) = v*(4/pi)

macro @@.div.pi4.sse
{
$usprocf @@.div.pi4

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.4D.pi
    .return:
        retn
$endp
}

macro @@.div.pi4.fpu
{
$usprocf @@.div.pi4

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.4D.pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.div.pi4.sse
$else
  @@.div.pi4.fpu
$end

; ------------------------------------------------------------------------------

; div.pi4 data modifier
; double :/pi4 ( integer v )
; v = rsp
; v:div.pi4 = v/(pi/4) = v*(4/pi)

macro @@_div.pi4_int.sse
{
$usprocf @@_div.pi4_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.4D.pi
    .return:
        retn
$endp
}

macro @@_div.pi4_int.fpu
{
$usprocf @@_div.pi4_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.4D.pi
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div.pi4_int.sse
$else
  @@_div.pi4_int.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; quo.2pi data modifier
; double :\2pi ( double v )
; v = rsp
; v:quo.2pi = v quo (2pi)

macro @@.quo.2pi.sse
{
$usprocf @@.quo.2pi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1D.2pi
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@.quo.2pi.fpu
{
$usprocf @@.quo.2pi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1D.2pi
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.quo.2pi.sse
$else
  @@.quo.2pi.fpu
$end

; ------------------------------------------------------------------------------

; quo.2pi data modifier
; double :\2pi ( integer v )
; v = rsp
; v:quo.2pi = v quo (2pi)

macro @@_quo.2pi_int.sse
{
$usprocf @@_quo.2pi_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.1D.2pi
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@_quo.2pi_int.fpu
{
$usprocf @@_quo.2pi_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.1D.2pi
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo.2pi_int.sse
$else
  @@_quo.2pi_int.fpu
$end

; ------------------------------------------------------------------------------

; quo.pi data modifier
; double :\pi ( double v )
; v = rsp
; v:quo.pi = v quo (pi)

macro @@.quo.pi.sse
{
$usprocf @@.quo.pi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1D.pi
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@.quo.pi.fpu
{
$usprocf @@.quo.pi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1D.pi
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.quo.pi.sse
$else
  @@.quo.pi.fpu
$end

; ------------------------------------------------------------------------------

; quo.pi data modifier
; double :\pi ( integer v )
; v = rsp
; v:quo.pi = v quo (pi)

macro @@_quo.pi_int.sse
{
$usprocf @@_quo.pi_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.1D.pi
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@_quo.pi_int.fpu
{
$usprocf @@_quo.pi_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.1D.pi
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo.pi_int.sse
$else
  @@_quo.pi_int.fpu
$end

; ------------------------------------------------------------------------------

; quo.pi2 data modifier
; double :\pi2 ( double v )
; v = rsp
; v:quo.pi2 = v quo (pi/2)

macro @@.quo.pi2.sse
{
$usprocf @@.quo.pi2

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1D.pi2
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@.quo.pi2.fpu
{
$usprocf @@.quo.pi2

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1D.pi2
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.quo.pi2.sse
$else
  @@.quo.pi2.fpu
$end

; ------------------------------------------------------------------------------

; quo.pi2 data modifier
; double :\pi2 ( integer v )
; v = rsp
; v:quo.pi2 = v quo (pi/2)

macro @@_quo.pi2_int.sse
{
$usprocf @@_quo.pi2_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.1D.pi2
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@_quo.pi2_int.fpu
{
$usprocf @@_quo.pi2_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.1D.pi2
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo.pi2_int.sse
$else
  @@_quo.pi2_int.fpu
$end

; ------------------------------------------------------------------------------

; quo.pi4 data modifier
; double :\pi4 ( double v )
; v = rsp
; v:quo.pi4 = v quo (pi/4)

macro @@.quo.pi4.sse
{
$usprocf @@.quo.pi4

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1D.pi4
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@.quo.pi4.fpu
{
$usprocf @@.quo.pi4

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1D.pi4
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@.quo.pi4.sse
$else
  @@.quo.pi4.fpu
$end

; ------------------------------------------------------------------------------

; quo.pi4 data modifier
; double :\pi4 ( integer v )
; v = rsp
; v:quo.pi4 = v quo (pi/4)

macro @@_quo.pi4_int.sse
{
$usprocf @@_quo.pi4_int

        cvtsi2sd xmm0, qword [rsp]
    .enter:
        xmulsd  xmm0, ??.1D.pi4
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@_quo.pi4_int.fpu
{
$usprocf @@_quo.pi4_int

        fild    qword [rsp]
    .enter:
        fmulq   ??.1D.pi4
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo.pi4_int.sse
$else
  @@_quo.pi4_int.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; mod.2pi data modifier
; double :%2pi ( double v )
; v = rsp
; v:mod.2pi = v mod (2pi)

macro @@.mod.2pi.sse
{
$usprocf @@.mod.2pi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm1, xmm0
        xmulsd  xmm1, ??.1D.2pi
        xintsd  xmm1, xmm1
        xmovsd  xmm4, ??.2pi                    ; xmm4 = D = 2pi
        mulsd   xmm1, xmm4
        subsd   xmm0, xmm1
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@.mod.2pi.fpu
{
$usprocf @@.mod.2pi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fldq    ??.2pi
        fxch                                    ; st0 = x       | st1 = D = 2pi
        fprem                                   ; st0 = x mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = x mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@.mod.2pi.sse
$else
  @@.mod.2pi.fpu
$end

; ------------------------------------------------------------------------------

; mod.2pi data modifier
; double :%2pi ( integer v )
; v = rsp
; v:mod.2pi = v mod (2pi)

macro @@_mod.2pi_int.sse
{
$usprocf @@_mod.2pi_int

        cvtsi2sd xmm0, qword [rsp]
   .enter:
        movsd   xmm1, xmm0
        xmulsd  xmm1, ??.1D.2pi
        xintsd  xmm1, xmm1
        xmovsd  xmm4, ??.2pi                    ; xmm4 = D = 2pi
        mulsd   xmm1, xmm4
        subsd   xmm0, xmm1
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@_mod.2pi_int.fpu
{
$usprocf @@_mod.2pi_int

        fild    qword [rsp]
   .enter:
        fldq    ??.2pi
        fxch                                    ; st0 = x       | st1 = D = 2pi
        fprem                                   ; st0 = x mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = x mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod.2pi_int.sse
$else
  @@_mod.2pi_int.fpu
$end

; ------------------------------------------------------------------------------

; mod.pi data modifier
; double :%pi ( double v )
; v = rsp
; v:mod.pi = v mod (pi)

macro @@.mod.pi.sse
{
$usprocf @@.mod.pi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm1, xmm0
        xmulsd  xmm1, ??.1D.pi
        xintsd  xmm1, xmm1
        xmovsd  xmm4, ??.pi                     ; xmm4 = D = pi
        mulsd   xmm1, xmm4
        subsd   xmm0, xmm1
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@.mod.pi.fpu
{
$usprocf @@.mod.pi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fldq    ??.pi
        fxch                                    ; st0 = x       | st1 = D = pi
        fprem                                   ; st0 = x mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = x mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@.mod.pi.sse
$else
  @@.mod.pi.fpu
$end

; ------------------------------------------------------------------------------

; mod.pi data modifier
; double :%pi ( integer v )
; v = rsp
; v:mod.pi = v mod (pi)

macro @@_mod.pi_int.sse
{
$usprocf @@_mod.pi_int

        cvtsi2sd xmm0, qword [rsp]
   .enter:
        movsd   xmm1, xmm0
        xmulsd  xmm1, ??.1D.pi
        xintsd  xmm1, xmm1
        xmovsd  xmm4, ??.pi                     ; xmm4 = D = pi
        mulsd   xmm1, xmm4
        subsd   xmm0, xmm1
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@_mod.pi_int.fpu
{
$usprocf @@_mod.pi_int

        fild    qword [rsp]
   .enter:
        fldq    ??.pi
        fxch                                    ; st0 = x       | st1 = D = pi
        fprem                                   ; st0 = x mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = x mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod.pi_int.sse
$else
  @@_mod.pi_int.fpu
$end

; ------------------------------------------------------------------------------

; mod.pi2 data modifier
; double :%pi2 ( double v )
; v = rsp
; v:mod.pi2 = v mod (pi/2)

macro @@.mod.pi2.sse
{
$usprocf @@.mod.pi2

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm1, xmm0
        xmulsd  xmm1, ??.1D.pi2
        xintsd  xmm1, xmm1
        xmovsd  xmm4, ??.pi2                    ; xmm4 = D = pi/2
        mulsd   xmm1, xmm4
        subsd   xmm0, xmm1
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@.mod.pi2.fpu
{
$usprocf @@.mod.pi2

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fldq    ??.pi2
        fxch                                    ; st0 = x       | st1 = D = pi/2
        fprem                                   ; st0 = x mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = x mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@.mod.pi2.sse
$else
  @@.mod.pi2.fpu
$end

; ------------------------------------------------------------------------------

; mod.pi2 data modifier
; double :%pi2 ( integer v )
; v = rsp
; v:mod.pi2 = v mod (pi/2)

macro @@_mod.pi2_int.sse
{
$usprocf @@_mod.pi2_int

        cvtsi2sd xmm0, qword [rsp]
   .enter:
        movsd   xmm1, xmm0
        xmulsd  xmm1, ??.1D.pi2
        xintsd  xmm1, xmm1
        xmovsd  xmm4, ??.pi2                    ; xmm4 = D = pi/2
        mulsd   xmm1, xmm4
        subsd   xmm0, xmm1
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@_mod.pi2_int.fpu
{
$usprocf @@_mod.pi2_int

        fild    qword [rsp]
   .enter:
        fldq    ??.pi2
        fxch                                    ; st0 = x       | st1 = D = pi/2
        fprem                                   ; st0 = x mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = x mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod.pi2_int.sse
$else
  @@_mod.pi2_int.fpu
$end

; ------------------------------------------------------------------------------

; mod.pi4 data modifier
; double :%pi4 ( double v )
; v = rsp
; v:mod.pi4 = v mod (pi/4)

macro @@.mod.pi4.sse
{
$usprocf @@.mod.pi4

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm1, xmm0
        xmulsd  xmm1, ??.1D.pi4
        xintsd  xmm1, xmm1
        xmovsd  xmm4, ??.pi4                    ; xmm4 = D = pi/4
        mulsd   xmm1, xmm4
        subsd   xmm0, xmm1
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@.mod.pi4.fpu
{
$usprocf @@.mod.pi4

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fldq    ??.pi4
        fxch                                    ; st0 = x       | st1 = D = pi/4
        fprem                                   ; st0 = x mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = x mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@.mod.pi4.sse
$else
  @@.mod.pi4.fpu
$end

; ------------------------------------------------------------------------------

; mod.pi4 data modifier
; double :%pi4 ( integer v )
; v = rsp
; v:mod.pi4 = v mod (pi/4)

macro @@_mod.pi4_int.sse
{
$usprocf @@_mod.pi4_int

        cvtsi2sd xmm0, qword [rsp]
   .enter:
        movsd   xmm1, xmm0
        xmulsd  xmm1, ??.1D.pi4
        xintsd  xmm1, xmm1
        xmovsd  xmm4, ??.pi4                    ; xmm4 = D = pi/4
        mulsd   xmm1, xmm4
        subsd   xmm0, xmm1
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@_mod.pi4_int.fpu
{
$usprocf @@_mod.pi4_int

        fild    qword [rsp]
   .enter:
        fldq    ??.pi4
        fxch                                    ; st0 = x       | st1 = D = pi/4
        fprem                                   ; st0 = x mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = x mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod.pi4_int.sse
$else
  @@_mod.pi4_int.fpu
$end

; ------------------------------------------------------------------------------
