
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (conversion between various units)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; angle conversion: arc degrees:minutes:seconds to degrees
; double arc2deg ( double d, double m, double s )
; d = esp
; m = esp + 8
; s = esp + 16
;
; degrees = d + m * (1/60) + s * (1/3600)

macro @@arc2deg.sse
{
$usprocf @@arc2deg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        movsd   xmm2, qword [esp + 16]
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm1, ??.deg.per.arc.min
        xmulsd  xmm2, ??.deg.per.arc.sec
        addsd   xmm0, xmm1
        addsd   xmm0, xmm2
    .return:
        retn
$endp
}

macro @@arc2deg.fpu
{
$usprocf @@arc2deg

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fmulq   ??.deg.per.arc.min
        faddp
        fld     qword [esp + 16]
        fmulq   ??.deg.per.arc.sec
        faddp                                   ; st0 = degrees
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arc2deg.sse
$else
  @@arc2deg.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: arc degrees:minutes:seconds to radians
; double arc2rad ( double d, double m, double s )
; d = esp
; m = esp + 8
; s = esp + 16
;
; radians = [d + m * (1/60) + s * (1/3600)] * [radians per degree]

macro @@arc2rad.sse
{
$usprocf @@arc2rad

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        movsd   xmm2, qword [esp + 16]
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm1, ??.deg.per.arc.min
        xmulsd  xmm2, ??.deg.per.arc.sec
        addsd   xmm0, xmm1
        addsd   xmm0, xmm2
        xmulsd  xmm0, ??.rad.per.deg
    .return:
        retn
$endp
}

macro @@arc2rad.fpu
{
$usprocf @@arc2rad

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fmulq   ??.deg.per.arc.min
        faddp
        fld     qword [esp + 16]
        fmulq   ??.deg.per.arc.sec
        faddp                                   ; st0 = degrees
        fmulq   ??.rad.per.deg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arc2rad.sse
$else
  @@arc2rad.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: arc degrees:minutes:seconds to grads
; double arc2grad ( double d, double m, double s )
; d = esp
; m = esp + 8
; s = esp + 16
;
; grads = [d + m * (1/60) + s * (1/3600)] * [grads per degree]

macro @@arc2grad.sse
{
$usprocf @@arc2grad

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        movsd   xmm2, qword [esp + 16]
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm1, ??.deg.per.arc.min
        xmulsd  xmm2, ??.deg.per.arc.sec
        addsd   xmm0, xmm1
        addsd   xmm0, xmm2
        xmulsd  xmm0, ??.grad.per.deg
    .return:
        retn
$endp
}

macro @@arc2grad.fpu
{
$usprocf @@arc2grad

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fmulq   ??.deg.per.arc.min
        faddp
        fld     qword [esp + 16]
        fmulq   ??.deg.per.arc.sec
        faddp                                   ; st0 = degrees
        fmulq   ??.grad.per.deg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arc2grad.sse
$else
  @@arc2grad.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: arc degrees:minutes:seconds to cycles
; double arc2cycle ( double d, double m, double s )
; d = esp
; m = esp + 8
; s = esp + 16
;
; cycles = [d + m * (1/60) + s * (1/3600)] * [cycles per degree]

macro @@arc2cycle.sse
{
$usprocf @@arc2cycle

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        movsd   xmm2, qword [esp + 16]
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm1, ??.deg.per.arc.min
        xmulsd  xmm2, ??.deg.per.arc.sec
        addsd   xmm0, xmm1
        addsd   xmm0, xmm2
        xmulsd  xmm0, ??.cycle.per.deg
    .return:
        retn
$endp
}

macro @@arc2cycle.fpu
{
$usprocf @@arc2cycle

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fmulq   ??.deg.per.arc.min
        faddp
        fld     qword [esp + 16]
        fmulq   ??.deg.per.arc.sec
        faddp                                   ; st0 = degrees
        fmulq   ??.cycle.per.deg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@arc2cycle.sse
$else
  @@arc2cycle.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: degrees to arc degrees:minutes:seconds
; double double double arc2deg ( double x )
; x = esp
;
; return_1 = st2 = degrees
; return_2 = st1 = minutes
; return_3 = st0 = seconds

macro @@deg2arc.sse
{
$usprocf @@deg2arc

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     edi, ??.60.0
        movsd   xmm1, xmm0
        xintsd  xmm0, xmm0
        subsd   xmm1, xmm0
        mulsd   xmm1, qword [edi]
        movsd   xmm2, xmm1
        xintsd  xmm1, xmm1
        subsd   xmm2, xmm1
        mulsd   xmm2, qword [edi]
    .return:
        retn
$endp
}

macro @@deg2arc.fpu
{
$usprocf @@deg2arc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        mov     edi, ??.60.0
        fld     st0
        frndint                                 ; st0 = d        | st1 = x
        fsub    st1, st0                        ; st0 = d        | st1 = (x-d)
        fxch                                    ; st0 = (x-d)    | st1 = d
        fmul    qword [edi]                     ; st0 = 60*(x-d) | st1 = d
        fld     st0                             ; st0 = 60*(x-d) | st1 = 60*(x-d) | st1 = d
        frndint                                 ; st0 = m        | st1 = 60*(x-d) | st2 = d
        fsub    st1, st0                        ; st0 = m        | st1 = s'       | st2 = d
        fxch                                    ; st0 = s'       | st1 = m        | st2 = d
        fmul    qword [edi]                     ; st0 = s        | st1 = m        | st2 = d

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deg2arc.sse
$else
  @@deg2arc.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: degrees to arc degrees:minutes:seconds
; double co.deg2arc ( double *d, double *m, double *s, double x )
; x = esp
;
; eax = d offset
; edx = m offset
; ecx = s offset
;
; return_1 = st2 = degrees
; return_2 = st1 = minutes
; return_3 = st0 = seconds
;
; return   = st0 = degrees

macro @@co.deg2arc.sse
{
$usprocf @@co.deg2arc

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     edi, ??.60.0
        movsd   xmm1, xmm0
        xintsd  xmm0, xmm0
        subsd   xmm1, xmm0
        mulsd   xmm1, qword [edi]
        movsd   xmm2, xmm1
        xintsd  xmm1, xmm1
        subsd   xmm2, xmm1
        mulsd   xmm2, qword [edi]
    .assign:
        movsd   qword [eax], xmm0
        movsd   qword [edx], xmm1
        movsd   qword [ecx], xmm2
    .return:
        retn
$endp
}

macro @@co.deg2arc.fpu
{
$usprocf @@co.deg2arc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        mov     edi, ??.60.0
        fld     st0
        frndint                                 ; st0 = d        | st1 = x
        fsub    st1, st0                        ; st0 = d        | st1 = (x-d)
        fxch                                    ; st0 = (x-d)    | st1 = d
        fmul    qword [edi]                     ; st0 = 60*(x-d) | st1 = d
        fld     st0                             ; st0 = 60*(x-d) | st1 = 60*(x-d) | st1 = d
        frndint                                 ; st0 = m        | st1 = 60*(x-d) | st2 = d
        fsub    st1, st0                        ; st0 = m        | st1 = s'       | st2 = d
        fxch                                    ; st0 = s'       | st1 = m        | st2 = d
        fmul    qword [edi]                     ; st0 = s        | st1 = m        | st2 = d

        @@.fpu.cw.restore                       ; restore control word
    .assign:
        fstp    qword [ecx]
        fstp    qword [edx]
        fst     qword [eax]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.deg2arc.sse
$else
  @@co.deg2arc.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: degrees to radians
;
; 360 degrees = 2PI radians
;    1 degree = [PI/180] radians
;     radians = degrees * [PI/180] = degrees * [radians per degree]

macro @@deg2rad.sse
{
$usprocf @@deg2rad

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.rad.per.deg
    .return:
        retn
$endp
}

macro @@deg2rad.fpu
{
$usprocf @@deg2rad

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.rad.per.deg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deg2rad.sse
$else
  @@deg2rad.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: degrees to grads
;
; 360 degrees = 400 grads
;    1 degree = [400/360] grads = [10/9] grads
;       grads = degrees * [10/9] = degrees * [grads per degree]

macro @@deg2grad.sse
{
$usprocf @@deg2grad

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.grad.per.deg
    .return:
        retn
$endp
}

macro @@deg2grad.fpu
{
$usprocf @@deg2grad

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.grad.per.deg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deg2grad.sse
$else
  @@deg2grad.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: degrees to cycles
;
; 360 degrees = 1 cycle
;    1 degree = [1/360] cycles
;      cycles = degree * [1/360] = degree * [cycles per degree]

macro @@deg2cycle.sse
{
$usprocf @@deg2cycle

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.cycle.per.deg
    .return:
        retn
$endp
}

macro @@deg2cycle.fpu
{
$usprocf @@deg2cycle

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.cycle.per.deg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deg2cycle.sse
$else
  @@deg2cycle.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: radians to degrees
;
; 2PI radians = 360 degrees
;    1 radian = [180/PI] degrees
;     degrees = radians * [180/PI] = radians * [degrees per radian]

macro @@rad2deg.sse
{
$usprocf @@rad2deg

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.deg.per.rad
    .return:
        retn
$endp
}

macro @@rad2deg.fpu
{
$usprocf @@rad2deg

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.deg.per.rad
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rad2deg.sse
$else
  @@rad2deg.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: radians to arc degrees:minutes:seconds
; double double double rad2arc ( double x )
; x = esp
;
; return_1 = st2 = degrees
; return_2 = st1 = minutes
; return_3 = st0 = seconds

macro @@rad2arc.sse
{
$usprocf @@rad2arc

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        xmulsd  xmm0, ??.deg.per.rad, rbx
      $else
        xmulsd  xmm0, ??.deg.per.rad
      $end
        mov     ebx, @@deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

macro @@rad2arc.fpu
{
$usprocf @@rad2arc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        fmulq   ??.deg.per.rad, rbx
      $else
        fmulq   ??.deg.per.rad
      $end
        mov     ebx, @@deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rad2arc.sse
$else
  @@rad2arc.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: radians to arc degrees:minutes:seconds
; double co.rad2arc ( double *d, double *m, double *s, double x )
; x = esp
;
; eax = d offset
; ecx = s offset
; edx = m offset
;
; return_1 = st2 = degrees
; return_2 = st1 = minutes
; return_3 = st0 = seconds
;
; return   = st0 = degrees

macro @@co.rad2arc.sse
{
$usprocf @@co.rad2arc

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        xmulsd  xmm0, ??.deg.per.rad, rbx
      $else
        xmulsd  xmm0, ??.deg.per.rad
      $end
        mov     ebx, @@co.deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

macro @@co.rad2arc.fpu
{
$usprocf @@co.rad2arc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        fmulq   ??.deg.per.rad, rbx
      $else
        fmulq   ??.deg.per.rad
      $end
        mov     ebx, @@co.deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.rad2arc.sse
$else
  @@co.rad2arc.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: radians to grads
;
; 2PI radians = 400 grads
;    1 radian = [200/PI] degrees
;       grads = radians * [200/PI] = radians * [grads per radian]

macro @@rad2grad.sse
{
$usprocf @@rad2grad

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.grad.per.rad
    .return:
        retn
$endp
}

macro @@rad2grad.fpu
{
$usprocf @@rad2grad

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.grad.per.rad
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rad2grad.sse
$else
  @@rad2grad.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: radians to cycles
;
; 2PI radians = 1 cycle
;    1 radian = [1/2PI] cycles
;      cycles = radians * [1/2PI] = radians * [cycles per radian]

macro @@rad2cycle.sse
{
$usprocf @@rad2cycle

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.cycle.per.rad
    .return:
        retn
$endp
}

macro @@rad2cycle.fpu
{
$usprocf @@rad2cycle

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.cycle.per.rad
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rad2cycle.sse
$else
  @@rad2cycle.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: grads to radians
;
; 400 grads = 2PI radians
;    1 grad = [PI/200] radians
;   radians = grads * [PI/200] = grads * [radians per grad]

macro @@grad2rad.sse
{
$usprocf @@grad2rad

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.rad.per.grad
    .return:
        retn
$endp
}

macro @@grad2rad.fpu
{
$usprocf @@grad2rad

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.rad.per.grad
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@grad2rad.sse
$else
  @@grad2rad.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: grads to degrees
;
; 400 grads = 360 degrees
;    1 grad = [360/400] degrees = [9/10] degrees
;   degrees = grads * [9/10] = grads * [degrees per grad]

macro @@grad2deg.sse
{
$usprocf @@grad2deg

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.deg.per.grad
    .return:
        retn
$endp
}

macro @@grad2deg.fpu
{
$usprocf @@grad2deg

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.deg.per.grad
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@grad2deg.sse
$else
  @@grad2deg.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: grads to arc degrees:minutes:seconds
; double double double grad2arc ( double x )
; x = esp
;
; return_1 = st2 = degrees
; return_2 = st1 = minutes
; return_3 = st0 = seconds

macro @@grad2arc.sse
{
$usprocf @@grad2arc

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        xmulsd  xmm0, ??.deg.per.grad, rbx
      $else
        xmulsd  xmm0, ??.deg.per.grad
      $end
        mov     ebx, @@deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

macro @@grad2arc.fpu
{
$usprocf @@grad2arc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        fmulq   ??.deg.per.grad, rbx
      $else
        fmulq   ??.deg.per.grad
      $end
        mov     ebx, @@deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@grad2arc.sse
$else
  @@grad2arc.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: grads to arc degrees:minutes:seconds
; double co.grad2arc ( double *d, double *m, double *s, double x )
; x = esp
;
; eax = d offset
; edx = m offset
; ecx = s offset
;
; return_1 = st2 = degrees
; return_2 = st1 = minutes
; return_3 = st0 = seconds
;
; return   = st0 = degrees

macro @@co.grad2arc.sse
{
$usprocf @@co.grad2arc

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        xmulsd  xmm0, ??.deg.per.grad, rbx
      $else
        xmulsd  xmm0, ??.deg.per.grad
      $end
        mov     ebx, @@co.deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

macro @@co.grad2arc.fpu
{
$usprocf @@co.grad2arc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        fmulq   ??.deg.per.grad, rbx
      $else
        fmulq   ??.deg.per.grad
      $end
        mov     ebx, @@co.deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.grad2arc.sse
$else
  @@co.grad2arc.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: grads to cycles
;
; 400 grads = 1 cycle
;    1 grad = [1/400] cycles
;    cycles = grads * [1/400] = grads * [cycles per grad]

macro @@grad2cycle.sse
{
$usprocf @@grad2cycle

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.cycle.per.grad
    .return:
        retn
$endp
}

macro @@grad2cycle.fpu
{
$usprocf @@grad2cycle

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.cycle.per.grad
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@grad2cycle.sse
$else
  @@grad2cycle.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: cycles to radians
;
; 1 cycle = 2PI radians
; radians = cycles * 2PI = cycles * [radians per cycle]

macro @@cycle2rad.sse
{
$usprocf @@cycle2rad

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.rad.per.cycle
    .return:
        retn
$endp
}

macro @@cycle2rad.fpu
{
$usprocf @@cycle2rad

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.rad.per.cycle
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@cycle2rad.sse
$else
  @@cycle2rad.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: cycles to degrees
;
; 1 cycle = 360 degrees
; degrees = cycles * 360 = cycles * [degrees per cycle]

macro @@cycle2deg.sse
{
$usprocf @@cycle2deg

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.deg.per.cycle
    .return:
        retn
$endp
}

macro @@cycle2deg.fpu
{
$usprocf @@cycle2deg

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.deg.per.cycle
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@cycle2deg.sse
$else
  @@cycle2deg.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: cycles to arc degrees:minutes:seconds
; double double double cycle2arc ( double x )
; x = esp
;
; return_1 = st2 = degrees
; return_2 = st1 = minutes
; return_3 = st0 = seconds

macro @@cycle2arc.sse
{
$usprocf @@cycle2arc

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        xmulsd  xmm0, ??.deg.per.cycle, rbx
      $else
        xmulsd  xmm0, ??.deg.per.cycle
      $end
        mov     ebx, @@deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

macro @@cycle2arc.fpu
{
$usprocf @@cycle2arc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        fmulq   ??.deg.per.cycle, rbx
      $else
        fmulq   ??.deg.per.cycle
      $end
        mov     ebx, @@deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@cycle2arc.sse
$else
  @@cycle2arc.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: cycles to arc degrees:minutes:seconds
; double co.cycle2arc ( double *d, double *m, double *s, double x )
; x = esp
;
; eax = d offset
; edx = m offset
; ecx = s offset
;
; return_1 = st2 = degrees
; return_2 = st1 = minutes
; return_3 = st0 = seconds
;
; return   = st0 = degrees

macro @@co.cycle2arc.sse
{
$usprocf @@co.cycle2arc

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        xmulsd  xmm0, ??.deg.per.cycle, ebx
      $else
        xmulsd  xmm0, ??.deg.per.cycle
      $end
        mov     ebx, @@co.deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

macro @@co.cycle2arc.fpu
{
$usprocf @@co.cycle2arc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
      $ifdef _X64
        fmulq   ??.deg.per.cycle, rbx
      $else
        fmulq   ??.deg.per.cycle
      $end
        mov     ebx, @@co.deg2arc.enter
        call    ebx
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.cycle2arc.sse
$else
  @@co.cycle2arc.fpu
$end

; ------------------------------------------------------------------------------

; angle conversion: cycles to grads
;
; 1 cycle = 400 grads
;   grads = cycles * 400 = cycles * [grads per cycle]

macro @@cycle2grad.sse
{
$usprocf @@cycle2grad

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.grad.per.cycle
    .return:
        retn
$endp
}

macro @@cycle2grad.fpu
{
$usprocf @@cycle2grad

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.grad.per.cycle
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@cycle2grad.sse
$else
  @@cycle2grad.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; temperature conversion: celsius to kelvin
; K = °C + 273.15

macro @@celsius2kelvin.sse
{
$usprocf @@celsius2kelvin

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xaddsd  xmm0, ??.273.15
    .return:
        retn
$endp
}

macro @@celsius2kelvin.fpu
{
$usprocf @@celsius2kelvin

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        faddq   ??.273.15
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@celsius2kelvin.sse
$else
  @@celsius2kelvin.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: celsius to fahrenheit
; °F = °C * 1.8 + 32
; °F = °C * (9/5) + 32

macro @@celsius2fahrenheit.sse
{
$usprocf @@celsius2fahrenheit

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1.8
        xaddsd  xmm0, ??.32.0
    .return:
        retn
$endp
}

macro @@celsius2fahrenheit.fpu
{
$usprocf @@celsius2fahrenheit

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1.8
        faddq   ??.32.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@celsius2fahrenheit.sse
$else
  @@celsius2fahrenheit.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: celsius to rankine
; °Ra = °C * 1.8 + 32 + 459.67 = °C * 1.8 + 491.67
; °Ra = °C * (9/5) + 491.67

macro @@celsius2rankine.sse
{
$usprocf @@celsius2rankine

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1.8
        xaddsd  xmm0, ??.491.67
    .return:
        retn
$endp
}

macro @@celsius2rankine.fpu
{
$usprocf @@celsius2rankine

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1.8
        faddq   ??.491.67
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@celsius2rankine.sse
$else
  @@celsius2rankine.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: celsius to reaumur
; °R = °C * 0.8
; °R = °C * (4/5)

macro @@celsius2reaumur.sse
{
$usprocf @@celsius2reaumur

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.0.8
    .return:
        retn
$endp
}

macro @@celsius2reaumur.fpu
{
$usprocf @@celsius2reaumur

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.0.8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@celsius2reaumur.sse
$else
  @@celsius2reaumur.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: kelvin to celsius
; °C = K - 273.15

macro @@kelvin2celsius.sse
{
$usprocf @@kelvin2celsius

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xsubsd  xmm0, ??.273.15
    .return:
        retn
$endp
}

macro @@kelvin2celsius.fpu
{
$usprocf @@kelvin2celsius

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsubq   ??.273.15
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@kelvin2celsius.sse
$else
  @@kelvin2celsius.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: kelvin to fahrenheit
; °F = K * 1.8 - 459.67
; °F = K * (9/5) - 459.67

macro @@kelvin2fahrenheit.sse
{
$usprocf @@kelvin2fahrenheit

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1.8
        xsubsd  xmm0, ??.459.67
    .return:
        retn
$endp
}

macro @@kelvin2fahrenheit.fpu
{
$usprocf @@kelvin2fahrenheit

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1.8
        fsubq   ??.459.67
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@kelvin2fahrenheit.sse
$else
  @@kelvin2fahrenheit.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: kelvin to rankine
; °Ra = K * 1.8
; °Ra = K * (9/5)

macro @@kelvin2rankine.sse
{
$usprocf @@kelvin2rankine

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1.8
    .return:
        retn
$endp
}

macro @@kelvin2rankine.fpu
{
$usprocf @@kelvin2rankine

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1.8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@kelvin2rankine.sse
$else
  @@kelvin2rankine.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: kelvin to reaumur
; °R = (K - 273.15) * 0.8
; °R = (K - 273.15) * (4/5)

macro @@kelvin2reaumur.sse
{
$usprocf @@kelvin2reaumur

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xsubsd  xmm0, ??.273.15
        xmulsd  xmm0, ??.0.8
    .return:
        retn
$endp
}

macro @@kelvin2reaumur.fpu
{
$usprocf @@kelvin2reaumur

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsubq   ??.273.15
        fmulq   ??.0.8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@kelvin2reaumur.sse
$else
  @@kelvin2reaumur.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: fahrenheit to celsius
; °C = (°F - 32) / 1.8 = (°F - 32) * (1/1.8)
; °C = (°F - 32) * (5/9)

macro @@fahrenheit2celsius.sse
{
$usprocf @@fahrenheit2celsius

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xsubsd  xmm0, ??.32.0
        xmulsd  xmm0, ??.1D1.8
    .return:
        retn
$endp
}

macro @@fahrenheit2celsius.fpu
{
$usprocf @@fahrenheit2celsius

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsubq   ??.32.0
        fmulq   ??.1D1.8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fahrenheit2celsius.sse
$else
  @@fahrenheit2celsius.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: fahrenheit to kelvin
; K = (°F + 459.67) / 1.8 = (°F + 459.67) * (1/1.8)
; K = (°F + 459.67) * (5/9)

macro @@fahrenheit2kelvin.sse
{
$usprocf @@fahrenheit2kelvin

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xaddsd  xmm0, ??.459.67
        xmulsd  xmm0, ??.1D1.8
    .return:
        retn
$endp
}

macro @@fahrenheit2kelvin.fpu
{
$usprocf @@fahrenheit2kelvin

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        faddq   ??.459.67
        fmulq   ??.1D1.8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fahrenheit2kelvin.sse
$else
  @@fahrenheit2kelvin.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: fahrenheit to rankine
; °Ra = °F + 459.67

macro @@fahrenheit2rankine.sse
{
$usprocf @@fahrenheit2rankine

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xaddsd  xmm0, ??.459.67
    .return:
        retn
$endp
}

macro @@fahrenheit2rankine.fpu
{
$usprocf @@fahrenheit2rankine

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        faddq   ??.459.67
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fahrenheit2rankine.sse
$else
  @@fahrenheit2rankine.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: fahrenheit to reaumur
; °R = (°F - 32) / 2.25 = (°F - 32) * (1/2.25)
; °R = (°F - 32) * (4/9)

macro @@fahrenheit2reaumur.sse
{
$usprocf @@fahrenheit2reaumur

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xsubsd  xmm0, ??.32.0
        xmulsd  xmm0, ??.1D2.25
    .return:
        retn
$endp
}

macro @@fahrenheit2reaumur.fpu
{
$usprocf @@fahrenheit2reaumur

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsubq   ??.32.0
        fmulq   ??.1D2.25
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fahrenheit2reaumur.sse
$else
  @@fahrenheit2reaumur.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: rankine to celsius
; °C = (°Ra - 32 - 459.67) / 1.8 = (°Ra - 491.67) * (1/1.8)
; °C = (°Ra - 491.67) * (5/9)

macro @@rankine2celsius.sse
{
$usprocf @@rankine2celsius

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xsubsd  xmm0, ??.491.67
        xmulsd  xmm0, ??.1D1.8
    .return:
        retn
$endp
}

macro @@rankine2celsius.fpu
{
$usprocf @@rankine2celsius

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsubq   ??.491.67
        fmulq   ??.1D1.8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rankine2celsius.sse
$else
  @@rankine2celsius.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: rankine to kelvin
; K = °Ra / 1.8 = °Ra * (1/1.8)
; K = °Ra * (5/9)

macro @@rankine2kelvin.sse
{
$usprocf @@rankine2kelvin

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1D1.8
    .return:
        retn
$endp
}

macro @@rankine2kelvin.fpu
{
$usprocf @@rankine2kelvin

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1D1.8
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rankine2kelvin.sse
$else
  @@rankine2kelvin.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: rankine to fahrenheit
; °F = °Ra - 459.67

macro @@rankine2fahrenheit.sse
{
$usprocf @@rankine2fahrenheit

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xsubsd  xmm0, ??.459.67
    .return:
        retn
$endp
}

macro @@rankine2fahrenheit.fpu
{
$usprocf @@rankine2fahrenheit

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsubq   ??.459.67
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rankine2fahrenheit.sse
$else
  @@rankine2fahrenheit.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: rankine to reaumur
; °R = (°Ra - 32 - 459.67) / 2.25 = (°Ra - 491.67) * (1/2.25)
; °R = (°Ra - 491.67) * (4/9)

macro @@rankine2reaumur.sse
{
$usprocf @@rankine2reaumur

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xsubsd  xmm0, ??.491.67
        xmulsd  xmm0, ??.1D2.25
    .return:
        retn
$endp
}

macro @@rankine2reaumur.fpu
{
$usprocf @@rankine2reaumur

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsubq   ??.491.67
        fmulq   ??.1D2.25
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@rankine2reaumur.sse
$else
  @@rankine2reaumur.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: reaumur to celsius
; °C = °R * 1.25
; °C = °R * (5/4)

macro @@reaumur2celsius.sse
{
$usprocf @@reaumur2celsius

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1.25
    .return:
        retn
$endp
}

macro @@reaumur2celsius.fpu
{
$usprocf @@reaumur2celsius

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1.25
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@reaumur2celsius.sse
$else
  @@reaumur2celsius.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: reaumur to kelvin
; K = °R * 1.25 + 273.15
; K = °R * (5/4) + 273.15

macro @@reaumur2kelvin.sse
{
$usprocf @@reaumur2kelvin

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.1.25
        xaddsd  xmm0, ??.273.15
    .return:
        retn
$endp
}

macro @@reaumur2kelvin.fpu
{
$usprocf @@reaumur2kelvin

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.1.25
        faddq   ??.273.15
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@reaumur2kelvin.sse
$else
  @@reaumur2kelvin.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: reaumur to fahrenheit
; °F = °R * 2.25 + 32
; °F = °R * (9/4) + 32

macro @@reaumur2fahrenheit.sse
{
$usprocf @@reaumur2fahrenheit

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.2.25
        xaddsd  xmm0, ??.32.0
    .return:
        retn
$endp
}

macro @@reaumur2fahrenheit.fpu
{
$usprocf @@reaumur2fahrenheit

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.2.25
        faddq   ??.32.0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@reaumur2fahrenheit.sse
$else
  @@reaumur2fahrenheit.fpu
$end

; ------------------------------------------------------------------------------

; temperature conversion: reaumur to rankine
; °Ra = °R * 2.25 + 32 + 459.67 = °R * 2.25 + 491.67
; °Ra = °R * (9/4) + 491.67

macro @@reaumur2rankine.sse
{
$usprocf @@reaumur2rankine

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmulsd  xmm0, ??.2.25
        xaddsd  xmm0, ??.491.67
    .return:
        retn
$endp
}

macro @@reaumur2rankine.fpu
{
$usprocf @@reaumur2rankine

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmulq   ??.2.25
        faddq   ??.491.67
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@reaumur2rankine.sse
$else
  @@reaumur2rankine.fpu
$end

; ------------------------------------------------------------------------------
