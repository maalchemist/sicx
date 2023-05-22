
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (approximate hyperbolic functions utils)

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
; sinh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get sinh for some args
;
; sinh(0)    = 0
; sinh(NaN)  = NaN
; sinh(PInf) = PInf
; sinh(NInf) = NInf

; <- rbx - assign result flag

macro @@sinh.arg.sse
{
$asprocf @@sinh.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(XInf) = XInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, ??.SD_fsinh_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jae    .max                             ; jump if x >= max_arg

        xmovsd  xmm5, ??.SD_fsinh_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .min:                                        ; x <= min_arg
        xmovsd  xmm0, SIC_AX.NInf
        jmp    .assign

   .max:                                        ; x >= max_arg
        xmovsd  xmm0, SIC_AX.PInf
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@sinh.arg.fpu
{
$asprocf @@sinh.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(XInf) = XInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fldq    ??.SD_fsinh_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_fsinh_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
        fstp    st0
        fldq    SIC_AX.NInf
        jmp    .assign

   .max:                                        ; x >= max_arg
        fstp    st0
        fldq    SIC_AX.PInf
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@sinh.arg.sse
$else
  @@sinh.arg.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosine
; cosh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cosh for some args
;
; cosh(0)    = 1
; cosh(NaN)  = NaN
; cosh(PInf) = PInf
; cosh(NInf) = PInf

; <- rbx - assign result flag

macro @@cosh.arg.sse
{
$asprocf @@cosh.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .assign                          ; f(PInf) = PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, ??.SD_fcosh_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jae    .max                             ; jump if x >= max_arg

        xmovsd  xmm5, ??.SD_fcosh_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .min:                                        ; x <= min_arg
   .max:                                        ; x >= max_arg
;       xmovsd  xmm0, SIC_AX.PInf
;       jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .assign

   .Zero:                                       ; x = 0
        xmovsd  xmm0, SIC_AX.1.0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@cosh.arg.fpu
{
$asprocf @@cosh.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .assign                          ; f(PInf) = PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fldq    ??.SD_fcosh_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_fcosh_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
   .max:                                        ; x >= max_arg
;       fstp    st0
;       fldq    SIC_AX.PInf
;       jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0
        fld1
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cosh.arg.sse
$else
  @@cosh.arg.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic sine and cosine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get sinh and cosh for some args
;
; sinh(0)    = 0
; sinh(NaN)  = NaN
; sinh(PInf) = PInf
; sinh(NInf) = NInf
;
; cosh(0)    = 1
; cosh(NaN)  = NaN
; cosh(PInf) = PInf
; cosh(NInf) = PInf

; <- rbx - assign result flag

macro @@sinhcosh.arg.sse
{
$asprocf @@sinhcosh.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN

   .main:
        xmovsd  xmm5, ??.SD_fsinhcosh_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jae    .max                             ; jump if x >= max_arg

        xmovsd  xmm5, ??.SD_fsinhcosh_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .min:                                        ; x <= min_arg
        xmovsd  xmm0, SIC_AX.NInf               ; sinh = NInf
        xmovx   xmm1, xmm0                      ; cosh = PInf
        @@.chs  xmm1
        jmp    .assign

   .max:                                        ; x >= max_arg
        xmovsd  xmm0, SIC_AX.PInf               ; sinh = PInf
        xmovx   xmm1, xmm0                      ; cosh = PInf
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
;       xmovsd  xmm0, SIC_AX.NInf               ; sinh = NInf
        xmovx   xmm1, xmm0                      ; cosh = PInf
        @@.chs  xmm1
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
;       xmovsd  xmm0, SIC_AX.PInf               ; sinh = PInf
        xmovx   xmm1, xmm0                      ; cosh = PInf
        jmp    .assign

   .NaN:                                        ; x = NaN
;       xmovsd  xmm0, SIC_AX.NaN                ; sinh = NaN
        xmovx   xmm1, xmm0                      ; cosh = NaN
        jmp    .assign

   .Zero:                                       ; x = 0
;       xmovx   xmm0, xmm0                      ; sinh = 0
        xmovsd  xmm1, SIC_AX.1.0                ; cosh = 1
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@sinhcosh.arg.fpu
{
$asprocf @@sinhcosh.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN

   .main:
        fldq    ??.SD_fsinhcosh_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_fsinhcosh_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
        fstp    st0
        fldq    SIC_AX.NInf                     ; sinh = NInf
        fld     st0                             ; cosh = PInf
        fchs
        jmp    .assign

   .max:                                        ; x >= max_arg
        fstp    st0
        fldq    SIC_AX.PInf                     ; sinh = PInf
        fld     st0                             ; cosh = PInf
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        fld     st0                             ; sinh = NInf
        fchs                                    ; cosh = PInf
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fld     st0                             ; sinh = PInf
        jmp    .assign                          ; cosh = PInf

   .NaN:                                        ; x = NaN
        fld     st0                             ; sinh = NaN
        jmp    .assign                          ; cosh = NaN

   .Zero:                                       ; x = 0
        fld1                                    ; sinh = 0
;       jmp    .assign                          ; cosh = 1

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@sinhcosh.arg.sse
$else
  @@sinhcosh.arg.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosine and sine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cosh and sinh for some args
;
; cosh(0)    = 1
; cosh(NaN)  = NaN
; cosh(PInf) = PInf
; cosh(NInf) = PInf
;
; sinh(0)    = 0
; sinh(NaN)  = NaN
; sinh(PInf) = PInf
; sinh(NInf) = NInf

; <- rbx - assign result flag

macro @@coshsinh.arg.sse
{
$asprocf @@coshsinh.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN

   .main:
        xmovsd  xmm5, ??.SD_fcoshsinh_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jae    .max                             ; jump if x >= max_arg

        xmovsd  xmm5, ??.SD_fcoshsinh_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .min:                                        ; x <= min_arg
        xmovsd  xmm0, SIC_AX.PInf               ; cosh = PInf
        xmovx   xmm1, xmm0                      ; sinh = NInf
        @@.chs  xmm1
        jmp    .assign

   .max:                                        ; x >= max_arg
        xmovsd  xmm0, SIC_AX.PInf               ; cosh = PInf
        xmovx   xmm1, xmm0                      ; sinh = PInf
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        xmovx   xmm1, xmm0                      ; cosh = PInf
        @@.chs  xmm0                            ; sinh = NInf
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
;       xmovsd  xmm0, SIC_AX.PInf               ; cosh = PInf
        xmovx   xmm1, xmm0                      ; sinh = PInf
        jmp    .assign

   .NaN:                                        ; x = NaN
;       xmovsd  xmm0, SIC_AX.NaN                ; cosh = NaN
        xmovx   xmm1, xmm0                      ; sinh = NaN
        jmp    .assign

   .Zero:                                       ; x = 0
        xmovx   xmm1, xmm0                      ; cosh = 1
        xmovsd  xmm0, SIC_AX.1.0                ; sinh = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@coshsinh.arg.fpu
{
$asprocf @@coshsinh.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN

   .main:
        fldq    ??.SD_fcoshsinh_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_fcoshsinh_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
        fstp    st0
        fldq    SIC_AX.PInf                     ; cosh = PInf
        fld     st0                             ; sinh = NInf
        fchs
        jmp    .assign

   .max:                                        ; x >= max_arg
        fstp    st0
        fldq    SIC_AX.PInf                     ; cosh = PInf
        fld     st0                             ; sinh = PInf
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        fld     st0                             ; cosh = PInf
        fchs                                    ; sinh = NInf
        fxch
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fld     st0                             ; cosh = PInf
        jmp    .assign                          ; sinh = PInf

   .NaN:                                        ; x = NaN
        fld     st0                             ; cosh = NaN
        jmp    .assign                          ; sinh = NaN

   .Zero:                                       ; x = 0
        fld1                                    ; cosh = 1
        fxch                                    ; sinh = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@coshsinh.arg.sse
$else
  @@coshsinh.arg.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic secant
; sech(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get sech for some args
;
; sech(0)    = 1
; sech(NaN)  = NaN
; sech(PInf) = +0
; sech(NInf) = +0

; <- rbx - assign result flag

macro @@sech.arg.sse
{
$asprocf @@sech.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, ??.SD_fsech_max_arg
        xmovx   xmm4, xmm0
        @@.abs  xmm4                            ; xmm4 = |x|
        comisd  xmm4, xmm5                      ; compare |x| to max_arg
        jb     .return                          ; jump if |x| < max_arg

   .max:                                        ; |x| >= max_arg
   .Inf:                                        ; Infinity
        xorpd   xmm0, xmm0                      ; +0.0
        jmp    .assign

   .Zero:                                       ; x = 0
        xmovsd  xmm0, SIC_AX.1.0                ; 1.0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@sech.arg.fpu
{
$asprocf @@sech.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fldq    ??.SD_fsech_max_arg
        fld     st1
        fabs
        fcompp                                  ; compare |x| to max_arg
        fnjl   .return                          ; jump if |x| < max_arg

   .max:                                        ; |x| >= max_arg
   .Inf:                                        ; Infinity
        fstp    st0
        fldz                                    ; +0.0
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0
        fld1                                    ; 1.0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@sech.arg.sse
$else
  @@sech.arg.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosecant
; cosech(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get sech for some args
;
; cosech(+0)   = PInf
; cosech(-0)   = NInf
; cosech(NaN)  = NaN
; cosech(PInf) = +0
; cosech(NInf) = -0

; <- rbx - assign result flag

macro @@cosech.arg.sse
{
$asprocf @@cosech.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023-356
        jb     .eps                             ; jump if |x| < 2^(-356)

        xmovsd  xmm5, ??.SD_fcosech_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jae    .max                             ; jump if x >= max_arg

        xmovsd  xmm5, ??.SD_fcosech_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .min:                                        ; x <= min_arg
   .NInf:                                       ; Negative Infinity
        xorpd   xmm0, xmm0
        @@.chs  xmm0                            ; -0.0
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; Positive Infinity
        xorpd   xmm0, xmm0                      ; +0.0
        jmp    .assign

   .eps:                                        ; |x| < 2^(-356) | cosech(x) = 1/x - x/6
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 1/x
        xmovsd  xmm4, SIC_AX.m1D6
        mulsd   xmm0, xmm4                      ; xmm0 = -x/6
        addsd   xmm0, xmm5                      ; xmm0 = 1/x - x/6
        jmp    .assign

   .Zero:                                       ; x = 0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0.0
        xmovsd  xmm0, SIC_AX.NInf               ; NInf
        jmp    .assign
   .PZero:                                      ; x = +0.0
        xmovsd  xmm0, SIC_AX.PInf               ; PInf
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@cosech.arg.fpu
{
$asprocf @@cosech.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023-356
        jb     .eps                             ; jump if |x| < 2^(-356)

        fldq    ??.SD_fcosech_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_fcosech_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
   .NInf:                                       ; Negative Infinity
        fstp    st0
        fldz
        fchs                                    ; -0.0
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; Positive Infinity
        fstp    st0
        fldz                                    ; +0.0
        jmp    .assign

   .eps:                                        ; |x| < 2^(-356) | cosech(x) = 1/x - x/6
        fld     st0
        fmulq   SIC_AX.m1D6
        fxch                                    ; st0 = x | st1 = -x/6
        fld1
        fdivrp
        faddp                                   ; st0 = 1/x - x/6
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0.0
        fldq    SIC_AX.NInf                     ; NInf
        jmp    .assign
   .PZero:                                      ; x = +0.0
        fldq    SIC_AX.PInf                     ; PInf
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cosech.arg.sse
$else
  @@cosech.arg.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic tangent
; tanh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get tanh for some args
;
; tanh(0)    = 0
; tanh(NaN)  = NaN
; tanh(PInf) = +1
; tanh(NInf) = -1

; <- rbx - assign result flag

macro @@tanh.arg.sse
{
$asprocf @@tanh.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, ??.SD_ftanh_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jae    .max                             ; jump if x >= max_arg

        xmovsd  xmm5, ??.SD_ftanh_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.m1.0
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        xmovsd  xmm0, SIC_AX.1.0
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@tanh.arg.fpu
{
$asprocf @@tanh.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fldq    ??.SD_ftanh_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_ftanh_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldq    SIC_AX.m1.0
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fld1
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@tanh.arg.sse
$else
  @@tanh.arg.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cotangent
; cotanh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cotanh for some args
;
; cotanh(+0)   = PInf
; cotanh(-0)   = NInf
; cotanh(NaN)  = NaN
; cotanh(PInf) = +1
; cotanh(NInf) = -1

; <- rbx - assign result flag

macro @@cotanh.arg.sse
{
$asprocf @@cotanh.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023-356
        jb     .eps                             ; jump if |x| < 2^(-356)

        xmovsd  xmm5, ??.SD_fcotanh_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jae    .max                             ; jump if x >= max_arg

        xmovsd  xmm5, ??.SD_fcotanh_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.m1.0
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        xmovsd  xmm0, SIC_AX.1.0
        jmp    .assign

   .eps:                                        ; |x| < 2^(-356) | cotanh(x) = 1/x + x/3
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 1/x
        xmovsd  xmm4, SIC_AX.1D3
        mulsd   xmm0, xmm4                      ; xmm0 = x/3
        addsd   xmm0, xmm5                      ; xmm0 = 1/x + x/3
        jmp    .assign

   .Zero:                                       ; x = 0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0
        xmovsd  xmm0, SIC_AX.NInf
        jmp    .assign
   .PZero:                                      ; x = +0
        xmovsd  xmm0, SIC_AX.PInf
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@cotanh.arg.fpu
{
$asprocf @@cotanh.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023-356
        jb     .eps                             ; jump if |x| < 2^(-356)

        fldq    ??.SD_fcotanh_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_fcotanh_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldq    SIC_AX.m1.0
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fld1
        jmp    .assign

   .eps:                                        ; |x| < 2^(-356) | cotanh(x) = 1/x + x/3
        fld     st0
        fmulq   SIC_AX.1D3
        fxch                                    ; st0 = x | st1 = x/3
        fld1
        fdivrp
        faddp                                   ; st0 = 1/x + x/3
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0
        fldq    SIC_AX.NInf
        jmp    .assign
   .PZero:                                      ; x = +0
        fldq    SIC_AX.PInf
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cotanh.arg.sse
$else
  @@cotanh.arg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; inverse hyperbolic sine
; asinh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get asinh for some args
;
; asinh(0)    = 0
; asinh(NaN)  = NaN
; asinh(PInf) = PInf
; asinh(NInf) = NInf

; <- rbx - assign result flag

macro @@asinh.arg.sse
{
$asprocf @@asinh.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(XInf) = XInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@asinh.arg.fpu
{
$asprocf @@asinh.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(XInf) = XInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@asinh.arg.sse
$else
  @@asinh.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic cosine
; acosh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get acosh for some args
;
; acosh(0)    = NaN
; acosh(NaN)  = NaN
; acosh(PInf) = PInf
; acosh(NInf) = NaN
;
; acosh(1)    = 0
; acosh(<1)   = NaN

; <- rbx - assign result flag

macro @@acosh.arg.sse
{
$asprocf @@acosh.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .assign                          ; f(PInf) = PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, SIC_AX.1.0
        comisd  xmm0, xmm5                      ; compare x to 1
        jb     .assign.NaN                      ; jump if x < 1
        ja     .return                          ; jump if x > 1

   .EQ.1:                                       ; x = 1
        xorpd   xmm0, xmm0
        jmp    .assign

   .Zero:                                       ; x = 0
   .NInf:                                       ; x = Negative Infinity
   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@acosh.arg.fpu
{
$asprocf @@acosh.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .assign                          ; f(PInf) = PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fld1
        fcomp                                   ; compare 1 to x
        fnstsw  ax
        sahf
        ja     .assign.NaN                      ; jump if x < 1 (1 > x)
        jb     .return                          ; jump if x > 1 (1 < x)
;       fnjg   .assign.NaN                      ; jump if x < 1 (1 > x)
;       fnjl   .return                          ; jump if x > 1 (1 < x)

   .EQ.1:                                       ; x = 1
        fstp    st0
        fldz
        jmp    .assign

   .Zero:                                       ; x = 0
   .NInf:                                       ; x = Negative Infinity
   .assign.NaN:
        fstp    st0
        fldq    SIC_AX.NaN
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@acosh.arg.sse
$else
  @@acosh.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic secant
; asech(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get asech for some args
;
; asech(+0)   = PInf
; asech(<0)   = NaN
; asech(NaN)  = NaN
; asech(PInf) = NaN
; asech(NInf) = NaN
;
; asech(1)    = 0
; asech(>1)   = NaN

; <- rbx - assign result flag

macro @@asech.arg.sse
{
$asprocf @@asech.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x8000                      ; test sign flag
        jnz    .assign.NaN
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign.NaN
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, SIC_AX.1.0
        comisd  xmm0, xmm5                      ; compare x to 1.0
        ja     .assign.NaN                      ; jump if x > 1.0
        jb     .return                          ; jump if x < 1.0

   .X.EQ.1.0:
        xorpd   xmm0, xmm0                      ; +0.0
        jmp    .assign

   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN                ; NaN
        jmp    .assign

   .Zero:
        xmovsd  xmm0, SIC_AX.PInf               ; PInf
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@asech.arg.fpu
{
$asprocf @@asech.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x8000                      ; test sign flag
        jnz    .assign.NaN
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign.NaN
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fld1
        fcomp                                   ; compare 1.0 to x
        fnstsw  ax
        sahf
        jb     .assign.NaN                      ; jump if x > 1.0 (1.0 < x)
        ja     .return                          ; jump if x < 1.0 (1.0 > x)

   .X.EQ.1.0:
        fstp    st0
        fldz                                    ; +0.0
        jmp    .assign

   .assign.NaN:
        fstp    st0
        fldq    SIC_AX.NaN                      ; NaN
        jmp    .assign

   .Zero:
        fstp    st0
        fldq    SIC_AX.PInf                     ; PInf
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@asech.arg.sse
$else
  @@asech.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic cosecant
; acosech(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get acosech for some args
;
; acosech(+0)   = PInf
; acosech(-0)   = NInf
; acosech(NaN)  = NaN
; acosech(PInf) = +0
; acosech(NInf) = -0

; <- rbx - assign result flag

macro @@acosech.arg.sse
{
$asprocf @@acosech.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .NInf:                                       ; Negative Infinity
        xorpd   xmm0, xmm0
        @@.chs  xmm0                            ; -0.0
        jmp    .assign

   .PInf:                                       ; Positive Infinity
        xorpd   xmm0, xmm0                      ; +0.0
        jmp    .assign

   .Zero:                                       ; x = 0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0
        xmovsd  xmm0, SIC_AX.NInf               ; NInf
        jmp    .assign
   .PZero:                                      ; x = +0
        xmovsd  xmm0, SIC_AX.PInf               ; PInf
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@acosech.arg.fpu
{
$asprocf @@acosech.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .NInf:                                       ; Negative Infinity
        fstp    st0
        fldz
        fchs                                    ; -0.0
        jmp    .assign

   .PInf:                                       ; Positive Infinity
        fstp    st0
        fldz                                    ; +0.0
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0
        fldq    SIC_AX.NInf                     ; NInf
        jmp    .assign
   .PZero:                                      ; x = +0
        fldq    SIC_AX.PInf                     ; PInf
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@acosech.arg.sse
$else
  @@acosech.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic tangent
; atanh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get atanh for some args
;
; atanh(0)    = 0
; atanh(NaN)  = NaN
; atanh(PInf) = NaN
; atanh(NInf) = NaN
;
; atanh(+1)   = PInf
; atanh(-1)   = NInf
; atanh(>+1)  = NaN
; atanh(<-1)  = NaN

; <- rbx - assign result flag

macro @@atanh.arg.sse
{
$asprocf @@atanh.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, SIC_AX.1.0
        comisd  xmm0, xmm5                      ; compare x to 1
        ja     .assign.NaN                      ; jump if x > 1
        jb     .LT.1                            ; jump if x < 1

   .EQ.1:                                       ; x = 1
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .assign

   .LT.1:                                       ; x < 1
        xmovsd  xmm5, SIC_AX.m1.0
        comisd  xmm0, xmm5                      ; compare x to -1
        jb     .assign.NaN                      ; jump if x < -1
        ja     .return                          ; jump if x > -1

   .EQ.m1:                                      ; x = -1
        xmovsd  xmm0, SIC_AX.NInf
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
   .NInf:                                       ; x = Negative Infinity
   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@atanh.arg.fpu
{
$asprocf @@atanh.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fld1
        fcomp                                   ; compare 1 to x
        fnstsw  ax
        sahf
        jb     .assign.NaN                      ; jump if x > 1 (1 < x)
        ja     .LT.1                            ; jump if x < 1 (1 > x)
;       fnjl   .assign.NaN                      ; jump if x > 1 (1 < x)
;       fnjg   .LT.1                            ; jump if x < 1 (1 > x)

   .EQ.1:                                       ; x = 1
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .assign

   .LT.1:                                       ; x < 1
        fldq    SIC_AX.m1.0
        fcomp                                   ; compare -1 to x
        fnstsw  ax
        sahf
        ja     .assign.NaN                      ; jump if x < -1 (-1 > x)
        jb     .return                          ; jump if x > -1 (-1 < x)
;       fnjg   .assign.NaN                      ; jump if x < -1 (-1 > x)
;       fnjl   .return                          ; jump if x > -1 (-1 < x)

   .EQ.m1:                                      ; x = -1
        fstp    st0
        fldq    SIC_AX.NInf
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
   .NInf:                                       ; x = Negative Infinity
   .assign.NaN:
        fstp    st0
        fldq    SIC_AX.NaN
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@atanh.arg.sse
$else
  @@atanh.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic cotangent
; acotanh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get acotanh for some args
;
; acotanh(0)     = NaN
; acotanh(NaN)   = NaN
; acotanh(PInf)  = +0
; acotanh(NInf)  = -0
;
; acotanh(+1)    = PInf
; acotanh(-1)    = NInf
; acotanh(|x|<1) = NaN

; <- rbx - assign result flag

macro @@acotanh.arg.sse
{
$asprocf @@acotanh.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, SIC_AX.1.0
        comisd  xmm0, xmm5                      ; compare x to 1
        ja     .return                          ; jump if x > 1
        jb     .LT.1                            ; jump if x < 1

   .EQ.1:                                       ; x = 1
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .assign

   .LT.1:                                       ; x < 1
        xmovsd  xmm5, SIC_AX.m1.0
        comisd  xmm0, xmm5                      ; compare x to -1
        jb     .return                          ; jump if x < -1
        ja     .assign.NaN                      ; jump if x > -1

   .EQ.m1:                                      ; x = -1
        xmovsd  xmm0, SIC_AX.NInf
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        xorpd   xmm0, xmm0
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        xorpd   xmm0, xmm0
        @@.chs  xmm0
;       xmovsd  xmm0, SIC_AX.m0.0
        jmp    .assign

   .Zero:                                       ; x = 0
   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@acotanh.arg.fpu
{
$asprocf @@acotanh.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fld1
        fcomp                                   ; compare 1 to x
        fnstsw  ax
        sahf
        jb     .return                          ; jump if x > 1 (1 < x)
        ja     .LT.1                            ; jump if x < 1 (1 > x)
;       fnjl   .return                          ; jump if x > 1 (1 < x)
;       fnjg   .LT.1                            ; jump if x < 1 (1 > x)

   .EQ.1:                                       ; x = 1
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .assign

   .LT.1:                                       ; x < 1
        fldq    SIC_AX.m1.0
        fcomp                                   ; compare -1 to x
        ja     .return                          ; jump if x < -1 (-1 > x)
        jb     .assign.NaN                      ; jump if x > -1 (-1 < x)
;       fnjg   .return                          ; jump if x < -1 (-1 > x)
;       fnjl   .assign.NaN                      ; jump if x > -1 (-1 < x)

   .EQ.m1:                                      ; x = -1
        fstp    st0
        fldq    SIC_AX.NInf
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fldz
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldz
        fchs
;       fldq    SIC_AX.m0.0
        jmp    .assign

   .Zero:                                       ; x = 0
   .assign.NaN:
        fstp    st0
        fldq    SIC_AX.NaN
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@acotanh.arg.sse
$else
  @@acotanh.arg.fpu
$end

; ------------------------------------------------------------------------------
