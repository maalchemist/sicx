
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (FMA functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double fmadd132 ( double x, double y, double z )
; fused multiply-add
;
; VFMADD132SD xmm1, xmm2, xmm3/m64
; xmm1 = xmm1*xmm3 + xmm2
; f(x,y,z) = x*z+y
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fmadd132.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfmadd132sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fmadd132.sse
{
$usprocf @@fmadd132

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm2                      ; xmm0=x*z
        addsd   xmm0, xmm1                      ; xmm0=x*z+y

   .return:
        retn
$endp
}

macro @@fmadd132.fpu
{
$usprocf @@fmadd132

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulp   st2, st0                        ; st0 = y, st1 = x*z
        faddp                                   ; st0 = x*z+y

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fmadd132.sse
$else
  @@fmadd132.fpu
$end

; ------------------------------------------------------------------------------

; double fmadd213 ( double x, double y, double z )
; fused multiply-add
;
; VFMADD213SD xmm1, xmm2, xmm3/m64
; xmm1 = xmm1*xmm2 + xmm3
; f(x,y,z) = x*y+z
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fmadd213.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfmadd213sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fmadd213.sse
{
$usprocf @@fmadd213

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm1                      ; xmm0 = x*y
        addsd   xmm0, xmm2                      ; xmm0 = x*y+z

   .return:
        retn
$endp
}

macro @@fmadd213.fpu
{
$usprocf @@fmadd213

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fxch    st2                             ; st0 = x, st1 = y, st2 = z
        fmulp                                   ; st0 = x*y, st1 = z
        faddp                                   ; st0 = x*y+z

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fmadd213.sse
$else
  @@fmadd213.fpu
$end

; ------------------------------------------------------------------------------

; double fmadd231 ( double x, double y, double z )
; fused multiply-add
;
; VFMADD231SD xmm1, xmm2, xmm3/m64
; xmm1 = xmm2*xmm3 + xmm1
; f(x,y,z) = y*z+x
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fmadd231.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfmadd231sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fmadd231.sse
{
$usprocf @@fmadd231

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm1, xmm2                      ; xmm1 = y*z
        addsd   xmm0, xmm1                      ; xmm0 = y*z+x

   .return:
        retn
$endp
}

macro @@fmadd231.fpu
{
$usprocf @@fmadd231

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulp                                   ; st0 = y*z, st1 = x
        faddp                                   ; st0 = y*z+x

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fmadd231.sse
$else
  @@fmadd231.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double fnmadd132 ( double x, double y, double z )
; fused negative multiply-add
;
; VFNMADD132SD xmm1, xmm2, xmm3/m64
; xmm1 = -xmm1*xmm3 + xmm2
; f(x,y,z) = -x*z+y
; f(x,y,z) = -(x*z-y)
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fnmadd132.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfnmadd132sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fnmadd132.sse
{
$usprocf @@fnmadd132

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm2                      ; xmm0 = x*z
        subsd   xmm0, xmm1                      ; xmm0 = x*z-y
        @@.chs  xmm0                            ; xmm0 = -(x*z-y)

   .return:
        retn
$endp
}

macro @@fnmadd132.fpu
{
$usprocf @@fnmadd132

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulp   st2, st0                        ; st0 = y, st1 = x*z
        fsubrp                                  ; st0 = -x*z+y

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fnmadd132.sse
$else
  @@fnmadd132.fpu
$end

; ------------------------------------------------------------------------------

; double fnmadd213 ( double x, double y, double z )
; fused negative multiply-add
;
; VFNMADD213SD xmm1, xmm2, xmm3/m64
; xmm1 = -xmm1*xmm2 + xmm3
; f(x,y,z) = -x*y+z
; f(x,y,z) = -(x*y-z)
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fnmadd213.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfnmadd213sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fnmadd213.sse
{
$usprocf @@fnmadd213

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm1                      ; xmm0 = x*y
        subsd   xmm0, xmm2                      ; xmm0 = x*y-z
        @@.chs  xmm0                            ; xmm0 = -(x*y-z)

   .return:
        retn
$endp
}

macro @@fnmadd213.fpu
{
$usprocf @@fnmadd213

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fxch    st2                             ; st0 = x, st1 = y, st2 = z
        fmulp                                   ; st0 = x*y, st1 = z
        fsubp                                   ; st0 = -x*y+z

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fnmadd213.sse
$else
  @@fnmadd213.fpu
$end

; ------------------------------------------------------------------------------

; double fnmadd231 ( double x, double y, double z )
; fused negative multiply-add
;
; VFNMADD231SD xmm1, xmm2, xmm3/m64
; xmm1 = -xmm2*xmm3 + xmm1
; f(x,y,z) = -y*z+x
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fnmadd231.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfnmadd231sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fnmadd231.sse
{
$usprocf @@fnmadd231

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm1, xmm2                      ; xmm1 = y*z
        subsd   xmm0, xmm1                      ; xmm0 = -y*z+x

   .return:
        retn
$endp
}

macro @@fnmadd231.fpu
{
$usprocf @@fnmadd231

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulp                                   ; st0 = y*z, st1 = x
        fsubp                                   ; st0 = -y*z+x

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fnmadd231.sse
$else
  @@fnmadd231.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double fmsub132 ( double x, double y, double z )
; fused multiply-subtract
;
; VFMSUB132SD xmm1, xmm2, xmm3/m64
; xmm1 = xmm1*xmm3 - xmm2
; f(x,y,z) = x*z-y
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fmsub132.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfmsub132sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fmsub132.sse
{
$usprocf @@fmsub132

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm2                      ; xmm0 = x*z
        subsd   xmm0, xmm1                      ; xmm0 = x*z-y

   .return:
        retn
$endp
}

macro @@fmsub132.fpu
{
$usprocf @@fmsub132

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulp   st2, st0                        ; st0 = y, st2 = x*z
        fsubp                                   ; st0 = x*z-y

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fmsub132.sse
$else
  @@fmsub132.fpu
$end

; ------------------------------------------------------------------------------

; double fmsub213 ( double x, double y, double z )
; fused multiply-subtract
;
; VFMSUB213SD xmm1, xmm2, xmm3/m64
; xmm1 = xmm1*xmm2 - xmm3
; f(x,y,z) = x*y-z
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fmsub213.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfmsub213sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fmsub213.sse
{
$usprocf @@fmsub213

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm1                      ; xmm0 = x*y
        subsd   xmm0, xmm2                      ; xmm0 = x*y-z

   .return:
        retn
$endp
}

macro @@fmsub213.fpu
{
$usprocf @@fmsub213

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fxch    st2                             ; st0 = x, st1 = y, st2 = z
        fmulp                                   ; st0 = x*y, st1 = z
        fsubrp                                  ; st0 = x*y-z

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fmsub213.sse
$else
  @@fmsub213.fpu
$end

; ------------------------------------------------------------------------------

; double fmsub231 ( double x, double y, double z )
; fused multiply-subtract
;
; VFMSUB231SD xmm1, xmm2, xmm3/m64
; xmm1 = xmm2*xmm3 - xmm1
; f(x,y,z) = y*z-x
; f(x,y,z) = -(x-y*z)
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fmsub231.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfmsub231sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fmsub231.sse
{
$usprocf @@fmsub231

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm1, xmm2                      ; xmm1 = y*z
        subsd   xmm0, xmm1                      ; xmm0 = x-y*z
        @@.chs  xmm0                            ; xmm0 = -(x-y*z)

   .return:
        retn
$endp
}

macro @@fmsub231.fpu
{
$usprocf @@fmsub231

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fmulp                                   ; st0 = y*z, st1 = x
        fsubrp                                  ; st0 = y*z-x

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fmsub231.sse
$else
  @@fmsub231.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double fnmsub132 ( double x, double y, double z )
; fused negative multiply-subtract
;
; VFNMSUB132SD xmm1, xmm2, xmm3/m64
; xmm1 = -xmm1*xmm3 - xmm2
; f(x,y,z) = -x*z-y
; f(x,y,z) = -(x*z+y)
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fnmsub132.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfnmsub132sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fnmsub132.sse
{
$usprocf @@fnmsub132

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm2                      ; xmm0 = x*z
        addsd   xmm0, xmm1                      ; xmm0 = x*z+y
        @@.chs  xmm0                            ; xmm0 = -(x*z+y)

   .return:
        retn
$endp
}

macro @@fnmsub132.fpu
{
$usprocf @@fnmsub132

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fchs                                    ; st0 = -z, st1 = y, st2 = x
        fmulp   st2, st0                        ; st0 = y, st1 = -x*z
        fsubp                                   ; st0 = -x*z-y

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fnmsub132.sse
$else
  @@fnmsub132.fpu
$end

; ------------------------------------------------------------------------------

; double fnmsub213 ( double x, double y, double z )
; fused negative multiply-subtract
;
; VFNMSUB213SD xmm1, xmm2, xmm3/m64
; xmm1 = -xmm1*xmm2 - xmm3
; f(x,y,z) = -x*y-z
; f(x,y,z) = -(x*y+z)
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fnmsub213.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfnmsub213sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fnmsub213.sse
{
$usprocf @@fnmsub213

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm1                      ; xmm0 = x*y
        addsd   xmm0, xmm2                      ; xmm0 = x*y+z
        @@.chs  xmm0                            ; xmm0 = -(x*y+z)

   .return:
        retn
$endp
}

macro @@fnmsub213.fpu
{
$usprocf @@fnmsub213

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fchs                                    ; st0 = -z, st1 = y, st2 = x
        fxch    st2                             ; st0 = x, st1 = y, st2 = -z
        fmulp                                   ; st0 = x*y, st1 = -z
        fsubp                                   ; st0 = -x*y-z

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fnmsub213.sse
$else
  @@fnmsub213.fpu
$end

; ------------------------------------------------------------------------------

; double fnmsub231 ( double x, double y, double z )
; fused negative multiply-subtract
;
; VFNMSUB231SD xmm1, xmm2, xmm3/m64
; xmm1 = -xmm2*xmm3 - xmm1
; f(x,y,z) = -y*z-x
; f(x,y,z) = -(y*z+x)
;
; x = rsp
; y = rsp + 8
; z = rsp + 16

$usprocf @@fnmsub231.fma

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        vfnmsub231sd xmm0, xmm1, xmm2

   .return:
        retn
$endp

macro @@fnmsub231.sse
{
$usprocf @@fnmsub231

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = z
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm1, xmm2                      ; xmm1 = y*z
        addsd   xmm0, xmm1                      ; xmm0 = y*z+x
        @@.chs  xmm0                            ; xmm0 = -(y*z+x)

   .return:
        retn
$endp
}

macro @@fnmsub231.fpu
{
$usprocf @@fnmsub231

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y, st1 = x
        fld     qword [rsp + 16]                ; st0 = z, st1 = y, st2 = x
;       @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fchs                                    ; st0 = -z, st1 = y, st2 = x
        fmulp                                   ; st0 = -y*z, st1 = x
        fsubrp                                  ; st0 = -y*z-x

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fnmsub231.sse
$else
  @@fnmsub231.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
